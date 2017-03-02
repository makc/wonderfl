//【気ままに動くダンボー】
//ダンボーが動きまわります。
//BoxとPlaneの組み合わせで比較的簡単に作れそうなので作ってみました。
//
//ボタン操作でダンボーの増減と、カメラの動きを変更することができます。
//カメラモードをマニュアルにすると、カメラをキーボードとマウスで自由に操作することができます。
//カメラの角度：マウスドラッグ
//カメラ移動：WASDEC or カーソル
package {
	import alternativ7.engine3d.materials.TextureMaterial;
	import flash.display.BitmapData;
	import flash.display.StageQuality
	import flash.display.Sprite;
	import flash.events.Event;
	//
	//Alternativa3D
	import alternativ7.engine3d.containers.ConflictContainer;
	import alternativ7.engine3d.controllers.SimpleObjectController;
	import alternativ7.engine3d.core.Camera3D;
	import alternativ7.engine3d.core.View;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.primitives.Plane;
	//
	//ボタンやラベル
	import com.bit101.components.PushButton;
	import com.bit101.components.Label;
	//
	//ステータス表示
	import net.hires.debug.Stats;
	//
	[SWF(width = 465, height = 465, frameRate = 60 , backgroundColor = "#FFF9E5")]

        public class Main extends Sprite {
		private static var AREA_W:uint = 3000;
		private static var AREA_H:uint = 3000;
		private static var FPS:uint = 60;
		
		//ステータス表示
		private var stats:Stats;
		
		//ボタン、ラベル
		private var btnAdd:PushButton;
		private var btnRemove:PushButton;
		private var btnCamera:PushButton;
		private var labelTotal:Label;
		private var labelCamera:Label;
		
		//3D関連
		private var container:ConflictContainer;
		private var camera:Camera3D;
		private var cameraMode:int;
		private var cameraModeLabels:Vector.<String>;
		private var cameraFrame:int = 0;
		private var cameraChangeFrame:int = 300;
		private var cameraR:Number;
		private var cameraSp:Number;
		private var controller:SimpleObjectController;
		
		private var plane:Plane;
		private var planeMat:TextureMaterial;
		
		private var textures:Textures;
		private var danbords:Vector.<Danbord>;
		private var kages:Vector.<Kage>;
		
		private var addState:Boolean = true;
		
		public function Main():void {
			//stage.quality = StageQuality.LOW;
			
			danbords = new Vector.<Danbord>();
			kages = new Vector.<Kage>();
			
			//container
			container = new ConflictContainer();
			
			//カメラ設定
			camera = new Camera3D();
			cameraModeLabels = new Vector.<String>();
			cameraModeLabels[0] = "Auto";
			cameraModeLabels[1] = "Rotate 1";
			cameraModeLabels[2] = "Rotate 2";
			cameraModeLabels[3] = "Target 1";
			cameraModeLabels[4] = "Target 2";
			cameraModeLabels[5] = "Top";
			cameraModeLabels[6] = "Manual";
			cameraMode = 0;
			cameraR = 0;
			cameraFrame = 0;
			
			container.addChild(camera);
			camera.view = new View(465, 465, false);
			addChild(camera.view);
			camera.y = -1000;
			camera.z = 300
			camera.rotationX = -Math.PI * 0.53;
			controller = new SimpleObjectController(stage, camera, 500);
			
			//
			//床
			planeMat = new TextureMaterial(new BitmapData(8,8,false,0xFF614F3E));
			plane = new Plane(AREA_W, AREA_H, 10, 10, false, false, false, planeMat, planeMat);
			plane.z = -1
			container.addChild(plane);
			
			//テクスチャ
			textures = new Textures();
			
			//ボタン
			btnAdd = new PushButton(this, 80, 5, "AddDanbord", addDanbord);
			btnRemove = new PushButton(this, 80, 30, "RemoveDanbord", removeDanbord);
			labelTotal = new Label(this, 80, 55, "TotalDanbord = " + String(danbords.length));
			
			btnCamera = new PushButton(this, 210, 5, "CameraChange", cameraModeChange);
			labelCamera = new Label(this, 210, 30, "CameraMode = " + cameraModeLabels[cameraMode]);
			
			stats = new Stats();
			addChild(stats);
			
			//ダンボー追加
			for (var i:int = 0; i < 10; i++) {
				addDanbord();
			}
			//イベント
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		//ダンボー追加
		private function addDanbord(_e:Event = null):void {
			var mySc:Number = Math.random() * 1 + 0.5;
			
			var myDanbord:Danbord = new Danbord(textures);
			myDanbord.x = Math.random() * AREA_W - AREA_W * 0.5;
			myDanbord.y = Math.random() * AREA_H - AREA_H * 0.5;
			myDanbord.scaleX = myDanbord.scaleY = myDanbord.scaleZ = mySc;
			container.addChild(myDanbord)
			danbords.push(myDanbord);
			
			
			var myKage:Kage = new Kage(textures);
			myKage.x = myDanbord.x
			myKage.y = myDanbord.y
			myKage.scaleX = myKage.scaleY = myKage.scaleZ = mySc;
			container.addChild(myKage)
			kages.push(myKage);
			
			//
			labelTotal.text = "TotalDanbord = " + String(danbords.length);
		}
		//ダンボー消去
		private function removeDanbord(_e:Event = null):void {
			var myNum:int = danbords.length - 1;
			if (myNum > 0) {
				var myDanbord:Danbord = danbords[myNum];
				//myDanbord.remove();
				container.removeChild(myDanbord);
				danbords[myNum] = null;
				danbords.pop();
				
				var myKage:Kage = kages[myNum];
				container.removeChild(myKage);
				kages[myNum] = null;
				kages.pop();
				
				labelTotal.text = "TotalDanbord = " + String(danbords.length);
			}
		}
		//カメラモードの変更
		private function cameraModeChange(_e:Event = null):void {
			cameraMode++;
			cameraR = 0;
			cameraFrame = 0;
			if (cameraMode >= cameraModeLabels.length) {
				cameraMode = 0;
			}
			if (cameraMode == 6) {
				controller.enable();
				controller.setObjectPosXYZ(0, -1000, 200);
				controller.lookAtXYZ(0, 0, 200);
			}else {
				controller.disable();
			}
			labelCamera.text = "CameraMode = " + cameraModeLabels[cameraMode];
		}
		//毎フレーム実行
		private function onEnterFrameHandler(_e:Event):void {
			//ダンボーのモーション
			var myLength:int = danbords.length;
			for (var i:int = 0; i < myLength; i++) {
				var myDanbord:Danbord = danbords[i];
				//ジャンプしていないときに、一定確率でモーションをランダムに変更
				if (Math.random() < 0.01 && myDanbord.ground == true) {
					myDanbord.setMotionRandom();
				}
				//移動
				myDanbord.x += Math.sin(-myDanbord.bodyR) * myDanbord.sp;
				myDanbord.y += Math.cos(-myDanbord.bodyR) * myDanbord.sp;
				//画面端に移動したら反射
				if (myDanbord.x < -AREA_W * 0.5) {
					myDanbord.x = -AREA_W * 0.5 - (AREA_W * 0.5 + myDanbord.x);
					myDanbord.bodyR = Math.PI - myDanbord.bodyR + Math.PI;
				}else if (myDanbord.x > AREA_W * 0.5) {
					myDanbord.x = AREA_W * 0.5 + (AREA_W * 0.5 - myDanbord.x);
					myDanbord.bodyR = Math.PI - myDanbord.bodyR + Math.PI;
				}
				if (myDanbord.y < -AREA_H * 0.5) {
					myDanbord.y = -AREA_H * 0.5 - (AREA_H * 0.5 + myDanbord.y);
					myDanbord.bodyR = Math.PI - myDanbord.bodyR;
				}else if (myDanbord.y > AREA_H * 0.5) {
					myDanbord.y = AREA_H * 0.5 + (AREA_H * 0.5 - myDanbord.y);
					myDanbord.bodyR = Math.PI - myDanbord.bodyR;
				}
				//ジャンプ時の挙動
				if (myDanbord.ground == false) {
					myDanbord.spZ -= 9.8 / FPS;
					myDanbord.z += myDanbord.spZ;
					if (myDanbord.z <= 0) {
						myDanbord.z = 0;
						myDanbord.spZ = 0;
						myDanbord.ground = true;
						myDanbord.setMotionRandom(false);
					}
				}
				//パーツのモーション
				myDanbord.enterFrameEvent();
				//影を足元に移動
				var myKage:Kage = kages[i];
				myKage.x = myDanbord.x;
				myKage.y = myDanbord.y;
			}
			//
			//オートカメラモードの管理
			var myCameraMode:int = cameraMode;
			if (myCameraMode == 0) {
				cameraFrame++;
				myCameraMode = Math.floor(cameraFrame / cameraChangeFrame) + 1;
				if (myCameraMode >= cameraModeLabels.length - 1) {
					cameraFrame = 0;
					myCameraMode = 1
				}
				
			}
			//
			//カメラを移動
			switch(myCameraMode) {
				case 0:
					break;
				case 1:
					//回転1
					cameraR += 0.007;
					controller.setObjectPosXYZ(Math.cos(cameraR)*1200, Math.sin(cameraR)*1200, 300);
					controller.lookAtXYZ(Math.cos(cameraR + Math.PI * 0.6)*700, Math.sin(cameraR + Math.PI * 0.6)*700, 100);
					break;
				case 2:
					//回転2
					cameraR += 0.005;
					controller.setObjectPosXYZ(Math.cos(cameraR)*1800, Math.sin(cameraR)*1800, 1500);
					controller.lookAtXYZ(0, 0, 0);
					break;
				case 3:
					//ターゲット1
					var myDanbord:Danbord = danbords[danbords.length - 1];
					cameraR += 0.01;
					controller.setObjectPosXYZ(Math.cos(cameraR)*600 + myDanbord.x, Math.sin(cameraR)*600 + myDanbord.y, 300);
					controller.lookAtXYZ(myDanbord.x, myDanbord.y, myDanbord.z + 200);
					break;
				case 4:
					//ターゲット2
					var myDanbord:Danbord = danbords[danbords.length - 1];
					var targetR:Number = myDanbord.bodyR + Math.PI * 0.5;
					while (targetR > cameraR + Math.PI) {
						targetR -= Math.PI * 2;
					}
					while (targetR < cameraR - Math.PI) {
						targetR += Math.PI * 2;
					}
					cameraR += (targetR - cameraR) * 0.03;
					controller.setObjectPosXYZ(Math.cos(cameraR)*400+myDanbord.x, Math.sin(cameraR)*400+myDanbord.y, myDanbord.z + 300);
					controller.lookAtXYZ(myDanbord.x, myDanbord.y, myDanbord.z + 200);
					break;
				case 5:
					//トップ
					controller.setObjectPosXYZ(0, 0, 3000);
					controller.lookAtXYZ(0, 0, 0);
					break;
				case 6:
					//マニュアル
					controller.update();
					break;
				default:
					break;
				
			}
			camera.render();
		}
	}
}
//Texture.as
//テクスチャを一括読み込み
//package {
	import flash.system.LoaderContext;
	//
	//Alternativa3D
	import alternativ7.engine3d.core.Object3DContainer;
	import alternativ7.engine3d.loaders.MaterialLoader;
	import alternativ7.engine3d.materials.TextureMaterial;
		
    //public 
	class Textures {
		//3D関連
		private var loaderContext:LoaderContext;
		private var materialLoader:MaterialLoader;
		
		private var textureMats:Vector.<TextureMaterial>;
		
		public var txMatDanboTop:TextureMaterial;
		public var txMatDanboBottom:TextureMaterial;
		public var txMatDanboFront:TextureMaterial;
		public var txMatDanboLeft:TextureMaterial;
		public var txMatDanboBack:TextureMaterial;
		public var txMatDanboRight:TextureMaterial;
		public var txMatDanboFace:TextureMaterial;
		public var txMatDanboHeadTop:TextureMaterial;
		public var txMatDanboBodyFront:TextureMaterial;
		public var txMatKage:TextureMaterial;
		
		public function Textures():void {
            //テクスチャの読み込み
			txMatDanboTop = new TextureMaterial();
			txMatDanboBottom = new TextureMaterial();
			txMatDanboFront = new TextureMaterial();
			txMatDanboLeft = new TextureMaterial();
			txMatDanboBack = new TextureMaterial();
			txMatDanboRight = new TextureMaterial();
			txMatDanboFace = new TextureMaterial();
			txMatDanboHeadTop = new TextureMaterial();
			txMatDanboBodyFront = new TextureMaterial();
			txMatKage = new TextureMaterial();
			
			txMatDanboTop.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_top.png";
			txMatDanboBottom.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_bottom.png";
			txMatDanboFront.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_front.png";
			txMatDanboLeft.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_left.png";
			txMatDanboBack.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_back.png";
			txMatDanboRight.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_right.png";
			txMatDanboFace.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_face.png";
			txMatDanboHeadTop.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_headtop.png";
			txMatDanboBodyFront.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/danbo_tx_bodyfront.png";
			txMatKage.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/danbord/tx_kage.png";
			
			textureMats = new Vector.<TextureMaterial>();
			
			textureMats.push(txMatDanboTop);
			textureMats.push(txMatDanboBottom);
			textureMats.push(txMatDanboFront);
			textureMats.push(txMatDanboLeft);
			textureMats.push(txMatDanboBack);
			textureMats.push(txMatDanboRight);
			textureMats.push(txMatDanboFace);
			textureMats.push(txMatDanboHeadTop);
			textureMats.push(txMatDanboBodyFront);
			textureMats.push(txMatKage);
            //
            //MaterialLoaderに読み込むテクスチャのリストを投げて、読み込み開始
            loaderContext = new LoaderContext(true);
            materialLoader = new MaterialLoader();
            materialLoader.load(textureMats, loaderContext);
		}
	}
//}
//Danbord.as
//ダンボーの生成とモーション
//package {
	//Alternativa3D
	import alternativ7.engine3d.core.Object3DContainer;
	import alternativ7.engine3d.materials.TextureMaterial;
	import alternativ7.engine3d.primitives.Box;
	import alternativ7.engine3d.primitives.Plane;
		
    //public 
	class Danbord extends Object3DContainer {
		private static var AREA_W:uint = 4000;
		private static var AREA_H:uint = 4000;
		private static var FPS:uint = 60;
		//3D関連
		private var boxHead:Box;
		private var boxBody:Box;
		private var boxSldL:Box;
		private var boxSldR:Box;
		private var boxArmL:Box;
		private var boxArmR:Box;
		private var boxKneL:Box;
		private var boxKneR:Box;
		private var boxLegL:Box;
		private var boxLegR:Box;
		private var planeSktL:Plane;
		private var planeSktR:Plane;
		private var planeSktF:Plane;
		private var planeSktB:Plane;
		
		private var danHead:Object3DContainer;
		private var danBody:Object3DContainer;
		private var danSldL:Object3DContainer;
		private var danSldR:Object3DContainer;
		private var danArmL:Object3DContainer;
		private var danArmR:Object3DContainer;
		private var danKneL:Object3DContainer;
		private var danKneR:Object3DContainer;
		private var danLegL:Object3DContainer;
		private var danLegR:Object3DContainer;
		private var danSktL:Object3DContainer;
		private var danSktR:Object3DContainer;
		private var danSktF:Object3DContainer;
		private var danSktB:Object3DContainer;

		private var motionR:Number = 0;
		private var motionType:String = "stand";
		private var motionTypes:Vector.<String>;
		//
		private var textures:Textures;
		
		public var bodyR:Number = 0;
		public var sp:Number = 0;
		public var spZ:Number = 0;
		public var ground:Boolean = true;
		
		//ダンボー
		public function Danbord(_textures:Textures):void {
			textures = _textures;
			//
			//パーツを埋め込むコンテナの作成（回転軸を中心以外の場所にしたいためコンテナに埋め込んでます）
			danHead = new Object3DContainer();
			danBody = new Object3DContainer();
			danSldL = new Object3DContainer();
			danSldR = new Object3DContainer();
			danArmL = new Object3DContainer();
			danArmR = new Object3DContainer();
			danKneL = new Object3DContainer();
			danKneR = new Object3DContainer();
			danLegL = new Object3DContainer();
			danLegR = new Object3DContainer();
			danSktL = new Object3DContainer();
			danSktR = new Object3DContainer();
			danSktF = new Object3DContainer();
			danSktB = new Object3DContainer();
			
			//パーツを作成
			boxBody = new Box(76, 60, 102, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboBodyFront, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxHead = new Box(160, 102, 102, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFace, textures.txMatDanboBottom, textures.txMatDanboHeadTop);
			boxSldL = new Box(20, 20, 20, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxSldR = new Box(20, 20, 20, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxArmL = new Box(106, 26, 26, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboTop);
			boxArmR = new Box(106, 26, 26, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboTop);
			boxKneL = new Box(20, 20, 20, 1, 1, 1, false, false, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxKneR = new Box(20, 20, 20, 1, 1, 1, false, false, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxLegL = new Box(30, 56, 66, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboBottom);
			boxLegR = new Box(30, 56, 66, 1, 1, 1, false, false, textures.txMatDanboLeft, textures.txMatDanboRight, textures.txMatDanboBack, textures.txMatDanboFront, textures.txMatDanboBottom, textures.txMatDanboBottom);
			planeSktL = new Plane(60, 30, 1, 1, true, false, false, textures.txMatDanboLeft, textures.txMatDanboBottom);
			planeSktR = new Plane(60, 30, 1, 1, true, false, false, textures.txMatDanboRight, textures.txMatDanboBottom);
			planeSktF = new Plane(76, 30, 1, 1, true, false, false, textures.txMatDanboFront, textures.txMatDanboBottom);
			planeSktB = new Plane(76, 30, 1, 1, true, false, false, textures.txMatDanboBack, textures.txMatDanboBottom);
			
			//ステージに追加（パーツごとに親子関係になっています）
			/*
			danBody：体
			-danHead：頭
			-danSldL：左肩
			--danArmL：左腕
			-danSldR：右肩
			--danArmR：右腕
			-boxKneL：左膝
			--boxLegL：左足
			-boxKneR：右膝
			--boxLegR：右足
			-danSktL：スカート右
			-danSktR：スカート左
			-danSktF：スカート前
			-danSktB：スカート後
			*/
			addChild(danBody);
			danBody.addChild(danHead);
			
			danBody.addChild(danSldL);
			danBody.addChild(danSldR);
			danSldL.addChild(danArmL);
			danSldR.addChild(danArmR);
			danBody.addChild(danKneL);
			danBody.addChild(danKneR);
			danKneL.addChild(danLegL);
			danKneR.addChild(danLegR);
			danBody.addChild(danSktL);
			danBody.addChild(danSktR);
			danBody.addChild(danSktF);
			danBody.addChild(danSktB);
			
			danHead.addChild(boxHead);
			danBody.addChild(boxBody);
			danSldL.addChild(boxSldL);
			danSldR.addChild(boxSldR);
			danArmL.addChild(boxArmL);
			danArmR.addChild(boxArmR);
			danKneL.addChild(boxKneL);
			danKneR.addChild(boxKneR);
			danLegL.addChild(boxLegL);
			danLegR.addChild(boxLegR);
			danSktL.addChild(planeSktL);
			danSktR.addChild(planeSktR);
			danSktF.addChild(planeSktF);
			danSktB.addChild(planeSktB);
			
			//座標・角度設定
			boxBody.z = 137
			boxHead.z = 51;
			boxArmL.x = -63;
			boxArmR.x = 63;
			boxLegL.z = -38;
			boxLegR.z = -38;
			
			danArmL.rotationY = -1.3;
			danArmR.rotationY = 1.3;
			
			planeSktL.rotationX = Math.PI * 0.5;
			planeSktL.rotationZ = Math.PI * 0.5;
			planeSktL.z = -15;
			planeSktR.rotationX = Math.PI * 0.5;
			planeSktR.rotationZ = Math.PI * -0.5;
			planeSktR.z = -15
			planeSktF.rotationX = Math.PI * 0.5;
			planeSktF.rotationZ = Math.PI * 0;
			planeSktF.z = -15
			planeSktB.rotationX = Math.PI * 0.5;
			planeSktB.rotationZ = Math.PI * 1;
			planeSktB.z = -15
			
			danBody.z = 0;
			danHead.z = 188;
			danSldL.x = -48;
			danSldL.z = 178;
			danSldR.x = 48;
			danSldR.z = 178;
			
			danKneL.x = -17;
			danKneL.z = 76;
			danKneR.x = 17;
			danKneR.z = 76;
			
			danSktL.x = -38;
			danSktL.z = 86;
			danSktL.rotationY = 0.5;
			danSktR.x = 38;
			danSktR.z = 86;
			danSktR.rotationY = -0.5;
			danSktF.y = 30;
			danSktF.z = 86;
			danSktF.rotationX = 0.5;
			danSktB.y = -30;
			danSktB.z = 86;
			danSktB.rotationX = -0.5;
			
			//
			motionTypes = new Vector.<String>();
			motionTypes[0] = "stand";
			motionTypes[1] = "walk";
			motionTypes[2] = "dash";
			motionTypes[3] = "jump";
			
			bodyR = Math.random() * Math.PI * 2;
			danBody.rotationZ = bodyR;
			setMotionRandom();
		}
		//モーションを設定
		public function setMotion(_motion:String):void {
			if(motionType != _motion){
				motionType = _motion;
				motionR = 0;
				danBody.rotationX = 0;
				danBody.rotationY = 0;
				switch(_motion) {
					case "stand":
						sp = 0;
						break;
					case "walk":
						bodyR = Math.random() * Math.PI * 2;
						danBody.rotationZ = bodyR
						sp = (2 + Math.random() * 2) * scaleX;
						break;
					case "dash":
						bodyR = Math.random() * Math.PI * 2;
						danBody.rotationZ = bodyR
						sp = (6 + Math.random() * 4) * scaleX;
						break;
					case "jump":
						spZ = (8 + Math.random() * 8) * scaleX;
						ground = false;
						break;
					default :
						break;
				}
			}
		}
		//ランダムにモーションを設定（ジャンプの有無）
		public function setMotionRandom(_jump:Boolean = true):void {
			if (_jump) {
				setMotion(motionTypes[Math.floor(Math.random() * motionTypes.length)])
			}else {
				setMotion(motionTypes[Math.floor(Math.random() * (motionTypes.length - 1))])
			}
		}
		//モーション
		public function enterFrameEvent() :void{
			danBody.rotationZ = bodyR;
			switch(motionType) {
				case "stand":
					motionR += 0.03;
					danBody.y = 0;
					danBody.z = 0;
					danHead.rotationX = Math.sin(-motionR) * 0.04;
					danArmL.rotationY = Math.sin(-motionR) * 0.1 + -1.3;
					danArmR.rotationY = Math.sin(motionR) * 0.1 + 1.3;
					danSldL.rotationX = 0;
					danSldR.rotationX = 0;
					danLegL.rotationX = 0;
					danLegR.rotationX = 0;
					danKneL.rotationY = 0;
					danKneR.rotationY = 0;
					break;
				case "walk":
					motionR += 0.1;
					danBody.z = Math.sin(motionR * 2) * 3 + 3;
					danHead.rotationX = Math.cos(motionR*2) * 0.03;
					danArmL.rotationY = -1.3;
					danArmR.rotationY = 1.3;
					danSldL.rotationX = Math.sin(-motionR) * 0.3;
					danSldR.rotationX = Math.sin(motionR) * 0.3;
					danLegL.rotationX = Math.sin(motionR) * 0.4;
					danLegR.rotationX = Math.sin( -motionR) * 0.4;
					danKneL.rotationY = 0;
					danKneR.rotationY = 0;
					break;
				case "dash":
					motionR += 0.23;
					danBody.z = Math.sin(motionR * 2) * 8 + 8;
					danHead.rotationX = Math.cos(motionR*2) * 0.05;
					danArmL.rotationY = -1.3;
					danArmR.rotationY = 1.3;
					danSldL.rotationX = Math.sin(-motionR) * 0.6;
					danSldR.rotationX = Math.sin(motionR) * 0.6;
					danLegL.rotationX = Math.sin(motionR) * 0.6;
					danLegR.rotationX = Math.sin( -motionR) * 0.6;
					danKneL.rotationY = 0;
					danKneR.rotationY = 0;
					break;
				case "jump":
					motionR += 0.23;
					danBody.z = 0;
					danHead.rotationX = Math.max(Math.min(spZ * 0.1, 0.8), -0.5);
					danArmL.rotationY = -Math.max(Math.min(spZ * 0.2, 1.4), -0.2);
					danArmR.rotationY = Math.max(Math.min(spZ * 0.2, 1.4), -0.2);
					danSldL.rotationX = 0;
					danSldR.rotationX = 0;
					danKneL.rotationY = -Math.max(Math.min(spZ * 0.2, 0), -0.2);
					danKneR.rotationY = Math.max(Math.min(spZ * 0.2, 0), -0.2);
					danLegL.rotationX = 0;
					danLegR.rotationX = 0;
					break;
				default :
					break;
			}
		}
	}
//}
//Kage.as
//影
//package {
	//Alternativa3D
	import alternativ7.engine3d.core.Object3DContainer;
	import alternativ7.engine3d.materials.TextureMaterial;
	import alternativ7.engine3d.primitives.Plane;
		
    //public 
	class Kage extends Object3DContainer {
		//3D関連
		private var planeKage:Plane;
		private var textures:Textures;
		
		public function Kage(_textures:Textures):void {
			textures = _textures;
			planeKage = new Plane(200, 200, 1, 1, true, false, false, textures.txMatKage, textures.txMatKage);
			addChild(planeKage);
		}
	}
//}
