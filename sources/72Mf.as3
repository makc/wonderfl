package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.events.*;
    import flash.text.*;
    import flash.ui.*;
    import net.hires.debug.Stats;
    /**
     * OimoPhysics wonderfl test
     * @author saharan
     */
    [SWF(width = "465", height = "465", frameRate = "60")]
    public class WonderflTest extends Sprite {
        private var s3d:Stage3D;
        private var world:World;
        private var renderer:DebugDraw;
        private var rigid:RigidBody;
        private var count:uint;
        private var tf:TextField;
        private var fps:Number;
        private var l:Boolean;
        private var r:Boolean;
        private var u:Boolean;
        private var d:Boolean;
        private var ctr:RigidBody;
        private var type:uint;
        private var demoName:String;
        private var dragX:Number;
        private var dragY:Number;
        private var rotX:Number;
        private var rotY:Number;
        private var pmouseX:Number;
        private var pmouseY:Number;
        private var press:Boolean;
        
        public function WonderflTest() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            contextMenu = new ContextMenu();
            contextMenu.hideBuiltInItems();
            var debug:Stats = new Stats();
            debug.x = 395;
            debug.alpha = 0.6;
            addChild(debug);
            tf = new TextField();
            tf.defaultTextFormat = new TextFormat("_monospace", 11, 0xffffff);
            tf.alpha = 0.8;
            tf.selectable = false;
            tf.x = 0;
            tf.y = 0;
            tf.width = 400;
            tf.height = 400;
            dragX = 0;
            dragY = 100;
            rotX = 0;
            rotY = 0;
            addChild(tf);
            type = 0;
            initWorld();
            fps = 0;
            
            s3d = stage.stage3Ds[0];
            s3d.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);
            s3d.requestContext3D();
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
                press = true;
            });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
                press = false;
            });
            stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
                var code:uint = e.keyCode;
                if (code == Keyboard.W) {
                    u = true;
                }
                if (code == Keyboard.S) {
                    d = true;
                }
                if (code == Keyboard.A) {
                    l = true;
                }
                if (code == Keyboard.D) {
                    r = true;
                }
                if (code == Keyboard.SPACE) {
                    initWorld();
                }
                if (code == Keyboard.NUMBER_1) {
                    type = 0;
                    initWorld();
                }
                if (code == Keyboard.NUMBER_2) {
                    type = 1;
                    initWorld();
                }
                if (code == Keyboard.NUMBER_3) {
                    type = 2;
                    initWorld();
                }
                if (code == Keyboard.NUMBER_4) {
                    type = 3;
                    initWorld();
                }
                if (code == Keyboard.NUMBER_5) {
                    type = 4;
                    initWorld();
                }
                if (code == Keyboard.NUMBER_6) {
                    type = 5;
                    initWorld();
                }
            });
            stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void {
                var code:uint = e.keyCode;
                if (code == Keyboard.W) {
                    u = false;
                }
                if (code == Keyboard.S) {
                    d = false;
                }
                if (code == Keyboard.A) {
                    l = false;
                }
                if (code == Keyboard.D) {
                    r = false;
                }
            });
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function initWorld():void {
            world = new World();
            if (!renderer) renderer = new DebugDraw(466, 466);
            renderer.setWorld(world);
            var rb:RigidBody;
            var s:Shape;
            var c:ShapeConfig = new ShapeConfig();
            rb = new RigidBody();
            c.position.init(0, -0.5, 0);
            c.rotation.init();
            s = new BoxShape(32, 1, 32, c);
            rb.addShape(s);
            rb.setupMass(RigidBody.BODY_STATIC);
            world.addRigidBody(rb);
            
            c.rotation.init();
            var width:uint;
            var height:uint;
            var depth:uint;
            var bw:Number = 0.75;
            var bh:Number = 0.75;
            var bd:Number = 0.75;
            var i:uint;
            var j:uint;
            var k:uint;
            var size:Number;
            switch(type) {
            case 0:
                demoName = "Basic demo";
                width = 6;
                height = 6;
                depth = 6;
                bw = 0.75;
                bh = 0.75;
                bd = 0.75;
                for (i = 0; i < width; i++) {
                    for (j = 0; j < height; j++) {
                        for (k = 0; k < depth; k++) {
                            rb = new RigidBody();
                            c.position.init(
                                (i - (width - 1) * 0.5) * bw,
                                j * bh + bh * 0.5,
                                (k - (depth - 1) * 0.5) * bd
                            );
                            s = new BoxShape(bw, bh, bd, c);
                            rb.addShape(s);
                            rb.setupMass(RigidBody.BODY_DYNAMIC);
                            world.addRigidBody(rb);
                        }
                        Shape.nextID++; // little trick for shape color
                    }
                    Shape.nextID++;
                }
                break;
            case 1:
                demoName = "Tower stack";
                height = 20;
                bw = 0.6;
                bh = 0.75;
                bd = 1.2;
                for (j = 0; j < height; j++) {
                    for (i = 0; i < 10; i++) {
                        var ang:Number = Math.PI * 2 / 10 * (i + (j & 1) * 0.5);
                        rb = new RigidBody(-ang, 0, 1, 0);
                        c.position.init(
                            Math.cos(ang) * 2.5,
                            j * bh + bh * 0.5,
                            Math.sin(ang) * 2.5
                        );
                        s = new BoxShape(bw, bh, bd, c);
                        rb.addShape(s);
                        rb.setupMass(RigidBody.BODY_DYNAMIC);
                        world.addRigidBody(rb);
                    }
                }
                break;
            case 2:
                demoName = "Compound shapes";
                width = 200;
                for (i = 0; i < width; i++) {
                    rb = new RigidBody(Math.PI, Math.random(), Math.random(), Math.random());
                    if (i & 1) {
                        c.position.init(
                            Math.random() * 8 - 4,
                            i * 0.25 + 2,
                            Math.random() * 8 - 4
                        );
                        size = 0.25 + Math.random() * 0.4;
                        s = new SphereShape(size, c);
                        rb.addShape(s);
                        c.position.x += size + (size = 0.25 + Math.random() * 0.4);
                        s = new SphereShape(size, c);
                        rb.addShape(s);
                    } else {
                        c.position.init(
                            Math.random() * 8 - 4,
                            i * 0.25 + 2,
                            Math.random() * 8 - 4
                        );
                        size = 0.7 + Math.random() * 0.3;
                        s = new BoxShape((0.8  + Math.random() * 0.4) * size, 0.5 * size, (0.8 + Math.random() * 0.4) * size, c);
                        rb.addShape(s);
                        c.position.y -= size;
                        s = new BoxShape(0.5 * size, 1.5 * size, 0.5 * size, c);
                        rb.addShape(s);
                    }
                    rb.setupMass(RigidBody.BODY_DYNAMIC);
                    world.addRigidBody(rb);
                }
                break;
            case 3:
                demoName = "Pyramid";
                width = 20;
                bw = 0.8;
                bh = 0.5;
                bd = 0.7;
                for (i = 0; i < width; i++) {
                    for (j = i; j < width; j++) {
                        rb = new RigidBody();
                        c.position.init(
                            (j - i * 0.5 - (width - 1) * 0.5) * bw * 1.1,
                            i * bh * 1.1 + bh * 0.5,
                            0
                        );
                        s = new BoxShape(bw, bh, bd, c);
                        rb.addShape(s);
                        rb.setupMass(RigidBody.BODY_DYNAMIC);
                        world.addRigidBody(rb);
                    }
                }
                break;
            case 4:
                demoName = "Spining tops";
                width = 6;
                depth = 4;
                for (i = 0; i < width; i++) {
                    for (j = 0; j < depth; j++) {
                        rb = new RigidBody(0.2, 1, 0, 0);
                        size = 0.5 + Math.random() * 0.25;
                        c.position.init(
                            (i - (width - 1) * 0.5) * 4,
                            0.2 * size,
                            (j - (depth - 1) * 0.5) * 4 - 3
                        );
                        c.density = 32; // move down center of gravity
                        s = new SphereShape(0.2 * size, c);
                        rb.addShape(s);
                        c.position.y += 0.75 * size;
                        c.density = 0.5;
                        s = new SphereShape(size, c);
                        rb.addShape(s);
                        c.position.y += 1.2 * size;
                        s = new BoxShape(0.4 * size, 0.4 * size, 0.4 * size, c);
                        rb.addShape(s);
                        c.position.y += 0.45 * size;
                        s = new SphereShape(0.25 * size, c);
                        rb.addShape(s);
                        rb.setupMass(RigidBody.BODY_DYNAMIC);
                        rb.angularVelocity.y = Math.PI * 2 * (15 + Math.random() * 4 - 2); // 900(+-120) rpm
                        world.addRigidBody(rb);
                        Shape.nextID++;
                    }
                    Shape.nextID++;
                }
                c.density = 1;
                break;
            case 5:
                demoName = "Dominoes";
                bw = 0.7;
                bh = 1.5;
                bd = 0.3;
                ang = 0;
                for (i = 0; i < 200; i++) {
                    var rad:Number = 0.5 + ang * 0.25;
                    ang += 5 / (Math.PI * rad * 2);
                    rb = new RigidBody(-ang, 0, 1, 0);
                    c.position.init(
                        Math.cos(ang) * rad,
                        bh * 0.5,
                        Math.sin(ang) * rad - 3
                    );
                    s = new BoxShape(bw, bh, bd, c);
                    rb.addShape(s);
                    rb.setupMass(RigidBody.BODY_DYNAMIC);
                    world.addRigidBody(rb);
                }
                rb.angularVelocity.x = Math.cos(ang) * -3;
                rb.angularVelocity.z = Math.sin(ang) * -3;
                rb.linearVelocity.x = Math.sin(ang);
                rb.linearVelocity.z = -Math.cos(ang);
                break;
            }
            c.friction = 2;
            c.position.init(0, 1, 10);
            c.density = 10;
            c.rotation.init();
            s = new SphereShape(1, c);
            ctr = new RigidBody();
            ctr.addShape(s);
            ctr.setupMass(RigidBody.BODY_DYNAMIC);
            world.addRigidBody(ctr);
        }
        
        private function onContext3DCreated(e:Event = null):void {
            renderer.setContext3D(s3d.context3D);
            renderer.camera(0, 2, 4);
        }
        
        private function frame(e:Event = null):void {
            count++;
            if (press) {
                dragX += mouseX - pmouseX;
                dragY -= mouseY - pmouseY;
            }
            if (dragY < 0) dragY = 0;
            if (dragY > 512) dragY = 512;
            rotX += (dragX - rotX) * 0.25;
            rotY += (dragY - rotY) * 0.25;
            pmouseX = mouseX;
            pmouseY = mouseY;
            var ang:Number = rotX * 0.01 + Math.PI * 0.5;
            var sin:Number = Math.sin(ang);
            var cos:Number = Math.cos(ang);
            renderer.camera(
                ctr.position.x + cos * 8,
                ctr.position.y + rotY * 0.1,
                ctr.position.z + sin * 8,
                ctr.position.x - cos * rotY * 0.025,
                ctr.position.y,
                ctr.position.z - sin * rotY * 0.025
            );
            if (l) {
                ctr.linearVelocity.x -= Math.cos(ang - Math.PI * 0.5) * 0.8;
                ctr.linearVelocity.z -= Math.sin(ang - Math.PI * 0.5) * 0.8;
            }
            if (r) {
                ctr.linearVelocity.x -= Math.cos(ang + Math.PI * 0.5) * 0.8;
                ctr.linearVelocity.z -= Math.sin(ang + Math.PI * 0.5) * 0.8;
            }
            if (u) {
                ctr.linearVelocity.x -= cos * 0.8;
                ctr.linearVelocity.z -= sin * 0.8;
            }
            if (d) {
                ctr.linearVelocity.x += cos * 0.8;
                ctr.linearVelocity.z += sin * 0.8;
            }
            world.step();
            fps += (1000 / world.performance.totalTime - fps) * 0.5;
            if (fps > 1000 || fps != fps) {
                fps = 1000;
            }
            tf.text =
                demoName + "\n\n" +
                "Rigid Body Count: " + world.numRigidBodies + "\n" +
                "Shape Count: " + world.numShapes + "\n" +
                "Contacts Count: " + world.numContacts + "\n\n" +
                "Broad Phase Time: " + world.performance.broadPhaseTime + "ms\n" +
                "Narrow Phase Time: " + world.performance.narrowPhaseTime + "ms\n" +
                "Constraints Time: " + world.performance.constraintsTime + "ms\n" +
                "Update Time: " + world.performance.updateTime + "ms\n" +
                "Total Time: " + world.performance.totalTime + "ms\n" +
                "Physics FPS: " + fps.toFixed(2) + "\n"
            ;
            tf.setTextFormat(new TextFormat("_monospace", 16, 0xffffff), 0, demoName.length);
            renderer.render();
            var len:uint = world.numRigidBodies;
            var rbs:Vector.<RigidBody> = world.rigidBodies;
            for (var i:int = 0; i < len; i++) {
                var r:RigidBody = rbs[i];
                if (r.position.y < -12) {
                    r.position.init(Math.random() * 8 - 4, Math.random() * 4 + 8, Math.random() * 8 - 4);
                    r.linearVelocity.x *= 0.8;
                    r.linearVelocity.z *= 0.8;
                }
            }
        }
    }
}

/* Copyright (c) 2012 EL-EMENT saharan
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation  * files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy,  * modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to
 * whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.*;
import flash.utils.*;

class OimoGLMini {
    private static const VERTEX_POISITION_INDEX:uint = 0;
    private static const VERTEX_NORMAL_INDEX:uint = 1;
    private static const FRAGMENT_COLOR_INDEX:uint = 0;
    private static const FRAGMENT_AMB_DIF_EMI_INDEX:uint = 1;
    private static const FRAGMENT_SPC_SHN_INDEX:uint = 2;
    private static const FRAGMENT_AMB_LIGHT_COLOR_INDEX:uint = 3;
    private static const FRAGMENT_DIR_LIGHT_COLOR_INDEX:uint = 4;
    private static const FRAGMENT_DIR_LIGHT_DIRECTION_INDEX:uint = 5;
    private static const FRAGMENT_CAMERA_POSITION_INDEX:uint = 6;
    private var c3d:Context3D;
    private var w:uint;
    private var h:uint;
    private var aspect:Number;
    private var worldM:Mat44;
    private var viewM:Mat44;
    private var projM:Mat44;
    private var viewProjM:Mat44;
    private var up:Vector.<Number>;
    private var stackM:Vector.<Mat44>;
    private var numStack:uint;
    private var vertexB:Vector.<VertexBuffer3D>;
    private var numVerticesB:Vector.<uint>;
    private var indexB:Vector.<IndexBuffer3D>;
    private var numIndicesB:Vector.<uint>;
    public function OimoGLMini(c3d:Context3D, w:uint, h:uint, antiAlias:uint = 0) {
        this.c3d = c3d;
        c3d.configureBackBuffer(w, h, antiAlias, true);
        c3d.setBlendFactors("sourceAlpha", "oneMinusSourceAlpha");
        c3d.setCulling("front"); // ClockWise
        this.w = w;
        this.h = h;
        aspect = w / h;
        worldM = new Mat44();
        viewM = new Mat44();
        projM = new Mat44();
        viewProjM = new Mat44();
        up = new Vector.<Number>(4, true);
        stackM = new Vector.<Mat44>(256, true);
        vertexB = new Vector.<VertexBuffer3D>(256, true);
        numVerticesB = new Vector.<uint>(256, true);
        indexB = new Vector.<IndexBuffer3D>(256, true);
        numIndicesB = new Vector.<uint>(256, true);
        numStack = 0;
        var program:Program3D = c3d.createProgram();
        var vs:AGALMiniAssembler = new AGALMiniAssembler();
        vs.assemble("vertex", createBasicVertexShaderCode(VERTEX_POISITION_INDEX, VERTEX_NORMAL_INDEX));
        var fs:AGALMiniAssembler = new AGALMiniAssembler();
        fs.assemble("fragment",
            createBasicFragmentShaderCode(
                VERTEX_POISITION_INDEX, VERTEX_NORMAL_INDEX,
                FRAGMENT_COLOR_INDEX, FRAGMENT_AMB_DIF_EMI_INDEX, FRAGMENT_SPC_SHN_INDEX,
                FRAGMENT_AMB_LIGHT_COLOR_INDEX, FRAGMENT_DIR_LIGHT_COLOR_INDEX, FRAGMENT_DIR_LIGHT_DIRECTION_INDEX,
                FRAGMENT_CAMERA_POSITION_INDEX
            )
        );
        program.upload(vs.agalcode, fs.agalcode);
        c3d.setProgram(program);
        material(1, 1, 0, 0, 0);
        color(1, 1, 1);
        ambientLightColor(0.2, 0.2, 0.2);
        directionalLightColor(0.8, 0.8, 0.8);
        directionalLightDirection(0, 0, -1);
        camera(0, 0, 100, 0, 0, 0, 0, 1, 0);
        perspective(Math.PI / 3);
    }
    public function material(
        ambient:Number, diffuse:Number, emission:Number,
        specular:Number, shininess:Number
    ):void {
        setProgramConstantsNumber("fragment", FRAGMENT_AMB_DIF_EMI_INDEX, ambient, diffuse, emission, 1);
        setProgramConstantsNumber("fragment", FRAGMENT_SPC_SHN_INDEX, specular, shininess, 0, 1);
    }
    public function color(r:Number, g:Number, b:Number, a:Number = 1):void {
        setProgramConstantsNumber("fragment", FRAGMENT_COLOR_INDEX, r, g, b, a);
    }
    public function ambientLightColor(r:Number, g:Number, b:Number):void {
        setProgramConstantsNumber("fragment", FRAGMENT_AMB_LIGHT_COLOR_INDEX, r, g, b, 1);
    }
    public function directionalLightColor(r:Number, g:Number, b:Number):void {
        setProgramConstantsNumber("fragment", FRAGMENT_DIR_LIGHT_COLOR_INDEX, r, g, b, 1);
    }
    public function directionalLightDirection(x:Number, y:Number, z:Number):void {
        setProgramConstantsNumber("fragment", FRAGMENT_DIR_LIGHT_DIRECTION_INDEX, x, y, z, 1);
    }
    public function camera(
        eyeX:Number, eyeY:Number, eyeZ:Number,
        atX:Number, atY:Number, atZ:Number,
        upX:Number, upY:Number, upZ:Number
    ):void {
        setProgramConstantsNumber("fragment", FRAGMENT_CAMERA_POSITION_INDEX, eyeX, eyeY, eyeZ, 1);
        viewM.lookAt(eyeX, eyeY, eyeZ, atX, atY, atZ, upX, upY, upZ);
    }
    public function perspective(fovY:Number, near:Number = 0.5, far:Number = 10000):void {
        projM.perspective(fovY, aspect, near, far);
    }
    public function beginScene(r:Number, g:Number, b:Number):void {
        worldM.init();
        c3d.clear(r, g, b);
    }
    public function endScene():void {
        c3d.present();
    }
    public function registerBox(bufferIndex:uint, width:Number, height:Number, depth:Number):void {
        width *= 0.5;
        height *= 0.5;
        depth *= 0.5;
        registerBuffer(bufferIndex, 24, 36);
        uploadVertexBuffer(bufferIndex, Vector.<Number>([
            -width, height, -depth, // top face
            -width, height, depth,
            width, height, depth,
            width, height, -depth,
            -width, -height, -depth, // bottom face
            width, -height, -depth,
            width, -height, depth,
            -width, -height, depth,
            -width, height, -depth, // left face
            -width, -height, -depth,
            -width, -height, depth,
            -width, height, depth,
            width, height, -depth, // right face
            width, height, depth,
            width, -height, depth,
            width, -height, -depth,
            -width, height, depth, // front face
            -width, -height, depth,
            width, -height, depth,
            width, height, depth,
            -width, height, -depth, // back face
            width, height, -depth,
            width, -height, -depth,
            -width, -height, -depth
        ]), Vector.<Number>([
            0, 1, 0, // top face
            0, 1, 0,
            0, 1, 0,
            0, 1, 0,
            0, -1, 0, // bottom face
            0, -1, 0,
            0, -1, 0,
            0, -1, 0,
            -1, 0, 0, // left face
            -1, 0, 0,
            -1, 0, 0,
            -1, 0, 0,
            1, 0, 0, // right face
            1, 0, 0,
            1, 0, 0,
            1, 0, 0,
            0, 0, 1, // front face
            0, 0, 1,
            0, 0, 1,
            0, 0, 1,
            0, 0, -1, // back face
            0, 0, -1,
            0, 0, -1,
            0, 0, -1
        ]));
        uploadIndexBuffer(bufferIndex, Vector.<uint>([
            0, 1, 2, // top face
            0, 2, 3,
            4, 5, 6, // bottom face
            4, 6, 7,
            8, 9, 10, // left face
            8, 10, 11,
            12, 13, 14, // right face
            12, 14, 15,
            16, 17, 18, // front face
            16, 18, 19,
            20, 21, 22, // back face
            20, 22, 23
        ]));
    }
    public function registerSphere(bufferIndex:uint, radius:Number, divisionH:uint, divisionV:uint):void {
        var count:uint = 0;
        var theta:Number;
        var phi:Number;
        var dTheta:Number = Math.PI * 2 / divisionH;
        var dPhi:Number = Math.PI / divisionV;
        var numVertices:uint = (divisionV + 1) * divisionH - ((divisionH - 1) << 1);
        var numFaces:uint = (divisionV - 1 << 1) * divisionH;
        var vtx:Vector.<Number> = new Vector.<Number>(numVertices * 3, true);
        var nrm:Vector.<Number> = new Vector.<Number>(numVertices * 3, true);
        vtx[count] = 0;
        vtx[count + 1] = radius;
        vtx[count + 2] = 0;
        nrm[count] = 0;
        nrm[count + 1] = 1;
        nrm[count + 2] = 0;
        count += 3;
        phi = dPhi;
        for (var i:int = 1; i < divisionV; i++) {
            theta = 0;
            for (var j:int = 0; j < divisionH; j++) {
                var sp:Number = Math.sin(phi);
                var cp:Number = Math.cos(phi);
                var st:Number = Math.sin(theta);
                var ct:Number = Math.cos(theta);
                vtx[count] = radius * sp * ct;
                vtx[count + 1] = radius * cp;
                vtx[count + 2] = radius * sp * st;
                nrm[count] = sp * ct;
                nrm[count + 1] = cp;
                nrm[count + 2] = sp * st;
                count += 3;
                theta += dTheta;
            }
            phi += dPhi;
        }
        vtx[count] = 0;
        vtx[count + 1] = -radius;
        vtx[count + 2] = 0;
        nrm[count] = 0;
        nrm[count + 1] = -1;
        nrm[count + 2] = 0;
        var idx:Vector.<uint> = new Vector.<uint>(numFaces * 3, true);
        count = 0;
        for (i = 0; i < divisionV; i++) {
            for (j = 0; j < divisionH; j++) {
                if (i == 0) {
                    idx[count] = 0;
                    idx[count + 1] = (j + 1) % divisionH + 1;
                    idx[count + 2] = j + 1;
                    count += 3;
                } else if (i == divisionV - 1) {
                    idx[count] = numVertices - 1;
                    idx[count + 1] = (i - 1) * divisionH + j + 1;
                    idx[count + 2] = (i - 1) * divisionH + (j + 1) % divisionH + 1;
                    count += 3;
                } else {
                    idx[count] = (i - 1) * divisionH + j + 1;
                    idx[count + 1] = (i - 1) * divisionH + (j + 1) % divisionH + 1;
                    idx[count + 2] = i * divisionH + (j + 1) % divisionH + 1;
                    count += 3;
                    idx[count] = (i - 1) * divisionH + j + 1;
                    idx[count + 1] = i * divisionH + (j + 1) % divisionH + 1;
                    idx[count + 2] = i * divisionH + j + 1;
                    count += 3;
                }
            }
        }
        registerBuffer(bufferIndex, numVertices, numFaces * 3);
        uploadVertexBuffer(bufferIndex, vtx, nrm);
        uploadIndexBuffer(bufferIndex, idx);
    }
    public function registerBuffer(bufferIndex:uint, numVertices:uint, numIndices:uint):void {
        if (vertexB[bufferIndex]) {
            vertexB[bufferIndex].dispose();
            indexB[bufferIndex].dispose();
        }
        vertexB[bufferIndex] = c3d.createVertexBuffer(numVertices, 6);
        numVerticesB[bufferIndex] = numVertices;
        indexB[bufferIndex] = c3d.createIndexBuffer(numIndices);
        numIndicesB[bufferIndex] = numIndices;
    }
    public function uploadVertexBuffer(bufferIndex:uint, vertices:Vector.<Number>, normals:Vector.<Number>):void {
        var numVertices:uint = numVerticesB[bufferIndex];
        var arrayCount:uint = numVertices * 3;
        var upload:Vector.<Number> = new Vector.<Number>(arrayCount << 1, true);
        var num:uint = 0;
        for (var i:int = 0; i < arrayCount; i += 3) {
            upload[num++] = vertices[i];
            upload[num++] = vertices[i + 1];
            upload[num++] = vertices[i + 2];
            upload[num++] = normals[i];
            upload[num++] = normals[i + 1];
            upload[num++] = normals[i + 2];
        }
        vertexB[bufferIndex].uploadFromVector(upload, 0, numVertices);
    }
    public function uploadIndexBuffer(bufferIndex:uint, indices:Vector.<uint>):void {
        indexB[bufferIndex].uploadFromVector(indices, 0, numIndicesB[bufferIndex]);
    }
    public function drawTriangles(bufferIndex:uint):void {
        c3d.setVertexBufferAt(0, vertexB[bufferIndex], 0, "float3");
        c3d.setVertexBufferAt(1, vertexB[bufferIndex], 3, "float3");
        setProgramConstantsMatrix("vertex", 0, worldM);
        viewProjM.mul(projM, viewM);
        setProgramConstantsMatrix("vertex", 4, viewProjM);
        c3d.drawTriangles(indexB[bufferIndex]);
    }
    public function translate(tx:Number, ty:Number, tz:Number):void {
        worldM.mulTranslate(worldM, tx, ty, tz);
    }
    public function scale(sx:Number, sy:Number, sz:Number):void {
        worldM.mulScale(worldM, sx, sy, sz);
    }
    public function rotate(rad:Number, ax:Number, ay:Number, az:Number):void {
        worldM.mulRotate(worldM, rad, ax, ay, az);
    }
    public function transform(m:Mat44):void {
        worldM.mul(worldM, m);
    }
    public function push():void {
        if (numStack < 256) {
            if (!stackM[numStack]) stackM[numStack] = new Mat44();
            stackM[numStack++].copy(worldM);
        } else {
            throw new Error("too many stacks.");
        }
    }
    public function pop():void {
        if (numStack > 0) {
            worldM.copy(stackM[--numStack]);
        } else {
            throw new Error("there is no stack.");
        }
    }
    public function loadWorldMatrix(m:Mat44):void {
        worldM.copy(m);
    }
    public function loadViewMatrix(m:Mat44):void {
        viewM.copy(m);
    }
    public function loadProjectionMatrix(m:Mat44):void {
        projM.copy(m);
    }
    public function getWorldMatrix(m:Mat44):void {
        m.copy(worldM);
    }
    public function getViewMatrix(m:Mat44):void {
        m.copy(viewM);
    }
    public function getProjectionMatrix(m:Mat44):void {
        m.copy(projM);
    }
    private function setProgramConstantsMatrix(type:String, index:uint, m:Mat44):void {
        up[0] = m.e00; up[1] = m.e01; up[2] = m.e02; up[3] = m.e03;
        c3d.setProgramConstantsFromVector(type, index, up);
        up[0] = m.e10; up[1] = m.e11; up[2] = m.e12; up[3] = m.e13;
        c3d.setProgramConstantsFromVector(type, index + 1, up);
        up[0] = m.e20; up[1] = m.e21; up[2] = m.e22; up[3] = m.e23;
        c3d.setProgramConstantsFromVector(type, index + 2, up);
        up[0] = m.e30; up[1] = m.e31; up[2] = m.e32; up[3] = m.e33;
        c3d.setProgramConstantsFromVector(type, index + 3, up);
    }
    private function setProgramConstantsNumber(type:String, index:uint, x:Number, y:Number, z:Number, w:Number):void {
        up[0] = x; up[1] = y; up[2] = z; up[3] = w;
        c3d.setProgramConstantsFromVector(type, index, up);
    }
    private function createBasicVertexShaderCode(vertexPositionIndex:uint, vertexNormalIndex:uint):String {
        var pos:String = "v" + vertexPositionIndex;
        var nor:String = "v" + vertexNormalIndex;
        var code:String =
            "m44 vt0, va0, vc0; \n" +
            "mov " + pos + ", vt0; \n" +
            "m44 op, vt0, vc4; \n" +
            "m33 vt0.xyz, va1, vc0; \n" +
            "nrm vt0.xyz, vt0.xyz; \n" +
            "mov " + nor + " vt0; \n"
        ;
        return code;
    }
    private function createBasicFragmentShaderCode(
        vertexPositionIndex:uint, vertexNormalIndex:uint,
        programColorIndex:uint, programAmbDifEmiIndex:uint, programSpcShnIndex:uint,
        programAmbLightColorIndex:uint, programDirLightColorIndex:uint, programDirLightDirectionIndex:uint,
        programCameraPosIndex:uint
    ):String {
        var pos:String = "v" + vertexPositionIndex;
        var nor:String = "v" + vertexNormalIndex;
        var col:String = "fc" + programColorIndex;
        var mat:String = "fc" + programAmbDifEmiIndex;
        var spc:String = "fc" + programSpcShnIndex;
        var alc:String = "fc" + programAmbLightColorIndex;
        var dlc:String = "fc" + programDirLightColorIndex;
        var dld:String = "fc" + programDirLightDirectionIndex;
        var cam:String = "fc" + programCameraPosIndex;
        var code:String =
            "nrm ft1.xyz, " + nor + ".xyz \n" +            // ft1 = normal
            "mov ft2, " + col + " \n" +                    // ft2 = col
            "mul ft0, ft2, " + alc + " \n" +            // ft0 = ambColor
            "mul ft0, ft0.xyz, " + mat + ".xxx \n" +    // ft0 = ft0 * ambFactor
            "mul ft3, ft2.xyz, " + mat + ".zzz \n" +    // ft3 = col * emiFactor
            "add ft0, ft0, ft3 \n" +                    // ft0 = ft0 + ft3
            "mul ft3, ft2, " + dlc + " \n" +            // ft3 = dirColor
            "mul ft3, ft3.xyz, " + mat + ".yyy \n" +    // ft3 = ft2 * dirFactor
            "mov ft4, " + dld + " \n" +                    // ft4 = lightDir
            "neg ft4, ft4 \n" +                            // ft4 = -ft4
            "nrm ft4.xyz, ft4.xyz \n" +                    // ft4 = nrm(ft4)
            "dp3 ft0.w, ft1.xyz, ft4.xyz \n" +            // dot = normal * lightDir
            "sat ft0.w, ft0.w \n" +                        // dot = sat(dot)
            "mul ft3, ft3.xyz, ft0.www \n" +            // ft3 = ft3 * dot
            "add ft0, ft0, ft3 \n" +                    // ft0 = ft0 + ft3
            "mul ft3, ft1.xyz, ft0.www \n" +            // ft3 = normal * dot
            "add ft3, ft3, ft3 \n" +                    // ft3 = ft3 * 2
            "sub ft3, ft3, ft4 \n" +                    // ft3 = ft3 - lightDir
            "nrm ft3.xyz, ft3.xyz \n" +                    // ft3 = nrm(ft3)
            "mov ft5, " + cam + " \n" +                    // ft5 = cam
            "sub ft5, ft5, " + pos + " \n" +            // ft5 = ft5 - pos
            "nrm ft5.xyz, ft5.xyz \n" +                    // ft5 = nrm(ft5)
            "dp3 ft3.w, ft3.xyz, ft5.xyz \n" +            // ref = ft3 * ft5
            "sat ft3.w, ft3.w \n" +                        // ref = sat(ref)
            "pow ft3.w, ft3.w, " + spc + ".yyy \n" +    // ref = ref ^ shn
            "mul ft3, ft3.www, " + dlc + ".xyz \n" +    // rfc = ref * dirColor
            "mul ft3, ft3, " + spc + ".xxx \n" +        // rfc = rfc * spc
            "sub ft3.w, ft3.w, ft3.w \n" +                // zer = zer - zer
            "slt ft3.w, ft3.w, ft0.w \n" +                // zer = zer < dot ? 1 : 0
            "mul ft3, ft3, ft3.www \n" +                // rfc = rfc * zer
            "add ft0, ft0, ft3 \n" +                    // ft0 = ft0 + rfc
            "mov ft0.w, ft2.w \n" +                        // ft0 = alp
            "mov oc, ft0 \n"                            // col = ft0
        ;
        return code;
    }
}
class Mat33 {
    public var e00:Number;
    public var e01:Number;
    public var e02:Number;
    public var e10:Number;
    public var e11:Number;
    public var e12:Number;
    public var e20:Number;
    public var e21:Number;
    public var e22:Number;
    public function Mat33(
        e00:Number = 1, e01:Number = 0, e02:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1
    ) {
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
    }
    public function init(
        e00:Number = 1, e01:Number = 0, e02:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1
    ):Mat33 {
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        return this;
    }
    public function add(m1:Mat33, m2:Mat33):Mat33 {
        e00 = m1.e00 + m2.e00;
        e01 = m1.e01 + m2.e01;
        e02 = m1.e02 + m2.e02;
        e10 = m1.e10 + m2.e10;
        e11 = m1.e11 + m2.e11;
        e12 = m1.e12 + m2.e12;
        e20 = m1.e20 + m2.e20;
        e21 = m1.e21 + m2.e21;
        e22 = m1.e22 + m2.e22;
        return this;
    }
    public function sub(m1:Mat33, m2:Mat33):Mat33 {
        e00 = m1.e00 - m2.e00;
        e01 = m1.e01 - m2.e01;
        e02 = m1.e02 - m2.e02;
        e10 = m1.e10 - m2.e10;
        e11 = m1.e11 - m2.e11;
        e12 = m1.e12 - m2.e12;
        e20 = m1.e20 - m2.e20;
        e21 = m1.e21 - m2.e21;
        e22 = m1.e22 - m2.e22;
        return this;
    }
    public function scale(m:Mat33, s:Number):Mat33 {
        e00 = m.e00 * s;
        e01 = m.e01 * s;
        e02 = m.e02 * s;
        e10 = m.e10 * s;
        e11 = m.e11 * s;
        e12 = m.e12 * s;
        e20 = m.e20 * s;
        e21 = m.e21 * s;
        e22 = m.e22 * s;
        return this;
    }
    public function mul(m1:Mat33, m2:Mat33):Mat33 {
        var e00:Number = m1.e00 * m2.e00 + m1.e01 * m2.e10 + m1.e02 * m2.e20;
        var e01:Number = m1.e00 * m2.e01 + m1.e01 * m2.e11 + m1.e02 * m2.e21;
        var e02:Number = m1.e00 * m2.e02 + m1.e01 * m2.e12 + m1.e02 * m2.e22;
        var e10:Number = m1.e10 * m2.e00 + m1.e11 * m2.e10 + m1.e12 * m2.e20;
        var e11:Number = m1.e10 * m2.e01 + m1.e11 * m2.e11 + m1.e12 * m2.e21;
        var e12:Number = m1.e10 * m2.e02 + m1.e11 * m2.e12 + m1.e12 * m2.e22;
        var e20:Number = m1.e20 * m2.e00 + m1.e21 * m2.e10 + m1.e22 * m2.e20;
        var e21:Number = m1.e20 * m2.e01 + m1.e21 * m2.e11 + m1.e22 * m2.e21;
        var e22:Number = m1.e20 * m2.e02 + m1.e21 * m2.e12 + m1.e22 * m2.e22;
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        return this;
    }
    public function mulScale(m:Mat33, sx:Number, sy:Number, sz:Number, prepend:Boolean = false):Mat33 {
        var e00:Number;
        var e01:Number;
        var e02:Number;
        var e10:Number;
        var e11:Number;
        var e12:Number;
        var e20:Number;
        var e21:Number;
        var e22:Number;
        if (prepend) {
            e00 = sx * m.e00;
            e01 = sx * m.e01;
            e02 = sx * m.e02;
            e10 = sy * m.e10;
            e11 = sy * m.e11;
            e12 = sy * m.e12;
            e20 = sz * m.e20;
            e21 = sz * m.e21;
            e22 = sz * m.e22;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
        } else {
            e00 = m.e00 * sx;
            e01 = m.e01 * sy;
            e02 = m.e02 * sz;
            e10 = m.e10 * sx;
            e11 = m.e11 * sy;
            e12 = m.e12 * sz;
            e20 = m.e20 * sx;
            e21 = m.e21 * sy;
            e22 = m.e22 * sz;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
        }
        return this;
    }
    public function mulRotate(m:Mat33, rad:Number, ax:Number, ay:Number, az:Number, prepend:Boolean = false):Mat33 {
        var s:Number = Math.sin(rad);
        var c:Number = Math.cos(rad);
        var c1:Number = 1 - c;
        var r00:Number = ax * ax * c1 + c;
        var r01:Number = ax * ay * c1 - az * s;
        var r02:Number = ax * az * c1 + ay * s;
        var r10:Number = ay * ax * c1 + az * s;
        var r11:Number = ay * ay * c1 + c;
        var r12:Number = ay * az * c1 - ax * s;
        var r20:Number = az * ax * c1 - ay * s;
        var r21:Number = az * ay * c1 + ax * s;
        var r22:Number = az * az * c1 + c;
        var e00:Number;
        var e01:Number;
        var e02:Number;
        var e10:Number;
        var e11:Number;
        var e12:Number;
        var e20:Number;
        var e21:Number;
        var e22:Number;
        if (prepend) {
            e00 = r00 * m.e00 + r01 * m.e10 + r02 * m.e20;
            e01 = r00 * m.e01 + r01 * m.e11 + r02 * m.e21;
            e02 = r00 * m.e02 + r01 * m.e12 + r02 * m.e22;
            e10 = r10 * m.e00 + r11 * m.e10 + r12 * m.e20;
            e11 = r10 * m.e01 + r11 * m.e11 + r12 * m.e21;
            e12 = r10 * m.e02 + r11 * m.e12 + r12 * m.e22;
            e20 = r20 * m.e00 + r21 * m.e10 + r22 * m.e20;
            e21 = r20 * m.e01 + r21 * m.e11 + r22 * m.e21;
            e22 = r20 * m.e02 + r21 * m.e12 + r22 * m.e22;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
        } else {
            e00 = m.e00 * r00 + m.e01 * r10 + m.e02 * r20;
            e01 = m.e00 * r01 + m.e01 * r11 + m.e02 * r21;
            e02 = m.e00 * r02 + m.e01 * r12 + m.e02 * r22;
            e10 = m.e10 * r00 + m.e11 * r10 + m.e12 * r20;
            e11 = m.e10 * r01 + m.e11 * r11 + m.e12 * r21;
            e12 = m.e10 * r02 + m.e11 * r12 + m.e12 * r22;
            e20 = m.e20 * r00 + m.e21 * r10 + m.e22 * r20;
            e21 = m.e20 * r01 + m.e21 * r11 + m.e22 * r21;
            e22 = m.e20 * r02 + m.e21 * r12 + m.e22 * r22;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
        }
        return this;
    }
    public function transpose(m:Mat33):Mat33 {
        var e01:Number = m.e10;
        var e02:Number = m.e20;
        var e10:Number = m.e01;
        var e12:Number = m.e21;
        var e20:Number = m.e02;
        var e21:Number = m.e12;
        e00 = m.e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e10 = e10;
        e11 = m.e11;
        this.e12 = e12;
        this.e20 = e20;
        this.e21 = e21;
        e22 = m.e22;
        return this;
    }
    public function setQuat(q:Quat):Mat33 {
        var x2:Number = 2 * q.x;
        var y2:Number = 2 * q.y;
        var z2:Number = 2 * q.z;
        var xx:Number = q.x * x2;
        var yy:Number = q.y * y2;
        var zz:Number = q.z * z2;
        var xy:Number = q.x * y2;
        var yz:Number = q.y * z2;
        var xz:Number = q.x * z2;
        var sx:Number = q.s * x2;
        var sy:Number = q.s * y2;
        var sz:Number = q.s * z2;
        e00 = 1 - yy - zz;
        e01 = xy - sz;
        e02 = xz + sy;
        e10 = xy + sz;
        e11 = 1 - xx - zz;
        e12 = yz - sx;
        e20 = xz - sy;
        e21 = yz + sx;
        e22 = 1 - xx - yy;
        return this;
    }
    public function invert(m:Mat33):Mat33 {
        var det:Number =
            m.e00 * (m.e11 * m.e22 - m.e21 * m.e12) +
            m.e10 * (m.e21 * m.e02 - m.e01 * m.e22) +
            m.e20 * (m.e01 * m.e12 - m.e11 * m.e02)
        ;
        if (det != 0) det = 1 / det;
        var t00:Number = m.e11 * m.e22 - m.e12 * m.e21;
        var t01:Number = m.e02 * m.e21 - m.e01 * m.e22;
        var t02:Number = m.e01 * m.e12 - m.e02 * m.e11;
        var t10:Number = m.e12 * m.e20 - m.e10 * m.e22;
        var t11:Number = m.e00 * m.e22 - m.e02 * m.e20;
        var t12:Number = m.e02 * m.e10 - m.e00 * m.e12;
        var t20:Number = m.e10 * m.e21 - m.e11 * m.e20;
        var t21:Number = m.e01 * m.e20 - m.e00 * m.e21;
        var t22:Number = m.e00 * m.e11 - m.e01 * m.e10;
        e00 = det * t00;
        e01 = det * t01;
        e02 = det * t02;
        e10 = det * t10;
        e11 = det * t11; 
        e12 = det * t12;
        e20 = det * t20;
        e21 = det * t21;
        e22 = det * t22;
        return this;
    }
    public function copy(m:Mat33):Mat33 {
        e00 = m.e00;
        e01 = m.e01;
        e02 = m.e02;
        e10 = m.e10;
        e11 = m.e11;
        e12 = m.e12;
        e20 = m.e20;
        e21 = m.e21;
        e22 = m.e22;
        return this;
    }
    public function copyMat44(m:Mat44):Mat33 {
        e00 = m.e00;
        e01 = m.e01;
        e02 = m.e02;
        e10 = m.e10;
        e11 = m.e11;
        e12 = m.e12;
        e20 = m.e20;
        e21 = m.e21;
        e22 = m.e22;
        return this;
    }
    public function clone():Mat33 {
        return new Mat33(e00, e01, e02, e10, e11, e12, e20, e21, e22);
    }
    public function toString():String {
        var text:String =
            "Mat33|" + e00.toFixed(4) + ", " + e01.toFixed(4) + ", " + e02.toFixed(4) + "|\n" +
            "     |" + e10.toFixed(4) + ", " + e11.toFixed(4) + ", " + e12.toFixed(4) + "|\n" +
            "     |" + e20.toFixed(4) + ", " + e21.toFixed(4) + ", " + e22.toFixed(4) + "|"
        ;
        return text;
    }
}
class Mat44 {
    public var e00:Number;
    public var e01:Number;
    public var e02:Number;
    public var e03:Number;
    public var e10:Number;
    public var e11:Number;
    public var e12:Number;
    public var e13:Number;
    public var e20:Number;
    public var e21:Number;
    public var e22:Number;
    public var e23:Number;
    public var e30:Number;
    public var e31:Number;
    public var e32:Number;
    public var e33:Number;
    public function Mat44(
        e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1
    ) {
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e03 = e03;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e13 = e13;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        this.e23 = e23;
        this.e30 = e30;
        this.e31 = e31;
        this.e32 = e32;
        this.e33 = e33;
    }
    public function init(
        e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1
    ):Mat44 {
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e03 = e03;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e13 = e13;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        this.e23 = e23;
        this.e30 = e30;
        this.e31 = e31;
        this.e32 = e32;
        this.e33 = e33;
        return this;
    }
    public function add(m1:Mat44, m2:Mat44):Mat44 {
        e00 = m1.e00 + m2.e00;
        e01 = m1.e01 + m2.e01;
        e02 = m1.e02 + m2.e02;
        e03 = m1.e03 + m2.e03;
        e10 = m1.e10 + m2.e10;
        e11 = m1.e11 + m2.e11;
        e12 = m1.e12 + m2.e12;
        e13 = m1.e13 + m2.e13;
        e20 = m1.e20 + m2.e20;
        e21 = m1.e21 + m2.e21;
        e22 = m1.e22 + m2.e22;
        e23 = m1.e23 + m2.e23;
        e30 = m1.e30 + m2.e30;
        e31 = m1.e31 + m2.e31;
        e32 = m1.e32 + m2.e32;
        e33 = m1.e33 + m2.e33;
        return this;
    }
    public function sub(m1:Mat44, m2:Mat44):Mat44 {
        e00 = m1.e00 - m2.e00;
        e01 = m1.e01 - m2.e01;
        e02 = m1.e02 - m2.e02;
        e03 = m1.e03 - m2.e03;
        e10 = m1.e10 - m2.e10;
        e11 = m1.e11 - m2.e11;
        e12 = m1.e12 - m2.e12;
        e13 = m1.e13 - m2.e13;
        e20 = m1.e20 - m2.e20;
        e21 = m1.e21 - m2.e21;
        e22 = m1.e22 - m2.e22;
        e23 = m1.e23 - m2.e23;
        e30 = m1.e30 - m2.e30;
        e31 = m1.e31 - m2.e31;
        e32 = m1.e32 - m2.e32;
        e33 = m1.e33 - m2.e33;
        return this;
    }
    public function scale(m:Mat44, s:Number):Mat44 {
        e00 = m.e00 * s;
        e01 = m.e01 * s;
        e02 = m.e02 * s;
        e03 = m.e03 * s;
        e10 = m.e10 * s;
        e11 = m.e11 * s;
        e12 = m.e12 * s;
        e13 = m.e13 * s;
        e20 = m.e20 * s;
        e21 = m.e21 * s;
        e22 = m.e22 * s;
        e23 = m.e23 * s;
        e30 = m.e30 * s;
        e31 = m.e31 * s;
        e32 = m.e32 * s;
        e33 = m.e33 * s;
        return this;
    }
    public function mul(m1:Mat44, m2:Mat44):Mat44 {
        var e00:Number = m1.e00 * m2.e00 + m1.e01 * m2.e10 + m1.e02 * m2.e20 + m1.e03 * m2.e30;
        var e01:Number = m1.e00 * m2.e01 + m1.e01 * m2.e11 + m1.e02 * m2.e21 + m1.e03 * m2.e31;
        var e02:Number = m1.e00 * m2.e02 + m1.e01 * m2.e12 + m1.e02 * m2.e22 + m1.e03 * m2.e32;
        var e03:Number = m1.e00 * m2.e03 + m1.e01 * m2.e13 + m1.e02 * m2.e23 + m1.e03 * m2.e33;
        var e10:Number = m1.e10 * m2.e00 + m1.e11 * m2.e10 + m1.e12 * m2.e20 + m1.e13 * m2.e30;
        var e11:Number = m1.e10 * m2.e01 + m1.e11 * m2.e11 + m1.e12 * m2.e21 + m1.e13 * m2.e31;
        var e12:Number = m1.e10 * m2.e02 + m1.e11 * m2.e12 + m1.e12 * m2.e22 + m1.e13 * m2.e32;
        var e13:Number = m1.e10 * m2.e03 + m1.e11 * m2.e13 + m1.e12 * m2.e23 + m1.e13 * m2.e33;
        var e20:Number = m1.e20 * m2.e00 + m1.e21 * m2.e10 + m1.e22 * m2.e20 + m1.e23 * m2.e30;
        var e21:Number = m1.e20 * m2.e01 + m1.e21 * m2.e11 + m1.e22 * m2.e21 + m1.e23 * m2.e31;
        var e22:Number = m1.e20 * m2.e02 + m1.e21 * m2.e12 + m1.e22 * m2.e22 + m1.e23 * m2.e32;
        var e23:Number = m1.e20 * m2.e03 + m1.e21 * m2.e13 + m1.e22 * m2.e23 + m1.e23 * m2.e33;
        var e30:Number = m1.e30 * m2.e00 + m1.e31 * m2.e10 + m1.e32 * m2.e20 + m1.e33 * m2.e30;
        var e31:Number = m1.e30 * m2.e01 + m1.e31 * m2.e11 + m1.e32 * m2.e21 + m1.e33 * m2.e31;
        var e32:Number = m1.e30 * m2.e02 + m1.e31 * m2.e12 + m1.e32 * m2.e22 + m1.e33 * m2.e32;
        var e33:Number = m1.e30 * m2.e03 + m1.e31 * m2.e13 + m1.e32 * m2.e23 + m1.e33 * m2.e33;
        this.e00 = e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e03 = e03;
        this.e10 = e10;
        this.e11 = e11;
        this.e12 = e12;
        this.e13 = e13;
        this.e20 = e20;
        this.e21 = e21;
        this.e22 = e22;
        this.e23 = e23;
        this.e30 = e30;
        this.e31 = e31;
        this.e32 = e32;
        this.e33 = e33;
        return this;
    }
    public function mulScale(m:Mat44, sx:Number, sy:Number, sz:Number, prepend:Boolean = false):Mat44 {
        var e00:Number;
        var e01:Number;
        var e02:Number;
        var e03:Number;
        var e10:Number;
        var e11:Number;
        var e12:Number;
        var e13:Number;
        var e20:Number;
        var e21:Number;
        var e22:Number;
        var e23:Number;
        var e30:Number;
        var e31:Number;
        var e32:Number;
        var e33:Number;
        if (prepend) {
            e00 = sx * m.e00;
            e01 = sx * m.e01;
            e02 = sx * m.e02;
            e03 = sx * m.e03;
            e10 = sy * m.e10;
            e11 = sy * m.e11;
            e12 = sy * m.e12;
            e13 = sy * m.e13;
            e20 = sz * m.e20;
            e21 = sz * m.e21;
            e22 = sz * m.e22;
            e23 = sz * m.e23;
            e30 = m.e30;
            e31 = m.e31;
            e32 = m.e32;
            e33 = m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        } else {
            e00 = m.e00 * sx;
            e01 = m.e01 * sy;
            e02 = m.e02 * sz;
            e03 = m.e03;
            e10 = m.e10 * sx;
            e11 = m.e11 * sy;
            e12 = m.e12 * sz;
            e13 = m.e13;
            e20 = m.e20 * sx;
            e21 = m.e21 * sy;
            e22 = m.e22 * sz;
            e23 = m.e23;
            e30 = m.e30 * sx;
            e31 = m.e31 * sy;
            e32 = m.e32 * sz;
            e33 = m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        }
        return this;
    }
    public function mulRotate(m:Mat44, rad:Number, ax:Number, ay:Number, az:Number, prepend:Boolean = false):Mat44 {
        var s:Number = Math.sin(rad);
        var c:Number = Math.cos(rad);
        var c1:Number = 1 - c;
        var r00:Number = ax * ax * c1 + c;
        var r01:Number = ax * ay * c1 - az * s;
        var r02:Number = ax * az * c1 + ay * s;
        var r10:Number = ay * ax * c1 + az * s;
        var r11:Number = ay * ay * c1 + c;
        var r12:Number = ay * az * c1 - ax * s;
        var r20:Number = az * ax * c1 - ay * s;
        var r21:Number = az * ay * c1 + ax * s;
        var r22:Number = az * az * c1 + c;
        var e00:Number;
        var e01:Number;
        var e02:Number;
        var e03:Number;
        var e10:Number;
        var e11:Number;
        var e12:Number;
        var e13:Number;
        var e20:Number;
        var e21:Number;
        var e22:Number;
        var e23:Number;
        var e30:Number;
        var e31:Number;
        var e32:Number;
        var e33:Number;
        if (prepend) {
            e00 = r00 * m.e00 + r01 * m.e10 + r02 * m.e20;
            e01 = r00 * m.e01 + r01 * m.e11 + r02 * m.e21;
            e02 = r00 * m.e02 + r01 * m.e12 + r02 * m.e22;
            e03 = r00 * m.e03 + r01 * m.e13 + r02 * m.e23;
            e10 = r10 * m.e00 + r11 * m.e10 + r12 * m.e20;
            e11 = r10 * m.e01 + r11 * m.e11 + r12 * m.e21;
            e12 = r10 * m.e02 + r11 * m.e12 + r12 * m.e22;
            e13 = r10 * m.e03 + r11 * m.e13 + r12 * m.e23;
            e20 = r20 * m.e00 + r21 * m.e10 + r22 * m.e20;
            e21 = r20 * m.e01 + r21 * m.e11 + r22 * m.e21;
            e22 = r20 * m.e02 + r21 * m.e12 + r22 * m.e22;
            e23 = r20 * m.e03 + r21 * m.e13 + r22 * m.e23;
            e30 = m.e30;
            e31 = m.e31;
            e32 = m.e32;
            e33 = m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        } else {
            e00 = m.e00 * r00 + m.e01 * r10 + m.e02 * r20;
            e01 = m.e00 * r01 + m.e01 * r11 + m.e02 * r21;
            e02 = m.e00 * r02 + m.e01 * r12 + m.e02 * r22;
            e03 = m.e03;
            e10 = m.e10 * r00 + m.e11 * r10 + m.e12 * r20;
            e11 = m.e10 * r01 + m.e11 * r11 + m.e12 * r21;
            e12 = m.e10 * r02 + m.e11 * r12 + m.e12 * r22;
            e13 = m.e13;
            e20 = m.e20 * r00 + m.e21 * r10 + m.e22 * r20;
            e21 = m.e20 * r01 + m.e21 * r11 + m.e22 * r21;
            e22 = m.e20 * r02 + m.e21 * r12 + m.e22 * r22;
            e23 = m.e23;
            e30 = m.e30 * r00 + m.e31 * r10 + m.e32 * r20;
            e31 = m.e30 * r01 + m.e31 * r11 + m.e32 * r21;
            e32 = m.e30 * r02 + m.e31 * r12 + m.e32 * r22;
            e33 = m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        }
        return this;
    }
    public function mulTranslate(m:Mat44, tx:Number, ty:Number, tz:Number, prepend:Boolean = false):Mat44 {
        var e00:Number;
        var e01:Number;
        var e02:Number;
        var e03:Number;
        var e10:Number;
        var e11:Number;
        var e12:Number;
        var e13:Number;
        var e20:Number;
        var e21:Number;
        var e22:Number;
        var e23:Number;
        var e30:Number;
        var e31:Number;
        var e32:Number;
        var e33:Number;
        if (prepend) {
            e00 = m.e00 + tx * m.e30;
            e01 = m.e01 + tx * m.e31;
            e02 = m.e02 + tx * m.e32;
            e03 = m.e03 + tx * m.e33;
            e10 = m.e10 + ty * m.e30;
            e11 = m.e11 + ty * m.e31;
            e12 = m.e12 + ty * m.e32;
            e13 = m.e13 + ty * m.e33;
            e20 = m.e20 + tz * m.e30;
            e21 = m.e21 + tz * m.e31;
            e22 = m.e22 + tz * m.e32;
            e23 = m.e23 + tz * m.e33;
            e30 = m.e30;
            e31 = m.e31;
            e32 = m.e32;
            e33 = m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        } else {
            e00 = m.e00;
            e01 = m.e01;
            e02 = m.e02;
            e03 = m.e00 * tx + m.e01 * ty + m.e02 * tz + m.e03;
            e10 = m.e10;
            e11 = m.e11;
            e12 = m.e12;
            e13 = m.e10 * tx + m.e11 * ty + m.e12 * tz + m.e13;
            e20 = m.e20;
            e21 = m.e21;
            e22 = m.e22;
            e23 = m.e20 * tx + m.e21 * ty + m.e22 * tz + m.e23;
            e30 = m.e30;
            e31 = m.e31;
            e32 = m.e32;
            e33 = m.e30 * tx + m.e31 * ty + m.e32 * tz + m.e33;
            this.e00 = e00;
            this.e01 = e01;
            this.e02 = e02;
            this.e03 = e03;
            this.e10 = e10;
            this.e11 = e11;
            this.e12 = e12;
            this.e13 = e13;
            this.e20 = e20;
            this.e21 = e21;
            this.e22 = e22;
            this.e23 = e23;
            this.e30 = e30;
            this.e31 = e31;
            this.e32 = e32;
            this.e33 = e33;
        }
        return this;
    }
    public function transpose(m:Mat44):Mat44 {
        var e01:Number = m.e10;
        var e02:Number = m.e20;
        var e03:Number = m.e30;
        var e10:Number = m.e01;
        var e12:Number = m.e21;
        var e13:Number = m.e31;
        var e20:Number = m.e02;
        var e21:Number = m.e12;
        var e23:Number = m.e32;
        var e30:Number = m.e03;
        var e31:Number = m.e13;
        var e32:Number = m.e23;
        e00 = m.e00;
        this.e01 = e01;
        this.e02 = e02;
        this.e03 = e03;
        this.e10 = e10;
        e11 = m.e11;
        this.e12 = e12;
        this.e13 = e13;
        this.e20 = e20;
        this.e21 = e21;
        e22 = m.e22;
        this.e23 = e23;
        this.e30 = e30;
        this.e31 = e31;
        this.e32 = e32;
        e33 = m.e33;
        return this;
    }
    public function setQuat(q:Quat):Mat44 {
        var x2:Number = 2 * q.x;
        var y2:Number = 2 * q.y;
        var z2:Number = 2 * q.z;
        var xx:Number = q.x * x2;
        var yy:Number = q.y * y2;
        var zz:Number = q.z * z2;
        var xy:Number = q.x * y2;
        var yz:Number = q.y * z2;
        var xz:Number = q.x * z2;
        var sx:Number = q.s * x2;
        var sy:Number = q.s * y2;
        var sz:Number = q.s * z2;
        e00 = 1 - yy - zz;
        e01 = xy - sz;
        e02 = xz + sy;
        e03 = 0;
        e10 = xy + sz;
        e11 = 1 - xx - zz;
        e12 = yz - sx;
        e13 = 0;
        e20 = xz - sy;
        e21 = yz + sx;
        e22 = 1 - xx - yy;
        e23 = 0;
        e30 = 0;
        e31 = 0;
        e32 = 0;
        e33 = 1;
        return this;
    }
    public function invert(m:Mat44):Mat44 {
        var e1021_1120:Number = m.e10 * m.e21 - m.e11 * m.e20;
        var e1022_1220:Number = m.e10 * m.e22 - m.e12 * m.e20;
        var e1023_1320:Number = m.e10 * m.e23 - m.e13 * m.e20;
        var e1031_1130:Number = m.e10 * m.e31 - m.e11 * m.e30;
        var e1032_1230:Number = m.e10 * m.e32 - m.e12 * m.e30;
        var e1033_1330:Number = m.e10 * m.e33 - m.e13 * m.e30;
        var e1122_1221:Number = m.e11 * m.e22 - m.e12 * m.e21;
        var e1123_1321:Number = m.e11 * m.e23 - m.e13 * m.e21;
        var e1132_1231:Number = m.e11 * m.e32 - m.e12 * m.e31;
        var e1133_1331:Number = m.e11 * m.e33 - m.e13 * m.e31;
        var e1220_2022:Number = m.e12 * m.e20 - m.e20 * m.e22;
        var e1223_1322:Number = m.e12 * m.e23 - m.e13 * m.e22;
        var e1223_2223:Number = m.e12 * m.e33 - m.e22 * m.e23;
        var e1233_1332:Number = m.e12 * m.e33 - m.e13 * m.e32;
        var e2031_2130:Number = m.e20 * m.e31 - m.e21 * m.e30;
        var e2032_2033:Number = m.e20 * m.e32 - m.e20 * m.e33;
        var e2032_2230:Number = m.e20 * m.e32 - m.e22 * m.e30;
        var e2033_2330:Number = m.e20 * m.e33 - m.e23 * m.e30;
        var e2132_2231:Number = m.e21 * m.e32 - m.e22 * m.e31;
        var e2133_2331:Number = m.e21 * m.e33 - m.e23 * m.e31;
        var e2230_2330:Number = m.e22 * m.e30 - m.e23 * m.e30;
        var e2233_2332:Number = m.e22 * m.e33 - m.e23 * m.e32;
        var det:Number =
            m.e00 * (m.e11 * e2233_2332 - m.e12 * e2133_2331 + m.e13 * e2132_2231) +
            m.e01 * (-m.e10 * e2233_2332 - m.e12 * e2032_2033 + m.e13 * e2230_2330) +
            m.e02 * (m.e10 * e2133_2331 - m.e11 * e2033_2330 + m.e13 * e2031_2130) +
            m.e03 * (-m.e10 * e2132_2231 + m.e11 * e2032_2230 - m.e12 * e2031_2130)
        ;
        if (det != 0) det = 1 / det;
        var t00:Number = m.e11 * e2233_2332 - m.e12 * e2133_2331 + m.e13 * e2132_2231;
        var t01:Number = -m.e01 * e2233_2332 + m.e02 * e2133_2331 - m.e03 * e2132_2231;
        var t02:Number = m.e01 * e1233_1332 - m.e02 * e1133_1331 + m.e03 * e1132_1231;
        var t03:Number = -m.e01 * e1223_2223 + m.e02 * e1123_1321 - m.e03 * e1122_1221;
        var t10:Number = -m.e10 * e2233_2332 + m.e12 * e2033_2330 - m.e13 * e2032_2230;
        var t11:Number = m.e00 * e2233_2332 - m.e02 * e2033_2330 + m.e03 * e2032_2230;
        var t12:Number = -m.e00 * e1233_1332 + m.e02 * e1033_1330 - m.e03 * e1032_1230;
        var t13:Number = m.e00 * e1223_1322 - m.e02 * e1023_1320 - m.e03 * e1220_2022;
        var t20:Number = m.e10 * e2133_2331 - m.e11 * e2033_2330 + m.e13 * e2031_2130;
        var t21:Number = -m.e00 * e2133_2331 + m.e01 * e2033_2330 - m.e03 * e2031_2130;
        var t22:Number = m.e00 * e1133_1331 - m.e01 * e1033_1330 + m.e03 * e1031_1130;
        var t23:Number = -m.e00 * e1123_1321 + m.e01 * e1023_1320 - m.e03 * e1021_1120;
        var t30:Number = -m.e10 * e2132_2231 + m.e11 * e2032_2230 - m.e12 * e2031_2130;
        var t31:Number = m.e00 * e2132_2231 - m.e01 * e2032_2230 + m.e02 * e2031_2130;
        var t32:Number = -m.e00 * e1132_1231 + m.e01 * e1032_1230 - m.e02 * e1031_1130;
        var t33:Number = m.e00 * e1122_1221 - m.e01 * e1022_1220 + m.e02 * e1021_1120;
        e00 = det * t00;
        e01 = det * t01;
        e02 = det * t02;
        e03 = det * t03;
        e10 = det * t10;
        e11 = det * t11;
        e12 = det * t12;
        e13 = det * t13;
        e20 = det * t20;
        e21 = det * t21;
        e22 = det * t22;
        e23 = det * t23;
        e30 = det * t30;
        e31 = det * t31;
        e32 = det * t32;
        e33 = det * t33;
        return this;
    }
    public function lookAt(
        eyeX:Number, eyeY:Number, eyeZ:Number,
        atX:Number, atY:Number, atZ:Number,
        upX:Number, upY:Number, upZ:Number
    ):Mat44 {
        var zx:Number = eyeX - atX;
        var zy:Number = eyeY - atY;
        var zz:Number = eyeZ - atZ;
        var tmp:Number = 1 / Math.sqrt(zx * zx + zy * zy + zz * zz);
        zx *= tmp;
        zy *= tmp;
        zz *= tmp;
        var xx:Number = upY * zz - upZ * zy;
        var xy:Number = upZ * zx - upX * zz;
        var xz:Number = upX * zy - upY * zx;
        tmp = 1 / Math.sqrt(xx * xx + xy * xy + xz * xz);
        xx *= tmp;
        xy *= tmp;
        xz *= tmp;
        var yx:Number = zy * xz - zz * xy;
        var yy:Number = zz * xx - zx * xz;
        var yz:Number = zx * xy - zy * xx;
        e00 = xx;
        e01 = xy;
        e02 = xz;
        e03 = -(xx * eyeX + xy * eyeY + xz * eyeZ);
        e10 = yx;
        e11 = yy;
        e12 = yz;
        e13 = -(yx * eyeX + yy * eyeY + yz * eyeZ);
        e20 = zx;
        e21 = zy;
        e22 = zz;
        e23 = -(zx * eyeX + zy * eyeY + zz * eyeZ);
        e30 = 0;
        e31 = 0;
        e32 = 0;
        e33 = 1;
        return this;
    }
    public function perspective(fovY:Number, aspect:Number, near:Number, far:Number):Mat44 {
        var h:Number = 1 / Math.tan(fovY * 0.5);
        var fnf:Number = far / (near - far);
        e00 = h / aspect;
        e01 = 0;
        e02 = 0;
        e03 = 0;
        e10 = 0;
        e11 = h;
        e12 = 0;
        e13 = 0;
        e20 = 0;
        e21 = 0;
        e22 = fnf;
        e23 = near * fnf;
        e30 = 0;
        e31 = 0;
        e32 = -1;
        e33 = 0;
        return this;
    }
    public function ortho(width:Number, height:Number, near:Number, far:Number):Mat44 {
        var nf:Number = 1 / (near - far);
        e00 = 2 / width;
        e01 = 0;
        e02 = 0;
        e03 = 0;
        e10 = 0;
        e11 = 2 / height;
        e12 = 0;
        e13 = 0;
        e20 = 0;
        e21 = 0;
        e22 = nf;
        e23 = near * nf;
        e30 = 0;
        e31 = 0;
        e32 = 0;
        e33 = 0;
        return this;
    }
    public function copy(m:Mat44):Mat44 {
        e00 = m.e00;
        e01 = m.e01;
        e02 = m.e02;
        e03 = m.e03;
        e10 = m.e10;
        e11 = m.e11;
        e12 = m.e12;
        e13 = m.e13;
        e20 = m.e20;
        e21 = m.e21;
        e22 = m.e22;
        e23 = m.e23;
        e30 = m.e30;
        e31 = m.e31;
        e32 = m.e32;
        e33 = m.e33;
        return this;
    }
    public function copyMat33(m:Mat33):Mat44 {
        e00 = m.e00;
        e01 = m.e01;
        e02 = m.e02;
        e03 = 0;
        e10 = m.e10;
        e11 = m.e11;
        e12 = m.e12;
        e13 = 0;
        e20 = m.e20;
        e21 = m.e21;
        e22 = m.e22;
        e23 = 0;
        e30 = 0;
        e31 = 0;
        e32 = 0;
        e33 = 1;
        return this;
    }
    public function clone():Mat44 {
        return new Mat44(
            e00, e01, e02, e03,
            e10, e11, e12, e13,
            e20, e21, e22, e23,
            e30, e31, e32, e33
        );
    }
    public function toString():String {
        var text:String =
            "Mat44|" + e00.toFixed(4) + ", " + e01.toFixed(4) + ", " + e02.toFixed(4) + ", " + e03.toFixed(4) + "|\n" +
            "     |" + e10.toFixed(4) + ", " + e11.toFixed(4) + ", " + e12.toFixed(4) + ", " + e13.toFixed(4) + "|\n" +
            "     |" + e20.toFixed(4) + ", " + e21.toFixed(4) + ", " + e22.toFixed(4) + ", " + e23.toFixed(4) + "|\n" +
            "     |" + e30.toFixed(4) + ", " + e31.toFixed(4) + ", " + e32.toFixed(4) + ", " + e33.toFixed(4) + "|\n"
        ;
        return text;
    }
}
class Quat {
    public var s:Number;
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public function Quat(s:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0) {
        this.s = s;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    public function init(s:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0):Quat {
        this.s = s;
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    public function add(q1:Quat, q2:Quat):Quat {
        s = q1.s + q2.s;
        x = q1.x + q2.x;
        y = q1.y + q2.y;
        z = q1.z + q2.z;
        return this;
    }
    public function sub(q1:Quat, q2:Quat):Quat {
        s = q1.s - q2.s;
        x = q1.x - q2.x;
        y = q1.y - q2.y;
        z = q1.z - q2.z;
        return this;
    }
    public function scale(q:Quat, s:Number):Quat {
        this.s = q.s * s;
        x = q.x * s;
        y = q.y * s;
        z = q.z * s;
        return this;
    }
    public function mul(q1:Quat, q2:Quat):Quat {
        var s:Number = q1.s * q2.s - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
        var x:Number = q1.s * q2.x + q1.x * q2.s + q1.y * q2.z - q1.z * q2.y;
        var y:Number = q1.s * q2.y - q1.x * q2.z + q1.y * q2.s + q1.z * q2.x;
        var z:Number = q1.s * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.s;
        this.s = s;
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    public function normalize(q:Quat):Quat {
        var len:Number = Math.sqrt(q.s * q.s + q.x * q.x + q.y * q.y + q.z * q.z);
        if (len > 0) len = 1 / len;
        s = q.s * len;
        x = q.x * len;
        y = q.y * len;
        z = q.z * len;
        return this;
    }
    public function invert(q:Quat):Quat {
        s = -q.s;
        x = -q.x;
        y = -q.y;
        z = -q.z;
        return this;
    }
    public function length():Number {
        return Math.sqrt(s * s + x * x + y * y + z * z);
    }
    public function copy(q:Quat):Quat {
        s = q.s;
        x = q.x;
        y = q.y;
        z = q.z;
        return this;
    }
    public function clone(q:Quat):Quat {
        return new Quat(s, x, y, z);
    }
    public function toString():String {
        return "Quat[" + s.toFixed(4) + ", (" + x.toFixed(4) + ", " + y.toFixed(4) + ", " + z.toFixed(4) + ")]";
    }
}
class Vec3 {
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public function Vec3(x:Number = 0, y:Number = 0, z:Number = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    public function init(x:Number = 0, y:Number = 0, z:Number = 0):Vec3 {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    public function add(v1:Vec3, v2:Vec3):Vec3 {
        x = v1.x + v2.x;
        y = v1.y + v2.y;
        z = v1.z + v2.z;
        return this;
    }
    public function sub(v1:Vec3, v2:Vec3):Vec3 {
        x = v1.x - v2.x;
        y = v1.y - v2.y;
        z = v1.z - v2.z;
        return this;
    }
    public function scale(v:Vec3, s:Number):Vec3 {
        x = v.x * s;
        y = v.y * s;
        z = v.z * s;
        return this;
    }
    public function dot(v:Vec3):Number {
        return x * v.x + y * v.y + z * v.z;
    }
    public function cross(v1:Vec3, v2:Vec3):Vec3 {
        var x:Number = v1.y * v2.z - v1.z * v2.y;
        var y:Number = v1.z * v2.x - v1.x * v2.z;
        var z:Number = v1.x * v2.y - v1.y * v2.x;
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    public function mulMat(m:Mat33, v:Vec3):Vec3 {
        var x:Number = m.e00 * v.x + m.e01 * v.y + m.e02 * v.z;
        var y:Number = m.e10 * v.x + m.e11 * v.y + m.e12 * v.z;
        var z:Number = m.e20 * v.x + m.e21 * v.y + m.e22 * v.z;
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    public function normalize(v:Vec3):Vec3 {
        var length:Number = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        if (length > 0) length = 1 / length;
        x = v.x * length;
        y = v.y * length;
        z = v.z * length;
        return this;
    }
    public function invert(v:Vec3):Vec3 {
        x = -v.x;
        y = -v.y;
        z = -v.z;
        return this;
    }
    public function length():Number {
        return Math.sqrt(x * x + y * y + z * z);
    }
    public function copy(v:Vec3):Vec3 {
        x = v.x;
        y = v.y;
        z = v.z;
        return this;
    }
    public function clone():Vec3 {
        return new Vec3(x, y, z);
    }
    public function toString():String {
        return "Vec3[" + x.toFixed(4) + ", " + y.toFixed(4) + ", " + z.toFixed(4) + "]";
    }
}
class BroadPhase {
    public var numPairChecks:uint;
    public function BroadPhase() {
    }
    public function addProxy(proxy:Proxy):void {
        throw new Error("addProxy 関数が継承されていません");
    }
    public function removeProxy(proxy:Proxy):void {
        throw new Error("removeProxy 関数が継承されていません");
    }
    public function detectPairs(pairs:Vector.<Pair>):uint {
        throw new Error("collectPairs 関数が継承されていません");
    }
}
class Pair {
    public var shape1:Shape;
    public var shape2:Shape;
    public function Pair() {
    }
}
class Proxy {
    public var minX:Number;
    public var maxX:Number;
    public var minY:Number;
    public var maxY:Number;
    public var minZ:Number;
    public var maxZ:Number;
    public var parent:Shape;
    public function Proxy(
        minX:Number = 0, maxX:Number = 0,
        minY:Number = 0, maxY:Number = 0,
        minZ:Number = 0, maxZ:Number = 0
    ) {
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
        this.minZ = minZ;
        this.maxZ = maxZ;
    }
    public function init(
        minX:Number = 0, maxX:Number = 0,
        minY:Number = 0, maxY:Number = 0,
        minZ:Number = 0, maxZ:Number = 0
    ):void {
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
        this.minZ = minZ;
        this.maxZ = maxZ;
    }
    public function intersect(proxy:Proxy):Boolean {
        return maxX > proxy.minX && minX < proxy.maxX && maxY > proxy.minY && minY < proxy.maxY && maxZ > proxy.minZ && minZ < proxy.maxZ;
    }
}
class SweepAndPruneBroadPhase extends BroadPhase {
    private var proxyPoolAxis:Vector.<Vector.<Proxy>>;
    private var sortAxis:uint;
    private var numProxies:uint;
    public function SweepAndPruneBroadPhase() {
        sortAxis = 0;
        proxyPoolAxis = new Vector.<Vector.<Proxy>>(3, true);
        proxyPoolAxis[0] = new Vector.<Proxy>(World.MAX_SHAPES, true);
        proxyPoolAxis[1] = new Vector.<Proxy>(World.MAX_SHAPES, true);
        proxyPoolAxis[2] = new Vector.<Proxy>(World.MAX_SHAPES, true);
    }
    override public function addProxy(proxy:Proxy):void {
        proxyPoolAxis[0][numProxies] = proxy;
        proxyPoolAxis[1][numProxies] = proxy;
        proxyPoolAxis[2][numProxies] = proxy;
        numProxies++;
    }
    override public function removeProxy(proxy:Proxy):void {
        removeProxyAxis(proxy, proxyPoolAxis[0]);
        removeProxyAxis(proxy, proxyPoolAxis[1]);
        removeProxyAxis(proxy, proxyPoolAxis[2]);
        numProxies--;
    }
    override public function detectPairs(pairs:Vector.<Pair>):uint {
        numPairChecks = 0;
        var proxyPool:Vector.<Proxy> = proxyPoolAxis[sortAxis];
        var result:uint;
        if (sortAxis == 0) {
            insertionSortX(proxyPool);
            return sweepX(pairs, proxyPool);
        } else if (sortAxis == 1) {
            insertionSortY(proxyPool);
            return sweepY(pairs, proxyPool);
        } else {
            insertionSortZ(proxyPool);
            return sweepZ(pairs, proxyPool);
        }
    }
    private function sweepX(pairs:Vector.<Pair>, proxyPool:Vector.<Proxy>):uint {
        var numPairs:uint = 0;
        var center:Number;
        var sumX:Number = 0;
        var sumX2:Number = 0;
        var sumY:Number = 0;
        var sumY2:Number = 0;
        var sumZ:Number = 0;
        var sumZ2:Number = 0;
        var invNum:Number = 1 / numProxies;
        var bodyStatic:uint = RigidBody.BODY_STATIC;
        var maxPairs:uint = World.MAX_PAIRS;
        for (var i:int = 0; i < numProxies; i++) {
            var p1:Proxy = proxyPool[i];
            center = p1.minX + p1.maxX;
            sumX += center;
            sumX2 += center * center;
            center = p1.minY + p1.maxY;
            sumY += center;
            sumY2 += center * center;
            center = p1.minZ + p1.maxZ;
            sumZ += center;
            sumZ2 += center * center;
            var s1:Shape = p1.parent;
            var b1:RigidBody = s1.parent;
            for (var j:int = i + 1; j < numProxies; j++) {
                var p2:Proxy = proxyPool[j];
                numPairChecks++;
                if (p1.maxX < p2.minX) {
                    break;
                }
                var s2:Shape = p2.parent;
                var b2:RigidBody = s2.parent;
                if (
                    b1 == b2 ||
                    p1.maxY < p2.minY || p1.minY > p2.maxY ||
                    p1.maxZ < p2.minZ || p1.minZ > p2.maxZ ||
                    b1.type == bodyStatic && b2.type == bodyStatic
                ) {
                    continue;
                }
                if (numPairs >= maxPairs) {
                    return numPairs;
                }
                var pair:Pair = pairs[numPairs];
                if (!pair) {
                    pair = new Pair();
                    pairs[numPairs] = pair;
                }
                pair.shape1 = s1;
                pair.shape2 = s2;
                numPairs++;
            }
        }
        sumX = sumX2 - sumX * sumX * invNum;
        sumY = sumY2 - sumY * sumY * invNum;
        sumZ = sumZ2 - sumZ * sumZ * invNum;
        if (sumX > sumY) {
            if (sumX > sumZ) {
                sortAxis = 0;
            } else {
                sortAxis = 2;
            }
        } else if (sumY > sumZ) {
            sortAxis = 1;
        } else {
            sortAxis = 2;
        }
        return numPairs;
    }
    private function sweepY(pairs:Vector.<Pair>, proxyPool:Vector.<Proxy>):uint {
        var numPairs:uint = 0;
        var center:Number;
        var sumX:Number = 0;
        var sumX2:Number = 0;
        var sumY:Number = 0;
        var sumY2:Number = 0;
        var sumZ:Number = 0;
        var sumZ2:Number = 0;
        var invNum:Number = 1 / numProxies;
        var bodyStatic:uint = RigidBody.BODY_STATIC;
        var maxPairs:uint = World.MAX_PAIRS;
        for (var i:int = 0; i < numProxies; i++) {
            var p1:Proxy = proxyPool[i];
            center = p1.minX + p1.maxX;
            sumX += center;
            sumX2 += center * center;
            center = p1.minY + p1.maxY;
            sumY += center;
            sumY2 += center * center;
            center = p1.minZ + p1.maxZ;
            sumZ += center;
            sumZ2 += center * center;
            var s1:Shape = p1.parent;
            var b1:RigidBody = s1.parent;
            for (var j:int = i + 1; j < numProxies; j++) {
                var p2:Proxy = proxyPool[j];
                numPairChecks++;
                if (p1.maxY < p2.minY) {
                    break;
                }
                var s2:Shape = p2.parent;
                var b2:RigidBody = s2.parent;
                if (
                    b1 == b2 ||
                    p1.maxX < p2.minX || p1.minX > p2.maxX ||
                    p1.maxZ < p2.minZ || p1.minZ > p2.maxZ ||
                    b1.type == bodyStatic && b2.type == bodyStatic
                ) {
                    continue;
                }
                if (numPairs >= maxPairs) {
                    return numPairs;
                }
                var pair:Pair = pairs[numPairs];
                if (!pair) {
                    pair = new Pair();
                    pairs[numPairs] = pair;
                }
                pair.shape1 = s1;
                pair.shape2 = s2;
                numPairs++;
            }
        }
        sumX = sumX2 - sumX * sumX * invNum;
        sumY = sumY2 - sumY * sumY * invNum;
        sumZ = sumZ2 - sumZ * sumZ * invNum;
        if (sumX > sumY) {
            if (sumX > sumZ) {
                sortAxis = 0;
            } else {
                sortAxis = 2;
            }
        } else if (sumY > sumZ) {
            sortAxis = 1;
        } else {
            sortAxis = 2;
        }
        return numPairs;
    }
    private function sweepZ(pairs:Vector.<Pair>, proxyPool:Vector.<Proxy>):uint {
        var numPairs:uint = 0;
        var center:Number;
        var sumX:Number = 0;
        var sumX2:Number = 0;
        var sumY:Number = 0;
        var sumY2:Number = 0;
        var sumZ:Number = 0;
        var sumZ2:Number = 0;
        var invNum:Number = 1 / numProxies;
        var bodyStatic:uint = RigidBody.BODY_STATIC;
        var maxPairs:uint = World.MAX_PAIRS;
        for (var i:int = 0; i < numProxies; i++) {
            var p1:Proxy = proxyPool[i];
            center = p1.minX + p1.maxX;
            sumX += center;
            sumX2 += center * center;
            center = p1.minY + p1.maxY;
            sumY += center;
            sumY2 += center * center;
            center = p1.minZ + p1.maxZ;
            sumZ += center;
            sumZ2 += center * center;
            var s1:Shape = p1.parent;
            var b1:RigidBody = s1.parent;
            for (var j:int = i + 1; j < numProxies; j++) {
                var p2:Proxy = proxyPool[j];
                numPairChecks++;
                if (p1.maxZ < p2.minZ) {
                    break;
                }
                var s2:Shape = p2.parent;
                var b2:RigidBody = s2.parent;
                if (
                    b1 == b2 ||
                    p1.maxX < p2.minX || p1.minX > p2.maxX ||
                    p1.maxY < p2.minY || p1.minY > p2.maxY ||
                    b1.type == bodyStatic && b2.type == bodyStatic
                ) {
                    continue;
                }
                if (numPairs >= maxPairs) {
                    return numPairs;
                }
                var pair:Pair = pairs[numPairs];
                if (!pair) {
                    pair = new Pair();
                    pairs[numPairs] = pair;
                }
                pair.shape1 = s1;
                pair.shape2 = s2;
                numPairs++;
            }
        }
        sumX = sumX2 - sumX * sumX * invNum;
        sumY = sumY2 - sumY * sumY * invNum;
        sumZ = sumZ2 - sumZ * sumZ * invNum;
        if (sumX > sumY) {
            if (sumX > sumZ) {
                sortAxis = 0;
            } else {
                sortAxis = 2;
            }
        } else if (sumY > sumZ) {
            sortAxis = 1;
        } else {
            sortAxis = 2;
        }
        return numPairs;
    }
    private function removeProxyAxis(proxy:Proxy, proxyPool:Vector.<Proxy>):void {
        var idx:int = -1;
        for (var i:int = 0; i < numProxies; i++) {
            if (proxyPool[i] == proxy) {
                idx = i;
                break;
            }
        }
        if (idx == -1) {
            return;
        }
        for (var j:int = idx; j < numProxies - 1; j++) {
            proxyPool[j] = proxyPool[j + 1];
        }
        proxyPool[numProxies] = null;
    }
    private function insertionSortX(proxyPool:Vector.<Proxy>):void {
        if (numProxies == 1)
            return;
        for (var i:int = 1; i < numProxies; i++) {
            var insert:Proxy = proxyPool[i];
            if (proxyPool[i - 1].minX > insert.minX) {
                var j:int = i;
                do {
                    proxyPool[j] = proxyPool[j - 1];
                    j--;
                } while (j > 0 && proxyPool[j - 1].minX > insert.minX);
                proxyPool[j] = insert;
            }
        }
    }
    private function insertionSortY(proxyPool:Vector.<Proxy>):void {
        if (numProxies == 1)
            return;
        for (var i:int = 1; i < numProxies; i++) {
            var insert:Proxy = proxyPool[i];
            if (proxyPool[i - 1].minY > insert.minY) {
                var j:int = i;
                do {
                    proxyPool[j] = proxyPool[j - 1];
                    j--;
                } while (j > 0 && proxyPool[j - 1].minY > insert.minY);
                proxyPool[j] = insert;
            }
        }
    }
    private function insertionSortZ(proxyPool:Vector.<Proxy>):void {
        if (numProxies == 1)
            return;
        for (var i:int = 1; i < numProxies; i++) {
            var insert:Proxy = proxyPool[i];
            if (proxyPool[i - 1].minZ > insert.minZ) {
                var j:int = i;
                do {
                    proxyPool[j] = proxyPool[j - 1];
                    j--;
                } while (j > 0 && proxyPool[j - 1].minZ > insert.minZ);
                proxyPool[j] = insert;
            }
        }
    }
}
class CollisionDetector {
    public var flip:Boolean;
    public function CollisionDetector() {
    }
    public function detectCollision(shape1:Shape, shape2:Shape, contactInfos:Vector.<ContactInfo>, numContactInfos:uint):uint {
        throw new Error("detectCollision 関数が継承されていません");
        return -1;
    }
}
class BoxBoxCollisionDetector extends CollisionDetector {
    private var clipVertices1:Vector.<Number>;
    private var clipVertices2:Vector.<Number>;
    private var used:Vector.<Boolean>;
    private const INF:Number = 1 / 0;
    public function BoxBoxCollisionDetector() {
        clipVertices1 = new Vector.<Number>(24, true); // 8 vertices x,y,z
        clipVertices2 = new Vector.<Number>(24, true);
        used = new Vector.<Boolean>(8, true);
    }
    override public function detectCollision(shape1:Shape, shape2:Shape, contactInfos:Vector.<ContactInfo>, numContactInfos:uint):uint {
        if (numContactInfos == contactInfos.length) return numContactInfos;
        var b1:BoxShape;
        var b2:BoxShape;
        if (shape1.id < shape2.id) {
            b1 = shape1 as BoxShape;
            b2 = shape2 as BoxShape;
        } else {
            b1 = shape2 as BoxShape;
            b2 = shape1 as BoxShape;
        }
        var p1:Vec3 = b1.position;
        var p2:Vec3 = b2.position;
        var p1x:Number = p1.x;
        var p1y:Number = p1.y;
        var p1z:Number = p1.z;
        var p2x:Number = p2.x;
        var p2y:Number = p2.y;
        var p2z:Number = p2.z;
        // diff
        var dx:Number = p2x - p1x;
        var dy:Number = p2y - p1y;
        var dz:Number = p2z - p1z;
        // distance
        var w1:Number = b1.halfWidth;
        var h1:Number = b1.halfHeight;
        var d1:Number = b1.halfDepth;
        var w2:Number = b2.halfWidth;
        var h2:Number = b2.halfHeight;
        var d2:Number = b2.halfDepth;
        // direction
        var d1x:Number = b1.halfDirectionWidth.x;
        var d1y:Number = b1.halfDirectionWidth.y;
        var d1z:Number = b1.halfDirectionWidth.z;
        // b1.y
        var d2x:Number = b1.halfDirectionHeight.x;
        var d2y:Number = b1.halfDirectionHeight.y;
        var d2z:Number = b1.halfDirectionHeight.z;
        // b1.z
        var d3x:Number = b1.halfDirectionDepth.x;
        var d3y:Number = b1.halfDirectionDepth.y;
        var d3z:Number = b1.halfDirectionDepth.z;
        // b2.x
        var d4x:Number = b2.halfDirectionWidth.x;
        var d4y:Number = b2.halfDirectionWidth.y;
        var d4z:Number = b2.halfDirectionWidth.z;
        // b2.y
        var d5x:Number = b2.halfDirectionHeight.x;
        var d5y:Number = b2.halfDirectionHeight.y;
        var d5z:Number = b2.halfDirectionHeight.z;
        // b2.z
        var d6x:Number = b2.halfDirectionDepth.x;
        var d6y:Number = b2.halfDirectionDepth.y;
        var d6z:Number = b2.halfDirectionDepth.z;
        // b1.x
        var a1x:Number = b1.normalDirectionWidth.x;
        var a1y:Number = b1.normalDirectionWidth.y;
        var a1z:Number = b1.normalDirectionWidth.z;
        // b1.y
        var a2x:Number = b1.normalDirectionHeight.x;
        var a2y:Number = b1.normalDirectionHeight.y;
        var a2z:Number = b1.normalDirectionHeight.z;
        // b1.z
        var a3x:Number = b1.normalDirectionDepth.x;
        var a3y:Number = b1.normalDirectionDepth.y;
        var a3z:Number = b1.normalDirectionDepth.z;
        // b2.x
        var a4x:Number = b2.normalDirectionWidth.x;
        var a4y:Number = b2.normalDirectionWidth.y;
        var a4z:Number = b2.normalDirectionWidth.z;
        // b2.y
        var a5x:Number = b2.normalDirectionHeight.x;
        var a5y:Number = b2.normalDirectionHeight.y;
        var a5z:Number = b2.normalDirectionHeight.z;
        // b2.z
        var a6x:Number = b2.normalDirectionDepth.x;
        var a6y:Number = b2.normalDirectionDepth.y;
        var a6z:Number = b2.normalDirectionDepth.z;
        // b1.x * b2.x
        var a7x:Number = a1y * a4z - a1z * a4y;
        var a7y:Number = a1z * a4x - a1x * a4z;
        var a7z:Number = a1x * a4y - a1y * a4x;
        // b1.x * b2.y
        var a8x:Number = a1y * a5z - a1z * a5y;
        var a8y:Number = a1z * a5x - a1x * a5z;
        var a8z:Number = a1x * a5y - a1y * a5x;
        // b1.x * b2.z
        var a9x:Number = a1y * a6z - a1z * a6y;
        var a9y:Number = a1z * a6x - a1x * a6z;
        var a9z:Number = a1x * a6y - a1y * a6x;
        // b1.y * b2.x
        var aax:Number = a2y * a4z - a2z * a4y;
        var aay:Number = a2z * a4x - a2x * a4z;
        var aaz:Number = a2x * a4y - a2y * a4x;
        // b1.y * b2.y
        var abx:Number = a2y * a5z - a2z * a5y;
        var aby:Number = a2z * a5x - a2x * a5z;
        var abz:Number = a2x * a5y - a2y * a5x;
        // b1.y * b2.z
        var acx:Number = a2y * a6z - a2z * a6y;
        var acy:Number = a2z * a6x - a2x * a6z;
        var acz:Number = a2x * a6y - a2y * a6x;
        // b1.z * b2.x
        var adx:Number = a3y * a4z - a3z * a4y;
        var ady:Number = a3z * a4x - a3x * a4z;
        var adz:Number = a3x * a4y - a3y * a4x;
        // b1.z * b2.y
        var aex:Number = a3y * a5z - a3z * a5y;
        var aey:Number = a3z * a5x - a3x * a5z;
        var aez:Number = a3x * a5y - a3y * a5x;
        // b1.z * b2.z
        var afx:Number = a3y * a6z - a3z * a6y;
        var afy:Number = a3z * a6x - a3x * a6z;
        var afz:Number = a3x * a6y - a3y * a6x;
        // right or left flag
        var right1:Boolean;
        var right2:Boolean;
        var right3:Boolean;
        var right4:Boolean;
        var right5:Boolean;
        var right6:Boolean;
        var right7:Boolean;
        var right8:Boolean;
        var right9:Boolean;
        var righta:Boolean;
        var rightb:Boolean;
        var rightc:Boolean;
        var rightd:Boolean;
        var righte:Boolean;
        var rightf:Boolean;
        // overlap distance
        var overlap1:Number;
        var overlap2:Number;
        var overlap3:Number;
        var overlap4:Number;
        var overlap5:Number;
        var overlap6:Number;
        var overlap7:Number;
        var overlap8:Number;
        var overlap9:Number;
        var overlapa:Number;
        var overlapb:Number;
        var overlapc:Number;
        var overlapd:Number;
        var overlape:Number;
        var overlapf:Number;
        // invalid flag
        var invalid7:Boolean = false;
        var invalid8:Boolean = false;
        var invalid9:Boolean = false;
        var invalida:Boolean = false;
        var invalidb:Boolean = false;
        var invalidc:Boolean = false;
        var invalidd:Boolean = false;
        var invalide:Boolean = false;
        var invalidf:Boolean = false;
        // temporary variables
        var len:Number;
        var len1:Number;
        var len2:Number;
        var dot1:Number;
        var dot2:Number;
        var dot3:Number;
        // try axis 1
        len = a1x * dx + a1y * dy + a1z * dz;
        right1 = len > 0;
        if (!right1) len = -len;
        len1 = w1;
        dot1 = a1x * a4x + a1y * a4y + a1z * a4z;
        dot2 = a1x * a5x + a1y * a5y + a1z * a5z;
        dot3 = a1x * a6x + a1y * a6y + a1z * a6z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len2 = dot1 * w2 + dot2 * h2 + dot3 * d2;
        overlap1 = len - len1 - len2;
        if (overlap1 > 0) return numContactInfos;
        // try axis 2
        len = a2x * dx + a2y * dy + a2z * dz;
        right2 = len > 0;
        if (!right2) len = -len;
        len1 = h1;
        dot1 = a2x * a4x + a2y * a4y + a2z * a4z;
        dot2 = a2x * a5x + a2y * a5y + a2z * a5z;
        dot3 = a2x * a6x + a2y * a6y + a2z * a6z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len2 = dot1 * w2 + dot2 * h2 + dot3 * d2;
        overlap2 = len - len1 - len2;
        if (overlap2 > 0) return numContactInfos;
        // try axis 3
        len = a3x * dx + a3y * dy + a3z * dz;
        right3 = len > 0;
        if (!right3) len = -len;
        len1 = d1;
        dot1 = a3x * a4x + a3y * a4y + a3z * a4z;
        dot2 = a3x * a5x + a3y * a5y + a3z * a5z;
        dot3 = a3x * a6x + a3y * a6y + a3z * a6z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len2 = dot1 * w2 + dot2 * h2 + dot3 * d2;
        overlap3 = len - len1 - len2;
        if (overlap3 > 0) return numContactInfos;
        // try axis 4
        len = a4x * dx + a4y * dy + a4z * dz;
        right4 = len > 0;
        if (!right4) len = -len;
        dot1 = a4x * a1x + a4y * a1y + a4z * a1z;
        dot2 = a4x * a2x + a4y * a2y + a4z * a2z;
        dot3 = a4x * a3x + a4y * a3y + a4z * a3z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len1 = dot1 * w1 + dot2 * h1 + dot3 * d1;
        len2 = w2;
        overlap4 = len - len1 - len2;
        if (overlap4 > 0) return numContactInfos;
        // try axis 5
        len = a5x * dx + a5y * dy + a5z * dz;
        right5 = len > 0;
        if (!right5) len = -len;
        dot1 = a5x * a1x + a5y * a1y + a5z * a1z;
        dot2 = a5x * a2x + a5y * a2y + a5z * a2z;
        dot3 = a5x * a3x + a5y * a3y + a5z * a3z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len1 = dot1 * w1 + dot2 * h1 + dot3 * d1;
        len2 = h2;
        overlap5 = len - len1 - len2;
        if (overlap5 > 0) return numContactInfos;
        // try axis 6
        len = a6x * dx + a6y * dy + a6z * dz;
        right6 = len > 0;
        if (!right6) len = -len;
        dot1 = a6x * a1x + a6y * a1y + a6z * a1z;
        dot2 = a6x * a2x + a6y * a2y + a6z * a2z;
        dot3 = a6x * a3x + a6y * a3y + a6z * a3z;
        if (dot1 < 0) dot1 = -dot1;
        if (dot2 < 0) dot2 = -dot2;
        if (dot3 < 0) dot3 = -dot3;
        len1 = dot1 * w1 + dot2 * h1 + dot3 * d1;
        len2 = d2;
        overlap6 = len - len1 - len2;
        if (overlap6 > 0) return numContactInfos;
        // try axis 7
        len = a7x * a7x + a7y * a7y + a7z * a7z;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            a7x *= len;
            a7y *= len;
            a7z *= len;
            len = a7x * dx + a7y * dy + a7z * dz;
            right7 = len > 0;
            if (!right7) len = -len;
            dot1 = a7x * a2x + a7y * a2y + a7z * a2z;
            dot2 = a7x * a3x + a7y * a3y + a7z * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * h1 + dot2 * d1;
            dot1 = a7x * a5x + a7y * a5y + a7z * a5z;
            dot2 = a7x * a6x + a7y * a6y + a7z * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * h2 + dot2 * d2;
            overlap7 = (len - len1 - len2) * 1.1;
            if (overlap7 > 0) return numContactInfos;
        } else {
            right7 = false;
            overlap7 = 0;
            invalid7 = true;
        }
        // try axis 8
        len = a8x * a8x + a8y * a8y + a8z * a8z;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            a8x *= len;
            a8y *= len;
            a8z *= len;
            len = a8x * dx + a8y * dy + a8z * dz;
            right8 = len > 0;
            if (!right8) len = -len;
            dot1 = a8x * a2x + a8y * a2y + a8z * a2z;
            dot2 = a8x * a3x + a8y * a3y + a8z * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * h1 + dot2 * d1;
            dot1 = a8x * a4x + a8y * a4y + a8z * a4z;
            dot2 = a8x * a6x + a8y * a6y + a8z * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * d2;
            overlap8 = (len - len1 - len2) * 1.1;
            if (overlap8 > 0) return numContactInfos;
        } else {
            right8 = false;
            overlap8 = 0;
            invalid8 = true;
        }
        // try axis 9
        len = a9x * a9x + a9y * a9y + a9z * a9z;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            a9x *= len;
            a9y *= len;
            a9z *= len;
            len = a9x * dx + a9y * dy + a9z * dz;
            right9 = len > 0;
            if (!right9) len = -len;
            dot1 = a9x * a2x + a9y * a2y + a9z * a2z;
            dot2 = a9x * a3x + a9y * a3y + a9z * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * h1 + dot2 * d1;
            dot1 = a9x * a4x + a9y * a4y + a9z * a4z;
            dot2 = a9x * a5x + a9y * a5y + a9z * a5z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * h2;
            overlap9 = (len - len1 - len2) * 1.1;
            if (overlap9 > 0) return numContactInfos;
        } else {
            right9 = false;
            overlap9 = 0;
            invalid9 = true;
        }
        // try axis 10
        len = aax * aax + aay * aay + aaz * aaz;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            aax *= len;
            aay *= len;
            aaz *= len;
            len = aax * dx + aay * dy + aaz * dz;
            righta = len > 0;
            if (!righta) len = -len;
            dot1 = aax * a1x + aay * a1y + aaz * a1z;
            dot2 = aax * a3x + aay * a3y + aaz * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * d1;
            dot1 = aax * a5x + aay * a5y + aaz * a5z;
            dot2 = aax * a6x + aay * a6y + aaz * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * h2 + dot2 * d2;
            overlapa = (len - len1 - len2) * 1.1;
            if (overlapa > 0) return numContactInfos;
        } else {
            righta = false;
            overlapa = 0;
            invalida = true;
        }
        // try axis 11
        len = abx * abx + aby * aby + abz * abz;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            abx *= len;
            aby *= len;
            abz *= len;
            len = abx * dx + aby * dy + abz * dz;
            rightb = len > 0;
            if (!rightb) len = -len;
            dot1 = abx * a1x + aby * a1y + abz * a1z;
            dot2 = abx * a3x + aby * a3y + abz * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * d1;
            dot1 = abx * a4x + aby * a4y + abz * a4z;
            dot2 = abx * a6x + aby * a6y + abz * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * d2;
            overlapb = (len - len1 - len2) * 1.1;
            if (overlapb > 0) return numContactInfos;
        } else {
            rightb = false;
            overlapb = 0;
            invalidb = true;
        }
        // try axis 12
        len = acx * acx + acy * acy + acz * acz;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            acx *= len;
            acy *= len;
            acz *= len;
            len = acx * dx + acy * dy + acz * dz;
            rightc = len > 0;
            if (!rightc) len = -len;
            dot1 = acx * a1x + acy * a1y + acz * a1z;
            dot2 = acx * a3x + acy * a3y + acz * a3z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * d1;
            dot1 = acx * a4x + acy * a4y + acz * a4z;
            dot2 = acx * a5x + acy * a5y + acz * a5z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * h2;
            overlapc = (len - len1 - len2) * 1.1;
            if (overlapc > 0) return numContactInfos;
        } else {
            rightc = false;
            overlapc = 0;
            invalidc = true;
        }
        // try axis 13
        len = adx * adx + ady * ady + adz * adz;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            adx *= len;
            ady *= len;
            adz *= len;
            len = adx * dx + ady * dy + adz * dz;
            rightd = len > 0;
            if (!rightd) len = -len;
            dot1 = adx * a1x + ady * a1y + adz * a1z;
            dot2 = adx * a2x + ady * a2y + adz * a2z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * h1;
            dot1 = adx * a5x + ady * a5y + adz * a5z;
            dot2 = adx * a6x + ady * a6y + adz * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * h2 + dot2 * d2;
            overlapd = (len - len1 - len2) * 1.1;
            if (overlapd > 0) return numContactInfos;
        } else {
            rightd = false;
            overlapd = 0;
            invalidd = true;
        }
        // try axis 14
        len = aex * aex + aey * aey + aez * aez;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            aex *= len;
            aey *= len;
            aez *= len;
            len = aex * dx + aey * dy + aez * dz;
            righte = len > 0;
            if (!righte) len = -len;
            dot1 = aex * a1x + aey * a1y + aez * a1z;
            dot2 = aex * a2x + aey * a2y + aez * a2z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * h1;
            dot1 = aex * a4x + aey * a4y + aez * a4z;
            dot2 = aex * a6x + aey * a6y + aez * a6z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * d2;
            overlape = (len - len1 - len2) * 1.1;
            if (overlape > 0) return numContactInfos;
        } else {
            righte = false;
            overlape = 0;
            invalide = true;
        }
        // try axis 15
        len = afx * afx + afy * afy + afz * afz;
        if (len > 1e-5) {
            len = 1 / Math.sqrt(len);
            afx *= len;
            afy *= len;
            afz *= len;
            len = afx * dx + afy * dy + afz * dz;
            rightf = len > 0;
            if (!rightf) len = -len;
            dot1 = afx * a1x + afy * a1y + afz * a1z;
            dot2 = afx * a2x + afy * a2y + afz * a2z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len1 = dot1 * w1 + dot2 * h1;
            dot1 = afx * a4x + afy * a4y + afz * a4z;
            dot2 = afx * a5x + afy * a5y + afz * a5z;
            if (dot1 < 0) dot1 = -dot1;
            if (dot2 < 0) dot2 = -dot2;
            len2 = dot1 * w2 + dot2 * h2;
            overlapf = (len - len1 - len2) * 1.1;
            if (overlapf > 0) return numContactInfos;
        } else {
            rightf = false;
            overlapf = 0;
            invalidf = true;
        }
        // boxes are overlapping
        var depth:Number = overlap1;
        var minIndex:uint = 0;
        var right:Boolean = right1;
        if (overlap2 > depth) {
            depth = overlap2;
            minIndex = 1;
            right = right2;
        }
        if (overlap3 > depth) {
            depth = overlap3;
            minIndex = 2;
            right = right3;
        }
        if (overlap4 > depth) {
            depth = overlap4;
            minIndex = 3;
            right = right4;
        }
        if (overlap5 > depth) {
            depth = overlap5;
            minIndex = 4;
            right = right5;
        }
        if (overlap6 > depth) {
            depth = overlap6;
            minIndex = 5;
            right = right6;
        }
        if (overlap7 > depth && !invalid7) {
            depth = overlap7;
            minIndex = 6;
            right = right7;
        }
        if (overlap8 > depth && !invalid8) {
            depth = overlap8;
            minIndex = 7;
            right = right8;
        }
        if (overlap9 > depth && !invalid9) {
            depth = overlap9;
            minIndex = 8;
            right = right9;
        }
        if (overlapa > depth && !invalida) {
            depth = overlapa;
            minIndex = 9;
            right = righta;
        }
        if (overlapb > depth && !invalidb) {
            depth = overlapb;
            minIndex = 10;
            right = rightb;
        }
        if (overlapc > depth && !invalidc) {
            depth = overlapc;
            minIndex = 11;
            right = rightc;
        }
        if (overlapd > depth && !invalidd) {
            depth = overlapd;
            minIndex = 12;
            right = rightd;
        }
        if (overlape > depth && !invalide) {
            depth = overlape;
            minIndex = 13;
            right = righte;
        }
        if (overlapf > depth && !invalidf) {
            depth = overlapf;
            minIndex = 14;
            right = rightf;
        }
        // normal
        var nx:Number = 0;
        var ny:Number = 0;
        var nz:Number = 0;
        // edge line or face side normal
        var n1x:Number = 0;
        var n1y:Number = 0;
        var n1z:Number = 0;
        var n2x:Number = 0;
        var n2y:Number = 0;
        var n2z:Number = 0;
        // center of current face
        var cx:Number = 0;
        var cy:Number = 0;
        var cz:Number = 0;
        // face side
        var s1x:Number = 0;
        var s1y:Number = 0;
        var s1z:Number = 0;
        var s2x:Number = 0;
        var s2y:Number = 0;
        var s2z:Number = 0;
        // swap b1 b2
        var swap:Boolean = false;
        switch(minIndex) {
        case 0: // b1.x * b2
            if (right) {
                cx = p1x + d1x;
                cy = p1y + d1y;
                cz = p1z + d1z;
                nx = a1x;
                ny = a1y;
                nz = a1z;
            } else {
                cx = p1x - d1x;
                cy = p1y - d1y;
                cz = p1z - d1z;
                nx = -a1x;
                ny = -a1y;
                nz = -a1z;
            }
            s1x = d2x;
            s1y = d2y;
            s1z = d2z;
            n1x = -a2x;
            n1y = -a2y;
            n1z = -a2z;
            s2x = d3x;
            s2y = d3y;
            s2z = d3z;
            n2x = -a3x;
            n2y = -a3y;
            n2z = -a3z;
            break;
        case 1: // b1.y * b2
            if (right) {
                cx = p1x + d2x;
                cy = p1y + d2y;
                cz = p1z + d2z;
                nx = a2x;
                ny = a2y;
                nz = a2z;
            } else {
                cx = p1x - d2x;
                cy = p1y - d2y;
                cz = p1z - d2z;
                nx = -a2x;
                ny = -a2y;
                nz = -a2z;
            }
            s1x = d1x;
            s1y = d1y;
            s1z = d1z;
            n1x = -a1x;
            n1y = -a1y;
            n1z = -a1z;
            s2x = d3x;
            s2y = d3y;
            s2z = d3z;
            n2x = -a3x;
            n2y = -a3y;
            n2z = -a3z;
            break;
        case 2: // b1.z * b2
            if (right) {
                cx = p1x + d3x;
                cy = p1y + d3y;
                cz = p1z + d3z;
                nx = a3x;
                ny = a3y;
                nz = a3z;
            } else {
                cx = p1x - d3x;
                cy = p1y - d3y;
                cz = p1z - d3z;
                nx = -a3x;
                ny = -a3y;
                nz = -a3z;
            }
            s1x = d1x;
            s1y = d1y;
            s1z = d1z;
            n1x = -a1x;
            n1y = -a1y;
            n1z = -a1z;
            s2x = d2x;
            s2y = d2y;
            s2z = d2z;
            n2x = -a2x;
            n2y = -a2y;
            n2z = -a2z;
            break;
        case 3: // b2.x * b1
            swap = true;
            if (!right) {
                cx = p2x + d4x;
                cy = p2y + d4y;
                cz = p2z + d4z;
                nx = a4x;
                ny = a4y;
                nz = a4z;
            } else {
                cx = p2x - d4x;
                cy = p2y - d4y;
                cz = p2z - d4z;
                nx = -a4x;
                ny = -a4y;
                nz = -a4z;
            }
            s1x = d5x;
            s1y = d5y;
            s1z = d5z;
            n1x = -a5x;
            n1y = -a5y;
            n1z = -a5z;
            s2x = d6x;
            s2y = d6y;
            s2z = d6z;
            n2x = -a6x;
            n2y = -a6y;
            n2z = -a6z;
            break;
        case 4: // b2.y * b1
            swap = true;
            if (!right) {
                cx = p2x + d5x;
                cy = p2y + d5y;
                cz = p2z + d5z;
                nx = a5x;
                ny = a5y;
                nz = a5z;
            } else {
                cx = p2x - d5x;
                cy = p2y - d5y;
                cz = p2z - d5z;
                nx = -a5x;
                ny = -a5y;
                nz = -a5z;
            }
            s1x = d4x;
            s1y = d4y;
            s1z = d4z;
            n1x = -a4x;
            n1y = -a4y;
            n1z = -a4z;
            s2x = d6x;
            s2y = d6y;
            s2z = d6z;
            n2x = -a6x;
            n2y = -a6y;
            n2z = -a6z;
            break;
        case 5: // b2.z * b1
            swap = true;
            if (!right) {
                cx = p2x + d6x;
                cy = p2y + d6y;
                cz = p2z + d6z;
                nx = a6x;
                ny = a6y;
                nz = a6z;
            } else {
                cx = p2x - d6x;
                cy = p2y - d6y;
                cz = p2z - d6z;
                nx = -a6x;
                ny = -a6y;
                nz = -a6z;
            }
            s1x = d4x;
            s1y = d4y;
            s1z = d4z;
            n1x = -a4x;
            n1y = -a4y;
            n1z = -a4z;
            s2x = d5x;
            s2y = d5y;
            s2z = d5z;
            n2x = -a5x;
            n2y = -a5y;
            n2z = -a5z;
            break;
        case 6: // b1.x * b2.x
            nx = a7x;
            ny = a7y;
            nz = a7z;
            n1x = a1x;
            n1y = a1y;
            n1z = a1z;
            n2x = a4x;
            n2y = a4y;
            n2z = a4z;
            break;
        case 7: // b1.x * b2.y
            nx = a8x;
            ny = a8y;
            nz = a8z;
            n1x = a1x;
            n1y = a1y;
            n1z = a1z;
            n2x = a5x;
            n2y = a5y;
            n2z = a5z;
            break;
        case 8: // b1.x * b2.z
            nx = a9x;
            ny = a9y;
            nz = a9z;
            n1x = a1x;
            n1y = a1y;
            n1z = a1z;
            n2x = a6x;
            n2y = a6y;
            n2z = a6z;
            break;
        case 9: // b1.y * b2.x
            nx = aax;
            ny = aay;
            nz = aaz;
            n1x = a2x;
            n1y = a2y;
            n1z = a2z;
            n2x = a4x;
            n2y = a4y;
            n2z = a4z;
            break;
        case 10: // b1.y * b2.y
            nx = abx;
            ny = aby;
            nz = abz;
            n1x = a2x;
            n1y = a2y;
            n1z = a2z;
            n2x = a5x;
            n2y = a5y;
            n2z = a5z;
            break;
        case 11: // b1.y * b2.z
            nx = acx;
            ny = acy;
            nz = acz;
            n1x = a2x;
            n1y = a2y;
            n1z = a2z;
            n2x = a6x;
            n2y = a6y;
            n2z = a6z;
            break;
        case 12: // b1.z * b2.x
            nx = adx;
            ny = ady;
            nz = adz;
            n1x = a3x;
            n1y = a3y;
            n1z = a3z;
            n2x = a4x;
            n2y = a4y;
            n2z = a4z;
            break;
        case 13: // b1.z * b2.y
            nx = aex;
            ny = aey;
            nz = aez;
            n1x = a3x;
            n1y = a3y;
            n1z = a3z;
            n2x = a5x;
            n2y = a5y;
            n2z = a5z;
            break;
        case 14: // b1.z * b2.z
            nx = afx;
            ny = afy;
            nz = afz;
            n1x = a3x;
            n1y = a3y;
            n1z = a3z;
            n2x = a6x;
            n2y = a6y;
            n2z = a6z;
            break;
        }
        var c:ContactInfo;
        var v:Vec3;
        if (minIndex > 5) { // edge-edge collision
            if (!right) {
                nx = -nx;
                ny = -ny;
                nz = -nz;
            }
            // temp
            var distance:Number;
            var maxDistance:Number;
            var vx:Number;
            var vy:Number;
            var vz:Number;
            var v1x:Number;
            var v1y:Number;
            var v1z:Number;
            var v2x:Number;
            var v2y:Number;
            var v2z:Number;
            // get support vertex 1
            v = b1.vertex1;
            v1x = v.x;
            v1y = v.y;
            v1z = v.z;
            maxDistance = nx * v1x + ny * v1y + nz * v1z;
            v = b1.vertex2;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex3;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex4;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex5;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex6;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex7;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            v = b1.vertex8;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance > maxDistance) {
                maxDistance = distance;
                v1x = vx;
                v1y = vy;
                v1z = vz;
            }
            // get support vertex 2
            v = b2.vertex1;
            v2x = v.x;
            v2y = v.y;
            v2z = v.z;
            maxDistance = nx * v2x + ny * v2y + nz * v2z;
            v = b2.vertex2;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex3;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex4;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex5;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex6;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex7;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            v = b2.vertex8;
            vx = v.x;
            vy = v.y;
            vz = v.z;
            distance = nx * vx + ny * vy + nz * vz;
            if (distance < maxDistance) {
                maxDistance = distance;
                v2x = vx;
                v2y = vy;
                v2z = vz;
            }
            // closest point
            vx = v2x - v1x;
            vy = v2y - v1y;
            vz = v2z - v1z;
            dot1 = n1x * n2x + n1y * n2y + n1z * n2z;
            var t:Number = (vx * (n1x - n2x * dot1) + vy * (n1y - n2y * dot1) + vz * (n1z - n2z * dot1)) / (1 - dot1 * dot1);
            if (!contactInfos[numContactInfos]) {
                contactInfos[numContactInfos] = new ContactInfo();
            }
            c = contactInfos[numContactInfos++];
            c.normal.x = nx;
            c.normal.y = ny;
            c.normal.z = nz;
            c.position.x = v1x + n1x * t + nx * depth * 0.5;
            c.position.y = v1y + n1y * t + ny * depth * 0.5;
            c.position.z = v1z + n1z * t + nz * depth * 0.5;
            c.overlap = depth;
            c.shape1 = b1;
            c.shape2 = b2;
            c.id.data1 = 0;
            c.id.data2 = 0;
            c.id.flip = false;
            return numContactInfos;
        }
        // now detect face-face collision...
        // target quad
        var q1x:Number;
        var q1y:Number;
        var q1z:Number;
        var q2x:Number;
        var q2y:Number;
        var q2z:Number;
        var q3x:Number;
        var q3y:Number;
        var q3z:Number;
        var q4x:Number;
        var q4y:Number;
        var q4z:Number;
        // search support face and vertex
        var minDot:Number = 1;
        var dot:Number = 0;
        var minDotIndex:Number = 0;
        if (swap) {
            dot = a1x * nx + a1y * ny + a1z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 0;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 1;
            }
            dot = a2x * nx + a2y * ny + a2z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 2;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 3;
            }
            dot = a3x * nx + a3y * ny + a3z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 4;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 5;
            }
            switch(minDotIndex) {
            case 0: // x+ face
                v = b1.vertex1;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex3;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex4;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex2;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 1: // x- face
                v = b1.vertex6;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex8;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex7;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex5;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 2: // y+ face
                v = b1.vertex5;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex1;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex2;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex6;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 3: // y- face
                v = b1.vertex8;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex4;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex3;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex7;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 4: // z+ face
                v = b1.vertex5;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex7;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex3;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex1;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 5: // z- face
                v = b1.vertex2;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b1.vertex4;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b1.vertex8;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b1.vertex6;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            }
        } else {
            dot = a4x * nx + a4y * ny + a4z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 0;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 1;
            }
            dot = a5x * nx + a5y * ny + a5z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 2;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 3;
            }
            dot = a6x * nx + a6y * ny + a6z * nz;
            if (dot < minDot) {
                minDot = dot;
                minDotIndex = 4;
            }
            if (-dot < minDot) {
                minDot = -dot;
                minDotIndex = 5;
            }
            switch(minDotIndex) {
            case 0: // x+ face
                v = b2.vertex1;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex3;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex4;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex2;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 1: // x- face
                v = b2.vertex6;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex8;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex7;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex5;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 2: // y+ face
                v = b2.vertex5;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex1;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex2;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex6;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 3: // y- face
                v = b2.vertex8;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex4;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex3;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex7;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 4: // z+ face
                v = b2.vertex5;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex7;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex3;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex1;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            case 5: // z- face
                v = b2.vertex2;
                q1x = v.x;
                q1y = v.y;
                q1z = v.z;
                v = b2.vertex4;
                q2x = v.x;
                q2y = v.y;
                q2z = v.z;
                v = b2.vertex8;
                q3x = v.x;
                q3y = v.y;
                q3z = v.z;
                v = b2.vertex6;
                q4x = v.x;
                q4y = v.y;
                q4z = v.z;
                break;
            }
        }
        // clip vertices
        var numClipVertices:uint;
        var numAddedClipVertices:uint;
        var index:uint;
        var x1:Number;
        var y1:Number;
        var z1:Number;
        var x2:Number;
        var y2:Number;
        var z2:Number;
        // i gave up inline-expansion...
        clipVertices1[0] = q1x;
        clipVertices1[1] = q1y;
        clipVertices1[2] = q1z;
        clipVertices1[3] = q2x;
        clipVertices1[4] = q2y;
        clipVertices1[5] = q2z;
        clipVertices1[6] = q3x;
        clipVertices1[7] = q3y;
        clipVertices1[8] = q3z;
        clipVertices1[9] = q4x;
        clipVertices1[10] = q4y;
        clipVertices1[11] = q4z;
        numAddedClipVertices = 0;
        x1 = clipVertices1[9];
        y1 = clipVertices1[10];
        z1 = clipVertices1[11];
        dot1 = (x1 - cx - s1x) * n1x + (y1 - cy - s1y) * n1y + (z1 - cz - s1z) * n1z;
        for (var i:int = 0; i < 4; i++) {
            index = i * 3;
            x2 = clipVertices1[index];
            y2 = clipVertices1[index + 1];
            z2 = clipVertices1[index + 2];
            dot2 = (x2 - cx - s1x) * n1x + (y2 - cy - s1y) * n1y + (z2 - cz - s1z) * n1z;
            if (dot1 > 0) {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices2[index] = x2;
                    clipVertices2[index + 1] = y2;
                    clipVertices2[index + 2] = z2;
                } else {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices2[index] = x1 + (x2 - x1) * t;
                    clipVertices2[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices2[index + 2] = z1 + (z2 - z1) * t;
                }
            } else {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices2[index] = x1 + (x2 - x1) * t;
                    clipVertices2[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices2[index + 2] = z1 + (z2 - z1) * t;
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices2[index] = x2;
                    clipVertices2[index + 1] = y2;
                    clipVertices2[index + 2] = z2;
                }
            }
            x1 = x2;
            y1 = y2;
            z1 = z2;
            dot1 = dot2;
        }
        numClipVertices = numAddedClipVertices;
        if (numClipVertices == 0) return numContactInfos; // what's happened
        numAddedClipVertices = 0;
        index = (numClipVertices - 1) * 3;
        x1 = clipVertices2[index];
        y1 = clipVertices2[index + 1];
        z1 = clipVertices2[index + 2];
        dot1 = (x1 - cx - s2x) * n2x + (y1 - cy - s2y) * n2y + (z1 - cz - s2z) * n2z;
        for (i = 0; i < numClipVertices; i++) {
            index = i * 3;
            x2 = clipVertices2[index];
            y2 = clipVertices2[index + 1];
            z2 = clipVertices2[index + 2];
            dot2 = (x2 - cx - s2x) * n2x + (y2 - cy - s2y) * n2y + (z2 - cz - s2z) * n2z;
            if (dot1 > 0) {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices1[index] = x2;
                    clipVertices1[index + 1] = y2;
                    clipVertices1[index + 2] = z2;
                } else {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices1[index] = x1 + (x2 - x1) * t;
                    clipVertices1[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices1[index + 2] = z1 + (z2 - z1) * t;
                }
            } else {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices1[index] = x1 + (x2 - x1) * t;
                    clipVertices1[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices1[index + 2] = z1 + (z2 - z1) * t;
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices1[index] = x2;
                    clipVertices1[index + 1] = y2;
                    clipVertices1[index + 2] = z2;
                }
            }
            x1 = x2;
            y1 = y2;
            z1 = z2;
            dot1 = dot2;
        }
        numClipVertices = numAddedClipVertices;
        if (numClipVertices == 0) return numContactInfos;
        numAddedClipVertices = 0;
        index = (numClipVertices - 1) * 3;
        x1 = clipVertices1[index];
        y1 = clipVertices1[index + 1];
        z1 = clipVertices1[index + 2];
        dot1 = (x1 - cx + s1x) * -n1x + (y1 - cy + s1y) * -n1y + (z1 - cz + s1z) * -n1z;
        for (i = 0; i < numClipVertices; i++) {
            index = i * 3;
            x2 = clipVertices1[index];
            y2 = clipVertices1[index + 1];
            z2 = clipVertices1[index + 2];
            dot2 = (x2 - cx + s1x) * -n1x + (y2 - cy + s1y) * -n1y + (z2 - cz + s1z) * -n1z;
            if (dot1 > 0) {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices2[index] = x2;
                    clipVertices2[index + 1] = y2;
                    clipVertices2[index + 2] = z2;
                } else {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices2[index] = x1 + (x2 - x1) * t;
                    clipVertices2[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices2[index + 2] = z1 + (z2 - z1) * t;
                }
            } else {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices2[index] = x1 + (x2 - x1) * t;
                    clipVertices2[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices2[index + 2] = z1 + (z2 - z1) * t;
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices2[index] = x2;
                    clipVertices2[index + 1] = y2;
                    clipVertices2[index + 2] = z2;
                }
            }
            x1 = x2;
            y1 = y2;
            z1 = z2;
            dot1 = dot2;
        }
        numClipVertices = numAddedClipVertices;
        if (numClipVertices == 0) return numContactInfos;
        numAddedClipVertices = 0;
        index = (numClipVertices - 1) * 3;
        x1 = clipVertices2[index];
        y1 = clipVertices2[index + 1];
        z1 = clipVertices2[index + 2];
        dot1 = (x1 - cx + s2x) * -n2x + (y1 - cy + s2y) * -n2y + (z1 - cz + s2z) * -n2z;
        for (i = 0; i < numClipVertices; i++) {
            index = i * 3;
            x2 = clipVertices2[index];
            y2 = clipVertices2[index + 1];
            z2 = clipVertices2[index + 2];
            dot2 = (x2 - cx + s2x) * -n2x + (y2 - cy + s2y) * -n2y + (z2 - cz + s2z) * -n2z;
            if (dot1 > 0) {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices1[index] = x2;
                    clipVertices1[index + 1] = y2;
                    clipVertices1[index + 2] = z2;
                } else {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices1[index] = x1 + (x2 - x1) * t;
                    clipVertices1[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices1[index + 2] = z1 + (z2 - z1) * t;
                }
            } else {
                if (dot2 > 0) {
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    t = dot1 / (dot1 - dot2);
                    clipVertices1[index] = x1 + (x2 - x1) * t;
                    clipVertices1[index + 1] = y1 + (y2 - y1) * t;
                    clipVertices1[index + 2] = z1 + (z2 - z1) * t;
                    index = numAddedClipVertices * 3;
                    numAddedClipVertices++;
                    clipVertices1[index] = x2;
                    clipVertices1[index + 1] = y2;
                    clipVertices1[index + 2] = z2;
                }
            }
            x1 = x2;
            y1 = y2;
            z1 = z2;
            dot1 = dot2;
        }
        numClipVertices = numAddedClipVertices;
        if (numClipVertices == 0) return numContactInfos;
        if (numClipVertices > 4) {
            // sweep vertices
            x1 = (q1x + q2x + q3x + q4x) * 0.25;
            y1 = (q1y + q2y + q3y + q4y) * 0.25;
            z1 = (q1z + q2z + q3z + q4z) * 0.25;
            n1x = q1x - x1;
            n1y = q1y - y1;
            n1z = q1z - z1;
            n2x = q2x - x1;
            n2y = q2y - y1;
            n2z = q2z - z1;
            var index1:uint = 0;
            var index2:uint = 0;
            var index3:uint = 0;
            var index4:uint = 0;
            var maxDot:Number = -INF;
            minDot = INF;
            for (i = 0; i < numClipVertices; i++) {
                used[i] = false;
                index = i * 3;
                x1 = clipVertices1[index];
                y1 = clipVertices1[index + 1];
                z1 = clipVertices1[index + 2];
                dot = x1 * n1x + y1 * n1y + z1 * n1z;
                if (dot < minDot) {
                    minDot = dot;
                    index1 = i;
                }
                if (dot > maxDot) {
                    maxDot = dot;
                    index3 = i;
                }
            }
            used[index1] = true;
            used[index3] = true;
            maxDot = -INF;
            minDot = INF;
            for (i = 0; i < numClipVertices; i++) {
                if (used[i]) continue;
                index = i * 3;
                x1 = clipVertices1[index];
                y1 = clipVertices1[index + 1];
                z1 = clipVertices1[index + 2];
                dot = x1 * n2x + y1 * n2y + z1 * n2z;
                if (dot < minDot) {
                    minDot = dot;
                    index2 = i;
                }
                if (dot > maxDot) {
                    maxDot = dot;
                    index4 = i;
                }
            }
            index = index1 * 3;
            x1 = clipVertices1[index];
            y1 = clipVertices1[index + 1];
            z1 = clipVertices1[index + 2];
            dot = (x1 - cx) * nx + (y1 - cy) * ny + (z1 - cz) * nz;
            if (dot < 0) {
                if (!contactInfos[numContactInfos]) {
                    contactInfos[numContactInfos] = new ContactInfo();
                }
                c = contactInfos[numContactInfos++];
                c.normal.x = nx;
                c.normal.y = ny;
                c.normal.z = nz;
                c.position.x = x1;
                c.position.y = y1;
                c.position.z = z1;
                c.overlap = dot;
                if (swap) {
                    c.shape1 = b2;
                    c.shape2 = b1;
                } else {
                    c.shape1 = b1;
                    c.shape2 = b2;
                }
                c.id.data1 = 0;
                c.id.data2 = 0;
                c.id.flip = false;
            }
            index = index2 * 3;
            x1 = clipVertices1[index];
            y1 = clipVertices1[index + 1];
            z1 = clipVertices1[index + 2];
            dot = (x1 - cx) * nx + (y1 - cy) * ny + (z1 - cz) * nz;
            if (dot < 0) {
                if (!contactInfos[numContactInfos]) {
                    contactInfos[numContactInfos] = new ContactInfo();
                }
                c = contactInfos[numContactInfos++];
                c.normal.x = nx;
                c.normal.y = ny;
                c.normal.z = nz;
                c.position.x = x1;
                c.position.y = y1;
                c.position.z = z1;
                c.overlap = dot;
                if (swap) {
                    c.shape1 = b2;
                    c.shape2 = b1;
                } else {
                    c.shape1 = b1;
                    c.shape2 = b2;
                }
                c.id.data1 = 1;
                c.id.data2 = 0;
                c.id.flip = false;
            }
            index = index3 * 3;
            x1 = clipVertices1[index];
            y1 = clipVertices1[index + 1];
            z1 = clipVertices1[index + 2];
            dot = (x1 - cx) * nx + (y1 - cy) * ny + (z1 - cz) * nz;
            if (dot < 0) {
                if (!contactInfos[numContactInfos]) {
                    contactInfos[numContactInfos] = new ContactInfo();
                }
                c = contactInfos[numContactInfos++];
                c.normal.x = nx;
                c.normal.y = ny;
                c.normal.z = nz;
                c.position.x = x1;
                c.position.y = y1;
                c.position.z = z1;
                c.overlap = dot;
                if (swap) {
                    c.shape1 = b2;
                    c.shape2 = b1;
                } else {
                    c.shape1 = b1;
                    c.shape2 = b2;
                }
                c.id.data1 = 2;
                c.id.data2 = 0;
                c.id.flip = false;
            }
            index = index4 * 3;
            x1 = clipVertices1[index];
            y1 = clipVertices1[index + 1];
            z1 = clipVertices1[index + 2];
            dot = (x1 - cx) * nx + (y1 - cy) * ny + (z1 - cz) * nz;
            if (dot < 0) {
                if (!contactInfos[numContactInfos]) {
                    contactInfos[numContactInfos] = new ContactInfo();
                }
                c = contactInfos[numContactInfos++];
                c.normal.x = nx;
                c.normal.y = ny;
                c.normal.z = nz;
                c.position.x = x1;
                c.position.y = y1;
                c.position.z = z1;
                c.overlap = dot;
                if (swap) {
                    c.shape1 = b2;
                    c.shape2 = b1;
                } else {
                    c.shape1 = b1;
                    c.shape2 = b2;
                }
                c.id.data1 = 3;
                c.id.data2 = 0;
                c.id.flip = false;
            }
        } else {
            for (i = 0; i < numClipVertices; i++) {
                index = i * 3;
                x1 = clipVertices1[index];
                y1 = clipVertices1[index + 1];
                z1 = clipVertices1[index + 2];
                dot = (x1 - cx) * nx + (y1 - cy) * ny + (z1 - cz) * nz;
                if (dot < 0) {
                    if (!contactInfos[numContactInfos]) {
                        contactInfos[numContactInfos] = new ContactInfo();
                    }
                    c = contactInfos[numContactInfos++];
                    c.normal.x = nx;
                    c.normal.y = ny;
                    c.normal.z = nz;
                    c.position.x = x1;
                    c.position.y = y1;
                    c.position.z = z1;
                    c.overlap = dot;
                    if (swap) {
                        c.shape1 = b2;
                        c.shape2 = b1;
                    } else {
                        c.shape1 = b1;
                        c.shape2 = b2;
                    }
                    c.id.data1 = i;
                    c.id.data2 = 0;
                    c.id.flip = false;
                }
            }
        }
        return numContactInfos;
    }
}
class ContactID {
    public var data1:uint;
    public var data2:uint;
    public var flip:Boolean;
    public function ContactID() {
    }
    public function equals(id:ContactID):Boolean {
        return flip == id.flip ? data1 == id.data1 && data2 == id.data2 : data2 == id.data1 && data1 == id.data2;
    }
}
class ContactInfo {
        public var position:Vec3;
        public var normal:Vec3;
        public var overlap:Number;
        public var shape1:Shape;
        public var shape2:Shape;
        public var id:ContactID;
        public function ContactInfo() {
            position = new Vec3();
            normal = new Vec3();
            id = new ContactID();
        }
    }
class SphereBoxCollisionDetector extends CollisionDetector {
    public function SphereBoxCollisionDetector(flip:Boolean) {
        this.flip = flip;
    }
    override public function detectCollision(shape1:Shape, shape2:Shape, contactInfos:Vector.<ContactInfo>, numContactInfos:uint):uint {
        if (numContactInfos == contactInfos.length) return numContactInfos;
        var s:SphereShape;
        var b:BoxShape;
        if (flip) {
            s = shape2 as SphereShape;
            b = shape1 as BoxShape;
        } else {
            s = shape1 as SphereShape;
            b = shape2 as BoxShape;
        }
        var ps:Vec3 = s.position;
        var psx:Number = ps.x;
        var psy:Number = ps.y;
        var psz:Number = ps.z;
        var pb:Vec3 = b.position;
        var pbx:Number = pb.x;
        var pby:Number = pb.y;
        var pbz:Number = pb.z;
        var rad:Number = s.radius;
        // normal
        var nw:Vec3 = b.normalDirectionWidth;
        var nh:Vec3 = b.normalDirectionHeight;
        var nd:Vec3 = b.normalDirectionDepth;
        // half
        var hw:Number = b.halfWidth;
        var hh:Number = b.halfHeight;
        var hd:Number = b.halfDepth;
        // diff
        var dx:Number = psx - pbx;
        var dy:Number = psy - pby;
        var dz:Number = psz - pbz;
        // shadow
        var sx:Number = nw.x * dx + nw.y * dy + nw.z * dz;
        var sy:Number = nh.x * dx + nh.y * dy + nh.z * dz;
        var sz:Number = nd.x * dx + nd.y * dy + nd.z * dz;
        // closest
        var cx:Number;
        var cy:Number;
        var cz:Number;
        var len:Number;
        var invLen:Number;
        var c:ContactInfo;
        var overlap:uint = 0;
        if (sx > hw) {
            sx = hw;
        } else if (sx < -hw) {
            sx = -hw;
        } else {
            overlap = 1;
        }
        if (sy > hh) {
            sy = hh;
        } else if (sy < -hh) {
            sy = -hh;
        } else {
            overlap |= 2;
        }
        if (sz > hd) {
            sz = hd;
        } else if (sz < -hd) {
            sz = -hd;
        } else {
            overlap |= 4;
        }
        if (overlap == 7) {
            // center of sphere is in the box
            if (sx < 0) {
                dx = hw + sx;
            } else {
                dx = hw - sx;
            }
            if (sy < 0) {
                dy = hh + sy;
            } else {
                dy = hh - sy;
            }
            if (sz < 0) {
                dz = hd + sz;
            } else {
                dz = hd - sz;
            }
            if (dx < dy) {
                if (dx < dz) {
                    // x
                    len = dx - hw;
                    if (sx < 0) {
                        sx = -hw;
                        dx = nw.x;
                        dy = nw.y;
                        dz = nw.z;
                    } else {
                        sx = hw;
                        dx = -nw.x;
                        dy = -nw.y;
                        dz = -nw.z;
                    }
                } else {
                    // z
                    len = dz - hd;
                    if (sz < 0) {
                        sz = -hd;
                        dx = nd.x;
                        dy = nd.y;
                        dz = nd.z;
                    } else {
                        sz = hd;
                        dx = -nd.x;
                        dy = -nd.y;
                        dz = -nd.z;
                    }
                }
            } else {
                if (dy < dz) {
                    // y
                    len = dy - hh;
                    if (sy < 0) {
                        sy = -hh;
                        dx = nh.x;
                        dy = nh.y;
                        dz = nh.z;
                    } else {
                        sy = hh;
                        dx = -nh.x;
                        dy = -nh.y;
                        dz = -nh.z;
                    }
                } else {
                    // z
                    len = dz - hd;
                    if (sz < 0) {
                        sz = -hd;
                        dx = nd.x;
                        dy = nd.y;
                        dz = nd.z;
                    } else {
                        sz = hd;
                        dx = -nd.x;
                        dy = -nd.y;
                        dz = -nd.z;
                    }
                }
            }
            cx = pbx + sx * nw.x + sy * nh.x + sz * nd.x;
            cy = pby + sx * nw.y + sy * nh.y + sz * nd.y;
            cz = pbz + sx * nw.z + sy * nh.z + sz * nd.z;
            if (!contactInfos[numContactInfos]) {
                contactInfos[numContactInfos] = new ContactInfo();
            }
            c = contactInfos[numContactInfos++];
            c.normal.x = dx;
            c.normal.y = dy;
            c.normal.z = dz;
            c.position.x = psx + rad * dx;
            c.position.y = psy + rad * dy;
            c.position.z = psz + rad * dz;
            c.overlap = len;
            c.shape1 = s;
            c.shape2 = b;
            c.id.data1 = 0;
            c.id.data2 = 0;
            c.id.flip = false;
        } else {
            // closest
            cx = pbx + sx * nw.x + sy * nh.x + sz * nd.x;
            cy = pby + sx * nw.y + sy * nh.y + sz * nd.y;
            cz = pbz + sx * nw.z + sy * nh.z + sz * nd.z;
            dx = cx - ps.x;
            dy = cy - ps.y;
            dz = cz - ps.z;
            len = dx * dx + dy * dy + dz * dz;
            if (len > 0 && len < rad * rad) {
                len = Math.sqrt(len);
                invLen = 1 / len;
                dx *= invLen;
                dy *= invLen;
                dz *= invLen;
                if (!contactInfos[numContactInfos]) {
                    contactInfos[numContactInfos] = new ContactInfo();
                }
                c = contactInfos[numContactInfos++];
                c.normal.x = dx;
                c.normal.y = dy;
                c.normal.z = dz;
                c.position.x = psx + rad * dx;
                c.position.y = psy + rad * dy;
                c.position.z = psz + rad * dz;
                c.overlap = len - rad;
                c.shape1 = s;
                c.shape2 = b;
                c.id.data1 = 0;
                c.id.data2 = 0;
                c.id.flip = false;
            }
        }
        return numContactInfos;
    }
}
class SphereSphereCollisionDetector extends CollisionDetector {
    public function SphereSphereCollisionDetector() {
    }
    override public function detectCollision(shape1:Shape, shape2:Shape, contactInfos:Vector.<ContactInfo>, numContactInfos:uint):uint {
        var s1:SphereShape = shape1 as SphereShape;
        var s2:SphereShape = shape2 as SphereShape;
        var p1:Vec3 = s1.position;
        var p2:Vec3 = s2.position;
        var dx:Number = p2.x - p1.x;
        var dy:Number = p2.y - p1.y;
        var dz:Number = p2.z - p1.z;
        var len:Number = dx * dx + dy * dy + dz * dz;
        var r1:Number = s1.radius;
        var r2:Number = s2.radius;
        var rad:Number = r1 + r2;
        if (len > 0 && len < rad * rad && contactInfos.length > numContactInfos) {
            len = Math.sqrt(len);
            var invLen:Number = 1 / len;
            dx *= invLen;
            dy *= invLen;
            dz *= invLen;
            if (!contactInfos[numContactInfos]) {
                contactInfos[numContactInfos] = new ContactInfo();
            }
            var c:ContactInfo = contactInfos[numContactInfos++];
            c.normal.x = dx;
            c.normal.y = dy;
            c.normal.z = dz;
            c.position.x = p1.x + dx * r1;
            c.position.y = p1.y + dy * r1;
            c.position.z = p1.z + dz * r1;
            c.overlap = len - rad;
            c.shape1 = s1;
            c.shape2 = s2;
            c.id.data1 = 0;
            c.id.data2 = 0;
            c.id.flip = false;
        }
        return numContactInfos;
    }
}
class Shape {
    public static var nextID:uint = 0;
    public static const SHAPE_NULL:uint = 0x0;
    public static const SHAPE_SPHERE:uint = 0x1;
    public static const SHAPE_BOX:uint = 0x2;
    public static const MAX_CONTACTS:uint = 1024;
    public var id:uint;
    public var type:uint;
    public var position:Vec3;
    public var relativePosition:Vec3;
    public var localRelativePosition:Vec3;
    public var rotation:Mat33;
    public var relativeRotation:Mat33;
    public var mass:Number;
    public var localInertia:Mat33;
    public var proxy:Proxy;
    public var friction:Number;
    public var restitution:Number;
    public var parent:RigidBody;
    public var contacts:Vector.<Contact>;
    public var numContacts:uint;
    public function Shape() {
        id = ++nextID;
        position = new Vec3();
        relativePosition = new Vec3();
        localRelativePosition = new Vec3();
        rotation = new Mat33();
        relativeRotation = new Mat33();
        localInertia = new Mat33();
        proxy = new Proxy();
        proxy.parent = this;
        contacts = new Vector.<Contact>(MAX_CONTACTS, true);
    }
    public function updateProxy():void {
        throw new Error("updateProxy メソッドが継承されていません");
    }
}
class BoxShape extends Shape {
    public var width:Number;
    public var halfWidth:Number;
    public var height:Number;
    public var halfHeight:Number;
    public var depth:Number;
    public var halfDepth:Number;
    public var normalDirectionWidth:Vec3;
    public var normalDirectionHeight:Vec3;
    public var normalDirectionDepth:Vec3;
    public var halfDirectionWidth:Vec3;
    public var halfDirectionHeight:Vec3;
    public var halfDirectionDepth:Vec3;
    public var vertex1:Vec3;
    public var vertex2:Vec3;
    public var vertex3:Vec3;
    public var vertex4:Vec3;
    public var vertex5:Vec3;
    public var vertex6:Vec3;
    public var vertex7:Vec3;
    public var vertex8:Vec3;
    public function BoxShape(width:Number, height:Number, depth:Number, config:ShapeConfig) {
        this.width = width;
        halfWidth = width * 0.5;
        this.height = height;
        halfHeight = height * 0.5;
        this.depth = depth;
        halfDepth = depth * 0.5;
        position.copy(config.position);
        rotation.copy(config.rotation);
        friction = config.friction;
        restitution = config.restitution;
        mass = width * height * depth * config.density;
        var inertia:Number = mass / 12;
        localInertia.init(
            inertia * (height * height + depth * depth), 0, 0,
            0, inertia * (width * width + depth * depth), 0,
            0, 0, inertia * (width * width + height * height)
        );
        normalDirectionWidth = new Vec3();
        normalDirectionHeight = new Vec3();
        normalDirectionDepth = new Vec3();
        halfDirectionWidth = new Vec3();
        halfDirectionHeight = new Vec3();
        halfDirectionDepth = new Vec3();
        vertex1 = new Vec3();
        vertex2 = new Vec3();
        vertex3 = new Vec3();
        vertex4 = new Vec3();
        vertex5 = new Vec3();
        vertex6 = new Vec3();
        vertex7 = new Vec3();
        vertex8 = new Vec3();
        type = SHAPE_BOX;
    }
    override public function updateProxy():void {
        normalDirectionWidth.x = rotation.e00;
        normalDirectionWidth.y = rotation.e10;
        normalDirectionWidth.z = rotation.e20;
        normalDirectionHeight.x = rotation.e01;
        normalDirectionHeight.y = rotation.e11;
        normalDirectionHeight.z = rotation.e21;
        normalDirectionDepth.x = rotation.e02;
        normalDirectionDepth.y = rotation.e12;
        normalDirectionDepth.z = rotation.e22;
        halfDirectionWidth.x = rotation.e00 * halfWidth;
        halfDirectionWidth.y = rotation.e10 * halfWidth;
        halfDirectionWidth.z = rotation.e20 * halfWidth;
        halfDirectionHeight.x = rotation.e01 * halfHeight;
        halfDirectionHeight.y = rotation.e11 * halfHeight;
        halfDirectionHeight.z = rotation.e21 * halfHeight;
        halfDirectionDepth.x = rotation.e02 * halfDepth;
        halfDirectionDepth.y = rotation.e12 * halfDepth;
        halfDirectionDepth.z = rotation.e22 * halfDepth;
        var wx:Number = halfDirectionWidth.x;
        var wy:Number = halfDirectionWidth.y;
        var wz:Number = halfDirectionWidth.z;
        var hx:Number = halfDirectionHeight.x;
        var hy:Number = halfDirectionHeight.y;
        var hz:Number = halfDirectionHeight.z;
        var dx:Number = halfDirectionDepth.x;
        var dy:Number = halfDirectionDepth.y;
        var dz:Number = halfDirectionDepth.z;
        var x:Number = position.x;
        var y:Number = position.y;
        var z:Number = position.z;
        vertex1.x = x + wx + hx + dx;
        vertex1.y = y + wy + hy + dy;
        vertex1.z = z + wz + hz + dz;
        vertex2.x = x + wx + hx - dx;
        vertex2.y = y + wy + hy - dy;
        vertex2.z = z + wz + hz - dz;
        vertex3.x = x + wx - hx + dx;
        vertex3.y = y + wy - hy + dy;
        vertex3.z = z + wz - hz + dz;
        vertex4.x = x + wx - hx - dx;
        vertex4.y = y + wy - hy - dy;
        vertex4.z = z + wz - hz - dz;
        vertex5.x = x - wx + hx + dx;
        vertex5.y = y - wy + hy + dy;
        vertex5.z = z - wz + hz + dz;
        vertex6.x = x - wx + hx - dx;
        vertex6.y = y - wy + hy - dy;
        vertex6.z = z - wz + hz - dz;
        vertex7.x = x - wx - hx + dx;
        vertex7.y = y - wy - hy + dy;
        vertex7.z = z - wz - hz + dz;
        vertex8.x = x - wx - hx - dx;
        vertex8.y = y - wy - hy - dy;
        vertex8.z = z - wz - hz - dz;
        var w:Number;
        var h:Number;
        var d:Number;
        if (halfDirectionWidth.x < 0) {
            w = -halfDirectionWidth.x;
        } else {
            w = halfDirectionWidth.x;
        }
        if (halfDirectionWidth.y < 0) {
            h = -halfDirectionWidth.y;
        } else {
            h = halfDirectionWidth.y;
        }
        if (halfDirectionWidth.z < 0) {
            d = -halfDirectionWidth.z;
        } else {
            d = halfDirectionWidth.z;
        }
        if (halfDirectionHeight.x < 0) {
            w -= halfDirectionHeight.x;
        } else {
            w += halfDirectionHeight.x;
        }
        if (halfDirectionHeight.y < 0) {
            h -= halfDirectionHeight.y;
        } else {
            h += halfDirectionHeight.y;
        }
        if (halfDirectionHeight.z < 0) {
            d -= halfDirectionHeight.z;
        } else {
            d += halfDirectionHeight.z;
        }
        if (halfDirectionDepth.x < 0) {
            w -= halfDirectionDepth.x;
        } else {
            w += halfDirectionDepth.x;
        }
        if (halfDirectionDepth.y < 0) {
            h -= halfDirectionDepth.y;
        } else {
            h += halfDirectionDepth.y;
        }
        if (halfDirectionDepth.z < 0) {
            d -= halfDirectionDepth.z;
        } else {
            d += halfDirectionDepth.z;
        }
        proxy.init(
            position.x - w, position.x + w,
            position.y - h, position.y + h,
            position.z - d, position.z + d
        );
    }
}
class ShapeConfig {
    public var position:Vec3;
    public var rotation:Mat33;
    public var friction:Number;
    public var restitution:Number;
    public var density:Number;
    public function ShapeConfig() {
        position = new Vec3();
        rotation = new Mat33();
        friction = 0.5;
        restitution = 0.5;
        density = 1;
    }
}
class SphereShape extends Shape {
    public var radius:Number;
    public function SphereShape(radius:Number, config:ShapeConfig) {
        this.radius = radius;
        position.copy(config.position);
        rotation.copy(config.rotation);
        friction = config.friction;
        restitution = config.restitution;
        mass = 4 / 3 * Math.PI * radius * radius * radius * config.density;
        var inertia:Number = 2 / 5 * radius * radius * mass;
        localInertia.init(
            inertia, 0, 0,
            0, inertia, 0,
            0, 0, inertia
        );
        type = SHAPE_SPHERE;
    }
    override public function updateProxy():void {
        proxy.init(
            position.x - radius, position.x + radius,
            position.y - radius, position.y + radius,
            position.z - radius, position.z + radius
        );
    }
}
class Constraint {
    public var parent:World;
    public function Constraint() {
    }
    public function preSolve(timeStep:Number, invTimeStep:Number):void {
        throw new Error("preSolve メソッドが継承されていません");
    }
    public function solve():void {
        throw new Error("solve メソッドが継承されていません");
    }
    public function postSolve():void {
        throw new Error("postSolve メソッドが継承されていません");
    }
}
class Contact extends Constraint {
    public var position:Vec3;
    public var relativePosition1:Vec3;
    public var relativePosition2:Vec3;
    public var normal:Vec3;
    public var tangent:Vec3;
    public var binormal:Vec3;
    public var overlap:Number;
    public var normalImpulse:Number;
    public var tangentImpulse:Number;
    public var binormalImpulse:Number;
    public var shape1:Shape;
    public var shape2:Shape;
    public var rigid1:RigidBody;
    public var rigid2:RigidBody;
    public var id:ContactID;
    public var warmStarted:Boolean;
    private var lVel1:Vec3;
    private var lVel2:Vec3;
    private var aVel1:Vec3;
    private var aVel2:Vec3;
    private var relPos1X:Number;
    private var relPos1Y:Number;
    private var relPos1Z:Number;
    private var relPos2X:Number;
    private var relPos2Y:Number;
    private var relPos2Z:Number;
    private var relVelX:Number;
    private var relVelY:Number;
    private var relVelZ:Number;
    private var norX:Number;
    private var norY:Number;
    private var norZ:Number;
    private var tanX:Number;
    private var tanY:Number;
    private var tanZ:Number;
    private var binX:Number;
    private var binY:Number;
    private var binZ:Number;
    private var norTorque1X:Number;
    private var norTorque1Y:Number;
    private var norTorque1Z:Number;
    private var norTorque2X:Number;
    private var norTorque2Y:Number;
    private var norTorque2Z:Number;
    private var tanTorque1X:Number;
    private var tanTorque1Y:Number;
    private var tanTorque1Z:Number;
    private var tanTorque2X:Number;
    private var tanTorque2Y:Number;
    private var tanTorque2Z:Number;
    private var binTorque1X:Number;
    private var binTorque1Y:Number;
    private var binTorque1Z:Number;
    private var binTorque2X:Number;
    private var binTorque2Y:Number;
    private var binTorque2Z:Number;
    private var norTorqueUnit1X:Number;
    private var norTorqueUnit1Y:Number;
    private var norTorqueUnit1Z:Number;
    private var norTorqueUnit2X:Number;
    private var norTorqueUnit2Y:Number;
    private var norTorqueUnit2Z:Number;
    private var tanTorqueUnit1X:Number;
    private var tanTorqueUnit1Y:Number;
    private var tanTorqueUnit1Z:Number;
    private var tanTorqueUnit2X:Number;
    private var tanTorqueUnit2Y:Number;
    private var tanTorqueUnit2Z:Number;
    private var binTorqueUnit1X:Number;
    private var binTorqueUnit1Y:Number;
    private var binTorqueUnit1Z:Number;
    private var binTorqueUnit2X:Number;
    private var binTorqueUnit2Y:Number;
    private var binTorqueUnit2Z:Number;
    private var invM1:Number;
    private var invM2:Number;
    private var invI1e00:Number;
    private var invI1e01:Number;
    private var invI1e02:Number;
    private var invI1e10:Number;
    private var invI1e11:Number;
    private var invI1e12:Number;
    private var invI1e20:Number;
    private var invI1e21:Number;
    private var invI1e22:Number;
    private var invI2e00:Number;
    private var invI2e01:Number;
    private var invI2e02:Number;
    private var invI2e10:Number;
    private var invI2e11:Number;
    private var invI2e12:Number;
    private var invI2e20:Number;
    private var invI2e21:Number;
    private var invI2e22:Number;
    private var normalDenominator:Number;
    private var tangentDenominator:Number;
    private var binormalDenominator:Number;
    private var targetNormalVelocity:Number;
    private var targetSeparateVelocity:Number;
    private var friction:Number;
    private var restitution:Number;
    private var relativeVelocity:Vec3;
    private var tmp1:Vec3;
    private var tmp2:Vec3;
    public function Contact() {
        position = new Vec3();
        relativePosition1 = new Vec3();
        relativePosition2 = new Vec3();
        normal = new Vec3();
        tangent = new Vec3();
        binormal = new Vec3();
        id = new ContactID();
        normalImpulse = 0;
        tangentImpulse = 0;
        binormalImpulse = 0;
        relativeVelocity = new Vec3();
        tmp1 = new Vec3();
        tmp2 = new Vec3();
    }
    public function setupFromContactInfo(contactInfo:ContactInfo):void {
        position.x = contactInfo.position.x;
        position.y = contactInfo.position.y;
        position.z = contactInfo.position.z;
        norX = contactInfo.normal.x;
        norY = contactInfo.normal.y;
        norZ = contactInfo.normal.z;
        overlap = contactInfo.overlap;
        shape1 = contactInfo.shape1;
        shape2 = contactInfo.shape2;
        rigid1 = shape1.parent;
        rigid2 = shape2.parent;
        relPos1X = position.x - rigid1.position.x;
        relPos1Y = position.y - rigid1.position.y;
        relPos1Z = position.z - rigid1.position.z;
        relPos2X = position.x - rigid2.position.x;
        relPos2Y = position.y - rigid2.position.y;
        relPos2Z = position.z - rigid2.position.z;
        lVel1 = rigid1.linearVelocity;
        lVel2 = rigid2.linearVelocity;
        aVel1 = rigid1.angularVelocity;
        aVel2 = rigid2.angularVelocity;
        invM1 = rigid1.invertMass;
        invM2 = rigid2.invertMass;
        var tmpI:Mat33;
        tmpI = rigid1.invertInertia;
        invI1e00 = tmpI.e00;
        invI1e01 = tmpI.e01;
        invI1e02 = tmpI.e02;
        invI1e10 = tmpI.e10;
        invI1e11 = tmpI.e11;
        invI1e12 = tmpI.e12;
        invI1e20 = tmpI.e20;
        invI1e21 = tmpI.e21;
        invI1e22 = tmpI.e22;
        tmpI = rigid2.invertInertia;
        invI2e00 = tmpI.e00;
        invI2e01 = tmpI.e01;
        invI2e02 = tmpI.e02;
        invI2e10 = tmpI.e10;
        invI2e11 = tmpI.e11;
        invI2e12 = tmpI.e12;
        invI2e20 = tmpI.e20;
        invI2e21 = tmpI.e21;
        invI2e22 = tmpI.e22;
        id.data1 = contactInfo.id.data1;
        id.data2 = contactInfo.id.data2;
        id.flip = contactInfo.id.flip;
        friction = shape1.friction * shape2.friction;
        restitution = shape1.restitution * shape2.restitution;
        overlap = contactInfo.overlap;
        normalImpulse = 0;
        tangentImpulse = 0;
        binormalImpulse = 0;
        warmStarted = false;
    }
    override public function preSolve(timeStep:Number, invTimeStep:Number):void {
        relVelX = (lVel2.x + aVel2.y * relPos2Z - aVel2.z * relPos2Y) - (lVel1.x + aVel1.y * relPos1Z - aVel1.z * relPos1Y);
        relVelY = (lVel2.y + aVel2.z * relPos2X - aVel2.x * relPos2Z) - (lVel1.y + aVel1.z * relPos1X - aVel1.x * relPos1Z);
        relVelZ = (lVel2.z + aVel2.x * relPos2Y - aVel2.y * relPos2X) - (lVel1.z + aVel1.x * relPos1Y - aVel1.y * relPos1X);
        var rvn:Number = norX * relVelX + norY * relVelY + norZ * relVelZ;
        tanX = relVelX - rvn * norX;
        tanY = relVelY - rvn * norY;
        tanZ = relVelZ - rvn * norZ;
        var len:Number = tanX * tanX + tanY * tanY + tanZ * tanZ;
        if (len > 1e-2) {
            len = 1 / Math.sqrt(len);
        } else {
            tanX = norY * norX - norZ * norZ;
            tanY = norZ * -norY - norX * norX;
            tanZ = norX * norZ + norY * norY;
            len = 1 / Math.sqrt(tanX * tanX + tanY * tanY + tanZ * tanZ);
        }
        tanX *= len;
        tanY *= len;
        tanZ *= len;
        binX = norY * tanZ - norZ * tanY;
        binY = norZ * tanX - norX * tanZ;
        binZ = norX * tanY - norY * tanX;
        norTorque1X = relPos1Y * norZ - relPos1Z * norY;
        norTorque1Y = relPos1Z * norX - relPos1X * norZ;
        norTorque1Z = relPos1X * norY - relPos1Y * norX;
        norTorque2X = relPos2Y * norZ - relPos2Z * norY;
        norTorque2Y = relPos2Z * norX - relPos2X * norZ;
        norTorque2Z = relPos2X * norY - relPos2Y * norX;
        tanTorque1X = relPos1Y * tanZ - relPos1Z * tanY;
        tanTorque1Y = relPos1Z * tanX - relPos1X * tanZ;
        tanTorque1Z = relPos1X * tanY - relPos1Y * tanX;
        tanTorque2X = relPos2Y * tanZ - relPos2Z * tanY;
        tanTorque2Y = relPos2Z * tanX - relPos2X * tanZ;
        tanTorque2Z = relPos2X * tanY - relPos2Y * tanX;
        binTorque1X = relPos1Y * binZ - relPos1Z * binY;
        binTorque1Y = relPos1Z * binX - relPos1X * binZ;
        binTorque1Z = relPos1X * binY - relPos1Y * binX;
        binTorque2X = relPos2Y * binZ - relPos2Z * binY;
        binTorque2Y = relPos2Z * binX - relPos2X * binZ;
        binTorque2Z = relPos2X * binY - relPos2Y * binX;
        norTorqueUnit1X = norTorque1X * invI1e00 + norTorque1Y * invI1e01 + norTorque1Z * invI1e02;
        norTorqueUnit1Y = norTorque1X * invI1e10 + norTorque1Y * invI1e11 + norTorque1Z * invI1e12;
        norTorqueUnit1Z = norTorque1X * invI1e20 + norTorque1Y * invI1e21 + norTorque1Z * invI1e22;
        norTorqueUnit2X = norTorque2X * invI2e00 + norTorque2Y * invI2e01 + norTorque2Z * invI2e02;
        norTorqueUnit2Y = norTorque2X * invI2e10 + norTorque2Y * invI2e11 + norTorque2Z * invI2e12;
        norTorqueUnit2Z = norTorque2X * invI2e20 + norTorque2Y * invI2e21 + norTorque2Z * invI2e22;
        tanTorqueUnit1X = tanTorque1X * invI1e00 + tanTorque1Y * invI1e01 + tanTorque1Z * invI1e02;
        tanTorqueUnit1Y = tanTorque1X * invI1e10 + tanTorque1Y * invI1e11 + tanTorque1Z * invI1e12;
        tanTorqueUnit1Z = tanTorque1X * invI1e20 + tanTorque1Y * invI1e21 + tanTorque1Z * invI1e22;
        tanTorqueUnit2X = tanTorque2X * invI2e00 + tanTorque2Y * invI2e01 + tanTorque2Z * invI2e02;
        tanTorqueUnit2Y = tanTorque2X * invI2e10 + tanTorque2Y * invI2e11 + tanTorque2Z * invI2e12;
        tanTorqueUnit2Z = tanTorque2X * invI2e20 + tanTorque2Y * invI2e21 + tanTorque2Z * invI2e22;
        binTorqueUnit1X = binTorque1X * invI1e00 + binTorque1Y * invI1e01 + binTorque1Z * invI1e02;
        binTorqueUnit1Y = binTorque1X * invI1e10 + binTorque1Y * invI1e11 + binTorque1Z * invI1e12;
        binTorqueUnit1Z = binTorque1X * invI1e20 + binTorque1Y * invI1e21 + binTorque1Z * invI1e22;
        binTorqueUnit2X = binTorque2X * invI2e00 + binTorque2Y * invI2e01 + binTorque2Z * invI2e02;
        binTorqueUnit2Y = binTorque2X * invI2e10 + binTorque2Y * invI2e11 + binTorque2Z * invI2e12;
        binTorqueUnit2Z = binTorque2X * invI2e20 + binTorque2Y * invI2e21 + binTorque2Z * invI2e22;
        var tmp1X:Number;
        var tmp1Y:Number;
        var tmp1Z:Number;
        var tmp2X:Number;
        var tmp2Y:Number;
        var tmp2Z:Number;
        tmp1X = norTorque1X * invI1e00 + norTorque1Y * invI1e01 + norTorque1Z * invI1e02;
        tmp1Y = norTorque1X * invI1e10 + norTorque1Y * invI1e11 + norTorque1Z * invI1e12;
        tmp1Z = norTorque1X * invI1e20 + norTorque1Y * invI1e21 + norTorque1Z * invI1e22;
        tmp2X = tmp1Y * relPos1Z - tmp1Z * relPos1Y;
        tmp2Y = tmp1Z * relPos1X - tmp1X * relPos1Z;
        tmp2Z = tmp1X * relPos1Y - tmp1Y * relPos1X;
        tmp1X = norTorque2X * invI2e00 + norTorque2Y * invI2e01 + norTorque2Z * invI2e02;
        tmp1Y = norTorque2X * invI2e10 + norTorque2Y * invI2e11 + norTorque2Z * invI2e12;
        tmp1Z = norTorque2X * invI2e20 + norTorque2Y * invI2e21 + norTorque2Z * invI2e22;
        tmp2X += tmp1Y * relPos2Z - tmp1Z * relPos2Y;
        tmp2Y += tmp1Z * relPos2X - tmp1X * relPos2Z;
        tmp2Z += tmp1X * relPos2Y - tmp1Y * relPos2X;
        normalDenominator = 1 / (invM1 + invM2 + norX * tmp2X + norY * tmp2Y + norZ * tmp2Z);
        tmp1X = tanTorque1X * invI1e00 + tanTorque1Y * invI1e01 + tanTorque1Z * invI1e02;
        tmp1Y = tanTorque1X * invI1e10 + tanTorque1Y * invI1e11 + tanTorque1Z * invI1e12;
        tmp1Z = tanTorque1X * invI1e20 + tanTorque1Y * invI1e21 + tanTorque1Z * invI1e22;
        tmp2X = tmp1Y * relPos1Z - tmp1Z * relPos1Y;
        tmp2Y = tmp1Z * relPos1X - tmp1X * relPos1Z;
        tmp2Z = tmp1X * relPos1Y - tmp1Y * relPos1X;
        tmp1X = tanTorque2X * invI2e00 + tanTorque2Y * invI2e01 + tanTorque2Z * invI2e02;
        tmp1Y = tanTorque2X * invI2e10 + tanTorque2Y * invI2e11 + tanTorque2Z * invI2e12;
        tmp1Z = tanTorque2X * invI2e20 + tanTorque2Y * invI2e21 + tanTorque2Z * invI2e22;
        tmp2X += tmp1Y * relPos2Z - tmp1Z * relPos2Y;
        tmp2Y += tmp1Z * relPos2X - tmp1X * relPos2Z;
        tmp2Z += tmp1X * relPos2Y - tmp1Y * relPos2X;
        tangentDenominator = 1 / (invM1 + invM2 + tanX * tmp2X + tanY * tmp2Y + tanZ * tmp2Z);
        tmp1X = binTorque1X * invI1e00 + binTorque1Y * invI1e01 + binTorque1Z * invI1e02;
        tmp1Y = binTorque1X * invI1e10 + binTorque1Y * invI1e11 + binTorque1Z * invI1e12;
        tmp1Z = binTorque1X * invI1e20 + binTorque1Y * invI1e21 + binTorque1Z * invI1e22;
        tmp2X = tmp1Y * relPos1Z - tmp1Z * relPos1Y;
        tmp2Y = tmp1Z * relPos1X - tmp1X * relPos1Z;
        tmp2Z = tmp1X * relPos1Y - tmp1Y * relPos1X;
        tmp1X = binTorque2X * invI2e00 + binTorque2Y * invI2e01 + binTorque2Z * invI2e02;
        tmp1Y = binTorque2X * invI2e10 + binTorque2Y * invI2e11 + binTorque2Z * invI2e12;
        tmp1Z = binTorque2X * invI2e20 + binTorque2Y * invI2e21 + binTorque2Z * invI2e22;
        tmp2X += tmp1Y * relPos2Z - tmp1Z * relPos2Y;
        tmp2Y += tmp1Z * relPos2X - tmp1X * relPos2Z;
        tmp2Z += tmp1X * relPos2Y - tmp1Y * relPos2X;
        binormalDenominator = 1 / (invM1 + invM2 + binX * tmp2X + binY * tmp2Y + binZ * tmp2Z);
        if (warmStarted) {
            tmp1X = norX * normalImpulse + tanX * tangentImpulse + binX * binormalImpulse;
            tmp1Y = norY * normalImpulse + tanY * tangentImpulse + binY * binormalImpulse;
            tmp1Z = norZ * normalImpulse + tanZ * tangentImpulse + binZ * binormalImpulse;
            lVel1.x += tmp1X * invM1;
            lVel1.y += tmp1Y * invM1;
            lVel1.z += tmp1Z * invM1;
            aVel1.x += norTorqueUnit1X * normalImpulse + tanTorqueUnit1X * tangentImpulse + binTorqueUnit1X * binormalImpulse;
            aVel1.y += norTorqueUnit1Y * normalImpulse + tanTorqueUnit1Y * tangentImpulse + binTorqueUnit1Y * binormalImpulse;
            aVel1.z += norTorqueUnit1Z * normalImpulse + tanTorqueUnit1Z * tangentImpulse + binTorqueUnit1Z * binormalImpulse;
            lVel2.x -= tmp1X * invM2;
            lVel2.y -= tmp1Y * invM2;
            lVel2.z -= tmp1Z * invM2;
            aVel2.x -= norTorqueUnit2X * normalImpulse + tanTorqueUnit2X * tangentImpulse + binTorqueUnit2X * binormalImpulse;
            aVel2.y -= norTorqueUnit2Y * normalImpulse + tanTorqueUnit2Y * tangentImpulse + binTorqueUnit2Y * binormalImpulse;
            aVel2.z -= norTorqueUnit2Z * normalImpulse + tanTorqueUnit2Z * tangentImpulse + binTorqueUnit2Z * binormalImpulse;
            rvn = 0; // disabling bounce
        }
        if (rvn > -1) {
            rvn = 0; // disabling bounce
        }
        targetNormalVelocity = restitution * -rvn;
        var separationalVelocity:Number = -overlap - 0.05; // allow 5cm overlap
        if (separationalVelocity > 0) {
            separationalVelocity *= invTimeStep * 0.05;
            if (targetNormalVelocity < separationalVelocity) {
                targetNormalVelocity = separationalVelocity;
            }
        }
    }
    override public function solve():void {
        var oldImpulse1:Number;
        var newImpulse1:Number;
        var oldImpulse2:Number;
        var newImpulse2:Number;
        var rvn:Number;
        var forceX:Number;
        var forceY:Number;
        var forceZ:Number;
        var tmpX:Number;
        var tmpY:Number;
        var tmpZ:Number;
        rvn = 
            (lVel2.x - lVel1.x) * norX + (lVel2.y - lVel1.y) * norY + (lVel2.z - lVel1.z) * norZ +
            aVel2.x * norTorque2X + aVel2.y * norTorque2Y + aVel2.z * norTorque2Z -
            aVel1.x * norTorque1X - aVel1.y * norTorque1Y - aVel1.z * norTorque1Z
        ;
        oldImpulse1 = normalImpulse;
        newImpulse1 = (rvn - targetNormalVelocity) * normalDenominator;
        normalImpulse += newImpulse1;
        if (normalImpulse > 0) normalImpulse = 0;
        newImpulse1 = normalImpulse - oldImpulse1;
        forceX = norX * newImpulse1;
        forceY = norY * newImpulse1;
        forceZ = norZ * newImpulse1;
        lVel1.x += forceX * invM1;
        lVel1.y += forceY * invM1;
        lVel1.z += forceZ * invM1;
        aVel1.x += norTorqueUnit1X * newImpulse1;
        aVel1.y += norTorqueUnit1Y * newImpulse1;
        aVel1.z += norTorqueUnit1Z * newImpulse1;
        lVel2.x -= forceX * invM2;
        lVel2.y -= forceY * invM2;
        lVel2.z -= forceZ * invM2;
        aVel2.x -= norTorqueUnit2X * newImpulse1;
        aVel2.y -= norTorqueUnit2Y * newImpulse1;
        aVel2.z -= norTorqueUnit2Z * newImpulse1;
        var max:Number = -normalImpulse * friction;
        relVelX = lVel2.x - lVel1.x;
        relVelY = lVel2.y - lVel1.y;
        relVelZ = lVel2.z - lVel1.z;
        rvn =
            relVelX * tanX + relVelY * tanY + relVelZ * tanZ +
            aVel2.x * tanTorque2X + aVel2.y * tanTorque2Y + aVel2.z * tanTorque2Z -
            aVel1.x * tanTorque1X - aVel1.y * tanTorque1Y - aVel1.z * tanTorque1Z
        ;
        oldImpulse1 = tangentImpulse;
        newImpulse1 = rvn * tangentDenominator;
        tangentImpulse += newImpulse1;
        rvn =
            relVelX * binX + relVelY * binY + relVelZ * binZ +
            aVel2.x * binTorque2X + aVel2.y * binTorque2Y + aVel2.z * binTorque2Z -
            aVel1.x * binTorque1X - aVel1.y * binTorque1Y - aVel1.z * binTorque1Z
        ;
        oldImpulse2 = binormalImpulse;
        newImpulse2 = rvn * binormalDenominator;
        binormalImpulse += newImpulse2;
        var len:Number = tangentImpulse * tangentImpulse + binormalImpulse * binormalImpulse;
        if (len > max * max) {
            len = max / Math.sqrt(len);
            tangentImpulse *= len;
            binormalImpulse *= len;
        }
        newImpulse1 = tangentImpulse - oldImpulse1;
        newImpulse2 = binormalImpulse - oldImpulse2;
        forceX = tanX * newImpulse1 + binX * newImpulse2;
        forceY = tanY * newImpulse1 + binY * newImpulse2;
        forceZ = tanZ * newImpulse1 + binZ * newImpulse2;
        lVel1.x += forceX * invM1;
        lVel1.y += forceY * invM1;
        lVel1.z += forceZ * invM1;
        aVel1.x += tanTorqueUnit1X * newImpulse1 + binTorqueUnit1X * newImpulse2;
        aVel1.y += tanTorqueUnit1Y * newImpulse1 + binTorqueUnit1Y * newImpulse2;
        aVel1.z += tanTorqueUnit1Z * newImpulse1 + binTorqueUnit1Z * newImpulse2;
        lVel2.x -= forceX * invM2;
        lVel2.y -= forceY * invM2;
        lVel2.z -= forceZ * invM2;
        aVel2.x -= tanTorqueUnit2X * newImpulse1 + binTorqueUnit2X * newImpulse2;
        aVel2.y -= tanTorqueUnit2Y * newImpulse1 + binTorqueUnit2Y * newImpulse2;
        aVel2.z -= tanTorqueUnit2Z * newImpulse1 + binTorqueUnit2Z * newImpulse2;
    }
    override public function postSolve():void {
        if (shape1.numContacts < Shape.MAX_CONTACTS) {
            shape1.contacts[shape1.numContacts++] = this;
        }
        if (shape2.numContacts < Shape.MAX_CONTACTS) {
            shape2.contacts[shape2.numContacts++] = this;
        }
        relativePosition1.x = relPos1X;
        relativePosition1.y = relPos1Y;
        relativePosition1.z = relPos1Z;
        relativePosition2.x = relPos2X;
        relativePosition2.y = relPos2Y;
        relativePosition2.z = relPos2Z;
        relativeVelocity.x = (lVel2.x + aVel2.y * relPos2Z - aVel2.z * relPos2Y) - (lVel1.x + aVel1.y * relPos1Z - aVel1.z * relPos1Y);
        relativeVelocity.y = (lVel2.y + aVel2.z * relPos2X - aVel2.x * relPos2Z) - (lVel1.y + aVel1.z * relPos1X - aVel1.x * relPos1Z);
        relativeVelocity.z = (lVel2.z + aVel2.x * relPos2Y - aVel2.y * relPos2X) - (lVel1.z + aVel1.x * relPos1Y - aVel1.y * relPos1X);
        normal.x = norX;
        normal.y = norY;
        normal.z = norZ;
        tangent.x = tanX;
        tangent.y = tanY;
        tangent.z = tanZ;
        binormal.x = binX;
        binormal.y = binY;
        binormal.z = binZ;
    }
}
class RigidBody {
    public static const BODY_DYNAMIC:uint = 0x0;
    public static const BODY_STATIC:uint = 0x1;
    public static const MAX_SHAPES:uint = 64;
    public var type:uint;
    public var position:Vec3;
    public var linearVelocity:Vec3;
    public var orientation:Quat;
    public var rotation:Mat33;
    public var angularVelocity:Vec3;
    public var mass:Number;
    public var invertMass:Number;
    public var invertInertia:Mat33;
    public var localInertia:Mat33;
    public var invertLocalInertia:Mat33;
    public var shapes:Vector.<Shape>;
    public var numShapes:uint;
    public var parent:World;
    public function RigidBody(rad:Number = 0, ax:Number = 0, ay:Number = 0, az:Number = 0) {
        position = new Vec3();
        linearVelocity = new Vec3();
        var len:Number = ax * ax + ay * ay + az * az;
        if (len > 0) {
            len = 1 / Math.sqrt(len);
            ax *= len;
            ay *= len;
            az *= len;
        }
        var sin:Number = Math.sin(rad * 0.5);
        var cos:Number = Math.cos(rad * 0.5);
        orientation = new Quat(cos, sin * ax, sin * ay, sin * az);
        rotation = new Mat33();
        angularVelocity = new Vec3();
        invertInertia = new Mat33();
        localInertia = new Mat33();
        invertLocalInertia = new Mat33();
        shapes = new Vector.<Shape>(MAX_SHAPES, true);
    }
    public function addShape(shape:Shape):void {
        if (numShapes == MAX_SHAPES) {
            throw new Error("これ以上剛体に形状を追加することはできません");
        }
        if (shape.parent) {
            throw new Error("一つの形状を複数剛体に追加することはできません");
        }
        shapes[numShapes++] = shape;
        shape.parent = this;
        if (parent) {
            parent.addShape(shape);
        }
    }
    public function removeShape(shape:Shape, index:int = -1):void {
        if (index < 0) {
            for (var i:int = 0; i < numShapes; i++) {
                if (shape == shapes[i]) {
                    index = i;
                    break;
                }
            }
            if (index == -1) {
                return;
            }
        } else if (index >= numShapes) {
            throw new Error("削除する形状のインデックスが範囲外です");
        }
        var remove:Shape = shapes[index];
        remove.parent = null;
        if (parent) {
            parent.removeShape(remove);
        }
        for (var j:int = index; j < numShapes - 1; j++) {
            shapes[j] = shapes[j + 1];
        }
        shapes[--numShapes] = null;
    }
    public function setupMass(type:uint = BODY_DYNAMIC):void {
        this.type = type;
        position.init();
        mass = 0;
        localInertia.init(0, 0, 0, 0, 0, 0, 0, 0, 0);
        var invRot:Mat33 = new Mat33(); // = rotation ^ -1
        invRot.transpose(rotation);
        var tmpM:Mat33 = new Mat33();
        var tmpV:Vec3 = new Vec3();
        var denom:Number = 0;
        for (var i:int = 0; i < numShapes; i++) {
            var shape:Shape = shapes[i];
            // relativeRotation = (rotation ^ -1) * shape.rotation
            shape.relativeRotation.mul(invRot, shape.rotation);
            position.add(position, tmpV.scale(shape.position, shape.mass));
            denom += shape.mass;
            mass += shape.mass;
            // inertia = rotation * localInertia * (rotation ^ -1)
            tmpM.mul(shape.relativeRotation, tmpM.mul(shape.localInertia, tmpM.transpose(shape.relativeRotation)));
            localInertia.add(localInertia, tmpM);
        }
        position.scale(position, 1 / denom);
        invertMass = 1 / mass;
        var xy:Number = 0;
        var yz:Number = 0;
        var zx:Number = 0;
        for (var j:int = 0; j < numShapes; j++) {
            shape = shapes[j];
            var relPos:Vec3 = shape.localRelativePosition;
            relPos.sub(shape.position, position).mulMat(invRot, relPos);
            shape.updateProxy();
            localInertia.e00 += shape.mass * (relPos.y * relPos.y + relPos.z * relPos.z);
            localInertia.e11 += shape.mass * (relPos.x * relPos.x + relPos.z * relPos.z);
            localInertia.e22 += shape.mass * (relPos.x * relPos.x + relPos.y * relPos.y);
            xy -= shape.mass * relPos.x * relPos.y;
            yz -= shape.mass * relPos.y * relPos.z;
            zx -= shape.mass * relPos.z * relPos.x;
        }
        localInertia.e01 = xy;
        localInertia.e10 = xy;
        localInertia.e02 = zx;
        localInertia.e20 = zx;
        localInertia.e12 = yz;
        localInertia.e21 = yz;
        invertLocalInertia.invert(localInertia);
        if (type == BODY_STATIC) {
            invertMass = 0;
            invertLocalInertia.init(0, 0, 0, 0, 0, 0, 0, 0, 0);
        }
        var r00:Number = rotation.e00;
        var r01:Number = rotation.e01;
        var r02:Number = rotation.e02;
        var r10:Number = rotation.e10;
        var r11:Number = rotation.e11;
        var r12:Number = rotation.e12;
        var r20:Number = rotation.e20;
        var r21:Number = rotation.e21;
        var r22:Number = rotation.e22;
        var i00:Number = invertLocalInertia.e00;
        var i01:Number = invertLocalInertia.e01;
        var i02:Number = invertLocalInertia.e02;
        var i10:Number = invertLocalInertia.e10;
        var i11:Number = invertLocalInertia.e11;
        var i12:Number = invertLocalInertia.e12;
        var i20:Number = invertLocalInertia.e20;
        var i21:Number = invertLocalInertia.e21;
        var i22:Number = invertLocalInertia.e22;
        var e00:Number = r00 * i00 + r01 * i10 + r02 * i20;
        var e01:Number = r00 * i01 + r01 * i11 + r02 * i21;
        var e02:Number = r00 * i02 + r01 * i12 + r02 * i22;
        var e10:Number = r10 * i00 + r11 * i10 + r12 * i20;
        var e11:Number = r10 * i01 + r11 * i11 + r12 * i21;
        var e12:Number = r10 * i02 + r11 * i12 + r12 * i22;
        var e20:Number = r20 * i00 + r21 * i10 + r22 * i20;
        var e21:Number = r20 * i01 + r21 * i11 + r22 * i21;
        var e22:Number = r20 * i02 + r21 * i12 + r22 * i22;
        invertInertia.e00 = e00 * r00 + e01 * r01 + e02 * r02;
        invertInertia.e01 = e00 * r10 + e01 * r11 + e02 * r12;
        invertInertia.e02 = e00 * r20 + e01 * r21 + e02 * r22;
        invertInertia.e10 = e10 * r00 + e11 * r01 + e12 * r02;
        invertInertia.e11 = e10 * r10 + e11 * r11 + e12 * r12;
        invertInertia.e12 = e10 * r20 + e11 * r21 + e12 * r22;
        invertInertia.e20 = e20 * r00 + e21 * r01 + e22 * r02;
        invertInertia.e21 = e20 * r10 + e21 * r11 + e22 * r12;
        invertInertia.e22 = e20 * r20 + e21 * r21 + e22 * r22;
    }
    public function updateVelocity(timeStep:Number, gravity:Vec3):void {
        if (type == BODY_DYNAMIC) {
            linearVelocity.x += gravity.x * timeStep;
            linearVelocity.y += gravity.y * timeStep;
            linearVelocity.z += gravity.z * timeStep;
        }
    }
    public function updatePosition(timeStep:Number):void {
        var s:Number;
        var x:Number;
        var y:Number;
        var z:Number;
        if (type == BODY_STATIC) {
            linearVelocity.x = 0;
            linearVelocity.y = 0;
            linearVelocity.z = 0;
            angularVelocity.x = 0;
            angularVelocity.y = 0;
            angularVelocity.z = 0;
        } else if (type == BODY_DYNAMIC) {
            position.x += linearVelocity.x * timeStep;
            position.y += linearVelocity.y * timeStep;
            position.z += linearVelocity.z * timeStep;
            var ax:Number = angularVelocity.x;
            var ay:Number = angularVelocity.y;
            var az:Number = angularVelocity.z;
            var os:Number = orientation.s;
            var ox:Number = orientation.x;
            var oy:Number = orientation.y;
            var oz:Number = orientation.z;
            timeStep *= 0.5;
            s = (-ax * ox - ay * oy - az * oz) * timeStep;
            x = (ax * os + ay * oz - az * oy) * timeStep;
            y = (-ax * oz + ay * os + az * ox) * timeStep;
            z = (ax * oy - ay * ox + az * os) * timeStep;
            os += s;
            ox += x;
            oy += y;
            oz += z;
            s = 1 / Math.sqrt(os * os + ox * ox + oy * oy + oz * oz);
            orientation.s = os * s;
            orientation.x = ox * s;
            orientation.y = oy * s;
            orientation.z = oz * s;
        } else {
            throw new Error("未定義の剛体の種類です");
        }
        s = orientation.s;
        x = orientation.x;
        y = orientation.y;
        z = orientation.z;
        var x2:Number = 2 * x;
        var y2:Number = 2 * y;
        var z2:Number = 2 * z;
        var xx:Number = x * x2;
        var yy:Number = y * y2;
        var zz:Number = z * z2;
        var xy:Number = x * y2;
        var yz:Number = y * z2;
        var xz:Number = x * z2;
        var sx:Number = s * x2;
        var sy:Number = s * y2;
        var sz:Number = s * z2;
        rotation.e00 = 1 - yy - zz;
        rotation.e01 = xy - sz;
        rotation.e02 = xz + sy;
        rotation.e10 = xy + sz;
        rotation.e11 = 1 - xx - zz;
        rotation.e12 = yz - sx;
        rotation.e20 = xz - sy;
        rotation.e21 = yz + sx;
        rotation.e22 = 1 - xx - yy;
        var r00:Number = rotation.e00;
        var r01:Number = rotation.e01;
        var r02:Number = rotation.e02;
        var r10:Number = rotation.e10;
        var r11:Number = rotation.e11;
        var r12:Number = rotation.e12;
        var r20:Number = rotation.e20;
        var r21:Number = rotation.e21;
        var r22:Number = rotation.e22;
        var i00:Number = invertLocalInertia.e00;
        var i01:Number = invertLocalInertia.e01;
        var i02:Number = invertLocalInertia.e02;
        var i10:Number = invertLocalInertia.e10;
        var i11:Number = invertLocalInertia.e11;
        var i12:Number = invertLocalInertia.e12;
        var i20:Number = invertLocalInertia.e20;
        var i21:Number = invertLocalInertia.e21;
        var i22:Number = invertLocalInertia.e22;
        var e00:Number = r00 * i00 + r01 * i10 + r02 * i20;
        var e01:Number = r00 * i01 + r01 * i11 + r02 * i21;
        var e02:Number = r00 * i02 + r01 * i12 + r02 * i22;
        var e10:Number = r10 * i00 + r11 * i10 + r12 * i20;
        var e11:Number = r10 * i01 + r11 * i11 + r12 * i21;
        var e12:Number = r10 * i02 + r11 * i12 + r12 * i22;
        var e20:Number = r20 * i00 + r21 * i10 + r22 * i20;
        var e21:Number = r20 * i01 + r21 * i11 + r22 * i21;
        var e22:Number = r20 * i02 + r21 * i12 + r22 * i22;
        invertInertia.e00 = e00 * r00 + e01 * r01 + e02 * r02;
        invertInertia.e01 = e00 * r10 + e01 * r11 + e02 * r12;
        invertInertia.e02 = e00 * r20 + e01 * r21 + e02 * r22;
        invertInertia.e10 = e10 * r00 + e11 * r01 + e12 * r02;
        invertInertia.e11 = e10 * r10 + e11 * r11 + e12 * r12;
        invertInertia.e12 = e10 * r20 + e11 * r21 + e12 * r22;
        invertInertia.e20 = e20 * r00 + e21 * r01 + e22 * r02;
        invertInertia.e21 = e20 * r10 + e21 * r11 + e22 * r12;
        invertInertia.e22 = e20 * r20 + e21 * r21 + e22 * r22;
        for (var i:int = 0; i < numShapes; i++) {
            var shape:Shape = shapes[i];
            var relPos:Vec3 = shape.relativePosition;
            var lRelPos:Vec3 = shape.localRelativePosition;
            var relRot:Mat33 = shape.relativeRotation;
            var rot:Mat33 = shape.rotation;
            var lx:Number = lRelPos.x;
            var ly:Number = lRelPos.y;
            var lz:Number = lRelPos.z;
            relPos.x = lx * r00 + ly * r01 + lz * r02;
            relPos.y = lx * r10 + ly * r11 + lz * r12;
            relPos.z = lx * r20 + ly * r21 + lz * r22;
            shape.position.x = position.x + relPos.x;
            shape.position.y = position.y + relPos.y;
            shape.position.z = position.z + relPos.z;
            e00 = relRot.e00;
            e01 = relRot.e01;
            e02 = relRot.e02;
            e10 = relRot.e10;
            e11 = relRot.e11;
            e12 = relRot.e12;
            e20 = relRot.e20;
            e21 = relRot.e21;
            e22 = relRot.e22;
            rot.e00 = r00 * e00 + r01 * e10 + r02 * e20;
            rot.e01 = r00 * e01 + r01 * e11 + r02 * e21;
            rot.e02 = r00 * e02 + r01 * e12 + r02 * e22;
            rot.e10 = r10 * e00 + r11 * e10 + r12 * e20;
            rot.e11 = r10 * e01 + r11 * e11 + r12 * e21;
            rot.e12 = r10 * e02 + r11 * e12 + r12 * e22;
            rot.e20 = r20 * e00 + r21 * e10 + r22 * e20;
            rot.e21 = r20 * e01 + r21 * e11 + r22 * e21;
            rot.e22 = r20 * e02 + r21 * e12 + r22 * e22;
            shape.updateProxy();
        }
    }
    public function applyImpulse(position:Vec3, force:Vec3):void {
        linearVelocity.x += force.x * invertMass;
        linearVelocity.y += force.y * invertMass;
        linearVelocity.z += force.z * invertMass;
        var rel:Vec3 = new Vec3();
        rel.sub(position, this.position).cross(rel, force).mulMat(invertInertia, rel);
        angularVelocity.x += rel.x;
        angularVelocity.y += rel.y;
        angularVelocity.z += rel.z;
    }
}
class World {
    public static const MAX_BODIES:uint = 16384;
    public static const MAX_SHAPES:uint = 32768;
    public static const MAX_CONTACTS:uint = 65536;
    public static const MAX_PAIRS:uint = 65536;
    public var rigidBodies:Vector.<RigidBody>;
    public var numRigidBodies:uint;
    public var shapes:Vector.<Shape>;
    public var numShapes:uint;
    public var pairs:Vector.<Pair>;
    public var numPairs:uint;
    public var contacts:Vector.<Contact>;
    private var contactsBuffer:Vector.<Contact>;
    public var numContacts:uint;
    public var timeStep:Number;
    public var gravity:Vec3;
    public var iteration:uint;
    public var performance:Performance;
    private var broadPhase:BroadPhase;
    private var detectors:Vector.<Vector.<CollisionDetector>>;
    private var contactInfos:Vector.<ContactInfo>;
    private var numContactInfos:uint;
    public function World(stepPerSecond:Number = 60) {
        trace(OimoPhysics.DESCRIPTION);
        timeStep = 1 / stepPerSecond;
        iteration = 8;
        gravity = new Vec3(0, -9.80665, 0);
        rigidBodies = new Vector.<RigidBody>(MAX_BODIES, true);
        shapes = new Vector.<Shape>(MAX_SHAPES, true);
        pairs = new Vector.<Pair>(MAX_PAIRS, true);
        performance = new Performance();
        broadPhase = new SweepAndPruneBroadPhase();
        // broadPhase = new BruteForceBroadPhase();
        var numShapeTypes:uint = 3;
        detectors = new Vector.<Vector.<CollisionDetector>>(numShapeTypes, true);
        for (var i:int = 0; i < numShapeTypes; i++) {
            detectors[i] = new Vector.<CollisionDetector>(numShapeTypes, true);
        }
        detectors[Shape.SHAPE_SPHERE][Shape.SHAPE_SPHERE] = new SphereSphereCollisionDetector();
        detectors[Shape.SHAPE_SPHERE][Shape.SHAPE_BOX] = new SphereBoxCollisionDetector(false);
        detectors[Shape.SHAPE_BOX][Shape.SHAPE_SPHERE] = new SphereBoxCollisionDetector(true);
        detectors[Shape.SHAPE_BOX][Shape.SHAPE_BOX] = new BoxBoxCollisionDetector();
        contactInfos = new Vector.<ContactInfo>(MAX_CONTACTS, true);
        contacts = new Vector.<Contact>(MAX_CONTACTS, true);
        contactsBuffer = new Vector.<Contact>(MAX_CONTACTS, true);
    }
    public function addRigidBody(rigidBody:RigidBody):void {
        if (numRigidBodies == MAX_BODIES) {
            throw new Error("これ以上ワールドに剛体を追加することはできません");
        }
        if (rigidBody.parent) {
            throw new Error("一つの剛体を複数ワールドに追加することはできません");
        }
        rigidBodies[numRigidBodies++] = rigidBody;
        var num:uint = rigidBody.numShapes;
        for (var i:int = 0; i < num; i++) {
            addShape(rigidBody.shapes[i]);
        }
        rigidBody.parent = this;
    }
    public function removeRigidBody(rigidBody:RigidBody, index:int = -1):void {
        if (index < 0) {
            for (var i:int = 0; i < numRigidBodies; i++) {
                if (rigidBody == rigidBodies[i]) {
                    index = i;
                    break;
                }
            }
            if (index == -1) {
                return;
            }
        } else if (index >= numRigidBodies) {
            throw new Error("削除する剛体のインデックスが範囲外です");
        }
        var remove:RigidBody = rigidBodies[index];
        remove.parent = null;
        var num:uint = rigidBody.numShapes;
        for (var j:int = 0; j < num; j++) {
            removeShape(rigidBody.shapes[j]);
        }
        for (var k:int = index; k < numRigidBodies - 1; k++) {
            rigidBodies[k] = rigidBodies[k + 1];
        }
        rigidBodies[--numRigidBodies] = null;
    }
    public function addShape(shape:Shape):void {
        if (numShapes == MAX_SHAPES) {
            throw new Error("これ以上ワールドに形状を追加することはできません");
        }
        if (!shape.parent) {
            throw new Error("ワールドに形状を単体で追加することはできません");
        }
        if (shape.parent.parent) {
            throw new Error("一つの形状を複数ワールドに追加することはできません");
        }
        broadPhase.addProxy(shape.proxy);
        shapes[numShapes++] = shape;
    }
    public function removeShape(shape:Shape, index:int = -1):void {
        if (index < 0) {
            for (var i:int = 0; i < numShapes; i++) {
                if (shape == shapes[i]) {
                    index = i;
                    break;
                }
            }
            if (index == -1) {
                return;
            }
        } else if (index >= numShapes) {
            throw new Error("削除する形状のインデックスが範囲外です");
        }
        var remove:Shape = shapes[index];
        broadPhase.removeProxy(remove.proxy);
        for (var j:int = index; j < numShapes - 1; j++) {
            shapes[j] = shapes[j + 1];
        }
        shapes[--numShapes] = null;
    }
    public function step():void {
        var start1:int = getTimer();
        var tmp:Vector.<Contact> = contacts; // swap contacts
        contacts = contactsBuffer;
        contactsBuffer = tmp;
        for (var i:int = 0; i < numRigidBodies; i++) {
            rigidBodies[i].updateVelocity(timeStep, gravity);
        }
        performance.updateTime = getTimer() - start1;
        collisionDetection();
        collisionResponse();
        var start2:int = getTimer();
        for (var j:int = 0; j < numRigidBodies; j++) {
            rigidBodies[j].updatePosition(timeStep);
        }
        performance.updateTime += getTimer() - start2;
        performance.totalTime = getTimer() - start1;
    }
    private function collisionDetection():void {
        collectContactInfos();
        setupContacts();
    }
    private function collectContactInfos():void {
        // broad phase
        var start:int = getTimer();
        numPairs = broadPhase.detectPairs(pairs);
        performance.broadPhaseTime = getTimer() - start;
        // narrow phase
        performance.narrowPhaseTime = getTimer();
        numContactInfos = 0;
        for (var i:int = 0; i < numPairs; i++) {
            var pair:Pair = pairs[i];
            var s1:Shape = pair.shape1;
            var s2:Shape = pair.shape2;
            var detector:CollisionDetector = detectors[s1.type][s2.type];
            if (detector) {
                numContactInfos = detector.detectCollision(s1, s2, contactInfos, numContactInfos);
                if (numContactInfos == MAX_CONTACTS) {
                    return;
                }
            }
        }
    }
    private function setupContacts():void {
        numContacts = numContactInfos;
        for (var i:int = 0; i < numContacts; i++) {
            if (!contacts[i]) {
                contacts[i] = new Contact();
            }
            var c:Contact = contacts[i];
            c.setupFromContactInfo(contactInfos[i]);
            // search old contacts
            var s1:Shape = c.shape1;
            var s2:Shape = c.shape2;
            var sc:Vector.<Contact>;
            var numSc:uint;
            if (s1.numContacts < s2.numContacts) {
                sc = s1.contacts;
                numSc = s1.numContacts;
            } else {
                sc = s2.contacts;
                numSc = s2.numContacts;
            }
            for (var j:int = 0; j < numSc; j++) {
                var oc:Contact = sc[j];
                if (
                    (oc.shape1 == c.shape1 && oc.shape2 == c.shape2 ||
                    oc.shape1 == c.shape2 && oc.shape2 == c.shape1) &&
                    oc.id.equals(c.id)
                ) {
                    // warm starting
                    c.normalImpulse = oc.normalImpulse;
                    c.tangentImpulse = oc.tangentImpulse;
                    c.binormalImpulse = oc.binormalImpulse;
                    c.warmStarted = true;
                    break;
                }
            }
        }
        performance.narrowPhaseTime = getTimer() - performance.narrowPhaseTime;
    }
    private function collisionResponse():void {
        var start:int = getTimer();
        var invTimeStep:Number = 1 / timeStep;
        // reset contact counts
        for (var i:int = 0; i < numShapes; i++) {
            shapes[i].numContacts = 0;
        }
        for (var j:int = 0; j < numContacts; j++) {
            contacts[j].preSolve(timeStep, invTimeStep);
        }
        // solve system of equations
        for (var k:int = 0; k < iteration; k++) {
            for (var l:int = 0; l < numContacts; l++) {
                contacts[l].solve();
            }
        }
        for (var m:int = 0; m < numContacts; m++) {
            contacts[m].postSolve();
        }
        performance.constraintsTime = getTimer() - start;
    }
}
class DebugDraw {
    private var w:uint;
    private var h:uint;
    private var wld:World;
    private var c3d:Context3D;
    private var gl:OimoGLMini;
    private var m44:Mat44;
    public function DebugDraw(width:uint, height:uint) {
        w = width;
        h = height;
        m44 = new Mat44();
    }
    public function setContext3D(context3D:Context3D):void {
        c3d = context3D;
        gl = new OimoGLMini(c3d, w, h);
        gl.material(1, 1, 0, 0.6, 32);
        gl.registerSphere(0, 1, 10, 5);
        gl.registerBox(1, 1, 1, 1);
        gl.camera(0, 5, 10, 0, 0, 0, 0, 1, 0);
    }
    public function setWorld(world:World):void {
        wld = world;
    }
    public function camera(
        camX:Number, camY:Number, camZ:Number,
        targetX:Number = 0, targetY:Number = 0, targetZ:Number = 0,
        upX:Number = 0, upY:Number = 1, upZ:Number = 0
    ):void {
        gl.camera(camX, camY, camZ, targetX, targetY, targetZ, upX, upY, upZ);
        var dx:Number = targetX - camX;
        var dy:Number = targetY - camY;
        var dz:Number = targetZ - camZ;
        var len:Number = Math.sqrt(dx * dx + dy * dy + dz * dz);
        if (len > 0) len = 1 / len;
        gl.directionalLightDirection(dx * len, dy * len, dz * len);
    }
    public function render():void {
        if (!c3d) {
            return;
        }
        gl.beginScene(0.1, 0.1, 0.1);
        var alpha:Number = 1;
        var drawContacts:Boolean = false;
        var drawNormals:Boolean = true;
        var drawForces:Boolean = true;
        var cs:Vector.<Contact> = wld.contacts;
        var num:uint = wld.numContacts;
        if (drawContacts) {
            for (var j:int = 0; j < num; j++) {
                var c:Contact = cs[j];
                gl.push();
                gl.translate(c.position.x, c.position.y, c.position.z);
                if (drawNormals) gl.push();
                if (c.warmStarted) {
                    gl.scale(0.1, 0.1, 0.1);
                    gl.color(0.5, 0.5, 0.5);
                } else {
                    gl.scale(0.15, 0.15, 0.15);
                    gl.color(1, 1, 0);
                }
                gl.drawTriangles(0);
                if (drawNormals) {
                    gl.pop();
                    gl.push();
                    if (drawForces) gl.translate(c.normal.x * -c.normalImpulse * 0.3, c.normal.y * -c.normalImpulse * 0.3, c.normal.z * -c.normalImpulse * 0.3);
                    else gl.translate(c.normal.x * 0.3, c.normal.y * 0.3, c.normal.z * 0.3);
                    gl.scale(0.1, 0.1, 0.1);
                    gl.color(1, 0, 0);
                    gl.drawTriangles(0);
                    gl.pop();
                    if (!drawForces) {
                        gl.push();
                        gl.translate(c.tangent.x * 0.3, c.tangent.y * 0.3, c.tangent.z * 0.3);
                        gl.scale(0.1, 0.1, 0.1);
                        gl.color(0, 0.6, 0);
                        gl.drawTriangles(0);
                        gl.pop();
                        gl.push();
                        gl.translate(c.binormal.x * 0.3, c.binormal.y * 0.3, c.binormal.z * 0.3);
                        gl.scale(0.1, 0.1, 0.1);
                        gl.color(0, 0, 1);
                        gl.drawTriangles(0);
                        gl.pop();
                    }
                    if (drawForces) {
                        gl.push();
                        gl.translate(
                            (c.tangent.x * c.tangentImpulse + c.binormal.x * c.binormalImpulse) * 0.3,
                            (c.tangent.y * c.tangentImpulse + c.binormal.y * c.binormalImpulse) * 0.3,
                            (c.tangent.z * c.tangentImpulse + c.binormal.z * c.binormalImpulse) * 0.3
                        );
                        gl.scale(0.1, 0.1, 0.1);
                        gl.color(0, 1, 1);
                        gl.drawTriangles(0);
                        gl.pop();
                    }
                }
                gl.pop();
            }
        }
        var ss:Vector.<Shape> = wld.shapes;
        num = wld.numShapes;
        for (var i:int = 0; i < num; i++) {
            var s:Shape = ss[i];
            gl.push();
            m44.copyMat33(s.rotation);
            m44.e03 = s.position.x;
            m44.e13 = s.position.y;
            m44.e23 = s.position.z;
            gl.transform(m44);
            switch(s.parent.type) {
            case RigidBody.BODY_DYNAMIC:
                if (s.id & 1) gl.color(1, 0.6, 0.1, alpha);
                else gl.color(0.6, 0.1, 1, alpha);
                break;
            case RigidBody.BODY_STATIC:
                gl.color(0.4, 0.4, 0.4, alpha);
                break;
            }
            switch(s.type) {
            case Shape.SHAPE_SPHERE:
                var sph:SphereShape = s as SphereShape;
                gl.scale(sph.radius, sph.radius, sph.radius);
                gl.drawTriangles(0);
                break;
            case Shape.SHAPE_BOX:
                var box:BoxShape = s as BoxShape;
                gl.scale(box.width, box.height, box.depth);
                gl.drawTriangles(1);
                break;
            }
            gl.pop();
        }
        
        gl.endScene();
        
    }
}
class Performance {
    public var broadPhaseTime:uint;
    public var narrowPhaseTime:uint;
    public var constraintsTime:uint;
    public var updateTime:uint;
    public var totalTime:uint;
    public function Performance() {
    }
}
final class OimoPhysics {
    public static const VERSION:String = "1.0.0";
    public static const DESCRIPTION:String = "OimoPhysics " + VERSION + " (c) 2012 EL-EMENT saharan";
    public function OimoPhysics() {
        throw new Error("OimoPhysics オブジェクトを作成することはできません");
    }
}
