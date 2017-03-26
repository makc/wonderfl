// This fork adds 16579 levels from
// http://www.sourcecode.se/sokoban/levels.php
//
// At the rate of five minutes per level, it
// would take you two months of non-stop playing
// to beat them all :)
//
// Controls: HJKL, WASD or arrows.
// Have fun!
package {
	import com.bit101.components.List;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.TextArea;
    import flash.display.*;
    import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	[SWF(width=465,height=465)]
    public class Sokoban extends Sprite {
        private var T:int = 16;
        private var s:Array;
        private var b:Array,f:Array,v:Array;
        private var u:int,w:int;

		private var progress:ProgressBar;
		private var list1:List;
		private var list2:List;
		private var info:TextArea;
		private var zip1:ByteArray = new ByteArray;
		private var zip2:ByteArray = new ByteArray;
        public function Sokoban () {
			progress = new ProgressBar (this, 100, 300);
			progress.width = 265;

			var loader:URLLoader = new URLLoader;
			loader.dataFormat = "binary";
			loader.addEventListener (ProgressEvent.PROGRESS, onProgress1);
			loader.addEventListener (Event.COMPLETE, onComplete1);
			loader.load (new URLRequest (/*"levels_1.gif"*/"http://assets.wonderfl.net/images/related_images/d/db/db35/db35aa47d5233b80ac22d4548a27e9770f8b3c8d"));
		}
		private function onProgress1 (e:ProgressEvent):void {
			progress.value = 0.5 * e.bytesLoaded / e.bytesTotal;
		}
		private function onProgress2 (e:ProgressEvent):void {
			progress.value = 0.5 * e.bytesLoaded / e.bytesTotal + 0.5;
		}
		private function onComplete1 (e:Event):void {
			var loader:URLLoader = URLLoader (e.target);
			loader.removeEventListener (ProgressEvent.PROGRESS, onProgress1);
			loader.removeEventListener (Event.COMPLETE, onComplete1);

			ByteArray (loader.data).position = 2305;
			ByteArray (loader.data).readBytes (zip1, 0);
			zip1.uncompress ();

			loader = new URLLoader;
			loader.dataFormat = "binary";
			loader.addEventListener (ProgressEvent.PROGRESS, onProgress2);
			loader.addEventListener (Event.COMPLETE, onComplete2);
			loader.load (new URLRequest (/*"levels_2.gif"*/"http://assets.wonderfl.net/images/related_images/8/80/804d/804ddc40164b123939dfc729483def6d22d41584"));
		}
		private function onComplete2 (e:Event):void {
			var loader:URLLoader = URLLoader (e.target);
			loader.removeEventListener (ProgressEvent.PROGRESS, onProgress2);
			loader.removeEventListener (Event.COMPLETE, onComplete2);

			ByteArray (loader.data).position = 2305;
			ByteArray (loader.data).readBytes (zip2, 0);
			zip2.uncompress ();

			// merge
			zip2.readBytes (zip1, zip1.length);

			// parse
			setTimeout (parse, 123);
		}
		private function parse ():void {
			var lines:Array = zip1.toString ().split (/[\n\r]+/);
			var items:Array = [];
			var collection:LevelCollection = new LevelCollection;
			for (var i:int = 6; i < lines.length; i++) {
				// start parsing collection
				var line:String = String (lines [i]);
				if (line == "") line = ";";
				if (line.charAt (0) == ";") {
					var line1:String = line.substr (1);
					if (collection.label == "")
						collection.label = line1;
					collection.description += line1 + "\n";
				} else {
					// this is 1st line of level 1
					while (line.charAt (0) != "<") {
						var level:Level = new Level;
						while (line.charAt (0) != ";") {
							if (line != "")
								level.map.push (line);
							i++; line = String (lines [i]);
						}
						level.label = line.substr (1);
						collection.levels.push (level);
						while (line.charAt (0) == ";") {
							// skip other ;-ed lines
							i++; line = String (lines [i]);
						}
					}
					items.push (collection);
					collection = new LevelCollection;
					// skip to next html, if any
					i += 8;
				}
			}

			// set up basic ui
			removeChild (progress);
			list1 = new List (this, 0, 365);
			list2 = new List (this, list1.width, 365);
			info = new TextArea (this, list1.width * 2, 365);
			info.editable = false; info.width = 465 - info.x;

			list1.items = items;

			list1.addEventListener (Event.SELECT, onSelect1);
			list2.addEventListener (Event.SELECT, onSelect2);

			stage.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		private function onSelect1 (e:Event):void {
			// show collection info
			info.text = LevelCollection (list1.selectedItem).description;
			// show levels list
			list2.items = LevelCollection (list1.selectedItem).levels;
		}
		private function onSelect2 (e:Event):void {
            s = Level (list2.selectedItem).map;
            var ll:int = 0;
            b = []; f = [];
            for (var j:int = 0; j < s.length; ++j) {
                b[j] = [];
                f[j] = [];
                var l:String = s[j];
                if (ll < l.length) ll = l.length;
                for (var i:int = 0; i < l.length; ++i) {
                    switch (l.charAt(i)) {
                    case '#':
                        b[j][i] = 1;
                        break;
                    case '.':
                        b[j][i] = 2;
                        break;
                    case '$':
                        f[j][i] = 3;
                        break;
                    case '@':
                        f[j][i] = 4;
                        u = i;
                        w = j;
                        break;
					case '*':
						b[j][i] = 2;
						f[j][i] = 3;
						break;
					case '+':
						b[j][i] = 2;
						f[j][i] = 4;
                        u = i;
                        w = j;
                        break;
                    default:
                        b[j][i]=f[j][i]=0;
                    }
                }
            }
            T = Math.min (16, 465 / ll);
            redraw();
        }
		private function onKeyDown (e:KeyboardEvent):void {
			if (list2.selectedItem == null) return;
                v = null;
                switch (e.keyCode) {
                case 72: // H
				case 37: // left
				case 65: // A
                    v = [-1,0];
                    break;
                case 74: // J
				case 40: // down
				case 83: // S
                    v = [0,1];
                    break;
                case 75: // K
				case 38: // up
				case 87: // W
                    v = [0,-1];
                    break;
                case 76: // L
				case 39: // right
				case 68: // D
                    v = [1,0];
                    break;
                }
                if (v) {
                    var s:String="";
                    for(var i:int=u,j:int=w;0<=j&&j<b.length&&0<=i&&i<b[j].length;i+=v[0],j+=v[1])
                        s+=int(f[j][i]?f[j][i]:b[j][i]);
                    if (s.search(/[02]/)==1)
                        move(v);
                    if (s.search(/3[02]/)==1){
                        move(v);
                        f[w + v[1]][u + v[0]] = 3;
                    }
                }
                redraw();
		}

        private function move(v:Array):void {
            f[w][u] = 0;
            u += v[0];
            w += v[1];
            f[w][u] = 4;
        }

        private function redraw():void {
            graphics.clear();
            graphics.lineStyle(1,0);
            for (var j:int = 0; j < b.length; ++j) {
                for (var i:int = 0; i < b[j].length; ++i) {
                    switch (f[j][i]?f[j][i]:b[j][i]) {
                    case 1:
                        graphics.beginFill(0);
                        graphics.drawRect(i*T,j*T,T,T);
                        graphics.endFill();
                        break;
                    case 2:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/8);
                        break;
                    case 3:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/2);
                        break;
                    case 4:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/2);
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/4);
                        break;
                    }
                }
            }
        }
    }
}

class Level {
	public var label:String = "";
	public var map:Array = [];
}

class LevelCollection {
	public var label:String = "";
	public var levels:Array = [];
	public var description:String = "";
}