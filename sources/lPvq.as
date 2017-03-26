package
{
    /**
     * Ported from: https://www.shadertoy.com/view/4dl3zS
     * 
     * Mouse down and drag to rotate ball.
     * 
     * 
     * @author Devon O.
     */
    
    import com.adobe.utils.*;
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.Texture;
    import flash.events.*;
    import flash.geom.Matrix3D;
    import flash.utils.getTimer;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class Ball extends Sprite
    {
        private var mContext3d:Context3D;
        private var mVertBuffer:VertexBuffer3D;
        private var mIndexBuffer:IndexBuffer3D; 
        private var mProgram:Program3D;
        private var mTexture:Texture;
        private var mTextureData:BitmapData;
        private var mMatrix:Matrix3D = new Matrix3D();
        private var mouseDown:Boolean = false;
        
        private static const FRAGMENT_SHADER:String =
    <![CDATA[
        //vec2 uv = -0.5+gl_FragCoord.xy / iResolution.xy;
        sub ft1.xy, v0.xy, fc0.zz
        
        //vec2 p = uv;
        //float d=sqrt(dot(p,p));
        // use distance
        mul ft0.x, ft1.x, ft1.x
        mul ft0.y, ft1.y, ft1.y
        add ft0.x, ft0.x, ft0.y
        sqt ft2.x, ft0.x
        
        // d = FT2.x
        
        // if(d<R)
        slt ft6.x, ft2.x, fc0.x
        
            // f5.x = (R+sqrt(R-d))
            sub ft5.x, fc0.x, ft2.x
            sqt ft5.x, ft5.x
            add ft5.x, ft5.x, fc0.x
            
            //uv.x=p.x/(R+sqrt(R-d));
            div ft3.x, ft1.x, ft5.x
            mul ft3.x, ft3.x, ft6.x
            
            //uv.y=p.y/(R+sqrt(R-d));
            div ft3.y, ft1.y, ft5.x
            mul ft3.y, ft3.y, ft6.x
            
            //fac = 0.005;
            mov ft4.x, fc0.w
            mul ft4.x, ft4.x, ft6.x
            
            //fac2 = 5.0;
            mov ft4.y, fc1.x
            mul ft4.y, ft4.y, ft6.x
            
        // else
        sge ft6.y, ft2.x, fc0.x
        
            // ft5.x = (d * d)
            mul ft5.x, ft2.x, ft2.x
            
            //uv.x=p.x/(d*d);
            div ft3.z, ft1.x, ft5.x
            mul ft3.z, ft3.z, ft6.y
            
            //uv.y=p.y/(d*d);
            div ft3.w, ft1.y, ft5.x
            mul ft3.w, ft3.w, ft6.y
            
            //fac = 0.02;
            mov ft4.z, fc1.y
            mul ft4.z, ft4.z, ft6.y
            
            //fac2 = 25.0;
            mov ft4.w, fc1.z
            mul ft4.w, ft4.w, ft6.y
            
            add ft3.x, ft3.x, ft3.z
            add ft3.y, ft3.y, ft3.w
            add ft4.x, ft4.x, ft4.z
            add ft4.y, ft4.y, ft4.w
            
            // uv = ft3.xy
            // fac  ft4.x
            // fac2 = ft4.y
            
        //uv.x=uv.x  -  iMouse.x*fac  +  fac*500.0*sin(0.2*iGlobalTime);
        mov ft1.x, fc2.x
        sin ft1.x, ft1.x
        mul ft1.x, ft1.x, fc2.z
        mul ft1.x, ft1.x, ft4.x
        
        mov ft1.y, fc3.x
        mul ft1.y, ft1.y, ft4.x
        
        add ft1.x, ft1.x, ft1.y
        sub ft3.x, ft3.x, ft1.x
        
        //uv.y=uv.y  -  iMouse.y*fac  +  fac*500.0*sin(0.4*iGlobalTime);
        mov ft1.x, fc2.y
        sin ft1.x, ft1.x
        mul ft1.x, ft1.x, fc2.z
        mul ft1.x, ft1.x, ft4.x
        
        mov ft1.y, fc3.y
        mul ft1.y, ft1.y, ft4.x
        
        add ft1.x, ft1.x, ft1.y
        sub ft3.y, ft3.y, ft1.x
        
        //col = texture2D(iChannel0, uv/fac2).xyz;
        div ft3.xy, ft3.xy, ft4.yy
        tex ft0, ft3.xy, fs0<2d, wrap, linear, mipnone>
        
        //col = col*exp(-3.0*(d-R)); // some lighting
        sub ft1.x, ft2.x, fc0.x
        mul ft1.x, ft1.x, fc3.z
        exp ft1.x, ft1.x
        mul ft0.xyz, ft0.xyz, ft1.xxx
        
        //col = col*(1.1-exp(-8.0*(abs(d-R)))); // and shading
        sub ft1.x, ft2.x, fc0.x
        abs ft1.x, ft1.x
        mul ft1.x, ft1.x, fc3.w
        exp ft1.x, ft1.x
        sub ft1.x, fc2.w, ft1.x
        mul ft0.xyz, ft0.xyz, ft1.xxx
        
        mov ft0.w, fc1.w
        
        mov oc, ft0
    ]]>
        
        public function Ball()
        {    
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);    
        }
        
        private function init(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            initStage();
            start();
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
            addEventListener(Event.ENTER_FRAME, onTick);
        }
        
        private function start():void
        {
            mTextureData = checkerBoard(512, 512, 16);    
            stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, initStage3d );
            stage.stage3Ds[0].requestContext3D();
        }
        
        private function initStage():void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            mouseDown = true;
        }
        
        private function onMouseUp(event:*):void
        {
            mouseDown = false;
        }
        
        private function initStage3d(event:Event):void
        {
            mContext3d = stage.stage3Ds[0].context3D;            
            
            mContext3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, true);
            
            var vertices:Vector.<Number> = Vector.<Number>([
            //    x        y        z            u     v
                -1.0,     -1.0,     0,          0, 0, 
                -1.0,      1.0,     0,             0, 1,
                 1.0,      1.0,     0,             1, 1,
                 1.0,     -1.0,     0,            1, 0  ]);
            
            mVertBuffer = mContext3d.createVertexBuffer(4, 5);
            mVertBuffer.uploadFromVector(vertices, 0, 4);
            
            mIndexBuffer = mContext3d.createIndexBuffer(6);            
            mIndexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
            
            mTexture = mContext3d.createTexture(mTextureData.width, mTextureData.height, Context3DTextureFormat.BGRA, true);
            mTexture.uploadFromBitmapData(mTextureData);
            mTextureData.dispose();
            
            // va0 holds xyz
            mContext3d.setVertexBufferAt(0, mVertBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            
            // va1 holds uv
            mContext3d.setVertexBufferAt(1, mVertBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            
            generateMicroProg();
            
            mContext3d.setTextureAt(0, mTexture);
            mContext3d.setProgram(mProgram);
        }
        
        private function generateMicroProg():void
        {
            var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble(Context3DProgramType.VERTEX,
                "m44 op, va0, vc0  \n" +
                "mov v0, va1         "
            );
            
            var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
            fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
            
            mProgram = mContext3d.createProgram();
            mProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        private function onTick(event:Event):void
        {
            if ( !mContext3d ) 
                return;
            
            mContext3d.clear ( 0, 0, 0, 1 );
            
            // set vertex data from blank Matrix3D
            mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
            
            const R:Number = .25;
            var time:Number = getTimer() / 1000;
            var t2:Number = time * .20;
            var t4:Number = time * .40;
            
            var mousex:Number = mouseDown ? stage.mouseX : 1;
            var mousey:Number = mouseDown ? stage.stageHeight - stage.mouseY : 1;

            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ R, .66, .5, .005 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>( [ 5.0, .02, 25, 1 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>( [ t2, t4, 50, 1.1 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>( [ mousex, mousey, -3, -5 ]) );
            
            mContext3d.drawTriangles(mIndexBuffer);
            mContext3d.present();
        }
        
        /**
         * Create a checkerboard pattern BitmapData
         * see: http://www.purplesquirrels.com.au/2011/06/drawing-a-checker-board-pattern-quickly-with-as3/
         * @param    w        Width of bitmapdata
         * @param    h        Height of bitmapdata
         * @param    boxSize  Size of checkerboard boxes
         * @param    even     Color 1
         * @param    odd      Color 2
         * @return Checkerboard pattern BitmapData instance
         */
        private function checkerBoard(w:int, h:int, boxSize:int, even:uint=0xCCCCCC, odd:uint=0x999999):BitmapData
        {
            var nH:int = w / boxSize;
            var nV:int = h / boxSize;
            
            var clr:uint;
            var i:uint;
            var j:uint;
            
            var s:Shape = new Shape();
            var dat:BitmapData = new BitmapData(w, h, false, 0x0);
            
            for (i = 0; i < nV;++i)
            {
                even ^= odd;
                odd  ^= even;
                even ^= odd;
                
                for (j = 0; j < nH;++j)
                {
                    clr = j & 1 ? even : odd;
                    
                    s.graphics.beginFill(clr,1);
                    s.graphics.drawRect(Number(j*boxSize),Number(i*boxSize),boxSize,boxSize);
                    s.graphics.endFill();
                }
            }
            
            dat.draw(s);
            s.graphics.clear();
            
            return dat;
        }
    }
}