package cn.royan.fl.uis.bases
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.interfaces.uis.IUiGroupBase;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class UiBaseGroupContainer extends UiBaseContainer implements IUiGroupBase
	{
		public static const ITEM_SELECTED:String = 'item_selected';
		
		protected var keys:Dictionary;
		
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiBaseGroupContainer()
		{
			super();
			
			keys = new Dictionary(true);
			values = [];
		}
		
		public function addGroupItem(item:IUiSelectBase, key:*):void
		{
			if(item.getDispatcher() == null) return;
			
			item.setIsInGroup(true);
			item.getDispatcher().addEventListener(DatasEvent.DATA_DONE, clickHandler);
			
			keys[item] = key;
			
			addItem(item);
		}
		
		public function getValues():Array
		{
			return values;
		}
		
		public function setValues(array:Array):void
		{
			var i:int;
			for(i = 0; i< values.length; i++){
				getValue(values[i]).setSelected(false);
			}
			values = array;
			for(i = 0; i < array.length; i++){
				getValue(array[i]).setSelected(true);
			}
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
			return keys[value];
		}
		
		protected function getValue(key:*):IUiSelectBase
		{
			for (var item:* in keys)
			{
				if( keys[item] == key )
				{
					return item;
				}
			}
			return null;
		}
		
		protected function clickHandler(evt:DatasEvent):void
		{
			var key:* = getKey(evt.currentTarget);
			var giveUpKey:*;
			if(values.indexOf(key) == -1){//未找到
				if( isMulti ){
					if( maxLen > values.length ){
						values.push(key);
					}else{
						giveUpKey = values.shift();
						if(getValue(giveUpKey))
							getValue(giveUpKey).setSelected(false);
						values.push(key);
						getValue(key).setSelected(true);
					}
				}else{
					giveUpKey = values.shift();
					if(getValue(giveUpKey))
						getValue(giveUpKey).setSelected(false);
					values.push(key);//values = [key];
					getValue(key).setSelected(true);
				}
			}else{//找到(取消)
				if(!isMust){//不是必须的
					values.splice(values.indexOf(key), 1);
					getValue(key).setSelected(false);
				}
			}
			
			if( callbacks && callbacks["select"] ) callbacks["select"](values);
		}
	}
}