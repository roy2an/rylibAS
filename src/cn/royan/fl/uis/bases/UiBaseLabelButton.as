package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	import cn.royan.fl.interfaces.uis.IUiTextBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	public class UiBaseLabelButton extends InteractiveUiBase implements IUiTextBase, IUiSelectBase
	{
		protected var bgTextures:Vector.<UninteractiveUiBase>;
		protected var currentStatus:UninteractiveUiBase;
		protected var isInGroup:Boolean;
		protected var btnLabel:String;
		protected var btnLabelText:UiBaseText;
		protected var btnBackground:InteractiveUiBase;
		
		public function UiBaseLabelButton(label:String="")
		{
			super();
			
			btnLabel = label;
			statusLen = 5;
			bgTextures = new Vector.<UninteractiveUiBase>(statusLen);
			
			var i:int;
			for( i = 0; i < statusLen; i++){
				bgTextures[i] = PoolMap.getInstanceByType(UninteractiveUiBase);
				bgTextures[i].setBackgroundColors(bgColors[i].length > 1?bgColors[i]:[bgColors[i]]);
				bgTextures[i].setBackgroundAlphas(bgAlphas[i].length > 1?bgAlphas[i]:[bgAlphas[i]]);
			}
			
			btnBackground = PoolMap.getInstanceByType(InteractiveUiBase);
			addChild(btnBackground);
			
			btnLabelText = PoolMap.getInstanceByType(UiBaseText);
			btnLabelText.setText(btnLabel);
			addChild(btnLabelText);
			
			setMouseRender(true);
		}
		
		override public function draw():void
		{
			if( bgTextures[status] )
				btnBackground.addChild(bgTextures[status]);
		}
		
		override protected function mouseClickHandler(evt:MouseEvent):void
		{
			if( isInGroup ){
				selected = !selected;
				status = selected?INTERACTIVE_STATUS_SELECTED:status;
				
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
			status = selected?INTERACTIVE_STATUS_SELECTED:INTERACTIVE_STATUS_NORMAL;
			draw();
		}
		
		public function getSelected():Boolean
		{
			return selected;
		}
		
		override public function setTexture(value:BitmapData, frames:uint=5):void
		{
			
		}
		
		public function setIsInGroup(value:Boolean):void
		{
			isInGroup = value;
		}
		
		override public function setSize(cWidth:int, cHeight:int):void
		{
			super.setSize(cWidth, cHeight);
			for each( var state:UninteractiveUiBase in bgTextures ){
				state.setSize(cWidth, cHeight);
			}
			btnLabelText.setSize(cWidth, cHeight);
		}
		
		public function setText(value:String):void
		{
			btnLabelText.setText(value);
		}
		
		public function appendText(value:String):void
		{
			btnLabelText.appendText(value);
		}
		
		public function getText():String
		{
			return btnLabelText.getText();
		}
		
		public function setHTMLText(value:String):void
		{
			btnLabelText.setHTMLText(value);
		}
		
		public function appendHTMLText(value:String):void
		{
			btnLabelText.appendHTMLText(value);
		}
		
		public function getHTMLText():String
		{
			return btnLabelText.getHTMLText();
		}
		
		public function setTextAlign(value:String):void
		{
			btnLabelText.setTextAlign(value);
		}
		
		public function setTextColor(value:uint):void
		{
			btnLabelText.setTextColor(value);
		}
		
		public function setTextSize(value:int):void
		{
			btnLabelText.setTextSize(value);
		}
		
		public function setEmbedFont(value:Boolean):void
		{
			btnLabelText.setEmbedFont(value);
		}
		
		public function setFormat(value:TextFormat,begin:int=-1,end:int=-1):void
		{
			btnLabelText.setFormat(value,begin,end);
		}
		
		public function getFormat(begin:int=-1,end:int=-1):TextFormat
		{
			return btnLabelText.getFormat(begin,end);
		}
		
		public function setDefaultFormat(value:TextFormat):void
		{
			btnLabelText.setDefaultFormat(value);
		}
		
		public function getDefaultFormat():TextFormat
		{
			return btnLabelText.getDefaultFormat();
		}
		
		public function setScroll(sx:int=0, sy:int=0):void
		{
			btnLabelText.setScroll(sx, sy);
		}
		
		public function getScroll():Array
		{
			return btnLabelText.getScroll();
		}
		
		public function getMaxScroll():Array
		{
			return btnLabelText.getMaxScroll();
		}
		
		public function setMultiLine(value:Boolean):void
		{
			btnLabelText.setMultiLine(value);
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