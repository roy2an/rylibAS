package cn.royan.fl.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import cn.royan.fl.bases.WeakMap;
	
	public class RoImage extends Sprite
	{
		protected var weakMap:WeakMap;
		
		public function RoImage(bmpd:BitmapData)
		{
			super();
			
			weakMap = new WeakMap();
			weakMap.add("bitmapdata", bmpd);
			
			if( stage ) addToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		protected function addToStageHandler(evt:Event = null):void
		{
			if( hasEventListener(Event.ADDED_TO_STAGE) )
				removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			
			var bmpd:BitmapData = weakMap.getValue("bitmapdata");
			if( bmpd )
				addChild(new Bitmap( bmpd ));
		}
		
		protected function removeFromStageHandler(evt:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
	}
}