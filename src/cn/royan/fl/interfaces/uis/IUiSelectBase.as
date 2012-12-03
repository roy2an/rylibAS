package cn.royan.fl.interfaces.uis
{
	import cn.royan.fl.interfaces.IDisposeBase;
	
	import flash.events.EventDispatcher;

	public interface IUiSelectBase extends IDisposeBase
	{
		function setSelected(value:Boolean):void;
		function getSelected():Boolean;
		function getDispatcher():EventDispatcher;
	}
}