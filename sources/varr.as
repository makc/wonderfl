package {
    import flash.display.Sprite;
    import flash.events.Event;
    [SWF(frameRate = "60", width="465", height="465")]
    
    /**
     * Software rendering in ActionScript3.0 #1
     * @author saharan
     */
    public class FlashSoft3D extends Sprite {
        private var r:Renderer;
        private var count:uint;
        
        public function FlashSoft3D() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            r = new Renderer(465, 465);
            addChild(r.image);
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event = null):void {
            count++;
            r.beginScene(0x000000);
            r.rotateX(count / 80);
            r.rotateY(count / 90);
            // Render the torus
            var detailH:uint = 25;
            var detailV:uint = 50;
            var innerSize:Number = 6 + Math.sin(count / 70) * 2;
            var outerSize:Number = 12;
            var addH:Number = Math.PI * 2 / detailH;
            var addV:Number = Math.PI * 2 / detailV;
            var v:Number = 0;
            var h:Number = 0;
            for (var i:int = 0; i < detailH; i++) {
                v = 0;
                for (var j:int = 0; j < detailV; j++) {
                    r.renderPoint(new Vec3D(
                        Math.sin(v) * (outerSize + (outerSize - innerSize) * Math.cos(h)),
                        (outerSize- innerSize) * Math.sin(h),
                        Math.cos(v) * (outerSize + (outerSize - innerSize) * Math.cos(h))));
                    v += addV;
                }
                h += addH;
            }
            r.endScene();
        }
    }
}
import flash.display.*;

class Renderer {
    private var img:BitmapData;
    private var frame:Vector.<uint>;
    private var bitmap:Bitmap;
    private var width:uint;
    private var height:uint;
    private var aspect:Number;
    private var width2:uint;
    private var height2:uint;
    private var size:uint;
    private var cameraPosition:Vec3D;
    private var cameraTarget:Vec3D;
    private var cameraUp:Vec3D;
    private var worldMatrix:Mat4x4;
    private var viewMatrix:Mat4x4;
    private var projectionMatrix:Mat4x4;
    
    public function Renderer(width:uint, height:uint) {
        img = new BitmapData(width, height, false, 0);
        bitmap = new Bitmap(img);
        this.width = width;
        this.height = height;
        aspect = height / width;
        size = width * height;
        width2 = width >> 1;
        height2 = height >> 1;
        worldMatrix = new Mat4x4();
        viewMatrix = new Mat4x4();
        projectionMatrix = new Mat4x4();
        lookAt(new Vec3D(0, 0, 50),  new Vec3D(0, 0, 0), new Vec3D(0, 1, 0));
        perspective(60 * Math.PI / 180, 5, 5000);
    }
    
    public function get image():Bitmap {
        return bitmap;
    }
    
    public function rotateX(theta:Number):void {
        worldMatrix.rotateX(theta);
    }
    
    public function rotateY(theta:Number):void {
        worldMatrix.rotateY(theta);
    }
    
    public function rotateZ(theta:Number):void {
        worldMatrix.rotateZ(theta);
    }
    
    public function beginScene(background:uint):void {
        frame = img.getVector(img.rect);
        for (var i:int = 0; i < size; i++) {
            frame[i] = background;
        }
        worldMatrix.identity();
    }
    
    public function renderPoint(vertex:Vec3D):void {
        worldMatrix.mulEqualVector(vertex);
        viewMatrix.mulEqualVector(vertex);
        projectionMatrix.mulEqualVector(vertex);
        var invW:Number = 1 / vertex.w;
        vertex.x *= invW;
        vertex.y *= invW;
        vertex.z *= invW;
        vertex.x = (width2 + vertex.x * width2) >> 0;
        vertex.y = (height2 + vertex.y * height2) >> 0;
        if (vertex.x >= 0 && vertex.x < width && vertex.y >= 0 && vertex.y < height) {
            var index:uint = vertex.y * width + vertex.x;
            frame[index] = 0xffffff;
        }
    }
    
    public function endScene():void {
        img.setVector(img.rect, frame);
    }
    
    public function lookAt(position:Vec3D, target:Vec3D, up:Vec3D):void {
        cameraPosition = position;
        cameraTarget = target;
        cameraUp = up;
        var axisZ:Vec3D = cameraTarget.sub(cameraPosition);
        axisZ.normalize();
        var axisX:Vec3D = cameraUp.cross(axisZ);
        axisX.normalize();
        var axisY:Vec3D = axisZ.cross(axisX);
        viewMatrix.e00 = axisX.x;
        viewMatrix.e01 = axisY.x;
        viewMatrix.e02 = axisZ.x;
        viewMatrix.e03 = 0;
        viewMatrix.e10 = axisX.y;
        viewMatrix.e11 = axisY.y;
        viewMatrix.e12 = axisZ.y;
        viewMatrix.e13 = 0;
        viewMatrix.e20 = axisX.z;
        viewMatrix.e21 = axisY.z;
        viewMatrix.e22 = axisZ.z;
        viewMatrix.e23 = 0;
        viewMatrix.e30 = -axisX.dot(cameraPosition);
        viewMatrix.e31 = -axisY.dot(cameraPosition);
        viewMatrix.e32 = -axisZ.dot(cameraPosition);
        viewMatrix.e33 = 1;
    }
    
    public function perspective(fovY:Number, near:Number, far:Number):void {
        var h:Number = Math.cos(fovY * 0.5) / Math.sin(fovY * 0.5);
        var w:Number = h * aspect;
        var ffn:Number = far / (far - near);
        projectionMatrix.e00 = w;
        projectionMatrix.e01 = 0;
        projectionMatrix.e02 = 0;
        projectionMatrix.e03 = 0;
        projectionMatrix.e10 = 0;
        projectionMatrix.e11 = h;
        projectionMatrix.e12 = 0;
        projectionMatrix.e13 = 0;
        projectionMatrix.e20 = 0;
        projectionMatrix.e21 = 0;
        projectionMatrix.e22 = ffn;
        projectionMatrix.e23 = 1;
        projectionMatrix.e30 = 0;
        projectionMatrix.e31 = 0;
        projectionMatrix.e32 = -near * ffn;
        projectionMatrix.e33 = 0;
    }
}

class Vec3D {
    /*
     * [x y z w]
     */
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var w:Number;
    
    public function Vec3D(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0) {
        setVector(x, y, z, w);
    }
    
    public function setVector(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0):void {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }
    
    public function add(v:Vec3D):Vec3D {
        return new Vec3D(x + v.x, y + v.y, z + v.z);
    }
    
    public function addEqual(v:Vec3D):void {
        x += v.x;
        y += v.y;
        z += v.z;
    }
    
    public function sub(v:Vec3D):Vec3D {
        return new Vec3D(x - v.x, y - v.y, z - v.z);
    }
    
    public function subEqual(v:Vec3D):void {
        x -= v.x;
        y -= v.y;
        z -= v.z;
    }
    
    public function mul(s:Number):Vec3D {
        return new Vec3D(x * s, y * s, z * s);
    }
    
    public function mulEqual(s:Number):void {
        x *= s;
        y *= s;
        z *= s;
    }
    
    public function dot(v:Vec3D):Number {
        return x * v.x + y * v.y + z * v.z;
    }
    
    public function cross(v:Vec3D):Vec3D {
        return new Vec3D(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
    }
    
    public function length():Number {
        return Math.sqrt(x * x + y * y + z * z);
    }
    
    public function normalize():void {
        var length:Number = length();
        if (length > 0) {
            length = 1 / length;
            x *= length;
            y *= length;
            z *= length;
        }
    }
}

class Mat4x4 {
    /*
     * [e00 e01 e02 e03]
     * [e10 e11 e12 e13]
     * [e20 e21 e22 e23]
     * [e30 e31 e32 e33]
     */
    public var e00:Number;
    public var e01:Number;
    public var e02:Number;
    public var e03:Number;
    public var e10:Number;
    public var e11:Number;
    public var e12:Number;
    public var e13:Number;
    public var e20:Number;
    public var e21:Number;
    public var e22:Number;
    public var e23:Number;
    public var e30:Number;
    public var e31:Number;
    public var e32:Number;
    public var e33:Number;
    
    public function Mat4x4(e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1) {
        setMatrix(e00, e01, e02, e03, e10, e11, e12, e13,
            e20, e21, e22, e23, e30, e31, e32, e33);
    }
    
    public function identity():void {
        setMatrix();
    }
    
    
    public function setMatrix(e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1):void {
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e03 = e03;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e13 = e13;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        this.e23 = e23;
        this.e30 = e30;
        this.e31 = e31;
        this.e32 = e32;
        this.e33 = e33;
    }
    
    public function rotateX(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e11 = cos;
        m.e12 = sin;
        m.e21 = -sin;
        m.e22 = cos;
        mulEqualMatrix(m);
    }
    
    public function rotateY(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e00 = cos;
        m.e02 = sin;
        m.e20 = -sin;
        m.e22 = cos;
        mulEqualMatrix(m);
    }
    
    public function rotateZ(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e00 = cos;
        m.e01 = -sin;
        m.e10 = sin;
        m.e11 = cos;
        mulEqualMatrix(m);
    }
    
    public function mulMatrix(m:Mat4x4):Mat4x4 {
        var t11:Number = e00 * m.e00 + e01 * m.e10 + e02 * m.e20 + e03 * m.e30;
        var t12:Number = e00 * m.e01 + e01 * m.e11 + e02 * m.e21 + e03 * m.e31;
        var t13:Number = e00 * m.e02 + e01 * m.e12 + e02 * m.e22 + e03 * m.e32;
        var t14:Number = e00 * m.e03 + e01 * m.e13 + e02 * m.e23 + e03 * m.e33;
        var t21:Number = e10 * m.e00 + e11 * m.e10 + e12 * m.e20 + e13 * m.e30;
        var t22:Number = e10 * m.e01 + e11 * m.e11 + e12 * m.e21 + e13 * m.e31;
        var t23:Number = e10 * m.e02 + e11 * m.e12 + e12 * m.e22 + e13 * m.e32;
        var t24:Number = e10 * m.e03 + e11 * m.e13 + e12 * m.e23 + e13 * m.e33;
        var t31:Number = e20 * m.e00 + e21 * m.e10 + e22 * m.e20 + e23 * m.e30;
        var t32:Number = e20 * m.e01 + e21 * m.e11 + e22 * m.e21 + e23 * m.e31;
        var t33:Number = e20 * m.e02 + e21 * m.e12 + e22 * m.e22 + e23 * m.e32;
        var t34:Number = e20 * m.e03 + e21 * m.e13 + e22 * m.e23 + e23 * m.e33;
        var t41:Number = e30 * m.e00 + e31 * m.e10 + e32 * m.e20 + e33 * m.e30;
        var t42:Number = e30 * m.e01 + e31 * m.e11 + e32 * m.e21 + e33 * m.e31;
        var t43:Number = e30 * m.e02 + e31 * m.e12 + e32 * m.e22 + e33 * m.e32;
        var t44:Number = e30 * m.e03 + e31 * m.e13 + e32 * m.e23 + e33 * m.e33;
        return new Mat4x4(t11, t12, t13, t14, t21, t22, t23, t24, t31, t32, t33, t34, t41,
                t42, t43, t44);
    }
    
    public function mulEqualMatrix(m:Mat4x4):void {
        var t11:Number = e00 * m.e00 + e01 * m.e10 + e02 * m.e20 + e03 * m.e30;
        var t12:Number = e00 * m.e01 + e01 * m.e11 + e02 * m.e21 + e03 * m.e31;
        var t13:Number = e00 * m.e02 + e01 * m.e12 + e02 * m.e22 + e03 * m.e32;
        var t14:Number = e00 * m.e03 + e01 * m.e13 + e02 * m.e23 + e03 * m.e33;
        var t21:Number = e10 * m.e00 + e11 * m.e10 + e12 * m.e20 + e13 * m.e30;
        var t22:Number = e10 * m.e01 + e11 * m.e11 + e12 * m.e21 + e13 * m.e31;
        var t23:Number = e10 * m.e02 + e11 * m.e12 + e12 * m.e22 + e13 * m.e32;
        var t24:Number = e10 * m.e03 + e11 * m.e13 + e12 * m.e23 + e13 * m.e33;
        var t31:Number = e20 * m.e00 + e21 * m.e10 + e22 * m.e20 + e23 * m.e30;
        var t32:Number = e20 * m.e01 + e21 * m.e11 + e22 * m.e21 + e23 * m.e31;
        var t33:Number = e20 * m.e02 + e21 * m.e12 + e22 * m.e22 + e23 * m.e32;
        var t34:Number = e20 * m.e03 + e21 * m.e13 + e22 * m.e23 + e23 * m.e33;
        var t41:Number = e30 * m.e00 + e31 * m.e10 + e32 * m.e20 + e33 * m.e30;
        var t42:Number = e30 * m.e01 + e31 * m.e11 + e32 * m.e21 + e33 * m.e31;
        var t43:Number = e30 * m.e02 + e31 * m.e12 + e32 * m.e22 + e33 * m.e32;
        var t44:Number = e30 * m.e03 + e31 * m.e13 + e32 * m.e23 + e33 * m.e33;
        setMatrix(t11, t12, t13, t14, t21, t22, t23, t24, t31, t32, t33, t34, t41,
                t42, t43, t44);
    }
    
    public function mulVector(v:Vec3D):Vec3D {
        return new Vec3D(e00 * v.x + e10 * v.y + e20 * v.z + e30,
                    e01 * v.x + e11 * v.y + e21 * v.z + e31,
                    e02 * v.x + e12 * v.y + e22 * v.z + e32,
                    e03 * v.x + e13 * v.y + e23 * v.z + e33);
    }
    
    public function mulEqualVector(v:Vec3D):void {
        v.setVector(e00 * v.x + e10 * v.y + e20 * v.z + e30,
                    e01 * v.x + e11 * v.y + e21 * v.z + e31,
                    e02 * v.x + e12 * v.y + e22 * v.z + e32,
                    e03 * v.x + e13 * v.y + e23 * v.z + e33);
    }
}