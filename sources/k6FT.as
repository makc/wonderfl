// forked from _mutast's ビートを検知してpv3dでエフェクト

// Wonderfl won't let me change the license, but most of 
// _mutast's original code is gone (see the diff).
//
// I don't know (or care) what that implies legally, but
// as far as I'm concerned you can do whatever you want
// with the code.

package 
{
    /**
    * ...
    * @author swc
    * 音はTsabeat より拝借
    * http://www.ektoplazm.com/free-music/tsabeat-warp-speed-ep/
    */

    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.media.*;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.utils.*;
    import flash.geom.*;
    import mx.utils.*;
    import caurina.transitions.Tweener;

    [SWF(backgroundColor="#000000", frameRate=30)]
    public class  Main extends Sprite {
        private var channel:SoundChannel;
        private var trans:SoundTransform;
        private var mySound:Sound;
        private var beats:Number = 0;

        private var shader:Shader;
        private var filter:ShaderFilter;

        public static const SIZE:Number = 465/2;
        public var r:Number = 0;
        public var br:Number = 1;
        public var exp:Number = 20;
        public var offset:Number = 0;
        
        public var cvs:Bitmap;
        public var bmd:BitmapData;
        
        public function Main() {
            stage.quality = "low";
            Wonderfl.capture_delay(15);
            Security.loadPolicyFile("http://mutast.heteml.jp/crossdomain.xml");
            mySound = new Sound();
            mySound.addEventListener(Event.COMPLETE, play);
            mySound.load(new URLRequest("http://mutast.heteml.jp/works/music/music.mp3"));
            init();
        }

        public function init():void {
            var dec:Base64Decoder = new Base64Decoder;
            dec.decode(shaderString);
            filter = new ShaderFilter(shader = new Shader(dec.drain()));
            shader.data["size"]["value"] = [SIZE, SIZE];
            shader.data["center1"]["value"] = [SIZE/2, SIZE/2, 1];
            shader.data["center2"]["value"] = [SIZE/2, SIZE/2, 1];
            shader.data["center3"]["value"] = [SIZE/2, SIZE/2, 1];

            bmd = new BitmapData(SIZE, SIZE);
            cvs = new Bitmap(bmd);
            cvs.scaleX = cvs.scaleY = 2;
            addChild(cvs);

            exp = 0;
            Tweener.addTween(this, {r: SIZE/4, br: 1000, exp: 20, time: 10, transition: "easeInSine"});
            addEventListener(Event.ENTER_FRAME, loop);
        }

        public function play(e:Event):void {
            var channel:SoundChannel = new SoundChannel();
            channel = mySound.play();
            channel.addEventListener(Event.SOUND_COMPLETE, byebye);
        }

        public function byebye(e:Event):void {
            Tweener.addTween( this, {
                    exp: 0,
                    offset: 20,
                    r: 0,
                    br: 1,
                    delay: 0.2,
                    time: 10,
                    transition: "easeOutSine",
                    onComplete: function():void { 
                        removeEventListener(Event.ENTER_FRAME, loop);
                    }
                });
        }

        public function hit():void {
            if (!beats) {
                Tweener.removeAllTweens();
            }
            beats++;
            exp = 0;
            Tweener.addTween(this, { 
                    offset: Math.random() * (beats%2 ? 2 : -2), 
                    time: 0.36, transition: "easeInQuart",
                    br: Math.random() * 1500 + 300, 
                    r: Math.random() * SIZE / 4 + SIZE / 6 });
        }

        public function loop(e:Event):void {
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, false, 0);
            bytes.position = 0;
            var rf:Number;
            var count:int = 0;
            for (var q:int = 0; bytes.bytesAvailable >= 4; q++) {
                rf = bytes.readFloat();
                var t:Number = Math.abs(rf);
                if (t >= 0.4 && q >256) {
                    count ++;
                }
                if (count >= 110) {
                    hit();
                }
            }

            var time:Number = offset + getTimer() / 600;

            var s:Function = Math.sin;
            var c:Function = Math.cos;
            var pi:Number = Math.PI;
            var ctr:Number = SIZE/2;
            var t1:Number = time;
            var t2:Number = time + 3.14 * 2 / 3;
            var t3:Number = time + 3.14 * 4 / 3;
            
            shader.data["size"]["value"] = [SIZE, SIZE];
            shader.data["exponent"]["value"] = [exp];
            if(beats) {
                var pow:Number = Math.max(0, 15 - count/150*15);
                if( exp < pow ) {
                    exp  = (exp*11+pow) / 12;
                } else {
                    exp = pow;
                }
                shader.data["center1"]["value"] = [ctr + r*s(t1) - r/3*c(t1*1.5), ctr - r*c(t1) + r/4*s(t1*1.5), br + br * s(t1) / 2];
                shader.data["center2"]["value"] = [ctr + r*s(t2) - r/3*c(t2*1.5), ctr - r*c(t2) + r/4*s(t2*1.5), br + br * s(t2) / 2];
                shader.data["center3"]["value"] = [ctr + r*s(t3) - r/3*c(t3*1.5), ctr - r*c(t3) + r/4*s(t3*1.5), br + br * s(t3) / 2];
            } else {
                shader.data["center1"]["value"] = [ctr + r*s(t1) - r/3*c(t1), ctr - r*c(t1) + r/4*s(t1), br + br/2*s(t1*5)];
                shader.data["center2"]["value"] = [ctr + r*s(t2) - r/3*c(t2), ctr - r*c(t2) + r/4*s(t2), br + br/2*s(t2*5)];
                shader.data["center3"]["value"] = [ctr + r*s(t3) - r/3*c(t3), ctr - r*c(t3) + r/4*s(t3), br + br/2*s(t3*5)];
            }
            
            bmd.applyFilter(bmd, bmd.rect, new Point(0,0), filter);
        }
        
        private var shaderString:String = "oQECAAAMX091dENvb3JkAKMABHNyYwChAgQBAA9kc3QAoQECAgAMc2l6ZQCiAmRlZmF1bHRWYWx1ZQBEAAAARAAAAKICbWluVmFsdWUAAAAAAAAAAACiAm1heFZhbHVlAEQAAABEAAAAoQEBBAAIZXhwb25lbnQAogFkZWZhdWx0VmFsdWUAQSAAAKIBbWluVmFsdWUAAAAAAKIBbWF4VmFsdWUAQsgAAKEBAwUADmNlbnRlcjEAogNkZWZhdWx0VmFsdWUAQxYAAEMgAABGHsAAogNtaW5WYWx1ZQAAAAAAAAAAAAAAAACiA21heFZhbHVlAD+AAAA/gAAARxxAAKEBAwYADmNlbnRlcjIAogNkZWZhdWx0VmFsdWUAQsgAAEPIAABGLmAAogNtaW5WYWx1ZQAAAAAAAAAAAAAAAACiA21heFZhbHVlAD+AAAA/gAAARxxAAKEBAwcADmNlbnRlcjMAogNkZWZhdWx0VmFsdWUAQ8gAAEJIAABGLmAAogNtaW5WYWx1ZQAAAAAAAAAAAAAAAACiA21heFZhbHVlAD+AAAA/gAAARxxAADIBAOAAAAAAHQMAMQUAEAACAwAxAAAQAAMDADEDALAAAQMAEAMAgAAdAwAgBQCAAAUDACADAMAAAQEAgAMAgAAdAwAxBgAQAAIDADEAABAAAwMAMQMAsAABAwAQAwCAAB0DACAGAIAABQMAIAMAwAABAQCAAwCAAB0DADEHABAAAgMAMQAAEAADAwAxAwCwAAEDABADAIAAHQMAIAcAgAAFAwAgAwDAAAEBAIADAIAABwEAgAQAAAAdAQBAAQAAAB0BACABAAAAMgEAED+AAAA=";
    }
}

/* Shader:

parameter "_OutCoord", float2, f0.rg, in

texture  "src", t0

parameter "dst", float4, f1, out

parameter "size", float2, f2.rg, in
meta  "defaultValue", 512, 512
meta  "minValue", 0, 0
meta  "maxValue", 512, 512

parameter "exponent", float, f4.r, in ; cutoff
meta  "defaultValue", 10
meta  "minValue", 0
meta  "maxValue", 100

parameter "center1", float3, f5.rgb, in ; x, y, size
meta  "defaultValue", 150, 160, 10160
meta  "minValue", 0, 0, 0
meta  "maxValue", 1, 1, 40000

parameter "center2", float3, f6.rgb, in
meta  "defaultValue", 100, 400, 11160
meta  "minValue", 0, 0, 0
meta  "maxValue", 1, 1, 40000

parameter "center3", float3, f7.rgb, in
meta  "defaultValue", 400, 50, 11160
meta  "minValue", 0, 0, 0
meta  "maxValue", 1, 1, 40000

;----------------------------------------------------------

set f1.rgb, 0

mov f3.ba, f5.rg
sub f3.ba, f0.rg
mul f3.ba, f3.ba
add f3.a, f3.b
mov f3.b, f5.b
div f3.b, f3.a
add f1.r, f3.b

mov f3.ba, f6.rg
sub f3.ba, f0.rg
mul f3.ba, f3.ba
add f3.a, f3.b
mov f3.b, f6.b
div f3.b, f3.a
add f1.r, f3.b

mov f3.ba, f7.rg
sub f3.ba, f0.rg
mul f3.ba, f3.ba
add f3.a, f3.b
mov f3.b, f7.b
div f3.b, f3.a
add f1.r, f3.b

pow f1.r, f4.r
mov f1.g, f1.r
mov f1.b, f1.r

set f1.a, 1

assembler: http://wonderfl.net/c/AsJq/fullscreen

*/