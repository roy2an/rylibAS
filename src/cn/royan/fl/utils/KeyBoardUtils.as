package cn.royan.fl.utils
{
	import flash.events.KeyboardEvent;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author RoYan
	 */
	public class KeyBoardUtils {
		
        private static var keyObj:KeyBoardUtils = null;
        private static var keys:Object;
		
        public static function init( display:DisplayObject ):void
		{
            if ( keyObj == null ) {
                keys = { };
				
                display.stage.addEventListener( KeyboardEvent.KEY_DOWN, KeyBoardUtils.keyDownHandler, false, 99, true );
                display.stage.addEventListener( KeyboardEvent.KEY_UP, KeyBoardUtils.keyUpHandler, false, 99, true );
				
				keyObj = new KeyBoardUtils();
            }
        }
		
        public static function isDown( keyCode:uint ):Boolean
		{
            return keys[keyCode];
        }
		
        private static function keyDownHandler( evt:KeyboardEvent ):void
		{
            keys[evt.keyCode] = true;
        }
		
        private static function keyUpHandler( evt:KeyboardEvent ):void
		{
            delete keys[evt.keyCode];
        }
    }

}