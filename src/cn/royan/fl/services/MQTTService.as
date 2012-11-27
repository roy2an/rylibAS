package cn.royan.fl.services
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import cn.royan.fl.bases.MqttByteArray;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.IService;
	
	public class MQTTService extends EventDispatcher implements IService
	{
		public function MQTTService(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function sendRequest(url:String='', extra:*=null):void
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
			return false;
		}
	}
}