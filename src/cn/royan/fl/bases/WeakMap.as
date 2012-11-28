package cn.royan.fl.bases
{
	import flash.utils.Dictionary;

	public class WeakMap
	{
		protected var map:Dictionary;
		protected var keys:Array;
		
		public function WeakMap()
		{
			map = new Dictionary(true);
			keys = [];
			
		}
		
		/**
		 * key与value 多对一
		 * 
		 */
		public function add(key:*, value:*):void
		{
			if( containKey(key) )
			{
				for each( var i:* in map )
				{
					i.splice( i.indexOf(key), 1)
				}
			}
			if( containValue(value) )
			{
				map[value].push(key);
			}
			else
			{
				map[value] = [key];
			}
		}
		
		public function getValue(key:*):*
		{
			for( var i:* in map )
			{
				var keysets:Array = map[i];
				for each(var k:* in keysets)
				{
					if(k == key)
					{
						return i;
					}
				}
			}
			return null;
		}
		
		public function remove(key:*):void
		{
			var value:* = getValue(key);
			var keysets:Array = map[value];
			if( keysets )
			{
				keysets.splice( keysets.indexOf(key), 1 );
				if( keysets.length <= 0 )
				{
					delete map[value];
				}
				
				keys.splice( keys.indexOf(key), 1 );
			}
		}
		
		public function containKey(key:*):Boolean
		{
			for( var i:* in keys )
			{
				if( i == key)
					return true;
			}
			return false;
		}
		
		public function containValue(value:*):Boolean
		{
			for( var i:* in map )
			{
				if( i == value )
					return true;
			}
			return false;
		}
	}
}