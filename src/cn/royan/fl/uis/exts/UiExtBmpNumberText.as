package cn.royan.fl.uis.exts
{
	import cn.royan.fl.uis.bases.UiBaseBmpdMovieClip;
	import cn.royan.fl.uis.bases.UiBaseContainer;
	
	import flash.display.BitmapData;
	
	public class UiExtBmpNumberText extends UiBaseContainer
	{
		private var isAlwaysShow:Boolean;
		private var num:int;
		
		public function UiExtBmpNumberText(texture:BitmapData, length:int = 1)
		{
			super();
			
			var i:int;
			var instance:UiBaseBmpdMovieClip = new UiBaseBmpdMovieClip(texture, 10, false, 10, 1, 10);
			
			for( i = 0; i < length; i++ ){
				(addItem(instance.clone()) as UiBaseBmpdMovieClip).visible = isAlwaysShow;
			}
		}
		
		public function setIsAlwaysShow(value:Boolean):void
		{
			isAlwaysShow = value;
		}
		
		public function setValue(value:int):void
		{
			var i:int;
			var j:int;
			for( i = 0; i < items.length; i++){
				(getItemAt(i) as UiBaseBmpdMovieClip).jumpTo(1);
				(getItemAt(i) as UiBaseBmpdMovieClip).visible = isAlwaysShow;
			}
			num = value;
			
			var str:String = value.toString();
			for( i = str.length - 1, j = 1; i >= 0, j <= Math.min(items.length, str.length); i--, j++){
				(getItemAt(items.length - j) as UiBaseBmpdMovieClip).visible = true;
				(getItemAt(items.length - j) as UiBaseBmpdMovieClip).jumpTo(1 + parseInt(str.charAt(i)));
			}
			
			draw();
		}
		
		public function getValue():int
		{
			return num;
		}
	}
}