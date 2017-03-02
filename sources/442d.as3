package  
{
    //import com.adobe.serialization.json.*;
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.CheckBox;
    import com.bit101.components.Slider;
    import flash.display.BitmapData;
    import flash.display.Shader;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.*;
    import flash.display3D.textures.Texture;
    import flash.events.*;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import net.hires.debug.Stats;
    import flash.text.TextFieldAutoSize;

    [SWF(width="460", height="460", backgroundColor="0xFFFFFF")]
    public class Main extends Sprite
    {
        private var WIDTH : int = 460;
        private var HEIGHT : int = 460;
        private var context : Context3D;
        
        private var fighter_model : Object;
        private var fighter : ObjsonForBevel;
        private var square_model : Object;
        private var square : ObjsonForBevel;
    
        private var program : ShaderProgram;
        private var simple_program : ShaderProgram;
        
        private var bvel_width : Number = 0.15;
        private var vconst4 : Vector.<Number> = Vector.<Number>([0.0, 0.1, 0.5, 1.0]);
        private var fconst0 : Vector.<Number> = Vector.<Number>([0.0, 0.1, 0.5, 1.0]);
        private var fconst1 : Vector.<Number> = Vector.<Number>([1.0, 2.0, bvel_width, Math.PI/(2*bvel_width)]); //[0]:wireframe sw
        private var light : Vector.<Number> = new Vector.<Number>(4);
        private var half : Vector.<Number> = new Vector.<Number>(4);
        private var eye : Vector.<Number> = new Vector.<Number>(4);
        private var material : Vector.<Number> = new Vector.<Number>(4);
        
        private var checkBevel : CheckBox;
        private var checkBevelOnly : CheckBox;
        private var checkSimpleModel : CheckBox;
        private var sliderWidth : Slider;
        private var sliderSharp : Slider;
        
        
        private var cam : Camera = new Camera();
        private var lightVec : Camera = new Camera();
        private var halfVec : Vector3D = new Vector3D;

        private var loaders : Array;
           private const url:Array = [
//            "./wasp.objson",
            "http://escargot.la.coocan.jp/molehill_smoothbevel/Spider.objson",
            "http://escargot.la.coocan.jp/molehill_smoothbevel/square.objson",
            ];
        
        public function Main() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        public function init(e:Event=null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
               loaders = new Array();
            for (var i : int = 0; i < url.length; i++) {
                loaders[i] = new URLLoader();
                loaders[i].addEventListener(Event.COMPLETE, modelLoaded);
                loaders[i].load(new URLRequest(url[i]));
            }
        }

        private var loadedCount : int = 0;
        private var txt : TextField = new TextField();
        
        public function modelLoaded( event : Event ) : void
        {
            loadedCount++;
            if (loadedCount < url.length) return;
            
            addChild(txt);
            
            var str : String = loaders[0].data;
            txt.autoSize = TextFieldAutoSize.LEFT;
            
            fighter_model = JSON.parse(str);
            txt.text = str; // ???stop
            
            str = loaders[1].data;
            square_model = JSON.parse(str);

            stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, createContext3D );
            stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO); 
            //stage.stage3Ds[0].viewPort = new Rectangle ( 0,0,WIDTH,HEIGHT ); 
            
            stage.frameRate = 60;
        }

        private function createContext3D(e:Event):void 
        {
            context = (e.target as Stage3D).context3D;
            context.configureBackBuffer(WIDTH, HEIGHT, 8, true);
            context.setRenderToBackBuffer();
            //context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            //context.enableErrorChecking = true;
            context.setCulling("front");
            
            fighter = new ObjsonForBevel(context, fighter_model);
            fighter.parse();
            square = new ObjsonForBevel(context, square_model);
            square.parse();
            
            program = new ShaderProgram(context, new VertexShader(), new FragmentShader());
            simple_program = new ShaderProgram(context, new VertexShader(), new SimpleFragmentShader());

            
            cam.perspective(45, WIDTH / HEIGHT, 0.1, 400);
            
            var uirect : Sprite = new Sprite();
            uirect.graphics.clear();
            uirect.graphics.beginFill(0x000000, 0.5);
            uirect.graphics.drawRoundRect(0, 0, 200, 100, 16, 16);
            uirect.graphics.endFill();
            checkBevel = new CheckBox( uirect, 80, 2, "Bevel Shader");
            checkBevelOnly = new CheckBox( uirect, 80, 20, "Bevel Only");
            checkBevel.selected = true;
            checkSimpleModel = new CheckBox( uirect, 80, 40, "SimpleModel", checkedSimpleModel );
            sliderWidth = new Slider("horizontal", uirect, 80, 60);
            sliderSharp = new Slider("horizontal", uirect, 80, 80);
            sliderWidth.maximum = 0.3;
            sliderWidth.value = 0.05;
            sliderSharp.maximum = 2.0;
            sliderSharp.value = 1.0;
            
            addChild(uirect);
            addChild(new Stats());

            this.addEventListener(Event.ENTER_FRAME, enterFrame);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        }
        
        private function checkedSimpleModel(e : Event) : void 
        {
            if (checkSimpleModel.selected) {
                sliderWidth.value = 0.03;
                sliderSharp.value = 1.0;
            } else {
                sliderWidth.value = 0.15;
                sliderSharp.value = 1.0;
            }
        }
            
        
        private var befDown : Point = new Point();
        private var isMouseDown : Boolean = false;
        private var RollH : Number = 0;
        private var RollV : Number = 70;
        private var Distance : Number = 100;
        
        private function mouseDown(e:MouseEvent):void 
        {
            if (e.target == stage) {
                isMouseDown = true;
                befDown.x = e.stageX;
                befDown.y = e.stageY;
            }
        }
        private function mouseUp(e:MouseEvent):void 
        {
            if (e.target == stage) {
                isMouseDown = false;
            }
        }
        
        
        private function enterFrame(e:Event):void 
        {
            context.clear(0.3, 0.35, 0.4, 1);
            
            if (checkBevel.selected || checkBevelOnly.selected)    context.setProgram(program.program);
            else                                                 context.setProgram(simple_program.program)
            
            if (isMouseDown) {
                if (false) {
                    Distance += befDown.y - stage.mouseY;
                    if (Distance < 0) Distance = 0;
                } else {
                    RollH += befDown.x - stage.mouseX;
                    RollV += befDown.y - stage.mouseY;
                    if (RollV < 0) RollV = 0; else if (RollV > 180) RollV = 180;
                }
                
                befDown.x = stage.mouseX;
                befDown.y = stage.mouseY;
            } else {
                RollH += checkSimpleModel.selected ? 5.0 : 1.0;
            }
            
            fconst1[0] = checkBevelOnly.selected ? 0 : 1;
            
            cam.lookAt(new Vector3D(0, 0, 0));
            cam.polarPosition(Distance, RollH*Math.PI/180, RollV*Math.PI/180);
            
            
            // ライトオブジェクトを作るのが面倒だったのでカメラで代用
            lightVec.lookAt(new Vector3D(0, 0, 0));
            lightVec.polarPosition(Distance, (RollH+30) * Math.PI / 180, (RollV-20) * Math.PI / 180);
            lightVec.getMatrix(false);
            lightVec.forward.normalize();
            light[0] = lightVec.forward.x;
            light[1] = lightVec.forward.y;
            light[2] = lightVec.forward.z;
            eye[0] = cam.forward.x;
            eye[1] = cam.forward.y;
            eye[2] = cam.forward.z;
            
            halfVec.x = (lightVec.forward.x + eye[0])/2;
            halfVec.y = (lightVec.forward.y + eye[1])/2;
            halfVec.z = (lightVec.forward.z + eye[2])/2;
            halfVec.normalize();
            half[0] = halfVec.x;
            half[1] = halfVec.y;
            half[2] = halfVec.z;
            
            material[0] = 0.8;
            material[1] = 0.9;
            material[2] = 1.0;
            material[3] = 64;
            
            fconst1[2] = sliderWidth.value;
            fconst1[3] = sliderSharp.value*Math.PI/(2*sliderWidth.value);
            
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, cam.getMatrix(true), true);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fconst0);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fconst1);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, light);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, half);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, eye);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, material);
            
            if (checkSimpleModel.selected) {
                square.setAttributes();
                square.draw();
            } else {
                fighter.setAttributes();
                fighter.draw();
            }
            

            context.present();
        }
        
    }

}

import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class Objson
{
    protected var context : Context3D;
    protected var model : Object;

    protected var iBuffer : IndexBuffer3D;
    protected var vBuffer : VertexBuffer3D;
    protected var index_count : uint;
    
    protected var iUnit : int;
    protected var vUnit : int;
    
    public function Objson(ctx3d : Context3D, model : Object)
    {
        this.context = ctx3d;
        this.model = model;
        
        iUnit = 3;
    }
    
    public function parse() : void { }
    
    public function setAttributes() : void { }
    
    public function draw() : void { }
}

    
class ObjsonForBevel extends Objson
{
    private var materials : Vector.<Number> = new Vector.<Number>();
    private var haveMaterials : Boolean = false;
    public function ObjsonForBevel(ctx3d : Context3D, model : Object)
    {
        super(ctx3d, model);
    }
    
    override public function parse() : void
    {
        var vertices:Vector.<Number> = new Vector.<Number>(0, false);
        var indices:Vector.<uint> = new Vector.<uint>(0, false);
        
        var i : int;
        var matcount : int = model.materials.length;
        var vcount : int = model.objects[0].meshes[0].vertex.count;
        var varray : Array = model.objects[0].meshes[0].vertex.array;
        var uvarray : Array = model.objects[0].meshes[0].uv.array;
        var smarray : Array = model.objects[0].meshes[0].smooth_normal.array;
        var nvarray : Array = model.objects[0].meshes[0].normal.array;
        var fcount : int = model.objects[0].meshes[0].face.count;
        var farray : Array = model.objects[0].meshes[0].face.array;
        var pos : int = 0;
        
        vUnit = 13;
        
        haveMaterials =  matcount > 1;
        if (haveMaterials) {
            vUnit += 3;
            for (i = 0; i < matcount; i++) {
                materials.push( model.materials[i].diffuse_col[0], model.materials[i].diffuse_col[1], model.materials[i].diffuse_col[2]);
            }
        }

        // べベルシェーダを簡易に実装したかったので、面毎に独立した頂点にした。エッジ情報が不要な部分は頂点を共有化すべき
        var vindex : int = 0;
        var regfunc : Function = function(n : int, i0 : int, i1 : int, i2 : int, i3 : int, edge0:Vector3D, edge1:Vector3D, edge2:Vector3D, edge3:Vector3D, matindex : int):void {
            vertices.push(varray[i0 * 3 + 0], varray[i0 * 3 + 1], varray[i0 * 3 + 2], nvarray[i0 * 3 + 0], nvarray[i0 * 3 + 1], nvarray[i0 * 3 + 2], edge0.x, edge0.y, edge0.z, edge0.w, smarray[i0 * 3 + 0], smarray[i0 * 3 + 1], smarray[i0 * 3 + 2]);
            if (haveMaterials) vertices.push( materials[matindex * 3 + 0], materials[matindex * 3 + 1], materials[matindex * 3 + 2]);
            vertices.push(varray[i1 * 3 + 0], varray[i1 * 3 + 1], varray[i1 * 3 + 2], nvarray[i1*3+0], nvarray[i1*3+1], nvarray[i1*3+2], edge1.x, edge1.y, edge1.z, edge1.w, smarray[i1*3+0], smarray[i1*3+1], smarray[i1*3+2]);
            if (haveMaterials) vertices.push( materials[matindex * 3 + 0], materials[matindex * 3 + 1], materials[matindex * 3 + 2]);
            vertices.push(varray[i2 * 3 + 0], varray[i2 * 3 + 1], varray[i2 * 3 + 2], nvarray[i2*3+0], nvarray[i2*3+1], nvarray[i2*3+2], edge2.x, edge2.y, edge2.z, edge2.w, smarray[i2*3+0], smarray[i2*3+1], smarray[i2*3+2]);
            if (haveMaterials) vertices.push( materials[matindex * 3 + 0], materials[matindex * 3 + 1], materials[matindex * 3 + 2]);
            
            indices.push( vindex++, vindex++, vindex++ );
            if (n == 4) {
                vertices.push(varray[i3 * 3 + 0], varray[i3 * 3 + 1], varray[i3 * 3 + 2], nvarray[i3*3+0], nvarray[i3*3+1], nvarray[i3*3+2], edge3.x, edge3.y, edge3.z, edge3.w, smarray[i3*3+0], smarray[i3*3+1], smarray[i3*3+2]);
                if (haveMaterials) vertices.push( materials[matindex * 3 + 0], materials[matindex * 3 + 1], materials[matindex * 3 + 2]);
                indices.push( vindex - 1, vindex , vindex - 3 );
                vindex++;
            }
        }
        var edge0 : Vector3D = new Vector3D(), edge1 : Vector3D = new Vector3D(), edge2 : Vector3D = new Vector3D(), edge3 : Vector3D = new Vector3D();
        for (i = 0; i < fcount; i++) {
            var n : int = farray[pos++];
            var matindex : int = farray[pos++];
            if (n == 3) {
                edge0.x = farray[pos + 1]; edge0.y = 1              ; edge0.z = farray[pos + 5]; edge0.w = 1;
                edge1.x = farray[pos + 1]; edge1.y = farray[pos + 3]; edge1.z = 1              ; edge1.w = 1;
                edge2.x = 1              ; edge2.y = farray[pos + 3]; edge2.z = farray[pos + 5]; edge2.w = 1;
                regfunc(3, farray[pos + 0], farray[pos + 2], farray[pos + 4], -1, edge0, edge1, edge2, edge3, matindex);
            } else {
                edge0.x = farray[pos + 1]; edge0.y = 1              ; edge0.z = 1              ; edge0.w = farray[pos + 7];
                edge1.x = farray[pos + 1]; edge1.y = farray[pos + 3]; edge1.z = 1              ; edge1.w = 1;
                edge2.x = 1              ; edge2.y = farray[pos + 3]; edge2.z = farray[pos + 5]; edge2.w = 1;
                edge3.x = 1              ; edge3.y = 1              ; edge3.z = farray[pos + 5]; edge3.w = farray[pos + 7];
                regfunc(4, farray[pos + 0], farray[pos + 2], farray[pos + 4], farray[pos + 6],  edge0, edge1, edge2, edge3, matindex);
            }
            
            pos += n*2;
        }
        index_count = indices.length;        
        
        vBuffer = context.createVertexBuffer(vertices.length/vUnit, vUnit);
        vBuffer.uploadFromVector (vertices, 0, vertices.length/vUnit );
        
        iBuffer = context.createIndexBuffer(indices.length);
        iBuffer.uploadFromVector(indices, 0, indices.length);
        
        model = null;
    }
    
    override public function setAttributes() : void
    {
        context.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        context.setVertexBufferAt(1, vBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
        context.setVertexBufferAt(2, vBuffer, 6, Context3DVertexBufferFormat.FLOAT_4);
        context.setVertexBufferAt(3, vBuffer, 10, Context3DVertexBufferFormat.FLOAT_3);
        if (haveMaterials) {
            context.setVertexBufferAt(4, vBuffer, 13, Context3DVertexBufferFormat.FLOAT_3);
        }
    }
    
    override public function draw() : void
    {
        context.drawTriangles(iBuffer, 0, index_count/iUnit);
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

class ShaderPreprocesser
{
    private var src : String;
    private var macro : Object;
    
    public function ShaderPreprocesser(macro : Object, source : String)
    {
        this.src = source;
        this.macro = macro;
        src = src.replace(/^\s+/gm, "");
        for (var key : String in macro) {
            var pat : RegExp = new RegExp(key, "g");
            src = src.replace(pat, macro[key]);
        }
    }
    
    public function getSource() : String
    {
        return src;
    }
}

class VertexShader  extends AGALMiniAssembler
{
    private var src : ShaderPreprocesser = new ShaderPreprocesser(
        {
            "=":",",
            matrix:"vc0",
            
            in_position:"va0",
            in_norm:"va1",
            in_edge:"va2",
            in_smooth:"va3",
            in_color:"va4",
            
            vr_norm   :"v0",
            vr_edge   :"v1",
            vr_smooth :"v2",
            vr_color  :"v3"
            
        }, <![CDATA[
            m44 vt0 := in_position, matrix
            mov vr_norm  = in_norm
            mov vr_edge  = in_edge
            mov vr_smooth   = in_smooth
            mov vr_color = in_color
            mov op  = vt0
        ]]>
    );
    
    public function VertexShader()
    {
        assemble(Context3DProgramType.VERTEX, src.getSource());
    }
}
class FragmentShader  extends AGALMiniAssembler
{
    private var src : ShaderPreprocesser = new ShaderPreprocesser(
        {
            "=":",", 
            "0.0":"fc0.x", "0.1":"fc0.y", "0.5":"fc0.z", "1.0":"fc0.w", "(1,1,1,1)":"fc0.wwww",
            
            wire_sw:"fc1.x", "2.0":"fc1.y", width:"fc1.z", pi_2:"fc1.wwww", 
            light  :"fc2",
            half   :"fc3",
            eye    :"fc4",
            mat    :"fc5",
            
            curve  :"ft0",
            nv1    :"ft1",
            nv2    :"ft2",
            temp   :"ft3",
            color1 :"ft4",
            bevel  :"ft5",
            color2 :"ft6",
            level  :"ft7",
            half   :"ft8",
            
            norm   :"v0",
            edge   :"v1",
            smooth :"v2",
            vcolor :"v3"
        },
        <![CDATA[
;            dp3 color1.w = light, norm
;            dp3 color2.w = light, smooth
            
            slt bevel.xyzw = edge.xyzw, width
            sub temp = "(1,1,1,1)", bevel
            mul curve = edge, pi_2
            sin curve.xyzw = curve.xyzw
            mul curve = curve, bevel
            add curve = curve, temp
            
            min level.x, curve.x, curve.y
            min level.x, level.x, curve.z
            min level.x, level.x, curve.w
            ;mul level.x = level.x, "2.0"

            sub level.y = "1.0", level.x
            mul level.x = level.x, wire_sw
            
            mul nv1 = norm, level.xxx 
            mul nv2 = smooth, level.yyy
            add nv1 = nv1, nv2
            nrm nv1.xyz = nv1.xyz
            dp3 color1.w = light, nv1
            dp3 color2.w = half, nv1
            pow color2.w = color2.w, mat.w
            mul color1.rgb = vcolor.rgb, color1.www
            mul color2.rgb = mat.rgb, color2.www
            
            add color1.rgb = color1.rgb, color2.rgb
            
            mov oc = color1.rgb
        ]]>
    );

    public function FragmentShader()
    {
        assemble(Context3DProgramType.FRAGMENT, src.getSource());
    }
}

class SimpleFragmentShader  extends AGALMiniAssembler
{
    private var src : ShaderPreprocesser = new ShaderPreprocesser(
        {
            "=":",", 
            "0.0":"fc0.x", "0.1":"fc0.y", "0.5":"fc0.z", "1.0":"fc0.w",
            
            wire_sw:"fc1.x", "2.0":"fc1.y", width:"fc1.z", pi_2:"fc1.wwww", 
            light  :"fc2",
            half   :"fc3",
            eye    :"fc4",
            mat    :"fc5",
            
            nv1    :"ft1",
            nv2    :"ft2",
            temp   :"ft3",
            color1 :"ft4",
            bevel  :"ft5",
            color2 :"ft6",
            level  :"ft7",
            half   :"ft8",
            
            norm   :"v0",
            edge   :"v1",
            smooth :"v2",
            vcolor :"v3"
        },
        <![CDATA[
            dp3 color1.w = light, norm
            dp3 color2.w = half, norm
            pow color2.w = color2.w, mat.w
            mul color1.rgb = vcolor.rgb, color1.www
            mul color2.rgb = mat.rgb, color2.www
            
            add color1.rgb = color1.rgb, color2.rgb
            
            mov oc = color1.rgb
        ]]>
    );
    
    public function SimpleFragmentShader()
    {
        assemble(Context3DProgramType.FRAGMENT, src.getSource());
    }
}

class Camera
{
    private var array : Vector.<Number> = new Vector.<Number>(16);
    private var matrix : Matrix3D = new Matrix3D();
    private var proj_matrix : Matrix3D = new Matrix3D();
    private var pos : Vector3D = new Vector3D();
    private var look : Vector3D = new Vector3D();

    private var up  : Vector3D = new Vector3D();
    private var computed_up  : Vector3D = new Vector3D();
    private var backward : Vector3D = new Vector3D();
    private var right : Vector3D = new Vector3D();
    public  var forward : Vector3D = new Vector3D();
    
    public function Camera()
    {
        up.x = 0.0;
        up.y = 1.0;
        up.z = 0.0;
        computed_up.x = 0.0;
        computed_up.y = 0.0;
        computed_up.z = -1.0;
        
        look.x = 0.0;
        look.y = 0.0;
        look.z = 0.0;
        
        pos.x = 0.0;
        pos.y = 0.0;
        pos.z = -1.0;
    }
    
    public function perspective(fov : Number, aspect : Number, near : Number, far : Number) : void
    {
        proj_matrix = MatrixUtil.perspective(fov, aspect, near, far);
    }
    
    public function ortho(width : int, height : int) : void
    {
        proj_matrix = MatrixUtil.ortho(width, height, false);
    }
    
    public function position(pos : Vector3D) : void
    {
        this.pos.x = pos.x;
        this.pos.y = pos.y;
        this.pos.z = pos.z;
    }
    
    public function polarPosition(r : Number, phi : Number, theta : Number) : void
    {
        this.pos.x = r * Math.sin(theta) * Math.sin(phi);
        this.pos.y = r * Math.cos(theta);
        this.pos.z = r * Math.sin(theta) * Math.cos(phi);
        
        right.x = Math.cos(phi);
        right.y = 0;
        right.z = -Math.sin(phi);
        
        this.up.x  = this.pos.y * right.z - this.pos.z * right.y;
        this.up.y  = this.pos.z * right.x - this.pos.x * right.z;
        this.up.z  = this.pos.x * right.y - this.pos.y * right.x;
        this.up.normalize();
    }
    
    public function lookAt(pos : Vector3D) : void
    {
        this.look.x = pos.x;
        this.look.y = pos.y;
        this.look.z = pos.z;
        
    }

    public function upVector(vec : Vector3D) : void
    {
        this.up.x = vec.x;
        this.up.y = vec.y;
        this.up.z = vec.z;
        
        this.up.normalize();
    }
    
    public function dolly(vec : Vector3D) : void
    {
        pos.add(vec);
        look.add(vec);
    }
    
    public function getMatrix(projection : Boolean) : Matrix3D
    {
        // カメラ姿勢の計算は我流なので一般的なものとは,ずれてるかもしれない
        backward.x = pos.x - look.x;
        backward.y = pos.y - look.y;
        backward.z = pos.z - look.z;
        backward.normalize();
        
        forward.x = -backward.x;
        forward.y = -backward.y;
        forward.z = -backward.z;
        
        //*backwardはカメラの後ろ向きのベクター
        
        // 一度大まかなupベクターとbackwardベクターの外積からrightベクターを算出
        right.x = up.y * backward.z - up.z * backward.y;
        right.y = up.z * backward.x - up.x * backward.z;
        right.z = up.x * backward.y - up.y * backward.x;

        if (right.length < 0.000001) { // upとbackwardの向きが近い場合、前回算出したcompted_upベクターでもう一度計算
            right.x = computed_up.y * backward.z - computed_up.z * backward.y;
            right.y = computed_up.z * backward.x - computed_up.x * backward.z;
            right.z = computed_up.x * backward.y - computed_up.y * backward.x;
        } else { // 求めたrightベクターとbackwardベクターからcomputed_upベクターを算出
            computed_up.x = backward.y * right.z - backward.z * right.y;
            computed_up.y = backward.z * right.x - backward.x * right.z;
            computed_up.z = backward.x * right.y - backward.y * right.x;
        }
        
        
        array[ 0] = right.x      ; array[ 4] = right.y      ; array[ 8] = right.z      ; array[12] = -pos.x*right.x       - pos.y*right.y       - pos.z*right.z;
        array[ 1] = computed_up.x; array[ 5] = computed_up.y; array[ 9] = computed_up.z; array[13] = -pos.x*computed_up.x - pos.y*computed_up.y - pos.z*computed_up.z;
        array[ 2] = backward.x   ; array[ 6] = backward.y   ; array[10] = backward.z   ; array[14] = -pos.x*backward.x    - pos.y*backward.y    - pos.z*backward.z;
        array[ 3] = 0            ; array[ 7] = 0            ; array[11] = 0            ; array[15] = 1;
        
        matrix.rawData = array;
        if (projection) matrix.append( proj_matrix );
        return matrix;
    }
}

class MatrixUtil
{
    public static function ortho(w : int, h : int, rev : Boolean) : Matrix3D
    {
        return new Matrix3D(Vector.<Number>([2/w, 0, 0, 0,  0, rev?-2/h:2/h, 0, 0,  0, 0, 1, 0,  -1, -1, 0, 1]));
    }
    
    public static function perspective(fovyInDegrees:Number, aspectRatio:Number, znear:Number, zfar:Number) : Matrix3D
    {
        var ymax:Number
        var xmax:Number;
        ymax = znear * Math.tan(fovyInDegrees * Math.PI / 360.0);
        xmax = ymax * aspectRatio;
        return MatrixUtil.frustum( -xmax, xmax, -ymax, ymax, znear, zfar );
    }
    
    public static function frustum(left:Number, right:Number, bottom:Number, top:Number, znear:Number, zfar:Number) : Matrix3D
    {
        var temp:Number;
        var temp2:Number;
        var temp3:Number;
        var temp4:Number;
        temp = 2.0 * znear;
        temp2 = right - left;
        temp3 = top - bottom;
        temp4 = zfar - znear;
        
        var matrixv:Vector.<Number> = new Vector.<Number>(16);
        matrixv[0] = temp / temp2;
        matrixv[1] = 0.0;
        matrixv[2] = 0.0;
        matrixv[3] = 0.0;
        
        matrixv[4] = 0.0;
        matrixv[5] = temp / temp3;
        matrixv[6] = 0.0;
        matrixv[7] = 0.0;
        
        matrixv[8] = (right + left) / temp2;
        matrixv[9] = (top + bottom) / temp3;
        matrixv[10] = ( -zfar - znear) / temp4;
        matrixv[11] = -1.0;
        
        matrixv[12] = 0.0;
        matrixv[13] = 0.0;
        matrixv[14] = ( -temp * zfar) / temp4;
        matrixv[15] = 0.0;
        return new Matrix3D(matrixv);
    }

}

