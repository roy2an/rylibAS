package cn.royan.fl.interfaces.uis
{
	public interface IUiStateBase
	{
		function setExclude(state:String,...args):void;
		function getExclude():Vector.<String>;
		function setInclude(state:String,...args):void;
		function getInclude():Vector.<String>;
	}
}