package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.StatusEvent;
    import flash.geom.Point;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.text.TextField;
    [SWF(width = 465, height = 465, frameRate = 30)]
    
    /**
     * パーティクルフィルタを使って青い物体と赤い物体を追跡し、2つの物体の画像中の角度を表示します
     * @author ton
     */
    public class Main extends Sprite {
        private var redParticleFilter:ImageParticleFilter;
        private var blueParticleFilter:ImageParticleFilter;
        
        private var video:Video;
        private var bmd:BitmapData;
        private var bmp:Bitmap;
        
        private var redCircle:Shape;
        private var blueCircle:Shape;
        
        private var canvas:Shape;
        private var container:Sprite;
        private var tf:TextField;
        
        public function Main():void {
            if (stage)
                init();
            else
                addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            container = new Sprite();
            addChild(container);
            
            var cam:Camera = Camera.getCamera();
            cam.addEventListener(StatusEvent.STATUS, onStatus);
            video = new Video();
            video.attachCamera(cam);
            
            container.scaleX = container.scaleY = stage.stageWidth / video.width;
            
            bmd = new BitmapData(video.width, video.height);
            bmp = new Bitmap(bmd);
            container.addChild(bmp);
            
            canvas = new Shape();
            container.addChild(canvas);
            
            var red:RedChecker = new RedChecker();
            redParticleFilter = new ImageParticleFilter(bmd, red);
            redCircle = makeCircle(0xff3333);
            container.addChild(redCircle);
            
            var blue:BlueChecker = new BlueChecker();
            blueParticleFilter = new ImageParticleFilter(bmd, blue);
            blueCircle = makeCircle(0x0077ff);
            container.addChild(blueCircle);
            
            tf = new TextField();
            tf.textColor = 0x00ff00;
            tf.scaleX = tf.scaleY = 2;
            container.addChild(tf);
        }
        
        /**
         * カメラの状態を監視します。
         * カメラへのアクセスが許可されるとパーティクフフィルタの更新が始まります。
         * @param    e
         */
        private function onStatus(e:StatusEvent):void {
            if (e.code == "Camera.Unmuted") {
                addEventListener(Event.ENTER_FRAME, update);
            }
        }
        
        /**
         * 円を生成します。
         */
        private function makeCircle(color:uint):Shape {
            var circle:Shape = new Shape();
            circle.graphics.beginFill(0xffffff);
            circle.graphics.drawCircle(0, 0, 5);
            circle.graphics.beginFill(color);
            circle.graphics.drawCircle(0, 0, 3);
            circle.graphics.endFill();
            return circle;
        }
        
        /**
         * 毎フレーム更新用メソッド
         */
        private function update(e:Event):void {
            bmd.draw(video);
            redParticleFilter.update();
            blueParticleFilter.update();
            
            var p:ImageParticle = redParticleFilter.resultParticle as ImageParticle;
            redCircle.x = p.x;
            redCircle.y = p.y;
            
            p = blueParticleFilter.resultParticle as ImageParticle;
            blueCircle.x = p.x;
            blueCircle.y = p.y;
            
            bmd.lock();
            for (var i:int = 0; i < redParticleFilter.particleCount; i++) {
                p = redParticleFilter.particles[i] as ImageParticle;
                bmd.setPixel(p.x, p.y, 0xff0000);
                
                p = blueParticleFilter.particles[i] as ImageParticle;
                bmd.setPixel(p.x, p.y, 0xff0000);
            }
            bmd.unlock();
            
            var cg:Graphics = canvas.graphics;
            cg.clear();
            cg.lineStyle(2, 0x00ff00);
            cg.moveTo(0, blueCircle.y);
            cg.lineTo(bmd.width, blueCircle.y);
            cg.moveTo(blueCircle.x, 0);
            cg.lineTo(blueCircle.x, bmd.height);
            
            cg.moveTo(blueCircle.x, blueCircle.y);
            cg.lineTo(redCircle.x, redCircle.y);
            
            var d:Number = dist(blueCircle.x, blueCircle.y, redCircle.x, redCircle.y);
            var angle:Number = angle(blueCircle.x, blueCircle.y, redCircle.x, redCircle.y);
            arcTo(cg, blueCircle.x, blueCircle.y, d / 2, 0, angle);
            
            tf.text = String(int(angle * 180 / Math.PI)) + "°";
        }
        
        /**
         * 2点間の距離を返します。
         */
        private function dist(x1:int, y1:int, x2:int, y2:int):Number {
            return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
        }
        
        /**
         * 2点間の角度を返します。
         */
        private function angle(x1:int, y1:int, x2:int, y2:int):Number {
            return Math.atan2(y2 - y1, x2 - x1);
        }
        
        /**
         * 弧を描くメソッド
         * (参考) http://www.fumiononaka.com/TechNotes/Flash/FN0506002.html
         */
        private function arcTo(g:Graphics, x:Number, y:Number, radius:Number, startAngle:Number, endAngle:Number):void {
            var clockwise:Boolean = startAngle < endAngle;
            
            g.moveTo(x + radius * Math.cos(startAngle), y + radius * Math.sin(startAngle));
            
            while (clockwise && startAngle < endAngle || !clockwise && startAngle > endAngle) {
                var nextAngle:Number = clockwise ? Math.min(endAngle, startAngle + Math.PI / 4) : Math.max(endAngle, startAngle - Math.PI / 4);
                
                var nextPos:Point = new Point(Math.cos(nextAngle) * radius, Math.sin(nextAngle) * radius);
                
                var controlPos:Point = new Point(radius * Math.tan((nextAngle - startAngle) / 2) * Math.cos(nextAngle - Math.PI / 2), radius * Math.tan((nextAngle - startAngle) / 2) * Math.sin(nextAngle - Math.PI / 2));
                
                g.curveTo(x + nextPos.x + controlPos.x, y + nextPos.y + controlPos.y, x + nextPos.x, y + nextPos.y);
                
                startAngle = nextAngle;
            }
        }
    }
}


/**
 * IParticle
 * パーティカルフィルターで用いるパーティクルクラスのインターフェース。
 *
 * @author ton
 */
interface IParticle {
    /**
     * パーティカルの重みを返します。
     */
    function get weight():Number;
    function set weight(value:Number):void;
    
    /**
     * パーティクルを複製して返します。
     * @return 複製されたパーティクルクラス。
     */
    function clone():IParticle;
}

import flash.errors.IllegalOperationError;

/**
 * ParticleFilter
 * パーティクルフィルタの抽象クラス。このクラスは直接生成できません。
 * パーティクルフィルタを実装する時はこのクラスを継承し、Iparticleを実装したパーティクルクラスを用いてください。
 *
 * @author ton
 */
class ParticleFilter {
    /**
     * パーティクルを格納した配列
     */
    protected var _particles:Vector.<IParticle>;
    
    /**
     * パーティクルの数
     */
    protected var _particleCount:int;
    
    /**
     * 観測結果のパーティクル
     */
    protected var _resultParticle:IParticle;
    
    /**
     * コンストラクタ
     * このクラスは直接生成できません。
     * このコンストラクタを呼び出すとIllegalOperationErrorが発生します。
     */
    public function ParticleFilter() {
        if (Object(this).constructor == ParticleFilter) {
            throw new IllegalOperationError("このクラスは抽象クラスです。直接生成できません。");
        }
    }
    
    /**
     * パーティクルフィルタを初期化します。
     */
    public function init():void {
    }
    
    /**
     * パーティクルフィルタを更新します。
     */
    public function update():void {
        resample(_particles);
        predict(_particles);
        weighting(_particles);
        _resultParticle = measure(_particles);
    }
    
    /**
     * リサンプリングを行います。
     * @param    particles　パーティクルの配列。
     */
    protected function resample(particles:Vector.<IParticle>):void {
        var n:int = this.particleCount;
        var tmpParticles:Vector.<IParticle> = new Vector.<IParticle>(n);
        var weights:Vector.<Number> = new Vector.<Number>(n);
        var i:int;
        for (i = 1; i < n; i++) {
            weights[i] = weights[i - 1] + particles[i].weight;
            tmpParticles[i] = particles[i].clone();
        }
        
        var w:Number;
        var j:int;
        
        for (i = 0; i < n; i++) {
            w = Math.random() * weights[n - 1];
            j = 0;
            while (weights[++j] < w) {
            }
            ;
            particles[i] = tmpParticles[j].clone();
            particles[i].weight = 1;
        }
    }
    
    /**
     * 前のパーティクル情報から、現在のパーティクル情報を予測します。
     * このメソッドは実装されていません。オーバーライドしてください。
     * @param    particles パーティクルの配列。
     */
    protected function predict(particles:Vector.<IParticle>):void {
    }
    
    /**
     * 重み付けを行います。
     * @param    particles
     */
    protected function weighting(particles:Vector.<IParticle>):void {
        var n:int = this.particleCount;
        var sumWeight:Number = 0;
        var i:int;
        
        for (i = 0; i < n; i++) {
            particles[i].weight = likelihood(particles[i]);
            sumWeight += particles[i].weight;
        }
        
        for (i = 0; i < n; i++) {
            particles[i].weight = n * particles[i].weight / sumWeight;
        }
    }
    
    /**
     * パーティクルの尤度を計算します。
     * このメソッドは実装されていません。オーバーライドしてください。
     * @param    particle　パーティクル。
     * @return 尤度。
     */
    protected function likelihood(particle:IParticle):Number {
        return 0;
    }
    
    /**
     * 全パーティクルの重み付き平均を計算します。
     * @param    particles パーティクルの配列。
     * @return    全パーティクルの重み付き平均をとったパーティクル。
     */
    protected function measure(particles:Vector.<IParticle>):IParticle {
        return null;
    }
    
    /**
     * パーティクルの配列を返します。
     */
    public function get particles():Vector.<IParticle> {
        return _particles;
    }
    
    /**
     * パーティクルの個数を返します。
     */
    public function get particleCount():int {
        return _particleCount;
    }
    
    /**
     * 全パーティクルの重み付き平均をとったパーティクルを返します。
     */
    public function get resultParticle():IParticle {
        return _resultParticle;
    }

}

import flash.display.BitmapData;

/**
 * 画像中の物体を追跡するパーティクルフィルタです。
 * @author ton
 */
class ImageParticleFilter extends ParticleFilter {
    private var _imgSrc:BitmapData;
    private var _colorChecker:IColorChecker;
    private var _variance:Number;
    private var _particleWidth:int;
    private var _particleHeight:int;
    
    /**
     * コンストラクタ。
     * @param    imgSrc 画像データ。
     * @param    colorChecker 認識したい物体の色を判定するクラス
     * @param    particleCount　パーティクルの数。
     * @param    variance　分散。
     * @param    particleWidth　パーティクルの探索する幅
     * @param    particleHeight パーティクル中心の探索する高さ
     */
    public function ImageParticleFilter(imgSrc:BitmapData, colorChecker:IColorChecker, particleCount:int = 100, variance:Number = 13, particleWidth:int = 30, particleHeight:int = 30) {
        _imgSrc = imgSrc;
        _colorChecker = colorChecker;
        _particleCount = particleCount;
        _variance = variance;
        _particleWidth = particleWidth;
        _particleHeight = particleHeight;
        
        init();
    }
    
    override public function init():void {
        _particles = new Vector.<IParticle>();
        
        for (var i:int = 0; i < _particleCount; i++) {
            var p:ImageParticle = new ImageParticle(1.0 / particleCount, Math.random() * imgSrc.width, Math.random() * imgSrc.height);
            _particles.push(p);
        }
    }
    
    override protected function predict(particles:Vector.<IParticle>):void {
        var n:int = particleCount;
        var v:Number = variance;
        var vx:Number;
        var vy:Number;
        var p:ImageParticle;
        
        for (var i:int = 0; i < n; i++) {
            p = particles[i] as ImageParticle;
            
            vx = variance * Math.sqrt(-2 * Math.log(Math.random())) * Math.sin(2 * Math.PI * Math.random());
            vy = variance * Math.sqrt(-2 * Math.log(Math.random())) * Math.sin(2 * Math.PI * Math.random());
            
            p.x += vx;
            p.y += vy;
            
            p.x = (p.x < 0) ? 0 : (p.x >= imgSrc.width) ? (imgSrc.width - 1) : p.x;
            p.y = (p.y < 0) ? 0 : (p.y >= imgSrc.height) ? (imgSrc.height - 1) : p.y;
        }
    }
    
    override protected function likelihood(particle:IParticle):Number {
        var p:ImageParticle = ImageParticle(particle);
        var x:int = p.x;
        var y:int = p.y;
        var w:int = particleWidth;
        var h:int = particleHeight;
        var cnt:int = 0;
        
        for (var i:int = y - h / 2; i < y + h / 2; i++) {
            for (var j:int = x - w / 2; j < x + w / 2; j++) {
                if (isInImage(j, i) && isInColor(j, i)) {
                    cnt++;
                }
            }
        }
        
        if (cnt == 0) {
            return 0.0001;
        } else {
            return cnt / (w * h);
        }
    }
    
    private function isInImage(x:int, y:int):Boolean {
        return x >= 0 && y >= 0 && x < imgSrc.width && y < imgSrc.height;
    }
    
    private function isInColor(x:int, y:int):Boolean {
        var c:uint = imgSrc.getPixel(x, y);
        return colorChecker.isCorrect(c);
    }
    
    override protected function measure(particles:Vector.<IParticle>):IParticle {
        var n:uint = particleCount;
        
        var x:Number = 0;
        var y:Number = 0;
        var w:Number = 0;
        
        var p:ImageParticle;
        
        for (var i:uint = 0; i < n; ++i) {
            p = ImageParticle(particles[i]);
            x += p.x * p.weight;
            y += p.y * p.weight;
            w += p.weight;
        }
        
        return new ImageParticle(1, x / w, y / w);
    }
    
    /**
     * 観測している画像データ。
     */
    public function get imgSrc():BitmapData {
        return _imgSrc;
    }
    
    /**
     * 認識したい物体の色を判定するチェッカーオブジェクト
     */
    public function get colorChecker():IColorChecker {
        return _colorChecker;
    }
    
    public function set colorChecker(value:IColorChecker):void {
        _colorChecker = value;
    }
    
    /**
     * 分散。
     */
    public function get variance():Number {
        return _variance;
    }
    
    public function set variance(value:Number):void {
        _variance = value;
    }
    
    /**
     * パーティクルの探索する幅
     */
    public function get particleWidth():int {
        return _particleWidth;
    }
    
    public function set particleWidth(value:int):void {
        _particleWidth = value;
    }
    
    /**
     * パーティクルの探索する高さ
     */
    public function get particleHeight():int {
        return _particleHeight;
    }
    
    public function set particleHeight(value:int):void {
        _particleHeight = value;
    }
}

/**
 * 画像中の位置情報を持つパーティクル。
 * @author ton
 */
class ImageParticle implements IParticle {
    private var _weight:Number;
    private var _x:int;
    private var _y:int;
    
    public function ImageParticle(weight:Number = 0, x:int = 0, y:int = 0) {
        _weight = weight;
        _x = x;
        _y = y;
    }
    
    public function get weight():Number {
        return _weight;
    }
    
    public function set weight(value:Number):void {
        _weight = value;
    }
    
    public function get x():int {
        return _x;
    }
    
    public function set x(value:int):void {
        _x = value;
    }
    
    public function get y():int {
        return _y;
    }
    
    public function set y(value:int):void {
        _y = value;
    }
    
    public function clone():IParticle {
        return new ImageParticle(_weight, _x, _y);
    }

}

/**
 * 認識したい物体の色かチェックするクラスインターフェースです。
 * @author ton
 */
interface IColorChecker {
    /**
     * 引数のRBGカラーが認識したい物体の色の場合はtrueを返すように実装してください。
     * @param    color RGBカラー
     * @return 認識したい物体の色の場合はtrue、そうでない場合はfalseを返してください。
     */
    function isCorrect(color:uint):Boolean;
}

/**
 * 赤色かチェックします。
 * @author ton
 */
class RedChecker implements IColorChecker {
    public function isCorrect(color:uint):Boolean {
        var r:uint = color >> 16 & 0xff;
        var g:uint = color >> 8 & 0xff;
        var b:uint = color & 0xff;
        
        return (r > 200 && g < 100 && b < 100);
    }
}

/**
 * 青色かチェックします。
 * @author ton
 */
class BlueChecker implements IColorChecker {
    public function isCorrect(color:uint):Boolean {
        var r:uint = color >> 16 & 0xff;
        var g:uint = color >> 8 & 0xff;
        var b:uint = color & 0xff;
        
        return (r < 100 && g < 100 && b > 200);
    }
}