// forked from yonatan's foggy forest/orchard
// forked from yonatan's fake infinity
// forked from yonatan's 1089 more trees
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import com.bit101.components.*;

    [SWF(width="465", height="465", frameRate="60")]
    public class main extends Sprite {
        public static const VS:int = 465; // viewport size
        public static const HVS:int = VS/2;
        public static const SS:int = 465; // stage size
        public static const HSS:int = SS/2;
        private const LINE_WIDTH_FACTOR:Number = 0.5;
        private const BRANCH_SCALE:Number = 0.85;//0.74;
        private const INIT_SIZE:Number = 120;
        private const GRID_CELLS:Number = 30;
        private const CELL_SIZE:Number = 350;
        private var sigl:SiGLCore = new SiGLCore(VS, VS);
        private var treeModifier:Number = 0;
        private var randomness:Number = 0.5;
        private var cbDrawAll:CheckBox;
        private var cbDraw:CheckBox;
        private var camSpeed:Number = 0.25;
        private var cam:SiGLMatrix = new SiGLMatrix;
        private var lastFrameTime:int = 0;
        private var minThickness:Number = 2;
        private var targetFPS:int = 24;
        private var maskAlpha:Number = 0.5;//1;
        private var mt:Label;
        private var mtx:Matrix = new Matrix; // temp matrix
        private var tv:Vector3D = new Vector3D;
        private var ui:Sprite = new Sprite;
        private var lines:Vector.<Line> = new Vector.<Line>;

        public function main() {
            stage.quality = "medium";
            //stage.scaleMode = "noScale";
            x = y = HSS;
            addChild(ui);
            //sigl.fieldOfView = 50;
            sigl.setZRange(-1000, 1000 + GRID_CELLS/2 * CELL_SIZE);
            addEventListener("enterFrame", onEnterFrame);

            var uix:int = -HSS+5, uiy:int = -HSS+5;
            var that:main = this;
            function _slider(txt:String, valVar:String, min:Number, max:Number, val:Number):void {
                var s:HUISlider = new HUISlider(ui, uix, uiy, txt, function(e:Event):void { that[valVar] = e.target.value; });
                s.minimum = min; s.maximum = max; that[valVar] = s.value = val; uiy += 16;
            }

            // cbDrawAll = new CheckBox(ui, uix, uiy, "Draw all computed branches (incl. clipped ones)"); uiy += 16;
            // cbDraw = new CheckBox(ui, uix, uiy, "Draw"); uiy += 16;
            // cbDraw.selected = true;
            _slider("Target FPS", "targetFPS", 6, 40, 20);
            _slider("Orchard/Forest", "randomness", 0, 1, 1);
            _slider("Tree Modifier", "treeModifier", -1, 3, 2);
            // _slider("Mask alpha", "maskAlpha", 0.5, 1, 1);

            new FPSMeter(ui, HSS-100, -HSS+5);
            mt = new Label(ui, HSS-100, -HSS+5+18);
            ui.graphics.beginFill(0xffcccc, 0.9);
            ui.graphics.drawRect(-HSS, -HSS, SS, 60);
            ui.graphics.endFill();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:*):void { ui.visible = true; });
            stage.addEventListener(Event.MOUSE_LEAVE, function(e:*):void { ui.visible = false; });
            ui.visible = false;
        }

        private function onEnterFrame(e:Event):void {
            var t:int = getTimer();
            var renderTime:int = t - lastFrameTime;
            lastFrameTime = t;
            var timeDiff:Number = Math.abs(renderTime - 1000/targetFPS);
            if(timeDiff > 200/targetFPS) { // don't adjust unless we have to (reduces flicker)
                minThickness *= (renderTime > 1000/targetFPS) ? 1.1 : 0.9;
                if(minThickness < 1.5) minThickness = 1.5;
            }
            mt.text = "Min. thickness: " + minThickness.toFixed(2);
            graphics.clear();

            var cx:Number = Math.sin(t/(5678/camSpeed)) * 1500;
            var cz:Number = Math.cos(t/(4567/camSpeed)) * 1500;
            var cy:Number = Math.cos(t/(3456/camSpeed)) * 500 - 500;
            var camrz:Number = 15 * Math.sin(t/(3456/2/camSpeed));
            cam.id().prependTranslation(cx, cy, cz);
            cam.lookAt(cx,cy,cz, 0,-INIT_SIZE/BRANCH_SCALE,0, 0,1,0, 1);
            cam.appendRotation(camrz, Vector3D.Z_AXIS);
            sigl.setCameraMatrix(cam);

            tv.setTo(-cx, 0, -cz);
            tv.normalize();
            tv.scaleBy(sigl.zFar);
            tv.x += cx;
            tv.z += cz;
            sigl.id().m(sigl.projectionMatrix).t(tv.x, tv.y, tv.z);
            projxy(tv);

            mtx.createGradientBox(VS, VS, -Math.PI/2 + camrz/180*Math.PI, -HVS + tv.x, -HVS + tv.y);
            graphics.beginGradientFill("linear",[0xffffff,0xf0f0f0,0xffffff],[1,1,1],[128,132,160],mtx,"pad","rgb",0);
            graphics.drawRect(-HVS, -HVS, VS, VS);
            graphics.endFill();

            sigl.id().m(sigl.modelViewProjectionMatrix); // work in projected space, no need to transform in projxy()...
            var rnd:Number = 0;
            var i:int = 0;
            var halfSide:Number = GRID_CELLS/2 * CELL_SIZE;
            for(var x:int = -halfSide; x <= halfSide; x += CELL_SIZE) {
                for(var z:int = -halfSide; z <= halfSide; z += CELL_SIZE) {
                    rnd = (rnd * 1664525 + 1013904223) & 0xffffffff;
                    var r1:Number = rnd/0xffffffff * randomness;
                    rnd = (rnd * 1664525 + 1013904223) & 0xffffffff;
                    var r2:Number = rnd/0xffffffff * randomness;
                    var h:Number = r1 * 0.5 + 0.75;
                    var w:Number = (1-r1) * 0.5 + 0.75;
                    sigl.push().t(x + CELL_SIZE * 0.75 * r1, 0, z + CELL_SIZE * 0.75 * r2).r(rnd, Vector3D.Y_AXIS).s(w,h,w);
                    tree(INIT_SIZE);
                    sigl.pop();
                }
            }

            lines.sort(Line.comparator);
            for(i=0; i<lines.length; i++) {
                lines[i].draw(graphics);
                Line.free(lines[i]);
            }
            lines.length = 0;

            // // horizon marker
            // graphics.beginFill(0xff0000);
            // graphics.drawCircle(tv.x, tv.y, 2);
            // graphics.endFill();

            graphics.lineStyle();
            graphics.beginFill(0xa0a0a0, cbDrawAll && cbDrawAll.selected ? 0.5 : 1); // maskAlpha);
            graphics.drawRect(-HSS, -HSS, SS, SS);
            graphics.drawRect(-HVS, -HVS, VS, VS);
            graphics.endFill();
        }

        private function projxy(v:Vector3D):void {
            sigl.matrix.copyColumnTo(3, v);
            v.x /= v.w;
            v.y /= v.w;
        }
        private var p1:Vector3D = new Vector3D, p2:Vector3D = new Vector3D;
        private function tree(size:Number):void {
            sigl.push();
            projxy(p1);
            var limit:Number = size/BRANCH_SCALE / (1 - BRANCH_SCALE);
            var xl:Number = HVS+limit/p1.w;
            var yl:Number = HVS+limit/p1.w;
            if(p1.z > sigl.zNear-limit && p1.z < sigl.zFar//+limit
                && p1.x > -xl && p1.x < xl
                && p1.y > -yl && p1.y < yl
            ) {
                size *= BRANCH_SCALE;
                sigl.t(0, -size, 0);
                projxy(p2);
                var midZ:Number = (p1.w+p2.w) * 0.5;
                var thickness:Number = size * LINE_WIDTH_FACTOR / midZ;
                // crude clipping
                var cs:Number = HVS + thickness * 0.5;

                var alpha:Number = 1;//Math.min(1, thickness-minThickness+1);//thickness/minThickness-1;
                var r:Number, g:Number, b:Number;
                var color:uint;
                var t1:Number = 0.5 * size * LINE_WIDTH_FACTOR / p1.w;
                var t2:Number = 0.5 * size * LINE_WIDTH_FACTOR / p2.w * BRANCH_SCALE;
                var fog:Number = (1-Math.pow(1-p2.z/sigl.zFar, 3));
                if(thickness <= minThickness) {
                    t1 *= 5;
                    t2 *= 5;
                    p2.x -= (p1.x-p2.x)*3;
                    p2.y -= (p1.y-p2.y)*3;
                    r = fog * 0.9 + (1-fog) * 0.10;
                    g = fog * 0.9 + (1-fog) * 0.25;
                    b = fog * 0.9 + (1-fog) * 0.20;
                } else {
                    r = fog * 0.9 + (1-fog) * 0.20;
                    g = fog * 0.9 + (1-fog) * 0.15;
                    b = fog * 0.9 + (1-fog) * 0.10;
                }
                color = (r*255<<16) + (g*255<<8) + b*255;

                var isClipped:Boolean = 
                (p1.x < -cs && p2.x < -cs) || 
                (p1.x > cs && p2.x > cs) || 
                (p1.y < -cs && p2.y < -cs) || 
                (p1.y > cs && p2.y > cs) || 
                // p1.z < sigl.zNear || p2.z < sigl.zNear || 
                p1.w<0 || p2.w<0 ||
                // p1.z > sigl.zFar || p2.z > sigl.zFar
                p1.w > p1.z || p2.w > p2.z
                ;

                if((cbDrawAll && cbDrawAll.selected) || !isClipped) {
                    if(!cbDraw || cbDraw.selected) {
                        lines.push(Line.alloc(p1.x, p1.y, t1, p2.x, p2.y, t2, midZ, color, alpha));
                    }
                }


                if(thickness > minThickness) {
                    sigl.r(221, Vector3D.Y_AXIS);
                    tree(size);
                    var s:Number  = 0.7;
                    sigl.t(0,size*-treeModifier,0).r(40, Vector3D.X_AXIS).s(1.33,0.5,1.33);
                    tree(size/BRANCH_SCALE*0.66);
                }
            }
            sigl.pop();
        }
    }
}

import flash.display.*;
import flash.geom.*;

class Line {
    static private var _freeList:Vector.<Line> = new Vector.<Line>();
    public var x1:Number, y1:Number, t1:Number, x2:Number, y2:Number, t2:Number, z:Number, color:Number, alpha:Number;
    public static function free(line:Line):void { _freeList.push(line); }
    public static function alloc(x1:Number, y1:Number, t1:Number, x2:Number, y2:Number, t2:Number, z:Number, color:Number, alpha:Number):Line {
        var l:Line = _freeList.pop() || new Line();
        l.x1 = x1; l.y1 = y1; l.t1 = t1; l.x2 = x2; l.y2 = y2; l.t2 = t2; l.z = z; l.color = color; l.alpha = alpha;
        return l;
    }
    public static function comparator(a:Line, b:Line):Number { return a.z > b.z ? -1 : 1; }

    private var cmd:Vector.<int> = new <int> [1, 2, 2, 2];
    private var coord:Vector.<Number> = new Vector.<Number>(8,true);
    public function draw(g:Graphics):void {
        var dx:Number = x2-x1;
        var dy:Number = y2-y1;
        var len:Number = Math.sqrt(dx*dx+dy*dy);
        dx /= len;
        dy /= len;
        var dxt1:Number = dx*t1, dxt2:Number = dx*t2, dyt1:Number = dy*t1, dyt2:Number = dy*t2;
        coord[0] = x1-dyt1; coord[1] = y1+dxt1;
        coord[2] = x1+dyt1; coord[3] = y1-dxt1;
        coord[4] = x2+dyt2; coord[5] = y2-dxt2;
        coord[6] = x2-dyt2; coord[7] = y2+dxt2;
        g.beginFill(color,alpha);
        g.drawPath(cmd, coord); 
        g.endFill();
    }
}

// useful stuff by keim_at_Si (probably from the boolean crystals demo - http://wonderfl.net/c/vpLs )
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
    public function copyFrom(v:Vector.<Number>, i:uint = 0, t:Boolean = false) : SiGLCore { matrix.copyRawDataFrom(v, i, t); matrix._invdir = _mvpdir = true; return this; }
    public function copyTo(v:Vector.<Number>, i:uint = 0, t:Boolean = false) : SiGLCore { matrix.copyRawDataTo(v, i, t); return this; }
}


/** SiGLMatrix is extention of Matrix3D with push/pop operation */
class SiGLMatrix extends Matrix3D {
    internal var _invdir:Boolean = false, _inv:Matrix3D = new Matrix3D(), _stac:Vector.<Matrix3D> = new Vector.<Matrix3D>();
    static private var _tv:Vector.<Number> = new Vector.<Number>(16, true), _tm:Matrix3D = new Matrix3D();
    static private var _in:Vector.<Number> = new Vector.<Number>(4, true), _out:Vector.<Number> = new Vector.<Number>(4, true);
    public var sp:int = 0;
    public function get inverted() : Matrix3D { if (_invdir) { _inv.copyFrom(this); _inv.invert(); _invdir = false; } return _inv; }
    public function forceUpdateInvertedMatrix() : SiGLMatrix { _invdir=true; return this; }
    public function clear() : SiGLMatrix { sp = 0; return id(); }
    public function id() : SiGLMatrix { identity(); _inv.identity(); return this; }
    public function push() : SiGLMatrix {
        if(_stac.length == sp) _stac.push(new Matrix3D());
        _stac[sp++].copyFrom(this);
        return this; 
    }
    public function pop() : SiGLMatrix {
        this.copyFrom(_stac[--sp]);
        _invdir=true;
        return this;
    }
    public function rem() : SiGLMatrix { this.copyFrom(_stac[sp-1]); _invdir=true; return this; }
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
        // The matrix from adobe's PerspectiveMatrix3D one is what http://msdn.microsoft.com/en-us/library/windows/desktop/bb153308%28v=vs.85%29.aspx 
        // calls "compliant", but this one seems to produce a transformed w that works for my projxy(). I'm not really sure why. This might be wrong.
        var n:Number = 1/((main.HVS) / Math.tan(fieldOfViewY * 0.5));
        this.copyRawDataFrom(Vector.<Number>([xScale,0,0,0,0,yScale,0,0,0,0,zFar/(zFar-0)*lh,n*lh,0,0,0,0]));
    }
    public function transform(vector:Vector3D) : Vector3D {
        _in[0] = vector.x; _in[1] = vector.y; _in[2] = vector.z; _in[3] = vector.w;
        transformVectors(_in, _out); vector.setTo(_out[0], _out[1], _out[2]); vector.w = _out[3];
        return vector;
    }
}
