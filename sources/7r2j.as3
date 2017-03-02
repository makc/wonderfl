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
     * Bump mapping earth
     * @author saharan
     */
    [SWF(width = "465", height = "465", frameRate = "60")]
    public class Main extends Sprite {
        private var gl:EGraphics;
        private var earth:EMesh;
        private var cloud:EMesh;
        private var c:uint;
        private var res:EResourceLoader;
        private var s1:EShader;
        private var s2:EShader;
        private var tz:Number;
        private var rx:Number;
        private var ry:Number;
        private var rvx:Number;
        private var rvy:Number;
        private var press:Boolean;
        private var pmouseX:Number;
        private var pmouseY:Number;
        
        public function Main() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null): void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void { press = true; });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void { press = false; });
            tz = 50;
            rx = 0;
            ry = 0;
            rvx = 0;
            rvy = 0;
            pmouseX = 0;
            pmouseY = 0;
            s1 = new EShader(vertexShaderCode, fragmentShaderEarth);
            s2 = new EShader(vertexShaderCode, fragmentShaderCloud);
            //
            res = new EResourceLoader(start);
            res.addImage("http://assets.wonderfl.net/images/related_images/5/5b/5b7f/5b7f96f67c33efc4503e432fe7056196b61a02d8", "tex");
            res.addImage("http://assets.wonderfl.net/images/related_images/d/db/db57/db579c79a73a8bd7a0855975dab8c39593562f70", "nor");
            res.addImage("http://assets.wonderfl.net/images/related_images/0/06/0642/0642bbe228d57fb802a9423dc72544f04b423d29", "spc");
            res.addImage("http://assets.wonderfl.net/images/related_images/0/03/032e/032e06a8bde3f7feaa35b4a3d107dd3d4cf269a2", "cld");
            res.addImage("http://assets.wonderfl.net/images/related_images/3/3a/3a3c/3a3c3b2bee59e56d4f7b4433b35f8988049946f8", "lgt");
            gl = new EGraphics(stage.stage3Ds[0], 465, 465, res.loadAll);
        }
        
        private function createSphere(divV:uint, divH:uint, radius:Number):EMesh {
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
                    mesh.addVertex(radius * Math.sin(phi) * Math.cos(theta), radius * Math.cos(phi), radius * Math.sin(phi) * Math.sin(theta));
                    theta -= dTheta;
                }
                phi += dPhi;
            }
            mesh.addVertex(0, -radius, 0);
            var invV:Number = 1 / divV;
            var invH:Number = 1 / divH;
            var u:Number = 0;
            var v:Number = 0;
            for (i = 0; i < divH; i++) {
                u = 0;
                for (j = 0; j < divV; j++) {
                    if (i == 0) {
                        mesh.addFace(0, (j + 1) % divV + 1, j + 1,
                        u + invV * 0.5, v, u, v + invH, u + invV, v + invH);
                    } else if (i == divH - 1) {
                        mesh.addFace(numVertices - 1, (i - 1) * divV + j + 1, (i - 1) * divV + (j + 1) % divV + 1,
                        u + invV * 0.5, v + invH, u + invV, v, u, v);
                    } else {
                        mesh.addFace((i - 1) * divV + j + 1, (i - 1) * divV + (j + 1) % divV + 1, i * divV + (j + 1) % divV + 1,
                        u, v, u + invV, v, u + invV, v + invH);
                        mesh.addFace((i - 1) * divV + j + 1, i * divV + (j + 1) % divV + 1, i * divV + j + 1,
                        u, v, u + invV, v + invH, u, v + invH);
                    }
                    u += invV;
                }
                v += invH;
            }
            return mesh;
        }
        
        private function start():void {
            earth = createSphere(64, 32, 2);
            earth.initVertexBuffer(gl);
            earth.initIndexBuffer(gl);
            earth.calcNormals();
            earth.updateBuffers();
            cloud = createSphere(64, 32, 2.05);
            cloud.initVertexBuffer(gl);
            cloud.initIndexBuffer(gl);
            cloud.calcNormals();
            cloud.updateBuffers();
            var tex:Texture = gl.context3D.createTexture(1024, 512, Context3DTextureFormat.BGRA, true);
            tex.uploadFromBitmapData(res.getImage("tex").bitmapData);
            gl.context3D.setTextureAt(0, tex);
            tex = gl.context3D.createTexture(1024, 512, Context3DTextureFormat.BGRA, true);
            tex.uploadFromBitmapData(res.getImage("nor").bitmapData);
            gl.context3D.setTextureAt(1, tex);
            tex = gl.context3D.createTexture(1024, 512, Context3DTextureFormat.BGRA, true);
            tex.uploadFromBitmapData(res.getImage("spc").bitmapData);
            gl.context3D.setTextureAt(2, tex);
            tex = gl.context3D.createTexture(1024, 512, Context3DTextureFormat.BGRA, true);
            tex.uploadFromBitmapData(res.getImage("cld").bitmapData);
            gl.context3D.setTextureAt(3, tex);
            tex = gl.context3D.createTexture(1024, 512, Context3DTextureFormat.BGRA, true);
            tex.uploadFromBitmapData(res.getImage("lgt").bitmapData);
            gl.context3D.setTextureAt(4, tex);
            var prj:PerspectiveMatrix3D = new PerspectiveMatrix3D();
            prj.perspectiveFieldOfViewRH(60 * Math.PI / 180, 1, 0.01, 100);
            gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, prj, true);
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event = null): void {
            c++;
            //
            tz += (5 - tz) * 0.03125;
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
            if (rx < -90) rx += ( -90 - rx) * 0.5;
            //
            var mdl:Matrix3D = new Matrix3D();
            mdl.prependTranslation(0, 0, -tz);
            mdl.prependRotation(rx, Vector3D.X_AXIS);
            mdl.prependRotation(ry, Vector3D.Y_AXIS);
            var lightVec:Vector3D = new Vector3D(Math.cos(c / 500 - 2), 0, Math.sin(c / 500 - 2));
            lightVec = mdl.deltaTransformVector(lightVec);
            gl.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([lightVec.x, lightVec.y, lightVec.z, 1]));
            gl.beginScene(0, 0, 0);
            gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mdl, true);
            gl.setShader(s1);
            gl.renderMesh(earth);
            mdl.prependRotation(-c / 30, Vector3D.Y_AXIS);
            gl.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mdl, true);
            gl.setShader(s2);
            gl.renderMesh(cloud);
            gl.endScene();
        }
    }
}

var vertexShaderCode:String = <![CDATA[
m44 vt0, va0, vc0;
mov v5, vt0.xyz; // set vertex position
m44 vt0, vt0, vc4;
mov op, vt0;
mov v0, va1; // vertex color
m33 vt0.xyz, va2.xyz, vc0; // transform vertex normal
nrm vt0.xyz, vt0.xyz; // normalize vertex normal
mov v1, vt0.xyz; // set vertex normal
mov v2, va3.xy; // set vertex uv
m33 vt1.xyz, va4.xyz, vc0; // transform vertex tangent
nrm vt1.xyz, vt1.xyz; // normalize vertex tangent
mov v3, vt1.xyz; // set vertex tangent
crs vt2.xyz, vt0.xyz, vt1.xyz; // calculate vertex binormal
nrm vt2.xyz, vt2.xyz; // normalize vertex binormal
mov v4, vt2.xyz; // set vertex binormal
]]>;

var fragmentShaderEarth:String = <![CDATA[
tex ft0, v2, fs3, <2d, linear, repeat>;
mov ft0, v1; // normal
mov ft1, v3; // tangent
mov ft2, v4; // binormal
nrm ft0.xyz, ft0.xyz;
nrm ft1.xyz, ft1.xyz;
nrm ft2.xyz, ft2.xyz;
tex ft3, v2, fs1, <2d, linear, repeat>; // normal map
sub ft3.xyz, ft3.xyz, fc8.yyy;
mul ft3.xyz, ft3.xyz, fc8.www; // bumpmap normal
mov ft4.xyz, fc8.xxx;
mul ft5.x, ft1.x, ft3.x;
mul ft5.y, ft2.x, ft3.y;
mul ft5.z, ft0.x, ft3.z;
add ft4.x, ft5.x, ft5.y;
add ft4.x, ft4.x, ft5.z;
mul ft5.x, ft1.y, ft3.x;
mul ft5.y, ft2.y, ft3.y;
mul ft5.z, ft0.y, ft3.z;
add ft4.y, ft5.x, ft5.y;
add ft4.y, ft4.y, ft5.z;
mul ft5.x, ft1.z, ft3.x;
mul ft5.y, ft2.z, ft3.y;
mul ft5.z, ft0.z, ft3.z;
add ft4.z, ft5.x, ft5.y;
add ft4.z, ft4.z, ft5.z;
nrm ft4.xyz, ft4.xyz;

mov ft1.xyz, fc0.xyz; // light vector
mul ft1.xyz, ft1.xyz, fc9.xxx;
nrm ft1.xyz, ft1.xyz;
dp3 ft7.x, ft4.xyz, ft1.xyz; // calc brightness
add ft7.x, ft7.x, fc10.w;
sat ft7.x, ft7.x;

mov ft2.xyz, v5.xyz; // calc view vector
mul ft2.xyz, ft2.xyz, fc9.xxx;
nrm ft2.xyz, ft2.xyz;

mul ft1.xyz, ft1.xyz, fc9.xxx; // calc refrection vector
dp3 ft3.x, ft1.xyz, ft4.xyz;
mul ft3.x, ft3.x, fc8.w;
mul ft3.xyz, ft4.xyz, ft3.xxx;
sub ft3.xyz, ft1.xyz, ft3.xyz;
nrm ft3.xyz, ft3.xyz;

dp3 ft1.x, ft2.xyz, ft3.xyz; // calc specular
sat ft1.x, ft1.x;
pow ft7.y, ft1.x, fc9.y;
mul ft7.y, ft7.y, fc8.y;

tex ft6, v2, fs0, <2d, linear, repeat>; // color map
mul ft4.xyz, ft6.xyz, ft7.xxx; // apply light
tex ft6, v2, fs4, <2d, linear, repeat>; // night map
sub ft7.x, fc8.z, ft7.x;
pow ft7.x, ft7.x, fc9.y;
mul ft6.xyz, ft6.xyz, ft7.xxx;
add ft4.xyz, ft4.xyz, ft6.xyz;

tex ft6, v2, fs2, <2d, linear, repeat>; // specular map
mul ft7.y, ft7.y, ft6.x; // apply specular map
add ft4.xyz, ft4.xyz, ft7.yyy; // add specular
sat ft4.xyz, ft4.xyz; // clamp
mov ft4.w, fc8.z;

mov oc, ft4;
]]>;

var fragmentShaderCloud:String = <![CDATA[
tex ft0, v2, fs0, <2d, nearest>;
tex ft0, v2, fs1, <2d, nearest>;
tex ft0, v2, fs2, <2d, nearest>;
tex ft0, v2, fs4, <2d, nearest>;
tex ft0, v2, fs3, <2d, linear, repeat>; // cloud map
mov ft1.xyz, fc0.xyz;
mul ft1.xyz, ft1.xyz, fc9.xxx;
nrm ft1.xyz, ft1.xyz;
mov ft2.xyz, v1.xyz;
nrm ft2.xyz, ft2.xyz;
dp3 ft1.x, ft1.xyz, ft2.xyz;
mov ft0.w, ft0.x;
mov ft0.xyz, ft1.xxx;
mov oc, ft0;
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
    public static const OFFSET_TANGENT:uint = 12;
    public static const OFFSET_TMP:uint = 15;
    public static const NUM_DATAS_IN_VERTEX:uint = 18;
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
        c3d.setCulling(Context3DTriangleFace.BACK);
        p3d = c3d.createProgram();
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, Vector.<Number>([0, 0.5, 1, 2]));
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9, Vector.<Number>([-1, 8, 16, 32]));
        c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, Vector.<Number>([0.03125, 0.0625, 0.125, 0.25]));
        c3d.setProgram(p3d);
        callback();
    }
    
    public function setShader(shader:EShader):void {
        p3d.upload(shader.vertexShader, shader.fragmentShader);
    }
    
    public function renderMesh(mesh:EMesh):void {
        var vtxbuf:VertexBuffer3D = mesh.vertexBuffer;
        c3d.setVertexBufferAt(0, vtxbuf, OFFSET_VERTEX, Context3DVertexBufferFormat.FLOAT_3);
        c3d.setVertexBufferAt(1, vtxbuf, OFFSET_COLOR, Context3DVertexBufferFormat.FLOAT_4);
        c3d.setVertexBufferAt(2, vtxbuf, OFFSET_NORMAL, Context3DVertexBufferFormat.FLOAT_3);
        c3d.setVertexBufferAt(3, vtxbuf, OFFSET_UV, Context3DVertexBufferFormat.FLOAT_2);
        c3d.setVertexBufferAt(4, vtxbuf, OFFSET_TANGENT, Context3DVertexBufferFormat.FLOAT_3);
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
    
    public function get program3D():Program3D {
        return p3d;
    }
}

class EMesh {
    private var vertex:Vector.<Number>;
    private var face:Vector.<uint>;
    private var normal:Vector.<Vector.<Number>>;
    private var color:Vector.<Vector.<Number>>;
    private var uv:Vector.<Vector.<Number>>;
    private var tangent:Vector.<Vector.<Number>>;
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
        vertex = new Vector.<Number>();
        face = new Vector.<uint>();
        normal = new Vector.<Vector.<Number>>();
        color = new Vector.<Vector.<Number>>();
        uv = new Vector.<Vector.<Number>>();
        tangent = new Vector.<Vector.<Number>>();
        //
        vtxbuf = null;
        idxbuf = null;
        //
        numvtx = 0;
        numfce = 0;
    }
    
    public function addVertex(x:Number, y:Number, z:Number):void {
        var idx:uint = numvtx * 3;
        vertex[idx++] = x;
        vertex[idx++] = y;
        vertex[idx++] = z;
        numvtx++;
    }
    
    public function addFace(i1:uint, i2:uint, i3:uint, u1:Number = 0, v1:Number = 0, u2:Number = 0, v2:Number = 0, u3:Number = 0, v3:Number = 0, c1:uint = 0xffffffff, c2:uint = 0xffffffff, c3:uint = 0xffffffff):void {
        var idx:uint = numfce * 3;
        face[idx++] = i1;
        face[idx++] = i2;
        face[idx++] = i3;
        normal[numfce] = new Vector.<Number>(9, true);
        tangent[numfce] = new Vector.<Number>(9, true);
        uv[numfce] = new Vector.<Number>(6, true);
        uv[numfce][0] = u1;
        uv[numfce][1] = v1;
        uv[numfce][2] = u2;
        uv[numfce][3] = v2;
        uv[numfce][4] = u3;
        uv[numfce][5] = v3;
        color[numfce] = new Vector.<Number>(12, true);
        color[numfce][0] = c1 >>> 24 & 0xff;
        color[numfce][1] = c1 >> 16 & 0xff;
        color[numfce][2] = c1 >> 8 & 0xff;
        color[numfce][3] = c1 & 0xff;
        color[numfce][4] = c2 >>> 24 & 0xff;
        color[numfce][5] = c2 >> 16 & 0xff;
        color[numfce][6] = c2 >> 8 & 0xff;
        color[numfce][7] = c2 & 0xff;
        color[numfce][8] = c3 >>> 24 & 0xff;
        color[numfce][9] = c3 >> 16 & 0xff;
        color[numfce][10] = c3 >> 8 & 0xff;
        color[numfce][11] = c3 & 0xff;
        numfce++;
    }
    
    public function calcNormals():void {
        var idx:uint = 0;
        var i:uint;
        var vtxnrm:Vector.<Number> = new Vector.<Number>(numvtx * 3, true);
        var vtxtan:Vector.<Number> = new Vector.<Number>(numvtx * 3, true);
        for (i = 0; i < numvtx; i++) {
            idx = i * 3;
            vtxnrm[idx] = 0;
            vtxnrm[idx + 1] = 0;
            vtxnrm[idx + 2] = 0;
            vtxtan[idx] = 0;
            vtxtan[idx + 1] = 0;
            vtxtan[idx + 2] = 0;
        }
        var n1:Number;
        var n2:Number;
        var n3:Number;
        var s1:Number;
        var s2:Number;
        var s3:Number;
        var t1:Number;
        var t2:Number;
        var t3:Number;
        idx = 0;
        for (i = 0; i < numfce; i++) {
            var i1:uint = face[idx];
            var i2:uint = face[idx + 1];
            var i3:uint = face[idx + 2];
            var v1:uint = i1 * 3;
            var v2:uint = i2 * 3;
            var v3:uint = i3 * 3;
            //
            var x1:Number = vertex[v2] - vertex[v1];
            var y1:Number = vertex[v2 + 1] - vertex[v1 + 1];
            var z1:Number = vertex[v2 + 2] - vertex[v1 + 2];
            var x2:Number = vertex[v3] - vertex[v1];
            var y2:Number = vertex[v3 + 1] - vertex[v1 + 1];
            var z2:Number = vertex[v3 + 2] - vertex[v1 + 2];
            //
            v1 = i1 * 2;
            v2 = i2 * 2;
            v3 = i3 * 2;
            s1 = uv[i][2] - uv[i][0];
            t1 = uv[i][3] - uv[i][1];
            s2 = uv[i][4] - uv[i][0];
            t2 = uv[i][5] - uv[i][1];
            //
            var nx:Number = y2 * z1 - z2 * y1;
            var ny:Number = z2 * x1 - x2 * z1;
            var nz:Number = x2 * y1 - y2 * x1;
            var nl:Number = Math.sqrt(nx * nx + ny * ny + nz * nz);
            if (nl != 0) nl = 1 / nl;
            nx *= nl;
            ny *= nl;
            nz *= nl;
            //
            nl = s1 * t2 - t1 * s2;
            if (nl != 0) nl = 1 / nl;
            //
            var sx:Number;
            var sy:Number;
            var sz:Number;
            sx = (t2 * x1 - t1 * x2) * nl;
            sy = (t2 * y1 - t1 * y2) * nl;
            sz = (t2 * z1 - t1 * z2) * nl;
            //
            var tx:Number;
            var ty:Number;
            var tz:Number;
            tx = (s1 * x2 - s2 * x1) * nl;
            ty = (s1 * y2 - s2 * y1) * nl;
            tz = (s1 * z2 - s2 * z1) * nl;
            //
            var n:uint = i1 * 3;
            vtxnrm[n] += nx;
            vtxnrm[n + 1] += ny;
            vtxnrm[n + 2] += nz;
            vtxtan[n] += sx;
            vtxtan[n + 1] += sy;
            vtxtan[n + 2] += sz;
            n = i2 * 3;
            vtxnrm[n] += nx;
            vtxnrm[n + 1] += ny;
            vtxnrm[n + 2] += nz;
            vtxtan[n] += sx;
            vtxtan[n + 1] += sy;
            vtxtan[n + 2] += sz;
            n = i3 * 3;
            vtxnrm[n] += nx;
            vtxnrm[n + 1] += ny;
            vtxnrm[n + 2] += nz;
            vtxtan[n] += sx;
            vtxtan[n + 1] += sy;
            vtxtan[n + 2] += sz;
            idx += 3;
        }
        idx = 0;
        for (i = 0; i < numvtx; i++) {
            n1 = vtxnrm[idx];
            n2 = vtxnrm[idx + 1];
            n3 = vtxnrm[idx + 2];
            s1 = vtxtan[idx];
            s2 = vtxtan[idx + 1];
            s3 = vtxtan[idx + 2];
            var dot:Number = n1 * s1 + n2 * s2 + n3 * s3;
            vtxtan[idx] = s1 - n1 * dot;
            vtxtan[idx + 1] = s2 - n2 * dot;
            vtxtan[idx + 2] = s3 - n3 * dot;
            idx += 3;
        }
        for (i = 0; i < numfce; i++) {
            i1 = face[i * 3];
            i2 = face[i * 3 + 1];
            i3 = face[i * 3 + 2];
            idx = i1 * 3;
            normal[i][0] = vtxnrm[idx];
            normal[i][1] = vtxnrm[idx + 1];
            normal[i][2] = vtxnrm[idx + 2];
            tangent[i][0] = vtxtan[idx];
            tangent[i][1] = vtxtan[idx + 1];
            tangent[i][2] = vtxtan[idx + 2];
            idx = i2 * 3;
            normal[i][3] = vtxnrm[idx];
            normal[i][4] = vtxnrm[idx + 1];
            normal[i][5] = vtxnrm[idx + 2];
            tangent[i][3] = vtxtan[idx];
            tangent[i][4] = vtxtan[idx + 1];
            tangent[i][5] = vtxtan[idx + 2];
            idx = i3 * 3;
            normal[i][6] = vtxnrm[idx];
            normal[i][7] = vtxnrm[idx + 1];
            normal[i][8] = vtxnrm[idx + 2];
            tangent[i][6] = vtxtan[idx];
            tangent[i][7] = vtxtan[idx + 1];
            tangent[i][8] = vtxtan[idx + 2];
        }
    }
    
    public function updateBuffers():void {
        const numDatasInVertex:uint = EGraphics.NUM_DATAS_IN_VERTEX;
        const offsetVertex:uint = EGraphics.OFFSET_VERTEX;
        const offsetNormal:uint = EGraphics.OFFSET_NORMAL;
        const offsetColor:uint = EGraphics.OFFSET_COLOR;
        const offsetUV:uint = EGraphics.OFFSET_UV;
        const offsetTangent:uint = EGraphics.OFFSET_TANGENT;
        const vertex:Vector.<Number> = this.vertex;
        const face:Vector.<uint> = this.face;
        const normal:Vector.<Vector.<Number>> = this.normal;
        const color:Vector.<Vector.<Number>> = this.color;
        const uv:Vector.<Vector.<Number>> = this.uv;
        const tangent:Vector.<Vector.<Number>> = this.tangent;
        var idx:uint;
        var vc:uint = 0;
        var fidx:uint = 0;
        for (var i:uint = 0; i < numfce; i++) {
            var end:uint = vc + numDatasInVertex * 3;
            for (var j:uint = vc; j < end; j++) vts[j] = 0;
            const i1:uint = face[fidx] * 3;
            const i2:uint = face[fidx + 1] * 3;
            const i3:uint = face[fidx + 2] * 3;
            idx = vc + offsetVertex;
            vts[idx++] = vertex[i1];
            vts[idx++] = vertex[i1 + 1];
            vts[idx++] = vertex[i1 + 2];
            idx = vc + offsetNormal;
            vts[idx++] = normal[i][0];
            vts[idx++] = normal[i][1];
            vts[idx++] = normal[i][2];
            idx = vc + offsetColor;
            vts[idx++] = color[i][0];
            vts[idx++] = color[i][1];
            vts[idx++] = color[i][2];
            vts[idx++] = color[i][3];
            idx = vc + offsetUV;
            vts[idx++] = uv[i][0];
            vts[idx++] = uv[i][1];
            idx = vc + offsetTangent;
            vts[idx++] = tangent[i][0];
            vts[idx++] = tangent[i][1];
            vts[idx++] = tangent[i][2];
            vc += numDatasInVertex;
            //
            idx = vc + offsetVertex;
            vts[idx++] = vertex[i2];
            vts[idx++] = vertex[i2 + 1];
            vts[idx++] = vertex[i2 + 2];
            idx = vc + offsetNormal;
            vts[idx++] = normal[i][3];
            vts[idx++] = normal[i][4];
            vts[idx++] = normal[i][5];
            idx = vc + offsetColor;
            vts[idx++] = color[i][4];
            vts[idx++] = color[i][5];
            vts[idx++] = color[i][6];
            vts[idx++] = color[i][7];
            idx = vc + offsetUV;
            vts[idx++] = uv[i][2];
            vts[idx++] = uv[i][3];
            idx = vc + offsetTangent;
            vts[idx++] = tangent[i][3];
            vts[idx++] = tangent[i][4];
            vts[idx++] = tangent[i][5];
            vc += numDatasInVertex;
            //
            idx = vc + offsetVertex;
            vts[idx++] = vertex[i3];
            vts[idx++] = vertex[i3 + 1];
            vts[idx++] = vertex[i3 + 2];
            idx = vc + offsetNormal;
            vts[idx++] = normal[i][6];
            vts[idx++] = normal[i][7];
            vts[idx++] = normal[i][8];
            idx = vc + offsetColor;
            vts[idx++] = color[i][8];
            vts[idx++] = color[i][9];
            vts[idx++] = color[i][10];
            vts[idx++] = color[i][11];
            idx = vc + offsetUV;
            vts[idx++] = uv[i][4];
            vts[idx++] = uv[i][5];
            idx = vc + offsetTangent;
            vts[idx++] = tangent[i][6];
            vts[idx++] = tangent[i][7];
            vts[idx++] = tangent[i][8];
            vc += numDatasInVertex;
            ids[fidx] = fidx++;
            ids[fidx] = fidx++;
            ids[fidx] = fidx++;
        }
    }
    
    public function initVertexBuffer(g:EGraphics):void {
        vtxbuf = g.createVertexBuffer(numfce * 3);
    }
    
    public function initIndexBuffer(g:EGraphics):void {
        idxbuf = g.createIndexBuffer(numfce * 3);
    }
    
    public function get numVertices():uint {
        return numfce * 3;
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
    
    public function EShader(vertex:String, fragment:String) {
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        agal.assemble(Context3DProgramType.VERTEX, vertex);
        vtxcode = agal.agalcode;
        agal.assemble(Context3DProgramType.FRAGMENT, fragment);
        frgcode = agal.agalcode;
    }
    
    public function get vertexShader():ByteArray {
        return vtxcode;
    }
    
    public function get fragmentShader():ByteArray {
        return frgcode;
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
            loadings[i] = null; // I believe GC :-)
        }
    }
}
