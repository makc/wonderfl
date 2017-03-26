// WARNING: shitty code, for lulz only. do not use as a reference :)
package {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	[SWF(width=465,height=465,frameRate=30)]
	public class TetrisGod extends Sprite {
		public const blocks:Array = [
			/* I */ [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0x00BFBF],
			/* J */ [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x0000FF],
			/* L */ [0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF7F00],
			/* O */ [1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xEFEF00],
			/* S */ [0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x007F00],
			/* T */ [0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF00FF],
			/* Z */ [1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF0000],
		];
		public var blockI:int = 1;
		public var blockX:int = 4;
		public var blockY:int = 0;
		public var blockT:int = 0;
		public const field:Array = [];
		public const keys:Array = [];
		public function handleKeys (e:KeyboardEvent):void {
			keys [e.keyCode] = (e.type == KeyboardEvent.KEY_DOWN);
		}
		public function draw (e:Event):void {
			var i:int, j:int;
			graphics.clear ();
			for (i = 0; i < 10; i++) for (j = 0; j < 20; j++) {
				graphics.beginFill (field [i + 10 * j] > 0 ? field [i + 10 * j] : 0xcccccc);
				graphics.drawRect (321 + 14 * i, 14 * j, 13, 13);
			}
		}
		public function freeSpot (i1:int, j1:int):Boolean {
			if ((i1 < 0) || (i1 > 10 -1)) return false;
			if ((j1 < 0) || (j1 > 20 -1)) return false;
			if (field [i1 + 10 * j1] > 0) return false;
			return true;
		}
		public var canMove:Boolean;
		public function enable ():void {
			canMove = true;
		}
		public function move ():void {
			if (!canMove) return;
			var i:int, j:int, i1:int, j1:int, k:int, speed:int = 20;
			// advance time
			blockT ++; blockT %= speed;
			// erase block from field
			for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) {
				if (blocks [blockI] [i + 4 * j] == 0) continue;
				i1 = i + blockX; j1 = j + blockY;
				if ((i1 < 0) || (i1 > 10 -1)) continue;
				if ((j1 < 0) || (j1 > 20 -1)) continue;
				field [i1 + 10 * j1] = 0;
			}
			// rotate blocks except O
			if ((keys [38] == true) && (blockI != 3)) {
				var block:Array = [], rotatedOk:Boolean = true;
				block [16] = blocks [blockI] [16];
				for (i = 0; rotatedOk && (i < 4); i++) for (j = 0; j < 4; j++) {
					if (blockI > 0) {
						i1 = j; j1 = 1 - (i - 1);
						k = ((j1 < 0) || (j1 > 3)) ? 0 : blocks [blockI] [i1 + 4 * j1];
					} else {
						// special "rotation" for line piece
						k = 0;
						if (blocks [0] [1] == 0) {
							if (i == 1) k = 1;
						} else {
							if (j == 1) k = 1;
						}
					}
					block [i + 4 * j] = k;
					if (k == 1) {
						i1 = i + blockX; j1 = j + blockY;
						if (!freeSpot (i1, j1)) { rotatedOk = false; break; }
					}
				}
				if (rotatedOk) {
					// replace block
					blocks [blockI] = block;
					keys [38] = false;
				}
			}
			// move left/right
			var dx:int = 0, movedOk:Boolean = true;
			if (keys [37]) dx = -1;
			if (keys [39]) dx = +1;
			for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) {
				if (blocks [blockI] [i + 4 * j] == 0) continue;
				i1 = i + blockX + dx; j1 = j + blockY;
				if (!freeSpot (i1, j1)) { movedOk = false; break; }
			}
			if (movedOk) {
				blockX += dx;
				keys [37] = false; keys [39] = false;
			}
			// move down
			var dy:int = blockT / (speed -1);
			if (keys [40]) dy = 1; movedOk = true;
			for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) {
				if (blocks [blockI] [i + 4 * j] == 0) continue;
				i1 = i + blockX; j1 = j + blockY + dy;
				if (!freeSpot (i1, j1)) { movedOk = false; break; }
			}
			if (movedOk) blockY += dy;
			// write back to field
			for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) {
				if (blocks [blockI] [i + 4 * j] == 0) continue;
				i1 = i + blockX; j1 = j + blockY;
				if ((i1 < 0) || (i1 > 10 -1)) continue;
				if ((j1 < 0) || (j1 > 20 -1)) continue;
				field [i1 + 10 * j1] = blocks [blockI] [16];
			}
			// if we could not move down, collapse the field and ask god for next block
			if (!movedOk) {
				k = 20 -1;
				while (k >= 0) {
					var sum:int = 0;
					for (i = 0; i < 10; i++) sum += (field [i + 10 * k] > 0) ? 1 : 0;
					if (sum == 10) {
						// collapse
						for (i = 0; i < 10; i++) for (j = k; j >= 0; j--) {
							field [i + 10 * j] = (j == 0) ? 0 : field [i + 10 * (j -1)];
						}
					} else {
						// next row
						k--;
					}
				}
				// next block
				blockI = int (blocks.length * Math.random ()) % blocks.length;
				blockX = 4; blockY = 0; keys [40] = false; declareBlock ();
				// is it over?
				for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) {
					if (blocks [blockI] [i + 4 * j] == 0) continue;
					i1 = i + blockX; j1 = j + blockY;
					if (!freeSpot (i1, j1)) {
						// game over
						for (i = 0; i < field.length; i++) field [i] = 0;
						break;
					}
				}
			}
		}
		public var loaded:ByteArray;
		public var loader:URLLoader;
		public var video:Loader;
		public var part_urls:Array = [
			//"part1.gif", "part2.gif", "part3.gif"
			"http://assets.wonderfl.net/images/related_images/6/6f/6faf/6faf7670b7645ab8dc7959004908253b04831b5f",
			"http://assets.wonderfl.net/images/related_images/2/21/2133/2133fd9b4ccc57fb55d95531b5d28a1ec569e981",
			"http://assets.wonderfl.net/images/related_images/e/e0/e07f/e07fd34c0a69a85515a473239bc566a7d5cc699c"
		];
		public var part:int = -1;
		public function TetrisGod () {
			// load swf pieces
			// thank you wonderfl for 500KB file limit >:(
			loaded = new ByteArray;
			loader = new URLLoader; loader.dataFormat = "binary";
			loader.addEventListener (ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener (Event.COMPLETE, onComplete);
			onComplete (null);
		}
		public function onProgress (e:ProgressEvent):void {
			var p:Number = (part + e.bytesLoaded / e.bytesTotal) / part_urls.length;
			graphics.clear ();
			graphics.lineStyle (2);
			graphics.drawRect (80, 220, 304, 34);
			graphics.lineStyle ();
			graphics.beginFill (0);
			graphics.drawRect (82, 222, 300 * p, 30);
			graphics.endFill ();
		}
		public function onComplete (e:Event):void {
			part++; 
			if (part > 0) {
				var ba:ByteArray = loader.data;
				ba.position = 959; // skip gif prefix
				ba.readBytes (loaded, loaded.length, ba.bytesAvailable);
			}

			if (part < part_urls.length) {
				loader.load (new URLRequest (part_urls [part]));
			} else {
				// load swf
				loaded.position = 0;
				video = new Loader;
				video.contentLoaderInfo.addEventListener (Event.COMPLETE, init);
				video.loadBytes (loaded);
			}
		}
		public function declareBlock ():void {
			canMove = false;
			video.content ["speak"] (blockI);
			setTimeout (enable, 2000);
		}
		public function init (e:Event):void {
			graphics.clear ();
			video.scaleX = 2.00;
			video.scaleY = 1.91;
			addChild (video);
			declareBlock ();
			stage.addEventListener (KeyboardEvent.KEY_DOWN, handleKeys);
			stage.addEventListener (KeyboardEvent.KEY_UP, handleKeys);
			stage.addEventListener (Event.ENTER_FRAME, draw);
			setInterval (move, 50);
			stage.focus = stage;
		}
	}
}