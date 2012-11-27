package cn.royan.fl.mvcs
{
	import flash.display.DisplayObjectContainer;
	
	import cn.royan.fl.bases.EventMap;
	import cn.royan.fl.events.DatasEvent;

	public class View extends DisplayObjectContainer 
	{
		protected var eventMap:EventMap;
		protected var model:Model;
		
		public function View(model:Model = null)
		{
			if( model )
			{
				this.model = model;
				this.model.addEventListener(DatasEvent.DATA_CHANGE, update);
			}
		}
		
		public function setModel(model:Model):void
		{
			this.model = model;
			this.model.addEventListener(DatasEvent.DATA_CHANGE, update);
		}
		
		protected function update(evt:DatasEvent = null):void
		{
			
		}
		
		protected function addModelListener(type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			
		}
		
		protected function removeModelListener():void
		{
			
		}
	}
}