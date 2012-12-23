package cn.royan.fl.bases
{
	import cn.royan.fl.interfaces.IDisposeBase;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class TimerBase implements IDisposeBase
	{
		public static const TIMERBASE_DELAY:int = 10;
		
		private static var timerlists:Vector.<TimerBase> = new Vector.<TimerBase>();
		private static var timer:Timer = new Timer(TIMERBASE_DELAY);
		
		protected var current:int;
		protected var last:int;
		protected var delay:int;
		protected var callback:Function;
		protected var isStart:Boolean;
		
		public function TimerBase(time:uint, deal:Function)
		{
			delay = time;
			callback = deal;
			timerlists.push(this);
		}
		
		public function getDelay():uint
		{
			return delay;
		}
		
		public function getCallback():Function
		{
			return callback;
		}
		
		public function getIsRunning():Boolean
		{
			return isStart;
		}
		
		public function needRender():Boolean
		{
			if( !isStart ) return false;
			current -= (getTimer() - last);
			last = getTimer();
			var isInit:Boolean = current < TIMERBASE_DELAY;
			if( isInit ) current = delay;
			return isStart && isInit;
		}
		
		public function start():void
		{
			isStart = true;
			last = getTimer();
			current = delay;
			
			if( !timer.running ){
				if( !timer.hasEventListener(TimerEvent.TIMER) ) timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
			}
		}
		
		public function stop():void
		{
			isStart = false;
		}
		
		public function dispose():void
		{
			timerlists.splice( timerlists.indexOf(this), 1 );
			if( timerlists.length <= 0 ){
				timer.stop();
			}
		}
		
		private static function timerHandler(evt:TimerEvent):void
		{
			for each( var time:TimerBase in timerlists ){
				if( time.needRender() ){
					time.getCallback()();
				}
			}
		}
	}
}