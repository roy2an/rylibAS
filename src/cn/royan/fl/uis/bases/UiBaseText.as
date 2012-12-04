package cn.royan.fl.uis.bases
{
	
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.interfaces.uis.IUiTextBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class UiBaseText extends InteractiveUiBase implements IUiTextBase
	{
		protected var text:String;
		protected var inputText:TextField;
		protected var defaultFormat:TextFormat;
		
		public function UiBaseText(label:String='')
		{
			text = label;
			inputText = PoolMap.getInstanceByType(TextField);
			inputText.text = text;
			inputText.mouseEnabled 	= false;
			inputText.selectable 	= false;
			inputText.defaultTextFormat = getDefaultFormat();
			
			setSize(100, 20);
			addChild(inputText);
		}
		
		public function setFormat(format:TextFormat):void
		{
			inputText.defaultTextFormat = format;
		}
		
		public function getFormat():TextFormat
		{
			return inputText.getTextFormat();
		}
		
		public function getDefaultFormat():TextFormat
		{
			if( !defaultFormat ){
				defaultFormat = PoolMap.getInstanceByType(TextFormat);
				defaultFormat.align = TextFormatAlign.CENTER;
				defaultFormat.size = 14;
			}
			return defaultFormat;
		}
		
		public function getText():String
		{
			return inputText.text;
		}
		
		public function setText(value:String):void
		{
			text = value;
			inputText.text = value;
		}
		
		public function appendText(value:String):void
		{
			inputText.appendText(value);
		}
		
		public function setHTMLText(value:String):void
		{
			inputText.htmlText = value;
		}
		
		public function getHTMLText():String
		{
			return inputText.htmlText;
		}
		
		public function appendHTMLText(value:String):void
		{
			inputText.htmlText += value;
		}
		
		public function setMultiLine(value:Boolean):void
		{
			inputText.multiline = value;
			inputText.wordWrap = value;
		}
		
		public function setEmbedFont(value:Boolean):void
		{
			inputText.embedFonts = value;
		}
		
		override public function draw():void
		{
			inputText.width = containerWidth;
			inputText.height= containerHeight;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if( inputText )
				PoolMap.disposeInstance(inputText);
				
			if( defaultFormat )
				PoolMap.disposeInstance(defaultFormat);
		}
	}
}