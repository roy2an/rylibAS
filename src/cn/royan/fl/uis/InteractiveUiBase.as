package cn.royan.fl.uis
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	public class InteractiveUiBase extends Sprite implements IUiBase
	{
		public static const NORMAL:int = 0;
		public static const OVER:int = 1;
		public static const DOWN:int = 2;
		public static const SELECTED:int = 3;
		public static const DISABLE:int = 4;
		
		protected var uid:uint;
		protected var status:uint;
		protected var statusLen:uint;
		protected var selected:Boolean;
		
		protected var bgColors:Array;
		protected var bgAlphas:Array;
		protected var eventMap:Dictionary;
		protected var bgTexture:BitmapData;
		protected var containerWidth:Number;
		protected var containerHeight:Number;
		protected var matrix:Matrix;
		protected var isMouseRender:Boolean;
		protected var callbacks:Object;
		
		public function InteractiveUiBase(texture:BitmapData = null)
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
			
			eventMap = new Dictionary(true);
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		protected function addToStageHandler(evt:Event = null):void
		{
			if( hasEventListener(Event.ADDED_TO_STAGE) ) removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			
			addEventListener(Event.REMOVED_FROM_STAGE, 	removeFromStageHandler);
			
			addEventListener(MouseEvent.MOUSE_OVER, 	mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, 		mouseOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, 	mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, 		mouseUpHandler);
			
			addEventListener(MouseEvent.CLICK, 			mouseClickHandler);
			
			draw();
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			for( var type:String in eventMap )
			{
				removeEventListener( type, eventMap[type] );
				eventMap[type] = null;
				delete eventMap[type];
			}
		}
		
		protected function mouseClickHandler(evt:MouseEvent):void
		{
			if( callbacks && callbacks["click"] ) callbacks["click"]();
		}
		
		protected function mouseOverHandler(evt:MouseEvent):void
		{
			status = selected?SELECTED:OVER;
			if( isMouseRender ) draw();
			if( callbacks && callbacks["over"] ) callbacks["over"]();
		}
		
		protected function mouseOutHandler(evt:MouseEvent):void
		{
			status = selected?SELECTED:NORMAL;
			if( isMouseRender ) draw();
			if( callbacks && callbacks["out"] ) callbacks["out"]();
		}
		
		protected function mouseDownHandler(evt:MouseEvent):void
		{
			status = selected?SELECTED:DOWN;
			if( isMouseRender ) draw();
			if( callbacks && callbacks["down"] ) callbacks["down"]();
		}
		
		protected function mouseUpHandler(evt:MouseEvent):void
		{
			status = selected?SELECTED:OVER;
			if( isMouseRender ) draw();
			if( callbacks && callbacks["up"] ) callbacks();
		}
		
		public function draw():void
		{
			graphics.clear();
			if( containerWidth && containerHeight ){
				if( bgTexture ){
					graphics.beginBitmapFill(bgTexture);
					graphics.drawRect( 0, 0, containerWidth, containerHeight );
					graphics.endFill();
				}else if( bgAlphas && bgAlphas.length > 1 ){
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
			return [0xFFFFFF];
		}
		
		public function getDefaultBackgroundAlphas():Array
		{
			return [1];
		}
		
		public function setBackgroundColors(value:Array):void
		{
			bgColors = value;
			
			if( bgColors && bgAlphas && bgTexture == null )
				statusLen = Math.min(bgColors.length, bgAlphas.length);
			
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
			
			if( bgColors && bgAlphas && bgTexture == null )
				statusLen = Math.min(bgColors.length, bgAlphas.length);
			
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
			draw();
		}
		
		public function getPosition():Array
		{
			return [x,y];
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
		
		public function getDispatcher():EventDispatcher
		{
			return this;
		}
		
		public function setMouseRender(value:Boolean):void
		{
			isMouseRender = value;
		}
		
		public function setEnabled(value:Boolean):void
		{
			status = value?status:DISABLE;
			mouseEnabled = value;
			mouseChildren = value;
			
			if(value){
				if( !hasEventListener(MouseEvent.MOUSE_OVER) ) addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				if( !hasEventListener(MouseEvent.MOUSE_OUT) ) addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				if( !hasEventListener(MouseEvent.MOUSE_DOWN) ) addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				if( !hasEventListener(MouseEvent.MOUSE_UP) ) addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				
				if( !hasEventListener(MouseEvent.CLICK) ) addEventListener(MouseEvent.CLICK, mouseClickHandler);
			}else{
				if( hasEventListener(MouseEvent.MOUSE_OVER) ) removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				if( hasEventListener(MouseEvent.MOUSE_OUT) ) removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				if( hasEventListener(MouseEvent.MOUSE_DOWN) ) removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				if( hasEventListener(MouseEvent.MOUSE_UP) ) removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				
				if( hasEventListener(MouseEvent.CLICK) ) removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			}
			
			draw();
		}
		
		public function getStatus():int
		{
			return status;
		}
		
		public function setCallbacks(value:Object):void
		{
			callbacks = value;
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
			callbacks = null;
		}
	}
}