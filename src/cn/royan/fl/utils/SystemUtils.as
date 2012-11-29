package cn.royan.fl.utils
{
	import cn.royan.fl.bases.PoolBase;
	
	import flash.net.LocalConnection;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.getDefinitionByName;

	public class SystemUtils
	{
		public static var showDebug:Boolean;
		
		private static var __loaderContext:LoaderContext;
		private static var __id:uint;
		
		public static function print(...args):void
		{
			if( showDebug ) trace(args);
		}
		
		public static function createObjectUID():uint
		{
			return __id++;
		}
		
		public static function readObject(object:Object, index:int = 0):void
		{
			for( var prop:String in object ){
				var str:String = "";
				var i:int = 0;
				for(i = 0; i < index; i++){
					str += " ";
				}
				str += "|+";
				SystemUtils.print('[Class SystemUtils]:'+ str +'Object['+prop+']:'+object[prop] );
				readObject(object[prop], index+1);
			}
		}
		
		public static function getLoaderContext():LoaderContext
		{
			if( __loaderContext == null )
				__loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				
			return __loaderContext;
		}
		
		public static function getInstanceByClassName(className:String, ...parameters):*
		{
			var InstanceClass:Class = getDefinitionByName(className) as Class;
			return PoolBase.getInstanceByType( InstanceClass, parameters );
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