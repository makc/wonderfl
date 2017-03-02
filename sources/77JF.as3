/*
　「ベタなロープアクション」
　・ごく普通のロープアクションゲーム

　操作方法
　・十字キー
　　・移動＆ジャンプ
　・SPACE（実際は十字キー以外全てのキーに対応）
　　・押してる間はプレイヤーとアンカーをロープで接続
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

        //マップ
        static public var m_MapIter:int = 0;
        static public const O:int = m_MapIter++;//空白
        static public const W:int = m_MapIter++;//壁
        static public const X:int = m_MapIter++;//アンカー
        static public const P:int = m_MapIter++;//プレイヤー
        static public const G:int = m_MapIter++;//ゴール

        static public const MAP:Array = [
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,O,O,O,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,G,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,X,O,O,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,X,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,X,O,O,O,O,O,O,O],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O],
            [W,O,P,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,O,O,O,O,X,O,O,O,O,O,X,O,O,O,O,O,X,O,O,O,O,O,X,O,O,O,O,O,X,O,O,O,O,O,O,O],
            [W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W],
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
        public var m_BitmapData_BG:BitmapData = new BitmapData(MAP_W, MAP_H, false, 0x000000);

        //プレイヤー
        public var m_Player:Player;

        //ゴール
        public var m_Goal:Goal;

        //テキスト
        public var m_Text:TextField = new TextField();

        //スコア
        public var m_Score:int = 10000;
        //スコア用テキスト
        public var m_ScoreText:TextField = new TextField();

        //モード
        public var m_Mode:int = MODE_MAIN;

        //==Function==

        //Init
        public function GameMain():void {
            //Pseudo Singleton
            {
                Instance = this;
            }
//*
            //Static Init
            {
                ScoreWindowLoader.init(this, new WonderflAPI(loaderInfo.parameters));
            }
//*/
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
                var FookShape:Shape = new Shape();
                {
                    var g:Graphics = FookShape.graphics;
                    //g.lineStyle(8, 0x880000, 1.0);
                    g.lineStyle(8, 0xFFFFFF, 1.0);

                    g.moveTo(PANEL_LEN*1/4, PANEL_LEN*2/4);
                    g.lineTo(PANEL_LEN*3/4, PANEL_LEN*2/4);
                    g.moveTo(PANEL_LEN*2/4, PANEL_LEN*1/4);
                    g.lineTo(PANEL_LEN*2/4, PANEL_LEN*3/4);
                }

                var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);
                var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
                for(var y:int = 0; y < MAP_NUM_Y; y++){
                    rect.y = mtx.ty = y * PANEL_LEN;
                    for(var x:int = 0; x < MAP_NUM_X; x++){
                        rect.x = mtx.tx = x * PANEL_LEN;

                        switch(MAP[y][x]){
                        case W:
                            //ロード前用の仮描画
                            m_BitmapData_BG.fillRect(rect, 0xFF444444);
                            break;
                        case X:
                            //フック位置の仮描画
                            m_BitmapData_BG.draw(FookShape, mtx);
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

            //Text
            {
                m_Text.selectable = false;
                m_Text.autoSize = TextFieldAutoSize.LEFT;
                m_Text.defaultTextFormat = new TextFormat('Verdana', 60, 0xFFFF00, true);
                m_Text.text = '';
                m_Text.filters = [new GlowFilter(0xFF0000)];

                addChild(m_Text);
            }
            {
                m_ScoreText.selectable = false;
                m_ScoreText.autoSize = TextFieldAutoSize.LEFT;
                m_ScoreText.defaultTextFormat = new TextFormat('Verdana', 16, 0x00FFFF, true);
                m_ScoreText.text = 'score : ' + m_Score.toString();
                m_ScoreText.filters = [new GlowFilter(0x0000FF)];

                addChild(m_ScoreText);

                m_ScoreText.x = (465 - m_ScoreText.width);
                m_ScoreText.y = 8;
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

            //Score
            {
                if(! IsEnd()){
                    if(m_Score > 0){m_Score--;}
                    m_ScoreText.text = 'score : ';
                    if(m_Score < 10000){m_ScoreText.appendText(' ');}
                    if(m_Score <  1000){m_ScoreText.appendText(' ');}
                    if(m_Score <   100){m_ScoreText.appendText(' ');}
                    if(m_Score <    10){m_ScoreText.appendText(' ');}
                    m_ScoreText.appendText(m_Score.toString());
                }
            }
        }

        //Update : Camera
        public function Update_Camera():void{
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

//*
            //スコア表示
            {
                ScoreWindowLoader.show(m_Score);
            }
//*/
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

        //
        public function GetMapVal(in_IndexX:int, in_IndexY:int):int{
            //範囲外は空白として扱う
            {
                if(in_IndexX < 0){return O;}
                if(in_IndexX >= MAP_NUM_X){return O;}
                if(in_IndexY < 0){return O;}
                if(in_IndexY >= MAP_NUM_Y){return O;}
            }

            return MAP[in_IndexY][in_IndexX];
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


//#ロープ用構造体
class SPoint
{
    //==Var==
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);
}

//#Player
class Player extends Sprite
{
    //==Const==

    //ロープの全長
    static public const ROPE_LEN:Number = GameMain.PANEL_LEN * 2.5;//STRAIGHT_POWで少し伸びる

    //ロープの分割数
    static public const NODE_NUM:int = 10;

    //ロープの分割されたやつの長さ
    static public const NODE_LEN:Number = ROPE_LEN / (NODE_NUM-1);

    //フックの探索距離（ロープの距離にかける倍率）
    static public const SEARCH_RATIO:Number = 1.8;

    //入力による移動力
    static public const MOVE_POW:Number = 500.0;
    //ポイントの距離の補正の試行回数
    static public const TRY_COUNT:int = 5;
    //擬似空気抵抗（速度の減衰率）
    static public const DEC_RATIO:Number = 0.995;
    //真っ直ぐになろうとする力
    static public const STRAIGHT_POW:Number = 300.0;

    //ラインの太さ
    static public const LINE_W:int = 8;

    //移動速度
    static public const VEL_X:Number = 100.0;

    //ジャンプ速度
    static public const JUMP_VEL:Number = 290.0;

    //重力
    static public const GRAVITY:Number = 500.0;


    //==Var==

    //ロープの各点([0]が根元)
    public var m_Point:Array = new Array(NODE_NUM);

    //移動まわりのパラメータ
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);

    //入力
    public var m_InputL:Boolean = false;
    public var m_InputR:Boolean = false;
    public var m_InputU:Boolean = false;
    public var m_InputRope:Boolean = false;

    //フック情報
    public var m_FookFlag:Boolean = false;
    public var m_FookPos:Point = new Point(0,0);
    public var m_FookSearchRight:Boolean = true;

    //表示画像
    public var m_Shape:Shape = new Shape();
    public var m_Graphics:Graphics = m_Shape.graphics;
    public var m_RopeGraphic:Graphics;

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

        //プレイヤーグラフィックの仮画像
        {
            var g:Graphics = m_Graphics;
            g.lineStyle(4,0xFFFFFF,1.0);
            g.drawCircle(0,0, GameMain.PANEL_LEN/2-2);
            g.beginFill(0xFFFFFF, 1.0);
            g.drawCircle(0,0, 2);
            g.endFill();

//            var Blur:Number = GameMain.PANEL_LEN/2;
//            m_Shape.filters = [new GlowFilter(0x00FFFF, 1.0, Blur,Blur)];

            addChild(m_Shape);
        }

        //ロープ画像
        {
            var rope_shape:Shape = new Shape();
            GameMain.Instance.m_Layer_Player.addChild(rope_shape);
            m_RopeGraphic = rope_shape.graphics;
        }

        //m_Point
        {
            for(var i:int = 0; i < NODE_NUM; i++){
                m_Point[i] = new SPoint();
            }
        }
    }

    //Init : Pos
    public function SetPos(in_X:int, in_Y:int):void{
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
    }

    public function SetVel(in_VX:int, in_VY:int):void{
        m_Vel.x = in_VX;
        m_Vel.y = in_VY;
    }

    //Update : Input
    private function OnKeyDown(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = true; m_FookSearchRight = false; return;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = true; m_FookSearchRight = true; return;}
        if(event.keyCode == Keyboard.UP){    m_InputU = true; return;}

        if(!m_InputRope){
//            if(event.keyCode == Keyboard.SPACE){
                //近くにフックがある場合のみ入力（モード変更）を許可する

                if(m_FookFlag){
                    m_InputRope = true;

                    //すぐにロープを張る
                    {
                        var SrcX:Number = this.x;
                        var SrcY:Number = this.y;
                        var DstX:Number = m_FookPos.x;
                        var DstY:Number = m_FookPos.y;

                        var SrcVX:Number = m_Vel.x;
                        var SrcVY:Number = m_Vel.y;
                        var DstVX:Number = 0;
                        var DstVY:Number = 0;

                        for(var i:int = 0; i < NODE_NUM; i++){
                            var Ratio:Number = 1.0 - i / (NODE_NUM-1.0);

                            m_Point[i].m_Pos.x = Lerp(SrcX, DstX, Ratio);
                            m_Point[i].m_Pos.y = Lerp(SrcY, DstY, Ratio);

                            m_Point[i].m_Vel.x = Lerp(SrcVX, DstVX, Ratio);
                            m_Point[i].m_Vel.y = Lerp(SrcVY, DstVY, Ratio);
                        }
                    }
                }
//            }
        }
    }
    private function OnKeyUp(event:KeyboardEvent):void{
        if(event.keyCode == Keyboard.LEFT){    m_InputL = false; return;}
        if(event.keyCode == Keyboard.RIGHT){m_InputR = false; return;}
        if(event.keyCode == Keyboard.UP){    m_InputU = false; return;}
        //if(event.keyCode == Keyboard.SPACE){m_InputRope = false;}
        m_InputRope = false;
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        //死亡・ゴール時は何もしない
        if(GameMain.Instance.IsEnd()){
            return;
        }

        //フックの位置を探索
        Check_Fook();

        //移動
        Update_Move(in_DeltaTime);

        //描画
        Update_Graphic(in_DeltaTime);

        //死亡チェック
        Check_Dead();
    }

    //Check : Fook
    public function Check_Fook():void{
        //前上、前下、後上、後下の順で、まずは優先順位を付ける
        //まだ候補が複数あれば、近いやつを採用

        //ロープに掴まっているなら変更しない
        if(m_InputRope){
            return;
        }

        const Range:int = int(ROPE_LEN / GameMain.PANEL_LEN) + 1;

        var center_x:int = this.x / GameMain.PANEL_LEN;
        var center_y:int = this.y / GameMain.PANEL_LEN;

        m_FookFlag = false;
        var MinLen:Number = ROPE_LEN*100;
        for(var offset_x:int = -Range; offset_x <= Range; offset_x++){
            for(var offset_y:int = -Range; offset_y <= Range; offset_y++){
                var index_x:int = center_x + offset_x;
                var index_y:int = center_y + offset_y;
                if(GameMain.Instance.GetMapVal(index_x, index_y) == GameMain.X){
                    var trg_x:Number = (index_x+0.5) * GameMain.PANEL_LEN;
                    var trg_y:Number = (index_y+0.5) * GameMain.PANEL_LEN;

                    var gap_x:Number = trg_x - this.x;
                    var gap_y:Number = trg_y - this.y;

                    var len:Number = Math.sqrt(gap_x*gap_x + gap_y*gap_y);
                    if(ROPE_LEN * SEARCH_RATIO < len){continue;}//この時点でロープに届いていなければスキップ
                    if(gap_y > 0){len += ROPE_LEN;}//プレイヤーより下にあるなら優先順位を下げる
                    if(m_FookSearchRight != (gap_x > 0)){len += ROPE_LEN*2;}//向いてる方向が逆なら優先順位を下げる

                    if(len < MinLen){
                        MinLen = len;

                        m_FookFlag = true;
                        m_FookPos.x = trg_x;
                        m_FookPos.y = trg_y;
                    }
                }
            }
        }
    }

    //Update : Graphic
    public function Update_Graphic(in_DeltaTime:Number):void{
        var g:Graphics = m_RopeGraphic;

        g.clear();

        //フック位置の描画
        if(m_FookFlag){
            g.lineStyle(4, 0xFFFFFF, 1.0);

            g.drawCircle(m_FookPos.x, m_FookPos.y, GameMain.PANEL_LEN/2);
        }

        //ロープの描画
        if(m_InputRope){
            g.lineStyle(8, 0xFFFFFF, 1.0);

            var SrcX:Number = m_Point[0].m_Pos.x;
            var SrcY:Number = m_Point[0].m_Pos.y;

            g.moveTo(SrcX, SrcY);

            for(var i:int = 1; i < NODE_NUM; i++){
                var DstX:Number = m_Point[i].m_Pos.x;
                var DstY:Number = m_Point[i].m_Pos.y;

                g.lineTo(DstX, DstY);

                SrcX = DstX;
                SrcY = DstY;
            }
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
        if(m_InputRope){
            Update_Move_Rope(in_DeltaTime);
        }else{
            Update_Move_Normal(in_DeltaTime);
        }
    }

    //Update : Move : Rope
    public function Update_Move_Rope(in_DeltaTime:Number):void{
        var i:int;

        //入力による補正
        {
            var InputVal:Number = 0;
            {
                if(m_InputL){InputVal -= 1;}
                if(m_InputR){InputVal += 1;}
            }

            //先端の力が大きくなるように全体にかけるとわりとそれっぽい
            {
                for(i = 0; i < NODE_NUM; i++){
                    var ratio:Number = i/(NODE_NUM-1.0);
                    ratio *= ratio;//固定点付近の力をさらに少なくする
                    m_Point[i].m_Vel.x += InputVal * MOVE_POW * in_DeltaTime * ratio;
                }
            }
        }

        //まずは慣性(Vel)と重力(Gravity)での移動先を算出
        var NextPos:Array = new Array(NODE_NUM);
        {
            var PrePrePosX:Number = m_Point[0].m_Pos.x;
            var PrePrePosY:Number = m_Point[0].m_Pos.y;
            var PrePosX:Number = m_Point[0].m_Pos.x;
            var PrePosY:Number = m_Point[0].m_Pos.y;
            for(i = 0; i < NODE_NUM; i++){
                //想定移動先
                if(i == 0){NextPos[i] = new Point(m_Point[i].m_Pos.x, m_Point[i].m_Pos.y); continue}

                NextPos[i] = new Point(
                    (m_Point[i].m_Pos.x) + (m_Point[i].m_Vel.x * in_DeltaTime) + (STRAIGHT_POW * in_DeltaTime * (PrePosX - PrePrePosX) / ROPE_LEN),
                    (m_Point[i].m_Pos.y) + (m_Point[i].m_Vel.y * in_DeltaTime) + (STRAIGHT_POW * in_DeltaTime * (PrePosY - PrePrePosY) / ROPE_LEN) + (GRAVITY * 0.5*in_DeltaTime*in_DeltaTime)
                );

                PrePrePosX = PrePosX;
                PrePrePosY = PrePosY;
                PrePosX = NextPos[i].x;
                PrePosY = NextPos[i].y;
            }
        }

        //ポイント間の距離を一定に保とうとする
        {
            for(var c:int = 0; c < TRY_COUNT; c++){
                //for(i = 1; i < NODE_NUM; ++i)
                for(i = NODE_NUM-1; i > 0; i--)
                {
                    var SrcIndex:int = i-1;
                    var DstIndex:int = i;

                    var SrcPos:Point = NextPos[SrcIndex];
                    var DstPos:Point = NextPos[DstIndex];

                    var Center:Point = new Point(
                        (DstPos.x + SrcPos.x)/2,
                        (DstPos.y + SrcPos.y)/2
                    );

                    var Src_Dst:Point = new Point(
                        (DstPos.x - SrcPos.x),
                        (DstPos.y - SrcPos.y)
                    );

                    //想定より短い分には調整しない
                    if(Src_Dst.length < NODE_LEN){continue;}

                    Src_Dst.normalize(1);

                    SrcPos.x = Center.x - NODE_LEN/2 * Src_Dst.x;
                    SrcPos.y = Center.y - NODE_LEN/2 * Src_Dst.y;
                    DstPos.x = Center.x + NODE_LEN/2 * Src_Dst.x;
                    DstPos.y = Center.y + NODE_LEN/2 * Src_Dst.y;
                }

                //[0]は戻す
                NextPos[0].x = m_Point[0].m_Pos.x;
                NextPos[0].y = m_Point[0].m_Pos.y;
            }
        }

        //ポイントが壁にめり込んでいたら、めりこまないように前回位置に半分ずつ近づける
        {//最初からめり込んでる時のためにカウンタを入れた
            for(i = 0, c = 0; i < NODE_NUM; ){
                var IndexX:int = NextPos[i].x / GameMain.PANEL_LEN;
                var IndexY:int = NextPos[i].x / GameMain.PANEL_LEN;

                //if(GameMain.Instance.GetMapVal(IndexX, IndexY) == GameMain.W)
                if(IsWall(NextPos[i].x, NextPos[i].y) && c++ < TRY_COUNT)
                {
                    NextPos[i].x = Lerp(m_Point[i].m_Pos.x, NextPos[i].x, 0.5);
                    NextPos[i].y = Lerp(m_Point[i].m_Pos.y, NextPos[i].y, 0.5);
                }else{
                    i++;
                    c = 0;
                }
            }
        }

        //速度の再計算
        {
            for(i = 0; i < NODE_NUM; ++i){
                //今回の移動量から逆算
                m_Point[i].m_Vel.x = (NextPos[i].x - m_Point[i].m_Pos.x) / in_DeltaTime;
                m_Point[i].m_Vel.y = (NextPos[i].y - m_Point[i].m_Pos.y) / in_DeltaTime;

                //重力による速度補正
                m_Point[i].m_Vel.y += GRAVITY * in_DeltaTime;

                //擬似空気抵抗
                m_Point[i].m_Vel.x *= DEC_RATIO;
                m_Point[i].m_Vel.y *= DEC_RATIO;
            }
        }

        //位置の正式採用
        {
            for(i = 0; i < NODE_NUM; ++i){
                m_Point[i].m_Pos = NextPos[i];
            }
        }

        //反映
        {
            SetPos(m_Point[NODE_NUM-1].m_Pos.x, m_Point[NODE_NUM-1].m_Pos.y);
            SetVel(m_Point[NODE_NUM-1].m_Vel.x, m_Point[NODE_NUM-1].m_Vel.y);
        }
    }

    //Update : Move : Normal
    public function Update_Move_Normal(in_DeltaTime:Number):void{
        //入力
        {
            //X
            {
                var TrgVX:Number = 0.0;
                if(m_InputR){TrgVX =  VEL_X; this.scaleX =  1;}
                if(m_InputL){TrgVX = -VEL_X; this.scaleX = -1;}

                var ratio:Number = 0.5;
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

    //壁があるかどうか
    public function IsWall(in_X:int, in_Y:int):Boolean{
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
            switch(GameMain.MAP[IndexY][IndexX]){
            case GameMain.W:
                return true;
            }
        }

        //四隅に壁が見つからなかったら壁はないと判断
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

    static public const GOAL_RANGE:int = 8;


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
    //==Const==


    //==Function==

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
/*
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
/*/
            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            g.lineStyle(4, 0xFFFF00, 1.0);
            g.drawCircle(W/2, H - GameMain.PANEL_LEN/2 - 6, GameMain.PANEL_LEN/2);

            shape.filters = [new GlowFilter(0xFF0000,1.0, 6,6)];

            bmd.draw(shape);
//*/

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

//*
import net.wonderfl.utils.WonderflAPI;

//bkzenさんのコードを利用
//@see http://wonderfl.net/c/cuY4
//@see http://wonderfl.net/c/kYyY
class ScoreWindowLoader
{
    private static var _top: DisplayObjectContainer;
    private static var _api: WonderflAPI;
    private static var _content: Object;
    private static const URL: String = "http://swf.wonderfl.net/swf/usercode/5/57/579a/579a46e1306b5770d429a3738349291f05fec4f3.swf";
    private static const TITLE: String = "ベタナ・ロープ・アクト";
    private static const TWEET: String = "Playing ベタナ・ロープ・アクト [score: %SCORE%] #wonderfl";

    //初期化
    public static function init(top: DisplayObjectContainer, api: WonderflAPI): void 
    {
        _top = top, _api = api;
        var loader: Loader = new Loader();
        var comp: Function = function(e: Event): void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, comp);
            _content = loader.content;
        }
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp);
        loader.load(new URLRequest(URL), new LoaderContext(true));
    }

    //表示
    public static function show( score: int): void
    {
        var window: DisplayObject = _content.makeScoreWindow(_api, score, TITLE, 1, TWEET);
        _top.addChild(window);
    }
    
}
//*/
