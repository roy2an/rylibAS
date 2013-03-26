package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.interfaces.uis.IUiScrollerBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class UiBaseScroller extends InteractiveUiBase implements IUiScrollerBase
	{
		public static const SCROLL_TYPE_NONE:int				= 0;
		public static const SCROLL_TYPE_HORIZONTAL_ONLY:int 	= 1;
		public static const SCROLL_TYPE_VERICAL_ONLY:int 		= 2;
		public static const SCROLL_TYPE_HANDV:int				= 3;
		
		protected var container:InteractiveUiBase;
		protected var containerMask:UninteractiveUiBase;
		protected var scrollerType:int;
		
		protected var hThumb:IUiBase;
		protected var hBackground:IUiBase;
		protected var hMin:IUiBase;
		protected var hMax:IUiBase;
		protected var hRect:Rectangle;
		
		protected var vThumb:IUiBase;
		protected var vBackground:IUiBase;
		protected var vMin:IUiBase;
		protected var vMax:IUiBase;
		protected var vRect:Rectangle;
		
		public function UiBaseScroller(container:InteractiveUiBase, type:int = SCROLL_TYPE_NONE)
		{
			super();
			
			this.container = container;
			
			containerMask = new UninteractiveUiBase();

			setType(type);
		}
		
		override public function draw():void
		{
			switch(scrollerType){
				case SCROLL_TYPE_NONE:
					container.mask = null;
					if( container.parent.contains(containerMask)) container.parent.removeChild(containerMask);
					if( hBackground && container.parent.contains(hBackground as InteractiveUiBase)) container.parent.removeChild(hBackground as InteractiveUiBase);
					if( vBackground && container.parent.contains(vBackground as InteractiveUiBase)) container.parent.removeChild(vBackground as InteractiveUiBase);
					break;
				case SCROLL_TYPE_VERICAL_ONLY:
					container.mask = containerMask;
					container.parent.addChild(containerMask);
					
					if( vRect == null ) vRect = new Rectangle(0, 0, 0, 0);
					vRect.x = (container.parent as InteractiveUiBase).getSize()[0] - getSize()[0];
					vRect.y = 0;
					vRect.width = 0;
					vRect.height = (container.parent as InteractiveUiBase).getSize()[1] - (vThumb?vThumb.getSize()[1]:0);
					
					if( vBackground == null ) vBackground = new InteractiveUiBase();
					vBackground.setSize( getSize()[0], (container.parent as InteractiveUiBase).getSize()[1]);
					vBackground.setPosition((container.parent as InteractiveUiBase).getSize()[0] - getSize()[0], 0);
					container.parent.addChild(vBackground as InteractiveUiBase);
					
					if( vThumb == null ){
						vThumb = new InteractiveUiBase();
						(vThumb as InteractiveUiBase).addEventListener(MouseEvent.MOUSE_DOWN, vThumbMouseDownHandler);
					}
					vThumb.setPosition((container.parent as InteractiveUiBase).getSize()[0] - getSize()[0], 0);
					container.parent.addChild(vThumb as InteractiveUiBase);
					
					break;
				case SCROLL_TYPE_HORIZONTAL_ONLY:
					container.mask = containerMask;
					container.parent.addChild(containerMask);
					
					if( hRect == null ) vRect = new Rectangle(0, 0, 0, 0);
					hRect.x = 0;
					hRect.y = (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1];
					hRect.width = (container.parent as InteractiveUiBase).getSize()[0] - (hThumb?hThumb.getSize()[0]:0);
					hRect.height = 0;
					
					if( hBackground == null ) hBackground = new InteractiveUiBase();
					hBackground.setSize( (container.parent as InteractiveUiBase).getSize()[0], getSize()[1]);
					hBackground.setPosition(0, (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1]);
					
					container.parent.addChild(hBackground as InteractiveUiBase);
					break;
				case SCROLL_TYPE_HANDV:
					container.mask = containerMask;
					container.parent.addChild(containerMask);
					
					if( vRect == null ) vRect = new Rectangle(0, 0, 0, 0);
					vRect.x = (container.parent as InteractiveUiBase).getSize()[0] - getSize()[0];
					vRect.y = 0;
					vRect.width = 0;
					vRect.height = (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1] - (vThumb?vThumb.getSize()[1]:0);
					
					if( hRect == null ) vRect = new Rectangle(0, 0, 0, 0);
					hRect.x = 0;
					hRect.y = (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1];
					hRect.width = (container.parent as InteractiveUiBase).getSize()[0] - getSize()[0] - (hThumb?hThumb.getSize()[0]:0);
					hRect.height = 0;
					
					if( vBackground == null ) vBackground = new InteractiveUiBase();
					vBackground.setSize( getSize()[0], (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1]);
					vBackground.setPosition((container.parent as InteractiveUiBase).getSize()[0] - getSize()[0], 0);
					
					container.parent.addChild(vBackground as InteractiveUiBase);
					
					if( hBackground == null ) hBackground = new InteractiveUiBase();
					hBackground.setSize( (container.parent as InteractiveUiBase).getSize()[0] - getSize()[0], getSize()[1]);
					hBackground.setPosition(0, (container.parent as InteractiveUiBase).getSize()[1] - getSize()[1]);
					
					container.parent.addChild(hBackground as InteractiveUiBase);
					break;
			}
		}
		
		protected function vThumbMouseDownHandler(evt:MouseEvent):void
		{
			(vThumb as InteractiveUiBase).addEventListener(Event.ENTER_FRAME, vThumbEnterFrameHandler);
			
			(vThumb as InteractiveUiBase).startDrag(false, vRect);
			(vThumb as InteractiveUiBase).addEventListener(MouseEvent.MOUSE_UP, vThumbMouseUpHandler);
			(vThumb as InteractiveUiBase).stage.addEventListener(MouseEvent.MOUSE_UP, vThumbMouseUpHandler);
		}
		
		protected function vThumbMouseUpHandler(evt:MouseEvent):void
		{
			(vThumb as InteractiveUiBase).stopDrag();
			
			(vThumb as InteractiveUiBase).removeEventListener(Event.ENTER_FRAME, vThumbEnterFrameHandler);
			
			(vThumb as InteractiveUiBase).removeEventListener(MouseEvent.MOUSE_UP, vThumbMouseUpHandler);
			(vThumb as InteractiveUiBase).stage.removeEventListener(MouseEvent.MOUSE_UP, vThumbMouseUpHandler);
		}
		
		protected function vThumbEnterFrameHandler(evt:Event):void
		{
			container.y = - vThumb.getPosition()[1]/vRect.height * (container.height - (container.parent as InteractiveUiBase).getSize()[1])
		}
		
		protected function hThumbMouseDownHandler(evt:MouseEvent):void
		{
			(hThumb as InteractiveUiBase).addEventListener(Event.ENTER_FRAME, hThumbEnterFrameHandler);
			
			(hThumb as InteractiveUiBase).startDrag(false, hRect);
			(hThumb as InteractiveUiBase).addEventListener(MouseEvent.MOUSE_UP, hThumbMouseUpHandler);
			(hThumb as InteractiveUiBase).stage.addEventListener(MouseEvent.MOUSE_UP, hThumbMouseUpHandler);
		}
		
		protected function hThumbMouseUpHandler(evt:MouseEvent):void
		{
			(hThumb as InteractiveUiBase).stopDrag();
			
			(hThumb as InteractiveUiBase).removeEventListener(Event.ENTER_FRAME, hThumbEnterFrameHandler);
			
			(hThumb as InteractiveUiBase).removeEventListener(MouseEvent.MOUSE_UP, hThumbMouseUpHandler);
			(hThumb as InteractiveUiBase).stage.removeEventListener(MouseEvent.MOUSE_UP, hThumbMouseUpHandler);
		}
		
		protected function hThumbEnterFrameHandler(evt:Event):void
		{
			container.y = - hThumb.getPosition()[0]/hRect.width * (container.height - (container.parent as InteractiveUiBase).getSize()[0])
		}
		
		public function setContainerSize(cWidth:int, cHeight:int):void
		{
			containerMask.setSize(cWidth, cHeight);
			
			draw();
		}
		
		public function setType(type:int):void
		{
			scrollerType = type;
			
			draw();
		}
		
		public function show(v:Boolean, h:Boolean):void
		{
			if(v){
				if(scrollerType == 2 || scrollerType == 3){
					if( vThumb ) (vThumb as InteractiveUiBase).visible = true;
					if( vBackground ) (vBackground as InteractiveUiBase).visible = true;
				}
			}else{
				if(scrollerType == 2 || scrollerType == 3){
					if( vThumb ) (vThumb as InteractiveUiBase).visible = false;
					if( vBackground ) (vBackground as InteractiveUiBase).visible = false;
				}
			}
			
			if(h){
				if(scrollerType == 1 || scrollerType == 3){
					if( hThumb ) (hThumb as InteractiveUiBase).visible = false;
					if( hBackground ) (hBackground as InteractiveUiBase).visible = false;
				}
			}else{
				if(scrollerType == 1 || scrollerType == 3){
					if( hThumb ) (hThumb as InteractiveUiBase).visible = false;
					if( hBackground ) (hBackground as InteractiveUiBase).visible = false;
				}
			}
		}
		
		public function setThumbTexture(texture:Object):void
		{
			if( texture is BitmapData ){
				if( vThumb ) vThumb.setTexture(texture as BitmapData);
				if( hThumb ) hThumb.setTexture(texture as BitmapData);
			}else if( texture is uint ){
				if( vThumb ) vThumb.setBackgroundColors([texture]);
				if( hThumb ) hThumb.setBackgroundColors([texture]);
			}
			
			draw();
		}
		
		public function setMinTexture(texture:Object):void
		{
			if( texture is BitmapData ){
				if( vMin ) vMin.setTexture(texture as BitmapData);
				if( hMin ) hMin.setTexture(texture as BitmapData);
			}else if( texture is uint ){
				if( vMin ) vMin.setBackgroundColors([texture]);
				if( hMin ) hMin.setBackgroundColors([texture]);
			}
			
			draw();
		}
		
		public function setMaxTexture(texture:Object):void
		{
			if( texture is BitmapData ){
				if( vMax ) vMax.setTexture(texture as BitmapData);
				if( hMax ) hMax.setTexture(texture as BitmapData);
			}else if( texture is uint ){
				if( vMax ) vMax.setBackgroundColors([texture]);
				if( hMax ) hMax.setBackgroundColors([texture]);
			}
			
			draw();
		}
		
		public function setBackgroundTextrue(texture:Object):void
		{
			if( texture is BitmapData ){
				if( vBackground ) vBackground.setTexture(texture as BitmapData);
				if( hBackground ) hBackground.setTexture(texture as BitmapData);
			}else if( texture is uint ){
				if( vBackground ) vBackground.setBackgroundColors([texture]);
				if( hBackground ) hBackground.setBackgroundColors([texture]);
			}
			
			draw();
		}
	}
}