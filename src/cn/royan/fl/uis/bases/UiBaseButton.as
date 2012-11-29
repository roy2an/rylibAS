package cn.royan.fl.uis.bases
{
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import cn.royan.fl.bases.PoolBase;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	
	public class UiBaseButton extends InteractiveUiBase implements IUiSelectBase
	{
		protected var btnHitArea:InteractiveUiBase;
		protected var bgTextures:Vector.<UninteractiveUiBase>;
		protected var btnLabel:String;
		protected var btnLabelText:UiBaseText;
		protected var btnBackgroundContainer:InteractiveUiBase;
		protected var type:int;
		protected var isInGroup:Boolean;
		
		public function UiBaseButton(label:String = '', texture:BitmapData = null, frames:uint = 5)
		{
			super(texture);
			
			btnLabel = label;
			
			if( bgColors && bgAlphas )
				statusLen = Math.min(bgColors.length, bgAlphas.length);
			
			if( texture ){
				type = 1;
				statusLen = frames;
			}
			
			initBackground();
			initLabel();
		}
		
		override public function draw():void
		{
			switch(type){
				case 0:
					while(btnBackgroundContainer.numChildren > 1){
						btnBackgroundContainer.removeChildAt(1);
					}
					
					if(__weakMap.getValue("bgTextures" + uid)[status])
						btnBackgroundContainer.addChild(bgTextures[status]);
					break;
				case 1:
					while(btnBackgroundContainer.numChildren){
						btnBackgroundContainer.removeChildAt(0);
					}
					
					if(__weakMap.getValue("bgTextures" + uid)[status])
						btnBackgroundContainer.addChild(bgTextures[status]);
					break;
			}
		}
		
		protected function initBackground():void
		{
			bgTextures = new Vector.<UninteractiveUiBase>(statusLen);
			
			var i:int = 0;
			var statusbg:UninteractiveUiBase;
			if( __weakMap.getValue("bgTexture" + uid) ){
				var bmpd:BitmapData;
				var frameWidth:int = bgTexture.width / statusLen;
				var frameHeight:int = bgTexture.height;
				var rectangle:Rectangle = PoolBase.getInstanceByType(Rectangle);
					rectangle.width = frameWidth;
					rectangle.height = frameHeight;
				var point:Point = PoolBase.getInstanceByType(Point);
				for( i = 0; i < statusLen; i++){
					bmpd = PoolBase.getInstanceByType(BitmapData, frameWidth, frameHeight, true);
					
					rectangle.x = i * frameWidth;
					
					bmpd.copyPixels( bgTexture, rectangle, point );
					statusbg = PoolBase.getInstanceByType(UninteractiveUiBase);
					statusbg.setTexture(bmpd);
					bgTextures[i] = statusbg;
				}
				
				PoolBase.disposeInstance(rectangle);
				PoolBase.disposeInstance(point);
			}else{
				for( i = 0; i < statusLen; i++){
					statusbg = PoolBase.getInstanceByType(UninteractiveUiBase);
					statusbg.setBackgroundColors([bgColors[i]]);
					statusbg.setBackgroundAlphas([bgAlphas[i]]);
					bgTextures[i] = statusbg;
				}
			}
			
			__weakMap.set("bgTextures" + uid, bgTextures);
			
			btnBackgroundContainer = PoolBase.getInstanceByType(InteractiveUiBase);
			addChild(btnBackgroundContainer);
			
			btnBackgroundContainer.addChild(bgTextures[0]);
		}
		
		protected function initLabel():void
		{
			btnLabelText = PoolBase.getInstanceByType(UiBaseText);
			btnLabelText.setText(btnLabel);
			btnLabelText.setSize(containerWidth, containerHeight);
			addChild(btnLabelText);
			
			__weakMap.set("btnLabelText" + uid, btnLabelText);
		}
		
		override protected function mouseClickHandler(evt:MouseEvent):void
		{
			if( !isInGroup ){
				selected = !selected;
				status = selected?SELECTED:status;
				
				draw();
			}
			
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE));
		}
		
		override public function getDefaultBackgroundColors():Array
		{
			return [0xFFFFFF,0x00ff64,0x00c850,0xe9f48e,0xa2a29e];
		}
		
		override public function getDefaultBackgroundAlphas():Array
		{
			return [1,1,1,1,1];
		}
		
		override public function setSize(cWidth:int, cHeight:int):void
		{
			super.setSize(cWidth, cHeight);
			for each( var io:UninteractiveUiBase in bgTextures ){
				io.setSize(cWidth, cHeight);
			}
			btnLabelText.setSize(cWidth, cHeight);
		}
		
		override public function setEnabled(value:Boolean):void
		{
			super.setEnabled(value);
			btnLabelText.setEnabled(value);
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
		
		public function getText():String
		{
			return btnLabelText.getText();
		}
		
		public function setText(value:String):void
		{
			btnLabelText.setText(value);
		}
		
		public function setFormat(format:TextFormat):void
		{
			btnLabelText.setFormat(format);
		}
		
		public function getFormat():TextFormat
		{
			return btnLabelText.getFormat();
		}
		
		public function setIsInGroup(value:Boolean):void
		{
			isInGroup = value;
		}
		
		override public function dispose():void
		{
			if( __weakMap.getValue("bgTexture" + uid) ){
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
			__weakMap.clear("btnLabelText" + uid);
			
			PoolBase.disposeInstance(btnLabelText);
			
			bgTextures = null;
			bgColors = null;
			bgAlphas = null;
		}
	}
}