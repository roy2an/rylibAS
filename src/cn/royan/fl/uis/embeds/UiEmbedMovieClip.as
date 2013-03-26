package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.TimerBase;
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	public class UiEmbedMovieClip extends MovieClip implements IUiPlayBase
	{
		protected var timer:TimerBase;
		protected var bindToFrameRate:Boolean;
		protected var current:int;
		protected var toFrame:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		
		protected var evtListenerType:Array;
		protected var evtListenerDirectory:Array
		
		public function UiEmbedMovieClip(auto:Boolean = true, rate:int = 30)
		{
			super();
			
			bindToFrameRate = auto;
			
			if( !bindToFrameRate )
			{
				timer = PoolMap.getInstanceByType(TimerBase, 1000 / rate, timerHandler);
			}else{
				addEventListener(Event.ENTER_FRAME, enterframeHandler);
			}
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		protected function addToStageHandler(evt:Event = null):void
		{
			if( hasEventListener(Event.ADDED_TO_STAGE) )
				removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
		
		protected function timerHandler():void
		{
			if( sequence )
			{
				current++;
				if( current > totalFrames ){
					if( loop ) current = 1;
					else timer.stop();
				}
			}
			else
			{
				current--;
				if( current < 1 ){
					if( loop ) current = totalFrames;
					else timer.stop();
				}
			}
			
			gotoAndStop(current);
		}
		
		protected function enterframeHandler(evt:Event):void
		{
			if( currentFrame == toFrame )
				removeEventListener(Event.ENTER_FRAME, enterframeHandler);
			
			if( sequence )
			{
				if( currentFrame >= totalFrames )
				{
					if( loop )
						gotoAndStop(1);
				}
				else 
					nextFrame();
			}
			else
			{
				if( currentFrame <= 1 )
				{
					if( loop )
						gotoAndStop( totalFrames );
				}
				else
					prevFrame();
			}
		}
		
		public function getIn():void
		{
			goFromTo(1, totalFrames);
		}
		
		public function getOut():void
		{
			goFromTo(totalFrames, 1);
		}
		
		public function goTo(to:int):void
		{
			goFromTo(currentFrame, to);
		}
		
		public function jumpTo(to:int):void
		{
			
		}
		
		public function goFromTo(from:int, to:int):void
		{
			SystemUtils.print("play from["+from+"] to ["+to+"]");
			loop = false;
			sequence = from <= to;
			toFrame = to;
			
			gotoAndStop(from);
			
			if( bindToFrameRate )
			{
				timer.start();
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, enterframeHandler);
			}
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			if( timer ) timer.stop();
			
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
			if(timer) {
				timer.stop();
				PoolMap.disposeInstance(timer);
			}
			
			removeAllChildren();
			removeAllEventListeners();
		}
	}
}