package cn.royan.fl.resources
{
	import cn.royan.fl.bases.PoolBase;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.IDisposeBase;
	import cn.royan.fl.services.TakeService;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.xml.XMLDocument;

	public class ResourceLoader extends EventDispatcher implements IDisposeBase
	{
		protected static var __loaderMap:Array = [];
		protected static var __weakMap:WeakMap = WeakMap.getInstance();
		
		protected var uid:uint;
		protected var moduleKey:String;
		protected var moduleVer:String;
		protected var takeService:TakeService;
		protected var configType:uint;
		protected var configFile:ConfigFile;
		protected var currentPath:String;
		protected var stageView:DisplayObjectContainer;
		
		public static function getInstance(key:String, container:DisplayObjectContainer, version:String="1.0"):ResourceLoader
		{
			if( __loaderMap[key] == null )
			{
				__loaderMap[key] = new ResourceLoader(key, container, version, new ResourceLoaderType());
			}
			return __loaderMap[key];
		}
		
		public function ResourceLoader(key:String, container:DisplayObjectContainer, version:String, type:ResourceLoaderType)
		{
			uid = SystemUtils.createObjectUID();
			
			moduleKey = key;
			moduleVer = version;
			
			stageView = container;
			
			takeService = PoolBase.getInstanceByType( TakeService, "version="+moduleVer );
			takeService.addEventListener(DatasEvent.DATA_DOING, configFileOnProgressHandler);
			takeService.addEventListener(DatasEvent.DATA_DONE, configFileOnCompleteHandler);
			takeService.addEventListener(DatasEvent.DATA_ERROR, configFileOnErrorHandler);
		}
		
		public function load():void
		{
			currentPath = moduleKey + ConfigFile.getExtension(configType);
			takeService.sendRequest(currentPath);
			takeService.connect();
		}
		
		public function dispose():void
		{
			
		}
		
		public function setConfigType(value:uint):void
		{
			configType = value;
		}
		
		public function getResourceByPath(path:String):*
		{
			return __weakMap.getValue(path + uid);
		}
		
		protected function synFileStartLoadHandler():void
		{
			var synFiles:Array = configFile.getValue()['DLLS']['DLL'] as Array;
			if( synFiles && synFiles.length ){
				
				SystemUtils.print("[Class ResourceLoader]:syn File Start");
				
				var currentDll:Object = synFiles.shift();
				currentPath = currentDll['path'];
				
				if( checkResourceByPath(currentPath) ){
					synFileStartLoadHandler();
					return;
				}
				
				SystemUtils.print("[Class ResourceLoader]:syn File Start:"+currentPath);
				
				takeService = PoolBase.getInstanceByType( TakeService, "version="+moduleVer );
				takeService.addEventListener(DatasEvent.DATA_DOING, synFileOnProgressHandler);
				takeService.addEventListener(DatasEvent.DATA_DONE, synFileOnCompleteHandler);
				takeService.addEventListener(DatasEvent.DATA_ERROR, synFileOnErrorHandler);
				takeService.sendRequest(currentPath);
				takeService.connect();
				
			}else{
				SystemUtils.print("[Class ResourceLoader]:syn File OnFinish");
				dispatchEvent(new DatasEvent(DatasEvent.DATA_DONE));
				
				asynFileStartLoadHandler();	
				
				return;
			}
		}
		
		protected function synFileOnProgressHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:syn File OnProgress");
		}
		
		
		protected function synFileOnCompleteHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:syn File OnComplete");
			
			__weakMap.set(currentPath + uid, evt.params);
			
			takeService.removeEventListener(DatasEvent.DATA_DOING, configFileOnProgressHandler);
			takeService.removeEventListener(DatasEvent.DATA_DONE, configFileOnCompleteHandler);
			takeService.removeEventListener(DatasEvent.DATA_ERROR, configFileOnErrorHandler);
			takeService.dispose();
			
			PoolBase.disposeInstance(takeService);
			
			synFileStartLoadHandler();
		}
		
		protected function synFileOnErrorHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:syn File OnError");
		}
		
		protected function asynFileStartLoadHandler():void
		{
			var asynFiles:Array = configFile.getValue()['AYSNDLLS']['DLL'] as Array;
			if( asynFiles && asynFiles.length ){
				SystemUtils.print("[Class ResourceLoader]:asyn File Start");
				
				var currentDll:Object = asynFiles.shift();
				currentPath = currentDll['path'];
				
				if( checkResourceByPath(currentPath) ){
					asynFileStartLoadHandler();
					return;
				}
				
				SystemUtils.print("[Class ResourceLoader]:asyn File Start:"+currentPath);
				
				takeService = PoolBase.getInstanceByType( TakeService, "version="+moduleVer );
				takeService.addEventListener(DatasEvent.DATA_DOING, asynFileOnProgressHandler);
				takeService.addEventListener(DatasEvent.DATA_DONE, asynFileOnCompleteHandler);
				takeService.addEventListener(DatasEvent.DATA_ERROR, asynFileOnErrorHandler);
				takeService.sendRequest(currentPath);
				takeService.connect();
			}else{
				
			}
		}
		
		protected function asynFileOnProgressHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:asyn File OnProgress");
		}
		
		protected function asynFileOnCompleteHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:asyn File OnComplete");
			
			__weakMap.set(currentPath + uid, evt.params);
			
			takeService.removeEventListener(DatasEvent.DATA_DOING, configFileOnProgressHandler);
			takeService.removeEventListener(DatasEvent.DATA_DONE, configFileOnCompleteHandler);
			takeService.removeEventListener(DatasEvent.DATA_ERROR, configFileOnErrorHandler);
			takeService.dispose();
			
			PoolBase.disposeInstance(takeService);
			
			asynFileStartLoadHandler();
		}
		
		protected function asynFileOnErrorHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:asyn File OnError");
		}
		
		protected function configFileOnProgressHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File onProgress");
		}
		
		protected function configFileOnCompleteHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File onComplete");
			
			__weakMap.set(currentPath + uid, evt.params);
			
			configFile = new ConfigFile(evt.params, configType);
			
			takeService.removeEventListener(DatasEvent.DATA_DOING, configFileOnProgressHandler);
			takeService.removeEventListener(DatasEvent.DATA_DONE, configFileOnCompleteHandler);
			takeService.removeEventListener(DatasEvent.DATA_ERROR, configFileOnErrorHandler);
			takeService.dispose();
			
			PoolBase.disposeInstance(takeService);
			
			synFileStartLoadHandler();
		}
		
		protected function configFileOnErrorHandler(evt:DatasEvent):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File OnError");
		}
		
		protected function checkResourceByPath(path:String):Boolean
		{
			for( var key:String in __loaderMap )
			{
				if( __loaderMap[key].getResourceByPath(path) ){
					return true;
					break;
				}
			}
			return false;
		}
	}
}

class ResourceLoaderType{}