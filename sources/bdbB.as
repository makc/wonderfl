package {
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.ShaderFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    
    [SWF(width=465,height=465,frameRate=60,backgroundColor=0x111111)]
    public class BumpMap extends Sprite {
        private var vertices:Vector.<Number>  = new Vector.<Number>(0, false);
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        private var indices:Vector.<int>      = new Vector.<int>(0, false);
        private var uvtData:Vector.<Number>   = new Vector.<Number>(0, false);
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        private var count:uint = 0;
        private var heightMap:BitmapData = new HeightMap();
        private var normalMap:BitmapData;
        private var texture:BitmapData = new BitmapData(256, 256, false, 0);
        
        public function BumpMap() {
            x = y = 465 / 2;
            vertices.push(-300, +300, 0, +300, +300, 0, +300, -300, 0, -300, -300, 0);
            uvtData.push(0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0);
            indices.push(0, 1, 2, 2, 3, 0);
            projection.fieldOfView = 60;
            
            var h2nShader:HeightToNormalShader = new HeightToNormalShader();
            h2nShader.data.multiplier.value = [10];
            normalMap = new BitmapData(256, 256, false, 0);
            normalMap.applyFilter(heightMap, heightMap.rect, heightMap.rect.topLeft, new ShaderFilter(h2nShader));
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
        }
        
        private function enterFrame(event:Event):void {
            var view:Matrix3D = new Matrix3D();
            view.appendRotation(Math.cos(count * 0.017) * 60, Vector3D.X_AXIS);
            view.appendRotation(Math.cos(count * 0.031) * 60, Vector3D.Y_AXIS);
            var light:Vector3D = view.transformVector(Vector3D.Z_AXIS);
            view.appendTranslation(0, 0, 850);
            view.append(projection.toMatrix3D());
            Utils3D.projectVectors(view, vertices, projected, uvtData);
            var lighting:ColorMatrixFilter = new ColorMatrixFilter([
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                2 * light.x, 2 * light.y, 2 * light.z, 0, (light.x + light.y + light.z) * -0xFF,
                0,           0,           0,           1, 0
            ]);
            texture.applyFilter(normalMap, normalMap.rect, normalMap.rect.topLeft, lighting);
            graphics.clear();
            graphics.beginBitmapFill(texture, null, false, true);
            graphics.drawTriangles(projected, indices, uvtData);
            count++;
        }
    }
}
import flash.display.BitmapData;
import flash.display.Shader;
import flash.display.Sprite;
import flash.text.TextField;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.filters.GlowFilter;
import flash.utils.ByteArray;
import mx.utils.Base64Decoder;
class HeightToNormalShader extends Shader {
    protected var base64:String = "pQEAAACkAQBhoAxuYW1lc3BhY2UAAKAMdmVuZG9yAACgCHZlcnNpb24AAQChAQIAAAxfT3V0Q29vcmQAoQEBAAACbXVsdGlwbGllcgCiAW1pblZhbHVlAAAAAACiAW1heFZhbHVlAELIAACiAWRlZmF1bHRWYWx1ZQBAoAAAowAEc3JjAKECBAEAD2RzdAAdAgDBAAAQADEDAPECABAAHQAAEAMAgAAyAwCAP4AAADIDAEAAAAAAHQMAMQIAEAABAwAxAwAQADEEAPEDALAAHQMAgAAAwAACAwCABACAAB0CACADAAAAMgMAgAAAAAAyAwBAP4AAAB0DADECABAAAQMAMQMAEAAxBADxAwCwAB0DAIAAAMAAAgMAgAQAgAAdAgAQAwAAAB0DAMECALAAAwMAwQAAoAAdAgAxAwAQACQDAIECALAAHQMAQAMAAAAyAwCAP4AAACoDAIADAEAAHQGAgACAAAA0AAAAAYAAADIDAEA/gAAABAMAMQMAUAADAgAxAwCwADYAAAAAAAAAHQQAgAIAgAAdBABAAgDAADIDAIA/gAAAHQMAIAMAQAADAwAgAwBAAB0DABADAAAAAgMAEAMAgAAWAwCAAwDAAB0EACADAAAAMgMAgD+AAAAdBAAQAwAAADIDAIA/AAAAHQUA8wQAGwADBQDzAwAAADIEAIA/AAAAMgQAQD8AAAAyBAAgPwAAADIEABA/AAAAHQYA8wUAGwABBgDzBAAbAB0BAPMGABsA";
    public function HeightToNormalShader() {
        var decoder:Base64Decoder = new Base64Decoder();
        decoder.decode(base64);
        super(decoder.drain());
    }
}
class HeightMap extends BitmapData {
    public function HeightMap() {
        super(256, 256, true, 0);
        perlinNoise(64, 64, 4, Math.random() * 100, false, true, 0, true);
        colorTransform(rect, new ColorTransform(1.5, 1.5, 1.5, 1, -0x40, -0x40, -0x40));
        fillRect(new Rectangle(0, 52, 256, 152), 0xFF808080);
        draw(new Pattern());
    }
}
class Pattern extends Sprite {
    public function Pattern() {
        var label:TextField = new TextField();
        label.autoSize = "left";
        label.htmlText = '<p align="center"><font face="_sans" size="58" color="#ffffff" letterspacing="-4"><b>BUMP\nMAPPING</b></font></p>';
        label.x = 256 - label.width >> 1;
        label.y = 256 - label.height >> 1;
        label.filters = [new GlowFilter(0x000000, 1, 4, 4, 2, 3, true)];
        addChild(label);
        var mtx:Matrix = new Matrix();
        var colors:Array = [0xFFFFFF, 0x000000];
        var alphas:Array = [1, 1];
        var ratios:Array = [0x00, 0xFF];
        for (var i:uint=1; i<8; i++) {
            mtx.createGradientBox(20, 20, 0, i * 32 - 10, 26 - 10);
            graphics.beginGradientFill("radial", colors, alphas, ratios, mtx);
            graphics.drawCircle(i * 32, 26, 10);
            graphics.endFill();
            mtx.createGradientBox(20, 20, 0, i * 32 - 10, 230 - 10);
            graphics.beginGradientFill("radial", colors, alphas, ratios, mtx);
            graphics.drawCircle(i * 32, 230, 10);
            graphics.endFill();
        }
    }
}
