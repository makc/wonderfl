package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	
	[SWF(width=465, height=465, backgroundColor=0x0, frameRate=60)]
	public class ytti_Sntk extends BasicView
	{
		private var _tempbmd:BitmapData;
		private var _particles:Array;
		private var _pcls:Particles;
		
		public function ytti_Sntk()
		{
			super(0,0,true,false,CameraType.TARGET);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this._onImageLoaded);
			loader.load(new URLRequest('http://saqoosha.net/images/sntk.jpg'), new LoaderContext(true));
		}
		
		private function _onImageLoaded(e:Event):void {
			var loader:Loader = LoaderInfo(e.target).loader;
			_tempbmd = Bitmap(loader.content).bitmapData as BitmapData;
			
			camera.z = -300;
			
			_particles = [];
			_pcls = new Particles();
			scene.addChild(_pcls);
			
			var div:Number = 4;
			for(var w:uint = 0;w < _tempbmd.width ;w+=div ){
				for(var h:uint = 0;h < _tempbmd.height;h+=div ){
					var color:uint = _tempbmd.getPixel(w,h);
					var px:int = w - (_tempbmd.width)/2;
					var py:int = -(h - (_tempbmd.height)/2);
					var pz:int = color/0xFFFFFF * 40;
					var material:ParticleMaterial = new ParticleMaterial(0x00FF00,0.7-(0.7*color/0xFFFFFF)+0.3,ParticleMaterial.SHAPE_CIRCLE);
					var particle:Particle = new Particle(material,2,px,py,pz);
					_pcls.addParticle(particle);
					_particles.push(particle);
				}
			}
			
			/*
			var img:Bitmap = new Bitmap(_tempbmd);
			addChild(img);
			img.scaleX = img.scaleY = 0.4;
			*/
			
			startRendering();
			
			addEventListener(Event.ENTER_FRAME , loop)
		}
		
		private function loop(e:Event):void {
			_pcls.yaw(2);
		}

	}
}