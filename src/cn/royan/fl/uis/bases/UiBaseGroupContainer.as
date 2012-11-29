package cn.royan.fl.uis.bases
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiGroupBase;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	import cn.royan.fl.interfaces.uis.IUiBase;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class UiBaseGroupContainer extends UiBaseContainer implements IUiGroupBase
	{
		public static const ITEM_SELECTED:String = 'item_selected';
		
		protected var selectedItems:Vector.<IUiSelectBase>;
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiBaseGroupContainer()
		{
			super();
			
			selectedItems = new Vector.<IUiSelectBase>();
			
			values = [];
		}
		
		public function addGroupItem(item:*, key:*=null):void
		{
			if(item.getDispatcher() == null) return;
			
			item.setIsInGroup(true);
			item.getDispatcher().addEventListener(DatasEvent.DATA_DONE, clickHandler);
			
			selectedItems[key] = item;
			
			__weakMap.set("selectedItems" + uid + "_" + (selectedItems.length - 1), item);
			
			addItem(item);
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
		
		public function setIsMust(value:Boolean):void
		{
			isMust = value;
		}
		
		public function setIsMulti(value:Boolean):void
		{
			isMulti = value;
		}
		
		public function setMaxLen(value:int):void
		{
			maxLen = value;
		}
		
		protected function getKey(value:*):*
		{
			for( var i:* in selectedItems )
			{
				if( selectedItems[i] == value )
				{
					return selectedItems[i];
				}
			}
			return null;
		}
		
		protected function clickHandler(evt:DatasEvent):void
		{
			var key:* = getKey(evt.currentTarget);
			var giveUpKey:*;
			if(values.indexOf(key) == -1){
				if(!isMust){
					values.splice(values.indexOf(key), 1);
					selectedItems[key].setSelected(false);
				}
			}else{
				if( isMulti ){
					if( maxLen > values.length )
					{
						values.push(key);
					}else{
						giveUpKey = values.shift();
						if(selectedItems[giveUpKey])
							selectedItems[giveUpKey].setSelected(false);
						values.push(key);
						selectedItems[key].setSelected(true);
					}
				}else{
					giveUpKey = values.shift();
					if(selectedItems[giveUpKey])
						selectedItems[giveUpKey].setSelected(false);
					values = [key];
					selectedItems[key].setSelected(true);
				}
			}
		}
		
		override protected function removeFromStageHandler(evt:Event):void
		{
			var i:int = 0;
			var len:int = selectedItems.length;
			for( i; i < len; i++ ){
				if( selectedItems[i] && selectedItems[i].getDispatcher().hasEventListener(DatasEvent.DATA_DONE) )
					selectedItems[i].getDispatcher().removeEventListener(DatasEvent.DATA_DONE, clickHandler);
				
				__weakMap.clear("selectedItems" + uid + "_" + i);
			}
			super.removeFromStageHandler(evt);
		}
	}
}