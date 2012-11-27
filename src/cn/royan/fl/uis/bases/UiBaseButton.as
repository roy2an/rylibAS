package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class UiBaseButton extends InteractiveUiBase
	{
		protected var btnHitArea:InteractiveUiBase;
		protected var bgTextures:Vector.<UninteractiveUiBase>;
		protected var btnLabel:String;
		protected var btnLabelText:UiBaseLabel;
		protected var btnBackgroundContainer:InteractiveUiBase;
		protected var type:int;
		
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
					
					if(weakMap.getValue("bgTextures")[status])
						btnBackgroundContainer.addChild(bgTextures[status]);
					break;
				case 1:
					while(btnBackgroundContainer.numChildren){
						btnBackgroundContainer.removeChildAt(0);
					}
					
					if(weakMap.getValue("bgTextures")[status])
						btnBackgroundContainer.addChild(bgTextures[status]);
					break;
			}
		}
		
		protected function initBackground():void
		{
			bgTextures = new Vector.<UninteractiveUiBase>(statusLen);
			
			var frameWidth:int = bgTexture.width / statusLen;
			var frameHeight:int = bgTexture.height;
			var i:int = 0;
			var statusbg:UninteractiveUiBase;
			if( weakMap.getValue("bgTexture") ){
				var bmpd:BitmapData;
				for( i = 0; i < statusLen; i++){
					bmpd = new BitmapData(frameWidth, frameHeight, true);
					bmpd.copyPixels( bgTexture, new Rectangle(i * frameWidth, 0, frameWidth, frameHeight), new Point() );
					statusbg = new UninteractiveUiBase(bmpd );
					bgTextures[i] = statusbg;
				}
			}else{
				for( i = 0; i < statusLen; i++){
					statusbg = new UninteractiveUiBase();
					statusbg.setBackgroundColors([bgColors[i]]);
					statusbg.setBackgroundAlphas([bgAlphas[i]]);
					bgTextures[i] = statusbg;
				}
			}
			
			weakMap.add("bgTextures", bgTextures);
			
			btnBackgroundContainer = new InteractiveUiBase();
			addChild(btnBackgroundContainer);
			
			btnBackgroundContainer.addChild(bgTextures[0]);
		}
		
		protected function initLabel():void
		{
			btnLabelText = new UiBaseLabel(btnLabel);
			btnLabelText.setSize(containerWidth, containerHeight);
			addChild(btnLabelText);
		}
		
		override protected function mouseClickHandler(evt:MouseEvent):void
		{
			selected = !selected;
			status = selected?SELECTED:status;
			draw();
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
		
		override public function dispose():void
		{
			if( weakMap.getValue("bgTexture") )
				bgTexture.dispose();
			
			var i:int = 0;
			var len:int = weakMap.getValue("bgTextures")?bgTextures.length:0;
			for( i; i < len; i++ ){
				if( bgTextures[i] )
					bgTextures[i].dispose();
				
				bgTextures[i] = null;
				delete bgTextures[i];
			}
			
			bgTexture = null;
			bgTextures = null;
			bgColors = null;
			bgAlphas = null;
		}
	}
}