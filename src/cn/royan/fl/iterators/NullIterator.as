package cn.royan.fl.iterators
{
	import cn.royan.fl.interfaces.IIteratorBase;
	
	public class NullIterator implements IIteratorBase
	{
		public function NullIterator()
		{
		}
		
		public function reset():void
		{
		}
		
		public function hasNext():Boolean
		{
			return false;
		}
		
		public function next():Object
		{
			return null;
		}
	}
}