package  
{
    import com.bit101.components.Panel;
    import com.bit101.components.HUISlider;
    import com.bit101.components.PushButton;

    import org.libspark.thread.utils.ParallelExecutor;
    import org.libspark.thread.EnterFrameThreadExecutor;
    import org.libspark.thread.Thread;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    import fl.motion.easing.Quadratic;

    /**
     * 昔見たグルビのあれ、っぽいの
     * 
     * ビットマップを使わずにベクターのみで何か作ってみたかった
     * 幾何のプラクティスもかねて無駄にベクトルや線分などのオブジェクトを定義してます。
     * 全部のクラスをインラインにしたらソースコードが長大に。。
     * 
     * @author imajuk
     */
    public class OnCurves extends Sprite 
    {
        private static const CANVAS_WIDTH : int = 400;
        private static const CANVAS_HEIGHT : int = 280;
        private var mainLoop : ParallelExecutor;
        private var main : Thread;
        private var cars : Vector.<CarModel>;
        private var carViews : Dictionary = new Dictionary(true);
        private var primaryCar : CarModel;
        private var cameraA : CameraRect;
        private var cameraB : CameraRect;
        private var cameraC : CameraRect;
        private var cameraScaler : Function;
        private var canvas : Canvas;
        //Bezier曲線レンダラー
        private var renderer : BezierRenderer;
        //Bezier曲で構成される道路
        private var road : RoadModel = new RoadModel(9);
        //初期スケール 
        private var defaultScale : Number = 9;
        //道路の描画スタイル
        private var style : RoadStyle = new RoadStyle(defaultScale);
        private var scaleSlider : HUISlider;

        public function OnCurves()
        {
            Wonderfl.capture_delay(10);
            //=================================
            // Stage setting
            //=================================
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = 60;
            
            //=================================
            // initialize Thread
            //=================================
            Thread.initialize(new EnterFrameThreadExecutor());
            
            //=================================
            // create renderer
            //=================================
            renderer = new BezierRenderer(50);
            
            //=================================
            // camera
            //=================================
            cameraA = new CameraRect(CANVAS_WIDTH, CANVAS_HEIGHT, 1);
            cameraB = new CameraRect(CANVAS_WIDTH, CANVAS_HEIGHT, defaultScale);
            cameraC = new CameraRect(CANVAS_WIDTH, CANVAS_HEIGHT, defaultScale);
            
            //=================================
            // background
            //=================================
            addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xFBFBFB)));
            
            //=================================
            // canvas
            //=================================
            canvas = 
                addChild(
                    new Canvas(CANVAS_WIDTH, CANVAS_HEIGHT, 0xeeebe9)
                ) as Canvas;
            canvas.x = 30;
            canvas.y = 70;
            canvas.gradientAngle = Math.PI * .2;
            
            //=================================
            // clock
            //=================================
            Clock.initialize(stage.frameRate);

            //=================================
            // car
            //=================================
            //20台分の車のモデルを生成
            cars = CarFactory.create(20, road);
            //プライマリーカーを定義
            primaryCar = cars[0];
            //モデルからビューを生成
            cars.forEach(function(car : CarModel, ...param):void
            {
                var primary : Boolean = car.primary;
                var color : uint = (primary) ? 0xDEAFE6 : 0x50AD7E;
                var color2 : uint = (primary) ? 0xBA66B1 : 0x397D5B;
                carViews[car] = canvas.addChild(new Car(color, color2));
            });
            
            //=================================
            // UI
            //=================================
            mouseEnabled = false;
            var panel:Panel = new Panel(this, 30, 300);
            panel.setSize(400, 50);
            panel.alpha = .7;
            
            //=================================
            // slider for speed
            //=================================
            var sSpeed : HUISlider = 
                new HUISlider(
                    panel, 20, 10, "speed", 
                    function():void
                    {
                        primaryCar.maxSpeed = sSpeed.value;
                    }
                );
            sSpeed.setSize(270, 20);
            sSpeed.setSliderParams(0, 10, primaryCar.maxSpeed);
            sSpeed.value = primaryCar.maxSpeed;
            
            //=================================
            // slider for scale
            //=================================
            scaleSlider = new HUISlider(panel, 20, 20, "scale ");
            scaleSlider.setSize(270, 20);
            scaleSlider.setSliderParams(10, 110, defaultScale * 10);
            
            //=================================
            // button for updating road
            //=================================
            new PushButton(panel, 280, 14, "new  road",start);
            
            start();
        }

        private function start(...param) : void 
        {
            if (main)
            {
                road.reset();
                main.interrupt();
            }
            
            mainLoop = new ParallelExecutor();
            
            //=================================
            // Drive car
            //=================================
            //プライマリカーと同じ方向を走っている他の車
            var safeTarget:Vector.<CarModel> = 
                cars.filter(
                    function(car : CarModel, ...param):Boolean
                    {
                        return !car.primary && car.direction == CarModel.CLOCKWISE; 
                    }
                );
            mainLoop.addThread(new DriveThread(cars, safeTarget));
            
            //=================================
            // controler for cameraB
            //=================================
            //プライマリーカーをカメラが追いかけるThread
            mainLoop.addThread(new ChasingCameraThread(primaryCar, cameraB));
            //スケール値を正規化するオブジェクト
            var mixedValue:Normalizer = new Normalizer(10, 110, Quadratic.easeInOut);
            mixedValue.calc(scaleSlider.value);
            //カメラのズームを変更するクロージャ
            cameraScaler = 
                function(s:Number):void
                {
                    //カメラBのスケールを変更 
                    cameraB.scaleX = cameraB.scaleY = 1 / (s / 10);
                    //ズームを計算
                    mixedValue.calc(s);
                    //レンダラーの精度を変更
                    renderer.accuracy = s * .3 + 10;
                };
            //カメラのズームを管理するThread
            mainLoop.addThread(new ScaleSliderThread(scaleSlider, cameraScaler, stage));
            //=================================
            // camera motion mixer
            // カメラAは固定、カメラBは車を追いかける.
            // カメラAとカメラBをミックスしたカメラCをアクティブカメラとして採用する
            //=================================
            mainLoop.addThread(
                new MotionMixerThread(cameraA, cameraB, cameraC, mixedValue, cameraC.validate));
                
            //=================================
            // controler for view
            //=================================
            mainLoop.addThread(new CarControlerThread(cars, cameraC, carViews));
            
            //=================================
            // renderer for camera view
            //================================= 
            mainLoop.addThread(
                new RenderBezierThread(
                        cameraC, 
                        renderer, 
                        canvas, 
                        road,
                        style
                    )
            );
            
            //=================================
            // start trip. good luck!
            //=================================
            main = 
                new BezierTripThread(
                    road, 
                    cars, 
                    mainLoop,
                    cameraA
                );
            main.start();
        }
    }
}

import org.libspark.thread.Thread;
import com.bit101.components.HUISlider;
import flash.display.Stage;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.GradientType;
import flash.display.IGraphicsData;
import flash.display.GraphicsPath;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.GraphicsPathCommand;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.filters.DropShadowFilter;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getTimer;
import flash.utils.Dictionary;
import fl.motion.easing.Quadratic;
import fl.transitions.easing.None;

//--------------------------------------------------------------------------
//
//  Models
//
//--------------------------------------------------------------------------

class Clock 
{
    public static var delay : Number = 0;
    private static var tick : Number;
    private static var internalTime : int;

    public static function update() : void 
    {
        var temp : int = internalTime;
        internalTime = getTimer();
        delay = (internalTime - temp) * tick;
    }

    public static function initialize(frameRate : Number) : void 
    {
        tick = 1 / (1000 / frameRate);
    }
}

class RoadModel 
{
    public var anchorPoints : Vector.<AnchorPoint>;
    public var amount : int;

    public function RoadModel(amount : int) 
    {
        if (amount < 2) throw new Error("the road is too short.");
        this.amount = amount;
        reset();
    }

    public function getAnchorPoint(invert : Boolean) : Vector.<AnchorPoint> 
    {
        return (invert) ? AnchorPointHelper.invert(anchorPoints) : anchorPoints;
    }

    public function reset() : void 
    {
        this.anchorPoints = new Vector.<AnchorPoint>();
    }

    public function getBounce() : Rectangle 
    {
        var minX:Number = NaN;
        var maxX:Number = NaN;
        var minY:Number = NaN;
        var maxY:Number = NaN;
        
        anchorPoints.forEach(function(a:AnchorPoint, ...param):void
        {
            minX = isNaN(minX) ? a.x : Math.min(a.x, minX);
            maxX = isNaN(maxX) ? a.x : Math.max(a.x, maxX);
            minY = isNaN(minY) ? a.y : Math.min(a.y, minY);
            maxY = isNaN(maxY) ? a.y : Math.max(a.y, maxY);
        });
        return new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }
}

class CarModel 
{
    public static const CLOCKWISE : int = 1;
    public static const OPPOSITE : int = -1;
    //現在位置
    public var point : Point = new Point();
    //現在の向き
    public var rotation : Number = 0;
    //全体のコースを10000とした時の1フレあたりの移動量
    public var speed : Number;
    public var maxSpeed : Number;
    public var minSpeed : Number;
    public var history : DriveHistory;
    public var primary : Boolean;
    public var direction : int;
    public var road : RoadModel;
    //道路の中央線からどのくらい離れて走るか
    public var safeDrive : Number = 1.2;
    private var currentTime : Number = 0;

    public function CarModel(
                        speed : Number, 
                        road:RoadModel,
                        primary:Boolean = false, 
                        direction : int = CLOCKWISE
                    ) 
    {
        this.direction = direction;
        this.maxSpeed = speed;
        this.minSpeed = speed * .1;
        this.speed = speed;
        this.primary = primary;
        this.road = road;
    }
    
    public function initialize() : void 
    {
        //=================================
        // set history object
        //=================================
        //逆走するモデルはでアンカーポイントを逆にする
        var isInvert : Boolean = direction == CarModel.OPPOSITE;
        history = new DriveHistory(road.getAnchorPoint(isInvert), !primary);
    }

    public function update() : void 
    {
//wonderfl上で実行すると思いのほかFPSが安定しなかったので時計使うのはやめる
//        if (primary) 
//            Clock.update();
        if (speed == 0)
            return;
        
        //現在の曲線を通過するのにかかるフレーム数
        var frames : Number = history.currentDistance / speed;
        //1フレあたりの時間増分
        var tick : Number = 1 / frames;
//        currentTime += tick * Clock.delay;
        currentTime += tick;

        //=================================
        // update history 
        // when the pos reached the end of a Bezier curve
        //=================================
        if (currentTime >= 1)
        {
            currentTime -= 1;
            history.updateBezier();
        }
        
        //現在位置を更新して取得
        point = history.updatePoint(currentTime);
        //現在の向きを取得
        rotation = MathUtil.radiansToDegrees(history.currentVector.angle);
    }

    public function getCurrentVector() : Vector2D 
    {
        return history.currentVector.clone();
    }

    public function get diff() : Number 
    {
        return history.diff;
    }
}

class DriveHistory 
{
    //=================================
    // Bezier running cars
    //=================================
    public var currentBezier : BezierSegment;                   //現在のベジェ曲線
    private var previousAnchorPoint : AnchorPoint;              //前回のアンカーポイント
    private var currentAnchorPoint : AnchorPoint;               //現在のアンカーポイント
    private var nextAnchorPoint : AnchorPoint;                  //次のアンカーポイント
    //=================================
    // infomation of car
    //=================================
    public var currentVector : Vector2D = Vector2D.create(0);   //現在のベクトル
    private var previousVector : Vector2D= Vector2D.create(0);  //前回のベクトル
    private var previousPosition : Point;                       //前回のベジェ曲線上の位置
    private var currentPosition : Point = new Point();          //現在のベジェ曲線上の位置
    //=================================
    // utils
    //=================================
    private var iterator : IIterator;
    private var anchorPoints : Vector.<AnchorPoint>;
    private static var whole : Number = NaN;
    public var diff : Number;
    private var _startingPositionAsRandom : Boolean;
    public var currentDistance : Number;

    public function DriveHistory(
                        anchorPoints : Vector.<AnchorPoint>, 
                        startingPositionAsRandom:Boolean = false
                    ) 
    {
        _startingPositionAsRandom = startingPositionAsRandom;
        //=================================
        // define points
        //=================================
        this.anchorPoints = anchorPoints;
        iterator = new VectorIterator(anchorPoints);
        previousAnchorPoint = anchorPoints[0];
        currentAnchorPoint = iterator.next();
        nextAnchorPoint = iterator.next();

        var l:int = anchorPoints.length;
        
        if (startingPositionAsRandom)
        {
            var r : int = Math.random() * l * .8;
            for (var i : int = 0;i < r;i++) 
            {
                updateBezier();
            }
        }
        
        //=================================
        // 道路全体の長さ
        //=================================
        if (isNaN(whole))
        {
            whole = 0;
            for (var j : int = 0;j < l; j++)             
            {
                var n : int = j == l - 1 ? 0 : j + 1;
                whole += 
                    BezierHelper.getBezierFromAnchorPair(
                        anchorPoints[j], 
                        anchorPoints[n]
                    ).length;
            }
        }
        
        currentBezier = getBezier();
        currentDistance = getCurrentDistance();
    }
    
    public function updateBezier() : void 
    {
        if (!iterator.hasNext())
            iterator = new VectorIterator(anchorPoints);
        
        previousAnchorPoint = currentAnchorPoint;
        currentAnchorPoint = nextAnchorPoint;
        nextAnchorPoint = iterator.next();
        currentBezier = getBezier();
        currentDistance = getCurrentDistance();
    }

    public function updatePoint(time : Number) : Point 
    {
        //=================================
        // update position
        //=================================
        var p:Point = currentBezier.getValue(time); 
        previousPosition = currentPosition; 
        currentPosition = p;
        //=================================
        // update vector
        //=================================
        previousVector = currentVector;
        currentVector = 
            Vector2D.createFromPoint(previousPosition, currentPosition);
        diff = currentVector.getRadiansWith(previousVector);
        
        return p;
    }

    private function getBezier() : BezierSegment 
    {
        return BezierHelper.getBezierFromAnchorPair(
                    currentAnchorPoint, nextAnchorPoint);
    }

    private function getCurrentDistance() : Number 
    {
        return (currentBezier.length / whole) * 10000;
    }
}

/**
 * カメラ定義
 */
class CameraRect extends Shape 
{
    //原点
    public var registration : Point = null;
    //レンダリング対象セグメント抽出用の拡張矩形の大きさ
    private var expander : Number = 300;
    private var tlAngle : Number;
    private var dist : Number;
    public var cameraWidth : int;
    public var cameraHeight : int;
    private var _currentWidth : Number;
    private var _currentHeight : Number;
    
    /**
     * 原点を中心としたカメラの矩形を定義する
     * @param cameraWidth   カメラの矩形の幅.
     * @param cameraHeight  カメラの矩形の高さ.
     * @param scale         カメラのスケール.
     */
    public function CameraRect(cameraWidth : int, cameraHeight : int, scale : Number)
    {
        this.cameraHeight = cameraHeight;
        this.cameraWidth = cameraWidth;
        
        var harfW_ex:Number = cameraWidth * .5 + expander * .5;
        var harlH_ex:Number = cameraHeight * .5 + expander * .5;
        this.scaleX = this.scaleY = 1 / scale;

        //矩形の中心を原点とする
        this.registration = new Point(cameraWidth * .5, cameraHeight * .5);
        //原点から見た左上の点の角度
        tlAngle = Vector2D.createFromPoint(new Point(-harfW_ex, -harlH_ex)).angle;
        //原点から左上の点までの距離
        dist = Math.sqrt(harfW_ex * harfW_ex + harlH_ex * harlH_ex);
    }

    public function validate() : void 
    {
        _currentWidth = (cameraWidth + expander) * scaleX;
        _currentHeight = (cameraHeight + expander) * scaleY;
    }
    
    //4辺を構成するセグメントを返す
    public function get sides() : Vector.<Segment> 
    {
        //現在のラジアン度
        var r : Number = MathUtil.degreesToRadians(rotation);
        
        var angle : Number = tlAngle + r;
        var l : Number = dist * scaleX;
        //左上の点
        var lt : Point = new Point(x + Math.cos(angle) * l, y + Math.sin(angle) * l);
        
        //上辺
        var top : Segment = Segment.createFromVector2D(lt, Vector2D.create(r, _currentWidth));
        //右辺
        var right : Segment = Segment.createFromVector2D(top.end, Vector2D.create(r + Math.PI * .5, _currentHeight));
        //下辺
        var bottom : Segment = Segment.createFromVector2D(right.end, Vector2D.create(r + Math.PI, _currentWidth));
        //左辺
        var left : Segment = Segment.createFromVector2D(bottom.end, Vector2D.create(r - Math.PI * .5, _currentHeight));
            
        return Vector.<Segment>([top, right, bottom, left]);
    }

    //グローバル空間の座標をカメラ空間の座標に変換して返す
    public function getPosition(p : Point) : Point 
    {
        //カメラ空間座標への変換マトリクス
        var m : Matrix = transform.matrix.clone();
        //その逆マトリックス
        m.invert();
        //カメラ空間から見たポイントの座標
        return m.transformPoint(p);
    }
}

/**
 * レンダリング対象のアンカーポイントを抽出するロジック
 */
class AnchorPointAssembler 
{
    private var anchorPoints : Vector.<AnchorPoint>;
    private var segments : Vector.<Segment> = new Vector.<Segment>;
    private var bezierToAnchor : Dictionary;
    private var segToBezier : Dictionary;
    private var lastBezierID:uint;

    /**
     * コンストラクタ
     * @param anchorPoints  検査対象となるAnchorPoint
     * @param sensitive     検査の精度
     */
    public function AnchorPointAssembler(
                        anchorPoints : Vector.<AnchorPoint>,
                        sensitive:int 
                    ) 
    {
        this.anchorPoints = anchorPoints.concat();
        initialize(sensitive);
    }

    /**
     * アンカーポイントを結ぶベジェ曲線をn分割した線分としてキャッシュする.
     * このセグメントはカメラとの衝突判定を経てベジェ曲線のレンダリング判定に使われる
     */
    private function initialize(div:int) : void 
    {
        //=================================
        // ベジェ曲線を分割したセグメントから
        // アンカーポイントを参照するための辞書
        //=================================
        //ベジェ曲線をキーに対応するアンカーポイントを参照するための辞書
        bezierToAnchor = new Dictionary(true);
        //セグメントをキーにベジェ曲線を参照するための辞書
        segToBezier = new Dictionary(true);
        
        //=================================
        // ベジェ曲線の分割
        //================================= 
        //アンカーポイントをベジェ曲線に変換
        var beziers:Vector.<BezierSegment> = 
            BezierHelper.getBezierFromAnchors(anchorPoints, true, false, bezierToAnchor);
        //ベジェ曲線のセットのうち最後のベジェ曲線のインデックスを保存
        lastBezierID = beziers.length - 1;
        //すべてのベジェ曲線をdiv個のセグメントに分割してsegmentsに格納
        var cur:Point;
        var sID:int = 0;
        beziers.forEach(
            function(bz:BezierSegment, ...param):void
            {
                var pre:Point = null;
                var seg:Segment;
                for (var n:int = 0;n <= div;n++) 
                {
                    cur = bz.getValue(n * 1 / div);
                    if (pre)
                    {
                        seg = Segment.createFromPoint(pre, cur);
                        seg.id = sID++;
                        segments.push(seg);
                        //ベジェ曲線を分割したセグメントからベジェ曲線を参照できるようにしておく
                        segToBezier[seg] = bz;
                    }
                    pre = cur;
                }
            });
    }
    
    //カメラが描画するべきアンカーポイントを返す
    public function assembleAnchorPoint(cameraRectSides:Vector.<Segment>) : Vector.<Vector.<AnchorPoint>>
    {
        //=================================
        // セグメントとカメラの矩形を総当たりで衝突判定
        // カメラの矩形内にあるセグメントで構成されるベジェ曲線はレンダリング候補
        //=================================
        var segmentsWithinCamera : Vector.<Segment> = 
            segments.filter(
                function(sg1 : Segment, ...param):Boolean
                {
                    return  cameraRectSides.every(
                                function(sg2 : Segment, ...param):Boolean
                                {
                                    return sg2.isRightSide(sg1.begin);
                                }
                            ) ||
                            cameraRectSides.some(
                                function(sg2 : Segment, ...param):Boolean
                                {
                                    return sg2.isCrossing(sg1);
                                }
                            );
                }
            );
        
        //=================================
        // カメラ内にあるベジェ曲線がわかったので、
        // レンダリングするべきアンカーポイントのペアを調べる
        //=================================
        var result:Vector.<Vector.<AnchorPoint>>  = new Vector.<Vector.<AnchorPoint>>();
        var dup:Dictionary = new Dictionary(true);          
        segmentsWithinCamera.forEach(
            function(seg:Segment, ...param):void
            {
                //線分からアンカーポイントを逆引き
                var anchorPair:Array = bezierToAnchor[segToBezier[seg]];
                var ap1:AnchorPoint = anchorPair[0] as AnchorPoint;
                var ap2:AnchorPoint = anchorPair[1] as AnchorPoint;
                
                //同じペアは重複してつくらない
                var pair:String = ap1.id + "-" + ap2.id; 
                if (dup[pair])
                   return;
                dup[pair] = true;
                
                result.push(Vector.<AnchorPoint>([ap1, ap2]));
            }
        );
        
        return result;
    }
}

class Normalizer 
{
    public var value : Number;
    private var length : int;
    private var easing : Function;
    public var min : int;
    public var max : int;

    public function Normalizer(min : int, max : int, easing : Function = null) 
    {
        this.min = min;
        this.max = max;
        this.length = max - min;
        this.easing = (easing == null) ? None.easeInOut : easing;
    }

    public function calc(v : Number) : void 
    {
        value = easing(v - min, 0, 1, length);
    }
}

//--------------------------------------------------------------------------
//
//  View
//
//--------------------------------------------------------------------------

class Canvas extends Sprite 
{
    private var _canvas : Sprite;
    private var canvasWidth : int;
    private var canvasHeight : int;
    private var gradLength : Number;
    private var gradMatrix : Matrix;
    private var registration : Point;
    private var color : uint;

    public function get canvas() : Sprite
    {
        return _canvas;
    }
    
    public function Canvas(
                        width:int,
                        height:int,
                        color:uint = 0xDDDDDD,
                        useMask:Boolean = true,
                        useCenterAsOrigin:Boolean = true
                    )
    {
        canvasWidth = width;
        canvasHeight = height;
        gradLength = Math.sqrt(canvasWidth * canvasWidth + canvasHeight * canvasHeight);
        gradMatrix = new Matrix();
        gradMatrix.createGradientBox( 1, 1, 0, -0.5, -0.5 );
        registration = new Point(width * .5, height*.5);
        this.color = color;
        mouseEnabled = false;
        mouseChildren = false;
        
        //=================================
        // canvas for rendering
        //=================================
        _canvas = addChild(new Sprite()) as Sprite;
        if (useCenterAsOrigin)
        {
            //実際に描画されるキャンバスの原点はこのコンテナ内の中央
            _canvas.x = registration.x;
            _canvas.y = registration.y;
        }
        //=================================
        // mask
        //=================================
        if (useMask)
        {
            var b:BitmapData = new BitmapData(width, height, false, 0);
            mask = addChild(new Bitmap(b));
        }
    }

    public function set gradientAngle(angle:Number) : void 
    {
        var m:Matrix = gradMatrix.clone();
        m.scale(gradLength, 1);
        m.rotate(angle);
        m.translate(registration.x, registration.y);
        graphics.clear();
        graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, color], [1,1], [0,255], m);
        graphics.drawRect(0, 0, canvasWidth, canvasHeight);
        graphics.endFill();
    }
}

class Car extends Shape 
{
    private var shadow : DropShadowFilter;

    public function Car(bodyColor : uint, tireColor : uint)
    {
        cacheAsBitmap = true;
        
        var g : Graphics = graphics;
        
        g.beginFill(tireColor, 1);
        g.moveTo(-1.9, -1.25);
        g.curveTo(-3.8, -1.35, -4, -2.45);
        g.curveTo(-3.8, -3.55, -1.9, -3.65);
        g.curveTo(0.05, -3.55, 0.2, -2.45);
        g.curveTo(0.05, -1.35, -1.9, -1.25);

        g.moveTo(-3.9, 2.4);
        g.curveTo(-3.7, 1.3, -1.8, 1.2);
        g.curveTo(0.15, 1.3, 0.3, 2.4);
        g.curveTo(0.15, 3.5, -1.8, 3.6);
        g.curveTo(-3.7, 3.5, -3.9, 2.4);

        g.beginFill(bodyColor, 1);
        g.moveTo(0.65, -3.35);
        g.curveTo(3.3, -3.35, 5.15, -2.35);
        g.curveTo(7, -1.35, 7, 0.05);
        g.curveTo(7, 1.45, 5.15, 2.4);
        g.curveTo(3.25, 3.4, 0.65, 3.4);
        g.curveTo(-2, 3.4, -3.9, 2.4);
        g.curveTo(-5.75, 1.45, -5.75, 0.05);
        g.curveTo(-5.75, -1.35, -3.9, -2.35);
        g.curveTo(-2, -3.35, 0.65, -3.35);
        
        
        g.beginGradientFill(
            "linear", 
            [0xc9c9c9,0xececec,0xbcbcbc], 
            [1,1,1], 
            [0,70,255], 
            new Matrix(0.0068817138671875, 0, 0, -0.0068817138671875, 0.6, 0.05), 
            "pad", 
            "rgb"
        );
        g.moveTo(0.65, -2.55);
        g.curveTo(3.05, -2.55, 4.75, -1.8);
        g.curveTo(6.45, -1.05, 6.45, 0.05);
        g.curveTo(6.45, 1.1, 4.75, 1.85);
        g.curveTo(3.05, 2.6, 0.65, 2.6);
        g.curveTo(-1.8, 2.6, -3.5, 1.85);
        g.curveTo(-5.2, 1.1, -5.2, 0.05);
        g.curveTo(-5.2, -1.05, -3.5, -1.8);
        g.curveTo(-1.8, -2.55, 0.65, -2.55);
         
        shadow = new DropShadowFilter(1, 0, 0, .8, 2, 2);
        filters = [shadow];
    }

    public function updateShadow(value : Number) : void 
    {
        shadow.angle = value;
    }
}

class RoadStyle 
{
    private var stroke1 : GraphicsStroke;
    private var stroke2 : GraphicsStroke;
    private var stroke3 : GraphicsStroke;
    private var stroke4 : GraphicsStroke;
    private var stroke5 : GraphicsStroke;
    private var stroke6 : GraphicsStroke;
    private var _scale : Number = 1;

    public function RoadStyle(scale:Number) 
    {
        stroke1 = new GraphicsStroke(0);
        stroke1.fill = new GraphicsSolidFill(0xffe0f6, 1);
        
        stroke2 = new GraphicsStroke(1); 
        stroke2.caps = CapsStyle.ROUND;
        stroke2.fill = new GraphicsSolidFill(0xFFFFFF, .7);
        
        stroke3 = new GraphicsStroke(1); 
        stroke3.caps = CapsStyle.ROUND;
        var b3:BitmapData = new BitmapData(4, 4, true, 0x00FFFFFF);
        var cl:uint = 0x4895b7ff;
        b3.setPixel32(0, 0, cl);
        b3.setPixel32(1, 1, cl);
        b3.setPixel32(2, 2, cl);
        b3.setPixel32(3, 3, cl);
        stroke3.fill = new GraphicsBitmapFill(b3, null, true, true);
        
        stroke4 = new GraphicsStroke(1); 
        stroke4.caps = CapsStyle.ROUND;
        stroke4.fill = new GraphicsSolidFill(0xf5f7f3, 1);
        
        stroke5 = new GraphicsStroke(1); 
        stroke5.caps = CapsStyle.ROUND;
        stroke5.fill = new GraphicsSolidFill(0xf5f7df, 1);
        stroke6 = new GraphicsStroke(1); 
        stroke6.caps = CapsStyle.ROUND;
        stroke6.fill = new GraphicsSolidFill(0xecead7, 1);

        this.scale = scale;
    }

    public function set scale(value : Number) : void
    {
        if (_scale == value)
           return;
           
        _scale = value;
        stroke2.thickness = value * 7.7;
        stroke3.thickness = value * 20;
        stroke4.thickness = value * 18.57;
        stroke5.thickness = value * 21;
        stroke6.thickness = value * 23;
    }

    public function getStrokes(path:GraphicsPath) : Vector.<IGraphicsData> 
    {
        return Vector.<IGraphicsData>([
           stroke6, path, 
           stroke5, path, 
           stroke4, path, 
           stroke3, path, 
           stroke2, path, 
           stroke1, path
        ]);
    }
}

/**
 * ベジェ曲線で定義されたシェイプのレンダラー
 * 
 * ベジェ曲線で定義されたシェイプを描画します。
 * アンカーポイントオブジェクトのセット、またはベジェ曲線オブジェクトのセットを使用し描画します。
 */
class BezierRenderer 
{
    public var accuracy:int;
    private var invertDrawing:Boolean;

    /**
     * コンストラクタ
     * @param accuracy  ベジェ曲線をレンダリングする際にどのくらいの直線で分割するか
     * @param shape_color   シェイプのカラー
     * @param line_color    ラインの色
     * @param pattern       塗りにパターンを使用するかどうか
     * @param invert        渡されたアンカーポイントは通常時計回りに描画されるが
     *                      これを反時計回りに描画する場合はtrueを指定します
     */
    public function BezierRenderer(
                        accuracy:int,
                        invert:Boolean = false
                    ) 
    {
        this.accuracy = accuracy;
        invertDrawing = invert;
    }
    
    /**
     * AnchorPointのコレクションで定義された複数のベジェ曲線を描画するためのGraphicsPathを返します.
     * ベジェ曲線を一つだけ渡す場合はgetGraphicsPathFromBezierCurve()を使用します.
     * @param anchorPoints  ベジェ曲線を表現するAnchorPointのコレクションを要素にもつVectorです.
     * @param closedShape   閉じた図形かどうか
     */
    public function getGraphicsPathFromMultipleBezierCurve(
                        anchorPointSets:Vector.<Vector.<AnchorPoint>>,
                        closedShape:Boolean,
                        path:GraphicsPath = null
                    ):GraphicsPath
    {
        path = path || getNewGraphicsPath();
        
        for each (var aps : Vector.<AnchorPoint> in anchorPointSets) 
        {
            getGraphicsPathFromBezierCurve(aps, closedShape, path);
        }
        return path;
    }

    /**
     * AnchorPointのコレクションで定義されたベジェ曲線を描画するためのGraphicsPathを返します.
     * 複数のベジェ曲線を渡す場合はgetGraphicsPathFromMultipleBezierCurve()を使用します.
     * @param anchorPoints  ベジェ曲線を表現するAnchorPointのコレクションです.
     * @param closedShape   閉じた図形かどうか
     */
    public function getGraphicsPathFromBezierCurve(
                        anchorPoints:Vector.<AnchorPoint>,
                        closedShape:Boolean,
                        path:GraphicsPath = null
                    ):GraphicsPath
    {
        //ベジェ曲線の描画には少なくとも2つのAnchorPointが必要
        var apNum:int = anchorPoints.length;
        if (apNum <= 1)
            return null;
                
        //閉じたシェイプを描画するには少なくとも3つ以上のアンカーポイントが必要
        var closed:Boolean = apNum > 2 && closedShape;
        
        return getGraphicsPathFromBezier(
            BezierHelper.getBezierFromAnchors(
                anchorPoints.concat(), closed, invertDrawing
            ),
            path
        );
    }
    
    /**
     * ベジェ曲線のコレクションを線分に分解しGraphicsPathとして返します.
     * @param beziers       ベジェ曲線のコレクションです.
     */
    public function getGraphicsPathFromBezier(
                        beziers : Vector.<BezierSegment>,
                        path:GraphicsPath = null
                    ) : GraphicsPath
    {
        try
        {           
            var p:Point = BezierSegment(beziers[0]).a;
        }
        catch(e:Error)
        {
            throw new Error("BezierSegmentが渡されませんでした");
            return null; 
        }
            
        path = path || getNewGraphicsPath(); 
            
        path.commands.push(GraphicsPathCommand.MOVE_TO);
        path.data.push(p.x, p.y);
            
        
        for each (var bezir : BezierSegment in beziers) 
        {
            getPathFromBezier(bezir, path);
        }
        
        return path;
    }

    /**
     * ベジェ曲線を線分に分解し描画コマンドをGraphicsPathに登録します
     * @param bezir     ベジェ曲線オブジェクト
     * @param myCanvas  描画対象になるGraphicsオブジェクト
     */
    private function getPathFromBezier(bezir : BezierSegment, path : GraphicsPath) : void 
    {
        var t:Number = 0;
        var d:Number = 1 / accuracy;
        for (var i:int = 0;i < accuracy; i ++) 
        {
            t += d;
            var p:Point = bezir.getValue(t);
            path.commands.push(GraphicsPathCommand.LINE_TO); 
            path.data.push(p.x, p.y); 
        }
    }

    private function getNewGraphicsPath() : GraphicsPath 
    {
        return new GraphicsPath( new Vector.<int>(), new Vector.<Number>());
    }
}

//--------------------------------------------------------------------------
//
//  Controlers
//
//--------------------------------------------------------------------------

/**
 * アプリケーションの初期化とメインループの実行
 */
class BezierTripThread extends Thread 
{
    private var mainLoop : Thread;
    private var models : Vector.<CarModel>;
    private var road : RoadModel;
    private var cameraA : CameraRect;

    public function BezierTripThread(
                        road : RoadModel, 
                        models : Vector.<CarModel>, 
                        mainLoop : Thread,
                        cameraA : CameraRect
                    )
    {
        super();

        this.road = road;
        this.models = models;
        this.mainLoop = mainLoop;
        this.cameraA = cameraA;
    }

    override protected function run() : void
    {
        if (isInterrupted) return;
        
        next(createRoad);
    }

    private function createRoad() : void 
    {
        interrupted(function():void{});
        
        var t:Thread = 
            new AnchorPointFactoryThread(road, 330);
            
        t.start();
        t.join();
        
        next(initModel);
    }

    private function initModel() : void 
    {
        if (isInterrupted) return;

        models.forEach(
            function(model:CarModel, ...param):void
            {
                model.initialize();
            });
            
        next(initFixedCamera);
    }

    private function initFixedCamera() : void 
    {
        //固定カメラを道路全体が納まる位置に調整
        var rect:Rectangle = road.getBounce();
        cameraA.x = rect.x + rect.width*.5;
        cameraA.y = rect.y + rect.height*.6;
        
        next(startMainLoop);
    }

    private function startMainLoop() : void 
    {
        interrupted(function():void{});
        
        mainLoop.start();
        mainLoop.join();
    }

    override protected function finalize():void
    {
        mainLoop.interrupt();
    }
}

/**
 * 車の速度と車線変更のコントロール
 */
class DriveThread extends Thread 
{
    private var carModels : Vector.<CarModel>;
    //角度のしきい値
    private var threshold : Number = .02;
    //この車と同じ方向を走っている他の車
    private var safeTarget : Vector.<CarModel>;

    public function DriveThread(carModels:Vector.<CarModel>, safeTarget:Vector.<CarModel>)
    {
        super();
        this.carModels = carModels;
        this.safeTarget = safeTarget;
    }

    override protected function run() : void
    {
        if (isInterrupted) return;
        
        next(run);
        
        carModels.forEach(function(model:CarModel, ...param):void
        {
            //=================================
            // update car model
            //=================================
            model.update();

            //=================================
            // adjustment speed of car
            // 前回との角度差があれば加速度を減らす
            // なければ加速度を増やす
            //=================================
            //加速度
            var accelaration:Number = (model.diff < threshold) ? .1 : -.2;
            //車のスピードを決定
            model.speed = Math.min(model.maxSpeed, Math.max(model.minSpeed, model.speed + accelaration));
            
            //=================================
            // 車線変更
            //=================================
            //この処理はプライマリーカーのみ
            if (!model.primary) return;
            
            //車間距離の許容値
            var threshold2:Number = model.maxSpeed * 10;
            if (threshold2 < 1)
            {
                model.safeDrive = 1.3;
                return;
            }

            //他の車との車間距離
            var dis:Vector.<Number> = new Vector.<Number>();
            var cv:Vector2D = model.getCurrentVector();
            safeTarget.filter(
                function(car:CarModel, ...param):Boolean
                {
                    //向いている方向が違う車は無視する
                    return cv.getRadiansWith(car.getCurrentVector()) < Math.PI;
                })
            .forEach(
                function(car:CarModel, ...param):void
                {
                    dis.push(Point.distance(model.point, car.point));       
                }
            );
            if (dis.length == 0) return;
            
            //一番近い車との距離
            var nearest : Number = 
                dis.sort(
                    function(a : Number, b : Number):Number
                    {
                        return (a == b) ? 0 : (a < b) ? -1 : 1;
                    }
                )[0];
            
            //道路の中央線からどのくらいはなれて走るかを決定 
            var value : Number = Math.max(threshold2 - nearest, 0);
            model.safeDrive = Quadratic.easeInOut(value, 1.3, 1.5, threshold2);
        });
    }
}

/**
 * プライマリーカーをカメラが追いかける
 */
class ChasingCameraThread extends Thread 
{
    private var cameraRect : CameraRect;
    private var model : CarModel;
    private var previous : Point = new Point();

    public function ChasingCameraThread(
                        model:CarModel,
                        cameraRect:CameraRect
                    )
    {
        super();
        
        this.cameraRect = cameraRect;
        this.model = model;
    }

    override protected function run() : void
    {
        if (isInterrupted)
           return;
           
        next(run);

        var pos:Point = model.point;
        if (pos.equals(previous))
            return;
        
        var px:Number = pos.x;
        var py:Number = pos.y;
        
        //=================================
        // remind pos for deciding whether camera should chase car
        //=================================
        previous = pos;
        
        //=================================
        // cameraRect
        //=================================
        //カメラの位置を調整
        cameraRect.x = px;
        cameraRect.y = py;
        
        //現在の車の向き
        var carVec:Vector2D = model.getCurrentVector();
        //ターゲットになる向き（車の向き+20度）
        var target:Vector2D = carVec.rotate(MathUtil.degreesToRadians(20));
        //現在のカメラの向き
        var cameraVec:Vector2D = 
            Vector2D.create(MathUtil.degreesToRadians(cameraRect.rotation));
        //角度差
        var diff:Number = MathUtil.radiansToDegrees(cameraVec.getRadiansWith2(target)); 
        //カメラの向きを調整
        cameraRect.rotation += diff * .05;
    }
}

/**
 * ScaleSliderManipulationThreadのトリガー
 */
class ScaleSliderThread extends Thread 
{
    private var slider : HUISlider;
    private var autoScale : Thread;
    private var cameraScaler : Function;
    private var stage : Stage;

    public function ScaleSliderThread(slider : HUISlider, cameraScaler : Function, stage : Stage)
    {
        super();
        
        this.slider = slider;
        this.cameraScaler = cameraScaler;
        this.stage = stage;
    }

    override protected function run() : void
    {
        if (isInterrupted) return;
        startAutoScaling();
        waitInteraction();
        slider.addEventListener(Event.CHANGE, onChange);
    }

    private function waitInteraction() : void 
    {
        if (isInterrupted) return;
        interrupted(function():void{});
        
        event(stage, MouseEvent.MOUSE_UP, function():void
        {
            startAutoScaling();
            waitInteraction();
        });
        event(stage, MouseEvent.MOUSE_DOWN, function():void
        {
            stopAutoScaling();
            waitInteraction();
        });
    }

    private function onChange(event : Event) : void 
    {
        cameraScaler(slider.value);
    }

    private function startAutoScaling() : void 
    {
        stopAutoScaling();
        //autoモード開始
        autoScale = new ScaleSliderManipulationThread(cameraScaler, slider);
        autoScale.start();
    }

    private function stopAutoScaling() : void 
    {
        //autoモード終了
        if (autoScale)
            autoScale.interrupt();
        autoScale = null;
    }
    
    override protected function finalize():void
    {
        stopAutoScaling();
        slider.removeEventListener(Event.CHANGE, onChange);
    }
}

/**
 * スケールスライダーを自動で動かす
 */
class ScaleSliderManipulationThread extends Thread 
{
    private var time : int = 0;
    private var duration : int = 300;
    private var begin : Number;
    private var end : Number;
    private var cameraUpdater : Function;
    private var targetScale : Vector.<Number>;
    private var slider : HUISlider;

    public function ScaleSliderManipulationThread(cameraUpdater : Function, slider:HUISlider)
    {
        super();
        
        this.cameraUpdater = cameraUpdater;
        this.slider = slider;
        begin = end = slider.value;
        targetScale = Vector.<Number>([ 10, 65, 70, 70, 80, 90, 90, 100, 110, 110]);
    }

    override protected function run() : void
    {
        if (isInterrupted) return;
        interrupted(function():void{});
        
        next(run);
        
        time++;
        if (time > duration)
        {
            begin = end;
            end = targetScale[int(Math.random() * targetScale.length)];     
            time = 0; 
            
            wait(5000);
            return;         
        }
        
        var value:Number = Quadratic.easeInOut(time, begin, end - begin, duration);
        slider.value = value;
        //minimalcompsのスライダーはsetterで値を変えてもイベントが飛ばないようなので直接ハンドラをたたく
        cameraUpdater(value);
    }
}

/**
 * 2つのDisplayObjectのMatrixを合成し3つ目のDisplayObjectに適用する
 */
class MotionMixerThread extends Thread 
{
    private var sourceA : DisplayObject;
    private var sourceB : DisplayObject;
    private var result : DisplayObject;
    private var mix : Normalizer;
    private var option : Function;

    /**
     * コンストラクタ
     * @param sourceA   合成ソースA
     * @param sourceB   合成ソースB
     * @param result    合成対象
     * @param mix       合成割合オブジェクト
     * @param option    合成後呼び出したいクロージャがあれば指定する
     */
    public function MotionMixerThread(
                        sourceA : DisplayObject, 
                        sourceB : DisplayObject, 
                        result : DisplayObject, 
                        mix : Normalizer, 
                        option:Function
                    )
    {
        super();
        this.sourceA = sourceA;
        this.sourceB = sourceB;
        this.result = result;
        this.mix = mix;
        this.option = option;
    }

    override protected function run() : void
    {
        next(run);
        
        var m : Matrix = new Matrix();
            
        var v : Number = mix.value; 
        var powerB : Number = v;
        var powerA : Number = (1 - powerB);
            
        //=================================
        // rotation
        //=================================
        var v1 : Vector2D = Vector2D.create(MathUtil.degreesToRadians(sourceA.rotation), powerA);
        var v2 : Vector2D = Vector2D.create(MathUtil.degreesToRadians(sourceB.rotation), powerB);
        //=================================
        // scale
        //=================================
        var sx : Number = sourceA.scaleX * powerA + sourceB.scaleX * powerB;
        var sy : Number = sourceA.scaleY * powerA + sourceB.scaleY * powerB; 
        m.scale(sx, sy);
        m.rotate(v1.add(v2).angle);
        m.translate(sourceA.x * powerA + sourceB.x * powerB, sourceA.y * powerA + sourceB.y * powerB);
        result.transform.matrix = m;
        if (option != null)
            option();
    }
}
    
/**
 * 道路を構成するアンカーポイントを生成
 */
class AnchorPointFactoryThread extends Thread 
{
    private static const RADIANS_18DEG : Number = Math.PI / 10;
    private static const RADIANS_90DEG : Number = Math.PI * .5;
    private var startPos :Point;
    private var size : int;
    private var road : RoadModel;

    public function AnchorPointFactoryThread(
                        road : RoadModel, 
                        size:int
                    )
    {
        super();
        this.road = road;
        this.startPos = new Point(size * .5, size * .5);
        this.size = size;
    }

    override protected function run() : void
    {
        //0番目のアンカーポイント
        road.anchorPoints.push(
            AnchorPointHelper.create(
                startPos, 
                new Point(0, -1),
                100
            )
        );
        //1〜n-1番目のアンカーポイント
        var num : int = road.amount;
        while(--num > 0)
        {                   
            road.anchorPoints.push(addNew(road.anchorPoints[road.anchorPoints.length - 1]));
        }
        
        //ハンドルの長さを調整してIDを連番にする
        var prev:AnchorPoint = road.anchorPoints[road.anchorPoints.length - 1];
        var dis:Number;
        var v:Vector.<AnchorPoint> = new Vector.<AnchorPoint>();
        road.anchorPoints.forEach(
            function(ap:AnchorPoint, idx:int, ...param):void
            {
                ap.id = idx;
                dis = Point.distance(prev.point, ap.point) * .6;
                ap.lefthandleLength = dis;
                prev.rightHandleLength = dis;
                prev = ap;
                v.push(ap);
            }
        );
        road.anchorPoints = v;
    }

    /**
     * @param ap          このアンカーポイントから次のアンカーポイントを決定する
     * @param direction   次のアンカーポイントが進むべきベクトル
     * @param handle      次のアンカーポイントの向き
     * @param dis         次のアンカーポイントまでの距離
     */
    private function addNew(ap : AnchorPoint, direction:Number = NaN, handle:Point = null, dis:Number = NaN) : AnchorPoint 
    {
        //=================================
        // next position
        //=================================
        //次に進む距離
        //引数で指定されていればその値を使う.なければランダムな値
        var distance : Number = isNaN(dis) ? MathUtil.random(70, 150) : dis;
        
        //次に進む方向
        //引数で指定されていればその値を使う.
        //なければアンカーポイントのハンドルの方向に+-90度のランダムな値を加算した値
        var hDirection:Number = ap.vector.angle + RADIANS_90DEG;
        var random:Number = MathUtil.random(-RADIANS_90DEG, RADIANS_90DEG);
        var rad:Number = (isNaN(direction)) ? hDirection + random : direction; 
        
        //次の位置
        var next:Point = 
            ap.point.add(
                    new Point(
                        Math.cos(rad) * distance, 
                        Math.sin(rad) * distance)
                    );
                    
        //=================================
        // 境界チェック
        // 次のアンカーポイントが画面外の場合、次のアンカーポイントは
        // 現在のアンカーポイントのハンドルの方向を90度回転した方向に置く。
        // また法線の向きは現在のアンカーポイントの法線を180度回転した角度。
        //=================================
        if (next.x < 50 || next.x > size || next.y < 50 || next.y > size)
        {
            //アンカーポイントのハンドルの方向を90度回転
            hDirection += RADIANS_90DEG;
            //アンカーポイントの法線を180度回転
            var ap2:AnchorPoint = ap.clone();
            ap2.vector.angle += Math.PI; 
            return addNew(ap2, hDirection, ap2.vector.coordinate, distance*.5);
        }                
            
        //=================================
        // 次のハンドル
        //=================================
        //向き
        var h : Point = (handle) ? handle :
        Point.polar(1, ap.vector.angle + MathUtil.random(-RADIANS_18DEG, RADIANS_18DEG));
        
        return AnchorPointHelper.create(next, h, 1);
    }
}

/**
 * 車のモデルを生成
 */
class CarFactory 
{
    public static function create(amount : int, road : RoadModel) : Vector.<CarModel> 
    {
        var cars : Vector.<CarModel> = new Vector.<CarModel>();
        for (var i : int = 0;i < amount;i++) 
        {
            //最初の1台はプライマリー.この車をカメラが追いかける
            var primary : Boolean = i == 0;
            var speed : Number = (primary) ? 5 : Math.random() * 5 + 1;
            var direction: int = (i < amount * .5) ? 
                CarModel.CLOCKWISE : CarModel.OPPOSITE;
            
            cars.push(new CarModel(speed, road, primary, direction));
        }
        return cars;
    }
}

/**
 * 車のビューのコントローラ
 */
class CarControlerThread extends Thread 
{
    private var camera : CameraRect;
    private var models : Vector.<CarModel>;
    private var carViews : Dictionary;

    public function CarControlerThread(
                        models : Vector.<CarModel>,
                        cameraRect : CameraRect,
                        carViews : Dictionary
                    )
    {
        super();

        this.models = models;
        this.carViews = carViews;
        this.camera = cameraRect;
    }

    override protected function run() : void
    {
        if (isInterrupted)
           return;
           
        next(run);
        
        models.forEach(function(model:CarModel, ...param):void
        {
            var car : Car = carViews[model]; 
            //=================================
            // rotation
            //=================================
            var r : Number = model.rotation - camera.rotation;
            car.rotation = r;
            //=================================
            // scale
            //=================================
            var s : Number = 1 / camera.scaleX;
            car.scaleX = car.scaleY = s*.13;
            //=================================
            // position
            //=================================
            //車の位置
            var cp:Point = model.point;
            
            //車の位置をカメラ座標系に座標変換
            cp = camera.getPosition(cp).add(camera.registration);

            //カメラ外なら表示しない
            if (cp.x > camera.cameraWidth || cp.y > camera.cameraHeight || cp.x < 0 || cp.y < 0)
            {
                car.visible = false;
                return;
            }
            
            //中央帯の真上を走らないようにちょっとずらす
            var r2 : Number = MathUtil.degreesToRadians(r + 90);
            var safeDrive:Number = model.safeDrive * s;
            var ax:Number = Math.cos(r2) * safeDrive; 
            var ay:Number = Math.sin(r2) * safeDrive;
            
            //=================================
            // 車のビューをアップデート
            //=================================
            car.visible = true;
            car.x = cp.x + ax;
            car.y = cp.y + ay;
            
            //=================================
            // shadow
            //=================================
            car.updateShadow(-camera.rotation + 45);
        });
    }
}

/**
 * 道路のレンダリング
 */
class RenderBezierThread extends Thread 
{
    private var canvas : Canvas;
    private var style : RoadStyle;
    private var camera : CameraRect;
    private var renderer : BezierRenderer;
    private var assembler : AnchorPointAssembler;
    private var road : RoadModel;

    public function RenderBezierThread(
                        camera:CameraRect, 
                        renderer:BezierRenderer, 
                        canvas:Canvas, 
                        road:RoadModel,
                        style:RoadStyle
                    )
    {
        super();
        this.camera = camera;
        this.canvas = canvas;
        this.renderer = renderer;
        this.road = road;
        this.style = style;
    }

    override protected function run() : void
    {
        assembler = new AnchorPointAssembler(road.anchorPoints, 5);      
        next(render);       
    }

    private function render() : void 
    {
        if (isInterrupted) return;
        //=================================
        // カメラにレンダリングされるアンカーポイントを取得
        //=================================
        var bezierSet:Vector.<Vector.<AnchorPoint>> = assembler.assembleAnchorPoint(camera.sides);
        //=================================
        // アンカーポイントをカメラの座標系に変換
        //=================================
        //Vector.map()が使えないので一時変数を使う
        var v2:Vector.<Vector.<AnchorPoint>> = new Vector.<Vector.<AnchorPoint>>();
        bezierSet.forEach(
            function(bSet:Vector.<AnchorPoint>, ...param):void
            {
                var v:Vector.<AnchorPoint> = new Vector.<AnchorPoint>(); 
                bSet.forEach(
                    function(ap:AnchorPoint, ...param):void
                    {
                        v.push(mapTo(ap));
                    });
                v2.push(v);
            }
        );
        bezierSet = v2;
        //=================================
        // レンダリング
        //=================================
        //スタイルのスケールを決定
        style.scale = 1 / camera.scaleX;
        canvas.canvas.graphics.clear();
        
        var path:GraphicsPath = 
            renderer.getGraphicsPathFromMultipleBezierCurve(bezierSet, false);
        
        canvas.canvas.graphics.drawGraphicsData(
            style.getStrokes(path)
        );

        //=================================
        // background of canvas
        //=================================
        canvas.gradientAngle = -MathUtil.degreesToRadians(camera.rotation+45);
        
        next(render);
    }

    private function mapTo(ap : AnchorPoint) : AnchorPoint 
    {
        var rad:Number = MathUtil.degreesToRadians(-camera.rotation);
        var scale:Number = 1 / camera.scaleX;
        
        //カメラ座標系に座標変換
        var p:Point = camera.getPosition(ap.point);
        
        var copy : AnchorPoint = ap.clone();
        copy.x = p.x;
        copy.y = p.y;   
        copy.vector.angle += rad;
        copy.lefthandleLength *= scale ;
        copy.rightHandleLength *= scale ;
        copy.id = ap.id;
        
        return copy;
    }
}


//--------------------------------------------------------------------------
//
//  Geom Data Types and Utils
//
//--------------------------------------------------------------------------

/**
 * イテレータのインターフェイス
 */
interface IIterator 
{
    /**
     * まだイテレートする対象があるかどうかを返します.
     */
    function hasNext():Boolean;

    /**
     * イテレーションの次の対象を返します.
     */
    function next():*;

    /**
     * イテレータの現在の位置を返します.
     */
    function get position():int;
}

/**
 * Vector用のイテレータ
 */
class VectorIterator implements IIterator
{
    /**
     * コンストラクタ.
     * @param vector 走査したいVector
     */
    public function VectorIterator(vector:*) 
    {
        _position = 0;
        myVector = vector;
    }   

    /**
     * @private
     */
    protected var myVector:Vector.<*>;

    /**
     * @private
     */
    protected var _position:Number;

    /**
     * @copy IIterator#position
     */
    public function get position():int
    {
        return _position;
    }

    /**
     * まだイテレートする対象があるかどうかを返します.
     */
    public function hasNext():Boolean
    {
        return _position < myVector.length;
    }   

    /**
     * イテレーションの次の対象を返します.
     */
    public function next():*
    {
        return myVector[_position ++];
    }
    
    public function clone():VectorIterator
    {
        return new VectorIterator(myVector.concat());
    }
}
    
class MathUtil
{
    /**
     * @private
     */
    private static const PI:Number = Math.PI;
    
    /**
     * 渡された任意のラジアンを角度に変換します.
     * 
     * @param radians　角度に変換したいラジアンを渡します.
     * @return ラジアンから角度に変換された値を返します.
     */
    public static function radiansToDegrees(radians:Number):Number 
    {
        return radians / PI * 180;
    }

    /**
     * 渡された任意の角度をラジアンに変換します.
     * 
     * @param degrees　ラジアンに変換したい角度を渡します.
     * @return 角度からラジアンに変換された値を返します.
     */
    public static function degreesToRadians(degrees:Number):Number 
    {
        return degrees * PI / 180;
    }

    /**
     * 任意の範囲からランダムな数値を返す
     */
    public static function random(min:Number, max:Number):Number
    {
        return Math.random() * (max - min) + min;
    }
}

/**
 * 2次元ベクトルオブジェクト
 */
class Vector2D 
{
    //=================================
    // 誤差吸収用テーブル
    //=================================
    private static const DEGREES_30 : Number = 0.5235987755982988;
    private static const DEGREES_45 : Number = 0.7853981633974483;
    private static const DEGREES_90 : Number = Math.PI * .5;
    private static const DEGREES_135 : Number = 2.356194490192345;
    private static const DEGREES_150 : Number= 2.6179938779914944;
    private static const SQRT_2 : Number = 1.4142135623730951;
    private static const SQRT_3 : Number = 1.7320508075688772;
    private static var tableX : Dictionary;
    private static var tableY : Dictionary;

    /**
     * 2次元ベクトルを生成します.
     * <p>
     * Vecor2Dインスタンスの生成は、コンストラクタを使用する以外に
     * 任意のPointから生成できるVector2D.createFromPoint()があります.
     * Vector2D.createFromPoint()の方が高速にインスタンスを生成できます.</p>
     * @param theta ベクトルの向きをラジアン度で渡します.
     * @param velocity  ベクトルの強さ.
     */
    public static function create(angle : Number, velocity : Number = 1) : Vector2D 
    {
        var v : Vector2D = new Vector2D();
        v._angle = angle;
        v._velocity = velocity;
        v._vx = NaN;
        v._vy = NaN;
        return v;
    }
    /**
     * 任意の点から2次元ベクトルを生成します.
     * 引数として渡す点はベクトルの終点、またはベクトルの始点と終点です.
     * 終点のみを渡す場合は始点は座標（0,0）となります。
     * @param p1    2次元ベクトルの終点、または始点
     * @param p2    2次元ベクトルの終点
     * @return      2次元ベクトル
     */
    public static function createFromPoint(p1:Point, p2:Point = null):Vector2D
    {
        var v:Vector2D = new Vector2D();   
        if (p2)
        {
            v._vx = p2.x - p1.x;    
            v._vy = p2.y - p1.y;    
        }
        else
        {
            v._vx = p1.x;
            v._vy = p1.y;
        }
        v._velocity = NaN;
        v._angle = NaN;
        return v;
    }

    /**
     * コンストラクタ.
     * 
     * <p>ゼロ2次元ベクトルを生成します.<br/>
     * 方向と強さからベクトルを生成する場合はVector2D.create()を、
     * 任意のPointから生成する場合はVector2D.createFromPoint()を使用します.</p>
     */
    public function Vector2D() 
    {
        //=================================
        // Math.cos(_angle) * _velocityの計算時に誤差が出てしまうので
        // 特定のangle,verocity時に限りテーブルを使ってvx,vyを求める.
        //=================================
        //テーブルがなければ作成
        if (!tableX)
            internalInit();
    }

    private function internalInit() : void 
    {
        tableX = new Dictionary(true);
        tableX[-DEGREES_30] = new Dictionary(true);
        tableX[-DEGREES_45] = new Dictionary(true);
        tableX[-DEGREES_150] = new Dictionary(true);
        tableX[DEGREES_30] = new Dictionary(true);
        tableX[DEGREES_45] = new Dictionary(true);
        tableX[Math.PI] = new Dictionary(true);
        tableX[DEGREES_150] = new Dictionary(true);
        tableX[DEGREES_90] = 0;
        tableX[-DEGREES_90] = 0;
            
        tableX[-DEGREES_30][2] = SQRT_3;
        tableX[-DEGREES_45][SQRT_2] = 1;
        tableX[-DEGREES_150][2] = -SQRT_3;
        tableX[DEGREES_30][2] = SQRT_3;
        tableX[DEGREES_45][SQRT_2] = 1;
        tableX[Math.PI][SQRT_2] = -SQRT_2;
        tableX[DEGREES_150][2] = -SQRT_3;
            
        tableY = new Dictionary(true);
        tableY[-DEGREES_30] = new Dictionary(true);
        tableY[-DEGREES_45] = new Dictionary(true);
        tableY[-DEGREES_90] = new Dictionary(true);
        tableY[-DEGREES_135] = new Dictionary(true);
        tableY[-DEGREES_150] = new Dictionary(true);
        tableY[DEGREES_30] = new Dictionary(true);
        tableY[DEGREES_45] = new Dictionary(true);
        tableY[DEGREES_90] = new Dictionary(true);
        tableY[DEGREES_135] = new Dictionary(true);
        tableY[DEGREES_150] = new Dictionary(true);
            
        tableY[-DEGREES_30][2] = -1;
        tableY[-DEGREES_45][SQRT_2] = -1;
        tableY[-DEGREES_90][SQRT_2] = -SQRT_2;
        tableY[-DEGREES_135][SQRT_2] = -1;
        tableY[-DEGREES_150][2] = -1;
        tableY[DEGREES_30][2] = 1;
        tableY[DEGREES_45][SQRT_2] = 1;
        tableY[DEGREES_90][SQRT_2] = SQRT_2;
        tableY[DEGREES_135][SQRT_2] = 1;
        tableY[DEGREES_150][2] = 1;
        tableY[Math.PI] = 0;
        tableY[-Math.PI] = 0;
    }

    /**
     * 2次元ベクトルのベロシティです
     * このプロパティを変更するとvx, vyプロパティも変更されます.
     */
    private var _velocity:Number = 0;
    public function get velocity():Number
    {
        if (isNaN(_velocity))
            validate2();
        return _velocity;
    }
    public function set velocity(value:Number):void
    {
        _velocity = value;
        _vx = NaN;
        _vy = NaN;
    }

    /**
     * 2次元ベクトルの角度です
     * このプロパティを変更するとvx, vyプロパティも変更されます.
     */
    private var _angle:Number = 0;
    public function get angle():Number
    {
        if (isNaN(_angle))
           validate2();
        return _angle;
    }
    public function set angle(value:Number):void
    {
        _angle = value;
        _vx = NaN;
        _vy = NaN;
    }

    /**
     * 終点のデカルト座標を返します
     * 戻り値に特にPointを必要としない場合は
     * vx, vyプロパティにアクセスする方が多分わずかに高速です.
     */
    private var _coordinate:Point;
    public function get coordinate():Point
    {
        _coordinate = new Point(vx, vy);
        return _coordinate;
    }
    
    /**
     * 2次元ベクトルのx成分です
     */
    private var _vx : Number = 0;
    public function get vx() : Number
    {
        if (isNaN(_vx))
           validate();
        return _vx;
    }
    public function set vx(value : Number) : void
    {
        _vx = value;
        _velocity = NaN;
        _angle = NaN;
    }

    /**
     * 2次元ベクトルのy成分です
     */
    private var _vy : Number = 0;
    public function get vy() : Number
    {
        if (isNaN(_vy))
           validate();
        return _vy;
    }
    public function set vy(value : Number) : void
    {
        _vy = value;
        _velocity = NaN;
        _angle = NaN;
    }
    
    //=================================
    // operations
    //=================================
    /**
     * ベクトルの加算.
     */
    public function add(v:Vector2D):Vector2D
    {
        return createFromPoint(new Point(vx + v.vx, vy + v.vy));
    }
    /**
     * 2つのベクトルのなす角を求める
     */
    public function getRadiansWith(v : Vector2D) : Number
    {
        var cos : Number = normalize().dotProduct(v.normalize()); 
        return Math.acos(cos);
    }
    /**
     * 2つのベクトルのなす角を求める（方向付き）
     */
    public function getRadiansWith2(v : Vector2D) : Number 
    {
        var n:Vector2D = normalize();
        return Math.atan2(n.crossProduct(v), n.dotProduct(v));
    }
    /**
     * ベクトルの内積を返します
     */
    public function dotProduct(v:Vector2D):Number
    {
        return vx * v.vx + vy * v.vy;
    }
    /**
     * ベクトルの外積を返します
     */
    public function crossProduct(v : Vector2D) : Number 
    {
        return vx * v.vy - v.vx * vy;
    }
    /**
     * 任意の2次元ベクトルと等しいかどうかを返します
     */
    public function equals(v:Vector2D):Boolean
    {
        return vx == v.vx && vy == v.vy;
    }
    /**
     * 2次元ベクトルを正規化した新しいベクトルを返します.
     */
    public function normalize():Vector2D
    {
        return Vector2D.create(angle);
    }
    /**
     * 2次元ベクトルの複製を返します
     */
    public function clone():Vector2D
    {
        return Vector2D.createFromPoint(new Point(vx, vy));
    }
    /**
     * 2次元ベクトルを回転します
     * このメソッドはvx, vy, angleプロパティを変更します
     * @param value 現在の角度に加えるラジアン度
     */
    public function rotate(value:Number):Vector2D
    {
        angle += value;
        validate();
        return this;
    }
    /**
     * angleとverocityからvx,vyを計算する
     * テーブルがある場合はテーブルの値を使用する
     */
    private function validate():void
    {
        var v:Number = _velocity;
        var a:Number = _angle;
        var n:Number = Number(tableX[a]);
        if(isNaN(n))
        {
            if (tableX[a] is Dictionary)
            {
                n = Number(tableX[a][v]);
                if (isNaN(n))
                    _vx = Math.cos(a) * v;
                else
                    _vx = n;
            }
            else
            {
                _vx = Math.cos(a) * v;
            }
        }
        else
        {
            _vx = n;
        }
        
        n = Number(tableY[a]);
        if(isNaN(n))
        {
            if (tableY[a] is Dictionary)
            {
                n = Number(tableY[a][v]);
                if (isNaN(n))
                    _vy = Math.sin(a) * v;
                else
                    _vy = n;
            }
            else
            {
                _vy = Math.sin(a) * v;
            }
        }
        else
        {
            _vy = n;
        }
    }
    //=================================
    // calcuration for angle and verocity
    //=================================
    private function validate2() : void 
    {
        _velocity = Math.sqrt(_vx * _vx + _vy * _vy);
        _angle = Math.atan2(_vy, _vx);
    }
}

/**
 * 線分を表現するクラス
 * 線分は位置をもつ2次元ベクトルとして定義されます.
 */
class Segment 
{
    /**
     * 2点から線分オグジェクトを生成します.
     * 線分オブジェクトは方向をもちます.第1匹数はベクトルの始点、第2匹数はベクトルの終点となります
     * @param p1    線分の両端の一点
     * @param p2    線分の両端の点でp1ではない点
     * @return      ２点を結ぶ線分オブジェクト
     */
    public static function createFromPoint(p1 : Point, p2 : Point) : Segment 
    {
        return Segment.createFromVector2D(
                    p1,
                    Vector2D.createFromPoint(p1, p2)
                );
    }
    /**
     * 開始点と2次元ベクトルから線分を生成します.
     * @param point     線分の始点
     * @param vector    線分のベクトル
     * @return          任意の始点、ベクトルをもつ線分オブジェクト
     */
    public static function createFromVector2D(
                                point : Point, 
                                vector : Vector2D
                            ) : Segment
    {
        var sg:Segment = new Segment();
        sg._vector = vector.clone();
        sg._begin = point.clone();
        sg._end = null;
        return sg;
    }
    public var id : Number;

    /**
     * 線分の始点です
     * このプロパティを変更するとendプロパティも変更されます.
     */
    private var _begin:Point = null;
    public function get begin():Point
    {
        return _begin;
    }
    public function set begin(point:Point):void
    {
        _begin = point;
        _end = null;
    }

    /**
     * 線分の終点です
     * このプロパティを変更によって線分の角度が変わるとangle, vectorプロパティが変更されます.
     */
    private var _end:Point = null;
    public function get end() : Point
    {
        if (!_end)
         _end = validate(_begin, _vector);
        return _end;
    }
    public function set end(point:Point):void
    {
        _end = point;
        _vector = Vector2D.createFromPoint(_begin, point);
    }

    /**
     * 線分の方向と長さを表す2次元ベクトルです
     * このプロパティを変更によって線分のベクトルが変わるとend, angleプロパティが変更されます.
     */
    private var _vector:Vector2D = null;
    public function get vector():Vector2D
    {
        return _vector;
    }
    public function set vector(value:Vector2D):void
    {
        _vector = value;
        _end = null;
    }

    /**
     * 線分の角度
     * このプロパティを変更するとend, vectorプロパティも変更されます.
     */
    public function get angle():Number
    {
        return _vector.angle;
    }
    public function set angle(value:Number):void
    {
        _vector.angle = value;
        _end = null;
    }
    
    /**
     * 線分の長さ
     * このプロパティを変更するとend, vectorプロパティも変更されます.
     */
    public function get length():Number
    {
        return _vector.velocity;
    }
    public function set length(value:Number):void
    {
        _vector.velocity = value;
        _end = null;
    }
    
    public function equals(s:Segment):Boolean
    {
        return _begin.equals(s._begin) && end.equals(s.end);
    }

    public function clone():Segment
    {
        return Segment.createFromVector2D(_begin, _vector);
    }
    
    /**
     * 線分を回転します
     * このメソッドはend, angleプロパティを変更します
     * @param value 現在の角度に加えるラジアン度
     */
    public function rotate(angle:Number):void
    {
        _vector.rotate(angle);
        _end = null;
    }
    
    /**
     * 線分を移動させます
     * このメソッドはbegin, endプロパティを変更します.
     */
    public function translate(x : Number, y : Number) : void 
    {
        _begin.x += x;
        _begin.y += y;
        _end = null;
    }
    
    /**
     * 線分を対角線にもつ矩形を返します.
     * @param segment   対角線となるSegment
     * @return          線分を対角線にもつ矩形
     */
    public static function getBounce(segment:Segment) : Rectangle 
    {
        var p1:Point = segment.begin;
        var p2:Point = segment.end;
        return new Rectangle(
                    Math.min(p1.x, p2.x), 
                    Math.min(p1.y, p2.y), 
                    Math.abs(p1.x - p2.x), 
                    Math.abs(p1.y - p2.y));
    }
    
    //=================================
    // collision
    //=================================
    /**
     * 任意の線分と交差しているかどうかを返します.
     */
    public function isCrossing(sg : Segment) : Boolean 
    {
        var v : Vector2D = Vector2D.createFromPoint(_begin, sg._begin);
        var v1 : Vector2D = _vector; 
        var v2 : Vector2D = sg._vector; 
        var v1Xv2 : Number = v1.crossProduct(v2);

        // 平行
        if ( v1Xv2 == 0 ) 
            return false;
        
        var t1 : Number = v.crossProduct(v2) / v1Xv2;
        var t2 : Number = v.crossProduct(v1) / v1Xv2;
        var eps : Number = 0.00001;
        
        if ( t1 + eps < 0 || t1 - eps > 1 || t2 + eps < 0 || t2 - eps > 1 ) 
            return false;
        else
            return true;
    }

    /**
     * ある線分に対し任意の点が線分の右側にあるかどうかを返します.
     * 多角形内に任意の点が含まれるかどうかを調べる時に使います.
     */
    public function isRightSide(point : Point) : Boolean 
    {
        var vx1 : Number = _begin.x;
        var vy1 : Number = _begin.y;
        var vx2 : Number = end.x;
        var vy2 : Number = _end.y;
        return ((vx2 - vx1) * (point.y - vy1) - (point.x - vx1) * (vy2 - vy1)) > 0; 
    }
    
    /**
     * @private
     * 始点とベクトルから終点を求める
     */        
    private static function validate(point:Point, vector:Vector2D):Point
    {
        return new Point(point.x + vector.vx, point.y + vector.vy);
    }
}

/**
 * アンカーポイント
 */
class AnchorPoint
{
    private static var _sid : int = 0;

    public function AnchorPoint(point:Point, left:Point, right:Point)
    {
        this.point = point;
        _leftHandle = left;
        _rightHandle = right;
        _leftHandleLength = Point.distance(_point, _leftHandle);
        _rightHandleLength = Point.distance(_point, _rightHandle);
        id = _sid ++;
        
        //デフォルトの向きは、ハンドルを結ぶ直線に直行する方向.
        _vector = 
            Vector2D.createFromPoint(_leftHandle, _rightHandle)
                .rotate(-MathUtil.degreesToRadians(90));
    }
    
    public var id : int;
    
    private var _point:Point;

    public function get point():Point
    {
        return _point;
    }
    
    public function set point(point : Point) : void
    {
        _point = point;
        _x = point.x;
        _y = point.y;
    }

    private var _x:Number;

    public function get x():Number
    {
        return _x;
    }

    public function set x(value:Number):void
    {
        _x = value;
        _point.x = value;
        updateHandle();
    }

    private var _y:Number;

    public function get y():Number
    {
        return _y;
    }

    public function set y(value:Number):void
    {
        _y = value;
        _point.y = value;
        updateHandle();
    }

    private var _leftHandleLength:Number;

    public function get lefthandleLength():Number
    {
        return _leftHandleLength;
    }

    public function set lefthandleLength(value:Number):void
    {
        _leftHandleLength = value;
        updateHandle();
    }

    private var _rightHandleLength:Number;

    public function get rightHandleLength():Number
    {
        return _rightHandleLength;
    }

    public function set rightHandleLength(value:Number):void
    {
        _rightHandleLength = value;
        updateHandle();
    }

    private var _leftHandle:Point;

    public function get leftHandle():Point
    {
        return _leftHandle;
    }

    private var _rightHandle:Point;

    public function get rightHandle():Point
    {
        return _rightHandle;
    }

    private var _vector:Vector2D;

    public function get vector():Vector2D
    {
        return _vector;
    }

    public function set vector(value:Vector2D):void
    {
        _vector = value;
        updateHandle();
    }

    public function clone():AnchorPoint
    {
        return new AnchorPoint(
                        _point.clone(),
                        _leftHandle.clone(),
                        _rightHandle.clone()
                    );
    }

    private function updateHandle():void
    {
        _leftHandle = 
            AnchorPointHelper.getLeftHandle(
                _vector.angle,
                _point, _leftHandleLength
            );
            
        _rightHandle = 
            AnchorPointHelper.getRightHandle(
                _vector.angle,
                _point,
                _rightHandleLength);
    }

    public function rotate(rad:Number):void
    {
        //180度以上の回転はハンドルの左右が入れ替わる
        if (rad%(Math.PI*2) >= Math.PI)
        {
            var l:Number = _leftHandleLength;
            var r:Number = _rightHandleLength;
            _leftHandleLength = r;
            _rightHandleLength = l;
        }
        _vector.rotate(rad);
        updateHandle();
    }
}

class AnchorPointHelper 
{
    public static function create(
                                registration:Point,
                                vec:Point,
                                handleLength:Number
                            ):AnchorPoint
    {
        //ベクトルの角度
        var rad:Number = Math.atan2(vec.y, vec.x);
        //左ハンドルの位置
        var left:Point = getLeftHandle(rad, registration, handleLength);
        //右ハンドルの位置
        var right:Point = getRightHandle(rad, registration, handleLength);
        return new AnchorPoint(registration, left, right);
    }

    public static function getRightHandle(
                                rad:Number,
                                registlation:Point, 
                                handleLength:Number
                            ):Point
    {
        rad += MathUtil.degreesToRadians(90);
        return new Point(
                Math.cos(rad) * handleLength + registlation.x, 
                Math.sin(rad) * handleLength + registlation.y
            );
    }

    public static function getLeftHandle(
                                rad:Number,
                                registlation:Point,
                                handleLength:Number
                            ):Point
    {
        rad += MathUtil.degreesToRadians(-90);
        return new Point(
                    Math.cos(rad) * handleLength + registlation.x,
                    Math.sin(rad) * handleLength + registlation.y);
    }

    /**
     * 渡されたAnchorPointのセットを逆順にして新しいセットを返します.
     */
    public static function invert(anchorPoints : Vector.<AnchorPoint>) : Vector.<AnchorPoint> 
    {
        var v:Vector.<AnchorPoint>  = 
            anchorPoints.concat().reverse();
            
        //Vector.mapができないので一時変数を使う
        var v2:Vector.<AnchorPoint> = new Vector.<AnchorPoint>();
        v.forEach(
            function(ap:AnchorPoint, ...param):void
            {
                var ap2:AnchorPoint = ap.clone();
                ap2.rotate(Math.PI);
                v2.push(ap2);
            }
        );
        return v2;
    }
}

/**
 * 3次ベジェ曲線
 */
class BezierSegment 
{
    public var a : Point;
    public var b : Point;
    public var c : Point;
    public var d : Point;
    private var _length : Number = NaN;

    public function BezierSegment(a : Point,b : Point,c : Point,d : Point) 
    {
        this.d = d;
        this.c = c;
        this.b = b;
        this.a = a;
    }

    public function getValue(t : Number) : Point 
    {
        if (t < 0) t = 0;
        if (t > 1) t = 1;
        var t2:Number = 1 - t;
        var tp3 : Number  = t * t * t;
        var tp2 : Number  = t * t;
        var t2p3 : Number = t2 * t2 * t2;
        var t2p2 : Number = t2 * t2;
        return new Point(
                t2p3*a.x + 3*t2p2*t*b.x + 3*t2*tp2*c.x + tp3*d.x,
                t2p3*a.y + 3*t2p2*t*b.y + 3*t2*tp2*c.y + tp3*d.y);
    }

    public function get length() : Number 
    {
        if (isNaN(_length))
        {
            var l : Number = 0;
            var pre : Point = a;
            var cur : Point;
            var sensitive : Number = .01;
            for (var t : Number = sensitive;t <= 1;t += sensitive) 
            {
                cur = getValue(t);
                var dx : Number = pre.x - cur.x;
                var dy : Number = pre.y - cur.y;
                l += Math.sqrt(dx * dx + dy * dy);
                pre = cur;
            }
            _length = l;
        }
        return _length;
    }
}

class BezierHelper 
{
    /**
     * 2点のアンカーポイントをつなぐベジェ曲線を返します
     */
    public static function getBezierFromAnchorPair(
                                ap1 : AnchorPoint, 
                                ap2 : AnchorPoint, 
                                invertDrawing:Boolean = false
                            ) : BezierSegment 
    {
        var v:Vector.<AnchorPoint> = Vector.<AnchorPoint>([ap1, ap2]);
        return BezierSegment(
                    getBezierFromAnchors(v, false, invertDrawing)[0]
               );
    }

    /**
     * アンカーポイントのセットをベジェ曲線のセットに変換します
     * @param anchorPoints      ベジェ曲線を構成するアンカーポイントのセットです
     * @param isClosedShape     アンカーポイントのセットが閉じたシェイプを定義しているかどうか
     * @param invertDrawing     アンカーポイントをつなぐ順番
     *                          アンカーポイントのセットはデフォルトで法線の向きに対して時計回りにつながれます。
     *                          これを反時計回りでつなぐ場合はtrueを渡します。
     * @param bezierToAnchor    この引数に辞書を渡すと、その辞書はベジェ曲線をキーに両端のアンカーポイントを返す辞書になります.
     */
    public static function getBezierFromAnchors(
                                anchorPoints : Vector.<AnchorPoint>,
                                isClosedShape:Boolean = true,
                                invertDrawing:Boolean = false,
                                bezierToAnchor:Dictionary = null
                            ) : Vector.<BezierSegment> 
    {
        if (anchorPoints.length <= 1)
            throw new Error("ベジェ曲線の生成には少なくとも2つのAnchorPointが必要です");
            
        //反時計回りに描画する場合はアンカーポイントのセットを逆順にする
        if (invertDrawing)
        {
            var top:AnchorPoint = anchorPoints.shift();
            anchorPoints.reverse();
            anchorPoints = Vector.<AnchorPoint>([top]).concat(anchorPoints);
        }
        if (isClosedShape)
            anchorPoints.push(anchorPoints[0]);
            
        var pre:AnchorPoint;
        
        var v2:Vector.<BezierSegment> = new Vector.<BezierSegment>();
        for each (var anchorPoint:AnchorPoint in anchorPoints) 
        {
            if (pre)
            {
                var a : Point = pre.point;
                var b : Point = pre.rightHandle;
                var c : Point = anchorPoint.leftHandle;
                var d : Point = anchorPoint.point;
                var bezier : BezierSegment = new BezierSegment(a, b, c, d);
                if (bezierToAnchor)
                    bezierToAnchor[bezier] = [pre, anchorPoint];
            }
            pre = anchorPoint;
            v2.push(bezier); 
        }
        v2 = v2.slice(1);
       return v2;
    }
}