package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.IUiBase;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class UiBaseGroupContainer extends UiBaseContainer
	{
		public static const ITEM_SELECTED:String = 'item_selected';
		
		protected var selectItem:IUiBase;
		
		public function UiBaseGroupContainer()
		{
			super();
		}
		
		override public function addItem(item:IUiBase):void
		{
			if(item.getDispatcher() == null) return;
			
			super.addItem(item);
			
			item.getDispatcher().addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		protected function clickHandler(evt:MouseEvent):void
		{
			selectItem = evt.currentTarget as IUiBase;
			dispatchEvent(new Event(ITEM_SELECTED));
		}
		
		public function get selectedItem():IUiBase
		{
			return selectItem;
		}
		
		public function get selectedIndex():int
		{
			return items.indexOf(selectItem);
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			var i:int = 0;
			var len:int = weakMap.getValue("items")?items.length:0;
			for( i; i < len; i++ ){
				if( items[i] && items[i].getDispatcher().hasEventListener(MouseEvent.CLICK) )
					items[i].getDispatcher().removeEventListener(MouseEvent.CLICK, clickHandler);
			}
			super.removeFromStageHandler(evt);
		}
	}
}