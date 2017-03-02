// forked from checkmate's Checkmate Vol.6 Amatuer
package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.system.LoaderContext;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import jp.progression.data.*;
	import jp.progression.casts.*;
	import jp.progression.commands.lists.SerialList;
	import jp.progression.commands.net.LoadBitmapData;
	/**
	 * ...
	 * @author k3lab
	 */
	[SWF(width="465", height="465", frameRate="60", backgroundColor="0x000000")] 
	public class CheckmateAmatuer  extends Sprite
	{
		public static var GRAPHIC_URL:String ="http://www.k3lab.com/wonderfl/Amphisbaena/photo.jpg"
		public function CheckmateAmatuer ()
		{
            /* 
            コードでエッチなものごとを描写してください。 
            公序良俗は守ってください。 
             
            Represent something sexual by codes. 
            DO NOT be offensive to public order and morals. 
            */ 
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var list:SerialList = new SerialList(null,
				new LoadBitmapData(new URLRequest(GRAPHIC_URL),{context:new LoaderContext(true)}),
				function ():void {
					var castbitmap:CastBitmap = new CastBitmap(getResourceById(GRAPHIC_URL).data);
					var canvas:BitmapData = castbitmap.bitmapData.clone();
					var blur:BlurFilter = new BlurFilter(30, 30, 1);
					canvas.applyFilter(canvas, canvas.rect, new Point(0, 0), blur); 
					var bmp:Bitmap = addChild(new Bitmap(canvas)) as Bitmap;
					var snake:Snake = addChild(new Snake(castbitmap)) as Snake;
				}
			)
			list.execute();
		}
	}
}
import jp.progression.casts.*;
import org.papervision3d.lights.PointLight3D;
import org.papervision3d.materials.BitmapFileMaterial;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.shadematerials.EnvMapMaterial;
import org.papervision3d.materials.utils.MaterialsList;
import org.papervision3d.objects.parsers.Collada;
import org.papervision3d.view.BasicView;
import flash.events.Event;
import flash.net.URLRequest;
class Snake extends BasicView
{
	public static var COLLADA_URL:String ="http://www.k3lab.com/wonderfl/Amphisbaena/Amphisbaena.DAE"
	private var _castbitmap:CastBitmap;
	public function Snake(bmp:CastBitmap)
	{
		super(465, 465, false, true);
		_castbitmap = bmp;
		init();
	}
	private function init():void
	{
		var light:PointLight3D = new PointLight3D(false, false);
		var envMapMaterial:EnvMapMaterial = new EnvMapMaterial(light, _castbitmap.bitmapData, _castbitmap.bitmapData,0);
		scene.addChild(light);
		var materialsList:MaterialsList = new MaterialsList(); 
		materialsList.addMaterial( envMapMaterial, "Mat"); 
		var c:Collada = new Collada(COLLADA_URL, materialsList, 0.045);
		c.y = -200;
		scene.addChild(c);
		addEventListener(Event.ENTER_FRAME, function(e:Event):void {
			light.copyPosition(camera) 
			c.yaw((200- mouseX )/40);
			c.pitch((200- mouseY )/40);
		})
       startRendering();
	}
}