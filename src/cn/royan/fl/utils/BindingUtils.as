package cn.royan.fl.utils
{
	import cn.royan.fl.events.DatasEvent;

	public class BindingUtils
	{
		public static function toProperty(objectA:BindableObject, property:String, objectB:Object, property:String):void
		{
			var callback:Function = function(evt:DatasEvent):void
			{
				objectB[property] = objectA[property];
			}
			
			objectA.addEventListener(DatasEvent.DATA_CHANGE, callback );
		}
		
		public static function toFunction(objectA:BindableObject, property:String, fun:Function, param:Array):void
		{
			var callback:Function = function(evt:DatasEvent):void
			{
				fun(param);
			}
				
			objectA.addEventListener(DatasEvent.DATA_CHANGE, callback );
		}
	}
}