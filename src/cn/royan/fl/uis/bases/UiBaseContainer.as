package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.DisplayObject;
	
	public class UiBaseContainer extends InteractiveUiBase
	{
		public static const LEFT:uint = 1;
		public static const RIGHT:uint = 2;
		public static const CNETER:uint = 3;
		
		public static const TOP:uint = 1;
		public static const BOTTOM:uint = 2;
		public static const MIDDLE:uint = 3;
		
		protected var items:Vector.<IUiBase>;
		protected var horizontalAlign:uint;
		protected var verticalAlign:uint;
		protected var gaps:Object;
		protected var margins:Object;
		
		public function UiBaseContainer()
		{
			items = new Vector.<IUiBase>();
		}
		
		public function addItem(item:IUiBase):void
		{
			items.push(item);
			
			addChild(item as DisplayObject);
			draw();
		}
		
		public function setHorizontalAlign(value:uint):void
		{
			horizontalAlign = value;
			draw();
		}
		
		public function setVerticalAlign(value:int):void
		{
			verticalAlign = value;
			draw();
		}
		
		public function getItems():Vector.<IUiBase>
		{
			return items;
		}
		
		public function getIndexByItem(item:IUiBase):int
		{
			return items.indexOf(item);
		}
		
		public function getItemByIndex(index:uint):IUiBase
		{
			return items[index];
		}
		
		public function setGaps(gapX:int, gapY:int):void
		{
			gaps = {x:gapX, y:gapY};
		}
		
		public function setMargin(left:int, top:int, right:int, bottom:int):void
		{
			margins = {l:left,t:top,r:right,b:bottom};
		}
		
		override public function draw():void
		{
			var offsetX:int = margins?margins['l']:0;
			var offsetY:int = margins?margins['t']:0;
			var lineHeight:int = 0;
			
			for each(var item:IUiBase in items)
			{
				var size:Array = item.getSize();
				
				if( size[0] + offsetX + (gaps?gaps['x']:0) > getSize()[0] )
				{
					offsetX = margins?margins['l']:0;
					offsetY += lineHeight + (gaps?gaps['y']:0);
				}
				
				item.setPosition(offsetX, offsetY);
				
				offsetX += item.getSize()[0] + (gaps?gaps['x']:0);
				lineHeight = Math.max(item.getSize()[1], lineHeight);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			var i:int = 0;
			var len:int = items.length;
			for( i; i < len; i++ ){
				items[i].dispose();
				delete items[i];
			}
			
			items = null;
		}
	}
}