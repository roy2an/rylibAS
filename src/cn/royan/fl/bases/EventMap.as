package cn.royan.fl.bases
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import cn.royan.fl.iterators.ArrayIterator;

	public class EventMap
	{
		//protected var eventDispatcher:EventDispatcher;
		protected var listeners:Array;
		
		public function EventMap(/*eventDispatcher:IEventDispatcher*/)
		{
			this.listeners = [];
			//this.eventDispatcher = eventDispatcher;
		}
		
		public function addListener(dispatcher:IEventDispatcher, type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			var param:ListenerParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			while(iterator.hasNext()){
				param = iterator.next() as ListenerParam;
				if( param.dispatcher == dispatcher &&
					param.type	== type &&
					param.listener == listener &&
					param.eventClass == eventClass &&
					param.useCapture == useCapture){
					return;
				}
			}
			
			var callback:Function = function(event:Event):void
				{
					routeEventToListener(event, listener, eventClass);
				}
				
			param = new ListenerParam();
			param.dispatcher = dispatcher;
			param.type		= type;
			param.listener	= listener;
			param.callback  = callback;
			param.eventClass= eventClass;
			param.useCapture= useCapture;
			
			listeners.push(param);
			dispatcher.addEventListener(type, callback, useCapture, priority, useWeakReference);
		}
		
		public function removeListener(dispatcher:IEventDispatcher, type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false):void
		{
			var param:ListenerParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			var i:int = listeners.length;
			while(i--){
				param = listeners[i] as ListenerParam;
				if( param.dispatcher == dispatcher &&
					param.type	== type &&
					param.listener == listener &&
					param.eventClass == eventClass &&
					param.useCapture == useCapture){
					param.dispatcher.removeEventListener(param.type, param.callback, param.useCapture);
					listeners.splice(i, 1);
					return;
				}
			}
		}
		
		public function removeListeners():void
		{
			var param:ListenerParam;
			var iterator:ArrayIterator = new ArrayIterator(listeners);
			while(iterator.hasNext()){
				param = iterator.next() as ListenerParam;
				param.dispatcher.removeEventListener(param.type, param.callback, param.useCapture);
			}
		}
		
		public function routeEventToListener(event:Event, listener:Function, originalEventClass:Class):void
		{
			if (event is originalEventClass)
			{
				listener(event);
			}
		}
	}
}
import flash.events.IEventDispatcher;

class ListenerParam{
	public var dispatcher:IEventDispatcher;
	public var type:String;
	public var listener:Function;
	public var callback:Function;
	public var eventClass:Class;
	public var useCapture:Boolean;
}