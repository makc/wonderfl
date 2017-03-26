package {
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.Style;
    import com.bit101.components.TextArea;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.getTimer;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {
        //const
        private const NUM_SIDE:uint = 2048;
        private const NUM_DATA:uint = NUM_SIDE * NUM_SIDE;
        private const RAD:Number = Math.PI / 180;
        //3D
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        private var indexBuffer:IndexBuffer3D;
        private var program:Program3D;
        private var texture:Texture;
        //data
        private var inputData:Vector.<Number>;
        private var cpu:Vector.<Number>;
        private var textureVector:Vector.<uint>;
        private var gpu:Vector.<Number>;
        private var sourceBd:BitmapData;
        private var resultBd:BitmapData;
        //ui
        private var timeText:TextField;
        private var verifyText:TextArea;
        //count
        private var start:uint;
        private var cpuTime:uint = 0;
        private var prepareTime:uint = 0;
        private var textureTime:uint = 0;
        private var drawTime:uint = 0;
        private var readTime:uint = 0;

        public function Main():void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            //set ui
            Style.embedFonts = false;
            Style.fontName = "Terminal";
            Style.fontSize = 14;
            verifyText = new TextArea(this, 0, 0, "");
            verifyText.setSize(300, 500);
            timeText = new TextField();
            timeText.height = 300;
            timeText.width = 200;
            addChild(timeText);
            timeText.x = 320;
            //
            //create input data and preapre output Vector
            inputData = new Vector.<Number>(NUM_DATA);
            cpu = new Vector.<Number>(NUM_DATA);
            textureVector = new Vector.<uint>(NUM_DATA);
            gpu = new Vector.<Number>(NUM_DATA);
            sourceBd = new BitmapData(NUM_SIDE, NUM_SIDE, false);
            resultBd = new BitmapData(NUM_SIDE, NUM_SIDE, false);
            //
            stage3D = stage.stage3Ds[0];
            stage3D.x = 0;
            stage3D.y = 0;
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onContextCreate(e:Event):void {
            start = getTimer();
            context3D = stage3D.context3D;
            //context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(NUM_SIDE, NUM_SIDE, 0, false);
            //shader
            var vertexShader:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShader.assemble(Context3DProgramType.VERTEX, "mov op, va0\n" + "mov v0, va1\n");
            //
            var fragmentShader:AGALMiniAssembler = new AGALMiniAssembler();
            var fragmentString:String = "";
            fragmentString += "mov ft0 v0\n";
            fragmentString += "tex ft0, ft0, fs0<2d,clamp,linear>\n";
            ////各成分からft0.xにuintを入れる
            fragmentString += "mul ft0, ft0, fc0.w\n"; //ft0=ft0*255...rgbに255かけて0xff形式に直す
            fragmentString += "frc ft1, ft0\n"; //ft1=fractional(ft0)...なおしたものの小数部
            fragmentString += "sub ft0, ft0, ft1\n"; //ft0=ft0-ft1...なおしたものの整数部(ft1は用済み)
            fragmentString += "dp3 ft0.x, ft0, fc0\n"; //ft0=ft0*fc0...直したものに重みをかけて足す(uint形式になる)
            //浮動小数点に戻す
            fragmentString += "div ft0.x, ft0.x, fc1.y\n"; //ft0.x=ft0.x/2^14...uint→ufloat
            fragmentString += "sub ft0.x, ft0.x, fc1.x\n"; //ft0.x=ft0.x-512...ufloat→float
            ////演算
            //fragmentString += "add ft0.x, ft0.x, fc1.x\n"; //ft0.x=ft0.x+fc1.x...加算
            //fragmentString += "mul ft0.x, ft0.x, fc1.y\n"; //ft0.x=ft0.x*fc1.y...積算
            //fragmentString += "sub ft0.x, ft0.x, fc1.z\n"; //ft0.x=ft0.x-fc1.z...減算
            fragmentString += "mul ft0.x, ft0.x, fc2.x\n";
            fragmentString += "cos ft0.x, ft0.x\n";
            fragmentString += "abs ft0.x, ft0.x\n";
            fragmentString += "rsq ft0.x, ft0.x\n";
            ////戻す
            //浮動小数点から戻す
            fragmentString += "add ft0.x, ft0.x, fc1.x\n"; //ft0.x=ft0.x+512...float→ufloat
            fragmentString += "mul ft0.x, ft0.x, fc1.y\n"; //ft0.x=ft0.x*2^14...ufloat→uint
            //r
            fragmentString += "div ft1.x, ft0.x, fc0.x\n"; //ft1.x=ft0.x/0xffff...ft1.xに演算結果を0xffffで割った答えを入れる。これの整数部がr
            fragmentString += "frc ft2.x, ft1.x\n"; //ft2.x=fractional(ft1.x)...rの小数部
            fragmentString += "sub ft1.x, ft1.x, ft2.x\n"; //ft1.x=ft1.x-ft2.x...rの整数部(ft2.xは用済み)
            //g
            fragmentString += "mul ft1.y, ft1.x, fc0.x\n"; //ft1.y=ft1.x*0xffff...r*0xffff
            fragmentString += "sub ft0.y, ft0.x, ft1.y\n"; //ft0.y=ft0.x*ft1.y...演算結果-r*0xffff(gbが残る)
            fragmentString += "div ft1.y, ft0.y, fc0.y\n"; //ft1.y=ft0.y/0xff...ft1.yにgbを0xffで割った答えを入れる。これの整数部がg
            fragmentString += "frc ft2.y, ft1.y\n"; //ft2.y=fractional(ft1.y)...gの小数部
            fragmentString += "sub ft1.y, ft1.y, ft2.y\n"; //ft1.y=ft1.y-ft2.y...gの整数部(ft2.yは用済み)
            //b
            fragmentString += "mul ft1.z, ft1.y, fc0.y\n"; //ft1.z=ft1.y*0xff...g*0xff
            fragmentString += "sub ft1.z, ft0.y, ft1.z\n"; //ft1.z=ft0.y*ft1.z...演算結果-r*0xffff-g*0xff(bが残る)
            ////
            fragmentString += "div ft0, ft1, fc0.w\n"; //ft0=ft1/255...rgbをスケーリング
            fragmentString += "mov ft0.w, fc0.z\n"; //ft0.w=1...アルファはつねに1にしないとgetPixelできない
            //
            fragmentString += "mov oc, ft0";
            fragmentShader.assemble(Context3DProgramType.FRAGMENT, fragmentString);
            //
            program = context3D.createProgram();
            program.upload(vertexShader.agalcode, fragmentShader.agalcode);
            //constant
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([256 * 256, 256, 1, 255.0001]), 1); //変換用
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([1 << 9, 1 << 14, 1, 0]), 1); //浮動小数点変換用
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([RAD, 26, 1, 0]), 1); //演算用
            //buffer
            var vertexBuffer:VertexBuffer3D = context3D.createVertexBuffer(4, 4);
            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            context3D.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            vertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 1, -1, 1, 0, 0, 1, -1, 1, 1, 1, 1, 1, 0]), 0, 4);
            //
            indexBuffer = context3D.createIndexBuffer(6);
            indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
            //texture
            texture = context3D.createTexture(NUM_SIDE, NUM_SIDE, Context3DTextureFormat.BGRA, false);
            prepareTime += getTimer() - start;
            //
            stage.addEventListener(MouseEvent.CLICK, execute);
        }

        private function execute(e:MouseEvent):void {
            for (var k:int = 0; k < NUM_DATA; k++){
                inputData[k] = 1024 * (Math.random() - 0.5);
            }
            //
            //calc in cpu
            calcCPU();
            //
            //calc in gpu
            //texture
            start = getTimer();
            for (var i:int = 0; i < NUM_DATA; i++){
                textureVector[i] = (inputData[i] + 512) * 16384 >> 0;
            }
            sourceBd.setVector(sourceBd.rect, textureVector);
            texture.uploadFromBitmapData(sourceBd);
            context3D.setTextureAt(0, texture);
            textureTime = getTimer() - start;
            //
            //////////////////////////////////////////execute
            start = getTimer();
            context3D.setProgram(program);
            context3D.clear(0, 0, 0, 1);
            context3D.drawTriangles(indexBuffer);
            //
            context3D.drawToBitmapData(resultBd);
            drawTime = getTimer() - start;
            //
            readBitmapData(resultBd);
            //
            verifyData();
            var str:String = "";
            str += "CPU : " + cpuTime + " ms\n";
            str += "GPU : " + (prepareTime + textureTime + drawTime + readTime) + " ms\n\n";
            str += "prepare : " + prepareTime + " ms\n";
            str += "texture : " + textureTime + " ms\n";
            str += "calc+draw : " + drawTime + " ms\n";
            str += "read : " + readTime + " ms\n";
            timeText.text = str;
        }

        private function calcCPU():void {
            start = getTimer();
            for (var i:int = 0; i < NUM_DATA; i++){
                cpu[i] = 1 / Math.sqrt(Math.abs(Math.cos(inputData[i] * RAD)));
            }
            cpuTime = getTimer() - start;
        }

        private function readBitmapData(bd:BitmapData):void {
            start = getTimer();
            var gpuVector:Vector.<uint> = new Vector.<uint>(NUM_DATA);
            gpuVector = bd.getVector(bd.rect);
            for (var i:int = 0; i < NUM_DATA; i++){
                gpu[i] = (gpuVector[i] & 0xffffff) / 16384.0 - 512;
            }
            readTime = getTimer() - start;
        }

        private function verifyData():void {
            var verify:String = "";
            for (var i:int = 0; i < 100; i++){
                verify += i + "\t" + cpu[i] + "\t" + gpu[i] + "\n";
            }
            verifyText.text = verify;
        }

    }
}