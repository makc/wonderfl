// forked from Nyarineko's えびばでぽっきー！
package
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
        
    [SWF(width = "465", height = "465", backgroundColor = "0xFF0000", frameRate = "30")]
    
    public class PockyDay extends Sprite
    {
        private var _width:int;
        private var _height:int;
        private var _canvas:BitmapData;
        private var _context3D:Context3D;
        private var _program:Program3D;
        private var _vertexBuffer:VertexBuffer3D;
        private var _indexBuffer:IndexBuffer3D;
        private var _texture:Texture;
        private var _projection:Matrix3D;
        private var _view:Matrix3D;
        private var _finalTransform:Matrix3D;
        
        public function PockyDay()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            _width = stage.stageWidth;
            _height = stage.stageHeight;
            _canvas = new BitmapData(_width, _height, false, 0xAA0000);
            stage.addChild(new Bitmap(_canvas));
            
            var stage3D:Stage3D = this.stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }
        private function onContext3DCreate(e:Event):void
        {
            var stage3D:Stage3D = e.currentTarget as Stage3D;
            _context3D = stage3D.context3D;
            _context3D.configureBackBuffer(_width, _height, 2, false);
            _context3D.enableErrorChecking = false;
            _context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
            init();
        }
        
        //------------------------------------------------------
        //初期化
        //------------------------------------------------------
        private function init():void
        {
            //vertex program
            var vertexShader:Array = [
                "m44 op, va0, vc0",
                "mov v0, va1.xy"            
            ];
            //fragment program
            var fragmentShader:Array = [
                "tex ft0, v0, fs0 <2d,clamp,linear,nomip>",
                "mov oc, ft0"
            ];
            var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join('\n'));
            var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));
            _program = _context3D.createProgram();
            _program.upload( vertexAssembler.agalcode, fragmentAssembler.agalcode );
            
            //model
            var w:int = 16;
            var h:int = 512;
            var vertices:Vector.<Number> = Vector.<Number>([
                0,0,      0,0,
                w,0,    1,0,
                0,h,    0,1,
                w,h,    1,1
            ]);
            
            //vertex Buffer
            _vertexBuffer = _context3D.createVertexBuffer(4, 4);
            _vertexBuffer.uploadFromVector(vertices, 0, 4);
            
            //index buffer
            _indexBuffer = _context3D.createIndexBuffer(6);
            _indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 3, 2]), 0, 6);
            
            //texture
            _texture = new Pocky().getTexture(_context3D);
            
            //transforms
            _finalTransform = new Matrix3D();
            _projection = makeOrthographicProjection(_width, _height, -1, 1);
            _view = new Matrix3D();
            
            //mouse move
            stage.addEventListener(MouseEvent.MOUSE_MOVE, moveEvent);
            stage.addEventListener(MouseEvent.DOUBLE_CLICK, doubelClickEvent);
            stage.doubleClickEnabled = true;
            
            //clear once
            _context3D.clear(0xAA/255, 0, 0, 1);
        }
        
        //------------------------------------------------------
        //マウス移動
        //------------------------------------------------------
        private function moveEvent(e:MouseEvent):void
        {
            if(e.buttonDown) drawPocky();
        }
        
        private function doubelClickEvent(e:MouseEvent):void
        {
            _context3D.clear(0xAA/255, 0, 0, 1);
            _context3D.drawToBitmapData(_canvas);
        }
        
        //ポッキー！！
        private var ang:Number = -30;
        private var a:Number = 5;
        private function drawPocky():void
        {
            _view.identity();
            
            if(ang > 30) a = -5;
            if(ang < -30) a = 5;
            ang += a;
            var rotationZ:Number = ang + Math.random() * 4 - 2;
            var x:Number = stage.mouseX;
            var y:Number = stage.mouseY;
            
            var w:int = 10;
            var h:int = 400;
            _view.appendTranslation(-w/2, -h/2, 0);
            _view.appendRotation(rotationZ, Vector3D.Z_AXIS);
            _view.appendTranslation(w/2, h/2, 0);
            
            _view.appendTranslation(x-w/2, y-h/2, 0);
                        
            render();
        }
        
        private function render():void
        {
            //_context3D.clear(1, 0, 0, 0);
            
            _context3D.setProgram(_program);
            _context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2)
            _context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            _context3D.setTextureAt(0, _texture);
                        
            _finalTransform.identity();
            _finalTransform.append(_view);
            _finalTransform.append(_projection);
            _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _finalTransform, true);
            
            _context3D.drawTriangles(_indexBuffer, 0, 2);
            
            _context3D.setVertexBufferAt(0, null)
            _context3D.setVertexBufferAt(1, null);
            _context3D.setTextureAt(0, null);
            
            _context3D.drawToBitmapData(_canvas);
        }
        
        private function makeOrthographicProjection(w:Number, h:Number, n:Number, f:Number):Matrix3D
        {
            return new Matrix3D(Vector.<Number>
                ([                
                    2.0/w, 0.0, 0.0, 0.0,
                    0.0, -2.0/h, 0.0, 0.0,
                    0.0, 0.0, -2.0/(f-n), 0.0,
                    -1.0, 1.0, -(f+n)/(f-n), 1.0                
                ]));
        }
    }
}

import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.Texture;
import flash.geom.Matrix;

class Pocky extends Sprite
{
    public function Pocky()
    {
        var d:Number = 1.0 / 1638.4;
        var ran:Number = 170;//Math.random()*20;
        var m : Matrix = new Matrix();
        m.identity();
        m.scale(d * 10 , d * 400);
        graphics.beginGradientFill(
            GradientType.LINEAR,
            [0x663300 , 0x221100 , 0x663300],
            [     1.0 ,      1.0 ,      1.0],
            [       0 ,      127 ,      255],
            m
        );
        graphics.drawRoundRect(0,-120+ran,10,350,10,10);
        graphics.endFill();
        graphics.beginGradientFill(
            GradientType.LINEAR,
            [0xeedd33 , 0xaa6633 , 0xeedd55],
            [     1.0 ,      1.0 ,      1.0],
            [       0 ,      187 ,      255],
            m
        );
        graphics.drawRoundRect(0,-170+ran,10,60,10,10);
    }
    
    public function getTexture(context:Context3D):Texture
    {
        var w:int = 16;
        var h:int = 512;
        var source:BitmapData = new BitmapData(w, h, true, 0x0);
        var m:Matrix;//= new Matrix(1,0,0,1, w-this.width>>1, h-this.height>>1);
        source.draw(this, m);
        var texture:Texture = context.createTexture(w, h, Context3DTextureFormat.BGRA, false);
        texture.uploadFromBitmapData(source);
        source.dispose();
        return texture;
    }
}