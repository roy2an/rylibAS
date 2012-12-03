package cn.royan.fl.resources
{
	import cn.royan.fl.bases.PoolBase;
	import cn.royan.fl.interfaces.IDisposeBase;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.describeType;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;

	public class ConfigFile implements IDisposeBase
	{
		public static const CONFIG_FILE_TYPE_JSON:uint = 0;
		public static const CONFIG_FILE_TYPE_XML:uint = 1;
		public static const CONFIG_FILE_TYPE_TEXT:uint = 2;
		
		protected var type:uint;
		protected var configData:Object;
		
		public function ConfigFile(data:String, type:uint = CONFIG_FILE_TYPE_JSON)
		{
			this.type = type;
			configData = new Object();
			switch(type){
				case ConfigFile.CONFIG_FILE_TYPE_JSON:
					parseJsonToObject(data);
					break;
				case ConfigFile.CONFIG_FILE_TYPE_XML:
					parseXMLToObject(data);
					break;
				case ConfigFile.CONFIG_FILE_TYPE_TEXT:
					parseTxtToObject(data);
					break;
			}
		}
		
		public function getValue():Object
		{
			return configData;
		}
		
		public function dispose():void
		{
			configData = null;
		}
		
		protected function parseJsonToObject(data:String):void
		{
			
		}
		
		protected function parseXMLToObject(data:String):void
		{
			try{
				var xml:XML = new XML(data);
				SystemUtils.print("[Class ConfigFile]:XML To Object");
				
				System.disposeXML(xml);
			}catch(e:Error){
				var xmlDoc:XMLDocument = PoolBase.getInstanceByType(XMLDocument);
					xmlDoc.ignoreWhite = true;
					xmlDoc.parseXML(data);
				
				parseXMLNodeToObject(xmlDoc, configData);
				SystemUtils.print("[Class ConfigFile]:XMLDocument To Object");
				//PoolBase.disposeInstance(xmlDoc);
				xmlDoc = null;
			}
		}
		
		protected function parseXMLListToObject(xmlList:XMLList, parent:Object):void
		{
			
		}
		
		protected function parseXMLNodeToObject(xmlNode:XMLNode, parent:Object):void
		{
			var i:int = 0;
			var nodes:Array = xmlNode.childNodes;
			var len:int = nodes.length;
			for(i = 0; i < len; i++){
				var child:Object = new Object();
				
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
		
		protected function parseTxtToObject(txt:String):void
		{
			var valuePair:Array = txt.split("&");
			var i:int;
			var len:int = valuePair.length;
			for( i = 0; i < len; i++){
				var pair:Array = valuePair[i].split("=");
				configData[pair[0]] = pair[1];
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