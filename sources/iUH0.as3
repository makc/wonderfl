/*
　「アイソ×トリック（Isome-Trick）」
　- アイソメトリック上を動く2Dアクション

　操作方法(How to play)
　- 十字キー(Arrow)
　-- 移動(Move)＆ジャンプ(Jump)

　備考
　- もともとはContinuityというゲームにインスパイアされたもの
　-- http://continuitygame.com/playcontinuity.html
　- そしてもともとは立方体の上を移動させる予定だった
　-- 連結処理やらステージ設計やらステージの回転処理などの対応コストが高いので今回の形式になった
　-- しかし、ある程度は拡張して立方体の上を移動できるように設計しているので、もう少しやればいけるかも

　既知の問題
　- 上の中央ブロックに乗り、ジャンプしながら左を押し続けると空中でひっかかる
　-- さらにそこから右にジャンプして天井の上に移動可能
*/

/*
　立方体に拡張する場合の注意点

　MAPの記述方法
　・展開図に近い形にするのが望ましい

　面の位置と向きの指定方法
　・Objectで指定できると良い
*/

/*
　ToDo
　・プレイヤーの挙動に慣性を
　　・今のLerpだと左入力時だけスリップしてしまう
*/


package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;

    //PV3D
    import org.papervision3d.core.proto.*;
    import org.papervision3d.core.geom.renderables.*;
    import org.papervision3d.scenes.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.cameras.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.render.*;
    import org.papervision3d.view.*;

    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class GameMain extends Sprite {

        //==Const==

//*
        static public const URL_BLOCKS:String = "http://assets.wonderfl.net/images/related_images/6/6d/6def/6defd17e259ec6e4eb1db31cd0b0e8e0e2bc1312";
        static public const URL_PLAYER:String = "http://assets.wonderfl.net/images/related_images/8/8a/8abf/8abf30a6e38d66875d937b49387a20426d0f0cfc";
/*/
        static public const URL_BLOCKS:String = "Blocks.png";
        static public const URL_PLAYER:String = "Player.png";
//*/
        //画面サイズ
        static public const VIEW_W:int = 465;
        static public const VIEW_H:int = 465;

        //１マスの大きさ
        static public const PANEL_LEN:int = 32;

        //マップ
        static public var m_MapIter:int = 0;
        static public const O:int = m_MapIter++;//空白
        static public const W:int = m_MapIter++;//壁
        static public const X:int = m_MapIter++;//トゲ（未対応）
        static public const P:int = m_MapIter++;//プレイヤー
        static public const G:int = m_MapIter++;//ゴール

        //面
        static public var m_StaticPlaneIter:int = 0;
        static public const PLANE_L:int = m_StaticPlaneIter++;
        static public const PLANE_R:int = m_StaticPlaneIter++;
        static public const PLANE_D:int = m_StaticPlaneIter++;
        static public const PLANE_NUM:int = m_StaticPlaneIter;

        static public const MAP:Array = [
            [//L
                [W,W,W,W,W,W],
                [W,O,O,O,W,O],
                [W,O,W,O,O,O],
                [W,O,W,P,O,O],
                [W,O,W,O,O,O],
                [W,O,W,W,W,W],
            ],
            [//R
                [O,O,W,W,W,W],
                [O,O,O,O,G,W],
                [O,O,O,O,W,W],
                [W,O,O,O,O,W],
                [O,O,O,O,O,W],
                [W,W,O,O,O,W],
            ],
            [//D
                [O,W,W,O,O,W],
                [O,O,W,W,O,W],
                [O,O,O,O,O,W],
                [O,O,O,O,O,W],
                [O,O,O,O,O,W],
                [W,O,O,W,W,W],
            ],
        ];

        //面の向き
        static public const DIR_U:int = 0;
        static public const DIR_R:int = 1;
        static public const DIR_D:int = 2;
        static public const DIR_L:int = 3;
        static public const DIR_F:int = 4;
        static public const DIR_B:int = 5;

        //辺
        static public var m_EdgeIter:int = 0;
        static public const EDGE_U:int = m_EdgeIter++;
        static public const EDGE_L:int = m_EdgeIter++;
        static public const EDGE_D:int = m_EdgeIter++;
        static public const EDGE_R:int = m_EdgeIter++;
        static public const EDGE_NUM:int = m_EdgeIter;

        //Planeのつなぎ用Matrix
        static public var PLANE_CONVERT_MTX:Vector.<Vector.<Matrix>>;//[SrcPlaneIndex][DstPlaneIndex]
        //隣接Planeの一覧
        static public var PLANE_CONNECT:Vector.<Vector.<int>>;//[PlaneIndex][EdgeIndex]
        //初期化
        static public function InitPlaneConvertMtx():void{
            var p:int;
            var q:int;

            //Common Init
            {
                //PLANE_CONVERT_MTX
                PLANE_CONVERT_MTX = new Vector.<Vector.<Matrix>>(PLANE_NUM);
                for(p = 0; p < PLANE_NUM; p++){
                    PLANE_CONVERT_MTX[p] = new Vector.<Matrix>(PLANE_NUM);
                    for(q = 0; q < PLANE_NUM; q++){
                        PLANE_CONVERT_MTX[p][q] = null;//new Matrix();
                    }
                }

                //PLANE_CONNECT
                PLANE_CONNECT = new Vector.<Vector.<int>>(PLANE_NUM);
                for(p = 0; p < PLANE_NUM; p++){
                    PLANE_CONNECT[p] = new Vector.<int>(EDGE_NUM);
                    for(q = 0; q < EDGE_NUM; q++){
                        PLANE_CONNECT[p][q] = -1;
                    }
                }
            }

            //Connect
            {
                //PLANE_L <=> PLANE_R
                InitConnect(PLANE_L,EDGE_R, PLANE_R,EDGE_L);

                //PLANE_L <=> PLANE_D
                InitConnect(PLANE_L,EDGE_D, PLANE_D,EDGE_L);

                //PLANE_R <=> PLANE_D
                InitConnect(PLANE_R,EDGE_D, PLANE_D,EDGE_U);
            }
        }
        //相互接続
        static public function InitConnect(in_PlaneSrc:int,in_EdgeSrc:int, in_PlaneDst:int,in_EdgeDst:int):void{
            //PLANE_CONVERT_MTX
            PLANE_CONVERT_MTX[in_PlaneSrc][in_PlaneDst] = CreateBaseMatrix(in_PlaneSrc,in_EdgeSrc, in_PlaneDst,in_EdgeDst);
            PLANE_CONVERT_MTX[in_PlaneDst][in_PlaneSrc] = CreateBaseMatrix(in_PlaneDst,in_EdgeDst, in_PlaneSrc,in_EdgeSrc);

            //PLANE_CONNECT
            PLANE_CONNECT[in_PlaneSrc][in_EdgeSrc] = in_PlaneDst;
            PLANE_CONNECT[in_PlaneDst][in_EdgeDst] = in_PlaneSrc;
        }
        //接続用Matrix生成
        static public function CreateBaseMatrix(in_PlaneSrc:int,in_EdgeSrc:int, in_PlaneDst:int,in_EdgeDst:int):Matrix{
            var SrcW:int = PANEL_LEN * MAP[in_PlaneSrc][0].length;
            var SrcH:int = PANEL_LEN * MAP[in_PlaneSrc].length;
            var DstW:int = PANEL_LEN * MAP[in_PlaneDst][0].length;
            var DstH:int = PANEL_LEN * MAP[in_PlaneDst].length;

            //注意事項
            //- Matrixの想定する座標系と、実際の表示はY軸が反転しているので、回転方向なども逆になる

            //Src => 接続辺を上辺とし、左上が原点となる変換Matrix
            var MtxSrc:Matrix = new Matrix();
//*
            {
                switch(in_EdgeSrc){
                case EDGE_U:
                    MtxSrc.rotate(Math.PI * 0/2);
                    MtxSrc.translate(0,0);
                    break;
                case EDGE_L:
                    MtxSrc.rotate(Math.PI * 3/2);
                    MtxSrc.translate(SrcH,0);
                    break;
                case EDGE_D:
                    MtxSrc.rotate(Math.PI * 2/2);
                    MtxSrc.translate(SrcW,SrcH);
                    break;
                case EDGE_R:
                    MtxSrc.rotate(Math.PI * 1/2);
                    MtxSrc.translate(0,SrcW);
                    break;
                }
            }
//*/
            //接続辺が上辺で左上が原点の状態 => Dstにつながる形への変換Matrix
            var MtxDst:Matrix = new Matrix();
//*
            {
                switch(in_EdgeDst){
                case EDGE_U:
                    MtxDst.rotate(Math.PI * 2/2);
                    MtxDst.translate(DstW,0);
                    break;
                case EDGE_L:
                    MtxDst.rotate(Math.PI * 3/2);
                    MtxDst.translate(0,0);
                    break;
                case EDGE_D:
                    MtxDst.rotate(Math.PI * 0/2);
                    MtxDst.translate(0,DstH);
                    break;
                case EDGE_R:
                    MtxDst.rotate(Math.PI * 1/2);
                    MtxDst.translate(DstW,DstH);
                    break;
                }
            }
//*/

            //それらを合成したものを返す
            return MtxConcat(MtxSrc, MtxDst);
        }

        //面の描画の明るさ（どちらかというと、光源方向を設定して法線方向から計算した方が良い）
        static public const CT_PLANE:Array = [
            //L
            new ColorTransform(0.8,0.8,0.8),
            //R
            new ColorTransform(1.0,1.0,1.0),
            //D
            new ColorTransform(1.3,1.3,1.3),
        ];

        //モード
        static public var ModeIter:int = 0;
        static public const MODE_MAIN:int    = ModeIter++;
        static public const MODE_GOAL:int    = ModeIter++;
        static public const MODE_GAME_OVER:int    = ModeIter++;


        //==Var==

        //Pseudo Singleton
        static public var Instance:GameMain;

        //レイヤー
        public var m_Layer_Root:Sprite = new Sprite();
        public var  m_Layer_Plane:Array = new Array(PLANE_NUM);
        public var   m_Layer_BG:Array = new Array(PLANE_NUM);
        public var   m_Layer_Obj:Array = new Array(PLANE_NUM);
        public var   m_Layer_Player:Array = new Array(PLANE_NUM);

        //画像
        public var m_BitmapData_BG:Array = new Array(PLANE_NUM);

        //PV3D
        //ビューポート
        public var m_Pv3d_ViewPort    :Viewport3D;
        //シーン（表示するものの登録先）
        public var m_Pv3d_Scene        :Scene3D;
        //カメラ
        public var m_Pv3d_Camera    :Camera3D;
        //レンダラ（描画処理）
        public var m_Pv3d_Renderer    :BasicRenderEngine;
        //各面ごとの画像
        public var m_BitmapData_Plane:Vector.<BitmapData> = new Vector.<BitmapData>(PLANE_NUM);

        //プレイヤー
        public var m_Player:Player;

        //ゴール
        public var m_Goal:Goal;

        //テキスト
        public var m_Text:TextField = new TextField();

        //モード
        public var m_Mode:int = MODE_MAIN;


        //==Function==

        //Init
        public function GameMain():void {
            var p:int;

            //Pseudo Singleton
            {
                Instance = this;
            }

            //Static Init
            {
                InitPlaneConvertMtx();
            }

            //PV3D
            {
                //ビューポートの作成
                m_Pv3d_ViewPort = new Viewport3D(VIEW_W, VIEW_H);
                addChild(m_Pv3d_ViewPort);

                //レンダラーの設定
                m_Pv3d_Renderer = new BasicRenderEngine();

                //シーン作成
                m_Pv3d_Scene = new Scene3D();

                // カメラの作成
                m_Pv3d_Camera = new Camera3D();
                m_Pv3d_Camera.z = -2000;
                m_Pv3d_Camera.orbit(-45, 45);
                m_Pv3d_Camera.ortho = true;
                m_Pv3d_Camera.orthoScale = 1.4;
            }

            //PV3D : Plane
            {
                //Plane
                for(p = 0; p < PLANE_NUM; p++){
                    //定数
                    var PlaneW:int = PANEL_LEN * MAP[p][0].length;
                    var PlaneH:int = PANEL_LEN * MAP[p].length;

                    //表示用Bitmap
                    m_BitmapData_Plane[p] = new BitmapData(PlaneW, PlaneH, false, 0x000000);
                    var material:BitmapMaterial = new BitmapMaterial(m_BitmapData_Plane[p]);

                    //生成＆登録
                    var NewPlane:Plane = new Plane(material, PlaneW, PlaneH, 1, 1);
                    m_Pv3d_Scene.addChild(NewPlane);

                    //位置＆向き
                    switch(p){
                    case 0:
                        NewPlane.z =  PlaneW/2;
                        break;
                    case 1:
                        NewPlane.x =  PlaneW/2;
                        NewPlane.rotationY = 90;
                        break;
                    case 2:
                        NewPlane.y = -PlaneW/2;
                        NewPlane.rotationX = 90;
                        NewPlane.rotationY = 90;
                        break;
                    }
                    //→定数の配列として用意したい
                }
            }

            //Layer
            {
                //Root
                //addChild(m_Layer_Root);//デバッグ用などのため、一応残しておく

                //Plane
                for(p = 0; p < PLANE_NUM; p++){
                    m_Layer_Plane[p] = new Sprite();
                    m_Layer_Root.addChild(m_Layer_Plane[p]);

                    //
                    {
                        //背景
                        m_Layer_BG[p] = new Sprite();
                        m_Layer_Plane[p].addChild(m_Layer_BG[p]);

                        //Obj・ゴール
                        m_Layer_Obj[p] = new Sprite();
                        m_Layer_Plane[p].addChild(m_Layer_Obj[p]);

                        //プレイヤー
                        m_Layer_Player[p] = new Sprite();
                        m_Layer_Plane[p].addChild(m_Layer_Player[p]);
                    }
                }

/*
                //仮：表示確認
                m_Layer_Plane[0].x = 0;     m_Layer_Plane[0].y = 0;     
                m_Layer_Plane[1].x = 465/2; m_Layer_Plane[1].y = 0;
                m_Layer_Plane[2].x = 465/2; m_Layer_Plane[2].y = 465/2;
//*/
            }

            //プレイヤー
            {
                m_Player = new Player();
                //m_Layer_Player.addChild(m_Player);//内部で各レイヤーに登録する（なのでレイヤーは事前作成必須）
            }

            //Goal
            {
                m_Goal = new Goal();
                //m_Layer_BG.addChild(m_Goal);//位置が確定したら、そこに登録する
            }

            //MAPに応じた処理
            {
                var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);

                for(p = 0; p < PLANE_NUM; p++){
                    var NumX:int = MAP[p][0].length;
                    var NumY:int = MAP[p].length;

                    var bmd:BitmapData = new BitmapData(NumX * PANEL_LEN, NumY * PANEL_LEN, false, 0x000000);
                    m_BitmapData_BG[p] = bmd;

                    for(var y:int = 0; y < NumY; y++){
                        rect.y = y * PANEL_LEN;

                        for(var x:int = 0; x < NumX; x++){
                            rect.x = x * PANEL_LEN;

                            switch(MAP[p][y][x]){
                            case W:
                                //ロード前用の仮描画
                                bmd.fillRect(rect, 0xFF444444);
                                break;
                            case P:
                                //プレイヤーの位置指定
                                m_Player.SetPlaneIndex(p);
                                m_Player.SetPos(
                                    (x+0.5) * PANEL_LEN,
                                    (y+0.5) * PANEL_LEN
                                );
                                break;
                            case G:
                                //ゴールの位置指定
                                m_Goal.SetPlaneIndex(p);
                                m_Goal.SetPos(
                                    (x+0.5) * PANEL_LEN,
                                    (y+0.5) * PANEL_LEN
                                );
                                break;
                            }
                        }
                    }
                }
            }

            //背景
            {
                for(p = 0; p < PLANE_NUM; p++){
                    m_Layer_BG[p].addChild(new Bitmap(m_BitmapData_BG[p]));
                }
            }

            //Text
            {
                m_Text.selectable = false;
                m_Text.autoSize = TextFieldAutoSize.LEFT;
                m_Text.defaultTextFormat = new TextFormat('Verdana', 64, 0xFFFF00, true);
                m_Text.text = '';
                m_Text.filters = [new GlowFilter(0xFF0000)];

                addChild(m_Text);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }

            //画像ロード開始
            {
                const LoadFunc:Function = function(in_URL:String, in_OnLoad:Function):void{
                    var loader:Loader = new Loader();
                    loader.load(new URLRequest(in_URL), new LoaderContext(true));//画像のロードを開始して
                    loader.contentLoaderInfo.addEventListener(
                        Event.COMPLETE,//ロードが完了したら
                        function(e:Event):void{
                            in_OnLoad(loader.content);//初期化に入る
                        }
                    );
                }

                LoadFunc(URL_BLOCKS, OnLoadEnd_Blocks);
                LoadFunc(URL_PLAYER, OnLoadEnd_Player);
            }
        }

        public function OnLoadEnd_Blocks(in_Graphic:DisplayObject):void{
            //Init ImageManager
            {
                ImageManager.Init(in_Graphic);//それを保持した後
            }

            //ブロック描画
            {
                for(var p:int = 0; p < PLANE_NUM; p++){
                    ImageManager.DrawBlocks(MAP[p], m_BitmapData_BG[p]);
                }
            }
        }

        public function OnLoadEnd_Player(in_Graphic:DisplayObject):void{
            //プレイヤー
            {
                var mtx:Matrix = new Matrix(1,0,0,1, 0,0);

                for(var i:int = 0; i < Player.GRAPHIC_NUM; i++){
                    var bmd:BitmapData = m_Player.m_BitmapDataList[i];
                    //Clear
                    bmd.fillRect(bmd.rect, 0x00000000);
                    //Draw
                    mtx.tx = -i*24;
                    mtx.ty = -PANEL_LEN;
                    bmd.draw(in_Graphic, mtx);
                }
            }
        }

        //Update
        static public var fff:int = 0;
        public function Update(e:Event=null):void{
            var DeltaTime:Number = 1.0 / stage.frameRate;

            //Player
            {
                m_Player.Update(DeltaTime);
            }

            //Goal
            {
                m_Goal.Update();
            }

            //Camera
            {
                Update_Camera();
            }

            //Draw
            {
                //Layer => Plane
                for(var p:int = 0; p < PLANE_NUM; p++){
                    m_BitmapData_Plane[p].draw(m_Layer_Plane[p], null, CT_PLANE[p]);
                }

                //PV3D
                m_Pv3d_Renderer.renderScene(m_Pv3d_Scene, m_Pv3d_Camera, m_Pv3d_ViewPort);
            }
/*
            //Debug
            {
                m_Pv3d_Camera.orbit(-45, fff++);
                m_Text.text = fff.toString();
            }
//*/
        }

        //Update : Camera
        public function Update_Camera():void{
/*
            var CAMERA_W:int = stage.stageWidth;
            var CAMERA_H:int = stage.stageHeight;

            var PlayerX:int = m_Player.x;
            var PlayerY:int = m_Player.y;

            var CameraLX:int = PlayerX - CAMERA_W*0.5;
            var CameraUY:int = PlayerY - CAMERA_H*0.5;

            var RootX:int;
            {
                RootX = -CameraLX;
                if(RootX < -MAP_W + CAMERA_W){
                    RootX = -MAP_W + CAMERA_W;
                }
                if(RootX > 0){
                    RootX = 0;
                }
            }

            var RootY:int;
            {
                RootY = -CameraUY;
                if(RootY < -MAP_H + CAMERA_H){
                    RootY = -MAP_H + CAMERA_H;
                }
                if(RootY > 0){
                    RootY = 0;
                }
            }

            m_Layer_Root.x = RootX;
            m_Layer_Root.y = RootY;
//*/
        }

        //Goal
        public function OnGoal():void{
            //Mode
            {
                m_Mode = MODE_GOAL;
            }

            //Text
            {
                //Text
                m_Text.text = 'Clear';

                //Centering
                m_Text.x = (stage.stageWidth - m_Text.width) / 2;
                m_Text.y = (stage.stageHeight - m_Text.height) / 2;
            }
        }

        //Game Over : Damage
        public function OnDead_Damage():void{
            //Mode
            {
                m_Mode = MODE_GAME_OVER;
            }

            //Text
            {
                //Text
                m_Text.text = 'Game Over';

                //Centering
                m_Text.x = (stage.stageWidth - m_Text.width) / 2;
                m_Text.y = (stage.stageHeight - m_Text.height) / 2;
            }
        }

        //Game Over : Fall
        public function OnDead_Fall():void{
            //Mode
            {
                m_Mode = MODE_GAME_OVER;
            }

            //Text
            {
                //Text
                m_Text.text = 'Game Over';

                //Centering
                m_Text.x = (stage.stageWidth - m_Text.width) / 2;
                m_Text.y = (stage.stageHeight - m_Text.height) / 2;
            }
        }
/*
        //
        public function IsWall(in_PlaneIndex:int, in_X:int, in_Y:int):Boolean{
            //実際に考慮する面
            var PlaneIndex:int = in_PlaneIndex;
            {
                for(;;){
                    //範囲外にはみ出したら、考慮する面などを変更する
                    var NumX:int = MAP[PlaneIndex][0].length;
                    var NumY:int = MAP[PlaneIndex].length;
                    if(in_X < 0){
                        PlaneIndex = NEXT_PLANE_INDEX[PlaneIndex][EDGE_L];
                        if(PlaneIndex < 0){return false;}//画面外

                        NextNumX = MAP[PlaneIndex][0].length;
                        in_X += NextNumX * PANEL_LEN;
                        continue;
                    }
                    if(in_X > NumX){
                        PlaneIndex = NEXT_PLANE_INDEX[PlaneIndex][EDGE_R];
                        if(PlaneIndex < 0){return false;}//画面外

                        in_X -= NumX * PANEL_LEN;
                        continue;
                    }

                    break;
                }
            }
        }
//*/
        //#IsGameOver
        public function IsEnd():Boolean{
            return (m_Mode != MODE_MAIN);
        }

        //Utility
        public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
            return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
        }
        //BaseMtxをかけた後にAppendMtxをかけるようなMatrixを計算して返す
        static public function MtxConcat(in_BaseMtx:Matrix, in_AppendMtx:Matrix):Matrix{
/*
            in_BaseMtx.concat(in_AppendMtx);//concatだとダメっぽい
            return in_BaseMtx;
/*/
            var Mtx:Matrix = new Matrix(
                in_AppendMtx.a*in_BaseMtx.a + in_AppendMtx.b*in_BaseMtx.c,
                in_AppendMtx.a*in_BaseMtx.b + in_AppendMtx.b*in_BaseMtx.d,
                in_AppendMtx.c*in_BaseMtx.a + in_AppendMtx.d*in_BaseMtx.c,
                in_AppendMtx.c*in_BaseMtx.b + in_AppendMtx.d*in_BaseMtx.d,

                in_AppendMtx.a*in_BaseMtx.tx + in_AppendMtx.b*in_BaseMtx.ty + in_AppendMtx.tx,
                in_AppendMtx.c*in_BaseMtx.tx + in_AppendMtx.d*in_BaseMtx.ty + in_AppendMtx.ty
            );
            return Mtx;
//*/
        }
    }
}


import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import flash.ui.*;


//#Player
class Player extends Sprite
{
    //==Const==

    //移動速度
    static public const VEL_X:Number = 100.0;

    //ジャンプ速度
    static public const JUMP_VEL:Number = 270.0;

    //重力
    static public const GRAVITY:Number = 500.0;

    //最高下降速度（ロックによって無限落下が可能なので、速度制限してみる）
    static public const FALL_VEL_MIN:Number = 1000.0;

    //アニメーション用パラメータ
    static public const ANIM_CYCLE:Number = 1.0;
    static public const ANIM_ITER:Array = [0,1,2,1];
    static public const ANIM_NUM:int = ANIM_ITER.length;

    //用意されたグラフィックの数
    static public const GRAPHIC_NUM:int = 3;

    //向き
    static public const DIR_U:int = 0;
    static public const DIR_R:int = 1;
    static public const DIR_D:int = 2;
    static public const DIR_L:int = 3;


    //==Var==

    //移動まわりのパラメータ
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);

    //現在居るPlaneのIndex
    public var m_PlaneIndex:int = 0;

    //Planeをまたぐため、各PlaneごとにMatrixを用意し、値はm_Posなどで共通で持つ
    public var m_BaseMtx:Vector.<Matrix> = new Vector.<Matrix>(GameMain.PLANE_NUM);

    //入力
    public var m_InputL:Boolean = false;
    public var m_InputR:Boolean = false;
    public var m_InputU:Boolean = false;

    //表示画像
    public var m_Image:Vector.<Sprite> = new Vector.<Sprite>(GameMain.PANEL_LEN);//各面にこれを表示する
    public var m_Bitmap:Vector.<Bitmap> = new Vector.<Bitmap>(GameMain.PANEL_LEN);//これの中身を差し替えることでアニメーションさせる

    //アニメーション用タイマー
    public var m_AnimTimer:Number = 0.0;

    //アニメーション用画像リスト
    public var m_BitmapDataList:Array = new Array(GRAPHIC_NUM);

    //接地フラグ
    public var m_GroundFlag:Boolean = false;

    //死亡フラグ
    public var m_IsDead:Boolean = false;


    //==Function==

    //Init
    public function Player(){
        //Input
        {
/*
            addEventListener(
                Event.ADDED_TO_STAGE,//ステージに追加されたら
                function(e:Event):void{
                    //キー入力を見る
                    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
                    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
                }
            );
/*/
            //キー入力を見る
            GameMain.Instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
            GameMain.Instance.stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
//*/
        }

        //プレイヤーグラフィックの仮画像
        {
            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            g.lineStyle(0,0,0);
            g.beginFill(0x000088, 1.0);
            g.drawCircle(GameMain.PANEL_LEN/2, GameMain.PANEL_LEN/2, GameMain.PANEL_LEN/4);
            g.endFill();

            for(var i:int = 0; i < GRAPHIC_NUM; i++){
                m_BitmapDataList[i] = new BitmapData(24, GameMain.PANEL_LEN, true, 0x00000000);
                m_BitmapDataList[i].draw(shape);
            }
        }

        //各面の処理
        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            //m_BaseMtx
            {
                m_BaseMtx[p] = new Matrix();
            }

            //m_Image
            {
                //生成
                {
                    m_Image[p] = new Sprite();
                }

                //登録
                {
                    GameMain.Instance.m_Layer_Plane[p].addChild(m_Image[p]);
                }
            }

            //m_Bitmap
            {
                //生成
                {
                    m_Bitmap[p] = new Bitmap();
                }

                //表示画像の登録
                {
                    m_Bitmap[p].x = -24/2;
                    m_Bitmap[p].y = -GameMain.PANEL_LEN/2;
                    m_Image[p].addChild(m_Bitmap[p]);
                }
            }
        }
    }

    //Init : Pos
    public function SetPos(in_X:int, in_Y:int):void{
/*
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
//*/
/*
        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            if(p == 0){
                m_Image[p].x = in_X;
                m_Image[p].y = in_Y;
            }
        }
//*/
//*
        m_Pos.x = in_X;
        m_Pos.y = in_Y;

        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            if(m_BaseMtx[p] != null){
                m_Image[p].x = m_BaseMtx[p].a * in_X + m_BaseMtx[p].b * in_Y + m_BaseMtx[p].tx;
                m_Image[p].y = m_BaseMtx[p].c * in_X + m_BaseMtx[p].d * in_Y + m_BaseMtx[p].ty;
            }
        }
//*/
    }

    //
    public function SetDir(in_Dir:int):void{
        //2Dアクションなので左右だけ
        var Scl:Number = 1;
        switch(in_Dir){
        case DIR_R: Scl =  1; break;
        case DIR_L: Scl = -1; break;
        }

        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            m_Image[p].scaleX = Scl;
        }
    }

    //Convert
    public function SetPlaneIndex(in_PlaneIndex:int):void{
        var DstPlaneIndex:int = in_PlaneIndex;

        var DstBaseMatrix:Matrix = m_BaseMtx[DstPlaneIndex];

        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            if(p == DstPlaneIndex){
                //移動先の面のパラメータはそのまま使う

                m_BaseMtx[p] = DstBaseMatrix;//cloneの方が良いか？

                //この面の画像は表示する（境界をまたぐ際に事前に表示するため）
                m_Image[p].visible = true;

                //回転量の設定
                m_Image[p].rotation = -Math.atan2(m_BaseMtx[p].b, m_BaseMtx[p].a) * 180/Math.PI;
            }else{
                //移動先の面から、pの面への変換Matrix
                var Mtx:Matrix = GameMain.PLANE_CONVERT_MTX[DstPlaneIndex][p];
                if(Mtx != null){
                    //変換Matrixが存在する＝隣接している

                    //この面用の変換Matrixを用意する
                    //m_BaseMtx[p] = DstBaseMatrix.clone();//移動先の面の基本Matrixに
                    //m_BaseMtx[p].concat(Mtx);//変換Matrixをかける
                    m_BaseMtx[p] = GameMain.MtxConcat(DstBaseMatrix, Mtx);

                    //この面の画像は表示する（境界をまたぐ際に事前に表示するため）
                    m_Image[p].visible = true;

                    //回転量の設定
                    m_Image[p].rotation = -Math.atan2(m_BaseMtx[p].b, m_BaseMtx[p].a) * 180/Math.PI;
                }else{
                    //変換Matrixが存在しない＝隣接していない

                    //とりあえずnullにしておく
                    m_BaseMtx[p] = null;

                    //この面の画像は表示しない
                    m_Image[p].visible = false;
                }
            }
        }

        //Srcを使う必要がある場合に備え、メンバの更新は最後にする
        m_PlaneIndex = in_PlaneIndex;
    }

    //Update : Input
    private function OnKeyDown(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = true;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = true;}
        if(event.keyCode == Keyboard.UP){    m_InputU = true;}
    }
    private function OnKeyUp(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = false;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = false;}
        if(event.keyCode == Keyboard.UP){    m_InputU = false;}
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        //死亡・ゴール時は何もしない
        if(GameMain.Instance.IsEnd()){
            return;
        }

        //移動
        Update_Move(in_DeltaTime);

        //アニメーション
        Update_Anim(in_DeltaTime);

        //死亡チェック
        Check_Dead()
    }

    //Update : Anim
    public function Update_Anim(in_DeltaTime:Number):void{
        //m_AnimTimer
        {
            m_AnimTimer += in_DeltaTime;
            if(m_AnimTimer > ANIM_CYCLE){m_AnimTimer -= ANIM_CYCLE;}
        }

        //m_AnimTimer => iter
        var iter:int;
        {
            iter = ANIM_ITER[int(ANIM_NUM * m_AnimTimer/ANIM_CYCLE)];
        }

        for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
            m_Bitmap[p].bitmapData = m_BitmapDataList[iter];
        }
    }

    //Check : Dead
    public function Check_Dead():void{
        //Check
        {
            if(m_IsDead){
                return;
            }
        }

/*
        //マップより下に行っていたら落下死する
        if(this.y > GameMain.MAP_H+GameMain.PANEL_LEN){
            //ゲームオーバー処理
            {
                GameMain.Instance.OnDead_Fall();
            }

            //フラグ
            {
                m_IsDead = true;
            }
        }
/*/
        //ひとまず大きく範囲外に出たら落下死としてみる
        if(m_Image[m_PlaneIndex].x < -GameMain.PANEL_LEN){m_IsDead = true;}
        if(m_Image[m_PlaneIndex].x > (GameMain.MAP[m_PlaneIndex][0].length+1) * GameMain.PANEL_LEN){m_IsDead = true;}
        if(m_Image[m_PlaneIndex].y < -GameMain.PANEL_LEN){m_IsDead = true;}
        if(m_Image[m_PlaneIndex].y > (GameMain.MAP[m_PlaneIndex].length+1) * GameMain.PANEL_LEN){m_IsDead = true;}

        if(m_IsDead){
            //ゲームオーバー処理
            GameMain.Instance.OnDead_Fall();
        }
//*/
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        //入力
        {
            //X
            {
                var TrgVX:Number = 0.0;
                if(m_InputR){TrgVX =  VEL_X; SetDir(DIR_R);}
                if(m_InputL){TrgVX = -VEL_X; SetDir(DIR_L);}

                var ratio:Number = 1.0;
                m_Vel.x = Lerp(m_Vel.x, TrgVX, ratio);
            }

            //Jump
            {
                if(m_InputU && m_GroundFlag){
                    m_Vel.y = -JUMP_VEL;
                }
            }
        }

        //重力
        {
            m_Vel.y += GRAVITY * in_DeltaTime;

            //速度制限
            if(m_Vel.y > FALL_VEL_MIN){
                m_Vel.y = FALL_VEL_MIN;
            }
        }

        //目標位置
        var DstX:Number;
        var DstY:Number;
        {
            DstX = (m_Pos.x) + (m_Vel.x * in_DeltaTime);
            DstY = (m_Pos.y) + (m_Vel.y * in_DeltaTime);
        }

        //移動を試みる
        //・端数制御のためにちょっと特殊なことをしているが、基本的にはただ単にX移動→Y移動してるだけ
        //・壁判定まわりはかなりムダが多い（高速化の余地が多い）が、ひとまずこれで

        //Planeをまたぐ移動でのひっかかりを誤魔化すため、１ドットだけ上に移動してから移動する
        {
            if(! IsWall(m_Pos.x, m_Pos.y-1)){
                m_Pos.y -= 1;
            }
        }

        //X移動
        {
            var TryX:int = m_Pos.x;
            if(TryX != int(DstX)){
                for(;;){
                    //++
                    if(TryX < DstX){
                        TryX++;
                    }else{
                        TryX--;
                    }

                    //壁があるならその手前で中断
                    if(IsWall(TryX, m_Pos.y)){
                        DstX = m_Pos.x;//壁の手前になるように位置補正（＝端数切捨て）
                        m_Vel.x = 0;
                        break;
                    }

                    //移動できたようなので更新（主に上の位置補正のための記憶用）
                    m_Pos.x = TryX;

                    //移動するたびに参照すべき面を確認する
                    CheckPlane();

                    //Dstまで辿りついたら終了
                    if(TryX == int(DstX)){
                        break;
                    }
                }
            }
            m_Pos.x = DstX;
        }

        //Y移動
        {
            m_GroundFlag = false;//更新のためリセット

            var TryY:int = m_Pos.y;
            if(TryY != int(DstY)){
                for(;;){
                    //++
                    if(TryY < DstY){
                        TryY++;
                    }else{
                        TryY--;
                    }

                    //壁があるならその手前で中断
                    if(IsWall(m_Pos.x, TryY)){
                        if(DstY > m_Pos.y){m_GroundFlag = true;}
                        DstY = m_Pos.y;//壁の手前になるように位置補正（＝端数切捨て）
                        m_Vel.y = 0;
                        break;
                    }

                    //移動できたようなので更新（主に上の位置補正のための記憶用）
                    m_Pos.y = TryY;

                    //移動するたびに参照すべき面を確認する
                    CheckPlane();

                    //Dstまで辿りついたら終了
                    if(TryY == int(DstY)){
                        break;
                    }
                }
            }
            m_Pos.y = DstY;
        }

        //反映
        {
/*
            this.x = m_Pos.x;
            this.y = m_Pos.y;
/*/
            SetPos(m_Pos.x, m_Pos.y);
//*/
        }
    }

    //壁があるかどうか
    public function IsWall(in_X:int, in_Y:int):Boolean{
/*
        //プレイヤーを中心とする四角形の四隅が壁にめり込まないようにする
        //・移動方向によって判定を省略して高速化できるはずだが、対応は保留
        //・同じく、Indexが変わらなければ判定をスキップできるはずだが、こちらも保留

        //四角形用のオフセット
        const OffsetX:int = (GameMain.PANEL_LEN-2)/2;
        const OffsetY:int = (GameMain.PANEL_LEN-2)/2;

        for(var i:int = 0; i < 4; i++){
            var PosX:int = in_X + (((i&1)==0)? OffsetX: -OffsetX);
            var PosY:int = in_Y + (((i&2)==0)? OffsetY: -OffsetY);

            var IndexX:int = PosX / GameMain.PANEL_LEN;
            var IndexY:int = PosY / GameMain.PANEL_LEN;

            //範囲チェック
            {
                //画面外は空白とみなす
                if(IndexX < 0){continue;}
                if(IndexX >= GameMain.MAP_NUM_X){continue;}
                if(IndexY < 0){continue;}
                if(IndexY >= GameMain.MAP_NUM_Y){continue;}
            }

            //該当箇所が壁ならtrueを返して終了
            var p:int = 0;
            switch(GameMain.MAP[p][IndexY][IndexX]){
            case GameMain.W:
                return true;
            }
        }

        //四隅に壁が見つからなかったら壁はないと判断
        return false;
/*/
        //プレイヤーを中心とする四角形の四隅が壁にめり込まないようにする
        //・移動方向によって判定を省略して高速化できるはずだが、対応は保留
        //・同じく、Indexが変わらなければ判定をスキップできるはずだが、こちらも保留

        //四角形用のオフセット
        const OffsetX:int = (24-2)/2;
        const OffsetY:int = (GameMain.PANEL_LEN-4)/2;

        for(var i:int = 0; i < 4; i++){
            var PosX:int = in_X + (((i&1)==0)? OffsetX: -OffsetX);
            var PosY:int = in_Y + (((i&2)==0)? OffsetY: -OffsetY);

            for(var p:int = 0; p < GameMain.PLANE_NUM; p++){
                //グラフィックがオフになっている面は考慮しない
                {
                    if(! m_Image[p].visible){continue;}
                }

                var AbsX:Number = m_BaseMtx[p].a * PosX + m_BaseMtx[p].b * PosY + m_BaseMtx[p].tx;
                var AbsY:Number = m_BaseMtx[p].c * PosX + m_BaseMtx[p].d * PosY + m_BaseMtx[p].ty;

                var IndexX:int = Math.floor(AbsX / GameMain.PANEL_LEN);
                var IndexY:int = Math.floor(AbsY / GameMain.PANEL_LEN);

                //範囲チェック
                {
                    //画面外は空白とみなす
                    if(IndexX < 0){continue;}
                    if(IndexX >= GameMain.MAP[p][0].length){continue;}
                    if(IndexY < 0){continue;}
                    if(IndexY >= GameMain.MAP[p].length){continue;}
                }

                //該当箇所が壁ならtrueを返して終了
                switch(GameMain.MAP[p][IndexY][IndexX]){
                case GameMain.W:
                    return true;
                }
            }
        }

        //四隅に壁が見つからなかったら壁はないと判断
        return false;
//*/
    }

    //
    public function CheckPlane():void{
        //参照すべき面を求める
        var PlaneIndex:int = m_PlaneIndex;
        {
            //レンジ外にあれば、そちらの接続先を探しているだけ
            for(var c:int = 0; c < 10; c++){//念のため回数制限を設ける
                var PlaneW:int = GameMain.PANEL_LEN * GameMain.MAP[PlaneIndex][0].length;
                var PlaneH:int = GameMain.PANEL_LEN * GameMain.MAP[PlaneIndex].length;

                var Cand:int = -1;
                {
                    if(m_Image[PlaneIndex].x < 0){
                        Cand = GameMain.PLANE_CONNECT[PlaneIndex][GameMain.EDGE_L];
                    }
                    if(m_Image[PlaneIndex].x >= PlaneW){
                        Cand = GameMain.PLANE_CONNECT[PlaneIndex][GameMain.EDGE_R];
                    }
                    if(m_Image[PlaneIndex].y < 0){
                        Cand = GameMain.PLANE_CONNECT[PlaneIndex][GameMain.EDGE_U];
                    }
                    if(m_Image[PlaneIndex].y >= PlaneH){
                        Cand = GameMain.PLANE_CONNECT[PlaneIndex][GameMain.EDGE_D];
                    }
                }

                if(Cand >= 0){
                    PlaneIndex = Cand;
                    SetPlaneIndex(PlaneIndex);
                    continue;
                }

                break;
            }
        }

        //参照すべき面が異なれば、参照先を変更する
        {
            if(PlaneIndex != m_PlaneIndex){
                SetPlaneIndex(PlaneIndex);
            }
        }
    }

    //Utility
    public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
        return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
    }
}


//#Goal
class Goal extends Sprite
{
    //==Constt==

    static public const GOAL_RANGE:int = 8;


    //==Var==

    public var m_PlaneIndex:int = 0;


    //==Function==

    //Init
    public function Goal():void{
        //Graphic
        {
            addChild(ImageManager.CreateGoalGraphic());
        }
    }

    //SetPos
    public function SetPos(in_X:int, in_Y:int):void{
        this.x = in_X;
        this.y = in_Y;
    }

    public function SetPlaneIndex(in_PlaneIndex:int):void{
        //画像位置の変更

        //解除
        {
            if(this.parent){
                this.parent.removeChild(this);
            }
        }

        //登録
        {
            GameMain.Instance.m_Layer_Obj[in_PlaneIndex].addChild(this);
        }

        //記憶
        {
            m_PlaneIndex = in_PlaneIndex;
        }
    }

    //Update
    public function Update():void{
        //プレイヤーが一定範囲に来たらゴールとする

        //そもそもすでにゴールしてたら何も処理しない
        {
            if(GameMain.Instance.IsEnd()){
                return;
            }
        }

        //プレイヤーとの距離が一定以上離れていたら何も処理しない
        {
            var GapX:Number = GameMain.Instance.m_Player.m_Image[m_PlaneIndex].x - this.x;
            var GapY:Number = GameMain.Instance.m_Player.m_Image[m_PlaneIndex].y - this.y;

            var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            if(Distance > GOAL_RANGE){
                return;
            }
        }

        //上のチェックに全てクリアしたらゴールしたものとして処理する
        {
            GameMain.Instance.OnGoal();
        }
    }
}


//#ImageManager
class ImageManager
{
    //==Const==

    //#Graphic
    static public var m_GraphicIndexIter:int = 0;

    static public const GRAPHIC_INDEX_BG:int            = m_GraphicIndexIter++;

    static public const GRAPHIC_INDEX_WALL:int            = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_WALL_X:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_WALL_Y:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_WALL_XorY:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_WALL_XandY:int    = m_GraphicIndexIter++;

    static public const GRAPHIC_INDEX_NEEDLE:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_NEEDLE_X:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_NEEDLE_Y:int        = m_GraphicIndexIter++;
    static public const GRAPHIC_INDEX_NEEDLE_XY:int        = m_GraphicIndexIter++;

    static public const GRAPHIC_INDEX_NUM:int            = m_GraphicIndexIter;


    //#enum:Quater
    static public const LU:int = 0;
    static public const RU:int = 1;
    static public const LD:int = 2;
    static public const RD:int = 3;

    //#enum:Pos
    static public const POS_X:int = 0;
    static public const POS_Y:int = 1;


    //#Graphic
    static public var m_BitmapData_View:BitmapData;

    //#Mapping
    static public var GRAPHIC_INDEX_TO_POS:Array;


    //#Palette
    static public var m_Palette_ForView:Array;


    //#Utility
    static public const POS_ZERO:Point = new Point(0,0);


    //==Function==

    //#Init
    static public function Init(in_Graphic:DisplayObject):void{
        var x:int, y:int, i:int;

        //m_BitmapData_View
        {
            m_BitmapData_View = new BitmapData(256, 256, false, 0x000000);
            m_BitmapData_View.draw(in_Graphic);
        }

        //GRAPHIC_INDEX_TO_POS
        {//GRAPHIC_INDEX_～から画像の位置へのマッピング（さらにどの隅での処理かも含む）（そして左から何マス目、上から何マス目、という指定）
            GRAPHIC_INDEX_TO_POS = new Array(GRAPHIC_INDEX_NUM);

            //[LU][RU][LD][RD]

            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_BG]            = [[3,2], [3,2], [3,2], [3,2]];

            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_WALL]        = [[1,1], [1,1], [1,1], [1,1]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_WALL_X]        = [[0,1], [2,1], [0,1], [2,1]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_WALL_Y]        = [[1,0], [1,0], [1,2], [1,2]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_WALL_XorY]    = [[0,0], [2,0], [0,2], [2,2]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_WALL_XandY]    = [[3,0], [4,0], [3,1], [4,1]];

            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_NEEDLE]        = [[3,3], [4,3], [3,4], [4,4]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_NEEDLE_X]    = [[0,4], [2,4], [0,4], [2,4]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_NEEDLE_Y]    = [[1,3], [1,3], [1,5], [1,5]];
            GRAPHIC_INDEX_TO_POS[GRAPHIC_INDEX_NEEDLE_XY]    = [[0,3], [2,3], [0,5], [2,5]];
        }

        //m_Palette_ForView
        {
            m_Palette_ForView = new Array(256);

            var index_graphic:int = GRAPHIC_INDEX_BG;
            for(i = 0; i < 256; i++){
                //区切りごとにindexを変更。次の区切りまではその値をセット
                switch(i){
                case 0:
                case 6:
                case 18:
                case 24:
                    index_graphic = GRAPHIC_INDEX_BG; break;
                case 3:
                case 21:
                    index_graphic = GRAPHIC_INDEX_NEEDLE_Y; break;
                case 9:
                case 15:
                    index_graphic = GRAPHIC_INDEX_NEEDLE_X; break;
                case 12:
                    index_graphic = GRAPHIC_INDEX_NEEDLE_XY; break;
                case 27:
                    index_graphic = GRAPHIC_INDEX_NEEDLE; break;
                case 54:
                case 63:
                    index_graphic = GRAPHIC_INDEX_WALL_XorY; break;
                case 60:
                case 69:
                    index_graphic = GRAPHIC_INDEX_WALL_X; break;
                case 72:
                    index_graphic = GRAPHIC_INDEX_WALL_Y; break;
                case 78:
                    index_graphic = GRAPHIC_INDEX_WALL_XandY; break;
                case 80:
                    index_graphic = GRAPHIC_INDEX_WALL; break;
                }

                m_Palette_ForView[i] = index_graphic;
            }
        }
    }

    //#Draw : BG
    static public function DrawBG(in_NumX:int, in_NumY:int, out_BitmapData_View:BitmapData):void
    {
        var x:int, y:int, i:int;
        var mtx:Matrix = new Matrix();
        var rect:Rectangle = new Rectangle(0,0, 16,16);
        var NumX:int = in_NumX;
        var NumY:int = in_NumY;

        for(y = 0; y < NumY; y++){
            for(x = 0; x < NumX; x++){
                for(i = 0; i < 4; i++){
                    rect.x = x * 32 + 16 * ((i&1)>>0);
                    rect.y = y * 32 + 16 * ((i&2)>>1);

                    var index:int = GRAPHIC_INDEX_BG;

                    //#view
                    mtx.tx = rect.x - 16 * GRAPHIC_INDEX_TO_POS[index][i][POS_X];
                    mtx.ty = rect.y - 16 * GRAPHIC_INDEX_TO_POS[index][i][POS_Y];
                    out_BitmapData_View.draw(m_BitmapData_View, mtx, null, null, rect);
                }
            }
        }
    }

    //#Draw : Blocks
    static public function DrawBlocks(in_Map:Array, out_BitmapData_View:BitmapData):void
    {
        var x:int, y:int, i:int;
        var mtx:Matrix = new Matrix();

        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //Map => Bitmap_Base
        //Mapの要素を元に、「０：空白」「１：トゲ」「２：壁」というBitmapを生成
        var BitmapData_Base:BitmapData;
        {
            BitmapData_Base = new BitmapData(NumX, NumY, false, 0x000000);
            for(y = 0; y < NumY; y++){
                for(x = 0; x < NumX; x++){
                    var index:int = 0;//default(O, P, G)
                    {
                        switch(in_Map[y][x]){
                        case GameMain.W:
                            index = 2;
                            break;
                        case GameMain.X:
                            index = 1;
                            break;
                        }
                    }

                    BitmapData_Base.setPixel(x, y, index);
                }
            }
        }

        //Bitmap_Base => Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD
        //Bitmap_Baseを元に、四隅の隣接状況をそれぞれ求める(Uniqueな値になるようにする)
        var BitmapData_Quater:Array = new Array(4);
        {
            //Create Filter
            const filter:Array = [
                new ConvolutionFilter(3,3,
                    [//LU
                        1,  3,  0,
                        9, 27,  0,
                        0,  0,  0,
                    ]
                    ,1,0,true,false//画面外を空白扱いするならコメントイン。clampの有無で実現
                ),
                new ConvolutionFilter(3,3,
                    [//RU
                        0,  3,  1,
                        0, 27,  9,
                        0,  0,  0,
                    ]
                    ,1,0,true,false
                ),
                new ConvolutionFilter(3,3,
                    [//LD
                        0,  0,  0,
                        9, 27,  0,
                        1,  3,  0,
                    ]
                    ,1,0,true,false
                ),
                new ConvolutionFilter(3,3,
                    [//RD
                        0,  0,  0,
                        0, 27,  9,
                        0,  3,  1,
                    ]
                    ,1,0,true,false
                ),
            ];

            for(i = 0; i < 4; i++){
                //Init
                BitmapData_Quater[i] = new BitmapData(NumX, NumY, false, 0x000000);

                //Apply Filter
                BitmapData_Quater[i].applyFilter(BitmapData_Base, BitmapData_Base.rect, POS_ZERO, filter[i]);
            }
        }

        //Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD => ForView
        //Uniqueな値から、対応するIndexへと変換する
        var BitmapData_ForView:Array = new Array(4);
        {
            for(i = 0; i < 4; i++){
                //Init
                BitmapData_ForView[i] = new BitmapData(NumX, NumY, false, 0x000000);

                //Apply Palette
                BitmapData_ForView[i].paletteMap(BitmapData_Quater[i], BitmapData_Quater[i].rect, POS_ZERO, null, null, m_Palette_ForView);
            }
        }


        //Draw
        //上で求めたIndexに基づき描画
        {
            var rect:Rectangle = new Rectangle(0,0, 16,16);

            for(y = 0; y < NumY; y++){
                for(x = 0; x < NumX; x++){
                    for(i = 0; i < 4; i++){
                        rect.x = x * 32 + 16 * ((i&1)>>0);
                        rect.y = y * 32 + 16 * ((i&2)>>1);

                        index = BitmapData_ForView[i].getPixel(x, y);

                        //#view
                        mtx.tx = rect.x - 16 * GRAPHIC_INDEX_TO_POS[index][i][POS_X];
                        mtx.ty = rect.y - 16 * GRAPHIC_INDEX_TO_POS[index][i][POS_Y];
                        out_BitmapData_View.draw(m_BitmapData_View, mtx, null, null, rect);
                    }
                }
            }
        }
    }

    //Image : Goal
    static public function CreateGoalGraphic():Sprite{
        //
        const W:int = 48;
        const H:int = 64;
        const BLUR_VAL:int = 20;

        //
        var result:Sprite = new Sprite();

        //基本画像
        var bmd:BitmapData = new BitmapData(W, H, true, 0x00000000);
        var bmp:Bitmap = new Bitmap(bmd);
        {
            //白い楕円の上半分を描画
            const RAD_W:int = 12;//W/2-BLUR_VAL;
            const RAD_H:int = 32;//H-BLUR_VAL;

            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            g.lineStyle(0, 0x000000, 0.0);
            g.beginFill(0xFFFFFF, 1.0);
            g.drawEllipse(W/2-RAD_W, H-RAD_H, RAD_W*2, RAD_H*2);
            g.endFill();

//            shape.filters = [new GlowFilter(0xFFFFFF,1.0, 2*BLUR_VAL,2*BLUR_VAL)];
//            shape.filters = [new GlowFilter(0xFFFFFF,1.0, 1,2*BLUR_VAL,255), new GlowFilter(0xFFFFFF,1.0, 2*BLUR_VAL,1,255)];

            bmd.draw(shape);

            shape.filters = [new BlurFilter(BLUR_VAL, BLUR_VAL)];
            bmd.draw(shape);
            bmd.draw(shape);

            result.addChild(bmp);
        }

        //発光っぽくする
        {
            //フィルターを追加
//            bmp.filters = [new GlowFilter(0xFFFFFF, 1.0, 2*BLUR_VAL,2*BLUR_VAL)];

            //フィルターで下に広がるのを防止するためのマスク
            var msk:Bitmap = new Bitmap(new BitmapData(W, H, false, 0xFFFFFF));
            result.mask = msk;
            result.addChild(msk);

            //加算化
            bmp.blendMode = BlendMode.ADD;
        }

        //位置調整
        {
            result.x = -W/2;
            result.y = -H+16;
        }

        return result;
    }
}


