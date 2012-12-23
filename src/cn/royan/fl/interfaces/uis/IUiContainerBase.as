package cn.royan.fl.interfaces.uis
{
	import cn.royan.fl.interfaces.IDisposeBase;

	public interface IUiContainerBase extends IDisposeBase
	{
		function addItem(item:IUiBase):void;
		function addItemAt(item:IUiBase, index:int):void;
		
		function removeItem(item:IUiBase):void;
		function removeItemAt(index:int):void;
		function removeAllItems():void;
		
		function getItemAt(index:int):IUiBase;
		function getIndexByItem(item:IUiBase):int;
		function getItems():Vector.<IUiBase>;
		
		function setHorizontalAlign(value:int):void;
		function setVerticalAlign(value:int):void;
		function setGaps(gapX:int, gapY:int):void;
		function setMargins(left:int, top:int, right:int, bottom:int):void;
	}
}