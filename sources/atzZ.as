package {
    import com.adobe.utils.*;
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*;
    import net.hires.debug.*;
    
    /**
     * Cloth Simulation 3D
     * @author saharan
     */
    [SWF(width = "465", height = "465", frameRate = "60")]
    public class ClothSim3D extends Sprite {
        private var gl:EGraphics;
        private var cloth:EMesh;
        private var table:EMesh;
        private var ball:EMesh;
        private var res:EResourceLoader;
        private var s1:EShader;
        private var s2:EShader;
        private var rx:Number;
        private var ry:Number;
        private var rvx:Number;
        private var rvy:Number;
        private var press:Boolean;
        private var pmouseX:Number;
        private var pmouseY:Number;
        private var vs:Vector.<Vtx>;
        private var ss:Vector.<Spg>;
        private var bs:Vector.<Ball>;
        private var cs:Vector.<Cst>;
        private var numv:uint;
        private var nums:uint;
        private var numc:uint;
        
        public function ClothSim3D() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null): void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { press = true; });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void { press = false; });
            rx = 0;
            ry = 0;
            rvx = 0;
            rvy = 0;
            pmouseX = 0;
            pmouseY = 0;
            vs = new Vector.<Vtx>();
            ss = new Vector.<Spg>();
            bs = new Vector.<Ball>();
            cs = new Vector.<Cst>();
            //
            gl = new EGraphics(stage.stage3Ds[0], 465, 465, start);
        }
        
        public function createBall(divV:uint, divH:uint, radius:Number):EMesh {
            var mesh:EMesh = new EMesh();
            var theta:Number;
            var phi:Number;
            var dTheta:Number = Math.PI * 2 / divV;
            var dPhi:Number = Math.PI / divH;
            var numVertices:uint = (divH + 1) * divV - (divV - 1) * 2;
            mesh.addVertex(0, radius, 0);
            phi = dPhi;
            for (var i:int = 1; i < divH; i++) {
                theta = Math.PI * 2;
                for (var j:int = 0; j < divV; j++) {
                    var index:int = (i - 1) * divV + j + 1;
                    mesh.addVertex(radius * Math.sin(phi) * Math.cos(theta), radius * Math.cos(phi), radius * Math.sin(phi) * Math.sin(theta), j / divV, i / divH);
                    theta -= dTheta;
                }
                phi += dPhi;
            }
            mesh.addVertex(0, -radius, 0);
            for (i = 0; i < divH; i++) {
                for (j = 0; j < divV; j++) {
                    if (i == 0) {
                        mesh.addFace(0, (j + 1) % divV + 1, j + 1);
                    } else if (i == divH - 1) {
                        mesh.addFace(numVertices - 1, (i - 1) * divV + j + 1, (i - 1) * divV + (j + 1) % divV + 1);
                    } else {
                        mesh.addFace((i - 1) * divV + j + 1, (i - 1) * divV + (j + 1) % divV + 1, i * divV + (j + 1) % divV + 1);
                        mesh.addFace((i - 1) * divV + j + 1, i * divV + (j + 1) % divV + 1, i * divV + j + 1);
                    }
                }
            }
            return mesh;
        }
        
        public function createClothMesh(divV:uint, divH:uint, size:Number):EMesh {
            var mesh:EMesh = new EMesh();
            var x:Number = -size * 0.5;
            var y:Number = size * 0.5;
            var dx:Number = size / divV;
            var dy:Number = -size / divH;
            for (var j:int = 0; j <= divH; j++) {
                x = -size * 0.5;
                for (var i:int = 0; i <= divV; i++) {
                    mesh.addVertex(x, y, 0, i / divV, j / divH);
                    x += dx;
                }
                y += dy;
            }
            for (i = 0; i < divH; i++) {
                for (j = 0; j < divV; j++) {
                    mesh.addFace(i * (divV + 1) + j, i * (divV + 1) + j + 1, (i + 1) * (divV + 1) + j);
                    mesh.addFace(i * (divV + 1) + j + 1, (i + 1) * (divV + 1) + j + 1, (i + 1) * (divV + 1) + j);
                }
            }
            return mesh;
        }
        
        private function start():void {
            s1 = new EShader(vertexShaderCode, fragmentShaderCode, gl.context3D);
            s2 = new EShader(vertexShaderCode, fragmentShaderCodeBall, gl.context3D);
            var dx:uint = 24; // この辺は適当計算なのでいじると変になる
            var dy:uint = 24;
            var size:uint = 250;
            var x:Number;
            var y:Number = 0;
            var d:Number = size / dx;
            numv = 0;
            numc = 0;
            for (var j:int = 0; j <= dy; j++) {
                x = -size * 0.5;
                for (var i:int = 0; i <= dx; i++) {
                    var tv:Vector3D = new Vector3D(x, size * 0.7, y);
                    vs[numv++] = new Vtx(tv.x, tv.y, tv.z, j == 0 && (i % 12 == 0));
                    x += d;
                }
                y -= d;
            }
            nums = 0;
            for (j = 0; j <= dy; j++) {
                for (i = 0; i <= dx; i++) {
                    var idx:int = j * (dx + 1) + i;
                    if (i < dx) ss[nums++] = new Spg(vs[idx], vs[idx + 1], 0.6);
                    if (j < dy) ss[nums++] = new Spg(vs[idx], vs[idx + dx + 1], 0.6);
                    if (i < dx - 1) ss[nums++] = new Spg(vs[idx], vs[idx + 2], 0.3);
                    if (j < dy - 1) ss[nums++] = new Spg(vs[idx], vs[idx + (dx + 1) * 2], 0.3);
                    if (i < dx && j < dy) ss[nums++] = new Spg(vs[idx], vs[idx + dx + 2], 0.5);
                }
            }
            ball = createBall(16, 8, 1);
            ball.initVertexBuffer(gl);
            ball.initIndexBuffer(gl);
            ball.calcNormals();
            cloth = createClothMesh(dx, dy, size);
            cloth.initVertexBuffer(gl);
            cloth.initIndexBuffer(gl);
            table = new EMesh();
            table.addVertex(-200, -102, -200, 0, 0, 0.8, 0.8, 0.8);
            table.addVertex(200, -102, -200, 0, 0, 0.8, 0.8, 0.8);
            table.addVertex(200, -102, 200, 0, 0, 0.8, 0.8, 0.8);
            table.addVertex(-200, -102, 200, 0, 0, 0.8, 0.8, 0.8);
            table.addFace(0, 1, 2);
            table.addFace(0, 2, 3);
            table.initVertexBuffer(gl);
            table.initIndexBuffer(gl);
            table.calcNormals();
            var prj:PerspectiveMatrix3D = new PerspectiveMatrix3D();
            prj.perspectiveFieldOfViewRH(60 * Math.PI / 180, 1, 0.01, 2000);
            gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, prj, true);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event = null):void {
                var ang:Number = (ry - 90) * Math.PI / 180 + Math.random() * 0.5 - 0.25;
                var sin:Number = Math.sin(ang);
                var cos:Number = Math.cos(ang);
                var ang2:Number = ang + Math.random() * 0.25 - 0.125;
                var sin2:Number = Math.sin(ang2);
                var cos2:Number = Math.cos(ang2);
                bs.push(new Ball(-cos * 200, 50, -sin * 200, cos2 * 12, Math.random() * 3, sin2 * 12));
            } );
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event = null): void {
            if (press) {
                rvx += (mouseY - pmouseY) * 0.0625;
                rvy += (mouseX - pmouseX) * 0.0625;
            }
            pmouseX = mouseX;
            pmouseY = mouseY;
            rvx *= 0.9;
            rvy *= 0.9;
            rx += rvx;
            ry += rvy;
            if (rx > 90) rx += (90 - rx) * 0.5;
            if (rx < -90) rx += (-90 - rx) * 0.5;
            //
            simulate();
            var vts:Vector.<Number> = cloth.vertices;
            for (var i:int = EGraphics.OFFSET_VERTEX, j:int = 0; i < vts.length; i += EGraphics.NUM_DATAS_IN_VERTEX, j++) {
                vts[i] = vs[j].x;
                vts[i + 1] = vs[j].y;
                vts[i + 2] = vs[j].z;
            }
            cloth.calcNormals();
            //
            var mdl:Matrix3D = new Matrix3D();
            mdl.prependTranslation(0, 0, -400);
            mdl.prependRotation(rx, Vector3D.X_AXIS);
            mdl.prependRotation(ry, Vector3D.Y_AXIS);
            var lightVec:Vector3D = new Vector3D(0, -1, -2);
            lightVec.normalize();
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([lightVec.x, lightVec.y, lightVec.z, 1]));
            //
            gl.beginScene(0, 0, 0);
            gl.setShader(s1);
            gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mdl, true);
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([0.8, 0.2, 0.2, 1]));
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, Vector.<Number>([-1, 0, 0, 1]));
            gl.context3D.setCulling(Context3DTriangleFace.FRONT);
            gl.renderMesh(cloth); // render back
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, Vector.<Number>([1, 0, 0, 1]));
            gl.context3D.setCulling(Context3DTriangleFace.BACK);
            gl.renderMesh(cloth); // render front
            //
            gl.setShader(s2);
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, Vector.<Number>([0.8, 0.8, 0.8, 1]));
            gl.renderMesh(table);
            var numb:uint = bs.length;
            for (i = 0; i < numb; i++) {
                var mtx:Matrix3D = mdl.clone();
                mtx.prependTranslation(bs[i].x, bs[i].y, bs[i].z);
                mtx.prependScale(bs[i].r - 3, bs[i].r - 3, bs[i].r - 3);
                gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mtx, true);
                gl.context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, bs[i].c);
                gl.renderMesh(ball);
            }
            //
            gl.endScene();
        }
        
        private function simulate():void {
            var i:int;
            var j:int;
            while (numc > 0) cs[--numc] = null; // for GC
            var numb:uint = bs.length;
            for (j = 0; j < numb; j++) { // 簡易衝突判定 (n^2)
                var c:Cst;
                for (i = 0; i < numv; i++) {
                    c = vs[i].collide(bs[j]); // 球と布の接触
                    if (c) cs[numc++] = c;
                }
                for (i = 0; i < j; i++) {
                    c = bs[i].collide(bs[j]); // 球同士の接触
                    if (c) cs[numc++] = c;
                }
            }
            for (j = 0; j < 4; j++) { // 連立方程式を解く (反復回数で精度が上下)
                for (i = 0; i < nums; i++) ss[i].solve();
                for (i = 0; i < numc; i++) cs[i].solve();
                for (i = 0; i < numv; i++) { // 床との接触
                    var v:Vtx = vs[i];
                    if (v.y < -100) if (v.vy < 0) v.vy = 0;
                }
                for (i = 0; i < numb; i++) { // 床との接触
                    var b:Ball = bs[i];
                    if (b.x > -200 && b.x < 200 && b.z > -200 && b.z < 200 && b.y <= -100 + b.r && b.vy < 0) b.vy *= -0.4;
                }
            }
            for (i = 0; i < numb; i++) {
                bs[i].move();
                if (bs[i].y < -300) bs.splice(i--, 1), numb--; // 落下判定
            }
            for (i = 0; i < numv; i++) vs[i].move();
        }
    }
}

class Vtx { // Vertex : 質点
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
    public var fix:Boolean;
    public var m:Number; // 質量の逆数
    
    public function Vtx(x:Number, y:Number, z:Number, fix:Boolean) {
        this.x = x;
        this.y = y;
        this.z = z;
        vx = Math.random() * 0.01 - 0.005;
        vy = Math.random() * 0.01 - 0.005;
        vz = Math.random() * 0.01 - 0.005;
        this.fix = fix;
        m = fix ? 0 : 1; // 固定なら質量無限 (逆数0)
    }
    
    public function move():void {
        if (fix) vx = vy = vz = 0;
        else {
            x += vx;
            y += vy;
            if (y < -100) y = -100;
            z += vz;
            vy -= 0.15;
        }
    }
    
    public function collide(b:Ball):Cst {
        var dx:Number = x - b.x;
        if (dx < -b.r || dx > b.r) return null;
        var dy:Number = y - b.y;
        if (dy < -b.r || dy > b.r) return null;
        var dz:Number = z - b.z;
        if (dz < -b.r || dz > b.r) return null;
        var d2:Number = dx * dx + dy * dy + dz * dz;
        if (d2 < b.r * b.r) {
            var d:Number = 1 / Math.sqrt(d2);
            dx *= d;
            dy *= d;
            dz *= d;
            return new Cst(this, b, null, dx, dy, dz, 0);
        }
        return null;
    }
}

class Spg { // Spring : ばねダンパモデル
    public var v1:Vtx;
    public var v2:Vtx;
    private var rest:Number; // 休息距離
    private var str:Number;
    private var m:Number;
    
    public function Spg(v1:Vtx, v2:Vtx, str:Number) {
        this.v1 = v1;
        this.v2 = v2;
        this.str = str;
        m = 1 / (v1.m + v2.m); // 適正質量
        rest = Math.sqrt((v2.x - v1.x) * (v2.x - v1.x) + (v2.y - v1.y) * (v2.y - v1.y) + (v2.z - v1.z) * (v2.z - v1.z));
    }
    
    public function solve():void { // 後退オイラー法
        if (v1.m + v2.m == 0) return;
        var dx:Number = v2.x - v1.x + v2.vx - v1.vx; // t+1 時でのばね係数を計算
        var dy:Number = v2.y - v1.y + v2.vy - v1.vy;
        var dz:Number = v2.z - v1.z + v2.vz - v1.vz;
        var dist:Number = Math.sqrt(dx * dx + dy * dy + dz * dz);
        var fs:Number = (dist - rest) * str;
        dist = 1 / dist;
        var nx:Number = dx * dist;
        var ny:Number = dy * dist;
        var nz:Number = dz * dist;
        var fd:Number = ((v2.vx - v1.vx) * nx + (v2.vy - v1.vy) * ny + (v2.vz - v1.vz) * nz) * 0.4 * str;
        var f:Number = (fs + fd) * m;
        var fx:Number = nx * f;
        var fy:Number = ny * f;
        var fz:Number = nz * f;
        v1.vx += fx * v1.m;
        v1.vy += fy * v1.m;
        v1.vz += fz * v1.m;
        v2.vx -= fx * v2.m;
        v2.vy -= fy * v2.m;
        v2.vz -= fz * v2.m;
    }
}

class Cst { // Constrant : 拘束 (接触点)
    public var v:Vtx;
    public var b1:Ball;
    public var b2:Ball;
    private var btb:Boolean;
    private var nx:Number;
    private var ny:Number;
    private var nz:Number;
    private var tv:Number;
    private var f:Number;
    private var m:Number;
    
    public function Cst(v:Vtx, b1:Ball, b2:Ball, nx:Number, ny:Number, nz:Number, tv:Number) {
        this.v = v;
        btb = !v;
        this.b1 = b1;
        this.b2 = b2;
        this.nx = nx;
        this.ny = ny;
        this.nz = nz;
        this.tv = tv; // 目標とする相対速度 (eを反発係数として -e * 法線方向の相対速度)
        if (btb) m = 1 / (b1.m + b2.m); // 適正質量
        else m = 1 / (v.m + b1.m);
        f = 0; // Warm Startを使う場合はこの値を前回のループの値に設定する (安定性が格段に上昇)
    }
    
    public function solve():void { // めり込まない拘束条件 : 法線方向の相対速度 >= 0
        var r:Number;
        var fce:Number;
        var nf:Number;
        var sub:Number;
        var fx:Number;
        var fy:Number;
        var fz:Number;
        if (btb) { // ball vs ball
            r = (b2.vx - b1.vx) * nx + (b2.vy - b1.vy) * ny + (b2.vz - b1.vz) * nz; // 相対速度
            fce = m * (r - tv); // 適正質量を掛ける
            nf = fce + f;
            if (nf < 0) nf = 0; // 離れる方向へは力を適用しない
            sub = nf - f; // 前回の解との差分を適用
            fx = nx * sub;
            fy = ny * sub;
            fz = nz * sub;
            b1.vx += fx * b1.m;
            b1.vy += fy * b1.m;
            b1.vz += fz * b1.m;
            b2.vx -= fx * b2.m;
            b2.vy -= fy * b2.m;
            b2.vz -= fz * b2.m;
            f = nf; // 力を蓄積 (この方法は垂直効力や摩擦力など解が非線形である場合のみ有効)
        } else { // vertex vs ball
            r = (b1.vx - v.vx) * nx + (b1.vy - v.vy) * ny + (b1.vz - v.vz) * nz; // 相対速度
            fce = m * (r - tv); // 適正質量を掛ける
            nf = fce + f;
            if (nf < 0) nf = 0; // 離れる方向へは力を適用しない
            sub = nf - f; // 前回の解との差分を適用
            fx = nx * sub;
            fy = ny * sub;
            fz = nz * sub;
            v.vx += fx * v.m;
            v.vy += fy * v.m;
            v.vz += fz * v.m;
            b1.vx -= fx * b1.m;
            b1.vy -= fy * b1.m;
            b1.vz -= fz * b1.m;
            f = nf; // 力を蓄積 (この方法は垂直効力や摩擦力など解が非線形である場合のみ有効)
        }
    }
}

class Ball { // Ball : 球
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var c:Vector.<Number>;
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
    public var r:Number;
    public var m:Number;
    
    public function Ball(x:Number, y:Number, z:Number, vx:Number = 0, vy:Number = 0, vz:Number = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.vx = vx;
        this.vy = vy;
        this.vz = vz;
        r = 25 + Math.random() * 25;
        m = 1 / (r * r * r * 4 / 3 * Math.PI * 0.00025); // 質量の逆数
        c = new Vector.<Number>(4, true);
        c[0] = 0.3 + Math.random() * 0.7;
        c[1] = 0.3 + Math.random() * 0.7;
        c[2] = 0.3 + Math.random() * 0.7;
        c[3] = 1;
    }
    
    public function move():void {
        x += vx;
        y += vy;
        if (x > -200 && x < 200 && z > -200 && z < 200 && y < -100 + r) y = -100 + r;
        z += vz;
        vy -= 0.15;
    }
    
    public function collide(b:Ball):Cst {
        var dx:Number = x - b.x;
        var dy:Number = y - b.y;
        var dz:Number = z - b.z;
        var d2:Number = dx * dx + dy * dy + dz * dz;
        if (d2 < (r + b.r) * (r + b.r)) {
            var d:Number = 1 / Math.sqrt(d2);
            dx *= d;
            dy *= d;
            dz *= d;
            return new Cst(null, this, b, dx, dy, dz, 0);
        }
        return null;
    }
}

var vertexShaderCode:String = <![CDATA[
m44 vt0, va0, vc0;
mov v5, vt0.xyz; // set vertex position
m44 vt0, vt0, vc4;
mov op, vt0;
mov vt0, va1;
mul vt0.xyz, vt0.xyz, vc8.xyz;
mov v0, vt0; // vertex color
m33 vt0.xyz, va2.xyz, vc0; // transform vertex normal
nrm vt0.xyz, vt0.xyz; // normalize vertex normal
mov v1, vt0.xyz; // set vertex normal
mov v2, va3.xy; // set vertex uv
]]>;

var fragmentShaderCode:String = <![CDATA[
mov ft0, v1; // normal
mov ft1.xyz, fc0.xyz; // light vector
mul ft1.xyz, ft1.xyz, fc9.xxx;
nrm ft1.xyz, ft1.xyz;
dp3 ft7.x, ft0.xyz, ft1.xyz; // calc brightness
mul ft7.x, ft7.x, fc11.x; // back or front
sat ft7.x, ft7.x;
add ft7.x, ft7.x, fc10.w;
sat ft7.x, ft7.x;

mov ft2.xyz, v5.xyz; // calc view vector
mul ft2.xyz, ft2.xyz, fc9.xxx;
nrm ft2.xyz, ft2.xyz;

mul ft4.xyz, v0.xyz, ft7.xxx;

mul ft1.xyz, ft1.xyz, fc9.xxx; // calc reflection vector
dp3 ft3.x, ft1.xyz, ft0.xyz;
mul ft3.x, ft3.x, fc8.w;
mul ft3.xyz, ft0.xyz, ft3.xxx;
sub ft3.xyz, ft1.xyz, ft3.xyz;
nrm ft3.xyz, ft3.xyz;

dp3 ft1.x, ft2.xyz, ft3.xyz; // calc specular
sat ft1.x, ft1.x;
pow ft7.y, ft1.x, fc9.y;
mul ft7.y, ft7.y, fc10.w;
add ft4.xyz, ft4.xyz, ft7.yyy; // add specular
sat ft4.xyz, ft4.xyz; // clamp
mov ft4.w, fc8.z;

mov oc, ft4;
]]>;

var fragmentShaderCodeBall:String = <![CDATA[
mov ft0, v1; // normal
mov ft1.xyz, fc0.xyz; // light vector
mul ft1.xyz, ft1.xyz, fc9.xxx;
nrm ft1.xyz, ft1.xyz;
dp3 ft7.x, ft0.xyz, ft1.xyz; // calc brightness
sat ft7.x, ft7.x;
add ft7.x, ft7.x, fc10.w;
sat ft7.x, ft7.x;

mov ft2.xyz, v5.xyz; // calc view vector
mul ft2.xyz, ft2.xyz, fc9.xxx;
nrm ft2.xyz, ft2.xyz;

mul ft4.xyz, v0.xyz, ft7.xxx;

mul ft1.xyz, ft1.xyz, fc9.xxx; // calc reflection vector
dp3 ft3.x, ft1.xyz, ft0.xyz;
mul ft3.x, ft3.x, fc8.w;
mul ft3.xyz, ft0.xyz, ft3.xxx;
sub ft3.xyz, ft1.xyz, ft3.xyz;
nrm ft3.xyz, ft3.xyz;

dp3 ft1.x, ft2.xyz, ft3.xyz; // calc specular
sat ft1.x, ft1.x;
pow ft7.y, ft1.x, fc9.w;
mul ft7.y, ft7.y, fc10.w;
add ft4.xyz, ft4.xyz, ft7.yyy; // add specular
sat ft4.xyz, ft4.xyz; // clamp
mov ft4.w, fc8.z;

mov oc, ft4;
]]>;

// ika shrGL

import flash.display.*;
import flash.events.*;
import flash.display3D.*;
import flash.display3D.textures.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import com.adobe.utils.*;
import flash.utils.*;

class EGraphics {
    public static const OFFSET_VERTEX:uint = 0;
    public static const OFFSET_NORMAL:uint = 3;
    public static const OFFSET_COLOR:uint = 6;
    public static const OFFSET_UV:uint = 10;
    public static const NUM_DATAS_IN_VERTEX:uint = 13;
    //
    private var s3d:Stage3D;
    private var c3d:Context3D;
    private var p3d:Program3D;
    private var callback:Function;
    private var width:int;
    private var height:int;
    //
    private var modelview:Matrix3D;
    private var projection:Matrix3D;
    
    public function EGraphics(s3d:Stage3D, width:int, height:int, callback:Function) {
        this.s3d = s3d;
        this.width = width;
        this.height = height;
        this.callback = callback;
        s3d.addEventListener(Event.CONTEXT3D_CREATE, init);
        s3d.requestContext3D(Context3DRenderMode.AUTO);
    }
    
    private function init(e:Event):void {
        c3d = s3d.context3D;
        c3d.enableErrorChecking = true;
        c3d.configureBackBuffer(width, height, 0, true);
        c3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA,
            Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        p3d = c3d.createProgram();
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, Vector.<Number>([0, 0.5, 1, 2]));
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9, Vector.<Number>([-1, 8, 16, 32]));
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, Vector.<Number>([0.03125, 0.0625, 0.125, 0.25]));
        c3d.setProgram(p3d);
        callback();
    }
    
    public function setShader(shader:EShader):void {
        c3d.setProgram(shader.program3D);
    }
    
    public function renderMesh(mesh:EMesh):void {
        var vtxbuf:VertexBuffer3D = mesh.vertexBuffer;
        c3d.setVertexBufferAt(0, vtxbuf, OFFSET_VERTEX, Context3DVertexBufferFormat.FLOAT_3);
        c3d.setVertexBufferAt(1, vtxbuf, OFFSET_COLOR, Context3DVertexBufferFormat.FLOAT_4);
        c3d.setVertexBufferAt(2, vtxbuf, OFFSET_NORMAL, Context3DVertexBufferFormat.FLOAT_3);
        c3d.setVertexBufferAt(3, vtxbuf, OFFSET_UV, Context3DVertexBufferFormat.FLOAT_2);
        vtxbuf.uploadFromVector(mesh.vertices, 0, mesh.numVertices);
        var idxbuf:IndexBuffer3D = mesh.indexBuffer;
        idxbuf.uploadFromVector(mesh.indices, 0, mesh.numIndices);
        c3d.drawTriangles(idxbuf);
    }
    
    public function createVertexBuffer(numVertices:uint):VertexBuffer3D {
        return c3d.createVertexBuffer(numVertices, NUM_DATAS_IN_VERTEX);
    }
    
    public function createIndexBuffer(numIndices:uint):IndexBuffer3D {
        return c3d.createIndexBuffer(numIndices);
    }
    
    public function beginScene(r:Number = 0, g:Number = 0, b:Number = 0):void {
        c3d.clear(r, g, b, 1);
    }
    
    public function endScene():void {
        c3d.present();
    }
    
    public function get stage3D():Stage3D {
        return s3d;
    }
    
    public function get context3D():Context3D {
        return c3d;
    }
}

class EMesh {
    private var vts:Vector.<Number>;
    private var ids:Vector.<uint>;
    //
    private var vtxbuf:VertexBuffer3D;
    private var idxbuf:IndexBuffer3D;
    //
    private var numvtx:uint;
    private var numfce:uint;
    
    public function EMesh() {
        vts = new Vector.<Number>();
        ids = new Vector.<uint>();
        //
        vtxbuf = null;
        idxbuf = null;
        //
        numvtx = 0;
        numfce = 0;
    }
    
    public function addVertex(x:Number, y:Number, z:Number, u:Number = 0, v:Number = 0, r:Number = 1, g:Number = 1, b:Number = 1):void {
        var idx:uint = numvtx * EGraphics.NUM_DATAS_IN_VERTEX;
        vts.length += EGraphics.NUM_DATAS_IN_VERTEX;
        var i:uint = idx + EGraphics.OFFSET_VERTEX;
        vts[i] = x;
        vts[i + 1] = y;
        vts[i + 2] = z;
        i = idx + EGraphics.OFFSET_COLOR;
        vts[i] = r;
        vts[i + 1] = g;
        vts[i + 2] = b;
        i = idx + EGraphics.OFFSET_UV;
        vts[i] = u;
        vts[i + 1] = v;
        numvtx++;
    }
    
    public function addFace(i1:uint, i2:uint, i3:uint):void {
        var idx:uint = numfce * 3;
        ids[idx++] = i1;
        ids[idx++] = i2;
        ids[idx++] = i3;
        numfce++;
    }
    
    public function calcNormals():void {
        const numDatasInVertex:uint = EGraphics.NUM_DATAS_IN_VERTEX;
        const offsetVertex:uint = EGraphics.OFFSET_VERTEX;
        const offsetNormal:uint = EGraphics.OFFSET_NORMAL;
        var idx:uint = 0;
        var i:uint;
        var num:uint = numvtx * numDatasInVertex;
        for (i = offsetNormal; i < num; i += numDatasInVertex) {
            vts[i] = 0;
            vts[i + 1] = 0;
            vts[i + 2] = 0;
        }
        for (i = 0; i < numfce; i++) {
            var i1:uint = ids[idx] * numDatasInVertex;
            var i2:uint = ids[idx + 1] * numDatasInVertex;
            var i3:uint = ids[idx + 2] * numDatasInVertex;
            var v1:uint = i1 + offsetVertex;
            var v2:uint = i2 + offsetVertex;
            var v3:uint = i3 + offsetVertex;
            //
            var x1:Number = vts[v2] - vts[v1];
            var y1:Number = vts[v2 + 1] - vts[v1 + 1];
            var z1:Number = vts[v2 + 2] - vts[v1 + 2];
            var x2:Number = vts[v3] - vts[v1];
            var y2:Number = vts[v3 + 1] - vts[v1 + 1];
            var z2:Number = vts[v3 + 2] - vts[v1 + 2];
            //
            var nx:Number = y2 * z1 - z2 * y1;
            var ny:Number = z2 * x1 - x2 * z1;
            var nz:Number = x2 * y1 - y2 * x1;
            var nl:Number = 1 / Math.sqrt(nx * nx + ny * ny + nz * nz);
            nx *= nl;
            ny *= nl;
            nz *= nl;
            //
            v1 = i1 + offsetNormal;
            v2 = i2 + offsetNormal;
            v3 = i3 + offsetNormal;
            vts[v1] += nx;
            vts[v1 + 1] += ny;
            vts[v1 + 2] += nz;
            vts[v2] += nx;
            vts[v2 + 1] += ny;
            vts[v2 + 2] += nz;
            vts[v3] += nx;
            vts[v3 + 1] += ny;
            vts[v3 + 2] += nz;
            idx += 3;
        }
    }
    
    public function initVertexBuffer(g:EGraphics):void {
        vtxbuf = g.createVertexBuffer(numvtx);
    }
    
    public function initIndexBuffer(g:EGraphics):void {
        idxbuf = g.createIndexBuffer(numfce * 3);
    }
    
    public function get numVertices():uint {
        return numvtx;
    }
    
    public function get numIndices():uint {
        return numfce * 3;
    }
    
    public function get vertices():Vector.<Number> {
        return vts;
    }
    
    public function get indices():Vector.<uint> {
        return ids;
    }
    
    public function get vertexBuffer():VertexBuffer3D {
        return vtxbuf;
    }
    
    public function get indexBuffer():IndexBuffer3D {
        return idxbuf;
    }
}

class EShader {
    private var vtxcode:ByteArray;
    private var frgcode:ByteArray;
    private var p3d:Program3D;
    
    public function EShader(vertex:String, fragment:String, c3d:Context3D) {
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        agal.assemble(Context3DProgramType.VERTEX, vertex);
        vtxcode = agal.agalcode;
        agal.assemble(Context3DProgramType.FRAGMENT, fragment);
        frgcode = agal.agalcode;
        p3d = c3d.createProgram();
        p3d.upload(vtxcode, frgcode);
    }
    
    public function get vertexShader():ByteArray {
        return vtxcode;
    }
    
    public function get fragmentShader():ByteArray {
        return frgcode;
    }
    
    public function get program3D():Program3D {
        return p3d;
    }
}

class EResourceLoader {
    private var result:Array;
    private var loadings:Vector.<Function>;
    private var numLoadings:uint;
    private var callback:Function;
    
    public function EResourceLoader(callback:Function) {
        this.callback = callback;
        loadings = new Vector.<Function>();
        numLoadings = 0;
        result = new Array();
    }
    
    public function addImage(url:String, name:String):void {
        var loader:Loader = new Loader();
        loadings[numLoadings++] = function():void {
            loader.load(new URLRequest(url), new LoaderContext(true));
        };
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
            result[name] = loader.content;
            if (--numLoadings == 0) callback();
        });
    }
    
    public function getImage(name:String):Bitmap {
        return Bitmap(result[name]);
    }
    
    public function loadAll():void {
        for (var i:uint = 0; i < numLoadings; i++) {
            loadings[i]();
            loadings[i] = null;
        }
    }
}
