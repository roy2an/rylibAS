package cn.royan.fl.bases
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class TimerBase
	{
		private static var timerlists:Vector.<TimerBase> = new Vector.<TimerBase>();
		private static var timer:Timer = new Timer(10);
		
		public var current:uint;
		
		protected var delay:uint;
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
		
		public function start():void
		{
			isStart = true;
			current = getTimer();
			
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
				if( time.getIsRunning() ){
					if( getTimer() - time.current >= time.getDelay() ){
						time.current = getTimer();
						time.getCallback()();
					}
				}
			}
		}
	}
}