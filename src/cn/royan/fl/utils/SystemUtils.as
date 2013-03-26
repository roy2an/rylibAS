package cn.royan.fl.utils
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.uis.bases.UiBaseText;
	
	import flash.net.LocalConnection;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	public class SystemUtils
	{
		public static var showDebug:Boolean;
		public static var debugText:UiBaseText;
		public static var ukey:Array = ["A","B","C","D","E","F","G","H"];
		
		private static var __loaderContext:LoaderContext;
		
		public static function print(...args):void
		{
			if( showDebug ){
				if(debugText){
					debugText.appendText(getTimer()+"|"+args+"\n");
					debugText.setScroll(0, debugText.getMaxScroll()[1]);
				}
				else trace(getTimer() +"|"+ args);
			}
		}
		
		public static function replace(orgin:String, ...args):String
		{
			var i:int;
			for( i = 1; i <= args.length; i++ ){
				orgin = orgin.replace("{"+i+"}", args[i - 1]);
			}
			return orgin;
		}
		
		public static function createUniqueID():String
		{
			var uid:String = "";
			var time:uint = new Date().time;
			var timecut:int = time & 0xFFF;
			var i:int;
			var sum:String = "";
			for( i = 0; i < 12; i++ ){
				sum = (time & 7) + sum;
				time >>= 3;
			}
			for( i = 0; i < 12; i++ ){
				uid = uid + ukey[int(sum.substr(i,1))];
			}
			return uid + "-" + timecut;
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
			if( parameters.length )
				return PoolMap.getInstanceByType( InstanceClass, parameters );
			
			return PoolMap.getInstanceByType(InstanceClass);
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