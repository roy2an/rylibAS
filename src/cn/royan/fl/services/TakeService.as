package cn.royan.fl.services
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.IService;
	import cn.royan.fl.utils.DebugUtils;
	
	public class TakeService extends EventDispatcher implements IService
	{
		protected var urlstream:URLStream;
		protected var urlrequest:URLRequest;
		protected var urlvariable:URLVariables;
		protected var serviceData:ByteArray;
		
		public function TakeService(param:*=null)
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
		
		public function connect():void
		{
			close();
			
			if( serviceData ) serviceData.clear();
			else serviceData = new ByteArray();
			
			urlstream = new URLStream();
			urlstream.addEventListener(Event.COMPLETE, onComplete);
			urlstream.addEventListener(ProgressEvent.PROGRESS, onProgress);
			urlstream.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlstream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			urlstream.load(urlrequest);
		}
		
		public function close():void
		{
			if( isServicing ){
				urlstream.close();
			}
		}
		
		public function dispose():void
		{
			urlstream.removeEventListener(Event.COMPLETE, onComplete);
			urlstream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			urlstream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			urlstream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			urlstream = null;
			urlrequest = null;
			urlvariable = null;
			serviceData.clear();
		}
		
		public function get data():*
		{
			return serviceData;
		}
		
		public function get isServicing():Boolean
		{
			return urlstream && urlstream.connected;
		}
		
		protected function onComplete(evt:Event):void
		{
			DebugUtils.print("[Class TakeService]:onComplete");
			
			urlstream.readBytes(serviceData, 0, urlstream.bytesAvailable);
			
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE, data));
		}
		
		protected function onProgress(evt:ProgressEvent):void
		{
			DebugUtils.print("[Class TakeService]:onProgress:"+evt.bytesLoaded+"/"+evt.bytesTotal);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DOING, {loaded:evt.bytesLoaded, total:evt.bytesTotal}));
		}
		
		protected function onError(evt:IOErrorEvent):void
		{
			DebugUtils.print("[Class TakeService]:onError:"+evt.type);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			DebugUtils.print("[Class TakeService]:onSecurityError:"+evt.type);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
	}
}