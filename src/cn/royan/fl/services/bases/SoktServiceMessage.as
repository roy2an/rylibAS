package cn.royan.fl.services.bases
{
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	public class SoktServiceMessage extends ByteArray implements IServiceMessageBase
	{
		public function SoktServiceMessage()
		{
			super();
		}
		
		public function writeMessageType(type:int):void
		{
		}
		
		public function writeMessageValue(value:*):void
		{
		}
		
		public function writeMessageFromBytes(input:IDataInput):void
		{
		}
		
		public function serialize():void
		{
		}
	}
}