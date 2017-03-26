package {
    import com.adobe.utils.AGALMiniAssembler;
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
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import net.hires.debug.Stats;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {
        private var size:Number = 1;
        private var num:uint = 2000;
        private var angle:Number = 0;
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var program1:Program3D;
        private var program2:Program3D;
        private var program3:Program3D;
        private var indexBuffer:IndexBuffer3D;
        private var mtx:Matrix3D;
        private var axis:Vector3D;
        private var point:Vector3D;
        private var texture:Texture;
        private var screen:Texture;
        private var screenIndexBuffer:IndexBuffer3D;
        private var screenMtx:Matrix3D;
        private var screenVertexBuffer:VertexBuffer3D;
        private var vertexBuffer:VertexBuffer3D;

        //

        public function Main():void {
            Wonderfl.disable_capture();
            addChild(new Stats());
            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            //
            stage3D = stage.stage3Ds[0];
            stage3D.x = 0;
            stage3D.y = 0;
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onContextCreate(e:Event):void {
            context3D = stage3D.context3D;
            //context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(466, 466, 0, false);
            //text
            var tf:TextField = new TextField();
            tf.wordWrap = true;
            tf.width = 400;
            tf.text = context3D.driverInfo;
            tf.y = 460;
            addChild(tf);
            //create
            createShaders();
            setConstant();
            setBuffer();
            texture = context3D.createTexture(64, 64, Context3DTextureFormat.BGRA, true);
            screen = context3D.createTexture(512, 512, Context3DTextureFormat.BGRA, true);
            //run
            addEventListener(Event.ENTER_FRAME, onEnter);
        }

        private function onEnter(e:Event):void {
            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
            mtx = new Matrix3D();
            mtx.appendRotation(angle, axis, point);
            angle++;
            mtx.appendScale(1 / 256, 1 / 256, 1);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mtx, false);
            context3D.setProgram(program1);
            context3D.setRenderToTexture(screen);
            context3D.clear(0, 0, 0, 1);
            context3D.drawTriangles(indexBuffer);
            //
            context3D.setVertexBufferAt(0, screenVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            context3D.setVertexBufferAt(1, screenVertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, screenMtx, false);
            context3D.setProgram(program2);
            context3D.setRenderToTexture(texture);
            context3D.setTextureAt(0, screen);
            context3D.clear(0, 0, 0, 1);
            context3D.drawTriangles(screenIndexBuffer);
            //
            context3D.setProgram(program3);
            context3D.setRenderToBackBuffer();
            context3D.setTextureAt(0, screen);
            context3D.setTextureAt(1, texture);
            context3D.clear(0, 0, 0, 1);
            context3D.drawTriangles(screenIndexBuffer);
            context3D.present();
            //
            context3D.setTextureAt(0, null);
            context3D.setTextureAt(1, null);
        }

        //

        private function createShaders():void {
            //create shaders
            var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            //
            //vertex
            var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0 \n" + "mov v0, va1\n");
            //
            //fragment
            var code:String = "";
            code += "mov ft0 v0\n";
            code += "mov oc, ft0\n";
            var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            program1 = context3D.createProgram();
            program1.upload(vertexShader, fragmentShader);
            //
            code = "";
            code += "mov ft0 v0\n";
            code += "tex ft0, ft0, fs0<2d,repeat,linear>\n";
            code += "mov oc, ft0\n";
            fragmentShader = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            program2 = context3D.createProgram();
            program2.upload(vertexShader, fragmentShader);
            //
            code = "";
            code += "mov ft0 v0\n";
            code += "tex ft1, ft0, fs0<2d,repeat,linear>\n";
            code += "tex ft0, ft0, fs1<2d,repeat,linear>\n";
            code += "add ft0, ft0, ft1\n";
            code += "mov oc, ft0\n";
            fragmentShader = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            program3 = context3D.createProgram();
            program3.upload(vertexShader, fragmentShader);
        }

        private function setConstant():void {
            //vc
            mtx = new Matrix3D();
            axis = new Vector3D(0, 0, 1);
            point = new Vector3D(0, 0, 0);
            screenMtx = new Matrix3D();
        }

        private function setBuffer():void {
            //vertex buffer
            vertexBuffer = context3D.createVertexBuffer(4 * num, 6);
            var particles:Vector.<Number> = new Vector.<Number>();
            var indices:Vector.<uint> = new Vector.<uint>();
            for (var i:int = 0; i < num; i++){
                particles = particles.concat(createParticle((Math.random() - 0.5) * 700, (Math.random() - 0.5) * 700, Math.random() * 0xFFFFFF));
                var s:uint = 4 * i;
                indices = indices.concat(Vector.<uint>([s, s + 1, s + 2, s + 1, s + 2, s + 3]));
            }
            vertexBuffer.uploadFromVector(particles, 0, 4 * num);
            //index buffer
            indexBuffer = context3D.createIndexBuffer(6 * num);
            indexBuffer.uploadFromVector(indices, 0, 6 * num);
            //
            //
            //vertex buffer
            screenVertexBuffer = context3D.createVertexBuffer(4, 4);
            screenVertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 1, -1, 1, 0, 0, 1, -1, 1, 1, 1, 1, 1, 0]), 0, 4);
            //index buffer
            screenIndexBuffer = context3D.createIndexBuffer(6);
            screenIndexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
        }

        private function createParticle(xPos:Number, yPos:Number, color:uint):Vector.<Number> {
            var r:Number = (color >> 16) / 255;
            var g:Number = (color >> 8 & 0xFF) / 255;
            var b:Number = (color & 0xFF) / 255;
            return Vector.<Number>([xPos - size, yPos - size, 0, r, g, b, xPos - size, yPos + size, 0, r, g, b, xPos + size, yPos - size, 0, r, g, b, xPos + size, yPos + size, 0, r, g, b]);
        }

    }
}