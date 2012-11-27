package cn.royan.fl.interfaces
{
	import flash.utils.ByteArray;

	public interface IMessage
	{
		function writeMessageType(type:int):void;
		function writeMessageValue(type:*):void;
	}
}