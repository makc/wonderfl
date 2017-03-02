/*

「錯視迷図 -Ilusion Maze- 」

・不可能立体上のゴールを目指す錯視ゲーム



操作方法（How to Play）

・下のボタンのタッチ（Touch）

　・ブロックの回転移動（Move Block）



ルール

・ブロックをゴールに運ぶ

・９０度回転での移動のみ可能



Android版（画面比率変更＆３０ステージ）

・https://play.google.com/store/apps/details?id=air.showohealer.game.illusionmaze

*/



/*

ブロック描画

・アイソ×トリックのクリッピングを流用

　・すなわち、各六角形ごとに個別にブロックを描画し、六角形の範囲外は非表示にする

＋独自処理

　・レイヤーの切り替えが必要

　・Hexマップの接続でマップを構築してるので、ブロックの描画は移動のPrevとNextが所属するHexMapの２つだけでOK

→結論

　・ブロックは２つ用意

　・PrevとNextの両方のレイヤーに入れる

　・Prev側のブロックはNextのHexのネガマスクで、Next側のブロックはPrevのHexのネガマスクで描画

　　・PrevとNextのHexが違う場合のみ

　　・「PrevブロックはPrevHexのマスク」としないのは、３つ目のHexにまたがることがあり、そちらを表示するため

*/



/*

懸念事項

・HexBlockとConnectionが相互参照になっている（SharedPointer的に考えると解放されない）

*/





//

package {

    import flash.display.*;

    import flash.events.*;

    import flash.geom.*;

    import flash.net.*;

    import flash.text.*;

    import flash.filters.*;

    import flash.ui.*;

    import flash.system.*;

    import flash.desktop.*;



    [SWF(width="465", height="465", frameRate="30", backgroundColor="0xFFFFFF")]

    public class SakusiWonderfl extends Sprite {

        //==File==

//*

        static public const BITMAP_URL:String = "http://assets.wonderfl.net/images/related_images/8/89/89d5/89d5505e4b7131750504b126b331199b785b83d6";

/*/

        [Embed(source='graphics.png')]

         private static var Bitmap_Graphic: Class;

//*/



        //==Const==



        //表示サイズ

        static public const VIEW_W:int = 465;

        static public const VIEW_H:int = 465;

        static public const AD_H:int = 0;



        //

        static public const FLAG_U:uint = 0x01;

        static public const FLAG_D:uint = 0x02;

        static public const FLAG_L:uint = 0x04;

        static public const FLAG_R:uint = 0x08;

        static public const FLAG_F:uint = 0x10;

        static public const FLAG_B:uint = 0x20;

        //Panel

        static public const nFBLRUD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_R | FLAG_F | FLAG_B;

        static public const nFBLRU_:uint = FLAG_U | FLAG_L | FLAG_R | FLAG_F | FLAG_B;

        static public const nFBLR_D:uint = FLAG_D | FLAG_L | FLAG_R | FLAG_F | FLAG_B;

        static public const nFBLR__:uint = FLAG_L | FLAG_R | FLAG_F | FLAG_B;

        static public const nFBL_UD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_F | FLAG_B;

        static public const nFBL_U_:uint = FLAG_U | FLAG_L | FLAG_F | FLAG_B;

        static public const nFBL__D:uint = FLAG_D | FLAG_L | FLAG_F | FLAG_B;

        static public const nFBL___:uint = FLAG_L | FLAG_F | FLAG_B;

        static public const nFB_RUD:uint = FLAG_U | FLAG_D | FLAG_R | FLAG_F | FLAG_B;

        static public const nFB_RU_:uint = FLAG_U | FLAG_R | FLAG_F | FLAG_B;

        static public const nFB_R_D:uint = FLAG_D | FLAG_R | FLAG_F | FLAG_B;

        static public const nFB_R__:uint = FLAG_R | FLAG_F | FLAG_B;

        static public const nFB__UD:uint = FLAG_U | FLAG_D | FLAG_F | FLAG_B;

        static public const nFB__U_:uint = FLAG_U | FLAG_F | FLAG_B;

        static public const nFB___D:uint = FLAG_D | FLAG_F | FLAG_B;

        static public const nFB____:uint = FLAG_F | FLAG_B;

        static public const nF_LRUD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_R | FLAG_F;

        static public const nF_LRU_:uint = FLAG_U | FLAG_L | FLAG_R | FLAG_F;

        static public const nF_LR_D:uint = FLAG_D | FLAG_L | FLAG_R | FLAG_F;

        static public const nF_LR__:uint = FLAG_L | FLAG_R | FLAG_F;

        static public const nF_L_UD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_F;

        static public const nF_L_U_:uint = FLAG_U | FLAG_L | FLAG_F;

        static public const nF_L__D:uint = FLAG_D | FLAG_L | FLAG_F;

        static public const nF_L___:uint = FLAG_L | FLAG_F;

        static public const nF__RU_:uint = FLAG_U | FLAG_R | FLAG_F;

        static public const nF__R_D:uint = FLAG_D | FLAG_R | FLAG_F;

        static public const nF__R__:uint = FLAG_R | FLAG_F;

        static public const nF___UD:uint = FLAG_U | FLAG_D | FLAG_F;

        static public const nF___U_:uint = FLAG_U | FLAG_F;

        static public const nF____D:uint = FLAG_D | FLAG_F;

        static public const nF_____:uint = FLAG_F;

        static public const n_BLRUD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_R | FLAG_B;

        static public const n_BLRU_:uint = FLAG_U | FLAG_L | FLAG_R | FLAG_B;

        static public const n_BLR_D:uint = FLAG_D | FLAG_L | FLAG_R | FLAG_B;

        static public const n_BLR__:uint = FLAG_L | FLAG_R | FLAG_B;

        static public const n_BL_UD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_B;

        static public const n_BL_U_:uint = FLAG_U | FLAG_L | FLAG_B;

        static public const n_BL__D:uint = FLAG_D | FLAG_L | FLAG_B;

        static public const n_BL___:uint = FLAG_L | FLAG_B;

        static public const n_B_RUD:uint = FLAG_U | FLAG_D | FLAG_R | FLAG_B;

        static public const n_B_RU_:uint = FLAG_U | FLAG_R | FLAG_B;

        static public const n_B_R_D:uint = FLAG_D | FLAG_R | FLAG_B;

        static public const n_B_R__:uint = FLAG_R | FLAG_B;

        static public const n_B__UD:uint = FLAG_U | FLAG_D | FLAG_B;

        static public const n_B__U_:uint = FLAG_U | FLAG_B;

        static public const n_B___D:uint = FLAG_D | FLAG_B;

        static public const n_B____:uint = FLAG_B;

        static public const n__LRUD:uint = FLAG_U | FLAG_D | FLAG_L | FLAG_R;

        static public const n__LRU_:uint = FLAG_U | FLAG_L | FLAG_R;

        static public const n__LR_D:uint = FLAG_D | FLAG_L | FLAG_R;

        static public const n__LR__:uint = FLAG_L | FLAG_R;

        static public const n__L_UD:uint = FLAG_U | FLAG_D | FLAG_L;

        static public const n__L_U_:uint = FLAG_U | FLAG_L;

        static public const n__L__D:uint = FLAG_D | FLAG_L;

        static public const n__L___:uint = FLAG_L;

        static public const n___RU_:uint = FLAG_U | FLAG_R;

        static public const n___R_D:uint = FLAG_D | FLAG_R;

        static public const n___R__:uint = FLAG_R;

        static public const n____UD:uint = FLAG_U | FLAG_D;

        static public const n____U_:uint = FLAG_U;

        static public const n_____D:uint = FLAG_D;

        static public const n______:uint = 0;

        //

        static public const xFB_LR:uint = 0x40;

        static public const xFB_UD:uint = 0x41;

        static public const xLR_FB:uint = 0x42;

        static public const xLR_UD:uint = 0x43;

        static public const xUD_FB:uint = 0x44;

        static public const xUD_LR:uint = 0x45;



        //Map

        static public var s_MapIter:int = 0;

        static public const MAP:Array = [

            {//easy:申

                name:"申",

                map:[

                [n______, n_____D, nF____D],

                [n______, xUD_FB,  nF___UD],

                [n_B___D, xFB_UD,  nF___U_],

                [n_B__UD, xUD_FB,  n______],

                [n_B__U_, n____U_, n______],

                ],

                start:{x:1, y:0, plane:"R"},

                goal:{x:1, y:4, plane:"R"}

            },

            {//easy:∞:great

                name:"Loop",

                map:[

                [n______, n______, nF____D],

                [n___R_D, xLR_FB,  n__L_U_],

                [n_B__U_, n______, n______],

                ],

                start:{x:2, y:0, plane:"U"},

                goal:{x:0, y:2, plane:"F"}

            },

            {//easy(mid)

                name:"Plane",

                map:[

                [n______, nF__R_D, n__LR_D, nF_L___],

                [n_B_R__, n__LRU_, n_BL_U_, n______],

                ],

                start:{x:0, y:1, plane:"U"},

                goal:{x:0, y:1, plane:"F"}

            },

            {//mid:Star

                name:"Star",

                map:[

                [n______, n______, n______, nF____D, n______],

                [n______, n___R_D, xLR_FB,  xLR_UD,  nF_L___],

                [n______, xUD_FB,  n______, xUD_FB,  n______],

                [n_B_R__, xLR_UD,  xFB_LR,  n__L_U_, n______],

                [n______, n_B__U_, n______, n______, n______],

                ],

                start:{x:0, y:3, plane:"U"},

                goal:{x:4, y:1, plane:"U"}

            },

            {//mid:No Illusion:great

                name:"No Illusion : Cube",

                map:[

                [n______, n______, nF__R_D, nF_L__D],

                [n______, nFB____, xFB_UD,  n____UD],

                [n_B_R_D, n_BL__D, nF__RU_, nF_L_U_],

                [n____UD, xUD_FB,  nFB____, n______],

                [n_B_RU_, n_BL_U_, n______, n______],

                ],

                start:{x:2, y:0, plane:"U"},

                goal:{x:0, y:4, plane:"F"}

            },

            {//easy

                name:"No Illusion : ＋",

                map:[

                [n______, n______, n______, nF____D, n______, n______],

                [n______, n______, n_B___D, n____UD, n______, n______],

                [n______, nF__R__, xUD_LR,  n__LRUD, n__LR__, nF_L___],

                [n_B_R__, n__LR__, n__LRUD, xLR_UD,  n_BL___, n______],

                [n______, n______, n____UD, nF___U_, n______, n______],

                [n______, n______, n_B__U_, n______, n______, n______],

                ],

                start:{x:5, y:2, plane:"U"},

                goal:{x:0, y:3, plane:"U"}

            },

            {//easy:

                name:"2-Diamonds",

                map:[

                [n______, n______, nF__R__, n__LR__, nF_L__D],

                [n______, nFB____, nF__R__, xLR_FB,  nF_L_U_],

                [n_B_R_D, xLR_FB,  n_BL___, nFB____, n______],

                [n_B_RU_, n__LR__, n_BL___, n______, n______],

                ],

                start:{x:2, y:3, plane:"U"},

                goal:{x:2, y:0, plane:"U"}

            },

            {//easy(mid)

                name:"Plane",

                map:[

                [n______, nF__R_D, n__LR_D, nF_L___],

                [n_B_R__, n__LRU_, n_BL_U_, n______],

                ],

                start:{x:0, y:1, plane:"U"},

                goal:{x:0, y:1, plane:"F"}

            },

            {//easy-mid

                name:"Symmetry",

                map:[

                [n______, n______, nF__R_D, n__LR__, nF_L__D],

                [n______, nFB____, n____UD, n_B_R__, nF_L_U_],

                [n_B_R_D, nF_L___, n____UD, nFB____, n______],

                [n_B_RU_, n__LR__, n_BL_U_, n______, n______],

                ],

                start:{x:1, y:3, plane:"U"},

                goal:{x:2, y:0, plane:"U"}

            },

            {//mid:3-Square

                name:"dop",

                map:[

                [n______, n______, n______, nF____D],

                [n______, n_____D, nFB___D, nF___U_],

                [n______, xUD_FB,  xUD_FB,  n______],

                [n_B___D, nFB__U_, n____U_, n______],

                [n_B__U_, n______, n______, n______],

                ],

                start:{x:1, y:1, plane:"R"},

                goal:{x:2, y:3, plane:"R"}

            },

            {//mid:円

                name:"円",

                map:[

                [n______, n______, n______, nF____D],

                [n______, n______, nFB____, nF___UD],

                [n______, nFB_R__, nFBL___, n____U_],

                [n_B___D, nFB____, n______, n______],

                [n_B__UD, n______, n______, n______],

                [n____U_, n______, n______, n______],

                ],

                start:{x:3, y:0, plane:"U"},

                goal:{x:3, y:2, plane:"F"}

            },

            {//mid

                name:"Fractal",

                map:[

                [n______, n______, n______, n______, nF____D],

                [n______, n______, n______, nFB____, nF___UD],

                [n______, n______, nFB____, nFB___D, n____UD],

                [n______, nFB____, nFB_R__, n__LRU_, n__L_UD],

                [n_B_R__, n_BLR__, n__LR__, n__LR__, n__L_U_],

                ],

                start:{x:4, y:0, plane:"U"},

                goal:{x:3, y:2, plane:"R"}

            },

            {//mid

                name:"X",

                map:[

                [n______, n______, n______, n______, n______, n______, nF____D],

                [n______, n______, n______, n______, n______, nFB____, nF___U_],

                [n______, n______, n______, n______, nFB____, nFB____, n______],

                [n___R_D, n__LR__, n__LR__, xLR_FB,  xFB_LR,  n__LR__, n__L__D],

                [n___RU_, n__LR__, xFB_LR,  nFBLR__, n__LR__, n__LR__, n__L_U_],

                [n______, nFB____, nFB____, n______, n______, n______, n______],

                [n_B___D, nFB____, n______, n______, n______, n______, n______],

                [n_B__U_, n______, n______, n______, n______, n______, n______],

                ],

                start:{x:1, y:6, plane:"U"},

                goal:{x:1, y:4, plane:"U"}

            },

            {//mid:

                name:"Diamond",

                map:[

                [n______, n______, nF__R_D, n__LR_D, nF_L___],

                [n______, nFB___D, n____UD, nFB__U_, n______],

                [n_B_R__, n__LRU_, n_BL_U_, n______, n______],

                ],

                start:{x:2, y:2, plane:"F"},

                goal:{x:2, y:0, plane:"U"}

            },

            {//mid:3-Diamond

                name:"Tri-Diamonds",

                map:[

                [n______, n______, n______, n______, n______, nF__R__, nF_L___],

                [n______, n______, n______, nF__R__, xFB_LR,  n_BL___, n______],

                [n______, nF__R__, xFB_LR,  n_BL___, n______, n______, n______],

                [n_B_R__, n_BL___, n______, n______, n______, n______, n______],

                ],

                start:{x:0, y:3, plane:"U"},

                goal:{x:6, y:0, plane:"U"}

            },

        ];





        //==Var==



        //Pseudo Singleton

        static public var Instance:SakusiWonderfl;



        //Layer

        public var m_Layer_Root            :Sprite = new Sprite();

        public var  m_Layer_Game        :Sprite = new Sprite();

        public var   m_Layer_BlockB        :Sprite = new Sprite();

        public var   m_Layer_BackGroundB:Sprite = new Sprite();

        public var   m_Layer_BlockC        :Sprite = new Sprite();

        public var   m_Layer_BackGroundF:Sprite = new Sprite();

        public var   m_Layer_BlockF        :Sprite = new Sprite();

        public var  m_Layer_UI            :Sprite = new Sprite();



        //BackGround

//        public var m_BitmapData_BackGroundF:BitmapData = new BitmapData(VIEW_W, VIEW_H, true, 0x00000000);

//        public var m_BitmapData_BackGroundB:BitmapData = new BitmapData(VIEW_W, VIEW_H, true, 0x00000000);

        public var m_BitmapData_BackGroundF:BitmapData = new BitmapData(2*VIEW_W, 2*VIEW_H, true, 0x00000000);

        public var m_BitmapData_BackGroundB:BitmapData = new BitmapData(2*VIEW_W, 2*VIEW_H, true, 0x00000000);



        //Player

        public var m_Player:Player;



        //Goal

        public var m_Goal:Goal;



        //Map

        public var m_Map:Vector.<Vector.<HexBlock> >;



        //UI

        //- Rot Button

        public var m_Bitmap_RotButton:Vector.<Bitmap>;

        public var m_BitmapData_RotButton_On:Vector.<BitmapData>;

        public var m_BitmapData_RotButton_Off:Vector.<BitmapData>;

        //- Pause Button

        public var m_ButtonPause:Button;

        public var m_Pause_Push:Boolean = false;

        public var m_Pause_Exec:Boolean = false;

        //- Popup系UI

        public var m_Popup_Queue:Vector.<Popup> = new Vector.<Popup>();

        public var m_TopPopup:Popup = null;





        //==Function==



        //Init

        public function SakusiWonderfl(){

            //Pseudo Singleton

            Instance = this;



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



                            Init(null);//初期化に入る

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

        public function Init(e:Event):void

        {

            var i:int;



            //Static Init

            {

                HexBlock.StaticInit();

                Player.StaticInit();

            }



            //Layer

            {

                addChild(m_Layer_Root);

                    m_Layer_Root.addChild(m_Layer_Game);

                        m_Layer_Game.addChild(m_Layer_BlockB);

                        m_Layer_Game.addChild(m_Layer_BackGroundB);

                        m_Layer_Game.addChild(m_Layer_BlockC);

                        m_Layer_Game.addChild(m_Layer_BackGroundF);

                        m_Layer_Game.addChild(m_Layer_BlockF);

                    m_Layer_Root.addChild(m_Layer_UI);

            }



            //BackGround

            {

                m_Layer_BackGroundF.addChild(new Bitmap(m_BitmapData_BackGroundF));

                m_Layer_BackGroundB.addChild(new Bitmap(m_BitmapData_BackGroundB));

            }



            //Player

            {

                m_Player = new Player();

            }



            //Goal

            {

                m_Goal = new Goal();

            }



            //Rot Button

            {

                m_Bitmap_RotButton            = new Vector.<Bitmap>(Player.ROT_NUM);

                m_BitmapData_RotButton_On    = new Vector.<BitmapData>(Player.ROT_NUM);

                m_BitmapData_RotButton_Off    = new Vector.<BitmapData>(Player.ROT_NUM);

                for(i = 0; i < Player.ROT_NUM; ++i){

                    m_Bitmap_RotButton[i] = new Bitmap();

                    m_Bitmap_RotButton[i].x = VIEW_W/12 + i * VIEW_W/6 - 64/2;

                    m_Bitmap_RotButton[i].y = VIEW_H - 64;

                    m_Layer_UI.addChild(m_Bitmap_RotButton[i]);



                    m_BitmapData_RotButton_On[i]  = ImageManager.GetBitmapData_RotButton(i, true);

                    m_BitmapData_RotButton_Off[i] = ImageManager.GetBitmapData_RotButton(i, false);

                }

            }



            //Pause Button

            {

                m_ButtonPause = new Button(ImageManager.GetBitmapData_Pause());

                m_Layer_UI.addChild(m_ButtonPause);

                m_ButtonPause.x = VIEW_W - 64/2;

                m_ButtonPause.y = 64/2;

            }



            //Touch

            {

                stage.addEventListener(MouseEvent.MOUSE_DOWN,    OnMouseDown);

                stage.addEventListener(MouseEvent.MOUSE_MOVE,    OnMouseMove);

                stage.addEventListener(MouseEvent.MOUSE_UP,        OnMouseUp);

            }



            //!!Test

//            addChild(new Bitmap(HexBlock.s_HexNegaMask));



            //Reset

            {

                Reset(true);

            }



            //最初のState

            {

                //ちょっと強引にステージ選択画面にする

                Push(new Popup_StageSelect());

                Pop();//上のResetでPushされたものをPopしておく

            }



            //Update

            {

                addEventListener(Event.ENTER_FRAME, Update);



                //プレイヤーの位置などの初期化

                Update();

            }



            //OnEnd

            {

                addEventListener(Event.REMOVED_FROM_STAGE, Finish);

            }

        }



        //Reset

        public function Reset(in_RestructFlag:Boolean):void{

            var xx:int, yy:int;



            //Alias

            var map:Array = MAP[s_MapIter].map;

            var MapNumX:int = map[0].length;

            var MapNumY:int = map.length;



            //Clear

            {

                m_BitmapData_BackGroundF.fillRect(m_BitmapData_BackGroundF.rect, 0x00000000);

                m_BitmapData_BackGroundB.fillRect(m_BitmapData_BackGroundB.rect, 0x00000000);

            }



            //Map

            {

                m_Map = new Vector.<Vector.<HexBlock> >(MapNumY);

                for(yy = 0; yy < MapNumY; ++yy){

                    m_Map[yy] = new Vector.<HexBlock>(MapNumX);

                    for(xx = 0; xx < MapNumX; ++xx){

                        var map_val:uint = map[yy][xx];

                        var block:HexBlock = new HexBlock();

                        block.Reset(xx, yy, map_val);



                        m_Map[yy][xx] = block;

                    }

                }

            }



            //Camera

            {

                var min_y:Number = MapNumY * 6*HexBlock.BLOCK_W;

                var max_y:Number = 0;

                for(yy = 0; yy < MapNumY; ++yy){

                    for(xx = 0; xx < MapNumX; ++xx){

                        if(map[yy][xx] != 0){

                            var uy:Number = xx * HexBlock.OFFSET_Y + yy * 6*HexBlock.BLOCK_W;

                            var dy:Number = uy + 6*HexBlock.BLOCK_W;

                            uy -= 2*HexBlock.BLOCK_W;

                            dy += 2*HexBlock.BLOCK_W;

                            if(uy < min_y){min_y = uy;}

                            if(max_y < dy){max_y = dy;}

                        }

                    }

                }



//*

                var map_w:Number = MapNumX * HexBlock.OFFSET_X;// + 1*HexBlock.BLOCK_W;

                var map_h:Number = max_y - min_y;

                var scl_x:Number = 1.0 * SakusiWonderfl.VIEW_W / map_w;

                var scl_y:Number = 1.0 * (SakusiWonderfl.VIEW_H - AD_H - 64)/ map_h;

                var scl_min:Number = Math.min(scl_x, scl_y);

                //var scl:Number = Util.Clamp(int(Math.min(scl_x, scl_y) * 8) / 8.0, 0.125, 1.0);

                var scl:Number;

                for(scl = 1; scl_min < scl; scl *= 0.5){

                    if(scl <= 0.125){break;}

                }

/*/

                var scl:Number = 1;

//*/



                m_Layer_Game.x = VIEW_W/2 - scl*map_w/2 - 6 * HexBlock.BLOCK_W * scl;

                m_Layer_Game.y = (VIEW_H - 64)/2 - scl*map_h/2 - 6 * HexBlock.BLOCK_W * scl - min_y * scl;

                m_Layer_Game.scaleX = m_Layer_Game.scaleY = scl;

            }



            //Connection

            {

                Refresh_Connection();

            }



            //Player

            {

                var player_index_x:int = MAP[s_MapIter].start.x;

                var player_index_y:int = MAP[s_MapIter].start.y;

                var player_plane_dir:int = 0;

                var player_plane_dir_str:String = MAP[s_MapIter].start.plane;

                if(player_plane_dir_str == "U"){player_plane_dir = Connection.DIR_U;}

                if(player_plane_dir_str == "D"){player_plane_dir = Connection.DIR_D;}

                if(player_plane_dir_str == "L"){player_plane_dir = Connection.DIR_L;}

                if(player_plane_dir_str == "R"){player_plane_dir = Connection.DIR_R;}

                if(player_plane_dir_str == "F"){player_plane_dir = Connection.DIR_F;}

                if(player_plane_dir_str == "B"){player_plane_dir = Connection.DIR_B;}



                m_Player.Reset(m_Map[player_index_y][player_index_x].m_BaseConnection[player_plane_dir]);

            }



            //Goal

            {

                var goal_index_x:int = MAP[s_MapIter].goal.x;

                var goal_index_y:int = MAP[s_MapIter].goal.y;

                var goal_plane_dir:int = 0;

                var goal_plane_dir_str:String = MAP[s_MapIter].goal.plane;

                if(goal_plane_dir_str == "U"){goal_plane_dir = Connection.DIR_U;}

                if(goal_plane_dir_str == "D"){goal_plane_dir = Connection.DIR_D;}

                if(goal_plane_dir_str == "L"){goal_plane_dir = Connection.DIR_L;}

                if(goal_plane_dir_str == "R"){goal_plane_dir = Connection.DIR_R;}

                if(goal_plane_dir_str == "F"){goal_plane_dir = Connection.DIR_F;}

                if(goal_plane_dir_str == "B"){goal_plane_dir = Connection.DIR_B;}



                m_Goal.InitConnection(m_Map[goal_index_y][goal_index_x].m_BaseConnection[goal_plane_dir], goal_plane_dir);

            }



            //Rot Button

            {

                Update_RotButton();

            }



            //StageName

            if(in_RestructFlag)

            {

                Push(new Popup_StageName(MAP[s_MapIter].name));

            }

        }



        //Finish

        public function Finish(e:Event):void{

            removeEventListener(Event.ADDED_TO_STAGE, Init);

            removeEventListener(Event.ENTER_FRAME, Update);

            removeEventListener(Event.REMOVED_FROM_STAGE, Finish);

        }



        //Refresh_Connection

        public function Refresh_Connection():void{

            var xx:int, yy:int;



            var map:Array = MAP[s_MapIter].map;

            var MapNumX:int = map[0].length;

            var MapNumY:int = map.length;



            for(yy = 0; yy < MapNumY; ++yy){

                for(xx = 0; xx < MapNumX; ++xx){

                    //Center

                    var block:HexBlock = m_Map[yy][xx];

                    if(block == null){continue;}



                    //UDLRFB

                    var block_u:HexBlock = GetMap(xx, yy, Connection.DIR_U);

                    var block_d:HexBlock = GetMap(xx, yy, Connection.DIR_D);

                    var block_l:HexBlock = GetMap(xx, yy, Connection.DIR_L);

                    var block_r:HexBlock = GetMap(xx, yy, Connection.DIR_R);

                    var block_f:HexBlock = GetMap(xx, yy, Connection.DIR_F);

                    var block_b:HexBlock = GetMap(xx, yy, Connection.DIR_B);



                    if(block_u != null){block.Connect(block_u, Connection.DIR_U);}

                    if(block_d != null){block.Connect(block_d, Connection.DIR_D);}

                    if(block_l != null){block.Connect(block_l, Connection.DIR_L);}

                    if(block_r != null){block.Connect(block_r, Connection.DIR_R);}

                    if(block_f != null){block.Connect(block_f, Connection.DIR_F);}

                    if(block_b != null){block.Connect(block_b, Connection.DIR_B);}

                }

            }

        }

        public function GetMap(in_BaseX:int, in_BaseY:int, in_Dir:int):HexBlock{

            //Index

            var xx:int = in_BaseX;

            var yy:int = in_BaseY;

            switch(in_Dir){

            case Connection.DIR_F: --xx; ++yy; break;

            case Connection.DIR_B: ++xx; --yy; break;

            case Connection.DIR_L: --xx; break;

            case Connection.DIR_R: ++xx; break;

            case Connection.DIR_U: --yy; break;

            case Connection.DIR_D: ++yy; break;

            }



            //Range

            var map:Array = MAP[s_MapIter].map;

            var MapNumX:int = map[0].length;

            var MapNumY:int = map.length;

            if(xx < 0){return null;}

            if(MapNumX <= xx){return null;}

            if(yy < 0){return null;}

            if(MapNumY <= yy){return null;}



            //Result

            return m_Map[yy][xx];

        }



        //Touch

        private function OnMouseDown(e:MouseEvent):void{

            if(m_TopPopup != null){

                m_TopPopup.OnMouseDown();

                return;

            }



            if(m_ButtonPause.IsRectIn()){

                m_Pause_Push = true;

                m_Pause_Exec = true;

                return;

            }



            m_Player.m_RotateIndex_Trg = 5.999 * mouseX / VIEW_W;

        }

        private function OnMouseMove(e:MouseEvent):void{

            if(m_TopPopup != null){

                m_TopPopup.OnMouseMove();

                return;

            }



            if(m_Pause_Push && !m_ButtonPause.IsRectIn()){

                m_Pause_Exec = false;

            }

        }

        private function OnMouseUp(e:MouseEvent):void{

            if(m_TopPopup != null){

                m_TopPopup.OnMouseUp();

                return;

            }



            if(m_Pause_Push && m_ButtonPause.IsRectIn()){

                if(m_Pause_Exec){

                    Push(new Popup_Pause());

                }



                return;

            }



            m_Player.m_RotateIndex_Trg = -1;

        }



        //Update

        public function Update(e:Event=null):void{

            const DeltaTime:Number = 1.0 / 30.0;



            //Popup

            if(m_TopPopup != null){

                m_TopPopup.Update(DeltaTime);

                if(m_TopPopup.IsEnd()){

                    Pop();

                }

                return;//ダイアログ表示中

            }



            //Button

            {

                m_ButtonPause.Update(DeltaTime);

            }



            //Rotate

            m_Player.Update(DeltaTime);



            //Rot Button

            Update_RotButton();



            //Goal

            m_Goal.Update();

        }

        //Update : Rot Button

        public function Update_RotButton():void{

            //プレイヤーが回転移動中なら何もしない

            if(0 <= m_Player.m_RotateIndex){

                return;

            }



            //プレイヤーが移動可能な方向をオン、そうでなければオフにする

            for(var i:int = 0; i < Player.ROT_NUM; ++i){

                var connection:Connection = m_Player.GetNextConnection(m_Player.m_Connection_Next, i);

                if(connection != null){

                    m_Bitmap_RotButton[i].bitmapData = m_BitmapData_RotButton_On[i];

                }else{

                    m_Bitmap_RotButton[i].bitmapData = m_BitmapData_RotButton_Off[i];

                }

            }

        }



        //Popup : Push

        public function Push(in_Popup:Popup):void{

            if(m_Popup_Queue.length <= 0){

                m_TopPopup = in_Popup;

            }

            m_Layer_Root.addChild(in_Popup);

            m_Popup_Queue.push(in_Popup);

        }



        //Popup : Pop

        public function Pop():void{

            if(m_TopPopup != null){

                m_TopPopup.parent.removeChild(m_TopPopup);

                m_Popup_Queue.shift();

            }



            if(m_Popup_Queue.length <= 0){

                m_TopPopup = null;

            }else{

                m_TopPopup = m_Popup_Queue[0];

            }

        }



        //Goal

        public function OnGoal():void{

            //Popup

            {

                Push(new Popup_Result(true));

            }

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

import flash.utils.*;

import flash.system.*;





class HexBlock

{

    //==Const==



    //Dir

    static public var s_DirIter:int = 0;

    //- そちらの方向に伸びるブロック用の線

    static public const DIR_U    :int = s_DirIter++;

    static public const DIR_D    :int = s_DirIter++;

    static public const DIR_L    :int = s_DirIter++;

    static public const DIR_R    :int = s_DirIter++;

    static public const DIR_F    :int = s_DirIter++;

    static public const DIR_B    :int = s_DirIter++;

    //- 境界線

    static public const DIR_UL    :int = s_DirIter++;

    static public const DIR_UR    :int = s_DirIter++;

    static public const DIR_UF    :int = s_DirIter++;

    static public const DIR_UB    :int = s_DirIter++;

    static public const DIR_FL    :int = s_DirIter++;

    static public const DIR_FR    :int = s_DirIter++;

    static public const DIR_FD    :int = s_DirIter++;

    static public const DIR_RB    :int = s_DirIter++;

    static public const DIR_RD    :int = s_DirIter++;

    //

    static public const DIR_NUM    :int = s_DirIter;





    //==Var==



    //Param

    static public var BMD_W:int;

    static public var BMD_H:int;

    static public var BLOCK_W:int;

    static public var OFFSET_X:int;

    static public var OFFSET_Y:int;



    //Ori Block Graphic

    static public var s_BitmapData:Vector.<BitmapData>;

    static public var s_BitmapData_Base:BitmapData;



    //Mask

    static public var s_HexMask:BitmapData;

    static public var s_HexNegaMask:BitmapData;



    //UL Pos

    public var m_BaseX:Number = 0;

    public var m_BaseY:Number = 0;



    //Map Val

    public var m_MapVal:int = -1;



    //Connection

    public var m_EdgeConnection:Vector.<Vector.<Connection> >;

    public var m_BaseConnection:Vector.<Connection>;





    //==Function==



    //Static Init

    static public function StaticInit():void{

/*

        BMD_H = 48;//96;

        BMD_W = BMD_H * 2;

        BLOCK_W = BMD_H / 6;

        const LINE_W:int = 2;

//*/

/*

        BMD_H = 48 * 3;//96;

        BMD_W = BMD_H;

        BLOCK_W = 8;

        const LINE_W:int = 2;

//*/

//*

        BMD_H = 96 * 3;//96;

        BMD_W = BMD_H;

        BLOCK_W = 16;

        const LINE_W:int = 4;

//*/



        var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



        OFFSET_X = block_offset * 6;

        OFFSET_Y = BLOCK_W * 3;



        const LINE_COLOR:uint = 0x000000;

        const LINE_ALPHA:Number = 1.0;

        const BLOCK_COLOR:uint = 0xFFFFFF;



        var center_x:int = BMD_W / 2;

        var center_y:int = BMD_H / 2;



        var xx:int, yy:int;

        var bmd:BitmapData;

        var shape:Shape = new Shape();

        var g:Graphics = shape.graphics;



        //s_BitmapDataBase

        {

            s_BitmapData_Base = new BitmapData(BMD_W, BMD_H, true, 0x00000000);



            g.clear();

            g.lineStyle(0,0,0);

            g.beginFill(BLOCK_COLOR, 1.0);

                g.moveTo(center_x,    center_y - BLOCK_W);

                g.lineTo(center_x - block_offset,    center_y - BLOCK_W/2);

                g.lineTo(center_x - block_offset,    center_y + BLOCK_W/2);

                g.lineTo(center_x,    center_y + BLOCK_W);

                g.lineTo(center_x + block_offset,    center_y + BLOCK_W/2);

                g.lineTo(center_x + block_offset,    center_y - BLOCK_W/2);

            g.endFill();



            s_BitmapData_Base.draw(shape);

        }



        //s_BitmapData

        {

            s_BitmapData = new Vector.<BitmapData>(DIR_NUM);

            for(var i:int = 0; i < DIR_NUM; ++i){

                bmd = new BitmapData(BMD_W, BMD_H, true, 0x00000000);



                g.clear();

                switch(i){

                //- 境界線

                case DIR_UL:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_UR:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x + block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_UF:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_UB:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x + block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_FL:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_FR:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x, center_y + BLOCK_W);

                    break;

                case DIR_FD:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y + BLOCK_W);

                    break;

                case DIR_RB:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y - BLOCK_W/2);

                    break;

                case DIR_RD:

                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y + BLOCK_W);

                    break;

                //- 伸びるブロック

//*

                case DIR_D:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                        g.lineTo(center_x + block_offset, center_y + BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y + BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x, center_y + BMD_H/2);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y + BMD_H/2);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y + BMD_H/2);

                    break;

                case DIR_L:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x, center_y - BLOCK_W);

                        g.lineTo(center_x - block_offset*4, center_y - BLOCK_W*3);

                        g.lineTo(center_x - block_offset*4, center_y - BLOCK_W*1);

                        g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x - block_offset*4, center_y - BLOCK_W*3);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset*4, center_y - BLOCK_W*2);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x - block_offset*4, center_y - BLOCK_W*1);

                    break;

                case DIR_B:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x, center_y - BLOCK_W);

                        g.lineTo(center_x + block_offset*4, center_y - BLOCK_W*3);

                        g.lineTo(center_x + block_offset*4, center_y - BLOCK_W*1);

                        g.lineTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x + block_offset*4, center_y - BLOCK_W*3);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset*4, center_y - BLOCK_W*2);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x + block_offset*4, center_y - BLOCK_W*1);

                    break;

                case DIR_U:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x + block_offset, center_y - BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y - BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x, center_y - BMD_H/2);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y - BMD_H/2);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y - BMD_H/2);

                    break;

                case DIR_R:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x + block_offset*4, center_y + BLOCK_W*1);

                        g.lineTo(center_x + block_offset*4, center_y + BLOCK_W*3);

                        g.lineTo(center_x, center_y + BLOCK_W);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset*4, center_y + BLOCK_W*1);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x + block_offset*4, center_y + BLOCK_W*2);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x + block_offset*4, center_y + BLOCK_W*3);

                    break;

                case DIR_F:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x - block_offset*4, center_y + BLOCK_W*1);

                        g.lineTo(center_x - block_offset*4, center_y + BLOCK_W*3);

                        g.lineTo(center_x, center_y + BLOCK_W);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset*4, center_y + BLOCK_W*1);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x - block_offset*4, center_y + BLOCK_W*2);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x - block_offset*4, center_y + BLOCK_W*3);

                    break;

/*/

                case DIR_D:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                        g.lineTo(center_x + block_offset, center_y + BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y + BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x, center_y + BMD_H/2);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y + BMD_H/2);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y + BMD_H/2);

                    break;

                case DIR_L:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x, center_y - BLOCK_W);

                        g.lineTo(center_x - block_offset*5/2, center_y - BLOCK_W*9/4);

                        g.lineTo(center_x - block_offset*7/2, center_y - BLOCK_W*3/4);

                        g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x - block_offset*5/2, center_y - BLOCK_W*9/4);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset*3, center_y - BLOCK_W*3/2);

                    g.moveTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x - block_offset*7/2, center_y - BLOCK_W*3/4);

                    break;

                case DIR_B:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x, center_y - BLOCK_W);

                        g.lineTo(center_x + block_offset*5/2, center_y - BLOCK_W*9/4);

                        g.lineTo(center_x + block_offset*7/2, center_y - BLOCK_W*3/4);

                        g.lineTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x + block_offset*5/2, center_y - BLOCK_W*9/4);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset*3, center_y - BLOCK_W*3/2);

                    g.moveTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x + block_offset*7/2, center_y - BLOCK_W*3/4);

                    break;

                case DIR_U:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x + block_offset, center_y - BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y - BMD_H/2);

                        g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x, center_y - BMD_H/2);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y - BMD_H/2);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y - BMD_H/2);

                    break;

                case DIR_R:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

                        g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x + block_offset*7/2, center_y + BLOCK_W*3/4);

                        g.lineTo(center_x + block_offset*5/2, center_y + BLOCK_W*9/4);

                        g.lineTo(center_x, center_y + BLOCK_W);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x + block_offset*3, center_y + BLOCK_W*3/2);

                    g.moveTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset*7/2, center_y + BLOCK_W*3/4);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x + block_offset*5/2, center_y + BLOCK_W*9/4);

                    break;

                case DIR_F:

                    g.lineStyle(0,0,0);

                    g.beginFill(BLOCK_COLOR, 1.0);

//                    g.beginFill(0x00FF00, 1.0);//!!test

                        g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                        g.lineTo(center_x - block_offset*7/2, center_y + BLOCK_W*3/4);

                        g.lineTo(center_x - block_offset*5/2, center_y + BLOCK_W*9/4);

                        g.lineTo(center_x, center_y + BLOCK_W);

                    g.endFill();



                    g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x - block_offset*3, center_y + BLOCK_W*3/2);

                    g.moveTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset*7/2, center_y + BLOCK_W*3/4);

                    g.moveTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x - block_offset*5/2, center_y + BLOCK_W*9/4);

                    break;

//*/

                }

                bmd.draw(shape);



                s_BitmapData[i] = bmd;

            }

        }



        //s_HexMask

        {

            bmd = new BitmapData(BMD_W, BMD_H, true, 0x00000000);



            bmd.lock();



            //Center Rect

            for(xx = center_x - 2*block_offset; xx < center_x + 2*block_offset; ++xx){

                for(yy = center_y - 3*BLOCK_W; yy < center_y + 3*BLOCK_W; ++yy){

                    bmd.setPixel32(xx, yy, 0xFF00FF00);

                }

            }



            //Triangle*4

            var tri_w:int = 2*block_offset;

            var tri_h:int = 3*BLOCK_W;

            var base_x:int, base_y:int;

            for(xx = 0; xx < tri_w; ++xx){

                for(yy = 0; yy < tri_h; ++yy){

                    var flag:Boolean = (yy < xx * tri_h/tri_w);

                    if(flag){

                        //UL

                        base_x = center_x - 4*block_offset + 1;

                        base_y = center_y - 1;

                        bmd.setPixel32(base_x + xx, base_y - yy, 0xFF00FF00);

                        //UR

                        base_x = center_x + 4*block_offset - 1;

                        base_y = center_y - 1;

                        bmd.setPixel32(base_x - xx, base_y - yy, 0xFF00FF00);

                    }else{

                        //DR

                        base_x = center_x - 4*block_offset + 1    + 1*OFFSET_X;

                        base_y = center_y - 1                    + 1*OFFSET_Y + 0*6*BLOCK_W;

                        bmd.setPixel32(base_x + xx, base_y - yy, 0xFF00FF00);

                        //DL

                        base_x = center_x + 4*block_offset - 1    - 1*OFFSET_X;

                        base_y = center_y - 1                    - 1*OFFSET_Y + 1*6*BLOCK_W;

                        bmd.setPixel32(base_x - xx, base_y - yy, 0xFF00FF00);

                    }

                }

            }



            bmd.unlock();



            s_HexMask = bmd;

        }



        //s_HexNegaMask

        {

            bmd = new BitmapData(BMD_W, BMD_H, true, 0x00000000);



            bmd.lock();



            for(xx = 0; xx < s_HexMask.width; ++xx){

                for(yy = 0; yy < s_HexMask.height; ++yy){

                    bmd.setPixel32(xx, yy, s_HexMask.getPixel32(xx, yy) ^ 0xFF000000);

                }

            }



            bmd.unlock();



            s_HexNegaMask = bmd;

        }

    }



    //Init

    public function HexBlock(){

        var i:int, j:int;



        //m_EdgeConnection

        {

            m_EdgeConnection = new Vector.<Vector.<Connection> >(Connection.DIR_NUM);

            for(i = 0; i < Connection.DIR_NUM; ++i){

                m_EdgeConnection[i] = new Vector.<Connection>(Connection.DIR_NUM);

                for(j = 0; j < Connection.DIR_NUM; ++j){

                    m_EdgeConnection[i][j] = null;

                }

            }

        }



        //m_BaseConnection

        {

            m_BaseConnection = new Vector.<Connection>(Connection.DIR_NUM);

            for(i = 0; i < Connection.DIR_NUM; ++i){

                m_BaseConnection[i] = null;

            }

        }

    }

    public function Reset(in_X:int, in_Y:int, in_MapVal:uint):void{

        //Param

        m_BaseX = in_X * OFFSET_X;

        m_BaseY = in_X * OFFSET_Y + in_Y * BLOCK_W*6;

        m_MapVal = in_MapVal;



        //BasePos

        var center_x:Number = m_BaseX + BMD_W/2;

        var center_y:Number = m_BaseY + BMD_H/2;



        //Reset

        if(in_MapVal < 0x40){

            Reset_Graphic_Normal(m_BaseX, m_BaseY);

            Reset_Connection_Normal(center_x, center_y);

        }else{

            Reset_Graphic_Cross(m_BaseX, m_BaseY);

            Reset_Connection_Cross(center_x, center_y);

        }

    }

    //Init - Graphic - Normal

    public function Reset_Graphic_Normal(in_BaseX:int, in_BaseY:int):void{

        //Check Empty

        if(m_MapVal == 0){

            return;

        }



        //Param

        var rect:Rectangle = new Rectangle(0, 0, BMD_W, BMD_H);

        var pos:Point = new Point(in_BaseX, in_BaseY);



        //Alias

        var bmd_layer_f:BitmapData = SakusiWonderfl.Instance.m_BitmapData_BackGroundF;

        var bmd_layer_b:BitmapData = SakusiWonderfl.Instance.m_BitmapData_BackGroundB;

        var u:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_U) != 0x00000000);

        var d:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_D) != 0x00000000);

        var l:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_L) != 0x00000000);

        var r:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_R) != 0x00000000);

        var f:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_F) != 0x00000000);

        var b:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_B) != 0x00000000);



        //Draw

        //- Base

        bmd_layer_b.copyPixels(s_BitmapData_Base, rect, pos, s_HexMask, null, true);

        //- 境界線：奥

        if(!u && !l){bmd_layer_b.copyPixels(s_BitmapData[DIR_UL], rect, pos, s_HexMask, null, true);}

        if(!u && !b){bmd_layer_b.copyPixels(s_BitmapData[DIR_UB], rect, pos, s_HexMask, null, true);}

        if(!f && !l){bmd_layer_b.copyPixels(s_BitmapData[DIR_FL], rect, pos, s_HexMask, null, true);}

        if(!f && !d){bmd_layer_b.copyPixels(s_BitmapData[DIR_FD], rect, pos, s_HexMask, null, true);}

        if(!r && !b){bmd_layer_b.copyPixels(s_BitmapData[DIR_RB], rect, pos, s_HexMask, null, true);}

        if(!r && !d){bmd_layer_b.copyPixels(s_BitmapData[DIR_RD], rect, pos, s_HexMask, null, true);}

        //- ブロック

        if(u){bmd_layer_f.copyPixels(s_BitmapData[DIR_U], rect, pos, s_HexMask, null, true);}

        if(r){bmd_layer_f.copyPixels(s_BitmapData[DIR_R], rect, pos, s_HexMask, null, true);}

        if(f){bmd_layer_f.copyPixels(s_BitmapData[DIR_F], rect, pos, s_HexMask, null, true);}

        if(d){bmd_layer_b.copyPixels(s_BitmapData[DIR_D], rect, pos, s_HexMask, null, true);}

        if(l){bmd_layer_b.copyPixels(s_BitmapData[DIR_L], rect, pos, s_HexMask, null, true);}

        if(b){bmd_layer_b.copyPixels(s_BitmapData[DIR_B], rect, pos, s_HexMask, null, true);}

        //- 境界線：手前

        if((r && f) || (!r && !f)){bmd_layer_b.copyPixels(s_BitmapData[DIR_FR], rect, pos, s_HexMask, null, true);}

        if((r && u) || (!r && !u)){bmd_layer_b.copyPixels(s_BitmapData[DIR_UR], rect, pos, s_HexMask, null, true);}

        if((u && f) || (!u && !f)){bmd_layer_b.copyPixels(s_BitmapData[DIR_UF], rect, pos, s_HexMask, null, true);}

    }

    //Init - Graphic - Cross

    public function Reset_Graphic_Cross(in_BaseX:int, in_BaseY:int):void{

        var rect:Rectangle = new Rectangle(0, 0, BMD_W, BMD_H);

        var pos:Point = new Point(in_BaseX, in_BaseY);



        //Alias

        var bmd_layer_f:BitmapData = SakusiWonderfl.Instance.m_BitmapData_BackGroundF;

        var bmd_layer_b:BitmapData = SakusiWonderfl.Instance.m_BitmapData_BackGroundB;



        //Draw

        //- Base

        bmd_layer_f.copyPixels(s_BitmapData_Base, rect, pos, s_HexMask, null, true);

        //- 

        switch(m_MapVal){

        case SakusiWonderfl.xFB_LR:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_F], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_B], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UL], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_RD], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UR], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_R], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_L], rect, pos, s_HexMask, null, true);

            break;

        case SakusiWonderfl.xFB_UD:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_F], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_B], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UL], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_RD], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UR], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_U], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_D], rect, pos, s_HexMask, null, true);

            break;

        case SakusiWonderfl.xLR_FB:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_R], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_L], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UB], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FD], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UF], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_F], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_B], rect, pos, s_HexMask, null, true);

            break;

        case SakusiWonderfl.xLR_UD:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_R], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_L], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UB], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FD], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_UF], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_U], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_D], rect, pos, s_HexMask, null, true);

            break;

        case SakusiWonderfl.xUD_FB:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_U], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_D], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FL], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_RB], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FR], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_F], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_B], rect, pos, s_HexMask, null, true);

            break;

        case SakusiWonderfl.xUD_LR:

            bmd_layer_f.copyPixels(s_BitmapData[DIR_U], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_D], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FL], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_RB], rect, pos, s_HexMask, null, true);

            bmd_layer_f.copyPixels(s_BitmapData[DIR_FR], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_R], rect, pos, s_HexMask, null, true);

            bmd_layer_b.copyPixels(s_BitmapData[DIR_L], rect, pos, s_HexMask, null, true);

            break;

        }

    }

    //Init - Connection - Normal

    public function Reset_Connection_Normal(in_CenterX:int, in_CenterY:int):void{

        //Alias

        var u:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_U) != 0x00000000);

        var d:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_D) != 0x00000000);

        var l:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_L) != 0x00000000);

        var r:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_R) != 0x00000000);

        var f:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_F) != 0x00000000);

        var b:Boolean = ((m_MapVal & SakusiWonderfl.FLAG_B) != 0x00000000);

        var sprite_layer_b:Sprite = SakusiWonderfl.Instance.m_Layer_BlockB;

        var sprite_layer_c:Sprite = SakusiWonderfl.Instance.m_Layer_BlockC;

        var sprite_layer_f:Sprite = SakusiWonderfl.Instance.m_Layer_BlockF;



        //該当方向にブロックが伸びてない場合の共用コネクション

        var connection_u:Connection = u? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_U]), sprite_layer_f);

        var connection_d:Connection = d? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_D]), sprite_layer_b);

        var connection_l:Connection = l? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_L]), sprite_layer_b);

        var connection_r:Connection = r? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_R]), sprite_layer_f);

        var connection_f:Connection = f? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_F]), sprite_layer_f);

        var connection_b:Connection = b? null: new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [Connection.DIR_B]), sprite_layer_b);



        //２つの方向をペアとして考えつつ繋げていく

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_L, connection_u, connection_l);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_R, connection_u, connection_r);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_F, connection_u, connection_f);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_B, connection_u, connection_b);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_D, Connection.DIR_L, connection_d, connection_l);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_D, Connection.DIR_R, connection_d, connection_r);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_D, Connection.DIR_F, connection_d, connection_f);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_D, Connection.DIR_B, connection_d, connection_b);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_L, Connection.DIR_F, connection_l, connection_f);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_F, Connection.DIR_R, connection_f, connection_r);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_R, Connection.DIR_B, connection_r, connection_b);

        Reset_Connection_Normal_Pair(in_CenterX, in_CenterY, Connection.DIR_B, Connection.DIR_L, connection_b, connection_l);



        //スタート位置やゴール位置で使うので記憶

        m_BaseConnection[Connection.DIR_U] = connection_u;

        m_BaseConnection[Connection.DIR_D] = connection_d;

        m_BaseConnection[Connection.DIR_L] = connection_l;

        m_BaseConnection[Connection.DIR_R] = connection_r;

        m_BaseConnection[Connection.DIR_F] = connection_f;

        m_BaseConnection[Connection.DIR_B] = connection_b;

    }

    public function Reset_Connection_Normal_Pair(in_CenterX:int, in_CenterY:int, in_DirA:int, in_DirB:int, in_CommonConnectionA:Connection, in_CommonConnectionB:Connection):void{

        //Alias

        var sprite_layer_b:Sprite = SakusiWonderfl.Instance.m_Layer_BlockB;

        var sprite_layer_c:Sprite = SakusiWonderfl.Instance.m_Layer_BlockC;

        var sprite_layer_f:Sprite = SakusiWonderfl.Instance.m_Layer_BlockF;



        //Layer

        const LAYER_VAL:Vector.<int> = new <int>[

            1,//DIR_F

            0,//DIR_B

            0,//DIR_L

            1,//DIR_R

            1,//DIR_U

            0,//DIR_D

        ];

        const LAYER_SPRITE:Vector.<Sprite> = new <Sprite>[

            SakusiWonderfl.Instance.m_Layer_BlockB,

            SakusiWonderfl.Instance.m_Layer_BlockC,

            SakusiWonderfl.Instance.m_Layer_BlockF,

        ];

        var sprite_layer:Sprite = LAYER_SPRITE[LAYER_VAL[in_DirA] + LAYER_VAL[in_DirB]];

        //Edge : A & B

        var edge_connection_a:Connection = (in_CommonConnectionA == null)? new Connection(this, in_DirA,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA,in_DirA,in_DirB]), sprite_layer): null;

        var edge_connection_b:Connection = (in_CommonConnectionB == null)? new Connection(this, in_DirB,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, [in_DirB,in_DirB,in_DirA]), sprite_layer): null;

        m_EdgeConnection[in_DirA][in_DirB] = edge_connection_a;

        m_EdgeConnection[in_DirB][in_DirA] = edge_connection_b;

        //U,F,Rはもうひとつ伸ばす

        if(edge_connection_a != null && (in_DirA == Connection.DIR_U || in_DirA == Connection.DIR_F || in_DirA == Connection.DIR_R)){

            m_EdgeConnection[in_DirA][in_DirB] = new Connection(this, in_DirA,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA,in_DirA,in_DirA,in_DirB]), sprite_layer);

            edge_connection_a.Link(m_EdgeConnection[in_DirA][in_DirB], in_DirA, in_DirB);

        }

        if(edge_connection_b != null && (in_DirB == Connection.DIR_U || in_DirB == Connection.DIR_F || in_DirB == Connection.DIR_R)){

            m_EdgeConnection[in_DirB][in_DirA] = new Connection(this, in_DirB,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, [in_DirB,in_DirB,in_DirB,in_DirA]), sprite_layer);

            edge_connection_b.Link(m_EdgeConnection[in_DirB][in_DirA], in_DirB, in_DirA);

        }



        if(edge_connection_a == null && edge_connection_b == null){

            //どちらも伸びてないので相互に移動することはない

            return;

        }



        if(edge_connection_a != null && edge_connection_b != null){

            //どちらも伸びている



            var corner_connection:Connection = new Connection(this, -1,-1, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA,in_DirB]), sprite_layer);

            corner_connection.Link(edge_connection_a, in_DirA, in_DirB);

            corner_connection.Link(edge_connection_b, in_DirB, in_DirA);



            return;

        }



        //片方だけ伸びている

        var sprite_layer_straight:Sprite = sprite_layer;

        if(sprite_layer_straight == sprite_layer_c){

            if(edge_connection_a != null){

                if(LAYER_VAL[in_DirB] == 0){

                    sprite_layer_straight = sprite_layer_b;

                }

            }else{

                if(LAYER_VAL[in_DirA] == 0){

                    sprite_layer_straight = sprite_layer_b;

                }

            }

        }

        var straight_connection:Connection;

        if(edge_connection_a != null){

            straight_connection = new Connection(this, in_DirA,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA,in_DirB]), sprite_layer_straight);

            in_CommonConnectionB.Link(straight_connection,    in_DirA, in_DirB);

            straight_connection.Link(edge_connection_a,        in_DirA, in_DirB);

        }else{

            straight_connection = new Connection(this, in_DirB,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA,in_DirB]), sprite_layer_straight);

            in_CommonConnectionA.Link(straight_connection,    in_DirB, in_DirA);

            straight_connection.Link(edge_connection_b,        in_DirB, in_DirA);

        }

    }

    //Init - Connection - Cross

    public function Reset_Connection_Cross(in_CenterX:int, in_CenterY:int):void{

        switch(m_MapVal){

        case SakusiWonderfl.xFB_LR:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_F, Connection.DIR_L, Connection.DIR_U);

            break;

        case SakusiWonderfl.xFB_UD:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_F, Connection.DIR_D, Connection.DIR_R);

            break;

        case SakusiWonderfl.xLR_FB:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_R, Connection.DIR_B, Connection.DIR_U);

            break;

        case SakusiWonderfl.xLR_UD:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_R, Connection.DIR_D, Connection.DIR_F);

            break;

        case SakusiWonderfl.xUD_FB:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_B, Connection.DIR_R);

            break;

        case SakusiWonderfl.xUD_LR:

            Reset_Connection_Cross_3Dir(in_CenterX, in_CenterY, Connection.DIR_U, Connection.DIR_L, Connection.DIR_F);

            break;

        }



        //!!Crossでもスタートやゴールを使う場合、m_BaseConnectionをセットする必要がある

    }

    public function Reset_Connection_Cross_3Dir(in_CenterX:int, in_CenterY:int, in_DirA:int, in_DirB:int, in_DirC:int):void{

        var i:int;

        var iter_prev:Connection;

        var iter_next:Connection;

        var common_connection_a:Connection;

        var common_connection_b:Connection;

        var dir_arr:Array;



        //Alias

        var sprite_layer_b:Sprite = SakusiWonderfl.Instance.m_Layer_BlockB;

        var sprite_layer_c:Sprite = SakusiWonderfl.Instance.m_Layer_BlockC;

        var sprite_layer_f:Sprite = SakusiWonderfl.Instance.m_Layer_BlockF;



        //一番手前

        dir_arr = [in_DirC,in_DirA,in_DirA,in_DirA];

        iter_prev = m_EdgeConnection[in_DirA][in_DirC] = new Connection(this, in_DirA,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirA^0x1);

            iter_next = new Connection(this, (i < 2)? in_DirA: in_DirA^0x1,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

            iter_prev.Link(iter_next, in_DirA^0x1, in_DirC);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirA^0x1);

        m_EdgeConnection[in_DirA^0x1][in_DirC] = new Connection(this, in_DirA^0x1,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

        iter_prev.Link(m_EdgeConnection[in_DirA^0x1][in_DirC], in_DirA^0x1, in_DirC);

        //少し手前

        //-- A

        dir_arr = [in_DirB,in_DirA^0x1,in_DirA^0x1];

        iter_prev = m_EdgeConnection[in_DirA^0x1][in_DirB] = new Connection(this, in_DirA^0x1,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirA);

            iter_next = new Connection(this, (i < 2)? in_DirA^0x1: in_DirA,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

            if(i == 0){common_connection_a = iter_next;}

            iter_prev.Link(iter_next, in_DirA, in_DirB);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirA);

        m_EdgeConnection[in_DirA][in_DirB] = new Connection(this, in_DirA,in_DirB, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

        iter_prev.Link(m_EdgeConnection[in_DirA][in_DirB], in_DirA, in_DirB);

        //-- B

        dir_arr = [in_DirB^0x1,in_DirA^0x1,in_DirA^0x1];

        iter_prev = m_EdgeConnection[in_DirA^0x1][in_DirB^0x1] = new Connection(this, in_DirA^0x1,in_DirB^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirA);

            iter_next = new Connection(this, (i < 2)? in_DirA^0x1: in_DirA,in_DirB^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

            if(i == 0){common_connection_b = iter_next;}

            iter_prev.Link(iter_next, in_DirA, in_DirB^0x1);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirA);

        m_EdgeConnection[in_DirA][in_DirB^0x1] = new Connection(this, in_DirA,in_DirB^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_f);

        iter_prev.Link(m_EdgeConnection[in_DirA][in_DirB^0x1], in_DirA, in_DirB^0x1);

        //-- A

        iter_next = new Connection(this, in_DirB,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA^0x1,in_DirB,in_DirB]), sprite_layer_c);

        common_connection_a.Link(iter_next, in_DirB, in_DirC);

        m_EdgeConnection[in_DirB][in_DirC] = new Connection(this, in_DirB,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA^0x1,in_DirB,in_DirB,in_DirB]), sprite_layer_c);

        iter_next.Link(m_EdgeConnection[in_DirB][in_DirC], in_DirB, in_DirC);

        //-- B

        m_EdgeConnection[in_DirB^0x1][in_DirC] = new Connection(this, in_DirB^0x1,in_DirC, CalcCenterPos(in_CenterX, in_CenterY, [in_DirA^0x1,in_DirB^0x1,in_DirB^0x1]), sprite_layer_f);

        m_EdgeConnection[in_DirB^0x1][in_DirC].Link(common_connection_b, in_DirB, in_DirC);

        //少し奥

        //-- A

        dir_arr = [in_DirC^0x1,in_DirB^0x1,in_DirB^0x1];

        iter_prev = m_EdgeConnection[in_DirB^0x1][in_DirA] = new Connection(this, in_DirB^0x1,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirB);

            iter_next = new Connection(this, (i < 2)? in_DirB^0x1: in_DirB,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

            if(i == 1){common_connection_a = iter_next;}

            iter_prev.Link(iter_next, in_DirB, in_DirA);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirB);

        m_EdgeConnection[in_DirB][in_DirA] = new Connection(this, in_DirB,in_DirA, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_c);

        iter_prev.Link(m_EdgeConnection[in_DirB][in_DirA], in_DirB, in_DirA);

        //-- B

        dir_arr = [in_DirC^0x1,in_DirB^0x1,in_DirB^0x1,in_DirA^0x1,in_DirA^0x1];

        iter_prev = m_EdgeConnection[in_DirB^0x1][in_DirA^0x1] = new Connection(this, in_DirB^0x1,in_DirA^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirB);

            iter_next = new Connection(this, (i < 2)? in_DirB^0x1: in_DirB,in_DirA^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

            if(i == 1){common_connection_b = iter_next;}

            iter_prev.Link(iter_next, in_DirB, in_DirA^0x1);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirB);

        m_EdgeConnection[in_DirB][in_DirA^0x1] = new Connection(this, in_DirB,in_DirA^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

        iter_prev.Link(m_EdgeConnection[in_DirB][in_DirA^0x1], in_DirB, in_DirA^0x1);

        //-- A

        iter_prev = new Connection(this, in_DirA,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, [in_DirC^0x1,in_DirA]), sprite_layer_c);

        iter_next = new Connection(this, in_DirA,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, [in_DirC^0x1,in_DirA,in_DirA]), sprite_layer_c);

        common_connection_a.Link(iter_prev, in_DirA, in_DirC^0x1);

        iter_prev.Link(iter_next, in_DirA, in_DirC^0x1);

        m_EdgeConnection[in_DirA][in_DirC^0x1] = new Connection(this, in_DirA,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, [in_DirC^0x1,in_DirA,in_DirA,in_DirA]), sprite_layer_c);

        iter_next.Link(m_EdgeConnection[in_DirA][in_DirC^0x1], in_DirA, in_DirC^0x1);

        //-- B

//        m_EdgeConnection[in_DirA^0x1][in_DirC^0x1] = new Connection(this, in_DirA^0x1,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, [in_DirC^0x1,in_DirA^0x1,in_DirA^0x1]), sprite_layer_b);

//        m_EdgeConnection[in_DirA^0x1][in_DirC^0x1].Link(common_connection_b, in_DirA, in_DirC^0x1);

        m_EdgeConnection[in_DirA^0x1][in_DirC^0x1] = common_connection_b;

        //一番奥

        dir_arr = [in_DirA^0x1,in_DirC^0x1,in_DirC^0x1,in_DirB^0x1,in_DirB^0x1];

        iter_prev = m_EdgeConnection[in_DirB^0x1][in_DirC^0x1] = new Connection(this, in_DirB^0x1,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

        for(i = 0; i < 4; ++i){

            dir_arr.push(in_DirB);

            iter_next = new Connection(this, (i < 2)? in_DirB^0x1: in_DirB,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

            iter_prev.Link(iter_next, in_DirB, in_DirC ^ 0x1);

            iter_prev = iter_next;

        }

        dir_arr.push(in_DirB);

        m_EdgeConnection[in_DirB][in_DirC^0x1] = new Connection(this, in_DirB,in_DirC^0x1, CalcCenterPos(in_CenterX, in_CenterY, dir_arr), sprite_layer_b);

        iter_prev.Link(m_EdgeConnection[in_DirB][in_DirC^0x1], in_DirB, in_DirC^0x1);

    }



    //Connection : Another

    public function Connect(in_Another:HexBlock, in_ConnectDir:int):void{

        for(var plane_dir:int = 0; plane_dir < Connection.DIR_NUM; ++plane_dir){

            //Edge

            var edge_connection:Connection = m_EdgeConnection[in_ConnectDir][plane_dir];

            if(edge_connection == null){continue;}



            //Another Edge

            var another_edge_connection:Connection = in_Another.m_EdgeConnection[in_ConnectDir ^ 0x1][plane_dir];

            if(another_edge_connection == null){continue;}



            //Link

            edge_connection.Link(another_edge_connection, in_ConnectDir, plane_dir);

        }

    }



    //Uti; : CalcPos

    public function CalcCenterPos(in_CenterX:Number, in_CenterY:Number, in_DirArr:Array):Point{

        //Alias

        var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



        //Base

        var pos:Point = new Point(in_CenterX, in_CenterY);



        //Offset

        var num:int = in_DirArr.length;

        for(var i:int = 0; i < num; ++i){

            var dir:int = in_DirArr[i];

            switch(dir){

            case Connection.DIR_U: pos.y -= BLOCK_W; break;

            case Connection.DIR_D: pos.y += BLOCK_W; break;

            case Connection.DIR_L: pos.x -= block_offset; pos.y -= BLOCK_W/2; break;

            case Connection.DIR_R: pos.x += block_offset; pos.y += BLOCK_W/2; break;

            case Connection.DIR_F: pos.x -= block_offset; pos.y += BLOCK_W/2; break;

            case Connection.DIR_B: pos.x += block_offset; pos.y -= BLOCK_W/2; break;

            }

        }



        return pos;

    }

}





class Connection

{

    //==Const==



    //Dir

    static public var s_DirIter:int = 0;

    static public const DIR_F    :int = s_DirIter++;

    static public const DIR_B    :int = s_DirIter++;

    static public const DIR_L    :int = s_DirIter++;

    static public const DIR_R    :int = s_DirIter++;

    static public const DIR_U    :int = s_DirIter++;

    static public const DIR_D    :int = s_DirIter++;

    static public const DIR_NUM    :int = s_DirIter;





    //==Var==



    //どのHexMapに所属するか

    public var m_HexMap:HexBlock;



    //どの方向のHexMapと接続するのが近いか（同じくらいなら-1）

    public var m_BaseDir:int = -1;

    public var m_PlaneDir:int = -1;



    //プレイヤーの中心位置の対応位置

    public var m_CenterX:Number;

    public var m_CenterY:Number;



    //ここに居る時のプレイヤーのレイヤー

    public var m_BlockLayer:Sprite;



    //他のConnectionとの相互リンク

    public var m_Link:Vector.<Vector.<Connection> >;//[BaseDir][PlaneNrmDir]





    //==Function==



    //Init

    public function Connection(in_HexMap:HexBlock, in_BaseDir:int, in_PlaneDir:int, in_CenterPos:Point, in_BlockLayer:Sprite){

        var i:int, j:int;



        //Parent

        {

            m_HexMap = in_HexMap;

        }



        //Dir

        {

            m_BaseDir = in_BaseDir;

            m_PlaneDir = in_PlaneDir;

        }



        //Pos

        {

            SetPos(in_CenterPos.x, in_CenterPos.y);

        }



        //Layer

        {

            m_BlockLayer = in_BlockLayer;

        }



        //m_Link

        {

            m_Link = new Vector.<Vector.<Connection> >(DIR_NUM);

            for(i = 0; i < DIR_NUM; ++i){

                m_Link[i] = new Vector.<Connection>(DIR_NUM);

                for(j = 0; j < DIR_NUM; ++j){

                    m_Link[i][j] = null;//no link

                }

            }

        }

    }



    //Pos

    public function SetPos(in_CenterX:Number, in_CenterY:Number):void{

        m_CenterX = in_CenterX;

        m_CenterY = in_CenterY;

    }



    //Link

    public function Link(in_Another:Connection, in_BaseDir:int, in_PlaneNrmDir:int):void{

        //this => another

        m_Link[in_BaseDir][in_PlaneNrmDir] = in_Another;



        //another => this

        in_Another.m_Link[in_BaseDir ^ 0x1][in_PlaneNrmDir] = this;

    }

}





class Player extends Sprite

{

    //==Const==



    //回転方向

    static public var s_RotIter:int = 0;

    static public const ROT_X_P:int = s_RotIter++;

    static public const ROT_X_M:int = s_RotIter++;

    static public const ROT_Y_P:int = s_RotIter++;

    static public const ROT_Y_M:int = s_RotIter++;

    static public const ROT_Z_P:int = s_RotIter++;

    static public const ROT_Z_M:int = s_RotIter++;

    static public const ROT_NUM:int = s_RotIter;



    //回転を何フレームで行うか

    static public const TOTAL_ROT_FRAME:int = 4;





    //==Static==



    //回転画像（パラパラマンガ風）

    static public var s_RotBitmapData:Vector.<Vector.<BitmapData> >;

    //回転時のズレ

    static public var s_RotOffset:Vector.<Vector.<Point> >;



    //用意する画像サイズ

    static public var BITMAP_W:int;





    //==Var==



    //Graphics

    //- 回転のたびに更新される基本画像

    public var m_BitmapData:BitmapData;

    //- 本体ブロック（HexMapをまたぐ際の整合性維持のため２つ用いてマスキングで切り替える）

    public var m_Sprite_Prev:Sprite = new Sprite();

    public var m_Sprite_Next:Sprite = new Sprite();

    public var m_BitmapData_Prev:BitmapData;

    public var m_BitmapData_Next:BitmapData;

    //- マスキング用Shape（HexMapのネガマスク）

    public var m_Mask_Prev:Bitmap;

    public var m_Mask_Next:Bitmap;



    //Move

    //- 一つ前のConnection

    public var m_Connection_Prev:Connection = null;

    //- 次のConnection

    public var m_Connection_Next:Connection = null;

    //- 移動フレーム

    public var m_RotFrame:int = 0;

    //- 回転によるズレ

    public var m_PosOffset:Point = new Point();

    //- 回転ズレの適用方向

    public var m_NextPlaneDir:int = -1;



    //Rotate

    //- 現在実行中の回転

    public var m_RotateIndex:int = -1;

    //- ボタンの現在の設定

    public var m_RotateIndex_Trg:int = -1;





    //==Function==



    //Static Init

    static public function StaticInit():void{

        //BITMAP_W

        {

            BITMAP_W = 3*HexBlock.BLOCK_W;

        }



        //s_RotBitmapData

        {

            const LINE_W:int = 2;//2;

            const LINE_COLOR:uint = 0x000000;//0xFF0000;

            const LINE_ALPHA:Number = 1.0;

            const BLOCK_COLOR:uint = 0xFF0000;



            const BLOCK_W:int = HexBlock.BLOCK_W;

            var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



            const lub:Vector3D = new Vector3D(-BLOCK_W/2, -BLOCK_W/2, -BLOCK_W/2);

            const rub:Vector3D = new Vector3D( BLOCK_W/2, -BLOCK_W/2, -BLOCK_W/2);

            const ldb:Vector3D = new Vector3D(-BLOCK_W/2,  BLOCK_W/2, -BLOCK_W/2);

            const rdb:Vector3D = new Vector3D( BLOCK_W/2,  BLOCK_W/2, -BLOCK_W/2);

            const luf:Vector3D = new Vector3D(-BLOCK_W/2, -BLOCK_W/2,  BLOCK_W/2);

            const ruf:Vector3D = new Vector3D( BLOCK_W/2, -BLOCK_W/2,  BLOCK_W/2);

            const ldf:Vector3D = new Vector3D(-BLOCK_W/2,  BLOCK_W/2,  BLOCK_W/2);

            const rdf:Vector3D = new Vector3D( BLOCK_W/2,  BLOCK_W/2,  BLOCK_W/2);

            const PLANE_ARR:Vector.<Vector.<Vector3D> > = new <Vector.<Vector3D> >[

                new <Vector3D>[luf, ruf, rdf, ldf],//DIR_F

                new <Vector3D>[rub, lub, ldb, rdb],//DIR_B

                new <Vector3D>[lub, luf, ldf, ldb],//DIR_L

                new <Vector3D>[ruf, rub, rdb, rdf],//DIR_R

                new <Vector3D>[lub, rub, ruf, luf],//DIR_U

                new <Vector3D>[ldf, rdf, rdb, ldb],//DIR_D

            ];



            var shape:Shape = new Shape();

            var g:Graphics = shape.graphics;



            s_RotBitmapData    = new Vector.<Vector.<BitmapData> >(ROT_NUM);

            for(var r:int = 0; r < ROT_NUM; ++r){//各回転方向のアニメの用意

                s_RotBitmapData[r]    = new Vector.<BitmapData>(TOTAL_ROT_FRAME);



                var axis_rot:Vector3D;

                switch(r){

                case ROT_Y_P: axis_rot = new Vector3D( 0,-1, 0); break;

                case ROT_Y_M: axis_rot = new Vector3D( 0, 1, 0); break;

                case ROT_X_P: axis_rot = new Vector3D( 1, 0, 0); break;

                case ROT_X_M: axis_rot = new Vector3D(-1, 0, 0); break;

                case ROT_Z_P: axis_rot = new Vector3D( 0, 0,-1); break;

                case ROT_Z_M: axis_rot = new Vector3D( 0, 0, 1); break;

                }



                for(var f:int = 0; f < TOTAL_ROT_FRAME; ++f){//回転のフレームの数だけ用意

                    var bmd:BitmapData = new BitmapData(BITMAP_W, BITMAP_W, true, 0x00000000);

                    {

                        //回転

                        var degrees:Number = 90 * (f + 1) / TOTAL_ROT_FRAME;

                        var mtx:Matrix3D = new Matrix3D();

                        //- 回転移動用の回転

                        mtx.appendRotation(degrees, axis_rot);

                        //- 表示用の基本回転

                        mtx.appendRotation(45, Vector3D.Y_AXIS);

                        mtx.appendRotation(45, Vector3D.X_AXIS);



                        for(var p:int = 0; p < Connection.DIR_NUM; ++p){//それぞれの面を描く

                            var point_num:int = PLANE_ARR[p].length;

                            var plane:Vector.<Vector3D> = new Vector.<Vector3D>(point_num);



                            for(var v:int = 0; v < point_num; ++v){

                                plane[v] = mtx.transformVector(PLANE_ARR[p][v]);

                            }



                            //面の向きによるクリッピング

                            var dot:Number;

                            {

    /*

                                var dir_a:Vector3D = plane[1].subtract(plane[0]);

                                var dir_b:Vector3D = plane[2].subtract(plane[1]);

                                dot = dir_a.dotProduct(dir_b);

    /*/

                                dot = -(plane[0].z + plane[2].z) / 2;//

    //*/

                            }



                            if(0 <= dot){

                                g.clear();

                                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);



                                g.beginFill(BLOCK_COLOR, 1.0);

                                g.moveTo(BITMAP_W/2 + plane[0].x, BITMAP_W/2 + plane[0].y);

                                g.lineTo(BITMAP_W/2 + plane[1].x, BITMAP_W/2 + plane[1].y);

                                g.lineTo(BITMAP_W/2 + plane[2].x, BITMAP_W/2 + plane[2].y);

                                g.lineTo(BITMAP_W/2 + plane[3].x, BITMAP_W/2 + plane[3].y);

                                g.lineTo(BITMAP_W/2 + plane[0].x, BITMAP_W/2 + plane[0].y);

                                g.endFill();



                                bmd.draw(shape);

                            }

                        }

                    }



                    s_RotBitmapData[r][f]    = bmd;

                }

            }

        }



        //s_RotOffset

        {

            s_RotOffset = new Vector.<Vector.<Point> >(Connection.DIR_NUM);

            for(var d:int = 0; d < Connection.DIR_NUM; ++d){

                s_RotOffset[d] = new Vector.<Point>(TOTAL_ROT_FRAME);



                var offset_dir:Point = new Point();

                switch(d){

                case Connection.DIR_F: offset_dir.x = -block_offset; offset_dir.y =  BLOCK_W/2; break;

                case Connection.DIR_B: offset_dir.x =  block_offset; offset_dir.y = -BLOCK_W/2; break;

                case Connection.DIR_L: offset_dir.x = -block_offset; offset_dir.y = -BLOCK_W/2; break;

                case Connection.DIR_R: offset_dir.x =  block_offset; offset_dir.y =  BLOCK_W/2; break;

                case Connection.DIR_U: offset_dir.y = -BLOCK_W; break;

                case Connection.DIR_D: offset_dir.y =  BLOCK_W; break;

                }



                for(f = 0; f < TOTAL_ROT_FRAME; ++f){

                    var theta:Number = Math.PI/4 + Math.PI/2 * (f+1)/TOTAL_ROT_FRAME;



                    //

                    var rot_offset:Point = new Point();

                    {

                        var offset:Number = Math.sqrt(2)/2 * Math.sin(theta) - 0.5;



                        rot_offset.x = offset * offset_dir.x;

                        rot_offset.y = offset * offset_dir.y;

                    }



                    s_RotOffset[d][f] = rot_offset;

                }

            }

        }

    }



    //Init

    public function Player():void{

        var i:int, j:int;

        var shape:Shape;

        var g:Graphics;



        //!!仮

        //m_Sprite_Prev, m_Sprite_Next

        {

/*

            const LINE_W:int = 2;

            const LINE_COLOR:uint = 0xFF0000;

            const LINE_ALPHA:Number = 1.0;

            const BLOCK_COLOR:uint = 0xFFFFFF;



            const BLOCK_W:int = HexBlock.BLOCK_W;

            var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



            for(i = 0; i < 2; ++i){

                shape = new Shape();

                g = shape.graphics;



                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                //- Frame

                g.beginFill(BLOCK_COLOR, 1.0);

                g.moveTo(0, -BLOCK_W);

                g.lineTo( block_offset, -BLOCK_W/2);

                g.lineTo( block_offset,  BLOCK_W/2);

                g.lineTo(0,  BLOCK_W);

                g.lineTo(-block_offset,  BLOCK_W/2);

                g.lineTo(-block_offset, -BLOCK_W/2);

                g.lineTo(0, -BLOCK_W);

                g.endFill();

                //- Line

                g.moveTo(0, 0);

                g.lineTo(0, BLOCK_W);

                g.moveTo(0, 0);

                g.lineTo( block_offset, -BLOCK_W/2);

                g.moveTo(0, 0);

                g.lineTo(-block_offset, -BLOCK_W/2);



                if(i == 0){

                    m_Sprite_Prev.addChild(shape);

                }else{

                    m_Sprite_Next.addChild(shape);

                }

            }

/*/

            const LINE_W:int = 2;

            const LINE_COLOR:uint = 0x008888;//0xFF0000;

            const LINE_ALPHA:Number = 1.0;

            const BLOCK_COLOR:uint = 0xFFFFFF;



            const BLOCK_W:int = HexBlock.BLOCK_W;

            var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



            {

                shape = new Shape();

                g = shape.graphics;



//*

                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                //- Frame

                g.beginFill(BLOCK_COLOR, 1.0);

                g.moveTo(0, -BLOCK_W);

                g.lineTo( block_offset, -BLOCK_W/2);

                g.lineTo( block_offset,  BLOCK_W/2);

                g.lineTo(0,  BLOCK_W);

                g.lineTo(-block_offset,  BLOCK_W/2);

                g.lineTo(-block_offset, -BLOCK_W/2);

                g.lineTo(0, -BLOCK_W);

                g.endFill();

                //- Line

                g.moveTo(0, 0);

                g.lineTo(0, BLOCK_W);

                g.moveTo(0, 0);

                g.lineTo( block_offset, -BLOCK_W/2);

                g.moveTo(0, 0);

                g.lineTo(-block_offset, -BLOCK_W/2);

/*/

                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                //- Frame

                g.beginFill(BLOCK_COLOR, 1.0);

                g.moveTo(0, -BLOCK_W+1);

                g.lineTo( block_offset-1, -BLOCK_W/2+1);

                g.lineTo( block_offset-1,  BLOCK_W/2-1);

                g.lineTo(0,  BLOCK_W-1);

                g.lineTo(-block_offset+1,  BLOCK_W/2-1);

                g.lineTo(-block_offset+1, -BLOCK_W/2+1);

                g.lineTo(0, -BLOCK_W+1);

                g.endFill();

                //- Line

                g.moveTo(0, 0);

                g.lineTo(0, BLOCK_W-1);

                g.moveTo(0, 0);

                g.lineTo( block_offset-1, -BLOCK_W/2+1);

                g.moveTo(0, 0);

                g.lineTo(-block_offset+1, -BLOCK_W/2+1);

//*/

            }



//            m_BitmapData = new BitmapData(BITMAP_W, BITMAP_W, true, 0x00000000);

//            m_BitmapData.draw(shape, new Matrix(1,0,0,1, BITMAP_W/2,BITMAP_W/2));

            m_BitmapData = s_RotBitmapData[0][TOTAL_ROT_FRAME-1];



            var bmp:Bitmap;



            m_BitmapData_Prev = new BitmapData(BITMAP_W, BITMAP_W, true, 0x00000000);

            bmp = new Bitmap(m_BitmapData_Prev);

            bmp.x = bmp.y = -BITMAP_W/2;

            m_Sprite_Prev.addChild(bmp);



            m_BitmapData_Next = new BitmapData(BITMAP_W, BITMAP_W, true, 0x00000000);

            bmp = new Bitmap(m_BitmapData_Next);

            bmp.x = bmp.y = -BITMAP_W/2;

            m_Sprite_Next.addChild(bmp);

//*/

        }



        //m_Mask_Prev, m_Mask_Next

        {//HexMapのネガマスク（HexBlockの該当部分だけ透明にして、周囲を不透明）（無限に不透明にはできないので、ブロックの表示に必要なぶんだけ表示）

/*

            var center_x:int = HexBlock.BMD_W / 2;

            var center_y:int = HexBlock.BMD_H / 2;

            var rad:Number = HexBlock.BLOCK_W * Math.sqrt(4*4 - 2*2);



            var xx:Number, yy:Number;

            var theta:Number;



            for(i = 0; i < 2; ++i){

                shape = new Shape();

                g = shape.graphics;



                g.lineStyle(0,0,0);

                for(j = 0; j < 6; ++j){

                    g.beginFill((i == 0)? 0xFF0000: 0x0000FF, 1.0);//色は関係ないがテスト表示用



                    theta = 2.0*Math.PI * (j + 0)/6;

                    xx = center_x + rad * Math.cos(theta);

                    yy = center_y + rad * Math.sin(theta);

                    g.moveTo(xx, yy);



                    theta = 2.0*Math.PI * (j + 0)/6;

                    xx = center_x + 2*rad * Math.cos(theta);

                    yy = center_y + 2*rad * Math.sin(theta);

                    g.lineTo(xx, yy);



                    theta = 2.0*Math.PI * (j + 1)/6;

                    xx = center_x + 2*rad * Math.cos(theta);

                    yy = center_y + 2*rad * Math.sin(theta);

                    g.lineTo(xx, yy);



                    theta = 2.0*Math.PI * (j + 1)/6;

                    xx = center_x + rad * Math.cos(theta);

                    yy = center_y + rad * Math.sin(theta);

                    g.lineTo(xx, yy);



                    g.endFill();

                }



                if(i == 0){

                    m_Mask_Prev = shape;

                }else{

                    m_Mask_Next = shape;

                }

            }

/*/

            m_Mask_Prev = new Bitmap(HexBlock.s_HexNegaMask.clone());

            m_Mask_Next = new Bitmap(HexBlock.s_HexNegaMask.clone());

//*/

        }

    }



    //Init : Connection

    public function Reset(in_Connection:Connection):void{

        //Param

        {

            m_RotateIndex_Trg = -1;

            m_BitmapData = s_RotBitmapData[0][TOTAL_ROT_FRAME-1];

            if(m_Sprite_Next.parent != null){

                m_Sprite_Next.parent.removeChild(m_Sprite_Next);

            }

        }



        //Connection

        {

            SetPrevConnection(in_Connection);

            SetNextConnection(in_Connection);

        }



        //Graphic

        {

            Update_Mask();

        }

    }



    //Set : Connection : Prev

    public function SetPrevConnection(in_Connection:Connection):void{

        if(in_Connection == null){

            //err

            return;

        }



        m_Connection_Prev = in_Connection;



        //ブロック描画：Prev

        m_Sprite_Prev.x = in_Connection.m_CenterX;

        m_Sprite_Prev.y = in_Connection.m_CenterY;

        in_Connection.m_BlockLayer.addChild(m_Sprite_Prev);



        //ブロック描画：Next

        //- Prevの位置に合わせる。描画先の変更はしない

        m_Sprite_Next.x = in_Connection.m_CenterX;

        m_Sprite_Next.y = in_Connection.m_CenterY;

    }



    //Set : Connection : Next

    public function SetNextConnection(in_Connection:Connection):void{

        m_Connection_Next = in_Connection;



        if(in_Connection == null){

            //Resetの時はここまで

            return;

        }



        //つながっている方向のHexMapがわかればマスクをかけてつなぐ

        var dir_base:int = in_Connection.m_BaseDir;

        var dir_plane:int = in_Connection.m_PlaneDir;

        if(0 <= dir_base && 0 <= dir_plane){

            //今居るHexBlock

            var hex_map_base:HexBlock = m_Connection_Prev.m_HexMap;

            //移動先のHexBlock

            var hex_map_next:HexBlock = m_Connection_Next.m_HexMap;

            var connection_next:Connection = m_Connection_Next;



            //同じHexBlock内の移動であれば、移動を先読みして次に移動するであろうHexBlockとのマスクをとる

            if(hex_map_base == hex_map_next){

                //指定方向からエッジを求め、相手側のエッジを求める

                var connection_edge:Connection = hex_map_base.m_EdgeConnection[dir_base][dir_plane];

                if(connection_edge == null){return;}

                connection_next = connection_edge.m_Link[dir_base][dir_plane];

                if(connection_next == null){return;}



                //相手側のHexBlock

                hex_map_next = connection_next.m_HexMap;

            }



            //1マスク位置の設定：ネガマスクなので相手位置でリセット

            m_Mask_Prev.x = hex_map_next.m_BaseX;

            m_Mask_Prev.y = hex_map_next.m_BaseY;

            m_Mask_Next.x = hex_map_base.m_BaseX;

            m_Mask_Next.y = hex_map_base.m_BaseY;



//            m_Sprite_Prev.mask = m_Mask_Prev;

//            m_Sprite_Next.mask = m_Mask_Next;



            if(m_Mask_Prev.parent == null){

//                SakusiWonderfl.Instance.m_Layer_BlockF.addChild(m_Mask_Prev);//!!test

            }

            if(m_Mask_Next.parent == null){

//                SakusiWonderfl.Instance.m_Layer_BlockF.addChild(m_Mask_Next);//!!test

            }



            connection_next.m_BlockLayer.addChild(m_Sprite_Next);



            //実際のマスキング処理はUpdateのたびに手動で実行する（BitmapDataをmaskに設定しても動作しないため）

        }

    }



    //Update

    public function Update(in_DeltaTime:Number):void{

        //現在実行中の回転処理

        Update_Rotation(in_DeltaTime);

/*

        //回転していなければ（完了していれば）ボタンによる回転を反映

        if(m_RotateIndex < 0){

            m_RotateIndex = m_RotateIndex_Trg;

        }

/*/

//*/

        //マスキング

        Update_Mask();

    }

    //Update : Rotation

    public function Update_Rotation(in_DeltaTime:Number):void{

/*

        //移動中でなければ回転方向に応じて次のポイントを探す

        if(m_Connection_Next == null){

            SetNextConnection(GetNextConnection(m_Connection_Prev, m_RotateIndex));

            m_RotFrame = 0;

        }



        //次の移動先がなければ移動完了とみなして終了

        if(m_Connection_Next == null){

            m_RotateIndex = -1;

            return;

        }



        //移動処理

        {

            //!!仮

            const TOTAL_ROT_FRAME:int = 4;

            ++m_RotFrame;

            var ratio:Number = 1.0 * m_RotFrame / TOTAL_ROT_FRAME;

            m_Sprite_Prev.x = m_Sprite_Next.x = Util.Lerp(m_Connection_Prev.m_CenterX, m_Connection_Next.m_CenterX, ratio);

            m_Sprite_Prev.y = m_Sprite_Next.y = Util.Lerp(m_Connection_Prev.m_CenterY, m_Connection_Next.m_CenterY, ratio);



            if(TOTAL_ROT_FRAME <= m_RotFrame){

                //移動完了

                SetPrevConnection(m_Connection_Next);

                SetNextConnection(null);

                m_RotateIndex = -1;

                m_RotFrame = 0;

            }

        }

/*/

        //移動中でなければ回転方向に応じて次のポイントを探す

        if(m_RotateIndex < 0){

            if(m_RotateIndex_Trg < 0){

                return;

            }



            var next_connection:Connection = GetNextConnection(m_Connection_Next, m_RotateIndex_Trg, true);

            if(next_connection == null){

                return;

            }



            m_RotateIndex = m_RotateIndex_Trg;

            SetPrevConnection(m_Connection_Next);

            SetNextConnection(next_connection);

            m_RotFrame = 0;

        }



        //回転アニメ

        {

            m_BitmapData = s_RotBitmapData[m_RotateIndex][m_RotFrame];

//            m_PosOffset = s_RotOffset[m_NextPlaneDir][m_RotFrame];//はみ出てしまうのでいったんオフ

        }



        //移動処理

        {

            //!!仮

            ++m_RotFrame;

            var ratio:Number = 1.0 * m_RotFrame / TOTAL_ROT_FRAME;

            m_Sprite_Prev.x = m_Sprite_Next.x = int(Util.Lerp(m_Connection_Prev.m_CenterX, m_Connection_Next.m_CenterX, ratio));

            m_Sprite_Prev.y = m_Sprite_Next.y = int(Util.Lerp(m_Connection_Prev.m_CenterY, m_Connection_Next.m_CenterY, ratio));



            if(TOTAL_ROT_FRAME <= m_RotFrame){

                //移動完了

                m_RotateIndex = -1;

                m_RotFrame = 0;

            }

        }

//*/

    }

    //Update : Rotation : Next Connection

    public function GetNextConnection(in_Connection:Connection, in_RotateIndex:int, in_UpdateNextPlaneDir:Boolean = false):Connection{

        var next_connection:Connection;

        switch(in_RotateIndex){

        case ROT_X_P:

            next_connection = in_Connection.m_Link[Connection.DIR_D][Connection.DIR_F];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_F;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_F][Connection.DIR_U];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_U;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_U][Connection.DIR_B];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_B;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_B][Connection.DIR_D];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_D;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        case ROT_X_M:

            next_connection = in_Connection.m_Link[Connection.DIR_D][Connection.DIR_B];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_B;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_F][Connection.DIR_D];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_D;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_U][Connection.DIR_F];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_F;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_B][Connection.DIR_U];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_U;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        case ROT_Y_P:

            next_connection = in_Connection.m_Link[Connection.DIR_B][Connection.DIR_R];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_R;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_R][Connection.DIR_F];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_F;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_F][Connection.DIR_L];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_L;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_L][Connection.DIR_B];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_B;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        case ROT_Y_M:

            next_connection = in_Connection.m_Link[Connection.DIR_B][Connection.DIR_L];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_L;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_R][Connection.DIR_B];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_B;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_F][Connection.DIR_R];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_R;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_L][Connection.DIR_F];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_F;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        case ROT_Z_P:

            next_connection = in_Connection.m_Link[Connection.DIR_L][Connection.DIR_U];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_U;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_U][Connection.DIR_R];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_R;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_R][Connection.DIR_D];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_D;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_D][Connection.DIR_L];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_L;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        case ROT_Z_M:

            next_connection = in_Connection.m_Link[Connection.DIR_L][Connection.DIR_D];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_D;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_U][Connection.DIR_L];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_L;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_R][Connection.DIR_U];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_U;}

            if(next_connection != null){return next_connection;}

            next_connection = in_Connection.m_Link[Connection.DIR_D][Connection.DIR_R];

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = Connection.DIR_R;}

            if(next_connection != null){return next_connection;}

            if(in_UpdateNextPlaneDir){m_NextPlaneDir = -1;}

            break;

        }



        return null;

    }



    //Update : Mask

    public function Update_Mask():void{

        //HexMapが２つ指定されていなければマスクは使わない

        var bmd_mask:BitmapData = (m_Sprite_Next.parent != null)? HexBlock.s_HexNegaMask: null;



        const BITMAP_W:int = 3*HexBlock.BLOCK_W;



        //Prev

        //- Clear

        m_BitmapData_Prev.fillRect(m_BitmapData_Prev.rect, 0x00000000);

        //- Draw

        //-- Mask:BmdXY - MaskXY

        m_BitmapData_Prev.copyPixels(m_BitmapData, m_BitmapData.rect, m_PosOffset, bmd_mask, new Point(m_Sprite_Prev.x-BITMAP_W/2 - m_Mask_Prev.x, m_Sprite_Prev.y-BITMAP_W/2 - m_Mask_Prev.y), true);



        //Next

        //- Clear

        m_BitmapData_Next.fillRect(m_BitmapData_Next.rect, 0x00000000);

        //- Draw

        if(bmd_mask != null){

            m_BitmapData_Next.copyPixels(m_BitmapData, m_BitmapData.rect, m_PosOffset, bmd_mask, new Point(m_Sprite_Next.x-BITMAP_W/2 - m_Mask_Next.x, m_Sprite_Next.y-BITMAP_W/2 - m_Mask_Next.y), true);

        }

    }

}





class Goal

{

    //==Var==



    //

    public var m_Connection:Connection;





    //==Function==



    //Init

    public function InitConnection(in_Connection:Connection, in_PlaneDir:int):void{

        //Param

        {

            m_Connection = in_Connection;

        }



        //Graphic

        {

            var bmd:BitmapData = new BitmapData(32, 32, true, 0x00000000);

            {

/*

                const LINE_W:int = 1;

                const LINE_COLOR:uint = 0xFF0000;

                const LINE_ALPHA:Number = 1.0;



                const FILL_COLOR:uint = 0xFF8800;//0xFF0000;



                const BLOCK_W:int = HexBlock.BLOCK_W;

                var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



                var center_x:Number = 32/2;

                var center_y:Number = 32/2;

                var rad_min:Number = BLOCK_W * 0.5;

                var rad_max:Number = rad_min * Math.sqrt(2);



                var shape:Shape = new Shape();

                var g:Graphics = shape.graphics;

                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                g.beginFill(FILL_COLOR, 1.0);

                switch(in_PlaneDir){

                case Connection.DIR_U:

                    g.drawEllipse(center_x - rad_max/2, center_y - rad_min/2 + BLOCK_W/2, rad_max, rad_min);

                    break;

                case Connection.DIR_R:

                    g.drawEllipse(center_x - rad_min/2 - block_offset/2, center_y - rad_max/2 - BLOCK_W/4, rad_min, rad_max);

                    break;

                case Connection.DIR_F:

                    g.drawEllipse(center_x - rad_min/2 + block_offset/2, center_y - rad_max/2 - BLOCK_W/4, rad_min, rad_max);

                    break;

                }

                g.endFill();

//*/

//*

                const LINE_W:int = 4;

                const LINE_COLOR:uint = 0x000000;

                const LINE_ALPHA:Number = 1.0;



                const FILL_COLOR:uint = 0xFFFF00;//0xFF0000;



                const BLOCK_W:int = HexBlock.BLOCK_W;

                var block_offset:Number = BLOCK_W * Math.sqrt(3)/2;



                var center_x:Number = 32/2;

                var center_y:Number = 32/2;



                var shape:Shape = new Shape();

                var g:Graphics = shape.graphics;

                g.lineStyle(LINE_W, LINE_COLOR, LINE_ALPHA);

                g.beginFill(FILL_COLOR, 1.0);

                switch(in_PlaneDir){

                case Connection.DIR_U:

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y + BLOCK_W);

                    g.lineTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y);

                    break;

                case Connection.DIR_R:

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x - block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x - block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y);

                    break;

                case Connection.DIR_F:

                    g.moveTo(center_x, center_y);

                    g.lineTo(center_x, center_y - BLOCK_W);

                    g.lineTo(center_x + block_offset, center_y - BLOCK_W/2);

                    g.lineTo(center_x + block_offset, center_y + BLOCK_W/2);

                    g.lineTo(center_x, center_y);

                    break;

                }

                g.endFill();

//*/

                bmd.draw(shape);

            }



            var bmd_layer:BitmapData = SakusiWonderfl.Instance.m_BitmapData_BackGroundB;



            bmd_layer.copyPixels(bmd, bmd.rect, new Point(in_Connection.m_CenterX - bmd.width/2, in_Connection.m_CenterY - bmd.height/2), null, null, true);

        }

    }



    //Update

    public function Update():void{

        var player:Player = SakusiWonderfl.Instance.m_Player;

        if(player.m_RotateIndex < 0 && player.m_Connection_Next == m_Connection){//回転移動が完了していて自分と同じConnectionに到達したら

            SakusiWonderfl.Instance.OnGoal();

        }

    }

}





//Base : Popup

class Popup extends Sprite

{

    //==Static==



    //全てPopするためのフラグ

//    static public var s_AllEndFlag:Boolean = false;





    //==Const==



    //プレートの高さ（押しやすいようにする）

    static public const PLATE_H:int = 64;

    //ついでに幅も

    static public const PLATE_W:int = 400;





    //==Var==



    //次のポップアップ

    public var m_NextPopup:Popup = null;



    //Flag

    protected var m_EndFlag:Boolean = false;





    //==Function==



    //Init

    public function Popup(){

//        s_AllEndFlag = false;

    }



    //Update

    public function Update(in_DeltaTime:Number):void{

        //Override

    }



    //Touch

    public function OnMouseDown():void{

        //Override

    }

    public function OnMouseMove():void{

        //Override

    }

    public function OnMouseUp():void{

        //Override

    }





    //

    public function GetNextPopup():Popup{

        return m_NextPopup;

    }

    public function ClearNextPopup():void{

        m_NextPopup = null;

    }



    //Flag

    public function IsEnd():Boolean{

        return m_EndFlag;// || s_AllEndFlag;

    }

}





//Base : Popup Scroll

class Popup_Scroll extends Popup

{

    //==Static==



    //毎回生成するのは高コストなので、一度生成したら保持しておく

    static public var s_BitmapData_BG:BitmapData = null;

    static public var s_NinePatch_Button_Content:NinePatch;



    //==Const==



    //

    static public const CONTENT_GAP_NORMAL        :int = 122;

    static public const CONTENT_GAP_STAGESELECT    :int = 70;



    //Type

    static public var s_TypeIter:int = 0;

    static public const TYPE_PAUSE        :int  = s_TypeIter++;

    static public const TYPE_RESULT        :int  = s_TypeIter++;

    static public const TYPE_STAGESELECT:int  = s_TypeIter++;





    //==Var==



    //Layer

    public var m_Layer_Root:Sprite = new Sprite();

    public var  m_Layer_BG:Sprite = new Sprite();

    public var  m_Layer_Content:Sprite = new Sprite();

    public var   m_Layer_Scroll:Sprite = new Sprite();



    //Type

    public var m_Type:int;



    //

    public var m_ContentGap:int;



    //Title

    public var m_BitmapData_Title:BitmapData;



    //Content

    public var m_BitmapData_Content:Vector.<BitmapData>;

    public var m_ContentAlign:int;



    //ボタン

    public var m_ButtonManager:ButtonManager = new ButtonManager();



    //Slide

    public var m_PushFlag:Boolean = false;

//    public var m_SrcTouchYXNumber = 0;

//    public var m_DstTouchX:Number = 0;

    public var m_SrcTouchY:Number = 0;

    public var m_DstTouchY:Number = 0;

    public var m_ScrollGap:Number = 0;





    //==Function==



    //Init

    public function Popup_Scroll(in_Type:int, in_Title:String, in_MesList:Vector.<String>, in_ContentAlign:int = -1){

        super();



        //Param

        {

            m_Type = in_Type;



            if(0 <= in_ContentAlign){

                m_ContentAlign = in_ContentAlign;

            }else{

                m_ContentAlign = FontText.ALIGN_LEFT;

            }



            m_ContentGap = (in_Type == TYPE_STAGESELECT)? CONTENT_GAP_STAGESELECT: CONTENT_GAP_NORMAL;

        }



        var bmd_ori:BitmapData = ImageManager.m_BitmapData_Ori;

        var bmd:BitmapData;

        var rad_x:int;

        var rad_y:int;

        var w:int;

        var h:int;

        var ori_x:int;

        var ori_y:int;

        var ori_w:int;

        var ori_h:int;



        const HeaderH:int = 64;

        const FooterH:int = 8;



        const offset:int = 0;//8;



        const TotalW:int = SakusiWonderfl.VIEW_W - 2*offset;

        const TotalH:int = SakusiWonderfl.VIEW_H - 2*offset - SakusiWonderfl.AD_H;



        var ContentAreaH:int = TotalH - HeaderH - FooterH;



        //Layer

        {

            addChild(m_Layer_Root);

            m_Layer_Root.y = SakusiWonderfl.AD_H;



            m_Layer_Root.addChild(m_Layer_BG);



//            m_Layer_Content.x = SakusiWonderfl.VIEW_W/2;

//            m_Layer_Content.y = 88;

            m_Layer_Content.y = HeaderH + offset;

            m_Layer_Content.scrollRect = new Rectangle(-SakusiWonderfl.VIEW_W/2, -m_ContentGap/2, SakusiWonderfl.VIEW_W, ContentAreaH);

            m_Layer_Root.addChild(m_Layer_Content);



            m_Layer_Content.addChild(m_Layer_Scroll);

        }



        //BG

        {

            if(s_BitmapData_BG == null){

                var mtx:Matrix = new Matrix();



                s_BitmapData_BG = new BitmapData(TotalW, TotalH, true, 0x00000000);

//*

                rad_x = 12;

                rad_y = 12;

                w = TotalW;

                h = TotalH;

                ori_x = 3*64;

                ori_y = 0;

                ori_w = 64;

                ori_h = 64;

                s_BitmapData_BG.draw(NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h), mtx);

//*/

                rad_x = 12;

                rad_y = 12;

                w = TotalW;

                h = HeaderH;

                ori_x = 3*64;

                ori_y = 0;

                ori_w = 64;

                ori_h = 64;

                s_BitmapData_BG.draw(NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h), mtx);

                mtx.ty += h;

/*

                rad_x = 12;

                rad_y = 12;

                w = TotalW;

                h = TotalH - HeaderH;

                ori_x = 3*64;

                ori_y = 0;

                ori_w = 64;

                ori_h = 64;

                s_BitmapData_BG.draw(NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h), mtx);

                mtx.ty += h;

//*/

            }



            var bmp_bg:Bitmap = new Bitmap(s_BitmapData_BG);

            bmp_bg.x = offset;

            bmp_bg.y = offset;

            m_Layer_BG.addChild(bmp_bg);

        }



        //Title

        {

            m_BitmapData_Title = new BitmapData(SakusiWonderfl.VIEW_W, 64, true, 0x00000000);

            FontText.DrawText(m_BitmapData_Title, in_Title, m_BitmapData_Title.width/2, m_BitmapData_Title.height/2, 32, 0x000000);

            var bmp_title:Bitmap = new Bitmap(m_BitmapData_Title);

            bmp_title.y = 8;

            m_Layer_Root.addChild(bmp_title);

        }



        //Content

        {

            if(s_NinePatch_Button_Content == null){

                rad_x = 12;

                rad_y = 12;

                w = PLATE_W - 64;

                h = PLATE_H;

                ori_x = 3*64;

                ori_y = 0;

                ori_w = 64;

                ori_h = 64;



                s_NinePatch_Button_Content = NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h);

            }



            var item_list:Vector.<String> = in_MesList;

//                new <String>["AA", "BB", "CC"];//!!test



            var num:int = item_list.length;

            m_BitmapData_Content = new Vector.<BitmapData>(num);

            var src_rect:Rectangle = new Rectangle(0,0,PLATE_W,PLATE_H);

            var dst_point:Point = new Point(0,0);

            for(var i:int = 0; i < num; ++i){

                //Frame

                {

                    bmd = new BitmapData(PLATE_W, PLATE_H, true, 0x00000000);



                    src_rect.x = 0;

                    src_rect.y = 0;

                    src_rect.width = PLATE_W - 64;

                    dst_point.x = 64;

                    bmd.copyPixels(s_NinePatch_Button_Content.m_BitmapData, src_rect, dst_point);



                    switch(m_Type){

                    case TYPE_PAUSE:

                    case TYPE_RESULT:

                        switch(i){

                        case 0: src_rect.x = 64*2; src_rect.y = 64*2; break;

                        case 1: src_rect.x = 64*2; src_rect.y = 64*3; break;

                        case 2: src_rect.x = 64*3; src_rect.y = 64*3; break;

                        }

                        break;

                    case TYPE_STAGESELECT:

                        src_rect.x = 64*2; src_rect.y = 64*2; break;

                        break;

                    }

                    src_rect.width = 64;

                    dst_point.x = 0;

                    bmd.copyPixels(bmd_ori, src_rect, dst_point);

                }



                switch(m_ContentAlign){

                case FontText.ALIGN_LEFT:

                    FontText.DrawText(bmd, item_list[i], 64+8, bmd.height/2, 32, 0x000000, m_ContentAlign);

                    break;

                case FontText.ALIGN_CENTER:

                    FontText.DrawText(bmd, item_list[i], bmd.width/2, bmd.height/2, 32, 0x000000, m_ContentAlign);

                    break;

                case FontText.ALIGN_RIGHT:

                    //No Support

                    break;

                }

                var button_content:Button = new Button(bmd);



                button_content.x = 0;//SakusiWonderfl.VIEW_W/2;

                button_content.y = i * m_ContentGap;

                m_Layer_Scroll.addChild(button_content);



                m_ButtonManager.AddButton(button_content);



                m_BitmapData_Content[i] = bmd;

            }

        }



        //Slide

        {

            m_ScrollGap = Math.min(ContentAreaH - in_MesList.length * m_ContentGap, 0);

        }

    }



    //Update

    override public function Update(in_DeltaTime:Number):void{

        m_ButtonManager.Update(in_DeltaTime);

    }



    //Touch

    override public function OnMouseDown():void{

//        m_SrcTouchX = m_DstTouchX = m_Layer_Content.mouseX;

        m_SrcTouchY = m_DstTouchY = m_Layer_Content.mouseY;

        m_PushFlag = true;



        m_ButtonManager.OnMouseDown();

    }

    override public function OnMouseMove():void{

        CheckSlide();



        m_ButtonManager.OnMouseMove();

    }

    override public function OnMouseUp():void{

        m_PushFlag = false;



        var index:int = m_ButtonManager.OnMouseUp();



        if(index < 0){//No Select

            return;

        }



        OnSelect(index);

    }

    protected function OnSelect(in_Index:int):void{

        //override

    }



    //

    public function CheckSlide():void{

        if(! m_PushFlag){

            return;

        }



//        var last_touch_x:int = m_Layer_Content.mouseX;

        var last_touch_y:int = m_Layer_Content.mouseY;



        //Slide

        m_Layer_Scroll.y += last_touch_y - m_DstTouchY;

        if(0 < m_Layer_Scroll.y){m_Layer_Scroll.y = 0;}

        if(m_Layer_Scroll.y < m_ScrollGap){m_Layer_Scroll.y = m_ScrollGap;}



        //一定以上スライドさせたらボタンの反応を無効化

        if(m_ContentGap/2 < Math.abs(m_DstTouchY - m_SrcTouchY)){

            m_ButtonManager.Cancel();

        }



//        m_DstTouchX = last_touch_x;

        m_DstTouchY = last_touch_y;

    }

}





//Popup : Result

class Popup_Result extends Popup_Scroll

{

    //==Var==



    public var m_SelectedIndex:int = -1;



    public var m_IsClear:Boolean;





    //==Function==



    //Init

    public function Popup_Result(in_IsClear:Boolean){

        super(Popup_Scroll.TYPE_RESULT, GetTitle(in_IsClear), GetMesList(in_IsClear));



        m_IsClear = in_IsClear;

    }



    //

    public function GetTitle(in_IsClear:Boolean):String{

        if(in_IsClear){

            return Util.IsJapanese()? "クリア！": "Clear!";

        }else{

            return Util.IsJapanese()? "失敗...": "Fail...";

        }

    }



    //

    public function GetMesList(in_IsClear:Boolean):Vector.<String>{

        var item_list_clear_jp:Vector.<String> =

            new <String>["次へ", "もう一度", "ステージ選択"];

        var item_list_clear_en:Vector.<String> =

            new <String>["Next Stage", "Replay", "Select Stage"];

        var item_list_clear_last_jp:Vector.<String> =

            new <String>["最初のステージへ", "もう一度", "ステージ選択"];

        var item_list_clear_last_en:Vector.<String> =

            new <String>["First Stage", "Replay", "Select Stage"];

        var item_list_fail_jp:Vector.<String> =

            new <String>["もう一度", "ステージ選択"];

        var item_list_fail_en:Vector.<String> =

            new <String>["Replay", "Select Stage"];



        if(in_IsClear){

            if(SakusiWonderfl.s_MapIter == SakusiWonderfl.MAP.length-1){

                return Util.IsJapanese()? item_list_clear_last_jp: item_list_clear_last_en;

            }else{

                return Util.IsJapanese()? item_list_clear_jp: item_list_clear_en;

            }

        }else{

            return Util.IsJapanese()? item_list_fail_jp: item_list_fail_en;

        }

    }



    //Touch

    override protected function OnSelect(in_Index:int):void{

        if(m_IsClear){

            switch(in_Index){

            case 0:

                //++

                SakusiWonderfl.s_MapIter++;

                if(SakusiWonderfl.MAP.length <= SakusiWonderfl.s_MapIter){

                    SakusiWonderfl.s_MapIter = 0;

                }

                //Reset

                SakusiWonderfl.Instance.Reset(true);

                //End

                m_EndFlag = true;

                break;

            case 1:

                //Reset

                SakusiWonderfl.Instance.Reset(false);

                //End

                m_EndFlag = true;

                break;

            case 2:

                //Menu

                SakusiWonderfl.Instance.Push(new Popup_StageSelect());

                //End

                m_EndFlag = true;

                break;

            }

        }else{

            switch(in_Index){

            case 0:

                //Reset

                SakusiWonderfl.Instance.Reset(false);

                //End

                m_EndFlag = true;

                break;

            case 1:

                //Menu

                SakusiWonderfl.Instance.Push(new Popup_StageSelect());

                //End

                m_EndFlag = true;

                break;

            }

        }



        m_SelectedIndex = in_Index;

    }



    //Update

    override public function Update(in_DeltaTime:Number):void{

        super.Update(in_DeltaTime);



/*

        switch(m_SelectedIndex){

        case 1:

            GlobalData.Instance.ChangeTask(GlobalData.TASK_MENU_GROUND);

            break;

        }

//*/

    }



}





//Popup : Pause

class Popup_Pause extends Popup_Scroll

{

    //==Var==



    public var m_SelectedIndex:int = -1;





    //==Function==



    //Init

    public function Popup_Pause(){

        super(Popup_Scroll.TYPE_PAUSE, Util.IsJapanese()? "メニュー": "Menu", GetMesList());

    }



    //

    public function GetMesList():Vector.<String>{

        var item_list_jp:Vector.<String> =

            new <String>["続ける", "最初から", "ステージ選択"];

        var item_list_en:Vector.<String> =

            new <String>["Continue", "Restart", "Select Stage"];



        return Util.IsJapanese()? item_list_jp: item_list_en;

    }



    //Touch

    override protected function OnSelect(in_Index:int):void{

        switch(in_Index){

        case 0:

            //End

            m_EndFlag = true;

            break;

        case 1:

            //Reset

            SakusiWonderfl.Instance.Reset(false);

            //End

            m_EndFlag = true;

            break;

        case 2:

            //Menu

            SakusiWonderfl.Instance.Push(new Popup_StageSelect());

            //End

            m_EndFlag = true;

            break;

        }



        m_SelectedIndex = in_Index;

    }



    //Update

    override public function Update(in_DeltaTime:Number):void{

        super.Update(in_DeltaTime);



/*

        switch(m_SelectedIndex){

        case 1:

            GlobalData.Instance.ChangeTask(GlobalData.TASK_MENU_GROUND);

            break;

        }

//*/

    }



}





//Popup : StageSelect

class Popup_StageSelect extends Popup_Scroll

{

    //==Var==



    public var m_SelectedIndex:int = -1;





    //==Function==



    //Init

    public function Popup_StageSelect(){

        super(Popup_Scroll.TYPE_STAGESELECT, Util.IsJapanese()? "ステージ選択": "Select Stage", GetMesList());

    }



    //

    public function GetMesList():Vector.<String>{

        var num:int = SakusiWonderfl.MAP.length;



        var item_list:Vector.<String> = new Vector.<String>(num);



        for(var i:int = 0; i < num; ++i){

            item_list[i] = SakusiWonderfl.MAP[i].name;

        }



        return item_list;

    }



    //Touch

    override protected function OnSelect(in_Index:int):void{

        //Index

        SakusiWonderfl.s_MapIter = in_Index;

        if(SakusiWonderfl.MAP.length <= SakusiWonderfl.s_MapIter){

            SakusiWonderfl.s_MapIter = 0;

        }

        //Reset

        SakusiWonderfl.Instance.Reset(true);

        //End

        m_EndFlag = true;





        m_SelectedIndex = in_Index;

    }



    //Update

    override public function Update(in_DeltaTime:Number):void{

        super.Update(in_DeltaTime);



/*

        switch(m_SelectedIndex){

        case 1:

            GlobalData.Instance.ChangeTask(GlobalData.TASK_MENU_GROUND);

            break;

        }

//*/

    }



}





//Base : StageName

class Popup_StageName extends Popup

{

    //==Const==



    //Time

    static public const TIME_WAIT    :Number = 2.0;

    static public const TIME_FADE    :Number = 1.0;



    //Mode

    static public var s_ModeIter:int = 0;

    static public const MODE_WAIT    :int = s_ModeIter++;

    static public const MODE_FADE    :int = s_ModeIter++;





    //==Var==



    //Time

    public var m_Timer:Number = 0;



    //Mode

    public var m_Mode:int = 0;





    //==Function==



    //Init

    public function Popup_StageName(in_StageName:String){

        super();



        var bmd:BitmapData = new BitmapData(SakusiWonderfl.VIEW_W, SakusiWonderfl.VIEW_H, false, 0x000000);

        FontText.DrawText(bmd, in_StageName, bmd.width/2, bmd.height/2, 32, 0xFFFFFF);

        addChild(new Bitmap(bmd));

    }



    //Update

    override public function Update(in_DeltaTime:Number):void{

        m_Timer += in_DeltaTime;



        switch(m_Mode){

        case MODE_WAIT:

            if(TIME_WAIT <= m_Timer){

                m_Timer -= TIME_WAIT;

                ++m_Mode;

            }

            break;

        case MODE_FADE:

            {

                var ratio:Number = m_Timer / TIME_FADE;

                if(TIME_FADE <= m_Timer){

                    ratio = 1;

                    m_EndFlag = true;

                }



                this.alpha = 1 - ratio;

            }

            break;

        }

    }

}





class Button extends Sprite

{

    //==Const==



    static public const SCALE_OFF    :Number = 1;

    static public const SCALE_ON    :Number = 1.1;





    //==Var==



    //Graphic

    public var m_Layer_Scale:Sprite = new Sprite();

    public var m_Bitmap:Bitmap;



    //Flag

    public var m_PressFlag:Boolean = false;





    //==Function==



    //Init

    public function Button(in_BMD:BitmapData){

/*

        m_Layer_Scale.x = in_BMD.width/2;

        m_Layer_Scale.y = in_BMD.height/2;

        addChild(m_Layer_Scale);

/*/

        addChild(m_Layer_Scale);

//*/



        var bmp:Bitmap = new Bitmap(in_BMD);

        bmp.x = -in_BMD.width/2;

        bmp.y = -in_BMD.height/2;

        m_Layer_Scale.addChild(bmp);

        m_Bitmap = bmp;

    }



    //Update

    public function Update(in_DeltaTime:Number):void{

        var lerp_ratio:Number = 0.9;

        var scl:Number = Util.Lerp(m_Layer_Scale.scaleX, (m_PressFlag? SCALE_ON: SCALE_OFF), lerp_ratio);

        m_Layer_Scale.scaleX = m_Layer_Scale.scaleY = scl;

    }



    //Range

    public function IsRectIn():Boolean{

        return m_Bitmap.bitmapData.rect.contains(m_Bitmap.mouseX, m_Bitmap.mouseY);

    }



    //

    public function SetPressFlag(in_Flag:Boolean):void{

        m_PressFlag = in_Flag;

    }

}





class ButtonManager

{

    //==Var==



    public var m_Button:Vector.<Button> = new Vector.<Button>();



    public var m_TouchIndex:int = -1;





    //==Function==



    //Register

    public function AddButton(in_Button:Button):void{

        m_Button.push(in_Button);

    }



    //Update

    public function Update(in_DeltaTime:Number):void{

        var num:int = m_Button.length;

        for(var i:int = 0; i < num; ++i){

            var button:Button = m_Button[i];

            button.Update(in_DeltaTime);

        }

    }



    //Touch

    public function OnMouseDown():void{

        m_TouchIndex = -1;



        var num:int = m_Button.length;

        for(var i:int = 0; i < num; ++i){

            var button:Button = m_Button[i];

            var parent:DisplayObjectContainer = button.parent;

            if(IsRangeIn(button)){

                m_TouchIndex = i;



                button.SetPressFlag(true);



                break;

            }

        }

    }

    public function OnMouseMove():void{

        if(0 <= m_TouchIndex){

            var button:Button = m_Button[m_TouchIndex];

            if(! button.IsRectIn()){

                button.SetPressFlag(false);

                m_TouchIndex = -1;

            }

        }

    }

    public function OnMouseUp():int{

        var touch_index:int = m_TouchIndex;



        if(0 <= m_TouchIndex){

            var button:Button = m_Button[m_TouchIndex];

            button.SetPressFlag(false);

        }



        m_TouchIndex = -1;



        return touch_index;

    }



    //Check Range

    public function IsRangeIn(in_Button:Button):Boolean{

        //そもそもボタンの範囲外なら反応しない

        if(! in_Button.IsRectIn()){

            return false;

        }



        //親のどこかのScrollRectの範囲外になってたら反応しない（スクロール対応）

        for(var content:DisplayObjectContainer = in_Button.parent; content != null; content = content.parent){

            if(content.scrollRect == null){

                continue;

            }



            if(! content.scrollRect.contains(content.mouseX / content.scaleX, content.mouseY / content.scaleY)){

                return false;

            }

        }



        return true;

    }



    //Cancel

    //- 主にボタンを押しながらのスライド用

    public function Cancel():void{

        if(0 <= m_TouchIndex){

            var button:Button = m_Button[m_TouchIndex];

            button.SetPressFlag(false);

        }



        m_TouchIndex = -1;

    }

}





class ImageManager

{

    //==Var==



    //Ori

    static public var m_BitmapData_Ori:BitmapData;



    //Rot Button

    static public var m_BitmapData_RotButton_On:Vector.<BitmapData>;

    static public var m_BitmapData_RotButton_Off:Vector.<BitmapData>;



    //Pause Button

    static public var m_BitmapData_Pause:BitmapData;





    //==Function==



    //Init

    static public function Init(in_Graphic:DisplayObject):void{

        //m_BitmapData_Ori

        {

            m_BitmapData_Ori = new BitmapData(256, 256, true, 0x00000000);

            m_BitmapData_Ori.draw(in_Graphic);

        }



        //m_BitmapData_RotButton_On, m_BitmapData_RotButton_Off

        {

            const gray_offset:Number = 0xAA;

            const ct_gray:ColorTransform = new ColorTransform(1,1,1,1, gray_offset,gray_offset,gray_offset,0);

            m_BitmapData_RotButton_On  = new Vector.<BitmapData>(Player.ROT_NUM);

            m_BitmapData_RotButton_Off = new Vector.<BitmapData>(Player.ROT_NUM);

            for(var i:int = 0; i < Player.ROT_NUM; ++i){

                m_BitmapData_RotButton_On[i]  = new BitmapData(64, 64, true, 0x00000000);

                m_BitmapData_RotButton_Off[i] = new BitmapData(64, 64, true, 0x00000000);



                var mtx:Matrix = new Matrix();

                mtx.tx = -64 * int(i & 0x1);

                mtx.ty = -64 * int(i >> 1);

                m_BitmapData_RotButton_On[i].draw(in_Graphic, mtx);



                m_BitmapData_RotButton_Off[i].draw(m_BitmapData_RotButton_On[i], null, ct_gray);

            }

        }



        //m_BitmapData_Pause

        {

            m_BitmapData_Pause = new BitmapData(64, 64, true, 0x00000000);

            m_BitmapData_Pause.draw(in_Graphic, new Matrix(1,0,0,1, -64*3, -64*2));

        }

    }



    static public function GetBitmapData_RotButton(in_RotIndex:int, in_On:Boolean):BitmapData{

        if(in_On){

            return m_BitmapData_RotButton_On[in_RotIndex];

        }else{

            return m_BitmapData_RotButton_Off[in_RotIndex];

        }

    }



    static public function GetBitmapData_Pause():BitmapData{

        return m_BitmapData_Pause;

    }

}





class NinePatch extends Sprite

{

    //処理コストが高いので、Popupなどで使う場合は事前に生成しておいて使いまわすこと



    //==Var==



    //描画結果を使いまわす場合、このBitmapDataを使いまわす

    public var m_BitmapData:BitmapData;





    //==Function==



    //Create

    static public function Create(in_BMD:BitmapData, in_RadX:int, in_RadY:int, in_W:int, in_H:int, in_OriX:int = 0, in_OriY:int = 0, in_OriW:int = -1, in_OriH:int = -1):NinePatch{

        var nine_patch:NinePatch = new NinePatch();

        nine_patch.Init(in_BMD, in_RadX, in_RadY, in_W, in_H, in_OriX, in_OriY, in_OriW, in_OriH);

        return nine_patch;

    }



    //Clone

    static public function Clone(in_BMD:BitmapData):NinePatch{

        var nine_patch:NinePatch = new NinePatch();

        nine_patch.m_BitmapData = in_BMD;

        nine_patch.addChild(new Bitmap(in_BMD));

        return nine_patch;

    }



    //Init

    public function Init(in_BMD:BitmapData, in_RadX:int, in_RadY:int, in_W:int, in_H:int, in_OriX:int, in_OriY:int, in_OriW:int, in_OriH:int):void{

        var OriW:int = (in_OriW <= 0)? in_BMD.width: in_OriW;

        var OriH:int = (in_OriH <= 0)? in_BMD.height: in_OriH;



        var edge_w:int = OriW - in_RadX*2;

        var edge_h:int = OriH - in_RadY*2;

        //念のため補正

        if(edge_w <= 0){edge_w = 1;}

        if(edge_h <= 0){edge_h = 1;}



        var bmd:BitmapData = new BitmapData(in_W, in_H, true, 0x00000000);



        var src_rect:Rectangle = new Rectangle(0,0,1,1);

        var dst_pos:Point = new Point(0,0);

        var offset_x:int;

        var offset_y:int;



        //Corner

        {

            src_rect.width  = in_RadX;

            src_rect.height = in_RadY;

            //- LU

            src_rect.x = in_OriX;

            src_rect.y = in_OriY;

            dst_pos.x = 0;

            dst_pos.y = 0;

            bmd.copyPixels(in_BMD, src_rect, dst_pos);

            //- RU

            src_rect.x = in_OriX + OriW-in_RadX;

            src_rect.y = in_OriY;

            dst_pos.x = in_W-in_RadX;

            dst_pos.y = 0;

            bmd.copyPixels(in_BMD, src_rect, dst_pos);

            //- LD

            src_rect.x = in_OriX;

            src_rect.y = in_OriY + OriH-in_RadY;

            dst_pos.x = 0;

            dst_pos.y = in_H-in_RadY;

            bmd.copyPixels(in_BMD, src_rect, dst_pos);

            //- RD

            src_rect.x = in_OriX + OriW-in_RadX;

            src_rect.y = in_OriY + OriH-in_RadY;

            dst_pos.x = in_W-in_RadX;

            dst_pos.y = in_H-in_RadY;

            bmd.copyPixels(in_BMD, src_rect, dst_pos);

        }



        //Edge

        {

            //UD

            src_rect.x = in_OriX + in_RadX;

            src_rect.width = edge_w;

            src_rect.height = in_RadY;

            for(offset_x = in_RadX; offset_x < in_W - in_RadX; offset_x += edge_w){

                dst_pos.x = offset_x;

                if(in_W - in_RadX < offset_x + edge_w){

                    src_rect.width = (in_W - in_RadX) - offset_x;

                }

                //U

                src_rect.y = in_OriY;

                dst_pos.y = 0;

                bmd.copyPixels(in_BMD, src_rect, dst_pos);

                //D

                src_rect.y = in_OriY + OriH-in_RadY;

                dst_pos.y = in_H-in_RadY;

                bmd.copyPixels(in_BMD, src_rect, dst_pos);

            }



            //LR

            src_rect.y = in_OriY + in_RadY;

            src_rect.width = in_RadX;

            src_rect.height = edge_h;

            for(offset_y = in_RadY; offset_y < in_H - in_RadY; offset_y += edge_h){

                dst_pos.y = offset_y;

                if(in_H - in_RadY < offset_y + edge_h){

                    src_rect.height = (in_H - in_RadY) - offset_y;

                }

                //L

                src_rect.x = in_OriX;

                dst_pos.x = 0;

                bmd.copyPixels(in_BMD, src_rect, dst_pos);

                //R

                src_rect.x = in_OriX + OriW-in_RadX;

                dst_pos.x = in_W-in_RadX;

                bmd.copyPixels(in_BMD, src_rect, dst_pos);

            }

        }



        //Center

        {

            src_rect.x = in_OriX + in_RadX;

            src_rect.y = in_OriY + in_RadY;

            for(offset_x = in_RadX; offset_x < in_W - in_RadX; offset_x += edge_w){

                dst_pos.x = offset_x;

                if(in_W - in_RadX < offset_x + edge_w){

                    src_rect.width = (in_W - in_RadX) - offset_x;

                }else{

                    src_rect.width = edge_w;

                }



                for(offset_y = in_RadY; offset_y < in_H - in_RadY; offset_y += edge_h){

                    dst_pos.y = offset_y;

                    if(in_H - in_RadY < offset_y + edge_h){

                        src_rect.height = (in_H - in_RadY) - offset_y;

                    }else{

                        src_rect.height = edge_h;

                    }



                    bmd.copyPixels(in_BMD, src_rect, dst_pos);

                }

            }

        }



        m_BitmapData = bmd;

        addChild(new Bitmap(bmd));

    }

}





class FontText

{

    //==Embed==

    //fontNameではなくfontFamily + embedAsCFF=falseにすること

//    [Embed(source="mplus-1c-black.ttf", fontFamily="mplus", embedAsCFF = "false", mimeType='application/x-font')]

//    private var font:Class;



    //==Const==



    //

    static public var s_AlignIter:int = 0;

    static public const ALIGN_CENTER:int = s_AlignIter++;//Default

    static public const ALIGN_LEFT    :int = s_AlignIter++;

    static public const ALIGN_RIGHT    :int = s_AlignIter++;

    static public const ALIGN_UP    :int = ALIGN_LEFT;

    static public const ALIGN_DOWN    :int = ALIGN_DOWN;



    //==Var==



    static public var s_TextField:TextField = null;

    static public var s_TextFormat:TextFormat = new TextFormat();

    static public var s_TextSprite:Sprite = new Sprite();





    //==Function==



    static public function DrawText(out_BMD:BitmapData, in_Text:String, in_X:Number, in_Y:Number, in_Size:int, in_Color:uint, in_AlignX:int = 0, in_AlignY:int = 0):void{

        if(s_TextField == null){

            s_TextField = new TextField();

//            s_TextField.embedFonts = true;

            s_TextField.autoSize = TextFieldAutoSize.LEFT;



//            s_TextFormat.font = "mplus";



            s_TextSprite.addChild(s_TextField);

        }



        //Param

        s_TextFormat.size = in_Size;

        s_TextFormat.color = in_Color;

        s_TextField.defaultTextFormat = s_TextFormat;

        s_TextField.text = in_Text;



        //Align

        switch(in_AlignX){

        case ALIGN_LEFT:

            s_TextField.x = in_X;

            break;

        case ALIGN_CENTER:

            s_TextField.x = in_X - s_TextField.textWidth/2;

            break;

        case ALIGN_CENTER:

            s_TextField.x = in_X - s_TextField.textWidth;

            break;

        }

        switch(in_AlignY){

        case ALIGN_UP:

            s_TextField.y = in_Y;

            break;

        case ALIGN_CENTER:

            s_TextField.y = in_Y - s_TextField.textHeight/2;

            break;

        case ALIGN_DOWN:

            s_TextField.y = in_Y - s_TextField.textHeight;

            break;

        }



        //Draw

        out_BMD.draw(s_TextSprite);

    }

}





class Util

{

    //Lerp

    static public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{

        return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);

    }



    //Clamp

    static public function Clamp(in_Val:Number, in_Min:Number, in_Max:Number):Number{

        if(in_Val < in_Min){return in_Min;}

        if(in_Max < in_Val){return in_Max;}

        return in_Val;

    }

    static public function Clamp01(in_Val:Number):Number{

        if(in_Val < 0){return 0;}

        if(1 < in_Val){return 1;}

        return in_Val;

    }



    //Language

    static public function IsJapanese():Boolean{

//*

        return (Capabilities.language == "ja");

/*/

        return false;

//*/

    }

}























































