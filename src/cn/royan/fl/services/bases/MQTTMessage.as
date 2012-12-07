package cn.royan.fl.services.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.ByteArray;
	
	public class MQTTMessage extends ByteArray implements IServiceMessageBase
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
		
		public function MQTTMessage()
		{
			super();
		}
		
		public function writeMessageType(type:int):void//Fix Head
		{
			this.position = 0;
			
			fixHead = PoolMap.getInstanceByType(ByteArray);
			fixHead.position = 0;
			fixHead.writeByte(type);
			fixHead.writeByte(0x00);
			fixHead.readBytes(this,0,2);
		}
		
		public function writeMessageValue(value:*):void//Variable Head
		{
			this.position = 1;
			this.writeByte(value.length);
			this.writeBytes(value);
		}
		
		public function getMessageType():ByteArray
		{
			this.position = 0;
			
			if( fixHead == null && this.length > 0 ){
				fixHead = PoolMap.getInstanceByType(ByteArray);
				
				this.readBytes(fixHead, 0, 2);
			}
			return fixHead;
		}
		
		public function getMessageValue():ByteArray
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