/*
　「テトリミノAct (Tetromino Act)」
　・T字のテトリミノが回転を駆使しつつ進むアクッションゲーム

　操作方法
　・十字キー(Arrow)
　　・移動(Move)＆ジャンプ(Jump)
　・Aキー、Sキー
　　・回転(Rotate)

*/



package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import net.wonderfl.utils.WonderflAPI;
 
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
        static public const P:int = m_MapIter++;//プレイヤー
        static public const G:int = m_MapIter++;//ゴール

        static public const MAP:Array = [
[W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,W,W,W,W,W,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,W,W,W,W,W,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,W,O,O,O,W,W,W,W,W,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,W,O,O,O,W,W,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,W,O,O,O,W,W,W,W,W,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,O,W,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W,W,W,W,W,W,O,O,W,W,O,O,W,O,O,O,O,W,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W,W,W,W,W,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,O,O,O,W,O,O,W,W,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,P,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,O,O,W,W,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,O,O,O,W,W,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,O,O,O,W,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,W,O,O,W,O,O,W,W,O,O,O,O,O,O,O,W,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,W],
[W,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,G,O,W],
[W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
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

        //画像
        public var m_BitmapData_BG:BitmapData   = new BitmapData(MAP_W, MAP_H, false, 0x000000);

        //プレイヤー
        public var m_Player:Player;

        //ゴール
        public var m_Goal:Goal;

        //テキスト
        public var m_Text:TextField = new TextField();
        public var m_Text_Score:TextField = new TextField();

        //モード
        public var m_Mode:int = MODE_MAIN;

        //スコア
        public var m_Score:int = 10000;

        //==Function==

        //Init
        public function GameMain():void {
            //Pseudo Singleton
            {
                Instance = this;
            }

            //Static Init
            {
                ImageManager.Init();
                ScoreWindowLoader.init(this, new WonderflAPI(loaderInfo.parameters));
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
                }
            }

            //背景
            {
                m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG));
            }

            //プレイヤー
            {
                m_Player = new Player();
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
                            //m_BitmapData_BG.fillRect(rect, 0xFF444444);
                            ImageManager.DrawBlock(m_BitmapData_BG, x, y, 0xFF004040);
                            break;
                        case P:
                            //プレイヤーの位置指定
                            m_Player.SetPos(
                                x * PANEL_LEN,
                                y * PANEL_LEN
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

            //Text
            {
                m_Text_Score.selectable = false;
                m_Text_Score.autoSize = TextFieldAutoSize.RIGHT;
                m_Text_Score.defaultTextFormat = new TextFormat('Verdana', 16, 0xFFFFFF, true);
                m_Text_Score.text = '0';
                m_Text_Score.filters = [new GlowFilter(0x00FFFF,1.0, 4,4)];

                m_Text_Score.x = VIEW_W - 32;
                m_Text_Score.y = 0;

                addChild(m_Text_Score);
            }
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

            if(! IsEnd()){
                --m_Score;
                if(m_Score < 0){
                    m_Score = 0;
                }

                m_Text_Score.text = m_Score.toString();
            }
        }

        //Update : Camera
        public function Update_Camera():void{
            var PlayerX:int = m_Player.x;
            var PlayerY:int = m_Player.y;

            //移動量
            var CameraMoveX:int = 0;
            var CameraMoveY:int = 0;
            {
                //現在のカメラでのプレイヤー相対位置
                var RelPlayerX:Number = PlayerX + m_Layer_Root.x;
                var RelPlayerY:Number = PlayerY + m_Layer_Root.y;

                //中央からの差がそのまま移動量
                CameraMoveX = VIEW_W/2 - RelPlayerX;
                CameraMoveY = VIEW_H/2 - RelPlayerY;
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

//*
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

            //スコア表示に移る
            ScoreWindowLoader.show(GameMain.Instance.m_Score);
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
import net.wonderfl.utils.WonderflAPI;


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

    //最高下降速度
    static public const FALL_VEL_MIN:Number = 1000.0;

    //ミノの並び
    static public const MINO:Array = [
        [
            [0, 1, 0],
            [1, 1, 1],
            [0, 0, 0],
        ],
        [
            [0, 1, 0],
            [0, 1, 1],
            [0, 1, 0],
        ],
        [
            [0, 0, 0],
            [1, 1, 1],
            [0, 1, 0],
        ],
        [
            [0, 1, 0],
            [1, 1, 0],
            [0, 1, 0],
        ],
    ];


    //==Var==

    //移動まわりのパラメータ
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);

    //ミノの状態
    public var m_MinoIter:int = 0;
    public var m_MinoIter_Trg:int = 0;

    //入力
    public var m_InputL:Boolean = false;
    public var m_InputR:Boolean = false;
    public var m_InputU:Boolean = false;
    public var m_InputD:Boolean = false;
    public var m_InputRotateL:Boolean = false;
    public var m_InputRotateR:Boolean = false;

    //プレイヤーのグラフィック
    public var m_BitmapData:BitmapData = new BitmapData(3*GameMain.PANEL_LEN, 3*GameMain.PANEL_LEN, true, 0x00000000);

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
            addChild(new Bitmap(m_BitmapData));

            RefreshGraphic();
        }
    }

    public function RefreshGraphic():void{
        for(var IterX:int = 0; IterX < 3; IterX++){
            for(var IterY:int = 0; IterY < 3; IterY++){
                var color:uint = 0x00000000;
                if(MINO[m_MinoIter][IterY][IterX] == 1){color = 0xFF8030C0;}

                ImageManager.DrawBlock(m_BitmapData, IterX, IterY, color);
            }
        }
    }

    //Init : Pos
    public function SetPos(in_X:int, in_Y:int):void{
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
    }

    //Update : Input
    static public const KEY_A:int = 65;
    static public const KEY_S:int = 83;
    private function OnKeyDown(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = true;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = true;}
        if(event.keyCode == Keyboard.UP){    m_InputU = true;}
        if(event.keyCode == Keyboard.DOWN){    m_InputD = true;}

        switch(event.keyCode){
        case KEY_A:
            if(! m_InputRotateL){
                m_InputRotateL = true;

                m_MinoIter_Trg = (m_MinoIter + 1) % 4;
            }
            break;
        case KEY_S:
            if(! m_InputRotateR){
                m_InputRotateR = true;

                m_MinoIter_Trg = (m_MinoIter + 3) % 4;
            }
            break;
        }
    }
    private function OnKeyUp(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = false;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = false;}
        if(event.keyCode == Keyboard.UP){    m_InputU = false;}
        if(event.keyCode == Keyboard.DOWN){    m_InputD = false;}

        switch(event.keyCode){
        case KEY_A:
            m_InputRotateL = false;
            break;
        case KEY_S:
            m_InputRotateR = false;
            break;
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

        //死亡チェック
        Check_Dead();
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
                    if(IsWall(TryX, m_Pos.y, m_MinoIter)){
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
                    if(IsWall(m_Pos.x, TryY, m_MinoIter)){
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

        //回転
        {
            if(m_MinoIter != m_MinoIter_Trg){
                var IsRot:Boolean = false;

                if(! IsWall(this.x, this.y, m_MinoIter_Trg)){
                    //そのまま回転可能
                    IsRot = true;
                }else{
                    if(! IsWall(this.x, this.y - GameMain.PANEL_LEN, m_MinoIter_Trg)){
                        //一段上に上がれば回転可能
                        IsRot = true;

                        m_Pos.y -= GameMain.PANEL_LEN;
                        this.y -= GameMain.PANEL_LEN;
                    }
                }

                if(IsRot){
                    //回転
                    m_MinoIter = m_MinoIter_Trg;//採用

                    RefreshGraphic();
                }else{
                    //回転不可
                    m_MinoIter_Trg = m_MinoIter;//不採用
                }
            }
        }
    }

    //壁があるかどうか
    public function IsWall(in_X:int, in_Y:int, in_MinoIter:int):Boolean{
        for(var IterX:int = 0; IterX < 3; IterX++){
            for(var IterY:int = 0; IterY < 3; IterY++){
                if(MINO[in_MinoIter][IterY][IterX] == 1){
                    if(GameMain.Instance.GetWallVal(in_X + IterX * GameMain.PANEL_LEN, in_Y + IterY * GameMain.PANEL_LEN) == GameMain.W){
                        return true;
                    }
                    if(GameMain.Instance.GetWallVal(in_X + (IterX + 1) * GameMain.PANEL_LEN - 1, in_Y + IterY * GameMain.PANEL_LEN) == GameMain.W){
                        return true;
                    }
                    if(GameMain.Instance.GetWallVal(in_X + IterX * GameMain.PANEL_LEN, in_Y + (IterY + 1) * GameMain.PANEL_LEN - 1) == GameMain.W){
                        return true;
                    }
                    if(GameMain.Instance.GetWallVal(in_X + (IterX + 1) * GameMain.PANEL_LEN - 1, in_Y + (IterY + 1) * GameMain.PANEL_LEN - 1) == GameMain.W){
                        return true;
                    }
                }
            }
        }

        return false;
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
/*
            var GapX:Number = GameMain.Instance.m_Player.x - this.x;
            var GapY:Number = GameMain.Instance.m_Player.y - this.y;

            var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            if(Distance > GOAL_RANGE){
                return;
            }
/*/
            var RelX:Number = this.x - GameMain.Instance.m_Player.x;
            var RelY:Number = this.y - GameMain.Instance.m_Player.y;

            var MinoIter:int = GameMain.Instance.m_Player.m_MinoIter;
            var IndexX:int = RelX / GameMain.PANEL_LEN;
            var IndexY:int = RelY / GameMain.PANEL_LEN;

            //Range
            if(IndexX < 0){return;}
            if(3 <= IndexX){return;}
            if(IndexY < 0){return;}
            if(3 <= IndexY){return;}

            //Mino
            if(Player.MINO[MinoIter][IndexY][IndexX] == 0){
                return;
            }
//*/
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
    static public var rect:Rectangle;
    static public var mtx:Matrix;
    static public var bmd_over:BitmapData;

    //Init
    static public function Init():void{
        const W:int = GameMain.PANEL_LEN/8;

        rect = new Rectangle(0, 0, GameMain.PANEL_LEN, GameMain.PANEL_LEN);
        mtx = new Matrix();
        bmd_over = new BitmapData(GameMain.PANEL_LEN, GameMain.PANEL_LEN, true, 0x00000000);

        for(var x:int = 0; x < GameMain.PANEL_LEN; x++){
            for(var y:int = 0; y < GameMain.PANEL_LEN; y++){
                if(W <= x && x < GameMain.PANEL_LEN - W && W <= y && y < GameMain.PANEL_LEN - W){continue;}

                var color:uint = 0x00000000;
                if(x < y){
                    if(x + y < GameMain.PANEL_LEN){
                        //L
                        color = 0x88FFFFFF;
                    }else{
                        //D
                        color = 0x66000000;
                    }
                }else{
                    if(x + y < GameMain.PANEL_LEN){
                        //U
                        color = 0x66FFFFFF;
                    }else{
                        //R
                        color = 0x88000000;
                    }
                }
                bmd_over.setPixel32(x, y, color);
            }
        }
    }

    static public function DrawBlock(in_BMD:BitmapData, in_X:int, in_Y:int, in_Color:uint):void{
        rect.x = in_X * GameMain.PANEL_LEN;
        rect.y = in_Y * GameMain.PANEL_LEN;

        mtx.tx = in_X * GameMain.PANEL_LEN;
        mtx.ty = in_Y * GameMain.PANEL_LEN;

        in_BMD.fillRect(rect, in_Color);

        if((in_Color & 0xFF000000) != 0x00000000){
            in_BMD.draw(bmd_over, mtx);
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


//bkzenさんのコードを利用
//@see http://wonderfl.net/c/cuY4
//@see http://wonderfl.net/c/kYyY
class ScoreWindowLoader
{
    private static var _top: DisplayObjectContainer;
    private static var _api: WonderflAPI;
    private static var _content: Object;
    //private static const URL: String = "wonderflScore.swf";
    private static const URL: String = "http://swf.wonderfl.net/swf/usercode/5/57/579a/579a46e1306b5770d429a3738349291f05fec4f3.swf";
    private static const TWEET: String = "Playing Tetromino Act [score: %SCORE%] #wonderfl";
    
    public static function init(top: DisplayObjectContainer, api: WonderflAPI): void 
    {
        _top = top, _api = api;
        var loader: Loader = new Loader();
        var comp: Function = function(e: Event): void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, comp);
            _content = loader.content;
//            handler();
        }
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp);
        loader.load(new URLRequest(URL), new LoaderContext(true));
    }
    
    /**
     * Wonderfl の Score API 用
     * ランキング表示から Tweet までをひとまとめにしたSWF素材を使う
     * @param    score            : 取得スコア
     * @param    closeHandler    : Window が閉じるイベントハンドら
     */
    public static function show( score: int): void
    {
        var window: DisplayObject = _content.makeScoreWindow(_api, score, "Tetromino Act", 1, TWEET);
//        var close: Function = function(e: Event): void
//        {
//            window.removeEventListener(Event.CLOSE, close);
//            closeHandler();
//        }
//        window.addEventListener(Event.CLOSE, close);
        _top.addChild(window);
    }
    
}
