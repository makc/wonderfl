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
/*
    import flash.text.TextField;
    import flash.display.Sprite;
    
    public class Main extends Sprite
    {
        function Main()
        {
            
            graphics.clear();
            var txt : TextField = new TextField();
            txt.text = "see http://escargot.la.coocan.jp/molehill/index.html";
            txt.width = stage.stageWidth;
            addChild(txt);
            
        }

    }

}
*/
    /**
     * FP11でのテスト。5000パーティクル.速くはなるけど汎用性なし
     * MacOSXだと不調。
     */
    import flash.display.*;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
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
    
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF")]
    public class c0Gi extends Sprite {
        private const TEXTURE_WIDTH:int = 2048;
        private const NUM_PARTICLE:uint = 5000;
        private var ROT_STEPS:int =0;
        
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

        
        private var context : Context3D;
        private var program : ShaderProgram;
        private var iBuffer : IndexBuffer3D;
        private var vBuffer : VertexBuffer3D;
        private var tBuffer : VertexBuffer3D;
        private var texture : Texture;
        private var ortho : Matrix3D = new Matrix3D();
        
        private var vb : Vector.<Number> = new Vector.<Number>();
        private var tb : Vector.<Number> = new Vector.<Number>();
        private var ib : Vector.<uint> = new Vector.<uint>();
        private const vunit : int = 4;
        private const tunit : int = 4;
        
        public function c0Gi() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 60;
            
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
            for (var r : int = 0; r < ROT_STEPS; r++) {
                matrix = new Matrix();
                matrix.translate( -11, -7);
                matrix.rotate( ( 360 / ROT_STEPS * r )* Math.PI / 180);
                matrix.scale(0.75, 0.75); // ちょっと縮小
                matrix.translate( 8+r*16, 8);
                rotBmp.draw(dummy, matrix);
            }
            
            // パーティクルを生成します
            for (var i : int  = 0; i < NUM_PARTICLE; i++) {
                var px:Number = Math.random() * 465;
                var py:Number = Math.random() * 465;
                particleList[i] = new Arrow(px, py);
                //world.addChild(particleList[i]);
            }
            
            // デバッグ用のスタッツを表示しています
            addChild(new Stats);
            
            //
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, createContext3D);
            stage.stage3Ds[0].requestContext3D();
            stage.stage3Ds[0].viewPort = new Rectangle(0, 0, rect.width, rect.height);
            
        }
        
        private function createContext3D(e:Event):void 
        {
            context = (e.target as Stage3D).context3D;
            context.configureBackBuffer(465, 465, 0, false);
            context.setRenderToBackBuffer();
            context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            context.enableErrorChecking = true;

            text = new TextField();
            text.textColor = 0xffffff;
            text.text = context.driverInfo;
            text.width = 465;
            text.y = 450;
            addChild(text);
            
            program = new ShaderProgram(context, new VertexShader(), new FragmentShader());
            //MatrixUtil.ortho(ortho, rect.width, rect.height, false);
            // matrix.rawData[]って読みだし専用？書き込んでもシェーダーに渡した際に値が反映されない。
            //のでnew。使用する定数レジスタを平行投影matrixに間借りさせる。気休めだし非常によくない。このorthoに対して通常の演算はできないので注意
            ortho = new Matrix3D(Vector.<Number>([ 2.0 / rect.width, 0, 0, 0,   0, 2.0 / rect.height, 0, 0,  0, 0, 1, -0 / 100, 1 / ROT_STEPS/*間借り*/, 0, 0, 1]));
            // 後々のUV演算のためにvc0.wに相当する位置に1画像あたりの幅を設定しておく
            

            for (var i : int = 0; i < NUM_PARTICLE; i++) {
                // ためしに静的なポリゴン情報と、毎フレーム更新する位置情報を別のvertexBufferにしてみたけど、速度的には変化なし
                vb.push( -8, -8,  0, 0);
                vb.push(  8, -8,  1/ROT_STEPS,0);
                vb.push(  8,  8,  1/ROT_STEPS,1);
                vb.push( -8,  8,  0, 1);

                tb.push(  0, 0, 0, 20);
                tb.push(  0, 0, 0, 20);
                tb.push(  0, 0, 0, 20);
                tb.push(  0, 0, 0, 20);
                
                ib.push( i*4+0, i*4+1, i*4+2, i*4+0, i*4+2, i*4+3 );
            }
            vBuffer = context.createVertexBuffer(vb.length / vunit, vunit);
            vBuffer.uploadFromVector(vb, 0, vb.length / vunit);
            
            tBuffer = context.createVertexBuffer(tb.length / tunit, tunit);
            tBuffer.uploadFromVector(tb, 0, tb.length / tunit);
            
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
            
            context.clear(0.3, 0.4, 0.4, 1); // この位置にclearがないとテクスチャが消える
            
            var len:uint = particleList.length;
            var col:Number;
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
                arrow.rot += (angle - arrow.rot) * 0.2;
                arrow.bitmapData = rotBmp;
                    
                arrow.ax *= .96;
                arrow.ay *= .96;
                arrow.vx *= .92;
                arrow.vy *= .92;
                
                // あと配置座標を整数化しておきます
                arrow.x = arrow.x | 0;
                arrow.y = arrow.y | 0;
                
                ( _posX > 465 ) ? arrow.x = 0 :
                    ( _posX < 0 ) ? arrow.x = 465 : 0;
                ( _posY > 465 ) ? arrow.y = 0 :
                    ( _posY < 0 ) ? arrow.y = 465 : 0;

                for (var j : int = 0; j < 4; j++) {
                    tb[tunit * (i*4+j) + 0] = (_posX*2 / 465.0)-1;
                    tb[tunit * (i*4+j) + 1] = (_posY*2 / 465.0)-1;
                    tb[tunit * (i*4+j) + 3] = angle >> 0;
                }
            }
            tBuffer.uploadFromVector(tb, 0, tb.length / tunit); 

            context.setProgram(program.program);

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, ortho, true);
            
            context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(1, vBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(2, tBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
            
            context.drawTriangles(iBuffer, 0, 2*NUM_PARTICLE);
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

class Arrow extends Bitmap
{
    public var rot:int = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;

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
    private var src : String =
        // attribure pos : va0.xy
        // attribure uv : va1.xy
        // attribure rot : va2.w
        // uniforrm  mat : vc0,vc1,vc2,vc3
        "mov vt0.xyz, vc0.xyz\n"+ // 行列の1～3行目はsetProgramConstantsFromMatrixで渡されたmatrixをそのまま使う
        "mov vt1.xyz, vc1.xyz\n"+
        "mov vt2.xyz, vc2.xyz\n"+
        "mov vt3.xyzw, vc3.xyzw\n" +
        "mov vt0.w, va2.x\n" + // 4行目はattribute(2)で渡された位置情報を使う
        "mov vt1.w, va2.y\n" +
        "mov vt2.w, vc3.z\n" + // 4,3はvc3.z(=0)を流用
        "dp4 op.x, va0, vt0\n"+ // attribute(0)で渡されたx,yを変換
        "dp4 op.y, va0, vt1\n"+
        "dp4 op.z, va0, vt2\n"+
        "dp4 op.w, va0, vt3\n" +
        "mov v0, va1.xyzw\n"+ // varying(0)にUV座標を代入。まずはそのまま
        "mul vt4.x, va2.w, vc0.w\n"+ // attribute(2)のwに入っている角度情報を元にU値を演算↓式
        "add v0.x, va1.x, vt4.x\n" + // v0.u = u{va1.x} + rot{va2.w} * vc0.w{ = 1/ROOT_STEPS}
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
// 使ってない
class MatrixUtil
{
    public static function ortho(w : int, h : int, rev : Boolean) : Matrix3D
    {
        return new Matrix3D(Vector.<Number>([2/w, 0, 0, 0,  0, rev?-2/h:2/h, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1]));
    }

}
