package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    public class Substrate extends Sprite
    {
        public static const W : int = 465;
        public static const H : int = 465;
        public static const SCALE : Number = 4;
        public static const RECT : Rectangle = new Rectangle(0, 0, W*SCALE, H*SCALE);
        public static const LEFT : String = "left";
        public static const RIGHT : String = "right";
        public static const UP : String = "up";
        public static const DOWN : String = "down";
        public static const MAX_LINES : int = 40;
        
        public static const NAMESPACE_KULER : String = "http://kuler.adobe.com/kuler/API/rss/";
        private static const APIKEY    : String = "4A297340291400B78BF1DFFE0E8E1678";
        public var kuler : Namespace = new Namespace(NAMESPACE_KULER);
        private var __loader : URLLoader;
        
        public static var bmpdPerlin : BitmapData = new BitmapData(W, H, false, 0);
        
        private var __bmpd : BitmapData = new BitmapData(W*SCALE, H*SCALE, true, 0);
        private var __bmpdFilled : BitmapData = new BitmapData(W*SCALE, H*SCALE, true, 0);
        private var __lines    : Array = [];
        private var __finishedlines    : Array = [];
        private var __colors : Array = [];
        
        public function Substrate() {
            var mtx:Matrix = new Matrix;
            mtx.createGradientBox(465, 465);
            graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xCCCCCC], [1, 1], [0, 255], mtx);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            
            var bmp:Bitmap = Bitmap(addChild(new Bitmap(__bmpd, "always", true)));
            bmp.scaleX = bmp.scaleY = 1/SCALE;
            
            __loader = new URLLoader();
            __loader.addEventListener(Event.COMPLETE, __onGetColor);
            stage.addEventListener(Event.ENTER_FRAME, __loop);
            stage.addEventListener(MouseEvent.CLICK, getColor);
            getColor();
        }
        
        public function getColor(e:Event=null) : void {    __loader.load(new URLRequest("http://kuler-api.adobe.com/rss/get.cfm?listType=rating&startIndex=0&itemsPerPage=20&key=" + APIKEY ));    }
        
        private function __onGetColor(e:Event) : void {
            var xml:XML = XML(__loader.data);
            __colors = [];
            var list:XMLList = new XMLList(xml.channel.item);
            var index : int = int(Math.random() * list.length());
            var theme:XML = list[index];
            var swatchList:XMLList = new XMLList(theme.kuler::themeItem.kuler::themeSwatches.kuler::swatch);
            var i : int = 0;
            var sColor:String;
            var color:uint
            for(i=0; i<swatchList.length(); i++) {
                sColor = swatchList[i].kuler::swatchHexColor;
                color = parseInt("0x"+sColor);
                __colors.push(color);
            }
            
            
            bmpdPerlin.perlinNoise(W, H, 15, Math.random()*0xFFFF, false, false, 4);
            __bmpd.fillRect(RECT, 0);
            __bmpdFilled.fillRect(RECT, 0);
            __lines = [];
            __finishedlines = [];
            createLine();
            createLine();
            createLine();
        }
        
        
        public function createLine() : void {
            if(__lines.length > MAX_LINES ) return;
            
            if(__finishedlines.length == 0) {
                var line:MarchingLine = new MarchingLine(Math.random() > .5 ? DOWN : UP, __bmpd, __bmpdFilled, new Point(Math.random()*W*SCALE, Math.random()*H*SCALE), getRandomElement(__colors), Math.random() * Math.PI * 2);
                line.addEventListener(MarchingLine.END_MARCHING, __onEndMarching);
                __lines.push(line);
            }else {
                var fline:MarchingLine;
                var dir:String;
                var MAX : int = 100;
                var count:int = 0;
                for ( var i:int=0; i<2; i++) {
                    var sp:Point;
                    
                    do {
                        fline = getRandomElement(__finishedlines);
                        sp = fline.getRandomMidPoint();
                        if(count ++ > MAX) return; 
                    } while ( !fline.canSpwan() || sp == null );
                    
                    if(fline.getDirection() == LEFT || fline.getDirection() == RIGHT)     dir = Math.random() > .5 ? UP : DOWN;
                    else dir = Math.random() > .5 ? LEFT : RIGHT;
                    
                    var newLine:MarchingLine = new MarchingLine(dir, __bmpd, __bmpdFilled, sp, getRandomElement(__colors), fline.getDefaultAngle());
                    newLine.addEventListener(MarchingLine.END_MARCHING, __onEndMarching);
                    __lines.push(newLine);
                }
                
            }
        }
        
        
        private function __onEndMarching(e:Event) : void {
            __lines.splice(__lines.indexOf(e.currentTarget), 1);
            __finishedlines.push(e.currentTarget);
            createLine();
        }
        
        
        private function __loop(e:Event=null) : void {
            const NUM_ITERATION : int = 5;
            for each ( var line:MarchingLine in __lines ) {
                var i:int= 0;
                while(i++<NUM_ITERATION) line.march();
            }
        }
        
        
        public static function getRandomElement(ary:Array) : * {    return ary[Math.floor(Math.random() * ary.length)];            }

    }
}




import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import Substrate;

class MarchingLine extends EventDispatcher {
    
    public static const END_MARCHING : String = "endMarching";
    
    private var __direction : String;
    private var __bmpdMap : BitmapData;
    private var __bmpdFilled : BitmapData;
    private var __position : Point;
    private var __startPosition : Point;
    private var __isFinished : Boolean = false;
    private var __color : uint;
    private var speed:Number = 1;
    private var __angle    : Number = 0;
    private var __len : Number = 1;
    private var __spwanPoints : Array = [];
    private var __lastPoint : Point;
    private var __shadowDirection : Number;
    private var __maxOffset : Number;
    private var __defaultAngle : Number;
    private var __angleInc : Number;
    private var __points : Array = [];
    
    public function MarchingLine(direction:String, referenceMap:BitmapData, fillMap:BitmapData, startPoint:Point, color:uint=0xFFFFFF, defaultAngle:Number=0) : void {
        __defaultAngle = defaultAngle;
        __direction = direction;
        __bmpdMap = referenceMap;
        __bmpdFilled = fillMap;
        __position = startPoint;
        __lastPoint = startPoint;
        __startPosition = startPoint.clone();
        __color = color;
        __shadowDirection = Math.random() > .5 ? 1 : -1;
        __maxOffset = 1 + Math.random() * 2;
        __angleInc = Math.random() > .5 ? Math.random() *.001 : 0;
        __points.push(__lastPoint);
        
        const DIFF_ANGLE:Number = .05; 
        switch(__direction) {
            case "left":
                __angle = getRandom(Math.PI - DIFF_ANGLE, Math.PI + DIFF_ANGLE);
                break;
            case "right":
                __angle = getRandom(-DIFF_ANGLE, DIFF_ANGLE);
                break;
            case "up":
                __angle = getRandom(-Math.PI * .5 - DIFF_ANGLE, -Math.PI * .5 + DIFF_ANGLE);
                break;
            case "down":
                __angle = getRandom(Math.PI * .5 - DIFF_ANGLE, Math.PI * .5 + DIFF_ANGLE);
                break;
            default:
                break;
        }
    }
    
    
    public function march() : void {
        if(__isFinished) return;
        __len += speed;
        __angle += __angleInc;
        __position = new Point(int(__startPosition.x + __len * Math.cos(__angle+__defaultAngle)), int(__startPosition.y + __len * Math.sin(__angle+__defaultAngle))); 
        __checkHit(); 
    }
    
    
    private function __checkHit():void {
        if(__isFinished) return;
        if(__position.x < 0 || __position.x > __bmpdMap.width || __position.y < 0 || __position.y > __bmpdMap.height || (__bmpdFilled.getPixel32(__position.x, __position.y) == 0xFF000000 && (!__lastPoint.equals(__position)))) {
            __isFinished = true;
            dispatchEvent(new Event(END_MARCHING));
        } else {
            __bmpdMap.setPixel32(__position.x, __position.y, 0xFF << 24 | 0x000000 );
            __bmpdFilled.setPixel32(__position.x, __position.y, 0xFF << 24 | 0x000000 );
            __drawShadows();
            __points.push(__position);
        }    
        __lastPoint = __position.clone();
        
    }
    
    private function __drawShadows():void {
        var angle:Number = __angle + Math.PI * .5 * __shadowDirection + __defaultAngle;
        const MAX_DISTANCE : Number = 30*Substrate.SCALE*__maxOffset;
        var range:Number = Substrate.bmpdPerlin.getPixel(__position.x / Substrate.SCALE, __position.y / Substrate.SCALE) / 255 * MAX_DISTANCE;
        var p : Point = new Point( __position.x + range * Math.cos(angle), __position.y + range * Math.sin(angle));
        const STEPS : int = 25;
        var tp:Point;
        var a:Number;
        for ( var i : int = 0; i< STEPS; i++ ) {
            tp = Point.interpolate(__position, p, i / STEPS);
            drawPixel(tp.x, tp.y, __color, i / STEPS*.6+.1);
        }
    }
    
    
    public function drawPixel(tx:Number, ty:Number, color:uint, a:Number) : void {
        if(__bmpdMap.getPixel32(tx, ty) == 0xFF000000) return;
        var aa:int = Math.floor( 0xFF * a );
        __bmpdMap.setPixel32(tx, ty, aa << 24 | __color );
    }
    
    
    public function getDirection() : String {    return __direction;    }
    public function isFinished() : Boolean { return __isFinished;    }
    public function canSpwan() : Boolean {    return Point.distance(__startPosition, __position) > 50 * Substrate.SCALE;     }
    public function getDefaultAngle() : Number {    return __defaultAngle;    }
    
    public function getRandomMidPoint() : Point {
        const MAX : int = 100;
        var count:int = 0;
        var p:Point;
        do {
            p = Substrate.getRandomElement(__points);
            count ++;
            if(count > MAX) return null;
        }while(!__checkSpwan(p));
        __spwanPoints.push(p);
        return p;
    }
    
    private function __checkSpwan(p:Point) : Boolean {
        const MIN_DISTANCE : int = 5;
        for each ( var tp:Point in __spwanPoints) if(Point.distance(p, tp) < MIN_DISTANCE) return false;
        return true;
    }
    
    
    static public function getRandom(start:Number, end:Number, isInt:Boolean=false) : Number {
        var n:Number    = start + Math.random()*(end-start);
        if(isInt)    n    = Math.floor(n);
        
        return n;
    }
}