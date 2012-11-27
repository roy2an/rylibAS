package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.IUiBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
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
		
		public function UiBaseContainer()
		{
			items = new Vector.<IUiBase>();
			
			weakMap.add("items", items);
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
		
		override public function draw():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var lineHeight:int = 0;
			
			for each(var item:IUiBase in items)
			{
				var size:Array = item.getSize();
				
				if( size[0] + offsetX > getSize()[0] )
				{
					offsetX = 0;
					offsetY += lineHeight;
				}
				
				item.setPosition(offsetX, offsetY);
				
				offsetX += item.getSize()[0];
				lineHeight = Math.max(item.getSize()[1], lineHeight);
			}
		}
		
		override public function dispose():void
		{
			var i:int = 0;
			var len:int = weakMap.getValue("items")?items.length:0;
			for( i; i < len; i++ ){
				items[i].dispose();
				items[i] = null;
				delete items[i];
			}
			
			items = null;
		}
	}
}