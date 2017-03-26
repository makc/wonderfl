// forked from fladdict's 250000 particle flow shimulation
// forked from fladdict's 20万個ぱーてぃくる 途中で飽きたけど 25万個は狙えるはず
// forked from beinteractive's forked from: 10万個ぱーてぃくる - 軽く高速化
// forked from bkzen's 10万個ぱーてぃくる

/*
http://www.be-interactive.org/index.php?itemid=458
↓
http://blog.joa-ebert.com/2009/04/03/massive-amounts-of-3d-particles-without-alchemy-and-pixelbender/
↓
http://www.joa-ebert.com/files/swf/pure/Main.as

の流れでBitmapData.setVector
*/

package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import net.hires.debug.Stats;
	
	/**
	 * なんかいっぱい動かすテスト
	 * 洗濯機みたいになってます。
	 * @author jc at bk-zen.com
	 */
	[SWF(backgroundColor = "0x000000", frameRate = "30")]
	public class Test3 extends Sprite
	{
		protected const NUM_OF_PARTICLES: int = 250000;
		private var main: TestMain;
		
		public function Test3() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//
			main = new TestMain(stage.stageWidth, stage.stageHeight, NUM_OF_PARTICLES);
			addChild(main.view);
			addChild(new Stats());
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, onEnter);
			
		}
		
		private function onClick(e:MouseEvent):void 
		{
			main.change();
		}
		
		private function onEnter(e:Event):void 
		{
			main.draw(mouseX, mouseY);
		}
		// りサイズ （未実装）
		private function onResize(e:Event):void 
		{
			main.resize(stage.stageWidth, stage.stageHeight);
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.utils.ByteArray;
import __AS3__.vec.Vector;
class TestMain
{
	private var w: int;
	private var h: int;
	private var mw: int;
	private var mh: int;
	public var view: Bitmap;
	private var bmpData: BitmapData;
	private var buffer: Vector.<uint>;
	private var forceMap: BitmapData;
	private var randomSeed: int;
	private var particles: Particle;
	private var num: int;
	private var color: uint = 0xF0F0FF;
	private var count: int = 0;
	private var colorTr: ColorTransform;
	private var fxVector:Vector.<int>;
	private var fyVector:Vector.<int>;
	
	public function TestMain(w: int, h: int, numOfParticles: int)
	{
		this.w = w;
		mw = w >> 1;
		this.h = h;
		mh = h >> 1;
		bmpData = new BitmapData(w, h, false, 0x00000000);
		buffer = new Vector.<uint>(w * h, true);
		forceMap = new BitmapData(mw, mh, false);
		forceMap.perlinNoise(mw >> 1, mh >> 1, 4, Math.random() * 0xFFFF, false, true, 3);
		view = new Bitmap(bmpData);
		num = numOfParticles;
		var i: int;
		var prev: Particle = particles = new Particle();
		var p: Particle;
		while (++i <= num)
		{
			p = new Particle();
			p.x = Math.random() * w;
			p.y = Math.random() * h;
			p.rnd = Math.random() * 0.003 + 0.003;
			prev.next = p;
			prev = p;
		}
		colorTr = new ColorTransform(1, 1, 1, 1, -32, -16, -16);
		fxVector = new Vector.<int>(mw * mh, true);
		fyVector = new Vector.<int>(mw * mh, true);
		
		change();
	}
	
	// 描画、マウスの判定を後で追加予定
	public function draw(mouseX: Number, mouseY: Number): void
	{
		var b: Vector.<uint> = buffer;
		var p: Particle = particles;
		var fx: Vector.<int> = fxVector;
		var fy: Vector.<int> = fyVector;
		
		var c: uint;
		var fi: uint;
		var bi: uint;
		
		var rnd: Number;
		
		var n: int = b.length;
		while (--n > -1) b[n] = 0;
		
		while ((p = p.next) != null)
		{
			fi = (p.y >> 2) * mw + (p.x >> 2);
			rnd = p.rnd;
			p.x += (p.vx = p.vx * 0.96 + fx[fi] * rnd);
			p.y += (p.vy = p.vy * 0.96 + fy[fi] * rnd);
			(p.x < 0) ? p.x += w :
			(p.x >= w) ? p.x -= w : 0;
			(p.y < 0) ? p.y += h :
			(p.y >= h) ? p.y -= h : 0;
			
			bi = (p.y >> 0) * w + (p.x >> 0);
			b[bi] = ((c = b[bi] + 0x303030) > 0xffffff) ? 0xffffff : c;
		}
		
		bmpData.lock();
		bmpData.setVector(bmpData.rect, b);
		bmpData.unlock();
	}
	
	public function change(): void
	{
		/**
		この処理は重いので、本当は次のforcemapの生成をバックグラウンドで少しづつ行って、完成したら切り替えるようにする。
		*/
		var base: uint = 32 * (Math.random() * 2 + 1);
		forceMap.perlinNoise(base, base, 4, Math.random() * 0xFFFF, false, true, 7);

		//force mapをキャッシュする
		for(var yy:int = 0; yy < mh; yy++){
			for(var xx:int = 0; xx < mw; xx++){
				var col:int = forceMap.getPixel(xx, yy);
				var pos:int = yy * mw + xx;
				fxVector[pos] = (col >> 16 & 0xff) - 128;
				fyVector[pos] = (col >> 8 & 0xff) - 128;
			}
		}
	}
	
	public function resize(w: Number, h: Number): void
	{
		this.w = w;
		this.h = h;
		if (bmpData) 
		{
			bmpData.dispose();
		}
		bmpData = new BitmapData(w, h, false, 0x00000000);
		view.bitmapData = bmpData;
	}
}

class Particle
{
	public var x: Number = 0;
	public var y: Number = 0;
	public var vx: Number = 0;
	public var vy: Number = 0;
	public var rnd: Number = 0;
	public var next: Particle;
	
	public function Particle()
	{
		
	}
}