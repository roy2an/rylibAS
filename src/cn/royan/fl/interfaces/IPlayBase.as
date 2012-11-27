package cn.royan.fl.interfaces
{
	public interface IPlayBase extends IDispose
	{
		function getIn():void;
		function getOut():void;
		function goTo(to:int):void;
		function goFromTo(from:int,to:int):void;
	}
}