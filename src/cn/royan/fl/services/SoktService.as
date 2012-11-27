package cn.royan.fl.services
{
	import flash.events.EventDispatcher;
	
	import cn.royan.fl.interfaces.IService;
	
	public class SoktService extends EventDispatcher implements IService
	{
		protected var servicing:Boolean;
		
		public function SoktService()
		{
			super();
		}
		
		public function sendRequest(url:String="", extra:*=null):void
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