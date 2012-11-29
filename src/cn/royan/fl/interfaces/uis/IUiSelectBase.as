package cn.royan.fl.interfaces.uis
{
	import flash.events.EventDispatcher;

	public interface IUiSelectBase
	{
		function setSelected(value:Boolean):void;
		function getSelected():Boolean;
		function getDispatcher():EventDispatcher;
	}
}