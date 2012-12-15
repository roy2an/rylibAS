package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.TimerBase;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiPlayBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class UiBaseBmpdMovieClip extends InteractiveUiBase implements IUiPlayBase
	{
		protected var bgTextures:Vector.<UninteractiveUiBase>;
		protected var timer:TimerBase;
		protected var current:int;
		protected var total:int;
		protected var toFrame:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		protected var autoPlay:Boolean;
		
		public function UiBaseBmpdMovieClip(texture:BitmapData, row:int = 1, column:int = 1, frames:int = 1, rate:int = 10, auto:Boolean = true)
		{
			super(texture);
			
			current = 1;
			total = frames;
			toFrame = 0;
			bgTextures = new Vector.<UninteractiveUiBase>(frames);
			loop = true;
			autoPlay = auto;
			sequence = true;
			
			var frameWidth:int = bgTexture.width / row;
			var frameHeight:int = bgTexture.height / column;
			
			setSize(frameWidth, frameHeight);
			
			var i:int;
			var frameunit:UninteractiveUiBase;
			var rectangle:Rectangle = PoolMap.getInstanceByType(Rectangle);
				rectangle.width = frameWidth;
				rectangle.height = frameHeight;
			var point:Point = PoolMap.getInstanceByType(Point);
			for(i = 0; i < frames; i++){
				var curRow:int = i % row;
				var curCol:int = i / row;
				var bmpd:BitmapData;
				
				rectangle.x = curRow * frameWidth;
				rectangle.y = curCol * frameHeight
				
				bmpd = PoolMap.getInstanceByType(BitmapData, frameWidth, frameHeight, true);
				bmpd.copyPixels( bgTexture, rectangle, point );
				frameunit = PoolMap.getInstanceByType(UninteractiveUiBase);
				frameunit.setTexture(bmpd);
				
				bgTextures[i] = frameunit;
			}
			
			PoolMap.disposeInstance(rectangle);
			PoolMap.disposeInstance(point);
			
			timer = PoolMap.getInstanceByType(TimerBase, 1000 / rate, timerHandler);
			
			if( bgTextures[current-1] )
				addChild(bgTextures[current-1]);
		}
		
		override protected function addToStageHandler(evt:Event = null):void
		{
			super.addToStageHandler(evt);
			
			if( autoPlay ) timer.start();
		}
		
		override public function draw():void
		{
			
		}
		
		protected function timerHandler():void
		{
			while(numChildren){
				removeChildAt(0);
			}
			
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
			
			if( bgTextures[current-1] )
				addChild(bgTextures[current-1]);
			
			if( current == toFrame && !loop ){
				if( callbacks && callbacks['done'] ) callbacks['done']();
				else dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE));
				timer.stop();
			}
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
		
		public function jumpTo(to:int):void
		{
			loop = false;
			if( getChildAt(0) ) removeChildAt(0);
			
			current = to;
			
			if(bgTextures[current-1])
				addChild(bgTextures[current-1]);
		}
		
		public function goFromTo(from:int, to:int):void
		{
			SystemUtils.print("play from["+from+"] to ["+to+"]");
			if( from == to ) return;
			
			loop = false;
			sequence = from <= to;
			current = from;
			toFrame = to;
			
			if( getChildAt(0) ) removeChildAt(0);
			
			if(bgTextures[current-1])
				addChild(bgTextures[current-1]);
			
			timer.start();
		}
		
		override public function dispose():void
		{
			super.dispose();

			var i:int = 0;
			var len:int = bgTextures?bgTextures.length:0;
			for( i; i < len; i++ ){
				if( bgTextures[i] ){
					bgTextures[i].dispose();
					PoolMap.disposeInstance(bgTextures[i]);
				}
				
				delete bgTextures[i];
			}
			
			if( timer )
				PoolMap.disposeInstance(timer);
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			super.removeFromStageHandler(evt);
			
			if( timer ) timer.stop();
		}
	}
}