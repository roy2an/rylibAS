package cn.royan.fl.bases
{
	import cn.royan.fl.interfaces.IDispose;
	import cn.royan.fl.interfaces.IMessage;
	
	import flash.utils.Dictionary;
	
	import mx.modules.Module;

	public class ModuleMap implements IDispose
	{
		private static var _map:Dictionary = new Dictionary(true);
		private static var _instance:ModuleMap;
		
		protected var moduleKey:String;
		protected var moduleDeal:Function;
		
		public function ModuleMap(key:String, deal:Function)
		{
			if( containKey(key) )
				throw new Error("key existed");
			
			moduleKey = key;
			moduleDeal = deal;
			
			_map[key] = this;
		}
		
		public function sendMessage(message:IMessage, toKey:String=''):void
		{
			for each( var moduleMap:ModuleMap in _map )
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
			_map[moduleKey] = null;
			delete _map[moduleKey];
		}
		
		protected function containKey(value:String):Boolean
		{
			for( var key:String in _map )
			{
				if( key == value )
					return true;
			}
			return false;
		}
	}
}