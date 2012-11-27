package cn.royan.fl.pools
{
	import cn.royan.fl.interfaces.IPool;
	import cn.royan.fl.services.TakeService;
	
	public class TakeServicePool implements IPool
	{
		protected var pools:Vector.<TakeService>;
		protected var counter:int;
		protected var maxLength:int;
		
		public function TakeServicePool(length:int)
		{
			pools = new Vector.<TakeService>(length);
			counter = maxLength = length;
			var i:uint = length;
			while( --i > -1 )
				pools[i] = new TakeService();
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