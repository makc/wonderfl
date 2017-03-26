package 
{
	/**
	 * 音はTsabeat より拝借
	 * http://www.ektoplazm.com/free-music/tsabeat-warp-speed-ep/
	 * 
	 * ビート検知するまで少々お待ち下さい。
	 * 過去作品をasだけで再現できるか試してみました。
	 * 容量の問題があるので途中で音はブツ切りしてます
	 *
	 *
	 * 2030エラーが発生しておりましたが
	 *　psyark様に修正していただきました。
	 *　ありがとうございます！
	 * 10/12/14
	 * 少し修正しました。たまにうごかなくなるバグを修正。
	 */
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.BitmapFireEffect;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.BitmapMotionEffect;
	import org.papervision3d.core.effects.utils.BitmapDrawCommand;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	import org.papervision3d.view.Viewport3D;

	[SWF(backgroundColor = "#000000",frameRate = 30)]
	public class Main extends Sprite
	{
		private var camera:Camera3D = new Camera3D(60,10,20000,true,false);
		private var renderer:BasicRenderEngine = new BasicRenderEngine();
		private var scene:Scene3D = new Scene3D();
		private var viewport:Viewport3D = new Viewport3D(stage.stageWidth,stage.stageHeight);
		private var channel:SoundChannel;
		private var trans:SoundTransform;
		private var bfx:BitmapEffectLayer;
		private var p:Plane;
		private var p1:Sphere;
		private var p2:Sphere;
		private var rot:int = 0;
		private var all_array:Array;
		private var count_array:Array;
		private var rad_array:Array;
		private var array_num:int;
		private var base:Plane;
		private var kyori:int;
		private var roll:int;
		private var mySound:Sound;
		private var bytes:ByteArray;
		private var count:int;
		private var lineArray:Array = new Array();
		private const HEIGHT:int = 100;
		private const LENGTH:int = 512;
		private const VC:int = 20;
		private var s:Sprite;
		private var b:int = 0;
		private var chek:int = 0;
                private var rf:Number;
		public function Main()
		{
			bytes = new ByteArray();
			count = 0;
                        rf = 0;
			Security.loadPolicyFile("http://mutast.heteml.jp/crossdomain.xml");
			addChild(viewport);
			all_array = new Array();
			count_array = new Array();
			rad_array = new Array();
			bfx = new BitmapEffectLayer(viewport,stage.stageWidth,stage.stageHeight);
			bfx.addEffect(new BitmapLayerEffect(new BlurFilter(4, 4, 4)));
			bfx.drawCommand = new BitmapDrawCommand(null,new ColorTransform(1,1,1,0.2),BlendMode.NORMAL);
			viewport.containerSprite.addLayer(bfx);
			mySound = new Sound();
			mySound.load(new URLRequest("http://mutast.heteml.jp/works/music/music.mp3"));
			mySound.addEventListener(Event.COMPLETE, init);
			make();
		}
		public function init(e:Event):void
		{
			var channel:SoundChannel = new SoundChannel();
			channel = mySound.play();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		public function hit():void
		{
			make_set();
			if (b == 0)
			{
				b = 1;
			}
		}
		public function make_set():void
		{
			roll = Math.random() * 6 - 5;
			if (roll >= -2)
			{
				roll +=  5;
			}
			rad_array = new Array();
			count_array = new Array();
			var r:int = Math.random() * 3 + 7;
			var g:int = Math.random() * 3 + 7;
			var b:int = Math.random() * 3 + 7;
			bfx.drawCommand = new BitmapDrawCommand(null,new ColorTransform(r / 10,g / 10,b / 10,0.2),BlendMode.NORMAL);
			var rad_set:int = Math.random() * 2000 + 500;
			var patern:int = Math.random() * 3;
			var rad:Number = 0;
			rot = Math.random() * 180;
			kyori = Math.random() * 5000 + 1000;
			for (var i:int = 0; i < 10; i++)
			{
				if (patern == 0)
				{
					rad = (i+1) * 250;
				}
				else if (patern == 1)
				{
					rad = Math.random() * 200 + rad_set;
				}
				else if (patern == 2)
				{
					rad = (Math.abs(i - 10 / 2) + 2) * 300;
				}
				rad_array.push(rad);
				var scale:int = Math.random() * 50;
				count_array.push(scale);
			}
		}

		public function make():void
		{
			var mat:ColorMaterial = new ColorMaterial(0x000000);
			mat.doubleSided = true;

			base = new Plane(material,1,1);
			scene.addChild(base);
			base.x = base.y = 500;

			var stars:ParticleField = new ParticleField(new ParticleMaterial(0xFFFFFF,1,0,1),300,10,10000,10000,10000);
			scene.addChild(stars);
			for (var i:int = 0; i < 10; i++)
			{
				var array:Array = new Array();
				all_array.push(array);
				var haba:int = Math.random() * 100 + 100;
				for (var f:int = 0; f < 10; f++)
				{
					var material:ColorMaterial = new ColorMaterial(0xffffff);
					material.doubleSided = true;
					var pl:Plane = new Plane(material,haba,haba);
					array.push(pl);
					scene.addChild(pl);

					bfx.addDisplayObject3D(pl);
				}
			}
		}
		public function loop(e:Event):void
		{
                        bytes.position=0;			
                        SoundMixer.computeSpectrum(bytes, false, 0);
			count = 0;
			for (var q:int = 0; bytes.bytesAvailable >= 4; q++)
			{
				rf = bytes.readFloat();
				var t:Number = Math.abs(rf);
				if (t >= 0.4 && q > 256)
				{
					count++;
				}
				if (count >= 120)
				{
					hit();
				}
			}
			if (b == 1)
			{
				rot +=  roll;
				camera.x = kyori * Math.sin(Math.PI / 180 * rot);
				camera.y = kyori * Math.cos(Math.PI / 180 * rot);
				camera.lookAt(base);
				for (var i:int = 0; i < 10; i++)
				{
					for (var j:int = 0; j < 10; j++)
					{
						var c:Plane = all_array[i][j];
						c.x = rad_array[i] * Math.sin(Math.PI / 180 * ((j / 10 * 360) + rot)) + 500;
						c.z = rad_array[i] * Math.cos(Math.PI / 180 * ((j / 10 * 360) + rot)) + 500;
						c.y = i * 700 - 3500;
						c.scaleY = count_array[i] / 10;
						c.lookAt(base);
					}
				}
				renderer.renderScene(scene, camera, viewport);
			}
		}
	}
}
