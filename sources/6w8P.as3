package {
    import com.bit101.components.*;
    import flash.display.*;
    import flash.display3D.*;
    import flash.events.*;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.ContextMenu;
    
    [SWF(width = "466", height = "466", frameRate = "60")]
    /**
     * Ring 3D
     * @author saharan
     */
    public class Ring extends Sprite {
        private var s3d:Stage3D;
        private var c3d:Context3D;
        private var w:World;
        private var drag:Boolean;
        private var pmouseX:Number;
        private var pmouseY:Number;
        
        public function Ring():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            contextMenu = new ContextMenu();
            contextMenu.hideBuiltInItems();
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
                drag = true;
            });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
                drag = false;
            });
            s3d = stage.stage3Ds[0];
            s3d.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            s3d.requestContext3D();
        }
        
        private function onContext3DCreate(e:Event = null):void {
            s3d.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            c3d = s3d.context3D;
            c3d.configureBackBuffer(466, 466, 0);
            w = new World(c3d);
            //
            var throwArea:Sprite = new Sprite();
            throwArea.graphics.beginFill(0, 0.4);
            throwArea.graphics.drawRect(0, 386, 466, 80);
            throwArea.graphics.endFill();
            throwArea.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event):void {
                throwArea.graphics.clear();
                throwArea.graphics.beginFill(0, 0.4);
                throwArea.graphics.drawRect(0, 386, 466, 80);
                throwArea.graphics.endFill();
            });
            throwArea.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event):void {
                throwArea.graphics.clear();
                throwArea.graphics.beginFill(0, 0);
                throwArea.graphics.drawRect(0, 386, 466, 80);
                throwArea.graphics.endFill();
            });
            throwArea.buttonMode = true;
            throwArea.tabEnabled = false;
            addChild(throwArea);
            throwArea.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
                w.throwRing();
            });
            //
            var pan:Panel = new Panel(this, 0, 0);
            pan.height = 24;
            var grav:CheckBox = new CheckBox(pan.content, 4, 0, "Gravity Control", function():void {
                w.controlGravity = grav.selected;
            });
            grav.y = pan.height - grav.height >> 1;
            var reset:PushButton = new PushButton(pan.content, grav.x + grav.width + 4, 0, "Reset", function():void {
                w.reset();
            });
            reset.y = pan.height - reset.height >> 1;
            var debug:Text = new Text(pan.content, reset.x + reset.width + 4, 0);
            debug.width = 466 - (reset.x + reset.width + 8);
            debug.height = 20;
            debug.y = pan.height - debug.height >> 1;
            debug.selectable = false;
            debug.editable = false;
            w.debug = debug;
            pan.width = 466;
            //
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event = null):void {
            if (drag) w.dragField(mouseX - pmouseX, mouseY - pmouseY);
            w.frame();
            pmouseX = mouseX;
            pmouseY = mouseY;
        }
    }
}

import com.adobe.utils.*;
import flash.display.*;
import flash.display3D.*;
import flash.geom.*;
import flash.utils.ByteArray;
import com.bit101.components.*;

class World {
    public var controlGravity:Boolean;
    public var debug:Text;
    private var c3d:Context3D;
    private var ps:Vector.<Particle>;
    private var numP:uint;
    private var rs:Vector.<Rigid>;
    private var numR:uint;
    private var grav:Vec3;
    private var gridW:uint;
    private var gridH:uint;
    private var gridD:uint;
    private var gridShiftW:uint;
    private var gridShiftH:uint;
    private var gridShiftD:uint;
    private var gridSize:Number;
    private var invGridSize:Number;
    private var numGrids:uint;
    private var wall:Rigid;
    private var wallP:Particle;
    private var grid:Vector.<Vector.<Particle>>;
    private var gridCount:Vector.<uint>;
    private var cs:Vector.<ContactConstraint>;
    private var numC:uint;
    private var maxCount:uint;
    private var rotX:Number;
    private var rotY:Number;
    private var rotTgtX:Number;
    private var rotTgtY:Number;
    private var rotM:Mat44;
    private var gl:ShrGL;
    
    public function World(c3d:Context3D):void {
        this.c3d = c3d;
        init();
    }
    
    private function init():void {
        rotX = 0;
        rotY = 0;
        rotTgtX = Math.PI * 0.125;
        rotTgtY = 0;
        grav = new Vec3();
        gl = new ShrGL(c3d, 466, 466);
        rotM = new Mat44();
        var i:int;
        var j:int;
        var k:int;
        ps = new Vector.<Particle>(20000, true);
        rs = new Vector.<Rigid>(2000, true);
        cs = new Vector.<ContactConstraint>(30000, true);
        //
        gridSize = 16;
        invGridSize = 1 / gridSize;
        maxCount = 8;
        gridW = 64;
        gridH = 32;
        gridD = 64;
        gridShiftW = 6;
        gridShiftH = 5;
        gridShiftD = 6;
        numGrids = gridW * gridH * gridD;
        grid = new Vector.<Vector.<Particle>>(numGrids, true);
        gridCount = new Vector.<uint>(numGrids, true);
        for (i = 0; i < numGrids; i++) {
            grid[i] = new Vector.<Particle>(maxCount, true);
            gridCount[i] = 0;
        }
        //
        gl.camera(0, -136, 700, 0, -136, 0);
        gl.perspective(Math.PI / 3, 0.5, 2000);
        //
        gl.registerProgram(0);
        gl.uploadVertexShader(0,
            "m44 vt0 va0 vc0 \n" +
            "mov v0 vt0 \n" + // pos
            "m44 op vt0 vc4 \n" + // vertex
            "m33 vt1.xyz va1.xyz vc0 \n" +
            "nrm vt1.xyz vt1.xyz \n" +
            "mov v1 vt1.xyz \n" // normal
        );
        gl.uploadFragmentShader(0,
            gl.createBasicFragmentShaderCode(0, 1, 0, 1, 2, 3, 4, 5, 6)
        );
        gl.setProgramConstantsNumber("fragment", 1, 0.3, 0.7, 0, 1); // amb dif emi
        gl.setProgramConstantsNumber("fragment", 2, 0.6, 48, 0, 1); // spc shn
        gl.setProgramConstantsNumber("fragment", 3, 1, 1, 1, 1); // amb col
        gl.setProgramConstantsNumber("fragment", 4, 1, 1, 1, 1); // dir col
        gl.setProgramConstantsNumber("fragment", 5, 0, -1, -1, 1); // dir
        gl.setProgramConstantsNumber("fragment", 6, 0, -100, 600, 1); // camera pos
        gl.setProgram(0);
        //
        gl.registerBuffer(0, 4, 6, 6);
        gl.uploadVertexBuffer(0, Vector.<Number>([
            -400, 0, 400, 0, 1, 0,
            400, 0, 400, 0, 1, 0,
            -400, 0, -400, 0, 1, 0,
            400, 0, -400, 0, 1, 0
        ]));
        gl.uploadIndexBuffer(0, Vector.<uint>([
            0, 1, 2,
            1, 3, 2
        ]));
        //
        createTorus(1, 24, 6, 26, 34);
        createCylinder(2, 16, 6, 128);
        //
        initField();
    }
    
    public function throwRing():void {
        var ang:Number = rotY + Math.random() - 0.5;
        var s:Number = Math.sin(-rotY);
        var c:Number = Math.cos(-rotY);
        var sv:Number = Math.sin(-ang);
        var cv:Number = Math.cos(-ang);
        var x:Number = s * 360;
        var y:Number = Math.random() * 50;
        var z:Number = c * 360;
        var vel:Number = 6 + Math.random() * 2;
        makeRing(30, x, y, z, sv * -vel, 2, cv * -vel);
    }
    
    private function initField():void {
        var i:int;
        var j:int;
        var k:int;
        wall = new Rigid();
        wallP = new Particle(0, 0, 0);
        wall.calcGravity();
        wall.addParticle(wallP);
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 4; j++) {
                var py:Number = -192;
                for (k = 0; k < 8; k++) {
                    var p:Particle = new Particle((i - 1.5) * 80, py, (j - 1.5) * 80);
                    wall.addParticle(p);
                    ps[numP++] = p;
                    py += 16;
                }
            }
        }
        for (i = 0; i < 16; i++) {
            var r:Rigid = makeRing(30, Math.random() * 400 - 200, i * 16, Math.random() * 400 - 200, 0, 0, 0);
            r.angV.x = Math.random() * 0.2 - 0.1;
            r.angV.y = Math.random() * 0.2 - 0.1;
            r.angV.z = Math.random() * 0.2 - 0.1;
        }
    }
    
    public function reset():void {
        numP = 0;
        numR = 0;
        Particle.STATIC_ID = 0;
        initField();
    }
    
    private function createTorus(register:uint, divV:uint, divH:uint, inRadius:Number, outRadius:Number):void {
        var vertices:Vector.<Number> = new Vector.<Number>();
        var theta:Number;
        var phi:Number;
        var dTheta:Number = Math.PI * 2 / divV;
        var dPhi:Number = Math.PI * 2 / divH;
        var numVertices:uint = divH * divV;
        phi = 0;
        var m:Mat44 = new Mat44();
        var n:Vec3 = new Vec3();
        for (var i:int = 0; i < divH; i++) {
            theta = 0;
            for (var j:int = 0; j < divV; j++) {
                m.init();
                m.rotate(m, -theta, 0, 1, 0);
                m.rotate(m, -phi, 0, 0, 1);
                n.init(0, 1, 0);
                n.mulMatrix(m, n);
                vertices.push(
                    Math.cos(theta) * (outRadius + (outRadius - inRadius) * Math.sin(phi)),
                    (outRadius - inRadius) * Math.cos(phi),
                    Math.sin(theta) * (outRadius + (outRadius - inRadius) * Math.sin(phi)),
                    n.x, n.y, n.z
                );
                theta += dTheta;
            }
            phi += dPhi;
        }
        var indices:Vector.<uint> = new Vector.<uint>();
        for (i = 0; i < divH; i++) {
            for (j = 0; j < divV; j++) {
                indices.push(
                    i * divV + j,
                    (i + 1) % divH * divV + (j + 1) % divV,
                    (i + 1) % divH * divV + j,
                    i * divV + j,
                    i % divH * divV + (j + 1) % divV,
                    (i + 1) % divH * divV + (j + 1) % divV
                );
            }
        }
        gl.registerBuffer(register, numVertices, 6, numVertices * 6);
        gl.uploadVertexBuffer(register, vertices);
        gl.uploadIndexBuffer(register, indices);
    }
    
    private function createCylinder(register:uint, div:uint, radius:Number, height:Number):void {
        var theta:Number;
        var dTheta:Number = Math.PI * 2 / div;
        var numVertices:uint = div * 4;
        var vertices:Vector.<Number> = new Vector.<Number>(numVertices * 6, true);
        var m:Mat44 = new Mat44();
        var n:Vec3 = new Vec3();
        var i:int;
        var idx:uint;
        theta = 0;
        for (i = 0; i < div; i++) {
            idx = i * 6;
            vertices[idx++] = Math.cos(theta) * radius;
            vertices[idx++] = height / 2;
            vertices[idx++] = Math.sin(theta) * radius;
            vertices[idx++] = Math.cos(theta);
            vertices[idx++] = 0;
            vertices[idx++] = Math.sin(theta);
            idx = (i + div) * 6;
            vertices[idx++] = Math.cos(theta) * radius;
            vertices[idx++] = -height / 2;
            vertices[idx++] = Math.sin(theta) * radius;
            vertices[idx++] = Math.cos(theta);
            vertices[idx++] = 0;
            vertices[idx++] = Math.sin(theta);
            idx = ((div << 1) + i) * 6;
            vertices[idx++] = Math.cos(theta) * radius;
            vertices[idx++] = height / 2;
            vertices[idx++] = Math.sin(theta) * radius;
            vertices[idx++] = 0;
            vertices[idx++] = 1;
            vertices[idx++] = 0;
            idx = ((div << 1) + i + div) * 6;
            vertices[idx++] = Math.cos(theta) * radius;
            vertices[idx++] = -height / 2;
            vertices[idx++] = Math.sin(theta) * radius;
            vertices[idx++] = 0;
            vertices[idx++] = -1;
            vertices[idx++] = 0;
            theta += dTheta;
        }
        var indices:Vector.<uint> = new Vector.<uint>();
        for (i = 0; i < div; i++) {
            indices.push(
                i, (i + 1) % div, (i + 1) % div + div,
                i, (i + 1) % div + div, i + div
            );
            if (i != 0) {
                var off:uint = div << 1;
                indices.push(
                    off, off + (i + 1) % div, off + i,
                    off + div, off + i + div, off + (i + 1) % div + div
                );
            }
        }
        gl.registerBuffer(register, numVertices, 6, indices.length);
        gl.uploadVertexBuffer(register, vertices);
        gl.uploadIndexBuffer(register, indices);
    }
    
    public function makeRing(rad:Number, x:Number, y:Number, z:Number, vx:Number, vy:Number, vz:Number):Rigid {
        var r:Rigid = new Rigid();
        var a:Number = 0;
        var num:uint = uint(Math.PI * rad / 8 + 0.5);
        trace(num * 8 / Math.PI); // idial radius
        var da:Number = Math.PI * 2 / num;
        for (var i:int = 0; i < num; i++) {
            r.addParticle(ps[numP++] = new Particle(Math.cos(a) * rad + x, y, Math.sin(a) * rad + z));
            a += da;
        }
        r.calcGravity();
        r.linV.x = vx;
        r.linV.y = vy;
        r.linV.z = vz;
        return rs[numR++] = r;
    }
    
    public function frame():void {
        rotX += (rotTgtX - rotX) * 0.2;
        rotY += (rotTgtY - rotY) * 0.2;
        step();
        render();
    }
    
    public function dragField(dragX:Number, dragY:Number):void  {
        rotTgtX += dragY * 0.01;
        if (rotTgtX > Math.PI * 0.5) rotTgtX = Math.PI * 0.5;
        else if (rotTgtX < 0) rotTgtX = 0;
        rotTgtY += dragX * 0.01;
        while (rotTgtY > Math.PI) {
            rotTgtY -= Math.PI * 2;
            rotY -= Math.PI * 2;
        }
        while (rotTgtY < -Math.PI) {
            rotTgtY += Math.PI * 2;
            rotY += Math.PI * 2;
        }
    }
    
    private function step():void {
        collisionDetection();
        collisionResponse();
        updatePositions();
    }
    
    private function collisionDetection():void {
        var i:int;
        var j:int;
        for (i = 0; i < numGrids; i++) {
            gridCount[i] = 0;
        }
        numC = 0;
        var halfWorldX:Number = gridW * gridSize * 0.5;
        var halfWorldY:Number = gridH * gridSize * 0.5;
        var halfWorldZ:Number = gridD * gridSize * 0.5;
        for (i = 0; i < numP; i++) {
            var p1:Particle = ps[i];
            if (p1.rigid.invM > 0) {
                if (p1.posx < -392) {
                    addWallConstraint(p1, -392 - p1.posx, -1, 0, 0);
                } else if (p1.posx > 392) {
                    addWallConstraint(p1, p1.posx - 392, 1, 0, 0);
                }
                if (p1.posz < -392) {
                    addWallConstraint(p1, -392 - p1.posz, 0, 0, -1);
                } else if (p1.posz > 392) {
                    addWallConstraint(p1, p1.posz - 392, 0, 0, 1);
                }
                if (p1.posy < -192) {
                    addWallConstraint(p1, -192 - p1.posy, 0, -1, 0);
                } else if (p1.posy > 192) {
                    addWallConstraint(p1, p1.posy - 192, 0, 1, 0);
                }
            }
            var gx:int = (p1.posx + halfWorldX) * invGridSize;
            var gy:int = (p1.posy + halfWorldY) * invGridSize;
            var gz:int = (p1.posz + halfWorldZ) * invGridSize;
            if (gx < 0) gx = 0;
            if (gy < 0) gy = 0;
            if (gz < 0) gz = 0;
            if (gx >= gridW) gx = gridW - 1;
            if (gy >= gridH) gy = gridH - 1;
            if (gz >= gridD) gz = gridD - 1;
            var index:uint = ((gy + (gz << gridShiftH)) << gridShiftW) + gx;
            
            var minX:int = gx - 1;
            if (minX < 0) minX = 0;
            var maxX:int = gx + 1;
            if (maxX >= gridW) maxX = gridW - 1;
            var numX:int = maxX - minX;
            
            var minY:int = gy - 1;
            if (minY < 0) minY = 0;
            var maxY:int = gy + 1;
            if (maxY >= gridH) maxY = gridH - 1;
            var numY:int = maxY - minY;
            
            var minZ:int = gz - 1;
            if (minZ < 0) minZ = 0;
            var maxZ:int = gz + 1;
            if (maxZ >= gridD) maxZ = gridD - 1;
            var numZ:int = maxZ - minZ;
            
            var offset:uint = ((minY + (minZ << gridShiftH)) << gridShiftW) + minX;
            var gridWxH:uint = 1 << (gridShiftW + gridShiftH);
            for (var z:uint = 0; z <= numZ; z++) {
                var index2:uint = offset;
                for (var y:uint = 0; y <= numY; y++) {
                    var index3:uint = index2;
                    for (var x:uint = 0; x <= numX; x++) {
                        var gps:Vector.<Particle> = grid[index3];
                        var numParticles:uint = gridCount[index3];
                        for (j = 0; j < numParticles; j++) {
                            if (gps[j].rigid != p1.rigid) {
                                var p2:Particle = gps[j];
                                var dx:Number = p2.posx - p1.posx;
                                if (dx < -16 || dx > 16) continue;
                                var dy:Number = p2.posy - p1.posy;
                                if (dy < -16 || dy > 16) continue;
                                var dz:Number = p2.posz - p1.posz;
                                if (dz < -16 || dz > 16) continue;
                                var len:Number = dx * dx + dy * dy + dz * dz;
                                if (len > 256) continue;
                                len = Math.sqrt(len);
                                var invL:Number = 1 / len;
                                if (!cs[numC]) cs[numC] = new ContactConstraint();
                                var newC:ContactConstraint = cs[numC++];
                                newC.init(
                                    p1, p2, 16 - len,
                                    (p1.posx + p2.posx) * 0.5, (p1.posy + p2.posy) * 0.5, (p1.posz + p2.posz) * 0.5,
                                    dx * invL, dy * invL, dz * invL
                                );
                                var id1:uint = p1.id;
                                var id2:uint = p2.id;
                                for (var k:int = 0; k < p1.numC; k++) { // search for warm start
                                    var oldC:ConstraintImpulseData = p1.cs[k];
                                    if (oldC.id1 == id1 && oldC.id2 == id2 || oldC.id1 == id2 && oldC.id2 == id1) {
                                        newC.impulseN = oldC.impulseN;
                                        newC.impulseT1 = oldC.impulseT1;
                                        newC.impulseT2 = oldC.impulseT2;
                                        break;
                                    }
                                }
                            }
                        }
                        index3++;
                    }
                    index2 += gridW;
                }
                offset += gridWxH;
            }
            p1.numC = 0; // reset old constraints
            var count:uint = gridCount[index];
            if (count < maxCount) {
                grid[index][count] = p1;
                gridCount[index] = ++count;
            } else trace("Grid filled!");
        }
        wallP.numC = 0;
    }
    
    private function addWallConstraint(p:Particle, bias:Number, nx:Number, ny:Number, nz:Number):void {
        if (!cs[numC]) cs[numC] = new ContactConstraint();
        var newC:ContactConstraint = cs[numC++];
        newC.init(
            p, wallP, bias,
            p.posx + nx * 8, p.posy + ny * 8, p.posz + nz * 8,
            nx, ny, nz
        );
        var id1:uint = p.id;
        var id2:uint = wallP.id;
        for (var i:int = 0; i < p.numC; i++) { // search for warm start
            var oldC:ConstraintImpulseData = p.cs[i];
            if (oldC.id1 == id1 && oldC.id2 == id2 || oldC.id1 == id2 && oldC.id2 == id1) {
                newC.impulseN = oldC.impulseN;
                newC.impulseT1 = oldC.impulseT1;
                newC.impulseT2 = oldC.impulseT2;
                break;
            }
        }
    }
    
    private function collisionResponse():void {
        var i:int;
        for (i = 0; i < numC; i++) {
            cs[i].preSolve();
        }
        // iteration
        for (var j:int = 0; j < 2; j++) {
            for (i = 0; i < numC; i++) {
                cs[i].solve();
            }
        }
        for (i = 0; i < numC; i++) {
            cs[i].postSolve();
        }
    }
    
    private function updatePositions():void  {
        var i:int;
        grav.init(0, -0.15, 0);
        if (controlGravity) {
            rotM.init();
            rotM.rotate(rotM, -rotY, 0, 1, 0);
            rotM.rotate(rotM, -rotX, 1, 0, 0);
            grav.mulMatrix(rotM, grav);
        }
        for (i = 0; i < numR; i++) {
            rs[i].update(grav);
        }
    }
    
    private function render():void {
        var i:int;
        var j:int;
        gl.beginScene(0.125, 0.125, 0.125);
        gl.push();
        gl.translate(0, -200, 0);
        gl.rotate(rotX, 1, 0, 0);
        gl.rotate(rotY, 0, 1, 0);
        gl.translate(0, 200, 0);
        var tmpM1:Mat44 = new Mat44();
        var tmpM2:Mat44 = new Mat44();
        gl.getViewMatrix(tmpM1);
        gl.getProjectionMatrix(tmpM2);
        tmpM1.mul(tmpM2, tmpM1);
        gl.setProgramConstantsMatrix("vertex", 4, tmpM1);
        for (i = 0; i < numR; i++) {
            var r:Rigid = rs[i];
            gl.push();
            gl.translate(r.posx, r.posy, r.posz);
            gl.transform(r.rotM);
            gl.getWorldMatrix(tmpM1);
            gl.setProgramConstantsVector("fragment", 0, r.col);
            gl.setProgramConstantsMatrix("vertex", 0, tmpM1);
            gl.bindVertexAttribute(1, 0, 0, "float3");
            gl.bindVertexAttribute(1, 1, 3, "float3");
            gl.drawTriangles(1);
            gl.unbindVertexAttributes();
            gl.pop();
        }
        // render poll
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 4; j++) {
                gl.push();
                gl.translate((i - 1.5) * 80, -200 + 64, (j - 1.5) * 80);
                gl.getWorldMatrix(tmpM1);
                gl.setProgramConstantsNumber("fragment", 0, 0.7, 0.7, 0.7 , 1);
                gl.setProgramConstantsMatrix("vertex", 0, tmpM1);
                gl.bindVertexAttribute(2, 0, 0, "float3");
                gl.bindVertexAttribute(2, 1, 3, "float3");
                gl.drawTriangles(2);
                gl.unbindVertexAttributes();
                gl.pop();
            }
        }
        debug.text = "Particles:" + numP + "   Rigids:" + numR + "   Constraints:" + numC;
        gl.push();
        gl.translate(0, -200, 0);
        gl.bindVertexAttribute(0, 0, 0, "float3");
        gl.bindVertexAttribute(0, 1, 3, "float3");
        gl.setProgramConstantsNumber("fragment", 0, 0.6, 0.6, 0.7, 1);
        gl.getWorldMatrix(tmpM1);
        gl.setProgramConstantsMatrix("vertex", 0, tmpM1);
        gl.drawTriangles(0);
        gl.pop();
        gl.pop();
        gl.endScene();
    }
}

class Rigid {
    public var posx:Number;
    public var posy:Number;
    public var posz:Number;
    public var linV:Vec3;
    public var angV:Vec3;
    public var rotQ:Qua;
    public var rotM:Mat44;
    public var rotT:Mat44;
    public var ps:Vector.<Particle>;
    public var numP:uint;
    public var invM:Number; // invert mass
    public var invI:Mat44; // invert inertia
    public var invLocalI:Mat44;
    public var col:Vec3;
    private var tmp:Vec3;
    private var tmpQ:Qua;
    
    public function Rigid() {
        posx = 0;
        posy = 0;
        posz = 0;
        ps = new Vector.<Particle>(512, true);
        linV = new Vec3();
        var rvel:Number = 0.4;
        angV = new Vec3(rvel * 0.3, rvel, 0);
        col = new Vec3();
        switch (uint(Math.random() * 4)) {
        case 0:
            col.init(1, 0.4, 0.2);
            break;
        case 1:
            col.init(1, 1, 0.2);
            break;
        case 2:
            col.init(0.2, 0.8, 0.3);
            break;
        case 3:
            col.init(0.2, 0.4, 1);
            break;
        }
        rotQ = new Qua();
        rotM = new Mat44();
        rotT = new Mat44();
        invI = new Mat44();
        invLocalI = new Mat44();
        tmp = new Vec3();
        tmpQ = new Qua();
    }
    
    public function addParticle(p:Particle):void {
        p.rigid = this;
        ps[numP++] = p;
    }
    
    public function calcGravity():void {
        if (numP == 0) {
            angV.init();
            linV.init();
            invM = 0;
            invLocalI.init();
            invLocalI.e00 = 0; invLocalI.e11 = 0; invLocalI.e22 = 0; invLocalI.e33 = 0;
            invI.copy(invLocalI);
            rotQ.init();
            rotM.quaternion(rotQ);
        } else {
            var i:int;
            posx = 0;
            posy = 0;
            posz = 0;
            for (i = 0; i < numP; i++) {
                posx += ps[i].posx;
                posy += ps[i].posy;
                posz += ps[i].posz;
            }
            invM = 1 / numP;
            posx *= invM;
            posy *= invM;
            posz *= invM;
            var inv6:Number = numP / 6;
            var xx:Number = inv6;
            var yy:Number = inv6;
            var zz:Number = inv6;
            var xy:Number = 0;
            var xz:Number = 0;
            var yz:Number = 0;
            for (i = 0; i < numP; i++) {
                ps[i].relLocalP.x = ps[i].posx - posx;
                ps[i].relLocalP.y = ps[i].posy - posy;
                ps[i].relLocalP.z = ps[i].posz - posz;
                var r:Vec3 = ps[i].relLocalP;
                xx += r.y * r.y + r.z * r.z;
                yy += r.x * r.x + r.z * r.z;
                zz += r.x * r.x + r.y * r.y;
                xy -= r.x * r.y;
                xz -= r.x * r.z;
                yz -= r.y * r.z;
            }
            invLocalI.init(
                xx, xy, xz, 0,
                xy, yy, yz, 0,
                xz, yz, zz, 0,
                0, 0, 0, 1
            );
            invLocalI.invert(invLocalI);
            invI.copy(invLocalI);
            rotQ.init();
            rotM.quaternion(rotQ);
        }
    }
    
    public function update(grv:Vec3):void {
        if (invM == 0) {
            linV.init();
            angV.init();
        } else {
            posx += linV.x;
            posy += linV.y;
            posz += linV.z;
            linV.x += grv.x;
            linV.y += grv.y;
            linV.z += grv.z;
            var rx:Number = angV.x;
            var ry:Number = angV.y;
            var rz:Number = angV.z;
            var invL:Number = Math.sqrt(rx * rx + ry * ry + rz * rz);
            var t:Number = invL * 0.5;
            if (invL > 0) invL = Math.sin(t) / invL;
            rx *= invL;
            ry *= invL;
            rz *= invL;
            tmpQ.s = Math.cos(t);
            tmpQ.x = rx;
            tmpQ.y = ry;
            tmpQ.z = rz;
            rotQ.mul(tmpQ, rotQ);
            invL = rotQ.s * rotQ.s + rotQ.x * rotQ.x + rotQ.y * rotQ.y + rotQ.z * rotQ.z;
            if (invL > 0) invL = 1 / Math.sqrt(invL);
            rotQ.s *= invL;
            rotQ.x *= invL;
            rotQ.y *= invL;
            rotQ.z *= invL;
            rotM.quaternion(rotQ);
            rotT.e00 = rotM.e00; rotT.e10 = rotM.e01; rotT.e20 = rotM.e02;
            rotT.e01 = rotM.e10; rotT.e11 = rotM.e11; rotT.e21 = rotM.e12;
            rotT.e02 = rotM.e20; rotT.e12 = rotM.e21; rotT.e22 = rotM.e22;
            invI.mul(rotM, invLocalI);
            invI.mul(invI, rotT);
            
            for (var i:int = 0; i < numP; i++) {
                var p:Particle = ps[i];
                var lrp:Vec3 = p.relLocalP;
                var rp:Vec3 = p.relP;
                var pq:Qua = p.rotQ;
                var pm:Mat44 = p.rotM;
                rp.x = lrp.x * rotM.e00 + lrp.y * rotM.e01 + lrp.z * rotM.e02;
                rp.y = lrp.x * rotM.e10 + lrp.y * rotM.e11 + lrp.z * rotM.e12;
                rp.z = lrp.x * rotM.e20 + lrp.y * rotM.e21 + lrp.z * rotM.e22;
                p.posx = posx + rp.x;
                p.posy = posy + rp.y;
                p.posz = posz + rp.z;
                pq.x = rotQ.x;
                pq.y = rotQ.y;
                pq.z = rotQ.z;
                pm.e00 = rotM.e00; pm.e01 = rotM.e01; pm.e02 = rotM.e02; pm.e03 = 0;
                pm.e10 = rotM.e10; pm.e11 = rotM.e11; pm.e12 = rotM.e12; pm.e13 = 0;
                pm.e20 = rotM.e20; pm.e21 = rotM.e21; pm.e22 = rotM.e22; pm.e23 = 0;
                pm.e30 = 0; pm.e31 = 0; pm.e32 = 0; pm.e33 = 1;
            }
        }
    }
    
    public function applyImpulse(relx:Number, rely:Number, relz:Number, forcex:Number, forcey:Number, forcez:Number):void {
        linV.x += forcex * invM;
        linV.y += forcey * invM;
        linV.z += forcez * invM;
        var tx:Number = rely * forcez - relz * forcey;
        var ty:Number = relz * forcex - relx * forcez;
        var tz:Number = relx * forcey - rely * forcex;
        angV.x += tx * invI.e00 + ty * invI.e01 + tz * invI.e02;
        angV.y += tx * invI.e10 + ty * invI.e11 + tz * invI.e12;
        angV.z += tx * invI.e20 + ty * invI.e21 + tz * invI.e22;
    }
    
    public function applyImpulseRev(relx:Number, rely:Number, relz:Number, forcex:Number, forcey:Number, forcez:Number):void {
        linV.x -= forcex * invM;
        linV.y -= forcey * invM;
        linV.z -= forcez * invM;
        var tx:Number = rely * forcez - relz * forcey;
        var ty:Number = relz * forcex - relx * forcez;
        var tz:Number = relx * forcey - rely * forcex;
        angV.x -= tx * invI.e00 + ty * invI.e01 + tz * invI.e02;
        angV.y -= tx * invI.e10 + ty * invI.e11 + tz * invI.e12;
        angV.z -= tx * invI.e20 + ty * invI.e21 + tz * invI.e22;
    }
}

class ContactConstraint {
    public var posx:Number;
    public var posy:Number;
    public var posz:Number;
    public var rel1x:Number;
    public var rel1y:Number;
    public var rel1z:Number;
    public var rel2x:Number;
    public var rel2y:Number;
    public var rel2z:Number;
    public var p1:Particle;
    public var p2:Particle;
    public var r1:Rigid;
    public var r2:Rigid;
    public var linV1:Vec3;
    public var linV2:Vec3;
    public var angV1:Vec3;
    public var angV2:Vec3;
    public var invI1e00:Number, invI1e01:Number, invI1e02:Number;
    public var invI1e10:Number, invI1e11:Number, invI1e12:Number;
    public var invI1e20:Number, invI1e21:Number, invI1e22:Number;
    public var invI2e00:Number, invI2e01:Number, invI2e02:Number;
    public var invI2e10:Number, invI2e11:Number, invI2e12:Number;
    public var invI2e20:Number, invI2e21:Number, invI2e22:Number;
    public var invM1:Number;
    public var invM2:Number;
    public var norx:Number;
    public var nory:Number;
    public var norz:Number;
    public var tan1x:Number;
    public var tan1y:Number;
    public var tan1z:Number;
    public var tan2x:Number;
    public var tan2y:Number;
    public var tan2z:Number;
    private var relVelx:Number;
    private var relVely:Number;
    private var relVelz:Number;
    private var forcex:Number;
    private var forcey:Number;
    private var forcez:Number;
    private var forceTmpx:Number;
    private var forceTmpy:Number;
    private var forceTmpz:Number;
    private var targetN:Number;
    private var denomN:Number;
    private var denomT1:Number;
    private var denomT2:Number;
    public var impulseN:Number;
    public var impulseT1:Number;
    public var impulseT2:Number;
    
    public function ContactConstraint() {
    }
    
    public function equals(id1:uint, id2:uint):Boolean {
        return p1.id == id1 && p2.id == id2 || p1.id == id2 && p2.id == id1;
    }
    
    public function init(p1:Particle, p2:Particle, bias:Number, px:Number, py:Number, pz:Number, nx:Number, ny:Number, nz:Number):void {
        this.p1 = p1;
        this.p2 = p2;
        r1 = p1.rigid;
        r2 = p2.rigid;
        linV1 = r1.linV;
        linV2 = r2.linV;
        angV1 = r1.angV;
        angV2 = r2.angV;
        invI1e00 = r1.invI.e00; invI1e01 = r1.invI.e01; invI1e02 = r1.invI.e02;
        invI1e10 = r1.invI.e10; invI1e11 = r1.invI.e11; invI1e12 = r1.invI.e12;
        invI1e20 = r1.invI.e20; invI1e21 = r1.invI.e21; invI1e22 = r1.invI.e22;
        invI2e00 = r2.invI.e00; invI2e01 = r2.invI.e01; invI2e02 = r2.invI.e02;
        invI2e10 = r2.invI.e10; invI2e11 = r2.invI.e11; invI2e12 = r2.invI.e12;
        invI2e20 = r2.invI.e20; invI2e21 = r2.invI.e21; invI2e22 = r2.invI.e22;
        invM1 = r1.invM;
        invM2 = r2.invM;
        posx = px;
        posy = py;
        posz = pz;
        rel1x = px - r1.posx;
        rel1y = py - r1.posy;
        rel1z = pz - r1.posz;
        rel2x = px - r2.posx;
        rel2y = py - r2.posy;
        rel2z = pz - r2.posz;
        norx = nx; // normal vector (direction of restitution)
        nory = ny;
        norz = nz;
        tan2x = ny;
        tan2y = -nz;
        tan2z = -nx;
        tan1x = nory * tan2z - norz * tan2y; // tangent vector (direction 1 of friction)
        tan1y = norz * tan2x - norx * tan2z;
        tan1z = norx * tan2y - nory * tan2x;
        var len:Number = 1 / Math.sqrt(tan1x * tan1x + tan1y * tan1y + tan1z * tan1z);
        tan1x *= len;
        tan1y *= len;
        tan1z *= len;
        tan2x = nory * tan1z - norz * tan1y; // binormal vector (direction 2 of friction)
        tan2y = norz * tan1x - norx * tan1z;
        tan2z = norx * tan1y - nory * tan1x;
        len = 1 / Math.sqrt(tan2x * tan2x + tan2y * tan2y + tan2z * tan2z);
        tan2x *= len;
        tan2y *= len;
        tan2z *= len;
        denomN = calculateDenominator(norx, nory, norz);
        denomT1 = calculateDenominator(tan1x, tan1y, tan1z);
        denomT2 = calculateDenominator(tan2x, tan2y, tan2z);
        var lv1:Vec3 = r1.linV;
        var lv2:Vec3 = r2.linV;
        var av1:Vec3 = r1.angV;
        var av2:Vec3 = r2.angV;
        relVelx = (lv2.x + av2.y * rel2z - av2.z * rel2y) - (lv1.x + av1.y * rel1z - av1.z * rel1y);
        relVely = (lv2.y + av2.z * rel2x - av2.x * rel2z) - (lv1.y + av1.z * rel1x - av1.x * rel1z);
        relVelz = (lv2.z + av2.x * rel2y - av2.y * rel2x) - (lv1.z + av1.x * rel1y - av1.y * rel1x);
        bias = bias - 2; // acceptable overlap error
        if (bias < 0) bias = 0;
        targetN = -(norx * relVelx + nory * relVely + norz * relVelz) * 0.2; // restitution coefficient
        if (targetN < 2) targetN = 0;
        targetN += bias * 0.2;
        impulseN = 0;
        impulseT1 = 0;
        impulseT2 = 0;
    }
    
    public function preSolve():void {
        // warm starting
        forcex = norx * impulseN + tan1x * impulseT1 + tan2x * impulseT2;
        forcey = nory * impulseN + tan1y * impulseT1 + tan2y * impulseT2;
        forcez = norz * impulseN + tan1z * impulseT1 + tan2z * impulseT2;
        var tx:Number;
        var ty:Number;
        var tz:Number;
        linV1.x += forcex * invM1;
        linV1.y += forcey * invM1;
        linV1.z += forcez * invM1;
        tx = rel1y * forcez - rel1z * forcey;
        ty = rel1z * forcex - rel1x * forcez;
        tz = rel1x * forcey - rel1y * forcex;
        angV1.x += tx * invI1e00 + ty * invI1e01 + tz * invI1e02;
        angV1.y += tx * invI1e10 + ty * invI1e11 + tz * invI1e12;
        angV1.z += tx * invI1e20 + ty * invI1e21 + tz * invI1e22;
        linV2.x -= forcex * invM2;
        linV2.y -= forcey * invM2;
        linV2.z -= forcez * invM2;
        tx = rel2y * forcez - rel2z * forcey;
        ty = rel2z * forcex - rel2x * forcez;
        tz = rel2x * forcey - rel2y * forcex;
        angV2.x -= tx * invI2e00 + ty * invI2e01 + tz * invI2e02;
        angV2.y -= tx * invI2e10 + ty * invI2e11 + tz * invI2e12;
        angV2.z -= tx * invI2e20 + ty * invI2e21 + tz * invI2e22;
    }
    
    private function calculateDenominator(nx:Number, ny:Number, nz:Number):Number {
        // 1/m1 + 1/m2 + n・([r1×n/I1]×r1 + [r2×n/I2]×r2)
        var tmp1x:Number = rel1y * nz - rel1z * ny;
        var tmp1y:Number = rel1z * nx - rel1x * nz;
        var tmp1z:Number = rel1x * ny - rel1y * nx;
        var tmp2x:Number = tmp1x * invI1e00 + tmp1y * invI1e01 + tmp1z * invI1e02;
        var tmp2y:Number = tmp1x * invI1e10 + tmp1y * invI1e11 + tmp1z * invI1e12;
        var tmp2z:Number = tmp1x * invI1e20 + tmp1y * invI1e21 + tmp1z * invI1e22;
        var dx:Number = tmp2y * rel1z - tmp2z * rel1y;
        var dy:Number = tmp2z * rel1x - tmp2x * rel1z;
        var dz:Number = tmp2x * rel1y - tmp2y * rel1x;
        tmp1x = rel2y * nz - rel2z * ny;
        tmp1y = rel2z * nx - rel2x * nz;
        tmp1z = rel2x * ny - rel2y * nx;
        tmp2x = tmp1x * invI2e00 + tmp1y * invI2e01 + tmp1z * invI2e02;
        tmp2y = tmp1x * invI2e10 + tmp1y * invI2e11 + tmp1z * invI2e12;
        tmp2z = tmp1x * invI2e20 + tmp1y * invI2e21 + tmp1z * invI2e22;
        dx += tmp2y * rel2z - tmp2z * rel2y;
        dy += tmp2z * rel2x - tmp2x * rel2z;
        dz += tmp2x * rel2y - tmp2y * rel2x;
        return 1 / (r1.invM + r2.invM + nx * dx + ny * dy + nz * dz);
    }
    
    public function solve():void {
        var tx:Number;
        var ty:Number;
        var tz:Number;
        // solve normal force
        var lv1:Vec3 = r1.linV;
        var lv2:Vec3 = r2.linV;
        var av1:Vec3 = r1.angV;
        var av2:Vec3 = r2.angV;
        var impulse1:Number;
        var old:Number;
        relVelx = (lv2.x + av2.y * rel2z - av2.z * rel2y) - (lv1.x + av1.y * rel1z - av1.z * rel1y);
        relVely = (lv2.y + av2.z * rel2x - av2.x * rel2z) - (lv1.y + av1.z * rel1x - av1.x * rel1z);
        relVelz = (lv2.z + av2.x * rel2y - av2.y * rel2x) - (lv1.z + av1.x * rel1y - av1.y * rel1x);
        impulse1 = (relVelx * norx + relVely * nory + relVelz * norz - targetN) * denomN;
        old = impulseN;
        impulseN += impulse1;
        if (impulseN > 0) impulseN = 0;
        impulse1 = impulseN - old;
        forcex = impulse1 * norx;
        forcey = impulse1 * nory;
        forcez = impulse1 * norz;
        linV1.x += forcex * invM1;
        linV1.y += forcey * invM1;
        linV1.z += forcez * invM1;
        tx = rel1y * forcez - rel1z * forcey;
        ty = rel1z * forcex - rel1x * forcez;
        tz = rel1x * forcey - rel1y * forcex;
        angV1.x += tx * invI1e00 + ty * invI1e01 + tz * invI1e02;
        angV1.y += tx * invI1e10 + ty * invI1e11 + tz * invI1e12;
        angV1.z += tx * invI1e20 + ty * invI1e21 + tz * invI1e22;
        linV2.x -= forcex * invM2;
        linV2.y -= forcey * invM2;
        linV2.z -= forcez * invM2;
        tx = rel2y * forcez - rel2z * forcey;
        ty = rel2z * forcex - rel2x * forcez;
        tz = rel2x * forcey - rel2y * forcex;
        angV2.x -= tx * invI2e00 + ty * invI2e01 + tz * invI2e02;
        angV2.y -= tx * invI2e10 + ty * invI2e11 + tz * invI2e12;
        angV2.z -= tx * invI2e20 + ty * invI2e21 + tz * invI2e22;
        
        // solve tangent force
        var impulse2:Number;
        var max:Number;
        relVelx = (lv2.x + av2.y * rel2z - av2.z * rel2y) - (lv1.x + av1.y * rel1z - av1.z * rel1y);
        relVely = (lv2.y + av2.z * rel2x - av2.x * rel2z) - (lv1.y + av1.z * rel1x - av1.x * rel1z);
        relVelz = (lv2.z + av2.x * rel2y - av2.y * rel2x) - (lv1.z + av1.x * rel1y - av1.y * rel1x);
        max = -impulseN * 0.25; // friction coefficient
        impulse1 = (relVelx * tan1x + relVely * tan1y + relVelz * tan1z) * denomT1;
        old = impulseT1;
        impulseT1 += impulse1;
        if (impulseT1 > max) impulseT1 = max;
        if (impulseT1 < -max) impulseT1 = -max;
        impulse1 = impulseT1 - old;
        impulse2 = (relVelx * tan2x + relVely * tan2y + relVelz * tan2z) * denomT2;
        old = impulseT2;
        impulseT2 += impulse2;
        if (impulseT2 > max) impulseT2 = max;
        if (impulseT2 < -max) impulseT2 = -max;
        impulse2 = impulseT2 - old;
        forcex = impulse1 * tan1x + impulse2 * tan2x;
        forcey = impulse1 * tan1y + impulse2 * tan2y;
        forcez = impulse1 * tan1z + impulse2 * tan2z;
        linV1.x += forcex * invM1;
        linV1.y += forcey * invM1;
        linV1.z += forcez * invM1;
        tx = rel1y * forcez - rel1z * forcey;
        ty = rel1z * forcex - rel1x * forcez;
        tz = rel1x * forcey - rel1y * forcex;
        angV1.x += tx * invI1e00 + ty * invI1e01 + tz * invI1e02;
        angV1.y += tx * invI1e10 + ty * invI1e11 + tz * invI1e12;
        angV1.z += tx * invI1e20 + ty * invI1e21 + tz * invI1e22;
        linV2.x -= forcex * invM2;
        linV2.y -= forcey * invM2;
        linV2.z -= forcez * invM2;
        tx = rel2y * forcez - rel2z * forcey;
        ty = rel2z * forcex - rel2x * forcez;
        tz = rel2x * forcey - rel2y * forcex;
        angV2.x -= tx * invI2e00 + ty * invI2e01 + tz * invI2e02;
        angV2.y -= tx * invI2e10 + ty * invI2e11 + tz * invI2e12;
        angV2.z -= tx * invI2e20 + ty * invI2e21 + tz * invI2e22;
    }
    
    public function postSolve():void {
        var c:ConstraintImpulseData;
        if (r1.invM > 0 && p1.numC < 8) {
            c = p1.cs[p1.numC++];
            c.impulseN = impulseN;
            c.impulseT1 = impulseT1;
            c.impulseT2 = impulseT2;
            c.id1 = p1.id;
            c.id2 = p2.id;
        }
        if (r2.invM > 0 && p2.numC < 8) {
            c = p2.cs[p2.numC++];
            c.impulseN = impulseN;
            c.impulseT1 = impulseT1;
            c.impulseT2 = impulseT2;
            c.id1 = p1.id;
            c.id2 = p2.id;
        }
    }
}

class ConstraintImpulseData {
    public var id1:uint;
    public var id2:uint;
    public var impulseN:Number;
    public var impulseT1:Number;
    public var impulseT2:Number;
}

class Particle {
    public static var STATIC_ID:uint = 0;
    public var posx:Number;
    public var posy:Number;
    public var posz:Number;
    public var relP:Vec3;
    public var relLocalP:Vec3;
    public var rotQ:Qua;
    public var rotM:Mat44;
    public var rigid:Rigid;
    public var id:uint;
    public var cs:Vector.<ConstraintImpulseData>;
    public var numC:uint;
    
    public function Particle(x:Number, y:Number, z:Number) {
        posx = x;
        posy = y;
        posz = z;
        relP = new Vec3();
        relLocalP = new Vec3();
        rotQ = new Qua();
        rotM = new Mat44();
        cs = new Vector.<ConstraintImpulseData>(8, true);
        for (var i:int = 0; i < 8; i++) {
            cs[i] = new ConstraintImpulseData();
        }
        id = STATIC_ID++;
        if (STATIC_ID > 0xffff) {
            STATIC_ID = 0;
        }
    }
    
    public function render(gl:ShrGL, meshIndex:uint):void {
        gl.bindVertexAttribute(meshIndex, 0, 0, "float3");
        gl.drawTriangles(meshIndex);
    }
}

class ShrGL {
    private var c3d:Context3D;
    private var w:uint;
    private var h:uint;
    private var aspect:Number;
    private var worldM:Mat44;
    private var viewM:Mat44;
    private var projM:Mat44;
    private var up:Vector.<Number>;
    private var stackM:Vector.<Mat44>;
    private var numStack:uint;
    private var vertexB:Vector.<VertexBuffer3D>;
    private var numVerticesB:Vector.<uint>;
    private var indexB:Vector.<IndexBuffer3D>;
    private var numIndicesB:Vector.<uint>;
    private var programs:Vector.<Program3D>;
    private var vertexCodes:Vector.<ByteArray>;
    private var fragmentCodes:Vector.<ByteArray>;
    
    public function ShrGL(c3d:Context3D, w:uint, h:uint) {
        this.c3d = c3d;
        c3d.setCulling("front"); // ClockWise
        this.w = w;
        this.h = h;
        aspect = h / w;
        worldM = new Mat44();
        viewM = new Mat44();
        projM = new Mat44();
        up = new Vector.<Number>(4, true);
        stackM = new Vector.<Mat44>(256, true);
        vertexB = new Vector.<VertexBuffer3D>(256, true);
        numVerticesB = new Vector.<uint>(256, true);
        indexB = new Vector.<IndexBuffer3D>(256, true);
        numIndicesB = new Vector.<uint>(256, true);
        programs = new Vector.<Program3D>(64, true);
        vertexCodes = new Vector.<ByteArray>(64, true);
        fragmentCodes = new Vector.<ByteArray>(64, true);
        numStack = 0;
    }
    
    public function camera(
        ex:Number, ey:Number, ez:Number,
        tx:Number = 0, ty:Number = 0, tz:Number = 0,
        ux:Number = 0, uy:Number = 1, uz:Number = 0
    ):void {
        viewM.viewMatrix(ex, ey, ez, tx, ty, tz, ux, uy, uz);
    }
    
    public function perspective(fovY:Number, near:Number = 0.5, far:Number = 2000):void {
        projM.perspectiveMatrix(fovY, aspect, near, far);
    }
    
    public function beginScene(r:Number, g:Number, b:Number):void {
        c3d.clear(r, g, b);
    }
    
    public function endScene():void {
        c3d.present();
    }
    
    public function setProgramConstantsMatrix(type:String, index:uint, m:Mat44):void {
        up[0] = m.e00; up[1] = m.e01; up[2] = m.e02; up[3] = m.e03;
        c3d.setProgramConstantsFromVector(type, index, up);
        up[0] = m.e10; up[1] = m.e11; up[2] = m.e12; up[3] = m.e13;
        c3d.setProgramConstantsFromVector(type, index + 1, up);
        up[0] = m.e20; up[1] = m.e21; up[2] = m.e22; up[3] = m.e23;
        c3d.setProgramConstantsFromVector(type, index + 2, up);
        up[0] = m.e30; up[1] = m.e31; up[2] = m.e32; up[3] = m.e33;
        c3d.setProgramConstantsFromVector(type, index + 3, up);
    }
    
    public function setProgramConstantsVector(type:String, index:uint, v:Vec3):void {
        up[0] = v.x; up[1] = v.y; up[2] = v.z; up[3] = 1;
        c3d.setProgramConstantsFromVector(type, index, up);
    }
    
    public function setProgramConstantsNumber(type:String, index:uint, x:Number, y:Number, z:Number, w:Number):void {
        up[0] = x; up[1] = y; up[2] = z; up[3] = w;
        c3d.setProgramConstantsFromVector(type, index, up);
    }
    
    public function registerProgram(programIndex:uint):void {
        if (programs[programIndex]) {
            programs[programIndex].dispose();
        }
        programs[programIndex] = c3d.createProgram();
        vertexCodes[programIndex] = null;
        fragmentCodes[programIndex] = null;
    }
    
    public function uploadVertexShader(programIndex:uint, vertexShaderCode:String):void {
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        agal.assemble("vertex", vertexShaderCode);
        vertexCodes[programIndex] = agal.agalcode;
        if (fragmentCodes[programIndex]) {
            programs[programIndex].upload(vertexCodes[programIndex], fragmentCodes[programIndex]);
        }
    }
    
    public function uploadFragmentShader(programIndex:uint, fragmentShaderCode:String):void {
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        agal.assemble("fragment", fragmentShaderCode);
        fragmentCodes[programIndex] = agal.agalcode;
        if (vertexCodes[programIndex]) {
            programs[programIndex].upload(vertexCodes[programIndex], fragmentCodes[programIndex]);
        }
    }
    
    public function createBasicFragmentShaderCode(
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
            "mov oc, ft0 \n"                            // col = ft0
        ;
        return code;
    }
    
    public function registerBuffer(bufferIndex:uint, numVertices:uint, variablePerVertex:uint, numIndices:uint):void {
        if (vertexB[bufferIndex]) {
            vertexB[bufferIndex].dispose();
            indexB[bufferIndex].dispose();
        }
        vertexB[bufferIndex] = c3d.createVertexBuffer(numVertices, variablePerVertex);
        numVerticesB[bufferIndex] = numVertices;
        indexB[bufferIndex] = c3d.createIndexBuffer(numIndices);
        numIndicesB[bufferIndex] = numIndices;
    }
    
    public function setProgram(programIndex:uint):void {
        c3d.setProgram(programs[programIndex]);
    }
    
    public function uploadVertexBuffer(bufferIndex:uint, vertices:Vector.<Number>):void {
        vertexB[bufferIndex].uploadFromVector(vertices, 0, numVerticesB[bufferIndex]);
    }
    
    public function uploadIndexBuffer(bufferIndex:uint, indices:Vector.<uint>):void {
        indexB[bufferIndex].uploadFromVector(indices, 0, numIndicesB[bufferIndex]);
    }
    
    public function bindVertexAttribute(bufferIndex:uint, index:uint, offset:uint, type:String):void {
        c3d.setVertexBufferAt(index, vertexB[bufferIndex], offset, type);
    }
    
    public function unbindVertexAttributes():void {
        c3d.setVertexBufferAt(0, null);
        c3d.setVertexBufferAt(1, null);
        c3d.setVertexBufferAt(2, null);
        c3d.setVertexBufferAt(3, null);
        c3d.setVertexBufferAt(4, null);
        c3d.setVertexBufferAt(5, null);
        c3d.setVertexBufferAt(6, null);
        c3d.setVertexBufferAt(7, null);
    }
    
    public function drawTriangles(bufferIndex:uint):void {
        c3d.drawTriangles(indexB[bufferIndex]);
    }
    
    public function translate(tx:Number, ty:Number, tz:Number):void {
        worldM.translate(worldM, tx, ty, tz);
    }
    
    public function scale(sx:Number, sy:Number, sz:Number):void {
        worldM.scale(worldM, sx, sy, sz);
    }
    
    public function rotate(rad:Number, ax:Number, ay:Number, az:Number):void {
        worldM.rotate(worldM, rad, ax, ay, az);
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
}

class Mat44 {
    public var e00:Number, e01:Number, e02:Number, e03:Number;
    public var e10:Number, e11:Number, e12:Number, e13:Number;
    public var e20:Number, e21:Number, e22:Number, e23:Number;
    public var e30:Number, e31:Number, e32:Number, e33:Number;
    
    public function Mat44(
        e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1
    ) {
        this.e00 = e00; this.e01 = e01; this.e02 = e02; this.e03 = e03;
        this.e10 = e10; this.e11 = e11; this.e12 = e12; this.e13 = e13;
        this.e20 = e20; this.e21 = e21; this.e22 = e22; this.e23 = e23;
        this.e30 = e30; this.e31 = e31; this.e32 = e32; this.e33 = e33;
    }
    
    public function init(
        e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1
    ):void {
        this.e00 = e00; this.e01 = e01; this.e02 = e02; this.e03 = e03;
        this.e10 = e10; this.e11 = e11; this.e12 = e12; this.e13 = e13;
        this.e20 = e20; this.e21 = e21; this.e22 = e22; this.e23 = e23;
        this.e30 = e30; this.e31 = e31; this.e32 = e32; this.e33 = e33;
    }
    
    public function add(m1:Mat44, m2:Mat44):void {
        e00 = m1.e00 + m2.e00; e01 = m1.e01 + m2.e01; e02 = m1.e02 + m2.e02; e03 = m1.e03 + m2.e03;
        e10 = m1.e10 + m2.e10; e11 = m1.e11 + m2.e11; e12 = m1.e12 + m2.e12; e13 = m1.e13 + m2.e13;
        e20 = m1.e20 + m2.e20; e21 = m1.e21 + m2.e21; e22 = m1.e22 + m2.e22; e23 = m1.e23 + m2.e23;
        e30 = m1.e30 + m2.e30; e31 = m1.e31 + m2.e31; e32 = m1.e32 + m2.e32; e33 = m1.e33 + m2.e33;
    }
    
    public function sub(m1:Mat44, m2:Mat44):void {
        e00 = m1.e00 - m2.e00; e01 = m1.e01 - m2.e01; e02 = m1.e02 - m2.e02; e03 = m1.e03 - m2.e03;
        e10 = m1.e10 - m2.e10; e11 = m1.e11 - m2.e11; e12 = m1.e12 - m2.e12; e13 = m1.e13 - m2.e13;
        e20 = m1.e20 - m2.e20; e21 = m1.e21 - m2.e21; e22 = m1.e22 - m2.e22; e23 = m1.e23 - m2.e23;
        e30 = m1.e30 - m2.e30; e31 = m1.e31 - m2.e31; e32 = m1.e32 - m2.e32; e33 = m1.e33 - m2.e33;
    }
    
    public function mul(m1:Mat44, m2:Mat44):void {
        var t00:Number = m1.e00 * m2.e00 + m1.e01 * m2.e10 + m1.e02 * m2.e20 + m1.e03 * m2.e30;
        var t01:Number = m1.e00 * m2.e01 + m1.e01 * m2.e11 + m1.e02 * m2.e21 + m1.e03 * m2.e31;
        var t02:Number = m1.e00 * m2.e02 + m1.e01 * m2.e12 + m1.e02 * m2.e22 + m1.e03 * m2.e32;
        var t03:Number = m1.e00 * m2.e03 + m1.e01 * m2.e13 + m1.e02 * m2.e23 + m1.e03 * m2.e33;
        var t10:Number = m1.e10 * m2.e00 + m1.e11 * m2.e10 + m1.e12 * m2.e20 + m1.e13 * m2.e30;
        var t11:Number = m1.e10 * m2.e01 + m1.e11 * m2.e11 + m1.e12 * m2.e21 + m1.e13 * m2.e31;
        var t12:Number = m1.e10 * m2.e02 + m1.e11 * m2.e12 + m1.e12 * m2.e22 + m1.e13 * m2.e32;
        var t13:Number = m1.e10 * m2.e03 + m1.e11 * m2.e13 + m1.e12 * m2.e23 + m1.e13 * m2.e33;
        var t20:Number = m1.e20 * m2.e00 + m1.e21 * m2.e10 + m1.e22 * m2.e20 + m1.e23 * m2.e30;
        var t21:Number = m1.e20 * m2.e01 + m1.e21 * m2.e11 + m1.e22 * m2.e21 + m1.e23 * m2.e31;
        var t22:Number = m1.e20 * m2.e02 + m1.e21 * m2.e12 + m1.e22 * m2.e22 + m1.e23 * m2.e32;
        var t23:Number = m1.e20 * m2.e03 + m1.e21 * m2.e13 + m1.e22 * m2.e23 + m1.e23 * m2.e33;
        var t30:Number = m1.e30 * m2.e00 + m1.e31 * m2.e10 + m1.e32 * m2.e20 + m1.e33 * m2.e30;
        var t31:Number = m1.e30 * m2.e01 + m1.e31 * m2.e11 + m1.e32 * m2.e21 + m1.e33 * m2.e31;
        var t32:Number = m1.e30 * m2.e02 + m1.e31 * m2.e12 + m1.e32 * m2.e22 + m1.e33 * m2.e32;
        var t33:Number = m1.e30 * m2.e03 + m1.e31 * m2.e13 + m1.e32 * m2.e23 + m1.e33 * m2.e33;
        e00 = t00; e01 = t01; e02 = t02; e03 = t03;
        e10 = t10; e11 = t11; e12 = t12; e13 = t13;
        e20 = t20; e21 = t21; e22 = t22; e23 = t23;
        e30 = t30; e31 = t31; e32 = t32; e33 = t33;
    }
    
    public function scale(m:Mat44, sx:Number, sy:Number, sz:Number, prepend:Boolean = false):void {
        var t00:Number, t01:Number, t02:Number, t03:Number;
        var t10:Number, t11:Number, t12:Number, t13:Number;
        var t20:Number, t21:Number, t22:Number, t23:Number;
        var t30:Number, t31:Number, t32:Number, t33:Number;
        if (prepend) {
            t00 = sx * m.e00;
            t01 = sx * m.e01;
            t02 = sx * m.e02;
            t03 = sx * m.e03;
            t10 = sy * m.e10;
            t11 = sy * m.e11;
            t12 = sy * m.e12;
            t13 = sy * m.e13;
            t20 = sz * m.e20;
            t21 = sz * m.e21;
            t22 = sz * m.e22;
            t23 = sz * m.e23;
            t30 = m.e30;
            t31 = m.e31;
            t32 = m.e32;
            t33 = m.e33;
        } else {
            t00 = m.e00 * sx;
            t01 = m.e01 * sy;
            t02 = m.e02 * sz;
            t03 = m.e03;
            t10 = m.e10 * sx;
            t11 = m.e11 * sy;
            t12 = m.e12 * sz;
            t13 = m.e13;
            t20 = m.e20 * sx;
            t21 = m.e21 * sy;
            t22 = m.e22 * sz;
            t23 = m.e23;
            t30 = m.e30 * sx;
            t31 = m.e31 * sy;
            t32 = m.e32 * sz;
            t33 = m.e33;
        }
        e00 = t00; e01 = t01; e02 = t02; e03 = t03;
        e10 = t10; e11 = t11; e12 = t12; e13 = t13;
        e20 = t20; e21 = t21; e22 = t22; e23 = t23;
        e30 = t30; e31 = t31; e32 = t32; e33 = t33;
    }
    
    public function rotate(m:Mat44, rad:Number, ax:Number, ay:Number, az:Number, prepend:Boolean = false):void {
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
        var t00:Number, t01:Number, t02:Number, t03:Number;
        var t10:Number, t11:Number, t12:Number, t13:Number;
        var t20:Number, t21:Number, t22:Number, t23:Number;
        var t30:Number, t31:Number, t32:Number, t33:Number;
        if (prepend) {
            t00 = r00 * m.e00 + r01 * m.e10 + r02 * m.e20;
            t01 = r00 * m.e01 + r01 * m.e11 + r02 * m.e21;
            t02 = r00 * m.e02 + r01 * m.e12 + r02 * m.e22;
            t03 = r00 * m.e03 + r01 * m.e13 + r02 * m.e23;
            t10 = r10 * m.e00 + r11 * m.e10 + r12 * m.e20;
            t11 = r10 * m.e01 + r11 * m.e11 + r12 * m.e21;
            t12 = r10 * m.e02 + r11 * m.e12 + r12 * m.e22;
            t13 = r10 * m.e03 + r11 * m.e13 + r12 * m.e23;
            t20 = r20 * m.e00 + r21 * m.e10 + r22 * m.e20;
            t21 = r20 * m.e01 + r21 * m.e11 + r22 * m.e21;
            t22 = r20 * m.e02 + r21 * m.e12 + r22 * m.e22;
            t23 = r20 * m.e03 + r21 * m.e13 + r22 * m.e23;
            t30 = m.e30;
            t31 = m.e31;
            t32 = m.e32;
            t33 = m.e33;
        } else {
            t00 = m.e00 * r00 + m.e01 * r10 + m.e02 * r20;
            t01 = m.e00 * r01 + m.e01 * r11 + m.e02 * r21;
            t02 = m.e00 * r02 + m.e01 * r12 + m.e02 * r22;
            t03 = m.e03;
            t10 = m.e10 * r00 + m.e11 * r10 + m.e12 * r20;
            t11 = m.e10 * r01 + m.e11 * r11 + m.e12 * r21;
            t12 = m.e10 * r02 + m.e11 * r12 + m.e12 * r22;
            t13 = m.e13;
            t20 = m.e20 * r00 + m.e21 * r10 + m.e22 * r20;
            t21 = m.e20 * r01 + m.e21 * r11 + m.e22 * r21;
            t22 = m.e20 * r02 + m.e21 * r12 + m.e22 * r22;
            t23 = m.e23;
            t30 = m.e30 * r00 + m.e31 * r10 + m.e32 * r20;
            t31 = m.e30 * r01 + m.e31 * r11 + m.e32 * r21;
            t32 = m.e30 * r02 + m.e31 * r12 + m.e32 * r22;
            t33 = m.e33;
        }
        e00 = t00; e01 = t01; e02 = t02; e03 = t03;
        e10 = t10; e11 = t11; e12 = t12; e13 = t13;
        e20 = t20; e21 = t21; e22 = t22; e23 = t23;
        e30 = t30; e31 = t31; e32 = t32; e33 = t33;
    }
    
    public function translate(m:Mat44, tx:Number, ty:Number, tz:Number, prepend:Boolean = false):void {
        var t00:Number, t01:Number, t02:Number, t03:Number;
        var t10:Number, t11:Number, t12:Number, t13:Number;
        var t20:Number, t21:Number, t22:Number, t23:Number;
        var t30:Number, t31:Number, t32:Number, t33:Number;
        if (prepend) {
            t00 = m.e00 + tx * m.e30;
            t01 = m.e01 + tx * m.e31;
            t02 = m.e02 + tx * m.e32;
            t03 = m.e03 + tx * m.e33;
            t10 = m.e10 + ty * m.e30;
            t11 = m.e11 + ty * m.e31;
            t12 = m.e12 + ty * m.e32;
            t13 = m.e13 + ty * m.e33;
            t20 = m.e20 + tz * m.e30;
            t21 = m.e21 + tz * m.e31;
            t22 = m.e22 + tz * m.e32;
            t23 = m.e23 + tz * m.e33;
            t30 = m.e30;
            t31 = m.e31;
            t32 = m.e32;
            t33 = m.e33;
        } else {
            t00 = m.e00;
            t01 = m.e01;
            t02 = m.e02;
            t03 = m.e00 * tx + m.e01 * ty + m.e02 * tz + m.e03;
            t10 = m.e10;
            t11 = m.e11;
            t12 = m.e12;
            t13 = m.e10 * tx + m.e11 * ty + m.e12 * tz + m.e13;
            t20 = m.e20;
            t21 = m.e21;
            t22 = m.e22;
            t23 = m.e20 * tx + m.e21 * ty + m.e22 * tz + m.e23;
            t30 = m.e30;
            t31 = m.e31;
            t32 = m.e32;
            t33 = m.e30 * tx + m.e31 * ty + m.e32 * tz + m.e33;
        }
        e00 = t00; e01 = t01; e02 = t02; e03 = t03;
        e10 = t10; e11 = t11; e12 = t12; e13 = t13;
        e20 = t20; e21 = t21; e22 = t22; e23 = t23;
        e30 = t30; e31 = t31; e32 = t32; e33 = t33;
    }
    
    public function invert(m:Mat44):void {
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
        e00 = det * t00; e01 = det * t01; e02 = det * t02; e03 = det * t03;
        e10 = det * t10; e11 = det * t11; e12 = det * t12; e13 = det * t13;
        e20 = det * t20; e21 = det * t21; e22 = det * t22; e23 = det * t23;
        e30 = det * t30; e31 = det * t31; e32 = det * t32; e33 = det * t33;
    }
    
    public function transpose(m:Mat44):void {
        var t00:Number = m.e00, t01:Number = m.e10, t02:Number = m.e20, t03:Number = m.e30;
        var t10:Number = m.e01, t11:Number = m.e11, t12:Number = m.e21, t13:Number = m.e31;
        var t20:Number = m.e02, t21:Number = m.e12, t22:Number = m.e22, t23:Number = m.e32;
        var t30:Number = m.e03, t31:Number = m.e13, t32:Number = m.e23, t33:Number = m.e33;
        e00 = t00; e01 = t01; e02 = t02; e03 = t03;
        e10 = t10; e11 = t11; e12 = t12; e13 = t13;
        e20 = t20; e21 = t21; e22 = t22; e23 = t23;
        e30 = t30; e31 = t31; e32 = t32; e33 = t33;
    }
    
    public function quaternion(q:Qua):void {
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
        e00 = 1 - yy - zz; e01 = xy - sz; e02 = xz + sy; e03 = 0;
        e10 = xy + sz; e11 = 1 - xx - zz; e12 = yz - sx; e13 = 0;
        e20 = xz - sy; e21 = yz + sx; e22 = 1 - xx - yy; e23 = 0;
        e30 = 0; e31 = 0; e32 = 0; e33 = 1;
    }
    
    public function viewMatrix(
        ex:Number, ey:Number, ez:Number,
        tx:Number, ty:Number, tz:Number,
        ux:Number, uy:Number, uz:Number
    ):void {
        var zx:Number = ex - tx;
        var zy:Number = ey - ty;
        var zz:Number = ez - tz;
        var tmp:Number = 1 / Math.sqrt(zx * zx + zy * zy + zz * zz);
        zx *= tmp;
        zy *= tmp;
        zz *= tmp;
        var xx:Number = uy * zz - uz * zy;
        var xy:Number = uz * zx - ux * zz;
        var xz:Number = ux * zy - uy * zx;
        tmp = 1 / Math.sqrt(xx * xx + xy * xy + xz * xz);
        xx *= tmp;
        xy *= tmp;
        xz *= tmp;
        var yx:Number = zy * xz - zz * xy;
        var yy:Number = zz * xx - zx * xz;
        var yz:Number = zx * xy - zy * xx;
        e00 = xx; e01 = xy; e02 = xz; e03 = -(xx * ex + xy * ey + xz * ez);
        e10 = yx; e11 = yy; e12 = yz; e13 = -(yx * ex + yy * ey + yz * ez);
        e20 = zx; e21 = zy; e22 = zz; e23 = -(zx * ex + zy * ey + zz * ez);
        e30 = 0; e31 = 0; e32 = 0; e33 = 1;
    }
    
    public function perspectiveMatrix(fovY:Number, aspect:Number, near:Number, far:Number):void {
        var h:Number = 1 / Math.tan(fovY * 0.5);
        var fnf:Number = far / (near - far);
        e00 = h / aspect; e01 = 0; e02 = 0; e03 = 0;
        e10 = 0; e11 = h; e12 = 0; e13 = 0;
        e20 = 0; e21 = 0; e22 = fnf; e23 = near * fnf;
        e30 = 0; e31 = 0; e32 = -1; e33 = 0;
    }
    
    public function copy(m:Mat44):void {
        e00 = m.e00; e01 = m.e01; e02 = m.e02; e03 = m.e03;
        e10 = m.e10; e11 = m.e11; e12 = m.e12; e13 = m.e13;
        e20 = m.e20; e21 = m.e21; e22 = m.e22; e23 = m.e23;
        e30 = m.e30; e31 = m.e31; e32 = m.e32; e33 = m.e33;
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
    
    public function init(x:Number = 0, y:Number = 0, z:Number = 0):void {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    public function add(v1:Vec3, v2:Vec3):void {
        x = v1.x + v2.x;
        y = v1.y + v2.y;
        z = v1.z + v2.z;
    }
    
    public function sub(v1:Vec3, v2:Vec3):void {
        x = v1.x - v2.x;
        y = v1.y - v2.y;
        z = v1.z - v2.z;
    }
    
    public function scale(v:Vec3, s:Number):void {
        x = v.x * s;
        y = v.y * s;
        z = v.z * s;
    }
    
    public function invert(v:Vec3):void {
        x = -v.x;
        y = -v.y;
        z = -v.z;
    }
    
    public function mulMatrix(m:Mat44, v:Vec3):void {
        var tx:Number = v.x * m.e00 + v.y * m.e01 + v.z * m.e02 + m.e03;
        var ty:Number = v.x * m.e10 + v.y * m.e11 + v.z * m.e12 + m.e13;
        var tz:Number = v.x * m.e20 + v.y * m.e21 + v.z * m.e22 + m.e23;
        x = tx;
        y = ty;
        z = tz;
    }
    
    public function mulQuaternion(q:Qua, v:Vec3):void {
        var xx:Number = q.x * q.x;
        var yy:Number = q.y * q.y;
        var zz:Number = q.z * q.z;
        var xy:Number = q.x * q.y;
        var yz:Number = q.y * q.z;
        var xz:Number = q.x * q.z;
        var sx:Number = q.s * q.x;
        var sy:Number = q.s * q.y;
        var sz:Number = q.s * q.z;
        var tx:Number = v.x * (0.5 - yy - zz) + v.y * (xy - sz) + v.z * (xz + sy);
        var ty:Number = v.x * (xy + sz) + v.y * (0.5 - xx - zz) + v.z * (yz - sx);
        var tz:Number = v.x * (xz - sy) + v.y * (yz + sx) + v.z * (0.5 - xx - yy);
        x = tx * 2;
        y = ty * 2;
        z = tz * 2;
    }
    
    public function dot(v:Vec3):Number {
        return x * v.x + y * v.y + z * v.z;
    }
    
    public function cross(v1:Vec3, v2:Vec3):void {
        var tx:Number = v1.y * v2.z - v1.z * v2.y;
        var ty:Number = v1.z * v2.x - v1.x * v2.z;
        var tz:Number = v1.x * v2.y - v1.y * v2.x;
        x = tx;
        y = ty;
        z = tz;
    }
    
    public function normalize(v:Vec3):void {
        var s:Number = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        if (s > 0) s = 1 / s;
        x = v.x * s;
        y = v.y * s;
        z = v.z * s;
    }
    
    public function length():Number {
        return Math.sqrt(x * x + y * y + z * z);
    }
    
    public function copy(v:Vec3):void {
        x = v.x;
        y = v.y;
        z = v.z;
    }
}

class Qua {
    public var s:Number;
    public var x:Number;
    public var y:Number;
    public var z:Number;
    
    public function Qua(s:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0) {
        this.s = s;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    public function init(s:Number = 1, x:Number = 0, y:Number = 0, z:Number = 0):void {
        this.s = s;
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    public function add(q1:Qua, q2:Qua):void {
        s = q1.s + q2.s;
        x = q1.x + q2.x;
        y = q1.y + q2.y;
        z = q1.z + q2.z;
    }
    
    public function sub(q1:Qua, q2:Qua):void {
        s = q1.s - q2.s;
        x = q1.x - q2.x;
        y = q1.y - q2.y;
        z = q1.z - q2.z;
    }
    
    public function scale(q:Qua, s:Number):void {
        this.s = q.s * s;
        x = q.x * s;
        y = q.y * s;
        z = q.z * s;
    }
    
    public function mul(q1:Qua, q2:Qua):void {
        var ts:Number = q1.s * q2.s - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
        var tx:Number = q1.s * q2.x + q1.x * q2.s + q1.y * q2.z - q1.z * q2.y;
        var ty:Number = q1.s * q2.y - q1.x * q2.z + q1.y * q2.s + q1.z * q2.x;
        var tz:Number = q1.s * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.s;
        
        s = ts;
        x = tx;
        y = ty;
        z = tz;
    }
    
    public function normalize(q:Qua):void {
        var len:Number = Math.sqrt(q.s * q.s + q.x * q.x + q.y * q.y + q.z * q.z);
        if (len > 0) len = 1 / len;
        s = q.s * len;
        x = q.x * len;
        y = q.y * len;
        z = q.z * len;
    }
    
    public function rotate(q:Qua, v:Vec3):void {
        var ts:Number = -q.x * v.x - q.y * v.y - q.z * v.z;
        var tx:Number = q.s * v.x + q.y * v.z - q.z * v.y;
        var ty:Number = q.s * v.y - q.x * v.z + q.z * v.x;
        var tz:Number = q.s * v.z + q.x * v.y - q.y * v.x;
        s = q.s + ts * 0.5;
        x = q.x + tx * 0.5;
        y = q.y + ty * 0.5;
        z = q.z + tz * 0.5;
    }
    
    public function copy(q:Qua):void {
        s = q.s;
        x = q.x;
        y = q.y;
        z = q.z;
    }
}
