package cn.royan.fl.interfaces.services
{
	import cn.royan.fl.interfaces.IDisposeBase;
	
	import flash.events.IEventDispatcher;
	
	public interface IServiceBase extends IEventDispatcher, IDisposeBase
	{
		function sendRequest(url:String='', extra:*=null):void;
		function setCallbacks(callbacks:Object):void;
		function connect():void;
		function close():void;
		function get data():*;
		function get isServicing():Boolean;
	}
}