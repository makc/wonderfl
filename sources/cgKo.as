/*
　FLARE.TAIL
　- 移動軌跡で相手を倒していくだけのゲーム

　操作方法
　- マウスを動かす
　-- プレイヤーの移動先を決めます
　-- その移動軌跡が攻撃判定になります
　-- 軌跡で囲んだ範囲も攻撃判定になります

　エネミーの種類
　- スライム
　-- ただ直進するだけ
　-- 移動先に炎を配置する遊び
　- ビー
　-- プレイヤーの居た位置に直進
　-- 反応して避ける遊び
　- ゴブリン
　-- プレイヤーを追いかける
　-- たくさん出して対応させる遊び
　- オーガ
　-- 炎で囲まないと倒せない
　-- 素早く囲む遊び
　- スネーク
　-- プレイヤーから逃げる
　-- 炎のあるところに誘導する遊び（自分も早めに中央に移動する遊び）

　素材
　- キャラ絵＆背景
　-- First Seed Materialの素材を利用しています
　-- http://www.tekepon.net/fsm/

　どうでもいいこと
　- タイトルの読みはもちろん「ふれあっている」
　-- しかし、敵の攻撃は「IcyTail（あいしている）」ではないのであった
*/

/*
　作業時間履歴
　・ファイル作成～プレイヤーがマウス位置に移動：２０分
　・軌跡の炎化（炎の習作からコピペ）：１５分
　・炎の持続時間調整：１５分
　・プレイヤーの移動パターンを試す：１５分
　・軌跡で囲んだ部分も炎化する処理＆調整：３０分
　・単純移動のエネミー作成＆一定周期で出現：１０分
　・以上をもとに炎の持続時間や移動パターンの再調整：３０分
　・（この時点でひとまずブログにUP）
　・モンスターの出現パターンを配列で指定できるように対応：２０分
　・モンスターの行動パターンの対応＆調整：３０分
　・（もう一度ブログにUP）
　・グラフィックの差し替え＆ローディング＆アニメーション対応：４０分
　・プレイヤーのやられ処理：１０分
　・エネミーの自動生成：２０分
　・背景の焼き処理：６０分（色々とハマった）
　→合計：３１５分＝５時間ちょい
　　・今回は休憩時間とかを多く取っただけで、体調が良ければやはり一週間でいけるレベルっぽい
*/

/*
　余裕があれば
　・敵も炎を出してくる
　　・プレイヤーはそこをしばらく通れない
　　・さらにそいつもオーガのように「囲まないと倒せない」タイプなら、誘導方法も考えざるを得ない
　・ボス
　　・弾幕ボスを炎で防ぎつつ、ボスを炎で囲んで攻撃
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

        //画像のリソース位置
//*
        //wonderfl用ロード型
        static public const URL_GRAPHICS:String = "http://assets.wonderfl.net/images/related_images/8/8f/8f2c/8f2c1f17b0072d904187289800f45404d41cf964";
//*/
/*
        //確認用ローカルロード型
        static public const URL_GRAPHICS:String = "Result.png";
//*/
/*
        //ブログ用埋め込み型
        [Embed(source='Result.png')]
         private static var Bitmap_Graphics: Class;
//*/

        //画面の大きさ
        static public const VIEW_W:int = 465;
        static public const VIEW_H:int = 465;

        //炎の線の大きさ
        static public const FIRE_LINE_W:int = 16;

        //エネミーの種類
        static public var EnemyIter:int = 0;
        static public const ENEMY_SLIME:int = EnemyIter++;
        static public const ENEMY_BEE:int = EnemyIter++;
        static public const ENEMY_GOBLIN:int = EnemyIter++;
        static public const ENEMY_OGRE:int = EnemyIter++;
        static public const ENEMY_SNAKE:int = EnemyIter++;
        static public const ENEMY_NUM:int = EnemyIter;
        //Alias
        static public const S:int = ENEMY_SLIME;
        static public const B:int = ENEMY_BEE;
        static public const G:int = ENEMY_GOBLIN;
        static public const O:int = ENEMY_OGRE;
        static public const N:int = ENEMY_SNAKE;

        //エネミーの自動生成用
        static public var AutoEnemyIter:int = 0;
        static public const X:int = AutoEnemyIter++;
        static public const Y:int = AutoEnemyIter++;
        static public const Z:int = AutoEnemyIter++;

        //モード
        static public var ModeIter:int = 0;
        static public const MODE_MAIN:int    = ModeIter++;
        static public const MODE_GAME_OVER:int    = ModeIter++;

        //画像サイズ
        static public const PANEL_W:int = 24;
        static public const PANEL_H:int = 32;
        static public const PANEL_NUM_X:int = 3;
        static public const PANEL_NUM_Y:int = 4;

        //Utility
        static public const VIEW_RECT:Rectangle = new Rectangle(0,0,VIEW_W,VIEW_H);
        static public const POS_ZERO:Point = new Point(0,0);
        static public const POS_ONE:Point = new Point(1,1);
        static public const MTX_FOR_FLOOD:Matrix = new Matrix(1,0,0,1, -1,-1);


        //#Enemy Setting

        static public const ENEMY_SEQ:Array = [
            //#スライムが上から出てくるだけ
            [
                [S, S, S, S, S]
            ],
//*
            //#もう一度上から
            [
                [S, S, S, S, S]
            ],

            //#ビーのお披露目
            [
                [B, B, B, B, B]
            ],

            //#もう一度ビー
            [
                [B, B, B, B, B]
            ],

            //#さらにもう一度ビー
            [
                [B, B, B, B, B]
            ],

            //#さらに下からビー
            [
                [             ],
                [B, B, B, B, B]
            ],

            //#今度は横から
            [
                [        ],
                [S,     S],
                [S,     S],
                [S,     S],
                [S,     S],
                [        ]
            ],

            //#さらに縦から
            [
                [S, S, S, S, S],
                [S, S, S, S, S]
            ],

            //#ゴブリン登場
            [
                [G, G, G, G, G]
            ],

            //#ゴブリンが上下から登場
            [
                [G, G, G, G, G],
                [G, G, G, G, G]
            ],

            //#さらに全方位ゴブリン
            [
                [  G, G, G  ],
                [G,        G],
                [G,        G],
                [G,        G],
                [  G, G, G  ]
            ],

            //#オーガ襲来
            [
                [O]
            ],

            //#オーガ＆ゴブリン
            [
                [G, O, G],
                [G,    G],
                [G,    G],
                [G,    G],
                [G, O, G]
            ],

            //#スネーク登場
            [
                [N]
            ],

            //#スネークがたくさん登場
            [
                [  N  ],
                [N,  N],
                [  N  ]
            ],
//*/
        ];

//*
        //エネミーの自動生成時のパターン設定
        static public const ENEMY_SEQ_AUTO:Array = [
            //=簡易=

            //#上下
            [
                [X, X, X],
                [X, X, X]
            ],
            //#左右
            [
                [        ],
                [X,     X],
                [X,     X],
                [X,     X],
                [        ]
            ],
            //#全方位
            [
                [  X  ],
                [X,  X],
                [  X  ]
            ],


            //=同じやつだけ=

            //#上下
            [
                [X, X, X, X, X],
                [X, X, X, X, X]
            ],
            //#左右
            [
                [        ],
                [X,     X],
                [X,     X],
                [X,     X],
                [X,     X],
                [X,     X],
                [        ]
            ],
            //#全方位
            [
                [  X, X, X  ],
                [X,        X],
                [X,        X],
                [X,        X],
                [  X, X, X  ]
            ],


            //=二種類混合=

            //#上下
            [
                [X, X, X, X, X],
                [Y, Y, Y, Y, Y]
            ],
            //#左右
            [
                [        ],
                [X,     Y],
                [X,     Y],
                [X,     Y],
                [X,     Y],
                [X,     Y],
                [        ]
            ],
            //#全方位
            [
                [  X, X, X  ],
                [Y,        Y],
                [Y,        Y],
                [Y,        Y],
                [  X, X, X  ]
            ],


            //=殺す気まんまん=

            //#全方位
            [
                [  X, Y, X, Y, X  ],
                [Y,              Y],
                [X,              X],
                [Y,              Y],
                [X,              X],
                [Y,              Y],
                [  X, Y, X, Y, X  ]
            ],
        ];
//*/



        //==Var==

        //#ゲーム部分

        //Pseudo Singleton
        static public var Instance:GameMain;

        //モード
        public var m_Mode:int = MODE_MAIN;


        //#エネミー

        //仮：エネミー出現用タイマー
        //public var m_EnemyTimer:Number = 0;

        //エネミーの出現管理用のイテレータ
        public var m_EnemySeqIter:int = 0;

        //倒したエネミーの数（スコア）
        public var m_Score:int = 0;


        //#表示まわり

        //レイヤー
        public var m_Layer_Root:Sprite = new Sprite();
        public var  m_Layer_BG:Sprite = new Sprite();
        public var  m_Layer_Player:Sprite = new Sprite();
        public var  m_Layer_Enemy:Sprite = new Sprite();
        public var  m_Layer_Fire:Sprite = new Sprite();

        //画像
        public var m_BitmapData_BG_Grass:BitmapData  = new BitmapData(VIEW_W, VIEW_H, true,  0xFF000000);
        public var m_BitmapData_BG_Soil:BitmapData   = new BitmapData(VIEW_W, VIEW_H, false, 0x000000);

        //プレイヤー
        public var m_Player:Player;

        //テキスト
        public var m_Text:TextField = new TextField();


        //#炎の描画＆処理まわり

        //実際の表示に使うビットマップ
        public var m_BitmapData_FireView:BitmapData = new BitmapData(VIEW_W, VIEW_H, true, 0x00000000);
        //炎の状態を0x00～0xFFで保持するデータ
        public var m_BitmapData_FireData:BitmapData = new BitmapData(VIEW_W, VIEW_H, false, 0x00);
        //炎を一定時間保持するための格納用ビットマップ
        public var m_BitmapData_FireEmit:BitmapData = new BitmapData(VIEW_W, VIEW_H, false, 0x00);
        //囲み判定用Bitmap
        public var m_BitmapData_Flood:BitmapData = new BitmapData(VIEW_W+2, VIEW_H+2, false, 0x00);
        //Fire => Viewの変換のためのパレット（0x00～0xFFの値を、実際の炎の色に置き換える）
        public var m_Palette_Fire_to_View:Array = new Array(256);
        //減衰に使うためのパーリンノイズ
        public var m_BitmapData_PerlinNoise:BitmapData = new BitmapData(VIEW_W * 2, VIEW_H * 2, false, 0x000000);
        //スクロールに使うマトリクス
        public var m_Mtx_PerlinNoise:Matrix = new Matrix();
        //広げるためのブラーフィルター
        public var m_Filter_FireBlur:BlurFilter = new BlurFilter(4,4);
//        public var m_Filter_FireBlur:BlurFilter = new BlurFilter(1,1);
        //持続を減衰させる処理
        static public const CT_DEC_RATIO:Number = 1.0;
        static public const CT_DEC_VAL:Number = -0xFF/90.0;
        public var m_CT_Dec:ColorTransform = new ColorTransform(CT_DEC_RATIO,CT_DEC_RATIO,CT_DEC_RATIO,1, CT_DEC_VAL,CT_DEC_VAL,CT_DEC_VAL);
        //汎用BitmapData
        public var m_BitmapData_Util:BitmapData = new BitmapData(VIEW_W, VIEW_H, true, 0x00000000);


        //==Function==

        //Init
        public function GameMain():void {
            var i:int;
            
            Wonderfl.capture_delay(6);

            //Pseudo Singleton
            {
                Instance = this;
            }

            //Static Init
            {
                Player.Initialize();
                Enemy.Initialize();
                ScoreWindowLoader.init(this, new WonderflAPI(loaderInfo.parameters));
            }

            //Layer
            {
                //Root
                addChild(m_Layer_Root);

                {
/*
                    //背景
                    m_Layer_Root.addChild(m_Layer_BG);

                    //OBJ
                    m_Layer_Root.addChild(m_Layer_Player);

                    //Enemy
                    m_Layer_Root.addChild(m_Layer_Enemy);

                    //炎
                    m_Layer_Root.addChild(m_Layer_Fire);
/*/
                    //#炎を後ろに表示する版

                    //背景
                    m_Layer_Root.addChild(m_Layer_BG);

                    //炎
                    m_Layer_Root.addChild(m_Layer_Fire);

                    //OBJ
                    m_Layer_Root.addChild(m_Layer_Player);

                    //Enemy
                    m_Layer_Root.addChild(m_Layer_Enemy);
//*/
                }
            }

            //背景
            {
                m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG_Soil));
                m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG_Grass));
            }

            //プレイヤー
            {
                m_Player = new Player();

                m_Player.SetPos(VIEW_W/2, VIEW_H/2);

                m_Layer_Player.addChild(m_Player);
            }

            //炎の表示
            {
                var bmp_view:Bitmap = new Bitmap(m_BitmapData_FireView);
                bmp_view.blendMode = BlendMode.ADD;//加算表現にすることによって、黒＝透明として扱える
                m_Layer_Fire.addChild(bmp_view);
            }

            //m_BitmapData_PerlinNoise
            {
                //普通にパーリンノイズを生成して
                const PanelLen:int = 16;//火種のおおまかな大きさ（ドット絵に使うので、１マス＝32ドットあたりを想定）
                const Octave:int = 2;//変化は雑でいい
                m_BitmapData_PerlinNoise.perlinNoise(PanelLen,PanelLen, Octave, 1000*Math.random(), true, true);
                //それを縦に２枚並べる形にして（スクロールするため。つなぎ目は気にしない）
                m_BitmapData_PerlinNoise.copyPixels(m_BitmapData_PerlinNoise, new Rectangle(0,0,VIEW_W*2,VIEW_H), new Point(0,VIEW_H));
                //減衰に使うため値を抑制
                const ratio:Number = 0.08;//小さくすると炎の伸びが大きくなる
                m_BitmapData_PerlinNoise.colorTransform(
                    m_BitmapData_PerlinNoise.rect,//VIEW_RECTとは範囲が違うので、直のrectを使う
                    new ColorTransform(ratio,ratio,ratio)//値を減衰させる
                );
            }

            //m_Palette_Fire_to_View
            {
                for(i = 0; i < 256; i++){
                    //Cosによって発火部分と消える部分の境界を薄める
                    //さらにPowによって減衰の速さを調整する（白→黄色→橙になるように）
                    var r:uint = 0xFF * (0.5 - 0.5*Math.cos(Math.PI * Math.pow(i/255, 1.0)));
                    var g:uint = 0xFF * (0.5 - 0.5*Math.cos(Math.PI * Math.pow(i/255, 1.5)));
                    var b:uint = 0xFF * (0.5 - 0.5*Math.cos(Math.PI * Math.pow(i/255, 3.0)));

                    m_Palette_Fire_to_View[i] = (0xFF<<24)|(r<<16)|(g<<8)|(b<<0);
                }
            }


            //Text
            {
                m_Text.selectable = false;
                m_Text.autoSize = TextFieldAutoSize.LEFT;
                m_Text.defaultTextFormat = new TextFormat('Verdana', 16, 0xFFFFFF, true);
                m_Text.text = '';
                m_Text.filters = [new GlowFilter(0x00FFFF,1.0, 8,8)];

                addChild(m_Text);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }

            //画像ロード開始
            {
//*
                var loader:Loader = new Loader();
                loader.load(new URLRequest(URL_GRAPHICS), new LoaderContext(true));//画像のロードを開始して
                loader.contentLoaderInfo.addEventListener(
                    Event.COMPLETE,//ロードが完了したら
                    function(e:Event):void{
                        OnLoadEnd(loader.content);//初期化に入る
                    }
                );
/*/
                OnLoadEnd(new Bitmap_Graphics());
//*/
            }
        }
        //ロード終了時の処理
        public function OnLoadEnd(in_Graphic:DisplayObject):void{
            var index_x:int;
            var index_y:int;
            var bmd:BitmapData;
            var mtx:Matrix = new Matrix(1,0,0,1, 0,0);
            var rect:Rectangle = new Rectangle(0,0, PANEL_W,PANEL_H);

            //プレイヤー画像
            {
                for(index_x = 0; index_x < PANEL_NUM_X; index_x++){
                    for(index_y = 0; index_y < PANEL_NUM_Y; index_y++){
                        bmd = Player.m_BitmapDataList[index_y][index_x];
                        //Clear
                        bmd.fillRect(rect, 0x00000000);
                        //Draw
                        mtx.tx = -index_x*PANEL_W;
                        mtx.ty = -index_y*PANEL_H;
                        bmd.draw(in_Graphic, mtx);
                    }
                }
            }

            //エネミー画像
            {
                var index_type:int;
                var offset_x:int = 0;
                var offset_y:int = 0;
                for(index_type = 0; index_type < ENEMY_NUM; index_type++){
                    switch(index_type){
                    case ENEMY_SLIME:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H*PANEL_NUM_Y * 0; break;
                    case ENEMY_BEE:
                        offset_x = PANEL_W*PANEL_NUM_X * 2; offset_y = PANEL_H*PANEL_NUM_Y * 0; break;
                    case ENEMY_GOBLIN:
                        offset_x = PANEL_W*PANEL_NUM_X * 3; offset_y = PANEL_H*PANEL_NUM_Y * 0; break;
                    case ENEMY_OGRE:
                        offset_x = PANEL_W*PANEL_NUM_X * 0; offset_y = PANEL_H*PANEL_NUM_Y * 1; break;
                    case ENEMY_SNAKE:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H*PANEL_NUM_Y * 1; break;
                    }
                    for(index_x = 0; index_x < PANEL_NUM_X; index_x++){
                        for(index_y = 0; index_y < PANEL_NUM_Y; index_y++){
                            bmd = Enemy.m_BitmapDataList[index_type][index_y][index_x];
                            //Clear
                            bmd.fillRect(rect, 0x00000000);
                            //Draw
                            mtx.tx = -offset_x - index_x*PANEL_W;
                            mtx.ty = -offset_y - index_y*PANEL_H;
                            bmd.draw(in_Graphic, mtx);
                        }
                    }
                }
            }

            //背景画像
            {
                //まずは左上に普通に描画
                {
                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 1;
                    m_BitmapData_BG_Grass.draw(in_Graphic, mtx);

                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 1 - 16;
                    m_BitmapData_BG_Soil.draw(in_Graphic, mtx);
                }

                //それをコピー
                {
                    var src_rect:Rectangle = new Rectangle(0,0,16,16);
                    var dst_point:Point = new Point(0,0);

                    for(index_x = 0; ; index_x++){
                        dst_point.x = index_x * 16;

                        if(dst_point.x > VIEW_W){break;}

                        for(index_y = 0; ; index_y++){
                            dst_point.y = index_y * 16;

                            if(dst_point.y > VIEW_H){break;}

                            if(index_x == 0 && index_y == 0){continue;}

                            m_BitmapData_BG_Grass.copyPixels(
                                m_BitmapData_BG_Grass,
                                src_rect,
                                dst_point
                            );

                            m_BitmapData_BG_Soil.copyPixels(
                                m_BitmapData_BG_Soil,
                                src_rect,
                                dst_point
                            );
                        }
                    }
                }
/*
                //ランダムな要素を加えて、均一感を減らす
                {
                    //イマイチ
                    const PanelLen:int = 64;//
                    const Octave:int = 2;//変化は雑でいい
                    m_BitmapData_Util.perlinNoise(PanelLen,PanelLen, Octave, 1000*Math.random(), true, true);

                    const ValMin:uint = 0xE0;
                    const ValMax:uint = 0xFF;
                    const Ratio:Number = 1.0 * (ValMax-ValMin)/0xFF;
                    const Offset:Number = ValMin;
                    m_BitmapData_Util.colorTransform(
                        VIEW_RECT,
                        new ColorTransform(Ratio,Ratio,Ratio,1, Offset,Offset,Offset)
                    );

                    m_BitmapData_BG_Grass.draw(m_BitmapData_Util, null, null, BlendMode.MULTIPLY);
                    m_BitmapData_BG_Soil.draw(m_BitmapData_Util, null, null, BlendMode.MULTIPLY);
                }
//*/
            }
        }


        //Update
        public function Update(e:Event=null):void{
            var DeltaTime:Number = 1.0 / stage.frameRate;

            //Check
            if(IsEnd()){return;}

            //Player
            m_Player.Update(DeltaTime);

            //Enemy
            Update_Enemy(DeltaTime);

            //炎表現
            DrawFire();
        }

        //Update : Enemy
        public function Update_Enemy(in_DeltaTime:Number):void{
            var enemy:Enemy;
            var i:int;

            //Create
            {
                const Offset:int = 32;//画面外にセットするためのオフセット

                if(m_Layer_Enemy.numChildren == 0){//全ての敵が居なくなった
                    //次の敵達を生成

                    var EnemyPattern:Array;
                    var IndexConvertMap:Array;//必要ならランダムなIDの割り当てを行う
                    {
                        if(m_EnemySeqIter < ENEMY_SEQ.length){
                            //シーケンス通りに生成
                            EnemyPattern = ENEMY_SEQ[m_EnemySeqIter];
                            //Iter++
                            m_EnemySeqIter++;
                        }else{
                            //シーケンスが終わったのでランダムに生成してみる
                            var Iter:int = Math.random() * ENEMY_SEQ_AUTO.length;
                            EnemyPattern = ENEMY_SEQ_AUTO[Iter];

                            //X,Y,Zの指定を、それぞれランダムに決定する
                            IndexConvertMap = new Array(3);
                            IndexConvertMap[X] = int(Math.random() * ENEMY_NUM);
                            IndexConvertMap[Y] = int(Math.random() * ENEMY_NUM);
                            IndexConvertMap[Z] = int(Math.random() * ENEMY_NUM);
                        }
                    }

                    //EnemyPatternを元に生成
                    {
                        var NumY:int = EnemyPattern.length;

                        var AppearDir:int = 0;
                        for(var IndexY:int = 0; IndexY < NumY; IndexY++){
                            var NumX:int = EnemyPattern[IndexY].length;

                            var EnemyY:int;
                            {
                                if(IndexY == 0){
                                    //上から出てくる
                                    EnemyY = -Offset;
                                    AppearDir = Enemy.APPEAR_U;
                                }else{
                                    if(IndexY == NumY-1){
                                        //下から出てくる
                                        EnemyY = VIEW_H + Offset;
                                        AppearDir = Enemy.APPEAR_D;
                                    }else{
                                        //それ以外は横から出てくる
                                        EnemyY = VIEW_H * (IndexY-0.5) / (NumY-2);
                                    }
                                }
                            }

                            for(var IndexX:int = 0; IndexX < NumX; IndexX++){
                                var EnemyX:int;
                                {
                                    if(IndexY == 0 || IndexY == NumY-1){
                                        //上下から出てくる
                                        EnemyX = VIEW_W * (IndexX+0.5) / NumX;
                                    }else{
                                        //左右から出てくる
                                        if(IndexX < NumX/2){
                                            //左から出てくる
                                            EnemyX = -Offset;
                                            AppearDir = Enemy.APPEAR_L;
                                        }else{
                                            //右から出てくる
                                            EnemyX = VIEW_W + Offset;
                                            AppearDir = Enemy.APPEAR_R;
                                        }
                                    }
                                }

                                enemy = new Enemy();
                                {
                                    enemy.Set_Pos(EnemyX, EnemyY);

                                    enemy.m_Index = EnemyPattern[IndexY][IndexX];
                                    if(IndexConvertMap){enemy.m_Index = IndexConvertMap[enemy.m_Index];}//変換先があれば変換

                                    enemy.m_AppearDir = AppearDir;
                                }

                                m_Layer_Enemy.addChild(enemy);
                            }
                        }
                    }
                }
            }

            //Update
            {
                var num:int = m_Layer_Enemy.numChildren;
                for(i = 0; i < num; i++){
                    enemy = m_Layer_Enemy.getChildAt(i) as Enemy;

                    //Update
                    enemy.Update(in_DeltaTime);

                    //KillCheck
                    if(enemy.m_KillFlag){
                        enemy.parent.removeChild(enemy);
                        num--;//減少
                        i--;//相殺
                    }
                }
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

            //スコア表示
            {
                ScoreWindowLoader.show(m_Score);
            }
        }

        //#IsGameOver
        public function IsEnd():Boolean{
            return (m_Mode != MODE_MAIN);
        }


        //#Fire : Add
        private var fire_shape:Shape = new Shape();
        public function EmitFire(in_SrcX:Number, in_SrcY:Number, in_DstX:Number, in_DstY:Number):void{
            var g:Graphics = fire_shape.graphics;

            {
                g.clear();
                g.lineStyle(FIRE_LINE_W, 0x0000FF, 1.0);
                g.moveTo(in_SrcX, in_SrcY);
                g.lineTo(in_DstX, in_DstY);
            }

            //発火元として描画
            {
                m_BitmapData_FireEmit.draw(fire_shape);
            }
        }


        //DrawFire：炎の自動描画
        public function DrawFire():void{
            //囲まれた部分も発火させる
            {
                //まずは全体を発火させる
                m_BitmapData_Flood.fillRect(m_BitmapData_Flood.rect, 0x0000E0);

                //発火部分をくりぬく
                //m_BitmapData_Flood.draw(m_BitmapData_FireEmit, null, null, BlendMode.SUBTRACT);
                const threshold:uint = 0xA0;//これが低いと、消えて見えるような線でも発火してしまう
                m_BitmapData_Flood.threshold(m_BitmapData_FireEmit, VIEW_RECT, POS_ONE, ">", threshold, 0x000000, 0xFF);

                //画面外から塗りつぶしで全体を鎮火する
                m_BitmapData_Flood.floodFill(VIEW_W,0, 0x000000);

                //ついでにブラーもかけてみる
                //m_BitmapData_Flood.applyFilter(m_BitmapData_Flood, VIEW_RECT, POS_ZERO, m_Filter_FireBlur);
            }

            //発火部分の描画
            {
                //発火元を描画
                m_BitmapData_FireData.draw(m_BitmapData_FireEmit, null, null, BlendMode.LIGHTEN);

                //囲まれた部分も追加
                m_BitmapData_FireData.draw(m_BitmapData_Flood, MTX_FOR_FLOOD, null, BlendMode.LIGHTEN);

                //発火元の時間減衰
                m_BitmapData_FireEmit.colorTransform(VIEW_RECT, m_CT_Dec);
            }

            //背景への干渉
            {//草の部分のαを０にして、土の方が表示されるようにする
                //αをコピー
                m_BitmapData_Util.copyChannel(m_BitmapData_BG_Grass, VIEW_RECT, POS_ZERO, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
                //炎のある部分のαを0にする
                m_BitmapData_Util.threshold(m_BitmapData_FireData, VIEW_RECT, POS_ZERO, ">", 0xD0, 0x00000000, 0xFF);
                m_BitmapData_Util.threshold(m_BitmapData_Flood, VIEW_RECT, POS_ZERO, ">", 0xD0, 0x00000000, 0xFF);
                //αを戻す
                m_BitmapData_BG_Grass.copyChannel(m_BitmapData_Util, VIEW_RECT, POS_ZERO, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
            }

            //描画処理
            {
                //ブラーで炎を広げる
                {
                    //薄めることで、上の方を細くする効果も兼ねる
                    m_BitmapData_FireData.applyFilter(m_BitmapData_FireData, VIEW_RECT, POS_ZERO, m_Filter_FireBlur);
                }

                //全体的に沈静化
                {
                    //パーリンノイズで減衰することで揺らぎを表現
                    m_BitmapData_FireData.draw(m_BitmapData_PerlinNoise, m_Mtx_PerlinNoise, null, BlendMode.SUBTRACT);
                }

                //そして0x00～0xFFの値を炎の色に置き換えて表示
                {
                    m_BitmapData_FireView.paletteMap(m_BitmapData_FireData, VIEW_RECT, POS_ZERO, null,null,m_Palette_Fire_to_View);
                }
            }

            //次回用の更新
            {
                const ScrollVal:int = 2;

                //炎を上にスクロールさせて、燃え上がりを実現
                {
                    //切り捨てて良いスクロールなので、普通にscrollを呼ぶ
                    m_BitmapData_FireData.scroll(0, -ScrollVal);
                }

                //パーリンノイズの採用位置を変更
                {
                    //横方向には少しだけ振動させ、上下方向は炎の上昇と合わせることで、それっぽい揺らぎを作り出す
                    //m_Mtx_PerlinNoise.tx += (Math.random() < 0.5)? 1: -1;//振動
                    m_Mtx_PerlinNoise.ty -= ScrollVal;//追随
                    //範囲チェック
                    //if(m_Mtx_PerlinNoise.tx > 0){m_Mtx_PerlinNoise.tx -= 2;}//範囲外は押し戻す
                    if(m_Mtx_PerlinNoise.tx < -VIEW_W){m_Mtx_PerlinNoise.tx += 2;}
                    if(m_Mtx_PerlinNoise.ty < -VIEW_H){m_Mtx_PerlinNoise.ty += VIEW_H;}//下にワープ
                }
            }
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

    //アニメーション用定数
    static public const ANIM_DIR_U:int = 0;
    static public const ANIM_DIR_R:int = 1;
    static public const ANIM_DIR_D:int = 2;
    static public const ANIM_DIR_L:int = 3;

    //アニメーション用パラメータ
    static public const ANIM_CYCLE:Number = 1.0;
    static public const ANIM_ITER:Array = [0,1,2,1];
    static public const ANIM_NUM:int = ANIM_ITER.length;


    //==Static==

    //画像
    static public var m_BitmapDataList:Array;

    //Init
    static public function Initialize():void{
        //m_BitmapDataList
        {
            m_BitmapDataList = new Array(GameMain.PANEL_NUM_Y);
            for(var y:int = 0; y < GameMain.PANEL_NUM_Y; y++){
                m_BitmapDataList[y] = new Array(GameMain.PANEL_NUM_X);
                for(var x:int = 0; x < GameMain.PANEL_NUM_X; x++){
                    m_BitmapDataList[y][x] = new BitmapData(GameMain.PANEL_W, GameMain.PANEL_H, true, 0xFF0000FF);
                }
            }
        }
    }


    //==Var==

    //移動まわりのパラメータ
    public var m_Pos:Point = new Point(0,0);
    public var m_Vel:Point = new Point(0,0);

    //グラフィック
    public var m_Bitmap:Bitmap = new Bitmap();
    //アニメーションの方向
    public var m_AnimDir:int = 0;
    //アニメーション用タイマー
    public var m_AnimTimer:Number = 0.0;

    //死亡フラグ
    public var m_IsDead:Boolean = false;


    //==Function==

    //Init
    public function Player(){
        //プレイヤーグラフィック
        {
            m_Bitmap.x = -GameMain.PANEL_W/2;
            m_Bitmap.y = -GameMain.PANEL_H*3/4;
            addChild(m_Bitmap);
        }
    }

    //Init : Pos
    public function SetPos(in_X:int, in_Y:int):void{
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
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

        m_Bitmap.bitmapData = m_BitmapDataList[m_AnimDir][iter];
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
//*/
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        var OldX:Number = m_Pos.x;
        var OldY:Number = m_Pos.y;

        //マウスの位置に移動しようとする
        {
            //想定移動先
            var DstX:Number = GameMain.Instance.mouseX;
            var DstY:Number = GameMain.Instance.mouseY;

            //今の位置
            var SrcX:Number = m_Pos.x;
            var SrcY:Number = m_Pos.y;

/*
            //=目標位置に直接移動ver.=

            m_Pos.x = DstX;
            m_Pos.y = DstY;

            //→いまいち「プレイヤーを動かしている」という感覚がない
//*/

//*
            //=適当に移動ver.=
            const LerpRatio:Number = 0.2;
            m_Pos.x = Lerp(SrcX, DstX, LerpRatio);
            m_Pos.y = Lerp(SrcY, DstY, LerpRatio);

            //→比較的良好だが、もう少し「物理的な感じ」を出したい
//*/

//*
            //=慣性つきver.=

            //DeltaTimeとかは考慮しない速度

            const Pow:Number = 0.02;
            m_Vel.x += (DstX - SrcX) * Pow;
            m_Vel.y += (DstY - SrcY) * Pow;

            m_Pos.x += m_Vel.x;
            m_Pos.y += m_Vel.y;

            const DecRatio:Number = 0.9;
            m_Vel.x *= DecRatio;
            m_Vel.y *= DecRatio;
//*/

/*
            //=等速移動ver.=

            //→「物理的な感じ」が出そうにないので作成保留
//*/
        }

        var NewX:Number = m_Pos.x;
        var NewY:Number = m_Pos.y;

        //移動軌跡を炎化する
        {
            GameMain.Instance.EmitFire(OldX,OldY, NewX,NewY);
        }

        //移動方向をキャラの向きにする
        {
            const Threshold:Number = 0.5;//一フレームあたりの移動量がこれ以下なら、向きの変更をしない

            var AbsGapX:Number = Math.abs(NewX - OldX);
            var AbsGapY:Number = Math.abs(NewY - OldY);

            if(AbsGapX > AbsGapY){
                if(AbsGapX > Threshold){
                    if(NewX < OldX){
                        m_AnimDir = ANIM_DIR_L;
                    }else{
                        m_AnimDir = ANIM_DIR_R;
                    }
                }
            }else{
                if(AbsGapY > Threshold){
                    if(NewY < OldY){
                        m_AnimDir = ANIM_DIR_U;
                    }else{
                        m_AnimDir = ANIM_DIR_D;
                    }
                }
            }
        }

        //反映
        {
            this.x = m_Pos.x;
            this.y = m_Pos.y;
        }
    }

    //Utility
    public function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
        return (in_Src * (1 - in_Ratio)) + (in_Dst * in_Ratio);
    }
}


//#Enemy
class Enemy extends Sprite
{
    //==Const==

    //出現開始位置
    static public var AppearDirIter:int = 0;
    static public const APPEAR_U:int = AppearDirIter++;
    static public const APPEAR_D:int = AppearDirIter++;
    static public const APPEAR_L:int = AppearDirIter++;
    static public const APPEAR_R:int = AppearDirIter++;

    //スライムの移動速度
    static public const VEL_SLIME:Number = 3.0;

    //ビーの移動速度
    static public const VEL_BEE:Number = 9.0;

    //ゴブリンの移動速度
    static public const VEL_GOBLIN:Number = 3.0;

    //オーガの移動速度
    static public const VEL_OGRE:Number = 1.0;

    //スネークの移動速度
    static public const VEL_SNAKE:Number = 10.0;

    //アニメーション用定数
    static public const ANIM_DIR_U:int = 0;
    static public const ANIM_DIR_R:int = 1;
    static public const ANIM_DIR_D:int = 2;
    static public const ANIM_DIR_L:int = 3;

    //アニメーション用パラメータ
    static public const ANIM_CYCLE:Number = 1.0;
    static public const ANIM_ITER:Array = [0,1,2,1];
    static public const ANIM_NUM:int = ANIM_ITER.length;


    //==Static==

    //画像
    static public var m_BitmapDataList:Array;

    //Init
    static public function Initialize():void{
        //m_BitmapDataList
        {
            m_BitmapDataList = new Array(GameMain.ENEMY_NUM);
            for(var type:int = 0; type < GameMain.ENEMY_NUM; type++){
                m_BitmapDataList[type] = new Array(GameMain.PANEL_NUM_Y);
                for(var y:int = 0; y < GameMain.PANEL_NUM_Y; y++){
                    m_BitmapDataList[type][y] = new Array(GameMain.PANEL_NUM_X);
                    for(var x:int = 0; x < GameMain.PANEL_NUM_X; x++){
                        m_BitmapDataList[type][y][x] = new BitmapData(GameMain.PANEL_W, GameMain.PANEL_H, true, 0xFFFF0000);
                    }
                }
            }
        }
    }


    //==Var==

    //Type
    public var m_Index:int = 0;

    //出現開始位置
    public var m_AppearDir:int = 0;

    //位置（小数点込み）
    public var m_Pos:Point = new Point();

    //グラフィック
    public var m_Bitmap:Bitmap = new Bitmap();
    //アニメーションの方向
    public var m_AnimDir:int = 0;
    //アニメーション用タイマー
    public var m_AnimTimer:Number = 0.0;

    //
    public var m_KillFlag:Boolean = false;

    //Util
    public var m_UtilPoint:Point = new Point();


    //==Function==

    //Init
    public function Enemy(){
        {
            m_Bitmap.x = -GameMain.PANEL_W/2;
            m_Bitmap.y = -GameMain.PANEL_H*3/4;
            addChild(m_Bitmap);
        }
    }

    //Set : Pos
    public function Set_Pos(in_X:Number, in_Y:Number):void{
        this.x = m_Pos.x = in_X;
        this.y = m_Pos.y = in_Y;
    }

    //Add : Pos
    public function Add_Pos(in_X:Number, in_Y:Number):void{
        this.x = (m_Pos.x += in_X);
        this.y = (m_Pos.y += in_Y);
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        //移動
        Update_Move(in_DeltaTime);

        //アニメーション
        Update_Graphic(in_DeltaTime);

        //プレイヤーとの衝突チェック
        Check_Hit();

        //死亡チェック
        Check_Dead();
    }

    //Update : Graphic
    public function Update_Graphic(in_DeltaTime:Number):void{
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

        m_Bitmap.bitmapData = m_BitmapDataList[m_Index][m_AnimDir][iter];

        //ついでにオーガをスケーリング
        if(m_Index == GameMain.ENEMY_OGRE){
            m_Bitmap.scaleX = m_Bitmap.scaleY = 2;
        }
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        var OldX:Number = m_Pos.x;
        var OldY:Number = m_Pos.y;

        var gap:Number;

        switch(m_Index){
        case GameMain.ENEMY_SLIME:
            //単純に逆サイドに移動
            switch(m_AppearDir){
            case APPEAR_U:
                Add_Pos(0, VEL_SLIME);
                break;
            case APPEAR_D:
                Add_Pos(0,-VEL_SLIME);
                break;
            case APPEAR_L:
                Add_Pos( VEL_SLIME, 0);
                break;
            case APPEAR_R:
                Add_Pos(-VEL_SLIME, 0);
                break;
            }
            break;
        case GameMain.ENEMY_BEE:
            //Aim
            {
                //本当は初期化時にやりたいが、ちゃんと作るのも面倒なので適当に
                if(m_UtilPoint.length <= 0){
                    m_UtilPoint.x = GameMain.Instance.mouseX - m_Pos.x;
                    m_UtilPoint.y = GameMain.Instance.mouseY - m_Pos.y;
                    gap = m_UtilPoint.length;
                    if(gap > 0){
                        m_UtilPoint.normalize(VEL_BEE);
                    }else{
                        m_UtilPoint.y = VEL_GOBLIN;//ないとは思うが、同じ位置なら一応下に行かせてみる
                    }
                }

                Add_Pos(m_UtilPoint.x, m_UtilPoint.y);
            }
            break;
        case GameMain.ENEMY_GOBLIN:
            //Homing
            {
                m_UtilPoint.x = GameMain.Instance.mouseX - m_Pos.x;
                m_UtilPoint.y = GameMain.Instance.mouseY - m_Pos.y;
                gap = m_UtilPoint.length;
                if(gap > 0){
                    m_UtilPoint.normalize(VEL_GOBLIN);
                }else{
                    m_UtilPoint.y = VEL_GOBLIN;//ないとは思うが、同じ位置なら一応下に行かせてみる
                }
                Add_Pos(m_UtilPoint.x, m_UtilPoint.y);
            }
            break;
        case GameMain.ENEMY_OGRE:
            //Homing
            {
                m_UtilPoint.x = GameMain.Instance.mouseX - m_Pos.x;
                m_UtilPoint.y = GameMain.Instance.mouseY - m_Pos.y;
                gap = m_UtilPoint.length;
                if(gap > 0){
                    m_UtilPoint.normalize(VEL_OGRE + GameMain.Instance.m_Score/20);
                }else{
                    m_UtilPoint.y = VEL_OGRE;//ないとは思うが、同じ位置なら一応下に行かせてみる
                }
                Add_Pos(m_UtilPoint.x, m_UtilPoint.y);
            }
            break;
        case GameMain.ENEMY_SNAKE:
            //Escape
            {
                //マウスの位置を少し補正して端に追い詰められないようにして
                var PseudoMouseX:Number = (GameMain.Instance.mouseX - GameMain.VIEW_W/2) * 1.2 + GameMain.VIEW_W/2;
                var PseudoMouseY:Number = (GameMain.Instance.mouseY - GameMain.VIEW_H/2) * 1.2 + GameMain.VIEW_H/2;
                //その位置の逆に動く
                m_UtilPoint.x = m_Pos.x - PseudoMouseX;
                m_UtilPoint.y = m_Pos.y - PseudoMouseY;
                if(m_UtilPoint.length < 1){m_UtilPoint.x = 1;}
                m_UtilPoint.normalize(VEL_SNAKE);//長さをVEL_SNAKEに整える

                //範囲制限
                if(m_Pos.x + m_UtilPoint.x < GameMain.PANEL_W){
                    m_UtilPoint.x = GameMain.PANEL_W - m_Pos.x;
                }
                if(m_Pos.x + m_UtilPoint.x > GameMain.VIEW_W-GameMain.PANEL_W){
                    m_UtilPoint.x = GameMain.VIEW_W-GameMain.PANEL_W - m_Pos.x;
                }
                if(m_Pos.y + m_UtilPoint.y < GameMain.PANEL_H){
                    m_UtilPoint.y = GameMain.PANEL_H - m_Pos.y;
                }
                if(m_Pos.y + m_UtilPoint.y > GameMain.VIEW_H-GameMain.PANEL_H){
                    m_UtilPoint.y = GameMain.VIEW_H-GameMain.PANEL_H - m_Pos.y;
                }

                //範囲制限を考慮して、再び長さを整える
                if(m_UtilPoint.length > VEL_SNAKE){m_UtilPoint.normalize(VEL_SNAKE);}

                //実際に移動
                Add_Pos(m_UtilPoint.x, m_UtilPoint.y);
            }
            break;
        default://Err
            //単純に下移動
            Add_Pos(0, 3);
            break;
        }

        var NewX:Number = m_Pos.x;
        var NewY:Number = m_Pos.y;

        //移動方向をキャラの向きにする
        {
            const Threshold:Number = 1.0;//一フレームあたりの移動量がこれ以下なら、向きの変更をしない

            var AbsGapX:Number = Math.abs(NewX - OldX);
            var AbsGapY:Number = Math.abs(NewY - OldY);

            if(AbsGapX > AbsGapY){
                if(AbsGapX > Threshold){
                    if(NewX < OldX){
                        m_AnimDir = ANIM_DIR_L;
                    }else{
                        m_AnimDir = ANIM_DIR_R;
                    }
                }
            }else{
                if(AbsGapY > Threshold){
                    if(NewY < OldY){
                        m_AnimDir = ANIM_DIR_U;
                    }else{
                        m_AnimDir = ANIM_DIR_D;
                    }
                }
            }
        }
    }

    //Check : Hit
    public function Check_Hit():void{
        //プレイヤーとの距離が一定範囲内であれば衝突したものとする

        //Check
        if(m_KillFlag){return;}

        var GapX:Number = m_Pos.x - GameMain.Instance.m_Player.m_Pos.x;
        var GapY:Number = m_Pos.y - GameMain.Instance.m_Player.m_Pos.y;

        var Distance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

        if(Distance < GameMain.PANEL_W*0.6){
            GameMain.Instance.OnDead_Damage();
        }
    }

    //Check : Dead
    public function Check_Dead():void{
        //炎死チェック
        Check_Dead_Fire();

        //範囲外チェック
        Check_Dead_Range();
    }
    //Check : Dead : Fire
    public function Check_Dead_Fire():void{
        const FireFlag:Boolean = true;//死ぬなら焼死

        //Ogre
        if(m_Index == GameMain.ENEMY_OGRE){
            //オーガは囲まれた場合にしか死なない
            if(GameMain.Instance.m_BitmapData_Flood.getPixel(this.x, this.y) > 0x00){
                Dead(FireFlag);
            }
            return;
        }

        //Default
        if(GameMain.Instance.m_BitmapData_FireData.getPixel(this.x, this.y) > 0x60){
            Dead(FireFlag);
        }
    }
    //Check : Dead : Range
    public function Check_Dead_Range():void{
        const Range:int = GameMain.VIEW_W/2;
        if((this.x < -Range) || (GameMain.VIEW_W+Range < this.x) || (this.y < -Range) || (GameMain.VIEW_H+Range < this.y)){
            Dead();
        }
    }

    //Dead
    public function Dead(in_FireFlag:Boolean = false):void{
        m_KillFlag = true;

        if(in_FireFlag){
            //エネミーの形状をそのまま火種として登録してみる
            var mtx:Matrix = new Matrix(1,0,0,1, this.x,this.y);
            var ct:ColorTransform = new ColorTransform(1,1,1,1, -0xFF,-0xFF,0xFF);
            GameMain.Instance.m_BitmapData_FireEmit.draw(this, mtx, ct);

            //焼死時のみスコアとして加算
            GameMain.Instance.m_Score++;
            
            //
            GameMain.Instance.m_Text.text = GameMain.Instance.m_Score.toString();
        }
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
    private static const TWEET: String = "Playing FLARE.TAIL [score: %SCORE%] #wonderfl";
    
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
        var window: DisplayObject = _content.makeScoreWindow(_api, score, "FLARE.TAIL", 1, TWEET);
//        var close: Function = function(e: Event): void
//        {
//            window.removeEventListener(Event.CLOSE, close);
//            closeHandler();
//        }
//        window.addEventListener(Event.CLOSE, close);
        _top.addChild(window);
    }
    
}
