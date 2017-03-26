package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0xffffff", frameRate="60")]
    public class Main extends Sprite  {
        public function Main():void  {
            initialize(this);
        }
    }
}
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.text.TextField;
var main:Main;
var g:Graphics;
var screen:Screen;
var innerPolygon:Polygon;
var outerPolygon:Polygon;
var overlayg:Graphics;
function initialize(main:Main):void {
    this.main = main;
    var textField:TextField = new TextField;
    textField.text = "Click to try another combination.";
    textField.width = 200;
    main.addChild(textField);
    g = main.graphics;
    screen = new Screen;
    var overlayShape:Shape = new Shape;
    main.addChild(overlayShape);
    overlayg = overlayShape.graphics;
    setInnterOuterPolygons();
    main.stage.addEventListener(MouseEvent.CLICK, onClicked);
    main.addEventListener(Event.ENTER_FRAME, update);
}
function onClicked(e:MouseEvent):void {
    setInnterOuterPolygons();
}
var rollSpeed:Number;
function setInnterOuterPolygons():void {
    overlayg.clear();
    overlayg.lineStyle(1, 0);
    innerPolygon = new Polygon(30, 150, false);
    outerPolygon = new Polygon(20, 100, true);
    outerPolygon.addDots(0, 0);
    var c:Contact = new Contact;
    c.polygon = outerPolygon;
    c.side = outerPolygon.sides[1];
    c.distance = 0;
    c.onCorner = true;
    outerPolygon.contact = c;
    var ic:Contact = new Contact;
    ic.polygon = innerPolygon;
    ic.side = innerPolygon.sides[0];
    ic.distance = 0;
    outerPolygon.innerContact = ic;
    outerPolygon.calcAnglePrevNextOuter();
    rollSpeed = 0.02;
}
function update(e:Event):void {
    g.clear();
    g.lineStyle(1, 0);
    innerPolygon.setAngleAbtolute();
    innerPolygon.calcSidePoss();
    innerPolygon.draw();
    outerPolygon.calcPosFromContact();
    outerPolygon.calcSidePoss();
    outerPolygon.draw();
    outerPolygon.roll(rollSpeed);
    if (rollSpeed < 0.5) rollSpeed += 0.001;
}
class Polygon {
    public var pos:Point = new Point;
    public var sides:Vector.<Side> = new Vector.<Side>;
    public var contact:Contact = new Contact;
    public var innerContact:Contact = new Contact;
    public var angle:Number = 0;
    public var anglePrev:Number, angleNext:Number;
    public var dots:Vector.<Point> = new Vector.<Point>;
    public var dotsPrev:Vector.<Point> = new Vector.<Point>;
    public var cornerAngle:Number;
    public function Polygon(minSize:Number, maxSize:Number, isCounterclockwise:Boolean) {
        var size:Number = rand() * (maxSize - minSize) + minSize;
        var w:Number, h:Number;
        switch (int(rand() * 3)) {
        case 0:
            w = size;
            h = 0;
            setPolygon(32, size / 2, isCounterclockwise);
            break;
        case 1:
            w = size * (rand() + 0.2);
            h = size * (rand() + 0.2);
            setSquare(w, h, isCounterclockwise);
            break;
        case 2:
            var n:int = 3 + int(rand() * 2) * 2;
            w = size;
            h = 2 * size * sin(PI / n);
            setPolygon(n, size / 2, isCounterclockwise);
            break;
        }
        pos.x = screen.center.x - w / 2;
        pos.y = screen.center.y - h / 2;
    }
    public function setSquare(width:Number, height:Number, isCounterclockwise:Boolean):void {
        var firstSide:Side;
        var prevSide:Side;
        var side:Side;
        cornerAngle = PI / 2;
        for (var i:int = 0; i < 4; i++) {
            side = new Side;
            if (i == 0) side.isFirst = true;
            if (i % 2 == 0)    side.length = height;
            else side.length = width;
            side.angle = i * cornerAngle;
            if (isCounterclockwise) side.angle *= -1;
            side.angle = normalizeAngle(side.angle);
            if (prevSide) {
                prevSide.nextSide = side;
                side.prevSide = prevSide;
            }
            sides.push(side);
            if (!firstSide) firstSide = side;
            prevSide = side;
        }
        side.nextSide = firstSide;
        firstSide.prevSide = side;
    }
    public function setPolygon(number:int, radius:Number, isCounterclockwise:Boolean):void {
        var firstSide:Side;
        var prevSide:Side;
        var side:Side;
        cornerAngle = PI2 / number;
        for (var i:int = 0; i < number; i++) {
            side = new Side;
            if (i == 0) side.isFirst = true;
            side.length = 2 * radius * sin(PI / number);
            side.angle = i * cornerAngle;
            if (isCounterclockwise) side.angle *= -1;
            side.angle = normalizeAngle(side.angle);
            if (prevSide) {
                prevSide.nextSide = side;
                side.prevSide = prevSide;
            }
            sides.push(side);
            if (!firstSide) firstSide = side;
            prevSide = side;
        }
        side.nextSide = firstSide;
        firstSide.prevSide = side;
    }
    public function addDots(x:Number, y:Number):void {
        dots.push(new Point(y, x));
        dotsPrev.push(new Point(-99999, -99999));
    }
    public function calcAnglePrevNextInner():void {
        anglePrev = -innerPolygon.cornerAngle;
        angleNext = 0;
    }
    public function calcAnglePrevNextOuter():void {
        anglePrev = -outerPolygon.cornerAngle;
        angleNext = 0;
    }
    private function gotoPrev(overAngle:Number):void {
        if (contact.onCorner) {
            if (innerContact.distance < contact.side.prevSide.length) {
                contact.side = contact.side.prevSide;
                contact.distance = contact.side.length - innerContact.distance;
                contact.onCorner = false;
                innerContact.distance = 0;
                innerContact.onCorner = true;
            } else {
                contact.side = contact.side.prevSide;
                innerContact.distance -= contact.side.length;
            }
        } else {
            if (contact.distance < innerContact.side.prevSide.length) {
                innerContact.side = innerContact.side.prevSide;
                innerContact.distance = innerContact.side.length - contact.distance;
                innerContact.onCorner = false;
                contact.distance = 0;
                contact.onCorner = true;
            } else {
                contact.distance -= innerContact.side.length;
                innerContact.side = innerContact.side.prevSide;
            }
        }
        if (contact.onCorner) calcAnglePrevNextOuter();
        else calcAnglePrevNextInner();
        angle = angleNext + overAngle;
    }
    private function gotoNext(overAngle:Number):void {
        if (contact.onCorner) {
            if (innerContact.side.length - innerContact.distance < contact.side.length) {
                contact.distance = innerContact.side.length - innerContact.distance;
                contact.onCorner = false;
                innerContact.distance = 0;
                innerContact.onCorner = true;
                innerContact.side = innerContact.side.nextSide;
            } else {
                innerContact.distance += contact.side.length;
                contact.side = contact.side.nextSide;
            }
        } else {
            if (contact.side.length - contact.distance  < innerContact.side.length) {
                innerContact.distance = contact.side.length - contact.distance;
                innerContact.onCorner = false;
                contact.distance = 0;
                contact.onCorner = true;
                contact.side = contact.side.nextSide;
            } else {
                contact.distance += innerContact.side.length;
                innerContact.side = innerContact.side.nextSide;
            }
        }
        if (contact.onCorner) calcAnglePrevNextOuter();
        else calcAnglePrevNextInner();
        angle = anglePrev + overAngle;
    }
    public function roll(a:Number):void {
        angle += a;
        while (angle < anglePrev) gotoPrev(angle - anglePrev);
        while (angle >= angleNext) gotoNext(angle - angleNext);
    }
    private var sidePos:Vector3D = new Vector3D;
    public function calcSidePoss():void {
        var s:Side;
        s = sides[0];
        s.pos.x = sidePos.x = pos.x;
        s.pos.y = sidePos.y = pos.y;
        var a:Number = s.angleAbsolute;
        for (var i:int = 1; i < sides.length; i++) {
            s = sides[i - 1];
            sidePos.x += sin(a) * s.length;
            sidePos.y += cos(a) * s.length;
            a += (s.nextSide.angle - s.angle);
            s = sides[i];
            s.pos.x = sidePos.x;
            s.pos.y = sidePos.y;
            s.angleAbsolute = a;
        }
    }
    private var rollMat:Matrix = new Matrix;
    public function draw():void {
        var s:Side;
        s = sides[0];
        g.moveTo(s.pos.x, s.pos.y);
        for (var i:int = 1; i < sides.length; i++) {
            s = sides[i];
            g.lineTo(s.pos.x, s.pos.y);
        }
        s = sides[0];
        g.lineTo(s.pos.x, s.pos.y);
        if (!contact.side) return;
        rollMat.identity();
        rollMat.rotate(contact.side.prevSide.angle - innerContact.side.angle - angle);
        for (i = 0; i < dots.length; i++) {
            var rp:Point = rollMat.transformPoint(dots[i]);
            var dp:Point = dotsPrev[i];
            var df:Boolean = (dp.x > -9);
            if (df) overlayg.moveTo(dp.x, dp.y);
            dp.x = rp.x + pos.x;
            dp.y = rp.y + pos.y;
            if (df) overlayg.lineTo(dp.x, dp.y);
        }
    }
    public function setAngleAbtolute():void {
        sides[0].angleAbsolute = angle + sides[0].angle;
    }
    public function calcPosFromContact():void {
        var p:Vector3D = calcContactPos();
        var s:Side = contact.side;
        var a:Number = innerContact.side.angleAbsolute + angle;
        p.x -= sin(a) * contact.distance;
        p.y -= cos(a) * contact.distance;
        for (;; ) {
            if (s.isFirst) break;
            a -= (s.angle - s.prevSide.angle);
            s = s.prevSide;
            p.x -= sin(a) * s.length;
            p.y -= cos(a) * s.length;
        }
        s.angleAbsolute = a;
        pos.x = p.x;
        pos.y = p.y;
    }
    private var contactPos:Vector3D = new Vector3D;
    private function calcContactPos():Vector3D {
        var s:Side = innerContact.side;
        contactPos.x = s.pos.x + sin(s.angleAbsolute) * innerContact.distance;
        contactPos.y = s.pos.y + cos(s.angleAbsolute) * innerContact.distance;
        return contactPos;
    }
}
class Side {
    public var length:Number
    public var angle:Number;
    public var prevSide:Side;
    public var nextSide:Side;
    public var pos:Vector3D = new Vector3D;
    public var angleAbsolute:Number;
    public var isFirst:Boolean;
}
class Contact {
    public var polygon:Polygon;
    public var side:Side;
    public var distance:Number;
    public var onCorner:Boolean;
}
class Screen {
    public var size:Vector3D;
    public var center:Vector3D;
    function Screen() {
        size = new Vector3D(main.stage.stageWidth, main.stage.stageHeight);
        center = new Vector3D(size.x / 2, size.y / 2);
    }
}
var PI:Number = Math.PI;
var PI2:Number = Math.PI * 2;
var sin:Function = Math.sin;
var cos:Function = Math.cos;
var rand:Function = Math.random;
function normalizeAngle(angle:Number):Number {
    var r:Number = angle % PI2;
    if (r > PI) r -= PI2;
    else if (r < -PI) r += PI2;
    return r;
}