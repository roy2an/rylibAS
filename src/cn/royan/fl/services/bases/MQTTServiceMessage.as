package cn.royan.fl.services.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.ByteArray;
	
	public class MQTTServiceMessage extends ByteArray implements IServiceMessageBase
	{
		/* Message types */
		public static const CONNECT:uint 		= 0x10;
		public static const CONNACK:uint 		= 0x20;
		public static const PUBLISH:uint 		= 0x30;
		public static const PUBACK:uint 		= 0x40;
		public static const PUBREC:uint 		= 0x50;
		public static const PUBREL:uint 		= 0x60;
		public static const PUBCOMP:uint 		= 0x70;
		public static const SUBSCRIBE:uint 	= 0x80;
		public static const SUBACK:uint 		= 0x90;
		public static const UNSUBSCRIBE:uint 	= 0xA0;
		public static const UNSUBACK:uint 	= 0xB0;
		public static const PINGREQ:uint 		= 0xC0;
		public static const PINGRESP:uint 	= 0xD0;
		public static const DISCONNECT:uint 	= 0xE0;
		
		protected var fixHead:ByteArray;
		protected var varHead:ByteArray;
		protected var payLoad:ByteArray;
		
		protected var type:int
		protected var dup:int;
		protected var qos:int;
		protected var retain:int;
		protected var remainingLength:int;
		
		public function MQTTServiceMessage()
		{
			super();
		}
		
		public function writeType(value:int):void
		{
			type = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeDUP(value:int):void
		{
			dup = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeQoS(value:int):void
		{
			qos = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeRETAIN(value:int):void
		{
			retain = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeRemainingLength(value:int):void
		{
			remainingLength = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function readType():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0xF0;
		}
		
		public function readDUP():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 3 & 0x01;
		}
		
		public function readQoS():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 1 & 0x03;
		}
		
		public function readRETAIN():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0x01;
		}
		
		public function readRemainingLength():uint
		{
			this.position = 1;
			return this.readUnsignedByte();
		}
		
		public function writeMessageType(value:int):void//Fix Head
		{
			this.position = 0;
			
			if( fixHead == null )
				fixHead = PoolMap.getInstanceByType(ByteArray);
			
			this.position = 0;
			this.writeByte(value);
			this.writeByte(remainingLength);
			this.readBytes(fixHead);
			
			type = value & 0xF0;
			dup = (value >> 3) & 0x01;
			qos = (value >> 1) & 0x03;
			retain = value & 0x01;
		}
		
		public function writeMessageValue(value:*):void//Variable Head
		{
			this.position = 2;
			this.writeBytes(value);
			this.serialize();
			writeMessageType( type + (dup << 3) + (qos << 1) + retain );
		}
		
		public function readMessageType():ByteArray
		{
			return fixHead;
		}
		
		public function readMessageValue():ByteArray
		{
			return varHead;
		}
		
		public function readPayLoad():ByteArray
		{
			return payLoad;
		}
		
		public function serialize():void
		{
			type 	= this.readType();
			dup 	= this.readDUP();
			qos 	= this.readQoS();
			retain	= this.readRETAIN();
			
			fixHead = PoolMap.getInstanceByType(ByteArray);
			varHead = PoolMap.getInstanceByType(ByteArray);
			payLoad = PoolMap.getInstanceByType(ByteArray);
			
			this.position = 0;
			this.readBytes(fixHead, 0, 2);
			
			this.position = 2;
			switch( type ){
				case CONNECT://Remaining Length is the length of the variable header (12 bytes) and the length of the Payload
					this.readBytes(varHead, 0 , 12);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				case PUBLISH://Remaining Length is the length of the variable header plus the length of the payload
					var index:int = (this.readUnsignedByte() << 8) + this.readUnsignedByte();//the length of variable header
					this.readBytes(varHead, 0 , index);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				case SUBSCRIBE://Remaining Length is the length of the payload
				case SUBACK://Remaining Length is the length of the payload
				case UNSUBSCRIBE://Remaining Length is the length of the payload
					this.readBytes(varHead, 0 , 2);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				default://Remaining Length is the length of the variable header (2 bytes)
					this.readBytes(varHead, 0);
					
					remainingLength = varHead.length;
					break;
			}
		}
	}
}