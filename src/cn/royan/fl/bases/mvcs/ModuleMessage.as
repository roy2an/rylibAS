package cn.royan.fl.bases.mvcs
{
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
		
		public function writeMessageValue(type:*):void
		{
		}
	}
}