package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.text.TextField;

	public class UiEmbedLoader extends UiEmbedSprite
	{
		protected var loaderData:EventDispatcher;
		protected var currentFileName:TextField;
		protected var progressTxt:TextField;
		protected var progressBar:Sprite;
		
		public function UiEmbedLoader(loader:EventDispatcher = null)
		{
			if( loader ) setLoaderData( loader );
			if( getChildByName("__progress") )
				progressBar = getChildByName("__progress") as Sprite;
			if( getChildByName("__progressTxt") )
				progressTxt = getChildByName("__progressTxt") as TextField;
			if( getChildByName("__currentFile") )
				currentFileName = getChildByName("__currentFile") as TextField;
		}
		
		public function setLoaderData(loader:EventDispatcher):void
		{
			loaderData = loader;
			loaderData.addEventListener(DatasEvent.DATA_DOING, loaderProgressHandler);
			loaderData.addEventListener(DatasEvent.DATA_DONE, loaderCompleteHandler);
		}
		
		public function loaderProgress(loaded:uint, total:uint):void
		{
			
		}
		
		public function loaderComplete():void
		{
			
		}
		
		public function setFileName(fileName:String, desp:String):void
		{
			
		}
		
		protected function loaderProgressHandler(evt:DatasEvent):void
		{
			
		}
		
		protected function loaderCompleteHandler(evt:DatasEvent):void
		{
			
		}
		
		override public function getIn():void
		{
			
		}
	}
}