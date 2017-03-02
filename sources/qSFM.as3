/*
　ActLaser
　・レーザーとなってゴールを目指す2Dアクション

　操作方法
　・十字キー
　　・移動＆ジャンプ
　・Sキー or SPACE （押しっぱなし）
　　・レーザー化
　　　・十字キーを押しながらSPACEで、レーザーになってそちらに移動
　　　・十字キーを押さなければ停滞モードになる
　　　　・そこから十字キーを入れれば移動


　できれば作りたかったもの
　○斜めの壁（三角壁）
　　・レーザーの反射パターンを増やせる
　　　→意外と対応コストが高かったので断念
　○ミラー＆スイッチ
　　・スイッチにぶつかるとミラーの角度が変わる＝進路が変わる
　　　→斜めの処理などとも絡んでコストがやや高い
　○ガラスブロック
　　・「光なんだからガラスは壊さずに通過できるよね」ということで、レーザー化してる時のみ通過できるブロック
　　・「斜めから衝突したら全反射するよね」ということで、垂直にしか進入できないとか
　　　→「透明なブロック」なんて自分には描けない
　○スーパースローモード
　　・「光速で移動してるんだから、まわりは止まって見えるよね」ということで、レーザー化してる時はまわりのギミックを停止
　　　→そもそも動くギミックを作ってない

　その他
　・アクトレイザー(ActRaiser)とは関係ありません
　　・http://ja.wikipedia.org/wiki/%E3%82%A2%E3%82%AF%E3%83%88%E3%83%AC%E3%82%A4%E3%82%B6%E3%83%BC
　・むしろSonic Colorsのシアン・レーザーが近いです
　　・http://sonic.sega.jp/SonicColors/#/action/wii_cyan
　・空中で方向指定せずにSPACEを連打すると、少しずつ落下できるので位置調整ができます
　・いつものように、ForkしてMAPをいじればステージが作れます。
*/



package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
 
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class GameMain extends Sprite {

        //==Const==

        //画面の大きさ
        static public const VIEW_W:int = 465;
        static public const VIEW_H:int = 465;

        //マップ
        static public var m_MapIter:int = 0;
        static public const O:int = m_MapIter++;//空白
        static public const W:int = m_MapIter++;//壁
        static public const Y:int = m_MapIter++;//三角壁：左上（キーボードの配置で見立て）
        static public const U:int = m_MapIter++;//三角壁：右上（しかし未実装なのであった）
        static public const H:int = m_MapIter++;//三角壁：左下
        static public const J:int = m_MapIter++;//三角壁：右下
        static public const P:int = m_MapIter++;//プレイヤー
        static public const G:int = m_MapIter++;//ゴール

        static public const MAP:Array = [
[W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,O,W,O,W,O,W,O,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,O,O,W,O,W,W,W,W,W,W,W,O,W,O,W,O,O,O,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,W,W,W,W,W,W,W,O,W,O,W,O,W,O,W,W,W,W,W,W,W,W,O,W,W,W,W,W,W,W,W,W,W,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,W,W,W,O,W,W,W,W,W,W,W,O,O,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,W,W,W,W,W,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,W,W,W,W,O,W,W,W,W,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,W,W,W,W,W,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,W,W,W,W,W,O,W,W,W,W,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,W,O,O,O,W,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,G,O,W,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,O,O,O,O,O,W,O,O,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,W,W,W,W,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,O,O,O,O,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,W,W,W,W,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,O,O,O,O,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,W],
[W,O,O,P,O,O,W,W,W,W,W,W,W,W,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,O,O,O,O,O,W,O,W,O,W,O,O,O,O,O,O,O,O,W,O,O,W,O,O,O,O,O,O,O,O,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,O,W,W,W,O,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,W,W,W,W,W,W,O,W,O,W,O,W,O,O,O,O,O,O,W,O,O,W,O,O,O,O,O,O,O,O,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,O,O,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,W,W,O,O,O,O,W,W,W,W,W,W,O,W,O,W,O,W,O,O,O,O,W,W,W,O,O,W,O,O,O,O,O,O,O,O,O,W],
[W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,W,W,W,W,W,W,O,W,O,W,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,W],
        ];

        //１マスの大きさ
        static public const PANEL_LEN:int = 32;

        //マップのサイズ
        static public const MAP_NUM_X:int = MAP[0].length;
        static public const MAP_NUM_Y:int = MAP.length;

        //マップの大きさ
        static public const MAP_W:int = PANEL_LEN * MAP_NUM_X;
        static public const MAP_H:int = PANEL_LEN * MAP_NUM_Y;

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
        public var  m_Layer_BG:Sprite = new Sprite();
        public var  m_Layer_Player:Sprite = new Sprite();
        public var  m_Layer_Wall:Sprite = new Sprite();

        //画像
        public var m_BitmapData_BG:BitmapData   = new BitmapData(MAP_W, MAP_H, false, 0x000000);
        public var m_BitmapData_Wall:BitmapData = new BitmapData(MAP_W, MAP_H, true,  0x00000000);

        //プレイヤー
        public var m_Player:Player = new Player();

        //ゴール
        public var m_Goal:Goal;

        //テキスト
        public var m_Text:TextField = new TextField();

        //モード
        public var m_Mode:int = MODE_MAIN;

        //==Function==

        //Init
        public function GameMain():void {
            //Pseudo Singleton
            {
                Instance = this;
            }

            //Layer
            {
                //Root
                addChild(m_Layer_Root);

                {
                    //背景
                    m_Layer_Root.addChild(m_Layer_BG);

                    //プレイヤー
                    m_Layer_Root.addChild(m_Layer_Player);

                    //壁（レーザーを隠すため、プレイヤーより手前にする）
                    m_Layer_Root.addChild(m_Layer_Wall);
                }
            }

            //背景
            {
                m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG));
            }

            //壁
            {
                m_Layer_Wall.addChild(new Bitmap(m_BitmapData_Wall));
            }

            //プレイヤー
            {
                m_Layer_Player.addChild(m_Player);
            }

            //Goal
            {
                m_Goal = new Goal();
                m_Layer_BG.addChild(m_Goal);
            }

            //MAPに応じた処理
            {
                var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);
                for(var y:int = 0; y < MAP_NUM_Y; y++){
                    rect.y = y * PANEL_LEN;
                    for(var x:int = 0; x < MAP_NUM_X; x++){
                        rect.x = x * PANEL_LEN;

                        switch(MAP[y][x]){
                        case W:
                            //壁の基本描画
                            m_BitmapData_Wall.fillRect(rect, 0xFF444444);
                            break;
                        case P:
                            //プレイヤーの位置指定
                            m_Player.SetPos(
                                (x+0.5) * PANEL_LEN,
                                (y+0.5) * PANEL_LEN
                            );
                            break;
                        case G:
                            //ゴールの位置指定
                            m_Goal.SetPos(
                                (x+0.5) * PANEL_LEN,
                                (y+0.5) * PANEL_LEN
                            );
                            break;
                        }
                    }
                }
            }

            //壁の見た目を調整
            {
                //BMDの一時コピーを生成することになるが気にしない
                m_BitmapData_Wall.applyFilter(
                    m_BitmapData_Wall, m_BitmapData_Wall.rect, new Point(0,0),
                    new GlowFilter(0x383838, 1.0, PANEL_LEN,PANEL_LEN, 2,1, true)
                );
            }

            //Text
            {
                m_Text.selectable = false;
                m_Text.autoSize = TextFieldAutoSize.LEFT;
                m_Text.defaultTextFormat = new TextFormat('Verdana', 60, 0xFFFFFF, true);
                m_Text.text = '';
                m_Text.filters = [new GlowFilter(0x00FFFF,1.0, 8,8)];

                addChild(m_Text);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }
        }

        //Update
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
        }

        //Update : Camera
        public function Update_Camera():void{
            var IsLaserMode:Boolean = m_Player.IsLaserMode();

            var PlayerX:int = m_Player.x;
            var PlayerY:int = m_Player.y;



            //移動量
            var CameraMoveX:int = 0;
            var CameraMoveY:int = 0;
            {
                //現在のカメラでのプレイヤー相対位置
                var RelPlayerX:Number = PlayerX + m_Layer_Root.x;
                var RelPlayerY:Number = PlayerY + m_Layer_Root.y;

                if(IsLaserMode){
                    //レーザー移動時
                    //→プレイヤーが画面外に移動するような状況に限りカメラを移動させる

                    //
                    var UnSafeRatio:Number = 0.2;
                    if(RelPlayerX < VIEW_W*UnSafeRatio){CameraMoveX = VIEW_W*UnSafeRatio - RelPlayerX;}
                    if(VIEW_W - VIEW_W*UnSafeRatio < RelPlayerX){CameraMoveX = (VIEW_W - VIEW_W*UnSafeRatio) - RelPlayerX;}
                    if(RelPlayerY < VIEW_H*UnSafeRatio){CameraMoveY = VIEW_H*UnSafeRatio - RelPlayerY;}
                    if(VIEW_H - VIEW_H*UnSafeRatio < RelPlayerY){CameraMoveY = (VIEW_H - VIEW_H*UnSafeRatio) - RelPlayerY;}
                }else{
                    //通常時
                    //→プレイヤーが中央に来るようにする

                    //中央からの差がそのまま移動量
                    CameraMoveX = VIEW_W/2 - RelPlayerX;
                    CameraMoveY = VIEW_H/2 - RelPlayerY;
                }
            }

            //目標値
            var RootX:int = m_Layer_Root.x + CameraMoveX;
            var RootY:int = m_Layer_Root.y + CameraMoveY;
            {
                //端制限
                if(RootX < -MAP_W + VIEW_W){
                    RootX = -MAP_W + VIEW_W;
                }
                if(RootX > 0){
                    RootX = 0;
                }
                if(RootY < -MAP_H + VIEW_H){
                    RootY = -MAP_H + VIEW_H;
                }
                if(RootY > 0){
                    RootY = 0;
                }
            }

/*
            m_Layer_Root.x = RootX;
            m_Layer_Root.y = RootY;
/*/
            var ratio:Number = 0.2;//レーザーモード解除時にすぐに移動するとわかりにくいので、補間してみる
            m_Layer_Root.x = Lerp(m_Layer_Root.x, RootX, ratio);
            m_Layer_Root.y = Lerp(m_Layer_Root.y, RootY, ratio);
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

        //#IsGameOver
        public function IsEnd():Boolean{
            return (m_Mode != MODE_MAIN);
        }

        //Wall
        public function GetWallVal(in_X:int, in_Y:int):int{
            var IndexX:int = in_X / PANEL_LEN;
            var IndexY:int = in_Y / PANEL_LEN;

            //範囲外は空白とみなす
            {
                if(IndexX < 0){return O;}
                if(MAP_NUM_X <= IndexX){return O;}
                if(IndexY < 0){return O;}
                if(MAP_NUM_Y <= IndexY){return O;}
            }

            //あとはMAPに従う
            var WallVal:int = O;
            {
                switch(MAP[IndexY][IndexX]){
                case W:
//                case Z:
//                case S:
//                case X:
                    //プレイヤー位置とかは空白とみなす
                    WallVal = MAP[IndexY][IndexX];
                    break;
                }
            }

            return WallVal;
        }

        //Utility
        public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
            return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
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
    static public const JUMP_VEL:Number = 290.0;

    //重力
    static public const GRAVITY:Number = 500.0;

    //最高下降速度（ロックによって無限落下が可能なので、速度制限してみる）
    static public const FALL_VEL_MIN:Number = 1000.0;

    //レーザー移動速度
    static public const LASER_VEL:Number = 500;

    //入力方向
    static public var DirIter:int = 0;
    static public const DIR_NONE:int = -1;
    static public const DIR_DR:int = DirIter++;
    static public const DIR_D :int = DirIter++;
    static public const DIR_DL:int = DirIter++;
    static public const DIR_L :int = DirIter++;
    static public const DIR_UL:int = DirIter++;
    static public const DIR_U :int = DirIter++;
    static public const DIR_UR:int = DirIter++;
    static public const DIR_R :int = DirIter++;
    static public const DIR_NUM :int = DirIter;


    //==Var==

    //移動まわりのパラメータ
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);

    //入力
    public var m_InputL:Boolean = false;
    public var m_InputR:Boolean = false;
    public var m_InputU:Boolean = false;
    public var m_InputD:Boolean = false;
    public var m_InputLaser:Boolean = false;

    //プレイヤーのグラフィック
    public var m_Shape:Shape = new Shape();
    public var m_Graphics:Graphics = m_Shape.graphics;

    //方向指定：グラフィック用
    public var m_AnimIndex:int = DIR_NONE;
    public var m_AnimIndex_Next:int = DIR_NONE;

    //レーザー用ポイントリスト
    public var m_PointList:Vector.<Point> = new Vector.<Point>();

    //レーザー移動用
    public var m_RestLen:Number = 1;
    public var m_LaserMoveX:int = 1;
    public var m_LaserMoveY:int = -1;

    //接地フラグ
    public var m_GroundFlag:Boolean = false;

    //死亡フラグ
    public var m_IsDead:Boolean = false;


    //==Function==

    //Init
    public function Player(){
        //Input
        {
            addEventListener(
                Event.ADDED_TO_STAGE,//ステージに追加されたら
                function(e:Event):void{
                    //キー入力を見る
                    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
                    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
                }
            );
        }

        //プレイヤーグラフィック
        {
            var g:Graphics = m_Graphics;
            g.lineStyle(0,0,0);
            g.beginFill(0xEEFFFF, 1.0);
            g.drawCircle(0,0, GameMain.PANEL_LEN/4);
            g.endFill();

            var Blur:Number = GameMain.PANEL_LEN/2;
            m_Shape.filters = [new GlowFilter(0x00FFFF, 1.0, Blur,Blur)];

            addChild(m_Shape);
        }
    }

    //Init : Pos
    public function SetPos(in_X:int, in_Y:int):void{
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
    }

    //Get : LaserMode
    public function IsLaserMode():Boolean{
        return m_PointList.length > 0;
    }

    //Update : Input
    static public const KEY_S:int = 83;
    private function OnKeyDown(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = true;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = true;}
        if(event.keyCode == Keyboard.UP){    m_InputU = true;}
        if(event.keyCode == Keyboard.DOWN){    m_InputD = true;}

        if(!m_InputLaser){
            switch(event.keyCode){
            case KEY_S:
            case Keyboard.SPACE:
                //レーザーモード開始

                //Flag
                m_InputLaser = true;

                //PointList : Init
                m_PointList.push(new Point(this.x, this.y));

                //移動方向リセット
                m_LaserMoveX = 0;
                m_LaserMoveY = 0;
                m_RestLen = 0;
            }
        }

        if(m_LaserMoveX == 0 && m_LaserMoveY == 0){
            //移動方向決定
            if(m_InputL){m_LaserMoveX--;}
            if(m_InputR){m_LaserMoveX++;}
            if(m_InputU){m_LaserMoveY--;}
            if(m_InputD){m_LaserMoveY++;}
        }
    }
    private function OnKeyUp(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = false;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = false;}
        if(event.keyCode == Keyboard.UP){    m_InputU = false;}
        if(event.keyCode == Keyboard.DOWN){    m_InputD = false;}

        if(m_InputLaser){
            switch(event.keyCode){
            case KEY_S:
            case Keyboard.SPACE:
                //レーザーモード解除

                //Flag
                m_InputLaser = false;

                //PointList : Clear
                m_PointList = new Vector.<Point>();
            }
        }
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        //死亡・ゴール時は何もしない
        if(GameMain.Instance.IsEnd()){
            return;
        }

        //移動
        Update_Move(in_DeltaTime);

        //グラフィック
        Update_Graphic(in_DeltaTime);

        //死亡チェック
        Check_Dead();
    }

    //Update : Graphic
    public function Update_Graphic(in_DeltaTime:Number):void{
        if(! IsLaserMode()){
            Update_Graphic_Normal(in_DeltaTime);
        }else{
            Update_Graphic_Laser(in_DeltaTime);
        }
    }
    //Update : Graphic : Normal
    public function Update_Graphic_Normal(in_DeltaTime:Number):void{
        //通常時

        //Check
        {
            //m_AnimIndex_Next
            {
                //LU, U, RU
                //L,  N, R
                //LD, D, RD
                const INPUT_to_ANIM:Array = [
                    DIR_UL,        DIR_U,        DIR_UR,
                    DIR_L,        DIR_NONE,    DIR_R,
                    DIR_DL,        DIR_D,        DIR_DR
                ];

                var input:int = 4;//center
                if(m_InputL){input -= 1;}
                if(m_InputR){input += 1;}
                if(m_InputU){input -= 3;}
                if(m_InputD){input += 3;}

                m_AnimIndex_Next = INPUT_to_ANIM[input];
            }

            if(m_AnimIndex == m_AnimIndex_Next){
                return;//変更がなければ何もしない
            }

            m_AnimIndex = m_AnimIndex_Next;
        }

        //Draw
        {
            var rad:Number = GameMain.PANEL_LEN/4;

            var g:Graphics = m_Graphics;

            //Reset
            {
                g.clear();
                g.lineStyle(0,0,0);
            }

            //Circle
            {
                g.beginFill(0xEEFFFF, 1.0);
                g.drawCircle(0,0, rad);
                g.endFill();
            }

            //Arrow
            {
                if(m_AnimIndex >= 0){
                    var theta:Number = 2*Math.PI * m_AnimIndex/DIR_NUM;

                    var rad2:Number = rad * 2;//Math.sqrt(2);

                    g.beginFill(0xEEFFFF, 1.0);
                    g.moveTo(rad*Math.cos(theta), rad*Math.sin(theta));
                    g.lineTo(rad2*Math.cos(theta+Math.PI/4), rad2*Math.sin(theta+Math.PI/4));
                    g.lineTo(rad*Math.cos(theta+Math.PI/2), rad*Math.sin(theta+Math.PI/2));
                    g.endFill();
                }
            }
        }
    }
    //Update : Graphic : Laser
    public function Update_Graphic_Laser(in_DeltaTime:Number):void{
        //レーザー時

        var g:Graphics = m_Graphics;

        var point_num:int = m_PointList.length;

        //Reset
        {
            g.clear();
            g.lineStyle(GameMain.PANEL_LEN/4, 0xEEFFFF,1.0);
        }

        //Line
        {
            g.moveTo(m_PointList[0].x-this.x, m_PointList[0].y-this.y);
            for(var i:int = 1; i < point_num; i++){
                g.lineTo(m_PointList[i].x-this.x, m_PointList[i].y-this.y);
            }
            g.lineTo(0,0);
        }

        //Circle
        {
            g.lineStyle(0,0,0);
            g.beginFill(0xEEFFFF, 1.0);
            g.drawCircle(0,0, GameMain.PANEL_LEN/4);
            g.endFill();
        }

        m_AnimIndex = -2;//戻った時に強制Draw
    }

    //Check : Dead
    public function Check_Dead():void{
        //Check
        {
            if(m_IsDead){
                return;
            }
        }

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
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        if(! IsLaserMode()){
            Update_Move_Normal(in_DeltaTime);
        }else{
            Update_Move_Laser(in_DeltaTime);
        }
    }
    //Update : Move : Normal
    public function Update_Move_Normal(in_DeltaTime:Number):void{
        //入力
        {
            //X
            {
                var TrgVX:Number = 0.0;
                if(m_InputR){TrgVX =  VEL_X;}
                if(m_InputL){TrgVX = -VEL_X;}

                var ratio:Number = 0.5;
                if(!m_GroundFlag){ratio = 0.2;}//空中では慣性をきかせる
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
            this.x = m_Pos.x;
            this.y = m_Pos.y;
        }
    }
    //Update : Move : Laser
    public function Update_Move_Laser(in_DeltaTime:Number):void{
//*
        //今回の移動量を計算
        m_RestLen += LASER_VEL * in_DeltaTime;

        //１ドットずつ移動
        for(; m_RestLen >= 1; m_RestLen -= 1){
            var NextX:int = m_Pos.x + m_LaserMoveX;
            var NextY:int = m_Pos.y + m_LaserMoveY;

            var WallVal:int = GameMain.Instance.GetWallVal(NextX, NextY);

            //三角壁用
            var DeltaWallCheck:Boolean = false;
            var DeltaWallHit:Boolean = false;
            var RelNextX:int = NextX % GameMain.PANEL_LEN;
            var RelNextY:int = NextY % GameMain.PANEL_LEN;

            switch(WallVal){
                //＝空間＝
            case GameMain.O:
                //そのまま移動
                m_Pos.x = NextX;
                m_Pos.y = NextY;
                break;

                //＝壁＝
            case GameMain.W:
                //上下反転も左右反転も両反転もありうる

                //今の位置を屈折点として登録
                {
                    m_PointList.push(new Point(m_Pos.x, m_Pos.y));
                }

                //周囲（といっても１ドット）のブロックの並びを調べる
                var WallVal_X:int = GameMain.Instance.GetWallVal(m_Pos.x+m_LaserMoveX, m_Pos.y);
                var WallVal_Y:int = GameMain.Instance.GetWallVal(m_Pos.x, m_Pos.y+m_LaserMoveY);

                //並び具合を数値化
                var ReflectVal:int = 0;
                if(WallVal_X == GameMain.W){ReflectVal += 1;}
                if(WallVal_Y == GameMain.W){ReflectVal += 2;}

                //並び具合に応じて反射
                switch(ReflectVal){
                case 0://隅
                case 3://隅
                    //逆移動
                    m_LaserMoveX = -m_LaserMoveX;
                    m_LaserMoveY = -m_LaserMoveY;
                    break;
                case 1://ブロックが横に並んでいるところへの衝突
                    //上下反転
                    m_LaserMoveY = -m_LaserMoveY;
                    //横だけ採用
                    m_Pos.x = NextX;
                    break;
                case 2://ブロックが縦に並んでいるところへの衝突
                    //左右反転
                    m_LaserMoveX = -m_LaserMoveX;
                    //縦だけ採用
                    m_Pos.y = NextY;
                    break;
                }

                //次の始点を再び屈折点として登録
                {
                    m_PointList.push(new Point(m_Pos.x, m_Pos.y));
                }

                break;
/*
                //＝三角壁＝
                //- まずはそれぞれのパターンで壁に接触したかをチェック
            case GameMain.Y:
                if(!DeltaWallCheck){
                    DeltaWallHit = (RelNextX <= (GameMain.PANEL_LEN-1 - RelNextY));
                    DeltaWallCheck = true;
                }
            case GameMain.U:
                if(!DeltaWallCheck){
                    DeltaWallHit = (RelNextY <= RelNextX);
                    DeltaWallCheck = true;
                }
            case GameMain.H:
                if(!DeltaWallCheck){
                    DeltaWallHit = (RelNextY >= RelNextX);
                    DeltaWallCheck = true;
                }
            case GameMain.J:
                if(!DeltaWallCheck){
                    DeltaWallHit = (RelNextX >= (GameMain.PANEL_LEN-1 - RelNextY));
                    DeltaWallCheck = true;
                }
                //共通
                //斜め移動なら両反射、そうでなければ９０度回転
                break;
//*/
            }
        }

        //反映
        {
            this.x = m_Pos.x;
            this.y = m_Pos.y;

            //速度も
            m_Vel.x = LASER_VEL * m_LaserMoveX;
            m_Vel.y = LASER_VEL * m_LaserMoveY;
        }

        //m_LaserMoveXは-1,0,1の値を取ることで横や斜めに１ドットずつ進むもの
//*/
    }

    //壁があるかどうか
    public function IsWall(in_X:int, in_Y:int):Boolean{
        return GameMain.Instance.GetWallVal(in_X, in_Y) == GameMain.W;
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

    static public const GOAL_RANGE:int = 16;


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
            var GapX:Number = GameMain.Instance.m_Player.x - this.x;
            var GapY:Number = GameMain.Instance.m_Player.y - this.y;

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


