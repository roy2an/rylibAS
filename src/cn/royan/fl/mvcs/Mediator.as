package cn.royan.fl.mvcs
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import cn.royan.fl.bases.mvcs.CommandMap;
	import cn.royan.fl.bases.mvcs.EventMap;
	import cn.royan.fl.bases.WeakMap;

	public class Mediator
	{
		protected var weakMap:WeakMap;
		protected var eventMap:EventMap;
		protected var commandMap:CommandMap;
		protected var view:View;
		protected var dispatcher:EventDispatcher
		
		public function Mediator(view:View)
		{
			this.dispatcher = new EventDispatcher();
			
			this.view = view;
			this.weakMap = new WeakMap();
			this.eventMap = new EventMap();
			this.commandMap = new CommandMap(dispatcher);
		}
		
		protected function addViewListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			eventMap.addListener(view, type, listener, eventClass, useCapture, priority, useWeakReference);
		}
		
		protected function removeViewListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false):void
		{
			eventMap.removeListener(view, type, listener, eventClass, useCapture );
		}
		
		protected function removeViewListeners():void
		{
			eventMap.removeListeners();
		}
		
		protected function addCommandListener(type:String, eventClass:Class,commandClass:Class):void
		{
			commandMap.addListener(type, eventClass, commandClass);
		}
		
		protected function removeCommandListener(type:String, eventClass:Class, commandClass:Class):void
		{
			commandMap.removeListener(type, eventClass, commandClass);
		}
		
		protected function removeCommandListeners():void
		{
			commandMap.removeListeners();
		}
		
		protected function sendCommandEvent(evt:Event):void
		{
			dispatcher.dispatchEvent(evt);
		}
	}
}