package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.interfaces.uis.IUiContainerBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.DisplayObject;
	
	public class UiBaseContainer extends InteractiveUiBase implements IUiContainerBase
	{
		public static const LEFT:uint = 1;
		public static const RIGHT:uint = 2;
		public static const CENTER:uint = 3;
		
		public static const TOP:uint = 1;
		public static const BOTTOM:uint = 2;
		public static const MIDDLE:uint = 3;
		
		protected var items:Vector.<IUiBase>;
		protected var horizontalAlign:uint;
		protected var verticalAlign:uint;
		protected var gaps:Object;
		protected var margins:Object;
		protected var rows:Array;
		protected var itemsWidth:int;
		protected var itemsHeight:int;
		
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
		
		public function addItemAt(item:IUiBase, index:int):void
		{
			var start:Vector.<IUiBase> = items.slice(0, index);
			var end:Vector.<IUiBase> = items.slice(index);
			start.push(item);
			
			items = start.concat(end);
			
			addChildAt( item as DisplayObject, index );
			draw();
		}
		
		public function removeItem(item:IUiBase):void
		{
			if( contains(item as DisplayObject) ) removeChild(item as DisplayObject);
			items.splice( items.indexOf(item), 1);
			draw();
		}
		
		public function removeItemAt(index:int):void
		{
			if( index < 0 || index >= items.length ) return;
			
			if( contains( items[index] as DisplayObject ) ) 
				removeChild(items[index] as DisplayObject);
			items.splice( index, 1);
			
			draw();
		}
		
		public function removeAllItems():void
		{
			while( items.length ){
				removeChild(items.shift());
			}
		}
		
		public function getIndexByItem(item:IUiBase):int
		{
			return items.indexOf(item);
		}
		
		public function getItemAt(index:int):IUiBase
		{
			if( index < 0 || index >= items.length ) return null;
			return items[index];
		}
		
		public function getItems():Vector.<IUiBase>
		{
			return items;
		}
		
		public function setHorizontalAlign(value:int):void
		{
			horizontalAlign = value;
			draw();
		}
		
		public function setVerticalAlign(value:int):void
		{
			verticalAlign = value;
			draw();
		}
		
		public function setGaps(gapX:int, gapY:int):void
		{
			gaps = {x:gapX, y:gapY};
		}
		
		public function setMargins(left:int, top:int, right:int, bottom:int):void
		{
			margins = {l:left,t:top,r:right,b:bottom};
		}
		
		override public function draw():void
		{
			fillRowHandler();
			drawRowHandler();
		}
		
		protected function fillRowHandler():void
		{
			var rowW:int	= 0;
			var rowH:int	= 0;
			
			var marginT:int = margins?margins['t']:0;
			var marginR:int = margins?margins['r']:0;
			var marginB:int = margins?margins['b']:0;
			var marginL:int = margins?margins['l']:0;
			
			var gapX:int = gaps?gaps['x']:0;
			var gapY:int = gaps?gaps['y']:0;
			
			itemsWidth = 0;
			itemsHeight = 0;
			
			rows = [];
			
			var i:int;
			var itemNumber:int;
			var rowNumber:int;
			for ( i = 0; i < items.length; i++ ) {
				
				var item:IUiBase = items[i] as IUiBase;
				if ( rowW + ( (i > 0 ? 1:0) * gapX + item.getSize()[0] ) > containerWidth - marginL - marginR ) {
					//prev row end
					rows.push( { width: rowW, height: rowH, length:itemNumber } );
					itemsWidth = Math.max( itemsWidth, rowW );
					itemsHeight += (rowNumber > 0 ? 1:0) * gapY + rowH;
					rowNumber++;
					//next row start
					rowW = item.getSize()[0];
					rowH = item.getSize()[1];
					
					itemNumber = 1;
				}else {
					rowW += ( (i > 0 ? 1:0) * gapX + item.getSize()[0]);
					rowH = Math.max( rowH, item.getSize()[1] );
					itemNumber++;
				}
			}
			rows.push( { width: rowW, height: rowH, length:itemNumber } );
			
			itemsWidth = Math.max( itemsWidth, rowW );
			itemsHeight += (rowNumber > 0 ? 1:0) * gapY + rowH;
		}
		
		protected function drawRowHandler():void
		{
			var rowW:int	= 0;
			var rowH:int	= 0;
			
			var marginT:int = margins?margins['t']:0;
			var marginR:int = margins?margins['r']:0;
			var marginB:int = margins?margins['b']:0;
			var marginL:int = margins?margins['l']:0;
			
			var gapX:int = gaps?gaps['x']:0;
			var gapY:int = gaps?gaps['y']:0;
			
			var offsetX:int;
			var offsetY:int;
			
			switch( verticalAlign ) {
				case BOTTOM:
					offsetY = containerHeight - marginB - itemsHeight;
					break;
				case MIDDLE:
					offsetY = (containerHeight - itemsHeight) / 2;
					break;
				default:
					offsetY = marginT;
			}
			
			var i:int;
			var z:int;
			for ( i = 0; i < rows.length; i++ ) {
				
				switch( horizontalAlign ) {
					case RIGHT:
						offsetX = containerWidth - marginR - rows[i].width;
						break;
					case CENTER:
						offsetX = (containerWidth - rows[i].width) / 2;
						break;
					default:
						offsetX = marginL;
				}
				
				var j:int;
				for( j = 0; j < rows[i].length; j++ ){
					items[z].setPosition( offsetX, offsetY );
					offsetX += items[z].getSize()[0] + gapX;
					z++;
				}
				offsetY += rows[i].height + gapY;
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