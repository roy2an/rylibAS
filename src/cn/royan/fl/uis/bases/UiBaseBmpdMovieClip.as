package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class UiBaseBmpdMovieClip extends InteractiveUiBase implements IUiPlayBase
	{
		protected var bgTextures:Vector.<UninteractiveUiBase>;
		protected var timer:Timer;
		protected var current:int;
		protected var total:int;
		protected var toFrame:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		
		public function UiBaseBmpdMovieClip(texture:BitmapData, row:int = 1, column:int = 1, frames:int = 1, rate:int = 10)
		{
			super(texture);
			
			current = 1;
			total = frames;
			toFrame = 0;
			bgTextures = new Vector.<UninteractiveUiBase>(frames);
			loop = true;
			
			var frameWidth:int = bgTexture.width / row;
			var frameHeight:int = bgTexture.height / column;
			var i:int;
			var frameunit:UninteractiveUiBase;
			for(i = 0; i < frames; i++){
				var curRow:int = i / row;
				var curCol:int = i % column;
				var bmpd:BitmapData;
				bmpd = new BitmapData( frameWidth, frameHeight, true);
				bmpd.copyPixels( bgTexture, new Rectangle(curRow * frameWidth, curCol * frameHeight, frameWidth, frameHeight), new Point() );
				frameunit = new UninteractiveUiBase( bmpd );
				bgTextures[i] = frameunit;
			}
			
			weakMap.add("bgTextures", bgTextures);
			
			timer = new Timer(1000 / rate);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			weakMap.add("timer", timer);
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		override protected function addToStageHandler(evt:Event = null):void
		{
			super.addToStageHandler(evt);
			
			if(weakMap.getValue("bgTextures")[current-1])
				addChild(bgTextures[current-1]);
			
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
			
			if(weakMap.getValue("bgTextures")[current-1])
				addChild(bgTextures[current-1]);
			
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
		
		public function goTo(to:int):void
		{
			goFromTo(current, to);
		}
		
		public function goFromTo(from:int, to:int):void
		{
			SystemUtils.print("play from["+from+"] to ["+to+"]");
			loop = false;
			sequence = from <= to;
			current = from;
			toFrame = to;
			
			removeChildAt(0);
			
			if(weakMap.getValue("bgTextures")[current-1])
				addChild(bgTextures[current-1]);
			
			timer.start();
		}
		
		override public function dispose():void
		{
			if( weakMap.getValue("bgTexture") ){
				bgTexture.dispose();
				weakMap.remove("bgTexture");
			}
			
			var i:int = 0;
			var len:int = weakMap.getValue("bgTextures")?bgTextures.length:0;
			for( i; i < len; i++ ){
				if( bgTextures[i] )
					bgTextures[i].dispose();
				
				bgTextures[i] = null;
				delete bgTextures[i];
			}
			
			weakMap.remove("bgTextures");
			
			if( weakMap.getValue("timer") ){
				timer = null;
				weakMap.remove("timer");
			}
			
			bgTexture = null;
			bgTextures = null;
			bgColors = null;
			bgAlphas = null;
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			super.removeFromStageHandler(evt);
			
			if( weakMap.getValue("timer") && timer.hasEventListener(TimerEvent.TIMER) )
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
		}
	}
}