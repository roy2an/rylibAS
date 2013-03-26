package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiGroupBase;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;

	public class UiEmbedGroupContainer extends UiEmbedSprite// implements IUiGroupBase
	{
		protected var items:Vector.<IUiSelectBase>;
		protected var isMulti:Boolean;
		protected var isMust:Boolean;
		protected var maxLen:uint;
		protected var values:Array;
		
		public function UiEmbedGroupContainer()
		{
			super();
			
			items = new Vector.<IUiSelectBase>();
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
			for( var i:* in items )
			{
				if( items[i] == value )
				{
					return items[i];
				}
			}
			return null;
		}
		
		protected function itemClickHandler(evt:DatasEvent):void
		{
			var key:* = getKey(evt.currentTarget);
			var giveUpKey:*;
			if(values.indexOf(key) == -1){
				if(!isMust){
					values.splice(values.indexOf(key), 1);
					items[key].setSelected(false);
				}
			}else{
				if( isMulti ){
					if( maxLen > values.length )
					{
						values.push(key);
					}else{
						giveUpKey = values.shift();
						if(items[giveUpKey])
							items[giveUpKey].setSelected(false);
						values.push(key);
						items[key].setSelected(true);
					}
				}else{
					giveUpKey = values.shift();
					if(items[giveUpKey])
						items[giveUpKey].setSelected(false);
					values = [key];
					items[key].setSelected(true);
				}
			}
		}
	}
}