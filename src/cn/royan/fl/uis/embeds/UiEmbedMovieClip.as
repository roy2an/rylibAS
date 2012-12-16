package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class UiEmbedMovieClip extends MovieClip implements IUiPlayBase
	{
		protected var eventMap:Dictionary;
		protected var timer:Timer;
		protected var bindToFrameRate:Boolean;
		protected var current:int;
		protected var toFrame:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		
		public function UiEmbedMovieClip(auto:Boolean = true, rate:int = 30)
		{
			super();
			
			bindToFrameRate = auto;
			eventMap = new Dictionary(true);
			
			if( !bindToFrameRate )
			{
				timer = PoolMap.getInstanceByType(Timer, 1000 / rate);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
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
		
		protected function timerHandler(evt:TimerEvent):void
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
		
		public function dispose():void
		{
			PoolMap.disposeInstance(timer);
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			if( timer && timer.hasEventListener(TimerEvent.TIMER) )
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
			
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