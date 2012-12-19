package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class UiBaseBmpdButton extends InteractiveUiBase implements IUiSelectBase
	{
		protected var bgTextures:Vector.<BitmapData>;
		protected var currentStatus:Bitmap;
		protected var total:int;
		protected var isInGroup:Boolean;
		
		public function UiBaseBmpdButton(texture:Object, frames:uint = 5)
		{
			super(texture is BitmapData?texture as BitmapData:null);
			
			if( texture is BitmapData ){
				total = frames;
				bgTextures = new Vector.<BitmapData>(total);
				drawTextures();
			}else if( texture is Vector.<BitmapData>){
				total = (texture as Vector.<BitmapData>).length;
				bgTextures = texture as Vector.<BitmapData>;
				
				setSize(bgTextures[0].width, bgTextures[0].height);
			}else{
				throw new Error("texture is wrong type(BitmapData or Vector.<BitmapData>)");
			}
			
			currentStatus = PoolMap.getInstanceByType( Bitmap );
			
			if( bgTextures[status] )
				currentStatus.bitmapData = bgTextures[status];
			
			addChild(currentStatus);
			
			isMouseRender = true;
			
			SystemUtils.print("Finish");
		}
		
		protected function drawTextures():void
		{
			var frameWidth:int = bgTexture.width / total;
			var frameHeight:int = bgTexture.height;
			
			var i:int;
			var rectangle:Rectangle = PoolMap.getInstanceByType(Rectangle);
				rectangle.width = frameWidth;
				rectangle.height = frameHeight;
			var point:Point = PoolMap.getInstanceByType(Point);
			var curRow:int;
			var curCol:int;
			
			for(i = 0; i < total; i++){
				curRow = i % total;
				curCol = i / total;
				
				rectangle.x = curRow * frameWidth;
				rectangle.y = curCol * frameHeight;
				
				var bmpd:BitmapData;
					bmpd = PoolMap.getInstanceByType(BitmapData, frameWidth, frameHeight, true);
					bmpd.copyPixels( bgTexture, rectangle, point );
				
				bgTextures[i] = bmpd;
			}
			
			setSize(frameWidth, frameHeight);
			
			PoolMap.disposeInstance(rectangle);
			PoolMap.disposeInstance(point);
		}
		
		override protected function addToStageHandler(evt:Event=null):void
		{
			super.addToStageHandler(evt);
			
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		protected function mouseMoveHandler(evt:MouseEvent):void
		{
			buttonMode = (currentStatus.bitmapData.getPixel32(evt.localX, evt.localY) >> 24) != 0x00;
		}
		
		override public function draw():void
		{
			if( currentStatus && bgTextures[status] )
				currentStatus.bitmapData = bgTextures[status];
		}
		
		public function clone():UiBaseBmpdButton
		{
			return new UiBaseBmpdButton(bgTextures);
		}
		
		override protected function mouseClickHandler(evt:MouseEvent):void
		{
			if( isInGroup ){
				selected = !selected;
				status = selected?SELECTED:status;
				
				draw();
			}
			
			super.mouseClickHandler(evt);
		}
		
		override public function getDefaultBackgroundColors():Array
		{
			return [[0xFFFFFF,0x00ff64],[0x00ff64,0x00c850],[0x00c850,0xe9f48e],[0xe9f48e,0xa2a29e],[0xa2a29e,0xFFFFFF]];
		}
		
		override public function getDefaultBackgroundAlphas():Array
		{
			return [[1,1],[1,1],[1,1],[1,1],[1,1]];
		}
		
		public function setSelected(value:Boolean):void
		{
			selected = value;
			status = selected?SELECTED:NORMAL;
			draw();
		}
		
		public function getSelected():Boolean
		{
			return selected;
		}
		
		override public function setTexture(value:BitmapData, frames:uint=5):void
		{
			if( value ){
				statusLen = frames;
			}
			
			bgTexture = value;
			
			drawTextures();
			draw();
		}
		
		public function setIsInGroup(value:Boolean):void
		{
			isInGroup = value;
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
		}
	}
}