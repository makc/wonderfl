package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundClr="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() {
            main = this;
            initializeFirst();
        }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import flash.events.*;
import flash.text.*;
import org.si.sion.*;
const SCR_WIDTH:int = 465, SCR_HEIGHT:int = 465;
var main:Main, bd:BitmapData;
var baseSprite:Sprite;
var bgColor:uint = 0;
function initializeFirst():void {
    scr = new Scr;
    bd = new BitmapData(scr.size.x, scr.size.y, false, bgColor);
    baseSprite = new Sprite;
    baseSprite.addChild(new Bitmap(bd));
    main.addChild(new Bitmap(new BitmapData(scr.size.x, scr.size.y, false, bgColor)));
    main.addChild(baseSprite);
    mse = new Mse;
    initialize();
    main.addEventListener(Event.ENTER_FRAME, updateFrame);
}
function updateFrame(event:Event):void {
    bd.lock();
    bd.fillRect(bd.rect, bgColor);
    update();
    bd.unlock();
}
class Vct extends Vector3D {
    public function Vct(x:Number = 0, y:Number = 0) {
        super(x, y);
    }
    public function set xy(v:Vector3D):void {
        x = v.x;
        y = v.y;
    }
}
var scr:Scr;
class Scr {
    public var size:Vct = new Vct(SCR_WIDTH, SCR_HEIGHT);
    public var center:Vct = new Vct(size.x / 2, size.y / 2);
    private var textField:TextField = new TextField;
    private var textFormat:TextFormat;
    public function Scr() {
        textFormat = new TextFormat("_typewriter");
        textFormat.size = 11; textFormat.bold = true;
        textFormat.align = TextFormatAlign.CENTER;
        textField.width = 256; textField.height = 20;
    }
    private var matrix:Matrix = new Matrix;
    public function drawText(text:String, x:int, y:int, color:uint = 0xffffff):void {
        textFormat.color = color;
        textField.defaultTextFormat = textFormat;
        textField.text = text;
        matrix.identity(); matrix.translate(x - 128, y - 10);
        bd.draw(textField, matrix);
    }
    public function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= size.x + spacing && 
            p.y >= -spacing && p.y <= size.y + spacing);
    }
}
class Clr {
    private static const BASE_BRIGHTNESS:int = 24;
    private static const WHITENESS:int = 0;
    public var r:int, g:int, b:int;
    public var brightness:Number = 1;
    public function Clr(r:int = 0, g:int = 0, b:int = 0) {
        this.r = r * BASE_BRIGHTNESS;
        this.g = g * BASE_BRIGHTNESS;
        this.b = b * BASE_BRIGHTNESS;
    }
    public function get i():uint {
        return uint(r * brightness) * 0x10000 + uint(g * brightness) * 0x100 + b * brightness;
    }
    public function set rgb(c:Clr):void {
        r = c.r; g = c.g; b = c.b;
    }
    public static var black:Clr = new Clr(0, 0, 0);
    public static var red:Clr = new Clr(10, WHITENESS, WHITENESS);
    public static var green:Clr = new Clr(WHITENESS, 10, WHITENESS);
    public static var blue:Clr = new Clr(WHITENESS, WHITENESS, 10);
    public static var yellow:Clr = new Clr(10, 10, WHITENESS);
    public static var magenta:Clr = new Clr(10, WHITENESS, 10);
    public static var cyan:Clr = new Clr(WHITENESS, 10, 10);
    public static var white:Clr = new Clr(10, 10, 10);
}
var mse:Mse;
class Mse {
    public var pos:Vct = new Vct;
    public var isPressing:Boolean;
    public function Mse() {
        baseSprite.addEventListener(MouseEvent.MOUSE_MOVE, onMoved);
        baseSprite.addEventListener(MouseEvent.MOUSE_DOWN, onPressed);
        baseSprite.addEventListener(MouseEvent.MOUSE_UP, onReleased);
        baseSprite.addEventListener(Event.MOUSE_LEAVE, onReleased);
    }
    private function onMoved(e:MouseEvent):void {
        pos.x = e.stageX;
        pos.y = e.stageY;
    }
    private function onPressed(e:MouseEvent):void {
        isPressing = true;
        onMoved(e);
    }
    private function onReleased(e:Event):void {
        isPressing = false;
    }
}
class Snd {
    public static var driver:SiONDriver = new SiONDriver;
    public static var isPlaying:Boolean;
    public var data:SiONData;
    function Snd(mml:String) {
        isPlaying = false;
        data = driver.compile(mml);
        driver.volume = 0;
        driver.play();
    }
    public function play():void {
        if (!isPlaying) {
            driver.volume = 0.7;
            isPlaying = true;
        }
        driver.sequenceOn(data, null, 0, 0, 0);
    }
}
function updateActors(s:*):void {
    for (var i:int = 0; i < s.length; i++) if (!s[i].update()) s.splice(i--, 1);
}
//----------------------------------------------------------------
var playButton:Button;
var clrButton:Button;
var clrAllButoon:Button;
var colorButton:Button;
var mmlText:TextField;
function initialize():void {
    mmlText = new TextField;
    main.stage.addChild(mmlText);
    mmlText.x = 10;
    mmlText.y = 440;
    mmlText.width = 450;
    mmlText.height = 20;
    mmlText.background = true;
    mmlText.backgroundColor = 0x333366;
    var tf:TextFormat = new TextFormat("_typewriter");
    tf.color = 0xffffff;
    mmlText.defaultTextFormat = tf;
    grid = new Grid;
    Button.s = new Vector.<Button>;
    playButton = new Button("play", 10, 10, 60, 375);
    clrButton = new Button("clear", 80, 390, 375, 40);
    colorButton = new Button("@1", 10, 390);
    clrAllButoon = new Button("clrall", 10, 415);
}
function update():void {
    grid.update();
    updateActors(Button.s);
    if (playButton.isPressed) grid.play();
    if (clrAllButoon.isPressed) grid.clear();
    if (colorButton.isPressed) {
        colorButton.text = "@" + grid.changeColor();
        grid.play();
    }
}
var grid:Grid;
class Grid {
    public const PIXEL_SIZE:int = 15;
    public const SIZE:int = 25;
    public var dots:Array = new Array(SIZE);
    public var pos:Vct = new Vct(scr.size.x - PIXEL_SIZE * SIZE - 10, 10);
    public var mml:String;
    public var tones:Array = ["c", "c+", "d", "d+", "e", "f", "f+", "g", "g+", "a", "a+", "b"];
    public var colors:Array = [1, 9, 10];
    public var color:int;
    public var msePos:Vct = new Vct(-1, -1);
    public var msePPos:Vct = new Vct(-1, -1);
    public var snds:Array;
    public var setTicks:int;
    function Grid() {
        for (var i:int = 0; i < SIZE; i++) dots[i] = new Array(SIZE);
        snds = new Array(colors.length);
        for (color = 0; color < colors.length; color++) {
            snds[color] = new Array(25);
            for (var y:int = 0; y < 25; y++) {
                snds[color][y] = new Snd(getBaseMml() + "o" + getOctave(y) + getScale(y));
            }
        }
        color = 0;
        clear();
    }
    public function clear():void {
        for (var x:int = 0; x < SIZE; x++) {
            for (var y:int = 0; y < SIZE; y++) {
                dots[x][y] = false;
            }
        }
    }
    public function changeColor():int {
        if (++color >= colors.length) color = 0;
        return colors[color];
    }
    public function update():void {
        msePos.x = int((mse.pos.x - pos.x) / PIXEL_SIZE);
        msePos.y = int((mse.pos.y - pos.y) / PIXEL_SIZE);
        if (msePos.x < 0 || msePos.x >= SIZE) {
            msePos.x = -1; 
        } else if (msePos.y < 0 || msePos.y >= SIZE) {
            msePos.y = -1; 
        } else if (msePPos.y != msePos.y) {
            snds[color][msePos.y].play();
        }
        if (msePos.x >= 0 && mse.isPressing) {
            setDot(msePos.x, msePos.y);
            setTicks = 10;
        }
        if (--setTicks == 0) play();
        for (var x:int = 0; x < SIZE; x++) {
            for (var y:int = 0; y < SIZE; y++) {
                var c:Clr = Clr.blue;
                if (dots[x][y]) c = Clr.red;
                else if (x == msePos.x && y == msePos.y) c = Clr.magenta;
                drawDot(x, y, c);
            }
        }
        msePPos.xy = msePos;
    }
    private function getBaseMml():String {
        return "l64%1@" + colors[color];
    }
    private function getOctave(y:int):int {
        return (24 - y) / tones.length + 4;
    }
    private function getScale(y:int):String {
        return tones[(24 - y) % tones.length];
    }
    public function play():void {
        mml = getBaseMml();
        var isStarted:Boolean = false;
        var po:int = -1;
        for (var x:int = 0; x < SIZE; x++) {
            var dy:int = -1;
            for (var y:int = 0; y < SIZE; y++) {
                if (dots[x][y]) {
                    isStarted = true;
                    dy = y;
                }
            }
            if (isStarted) {
                if (dy < 0) {
                    mml += "r";
                } else {
                    var o:int = getOctave(dy);
                    if (po != o) {
                        mml += "o" + o;
                        po = o;
                    }
                    mml += getScale(dy);
                }
            }
        }
        for (var i:int = mml.length - 1; i >= 0; i--) {
            if (mml.charAt(i) == 'r') mml = mml.slice(0, i);
            else break;
        }
        mmlText.text = mml;
        Snd.driver.play(mml);
    }
    public function setDot(x:int, y:int):void {
        for (var i:int = 0; i < SIZE; i++) dots[x][i] = false;
        if (y >= 0) dots[x][y] = true;
    }
    private var rect:Rectangle = new Rectangle(0, 0, PIXEL_SIZE - 1, PIXEL_SIZE - 1);
    public function drawDot(x:int, y:int, c:Clr):void {
        rect.x = x * PIXEL_SIZE + pos.x;
        rect.y = y * PIXEL_SIZE + pos.y;
        bd.fillRect(rect, c.i);
    }
}
class Button {
    public static var s:Vector.<Button>;
    public var pos:Vct = new Vct;
    public var size:Vct = new Vct;
    public var text:String;
    public var isPressing:Boolean, isPressed:Boolean;
    public var rect:Rectangle = new Rectangle;
    public var color:Clr = new Clr;
    function Button(text:String, x:int, y:int, width:int = 60, height:int = 15) {
        this.text = text;
        pos.x = x; pos.y = y;
        size.x = width; size.y = height;
        s.push(this);
    }
    public function update():Boolean {
        isPressed = false;
        rect.x = pos.x; rect.y = pos.y;
        rect.width = size.x; rect.height = size.y;
        var isMouseOn:Boolean = (mse.pos.x >= pos.x && mse.pos.x <= pos.x + size.x &&
            mse.pos.y >= pos.y && mse.pos.y <= pos.y + size.y);
        if (isPressing) {
            if (!isMouseOn) {
                isPressing = false;
            } else {
                if (!mse.isPressing) {
                    isPressed = true;
                    isPressing = false;
                }
            }
        } else {
            if (isMouseOn && mse.isPressing) isPressing = true;
        }
        if (isPressing) color.rgb = Clr.red;
        else if (isMouseOn) color.rgb = Clr.yellow;
        else color.rgb = Clr.white;
        bd.fillRect(rect, color.i);
        rect.x++; rect.y++;
        rect.width -= 2; rect.height -= 2;
        bd.fillRect(rect, Clr.black.i);
        scr.drawText(text, pos.x + size.x / 2, pos.y + size.y / 2);
        return true;
    }
}