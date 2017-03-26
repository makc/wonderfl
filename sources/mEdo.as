// forked from keim_at_Si's Clear Water with refraction rendering forked from: 3D水面 / Water 3D
// forked from saharan's 3D水面 / Water 3D
package {
	import alternativ7.engine3d.core.Object3DContainer;
	import alternativ7.engine3d.core.RayIntersectionData;
	import alternativ7.engine3d.core.View;
	import alternativ7.engine3d.materials.TextureMaterial;
	import alternativ7.engine3d.objects.Mesh;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
    import flash.system.LoaderContext;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import com.bit101.components.*;
    //import net.hires.debug.*;

    [SWF(frameRate = "30", width="465", height="465")]

    /**
     * Water 3D
     *
     * ・解説コメントをちょっと入れました
     * 
     * Click&Drag:Make wave
     * 
     * @author saharan
     */
    public class main extends Sprite {
        private const NUM_DETAILS:int = 48;
        private const INV_NUM_DETAILS:Number = 1 / NUM_DETAILS;
        private const MESH_SIZE:Number = 100;
        private var count:uint;
        private var bmd:BitmapData, bmd2:BitmapData;
        private var loader:Loader, loader2:Loader, loader3:Loader;
        private var vertices:Vector.<Vertex>;
        private var transformedVertices:Vector.<Number>;
        private var indices:Vector.<int>;
        private var uvt:Vector.<Number>, uvt2:Vector.<Number>;
        private var width2:Number;
        private var height2:Number;
        private var heights:Vector.<Vector.<Number>>;
        private var velocity:Vector.<Vector.<Number>>;
        private var press:Boolean;
        
        private var viewedAngle:Number = -65;
        private var focalLength:Number = 4 * MESH_SIZE;
        private var boxHeight:Number = MESH_SIZE * 0.75;
        private var refractiveIndex:Number = 1.4;
        private var reflectionLayer:Shape;
        private var refractionLayer:Shape;
		private var duckLayer:View;
		private var camera:BetterCamera3D;
		private var cameraDistance:Number = 1.02 * MESH_SIZE;
		private var duck:Mesh, plane:Mesh;
		private var duckNode:Object3DContainer;
        
        public function main():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = StageQuality.LOW;
            width2 = 465 / 2;
            height2 = 465 / 2;
            // var s:Stats = new Stats();
            // s.alpha = 0.8;
            // addChild(s);
            count = 0;
            loader = new Loader();
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/b2/b217/b2177f87d979a28b9bcbb6e0b89370e77ce22337"), new LoaderContext(true));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
            loader2 = new Loader();
            loader2.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/bb/bbf1/bbf12c60cf84e5ab43e059920783d036da25df48"), new LoaderContext(true));
            loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
            loader3 = new Loader();
            loader3.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/ba/ba56/ba5643ab1dcece8b8f4eef06b44deedb31d6803c"), new LoaderContext(true));
            loader3.contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,
                function(e:Event = null):void {
                    drag();
                    press = true;
                });
            stage.addEventListener(MouseEvent.MOUSE_UP,
                function(e:Event = null):void {
                    press = false;
                });
            stage.addEventListener(MouseEvent.MOUSE_MOVE,
                function(e:Event = null):void {
                    if (press) drag();
                });
            vertices = new Vector.<Vertex>(NUM_DETAILS * NUM_DETAILS, true);
            transformedVertices = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            indices = new Vector.<int>();
            uvt = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            uvt2 = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            var i:int;
            var j:int;
            // 頂点初期化。外側2つ分は表示しないので無駄な処理＆メモリに・・・
            // 【modification】 nx, ny と整合性を取るために x-z 平面 ⇒ x-y 平面 に修正
            for (i = 2; i < NUM_DETAILS - 2; i++) {
                for (j = 2; j < NUM_DETAILS - 2; j++) {
                    vertices[getIndex(j, i)] = new Vertex(
                        (j - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE,
                        (i - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE, 0);
                    if (i != 2 && j != 2) {
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j - 1), getIndex(i, j));
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j), getIndex(i - 1, j));
                    }
                }
            }
            // 水面関係初期化
            heights = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            velocity = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            for (i = 0; i < NUM_DETAILS; i++) {
                heights[i] = new Vector.<Number>(NUM_DETAILS, true);
                velocity[i] = new Vector.<Number>(NUM_DETAILS, true);
                for (j = 0; j < NUM_DETAILS; j++) {
                    heights[i][j] = 0;
                    velocity[i][j] = 0;
                }
            }
            

			// I will not be writing my own engine for this code, sorry :(
			camera = new BetterCamera3D;
			camera.view = new View (465, 465);
			camera.view.hideLogo ();
			camera.f = focalLength;
			var dc:DuckContainer = new DuckContainer;
			dc.addChild (camera);
			dc.addChild (plane = dc.plane);
			dc.addChild (duckNode = new Object3DContainer);
			duckNode.addChild (duck = dc.duck);
			duck.rotationX = Math.PI;
			duck.scaleX = 0.5;
			duck.scaleY = 0.5;
			duck.scaleZ = 0.5;


            // 【modification】Rendering layers
            addChild(refractionLayer = new Shape());
            addChild(reflectionLayer = new Shape());
            reflectionLayer.alpha = 0.7;
            addChild(camera.view);
            // 【modification】controlers
            new HUISlider(this, 0, 0, "Angle", function(e:Event):void { viewedAngle = -e.target.value;syncAlternativa();}).setSliderParams(0, 89, 65);
            new HUISlider(this, 0, 20, "Refraction", function(e:Event):void { refractiveIndex = e.target.value;}).setSliderParams(1, 3, 1.4);
            new HUISlider(this, 0, 40, "Reflection", function(e:Event):void { reflectionLayer.alpha = e.target.value;}).setSliderParams(0, 1, 0.7);

			syncAlternativa ();
		}
        
        private function loaded(e:Event) : void {
            e.target.removeEventListener(e.type, arguments.callee);
            if (loader.content && loader2.content && loader3.content) {
                bmd  = Bitmap(loader.content).bitmapData;
                bmd2 = Bitmap(loader2.content).bitmapData;
                duck.setMaterialToAllFaces (new TextureMaterial (Bitmap(loader3.content).bitmapData));
                addEventListener(Event.ENTER_FRAME, frame);
            }
        }

        private function frame(e:Event = null):void {
            count++;
            move();
            setMesh();
            transformVertices();
            draw();
            drawDuck();
        }

        private function setMesh():void {
            // calclate constants
            var angle:Number = viewedAngle * 0.017453292519943295, 
                sin:Number = Math.sin(angle), 
                cos:Number = Math.cos(angle), 
                eyex:Number = 0, 
                eyey:Number = -sin * cameraDistance, 
                eyez:Number = -cos * cameraDistance,
                rimo:Number = refractiveIndex - 1,
                xymax:Number = MESH_SIZE * .45, //MESH_SIZE * 0.5,
                ixymax:Number = 1 / xymax;
            
            for (var i:int = 2; i < NUM_DETAILS - 2; i++) {
                for (var j:int = 2; j < NUM_DETAILS - 2; j++) {
                    const index:int = getIndex(i, j);
                    var v:Vertex = vertices[index];
                    v.z = heights[i][j] * 0.15;
                    
                    // ---Sphere map---
                    var nx:Number, ny:Number, nz:Number;
                    nx = (heights[i][j] - heights[i - 1][j]) * 0.15;
                    ny = (heights[i][j] - heights[i][j - 1]) * 0.15;
                    var len:Number = 1 / Math.sqrt(nx * nx + ny * ny + 1);
                    nx *= len;
                    ny *= len;
                    nz = len;
                    var tny:Number = cos * ny - sin * nz;
					// it's all hacks
					tny *= -1;
					tny += 0.4 * tny * tny;
					tny += 0.3;
                    uvt[index * 2] = tny * 0.5 + 0.5 + ((j - NUM_DETAILS * 0.5) * INV_NUM_DETAILS * 0.25);
                    uvt[index * 2 + 1] = nx * 0.5 + 0.5 + ((NUM_DETAILS * 0.5 - i) * INV_NUM_DETAILS * 0.25);
                    
                    // 【modification】 屈折マップ
                    
                    // ---Refraction map---
                    // incident vector (you can calculate them in the setup if you want faster)
                    var dx:Number = v.x - eyex, dy:Number = v.y - eyey, dz:Number = v.z - eyez;
                    len = 1 / Math.sqrt(dx * dx + dy * dy + dz * dz);
                    dx *= len;
                    dy *= len;
                    dz *= len;
                    // output vector
                    t = (dx * nx + dy * ny + dz) * rimo;
                    dx += nx * t;
                    dy += ny * t;
                    dz += nz * t;
                    // in this calculation, we can omit normalization of output vector !
                    //len = 1 / Math.sqrt(dx * dx + dy * dy + dz * dz);
                    //dx *= len;
                    //dy *= len;
                    //dz *= len;
                    // uv coordinate
                    var t:Number, s:Number, r:Number, hitz:Number, sign:Number;
                    if (dx == 0) {
                        if (dy == 0) {
                            uvt2[index * 2] = uvt2[index * 2 + 1] = 0.5;
                            sign = 0;
                        } else sign = (dy < 0) ? -1 : 1;
                    } else {
                        sign = (dx < 0) ? -1 : 1;
                        t = (sign * xymax - v.x) / dx;
                        s = t * dy + v.y;
                        if (-xymax < s && s < xymax) {
                            hitz = t * dz + v.z;
                            if (hitz > boxHeight) {
                                r = (boxHeight-v.z) / dz;
                                uvt2[index * 2]     = (dx * r + v.x) * ixymax * 0.25 + 0.5;
                                uvt2[index * 2 + 1] = (dy * r + v.y) * ixymax * 0.25 + 0.5;
                            } else {
                                r = boxHeight / (hitz + boxHeight);
                                uvt2[index * 2]     = sign       * r * 0.5 + 0.5;
                                uvt2[index * 2 + 1] = s * ixymax * r * 0.5 + 0.5;
                            }
                            sign = 0;
                        } else sign = (s < 0) ? -1 : 1;
                    }
                    if (sign != 0) {
                        t = (sign * xymax - v.y) / dy;
                        s = t * dx + v.x;
                        hitz = t * dz + v.z;
                        if (hitz > boxHeight) {
                            r = (boxHeight-v.z) / dz;
                            uvt2[index * 2]     = (dx * r + v.x) * ixymax * 0.25 + 0.5;
                            uvt2[index * 2 + 1] = (dy * r + v.y) * ixymax * 0.25 + 0.5;
                        } else {
                            r = boxHeight / (hitz + boxHeight);
                            uvt2[index * 2]     = s * ixymax * r * 0.5 + 0.5;
                            uvt2[index * 2 + 1] = sign       * r * 0.5 + 0.5;
                        }
                    }
                    //trace(v.x,v.y,dx,dy,uvt2[index * 2],uvt2[index * 2+1]);
                }
            }
            //throw new Error("STOPPER!!");
        }

        public function move():void {
            
            // ---Water simulation---
            
            var i:int;
            var j:int;
            var mx:Number = mouseX / 465 * NUM_DETAILS;
            var my:Number = (1 - mouseY / 465) * NUM_DETAILS;
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    heights[i][j] += velocity[i][j];
                    if (heights[i][j] > 100) heights[i][j] = 100;
                    else if (heights[i][j] < -100) heights[i][j] = -100;
                }
            }
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    velocity[i][j] = (velocity[i][j] +
                        (heights[i - 1][j] + heights[i][j - 1] + heights[i + 1][j] +
                        heights[i][j + 1] - heights[i][j] * 4) * 0.5) * 0.95;
                }
            }
        }

        public function drag():void {
            var i:int;
            var j:int;
			// do fucking ray-plane intersection, dammit!
			var o:Vector3D = new Vector3D (camera.x, camera.y, camera.z);
			var d:Vector3D = o.clone ();
			d.normalize (); d.scaleBy ( -1);
			var n:Vector3D = d.clone ();
			n.y = - d.z; n.z = d.y;
			d.scaleBy (focalLength);
			n.scaleBy (232.5 - mouseY);
			d.incrementBy (n);
			d.x += mouseX - 232.5;
			var data:RayIntersectionData = plane.intersectRay (o, d);
			if (data == null) return;
			//duck.x = data.point.x;
			//duck.y = data.point.y;
            var mx:int = NUM_DETAILS * (data.point.x + 0.5 * MESH_SIZE) / MESH_SIZE;
            var my:int = NUM_DETAILS * (data.point.y + 0.5 * MESH_SIZE) / MESH_SIZE;
            for (i = mx - 3; i < NUM_DETAILS - 1 && mx + 3; i++) {
                for (j = my - 3; j < NUM_DETAILS - 1 && my + 3; j++) {
                    if (i > 1 && j > 1 && i < NUM_DETAILS - 1 && j < NUM_DETAILS - 1) {
                        var len:Number = 3 - Math.sqrt((mx - i) * (mx - i) + (my - j) * (my - j));
                        if (len < 0) len = 0;
                        velocity[i][j] -= len * (press ? 1 : 5);
                    }
                }
            }
        }

        private function draw():void {
            var refractionGraphics:Graphics = refractionLayer.graphics,
                reflectionGraphics:Graphics = reflectionLayer.graphics;
            graphics.clear();
            graphics.beginFill(0x202020);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            // 【modification】 屈折マップ
            refractionGraphics.clear();
            refractionGraphics.beginBitmapFill(bmd2);
            refractionGraphics.drawTriangles(transformedVertices, indices, uvt2, TriangleCulling.NEGATIVE);
            refractionGraphics.endFill();
            reflectionGraphics.clear();
            reflectionGraphics.beginBitmapFill(bmd);
            reflectionGraphics.drawTriangles(transformedVertices, indices, uvt, TriangleCulling.NEGATIVE);
            reflectionGraphics.endFill();
        }

        private function getIndex(x:int, y:int):int {
            return y * NUM_DETAILS + x;
        }

        private function transformVertices():void {
            
            // x軸回転とビュー変換・プロジェクション変換を実行
            
            var angle:Number = viewedAngle * Math.PI / 180;
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);
            for (var i:int = 0; i < vertices.length; i++) {
                var v:Vertex = vertices[i];
                if(v != null) {
                    var x:Number = v.x;
                    // x軸回転行列もどき
                    var y:Number = cos * v.y - sin * v.z;
                    var z:Number = sin * v.y + cos * v.z;
                    // wtf, people, why can't we have
					// normal pinhole projection here
                    z = focalLength / (z + cameraDistance);
                    x = x * z + 232.5;
                    y = y * z + 232.5;
                    transformedVertices[i * 2] = x;
                    transformedVertices[i * 2 + 1] = y;
                }
            }
        }

		private function syncAlternativa ():void {
			var a:Number = viewedAngle * Math.PI / 180;
			camera.rotationX = -a;
			camera.y = -Math.sin (a) * cameraDistance;
			camera.z = -Math.cos (a) * cameraDistance;
		}

		private var duckVelocityX:Number = 0;
		private var duckVelocityY:Number = 0;
		private var duckSpin:Number = 0;

		private function drawDuck ():void {
			var duckX:Number = duckNode.x;
			var duckY:Number = duckNode.y;
            var i:int = NUM_DETAILS * (duckX + 0.5 * MESH_SIZE) / MESH_SIZE;
            var j:int = NUM_DETAILS * (duckY + 0.5 * MESH_SIZE) / MESH_SIZE;
			i = Math.min (NUM_DETAILS - 2, Math.max (1, i));
			j = Math.min (NUM_DETAILS - 2, Math.max (1, j));
			var duckZ:Number = heights[i][j] * 0.15;

			// water normal (idea stolen from reflection code,
			// so I'm not even sure this is correct formula :)
			var n:Vector3D = new Vector3D (
				(heights[i + 1][j] - heights[i - 1][j]) * 0.075,
				(heights[i][j + 1] - heights[i][j - 1]) * 0.075,
				1
			); n.normalize ();

			// duck tilt matrix corresponding to this normal
			var m:Matrix3D = new Matrix3D;
			var r:Vector3D = n.crossProduct (Vector3D.Z_AXIS);
			if (r.length > 0.00001) {
				r.normalize ();
				m.prependRotation (
					Math.acos (n.dotProduct (Vector3D.Z_AXIS)) * 180 / Math.PI,
					r
				);
			}

			duckNode.matrix = m;

			duckNode.x = duckX + duckVelocityX;
			duckNode.y = duckY + duckVelocityY;
			duckNode.z = duckZ;

			duck.rotationZ +=  duckSpin;

			camera.render ();

			// drift
			duckVelocityX += 0.05 * n.x;
			duckVelocityY += 0.05 * n.y;

			// bounce
			if (((i == 1) && (duckVelocityX < 0)) || ((i == NUM_DETAILS - 2) && (duckVelocityX > 0))) duckVelocityX *= -1;
			if (((j == 1) && (duckVelocityY < 0)) || ((j == NUM_DETAILS - 2) && (duckVelocityY > 0))) duckVelocityY *= -1;

			// spin... I actually have no fucking idea how to calculate it correctly :(
			duckSpin += 0.015 * (velocity [i + 1][j + 1] - velocity [i][j] + velocity [i + 1][j] - velocity [i][j + 1]);
			duckSpin *= 0.999;
		}
    }
}

class Vertex {
    public var x:Number;
    public var y:Number;
    public var z:Number;

    public function Vertex(x:Number, y:Number,z:Number) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}


import alternativ7.engine3d.alternativa3d;
import alternativ7.engine3d.core.Camera3D;
/** How hard is it to make focalLength a property? */
class BetterCamera3D extends Camera3D {
	public function get f ():Number {
		if (view != null) {
			alternativa3d::viewSizeX = view.alternativa3d::_width * 0.5;
			alternativa3d::viewSizeY = view.alternativa3d::_height * 0.5;
			alternativa3d::focalLength = Math.sqrt (
				((alternativa3d::viewSizeX * alternativa3d::viewSizeX) +
				 (alternativa3d::viewSizeY * alternativa3d::viewSizeY))
			) / Math.tan (fov * 0.5);
		}
		return alternativa3d::focalLength;
	}
	public function set f (v:Number):void {
		if ((view != null) && (v > 0)) {
			alternativa3d::viewSizeX = view.alternativa3d::_width * 0.5;
			alternativa3d::viewSizeY = view.alternativa3d::_height * 0.5;
			fov = 2 * Math.atan2 (Math.sqrt (
				((alternativa3d::viewSizeX * alternativa3d::viewSizeX) +
				 (alternativa3d::viewSizeY * alternativa3d::viewSizeY))
			), v);
		}
	}
}

import alternativ7.engine3d.core.Object3DContainer;
import alternativ7.engine3d.loaders.Parser3DS;
import alternativ7.engine3d.materials.FillMaterial;
import alternativ7.engine3d.objects.Mesh;
import alternativ7.engine3d.primitives.Plane;
import flash.utils.ByteArray;
class DuckContainer extends Object3DContainer {
	public var duck:Mesh;
	public var plane:Plane;
	public function DuckContainer () {
		super ();

		plane = new Plane (90, 90);
		plane.setMaterialToAllFaces (new FillMaterial (0, 0, 1, 0xFFFF00));

		var parser:Parser3DS = new Parser3DS;
		parser.parse (new Base64 (duck64.toString ()));
		duck = Mesh (parser.objects [0]);
	}
	private var duck64:XML = <duck>
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
Ps+/RT9GJNI+6KJBP9yDHD/Pv0U/RiTSPu+pVD/2YSk/5KNhPzJWkz64kF8/RfQnP++pVD/2YSk/
5KNhPzJWkz7vqVQ/9mEpP6OVVz/Sx5Q+o5VXP9LHlD7vqVQ/9mEpP8+/RT9GJNI+z79FP0Yk0j6Y
/D8/UAxJPqOVVz/Sx5Q+OXtDPxgFAT6Y/D8/UAxJPulJJT/gnfU97gV2PjCl/j6fW5g+utu9PvGc
tT6lvgA/8Zy1PqW+AD+fW5g+utu9Pk0V/D5EGqU+TRX8PkQapT4e//U+hXoKP/GctT6lvgA/7gV2
PjCl/j7VXJ4+oPwRPyPzkD5aRxU/1VyePqD8ET+srJ0+Lo4ePyPzkD5aRxU/2DJJPldBKD8M5h8+
QE4wP4iPyD2ZKA4/gOxFPmXFQD8M5h8+QE4wP9gyST5XQSg/xLRvPnB6Rz+A7EU+ZcVAP9gyST5X
QSg/2DJJPldBKD+Ij8g9mSgOP9odcj5eESQ/2DJJPldBKD/aHXI+XhEkP8S0bz5wekc/7gV2PjCl
/j7xnLU+pb4AP9Vcnj6g/BE/Y0fbPvkTbT8qGZA+QL5cP6pgvD6vPk4/5kAPPwskWD9jR9s++RNt
Pxv26z5tyU4/dm0TPw6fMD/mQA8/CyRYP1rVAj+95T4/K/wFP3B7Dj92bRM/Dp8wP4LGBD8Ulx8/
IoqBPsLDTD+srJ0+Lo4eP/rxpz4tYDo/KhmQPkC+XD8iioE+wsNMP/rxpz4tYDo/vf/fPjgwET/x
nLU+pb4APx7/9T6Fego/+vGnPi1gOj+qYLw+rz5OPyoZkD5Avlw/Y0fbPvkTbT+qYLw+rz5OPxv2
6z5tyU4/5kAPPwskWD8b9us+bclOP1rVAj+95T4/dm0TPw6fMD9a1QI/veU+P4LGBD8Ulx8/gsYE
PxSXHz8e//U+hXoKPyv8BT9wew4/Hv/1PoV6Cj+CxgQ/FJcfP73/3z44MBE/rKydPi6OHj/VXJ4+
oPwRP/GctT6lvgA/00zfPtJvKz/68ac+LWA6P6ysnT4ujh4/qmC8Pq8+Tj/68ac+LWA6P9NM3z7S
bys/00zfPtJvKz8b9us+bclOP6pgvD6vPk4/00zfPtJvKz9a1QI/veU+Pxv26z5tyU4/00zfPtJv
Kz+CxgQ/FJcfP1rVAj+95T4/00zfPtJvKz+9/98+ODARP4LGBD8Ulx8/rKydPi6OHj+9/98+ODAR
P9NM3z7Sbys/vf/fPjgwET+srJ0+Lo4eP/GctT6lvgA/o5VXP9LHlD6Y/D8/UAxJPjl7Qz8YBQE+
o5VXP9LHlD45e0M/GAUBPuSjYT8yVpM+MbR+PwBkrjvko2E/MlaTPjl7Qz8YBQE+MbR+PwBkrjs5
e0M/GAUBPmsMFj9YZoo9awwWP1hmij3F/8U+YMKIPT9zvj4AYac7P3O+PgBhpzsxtH4/AGSuO2sM
Fj9YZoo9mPw/P1AMST7pSSU/4J31PX6PLj9oNk8+YK0KP8DWNT7pSSU/4J31PYgs+j5g5/89YK0K
P8DWNT6ILPo+YOf/PS+L4T64hmk+6UklP+Cd9T1grQo/wNY1Pn6PLj9oNk8+TRX8PkQapT5u3Rk/
xhiwPqm8BT8a+JE+qbwFPxr4kT4vi+E+uIZpPk0V/D5EGqU+L4vhPriGaT6pvAU/GviRPmCtCj/A
1jU+O3MzPyamqz6pvAU/GviRPm7dGT/GGLA+bt0ZP8YYsD7Pv0U/RiTSPjtzMz8mpqs+z79FP0Yk
0j6Y/D8/UAxJPjtzMz8mpqs+O3MzPyamqz5grQo/wNY1Pqm8BT8a+JE+fo8uP2g2Tz47czM/Jqar
Ppj8Pz9QDEk+YK0KP8DWNT47czM/JqarPn6PLj9oNk8+pPVXPtArbj6gSUI+NA/APl9+hz6MQlI+
X36HPoxCUj6gSUI+NA/APp9bmD66270+P3O+PgBhpzuk9Vc+0CtuPl9+hz6MQlI+X36HPoxCUj7F
/8U+YMKIPT9zvj4AYac7iCz6PmDn/z1rDBY/WGaKPcX/xT5gwog9awwWP1hmij2ILPo+YOf/PelJ
JT/gnfU9OXtDPxgFAT5rDBY/WGaKPelJJT/gnfU9xf/FPmDCiD0vi+E+uIZpPogs+j5g5/89X36H
PoxCUj4vi+E+uIZpPsX/xT5gwog97gV2PjCl/j6fW5g+utu9PqBJQj40D8A+L4vhPriGaT5ffoc+
jEJSPp9bmD66270+TRX8PkQapT4vi+E+uIZpPp9bmD66270+K/wFP3B7Dj9NFfw+RBqlPh7/9T6F
ego/bt0ZP8YYsD5NFfw+RBqlPiv8BT9wew4/bt0ZP8YYsD4r/AU/cHsOP+iiQT/cgxw/76lUP/Zh
KT/hDE4/dcg1P7iQXz9F9Cc/76lUP/ZhKT/ookE/3IMcP+EMTj91yDU/z79FP0Yk0j5u3Rk/xhiw
PuiiQT/cgxw/76lUP/ZhKT/Pv0U/RiTSPuiiQT/cgxw/76lUP/ZhKT+4kF8/RfQnP+SjYT8yVpM+
o5VXP9LHlD7vqVQ/9mEpP+SjYT8yVpM+z79FP0Yk0j7vqVQ/9mEpP6OVVz/Sx5Q+o5VXP9LHlD6Y
/D8/UAxJPs+/RT9GJNI+6UklP+Cd9T2Y/D8/UAxJPjl7Qz8YBQE+8Zy1PqW+AD+fW5g+utu9Pu4F
dj4wpf4+TRX8PkQapT6fW5g+utu9PvGctT6lvgA/8Zy1PqW+AD8e//U+hXoKP00V/D5EGqU+I/OQ
PlpHFT/VXJ4+oPwRP+4Fdj4wpf4+I/OQPlpHFT+srJ0+Lo4eP9Vcnj6g/BE/iI/IPZkoDj8M5h8+
QE4wP9gyST5XQSg/2DJJPldBKD8M5h8+QE4wP4DsRT5lxUA/2DJJPldBKD+A7EU+ZcVAP8S0bz5w
ekc/2h1yPl4RJD+Ij8g9mSgOP9gyST5XQSg/xLRvPnB6Rz/aHXI+XhEkP9gyST5XQSg/1VyePqD8
ET/xnLU+pb4AP+4Fdj4wpf4+qmC8Pq8+Tj8qGZA+QL5cP2NH2z75E20/G/brPm3JTj9jR9s++RNt
P+ZADz8LJFg/WtUCP73lPj/mQA8/CyRYP3ZtEz8OnzA/gsYEPxSXHz92bRM/Dp8wPyv8BT9wew4/
+vGnPi1gOj+srJ0+Lo4ePyKKgT7Cw0w/+vGnPi1gOj8iioE+wsNMPyoZkD5Avlw/Hv/1PoV6Cj/x
nLU+pb4AP73/3z44MBE/KhmQPkC+XD+qYLw+rz5OP/rxpz4tYDo/G/brPm3JTj+qYLw+rz5OP2NH
2z75E20/WtUCP73lPj8b9us+bclOP+ZADz8LJFg/gsYEPxSXHz9a1QI/veU+P3ZtEz8OnzA/K/wF
P3B7Dj8e//U+hXoKP4LGBD8Ulx8/vf/fPjgwET+CxgQ/FJcfPx7/9T6Fego/8Zy1PqW+AD/VXJ4+
oPwRP6ysnT4ujh4/rKydPi6OHj/68ac+LWA6P9NM3z7Sbys/00zfPtJvKz/68ac+LWA6P6pgvD6v
Pk4/qmC8Pq8+Tj8b9us+bclOP9NM3z7Sbys/G/brPm3JTj9a1QI/veU+P9NM3z7Sbys/WtUCP73l
Pj+CxgQ/FJcfP9NM3z7Sbys/gsYEPxSXHz+9/98+ODARP9NM3z7Sbys/00zfPtJvKz+9/98+ODAR
P6ysnT4ujh4/8Zy1PqW+AD+srJ0+Lo4eP73/3z44MBE/OXtDPxgFAT6Y/D8/UAxJPqOVVz/Sx5Q+
5KNhPzJWkz45e0M/GAUBPqOVVz/Sx5Q+OXtDPxgFAT7ko2E/MlaTPjG0fj8AZK47awwWP1hmij05
e0M/GAUBPjG0fj8AZK47P3O+PgBhpzvF/8U+YMKIPWsMFj9YZoo9awwWP1hmij0xtH4/AGSuOz9z
vj4AYac7IEEHBgAAmAAAAAEAAgAGAAMABAAFAAYABgAHAAgABgAJAAoACwAGAAwADQAOAAYADwAQ
ABEABgASABMAFAAGABUAFgAXAAYAGAAZABoABgAbABwAHQAGAB4AHwAgAAYAIQAiACMABgAkACUA
JgAGACcAKAApAAYAKgArACwABgAtAC4ALwAGADAAMQAyAAYAMwA0ADUABgA2ADcAOAAGADkAOgA7
AAYAPAA9AD4ABgA/AEAAQQAGAEIAQwBEAAYARQBGAEcABgBIAEkASgAGAEsATABNAAYATgBPAFAA
BgBRAFIAUwAGAFQAVQBWAAYAVwBYAFkABgBaAFsAXAAGAF0AXgBfAAYAYABhAGIABgBjAGQAZQAG
AGYAZwBoAAYAaQBqAGsABgBsAG0AbgAGAG8AcABxAAYAcgBzAHQABgB1AHYAdwAGAHgAeQB6AAYA
ewB8AH0ABgB+AH8AgAAGAIEAggCDAAYAhACFAIYABgCHAIgAiQAGAIoAiwCMAAYAjQCOAI8ABgCQ
AJEAkgAGAJMAlACVAAYAlgCXAJgABgCZAJoAmwAGAJwAnQCeAAYAnwCgAKEABgCiAKMApAAGAKUA
pgCnAAYAqACpAKoABgCrAKwArQAGAK4ArwCwAAYAsQCyALMABgC0ALUAtgAGALcAuAC5AAYAugC7
ALwABgC9AL4AvwAGAMAAwQDCAAYAwwDEAMUABgDGAMcAyAAGAMkAygDLAAYAzADNAM4ABgDPANAA
0QAGANIA0wDUAAYA1QDWANcABgDYANkA2gAGANsA3ADdAAYA3gDfAOAABgDhAOIA4wAGAOQA5QDm
AAYA5wDoAOkABgDqAOsA7AAGAO0A7gDvAAYA8ADxAPIABgDzAPQA9QAGAPYA9wD4AAYA+QD6APsA
BgD8AP0A/gAGAP8AAAEBAQYAAgEDAQQBBgAFAQYBBwEGAAgBCQEKAQYACwEMAQ0BBgAOAQ8BEAEG
ABEBEgETAQYAFAEVARYBBgAXARgBGQEGABoBGwEcAQYAHQEeAR8BBgAgASEBIgEGACMBJAElAQYA
JgEnASgBBgApASoBKwEGACwBLQEuAQYALwEwATEBBgAyATMBNAEGADUBNgE3AQYAOAE5AToBBgA7
ATwBPQEGAD4BPwFAAQYAQQFCAUMBBgBEAUUBRgEGAEcBSAFJAQYASgFLAUwBBgBNAU4BTwEGAFAB
UQFSAQYAUwFUAVUBBgBWAVcBWAEGAFkBWgFbAQYAXAFdAV4BBgBfAWABYQEGAGIBYwFkAQYAZQFm
AWcBBgBoAWkBagEGAGsBbAFtAQYAbgFvAXABBgBxAXIBcwEGAHQBdQF2AQYAdwF4AXkBBgB6AXsB
fAEGAH0BfgF/AQYAgAGBAYIBBgCDAYQBhQEGAIYBhwGIAQYAiQGKAYsBBgCMAY0BjgEGAI8BkAGR
AQYAkgGTAZQBBgCVAZYBlwEGAJgBmQGaAQYAmwGcAZ0BBgCeAZ8BoAEGAKEBogGjAQYApAGlAaYB
BgCnAagBqQEGAKoBqwGsAQYArQGuAa8BBgCwAbEBsgEGALMBtAG1AQYAtgG3AbgBBgC5AboBuwEG
ALwBvQG+AQYAvwHAAcEBBgDCAcMBxAEGAMUBxgHHAQYAMEE/AQAAcnViYmVyAJgAAAABAAIAAwAE
AAUABgAHAAgACQAKAAsADAANAA4ADwAQABEAEgATABQAFQAWABcAGAAZABoAGwAcAB0AHgAfACAA
IQAiACMAJAAlACYAJwAoACkAKgArACwALQAuAC8AMAAxADIAMwA0ADUANgA3ADgAOQA6ADsAPAA9
AD4APwBAAEEAQgBDAEQARQBGAEcASABJAEoASwBMAE0ATgBPAFAAUQBSAFMAVABVAFYAVwBYAFkA
WgBbAFwAXQBeAF8AYABhAGIAYwBkAGUAZgBnAGgAaQBqAGsAbABtAG4AbwBwAHEAcgBzAHQAdQB2
AHcAeAB5AHoAewB8AH0AfgB/AIAAgQCCAIMAhACFAIYAhwCIAIkAigCLAIwAjQCOAI8AkACRAJIA
kwCUAJUAlgCXAA==</duck>;
}
// base64 code by 2ndyofyyx,
// http://wonderfl.kayac.com/code/b3a19884080f5ed34137e52e7c3032f3510ef861
import flash.utils.ByteArray; 
class Base64 extends ByteArray { 
    private static const BASE64:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0]; 
    public function Base64(str:String) { 
        var n:int, j:int; 
        for(var i:int = 0; i < str.length && str.charAt(i) != "="; i++) {
			if (str.charCodeAt (i) < 33) continue;
            j = (j << 6) | BASE64[str.charCodeAt(i)]; 
            n += 6; 
            while(n >= 8) { 
                writeByte((j >> (n -= 8)) & 0xFF); 
            } 
        } 
        position = 0; 
    } 
}
