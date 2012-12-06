package cn.royan.fl.utils
{
	import flash.utils.ByteArray;

	public class BytesUtils
	{
		public static function getType(bytes:ByteArray):String
		{
			if( isPNG(bytes) ){
				return "PNG";
			}
			if( isJPEG(bytes) ){
				return "JPEG";
			}
			if( isSWF(bytes) ){
				return "SWF";
			}
			if( isXML(bytes) ){
				return "XML";
			}
			if( isGIF(bytes) ){
				return "GIF";
			}
			if( isBMP(bytes) ){
				return "BMP";
			}
			if( isFLV(bytes) ){
				return "FLV";
			}
			if( isMP3(bytes) ){
				return "MP3";
			}
			return "Other";
		}
		
		public static function isPNG(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			
			if( bytes.readUnsignedByte() != 0xff ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0xd8 ){
				return false;
			}
			
			bytes.position = bytes.length - 2;
			
			if( bytes.readUnsignedByte() != 0xff ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0xd9 ){
				return false;
			}
			return true;
		}
		
		public static function isJPEG(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			
			if( bytes.readUnsignedByte() != 0x89 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x50 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x4E ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x47 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x0D ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x0A ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x1A ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x0A ){
				return false;
			}
			return true;
		}
		
		public static function isSWF(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			var header:String = bytes.readMultiByte(3,'utf8');
			return header == "CWS" || header == "FWS";
		}
		
		public static function isXML(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			var header:String = bytes.readMultiByte(5,'utf8');
			return header == "<?xml";
		}
		
		public static function isGIF(bytes:ByteArray):Boolean
		{
			if( bytes.readUnsignedByte() != 0x47 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x49 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x46 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x38 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x39 && bytes.readUnsignedByte() != 0x37 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x61 ){
				return false;
			}
			return true;
		}
		
		public static function isBMP(bytes:ByteArray):Boolean
		{
			if( bytes.readUnsignedByte() != 0x42 ){
				return false;
			}
			if( bytes.readUnsignedByte() != 0x4d ){
				return false;
			}
			return true;
		}
		
		public static function isFLV(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			var header:String = bytes.readMultiByte(3,'utf8');
			return header == "FLV";
		}
		
		public static function isMP3(bytes:ByteArray):Boolean
		{
			bytes.position = 0;
			var header:String = bytes.readMultiByte(3,'utf8');
			return header == "ID3";
		}
	}
}