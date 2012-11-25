package cn.royan.fl.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.IView;
	import cn.royan.fl.utils.DebugUtils;
	
	public class RoBitmapMovieClip extends Sprite implements IView
	{
		protected var weakMap:WeakMap;
		protected var frames:Vector.<BitmapData>;
		protected var timer:Timer;
		protected var current:int;
		protected var total:int;
		protected var toFrame:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		
		public function RoBitmapMovieClip(bitmapdata:BitmapData, row:int = 1, column:int = 1, frame:int = 1, rate:int = 10)
		{
			super();
			
			weakMap = new WeakMap();
			current = 1;
			total = frame;
			toFrame = 0;
			frames = new Vector.<BitmapData>(total);
			loop = true;
			
			var frameWidth:int = bitmapdata.width / row;
			var frameHeight:int = bitmapdata.height / column;
			var i:int;
			for(i = 0; i < frame; i++){
				var curRow:int = i / row;
				var curCol:int = i % column;
				var frameUnit:BitmapData = new BitmapData(frameWidth, frameHeight);
				frameUnit.copyPixels(bitmapdata, new Rectangle(frameWidth * curRow, frameHeight * curCol, frameWidth, frameHeight), new Point());
				weakMap.add("frame_"+i, frameUnit);
				frames[i] = frameUnit;
			}
			
			timer = new Timer(1000 / rate);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			weakMap.add("timer", timer);
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		protected function addToStageHandler(evt:Event = null):void
		{
			if( hasEventListener(Event.ADDED_TO_STAGE) )
				removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			
			addChild(new Bitmap(frames[current-1]));
			
			timer.start();
		}
		
		protected function timerHandler(evt:TimerEvent):void
		{
			removeChildAt(0);
			if( sequence )
			{
				current++;
				if( current > total )
				{
					if( loop ) current = 1;
					else timer.stop();
				}
			}
			else
			{
				current--;
				if( current < 1 )
				{
					if( loop ) current = total;
					else timer.stop();
				}
			}
			
			addChild(new Bitmap(frames[current-1]));
			if( current == toFrame && !loop )
				timer.stop();
		}
		
		public function getIn():void
		{
			goFromTo(1, total);
		}
		
		public function getOut():void
		{
			goFromTo(total, 1);
		}
		
		public function goTo(frame:int):void
		{
			goFromTo(current, frame);
		}
		
		public function goFromTo(from:int, to:int):void
		{
			DebugUtils.print("play from["+from+"] to ["+to+"]");
			loop = false;
			sequence = from <= to;
			current = from;
			toFrame = to;
			
			removeChildAt(0);
			addChild(new Bitmap(frames[current-1]));
			
			timer.start();
		}
		
		public function dispose():void
		{
			var i:int;
			for(i = 0; i < frames.length; i++)
			{
				if( frames[i] ) frames[i].dispose();
			}
			frames = null;
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
	}
}