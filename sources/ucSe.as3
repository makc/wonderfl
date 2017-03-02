/**
* Fire Slash
* interaction: mouse move, click
* 
* 炎を作ったことがほとんどないので勉強中.
* ドラゴンのグラフィックは野プリン様からお借りしました.
* @see http://wild-pd.hp.infoseek.co.jp/
* 
* クリックで表示を3段階で切り替えます.
* 剣閃+ドラゴン → ドラゴン炎上 → 剣閃,
* 炎上中はマウス座標で炎の大きさが変化します.
* 
* 炎ライブラリはもう少しブラッシュアップしたら
* 一応解説とかする心づもりです.
* 
* LOG
* 2010.09.07 フィルタを簡略化してちょっと高速化
* 2010.09.07 発火元の強度を可変にした
* 
* TODO
* フィルタ/パーティクル処理のPixelBenderへの組み込み
* 
* @author Yukiya Okuda<http://alumican.net/>
*/
package {
    import com.flashdynamix.utils.SWFProfiler;
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Linear;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width=465,height=465,backgroundColor=0x000000)]
    public class Main extends Sprite {
        
        private var canvas:CurveSketch;
        private var monster:Sprite;
        private var monsterBmp:Bitmap;
        private var count:int;
        private var countMax:int;
        private var tween:ITween;
        private var flame:Flame;
        private var phase:int;
        
        public function Main():void {
            Wonderfl.disable_capture();
            opaqueBackground = 0x0;
            stage.frameRate = 60;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            SWFProfiler.init(this);
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.INIT, _loadCompleteHandler);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/5/5d/5dab/5dab683dec1a7007c339ddd3fc952ca58a82b68c"), new LoaderContext(true));
        }
        
        private function _loadCompleteHandler(e:Event):void {
            monsterBmp = LoaderInfo(e.target).content as Bitmap;
            monster = new Sprite();
            monster.addChild(monsterBmp);
            addChild(monster);
            
            canvas = addChild( new CurveSketch(this) ) as CurveSketch;
            canvas.visible = false;
            
            flame = addChild( new Flame(canvas, 465, 465) ) as Flame;
            //flame.blendMode = BlendMode.ADD;
            
            phase = 0;
            stage.addEventListener(MouseEvent.CLICK, _clickHandler);
        }
        
        private function _clickHandler(e:MouseEvent):void {
            if (++phase > 2) phase = 0;
            
            if (phase == 0) {
                flame.emitter = canvas;
                flame.cooling = 0.1;
                flame.enhance = 1;
                monster.visible = true;
                monsterBmp.y = 0;
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
                
            } else  if (phase == 1) {
                flame.emitter = monster;
                flame.enhance = 2;
                monster.visible = false;
                monsterBmp.y = 3;
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
                
            } else {
                flame.emitter = canvas;
                flame.cooling = 0.1;
                flame.enhance = 1;
                monster.visible = false;
                monsterBmp.y = 0;
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
            }
        }
        
        private function onMove(e:MouseEvent):void {
            var min:Number = 0.1;
            var max:Number = 1;
            
            var my:Number = mouseY / stage.stageHeight;
            flame.cooling = min + (my * my) * (max - min);
        }
        
        public function shake():void
        {
            if (!monster.visible) return;
            addEventListener(Event.ENTER_FRAME, updateShake);
            countMax = count = 30;
            
            if (tween) tween.stop();
            tween = BetweenAS3.tween(monster, { transform : { colorTransform : { redOffset : 0 , blueOffset : 0, greenOffset : 0 } } },    
                                              { transform : { colorTransform : { redOffset : 60, blueOffset : 0, greenOffset : 0 } } }, 1, Linear.easeNone);
            tween.play();
        }
        
        private function updateShake(e:Event):void {
            if (--count < 0) {
                monster.x = monster.y = 0;
                removeEventListener(Event.ENTER_FRAME, updateShake);
            } else {
                monster.x = Math.random() * (count / countMax) * 10;
                monster.y = Math.random() * (count / countMax) * 10;
            }
        }
    }
}





/**
* forked from: SketchSample6
* http://wonderfl.net/c/vCkz
*/
//package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.ConvolutionFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import frocessing.display.F5MovieClip2D;
    
    /*public*/ class CurveSketch extends F5MovieClip2D {
        
        //加速度運動の変数
        
        //位置
        private var xx:Number;
        private var yy:Number;
        
        //速度
        private var vx:Number;
        private var vy:Number;
        
        //加速度の係数
        private var ac:Number;
        
        //速度の減衰係数
        private var de:Number;
        
        //描画座標
        private var px0:Array;
        private var py0:Array;
        private var px1:Array;
        private var py1:Array;
        
        //グラデーション用の変数
        private var cs:Array;
        private var ratios:Array;
        
        //描画グループ
        private var shapes:Array;
        
        private var main:Main;
        
        public function CurveSketch(main:Main):void {
            this.main = main;
            
            //初期化
            vx = vy = 0.0;
            xx = mouseX;
            yy = mouseY;
            ac = 0.06;
            de = 0.9;
            px0 = [xx, xx, xx, xx];
            py0 = [yy, yy, yy, yy];
            px1 = [xx, xx, xx, xx];
            py1 = [yy, yy, yy, yy];
            
            cs = [0xcc0000,0xcc0000];
            ratios = [0, 255];
            
            shapes = [];
            
            //線と塗りの色指定
            noStroke();
        }
        
        public function draw():void {
            //加速度運動
            xx += vx += ( mouseX - xx ) * ac;
            yy += vy += ( mouseY - yy ) * ac;
            
            var len:Number = mag( vx, vy );
            
            if (len > 30) main.shake();
            
            //新しい描画座標
            var x0:Number = xx + 5 + len * 0.15;
            var y0:Number = yy - 4 - len * 0.15;
            var x1:Number = xx - 5 - len * 0.15;
            var y1:Number = yy + 4 + len * 0.15;
            
            //描画座標
            px0.shift(); px0.push( x0 );
            py0.shift(); py0.push( y0 );
            px1.shift(); px1.push( x1 );
            py1.shift(); py1.push( y1 );
            
            //グラデーション形状指定
            //var mtx:FGradientMatrix = new FGradientMatrix();
            //mtx.createLinear( px0[1], py0[1], px0[2], py0[2] );
            
            var _px0:Array = [px0[0], px0[1], px0[2], px0[3]];
            var _py0:Array = [py0[0], py0[1], py0[2], py0[3]];
            var _px1:Array = [px1[0], px1[1], px1[2], px1[3]];
            var _py1:Array = [py1[0], py1[1], py1[2], py1[3]];
            
            shapes.push( { px0:_px0, py0:_py0, px1:_px1, py1:_py1} );
            if (shapes.length >= 60) shapes.shift();
            
            var shapesLength:int = shapes.length;
            for (var i:int = shapesLength-1; i >= 0; i--) {
                var sh:Object = shapes[i];
                var a1:Number = i * 0.03;
                var a2:Number = (i - 1) * 0.03;
                if (a1 > 1) a1 = 1.0;
                if (a2 > 1) a2 = 1.0;
                else if (a2 < 0) a2 = 0.0;
                
                //beginGradientFill( "linear", cs, [a2,a1], ratios, sh.mtx );
                beginShape();
                curveVertex( sh.px0[0], sh.py0[0] );
                curveVertex( sh.px0[1], sh.py0[1] );
                curveVertex( sh.px0[2], sh.py0[2] );
                curveVertex( sh.px0[3], sh.py0[3] );
                vertex( sh.px1[2], sh.py1[2] );
                curveVertex( sh.px1[3], sh.py1[3] );
                curveVertex( sh.px1[2], sh.py1[2] );
                curveVertex( sh.px1[1], sh.py1[1] );
                curveVertex( sh.px1[0], sh.py1[0] );
                endShape();
            }
            
            //減衰処理
            vx *= de;
            vy *= de;
        }
    }
//}





/**
* 炎(プロトタイプ)
* Saqoosha氏のhttp://wonderfl.net/c/roloを参考に軽量化・改造
*/
//package
//{    
    /*public*/ class Flame extends Sprite
    {
        public function get emitter():DisplayObject { return _emitter; }
        public function set emitter(value:DisplayObject):void { _emitter = value; }
        private var _emitter:DisplayObject;
        
        private var _width:int;
        private var _height:int;
        
        private var _clearBmd:BitmapData;
        
        private var _greyBmd:BitmapData;
        private var _greyFilter:ColorMatrixFilter;
        
        private var _spreadFilter:ConvolutionFilter;
        private var _spread:int;
        
        public function get cooling():Number { return _cooling; }
        public function set cooling(value:Number):void
        {
            _cooling = value;
            _coolingFilter = new ColorMatrixFilter(
            [
            value, 0    , 0    , 0    , 0,
            0    , value, 0    , 0    , 0,
            0    , 0    , value, 0    , 0,
            0    , 0    , 0    , value, 0
            ]);
        }
        private var _cooling:Number;
        private var _coolingBmd1:BitmapData;
        private var _coolingBmd2:BitmapData;
        private var _coolingOffset:Array;
        private var _coolingFilter:ColorMatrixFilter;
        
        private var _coolingOffset1:Point;
        private var _coolingOffset2:Point;
        
        private var _coolingTmpBmd1:BitmapData;
        private var _coolingTmpBmd2:BitmapData;
        
        public function get enhance():Number { return _enhance; }
        public function set enhance(value:Number):void
        {
            _enhance = value;
            _enhanceTransform = new ColorTransform(_enhance, _enhance, _enhance);
        }
        private var _enhance:Number;
        private var _enhanceTransform:ColorTransform;
        
        public function get palette():Array { return _palette; }
        public function set palette(value:Array):void { _palette = value; }
        
        private var _palette:Array;
        private var _paletteAlpha:Array;
        
        private var _fire:BitmapData;
        
        private var _zeros:Array;
        private var _point:Point;
        private var _rect:Rectangle;
        
        private var _particleCount:int;
        private var _particleFirst:Particle;
        
        public function get sparkLife():int { return _sparkLife; }
        public function set sparkLife(value:int):void { _sparkLife = value; }
        private var _sparkLife:int;
        
        public function get sparkThreshold():int { return _sparkThreshold; }
        public function set sparkThreshold(value:int):void { _sparkThreshold = value; }
        private var _sparkThreshold:int;
        
        public function Flame(emitter:DisplayObject, width:int, height:int):void
        {
            _emitter = emitter;
            _width = width;
            _height = height;
            
            _point = new Point(0, 0);
            _rect = new Rectangle(0, 0, _width, _height);
            
            _clearBmd = new BitmapData(_width, _height, false, 0x0);
            
            //グレースケール(NTSC加重平均)
            _greyBmd = new BitmapData(_width, _height, false, 0x0);
            _greyFilter = new ColorMatrixFilter([
                0.298912, 0.586611, 0.114478, 0, 0,
                0.298912, 0.586611, 0.114478, 0, 0,
                0.298912, 0.586611, 0.114478, 0, 0,
                0       , 0       , 0       , 1, 0
            ]);
            
            //炎の拡散
            _spread = 3;
            _spreadFilter = new ConvolutionFilter(_spread, _spread, [
                0, 1, 0,
                1, 1, 1,
                0, 1, 0
            ], 5);
            
            //炎の冷却
            _coolingBmd1 = new BitmapData(_width, _height, false, 0x0);
            _coolingBmd2 = new BitmapData(_width, _height, false, 0x0);
            _coolingOffset = [new Point(0, 0), new Point(0, 0)];
            cooling = 0.1;
            
            /*
            var scaleX1:Number = 0.1;
            var scaleY1:Number = 1.0;
            var scaleX2:Number = 2;
            var scaleY2:Number = 1.0;
            _coolingOffset1.x -= 0; _coolingOffset1.y -= 5;
            _coolingOffset2.x += 2; _coolingOffset2.y -= 10;
            */
            
            var scaleX1:Number = 0.1;
            var scaleY1:Number = 1.0;
            var scaleX2:Number = 2;
            var scaleY2:Number = 1.0;
            _coolingBmd1.perlinNoise(_width * scaleX1, _height * scaleY1, 2, 982374, true, false, 0, true);
            _coolingBmd2.perlinNoise(_width * scaleX2, _height * scaleY2, 2, 982374, true, false, 0, true);
            
            _coolingTmpBmd1 = _coolingBmd1.clone();
            _coolingTmpBmd2 = _coolingBmd2.clone();
            
            _coolingOffset1 = new Point();
            _coolingOffset2 = new Point();
            
            //炎の着色
            _palette = [0x00000000, 0x00000000, 0x027f0000, 0x03aa0000, 0x05cc3300, 0x06d42a00, 0x08df2000, 0x09e31c00, 0x0be82e00, 0x0deb2700, 0x0fee3300, 0x10ef3000, 0x12f13900, 0x13f23600, 0x15f33100, 0x16f33a00, 0x18f43500, 0x19f53d00, 0x1bf53900, 0x1df63e00, 0x1ff73a00, 0x20f74000, 0x22f73c00, 0x23f84200, 0x25f83e00, 0x26f84300, 0x29f93e00, 0x2af94300, 0x2cf94600, 0x2df94400, 0x2ff94600, 0x30fa4500, 0x32fa4700, 0x33fa4600, 0x36fa4700, 0x37fa4a00, 0x39fa4800, 0x3afa4b00, 0x3cfb4c00, 0x3dfb4b00, 0x3ffb4d00, 0x41fb4e00, 0x43fb4c00, 0x44fb4f00, 0x46fb5000, 0x47fb4f00, 0x49fb5000, 0x4bfb5200, 0x4cfb5000, 0x4efb5200, 0x4ffc5400, 0x51fc5500, 0x53fc5600, 0x55fc5400, 0x56fc5600, 0x58fc5700, 0x59fc5600, 0x5bfc5700, 0x5cfc5900, 0x5ffc5b00, 0x60fc5a00, 0x62fc5b00, 0x63fc5d00, 0x65fc5d00, 0x66fc5c00, 0x68fc6000, 0x69fc5f00, 0x6cfc5e00, 0x6cfc6100, 0x6ffd6000, 0x70fc6200, 0x72fc6200, 0x73fc6400, 0x75fc6400, 0x76fd6600, 0x78fd6400, 0x7afd6400, 0x7cfd6500, 0x7dfd6400, 0x7ffd6400, 0x80fd6600, 0x82fd6400, 0x83fd6500, 0x85fd6400, 0x87fd6400, 0x89fd6400, 0x8afd6400, 0x8cfd6400, 0x8dfd6500, 0x8ffd6400, 0x90fd6500, 0x92fd6500, 0x94fd6400, 0x96fd6400, 0x97fd6500, 0x99fd6400, 0x9afd6500, 0x9cfd6500, 0x9efd6400, 0x9ffd6500, 0xa1fd6500, 0xa3fd6400, 0xa4fd6500, 0xa6fd6500, 0xa8fd6400, 0xa9fd6500, 0xabfd6500, 0xacfd6500, 0xaefd6500, 0xb0fd6500, 0xb2fd6400, 0xb3fd6500, 0xb5fd6500, 0xb6fd6500, 0xb8fd6500, 0xb9fd6400, 0xbbfe6500, 0xbdfd6500, 0xbffd6500, 0xc0fe6500, 0xc2fd6500, 0xc3fd6400, 0xc4fe6500, 0xc5fd6500, 0xc6fd6400, 0xc7fe6500, 0xc7fe6500, 0xc8fd6500, 0xc8fd6500, 0xc9fd6500, 0xcafe6500, 0xcafe6500, 0xcbfd6400, 0xccfe6500, 0xccfe6500, 0xcdfd6500, 0xcefd6500, 0xcefd6500, 0xcffd6500, 0xd0fd6400, 0xd0fd6400, 0xd1fd6500, 0xd2fd6500, 0xd2fd6500, 0xd3fd6500, 0xd4fd6500, 0xd4fd6500, 0xd5fd6400, 0xd6fe6500, 0xd7fd6500, 0xd7fd6700, 0xd8fe6a00, 0xd8fe6e00, 0xd9fd7000, 0xdafd7500, 0xdafd7800, 0xdbfe7b00, 0xdcfd7e00, 0xdcfd8000, 0xddfe8300, 0xdefe8800, 0xdefe8b00, 0xdffd8d00, 0xe0fd9000, 0xe0fd9400, 0xe1fe9800, 0xe2fd9a00, 0xe2fd9f00, 0xe3fda100, 0xe4fea400, 0xe4fea800, 0xe5feaa00, 0xe6fdae00, 0xe6fdb100, 0xe7fdb500, 0xe8feb700, 0xe8febb00, 0xe9febd00, 0xeafdc100, 0xeafdc300, 0xebfdc800, 0xecfdcb00, 0xecfdce00, 0xedfed100, 0xeefed400, 0xeefed700, 0xeffedc00, 0xf0fedf00, 0xf0fee100, 0xf1fde400, 0xf2fde700, 0xf2fdeb00, 0xf3fdee00, 0xf4fdf200, 0xf4fdf500, 0xf5fef800, 0xf6fefc00, 0xf6fefe01, 0xf7fefe05, 0xf8fefe0a, 0xf8fefe0e, 0xf9fefe13, 0xfafefe17, 0xfafefe1c, 0xfbfefe20, 0xfcfefe24, 0xfcfefe29, 0xfdfefe2e, 0xfefefe32, 0xfefefe36, 0xffffff3c, 0xffffff40, 0xffffff45, 0xffffff49, 0xffffff4e, 0xffffff52, 0xffffff56, 0xffffff5b, 0xffffff60, 0xffffff64, 0xffffff69, 0xffffff6d, 0xffffff71, 0xffffff76, 0xffffff7a, 0xffffff7f, 0xffffff83, 0xffffff88, 0xffffff8c, 0xffffff91, 0xffffff95, 0xffffff9a, 0xffffff9e, 0xffffffa3, 0xffffffa7, 0xffffffab, 0xffffffb0, 0xffffffb4, 0xffffffb9, 0xffffffbe, 0xffffffc2, 0xffffffc6, 0xffffffcb, 0xffffffcf, 0xffffffd4, 0xffffffd8, 0xffffffdd, 0xffffffe1, 0xffffffe5, 0xffffffea, 0xffffffef, 0xfffffff3, 0xfffffff8, 0xfffffffc, 0xffffffff, 0xffffffff];
            _zeros = new Array(256);
            _paletteAlpha = new Array(256);
            for (var i:int = 0; i < 256; i++)
            {
                _zeros[i] = 0;
                _paletteAlpha[i] = i;
            }
            
            //発火元の強度
            enhance = 1;
            
            //火の粉
            _sparkLife = 50;
            _sparkThreshold = 128;
            _particleCount = 200;
            var p:Particle;
            var old:Particle;
            for (i = 0; i < _particleCount; ++i)
            {
                p = new Particle(Math.random() * _width, Math.random() * _height);
                if (_particleFirst == null)
                {
                    old = _particleFirst = p;
                }
                else
                {
                    old.next = p;
                    old = p;
                }
            }
            
            //レンダリング先
            _fire = new BitmapData(_width, _height, true, 0x0);
            addChild(new Bitmap(_fire));
            
            startRender();
        }
        
        private function _update(e:Event):void
        {
            var emitterRect:Rectangle = _emitter.getRect(_emitter),
            brightness:int,
            color:int,
            p:Particle = _particleFirst;
            
            _greyBmd.lock();
            _fire.lock();
            
            _coolingTmpBmd1.lock();
            _coolingTmpBmd2.lock();
            
            _coolingBmd1.lock();
            _coolingBmd2.lock();
            
            _greyBmd.draw(_emitter, null, _enhanceTransform);
            _greyBmd.applyFilter(_greyBmd, _rect, _point, _greyFilter);
            _greyBmd.applyFilter(_greyBmd, _rect, _point, _spreadFilter);
            
            _scrollBitmapData(_coolingBmd1, _coolingTmpBmd1, _coolingOffset1.x, _coolingOffset1.y);
            _scrollBitmapData(_coolingBmd2, _coolingTmpBmd2, _coolingOffset2.x, _coolingOffset2.y);
            
            _coolingOffset1.x -= 0; _coolingOffset1.y -= 10;
            _coolingOffset2.x += 2; _coolingOffset2.y -= 5;
            
            _coolingTmpBmd2.draw(_coolingTmpBmd1, null, null, BlendMode.ADD);
            _coolingTmpBmd2.applyFilter(_coolingTmpBmd2, _rect, _point, _coolingFilter);
            
            _greyBmd.draw(_coolingTmpBmd2, null, null, BlendMode.SUBTRACT);
            
            _greyBmd.scroll(0, -_spread);
            
            do
            {
                brightness = _greyBmd.getPixel(p.x, p.y) & 0xff;
                
                p.vx = Math.sin(p.clock);
                p.vy = -brightness * 0.05 - 1;
                
                p.clock += 0.01;
                
                p.x += p.vx;
                p.y += p.vy;
                
                if (/*p.life <= 0 &&*/ brightness > _sparkThreshold)
                {
                    p.life = _sparkLife;
                }
                else
                {
                    --p.life;
                }
                
                if (p.x > emitterRect.x + emitterRect.width ) { p.x -= emitterRect.width;  p.life = 0; }
                if (p.x < emitterRect.x                     ) { p.x += emitterRect.width;  p.life = 0; }
                if (p.y < 0                                 ) { p.y += emitterRect.y + emitterRect.height; p.life = 0; }
                
                if (p.life > 0)
                {
                    color = (p.life / _sparkLife) * 0xff;
                    color = (color > brightness) ? color : brightness;
                    
                    _greyBmd.setPixel(p.x, p.y, (color << 16) | (color << 8) | color);
                }
            }
            while (p = p.next);
            
            _fire.paletteMap(_greyBmd, _rect, _point, _zeros, _zeros, _palette, _zeros);
            
            _coolingBmd1.unlock();
            _coolingBmd2.unlock();
            
            _coolingTmpBmd1.unlock();
            _coolingTmpBmd2.unlock();
            
            _greyBmd.unlock();
            _fire.unlock();
        }
        
        public function startRender():void
        {
            addEventListener(Event.ENTER_FRAME, _update);
        }
        
        public function stopRender():void
        {
            removeEventListener(Event.ENTER_FRAME, _update);
        }
        
        public function singleRender():void
        {
            _update(null);
        }
        
        private function _scrollBitmapData(src:BitmapData, dst:BitmapData, scrollX:int, scrollY:int):void
        {
            scrollX %= _width;
            scrollY %= _height;
            
            if (scrollX != 0)
            {
                if (scrollX > 0)
                {
                dst.copyPixels(src, new Rectangle(0, 0, _width - scrollX, _height), new Point(scrollX, 0));
                        dst.copyPixels(src, new Rectangle(_width - scrollX, 0, scrollX, _height), _point);
                }
                else
                {
                    dst.copyPixels(src, new Rectangle(-scrollX, 0, _width + scrollX, _height), _point);
                    dst.copyPixels(src, new Rectangle(0, 0, -scrollX, _height), new Point(_width + scrollX, 0));
                }
            }
            
            if (scrollY != 0)
            {
                if (scrollX != 0)
                {
                    src = dst.clone();
                }
                
                if (scrollY > 0)
                {
                    dst.copyPixels(src, new Rectangle(0, 0, _width, _height - scrollY), new Point(0, scrollY));
                    dst.copyPixels(src, new Rectangle(0, _height - scrollY, _width, scrollY), _point);
                }
                else
                {
                    dst.copyPixels(src, new Rectangle(0, -scrollY, _width, _height + scrollY), _point);
                    dst.copyPixels(src, new Rectangle(0, 0, _width, -scrollY), new Point(0, _height + scrollY));
                }
            }
        }
    }
//}

internal class Particle {
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var life:int;
    public var clock:Number;
    public var next:Particle;
    public function Particle(x:Number, y:Number):void {
        this.x = x;
        this.y = y;
        this.vx = 0;
        this.vy = 0;
        this.life = 0;
        this.clock = Math.random() * Math.PI * 2;
    }
}