package cn.royan.fl.iterators
{
	import cn.royan.fl.interfaces.IIteratorBase;
	
	public class ArrayIterator implements IIteratorBase
	{
		protected var _source:Array;
		protected var _index:int;
		public function ArrayIterator(array:Array)
		{
			_source = array.concat();
		}
		
		public function reset():void
		{
			_index = 0;
		}
		
		public function hasNext():Boolean
		{
			return _index < _source.length;
		}
		
		public function next():Object
		{
			return _source[_index++];
		}
	}
}