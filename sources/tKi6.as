package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Jon "Jonanin" Morton <jonanin -AT- gmail.com>
	 */
	public class Main extends Sprite 
	{
		
		private var CommandRegistry:Object;
		private var CommonCommandRegistry:Object;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
		private function init(e:Event = null):void 
		{
			var txt:TextField = new TextField();
			addChild(txt);
			
			txt.x = 50;
			txt.y = 50;
			txt.width = 500;
			txt.multiline = true;
			
			CommandRegistry = new Object();
			CommandRegistry.registerCommand = registerCommand;
			CommonCommandRegistry = new Object();
			CommonCommandRegistry.registerCommand = registerCommand;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			CommandRegistry.registerCommand(0, "Hhifd", "test", "?", function (status:Boolean):void {});
			
			CommandRegistry.test(10, 10, 10, 10, 10);
                
		}
		
		private function dataReceived(event:Event):void {
    			var sock:Socket = (event.target as Socket);
			var command:int = sock.readByte();
			var registry:Object = CommandRegistry;
			
			if (command == 0x00) registry = CommonCommandRegistry;
			else if (command == 0xFF) command = sock.readUnsignedShort();
			
			var data:ByteArray = new ByteArray();
			sock.readBytes(data, 0, registry["len_"+command.toString(16)]);
			registry["replyHandler_"+command.toString(16)](data);
			
			if (sock.bytesAvailable > 0) dataReceived(event);
		}
		
		private function registerCommand(command:int, format:String, fn:String, replyFormat:String="", callback:Function=null):void {
 			var len:int = 0;
			for(var i:int = 0; i < format.length; i ++) {
				var k:String = format.charAt(i);
				if (k == "H" || k == "h" || k == "f") len += 2;
				else if (k == "B" || k == "b" || k == "?") len ++;
				else if (k == "I" || k == "i" || k == "L" || k == "l" || k == "d") len += 4;
			}
			this["len_"+command.toString(16)] = len;
			if (callback != null) {
				this["replyHandler_"+command.toString(16)] = function(data:ByteArray):void {
					if (replyFormat.length < 1) { callback(); return; }
					var args:Array = new Array();
					// assume command has been eaten.
					for (var i:int = 0; i < replyFormat.length; i ++) {
						var k:String = replyFormat.charAt(i);
						if (k == "H") args.push(data.readUnsignedShort());
						else if (k == "h") args.push(data.readShort());
						else if (k == "?") args.push(data.readByte() > 0);
						else if (k == "b") args.push(data.readByte());
						else if (k == "B") args.push(data.readUnsignedByte());
						else if (k == "i" || k == "l") args.push(data.readInt());
						else if (k == "I" || k == "L") args.push(data.readUnsignedInt());
						else if (k == "f") args.push(data.readFloat());
						else if (k == "d") args.push(data.readDouble());
						else if (k == "c") {
    							var c:int = 0;
    							var str:String = "";
    							while (true) {
        							c = data.readByte();
        							if (c == 0) break;
        							str += String.fromCharCode(c);
        						}
        						args.push(str);
    						}
					}
					callback.apply(args);
				}
			}
			this[fn] = function(...args):void {
				if (args.length != format.length) throw new Error();
				var c:ByteArray = new ByteArray();
				c.writeByte(command);
				for (var i:int = 0; i < format.length; i ++) {
					var k:String = format.charAt(i);
					if (k == "h" || k == "H") c.writeShort(args[i]);
					else if (k == "i" || k == "l") c.writeInt(args[i]);
					else if (k == "?") c.writeByte(args[i] ? 1 : 0);
					else if (k == "b" || k == "B") c.writeByte(args[i]);
					else if (k == "I" || k == "L") c.writeUnsignedInt(args[i]);
					else if (k == "f") c.writeFloat(args[i]);
					else if (k == "d") c.writeDouble(args[i]);
					else if (k == "c") c.writeUTFBytes(args[i] + "\0");
				}
				trace("sendCommand: " + c.toString());
			}
		
		}
	}
	
}