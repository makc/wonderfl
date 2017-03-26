// forked from Aquioux's アポロニウスのガスケット Apollonian Gasket (2)
// forked from Aquioux's アポロニウスのガスケット Apollonian Gasket (1)
package {
    //import aquioux.display.colorUtil.RGBWheel;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#ffffff")]
    /**
     * アポロニウスのガスケット(3) 
     * ユーザーインタラクティブ
     * @author YOSHIDA, Akio
     */
    public class Main extends Sprite {
        // 再帰の終了判定（描画円の半径の最小値）
        static private const MIN_RADIUS:Number = 2.5;

        // 円の色初期値
        static private var colorStart_:Number = (Math.random() * 2 >> 0) * 180;
        // 円の色増分
        static private const ADD:int = 360 / 13 >> 0;
        
        // 円
        private var circleSpriteA_:CircleSprite;    // 正接円A
        private var circleSpriteB_:CircleSprite;    // 正接円B
        private var circleSpriteC_:CircleSprite;    // 正接円C
        private var draggingCircleSprite_:CircleSprite;    // ドラッグ中の正接円

        private var container_:Sprite;                // 円のコンテナ
        private var canvas_:Shape;                    // 円のキャンバス


        /**
         * コンストラクタ
         */
        public function Main() {
            setup();
            draw();
        }

        /**
         * セットアップ
         */
        private function setup():void {
            // ステージシフト値
            const SHIFT_X:Number = -10000;
            const SHIFT_Y:Number = -10000;
            // ステージ中央値
            const CENTER_X:Number = stage.stageWidth  / 2;
            const CENTER_Y:Number = stage.stageHeight / 2;

            // 円のコンテナ
            container_ = new Sprite();
            container_.x = SHIFT_X;
            container_.y = SHIFT_Y;
            container_.mouseEnabled = false;
            addChild(container_);
            // 円のキャンバス
            canvas_ = new Shape();
            container_.addChild(canvas_);

            // 正接円の生成
            circleSpriteA_ = new CircleSprite();
            circleSpriteB_ = new CircleSprite();
            circleSpriteC_ = new CircleSprite();
            circleSpriteA_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            circleSpriteB_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            circleSpriteC_.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            container_.addChild(circleSpriteA_);
            container_.addChild(circleSpriteB_);
            container_.addChild(circleSpriteC_);

            // 正接円の配置（極座標計算）
            var radianA:Number = -90 * Math.PI / 180;
            var radianB:Number =  30 * Math.PI / 180;
            var radianC:Number = 150 * Math.PI / 180;
            const LENGTH:int = 100;// stage.stageWidth * 0.27 >> 0;
            circleSpriteA_.x = CENTER_X + Math.cos(radianA) * LENGTH - SHIFT_X;
            circleSpriteA_.y = CENTER_Y + Math.sin(radianA) * LENGTH - SHIFT_Y;
            circleSpriteB_.x = CENTER_X + Math.cos(radianB) * LENGTH - SHIFT_X;
            circleSpriteB_.y = CENTER_Y + Math.sin(radianB) * LENGTH - SHIFT_Y;
            circleSpriteC_.x = CENTER_X + Math.cos(radianC) * LENGTH - SHIFT_X;
            circleSpriteC_.y = CENTER_Y + Math.sin(radianC) * LENGTH - SHIFT_Y;
        }
        // マウスハンドラ
        private function mouseDownHandler(event:MouseEvent):void {
            draggingCircleSprite_ = CircleSprite(event.target);
            draggingCircleSprite_.startDrag();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            stage.addEventListener(Event.MOUSE_LEAVE,     mouseUpHandler);
        }
        private function mouseMoveHandler(event:MouseEvent):void {
            draw();
        }
        private function mouseUpHandler(event:MouseEvent):void {
            draggingCircleSprite_.stopDrag();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            stage.removeEventListener(Event.MOUSE_LEAVE,     mouseUpHandler);
        }

        /**
         * 描画
         */
        private function draw():void {
            // 正接円の半径の計算
            Calculator.calcTangentCircles(circleSpriteA_.circle, circleSpriteB_.circle, circleSpriteC_.circle);
            // 正接円の描画
            var color:uint = RGBWheel.getDegreeColor(colorStart_);
            circleSpriteA_.draw(color);
            circleSpriteB_.draw(color);
            circleSpriteC_.draw(color);

            canvas_.graphics.clear();

            // 外接円の生成
            var outer:Circle = Calculator.calcSoddyCircles(circleSpriteA_.circle, circleSpriteB_.circle, circleSpriteC_.circle, false);
            drawCircle(outer, 0);
            // 正接円以外の円の描画
            var degree:Number = 1;
            // 3正接円の再帰
            drawSoddyCircles(circleSpriteA_.circle, circleSpriteB_.circle, circleSpriteC_.circle, degree);
            // 二つの正接円と外接円の再帰
            degree++;
            drawSoddyCircles(circleSpriteA_.circle, circleSpriteB_.circle, outer, degree);    // その1
            drawSoddyCircles(circleSpriteB_.circle, circleSpriteC_.circle, outer, degree);    // その2
            drawSoddyCircles(circleSpriteC_.circle, circleSpriteA_.circle, outer, degree);    // その3

            colorStart_ += 0.5;
        }
        
        private function drawSoddyCircles(circleA:Circle, circleB:Circle, circleC:Circle, degree:int):void {
            // 内接円の生成
            var inner:Circle = Calculator.calcSoddyCircles(circleA, circleB, circleC);
            // 終了判定
            if (inner.radius < MIN_RADIUS) return;
            // 内接円の描画
            drawCircle(inner, RGBWheel.getDegreeColor(degree * ADD + colorStart_));
            // 3分木で再帰
            degree++;
            drawSoddyCircles(circleA, circleB, inner, degree);
            drawSoddyCircles(circleB, circleC, inner, degree);
            drawSoddyCircles(circleC, circleA, inner, degree);
        }

        private function drawCircle(circle:Circle, color:int):void {
            var g:Graphics = canvas_.graphics;
            g.lineStyle(0, 0x0);
            g.beginFill(color);
            g.drawCircle(circle.center.x, circle.center.y, circle.radius);
            g.endFill();
        }
    }
}



//package {
    //import aquioux.math.Complex;
    //import aquioux.math.ComplexMath;
    /**
     * 「デカルトの円定理」あるいは "Soddy Circles"
     * http://en.wikipedia.org/wiki/Descartes'_theorem
     * http://mathworld.wolfram.com/DescartesCircleTheorem.html
     * http://mathworld.wolfram.com/SoddyCircles.html
     * http://mathworld.wolfram.com/InnerSoddyCircle.html
     * http://mathworld.wolfram.com/OuterSoddyCircle.html
     * @author YOSHIDA, Akio
     */
    /*public*/ class Calculator {
        /**
         * 3つの正接円の中心座標からそれぞれの半径を算出
         * @param    circleA
         * @param    circleB
         * @param    circleC
         */
        static public function calcTangentCircles(circleA:Circle, circleB:Circle, circleC:Circle):void {
            // 2つの正接円間の距離（2つの正接円の半径の和）を算出
            var distAB:Number = dist(circleA.center, circleB.center);    // = circleA.radius + circleB.radius
            var distBC:Number = dist(circleB.center, circleC.center);    // = circleB.radius + circleC.radius
            var distCA:Number = dist(circleC.center, circleA.center);    // = circleC.radius + circleA.radius
            // 各正接円の半径を算出
            circleA.radius = (distCA + distAB - distBC) / 2;
            circleB.radius = (distAB + distBC - distCA) / 2;
            circleC.radius = (distBC + distCA - distAB) / 2;
        }
        // 2つの複素数間の距離を求める
        static private function dist(center1:Complex, center2:Complex):Number {
            return ComplexMath.abs(ComplexMath.subtract(center1, center2));
        }

        /**
         * 3つの正接円から、その内接円もしくは外接円の半径と中心座標を算出
         * @param    circleA
         * @param    circleB
         * @param    circleC
         * @param    isInner    3つの内接円の内接円を求めるのか、外接円を求めるのか。true:内接円、false：外接円
         * @return
         */
        static public function calcSoddyCircles(circleA:Circle, circleB:Circle, circleC:Circle, isInner:Boolean = true):Circle {
            // ----- 4番目の円の半径を求める -----
            // 4番目の円の曲率kを求める公式
            // (k1 + k2 + k3 + k4)^2 = 2 * (k1^2 + k2^2 + k3^2 + k4^2)
            // ↓
            // k4 = k1 + k2 + k3 ± 2 * √(k1*k2 + k2*k3 + k3*k1)

            // 各正接円の曲率
            var kA:Number = 1 / circleA.radius;        // k1
            var kB:Number = 1 / circleB.radius;        // k2
            var kC:Number = 1 / circleC.radius;        // k3
            
            // ±前の部分
            var kABC:Number = kA + kB + kC;            // k1 + k2 + k3
            // ±後の部分
            var kAB:Number = kA * kB;                // k1 * k2
            var kBC:Number = kB * kC;                // k2 * k3
            var kCA:Number = kC * kA;                // k3 * k1
            var sq1:Number = 2 * Math.sqrt(kAB + kBC + kCA);    // 2 * √(k1*k2 + k2*k3 + k3*k1)
            // k4 の計算結果（逆数にして半径に）
            if (!isInner) sq1 = -sq1;    // 外接円の場合
            var radiusD:Number = 1 / (kABC + sq1);

            // ----- 4番目の円の中心座標を求める -----
            // 4番目の円の中心座標（複素平面上）を求める公式
            // (z1*k1 + z2*k2 + z3*k3 + z4*k4)^2 = 2 * (z1^2*k1^2 + z2^2*k2^2 + z3^2*k3^2 + z4^2*k4^2)
            // ↓
            // z4 = (z1*k1 + z2*k2 + z3*k3 ± 2 * √(z1*k1 * z2*k2 + z2*k2 * z3*k3 + z3*k3 * z1*k1)) / k4

            // 分子のうち、±前の部分
            var zkA:Complex   = ComplexMath.scale(circleA.center, kA);    // z1 * k1
            var zkB:Complex   = ComplexMath.scale(circleB.center, kB);    // z2 * k2
            var zkC:Complex   = ComplexMath.scale(circleC.center, kC);    // z3 * k3
            var zkABC:Complex = ComplexMath.add(ComplexMath.add(zkA, zkB), zkC);
                                                                        // z1*k1 + z2*k2 + z3*k3
            // 分子のうち、±後の部分
            var zkAB:Complex = ComplexMath.multiply(zkA, zkB);    // z1*k1 * z2*k2
            var zkBC:Complex = ComplexMath.multiply(zkB, zkC);    // z2*k2 * z3*k3
            var zkCA:Complex = ComplexMath.multiply(zkC, zkA);    // z3*k3 * z1*k1
            var zkAABBCC:Complex = ComplexMath.add(ComplexMath.add(zkAB, zkBC), zkCA);
                                                                // z1*k1 * z2*k2 + z2*k2 * z3*k3 + z3*k3 * z1*k1
            var sq2:Complex = ComplexMath.scale(ComplexMath.pow(zkAABBCC, 1 / 2), 2);
                                                                // 2 * √(z1*k1 * z2*k2 + z2*k2 * z3*k3 + z3*k3 * z1*k1)
            // z4 の計算結果
            if (!isInner) sq2 = ComplexMath.scale(sq2, -1);    // 外接円の場合
            var zD:Complex = ComplexMath.scale(ComplexMath.add(zkABC, sq2), radiusD);

            return new Circle(zD, radiusD);
        }
    }
//}


//package  {
    //import aquioux.math.Complex;
    /**
     * 円クラス
     * @author YOSHIDA, Akio
     */
    /*public*/ class Circle {
        /**
         * 中心座標
         */
        public function get center():Complex { return _center; }
        public function set center(value:Complex):void { _center = value; }
        private var _center:Complex;

        /**
         * 半径
         */
        public function get radius():Number { return _radius; }
        public function set radius(value:Number):void { _radius = value; }
        private var _radius:Number;
        

        /**
         * コンストラクタ
         * @param    center    中心座標
         * @param    radius    半径
         */
        public function Circle(center:Complex = null, radius:Number = 0.0) {
            _center = (center) ? center : new Complex(0.0, 0.0);
            _radius = radius;
        }
    }
//}


//package {
    //import aquioux.math.Complex;
    import flash.display.Graphics;
    import flash.display.Sprite;
    /**
     * 円スプライトクラス
     * @author YOSHIDA, Akio
     */
    /*public*/ class CircleSprite extends Sprite {
        /**
         * 円の情報
         */
        public function get circle():Circle {
            _circle.center.x = this.x;
            _circle.center.y = this.y;
            return _circle;
        }
        public function set circle(value:Circle):void { _circle = value; }
        private var _circle:Circle = new Circle();


        /**
         * コンストラクタ
         */
        public function CircleSprite():void {
            this.buttonMode = true;
        }

        /**
         * 描画
         */
        public function draw(color:uint = 0x0):void {
            var g:Graphics = this.graphics;
            g.clear();
            g.lineStyle(0, 0x0);
            g.beginFill(color);
            g.drawCircle(0, 0, _circle.radius);
            g.endFill();
        }
    }
//}


//package aquioux.math {
    /**
     * 複素数
     * @author YOSHIDA, Akio
     */
    /*public*/ final class Complex {
        /**
         * 実数部
         */
        // 実数
        public function get real():Number { return _real; }
        public function set real(value:Number):void { _real = value; }
        // 直交座標におけるX座標
        public function get x():Number { return _real; }
        public function set x(value:Number):void { _real = value; }
        // 局座標における長さ
        public function get length():Number { return _real; }
        public function set length(value:Number):void { _real = value; }
        // 実数部
        private var _real:Number;

        /**
         * 数部
         */
        // 虚数
        public function get imag():Number { return _imag; }
        public function set imag(value:Number):void { _imag = value; }
        // 直交座標におけるY座標
        public function get y():Number { return _imag; }
        public function set y(value:Number):void { _imag = value; }
        // 局座標における偏角
        public function get angle():Number { return _imag; }
        public function set angle(value:Number):void { _imag = value; }
        // 虚数部
        private var _imag:Number;


        /**
         * コンストラクタ
         * @param    real    実数部
         * @param    imag    虚数部
         */
        public function Complex(real:Number = 0.0, imag:Number = 0.0) {
            _real = real;
            _imag = imag;
        }

        /**
         * 複製
         * @return    複製した複素数
         */
        public function clone():Complex {
            return new Complex(_real, _imag);
        }

        /**
         * toString
         * @return    文字列表示
         */
        public function toString():String {
            return String(_real) + " + " + String(_imag) + " i";
        }
    }
//}


//package aquioux.math {
    /**
     * 複素数の定数と演算
     * @author YOSHIDA, Akio
     */
    /*public*/ final class ComplexMath {
        // ----- 定数 -----
        /**
         * ゼロ
         */
        static public const  ZERO:Complex = new Complex(0.0, 0.0);
        /**
         * 純実数1
         */
        static public const  PURE_REAL:Complex = new Complex(1.0, 0.0);
        /**
         * 純虚数i
         */
        static public const  PURE_IMAGINARY:Complex = new Complex(0.0, 1.0);


        /**
         * 加算
         * @param    a    加算項1
         * @param    b    加算項2
         * @return    加算結果
         */
        static public function add(a:Complex, b:Complex):Complex {
            return new Complex(
                a.real + b.real,
                a.imag + b.imag
            );
        }
        /**
         * 減算
         * @param    a    減算項1
         * @param    b    減算項2
         * @return    減算結果
         */
        static public function subtract(a:Complex, b:Complex):Complex {
            return new Complex(
                a.real - b.real,
                a.imag - b.imag
            );
        }
        /**
         * 乗算
         * @param    a    乗算項1
         * @param    b    乗算項2
         * @return    乗算結果
         */
        static public function multiply(a:Complex, b:Complex):Complex {
            var aRl:Number = a.real;
            var aIm:Number = a.imag;
            var bRl:Number = b.real;
            var bIm:Number = b.imag;
            return new Complex(
                aRl * bRl - aIm * bIm,
                aRl * bIm + aIm * bRl
            );
        }
        /**
         * 除算
         * @param    a    除算項1
         * @param    b    除算項2
         * @return    除算結果
         */
        static public function divide(a:Complex, b:Complex):Complex {
            return multiply(a, reciprocal(b));
        }

        /**
         * スケーリング（第2引数が実数である乗算）
         * @param    c    複素数
         * @param    n    実数
         * @return    乗算結果
         */
        static public function scale(c:Complex, n:Number):Complex {
            return new Complex(
                c.real * n,
                c.imag * n
            );
        }


        /**
         * 絶対値の2乗
         * @param    c    複素数
         * @return    絶対値の2乗
         */
        // c * c~ = c.real^2 + c.imag^2
        static public function absSquare(c:Complex):Number {
            var rl:Number = c.real;
            var im:Number = c.imag;
            return rl * rl + im * im;
        }
        /**
         * 絶対値（=長さ）
         * @param    c    複素数
         * @return    絶対値
         */
        // |c| = √(c * c~) = √(c.real^2 + c.imag^2)
        static public function abs(c:Complex):Number {
            return Math.sqrt(absSquare(c));
        }


        /**
         * 共役複素数
         * @param    c    複素数
         * @return    共役複素数
         */
        static public function conjugate(c:Complex):Complex {
            return new Complex(
                 c.real,
                -c.imag
            );
        }
        /**
         * 逆数
         * @param    c    複素数
         * @return    逆数
         */
        static public function reciprocal(c:Complex):Complex {
            var val:Number = absSquare(c);
            return new Complex(
                 c.real / val,
                -c.imag / val
            );
        }

        /**
         * 冪乗
         * @param    c    複素数
         * @param    exponent    冪指数
         * @return    冪乗結果
         */
        static public function pow(c:Complex, exponent:Number):Complex {
            // 極座標形式で計算
            var cc:Complex = cartesianToPolar(c);
            var length:Number = Math.pow(cc.length, exponent);
            var angle:Number  = cc.angle * exponent;
            return new Complex(
                length * Math.cos(angle),
                length * Math.sin(angle)
            );
        }


        /**
         * 直交座標形式から極座標形式へ
         * @param    c    直交座標形式の複素数
         * @return    極座標形式の複素数
         */
        // 対数関数との関連性
        static public function cartesianToPolar(c:Complex):Complex {
            var cc:Complex = new Complex();
            cc.length = abs(c);                        // 長さ
            cc.angle  = Math.atan2(c.imag, c.real);    // 偏角
            return cc;
        }
        /**
         * 極座標形式から直交座標形式へ
         * @param    c    極座標形式の複素数
         * @return    直交座標形式の複素数
         */
        // 指数関数との関連性
        static public function polarToCartesian(c:Complex):Complex {
            var length:Number = c.length;
            var angle:Number  = c.angle;
            return new Complex(
                length * Math.cos(angle),
                length * Math.sin(angle)
            );
        }


        /**
         * 対数関数
         * @param    c    複素数
         * @return    対数値
         */
        // 実数部は絶対値、虚数部は偏角
        static public function log(c:Complex):Complex {
            var cc:Complex = cartesianToPolar(c);
            return new Complex(
                Math.log(cc.length),
                cc.angle
            );
        }
        /**
         * 指数関数
         * @param    c    複素数
         * @return    指数値
         */
        // e^length * (cos(angle) + sin(angle)i)
        static public function exp(c:Complex):Complex {
            var val:Number = Math.exp(c.real);
            var im:Number  = c.imag;
            return new Complex(
                val * Math.cos(im),
                val * Math.sin(im)
            );
        }
    }
//}


//package aquioux.display.colorUtil {
    /**
     * コサインカーブで色相環的に RGB を計算
     * @author YOSHIDA, Akio
     */
    /*public*/ class RGBWheel {
        /**
         * 彩度（HSV の彩度 S と同じ扱い）
         */
        static public function get s():Number { return _s; }
        static public function set s(value:Number):void {
            _s = ColorMath.adjust1(value);
        }
        static private var _s:Number = 1.0;

        /**
         * 明度（HSV の彩度 V と同じ扱い）
         */
        static public function get v():Number { return _v; }
        static public function set v(value:Number):void {
            _v = ColorMath.adjust1(value);
        }
        static private var _v:Number = 1.0;

        /**
         * 角度に応じた RGB を得る（度数法指定）
         * @param    angle    角度（度数法）
         * @return    色（0xRRGGBB）
         */
        static private const TO_RADIAN:Number = Math.PI / 180;        // 度数を弧度に
        static public function getDegreeColor(angle:Number):uint {
            var r:uint = (Math.cos( angle        * TO_RADIAN) + 1) * 0xff >> 1;
            var g:uint = (Math.cos((angle + 120) * TO_RADIAN) + 1) * 0xff >> 1;
            var b:uint = (Math.cos((angle - 120) * TO_RADIAN) + 1) * 0xff >> 1;
            if (_s != 1.0) {
                r += calcShiftS(r);
                g += calcShiftS(g);
                b += calcShiftS(b);
            }
            if (_v != 1.0) {
                r -= calcShiftV(r);
                g -= calcShiftV(g);
                b -= calcShiftV(b);
            }
            return r << 16 | g << 8 | b;
        }
        /**
         * 角度に応じた RGB を得る（弧度法指定）
         * @param    radian    角度（弧度法）
         * @return    色（0xRRGGBB）
         */
        static private const RADIAN120:Number = Math.PI * 2 / 3;        // 120度を弧度で
        static public function getRadianColor(radian:Number):uint {
            var r:uint = (Math.cos(radian)             + 1) * 0xff >> 1;
            var g:uint = (Math.cos(radian + RADIAN120) + 1) * 0xff >> 1;
            var b:uint = (Math.cos(radian - RADIAN120) + 1) * 0xff >> 1;
            if (_s != 1.0) {
                r += calcShiftS(r);
                g += calcShiftS(g);
                b += calcShiftS(b);
            }
            if (_v != 1.0) {
                r -= calcShiftV(r);
                g -= calcShiftV(g);
                b -= calcShiftV(b);
            }
            return r << 16 | g << 8 | b;
        }


        /**
         * 彩度の反映
         * @param    gray    諧調（0～255）
         * @return    諧調のシフト値
         * @private
         */
        static private function calcShiftS(gray:uint):uint {
            return (0xff - gray) * (1 - _s) >> 0;
        }
        /**
         * 明度の反映
         * @param    gray    諧調（0～255）
         * @return    諧調のシフト値
         * @private
         */
        static private function calcShiftV(gray:uint):uint {
            return gray * (1 - _v) >> 0;
        }
    }
//}


//package aquioux.display.colorUtil {
    /**
     * 色にまつわる各種計算クラス（static クラス）
     * "HEX"   : uint 0xRRGGBB（16bitカラー）
     * "HEX32" : uint 0xAARRGGBB（32bitカラー）
     * "RGB"   : Vector.<uint>([r, b, g])
     * "ARGB"  : Vector.<uint>([r, b, g, a])
     * "HSV"   : Vector.<Number>([h, s, v])
     * @author YOSHIDA, Akio
     */
    /*public*/ class ColorMath {
        /**
         * コンストラクタ
         */
        public function ColorMath() {
            throw new Error("ColorMath クラスは static クラスです。");
        }


        // ++++++++++ "HEX" と "RGB" との相互変換 ++++++++++ //
        /**
         * "HEX" を "RGB" に変換する
         * @param    hex    "HEX"
         * @return    "RGB"
         */
        static public function hexToRgb(hex:uint):Vector.<uint> {
            var r:uint = (hex >> 16) & 0xff;
            var g:uint = (hex >>  8) & 0xff;
            var b:uint =  hex        & 0xff;
            return Vector.<uint>([r, g, b]);
        }
        /**
         * "RGB" を "HEX" に変換する
         * @param    rgb    "RGB"
         * @return    "HEX"
         */
        static public function rgbToHex(rgb:Vector.<uint>):uint {
            var r:uint = adjust255(rgb[0]);
            var g:uint = adjust255(rgb[1]);
            var b:uint = adjust255(rgb[2]);
            return r << 16 | g << 8 | b;
        }


        // ++++++++++ "HEX32" と "ARGB" との相互変換 ++++++++++ //
        /**
         * "HEX32" を "ARGB" に変換する
         * @param    hex    "ARGB"
         * @return    "ARGB"
         */
        static public function hex32ToRgb(hex:uint):Vector.<uint> {
            var a:uint = (hex >> 24) & 0xff;
            var r:uint = (hex >> 16) & 0xff;
            var g:uint = (hex >>  8) & 0xff;
            var b:uint =  hex        & 0xff;
            return Vector.<uint>([r, g, b, a]);
        }
        /**
         * "ARGB" を "HEX32" に変換する
         * @param    rgba    "ARGB"
         * @return    "ARGB"
         */
        static public function rgbToHex32(rgba:Vector.<uint>):uint {
            var a:uint = adjust255(rgba[3]);
            var r:uint = adjust255(rgba[0]);
            var g:uint = adjust255(rgba[1]);
            var b:uint = adjust255(rgba[2]);
            return a << 24 | r << 16 | g << 8 | b;
        }


        // ++++++++++ "RGB" と "HSV" との相互変換 ++++++++++ //
        /**
         * "RGB" を "HSV" に変換する
         * @param    rgb    "RGB"
         * @return    "HSV"
         * @see    http://ja.wikipedia.org/wiki/HSV%E8%89%B2%E7%A9%BA%E9%96%93
         */
        static public function rgbToHsv(rgb:Vector.<uint>):Vector.<Number> {
            // R,G,B 正規化（各値を 0 ～ 255 の範囲にする）
            var r:Number = adjust255(rgb[0]);
            var g:Number = adjust255(rgb[1]);
            var b:Number = adjust255(rgb[2]);

            // R,G,B 要素中の最大値と最小値およびその差を求める
            var minVal:Number = g < b ? g : b;
            if (r < minVal) minVal = r;                // 最大の値
            var maxVal:Number = g > b ? g : b;
            if (r > maxVal) maxVal = r;                // 最小の値
            var diffVal:Number = maxVal - minVal;    // 差分

            // H,S,V 計算
            if(diffVal == 0) {
                var h:Number = 0;
                var s:Number = 0;
                var v:Number = 0;
            } else {
                if (r == maxVal) {
                    h = 60 * (g - b) / diffVal;
                } else if (g == maxVal) {
                    h = 60 * (b - r) / diffVal + 120;
                } else {
                    h = 60 * (r - g) / diffVal + 240;
                }
                s = diffVal / maxVal;
                v = maxVal  / 0xff;
            }
            return Vector.<Number>([h, s, v]);
        }
        /**
         * "HSV" を "RGB" に変換する
         * @param    rgb    "HSV"
         * @return    "RGB"
         * @see    http://ja.wikipedia.org/wiki/HSV%E8%89%B2%E7%A9%BA%E9%96%93
         */
        static public function hsvToRgb(hsv:Vector.<Number>):Vector.<uint> {
            // H,S,V 正規化
            var h:Number = adjust360(hsv[0]);
            var s:Number = adjust1(hsv[1]);
            var v:Number = adjust1(hsv[2]);

            // R,G,B 計算
            if (s == 0) {
                var r:Number = v;
                var g:Number = v;
                var b:Number = v;
            } else {
                h /= 60;
                var i:int = h % 6 >> 0;
                var f:Number = h - i;
                var p:Number = v * (1 - s);
                var q:Number = v * (1 - s * f);
                var t:Number = v * (1 - s * (1 - f));
                switch(i) {
                    case 0:    r = v;    g = t;    b = p;    break;
                    case 1:    r = q;    g = v;    b = p;    break;
                    case 2:    r = p;    g = v;    b = t;    break;
                    case 3:    r = p;    g = q;    b = v;    break;
                    case 4:    r = t;    g = p;    b = v;    break;
                    case 5:    r = v;    g = p;    b = q;    break;
                }
            }
            return Vector.<uint>([r * 0xff >> 0, g * 0xff >> 0, b * 0xff >> 0]);
        }


        // ++++++++++ "HEX" と "HSV" との相互変換 ++++++++++ //
        /**
         * "HEX" を "HSV" に変換する
         * @param    hex    "HEX"
         * @return    "HSV"
         */
        static public function hexToHsv(hex:uint):Vector.<Number> {
            return rgbToHsv(hexToRgb(hex));
        }
        /**
         * "HSV" を "HEX" に変換する
         * @param    hsv    "HSV"
         * @return    "HEX"
         */
        static public function hsvToHex(hsv:Vector.<Number>):uint {
            return rgbToHex(hsvToRgb(hsv));
        }


        // ++++++++++ ヘルパー ++++++++++ //
        /**
         * 数値を 0.0 <= value < 360.0 の範囲に収める
         * @param    value
         * @return    チェック後の値
         * @private
         */
        static public function adjust360(value:Number):Number {
            value %= 360;
            if (value < 0) value += 360;
            return value;
        }
        /**
         * 数値を 0.0 <= value <= 1.0 の範囲に収める
         * @param    value
         * @return    チェック後の値
         * @private
         */
        static public function adjust1(value:Number):Number {
            if (value < 0.0) value = 0.0;
            if (value > 1.0) value = 1.0;
            return value;
        }
        /**
         * 数値を 0 <= value <= 255 の範囲に収める
         * @param    value
         * @return    チェック後の値
         * @private
         */
        static public function adjust255(value:uint):uint {
            if (value <   0) value =   0;
            if (value > 255) value = 255;
            return value;
        }
    }
//}
