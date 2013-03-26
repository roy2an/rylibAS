package cn.royan.fl.utils
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.bases.BindBase;

	public class BindUtils
	{
		public static function toProperty(objectA:BindBase, propertyA:String, objectB:Object, propertyB:String):void
		{
			var callback:Function = function(evt:DatasEvent):void
			{
				objectB[propertyA] = objectA[propertyB];
			}
			
			objectA.addEventListener(DatasEvent.DATA_CHANGE, callback );
		}
		
		public static function toFunction(objectA:BindBase, property:String, fun:Function, param:Array):void
		{
			var callback:Function = function(evt:DatasEvent):void
			{
				fun(param);
			}
				
			objectA.addEventListener(DatasEvent.DATA_CHANGE, callback );
		}
	}
}