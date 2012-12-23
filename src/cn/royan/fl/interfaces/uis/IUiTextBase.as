package cn.royan.fl.interfaces.uis
{
	import flash.text.TextFormat;

	public interface IUiTextBase extends IUiBase
	{
		function setText(value:String):void;
		function appendText(value:String):void;
		function getText():String;
		
		function setHTMLText(value:String):void;
		function appendHTMLText(value:String):void;
		function getHTMLText():String;
		
		function setTextAlign(value:String):void;
		function setTextColor(value:uint):void;
		function setTextSize(value:int):void;
		
		function setEmbedFont(value:Boolean):void;
		
		function setFormat(value:TextFormat):void;
		function getFormat():TextFormat;
		function getDefaultFormat():TextFormat;
		
		function setScroll(sx:int=0, sy:int=0):void;
		function getScroll():Array;
		function getMaxScroll():Array;
		
		function setMultiLine(value:Boolean):void;
	}
}