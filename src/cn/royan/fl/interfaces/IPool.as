package cn.royan.fl.interfaces
{
	public interface IPool extends IDispose
	{
		function getInstance():*;
		function disposeInstance(instance:*):void;
	}
}