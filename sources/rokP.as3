// This fork adds some automation to play
// some big-ass levels faster :)
//
// The game features 16579 levels from
// http://www.sourcecode.se/sokoban/levels.php
//
// At the rate of five minutes per level, it
// would take you two months of non-stop playing
// to beat them all :)
//
// Controls: 
// - HJKL, WASD or arrows,
// - click free spot to walk there,
// - Numpad +/- to zoom in/out
//
// Have fun!
package {
    import com.bit101.components.Label;
    import com.bit101.components.List;
    import com.bit101.components.Panel;
    import com.bit101.components.ProgressBar;
    import com.bit101.components.TextArea;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;
    import mx.utils.Base64Decoder;
    
    [SWF(width=465,height=465)]
    public class Sokoban extends Sprite {
        private var T:int = 16;
		private var Tmin:int = 4, Tmax:int = 123;
        private var s:Array;
        private var b:Array,f:Array,v:Array,wa:Array;
        private var u:int,w:int;
		private var path:Vector.<Point>, astar:AStar = new AStar;

        private var progress:ProgressBar;
        private var list1:List;
        private var list2:List;
        private var info:TextArea;
        private var zip1:ByteArray = new ByteArray;
        private var zip2:ByteArray = new ByteArray;
        private var skin:BitmapData;
        private var defs:Object;
        private var rows:int;
        private var cols:int;
        private var infoPanel:Panel;
        private var moves:int = 0;
        
        public function Sokoban () {
            progress = new ProgressBar (this, 100, 300);
            progress.width = 265;

            loadSkin();
        }
        
        private function loadSkin():void 
        {
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = "binary";
            loader.addEventListener (ProgressEvent.PROGRESS, onProgress0);
            loader.addEventListener(Event.COMPLETE, skin_complete);
            loader.load(new URLRequest(/*"skin.gif"*/"http://assets.wonderfl.net/images/related_images/d/df/df99/df999684a5544c7d7b8571e4e19205e3de08c1fd"));
        }
        private function skin_complete(e:Event):void 
        {
            var loader:URLLoader = URLLoader(e.target);
            var ba:ByteArray = ByteArray(loader.data);
            ba.position = 2305;
            var zip:ByteArray = new ByteArray();
            ba.readBytes(zip, 0);
            zip.uncompress();
            
            var src:Array = String(zip.readUTFBytes(zip.length)).split(/\[[A-Z]+\]/);
            var lines:Array = src[2].split(/[\r\n]+/);
            defs = { };
            for each(var line:String in lines) {
                var p:Array = line.split(/\s*=\s*/);
                if (p[0].length) defs[p[0]] = parseInt(p[1]);
            }
            
            var rawImg:String = src[3];
            var dec:Base64Decoder = new Base64Decoder();
            dec.decode(rawImg);
            ba = dec.toByteArray();
            var img:Loader = new Loader();
            img.loadBytes(ba);
            img.contentLoaderInfo.addEventListener(Event.COMPLETE, skin_loaded);
        }
        private function skin_loaded(e:Event):void 
        {
            skin = (e.target.content as Bitmap).bitmapData;
            loadLevels();
        }
        
        private function loadLevels():void {
            var loader:URLLoader = new URLLoader;
            loader.dataFormat = "binary";
            loader.addEventListener (ProgressEvent.PROGRESS, onProgress1);
            loader.addEventListener (Event.COMPLETE, onComplete1);
            loader.load (new URLRequest (/*"levels_1.gif"*/"http://assets.wonderfl.net/images/related_images/d/db/db35/db35aa47d5233b80ac22d4548a27e9770f8b3c8d"));
        }
        private function onProgress0 (e:ProgressEvent):void {
            progress.value = 0.33 * e.bytesLoaded / e.bytesTotal;
        }
        private function onProgress1 (e:ProgressEvent):void {
            progress.value = 0.33 * e.bytesLoaded / e.bytesTotal + 0.33;
        }
        private function onProgress2 (e:ProgressEvent):void {
            progress.value = 0.33 * e.bytesLoaded / e.bytesTotal + 0.66;
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
			stage.addEventListener (MouseEvent.CLICK, onClick);
			stage.addEventListener (Event.ENTER_FRAME, onPathFound);
        }
        private function onSelect1 (e:Event):void {
            // show collection info
            info.text = LevelCollection (list1.selectedItem).description;
            // show levels list
            list2.items = LevelCollection (list1.selectedItem).levels;
        }
        private function onSelect2 (e:Event):void {
            if (infoPanel) { removeChild(infoPanel); infoPanel = null; }
            moves = 0; path = null;
            s = Level (list2.selectedItem).map;
            b = []; f = []; 
            rows = s.length;
            cols = 0;
            for (var j:int = 0; j < rows; ++j) {
                b[j] = [];
                f[j] = [];
                var l:String = s[j];
                if (cols < l.length) cols = l.length;
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
            
            var cpt:int = 0;
            wa = [];
            for (j = 0; j < rows; ++j) {
                wa[j] = [];
                for (i = 0; i < cols; ++i) {
                    if (b[j][i] != 1) continue;
                    var n:int = 0;
                    if (j > 0 && b[j - 1][i] == 1) n = 1;
                    if (b[j][i + 1] == 1) n += 2;
                    if (j < rows - 1 && b[j + 1][i] == 1) n += 4;
                    if (i > 0 && b[j][i - 1] == 1) n += 8;
                    wa[j][i] = n.toString(16).toUpperCase();
                }
            }
            T = int(Math.min (25, Math.min(365 / rows, 465 / cols)));
            redraw();
        }
        private function onKeyDown (e:KeyboardEvent):void {
            if (userInputNotAllowed ()) return;
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
                case 107: // +
                    if (T < Tmax) T++;
                    break;
                case 109: // -
                    if (T > Tmin) T--;
                    break;
                }
				processMoveCommand (v);
                redraw();
        }

		private function processMoveCommand (v:Array):void {
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
		}

        private function move(v:Array):void {
            f[w][u] = 0;
            u += v[0];
            w += v[1];
            f[w][u] = 4;
            moves ++;
        }

		private function userInputNotAllowed ():Boolean {
			return (list2.selectedItem == null) || (path != null);
		}

		private function isFreeToGo (mX:int, mY:int, includePlayer:Boolean):Boolean {
			if (mY < rows) {
				if (mX < cols) {
					// is there any rule to this...
					if (((b[mY][mX] == 2) && (f[mY][mX] == undefined)) ||
						((b[mY][mX] == undefined) && (f[mY][mX] == 0)) ||
						((b[mY][mX] == 2) && (f[mY][mX] == 0)) ||
						((b[mY][mX] == 0) && (f[mY][mX] == 0)) ||
						(includePlayer    && (f[mY][mX] == 4))) {
						// this may be free spot
						return true;
					}
				}
			}
			return false;
		}

        private function onClick (e:MouseEvent):void {
            if (userInputNotAllowed ()) return;

			var mX:int = mouseX / T;
			var mY:int = mouseY / T;
			if (isFreeToGo (mX, mY, false)) { trace ("!");
				// update astar.map
				astar.map = [];
				for (var _y:int = 0; _y < rows; _y++) {
					astar.map [_y] = [];
					for (var _x:int = 0; _x < cols; _x++) {
						astar.map [_y] [_x] = isFreeToGo (_x, _y, true) ? 1 : 0;
					}
				}
				// find path
				path = astar.findPath (new Point (u, w), new Point (mX, mY));
			}
		}

		private function onPathFound (e:Event):void {
			if (path) {
				if (path.length > 0) {
					var pt:Point = path.shift ();
					processMoveCommand (v = [pt.x - u, pt.y - w]);
					redraw ();
				} else {
					path = null;
				}
			}
		}

        private function redraw():void {
            graphics.clear();
            var s:Number = T / skin.height;
            var m:Matrix = new Matrix();
            var finished:Boolean = true;
            for (var j:int = 0; j < rows; ++j) {
                for (var i:int = 0; i < cols; ++i) {
                    var tex:String = null;
                    switch (f[j][i]?f[j][i]:b[j][i]) {
                    case 1:
                        tex = "Wall_" + wa[j][i];
                        break;
                    case 2:
                        tex = "Goal";
                        break;
                    case 3:
                        tex = b[j][i] == 2 ? "Pack_Goal" : "Pack";
                        if (tex == "Pack") finished = false;
                        break;
                    case 4:
                        tex = b[j][i] == 2 ? "Man_Goal" : "Man";
                       break;
                    default: tex = "Floor";
                    }
                    if (!(tex in defs)) tex = "Floor";
                    var idx:int = defs[tex];
                    var cx:int = i * T;
                    var cy:int = j * T;
                    m.identity(); m.scale(s, s); 
                    m.translate(cx - idx * T, cy);
                    graphics.beginBitmapFill(skin, m, false, true);
                    graphics.drawRect(cx, cy, T, T);
                    graphics.endFill();
                }
            }
            
            if (finished && !infoPanel)
            {
                infoPanel = new Panel(this, 100, 150);
                infoPanel.setSize(265, 65);
                var l:Label = new Label(infoPanel, 20, 25, "Congratulations, you solved it in " + moves + " moves!");
                l.x = (265 - l.width) / 2;
                setTimeout(function ():void { infoPanel.visible = false; }, 3000);
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

import flash.geom.Point;

/**
 * Dijkstra A*経路探索
 * http://gingama.hp.infoseek.co.jp/java/a_star.html
 *
 * Code stolen from http://wonderfl.net/c/7230
 * @author svartalf
 */
class AStar 
{	
	private var startNode:Node;
	private var goalNode:Node;
	
	private var openList:Array;
	private var closeList:Array;
	
	private var dir4:Array = [[0, -1], [-1, 0], [0, 1], [1, 0]];

	/**
	 * 1 free, 0 obstacle.
	 */
	public var map:Array =    [[1,1,1,1,1,1,1,1,1,1],
								[1,1,1,1,1,1,1,1,1,1],
								[1,1,1,1,1,1,1,1,1,1],
								[1,0,0,0,0,0,0,1,1,1],
								[1,1,1,1,1,1,0,1,1,1],
								[1,1,1,1,1,1,0,1,1,1],
								[1,1,1,1,1,1,0,1,1,1],
								[1,1,1,1,1,1,0,1,1,1],
								[1,1,1,1,1,1,0,1,1,1],
								[1,1,1,1,1,1,1,1,1,1]
	];
	
	private var nodeMap:Array;

	/**
	 * Assumes map is already set.
	 * @param	from
	 * @param	to
	 */
	public function findPath (from:Point, to:Point):Vector.<Point> 
	{
		startNode = new Node(from.x,from.y,0,null)
		goalNode = new Node(to.x,to.y,0,null);
		
		openList = [startNode];
		closeList = [];
		
		makeNodeMap();
		
		return searchMap();
	}
	
	/**
	 * mapからnodeMapを作成
	 */
	private function makeNodeMap():void
	{
		nodeMap = [];
		for (var y:int = 0; y < map.length; y++ )
		{
			nodeMap[y] = [];
			for (var x:int = 0; x < map[0].length; x++)
			{
				nodeMap[y][x] = new Node(x,y,0,null);//配列だとxyが逆になるので注意！
			}
		}
	}
	
	/**
	 * A*経路探索
	 */
	private function searchMap():Vector.<Point>
	{
		var totalCost:int = 0;
		while (openList.length != 0)
		{
			openList.sortOn(["cost"], Array.NUMERIC | Array.DESCENDING);
			var cnode:Node = openList.pop();
			
			closeList.push(cnode);
			
			if (cnode.x == goalNode.x && cnode.y == goalNode.y)
			{
				return prevNodeSearch();
			}
			
			var diffX:int;
			var diffY:int;
			var posX:int;
			var posY:int;
			var targetNode:Node;
			
			for (var i:int = 0; i < dir4.length; i++ )
			{
				diffX = dir4[i][0];
				diffY = dir4[i][1];
				posX = cnode.x + diffX;
				posY = cnode.y + diffY;
				
				if ( posX >= 0 && posX < map[0].length && posY >= 0 && posY < map.length)
				{
					targetNode = nodeMap[posY][posX];
					
					if ( targetNode.cost == 0 && map[posY][posX] == 1)
					{
						targetNode.cost = Math.sqrt( Math.pow((goalNode.x - targetNode.x), 2) + Math.pow((goalNode.y - targetNode.y), 2)) + totalCost;
						targetNode.prevNode = cnode;
						nodeMap[posY][posX] = targetNode;
						openList.push(targetNode);
					}
				}
			}
			totalCost++;
		}

		// if here, we did not find shit :(
		return null;
	}
	
	/**
	 * 結果出力
	 */
	private function prevNodeSearch():Vector.<Point>
	{
		var result:Vector.<Point> = new Vector.<Point>;
		
		var node:Node = closeList.pop ();
		
		while (node.prevNode != null)
		{
			result.unshift (new Point (node.x, node.y));
			node = node.prevNode;
		}

		// maybe returning Node would be better idea?
		return result;
	}
}

/**
 * ノードクラス
 */
class Node
{
	private var _x:int;
	public function get x():int
	{
		return _x;
	}
	
	private var _y:int;
	public function get y():int
	{
		return _y;
	}
	
	private var _cost:Number;
	public function get cost():Number
	{
		return _cost;
	}
	public function set cost(value:Number):void
	{
		_cost = value;
	}
	
	private var _prevNode:Node;
	public function get prevNode():Node
	{
		return _prevNode;
	}
	public function set prevNode(value:Node):void
	{
		_prevNode = value;
	}
	
	public function Node(x:int, y:int, cost:Number = 0, prevNode:Node = null):void
	{
		_x = x;
		_y = y;
		_cost = cost;
		_prevNode = prevNode;
	}
}