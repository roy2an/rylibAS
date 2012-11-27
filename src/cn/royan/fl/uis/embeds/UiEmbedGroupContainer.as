package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.IGroupBase;

	public class UiEmbedGroupContainer extends UiEmbedSprite implements IGroupBase
	{
		protected var items:Vector.<UiEmbedButton>;
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiEmbedGroupContainer()
		{
			super();
			
			items = new Vector.<UiEmbedButton>();
			values = [];
		}
		
		public function addGroupItem(item:*, key:* = null):void
		{
			items[key] = item;
			item.addEventListener(DatasEvent.DATA_DONE, itemClickHandler);
		}
		
		public function getValues():Array
		{
			return values;
		}
		
		protected function itemClickHandler(evt:DatasEvent):void
		{
			
		}
	}
}