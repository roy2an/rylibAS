package cn.royan.fl.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cn.royan.fl.interfaces.IView;
	
	public class RoSprite extends Sprite implements IView
	{
		public function RoSprite()
		{
			super();
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		protected function addToStageHandler(evt:Event = null):void
		{
			if( hasEventListener(Event.ADDED_TO_STAGE) )
				removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
		
		public function getIn():void
		{
		}
		
		public function getOut():void
		{
		}
		
		public function dispose():void
		{
			
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
	}
}