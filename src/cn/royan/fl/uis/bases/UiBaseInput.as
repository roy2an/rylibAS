package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiTextBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class UiBaseInput extends UiBaseText
	{
		public function UiBaseInput(label:String='')
		{
			super(label);
			
			inputText.mouseEnabled 	= true;
			inputText.selectable 	= true;
			inputText.border 		= true;
			inputText.type 			= TextFieldType.INPUT;
			inputText.addEventListener(Event.CHANGE, textChangeHandler);
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
		
		override public function getDefaultFormat():TextFormat
		{
			if( !defaultFormat ){
				defaultFormat = PoolMap.getInstanceByType(TextFormat);
				defaultFormat.size = 14;
			}
			return defaultFormat;
		}
		
		public function setRestrict(value:String):void
		{
			inputText.restrict = value;
		}
	}
}