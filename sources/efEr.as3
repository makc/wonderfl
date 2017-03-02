/*
　「キーボードクライマー(Keyboard Climber)」
　・キーを押し続けながら登っていくゲーム

　操作方法(How to Play)
　・キーを押す(Key:Press)
　　・掴む（Hang）
　・キーを離す(Key:Release)
　　・離す（Release）
　・SPACE
　　・描画モード変更（線画<=>ダンボー）
　　　・ただしダンボーだと腕が頭に隠れて見にくい
*/

/*
Memo

ステージの座標系について
・画面の中央下が原点
　・X：中央が０で、左がマイナス、右がプラス
　・Y：地面が０で、上に行くほどマイナス
*/

package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import flash.ui.*;
 
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0xFFFFFF")]
    public class GameMain extends Sprite {
        //==Const==

        //画面の大きさ
        static public const VIEW_W:int = 465;
        static public const VIEW_H:int = 465;

        //キーの配置の幅
        static public const KEY_GAP_W:int = 74;
        static public const KEY_GAP_H:int = 48;
        static public const KEY_INIT_OFFSET_Y:int = 230;

        //キー
        static public const KEY_BASE:int = 65;
        static public const A:int = KEY_BASE + 0;
        static public const B:int = KEY_BASE + 1;
        static public const C:int = KEY_BASE + 2;
        static public const D:int = KEY_BASE + 3;
        static public const E:int = KEY_BASE + 4;
        static public const F:int = KEY_BASE + 5;
        static public const G:int = KEY_BASE + 6;
        static public const H:int = KEY_BASE + 7;
        static public const I:int = KEY_BASE + 8;
        static public const J:int = KEY_BASE + 9;
        static public const K:int = KEY_BASE + 10;
        static public const L:int = KEY_BASE + 11;
        static public const M:int = KEY_BASE + 12;
        static public const N:int = KEY_BASE + 13;
        static public const O:int = KEY_BASE + 14;
        static public const P:int = KEY_BASE + 15;
        static public const Q:int = KEY_BASE + 16;
        static public const R:int = KEY_BASE + 17;
        static public const S:int = KEY_BASE + 18;
        static public const T:int = KEY_BASE + 19;
        static public const U:int = KEY_BASE + 20;
        static public const V:int = KEY_BASE + 21;
        static public const W:int = KEY_BASE + 22;
        static public const X:int = KEY_BASE + 23;
        static public const Y:int = KEY_BASE + 24;
        static public const Z:int = KEY_BASE + 25;
        static public const _:int = -1;

        //Map
        static public const MAP:Array = [
            [0, _, _, _],
            [_, O, _, _],
            [_, _, K, _],
            [_, _, _, M],
            [_, _, J, N],
            [7, _, H, _],
            [6, _, _, _],
            [5, T, G, _],
            [_, _, _, _],
            [_, _, _, V],
            [_, R, _, _],
            [_, _, D, _],
            [_, E, _, _],
            [_, _, _, _],
            [_, _, _, X],
            [_, _, _, _],
            [_, W, _, _],
            [_, _, _, _],
            [_, _, _, Z],
            [_, _, _, _],
            [_, Q, _, _],
        ];


        //==Var==

        //Pseudo Singleton
        static public var Instance:GameMain;

        //レイヤー
        public var m_Layer_Root:Sprite = new Sprite();

        //プレイヤー
        public var m_Player:Player;

        //ゴールエリア
        public var m_Goal:Sprite;

        //テキスト
        public var m_Text:TextField = new TextField();
        public var m_Text_Score:TextField = new TextField();

        //Flag
        public var m_IsGoal:Boolean = false;


        //==Function==

        //Init
        public function GameMain() {
            var i:int;
            var x:int;
            var y:int;

            var NumX:int = MAP[0].length;
            var NumY:int = MAP.length;

            //Pseudo Singleton
            {
                Instance = this;
            }

            //Layer
            {
                addChild(m_Layer_Root);

                //原点を画面下とする
                m_Layer_Root.x = VIEW_W/2;
                m_Layer_Root.y = VIEW_H;
            }

            //Player
            {
                m_Player = new Player();
                m_Layer_Root.addChild(m_Player);
            }

            //Key
            {
                const NUMBER_LIST:Array = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
                const TEXT_LIST:Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

                for(y = 0; y < NumY; y++){
                    for(x = 0; x < NumX; x++){
                        var text:TextField;
                        //Text
                        {
                            text = new TextField();
                            text.selectable = false;
                            text.autoSize = TextFieldAutoSize.LEFT;
                            text.defaultTextFormat = new TextFormat('Verdana', VIEW_W/16, 0x000000, true);
                            //text.filters = [new GlowFilter(0x440000)];
                        }

                        var index:int = MAP[y][x];
                        if(0 <= index){
                            if(index < 10){
                                text.text = NUMBER_LIST[index];
                            }else{
                                text.text = TEXT_LIST[index - KEY_BASE];
                            }
                        }

                        //Pos
                        {
                            text.x = KEY_GAP_W*(x-2) - text.textWidth/2  -3;
                            text.y = -KEY_INIT_OFFSET_Y - KEY_GAP_H*(NumY-1-y) - text.textHeight/2 -2;
                        }

                        if(0 <= index){
                            m_Layer_Root.addChild(text);
                        }
                    }
                }
            }

            //Goal
            {
                m_Goal = new Sprite();

                //Graphic
                var g:Graphics = m_Goal.graphics;
                g.lineStyle(5, 0xFF8800, 1.0);
                for(x = 0; x < NumX; x++){
                    if(0 <= MAP[0][x]){
                        g.drawCircle(KEY_GAP_W * (x-2), 0, 24);
                    }
                }

                //Pos
                m_Goal.x = 0;
                m_Goal.y = -(KEY_GAP_H * (MAP.length-1) + KEY_INIT_OFFSET_Y);

                m_Layer_Root.addChild(m_Goal);
            }


            //Text
            {
                m_Text_Score.selectable = false;
                m_Text_Score.autoSize = TextFieldAutoSize.RIGHT;
                m_Text_Score.defaultTextFormat = new TextFormat('Verdana', 16, 0xFFFFFF, true);
                m_Text_Score.text = '';
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
                m_Text.filters = [new GlowFilter(0x0000FF,1.0, 8,8)];

                addChild(m_Text);
            }

            //Keyboard
            {
                //キー入力を見る
                stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
                stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }
        }

        //Key
        private function OnKeyDown(event:KeyboardEvent):void{
            var NumX:int = MAP[0].length;
            var NumY:int = MAP.length;
            var index:int;

            if(event.keyCode == Keyboard.SPACE){
                //表示モード切替
                m_Player.m_IsDanboard = !m_Player.m_IsDanboard;
                return;
            }

            for(var y:int = 0; y < NumY; y++){
                for(var x:int = 0; x < NumX; x++){
                    index = MAP[y][x];
                    if(event.keyCode == index){
                        m_Player.TryToHang(x, NumY-1 - y);
                        continue;
                    }
                    if(event.keyCode-48 == index){
                        m_Player.TryToHang(x, NumY-1 - y);
                        continue;
                    }
                }
            }
        }
        private function OnKeyUp(event:KeyboardEvent):void{
            var NumX:int = MAP[0].length;
            var NumY:int = MAP.length;
            var index:int;

            for(var y:int = 0; y < NumY; y++){
                for(var x:int = 0; x < NumX; x++){
                    index = MAP[y][x];
                    if(event.keyCode == index){
                        m_Player.TryToRelease(x, NumY-1 - y);
                        continue;
                    }
                    if(event.keyCode-48 == index){
                        m_Player.TryToRelease(x, NumY-1 - y);
                        continue;
                    }
                }
            }
        }

        //Update
        public function Update(e:Event=null):void{
            var DeltaTime:Number = 1.0 / stage.frameRate;

            if(m_IsGoal){return;}

            m_Player.Update(DeltaTime);

            Update_Camera();

            Check_Goal();
        }

        //Update : Camera
        public function Update_Camera():void{
            //m_Layer_Root.y + m_Player.GetCenterY() = VIEW_H/2;//プレイヤーの位置が画面中央
            m_Layer_Root.y = VIEW_H/2 - m_Player.GetCenterY();
            if(m_Layer_Root.y < VIEW_H){
                   m_Layer_Root.y = VIEW_H;
            }
        }

        //Check : Goal
        public function Check_Goal():void{
//            m_IsGoal = (m_Player.m_Part[Player.PART_HAND_L].y < m_Goal.y) || (m_Player.m_Part[Player.PART_HAND_R].y < m_Goal.y);
            const GoalIndexY:int = MAP.length-1;
            m_IsGoal = (m_Player.m_HangFlag_L && m_Player.m_HangIndexY_L == GoalIndexY) || (m_Player.m_HangFlag_R && m_Player.m_HangIndexY_R == GoalIndexY);

            if(m_IsGoal){
                //Text
                {
                    //Text
                    m_Text.text = 'Goal';

                    //Centering
                    m_Text.x = (stage.stageWidth - m_Text.width) / 2;
                    m_Text.y = (stage.stageHeight - m_Text.height) / 2;
                }
            }
        }
    }
}


import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;


//関節部分
//- 位置や速度の保持
class Node
{
    public var x:Number = 0;
    public var y:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;

    public var OldX:Number = 0;
    public var OldY:Number = 0;

    public function RefreshVel(DeltaTime:Number):void{
        const DecRatio:Number = 0.98;

        vx = (x - OldX) / DeltaTime * DecRatio;
        vy = (y - OldY) / DeltaTime * DecRatio;

        OldX = x;
        OldY = y;
    }
}


//プレイヤー
class Player extends Sprite
{
    //==Const==

    //重力
    public static const GRAVITY:Number = 2000;

    //手を離した際のジャンプ力
    public static const HOP_VY:Number = 700;

    //腕の長さ
    public static const ARM_LEN:Number = 64;
    //肩幅
    public static const SHOULDER_GAP:Number = 64;
    //足の長さ
    public static const LEG_LEN:Number = 64;


    //体のパーツ
    private static var PartTypeIter:int = 0;
    public static const PART_HAND_L:int = PartTypeIter++;
    public static const PART_HAND_R:int = PartTypeIter++;
    public static const PART_SHOULDER_L:int = PartTypeIter++;
    public static const PART_SHOULDER_R:int = PartTypeIter++;
    public static const PART_CENTER:int = PartTypeIter++;
    public static const PART_HIP_L:int = PartTypeIter++;
    public static const PART_HIP_R:int = PartTypeIter++;
    public static const PART_FOOT_L:int = PartTypeIter++;
    public static const PART_FOOT_R:int = PartTypeIter++;
    public static const PART_NUM:int = PartTypeIter;


    //Util
    public static const SQRT_2:Number = Math.sqrt(2);
    public static const SQRT_3:Number = Math.sqrt(3);

    //==Var==

    //体のパーツ
    public var m_Part:Vector.<Node> = new Vector.<Node>(PART_NUM);

    //掴んでるかフラグ
    public var m_HangFlag_L:Boolean = false;
    public var m_HangFlag_R:Boolean = false;
    //掴んでいる場所
    public var m_HangIndexX_L:int = -1;
    public var m_HangIndexY_L:int = -1;
    public var m_HangIndexX_R:int = -1;
    public var m_HangIndexY_R:int = -1;

    //描画モード
    public var m_IsDanboard:Boolean = false;

    //==Function==

    public function Player(){
        var i:int;

        //Init : Pose
        {
            for(i = 0; i < PART_NUM; i++){
                m_Part[i] = new Node();
            }

            m_Part[PART_FOOT_L].x = -SHOULDER_GAP/2;
            m_Part[PART_FOOT_L].y = -0;

            m_Part[PART_HIP_L].x = -SHOULDER_GAP/2;
            m_Part[PART_HIP_L].y = m_Part[PART_FOOT_L].y - LEG_LEN;

            m_Part[PART_CENTER].x = 0;
            m_Part[PART_CENTER].y = m_Part[PART_HIP_L].y - LEG_LEN*SQRT_3/2;

            m_Part[PART_SHOULDER_L].x = -SHOULDER_GAP/2;
            m_Part[PART_SHOULDER_L].y = m_Part[PART_CENTER].y - LEG_LEN*SQRT_3/2;

            m_Part[PART_HAND_L].x = m_Part[PART_SHOULDER_L].x - ARM_LEN/SQRT_2;
            m_Part[PART_HAND_L].y = m_Part[PART_SHOULDER_L].y - ARM_LEN/SQRT_2;

            //左右対称
            m_Part[PART_FOOT_R].x = -m_Part[PART_FOOT_L].x;
            m_Part[PART_FOOT_R].y = m_Part[PART_FOOT_L].y;
            m_Part[PART_HIP_R].x = -m_Part[PART_HIP_L].x;
            m_Part[PART_HIP_R].y = m_Part[PART_HIP_L].y;
            m_Part[PART_HAND_R].x = -m_Part[PART_HAND_L].x;
            m_Part[PART_HAND_R].y = m_Part[PART_HAND_L].y;
            m_Part[PART_SHOULDER_R].x = -m_Part[PART_SHOULDER_L].x;
            m_Part[PART_SHOULDER_R].y = m_Part[PART_SHOULDER_L].y;

            //Reset Old
            for(i = 0; i < PART_NUM; i++){
                m_Part[i].OldX = m_Part[i].x;
                m_Part[i].OldY = m_Part[i].y;
            }
        }
    }

    static private var c:int = 0;
    public function Update(DeltaTime:Number):void{
        var LerpRatio:Number;
/*
        //test
        if(c++ < 30){
            return;
        }
        c = 0;
//*/
        UpdatePart_Base(DeltaTime);

        //腕の掴み状況などに応じて、位置調整の順序を変更する（依存関係を変更する）
        {
            var IsFixHandL:Boolean = m_HangFlag_L;
            var IsFixHandR:Boolean = m_HangFlag_R;
//            var IsFixHandL:Boolean = (m_HangFlag_L || 0 <= m_HangIndexX_L);
//            var IsFixHandR:Boolean = (m_HangFlag_R || 0 <= m_HangIndexX_R);

            //掴んでる腕と体の位置調整
            //- 腕の方を固定し、体だけ動かして位置調整
            if(IsFixHandL){
                UpdatePart_Arm_Body(m_Part[PART_HAND_L], m_Part[PART_SHOULDER_L], DeltaTime);
            }
            if(IsFixHandR){
                UpdatePart_Arm_Body(m_Part[PART_HAND_R], m_Part[PART_SHOULDER_R], DeltaTime);
            }

            //足が地面についていれば、体にフィードバックさせるために先に調整
            if(IsGroundL()){
                UpdatePart_Leg_Body(m_Part[PART_FOOT_L], m_Part[PART_HIP_L], DeltaTime);
            }
            if(IsGroundR()){
                UpdatePart_Leg_Body(m_Part[PART_FOOT_R], m_Part[PART_HIP_R], DeltaTime);
            }

            //体の４箇所の調整
            UpdatePart_Body(DeltaTime);

            //何も掴んでない腕と体の位置調整
            //- 体の方を固定し、腕だけ動かして位置調整
            if(! IsFixHandL){
                UpdatePart_Arm_Body(m_Part[PART_SHOULDER_L], m_Part[PART_HAND_L], DeltaTime);
            }
            if(! IsFixHandR){
                UpdatePart_Arm_Body(m_Part[PART_SHOULDER_R], m_Part[PART_HAND_R], DeltaTime);
            }

            //地面についてない足の調整
            if(! IsGroundL()){
                UpdatePart_Leg_Body(m_Part[PART_HIP_L], m_Part[PART_FOOT_L], DeltaTime);
            }
            if(! IsGroundR()){
                UpdatePart_Leg_Body(m_Part[PART_HIP_R], m_Part[PART_FOOT_R], DeltaTime);
            }
        }

        //全ての制御が終わったら、それを元に各パーツの速度を再計算
        {
            for(var i:int = 0; i < PART_NUM; i++){
                m_Part[i].RefreshVel(DeltaTime);
            }
        }

        //Graphics
        {
            var g:Graphics = this.graphics;

            g.clear();

            if(! m_IsDanboard){
                //＝線画バージョン＝
                g.lineStyle(8, 0x000000, 1.0);

                //左手～右手
                g.moveTo(m_Part[PART_HAND_L].x, m_Part[PART_HAND_L].y);
                g.lineTo(m_Part[PART_SHOULDER_L].x, m_Part[PART_SHOULDER_L].y);
                g.lineTo(m_Part[PART_SHOULDER_R].x, m_Part[PART_SHOULDER_R].y);
                g.lineTo(m_Part[PART_HAND_R].x, m_Part[PART_HAND_R].y);

                //頭
                g.drawCircle(
                    ((m_Part[PART_SHOULDER_L].x + (m_Part[PART_SHOULDER_R].y - m_Part[PART_SHOULDER_L].y)) + m_Part[PART_SHOULDER_R].x)/2,
                    ((m_Part[PART_SHOULDER_L].y - (m_Part[PART_SHOULDER_R].x - m_Part[PART_SHOULDER_L].x)) + m_Part[PART_SHOULDER_R].y)/2,
                    SHOULDER_GAP/2
                );

                //背
                g.moveTo(
                    (m_Part[PART_SHOULDER_L].x + m_Part[PART_SHOULDER_R].x)/2,
                    (m_Part[PART_SHOULDER_L].y + m_Part[PART_SHOULDER_R].y)/2
                );
                g.curveTo(//カーブしなくなったけど一応
                    m_Part[PART_CENTER].x,
                    m_Part[PART_CENTER].y,
                    (m_Part[PART_HIP_L].x + m_Part[PART_HIP_R].x)/2,
                    (m_Part[PART_HIP_L].y + m_Part[PART_HIP_R].y)/2
                );

                //左足～右足
                g.moveTo(m_Part[PART_FOOT_L].x, m_Part[PART_FOOT_L].y);
                g.lineTo(m_Part[PART_HIP_L].x, m_Part[PART_HIP_L].y);
                g.lineTo(m_Part[PART_HIP_R].x, m_Part[PART_HIP_R].y);
                g.lineTo(m_Part[PART_FOOT_R].x, m_Part[PART_FOOT_R].y);
            }else{
                //＝ダンボーバージョン＝

                const FILL_COLOR:uint = 0xCD853F;//peru

                var SrcX:Number;
                var SrcY:Number;
                var DstX:Number;
                var DstY:Number;
                var SideX:Number;
                var SideY:Number;

                var Distance:Number;

                g.lineStyle(1, 0x000000, 1.0);

                //Arm-L
                SideX = -(m_Part[PART_SHOULDER_L].y - m_Part[PART_HAND_L].y) / 4;
                SideY =  (m_Part[PART_SHOULDER_L].x - m_Part[PART_HAND_L].x) / 4;
                Distance = Math.sqrt(SideX*SideX + SideY*SideY);
                SideX *= (ARM_LEN/4) / Distance;
                SideY *= (ARM_LEN/4) / Distance;
                SrcX = m_Part[PART_SHOULDER_L].x;
                SrcY = m_Part[PART_SHOULDER_L].y;
                DstX = m_Part[PART_HAND_L].x;
                DstY = m_Part[PART_HAND_L].y;
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(SrcX - SideX, SrcY - SideY);
                g.lineTo(SrcX + SideX, SrcY + SideY);
                g.lineTo(DstX + SideX, DstY + SideY);
                g.lineTo(DstX - SideX, DstY - SideY);
                g.lineTo(SrcX - SideX, SrcY - SideY);
                g.endFill();

                //Arm-R
                SideX =  (m_Part[PART_SHOULDER_R].y - m_Part[PART_HAND_R].y) / 4;
                SideY = -(m_Part[PART_SHOULDER_R].x - m_Part[PART_HAND_R].x) / 4;
                Distance = Math.sqrt(SideX*SideX + SideY*SideY);
                SideX *= (ARM_LEN/4) / Distance;
                SideY *= (ARM_LEN/4) / Distance;
                SrcX = m_Part[PART_SHOULDER_R].x;
                SrcY = m_Part[PART_SHOULDER_R].y;
                DstX = m_Part[PART_HAND_R].x;
                DstY = m_Part[PART_HAND_R].y;
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(SrcX - SideX, SrcY - SideY);
                g.lineTo(SrcX + SideX, SrcY + SideY);
                g.lineTo(DstX + SideX, DstY + SideY);
                g.lineTo(DstX - SideX, DstY - SideY);
                g.lineTo(SrcX - SideX, SrcY - SideY);
                g.endFill();

                //Body
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(m_Part[PART_SHOULDER_L].x, m_Part[PART_SHOULDER_L].y);
                g.lineTo(m_Part[PART_SHOULDER_R].x, m_Part[PART_SHOULDER_R].y);
                g.lineTo(m_Part[PART_HIP_R].x, m_Part[PART_HIP_R].y);
                g.lineTo(m_Part[PART_HIP_L].x, m_Part[PART_HIP_L].y);
                g.lineTo(m_Part[PART_SHOULDER_L].x, m_Part[PART_SHOULDER_L].y);
                g.endFill();
                //Part
                const PartRatio:Number = 0.2;
                const PartRad:Number = SHOULDER_GAP/16;
                g.beginFill(0x888888, 1.0);
                g.drawCircle(Lerp(m_Part[PART_SHOULDER_R].x, m_Part[PART_HIP_L].x, PartRatio), Lerp(m_Part[PART_SHOULDER_R].y, m_Part[PART_HIP_L].y, PartRatio), PartRad);
                g.endFill();

                //Head
                SideX = (m_Part[PART_SHOULDER_R].x - m_Part[PART_SHOULDER_L].x) * 0.8;
                SideY = (m_Part[PART_SHOULDER_R].y - m_Part[PART_SHOULDER_L].y) * 0.8;
                SrcX = (m_Part[PART_SHOULDER_R].x + m_Part[PART_SHOULDER_L].x) / 2;
                SrcY = (m_Part[PART_SHOULDER_R].y + m_Part[PART_SHOULDER_L].y) / 2;
                DstX = SrcX + ((m_Part[PART_SHOULDER_R].x + m_Part[PART_SHOULDER_L].x) / 2 - (m_Part[PART_HIP_R].x + m_Part[PART_HIP_L].x) / 2) * 0.7;
                DstY = SrcY + ((m_Part[PART_SHOULDER_R].y + m_Part[PART_SHOULDER_L].y) / 2 - (m_Part[PART_HIP_R].y + m_Part[PART_HIP_L].y) / 2) * 0.7;
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(SrcX - SideX, SrcY - SideY);
                g.lineTo(SrcX + SideX, SrcY + SideY);
                g.lineTo(DstX + SideX, DstY + SideY);
                g.lineTo(DstX - SideX, DstY - SideY);
                g.lineTo(SrcX - SideX, SrcY - SideY);
                g.endFill();
                //Eye
                const EyeRatio:Number = 0.6;
                const EyeSideRatio:Number = 0.4;
                const EyeRad:Number = SHOULDER_GAP/10;
                g.beginFill(0x000000, 1.0);
                g.drawCircle(Lerp(SrcX, DstX, EyeRatio) + SideX*EyeSideRatio, Lerp(SrcY, DstY, EyeRatio) + SideY*EyeSideRatio, EyeRad);
                g.endFill();
                g.beginFill(0x000000, 1.0);
                g.drawCircle(Lerp(SrcX, DstX, EyeRatio) - SideX*EyeSideRatio, Lerp(SrcY, DstY, EyeRatio) - SideY*EyeSideRatio, EyeRad);
                g.endFill();
                //Mouse
                const MouthRatioU:Number = 0.4;
                const MouthRatioD:Number = 0.2;
                const MouthSideRatio:Number = 0.2;
                g.beginFill(0x000000, 1.0);
                g.moveTo(Lerp(SrcX, DstX, MouthRatioU), Lerp(SrcY, DstY, MouthRatioU));
                g.lineTo(Lerp(SrcX, DstX, MouthRatioD) + SideX*MouthSideRatio, Lerp(SrcY, DstY, MouthRatioD) + SideY*MouthSideRatio);
                g.lineTo(Lerp(SrcX, DstX, MouthRatioD) - SideX*MouthSideRatio, Lerp(SrcY, DstY, MouthRatioD) - SideY*MouthSideRatio);
                g.lineTo(Lerp(SrcX, DstX, MouthRatioU), Lerp(SrcY, DstY, MouthRatioU));
                g.endFill();

                //Leg-L
                SideX = -(m_Part[PART_HIP_L].y - m_Part[PART_FOOT_L].y) / 4;
                SideY =  (m_Part[PART_HIP_L].x - m_Part[PART_FOOT_L].x) / 4;
                SrcX = m_Part[PART_HIP_L].x + SideX;
                SrcY = m_Part[PART_HIP_L].y + SideY;
                DstX = m_Part[PART_FOOT_L].x + SideX;
                DstY = m_Part[PART_FOOT_L].y + SideY;
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(SrcX - SideX, SrcY - SideY);
                g.lineTo(SrcX + SideX, SrcY + SideY);
                g.lineTo(DstX + SideX, DstY + SideY);
                g.lineTo(DstX - SideX, DstY - SideY);
                g.lineTo(SrcX - SideX, SrcY - SideY);
                g.endFill();

                //Leg-R
                SideX =  (m_Part[PART_HIP_R].y - m_Part[PART_FOOT_R].y) / 4;
                SideY = -(m_Part[PART_HIP_R].x - m_Part[PART_FOOT_R].x) / 4;
                SrcX = m_Part[PART_HIP_R].x + SideX;
                SrcY = m_Part[PART_HIP_R].y + SideY;
                DstX = m_Part[PART_FOOT_R].x + SideX;
                DstY = m_Part[PART_FOOT_R].y + SideY;
                g.beginFill(FILL_COLOR, 1.0);
                g.moveTo(SrcX - SideX, SrcY - SideY);
                g.lineTo(SrcX + SideX, SrcY + SideY);
                g.lineTo(DstX + SideX, DstY + SideY);
                g.lineTo(DstX - SideX, DstY - SideY);
                g.lineTo(SrcX - SideX, SrcY - SideY);
                g.endFill();
            }

            //ついでに掴んだ部分の可視化処理も加えてみる
            g.lineStyle(5, 0x00FFFF, 0.6);
            if(m_HangFlag_L && 0 <= m_HangIndexX_L){
                g.drawCircle(GetTrgPointX(m_HangIndexX_L), GetTrgPointY(m_HangIndexY_L), 24);
            }
            if(m_HangFlag_R && 0 <= m_HangIndexX_R){
                g.drawCircle(GetTrgPointX(m_HangIndexX_R), GetTrgPointY(m_HangIndexY_R), 24);
            }
        }
    }

    public function FallPart(in_Part:Node, DeltaTime:Number):void{
        in_Part.y += (in_Part.vy * DeltaTime) + (0.5 * GRAVITY * DeltaTime * DeltaTime);
        in_Part.vy += GRAVITY * DeltaTime;
        in_Part.x += in_Part.vx * DeltaTime;

        //Range
        if(0 < in_Part.y){
            in_Part.y = 0;
            if(in_Part.vy < 0){
                in_Part.vy = 0;
            }
        }
        if(in_Part.x < -3*GameMain.KEY_GAP_W){
            in_Part.x = -3*GameMain.KEY_GAP_W;
            if(in_Part.vx < 0){
                in_Part.vx = 0;
            }
        }
        if(3*GameMain.KEY_GAP_W < in_Part.x){
            in_Part.x = 3*GameMain.KEY_GAP_W;
            if(0 < in_Part.vx){
                in_Part.vx = 0;
            }
        }
    }

    public function MovePart(in_Part:Node, DeltaTime:Number, in_TrgPointX:Number, in_TrgPointY:Number, in_Ratio:Number):void{
        var GapX:Number = in_TrgPointX - in_Part.x;
        var GapY:Number = in_TrgPointY - in_Part.y;

//        var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

        in_Part.x += GapX * in_Ratio;
        in_Part.y += GapY * in_Ratio;
    }

    public function GetTrgPointX(in_X:int):Number{
        return GameMain.KEY_GAP_W * (in_X-2);
    }
    public function GetTrgPointY(in_Y:int):Number{
        return - (GameMain.KEY_GAP_H * in_Y + GameMain.KEY_INIT_OFFSET_Y);
    }

    public function UpdatePart_Base(DeltaTime:Number):void{
        //両足が地面についていたら、中央に移動させる
        if(IsGroundL() && IsGroundR()){
            m_Part[PART_FOOT_L].vx =
            m_Part[PART_FOOT_R].vx =
                -m_Part[PART_CENTER].x * 0.5;
        }

        //各パーツを自然落下させる
        //- 掴んだ腕だけは落下させない
        for(var i:int = 0; i < PART_NUM; i++){
            switch(i){
            case PART_HAND_L:
                if(m_HangFlag_L){continue;}//掴んでる手は落下しない
                break;
            case PART_HAND_R:
                if(m_HangFlag_R){continue;}//掴んでる手は落下しない
                break;
            }

            FallPart(m_Part[i], DeltaTime);
        }

        //何かを掴もうとしてる腕はそちらに移動させる
        //- 細かい距離の補正はUpdatePart_Arm_Bodyの方で行う
        {
            const ReachRatio:Number = 0.2;
            const KeepRatio:Number = 0.1;

            //L
            if(!m_HangFlag_L){
                //何も掴んでなくて
                if(0 <= m_HangIndexX_L){
                    //何かを掴もうとしてる
                    //→そちらに腕を伸ばす
                    MovePart(m_Part[PART_HAND_L], DeltaTime, GetTrgPointX(m_HangIndexX_L), GetTrgPointY(m_HangIndexY_L), ReachRatio);
                    CheckHang(m_Part[PART_HAND_L], GetTrgPointX(m_HangIndexX_L), GetTrgPointY(m_HangIndexY_L));
                }else{
                    //何も掴もうとしてない
                    //→横に伸ばすのをデフォルトとする
                    MovePart(m_Part[PART_HAND_L], DeltaTime, m_Part[PART_HAND_L].x - ARM_LEN, m_Part[PART_HAND_L].y, KeepRatio);
                }
            }else{
                //何かを掴んでいる
                //→体を手の斜め下になるようにする
                MovePart(m_Part[PART_SHOULDER_L], DeltaTime, m_Part[PART_HAND_L].x + ARM_LEN/SQRT_2, m_Part[PART_HAND_L].y + ARM_LEN/SQRT_2, KeepRatio);
            }

            //R
            if(!m_HangFlag_R){
                //
                if(0 <= m_HangIndexX_R){
                    //
                    //
                    MovePart(m_Part[PART_HAND_R], DeltaTime, GetTrgPointX(m_HangIndexX_R), GetTrgPointY(m_HangIndexY_R), ReachRatio);
                    CheckHang(m_Part[PART_HAND_R], GetTrgPointX(m_HangIndexX_R), GetTrgPointY(m_HangIndexY_R));
                }else{
                    //
                    //
                    MovePart(m_Part[PART_HAND_R], DeltaTime, m_Part[PART_HAND_R].x + ARM_LEN, m_Part[PART_HAND_R].y, KeepRatio);
                }
            }else{
                //
                //
                MovePart(m_Part[PART_SHOULDER_R], DeltaTime, m_Part[PART_HAND_R].x - ARM_LEN/SQRT_2, m_Part[PART_HAND_R].y + ARM_LEN/SQRT_2, KeepRatio);
            }
        }

        //基本的な姿勢制御力
        {
            var LerpRatio:Number;

            var TrgPointX:Number;
            var TrgPointY:Number;

            //肩が水平になるようにする
            {
                LerpRatio = 0.2;

                TrgPointY = (m_Part[PART_SHOULDER_L].y + m_Part[PART_SHOULDER_R].y)/2;
                m_Part[PART_SHOULDER_L].y = Lerp(m_Part[PART_SHOULDER_L].y, TrgPointY, LerpRatio);
                m_Part[PART_SHOULDER_R].y = Lerp(m_Part[PART_SHOULDER_R].y, TrgPointY, LerpRatio);
/*
                //腰も
                TrgPointY = (m_Part[PART_HIP_L].y + m_Part[PART_HIP_R].y)/2;
                m_Part[PART_HIP_L].y = Lerp(m_Part[PART_HIP_L].y, TrgPointY, LerpRatio);
                m_Part[PART_HIP_R].y = Lerp(m_Part[PART_HIP_R].y, TrgPointY, LerpRatio);
//*/
//*
                //縦補正
                TrgPointX = (m_Part[PART_SHOULDER_L].x + m_Part[PART_HIP_L].x)/2;
                m_Part[PART_SHOULDER_L].x = Lerp(m_Part[PART_SHOULDER_L].x, TrgPointX, LerpRatio);
                m_Part[PART_HIP_L].x = Lerp(m_Part[PART_HIP_L].x, TrgPointX, LerpRatio);
                TrgPointX = (m_Part[PART_SHOULDER_R].x + m_Part[PART_HIP_R].x)/2;
                m_Part[PART_SHOULDER_R].x = Lerp(m_Part[PART_SHOULDER_R].x, TrgPointX, LerpRatio);
                m_Part[PART_HIP_R].x = Lerp(m_Part[PART_HIP_R].x, TrgPointX, LerpRatio);
//*/
            }
/*
            //足が垂直になるようにする
            {
                LerpRatio = 0.08;

                m_Part[PART_FOOT_L].x = Lerp(m_Part[PART_FOOT_L].x, m_Part[PART_HIP_L].x, LerpRatio);
                m_Part[PART_FOOT_R].x = Lerp(m_Part[PART_FOOT_R].x, m_Part[PART_HIP_R].x, LerpRatio);
            }
//*/
        }
    }

    public function UpdatePart_Arm_Body(in_FixPart:Node, in_DynPart:Node, DeltaTime:Number):void{
        //FixPartは固定し、距離がARM_LENになるようにDynPartの方を動かす
        //- 距離が０の時を考慮していないが

        var GapX:Number = in_DynPart.x - in_FixPart.x;
        var GapY:Number = in_DynPart.y - in_FixPart.y;

        var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

        in_DynPart.x = in_FixPart.x + GapX * ARM_LEN/Distance;
        in_DynPart.y = in_FixPart.y + GapY * ARM_LEN/Distance;
    }

    public function CheckHang(in_Part:Node, in_TrgPointX:Number, in_TrgPointY:Number):void{
        var GapX:Number = in_TrgPointX - in_Part.x;
        var GapY:Number = in_TrgPointY - in_Part.y;

        var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

        //腕の速度やDeltaTimeを考慮した方が良いが、一定距離で掴んでしまう
        if(Distance < 20){
            in_Part.x = in_TrgPointX;
            in_Part.y = in_TrgPointY;

            if(in_Part == m_Part[PART_HAND_L]){
                m_HangFlag_L = true;
            }
            if(in_Part == m_Part[PART_HAND_R]){
                m_HangFlag_R = true;
            }
        }
    }

    public function UpdatePart_Body(DeltaTime:Number):void{
//*
        //まずは現在のパーツの位置の重心を中心とする
        {
            m_Part[PART_CENTER].x = (m_Part[PART_SHOULDER_L].x + m_Part[PART_SHOULDER_R].x + m_Part[PART_HIP_L].x + m_Part[PART_HIP_R].x)/4;
            m_Part[PART_CENTER].y = (m_Part[PART_SHOULDER_L].y + m_Part[PART_SHOULDER_R].y + m_Part[PART_HIP_L].y + m_Part[PART_HIP_R].y)/4;
        }

        //肩の中心-腰の中心を結ぶ線を縦線とし、それぞれの想定位置を決定
        {
            var CenterX_Shoulder:Number = (m_Part[PART_SHOULDER_L].x + m_Part[PART_SHOULDER_R].x) / 2;
            var CenterY_Shoulder:Number = (m_Part[PART_SHOULDER_L].y + m_Part[PART_SHOULDER_R].y) / 2;
            var CenterX_Hip:Number = (m_Part[PART_HIP_L].x + m_Part[PART_HIP_R].x) / 2;
            var CenterY_Hip:Number = (m_Part[PART_HIP_L].y + m_Part[PART_HIP_R].y) / 2;

            var GapX:Number = CenterX_Shoulder - CenterX_Hip;
            var GapY:Number = CenterY_Shoulder - CenterY_Hip;

            var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            var UpX:Number = GapX/Distance;
            var UpY:Number = GapY/Distance;

            var RightX:Number = -UpY;
            var RightY:Number =  UpX;

            m_Part[PART_SHOULDER_L].x    = (m_Part[PART_CENTER].x) + ( UpX * SHOULDER_GAP*SQRT_3/2) + (-RightX * SHOULDER_GAP/2);
            m_Part[PART_SHOULDER_L].y    = (m_Part[PART_CENTER].y) + ( UpY * SHOULDER_GAP*SQRT_3/2) + (-RightY * SHOULDER_GAP/2);
            m_Part[PART_SHOULDER_R].x    = (m_Part[PART_CENTER].x) + ( UpX * SHOULDER_GAP*SQRT_3/2) + ( RightX * SHOULDER_GAP/2);
            m_Part[PART_SHOULDER_R].y    = (m_Part[PART_CENTER].y) + ( UpY * SHOULDER_GAP*SQRT_3/2) + ( RightY * SHOULDER_GAP/2);
            m_Part[PART_HIP_L].x        = (m_Part[PART_CENTER].x) + (-UpX * SHOULDER_GAP*SQRT_3/2) + (-RightX * SHOULDER_GAP/2);
            m_Part[PART_HIP_L].y        = (m_Part[PART_CENTER].y) + (-UpY * SHOULDER_GAP*SQRT_3/2) + (-RightY * SHOULDER_GAP/2);
            m_Part[PART_HIP_R].x        = (m_Part[PART_CENTER].x) + (-UpX * SHOULDER_GAP*SQRT_3/2) + ( RightX * SHOULDER_GAP/2);
            m_Part[PART_HIP_R].y        = (m_Part[PART_CENTER].y) + (-UpY * SHOULDER_GAP*SQRT_3/2) + ( RightY * SHOULDER_GAP/2);
        }
//*/
    }

    public function UpdatePart_Leg_Body(in_FixPart:Node, in_DynPart:Node, DeltaTime:Number):void{
        //足が地面についていれば体の方を動かす
        //- そうでなければ足の方を動かす

        //足が垂直になるようにする
        var LerpRatio:Number = 0.9;
        in_DynPart.x = Lerp(in_DynPart.x, in_FixPart.x, LerpRatio);

        var GapX:Number = in_DynPart.x - in_FixPart.x;
        var GapY:Number = in_DynPart.y - in_FixPart.y;

        var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

        in_DynPart.x = in_FixPart.x + GapX * LEG_LEN/Distance;
        in_DynPart.y = in_FixPart.y + GapY * LEG_LEN/Distance;
    }

    public function IsGround():Boolean{
        return (IsGroundL() || IsGroundR());
    }
    public function IsGroundL():Boolean{
        return (m_Part[PART_FOOT_L].y >= 0);
    }
    public function IsGroundR():Boolean{
        return (m_Part[PART_FOOT_R].y >= 0);
    }

    public function TryToHang(in_X:int, in_Y:int):void{
//*
        var TrgPointX:Number = GameMain.KEY_GAP_W * (in_X-2);
        var TrgPointY:Number = - (GameMain.KEY_GAP_H * in_Y + GameMain.KEY_INIT_OFFSET_Y);

        var GapX:Number;
        var GapY:Number;

        //すでに掴んでたら掴まない
        if(m_HangFlag_L && m_HangIndexX_L == in_X && m_HangIndexY_L == in_Y){
            return;
        }
        if(m_HangFlag_R && m_HangIndexX_R == in_X && m_HangIndexY_R == in_Y){
            return;
        }

        //両手が塞がってたら掴まない
        if(m_HangFlag_L && m_HangFlag_R){
            return;
        }

        //空いてる方の手で掴もうとする

        //L
        var Distance_L:Number = 999999999999;//空いてない場合のために大きな値を入れておく
        {
            if(! m_HangFlag_L){
                GapX = m_Part[PART_HAND_L].x - TrgPointX;
                GapY = m_Part[PART_HAND_L].y - TrgPointY;

                Distance_L = Math.sqrt(GapX*GapX + GapY*GapY);
            }
        }

        //R
        var Distance_R:Number = 999999999999;//空いてない場合のために大きな値を入れておく
        {
            if(! m_HangFlag_R){
                GapX = m_Part[PART_HAND_R].x - TrgPointX;
                GapY = m_Part[PART_HAND_R].y - TrgPointY;

                Distance_R = Math.sqrt(GapX*GapX + GapY*GapY);
            }
        }

        if(Distance_L < Distance_R){
            //左手で掴もうとする
            m_HangIndexX_L = in_X;
            m_HangIndexY_L = in_Y;
        }else{
            //右手で掴もうとする
            m_HangIndexX_R = in_X;
            m_HangIndexY_R = in_Y;
        }

        //地面に居る状態であれば跳ねる
        if(IsGround() && (m_HangFlag_L != m_HangFlag_R)){
            Hop(0, -HOP_VY);
        }
/*/
        var TrgPointX:Number = GameMain.KEY_GAP_W * (in_X-2);
        var TrgPointY:Number = - (GameMain.KEY_GAP_H * in_Y + GameMain.KEY_INIT_OFFSET_Y);

        var Distance:Number;
        var GapX:Number;
        var GapY:Number;

        //すでに掴んでたら掴まない
        if(m_HangFlag_L && m_HangIndexX_L == in_X && m_HangIndexY_L == in_Y){
            return;
        }
        if(m_HangFlag_R && m_HangIndexX_R == in_X && m_HangIndexY_R == in_Y){
            return;
        }

        //掴んでない手で掴めるかチェック
        if(! m_HangFlag_L){
            //Distance
            {
                GapX = m_Part[PART_HAND_L].x - TrgPointX;
                GapY = m_Part[PART_HAND_L].y - TrgPointY;

                Distance = Math.sqrt(GapX*GapX + GapY*GapY);
            }

            if(Distance < 2*ARM_LEN + SHOULDER_GAP){
                //掴み成功

                //Pos
                m_Part[PART_HAND_L].x = TrgPointX;
                m_Part[PART_HAND_L].y = TrgPointY;

                //Vel
                m_Part[PART_HAND_L].vx = 0;
                m_Part[PART_HAND_L].vy = 0;

                //Flag
                m_HangFlag_L = true;
                m_HangIndexX_L = in_X;
                m_HangIndexY_L = in_Y;

                //
                return;
            }
        }

        if(! m_HangFlag_R){
            //Distance
            {
                GapX = m_Part[PART_HAND_R].x - TrgPointX;
                GapY = m_Part[PART_HAND_R].y - TrgPointY;

                Distance = Math.sqrt(GapX*GapX + GapY*GapY);
            }

            if(Distance < 2*ARM_LEN + SHOULDER_GAP){
                //掴み成功

                //Pos
                m_Part[PART_HAND_R].x = TrgPointX;
                m_Part[PART_HAND_R].y = TrgPointY;

                //Vel
                m_Part[PART_HAND_R].vx = 0;
                m_Part[PART_HAND_R].vy = 0;

                //Flag
                m_HangFlag_R = true;
                m_HangIndexX_R = in_X;
                m_HangIndexY_R = in_Y;

                //
                return;
            }
        }
//*/
    }
    public function TryToRelease(in_X:int, in_Y:int):void{
        if(m_HangIndexX_L == in_X && m_HangIndexY_L == in_Y){
            if(m_HangFlag_L && m_HangFlag_R){
                Hop(-HOP_VY/SQRT_2, -HOP_VY/SQRT_2);
            }
            m_HangFlag_L = false;
            m_HangIndexX_L = -1;
            m_HangIndexY_L = -1;
        }
        if(m_HangIndexX_R == in_X && m_HangIndexY_R == in_Y){
            if(m_HangFlag_L && m_HangFlag_R){
                Hop( HOP_VY/SQRT_2, -HOP_VY/SQRT_2);
            }
            m_HangFlag_R = false;
            m_HangIndexX_R = -1;
            m_HangIndexY_R = -1;
        }
    }

    public function Hop(in_VX:Number, in_VY:Number):void{
        m_Part[PART_SHOULDER_L].vy =
        m_Part[PART_SHOULDER_R].vy =
        m_Part[PART_HIP_L].vy =
        m_Part[PART_HIP_R].vy =
        m_Part[PART_FOOT_L].vy =
        m_Part[PART_FOOT_R].vy =
            in_VY;

        m_Part[PART_SHOULDER_L].vx =
        m_Part[PART_SHOULDER_R].vx =
        m_Part[PART_HIP_L].vx =
        m_Part[PART_HIP_R].vx =
        m_Part[PART_FOOT_L].vx =
        m_Part[PART_FOOT_R].vx =
            in_VX;

        //足を地面から離さないと地面に吸着してしまう
        m_Part[PART_FOOT_L].y -= 1;
        m_Part[PART_FOOT_R].y -= 1;
    }

    public function GetCenterY():Number{
        //ひとまず肩の中央を中心としてみる
        return (m_Part[PART_SHOULDER_L].y + m_Part[PART_SHOULDER_R].y)/2;
    }

    //Util
    static public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
        return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
    }
}
