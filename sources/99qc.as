// forked from fladdict's 20万個ぱーてぃくる 途中で飽きたけど 25万個は狙えるはず
// forked from beinteractive's forked from: 10万個ぱーてぃくる - 軽く高速化
// forked from bkzen's 10万個ぱーてぃくる
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
class TestMain
{
	private var w: int;
	private var h: int;
	private var mw: int;
	private var mh: int;
	public var view: Bitmap;
	private var bmpData: BitmapData;
	private var forceMap: BitmapData;
        private var forceCache: Array;
	private var randomSeed: int;
	private var particles: Particle;
	private var num: int;
	private var color: uint = 0xF0F0FF;
	private var count: int = 0;
	private var colorTr: ColorTransform;

        private var cnt:int = 0;

        //forcemap を getPixel で計算すると重いので、色はキャッシュする。
        private var forceVector:Vector.<int>;
        private var fxVector:Vector.<int>;
        private var fyVector:Vector.<int>;
	
	public function TestMain(w: int, h: int, numOfParticles: int)
	{
		this.w = w;
		mw = w >> 1;
		this.h = h;
		mh = h >> 1;
		bmpData = new BitmapData(w, h, false, 0x00000000);
		forceMap = new BitmapData(mw, mh, false);
		
                
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
                        p.rnd = (Math.random()*0.2 + 0.9) * 0.003;
			prev.next = p;
			prev = p;
		}
		colorTr = new ColorTransform(1, 1, 1, 1, -20, -20, -20);

                change();
                
                
	}
	// 描画、マウスの判定を後で追加予定
	public function draw(mouseX: Number, mouseY: Number): void
	{
                cnt++;
                if(cnt>100){
                   change();
                   cnt = 0;
                }
		var p: Particle = particles;
		var col: uint;
                var forceIndex:int;
		bmpData.lock();
		bmpData.colorTransform(bmpData.rect, colorTr);
		while ((p = p.next) != null)
		{
                        forceIndex = (p.y>>2) * mw + (p.x>>2);

                        //2万個以上はパーティクルの座標が重なった場合の対策をしないと、
                        //まったく同じ動きをするので意味がないので p.rndに乱数を持たせて、力に揺らぎを与える。                     
			p.vx = p.vx * 0.99 + fxVector[forceIndex] * p.rnd;
                        p.vy = p.vy * 0.99 + fyVector[forceIndex] * p.rnd;
                        p.x += p.vx;
			p.y += p.vy;

			if (p.x < 0) p.x += w;
			else if (p.x >= w) p.x -= w;
			if (p.y < 0) p.y += h;
			else if (p.y >= h) p.y -= h;
			bmpData.setPixel(p.x >> 0, p.y >> 0, p.col);
		}
		bmpData.unlock();
	}
	
	public function change(): void
	{
                /**
                この処理は重いので、本当は次のforcemapの生成をバックグラウンドで少しづつ行って、完成したら切り替えるようにする。
                */
		forceMap.perlinNoise(128, 128, 8, Math.random() * 0xFFFF, false, true, 7, false);

                if(!forceVector){
                    fxVector = new Vector.<int>(mw*mh,true);
                    fyVector = new Vector.<int>(mw*mh,true);
                }
                //force mapをキャッシュする
                for(var yy:int=0; yy<mh; yy++){
                    for(var xx:int=0; xx<mw; xx++){
                        var col:int = forceMap.getPixel(xx,yy);
                        var pos:int = yy*mw+xx;
                        fxVector[pos] = (col>>16&0xff)-128;
                        fyVector[pos] = (col>>8&0xff)-128;
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
        public var col:int= Math.random()*256*256*256;
	public var next: Particle;
	
	public function Particle()
	{
		
	}
}

