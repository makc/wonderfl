// ProceduralAutomaton
//  Procedural generated cellular automaton.
//  <Operation>
//   [N]       : Generate a next automaton.
//   Mouse Drag: Place R/G/B cell.
//   [R][G][B] : Change type of placed cell.
//   [C]       : Reset a field with the same rule.
package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initializeFirst(); }
    }
}
// Initializer.
var seedText:TextField, messageText:TextField;
function initialize():void {
    seedText = createTextField(0, 0, 15, 300, 20, 0xffffff);
    messageText = createTextField(0, 445, 15, 300, 20, 0xffffff);
    messageText.text = "Push [N] key to generate a next automaton.";
    main.addChild(seedText); main.addChild(messageText);
    setRandomSeed((new Date).getTime());
    createNewAutomaton();
}
function createNewAutomaton():void {
    var i:int;
    do {
        automaton = new Automaton;
        automaton.initialize();
        field = new Field;
        for (i = 0; i < 32; i++) {
            field.update();
            if (!field.isChanged || !field.isChangedFromPrevPrev) break;
        }
    } while (i < 32);
    automaton.removeUnusedRules();
    field = new Field;
    ticks = 0;
    seedText.text = "Rule #" + automaton.seed;
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
    if (keys[78]) {    keys[78] = false; createNewAutomaton(); }
    field.draw();
    field.drawCell(cx, cy, placedType);
    automaton.drawRules();
}
// Field consists of cells.
var field:Field;
class Field {
    public static const BLANK:int = 0, FIRE:int = 1, TREE:int = 2, WATER:int = 3;
    public static const SIZE:int = 31, CELL_PIXEL:int = SCREEN_WIDTH / SIZE;
    public var cells:Vector.<int> = new Vector.<int>(SIZE * SIZE);
    private var rect:Rectangle = new Rectangle(0, 0, CELL_PIXEL - 1, CELL_PIXEL - 1);
    private var cellsPrev:Vector.<int> = new Vector.<int>(SIZE * SIZE);
    private var cellsPrevPrev:Vector.<int> = new Vector.<int>(SIZE * SIZE);
    private var colors:Array = [[100, 100, 50], [250, 0, 0], [50, 250, 50], [50, 50, 250]];
    public function Field() {
        for (var i:int = 0; i < SIZE; i++) {
            cells[randi(SIZE) + randi(SIZE) * SIZE] = randi(automaton.typeCount - 1) + 1;
        }
    }
    public function update():void {
        for (var i:int = 0; i < SIZE * SIZE; i++) {
            cellsPrevPrev[i] = cellsPrev[i];
            cellsPrev[i] = cells[i];
        }
        for (var x:int = 0; x < SIZE; x++) for (var y:int = 0; y < SIZE; y++) automaton.updateCell(x, y);
    }
    public function get isChanged():Boolean {
        for (var i:int = 0; i < SIZE * SIZE; i++) if (cellsPrev[i] != cells[i]) return true;
        return false;
    }
    public function get isChangedFromPrevPrev():Boolean {
        for (var i:int = 0; i < SIZE * SIZE; i++) if (cellsPrevPrev[i] != cells[i]) return true;
        return false;
    }
    public function draw():void {
        for (var x:int = 0; x < SIZE; x++) for (var y:int = 0; y < SIZE; y++) drawCell(x, y, cells[x + y * SIZE]);
    }
    public function drawCell(x:int, y:int, c:int):void {
        rect.x = x * CELL_PIXEL;
        rect.y = y * CELL_PIXEL;
        bd.fillRect(rect, getColor(c));
    }
    public function getColor(c:int):int {
        return colors[c][0] * 0x10000 + colors[c][1] * 0x100 + colors[c][2];
    }
    public function set(x:int, y:int, c:int):void {
        cells[x + y * SIZE] = c;
    }
    public function get(x:int, y:int):int {
        return cells[x + y * SIZE];
    }
    public function checkAround(cx:int, cy:int, p:int):int {
        var c:int;
        for (var ox:int = -1; ox <= 1; ox++) for (var oy:int = -1; oy <= 1; oy++) {
            if (ox == 0 && oy == 0) continue;
            var x:int = cx + ox, y:int = cy + oy;
            if (x < 0 || x >= SIZE || y < 0 || y >= SIZE) continue;
            if (cellsPrev[x + y * SIZE] == p) c++;
        }
        return c;
    }
}
// Generated automaton.
var automaton:Automaton;
class Automaton {
    public var seed:int;
    public var typeCount:int;
    public var rules:Vector.<Rule> = new Vector.<Rule>;
    public function Automaton() {
        seed = randn(int.MAX_VALUE);
        setRandomSeed(seed);
        typeCount = randi(3) + 2;
    }
    public function initialize():void {
        var types:Vector.<int> = new Vector.<int>;
        var i:int;
        for (i = 0; i < typeCount; i++) types.push(i);
        for (i = 0; i < typeCount; i++) {
            var t:int = randi(types.length);
            rules.push(new Rule(types[t]));
            types.splice(t, 1);
        }
        var rc:int = randi(3);
        for (i = 0; i < rc; i++) rules.push(new Rule(randi(typeCount)));
    }
    public function removeUnusedRules():void {
        for (var i:int = 0; i < rules.length; i++) if (!rules[i].isUsed) { rules.splice(i, 1); i--; }
    }
    public function updateCell(x:int, y:int):void {
        for (var i:int = rules.length - 1; i >= 0; i--) rules[i].updateCell(x, y);
    }
    public function drawRules():void {
        var y:int = 20;
        for each (var r:Rule in rules) {
            r.draw(10, y); y += Rule.CELL_PIXEL * 4;
        }
    }
}
// Rule for changing a cell.
class Rule {
    public static const CELL_PIXEL:int = Field.CELL_PIXEL * 0.7;
    public var centerType:int, aroundType:int, nextType:int;
    public var minAroundCount:int, maxAroundCount:int;
    public var isUsed:Boolean;
    private var rect:Rectangle = new Rectangle(0, 0, CELL_PIXEL - 1,  CELL_PIXEL - 1);
    private var rectInner:Rectangle = new Rectangle(0, 0, CELL_PIXEL - 3,  CELL_PIXEL - 3);
    private var rectBox:Rectangle = new Rectangle(0, 0, CELL_PIXEL * 3 + 1,  CELL_PIXEL * 3 + 1);
    private var rectArrow:Rectangle = new Rectangle(0, 0, CELL_PIXEL * 0.5 - 1,  CELL_PIXEL * 0.5 - 1);
    public function Rule(centerType:int) {
        this.centerType = centerType;
        aroundType = randi(automaton.typeCount);
        nextType = randi(automaton.typeCount);
        if (nextType == centerType) {
            nextType++; if (nextType >= automaton.typeCount) nextType = 0;
        }
        minAroundCount = randi(8) + 1;
        maxAroundCount = minAroundCount + randi(9 - minAroundCount);
    }
    public function updateCell(x:int, y:int):void {
        if (field.get(x, y) != centerType) return;
        var c:int = field.checkAround(x, y, aroundType);
        if (c >= minAroundCount && c <= maxAroundCount) {
            field.set(x, y, nextType);
            isUsed = true;
        }
    }
    public function draw(x:int, y:int):void {
        drawCells(x, y, centerType);
        drawArrow(x + CELL_PIXEL * 3.5, y);
        drawCells(x + CELL_PIXEL * 6, y, nextType);
    }
    private const offsets:Array = [0, 0, 1, 0, 2, 0, 0, 1, 2, 1, 0, 2, 1, 2, 2, 2];
    private function drawCells(x:int, y:int, c:int):void {
        rectBox.x = x - 1; rectBox.y = y - 1;
        bd.fillRect(rectBox, 0);
        rect.x = x + CELL_PIXEL; rect.y = y + CELL_PIXEL;
        bd.fillRect(rect, field.getColor(c));
        for (var i:int = 0; i < maxAroundCount; i++) {
            rect.x = x + offsets[i * 2] * CELL_PIXEL;
            rect.y = y + offsets[i * 2 + 1] * CELL_PIXEL;
            bd.fillRect(rect, field.getColor(aroundType));
            if (i < minAroundCount - 1) {
                rectInner.x = rect.x + 1;
                rectInner.y = rect.y + 1;
                bd.fillRect(rectInner, 0);
            }
        }
    }
    private const arrowColor:int = 0xffffff;
    private function drawArrow(x:int, y:int):void {
        for (var i:int = 0; i < 4; i++) {
            rectArrow.x = x + i * CELL_PIXEL * 0.5; rectArrow.y = y + CELL_PIXEL * 1.3;
            bd.fillRect(rectArrow, arrowColor);
            if (i == 2) {
                rectArrow.y = y + CELL_PIXEL * 0.75; bd.fillRect(rectArrow, arrowColor);
                rectArrow.y = y + CELL_PIXEL * 1.75; bd.fillRect(rectArrow, arrowColor);
            } else if (i == 1) {
                rectArrow.y = y + CELL_PIXEL * 0.4; bd.fillRect(rectArrow, arrowColor);
                rectArrow.y = y + CELL_PIXEL * 2.25; bd.fillRect(rectArrow, arrowColor);
            }
        }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
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
function createTextField(x:int, y:int, size:int, width:int, height:int, color:int):TextField {
    var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
    fm.size = size; fm.color = color; fm.leftMargin = 0;
    fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height; fi.selectable = false;
    return fi;
}
function randi(n:int):int {
    return random() * n;
}
function randn(n:int):Number {
    return random() * n;
}
var xorShiftX:int = 123456789, xorShiftY:int = 362436069, xorShiftZ:int = 521288629, xorShiftW:int = 88675123;
function setRandomSeed(v:int):void {
    var sv:int = v;
    xorShiftX = sv = 1812433253 * (sv ^ (sv >> 30));
    xorShiftY = sv = 1812433253 * (sv ^ (sv >> 30)) + 1;
    xorShiftZ = sv = 1812433253 * (sv ^ (sv >> 30)) + 2;
    xorShiftW = sv = 1812433253 * (sv ^ (sv >> 30)) + 3;
}
function random():Number {
    var t:int = xorShiftX ^ (xorShiftX << 11);
    xorShiftX = xorShiftY; xorShiftY = xorShiftZ; xorShiftZ = xorShiftW;
    xorShiftW = (xorShiftW ^ (xorShiftW >> 19)) ^ (t ^ (t >> 8));
    return Number(xorShiftW) / int.MAX_VALUE;
}