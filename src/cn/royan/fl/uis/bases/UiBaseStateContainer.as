package cn.royan.fl.uis.bases
{
	import cn.royan.fl.interfaces.uis.IUiStateBase;
	import cn.royan.fl.interfaces.uis.IUiStateContainerBase;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	public class UiBaseStateContainer extends InteractiveUiBase implements IUiStateContainerBase
	{
		protected var states:Vector.<String>;
		protected var current:String;
		
		public function UiBaseStateContainer(texture:BitmapData = null)
		{
			super(texture);
			
			states = new Vector.<String>();
		}
		
		public function setState(value:String):void
		{
			if( states.indexOf(value) == -1 )
				return;
			
			current = value;
			var i:int;
			for(i = 0; i < numChildren; i++){
				if( getChildAt(i) is IUiStateBase ){
					var item:IUiStateBase = IUiStateBase(getChildAt(i));
					if( item.getInclude() )
						if( item.getInclude().indexOf(current) != -1 ){
							(item as DisplayObject).visible = true;
						}else{
							(item as DisplayObject).visible = false;
						}
					
					if( item.getExclude() )
						if( item.getExclude().indexOf(current) != -1 ){
							(item as DisplayObject).visible = false;
						}else{
							(item as DisplayObject).visible = true;
						}
				}
			}
		}
		
		public function getState():String
		{
			return current;
		}
	}
}