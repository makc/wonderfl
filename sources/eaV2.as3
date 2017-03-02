package {
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.ByteArray;
    import frocessing.color.ColorHSV;
    import net.hires.debug.Stats;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {

        private const NUM_PARTICLES:uint = 21845;
        private const MAX_BUFFERS:uint = 500;
        private const P_SIZE:Number = 0.5 * 0.015;
        private const R3_P_1_SIZE:Number = P_SIZE / Math.sqrt(3);
        private const R3_P_2_SIZE:Number = R3_P_1_SIZE * 2;
        private const WIDTH:uint = 466;
        private const HEIGHT:uint = 466;
        private const RAD:Number = Math.PI / 180;
        //
        private const CIRCLE_SCALE:Number = 1000;
        private const CIRCLE_WIDTH:Number = 0.4;
        private const CIRCLE_SIZE:Number = 360;
        private const CIRCLE_T:Number = 8;
        private const CONST_SIZE:Vector.<Number> = Vector.<Number>([CIRCLE_SCALE, CIRCLE_SIZE * (1 - CIRCLE_WIDTH / 2), CIRCLE_SIZE * CIRCLE_WIDTH / 2, CIRCLE_T]);
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var camera:SimpleCamera3D;
        private var particleProgram:Program3D;
        private var vBufferHS:VertexBuffer3D;
        private var vBufferOffset:VertexBuffer3D;
        private var iBuffer:IndexBuffer3D;
        //
        private var constRad:Vector.<Number>;
        private var theta:Number = 0;
        private var filter:TwinkleFilter3D;
        private var isFilter:Boolean = false;
        //
        private var tfP:TextField;

        public function Main():void {
            Wonderfl.disable_capture();
            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            addChild(new Stats());
            //
            //set ui
            var tfB:TextField = new TextField();
            tfB.autoSize = TextFieldAutoSize.LEFT;
            tfB.textColor = 0xffffff;
            tfB.text = "MotiMoti : ";
            tfB.x = 100;
            addChild(tfB);
            var stepper:NumericStepper = new NumericStepper(this, 170, 0, onStepper);
            stepper.value = 8;
            stepper.minimum = 0;
            stepper.maximum = 12;
            stepper.width = 60;
            tfP = new TextField();
            tfP.autoSize = TextFieldAutoSize.LEFT;
            tfP.textColor = 0xffffff;
            tfP.text = "Particle : " + NUM_PARTICLES;
            tfP.x = 250;
            addChild(tfP);
            var pushButton:PushButton = new PushButton(this, 350, 0, "Twinkle", onPush);
            pushButton.toggle = true;
            //
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onStepper(e:Event):void {
            CONST_SIZE[3] = (e.currentTarget as NumericStepper).value;
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, CONST_SIZE); //radius
        }

        private function onPush(e:MouseEvent):void {
            isFilter = !isFilter;
        }

        private function onContextCreate(e:Event):void {
            context3D = stage3D.context3D;
            //context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(WIDTH, HEIGHT, 0, true);
            context3D.setCulling(Context3DTriangleFace.BACK);
            //
            filter = new TwinkleFilter3D(context3D, WIDTH, HEIGHT, 3);
            camera = new SimpleCamera3D(45 * RAD, 1, 0.1, 3000);
            new RoundCameraController(camera, stage);
            createBuffer();
            createShader();
            constRad = Vector.<Number>([0, 0, 0, 0]);
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([0, 0, 0, 1])); //initial coord
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, CONST_SIZE); //radius
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 7, AGALUtil.CONST_RADIAN_TO_HSV);
            //
            addEventListener(Event.ENTER_FRAME, onEnter);
        }

        private function onEnter(e:Event):void {
            theta += 0.005;
            constRad[0] = Math.sin(theta) * Math.PI;
            if (isFilter){
                filter.setRenderToTexture();
            }
            context3D.clear();
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.cameraMtx, true);

            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 6, constRad);
            context3D.drawTriangles(iBuffer);

            if (isFilter){
                context3D.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
                context3D.setVertexBufferAt(1, null, 0, Context3DVertexBufferFormat.FLOAT_3);
                filter.applyFilter();
                context3D.setProgram(particleProgram);
                context3D.setVertexBufferAt(0, vBufferHS, 0, Context3DVertexBufferFormat.FLOAT_2);
                context3D.setVertexBufferAt(1, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
            }
            context3D.present();
        }

        private function createShader():void {
            var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            var code:String = "";
            //base vec
            code += "mov vt0, vc4\n"; //vt0=(0,0,0,1)
            code += "cos vt0.x, va0.x\n"; //vt0.x=cos(hue)
            code += "sin vt0.z, va0.x\n"; //vt0.z=sin(hue)
            //tangent
            code += "mov vt2, vc4\n"; //vt2=(0,0,0,1)
            code += "neg vt2.x, vt0.z\n"; //vt2.x=-sin(hue)
            code += "mov vt2.z, vt0.x\n"; //vt2.y=cos(hue)
            //vertical vec
            code += "crs vt3.xyz, vt2.xyz, vt0.xyz\n";
            code += "nrm vt3.xyz, vt3.xyz\n"; //X vector
            code += "crs vt2.xyz, vt2.xyz, vt3.xyz\n"; //Y vector
            //offset vec
            code += "add vt1.z, va0.y, vc6.x\n"; //vt1.x=theta+alpha
            code += "cos vt1.x, vt1.z\n"; //vt1.x=cos(theta+alpha)
            code += "sin vt1.y, vt1.z\n"; //vt1.y=sin(theta+alpha)
            code += "mul vt3.xyz, vt3.xyz, vt1.x\n"; //vt3=cos(theta+alpha)*vt3
            code += "mul vt2.xyz, vt2.xyz, vt1.y\n"; //vt2=sin(theta+alpha)*vt2
            code += "add vt1.xyz, vt2.xyz, vt3.xyz\n"; //vt1=vt2+vt3
            //scale
            code += "add vt2.x, va0.x, vc6.y\n"; //vt1.x=hue+alpha
            code += "mul vt2.x, vt2.x, vc5.w\n"; //vt2.x=hue*n
            code += "cos vt2.x, vt2.x\n"; //vt2.x=cos(n*hue)
            code += "mul vt2.x, vt2.x, vc5.z\n"; //vt2.x=cos(n*hue)*vc5.z
            code += "add vt2.x, vt2.x, vc5.y\n"; //vt2.x=cos(n*hue)*vc5.z+vc5.y
            code += "mul vt1.xyz, vt1.xyz, vt2.x\n"; //vt1*=vt2.x
            //base+offset
            code += "mul vt0.xyz, vt0.xyz, vc5.x\n"; //vt0.xyz*=r
            code += "add vt0.xyz, vt0.xyz, vt1.xyz\n"; //vt0+=vt1
            //projection
            code += "m44 vt0, vt0, vc0\n";
            code += "mul vt1, vt0.w, va1\n";
            code += "add vt0, vt0, vt1\n";
            code += "mov op, vt0\n";
            //color HSV
            code += AGALUtil.radianToHSV("va0.x", 0, 7, 0); //radian to H
            //
            var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, code);
            var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, "mov oc v0\n");
            particleProgram = context3D.createProgram();
            particleProgram.upload(vertexShader, fragmentShader);
            context3D.setProgram(particleProgram);
        }

        private function createBuffer():void {
            ////Particle
            var numVertices:uint = NUM_PARTICLES * 3;
            var numIndices:uint = NUM_PARTICLES * 3;
            //hs,rgb
            var index:uint = 0;
            var pos:Vector.<Number> = new Vector.<Number>(numVertices * 2);
            var h:Number;
            var s:Number;
            var v:Number;
            var hsv:ColorHSV = new ColorHSV();
            var theta:Number;
            vBufferHS = context3D.createVertexBuffer(numVertices, 2);
            for (var i:int = 0; i < NUM_PARTICLES; i++){
                v = Math.sqrt(Math.random());
                do {
                    s = Math.random();
                } while (v < s);
                h = Math.random() * 360;
                hsv.hsv(h, s, v);
                h *= RAD;
                theta = Math.random() * 360 * RAD;
                pos[index++] = h;
                pos[index++] = theta;
                pos[index++] = h;
                pos[index++] = theta;
                pos[index++] = h;
                pos[index++] = theta;
            }
            vBufferHS.uploadFromVector(pos, 0, numVertices);
            context3D.setVertexBufferAt(0, vBufferHS, 0, Context3DVertexBufferFormat.FLOAT_2);
            //offset
            vBufferOffset = context3D.createVertexBuffer(numVertices, 2);
            var offsetVec:Vector.<Number> = new Vector.<Number>(numVertices * 2);
            index = 0;
            for (i = 0; i < NUM_PARTICLES; i++){
                offsetVec[index++] = -P_SIZE;
                offsetVec[index++] = -R3_P_1_SIZE;
                offsetVec[index++] = 0;
                offsetVec[index++] = R3_P_2_SIZE;
                offsetVec[index++] = P_SIZE;
                offsetVec[index++] = -R3_P_1_SIZE;
            }
            vBufferOffset.uploadFromVector(offsetVec, 0, numVertices);
            context3D.setVertexBufferAt(1, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
            //index buffer
            iBuffer = context3D.createIndexBuffer(numIndices);
            var iVec:Vector.<uint> = new Vector.<uint>(numIndices);
            index = 0;
            var p:uint;
            for (i = 0; i < NUM_PARTICLES; i++){
                p = i * 3;
                iVec[index++] = p;
                iVec[index++] = p + 1;
                iVec[index++] = p + 2;
            }
            iBuffer.uploadFromVector(iVec, 0, numIndices);
        }

    }
}

import com.adobe.utils.AGALMiniAssembler;
import com.adobe.utils.PerspectiveMatrix3D;
import flash.display.InteractiveObject;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

//////////////////////////////////////////////////
// SimpleCamera3D
//////////////////////////////////////////////////
class SimpleCamera3D extends Object {

    private const RAD:Number = Math.random() / 180;
    private const DIRECTION:Vector3D = new Vector3D(0, 0, 1);
    //
    private var _cameraUP:Vector3D = new Vector3D(0, 1, 0);
    private var _direction:Vector3D = DIRECTION.clone();
    //
    private var _projectionMtx:PerspectiveMatrix3D = new PerspectiveMatrix3D();
    private var _cameraMtx:Matrix3D = new Matrix3D();
    private var _rotationMtx:Matrix3D = new Matrix3D();
    //
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;

    public function SimpleCamera3D(fov:Number, aspect:Number, zNear:Number, zFar:Number):void {
        _projectionMtx.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
    }

    public function get cameraMtx():Matrix3D {
        var forwardX:Number = _direction.x;
        var forwardY:Number = _direction.y;
        var forwardZ:Number = _direction.z;
        var rightX:Number = _cameraUP.y * forwardZ - _cameraUP.z * forwardY;
        var rightY:Number = _cameraUP.z * forwardX - _cameraUP.x * forwardZ;
        var rightZ:Number = _cameraUP.x * forwardY - _cameraUP.y * forwardX;
        var distance:Number = Math.sqrt(rightX * rightX + rightY * rightY + rightZ * rightZ);
        rightX /= distance;
        rightY /= distance;
        rightZ /= distance;
        var upX:Number = forwardY * rightZ - forwardZ * rightY;
        var upY:Number = forwardZ * rightX - forwardX * rightZ;
        var upZ:Number = forwardX * rightY - forwardY * rightX;
        var right:Number = rightX * x + rightY * y + rightZ * z;
        var up:Number = upX * x + upY * y + upZ * z;
        var forward:Number = forwardX * x + forwardY * y + forwardZ * z;
        _cameraMtx.rawData = Vector.<Number>([rightX, upX, forwardX, 0, rightY, upY, forwardY, 0, rightZ, upZ, forwardZ, 0, -right, -up, -forward, 1]);
        _cameraMtx.append(_projectionMtx);
        return _cameraMtx;
    }

    public function lookAt(point:Vector3D):void {
        _direction.x = point.x - x;
        _direction.y = point.y - y;
        _direction.z = point.z - z;
        _direction.normalize();
    }

}

//////////////////////////////////////////////////
// RoundCameraController
//////////////////////////////////////////////////
class RoundCameraController extends Object {

    private var _camera:SimpleCamera3D;
    private var _stage:InteractiveObject;
    private var _target:Vector3D;
    public var radiusOffset:Number = 40;
    //
    private const RAD:Number = Math.PI / 180;
    //
    public var isMouseDown:Boolean;
    private var _radius:Number = 2000;
    private var _theta:Number = 0;
    private var _oldX:Number = 0;
    private var _phi:Number = 90;
    private var _oldY:Number = 0;

    public function RoundCameraController(camera:SimpleCamera3D, stage:InteractiveObject){
        _camera = camera;
        _stage = stage;
        _target = new Vector3D();
        enable();
        _upDateCamera();
    }

    public function enable():void {
        _stage.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyHandler);
        _stage.stage.addEventListener(MouseEvent.MOUSE_UP, _upHandler);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, _downHandler);
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, _moveHandler);
        _stage.addEventListener(MouseEvent.MOUSE_WHEEL, _wheelHandler);
    }

    //
    private function _keyHandler(e:KeyboardEvent):void {
        switch (e.keyCode){
            case Keyboard.UP:
                _radius -= radiusOffset;
                if (_radius < 10){
                    _radius = 10;
                }
                _upDateCamera();
                break;
            case Keyboard.DOWN:
                _radius += radiusOffset;
                _upDateCamera();
                break;
            default:
                break;
        }
    }

    private function _upHandler(e:MouseEvent):void {
        isMouseDown = false;
    }

    private function _downHandler(e:MouseEvent):void {
        isMouseDown = true;
        _oldX = _stage.mouseX;
        _oldY = _stage.mouseY;
    }

    private function _wheelHandler(e:MouseEvent):void {
        if (e.delta > 0){
            _radius -= radiusOffset;
            if (_radius < 10){
                _radius = 10;
            }
        } else {
            _radius += radiusOffset;
        }
        _upDateCamera();
    }

    private function _moveHandler(e:MouseEvent):void {
        if (isMouseDown){
            _theta += (e.stageX - _oldX) >> 2;
            _oldX = e.stageX;
            _phi -= (e.stageY - _oldY) >> 2;
            _oldY = e.stageY;
            //
            if (_theta < 0){
                _theta += 360;
            } else if (_theta > 360){
                _theta -= 360;
            }
            if (_phi < 20){
                _phi = 20;
            } else if (_phi > 160){
                _phi = 160;
            }
            _upDateCamera();
        }
    }

    private function _upDateCamera():void {
        var t:Number = _theta * RAD;
        var p:Number = _phi * RAD;
        var rsin:Number = _radius * Math.sin(p);
        _camera.x = rsin * Math.sin(t) + _target.x;
        _camera.z = rsin * Math.cos(t) + _target.z;
        _camera.y = _radius * Math.cos(p) + _target.y;
        _camera.lookAt(_target)
    }

}

//////////////////////////////////////////////////
// TwinkleFilter3D
//////////////////////////////////////////////////
class TwinkleFilter3D extends Object {
    private var _context3D:Context3D;
    private var _width:Number;
    private var _height:Number;
    //twinkle
    private var _canvasTexture:Texture;
    private var _shrinkTexture:Texture;
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _shrinkProgram:Program3D;
    private var _compositeProgram:Program3D;

    public function TwinkleFilter3D(context3D:Context3D, width:uint, height:uint, twinkleStrength:uint = 4){
        _context3D = context3D;
        _width = _toPowerOfTwo(width);
        _height = _toPowerOfTwo(height);
        twinkleStrength = twinkleStrength < 2 ? 2 : twinkleStrength;
        var sW:uint = _width >> twinkleStrength;
        var sH:uint = _height >> twinkleStrength;
        sW = sW < 1 ? 1 : sW;
        sH = sH < 1 ? 1 : sH;
        ////texture
        _canvasTexture = _context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA, true);
        _shrinkTexture = _context3D.createTexture(sW, sH, Context3DTextureFormat.BGRA, true);
        ////buffer
        //vertex buffer
        _vertexBuffer = _context3D.createVertexBuffer(4, 4);
        _vertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 1, -1, 1, 0, 0, 1, -1, 1, 1, 1, 1, 1, 0]), 0, 4);
        //index buffer
        _indexBuffer = _context3D.createIndexBuffer(6);
        _indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 3, 2]), 0, 6);
        ////shader
        //shrink
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        var vertexShader:ByteArray = agal.assemble(Context3DProgramType.VERTEX, "mov op, va0 \n" + "mov v0, va1\n");
        var code:String = "";
        code += "mov ft0 v0\n";
        code += "tex ft0, ft0, fs0<2d,repeat,linear>\n";
        code += "mov oc, ft0\n";
        var fragmentShader:ByteArray = agal.assemble(Context3DProgramType.FRAGMENT, code);
        _shrinkProgram = _context3D.createProgram();
        _shrinkProgram.upload(vertexShader, fragmentShader);
        //composite
        code = "";
        code += "mov ft0 v0\n";
        code += "tex ft1, ft0, fs0<2d,repeat,linear>\n";
        code += "tex ft0, ft0, fs1<2d,repeat,linear>\n";
        code += "add ft0, ft0, ft1\n";
        code += "mov oc, ft0\n";
        fragmentShader = agal.assemble(Context3DProgramType.FRAGMENT, code);
        _compositeProgram = _context3D.createProgram();
        _compositeProgram.upload(vertexShader, fragmentShader);
    }

    public function setRenderToTexture():void {
        _context3D.setRenderToTexture(_canvasTexture, true);
    }

    public function applyFilter():void {
        _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        //shrink
        _context3D.setProgram(_shrinkProgram);
        _context3D.setRenderToTexture(_shrinkTexture);
        _context3D.clear();
        _context3D.setTextureAt(0, _canvasTexture);
        _context3D.drawTriangles(_indexBuffer);
        //composite
        _context3D.setRenderToBackBuffer();
        _context3D.setProgram(_compositeProgram);
        _context3D.setTextureAt(0, _canvasTexture);
        _context3D.setTextureAt(1, _shrinkTexture);
        _context3D.clear();
        _context3D.drawTriangles(_indexBuffer);
        //
        _context3D.setTextureAt(0, null);
        _context3D.setTextureAt(1, null);
        _context3D.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
    }

    //
    private function _toPowerOfTwo(x:uint):uint {
        if ((x & (x - 1))){
            var i:uint = 1;
            while (i < x){
                i <<= 1;
            }
            x = i;
        }
        return x;
    }

}

//////////////////////////////////////////////////
// AGALUtil
//////////////////////////////////////////////////
class AGALUtil extends Object {
    public static const RAD:Number = Math.PI / 180;
    public static const CONST_RADIAN_TO_HSV:Vector.<Number> = Vector.<Number>([1, 0.5, 120 * RAD, 0]);

    public function AGALUtil(){
    }

    public static function radianToHSV(radianResister:String, temporary:uint, constant:uint, varying:uint):String {
        var code:String = "";
        code += "mov vt" + temporary + ".xyz, " + radianResister + "\n";
        code += "add vt" + temporary + ".y, vt" + temporary + ".y, vc" + constant + ".z\n";
        code += "sub vt" + temporary + ".z, vt" + temporary + ".z, vc" + constant + ".z\n";
        code += "cos vt" + temporary + ".xyz, vt" + temporary + ".xyz\n";
        code += "add vt" + temporary + ".xyz, vt" + temporary + ".xyz, vc" + constant + ".x\n";
        code += "mul vt" + temporary + ".xyz, vt" + temporary + ".xyz, vc" + constant + ".y\n";
        code += "mov v" + varying + ", vt" + temporary + "\n";
        return code;
    }

}