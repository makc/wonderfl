/**
 * ステージクリックで明かりがついたり消えたりします。
 * 
 * 
 * -参考-
 * 
 * キラキラPixel3D！
 * http://wonderfl.net/c/rwYK
 */
package
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import gs.TweenMax;
	import net.hires.debug.Stats;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.utils.BitmapClearMode;
	import org.papervision3d.core.effects.utils.BitmapDrawCommand;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	[SWF(backgroundColor = 0x000000, width = "465", height = "465", frameRate = 60)]
	public class Main extends BasicView
	{
		private const STAR_COLOR:uint = 0xFFC460
		private const STAR_RADIUS:uint = 50;
		private const LEAF_COLOR:uint = 0x274905;
		private const LEAF_RADIUS:uint = 300;
		private const LEAF_HEIGHT:Number = 700;
		private const TRUNK_COLOR:uint = 0x822e01;
		private const TRUNK_RADIUS:uint = 50;
		private const TRUNK_HEIGHT:Number = 120;
		private const PLANT_COLOR:uint = 0x4f1700;
		private const PLANT_RADIUS:uint = 90;
		private const PLANT_HEIGHT:Number = 40;
		private const SPHERE_COUNT:uint = 30;
		private const SPHERE_COLOR_LIST:Array = [0xFC0A0A, 0xFC0A0A, 0x3E33FF,0x666666];
		private const LACE_COUNT:uint = 1000;
		private const LACE_COLOR:uint = 0xCCFFF4AA;
		private const SNOW_COUNT:uint = 500;
		private const SNOW_COLOR:uint = 0x99FFFFFF;
		private const SNOW_AREA_R:Number = 500;
		private var _sphereList:Vector.<Sphere>=new Vector.<Sphere>();
		private var _my:Number = 0;
		private var _isLight:Boolean = false;
		private var _root:DisplayObject3D, _tree:Tree, _bfx:BitmapEffectLayer, _snow:Snow;
		public function Main():void
		{
			super(465, 465, false);
			Wonderfl.capture_delay(15);
			if (!stage)
				addEventListener(Event.ADDED_TO_STAGE, _init);
			else
				_init();
		}
		private function _init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			_root = scene.addChild(new DisplayObject3D());
			var light:PointLight3D = new PointLight3D(false);
			light.z = -1000;
			light.x = -1000;
			light.y = 1000;
			var objList:Array = [];
			_tree = new Tree(STAR_COLOR, STAR_RADIUS, LEAF_COLOR, LEAF_RADIUS, LEAF_HEIGHT, TRUNK_COLOR, TRUNK_RADIUS, TRUNK_HEIGHT, PLANT_COLOR, PLANT_RADIUS, PLANT_HEIGHT);
			_root.addChild(_tree);
			objList.push(_tree)
			_tree.y = -400;
			var sphBaseRad:Number =  (2 * Math.PI) / SPHERE_COUNT;
			for (var i:int = 0; i < SPHERE_COUNT; i++)
			{
				var sphMaterial:FlatShadeMaterial = new FlatShadeMaterial(light, 0x666666, SPHERE_COLOR_LIST[Math.floor((SPHERE_COLOR_LIST.length - 0.01) * Math.random())]);
				objList.push(_createSphere(sphMaterial, sphBaseRad * i));
			}
			_createBitmapEffectLayer(objList);
			var pixels:Pixels  = new Pixels(_bfx);
			_root.addChild(pixels);
			_createLacePixels(pixels, LACE_COUNT);
			//addChild(new Stats());
			_start();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
		}
		private function _start():void
		{
			_tree.start(0.3, 0.045);
			_sphereStart(2.6, 0.075);
			TweenMax.delayedCall(5.60, _openingComplete);
			_snow = new Snow(SNOW_COUNT, SNOW_COLOR, SNOW_AREA_R);
			addChildAt(_snow, 1);
			startRendering();
		}
		private function _openingComplete():void
		{
			stage.addEventListener(MouseEvent.CLICK, _onClickHandler);
			_onClickHandler();
		}
		private function _createBitmapEffectLayer(list:Array):void
		{
			_bfx = new BitmapEffectLayer(viewport, 465, 465, true, 0x00FFFFFF, BitmapClearMode.CLEAR_PRE, false, false);
			_bfx.addEffect(new BitmapColorEffect(1.0, 1.0, 1.0, 0.9));
            _bfx.addEffect(new BitmapLayerEffect(new BlurFilter(10, 10, BitmapFilterQuality.LOW), false));
			_bfx.drawCommand = new BitmapDrawCommand(null, new ColorTransform(1.0, 1.0, 1.0, 1.0, -32, -16, -32, -16), BlendMode.ADD);
			for (var i:int = 0; i < list.length; i++)
			{
				_bfx.addDisplayObject3D(list[i]);
			}
		}
		private function _createSphere(mat:FlatShadeMaterial, rad:Number = 0):Sphere
		{
			var result:Sphere = new Sphere(mat, 15, 3, 4);
			var pt:Pt = _treeOutLinePt(rad, 220, 80);
			result.x = pt.x;
			result.y = pt.y;
			result.z = pt.z;
			result.rotationY = 360 * Math.random();
			_sphereList.push(result);
			return result;
		}
		private function _createLacePixels(pixels:Pixels, num:uint):void
		{
			for (var i:int = 0; i < num; ++i) 
			{
				var pt:Pt = _treeOutLinePt(Math.PI * 2 * Math.random(), 80, 50 * Math.sin(Math.PI * 0.5 * Math.random())-20);
				var px:Pixel3D = new Pixel3D(LACE_COLOR, pt.x, pt.y, pt.z);
				pixels.addPixel3D(px);
			}
		}
		private function _treeOutLinePt(rad:Number, top:Number = 0, bottom:Number = 0):Pt
		{
			var result:Pt = new Pt();
			var posY:Number = (LEAF_HEIGHT - top) * ( _tree.getOutLine(Math.random() * LEAF_HEIGHT) / LEAF_RADIUS) + bottom;
			var r:Number = _tree.getOutLine(posY);
			result.x = r * Math.cos(rad);
			result.y = posY + _tree.leafBaseY + _tree.y;
			result.z = r * Math.sin(rad);
			return result;
		}
		private function _sphereStart(delayTime:Number = 0, speed:Number = 0.04):void
		{
			for (var i:int = 0; i < _sphereList.length; i++) 
			{
				TweenMax.delayedCall(i * speed + delayTime, _addChildSphere, [_sphereList[i]]);
			}
			_sphereList = null;
		}
		private function _addChildSphere(sphere:Sphere):void
		{
			_root.addChild(sphere);
		}
		override protected function onRenderTick(event:Event = null):void
		{
			super.onRenderTick(event);
            _root.rotationY -= (stage.mouseX - stage.stageWidth * 0.5) * 0.008;
			_my += ((stage.mouseY - stage.stageHeight * 0.5) * 2.0 - _my) * 0.08;
			camera.y = _my;
			camera.zoom = 40 - _my * 0.025
			_snow.update(_root.rotationY,camera.y,camera.zoom);
		}
		private function _onClickHandler(e:MouseEvent = null):void
		{
			_isLight = !_isLight;
			if (_isLight)
			{	
				viewport.containerSprite.addLayer(_bfx);
				_snow.show();
			}else
			{	
				viewport.containerSprite.removeLayer(_bfx);
				_snow.hide();
			}
		}
	}
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.PixelSnapping;
import flash.geom.Matrix;
import gs.TweenMax;
import org.papervision3d.core.effects.utils.BitmapClearMode;
import org.papervision3d.core.geom.Lines3D;
import org.papervision3d.core.geom.Pixels;
import org.papervision3d.core.geom.renderables.Line3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.geom.renderables.Pixel3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.materials.special.LineMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.view.BasicView;
import org.papervision3d.view.layer.BitmapEffectLayer;
class Tree extends Lines3D
{		
	private const LINE_SIZE:uint = 3;
	private const MARGIN:Number = 5;
	private var _rad:Number = 0;
	private var _h:Number = 0;
	private var _list:Vector.<Line3D>=new Vector.<Line3D>();
	private var _v3d:Vertex3D, _interval_rad:Number, _starMaterial:LineMaterial, _starRadius:Number, _leafMaterial:LineMaterial, _leafRadius:Number, _leafHeight:Number, _leafBaseY:Number, _trunkMaterial:LineMaterial, _trunkRadius:Number, _plantMaterial:LineMaterial, _plantRadius:Number;
	public function Tree(starColor:uint, starRadius:Number, leafColor:uint, leafRadius:Number, leafHeight:Number, trunkColor:uint, trunkRadius:Number, trunkHeight:Number, plantColor:uint, plantRadius:Number, plantHeight:Number)
	{
		_init(starColor, starRadius, leafColor, leafRadius, leafHeight, trunkColor, trunkRadius, trunkHeight, plantColor, plantRadius, plantHeight);
	}
	private function _init(starColor:uint, starRadius:Number, leafColor:uint, leafRadius:Number, leafHeight:Number, trunkColor:uint, trunkRadius:Number, trunkHeight:Number, plantColor:uint, plantRadius:Number, plantHeight:Number):void
	{
		_v3d = new Vertex3D(_trunkRadius * Math.cos(_rad), _trunkRadius * Math.sin(_rad), _h);
		_interval_rad = 110 / 180 * Math.PI;
		_starMaterial = new LineMaterial(starColor, 1);
		_starRadius = starRadius;
		_leafMaterial = new LineMaterial(leafColor, 1);
		_leafRadius = leafRadius;
		_trunkMaterial = new LineMaterial(trunkColor, 1);
		_trunkRadius = trunkRadius;
		_plantMaterial = new LineMaterial(plantColor, 1);
		_plantRadius = plantRadius;
		_createPlant(plantHeight);
		_createTrunk(trunkHeight);
		_createLeaf(leafHeight);
		_createStar();
	}
	private function _createTrunk(height:Number):void
	{
		var margin:Number = MARGIN * 1.2;
		var num:uint = Math.floor(height / margin);
		for (var i:int = 0; i < num; i++)
		{
			_h += margin;
			var newV3d:Vertex3D = _createV3d(_trunkRadius, _h);
			var line:Line3D = new Line3D(this, _trunkMaterial, LINE_SIZE, _v3d, newV3d);
			_list.push(line);
			_v3d = newV3d;
		}
		_h -= MARGIN * 2
	}
	private function _createLeaf(height:Number):void
	{
		var margin:Number=MARGIN*2.0
		var num:uint = Math.floor(height / margin);
		_leafBaseY = _h;
		for (var i:int = 0; i < num; i++)
		{
			_h += margin;
			var newV3d:Vertex3D = _createV3d(_leafCurve(i,num), _h);
			var line:Line3D = new Line3D(this, _leafMaterial, LINE_SIZE, _v3d, newV3d);
			_list.push(line);
			_v3d = newV3d;
		}
		_leafHeight = _h - _leafBaseY;
		_h -= MARGIN*5
	}
	private function _createStar():void
	{
		_createStarV3d(0, _h);
		_createStarV3d(3, _h);
		_createStarV3d(1, _h);
		_createStarV3d(4, _h);
		_createStarV3d(2, _h);
		_createStarV3d(0, _h);
	}
	private function _createPlant(height:Number):void
	{
		var margin:Number = MARGIN;
		var num:uint = uint(height / margin);
		var r:Number = _plantRadius;
		for (var i:int = 0; i < num; i+=4)
		{
			for (var j:int = 0; j < 4; j++)
			{	
				_createPlantV3d(j, _h, r);
				_h += margin
			}
			r += 2;
		}
		r *= 1.1;
		for (var k:int = 0; k < 4; k++)
		{	
			_createPlantV3d(k, _h, r);
			_h += margin
		}
		_createPlantV3d(0, _h, 0);
		_h -= MARGIN*4
	}
	private function _createV3d(r:Number, h:Number):Vertex3D
	{
		_rad += _interval_rad;
		return new Vertex3D(r * Math.cos(_rad), h, r * Math.sin(_rad));
	}
	private function _leafCurve(i:Number,max:Number):Number
	{
		var a:Number = 0.06;
		var b:Number=0.1
		return _leafRadius * (1-Math.sin(i / max * Math.PI*0.5))
	}
	private function _createStarV3d(i:uint, baseY:Number):void
	{
		var baseRad:Number = 72 / 180 * Math.PI;
		var newV3d:Vertex3D = new Vertex3D(_starRadius * Math.cos(baseRad * i), _starRadius * Math.sin(baseRad * i)+baseY, 0);
		var line:Line3D = new Line3D(this, _starMaterial, LINE_SIZE, _v3d, newV3d);
		_list.push(line);
		_v3d = newV3d;
	}
	private function _createPlantV3d(i:uint, h:Number, r:Number):void
	{
		var baseRad:Number = Math.PI *0.5;
		var newV3d:Vertex3D = new Vertex3D(r * Math.cos(baseRad * i), h, r * Math.sin(baseRad * i));
		var line:Line3D = new Line3D(this, _plantMaterial, LINE_SIZE, _v3d, newV3d);
		_list.push(line);
		_v3d = newV3d;
	}
	public function getOutLine(y:Number):Number
	{
		return _leafCurve(y, _leafHeight);
	}
	public function start(delayTime:Number=0, speed:Number=0.04):void
	{
		for (var i:int = 0; i < _list.length; i++) 
		{
			TweenMax.delayedCall(i * speed + delayTime, _addLine, [_list[i]]);
		}
		_list = null;
	}
	private function _addLine(line3D:Line3D):void
	{
		addLine(line3D)
	}
	public function get leafHeight():Number { return _leafHeight };
	public function get leafBaseY():Number { return _leafBaseY };
}
class Snow extends BasicView
{
	private var _list:Vector.<Pixel3D>=new Vector.<Pixel3D>();
	private var _root:DisplayObject3D, _bmp:Bitmap, _mtx:Matrix;
	public function Snow(count:uint, color:uint, areaR:Number)
	{
		super(465, 465, false);
		_init(count, color, areaR);
	}
	private function _init(count:uint, color:uint, areaR:Number):void
	{
		_root = scene.addChild(new DisplayObject3D());
		var bfx:BitmapEffectLayer = new BitmapEffectLayer(viewport, 465, 465, true, 0x00FFFFFF, BitmapClearMode.CLEAR_PRE, false, false);
		bfx.clearBeforeRender=true;
		viewport.containerSprite.addLayer(bfx);
		var pixels:Pixels  = new Pixels(bfx);
		var rad:Number, r:Number;
		for (var i:int = 0; i < count; ++i) 
		{
			rad = 2 * Math.PI * Math.random();
			r = areaR * Math.random();
			var px:Pixel3D = new Pixel3D(color, r * Math.cos(rad), Math.random() * 1000 - 400, r * Math.sin(rad));
			pixels.addPixel3D(px);
			_list.push(px)
		}
		_root.addChild(pixels);
		_bmp = new Bitmap(new BitmapData(465 / 4, 465 / 4, false, 0x00000000), PixelSnapping.NEVER, true);
		_bmp.scaleX = _bmp.scaleY = 4;
		_bmp.smoothing = true;
		_bmp.blendMode=BlendMode.ADD;
		_mtx = new Matrix(0.25, 0, 0, 0.25);
	}
	public function update(rotationY:Number, cameraY:Number, cameraZoom:Number):void
	{
		super.onRenderTick();
		var px:Pixel3D;
		for (var i:int = 0; i < _list.length; i++)
		{
			px = _list[i] as Pixel3D;
			px.y = (px.y < -400) ? 600 : px.y - 1;
		}
		var canvas:BitmapData=_bmp.bitmapData
		canvas.fillRect(canvas.rect, 0x00000000);
		canvas.draw(viewport, _mtx);
		_root.rotationY = rotationY;
		camera.y = cameraY;
		camera.zoom = cameraZoom;
	}	
	public function show():void { addChild(_bmp) };
	public function hide():void { removeChild(_bmp) };
}
class Pt
{
	public var x:Number, y:Number, z:Number, color:uint;
	public function Pt(x:Number = 0, y:Number = 0, z:Number = 0, color:uint = 0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.color = color;
	}
}