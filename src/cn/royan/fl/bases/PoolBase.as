package cn.royan.fl.bases
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class PoolBase
	{
		public static var maxValue:uint = 10;
		
		private static var pools:Dictionary = new Dictionary();
		
		private static function getPool( type:Class ):Array
		{
			return type in pools ? pools[type] : pools[type] = new Array();
		}
		
		private static function createInstanceByType(type:Class, parameters:Array):*
		{
			switch( parameters.length )
			{
				case 0:
					return new type();
				case 1:
					return new type( parameters[0] );
				case 2:
					return new type( parameters[0], parameters[1] );
				case 3:
					return new type( parameters[0], parameters[1], parameters[2] );
				case 4:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3] );
				case 5:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4] );
				case 6:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] );
				case 7:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6] );
				case 8:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7] );
				case 9:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8] );
				case 10:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9] );
				default:
					return null;
			}
		}
		
		public static function getInstanceByType( type:Class, ...parameters ):*
		{
			if( parameters.length > 0 )
				return createInstanceByType( type, parameters );
			
			var pool:Array = getPool( type );
			if( pool.length > 0 )
			{
				return pool.pop();
			}
			else
			{
				return createInstanceByType( type, parameters );
			}
		}
		
		public static function disposeInstance( object:*, type:Class = null ):void
		{
			if( !type )
			{
				var typeName:String = getQualifiedClassName( object );
				type = getDefinitionByName( typeName ) as Class;
			}
			var pool:Array = getPool( type );
			if(pool.length > maxValue)
				pool.shift();
			
			pool.push( object );
		}
	}
}