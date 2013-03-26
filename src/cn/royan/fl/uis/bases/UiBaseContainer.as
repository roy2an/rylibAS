package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.uis.IUiBase;
	import cn.royan.fl.interfaces.uis.IUiContainerBase;
	import cn.royan.fl.interfaces.uis.IUiScrollableBase;
	import cn.royan.fl.interfaces.uis.IUiStateBase;
	import cn.royan.fl.interfaces.uis.IUiStateContainerBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class UiBaseContainer extends InteractiveUiBase implements IUiContainerBase, IUiStateContainerBase, IUiScrollableBase
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
		
		protected var container:InteractiveUiBase;
		protected var scroller:UiBaseScroller;
		
		protected var states:Vector.<String>;
		protected var current:String;
		
		public function UiBaseContainer(texture:BitmapData = null)
		{
			super(texture);
			
			items = new Vector.<IUiBase>();
			states = new Vector.<String>();
			
			container = new InteractiveUiBase();
			addChild(container);
			
			scroller = new UiBaseScroller(container);
			
			setBackgroundAlphas([0]);
		}
		
		public function addItem(item:IUiBase):IUiBase
		{
			items.push(item);
			
			container.addChild(item as DisplayObject);
			draw();
			
			return item;
		}
		
		public function addItemAt(item:IUiBase, index:int):IUiBase
		{
			var start:Vector.<IUiBase> = items.slice(0, index);
			var end:Vector.<IUiBase> = items.slice(index);
			start.push(item);
			
			items = start.concat(end);
			
			container.addChildAt( item as DisplayObject, index );
			draw();
			
			return item;
		}
		
		public function removeItem(item:IUiBase):IUiBase
		{
			if( container.contains(item as DisplayObject) ) container.removeChild(item as DisplayObject);
			items.splice( items.indexOf(item), 1);
			draw();
			
			return item;
		}
		
		public function removeItemAt(index:int):IUiBase
		{
			if( index < 0 || index >= items.length ) return null;
			
			var item:IUiBase = items[index];
			return removeItem(item);
		}
		
		public function removeAllItems():void
		{
			while( items.length ){
				container.removeChild(items.shift());
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
		
		public function setState(value:String):void
		{
			if( states.indexOf(value) == -1 )
				return;
			
			current = value;
			
			var i:int;
			for(i = 0; i < numChildren; i++){
				if( getChildAt(i) is IUiStateBase ){
					var item:IUiStateBase = IUiStateBase(getChildAt(i));
					if( item.getInclude().indexOf(current) != -1 ){
						(item as DisplayObject).visible = true;
					}
					if( item.getExclude().indexOf(current) != -1 ){
						(item as DisplayObject).visible = false;
					}
				}
			}
		}
		
		public function getState():String
		{
			return current;
		}
		
		public function setScrollerSize(cWidth:int, cHeight:int):void
		{
			scroller.setSize(cWidth, cHeight);
		}
		
		public function setScrollerType(type:int):void
		{
			scroller.setType(type);
		}
		
		public function setScrollerThumbTexture(texture:Object):void
		{
			scroller.setThumbTexture(texture);
		}
		
		public function setScrollerMinTexture(texture:Object):void
		{
			scroller.setMinTexture(texture);
		}
		
		public function setScrollerMaxTexture(texture:Object):void
		{
			scroller.setMaxTexture(texture);
		}
		
		public function setScrollerBackgroundTextrue(texture:Object):void
		{
			scroller.setBackgroundTextrue(texture);
		}
		
		override public function setSize(cWidth:int, cHeight:int):void
		{
			super.setSize(cWidth, cHeight);
			
			if( scroller ) scroller.setContainerSize(cWidth, cHeight);
		}
		
		override public function draw():void
		{
			super.draw();
			
			if( items ){
				fillRowHandler();
				drawRowHandler();
			}
			
			if( scroller ){
				scroller.show(containerHeight < height, containerWidth < width);
			}
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
					item.setPosition(0, 0);
				if ( !(item as DisplayObject).visible ) continue;
				
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
				
				for ( j = 0; j < rows[i].length; ) {
					if ( !(items[z] as DisplayObject).visible ) {
						z++;
						continue;
					}
					
					items[z].setPosition( offsetX, offsetY );
					offsetX += items[z].getSize()[0] + gapX;
					z++;
					j++;
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