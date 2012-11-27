package cn.royan.fl.uis.bases
{
	
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class UiBaseLabel extends InteractiveUiBase
	{
		protected var labelValue:String;
		protected var labelText:TextField;
		protected var labelFormat:TextFormat;
		
		public function UiBaseLabel(label:String)
		{
			labelValue = label;
			labelText = new TextField();
			
			labelText.mouseEnabled = false;
			labelText.selectable = false;
			
			labelFormat = new TextFormat();
			labelFormat.align = TextFormatAlign.CENTER;
			labelText.defaultTextFormat = labelFormat;
			
			weakMap.add("labelText", labelText);
			weakMap.add("labelFormat", labelFormat);
			
			addChild(labelText);
		}
		
		override public function draw():void
		{
			labelText.text = labelValue;
			labelText.width = containerWidth;
			labelText.height= containerHeight;
		}
		
		override public function dispose():void
		{
			if( weakMap.getValue("labelText") )
				labelText = null;
			if( weakMap.getValue("labelFormat") )
				labelFormat = null;
		}
	}
}