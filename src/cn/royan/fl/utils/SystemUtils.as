package cn.royan.fl.utils
{
	import flash.net.LocalConnection;
	import flash.system.System;
	import flash.utils.getDefinitionByName;

	public class SystemUtils
	{
		public static var isShow:Boolean;
		
		public static function print(...args):void
		{
			if(isShow)
				trace(args);
		}
		
		public static function getInstanceByClassName(className:String, args:Array):*
		{
			var InstanceClass:Class = getDefinitionByName(className) as Class;
			return new InstanceClass(args);
		}
		
		public static function copyToClipboard(value:String):void
		{
			System.setClipboard(value);
		}
		
		public static function gc():void
		{
			try
			{
				new LocalConnection().connect("use_for_gc");
				new LocalConnection().connect("use_for_gc");
			}catch(e:Error){
				
			}
		}
	}
}