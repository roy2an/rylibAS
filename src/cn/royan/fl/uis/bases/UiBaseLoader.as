package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolBase;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	public class UiBaseLoader extends InteractiveUiBase
	{
		protected var progressBar:UninteractiveUiBase;
		protected var progressTxt:UiBaseText;
		protected var currentFileName:UiBaseText;
		protected var loaderData:EventDispatcher;
		
		public function UiBaseLoader(loaderData:EventDispatcher, texture:BitmapData=null)
		{
			super(texture);
			
			uid = SystemUtils.createObjectUID();
			
			loaderData.addEventListener(DatasEvent.DATA_DOING, loaderPorgressHandler);
			loaderData.addEventListener(DatasEvent.DATA_DONE, loaderCompleteHandler);
			
			progressTxt = PoolBase.getInstanceByType(UiBaseText);
			progressTxt.setText("0%");
			progressTxt.setSize(50, 20);
			addChild(progressTxt);
			
			progressBar = PoolBase.getInstanceByType(UninteractiveUiBase);
			progressBar.setBackgroundColors([0xFF0000]);
			progressBar.setSize(100, 10);
			addChild(progressBar);
			
			currentFileName = PoolBase.getInstanceByType(UiBaseText);
			currentFileName.setSize(100, 20);
			addChild(currentFileName);
		}
		
		public function setFileName(fileName:String, desp:String):void
		{
			currentFileName.setText(fileName +"\n" + desp);
		}
		
		protected function loaderPorgressHandler(evt:DatasEvent):void
		{
			progressTxt.setText( int( evt.params['loaded'] / evt.params['total'] * 100 ) + "%" );
			progressBar.scaleX = evt.params['loaded'] / evt.params['total'];
		}
		
		protected function loaderCompleteHandler(evt:DatasEvent):void
		{
			progressTxt.setText("100%");
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if( loaderData )
				PoolBase.disposeInstance(loaderData);
			
			if( progressTxt )
				PoolBase.disposeInstance(progressTxt);
			
			if( progressBar )
				PoolBase.disposeInstance(progressBar);
			
			if( currentFileName )
				PoolBase.disposeInstance(currentFileName);
			
		}
	}
}