package cn.royan.fl.interfaces.services
{
	import cn.royan.fl.interfaces.IDisposeBase;
	
	import flash.utils.IDataInput;

	public interface IServiceMessageBase extends IDisposeBase
	{
		function writeMessageType(type:int):void;
		function writeMessageValue(value:*):void;
		function writeMessageFromBytes(input:IDataInput):void;
		function readMessageType():int;
		function readMessageValue():*;
		function serialize():void;
	}
}