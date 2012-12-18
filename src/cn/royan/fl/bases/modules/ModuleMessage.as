package cn.royan.fl.bases.modules
{
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.IDataInput;
	
	public class ModuleMessage implements IServiceMessageBase
	{
		public static const MODULE_INITED:String = 'module_inited';
		
		protected var type:int;
		protected var value:Object;
		
		public function ModuleMessage()
		{
		}
		
		public function writeMessageType(type:int):void
		{
			this.type = type;
		}
		
		public function writeMessageValue(value:*):void
		{
			this.value = value;
		}
		
		public function writeMessageFromBytes(input:IDataInput):void
		{
			throw new Error("no implement");
		}
		
		public function readMessageType():int
		{
			return type;
		}
		
		public function readMessageValue():*
		{
			return value;
		}
		
		public function serialize():void
		{
			throw new Error("no implements");
		}
		
		public function dispose():void
		{
			value = null;
		}
	}
}