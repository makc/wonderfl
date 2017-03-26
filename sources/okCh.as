// forked from yonatan's Minecraft4kAS Extreme Hills Map + Sunlight
// forked from Albert's forked from: forked from: forked from: Minecraft4kAS Extreme Hills Map
// forked from Albert's forked from: forked from: Minecraft4kAS Extreme Hills Map
// forked from Albert's forked from: Minecraft4kAS Extreme Hills Map
// forked from bkzen's Minecraft4kAS Extreme Hills Map
// forked from yonatan's Minecraft4kAS
// ported from notch's javascript version: http://jsdo.it/notch/dB1E
// added some brightness change (shadow) on top of the tiles if needed.
// added water and waterlevel input
// added fake (and wrong) ambient shadow
// changed fog as yonatan did: http://wonderfl.net/c/dl6u
// added some flora (bushes) and flora input

package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.utils.*;
    //import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0", frameRate="60")]
    public class main extends Sprite {
        private var w:int = 200;
        private var h:int = 200;
        private var bmd: BitmapData = new BitmapData(w, h, true, 0);
        private var bmp: Bitmap = new Bitmap(bmd);

        private var f: int = 0;
        private var label: TextField = new TextField();
        private var input: TextField = new TextField();
        private var labelwater: TextField = new TextField();
        private var inputwater: TextField = new TextField();
        private var labelflora: TextField = new TextField();
        private var inputflora: TextField = new TextField();

        private var map: Vector.<int> = new Vector.<int>(256 * 64 * 64, true);
        private var texmap: Vector.<int> = new Vector.<int>(16 * 16 * 3 * 16, true);
        private var waitTimer:Timer;

        private var vpl:VolumetricPointLight;

        function main() {
            stage.quality = "medium";
            graphics.clear();
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 464, 464);
            graphics.beginFill(0x9bdeff);
            graphics.drawRect(32, 32, 400, 400);
            graphics.endFill();

            vpl = new VolumetricPointLight(w, h, bmp, [0xffffff, 0xffc080, 0x9bdeff], [0.25, 0.1, 0], [0, 40, 200]);
            vpl.emission.visible = false;
            vpl.scaleX = vpl.scaleY = 2;
            vpl.x = vpl.y = 32;
            vpl.setBufferSize(50*50);

            initTexMap();
            label.autoSize = "left", label.textColor = 0xffffff, label.text = "seed : ";
            input.textColor = 0xffffff, input.type = "input", input.restrict = "0-9";
            input.height = 30, input.width = 100, input.x = label.width + 10;
            initMap();
            addChild(label);
            addChild(input);
            input.addEventListener(Event.CHANGE, onChange);

            labelwater.autoSize = "left", labelwater.textColor = 0xffffff, labelwater.text = "waterlevel : "; labelwater.x = 150;
            inputwater.textColor = 0xffffff, inputwater.type = "input", inputwater.restrict = "0-9";
            inputwater.height = 30, inputwater.width = 100, inputwater.x = labelwater.x + labelwater.width + 10;
            addChild(labelwater);
            addChild(inputwater);
            inputwater.addEventListener(Event.CHANGE, onChange);

            labelflora.autoSize = "left", labelflora.textColor = 0xffffff, labelflora.text = "flora : "; labelflora.x = 300;
            inputflora.textColor = 0xffffff, inputflora.type = "input", inputflora.restrict = "0-9";
            inputflora.height = 30, inputflora.width = 100, inputflora.x = labelflora.x + labelflora.width + 10;
            addChild(labelflora);
            addChild(inputflora);
            inputflora.addEventListener(Event.CHANGE, onChange);

            waitTimer = new Timer(1000, 1);
            waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompTimer);
            addEventListener("enterFrame", renderMinecraft);

            addChild(vpl);
            //addChild(new Stats);
        }

        private function onChange(e: Event): void
        {
            removeEventListener(Event.ENTER_FRAME, renderMinecraft);
            waitTimer.reset();
            waitTimer.start();
        }

        private function onCompTimer(e: TimerEvent): void
        {
            initMap(int(input.text), int(inputwater.text), int(inputflora.text));
            addEventListener(Event.ENTER_FRAME, renderMinecraft);
        }

        private function initTexMap():void {
            for ( var i:int = 1; i < 16; i++) {
                var br:int = 255 - ((Math.random() * 96) | 0);
                for ( var y:int = 0; y < 16 * 3; y++) {
                    for ( var x:int = 0; x < 16; x++) {
                        var color:int = 0x966C4A;
                        if (i == 4)
                        color = 0x7F7F7F;
                        if (i != 4 || ((Math.random() * 3) | 0) == 0) {
                            br = 255 - ((Math.random() * 96) | 0);
                        }
                        if ((i == 1 && y < (((x * x * 3 + x * 81) >> 2) & 3) + 18)) {
                            color = 0x6AAA40;
                        } else if ((i == 1 && y < (((x * x * 3 + x * 81) >> 2) & 3) + 19)) {
                            br = br * 2 / 3;
                        }
                        if (i == 7) {
                            color = 0x675231;
                            if (x > 0 && x < 15
                                && ((y > 0 && y < 15) || (y > 32 && y < 47))) {
                                color = 0xBC9862;
                                var xd:int = (x - 7);
                                var yd:int = ((y & 15) - 7);
                                if (xd < 0)
                                xd = 1 - xd;
                                if (yd < 0)
                                yd = 1 - yd;
                                if (yd > xd)
                                xd = yd;

                                br = 196 - ((Math.random() * 32) | 0) + xd % 3 * 32;
                            } else if (((Math.random() * 2) | 0) == 0) {
                                br = br * (150 - (x & 1) * 100) / 100;
                            }
                        }

                        if (i == 5) {
                            color = 0xB53A15;
                            if ((x + (y >> 2) * 4) % 8 == 0 || y % 4 == 0) {
                                color = 0xBCAFA5;
                            }
                        }
                        if (i == 9) {
                            color = 0x4040ff;
                        }
                        var brr:int = br;
                        if (y >= 32)
                        brr /= 2;

                        if (i == 8) {
                            color = 0x50D937;
                            if (((Math.random() * 2) | 0) == 0) {
                                color = 0;
                                brr = 255;
                            }
                        }

                        var col:int = (((color >> 16) & 0xff) * brr / 255) << 16
                        | (((color >> 8) & 0xff) * brr / 255) << 8
                        | (((color) & 0xff) * brr / 255);
                        texmap[x + y * 16 + i * 256 * 3] = col;
                    }
                }
            }
        }

        private function initMap(s: int = 0, w: int = 0, f: int = 0): void {
            var noise: BitmapData = new BitmapData(64, 64, false);
            noise.lock();
            var p1: Point = new Point(), p2: Point = new Point();
            var offset: Array = [p1, p2];
            var seed: int = s || Math.random() * 0xFFFFFF;
            input.text = "" + seed;
            var waterlevel: int = w || 15 + Math.random() * 10;
            if (waterlevel > 22)
                waterlevel = 22; 
            inputwater.text = "" + waterlevel;
            var flora: int = f || Math.random() * 10000;
            inputflora.text = "" + flora;

            for ( var z: int = 0; z < 256; z++)
            {
                // 擬似PerlinNoise3D
                p1.x = z, p2.x = -z;
                noise.perlinNoise(32, 32, 2, seed, false, true, 7, true, offset);
                for ( var x: int = 0; x < 64; x++)
                {
                    for ( var y: int = 0; y < 64; y++)
                    {
                        var i:int = z << 12 | y << 6 | x;
                        var yd:Number = (y - 32.5 - Math.sin(Math.PI * 2 * (z % 256)/256)*10) * 0.4;
                        var xd:Number = (x - 32.5 - Math.sin(Math.PI * 2 * ((z+128) % 256)/256)*5) * 0.4;
                        map[i] = 4; //(Math.random() * 16) | 0;
                        if    ((Math.sqrt(Math.sqrt(yd * yd + xd * xd)) - 0.8 < 0.3 + (Math.random() * 0.1)) ||
                            ((noise.getPixel(x, y) & 0xFF) * 4 / 5) < ((64 - y) << 2))
                                map[i] = 0;
                            
                        //if (Math.random() > Math.sqrt(Math.sqrt(yd * yd + zd * zd)) - 0.8 ||
                            //map[i] = 0;
                    }
                }
            }
            noise.dispose();
           for ( z = 0; z < 256; z++)
           {
                for ( x = 0; x < 64; x++)
                {
                    for ( y = 0; y < 64; y++)
                    {

                        i = z << 12 | y << 6 | x;
                        if (map[i] == 0 && y>64-waterlevel)
                            map[i] = 9;
                        else
                        if (map[i] != 0)
                       {
                            var j:int = z << 12 | (y-1) << 6 | x;
                            if (map[j] == 0)
                                map[i] = 1;
                            else
                           {
                               j = z << 12 | (y-2) << 6 | x;
                               if (map[j] == 0)
                                   map[i] = 2;
                               else
                                   map[i] = Math.random()*3+2;
                           }
                        }
                    }
                }
            }

            for ( var b: int = 0; b < flora; b++ )
           {
               x = Math.random()*64;
               y = Math.random()*64;
               z = Math.random()*256;

               i = z << 12 | (y+1) << 6 | x;
               var c:int = map[i];
               i = z << 12 | y << 6 | x;
               var c2:int = map[i];
               if (c2 != 0)
              {
                   y--;
                   i = z << 12 | y << 6 | x;
                   c2 = map[i];
                   while (c2 != 0 && y>1)
                  {
                      y--;
                       i = z << 12 | y << 6 | x;
                       c=c2;
                       c2 = map[i];
                      //c2 = 0;
                  }
               }
               if (c2==0 && c!=9 && c!=0)
                  map[i] = 8;
           }


        }

        private function renderMinecraft(e: Event): void {
            var speed: int = 20000;
            var xRot:Number = Math.sin(getTimer() % speed / speed * Math.PI * 2) * 0.4;
            var yRot:Number = Math.sin((getTimer() * 1.1) % speed / speed * Math.PI * 2) * 0.3 - Math.PI / 16;
            var yCos:Number = Math.cos(yRot);
            var ySin:Number = Math.sin(yRot);
            var xCos:Number = Math.cos(xRot);
            var xSin:Number = Math.sin(xRot);

            speed = 40000;
            var oz:Number = 32.5 + getTimer() % speed / speed * 256;
            var oy:Number = 32.5 + Math.sin(Math.PI * 2 * (oz % 256)/256)*10; // Math.sin(Math.PI * 2 * i / 256) * 100
            var ox:Number = 32.5 + Math.sin(Math.PI * 2 * ((oz+ 128) % 256)/256)*5;

            f++;
            for ( var x:int = 0; x < w; x++) {
                var ___xd:Number = (x - w / 2) / h;
                for ( var y:int = 0; y < h; y++) {
                    var __yd:Number = (y - h / 2) / h;
                    var __zd:Number = 1;

                    var ___zd:Number = __zd * yCos + __yd * ySin;
                    var _yd:Number = __yd * yCos - __zd * ySin;

                    var _xd:Number = ___xd * xCos + ___zd * xSin;
                    var _zd:Number = ___zd * xCos - ___xd * xSin;

                    var col:int = 0;
                    var br:int = 255;
                    var ddist:int = 0;

                    var closest:Number = 32;
                    for ( var d:int = 0; d < 3; d++) {
                        var dimLength:Number = _xd;
                        if (d == 1)
                        dimLength = _yd;
                        if (d == 2)
                        dimLength = _zd;

                        var ll:Number = 1 / (dimLength < 0 ? -dimLength : dimLength);
                        var xd:Number = (_xd) * ll;
                        var yd:Number = (_yd) * ll;
                        var zd:Number = (_zd) * ll;

                        var initial:Number = ox - (ox | 0);
                        if (d == 1)
                        initial = oy - (oy | 0);
                        if (d == 2)
                        initial = oz - (oz | 0);
                        if (dimLength > 0)
                        initial = 1 - initial;

                        var dist:Number = ll * initial;

                        var xp:Number = ox + xd * initial;
                        var yp:Number = oy + yd * initial;
                        var zp:Number = oz + zd * initial;

                        if (dimLength < 0) {
                            if (d == 0)
                            xp--;
                            if (d == 1)
                            yp--;
                            if (d == 2)
                            zp--;
                        }

                        while (dist < closest) {
                            var tex:int = map[(zp & 255) << 12 | (yp & 63) << 6 | (xp & 63)];

                            if (tex > 0) {
                                var u:int = ((xp + zp) * 16) & 15;
                                var v:int = ((yp * 16) & 15) + 16;
                                if (d == 1) {
                                    u = (xp * 16) & 15;
                                    v = (zp * 16) & 15;
                                    if (yd < 0)
                                    v += 32;
                                }

                                var cc:int = texmap[u + v * 16 + tex * 768];
                                if (cc > 0) {
                                    col = cc;
                                    closest = dist;
                                    ddist = 255 - int(dist * 7.96875);
                                    br = (d==0 ? 155 : (d==1 ? 255 : 205));
                                    if (d == 1)
                                    {
                                        var maxsh:Number = 0.4;
                                        var shcorner:int = 12;
                                        tex = map[((zp-1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp-1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (u+v)/shcorner));
                                        tex = map[((zp+1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp-1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (u+16-v)/shcorner));
                                        tex = map[((zp-1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp+1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (16-u+v)/shcorner));
                                        tex = map[((zp+1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp+1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (16-u+16-v)/shcorner));

                                        var sh:int = 12;
                                        tex = map[((zp) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp-1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (u)/sh));
                                        tex = map[((zp) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp+1) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (16-u)/sh));
                                        tex = map[((zp-1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (v)/sh));
                                        tex = map[((zp+1) & 255) << 12 | ((yp-1) & 63) << 6 | ((xp) & 63)];
                                        if (tex>0)
                                            br *= Math.max(maxsh, Math.min(1.0, (16-v)/sh));

                                        br = Math.max(br, 120);
                                        //br = 255;
                                    }
                                }
                                if (d == 1)
                               {
                                    tex = map[(zp & 255) << 12 | ((yp-1) & 63) << 6 | (xp & 63)];
                                    if (tex > 0)
                                        br *= 0.4;
                                    else
                                   {
                                        tex = map[(zp & 255) << 12 | ((yp-2) & 63) << 6 | (xp & 63)];
                                        if (tex > 0)
                                            br *= 0.5;
                                        else
                                       {
                                        tex = map[(zp & 255) << 12 | ((yp-3) & 63) << 6 | (xp & 63)];
                                        if (tex > 0)
                                            br *= 0.7;
                                       }
                                   }
                                }
                            }
                            xp += xd;
                            yp += yd;
                            zp += zd;
                            dist += ll;
                        }
                    }

                    var r:int = ((col >> 16) & 0xff) * br * ddist / (255 * 255);
                    var g:int = ((col >> 8) & 0xff) * br * ddist / (255 * 255);
                    var b:int = ((col) & 0xff) * br * ddist / (255 * 255);
                    if(ddist <= 155) r += 155-ddist;
                    if(ddist <= 222) g += 222-ddist;
                    if(ddist <= 255) b += 255-ddist;

                    if(col) bmd.setPixel32(x, y, 0xff000000 | r << 16 | g << 8 | b);
                    else bmd.setPixel32(x, y, 0);
                }
            }

            vpl.srcX = w/2 + Math.cos(xRot + Math.PI/2) * w * 2;
            vpl.srcY = h/2 + Math.sin(yRot-Math.PI/24) * h * 2;
            if(vpl.srcX > 0 || vpl.srcY > 0 || vpl.srcX < w || vpl.srcY < h) {
                if(vpl.srcX < 40 || vpl.srcY < 40 || w-vpl.srcX < 40 || h-vpl.srcY < 40) {
                    var distFromEdge:Number = Math.min(vpl.srcX, vpl.srcY, w-vpl.srcX, h-vpl.srcY);
                    vpl.rays.alpha = distFromEdge / 20;
                } else {
                    vpl.rays.alpha = 1;
                }
                vpl.render();
            }
        }
    }
}

// --- https://github.com/yonatan/volumetrics

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;

class EffectContainer extends Sprite {
    public var blur:Boolean = false;
    public var colorIntegrity:Boolean = false;
    public var intensity:Number = 4;
    public var passes:uint = 6;
    public var rasterQuality:String = null;
    public var scale:Number = 2;
    public var smoothing:Boolean = true;
    public var srcX:Number;
    public var srcY:Number;

    protected var _blurFilter:BlurFilter = new BlurFilter(2, 2);
    protected var _emission:DisplayObject;
    protected var _occlusion:DisplayObject;
    protected var _ct:ColorTransform = new ColorTransform;
    protected var _halve:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
    protected var _occlusionLoResBmd:BitmapData;
    protected var _occlusionLoResBmp:Bitmap;
    protected var _baseBmd:BitmapData;
    protected var _bufferBmd:BitmapData;
    protected var _lightBmp:Bitmap = new Bitmap;
    protected var _bufferSize:uint = 0x8000;
    protected var _bufferRect:Rectangle = new Rectangle;
    protected var _viewportWidth:uint;
    protected var _viewportHeight:uint;
    protected var _mtx:Matrix = new Matrix;
    protected var _zero:Point = new Point;

    public function EffectContainer(width:uint, height:uint, emission:DisplayObject, occlusion:DisplayObject = null) {
        if(!emission) throw(new Error("emission DisplayObject must not be null."));
        addChild(_emission = emission);
        if(occlusion) addChild(_occlusion = occlusion);
        setViewportSize(width, height);
        _lightBmp.blendMode = BlendMode.ADD;
        addChild(_lightBmp);
        srcX = width / 2;
        srcY = height / 2;
    }

    // extra getters
    public function get emission():DisplayObject { return _emission; }
    public function get occlusion():DisplayObject { return _occlusion; }
    public function get rays():Bitmap { return _lightBmp; }

    public function setViewportSize(width:uint, height:uint):void {
        _viewportWidth = width;
        _viewportHeight = height;
        scrollRect = new Rectangle(0, 0, width, height);
        _updateBuffers();
    }

    public function setBufferSize(size:uint):void {
        _bufferSize = size;
        _updateBuffers();
    }

    protected function _updateBuffers():void {
        var aspect:Number = _viewportWidth / _viewportHeight;
        _bufferRect.height = int(Math.max(1, Math.sqrt(_bufferSize / aspect)));
        _bufferRect.width  = int(Math.max(1, _bufferRect.height * aspect));
        dispose();
        _baseBmd           = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _bufferBmd         = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _occlusionLoResBmd = new BitmapData(_bufferRect.width, _bufferRect.height, true, 0);
        _occlusionLoResBmp = new Bitmap(_occlusionLoResBmd);
    }

    public function render(e:Event = null):void {
        if(!(_lightBmp.visible = intensity > 0)) return;
        var savedQuality:String = stage.quality;
        if(rasterQuality) stage.quality = rasterQuality;
        var mul:Number = colorIntegrity ? intensity : intensity/(1<<passes);
        _ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
        _drawLoResEmission();
        if(_occlusion) _eraseLoResOcclusion();
        if(rasterQuality) stage.quality = savedQuality;
        var s:Number = 1 + (scale-1) / (1 << passes);
        var tx:Number = srcX/_viewportWidth*_bufferRect.width;
        var ty:Number = srcY/_viewportHeight*_bufferRect.height;
        _mtx.identity();
        _mtx.translate(-tx, -ty);
        _mtx.scale(s, s);
        _mtx.translate(tx, ty);
        _applyEffect(_baseBmd, _bufferRect, _bufferBmd, _mtx, passes);
        _lightBmp.bitmapData = _baseBmd;
        _lightBmp.width = _viewportWidth;
        _lightBmp.height = _viewportHeight;
        _lightBmp.smoothing = smoothing;
    }

    protected function _drawLoResEmission():void {
        _copyMatrix(_emission.transform.matrix, _mtx);
        _mtx.scale(_bufferRect.width / _viewportWidth, _bufferRect.height / _viewportHeight);
        _baseBmd.fillRect(_bufferRect, 0);
        _baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
    }

    protected function _eraseLoResOcclusion():void {
        _occlusionLoResBmd.fillRect(_bufferRect, 0);
        _copyMatrix(_occlusion.transform.matrix, _mtx);
        _mtx.scale(_bufferRect.width / _viewportWidth, _bufferRect.height / _viewportHeight);
        _occlusionLoResBmd.draw(_occlusion, _mtx);
        _baseBmd.draw(_occlusionLoResBmp, null, null, BlendMode.ERASE);
    }

    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, render);
    }

    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, render);
    }

    protected function _applyEffect(bmd:BitmapData, rect:Rectangle, buffer:BitmapData, mtx:Matrix, passes:uint):void {
        while(passes--) {
            if(colorIntegrity) bmd.colorTransform(rect, _halve);
            buffer.copyPixels(bmd, rect, _zero);
            bmd.draw(buffer, mtx, null, BlendMode.ADD, null, true);
            mtx.concat(mtx);
        }
        if(colorIntegrity) bmd.colorTransform(rect, _ct);
        if(blur) bmd.applyFilter(bmd, rect, _zero, _blurFilter);
    }

    public function dispose():void {
        if(_baseBmd) _baseBmd.dispose();
        if(_occlusionLoResBmd) _occlusionLoResBmd.dispose();
        if(_bufferBmd) _bufferBmd.dispose();
        _baseBmd = _occlusionLoResBmd = _bufferBmd = _lightBmp.bitmapData = null;
    }

    protected function _copyMatrix(src:Matrix, dst:Matrix):void {
        dst.a = src.a;
        dst.b = src.b;
        dst.c = src.c;
        dst.d = src.d;
        dst.tx = src.tx;
        dst.ty = src.ty;
    }
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;

class VolumetricPointLight extends EffectContainer {
    protected var _colors:Array;
    protected var _alphas:Array;
    protected var _ratios:Array;
    protected var _gradient:Shape = new Shape;
    protected var _gradientMtx:Matrix = new Matrix;
    protected var _gradientBmp:Bitmap = new Bitmap;
    protected var _lastSrcX:Number;
    protected var _lastSrcY:Number;
    protected var _lastIntensity:Number;
    protected var _lastColorIntegrity:Boolean = false;
    protected var _gradientLoResBmd:BitmapData;
    protected var _gradientLoResDirty:Boolean = true;

    public function VolumetricPointLight(width:uint, height:uint, occlusion:DisplayObject, colorOrGradient:*, alphas:Array = null, ratios:Array = null) {
        if(colorOrGradient is Array) {
            _colors = colorOrGradient.concat();
            _ratios = ratios || _colors.map(function(item:*, i:int, arr:Array):int { return 0x100*i/(colorOrGradient.length+i-1) });
            _alphas = alphas || _colors.map(function(..._):Number { return 1 });
        } else {
            _colors = [colorOrGradient, 0];
            _ratios = [0, 255];
        }
        super(width, height, _gradientBmp, occlusion);
        if(!occlusion) throw(new Error("An occlusion DisplayObject must be provided."));
        if(!(colorOrGradient is Array || colorOrGradient is uint)) throw(new Error("colorOrGradient must be either an Array or a uint."));
    }

    protected function _drawGradient():void {
        var size:Number = 2 * Math.sqrt(_viewportWidth*_viewportWidth + _viewportHeight*_viewportHeight);
        _gradientMtx.createGradientBox(size, size, 0, -size/2 + srcX, -size/2 + srcY);
        _gradient.graphics.clear();
        _gradient.graphics.beginGradientFill(GradientType.RADIAL, _colors, _alphas, _ratios, _gradientMtx);
        _gradient.graphics.drawRect(0, 0, _viewportWidth, _viewportHeight);
        _gradient.graphics.endFill();
        if(_gradientBmp.bitmapData) _gradientBmp.bitmapData.dispose();
        _gradientBmp.bitmapData = new BitmapData(_viewportWidth, _viewportHeight, true, 0);
        _gradientBmp.bitmapData.draw(_gradient);
    }

    override protected function _drawLoResEmission():void {
        if(_gradientLoResDirty) {
            super._drawLoResEmission();
            _gradientLoResBmd.copyPixels(_baseBmd, _bufferRect, _zero);
            _gradientLoResDirty = false;
        } else {
            _baseBmd.copyPixels(_gradientLoResBmd, _bufferRect, _zero);
        }
    }

    override protected function _updateBuffers():void {
        super._updateBuffers();
        _gradientLoResBmd = new BitmapData(_bufferRect.width, _bufferRect.height, false, 0);
        _gradientLoResDirty = true;
    }

    override public function setViewportSize(width:uint, height:uint):void {
        super.setViewportSize(width, height);
        _drawGradient();
        _gradientLoResDirty = true;
    }

    override public function render(e:Event = null):void {
        var srcChanged:Boolean = _lastSrcX != srcX || _lastSrcY != srcY;
        if(srcChanged) _drawGradient();
        _gradientLoResDirty ||= srcChanged;
        _gradientLoResDirty ||= (!colorIntegrity && (_lastIntensity != intensity));
        _gradientLoResDirty ||= (_lastColorIntegrity != colorIntegrity);
        _lastSrcX = srcX;
        _lastSrcY = srcY;
        _lastIntensity = intensity;
        _lastColorIntegrity = colorIntegrity;
        super.render(e);
    }

    override public function dispose():void {
        super.dispose();
        if(_gradientLoResBmd) _gradientLoResBmd.dispose();
        _gradientLoResBmd = null;
    }
}
