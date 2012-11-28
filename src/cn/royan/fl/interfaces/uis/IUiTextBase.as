package cn.royan.fl.interfaces.uis
{
	import flash.text.TextFormat;

	public interface IUiTextBase extends IUiBase
	{
		function setText(value:String):void;
		function getText():String;
		function setFormat(value:TextFormat):void;
		function getFormat():TextFormat;
		function getDefaultFormat():TextFormat;
	}
}