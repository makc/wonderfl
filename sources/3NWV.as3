// forked from yonatan's Reproduction
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
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class main extends Sprite {
        public static const W:int = 465;
        public static const H:int = 465;
        private const _sides:int = 4;
        private const _sections:int = 72;
        private var _matrix:Matrix3D = new Matrix3D();
        private var _rotMatrix:Matrix3D = new Matrix3D();
        private var _engine:EngineFaceBasedRender = new EngineFaceBasedRender(800);
        private var _material:Material = new Material;
        private var _models:Array = [];
        private var _model:Spirals;
        private var _transformedNormals:Vector.<Number> = new Vector.<Number>();
        private var _mousePoint:Point;
        private var _timeSum:int, _timeCount:int;
        private var _textField:TextField = new TextField();
        private var _renderBmd:BitmapData = new BitmapData(465, 465, true, 0);
        private var _lighting:Lighting = new Lighting(_renderBmd);
        private var _glow:GlowFilter = new GlowFilter(0, 1, 4, 4, 2, 2);
        private var _greenPower:Number = 0;
        private var _gps:Shape = new Shape;
        
        function main() {
            Wonderfl.capture_delay(1);
            var i:int;

            for (i=0; i<60; i++) _models.push(new Spirals(i/60));
            var m:Matrix = new Matrix;
            m.createGradientBox(W,H,0,0,0);
            graphics.beginGradientFill("radial", [0xffffff, 0x204060, 0], [1, 1, 1], [0, 128, 255], m);
            graphics.drawRect(0, 0, W, H);
            graphics.endFill();

            stage.quality = "medium";
            addChild(new Bitmap(_renderBmd));
            addChild(_lighting);
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
            var time:Number = getTimer()/7;
            _model = _models[int(time) % _models.length];

            // update paremters
            if(_mousePoint) {
                var p:Point = new Point(mouseX, mouseY).subtract(_mousePoint);
                var axis:Vector3D = new Vector3D(p.y, -p.x, 0); 
                axis.normalize();
                _rotMatrix.appendRotation(p.length/2, axis);
                _mousePoint.x = mouseX;
                _mousePoint.y = mouseY;
            }
            
            t = getTimer();
            _engine.pushMatrix();

            _matrix.identity();
            _matrix.appendRotation(time/-4, Vector3D.Z_AXIS);
            _matrix.appendRotation(time/-7, Vector3D.X_AXIS);
            _matrix.appendRotation(time/-13, Vector3D.Y_AXIS);
            _matrix.append(_rotMatrix);
            _calculateVertexNormal();
            _matrix.appendScale(100, 100, 100);
            _matrix.appendTranslation(0, 0, Math.sin(time/1000)*200 + 700);
            _engine.matrix.append(_matrix);
            _engine.project(_model);
            _engine.render(_model, _material);
            _lighting.update();
            _engine.popMatrix();
            _renderBmd.fillRect(_renderBmd.rect, 0);

            _greenPower = _mousePoint ? 1.1*(_greenPower+0.1) : _greenPower*0.8;
            if(_greenPower<0.01) _greenPower = 0;
            if(_greenPower>1) _greenPower = 1;
            if(_greenPower) {
                var m:Matrix = new Matrix;
                m.createGradientBox(W,H,0,0,0);
                _gps.graphics.clear();
                _gps.graphics.beginGradientFill("radial", [0x406020, 0x204060, 0], [_greenPower, _greenPower, _greenPower], [0, 128, 255], m);
                _gps.graphics.drawRect(0, 0, W, H);
                _gps.graphics.endFill();
                _renderBmd.draw(_gps);
            }
            _renderBmd.draw(_engine, new Matrix(1, 0, 0, 1, 232, 232));

            // _timeSum += getTimer() - t;
            // if (++_timeCount == 30) {
            //     _textField.text = "Rendering time: " + String(_timeSum) + "[ms/30frames]";
            //     _timeSum = 0;
            //     _timeCount = 0;
            // }
        }
        
        private function _calculateVertexNormal() : void {
            var len:int = _transformedNormals.length;
            var ni:int = 0;
            var ti:int = 0;
            _matrix.transformVectors(_model.normals, _transformedNormals);
            while (ni<len) {
                var nx:Number = _transformedNormals[ni++];
                var ny:Number = _transformedNormals[ni++];
                var nz:Number = _transformedNormals[ni++];
                // this is completely arbitrary...
                // darker on the outside
                _model.texCoord[ti++] = 0.5+nz/2.5;
                _model.texCoord[ti++] = 0.5+nz/2.5;
                _model.texCoord[ti++] = 0;
                // brighter on the inside
                _model.texCoord[ti++] = 0.5+nx/4;
                _model.texCoord[ti++] = 0.5+ny/4;
                _model.texCoord[ti++] = 0;
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

    function EngineFaceBasedRender(focus:Number=400) {
        _vertexOnWorld = new Vector.<Number>;
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
    
    public function render(model:Model, material:Material) : EngineFaceBasedRender {
        Utils3D.projectVectors(_projectionMatrix, _vertexOnWorld, _vout, model.texCoord);
        graphics.clear();
        graphics.beginBitmapFill(material.texture, null, false, true);
        graphics.drawTriangles(_vout, model.indices, model.texCoord, "positive");
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

class Material {
    private static const LINES:int = 13;
    private static const W:int = 160;
    private static const H:int = 160;

    public var texture:BitmapData = new BitmapData(W,H,false);
    private var _shape:Shape = new Shape;

    function Material() {
        _shape.graphics.clear();
        _shape.graphics.beginGradientFill("radial",[16777215,16378314,16771002,16765308,13721663,0/*8126464*/],[1,1,1,1,1,1],[0,40,52,100,165,255],new Matrix(0.0828,0.0518,-0.0518,0.0828,80.0000,80.0000),"pad","rgb",0);
        _shape.graphics.drawRect(0, 0, W, H);
        _shape.graphics.endFill();
        texture.draw(_shape, null, null, null, null, true);
    }
}

class Spirals extends Model {
    private var _sections:int, _turns:Number = 1.5, _spirals:int, _radius:Number, _stripWidth:Number, _stripThickness:Number, _twistFactor:Number, _offset:Number;
    public var normals:Vector.<Number>;

    public function Spirals(offset:Number = 0, sections:int = 72, spirals:int = 4, radius:Number = 2/3, stripWidth:Number = 0.75, stripThickness:Number = 0.05, twistFactor:Number = 6) {
        var numVerts:int = sections*spirals*8;
        _sections = sections;
        _spirals = spirals;
        _radius = radius;
        _stripWidth = stripWidth;
        _stripThickness = stripThickness;
        _twistFactor = twistFactor;
        _offset = offset*Math.PI*2/_spirals;
        normals = new Vector.<Number>;
        _createVertices();
        _createFaces();
    }

    protected function _getVertex(u:Number, v:Number, r:Number):Vector3D {
        var r2:Number = 1 + Math.cos(v) * r;
        return(new Vector3D(Math.cos(u) * r2, Math.sin(u) * r2, Math.sin(v) * r));
    }

    protected function _getNormal(u:Number, v:Number):Vector3D {
        var normal:Vector3D = _getVertex(u, v, 1);
        normal.decrementBy(_getVertex(u, v, 0));
        return normal;
    }

    protected function _quad(i0:int, i1:int, i2:int, i3:int):void { face(i1, i0, i3).face(i2, i1, i3); }
    protected function _createFaces():void {
        for(var section:int=0; section<_sections-1; section++) {
            for(var spiral:int=0; spiral<_spirals; spiral++) {
                var i0:int = (section*_spirals + spiral) * 4;
                var i1:int = ((section+1)*_spirals + spiral) * 4;
                _quad(i0, i0+2, i1+2, i1); // outer quad
                _quad(i1+1, i1+3, i0+3, i0+1); // inner quad
            }
        }
    }

    protected function _createVertices():void {
        function pushCoord(v:Vector.<Number>, c:Vector3D):void { v.push(c.x, c.y, c.z); }
        for(var section:int=0; section<_sections; section++) {
            for(var spiral:int=0; spiral<_spirals; spiral++) {
                var u:Number = Math.PI*2 * section/_sections * _turns;
                var v:Number = Math.PI*2 * (spiral/_spirals + section/_sections * _twistFactor) - _offset;
                var r:Number = _radius * (1 - section/_sections);
                pushCoord(vertices, _getVertex(u, v, r)); // outer vertex
                pushCoord(vertices, _getVertex(u, v, r * (1-_stripThickness))); // inner vertex
                pushCoord(normals, _getNormal(u, v)); // outward facing normal
                v += _stripWidth;
                pushCoord(vertices, _getVertex(u, v, r)); // outer vertex
                pushCoord(vertices, _getVertex(u, v, r * (1-_stripThickness))); // inner vertex
                pushCoord(normals, _getNormal(u, v)); // outward facing normal
            }
        }
    }
}

class Lighting extends Sprite {
    public static const FXW:int = 0x100;
    public static const FXH:int = 0x100;

    private var scaledOccBmd:BitmapData = new BitmapData(FXW, FXH, true, 0);
    public var scaledOccBmp:Bitmap = new Bitmap(scaledOccBmd);
    private var src:BitmapData = new BitmapData(FXW, FXH, true, 0);
    private var dst:BitmapData = new BitmapData(FXW, FXH, true, 0);
    private var sun:Shape = new Shape;
    private var occlusion:Bitmap;
    private var scaleDown:Matrix = new Matrix;
    private var scaleUp:Matrix = new Matrix;
    private var mtx:Matrix = new Matrix;
    private var canvas:Bitmap = new Bitmap(dst);
    private var blur:BlurFilter = new BlurFilter(5,5,1);
    
    public function Lighting(occlusion:BitmapData) {
        this.blendMode = "add";
        this.occlusion = new Bitmap(occlusion);
        var m:Matrix = new Matrix;
        m.createGradientBox(FXW, FXH, 0, 0, 0);
        sun.graphics.beginGradientFill("radial", 
            [0x04080c, 0x04080c, 0x020406, 0x010203, 0], 
            [1, 1, 1, 1, 1], 
            [0, 32, 64, 96, 128], m);
        sun.graphics.drawRect(0, 0, FXW, FXH);
        sun.graphics.endFill();
        sun.cacheAsBitmap = true;
        
        scaleDown.scale(FXW/main.W, FXH/main.H);
        scaleUp.scale(main.W/FXW, main.H/FXH);

        addChild(canvas);
        transform.matrix = scaleUp;
    }

    public function update():void {
        scaledOccBmd.fillRect(scaledOccBmd.rect,0);
        scaledOccBmd.draw(occlusion, scaleDown);
        src.lock();
        dst.lock();
        src.fillRect(src.rect, 0);
        src.draw(scaledOccBmp, null, new ColorTransform(0.085,0.085,0.085));
        canvas.bitmapData = process(src);
        src.unlock();
        dst.unlock();
    }
    
    private function process(src:BitmapData):BitmapData {
        var dst:BitmapData = this.dst;
        mtx.identity();
        mtx.translate(-FXW/65, -FXH/65);
        mtx.scale(33/32, 33/32);
        var cnt:int = 5;
        var tmp:BitmapData;
        while(cnt--) {
            mtx.concat(mtx);
            dst.copyPixels(src, src.rect, src.rect.topLeft);
            dst.draw(src, mtx, null, "add");
            dst.applyFilter(dst, dst.rect, dst.rect.topLeft, blur);
            tmp = src;
            src = dst;
            dst = tmp;
        }
        return src;
    }
}
