package cn.royan.fl.interfaces.uis
{
	public interface IUiGroupBase
	{
		function addGroupItem(item:IUiSelectBase, key:*):void;
		function getValues():Array;
		function setIsMust(value:Boolean):void;
		function setIsMulti(value:Boolean):void;
		function setMaxLen(value:int):void;
	}
}