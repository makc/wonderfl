// working example of stratus, p2p with Flash Player
// 1. get a stratus dev key, input it, and submit
// 2. you'll see "myID" filled with a string
// 3. open this swf in another Flash Player ( or browser tab )
// 4. copy and paste your "myID" and set it to "targetID"
//    in the other tab
// 5. press SUBMIT, and you got your DIRECT_CONNECTION
package {
	import flash.display.StageScaleMode;
	import com.bit101.components.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class Cumulus extends Sprite {

		private var lblDevKey :Label;
		private var itDevKey :InputText;
		private var itMe :InputText;
		private var itTarget :InputText;
		private var lblGuideMe :Label;
		private var lblGuideTarget :Label;
		private var itStatus :Text;
		private var btnDevKey :PushButton;
		private var btnTarget :PushButton;
		private var nc :NetConnection;
		private var subscriber :NetStream;
		private var publisher :NetStream;

		public function Cumulus() {
			initView();
		}

		private function initView() :void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			lblDevKey = new Label(this, 0, 0, "Key");
			itDevKey = new InputText(this, 50, 0, "Stratus Developer Key");
			itDevKey.width = 350;
			itDevKey.height = 20;

			lblGuideMe = new Label(this, 0, 20, "my ID");

			itMe = new InputText(this, 50, 20);
			itMe.width = 350;
			itMe.height = 20;

			lblGuideTarget = new Label(this, 0, 40, "target ID");

			itTarget = new InputText(this, 50, 40);
			itTarget.width = 350;
			itTarget.height = 20;

			itStatus = new Text(this, 0, 70);
			itStatus.width = 450;
			itStatus.height = 1000;
			
			btnDevKey = new PushButton(this, 400, 0, "SUBMIT", onDevKey);
			btnDevKey.width = 50;
			btnTarget = new PushButton(this, 400, 40, "SUBMIT", onClickTarget);
			btnTarget.width = 50;
		}

		private function onDevKey( e :MouseEvent = null ) :void {
			logger("onDevKey: " + itDevKey.text);

			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			nc.connect("rtmfp://stratus.adobe.com/" + itDevKey.text);
		}

		private function onNetStatus(e :NetStatusEvent) :void {
			logger("onNetStatus: " + e.info.code);
			switch( e.info.code ) {
			case "NetConnection.Connect.Success":
				logger("nearID: " + nc.nearID);
				itMe.text = nc.nearID;
				break;
			case "NetStream.Connect.Success":
				logger("connect from: " + e.info.stream.farID);
				if ( ! publisher || ! subscriber ) {
					startDirectConnection(e.info.stream.farID);
				}
				break;
			}
		}

		private function onClickTarget(e :MouseEvent) :void {
			startDirectConnection(itTarget.text);
		}

		private function startDirectConnection( far :String ) :void {
			logger("start publishing, and subscribe to "+far);

			publisher = new NetStream(nc, NetStream.DIRECT_CONNECTIONS);
			publisher.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			var cam :Camera = Camera.getCamera();
			publisher.attachCamera( cam );
			publisher.publish("media");

			subscriber = new NetStream(nc, far);
			subscriber.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			subscriber.play("media");
			
			var vid :Video = new Video;
			vid.attachNetStream( subscriber );
			vid.x = 130;
			vid.y = 210;
			addChild( vid );
		}

		private function logger( str :String ) :void {
			//log(str);
			itStatus.text += str + "\n";
		}
	}
}
