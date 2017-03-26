/* Mechanical Clock with Box2D（機械式時計）
 * 
 * 最初はぜんまいが巻かれていない状態です。
 * 左上のボタンをクリックすると最初の数秒間リューズにトルクを加え、ぜんまいが巻かれ、時計が動き始めます。
 * 途中から、30秒間で秒針（四番車）が何度回転するかを計測します。
 * 
 * http://flashjp.com/mecclock
 * 
 * */


package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	[SWF(width=465, height=465, backgroundColor=0xFFFFFF, frameRate=50)]

	public class clockfl extends Sprite {
		
		public var sheets:Sprite = new Sprite();//全体
		public var b2Sheet:Sprite = new Sprite();//box2Dのデバッグを描く
		public var backgroundSheet:Sprite = new Sprite();//背景用画像を描く
		public var textSheet:Sprite = new Sprite();//説明文を書く
		public var clock:Clock;//Clockクラスのオブジェクト
		public var fStart:Boolean = false;//実行時はtrue
		public var appTorqueInfo:Sprite;//トルクを加えている時の矢印など
		public var evaluTF:TextField;//計測結果表示用テキストフィールド
		
		public function clockfl() {
			
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init():void {
			
			stage.addChild(sheets);
			sheets.x = 465 / 2;
			sheets.y = 465 / 2;
			
			sheets.addChild(backgroundSheet);
			sheets.addChild(b2Sheet);
			sheets.addChild(textSheet);
			
			drawBackground();//背景を描く
			
			drawTexts();//説明文などを描く
			
			setButtons();//ボタンをセットする
			
			main();//メインの実行部分
			
		}
		
		private function drawBackground():void {//背景を描く
			
			//var b2bg:Sprite = new Sprite();
			var b2bg:Shape = new Shape();
			b2bg.graphics.lineStyle(0, 0x555555);
			b2bg.graphics.beginFill(0x666666);
			b2bg.graphics.drawRoundRect(-465/2,-465/2,465,465,10);
			b2bg.graphics.endFill();
			
			b2bg.graphics.lineStyle(0, 0xAAAAAA);
			b2bg.graphics.moveTo( -465 / 2, 0);
			b2bg.graphics.lineTo( 465 / 2, 0);
			b2bg.graphics.moveTo(0, -465 / 2);
			b2bg.graphics.lineTo( 0, 465 / 2);
			b2bg.graphics.drawCircle(0, 0, 440 / 2);
			backgroundSheet.addChild(b2bg);
			
			
			drawCrossLine( -8.371 * 10 , 10.2764 * 10 , 5);//アンクルの回転中心を描く
			drawCrossLine( -11.971 * 10 , 7.35 * 10 , 5);//テンプの回転中心を描く
			
			function drawCrossLine(x:Number , y:Number , length:Number):void {
				var lines:Shape = new Shape();
				var length:Number = 5;
				lines.graphics.lineStyle(0, 0xffffff, 0.3);
				lines.graphics.moveTo(x - length, y);
				lines.graphics.lineTo(x + length, y);
				lines.graphics.moveTo(x, y - length);
				lines.graphics.lineTo(x, y + length);
				backgroundSheet.addChild(lines);
			}
			
			
			
		}
		
		private function setButtons():void {//ボタンをセットする
			
			var button1:Sprite = new Sprite();//スタート|ストップボタン
			button1.graphics.lineStyle(0, 0xffffff);
			button1.graphics.beginFill(0xeeeeee);
			button1.graphics.drawRoundRect(0,0, 100,20 , 7);
			button1.graphics.endFill();
			button1.x = -225;
			button1.y = -225;
			button1.buttonMode = true;
			button1.useHandCursor = true;
			button1.addEventListener(MouseEvent.CLICK , bt1ClickHandler);
			backgroundSheet.addChild(button1);
			
			
			var bt1Text:TextField = new TextField();
			bt1Text.width = 100;
			bt1Text.height = 20;
			bt1Text.mouseEnabled = false;
			button1.addChild(bt1Text);
			
			var bt1TF:TextFormat = new TextFormat();
			bt1TF.font ="verdana";
			bt1TF.size = 12;
			bt1TF.align = "center";
			bt1Text.defaultTextFormat = bt1TF;
			bt1Text.text = "click to start";
			
			function bt1ClickHandler(e:MouseEvent):void {//ボタンがクリックされた時の処理
				
				fStart = !fStart;//状態を切り替える
				
				if (fStart) {
					bt1Text.text = "click to stop";
				}else {
					bt1Text.text = "click to start";
				}
			}
		}
		
		private function drawTexts():void {//説明文などを描く
			
			//各部品の名称を書く
			var tfmt:TextFormat = new TextFormat();
			tfmt.font ="verdana";
			tfmt.size = 12;
			tfmt.color = 0xffffff;
			
			setText(145,-135,"リューズ");
			setText(135, -90, "丸穴車");
			setText(-60, -180, "角穴車");
			setText( -180, -115, "香箱車");
			setText(65, 5, "二番車（分針）");
			setText(60, 60, "三番車");
			setText(55, 120, "四番車（秒針）");
			setText( -90, 155, "ガンギ車");
			setText( -140, 120, "アンクル");
			setText( -180, 60, "テンプ");
			
			function setText(x:Number , y:Number , text:String):void {
				var tf:TextField = new TextField();
				tf.x = x;
				tf.y = y;
				tf.text = text;
				tf.mouseEnabled = false;
				tf.setTextFormat(tfmt);
				textSheet.addChild(tf);
			}
			
			
			
			//now applying torque!の画像作成
			appTorqueInfo = new Sprite();
			appTorqueInfo.visible = false;//デフォルトは表示しない
			textSheet.addChild(appTorqueInfo);
			
			var color:Number = 0xffe4e1;
			var arrow:Shape = new Shape();
			var r:Number = 25;
			arrow.graphics.lineStyle(3, color, 0.99);
			arrow.graphics.moveTo(r/2 , -r*1.732/2);
			arrow.graphics.curveTo(0, -r * 2 / 1.732 , -r / 2, -r * 1.732 / 2);
			arrow.graphics.lineTo(-r/2+7 , -r*1.732/2-7);
			appTorqueInfo.addChild(arrow);
			appTorqueInfo.x = 12.97 * 10;
			appTorqueInfo.y = -12.64 * 10;
			
			var textInfo:TextField = new TextField();
			textInfo.text = "now\napplying\ntorque!"
			textInfo.x = -75;
			textInfo.y = -75;
			textInfo.width = 150;
			textInfo.height = 66;
			textInfo.mouseEnabled = false;
			appTorqueInfo.addChild(textInfo);
			
			var textInfoFmt:TextFormat = new TextFormat();
			textInfoFmt.font ="verdana";
			textInfoFmt.size = 12;
			textInfoFmt.color = color;
			textInfoFmt.align = "center";
			textInfoFmt.bold = true;
			textInfo.setTextFormat(textInfoFmt);
			
			
			
			//計測用テキストフィールドの設定
			evaluTF = new TextField();
			evaluTF.x = -230;
			evaluTF.y = 210;
			evaluTF.width = 400;
			evaluTF.defaultTextFormat = tfmt;
			textSheet.addChild(evaluTF);
			
		}
		
		private function main():void {//メインの実行部分
			
			//Clockクラスのオブジェクト作成
			clock = new Clock(b2Sheet);
			
			//初期画面用に実行する（これがないと寂しいので）
			clock.makeStep();
			
			var count:uint = 0;
			var sttAngle:Number;//秒針の角度（計測用）
			var endAngle:Number;//秒針の角度（計測用）
			
			// 毎フレームの処理のリスナー設定
			addEventListener(Event.ENTER_FRAME , EFHandler);
			
			function EFHandler(e:Event):void {// 毎フレームの処理
				
				if (fStart){//実行時のみ処理する
					clock.makeStep();
					
					count++;
					if (count < 250) {//最初の250ステップだけ、リューズを巻き上げる
						clock.wind();
						appTorqueInfo.visible = true;
					}else{
						appTorqueInfo.visible = false;
					}
					
					//精度を測定してみる
					if (count < 1000) {
						evaluTF.text = "もうすぐ精度を測定します";
					}else if (count == 1000) {
						sttAngle = clock._angle;//測定開始時の秒針の角度[ラジアン]
					}else if (count < 2500) {
						evaluTF.text = "測定中 (" + ((count - 1000) / 1500 * 100).toFixed(1) + "%)";
					}else if (count == 2500) {
						endAngle = clock._angle;//測定終了時の秒針の角度[ラジアン]
						var dAngle:Number = endAngle-sttAngle;//実測した秒針の角度の変化[ラジアン]
						var dAngleDeg:Number = dAngle / Math.PI * 180;
						var theoAngle:Number = Math.PI;//理論値では1500ステップ＝30秒=半回転する→π[ラジアン]
						var result:Number = (dAngle-theoAngle) / theoAngle * 100;//理論値との比
						evaluTF.text = "計測終了 30秒での秒針の回転角度は"+dAngleDeg.toFixed(2)+"°(理論値と比べ "+result.toFixed(2)+"%)";
					}
				}
			}
		}
		
	}
}




//Clockクラス
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;
import Box2D.Dynamics.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Common.Math.*;
import Box2D.Dynamics.Joints.*;
internal class Clock {
	
	private const SCALE:Number = 10;//px/m  よって1mが10px
	
	private var world:b2World;
	private var ground:b2Body;
	
	private var crown:Crown;
	private var maruana:Maruana;
	private var kakuana:Kakuana;
	private var koubako:Koubako;
	private var gear2:Gear2;
	private var gear3:Gear3;
	private var gear4:Gear4;
	private var gangi:Gangi;
	private var anchor:Anchor;
	private var tempu:Tempu;
	
	////////////////////////////////////////////////////////////////////
	public function Clock(drawSheet:Sprite) {// コンストラクタ
		
		setBase();//基本設定
		
		setParts();//各部品設定
		
		function setBase():void {//基本設定
			
			// シミュレーションする座標の範囲を指定する
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);
			
			// 重力を定義する
			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// 世界のインスタンスを作成する
			world = new b2World(worldAABB, gravity, true);
			
			// DebugDraw を有効にする
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.m_sprite = drawSheet;// b2bg;
			debugDraw.m_drawScale = SCALE;
			debugDraw.m_fillAlpha =  0.1;
			debugDraw.m_lineThickness = 1;
			debugDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
			world.SetDebugDraw(debugDraw);
			
			//goundの設定
			ground= world.GetGroundBody();
		}
		
		function setParts():void {//各部品設定
			
			//各部品のオブジェクト作成
			crown= new Crown(world , ground);//リューズ
			maruana = new Maruana(world , ground);//丸穴車
			kakuana = new Kakuana(world , ground);//角穴車
			koubako = new Koubako(world , ground);//香箱車
			gear2 = new Gear2(world , ground);//二番車…分針
			gear3 = new Gear3(world , ground);//三番車
			gear4 = new Gear4(world , ground);//四番車…秒針
			gangi = new Gangi(world , ground);//ガンギ車
			anchor = new Anchor(world , ground);//アンクル
			tempu = new Tempu(world , ground);//テンプ
			
			
			//ギアジョイント設定
			setGearJoint(crown.body , maruana.body , crown.revoluteJoint , maruana.revoluteJoint , 1);//リューズと丸穴車
			setGearJoint(maruana.body , kakuana.body , maruana.revoluteJoint , kakuana.revoluteJoint , 1);//丸穴車と角穴車
			setGearJoint(koubako.body , gear2.body1 , koubako.revoluteJoint , gear2.revoluteJoint1 , 1 / 6);//香箱車と二番車（の内側）
			setGearJoint(gear2.body2 , gear3.body1 , gear2.revoluteJoint2 , gear3.revoluteJoint1 , 1 / 8);//二番車（の外側）と三番車（の内側）
			setGearJoint(gear3.body2 , gear4.body1 , gear3.revoluteJoint2 , gear4.revoluteJoint1 , 1 / 7.5);//三番車（の外側）と四番車（の内側）
			setGearJoint(gear4.body2 , gangi.body1 , gear4.revoluteJoint2 , gangi.revoluteJoint1 , 1 / 10);//四番車（の外側）とガンギ車（の内側）
			
			
			//ディスタンスジョイントを設定する（干渉回避用）
			setDistanceJoint(gangi.body2 , gear4.body2);//ガンギ車（の外側）と四番車（の外側）が干渉しないようにディスタンスジョイントでつなぐ
			setDistanceJoint(gangi.body2 , gear3.body2);//ガンギ車（の外側）と三番車（の外側）が干渉しないようにディスタンスジョイントでつなぐ
			
			
			function setGearJoint(b1:b2Body , b2:b2Body , j1:b2RevoluteJoint , j2:b2RevoluteJoint , r:Number):void {//ギアジョイントを設定する
				var gJointDef1:b2GearJointDef = new b2GearJointDef();
				gJointDef1.body1 = b1;
				gJointDef1.body2 = b2;
				gJointDef1.joint1 = j1;
				gJointDef1.joint2 = j2;
				gJointDef1.ratio = r;
				world.CreateJoint(gJointDef1);
			}
			
			function setDistanceJoint(b1:b2Body , b2:b2Body):void {//ディスタンスジョイントを設定する（干渉回避用）
				var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
				jointDef.Initialize(b1, b2, b1.GetWorldCenter() , b2.GetWorldCenter());
				world.CreateJoint(jointDef);
			}
		}
		
	}////////////////////////////////////////////////////////////////////// コンストラクタここまで
	
	
	////////////////////////////////////////////////////////////////////
	public function makeStep():void {//Box2Dで時間を進める
		
		//Box2Dで時間を進める
		world.Step(1 / 50, 10);
		
		
		//角穴車-香箱車の角度差でトルクを決める
		var theKakuanaAngle:Number = kakuana.body.GetAngle();
		var theKoubakoAngle:Number = koubako.body.GetAngle();
		var torque:Number = (theKakuanaAngle - theKoubakoAngle) * 3000;
		//kakuana.body.ApplyTorque(-torque); 
		//↑本来ならこういうトルクがかかるはずですが、逆回転防止のコハゼという機構の代わりに、この行を消すことで角穴車が逆回転しないようにしています
		koubako.body.ApplyTorque(torque);
		
		
		//テンプを回転させる
		var tempuAngle:Number = tempu.body.GetAngle();//テンプの回転角
		torque = tempuAngle* tempu._kr;//回転角とばね定数でトルクを決める
		tempu.body.ApplyTorque(-torque);//トルクを与える
		
	}////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////
	public function wind():void {//リューズを巻く
		crown.body.ApplyTorque(-3000);
	}////////////////////////////////////////////////////////////////////
	
	////////////////////////////////////////////////////////////////////
	public function get _angle():Number {//秒針の角度を返す（計測用）
		return gear4.body2.GetAngle();
	}////////////////////////////////////////////////////////////////////
	
}





//各部品の座標・形状等の物性を扱うための内部クラス・共通関数	
import Box2D.Dynamics.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Collision.Shapes.*;
import Box2D.Common.Math.*;
import flash.geom.Point;

internal class Crown {//竜頭（リューズ）部分
	public var xx:Number = 12.97;//x座標[m]
	public var yy:Number = -12.64;//y座標[m]
	public var radius:Number = 2.92/2;//半径[m]
	public var density:Number = 1;//密度[kg/m^2]
	public var body:b2Body;
	public var revoluteJoint:b2RevoluteJoint;
	public function Crown(world:b2World , ground:b2Body) {
		body = makeGearBody(world , xx , yy , radius , density);
		revoluteJoint = makeRevoluteJoint(world , ground , body);
	}
}

internal class Maruana {//丸穴車
	public var xx:Number = 8.58;//x座標[m]
	public var yy:Number = -8.25;//y座標[m]
	public var radius:Number = 9.39/2;//半径[m]
	public var density:Number = 1;//密度[kg/m^2]
	public var body:b2Body;
	public var revoluteJoint:b2RevoluteJoint;
	public function Maruana(world:b2World , ground:b2Body) {
		body = makeGearBody(world , xx , yy , radius , density);
		revoluteJoint = makeRevoluteJoint(world , ground , body);
	}
}

internal class Kakuana {//角穴車
	public var xx:Number = -3.99;//x座標[m]
	public var yy:Number = -10.22;//y座標[m]
	public var radius:Number = 15.86/2;//半径[m]
	public var density:Number = 1;//密度[kg/m^2]
	public var body:b2Body;
	public var revoluteJoint:b2RevoluteJoint;
	public function Kakuana(world:b2World , ground:b2Body) {
		body = makeGearBody(world , xx , yy , radius , density);
		revoluteJoint = makeRevoluteJoint(world , ground , body);
	}
}

internal class Koubako {//香箱車
	public var xx:Number = -3.99;//x座標[m]
	public var yy:Number = -10.22;//y座標[m]
	public var radius:Number = 19.22/2;//半径[m]
	public var density:Number = 0.005;//密度[kg/m^2]
	public var body:b2Body;
	public var revoluteJoint:b2RevoluteJoint;
	public function Koubako(world:b2World , ground:b2Body) {
		body = makeGearBody(world , xx , yy , radius , density , 0);
		revoluteJoint = makeRevoluteJoint(world , ground , body);
	}
}

internal class Gear2 {//二番車
	public var xx:Number = 0;//x座標[m]
	public var yy:Number = 0;//y座標[m]
	public var radius1:Number = 2.65/2;//半径[m] radius1 < radius2 のこと！
	public var radius2:Number = 12.24/2;//半径[m]
	public var density:Number = 0.001550;//密度[kg/m^2]
	public var body1:b2Body;
	public var body2:b2Body;
	public var revoluteJoint1:b2RevoluteJoint;
	public var revoluteJoint2:b2RevoluteJoint;
	public function Gear2(world:b2World , ground:b2Body) {
		
		body1 = makeGearBody(world , xx , yy , radius1 , density , 0);
		revoluteJoint1 = makeRevoluteJoint(world , ground , body1);
		body2 = makeGearBody(world , xx , yy , radius2 , density , 0);
		revoluteJoint2 = makeRevoluteJoint(world , ground , body2);
		
		//body1,2をdistanceJointでつなぐ
		setDistanceJoint(world , body1, body2 , xx , yy , radius1);
	}
}

internal class Gear3 {//三番車
	public var xx:Number = 0;//x座標[m]
	public var yy:Number = 7.03;//y座標[m]
	public var radius1:Number = 1.85/2;//半径[m] radius1 < radius2 のこと！
	public var radius2:Number = 10.75/2;//半径[m]
	public var density:Number = 0.005;//密度[kg/m^2]
	public var body1:b2Body;
	public var body2:b2Body;
	public var revoluteJoint1:b2RevoluteJoint;
	public var revoluteJoint2:b2RevoluteJoint;
	public function Gear3(world:b2World , ground:b2Body) {
		
		body1 = makeGearBody(world , xx , yy , radius1 , density , 0);
		revoluteJoint1 = makeRevoluteJoint(world , ground , body1);
		body2 = makeGearBody(world , xx , yy , radius2 , density , 0);
		revoluteJoint2 = makeRevoluteJoint(world , ground , body2);
		
		//body1,2をdistanceJointでつなぐ
		setDistanceJoint(world , body1, body2 , xx , yy , radius1);
	}
}

internal class Gear4 {//四番車
	public var xx:Number = 0;//x座標[m]
	public var yy:Number = 13.03;//y座標[m]
	public var radius1:Number = 1.28/2;//半径[m] radius1 < radius2 のこと！
	public var radius2:Number = 9.85/2;//半径[m]
	public var density:Number = 0.005;//密度[kg/m^2]
	public var body1:b2Body;
	public var body2:b2Body;
	public var revoluteJoint1:b2RevoluteJoint;
	public var revoluteJoint2:b2RevoluteJoint;
	public function Gear4(world:b2World , ground:b2Body) {
		
		body1 = makeGearBody(world , xx , yy , radius1 , density , 0);
		revoluteJoint1 = makeRevoluteJoint(world , ground , body1);
		body2 = makeGearBody(world , xx , yy , radius2 , density , 0);
		revoluteJoint2 = makeRevoluteJoint(world , ground , body2);
		
		//body1,2をdistanceJointでつなぐ
		setDistanceJoint(world , body1, body2 , xx , yy , radius1);
	}
}

internal class Gangi {//ガンギ車
	public var xx:Number = -5.69;//x座標[m]
	public var yy:Number = 12.47;//y座標[m]
	public var radius1:Number = 1.51/2;//半径[m] radius1 < radius2 のこと！
	public var radius2:Number = 3.0360;//半径[m]
	public var density:Number = 0.004800;//密度[kg/m^2]
	public var body1:b2Body;
	public var body2:b2Body;
	public var revoluteJoint1:b2RevoluteJoint;
	public var revoluteJoint2:b2RevoluteJoint;
	public function Gangi(world:b2World , ground:b2Body) {
		
		body1 = makeGearBody(world , xx , yy , radius1 , density , 0);
		revoluteJoint1 = makeRevoluteJoint(world , ground , body1);
		
		body2 = makeGangi(world , xx , yy , radius2 , density);
		revoluteJoint2 = makeRevoluteJoint(world , ground , body2);
		
		//body1,2をdistanceJointでつなぐ
		setDistanceJoint(world , body1, body2 , xx , yy , radius1);
	}
}

internal class Anchor {//アンクル
	public var xx:Number =  -8.371;//支点x座標[m]
	public var yy:Number = 10.2764;//支点y座標[m]
	public var density:Number = 0.000240;//密度[kg/m^2]
	public var body:b2Body;
	public var w:Number = 0.404 , h:Number = 0.82;//つめの形状
	public function Anchor(world:b2World , ground:b2Body , l1:Number = 1.79 , l2:Number = 1.79 , thetaL1deg:Number = 32.5,thetaL2deg:Number=149.0 ,thetaTdeg:Number=2) {
		
		//物体の定義
		var bodyDef:b2BodyDef = new b2BodyDef();
		bodyDef.position.Set(xx , yy);//座標[m]
		bodyDef.angularDamping = 0;
		bodyDef.angle = -0.888;
		
		var  thetaT:Number = Math.PI / 180 * thetaTdeg;//ラジアンに変換
		var  thetaL1:Number = Math.PI / 180 * thetaL1deg;//ラジアンに変換
		var  thetaL2:Number = Math.PI / 180 * thetaL2deg;//ラジアンに変換
		
		//物体を作る
		body = world.CreateBody(bodyDef);
		
		// 形の定義を作る（１）右側
		var shapeDef:b2PolygonDef = new b2PolygonDef();
		shapeDef.vertexCount = 4;
		//右下座標
		var RCPt1:Point = new Point(0, 0);//回転中心１
		var RCPt2:Point = new Point(l1, 0);//右下の回転前
		var aPt:Point;
		
		RCPt2 = RotatePoint(RCPt2 , RCPt1, thetaL1);//RCPt1（原点）を中心に回転させる
		shapeDef.vertices[0].Set(RCPt2.x , RCPt2.y);//右下
		
		aPt = RotatePoint(new Point(l1-w , 0) , RCPt1,thetaL1);//左下
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[1].Set(aPt.x , aPt.y);//左下
		
		aPt = RotatePoint(new Point(l1-w , -h) , RCPt1,thetaL1);//左上
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[2].Set(aPt.x , aPt.y);//左上
		
		aPt = RotatePoint(new Point(l1 , -h) , RCPt1,thetaL1);//右上
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[3].Set(aPt.x , aPt.y);//右上
		
		shapeDef.density = density;     // 密度 [kg/m^2]
        shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		// 形を物体に追加する
		body.CreateShape(shapeDef);
		
		
		// 形の定義を作る（２）左側
		shapeDef.vertexCount = 4;
		
		RCPt2 = new Point(l2, 0);//左上の回転前
		
		RCPt2 = RotatePoint(RCPt2 , RCPt1, thetaL2);//RCPt1（原点）を中心に回転させる
		shapeDef.vertices[0].Set(RCPt2.x , RCPt2.y);//左上
		
		aPt = RotatePoint(new Point(l2+w, 0) , RCPt1,thetaL2);//右上
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[1].Set(aPt.x , aPt.y);//右上
		
		aPt = RotatePoint(new Point(l2+w , h) , RCPt1,thetaL2);//右下
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[2].Set(aPt.x , aPt.y);//右下
		
		aPt = RotatePoint(new Point(l2 , h) , RCPt1,thetaL2);//左下
		aPt = RotatePoint(aPt, RCPt2, thetaT);
		shapeDef.vertices[3].Set(aPt.x , aPt.y);//左下
		
        shapeDef.density = density;     // 密度 [kg/m^2]
        shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		// 形を物体に追加する
		body.CreateShape(shapeDef);
		
		
		
		// 形の定義を作る（３）上の左側
		var tDeg:Number = 39.8;
		var tRad:Number = Math.PI / 180 * tDeg;
		w = 0.3;
		h = 0.52;
		
		var wAbs:Number = 0.30;// 0.60;//中心線からの距離
		var hAbs:Number = 3.85;
		RCPt1 = new Point(-wAbs, -hAbs);//回転中心
		shapeDef.vertexCount = 4;
		shapeDef.vertices[0].Set( -wAbs , -hAbs);//右下
		
		aPt = RotatePoint(new Point(-wAbs-w , -hAbs) , RCPt1, -tRad);//左下
		shapeDef.vertices[1].Set(aPt.x , aPt.y);//左下
		
		aPt = RotatePoint(new Point(-wAbs-w , -hAbs - h) , RCPt1, -tRad);//左上
		shapeDef.vertices[2].Set(aPt.x , aPt.y);//左上
		
		aPt = RotatePoint(new Point(-wAbs , -hAbs-h) , RCPt1, -tRad);//右上
		shapeDef.vertices[3].Set(aPt.x , aPt.y);//右上
		
        shapeDef.density = density;// 密度 [kg/m^2]
        shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		// 形を物体に追加する
		body.CreateShape(shapeDef);
		
		
		// 形の定義を作る（４）上の右側
		shapeDef.vertexCount = 4;
		RCPt1 = new Point(wAbs, -hAbs);//回転中心
		
		shapeDef.vertices[0].Set(wAbs , -hAbs);//左下
		
		aPt = RotatePoint(new Point(wAbs , -hAbs-h) , RCPt1, tRad);//左上
		shapeDef.vertices[1].Set(aPt.x , aPt.y);//左上
		
		aPt = RotatePoint(new Point(wAbs+w , -hAbs - h) , RCPt1, tRad);//右上
		shapeDef.vertices[2].Set(aPt.x , aPt.y);//右上
		
		aPt = RotatePoint(new Point(wAbs+w , -hAbs) , RCPt1, tRad);//右下
		shapeDef.vertices[3].Set(aPt.x , aPt.y);//右下
		
        shapeDef.density = density;     // 密度 [kg/m^2]
        shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		// 形を物体に追加する
		body.CreateShape(shapeDef);
		
		
		// 重さ・重心を計算する
		body.SetMassFromShapes();
		
		
		//RevoluteJointの設定
		var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
		jointDef.Initialize(ground, body, new b2Vec2(xx, yy));
		jointDef.lowerAngle =  - Math.PI / 180 * 5;
		jointDef.upperAngle =  + Math.PI / 180 * 5;
		jointDef.enableLimit =  true;//振幅の制限設定の可否
		
		//実際にジョイントを作る
		world.CreateJoint(jointDef);
		
		
		
		function RotatePoint(pt:Point , cpt:Point , rad:Number):Point {//点ptをcptを中心に回転させる
			var xl1:Number = pt.x - cpt.x;
			var yl1:Number = pt.y - cpt.y;
			
			var x2:Number = cpt.x + Math.cos(rad) * xl1 - Math.sin(rad) * yl1;
			var y2:Number = cpt.y + Math.sin(rad) * xl1 + Math.cos(rad) * yl1;
			return new Point(x2, y2);
		}
	}
}

internal class Tempu {//テンプ
	public var xx:Number = -11.971;//x座標[m]
	public var yy:Number = 7.35;//y座標[m]
	public var radius:Number = 0.16;//半径[m]
	public var density:Number = 0.0002;//密度[kg/m^2]
	public var _kr:Number;//ねじりばね定数[N･m/rad]
	public var body:b2Body;
	public function Tempu(world:b2World , ground:b2Body) {
		
		var _m:Number , _r:Number;//慣性モーメント計算用
		
		//物体の定義
		var bodyDef:b2BodyDef = new b2BodyDef();
		bodyDef.position.Set(xx , yy);//座標[m]
		bodyDef.angularDamping = 0;
		bodyDef.isBullet = true;
		
		//物体を作る
		body = world.CreateBody(bodyDef);
		
		var shapeDef:b2CircleDef = new b2CircleDef();
		shapeDef.radius = radius;
		shapeDef.density = density;
		shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		
		var tl:Number = 0.15;//テンプ中心とアンクル支点を内分する割合（0だとテンプ中心）
		shapeDef.localPosition.Set((11.971-8.371)*tl,(10.2764-7.35)*tl);//ここに質量がある
		
		//チェック用
		_m = Math.PI * radius * radius * density;//慣性モーメント計算用ｍ
		_r = Math.sqrt(Math.pow((11.971 - 8.371) * tl, 2) + Math.pow((10.2764 - 7.35) * tl, 2));
		_kr = _m * _r * _r * Math.pow(2.5 * 2 * Math.PI , 2)*2;//*2はカウンター込み
		
		// 形を物体に追加する
		body.CreateShape(shapeDef);
		
		//カウンター
		shapeDef.localPosition.Set((11.971-8.371)*(-tl),(10.2764-7.35)*(-tl));//ここに質量がある
		body.CreateShape(shapeDef);// 形を物体に追加する
		
		
		//外側に二つ錘をつける
		var l:Number = 2.2;//半径
		var lrad:Number = (39.2894+90) * Math.PI / 180;
		radius = 0.30;
		shapeDef.radius =radius;
		shapeDef.density = density;
		shapeDef.friction = 0;
		shapeDef.restitution = 0;
		shapeDef.localPosition.Set(l*Math.cos(lrad),l*Math.sin(lrad));//ここに質量がある
		body.CreateShape(shapeDef);// 形を物体に追加する
		shapeDef.localPosition.Set(-l*Math.cos(lrad),-l*Math.sin(lrad));//ここに質量がある
		body.CreateShape(shapeDef);// 形を物体に追加する
		
		_m = Math.PI * radius * radius * density;//慣性モーメント計算用ｍ
		_kr += _m * l * l * Math.pow(2.5 * 2 * Math.PI , 2)*2;
		
		// 重さ・重心を計算する
		body.SetMassFromShapes();
		
		
		//RevoluteJointの設定
		var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
		jointDef.Initialize(ground, body, new b2Vec2(xx,yy));
		world.CreateJoint(jointDef);
		
	}
}


function makeGearBody(world:b2World , xx:Number , yy:Number , radius:Number , density:Number , angularDamping:Number=3):b2Body {//単純なギア作成
	//物体の定義
	var bodyDef:b2BodyDef = new b2BodyDef();
	bodyDef.position.Set(xx , yy);//座標[m]
	bodyDef.angularDamping = angularDamping;
	
	//物体を作る
	var body:b2Body = world.CreateBody(bodyDef);
	
	// 形の定義を作る
	var shapeDef:b2CircleDef = new b2CircleDef();
	shapeDef.radius = radius;
	shapeDef.density = density;     // 密度 [kg/m^2]
	shapeDef.friction = 0;
	
	// 形を物体に追加する
	body.CreateShape(shapeDef);
	
	// 重さ・重心を計算する
	body.SetMassFromShapes();
	
	return body;
}

function makeRevoluteJoint(world:b2World , ground:b2Body , body:b2Body):b2RevoluteJoint {//body（歯車）を固定するRevoluteJointの作成
	
	//RevoluteJointの設定
	var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
	jointDef.Initialize(ground, body, body.GetWorldCenter());
	
	//実際にジョイントを作る
	var joint:b2RevoluteJoint = b2RevoluteJoint(world.CreateJoint(jointDef));
	
	return joint;
}

function makeGangi(world:b2World , xx:Number , yy:Number , radius:Number , density:Number):b2Body {//ガンギ車外側作成
	//半径radius上の円に15個の小さい円を作成する
	const R:Number = 0.1;
	const N:uint = 15;
	var ii:uint;
	var shapeDef:b2CircleDef;
	var rad:Number;
	var offsetR:Number = Math.PI / 180 * 10;
	
	//物体の定義
	var bodyDef:b2BodyDef = new b2BodyDef();
	bodyDef.position.Set(xx , yy);//座標[m]
	bodyDef.angularDamping = 0;
	bodyDef.isBullet = true;
	
	//物体を作る
	var body:b2Body = world.CreateBody(bodyDef);
	
	for (ii = 0; ii < N; ii++) {
		makeDot(ii);
	}
	
	// 重さ・重心を計算する
	body.SetMassFromShapes();
	
	return body;
	
	function makeDot(nn:uint):void {
		// 形の定義を作る
		rad = (360 / N * nn) / 180 * Math.PI;
		shapeDef = new b2CircleDef();
		shapeDef.radius = R;
		shapeDef.density = density;     // 密度 [kg/m^2]
		shapeDef.localPosition.Set(offsetR+radius*Math.cos(rad), radius*Math.sin(rad));
		shapeDef.friction = 0;
		shapeDef.restitution = 0;
		
		body.CreateShape(shapeDef);// 形を物体に追加する
	}
}

function setDistanceJoint(world:b2World , body1:b2Body, body2:b2Body , cx:Number , cy:Number , r:Number):void {//二番車など内外に歯を持つギアの固定のためのJoint設定
	
	var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
	jointDef.Initialize(body1, body2, new b2Vec2(cx+r, cy) , new b2Vec2(cx, cy+r));
	world.CreateJoint(jointDef);
	
}