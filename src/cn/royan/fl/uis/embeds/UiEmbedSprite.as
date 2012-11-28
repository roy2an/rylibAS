package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class UiEmbedSprite extends Sprite implements IUiPlayBase
	{
		protected var eventMap:Dictionary;
		
		public function UiEmbedSprite()
		{
			super();
			
			eventMap = new Dictionary(true);
			
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
		
		public function goTo(to:int):void
		{
			
		}
		
		public function goFromTo(from:int, to:int):void
		{
			
		}
		
		public function dispose():void
		{
			
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
//			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			
			for( var type:String in eventMap )
			{
				removeEventListener( type, eventMap[type] );
				eventMap[type] = null;
				delete eventMap[type];
			}
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			eventMap[type] = listener;
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventMap[type] = null;
			delete eventMap[type];
			
			super.removeEventListener(type, listener, useCapture );
		}
	}
}