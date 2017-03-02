package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        // derived from http://en.wikipedia.org/wiki/File:7_segment_display_labeled.svg
        private static const SEGMENTS:Array = [190.79731, 72.5, 175.58534, 88, 116.58535, 88, 101.06756, 72.5, 116.58535, 57, 175.58534, 57, 190.79731, 72.5, 190.79731, 154, 175.58534, 169.5, 116.58535, 169.5, 101.06756, 154, 116.58535, 138.5, 175.58534, 138.5, 190.79731, 154, 98, 75.38513, 113.5, 90.59709, 113.5, 135.59708, 98, 151.11487, 82.5, 135.59708, 82.5, 90.59709, 98, 75.38513, 194, 75.38513, 209.5, 90.59709, 209.5, 135.59708, 194, 151.11487, 178.5, 135.59708, 178.5, 90.59709, 194, 75.38513, 190.79731, 236.05743, 175.58534, 251.55743, 116.58535, 251.55743, 101.06756, 236.05743, 116.58535, 220.55743, 175.58534, 220.55743, 190.79731, 236.05743, 98, 157.44257, 113.5, 172.65453, 113.5, 217.65452, 98, 233.1723, 82.5, 217.65452, 82.5, 172.65453, 98, 157.44257, 194, 157.44257, 209.5, 172.65453, 209.5, 217.65452, 194, 233.1723, 178.5, 217.65452, 178.5, 172.65453, 194, 157.44257];
        private static const ENCODING:Array = [[true, false, true, true, true, true, true], [false, false, false, true, false, false, true], [true, true, false, true, true, true, false], [true, true, false, true, true, false, true], [false, true, true, true, false, false, true], [true, true, true, false, true, false, true], [true, true, true, false, true, true, true], [true, false, false, true, false, false, true], [true, true, true, true, true, true, true], [true, true, true, true, true, false, true]];
        private static const WIDTH:int = 416;
        private static const HEIGHT:int = 162;
        private static const COLOR:uint = 0x80ff20;
        private static const CANVAS:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
        private static const ORIGIN:Point = new Point(0, 0);
        private static const DOUBLE:ColorTransform = new ColorTransform(2, 2, 2);
        private static const START:Matrix = new Matrix(0.5, 0, 0, 0.5, -9, 4);
        private static const DIFFUSION_BLUR:BlurFilter = new BlurFilter(32, 32, 3);
        private static const BLOOM_BLUR:BlurFilter = new BlurFilter(8, 8, 2);
        
        private const segments:Array = prepareSegments();
        private const colon:Shape = prepareColon();
        private const diffuser:BitmapData = prepareDiffuser();
        private const cover:Shape = prepareCover();
        private var prevMinutes:int;
        
        private function prepareSegments():Array {
            // turns the coordinates don't go in the abcdefg order. it's currently agfbdec. \:
            var a:Array = [];
            var k:int = 0;
            for (var i:int = 0; i < 7; i++) {
                var s:Shape = new Shape();
                var g:Graphics = s.graphics;
                g.beginFill(COLOR);
                g.moveTo(SEGMENTS[k++], SEGMENTS[k++]);
                for (var j:int = 1; j < 7; j++) {
                    g.lineTo(SEGMENTS[k++], SEGMENTS[k++]);
                }
                g.endFill();
                a.push(s);
            }
            return a;
        }
        
        private function prepareColon():Shape {
            // I took the "DP" segment and translated it to be vertically centered next to b and c
            var s:Shape = new Shape();
            var g:Graphics = s.graphics;
            g.beginFill(COLOR);
            g.drawCircle(94.25, 195, 12.25);
            g.drawCircle(94.25, 112.5, 12.25);
            g.endFill();
            return s;
        }
        
        private function prepareDiffuser():BitmapData {
            // a layer of grease and dust diffuses the light
            var bd:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
            
            // cloudiness
            bd.perlinNoise(128, 128, 4, Math.random() * 0xfffffff, false, true, 7, true);
            
            // splatters
            var s:Shape = new Shape();
            for (var i:int = 0; i < 10; i++) {
                var cx:Number = Math.random() * WIDTH;
                var cy:Number = Math.random() * HEIGHT;
                var r:Number = Math.random() * 13 + 2;
                
                s.graphics.clear();
                s.graphics.beginFill(0x808080);
                s.graphics.drawRect(0, 0, WIDTH, HEIGHT);
                s.graphics.lineStyle(2, 0xffffff);
                s.graphics.beginFill(0x404040);
                s.graphics.drawCircle(cx, cy, r);
                bd.draw(s, null, null, BlendMode.MULTIPLY);
                bd.colorTransform(CANVAS, DOUBLE);
            }
            
            // graininess
            var specs:BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0x000000);
            specs.noise(Math.random() * 0xfffffff, 0, 255, 7, true);
            specs.colorTransform(CANVAS, new ColorTransform(0.5, 0.5, 0.5, 1, 128, 128, 128));
            specs.draw(specs, null, null, BlendMode.MULTIPLY);
            specs.draw(specs, null, null, BlendMode.MULTIPLY);
            bd.draw(specs, null, null, BlendMode.MULTIPLY);
            
            return bd;
        }
        
        private function prepareCover():Shape {
            var s:Shape = new Shape();
            var g:Graphics = s.graphics;
            g.lineStyle(4, 0xffffff);
            g.drawRoundRect(-WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT, 32, 32);
            return s;
        }
        
        private var axis:Sprite;
        private var stack:Sprite;
        private var main:Bitmap;
        private var bloom:Bitmap;
        private var mirror1:Bitmap;
        private var mirror2:Bitmap;
        private var glare:Bitmap;
        
        public function FlashTest() {
            // use black for capture
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            
            // the main layer is the brightest part
            main = new Bitmap(new BitmapData(WIDTH, HEIGHT, false, 0x000000));
            main.blendMode = BlendMode.ADD;
            main.alpha = 0.75;
            main.x = -WIDTH / 2;
            main.y = -HEIGHT / 2;
            main.z = 32;
            
            // the bloom layer adds some glow to the main layer
            bloom = new Bitmap(main.bitmapData);
            bloom.filters = [BLOOM_BLUR];
            bloom.blendMode = BlendMode.ADD;
            bloom.alpha = 0.25;
            bloom.x = -WIDTH / 2;
            bloom.y = -HEIGHT / 2;
            bloom.z = 32;
            
            // internal reflection causes gosts to be visible behind the clock
            mirror1 = new Bitmap(main.bitmapData);
            mirror1.blendMode = BlendMode.ADD;
            mirror1.alpha = 1. / 6;
            mirror1.x = -WIDTH / 2;
            mirror1.y = -HEIGHT / 2;
            mirror1.z = 64;
            
            mirror2 = new Bitmap(main.bitmapData);
            mirror2.blendMode = BlendMode.ADD;
            mirror2.alpha = 1. / 36;
            mirror2.x = -WIDTH / 2;
            mirror2.y = -HEIGHT / 2;
            mirror2.z = 96;
            
            // a layer of grease and dust diffuses the light somewhat
            glare = new Bitmap(new BitmapData(WIDTH, HEIGHT, false, 0x000000));
            glare.blendMode = BlendMode.ADD;
            glare.x = -WIDTH / 2;
            glare.y = -HEIGHT / 2;
            
            // this sprite arranges everything in world space
            stack = new Sprite();
            stack.addChild(mirror2);
            stack.addChild(mirror1);
            stack.addChild(main);
            stack.addChild(bloom);
            stack.addChild(glare);
            stack.addChild(cover);
            
            // another wrapper allows us to rotate around Y before X
            axis = new Sprite();
            axis.addChild(stack);
            axis.x = stage.stageWidth / 2;
            axis.y = stage.stageHeight / 2;
            axis.z = 128;
            
            addChild(axis);
            
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function drawDiffuse(n:Array):void {
            // clear main canvas
            main.bitmapData.fillRect(CANVAS, 0x000000);
            // draw plain segments
            drawSegments(main.bitmapData, n);
            // create blurred copy
            glare.bitmapData.applyFilter(main.bitmapData, CANVAS, ORIGIN, DIFFUSION_BLUR);
            // multiply static diffusion layer for texture
            glare.bitmapData.draw(diffuser, null, null, BlendMode.MULTIPLY);
            // turned out too dim, so just brighten it, lol
            glare.bitmapData.colorTransform(CANVAS, DOUBLE);
        }
        
        private function drawSegments(dst:BitmapData, n:Array):void {
            var m:Matrix = START.clone();
            for (var i:int = 0; i < 4; i++) {
                var e:Array = ENCODING[n[i]];
                for (var j:int = 0; j < 7; j++) {
                    if (e[j]) dst.draw(segments[j], m);
                }
                m.tx += 96;
            }
            m.tx = START.tx + 169.875;
            dst.draw(colon, m);
        }
        
        private function frame(e:Event):void {
            // rotate by mouse
            axis.rotationX = -(stage.mouseY / stage.stageHeight - 0.5) * 60;
            stack.rotationY = (stage.mouseX / stage.stageWidth - 0.5) * 60;
            
            // update display if time has changed
            var d:Date = new Date();
            var h:int = d.getHours() % 12; // lol USA
            var m:int = d.getMinutes();
            if (m != prevMinutes) {
                drawDiffuse([int(h / 10), h % 10, int(m / 10), m % 10]);
                prevMinutes = m;
            }
        }
        
    }
}