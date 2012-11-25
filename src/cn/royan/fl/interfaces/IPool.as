package cn.royan.fl.interfaces
{
	public interface IPool
	{
		function getInstance():*;
		function disposeInstance(instance:*):void;
		function dispose():void;
	}
}