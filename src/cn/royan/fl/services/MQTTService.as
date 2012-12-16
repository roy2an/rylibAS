package cn.royan.fl.services
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import cn.royan.fl.bases.DispacherBase;
	import cn.royan.fl.bases.PoolMap;
	import cn.royan.fl.bases.TimerBase;
	import cn.royan.fl.events.DatasEvent;
	import cn.royan.fl.interfaces.services.IServiceBase;
	import cn.royan.fl.services.bases.MQTTServiceMessage;
	import cn.royan.fl.utils.SystemUtils;
	
	public class MQTTService extends DispacherBase implements IServiceBase
	{
		private static const MAX_LEN_UUID:int		= 16;
		private static const MAX_LEN_TOPIC:int		= 7;
		private static const MAX_LEN_USERNAME:int	= 12;
		//Topic level separator
		public static const TOPIC_LEVEL_SEPARATOR:String = "/";
		//Multi-level wildcard
		public static const TOPIC_M_LEVEL_WILDCARD:String = "#";
		//Single-level wildcard
		public static const TOPIC_S_LEVEL_WILDCARD:String = "+";
		
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
		protected var packet:MQTTServiceMessage;
		
		public function MQTTService(host:String, port:uint, clientid:String)
		{
			this.host = host;
			this.port = port;
			this.clientid = clientid;

			timer = PoolMap.getInstanceByType(TimerBase, keepalive / 2 * 1000, onPing);
		}
		
		public function sendRequest(type:String='', extra:*=null):void
		{
			var i:int;
			var topics:Array;
			var qoss:Array;
			var bytes:ByteArray;
			var messageType:int;
			var mqttBytes:MQTTServiceMessage;
			switch( type ){
				case "publish":
					publish(extra.topic, extra.content, extra.qos, extra.retain);
					break;
				case "subscribe":
					subscribe(extra.topics, extra.qoss, extra.qos);
					break;
				case "unsubscribe":
					unsubscribe(extra.topics, extra.qos);
					break;
				default:
					extra = extra == null?{}:extra;
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
			var mqttBytes:MQTTServiceMessage = PoolMap.getInstanceByType(MQTTServiceMessage);
			mqttBytes.writeMessageType(MQTTServiceMessage.DISCONNECT);
				
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
			
			removeAllEventListener();
		}
		
		public function get data():*
		{
			return packet;
		}
		
		public function get isServicing():Boolean
		{
			return servicing;
		}
		
		protected function publish(topic:String, content:String, qos:int = 0, retain:int = 0):void
		{
			var bytes:ByteArray = new ByteArray();//PoolMap.getInstanceByType(ByteArray);
			writeString(bytes, topic);
			
			if( qos )
			{
				msgid++;
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256 );
			}
			writeString(bytes, content);
			
			var messageType:int = MQTTServiceMessage.PUBLISH;
			if( qos ) messageType += qos << 1;
			if( retain ) messageType += 1;
			var mqttBytes:MQTTServiceMessage = new MQTTServiceMessage()//PoolMap.getInstanceByType(MQTTServiceMessage);
				mqttBytes.writeMessageType(messageType);
				mqttBytes.writeMessageValue(bytes);
			
			socket.writeBytes(mqttBytes);
			socket.flush();
			
			bytes.length = 0;
			mqttBytes.length = 0;
			
			SystemUtils.print( "[Class MQTTService]:Publish sent" );
		}
		
		protected function subscribe(topics:Array, qoss:Array, qos:int = 0):void
		{
			var bytes:ByteArray = new ByteArray()//PoolMap.getInstanceByType(ByteArray);
			
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256);
			
			var i:int;
			for(i = 0; i < topics.length; i++){
				if (topics[i].length > MAX_LEN_TOPIC)
					throw new Error("Out of range ".concat(MAX_LEN_TOPIC, "!"));
				
				writeString(bytes, topics[i]);
				bytes.writeByte(qoss[i]);
			}
			//TODO:send subscribe message
			var messageType:int = MQTTServiceMessage.SUBSCRIBE;
				messageType += (qos << 1);
			var mqttBytes:MQTTServiceMessage = new MQTTServiceMessage()//PoolMap.getInstanceByType(MQTTServiceMessage);
				mqttBytes.writeMessageType(messageType);
				mqttBytes.writeMessageValue(bytes);
			
			//
			socket.writeBytes(mqttBytes);
			socket.flush();
			
			SystemUtils.print( "[Class MQTTService]:Subscribe sent" );
		}
		
		protected function unsubscribe(topics:Array, qos:int = 0):void
		{
			
			var bytes:ByteArray = new ByteArray()//PoolMap.getInstanceByType(ByteArray);
				
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256);
			var i:int;
			for(i = 0; i < topics.length; i++){
				if (topics[i].length > MAX_LEN_TOPIC)
					throw new Error("Out of range ".concat(MAX_LEN_TOPIC, "!"));
				
				writeString(bytes, topics[i]);
			}
			//TODO:send subscribe message
			var messageType:int = MQTTServiceMessage.UNSUBSCRIBE;
				messageType += (qos << 1);
			var mqttBytes:MQTTServiceMessage = new MQTTServiceMessage()//PoolMap.getInstanceByType(MQTTServiceMessage);
				mqttBytes.writeMessageType(messageType);
				mqttBytes.writeMessageValue(bytes);
			//
			socket.writeBytes(mqttBytes);
			socket.flush();
			
			SystemUtils.print( "[Class MQTTService]:Unsubscribe sent" );
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
			var mqttBytes:MQTTServiceMessage = PoolMap.getInstanceByType(MQTTServiceMessage);
				mqttBytes.writeMessageType(MQTTServiceMessage.CONNECT);
				mqttBytes.writeMessageValue(bytes);
				
			socket.writeBytes(mqttBytes);
			socket.flush();
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
			while( socket.bytesAvailable ){
				packet = PoolMap.getInstanceByType(MQTTServiceMessage);
				packet.writeType(socket.readUnsignedByte());
				var remainingLength:uint = socket.readUnsignedByte();
				var bytes:ByteArray = new ByteArray();
				socket.readBytes(bytes, 0, remainingLength);
				packet.writeMessageValue(bytes);
				
				SystemUtils.print("Protocol Type:"+ packet.readType().toString(16));
				SystemUtils.print("Protocol Length:"+ packet.length);
				SystemUtils.print("Protocol DUP:"+ packet.readDUP());
				SystemUtils.print("Protocol QoS:"+ packet.readQoS());
				SystemUtils.print("Protocol RETAIN:"+ packet.readRETAIN());
				SystemUtils.print("Protocol RemainingLength:"+ packet.readRemainingLength());
				SystemUtils.print("Protocol Variable Header Length:"+ packet.readMessageValue().length);
				SystemUtils.print("Protocol PayLoad Length:"+ packet.readPayLoad().length);
				
				switch(packet.readType()){
					case MQTTServiceMessage.CONNACK:
						onConnack(packet);
						break;
					case MQTTServiceMessage.PUBACK:
						onPuback(packet);
						SystemUtils.print( "[Class MQTTService]:Publish Acknowledgment" );
						break;
					case MQTTServiceMessage.PUBREC:
						onPubrec(packet);
						SystemUtils.print( "[Class MQTTService]:Publish Received (assured delivery part 1)" );
						break;
					case MQTTServiceMessage.PUBREL:
						onPubrel(packet);
						SystemUtils.print( "[Class MQTTService]:Publish Release (assured delivery part 2)" );
						break;
					case MQTTServiceMessage.PUBCOMP:
						onPubcomp(packet);
						SystemUtils.print( "[Class MQTTService]:Publish Complete (assured delivery part 3)" );
						break;
					case MQTTServiceMessage.SUBACK:
						onSuback(packet);
						SystemUtils.print( "[Class MQTTService]:Subscribe Acknowledgment" );
						break;
					case MQTTServiceMessage.UNSUBACK:
						onUnsuback(packet);
						SystemUtils.print( "[Class MQTTService]:Unsubscribe Acknowledgment" );
						break;
					case MQTTServiceMessage.PINGRESP:
						onPingresp(packet);
						SystemUtils.print( "[Class MQTTService]:Ping Response" );
						break;
					default:
						SystemUtils.print( "[Class MQTTService]:Other" );
				}
			}
		}
		
		protected function onConnack(packet:MQTTServiceMessage):void
		{
			packet.position = 0;
			var varHead:ByteArray = packet.readMessageValue();
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
		
		protected function onPuback(packet:MQTTServiceMessage):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					SystemUtils.print("Puback Message ID "+messageId);
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onPubrec(packet:MQTTServiceMessage):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					SystemUtils.print("Pubrec Message ID "+messageId);
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onPubrel(packet:MQTTServiceMessage):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					SystemUtils.print("Pubrel Message ID "+messageId);
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onPubcomp(packet:MQTTServiceMessage):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					SystemUtils.print("Pubcomp Message ID "+messageId);
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onSuback(packet:MQTTServiceMessage):void
		{
			//Fixed header
			var payloadLen:int = packet.readRemainingLength();
			//Variable header
			var varHead:ByteArray = packet.readMessageValue();
			var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
			SystemUtils.print("Suback Message ID "+messageId);
			//Payload
			var payload:ByteArray = packet.readPayLoad();
			var i:int;
			for( i = 0; i < payload.length; i++){
				var qos:int = payload.readUnsignedByte() & 0x03;
				SystemUtils.print("Suback Topic "+i+" QoS "+ qos);
			}
			//Actions
		}
		
		//TODO:
		protected function onUnsuback(packet:MQTTServiceMessage):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header( 2 bytes)
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					SystemUtils.print("Unsuback Message ID "+messageId);
					break;
				default:
					break;
			}
			
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onPingresp(packet:MQTTServiceMessage):void
		{
			//Only Fixed header
			switch (packet.readRemainingLength())
			{
				case 0x00:
					SystemUtils.print("Ping Response");
					break;
				default:
					break;
			}
			//Variable header
			//Payload
			//Actions
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
		
		protected function onPing():void
		{
			var bytes:MQTTServiceMessage = new MQTTServiceMessage();
			bytes.writeMessageType(MQTTServiceMessage.PINGREQ);
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