package cn.royan.fl.services.bases
{
	import cn.royan.fl.interfaces.IMessage;
	
	import flash.utils.ByteArray;
	
	public class MQTTMessage extends ByteArray implements IMessage
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
		
		public function MQTTMessage()
		{
			super();
		}
		
		public function writeMessageType(type:int):void
		{
			this.position = 0;
			this.writeByte(type);
			this.writeByte(0x00);
		}
		
		public function writeMessageValue(value:*):void
		{
			this.position = 1;
			this.writeByte(value.length);
			this.writeBytes(value);
		}
		
		public function isConnack():Boolean
		{
			this.position = 0;
			var params:Array = [this.readByte(), this.readByte(), this.readByte(), this.readByte()];
			return ( params[0] == CONNACK ) && params[3] ==0;
		}
		
//		public function isPuback():Boolean
//		{
//			this.position = 0;
//			return this.readUnsignedByte() == PUBACK;
//		}
//		
//		public function isSuback():Boolean
//		{
//			this.position = 0;
//			return this.readUnsignedByte() == SUBACK;
//		}
//		
//		public function isUnsuback():Boolean
//		{
//			this.position = 0;
//			return this.readUnsignedByte() == UNSUBACK;
//		}
//		
//		public function isPingResp():Boolean
//		{
//			this.position = 0;
//			return this.readUnsignedByte() == PINGRESP;
//		}
	}
}