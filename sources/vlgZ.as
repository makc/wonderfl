//
// ＜ミツバチを歩かせたくなった＞
//
// 虫好きには可愛く、虫嫌いの方には気持ち悪くみえれば成功
//
//
// IKをまじめに実装したことが無かったので、 既存の実装は見ずに、
// 「与えられた子の位置から親までの間接の角度を求める」という条件で実装。
// 車輪の再発明
//
//
// 試行錯誤の工程がわかりやすくなるように、各ステップのコードは殆どそのままに残す。
// wonderflでは500行を超えると長いほうだと思うが、今回は
// 総行数1500行を超えたので、試行錯誤部分をさっくり削除したいけど・・・
//
// STEP1. まずはFKで大体の間接角度を決めて、それをIKで補正するというアプローチを考える
// STEP2. 足が接地している期間を適当に決め、その期間だけIKで間接角度を決めるようにする。
// 
//
// 今回のコードの問題点：間接角度のconstraintsができない。間接1つづつの稼動範囲円で
// 新しい関節位置を求めるのではなくて、constraints付きの間接群を一つまとめにした稼動範囲
// を考慮する必要ありか？
//
// 20100428 バグ修正：間接角度が0度になったときにacos()がNanになる場合があった

package 
{
	import com.actionsnippet.qbox.QuickBox2D;
	import com.bit101.components.CheckBox;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	import frocessing.core.F5BitmapData2D;
	
	/**
	 * ...
	 * @author TMaeda
	 */
    [SWF(width=465,height=465,backgroundColor=0xcccccc,frameRate=60)]
	public class MyFirstIK extends Sprite 
	{
		private var step : int = 0;
		private var txt  : TextField = new TextField();
		private var infotxt : TextField = new TextField();
		private var legs : Vector.<Leg> = new Vector.<Leg>;
		private var canvas: F5BitmapData2D;
		
		private var nextButton : PushButton;
		private var autoCheckbox : CheckBox;
		private var fullscreenCheckbox : CheckBox;
		
		private var state : int = 0;
		private var abdomenState : int = 0;
		private var moveDx : int = 0;
		private var moveDy : int = 0;
		private var scrollDy : int = 0;
		
		private var temppos1 : Point = new Point();
		private var temppos2 : Point = new Point();
		
		private var mouseIsDown : Boolean = false;
		
		private var blur : BlurFilter = new BlurFilter(4, 4, 1);
		private var zeroPoint : Point = new Point(0, 0);
		
		// behavior
		private var walk : WalkBehavior;
		private var fly : FlyingBehavior;
		
		private var stepFuncs : Array = [ 
			{ init:initStep0, frame:frameStep0 },  
			{ init:initFKWalk, frame:frameFKWalk },
			{ init:initIKTest, frame:frameIKTest },
			{ init:initIKFinish, frame:frameIKFinish }
		];
		
		public function MyFirstIK()
		{
            Wonderfl.capture_delay( 50 );
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init( e : Event = null) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, changeFullscreen);
		
			canvas = new F5BitmapData2D(stage.stageWidth, stage.stageHeight, true, 0xff808080);
			addChild(new Bitmap(canvas.bitmapData) );
			
			nextButton =  new PushButton(this, stage.stageWidth - 128, 0, "NEXT>>", nextButtonClick);
			autoCheckbox = new CheckBox(this, 0, 0, "AUTO");
			autoCheckbox.enabled = false;
			fullscreenCheckbox = new CheckBox(this, 0, 0, "FULLSCREEN", fullscreenChecked);
			fullscreenCheckbox.y = stage.stageHeight-fullscreenCheckbox.height;
			autoCheckbox.y = stage.stageHeight-fullscreenCheckbox.height-autoCheckbox.height;
			
			txt.autoSize = TextFieldAutoSize.LEFT;
			addChild(txt);
			infotxt.text = "";
			infotxt.autoSize = TextFieldAutoSize.LEFT;
			addChild(infotxt);
			goStep(0);
			
			// 脚構造をセットアップ
			// front
			legs[0] = new Leg([ { x:8, y: -8, len:16, rotate: -30 } , { len:16, rotate:45 }, { len:24, rotate: -90 } ]);
			legs[1] = new Leg([ { x: -8, y: -8, len:16, rotate: -150 } , { len:16, rotate:-45 }, { len:24, rotate:90 } ]);
			
			// middle
			legs[2] = new Leg([ { x:16, y: 0, len:32, rotate: 15 } , { len:24, rotate: -45 }, { len:8, rotate: -20 } ]);
			legs[3] = new Leg([ { x: -16, y: 0, len:32, rotate: 165 } , { len:24, rotate:45 }, { len:8, rotate:20 } ]);
			//
			// last
			legs[4] = new Leg([ { x:8, y: 8, len:16, rotate: 45 } , { len:24, rotate: -30 }, { len:56, rotate: 45 } ]);
			legs[5] = new Leg([ { x:-8, y: 8, len:16, rotate: 135 } , { len:24, rotate:30 }, { len:56, rotate:-45 } ]);
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
		

		private function nextButtonClick(e:Event) : void
		{
			goStep(step + 1);
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			mouseIsDown = false;
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			mouseIsDown = true;
		}
		private function goStep(no : int) : void
		{
			if (no < stepFuncs.length) step = no;
			
			stepFuncs[ step ].init.call();
		}
		
		private function enterFrame(e:Event):void 
		{
			canvas.bitmapData.fillRect(canvas.bitmapData.rect, 0xff808080);
			stepFuncs[ step ].frame.call();
		}
		
		// step0
		private function initStep0() : void
		{
			txt.text = "STEP 0.まずは足の構造をセットアップ";

			state = 0;
			
		}

		private function frameStep0() : void
		{
			var legcnt : int = legs.length;

			state++;
			canvas.beginDraw();
			canvas.moveTo(stage.stageWidth / 2, 0);
			canvas.lineTo(stage.stageWidth / 2, stage.stageHeight);
			canvas.moveTo(0, stage.stageHeight / 2);
			canvas.lineTo(stage.stageWidth , stage.stageHeight / 2);

			drawBody(0,0,0,0,0);
			
			canvas.stroke(0, 0, 0, 0xff);
			var progress : int = 0;
			for (var i : int = 0; i < legcnt; i++) {
				var segcnt : int = legs[i].items.length;
				legs[i].computeFK(stage.stageWidth / 2, stage.stageHeight / 2, 0);
				canvas.moveTo(legs[i].root.x, legs[i].root.y);
				for (var j : int = 0; j < segcnt; j++) {
					if (progress*10 > state) continue;
					canvas.lineTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y);
					canvas.circle(legs[i].items[j].joint.x, legs[i].items[j].joint.y,4);
					canvas.moveTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y);
					progress++;
				}
			}
			canvas.endDraw();
			
			if (state > 60 * 5) goStep(step + 1);
			
		}
		private function walkWave(norm : Number) : Number
		{
			//return Math.sin(norm * Math.PI * 2);
			
			if ((norm < 0.25) && (norm > 0.75)) return Math.sin(norm * Math.PI * 2);
			else if (norm < 0.5) return  Math.sin( (0.25 + (norm - 0.25) * 2) * Math.PI * 2);
			else return -1;
		}
		// step1: walk motion by FK
		private function initFKWalk() : void
		{
			txt.text = "STEP 1.基本の歩行モーションをつける\n赤丸は接地タイミングを表現";
			state = 0;
			moveDy = 0;
			scrollDy = 0;
		}
		
		private function frameFKWalk() : void
		{
			var legcnt : int = legs.length;

			if (!mouseIsDown) {
				state++;
			}
			if (state > 60 * 2) {
				moveDy--;
				infotxt.text = "FKだけのモーションだとやっぱりすり足";
				infotxt.x = 0;
				infotxt.y = 100;
			} if (state > 60 * 10) {
				goStep(step + 1);
				return;
			}
			canvas.beginDraw();
			canvas.stroke(0xff000000);
			canvas.moveTo(stage.stageWidth / 2, 0);
			canvas.lineTo(stage.stageWidth / 2, stage.stageHeight);
			canvas.moveTo(0, stage.stageHeight / 2);
			canvas.lineTo(stage.stageWidth , stage.stageHeight / 2);

			canvas.stroke(0, 0, 0, 0xff);
			
			// 試行錯誤過程を説明するためほぼ同じコードが3箇所ある。この部分は最終的には使われない
			var nr : Number = 0;
			var rad : Number = 0;
			for (var i : int = 0; i < legcnt; i++) {
				legs[i].computeFK(stage.stageWidth / 2, stage.stageHeight / 2 + moveDy, 0);

				var segcnt : int = legs[i].items.length;
				switch (i) {
					case 0:
					case 1:
					{
						nr = (((state * 10) % 360) / 360) + 0.25;
						if (i == 0) {
							legs[i].items[2].IK = (nr > 0.75) || (nr < 0.25);
						} else {
							legs[i].items[2].IK = (nr < 0.75) && (nr > 0.25);
						}

						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (-90+(i==1?-60:60)+Math.sin(rad)*20)* Math.PI / 180;

						nr = nr+0.5;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==1?-45:45)-Math.sin(rad)*20)* Math.PI / 180;
						legs[i].items[2].rotate = ((i==1?90:-90)+Math.sin(rad)*20)* Math.PI / 180;
						break;
					}
					case 2:
					case 3:
					{
						nr = (((state * 10) % 360) / 360) + 0.5;
						if (i == 2) {
							legs[i].items[2].IK = (nr < 1.3) && (nr > 0.8);
						} else {
							legs[i].items[2].IK = (nr > 1.3) || (nr < 0.8);
						}

						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (90+(i==3?95:-95)+Math.sin(rad)*20)* Math.PI / 180;
						nr = nr + 0.75;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==3?-60:60)-Math.sin(rad)*40)* Math.PI / 180;
						//legs[i].items[2].rotate = (10+Math.sin(state/10)*10)* Math.PI / 180;
						break;
					}
					case 4:
					case 5:
					{
						nr = (((state * 10) % 360) / 360);
						if (i == 4) {
							legs[i].items[2].IK = (nr < 0.3) || (nr > 0.8);
						} else {
							legs[i].items[2].IK = (nr > 0.3) && (nr < 0.8);
						}
						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (90+(i==5?55:-55)-Math.sin(rad)*20)* Math.PI / 180;
						nr = nr + 0.5;// 75;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==5?30:-30)-Math.sin(rad)*40)* Math.PI / 180;
						legs[i].items[2].rotate = ((i==5?-90:90)+Math.sin(rad)*20)* Math.PI / 180;
						break;
					}
				}
				
				canvas.stroke(0xff000000);
				canvas.moveTo(legs[i].root.x, legs[i].root.y);
				for (var j : int = 0; j < segcnt; j++) {
					canvas.lineTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y);
					if (legs[i].items[j].IK) canvas.stroke(0xffff0000);
					else canvas.stroke(0xff000000);
					canvas.circle(legs[i].items[j].joint.x, legs[i].items[j].joint.y, 4);
					canvas.moveTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y);
				}
			}
			drawBody(0,moveDy,0,0,0);

			canvas.endDraw();
		}
		
		// step2. IKtest
		private function initIKTest() : void
		{
			txt.text = "STEP 2.IKで動かす方法を模索。\n  前足で説明";
			state = 0;
			moveDy = 0;
			scrollDy = 0;
		}
		
		
		private var slowCnt : int = 0;
		private var lastMoveDy : int = 0;
		private var lastMoveDx : int = 0;
		private var bodyAngle : Number = 0;
		private function frameIKTest() : void
		{
			var legcnt : int = legs.length;
			var i : int, j : int, thi : Number, a : Number;

			if (!mouseIsDown) {
				if (state < 6*10) {
					slowCnt = (slowCnt + 1) % 10;
				} else slowCnt = 0;
				
				if (slowCnt == 0) {
					state++;
					moveDy-=2;
					if (state < 60*10) {
						scrollDy += 2;
					}
				}
			}
			if (state > 60 * 13) {
				goStep(step + 1);
				return;
			}
			
			canvas.beginDraw();
			canvas.stroke(0xff606060);
			canvas.moveTo(stage.stageWidth / 2, 0);
			canvas.lineTo(stage.stageWidth / 2, stage.stageHeight);
			for (var grid : int = scrollDy; grid < scrollDy+stage.stageHeight; grid += 15) {
				canvas.moveTo(0, grid % stage.stageHeight);
				canvas.lineTo(stage.stageWidth , grid % stage.stageHeight);
			}

			canvas.stroke(0, 0, 0, 0xff);
			// 試行錯誤過程を説明するためほぼ同じコードが3箇所ある。この部分は最終的には使われない
			var nr : Number = 0;
			var rad : Number = 0;
			var befground : Boolean = false;
			for (i = 0; i < legcnt; i++) {
				legs[i].computeFK(stage.stageWidth / 2, stage.stageHeight / 2 + moveDy, 0);

				var segcnt : int = legs[i].items.length;
				if (legs[i].items[2].IK) {
					canvas.stroke(0xff606060);
					canvas.noFill();
					
					// 各セグメントの長さが変わらないようになるジョイント(関節位置)を求める。(=先端を中心に、セグメントの長さを半径とする円上にジョイントがくる)
					
					// << 先端セグメントの位置を算出>>
					
					// 先端部分を中心として、先端部分(第3)のセグメントの長さを半径とする円と
					if (i == 1) canvas.circle(legs[i].items[2].IKPoint.x, legs[i].items[2].IKPoint.y + scrollDy, legs[i].items[2].len);
					// 2つ根元側(第2セグメント)のジョイントを中心として、1つ根元側(第2)のセグメントの長さを半径とする円の
					if (i == 1) canvas.circle(legs[i].items[2 - 2].joint.x, legs[i].items[2 - 2].joint.y + scrollDy, legs[i].items[2 - 1].len);
					// 交点を求める。 1～2個の交点が求まる場合はいずれかが第1セグメントのジョイント候補。0個の場合は2つの円の中心を結ぶ直線と先端円の交点を第1セグメントのジョイントとする
					var len : Number = dist(legs[i].items[2].IKPoint, legs[i].items[2 - 2].joint);
					if ((len <= legs[i].items[2].len + legs[i].items[2 - 1].len) && (len >= Math.abs(legs[i].items[2].len - legs[i].items[2 - 1].len))) { // 交点がある可能性あり
						thi = Math.atan2(legs[i].items[2 - 2].joint.y - legs[i].items[2].IKPoint.y, legs[i].items[2 - 2].joint.x - legs[i].items[2].IKPoint.x);
						// 余弦定理で求める cosa = (b*b+c*c-a*a)/(2bc)
						a = Math.acos(Number(legs[i].items[2].len * legs[i].items[2].len + len * len - legs[i].items[2 - 1].len * legs[i].items[2 - 1].len) / (2 * legs[i].items[2].len * len));

						temppos1.x = legs[i].items[2].IKPoint.x + Math.cos(thi + a) * legs[i].items[2].len;
						temppos1.y = legs[i].items[2].IKPoint.y +  Math.sin(thi + a) * legs[i].items[2].len;
						if (i == 1) canvas.moveTo(legs[i].items[2].IKPoint.x, legs[i].items[2].IKPoint.y + scrollDy);
						if (i == 1) canvas.lineTo(temppos1.x, temppos1.y + scrollDy);
						temppos2.x = legs[i].items[2].IKPoint.x + Math.cos(thi - a) * legs[i].items[2].len;
						temppos2.y = legs[i].items[2].IKPoint.y +  Math.sin(thi - a) * legs[i].items[2].len;
						if (i == 1) canvas.moveTo(legs[i].items[2].IKPoint.x, legs[i].items[2].IKPoint.y + scrollDy);
						if (i == 1) canvas.lineTo(temppos2.x, temppos2.y + scrollDy);
						// 求まった2つの交点から元の間接に近い点を求め、それを新しい間接位置にする
						var l1 : Number = dist(temppos1, legs[i].items[1].IKPoint);
						var l2 : Number = dist(temppos2, legs[i].items[1].IKPoint);
						if (l1 < l2) {
							legs[i].items[1].IKPoint.x = temppos1.x;
							legs[i].items[1].IKPoint.y = temppos1.y;
						} else {
							legs[i].items[1].IKPoint.x = temppos2.x;
							legs[i].items[1].IKPoint.y = temppos2.y;
						}
						canvas.stroke(0xff000000);
						canvas.moveTo(legs[i].items[2].IKPoint.x, legs[i].items[2].IKPoint.y + scrollDy);
						canvas.lineTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
						
					} else {
						thi = Math.atan2(legs[i].items[2 - 2].joint.y - legs[i].items[2].IKPoint.y, legs[i].items[2 - 2].joint.x - legs[i].items[2].IKPoint.x);
						// 2つの円の中心を結ぶ直線と先端の円の交点を求め、それを新しい間接位置にする
						temppos1.x = legs[i].items[2].IKPoint.x + Math.cos(thi) * legs[i].items[2].len;
						temppos1.y = legs[i].items[2].IKPoint.y +  Math.sin(thi) * legs[i].items[2].len;
						legs[i].items[1].IKPoint.x += (temppos1.x - legs[i].items[1].IKPoint.x)/4;
						legs[i].items[1].IKPoint.y += (temppos1.y - legs[i].items[1].IKPoint.y)/4;
						canvas.stroke(0xff000000);
						canvas.moveTo(legs[i].items[2].IKPoint.x, legs[i].items[2].IKPoint.y + scrollDy);
						canvas.lineTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
					}
					// << 第2セグメントの位置を算出>>
					// 先端部分を中心として、先端部分(第3)のセグメントの長さを半径とする円と
					canvas.stroke(0xff606060);
					if (i == 0) canvas.circle(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy, legs[i].items[1].len);
					if (i == 0) canvas.circle(legs[i].root.x, legs[i].root.y + scrollDy, legs[i].items[0].len);
					len = dist(legs[i].items[1].IKPoint, legs[i].root);
					if ((len <= legs[i].items[1].len + legs[i].items[0].len) && (len >= Math.abs(legs[i].items[1].len - legs[i].items[0].len) )) { // 交点がある可能性あり
						thi = Math.atan2(legs[i].root.y - legs[i].items[1].IKPoint.y, legs[i].root.x - legs[i].items[1].IKPoint.x);
						// 余弦定理で求める cosa = (b*b+c*c-a*a)/(2bc)
						a = Math.acos(Number(legs[i].items[1].len * legs[i].items[1].len + len * len - legs[i].items[0].len * legs[i].items[0].len) / (2 * legs[i].items[1].len * len));

						temppos1.x = legs[i].items[1].IKPoint.x + Math.cos(thi + a) * legs[i].items[1].len;
						temppos1.y = legs[i].items[1].IKPoint.y +  Math.sin(thi + a) * legs[i].items[1].len;
						if (i == 0) canvas.moveTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
						if (i == 0) canvas.lineTo(temppos1.x, temppos1.y + scrollDy);
						temppos2.x = legs[i].items[1].IKPoint.x + Math.cos(thi - a) * legs[i].items[1].len;
						temppos2.y = legs[i].items[1].IKPoint.y +  Math.sin(thi - a) * legs[i].items[1].len;
						if (i == 0) canvas.moveTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
						if (i == 0) canvas.lineTo(temppos2.x, temppos2.y + scrollDy);
						// 求まった2つの交点から元の間接に近い点を求め、それを新しい間接位置にする
						l1 = dist(temppos1, legs[i].items[0].IKPoint);
						l2 = dist(temppos2, legs[i].items[0].IKPoint);
						if (l1 < l2) {
							legs[i].items[0].IKPoint.x = temppos1.x;
							legs[i].items[0].IKPoint.y = temppos1.y;
						} else {
							legs[i].items[0].IKPoint.x = temppos2.x;
							legs[i].items[0].IKPoint.y = temppos2.y;
						}
						canvas.stroke(0xff000000);
						canvas.moveTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
						canvas.lineTo(legs[i].items[0].IKPoint.x, legs[i].items[0].IKPoint.y + scrollDy);
					} else {
						thi = Math.atan2(legs[i].root.y - legs[i].items[1].IKPoint.y, legs[i].root.x - legs[i].items[1].IKPoint.x);
						// 2つの円の中心を結ぶ直線と先端の円の交点を求め、それを新しい間接位置にする
						temppos1.x = legs[i].items[1].IKPoint.x + Math.cos(thi) * legs[i].items[1].len;
						temppos1.y = legs[i].items[1].IKPoint.y +  Math.sin(thi) * legs[i].items[1].len;
						legs[i].items[0].IKPoint.x += (temppos1.x - legs[i].items[0].IKPoint.x)/4;
						legs[i].items[0].IKPoint.y += (temppos1.y - legs[i].items[0].IKPoint.y)/4;
						canvas.stroke(0xff000000);
						canvas.moveTo(legs[i].items[1].IKPoint.x, legs[i].items[1].IKPoint.y + scrollDy);
						canvas.lineTo(legs[i].items[0].IKPoint.x, legs[i].items[0].IKPoint.y + scrollDy);
					}
					
					canvas.stroke(0xff000000);
					canvas.moveTo(legs[i].items[0].IKPoint.x, legs[i].items[0].IKPoint.y + scrollDy);
					canvas.lineTo(legs[i].root.x, legs[i].root.y + scrollDy);
					
					
					canvas.fill(0xff,0xff,0xff,0xff);
				}
				switch (i) {
					case 0:
					case 1:
					{
						nr = (((state * 10) % 360) / 360) + 0.25;
						if (state < 6*10) {
							if ((legs[i].items[2].IK)) {// && (nr > 0.5 + 0.25)) {
								canvas.stroke(0xff606060);
								infotxt.visible = true;
								if (i == 1) {
									if (nr < 0.5) {
										infotxt.text = "先端を中心とした円と、その2つ上位の間接を\n中心とした円の交点を求める"
									} else {
										infotxt.text = "求まった1～2つの交点から、もともとの\n間接位置に近い点を新しい関節位置にする"
									}
								} else {
									if (nr < 1.0) {
										infotxt.text = "先端の間接を中心とした円と、\nその2つ上位(根元)の間接を\n中心とした円の交点を求める"
									} else {
										infotxt.text = "求まった1～2つの交点から、もともとの\n間接位置に近い点を新しい関節位置にする"
									}
								}
								temppos1.x = legs[i].items[i+1].IKPoint.x + Math.cos((i+1)*Math.PI / 4) * legs[i].items[i+1].len;
								temppos1.y = legs[i].items[i+1].IKPoint.y - Math.sin((i+1)*Math.PI / 4) * legs[i].items[i+1].len;
								infotxt.x = temppos1.x - 32;
								infotxt.y = temppos1.y + scrollDy -100;
								
								canvas.moveTo(temppos1.x, temppos1.y + scrollDy);
								canvas.lineTo(temppos1.x , temppos1.y + scrollDy - 100 +32);

								if (i == 0) {
									temppos2.x = legs[i].root.x;
									temppos2.y = legs[i].root.y;
								} else {
									temppos2.x = legs[i].items[i-1].joint.x;
									temppos2.y = legs[i].items[i-1].joint.y;
								}
								temppos2.x = temppos2.x + Math.cos((i+1)*Math.PI / 4) * legs[i].items[1-i].len;
								temppos2.y = temppos2.y - Math.sin((i+1)*Math.PI / 4) * legs[i].items[1-i].len;
								canvas.moveTo(temppos2.x, temppos2.y + scrollDy);
								canvas.lineTo(temppos1.x , temppos1.y + scrollDy - 100 +32);
							} else if (i==0) {
								infotxt.visible = false;
							}
						} else {
							infotxt.x = 0;
							infotxt.y = 100;
							infotxt.text = "IKからFKへの切り替えがまだ\nスムーズではないので次のステップで修正"
						}
						for (j = 0; j < legs[i].items.length; j++) {
							if (i == 0) {
								legs[i].items[j].IK = (nr > 0.75) || (nr < 0.25);
							} else {
								legs[i].items[j].IK = (nr < 0.75) && (nr > 0.25);
							}
						}

						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (-90+(i==1?-60:60)+Math.sin(rad)*20)* Math.PI / 180;

						nr = nr+0.5;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==1?-45:45)-Math.sin(rad)*20)* Math.PI / 180;
						legs[i].items[2].rotate = ((i==1?90:-90)+Math.sin(rad)*20)* Math.PI / 180;
						break;
					}
					case 2:
					case 3:
					{
						nr = (((state * 10) % 360) / 360) + 0.5;
						for (j = 0; j < legs[i].items.length; j++) {
							if (i == 2) {
								legs[i].items[j].IK = (nr < 1.3) && (nr > 0.8);
							} else {
								legs[i].items[j].IK = (nr > 1.3) || (nr < 0.8);
							}
						}

						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (90+(i==3?95:-95)+Math.sin(rad)*20)* Math.PI / 180;
						nr = nr + 0.75;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==3?-60:60)-Math.sin(rad)*40)* Math.PI / 180;
						//legs[i].items[2].rotate = (10+Math.sin(state/10)*10)* Math.PI / 180;
						break;
					}
					case 4:
					case 5:
					{
						nr = (((state * 10) % 360) / 360);
						for (j = 0; j < legs[i].items.length; j++) {
							if (i == 4) {
								legs[i].items[j].IK = (nr < 0.3) || (nr > 0.8);
							} else {
								legs[i].items[j].IK = (nr > 0.3) && (nr < 0.8);
							}
						}
						rad = nr * Math.PI * 2;
						legs[i].items[0].rotate = (90+(i==5?55:-55)-Math.sin(rad)*20)* Math.PI / 180;
						nr = nr + 0.5;// 75;
						rad = nr * Math.PI * 2;
						legs[i].items[1].rotate = ((i==5?30:-30)-Math.sin(rad)*40)* Math.PI / 180;
						legs[i].items[2].rotate = ((i==5?-90:90)+Math.sin(rad)*20)* Math.PI / 180;
						break;
					}
				}
				
				canvas.stroke(0xff000000);
				canvas.moveTo(legs[i].root.x, legs[i].root.y + scrollDy);
				for (j  = 0; j < segcnt; j++) {
					if (legs[i].items[j].IK) canvas.stroke(0xffc0c0c0);
					else {
						canvas.stroke(0xff000000);
						canvas.lineTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y + scrollDy);
					}
					if (state < 60*5) {
						canvas.circle(legs[i].items[j].joint.x, legs[i].items[j].joint.y + scrollDy, 4);
					}
					canvas.moveTo(legs[i].items[j].joint.x, legs[i].items[j].joint.y + scrollDy);
				}
			}
			if (state > 60) drawBody(0,moveDy, 0, scrollDy,0);

			canvas.endDraw();
		}
		// step3 finish
		private function initIKFinish() : void
		{
			txt.text = "Apis cerana japonica";// "STEP 3.ドラッグしてください";
			txt.x = (stage.stageWidth - txt.width) / 2;
			txt.y = stage.stageHeight - 50;
			infotxt.text = "";
			state = 0;
			moveDx = 0;
			moveDy = stage.stageHeight;
			appear = 360;
			scrollDy = 0;
			dice_count = 0;
			
			nextButton.visible = false;
			autoCheckbox.enabled = true;
			autoCheckbox.selected = true;
			
			walk = new WalkBehavior(legs);
			fly = new FlyingBehavior(legs);
		}
		private var appear : int = 0;
		private var after_fly : int = 0;
		private var dice_count : int = 0;
		private var dice_pos : Point = new Point();
		
		private function frameIKFinish() : void
		{
			var legcnt : int = legs.length;
			var i : int, j : int, thi : Number, a : Number;
			var flying : Boolean = false;
			//state++;
			
			if (appear > 0) {
				bodyAngle = ((appear*appear)/180) * Math.PI / 180;
				moveDx = Math.cos(bodyAngle) * (appear+20);
				moveDy = Math.sin(bodyAngle) * (appear+20);
				flying = ((appear * appear) / 180) > 30;
				if (!flying) walk.stepState();
				appear--;
				after_fly = 30;
				dice_count = 1;
				dice_pos.x = 0;
				dice_pos.y = 0;
			} else if (mouseIsDown || autoCheckbox.selected) {
				if (autoCheckbox.selected) {
					if (dice_count == 0) {
						if (Math.random() * 100 > 90) {
							dice_pos.x = (Math.round(Math.random()*2)-1)*100;
							dice_pos.y = ((Math.random()*2)-1)*100;
						} else {
							dice_pos.x = Math.random() * 48 - 24;
							dice_pos.y = Math.random() * 48 - 24;
						}
						
					}
					dice_count = (dice_count + 1) & 0x1f;
					temppos1.x = moveDx + dice_pos.x + Math.random()*16-8;
					temppos1.y = moveDy + dice_pos.y + Math.random()*16-8;
					if (temppos1.x > stage.stageWidth / 2-32) temppos1.x = stage.stageWidth / 2 - 32;
					if (temppos1.x < -stage.stageWidth / 2+32) temppos1.x = -stage.stageWidth / 2 + 32;
					if (temppos1.y > stage.stageHeight / 2-32) temppos1.y = stage.stageHeight / 2 - 32;
					if (temppos1.y < -stage.stageHeight / 2+32) temppos1.y = -stage.stageHeight / 2 + 32;
				} else {
					temppos1.x = stage.mouseX - stage.stageWidth / 2;
					temppos1.y = stage.mouseY - stage.stageHeight / 2;
				}
				temppos2.x = moveDx;
				temppos2.y = moveDy;
				var ba : Number = Math.atan2( temppos1.y - moveDy, temppos1.x - moveDx);
				var dx : Number = (temppos1.x - moveDx);
				var dy : Number = (temppos1.y - moveDy);
				
				moveDx += dx / 8;
				moveDy += dy / 8;
				if ((moveDx != lastMoveDx) || (moveDy != lastMoveDy)) walk.stepState();
				
				flying = Math.sqrt(dx * dx + dy * dy) > 64;
				after_fly |= flying ? 30 : 0;
				if (dist(temppos1, temppos2) > 32){					
					bodyAngle = interpolateAngle(bodyAngle,  ba + Math.PI / 2, flying ? 1/4 : 1 / 32);
				} else if (mouseIsDown) {
					autoCheckbox.selected = false;
				}
			} else {
				if (after_fly > 0) {
					after_fly--;
					walk.stepState();
				}
				flying = false;
			}
			lastMoveDx = moveDx;
			lastMoveDy = moveDy;
			
			abdomenState++;
			
			state = (36 + state) % 36;
			
			canvas.beginDraw();
			canvas.stroke(0xff606060);
			
				
			canvas.stroke(0, 0, 0, 0xff);
			
			if (flying) {
				fly.stepFrame(stage.stageWidth / 2 + moveDx, stage.stageHeight / 2 + moveDy, bodyAngle);
			} else {
				walk.stepFrame(stage.stageWidth / 2 + moveDx, stage.stageHeight / 2 + moveDy, bodyAngle);
			}
			
			var segcnt : int;
			// shadow
			drawBodyShadow(moveDx, moveDy, bodyAngle, 0, abdomenState, flying);
			if (!flying) {
				for (i = 0; i < legcnt; i++) {
					segcnt = legs[i].items.length;
					canvas.stroke(0x00);
					canvas.moveTo(legs[i].root.x+8, legs[i].root.y + 8);
					for (j  = 0; j < segcnt; j++) {
						if (legs[i].items[j].IK && (j == segcnt-1)) {
							canvas.strokeAlpha = 0.5;
							canvas.lineTo(legs[i].items[j].IKPoint.x, legs[i].items[j].IKPoint.y);
						} else {
							canvas.strokeAlpha = 0.2;
							canvas.lineTo(legs[i].items[j].IKPoint.x + 8-(j*4)/segcnt, legs[i].items[j].IKPoint.y + 8-(j*4)/segcnt);
						}
					}
				}
			}
			canvas.endDraw();
			canvas.bitmapData.applyFilter(canvas.bitmapData, canvas.bitmapData.rect, zeroPoint, blur);
			
			canvas.beginDraw();
			canvas.strokeAlpha = 1;
			// image
			for (i = 0; i < legcnt; i++) {
				segcnt = legs[i].items.length;
				for (j  = 0; j < segcnt; j++) {
					canvas.pushMatrix();
					var m : Matrix = legs[i].items[j].matrix;
					canvas.resetMatrix();
					canvas.applyMatrix(m.a, m.b, m.c, m.d, m.tx, m.ty);
					canvas.stroke(0xff404040);
					switch (j) {
						case 0:
						{
							canvas.moveTo(0, 0);
							canvas.lineTo(legs[i].items[j].len, 0);
							break;
						}
						case 1:
						{
							if (i & 2) {
								canvas.beginFill(0xff002040);
								canvas.moveTo(0, 0);
								canvas.lineTo(legs[i].items[j].len, 2);
								canvas.lineTo(legs[i].items[j].len, -2);
								canvas.lineTo(0,0);
								canvas.endFill();
							} else {
								canvas.moveTo(0, 0);
								canvas.lineTo(legs[i].items[j].len, 0);
							}
							break;
						}
						case 2:
						{
							if (i & 2) {
								canvas.beginFill(0xff002040);
								canvas.moveTo(0, -2);
								canvas.lineTo(legs[i].items[j].len, -1);
								canvas.lineTo(legs[i].items[j].len, 1);
								canvas.lineTo(0, 2);
								canvas.lineTo(0, -2);
								canvas.endFill();
								
								canvas.stroke(0xff808040);
								canvas.strokeWeight(2);
								canvas.moveTo(0, 2);
								canvas.lineTo(0, -2);
								canvas.strokeWeight(1);
							} else {
								canvas.beginFill(0xff002040);
								canvas.moveTo(0, 0);
								canvas.lineTo(legs[i].items[j].len/2, 2);
								canvas.lineTo(legs[i].items[j].len, 0);
								canvas.lineTo(legs[i].items[j].len/2, -2);
								canvas.lineTo(0, 0);
								canvas.endFill();

								canvas.stroke(0xff808040);
								canvas.strokeWeight(2);
								canvas.moveTo(legs[i].items[j].len/2, 2);
								canvas.lineTo(legs[i].items[j].len/2, -2);
								canvas.strokeWeight(1);
							}
							
							if (i & 4) {
								canvas.beginFill(0xffffd040);
								canvas.ellipse(legs[i].items[j].len / 3, 0, 32, 16);
								canvas.endFill();
							}

							canvas.stroke(0xff404040);
							if (legs[i].items[j].IK) {
								canvas.moveTo(legs[i].items[j].len, 0);
								canvas.lineTo(legs[i].items[j].len , (i & 1) ? 3 : -3);
							} else {
								canvas.moveTo(legs[i].items[j].len, 0);
								canvas.lineTo(legs[i].items[j].len + 4, (i & 1) ? 2 : -2);
							}
							
							break;
						}
					}
					canvas.popMatrix();
				}
			}
			drawBody(moveDx, moveDy, bodyAngle,0,abdomenState, true, flying);
			canvas.endDraw();
		}
	
		private var offsetrec : int;
		private function drawBodyShadow(dx : int,  dy : int, angle : Number, scroll : int, state : int, flying : Boolean) : void
		{
			//if (!flying) offsetrec = 8;
			
			var offset : int = flying ? offsetrec + (32 - offsetrec) / 4: offsetrec + (8 - offsetrec) / 4;
			offsetrec = offset;
			
			canvas.fill(0.5,0.5,0.5,0.2);
			canvas.pushMatrix();
			canvas.strokeAlpha = 0;
			canvas.translate(stage.stageWidth / 2 + dx+offset, stage.stageHeight / 2 + dy +offset + scroll);
			canvas.rotate(angle);
			canvas.ellipse( -0, -32, 48, 32);
			canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 96 + (state % 15));
			canvas.ellipse(0, 0, 56,48);

			canvas.stroke(0x00);
			canvas.strokeAlpha = 0.2;
			canvas.moveTo( -4, -48);
			canvas.lineTo( -8, -52);
			canvas.lineTo( -12, -64);
			canvas.moveTo( 4, -48);
			canvas.lineTo( 8, -52);
			canvas.lineTo( 12, -64);
			
			canvas.popMatrix();
		}
		
		private function drawBody(dx : int,  dy : int, angle : Number, scroll : int, state : int, finalRender : Boolean = false, fly : Boolean = false) : void
		{
			canvas.fill(0xff, 0xff, 0xff, 1);
			canvas.pushMatrix();
			canvas.stroke(0xff404040);
			canvas.translate(stage.stageWidth / 2 + dx, stage.stageHeight / 2 + dy + scroll);
			canvas.rotate(angle);
			if (finalRender) {
				canvas.beginFill(0x806020);
				canvas.ellipse( -0, -32, 48, 32);
				canvas.endFill();

				canvas.beginFill(0x201000);
				canvas.ellipse( -16, -32, 16, 24);
				canvas.ellipse( 16, -32, 16, 24);
				canvas.pushMatrix();
				canvas.translate( -16, -32);
				canvas.rotate( -angle);
				canvas.beginFill(0xffffff, 0.8);
				canvas.circle( -4, -4, 2);
				canvas.endFill();
				canvas.popMatrix();

				canvas.pushMatrix();
				canvas.translate( 16, -32);
				canvas.rotate( -angle);
				canvas.beginFill(0xffffff, 0.8);
				canvas.circle( -4, -4, 2);
				canvas.endFill();
				canvas.popMatrix();
				
				canvas.endFill();
				canvas.beginFill(0x806020);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 96 + (state % 15));
				canvas.endFill();
				
				canvas.stroke(0xf0, 0x80, 0x00, 0x00);
				canvas.beginFill(0xf09000);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 86 + (state % 15));
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 66 + (state % 15));
				canvas.endFill();
				canvas.beginFill(0xf08000);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 46 + (state % 15));
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 26 + (state % 15));
				canvas.endFill();

				canvas.beginFill(0x201000);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 96 + (state % 15));
				canvas.ellipse( 0, 64 -5+ (state % 15) / 2, 70, 76 + (state % 15));
				canvas.endFill();

				canvas.beginFill(0x201000);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 56 + (state % 15));
				canvas.ellipse( 0, 64 -5+ (state % 15) / 2, 70, 36 + (state % 15));
				canvas.endFill();

				canvas.beginFill(0x201000);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 16 + (state % 15));
				canvas.ellipse( 0, 64 -3+ (state % 15) / 2, 70, 6 + (state % 15));
				canvas.endFill();
				
				canvas.beginFill(0x402010);
				canvas.ellipse(0, 0, 56,48);
				canvas.endFill();
				canvas.beginFill(0x201000);
				canvas.ellipse(0, -5, 46,38);
				canvas.endFill();

				// eye highlight
				canvas.fill(0xff, 0xff, 0xff, 0xff);
				for (var i : int = 0; i < 360; i+=4) {
					var ra1 : Number = i * Math.PI / 180;
					var x0 : Number = Math.sin(ra1) * 54/2;
					var y0 : Number = Math.cos(ra1) * 44/2;
					var x1 : Number = Math.sin(ra1) * 59/2;
					var y1 : Number = Math.cos(ra1) * 52/2+2;
					var x2 : Number = Math.sin(ra1) * 64/2;
					var y2 : Number = Math.cos(ra1) * 56/2+4;
					canvas.stroke(0xa0, 0x70, 0x00, 0x80);
					canvas.moveTo(x0, y0);
					canvas.lineTo(x1, y1);
					canvas.stroke(0xf0, 0x80, 0x00, 0x10);
					canvas.lineTo(x2, y2);
				}
				canvas.stroke(0xff404040);
			} else {
				canvas.ellipse( -0, -32, 48, 32);
				canvas.ellipse( -16, -32, 16, 24);
				canvas.ellipse( 16, -32, 16, 24);
				canvas.ellipse( 0, 64 + (state % 15) / 2, 70, 96 + (state % 15));
				canvas.ellipse(0, 0, 56,48);
			}
			canvas.moveTo( -4, -48);
			canvas.lineTo( -8, -52);
			canvas.lineTo( -12, -64);
			canvas.moveTo( 4, -48);
			canvas.lineTo( 8, -52);
			canvas.lineTo( 12, -64);
			
			var flystate : int = (state*2) % 10;
			if (fly) flystate = flystate*2 + 90;
			
			if (finalRender) {
				canvas.stroke(0x00, 0xff, 0xff, 0x40);
				canvas.strokeAlpha = 0.5;
				canvas.pushMatrix();
				canvas.translate( -8, 8);
				canvas.rotate(flystate*Math.PI / 180);
				canvas.beginFill(0x00ffff,0.2);
				canvas.moveTo(-8, 0);
				canvas.lineTo( -24, 48);
				canvas.arcCurveTo( -24,48, -12, 56,2, 8, false, false);
				canvas.strokeAlpha = 0;
				canvas.arcCurveTo( -12, 56, 4, 32, 2, 4, false, false);
				canvas.lineTo( 0, 8);
				canvas.endFill();
				canvas.popMatrix();
				
				canvas.stroke(0x00, 0xff, 0xff, 0x40);
				canvas.strokeAlpha = 0.5;
				canvas.pushMatrix();
				canvas.translate( 8, 8);
				canvas.rotate(flystate*-Math.PI / 180);
				canvas.beginFill(0x00ffff,0.2);
				canvas.moveTo( 8, 0);
				canvas.lineTo( 24, 48);
				canvas.arcCurveTo( 24,48, 12, 56,2, 8, false, true);
				canvas.strokeAlpha = 0;
				canvas.arcCurveTo( 12, 56,-4, 32, 2, 4, false, true);
				canvas.lineTo( 0, 8);
				canvas.endFill();
				canvas.popMatrix();
			}	
			canvas.fill(0xff, 0xff, 0xff, 0xff);
			
			canvas.popMatrix();
			
		}
	}
	
}

function dist(p0 : Point, p1 : Point) : Number
{
	return Math.sqrt( (p0.x - p1.x) * (p0.x - p1.x) + (p0.y - p1.y) * (p0.y - p1.y) );
}

function unitVector(p0 : Point, p1 : Point, /*out*/ u : Point) : Boolean
{
	var len : Number = Math.sqrt( (p0.y - p1.y) * (p0.y - p1.y) + (p0.x - p1.x) * (p0.x - p1.x) );
	if (len > 0) {
		u.x = (p0.x - p1.x) / len;
		u.y = (p0.y - p1.y) / len;
		return true;
	} else return false;
}

function dotProduct(p0 : Point, p1 : Point) : Number
{
	return p0.x * p1.x + p0.y * p1.y;
}

function crossProductZ(p0 : Point, p1 : Point) : Number
{
	return p0.x * p1.y - p0.y * p1.x;
}


function interpolateAngle(from : Number, to : Number, coef : Number/*, limit : Number = Math.PI/18*/ ) : Number
{
	var d1 : Number = Math.abs(to-from);
	var to2 : Number = to;
	var from2 : Number = from;
	
	if (to2 < 0) to2 += 2 * Math.PI;
	if (from2 < 0) from2 += 2 * Math.PI;
	var d2 : Number = Math.abs(to2 - from2);
	var d : Number = 0;
	if (d1 < d2) {
		d = (to-from) * coef;
	} else {
		d = (to2 - from2) * coef;
	}
	
	/*
	if (limit > 0) {
		if (d > limit) d = limit; else if (d < -limit) d = -limit;
	}
	*/
	
	from += d;
	
	if (from > Math.PI) from -= 2 * Math.PI;
	if (from < -Math.PI) from += 2 * Math.PI;
	
	return from;
}

import flash.geom.Matrix;
import flash.geom.Point;

class LegSegment
{
	public var root : Point = new Point(); // 親jointからの相対値
	public var joint : Point = new Point(); // joint絶対値
	public var len : Number = 10;
	public var rotate : Number = 0; // 
	public var IKRotate : Number = 0; // 
	public var IKPoint : Point = new Point(); // 接地点の座標
	
	public var uselim : Boolean = false;
	public var limmax : Number = 0;
	public var limmin : Number = 0;

	private var _IK : Boolean = false;
	private var _matrix : Matrix = new Matrix();
	
	public function get IK():Boolean { return _IK; }
	
	public function set IK(value:Boolean):void 
	{
		if (!_IK && value) {
			IKPoint.x = joint.x;
			IKPoint.y = joint.y;
		}
		_IK = value;
	}
	
	public function get matrix():Matrix { return _matrix; }
}

class Leg
{
	private var temppos : Point = new Point();
	private var temppos1 : Point = new Point();
	private var temppos2 : Point = new Point();

	public var matrix : MatrixStack = new MatrixStack();
	public var items : Vector.<LegSegment> = new Vector.<LegSegment>;
	public var root : Point = new Point();

	public function Leg( assemble : Array )
	{
		var cnt : int = assemble.length;
		for (var i : int = 0; i < cnt; i++) {
			items[i] = new LegSegment();
			items[i].root.x = 0;
			items[i].root.y = 0;
			if (assemble[i].x != undefined) {
				items[i].root.x = assemble[i].x;
				items[i].root.y = assemble[i].y;
			} else {
			}
			items[i].len = assemble[i].len;
			items[i].rotate = assemble[i].rotate * Math.PI / 180;
			
			if ((assemble[i].limmax != undefined) && (assemble[i].limmin != undefined)) {
				items[i].uselim = true;
				items[i].limmax = assemble[i].limmax;
				items[i].limmin = assemble[i].limmin;
			}
		}
		if (cnt > 0) computeFK(0,0,0);
	}
	
	public function computeFK(x : Number, y : Number, angle : Number) : void
	{
		var cnt : int = items.length;
		if (cnt == 0) return;
		
		matrix.push().translate(x, y).rotate(angle);
		
		for (var i : int = 0; i < cnt; i++) {
			temppos.x = items[i].root.x;
			temppos.y = items[i].root.y;
			
			if (i == 0) {
				root.x = temppos.x;
				root.y = temppos.y;
				matrix.transform(root);
			}
			
			matrix.translate(temppos.x, temppos.y).rotate(items[i].rotate);
			
			temppos.x = items[i].len;
			temppos.y = 0;
			matrix.transform(temppos);
			items[i].joint.x = temppos.x;
			items[i].joint.y = temppos.y;
			matrix.copyTo(items[i].matrix);
			matrix.translate(items[i].len, 0);
		}
		matrix.pop();
	}
	
	public function setIK(useIK : Boolean, startIndex : int, endIndex : int) : void
	{
		if (endIndex >= items.length - 1) endIndex = items.length - 1;
		
		for (var i : int = startIndex; i <= endIndex; i++) {
			items[i].IK = useIK;
		}
		
	}
	
	public function computeIK(x : Number, y : Number, angle : Number, interpolateCoeff : Number) : void
	{
		var i : int, j : int;
		var cnt : int = items.length;
		if (cnt == 0) return;
		
		computeFK(x, y, angle);
		
		for (i = cnt - 1; i > 0; i--) {
			if (items[i].IK) adjustIK(i);
		}
		for (j = 0; j < items.length; j++) {
			if (j == 0) {
				temppos2.x = Math.cos( angle );
				temppos2.y = Math.sin( angle );
				unitVector( items[j].IKPoint,  root, temppos1);
			} else {
				unitVector( items[j].IKPoint,  items[j - 1].IKPoint, temppos1);
			}
			var ca : Number = Math.max(-1,Math.min(1, dotProduct(temppos1, temppos2))); // 単位ベクトル同士の内積だが、たま～に1を微妙に超えることがあるみたい
			var sa : Number = crossProductZ(temppos1, temppos2);
			var r : Number = Math.acos(ca);
			if (sa > 0) r = -r;
			items[j].IKRotate = r;
			
			temppos2.x = temppos1.x;
			temppos2.y = temppos1.y;
		}
		
		matrix.push().translate(x, y).rotate(angle);
		
		for (i = 0; i < cnt; i++) {
			temppos.x = items[i].root.x;
			temppos.y = items[i].root.y;
			
			if (i == 0) {
				root.x = temppos.x;
				root.y = temppos.y;
				matrix.transform(root);
			}
			
			if (!items[i].IK) {
				items[i].IKRotate = interpolateAngle(items[i].IKRotate, items[i].rotate, interpolateCoeff);
			}

			if (items[i].uselim) {
				if (items[i].IKRotate > items[i].limmax) {
					items[i].IKRotate = items[i].limmax;
				} else if (items[i].IKRotate < items[i].limmin) {
					items[i].IKRotate = items[i].limmin;
				}
			}
			
			matrix.translate(temppos.x, temppos.y).rotate(items[i].IKRotate);
			
			temppos.x = items[i].len;
			temppos.y = 0;
			matrix.transform(temppos);
			items[i].IKPoint.x = temppos.x;
			items[i].IKPoint.y = temppos.y;
			matrix.copyTo(items[i].matrix);
			matrix.translate(items[i].len, 0);
		}
		matrix.pop();
	}
	
	public function adjustIK(index : int) : void
	{
		if (index < 1) return;
		
		var item_2 : Point;
		if (index >= 2) {
			item_2 = items[index - 2].joint;
		} else {
			item_2 = root;
		}
		
		var len : Number = dist(items[index].IKPoint, item_2);
		
		if ((len <= items[index].len + items[index-1].len) && (len >= Math.abs(items[index].len - items[index - 1].len))) { // 交点がある可能性あり
			var thi : Number = Math.atan2(item_2.y - items[index].IKPoint.y, item_2.x - items[index].IKPoint.x);
			// 余弦定理で求める cosa = (b*b+c*c-a*a)/(2bc)
			var cf : Number = (items[index].len * items[index].len + len * len - items[index - 1].len * items[index - 1].len) / (2 * items[index].len * len);
			var a : Number = Math.acos(cf);

			temppos1.x = items[index].IKPoint.x + Math.cos(thi + a) * items[index].len;
			temppos1.y = items[index].IKPoint.y + Math.sin(thi + a) * items[index].len;
			temppos2.x = items[index].IKPoint.x + Math.cos(thi - a) * items[index].len;
			temppos2.y = items[index].IKPoint.y + Math.sin(thi - a) * items[index].len;
			// 求まった2つの交点から元の間接に近い点を求め、それを新しい間接位置にする
			var l1 : Number = dist(temppos1, items[index-1].IKPoint);
			var l2 : Number = dist(temppos2, items[index-1].IKPoint);
			if (l1 < l2) {
				items[index-1].IKPoint.x = temppos1.x;
				items[index-1].IKPoint.y = temppos1.y;
			} else {
				items[index-1].IKPoint.x = temppos2.x;
				items[index-1].IKPoint.y = temppos2.y;
			}
		} else {
			thi = Math.atan2(item_2.y - items[index].IKPoint.y, item_2.x - items[index].IKPoint.x);
			// 2つの円の中心を結ぶ直線と先端の円の交点を求め、それを新しい間接位置にする
			temppos1.x = items[index].IKPoint.x + Math.cos(thi) * items[index].len;
			temppos1.y = items[index].IKPoint.y + Math.sin(thi) * items[index].len;
			items[index-1].IKPoint.x += (temppos1.x - items[index-1].IKPoint.x) / 4;
			items[index-1].IKPoint.y += (temppos1.y - items[index-1].IKPoint.y) / 4;
			
		}
		
	}
	
}

class FlyingBehavior
{
	private var legs : Vector.<Leg> = null;
	private var state : int = 0;
	private var temppos1 : Point = new Point();
	private var temppos2 : Point = new Point();

	public function FlyingBehavior(legs : Vector.<Leg>)
	{
		this.legs = legs;
	}
	public function stepState() : void
	{
		state++;
	}
	public function stepFrame(x : Number, y : Number, angle : Number) : void
	{
		var legcnt : int = legs.length;
		for (var i : int = 0; i < legcnt; i++) {
			legs[i].setIK( false, 0, legs[i].items.length-1);
			switch (i) {
				case 0:
				case 1:
				{
					legs[i].items[0].rotate = (-90+(i==1?-40:40))* Math.PI / 180;
					legs[i].items[1].rotate = (i==1?-50:50)* Math.PI / 180;
					legs[i].items[2].rotate = (i==1?160:-160)* Math.PI / 180;
					break;
				}
				case 2:
				case 3:
				{
					legs[i].items[0].rotate = (90+(i==3?55:-55))* Math.PI / 180;
					legs[i].items[1].rotate = (i == 3? -70:70) * Math.PI / 180;
					legs[i].items[2].rotate = (i == 3? 20:-20) * Math.PI / 180;
					break;
				}
				case 4:
				case 5:
				{
					legs[i].items[0].rotate = (90+(i==5?55:-55))* Math.PI / 180;
					legs[i].items[1].rotate = (i == 5? -20:20) * Math.PI / 180;
					legs[i].items[2].rotate = (i == 5? -40:40) * Math.PI / 180;
					break;
				}
			}
			legs[i].computeIK(x, y, angle, 1/4);
		}
	}
}

class WalkBehavior
{
	private var legs : Vector.<Leg> = null;
	private var state : int = 0;
	private var temppos1 : Point = new Point();
	private var temppos2 : Point = new Point();

	
	public function WalkBehavior(legs : Vector.<Leg>)
	{
		this.legs = legs;
	}
	
	public function stepState() : void
	{
		state++;
	}
	
	public function stepFrame(x : Number, y : Number, angle : Number) : void
	{
		var legcnt : int = legs.length;
		var nr : Number = 0;
		var rad : Number = 0;
		for (var i : int = 0; i < legcnt; i++) {
			legs[i].computeIK(x, y, angle, 1/8);
			switch (i) {
				case 0:
				case 1:
				{
					nr = (((state * 10) % 360) / 360) + 0.25;
					if (i == 0) {
						legs[i].setIK( (nr > 0.75) || (nr < 0.25), 0, legs[i].items.length-1);
					} else {
						legs[i].setIK( (nr < 0.75) && (nr > 0.25), 0, legs[i].items.length-1);
					}

					rad = nr * Math.PI * 2;
					legs[i].items[0].rotate = (-90+(i==1?-60:60)+Math.sin(rad)*20)* Math.PI / 180;

					nr = nr+0.5;
					rad = nr * Math.PI * 2;
					legs[i].items[1].rotate = ((i==1?-45:45)-Math.sin(rad)*20)* Math.PI / 180;
					legs[i].items[2].rotate = ((i==1?90:-90)+Math.sin(rad)*20)* Math.PI / 180;
					break;
				}
				case 2:
				case 3:
				{
					nr = (((state * 10) % 360) / 360) + 0.5;
					if (i == 2) {
						legs[i].setIK( (nr < 1.3) && (nr > 0.8), 0, legs[i].items.length-1);
					} else {
						legs[i].setIK( (nr > 1.3) || (nr < 0.8), 0, legs[i].items.length-1);
					}

					rad = nr * Math.PI * 2;
					legs[i].items[0].rotate = (90+(i==3?95:-95)+Math.sin(rad)*20)* Math.PI / 180;
					nr = nr + 0.75;
					rad = nr * Math.PI * 2;
					legs[i].items[1].rotate = ((i==3?-60:60)-Math.sin(rad)*40)* Math.PI / 180;
					legs[i].items[2].rotate = (i==3?20:-20)* Math.PI / 180;// (10 + Math.sin(state / 10) * 10) * Math.PI / 180;
					break;
				}
				case 4:
				case 5:
				{
					nr = (((state * 10) % 360) / 360);
					if (i == 4) {
						legs[i].setIK( (nr < 0.3) || (nr > 0.8), 0, legs[i].items.length-1);
					} else {
						legs[i].setIK( (nr > 0.3) && (nr < 0.8), 0, legs[i].items.length-1);
					}
					rad = nr * Math.PI * 2;
					legs[i].items[0].rotate = (90+(i==5?55:-55)-Math.sin(rad)*20)* Math.PI / 180;
					nr = nr + 0.5;// 75;
					rad = nr * Math.PI * 2;
					legs[i].items[1].rotate = ((i==5?30:-30)-Math.sin(rad)*40)* Math.PI / 180;
					legs[i].items[2].rotate = ((i==5?-90:90)+Math.sin(rad)*20)* Math.PI / 180;
					break;
				}
			}
		}
		
	}
	
}

class MatrixWrap
{
	public var matrix : Matrix;
	public var index : int;
	public var used : Boolean;
}

class MatrixPool
{
	// matrixは頻繁に作成されるので、そのたびにnewするのは精神衛生上悪いからPoolする。でもまあ殆ど影響ないと思う
	private var mats : Vector.<MatrixWrap> = new Vector.<MatrixWrap>;
	private var freep : int = -1;
	private const itemlimit : int = 5000;
	
	// 毎回newする変わりに、プールから取り出す。 オーバーヘッドが気になるけど、クリティカルなタイミングでGCが発動するよりましか？
	public function newItem(a : Number = 1, b : Number = 0, c : Number = 0, d : Number = 1, tx : Number = 0, ty : Number = 0 ) : MatrixWrap
	{
		var cnt : int = mats.length;
		if (((itemlimit > 0) && cnt >= itemlimit) && (freep >= cnt-1)) return null;
		
		freep++;

		if (freep == cnt) {
			mats[cnt] = new MatrixWrap();
			mats[cnt].matrix = new Matrix(a, b, c, d, tx, ty);
		} else {
			var m : Matrix = mats[freep].matrix;
			m.a = a;
			m.b = b;
			m.c = c;
			m.d = d;
			m.tx = tx;
			m.ty = ty;
		}
		mats[freep].index = freep;
		mats[freep].used = true;
	
		return mats[freep];
	}
	
	public function remove(item : MatrixWrap) : void
	{
		var cnt : int = mats.length;
		var lastp : int = freep;

		item.used = false;
		if (lastp != item.index) {
			mats[item.index] = mats[lastp];
			mats[item.index].index = item.index;
			mats[lastp] = item;
		}
		freep = lastp - 1;
		
	}
	
	private static var pool : MatrixPool = null;
	public static function get instance() : MatrixPool
	{
		if (!MatrixPool.pool) MatrixPool.pool = new MatrixPool();
		
		return MatrixPool.pool;
	}
	
}

// matrixの適用順をfrocessing互換にするためのMatrixStackクラス。
// 互換性うんぬんよりも、個人的にこちらのほうが使いやすいためという理由のほうが大きい
class MatrixStack
{
		// Matrixクラスのフォーマットがよくわからない
		// あるMatrixでPointをtransformPointするとしてその式はドキュメントだと↓だと思う
		//   a b tx     px 
		// [ c d ty ] [ py ]
		//   0 0 1       1

		// でも実際には
		//             a  b  0  
		//  [px py 1][ c  d  0 ]
		//             tx ty 1   
		// のように見える???
		
		
	private var stack : Vector.<MatrixWrap> = new Vector.<MatrixWrap>;
	private var current : MatrixWrap = new MatrixWrap();

	public function MatrixStack()
	{
		
	}
	
	public function push() : MatrixStack
	{
		stack.push(current);
		current = MatrixPool.instance.newItem(1,0,0,1,0,0);
		
		return this;
	}
	
	public function pop() : MatrixStack
	{
		MatrixPool.instance.remove(current);
		current = stack.pop();
		
		return this;
	}
	
	public function translate(x : Number, y : Number) : MatrixStack
	{
		var mat : MatrixWrap = MatrixPool.instance.newItem(1, 0, 0, 1, x, y);
		mat.matrix.concat(current.matrix);
		MatrixPool.instance.remove(current);
		current = mat;
		return this;
	}
	
	public function rotate(rad : Number) : MatrixStack
	{
		var mat : MatrixWrap = MatrixPool.instance.newItem(Math.cos(rad), Math.sin(rad), -Math.sin(rad), Math.cos(rad), 0, 0);
		mat.matrix.concat(current.matrix);
		MatrixPool.instance.remove(current);
		current = mat;
		return this;
	}
	
	public function identity() : MatrixStack
	{
		current.matrix.identity();
		
		return this;
	}
	
	public function transform(/*inout*/ pos : Point) : void
	{
		var m : Matrix = current.matrix;
		var tmpx : Number = m.a * pos.x + m.c * pos.y + m.tx * 1;
		var tmpy : Number = m.b * pos.x + m.d * pos.y + m.ty * 1;
		
		pos.x = tmpx;
		pos.y = tmpy;
	}
	
	public function copyTo(/* out */dest : Matrix) : void
	{
		dest.a = current.matrix.a;
		dest.b = current.matrix.b;
		dest.c = current.matrix.c;
		dest.d = current.matrix.d;
		dest.tx = current.matrix.tx;
		dest.ty = current.matrix.ty;
	}
	
	//public function get raw() : Matrix { return current.matrix; } // このプロパティで取り出されるmatrixの寿命は短いので要注意
}
