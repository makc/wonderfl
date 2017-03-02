// forked from makc3d's ff[12]: Mouse Position Gradation 
// forked from H.S's ff[11]: Mouse Position Gradation 
// forked from makc3d's ff[10]: Mouse Position Gradation 
// forked from H.S's ff[9]: Mouse Position Gradation 
// forked from makc3d's ff[8]: Mouse Position Gradation 
// forked from H.S's ff[7]: Mouse Position Gradation 
// forked from makc3d's ff[6]: Mouse Position Gradation 
// forked from H.S's ff[5]: Mouse Position Gradation 
// forked from makc3d's ff[4]: Mouse Position Gradation 
// forked from H.S's forked from: ff[2]: Mouse Position Gradation 
// forked from makc3d's ff[2]: Mouse Position Gradation 
// forked from H.S's forked from: Mouse Position Gradation 
// forked from kawamura's Mouse Position Gradation 
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.*;
    import org.flintparticles.common.counters.*;
    import org.flintparticles.common.displayObjects.RadialDot;
    import org.flintparticles.common.emitters.Emitter;
    import org.flintparticles.common.initializers.*;
    import org.flintparticles.twoD.actions.*;
    import org.flintparticles.twoD.emitters.Emitter2D;
    import org.flintparticles.twoD.initializers.*;
    import org.flintparticles.twoD.renderers.*;
    import org.flintparticles.twoD.zones.*;
    public class FlashTest extends Sprite {
        private var kiki:Shape = new Shape(), kikiLoader:Loader, kikiData:BitmapData, matrix:Matrix = new Matrix;
        private var kikiLifePoint:Number = 100;
        private var hitFlag:Boolean;
        private var explosion:Number = 0;
        private var explosionData:BitmapData;
        private var explosionShape:Shape = new Shape();
        private var snowRenderer1:DisplayObjectRenderer = new DisplayObjectRenderer();
        private var snowRenderer2:DisplayObjectRenderer = new DisplayObjectRenderer();
        private var mousePoint:Point = new Point( -465, -465);
        private function kikiLoads(event:Event):void {
            kikiData = Bitmap(LoaderInfo(event.target).content).bitmapData; kikiLoader = null;
        }
        public function FlashTest() {
            // if coding at night, uncomment this:
            //SoundMixer.soundTransform = new SoundTransform(0);

            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private var bkg:Vector.<Loader> = new <Loader> [];
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            var loader:Loader = new Loader();
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/bd/bd0f/bd0f915b1b3e049363dc5adcb9be32b269918764"), new LoaderContext(true));
            loader.alpha = 0;
            stage.addChild(loader); bkg.push(loader);

            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bkgLoads);
            loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_snow.png"), new LoaderContext(true));
            stage.addChild(loader); bkg.push(loader);

            var explosionLoader:Loader = new Loader();
            explosionLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, explosionLoads);
            explosionLoader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/explosion.png"), new LoaderContext(true));

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        private var t:int = 0, kikiCenter:Point = new Point(), sakura:Loader, music:Loader;
        private function enterFrameHandler(e:Event):void 
        {
            var g:Graphics = kiki.graphics;
            var hitTestRadius:Number;
            g.clear(); g.beginFill(0,0.004); g.drawRect(0,0,465,465);
            if (kikiData) {
            if (kikiLifePoint > 0) {
                t = getTimer ();
                var frame:int = (t / 100) % 6;
                var right:Boolean = int (t / 3000) % 2 > 0;
                var scale:Number = right ? -0.4 : 0.6;
                matrix.identity(); matrix.a = scale; matrix.d = Math.abs (scale);
                var kikix:Number, kikiy:Number, kikit:int = t % 3000;
                if (right) {
                    kikix = 0.2 * kikit * matrix.d;
                    kikiy = 120;
                } else {
                    kikix = 0.2 * (3000 - kikit) * matrix.d - 100;
                    kikiy = 75;
                }
                matrix.tx = kikix - 90 * frame * matrix.d;
                matrix.ty = kikiy;
                g.beginBitmapFill (kikiData, matrix, true, true);
                g.drawRect(kikix, kikiy, 90 * matrix.d, 65 * matrix.d);
                
                kikiCenter.x = (right)?  kikix + 35 * matrix.d : kikix + 55 * matrix.d;
                kikiCenter.y = kikiy + 65 * matrix.d / 2;
                hitTestRadius = 65 * matrix.d;
                /*var barColor:uint = 0x00E000;
                if (kikiLifePoint / 100 <= 0.2) barColor = 0xF5201A;
                else if (kikiLifePoint / 100 <= 0.6) barColor = 0xF5E800;
                g.beginFill(0x000000);
                g.drawRect(kikiCenter.x - 19, kikiy - 11, 38, 6);
                g.beginFill(0x606060);
                g.drawRect(kikiCenter.x - 18, kikiy - 10, 36, 4);
                g.beginFill(0xFFFFFF);
                g.drawRect(kikiCenter.x - 18, kikiy - 10, 36 * kikiLifePoint / 100, 1);
                g.beginFill(barColor);
                g.drawRect(kikiCenter.x - 18, kikiy - 9, 36 * kikiLifePoint / 100, 3);*/
            } else {
                // "explode" kiki at her last known coords
                explosion = 0.02 * 1 + 0.98 * explosion;
                if (explosion < 1) {
                    var side:Number = 500 * explosion + 50, a:Number = Math.min(1,2-2*explosion);
                    matrix.createGradientBox(side, 0.6*side, 0, kikiCenter.x -0.5*side, kikiCenter.y -0.3*side);
                    g.beginGradientFill("radial",[0xff7fff,0xffffff,0xffffff],[0,a,0],[50,250,255],matrix);
                    g.drawRect(kikiCenter.x -0.5*side, kikiCenter.y -0.3*side, side, 0.6*side);
                    // lit up the tree
                    bkg[0].alpha = 1;
                    bkg[1].alpha = a;
                    // remove rpg
                    if (rpg && (rpgFrame == 0)) {
                        var rpgLoader:DisplayObjectContainer = rpg.parent;
                        var rpgRect:Rectangle = rpgLoader.scrollRect;
                        if (rpgRect.height < 2) {
                            rpgLoader.parent.removeChild(rpgLoader); rpg = null;
                        } else {
                            rpgRect.height = Math.max(rpgRect.height - 15, 0); rpgLoader.scrollRect = rpgRect; rpgLoader.y += 15;
                        }
                    }
                }
            }
            }
            
            var delay:int = 5;
            if (rpg && explosionData && rpgFrame >= delay && int(rpgFrame) <= 11 + delay) {
                explosionShape.graphics.clear();
                var col:int = (rpgFrame - delay) % 4;
                var row:int = Math.floor((rpgFrame - delay) / 4);
                var mX:int = mousePoint.x;
                var mY:int = mousePoint.y;
                var mA:Number = ((maskBD.getPixel32(mX, mY) >> 24) & 255) / 255.0;
                var es:Number = 0.3 + mA * Math.max(0, Math.max(mY / 200 - 1, 0.8 * Math.abs(mX / 150 - 1)));
                matrix.identity();
                matrix.translate(mousePoint.x / es - 245 - 490 * col, mousePoint.y / es - 245 - 490 * row);
                matrix.scale(es, es);
                var kikiJustDied:Boolean = false;
                if (mA > 0.3) {
                    g = explosionShape.graphics;
                } else {
                    // kiki hit test
                    if (int(rpgFrame) - delay <= 3 && Point.distance(kikiCenter, mousePoint) <= hitTestRadius && !hitFlag) {
                        kikiLifePoint -= 100; kikiJustDied = (kikiLifePoint <= 0);
                        setTimeout(kikiJustDied ? dyingVoice.play : damageVoice.play, 200);
                        hitFlag = true;
                    }
                }
                g.beginBitmapFill(explosionData, matrix);
                g.drawRect(mousePoint.x - 245 * es, mousePoint.y - 245 * es, 490 * es, 490 * es);
                if (kikiJustDied) {
                    // fade the smoke faster
                    smokeCT.alphaOffset = -10;
                    // change circle gfx to small pink dot
                    circle = new Shape;
                    matrix.createGradientBox(8, 8, 0, -4, -4);
                    circle.graphics.beginGradientFill("radial",[0xffffff,0xff7fff],[1,0],[50,255],matrix);
                    circle.graphics.drawCircle(0, 0, 4);
                }
            }

            if (rpg) {
                matrix.identity();
                matrix.translate(-288 -80, -216 +30 -432 * int(rpgFrame));
                matrix.rotate(0.18); matrix.translate(288, 216);
                rpg.transform.matrix = matrix;

                if (rpgFrame > 0) {
                    rpgFrame += 0.33;
                    if (rpgFrame > 22.4) {
                        rpgFrame = 0;
                    }
                }

                matrix.identity();
                matrix.translate(-270, -180);
                matrix.scale(1.01, 1.01);
                matrix.translate(270, 180);
                var bd2:BitmapData = smokeBD;
                bd2.fillRect(smokeRect, 0);
                bd2.draw(smoke.bitmapData, matrix, smokeCT, null, null, true);
                smokeBD = smoke.bitmapData; smoke.bitmapData = bd2;
            } else if (kikiLifePoint <= 0) {
                if (Math.random() < 0.5) {
                    // torch the tree
                    matrix.identity();
                    matrix.a = matrix.d = 0.1 + Math.random();
                    matrix.tx = //20 + Math.random() * 55
                        20 + 27 + 27 * (Math.random() - Math.random ());
                    matrix.ty = (matrix.tx > 45) ? (75 + Math.random() * 100) : (60 + Math.random() * 25);
                    smoke.bitmapData.draw(circle, matrix, null, null, null, true);
                    // at this point, it is finally safe to load http://wonderfl.net/c/mHNT
                    if(!sakura) {
                        sakura = new Loader;
                        sakura.load(new URLRequest("http://swf.wonderfl.net/swf/usercode/9/9f/9f23/9f2375940c809569ddea50028df93229bf194e33.swf"));
                        sakura.scrollRect = new Rectangle(0, 58, 465, 349);
                        sakura.y = 58;
                        sakura.blendMode = "lighten";
                        stage.addChild(sakura);
                        // also let's try to play some sad anime music off youtube
                        music = new Loader;
                        music.load(new URLRequest("https://www.youtube.com/v/3moSRL57l2A&autoplay=1"));
                    }
                }
                smoke.bitmapData.scroll(0, -1);
                if (snowRenderer1.alpha > 0) snowRenderer1.alpha = snowRenderer2.alpha -= 0.05;
                else snowRenderer1.alpha = snowRenderer2.alpha = 0;
            }
        }

        private function bkgLoads(event:Event):void {
            var spriteSky:Sprite = new Sprite();
            spriteSky.scrollRect = new Rectangle (0, 0, 465, 465);
            stage.addChild(spriteSky);

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, maskLoads);
            loader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/background_mask_snow.png"), new LoaderContext(true));

            spriteSky.addChild(kiki = new Shape);
            spriteSky.addChild(loader);
            spriteSky.blendMode = "layer";
            loader.blendMode = "erase";
            explosionShape.scrollRect = new Rectangle(0, 58, 465, 349);
            explosionShape.y = 58;
            stage.addChild(explosionShape);
            
            stage.addChild(snowRenderer1);
            snowRenderer1.alpha = 0.6;
            var emitter:Emitter2D = newEmitter(35, 0.4, 2);
            snowRenderer1.addEmitter(emitter);
            emitter.start();
            emitter.runAhead(10);
        }
        
        private function explosionLoads(event:Event):void {
            explosionData = Bitmap(LoaderInfo(event.target).content).bitmapData;
        }

        private var maskBD:BitmapData=new BitmapData(1, 1), smoke:Bitmap, smokeBD:BitmapData, smokeRect:Rectangle, circle:Shape, smokeCT:ColorTransform;
        private function maskLoads(event:Event):void {
            maskBD = Bitmap(LoaderInfo(event.target).content).bitmapData;

            kikiLoader = new Loader();
            kikiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, kikiLoads);
            kikiLoader.load(new URLRequest("http://chococornet.sakura.ne.jp/img/kiki_snow.png"), new LoaderContext(true));

            smoke = new Bitmap(new BitmapData (465, 349, true, 0));
            smoke.y = 58; smokeRect = smoke.bitmapData.rect;
            stage.addChild(smoke);

            smokeBD = smoke.bitmapData.clone ();

            circle = new Shape;
            matrix.createGradientBox(200, 200, 0, -100, -100);
            circle.graphics.beginGradientFill("radial",[0xffffff,0xffffff],[0.4,0],[100,255],matrix);
            circle.graphics.drawCircle(0, 0, 100);

            smokeCT = new ColorTransform();
            smokeCT.alphaOffset = -1;

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, rpgLoads);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/e3/e386/e3863b34fdf56ee36c0b34563061cf7d2e7766ca"), new LoaderContext(true));
            loader.scrollRect = new Rectangle (0, 59, 465, 349);
            loader.y = 58;
            loader.addEventListener(MouseEvent.CLICK, rpgFires);
            stage.addChild(loader);
            
            stage.addChild(snowRenderer2);
            snowRenderer2.alpha = 0.6;
            var emitter:Emitter2D = newEmitter(1, 3, 4);
            snowRenderer2.addEmitter(emitter);
            emitter.start();
            emitter.runAhead( 10 );
        }

        private var rpg:Bitmap, rpgFrame:Number = 8;
        private function rpgLoads(event:Event):void {
            rpg = Bitmap(LoaderInfo(event.target).content); rpg.smoothing = true;
        }

        private var rpgShot:Sound = new Sound(new URLRequest("http://freesound.org/data/previews/33/33276_286533-lq.mp3"));
        private var rpgBoom:Sound = new Sound(new URLRequest("http://freesound.org/data/previews/264/264031_3797507-lq.mp3"));
        private var damageVoice:Sound = new Sound(new URLRequest("http://chococornet.sakura.ne.jp/sound/voice_damage.mp3"));
        private var dyingVoice:Sound = new Sound(new URLRequest("http://freesound.org/data/previews/333/333862_5627545-lq.mp3"));
        private function rpgFires(event:MouseEvent):void {
            if (rpg && (rpgFrame == 0) && (kikiLifePoint > 0)) {
                rpgFrame = 1;

                for (var i:int = 0; i < 7; i++) {
                    matrix.identity();
                    matrix.translate(
                        270 + 180 * (Math.random() - Math.random()),
                        180 + 130 * (Math.random() - Math.random())
                    );
                    smoke.bitmapData.draw (circle, matrix);
                }

                rpgShot.play();
                setTimeout(rpgBoom.play, 500);

                mousePoint.setTo(mouseX, mouseY);
                // limit the area we can hit to upper left
                mousePoint.normalize(Math.min(mousePoint.length, 290));
                hitFlag = false;
            }
        }
        
        private function newEmitter(rate:Number, miniScale:Number, maxScale:Number):Emitter2D {
            var emitter:Emitter2D = new Emitter2D();
            emitter.counter = new Steady(rate);
            emitter.addInitializer(new ImageClass( RadialDot, [2]));
            emitter.addInitializer(new Position(new LineZone(new Point(0, 58), new Point(465, 58))));
            emitter.addInitializer(new Velocity(new PointZone(new Point(0, 65))));
            emitter.addInitializer(new ScaleImageInit(miniScale, maxScale));
            emitter.addAction(new Move());
            emitter.addAction(new DeathZone(new RectangleZone( 0, 0, 465, 407 ), true));
            emitter.addAction(new RandomDrift(30, 15 ));
            return emitter;
        }
    }
}