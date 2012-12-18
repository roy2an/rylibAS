package cn.royan.fl.services.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	public class SoktServiceMessage extends ByteArray implements IServiceMessageBase
	{
		public static const CONNECT:uint 		= 0x10;
		public static const DISCONNECT:uint 	= 0x20;
		public static const PING:uint			= 0x30;
		
		protected var type:int;
		protected var value:ByteArray;
		
		public function SoktServiceMessage()
		{
			super();
		}
		
		public function writeMessageType(type:int):void
		{
			this.type = type;
		}
		
		public function writeMessageValue(value:*):void
		{
			this.value = value as ByteArray;
			this.position = 1;
			
			this.writeByte(this.value.length >> 8);
			this.writeByte(this.value.length & 0xFF);
			
			this.writeBytes(value);
		}
		
		public function writeMessageFromBytes(input:IDataInput):void
		{
			this.position = 0;
			this.type = input.readUnsignedByte();
			var length:int = (input.readUnsignedByte() << 8) + input.readUnsignedByte();
			
			input.readBytes(this, 1, length);
			serialize();
		}
		
		public function readMessageType():int
		{
			return 0;
		}
		
		public function readMessageValue():*
		{
			return value;
		}
		
		public function serialize():void
		{
			this.position = 0;
			this.type = this.readUnsignedByte();
			this.value = PoolMap.getInstanceByType( ByteArray );
			this.readBytes(value);
		}
		
		public function dispose():void
		{
			value.length = 0;
			PoolMap.disposeInstance(value);
		}
	}
}