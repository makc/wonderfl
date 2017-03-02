// forked from bkzen's [QuickBox2D]スライム
// QuickBox2Dの勉強に使わせていただいた[QuickBox2D]スライムに屈折をつけてみました。
// イメージ通りにはいかなかった・・・

// 屈折用displacementMapを変形させるためにUV付きの3角形を描画したいという理由だけでPapervision3Dを使ってます。
// PV3Dの平行投影の設定方法が中々わからず、てこずりました。コンパクトなUV付きの3角形描画方法があれば置き換えたい。

// どうにかしたい点：スライムの周辺部が折りたたまれた感じになってしまう現象
//              スライム大量描画。元のコードから著しく変わりそうだったのでやめました

// インデントがむちゃくちゃになってしまった、FlashDevelopと設定があってないのかな。
/**
* スライム with displacementMapFilter/Refraction
*/
package 
{
    import Box2D.Common.Math.b2Vec2;
    import flash.display.Bitmap;
    import flash.display.BitmapDataChannel;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.filters.DisplacementMapFilter;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.geom.Matrix;
    import flash.display.BitmapData;
    import com.actionsnippet.qbox.QuickBox2D;
    import com.actionsnippet.qbox.QuickObject;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.geom.renderables.Triangle3D;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.core.geom.TriangleMesh3D;
    import org.papervision3d.core.math.NumberUV;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.view.Viewport3D;
    
    import flash.system.LoaderContext;
    
    [SWF(width=465,height=465,backgroundColor=0xcccccc,frameRate=60)]
    public class FlashTest extends Sprite 
    {
    		private var points:Array;
    		private var centerObj:QuickObject;
    		private var shape:Shape;
    		private var loader:/*Loader*/Array;
    		private var faceMatrix:Matrix;
    		private var face:BitmapData;

    		// 
                private var back : BitmapData;
                private var displacementBmp : BitmapData;
                private var sky : BitmapData;
                private var slimeSphere : SphereRenderImage;
                private var displacementFilter : DisplacementMapFilter;
		// pv3d
                private var scene : Scene3D;
                private var camera : Camera3D;
                private var renderer : BasicRenderEngine;
                private var viewport : Viewport3D;
                private var obj3d : TriangleMesh3D ;
                private var refractionMaterial : BitmapMaterial;
                private var reflectionMaterial : BitmapMaterial;
                //
                private var temppos : Point;
                private var zeroPoint : Point = new Point(0,0);
			
		
                //複数画像の読み方がこれでいいのか自信なし
    		private const url:Array = [
				"http://assets.wonderfl.net/images/related_images/c/c4/c47a/c47a1475f2e789c8b0f7533f0875095377ade1af",
				"http://assets.wonderfl.net/images/related_images/6/62/62a1/62a17980f65a893376211b1cfb8fcb0d3bc5d4fc"
				];
    		
        public function FlashTest() 
        {
            // write as3 code here..
            Wonderfl.capture_delay( 50 );
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void
        {
        		//
        		//stage.align = StageAlign.TOP_LEFT; 
        		//stage.scaleMode = StageScaleMode.NO_SCALE;// Playerで最大化したかったのでコメントアウト
				
        		loader = new Array();
        		faceMatrix = new Matrix();
			for (var i : int = 0; i < url.length; i++) {
				loader[i] = new Loader();
				loader[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
				loader[i].load(new URLRequest(url[i]), new LoaderContext(true));
			}
        		//
			temppos = new Point();
        }

	private var loadercnt : int = 0;
        private function onComp(e:Event):void
        {
			loadercnt++;
			if (loadercnt < url.length) return;

			face = Bitmap(loader[0].content).bitmapData;
        		var mc:MovieClip = new MovieClip();
        		addChild(mc);
			//mc.visible = false;
        		var sim:QuickBox2D = new QuickBox2D(mc, {debug:true});
        		centerObj = sim.addCircle({x:5, y:5, radius: 1.2, lineAlpha: 0, fillAlpha: 0 });
        		var rot:Number = 0, n:int = 10, i:int, rn:Number = 180 / n, xx:Number, yy:Number, 
       			pB:QuickObject, pC:QuickObject, pD:QuickObject, pE:QuickObject, pF:QuickObject, pG:QuickObject, 
       			arr1:Array = [], arr2:Array = [];
        		for (i = 0; i < n; i++)
        		{
        			xx = Math.sin(rot * Math.PI / 180) * 2 + 5;
        			yy = Math.cos(rot * Math.PI / 180) * 2 + 5;
        			pB = sim.addCircle(
        				{x: xx, y: yy, radius: 0.01, density: 250, lineAlpha: 0, fillAlpha: 0 ,isBullet:true}
        			);
        			xx = Math.sin((rot + 180) * Math.PI / 180) * 2 + 5;
        			yy = Math.cos((rot + 180) * Math.PI / 180) * 2 + 5;
					if (i == 0) yy -= 0.2;
        			pC = sim.addCircle(
        				{x: xx, y: yy, radius: 0.01, density: 250, lineAlpha: 0, fillAlpha: 0 ,isBullet:true}
        			);
        			sim.addJoint({a: centerObj.body, b: pB.body, frequencyHz: 10, lineAlpha: 0});
        			sim.addJoint({a: centerObj.body, b: pC.body, frequencyHz: 10, lineAlpha: 0});
        			arr1[i] = pB, arr2[i] = pC;
        			if (pD)
        			{
        				sim.addJoint( {a: pB.body, b: pD.body, frequencyHz: 50, lineAlpha: 0} );
        				sim.addJoint( {a: pC.body, b: pE.body, frequencyHz: 50, lineAlpha: 0} );
        			}
        			else
        			{
        				pF = pB, pG = pC;
        			}
        			pD = pB, pE = pC;
        			rot += rn;
        		}
				
        		
        		sim.addJoint( {a: pB.body, b: pG.body, frequencyHz: 50, lineAlpha: 0} );
        		sim.addJoint( {a: pC.body, b: pF.body, frequencyHz: 50, lineAlpha: 0} );
        		
        		points = arr2.concat(arr1);
        		
        		//sim.createStageWalls();
			sim.addBox( {x:-16/30, y:0, width:32/30, height:stage.stageHeight*2/30, density:0} );
			sim.addBox( {x:0, y:-16/30, width:stage.stageWidth/15, height:32/30, density:0} );
			sim.addBox( {x:(stage.stageWidth+16)/30, y:0, width:32/30, height:stage.stageHeight*2/30, density:0} );
			sim.addBox( {x:0, y:(stage.stageHeight+16)/30, width:stage.stageWidth*2/30, height:32/30, density:0} );

        		sim.start();
        		sim.mouseDrag();
        		//removeChild(mc);
        		addChild(shape = new Shape());

			// 
			sky = Bitmap(loader[1].content).bitmapData;// new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffffff);
//			sky.perlinNoise(stage.stageWidth, stage.stageHeight, 8, 0, false, false, 7, true);
			back = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xff00f0f0);
			mc.addChild(new Bitmap(back) );
			displacementBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xff008080);
			displacementFilter  = new DisplacementMapFilter(displacementBmp, null, BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, back.width / 2, back.height / 2);
				
			slimeSphere = new SphereRenderImage(96, 96, back);
			slimeSphere.rl.r = 1.0;
			slimeSphere.rl.g = 1.0;
			slimeSphere.rl.b = 1.0;
			slimeSphere.tcol.r = 0.0;
			slimeSphere.tcol.g = 0.0;
			slimeSphere.tcol.b = 0.5;
			slimeSphere.render(0, 0, true);
			// pv3d
			scene = new Scene3D();
			camera = new Camera3D();
			camera.x = 0;
			camera.y = 0;
			camera.z = -300;
			camera.ortho = true;
			renderer = new BasicRenderEngine();
			viewport = new Viewport3D(stage.stageWidth, stage.stageHeight, false);
			mc.addChild(viewport);
			refractionMaterial = new BitmapMaterial(slimeSphere.refractionBmp);
			refractionMaterial.doubleSided = true;
			reflectionMaterial = new BitmapMaterial(slimeSphere.layerBmp);
			reflectionMaterial.doubleSided = true;
			
			
			obj3d = new TriangleMesh3D(reflectionMaterial, new Array(), new Array());
			obj3d.x = -stage.stageWidth/2;
			obj3d.y = 0;
			obj3d.z = 0;

			obj3d.geometry.vertices.push( new Vertex3D(0, 0, 0));
			for (i = 0; i < n*2; i++) {
				obj3d.geometry.vertices.push( new Vertex3D(0, 0, 0));
			}
			
			for (i = 0; i < n*2; i++) {
			obj3d.geometry.faces.push( new Triangle3D(obj3d, [ obj3d.geometry.vertices[0], obj3d.geometry.vertices[i+1], obj3d.geometry.vertices[((i+1) % (n*2))+1] ], null, [new NumberUV(0, 0), new NumberUV(1, 0), new NumberUV(1, 1)]));
				}

				scene.addChild(obj3d);
				//
        		addEventListener(Event.ENTER_FRAME, loop);
        		
        }
        
        private function loop(e:Event):void
        {
			
        		var g:Graphics = shape.graphics, p1:QuickObject = points[0], p2:QuickObject,
        			i:int, n: int = points.length, px:Number, py:Number,
        			tx:Number, ty:Number;
				obj3d.geometry.vertices[0].x = centerObj.x * N;
				obj3d.geometry.vertices[0].y = stage.stageHeight/2 - centerObj.y * N;
				var rad : Number = 0;
                                rad = Math.atan2(points[0].y-centerObj.y,points[0].x-centerObj.x); // 本当は左上にハイライトがくるように角度を求めるつもりだったが・・・こっちのほうが屈折具合が気持ちいいのでバグのまま残す
				for (i = 0; i < n; i ++) {
					var v : Vertex3D;
        			p1 = points[i    ];
					v = obj3d.geometry.vertices[i + 1];
					v.x = p1.x * N ;
					v.y = stage.stageHeight/2 - p1.y * N ;
				}
				
				var facen : int = obj3d.geometry.faces.length;
				for (i = 0; i < facen; i++) {
					var f : Triangle3D = obj3d.geometry.faces[i];
					f.uv0.u = 0.5;
					f.uv0.v = 0.5;
					f.uv1.u = 0.5 + Math.sin(rad) * 0.5;
					f.uv1.v = 0.5 + Math.cos(rad) * 0.5;
					f.uv2.u = 0.5 + Math.sin(rad - Math.PI / 10) * 0.5;
					f.uv2.v = 0.5 + Math.cos(rad - Math.PI / 10) * 0.5;
					rad -=  Math.PI / 10;
				}
				refractionMaterial.resetMapping();
				obj3d.material = refractionMaterial;
				renderer.renderScene(scene, camera, viewport);
				displacementBmp.fillRect(displacementBmp.rect, 0xff008080);
				displacementBmp.draw(viewport);
				back.applyFilter(sky, sky.rect, zeroPoint, displacementFilter);
				//back.copyPixels(displacementBmp, displacementBmp.rect, zeroPoint);

				reflectionMaterial.resetMapping();
				obj3d.material = reflectionMaterial;
				renderer.renderScene(scene, camera, viewport);

					
        		g.clear();
        		g.beginFill(0x33CCCC);
        		px = centerObj.x * N;
        		py = centerObj.y * N;
        		tx = stage.mouseX - px;
        		ty = stage.mouseY - py;
        		tx = tx / stage.stageWidth  * 3;
        		ty = ty / stage.stageHeight * 3;
        		faceMatrix.tx = px - 35;
        		faceMatrix.ty = py - 35;
        		g.beginBitmapFill(face, faceMatrix, false, true);
        		g.drawRect(faceMatrix.tx, faceMatrix.ty, 70, 70);
        		g.beginFill(0x000000);
        		g.drawCircle(px - 20 + tx, py - 20 + ty, 7);
        		g.drawCircle(px + 20 + tx, py - 20 + ty, 7);
        }
		
    }
}
/// 実際のx,yがちいさいからとりあえず30倍したら丁度よかった。
const N:int = 30;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BlurFilter;
class Point3D
{
	public var x : Number;
	public var y : Number;
	public var z : Number;
}
class Rgb 
{
	public var a : Number;
	public var r : Number;
	public var g : Number;
	public var b : Number;
	
	public function color(col : uint) : Rgb
	{
		a = (col >> 24) / 255;
		r = ((col >> 16) & 0xff) / 255;
		g = ((col >> 8) & 0xff) / 255;
		b = ((col >> 0) & 0xff) / 255;
		
		return this;
	}
	
	public static function pack32(r : Number, g : Number, b : Number, a : Number) : uint
	{
		return (Math.min(255, a * 255) << 24) | (Math.min(255, r * 255) << 16) | (Math.min(255, g * 255) << 8) | Math.min(255, b * 255);
	}
	
	public function color32() : uint
	{
		return pack32(r, g, b, a);
	}
	
}


import flash.display.BitmapData;
import flash.filters.DisplacementMapFilter;
import flash.geom.Point;

class SphereRenderImage
{
	private const PI : Number = 3.141592;
	private var width : int;
	private var height : int;
	private var radius : int;
	
	//private var blur : BlurFilter = new BlurFilter(4, 4, 1);
	private var zeroPoint : Point = new Point(0, 0);
	public  var layerBmp : BitmapData;
	public  var refractionBmp : BitmapData;
	private var backgroundBmp : BitmapData;
	private var diffuseBmp : BitmapData = null; // not use yet
	
	private var temppos : Point3D = new Point3D();
	private var dcol : Rgb = new Rgb();

	
	public  var refraction : Number = 1.0;
	public  var shininess : Number = 1.0;
	public  var tcol : Rgb = new Rgb(); 
	public  var spec : Rgb = new Rgb(); 
	public  var amb : Rgb = new Rgb(); 
	public  var rl : Rgb = new Rgb(); 
	public  var bk : Rgb = new Rgb(); 
	
	
	public function SphereRenderImage(width : int, height : int, background : BitmapData) : void
	{
		this.width = width;
		this.height = height;
		this.radius = Math.min(width, height) / 2;
		
		backgroundBmp = background;
		
		layerBmp = new BitmapData(width, height, true, 0);
		refractionBmp = new BitmapData(width, height, true, 0);
		
		spec.a = 1.0;
		spec.r = 1.0;
		spec.g = 1.0;
		spec.b = 1.0;

		amb.a = .0;
		amb.r = .0;
		amb.g = .0;
		amb.b = .0;
	}
	
	private function norm(x : Number, y : Number, z : Number ,/*out*/ o : Point3D) : void
	{
		var len : Number = Math.sqrt( x*x + y*y + z*z );
		o.x = x / len;
		o.y = y / len;
		o.z = z / len;
	}
	
	public function render(posx : int, posy : int, use_displace : Boolean = false) : void
	{
		if (use_displace) refractionBmp.lock();
		layerBmp.lock();
		var cx : int = Math.min( width, height )/2;
		var cy : int = Math.min( width, height )/2;

		var rr : Number = radius;
		var tr : int = rr >> 0;

		var tr_xscale : Number =  2;// backgroundBmp.width / 32;// width;
		var tr_yscale : Number =  2;// backgroundBmp.height / 32;// height;
		
		for (var i : int = 0; i < tr * 2 ; i++) {
			
			var rad1 : Number = Math.acos( ((tr-i)/tr) );
			var spanr : Number = Math.sin( rad1 ) * rr - 1;
			var y : Number = (tr-i);

			for (var j : int = 0; j < tr * 4 -1; j++) {
				var rad2 : Number = (j / rr)*PI/4;
				var x : Number = Math.cos( rad2 ) * spanr;
				var z : Number = Math.sin( rad2 ) * spanr;

				norm(0 - x, 0 - y, rr*10 - z, temppos);
				var ex : Number = temppos.x;
				var ey : Number = temppos.y;
				var ez : Number = temppos.z;

				norm(rr*10 - x,rr*10 - y,rr*10 - z, temppos);
				var lx : Number = temppos.x;
				var ly : Number = temppos.y;
				var lz : Number = temppos.z;

				norm(ex+lx,ex+lx,ex+lx, temppos);
				var hx : Number = temppos.x;
				var hy : Number = temppos.y;
				var hz : Number = temppos.z;

				norm(x,y,z, temppos);
				var nx : Number = temppos.x;
				var ny : Number = temppos.y;
				var nz : Number = temppos.z;

				var dr : Number = 0.0, dg : Number = 0.0 , db : Number = 0.0;
				if (diffuseBmp) {
					col = diffuseBmp.getPixel32( diffuseBmp.width * ((rad2 / PI / 1 )) , diffuseBmp.height * (rad1 / PI / 1 ));
					dcol.color(col);
					dcol.r = dcol.r * dr;
					dcol.g = dcol.g * dg;
					dcol.b = dcol.b * db;
				} else {
					dcol.r = dr;
					dcol.g = dg;
					dcol.b = db;
				}

				var tx : int = x;
				var px : int = (cx - tr) + tr - tx;
				var py : int = (cy - tr + i);
				
				if ((tcol.r != 0.0) || (tcol.g != 0.0) || (tcol.b != 0.0)) {
					var cosa : Number = nx * 0 + ny * 0 + nz * 1;
					var tr_u : Number, tr_v : Number;
					if (cosa != 0) tr_u = nx / cosa; else tr_u = 0;
					if (cosa != 0) tr_v = ny / cosa; else tr_v = 0;

					var tr_x : int = (backgroundBmp.width + ((cx+posx+tr_u*tr*refraction)*tr_xscale) >> 0) % backgroundBmp.width;
					if (tr_x < 0) tr_x = 0;

					var tr_y : int = (backgroundBmp.height + ((cy+posy+tr_v*tr*refraction)*tr_yscale) >> 0) % backgroundBmp.height;
					if (tr_y < 0) tr_y = 0;

					cosa = 1-cosa;
					var reflection : Number = (1-0.2)*cosa;//0.0 + (1-0.0)*cosa*cosa*cosa*cosa*cosa; // fresnel

					// pseudo refraction! not real! but look like
					if (use_displace) {
						var  tu : int = Math.max(Math.min(255, (tr_u*tr*refraction*tr_xscale/backgroundBmp.width)*128 + 128), 0);
						var  tv : int = Math.max(Math.min(255, (tr_v*tr*refraction*tr_yscale/backgroundBmp.height)*128 + 128), 0);
						refractionBmp.setPixel32(px, py, 0xff000000 | (tu << 8) | (tv));
						dcol.r = (1-rl.r*reflection)*(dcol.r*(1-tcol.r)+1*tcol.r) + rl.r*reflection*1; // 透明部分に色をつけたかったので1*tcol.を追加。ちょっとむちゃくちゃな式になってきてます
						dcol.g = (1-rl.g*reflection)*(dcol.g*(1-tcol.g)+1*tcol.g) + rl.g*reflection*1;
						dcol.b = (1-rl.b*reflection)*(dcol.b*(1-tcol.b)+1*tcol.b) + rl.b*reflection*1;
					} else {
						if (tr_y < backgroundBmp.height) {
							col = backgroundBmp.getPixel32(tr_x, tr_y);
							bk.color(col);
							dcol.r = (1-rl.r*reflection)*(dcol.r*(1-tcol.r)+bk.r*tcol.r) + rl.r*reflection*1;
							dcol.g = (1-rl.g*reflection)*(dcol.g*(1-tcol.g)+bk.g*tcol.g) + rl.g*reflection*1;
							dcol.b = (1-rl.b*reflection)*(dcol.b*(1-tcol.b)+bk.b*tcol.b) + rl.b*reflection*1;
						} else {
							dcol.r = tcol.r;
							dcol.g = tcol.g;
							dcol.b = tcol.b;
						}
					}
				}
				
				var dot1 : Number;

				if ((tcol.r != 0.0) || (tcol.g != 0.0) || (tcol.b != 0.0)) {
					dot1 = Math.max(1, Math.abs(lx*nx + ly*ny + lz*nz));
				} else {
					dot1 = Math.max(0, lx*nx + ly*ny + lz*nz);
				}
				var kpow : Number = (shininess*128);
				var dot2 : Number = Math.pow(Math.max(0, hx*nx + hy*ny + hz*nz), kpow);

				var col : uint;
				
				if (use_displace) {
					col = Rgb.pack32(dot2*spec.r + dot1 * dcol.r + amb.r, dot2*spec.g + dot1 * dcol.g + amb.g, dot2*spec.b + dot1 * dcol.b + amb.b, dot2*spec.a+dot1*Math.max(dcol.r, dcol.g, dcol.b) );
				} else {
					col = Rgb.pack32(dot2 * spec.r + dot1 * dcol.r + amb.r,  dot2 * spec.g + dot1 * dcol.g + amb.g, dot2 * spec.b + dot1 * dcol.b + amb.b, 1 );
				}

				if ((px >= 0) && (px < width) && (py >= 0) && (py < height)) {
					layerBmp.setPixel32(px, py, col);
				}
			}
		}
		layerBmp.unlock();
		if (use_displace) {
			//refractionBmp.applyFilter(refractionBmp, refractionBmp.rect, zeroPoint, blur);
			refractionBmp.unlock();
		}
	}
}

