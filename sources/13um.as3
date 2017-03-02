// forked from gaina's soundtest6
//  << 水滴遊び+soundSpectrum >> ※注：激重
// 家のFirefoxで何故かcomputeSpectrum系の作品が全く動かないので調査を兼ねて製作
//
// 20100713 グラデーション方向を間違えていた。ついでに背景色をちょっと変更
// 20100716 半永久ループ化(9999回)。 マウスクリックの度に色を変えるようにしてみた
package  
{
	import com.bit101.components.CheckBox;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.ShaderInput;
	import flash.display.ShaderParameter;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import frocessing.core.F5BitmapData2D;
	import mx.graphics.ImageSnapshot;
	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author TM
	 */
    [SWF(width=465,height=465,backgroundColor=0x0,frameRate=60)]
	public class soundSpectrumDropWaters extends Sprite
	{
		private var snd:Sound;
		private var FFTswitch:Boolean = false;

		private var canvas : BitmapData;
		private var canvasBmp : Bitmap;

		private var gradiant : BitmapData;
		private var back : BitmapData;
		private var backBmp : Bitmap;
		private var track : BitmapData;

		private var zeroPoint : Point = new Point(0, 0);
		private var dropimages : Vector.<MetaCircle> = new Vector.<MetaCircle>;
		private var uiBar : Sprite = new Sprite();
		
		private var tempPos : Point = new Point();
		private var tempRect : Rectangle = new Rectangle();
		
		private var shader : DropWaterShader = new DropWaterShader();
		private var filter : ShaderFilter = new ShaderFilter(shader);
		private var metaNV : MetaNVShader = new MetaNVShader();
		private var metaNVfilter : ShaderFilter = new ShaderFilter(metaNV);
		private var blur : BlurFilter = new BlurFilter(4, 4);
		private var dropShadow : DropShadowFilter = new DropShadowFilter(2, 2, 0, 0.5);
		
		private var light : Vector3D;
		private var eye : Vector3D;
		private var halfv : Vector3D;

		private var debugMode : Boolean = false;
		private var solidlMode : Boolean = false;

		private var shiftKeyIsDown : Boolean = false;
		private var mouseIsDown : Boolean = false;
		private var downPoint : Point = new Point();
		private var captureDrop : DropWater = null;

		private var fullscreenCheckbox : CheckBox;
		
		
		private var drops : Vector.<DropWater> = new Vector.<DropWater>;
		private var freep : int = -1;
		private const itemlimit : int = 50;

		public function soundSpectrumDropWaters() 
		{
			Wonderfl.capture_delay( 30 );
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, changeFullscreen);
			
			stage.doubleClickEnabled = true;
			
			//sceneImage = Bitmap(loaders[0].content).bitmapData;

			gradiant = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			buildGradiantBack(0x404040);

			backBmp = new Bitmap(gradiant);
			addChild(backBmp) ;
		
			blur.blurX = 4;
			blur.blurY = 4;
			
			track = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x000000);
			
			canvas = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xff000000);
			canvasBmp = new Bitmap(canvas);
			addChild(canvasBmp);
			
			addChild(uiBar);
			uiBar.graphics.clear();
			uiBar.graphics.beginFill(0, 0.7);
			uiBar.graphics.drawRect(0, 0, stage.stageWidth, 16);
			uiBar.graphics.endFill();
			uiBar.y = stage.stageHeight - 16;
			fullscreenCheckbox = new CheckBox( uiBar, 2, 2, "FULL SCREEN", fullscreenChecked);
			
			//addChild(new Stats());

			shader.data.src2.input = gradiant;
			light = new Vector3D( -0.2, 0.5, 0.8 );
			light.normalize();
			eye = new Vector3D( 0.0, 0.2, 1.0 ); // 少し斜めから見ている体にする
			eye.normalize();
			halfv = light.add(eye);
			halfv.normalize();
			shader.data.light.value = [ light.x, light.y, light.z];
	//		shader.data.eye.value = [ eye.x, eye.y, eye.z ];
			shader.data.halfv.value = [ halfv.x, halfv.y, halfv.z ];
			shader.data.reflection.value = [ -1.0 ];
			
			dropShadow.angle = Math.atan2( light.y, light.x ) * 180 / Math.PI;
			canvasBmp.filters = [ dropShadow ];
			
			for (var r : Number = 0; r <= MAX_RADIUS; r++) {
				dropimages[r] = new MetaCircle(r + 1, r > 10 ? 1.0 : r / 20 +0.5 );
			}
			DropWater.metaImages = dropimages;

			playSound("http://www.takasumi-nagai.com/soundfiles/sound001.mp3");
//			Security.allowDomain("locadlhost");	playSound("sound001.mp3"); // for local test
			
			newItem( 10, 30, 5);
			newItem( 40, 60, 3);
			newItem( 120, 20, 15);
			newItem( 200, 80, 10);
			newItem( 350, 40, 12);
		}
		
		private function buildGradiantBack(color : uint) : void
		{
			var grad : Shape = new Shape();
			grad.graphics.clear();
			var m : Matrix = new Matrix;
			m.rotate(Math.PI/2); // 100713 radianだったのね・・・
			grad.graphics.beginGradientFill(GradientType.LINEAR, [ 0xefefff, color], [1.0, 1.0], [0x00, 0xff], m);
			grad.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			grad.graphics.endFill();
			gradiant.draw(grad);
		}
		
		private function playSound(sndUrl:String):void
		{
			snd = new Sound();
			var context:SoundLoaderContext = new SoundLoaderContext(10,true);
			var req:URLRequest = new URLRequest(sndUrl);
			var sndChannel:SoundChannel=new SoundChannel();
			snd.load(req, context);
			sndChannel = snd.play(0, 9999);
		}
		
		private function changeFullscreen(e:Event):void 
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				fullscreenCheckbox.selected = true;
			} else {
				fullscreenCheckbox.selected = false;
			}
		}
		
		private function fullscreenChecked(e:Event) : void
		{
			if (!fullscreenCheckbox.selected) {
				stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				stage.displayState = StageDisplayState.NORMAL;
			} else {
				stage.fullScreenSourceRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		private function onClick(e : MouseEvent) : void
		{
			var r : int = Math.round(Math.random() * 0x80);
			var g : int = Math.round(Math.random() * 0x80);
			var b : int = Math.round(Math.random() * 0x80);
			buildGradiantBack((r << 16) | (g << 8) | b);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			if (e.charCode == 122) { // "Z"
				debugMode = !debugMode;
			} else if (e.charCode == 120) { // "X"
				solidlMode = !solidlMode;
				if (solidlMode) {
					shader.data.reflection.value = [ 0.0 ];
				} else {
					shader.data.reflection.value = [ -1.0 ];
				}
			} 
			shiftKeyIsDown = e.shiftKey;
		}
		private function keyUp(e:KeyboardEvent):void 
		{
			shiftKeyIsDown = e.shiftKey;
		}
		
		private function newItem( x : Number, y : Number, r : Number) : DropWater
		{
			var cnt : int = drops.length;
			var maxr : int = MAX_RADIUS;
			if (((itemlimit > 0) && cnt >= itemlimit) && (freep >= cnt-1)) return null;
			
			freep++;

			maxr = MAX_RADIUS - (freep & 0x7);
			if (r > maxr) r = maxr;
			
			if (freep == cnt) {
				drops[cnt] = new DropWater(x, y, r);
			} else {
				drops[freep].regenerate(x, y, r);
			}
			drops[freep].dropping = false;
			/*
			if (drop) {
				drops[freep].dx = 0;
				drops[freep].dy = Math.random()*20;
			}
			*/
			drops[freep].max_radius = maxr; // 20100713 最大径をばらつかせるために、インデックスを元に最大値を決定

			drops[freep].index = freep;
			drops[freep].visible = true;

			
			return drops[freep];
		}
		private function remove(index : int) : void
		{
			var cnt : int = drops.length;
			var temp : DropWater = drops[index];
			var lastp : int = freep;

			temp.visible = false;
			//removeChild(temp);
			if (lastp != index) {
				drops[index] = drops[lastp];
				drops[index].index = index;
				drops[lastp] = temp;
			}
			freep = lastp - 1;
			
		}

		private function enterFrame(e:Event):void 
		{
			var i : int, j : int, drop : DropWater;
			var bytes:ByteArray = new ByteArray();
			var lx : Number, ly : Number, change_light : Boolean = false;
			SoundMixer.computeSpectrum(bytes, FFTswitch, 0);

			for (i = 0; i < 2; i++)
			{
				for (j = 0; j < 256; j++)
				{
					drop = null;
					var rf:Number = bytes.readFloat();
					if (rf > 0.3) {
						drop = newItem( (i < 1 ? j + 256 : 255 - j) * (stage.stageWidth / 512), (rf - 0.3) * 1000, rf * MAX_RADIUS);
					}
					if (rf < 0) {
						lx = j * (stage.stageWidth / 256);
						ly = -rf * stage.stageHeight;
						change_light = true;
					}
					if (!drop && (Math.abs(rf) > 0.1)) {
						var index : uint = (j % freep) >> 0;
						if (index < freep) {
							drop = drops[index];
							if (!drop.dropping || (drop.dy < 1)) {
								var radius : Number = drop.radius +rf * drop.max_radius;
								if (radius < 5) radius = 5;
								if (radius < drop.max_radius) drop.radius = radius; else drop.radius = drop.max_radius;
								drop.dy = 1;// drop.radius + 1;
								drop.dropping = drop.dy > 0;
							}
						}
					}
					
				}
			}
			
			
			track.lock();

			if (shiftKeyIsDown) {
				lx = stage.mouseX;
				ly = stage.mouseY;
			}

			
			if (shiftKeyIsDown || change_light) {
				light.x = (stage.stageWidth / 2.0 - lx)/(stage.stageWidth / 2.0);
				light.y = (stage.stageHeight / 2.0 - ly)/(stage.stageHeight / 2.0);
				light.z = 1.0;
				light.normalize();
				halfv = light.add(eye);
				halfv.normalize();
				shader.data.light.value = [ light.x, light.y, light.z];
				shader.data.halfv.value = [ halfv.x, halfv.y, halfv.z ];
				dropShadow.angle = Math.atan2( light.y, light.x ) * 180 / Math.PI;
				canvasBmp.filters = [ dropShadow ];
			}
			
			// 水滴同士 引き合う
			for (i = freep; i >= 0; i--) {
				var dropA : DropWater = drops[i];
				
				// 分離したしずくはしばらくは融合しない
				if (dropA.stay > 0) {
					dropA.stay--;
				} else { // 融合チェック
					
					var cnt : int = 0;
					for (j = freep; j >= 0; j--) {
						if (j != i) {
							var dropB : DropWater = drops[j];
							if ((dropA.radius <= dropB.radius) && !dropB.fusion) {
								var dx : Number = Math.abs(dropA.x - dropB.x);
								var dy : Number = Math.abs(dropA.y - dropB.y);
								if (( dx < dropA.radius+dropB.radius) && (dy < dropA.radius+dropB.radius)) {
									var drop_dist : Number = Math.sqrt( dx * dx + dy * dy );
									
									var q : Number = dropA.radius / (dropA.radius + dropB.radius);
									var density : Number = (track.getPixel( dropA.x + (dropB.x - dropA.x) * q, dropA.y + (dropB.y - dropA.y) * q) & 0xff) / 255.0;
									if (density > 0.5) {
										dropA.fusion = (captureDrop != dropA);// && (dropA.radius < MAX_RADIUS);
										if (dropA.fusion && (dropB.radius < dropB.max_radius)) {
											dropB.radius += dropA.radius/4;
											if (dropB.radius >= dropB.max_radius*0.8) {
												dropB.dy = dropB.radius*Math.random();
												dropB.dropping = dropB.dy > 0;
											}
										}
									} else if ((density >= 0.09) && (drop_dist <= dropA.radius + dropB.radius)) {
										dropA.dx += (dropB.x - dropA.x) * dropB.radius / drop_dist;
										dropA.dy += (dropB.y - dropA.y) * dropB.radius / drop_dist;
										dropB.dx += (dropA.x - dropB.x) * dropA.radius / drop_dist / 2;
										if (dropA.y > dropB.y) {
											dropB.dy += (dropA.y - dropB.y) * dropA.radius / drop_dist/2;
										}
										cnt++;
										dropA.dropping = false;
									}
								}
							}
							if (cnt > 0) {
								dropA.dx /= cnt;
								dropA.dy /= cnt;
								dropB.dx /= cnt;
								dropB.dy /= cnt;
							}
						}
						
					}
				}
			}
			track.unlock();
			
			
			canvas.fillRect(canvas.rect, 0x000000);
			//canvas.copyPixels(track, track.rect, zeroPoint);
			
			for (i = freep; i >= 0; i--) {
				drop = drops[i];
				drop.x += drop.dx*0.4;
				drop.y += drop.dy*0.4;
				
				if (drop.radius >= drop.max_radius) {
					drop.dy = drop.radius;
					drop.dropping = true;
				}
				
				if (!drop.dropping) {
					drop.dx = 0;
					drop.dy = 0;
				} else {
					drop.dx = drop.dx*0.6;
					drop.dy = drop.dy*0.8;
					if ((drop.radius > 10) && (Math.random() > 0.99) && (drop.y-drop.lastSplit > 10) ) {
						var newdrop : DropWater = newItem( drop.x+Math.random()*drop.radius-drop.radius/2, drop.y, 3 + Math.random() * drop.radius / 10);
						if (newdrop) {
							newdrop.stay = 30;
							drop.lastSplit = drop.y;
						}
					}
				}
				// 垂れを表現するために、水滴の後ろに一回り小さい水滴(ghost)を追尾させる
				var befdx : Number = drop.x - drop.befpos.x;
				var befdy : Number = drop.y - drop.befpos.y;
				var movdist : Number = Math.sqrt(befdx * befdx + befdy * befdy);
				if (movdist > drop.radius / 2) {
					drop.befpos.x = drop.x - (drop.radius / 2)* befdx / movdist;
					drop.befpos.y = drop.y - (drop.radius / 2)* befdy / movdist;
				}
				if (drop.befpos.y > drop.y) { // ghostが下にあると不安定感があるのでghostより本体が下になるように
					drop.y += (drop.befpos.y - drop.y) / 16;
				}
				// render!
				for (var ghost : int = 0; ghost < 2; ghost++) {
					if (ghost && (drop.radius < 5)) continue;
					var xx : int, yy : int, rr : int;
					rr = drop.radius;
					if (drop.appear > 0) {
						rr /= drop.appear;
						drop.appear--;
					}
					
					if (ghost) {
						rr = rr * 0.8;
						xx = (drop.befpos.x  - rr) >> 0;
						yy = (drop.befpos.y  - rr) >> 0;
					} else {
						xx = (drop.x  - rr) >> 0;
						yy = (drop.y  - rr) >> 0;
					}
					
					tempPos.x = xx;
					tempPos.y = yy;
					tempRect.x = tempPos.x;
					tempRect.y = tempPos.y;
					tempRect.width = drop.width;
					tempRect.height = drop.height;
					
					dropimages[rr].workImage.copyPixels( canvas, tempRect, zeroPoint );
					
					metaNV.data.fore.input = dropimages[rr].densityImage;
					metaNV.data.level.value = [ rr/MAX_RADIUS ];
					dropimages[rr].workImage.applyFilter( dropimages[rr].workImage, dropimages[rr].workImage.rect, zeroPoint, metaNVfilter);
					canvas.copyPixels(dropimages[rr].workImage, dropimages[rr].workImage.rect, tempPos);
				}

				if (drop.fusion || drop.y > stage.stageWidth+drop.radius) {
					remove(i);
				}
				
			}
			
			track.copyPixels(canvas, canvas.rect, zeroPoint);
			
			if (!debugMode) canvas.applyFilter(canvas, canvas.rect, zeroPoint, filter);
		}
		
	}

}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shader;
import flash.geom.Point;
import flash.utils.ByteArray;
import mx.utils.Base64Decoder;

const MAX_RADIUS : Number = 25;

class DropWater extends Bitmap
{
	public static var metaImages : Vector.<MetaCircle>;
	
	public var index : int;
	private var _radius : int;
	public var max_radius : int = MAX_RADIUS;
	public var dx : Number;
	public var dy : Number;
	public var dropping : Boolean;
	public var fusion : Boolean;
	public var stay : uint = 0;
	public var lastSplit : Number;
	public var befpos : Point = new Point();
	public var appear : int = 0;
	
	//public var width : Number;
	//public var height : Number;
	
	public function DropWater(x : Number, y : Number, r : Number)
	{
		regenerate(x, y, r);
	}
	
	public function regenerate(x : Number, y : Number, r : Number) : void
	{
		this.x = x;
		this.y = y;
		befpos.x = x;
		befpos.y = y;
		lastSplit = y;
		this.dx = 0;
		this.dy = 0;
		radius = r;
		fusion = false;
		visible = true;
		dropping = false;
		stay = 0;
		appear = 2;
	}
	
	public function get radius():int { return _radius; }
	
	public function set radius(value:int):void 
	{
		_radius = value < MAX_RADIUS ? value : MAX_RADIUS;
		bitmapData = metaImages[_radius >> 0].densityImage;
	}
}

class MetaCircle
{
	private var radius : Number = 0;
	private var maxdensity : Number = 1;
	private var visibleRatio : Number = 0.8;
	public  var densityImage : BitmapData;
	public  var workImage : BitmapData;
	private var pos : Point =  new Point();
	
	public function MetaCircle(r : Number, density : Number )
	{
		radius = r;
		maxdensity = density;
		densityImage = new BitmapData(r * 2+1, r * 2+1, true, 0);
		workImage = densityImage.clone();
		
		render();
	}
	
	public function density(r : Number) : Number
	{
		if (r < radius) {
			var t : Number = (r / radius);
			return maxdensity * (1 - t) * (1 - t);
		} else {
			return 0.0;
		}
	}
	
	private function render() : void
	{
		var h : int = densityImage.height;
		var w : int = densityImage.width;
		var h2 : int = h / 2;
		var w2 : int = w / 2;
		densityImage.lock();
		for (var y : int = 0; y < h; y++ ) {
			var rad1 : Number = Math.acos( ((h2-y)/h2) );
			var spanr : Number = Math.sin( rad1 ) * h2;
			
			for (var x : int = 0; x < w; x++) {
				var r : Number = Math.sqrt( (w2 - x) * (w2 - x) + (h2 - y) * (h2 - y) );
				var a : uint = density(r) * 127;
				if (a > 0) {
					var rad2 : Number = Math.acos(( (w2 - x) / w2));
					// 右手座標系 +X=左  +Y=上  +Z=手前
					var ny : Number = (h2 - y);
					var nx : Number = (Math.cos( rad2 ) * spanr);
					var nz : Number = Math.sin( rad2 ) * spanr;
					var l : Number = Math.sqrt( nx * nx + ny * ny +nz * nz );
					var nv : int = (Math.max(0,Math.min(255, nx / l * 128 + 128)) << 16) | (Math.min(255, ny / l * 128 + 128) << 8) | a;// (Math.min(255, nz / l * 128 + 128));
					
					if (a > 0) {
						// 本当はAチャンネルで濃度をあらわしたいが、Aの値を変えるとPixelBenderで参照しているRGBも変わってしまうのでしかたなくBに濃度を格納
						densityImage.setPixel32(x, y, (255 << 24) | nv );
					}
				}
			}
		}
		densityImage.unlock();
	}
	
	public function drawTo(target : BitmapData, x : Number, y : Number) : void
	{
		pos.x = x-radius;
		pos.y = y-radius;
		target.copyPixels(densityImage, densityImage.rect, pos, null, null, true);
	}
}

class DropWaterShader extends Shader
{
	//[Embed(source = 'MetaWater.pbj', mimeType = 'application/octet-stream')]
	//private var pbj : Class;
	private var bcode : String =
"pQEAAACkCQBEcm9wV2F0ZXKgDG5hbWVzcGFjZQBqcC5saW1hY29uAKAMdmVuZG9yAEVTVgCgCHZl"+
"cnNpb24AAQCgDGRlc2NyaXB0aW9uAG1ldGF3YXRlcgChAQIAAAxfT3V0Q29vcmQAoQEDAQAObGln"+
"aHQAoQEDAgAOaGFsZnYAoQEBAAACcmVmbGVjdGlvbgCiAWRlZmF1bHRWYWx1ZQAAAAAAowAEc3Jj"+
"AKMBBHNyYzIAoQIEAwAPZHN0ADIEAIA/gAAAMgQAQD+AAAAdBAAxBAAQADIAABAAAAAAAgAAEAIA"+
"AAAdBQCAAADAADIAABAAAAAAAgAAEAIAQAAdBQBAAADAAB0FACACAIAAHQYA4gUAGAAwBQDxAAAQ"+
"AB0HAPMFABsAMgAAED24UewqAAAQBwCAAB0BgIAAgAAANAAAAAGAAAAyAAAQPwAAAB0EAMEHABAA"+
"AgQAwQAA8AAyAAAQQAAAAB0FAMEEABAAAwUAwQAA8AAdCADBBQAQADIAABA/gAAAHQEAEAgAAAAD"+
"AQAQCAAAAB0CABAAAMAAAgIAEAEAwAAdAAAQCABAAAMAABAIAEAAHQEAEAIAwAACAQAQAADAABYA"+
"ABABAMAAHQgAIAAAwAAdBQDiAgAYACYFAOIIABgAMgAAEEPIAAAdAQAQBQAAAAcBABAAAMAAHQAA"+
"EAEAwAAdBQDiAQAYACYFAOIIABgAHQEAEAUAAAAyAgAQAAAAACkAACACAMAAHQGAQACAAAA0AAAA"+
"AYBAADICABBDyAAAHQQAwQgAEAADBADBAgDwAB0FAMEAABAAAQUAwQQAEAAdBADBBQAQADICABBD"+
"6IAAKgIAEAQAAAAdAYAgAIAAADQAAAABgIAAMgIAEEPogAAdBQCABAAAAAIFAIACAMAAHQQAgAUA"+
"AAA2AAAAAAAAADICABAAAAAAKgQAgAIAwAAdAYAgAIAAADQAAAABgIAAMgIAEEPogAAdBQCABAAA"+
"AAEFAIACAMAAHQQAgAUAAAA2AAAAAAAAADICABBD6IAAKgIAEAQAQAAdAYAgAIAAADQAAAABgIAA"+
"MgQAQEPoAAA2AAAAAAAAADICABAAAAAAKgQAQAIAwAAdAYAgAIAAADQAAAABgIAAMgQAQAAAAAA2"+
"AAAAAAAAADAFAPEEABABHQkA8wUAGwA1AAAAAAAAADIJAIA/AAAAMgkAQD8AAAAyCQAgPwAAADIJ"+
"ABA/AAAANgAAAAAAAAAdBQDiBgAYACYFAOIIABgAMgIAEEEgAAAdBQBABQAAAAcFAEACAMAAHQIA"+
"EAUAQAAdBQDiCQAYAAMFAOIBAPwAHQoA4gAA/AABCgDiBQAYADIFAIA+zMzNMgUAQD8AAAAyBQAg"+
"PwAAAB0LAOIFABgAAQsA4gkAGAAdBQDiCwAYAAMFAOICAPwAHQsA4goAGAABCwDiBQAYAB0DAOIL"+
"ABgAMgUAgD+AAAAyBQBAPczMzR0FACAIAEAAAgUAIAUAQAAyBQBAQAAAAB0FABAFAIAAAwUAEAUA"+
"QAAdBQBABQAAAAIFAEAFAMAAHQUAgAUAQAAyBQBAPczMzSoFAEAHAIAAHQGAQACAAAA0AAAAAYBA"+
"ADIFAEA9zMzNKgUAQAgAQAAdAYAgAIAAADQAAAABgIAAHQUAQAUAAAABBQBAAADAAB0DABAFAEAA"+
"NQAAAAAAAAAyAwAQP4AAADYAAAAAAAAANQAAAAAAAAAyBQBAPbhR7CoFAEAHAIAAHQGAIACAAAA0"+
"AAAAAYCAADIFAEA9zMzNKgUAQAgAQAAdAYAQAIAAADQAAAABgMAAMgUAQD24UewdBQAgBwCAAAIF"+
"ACAFAEAAMgUAQELIAAAdBQAQBQCAAAMFABAFAEAAHQUAQAUAwAADBQBABQAAAB0DABAFAEAANQAA"+
"AAAAAAAyBQBAPbhR7B0FACAHAIAAAgUAIAUAQAAyBQBAQsgAAB0FABAFAIAAAwUAEAUAQAAdAwAQ"+
"BQDAADYAAAAAAAAANgAAAAAAAAA2AAAAAAAAADUAAAAAAAAAMgMAEAAAAAA2AAAAAAAAAA==";	
	
	public function DropWaterShader()
	{
		/*
		var code : ByteArray = (new pbj()) as ByteArray;
		super( code );
		*/
		var dec : Base64Decoder = new Base64Decoder();
		dec.decode( bcode );
		super(dec.toByteArray());
		
	}
}

class MetaNVShader extends Shader
{
	//[Embed(source = 'metaNV.pbj', mimeType = 'application/octet-stream')]
	//private var pbj : Class;
	private var bcode : String = 
"pQEAAACkCQBEcm9wV2F0ZXKgDG5hbWVzcGFjZQBqcC5saW1hY29uAKAMdmVuZG9yAEVTVgCgCHZl"+
"cnNpb24AAgCgDGRlc2NyaXB0aW9uAG1ldGFOVgChAQIAAAxfT3V0Q29vcmQAoQEBAAACbGV2ZWwA"+
"owAEYmFjawCjAQRmb3JlAKECBAEAD2Rlc3QAHQIAwQAAEAAwAwDxAgAQAR0EAPMDABsAMAMA8QIA"+
"EAAdBQDzAwAbAB0AABAEAIAAHQIAIAUAgAAdAgAQAADAAAECABACAIAAHQMAgAIAwAAdAgAQBADA"+
"AAECABAFAMAAHQEAEAIAwAAyAgAQAAAAACoCABAEAMAAHQGAgACAAAA0AAAAAYAAADICABA/AAAA"+
"HQMAYQQAEAACAwBhAgDwADICABBAAAAAHQYAwQMAYAADBgDBAgDwAB0EAMEGABAAMgIAED+AAAAd"+
"AwBABAAAAAMDAEAEAAAAHQMAIAIAwAACAwAgAwBAAB0CABAEAEAAAwIAEAQAQAAdAwBAAwCAAAID"+
"AEACAMAAFgIAEAMAQAAdBAAgAgDAADICABAAAAAAKgIAEAUAwAAdAYBAAIAAADQAAAABgEAAMgIA"+
"ED8AAAAdAwBhBQAQAAIDAGECAPAAMgIAEEAAAAAdBgDBAwBgAAMGAMECAPAAHQUAwQYAEAAyAgAQ"+
"P4AAAB0DAEAFAAAAAwMAQAUAAAAdAwAgAgDAAAIDACADAEAAHQIAEAUAQAADAgAQBQBAAB0DAEAD"+
"AIAAAgMAQAIAwAAWAgAQAwBAAB0FACACAMAANQAAAAAAAAAyBQCAAAAAADIFAEAAAAAAMgUAID+A"+
"AAA2AAAAAAAAAB0DAHIEABgAAwMAcgAA/AAdBgDiAwBsAAMGAOIAAKgAHQMAcgUAGAADAwByAgCo"+
"AB0HAOIGABgAAQcA4gMAbAAdAwByBwAYACQCABIDAGwAHQYAgAIAwAAEBgByBgAAAAMGAHIDAGwA"+
"HQMAcgYAbAAyAgAQQAAAAAQGAHICAPwAAwYAcgMAbAAyAgAQPwAAAB0HAOIGAGwAAQcA4gIA/AAd"+
"AwByBwAYAB0GAEADAEAAHQYAIAMAgAAdBgAQAwAAAB0BAOIGAGwANQAAAAAAAAAdAQDiBQAYADYA"+
"AAAAAAAA";

	public function MetaNVShader()
	{
		/*
		var code : ByteArray = (new pbj()) as ByteArray;
		super( code );
		*/
		var dec : Base64Decoder = new Base64Decoder();
		dec.decode( bcode );
		super(dec.toByteArray());

		
	}
}
/*
<languageVersion : 1.0;>

kernel MetaWater
<   namespace : "jp.limacon";
    vendor : "ESV";
    version : 1;
    description : "metawater"; >
{

#if AIF_FLASH_TARGET
   parameter float3 eye;
   parameter float3 light;
   parameter float3 halfv;
#else
   parameter float3 eye
   <
        defaultValue : float3(0,0.2,1.0);
   >;
   parameter float3 light
   <
        defaultValue : float3(-0.2, 0.5, 0.8);
   >;
#endif
   parameter float reflection
   <
        defaultValue : float(0.0);
   >;
   input image4 src;
   input image4 src2;
   
   output pixel4 dst;
   
   
   void evaluatePixel()
   {
#if !AIF_FLASH_TARGET
        float3 halfv = normalize(eye+light);
#endif
        float2 singlePixel = pixelSize(src);
        float3 invlight = float3(-halfv.x, -halfv.y, halfv.z);
        
        float4 pix = sampleNearest(src, outCoord());
        if (pix.z > 0.09) {
            
            float3 nv;
            nv.xy = (pix.xy-0.5)*2.0;
            nv.z = sqrt( 1.0 - nv.x*nv.x - nv.y*nv.y );

            float dotspec = pow(dot(halfv.xyz, nv.xyz),400.0);//pow( max(0.0, dot(halfv.xyz, nv) ), 64.0);
            float dotdi = dot( light, nv ) ; // !!! if i use dot(),  blink!???

            float2 backpos;
            float4 color;
            
            if (reflection != 0.0) {
                backpos = outCoord()+nv.xy*400.0;
                if (backpos.x > 465.0) backpos.x = backpos.x - 465.0;
                if (backpos.x < 0.0) backpos.x = backpos.x + 465.0;
                if (backpos.y > 465.0) backpos.y = 464.0;//backpos.y - 465.0;
                if (backpos.y < 0.0) backpos.y = 0.0;//backpos.y + 465.0;           
                color = sampleNearest(src2, backpos);
                
                
            } else {
                color = float4(0.5, 0.5, 0.5, 0.5);
            }
            
            float refl = pow(dot( invlight, nv ),10.0);//(0.9-dotdi)*2.0;

            dst.rgb = dotspec + color.rgb*dotdi + (float3(0.4,0.5,0.5)+color.rgb)*refl;// + float3(0.8,1.0,1.0)*refl;
            
            //dst.rgb = float3(dot2, dot2, dot2);
            float fade = 1.0-(nv.y-0.1)*2.0;
            if ((pix.z > 0.1)){// || (nv.y > 0.1)) {
                if (nv.y > 0.1) dst.a = fade + dotspec;
                else dst.a = 1.0;
            } else if (pix.z > 0.09) { // pseoud AA
                if (nv.y > 0.1) dst.a = (pix.z-0.09)*100.0*fade;
                else dst.a = (pix.z-0.09)*100.0;
            }
        } else {
          dst.a = 0.0;
        }
    }
}
<languageVersion : 1.0;>

kernel MetaNV
<   namespace : "jp.limacon";
    vendor : "ESV";
    version : 2;
    description : "metaNV"; >
{
   parameter float level;
   input image4 back;
   input image4 fore;
   
   output pixel4 dest;
   
   
   void evaluatePixel()
   {
        float2 curPos = outCoord();
        pixel4 f0 = sampleNearest(fore, curPos);
        pixel4 b0 = sampleNearest(back, curPos);
        
        float  fd = f0.z;
        float  bd = b0.z;
        
        // .a=height
        // .r=norm.x
        // .g=norm.y
        // .b=density
        
        float density = fd + bd;
        
        dest.a = f0.a+b0.a;
        if (f0.a > 0.0) {
            f0.xy = (f0.xy-0.5)*2.0;
            f0.z = sqrt( 1.0 - f0.x*f0.x - f0.y*f0.y);

            if (b0.a > 0.0) {
                b0.xy = (b0.xy-0.5)*2.0;
                b0.z = sqrt( 1.0 - b0.x*b0.x - b0.y*b0.y);
            } else {
                b0.xyz = float3(0.0, 0.0, 1.0);               
            }
        
            float3 v = f0.xyz*fd*level + b0.xyz*bd;//(f0.xyz-0.5)*2.0 + (b0.xyz-0.5)*2.0;//(f0.xyz*2.0-1.0) + (b0.xyz*2.0-1.0);
            float l = length( v );
            v = v/l;
            v = v/2.0+0.5;

            dest.rgb = float3(v.x, v.y, density);//float3(density,density,density);// density);
        } else {
            dest.rgb = b0.rgb;
        }
        
   }
}

*/
