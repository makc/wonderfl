//3Dアクションゲーム
//操作：WASD
//視点：マウス移動
//射撃：左クリック
//跳躍：スペース
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.LoaderContext;
	import flash.ui.Keyboard;
	//
	//ステータス表示
	import net.hires.debug.Stats;
	//
	//Alternativa3D
	import alternativ7.engine3d.loaders.MaterialLoader;
	import alternativ7.engine3d.containers.ConflictContainer;
	import alternativ7.engine3d.controllers.SimpleObjectController;
	import alternativ7.engine3d.core.Camera3D;
	import alternativ7.engine3d.core.View;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.materials.TextureMaterial;
	import alternativ7.engine3d.primitives.Box;
	import alternativ7.engine3d.primitives.Plane;
	import alternativ7.engine3d.primitives.Sphere;
	import alternativ7.engine3d.primitives.GeoSphere;
	import alternativ7.engine3d.objects.Sprite3D;

	[SWF(width = 465, height = 465, frameRate = 60 , backgroundColor = "#000000")]

	public class Main extends Sprite {
		private static var STAGE_W:uint = 465;
		private static var STAGE_H:uint = 465;
		private static var FPS:uint = 60;

		private static var PI2:Number = Math.PI / 180;
		private static var fullScreenSupport:Boolean = true;
		private var stats:Stats;

		private var keyState:KeyState;
		private var isMouseDown:Boolean = false;

		private var cursorX:Number = 0;
		private var cursorY:Number = 0;

		private var cameraPitch:Number = 0;

		//3D関連
		private var container:ConflictContainer;
		private var containerBg:ConflictContainer;
		private var camera:Camera3D;
		private var cameraBg:Camera3D;
		private var controller:SimpleObjectController;
		private var cameraRdmAdd:int = 0;

		//3Dオブジェクト格納
		private var boxs:Vector.<Box>;
		private var particleObjs:Vector.<ParticleObj>;
		private var bulletObjs:Vector.<BulletObj>;
		private var enemyObjs:Vector.<EnemyObj>;

		//テクスチャ
		private var txMatCubeTop:TextureMaterial;;
		private var txMatCubeBottom:TextureMaterial;
		private var txMatCubeFront:TextureMaterial;
		private var txMatCubeLeft:TextureMaterial;
		private var txMatCubeBack:TextureMaterial;
		private var txMatCubeRight:TextureMaterial;
		private var txMatRamiel:TextureMaterial;
		private var txMatKusa0:TextureMaterial;
		private var txMatKusa1:TextureMaterial;
		private var txMatKusa2:TextureMaterial;
		private var txMatKusa3:TextureMaterial;
		private var txMatStar:TextureMaterial;
		private var txMatBg:TextureMaterial;
		private var txMatKage:TextureMaterial;
		private var txMatExp:TextureMaterial;
		//テクスチャ読み込み関連
		private var textures:Vector.<TextureMaterial> ;
		private var materialLoader:MaterialLoader;
		private var loaderContext:LoaderContext;

		private var player:PlayerObj = new PlayerObj();
		private var playerH:int = 30;
		private var player3D:GeoSphere;
		private var player3D2:Box;

		private var kage:Plane;
		private var bg:Sphere;

		private var bgBmd:BitmapData;
		private var bgBmp:Bitmap;

		private var layerMain:Sprite;
		private var layerBg:Sprite;
		private var layerBmp:Sprite;
		

		public function Main():void {
			stage.quality = StageQuality.LOW;
			stats = new Stats();
			//
			//レイヤーを準備
			//レイヤーは、メイン3Dと背景（天球）の２つです。
			//ただし、背景はそのまま表示すると手前レイヤーでロゴが隠れた際に表示が消えてしまう（Alternativa3Dの仕様）ので、
			//レンダリング結果をBitmapDataにdrawして、そちらを表示します。
			bgBmd = new BitmapData(STAGE_W, STAGE_H,false,0x000000);
			bgBmp = new Bitmap(bgBmd);
			layerBg = new Sprite();
			layerMain = new Sprite();
			layerBmp = new Sprite();
			layerBmp.addChild(bgBmp);
			//addChild(layerBg);
			addChild(layerBmp);
			addChild(layerMain);

			//3Dの初期化、*Bgは天球用
			//container
			container = new ConflictContainer();
			containerBg = new ConflictContainer();
			//
			//camera
			camera = new Camera3D();
			cameraBg = new Camera3D();
			container.addChild(camera);
			containerBg.addChild(cameraBg);
			camera.view = new View(STAGE_W, STAGE_H, false);
			cameraBg.view = new View(STAGE_W, STAGE_H, false);
			layerBg.addChild(cameraBg.view);
			layerMain.addChild(camera.view);

			//カメラ設定
			camera.farClipping = 1000;
			camera.x = 0;
			camera.y = -1000;
			camera.z = 100;
			cameraBg.farClipping = 5000;

			controller = new SimpleObjectController(stage, camera, 500);
			controller.lookAtXYZ(0, 0, 0);
			//
			boxs = new Vector.<Box>();
			enemyObjs = new Vector.<EnemyObj>();
			particleObjs = new Vector.<ParticleObj>();
			bulletObjs = new Vector.<BulletObj>();

			//テクスチャの読み込み
			//とりあえず読み込みは一時的にスルー
			txMatCubeTop = new TextureMaterial();
			txMatCubeBottom = new TextureMaterial();
			txMatCubeFront = new TextureMaterial();
			txMatCubeLeft = new TextureMaterial();
			txMatCubeBack = new TextureMaterial();
			txMatCubeRight = new TextureMaterial();
			txMatRamiel = new TextureMaterial();
			txMatKusa0 = new TextureMaterial();
			txMatKusa1 = new TextureMaterial();
			txMatKusa2 = new TextureMaterial();
			txMatKusa3 = new TextureMaterial();
			txMatStar = new TextureMaterial();
			txMatBg = new TextureMaterial();
			txMatKage = new TextureMaterial();
			txMatExp = new TextureMaterial();
			txMatCubeTop.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_top.png";
			txMatCubeBottom.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_bottom.png";
			txMatCubeFront.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_front.png";
			txMatCubeLeft.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_left.png";
			txMatCubeBack.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_back.png";
			txMatCubeRight.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_cube_kusa_right.png";
			txMatRamiel.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_ramiel.png";
			txMatKusa0.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_kusa0.png";
			txMatKusa1.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_kusa1.png";
			txMatKusa2.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_kusa2.png";
			txMatKusa3.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_kusa3.png";
			txMatStar.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_star.png";
			txMatBg.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_air.png";
			txMatKage.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_kage.png";
			txMatExp.diffuseMapURL = "http://garena.sakura.ne.jp/wonderfl/action3d/tx_exp.png";
			textures = new Vector.<TextureMaterial>();
			textures.push(txMatCubeTop);
			textures.push(txMatCubeBottom);
			textures.push(txMatCubeFront);
			textures.push(txMatCubeLeft);
			textures.push(txMatCubeBack);
			textures.push(txMatCubeRight);
			textures.push(txMatRamiel);
			textures.push(txMatKusa0);
			textures.push(txMatKusa1);
			textures.push(txMatKusa2);
			textures.push(txMatKusa3);
			textures.push(txMatStar);
			textures.push(txMatBg);
			textures.push(txMatKage);
			textures.push(txMatExp);
			//
			//MaterialLoaderに読み込むテクスチャのリストを投げて、読み込み開始
			loaderContext = new LoaderContext(true);
			materialLoader = new MaterialLoader()
			materialLoader.load(textures, loaderContext);
			
			//
			//宙に浮かぶキューブ群をBoxを使って生成
			var myBoxTotal:uint = 10;
			for (var x:int = 0; x < myBoxTotal; x++) {
				for (var y:int = 0; y < myBoxTotal; y++) {
					//ボックス生成時に、new Box(1,1,1)で、サイズを１にしたあと、scaleでサイズを変えると、
					//scaleX,scaleY,scaleZの値がボックスの大きさと同等になるので便利
					var myZ:Number = Math.random() * 500;
					var myBox:Box = new Box(1,1,1);
					myBox.faces[0].material = txMatCubeRight;
					myBox.faces[1].material = txMatCubeLeft;
					myBox.faces[2].material = txMatCubeFront;
					myBox.faces[3].material = txMatCubeBack;
					myBox.faces[4].material = txMatCubeTop;
					myBox.faces[5].material = txMatCubeBottom;

					myBox.x = (x - myBoxTotal*0.5) * 100; 
					myBox.y = (y - myBoxTotal*0.5) * 100;
					myBox.z = myZ + 50;
					myBox.scaleX = 100;
					myBox.scaleZ = 100;
					myBox.scaleY = 100;
					myBox.clipping = 1000;

					container.addChild(myBox);
					boxs.push(myBox);
				}
			}
			//
			//敵（ラミエルさん）群をSphereを使って生成
			var myEnemyTotal:uint = boxs.length;
			for (var i:int = 0; i < myEnemyTotal; i++) {
				var mySphere:Sphere = new Sphere(70,4,2,false, txMatRamiel);
				var myX:Number = boxs[i].x;
				var myY:Number = boxs[i].y;
				var myZ:Number = boxs[i].z + 100 + Math.random() * 300;
				
				var myEnemyObj:EnemyObj = new EnemyObj(mySphere, myX, myY, myZ, 10);
				container.addChild(mySphere);
				enemyObjs.push(myEnemyObj);
			}
			//
			//草
			var myKusaTotal:int = 200;
			var myTxs:Array = [txMatKusa0,txMatKusa1,txMatKusa2,txMatKusa3]
			for (var i:int = 0; i < myKusaTotal; i++) {
				var myRdm:int = Math.floor(Math.random() * 4)
				var mySc:Number = Math.random() * 20 + 5
				var myKusa:Sprite3D = new Sprite3D(mySc,mySc,myTxs[myRdm]);
				myKusa.x = Math.random() * 2000 - 1000;
				myKusa.y = Math.random() * 2000 - 1000;
				myKusa.z = mySc;
				container.addChild(myKusa);
			}
			//
			//星
			var myStarTotal:int = 500;
			for (var i:int = 0; i < myStarTotal; i++) {
				var mySc:Number = Math.random() * 10 + 5
				var myStar:Sprite3D = new Sprite3D(mySc,mySc,txMatStar);
				myStar.x = Math.random() * 4000 - 2000;
				myStar.y = Math.random() * 4000 - 2000;
				myStar.z = Math.random() * 2000;
				container.addChild(myStar);
			}
			//
			//プレイヤー
			var playerMaterial:FillMaterial = new FillMaterial(0xFFCC00, 0.5, 1, 0xFF9900);
			player3D = new GeoSphere(30, 1, false, playerMaterial);
			container.addChild(player3D);
			player3D.x = 0;
			player3D.y = 0;
			player3D.z = 0;
			var playerMaterial2:FillMaterial = new FillMaterial(0xFF9900, 1, 1, 0xFF6600);
			player3D2 = new Box(15, 15, 15);
			player3D2.setMaterialToAllFaces(playerMaterial2);
			container.addChild(player3D2);
			kage = new Plane(40, 40, 1, 1, true, false, false, null, txMatKage);
			container.addChild(kage);
			//
			//天球（天球のみ、背景用のcontainerに配置します。）
			bg = new Sphere(4000, 10, 10, true, txMatBg);
			containerBg.addChild(bg);
			//
			//ステータス表示
			addChild(stats);
			//
			//イベント
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			//マウスイベント
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			//キーボードイベント
			keyState = new KeyState();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyState.onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyState.onKeyUp);
		}
		//マウスを押されたとき
		private function mouseDownHandler(_e:MouseEvent):void{
			isMouseDown = true;
		}
		//マウスを放したとき
		private function mouseUpHandler(_e:MouseEvent):void{
			isMouseDown = false;
		}
		//マウスが動いたとき
		private function mouseMoveHandler(_e:MouseEvent):void{
			cursorX = (stage.mouseX - (stage.stageWidth * 0.5)) / (stage.stageWidth * 0.5);
			cursorY = stage.mouseY / stage.stageHeight;
		}
		//毎フレーム実行
		private function onEnterFrameHandler(_e:Event):void {
			//カメラ
			player.sp.w = cursorX * 0.04;
			cameraPitch = -cursorY * Math.PI;
			cameraPitch = Math.max(Math.min(cameraPitch, -Math.PI * 0.1), -Math.PI * 0.8);
			player.point.w += player.sp.w;
			//
			//前後移動
			if (keyState.up) {
				player.sp.y = player.spWalk;
			} else if (keyState.down) {
				player.sp.y = -player.spWalk;
			} else {
				player.sp.y = 0;
			}
			//左右移動
			if (keyState.left) {
				player.sp.x = -player.spWalk;
			} else if (keyState.right) {
				player.sp.x = player.spWalk;
			} else {
				player.sp.x = 0;
			}
			//斜め移動時は補正
			if (player.sp.x != 0 && player.sp.y != 0) {
				player.sp.x *= 0.7071;
				player.sp.y *= 0.7071;
			}
			//ジャンプ
			if (keyState.aP && player.jumpCount < player.jumpMax) {
				//ジャンプボタンが押されていて、ジャンプ可能な状態であれば、ジャンプ開始
				player.sp.z = player.spJump;
				player.ground = false;
				player.jumpCount++;
			} else if (player.point.z > 0 && player.ground == false) {
				//空中にいる時は、重力で落下
				player.sp.z -= 9.8 / FPS;
			}
			//
			//座標移動
			var mySpX:Number = (Math.sin(player.point.w) * player.sp.y) - (Math.sin(player.point.w - Math.PI*0.5) * player.sp.x);
			var mySpY:Number = (Math.cos(player.point.w) * player.sp.y) - (Math.cos(player.point.w - Math.PI*0.5) * player.sp.x)
			var mySpZ:Number = player.sp.z
			var myX:Number = player.point.x + mySpX;
			var myY:Number = player.point.y + mySpY;
			var myZ:Number = Math.max(player.point.z + mySpZ, 0);
			
			var myHit:Boolean = false;
			var myGround:Boolean = false
			
			//キューブとの当たり判定
			//プレイヤーの近くにあるキューブを抽出
			var myHitBoxArray:Array = [];
			for (var i:int = 0; i < boxs.length; i++) {
				var myBox:Box = boxs[i];
				//判定はプレイヤーY軸の上端と下端
				if (lengthTest(myBox, myX, myY, myZ + playerH * 0.5, 200)) {
					myHitBoxArray.push(myBox);
				}
			}
			var myLoop:int = 0;
			if(myHitBoxArray.length > 0){
				for (var i:int = 0; i < myHitBoxArray.length; i++) {
					myX = player.point.x + mySpX;
					myY = player.point.y + mySpY;
					myZ = Math.max(player.point.z + mySpZ, 0);
					
					
					var myBox:Box = myHitBoxArray[i];
					//判定はプレイヤーZ軸の上端と下端
					var myHitB:Boolean = hitTestBox(myBox, myX, myY, myZ);
					var myHitT:Boolean = hitTestBox(myBox, myX, myY, myZ + playerH);
					var myHitG:Boolean = false;
					
					if (myHitB || myHitT) {
						if(player.ground && myHitB && hitTestBox(myBox, myX, myY, myZ + 20) == false){
							mySpZ = 0;
							player.point.z = myBox.z + myBox.scaleZ * 0.5;
							myGround = true;
							player.ground = true;
							player.jumpCount = 0;
						}else if(mySpZ < 0 && myHitB && hitTestBox(myBox, myX, myY, myZ - mySpZ) == false) {
							//着地
							mySpZ = 0;
							player.point.z = myBox.z + myBox.scaleZ * 0.5;
							myGround = true
							player.ground = true;
							player.jumpCount = 0;
						}else if (mySpZ > 0 && myHitT && hitTestBox(myBox, myX - mySpX, myY - mySpY, myZ + playerH)) {
							//ジャンプで頭ぶつけ
							mySpZ = -mySpZ;
							player.point.z = myBox.z - myBox.scaleZ * 0.5 - playerH;
						}else{
							var mySpXL:Number = (Math.sin((player.point.w + Math.PI*0.75)) * player.sp.y) - (Math.sin((player.point.w - Math.PI*0.5 + Math.PI*0.75)) * player.sp.x);
							var mySpYL:Number = (Math.cos((player.point.w + Math.PI*0.75)) * player.sp.y) - (Math.cos((player.point.w - Math.PI*0.5 + Math.PI*0.75)) * player.sp.x)
							
							var mySpXR:Number = (Math.sin((player.point.w - Math.PI*0.75)) * player.sp.y) - (Math.sin((player.point.w - Math.PI*0.5 -Math.PI*0.75)) * player.sp.x);
							var mySpYR:Number = (Math.cos((player.point.w - Math.PI*0.75)) * player.sp.y) - (Math.cos((player.point.w - Math.PI*0.5 - Math.PI*0.75)) * player.sp.x);
							//
							var myAddX:Number = 0;
							var myAddY:Number = 0;
							for (var j:int = 1; j < 6; j++) {
								myAddX = mySpXL * j * 0.2;
								myAddY = mySpYL * j * 0.2;
								if (hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ) == false && hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ + playerH) == false) {
									mySpX += myAddX;
									mySpY += myAddY;
									break;
								}
								myAddX = mySpXR * j * 0.2;
								myAddY = mySpYR * j * 0.2;
								if (hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ) == false && hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ+playerH) == false) {
									mySpX += myAddX;
									mySpY += myAddY;
									break;
								}
								myAddX = -mySpX * j * 0.2;
								myAddY = -mySpY * j * 0.2;
								if (hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ) == false && hitTestBox(myBox,myX + myAddX, myY + myAddY, myZ+playerH) == false) {
									mySpX += myAddX;
									mySpY += myAddY;
									break;
								}
							}
							//XY軸移動時にヒット判定がある場合は、XY軸を補正した後、最初から当たり判定チェックをやり直す
							i = -1;
							myLoop++;
							if (myLoop > 30) {
								//ループ回数が30を超えた場合は強制的に終了
								break;
							}
						}
					}
				}	
			}
			//落下判定
			if (player.point.z <= 0 || myGround == true) {
				//0以下(地面) or キューブ当たり判定の段階で着地してるかどうか
				myGround = true;
			}else {
				//キューブとヒットしているかどうか
				for (var i:int = 0; i < boxs.length; i++) {
					if (myGround == false) {
						var myBox:Box = boxs[i]
						myHitG = hitTestBox(myBox, myX, myY, myZ - 1);
						if (myHitG == true) {
							myGround = true;
						}
					}
				}
			}
			if (myGround == false) {
				player.ground = false;
			}
			
			//影
			var myKageZ:Number = 0;
			for (var i:int = 0; i < boxs.length; i++) {
				var myBox:Box = boxs[i];
				if (hitTestXY(myBox, player.point.x, player.point.y)) {
					var myT:Number = myBox.z + myBox.scaleZ * 0.5;
					if(myT <= player.point.z){
						myKageZ = Math.max(myKageZ, myT);
					}
				}
			}
			kage.z = myKageZ + 3;
			player.sp.x = mySpX;
			player.sp.z = mySpZ
			player.sp.y = mySpY
			player.point.x += mySpX;
			player.point.z += mySpZ;
			player.point.y += mySpY;
			if (player.point.z <= 0) {
				player.point.z = 0;
				player.sp.z = 0
				player.ground = true;
				player.jumpCount = 0;
			}
			
			//プレイヤー座標
			player3D.x = player.point.x
			player3D.y = player.point.y
			player3D.z = player.point.z + 30
			player3D.rotationZ = -player.point.w
			player3D2.x = player3D.x;
			player3D2.y = player3D.y;
			player3D2.z = player3D.z;
			player3D2.rotationX += 0.04
			player3D2.rotationY += 0.043
			player3D2.rotationZ += 0.072
			
			kage.x = player.point.x;
			kage.y = player.point.y;
			
			kage.rotationZ = -player.point.w;
			
			//カメラ座標
			camera.x += ((player3D.x + Math.sin(player.point.w) * -120) - camera.x) * 1;
			camera.y += ((player3D.y + Math.cos(player.point.w) * -120) - camera.y) * 1;
			camera.z += ((player3D.z + 40 + (cameraPitch + Math.PI * 0.5) * -50) - camera.z) * 1;
			
			camera.rotationZ = -player.point.w;
			camera.rotationX += (cameraPitch - camera.rotationX) * 0.2;
			
			//
			//敵
			for (var i:int = 0; i < enemyObjs.length; i++) {
				var myEnemyObj:EnemyObj = enemyObjs[i];
				var mySphere:Sphere = myEnemyObj.sphere;
				var myPoint:Vector3D = myEnemyObj.point
				myEnemyObj.enterFrameAction();
				//当たり判定
				var myHitP:Boolean =  lengthTest(myPoint, player.point.x, player.point.y + playerH * 0.5, player.point.z, 60);
				if (myHitP) {
					addParticle(myPoint.x, myPoint.y, myPoint.z);
					container.removeChild(mySphere);
					myEnemyObj.sphere = null;
					enemyObjs.splice(i, 1);
					i--;
					cameraRdmAdd = 25;
				}
			}
			
			//ショットの判定
			for (var i:int = 0; i < bulletObjs.length; i++) {
				var myBulletObj:BulletObj = bulletObjs[i];
				var mySphere:Sphere = myBulletObj.sphere;
				var myPoint:Vector3D = myBulletObj.point;
				myPoint.x += myBulletObj.sp.x;
				myPoint.y += myBulletObj.sp.y;
				myPoint.z += myBulletObj.sp.z;
				mySphere.x = myPoint.x
				mySphere.y = myPoint.y
				mySphere.z = myPoint.z
				if (myPoint.x < -5000 || 5000 < myPoint.x || myPoint.y < -5000 || 5000 < myPoint.y || myPoint.z < 0 || 5000 < myPoint.z) {
					container.removeChild(mySphere);
					myBulletObj.sphere = null;
					bulletObjs.splice(i, 1);
					i--;
				}else {
					//敵との判定
					var myHitState:Boolean = false;
					for (var j:int = 0; j < enemyObjs.length; j++) {
						var myEnemyObj:EnemyObj = enemyObjs[j];
						var myEnemyPoint:Vector3D = myEnemyObj.point;
						var myHitB:Boolean =  lengthTest(myPoint, myEnemyPoint.x, myEnemyPoint.y, myEnemyPoint.z, 40);
						if (myHitB) {
							//敵にヒット
							myHitState = true;
							addParticleS(myPoint.x,myPoint.y,myPoint.z)
							myEnemyObj.life--;
							myEnemyObj.bulletHit();
							container.removeChild(mySphere);
							myBulletObj.sphere = null;
							bulletObjs.splice(i, 1);
							i--;
							if (myEnemyObj.life <= 0) {
								//敵を破壊
								//カメラの振動を、破壊した敵からの距離に比例して設定
								cameraRdmAdd = Math.max(cameraRdmAdd, Math.min(25, 25 - Math.sqrt(Math.pow(myEnemyPoint.x - camera.x, 2) + Math.pow(myEnemyPoint.y - camera.y, 2) + Math.pow(myEnemyPoint.z - camera.z, 2)) * 0.02));
								addParticle(myEnemyPoint.x, myEnemyPoint.y, myEnemyPoint.z);
								container.removeChild(myEnemyObj.sphere);
								myEnemyObj.sphere = null;
								enemyObjs.splice(j, 1);
							}
							break;
						}
					}
					if(myHitState == false){
						//キューブとの判定（敵にヒットしていない場合のみ）
						for (var j:int = 0; j < boxs.length; j++) {
							var myBox:Box = boxs[j];
							var myHitB:Boolean = hitTestBox(myBox, myPoint.x, myPoint.y, myPoint.z);
							if (myHitB) {
								//キューブとヒット
								container.removeChild(mySphere);
								myBulletObj.sphere = null;
								bulletObjs.splice(i, 1);
								i--;
								break;
							}
						}
					}
				}
				
			}
			
			//パーティクル
			for (var i:int = 0; i < particleObjs.length; i++) {
				var myParticleObj:ParticleObj = particleObjs[i];
				var mySprite3D:Sprite3D = myParticleObj.sprite3D;
				myParticleObj.point.x += myParticleObj.sp.x;
				myParticleObj.point.y += myParticleObj.sp.y;
				myParticleObj.point.z += myParticleObj.sp.z;
				myParticleObj.sp.z -= 9.8 / FPS;
				myParticleObj.life--;
				mySprite3D.x = myParticleObj.point.x;
				mySprite3D.y = myParticleObj.point.y;
				mySprite3D.z = myParticleObj.point.z;
				if (myParticleObj.life < 0 || myParticleObj.point.x < -5000 || 5000 < myParticleObj.point.x || myParticleObj.point.y < -5000 || 5000 < myParticleObj.point.y || myParticleObj.point.z < 0 || 5000 < myParticleObj.point.z) {
					container.removeChild(mySprite3D);
					particleObjs[i].sprite3D = null;
					particleObjs.splice(i, 1);
					i--;
				}
			}
			//マウスが押し下げられているときは、ショット発射
			if (isMouseDown) {
				var myFillMat:FillMaterial = new FillMaterial(0xFF3300, 1, 1, 0xFF6600);
				var mySphere:Sphere = new Sphere(20, 3, 2, false, myFillMat);
				var mySp:Number = 40;
				//プレイヤーの向いている方向にショット発射
				var mySpX:Number = Math.sin(cameraPitch) * (Math.sin(player.point.w + Math.PI) * mySp + Math.random() * 6 - 3);
				var mySpY:Number = Math.sin(cameraPitch) * (Math.cos(player.point.w + Math.PI) * mySp + Math.random() * 6 - 3);
				var mySpZ:Number = Math.cos(cameraPitch) * mySp + Math.random() * 6 - 3;
				var myX:Number = player.point.x + mySpX * 0.4;
				var myY:Number = player.point.y + mySpY * 0.4;
				var myZ:Number = player.point.z + mySpZ * 0.4 + playerH;
				var myBulletObj:BulletObj = new BulletObj(mySphere,myX,myY,myZ,mySpX,mySpY,mySpZ);
				mySphere.rotationX = Math.random() * Math.PI * 2
				mySphere.rotationY = Math.random() * Math.PI * 2
				mySphere.rotationZ = Math.random() * Math.PI * 2
				bulletObjs.push(myBulletObj);
				container.addChild(mySphere);
			}
			//カメラ振動
			if (cameraRdmAdd > 0) {
				cameraRdmAdd -= 1;
				camera.x += Math.random() * cameraRdmAdd - cameraRdmAdd * 0.5
				camera.y += Math.random() * cameraRdmAdd - cameraRdmAdd * 0.5
				camera.z += Math.random() * cameraRdmAdd - cameraRdmAdd * 0.5
			}
			camera.render();
			cameraBg.rotationX = camera.rotationX;
			cameraBg.rotationY = camera.rotationY;
			cameraBg.rotationZ = camera.rotationZ;
			cameraBg.render();
			//
			keyState.keyCheck();
			
			//viewが重なっていると消えてしまう（ロゴ部分を隠すと非表示になる仕様）を回避するため、
			//背景用のviewは別のbitmapDataにdrawしてそちらを表示
			bgBmd.draw(layerBg);
			//bgBmd.draw(layerMain);
		}
		
		//着弾パーティクル追加
		private function addParticleS(agX:Number, agY:Number, agZ:Number):void {
			for (var i:int = 0; i < 8; i++) {
				var mySc:Number = Math.random() * 16 + 16;
				var mySprite3D:Sprite3D = new Sprite3D(mySc,mySc,txMatExp);
				var mySp:Number = 8 + Math.random() * 32;
				var myRX:Number = Math.random() * Math.PI * 2;
				var myRY:Number = Math.random() * Math.PI * 2;
				var myRZ:Number = Math.random() * Math.PI * 2;
				
				var mySpX:Number = Math.sin(myRX) * Math.cos(myRY) * mySp
				var mySpY:Number = Math.sin(myRY) * Math.cos(myRZ) * mySp;
				var mySpZ:Number = Math.sin(myRZ) * Math.cos(myRX) * mySp;
				
				var myLife:int = Math.floor(Math.random() * 10 + 5);
				
				var myParticleObj:ParticleObj = new ParticleObj(mySprite3D, agX + mySpX, agY + mySpY, agZ + mySpZ, mySpX, mySpY, mySpZ, myLife);
				container.addChild(mySprite3D);
				particleObjs.push(myParticleObj);
			}
		}
		//爆発パーティクル追加
		private function addParticle(agX:Number, agY:Number, agZ:Number):void {
			for (var i:int = 0; i < 50; i++) {
				var mySc:Number = Math.random() * 128 + 32;
				var mySprite3D:Sprite3D = new Sprite3D(mySc,mySc,txMatExp);
				var mySp:Number = 5 + Math.random() * 40;
				var myRX:Number = Math.random() * Math.PI * 2;
				var myRY:Number = Math.random() * Math.PI * 2;
				var myRZ:Number = Math.random() * Math.PI * 2;
				
				var mySpX:Number = Math.sin(myRX) * Math.cos(myRY) * mySp
				var mySpY:Number = Math.sin(myRY) * Math.cos(myRZ) * mySp;
				var mySpZ:Number = Math.sin(myRZ) * Math.cos(myRX) * mySp;
				
				var myLife:int = Math.floor(Math.random() * 40 + 20);
				
				var myParticleObj:ParticleObj = new ParticleObj(mySprite3D, agX + mySpX, agY + mySpY, agZ + mySpZ, mySpX, mySpY, mySpZ, myLife);
				container.addChild(mySprite3D);
				particleObjs.push(myParticleObj);
			}
		}
		
		//当たり判定
		private function hitTestBox(agBox:Box, agX:Number, agY:Number, agZ:Number):Boolean {
			if (agBox.x - agBox.scaleX * 0.5 <= agX && agX <= agBox.x + agBox.scaleX * 0.5) {
				if (agBox.y - agBox.scaleY * 0.5 <= agY && agY <= agBox.y + agBox.scaleY * 0.5) {
					if (agBox.z - agBox.scaleZ * 0.5 <= agZ && agZ <= agBox.z + agBox.scaleZ * 0.5) {
						return true;
					}
				}
			}
			return false;
		}
		//
		//当たり判定（XY座標（平面）のみ、Z軸（高さ）を問わず
		private function hitTestXY(agBox:Box, agX:Number, agY:Number):Boolean {
			if (agBox.x - agBox.scaleX * 0.5 <= agX && agX <= agBox.x + agBox.scaleX * 0.5) {
				if (agBox.y - agBox.scaleY * 0.5 <= agY && agY <= agBox.y + agBox.scaleY * 0.5) {
					return true;
				}
			}
			return false;
		}
		//
		//距離判定
		private function lengthTest(agBox:*, agX:Number, agY:Number, agZ:Number, agLength:Number):Boolean {
			if (Math.abs(agBox.x - agX) < agLength) {
				if (Math.abs(agBox.y - agY) < agLength) {
					if (Math.abs(agBox.z - agZ) < agLength) {
						return true;
					}
				}
			}
			return false;
		}
	}
}
//----------------------------------
//PlayerObj.as
//プレイヤーの各種情報を保持
//package {
	import flash.geom.Vector3D;
	//public 
	class PlayerObj {
		public var point:Vector3D;
		public var sp:Vector3D;
		public var ground:Boolean = true;
		
		public var spWalk:Number = 4;
		public var spJump:Number = 7;
		public var jumpMax:uint = 3;
		public var jumpCount:uint = 0
		//
		public function PlayerObj(agX:Number = 0, agY:Number = 0, agZ:Number = 800, agW:Number = 0):void {
			point = new Vector3D(agX, agY, agZ, agW);
			sp = new Vector3D();
		}
	}
//}
//----------------------------------
//EnemyObj.as
//敵の各種情報を保持
//package {
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import alternativ7.engine3d.primitives.Sphere;
	//public 
	class EnemyObj {
		public var sphere:Sphere;
		public var point:Vector3D;
		public var sp:Vector3D;
		public var life:int;
		public var hitFrame:int = 0;
		public var hitState:Boolean = false;
		private var rotSp:Number
		private var rotSpAdd:Number = 0
		//
		public function EnemyObj(_sphere:Sphere, _x:Number = 0, _y:Number = 0, _z:Number = 0, _life:uint = 10):void {
			sphere = _sphere;
			point = new Vector3D(_x, _y, _z);
			sp = new Vector3D();
			life = _life;
			
			sphere.x = _x;
			sphere.y = _y;
			sphere.z = _z;
			
			rotSp = Math.random() * 0.02 + 0.01
		}
		
		public function bulletHit():void {
			if (hitState == false) {
				hitState = true;
				rotSpAdd = 1;
				if(hitFrame == 0){
					sphere.colorTransform = new ColorTransform(1, 1, 1, 1, 180, 180, 180, 0);
					hitFrame = 1;
				}else {
					sphere.colorTransform = new ColorTransform(1, 1, 1, 1, 100, 100, 100, 0);
					hitFrame = 0;
				}
			}
		}
		public function enterFrameAction():void {
			if (hitState) {
				hitState = false;
				sphere.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			}
			sphere.rotationZ += rotSp + rotSpAdd;
			rotSpAdd *= 0.9;
		}
	}
//}
//----------------------------------
//BulletObj.as
//ショットの各種情報を保持
//package {
	import alternativ7.engine3d.primitives.Sphere;
	import flash.geom.Vector3D;
	//public 
	class BulletObj {
		public var point:Vector3D;
		public var sp:Vector3D;
		public var sphere:Sphere
		
		public function BulletObj(_sphere:Sphere, _x:Number = 0, _y:Number = 0, _z:Number = 0, _spX:Number = 0, _spY:Number = 0, _spZ:Number = 0):void {
			sphere = _sphere;
			point = new Vector3D(_x, _y, _z);
			sp = new Vector3D(_spX, _spY, _spZ);
			
			sphere.x = _x;
			sphere.y = _y;
			sphere.z = _z;
		}
	}
//}
//----------------------------------
//ParticleObj.as
//パーティクルの各種情報を保持
//package {
	import alternativ7.engine3d.objects.Sprite3D;
	import flash.geom.Vector3D;
	//public 
	class ParticleObj {
		public var point:Vector3D;
		public var sp:Vector3D;
		public var life:int;
		public var sprite3D:Sprite3D;
		
		public function ParticleObj(_sprite3D:Sprite3D, _x:Number = 0, _y:Number = 0, _z:Number = 0, _spX:Number = 0, _spY:Number = 0, _spZ:Number = 0, _life:int = 30):void {
			sprite3D = _sprite3D;
			point = new Vector3D(_x, _y, _z);
			sp = new Vector3D(_spX, _spY, _spZ);
			life = _life;
			
			sprite3D.x = _x;
			sprite3D.y = _y;
			sprite3D.z = _z;
		}
	}
//}
//----------------------------------
//KeyState.as
//キーボードの操作状態を保存します。
//package {
	//import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	//public 
	class KeyState {
		public var left:Boolean = false;
		public var up:Boolean = false;
		public var right:Boolean = false;
		public var down:Boolean = false;
		public var a:Boolean = false;
		public var b:Boolean = false;
		public var c:Boolean = false;
		public var d:Boolean = false;
		public var p:Boolean = false;
		public var f:Boolean = false;
		public var esc:Boolean = false;
		//
		//押したフレームのみtrue
		public var leftP:Boolean = false;
		public var upP:Boolean = false;
		public var rightP:Boolean = false;
		public var downP:Boolean = false;
		public var aP:Boolean = false;
		public var bP:Boolean = false;
		public var cP:Boolean = false;
		public var dP:Boolean = false;
		public var pP:Boolean = false;
		public var fP:Boolean = false;
		public var escP:Boolean = false;
		//
		public var controlType:uint = 0;
		public var keyChecked:Boolean = false;
		//
		private var aCode:uint = 90;
		private var bCode:uint = 88;
		private var cCode:uint = 67;
		private var dCode:uint = 86;
		private var pCode:uint = 80;
		private var fCode:uint = 70;
		//
		public function onKeyDown(myEvt:KeyboardEvent):void {
			keyChecked = false;
			//trace("[ "+myEvt+" ]キーが押されました")
			switch (myEvt.keyCode) {
				case 37://←
				case 100://テンキー4
				case 65://A
					if (left == false) {
						leftP = true;
					}
					left = true;
					break;
				case 38://↑
				case 104://テンキー8
				case 87://W
					if (up == false) {
						upP = true;
					}
					up = true;
					break;
				case 39://→
				case 102://テンキー6
				case 68://D
					if (right == false) {
						rightP = true;
					}
					right = true;
					break;
				case 40://↓
				case 98://テンキー2
				case 83://S
					if (down == false) {
						downP = true;
					}
					down = true;
					break;
				case aCode://Z
				case 32://SPACE
					if (a == false) {
						aP = true;
					}
					a = true;
					break;
				case bCode://X
					if (b == false) {
						bP = true;
					}
					b = true;
					break;
				case cCode://C
					if (c == false) {
						cP = true;
					}
					c = true;
					break;
				case dCode://V
					if (d == false) {
						dP = true;
					}
					d = true;
					break;
				case pCode://P
					if (p == false) {
						pP = true;
					}
					p = true;
					break;
				case fCode://F
					if (f == false) {
						fP = true;
					}
					f = true;
					break;
				case 27://ESC
					if (esc == false) {
						escP = true;
					}
					esc = true;
					break;
				default :
					break;
			}
		}
		public function onKeyUp(myEvt:KeyboardEvent):void {
			keyChecked = false;
			switch (myEvt.keyCode) {
				case 37://←
				case 100://テンキー4
				case 65://A
					left = false;
					break;
				case 38://↑
				case 104://テンキー8
				case 87://W
					up = false;
					break;
				case 39://→
				case 102://テンキー6
				case 68://D
					right = false;
					break;
				case 40://↓
				case 98://テンキー2
				case 83://S
					down = false;
					break;
				case aCode://Z
				case 32://SPACE
					a = false;
					break;
				case bCode://X
					b = false;
					break;
				case cCode://C
					c = false;
					break;
				case dCode://V
					d = false;
					break;
				case pCode://P
					p = false;
					break;
				case fCode://F
					f = false;
					break;
				case 27://ESC
					esc = false;
					break;
				default :
					break;
			}
		}
		public function keyCheck():void {
			if(keyChecked == false){
				keyChecked = true;
				leftP = false;
				upP = false;
				rightP = false;
				downP= false;
				aP = false;
				bP = false;
				cP = false;
				dP = false;
				pP = false;
				fP = false;
				escP = false;
			}
		}
	}
//}

