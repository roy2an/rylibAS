package cn.royan.fl.uis
{
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.uis.IUiBase;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.EventDispatcher;

	public class UninteractiveUiBase extends Shape implements IUiBase
	{
		protected var weakMap:WeakMap;
		protected var bgColors:Array;
		protected var bgAlphas:Array;
		protected var bgTexture:BitmapData;
		protected var containerWidth:Number;
		protected var containerHeight:Number;
		
		public function UninteractiveUiBase(texture:BitmapData = null)
		{
			super();
			
			weakMap = new WeakMap();
			
			bgColors = getDefaultBackgroundColors();
			bgAlphas = getDefaultBackgroundAlphas();
			
			if( texture ){
				bgTexture = texture;
				weakMap.add("bgTexture", bgTexture);
			}
			
		}
		
		public function draw():void
		{
			graphics.clear();
			if( containerWidth && containerHeight ){
				if( weakMap.getValue("bgTexture") ){
					graphics.beginBitmapFill(bgTexture);
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}else if(  bgAlphas && bgAlphas.length > 1 ){
					throw new Error("no implements");
				}else if(  bgAlphas && bgAlphas.length > 0 && bgAlphas[0] > 0 ){
					graphics.beginFill( bgColors[0], bgAlphas[0] );
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}
			}
		}
		
		public function getDefaultBackgroundColors():Array
		{
			return [0xFFFFFF];
		}
		
		public function getDefaultBackgroundAlphas():Array
		{
			return [1];
		}
		
		public function setBackgroundColors(value:Array):void
		{
			bgColors = value;
			draw();
		}
		
		public function getBackgroundColors():Array
		{
			return bgColors;
		}
		
		public function setBackgroundAlphas(value:Array):void
		{
			bgAlphas = value;
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
		
		final public function getDispatcher():EventDispatcher
		{
			return null;
		}
		
		public function setEnabled(value:Boolean):void
		{
			
		}
		
		public function dispose():void
		{
			if( weakMap.getValue("bgTexture") ){
				bgTexture.dispose();
				weakMap.remove("bgTexture");
			}
				
			
			bgTexture = null;
			bgColors = null;
			bgAlphas = null;
		}
	}
}