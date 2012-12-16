package cn.royan.fl.utils
{
	import cn.royan.fl.bases.PoolMap;
	
	import flash.geom.Point;
	
	public class DisplayUtils
	{
		public static function centerRotate(orgin:Point, center:Point, angle:Number):Point
		{
			var result:Point = PoolMap.getInstanceByType( Point );
				result.x = ( orgin.x - center.x ) * Math.cos(Math.PI / 180 * angle) + ( orgin.y - center.y ) * Math.sin( Math.PI / 180 * angle) + center.x;
				result.y = -( orgin.x - center.x) * Math.sin(Math.PI / 180 * angle) + ( orgin.y - center.y ) * Math.cos( Math.PI / 180 * angle) + center.y;
			return result;
		}
	}
}