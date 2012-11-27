package cn.royan.fl.bases
{
	import flash.events.EventDispatcher;
	
	import cn.royan.fl.events.DatasEvent;
	
	public class BindBase extends EventDispatcher
	{
		public function BindBase()
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