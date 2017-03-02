package
{
    import flash.display.Sprite;
    
    import starling.core.Starling;

    [SWF(frameRate = "60", width = "465", height = "465")]
    /**
     * パーティクルデモのメインクラスです。
     */
    public class Main extends flash.display.Sprite
    {
        //----------------------------------------------------------
        //
        //   Constructor 
        //
        //----------------------------------------------------------

        public function Main()
        {
            new Starling(ParticleSample, stage).start();
            Starling.current.showStats = true;
        }
    }
}

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.SpreadMethod;
import flash.display.StageQuality;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.display.QuadBatch;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

/**
 * 大量のパーティクルを発生させてみた
 * マウスを押してる間でてくるよ
 * @see http://wonderfl.net/c/4WjT
 * @class demo.ParticleSample
 */
internal final class ParticleSample extends Sprite
{

    //----------------------------------------------------------
    //
    //   Property 
    //
    //----------------------------------------------------------

    private var _emitter:ParticleEmitter;
    private var _eventMouseDown:Function;

    private var _bg:Quad;

    //----------------------------------------------------------
    //
    //   Constructor 
    //
    //----------------------------------------------------------

    public function ParticleSample()
    {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, initialize);
    }

    private function initialize(event:Event):void
    {
        this._bg = new Quad(1, 1, 0x0);
        this.addChild(this._bg);

        this._emitter = new ParticleEmitter();
        this.addChild(this._emitter.container);

        this.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
        this._bg.addEventListener(TouchEvent.TOUCH, this.mouseDown);

        this.handleResize();
        stage.addEventListener(Event.RESIZE, this.handleResize);
    }

    /**
     * エンターフレームイベント
     * @param event
     */
    private function enterFrameHandler(event):void
    {
        this._emitter.update();
    }

    private function mouseDown(event:TouchEvent):void
    {
        var touches:Vector.<Touch> = event.touches;
        if (touches[0].phase == TouchPhase.BEGAN)
        {
            this.addEventListener(Event.ENTER_FRAME, this.createParticle);
            updateMousePosition();
            this._emitter.x = Starling.current.nativeStage.mouseX;
            this._emitter.y = Starling.current.nativeStage.mouseY;
        }
        if (touches[0].phase == TouchPhase.MOVED)
        {
            updateMousePosition();
        }
        else if (touches[0].phase == TouchPhase.ENDED)
        {
            this.removeEventListener(Event.ENTER_FRAME, this.createParticle);
            updateMousePosition();
        }
    }

    private function updateMousePosition():void
    {
        this._emitter.latestX = Starling.current.nativeStage.mouseX;
        this._emitter.latestY = Starling.current.nativeStage.mouseY;
    }

    private function createParticle(event:Event):void
    {
        var mouseX:Number = Starling.current.nativeStage.mouseX;
        var mouseY:Number = Starling.current.nativeStage.mouseY;
        this._emitter.emit(mouseX, mouseY);

    }

    private function handleResize(event = null):void
    {
        var stageW:Number = Starling.current.nativeStage.stageWidth;
        var stageH:Number = Starling.current.nativeStage.stageHeight;

        // set rectangle dimensions for viewPort:
        var viewPortRectangle:Rectangle = new Rectangle();
        viewPortRectangle.width = stageW;
        viewPortRectangle.height = stageH;

        // resize the viewport:
        Starling.current.viewPort = viewPortRectangle;

        // assign the new stage width and height:
        stage.stageWidth = stageW;
        stage.stageHeight = stageH;

        this._bg.width = stageW;
        this._bg.height = stageH;
    }
}

/**
 * パーティクル発生装置。マウス座標から速度を計算する。
 * @class project.Emitter
 */
internal class Emitter
{

    //----------------------------------------------------------
    //
    //   Property 
    //
    //----------------------------------------------------------

    /** 速度(X方向) */
    public var vy:Number = 0;
    /** 速度(Y方向) */
    public var x:Number = 0;
    /** マウスのX座標 */
    public var latestY:Number = 0;
    /** マウスのY座標 */
    public var latestX:Number = 0;
    /** パーティクル発生のX座標 */
    public var y:Number = 0;
    /** パーティクル発生のY座標 */
    public var vx:Number = 0;

    internal var texture:Texture;

    //----------------------------------------------------------
    //
    //   Constructor 
    //
    //----------------------------------------------------------

    /**
     * @constructor
     */
    public function Emitter()
    {

    }

    /**
     * パーティクルエミッターの計算を行います。この計算によりマウスの引力が計算されます。
     * @method
     */
    public function update():void
    {
        var dx:Number = this.latestX - this.x;
        var dy:Number = this.latestY - this.y;
        var d:Number = Math.sqrt(dx * dx + dy * dy) * 0.2;
        var rad:Number = Math.atan2(dy, dx);

        this.vx += Math.cos(rad) * d;
        this.vy += Math.sin(rad) * d;

        this.vx *= 0.4;
        this.vy *= 0.4;

        this.x += this.vx;
        this.y += this.vy;
    }
}

/**
 * パーティクルエミッター
 * @class project.ParticleEmitter
 */
internal final class ParticleEmitter extends Emitter
{

    //----------------------------------------------------------
    //
    //   Static Property 
    //
    //----------------------------------------------------------

    private static const PARTICLE_ORIGINAL_SIZE:Number = 32;
    private static const PRE_CACHE_PARTICLES:Number = 5000;

    /**
     * パーティクルのつぶ模様を作成します。
     * @return
     */
    private static function createCircleTexture():Texture
    {
        const SIZE:int = PARTICLE_ORIGINAL_SIZE;
        var shape:Shape = new Shape();

        var fillType:String = GradientType.RADIAL;
        var colors:Array = [0xFFFFFF, 0x000000];
        var alphas:Array = [100, 100];
        var ratios:Array = [0x00, 0xFF];
        var mat:Matrix = new Matrix();
        mat.createGradientBox(SIZE, SIZE, 0, -SIZE / 2, -SIZE / 2);
        var spreadMethod:String = SpreadMethod.PAD;

        shape.graphics.clear();
        shape.graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
        shape.graphics.drawCircle(0, 0, SIZE);
        shape.graphics.endFill();

        var bmd:BitmapData = new BitmapData(SIZE * 2, SIZE * 2, true, 0x000000);
        mat.identity();
        mat.translate(SIZE / 2, SIZE / 2);
        bmd.drawWithQuality(shape, mat, null, null, null, true, StageQuality.HIGH_16X16);

        var texture:Texture = Texture.fromBitmapData(bmd);
        return texture;

    }

    //----------------------------------------------------------
    //
    //   Property 
    //
    //----------------------------------------------------------

    /** 1フレーム間に発生させる Particle 数 */
    public var numParticles:Number = 100;
    public var container:Sprite;
    private var _particleActive:Vector.<Particle>;
    private var _particlePool:Vector.<Particle>;
    private var _quadBatch:QuadBatch;
    private var _image:Image;

    //----------------------------------------------------------
    //
    //   Constructor 
    //
    //----------------------------------------------------------

    /**
     * @constructor
     */
    public function ParticleEmitter()
    {
        super();

        this.container = new Sprite();
        this.container.touchable = false;

        this._particleActive = new Vector.<Particle>();
        this._particlePool = new Vector.<Particle>();

        _image = new Image(createCircleTexture());
        _image.pivotX = PARTICLE_ORIGINAL_SIZE / 2;
        _image.pivotY = PARTICLE_ORIGINAL_SIZE / 2;

        this._quadBatch = new QuadBatch();
        this.container.addChild(this._quadBatch);

        /* 予め必要そうな分だけ作成しておく */
        for (var i:int = 0; i < PRE_CACHE_PARTICLES; i++)
        {
            this._particlePool.push(new Particle());
        }
    }

    /**
     * パーティクルを発生させます。
     * @param {number} x パーティクルの発生座標
     * @param {number} y パーティクルの発生座標
     * @method
     */
    public function emit(x:Number, y:Number):void
    {
        for (var i:int = 0; i < this.numParticles; i++)
        {
            this.getNewParticle(x, y);
        }
    }

    /**
     * パーティクルを更新します。
     * @method
     */
    override public function update():void
    {
        super.update();

        this._quadBatch.reset();

        for (var i:int = 0; i < this._particleActive.length; i++)
        {
            var p:Particle = this._particleActive[i];
            if (!p.getIsDead())
            {

                if (p.y >= Starling.current.stage.stageHeight)
                {
                    p.vy *= -0.6;
                    p.y = Starling.current.stage.stageHeight;
                }
                else if (p.y <= 0)
                {
                    p.vy *= -0.6;
                    p.y = 0;
                }
                if (p.x >= Starling.current.stage.stageWidth)
                {
                    p.vx *= -0.6;
                    p.x = Starling.current.stage.stageWidth;
                }
                else if (p.x <= 0)
                {
                    p.vx *= -0.6;
                    p.x = 0;
                }

                p.update();

                _image.x = p.x;
                _image.y = p.y;
                _image.width = _image.height = p.scale * p.size * 2;
                _image.blendMode = BlendMode.ADD;
                _image.color = p.color;

                this._quadBatch.addQuad(_image, p.alpha, _image.texture);
            }
            else
            {
                this.removeParticle(p);
            }
        }
    }

    /**
     * パーティクルを削除します。
     * @param {Particle} particle
     * @method
     */
    public function removeParticle(p:Particle):void
    {
        var index:int = this._particleActive.indexOf(p);
        if (index > -1)
        {
            this._particleActive.splice(index, 1);
        }

        this.toPool(p);
    }

    /**
     * アクティブなパーティクルを取り出します。
     * @returns {project.Particle[]}
     * @method
     */
    public function getActiveParticles():Vector.<Particle>
    {
        return this._particleActive;
    }

    /**
     * パーティクルを追加します。
     * @param {THREE.Vector3} emitPoint
     * @method
     */
    private function getNewParticle(emitX:Number, emitY:Number):Particle
    {
        var p:Particle = this.fromPool();
        p.resetParameters(this.x, this.y, this.vx, this.vy);
        this._particleActive.push(p);
        return p;
    }

    /**
     * プールからインスタンスを取り出します。
     * プールになければ新しいインスタンスを作成します。
     * @returns {project.Particle}
     * @method
     */
    private function fromPool():Particle
    {
        if (this._particlePool.length > 0)
            return this._particlePool.shift();

        else
            return new Particle();
    }

    /**
     * プールにインスタンスを格納します。
     * @param particle
     */
    private function toPool(particle:Particle):void
    {
        this._particlePool.push(particle);
    }
}

/**
 * @class demo.Particle
 */
internal final class Particle
{

    //----------------------------------------------------------
    //
    //   Property 
    //
    //----------------------------------------------------------

    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var life:Number;
    public var size:Number;
    public var alpha:Number;
    public var scale:Number;
    public var color:Number;
    private var _count:Number;
    private var _destroy:Boolean;

    //----------------------------------------------------------
    //
    //   Constructor 
    //
    //----------------------------------------------------------

    /**
     * コンストラクタ
     * @constructor
     */
    public function Particle()
    {
        super();

        this._destroy = true;
    }

    /**
     * パーティクルをリセットします。
     * @param {createjs.Point} point
     * @param {number} vx
     * @param {number} vy
     */
    public function resetParameters(emitX:Number, emitY:Number, vx:Number, vy:Number):void
    {
        this.x = emitX;
        this.y = emitY;
        this.vx = vx * 0.5 + (Math.random() - 0.5) * 10;
        this.vy = vy * 0.5 + (Math.random() - 0.5) * 10;
        this.life = Math.random() *Math.random() * 128 + 8;
        this.size = Math.random() * Math.random() * 64 + 8;
        
        var red:uint = Math.floor(Math.random() * 100 + 156);
        var green:uint = Math.floor(Math.random() * 156);
        var blue:uint = Math.floor(Math.random() * 100 + 100);
        this.color = (red << 16) | (green << 8) | (blue);

        this.alpha = 1.0;
        this.scale = 1.0;
        
        this._count = 0;
        this._destroy = false;
    }

    /**
     * パーティクル個別の内部計算を行います。
     * @method
     */
    public function update():void
    {
        this.vx *= 0.999;
        this.vy *= 0.999;
        
        this.x += this.vx;
        this.y += this.vy;

        this._count++;

        var maxD:Number = (1 - this._count / this.life / 2);

        this.alpha = Math.random() * 0.6 + 0.4;
        this.scale = maxD;

        // 死亡フラグ
        if (this.life < this._count)
        {
            this._destroy = true;
        }
    }

    /**
     * パーティクルが死んでいるかどうかを確認します。
     * @returns {boolean}
     * @method
     */
    public function getIsDead():Boolean
    {
        return this._destroy;
    }
}
