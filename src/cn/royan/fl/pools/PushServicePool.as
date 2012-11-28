package cn.royan.fl.pools
{
	import cn.royan.fl.interfaces.IPoolBase;
	import cn.royan.fl.services.PushService;
	
	public class PushServicePool implements IPoolBase
	{
		protected var pools:Vector.<PushService>;
		protected var counter:int;
		protected var maxLength:int;
		
		public function PushServicePool(length:int)
		{
			pools = new Vector.<PushService>(length);
			counter = maxLength = length;
			var i:uint = length;
			while( --i > -1 )
				pools[i] = new PushService();
		}
		
		public function getInstance():*
		{
			if( counter > 0 )
				return pools[--counter];
		}
		
		public function disposeInstance(instance:*):void
		{
			pools[counter++] = instance;
		}
		
		public function dispose():void
		{
			var i:uint = maxLength;
			while( --i > -1 ){
				pools[i] = null;
			}
		}
	}
}