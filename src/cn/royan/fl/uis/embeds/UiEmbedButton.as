package cn.royan.fl.uis.embeds
{
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.uis.IUiSelectBase;
	
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class UiEmbedButton extends UiEmbedMovieClip// implements IUiSelectBase
	{
		protected var selected:Boolean;
		protected var jump:Boolean;
		protected var labels:Vector.<int>;
		protected var unabled:Boolean;
		protected var urlPath:String;
		protected var urlTarget:String;
		
		public function UiEmbedButton()
		{
			super();
			
			labels = new Vector.<int>(4);
			for each(var frame:FrameLabel in currentLabels){
				switch(frame.name)
				{
					case "normal":
						labels[0] = frame.frame;
						break;
					case "over":
						labels[1] = frame.frame;
						break;
					case "select":
						labels[2] = frame.frame;
						break;
					case "disable":
						labels[3] = frame.frame;
						break;
				}
			}
		}
		
		override protected function addToStageHandler(evt:Event=null):void
		{
			super.addToStageHandler(evt);
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		}
		
		protected function mouseClickHandler(evt:MouseEvent):void
		{
			if( keyJump && !disabled )
			{
				if( url != "" )
				{
					gotoURLHandler( urlPath, urlTarget );
				}
				dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE));
			}
		}
		
		protected function mouseOverHandler(evt:MouseEvent):void
		{
			if( !selected && !disabled )
			{
				if( labels[1] ) goTo(labels[1]);
				else getIn();
				addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			}
		}
		
		protected function mouseOutHandler(evt:MouseEvent):void
		{
			if( !selected )
			{
				if( labels[0] ) goTo(labels[0]);
				else getOut();
				removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			}
		}
		
		protected function mouseDownHandler(evt:MouseEvent):void
		{
			if( !keyJump )
			{
				addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				
				addEventListener(Event.ENTER_FRAME, mouseDownEnterFrameHandler);
			}
		}
		
		protected function mouseDownEnterFrameHandler(evt:Event):void
		{
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DOING));
		}
		
		protected function mouseUpHandler(evt:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			removeEventListener(Event.ENTER_FRAME, mouseDownEnterFrameHandler);
		}
		
		public function getSelected():Boolean
		{
			return selected;
		}
		
		public function setSelected(value:Boolean):void
		{
			selected = value;
			if( selected )
			{
				if( labels[2] ) goTo( labels[2] );
				else getIn();
			}
			else
			{
				if( labels[0] ) goTo( labels[0] );
				else getOut();
			}
		}
		
		public function get keyJump():Boolean
		{
			return jump;
		}
		
		public function set keyJump(value:Boolean):void
		{
			jump = value;
		}
		
		public function get disabled():Boolean
		{
			return unabled;
		}
		
		public function set disabled(value:Boolean):void
		{
			unabled = value;
			
			mouseEnabled = !unabled;
			mouseChildren = !unabled;
			
			if( !disabled && labels[3] )
			{
				gotoAndStop(labels[3]);
			}
		}
		
		public function get url():String
		{
			return urlPath;
		}
		
		public function set url(value:String):void
		{
			urlPath = value;
		}
		
		public function get target():String
		{
			return urlTarget;
		}
		
		public function set target(value:String):void
		{
			urlTarget = value;
		}
		
		public function getDispatcher():EventDispatcher
		{
			return this;
		}
		
		protected function gotoURLHandler( url:String, window:String = "_self" ):void
		{
			if ( ExternalInterface.available ) {
				var broswer:String = ExternalInterface.call("function getBrowser(){ return navigator.userAgent;}") as String;
			}
			if ( broswer && ( broswer.indexOf( "Firefox" ) != -1 || broswer.indexOf( "MSIE" ) != -1 ) ) {
				ExternalInterface.call( 'window.open("' + url + '","' + window + '")' );
				return;
			}
			navigateToURL( new URLRequest( url ), window );
		}
	}
}