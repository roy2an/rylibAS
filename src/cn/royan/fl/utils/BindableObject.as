package cn.royan.fl.utils
{
	import flash.events.EventDispatcher;
	
	import cn.royan.fl.events.DatasEvent;
	
	public class BindableObject extends EventDispatcher
	{
		public function BindableObject()
		{
			super();
		}
		
		protected function checkValue(oldValue:*, newValue:*):void
		{
			if( oldValue !== newValue )
			{
				dispatchEvent(new DatasEvent(DatasEvent.DATA_CHANGE));
			}
		}
	}
}