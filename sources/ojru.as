package {
    import mx.utils.Base64Decoder;
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            var d:Base64Decoder = new Base64Decoder();
            d.decode('oQECAAAMX091dENvb3JkAKMABHNyYwChAgQBAA9kc3QAMAEA8QAAEAAyAQAgvwAAAAEBAMEBAKAAHQIAEAEAQAAGAgAQAQAAADICAIA/dHZFAwIAEAIAAAAdAgDiAgD8ADIBAEA/gAAAMgEAIL+AAAABAgBhAQBgABgCAOICABgAMgEAgEAAAAAyAQBAv4AAADIBACC/gAAAAgEAgAIAAAABAQBhAgBgADIBABA/gAAA');
            var sf:ShaderFilter = new ShaderFilter(new Shader(d.toByteArray()));
            var bd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
            bd.perlinNoise(
                128, 128, 2,
                new Date().getTime(),
                false, true,
                BitmapDataChannel.RED | BitmapDataChannel.GREEN,
                false,
                [new Point(0, 0), new Point(32, 32)]);
            addChild(new Bitmap(bd)).filters = [sf];
        }
        
    }
}

/*
parameter "_OutCoord", float2, f0.rg, in
texture "src", t0
parameter "dst", float4, f1, out

; f1 = sample() - (0.5, 0.5)
texn f1, f0.rg, t0
set f1.b, -0.5
add f1.rg, f1.bb
; f2.a = atan2(f1.g, f1.r) * 3 / pi
mov f2.a, f1.g
atan2 f2.a, f1.r
set f2.r, 0.95492965855137201461330258023509
mul f2.a, f2.r
; f1.r = 2 - abs(f2.a)
; f1.g = abs(f2.a + 1) - 1
; f1.b = abs(f2.a - 1) - 1
mov f2.rgb, f2.aaa
set f1.g, 1
set f1.b, -1
add f2.gb, f1.gb
abs f2.rgb, f2.rgb
set f1.r, 2
set f1.g, -1
set f1.b, -1
sub f1.r, f2.r
add f1.gb, f2.gb
set f1.a, 1
*/