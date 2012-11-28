package cn.royan.fl.interfaces.services
{
	import flash.events.IEventDispatcher;
	import cn.royan.fl.interfaces.IDisposeBase;
	
	public interface IServiceBase extends IEventDispatcher, IDisposeBase
	{
		function sendRequest(url:String='', extra:*=null):void;
		function connect():void;
		function close():void;
		function get data():*;
		function get isServicing():Boolean;
	}
}