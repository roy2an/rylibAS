package cn.royan.fl.services
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class SoktService extends EventDispatcher implements IServiceBase
	{
		protected var callbacks:Object;
		
		protected var host:String;
		protected var port:int;
		
		protected var socket:Socket;
		protected var packet:ByteArray;
		
		public function SoktService()
		{
		}
		
		public function sendRequest(url:String="", extra:*=null):void
		{
			if( isServicing ){
				socket.writeBytes( extra as ByteArray );
				socket.flush();
			}else{
				if( url == "" || extra == null ) throw new Error("host and port must be filled in");
				host = url;
				port = extra as int;
			}
		}
		
		/**
		 * {create:Function,doing:Function,error:Function,destory:Function}
		 * 
		 */
		public function setCallbacks(value:Object):void
		{
			callbacks = value;
		}
		
		public function connect():void
		{
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onProgress);
			socket.connect(host, port);
		}
		
		public function close():void
		{
			socket.close();
		}
		
		public function dispose():void
		{
			if( isServicing ) socket.close();
			
			socket.removeEventListener(Event.CONNECT, onConnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onProgress);
			socket.removeEventListener(Event.CLOSE, onClose);
			socket = null;
			callbacks = null;
		}
		
		public function get data():*
		{
			return packet;
		}
		
		public function get isServicing():Boolean
		{
			return socket.connected;
		}
		
		protected function onConnect(evt:Event):void
		{
			SystemUtils.print("[Class SoktService]:onConnect");
			if( callbacks && callbacks['create'] ) callbacks['create']();
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_CREATE));
		}
		
		protected function onClose(evt:Event):void
		{
			SystemUtils.print("[Class SoktService]:onClose");
			if( callbacks && callbacks['destory'] ) callbacks['destory']();
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_DESTROY));
		}
		
		protected function onIOError(evt:IOErrorEvent):void
		{
			SystemUtils.print("[Class SoktService]:onIOError:"+evt);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			SystemUtils.print("[Class SoktService]:onSecurityError:"+evt);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
		}
		
		protected function onProgress(evt:ProgressEvent):void
		{
			SystemUtils.print("[Class SoktService]:onProgress");
			packet = PoolMap.getInstanceByType( ByteArray );
			
			socket.readBytes(packet);
			if( callbacks && callbacks['doing'] ) callbacks['doing']( packet );
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_DOING, packet));
			PoolMap.disposeInstance(packet);
		}
	}
}