package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.uis.InteractiveUiBase;
	
	import flash.events.EventDispatcher;
	import flash.text.TextField;

	public class UiEmbedLoader extends UiEmbedSprite
	{
		protected var loaderData:EventDispatcher;
		protected var currentFileName:TextField;
		protected var progressTxt:TextField;
		protected var progressBar:InteractiveUiBase;
		
		public function UiEmbedLoader(loader:EventDispatcher = null)
		{
			if( loader ) setLoaderData( loader );
			progressBar = getChildByName("__progress") as InteractiveUiBase;
			progressTxt = getChildByName("__progressTxt") as TextField;
			currentFileName = getChildByName("__currentFile") as TextField;
		}
		
		public function setLoaderData(loader:EventDispatcher):void
		{
			loaderData = loader;
			loaderData.addEventListener(DatasEvent.DATA_DOING, loaderPorgressHandler);
			loaderData.addEventListener(DatasEvent.DATA_DONE, loaderCompleteHandler);
		}
		
		public function setFileName(fileName:String, desp:String):void
		{
			
		}
		
		protected function loaderPorgressHandler(evt:DatasEvent):void
		{
			
		}
		
		protected function loaderCompleteHandler(evt:DatasEvent):void
		{
			
		}
		
		override public function getIn():void
		{
			
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}