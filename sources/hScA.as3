// forked from osamX's ワンダフルクエスト
// forked from nengafl's nengafl
/**=====================================================
 * osamXさんのワンダフルクエストをfolkして3Dにしました。
 * 3Dの実装はAlternativa3Dというライブラリを使っています。
 *
 * Papervision3Dと比べてポリゴン欠けが発生しづらいのが特徴で
 * 今回の実装には向いていました。
 *
 * [How to Play]
 * up, w    : move up
 * down, s  : move down
 * left, a  : move left
 * right, d : move right
 *
 * [Hint]
 * You can change map with edit MAP_DATA
 * ===================================================== */
package {
    import com.bit101.components.ProgressBar;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.ui.Keyboard;
    import alternativ5.engine3d.materials.MovieClipMaterial;
    import alternativ5.engine3d.materials.TextureMaterial;
    import alternativ5.engine3d.primitives.Plane;
    import alternativ5.types.Texture;
    import alternativ5.utils.MathUtils;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.data.Resource;
    import jp.progression.data.getResourceById;

    [SWF(width="465", height="465", frameRate="60", backgroundColor="0x000000")]
    public class WonderflQuest extends Sprite {
        private static const FLDSIZE:uint = 48; //フィールド（マップ上の1マス）の横・縦のドット数
        private static const MAPSIZE:uint = 32; //マップの横・縦のマスの個数

        /**-----------------------------------------------------
         * マップのデータ（ここが木で、あそこが芝生で．．．ってやつ）が入ってます。
         * ここをいじると、マップが変わります。上のfieldListのコメント参照。
         * ----------------------------------------------------- */
        private static const MAP_DATA:Array =
            [
            [9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 2, 1, 1, 1, 1, 1, 0, 6, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 9],
            [9, 9, 9, 9, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 1, 9],
            [9, 9, 9, 9, 0, 0, 0, 0, 0, 1, 0, 1, 3, 8, 3, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 8, 3, 9],
            [9, 9, 9, 9, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 3, 3, 7, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 3, 9],
            [9, 9, 9, 1, 1, 1, 1, 1, 0, 1, 0, 1, 3, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 3, 1, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 0, 0, 0, 7, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 7, 0, 0, 0, 1, 1, 1, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 9],
            [9, 9, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 9],
            [9, 9, 9, 9, 9, 9, 9, 9, 4, 4, 9, 9, 9, 9, 9, 9, 1, 1, 9, 9, 9, 9, 9, 9, 4, 4, 9, 9, 9, 9, 9, 9],
            [9, 9, 0, 0, 0, 9, 9, 0, 0, 0, 0, 6, 0, 6, 6, 7, 1, 1, 0, 0, 0, 9, 9, 0, 0, 0, 0, 6, 0, 0, 0, 9],
            [9, 9, 1, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 7, 0, 1, 1, 1, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 9, 9, 9, 9, 0, 0, 1, 1, 0, 0, 6, 0, 1, 8, 1, 1, 9, 9, 9, 9, 0, 0, 1, 1, 0, 0, 6, 9],
            [9, 9, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 0, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1, 1, 9],
            [9, 9, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 0, 6, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 8, 3, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 8, 3, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 3, 3, 7, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 3, 3, 3, 9],
            [9, 9, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 3, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 3, 1, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 0, 0, 0, 7, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 7, 0, 0, 0, 1, 1, 1, 1, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 9],
            [9, 9, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 9],
            [9, 9, 9, 9, 9, 9, 9, 9, 4, 4, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
            [9, 9, 0, 0, 0, 9, 9, 0, 0, 0, 0, 6, 0, 6, 0, 7, 1, 1, 0, 0, 9, 9, 9, 0, 0, 0, 0, 6, 0, 0, 0, 9],
            [9, 9, 1, 0, 0, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 9],
            [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],
            [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9],

            ];
        private static const SCALE:Number = 3; //勇者やフィールドの拡大率
        private static const SIZE:Number = 465; //ステージの大きさ
        // 空の画像
        private static const SKY_URL:String = "http://clockmaker.jp/labs/100109_wonderfl_quest/imgs/sky.png";
        private static const SPEED:Number = 3; //勇者が歩くスピード FLDSIZEの約数にしてください

        /**-----------------------------------------------------
         * コンストラクタ。　ここが最初に処理されます。
         * ----------------------------------------------------- */
        public function WonderflQuest():void {
            stage.quality = StageQuality.LOW;

            _progress = new ProgressBar();
            addChild(_progress);
            _progress.x = (stage.stageWidth - _progress.width) / 2 >> 0
            _progress.y = (stage.stageHeight - _progress.height) / 2 >> 0

            createMap(); //マップを作る

            yuusha = new Yuusha(); //勇者を作る
            yuusha.scaleX = yuusha.scaleY = SCALE; //勇者を拡大表示
            yuusha.x = yuusha.y = (SIZE - FLDSIZE) / 2; //中央に配置

            yuushaPos = new Point(16 * FLDSIZE, 26 * FLDSIZE); //勇者初期位置
            moveMap(yuushaPos); //マップ移動
        }

        /**-----------------------------------------------------
         * マップの1マス（フィールド）のリストです。
         * ここをいじると好きな画像をマップ上に貼ることができます。
         * 画像のサイズは、基本的に16*16ピクセルです。
         * 形式はjpeg,gif,pngのどれかにしてください。
         * Twitterのアイコン画像取得は、こちらのAPIを使わせてもらってます。
         * http://usericons.relucks.org/
         * ----------------------------------------------------- */
        private const FIELD_IMG_URLS:Array = [
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map0.png", false), //[ 0]: 芝生
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map1.png", false), //[ 1]: 砂
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map2.png", false), //[ 2]: 石畳
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map3.png", false), //[ 3]: フローリング
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map4.png", false), //[ 4]: 橋（縦）
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map5.png", false), //[ 5]: 橋（横）
            new Field("http://clockmaker.jp/labs/100109_wonderfl_quest/imgs/map6.png", true), //[ 6]: 木（小）
            new Field("http://clockmaker.jp/labs/100109_wonderfl_quest/imgs/map7.png", true), //[ 7]: 木（大）
            new Field("http://clockmaker.jp/labs/100109_wonderfl_quest/imgs/ton.png", true), //[ 8]: サボテン
            new Field("http://flash-scope.com/wonderfl/WonderflQuest/map/map9.png", true), //[ 9]: 水
            ];
        /**-----------------------------------------------------
         * 勇者の画像のURLリスト
         * ----------------------------------------------------- */
        private const YUUSHA_IMG_URLS:Array = [
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF1.png", //前向き1
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaF2.png", //前向き2
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB1.png", //後ろ向き1
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaB2.png", //後ろ向き2
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL1.png", //左向き1
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaL2.png", //左向き2
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR1.png", //右向き1
            "http://flash-scope.com/wonderfl/WonderflQuest/yuusha/yuushaR2.png" //右向き2
            ];

        private var _progress:ProgressBar;
        private var _world:BasicTemplate; // Alternativa3Dのテンプレート

        private var _yuusha3D:Plane;
        private var bMapData:Array = []; //フィールドが障害物か否かを記憶
        private var frameCount:Number = 0; //onEnterFrameで使用
        private var keyFlags:Array = [false, false, false, false]; //下上左右のキーが押されているか
        private var map:MovieClip; //マップ本体　これを動かして勇者が移動しているように見せる
        private var walkDirection:int = 4; //歩いていく方向 （0～3：下上左右  4:止）

        private var yuusha:Yuusha; //勇者
        private var yuushaPos:Point; //勇者のマップ上の座標

        /**-----------------------------------------------------
         * マップを作ります。
         * この実装方法は良くないです。遅いし、何回も同じ画像をロードしてます。
         * 画像が別ドメインにある時に、crossdomain.xmlがなくても大丈夫なようにしています。
         * ----------------------------------------------------- */
        private function createMap():void {
            var i:int;
            var cmd:IllegalLoadBitmapData;

            map = new MovieClip();
            bMapData = [];

            var list:SerialList = new SerialList();

            // update progress bar
            list.onPosition = function():void {
                _progress.value = list.position / list.numCommands;
            };

            // Load Field Images
            for (i = 0; i < FIELD_IMG_URLS.length; i++) {
                cmd = new IllegalLoadBitmapData(new URLRequest(FIELD_IMG_URLS[i].url));
                cmd.context = new LoaderContext(true);
                cmd.catchError = function(target:Object, error:Error):void {
                    target.executeComplete();
                };
                list.addCommand(cmd);
            }

            // Load Yuusha Images
            for (i = 0; i < YUUSHA_IMG_URLS.length; i++) {
                cmd = new IllegalLoadBitmapData(new URLRequest(YUUSHA_IMG_URLS[i]));
                cmd.context = new LoaderContext(true);
                cmd.catchError = function(target:Object, error:Error):void {
                    target.executeComplete();
                };
                list.addCommand(cmd);
            }

            // SKY IMAGE
            list.addCommand(new IllegalLoadBitmapData(new URLRequest(SKY_URL), {context: new LoaderContext(true)}));

            // init
            list.addCommand(
                function():void {
                    for (var i:uint = 0; i < MAPSIZE; i++) {
                        bMapData[i] = [];
                        for (var j:uint = 0; j < MAPSIZE; j++) {
                            var field:Field = FIELD_IMG_URLS[MAP_DATA[j][i]];
                            bMapData[i][j] = field.isObstacle;
                            switch (MAP_DATA[j][i]) {
                                case 6:
                                case 7:
                                    field = FIELD_IMG_URLS[0];
                                    break;
                                case 8:
                                    field = FIELD_IMG_URLS[1];
                                    break;
                            }

                            var res:Resource = getResourceById(field.url);
                            if (res) {
                                var bmp:Bitmap = new Bitmap(res.toBitmapData());
                                bmp.x = FLDSIZE * i;
                                bmp.y = FLDSIZE * j;
                                bmp.scaleX = bmp.scaleY = SCALE;
                                map.addChild(bmp);
                            }
                        }
                    }

                    // build bitmap object from images
                    yuusha.build(YUUSHA_IMG_URLS);

                    // 3Dの初期化
                    init3D();

                    //イベントリスナーの登録
                    addEventListener(Event.ENTER_FRAME, loop);
                }
                );
            list.execute();
        }

        /**
         * Init Alternativa3D
         *
         */
        private function init3D():void {
            removeChild(_progress); //ロード画面非表示
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); //イベントリスナーの登録
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp); //イベントリスナーの登録

            var res:Resource = getResourceById(SKY_URL);
            addChild(new Bitmap(res.toBitmapData()));

            // Alternativa3Dを初期化
            _world = new BasicTemplate(465, 465, true);
            addChild(_world);

            var bmd:BitmapData = new BitmapData(map.width, map.height);
            bmd.draw(map);

            var tex:Texture = new Texture(bmd);
            var mat:TextureMaterial = new TextureMaterial(tex);

            var fieldPlane:Plane = new Plane(map.width, map.height, 1, 1);
            fieldPlane.cloneMaterialToAllSurfaces(mat);
            _world.scene.root.addChild(fieldPlane);
            fieldPlane.x = +map.width / 2 >> 0;
            fieldPlane.y = +map.height / 2 >> 0;

            var mcMat:MovieClipMaterial = new MovieClipMaterial(yuusha, FLDSIZE / SCALE, FLDSIZE / SCALE);
            _yuusha3D = new Plane(FLDSIZE, FLDSIZE, 1, 1);
            _yuusha3D.cloneMaterialToAllSurfaces(mcMat);

            _yuusha3D.z = -yuusha.height / 2;
            _yuusha3D.rotationX = MathUtils.toRadian(90);

            _world.scene.root.addChild(_yuusha3D);
            _world.camera.z = -40;

            _world.camera.rotationY = MathUtils.toRadian(180);
            _world.camera.rotationX = MathUtils.toRadian(-100);
            _world.camera.rotationZ = MathUtils.toRadian(180);

            var field:Field;
            var mat2:TextureMaterial;
            var tree:Plane;

            // 木とさぼ㌧だけ立体にする
            for (var i:uint = 0; i < MAPSIZE; i++) {
                for (var j:uint = 0; j < MAPSIZE; j++) {
                    switch (MAP_DATA[i][j]) {
                        case 6:
                        case 7:
                        case 8:
                            field = FIELD_IMG_URLS[MAP_DATA[i][j]];
                            res = getResourceById(field.url);
                            if (res) {
                                mat2 = new TextureMaterial(new Texture(res.toBitmapData()));
                                tree = new Plane(FLDSIZE, FLDSIZE, 1, 1, true);
                                tree.cloneMaterialToAllSurfaces(mat2);
                                _world.scene.root.addChild(tree);
                                tree.x = FLDSIZE * j + FLDSIZE / 2;
                                tree.y = FLDSIZE * i + FLDSIZE / 2;
                                tree.z = -FLDSIZE / 2;
                                tree.rotationX = MathUtils.toRadian(90);
                            }
                            break;
                    }
                }
            }
        }

        /**-----------------------------------------------------
         * 毎フレームの処理。
         * ----------------------------------------------------- */
        private function loop(event:Event):void {
            _yuusha3D.x = yuushaPos.x + FLDSIZE / 2;
            _yuusha3D.y = yuushaPos.y + FLDSIZE / 2;

            _world.camera.x = yuushaPos.x + FLDSIZE / 2;
            _world.camera.y = yuushaPos.y + FLDSIZE + 100;

            //20フレーム毎に処理する
            if (frameCount++ > 20) {
                frameCount = 0;
                yuusha.walk();
            }

            //マップ（勇者）をどの方向に動かすか判定
            if (yuushaPos.x % FLDSIZE == 0 && yuushaPos.y % FLDSIZE == 0) {
                var mapPosX:int = int(yuushaPos.x / FLDSIZE), mapPosY:int = int(yuushaPos.y / FLDSIZE);
                walkDirection = 4; //止まる
                switch (true) {
                    case keyFlags[0]: //下
                        if (yuushaPos.y < (MAPSIZE - 1) * FLDSIZE && !bMapData[mapPosX][mapPosY + 1])
                            walkDirection = 0;
                        yuusha.changeDirection(0);
                        break;
                    case keyFlags[1]: //上
                        if (yuushaPos.y > 0 && !bMapData[mapPosX][mapPosY - 1])
                            walkDirection = 1;
                        yuusha.changeDirection(1);
                        break;
                    case keyFlags[2]: //左
                        if (yuushaPos.x > 0 && !bMapData[mapPosX - 1][mapPosY])
                            walkDirection = 2;
                        yuusha.changeDirection(2);
                        break;
                    case keyFlags[3]: //右
                        if (yuushaPos.x < (MAPSIZE - 1) * FLDSIZE && !bMapData[mapPosX + 1][mapPosY])
                            walkDirection = 3;
                        yuusha.changeDirection(3);
                        break;
                }
            }

            //次のマスまで自動的に勇者を歩かせる
            switch (walkDirection) {
                case 0:
                    yuushaPos.y += SPEED;
                    break;
                case 1:
                    yuushaPos.y -= SPEED;
                    break;
                case 2:
                    yuushaPos.x -= SPEED;
                    break;
                case 3:
                    yuushaPos.x += SPEED;
                    break;
            }
            if (walkDirection < 4)
                moveMap(yuushaPos);
        }

        /**-----------------------------------------------------
         * マップの座標計算。
         * ----------------------------------------------------- */
        private function moveMap(pos:Point):void {
            map.x = (SIZE - FLDSIZE) / 2 - yuushaPos.x;
            map.y = (SIZE - FLDSIZE) / 2 - yuushaPos.y;
        }

        /**-----------------------------------------------------
         * キーボードのキーが押された時の処理。
         * ----------------------------------------------------- */
        private function onKeyDown(event:KeyboardEvent):void {
            switch (event.keyCode) {
                case Keyboard.DOWN:
                case "s".charAt(0): //↓ s
                    keyFlags[0] = true;
            }
            switch (event.keyCode) {
                case Keyboard.UP:
                case "w".charAt(0): //↑ w
                    keyFlags[1] = true;
            }
            switch (event.keyCode) {
                case Keyboard.LEFT:
                case "a".charAt(0): //← a
                    keyFlags[2] = true;
            }
            switch (event.keyCode) {
                case Keyboard.RIGHT:
                case "d".charAt(0): //→ d
                    keyFlags[3] = true;
            }
        }

        /**-----------------------------------------------------
         * キーボードのキーが離された時の処理。
         * ----------------------------------------------------- */
        private function onKeyUp(event:KeyboardEvent):void {
            switch (event.keyCode) {
                case Keyboard.DOWN:
                case "s".charAt(0): //↓ s
                    keyFlags[0] = false;
            }
            switch (event.keyCode) {
                case Keyboard.UP:
                case "w".charAt(0): //↑ w
                    keyFlags[1] = false;
            }
            switch (event.keyCode) {
                case Keyboard.LEFT:
                case "a".charAt(0): //← a
                    keyFlags[2] = false;
            }
            switch (event.keyCode) {
                case Keyboard.RIGHT:
                case "d".charAt(0): //→ d
                    keyFlags[3] = false;
            }
        }
    }
}

import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import alternativ5.engine3d.controllers.CameraController;
import alternativ5.engine3d.core.Camera3D;
import alternativ5.engine3d.core.Object3D;
import alternativ5.engine3d.core.Scene3D;
import alternativ5.engine3d.display.View;
import jp.progression.commands.lists.SerialList;
import jp.progression.commands.net.LoadCommand;
import jp.progression.data.Resource;
import jp.progression.data.getResourceById;

/**-----------------------------------------------------
 * 勇者クラスです。勇者を作ったり、足踏させたり、向きを変えたりします。
 * ----------------------------------------------------- */
class Yuusha extends MovieClip {
    /**-----------------------------------------------------
     * コンストラクタ。
     * ----------------------------------------------------- */
    public function Yuusha():void {
    }

    public var direction:int = 0; //向き　（0:前　1：後　2：左　3：右）
    private var walkFlag:Boolean = true; //足踏み用
    private var yuushaImages:Array = []; //勇者の画像集

    public function build(ImageURL:Array):void {
        for (var i:uint = 0; i < 8; i++) {
            var res:Resource = getResourceById(ImageURL[i]);
            if (res) {
                var bmp:Bitmap = new Bitmap(res.toBitmapData());
                yuushaImages.push(bmp);
                if (i)
                    yuushaImages[i].visible = false;
                addChild(yuushaImages[i]);
            }
        }
    }

    /**-----------------------------------------------------
     * 向きを変更します。
     * numは勇者の向きを表します。（0～3）
     * ----------------------------------------------------- */
    public function changeDirection(num:int):void {
        direction = num;
        for (var i:uint = 0; i < 8; i++) {
            yuushaImages[i].visible = i == 2 * direction + int(walkFlag);
        }
    }

    /**-----------------------------------------------------
     * 足踏みさせます。
     * ----------------------------------------------------- */
    public function walk():void {
        walkFlag = !walkFlag;
        for (var i:uint = 0; i < 8; i++) {
            yuushaImages[i].visible = i == 2 * direction + int(walkFlag);
        }
    }
}

/**-----------------------------------------------------
 * Fieldクラスです。画像のURLと、そのフィールドが障害物か否かを保存します。
 * ----------------------------------------------------- */
class Field {
    public function Field(s:String, b:Boolean = false):void {
        url = s;
        isObstacle = b;
    }
    public var isObstacle:Boolean; //障害物か否か （true:障害物　　false:障害物じゃない（歩ける））
    public var url:String; //画像のURL
}


class BasicTemplate extends Sprite {

    /**
     * 新しい BasicTemplate インスタンスを作成します。
     * @param    viewWidth
     * @param    viewHeight
     * @param    scaleToStage
     */
    public function BasicTemplate(viewWidth:int = 640, viewHeight:int = 480, scaleToStage:Boolean = true) {
        _viewWidth = viewWidth;
        _viewHeight = viewHeight;
        _scaleToStage = scaleToStage;

        // Creating scene
        scene = new Scene3D();
        scene.splitAnalysis = false; // not analysis for performance
        scene.root = new Object3D();

        // Adding camera
        camera = new Camera3D();
        camera.z = -1000;
        scene.root.addChild(camera);

        // camera contoller
        cameraContoller = new CameraController(this);
        cameraContoller.camera = camera;

        // set view
        view = new View();
        view.camera = camera;
        addChild(view);

        // stage
        if (stage)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }
    /**
     * カメラインスタンスです。
     */
    public var camera:Camera3D;
    /**
     * カメラコントローラーです。
     */
    public var cameraContoller:CameraController;
    /**
     * シーンインスタンスです。
     */
    public var scene:Scene3D;
    /**
     * ビューインスタンスです。
     */
    public var view:View;

    /**
     * Event.ENTER_FRAME 時に実行されるレンダリングのイベントです。
     * レンダリング後に実行したい処理を記述します。
     */
    protected var _onPostRender:Function = function():void {};

    /**
     * 初期化されたときに実行されるイベントです。
     * 初期化時に実行したい処理を記述します。
     */
    private var _onInit:Function = function():void {};

    /**
     * Event.ENTER_FRAME 時に実行されるレンダリングのイベントです。
     * レンダリング前に実行したい処理を記述します。
     */
    private var _onPreRender:Function = function():void {};
    private var _scaleToStage:Boolean;
    private var _viewHeight:int;

    private var _viewWidth:int;

    public function get onInit():Function {
        return _onInit;
    }

    public function set onInit(value:Function):void {
        _onInit = value;
    }

    public function get onPostRender():Function {
        return _onPostRender;
    }

    public function set onPostRender(value:Function):void {
        _onPostRender = value;
    }

    public function get onPreRender():Function {
        return _onPreRender;
    }

    public function set onPreRender(value:Function):void {
        _onPreRender = value;
    }

    /**
     * シングルレンダリング(レンダリングを一回だけ)を実行します。
     */
    public function singleRender():void {
        onRenderTick();
    }

    /**
     * レンダリングを開始します。
     */
    public function startRendering():void {
        addEventListener(Event.ENTER_FRAME, onRenderTick);
    }

    /**
     * レンダリングを停止します。
     */
    public function stopRendering():void {
        removeEventListener(Event.ENTER_FRAME, onRenderTick);
    }

    /**
     * 初期化されたときに実行されるイベントです。
     * 初期化時に実行したい処理をオーバーライドして記述します。
     */
    protected function atInit():void {
    }

    /**
     * Event.ENTER_FRAME 時に実行されるレンダリングのイベントです。
     * レンダリング後に実行したい処理をオーバーライドして記述します。
     */
    protected function atPostRender():void {
    }

    /**
     * Event.ENTER_FRAME 時に実行されるレンダリングのイベントです。
     * レンダリング前に実行したい処理をオーバーライドして記述します。
     */
    protected function atPreRender():void {
    }

    /**
     * @private
     */
    private function init(e:Event = null):void {
        // resize
        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);

        // render
        startRendering();

        atInit();
        _onInit();

    }

    /**
     * @private
     */
    private function onRenderTick(e:Event = null):void {
        atPreRender();
        _onPreRender();
        scene.calculate();
        atPostRender();
        _onPostRender();
    }

    /**
     * @private
     */
    private function onResize(event:Event = null):void {
        if (_scaleToStage) {
            view.width = stage.stageWidth;
            view.height = stage.stageHeight;
        } else {
            view.width = _viewWidth;
            view.height = _viewHeight;
        }
    }
}

/**
 * クロスドメイン問題を無視してロードするLoadBitmapData
 * @see http://wonderfl.net/code/5c164cb968b9883d1eee01b236c5206956e57545
 */
class IllegalLoadBitmapData extends LoadCommand {
    public function IllegalLoadBitmapData(request:URLRequest, initObject:Object = null) {
        // 引数を設定する
        _request = request;

        // 親クラスを初期化する
        super(request, initObject);
    }
    private var _context:LoaderContext;
    private var _request:URLRequest;
    private var loaderA:Loader;
    private var loaderB:Loader;

    public function get context():LoaderContext {
        return _context;
    }

    public function set context(value:LoaderContext):void {
        _context = value;
    }

    override protected function executeFunction():void {
        // Loader を作成する
        loaderA = new Loader();

        // イベントリスナーを登録する
        loaderA.contentLoaderInfo.addEventListener(Event.COMPLETE, _complete1);
        loaderA.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _ioError2);
        loaderA.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, super.dispatchEvent);

        // ファイルを読み込む
        loaderA.load(_request, context);
    }

    /**
     * データが正常にロードされたときに送出されます。
     */
    private function _complete1(e:Event):void {
        loaderB = new Loader();
        loaderB.contentLoaderInfo.addEventListener(Event.INIT, _complete2);
        loaderB.loadBytes(loaderA.contentLoaderInfo.bytes);
    }

    private function _complete2(e:Event):void {
        var loader:Loader = e.currentTarget.loader;

        var bmd:BitmapData = new BitmapData(loader.width, loader.height, true, 0x00000000);
        bmd.draw(loader);

        // データを保持する
        super.data = bmd;

        // 処理を終了する
        super.executeComplete();
    }

    private function _ioError2(e:IOErrorEvent):void {
        super.throwError(this, new IOError(e.text));
    }
}