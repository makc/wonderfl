package
{
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.HUISlider;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;

    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class Bokeh extends Sprite
    {
        
        private var mContext3d:Context3D;
        private var mVertBuffer:VertexBuffer3D;
        private var mIndexBuffer:IndexBuffer3D; 
        private var mProgram:Program3D;
        
        private var mSizeSlider:HUISlider;
        private var mSpeedSlider:HUISlider;
        
        private var mMatrix:Matrix3D = new Matrix3D();
        
        public function Bokeh()
        {    
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);    
        }
        
        private function init(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            initStage();
            initUI();
            setS3d();
    
            addEventListener(Event.ENTER_FRAME, onTick);
        }
        
        private function initUI():void
        {
            mSizeSlider = new HUISlider(this, 5, 5, "Size", onSizeChange);
            mSizeSlider.minimum = 16;
            mSizeSlider.maximum = 128;
            mSizeSlider.tick = .5;
            mSizeSlider.value = 18;
            
            mSpeedSlider = new HUISlider(this, 5, 20, "Speed", onSpeedChange);
            mSpeedSlider.tick = .01;
            mSpeedSlider.minimum = .01;
            mSpeedSlider.maximum = 2.0;
            mSpeedSlider.value = .2;
        }
        
        private function onSizeChange(event:Event):void { }
    
        private function onSpeedChange(event:Event):void{}
        
        private function setS3d():void
        {
            stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, initStage3d );
            stage.stage3Ds[0].requestContext3D();
        }
        
        private function initStage():void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }
        
        private function initStage3d(event:Event):void
        {
            mContext3d = stage.stage3Ds[0].context3D;        
            mContext3d.enableErrorChecking = false;
            
            mContext3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, true);
            
            var vertices:Vector.<Number> = Vector.<Number> ([
            //    X,        Y,        Z,        r,    g,    b,        u,    v,        cx, cy, flag
                -1.0,    -1.0,    0.0,    1,    0,    1,        0,    0,        0.2, 0.4, 1.0,
                1.0,    -1.0,    0.0,    1,    0,    0,        1,    0,        0.2, 0.4, 1.0,
                1.0,    1.0,    0.0,    0,    1,    0,        1,    1,        0.2, 0.4, 1.0,
                -1.0,    1.0,    0.0,    1,    0,    1,        0,  1,        0.2, 0.4, 1.0
            ]);
            
            mVertBuffer = mContext3d.createVertexBuffer(vertices.length / 11, 11);
            mVertBuffer.uploadFromVector(vertices, 0, vertices.length / 11);
            mContext3d.setVertexBufferAt( 0, mVertBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 );
            mContext3d.setVertexBufferAt( 1, mVertBuffer,  6, Context3DVertexBufferFormat.FLOAT_2 );
            mContext3d.setVertexBufferAt( 2, mVertBuffer,  3, Context3DVertexBufferFormat.FLOAT_3 );
            mContext3d.setVertexBufferAt( 3, mVertBuffer,  8, Context3DVertexBufferFormat.FLOAT_3 );
            

            mIndexBuffer = mContext3d.createIndexBuffer(6);            
            mIndexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);

            generateProgram();
            
            mContext3d.setProgram(mProgram);
        }
        
        
        private function generateProgram():void
        {
            var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "m44 op, va0, vc0     \n" +
                "mov v0, va1     \n" +
                "mov v1, va2     \n" +
                "mov v2, va3     " 
            );
            
            var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
                "div ft0, v0.xy, fc0.y                \n" +
                "mul ft0, ft0, fc27.y                \n" +
                "sub ft0.x, ft0.x, fc0.y                \n" +
                "sub ft0.y, ft0.y, fc0.x                \n" +
                "mov ft2, fc0                \n" +
                "mov ft1, fc0                \n" +
                "add ft3, fc1.x, ft0.x                \n" +
                "add ft4, fc1.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft1.x, fc0.x, ft3                \n" +
                "add ft3, fc1.z, ft0.x                \n" +
                "add ft4, fc1.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc2.x, ft0.x                \n" +
                "add ft4, fc2.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc2.z, ft0.x                \n" +
                "add ft4, fc2.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc3.x, ft0.x                \n" +
                "add ft4, fc3.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc3.z, ft0.x                \n" +
                "add ft4, fc3.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc4.x, ft0.x                \n" +
                "add ft4, fc4.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc4.z, ft0.x                \n" +
                "add ft4, fc4.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +    
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc5.x, ft0.x                \n" +    
                "add ft4, fc5.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +        
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.x, fc0.x, ft3                \n" +
                "add ft1.x, ft1.x, ft2.x                \n" +
                "add ft3, fc6.x, ft0.x                \n" +
                "add ft4, fc6.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft1.y, fc0.x, ft3                \n" +
                "add ft3, fc6.z, ft0.x                \n" +
                "add ft4, fc6.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc7.x, ft0.x                \n" +
                "add ft4, fc7.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc7.z, ft0.x                \n" +
                "add ft4, fc7.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc8.x, ft0.x                \n" +
                "add ft4, fc8.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc8.z, ft0.x                \n" +
                "add ft4, fc8.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc9.x, ft0.x                \n" +
                "add ft4, fc9.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc9.z, ft0.x                \n" +
                "add ft4, fc9.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc10.x, ft0.x                \n" +
                "add ft4, fc10.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.y, fc0.x, ft3                \n" +
                "add ft1.y, ft1.y, ft2.y                \n" +
                "add ft3, fc11.x, ft0.x                \n" +
                "add ft4, fc11.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft1.z, fc0.x, ft3                \n" +
                "add ft3, fc11.z, ft0.x                \n" +
                "add ft4, fc11.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.z, fc0.x, ft3                \n" +
                "add ft1.z, ft1.z, ft2.z                \n" +
                "add ft3, fc12.x, ft0.x                \n" +
                "add ft4, fc12.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.z, fc0.x, ft3                \n" +
                "add ft1.z, ft1.z, ft2.z                \n" +
                "add ft3, fc12.z, ft0.x                \n" +
                "add ft4, fc12.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.z, fc0.x, ft3                \n" +
                "add ft1.z, ft1.z, ft2.z                \n" +
                "add ft3, fc13.x, ft0.x                \n" +
                "add ft4, fc13.y, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.z, fc0.x, ft3                \n" +
                "add ft1.z, ft1.z, ft2.z                \n" +
                "add ft3, fc13.z, ft0.x                \n" +
                "add ft4, fc13.w, ft0.y                \n" +
                "mul ft3, ft3, ft3                \n" +
                "mul ft4, ft4, ft4                \n" +
                "add ft3, ft3, ft4                \n" +
                "sqt ft3, ft3                \n" +
                "div ft2.z, fc0.x, ft3                \n" +
                "add ft1.z, ft1.z, ft2.z                \n" +
                "div ft1, ft1, fc27.x                \n" +
                "mov oc, ft1                "
            );
            
            mProgram = mContext3d.createProgram();
            mProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        private var mTime:Number = 0.0;
        private function onTick(event:Event):void
        {
            if ( !mContext3d ) 
                return;
            
            mContext3d.clear ( 0, 0, 0, 1 );
            mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
            
            
            // 0        resolution;
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ 1, 1, 1, 1 ]) );
            
            
            var p1:Object;
            var p2:Object;
            
            // POINTS
            // R
            p1 = makePoint(3.3, 2.9, 0.1, 0.1, mTime);
            p2 = makePoint(1.9, 2.0, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.8, 0.7, 0.4, 0.5, mTime);
            p2 = makePoint(2.3, 0.1, 0.6, 0.3, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.8, 1.7, 0.5, 0.4, mTime);
            p2 = makePoint(0.3, 1.0, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(1.4, 1.7, 0.4, 0.5, mTime);
            p2 = makePoint(1.3, 2.1, 0.6, 0.3, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(1.8, 1.7, 0.5, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, Vector.<Number>( [ p1.x, p1.y, 1, 1 ]) );
            
            
            // G
            p1 = makePoint(1.2, 1.9, 0.1, 0.2, mTime);
            p2 = makePoint(0.7, 2.7, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(1.4, 0.6, 0.4, 0.5, mTime);
            p2 = makePoint(2.6, 0.4, 0.6, 0.3, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.7, 1.4, 0.5, 0.4, mTime);
            p2 = makePoint(0.7, 1.7, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.8, 0.5, 0.4, 0.5, mTime);
            p2 = makePoint(1.4, 0.9, 0.6, 0.3, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.7, 1.3, 0.5, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, Vector.<Number>( [ p1.x, p1.y, 1, 1 ]) );
            
            // B
            p1 = makePoint(3.7, 0.3, 0.3, 0.3, mTime);
            p2 = makePoint(1.9, 1.3, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );

            p1 = makePoint(0.8, 0.9, 0.4, 0.5, mTime);
            p2 = makePoint(1.2, 1.7, 0.6, 0.3, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 12, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
            
            p1 = makePoint(0.3, 0.6, 0.5, 0.4, mTime);
            p2 = makePoint(0.3, 0.3, 0.4, 0.4, mTime);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 13, Vector.<Number>( [ p1.x, p1.y, p2.x, p2.y ]) );
                
            // constants 
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 27, Vector.<Number>([ mSizeSlider.value, 2, 3, 1 ]) );
        
            
            mContext3d.drawTriangles(mIndexBuffer);
            mContext3d.present();
            
            mTime += mSpeedSlider.value;
        }
        
        private function makePoint(fx:Number, fy:Number, sx:Number, sy:Number, t:Number):Object
        {
            var xx:Number = Math.sin(t * fx * 0.1) * sx;
            var yy:Number = Math.cos(t * fy * 0.1) * sy;
            return { x:xx, y:yy };
        }
        
    }
}