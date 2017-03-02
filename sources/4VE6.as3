// forked from clockmaker's BitmapDataで配列に格納すると高速化するよ
// forked from clockmaker's 3D Flow Simulation with Field of Blur
// forked from clockmaker's 3D Flow Simulation
// forked from clockmaker's Interactive Liquid 10000
// forked from clockmaker's Liquid110000 By Vector
// forked from munegon's forked from: forked from: forked from: forked from: Liquid10000
// forked from Saqoosha's forked from: forked from: forked from: Liquid10000
// forked from nutsu's forked from: forked from: Liquid10000
// forked from nutsu's forked from: Liquid10000
// forked from zin0086's Liquid10000
package 
{
    /**
     * FP11でのテスト。5000パーティクル.速くはなるけど汎用性なし
     */

    import flash.display.*;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.*;
    import flash.events.*;
    import flash.text.TextField;
    import flash.utils.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    import com.bit101.components.ComboBox;
    
    [SWF(width="460", height="460", backgroundColor="0xFFFFFF")]
    public class c0Gi extends Sprite {
        private const TEXTURE_WIDTH:int = 2048;
        private const NUM_PARTICLE:uint = 16380; // パーティクル上限
        private var ROT_STEPS:int = 0;
        
        private var num_limit:uint = 5000; // レンダリングする数
        
        private var forceMap:BitmapData = new BitmapData( 233, 233, false, 0x000000 );
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var particleList:Vector.<Arrow> = new Vector.<Arrow>(NUM_PARTICLE, true);
        private var rect:Rectangle = new Rectangle( 0, 0, 465, 465 );
        private var seed:Number = Math.floor( Math.random() * 0xFFFF );
        private var offset:Array = [new Point(), new Point()];
        private var timer:Timer;
        private var world:Sprite = new Sprite();
        private var rotBmp: BitmapData;
        private var text : TextField;
        
        private var combobox : ComboBox;
       
        private var context : Context3D;
        private var program : ShaderProgram;
        private var iBuffer : IndexBuffer3D;
        private var vBuffer : VertexBuffer3D;
        private var uvBuffer : VertexBuffer3D;
        private var texture : Texture;
        private var ortho : Matrix3D = new Matrix3D();
        private var r_rot_steps : Vector.<Number> = Vector.<Number>([0,0,0,0]);
        
        private var vb : Vector.<Number> = new Vector.<Number>();
        private var uvb : Vector.<Number> = new Vector.<Number>();
        private var ib : Vector.<uint> = new Vector.<uint>();
        private const vunit : int = 4;
        private const uvunit : int = 2;
        
        private var uirect : Sprite = new Sprite;
        
        public function c0Gi() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 120;
            
            addChild(world);
            
            // フォースマップの初期化をおこないます
            resetFunc();
            
            // ループ処理
            //addEventListener( Event.ENTER_FRAME, loop );
            
            // 時間差でフォースマップと色変化の具合を変更しています
            var timer:Timer = new Timer(1000)
            timer.addEventListener(TimerEvent.TIMER, resetFunc);
            timer.start();
            
            // 矢印をプレレンダリング
            var dummy:Sprite = new Sprite();
            dummy.graphics.beginFill(0xFFFFFF, 1);
            dummy.graphics.lineStyle(1, 0x0, 1);
            
            dummy.graphics.moveTo(2, 4);
            dummy.graphics.lineTo(8, 4);
            dummy.graphics.lineTo(8, 0);
            dummy.graphics.lineTo(20, 7);
            dummy.graphics.lineTo(8, 14);
            dummy.graphics.lineTo(8, 10);
            dummy.graphics.lineTo(2, 10);
            dummy.graphics.lineTo(2, 4);
            
            var bmpw : int = TEXTURE_WIDTH;
            ROT_STEPS = bmpw / 16; 
            var matrix:Matrix;
            rotBmp = new BitmapData(bmpw, 16, true, 0x0);
            var i:int = ROT_STEPS;
            while (i--)
            {
                matrix = new Matrix();
                matrix.translate( -11, -7);
                matrix.rotate( ( 360 / ROT_STEPS * i )* Math.PI / 180);
                matrix.scale(0.75, 0.75); // ちょっと縮小
                matrix.translate( 8+i*16, 8);
                rotBmp.draw(dummy, matrix);
            }
            
            // パーティクルを生成します
            for (i = 0; i < NUM_PARTICLE; i++) {
                var px:Number = Math.random() * 465;
                var py:Number = Math.random() * 465;
                particleList[i] = new Arrow(px, py);
                //world.addChild(particleList[i]);
            }
            
            // ui
            uirect.graphics.clear();
            uirect.graphics.beginFill(0x000000, 0.8);
            uirect.graphics.drawRoundRect(0, 0, 200, 100, 16, 16);
            uirect.graphics.endFill();
            
            combobox = new ComboBox(uirect, 80, 8, "5000", new Array(500, 1000, 5000, 10000, 16380));
            combobox.selectedIndex = 2;
            num_limit = 5000;
            
            addChild(uirect);
            
            // デバッグ用のスタッツを表示しています
            addChild(new Stats);
            
            //
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, createContext3D);
            stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
            //stage.stage3Ds[0].viewPort = new Rectangle(0, 0, rect.width, rect.height);
            
        }
        
        private function createContext3D(e:Event):void 
        {
            context = (e.target as Stage3D).context3D;
            context.configureBackBuffer(460, 460, 0, false);
            context.setRenderToBackBuffer();
            context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            context.enableErrorChecking = true;

            text = new TextField();
            text.textColor = 0xffffff;
            text.text = context.driverInfo;
            text.width = 460;
            text.y = 440;
            addChild(text);
            
            program = new ShaderProgram(context, new VertexShader(), new FragmentShader());
            ortho = MatrixUtil.ortho(rect.width, rect.height, false);        
            r_rot_steps[0] = 1/ROT_STEPS;

            for (var i : int = 0; i < NUM_PARTICLE; i++) {
                // ためしに静的なポリゴン情報と、毎フレーム更新する位置情報を別のvertexBufferにしてみたけど、速度的には変化なし
                vb.push( -8, -8,  0, 0);
                vb.push(  8, -8,  0 ,0);
                vb.push(  8,  8,  0 ,0);
                vb.push( -8,  8,  0, 0);
                
                uvb.push( 0,          0);
                uvb.push( 1/ROT_STEPS,0);
                uvb.push( 1/ROT_STEPS,1);
                uvb.push( 0,          1);
                
                
                ib.push( i*4+0, i*4+1, i*4+2, i*4+0, i*4+2, i*4+3 );
            }
            vBuffer = context.createVertexBuffer(vb.length / vunit, vunit);
            vBuffer.uploadFromVector(vb, 0, vb.length / vunit);
            
            uvBuffer = context.createVertexBuffer(uvb.length / uvunit, uvunit);
            uvBuffer.uploadFromVector(uvb, 0, uvb.length / uvunit);
            
            iBuffer = context.createIndexBuffer(ib.length);
            iBuffer.uploadFromVector(ib,0,ib.length);
            
            try {
            texture = context.createTexture(TEXTURE_WIDTH, 16, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(rotBmp);
            context.setTextureAt( 1, texture );
            } catch (e:Error) {
                text.text = e.message;
            }
            
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function loop( e:Event ):void {
            
            context.clear(0.4, 0.4, 0.5, 1); // この位置にclearがないとテクスチャが消える
            
            num_limit = parseInt(combobox.items[combobox.selectedIndex]);
            
            var len:uint = num_limit < particleList.length ? num_limit : particleList.length ;
            var col:Number;
            var index : int = 0;
            for (var i:uint = 0; i < len; i++) {
                var arrow:Arrow = particleList[i];
                
                var oldX:Number = arrow.x;
                var oldY:Number = arrow.y;
                
                col = forceMap.getPixel( arrow.x >> 1, arrow.y >> 1);
                arrow.ax += ( (col      & 0xff) - 0x80 ) * .0005;
                arrow.ay += ( (col >> 8 & 0xff) - 0x80 ) * .0005;
                arrow.vx += arrow.ax;
                arrow.vy += arrow.ay;
                arrow.x += arrow.vx;
                arrow.y += arrow.vy;
                
                var _posX:Number = arrow.x;
                var _posY:Number = arrow.y;
                var rot:Number = - Math.atan2((_posX - oldX), (_posY - oldY)) * 180 / Math.PI + 90;
                var angle:int = rot / 360 * ROT_STEPS | 0;
                // Math.absの高速化ね
                angle = (angle ^ (angle >> 31)) - (angle >> 31);
                //arrow.rot += (angle - arrow.rot) * 0.2;
                //arrow.bitmapData = rotBmp;
                    
                arrow.ax *= .96;
                arrow.ay *= .96;
                arrow.vx *= .92;
                arrow.vy *= .92;
                
                // あと配置座標を整数化しておきます
                //arrow.x = arrow.x | 0;
                //arrow.y = arrow.y | 0;
                
                ( _posX > 465 ) ? arrow.x = 0 :
                    ( _posX < 0 ) ? arrow.x = 465 : 0;
                ( _posY > 465 ) ? arrow.y = 0 :
                    ( _posY < 0 ) ? arrow.y = 465 : 0;

                vb[index++] = (_posX - 465.0/2)-8;
                vb[index++] = (_posY - 465.0/2)-8;
                vb[index++] = angle >> 0;
                index++;
                
                vb[index++] = (_posX - 465.0/2)+8;
                vb[index++] = (_posY - 465.0/2)-8;
                vb[index++] = angle >> 0;
                index++;
                
                vb[index++] = (_posX - 465.0/2)+8;
                vb[index++] = (_posY - 465.0/2)+8;
                vb[index++] = angle >> 0;
                index++;
                
                vb[index++] = (_posX - 465.0/2)-8;
                vb[index++] = (_posY - 465.0/2)+8;
                vb[index++] = angle >> 0;
                index++;
            }
            vBuffer.uploadFromVector(vb, 0, num_limit*4); 

            context.setProgram(program.program);

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, ortho, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, r_rot_steps);
            
            context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(2, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            
            context.drawTriangles(iBuffer, 0, 2*num_limit);
            context.present();
        }
        
        private function resetFunc(e:Event = null):void{
            forceMap.perlinNoise(117, 117, 3, seed, false, true, 6, false, offset);
            
            offset[0].x += 1.5;
            offset[1].y += 1;
            seed = Math.floor( Math.random() * 0xFFFFFF );
        }
    }
}

import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.geom.Matrix3D;

import flash.display.*;

class Arrow// extends Bitmap
{
    public var rot:int = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;

    function Arrow( x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
}

class ShaderProgram
{
    public var program : Program3D = null;
    
    public function ShaderProgram(context : Context3D, vsh : AGALMiniAssembler, fsh : AGALMiniAssembler)
    {
        program = context.createProgram();
        program.upload(vsh.agalcode, fsh.agalcode);
    }
}

class VertexShader  extends AGALMiniAssembler
{
//
// <geometry inputs>
//  vBuffer0(x,y)     --> attribute(0) : va0.xy
//  vBuffer1(rot,rsv) --> attribute(1) : va1.x, va1.y
//  uvBuffer2(u,v)    --> attribute(2) : va2.xy
//
// <constants/parameters>
//  projmatrix(transposed)   --> | vc0.x  vc1.x  vc2.x  vc3.x |
//                               | vc0.y  vc1.y  vc2.y  vc3.y |
//                               | vc0.z  vc1.z  vc2.z  vc3.z |
//                               | vc0.w  vc1.w  vc2.w  vc3.w |
//
//  texture coord step       --> vc4.x   (1/rotation steps)
//
// <outputs>
//  position                 --> op.xyzw
//
// <varying/vertex shader to fragment shader>
//  texture coord            --> v0.uv
//
//  m44 op, va0, vc0             position = (x,y) * projmatrix
//  mov v0, va2                  uv = (u,v)
//  mul vt0.x, va1.x, vc4.x      
//  add v0.x, va2.x, vt0.x       u = u + (rot*texture_coord_step)
//
    private var src : String =
        "m44 op, va0, vc0 \n" + // m33でもいいかも
        "mov v0, va2 \n" +
        "mul vt0.x, va1.x, vc4.x \n" +
        "add v0.x, va2.x, vt0.x \n" +
        "";    
        
    public function VertexShader()
    {
        assemble(Context3DProgramType.VERTEX, src);
    }
}

class FragmentShader  extends AGALMiniAssembler
{
    private var src : String =
        "mov ft0, v0\n" +
        "tex ft1, ft0.xy, fs1 <2d,repeat,nearest>\n" + 
        "mov oc, ft1\n";
    
    public function FragmentShader()
    {
        assemble(Context3DProgramType.FRAGMENT, src);
    }
}
class MatrixUtil
{
    public static function ortho(w : int, h : int, rev : Boolean) : Matrix3D
    {
        return new Matrix3D(Vector.<Number>([2/w, 0, 0, 0,  0, rev?-2/h:2/h, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1]));
    }

}

