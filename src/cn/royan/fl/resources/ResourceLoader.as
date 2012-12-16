package cn.royan.fl.resources
{
	import cn.royan.fl.bases.DispacherBase;
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.interfaces.IDisposeBase;
	import cn.royan.fl.services.TakeService;
	import cn.royan.fl.uis.embeds.UiEmbedLoader;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.utils.setTimeout;

	public class ResourceLoader extends DispacherBase implements IDisposeBase
	{
		protected static var __loaderMap:Array = [];
		protected static var __weakMap:WeakMap = WeakMap.getInstance();
		
		protected var uid:String;
		protected var moduleKey:String;
		protected var moduleVer:String;
		protected var takeService:TakeService;
		protected var configType:uint;
		protected var configFile:ConfigFile;
		protected var currentPath:String;
		protected var stageView:DisplayObjectContainer;
		protected var callbacks:Object;
		protected var root:DisplayObjectContainer;
		protected var loader:UiEmbedLoader;
		
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
			uid = SystemUtils.createUniqueID();
			
			root = container;
			
			moduleKey = key;
			moduleVer = version;
			
			stageView = container;
			
			currentPath = "component/loadinglibs.swf";
			
			takeService = PoolMap.getInstanceByType( TakeService, "version="+moduleVer );
			takeService.setCallbacks({done:loaderOnCompleteHandler,
									  doing:loaderOnProgressHandler,
									  error:loaderOnErrorHandler})
			takeService.sendRequest(currentPath);
			takeService.connect();
		}
		
		public function load():void
		{
			currentPath = moduleKey + ConfigFile.getExtension(configType);
			takeService.sendRequest(currentPath);
			takeService.connect();
		}
		
		public function dispose():void
		{
			PoolMap.disposeInstance(configFile);
			callbacks = null;
		}
		
		public function setConfigType(value:uint):void
		{
			configType = value;
		}
		
		public function getResourceByPath(path:String):*
		{
			return __weakMap.getValue(path + uid);
		}
		
		public function setCallbacks(value:Object):void
		{
			callbacks = value;
		}
		
		protected function loaderOnProgressHandler(loaded:uint, total:uint):void
		{
			SystemUtils.print("[Class ResourceLoader]:Loader File OnProgress");
		}
		
		protected function loaderOnCompleteHandler(data:*):void
		{
			SystemUtils.print("[Class ResourceLoader]:Loader File OnComplete");
			__weakMap.set(currentPath + uid, data);
			
			takeService.dispose();
			
			loader = SystemUtils.getInstanceByClassName("LoaderClass") as UiEmbedLoader;
			
			root.addChild( loader );
			
			PoolMap.disposeInstance(takeService);
			
			takeService = PoolMap.getInstanceByType( TakeService, "version="+moduleVer );
			takeService.setCallbacks({done:configFileOnCompleteHandler,
									  doing:configFileOnProgressHandler,
									  error:configFileOnErrorHandler});
			load();
		}
		
		protected function loaderOnErrorHandler(message:String):void
		{
			SystemUtils.print("[Class ResourceLoader]:Loader File OnError");
		}
		
		protected function configFileOnProgressHandler(loaded:uint, total:uint):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File onProgress");
		}
		
		protected function configFileOnCompleteHandler(data:*):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File onComplete");
			
			__weakMap.set(currentPath + uid, data);
			
			configFile = PoolMap.getInstanceByType(ConfigFile, data, configType);
			
			takeService.dispose();
			
			PoolMap.disposeInstance(takeService);
			
			synFileStartLoadHandler();
		}
		
		protected function configFileOnErrorHandler(message:String):void
		{
			SystemUtils.print("[Class ResourceLoader]:Config File OnError");
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
				
				takeService = PoolMap.getInstanceByType( TakeService, "version="+moduleVer );
				takeService.setCallbacks({done:synFileOnCompleteHandler,
										  doing:synFileOnProgressHandler,
					 					  error:synFileOnErrorHandler});
				takeService.sendRequest(currentPath);
				takeService.connect();
				
			}else{
				SystemUtils.print("[Class ResourceLoader]:syn File OnFinish");
				if( callbacks && callbacks['synDone'] ) callbacks['synDone']();
				asynFileStartLoadHandler();	
				
				if( root.contains(loader) ) root.removeChild(loader);
				return;
			}
		}
		
		protected function synFileOnProgressHandler(loaded:uint, total:uint):void
		{
			loader.loaderProgress(loaded, total);
		}
		
		protected function synFileOnCompleteHandler(data:*):void
		{
			SystemUtils.print("[Class ResourceLoader]:syn File OnComplete");
			
			loader.loaderComplete();
			
			__weakMap.set(currentPath + uid, data);
			
			takeService.dispose();
			PoolMap.disposeInstance(takeService);
			
			setTimeout(synFileStartLoadHandler, 500);
		}
		
		protected function synFileOnErrorHandler(message:String):void
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
				
				takeService = PoolMap.getInstanceByType( TakeService, "version="+moduleVer );
				takeService.setCallbacks({done:asynFileOnCompleteHandler,
										  doing:asynFileOnProgressHandler,
										  error:asynFileOnErrorHandler});
				takeService.sendRequest(currentPath);
				takeService.connect();
				
			}else{
				SystemUtils.print("[Class ResourceLoader]:asyn File OnFinish");
				if( callbacks && callbacks['asynDone'] ) callbacks['asynDone']();
			}
		}
		
		protected function asynFileOnProgressHandler(loaded:uint, total:uint):void
		{
		}
		
		protected function asynFileOnCompleteHandler(data:*):void
		{
			SystemUtils.print("[Class ResourceLoader]:asyn File OnComplete");
			
			__weakMap.set(currentPath + uid, data);
			
			takeService.dispose();
			PoolMap.disposeInstance(takeService);
			
			asynFileStartLoadHandler();
		}
		
		protected function asynFileOnErrorHandler(message:String):void
		{
			SystemUtils.print("[Class ResourceLoader]:asyn File OnError");
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