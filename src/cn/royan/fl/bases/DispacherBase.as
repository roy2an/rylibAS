package cn.royan.fl.bases
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class DispacherBase extends EventDispatcher
	{
		protected var evtListenerType:Array;
		protected var evtListenerDirectory:Array
		
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void 
		{
			if ( evtListenerDirectory == null ) {
				evtListenerDirectory = [];
				evtListenerType = [];
			}
			var dir:Dictionary = new Dictionary();
			dir[ type ] = listener;
			evtListenerDirectory.push( dir );
			evtListenerType.push( type );
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void 
		{
			super.removeEventListener(type, listener, useCapture);
			if ( evtListenerDirectory != null ) {
				for ( var i:int = 0; i < evtListenerDirectory.length; i++ ) {
					var dir:Dictionary = evtListenerDirectory[i];
					if ( dir[ type ] == null ) {
						continue;
					}else {
						if ( dir[ type ] != listener ) {
							continue
						}else {
							evtListenerType.splice( i, 1 );
							evtListenerDirectory.splice( i, 1 );
							delete dir[ type ];
							dir = null;
							break;
						}
					}
				}
			}
		}
		
		public function removeAllEventListener():void
		{
			if ( evtListenerType == null || evtListenerType.length == 0)
				return;
			for ( var i:int = 0; i < evtListenerType.length; i++)
			{
				var type:String = evtListenerType[i];
				var dic:Dictionary = evtListenerDirectory[i];
				var fun:Function = dic[ type ];
				removeEventListener( type, fun );
			}
		}
	}
}