package cn.royan.fl.interfaces.uis
{
	public interface IUiScrollerBase
	{
		function show(v:Boolean, h:Boolean):void;
		function setSize(cWidth:int, cHeight:int):void;
		function setContainerSize(cWidth:int, cHeight:int):void;
		function setType(type:int):void;
		function setThumbTexture(texture:Object):void;
		function setMinTexture(texture:Object):void;
		function setMaxTexture(texture:Object):void;
		function setBackgroundTextrue(texture:Object):void;
	}
}