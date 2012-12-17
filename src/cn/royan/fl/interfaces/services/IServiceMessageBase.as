package cn.royan.fl.interfaces.services
{
	import flash.utils.IDataInput;

	public interface IServiceMessageBase
	{
		function writeMessageType(type:int):void;
		function writeMessageValue(value:*):void;
		function writeMessageFromBytes(input:IDataInput):void;
		function serialize():void;
	}
}