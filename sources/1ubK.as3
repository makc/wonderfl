/*
　「断斬～Touch＆Kill～」
　・クリックでキャラを移動させ、エネミーを倒すゲーム

　操作方法
　・クリック
　　・クリック位置にキャラクターが移動
　　・移動中に接触するとエネミーを倒せる
*/

/*
ToDo

処理
・ボス
　・ボスを倒したらスコアへ
・エネミー：ゴースト
　・当たり判定の定期オンオフ
　・今回は不要っぽいので作成保留

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
    import net.wonderfl.utils.WonderflAPI;
 
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class GameMain extends Sprite {
        //==Const==

        //画像のリソース位置
//*
        //wonderfl用ロード型
        static public const URL_GRAPHICS:String = "http://assets.wonderfl.net/images/related_images/0/06/06f2/06f2388a4ff3e3640a4afd47d26dc33881112f6b";
//*/
/*
        //確認用ローカルロード型
        static public const URL_GRAPHICS:String = "TouchKill.png";
//*/
/*
        //ブログ用埋め込み型
        [Embed(source='TouchKill.png')]
         private static var Bitmap_Graphics: Class;
//*/

        //画面の大きさ
        static public const VIEW_W:int = 465;
        static public const VIEW_H:int = 465;

        //エネミーの当たり判定（直径）
        static public const HIT_RANGE:int = 32;

        //画像サイズ
        static public const PANEL_W:int = 24;
        static public const PANEL_H:int = 32;
        static public const BMP_W:int = 24;
        static public const BMP_H:int = 40;//陰用に元画像より少し下に長くする
        static public const PANEL_NUM_X:int = 3;
        static public const PANEL_NUM_Y:int = 4;


        //エネミーの出現パターン
        static public var EnemyIter:int = 0;
        static public const GB:int = EnemyIter++;//TYPE_GOBLIN
        static public const SN:int = EnemyIter++;//TYPE_SNAKE
        static public const OG:int = EnemyIter++;//TYPE_OGRE
        static public const GH:int = EnemyIter++;//TYPE_GOHST
        static public const HU:int = EnemyIter++;//TYPE_HUMAN
        static public const BS:int = EnemyIter++;//TYPE_BOSS
        static public const FR:int = EnemyIter++;//TYPE_FIRE
        static public const XX:int = EnemyIter++;//EMPTY
        //ステージ構成
        //- 下から順に出てくるので注意
        static public const ENEMY_SEQ:Array = [
            //#ボス戦
            [XX, BS, XX],
//*
            [XX, XX, XX],
            [XX, XX, XX],
            [XX, XX, XX],
            [XX, XX, XX],

            //#人質に紛れて突入
            [XX, XX, XX],
            [XX, XX, XX],
            [HU, GB, HU],
            [HU, GB, HU],
            [HU, GB, HU],
            [XX, XX, XX],
            [XX, XX, XX],
            [HU, HU, HU],
            [XX, GB, XX],
            [HU, HU, HU],
            [XX, XX, XX],
            [XX, OG, XX],

            //#人質の帰還
            [XX, XX, XX],
            [XX, XX, XX],
            [XX, XX, HU],
            [HU, XX, XX],
            [XX, HU, XX],

            //#オーグ登場
            [XX, XX, XX],
            [XX, XX, XX],
            [OG, XX, OG],
            [XX, XX, XX],
            [XX, OG, XX],

            //#ゴブリンとスネークの混合
            [XX, XX, XX],
            [XX, XX, XX],
            [XX, SN, XX],
            [XX, XX, XX],
            [GB, SN, GB],
            [XX, XX, XX],
            [GB, XX, GB],

            //#スネークで奇襲
            [XX, XX, XX],
            [XX, XX, XX],
            [SN, XX, SN],
            [XX, XX, XX],
            [XX, SN, XX],

            //#斜め
            [XX, XX, XX],
            [XX, XX, XX],
            [XX, XX, GB],
            [XX, GB, XX],
            [GB, XX, XX],
            [XX, XX, XX],
            [GB, XX, XX],
            [XX, GB, XX],
            [XX, XX, GB],

            //#ゴブリンで小手調べ
            [XX, XX, XX],
            [XX, XX, XX],
            [GB, GB, GB],
            [XX, XX, XX],
            [GB, GB, GB],
            [XX, XX, XX],
            [GB, GB, GB],
//*/
        ];

        //==Var==

        //Pseudo Singleton
        static public var Instance:GameMain;

        //レイヤー
        public var m_Layer_Root:Sprite = new Sprite();
        public var  m_Layer_BG:Sprite = new Sprite();
        public var  m_Layer_Enemy:Sprite = new Sprite();
        public var  m_Layer_Player:Sprite = new Sprite();
        public var  m_Layer_Effect:Sprite = new Sprite();

        //プレイヤー
        public var m_Player:Player;

        //エネミー
        public var m_EnemyTimer:Number = 0;//生成管理用タイマー
        //エネミーの出現管理用のイテレータ
        public var m_EnemySeqIter:int = ENEMY_SEQ.length-1;

        //背景
        public var m_BitmapData_BG:BitmapData = new BitmapData(VIEW_W, VIEW_H, false, 0x000000);

        //ガイドライン
        public var m_GuideLine:Graphics;

        //スコア
        public var m_Score:int = 0;
        public var m_GlobalCombo:int = 0;
        public var m_ScoreDataBegin:ScoreData;

        //テキスト
        public var m_Text:TextField = new TextField();
        public var m_Text_Score:TextField = new TextField();

        //==Function==

        //Init
        public function GameMain() {
            var i:int;

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
                    //背景
                    m_Layer_Root.addChild(m_Layer_BG);

                    //キャラクター：エネミー
                    m_Layer_Root.addChild(m_Layer_Enemy);
                    //キャラクター：プレイヤー
                    m_Layer_Root.addChild(m_Layer_Player);

                    //UI：スコア
                    m_Layer_Root.addChild(m_Layer_Effect);
                }
            }

            //背景
            {
                m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG));
            }

            //ガイドライン
            {
                var s:Sprite = new Sprite();
                m_GuideLine = s.graphics;

                m_Layer_BG.addChild(s);
            }

            //プレイヤー
            {
                m_Player = new Player();

                //左中央に配置
                m_Player.x = VIEW_W/8;
                m_Player.y = VIEW_H/2;

                m_Layer_Player.addChild(m_Player);
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

            //Click
            {
                stage.addEventListener(
                    MouseEvent.CLICK,
                    onClick
                );
                stage.addEventListener(
                    MouseEvent.MOUSE_MOVE,
                    onMove
                );
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
            var rect:Rectangle = new Rectangle(0,0, BMP_W,BMP_H);
            var clip_rect:Rectangle = new Rectangle(0,0, PANEL_W,PANEL_H);
            const pos_zero:Point = new Point(0,0);

            //足元の影画像
            var bmd_shadow:BitmapData = new BitmapData(BMP_W, BMP_H, true, 0x00000000);
            {
                var shadow_sp:Sprite = new Sprite();
                var g:Graphics = shadow_sp.graphics;
                g.lineStyle(0,0,0);
                g.beginFill(0x000000, 0.6);
                g.drawEllipse(0, BMP_H-BMP_W/2, BMP_W, BMP_W/2);
                g.endFill();
                bmd_shadow.draw(shadow_sp);
            }

            //プレイヤー画像
            {
                for(index_x = 0; index_x < PANEL_NUM_X; index_x++){
                    for(index_y = 0; index_y < PANEL_NUM_Y; index_y++){
                        bmd = Player.m_BitmapDataList[index_y][index_x];
                        //Clear
                        bmd.copyPixels(bmd_shadow, rect, pos_zero);
                        //Draw
                        mtx.tx = -index_x*PANEL_W;
                        mtx.ty = -index_y*PANEL_H;
                        bmd.draw(in_Graphic, mtx, null, null, clip_rect);
                    }
                }
            }

            //エネミー画像
            {
                var index_type:int;
                var offset_x:int = 0;
                var offset_y:int = 0;
                index_y = 0;
                for(index_type = 0; index_type < Enemy.TYPE_NUM; index_type++){
                    switch(index_type){
                    case Enemy.TYPE_GOBLIN:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H * 0; break;
                    case Enemy.TYPE_SNAKE:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H * 1; break;
                    case Enemy.TYPE_OGRE:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H * 2; break;
                    case Enemy.TYPE_GOHST:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H * 0; break;
                    case Enemy.TYPE_HUMAN:
                        offset_x = PANEL_W*PANEL_NUM_X * 1; offset_y = PANEL_H * 3; break;
                    case Enemy.TYPE_BOSS:
                        offset_x = PANEL_W*PANEL_NUM_X * 2; offset_y = PANEL_H * 3; break;
                    case Enemy.TYPE_FIRE:
                        offset_x = PANEL_W*PANEL_NUM_X * 2; offset_y = PANEL_H * 2; break;
                    }
                    for(index_x = 0; index_x < PANEL_NUM_X; index_x++){
                        bmd = Enemy.m_BitmapDataList[index_type][index_x];
                        //Clear
                        bmd.copyPixels(bmd_shadow, rect, pos_zero);
                        //Draw
                        mtx.tx = -offset_x - index_x*PANEL_W;
                        mtx.ty = -offset_y - index_y*PANEL_H;
                        bmd.draw(in_Graphic, mtx, null, null, clip_rect);
                    }
                }
            }

            //背景画像
            {
                clip_rect.width  = 16;
                clip_rect.height = 16;

                //まずは個別の画像を一旦保持
                var bmd_bg_g:BitmapData = new BitmapData(16,16,false,0x000000);
                var bmd_bg_s:BitmapData = new BitmapData(16,16,false,0x000000);
                var bmd_bg_l:BitmapData = new BitmapData(16,16,false,0x000000);
                var bmd_bg_r:BitmapData = new BitmapData(16,16,false,0x000000);
                {
                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2 - 16*1;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 0;
                    bmd_bg_g.draw(in_Graphic, mtx);

                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2 - 16*1;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 0 - 16 * 2;
                    bmd_bg_s.draw(in_Graphic, mtx);

                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2 - 16*0;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 0 - 16 * 2;
                    bmd_bg_l.draw(in_Graphic, mtx);

                    mtx.tx = -PANEL_W*PANEL_NUM_X * 2 - 16*2;
                    mtx.ty = -PANEL_H*PANEL_NUM_Y * 0 - 16 * 2;
                    bmd_bg_r.draw(in_Graphic, mtx);
                }

                //上のラインに敷き詰める
                {
                    var offset:int = 8;
                    mtx.ty = 0;

                    var CenterX:int = VIEW_W/2;

                    bmd = bmd_bg_s;
                    for(; offset < VIEW_W*6/20; offset += 16){
                        mtx.tx = CenterX + offset - 8;
                        m_BitmapData_BG.draw(bmd, mtx);

                        mtx.tx = CenterX - offset - 8;
                        m_BitmapData_BG.draw(bmd, mtx);
                    }

                    {
                        mtx.tx = CenterX + offset - 8;
                        m_BitmapData_BG.draw(bmd_bg_r, mtx);

                        mtx.tx = CenterX - offset - 8;
                        m_BitmapData_BG.draw(bmd_bg_l, mtx);

                        offset += 16;
                    }

                    bmd = bmd_bg_g;
                    for(; offset < VIEW_W/2 + 16; offset += 16){
                        mtx.tx = CenterX + offset - 8;
                        m_BitmapData_BG.draw(bmd, mtx);

                        mtx.tx = CenterX - offset - 8;
                        m_BitmapData_BG.draw(bmd, mtx);
                    }
                }

                //それを下にコピー
                {
                    var src_rect:Rectangle = new Rectangle(0,0,VIEW_W,16);
                    var dst_point:Point = new Point(0,0);

                    for(index_y = 1; ; index_y++){
                        dst_point.y = index_y * 16;

                        if(dst_point.y > VIEW_H){break;}

                        m_BitmapData_BG.copyPixels(
                            m_BitmapData_BG,
                            src_rect,
                            dst_point
                        );
                    }
                }
            }
        }

        //Move
        public function onMove(e:MouseEvent):void{
            m_GuideLine.clear();
            m_GuideLine.lineStyle(4, 0xFF0000, 0.5);
            m_GuideLine.moveTo(m_Player.x, m_Player.y);
            m_GuideLine.lineTo(m_Player.parent.mouseX, m_Player.parent.mouseY);
        }
        //Click
        public function onClick(e:MouseEvent):void{
            var i:int;
            var j:int;
            var num:int;
            var enemy:Enemy;

            var SrcX:int = m_Player.x;
            var SrcY:int = m_Player.y;
            var DstX:int = m_Player.parent.mouseX;
            var DstY:int = m_Player.parent.mouseY;

            var GapX:int = DstX - SrcX;
            var GapY:int = DstY - SrcY;
            var MoveDistance:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            m_GuideLine.clear();

            //移動してないなら何もしない
            if(MoveDistance < 1){
                return;
            }

            //攻撃処理
            //この時点ではフラグを立てるだけで、すぐにKillはしない？
            num = m_Layer_Enemy.numChildren;
            for(i = 0; i < num; i++){
                enemy = m_Layer_Enemy.getChildAt(i) as Enemy;

                var EnemyGapX:int = enemy.x - SrcX;
                var EnemyGapY:int = enemy.y - SrcY;

                //進行方向に対する内積
                var DistanceForward:Number = (GapX*EnemyGapX + GapY*EnemyGapY) / MoveDistance;
                if(0 <= DistanceForward && DistanceForward < MoveDistance){
                    //進行横方向に対する内積
                    var DistanceSide:Number = (GapY*EnemyGapX - GapX*EnemyGapY) / MoveDistance;
                    if(-HIT_RANGE <= DistanceSide && DistanceSide <= HIT_RANGE){
                        //ダメージを与える
                        enemy.onDamage(1);

                        //スコア計算用準備
                        //- 人質が途中に入っていたらそこでリセットされるため、あとでまとめてチェックする

                        //距離に基づくソート
                        PushScore(
                            DistanceForward,
                            enemy.x,
                            enemy.y,
                            enemy.m_Type
                        );
                    }
                }
            }

            //スコアを実際に計算
            RefreshScore();

            //Effect
            m_Layer_Effect.addChild(new SlashEffect(SrcX, SrcY, DstX, DstY));

            //プレイヤーを実際に移動
            m_Player.x = DstX;
            m_Player.y = DstY;
        }

        //Score : 追加
        public function PushScore(in_Distance:Number, in_X:Number, in_Y:Number, in_Type:int):void{
            var score_data:ScoreData = new ScoreData(
                in_Distance,
                in_X,
                in_Y,
                in_Type
            );

            //あまりエレガントでない書き方になったがリスト挿入
            if(m_ScoreDataBegin == null){
                //最初にセット
                m_ScoreDataBegin = score_data;
            }else{
                for(var iter:ScoreData = m_ScoreDataBegin; iter != null; iter = iter.next){
                    if(in_Distance < iter.distance){
                        //iterの手前に挿入
                        score_data.prev = iter.prev;
                        score_data.next = iter;

                        if(score_data.prev != null){
                            score_data.prev.next = score_data;
                        }else{
                            m_ScoreDataBegin = score_data;
                        }
                        if(score_data.next != null){
                            score_data.next.prev = score_data;
                        }

                        break;
                    }

                    if(iter.next == null){
                        //末尾に追加
                        score_data.prev = iter;
                        iter.next = score_data;

                        break;
                    }
                }
            }
        }

        //Score : 追加（直接）（コンボなし）
        public function AddScore(in_X:Number, in_Y:Number, in_Val:int):void{
            //スコア加算
            m_Score += in_Val;

            //スコア表示
            m_Layer_Effect.addChild(new ScoreView(in_X, in_Y, in_Val));

            //合計スコアの表示更新
            m_Text_Score.text = m_Score.toString();
        }

        //Score : 反映
        public function RefreshScore():void{
            var local_combo:int = 0;
            var score:int = 0;

            for(var iter:ScoreData = m_ScoreDataBegin; iter != null; iter = iter.next){
                switch(iter.type){
                case Enemy.TYPE_FIRE:
                    //火の玉

                    //コンボ中断
                    //!!
                    local_combo = 0;
                    m_GlobalCombo = 0;

                    //スコア計算
                    score = -1;

                    //スコア減算
                    m_Score += score;

                    //スコア表示
                    m_Layer_Effect.addChild(new ScoreView(iter.x, iter.y, score));

                    break;
                case Enemy.TYPE_HUMAN:
                    //人質

                    //コンボ中断
                    //!!
                    local_combo = 0;
                    m_GlobalCombo = 0;

                    //スコア計算
                    score = -10;

                    //スコア減算
                    m_Score += score;

                    //スコア表示
                    m_Layer_Effect.addChild(new ScoreView(iter.x, iter.y, score));

                    break;
                default:
                    //敵

                    //コンボ数＋＋
                    ++local_combo;
                    ++m_GlobalCombo;

                    //スコア計算
                    if(m_GlobalCombo == local_combo){
                        //前回のコンボからはつながってない場合（通常挙動）
                        score = local_combo;
                    }else{
                        //前回のコンボからつながってる場合
                        score = local_combo+1;
                    }

                    //スコア加算
                    m_Score += score;

                    //スコア表示
                    m_Layer_Effect.addChild(new ScoreView(iter.x, iter.y, score));

                    break;
                }

                //相互リンクを切って解放できるようにしておく
                iter.prev = null;
            }

            //ヒットがなければコンボ中断
            if(local_combo == 0){
                m_GlobalCombo = 0;
            }

            //合計スコアの表示更新
            m_Text_Score.text = m_Score.toString();

            //先頭からのリンクを切って解放する
            m_ScoreDataBegin = null;
        }

        //Update
        public function Update(e:Event=null):void{
            var DeltaTime:Number = 1.0 / stage.frameRate;

            //Player
            m_Player.Update(DeltaTime);

            //Enemy
            Update_Enemy(DeltaTime);

            //Effect
            Update_Effect(DeltaTime);
        }

        //Update : Score
        public function Update_Effect(in_DeltaTime:Number):void{
            var i:int;
            var num:int;
            var uo:UpdateObject;

            //個別Update
            num = m_Layer_Effect.numChildren;
            for(i = 0; i < num; i++){
                uo = m_Layer_Effect.getChildAt(i) as UpdateObject;

                //更新
                uo.Update(in_DeltaTime);

                //死亡チェック
                if(uo.parent == null){//登録が解除された
                    num -= 1;//更新
                    i--;//相殺
                    continue;
                }
            }
        }

        //Update : Enemy
        public function Update_Enemy(in_DeltaTime:Number):void{
            var i:int;
            var num:int;
            var enemy:Enemy;

            //生成
/*
            //!!仮
            const Interval:Number = 2.0;
            m_EnemyTimer += in_DeltaTime;
            if(Interval < m_EnemyTimer){
                m_EnemyTimer -= Interval;

                for(i = 0; i < 3; i++){
                    enemy = new Enemy(Enemy.TYPE_GOBLIN);

                    enemy.x = VIEW_W * (i+1)/4;
                    enemy.y = -32;

                    m_Layer_Enemy.addChild(enemy);
                }
            }
/*/
            var type:int;

            const Interval:Number = 2.0;
            m_EnemyTimer += in_DeltaTime;
            if(Interval < m_EnemyTimer){
                m_EnemyTimer -= Interval;

                if(0 <= m_EnemySeqIter){
                    for(i = 0; i < 3; i++){
                        type = ENEMY_SEQ[m_EnemySeqIter][i];

                        if(type != XX){
                            enemy = new Enemy(type);

                            enemy.x = VIEW_W * (i+1)/4;
                            enemy.y = -32;

                            m_Layer_Enemy.addChild(enemy);
                        }
                    }

                    //
                    --m_EnemySeqIter;
                }else{
                }
            }
//*/

            //個別Update
            num = m_Layer_Enemy.numChildren;
            for(i = 0; i < num; i++){
                enemy = m_Layer_Enemy.getChildAt(i) as Enemy;

                //更新
                enemy.Update(in_DeltaTime);

                //死亡チェック
                if(enemy.parent == null){//登録が解除された
                    num -= 1;//更新
                    i--;//相殺
                    continue;
                }

                //さらにプレイヤーとぶつかっていたらプレイヤーを横にどける
                var GapX:Number = m_Player.x - enemy.x;
                var GapY:Number = m_Player.y - enemy.y;
//                var Distance:Number = Math.sqrt(GapX*GapX + 4*GapY*GapY);
                var Distance:Number = Math.sqrt(GapX*GapX + 2*GapY*GapY);
                var Range:Number = 16 * enemy.scaleX;
                if(Distance < Range){
                    if(enemy.m_Type != Enemy.TYPE_FIRE){
                        if(0 < GapX){
                            m_Player.x = enemy.x + Math.sqrt(Range*Range - GapY*GapY);
                        }else{
                            m_Player.x = enemy.x - Math.sqrt(Range*Range - GapY*GapY);
                        }
                    }else{
                        //炎に触れるとダメージ、の代わりにスコア減点
                        if(1 <= enemy.alpha){
                            AddScore(
                                m_Player.x,
                                m_Player.y,
                                -1
                            );

                            enemy.alpha = 0.5;
                        }
                    }
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
import net.wonderfl.utils.WonderflAPI;


//#Utility
function Lerp(in_Src:Number, in_Dst:Number, in_Ratio:Number):Number{
    return (in_Src * (1.0 - in_Ratio)) + (in_Dst * in_Ratio);
}

class UpdateObject extends Sprite{
    public function Update(in_DeltaTime:Number):void{
    }
}


//#Score
class ScoreData{
    public var distance:Number;
    public var x:Number;
    public var y:Number;
    public var type:int;
    public var next:ScoreData;
    public var prev:ScoreData;

    //Init
    public function ScoreData(in_Distance:Number, in_X:Number, in_Y:Number, in_Type:int){
        distance = in_Distance;
        x = in_X;
        y = in_Y;
        type = in_Type;
    }
}

class ScoreView extends UpdateObject{
    public var m_Text_Score:TextField = new TextField();

    //Init
    public function ScoreView(in_X:int, in_Y:int, in_Score:int){
        //Text
        {
            m_Text_Score.selectable = false;
            m_Text_Score.autoSize = TextFieldAutoSize.CENTER;
            m_Text_Score.defaultTextFormat = new TextFormat('Verdana', 32, 0xFFFFFF, true);
            m_Text_Score.text = ((in_Score < 0)? "": "+") + in_Score.toString();
            m_Text_Score.filters = [new GlowFilter((in_Score < 0)? 0xFF0000: 0x00FFFF,1.0, 4,4)];

            m_Text_Score.x = -m_Text_Score.width/2;
            m_Text_Score.y = -m_Text_Score.height/2;

            addChild(m_Text_Score);
        }

        //Pos
        {
            this.x = in_X;
            this.y = in_Y - 32;
        }
    }

    //Update
    override public function Update(in_DeltaTime:Number):void{
/*
        const ScaleVel:Number = 1.0;
        const ScaleThr:Number = 1.5;

        var scl:Number = this.scaleX + ScaleVel * in_DeltaTime;
        if(ScaleThr < scl){scl = ScaleThr;}

        this.scaleX = this.scaleY = scl;
        this.alpha = (ScaleThr - scl) / (ScaleThr - 1);
/*/
        const AlphaVel:Number = 0.5;

        this.alpha -= AlphaVel * in_DeltaTime;
//*/

        if(this.alpha <= 0){
            //Kill
            parent.removeChild(this);//描画登録の解除で実現
        }
    }
}


class SlashEffect extends UpdateObject{
    //
    static public const W:int = 8;

    //
    public var m_CT:ColorTransform = new ColorTransform();

    //Init
    public function SlashEffect(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int){
        //
        {
            var GapX:int = in_DstX - in_SrcX;
            var GapY:int = in_DstY - in_SrcY;

            var Len:Number = Math.sqrt(GapX*GapX + GapY*GapY);

            var g:Graphics = this.graphics;
            g.lineStyle(0,0,0);
            g.beginFill(0xFF0000, 1.0);
            g.drawEllipse(-Len/2, -W/2, Len, W);
            g.endFill();
            Len *= 0.9;
            g.beginFill(0xFFFF00, 1.0);
            g.drawEllipse(-Len/2, -W/2, Len, W);
            g.endFill();
            Len *= 0.9;
            g.beginFill(0xFFFFFF, 1.0);
            g.drawEllipse(-Len/2, -W/2, Len, W);
            g.endFill();

            this.rotation = Math.atan2(GapY, GapX) * 180/Math.PI;

            this.x = (in_SrcX + in_DstX)/2;
            this.y = (in_SrcY + in_DstY)/2;

            this.blendMode = BlendMode.ADD;
        }
    }

    //Update
    override public function Update(in_DeltaTime:Number):void{
        const AlphaVel:Number = 3.0;

        this.alpha -= AlphaVel * in_DeltaTime;

        //αを減らしつつ加算合成で表示するのは上手くいかない（RGBを減らさなければいけない）ので以下のようにやる
        m_CT.redMultiplier = this.alpha;
        m_CT.greenMultiplier = this.alpha;
        m_CT.blueMultiplier = this.alpha;
        m_CT.alphaMultiplier = this.alpha;
        this.transform.colorTransform = m_CT;

        if(this.alpha <= 0){
            //Kill
            parent.removeChild(this);//描画登録の解除で実現
        }
    }
}


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
    static public var m_BitmapDataList:Vector.<Vector.<BitmapData> >;

    //Init
    static public function Initialize():void{
        //m_BitmapDataList
        {
            m_BitmapDataList = new Vector.<Vector.<BitmapData> >(GameMain.PANEL_NUM_Y);
            for(var y:int = 0; y < GameMain.PANEL_NUM_Y; y++){
                m_BitmapDataList[y] = new Vector.<BitmapData>(GameMain.PANEL_NUM_X);
                for(var x:int = 0; x < GameMain.PANEL_NUM_X; x++){
                    m_BitmapDataList[y][x] = new BitmapData(GameMain.BMP_W, GameMain.BMP_H, true, 0xFF0000FF);
                }
            }
        }
    }


    //==Var==

    //グラフィック
    public var m_Bitmap:Bitmap = new Bitmap();
    //アニメーションの方向
    public var m_AnimDir:int = 0;
    //アニメーション用タイマー
    public var m_AnimTimer:Number = 0.0;


    //==Function==

    //Init
    public function Player(){
        //プレイヤーグラフィック
        {
            m_Bitmap.x = -GameMain.PANEL_W/2;
            m_Bitmap.y = -GameMain.PANEL_H;
            addChild(m_Bitmap);
        }
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        //死亡・ゴール時は何もしない
//        if(GameMain.Instance.IsEnd()){
///            return;
//        }

        //移動
//        Update_Move(in_DeltaTime);

        //グラフィック
        Update_Graphic(in_DeltaTime);

        //死亡チェック
//        Check_Dead();
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
/*
    //Check : Dead
    public function Check_Dead():void{
        //Check
        {
            if(m_IsDead){
                return;
            }
        }
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
    }
//*/
}


//#Enemy
class Enemy extends Sprite{
    //==Const==

    static public var TypeIter:int = 0;
    static public const TYPE_GOBLIN:int    = TypeIter++;
    static public const TYPE_SNAKE:int    = TypeIter++;
    static public const TYPE_OGRE:int    = TypeIter++;
    static public const TYPE_GOHST:int    = TypeIter++;
    static public const TYPE_HUMAN:int    = TypeIter++;
    static public const TYPE_BOSS:int    = TypeIter++;
    static public const TYPE_FIRE:int    = TypeIter++;
    static public const TYPE_NUM:int    = TypeIter;

    //画像
    static public var m_BitmapDataList:Vector.<Vector.<BitmapData> >;

    //アニメーション用パラメータ
    static public const ANIM_CYCLE:Number = 1.0;
    static public const ANIM_ITER:Array = [0,1,2,1];
    static public const ANIM_NUM:int = ANIM_ITER.length;


    //==Var==

    //Type
    public var m_Type:int = 0;

    //Graphic
    public var m_Bitmap:Bitmap = new Bitmap();
    //アニメーション用タイマー
    public var m_AnimTimer:Number = 0.0;

    //HP
    public var m_HP:int = 1;

    //汎用タイマー
    public var m_Timer:Number = 0;
    //ボス用リスト
    public var m_List:Vector.<Enemy> = new Vector.<Enemy>();


    //==Function==

    //Static Init
    static public function Initialize():void{
        m_BitmapDataList = new Vector.<Vector.<BitmapData> >(TYPE_NUM);

        for(var i:int = 0; i < TYPE_NUM; i++){
            m_BitmapDataList[i] = new Vector.<BitmapData>(GameMain.PANEL_NUM_X);
            for(var j:int = 0; j < GameMain.PANEL_NUM_X; j++){
                m_BitmapDataList[i][j] = new BitmapData(GameMain.BMP_W, GameMain.BMP_H, true, 0x22000000);
            }
        }
    }

    //Init
    public function Enemy(in_Type:int){
        //Param
        {
            m_Type = in_Type;

            if(in_Type == TYPE_OGRE){
                m_HP = 2;
                this.scaleX = this.scaleY = m_HP;
            }

            if(in_Type == TYPE_BOSS){
                m_HP = 10;
                this.scaleX = this.scaleY = Math.sqrt(m_HP);

                var fire:Enemy = new Enemy(TYPE_FIRE);
                fire.m_Timer = -1;//　ボス側で操作するため
                m_List.push(fire);
                GameMain.Instance.m_Layer_Enemy.addChild(fire);
            }

            if(in_Type == TYPE_FIRE){
                m_HP = -1;
            }
        }

        //Graphic
        {
/*
            //!!仮画像
            var g:Graphics = this.graphics;
            g.lineStyle(0,0,0);
            g.beginFill(0xFF0000, 1.0);
            g.drawCircle(0,0, 16);
            g.endFill();
/*/
            m_Bitmap.x = -GameMain.PANEL_W/2;
            m_Bitmap.y = -GameMain.PANEL_H;
            addChild(m_Bitmap);
//*/
        }
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        const BOSS_CYCLE:Number = 2.0;

        var en:Enemy;

        //Check HP
        if(m_HP == 0){
            //Kill
            this.parent.removeChild(this);
            return;
        }

        //Move
        switch(m_Type){
        case TYPE_GOBLIN:
            this.y += 40 * in_DeltaTime;
            break;
        case TYPE_SNAKE:
            this.y += 120 * in_DeltaTime;
            break;
        case TYPE_OGRE:
            this.y += 40 * in_DeltaTime;
            break;
        case TYPE_GOHST:
            this.y += 30 * in_DeltaTime;
            break;
        case TYPE_HUMAN:
            this.y += 40 * in_DeltaTime;
            break;
        case TYPE_BOSS:
            this.y += 40 * in_DeltaTime;
            if(GameMain.VIEW_H/4 < this.y){
                this.y = GameMain.VIEW_H/4;
            }
            m_Timer += in_DeltaTime;
            if(2*BOSS_CYCLE < m_Timer){
                m_Timer -= 2*BOSS_CYCLE;

                if(m_HP < 7){
                    en = new Enemy(TYPE_FIRE);

                    //移動角度をm_Timerに詰めてやりくりしてしまう
                    var GapX:Number = GameMain.Instance.m_Player.x - this.x;
                    var GapY:Number = GameMain.Instance.m_Player.y - this.y;
                    en.m_Timer = Math.atan2(GapY, GapX) + 2*Math.PI;

                    en.x = this.x;
                    en.y = this.y;

                    GameMain.Instance.m_Layer_Enemy.addChild(en);
                }
            }
//*
            for(var i:int = 0; i < m_List.length; i++){
                en = m_List[i];

                if(en != null && en.m_Type == TYPE_FIRE){
                    var Rad:int;
                    var theta:Number;
                    if(i < 4){
                        if(i < 2){
                            Rad = 48;
                            theta = 2*Math.PI * (m_Timer/BOSS_CYCLE + i/2.0);
                        }else{
                            Rad = 80;
                            theta = 2*Math.PI * -(m_Timer/BOSS_CYCLE + i/2.0);
                        }

                        //Pos
                        en.x = this.x + Rad * Math.cos(theta);
                        en.y = this.y + Rad * Math.sin(theta);
                    }else{
/*
                        if(0 <= fire.m_Timer){//m_Timerを移動角度代わりに使用
                            const SPEED:Number = 40;
                            fire.x += SPEED * in_DeltaTime * Math.cos(fire.m_Timer);
                            fire.y += SPEED * in_DeltaTime * Math.sin(fire.m_Timer);
                        }
//*/
                    }
                }
            }
//*/
            break;
        case TYPE_FIRE:
            this.alpha += 1 * in_DeltaTime;
            if(1 < this.alpha){this.alpha = 1;}
//*
            if(0 <= m_Timer){//m_Timerを移動角度代わりに使用
                const SPEED:Number = 40;
                this.x += SPEED * in_DeltaTime * Math.cos(m_Timer);
                this.y += SPEED * in_DeltaTime * Math.sin(m_Timer);
            }
//*/
            break;
        }

        //Range
        {
            var IsRangeOut:Boolean = false;
            if(this.x < -32){IsRangeOut = true;}
            if(GameMain.VIEW_W + 32 < this.x){IsRangeOut = true;}
            if(this.y < -32){IsRangeOut = true;}
            if(GameMain.VIEW_H + 32 < this.y){IsRangeOut = true;}

            if(IsRangeOut){
                //Score
                if(m_Type != TYPE_HUMAN){
                    GameMain.Instance.AddScore(
                        this.x,
                        GameMain.VIEW_H,
                        -1
                    );
                }else{
                    GameMain.Instance.AddScore(
                        this.x,
                        GameMain.VIEW_H,
                        10
                    );
                }

                //Kill
                this.parent.removeChild(this);
                return;
            }
        }

        //Anim
        {
            Update_Graphic(in_DeltaTime);
        }
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

        m_Bitmap.bitmapData = m_BitmapDataList[m_Type][iter];
    }

    //Damage
    public function onDamage(in_Val:int):void{
        var en:Enemy;

        //すでに死んでたら何もしない
        if(m_HP <= 0){
            return;
        }

        m_HP -= in_Val;
        if(m_HP < 0){m_HP = 0;}

        if(m_Type == TYPE_OGRE){
            this.scaleX = this.scaleY = m_HP;
        }
        if(m_Type == TYPE_BOSS){
            this.scaleX = this.scaleY = Math.sqrt(m_HP);

            if(7 <= m_HP){
                en = new Enemy(TYPE_FIRE);

                en.m_Timer = -1;//　ボス側で操作するため

                m_List.push(en);

                GameMain.Instance.m_Layer_Enemy.addChild(en);

                //ボスの方を炎より手前に表示する
                this.parent.swapChildren(this, en);
            }

            if(m_HP == 0){
                //火の玉も消す
                for(var i:int = 0; i < m_List.length; i++){
                    en = m_List[i];
                    en.m_HP = 0;
                }

                //スコア表示に移る
                ScoreWindowLoader.show(GameMain.Instance.m_Score);
            }
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
    private static const TWEET: String = "Playing Touch&Kill [score: %SCORE%] #wonderfl";
    
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
        var window: DisplayObject = _content.makeScoreWindow(_api, score, "Touch & Kill", 1, TWEET);
//        var close: Function = function(e: Event): void
//        {
//            window.removeEventListener(Event.CLOSE, close);
//            closeHandler();
//        }
//        window.addEventListener(Event.CLOSE, close);
        _top.addChild(window);
    }
    
}
