package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.TimerBase;
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
		protected var bgTextures:Vector.<BitmapData>;
		protected var timer:TimerBase;
		protected var current:int;
		protected var total:int;
		protected var toFrame:int;
		protected var frameRate:int;
		protected var sequence:Boolean;
		protected var loop:Boolean;
		protected var autoPlay:Boolean;
		protected var currentFrame:Bitmap;
		
		public function UiBaseBmpdMovieClip(texture:Object, rate:int = 10, auto:Boolean = true, row:int = 1, column:int = 1, frames:int = 1)
		{
			super(texture is BitmapData?texture as BitmapData:null);
			
			var bmpd:BitmapData;
			var frameunit:UninteractiveUiBase;
			
			if( texture is BitmapData ){
				total = frames;
				
				bgTextures = new Vector.<BitmapData>(total);
				
				var frameWidth:int = bgTexture.width / row;
				var frameHeight:int = bgTexture.height / column;
				
				setSize(frameWidth, frameHeight);
				
				var i:int;
				var rectangle:Rectangle = PoolMap.getInstanceByType(Rectangle);
					rectangle.width = frameWidth;
					rectangle.height = frameHeight;
				var point:Point = PoolMap.getInstanceByType(Point);
				var curRow:int;
				var curCol:int;
				
				for(i = 0; i < total; i++){
					curRow = i % row;
					curCol = i / row;
					
					rectangle.x = curRow * frameWidth;
					rectangle.y = curCol * frameHeight;
					
					bmpd = PoolMap.getInstanceByType(BitmapData, frameWidth, frameHeight, true);
					bmpd.copyPixels( bgTexture, rectangle, point );
					
					bgTextures[i] = bmpd;
				}
				
				PoolMap.disposeInstance(rectangle);
				PoolMap.disposeInstance(point);
			}else if( texture is Vector.<BitmapData>){
				total = (texture as Vector.<BitmapData>).length;
				bgTextures = texture as Vector.<BitmapData>;
				
				setSize(bgTextures[0].width, bgTextures[0].height);
			}else{
				throw new Error("texture is wrong type(BitmapData or Vector.<BitmapData>)");
			}
			
			loop = true;
			autoPlay = auto;
			sequence = true;
			current = 1;
			toFrame = 0;
			frameRate = rate;
			
			timer = PoolMap.getInstanceByType(TimerBase, 1000 / frameRate, timerHandler);
			
			currentFrame = PoolMap.getInstanceByType( Bitmap );
			
			if( bgTextures[current-1] )
				currentFrame.bitmapData = bgTextures[current - 1];
			
			addChild(currentFrame);
		}
		
		override protected function addToStageHandler(evt:Event = null):void
		{
			super.addToStageHandler(evt);
			
			if( autoPlay ) timer.start();
		}
		
		override public function draw():void
		{
			
		}
		
		public function clone():UiBaseBmpdMovieClip
		{
			return new UiBaseBmpdMovieClip(bgTextures, frameRate, autoPlay);
		}
		
		public function addFrame():void
		{
			
		}
		
		public function addFrameAt(index:int):void
		{
			
		}
		
		public function removeFrame():void
		{
			
		}
		
		public function removeFrameAt(index:int):void
		{
			
		}
		
		protected function timerHandler():void
		{
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
			
			currentFrame.bitmapData = bgTextures[current - 1];
			
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
			
			current = to;
			
			currentFrame.bitmapData = bgTextures[current - 1];
		}
		
		public function goFromTo(from:int, to:int):void
		{
			SystemUtils.print("play from["+from+"] to ["+to+"]");
			if( from == to ) return;
			
			loop = false;
			sequence = from <= to;
			current = from;
			toFrame = to;
			
			currentFrame.bitmapData = bgTextures[current - 1];
			
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
			
			timer.stop();
			PoolMap.disposeInstance(timer);
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			super.removeFromStageHandler(evt);
			
			if( timer ) timer.stop();
		}
	}
}