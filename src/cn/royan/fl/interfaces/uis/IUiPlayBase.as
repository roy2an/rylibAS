package cn.royan.fl.interfaces.uis
{
	import cn.royan.fl.interfaces.IDisposeBase;

	public interface IUiPlayBase extends IDisposeBase
	{
		function getIn():void;
		function getOut():void;
		function goTo(to:int):void;
		function goFromTo(from:int,to:int):void;
	}
}