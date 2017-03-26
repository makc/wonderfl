package {
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.NumericStepper;
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
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.ByteArray;
    import net.hires.debug.Stats;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {

        private const C23:Number = 2 / 3;
        private const E11:Number = Math.exp(11);
        private const C18:Number = 1 / 8;
        private const C13:Number = 1 / 3;
        private const C12:Number = 1 / 2;
        //
        private const NUM_PARTICLES:uint = 16383;
        private const MAX_BUFFERS:uint = 20;
        private const P_SIZE:Number = 0.5 * 0.01;
        private const WIDTH:uint = 466;
        private const HEIGHT:uint = 466;
        private const RAD:Number = Math.PI / 180;
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var camera:SimpleCamera3D;
        private var particleProgram:Program3D;
        private var vBufferXYZs:Vector.<VertexBuffer3D>;
        private var vBufferRGBs:Vector.<VertexBuffer3D>;
        private var vBufferOffset:VertexBuffer3D;
        private var iBuffer:IndexBuffer3D;
        //
        private var numBuffers:uint = 1;
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
            tfB.text = "Buffer : ";
            tfB.x = 100;
            addChild(tfB);
            var stepper:NumericStepper = new NumericStepper(this, 150, 0, onStepper);
            stepper.minimum = 1;
            stepper.maximum = MAX_BUFFERS;
            stepper.width = 60;
            tfP = new TextField();
            tfP.autoSize = TextFieldAutoSize.LEFT;
            tfP.textColor = 0xffffff;
            tfP.text = "Particle : " + NUM_PARTICLES;
            tfP.x = 250;
            addChild(tfP);
            //
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onStepper(e:Event):void {
            numBuffers = (e.currentTarget as NumericStepper).value;
            tfP.text = "Particle : " + NUM_PARTICLES * numBuffers;
        }

        private function onContextCreate(e:Event):void {
            context3D = stage3D.context3D;
            //context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(WIDTH, HEIGHT, 0, true);
            context3D.setCulling(Context3DTriangleFace.BACK);
            //
            camera = new SimpleCamera3D(45 * RAD, 1, 0.1, 3000);
            new RoundCameraController(camera, stage);
            createBuffer();
            createShader();
            context3D.setProgram(particleProgram);
            context3D.setVertexBufferAt(2, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
            //
            addEventListener(Event.ENTER_FRAME, onEnter);
        }

        private function onEnter(e:Event):void {
            context3D.clear();
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.cameraMtx, true);
            for (var i:int = 0; i < numBuffers; i++){
                context3D.setVertexBufferAt(0, vBufferXYZs[i], 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.setVertexBufferAt(1, vBufferRGBs[i], 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.drawTriangles(iBuffer);
            }
            context3D.present();
        }

        private function createShader():void {
            var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            ////Particle
            var code:String = "";
            code += "m44 vt0, va0, vc0\n";
            code += "mul vt1, vt0.w, va2\n";
            code += "add vt0, vt0, vt1\n";
            code += "mov op, vt0\n";
            code += "mov v0, va1\n";
            var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, code);
            var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, "mov oc v0\n");
            particleProgram = context3D.createProgram();
            particleProgram.upload(vertexShader, fragmentShader);
            context3D.setProgram(particleProgram);
        }

        private function createBuffer():void {
            ////Particle
            var numVertices:uint = NUM_PARTICLES * 4;
            var numIndices:uint = NUM_PARTICLES * 6;
            //hs,rgb
            vBufferXYZs = new Vector.<VertexBuffer3D>(MAX_BUFFERS);
            vBufferRGBs = new Vector.<VertexBuffer3D>(MAX_BUFFERS);
            var index:uint;
            var index2:uint;
            var pos:Vector.<Number> = new Vector.<Number>(NUM_PARTICLES * 4 * 3);
            var cVec:Vector.<Number> = new Vector.<Number>(numVertices * 3);
            var r:Number;
            var g:Number;
            var b:Number;
            var posX:Number;
            var posY:Number;
            var posZ:Number;
            var x23abs:Number;
            var y23:Number;
            var x23y23:Number;
            for (var j:int = 0; j < MAX_BUFFERS; j++){
                vBufferXYZs[j] = context3D.createVertexBuffer(numVertices, 3);
                vBufferRGBs[j] = context3D.createVertexBuffer(numVertices, 3);
                index = 0;
                index2 = 0;
                for (var i:int = 0; i < NUM_PARTICLES; i++){
                    posX = (Math.random() - 0.5) * 6;
                    posY = (Math.random() - 0.5) * 4;
                    x23abs = Math.abs(posX * C23);
                    y23 = posY * C23;
                    x23y23 = (x23abs - 1) * (x23abs - 1) + y23 * y23;
                    posZ = C18 * (6 * Math.exp(-x23y23 - C13 * Math.pow(y23 + C12, 3)) + C23 * Math.exp(-E11 * x23y23 * x23y23) + y23 - Math.pow(x23abs, 4));
                    pos[index++] = posX;
                    pos[index++] = posY;
                    pos[index++] = posZ;
                    pos[index++] = posX;
                    pos[index++] = posY;
                    pos[index++] = posZ;
                    pos[index++] = posX;
                    pos[index++] = posY;
                    pos[index++] = posZ;
                    pos[index++] = posX;
                    pos[index++] = posY;
                    pos[index++] = posZ;
                    //
                    if (posZ < 0.65){
                        r = 0xff / 255.0;
                        g = 0xcc / 255.0;
                        b = 0x99 / 255.0;
                    } else {
                        r = 0xee / 255.0;
                        g = 0x8e / 255.0;
                        b = 0xa0 / 255.0;
                    }
                    cVec[index2++] = r;
                    cVec[index2++] = g;
                    cVec[index2++] = b;
                    cVec[index2++] = r;
                    cVec[index2++] = g;
                    cVec[index2++] = b;
                    cVec[index2++] = r;
                    cVec[index2++] = g;
                    cVec[index2++] = b;
                    cVec[index2++] = r;
                    cVec[index2++] = g;
                    cVec[index2++] = b;
                }
                vBufferXYZs[j].uploadFromVector(pos, 0, numVertices);
                vBufferRGBs[j].uploadFromVector(cVec, 0, numVertices);
            }
            //offset
            vBufferOffset = context3D.createVertexBuffer(numVertices, 2);
            var offsetVec:Vector.<Number> = new Vector.<Number>(numVertices * 2);
            index = 0;
            for (i = 0; i < NUM_PARTICLES; i++){
                offsetVec[index++] = -P_SIZE;
                offsetVec[index++] = -P_SIZE;
                offsetVec[index++] = -P_SIZE;
                offsetVec[index++] = P_SIZE;
                offsetVec[index++] = P_SIZE;
                offsetVec[index++] = -P_SIZE;
                offsetVec[index++] = P_SIZE;
                offsetVec[index++] = P_SIZE;
            }
            vBufferOffset.uploadFromVector(offsetVec, 0, numVertices);
            context3D.setVertexBufferAt(2, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
            //index buffer
            iBuffer = context3D.createIndexBuffer(numIndices);
            var iVec:Vector.<uint> = new Vector.<uint>(numIndices);
            index = 0;
            var p:uint;
            for (i = 0; i < NUM_PARTICLES; i++){
                p = i << 2;
                iVec[index++] = p;
                iVec[index++] = p + 1;
                iVec[index++] = p + 2;
                iVec[index++] = p + 2;
                iVec[index++] = p + 1;
                iVec[index++] = p + 3;
            }
            iBuffer.uploadFromVector(iVec, 0, numIndices);
        }

    }
}

import com.adobe.utils.PerspectiveMatrix3D;
import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

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
    public var radiusOffset:Number = 0.1;
    //
    private const RAD:Number = Math.PI / 180;
    //
    public var isMouseDown:Boolean;
    private var _radius:Number = 4;
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
                if (_radius < 0.1){
                    _radius = 0.1;
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
            if (_radius < 0.1){
                _radius = 0.1;
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