package cn.royan.fl.bases
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import cn.royan.fl.iterators.ArrayIterator;
	import cn.royan.fl.mvcs.Command;

	public class CommandMap
	{
		protected var listeners:Array;
		protected var dispatcher:IEventDispatcher;
		
		public function CommandMap(dispatcher:IEventDispatcher)
		{
			this.listeners = [];
			this.dispatcher = dispatcher;
		}
		
		public function addListener(type:String, eventClass:Class, commandClass:Class):void
		{
			var param:CommandParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			while(iterator.hasNext()){
				param = iterator.next() as CommandParam;
				if( param.dispatcher == dispatcher &&
					param.type	== type &&
					param.commandClass == commandClass ){
					return;
				}
			}
			
			var callback:Function = function(event:Event):void
			{
				routeCommandToListener(event, commandClass, eventClass);
			}
			
			param = new CommandParam();
			param.dispatcher = dispatcher;
			param.type		= type;
			param.callback  = callback;
			param.eventClass = eventClass;
			param.commandClass	= commandClass;
			
			listeners.push(param);
			dispatcher.addEventListener(type, callback, false, 0, true);
		}
		
		public function removeListener(type:String, eventClass:Class, commandClass:Class):void
		{
			var param:CommandParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			var i:int = listeners.length;
			while(i--){
				param = listeners[i] as CommandParam;
				if( param.dispatcher == dispatcher &&
					param.type	== type &&
					param.eventClass == eventClass &&
					param.commandClass == commandClass ){
					param.dispatcher.removeEventListener(param.type, param.callback);
					listeners.splice(i, 1);
					return;
				}
			}
		}
		
		public function removeListeners():void
		{
			var param:CommandParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			while(iterator.hasNext()){
				param = iterator.next() as CommandParam;
				param.dispatcher.removeEventListener(param.type, param.callback);
			}
		}
		
		public function routeCommandToListener(event:Event, originalEventClass:Class, commandClass:Class):void
		{
			if (event is originalEventClass)
			{
				var instance:Command = new commandClass();
					instance.execute();
			}
		}
	}
}
import flash.events.IEventDispatcher;

class CommandParam{
	public var dispatcher:IEventDispatcher;
	public var type:String;
	public var callback:Function;
	public var eventClass:Class;
	public var commandClass:Class;
}