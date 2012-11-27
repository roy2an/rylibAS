package cn.royan.fl.uis.bases
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	public class UiBaseInput extends InteractiveUiBase
	{
		protected var inputText:TextField;
		protected var inputFormat:TextFormat;
		
		public function UiBaseInput(texture:BitmapData=null)
		{
			super(texture);
			
			inputText = new TextField();
			inputText.type = TextFieldType.INPUT;
			inputText.border = true;
			inputText.addEventListener(Event.CHANGE, textChangeHandler);
			addChild(inputText);
		}
		
		protected function textChangeHandler(evt:Event):void
		{
			dispatchEvent(new DatasEvent(DatasEvent.DATA_CHANGE, getText()));
		}
		
		override public function setSize(cWidth:int, cHeight:int):void
		{
			super.setSize(cWidth, cHeight);
			
			inputText.width = cWidth;
			inputText.height = cHeight;
		}
		
		public function setFormat(format:TextFormat):void
		{
			inputText.defaultTextFormat = format;
		}
		
		public function setRestrict(value:String):void
		{
			inputText.restrict = value;
		}
		
		public function getText():String
		{
			return inputText.text;
		}
		
		public function setText(value:String):void
		{
			inputText.text = value;
		}
	}
}