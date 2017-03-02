package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import net.hires.debug.*;
    [SWF(frameRate = "30", width="465", height="465")]
    
    /**
     * Fake Refraction Mapping
     * @author saharan
     */
    public class FlashSoft3D extends Sprite {
        private var r:Renderer;
        private var count:uint;
        private var star:Vector.<Model>;
        private var bg:Model;
        private var earth:Model;
        private var ring:Model;
        private var t1:Texture;
        private var t2:Texture;
        public static var debug:TextField;
        private const w:uint = 512;
        private const h:uint = 256;
        
        public function FlashSoft3D() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            var black:Sprite = new Sprite();
            black.graphics.beginFill(0xa0a0a0);
            black.graphics.drawRect(0, 0, 465, 465);
            black.graphics.endFill();
            addChild(black);
            r = new Renderer(w, h);
            r.lookAt(new Vec3D(0, 0, 300), new Vec3D(), new Vec3D(0, 1, 0));
            t1 = new Texture();
            t2 = new Texture();
            t1.load("http://assets.wonderfl.net/images/related_images/0/0b/0bf5/0bf5a6f264fffbbb211e40e2df933fb0614207f7");
            t2.load("http://assets.wonderfl.net/images/related_images/d/db/dbb9/dbb91436be8551633568d70004230473303c4bb3");
            
            // dirx, diry, dirz, red, green, blue
            r.light(0).directional(0, 0, -1, 1, 1, 1);
            // r.light(0).directional(0, -2, -1, 0.6, 0.1, 0.1);
            // r.light(1).directional(3, 2, -1, 0.1, 0.6, 0.1);
            // r.light(2).directional(-3, 2, -1, 0.1, 0.1, 0.6);
            r.image.x = (465 - w) >> 1;
            r.image.y = (465 - h) >> 1;
            addChild(r.image);
            // debug = new TextField();
            // debug.x = 200;
            // debug.textColor = 0xffffff;
            // addChild(debug);
            addChild(new Stats());
            bg = new Model();
            bg.toSphere(8, 8, 300);
            bg.reverseFace();
            earth = new Model();
            earth.toSphere(16, 8, 90);
            earth.calcNormals();
            ring = new Model();
            ring.toTorus(32, 16, 80, 110);
            ring.calcNormals();
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function frame(e:Event = null):void {
            count++;
            r.beginScene(0x000000);
            r.push();
            r.rotateX(count / 30);
            r.rotateY(count / 20);
            r.texture(t2);
            r.material(0, 0, 0, 0, 1, 1, 1, 1);
            bg.render(r);
            r.texture(t1);
            r.material(0.8, 0.8, 0, 0, 0, 1, 1, 1);
            earth.render(r);
            r.pop();
            r.push();
            r.rotateY(count / 30);
            r.rotateZ(count / 20);
            r.texture(r.createFrameBufferTexture());
            r.sphereMap(true);
            r.material(0, 0, 0, 0, 1, 1, 1, 1);
            ring.render(r);
            r.sphereMap(false);
            r.pop();
            r.endScene();
        }
    }
}

import flash.events.*;
import flash.display.*;
import flash.net.*;
import flash.system.*;

class Renderer {
    private var img:BitmapData;
    private var fBuffer:Vector.<uint>;
    private var zBuffer:Vector.<Number>;
    private var bitmap:Bitmap;
    
    private var sprUse:Boolean;
    private var norUse:Boolean;
    private var texUse:Boolean;
    private var texel:Vector.<uint>;
    private var texWidth:uint;
    private var texHeight:uint;
    private var texSize:uint;
    private var texShift:uint;
    
    private var width:uint;
    private var height:uint;
    private var aspect:Number;
    private var width2:uint;
    private var height2:uint;
    private var size:uint;
    private var near:uint;
    private var far:uint;
    
    private var cameraPosition:Vec3D;
    private var cameraTarget:Vec3D;
    private var cameraUp:Vec3D;
    
    private var worldMatrix:Mat4x4;
    private var viewMatrix:Mat4x4;
    private var projectionMatrix:Mat4x4;
    
    private var numStacks:int;
    private var stack:Vector.<Mat4x4>;
    private var color:Vector.<uint>;
    
    private var amb:Number;
    private var dif:Number;
    private var spc:Number;
    private var shn:Number;
    private var emi:Number;
    private var r:Number;
    private var g:Number;
    private var b:Number;
    
    private var lights:Vector.<Light>;
    private var ambr:Number;
    private var ambg:Number;
    private var ambb:Number;
    
    private var vtop:RVtx; // for recycle object
    private var vleft:RVtx;
    private var vright:RVtx;
    private var temp1:Vec3D;
    private var temp2:Vec3D;
    private var temp3:Vec3D;
    
    private var normalMatrix:Mat4x4;
    private var normalMatrixCreated:Boolean;
    
    public function Renderer(width:uint, height:uint) {
        img = new BitmapData(width, height, false, 0);
        bitmap = new Bitmap(img);
        this.width = width;
        this.height = height;
        aspect = height / width;
        size = width * height;
        width2 = width >> 1;
        height2 = height >> 1;
        numStacks = 0;
        sprUse = false;
        texUse = false;
        norUse = false;
        zBuffer = new Vector.<Number>(size, true);
        fBuffer = new Vector.<uint>(size, true);
        lights = new Vector.<Light>(8, true);
        for (var i:int = 0; i < 8; i++) lights[i] = new Light();
        stack = new Vector.<Mat4x4>(64, true);
        worldMatrix = new Mat4x4();
        viewMatrix = new Mat4x4();
        projectionMatrix = new Mat4x4();
        
        // system initialization
        lookAt(new Vec3D(0, 0, 50),  new Vec3D(0, 0, 0), new Vec3D(0, 1, 0));
        perspective(60 * Math.PI / 180, 5, 5000);
        ambient(0.2, 0.2, 0.2);
        light(0).directional(0, 0, -1, 1, 1, 1);
        material(0.8, 0.8, 0, 0, 0, 1, 1, 1);
        vtop = new RVtx();
        vleft = new RVtx();
        vright = new RVtx();
        temp1 = new Vec3D();
        temp2 = new Vec3D();
        temp3 = new Vec3D();
        normalMatrix = new Mat4x4();
        normalMatrixCreated = false;
        color = new Vector.<uint>(9, true);
    }
    
    public function get image():Bitmap {
        return bitmap;
    }
    
    public function push():void {
        if(numStacks < 32) {
            stack[numStacks] = new Mat4x4(
                worldMatrix.e00, worldMatrix.e01, worldMatrix.e02, worldMatrix.e03,
                worldMatrix.e10, worldMatrix.e11, worldMatrix.e12, worldMatrix.e13,
                worldMatrix.e20, worldMatrix.e21, worldMatrix.e22, worldMatrix.e23,
                worldMatrix.e30, worldMatrix.e31, worldMatrix.e32, worldMatrix.e33);
            numStacks++;
        }
    }
    
    public function pop():void {
        if (numStacks > 0) {
            numStacks--;
            worldMatrix = stack[numStacks];
        }
    }
    
    public function rotateX(theta:Number):void {
        var temp:Mat4x4 = new Mat4x4();
        temp.rotateX(theta);
        temp.mulEqualMatrix(worldMatrix);
        worldMatrix = temp;
    }
    
    public function rotateY(theta:Number):void {
        var temp:Mat4x4 = new Mat4x4();
        temp.rotateY(theta);
        temp.mulEqualMatrix(worldMatrix);
        worldMatrix = temp;
    }
    
    public function rotateZ(theta:Number):void {
        var temp:Mat4x4 = new Mat4x4();
        temp.rotateZ(theta);
        temp.mulEqualMatrix(worldMatrix);
        worldMatrix = temp;
    }
    
    public function scale(sx:Number, sy:Number, sz:Number):void {
        var temp:Mat4x4 = new Mat4x4();
        temp.scale(sx, sy, sz);
        temp.mulEqualMatrix(worldMatrix);
        worldMatrix = temp;
    }
    
    public function translate(tx:Number, ty:Number, tz:Number):void {
        var temp:Mat4x4 = new Mat4x4();
        temp.translate(tx, ty, tz);
        temp.mulEqualMatrix(worldMatrix);
        worldMatrix = temp;
    }
    
    public function beginScene(bg:uint):void {
        for (var i:int = 0; i < size; i++) {
            fBuffer[i] = bg;
            zBuffer[i] = 0;
        }
        worldMatrix.identity();
    }
    
    public function createNormalMatrix():void {
        normalMatrix.setMatrix(
            worldMatrix.e00, worldMatrix.e01, worldMatrix.e02, worldMatrix.e03,
            worldMatrix.e10, worldMatrix.e11, worldMatrix.e12, worldMatrix.e13,
            worldMatrix.e20, worldMatrix.e21, worldMatrix.e22, worldMatrix.e23,
            worldMatrix.e30, worldMatrix.e31, worldMatrix.e32, worldMatrix.e33);
        var s:Number = 1 / (normalMatrix.e00 * normalMatrix.e00 + normalMatrix.e01 * normalMatrix.e01 + normalMatrix.e02 * normalMatrix.e02);
        normalMatrix.e00 *= s;
        normalMatrix.e01 *= s;
        normalMatrix.e02 *= s;
        s = 1 / (normalMatrix.e10 * normalMatrix.e10 + normalMatrix.e11 * normalMatrix.e11 + normalMatrix.e12 * normalMatrix.e12);
        normalMatrix.e10 *= s;
        normalMatrix.e11 *= s;
        normalMatrix.e12 *= s;
        s = 1 / (normalMatrix.e20 * normalMatrix.e20 + normalMatrix.e21 * normalMatrix.e21 + normalMatrix.e22 * normalMatrix.e22);
        normalMatrix.e20 *= s;
        normalMatrix.e21 *= s;
        normalMatrix.e22 *= s;
        normalMatrixCreated = true;
    }
    
    public function destroyNormalMatrix():void {
        normalMatrixCreated = false;
    }
    
    public function transformVertices(vs:Vector.<Vertex>):void {
        const len:uint = vs.length;
        for (var i:uint = 0; i < len; i++) {
            const v:Vertex = vs[i];
            v.worldPos.setVector(v.pos.x, v.pos.y, v.pos.z);
            worldMatrix.mulEqualVector(v.worldPos);
            v.viewPos.setVector(v.worldPos.x, v.worldPos.y, v.worldPos.z);
            viewMatrix.mulEqualVector(v.viewPos);
        }
    }
    
    public function renderPolygon(v1:Vertex, v2:Vertex, v3:Vertex):void {
        v1.worldPos.setVector(v1.pos.x, v1.pos.y, v1.pos.z);
        worldMatrix.mulEqualVector(v1.worldPos);
        v1.viewPos.setVector(v1.worldPos.x, v1.worldPos.y, v1.worldPos.z);
        viewMatrix.mulEqualVector(v1.viewPos);
        v2.worldPos.setVector(v2.pos.x, v2.pos.y, v2.pos.z);
        worldMatrix.mulEqualVector(v2.worldPos);
        v2.viewPos.setVector(v2.worldPos.x, v2.worldPos.y, v2.worldPos.z);
        viewMatrix.mulEqualVector(v2.viewPos);
        v3.worldPos.setVector(v3.pos.x, v3.pos.y, v3.pos.z);
        worldMatrix.mulEqualVector(v3.worldPos);
        v3.viewPos.setVector(v3.worldPos.x, v3.worldPos.y, v3.worldPos.z);
        viewMatrix.mulEqualVector(v3.viewPos);
        renderPolygonWithoutTransform(v1, v2, v3);
    }
    
    public function renderPolygonWithoutTransform(v1:Vertex, v2:Vertex, v3:Vertex):void {
        norUse = v1.normal.length() != 0 || v2.normal.length() != 0 || v3.normal.length() != 0;
        
        if (norUse) {
            const flag:Boolean = !normalMatrixCreated;
            if (flag) createNormalMatrix();
            const normalMatrix:Mat4x4 = this.normalMatrix;
            
            v1.tn.x = normalMatrix.e00 * v1.normal.x + normalMatrix.e10 * v1.normal.y + normalMatrix.e20 * v1.normal.z;
            v1.tn.y = normalMatrix.e01 * v1.normal.x + normalMatrix.e11 * v1.normal.y + normalMatrix.e21 * v1.normal.z;
            v1.tn.z = normalMatrix.e02 * v1.normal.x + normalMatrix.e12 * v1.normal.y + normalMatrix.e22 * v1.normal.z;
            v1.tn.normalize();
            lightingGouraud(v1);
            
            v2.tn.x = normalMatrix.e00 * v2.normal.x + normalMatrix.e10 * v2.normal.y + normalMatrix.e20 * v2.normal.z;
            v2.tn.y = normalMatrix.e01 * v2.normal.x + normalMatrix.e11 * v2.normal.y + normalMatrix.e21 * v2.normal.z;
            v2.tn.z = normalMatrix.e02 * v2.normal.x + normalMatrix.e12 * v2.normal.y + normalMatrix.e22 * v2.normal.z;
            v2.tn.normalize();
            lightingGouraud(v2);
            
            v3.tn.x = normalMatrix.e00 * v3.normal.x + normalMatrix.e10 * v3.normal.y + normalMatrix.e20 * v3.normal.z;
            v3.tn.y = normalMatrix.e01 * v3.normal.x + normalMatrix.e11 * v3.normal.y + normalMatrix.e21 * v3.normal.z;
            v3.tn.z = normalMatrix.e02 * v3.normal.x + normalMatrix.e12 * v3.normal.y + normalMatrix.e22 * v3.normal.z;
            v3.tn.normalize();
            lightingGouraud(v3);
            
            if (flag) destroyNormalMatrix();
        } else {
            calcNormal(v1.worldPos, v2.worldPos, v3.worldPos, v1.tn);
            v1.tn.normalize();
            lighting(v1.tn);
        }
        
        clipPolygonDepth(v1, v2, v3, 0);
    }
    
    public function light(id:uint):Light {
        return lights[id];
    }
    
    public function ambient(r:Number, g:Number, b:Number):void {
        ambr = r;
        ambg = g;
        ambb = b;
    }
    
    public function sphereMap(enable:Boolean):void {
        sprUse = enable;
    }
    
    public function material(ambient:Number, diffuse:Number, specular:Number,
        shininess:Number, emission:Number, r:Number, g:Number, b:Number):void {
        amb = ambient;
        dif = diffuse;
        spc = specular;
        shn = shininess;
        emi = emission;
        this.r = r;
        this.g = g;
        this.b = b;
    }
    
    public function createFrameBufferTexture():Texture {
        var tex:Texture = new Texture();
        tex.init(width, height, fBuffer);
        return tex;
    }
    
    public function texture(tex:Texture):void {
        if (tex == null || !tex.loaded) {
            texUse = false;
            return;
        }
        texWidth = tex.width;
        texHeight = tex.height;
        texSize = tex.size;
        texel = tex.texel;
        texShift = tex.shift;
        texUse = true;
    }
    
    private function calcNormal(v1:Vec3D, v2:Vec3D, v3:Vec3D, out:Vec3D):void {
        const x13:Number = v3.x - v1.x;
        const y13:Number = v3.y - v1.y;
        const z13:Number = v3.z - v1.z;
        const x12:Number = v2.x - v1.x;
        const y12:Number = v2.y - v1.y;
        const z12:Number = v2.z - v1.z;
        out.x = y13 * z12 - z13 * y12;
        out.y = z13 * x12 - x13 * z12;
        out.z = x13 * y12 - y13 * x12;
    }
    
    private function lightingGouraud(v:Vertex):void {
        // simple lighting for gouraud
        var cr:Number = (amb * ambr + emi) * r;
        var cg:Number = (amb * ambg + emi) * g;
        var cb:Number = (amb * ambb + emi) * b;
        var sr:Number = 0;
        var sg:Number = 0;
        var sb:Number = 0;
        const temp1:Vec3D = this.temp1;
        const temp2:Vec3D = this.temp2;
        const temp3:Vec3D = this.temp3;
        temp1.x = v.tn.x;
        temp1.y = v.tn.y;
        temp1.z = v.tn.z;
        temp2.x = cameraTarget.x - cameraPosition.x;
        temp2.y = cameraTarget.y - cameraPosition.y;
        temp2.z = cameraTarget.z - cameraPosition.z;
        temp2.normalize();
        for (var i:int = 0; i < 8; i++) {
            const light:Light = lights[i];
            if (light.type == Light.DISABLED) continue;
            const lr:Number = light.r;
            const lg:Number = light.g;
            const lb:Number = light.b;
            switch(light.type) {
                case Light.DIRECTIONAL: // directional light
                const dot:Number = -(light.dir.x * temp1.x + light.dir.y * temp1.y + light.dir.z * temp1.z) * dif;
                if (dot > 0) {
                    cr += r * lr * dot;
                    cg += g * lg * dot;
                    cb += b * lb * dot;
                }
                if (spc > 0) {
                    // calc reflection vector and specular
                    // ref = vec - 2 * (nor * vec) * nor
                    var dots:Number = 2 * (temp1.x * temp2.x + temp1.y * temp2.y + temp1.z * temp2.z);
                    temp3.x = temp2.x - temp1.x * dots;
                    temp3.y = temp2.y - temp1.y * dots;
                    temp3.z = temp2.z - temp1.z * dots;
                    dots = -(light.dir.x * temp3.x + light.dir.y * temp3.y + light.dir.z * temp3.z);
                    if (dots > 0) {
                        dots = Math.pow(dots, shn) * spc;
                        sr += lr * dots;
                        sg += lg * dots;
                        sb += lb * dots;
                    }
                }
                break;
            }
        }
        if (cr > 1) cr = 1;
        if (cg > 1) cg = 1;
        if (cb > 1) cb = 1;
        if (sr > 1) sr = 1;
        if (sg > 1) sg = 1;
        if (sb > 1) sb = 1;
        v.r = cr * 0xff;
        v.g = cg * 0xff;
        v.b = cb * 0xff;
        v.sr = sr * 0xff;
        v.sg = sg * 0xff;
        v.sb = sb * 0xff;
    }
    
    private function lighting(n:Vec3D):void {
        // simple lighting
        var cr:Number = (amb * ambr + emi) * r;
        var cg:Number = (amb * ambg + emi) * g;
        var cb:Number = (amb * ambb + emi) * b;
        var sr:Number = 0;
        var sg:Number = 0;
        var sb:Number = 0;
        const temp1:Vec3D = n;
        const temp2:Vec3D = this.temp2;
        const temp3:Vec3D = this.temp3;
        temp2.x = cameraTarget.x - cameraPosition.x;
        temp2.y = cameraTarget.y - cameraPosition.y;
        temp2.z = cameraTarget.z - cameraPosition.z;
        temp2.normalize();
        for (var i:int = 0; i < 8; i++) {
            const light:Light = lights[i];
            if (light.type == Light.DISABLED) continue;
            const lr:Number = light.r;
            const lg:Number = light.g;
            const lb:Number = light.b;
            switch(light.type) {
                case Light.DIRECTIONAL: // directional light
                const dot:Number = -(light.dir.x * temp1.x + light.dir.y * temp1.y + light.dir.z * temp1.z) * dif;
                if (dot > 0) {
                    cr += r * lr * dot;
                    cg += g * lg * dot;
                    cb += b * lb * dot;
                }
                if (spc > 0) {
                    // calc reflection vector and specular
                    // ref = vec - 2 * (nor * vec) * nor
                    var dots:Number = 2 * (temp1.x * temp2.x + temp1.y * temp2.y + temp1.z * temp2.z);
                    temp3.x = temp2.x - temp1.x * dots;
                    temp3.y = temp2.y - temp1.y * dots;
                    temp3.z = temp2.z - temp1.z * dots;
                    dots = -(light.dir.x * temp3.x + light.dir.y * temp3.y + light.dir.z * temp3.z);
                    if (dots > 0) {
                        dots = Math.pow(dots, shn) * spc;
                        sr += lr * dots;
                        sg += lg * dots;
                        sb += lb * dots;
                    }
                }
                break;
            }
        }
        if (cr > 1) cr = 1;
        if (cg > 1) cg = 1;
        if (cb > 1) cb = 1;
        if (sr > 1) sr = 1;
        if (sg > 1) sg = 1;
        if (sb > 1) sb = 1;
        color[0] = cr * 0xff;
        color[1] = cg * 0xff;
        color[2] = cb * 0xff;
        color[3] = sr * 0xff;
        color[4] = sg * 0xff;
        color[5] = sb * 0xff;
        cr += sr;
        cg += sg;
        cb += sb;
        if (cr > 1) cr = 1;
        if (cg > 1) cg = 1;
        if (cb > 1) cb = 1;
        color[6] = cr * 0xff;
        color[7] = cg * 0xff;
        color[8] = cb * 0xff;
    }
    
    private function clipPolygonDepth(v1:Vertex, v2:Vertex, v3:Vertex, step:int):void {
        var flag:int;
        var c1:Vertex;
        var c2:Vertex;
        switch(step) {
        case 0:// near
            flag = 0;
            if (v1.viewPos.z < near) flag |= 1;
            if (v2.viewPos.z < near) flag |= 2;
            if (v3.viewPos.z < near) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, (near - v1.viewPos.z) / (v2.viewPos.z - v1.viewPos.z), false);
                    c2 = interpolate(v1, v3, (near - v1.viewPos.z) / (v3.viewPos.z - v1.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, v2, v3, 1);
                    clipPolygonDepth(c1, v3, c2, 1);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, (near - v2.viewPos.z) / (v3.viewPos.z - v2.viewPos.z), false);
                    c2 = interpolate(v2, v1, (near - v2.viewPos.z) / (v1.viewPos.z - v2.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, v3, v1, 1);
                    clipPolygonDepth(c1, v1, c2, 1);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, (near - v1.viewPos.z) / (v3.viewPos.z - v1.viewPos.z), false);
                    c2 = interpolate(v2, v3, (near - v2.viewPos.z) / (v3.viewPos.z - v2.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, c2, v3, 1);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, (near - v3.viewPos.z) / (v1.viewPos.z - v3.viewPos.z), false);
                    c2 = interpolate(v3, v2, (near - v3.viewPos.z) / (v2.viewPos.z - v3.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, v1, v2, 1);
                    clipPolygonDepth(c1, v2, c2, 1);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, (near - v3.viewPos.z) / (v2.viewPos.z - v3.viewPos.z), false);
                    c2 = interpolate(v1, v2, (near - v1.viewPos.z) / (v2.viewPos.z - v1.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, c2, v2, 1);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, (near - v2.viewPos.z) / (v1.viewPos.z - v2.viewPos.z), false);
                    c2 = interpolate(v3, v1, (near - v3.viewPos.z) / (v1.viewPos.z - v3.viewPos.z), false);
                    c1.viewPos.z = near;
                    c2.viewPos.z = near;
                    clipPolygonDepth(c1, c2, v1, 1);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        case 1:// far
            flag = 0;
            if (v1.viewPos.z > far) flag |= 1;
            if (v2.viewPos.z > far) flag |= 2;
            if (v3.viewPos.z > far) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, (far - v1.viewPos.z) / (v2.viewPos.z - v1.viewPos.z), false);
                    c2 = interpolate(v1, v3, (far - v1.viewPos.z) / (v3.viewPos.z - v1.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, v2, v3, 0);
                    clipPolygonScreen(c1, v3, c2, 0);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, (far - v2.viewPos.z) / (v3.viewPos.z - v2.viewPos.z), false);
                    c2 = interpolate(v2, v1, (far - v2.viewPos.z) / (v1.viewPos.z - v2.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, v3, v1, 0);
                    clipPolygonScreen(c1, v1, c2, 0);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, (far - v1.viewPos.z) / (v3.viewPos.z - v1.viewPos.z), false);
                    c2 = interpolate(v2, v3, (far - v2.viewPos.z) / (v3.viewPos.z - v2.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, c2, v3, 0);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, (far - v3.viewPos.z) / (v1.viewPos.z - v3.viewPos.z), false);
                    c2 = interpolate(v3, v2, (far - v3.viewPos.z) / (v2.viewPos.z - v3.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, v1, v2, 0);
                    clipPolygonScreen(c1, v2, c2, 0);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, (far - v3.viewPos.z) / (v2.viewPos.z - v3.viewPos.z), false);
                    c2 = interpolate(v1, v2, (far - v1.viewPos.z) / (v2.viewPos.z - v1.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, c2, v2, 0);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, (far - v2.viewPos.z) / (v1.viewPos.z - v2.viewPos.z), false);
                    c2 = interpolate(v3, v1, (far - v3.viewPos.z) / (v1.viewPos.z - v3.viewPos.z), false);
                    c1.viewPos.z = far;
                    c2.viewPos.z = far;
                    clipPolygonScreen(c1, c2, v1, 0);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        }
        clipPolygonScreen(v1, v2, v3, 0);
    }
    
    private function clipPolygonScreen(v1:Vertex, v2:Vertex, v3:Vertex, step:int):void {
        var flag:int;
        var c1:Vertex;
        var c2:Vertex;
        switch(step) {
        case 0:// left
            {
                // transform
                var invW:Number;
                v1.projPos.setVector(v1.viewPos.x, v1.viewPos.y, v1.viewPos.z, 1);
                projectionMatrix.mulEqualVector(v1.projPos);
                invW = 1 / v1.projPos.w;
                v1.projPos.x *= invW;
                v1.projPos.y *= invW;
                v1.projPos.z = invW;
                
                v2.projPos.setVector(v2.viewPos.x, v2.viewPos.y, v2.viewPos.z);
                projectionMatrix.mulEqualVector(v2.projPos);
                invW = 1 / v2.projPos.w;
                v2.projPos.x *= invW;
                v2.projPos.y *= invW;
                v2.projPos.z = invW;
                
                v3.projPos.setVector(v3.viewPos.x, v3.viewPos.y, v3.viewPos.z);
                projectionMatrix.mulEqualVector(v3.projPos);
                invW = 1 / v3.projPos.w;
                v3.projPos.x *= invW;
                v3.projPos.y *= invW;
                v3.projPos.z = invW;
                
                // correct uv
                if (texUse) {
                    if (sprUse) {
                        /* 
                        if (norUse) {
                            v1.tu = (0.5 + v1.tn.x * 0.5) * texWidth;
                            v1.tv = (0.5 - v1.tn.y * 0.5) * texHeight;
                            v2.tu = (0.5 + v2.tn.x * 0.5) * texWidth;
                            v2.tv = (0.5 - v2.tn.y * 0.5) * texHeight;
                            v3.tu = (0.5 + v3.tn.x * 0.5) * texWidth;
                            v3.tv = (0.5 - v3.tn.y * 0.5) * texHeight;
                        } else {
                            v1.tu = (0.5 + v1.tn.x * 0.5) * texWidth;
                            v1.tv = (0.5 - v1.tn.y * 0.5) * texHeight;
                            v2.tu = (0.5 + v1.tn.x * 0.5) * texWidth;
                            v2.tv = (0.5 - v1.tn.y * 0.5) * texHeight;
                            v3.tu = (0.5 + v1.tn.x * 0.5) * texWidth;
                            v3.tv = (0.5 - v1.tn.y * 0.5) * texHeight;
                        }
                         */
                        // for refraction mapping
                        v1.tu = (0.5 + v1.projPos.x * 0.5 - v1.tn.x * v1.tn.x * v1.tn.x * 0.1) * texWidth;
                        v1.tv = (0.5 - v1.projPos.y * 0.5 - v1.tn.y * v1.tn.y * v1.tn.y * 0.2) * texHeight;
                        v2.tu = (0.5 + v2.projPos.x * 0.5 - v2.tn.x * v2.tn.x * v2.tn.x * 0.1) * texWidth;
                        v2.tv = (0.5 - v2.projPos.y * 0.5 - v2.tn.y * v2.tn.y * v2.tn.y * 0.2) * texHeight;
                        v3.tu = (0.5 + v3.projPos.x * 0.5 - v3.tn.x * v3.tn.x * v3.tn.x * 0.1) * texWidth;
                        v3.tv = (0.5 - v3.projPos.y * 0.5 - v3.tn.y * v3.tn.y * v3.tn.y * 0.2) * texHeight;
                    } else {
                        v1.tu = v1.u * texWidth;
                        v1.tv = v1.v * texHeight;
                        v2.tu = v2.u * texWidth;
                        v2.tv = v2.v * texHeight;
                        v3.tu = v3.u * texWidth;
                        v3.tv = v3.v * texHeight;
                    }
                }
                v1.projPos.x = width2 + v1.projPos.x * width2 >> 0;
                v1.projPos.y = height2 - v1.projPos.y * height2 >> 0;
                v2.projPos.x = width2 + v2.projPos.x * width2 >> 0;
                v2.projPos.y = height2 - v2.projPos.y * height2 >> 0;
                v3.projPos.x = width2 + v3.projPos.x * width2 >> 0;
                v3.projPos.y = height2 - v3.projPos.y * height2 >> 0;
                
                // culling
                if ((v3.projPos.x - v1.projPos.x) * (v2.projPos.y - v1.projPos.y) -
                (v3.projPos.y - v1.projPos.y) * (v2.projPos.x - v1.projPos.x) < 0) return;
            }
            flag = 0;
            if (v1.projPos.x < 0) flag |= 1;
            if (v2.projPos.x < 0) flag |= 2;
            if (v3.projPos.x < 0) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, -v1.projPos.x / (v2.projPos.x - v1.projPos.x), true);
                    c2 = interpolate(v1, v3, -v1.projPos.x / (v3.projPos.x - v1.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, v2, v3, 1);
                    clipPolygonScreen(c1, v3, c2, 1);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, -v2.projPos.x / (v3.projPos.x - v2.projPos.x), true);
                    c2 = interpolate(v2, v1, -v2.projPos.x / (v1.projPos.x - v2.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, v3, v1, 1);
                    clipPolygonScreen(c1, v1, c2, 1);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, -v1.projPos.x / (v3.projPos.x - v1.projPos.x), true);
                    c2 = interpolate(v2, v3, -v2.projPos.x / (v3.projPos.x - v2.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, c2, v3, 1);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, -v3.projPos.x / (v1.projPos.x - v3.projPos.x), true);
                    c2 = interpolate(v3, v2, -v3.projPos.x / (v2.projPos.x - v3.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, v1, v2, 1);
                    clipPolygonScreen(c1, v2, c2, 1);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, -v3.projPos.x / (v2.projPos.x - v3.projPos.x), true);
                    c2 = interpolate(v1, v2, -v1.projPos.x / (v2.projPos.x - v1.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, c2, v2, 1);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, -v2.projPos.x / (v1.projPos.x - v2.projPos.x), true);
                    c2 = interpolate(v3, v1, -v3.projPos.x / (v1.projPos.x - v3.projPos.x), true);
                    c1.projPos.x = 0;
                    c2.projPos.x = 0;
                    clipPolygonScreen(c1, c2, v1, 1);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        case 1:// right
            flag = 0;
            if (v1.projPos.x > width) flag |= 1;
            if (v2.projPos.x > width) flag |= 2;
            if (v3.projPos.x > width) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, (width - v1.projPos.x) / (v2.projPos.x - v1.projPos.x), true);
                    c2 = interpolate(v1, v3, (width - v1.projPos.x) / (v3.projPos.x - v1.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, v2, v3, 2);
                    clipPolygonScreen(c1, v3, c2, 2);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, (width - v2.projPos.x) / (v3.projPos.x - v2.projPos.x), true);
                    c2 = interpolate(v2, v1, (width - v2.projPos.x) / (v1.projPos.x - v2.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, v3, v1, 2);
                    clipPolygonScreen(c1, v1, c2, 2);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, (width - v1.projPos.x) / (v3.projPos.x - v1.projPos.x), true);
                    c2 = interpolate(v2, v3, (width - v2.projPos.x) / (v3.projPos.x - v2.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, c2, v3, 2);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, (width - v3.projPos.x) / (v1.projPos.x - v3.projPos.x), true);
                    c2 = interpolate(v3, v2, (width - v3.projPos.x) / (v2.projPos.x - v3.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, v1, v2, 2);
                    clipPolygonScreen(c1, v2, c2, 2);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, (width - v3.projPos.x) / (v2.projPos.x - v3.projPos.x), true);
                    c2 = interpolate(v1, v2, (width - v1.projPos.x) / (v2.projPos.x - v1.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, c2, v2, 2);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, (width - v2.projPos.x) / (v1.projPos.x - v2.projPos.x), true);
                    c2 = interpolate(v3, v1, (width - v3.projPos.x) / (v1.projPos.x - v3.projPos.x), true);
                    c1.projPos.x = width;
                    c2.projPos.x = width;
                    clipPolygonScreen(c1, c2, v1, 2);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        case 2:// top
            flag = 0;
            if (v1.projPos.y < 0) flag |= 1;
            if (v2.projPos.y < 0) flag |= 2;
            if (v3.projPos.y < 0) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, -v1.projPos.y / (v2.projPos.y - v1.projPos.y), true);
                    c2 = interpolate(v1, v3, -v1.projPos.y / (v3.projPos.y - v1.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, v2, v3, 3);
                    clipPolygonScreen(c1, v3, c2, 3);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, -v2.projPos.y / (v3.projPos.y - v2.projPos.y), true);
                    c2 = interpolate(v2, v1, -v2.projPos.y / (v1.projPos.y - v2.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, v3, v1, 3);
                    clipPolygonScreen(c1, v1, c2, 3);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, -v1.projPos.y / (v3.projPos.y - v1.projPos.y), true);
                    c2 = interpolate(v2, v3, -v2.projPos.y / (v3.projPos.y - v2.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, c2, v3, 3);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, -v3.projPos.y / (v1.projPos.y - v3.projPos.y), true);
                    c2 = interpolate(v3, v2, -v3.projPos.y / (v2.projPos.y - v3.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, v1, v2, 3);
                    clipPolygonScreen(c1, v2, c2, 3);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, -v3.projPos.y / (v2.projPos.y - v3.projPos.y), true);
                    c2 = interpolate(v1, v2, -v1.projPos.y / (v2.projPos.y - v1.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, c2, v2, 3);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, -v2.projPos.y / (v1.projPos.y - v2.projPos.y), true);
                    c2 = interpolate(v3, v1, -v3.projPos.y / (v1.projPos.y - v3.projPos.y), true);
                    c1.projPos.y = 0;
                    c2.projPos.y = 0;
                    clipPolygonScreen(c1, c2, v1, 3);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        case 3:// bottom
            flag = 0;
            if (v1.projPos.y > height) flag |= 1;
            if (v2.projPos.y > height) flag |= 2;
            if (v3.projPos.y > height) flag |= 4;
            if (flag != 0) {
                switch (flag) {
                case 1:// 1
                    c1 = interpolate(v1, v2, (height - v1.projPos.y) / (v2.projPos.y - v1.projPos.y), true);
                    c2 = interpolate(v1, v3, (height - v1.projPos.y) / (v3.projPos.y - v1.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, v2, v3);
                    renderTriangle(c1, v3, c2);
                    return;
                case 2:// 2
                    c1 = interpolate(v2, v3, (height - v2.projPos.y) / (v3.projPos.y - v2.projPos.y), true);
                    c2 = interpolate(v2, v1, (height - v2.projPos.y) / (v1.projPos.y - v2.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, v3, v1);
                    renderTriangle(c1, v1, c2);
                    return;
                case 3:// 1 2
                    c1 = interpolate(v1, v3, (height - v1.projPos.y) / (v3.projPos.y - v1.projPos.y), true);
                    c2 = interpolate(v2, v3, (height - v2.projPos.y) / (v3.projPos.y - v2.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, c2, v3);
                    return;
                case 4:// 3
                    c1 = interpolate(v3, v1, (height - v3.projPos.y) / (v1.projPos.y - v3.projPos.y), true);
                    c2 = interpolate(v3, v2, (height - v3.projPos.y) / (v2.projPos.y - v3.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, v1, v2);
                    renderTriangle(c1, v2, c2);
                    return;
                case 5:// 3 1
                    c1 = interpolate(v3, v2, (height - v3.projPos.y) / (v2.projPos.y - v3.projPos.y), true);
                    c2 = interpolate(v1, v2, (height - v1.projPos.y) / (v2.projPos.y - v1.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, c2, v2);
                    return;
                case 6:// 2 3
                    c1 = interpolate(v2, v1, (height - v2.projPos.y) / (v1.projPos.y - v2.projPos.y), true);
                    c2 = interpolate(v3, v1, (height - v3.projPos.y) / (v1.projPos.y - v3.projPos.y), true);
                    c1.projPos.y = height;
                    c2.projPos.y = height;
                    renderTriangle(c1, c2, v1);
                    return;
                case 7:// 1 2 3
                    return;
                }
            }
        }
        renderTriangle(v1, v2, v3);
    }
    
    private function interpolate(v1:Vertex, v2:Vertex, t:Number, screen:Boolean):Vertex {
        var v3:Vertex = new Vertex();
        // v3.worldPos.x = v1.worldPos.x + (v2.worldPos.x - v1.worldPos.x) * t;
        // v3.worldPos.y = v1.worldPos.y + (v2.worldPos.y - v1.worldPos.y) * t;
        // v3.worldPos.z = v1.worldPos.z + (v2.worldPos.z - v1.worldPos.z) * t;
        v3.r = v1.r + (v2.r - v1.r) * t;
        v3.g = v1.g + (v2.g - v1.g) * t;
        v3.b = v1.b + (v2.b - v1.b) * t;
        if(norUse) {
            v3.sr = v1.sr + (v2.sr - v1.sr) * t;
            v3.sg = v1.sg + (v2.sg - v1.sg) * t;
            v3.sb = v1.sb + (v2.sb - v1.sb) * t;
        }
        if(screen) {
            v3.projPos.x = (v1.projPos.x + (v2.projPos.x - v1.projPos.x) * t) >> 0;
            v3.projPos.y = (v1.projPos.y + (v2.projPos.y - v1.projPos.y) * t) >> 0;
            v3.projPos.z = v1.projPos.z + (v2.projPos.z - v1.projPos.z) * t;
            if(texUse) {
                v3.tu = v1.tu + (v2.tu - v1.tu) * t;
                v3.tv = v1.tv + (v2.tv - v1.tv) * t;
            }
        } else {
            v3.viewPos.x = v1.viewPos.x + (v2.viewPos.x - v1.viewPos.x) * t;
            v3.viewPos.y = v1.viewPos.y + (v2.viewPos.y - v1.viewPos.y) * t;
            v3.viewPos.z = v1.viewPos.z + (v2.viewPos.z - v1.viewPos.z) * t;
            if(texUse) {
                v3.u = v1.u + (v2.u - v1.u) * t;
                v3.v = v1.v + (v2.v - v1.v) * t;
            }
        }
        return v3;
    }
    
    private function renderTriangle(v1:Vertex, v2:Vertex, v3:Vertex):void {
        if (v1.projPos.y < v2.projPos.y) {
            if (v2.projPos.y < v3.projPos.y) {
                vtop.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
                vleft.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
                vright.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
            } else if (v1.projPos.y < v3.projPos.y) {
                vtop.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
                vleft.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
                vright.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
            } else {
                vtop.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
                vleft.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
                vright.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
            }
        } else {
            if (v2.projPos.y > v3.projPos.y) {
                vtop.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
                vleft.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
                vright.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
            } else if (v1.projPos.y > v3.projPos.y) {
                vtop.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
                vleft.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
                vright.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
            } else {
                vtop.reset(v2.projPos.x, v2.projPos.y, v2.projPos.z, v2.tu, v2.tv, v2.r, v2.g, v2.b, v2.sr, v2.sg, v2.sb);
                vleft.reset(v1.projPos.x, v1.projPos.y, v1.projPos.z, v1.tu, v1.tv, v1.r, v1.g, v1.b, v1.sr, v1.sg, v1.sb);
                vright.reset(v3.projPos.x, v3.projPos.y, v3.projPos.z, v3.tu, v3.tv, v3.r, v3.g, v3.b, v3.sr, v3.sg, v3.sb);
            }
        }
        var min:int = vtop.y + 0.5;
        var mid:int = vleft.y + 0.5;
        var max:int = vright.y + 0.5;
        if ((vleft.x - vtop.x) / (vleft.y - vtop.y) > (vright.x - vtop.x) / (vright.y - vtop.y)) {
            const temp:RVtx = vleft;
            vleft = vright;
            vright = temp;
        }
        if (min == max) return;
        var flag:uint = (norUse ? 2 : 0) | (texUse? 1 : 0);
        switch(flag) {
        case 0:
            renderFlat(vtop, vleft, vright, min, mid, max);
            break;
        case 1:
            renderFlatTexture(vtop, vleft, vright, min, mid, max);
            break;
        case 2:
            renderGouraud(vtop, vleft, vright, min, mid, max);
            break;
        case 3:
            renderGouraudTexture(vtop, vleft, vright, min, mid, max);
            break;
        }
    }
    
    private function renderGouraudTexture(top:RVtx, left:RVtx, right:RVtx, min:int, mid:int, max:int):void {
        var invLength:Number;
        const zBuffer:Vector.<Number> = this.zBuffer;
        const fBuffer:Vector.<uint> = this.fBuffer;
        const maskU:uint = texWidth - 1;
        const maskV:uint = texHeight - 1;
        const shift:uint = texShift;
        
        // thickness
        var t:Number = (right.x - top.x) * (left.y - top.y) - (left.x - top.x) * (right.y - top.y);
        if (t == 0) return;
        t = 1 / t;
        
        // in scanline
        var lLength:int = left.y - top.y;
        var rLength:int = right.y - top.y;
        var lineZ:Number;
        var lineU:int;
        var lineV:int;
        var lineR:int;
        var lineG:int;
        var lineB:int;
        var lineSR:int;
        var lineSG:int;
        var lineSB:int;
        const addLineZ:Number = ((right.z - top.z) * lLength - (left.z - top.z) * rLength) * t * 0xffffff;
        const addLineU:int = ((right.u - top.u) * lLength - (left.u - top.u) * rLength) * t * 0xffff;
        const addLineV:int = ((right.v - top.v) * lLength - (left.v - top.v) * rLength) * t * 0xffff;
        const addLineR:int = ((right.r - top.r) * lLength - (left.r - top.r) * rLength) * t * 0xffff;
        const addLineG:int = ((right.g - top.g) * lLength - (left.g - top.g) * rLength) * t * 0xffff;
        const addLineB:int = ((right.b - top.b) * lLength - (left.b - top.b) * rLength) * t * 0xffff;
        const addLineSR:int = ((right.sr - top.sr) * lLength - (left.sr - top.sr) * rLength) * t * 0xffff;
        const addLineSG:int = ((right.sg - top.sg) * lLength - (left.sg - top.sg) * rLength) * t * 0xffff;
        const addLineSB:int = ((right.sb - top.sb) * lLength - (left.sb - top.sb) * rLength) * t * 0xffff;
        
        // left data
        var lY:int = left.y;
        invLength = 1 / lLength;
        var lX:Number = top.x;
        var lAddX:Number = (left.x - top.x) * invLength;
        var lZ:Number = top.z;
        var lAddZ:Number = (left.z - top.z) * invLength;
        var lU:Number = top.u;
        var lAddU:Number = (left.u - top.u) * invLength;
        var lV:Number = top.v;
        var lAddV:Number = (left.v - top.v) * invLength;
        var lR:Number = top.r;
        var lAddR:Number = (left.r - top.r) * invLength;
        var lG:Number = top.g;
        var lAddG:Number = (left.g - top.g) * invLength;
        var lB:Number = top.b;
        var lAddB:Number = (left.b - top.b) * invLength;
        var lSR:Number = top.sr;
        var lAddSR:Number = (left.sr - top.sr) * invLength;
        var lSG:Number = top.sg;
        var lAddSG:Number = (left.sg - top.sg) * invLength;
        var lSB:Number = top.sb;
        var lAddSB:Number = (left.sb - top.sb) * invLength;
        
        // right data
        var rY:int = right.y;
        invLength = 1 / rLength;
        var rX:Number = top.x;
        var rAddX:Number = (right.x - top.x) * invLength;
        var rZ:Number = top.z;
        var rAddZ:Number = (right.z - top.z) * invLength;
        var rU:Number = top.u;
        var rAddU:Number = (right.u - top.u) * invLength;
        var rV:Number = top.u;
        var rAddV:Number = (right.v - top.v) * invLength;
        var rR:Number = top.r;
        var rAddR:Number = (right.r - top.r) * invLength;
        var rG:Number = top.g;
        var rAddG:Number = (right.g - top.g) * invLength;
        var rB:Number = top.b;
        var rAddB:Number = (right.b - top.b) * invLength;
        var rSR:Number = top.sr;
        var rAddSR:Number = (right.sr - top.sr) * invLength;
        var rSG:Number = top.sg;
        var rAddSG:Number = (right.sg - top.sg) * invLength;
        var rSB:Number = top.sb;
        var rAddSB:Number = (right.sb - top.sb) * invLength;
        
        var y:int = min;
        var offset:int = min * width;
        
        while (y < max) {
            if (y == mid) {
                // flip left and right
                if (lY == rY)
                    return;
                if (y == lY) {
                    lLength = right.y - left.y;
                    invLength = 1 / lLength;
                    lX = left.x;
                    lAddX = (right.x - left.x) * invLength;
                    lZ = left.z;
                    lAddZ = (right.z - left.z) * invLength;
                    lU = left.u;
                    lAddU = (right.u - left.u) * invLength;
                    lV = left.v;
                    lAddV = (right.v - left.v) * invLength;
                    lR = left.r;
                    lAddR = (right.r - left.r) * invLength;
                    lG = left.g;
                    lAddG = (right.g - left.g) * invLength;
                    lB = left.b;
                    lAddB = (right.b - left.b) * invLength;
                    lSR = left.sr;
                    lAddSR = (right.sr - left.sr) * invLength;
                    lSG = left.sg;
                    lAddSG = (right.sg - left.sg) * invLength;
                    lSB = left.sb;
                    lAddSB = (right.sb - left.sb) * invLength;
                }
                if (y == rY) {
                    rLength = left.y - right.y;
                    invLength = 1 / rLength;
                    rX = right.x;
                    rAddX = (left.x - right.x) * invLength;
                    rZ = right.z;
                    rAddZ = (left.z - right.z) * invLength;
                    rU = right.u;
                    rAddU = (left.u - right.u) * invLength;
                    rV = right.v;
                    rAddV = (left.v - right.v) * invLength;
                    rR = right.r;
                    rAddR = (left.r - right.r) * invLength;
                    rG = right.g;
                    rAddG = (left.g - right.g) * invLength;
                    rB = right.b;
                    rAddB = (left.b - right.b) * invLength;
                    rSR = right.sr;
                    rAddSR = (left.sr - right.sr) * invLength;
                    rSG = right.sg;
                    rAddSG = (left.sg - right.sg) * invLength;
                    rSB = right.sb;
                    rAddSB = (left.sb - right.sb) * invLength;
                }
            }
            const ilx:int = lX;
            const irx:int = rX;
            if (irx - ilx > 0) {
                lineZ = lZ * 0xffffff;
                lineU = lU * 0xffff;
                lineV = lV * 0xffff;
                lineR = lR * 0xffff;
                lineG = lG * 0xffff;
                lineB = lB * 0xffff;
                lineSR = lSR * 0xffff;
                lineSG = lSG * 0xffff;
                lineSB = lSB * 0xffff;
                var pix:int = offset + ilx;
                const end:int = offset + irx;
                while (pix < end) {
                    if (zBuffer[pix] < lineZ) {
                        var col:uint = texel[lineU >> 16 & maskU | (lineV >> 16 & maskV) << shift];
                        col = (col & 0xff0000) * (lineR >> 16) >> 8 & 0xff0000 | (col & 0xff00) * (lineG >> 16) >> 8 & 0xff00 | (col & 0xff) * (lineB >> 16) >> 8 & 0xff;
                        const spc:uint = lineSR & 0xff0000 | lineSG >> 8 & 0xff00 | lineSB >> 16;
                        const temp:uint = (col & spc) + ((col ^ spc) >> 1 & 0x7f7f7f) & 0x808080;
                        const mask:uint = (temp << 1) - (temp >> 7);
                        fBuffer[pix] = col + spc - mask | mask;
                        zBuffer[pix] = lineZ;
                    }
                    pix++;
                    lineZ += addLineZ;
                    lineU += addLineU;
                    lineV += addLineV;
                    lineR += addLineR;
                    lineG += addLineG;
                    lineB += addLineB;
                    lineSR += addLineSR;
                    lineSG += addLineSG;
                    lineSB += addLineSB;
                }
            }
            lX += lAddX;
            rX += rAddX;
            lZ += lAddZ;
            rZ += rAddZ;
            lU += lAddU;
            rU += rAddU;
            lV += lAddV;
            rV += rAddV;
            lR += lAddR;
            rR += rAddR;
            lG += lAddG;
            rG += rAddG;
            lB += lAddB;
            rB += rAddB;
            lSR += lAddSR;
            rSR += rAddSR;
            lSG += lAddSG;
            rSG += rAddSG;
            lSB += lAddSB;
            rSB += rAddSB;
            offset += width;
            y++;
        }
    }
    
    private function renderGouraud(top:RVtx, left:RVtx, right:RVtx, min:int, mid:int, max:int):void {
        var invLength:Number;
        const zBuffer:Vector.<Number> = this.zBuffer;
        const fBuffer:Vector.<uint> = this.fBuffer;
        top.r += top.sr;
        if (top.r > 255) top.r = 255;
        top.g += top.sg;
        if (top.g > 255) top.g = 255;
        top.b += top.sb;
        if (top.b > 255) top.b = 255;
        left.r += left.sr;
        if (left.r > 255) left.r = 255;
        left.g += left.sg;
        if (left.g > 255) left.g = 255;
        left.b += left.sb;
        if (left.b > 255) left.b = 255;
        right.r += right.sr;
        if (right.r > 255) right.r = 255;
        right.g += right.sg;
        if (right.g > 255) right.g = 255;
        right.b += right.sb;
        if (right.b > 255) right.b = 255;
        
        // thickness
        var t:Number = (right.x - top.x) * (left.y - top.y) - (left.x - top.x) * (right.y - top.y);
        if (t == 0) return;
        t = 1 / t;
        
        // in scanline
        var lLength:int = left.y - top.y;
        var rLength:int = right.y - top.y;
        var lineZ:Number;
        var lineR:int;
        var lineG:int;
        var lineB:int;
        const addLineZ:Number = ((right.z - top.z) * lLength - (left.z - top.z) * rLength) * t * 0xffffff;
        const addLineR:int = ((right.r - top.r) * lLength - (left.r - top.r) * rLength) * t * 0xffff;
        const addLineG:int = ((right.g - top.g) * lLength - (left.g - top.g) * rLength) * t * 0xffff;
        const addLineB:int = ((right.b - top.b) * lLength - (left.b - top.b) * rLength) * t * 0xffff;
        
        // left data
        var lY:int = left.y;
        invLength = 1 / lLength;
        var lX:Number = top.x;
        var lAddX:Number = (left.x - top.x) * invLength;
        var lZ:Number = top.z;
        var lAddZ:Number = (left.z - top.z) * invLength;
        var lR:Number = top.r;
        var lAddR:Number = (left.r - top.r) * invLength;
        var lG:Number = top.g;
        var lAddG:Number = (left.g - top.g) * invLength;
        var lB:Number = top.b;
        var lAddB:Number = (left.b - top.b) * invLength;
        
        // right data
        var rY:int = right.y;
        invLength = 1 / rLength;
        var rX:Number = top.x;
        var rAddX:Number = (right.x - top.x) * invLength;
        var rZ:Number = top.z;
        var rAddZ:Number = (right.z - top.z) * invLength;
        var rR:Number = top.r;
        var rAddR:Number = (right.r - top.r) * invLength;
        var rG:Number = top.g;
        var rAddG:Number = (right.g - top.g) * invLength;
        var rB:Number = top.b;
        var rAddB:Number = (right.b - top.b) * invLength;
        
        var y:int = min;
        var offset:int = min * width;
        
        while (y < max) {
            if (y == mid) {
                // flip left and right
                if (lY == rY)
                    return;
                if (y == lY) {
                    lLength = right.y - left.y;
                    invLength = 1 / lLength;
                    lX = left.x;
                    lAddX = (right.x - left.x) * invLength;
                    lZ = left.z;
                    lAddZ = (right.z - left.z) * invLength;
                    lR = left.r;
                    lAddR = (right.r - left.r) * invLength;
                    lG = left.g;
                    lAddG = (right.g - left.g) * invLength;
                    lB = left.b;
                    lAddB = (right.b - left.b) * invLength;
                }
                if (y == rY) {
                    rLength = left.y - right.y;
                    invLength = 1 / rLength;
                    rX = right.x;
                    rAddX = (left.x - right.x) * invLength;
                    rZ = right.z;
                    rAddZ = (left.z - right.z) * invLength;
                    rR = right.r;
                    rAddR = (left.r - right.r) * invLength;
                    rG = right.g;
                    rAddG = (left.g - right.g) * invLength;
                    rB = right.b;
                    rAddB = (left.b - right.b) * invLength;
                }
            }
            const ilx:int = lX;
            const irx:int = rX;
            if (irx - ilx > 0) {
                lineZ = lZ * 0xffffff;
                lineR = lR * 0xffff;
                lineG = lG * 0xffff;
                lineB = lB * 0xffff;
                var pix:int = offset + ilx;
                const end:int = offset + irx;
                while (pix < end) {
                    if (zBuffer[pix] < lineZ) {
                        fBuffer[pix] = lineR & 0xff0000 | lineG >> 8 & 0xff00 | lineB >> 16;
                        zBuffer[pix] = lineZ;
                    }
                    pix++;
                    lineZ += addLineZ;
                    lineR += addLineR;
                    lineG += addLineG;
                    lineB += addLineB;
                }
            }
            lX += lAddX;
            rX += rAddX;
            lZ += lAddZ;
            rZ += rAddZ;
            lR += lAddR;
            rR += rAddR;
            lG += lAddG;
            rG += rAddG;
            lB += lAddB;
            rB += rAddB;
            offset += width;
            y++;
        }
    }
    
    private function renderFlat(top:RVtx, left:RVtx, right:RVtx, min:int, mid:int, max:int):void {
        var invLength:Number;
        const zBuffer:Vector.<Number> = this.zBuffer;
        const fBuffer:Vector.<uint> = this.fBuffer;
        var colorRGB:uint = color[6] << 16 | color[7] << 8 | color[8];
        
        // thickness
        var t:Number = (right.x - top.x) * (left.y - top.y) - (left.x - top.x) * (right.y - top.y);
        if (t == 0) return;
        t = 1 / t;
        
        // in scanline
        var lLength:int = left.y - top.y;
        var rLength:int = right.y - top.y;
        var lineZ:Number;
        const addLineZ:Number = ((right.z - top.z) * lLength - (left.z - top.z) * rLength) * t * 0xffffff;
        
        // left data
        var lY:int = left.y;
        invLength = 1 / lLength;
        var lX:Number = top.x;
        var lAddX:Number = (left.x - top.x) * invLength;
        var lZ:Number = top.z;
        var lAddZ:Number = (left.z - top.z) * invLength;
        
        // right data
        var rY:int = right.y;
        invLength = 1 / rLength;
        var rX:Number = top.x;
        var rAddX:Number = (right.x - top.x) * invLength;
        var rZ:Number = top.z;
        var rAddZ:Number = (right.z - top.z) * invLength;
        
        var y:int = min;
        var offset:int = min * width;
        
        while (y < max) {
            if (y == mid) {
                // flip left and right
                if (lY == rY)
                    return;
                if (y == lY) {
                    lLength = right.y - left.y;
                    invLength = 1 / lLength;
                    lX = left.x;
                    lAddX = (right.x - left.x) * invLength;
                    lZ = left.z;
                    lAddZ = (right.z - left.z) * invLength;
                }
                if (y == rY) {
                    rLength = left.y - right.y;
                    invLength = 1 / rLength;
                    rX = right.x;
                    rAddX = (left.x - right.x) * invLength;
                    rZ = right.z;
                    rAddZ = (left.z - right.z) * invLength;
                }
            }
            const ilx:int = lX;
            const irx:int = rX;
            if (irx - ilx > 0) {
                lineZ = lZ * 0xffffff;
                var pix:int = offset + ilx;
                const end:int = offset + irx;
                while (pix < end) {
                    if (zBuffer[pix] < lineZ) {
                        fBuffer[pix] = colorRGB;
                        zBuffer[pix] = lineZ;
                    }
                    pix++;
                    lineZ += addLineZ;
                }
            }
            lX += lAddX;
            rX += rAddX;
            lZ += lAddZ;
            rZ += rAddZ;
            offset += width;
            y++;
        }
    }
    
    private function renderFlatTexture(top:RVtx, left:RVtx, right:RVtx, min:int, mid:int, max:int):void {
        var invLength:Number;
        const zBuffer:Vector.<Number> = this.zBuffer;
        const fBuffer:Vector.<uint> = this.fBuffer;
        const texel:Vector.<uint> = this.texel;
        const maskU:uint = texWidth - 1;
        const maskV:uint = texHeight - 1;
        const shift:uint = texShift;
        const cr:uint = color[0] + 1;
        const cg:uint = color[1] + 1;
        const cb:uint = color[2] + 1;
        const spc:uint = color[3] << 16 | color[4] << 8 | color[5];
        
        // thickness
        var t:Number = (right.x - top.x) * (left.y - top.y) - (left.x - top.x) * (right.y - top.y);
        if (t == 0) return;
        t = 1 / t;
        
        // in scanline
        var lLength:int = left.y - top.y;
        var rLength:int = right.y - top.y;
        var lineZ:Number;
        var lineU:int;
        var lineV:int;
        const addLineZ:Number = ((right.z - top.z) * lLength - (left.z - top.z) * rLength) * t * 0xffffff;
        const addLineU:int = ((right.u - top.u) * lLength - (left.u - top.u) * rLength) * t * 0xffff;
        const addLineV:int = ((right.v - top.v) * lLength - (left.v - top.v) * rLength) * t * 0xffff;
        
        // left data
        var lY:int = left.y;
        invLength = 1 / lLength;
        var lX:Number = top.x;
        var lAddX:Number = (left.x - top.x) * invLength;
        var lZ:Number = top.z;
        var lAddZ:Number = (left.z - top.z) * invLength;
        var lU:Number = top.u;
        var lAddU:Number = (left.u - top.u) * invLength;
        var lV:Number = top.v;
        var lAddV:Number = (left.v - top.v) * invLength;
        
        // right data
        var rY:int = right.y;
        invLength = 1 / rLength;
        var rX:Number = top.x;
        var rAddX:Number = (right.x - top.x) * invLength;
        var rZ:Number = top.z;
        var rAddZ:Number = (right.z - top.z) * invLength;
        var rU:Number = top.u;
        var rAddU:Number = (right.u - top.u) * invLength;
        var rV:Number = top.u;
        var rAddV:Number = (right.v - top.v) * invLength;
        
        var y:int = min;
        var offset:int = min * width;
        while (y < max) {
            if (y == mid) {
                // flip left and right
                if (lY == rY)
                    return;
                if (y == lY) {
                    lLength = right.y - left.y;
                    invLength = 1 / lLength;
                    lX = left.x;
                    lAddX = (right.x - left.x) * invLength;
                    lZ = left.z;
                    lAddZ = (right.z - left.z) * invLength;
                    lU = left.u;
                    lAddU = (right.u - left.u) * invLength;
                    lV = left.v;
                    lAddV = (right.v - left.v) * invLength;
                }
                if (y == rY) {
                    rLength = left.y - right.y;
                    invLength = 1 / rLength;
                    rX = right.x;
                    rAddX = (left.x - right.x) * invLength;
                    rZ = right.z;
                    rAddZ = (left.z - right.z) * invLength;
                    rU = right.u;
                    rAddU = (left.u - right.u) * invLength;
                    rV = right.v;
                    rAddV = (left.v - right.v) * invLength;
                }
            }
            const ilx:int = lX;
            const irx:int = rX;
            if (irx - ilx > 0) {
                lineZ = lZ * 0xffffff;
                lineU = lU * 0xffff;
                lineV = lV * 0xffff;
                var pix:int = offset + ilx;
                const end:int = offset + irx;
                while (pix < end) {
                    if (zBuffer[pix] < lineZ) {
                        var col:uint = texel[lineU >> 16 & maskU | (lineV >> 16 & maskV) << shift];
                        col = (col & 0xff0000) * cr >> 8 & 0xff0000 | (col & 0xff00) * cg >> 8 & 0xff00 | (col & 0xff) * cb >> 8 & 0xff;
                        const temp:uint = (col & spc) + ((col ^ spc) >> 1 & 0x7f7f7f) & 0x808080;
                        const mask:uint = (temp << 1) - (temp >> 7);
                        fBuffer[pix] = col + spc - mask | mask;
                        zBuffer[pix] = lineZ;
                    }
                    pix++;
                    lineZ += addLineZ;
                    lineU += addLineU;
                    lineV += addLineV;
                }
            }
            lX += lAddX;
            rX += rAddX;
            lZ += lAddZ;
            rZ += rAddZ;
            lU += lAddU;
            rU += rAddU;
            lV += lAddV;
            rV += rAddV;
            offset += width;
            y++;
        }
    }
    
    public function renderPoint(vertex:Vec3D):void {
        worldMatrix.mulEqualVector(vertex);
        viewMatrix.mulEqualVector(vertex);
        projectionMatrix.mulEqualVector(vertex);
        var invW:Number = 1 / vertex.w;
        vertex.x *= invW;
        vertex.y *= invW;
        vertex.z *= invW;
        vertex.x = (width2 + vertex.x * width2) >> 0;
        vertex.y = (height2 + vertex.y * height2) >> 0;
        if (vertex.x >= 0 && vertex.x < width && vertex.y >= 0 && vertex.y < height) {
            var index:uint = vertex.y * width + vertex.x;
            fBuffer[index] = 0xffffff;
        }
    }
    
    public function endScene():void {
        img.setVector(img.rect, fBuffer);
    }
    
    public function lookAt(position:Vec3D, target:Vec3D, up:Vec3D):void {
        cameraPosition = position;
        cameraTarget = target;
        cameraUp = up;
        var axisZ:Vec3D = cameraTarget.sub(cameraPosition);
        axisZ.normalize();
        var axisX:Vec3D = cameraUp.cross(axisZ);
        axisX.normalize();
        var axisY:Vec3D = axisZ.cross(axisX);
        viewMatrix.e00 = axisX.x;
        viewMatrix.e01 = axisY.x;
        viewMatrix.e02 = axisZ.x;
        viewMatrix.e03 = 0;
        viewMatrix.e10 = axisX.y;
        viewMatrix.e11 = axisY.y;
        viewMatrix.e12 = axisZ.y;
        viewMatrix.e13 = 0;
        viewMatrix.e20 = axisX.z;
        viewMatrix.e21 = axisY.z;
        viewMatrix.e22 = axisZ.z;
        viewMatrix.e23 = 0;
        viewMatrix.e30 = -axisX.dot(cameraPosition);
        viewMatrix.e31 = -axisY.dot(cameraPosition);
        viewMatrix.e32 = -axisZ.dot(cameraPosition);
        viewMatrix.e33 = 1;
    }
    
    public function perspective(fovY:Number, near:Number, far:Number):void {
        this.near = near;
        this.far = far;
        var h:Number = Math.cos(fovY * 0.5) / Math.sin(fovY * 0.5);
        var w:Number = h * aspect;
        var ffn:Number = far / (far - near);
        projectionMatrix.e00 = w;
        projectionMatrix.e01 = 0;
        projectionMatrix.e02 = 0;
        projectionMatrix.e03 = 0;
        projectionMatrix.e10 = 0;
        projectionMatrix.e11 = h;
        projectionMatrix.e12 = 0;
        projectionMatrix.e13 = 0;
        projectionMatrix.e20 = 0;
        projectionMatrix.e21 = 0;
        projectionMatrix.e22 = ffn;
        projectionMatrix.e23 = 1;
        projectionMatrix.e30 = 0;
        projectionMatrix.e31 = 0;
        projectionMatrix.e32 = -near * ffn;
        projectionMatrix.e33 = 0;
    }
}

class Light {
    public static const DISABLED:uint = 0;
    public static const DIRECTIONAL:uint = 1;
    public var dir:Vec3D;
    public var pos:Vec3D;
    public var r:Number;
    public var g:Number;
    public var b:Number;
    public var type:uint;
    public function Light() {
        type = DISABLED;
        dir = new Vec3D();
        pos = new Vec3D();
    }
    
    public function directional(dx:Number, dy:Number, dz:Number, r:Number, g:Number, b:Number):void {
        type = DIRECTIONAL;
        dir.setVector(dx, dy, dz);
        dir.normalize();
        this.r = r;
        this.g = g;
        this.b = b;
    }
    
    public function disable():void {
        type = DISABLED;
    }
}

class Model {
    public var vertices:Vector.<Vertex>;
    public var faces:Vector.<Vector.<uint>>;
    public var uvs:Vector.<Vector.<Number>>;
    public var normals:Vector.<Vector.<Number>>;
    public function Model() {
        vertices = new Vector.<Vertex>();
        faces = new Vector.<Vector.<uint>>();
        uvs = new Vector.<Vector.<Number>>();
        normals = new Vector.<Vector.<Number>>();
    }
    
    public function toBox(w:Number, h:Number, d:Number):void {
        w *= 0.5;
        h *= 0.5;
        d *= 0.5;
        vertices[0] = new Vertex(-w, -h, d);
        vertices[1] = new Vertex(w, -h, d);
        vertices[2] = new Vertex(w, -h, -d);
        vertices[3] = new Vertex(-w, -h, -d);
        vertices[4] = new Vertex(-w, h, d);
        vertices[5] = new Vertex(w, h, d);
        vertices[6] = new Vertex(w, h, -d);
        vertices[7] = new Vertex( -w, h, -d);
        for (var i:int = 0; i < 12; i++)
            initFace(i);
        setFace(0, 0, 1, 2, 0, 0, 1, 0, 1, 1);
        setFace(1, 0, 2, 3, 0, 0, 1, 1, 0, 1);
        setFace(2, 7, 6, 5, 0, 0, 1, 0, 1, 1);
        setFace(3, 7, 5, 4, 0, 0, 1, 1, 0, 1);
        setFace(4, 4, 5, 1, 0, 0, 1, 0, 1, 1);
        setFace(5, 4, 1, 0, 0, 0, 1, 1, 0, 1);
        setFace(6, 6, 7, 3, 0, 0, 1, 0, 1, 1);
        setFace(7, 6, 3, 2, 0, 0, 1, 1, 0, 1);
        setFace(8, 5, 6, 2, 0, 0, 1, 0, 1, 1);
        setFace(9, 5, 2, 1, 0, 0, 1, 1, 0, 1);
        setFace(10, 7, 4, 0, 0, 0, 1, 0, 1, 1);
        setFace(11, 7, 0, 3, 0, 0, 1, 1, 0, 1);
    }
    
    public function toSphere(divV:uint, divH:uint, radius:Number):void {
        var theta:Number;
        var phi:Number;
        var dTheta:Number = Math.PI * 2 / divV;
        var dPhi:Number = Math.PI / divH;
        var numVertices:uint = (divH + 1) * divV - (divV - 1) * 2;
        vertices[0] = new Vertex(0, radius, 0);
        phi = dPhi;
        for (var i:int = 1; i < divH; i++) {
            theta = 0;
            for (var j:int = 0; j < divV; j++) {
                var index:int = (i - 1) * divV + j + 1;
                vertices[index] = new Vertex(radius * Math.sin(phi) * Math.cos(theta), radius * Math.cos(phi), radius * Math.sin(phi) * Math.sin(theta));
                theta += dTheta;
            }
            phi += dPhi;
        }
        vertices[numVertices - 1] = new Vertex(0, -radius, 0);
        var numFaces:int = 0;
        var invV:Number = 1 / divV;
        var invH:Number = 1 / divH;
        for (i = 0; i < divH; i++) {
            for (j = 0; j < divV; j++) {
                if (i == 0) {
                    initFace(numFaces);
                    setFace(numFaces, 0, j + 1, (j + 1) % divV + 1, invV * (j + 0.5), 0, invV * j, invH, invV * (j + 1), invH);
                    numFaces++;
                } else if (i == divH - 1) {
                    initFace(numFaces);
                    setFace(numFaces, numVertices - 1, (i - 1) * divV + (j + 1) % divV + 1, (i - 1) * divV + j + 1, invV * (j + 0.5), 1, invV * (j + 1), 1 - invH, invV * j, 1 - invH);
                    numFaces++;
                } else {
                    initFace(numFaces);
                    setFace(numFaces, (i - 1) * divV + j + 1, i * divV + j + 1, i * divV + (j + 1) % divV + 1, invV * j, invH * i, invV * j, invH * (i + 1), invV * (j + 1), invH * (i + 1));
                    numFaces++;
                    initFace(numFaces);
                    setFace(numFaces, (i - 1) * divV + j + 1, i * divV + (j + 1) % divV + 1, (i - 1) * divV + (j + 1) % divV + 1, invV * j, invH * i, invV * (j + 1), invH * (i + 1), invV * (j + 1), invH * i);
                    numFaces++;
                }
            }
        }
    }
    
    public function toTorus(divV:uint, divH:uint, inRadius:Number, outRadius:Number):void {
        var theta:Number;
        var phi:Number;
        var dTheta:Number = Math.PI * 2 / divV;
        var dPhi:Number = Math.PI * 2 / divH;
        var numVertices:uint = divH * divV;
        phi = 0;
        for (var i:int = 0; i < divH; i++) {
            theta = 0;
            for (var j:int = 0; j < divV; j++) {
                var index:int = i * divV + j;
                vertices[index] = new Vertex(Math.cos(theta) * (outRadius + (outRadius - inRadius) * Math.sin(phi)), (outRadius - inRadius) * Math.cos(phi), Math.sin(theta) * (outRadius + (outRadius - inRadius) * Math.sin(phi)));
                theta += dTheta;
            }
            phi += dPhi;
        }
        var numFaces:int = 0;
        var invV:Number = 1 / divV;
        var invH:Number = 1 / divH;
        for (i = 0; i < divH; i++) {
            for (j = 0; j < divV; j++) {
                initFace(numFaces);
                setFace(numFaces, i * divV + j, (i + 1) % divH * divV + j, (i + 1) % divH * divV + (j + 1) % divV, invV * j, invH * i, invV * j, invH * (i + 1), invV * (j + 1), invH * (i + 1));
                numFaces++;
                initFace(numFaces);
                setFace(numFaces, i * divV + j, (i + 1) % divH * divV + (j + 1) % divV, i % divH * divV + (j + 1) % divV, invV * j, invH * i, invV * (j + 1), invH * (i + 1), invV * (j + 1), invH * i);
                numFaces++;
            }
        }
    }
    
    public function reverseFace():void {
        for (var i:int = 0; i < faces.length; i++) {
            const temp1:uint = faces[i][0];
            faces[i][0] = faces[i][1];
            faces[i][1] = temp1;
            var temp2:Number = uvs[i][0];
            uvs[i][0] = uvs[i][2];
            uvs[i][2] = temp2;
            temp2 = uvs[i][1];
            uvs[i][1] = uvs[i][3];
            uvs[i][3] = temp2;
        }
    }
    
    public function calcNormals():void {
        const temp:Vector.<Vec3D> = new Vector.<Vec3D>(vertices.length, true);
        for (i = 0; i < vertices.length; i++)
            temp[i] = new Vec3D();
        for (var i:int = 0; i < faces.length; i++) {
            var nor:Vec3D = vertices[faces[i][2]].pos.sub(vertices[faces[i][0]].pos).cross(vertices[faces[i][1]].pos.sub(vertices[faces[i][0]].pos));
            nor.normalize();
            temp[faces[i][0]].addEqual(nor);
            temp[faces[i][1]].addEqual(nor);
            temp[faces[i][2]].addEqual(nor);
        }
        for (i = 0; i < vertices.length; i++)
            temp[i].normalize();
        for (i = 0; i < faces.length; i++) {
            normals[i][0] = temp[faces[i][0]].x;
            normals[i][1] = temp[faces[i][0]].y;
            normals[i][2] = temp[faces[i][0]].z;
            normals[i][3] = temp[faces[i][1]].x;
            normals[i][4] = temp[faces[i][1]].y;
            normals[i][5] = temp[faces[i][1]].z;
            normals[i][6] = temp[faces[i][2]].x;
            normals[i][7] = temp[faces[i][2]].y;
            normals[i][8] = temp[faces[i][2]].z;
        }
    }
    
    public function initFace(id:uint):void {
        faces[id] = new Vector.<uint>(3, true);
        uvs[id] = new Vector.<Number>(6, true);
        normals[id] = new Vector.<Number>(9, true);
    }
    
    public function setFace(id:uint, vtx1:uint, vtx2:uint, vtx3:uint, u1:Number = 0, v1:Number = 0, u2:Number = 0, v2:Number = 0, u3:Number = 0, v3:Number = 0):void {
        faces[id][0] = vtx1;
        faces[id][1] = vtx2;
        faces[id][2] = vtx3;
        uvs[id][0] = u1;
        uvs[id][1] = v1;
        uvs[id][2] = u2;
        uvs[id][3] = v2;
        uvs[id][4] = u3;
        uvs[id][5] = v3;
        normals[id][0] = 0;
        normals[id][1] = 0;
        normals[id][2] = 0;
        normals[id][3] = 0;
        normals[id][4] = 0;
        normals[id][5] = 0;
        normals[id][6] = 0;
        normals[id][7] = 0;
        normals[id][8] = 0;
    }
    
    public function render(renderer:Renderer):void {
        renderer.createNormalMatrix();
        renderer.transformVertices(vertices);
        for (var i:int = 0; i < faces.length; i++) {
            const v1:Vertex = vertices[faces[i][0]];
            const v2:Vertex = vertices[faces[i][1]];
            const v3:Vertex = vertices[faces[i][2]];
            const normal:Vector.<Number> = normals[i];
            v1.u = uvs[i][0];
            v1.v = uvs[i][1];
            v2.u = uvs[i][2];
            v2.v = uvs[i][3];
            v3.u = uvs[i][4];
            v3.v = uvs[i][5];
            v1.normal.x = normal[0];
            v1.normal.y = normal[1];
            v1.normal.z = normal[2];
            v2.normal.x = normal[3];
            v2.normal.y = normal[4];
            v2.normal.z = normal[5];
            v3.normal.x = normal[6];
            v3.normal.y = normal[7];
            v3.normal.z = normal[8];
            renderer.renderPolygonWithoutTransform(v1, v2, v3);
            // renderer.renderPolygon(v1, v2, v3);
        }
        renderer.destroyNormalMatrix();
    }
}

class Vertex {
    public var pos:Vec3D;
    public var worldPos:Vec3D;
    public var viewPos:Vec3D;
    public var projPos:Vec3D;
    public var normal:Vec3D;
    public var u:Number;
    public var v:Number;
    public var tn:Vec3D;
    public var tu:Number;
    public var tv:Number;
    public var r:int;
    public var g:int;
    public var b:int;
    public var sr:int;
    public var sg:int;
    public var sb:int;
    
    public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0):void {
        pos = new Vec3D(x, y, z);
        worldPos = new Vec3D();
        viewPos = new Vec3D();
        projPos = new Vec3D();
        normal = new Vec3D();
        tn = new Vec3D();
    }
}

class RVtx {
    public var x:int;
    public var y:int;
    public var z:Number;
    public var u:Number;
    public var v:Number;
    public var r:int;
    public var g:int;
    public var b:int;
    public var sr:int;
    public var sg:int;
    public var sb:int;
    
    public function RVtx():void {
    }
    
    public function reset(x:Number, y:Number, z:Number, u:Number, v:Number, r:int = 0, g:int = 0, b:int = 0, sr:int = 0, sg:int = 0, sb:int = 0):void {
        this.x = x;
        this.y = y;
        this.z = z;
        this.u = u;
        this.v = v;
        this.r = r;
        this.g = g;
        this.b = b;
        this.sr = sr;
        this.sg = sg;
        this.sb = sb;
    }
}

class Texture {
    public var texel:Vector.<uint>;
    public var width:uint;
    public var height:uint;
    public var shift:uint;
    public var size:uint;
    public var loaded:Boolean;
    
    public function Texture() {
        loaded = false;
    }
    
    public function init(width:uint, height:uint, pixels:Vector.<uint>):void {
        loaded = false;
        this.width = width;
        this.height = height;
        size = width * height;
        shift = 0;
        for (var i:int = 0; i < 16; i++) if (((width - 1) & (1 << i)) != 0) shift++;
        texel = new Vector.<uint>(size, true);
        for (i = 0; i < size; i++) texel[i] = pixels[i];
        loaded = true;
    }
    
    public function load(url:String):void {
        loaded = false;
        var bmd:BitmapData = null;
        var loader:Loader = new Loader();
        loader.load(new URLRequest(url), new LoaderContext(true));
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
            function(e:Event = null):void {
                bmd = Bitmap(loader.content).bitmapData;
                width = bmd.width;
                height = bmd.height;
                size = width * height;
                shift = 0;
                for (var i:int = 0; i < 16; i++) if (((width - 1) & (1 << i)) != 0) shift++;
                var pix:Vector.<uint> = bmd.getVector(bmd.rect);
                texel = new Vector.<uint>(size, true);
                for (i = 0; i < size; i++) texel[i] = pix[i];
                loaded = true;
            });
    }
}

class Vec3D {
    /*
     * [x y z w]
     */
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var w:Number;
    
    public function Vec3D(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0) {
        setVector(x, y, z, w);
    }
    
    public function setVector(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0):void {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }
    
    public function add(v:Vec3D):Vec3D {
        return new Vec3D(x + v.x, y + v.y, z + v.z);
    }
    
    public function addEqual(v:Vec3D):void {
        x += v.x;
        y += v.y;
        z += v.z;
    }
    
    public function sub(v:Vec3D):Vec3D {
        return new Vec3D(x - v.x, y - v.y, z - v.z);
    }
    
    public function subEqual(v:Vec3D):void {
        x -= v.x;
        y -= v.y;
        z -= v.z;
    }
    
    public function mul(s:Number):Vec3D {
        return new Vec3D(x * s, y * s, z * s);
    }
    
    public function mulEqual(s:Number):void {
        x *= s;
        y *= s;
        z *= s;
    }
    
    public function dot(v:Vec3D):Number {
        return x * v.x + y * v.y + z * v.z;
    }
    
    public function cross(v:Vec3D):Vec3D {
        return new Vec3D(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
    }
    
    public function length():Number {
        return Math.sqrt(x * x + y * y + z * z);
    }
    
    public function normalize():void {
        var length:Number = length();
        if (length != 0 && length != 1) {
            length = 1 / length;
            x *= length;
            y *= length;
            z *= length;
        }
    }
}

class Mat4x4 {
    /*
     * [e00 e01 e02 e03]
     * [e10 e11 e12 e13]
     * [e20 e21 e22 e23]
     * [e30 e31 e32 e33]
     */
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
    
    public function Mat4x4(e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1) {
        setMatrix(e00, e01, e02, e03, e10, e11, e12, e13,
            e20, e21, e22, e23, e30, e31, e32, e33);
    }
    
    public function identity():void {
        setMatrix();
    }
    
    
    public function setMatrix(e00:Number = 1, e01:Number = 0, e02:Number = 0, e03:Number = 0,
        e10:Number = 0, e11:Number = 1, e12:Number = 0, e13:Number = 0,
        e20:Number = 0, e21:Number = 0, e22:Number = 1, e23:Number = 0,
        e30:Number = 0, e31:Number = 0, e32:Number = 0, e33:Number = 1):void {
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
    
    public function rotateX(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e11 = cos;
        m.e12 = sin;
        m.e21 = -sin;
        m.e22 = cos;
        mulEqualMatrix(m);
    }
    
    public function rotateY(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e00 = cos;
        m.e02 = sin;
        m.e20 = -sin;
        m.e22 = cos;
        mulEqualMatrix(m);
    }
    
    public function rotateZ(theta:Number):void {
        var sin:Number = Math.sin(theta);
        var cos:Number = Math.cos(theta);
        var m:Mat4x4 = new Mat4x4();
        m.e00 = cos;
        m.e01 = -sin;
        m.e10 = sin;
        m.e11 = cos;
        mulEqualMatrix(m);
    }
    
    public function translate(tx:Number, ty:Number, tz:Number):void {
        var m:Mat4x4 = new Mat4x4();
        m.e30 = tx;
        m.e31 = ty;
        m.e32 = tz;
        mulEqualMatrix(m);
    }
    
    public function scale(sx:Number, sy:Number, sz:Number):void {
        var m:Mat4x4 = new Mat4x4();
        m.e00 = sx;
        m.e11 = sy;
        m.e22 = sz;
        mulEqualMatrix(m);
    }
    
    public function mulMatrix(m:Mat4x4):Mat4x4 {
        var t11:Number = e00 * m.e00 + e01 * m.e10 + e02 * m.e20 + e03 * m.e30;
        var t12:Number = e00 * m.e01 + e01 * m.e11 + e02 * m.e21 + e03 * m.e31;
        var t13:Number = e00 * m.e02 + e01 * m.e12 + e02 * m.e22 + e03 * m.e32;
        var t14:Number = e00 * m.e03 + e01 * m.e13 + e02 * m.e23 + e03 * m.e33;
        var t21:Number = e10 * m.e00 + e11 * m.e10 + e12 * m.e20 + e13 * m.e30;
        var t22:Number = e10 * m.e01 + e11 * m.e11 + e12 * m.e21 + e13 * m.e31;
        var t23:Number = e10 * m.e02 + e11 * m.e12 + e12 * m.e22 + e13 * m.e32;
        var t24:Number = e10 * m.e03 + e11 * m.e13 + e12 * m.e23 + e13 * m.e33;
        var t31:Number = e20 * m.e00 + e21 * m.e10 + e22 * m.e20 + e23 * m.e30;
        var t32:Number = e20 * m.e01 + e21 * m.e11 + e22 * m.e21 + e23 * m.e31;
        var t33:Number = e20 * m.e02 + e21 * m.e12 + e22 * m.e22 + e23 * m.e32;
        var t34:Number = e20 * m.e03 + e21 * m.e13 + e22 * m.e23 + e23 * m.e33;
        var t41:Number = e30 * m.e00 + e31 * m.e10 + e32 * m.e20 + e33 * m.e30;
        var t42:Number = e30 * m.e01 + e31 * m.e11 + e32 * m.e21 + e33 * m.e31;
        var t43:Number = e30 * m.e02 + e31 * m.e12 + e32 * m.e22 + e33 * m.e32;
        var t44:Number = e30 * m.e03 + e31 * m.e13 + e32 * m.e23 + e33 * m.e33;
        return new Mat4x4(t11, t12, t13, t14, t21, t22, t23, t24, t31, t32, t33, t34, t41,
                t42, t43, t44);
    }
    
    public function mulEqualMatrix(m:Mat4x4):void {
        var t11:Number = e00 * m.e00 + e01 * m.e10 + e02 * m.e20 + e03 * m.e30;
        var t12:Number = e00 * m.e01 + e01 * m.e11 + e02 * m.e21 + e03 * m.e31;
        var t13:Number = e00 * m.e02 + e01 * m.e12 + e02 * m.e22 + e03 * m.e32;
        var t14:Number = e00 * m.e03 + e01 * m.e13 + e02 * m.e23 + e03 * m.e33;
        var t21:Number = e10 * m.e00 + e11 * m.e10 + e12 * m.e20 + e13 * m.e30;
        var t22:Number = e10 * m.e01 + e11 * m.e11 + e12 * m.e21 + e13 * m.e31;
        var t23:Number = e10 * m.e02 + e11 * m.e12 + e12 * m.e22 + e13 * m.e32;
        var t24:Number = e10 * m.e03 + e11 * m.e13 + e12 * m.e23 + e13 * m.e33;
        var t31:Number = e20 * m.e00 + e21 * m.e10 + e22 * m.e20 + e23 * m.e30;
        var t32:Number = e20 * m.e01 + e21 * m.e11 + e22 * m.e21 + e23 * m.e31;
        var t33:Number = e20 * m.e02 + e21 * m.e12 + e22 * m.e22 + e23 * m.e32;
        var t34:Number = e20 * m.e03 + e21 * m.e13 + e22 * m.e23 + e23 * m.e33;
        var t41:Number = e30 * m.e00 + e31 * m.e10 + e32 * m.e20 + e33 * m.e30;
        var t42:Number = e30 * m.e01 + e31 * m.e11 + e32 * m.e21 + e33 * m.e31;
        var t43:Number = e30 * m.e02 + e31 * m.e12 + e32 * m.e22 + e33 * m.e32;
        var t44:Number = e30 * m.e03 + e31 * m.e13 + e32 * m.e23 + e33 * m.e33;
        setMatrix(t11, t12, t13, t14, t21, t22, t23, t24, t31, t32, t33, t34, t41,
                t42, t43, t44);
    }
    
    public function mulVector(v:Vec3D):Vec3D {
        return new Vec3D(e00 * v.x + e10 * v.y + e20 * v.z + e30,
                    e01 * v.x + e11 * v.y + e21 * v.z + e31,
                    e02 * v.x + e12 * v.y + e22 * v.z + e32,
                    e03 * v.x + e13 * v.y + e23 * v.z + e33);
    }
    
    public function mulEqualVector(v:Vec3D):void {
        v.setVector(e00 * v.x + e10 * v.y + e20 * v.z + e30,
                    e01 * v.x + e11 * v.y + e21 * v.z + e31,
                    e02 * v.x + e12 * v.y + e22 * v.z + e32,
                    e03 * v.x + e13 * v.y + e23 * v.z + e33);
    }
}