// forked from yonatan's MCE on SiGL
// forked from keim_at_Si's wonderflで3D 【Phong shading】
// forked from keim_at_Si's wonderflで3D 【Flat shading】 高速化
// forked from keim_at_Si's wonderflで3D 【Flat shading】
// 高速化，マウスで光源移動，クリックで材質変更
//--------------------------------------------------
package {
    import flash.display.*;
    import flash.text.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.filters.*;
    import flash.ui.*;
    // import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0xE0E0E0", frameRate="30")]
    public class main extends Sprite {
        private const _sides:int = 4;
        private const _sections:int = 72;
        private var _matrix:Matrix3D = new Matrix3D();
        private var _rotMatrix:Matrix3D = new Matrix3D();
        private var _engine:EngineFaceBasedRender = new EngineFaceBasedRender(800, _sections*_sides*8);
        private var _material:Material = new Material;
        private var _light:Light = new Light();
        private var _models:Array = [];
        private var _model:Knot;
        private var _transformedSideNormals:Vector.<Number> = new Vector.<Number>();
        private var _mousePoint:Point;
        private var _timeSum:int, _timeCount:int;
        private var _textField:TextField = new TextField();
        
        function main() {
            var i:int;

            for (i=0; i<60; i++) _models.push(new Knot(2, 3, _sections, _sides, 2/3, i/60));

            stage.quality = "medium";
            _engine.x = 232;
            _engine.y = 232;
            // GlowFilter(color:uint = 0xFF0000, alpha:Number = 1.0, blurX:Number = 6.0, blurY:Number = 6.0,
            // strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false)
            _engine.filters = [new GlowFilter(0, 1, 4, 4, 2, 2)];
            addChild(_engine);
            addEventListener("enterFrame", _onEnterFrame);
            Mouse.cursor = MouseCursor.BUTTON;
            stage.addEventListener("mouseDown", function(e:Event):void { 
                    _mousePoint = new Point(mouseX, mouseY); 
                    Mouse.cursor = MouseCursor.HAND;
                });
            stage.addEventListener("mouseUp", function(e:Event):void {
                    _mousePoint = null; 
                    Mouse.cursor = MouseCursor.BUTTON;
                });

            // initialize parameters
            // _timeSum = 0;
            // _timeCount = 0;
            // _textField.autoSize = "left";
            // _textField.background = true;
            // _textField.backgroundColor = 0x80f080;
            // addChild(_textField);
            // var status:Stats = new Stats();
            // status.x = 400;
            // addChild(status);
        }

        private function _onEnterFrame(e:Event) : void {
            var i:int, t:int;
            _model = _models[int(getTimer()/10) % _models.length];

            // update paremters
            if(_mousePoint) {
                var p:Point = new Point(mouseX, mouseY).subtract(_mousePoint);
                var axis:Vector3D = new Vector3D(p.y, -p.x, 0); 
                axis.normalize();
                _rotMatrix.appendRotation(p.length/2, axis)
                _mousePoint.x = mouseX;
                _mousePoint.y = mouseY;
            }

            // light position
            var lx:Number = (Math.max(0, Math.min(2, mouseX / (465 / 2))) - 1) / Math.SQRT2;
            var ly:Number = (Math.max(0, Math.min(2, mouseY / (465 / 2))) - 1) / Math.SQRT2;
            var lz:Number = -Math.sqrt(1 - (lx*lx+ly*ly));
            _light.setPosition(lx, ly, lz);
            
            t = getTimer();
            _engine.pushMatrix();

            _matrix.identity();
            _matrix.append(_rotMatrix);
            _matrix.appendScale(10, 10, 10);
            _matrix.appendTranslation(0, 0, 150);
            _engine.matrix.append(_matrix);
            _engine.project(_model);
            _calculateVertexNormal();
            _engine.render(_model, _light, _material);
            _engine.popMatrix();
            _timeSum += getTimer() - t;
            
            // if (++_timeCount == 30) {
            //     _textField.text = "Redering time: " + String(_timeSum) + "[ms/30frames]";
            //     _timeSum = 0;
            //     _timeCount = 0;
            // }
        }
        
        private function _calculateVertexNormal() : void {
            var len:int = _transformedSideNormals.length;
            var ni:int = 0;
            var ti:int = 0;
            _rotMatrix.transformVectors(_model.sideNormals, _transformedSideNormals);
            while (ni<len) {
                var nx:Number = _transformedSideNormals[ni++];
                var ny:Number = _transformedSideNormals[ni++];
                var nz:Number = _transformedSideNormals[ni++];
                var v:Vector3D = _light.direction;
                var intensity:Number = v.x * nx + v.y * ny + v.z * nz;
                intensity *= intensity;
                //if(intensity<0) intensity = -intensity; // saturate
                if(nz>0) intensity = -intensity; // front/back material
                var u:Number = 0.5 + intensity/2;
                _model.texCoord[ti] = u; ti+=3;
                _model.texCoord[ti] = u; ti+=3;
                _model.texCoord[ti] = u; ti+=3;
                _model.texCoord[ti] = u; ti+=3;
            }
        }
    }
}

import flash.display.*;
import flash.filters.*;
import flash.geom.*;

class EngineFaceBasedRender extends Shape {
    public var matrix:Matrix3D;
    
    private var _vertexOnWorld:Vector.<Number>;
    private var _vout:Vector.<Number>;
    
    private var _projector:PerspectiveProjection;
    private var _projectionMatrix:Matrix3D;
    private var _matrixStac:Vector.<Matrix3D>;

    function EngineFaceBasedRender(focus:Number=400, numVerts:int = 0) {
        _vertexOnWorld = new Vector.<Number>(numVerts*3, numVerts != 0);
        _vout = new Vector.<Number>;

        _projector  = new PerspectiveProjection();
        _matrixStac = new Vector.<Matrix3D>();
        initialize(focus);
    }

    public function initialize(focus:Number) : EngineFaceBasedRender {
        _projector.focalLength = focus;
        _projectionMatrix = _projector.toMatrix3D();
        matrix = new Matrix3D();
        _matrixStac.length = 1;
        _matrixStac[0] = matrix;
        return this;
    }

    public function clearMatrix() : EngineFaceBasedRender { 
        matrix = _matrixStac[0];
        _matrixStac.length = 1;
        return this;
    }
    
    public function pushMatrix() : EngineFaceBasedRender {
        _matrixStac.push(matrix.clone());
        return this;
    }
    
    public function popMatrix() : EngineFaceBasedRender {
        if (_matrixStac.length == 1) return this;
        matrix = _matrixStac.pop();
        return this;
    }
    
    public function project(model:Model) : EngineFaceBasedRender {
        matrix.transformVectors(model.vertices, _vertexOnWorld);
        var vertices:Vector.<Number> = _vertexOnWorld;
        for each (var face:Face in model.faces) {
            var z:Number;
            z = vertices[int(int((face.i0<<1) + face.i0) + 2)];
            z += vertices[int(int((face.i1<<1) + face.i1) + 2)];
            z += vertices[int(int((face.i2<<1) + face.i2) + 2)];
            face.z = z;
        }
        model.faces.sort(function(f1:Face, f2:Face) : Number { return f2.z - f1.z; });
        return this;
    }
    
    public function render(model:Model, light:Light, material:Material) : EngineFaceBasedRender {
        Utils3D.projectVectors(_projectionMatrix, _vertexOnWorld, _vout, model.texCoord);
        graphics.clear();
        graphics.beginBitmapFill(material.texture, null, false, true);
        graphics.drawTriangles(_vout, model.indices, model.texCoord);
        graphics.endFill();
        return this;
    }
}

class Face {
    public var i0:int, i1:int, i2:int, z:Number;

    // Factory
    static private var _freeList:Vector.<Face> = new Vector.<Face>();
    static public function alloc() : Face { return _freeList.pop() || new Face(); }
    static public function free(face:Face) : void { _freeList.push(face); }
}

class Model {
    public var vertices:Vector.<Number>;
    public var texCoord:Vector.<Number>;
    public var faces:Vector.<Face>;
    private var _indices:Vector.<int> = new Vector.<int>();
    private var _faceIdx:int = 0;

    function Model(vertices:Vector.<Number>=null, texCoord:Vector.<Number>=null, faces:Vector.<Face>=null) {
        this.vertices = vertices || new Vector.<Number>();
        this.texCoord = texCoord || new Vector.<Number>();
        this.faces    = faces    || new Vector.<Face>();
        if(faces) {
            _indices = new Vector.<int>(faces.length*3, true);
        }
    }
    
    public function clear() : Model {
        for each (var face:Face in faces) Face.free(face);
        faces = new Vector.<Face>();
        _faceIdx = 0;
        return this;
    }
    
    public function face(i0:int, i1:int, i2:int) : Model {
        var face:Face = Face.alloc();
        face.i0 = i0;
        face.i1 = i1;
        face.i2 = i2;
        faces[_faceIdx++] = face;
        return this;
    }
    
    public function get indices() : Vector.<int> {
        var i:int = 0;
        for each (var face:Face in faces) {
            _indices[i++] = face.i0;
            _indices[i++] = face.i1;
            _indices[i++] = face.i2;
        }
        return _indices;
    }
}

class Light {
    private var _direction:Vector3D = new Vector3D();
    private var _halfVector:Vector3D = new Vector3D();
    public function get direction() : Vector3D { return _direction; }
    public function get halfVector() : Vector3D { return _halfVector; }
    
    function Light(x:Number=1, y:Number=1, z:Number=1) { setPosition(x, y, z); }
    
    public function setPosition(x:Number, y:Number, z:Number) : void {
        _direction.x = -x;
        _direction.y = -y;
        _direction.z = -z; 
        _direction.normalize();
        _halfVector.x = _direction.x;
        _halfVector.y = _direction.y;
        _halfVector.z = _direction.z + 1; 
        _halfVector.normalize();
    }
}

class Material {
    private static const LINES:int = 13;
    private static const W:int = 0x800;
    private static const H:int = 0x100;

    public var texture:BitmapData = new BitmapData(W,H,false);
    private var _shape:Shape = new Shape;

    function Material() { setColor(0xdb9438, 0xb2a64a); }

    protected function _drawLines(color:uint, start:Number, end:Number):void {
        for(var line:int = 0; line<LINES; line++) {
            var y1:Number = line/LINES*H;
            var y2:Number = (line+1)/LINES*H;
            _shape.graphics.beginFill(color);
            _shape.graphics.moveTo(start*W, y1)
            _shape.graphics.lineTo(end*W, (y1+y2)/2)
            _shape.graphics.lineTo(start*W, y2)
            _shape.graphics.endFill();
        }
    }
    
    public function setColor(front:uint, back:uint) : Material
    {
        _shape.graphics.clear();
        _shape.graphics.beginFill(back);
        _shape.graphics.drawRect(0, 0, W/2, H);
        _shape.graphics.endFill();
        _shape.graphics.beginFill(front);
        _shape.graphics.drawRect(W/2, 0, W/2, H);
        _shape.graphics.endFill();
        _drawLines(0xFFFFFF, 9/8, 6/7);
        _drawLines(0, 1/2, 6/7-0.025);
        _drawLines(0, 1/2, -1/4);
        texture.draw(_shape, null, null, null, null, true);
        texture.applyFilter(texture, texture.rect, new Point, new BlurFilter(4,4,3));
        return this;
    }
    
    static public function calculateTexCoord(texCoord:Point, light:Light, normal:Vector3D, doubleSided:Boolean=false) : void {
        var v:Vector3D = light.direction;
        texCoord.x = v.x * normal.x + v.y * normal.y + v.z * normal.z;
        if (texCoord.x < 0) texCoord.x = (doubleSided) ? -texCoord.x : 0;
        v = light.halfVector;
        texCoord.y = v.x * normal.x + v.y * normal.y + v.z * normal.z;
        if (texCoord.y < 0) texCoord.y = (doubleSided) ? -texCoord.y : 0;
    }
}

class Knot extends Model {
    private var _p:int, _q:int, _sections:int, _slices:int, _sides:int, _thickness:Number, _offset:Number;
    public var sideNormals:Vector.<Number>;

    public function Knot(p:int = 2, q:int = 3, sections:int = 72, sides:int = 4, thickness:Number = 2/3, offset:Number = 0) {
        var numVerts:int = sections*sides*8;
        _p = p;
        _q = q;
        _sections = sections;
        _slices = sections * 2;
        _sides = sides;
        _thickness = thickness;
        _offset = offset;
        super(
            new Vector.<Number>(numVerts*3, true), 
            new Vector.<Number>(numVerts*3, true),
            new Vector.<Face>(sections*sides*8, true)
        );
        sideNormals = new Vector.<Number>(_slices*_sides*3, true)
        _createVertices();
        _createFaces();
        _createNormals();
    }

    protected function _createNormals():void {
        var i:int = 0;
        for(var section:int=0; section<_sections; section++) {
            for(var side:int=0; side<_sides; side++) {
                for(var slice:int=0; slice<2; slice++) {
                    var u:Number = Math.PI*2 * (section*2+slice)/_slices;
                    var v:Number = Math.PI*2 * side/_sides - u*(_sides-1)/_sides;
                    var n:Vector3D = _extrudedPoint(u, v, 1);
                    n.decrementBy(_curvePoint(u));
                    n.normalize();
                    sideNormals[i++] = n.x;
                    sideNormals[i++] = n.y;
                    sideNormals[i++] = n.z;
                }
            }
        }
    }

    protected function _createFaces():void {
        for(var section:int=0; section<_sections; section++) {
            for(var side:int=0; side<_sides; side++) {
                var i:int = section*_sides*8 + side*8;
                // section
                face(i+1, i+0, i+4).face(i+4, i+5, i+1)
                i++;
                face(i+1, i+0, i+4).face(i+4, i+5, i+1)
                i++;
                face(i+1, i+0, i+4).face(i+4, i+5, i+1)
                i--; i--;
                // connector
                var i0:int, i1:int, i2:int, i3:int;
                i0=i+5; i1=i+6;
                i += _sides*8;
                if(section+1 == _sections) {
                    i+=8; // compensate for twist
                    if(side+1 == _sides) i = 0;
                }
                i %= vertices.length/3;
                i2=i+1; i3=i+2;
                face(i0, i2, i1); face(i2, i3, i1);
            }
        }
    }

    protected function _createVertices():void {
        var i:int = 0;
        function _vertex(v:Vector3D, texv:Number):void {
            vertices[i] = v.x; texCoord[i++] = 0;
            vertices[i] = v.y; texCoord[i++] = texv;
            vertices[i] = v.z; texCoord[i++] = 0;
        }
        for(var section:int=0; section<_sections; section++) {
            for(var side:int=0; side<_sides; side++) {
                var p:Number;
                for each(p in [0, 0.4, 0.6, 1]) _vertex(_edgePoint(section*2, side, p), p);
                for each(p in [0, 0.4, 0.6, 1]) _vertex(_edgePoint(section*2+1, side, p), p);
            }
        }
    }

    // 0 <= p <= 1 is the offset along the edge
    protected function _edgePoint(slice:int, side:int, p:Number):Vector3D {
        var u:Number = Math.PI*2 * slice/_slices;
        var v:Number = Math.PI*2 * side/_sides - u*(_sides-1)/_sides;
        v -= Math.PI / _sides; // make side 0 parallel to Z axis
        var v0:Vector3D = _extrudedPoint(u, v, _thickness);
        var v1:Vector3D = _extrudedPoint(u, v + Math.PI*2/_sides, _thickness);
        return _vlerp(v0, v1, p);
    }

    protected function _extrudedPoint(u:Number, v:Number, length:Number):Vector3D {
        v -= Math.PI*2*_offset/_sections*(_sides-1)/_sides;
        // calculate curve point and normal vectors from u
        var cp:Vector3D = _curvePoint(u);
        var ncp:Vector3D = _curvePoint(u+0.0001);
        var t:Vector3D = ncp.subtract(cp);
        var n:Vector3D = ncp.add(cp);
        var b:Vector3D = t.crossProduct(n);
        n = b.crossProduct(t);
        n.normalize();
        b.normalize();
        // extrude in direction v
        var cx:Number = length * Math.sin(v);
        var cy:Number = length * -Math.cos(v);
        return new Vector3D(
            cp.x + cx*n.x + cy*b.x, 
            cp.y + cx*n.y + cy*b.y, 
            cp.z + cx*n.z + cy*b.z
        );
    }

    protected function _curvePoint(t:Number):Vector3D {
        t += Math.PI*2*_offset/_sections;
        return new Vector3D(
            2 * Math.sin(t*_p) - Math.sin(t),
            -(2 * Math.cos(t*_p) + Math.cos(t)),
            Math.sin(t*_q)
        );
    }

    protected function _vlerp(v0:Vector3D, v1:Vector3D, p:Number):Vector3D {
        return new Vector3D(
            v0.x*(1-p) + v1.x*p,
            v0.y*(1-p) + v1.y*p,
            v0.z*(1-p) + v1.z*p,
            v0.w*(1-p) + v1.w*p
        );
    }
}
