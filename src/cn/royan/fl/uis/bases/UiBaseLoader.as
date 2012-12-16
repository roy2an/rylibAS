package cn.royan.fl.uis.bases
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.uis.InteractiveUiBase;
	import cn.royan.fl.uis.UninteractiveUiBase;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	public class UiBaseLoader extends InteractiveUiBase
	{
		protected var progressBar:UninteractiveUiBase;
		protected var progressTxt:UiBaseText;
		protected var currentFileName:UiBaseText;
		protected var loaderData:EventDispatcher;
		
		public function UiBaseLoader(loader:EventDispatcher=null, texture:BitmapData=null)
		{
			super(texture);
			
			if( loader ){
				loaderData = loader;
				loaderData.addEventListener(DatasEvent.DATA_DOING, loaderPorgressHandler);
				loaderData.addEventListener(DatasEvent.DATA_DONE, loaderCompleteHandler);
			}
			
			progressTxt = PoolMap.getInstanceByType(UiBaseText);
			progressTxt.setText("0%");
			progressTxt.setSize(50, 20);
			addChild(progressTxt);
			
			progressBar = PoolMap.getInstanceByType(UninteractiveUiBase);
			progressBar.setBackgroundColors([0xFF0000]);
			progressBar.setSize(100, 10);
			addChild(progressBar);
			
			currentFileName = PoolMap.getInstanceByType(UiBaseText);
			currentFileName.setSize(100, 20);
			addChild(currentFileName);
		}
		
		public function setLoaderData(loader:EventDispatcher):void
		{
			loaderData = loader;
			loaderData.addEventListener(DatasEvent.DATA_DOING, loaderPorgressHandler);
			loaderData.addEventListener(DatasEvent.DATA_DONE, loaderCompleteHandler);
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
				PoolMap.disposeInstance(loaderData);
			
			if( progressTxt )
				PoolMap.disposeInstance(progressTxt);
			
			if( progressBar )
				PoolMap.disposeInstance(progressBar);
			
			if( currentFileName )
				PoolMap.disposeInstance(currentFileName);
			
		}
	}
}