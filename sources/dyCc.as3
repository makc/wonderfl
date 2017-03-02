package {
    /**
     * FlashDevelop.jp飲みのおみやげ
     * Twist クラスは zupko.info より拝借
     * 参考記事；　http://d.hatena.ne.jp/haru-komugi/20080614/1213377340
     */    
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.getTimer;

    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.LoadBitmapData;
    import jp.progression.data.getResourceById;

    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.core.math.*;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;

    [SWF(width=465, height=465, frameRate=60)]
    public class Main extends BasicView {
        private var cube:Cube;
        private var t:Twist;
        private var a:Number = 0;
        private var axis:Number3D  = new Number3D(0, 1, 0);
        private var center:Number3D = new Number3D(0, 0, 0);

        static private const CUBE_IMGAGE:String = "http://assets.wonderfl.net/images/related_images/d/d8/d8f8/d8f822b1b8df788aa95a7e4f047e91de375c4260m";
        static private const FLOOR_IMAGE:String = "http://assets.wonderfl.net/images/related_images/3/38/3804/3804f849e6f3ebca27627e5162db882e6eed7ac3m";

        public function Main() {
            opaqueBackground = 0x0;
            stage.quality = StageQuality.LOW;

            var c:LoaderContext = new LoaderContext(true);

            new SerialList(null,
                new LoadBitmapData(new URLRequest(CUBE_IMGAGE), {context: c}),
                new LoadBitmapData(new URLRequest(FLOOR_IMAGE), {context: c}),
                function():void {
                    var m:BitmapMaterial = new BitmapMaterial(getResourceById(CUBE_IMGAGE).data);
                    cube = new Cube(new MaterialsList({all: m}), 500, 500, 500, 8, 8, 8);
                    scene.addChild(cube);

                    var floor:Plane = new Plane(new BitmapMaterial(getResourceById(FLOOR_IMAGE).data), 2000, 2000, 4, 4);
                    floor.rotationX = 90;
                    floor.y = -500;
                    scene.addChild(floor);

                    t = new Twist(cube);;

                    startRendering();
                    addEventListener(Event.ENTER_FRAME, loop);
                }).execute();
        }

        private var rot:Number = 0;

        private function loop(e:Event):void {
            cube.yaw(2);
            t.twist(Math.sin(a += 0.05) * 80, axis, center);

            rot += (mouseX / stage.stageWidth * 3 * Math.PI - rot) * .1
            camera.x = Math.sin(rot) * 1500;
            camera.z = Math.cos(rot) * 1500;
            camera.y += (mouseY / stage.stageHeight * 3000 - 500 - camera.y) * .05;
            camera.fov = Math.sin(getTimer() / 750) * 30 + 60;
        }
    }
}

/**
 * Twist クラスは zupko.info より拝借
 * @see http://blog.zupko.info/?p=140
 */
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.objects.DisplayObject3D;

class Twist {
    public var target:DisplayObject3D;
    public var origins:Array;
    public var vector:Number3D = new Number3D(0, 0, 1);
    public var center:Number3D = new Number3D();

    private var tMat:Matrix3D;
    private var inverseTMat:Matrix3D;

    private var height:Number;
    private var width:Number;
    private var depth:Number;

    private var top:Number;

    private var pD:Number;

    public function Twist(target:DisplayObject3D) {
        this.target = target;
        origins = new Array();

        var minx:Number = 0;
        var maxx:Number = 0;
        var miny:Number = 0;
        var maxy:Number = 0;
        var minz:Number = 0;
        var maxz:Number = 0;

        for (var i:int = 0; i < target.geometry.vertices.length; i++) {
            var tmp:Vertex3D = target.geometry.vertices[i];
            origins[i] = {x: tmp.x, y: tmp.y, z: tmp.z};

            if (i == 0) {
                minx = maxx = tmp.x;
                miny = maxy = tmp.y;
                minz = maxz = tmp.z;
            } else {
                minx = minx > tmp.x ? tmp.x : minx;
                maxx = maxx < tmp.x ? tmp.x : maxx;

                miny = miny > tmp.y ? tmp.y : miny;
                maxy = maxy < tmp.y ? tmp.y : maxy;

                minz = minz > tmp.z ? tmp.z : minz;
                maxz = maxz < tmp.z ? tmp.z : maxz;
            }
        }

        height = maxy - miny;
        width = maxx - minx;
        depth = maxz - minz;

    }

    public function twist(degrees:Number, axis:Number3D, center:Number3D):void {
        this.vector = axis;
        this.center = center;

        this.vector.normalize();

        pD = -Number3D.dot(this.vector, this.center);

        var rads:Number = degrees * Math.PI / 180;

        tMat = new Matrix3D();
        tMat.n14 = -center.x;
        tMat.n24 = -center.y;
        tMat.n34 = -center.z;

        inverseTMat = Matrix3D.inverse(tMat);

        //calculate some distances....
        var maxD:Number = height;
        var dx:Number = center.x - target.x;
        var dy:Number = center.y - target.y;
        var dz:Number = center.z - target.z;

        dx += dx < 0 ? -width / 2 : width / 2;
        dy += dy < 0 ? -height / 2 : height / 2;
        dy += dz < 0 ? -depth / 2 : depth / 2;

        maxD = Math.sqrt(dx * dx + dy * dy + dz * dz);

        var d:Number = -Number3D.dot(vector, center);

        var endPoint1:Number3D;
        var endPoint2:Number3D;
        var h2:Number = Math.max(height, width, depth);

        for (var i:int = 0; i < target.geometry.vertices.length; i++) {

            resetIndex(i);
            var tmp:Vertex3D = target.geometry.vertices[i];

            var dd:Number = Number3D.dot(tmp.toNumber3D(), vector) + d;

            twistPoint(tmp, (dd / maxD) * rads);
        }
    }

    private function resetIndex(index:Number):void {
        var tmp:Vertex3D = target.geometry.vertices[index];
        tmp.x = origins[index].x;
        tmp.y = origins[index].y;
        tmp.z = origins[index].z;
    }

    private function twistPoint(v:Vertex3D, angle:Number):void {
        var mat:Matrix3D = Matrix3D.translationMatrix(v.x, v.y, v.z);

        mat = Matrix3D.multiply(tMat, mat);
        mat = Matrix3D.multiply(Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle), mat);
        mat = Matrix3D.multiply(inverseTMat, mat);

        v.x = mat.n14;
        v.y = mat.n24;
        v.z = mat.n34;
    }
}
