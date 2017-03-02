// forked from yonatan's Gradient Editor
// forked from keim_at_Si's Extended ColorChooser
// 3D rendering:
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
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class main extends Sprite {
        private var _matrix:Matrix3D = new Matrix3D();
        private var _engine:EngineFaceBasedRender = new EngineFaceBasedRender();
        
        private var _material:Material = (new Material()).setColor(0x8080c0, 1, 64, 128, 128, 12, 0, false);
        private var _light:Light = new Light();
        private var _model:Model = new Model();
        private var _boxVertex:Vector.<Number> = new Vector.<Number>();
        private var _sphVertex:Vector.<Number> = new Vector.<Number>();
        private var _vertexNormal:Vector.<Vector3D> = new Vector.<Vector3D>();
        
        private var _t:Number, _dt:Number, _rot:Number;
        private var _timeSum:int, _timeCount:int;
        
        private var _textField:TextField = new TextField();

        private var _ed1:GradientEditor;
        private var _ed2:GradientEditor;
        private var _canvas1:Sprite = new Sprite;
        private var _canvas2:Sprite = new Sprite;
        private var _bmp:Bitmap = new Bitmap(_material.colorTable);
        
        function main() {
            _engine.x = 232;
            _engine.y = 232;
            addChild(_engine);
            addEventListener("enterFrame", _onEnterFrame);

            var args:Array = ["linear", [0, 0x808080], [1, 1], [0, 255]];
            _ed1 = new GradientEditor(this, 10, 5, args, _onGradientChange);
            _ed2 = new GradientEditor(this, 10, 65, args, _onGradientChange);
            _canvas1.addChild(_canvas2);
            _canvas2.blendMode = "add";
            addChild(_bmp);
            _bmp.scaleX = _bmp.scaleY = 0.5;
            _bmp.x = _bmp.y = 465-128;
            _onGradientChange(null);

            // create shape
            for (var x:Number=-14; x<16; x+=4) {
                for (var y:Number=-14; y<16; y+=4) {
                    _vertex( x, y, 16);
                    _vertex( x,-y,-16);
                    _vertex( y, 16, x);
                    _vertex(-y,-16, x);
                    _vertex( 16, x, y);
                    _vertex(-16, x,-y);
                }
            }
            for (var i:int=0; i<7; i++) {
                for (var j:int=0; j<7; j++) {
                    for (var k:int=0; k<6; k++) {
                        var i0:int = (i*8+j)*6+k;
                        _model.face(i0, i0+6, i0+48).face(i0+54, i0+48, i0+6);
                    }
                }
            }
            _model.vertices.length = _boxVertex.length;
            _model.texCoord.length = _boxVertex.length;
            _vertexNormal.length = _boxVertex.length/3;
            for (i=0; i<_vertexNormal.length; i++) _vertexNormal[i] = new Vector3D();
            
            // initialize parameters
            _rot = 0;
            _t = 0;
            _dt = 0.01;
            _timeSum = 0;
            _timeCount = 0;
            _textField.autoSize = "left";
            _textField.background = true;
            _textField.backgroundColor = 0x80f080;
            // addChild(_textField);
            // var status:Stats = new Stats();
            // status.x = 400;
            // addChild(status);

            function _vertex(x:Number, y:Number, z:Number) : void {
                _boxVertex.push( x, y, z);
                var ilen:Number = 20/Math.sqrt(x*x+y*y+z*z);
                _sphVertex.push( x*ilen, y*ilen, z*ilen);
            }
        }

        private function _onGradientChange(e:Event):void {
            if(_ed1 == null || _ed2 == null) return;
            var g1:Graphics = _canvas1.graphics;
            var g2:Graphics = _canvas2.graphics;
            var mtx:Matrix = new Matrix();
            mtx.createGradientBox(256, 256, 0, 0, 0);
            g1.clear();
            g1.beginGradientFill("linear", _ed1.colors, _ed1.alphas, _ed1.ratios, mtx);
            g1.drawRect(0, 0, 256, 256);
            g1.endFill();
            mtx.createGradientBox(256, 256, Math.PI/2, 0, 0);
            g2.clear();
            g2.beginGradientFill("linear", _ed2.colors, _ed2.alphas, _ed2.ratios, mtx);
            g2.drawRect(0, 0, 256, 256);
            g2.endFill();
            _material.colorTable.draw(_canvas1);
            _material.colorTable.draw(_canvas1, null, null, "alpha");
        }

        private function _onEnterFrame(e:Event) : void {
            var i:int, t:int;
            // update paremters
            _rot += 1;
            _t += _dt;
            if (_t>3 || _t<-3) { _dt = -_dt; _t += _dt; }
            for (i=0; i<_model.vertices.length; i++) {
                _model.vertices[i] = _boxVertex[i]*_t + _sphVertex[i]*(1-_t);
            }

            // light position
            _light.setPosition(mouseX-232, mouseY-232, -100);
            
            t = getTimer();
            _engine.pushMatrix();
            _matrix.identity();
            _matrix.appendRotation(_rot*0.3, Vector3D.X_AXIS);
            _matrix.appendRotation(_rot,     Vector3D.Y_AXIS);
            _matrix.appendTranslation(0, 0, 100);
            _engine.matrix.append(_matrix);
            _engine.project(_model);
            _calculateVertexNormal();
            _engine.render(_model, _light, _material);
            _engine.popMatrix();
            _timeSum += getTimer() - t;
            
            if (++_timeCount == 30) {
                _textField.text = "Redering time: " + String(_timeSum) + "[ms/30frames]";
                _timeSum = 0;
                _timeCount = 0;
            }
        }
        
        private var uv:Point = new Point();
        private function _calculateVertexNormal() : void {
            var i:int, face:Face, normal:Vector3D;
            for each (face in _model.faces) {
                _vertexNormal[face.i0].x += face.normal.x;
                _vertexNormal[face.i0].y += face.normal.y;
                _vertexNormal[face.i0].z += face.normal.z;
                _vertexNormal[face.i0].w += 1;
                _vertexNormal[face.i1].x += face.normal.x;
                _vertexNormal[face.i1].y += face.normal.y;
                _vertexNormal[face.i1].z += face.normal.z;
                _vertexNormal[face.i1].w += 1;
                _vertexNormal[face.i2].x += face.normal.x;
                _vertexNormal[face.i2].y += face.normal.y;
                _vertexNormal[face.i2].z += face.normal.z;
                _vertexNormal[face.i2].w += 1;
            }
            i = 0;
            for each (normal in _vertexNormal) {
                normal.project();
                Material.calculateTexCoord(uv, _light, normal);
                _model.texCoord[i] = uv.x; i++;
                _model.texCoord[i] = uv.y; i+=2;
                normal.x = 0;
                normal.y = 0;
                normal.z = 0;
                normal.w = 0;
            }
        }
    }
}


import flash.display.*;
import flash.geom.*;

class EngineFaceBasedRender extends Shape {
    public var matrix:Matrix3D;
    
    private var _vertexOnWorld:Vector.<Number> = new Vector.<Number>();
    private var _vout:Vector.<Number> = new Vector.<Number>();
    
    private var _projector:PerspectiveProjection;
    private var _projectionMatrix:Matrix3D;
    private var _matrixStac:Vector.<Matrix3D>;

    function EngineFaceBasedRender(focus:Number=300) {
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
        var i0x3:int, i1x3:int, i2x3:int, x01:Number, x02:Number, y01:Number, y02:Number, z01:Number, z02:Number;
        matrix.transformVectors(model.vertices, _vertexOnWorld);
        var vertices:Vector.<Number> = _vertexOnWorld;
        for each (var face:Face in model.faces) {
            i0x3 = (face.i0<<1) + face.i0;
            i1x3 = (face.i1<<1) + face.i1;
            i2x3 = (face.i2<<1) + face.i2;
            x01 = vertices[i1x3] - vertices[i0x3];
            x02 = vertices[i2x3] - vertices[i0x3];
            i0x3++; i1x3++; i2x3++;
            y01 = vertices[i1x3] - vertices[i0x3];
            y02 = vertices[i2x3] - vertices[i0x3];
            i0x3++; i1x3++; i2x3++;
            z01 = vertices[i1x3] - vertices[i0x3];
            z02 = vertices[i2x3] - vertices[i0x3];
            face.z = vertices[i0x3] + vertices[i1x3] + vertices[i2x3];
            face.normal.x = y01*z02 - y02*z01;
            face.normal.y = z01*x02 - z02*x01;
            face.normal.z = x01*y02 - x02*y01;
            face.normal.normalize();
        }
        model.faces.sort(function(f1:Face, f2:Face) : Number { return f2.z - f1.z; });
        return this;
    }
    
    public function render(model:Model, light:Light, material:Material) : EngineFaceBasedRender {
        Utils3D.projectVectors(_projectionMatrix, _vertexOnWorld, _vout, model.texCoord);
/*
        graphics.clear();
        for each (var face:Face in model.faces) {
            graphics.beginFill(material.getColor(light, face.normal), material.alpha);
            graphics.moveTo(_vout[face.i0<<1], _vout[(face.i0<<1)+1]);
            graphics.lineTo(_vout[face.i1<<1], _vout[(face.i1<<1)+1]);
            graphics.lineTo(_vout[face.i2<<1], _vout[(face.i2<<1)+1]);
            graphics.endFill();
        }
//*/
//*
        graphics.clear();
        graphics.beginBitmapFill(material.colorTable, null, false, true);
        graphics.drawTriangles(_vout, model.indices, model.texCoord);
        graphics.endFill();
//*/
        return this;
    }
}

class Face {
    public var i0:int, i1:int, i2:int, z:Number, normal:Vector3D = new Vector3D();

    // Factory
    static private var _freeList:Vector.<Face> = new Vector.<Face>();
    static public function alloc() : Face { return _freeList.pop() || new Face(); }
    static public function free(face:Face) : void { _freeList.push(face); }
}

class Model {
    public var vertices:Vector.<Number>;
    public var texCoord:Vector.<Number>;
    public var faces:Vector.<Face> = new Vector.<Face>();
    private var _indices:Vector.<int> = new Vector.<int>();

    function Model(vertices:Vector.<Number>=null, texCoord:Vector.<Number>=null) {
        this.vertices = vertices || new Vector.<Number>();
        this.texCoord = texCoord || new Vector.<Number>();
    }
    
    public function clear() : Model {
        for each (var face:Face in faces) Face.free(face);
        faces.length = 0;
        return this;
    }
    
    public function face(i0:int, i1:int, i2:int) : Model {
        var face:Face = Face.alloc();
        face.i0 = i0;
        face.i1 = i1;
        face.i2 = i2;
        faces.push(face);
        return this;
    }
    
    public function get indices() : Vector.<int> {
        _indices.length = 0;
        for each (var face:Face in faces) _indices.push(face.i0, face.i1, face.i2);
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
    public var colorTable:BitmapData = new BitmapData(256,256,false);
    public var alpha:Number = 1;
    private var _nega_filter:int = 0;
    
    function Material() { setColor(0xc0c0c0, 1); }
    
    public function setColor(color:uint, alpha_:Number= 1.0, 
                             amb:int=64, dif:int=192, spc:int=0, pow:Number=8, emi:int=0, doubleSided:Boolean=false) : Material
    {
        var i:int, r:int, c:int,
            lightTable:BitmapData = new BitmapData(256, 256, false),
            rct:Rectangle = new Rectangle();
        
        // base color
        alpha = alpha_;
        colorTable.fillRect(colorTable.rect, color);

        // ambient/diffusion/emittance
        var ea:Number = (256-emi)*0.00390625,
            eb:Number = emi*0.5;
        r = dif - amb;
        rct.width=1; rct.height=256; rct.y=0;
        for (i=0; i<256; ++i) {
            rct.x = i;
            lightTable.fillRect(rct, (((i*r)>>8)+amb)*0x10101);
        }
        colorTable.draw(new Bitmap(lightTable), null, new ColorTransform(ea,ea,ea,1,eb,eb,eb,0), BlendMode.HARDLIGHT);
        
        // specular/power
        if (spc > 0) {
            rct.width=256; rct.height=1; rct.x=0;
            for (i=0; i<256; ++i) {
                rct.y = i;
                c = int(Math.pow(i*0.0039215686, pow)*spc);
                lightTable.fillRect(rct, ((c<255)?c:255)*0x10101);
            }
            colorTable.draw(new Bitmap(lightTable), null, null, BlendMode.ADD);
        }
        lightTable.dispose();

        // double sided
        _nega_filter = (doubleSided) ? -1 : 0;
        
        return this;
    }
    
    public function getColor(light:Light, normal:Vector3D) : uint
    {
        var v:Vector3D, ln:int, hn:int, sign:int;
        
        // ambient
        v = light.direction;
        ln = int((v.x * normal.x + v.y * normal.y + v.z * normal.z)*255);
        sign = ((ln & 0x80000000)>>31);
        ln = (ln ^ sign) & ((~sign) | _nega_filter);

        // specular
        v = light.halfVector;
        hn = int((v.x * normal.x + v.y * normal.y + v.z * normal.z)*255);
        sign = ((hn & 0x80000000)>>31);
        hn = (hn ^ sign) & ((~sign) | _nega_filter);
        
        return colorTable.getPixel(ln, hn);
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


// Gradient Editor

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.filters.*;
import com.bit101.components.*;
import com.adobe.serialization.json.JSON;

function matrixToGradientBox(m:Matrix):Object {
    var w:Number = Math.sqrt(m.a*m.a + m.c*m.c) * 1638.5;
    var h:Number = Math.sqrt(m.b*m.b + m.d*m.d) * 1638.5;
    return {
        w: w,
        h: h,
        rot: Math.atan2(m.b, m.d),
        tx: m.tx-w/2,
        ty: m.ty-h/2
    };
}

class GradientEditor extends Panel {
    public static const LABEL_WIDTH:Number = 30;
    public static const PREVIEW_SIZE:Number = 160;
    public static const BAR_W:Number = 280;
    public static const BAR_H:Number = 20;
    
    protected var _gPoints:Array = [];
    protected var _ui:Object = {};
    protected var _uiSetters:Object = {};
    protected var _mainBox:VBox;
    protected var _colorChooser:ColorChooserEx;
    protected var _preview:Shape = new Shape;
    protected var _previewContainer:Sprite = new Sprite;
    protected var _bar:Sprite = new Sprite;
    protected var _barContainer:Sprite = new Sprite;
    protected var _code:Text;
    protected var _errIndicator:GlowFilter = new GlowFilter(0xff4444, 2, 4, 4);

    // args should be an array of beginGradientFill args.
    public function GradientEditor(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, args:Array = null, defaultHandler:Function = null) {
        super(parent, xpos, ypos);
        if(defaultHandler != null) addEventListener(Event.CHANGE, defaultHandler);
        setSize(465-20, 55);
        args = args || ["linear", [0, 0xffffff], [1, 1], [0, 255]];
        for(var i:int = 0; i < args[1].length; i++) {
            _gPoints.push(new GradientPoint(_barContainer, args[1][i], args[2][i], args[3][i], _onPointDrag, _removePoint));
        }

        // args array:
        //0 type:String, 
        //1 colors:Array, 
        //2 alphas:Array, 
        //3 ratios:Array, 
        //4 matrix:Matrix = null, 
        //5 spreadMethod:String = "pad", 
        //6 interpolationMethod:String = "rgb", 
        //7 focalPointRatio:Number = 0

        // ui setup
        var p:Object = _gPoints[0];
        p.isSelected = true;
        _mainBox = new VBox(this.content, 5, 5);
        _mainBox.spacing = 24;
		_ui["Gradient Point"] = 0;
        var ccBox:Component = new Component(_mainBox);
        _colorChooser = new ColorChooserEx(ccBox, 0, 0, _gPoints[0].color, _onColorChange);
        _newTxtSlider("Alpha", p.alpha, 0, 1, "0-9.", _onAlphaChange);
        _ui["Gradient Type"] = args[0] || "linear";
        _ui["Spread Method"] = args[5] || "pad";
        _ui["Interpolation Method"] = args[6] || "rgb";

        _onGradientChange();
        
        var board:Bitmap = _checkerboard(BAR_W, BAR_H);
        board.y = _bar.y = 20;
        _barContainer.addChild(board);
        _barContainer.addChild(_bar);
        _bar.addEventListener(MouseEvent.CLICK, _onBarClick);
        content.addChild(_barContainer);
		_barContainer.x = 150;
    }

    public function get selectedPoint():GradientPoint { return _gPoints[_ui["Gradient Point"]]; };
    public function set selectedPoint(p:GradientPoint):void { 
        _ui["Gradient Point"] = _gPoints.indexOf(p);
        _onPointChange();
    }

    protected function _onBarClick(e:MouseEvent):void {
        var bmd:BitmapData = new BitmapData(_bar.width, _bar.height, true);
        bmd.draw(_bar);
        bmd.draw(_bar, null, null, "alpha");
        var c32:Number = bmd.getPixel32(e.localX, e.localY);
        var p:GradientPoint = new GradientPoint(_barContainer, c32 & 0xffffff, (c32>>>24)/255, e.localX / BAR_W * 255, _onPointDrag, _removePoint);
        _addPoint(p);
    }

    protected function _addPoint(p:GradientPoint):void {
        _gPoints.push(p);
        _sortPoints();
        selectedPoint = p;
        _onGradientChange();
    }

    protected function _removePoint(p:GradientPoint):Boolean {
        if(_gPoints.length < 3) return false; // only if there are more than 2 points
        _gPoints.splice(_gPoints.indexOf(p), 1);
        if(p.isSelected) selectedPoint = _gPoints[0];
        _onGradientChange();
        return true;
    }

    protected function _sortPoints():void {
        var p:GradientPoint = selectedPoint;
        _gPoints.sortOn(["ratio"], Array.NUMERIC);
        selectedPoint = p;
    }

    protected function _onPointChange(e:Event = null):void {
        for each(var p:GradientPoint in _gPoints) p.isSelected = (p == selectedPoint);
        _colorChooser.value = selectedPoint.color;
        _uiSetters["Alpha"](selectedPoint.alpha);
    }

    protected function _onColorChange(e:Event):void { selectedPoint.color = _colorChooser.value; _onGradientChange(); }
    protected function _onAlphaChange(e:Event):void { selectedPoint.alpha = _ui["Alpha"]; _onGradientChange(); }
    protected function _onRatioChange(e:Event):void { selectedPoint.ratio = _ui["Ratio"]; _sortPoints(); _onGradientChange(); }
    protected function _onPointDrag(p:GradientPoint):void { 
        selectedPoint = p; 
        _sortPoints(); 
        _onGradientChange(); 
    }

    protected function _onGradientChange(e:Event = null):void {
        var args:Array = this.args;
        var mtx:Matrix = new Matrix;
        _bar.graphics.clear();
        mtx.createGradientBox(BAR_W, BAR_H, 0, 0, 0);
        _bar.graphics.beginGradientFill("linear", args[1], args[2], args[3], mtx, args[5], args[6], 0);
        _bar.graphics.drawRect(0, 0, BAR_W, BAR_H);
        _bar.graphics.endFill();
        dispatchEvent(new Event(Event.CHANGE));
    }

    protected function _newTxtSlider(name:String, value:Number, min:Number, max:Number, restrict:String, handler:Function):Slider {
        var container:Component = new Component(_mainBox, 0, 0);
        new Label(container, 0, 0, name + ":");
        var txt:InputText = new InputText(container, LABEL_WIDTH, 0, String(value), txtHandler);
        txt.restrict = restrict;
        txt.width = 25;
        var slider:Slider = new HSlider(container, txt.x + 30, 3, sliderHandler);
        slider.minimum = min;
        slider.maximum = max;
		slider.width = 60;
        slider.value = value;
        function txtHandler(e:Event):void {
            var v:Number = Number(txt.text);
            if(isNaN(v) || txt.text == "") {
                txt.filters = [_errIndicator];
            } else {
                txt.filters = [];
                slider.value = v; 
                _ui[name] = slider.value;
                handler(e);
            }
        };
        function sliderHandler(e:Event):void { 
            txt.text = _ui[name] = slider.value;
            txt.filters = [];
            handler(e);
        };
        txt.textField.addEventListener(FocusEvent.FOCUS_OUT, sliderHandler);
        _uiSetters[name] = function(v:Number):void { txt.text = String(_ui[name] = slider.value = v); };
        txt.text = _ui[name] = slider.value;
        return slider;
    }

    public function get args():Array {
        var ret:Array = [];
        ret[0] = _ui["Gradient Type"];
        ret[1] = []; ret[2] = []; ret[3] = [];
        for(var i:int = 0; i < _gPoints.length; i++) {
            ret[1].push(_gPoints[i].color);
            ret[2].push(_gPoints[i].alpha);
            ret[3].push(int(_gPoints[i].ratio));
        }
        ret[4] = new Matrix;
        ret[4].createGradientBox(
            _ui["Box Width"],
            _ui["Box Height"],
            _ui["Box Rotation"] / 180 * Math.PI,
            _ui["Box X Translation"],
            _ui["Box Y Translation"]
        );
        ret[5] = _ui["Spread Method"];
        ret[6] = _ui["Interpolation Method"];
        ret[7] = _ui["Focal Point Ratio"];
        return ret;
    }

    public function get colors():Array {return _gPoints.map(function(p:GradientPoint, ..._):Number {return p.color})}
    public function get alphas():Array {return _gPoints.map(function(p:GradientPoint, ..._):Number {return p.alpha})}
    public function get ratios():Array {return _gPoints.map(function(p:GradientPoint, ..._):Number {return p.ratio})}

    protected function _checkerboard(w:int, h:int):Bitmap {
        var bmd:BitmapData = new BitmapData(w, h, false);
        for(var y:int = 0; y < h; y++) {
            for(var x:int = 0; x < w; x++) {
                bmd.setPixel(x, y, (x&8)^(y&8) ? 0xffffff : 0xc0c0c0);
            }
        }
        return(new Bitmap(bmd));
    }
}

class GradientPoint {
    protected var _ratio:Number;
    protected var _color:uint;
    protected var _alpha:Number;
    protected var _isSelected:Boolean;
    protected var _changeHandler:Function;
    protected var _killHandler:Function;
    protected var _mover:Sprite = new Sprite;
    protected var _killer:Sprite = new Sprite;
    protected var _parent:DisplayObjectContainer;

    public function get color():uint { return _color; }
    public function set color(v:uint):void { _color = v; _updateUI(); }
    public function get alpha():Number { return _alpha; }
    public function set alpha(v:Number):void { _alpha = v; _updateUI(); }
    public function get ratio():Number { return _ratio; }
    public function set ratio(v:Number):void { _ratio = v; _updateUI(); }
    public function get isSelected():Boolean { return _isSelected; }
    public function set isSelected(v:Boolean):void { _isSelected = v; _updateUI(); }

    public function GradientPoint(parent:DisplayObjectContainer, c:uint, a:Number, r:Number, change:Function, kill:Function):void {
        _ratio = r; _color = c; _alpha = a; _changeHandler = change; _killHandler = kill; _parent = parent;
        _mover.buttonMode = _killer.buttonMode = true;
        _parent.addChild(_mover);
        _parent.addChild(_killer);
        _mover.y = 10;
        _killer.y = GradientEditor.BAR_H + 25;
        _mover.addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
        _killer.addEventListener(MouseEvent.CLICK, _onKill);
        _updateUI();
    }

    protected function _onKill(e:Event):void {
        if(_killHandler(this)) { // returns false if point count < 3
            _parent.removeChild(_mover);
            _parent.removeChild(_killer);
        }
    }

    protected function _onDragStart(e:MouseEvent) : void {
        _parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, _onDragging);
        _parent.stage.addEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
        _onDragging(e);
    }
    
    protected function _onDragging(e:MouseEvent) : void {
        var x:Number = _parent.mouseX < 0 ? 0 : _parent.mouseX;
        if(_parent.mouseX > GradientEditor.BAR_W) x = GradientEditor.BAR_W;
        _ratio = x / GradientEditor.BAR_W * 255;
        _mover.x = _killer.x = x;
        _changeHandler(this);
    }
    
    protected function _onDragEnd(e:MouseEvent) : void {
        _onDragging(e);
        _parent.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onDragging);
        _parent.stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
    }

    protected function _updateUI():void {
        if(_isSelected) { // bring to front
            _parent.addChild(_mover); 
            _parent.addChild(_killer);
        }
        _mover.x = _killer.x = _ratio / 255 * GradientEditor.BAR_W;
        with(_mover.graphics) {
            clear();
            lineStyle(_isSelected ? 2 : 1, 0);
            beginFill(_color, _alpha);
            drawCircle(0, 0, _isSelected ? 6 : 4);
            endFill();
        }
        with(_killer.graphics) {
            clear();
            lineStyle(1, 0);
            beginFill(_color, _alpha);
            drawRect(-4, -4, 9, 9);
            endFill();
            moveTo(-4,-4); lineTo(5,5);
            moveTo(-4,5); lineTo(5,-4);
        }
    }
}

// ColorChooserEx

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import com.bit101.components.*;
import frocessing.color.*;


function hsv2rgb(h:Number, s:Number, v:Number) : uint {
    var ht:Number=(h-int(h)+int(h<0))*6, hi:int=int(ht), vt:Number=v*255;
    switch(hi) {
        case 0: return 0xff000000|(vt<<16)|(int(vt*(1-(1-ht+hi)*s))<<8)|int(vt*(1-s));
        case 1: return 0xff000000|(vt<<8)|(int(vt*(1-(ht-hi)*s))<<16)|int(vt*(1-s));
        case 2: return 0xff000000|(vt<<8)|int(vt*(1-(1-ht+hi)*s))|(int(vt*(1-s))<<16);
        case 3: return 0xff000000|vt|(int(vt*(1-(ht-hi)*s))<<8)|(int(vt*(1-s))<<16);
        case 4: return 0xff000000|vt|(int(vt*(1-(1-ht+hi)*s))<<16)|(int(vt*(1-s))<<8);
        case 5: return 0xff000000|(vt<<16)|int(vt*(1-(ht-hi)*s))|(int(vt*(1-s))<<8);
    }
    return 0;
}

function rgb2hsv(r:int, g:int, b:int) : uint { // h:12bit,s:10bit,v:8bit
    var max:int, min:int, sv:int;
    if (r>g) { if (g>b) {min=b;max=r;} else {min=g;max=(r>b)?r:b;} } 
    else     { if (g<b) {max=b;min=r;} else {max=g;min=(r<b)?r:b;} }
    if (max == min) return max;
    sv = (int((max - min) * 1023 / max)<<8) | max;
    if (b==max) return (int((r-g)*682.6666666666666/(max-min)+2730.6666666666665)<<18)|sv;
    if (g==max) return (int((b-r)*682.6666666666666/(max-min)+1365.3333333333332)<<18)|sv;
    if (g>=b) return (int((g-b)*682.6666666666666/(max-min))<<18)|sv;
    return (int(4096+(g-b)*682.6666666666666/(max-min))<<18)|sv;
}

class ColorChooserEx extends ColorChooser {
//-------------------------------------------------- variables
    protected var uniqueDefaultModel:Sprite = null;
    protected var originalDefaultModel:Sprite = null;
    protected var dummyBackground:Sprite;
    protected var mainPanel:Panel, tabLine:Shape = new Shape();
    protected var tabs:Array, models:Array = [];
    protected var _selectedTab:int;
    
//-------------------------------------------------- properties
    public function get selectedTab() : int { return _selectedTab; }
    public function set selectedTab(idx:int) : void {
        _selectedTab = idx;
        for each (var model:Sprite in models) model.visible = false;
        models[_selectedTab].visible = true;
        models[_selectedTab].value = value;
        tabLine.x = _selectedTab * 40;
    }
    
//-------------------------------------------------- constructor
    function ColorChooserEx(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, value:uint = 0xff0000, defaultHandler:Function = null) {
        super(parent, xpos, ypos, value, defaultHandler);
        usePopup = true;
    }
    
//-------------------------------------------------- modifications
    override protected function onColorsRemovedFromStage(e:Event) : void {
        dummyBackground.removeEventListener(MouseEvent.CLICK, onStageClick);
    }
    
    override protected function onColorsAddedToStage(e:Event) : void {
        _stage = stage;
        dummyBackground.graphics.clear();
        dummyBackground.graphics.beginFill(0, 0);
        dummyBackground.graphics.drawRect(-_stage.stageWidth, -_stage.stageHeight, _stage.stageWidth*2, _stage.stageHeight*2);
        dummyBackground.graphics.endFill();
        dummyBackground.addEventListener(MouseEvent.CLICK, onStageClick);
        models[_selectedTab].value = value;
    }
    
    override protected function drawColors(d:DisplayObject) : void {
        while (_colorsContainer.numChildren) _colorsContainer.removeChildAt(0);
        _colorsContainer.addChild(d); // currently always (d === _model)
        placeColors();
    }
    
    override public function set usePopup(value:Boolean):void {
        _usePopup = value;
        _swatch.buttonMode = true;
        _swatch.addEventListener(MouseEvent.CLICK, onSwatchClick);
        if (!_usePopup) {
            _swatch.buttonMode = false;
            _swatch.removeEventListener(MouseEvent.CLICK, onSwatchClick);
        }
    }
    
//-------------------------------------------------- for interactive selectors
    public function browseColorChoiceEx(col:uint) : void { value = _tmpColorChoice = col; dispatchEvent(new Event(Event.CHANGE)); }
    public function backToColorChoiceEx() : void { value = _oldColorChoice; }
    public function setColorChoiceEx() : void {
        _oldColorChoice = value;
        dispatchEvent(new Event(Event.CHANGE));
        displayColors();
    }
    
//-------------------------------------------------- exchange default model
    override protected function getDefaultModel() : Sprite {
        var x_:Number = 0;
        if (uniqueDefaultModel) return uniqueDefaultModel;
        originalDefaultModel = super.getDefaultModel();
        uniqueDefaultModel = new Sprite();
        dummyBackground = new Sprite();
        uniqueDefaultModel.addChild(dummyBackground);
        mainPanel = new Panel(uniqueDefaultModel);
        mainPanel.setSize(160, 134);
        tabs   = [newTab("Gimp"), newTab("Bars"), newTab("Hue"), newTab("Mem")];
        models = [new GimpModel(mainPanel.content, this), 
                  new BarsModel(mainPanel.content, this), 
                  new HueModel(mainPanel.content, this),
                  new MemoryModel(mainPanel.content, this)];
        mainPanel.content.addChild(tabLine = new Shape());
        tabLine.graphics.lineStyle(1, Style.PANEL);
        tabLine.graphics.moveTo(0,0);
        tabLine.graphics.lineTo(40,0);
        tabLine.y = 116;
        selectedTab = 0;
        return uniqueDefaultModel;
        function newTab(label:String) : PushButton {
            var newButton:PushButton = new PushButton(mainPanel.content, x_, 116, label, _onTabClick);
            newButton.setSize(40, 18);
            x_ += 40;
            return newButton;
        }
    }

    protected function _onTabClick(e:Event) : void { selectedTab = int((e.target.x + 20) / 40); }
}

class ColorChooserExModel extends Sprite {
    protected static const $$:Number = 0.00392156862745098;
    protected var _h:Number, _s:Number, _v:Number, _r:uint, _g:uint, _b:uint, _a:uint;
    protected var _chooser:ColorChooserEx;
    
    public function get value() : uint { return (_a<<24)|(_r<<16)|(_g<<8)|_b; }
    public function set value(v:uint) : void {
        _a = (v >> 24) & 0xff;
        _r = (v >> 16) & 0xff;
        _g = (v >> 8) & 0xff;
        _b = v & 0xff;
        _RGBupdated();
        _setup();
    }
    
    function ColorChooserExModel(parent:DisplayObjectContainer, chooser:ColorChooserEx) {
        super();
        parent.addChild(this);
        visible = false;
        _chooser = chooser;
    }
    
    protected function _setup() : void {}
    
    protected function _HSVupdated() : void {
        var v:uint = hsv2rgb(_h, _s, _v);
        _r = (v >> 16) & 0xff;
        _g = (v >> 8) & 0xff;
        _b = v & 0xff;
    }
    
    protected function _RGBupdated() : void {
        var hsv:uint = rgb2hsv(_r, _g, _b);
        _h = (hsv >> 18) * 0.000244140625;
        _s = ((hsv >> 8) & 0x3ff) * 0.0009775171065493646;
        _v = (hsv & 0xff) * 0.00392156862745098;
    }
}

class ControlPad extends Panel {
    public var backBitmap:Bitmap, pixels:BitmapData;
    protected var _pointer:Shape, _pointerRange:Rectangle;
    
    public function get valueX() : Number { return _pointer.x / _pointerRange.width; }
    public function set valueX(p:Number) : void { _pointer.x = _pointerRange.width * p; }
    public function get valueY() : Number { return 1 - _pointer.y / _pointerRange.height; }
    public function set valueY(p:Number) : void { _pointer.y =  _pointerRange.height * (1-p); }
    public function valueXY(px:Number, py:Number) : void { 
        _pointer.x = _pointerRange.width * px;
        _pointer.y = _pointerRange.height * (1-py);
    }
    
    function ControlPad(parent:DisplayObjectContainer, xpos:Number, ypos:Number, width:Number, height:Number, defaultHandler:Function=null) {
        super(parent, xpos, ypos);
        setSize(width, height);
        backBitmap = new Bitmap(pixels = new BitmapData(width, height, false, 0x808080));
        _pointer = _addPointer();
        _pointerRange = pixels.rect;
        _background.addChild(backBitmap);
        content.addChild(_pointer);
        addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart);
        if (defaultHandler != null) addEventListener(Event.CHANGE, defaultHandler);
        buttonMode = true;
    }
    
    override public function draw() : void {
        dispatchEvent(new Event(Component.DRAW));
        _mask.graphics.clear();
        _mask.graphics.beginFill(0xff0000);
        _mask.graphics.drawRect(0, 0, _width, _height);
        _mask.graphics.endFill();
    }

    protected function _addPointer() : Shape {
        var pt:Shape = new Shape();
        pt.graphics.lineStyle(2, 0, 0.5);
        pt.graphics.beginFill(0xffffff, 1);
        pt.graphics.drawCircle(0, 0, 3);
        pt.graphics.endFill();
        content.addChild(pt);
        return pt;
    }
    
    protected function _onDragStart(e:MouseEvent) : void {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _onDragging);
        stage.addEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
        _onDragging(e);
    }
    
    protected function _onDragging(e:MouseEvent) : void {
        _pointer.x = mouseX;
        _pointer.y = mouseY;
             if (_pointer.x < _pointerRange.left)   _pointer.x = _pointerRange.left;
        else if (_pointer.x > _pointerRange.right)  _pointer.x = _pointerRange.right;
             if (_pointer.y < _pointerRange.top)    _pointer.y = _pointerRange.top;
        else if (_pointer.y > _pointerRange.bottom) _pointer.y = _pointerRange.bottom;
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    protected function _onDragEnd(e:MouseEvent) : void {
        _onDragging(e);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onDragging);
        stage.removeEventListener(MouseEvent.MOUSE_UP, _onDragEnd);
    }
}

class HueCircle extends ControlPad {
    protected var circleWidth:Number, circleRadius:Number, triangleSize:Number;
    protected var dragFunc:Function, _hpointer:Shape, _shadowx2:DropShadowFilter;
    protected var hCircle:BitmapData, svTriangle:BitmapData;
    protected var _h:Number=0, _s:Number=0, _v:Number=0;
    protected var svTriangleDrawMatrix:Matrix = new Matrix(0.5, 0, 0, 0.5);
    protected var baseMatrix:Matrix = new Matrix(0.8660254037844386, 0, 0.4330127018922193, 0.75, -0.4330127018922193, -0.25);
    protected var matrix:Matrix, invert:Matrix;
    
    public function get sat() : Number { return _s; }
    public function get val() : Number { return _v; }
    public function get hue() : Number { return _h; }
    public function setHSV(h:Number, s:Number, v:Number) : void {
        _h = h; _s = s; _v = v;
        _drawSVTriangle();
        invalidate();
    }
    
    function HueCircle(parent:DisplayObjectContainer, xpos:Number, ypos:Number, radius:Number, cwidth:Number, defaultHandler:Function=null) {
        super(parent, xpos, ypos, radius*2, radius*2, defaultHandler);
        filters = null;
        circleWidth  = cwidth;
        circleRadius = radius;
        triangleSize = (radius - cwidth) * 2;
        hCircle    = new BitmapData(radius*2, radius*2, true, 0);
        svTriangle = new BitmapData(triangleSize*2, triangleSize*2, true, 0);
        svTriangleDrawMatrix.translate(cwidth, cwidth);
        baseMatrix.scale(triangleSize, triangleSize);
        _shadowx2 = getShadow(4, true);
        _drawHCircle();
        _drawSVTriangle();
        _hpointer = _addPointer();
    }
    
    override public function draw() : void {
        super.draw();
        _updateHPointerPosition();
        _updateSVPointerPosition();
        pixels.copyPixels(hCircle, hCircle.rect, hCircle.rect.topLeft);
        pixels.draw(svTriangle, svTriangleDrawMatrix, null, null, null, true);
    }
    
    protected function _drawHCircle() : void {
        var px:int, py:int, rgb:uint, d:Number, pmax:int = circleRadius * 2, 
            r2:Number = pmax * pmax, w2:Number = triangleSize * triangleSize, 
            temp:BitmapData = new BitmapData(hCircle.width*2, hCircle.height*2, true, 0);
        for (py=-pmax; py<pmax; py++) for (px=-pmax; px<pmax; px++) {
            d = px * px + py * py;
            if (w2<=d && d<=r2) {
                rgb = hsv2rgb(Math.atan2(px, -py)*0.15915494309189534, 1, 1);
                temp.setPixel32(px+pmax, py+pmax, 0xff000000|rgb);
            }
        }
        temp.applyFilter(temp, temp.rect, temp.rect.topLeft, _shadowx2);
        hCircle.fillRect(hCircle.rect, 0xff000000|Style.PANEL);
        hCircle.draw(temp, new Matrix(0.5,0,0,0.5), null, null, null, true);
        temp.dispose();
    }
    
    protected function _drawSVTriangle() : void {
        matrix = baseMatrix.clone();
        matrix.rotate((_h+0.5)*6.283185307179586);
        invert = matrix.clone();
        invert.invert();
        svTriangle.fillRect(svTriangle.rect, 0);
        var px:int, py:int, rgb:uint, sx:Number, sy:Number, ss:Number, vv:Number, pmax:int = triangleSize, 
            a:Number = invert.a * 0.5, b:Number = invert.b * 0.5, 
            c:Number = invert.c * 0.5, d:Number = invert.d * 0.5, 
            tx:Number= invert.tx,      ty:Number= invert.ty;
        for (py=-pmax; py<pmax; py++) for (px=-pmax; px<pmax; px++) {
            sx = px * a + py * c + tx;
            sy = px * b + py * d + ty;
            if (sx+sy<=1 && sx>=0 && sy>=0) {
                vv = sx + sy;
                ss = (vv==0) ? 1 : (((sy - sx) / vv + 1) * 0.5);
                svTriangle.setPixel32(px+pmax, py+pmax, hsv2rgb(_h, ss, vv));
            }
        }
        svTriangle.applyFilter(svTriangle, svTriangle.rect, svTriangle.rect.topLeft, _shadowx2);
    }
    
    override protected function _onDragStart(e:MouseEvent) : void {
        var dx:Number = mouseX - circleRadius, dy:Number = mouseY - circleRadius,
            l2:Number = dx*dx + dy*dy, icr:Number = circleRadius - circleWidth;
        dragFunc = (l2 < icr * icr) ? _updateSVValue : _updateHValue;
        _onDragging(e);
        super._onDragStart(e);
    }
    
    protected function _updateHValue(dx:Number, dy:Number) : void {
        var len:Number = Math.sqrt(dx*dx + dy*dy), il:Number;
        if (len != 0) {
            il = (circleRadius - circleWidth * 0.5) / len;
            _h = Math.atan2(dx, -dy)*0.15915494309189534;
            if (_h<0) _h += 1;
            _drawSVTriangle();
            invalidate();
        }
    }
    
    protected function _updateHPointerPosition() : void {
        var radh:Number = (_h + 0.5) * 6.283185307179586;
        _hpointer.x = -Math.sin(radh) * (circleRadius - circleWidth * 0.5) + circleRadius;
        _hpointer.y = Math.cos(radh) * (circleRadius - circleWidth * 0.5) + circleRadius;
    }
    
    protected function _updateSVValue(dx:Number, dy:Number) : void {
        var sx:Number = dx * invert.a + dy * invert.c + invert.tx,
            sy:Number = dx * invert.b + dy * invert.d + invert.ty;
        sx = (sx<0) ? 0 : sx;
        sy = (sy<0) ? 0 : sy;
        if (sx+sy > 1) { 
            var iss:Number = 1/(sx + sy);
            sx *= iss;
            sy *= iss;
        }
        _v = sx + sy;
        _s = (_v==0) ? 1 : (((sy - sx) / _v + 1) * 0.5);
        _updateSVPointerPosition();
    }
    
    protected function _updateSVPointerPosition() : void {
        var sy:Number = _v * _s, sx:Number = _v - sy;
        _pointer.x = sx * matrix.a + sy * matrix.c + matrix.tx + circleRadius;
        _pointer.y = sx * matrix.b + sy * matrix.d + matrix.ty + circleRadius;
    }
    
    override protected function _onDragging(e:MouseEvent) : void {
        dragFunc(mouseX - circleRadius, mouseY - circleRadius);
        dispatchEvent(new Event(Event.CHANGE));
    }
}

class HColorBar extends ControlPad {
    function HColorBar(parent:DisplayObjectContainer, xpos:Number, ypos:Number, width:Number, height:Number, defaultHandler:Function=null) {
        super(parent, xpos, ypos, width, height, defaultHandler);
        _pointerRange = new Rectangle(0, height*0.5, width, 0);
        _pointer.y = _pointerRange.y;
    }
}

class VColorBar extends ControlPad {
    function VColorBar(parent:DisplayObjectContainer, xpos:Number, ypos:Number, width:Number, height:Number, defaultHandler:Function=null) {
        super(parent, xpos, ypos, width, height, defaultHandler);
        _pointerRange = new Rectangle(width*0.5, 0, 0, height);
        _pointer.x = _pointerRange.x;
    }
}

class GimpModel extends ColorChooserExModel {
    private var ctrl:ControlPad, bar:VColorBar, tabs:Array, cursor:Shape, _selectedTab:int;
    
    public function get selectedTab() : int { return _selectedTab; }
    public function set selectedTab(idx:int) : void {
        _selectedTab = idx;
        cursor.y = _selectedTab * 18 + 4;
        _setup();
    }
    
    function GimpModel(parent:DisplayObjectContainer, chooser:ColorChooserEx) {
        var y_:Number = 4, me:Sprite = this;
        super(parent, chooser);
        ctrl = new ControlPad(me, 8, 8, 100, 100, _onCtrlChange);
        bar = new VColorBar(me, 112, 8, 12, 100, _onBarChange);
        tabs = [newTab("H"), newTab("S"), newTab("V"), newTab("R"), newTab("G"), newTab("B")];
        addChild(cursor = new Shape());
        cursor.graphics.beginFill(0x8080ff, 0.25);
        cursor.graphics.drawRect(0,0,26,18);
        cursor.graphics.endFill();
        cursor.x = 130;
        selectedTab = 0;
        function newTab(label:String) : PushButton {
            var newButton:PushButton = new PushButton(me, 130, y_, label, _onTabClick);
            newButton.setSize(26, 18);
            y_ += 18;
            return newButton;
        }
    }

    override protected function _setup() : void {
        _updateColors();
        _updatePointer();
    }
    
    protected function _onTabClick(e:Event) : void {
        selectedTab = int((e.target.y + 10) / 20);
    }
    
    protected function _onCtrlChange(e:Event) : void {
        switch (_selectedTab) {
        case 0:  _s=ctrl.valueX; _v=ctrl.valueY; _HSVupdated(); break;
        case 1:  _v=ctrl.valueX; _h=ctrl.valueY; _HSVupdated(); break;
        case 2:  _h=ctrl.valueX; _s=ctrl.valueY; _HSVupdated(); break;
        case 3:  _g=ctrl.valueY*255; _b=ctrl.valueX*255; _RGBupdated(); break;
        case 4:  _b=ctrl.valueY*255; _r=ctrl.valueX*255; _RGBupdated(); break;
        default: _r=ctrl.valueY*255; _g=ctrl.valueX*255; _RGBupdated(); break;
        }
        _updateColors(true, false);
        _chooser.browseColorChoiceEx(value);
    }
    
    protected function _onBarChange(e:Event) : void {
        switch (_selectedTab) {
        case 0:  _h=bar.valueY; _HSVupdated(); break;
        case 1:  _s=bar.valueY; _HSVupdated(); break;
        case 2:  _v=bar.valueY; _HSVupdated(); break;
        case 3:  _r=bar.valueY*255; _RGBupdated(); break;
        case 4:  _g=bar.valueY*255; _RGBupdated(); break;
        default: _b=bar.valueY*255; _RGBupdated(); break;
        }
        _updateColors(false, true);
        _chooser.browseColorChoiceEx(value);
    }
    
    protected function _updateColors(b:Boolean=true, c:Boolean=true) : void {
        var rc:Rectangle = new Rectangle(0,0,12,1), i:int;
        if (_selectedTab<3) {
            switch (_selectedTab) {
            case 0: _drawHSV(b,c); break;
            case 1: _drawSVH(b,c); break;
            case 2: _drawVHS(b,c); break;
            }
        } else _drawRGB(5-_selectedTab,b,c);
        for (rc.y=99, i=0; i<100; rc.y--, i++) bar.pixels.fillRect(rc, _bar[i]);
        ctrl.pixels.fillRect(ctrl.pixels.rect, 0);
        ctrl.pixels.setVector(ctrl.pixels.rect, _mtx);
    }
    
    protected function _updatePointer() : void {
        switch (_selectedTab) {
        case 0:  bar.valueY=_h; ctrl.valueX=_s; ctrl.valueY=_v; break;
        case 1:  bar.valueY=_s; ctrl.valueX=_v; ctrl.valueY=_h; break;
        case 2:  bar.valueY=_v; ctrl.valueX=_h; ctrl.valueY=_s; break;
        case 3:  bar.valueY=_r*$$; ctrl.valueY=_g*$$; ctrl.valueX=_b*$$; break;
        case 4:  bar.valueY=_g*$$; ctrl.valueY=_b*$$; ctrl.valueX=_r*$$; break;
        default: bar.valueY=_b*$$; ctrl.valueY=_r*$$; ctrl.valueX=_g*$$; break;
        }
    }
    
    private var _bar:Vector.<uint> = new Vector.<uint>(100);
    private var _mtx:Vector.<uint> = new Vector.<uint>(10000);
    private function _drawHSV(b:Boolean, c:Boolean) : void {
        var h:Number=_h, s:Number=_s, v:Number=_v, i:int;
        if (b) for (i=0; i<100; i++) _bar[i] = hsv2rgb(i*0.01, 1, 1);
        if (c) for (i=0, v=99; v>=0; v--) for (s=0; s<100; s++, i++) _mtx[i] = hsv2rgb(h, s*0.01, v*0.01);
    }
    private function _drawSVH(b:Boolean, c:Boolean) : void {
        var h:Number=_h, s:Number=_s, v:Number=_v, i:int;
        if (b) for (i=0; i<100; i++) _bar[i] = hsv2rgb(h, i*0.01, i*0.005+0.5);
        if (c) for (i=0, h=99; h>=0; h--) for (v=0; v<100; v++, i++) _mtx[i] = hsv2rgb(h*0.01, s, v*0.01);
    }
    private function _drawVHS(b:Boolean, c:Boolean) : void {
        var h:Number=_h, s:Number=_s, v:Number=_v, i:int;
        if (b) for (i=0; i<100; i++) _bar[i] = hsv2rgb(h, 1, i*0.01);
        if (c) for (i=0, s=99; s>=0; s--) for (h=0; h<100; h++, i++) _mtx[i] = hsv2rgb(h*0.01, s*0.01, v);
    }
    private function _drawRGB(rgbIndex:int, b:Boolean, c:Boolean) : void {
        var shift:int = rgbIndex*8, shiftx:int = [8,16,0][rgbIndex], shifty:int = [16,0,8][rgbIndex],
            rgb:uint = value, col:int = 0xff000000|rgb&~(0xff<<shift), i:int, x:int, y:int;
        if (b) for (i=0; i<100; i++) _bar[i] = 0xff000000 | (int(i*2.55)<<shift);
        if (c) {
            col = 0xff000000|rgb&~((0xff<<shiftx)|(0xff<<shifty));
            for (i=0, y=99; y>=0; y--) for (x=0; x<100; x++, i++) _mtx[i] = col | (int(x*2.55)<<shiftx)|(int(y*2.55)<<shifty);
        }
    }
}

class ColorChooser6Numbers extends ColorChooserExModel {
    protected var numbers:Array = [], _labelx:Number, _numbery:Number = 5;
    
    function ColorChooser6Numbers(parent:DisplayObjectContainer, chooser:ColorChooserEx) { super(parent, chooser); }
    
    protected function _createNumbers(labelx:Number) : void {
        _labelx = labelx;
        _newNumber("H", _onHSVChange, _onHSVTextChange);
        _newNumber("S", _onHSVChange, _onHSVTextChange);
        _newNumber("V", _onHSVChange, _onHSVTextChange);
        _newNumber("R", _onRGBChange, _onRGBTextChange);
        _newNumber("G", _onRGBChange, _onRGBTextChange);
        _newNumber("B", _onRGBChange, _onRGBTextChange);
    }
    
    protected function _newNumber(label:String, onChange:Function, onEdit:Function) : void {
        var input:InputText = new InputText(this, 128, _numbery, "0", onEdit);
        input.setSize(28, 18);
        input.restrict = "0-9";
        numbers.push(input);
        new Label(this, _labelx, _numbery, label);
        _numbery += 18;
    }
    
    protected function _onHSVChange(e:Event) : void {}
    protected function _onHSVTextChange(e:Event) : void {
        _h = Number(numbers[0].text) * 0.002777777777777778;
        _s = Number(numbers[1].text) * 0.01;
        _v = Number(numbers[2].text) * 0.01;
        if (_h<0) _h=0 else if (_h>1) _h=1;
        if (_s<0) _s=0 else if (_s>1) _s=1;
        if (_v<0) _v=0 else if (_v>1) _v=1;
        _updateColors();
        _updatePointer();
        _chooser.browseColorChoiceEx(value);
    }
    
    protected function _onRGBChange(e:Event) : void {}
    protected function _onRGBTextChange(e:Event) : void {
        _r = int(numbers[3].text);
        _g = int(numbers[4].text);
        _b = int(numbers[5].text);
        if (_r<0) _r=0 else if (_r>255) _r=255;
        if (_g<0) _g=0 else if (_g>255) _g=255;
        if (_b<0) _b=0 else if (_b>255) _b=255;
        _updateColors();
        _updatePointer();
        _chooser.browseColorChoiceEx(value);
    }
    
    protected function _updateColors() : void {}
    protected function _updatePointer() : void {}
    protected function _updateNumbers() : void {
        numbers[0].text = String(int(_h*360));
        numbers[1].text = String(int(_s*100));
        numbers[2].text = String(int(_v*100));
        numbers[3].text = String(_r);
        numbers[4].text = String(_g);
        numbers[5].text = String(_b);
    }
}

class BarsModel extends ColorChooser6Numbers {
    protected var bars:Array = [];
    
    function BarsModel(parent:DisplayObjectContainer, chooser:ColorChooserEx) {
        super(parent, chooser);
        _createNumbers(4);
    }

    override protected function _newNumber(label:String, onChange:Function, onEdit:Function) : void {
        bars.push(new HColorBar(this, 20, _numbery+4, 100, 10, onChange));
        return super._newNumber(label, onChange, onEdit);
    }
    
    override protected function _setup() : void {
        _updateColors();
        _updatePointer();
        _updateNumbers();
    }
    
    override protected function _onHSVChange(e:Event) : void {
        _h = bars[0].valueX;
        _s = bars[1].valueX;
        _v = bars[2].valueX;
        _HSVupdated();
        bars[3].valueX = _r * $$;
        bars[4].valueX = _g * $$;
        bars[5].valueX = _b * $$;
        _updateColors();
        _updateNumbers();
        _chooser.browseColorChoiceEx(value);
    }
    
    override protected function _onRGBChange(e:Event) : void {
        _r = bars[3].valueX * 255;
        _g = bars[4].valueX * 255;
        _b = bars[5].valueX * 255;
        _RGBupdated();
        bars[0].valueX = _h;
        bars[1].valueX = _s;
        bars[2].valueX = _v;
        _updateColors();
        _updateNumbers();
        _chooser.browseColorChoiceEx(value);
    }
    
    override protected function _updateColors() : void {
        var h:Number=_h, s:Number=_s, v:Number=_v, rgb:uint = value, i:int, rc:Rectangle = new Rectangle(0,0,1,10);
        for (rc.x=0, i=0; i<100; rc.x++, i++) {
            bars[0].pixels.fillRect(rc, hsv2rgb(i*0.01, s, v));
            bars[1].pixels.fillRect(rc, hsv2rgb(h, i*0.01, v));
            bars[2].pixels.fillRect(rc, hsv2rgb(h, s, i*0.01));
            bars[3].pixels.fillRect(rc, (rgb&0x00ffff)|((i*2.55)<<16));
            bars[4].pixels.fillRect(rc, (rgb&0xff00ff)|((i*2.55)<<8));
            bars[5].pixels.fillRect(rc, (rgb&0xffff00)|((i*2.55)<<0));
        }
    }
    
    override protected function _updatePointer() : void {
        bars[0].valueX = _h;
        bars[1].valueX = _s;
        bars[2].valueX = _v;
        bars[3].valueX = _r * $$;
        bars[4].valueX = _g * $$;
        bars[5].valueX = _b * $$;
    }
}

class HueModel extends ColorChooser6Numbers {
    protected var circle:HueCircle;
    
    function HueModel(parent:DisplayObjectContainer, chooser:ColorChooserEx) {
        super(parent, chooser);
        _createNumbers(114);
        circle = new HueCircle(this, 8, 8, 50, 12, _onHueCircleChanged);
    }
    
    protected function _onHueCircleChanged(e:Event) : void {
        _h = circle.hue;
        _s = circle.sat;
        _v = circle.val;
        _HSVupdated();
        _updateNumbers();
        _chooser.browseColorChoiceEx(value);
    }
    
    override protected function _setup() : void { circle.setHSV(_h, _s, _v); _updateNumbers(); }
    override protected function _updateColors() : void { circle.setHSV(_h, _s, _v); }
}

class MemoryModel extends ColorChooserExModel {
    protected var colors:Vector.<uint> = new Vector.<uint>(16);
    protected var pallet:Sprite = new Sprite();
    
    function MemoryModel(parent:DisplayObjectContainer, chooser:ColorChooserEx) {
        super(parent, chooser);
        addChild(pallet);
        pallet.filters = [new DropShadowFilter(2, 45, Style.DROPSHADOW, 1, 2, 2, .3, 1, true)];
        pallet.buttonMode = true;
        pallet.addEventListener(MouseEvent.CLICK, _onColorSelected);
    }
    
    override protected function _setup() : void {
        memory(value);
        _updateColors();
    }
    
    protected function _updateColors() : void { 
        var i:int, g:Graphics = pallet.graphics;
        g.clear();
        for (i=0; i<16; i++) {
            g.beginFill(colors[i]);
            g.drawRect((i&7)*19+5, (i>>3)*19+5, 16, 16);
            g.endFill();
        }
    }
    
    protected function _onColorSelected(e:Event) : void {
        var idx:int = (int((mouseX - 3) / 19) & 7) + (int((mouseY - 3) / 19) << 3);
        if (idx>=0 && idx<16) {
            memory(value);
            _chooser.browseColorChoiceEx(colors[idx]);
        }
    }
    
    public function memory(color:uint) : void {
        var i:int, j:int=15;
        for (i=0; i<16; i++) if (colors[i] == color) { j = i; break; }
        for (; j>0; j--) colors[j] = colors[j-1];
        colors[0] = color;
        _updateColors();
    }
}
