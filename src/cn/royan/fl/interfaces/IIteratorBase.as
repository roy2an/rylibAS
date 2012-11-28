package cn.royan.fl.interfaces
{
	public interface IIteratorBase
	{
		function reset():void;
		function hasNext():Boolean;
		function next():Object;
	}
}