package cn.royan.fl.interfaces.uis
{
	public interface IUiScrollableBase
	{
		function setScrollerSize(cWidth:int, cHeight:int):void;
		function setScrollerType(type:int):void;
		function setScrollerThumbTexture(texture:Object):void;
		function setScrollerMinTexture(texture:Object):void;
		function setScrollerMaxTexture(texture:Object):void;
		function setScrollerBackgroundTextrue(texture:Object):void;
	}
}