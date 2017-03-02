package {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#ffffff")]
    /**
     * ソディの円、もしくは、デカルトの円定理
     * @see http://aquioux.net/blog/?p=3823
     * @author YOSHIDA, Akio
     */
    public class Main extends Sprite {
        // 円
        private var circleA_:Circle;        // 正接円A
        private var circleB_:Circle;        // 正接円B
        private var circleC_:Circle;        // 正接円C
        private var circleD_:Circle;        // 内接円
        private var circleE_:Circle;        // 外接円
        private var draggingCircle_:Circle;    // ドラッグ中の正接円
        private var circleContainer_:Sprite;// 円のコンテナ

        // 線
        private var line_:Line;                // 正接円の中心を結ぶ直線


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
            // 円のコンテナ
            circleContainer_ = new Sprite();
            circleContainer_.mouseEnabled = false;
            addChild(circleContainer_);
            // 円の生成
            circleA_ = makeCircle(true,  0xff6666);
            circleB_ = makeCircle(true,  0x66ff66);
            circleC_ = makeCircle(true,  0x6666ff);
            circleD_ = makeCircle(false, 0x000000);
            circleE_ = makeCircle(false, 0x808080);
            // 正接円の配置
            const CENTER_X:Number = stage.stageWidth  / 2;
            const CENTER_Y:Number = stage.stageHeight / 2;
            // 極座標計算
            var radianA:Number = (-90 + Math.random() * 40 - 20) * Math.PI / 180;
            var radianB:Number = ( 30 + Math.random() * 40 - 20) * Math.PI / 180;
            var radianC:Number = (150 + Math.random() * 40 - 20) * Math.PI / 180;
            var lengthA:int = (Math.random() * 3 >> 0) * 10 + 100;
            var lengthB:int = (Math.random() * 3 >> 0) * 10 + 100;
            var lengthC:int = (Math.random() * 3 >> 0) * 10 + 100;
            circleA_.x = CENTER_X + Math.cos(radianA) * lengthA;
            circleA_.y = CENTER_Y + Math.sin(radianA) * lengthA;
            circleB_.x = CENTER_X + Math.cos(radianB) * lengthB;
            circleB_.y = CENTER_Y + Math.sin(radianB) * lengthB;
            circleC_.x = CENTER_X + Math.cos(radianC) * lengthC;
            circleC_.y = CENTER_Y + Math.sin(radianC) * lengthC;
            circleContainer_.addChild(circleD_);
            circleContainer_.addChild(circleE_);
            circleContainer_.addChild(circleA_);
            circleContainer_.addChild(circleB_);
            circleContainer_.addChild(circleC_);

            // 正接円の中心を結ぶ直線
            line_ = new Line();
            addChild(line_);
        }
        // 正接円の生成
        private function makeCircle(isDrag:Boolean, color:uint):Circle {
            var circle:Circle = new Circle(isDrag);
            circle.color = color;
            circle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            return circle;
        }
        // マウスハンドラ
        private function mouseDownHandler(event:MouseEvent):void {
            draggingCircle_ = Circle(event.target);
            draggingCircle_.startDrag();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            stage.addEventListener(Event.MOUSE_LEAVE,     mouseUpHandler);
        }
        private function mouseMoveHandler(event:MouseEvent):void {
            draw();
        }
        private function mouseUpHandler(event:MouseEvent):void {
            draggingCircle_.stopDrag();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            stage.removeEventListener(Event.MOUSE_LEAVE,     mouseUpHandler);
        }

        /**
         * 描画
         */
        private function draw():void {
            // 各円の計算
            Calculator.calcTangentCircles(circleA_, circleB_, circleC_);
            Calculator.calcSoddyCircles(circleA_, circleB_, circleC_, circleD_, circleE_);

            // 各円の描画
            circleA_.draw();
            circleB_.draw();
            circleC_.draw();
            circleD_.draw();
            circleE_.draw();

            // 線の描画
            line_.draw(circleA_, circleB_, circleC_);
        }
    }
}


//package {
    //import aquioux.math.Complex;
    //import aquioux.math.ComplexMath;
    /**
     * ソディの円、もしくは、デカルトの4円定理
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
            var distAB:Number = dist(circleA, circleB);    // = circleA.radius + circleB.radius
            var distBC:Number = dist(circleB, circleC);    // = circleB.radius + circleC.radius
            var distCA:Number = dist(circleC, circleA);    // = circleC.radius + circleA.radius
            // 各正接円の半径を算出
            circleA.radius = (distCA + distAB - distBC) / 2;
            circleB.radius = (distAB + distBC - distCA) / 2;
            circleC.radius = (distBC + distCA - distAB) / 2;
        }
        // 2点間の距離を求める
        static private function dist(circle1:Circle, circle2:Circle):Number {
            var distX:Number = circle1.x - circle2.x;
            var distY:Number = circle1.y - circle2.y;
            return Math.sqrt(distX * distX + distY * distY);
        }

        /**
         * 3つの正接円から、その内接円と外接円の半径と中心座標を算出
         * @param    circleA
         * @param    circleB
         * @param    circleC
         * @param    circleD
         * @param    circleE
         */
        static public function calcSoddyCircles(circleA:Circle, circleB:Circle, circleC:Circle, circleD:Circle, circleE:Circle):void {
            // ----- 4番目の円の半径を求める -----
            // 4番目の円の曲率k（半径の逆数 = 1/r）を求める公式
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
            // k4 の計算結果（±なのでふたつ）
            var radiusD:Number = 1 / (kABC - sq1);    // 外接円の半径（－の方）
            var radiusE:Number = 1 / (kABC + sq1);    // 内接円の半径（＋の方）

            // ----- 4番目の円の中心座標を求める -----
            // 4番目の円の中心座標（複素平面上）を求める公式
            // (z1*k1 + z2*k2 + z3*k3 + z4*k4)^2 = 2 * (z1^2*k1^2 + z2^2*k2^2 + z3^2*k3^2 + z4^2*k4^2)
            // ↓
            // z4 = (z1*k1 + z2*k2 + z3*k3 ± 2 * √(z1*k1 * z2*k2 + z2*k2 * z3*k3 + z3*k3 * z1*k1)) / k4

            // 各正接円の座標
            var zA:Complex = new Complex(circleA.x, circleA.y);    // z1
            var zB:Complex = new Complex(circleB.x, circleB.y);    // z2
            var zC:Complex = new Complex(circleC.x, circleC.y);    // z3
            // 分子のうち、±前の部分
            var zkA:Complex   = ComplexMath.scale(zA, kA);        // z1 * k1
            var zkB:Complex   = ComplexMath.scale(zB, kB);        // z2 * k2
            var zkC:Complex   = ComplexMath.scale(zC, kC);        // z3 * k3
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
            // z4 の計算結果（±なのでふたつ）
            var zD:Complex = ComplexMath.scale(ComplexMath.subtract(zkABC, sq2), radiusD);    // 外接円（－の方）
            var zE:Complex = ComplexMath.scale(ComplexMath.add(zkABC, sq2), radiusE);        // 内接円（＋の方）

            // 外接円
            circleD.x = zD.real;
            circleD.y = zD.imag;
            circleD.radius = radiusD;
            // 内接円
            circleE.x = zE.real;
            circleE.y = zE.imag;
            circleE.radius = radiusE;
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
        public function get real():Number { return _real; }
        public function set real(value:Number):void { _real = value; }
        public function get x():Number { return _real; }
        public function set x(value:Number):void { _real = value; }
        // 実数部
        private var _real:Number;

        /**
         * 虚数部
         */
        public function get imag():Number { return _imag; }
        public function set imag(value:Number):void { _imag = value; }
        public function get y():Number { return _imag; }
        public function set y(value:Number):void { _imag = value; }
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


        // ----- 四則演算 -----
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
            var len:Number   = Math.pow(abs(c), exponent);
            var angle:Number = Math.atan2(c.imag, c.real) * exponent;
            return new Complex(
                len * Math.cos(angle),
                len * Math.sin(angle)
            );
        }


        /**
         * 直交座標形式から極座標形式へ
         * @param    c    直交座標形式の複素数
         * @return    極座標形式の複素数
         */
        // 対数関数との関連性
        static public function cartesianToPolar(c:Complex):Complex {
            return new Complex(
                abs(c),                        // 長さ
                Math.atan2(c.imag, c.real)    // 偏角
            );
        }
        /**
         * 極座標形式から直交座標形式へ
         * @param    c    極座標形式の複素数
         * @return    直交座標形式の複素数
         */
        // 指数関数との関連性
        static public function polarToCartesian(c:Complex):Complex {
            var len:Number   = c.real;
            var angle:Number = c.imag;
            return new Complex(
                len * Math.cos(angle),
                len * Math.sin(angle)
            );
        }


        /**
         * 対数関数
         * @param    c    複素数
         * @return    対数値
         */
        // 実数部は絶対値、虚数部は偏角
        static public function log(c:Complex):Complex {
            return new Complex(
                Math.log(abs(c)),
                Math.atan2(c.imag, c.real)
            );
        }
        /**
         * 指数関数
         * @param    c    複素数
         * @return    指数値
         */
        // e^x * (cosy + isiny)
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


//package {
    import flash.display.Graphics;
    import flash.display.Sprite;
    /**
     * 円クラス
     * @author YOSHIDA, Akio
     */
    /*public*/ class Circle extends Sprite {
        /**
         * 半径
         */
        public function get radius():Number { return _radius; }
        public function set radius(value:Number):void { _radius = value; }
        private var _radius:Number;

        /**
         * 描画色
         */
        public function set color(value:uint):void { _color = value; }
        private var _color:uint = 0x000000;


        /**
         * コンストラクタ
         */
        public function Circle(isDrag:Boolean = false):void {
            if (isDrag) this.buttonMode = true;
        }

        /**
         * 描画
         */
        public function draw():void {
            var g:Graphics = this.graphics;
            g.clear();
            g.beginFill(_color);
            g.drawCircle(0, 0, _radius);
            g.endFill();
        }
    }
//}


//package {
    import flash.display.Graphics;
    import flash.display.Shape;
    /**
     * 線クラス
     * @author YOSHIDA, Akio
     */
    /*public*/ class Line extends Shape {
        /**
         * 描画色
         */
        public function set color(value:uint):void { _color = value; }
        private var _color:uint = 0xffffff;


        /**
         * コンストラクタ
         */
        public function Line():void {
        }

        /**
         * 描画
         */
        public function draw(circleA:Circle, circleB:Circle, circleC:Circle):void {
            // 正接円の中心座標
            var xA:Number = circleA.x;
            var yA:Number = circleA.y;
            var xB:Number = circleB.x;
            var yB:Number = circleB.y;
            var xC:Number = circleC.x;
            var yC:Number = circleC.y;
            // 正接円の中心を結ぶ線の描画
            var g:Graphics = this.graphics;
            g.clear();
            g.lineStyle(0, _color);
            g.moveTo(xA, yA);
            g.lineTo(xB, yB);
            g.lineTo(xC, yC);
            g.lineTo(xA, yA);
        }
    }
//}
