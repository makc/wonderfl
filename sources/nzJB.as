package {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * Tile mapping test.
	 * Hold left mouse button down to pan, wheel to zoom.
	 * @author makc
	 * @license WTFPLv2
	 */
	public class Test4 extends Sprite {
		public function Test4 () {
			x = y = (465 - 401) / 2;
			// load maze image
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onMazeLoaded);
			loader.load (new URLRequest (/*"maze.gif"*/"http://assets.wonderfl.net/images/related_images/3/33/3314/3314c15f8a2b2a7b4a293733e6c1b9e2fe6867c9"),
				new LoaderContext (true));
		}
		public function onMazeLoaded (e:Event):void {
			var info:LoaderInfo = LoaderInfo (e.target);
			info.removeEventListener (Event.COMPLETE, onMazeLoaded);
			addChild (info.content);
			// load tiles image
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onTilesLoaded);
			loader.load (new URLRequest (/*"tiles.gif"*/"http://assets.wonderfl.net/images/related_images/4/4b/4bb8/4bb8f8e6f1c88eb42087484c9dca50a2f20f78a4"),
				new LoaderContext (true));
		}
		public var tiles:BitmapData;
		public function onTilesLoaded (e:Event):void {
			var info:LoaderInfo = LoaderInfo (e.target);
			info.removeEventListener (Event.COMPLETE, onTilesLoaded);
			tiles = info.content ["bitmapData"];
			// load tile mapping shader
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener (Event.COMPLETE, onShaderLoaded);
			loader.load (new URLRequest (/*"tmap.pbj.gif"*/"http://assets.wonderfl.net/images/related_images/b/b0/b05c/b05cec703b5737e28c3f6cc15325fe3f5b88b955"));
		}
		public var filter:ShaderFilter;
		public function updateFilter ():void { filters = [ filter ]; }
		public function onShaderLoaded (e:Event):void {
			var loader:URLLoader = URLLoader (e.target);
			loader.removeEventListener (Event.COMPLETE, onShaderLoaded);
			// skip some bytes (for wonderfl)
			var loadedData:ByteArray = ByteArray (loader.data);
			var shaderData:ByteArray = new ByteArray;
			loadedData.position = 1939;
			loadedData.readBytes (shaderData, shaderData.length, loadedData.bytesAvailable);
			// make filter
			var shader:Shader = new Shader (shaderData); shader.data.tiles.input = tiles;
			filter = new ShaderFilter (shader); updateFilter ();
			// wire controls
			stage.addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);
		}
		public function onMouseWheel (e:MouseEvent):void {
			var area:Array = filter.shader.data.zoomArea.value;
			var delta:Number = ((e.delta > 0) ? 0.05 : -0.05) * area [2];
			area [0] -= delta; area [2] += 2 * delta;
			area [1] -= delta; area [3] += 2 * delta;
			updateFilter ();
		}
		public function onMouseDown (e:MouseEvent):void {
			addEventListener (Event.ENTER_FRAME, onEnterFrame);
		}
		public function onMouseUp (e:MouseEvent):void {
			removeEventListener (Event.ENTER_FRAME, onEnterFrame);
		}
		public function onEnterFrame (e:Event):void {
			var area:Array = filter.shader.data.zoomArea.value;
			var delta:Point = new Point (x + mouseX - 465 / 2, y + mouseY - 465 / 2);
			delta.normalize (0.02 * (area [2] + area [3]));
			area [0] += delta.x; area [1] += delta.y;
			updateFilter ();
		}
	}
}