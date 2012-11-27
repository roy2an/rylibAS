package cn.royan.fl.interfaces
{
	public interface IIterator
	{
		function reset():void;
		function hasNext():Boolean;
		function next():Object;
	}
}