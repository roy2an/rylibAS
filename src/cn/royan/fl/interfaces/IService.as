package cn.royan.fl.interfaces
{
	import flash.events.IEventDispatcher;
	
	public interface IService extends IEventDispatcher, IDispose
	{
		function sendRequest(url:String='', extra:*=null):void;
		function connect():void;
		function close():void;
		function get data():*;
		function get isServicing():Boolean;
	}
}