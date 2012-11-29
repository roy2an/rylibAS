package cn.royan.fl.bases.mvcs
{
	import cn.royan.fl.interfaces.IDisposeBase;
	import cn.royan.fl.interfaces.services.IServiceMessageBase;
	
	import flash.utils.Dictionary;
	
	public class ModuleMap implements IDisposeBase
	{
		private static var __map:Dictionary = new Dictionary(true);
		
		protected var moduleKey:String;
		protected var moduleDeal:Function;
		
		public function ModuleMap(key:String, deal:Function)
		{
			if( containKey(key) )
				throw new Error("key existed");
			
			moduleKey = key;
			moduleDeal = deal;
			
			__map[key] = this;
			
			sendModuleMessage(new ModuleMessage());
		}
		
		public function sendModuleMessage(message:IServiceMessageBase, toKey:String=''):void
		{
			for each( var moduleMap:ModuleMap in __map )
			{
				var callback:Function = moduleMap.getDeal();
				if( toKey )
					callback(message, moduleKey);
				else if( moduleMap.getModuleKey() == toKey )
					callback(message, moduleKey);
			}
		}
		
		public function getModuleKey():String
		{
			return moduleKey;
		}
		
		public function getDeal():Function
		{
			return moduleDeal;
		}
		
		public function dispose():void
		{
			__map[moduleKey] = null;
			delete __map[moduleKey];
		}
		
		protected function containKey(value:String):Boolean
		{
			for( var key:String in __map )
			{
				if( key == value )
					return true;
			}
			return false;
		}
	}
}