package cn.royan.fl.resources
{
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.utils.describeType;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;

	public class ConfigFile
	{
		public static const CONFIG_FILE_TYPE_JSON:uint = 0;
		public static const CONFIG_FILE_TYPE_XML:uint = 1;
		public static const CONFIG_FILE_TYPE_TEXT:uint = 2;
		
		protected var type:uint;
		protected var configData:Object;
		
		public function ConfigFile(data:*, type:uint = CONFIG_FILE_TYPE_JSON)
		{
			configData = new Object();
			configData['CODE_ID'] = 'test';
			switch(type){
				case ConfigFile.CONFIG_FILE_TYPE_JSON:
					
					break;
				case ConfigFile.CONFIG_FILE_TYPE_XML:
					parseXMLToObject(data);
					break;
				case ConfigFile.CONFIG_FILE_TYPE_TEXT:
					
					break;
			}
		}
		
		public function getValue():Object
		{
			return configData;
		}
		
		protected function parseXMLToObject(data:*):void
		{
			try{
				var xml:XML = new XML(data);
				
				SystemUtils.print("[Class ConfigFile]:XML");
			}catch(e:Error){
				var xmlDoc:XMLDocument = new XMLDocument();
					xmlDoc.ignoreWhite = true;
					xmlDoc.parseXML(data);
				
				parseXMLNodeToObject(xmlDoc, configData);
				SystemUtils.print("[Class ConfigFile]:XMLDocument");
				//readObject(configData);
			}
		}
		
		protected function parseXMLNodeToObject(xmlNode:XMLNode, parent:Object):void
		{
			var i:int = 0;
			var nodes:Array = xmlNode.childNodes;
			var len:int = nodes.length;
			for(i = 0; i < len; i++){
				var child:Object = new Object();
					child['CODE_ID'] = parent['CODE_ID']+"_"+i;
				
				if( !parent[nodes[i].nodeName] ){
					parent[nodes[i].nodeName] = child;
				}
				else if( parent[nodes[i].nodeName] is Array ){
					parent[nodes[i].nodeName].push( child );
				}else{
					var temp:Object = parent[nodes[i].nodeName];
					parent[nodes[i].nodeName] = [temp];
					parent[nodes[i].nodeName].push( child );
				}
				if( nodes[i].childNodes.length > 0 ){
					parseXMLNodeToObject(nodes[i], child);
				}
				
				for (var prop:String in nodes[i].attributes)
				{
					child[prop] = nodes[i].attributes[prop];
				}
			}
		}
		
		protected function readObject(object:Object, index:int = 0):void
		{
			for( var prop:String in object ){
				var str:String = "";
				var i:int = 0;
				for(i = 0; i < index; i++){
					str += " ";
				}
				str += "|+";
				SystemUtils.print('[Class ConfigFile]:'+ str +'Object['+prop+']' );
				readObject(object[prop], index+1);
			}
		}
		
		static public function getExtension(configType:uint):String
		{
			switch( configType ){
				case ConfigFile.CONFIG_FILE_TYPE_JSON:
					return ".json";
					break;
				case ConfigFile.CONFIG_FILE_TYPE_XML:
					return ".xml";
					break;
				case ConfigFile.CONFIG_FILE_TYPE_TEXT:
					return ".txt";
					break;
			}
			return ".json";
		}
	}
}