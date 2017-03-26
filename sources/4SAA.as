/**
 * マウスオーバーでハンドルを表示、ハンドルをドラッグで曲線を変形できます。
 */
package {
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    [SWF (width = "465", height = "465", frameRate = "60", backgroundColor = "0xFFFFFF")]
    
    public class Main extends Sprite {
        
        private const _SIZE:Number = 20;
        private const _RADIUS:Number = _SIZE * 0.5;
        private const _GRAVITY:Number = 0.1;
        private const _COR:Number = 0.6;
        private const _LIMIT_SPEED:Number = 10;
        
        private var _stageWidth:int;
        private var _stageHeight:int;
        
        private var _ball:Ball;
        private var _curveList:Array = [];
        private var _target:Handle = null;
        
        public function Main() {
            _init();
        }
        
        private function _init():void {
            stage.scaleMode = "noScale";
            _stageWidth = stage.stageWidth;
            _stageHeight = stage.stageHeight;
            graphics.beginFill(0x111111);
            graphics.drawRect(0, 0, _stageWidth, _stageHeight);
            graphics.endFill();
            
            _ball = new Ball(50, 10, _SIZE);
            addChild(_ball);
            
            var start:Point = new Point();
            var control:Point = new Point();
            var anchor:Point = new Point();
            var list:Array = [[ 40,  70,  40, 191, 282, 124],
                              [197, 219, 409, 213, 437,  69],
                              [ 25, 240, 140, 240, 180, 340],
                              [180, 340, 220, 440, 310, 320],
                              [380, 350, 410, 420, 440, 350]];
            for (var i:int = 0; i < list.length; i++) {
                start.x   = list[i][0], start.y   = list[i][1];
                control.x = list[i][2], control.y = list[i][3];
                anchor.x  = list[i][4], anchor.y  = list[i][5];
                _createCurve(start, control, anchor);
            }
            
            stage.addEventListener(MouseEvent.MOUSE_OVER, _mouseOverHandler);
            stage.addEventListener(MouseEvent.MOUSE_OUT, _mouseOutHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
            addEventListener(Event.ENTER_FRAME, _enterFrameHandler);
        }
        
        private function _mouseOverHandler(event:MouseEvent):void {
            var name:String = event.target.name;
            var curve:Curve;
            if (name == "curve") {
                curve = Curve(event.target);
            } else if (name == "handle") {
                curve = Curve(event.target.parent);
            } else {
                return;
            }
            curve.show();
            setChildIndex(curve, numChildren - 1);
        }
        
        private function _mouseOutHandler(event:MouseEvent):void {
            var name:String = event.target.name;
            var curve:Curve;
            if (name == "curve") {
                curve = Curve(event.target);
            } else if (name == "handle") {
                curve = Curve(event.target.parent);
            } else {
                return;
            }
            curve.hide();
        }
        
        private function _mouseDownHandler(event:MouseEvent):void {
            if (event.target.name == "handle") {
                _target = event.target as Handle;
                _target.startDrag();
                stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
                stage.removeEventListener(MouseEvent.MOUSE_OVER, _mouseOverHandler);
                stage.removeEventListener(MouseEvent.MOUSE_OUT, _mouseOutHandler);
            }
        }
        
        private function _mouseMoveHandler(event:MouseEvent):void {
            Curve(_target.parent).draw();
            event.updateAfterEvent();
        }
        
        private function _mouseUpHandler(event:MouseEvent):void {
            if (_target) {
                Curve(_target.parent).draw();
                _target.stopDrag();
                _target = null;
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
                stage.addEventListener(MouseEvent.MOUSE_OVER, _mouseOverHandler);
                stage.addEventListener(MouseEvent.MOUSE_OUT, _mouseOutHandler);
            }
        }
        
        private function _enterFrameHandler(event:Event):void {
            var vel:Point = _ball.velocity;
            vel.x = Math.min(_LIMIT_SPEED, Math.max(vel.x, -_LIMIT_SPEED));
            vel.y = Math.min(_LIMIT_SPEED, Math.max(vel.y += _GRAVITY, -_LIMIT_SPEED));
            _ball.x += vel.x;
            (_ball.x %= _stageWidth) < 0 ? _ball.x += _stageWidth : 0;
            _ball.y += vel.y;
            (_ball.y %= _stageHeight) < 0 ? _ball.y += _stageHeight : 0;
            var ballRect:Rectangle = _ball.getRect(this);
            var d:Number = vel.length - _SIZE;
            if (d > 0) ballRect.inflate(d, d);
            for each(var curve:Curve in _curveList) {
                if (ballRect.intersects(curve.rect)) {
                    _collisionBezier(_ball, curve);
                }
            }
        }
        
        private function _collisionBezier(ball:Ball, curve:Curve):void {
            var start:Point = curve.start;
            var control:Point = curve.control;
            var anchor:Point = curve.anchor;
            var pos:Point = ball.position;
            var vel:Point = ball.velocity;
            var t:Number = BezierUtil.getTForClosestPoint(start, control, anchor, pos);
            var value:Point = BezierUtil.getValue(start, control, anchor, t);
            
            // すり抜け防止処理
            // _RADIUS > _LIMIT_SPEED * Math.sqrt(2) の場合は必要ないです
            // 他の曲線との干渉によるすり抜けは防げないのであまり意味ないかも
            var v1:Point = new Point(value.x - pos.x, value.y - pos.y);
            var v2:Point = new Point(v1.x + vel.x, v1.y + vel.y);
            var dot:Number = v1.x * v2.x + v1.y * v2.y;
            if (dot <= 0) {
                pos.offset(-vel.x, -vel.y);
                var v:Point = vel.clone();
                v.normalize(_RADIUS * 0.5);
                var d:Number = vel.length;
                var count:int = Math.ceil(d / (_RADIUS * 0.5));
                for (var i:int = 0; i < count; i++) {
                    pos.x += v.x;
                    pos.y += v.y;
                    t = BezierUtil.getTForClosestPoint(start, control, anchor, pos);
                    value = BezierUtil.getValue(start, control, anchor, t);
                    if (d - (d = Point.distance(pos, value)) < 0) return;
                    if (d <= _RADIUS) break;
                }
            }
            
            var dx:Number = pos.x - value.x;
            var dy:Number = pos.y - value.y;
            var dist:Number = Math.sqrt(dx * dx + dy * dy);
            if (dist > _RADIUS) return;
            var cos:Number = dx / dist;
            var sin:Number = dy / dist;
            pos = _coordinateRotation(0, _RADIUS, sin, -cos);
            ball.x = value.x + pos.x;
            ball.y = value.y + pos.y;
            vel = _coordinateRotation(vel.x, vel.y, sin, cos);
            ball.velocity = _coordinateRotation(vel.x, -vel.y * _COR, sin, -cos);
        }
        
        private function _coordinateRotation(x:Number, y:Number, cos:Number, sin:Number):Point {
            return new Point(x * cos - y * sin, x * sin + y * cos);
        }
        
        private function _createCurve(start:Point, control:Point, anchor:Point):void {
            var curve:Curve = new Curve(start, control, anchor);
            addChild(curve);
            _curveList.push(curve);
        }
        
    }
    
}

import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

class Ball extends Sprite {
    
    public var velocity:Point = new Point();
    
    public function Ball(x:Number, y:Number, size:Number) {
        graphics.beginFill(0xFFFFFF, 0.8);
        graphics.drawCircle(0, 0, size * 0.5);
        graphics.endFill();
        this.x = x;
        this.y = y;
    }
    
    public function get position():Point {
        return new Point(x, y);
    }
    
}

class Curve extends Sprite {
    
    private var _start:Handle;
    private var _control:Handle;
    private var _anchor:Handle;
    private var _shape:Shape;
    private var _hitArea:Sprite;
    
    public function Curve(start:Point, control:Point, anchor:Point) {
        _start = new Handle(start.x, start.y);
        addChild(_start);
        _control = new Handle(control.x, control.y);
        addChild(_control);
        _anchor = new Handle(anchor.x, anchor.y);
        addChild(_anchor);
        _shape = new Shape();
        addChild(_shape);
        _hitArea = new Sprite();
        _hitArea.mouseEnabled = false;
        _hitArea.visible = false;
        addChild(_hitArea);
        hitArea = _hitArea;
        name = "curve";
        draw();
        hide();
    }
    
    public function show():void {
        graphics.clear();
        graphics.lineStyle(0, 0x2498F6, 0.6);
        graphics.moveTo(_start.x, _start.y);
        graphics.lineTo(_control.x, _control.y);
        graphics.lineTo(_anchor.x, _anchor.y);
        _start.alpha = 1;
        _control.alpha = 1;
        _anchor.alpha = 1;
    }
    
    public function hide():void {
        graphics.clear();
        _start.alpha = 0;
        _control.alpha = 0;
        _anchor.alpha = 0;
    }
    
    public function draw():void {
        _shape.graphics.clear();
        _shape.graphics.lineStyle(1, 0xFFFFFF, 0.8);
        _shape.graphics.moveTo(_start.x, _start.y);
        _shape.graphics.curveTo(_control.x, _control.y, _anchor.x, _anchor.y);
        _hitArea.graphics.clear();
        _hitArea.graphics.lineStyle(20, 0, 1);
        _hitArea.graphics.moveTo(_start.x, _start.y);
        _hitArea.graphics.lineTo(_control.x, _control.y);
        _hitArea.graphics.lineTo(_anchor.x, _anchor.y);
        show();
    }
    
    public function get start():Point {
        return new Point(_start.x, _start.y);
    }
    
    public function get control():Point {
        return new Point(_control.x, _control.y);
    }
    
    public function get anchor():Point {
        return new Point(_anchor.x, _anchor.y);
    }
    
    public function get rect():Rectangle {
        return _shape.getBounds(this);
    }
    
}

class Handle extends Sprite {
    
    public function Handle(x:Number = 0, y:Number = 0) {
        graphics.beginFill(0x2498F6, 0.4);
        graphics.drawCircle(0, 0, 5);
        graphics.beginFill(0x24C8F6, 0.8);
        graphics.drawCircle(0, 0, 2);
        graphics.endFill();
        this.x = x;
        this.y = y;
        name = "handle";
        buttonMode = true;
    }
    
}

class BezierUtil {
    
    public static function getValue(start:Point, control:Point, anchor:Point, t:Number):Point {
        var m:Number = 1 - t;
        var x:Number = m * m * start.x + 2 * t * m * control.x + t * t * anchor.x;
        var y:Number = m * m * start.y + 2 * t * m * control.y + t * t * anchor.y;
        return new Point(x, y);
    }
    
    public static function getControlPoint(start:Point, middle:Point, end:Point):Point {
        var x:Number = (4 * middle.x - start.x - end.x) * 0.5;
        var y:Number = (4 * middle.y - start.y - end.y) * 0.5;
        return new Point (x, y);
    }
    
    public static function getLength(start:Point, control:Point, anchor:Point, t:Number):Number {
        _initIntegration(start, control, anchor);
        return _calculateLength(t);
    }
    
    public static function getTForX(start:Point, control:Point, anchor:Point, x:Number):Array {
        var ax:Number = start.x - 2 * control.x + anchor.x;
        var bx:Number = 2 * (control.x - start.x);
        var cx:Number = start.x - x;
        var answer:Array = _quadraticFormula(ax, bx, cx);
        var i:int = answer.length;
        while (i--) {
            var t:Number = answer[i];
            if (t < 0 || t > 1) answer.splice(i, 1);
        }
        return answer;
    }
    
    public static function getTForY(start:Point, control:Point, anchor:Point, y:Number):Array {
        var ay:Number = start.y - 2 * control.y + anchor.y;
        var by:Number = 2 * (control.y - start.y);
        var cy:Number = start.y - y;
        var answer:Array = _quadraticFormula(ay, by, cy);
        var i:int = answer.length;
        while (i--) {
            var t:Number = answer[i];
            if (t < 0 || t > 1) answer.splice(i, 1);
        }
        return answer;
    }
    
    public static function getTForLength(start:Point, control:Point, anchor:Point, length:Number):Number {
        _initIntegration(start, control, anchor);
        var totalLength:Number = _calculateLength(1);
        var t:Number = length / totalLength;
        if (t <= 0 || t >= 1) {
            return t <= 0 ? 0 : 1;
        }
        var temp:Number = _calculateLength(t);
        var d:Number = length - temp;
        while (Math.abs(d) > 0.01) {
            t += d / totalLength;
            temp = _calculateLength(t);
            d = length - temp;
        }
        return t;
    }
    
    public static function getTForClosestPoint(start:Point, control:Point, anchor:Point, point:Point):Number {
        var ax:Number = start.x - 2 * control.x + anchor.x;
        var bx:Number = control.x - start.x;
        var cx:Number = start.x;
        var ay:Number = start.y - 2 * control.y + anchor.y;
        var by:Number = control.y - start.y;
        var cy:Number = start.y;
        var a:Number = - (ax * ax + ay * ay);
        var b:Number = - 3 * (ax * bx + ay * by);
        var c:Number = ax * (point.x - cx) - 2 * bx * bx + ay * (point.y - cy) - 2 * by * by;
        var d:Number = bx * (point.x - cx) + by * (point.y - cy);
        var answer:Array = _cubicFormula(a, b, c, d);
        var minimum:Number = Number.MAX_VALUE;
        var length:int = answer.length;
        var t:Number;
        for (var i:int = 0; i < length; i++) {
            if (answer[i] < 0) answer[i] = 0;
            else if (answer[i] > 1) answer[i] = 1;
            var distance:Number = Point.distance(point, getValue(start, control, anchor, answer[i]));
            if (distance < minimum) {
                t = answer[i];
                minimum = distance;
            }
        }
        return t;
    }
    
    public static function getTForIntersectionOfLine(start:Point, control:Point, anchor:Point, a:Number, b:Number, c:Number):Array {
        var aa:Number = a * (start.x - 2 * control.x + anchor.x) + b * (start.y - 2 * control.y + anchor.y);
        var bb:Number = 2 * a * (control.x - start.x) + 2 * b * (control.y - start.y);
        var cc:Number = a * start.x + b * start.y + c;
        var answer:Array = _quadraticFormula(aa, bb, cc);
        var i:int = answer.length;
        while (i--) {
            var t:Number = answer[i];
            if (t < 0 || t > 1) answer.splice(i, 1);
        }
        return answer;
    }
    
    private static var _ax:Number;
    private static var _ay:Number;
    private static var _bx:Number;
    private static var _by:Number;
    private static var _A:Number;
    private static var _B:Number;
    private static var _C:Number;
    
    private static function _initIntegration(start:Point, control:Point, anchor:Point):void {
        _ax = start.x - 2 * control.x + anchor.x;
        _ay = start.y - 2 * control.y + anchor.y;
        _bx = control.x - start.x;
        _by = control.y - start.y;
        _A = _ax * _ax + _ay * _ay;
        _B = _ax * _bx + _ay * _by;
        _C = _bx * _bx + _by * _by;
        if (_A != 0) {
            _B = _B / _A;
            _C = _C / _A - _B * _B;
            _A = Math.sqrt(_A);
        }
    }
    
    private static function _integrate(t:Number):Number {
        var m:Number = _B + t;
        var n:Number = Math.sqrt(m * m + _C);
        if (_C <= 0) return _A * m * n;
        return _A * (m * n + _C * Math.log(m + n));
    }
    
    private static function _calculateLength(t:Number):Number {
        if (_A == 0) return Math.sqrt(4 * _C) * t;
        return _integrate(t) - _integrate(0);
    }
    
    private static function _quadraticFormula(a:Number, b:Number, c:Number):Array {
        var answer:Array = [];
        if (a == 0) {
            if (b != 0) answer.push(- c / b);
        } else {
            var D:Number = b * b - 4 * a * c;
            if (D > 0) {
                D = Math.sqrt(D);
                answer.push((- b - D) / (2 * a), (- b + D) / (2 * a));
            } else if (D == 0) {
                answer.push(- b / (2 * a));
            }
        }
        return answer;
    }
    
    private static function _cubicFormula(a:Number, b:Number, c:Number, d:Number):Array {
        if (a == 0) {
            return _quadraticFormula(b, c, d);
        }
        var answer:Array = [];
        var q:Number = (3 * a * c - b * b) / (9 * a * a);
        var r:Number = (9 * a * b * c - 27 * a * a * d - 2 * b * b * b) / (54 * a * a * a);
        if (q == 0) {
            answer.push((r < 0 ? -1 : 1) * Math.pow(Math.abs(r), 1 / 3) - b / (3 * a));
        } else {
            var D:Number = q * q * q + r * r;
            if (D > 0) {
                D = Math.sqrt(D);
                var s:Number = r + D;
                s = (s < 0 ? -1 : 1) * Math.pow(Math.abs(s), 1 / 3);
                var t:Number = r - D;
                t = (t < 0 ? -1 : 1) * Math.pow(Math.abs(t), 1 / 3);
                answer.push(s + t - b / (3 * a));
            } else {
                var u:Number = Math.sqrt(-q);
                var theta:Number = Math.acos(r / Math.sqrt(-Math.pow(q, 3)));
                answer.push(2 * u * Math.cos(theta / 3) - b / (3 * a));
                answer.push(2 * u * Math.cos((theta + 2 * Math.PI) / 3) - b / (3 * a));
                answer.push(2 * u * Math.cos((theta + 4 * Math.PI) / 3) - b / (3 * a));
            }
        }
        return answer;
    }
    
}