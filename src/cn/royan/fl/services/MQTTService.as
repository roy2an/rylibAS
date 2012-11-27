package cn.royan.fl.services
{
	import cn.royan.fl.interfaces.IService;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
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