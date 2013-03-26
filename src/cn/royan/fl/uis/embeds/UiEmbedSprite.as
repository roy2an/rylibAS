package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class UiEmbedSprite extends Sprite implements IUiPlayBase
	{
		protected var evtListenerType:Array;
		protected var evtListenerDirectory:Array
		
		public function UiEmbedSprite()
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
		
		public function goTo(to:int):void
		{
			
		}
		
		public function jumpTo(to:int):void
		{
			
		}
		
		public function goFromTo(from:int, to:int):void
		{
			
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			removeAllEventListeners();
			
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void 
		{
			if ( evtListenerDirectory == null ) {
				evtListenerDirectory = [];
				evtListenerType = [];
			}
			var dir:Dictionary = new Dictionary();
			dir[ type ] = listener;
			evtListenerDirectory.push( dir );
			evtListenerType.push( type );
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void 
		{
			super.removeEventListener(type, listener, useCapture);
			if ( evtListenerDirectory != null ) {
				for ( var i:int = 0; i < evtListenerDirectory.length; i++ ) {
					var dir:Dictionary = evtListenerDirectory[i];
					if ( dir[ type ] == null ) {
						continue;
					}else {
						if ( dir[ type ] != listener ) {
							continue
						}else {
							evtListenerType.splice( i, 1 );
							evtListenerDirectory.splice( i, 1 );
							delete dir[ type ];
							dir = null;
							break;
						}
					}
				}
			}
		}
		
		public function removeAllEventListeners():void
		{
			if ( evtListenerType == null || evtListenerType.length == 0)
				return;
			for ( var i:int = 0; i < evtListenerType.length; i++)
			{
				var type:String = evtListenerType[i];
				var dic:Dictionary = evtListenerDirectory[i];
				var fun:Function = dic[ type ];
				removeEventListener( type, fun );
			}
		}
		
		public function removeAllChildren():void
		{
			while ( numChildren > 0 ) {
				removeChildAt( 0 );
			}
		}
		
		
		public function dispose():void
		{
			removeAllChildren();
			removeAllEventListeners();
		}
	}
}