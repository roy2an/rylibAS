package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolBase;
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
			var rectangle:Rectangle = PoolBase.getInstanceByType(Rectangle);
			rectangle.width = frameWidth;
				rectangle.height = frameHeight;
			var point:Point = PoolBase.getInstanceByType(Point);
			for(i = 0; i < frames; i++){
				var curRow:int = i / row;
				var curCol:int = i % column;
				var bmpd:BitmapData;
				
				rectangle.x = curRow * frameWidth;
				rectangle.y = curCol * frameHeight
				
				bmpd = PoolBase.getInstanceByType(BitmapData, frameWidth, frameHeight, true);
				bmpd.copyPixels( bgTexture, rectangle, point );
				frameunit = PoolBase.getInstanceByType(UninteractiveUiBase);
				frameunit.setTexture(bmpd);
				bgTextures[i] = frameunit;
			}
			
			PoolBase.disposeInstance(rectangle);
			PoolBase.disposeInstance(point);
			
			__weakMap.set("bgTextures" + uid, bgTextures);
			
			timer = PoolBase.getInstanceByType(Timer, 1000 / rate);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			__weakMap.set("timer" + uid, timer);
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		override protected function addToStageHandler(evt:Event = null):void
		{
			super.addToStageHandler(evt);
			
			if(__weakMap.getValue("bgTextures" + uid)[current-1])
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
			
			if(__weakMap.getValue("bgTextures" + uid)[current-1])
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
			
			if(__weakMap.getValue("bgTextures" + uid)[current-1])
				addChild(bgTextures[current-1]);
			
			timer.start();
		}
		
		override public function dispose():void
		{
			if( __weakMap.getValue("bgTexture") + uid ){
				bgTexture.dispose();
				PoolBase.disposeInstance(bgTexture);
				__weakMap.clear("bgTexture" + uid);
			}
			
			var i:int = 0;
			var len:int = __weakMap.getValue("bgTextures" + uid)?bgTextures.length:0;
			for( i; i < len; i++ ){
				if( bgTextures[i] ){
					bgTextures[i].dispose();
					PoolBase.disposeInstance(bgTextures[i]);
				}
				
				delete bgTextures[i];
			}
			
			__weakMap.clear("bgTextures" + uid);
			
			if( __weakMap.getValue("timer" + uid) ){
				PoolBase.disposeInstance(timer);
				__weakMap.clear("timer" + uid);
			}
			
			bgTextures = null;
			bgColors = null;
			bgAlphas = null;
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			super.removeFromStageHandler(evt);
			
			if( __weakMap.getValue("timer" + uid) && timer.hasEventListener(TimerEvent.TIMER) )
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
		}
	}
}