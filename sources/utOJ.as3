package {
    import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
    import com.bit101.components.PushButton;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import net.hires.debug.Stats;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {
        private var fl:BitmapData;
        //
        private const RAD:Number = Math.PI / 180;
        private var theta:Number = 0;
        private var rot:Number = 4;
        private var axis:Vector3D;
        private var point:Vector3D;
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var indexBuffer:IndexBuffer3D;
        private var fogProgram:Program3D
        private var normalProgram:Program3D;
        private var flMtx:Matrix3D;
        private var groundMtx:Matrix3D;
        private var perlinMtx:Matrix3D;
        private var projectionMtx:PerspectiveMatrix3D;
        private var cameraMtx:Matrix3D;
        private var texture:Texture;
        private var fogConst:Vector.<Number>;
        private var mist:PerlinPlane;
        //
        private var isMist:Boolean = true;
        private var isFog:Boolean = true;

        public function Main():void {
            Wonderfl.disable_capture();
            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            addChild(new Stats());
            //
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/6/61/61ab/61ab9c02044e0986d8d0f28425621104d3d1289a"), new LoaderContext(true));
        }

        private function init(e:Event):void {
            var loader:Loader = e.currentTarget.loader;
            fl = new BitmapData(loader.width, loader.height, true, 0x0);
            fl.draw(loader);
            //
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onContextCreate(e:Event):void {
            context3D = stage3D.context3D;
            //context3D.enableErrorChecking = true;
            mist = new PerlinPlane(context3D);
            context3D.configureBackBuffer(466, 466, 0, true);
            context3D.setRenderToBackBuffer();
            context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            //
            //vertex buffer
            var vertexBuffer:VertexBuffer3D = context3D.createVertexBuffer(4, 5);
            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            vertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 0, 1, -1, 1, 0, 0, 0, 1, -1, 0, 1, 1, 1, 1, 0, 1, 0]), 0, 4);
            //index buffer
            indexBuffer = context3D.createIndexBuffer(6);
            indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
            //
            //constant
            axis = new Vector3D(1, 1, 1);
            point = new Vector3D(0, 0, 0);
            projectionMtx = new PerspectiveMatrix3D();
            var aspect:Number = 1;
            var zNear:Number = 0.1;
            var zFar:Number = 1000;
            var fov:Number = 45 * RAD;
            projectionMtx.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
            cameraMtx = new Matrix3D();
            cameraMtx.appendTranslation(0, 0, 12);
            cameraMtx.append(projectionMtx);
            var fog:Number = 1 / 16;
            fogConst = Vector.<Number>([fog, fog, fog, 0]);
            //
            groundMtx = new Matrix3D();
            groundMtx.appendScale(4, 4, 1);
            groundMtx.appendRotation(90, Vector3D.X_AXIS, point);
            groundMtx.appendTranslation(0, -2.5, 0);
            groundMtx.append(cameraMtx);
            perlinMtx = new Matrix3D();
            perlinMtx.appendScale(4, 4, 1);
            //
            perlinMtx.appendTranslation(0, 0, -8);
            perlinMtx.append(cameraMtx);
            //
            //texture
            texture = context3D.createTexture(fl.width, fl.height, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(fl);
            //
            //vertex shader
            var vertexShader:AGALMiniAssembler = new AGALMiniAssembler();
            var code:String = "";
            code += "m44 vt0, va0, vc0\n";
            code += "mov op, vt0\n";
            code += "mov v0, va1\n";
            code += "mov v1, vt0.z\n";
            vertexShader.assemble(Context3DProgramType.VERTEX, code);
            //fragment shader
            var fragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
            code = "";
            code += "tex ft0, v0, fs0<2d,clamp,linear>\n";
            code += "mul ft1, fc0, v1\n";
            code += "add ft0, ft0, ft1\n";
            code += "mov oc ft0\n";
            fragmentShader.assemble(Context3DProgramType.FRAGMENT, code);
            //
            fogProgram = context3D.createProgram();
            fogProgram.upload(vertexShader.agalcode, fragmentShader.agalcode);
            //
            code = "tex ft0, v0, fs0<2d,clamp,linear>\n" + "mov oc ft0\n";
            fragmentShader.assemble(Context3DProgramType.FRAGMENT, code);
            normalProgram = context3D.createProgram();
            normalProgram.upload(vertexShader.agalcode, fragmentShader.agalcode);
            //
            //2D menu
            var mistButton:PushButton = new PushButton(this, 100, 0, "NO MIST", onMistPush);
            mistButton.toggle = true;
            var fogButton:PushButton = new PushButton(this, 100, 20, "NO FOG", onFogPush);
            fogButton.toggle = true;
            //
            addEventListener(Event.ENTER_FRAME, onEnter);
        }

        private function onMistPush(e:MouseEvent):void {
            isMist = !(e.currentTarget as PushButton).selected;
        }

        private function onFogPush(e:MouseEvent):void {
            isFog = !(e.currentTarget as PushButton).selected;
        }

        private function onEnter(e:Event):void {
            context3D.clear(1, 1, 1, 1);
            //
            flMtx = new Matrix3D();
            flMtx.appendRotation(rot, axis, point);
            rot += 2;
            flMtx.appendTranslation(5 * Math.cos(theta), 0, 5 * Math.sin(theta));
            theta += 0.01;
            flMtx.append(cameraMtx);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, flMtx, true);
            if (isFog){
                context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fogConst);
                context3D.setProgram(fogProgram);
            } else {
                context3D.setProgram(normalProgram);
            }
            context3D.setTextureAt(0, texture);
            context3D.drawTriangles(indexBuffer);
            //
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, groundMtx, true);
            context3D.setTextureAt(0, texture);
            context3D.drawTriangles(indexBuffer);
            //
            if (isMist){
                mist.render(perlinMtx);
            }
            //
            context3D.present();
        }

    }

}
//
//PerlinPlane Class
//
import com.adobe.utils.AGALMiniAssembler;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;

/**
 * ...
 * @author
 */
class PerlinPlane extends Object {
    private var subAlpha:Number = 0.1;
    private var blendMax:Number = 0.6;
    private var textureMax:uint = 128;
    //
    private var _context3D:Context3D;
    //
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _dxy:Vector.<Number>;
    private var _theta:Number = 0;
    private const _RAD:Number = Math.PI / 180;
    //
    private var _program:Program3D;
    private var _texture0:Texture;
    private var _texture1:Texture;

    public function PerlinPlane(context3D:Context3D){
        _context3D = context3D;
        //
        _dxy = Vector.<Number>([0, 0, 0, 0]);
        //buffer
        _vertexBuffer = _context3D.createVertexBuffer(4, 5);
        _vertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 0, 1, -1, 1, 0, 0, 0, 1, -1, 0, 1, 1, 1, 1, 0, 1, 0]), 0, 4);
        _indexBuffer = context3D.createIndexBuffer(6);
        _indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
        //shader
        var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        //vertex shader
        var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0 \n" + "mov v0, va1\n");
        //fragment shader
        var code:String = "";
        code += "add ft0, v0 fc0\n";
        code += "tex ft1, ft0, fs0<2d,repeat,linear>\n";
        code += "add ft0, ft0 fc0\n";
        code += "tex ft2, ft0, fs1<2d,repeat,linear>\n";
        code += "add oc, ft1, ft2\n";
        var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
        _program = context3D.createProgram();
        _program.upload(vertexShader, fragmentShader);
        //
        //
        //prepare perlin texture
        var textures:Vector.<Texture> = new Vector.<Texture>(6);
        for (var i:int = 0; i < 6; i++){
            textures[i] = _createRandomTexture(textureMax >> i)
        }
        var blend:Vector.<Number> = new Vector.<Number>(6);
        for (i = 0; i < 6; i++){
            blend[i] = blendMax;
            blendMax /= 2;
        }
        code = "";
        code += "tex ft0, v0, fs0<2d,repeat,linear>\n";
        code += "mul ft0, ft0, fc0.z\n";
        code += "tex ft1, v0, fs1<2d,repeat,linear>\n";
        code += "mul ft1, ft1, fc0.y\n";
        code += "add ft0, ft0, ft1\n";
        code += "tex ft1, v0, fs2<2d,repeat,linear>\n";
        code += "mul ft1, ft1, fc0.x\n";
        code += "add ft0, ft0, ft1\n";
        code += "sub ft0.w, ft0.x, fc0.w\n";
        code += "mov oc, ft0\n";
        var program:Program3D = context3D.createProgram();
        program.upload(agalAssembler.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "mov v0, va1\n"), agalAssembler.assemble(Context3DProgramType.FRAGMENT, code));
        _texture0 = context3D.createTexture(textureMax, textureMax, Context3DTextureFormat.BGRA, true);
        _texture1 = context3D.createTexture(textureMax, textureMax, Context3DTextureFormat.BGRA, true);
        //
        _context3D.configureBackBuffer(textureMax, textureMax, 0);
        _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        _context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setProgram(program);
        //first 3 textures
        _context3D.setRenderToTexture(_texture0);
        _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([blend[3], blend[4], blend[5], subAlpha]), 1);
        _context3D.setTextureAt(0, textures[0]);
        _context3D.setTextureAt(1, textures[1]);
        _context3D.setTextureAt(2, textures[2]);
        _context3D.clear();
        _context3D.drawTriangles(_indexBuffer);
        //second 3 textures
        _context3D.setRenderToTexture(_texture1);
        _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([blend[0], blend[1], blend[2], subAlpha]), 1);
        _context3D.setTextureAt(0, textures[3]);
        _context3D.setTextureAt(1, textures[4]);
        _context3D.setTextureAt(2, textures[5]);
        _context3D.clear();
        _context3D.drawTriangles(_indexBuffer);
        //diapose
        _context3D.setTextureAt(0, null);
        _context3D.setTextureAt(1, null);
        _context3D.setTextureAt(2, null);
        for (i = 0; i < 6; i++){
            textures[i].dispose();
        }
        program.dispose();
    }

    private function _createRandomTexture(size:uint):Texture {
        var bd:BitmapData = new BitmapData(size, size, false);
        bd.noise(Math.random() * 0xFFFFFFFF >> 0, 0, 255, 7, true);
        var texture:Texture = _context3D.createTexture(size, size, Context3DTextureFormat.BGRA, false);
        texture.uploadFromBitmapData(bd);
        bd.dispose();
        return texture;
    }

    public function render(mtx:Matrix3D):void {
        _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        _context3D.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mtx, true);
        _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _dxy, 1);
        _dxy[0] += Math.cos(_theta * _RAD) * 0.005;
        _dxy[1] += 0.0004;
        _theta += 0.01;
        _context3D.setProgram(_program);
        _context3D.setTextureAt(0, _texture0);
        _context3D.setTextureAt(1, _texture1);
        _context3D.drawTriangles(_indexBuffer);
        //
        _context3D.setTextureAt(0, null);
        _context3D.setTextureAt(1, null);
    }
}

