package cn.royan.fl.utils
{
	import flash.net.LocalConnection;

	public class DebugUtils
	{
		public static var isShow:Boolean;
		
		public static function print(...args):void
		{
			if(isShow)
				trace(args);
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