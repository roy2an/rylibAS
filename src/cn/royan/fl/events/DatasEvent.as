package cn.royan.fl.events
{
	import flash.events.Event;
	
	public class DatasEvent extends Event
	{
		static public const DATA_CHANGE:String 	= "data_change";
		static public const DATA_DOING:String	= "data_doing";
		static public const DATA_DONE:String	= "data_done";
		static public const DATA_CREATE:String	= "data_create";
		static public const DATA_DESTROY:String	= "data_destroy";
		static public const DATA_ERROR:String	= "data_error";
		
		protected var _params:Object;
		public function DatasEvent(type:String, params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_params = params;
			super(type, bubbles, cancelable);
		}
		
		public function get params():Object
		{
			return _params;
		}
		
		override public function clone():Event
		{
			return new DatasEvent(type, params, bubbles, cancelable);
		}
	}
}