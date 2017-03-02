package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import frocessing.color.FColor;
	import idv.cjcat.stardust.common.clocks.SteadyClock;
	import idv.cjcat.stardust.common.emitters.Emitter;
	import idv.cjcat.stardust.threeD.papervision3d.renderers.PV3DDisplayObject3DRenderer;
	import idv.cjcat.stardust.threeD.papervision3d.renderers.PV3DDisplayObjectRenderer;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.view.ReflectionView;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	/**
	 * ...
	 * @author paq89
	 */
	[SWF(width = 465, height = 465, backgroundColor = 0xFFFFFF, frameRate = 60)]
	public class Main extends BasicView
	{
		private const ZERO_POINT:Point = new Point(0, 0);
		private const BLUR:BlurFilter = new BlurFilter(4, 4, 1);
		
		private var _emitter:Pixel3DEmitter;
		private var _pixels:Pixels;
		private var _canvas:BitmapData;
		private var _matrix:Matrix;
		private var _rotation:Number = 0;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// 背景色を設定
			opaqueBackground = 0x000000;
			
			// レンダリング開始
			startRendering();
			
			// キラキラエフェクト用BitmapEffectLayer
			var layer:BitmapEffectLayer=new BitmapEffectLayer(viewport, 465, 465, true, 0, "clear_pre", true);
            layer.clearBeforeRender = true;
            viewport.containerSprite.addLayer(layer);
			
			// Pixels
			_pixels = new Pixels(layer);
			scene.addChild(_pixels);
			
			// エミッター
			_emitter = new Pixel3DEmitter(new SteadyClock(10));
			
			// レンダラー
			var renderer:PV3DPixelsRenderer = new PV3DPixelsRenderer(_pixels);
            renderer.addEmitter(_emitter);
			
			// キラキラエフェクト
			_canvas=new BitmapData(465 / 4, 465 / 4, false, 0x000000);
            var bmp:Bitmap=new Bitmap(_canvas, "never", true);
            bmp.scaleX=bmp.scaleY=4;
            bmp.smoothing=true;
            bmp.blendMode=BlendMode.ADD;
            addChild(bmp);
            _matrix = new Matrix(0.25, 0, 0, 0.25);
			
			// イベントリスナー
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(e:Event):void 
		{
			// キラキラ
			//_canvas.fillRect(_canvas.rect, 0x000000);
			_canvas.applyFilter(_canvas, _canvas.rect, ZERO_POINT, BLUR);
            _canvas.draw(viewport, _matrix);
			
			// パーティクルの発生元をくるくる
			_rotation += 3;
			_emitter.pointA.x = 400 * Math.sin(_rotation * Number3D.toRADIANS);
			_emitter.pointA.y = 400 * Math.cos(_rotation * Number3D.toRADIANS);
			_emitter.pointB.z = 400 * Math.cos(_rotation * Number3D.toRADIANS);
			_emitter.pointB.y = 400 * Math.sin(_rotation * Number3D.toRADIANS);
			_emitter.sphereCap.rotationX = 90;
            _emitter.sphereCap.rotationZ = -_rotation - 90;
			_pixels.rotationX += 0.2;
			_pixels.rotationY += 1;
			
			// エミッター更新
			_emitter.step();
		}
		
	}
	
}
import frocessing.color.ColorHSV;
import idv.cjcat.stardust.common.actions.Age;
import idv.cjcat.stardust.common.actions.DeathLife;
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.events.EmitterEvent;
import idv.cjcat.stardust.common.initializers.CompositeInitializer;
import idv.cjcat.stardust.common.initializers.SwitchInitializer;
import idv.cjcat.stardust.common.particles.ParticleIterator
import idv.cjcat.stardust.common.initializers.Life;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.common.renderers.Renderer;
import idv.cjcat.stardust.threeD.actions.Accelerate3D;
import idv.cjcat.stardust.threeD.actions.Move3D;
import idv.cjcat.stardust.threeD.emitters.Emitter3D;
import idv.cjcat.stardust.threeD.initializers.DisplayObjectClass3D;
import idv.cjcat.stardust.threeD.initializers.Position3D;
import idv.cjcat.stardust.threeD.initializers.Velocity3D;
import idv.cjcat.stardust.threeD.particles.Particle3D;
import idv.cjcat.stardust.threeD.zones.SinglePoint3D;
import idv.cjcat.stardust.threeD.zones.SphereCap;
import org.papervision3d.core.geom.Pixels;
import org.papervision3d.core.geom.renderables.Pixel3D;

/**
 * エミッター
 * @author paq89
 */
class Pixel3DEmitter extends Emitter3D
{
	public var pointA:SinglePoint3D = new SinglePoint3D();
	public var pointB:SinglePoint3D = new SinglePoint3D();
	public var sphereCap:SphereCap = new SphereCap(0, 0, 0, 1, 0, 40);
	
	public function Pixel3DEmitter(clock:Clock)
	{
		super(clock);
		
		var compInitA:CompositeInitializer = new CompositeInitializer();
		compInitA.addInitializer(new Position3D(pointA));
		compInitA.addInitializer(new DisplayObjectClass3D(PixelParticleA));
		var compInitB:CompositeInitializer = new CompositeInitializer();
		compInitB.addInitializer(new Position3D(pointB));
		compInitB.addInitializer(new DisplayObjectClass3D(PixelParticleB));
		var switchInit:SwitchInitializer = new SwitchInitializer([compInitA, compInitB],[1,1]);
		addInitializer(switchInit);
		addInitializer(new Life(new UniformRandom(90, 0)));
		addInitializer(new Velocity3D(sphereCap));
		
		addAction(new Move3D());
		addAction(new Age());
        addAction(new DeathLife());
		addAction(new Accelerate3D(0.05));
	}
}

/**
 * パーティクル
 * @author paq89
 */
class PixelParticleA extends Pixel3D
{
	private static var hsv:ColorHSV = new ColorHSV(0, 1, 0.7);
	
	public function PixelParticleA()
	{
		hsv.h += 0.1;
		super(hsv.value32);
	}
}
class PixelParticleB extends Pixel3D
{
	private static var hsv:ColorHSV = new ColorHSV(70, 1, 0.7);
	
	public function PixelParticleB()
	{
		hsv.h += 0.1;
		super(hsv.value32);
	}
}

/**
 * Pixel3D専用レンダラー
 * @author paq89
 */
class PV3DPixelsRenderer extends Renderer
{
	private var container:Pixels;
	
	public function PV3DPixelsRenderer(container:Pixels = null)
	{
		this.container = container;
	}
	
	override protected function particlesAdded(e:EmitterEvent):void
	{
		if (!container) return;
		var particle:Particle3D;
		var iter:ParticleIterator = e.particles.getIterator();
		while (particle = iter.particle as Particle3D)
		{
			var pixel:Pixel3D = particle.target;
			container.addPixel3D(pixel);
			particle.dictionary[PV3DPixelsRenderer] = container;
			
			iter.next();
		}
	}
	
	override protected function particlesRemoved(e:EmitterEvent):void
	{
		var particle:Particle3D;
		var iter:ParticleIterator = e.particles.getIterator();
		while (particle = iter.particle as Particle3D)
		{
			var pixel:Pixel3D = particle.target;
			var container:Pixels = particle.dictionary[PV3DPixelsRenderer] as Pixels;
			
			container.removePixel3D(pixel);
			
			iter.next();
		}
	}
	
	override protected function render(e:EmitterEvent):void
	{
		var particle:Particle3D;
		var iter:ParticleIterator = e.particles.getIterator();
		while (particle = iter.particle as Particle3D)
		{
			var pixel:Pixel3D = particle.target;
			
			pixel.x = particle.x;
			pixel.y = particle.y;
			pixel.z = particle.z;
			
			iter.next();
		}
	}
}