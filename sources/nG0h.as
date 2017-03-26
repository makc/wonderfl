// forked from bkzen's Sound
/**
 * sound from @gaina
 * @author jc at bk-zen.com
 */
package 
{
    import flash.display.*;
    import flash.geom.*;
    import flash.filters.*;
    import flash.events.MouseEvent;
    import flash.utils.ByteArray;
    import flash.media.SoundMixer;
    import flash.events.Event;
    import frocessing.color.ColorHSV;
    import net.hires.debug.Stats;

    [SWF (backgroundColor = "0x000000", frameRate = "30", width = "465", height = "465")]
    public class FlashTest extends Sprite 
    {
        private var shape: Shape;
        private var _byte: ByteArray;
        private var color: uint;
        private var colorHSV: ColorHSV = new ColorHSV(Math.random() * 360);
        private var afterChangeColor: Boolean;
        private var stageWidth: uint;
        private var stageHeight: uint;
        private var root3D: Sprite = new Sprite;
        private var sphere: Sphere;
        private var fxBase: BitmapData = new BitmapData(fxW, fxH, true, 0);
        private var fxTmp: BitmapData = new BitmapData(fxW, fxH, true, 0);
        private var fxW: int = 0x100, fxH: int = 0x100;
        private var fxOut:Bitmap = new Bitmap;
        private var fxct:ColorTransform = new ColorTransform(0.08, 0.08, 0.08, 1, 4, 4, 4);
        private var scaleUp: Matrix = new Matrix, scaleDown: Matrix  = new Matrix;
        private var blur:BlurFilter = new BlurFilter;
        private var stats:Stats = new Stats;

        public function FlashTest()
        {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void
        {
            addChild(root3D);
            root3D.visible = false;
            addChild(fxOut);
            addChild(shape = new Shape());
            shape.blendMode = "add";
            root3D.addChild(sphere = new Sphere);
            var _sound:PlaySound = new PlaySound("http://www.takasumi-nagai.com/soundfiles/sound007.mp3");
            _byte = new ByteArray();
            addEventListener(Event.ENTER_FRAME, frame);
            stage.addEventListener(Event.RESIZE, onResize)
            stage.addEventListener(MouseEvent.CLICK, onClick);
            onResize();
            changeColor();
            stats.visible = false;
            // addChild(stats);
        }
        private function onResize(e: Event = null): void
        {
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;
            graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0, 0, stageWidth, stageHeight);
            root3D.x = stageWidth/2;
            root3D.y = stageHeight/2;

            scaleDown.identity(); 
            scaleDown.translate(stageWidth/2, stageHeight/2); 
            scaleDown.scale(fxW/stageWidth, fxH/stageHeight);
            scaleUp.identity(); 
            scaleUp.scale(stageWidth/fxW, stageHeight/fxH);
            fxOut.transform.matrix = scaleUp;
        }
        
        private function frame(e: Event): void 
        {
            if (afterChangeColor) changeColor();
            var g:Graphics = shape.graphics;
            SoundMixer.computeSpectrum(_byte, true, 0);
            var i: int;
            var n: Number = 0;
            var size: int = stageWidth >> 6;
            var centerX: int = stageWidth  >> 1;
            var centerY: int = stageHeight >> 1;
            g.clear();
            var p: Number = 0;
            while (i++ < 32)
            {
                n = _byte.readFloat();
                p += n;
                if (p > 8) afterChangeColor = true;
                g.beginFill(downColor(color, n), 1);
                g.drawCircle(centerX,  centerY, centerX - size * i);
                g.drawCircle(centerX,  centerY, centerX - size * (i-1));
                g.endFill();
            }
            sphere.rotationX += 5;
            sphere.rotationY += 3;
            sphere.cull();

            fxBase.fillRect(fxBase.rect, 0);
            fxBase.draw(root3D, scaleDown);
            fxBase.colorTransform(fxBase.rect, fxct);
            fxOut.bitmapData = process(fxBase);
        }

        private function process(src:BitmapData, cx:Number = 0, cy:Number = 0):BitmapData {
            var dst:BitmapData = fxTmp;
            var mtx:Matrix = new Matrix;
            var cnt:int = 6;
            mtx.identity();
            mtx.translate(-src.width / (1<<cnt), -src.height / (1<<cnt));
            mtx.translate(cx, cy);
            mtx.scale(1+1/(1<<cnt-1), 1+1/(1<<cnt-1));
            var tmp:BitmapData;
            src.lock(); dst.lock();
            while(cnt--) {
                mtx.concat(mtx);
                dst.copyPixels(src, src.rect, src.rect.topLeft);
                dst.draw(src, mtx, null, "add");
                dst.applyFilter(dst, dst.rect, dst.rect.topLeft, blur);
                tmp = src;
                src = dst;
                dst = tmp;
            }
            src.unlock(); dst.unlock();
            return src;
        }

        
        private function onClick(e: MouseEvent): void 
        {
            changeColor();
            stats.visible = !stats.visible;
        }
        
        private static function downColor(argb: uint, n: Number): uint
        {
            var alpha: uint = argb >> 24 & 0xFF;
            var r: uint = argb >> 16 & 0xFF;
            var g: uint = argb >> 8 & 0xFF;
            var b: uint = argb & 0xFF;
            return (alpha << 24) | (((r * n) & 0xFF) << 16) | (((g * n) & 0xFF) << 8) | ((b * n) & 0xFF);
        }
        
        private function changeColor():void 
        {
            afterChangeColor = false;
            colorHSV.h += Math.random() * 10 + 30;
            color = colorHSV.value;
        }
    }
}

import flash.display.*;
import flash.geom.*;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import frocessing.color.ColorHSV;

class PlaySound
{
    private var sound:Sound;

        public function PlaySound(url:String)
        {
            sound = new Sound();
            var _context:SoundLoaderContext = new SoundLoaderContext(1000, true);
            sound.addEventListener(Event.COMPLETE, SoundLoadeComplete);
            sound.load(new URLRequest(url), _context);
        }
        
        private function SoundLoadeComplete(e:Event):void 
        {
            sound.play(0, 10, new SoundTransform(0.3, 0));
        }
}

class Sphere extends Sprite {
    public function Sphere():void {   
        // layout from makc3d's Sphere made from planes, 3 - http://wonderfl.net/c/2drp
        var planeWidth:Number = 10;   
        var planeHength:Number = 15;   
        var radius:Number = 80;   
        var hsv:ColorHSV = new ColorHSV(1, 1, 1);
        // uniformly distributed directions:
        // Bauer, Robert, "Distribution of Points on a Sphere with Application to Star Catalogs",
        // Journal of Guidance, Control, and Dynamics, January-February 2000, vol.23 no.1 (130-137).
        var N:Number = 90;
        for (var i:int = 1; i <= N; i++) {
            var phi:Number = Math.acos ( -1 + (2 * i -1) / N);
            var theta:Number = Math.sqrt (N * Math.PI) * phi;
            var alpha:Number = phi;   
            var z:Number = radius*Math.cos(alpha);
            var xy:Number = radius*Math.sin(alpha);   
            var beta:Number = theta;   
            var x:Number = -xy*Math.sin(beta);   
            var y:Number = xy*Math.cos(beta);

            hsv.h = 360 * i/N + (i&1)*60;
            var circle:Shape = newCircle(hsv.value);
            circle.x = x; circle.y = y; circle.z = z;
            circle.rotationX = -alpha / Math.PI * 180;   
            circle.rotationZ = beta / Math.PI * 180;   
            addChild(circle);
        }
    }

    public function cull():void {
        var v3D:Vector3D = new Vector3D;
        for(var i:int = 0; i < numChildren; i++) {
            var child:DisplayObject = getChildAt(i);
            v3D.x = child.x; v3D.y = child.y; v3D.z = child.z;
            var scr:Vector3D = transform.matrix3D.transformVector(v3D);
            child.visible = scr.z < -10;
        }
    }

    private function newCircle(color:uint = 0x00ff00, radius:Number = 5):Shape {
        var s:Shape = new Shape;
        s.graphics.beginFill(color);
        s.graphics.drawCircle(0, 0, radius);
        s.graphics.endFill();
        return s;
    }
}