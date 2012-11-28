package cn.royan.fl.interfaces
{

	public interface IPoolBase extends IDisposeBase
	{
		function getInstance():*;
		function disposeInstance(instance:*):void;
	}
}