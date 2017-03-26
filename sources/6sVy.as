package {
    import flash.display.Sprite;
    [SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
    public class Main extends Sprite {
        public function Main() { main = this; initialize(); }
    }
}
import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.filters.BlurFilter;
var main:Main, bds:Vector.<BitmapData> = new Vector.<BitmapData>(4), bd:BitmapData;
var blurFilters:Vector.<BlurFilter> = new Vector.<BlurFilter>;
function initialize():void {
    for (var i:int = 0; i < bds.length; i++) {
        bds[i] = new BitmapData(Screen.WIDTH, Screen.HEIGHT);
        bds[i].fillRect(bds[i].rect, 0);
        main.addChild(new Bitmap(bds[i]));
        blurFilters[i] = new BlurFilter((i + 1) * 16, (i + 1) * 16);
    }
    bd = bds[bds.length - 1];
    camera = new Camera;
    for (i = 0; i < 500; i++) trees.push(new Tree);
    main.addEventListener(Event.ENTER_FRAME, update);
}
var zeroPoint:Point = new Point;
function update():void {
    for each (var bd:BitmapData in bds) bd.fillRect(bd.rect, 0);
    camera.update();
    for each (var t:Tree in trees) t.draw();
    for (var i:int = 0; i < bds.length - 1; i++) {
        bds[i].copyPixels(bd, bd.rect, zeroPoint);
        bds[i].applyFilter(bds[i], bd.rect, zeroPoint, blurFilters[i]);
    }
}
var trees:Vector.<Tree> = new Vector.<Tree>;
class Tree {
    private const FIELD_SIZE:Number = 50000;
    private static var isFirst:Boolean = true;
    private var ps:Vector.<Vector3D> = new Vector.<Vector3D>;
    private var cs:Vector.<int> = new Vector.<int>;
    private var lps:Vector.<Vector3D> = new Vector.<Vector3D>;
    private var pos:Vector3D = new Vector3D;
    public function Tree() {
        var h:Number = (rand() + rand() + rand() + 1) * 100;
        if (isFirst) {
            h = 3600;
            isFirst = false;
        }
        addLine(0, 0, 0, 0, -h, 0, 0xff8844);
        for (var i:int = 0; i < 3 + rand() * 3; i++) {
            var a:Number = rand() * Math.PI * 2;
            var hr1:Number = rand() * 0.4 + 0.5, hr2:Number = hr1 + rand() * 0.5 + 0.1;
            var wr:Number = rand() * 0.3 + 0.2;
            addLine(0, -h * hr1, 0, sin(a) * wr * h, -h * hr2, cos(a) * wr * h, 0xff8844);
        }
        for (i = 0; i < 10 + rand() * 10; i++) {
            var a1:Number = rand() * Math.PI * 2, a2:Number = a1 + rand() * 0.4 - 0.2;
            hr1 = rand() * 0.9 + 0.5; hr2 = hr1 + rand() * 0.8 - 0.4;
            var wr1:Number = rand() * 0.7, wr2:Number = rand() * 0.7;
            addLine(sin(a1) * wr1 * h, -h * hr1, cos(a1) * wr1 * h, sin(a1) * wr2 * h, -h * hr2, cos(a2) * wr2 * h, 0x88ff88);
        }
        pos.x = (rand() + rand()) * FIELD_SIZE / 2 - FIELD_SIZE / 2;
        pos.z = (rand() + rand()) * FIELD_SIZE / 2 - FIELD_SIZE / 2;
    }
    private function addLine(x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, z2:Number, c:int):void {
        ps.push(new Vector3D(x1, y1, z1));
        ps.push(new Vector3D(x2, y2, z2));
        cs.push(c);
        lps.push(new Vector3D);
        lps.push(new Vector3D);
    }
    public function draw():void {
        var x:Number = pos.x - camera.pos.x, z:Number = pos.z - camera.pos.z;
        x = (x + FIELD_SIZE / 2) % FIELD_SIZE;
        if (x < 0) x += FIELD_SIZE;
        x -= FIELD_SIZE / 2;
        z = (z + FIELD_SIZE / 2) % FIELD_SIZE;
        if (z < 0) z += FIELD_SIZE;
        z -= FIELD_SIZE / 2;
        var y:Number = -camera.pos.y;
        for (var i:int = 0; i < ps.length; i++) {
            var p:Vector3D = ps[i], lp:Vector3D = lps[i];
            lp.x = x + p.x;
            lp.y = y + p.y;
            lp.z = z + p.z;
            camera.quat.transform(lp);
        }
        if (lp.z < 0) return;
        var ci:int = 0;
        for (i = 0; i < lps.length; i += 2, ci++) BLine.draw3(lps[i], lps[i + 1], cs[ci]);
    }
}
var camera:Camera;
class Camera {
    private const SPEED:Number = 160;
    public var pos:Vector3D = new Vector3D(0, -100, 0);
    public var yaw:Number = 0, pitch:Number = 0, roll:Number = 0;
    public var quat:Quaternion = new Quaternion;
    private var rollv:Vector3D = new Vector3D(0, 0, 1);
    private var pitchq:Quaternion = new Quaternion, pitchv:Vector3D = new Vector3D(1, 0, 0);
    private var yawq:Quaternion = new Quaternion, yawv:Vector3D = new Vector3D(0, 1, 0);
    public function update():void {
        var mx:Number = main.stage.mouseX, my:Number = main.stage.mouseY;
        mx = (mx - Screen.CENTER_X) / 2000;
        yaw -= mx; roll -= mx; roll *= 0.9;
        my = (my - Screen.CENTER_Y) / 2000;
        pitch -= my; pitch *= 0.8;
        quat.set(rollv, roll);
        pitchq.set(pitchv, pitch);
        quat.mul(pitchq);
        yawq.set(yawv, yaw);
        quat.mul(yawq);
        pos.x -= sin(yaw) * SPEED; pos.z += cos(yaw) * SPEED;
    }
}
class BLine {
    private static var p:Vector3D = new Vector3D, v:Vector3D = new Vector3D;
    private static var rect:Rectangle = new Rectangle;
    public static function draw(p1:Vector3D, p2:Vector3D, sz:int, color:int, a:int):void {
        if (Screen.isIn(p1)) {
            p.x = p1.x; p.y = p1.y;
            v.x = p2.x - p1.x; v.y = p2.y - p1.y;
        } else {
            if (!Screen.isIn(p2)) return;
            p.x = p2.x; p.y = p2.y;
            v.x = p1.x - p2.x; v.y = p1.y - p2.y;
        }
        var avx:Number = Math.abs(v.x), avy:Number = Math.abs(v.y);
        var c:int;
        if (avx > avy) {
            c = avx; v.y /= c;
            if (v.x > 0) {
                v.x = 1;
                if (p.x + c > Screen.WIDTH) c = Screen.WIDTH - p.x;
            } else {
                v.x = -1;
                if (p.x - c < 0) c = p.x;
            }
        }
        else {
            c = avy;  v.x /= c;
            if (v.y > 0) {
                v.y = 1;
                if (p.y + c > Screen.HEIGHT) c = Screen.HEIGHT - p.y;
            } else {
                v.y = -1;
                if (p.y - c < 0) c = p.y;
            }
        }
        var lx:Number = p.x, ly:Number = p.y;
        var cl:int = color + 0x1000000 * a;
        if (sz > 1) {
            rect.width = rect.height = sz;
            var sz2:int = sz / 2;
            v.scaleBy(sz2);
            var vx:Number = v.x, vy:Number = v.y;
            for (var i:int = c; i > 0; i -= sz2) {
                rect.x = lx - sz2; rect.y = ly - sz2;
                bd.fillRect(rect, cl);
                lx += vx; ly += vy;
            }
        } else {
            vx = v.x; vy = v.y;
            for (i = c; i > 0; i--) {
                bd.setPixel32(lx, ly, cl);
                lx += vx; ly += vy;
            }
        }
    }
    private static var l1:Vector3D = new Vector3D, l2:Vector3D = new Vector3D;
    public static function draw3(p1:Vector3D, p2:Vector3D, c:int):void {
        l1.x = p1.x; l1.y = p1.y; l1.z = p1.z;
        l2.x = p2.x; l2.y = p2.y; l2.z = p2.z;
        if (l1.z < 1) {
            if (l2.z < 1) return;
            projToFront(l1, l2);
        } else {
            if (l2.z < 1) projToFront(l2, l1);
        }
        proj3(l1); proj3(l2);
        var pz:Number = Math.sqrt(p1.z + p2.z);
        if (pz < 1) pz = 1;
        var lsz:Number = 200 / pz; 
        if (lsz < 1) lsz = 1;
        var la:int = 30000 / pz;
        if (la < 0) return;
        else if (la > 0xff) la = 0xff;
        draw(l1, l2, lsz, c, la);
    }
    private static function projToFront(p1:Vector3D, p2:Vector3D):void {
        var zr:Number = (1 - p1.z) / (p2.z - p1.z);
        p1.x += (p2.x - p1.x) * zr;
        p1.y += (p2.y - p1.y) * zr;
        p1.z = 1;
    }
    private static function proj3(p:Vector3D):void {
        var zr:Number = 500 / p.z;
        p.x *= zr; p.y *= zr;
        p.x += Screen.CENTER_X; p.y += Screen.CENTER_Y;
    }
}
class Quaternion {
    public var x:Number, y:Number, z:Number, w:Number;
    public function set(v:Vector3D, angle:Number):void {
        w = Math.cos(angle / 2);
        var s:Number = Math.sin(angle / 2);
        x = v.x * s; y = v.y * s; z = v.z * s;
    }
    public function mul(v2:Quaternion):void {
        var v1x:Number = x, v1y:Number = y, v1z:Number = z, v1w:Number = w;
        w = v1w * v2.w - v1x * v2.x - v1y * v2.y - v1z * v2.z;
        x = v1y * v2.z - v1z * v2.y + v1w * v2.x + v1x * v2.w;
        y = v1z * v2.x - v1x * v2.z + v1w * v2.y + v1y * v2.w;
        z = v1x * v2.y - v1y * v2.x + v1w * v2.z + v1z * v2.w;
    }
    public function transform(v:Vector3D):void {
        var vw:Number = -x * v.x - y * v.y - z * v.z;
        var vx:Number = y * v.z - z * v.y + w * v.x;
        var vy:Number = z * v.x - x * v.z + w * v.y;
        var vz:Number = x * v.y - y * v.x + w * v.z;
        v.x = -vy * z + vz * y - vw * x + vx * w;
        v.y = -vz * x + vx * z - vw * y + vy * w;
        v.z = -vx * y + vy * x - vw * z + vz * w;
    }
}
class Screen {
    public static const WIDTH:int = 465, HEIGHT:int = 465;
    public static const CENTER_X:int = WIDTH / 2;
    public static const CENTER_Y:int = HEIGHT / 2;
    public static function isIn(p:Vector3D, spacing:Number = 0):Boolean {
        return (p.x >= -spacing && p.x <= WIDTH + spacing && 
            p.y >= -spacing && p.y <= HEIGHT + spacing);
    }
}
var rand:Function = Math.random, sin:Function = Math.sin, cos:Function = Math.cos;