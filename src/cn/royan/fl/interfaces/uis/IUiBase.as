package cn.royan.fl.interfaces.uis
{
	import cn.royan.fl.interfaces.IDisposeBase;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;

	public interface IUiBase extends IDisposeBase
	{
		function draw():void;
		function getDefaultBackgroundColors():Array;
		function getDefaultBackgroundAlphas():Array;
		function setBackgroundColors(value:Array):void;
		function getBackgroundColors():Array;
		function setBackgroundAlphas(value:Array):void;
		function getBackgroundAlphas():Array;
		function setSize(cWidth:int, cHeight:int):void;
		function getSize():Array;
		function setPosition(cX:int, cY:int):void;
		function getPosition():Array;
		function setTexture(value:BitmapData):void;
		function getTexture():BitmapData;
		function getDispatcher():EventDispatcher;
//		function setEnabled(value:Boolean):void;
	}
}