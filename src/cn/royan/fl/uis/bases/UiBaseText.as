package cn.royan.fl.uis.bases
{
	
	import cn.royan.fl.interfaces.uis.IUiTextBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
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
			inputText = new TextField();
			
			inputText.mouseEnabled 	= false;
			inputText.selectable 	= false;
			
			inputText.defaultTextFormat = getDefaultFormat();
			
			weakMap.add("inputText", inputText);
			weakMap.add("defaultFormat", defaultFormat);
			
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
				defaultFormat = new TextFormat();
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
		
		override public function draw():void
		{
			inputText.text = text;
			inputText.width = containerWidth;
			inputText.height= containerHeight;
		}
		
		override public function dispose():void
		{
			if( weakMap.getValue("inputText") ){
				weakMap.remove("inputText");
				inputText = null;
			}
				
			if( weakMap.getValue("defaultFormat") ){
				weakMap.remove("defaultFormat");
				defaultFormat = null;
			}
		}
	}
}