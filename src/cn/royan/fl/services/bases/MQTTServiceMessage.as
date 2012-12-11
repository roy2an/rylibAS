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
		
		public function readyType():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0xF0;
		}
		
		public function readDUP():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 3 & 0x01;
		}
		
		public function readyQoS():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 1 & 0x03;
		}
		
		public function readyRETAIN():uint
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
			this.readBytes(fixHead,0,2);
			
			type = value & 0xF0;
			dup = (value >> 3) & 0x01;
			qos = (value >> 1) & 0x03;
			retain = value & 0x01;
		}
		
		public function writeMessageValue(value:*):void//Variable Head
		{
			remainingLength = value.length;
			writeMessageType( type + (dup << 3) + (qos << 1) + retain );
			this.writeBytes(value);
			
			if( varHead == null ) (value as ByteArray).readBytes(varHead);
		}
		
		public function readMessageType():ByteArray
		{
			this.position = 0;
			
			if( fixHead == null && this.length > 0 ){
				fixHead = PoolMap.getInstanceByType(ByteArray);
				
				this.readBytes(fixHead, 0, 2);
			}
			return fixHead;
		}
		
		public function readMessageValue():ByteArray
		{
			this.position = 0;
			if( varHead == null && this.length > 2 ){
				varHead = PoolMap.getInstanceByType(ByteArray);
				
				this.readBytes(varHead, 2);
			}
			return varHead;
		}
	}
}