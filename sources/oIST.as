/*
　「Wall×Walk」
　・床と壁と天井を歩くアクションゲーム

　概要
　・床や天井などを歩いたりジャンプしたりして、
　  ゴールまで辿り着けばクリアとなるゲームです

　操作方法（画面を２回くらいクリックしないと操作できないかも）
　・十字キー
　　・移動
　・SPACE（半角で）
　　・ジャンプ
　・Rキー（半角で）
　　・リスタート

　ステージの作り方
　・ForkしてMAPの中身をいじればステージが自作できます
　・MAPの中身は以下のものに対応しています
　　・O：空間
　　　・何もないスペースです
　　・W：壁
　　　・プレイヤーが歩くところです
　　・X：針ブロック
　　　・上下左右に針があるブロックです
　　・P：プレイヤー位置
　　　・プレイヤーの初期位置を設定します
　　・G：ゴール位置
　　　・ゴールの位置を設定します

　注意事項
　・MAPのサイズは100x100あたりが限界です
　　・それ以上はBitmapDataのサイズ的に限界です
　・移動処理などでBitmapDataやFilterを必要以上に多用しています
　　・スタディを兼ねて色々と使っているので、処理として最適というわけではないです

　その他
　・ドット絵をwonderflにアップロードすると圧縮されて汚くなるので、できればどこか別のところに上げて参照したいところ
　　→コメント欄を参考にしたりして、たぶん解決
　　　・しかし、家のchromeでだけまだ表示が潰れてるので、あとでもう少し調べる
　　　　→単に家のブラウザが１段階縮小表示されていただけだった。
*/

package{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.text.*;
    import flash.filters.*;
    import flash.ui.*;
    import flash.system.*;

    public class GameMain extends Sprite{
        //==File==
//*
        static public const BITMAP_URL:String = "http://assets.wonderfl.net/images/related_images/b/b9/b932/b9323a1f23b23d93a010a4c901aa91d9630704cdm";
/*/
        [Embed(source='Graphics.png')]
         private static var Bitmap_Graphic: Class;
//*/

        //==Const==

        //マップ要素
        static public var MapIter:int = 0;
        static public const O:uint    = MapIter++;
        static public const W:uint    = MapIter++;
        static public const P:uint    = MapIter++;
        static public const G:uint    = MapIter++;
        static public const X:uint    = MapIter++;

        //マップ
        static public const MAP:Array = [
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
            [W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, O, O, O, O, O, O, O, W, W, X, X, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, O, O, O, O, O, O, O, W, W, W, W, W, W, O, O, W, W, O, O, O, W, W, O, O, O, W, W, O, O, O, W, W, O, O, W],
            [W, O, O, O, O, O, O, O, O, W, W, W, W, W, W, O, O, W, W, O, O, O, W, W, O, O, O, W, W, O, O, O, W, W, O, O, W],
            [W, O, O, O, O, O, O, O, O, W, W, W, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, O, O, O, O, O, O, O, W, W, W, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, O, O, O, O, O, W, W, W, W, W, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
            [W, O, P, O, O, O, O, W, W, W, W, W, W, W, W, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, X, X],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, O],
            [W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, O],
            [W, W, W, W, W, W, W, W, X, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W, W, O, O, O],
            [W, W, W, W, W, W, W, W, X, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W, W, O, O, O],
            [W, X, X, X, X, X, X, X, X, O, O, O, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, O, O, W, W, O, O, O],
            [W, O, O, O, O, O, O, O, O, O, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, X, O, O, W, W, O, O, O],
            [W, O, O, O, O, O, O, O, O, O, O, O, W, W, W, W, W, W, W, W, W, W, W, X, W, W, W, W, W, X, O, O, W, W, O, O, O],
            [W, O, O, O, W, O, W, O, X, O, W, O, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W, W, O, O, O],
            [W, O, O, O, O, O, O, O, O, O, O, O, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W, W, O, O, O],
            [W, O, O, O, O, O, O, O, O, O, O, O, W, W, W, O, O, W, W, W, X, W, W, W, W, W, X, W, W, W, W, W, W, W, O, O, O],
            [W, O, G, O, X, O, W, O, W, O, W, O, W, W, W, O, O, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, O, O, O],
            [W, W, W, W, O, O, O, O, O, O, O, O, W, W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O],
        ];

        //ステージのサイズ（初期化時に計算する）
        static public var BitmapW:int = 100;
        static public var BitmapH:int = 100;

        //モード
        static public var ModeIter:int = 0;
        static public const MODE_MAIN:int    = ModeIter++;
        static public const MODE_GOAL:int    = ModeIter++;
        static public const MODE_GAME_OVER:int    = ModeIter++;


        //==Var==

        //ルート
        public var m_Layer_Root:Sprite = new Sprite();

        //背景＆パス
        public var m_BitmapData_View:BitmapData;
        public var m_BitmapData_Path:BitmapData;

        //プレイヤー
        public var m_Player:Player;

        //ゴール
        public var m_Goal:Goal;

        //テキスト
        public var m_Text:TextField = new TextField();


        //モード
        public var m_Mode:int = MODE_MAIN;


        //==Function==

        //Static Global Access
        static private var m_Instance:GameMain;
        static public function Instance():GameMain{return m_Instance;}

        //#Init
        public function GameMain(){
            m_Instance = this;
//*
            //wonderfl用：Bitmapを外部からロードする場合

            //Load
            addEventListener(
                Event.ADDED_TO_STAGE,//ステージに追加されたら
                function(e:Event):void{
                    var loader:Loader = new Loader();
                    loader.load(new URLRequest(BITMAP_URL), new LoaderContext(true));//画像のロードを開始して
                    loader.contentLoaderInfo.addEventListener(
                        Event.COMPLETE,//ロードが完了したら
                        function(e:Event):void{
                            ImageManager.Init(loader.content);//それを保持した後

                            Init();//初期化に入る
                        }
                    );
                }
            );

            //キャプチャのタイミング指定
            Wonderfl.capture_delay(30);//30秒後に実行
/*/
            //ローカル用：Bitmapを事前ロードできる場合

            //ブロック画像のセット（＆その他初期化）
            ImageManager.Init(new Bitmap_Graphic());

            //本体の初期化
            addEventListener(Event.ADDED_TO_STAGE, Init);
//*/
        }

        //#Init
        public function Init(e:Event=null):void{
            var NumX:int = MAP[0].length;
            var NumY:int = MAP.length;

            //Param
            {
                BitmapW = NumX * 32;
                BitmapH = NumY * 32;
            }

            //レイヤー
            {
                addChild(m_Layer_Root);
            }

            //m_BitmapData_View
            //m_BitmapData_Path
            {
                m_BitmapData_View = new BitmapData(BitmapW, BitmapH, true, 0x00000000);
                m_BitmapData_Path = new BitmapData(BitmapW, BitmapH, true, 0x00000000);

                ImageManager.DrawBG(MAP, m_BitmapData_View, m_BitmapData_Path);

                m_Layer_Root.addChild(new Bitmap(m_BitmapData_View));
/*
                //Debug
                {
                    var bmd:BitmapData = new BitmapData(BitmapW, BitmapH, true, 0x00000000);
                    {
                        var palette:Array = new Array(256);

                        for(var i:int = 0; i < 256; i++){
                            palette[i] = 0x00000000;
                        }
                        palette[Player.PATH_U] = 0xFF008800;
                        palette[Player.PATH_D] = 0xFF008800;
                        palette[Player.PATH_L] = 0xFF008800;
                        palette[Player.PATH_R] = 0xFF008800;
                        palette[Player.PATH_UorL] = 0xFF00FF00;
                        palette[Player.PATH_UorR] = 0xFF00FF00;
                        palette[Player.PATH_DorL] = 0xFFFF0000;
                        palette[Player.PATH_DorR] = 0xFF00FF00;
                        palette[Player.PATH_UandL] = 0xFF00FF00;
                        palette[Player.PATH_UandR] = 0xFF00FF00;
                        palette[Player.PATH_DandL] = 0xFFFF0000;
                        palette[Player.PATH_DandR] = 0xFF00FF00;
                        palette[Player.PATH_DAMAGE] = 0xFFFF0000;

                        const POS_ZERO:Point = new Point(0,0);
                        bmd.paletteMap(m_BitmapData_Path, m_BitmapData_Path.rect, POS_ZERO, null, null, palette);
                        //bmd.paletteMap(ImageManager.m_BitmapData_Path, ImageManager.m_BitmapData_Path.rect, POS_ZERO, null, null, palette);
                    }

                    m_Layer_Root.addChild(new Bitmap(bmd));
                }
//*/
            }

            //MAPからパラメータ取得
            var PlayerX:int = 0;
            var PlayerY:int = 0;
            var GoalX:int = 0;
            var GoalY:int = 0;
            {
                for(var y:int = 0; y < NumY; y++){
                    for(var x:int = 0; x < NumX; x++){
                        switch(MAP[y][x]){
                        case P:
                            PlayerX = (x + 0.5) * 32;
                            PlayerY = (y + 0.5) * 32;
                            break;
                        case G:
                            GoalX = (x + 0.5) * 32;
                            GoalY = (y + 0.5) * 32;
                            break;
                        }
                    }
                }
            }

            //Player
            {
                m_Player = new Player(PlayerX, PlayerY);
                m_Layer_Root.addChild(m_Player);
            }

            //Goal
            {
                m_Goal = new Goal(GoalX, GoalY);
                m_Layer_Root.addChild(m_Goal);
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

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }
        }

        //#Reset
        public function Reset():void{
            //Player
            {
                m_Player.Reset();
            }

            //Mode
            {
                m_Mode = MODE_MAIN;
            }

            //Text
            {
                m_Text.text = '';
            }
        }

        //#Update
        public function Update(e:Event=null):void{
            var DeltaTime:Number = 1/24.0;

            //Player
            {
                m_Player.Update();
            }

            //Camera
            {
                Update_Camera();
            }

            //Goal
            {
                m_Goal.Update();
            }
        }

        //Update :Camera
        public function Update_Camera():void{
            var CAMERA_W:int = stage.stageWidth;
            var CAMERA_H:int = stage.stageHeight;

            var trgX:Number = m_Player.x - CAMERA_W/2.0;
            var trgY:Number = m_Player.y - CAMERA_H/2.0;

            var MinX:Number = 0.0;
            var MaxX:Number = BitmapW - CAMERA_W;
            var MinY:Number = 0.0;
            var MaxY:Number = BitmapH - CAMERA_H;

            if(trgX > MaxX){
                trgX = MaxX;
            }
            if(trgY > MaxY){
                trgY = MaxY;
            }
            if(trgX < MinX){
                trgX = MinX;
            }
            if(trgY < MinY){
                trgY = MinY;
            }

            m_Layer_Root.x = -trgX;
            m_Layer_Root.y = -trgY;
        }

        //#Path
        public function GetPathIndex(in_X:int, in_Y:int):int{
            return m_BitmapData_Path.getPixel(in_X, in_Y);
        }


        //#Goal
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

        //#Game Over : Damage
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

        //#Game Over : Fall
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
    }
}


import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import flash.filters.*;
import flash.ui.*;
import flash.system.*;


//#Image
class ImageManager
{
    //==BG==

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


    //#Path
    static public var m_PathIndexIter:int = 0;

    static public const PATH_INDEX_NONE:int                 = m_PathIndexIter++;

    static public const PATH_INDEX_WALL_X:int            = m_PathIndexIter++;
    static public const PATH_INDEX_WALL_Y:int            = m_PathIndexIter++;
    static public const PATH_INDEX_WALL_XorY:int        = m_PathIndexIter++;
    static public const PATH_INDEX_WALL_XandY:int        = m_PathIndexIter++;

    static public const PATH_INDEX_DAMAGE_X:int            = m_PathIndexIter++;
    static public const PATH_INDEX_DAMAGE_Y:int            = m_PathIndexIter++;
    static public const PATH_INDEX_DAMAGE_XorY:int        = m_PathIndexIter++;
    static public const PATH_INDEX_DAMAGE_XandY:int        = m_PathIndexIter++;

    static public const PATH_INDEX_WALL_X_DAMAGE_Y:int    = m_PathIndexIter++;
    static public const PATH_INDEX_WALL_Y_DAMAGE_X:int    = m_PathIndexIter++;

    static public const PATH_INDEX_NUM:int                 = m_PathIndexIter;

    //#Offset：地形からどれだけ浮かせるか
    static public const PATH_OFFSET:int = 12;


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
    static public var m_BitmapData_Path:BitmapData;

    //#Mapping
    static public var GRAPHIC_INDEX_TO_POS:Array;
    static public var PATH_INDEX_TO_POS:Array;


    //#Palette
    static public var m_Palette_ForView:Array;
    static public var m_Palette_ForPath:Array;


    //==Player==

    //#Bitmap
    static public var m_PlayerBitmap:Array = new Array(3);


    //==Utility==

    static public const POS_ZERO:Point = new Point(0,0);


    //#Init
    static public function Init(in_Graphic:DisplayObject):void{
        var x:int, y:int, i:int;

        //m_BitmapData_View
        {
            m_BitmapData_View = new BitmapData(256, 256, false, 0x000000);
            m_BitmapData_View.draw(in_Graphic);
        }

        //m_BitmapData_Path
        {
            var rect:Rectangle = new Rectangle(0,0,1,1);

            m_BitmapData_Path = new BitmapData(256, 256, false, 0x000000);

            //U
            rect.x = PATH_OFFSET; rect.y = PATH_OFFSET; rect.width = 3*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_U);
            //D
            rect.x = PATH_OFFSET; rect.y = 3*16-1-PATH_OFFSET; rect.width = 3*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_D);
            //L
            rect.x = PATH_OFFSET; rect.y = PATH_OFFSET; rect.width = 1; rect.height = 3*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_L);
            //R
            rect.x = 3*16-1-PATH_OFFSET; rect.y = PATH_OFFSET; rect.width = 1; rect.height = 3*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_R);

            //UorL
            m_BitmapData_Path.setPixel(PATH_OFFSET,            PATH_OFFSET,        Player.PATH_UorL);
            //UorR
            m_BitmapData_Path.setPixel(3*16-1-PATH_OFFSET,    PATH_OFFSET,        Player.PATH_UorR);
            //DorL
            m_BitmapData_Path.setPixel(PATH_OFFSET,            3*16-1-PATH_OFFSET,    Player.PATH_DorL);
            //DorR
            m_BitmapData_Path.setPixel(3*16-1-PATH_OFFSET,    3*16-1-PATH_OFFSET,    Player.PATH_DorR);

            //UandL
            rect.x = 3*16; rect.y = PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_U);
            rect.x = 3*16+PATH_OFFSET; rect.y = 0; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_L);
            m_BitmapData_Path.setPixel(3*16+PATH_OFFSET,    PATH_OFFSET,        Player.PATH_UandL);
            //UandR
            rect.x = 5*16-1-PATH_OFFSET; rect.y = PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_U);
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 0; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_R);
            m_BitmapData_Path.setPixel(5*16-1-PATH_OFFSET,    PATH_OFFSET,        Player.PATH_UandR);
            //DandL
            rect.x = 3*16; rect.y = 2*16-1-PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_D);
            rect.x = 3*16+PATH_OFFSET; rect.y = 2*16-1-PATH_OFFSET; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_L);
            m_BitmapData_Path.setPixel(3*16+PATH_OFFSET,    2*16-1-PATH_OFFSET,    Player.PATH_DandL);
            //DandR
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 2*16-1-PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_D);
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 2*16-1-PATH_OFFSET; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_R);
            m_BitmapData_Path.setPixel(5*16-1-PATH_OFFSET,    2*16-1-PATH_OFFSET,    Player.PATH_DandR);

            //Damage:U
            rect.x = PATH_OFFSET; rect.y = 3*16+PATH_OFFSET; rect.width = 3*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            //Damage:D
            rect.x = PATH_OFFSET; rect.y = 6*16-1-PATH_OFFSET; rect.width = 3*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            //Damage:L
            rect.x = PATH_OFFSET; rect.y = 3*16+PATH_OFFSET; rect.width = 1; rect.height = 3*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            //Damage:R
            rect.x = 3*16-1-PATH_OFFSET; rect.y = 3*16+PATH_OFFSET; rect.width = 1; rect.height = 3*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);

            //Damage:UandL
            rect.x = 3*16; rect.y = 3*16+PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 3*16+PATH_OFFSET; rect.y = 3*16; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            m_BitmapData_Path.setPixel(3*16+PATH_OFFSET,    PATH_OFFSET,        Player.PATH_UandL);
            //Damage:UandR
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 3*16+PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 3*16; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            m_BitmapData_Path.setPixel(5*16-1-PATH_OFFSET,    PATH_OFFSET,        Player.PATH_UandR);
            //Damage:DandL
            rect.x = 3*16; rect.y = 5*16-1-PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 3*16+PATH_OFFSET; rect.y = 5*16-1-PATH_OFFSET; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            m_BitmapData_Path.setPixel(3*16+PATH_OFFSET,    2*16-1-PATH_OFFSET,    Player.PATH_DandL);
            //Damage:DandR
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 5*16-1-PATH_OFFSET; rect.width = PATH_OFFSET+1; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 5*16-1-PATH_OFFSET; rect.y = 5*16-1-PATH_OFFSET; rect.width = 1; rect.height = PATH_OFFSET+1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            m_BitmapData_Path.setPixel(5*16-1-PATH_OFFSET,    2*16-1-PATH_OFFSET,    Player.PATH_DandR);

            //Damage+Wall
            rect.x = 5*16+PATH_OFFSET; rect.y = 0*16+PATH_OFFSET; rect.width = 1; rect.height = 2*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_L);
            rect.x = 7*16-1-PATH_OFFSET; rect.y = 0*16+PATH_OFFSET; rect.width = 1; rect.height = 2*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_R);
            rect.x = 5*16+PATH_OFFSET; rect.y = 2*16+PATH_OFFSET; rect.width = 2*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_U);
            rect.x = 5*16+PATH_OFFSET; rect.y = 4*16-1-PATH_OFFSET; rect.width = 2*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_D);
            rect.x = 5*16+PATH_OFFSET; rect.y = 0*16+PATH_OFFSET; rect.width = 2*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 5*16+PATH_OFFSET; rect.y = 2*16-1-PATH_OFFSET; rect.width = 2*16-2*PATH_OFFSET; rect.height = 1;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 5*16+PATH_OFFSET; rect.y = 2*16+PATH_OFFSET; rect.width = 1; rect.height = 2*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
            rect.x = 7*16-1-PATH_OFFSET; rect.y = 2*16+PATH_OFFSET; rect.width = 1; rect.height = 2*16-2*PATH_OFFSET;
            m_BitmapData_Path.fillRect(rect, Player.PATH_DAMAGE);
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

        //PATH_INDEX_TO_POS
        {//PATH_INDEX_～からパス用画像の位置へのマッピング
            PATH_INDEX_TO_POS = new Array(PATH_INDEX_NUM);

            //[LU][RU][LD][RD]

            PATH_INDEX_TO_POS[PATH_INDEX_NONE]                = [[1,1], [1,1], [1,1], [1,1]];

            PATH_INDEX_TO_POS[PATH_INDEX_WALL_X]            = [[0,1], [2,1], [0,1], [2,1]];
            PATH_INDEX_TO_POS[PATH_INDEX_WALL_Y]            = [[1,0], [1,0], [1,2], [1,2]];
            PATH_INDEX_TO_POS[PATH_INDEX_WALL_XorY]            = [[0,0], [2,0], [0,2], [2,2]];
            PATH_INDEX_TO_POS[PATH_INDEX_WALL_XandY]        = [[3,0], [4,0], [3,1], [4,1]];

            PATH_INDEX_TO_POS[PATH_INDEX_DAMAGE_X]            = [[0,4], [2,4], [0,4], [2,4]];
            PATH_INDEX_TO_POS[PATH_INDEX_DAMAGE_Y]            = [[1,3], [1,3], [1,5], [1,5]];
            PATH_INDEX_TO_POS[PATH_INDEX_DAMAGE_XorY]        = [[0,3], [2,3], [0,5], [2,5]];
            PATH_INDEX_TO_POS[PATH_INDEX_DAMAGE_XandY]        = [[3,3], [4,3], [3,4], [4,4]];

            PATH_INDEX_TO_POS[PATH_INDEX_WALL_X_DAMAGE_Y]    = [[5,0], [6,0], [5,1], [6,1]];
            PATH_INDEX_TO_POS[PATH_INDEX_WALL_Y_DAMAGE_X]    = [[5,2], [6,2], [5,3], [6,3]];
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

        //m_Palette_ForPath
        {
            m_Palette_ForPath = new Array(256);

            var index_path:int = GRAPHIC_INDEX_BG;
            for(i = 0; i < 256; i++){
                //区切りごとにindexを変更。次の区切りまではその値をセット
                switch(i){
                case 0:
                case 27:
                    index_path = PATH_INDEX_NONE; break;
                case 2:
                    index_path = PATH_INDEX_WALL_XandY; break;
                case 6:
                    index_path = PATH_INDEX_WALL_Y; break;
                case 18:
                    index_path = PATH_INDEX_WALL_X; break;
                case 24:
                    index_path = PATH_INDEX_WALL_XorY; break;
                case 3:
                    index_path = PATH_INDEX_DAMAGE_Y; break;
                case 21:
                    index_path = PATH_INDEX_WALL_X_DAMAGE_Y; break;
                case 9:
                    index_path = PATH_INDEX_DAMAGE_X; break;
                case 15:
                    index_path = PATH_INDEX_WALL_Y_DAMAGE_X; break;
                case 12:
                    index_path = PATH_INDEX_DAMAGE_XorY; break;
                case 1:
                    index_path = PATH_INDEX_DAMAGE_XandY; break;
                }

                m_Palette_ForPath[i] = index_path;
            }
        }

        //m_PlayerBitmap
        {
            var mtx:Matrix = new Matrix();
            //var rect:Rectangle = new Rectangle(0,0, 32,32);
            rect.width = rect.height = 32;

            for(i = 0; i < 3; i++){
                //Init
                m_PlayerBitmap[i] = new Bitmap(new BitmapData(24, 32, true, 0x000000));

                //Pos
                m_PlayerBitmap[i].x = -24/2;
                m_PlayerBitmap[i].y = -29 + PATH_OFFSET;

                //Draw Graphic
                mtx.tx = -i*24;
                mtx.ty = -6*16;
                m_PlayerBitmap[i].bitmapData.draw(m_BitmapData_View, mtx);

                //Set Alpha
                rect.x = i*24;
                rect.y = 8*16;
                m_PlayerBitmap[i].bitmapData.copyChannel(m_BitmapData_View, rect, POS_ZERO, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
            }
        }
    }

    //#Draw : BG
    static public function DrawBG(in_Map:Array, out_BitmapData_View:BitmapData, out_BitmapData_Path:BitmapData):void
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
                ),
                new ConvolutionFilter(3,3,
                    [//RU
                        0,  3,  1,
                        0, 27,  9,
                        0,  0,  0,
                    ]
                ),
                new ConvolutionFilter(3,3,
                    [//LD
                        0,  0,  0,
                        9, 27,  0,
                        1,  3,  0,
                    ]
                ),
                new ConvolutionFilter(3,3,
                    [//RD
                        0,  0,  0,
                        0, 27,  9,
                        0,  3,  1,
                    ]
                ),
            ];

            for(i = 0; i < 4; i++){
                //Init
                BitmapData_Quater[i] = new BitmapData(NumX, NumY, false, 0x000000);

                //Apply Filter
                BitmapData_Quater[i].applyFilter(BitmapData_Base, BitmapData_Base.rect, POS_ZERO, filter[i]);
            }
        }

        //Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD => ForView & ForPath
        //Uniqueな値から、対応するIndexへと変換する
        var BitmapData_ForView:Array = new Array(4);
        var BitmapData_ForPath:Array = new Array(4);
        {
            for(i = 0; i < 4; i++){
                //Init
                BitmapData_ForView[i] = new BitmapData(NumX, NumY, false, 0x000000);
                BitmapData_ForPath[i] = new BitmapData(NumX, NumY, false, 0x000000);

                //Apply Palette
                BitmapData_ForView[i].paletteMap(BitmapData_Quater[i], BitmapData_Quater[i].rect, POS_ZERO, null, null, m_Palette_ForView);
                BitmapData_ForPath[i].paletteMap(BitmapData_Quater[i], BitmapData_Quater[i].rect, POS_ZERO, null, null, m_Palette_ForPath);
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

                        //#view
                        mtx.tx = rect.x - 16 * GRAPHIC_INDEX_TO_POS[BitmapData_ForView[i].getPixel(x, y)][i][POS_X];
                        mtx.ty = rect.y - 16 * GRAPHIC_INDEX_TO_POS[BitmapData_ForView[i].getPixel(x, y)][i][POS_Y];
                        out_BitmapData_View.draw(m_BitmapData_View, mtx, null, null, rect);

                        //#Path
                        mtx.tx = rect.x - 16 * PATH_INDEX_TO_POS[BitmapData_ForPath[i].getPixel(x, y)][i][POS_X];
                        mtx.ty = rect.y - 16 * PATH_INDEX_TO_POS[BitmapData_ForPath[i].getPixel(x, y)][i][POS_Y];
                        out_BitmapData_Path.draw(m_BitmapData_Path, mtx, null, null, rect);
                    }
                }
            }
        }
    }

    //Image : Player
    static public function GetPlayerGraphic(in_Index:int):Bitmap{
        const Index2Index:Array = [0, 1, 2, 1];
        return m_PlayerBitmap[Index2Index[in_Index]];
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


//#Player
class Player extends Sprite
{
    //==Const==

    //パス
    static public var PathIter:int = 0;
    static public const PATH_NONE:int    = PathIter++;
    static public const PATH_U:int        = PathIter++;
    static public const PATH_D:int        = PathIter++;
    static public const PATH_L:int        = PathIter++;
    static public const PATH_R:int        = PathIter++;
    static public const PATH_UorL:int    = PathIter++;
    static public const PATH_UorR:int    = PathIter++;
    static public const PATH_DorL:int    = PathIter++;
    static public const PATH_DorR:int    = PathIter++;
    static public const PATH_UandL:int    = PathIter++;
    static public const PATH_UandR:int    = PathIter++;
    static public const PATH_DandL:int    = PathIter++;
    static public const PATH_DandR:int    = PathIter++;
    static public const PATH_DAMAGE:int    = PathIter++;
    static public const PATH_NUM:int    = PathIter;

    //軸
    static public const AXIS_X:int = 0;
    static public const AXIS_Y:int = 1;
    static public const AXIS_NUM:int = 2;

    //方向
    static public const DIR_U:int = 0;
    static public const DIR_D:int = 1;
    static public const DIR_L:int = 2;
    static public const DIR_R:int = 3;
    static public const DIR_NUM:int = 4;

    //移動力
    static public const MOVE_POW:Number = 150.0;

    //地上での減速率
    static public const BREAK_RATIO:Number = 0.98;

    //ジャンプ速度
    static public const JUMP_VEL:Number = 120.0;

    //重力
    static public const GRAVITY:Number = 150.0;

    //入力
    static public var InputIter:int = 0;
    static public const INPUT_U:int        = InputIter++;
    static public const INPUT_D:int        = InputIter++;
    static public const INPUT_L:int        = InputIter++;
    static public const INPUT_R:int        = InputIter++;
    static public const INPUT_JUMP:int    = InputIter++;
    static public const INPUT_RESET:int    = InputIter++;
    static public const INPUT_NUM:int    = InputIter;

    //アニメーション
    static public const ANIM_NUM:int = 4;

    //移動
    static public const MOVE_NONE:uint    = 0x11;
    static public const MOVE_U:uint        = 0x11 - 0x10;
    static public const MOVE_D:uint        = 0x11 + 0x10;
    static public const MOVE_L:uint        = 0x11 - 0x01;
    static public const MOVE_R:uint        = 0x11 + 0x01;
    static public const MOVE_UL:uint    = 0x11 - 0x10 - 0x01;
    static public const MOVE_UR:uint    = 0x11 - 0x10 + 0x01;
    static public const MOVE_DL:uint    = 0x11 + 0x10 - 0x01;
    static public const MOVE_DR:uint    = 0x11 + 0x10 + 0x01;

    //パスによる移動方向の変化（初期化時に作成）
    static public var PALETTE_MOVE:Array = new Array(PATH_NUM);//[PATH_NUM][MOVE_XX] = MOVE_YY

    //Utility
    static public const POS_ZERO:Point = new Point(0,0);


    //==Var==

    //スタート位置（初期化、リセット用）
    public var m_StartPosX:int = 0;
    public var m_StartPosY:int = 0;

    //現在位置（小数点まで保持版）（でもなんか普通のxでも上手くいってる気がする）
    public var m_PosX:Number = 0;
    public var m_PosY:Number = 0;

    //現在速度
    public var m_VelX:Number = 0;
    public var m_VelY:Number = 0;

    //現在加速度
    public var m_AccX:Number = 0;
    public var m_AccY:Number = 0;

    //現在のパス
    public var m_PathIndex:int = PATH_NONE;

    //地面に居るか
    public var m_OnGround:Boolean = false;//最初は空中からスタートすると仮定

    //現在の姿勢（足→頭の方向）
    public var m_HeadDir:int = DIR_U;

    //入力
    public var m_Input:Array = new Array(INPUT_NUM);
    public var m_Input_Old:Array = new Array(INPUT_NUM);
    public var m_Input_Edge:Array = new Array(INPUT_NUM);

    //現在表示中の画像のIndex
    public var m_AnimIndex:Number = 0;

    //表示に使う画像
    public var m_Graphic:Array;

    //死んでいるか
    public var m_IsDead:Boolean = false;

    //移動処理用のもろもろ
    public var m_MoveList:BitmapData = new BitmapData(256, 1, false, MOVE_NONE);//１ドットずつ移動する処理の配列相当（移動方向の変換処理のためBitmapDataで）
    public var m_Util:BitmapData = new BitmapData(16, 1, false, MOVE_NONE);//汎用


    //==Function==

    //Init
    public function Player(in_X:int, in_Y:int){
        //Param
        {
            m_StartPosX = in_X;
            m_StartPosY = in_Y;

            InitPaletteForMove();
        }

        //Init Later
        addEventListener(
            Event.ADDED_TO_STAGE,//stageに触れるようになるまで遅延
            Init
        );
    }

    //Init
    public function Init(e:Event=null):void{
        //Init Once Only
        {
            removeEventListener(Event.ADDED_TO_STAGE, Init);
        }

        //Input
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, SetKeyFlag(true));
            stage.addEventListener(KeyboardEvent.KEY_UP,   SetKeyFlag(false));
        }

        //Graphic
        {
            m_Graphic = new Array(ANIM_NUM);
            for(var i:int = 0; i < ANIM_NUM; i++){
                m_Graphic[i] = ImageManager.GetPlayerGraphic(i);
            }
            addChild(m_Graphic[0]);
        }

        //Update
//        {//→本体で一括処理する
//            addEventListener(Event.ENTER_FRAME, Update);
//        }

        //残りはResetと同じ処理
        {
            Reset();
        }
    }

    //Init : Palette
    public function InitPaletteForMove():void{
        //PALETTE_MOVEの初期化
        //現在のパス位置に応じて移動方向を変えるパレットを準備

        //要素を変えないパレットの生成
        const createBasePalette:Function = function():Array{
            var arr:Array = new Array(256);
            for(var i:int = 0; i < 256; i++){
                arr[i] = i;
            }
            return arr;
        };

        //PATH_NONE：空中：移動を変更する必要がないのでそのままで
        PALETTE_MOVE[PATH_NONE] = createBasePalette();

        //PATH_U：天井走り中：上下方向の移動は無効化
        PALETTE_MOVE[PATH_U] = createBasePalette();
        PALETTE_MOVE[PATH_U][MOVE_U] = MOVE_NONE;
        PALETTE_MOVE[PATH_U][MOVE_D] = MOVE_NONE;
        PALETTE_MOVE[PATH_U][MOVE_UL] = MOVE_L;
        PALETTE_MOVE[PATH_U][MOVE_UR] = MOVE_R;
        PALETTE_MOVE[PATH_U][MOVE_DL] = MOVE_L;
        PALETTE_MOVE[PATH_U][MOVE_DR] = MOVE_R;

        //PATH_D：地面走り中：PATH_Uと同じなので、同じものを参照する
        PALETTE_MOVE[PATH_D] = PALETTE_MOVE[PATH_U];

        //PATH_L：壁走り中（壁が左にある）：左右方向の移動は無効化
        PALETTE_MOVE[PATH_L] = createBasePalette();
        PALETTE_MOVE[PATH_L][MOVE_L] = MOVE_NONE;
        PALETTE_MOVE[PATH_L][MOVE_R] = MOVE_NONE;
        PALETTE_MOVE[PATH_L][MOVE_UL] = MOVE_U;
        PALETTE_MOVE[PATH_L][MOVE_UR] = MOVE_U;
        PALETTE_MOVE[PATH_L][MOVE_DL] = MOVE_D;
        PALETTE_MOVE[PATH_L][MOVE_DR] = MOVE_D;

        //PATH_R：壁走り中（壁が右にある）：同じくPATH_Lを参照
        PALETTE_MOVE[PATH_R] = PALETTE_MOVE[PATH_L];

        //PATH_UorL：空間の左上隅：移動は右か下のみ
        PALETTE_MOVE[PATH_UorL] = createBasePalette();
        PALETTE_MOVE[PATH_UorL][MOVE_U] = MOVE_R;
        PALETTE_MOVE[PATH_UorL][MOVE_D] = MOVE_D;
        PALETTE_MOVE[PATH_UorL][MOVE_L] = MOVE_D;
        PALETTE_MOVE[PATH_UorL][MOVE_R] = MOVE_R;
        PALETTE_MOVE[PATH_UorL][MOVE_UL] = MOVE_NONE;
        PALETTE_MOVE[PATH_UorL][MOVE_UR] = MOVE_R;
        PALETTE_MOVE[PATH_UorL][MOVE_DL] = MOVE_D;
        PALETTE_MOVE[PATH_UorL][MOVE_DR] = MOVE_NONE;

        //PATH_UorR：空間の右上隅：移動は左か下のみ
        PALETTE_MOVE[PATH_UorR] = createBasePalette();
        PALETTE_MOVE[PATH_UorR][MOVE_U] = MOVE_L;
        PALETTE_MOVE[PATH_UorR][MOVE_D] = MOVE_D;
        PALETTE_MOVE[PATH_UorR][MOVE_L] = MOVE_L;
        PALETTE_MOVE[PATH_UorR][MOVE_R] = MOVE_D;
        PALETTE_MOVE[PATH_UorR][MOVE_UL] = MOVE_L;
        PALETTE_MOVE[PATH_UorR][MOVE_UR] = MOVE_NONE;
        PALETTE_MOVE[PATH_UorR][MOVE_DL] = MOVE_NONE;
        PALETTE_MOVE[PATH_UorR][MOVE_DR] = MOVE_D;

        //PATH_DorL：空間の左下隅：移動は右か上のみ
        PALETTE_MOVE[PATH_DorL] = createBasePalette();
        PALETTE_MOVE[PATH_DorL][MOVE_U] = MOVE_U;
        PALETTE_MOVE[PATH_DorL][MOVE_D] = MOVE_R;
        PALETTE_MOVE[PATH_DorL][MOVE_L] = MOVE_U;
        PALETTE_MOVE[PATH_DorL][MOVE_R] = MOVE_R;
        PALETTE_MOVE[PATH_DorL][MOVE_UL] = MOVE_U;
        PALETTE_MOVE[PATH_DorL][MOVE_UR] = MOVE_NONE;
        PALETTE_MOVE[PATH_DorL][MOVE_DL] = MOVE_NONE;
        PALETTE_MOVE[PATH_DorL][MOVE_DR] = MOVE_R;

        //PATH_DorR：空間の右下隅：移動は左か上のみ
        PALETTE_MOVE[PATH_DorR] = createBasePalette();
        PALETTE_MOVE[PATH_DorR][MOVE_U] = MOVE_U;
        PALETTE_MOVE[PATH_DorR][MOVE_D] = MOVE_L;
        PALETTE_MOVE[PATH_DorR][MOVE_L] = MOVE_L;
        PALETTE_MOVE[PATH_DorR][MOVE_R] = MOVE_U;
        PALETTE_MOVE[PATH_DorR][MOVE_UL] = MOVE_NONE;
        PALETTE_MOVE[PATH_DorR][MOVE_UR] = MOVE_U;
        PALETTE_MOVE[PATH_DorR][MOVE_DL] = MOVE_L;
        PALETTE_MOVE[PATH_DorR][MOVE_DR] = MOVE_NONE;

        //PATH_UandL：壁の右下隅：移動は左か上のみ→PATH_DorRと同じなので参照で済ませる
        PALETTE_MOVE[PATH_UandL] = PALETTE_MOVE[PATH_DorR];

        //PATH_UandR：壁の左下隅：PATH_DorLと同じ
        PALETTE_MOVE[PATH_UandR] = PALETTE_MOVE[PATH_DorL];

        //PATH_DandL：壁の右上隅：PATH_UorRと同じ
        PALETTE_MOVE[PATH_DandL] = PALETTE_MOVE[PATH_UorR];

        //PATH_DandR：壁の左上隅：PATH_UorLと同じ
        PALETTE_MOVE[PATH_DandR] = PALETTE_MOVE[PATH_UorL];

        //PATH_DAMAGE：ダメージエリア：変える必要もないのでNONEと同じで。
        PALETTE_MOVE[PATH_DAMAGE] = PALETTE_MOVE[PATH_NONE];
    }

    //Reset
    public function Reset():void{
        //Pos
        {
            this.x = m_PosX = m_StartPosX;
            this.y = m_PosY = m_StartPosY;
        }

        //Vel
        {
            m_VelX = 0;
            m_VelY = 0;
        }

        //Acc
        {
            m_AccX = 0;
            m_AccY = 0;
        }

        //現在のパス
        {
            //m_PathIndex = PATH_NONE;
            m_PathIndex = GameMain.Instance().GetPathIndex(this.x, this.y);
        }

        //地面に居るか
        {
            m_OnGround = false;//最初は空中からスタートすると仮定
        }

        //死んでいるか
        {
            m_IsDead = false;
        }

        //姿勢
        {
            this.rotation = 0;
            this.scaleX = 1;
        }

        //Input
        {
            for(var i:int = 0; i < INPUT_NUM; i++){
                m_Input[i] = m_Input_Old[i] = m_Input_Edge[i] = false;
            }
        }
    }

    //Input
    public function SetKeyFlag(in_Flag:Boolean):Function{
        const KEY_R:int = 82;

        return function(e:KeyboardEvent):void{
            switch(e.keyCode){
            case Keyboard.UP:        m_Input[INPUT_U] = in_Flag; break;
            case Keyboard.DOWN:        m_Input[INPUT_D] = in_Flag; break;
            case Keyboard.LEFT:        m_Input[INPUT_L] = in_Flag; break;
            case Keyboard.RIGHT:    m_Input[INPUT_R] = in_Flag; break;
            case Keyboard.SPACE:    m_Input[INPUT_JUMP] = in_Flag; break;
            case KEY_R:                m_Input[INPUT_RESET] = in_Flag; break;
            }
        };
    }

    //Update
    public function Update(e:Event=null):void{
        var DeltaTime:Number = 1/24.0;

        //Input
        {
            Update_Input();
        }

        //Check Reset
        {
            if(m_Input_Edge[INPUT_RESET]){
                //本当はリセットの入力管理は本体側に持たせるべきだが面倒なのでここで。
                GameMain.Instance().Reset();

                return;
            }
        }

        //死んでたら以降の処理はしない
        {
/*
            if(m_IsDead){
                return;
            }
/*/
            //死亡フラグは不要かも
            if(GameMain.Instance().IsEnd()){
                return;
            }
//*/
        }

        //Move
        {
            Update_Move(DeltaTime);
        }

        //Anim
        {
            Update_Anim(DeltaTime);
        }
    }

    //Update : Input
    public function Update_Input():void{
        //
        for(var i:int = 0; i < INPUT_NUM; i++){
            m_Input_Edge[i] = (m_Input[i] && !m_Input_Old[i]);
            m_Input_Old[i] = m_Input[i];
        }
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        var i:int, j:int;

        //Acc
        {
            m_AccX = 0;
            m_AccY = 0;

            if(m_OnGround){
                //着地中は入力を力として扱う

                //まずは中央値で初期化
                var Pow:uint = MOVE_NONE;

                //入力に応じた方向に力を加える
                if(m_Input_Edge[INPUT_JUMP]){
                    //ジャンプ
                    switch(m_HeadDir){
                    case DIR_U: m_VelY = -JUMP_VEL; break;
                    case DIR_D: m_VelY =  JUMP_VEL; break;
                    case DIR_L: m_VelX = -JUMP_VEL; break;
                    case DIR_R: m_VelX =  JUMP_VEL; break;
                    }
                }else{
                    //壁に沿った入力移動
                    if(m_Input[INPUT_L]){Pow -= 0x01;}
                    if(m_Input[INPUT_R]){Pow += 0x01;}
                    if(m_Input[INPUT_U]){Pow -= 0x10;}
                    if(m_Input[INPUT_D]){Pow += 0x10;}

                    //そして現在の位置に応じて力の方向を変更
                    m_Util.setPixel(0,0, Pow);
                    ConvertByPath(m_Util);//, 0, 1
                    m_AccX = ((m_Util.getPixel(0,0) & 0x0F) >> 0) - 1;
                    m_AccY = ((m_Util.getPixel(0,0) & 0xF0) >> 4) - 1;
                    m_AccX *= MOVE_POW;
                    m_AccY *= MOVE_POW;

                    //地上に入れば自然減速する
                    {
                        if(m_OnGround){
                            m_VelX *= BREAK_RATIO;//m_HeadDirに応じて変えるのも面倒なので両方やっちゃう
                            m_VelY *= BREAK_RATIO;
                        }
                    }
                }
            }else{
                //空中ならば入力は受け付けず、重力しか働かない

                m_AccY = GRAVITY;
            }
        }

        //Vel
        {
            //Powに応じて加減速
            {
                m_VelX += m_AccX * in_DeltaTime;
                m_VelY += m_AccY * in_DeltaTime;
            }
        }

        //移動目標
        var RelTrgX:int;
        var RelTrgY:int;
        {
            m_PosX += m_VelX * in_DeltaTime;
            m_PosY += m_VelY * in_DeltaTime;

            RelTrgX = Math.round(m_PosX - this.x);
            RelTrgY = Math.round(m_PosY - this.y);
        }

        //端数
        var RestX:Number = (RelTrgX < 0)? RelTrgX - (m_PosX - this.x): (m_PosX - this.x) - RelTrgX;
        var RestY:Number = (RelTrgY < 0)? RelTrgY - (m_PosY - this.y): (m_PosY - this.y) - RelTrgY;

        //端数の反映方向
        m_Util.setPixel(0,0, (RelTrgX < 0)? MOVE_L: MOVE_R);
        m_Util.setPixel(1,0, (RelTrgY < 0)? MOVE_U: MOVE_D);

        //速度
        var AbsVelX:Number = Math.abs(m_VelX);
        var AbsVelY:Number = Math.abs(m_VelY);

        //速度の反映方向
        m_Util.setPixel(2,0, (m_VelX < 0)? MOVE_L: MOVE_R);
        m_Util.setPixel(3,0, (m_VelY < 0)? MOVE_U: MOVE_D);

        //１ドットずつの動きを求める
        var MoveNum:int;
        {
            //何ドット進むか
            var NumX:int = Math.abs(RelTrgX);
            var NumY:int = Math.abs(RelTrgY);
            MoveNum = NumX + NumY;

            //移動方向
            var MoveX:uint = (RelTrgX < 0)? MOVE_L: MOVE_R;
            var MoveY:uint = (RelTrgY < 0)? MOVE_U: MOVE_D;

            //初期化
            m_MoveList.fillRect(m_MoveList.rect, MOVE_NONE);//不要っちゃ不要

            //移動列を詰め込む
            //ちゃんとした直線にする意味も特にないので、「縦移動→横移動」みたいな感じで積む
            //ジャンプ処理がやりやすいように、必ず初手で空宙に移動するようにする（そうでないとジャンプ方向の移動が打ち消される）
            switch(m_HeadDir){
            case DIR_U:
            case DIR_D:
                for(i = 0; i < NumY; i++){
                    m_MoveList.setPixel(i, 0, MoveY);
                }
                for(i = 0; i < NumX; i++){
                    m_MoveList.setPixel(NumY+i, 0, MoveX);
                }
                break;
            case DIR_L:
            case DIR_R:
                for(i = 0; i < NumX; i++){
                    m_MoveList.setPixel(i, 0, MoveX);
                }
                for(i = 0; i < NumY; i++){
                    m_MoveList.setPixel(NumX+i, 0, MoveY);
                }
                break;
            }
        }

        //指定された動きに合わせて１ドットずつ移動する
        for(i = 0; i < MoveNum; i++){
            //Move
            {
                var ValX:int = ((m_MoveList.getPixel(i,0) & 0x0F) >> 0) - 1;
                var ValY:int = ((m_MoveList.getPixel(i,0) & 0xF0) >> 4) - 1;

                this.x += ValX;
                this.y += ValY;
            }

            //現在位置のパス取得
            {
                m_PathIndex = GameMain.Instance().GetPathIndex(this.x, this.y);
            }

            //ダメージエリアに入ったならここで死んで終了
            {
                if(m_PathIndex == PATH_DAMAGE){
                    Dead_Damage();

                    return;
                }
            }
            //現在位置に応じて以降の移動方向を変更（角での移動方向変更などの対応）
            {
                ConvertByPath(m_MoveList);//, i, MoveNum
                ConvertByPath(m_Util);//, 0, 2
            }

        }


        var XtoX:int, XtoY:int, YtoX:int, YtoY:int;

        //端数の書き戻し
        {
            XtoX = ((m_Util.getPixel(0,0) & 0x0F) >> 0) - 1;
            XtoY = ((m_Util.getPixel(0,0) & 0xF0) >> 4) - 1;
            YtoX = ((m_Util.getPixel(1,0) & 0x0F) >> 0) - 1;
            YtoY = ((m_Util.getPixel(1,0) & 0xF0) >> 4) - 1;

            m_PosX = this.x + XtoX*RestX + YtoX*RestY;
            m_PosY = this.y + XtoY*RestX + YtoY*RestY;
        }

        //速度をパスに応じて変更
        {
            XtoX = ((m_Util.getPixel(2,0) & 0x0F) >> 0) - 1;
            XtoY = ((m_Util.getPixel(2,0) & 0xF0) >> 4) - 1;
            YtoX = ((m_Util.getPixel(3,0) & 0x0F) >> 0) - 1;
            YtoY = ((m_Util.getPixel(3,0) & 0xF0) >> 4) - 1;

            m_VelX = XtoX*AbsVelX + YtoX*AbsVelY;
            m_VelY = XtoY*AbsVelX + YtoY*AbsVelY;
        }

        //現在の位置に合わせて姿勢制御
        {
            //回転
            switch(m_PathIndex){
            case PATH_D: this.rotation =   0; m_HeadDir = DIR_U; break;
            case PATH_L: this.rotation =  90; m_HeadDir = DIR_R; break;
            case PATH_U: this.rotation = 180; m_HeadDir = DIR_D; break;
            case PATH_R: this.rotation = 270; m_HeadDir = DIR_L; break;
            //これ以外のパス上では姿勢は更新しない
            }

            //向き（スケールで実現）
            switch(m_HeadDir){//基本は速度で判定。入力があればそちらを優先
            case DIR_U:
                if(m_VelX < 0){this.scaleX = -1;}
                if(m_VelX > 0){this.scaleX =  1;}
                if(m_AccX < 0){this.scaleX = -1;}
                if(m_AccX > 0){this.scaleX =  1;}
                break;
            case DIR_D:
                if(m_VelX < 0){this.scaleX =  1;}
                if(m_VelX > 0){this.scaleX = -1;}
                if(m_AccX < 0){this.scaleX =  1;}
                if(m_AccX > 0){this.scaleX = -1;}
                break;
            case DIR_L:
                if(m_VelY < 0){this.scaleX =  1;}
                if(m_VelY > 0){this.scaleX = -1;}
                if(m_AccY < 0){this.scaleX =  1;}
                if(m_AccY > 0){this.scaleX = -1;}
                break;
            case DIR_R:
                if(m_VelY < 0){this.scaleX = -1;}
                if(m_VelY > 0){this.scaleX =  1;}
                if(m_AccY < 0){this.scaleX = -1;}
                if(m_AccY > 0){this.scaleX =  1;}
                break;
            }
        }

        //フラグ更新
        {
            //地上にいる＝パスがある
            m_OnGround = (m_PathIndex != PATH_NONE);
        }

        //落下死チェック
        {
            if(this.y > GameMain.BitmapH+32){
                Dead_Fall();
            }
        }
    }

    //Update : Anim
    public function Update_Anim(in_DeltaTime:Number):void{
        var AnimIndex_Old:int = m_AnimIndex;

        //考慮する速度・加速度
        var Vel:Number;
        var Acc:Number;
        {
            switch(m_HeadDir){
            case DIR_U:
            case DIR_D:
                Vel = Math.abs(m_VelX);
                Acc = Math.abs(m_AccX);
                break;
            case DIR_L:
            case DIR_R:
                Vel = Math.abs(m_VelY);
                Acc = Math.abs(m_AccY);
                break;
            }
        }

        //アニメーションの更新量
        var DeltaAnim:Number;
        {
            //速度による更新量
            const ANIM_CYCLE_PER_VEL:Number = 20;
            var DeltaAnim_ByVel:Number = Vel / ANIM_CYCLE_PER_VEL * in_DeltaTime;

            //加速度による更新量
            const ANIM_CYCLE_PER_ACC:Number = 10;
            var DeltaAnim_ByAcc:Number = Acc / ANIM_CYCLE_PER_VEL * in_DeltaTime;

            //大きい方を採用
            DeltaAnim = Math.max(DeltaAnim_ByVel, DeltaAnim_ByAcc);
        }

        //m_AnimIndexの更新
        {
            m_AnimIndex += DeltaAnim;
            while(m_AnimIndex >= ANIM_NUM){m_AnimIndex -= ANIM_NUM;}
        }

        //新しいAnimIndexになったら表示画像を差し替える
        var AnimIndex_New:int = m_AnimIndex;
        if(AnimIndex_New != AnimIndex_Old){
            //Delete Old
            removeChild(m_Graphic[AnimIndex_Old]);
            //Create New
            addChild(m_Graphic[AnimIndex_New]);
        }
    }

    //移動方向を今のパスに基づいて変更する
    public function ConvertByPath(io_MoveList:BitmapData):void{
        //for(i++ < 256){List[i] = PALETTE_MOVE[PALETTE_MOVE][List[i]];}
        io_MoveList.paletteMap(io_MoveList, io_MoveList.rect, POS_ZERO, null, null, PALETTE_MOVE[m_PathIndex]);
    }

    //死亡する
    public function Dead_Damage():void{
        //Check
        {
            if(m_IsDead){
                return;
            }
        }

        //ゲームオーバー処理
        {
            GameMain.Instance().OnDead_Damage();
        }

        //フラグ
        {
            m_IsDead = true;
        }
    }
    public function Dead_Fall():void{
        //Check
        {
            if(m_IsDead){
                return;
            }
        }

        //ゲームオーバー処理
        {
            GameMain.Instance().OnDead_Fall();//こいつに引数を渡すようにして統合したい
        }

        //フラグ
        {
            m_IsDead = true;
        }
    }
}


//#Goal
class Goal extends Sprite
{
    //==Constt==

    static public const GOAL_RANGE:int = 8;


    //==Function==

    //Init
    public function Goal(in_X:int, in_Y:int):void{
        //Pos
        {
            this.x = in_X;
            this.y = in_Y;
        }

        //Graphic
        {
            addChild(ImageManager.CreateGoalGraphic());
        }
    }

    //Update
    public function Update():void{
        //プレイヤーが一定範囲に来たらゴールとする

        //そもそもすでにゴールしてたら何も処理しない
        {
            if(GameMain.Instance().IsEnd()){
                return;
            }
        }

        //プレイヤーとの距離が一定以上離れていたら何も処理しない
        {
            var GapX:Number = GameMain.Instance().m_Player.x - this.x;
            var GapY:Number = GameMain.Instance().m_Player.y - this.y;

            var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            if(Distance > GOAL_RANGE){
                return;
            }
        }

        //上のチェックに全てクリアしたらゴールしたものとして処理する
        {
            GameMain.Instance().OnGoal();
        }
    }
}


