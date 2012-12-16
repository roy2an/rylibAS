package cn.royan.fl.interfaces.services
{
	public interface IServiceMessageBase
	{
		function writeMessageType(type:int):void;
		function writeMessageValue(type:*):void;
		function serialize():void;
	}
}