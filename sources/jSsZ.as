// AutomatonRGB
//  Red: fire.  Green: tree.  Blue: water.
//  <Operation>
//   Mouse Drag: Place fire/tree/water.
//   [R][G][B]: Change type of placed object.
//   [C]      : Clear a field.
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
// Initializer.
function initialize():void {
    field = new Field;
}
// Update a field.
var ticks:int;
var placedType:int = Field.FIRE;
function update():void {
    if (ticks++ % 10 == 0) field.update();
    if (keys[82]) { keys[82] = false; placedType = Field.FIRE; }
    if (keys[71]) { keys[71] = false; placedType = Field.TREE; }
    if (keys[66]) { keys[66] = false; placedType = Field.WATER; }
    var cx:int = main.stage.mouseX / Field.CELL_PIXEL;
    var cy:int = main.stage.mouseY / Field.CELL_PIXEL;
    if (cx < 0) cx = 0; else if (cx >= Field.SIZE) cx = Field.SIZE - 1;
    if (cy < 0) cy = 0; else if (cy >= Field.SIZE) cy = Field.SIZE - 1;
    if (isMousePressed) field.cells[cx + cy * Field.SIZE] = placedType;
    if (keys[67]) { keys[67] = false; field = new Field; ticks = 0; }
    field.draw();
    field.drawCell(cx, cy, placedType);
}
// Field consists of cells.
var field:Field;
class Field {
    public static const BLANK:int = 0, FIRE:int = 1, TREE:int = 2, WATER:int = 3;
    public static const SIZE:int = 31, CELL_PIXEL:int = SCREEN_WIDTH / SIZE;
    public var cells:Vector.<int> = new Vector.<int>(SIZE * SIZE);
    private var rect:Rectangle = new Rectangle(0, 0, CELL_PIXEL - 1, CELL_PIXEL - 1);
    private var cellsPrev:Vector.<int> = new Vector.<int>(SIZE * SIZE);
    private var colors:Array = [[100, 100, 50], [250, 0, 0], [50, 250, 50], [50, 50, 250]];
    public function Field() {
        for (var i:int = 0; i < SIZE; i++) cells[randi(SIZE) + randi(SIZE) * SIZE] = randi(2) + TREE;
    }
    public function update():void {
        var i:int;
        for (i = 0; i < SIZE * SIZE; i++) cellsPrev[i] = cells[i];
        for (var x:int = 0; x < SIZE; x++) for (var y:int = 0; y < SIZE; y++) {
            i = x + y * SIZE;
            var c:int = cellsPrev[i];
            if (c == TREE && checkAround(x, y, FIRE)) cells[i] = FIRE;
            else if (c == FIRE) cells[i] = BLANK;
            else if (c == BLANK && checkAround(x, y, TREE) && checkAround(x, y, WATER)) cells[i] = TREE;
            else if (c == BLANK && checkAround(x, y, WATER)) cells[i] = WATER;
            else if (c == WATER && checkAround(x, y, FIRE)) cells[i] = BLANK;
            else if (c == WATER && checkAround(x, y, WATER, true)) cells[i] = TREE;
        }
    }
    public function draw():void {
        for (var x:int = 0; x < SIZE; x++) for (var y:int = 0; y < SIZE; y++) drawCell(x, y, cells[x + y * SIZE]);
    }
    public function drawCell(x:int, y:int, c:int):void {
        rect.x = x * CELL_PIXEL;
        rect.y = y * CELL_PIXEL;
        var color:int = colors[c][0] * 0x10000 + colors[c][1] * 0x100 + colors[c][2];
        bd.fillRect(rect, color);
    }
    private function checkAround(cx:int, cy:int, p:int, all:Boolean = false):Boolean {
        for (var ox:int = -1; ox <= 1; ox++) for (var oy:int = -1; oy <= 1; oy++) {
            if (ox == 0 && oy == 0) continue;
            var x:int = cx + ox, y:int = cy + oy;
            if (x < 0 || x >= SIZE || y < 0 || y >= SIZE) continue;
            if (all) {
                if (cellsPrev[x + y * SIZE] != p) return false;
            } else {
                if (cellsPrev[x + y * SIZE] == p) return true;
            }
        }
        return all;
    }
}
import flash.display.*;
import flash.geom.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Main, bd:BitmapData;
var isMousePressed:Boolean, keys:Vector.<Boolean> = new Vector.<Boolean>(256);
// Initialize a bitmapdata and events.
function initializeFirst():void {
    bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
    bd.fillRect(bd.rect, 0);
    main.addChild(new Bitmap(bd));
    main.stage.addEventListener(MouseEvent.MOUSE_DOWN, function (e:Event):void { isMousePressed = true; });
    main.stage.addEventListener(MouseEvent.MOUSE_UP, function (e:Event):void { isMousePressed = false; });
    main.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
    initialize();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
// Update the frame.
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, 0);
    update();
    bd.unlock();
}
// Utility functions.
function randi(n:int):Number {
    return int(Math.random() * n);
}