package cn.royan.fl.services
{
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.utils.SystemUtils;
	
	public class PushService extends EventDispatcher implements IServiceBase
	{
		protected var servicing:Boolean;
		protected var urlloader:URLLoader;
		protected var urlrequest:URLRequest;
		protected var urlvariable:URLVariables;
		
		public function PushService(param:*=null)
		{
			if( param )
				if( param is URLVariables ){
					urlvariable = param;
				}else if( param is String ){
					urlvariable = new URLVariables( param );
				}else{
					throw new Error("param must be URLVariables or String");
				}
			else
				urlvariable = new URLVariables();
		}
		
		public function sendRequest(url:String='', extra:*=null):void
		{
			urlrequest = new URLRequest(url);
			urlrequest.data = urlvariable;
			urlrequest.method = extra == URLRequestMethod.POST?extra:URLRequestMethod.GET;
		}
		
		public function setCallbacks(value:Object):void
		{
			
		}
		
		public function connect():void
		{
			
		}
		
		public function close():void
		{
			
		}
		
		public function dispose():void
		{
			
		}
		
		public function get data():*
		{
			return null;
		}
		
		public function get isServicing():Boolean
		{
			return servicing;
		}
	}
}