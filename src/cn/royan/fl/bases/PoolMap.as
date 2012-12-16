package cn.royan.fl.bases
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class PoolMap
	{
		public static var maxValue:uint = 10;
		
		private static var __weakMap:WeakMap = WeakMap.getInstance();
		private static var pools:Dictionary = new Dictionary();
		
		private static function getPool( type:Class ):Array
		{
			return type in pools ? pools[type] : pools[type] = new Array();
		}
		
		private static function createInstanceByType(type:Class, parameters:Array):*
		{
//			SystemUtils.print("create:"+type);
			
			var waterDrop:WaterDrop = new WaterDrop(type, parameters);
			__weakMap.set(waterDrop.key, waterDrop.target);
			
			return waterDrop.target
		}
		
		public static function getInstanceByType( type:Class, ...parameters ):*
		{
			if( parameters.length == 1 && parameters[0] is Array )
				return createInstanceByType( type, parameters[0] );
			if( parameters.length > 0 )
				return createInstanceByType( type, parameters );
			
			var pool:Array = getPool( type );
			if( pool.length > 0 )
				return pool.pop();
			else
				return createInstanceByType( type, parameters );
		}
		
		public static function disposeInstance( object:*, type:Class = null ):void
		{
			if( !type )
			{
				var typeName:String = getQualifiedClassName( object );
				type = getDefinitionByName( typeName ) as Class;
			}
			
			var keys:Array = __weakMap.getKeys(object);
			var pool:Array;
			
			if( keys.length > 1 || keys.length == 0){
//				SystemUtils.print("dispose: "+type);
				
				pool = getPool( type );
				if(pool.length >= maxValue)
					pool.shift();
				
				pool.push( object );
			}else{
				var params:Array = String(keys[0]).split("|");
				if( params[params.length - 1] != "0" ){
//					SystemUtils.print("destroy: "+type);
					
					__weakMap.clear(keys[0]);
					object = null;
				}else{
//					SystemUtils.print("dispose: "+type);
					pool = getPool( type );
					if(pool.length >= maxValue)
						pool.shift();
					
					pool.push( object );
				}
			}
		}
	}
}

class WaterDrop
{
	public var target:*;
	public var type:Class;
	public var params:Array;
	public var key:String;
	public var autoKill:uint;
	
	public function WaterDrop(type:Class, parameters:Array)
	{
		this.type 		= type;
		this.params 	= parameters;
		this.autoKill 	= params.length;
		this.key 		= type+"|"+autoKill;
		this.target 	= createInstanceByType(type, params);
	}
	
	protected function createInstanceByType(type:Class, parameters:Array):*
	{
		switch( parameters.length )
		{
			case 0:
				return new type();
				break;
			case 1:
				return new type( parameters[0] );
				break;
			case 2:
				return new type( parameters[0], parameters[1] );
				break;
			case 3:
				return new type( parameters[0], parameters[1], parameters[2] );
				break;
			case 4:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3] );
				break;
			case 5:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4] );
				break;
			case 6:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] );
				break;
			case 7:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6] );
				break;
			case 8:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7] );
				break;
			case 9:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8] );
				break;
			case 10:
				return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9] );
				break;
			default:
				return null;
		}
	}
}