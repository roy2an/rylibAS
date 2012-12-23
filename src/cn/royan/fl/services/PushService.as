package cn.royan.fl.services
{
	import cn.royan.fl.bases.DispacherBase;
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.services.bases.PushServiceHelper;
	import cn.royan.fl.utils.BytesUtils;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class PushService extends DispacherBase implements IServiceBase
	{
		protected var servicing:Boolean;
		protected var urlstream:URLStream;
		protected var urlrequest:URLRequest;
		protected var urlvariable:URLVariables;
		protected var callbacks:Object;
		protected var serviceData:ByteArray;
		
		public function PushService(param:*=null)
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
		}
		
		public function sendRequest(url:String='', extra:*=null):void
		{
			urlrequest = new URLRequest(url);
			urlrequest.data = urlvariable;
			urlrequest.method = URLRequestMethod.POST;
			urlrequest.contentType = "multipart/form-data; boundary=" + PushServiceHelper.getBoundary();
			urlrequest.data = PushServiceHelper.getPostData( 'image.jpg', extra as ByteArray, "filedata", urlvariable );
			urlrequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
		}
		
		public function setCallbacks(value:Object):void
		{
			callbacks = value;
		}
		
		public function connect():void
		{
			urlstream = PoolMap.getInstanceByType(URLStream);
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
			
			PoolMap.disposeInstance(urlstream);
			
			serviceData.length = 0;
			serviceData = null;
			urlrequest = null;
			urlvariable = null;
			callbacks = null;
			removeAllEventListeners();
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
			
			switch( BytesUtils.getType(serviceData) ){
				case "SWF":
					var loader:Loader = PoolMap.getInstanceByType(Loader);
					loader.loadBytes(serviceData, SystemUtils.getLoaderContext());
					if( callbacks && callbacks['done'] ) callbacks['done'](loader);
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE, loader));
					PoolMap.disposeInstance(loader);
					break;
//				case "XML":
//					break;
//				case "PNG":
//					break;
//				case "JPEG":
//					break;
//				case "GIF":
//					break;
//				case "BMP":
//					break;
//				case "FLV":
//					break;
//				case "MP3":
//					break;
				default:
					if( callbacks && callbacks['done'] ) callbacks['done'](data);
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE, data));
			}
		}
		
		protected function onProgress(evt:ProgressEvent):void
		{
			if( callbacks && callbacks['doing'] ) callbacks['doing'](evt.bytesLoaded, evt.bytesTotal);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_DOING, {loaded:evt.bytesLoaded, total:evt.bytesTotal}));
		}
		
		protected function onError(evt:IOErrorEvent):void
		{
			SystemUtils.print("[Class TakeService]:onError:"+evt.type);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			SystemUtils.print("[Class TakeService]:onSecurityError:"+evt.type);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
			close();
		}
	}
}