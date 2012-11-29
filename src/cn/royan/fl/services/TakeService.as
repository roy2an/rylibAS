package cn.royan.fl.services
{
	import cn.royan.fl.bases.PoolBase;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class TakeService extends EventDispatcher implements IServiceBase
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
					urlvariable = new URLVariables();
					for( var key:String in param ){
						urlvariable[key] = param[key];
					}
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
			
			urlstream = PoolBase.getInstanceByType(URLStream);
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
			
			PoolBase.disposeInstance(urlstream);
			
			urlrequest = null;
			urlvariable = null;
			serviceData.length = 0;
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
			SystemUtils.print("[Class TakeService]:onComplete");
			
			urlstream.readBytes(serviceData, 0, urlstream.bytesAvailable);
			
			var format:String = String.fromCharCode(serviceData.readByte()) + 
								String.fromCharCode(serviceData.readByte()) + 
								String.fromCharCode(serviceData.readByte());
			
			serviceData.position = 0;
			
			switch( format ){
				case "CWS":
				case "FWS":
					var loader:Loader = PoolBase.getInstanceByType(Loader);
					loader.loadBytes(serviceData, SystemUtils.getLoaderContext());
					dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE, loader));
					
					PoolBase.disposeInstance(loader);
					return;
					break;
			}
			
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE, data));
		}
		
		protected function onProgress(evt:ProgressEvent):void
		{
			SystemUtils.print("[Class TakeService]:onProgress:"+evt.bytesLoaded+"/"+evt.bytesTotal);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DOING, {loaded:evt.bytesLoaded, total:evt.bytesTotal}));
		}
		
		protected function onError(evt:IOErrorEvent):void
		{
			SystemUtils.print("[Class TakeService]:onError:"+evt.type);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			SystemUtils.print("[Class TakeService]:onSecurityError:"+evt.type);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
	}
}