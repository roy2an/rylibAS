package cn.royan.fl.services
{
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.TimerBase;
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
	
	public class MQTTService extends EventDispatcher implements IServiceBase
	{
		protected static var __weakMap:WeakMap = WeakMap.getInstance();
		
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
		protected var timer:TimerBase;
		protected var msgid:int;
		protected var callbacks:Object;
		protected var packet:MQTTMessage;
		
		public function MQTTService(host:String, port:uint, clientid:String='')
		{
			this.host = host;
			this.port = port;
			this.clientid = clientid;

			timer = PoolMap.getInstanceByType(TimerBase, keepalive / 2 * 1000, onPing);
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
			callbacks = value;
		}
		
		public function connect():void
		{
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onProgress);
			socket.addEventListener(Event.CLOSE, onClose);
			socket.connect(host, port);
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
			
			if( callbacks && callbacks['destory'] ) callbacks['destory']();
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_DESTROY));
		}
		
		public function dispose():void
		{
			if( isServicing || socket.connected ) close();
			
			socket.removeEventListener(Event.CONNECT, onConnect);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, onProgress);
			socket.removeEventListener(Event.CLOSE, onClose);
			socket = null;
			callbacks = null;
		}
		
		public function get data():*
		{
			return packet;
		}
		
		public function get isServicing():Boolean
		{
			return servicing;
		}
		
		protected function onConnect(event:Event):void
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
		
		protected function onIOError(evt:IOErrorEvent):void
		{
			SystemUtils.print("[Class MQTTService]:IO Error: " + evt);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			SystemUtils.print( "[Class MQTTService]:Socket received " + socket.bytesAvailable + " byte(s) of data:");
			packet = PoolMap.getInstanceByType(MQTTMessage);
			
			socket.readBytes(packet);
			
			switch(packet.readUnsignedByte()){
				case MQTTMessage.CONNACK:
					onConnack();
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
		
		protected function onConnack():void
		{
			var varHead:ByteArray = packet.getMessageValue();
				varHead.position = 1;
			switch(varHead.readUnsignedByte()){
				case 0x00:
					SystemUtils.print( "[Class MQTTService]:Socket connected" );
					servicing = true;
					
					if( callbacks && callbacks['create'] ) callbacks['create']();
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_CREATE));
					
					timer.start();
					break;
				case 0x01:
					SystemUtils.print( "[Class MQTTService]:Connection Refused: unacceptable protocol version" );
						
					if( callbacks && callbacks['error'] ) callbacks['error']("Connection Refused: unacceptable protocol version");
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection Refused: unacceptable protocol version"));
					
					break;
				case 0x02:
					SystemUtils.print( "[Class MQTTService]:Connection Refused: identifier rejected" );
					
					if( callbacks && callbacks['error'] ) callbacks['error']("Connection Refused: identifier rejected");
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection Refused: identifier rejected"));
					
					break;
				case 0x03:
					SystemUtils.print( "[Class MQTTService]:Connection Refused: server unavailable" );
					
					if( callbacks && callbacks['error'] ) callbacks['error']("Connection Refused: server unavailable");
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection Refused: server unavailable"));
					
					break;
				case 0x04:
					SystemUtils.print( "[Class MQTTService]:Connection Refused: bad user name or password" );
					
					if( callbacks && callbacks['error'] ) callbacks['error']("Connection Refused: bad user name or password");
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection Refused: bad user name or password"));
					
					break;
				case 0x05:
					SystemUtils.print( "[Class MQTTService]:Connection Refused: not authorized" );
					
					if( callbacks && callbacks['error'] ) callbacks['error']("Connection Refused: not authorized");
					else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, "Connection Refused: not authorized"));
					
					break;
			}
		}
		
		protected function onSecurityError(evt:SecurityErrorEvent):void
		{
			SystemUtils.print("[Class MQTTService]:Security Error: " + evt);
			if( callbacks && callbacks['error'] ) callbacks['error'](evt.type);
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_ERROR, evt.type));
		}
		
		protected function onClose(event:Event):void
		{
			SystemUtils.print("[Class MQTTService]:Server close link");
			servicing = false;
			if( callbacks && callbacks['destory'] ) callbacks['destory']();
			else dispatchEvent(new DatasEvent(DatasEvent.DATA_DESTROY));
		}
		
		protected function onPing(event:TimerEvent):void
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