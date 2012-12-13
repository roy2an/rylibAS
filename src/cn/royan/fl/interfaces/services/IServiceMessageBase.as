package cn.royan.fl.interfaces.services
{
	import flash.utils.ByteArray;

	public interface IServiceMessageBase
	{
		function writeMessageType(type:int):void;
		function writeMessageValue(type:*):void;
		function serialize():void;
	}
}