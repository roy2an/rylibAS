package cn.royan.fl.bases.modules
{
	import flash.utils.IDataInput;
	
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	public class ModuleMessage implements IServiceMessageBase
	{
		public static const MODULE_INITED:String = 'module_inited';
		
		public function ModuleMessage()
		{
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