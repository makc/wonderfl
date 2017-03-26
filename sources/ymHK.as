package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import com.bit101.components.*;

    [SWF(width="465", height="465")]
    public class main extends Sprite {
        private const MIN_THICKNESS:Number = 1;
        private const LINE_WIDTH_FACTOR:Number = 0.5;
        private const BRANCH_SCALE:Number = 0.75;
        private const VS:int = 300; // viewport size
        private const HVS:int = VS/2;
        private const SS:int = 465; // stage size
        private const HSS:int = SS/2;
        private const INIT_SIZE:Number = 120;
        private var sigl:SiGLCore = new SiGLCore(VS, VS);
        private var cbDrawAll:CheckBox;
        private var slDistance:HUISlider;
        private var distance:Number;
        private var slRotY:HUISlider;
        private var slMaskAlpha:HUISlider;

        public function main() {
            // stage.quality = "medium";
            x = y = HSS;
            sigl.fieldOfView = 45;
            addEventListener("enterFrame", onEnterFrame);

            var uix:int = -HSS+5, uiy:int = -HSS+5;
            cbDrawAll = new CheckBox(this, uix, uiy, "Draw all computed branches (incl. clipped ones)"); uiy += 18;
            slDistance = new HUISlider(this, uix, uiy, "Distance"); uiy += 18;
            slDistance.minimum = sigl.zNear + INIT_SIZE / (1 - BRANCH_SCALE);
            slDistance.maximum = 4000;
            distance = slDistance.value = slDistance.minimum;
            slRotY = new HUISlider(this, uix, uiy, "Rot Y"); uiy += 18;
            slRotY.minimum = -180;
            slRotY.maximum = 180;
            slRotY.value = 0;
            slMaskAlpha = new HUISlider(this, uix, uiy, "Mask alpha"); uiy += 18;
            slMaskAlpha.minimum = 0.5;
            slMaskAlpha.maximum = 1;
            slMaskAlpha.value = 0.8;
        }

        private function onEnterFrame(e:Event):void {
            graphics.clear();
            if(slRotY.value == 180) slRotY.value = -180;
            else slRotY.value += 0.25;
            distance = distance * 0.8 + slDistance.value * 0.2;
            sigl.id().t(0, 150, -distance).r(slRotY.value, Vector3D.Y_AXIS);//.r(Math.sin(getTimer()/5670)*20, Vector3D.Z_AXIS);
            render(INIT_SIZE);

            graphics.lineStyle();
            graphics.beginFill(0xffeedd, slMaskAlpha.value);
            graphics.drawRect(-HSS, -HSS, SS, SS);
            graphics.drawRect(-HVS, -HVS, VS, VS);
            graphics.endFill();
        }

        private var p1:Vector3D = new Vector3D, p2:Vector3D = new Vector3D;
        private function render(size:Number):void {
            function proj(v:Vector3D):void {
                sigl.projectionMatrix.transform(sigl.matrix.position, v);
                v.w = v.z/sigl.focalLength;
                v.project();
            }
            sigl.push();
            proj(p1);
            var limit:Number = size / (1 - BRANCH_SCALE);
            var xl:Number = HVS+limit;
            var yl:Number = HVS+limit;
            if(p1.x > -xl && p1.x < xl
                && p1.y > -yl && p1.y < yl
                // && p1.z+limit > sigl.zNear && p1.z-limit < sigl.zFar
            ) {
                size *= BRANCH_SCALE;
                sigl.t(0, -size, 0);
                proj(p2);
                var thickness:Number = size * LINE_WIDTH_FACTOR / ((p1.w+p2.w)*0.5);
                if(thickness > MIN_THICKNESS) {
                    var cs:Number = HVS + thickness * 0.5;
                    if(cbDrawAll.selected || !( // crude clipping
                            (p1.x < -cs && p2.x < -cs) ||
                            (p1.x > cs && p2.x > cs) ||
                            (p1.y < -cs && p2.y < -cs) ||
                            (p1.y > cs && p2.y > cs)
                        )) {
                        // alpha value for nicer transition, multiplier to avoid it as much as possible (performance)... doesn't make too much sense, i know
                        graphics.lineStyle(thickness, 0, (thickness-MIN_THICKNESS)*16, false, "normal", "none");
                        graphics.moveTo(p1.x, p1.y);
                        graphics.lineTo(p2.x, p2.y);
                    }
                    sigl.r(120, Vector3D.Y_AXIS).r(-30, Vector3D.X_AXIS);
                    render(size);
                    sigl.r(70, Vector3D.X_AXIS);
                    render(size);
                }
            }
            sigl.pop();
        }
    }
}

import flash.geom.*;

// useful stuff by keim_at_Si (i think i copied it from the boolean crystals demo)
// modifications:
// - dest arg in SiGLMatrix transform() function
// - reuse objects on SiGLMatrix stack in push, pop, rem (rem might be broken now)
// - focalLength, zNear, zFar getters in SiGLCore

/** SiGLCore provides basic matrix operations. */
class SiGLCore {
    // variables ----------------------------------------
    public var modelViewMatrix:SiGLMatrix = new SiGLMatrix(), projectionMatrix:SiGLMatrix = new SiGLMatrix();
    public var viewWidth:Number, viewHeight:Number, pointSpriteFieldScale:Point = new Point();
    public var defaultCameraMatrix:SiGLMatrix = new SiGLMatrix(), matrix:SiGLMatrix = modelViewMatrix;
    private var _mvpMatrix:SiGLMatrix = new SiGLMatrix(), _mvpdir:Boolean, _2d:Number, _2r:Number;
    private var _mag:Number, _zNear:Number, _zFar:Number, _fieldOfView:Number, _fl:Number, _alignTopLeft:Boolean = false;
    // properties ----------------------------------------
    public function get modelViewProjectionMatrix() : SiGLMatrix {
        if (_mvpdir) {
            _mvpMatrix.copyFrom(projectionMatrix);
            _mvpMatrix.prepend(modelViewMatrix);
            _mvpdir = false;
        }
        return _mvpMatrix;
    }
    public function get focalLength() : Number { return _fl; }
    public function get zNear() : Number { return _zNear; }
    public function get zFar() : Number { return _zFar; }
    public function get align() : String { return (_alignTopLeft) ? "topLeft" : "center"; }
    public function set align(mode:String) : void { _alignTopLeft = (mode == "topLeft"); _updateProjectionMatrix(); }
    public function get matrixMode() : String { return (matrix === projectionMatrix) ? "projection" : "modelView"; }
    public function set matrixMode(mode:String) : void { matrix = (mode == "projection") ? projectionMatrix : modelViewMatrix; }
    public function get angleMode() : String { return (_2r == 1) ? "radian" : "degree"; }
    public function set angleMode(mode:String) : void { _2d = (mode == "radian") ? 57.29577951308232 : 1; _2r = (mode == "radian") ? 1 : 0.017453292519943295; }
    public function get fieldOfView() : Number { return _fieldOfView / _2r; }
    public function set fieldOfView(fov:Number) : void { _fieldOfView = fov * _2r; _updateProjectionMatrix(); }
    public function get magnification() : Number { return _mag; }
    public function set magnification(mag:Number) : void { _mag = mag; _updateProjectionMatrix(); }
    // constructor ----------------------------------------
    function SiGLCore(width:Number=1, height:Number=1) {
        viewWidth = width; viewHeight = height;
        angleMode = "degree"; _mag = 1;
        _zNear = -1000; _zFar = 200;
        modelViewMatrix.identity();
        _mvpdir = true;
        this.fieldOfView = 60;
    }
    // matrix operations ----------------------------------------
    public function forceUpdateMatrix() : SiGLCore { _mvpdir = true; return this; }
    public function setZRange(zNear:Number=-100, zFar:Number=100) : SiGLCore { _zNear = zNear; _zFar = zFar; _updateProjectionMatrix(); return this; }
    public function clear() : SiGLCore { matrix.clear(); _mvpdir = true; return this; }
    public function id() : SiGLCore { matrix.id(); _mvpdir = true; return this; }
    public function push() : SiGLCore { matrix.push(); return this; }
    public function pop() : SiGLCore { matrix.pop(); _mvpdir = true; return this; }
    public function rem() : SiGLCore { matrix.rem(); _mvpdir = true; return this; }
    public function r(a:Number, axis:Vector3D, pivot:Vector3D = null) : SiGLCore { matrix.prependRotation(a*_2d, axis, pivot); matrix._invdir = _mvpdir = true; return this; }
    public function s(x:Number, y:Number, z:Number=1) : SiGLCore { matrix.prependScale(x, y, z); matrix._invdir = _mvpdir = true; return this; }
    public function t(x:Number, y:Number, z:Number=0) : SiGLCore { matrix.prependTranslation(x, y, z); matrix._invdir = _mvpdir = true; return this; }
    public function m(mat:Matrix3D) : SiGLCore { matrix.prepend(mat); matrix._invdir = _mvpdir = true; return this; }
    public function re(x:Number, y:Number, z:Number) : SiGLCore { matrix.prependRotationXYZ(x*_2r, y*_2r, z*_2r); _mvpdir = true; return this; }
    public function setCameraMatrix(mat:Matrix3D=null) : SiGLCore { projectionMatrix.rem().prepend(mat || defaultCameraMatrix); _mvpdir = true; return this; }
    private function _updateProjectionMatrix() : void {
        var wh:Number = viewWidth / viewHeight, rev:Number = (_alignTopLeft)?-1:1;
        _fl = (viewHeight * 0.5) / Math.tan(_fieldOfView * 0.5);
        if (_zNear <= -_fl) _zNear = -_fl + 0.001;
        projectionMatrix.clear().perspectiveFieldOfView(_fieldOfView, wh, _zNear+_fl, _zFar+_fl, -1);
        pointSpriteFieldScale.setTo(projectionMatrix.rawData[0] * _fl, projectionMatrix.rawData[5] * _fl);
        projectionMatrix.push();
        defaultCameraMatrix.identity();
        defaultCameraMatrix.prependTranslation(0, 0, -_fl);
        if (_alignTopLeft) defaultCameraMatrix.prependTranslation(viewWidth* 0.5, -viewHeight * 0.5, 0);
        defaultCameraMatrix.prependScale(_mag, _mag * rev, _mag * rev);
        setCameraMatrix();
    }
}


/** SiGLMatrix is extention of Matrix3D with push/pop operation */
class SiGLMatrix extends Matrix3D {
    internal var _top:int = 0, _invdir:Boolean = false, _inv:Matrix3D = new Matrix3D(), _stac:Vector.<Matrix3D> = new Vector.<Matrix3D>();
    static private var _tv:Vector.<Number> = new Vector.<Number>(16, true), _tm:Matrix3D = new Matrix3D();
    static private var _in:Vector.<Number> = new Vector.<Number>(4, true), _out:Vector.<Number> = new Vector.<Number>(4, true);
    public function get inverted() : Matrix3D { if (_invdir) { _inv.copyFrom(this); _inv.invert(); _invdir = false; } return _inv; }
    public function forceUpdateInvertedMatrix() : SiGLMatrix { _invdir=true; return this; }
    public function clear() : SiGLMatrix { _top = 0; return id(); }
    public function id() : SiGLMatrix { identity(); _inv.identity(); return this; }
    public function push() : SiGLMatrix {
        if(_stac.length == _top) _stac.push(new SiGLMatrix());
        _stac[_top++].copyFrom(this);
        return this; 
    }
    public function pop() : SiGLMatrix { 
        this.copyFrom(_stac[--_top]);
        _invdir=true;
        return this;
    }
    public function rem() : SiGLMatrix { this.copyFrom(_stac[_top-1]); _invdir=true; return this; }
    public function prependRotationXYZ(rx:Number, ry:Number, rz:Number) : SiGLMatrix {
        var sx:Number = Math.sin(rx), sy:Number = Math.sin(ry), sz:Number = Math.sin(rz), 
        cx:Number = Math.cos(rx), cy:Number = Math.cos(ry), cz:Number = Math.cos(rz);
        _tv[0] = cz*cy; _tv[1] = sz*cy; _tv[2] = -sy; _tv[4] = -sz*cx+cz*sy*sx; _tv[5] = cz*cx+sz*sy*sx;
        _tv[6] = cy*sx; _tv[8] = sz*sx+cz*sy*cx; _tv[9] = -cz*sx+sz*sy*cx;
        _tv[10] = cy*cx; _tv[14] = _tv[13] = _tv[12] = _tv[11] = _tv[7] = _tv[3] = 0; _tv[15] = 1;
        _tm.copyRawDataFrom(_tv); prepend(_tm); _invdir=true;
        return this;
    }
    public function lookAt(cx:Number, cy:Number, cz:Number, tx:Number=0, ty:Number=0, tz:Number=0, ux:Number=0, uy:Number=1, uz:Number=0, w:Number=0) : SiGLMatrix {
        var dx:Number=tx-cx, dy:Number=ty-cy, dz:Number=tz-cz, dl:Number=-1/Math.sqrt(dx*dx+dy*dy+dz*dz), 
        rx:Number=dy*uz-dz*uy, ry:Number=dz*ux-dx*uz, rz:Number=dx*uy-dy*ux, rl:Number= 1/Math.sqrt(rx*rx+ry*ry+rz*rz);
        _tv[0]  = (rx*=rl); _tv[4]  = (ry*=rl); _tv[8]  = (rz*=rl); _tv[12] = -(cx*rx+cy*ry+cz*rz) * w;
        _tv[2]  = (dx*=dl); _tv[6]  = (dy*=dl); _tv[10] = (dz*=dl); _tv[14] = -(cx*dx+cy*dy+cz*dz) * w;
        _tv[1]  = (ux=dy*rz-dz*ry); _tv[5]  = (uy=dz*rx-dx*rz); _tv[9]  = (uz=dx*ry-dy*rx); _tv[13] = -(cx*ux+cy*uy+cz*uz) * w;
        _tv[3] = _tv[7] = _tv[11] = 0; _tv[15] = 1; copyRawDataFrom(_tv); _invdir=true;
        return this;
    }
    public function perspectiveFieldOfView(fieldOfViewY:Number, aspectRatio:Number, zNear:Number, zFar:Number, lh:Number=1.0) : void {
        var yScale:Number = 1.0 / Math.tan(fieldOfViewY * 0.5), xScale:Number = yScale / aspectRatio;
        this.copyRawDataFrom(Vector.<Number>([xScale,0,0,0,0,yScale,0,0,0,0,zFar/(zFar-zNear)*lh,lh,0,0,(zNear*zFar)/(zNear-zFar),0]));
    }
    public function transform(vector:Vector3D, dest:Vector3D = null) : Vector3D {
        if(!dest) dest = vector;
        _in[0] = vector.x; _in[1] = vector.y; _in[2] = vector.z; _in[3] = vector.w;
        transformVectors(_in, _out); dest.setTo(_out[0], _out[1], _out[2]); dest.w = _out[3];
        return dest;
    }
}
