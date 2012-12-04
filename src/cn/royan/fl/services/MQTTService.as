package cn.royan.fl.services
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.WeakMap;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.services.bases.MQTTMessage;
	import cn.royan.fl.utils.SystemUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class MQTTService extends EventDispatcher implements IServiceBase
	{
		protected static var __weakMap:WeakMap = WeakMap.getInstance();
		
		protected var uid:uint;
		protected var keepalive:int = 10;
		protected var host:String;
		protected var port:int;
		protected var servicing:Boolean;
		protected var socket:Socket;
		protected var clean:Boolean;
		protected var username:String;
		protected var password:String;
		protected var clientid:String;
		protected var will:Object;
		protected var timer:Timer;
		protected var msgid:int;
		
		public function MQTTService(host:String, port:uint, clientid:String='')
		{
			this.host = host;
			this.port = port;
			this.clientid = clientid;
			
			uid = SystemUtils.createObjectUID();
			
			timer = PoolMap.getInstanceByType(Timer, keepalive / 2 * 1000);
			timer.addEventListener(TimerEvent.TIMER, pingHandler);
			
			__weakMap.set("timer" + uid, timer);
		}
		
		public function sendRequest(type:String='', extra:*=null):void
		{
			switch(type){
				case "publish":
					if( extra.topic && extra.content )
					{
						var bytes:ByteArray = PoolMap.getInstanceByType(ByteArray);
						writeString(bytes, extra.topic);
						
						if( extra.qos )
						{
							msgid++;
							bytes.writeByte(msgid >> 8);
							bytes.writeByte(msgid % 256 );
						}
						
						writeString(bytes, extra.content);
						
						var messageType:int = MQTTMessage.PUBLISH;
						if( extra.qos ) messageType += extra.qos << 1;
						if( extra.retain ) messageType += 1;
						var mqttBytes:MQTTMessage = PoolMap.getInstanceByType(MQTTMessage);
							mqttBytes.writeMessageType(messageType);
							mqttBytes.writeMessageValue(bytes);
						
						socket.writeBytes(mqttBytes);
						socket.flush();
						
						bytes.length = 0;
						mqttBytes.length = 0;
						
						PoolMap.disposeInstance(bytes);
						PoolMap.disposeInstance(mqttBytes);
						
						SystemUtils.print( "[Class MQTTService]:Publish sent" );
					}
					break;
				case "subscribe":
					
					break;
				case "unsubscribe":
					
					break;
				default:
					clean = extra.clean != false;
					if( extra.username ) this.username = extra.username;
					else this.username = "";
					if( extra.password ) this.password = extra.password;
					else this.password = "";
					if( extra.will ) this.will = extra.will;
			}
		}
		
		public function setCallbacks(value:Object):void
		{
			
		}
		
		public function connect():void
		{
			socket = new Socket(host, port);
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioerrorHandler);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityerrorHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketdataHandler);
			socket.addEventListener(Event.CLOSE, closeHandler);
		}
		
		public function close():void
		{
			var mqttBytes:MQTTMessage = PoolMap.getInstanceByType(MQTTMessage);
			mqttBytes.writeMessageType(MQTTMessage.DISCONNECT);
				
			socket.writeBytes(mqttBytes);
			socket.flush();
			
			mqttBytes.length = 0;
			
			PoolMap.disposeInstance(mqttBytes);
			
			socket.close();
			servicing = false;
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DESTROY));
		}
		
		public function dispose():void
		{
			if( __weakMap.getValue("timer"+uid) ){
				PoolMap.disposeInstance(timer);
				__weakMap.clear("timer"+uid);
			}
		}
		
		public function get data():*
		{
			return null;
		}
		
		public function get isServicing():Boolean
		{
			return servicing;
		}
		
		protected function connectHandler(event:Event):void
		{
			var bytes:ByteArray = PoolMap.getInstanceByType(ByteArray);
				bytes.writeByte(0x00); //0
				bytes.writeByte(0x06); //6
				bytes.writeByte(0x4d); //M
				bytes.writeByte(0x51); //Q
				bytes.writeByte(0x49); //I
				bytes.writeByte(0x73); //S
				bytes.writeByte(0x64); //D
				bytes.writeByte(0x70); //P
				bytes.writeByte(0x03); //Protocol version = 3
			var type:int = 0;
			if( clean ) type += 2;
			if( will )
			{
				type += 4;
				type += will['qos'] << 3;
				if( will['retain'] ) type += 32;
			}
			if( username ) type += 128;
			if( password ) type += 64;
			bytes.writeByte(type); //Clean session only
			bytes.writeByte(keepalive >> 8); //Keepalive MSB
			bytes.writeByte(keepalive & 0xff); //Keepaliave LSB = 60
			writeString(bytes, clientid);
			writeString(bytes, username?username:"");
			writeString(bytes, password?password:"");
			var mqttBytes:MQTTMessage = PoolMap.getInstanceByType(MQTTMessage);
				mqttBytes.writeMessageType(MQTTMessage.CONNECT);
				mqttBytes.writeMessageValue(bytes);
			
			socket.writeBytes(mqttBytes);
			socket.flush();
			
			bytes.length = 0;
			mqttBytes.length = 0;
			
			PoolMap.disposeInstance(bytes);
			PoolMap.disposeInstance(mqttBytes);
		}
		
		protected function ioerrorHandler(event:IOErrorEvent):void
		{
			SystemUtils.print("[Class MQTTService]:IO Error: " + event);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, event.type));
		}
		
		protected function socketdataHandler(event:ProgressEvent):void
		{
			SystemUtils.print( "[Class MQTTService]:Socket received " + socket.bytesAvailable + " byte(s) of data:");
			var result:MQTTMessage = PoolMap.getInstanceByType(MQTTMessage);
			socket.readBytes(result);
			
			switch(result.readUnsignedByte()){
				case MQTTMessage.CONNACK:
					result.position = 3;
					if(result.isConnack())
					{
						SystemUtils.print( "[Class MQTTService]:Socket connected" );
						servicing = true;
						dispatchEvent(new DatasEvent(DatasEvent.DATA_CREATE));
						
						timer.start();
					}else{
						SystemUtils.print( "[Class MQTTService]:Connection failed!" );
						dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection failed!"));
					}
					break;
				case MQTTMessage.PUBACK:
					SystemUtils.print( "[Class MQTTService]:Publish Acknowledgment" );
					break;
				case MQTTMessage.SUBACK:
					SystemUtils.print( "[Class MQTTService]:Subscribe Acknowledgment" );
					break;
				case MQTTMessage.UNSUBACK:
					SystemUtils.print( "[Class MQTTService]:Unsubscribe Acknowledgment" );
					break;
				case MQTTMessage.PINGRESP:
					SystemUtils.print( "[Class MQTTService]:Ping Response" );
					break;
				default:
					SystemUtils.print( "[Class MQTTService]:Other" );
			}
		}
		
		protected function securityerrorHandler(event:SecurityErrorEvent):void
		{
			SystemUtils.print("[Class MQTTService]:Security Error: " + event);
			dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, event.type));
		}
		
		protected function closeHandler(event:Event):void
		{
			SystemUtils.print("[Class MQTTService]:Server close link");
			servicing = false;
			dispatchEvent(new DatasEvent(DatasEvent.DATA_DESTROY));
		}
		
		protected function pingHandler(event:TimerEvent):void
		{
			var bytes:MQTTMessage = new MQTTMessage();
			bytes.writeMessageType(MQTTMessage.PINGREQ);
			socket.writeBytes(bytes);
			socket.flush();
			SystemUtils.print("[Class MQTTService]:Ping sent");
		}
		
		protected function writeString(bytes:ByteArray, str:String):void
		{
			var len:int = str.length;
			var msb:int = len >>8;
			var lsb:int = len % 256;
			bytes.writeByte(msb);
			bytes.writeByte(lsb);
			bytes.writeMultiByte(str, 'utf-8');
		}
	}
}