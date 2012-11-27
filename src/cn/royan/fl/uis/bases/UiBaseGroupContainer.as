package cn.royan.fl.uis.bases
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.IGroupBase;
	import cn.royan.fl.interfaces.IUiBase;

	public class UiBaseGroupContainer extends UiBaseContainer implements IGroupBase
	{
		public static const ITEM_SELECTED:String = 'item_selected';
		
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiBaseGroupContainer()
		{
			super();
			
			values = [];
		}
		
		public function addGroupItem(item:*, key:*=null):void
		{
			if(item.getDispatcher() == null) return;
			
			items[key] = item;
			super.addItem(item);
			
			item.getDispatcher().addEventListener(DatasEvent.DATA_DONE, clickHandler);
		}
		
		override public function addItem(item:IUiBase):void
		{
			addChild(item as DisplayObject);
			draw();
		}
		
		public function getValues():Array
		{
			return values;
		}
		
		protected function clickHandler(evt:DatasEvent):void
		{
			
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			var i:int = 0;
			var len:int = weakMap.getValue("items")?items.length:0;
			for( i; i < len; i++ ){
				if( items[i] && items[i].getDispatcher().hasEventListener(DatasEvent.DATA_DONE) )
					items[i].getDispatcher().removeEventListener(DatasEvent.DATA_DONE, clickHandler);
			}
			super.removeFromStageHandler(evt);
		}
	}
}