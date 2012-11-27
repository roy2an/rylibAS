package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;

	public class UiEmbedButtonBar extends UiEmbedSprite
	{
		protected var items:Vector.<UiEmbedButton>;
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiEmbedButtonBar()
		{
			super();
			
			items = new Vector.<UiEmbedButton>();
			values = [];
		}
		
		public function addItem(item:UiEmbedButton, value:*):void
		{
			items[value] = item;
			
			item.addEventListener(DatasEvent.DATA_DONE, itemClickHandler);
		}
		
		public function getValues():Array
		{
			return null;
		}
		
		protected function itemClickHandler(evt:DatasEvent):void
		{
			for( var key:String in items )
			{
				if( items[key] == evt.currentTarget )
				{
					items[key].isSelected = true;
				}else{
					items[key].isSelected = false;
				}
			}
		}
	}
}