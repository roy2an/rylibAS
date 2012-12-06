package cn.royan.fl.uis
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class UninteractiveUiBase extends Shape implements IUiBase
	{
		protected var uid:uint;
		protected var bgColors:Array;
		protected var bgAlphas:Array;
		protected var bgTexture:BitmapData;
		protected var containerWidth:Number;
		protected var containerHeight:Number;
		protected var matrix:Matrix;
		
		public function UninteractiveUiBase(texture:BitmapData = null)
		{
			super();
			
			cacheAsBitmap = true;
			
			uid = SystemUtils.createObjectUID();
			
			bgColors = getDefaultBackgroundColors();
			bgAlphas = getDefaultBackgroundAlphas();
			
			if( texture ){
				bgTexture = texture;
				setSize(bgTexture.width, bgTexture.height);
			}
			
		}
		
		public function draw():void
		{
			graphics.clear();
			if( containerWidth && containerHeight ){
				if( bgTexture ){
					graphics.beginBitmapFill(bgTexture);
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}else if(  bgAlphas && bgAlphas.length > 1 ){
					matrix.createGradientBox(containerWidth, containerHeight, Math.PI / 2, 0, 0);
					graphics.beginGradientFill(GradientType.LINEAR, bgColors, bgAlphas, [0,255], matrix);
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}else if(  bgAlphas && bgAlphas.length > 0 && bgAlphas[0] > 0 ){
					graphics.beginFill( bgColors[0], bgAlphas[0] );
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}
			}
		}
		
		public function getDefaultBackgroundColors():Array
		{
			return [0xFF0000,0x00FF00];
		}
		
		public function getDefaultBackgroundAlphas():Array
		{
			return [1,1];
		}
		
		public function setBackgroundColors(value:Array):void
		{
			bgColors = value;
			
			if( bgColors.length > 1 ){
				if( matrix )
					PoolMap.disposeInstance(matrix);
				
				matrix = PoolMap.getInstanceByType(Matrix);
			}
			
			draw();
		}
		
		public function getBackgroundColors():Array
		{
			return bgColors;
		}
		
		public function setBackgroundAlphas(value:Array):void
		{
			bgAlphas = value;
			
			if( bgAlphas.length > 1 ){
				if( matrix )
					PoolMap.disposeInstance(matrix);
				
				matrix = PoolMap.getInstanceByType(Matrix);
			}
			
			draw();
		}
		
		public function getBackgroundAlphas():Array
		{
			return bgAlphas;
		}
		
		public function setSize(cWidth:int, cHeight:int):void
		{
			containerWidth = cWidth;
			containerHeight= cHeight;
			draw();
		}
		
		public function getSize():Array
		{
			return [containerWidth, containerHeight];
		}
		
		public function setPosition(cX:int, cY:int):void
		{
			x = cX;
			y = cY;
		}
		
		public function getPosition():Array
		{
			return [x,y];
		}
		
		public function setPositionPoint(point:Point):void
		{
			setPosition(point.x, point.y);
		}
		
		public function getPositionPoint():Point
		{
			return new Point(x, y);
		}
		
		public function setTexture(value:BitmapData, frames:uint=1):void
		{
			bgTexture = value;
			
			setSize( value.width, value.height );
			
			draw();
		}
		
		public function getTexture():BitmapData
		{
			return bgTexture;
		}
		
		final public function getDispatcher():EventDispatcher
		{
			return null;
		}
		
		public function dispose():void
		{
			if( bgTexture ){
				bgTexture.dispose();
				PoolMap.disposeInstance(bgTexture);
			}
				
			if( matrix )
				PoolMap.disposeInstance(matrix);
			
			bgColors = null;
			bgAlphas = null;
		}
	}
}