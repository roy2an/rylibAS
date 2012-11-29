package cn.royan.fl.bases
{
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.utils.Dictionary;
	
	public class WeakMap
	{
		private static var __instance:WeakMap;
		
		private var map:Dictionary;
		private var keys:Array;
		private var length:int = 0;
		
		public static function getInstance():WeakMap
		{
			if( __instance == null )
				__instance = new WeakMap(new WeakMapType());
			return __instance;
		}
		
		public function WeakMap(type:WeakMapType)
		{
			map = new Dictionary(true);
			keys = [];
		}
		
		public function getLength():int
		{
			return length;
		}
		
		public function getAllKeys():Array
		{
			return keys;
		}
		
		public function getValues():Array
		{
			var result:Array = [];
			for (var i:* in map)
			{
				result.push(i);
			}
			return result;
		}
		
		public function contentValue(value:*):Boolean
		{
			for (var i:* in map)
			{
				if(i == value)
				{
					return true;
				}
			}
			return false;
		}
		
		public function contentKey(key:String):Boolean
		{
			for each( var i:* in keys)
			{
				if( i == key )
				{
					return true;
				}
			}
			return false;
			
		}
		
		public function set(key:String,value:*):void
		{
			//如果键存在，删除键
			if(contentKey(key))
			{
				for each(var i:Array in map)
				{
					i.splice(i.indexOf(key),1);
				}
				length--;
			}
			//如果值存在
			if(contentValue(value))
			{
				//增加指向值的键
				map[value].push(key);
			}
			else
			{
				//指向值的键
				map[value]=[key];
			}
			length++
			if(keys.indexOf(key)<0)
			{
				keys.push(key);
			}
		}
		
		public function getValue(key:String):*
		{
			// i 为值
			for (var item:* in map)
			{
				// 指向 i 的键
				var key_arr:Array = map[item];
				for each( var k:* in key_arr )
				{
					if( k == key )
					{
						return item;
					}
				}
			}
			return null;
		}
		
		public function getKeys(value:*):Array
		{
			return map[value];
		}
		
		public function clear(key:String):void
		{
			var value:* = getValue(key);
			var key_arr:Array = map[value];
			if( key_arr )
			{
				key_arr.splice(key_arr.indexOf(key),1);
				
				if( key_arr.length <= 0 )
				{
					delete map[value];
				}
				
				length--;
				
				keys.splice(keys.indexOf(key),1);
			}
		}
		
	}
}

class WeakMapType{}