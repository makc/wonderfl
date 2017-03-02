/* -----------------------------------------------------------
 * [reference]
 * 
 * 火炎放射。
 * http://wonderfl.net/c/oD47
 * FireTest
 * http://wonderfl.net/c/gOig
 * Smoke 煙の表現
 * http://wonderfl.net/c/zuO7
 * 煙もくもく。
 * http://wonderfl.net/c/5hBU
 * perlinNoiseでランダムシードをある数にすると穴がぽこぽこ
 * http://wonderfl.net/c/d01w
 * BitmapData.draw 変な枠線が出る
 * http://wonderfl.net/c/8gEs
 * WWII Flame Thrower 2
 * http://youtu.be/uE9XEXClDGo
 * 陸上自衛隊　火炎放射　模擬戦
 * http://youtu.be/rVECqHwXyZc
 * 汚物
 * http://www.nicovideo.jp/watch/sm2112790
 * 
 * ----------------------------------------------------------
 */

package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.BlurFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import net.hires.debug.Stats;
    
    [SWF(width="465",height="465",frameRate="30")]
    public class Main extends Sprite {
        private var _screen:BitmapData;
        private var _images:Vector.<BitmapData>;
        private var _particles:Vector.<IParticle>;
        private var _pressingTime:int;
        
        public function Main() {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            stage ? initialize() : addEventListener(Event.ADDED_TO_STAGE, initialize);
        }
        
        private static const NUM_IMAGES:int = 20;
        private static const IMAGE_SIZE:int = 40;
        
        private function initialize(event:Event = null):void {
            if (event) { event.target.removeEventListener(Event.ADDED_TO_STAGE, initialize); }
            stage.quality = StageQuality.LOW;
            
            _screen = new BitmapData(465, 465, true, 0x00FFFFFF);
            _images = new Vector.<BitmapData>();
            for (var i:int = 0; i < NUM_IMAGES; i++) {
                _images.push(createFlameImage(IMAGE_SIZE));
            }
            _particles = new Vector.<IParticle>();
            _pressingTime = -1;
            
            addChild(new Bitmap(_screen));
            addChild(new Stats());
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            addEventListener(Event.ENTER_FRAME, update);
        }
        private function mouseDownHandler(event:MouseEvent):void { _pressingTime = 0; }
        private function mouseUpHandler(event:MouseEvent):void { _pressingTime = -1; }
        
        private static const ORIGIN:Point = new Point(0, 0);
        
        private function createFlameImage(size:int):BitmapData {
            var image:BitmapData = new BitmapData(size, size, true, 0x00FFFFFF);
            var noise:BitmapData = image.clone();
            
            var base:Number = size / 2;
            noise.perlinNoise(base, base, 4, 346 * Math.random(), false, false, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var shrinkageSize:Number = size / 3;
            var circleSize:Number = size - shrinkageSize;
            var offset:Number = shrinkageSize / 2;
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(circleSize, circleSize, 0, offset, offset);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFFFF80, 0xFFC000, 0xFF8000, 0xc04000, 0x800000], [1, 1, 1, 1, 1, 0], [0, 64, 128, 160, 208, 255], matrix);
            sprite.graphics.drawRect(offset, offset, circleSize, circleSize);
            sprite.graphics.endFill();
            image.draw(sprite);
            
            var filter:BitmapFilter = new DisplacementMapFilter(noise, ORIGIN, BitmapDataChannel.RED, BitmapDataChannel.GREEN, shrinkageSize, shrinkageSize, DisplacementMapFilterMode.CLAMP);
            image.applyFilter(image, image.rect, ORIGIN, filter);
            return image;
        }
        
        private static const IMAGE_OFFSET:Number = -(IMAGE_SIZE / 2);
        private static const FADE:ColorTransform = new ColorTransform(1, 1, 1, 0.5);
        private static const BLUR:BitmapFilter = new BlurFilter(2, 2);
        
        private function update(event:Event):void {
            if (_pressingTime > -1) { 
                _pressingTime++;
                createParticle();
            }
            
            _screen.lock();
            _screen.colorTransform(_screen.rect, FADE);
            for (var i:int = _particles.length - 1; i >= 0; i--) {
                var particle:IParticle = _particles[i];
                if (particle.update(IMAGE_OFFSET)) {
                    _screen.draw(_images[particle.imageIndex], particle.matrix, particle.colorTransform, particle.blendMode);
                }else {
                    _particles.splice(i, 1);
                }
            }
            _screen.applyFilter(_screen, _screen.rect, ORIGIN, BLUR);
            _screen.unlock();
        }
        
        private static const EMITTER_POSX:Number = 93;
        private static const EMITTER_POSY:Number = 372;
        private static const FLAME_RANGE:Number = 450;
        
        private function createParticle():void {
            var radian:Number = Math.atan2(mouseY - EMITTER_POSY, mouseX - EMITTER_POSX);
            var frameRate:Number = stage.frameRate;
            
            if ( _pressingTime > 14) {
                _particles.push(new LargeSmoke(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
                _particles.push(new SmallSmoke(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
                _particles.push(new LargeFlame(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
            }else if (_pressingTime > 9) {
                _particles.push(new Explosion(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
                _particles.push(new SmallSmoke(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
                _particles.push(new LargeFlame(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
            }else {
                _particles.push(new SmallFlame(EMITTER_POSX, EMITTER_POSY, FLAME_RANGE, radian, frameRate, NUM_IMAGES * Math.random()));
            }
        }
    }
}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * IParticle
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    
    //public 
    interface IParticle {
        function update(offset:Number):Boolean;
        
        function get imageIndex():int;
        function get matrix():Matrix;
        function get colorTransform():ColorTransform;
        function get blendMode():String;
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * AbstractParticle
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import org.libspark.betweenas3.tweens.ITween;
    
    //public
    class AbstractParticle implements IParticle {
        public var posX:Number;
        public var posY:Number;
        public var scaleX:Number;
        public var scaleY:Number;
        public var radian:Number;
        public var alpha:Number;
        public var colorMultiplier:Number;
        public var colorOffset:Number;
        
        private var _imageIndex:int;
        private var _matrix:Matrix;
        private var _colorTransform:ColorTransform;
        private var _blendMode:String;
        
        private var _tween:ITween;
        private var _lifeCount:int;
        private var _lifeMax:int;
        
        public function AbstractParticle(
            posX:Number, posY:Number, scaleX:Number, scaleY:Number,
            radian:Number, alpha:Number, colorMultiplier:Number, colorOffset:Number,
            time:Number, frameRate:Number, imageIndex:int, tween:ITween
        ) {
            this.posX = posX;
            this.posY = posY;
            this.scaleX = scaleX;
            this.scaleY = scaleY;
            this.radian = radian;
            this.alpha = alpha;
            this.colorMultiplier = colorMultiplier;
            this.colorOffset = colorOffset;
            
            _imageIndex = imageIndex;
            _matrix = new Matrix();
            _colorTransform = new ColorTransform();
            _blendMode = BlendMode.NORMAL;
            _tween = tween;
            _lifeCount = _lifeMax = int(time * frameRate);
            
            _tween.play();
        }
        
        public final function update(offset:Number):Boolean {
            _matrix.identity();
            _matrix.translate(offset, offset);
            _matrix.scale(scaleX, scaleY);
            _matrix.rotate(radian);
            _matrix.translate(posX, posY);
            
            _colorTransform.alphaMultiplier = alpha;
            _colorTransform.redMultiplier = _colorTransform.greenMultiplier = _colorTransform.blueMultiplier = colorMultiplier;
            _colorTransform.redOffset = _colorTransform.greenOffset = _colorTransform.blueOffset = colorOffset;
            
            _blendMode = getCurrentBlendMode();
            
            return --_lifeCount > 0;
        }
        
        protected function getCurrentBlendMode():String { return BlendMode.NORMAL; }
        
        public final function get imageIndex():int { return _imageIndex; }
        public final function get matrix():Matrix { return _matrix; }
        public final function get colorTransform():ColorTransform { return _colorTransform; }
        public final function get blendMode():String { return _blendMode; }
        protected final function get lifeRate():Number { return _lifeCount / _lifeMax; }
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * SmallFlame
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;

    //public
    class SmallFlame extends AbstractParticle implements IParticle {
        
        public function SmallFlame(fromX:Number, fromY:Number, range:Number, radian:Number, frameRate:Number, imageIndex:int) {
            var flickeredRange:Number = range - (range * 0.2 * Math.random());
            var flickeredRadian:Number = radian + (Math.PI / 72 * (Math.random() - 0.5));
            var toX:Number = flickeredRange * Math.cos(flickeredRadian) + fromX;
            var toY:Number = flickeredRange * Math.sin(flickeredRadian) + fromY;
            super(fromX, fromY, 1.5, 0.3, radian, 1, 1, 64, 0.8, frameRate, imageIndex,
                BetweenAS3.to(this,
                    {posX:toX, posY:toY, scaleY:0.9, alpha:0 },
                    0.8, Sine.easeOut
                )
            );
        }
        
        override protected function getCurrentBlendMode():String {
            return BlendMode.ADD;
        }
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * LargeFlame
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;

    //public
    class LargeFlame extends AbstractParticle implements IParticle {
        
        public function LargeFlame(fromX:Number, fromY:Number, range:Number, radian:Number, frameRate:Number, imageIndex:int) {
            var flickeredRange:Number = range - (range * 0.2 * Math.random());
            var flickeredRadian:Number = radian + (Math.PI / 36 * (Math.random() - 0.5));
            var toX:Number = flickeredRange * Math.cos(flickeredRadian) + fromX;
            var toY:Number = flickeredRange * Math.sin(flickeredRadian) + fromY;
            var toScaleY:Number = 1.5 * Math.random() + 2;
            var toColorOffset:Number = 128 * Math.random() - 96;
            super(fromX, fromY, 1.5, 0.3, radian, 1, 1, 0, 0.8, frameRate, imageIndex,
                BetweenAS3.to(this,
                    {posX:toX, posY:toY, scaleX:2, scaleY:toScaleY, alpha:0, colorOffset:toColorOffset },
                    0.8, Sine.easeOut
                )
            );
        }
        
        override protected function getCurrentBlendMode():String {
            if (lifeRate > 0.7) { return BlendMode.DARKEN; }
            else { return BlendMode.ADD; }
        }
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * SmallSmoke
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;

    //public
    class SmallSmoke extends AbstractParticle implements IParticle {
        
        public function SmallSmoke(fromX:Number, fromY:Number, range:Number, radian:Number, frameRate:Number, imageIndex:int) {
            var vectorX:Number = range * Math.cos(radian);
            var vectorY:Number = range * Math.sin(radian);
            var midX:Number = vectorX * 0.4 + fromX;
            var midY:Number = vectorY * 0.4 + fromY;
            var control1Point:Number = 0.4 * Math.random() + 0.4;
            var control1X:Number = vectorX * control1Point + fromX;
            var control1Y:Number = vectorY * control1Point + fromY;
            var control2X:Number = control1X;
            var control2Y:Number = control1Y - (range * (0.1 * Math.random() + 0.1));
            var toX:Number = (control1X - midX) * 0.5 + midX;
            var toY:Number = control2Y;
            var toScale:Number = Math.random() + 2.5;
            var relativeRadian:Number = Math.PI * (Math.random() - 0.5);
            super(fromX, fromY, 1.5, 0.3, radian, 1, 1, 64, 1.2, frameRate, imageIndex,
                BetweenAS3.serial(
                    BetweenAS3.to(this,
                        {posX:midX, posY:midY, scaleY:0.6, colorOffset:0 },
                        0.3, Linear.linear
                    ),
                    BetweenAS3.bezier(this,
                        {posX:toX, posY:toY, scaleX:toScale, scaleY:toScale, alpha:0, colorMultiplier:0, colorOffset:128, $radian:relativeRadian },
                        {scaleX:1.5, scaleY:1.5, alpha:0.6, colorMultiplier:0.3, colorOffset:32 },
                        {posX:[control1X, control2X], posY:[control1Y, control2Y] },
                        0.9, Sine.easeOut
                    )
                )
            );
        }
        
        override protected function getCurrentBlendMode():String {
            if (lifeRate > 0.85) { return BlendMode.ADD;}
            else if (lifeRate > 0.74) { return BlendMode.LIGHTEN; }
            else { return BlendMode.DARKEN; }
        }
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * LargeSmoke
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;

    //public
    class LargeSmoke extends AbstractParticle implements IParticle {
        
        public function LargeSmoke(fromX:Number, fromY:Number, range:Number, radian:Number, frameRate:Number, imageIndex:int) {
            var vectorX:Number = range * Math.cos(radian);
            var vectorY:Number = range * Math.sin(radian);
            var midX:Number = vectorX * 0.5 + fromX;
            var midY:Number = vectorY * 0.5 + fromY;
            var control1Point:Number = 0.5 * Math.random() + 0.5;
            var control1X:Number = vectorX * control1Point + fromX;
            var control1Y:Number = vectorY * control1Point + fromY;
            var control2X:Number = control1X;
            var control2Y:Number = control1Y - (range * (0.2 * Math.random() + 0.2));
            var toX:Number = (control1X - midX) * 0.5 + midX;
            var toY:Number = control2Y;
            var toScale:Number = 2 * Math.random() + 5;
            var relativeRadian:Number = Math.PI * (Math.random() - 0.5);
            super(fromX, fromY, 1.5, 0.3, radian, 1, 1, 64, 1.5, frameRate, imageIndex,
                BetweenAS3.serial(
                    BetweenAS3.to(this,
                        {posX:midX, posY:midY, scaleY:0.9, colorOffset:0 },
                        0.3, Linear.linear
                    ),
                    BetweenAS3.bezier(this,
                        {posX:toX, posY:toY, scaleX:toScale, scaleY:toScale, alpha:0, colorMultiplier:0, colorOffset:96, $radian:relativeRadian },
                        {scaleX:1.5, scaleY:1.5, colorMultiplier:0.4, colorOffset:16 },
                        {posX:[control1X, control2X], posY:[control1Y, control2Y] },
                        1.2, Sine.easeOut
                    )
                )
            );
        }
        
        override protected function getCurrentBlendMode():String {
            if (lifeRate > 0.79) { return BlendMode.SCREEN; }
            else { return BlendMode.MULTIPLY; }
        }
    }
//}
/* -------------------------------------------------------------------------------------------------------------------------------------
 * Explosion
 * -------------------------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BlendMode;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;

    //public
    class Explosion extends AbstractParticle implements IParticle {
        
        public function Explosion(fromX:Number, fromY:Number, range:Number, radian:Number, frameRate:Number, imageIndex:int) {
            var vectorX:Number = range * Math.cos(radian);
            var vectorY:Number = range * Math.sin(radian);
            var midX:Number = vectorX * 0.2 + fromX;
            var midY:Number = vectorY * 0.2 + fromY;
            var toX:Number = vectorX + fromX;
            var toY:Number = vectorY + fromY;
            super(fromX, fromY, 1, 0, radian, 1, 1, 32, 0.8, frameRate, imageIndex,
                BetweenAS3.serial(
                    BetweenAS3.to(this,
                        {posX:midX, posY:midY, scaleX:2.4, scaleY:1.8 },
                        0.2, Cubic.easeIn
                    ),
                    BetweenAS3.to(this,
                        {posX:toX, posY:toY, scaleX:1.2, scaleY:0.8, alpha:0, colorOffset:-64 },
                        0.6, Quad.easeOut
                    )
                )
            );
        }
        
        override protected function getCurrentBlendMode():String {
            if (lifeRate > 0.6) { return BlendMode.SCREEN; }
            else { return BlendMode.MULTIPLY;}
        }
    }
//}