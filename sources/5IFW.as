/*
　「閃光乱舞 -Laser Bouncer-」
　・レーザーとなって止まった世界を跳ね回るアクションパズル
　　・アクトレーザー＋時間停止＋物理エンジン

　操作方法（How To Play）
　・ボタンをタッチ（Touch a Button）
　　・対応した方向に反射移動（Bounce Around）

　リンク
　・次回作とかの情報はTwitterなどでお知らせ中
　　・https://twitter.com/o_healer
　・Android版
　　・https://play.google.com/store/apps/details?id=air.showohealer.game.works

　メモ
　・GPUを使用
　　・CPUオンリーのPCだと重くなる
　・Box2D 2.0.2 only
　　・2.1とかだとエラー
*/



package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.desktop.*;
 
    //3D
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display3D.*;
    import flash.display3D.textures.*;
 
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class LaserBouncer_Wonderfl extends Sprite {
        //==File==
//*
        static public const BITMAP_URL:String = "http://assets.wonderfl.net/images/related_images/4/4a/4aa7/4aa7e609cf15c38c66c37e00b9fe5a7b3392b5c7";
/*/
        [Embed(source='Image.png')]
         private static var Bitmap_Graphic: Class;
//*/

        //==Const==

        //画面の大きさ
        public function GetTotalW():int{
            return stage.stageWidth;
        }
        public function GetTotalH():int{
            return stage.stageHeight;
        }

        //==Var==

        //3D
        public var m_Stage3D:Stage3D;

        //Layer
        public var m_Layer_GameRoot:Sprite = new Sprite();

        //Engine
        public var m_ActGameEngine:ActGameEngine;

        //Time for DeltaTime
        public var m_TimeOld:Number = 0;


        //==Function==

        //Init
        public function LaserBouncer_Wonderfl() {
            //Load
//*
            //wonderfl用：Bitmapを外部からロードする場合

            //Load
            var loader:Loader = new Loader();
            loader.load(new URLRequest(BITMAP_URL), new LoaderContext(true));//画像のロードを開始して
            loader.contentLoaderInfo.addEventListener(
                Event.COMPLETE,//ロードが完了したら
                function(e:Event):void{
                    OnLoad(loader.content);//それを保持した後
                }
            );
/*/
            //ローカル用：Bitmapを事前ロードできる場合

            //ブロック画像のセット（＆その他初期化）
            OnLoad(new Bitmap_Graphic());
//*/
        }

        public function OnLoad(in_Graphic:DisplayObject):void
        {
            //Static Init
            {
                ImageManager.Init(in_Graphic);
            }

            //Init
            {
                if(stage != null){
                    InitStage();
                }else{
                    addEventListener(
                        Event.ADDED_TO_STAGE,//ステージに追加されたら
                        InitStage
                    );
                }
            }
        }
        public function InitStage(e:Event=null):void
        {
            //Settings
            {
/*
                //画面幅に合わせ、長い方が画面にフィットするように拡大
                //- 短い方は画面にフィットせず、もともと画面外だったものが内部表示されるかも
                stage.scaleMode = StageScaleMode.SHOW_ALL;
/*/
                //自前で計算することにした
                stage.scaleMode = StageScaleMode.NO_SCALE;
                stage.align = StageAlign.TOP_LEFT; 
//*/
            }

            //3D
            {
                m_Stage3D = stage.stage3Ds[0];
                m_Stage3D.addEventListener(Event.CONTEXT3D_CREATE, Init);
                m_Stage3D.requestContext3D(Context3DRenderMode.AUTO);
            }

            removeEventListener(Event.ADDED_TO_STAGE, InitStage);
        }

        public function Init(e:Event):void
        {
            //Settings
            {
//*
                //ひとまず自動計算に任せてみる
                stage.scaleMode = StageScaleMode.SHOW_ALL;
/*/
                //手動にするのであればこちら
                stage.scaleMode = StageScaleMode.NO_SCALE;
                stage.align = StageAlign.TOP_LEFT; 
//*/
            }

            //BG
//            {
//                addChild(new Bitmap(new BitmapData(VIEW_W, VIEW_H, false, 0x808080)));
//            }

            //Layer
            {
                addChild(m_Layer_GameRoot);
            }

            //Engine
            {
                m_ActGameEngine = new ActGameEngine(m_Stage3D);
                m_Layer_GameRoot.addChild(m_ActGameEngine);
                m_ActGameEngine.Init(GetTotalW(), GetTotalH());
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }

            m_Stage3D.removeEventListener(Event.CONTEXT3D_CREATE, Init);

            //OnEnd
//            {
//                addEventListener(Event.REMOVED_FROM_STAGE, Finish);
//            }

            m_TimeOld = getTimer();
        }

        //Update
        public function Update(e:Event=null):void{
            //var DeltaTime:Number = 1.0 / stage.frameRate;
            const DELTATIME_MIN:Number = 1.0 / stage.frameRate;
            const DELTATIME_MAX:Number = 1.0 / 20.0;

            var time_old:Number = m_TimeOld;
            var time_new:Number = getTimer();
            var DeltaTime:Number = Util.Clamp((time_new - time_old) / 1000.0, DELTATIME_MIN, DELTATIME_MAX);

            m_TimeOld = time_new;

            m_ActGameEngine.Update(DeltaTime);
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
import flash.desktop.*;

//Box2D
import Box2D.Dynamics.*;
import Box2D.Dynamics.Contacts.*;
import Box2D.Dynamics.Joints.*;
import Box2D.Collision.*;
import Box2D.Collision.Shapes.*;
import Box2D.Common.Math.*;
//import General.*;

//3D
import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.*;
import flash.display3D.textures.*;


//Engine
class ActGameEngine extends Sprite
{
    //==Const==

    //実際の表示サイズ
    public function GetTotalW():int{
        //return Capabilities.screenResolutionX;
        //return stage.stageWidth;
        return VIEW_W;
    }
    public function GetTotalH():int{
        //return Capabilities.screenResolutionY;
        //return stage.stageHeight;
        return VIEW_H;
    }

    //パネルの大きさ
    static public const PANEL_W:int = 32;

    //ゲーム画面のサイズ
    static public const GAME_W:int = PANEL_W * 16;
    static public const GAME_H:int = PANEL_W * 16;

    //レーザーの色
    static public const LASER_COLOR_NORMAL:uint = 0x00FFFF;
    static public const LASER_COLOR_CLEAR :uint = 0xFFFF00;

    //重力
    static public const GRAVITY:Number = 10.0;

    //マップの要素
    static public var s_BlockIndexIter:int = 0;
    static public const O:int = s_BlockIndexIter++;//空白
    static public const W:int = s_BlockIndexIter++;//地形
    static public const P:int = s_BlockIndexIter++;//プレイヤー位置（生成後は空白として扱われる）
    static public const G:int = s_BlockIndexIter++;//ゴール位置（基本的には空白として扱われる）
//    static public const X:int = s_BlockIndexIter++;//トゲブロック
//    static public const L:int = s_BlockIndexIter++;//連結ブロック
//    static public const A:int = s_BlockIndexIter++;//ダッシュブロック
    static public const A:int = s_BlockIndexIter++;//軽ブロック
    static public const B:int = s_BlockIndexIter++;//軽ブロック
    static public const E:int = s_BlockIndexIter++;//非回転ブロック
    static public const F:int = s_BlockIndexIter++;//非回転ブロック
    static public const Q:int = s_BlockIndexIter++;//トランポリンブロック
    static public const R:int = s_BlockIndexIter++;//トランポリンブロック
    static public const I:int = s_BlockIndexIter++;//壊せるブロック
    static public const J:int = s_BlockIndexIter++;//壊せるブロック
    static public const U:int = s_BlockIndexIter++;//Heavyブロック
    static public const V:int = s_BlockIndexIter++;//Heavyブロック
    static public const M:int = s_BlockIndexIter++;//ミラーブロック
    static public const S:int = s_BlockIndexIter++;//同期ブロック
    static public const Z:int = s_BlockIndexIter++;//シーソー（MAPには配置しないが、整合性のために使用）
    //A,B：通常ブロック
    //E,F：非回転ブロック
    //I,J：壊せる
    //M：ミラー
    //Q,R：トランポリン
    //U,V：Heavy

    //Appendで指定するギミック
    static public var s_GimmickIndexIter:int = 0;
    static public const GIMMICK_SEESAW    :int = s_GimmickIndexIter++;//シーソー

    //マップ
    public var m_MapIndex:int = 0;//動作確認時にここにあった方が楽なのでここで宣言
    static public const MAP_ARR:Array = [
        {//Tutorial 1
            name:"Bounce",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,W,O,O,O,O,O,W,W],
            [W,P,O,O,O,O,O,O,W,O,O,O,O,G,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//Tutorial
            name:"Blocks",
            param:{
                block_a_density:0.1,
                block_b_density:0.1,
                block_e_density:0.1,
                block_f_density:0.1,
                block_s_density:0.1,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,O,O,O,O,O,B,A,O,O,O,O,O,W,W],
            [W,W,O,O,O,O,O,A,B,O,O,O,O,O,W,W],
            [W,W,P,O,O,O,O,B,A,O,O,O,O,O,W,W],
            [W,W,W,W,W,W,W,W,W,O,O,O,O,O,W,W],
            [W,W,O,O,O,O,O,E,F,O,O,O,O,O,W,W],
            [W,W,O,O,O,O,O,F,E,O,O,O,O,O,W,W],
            [W,W,O,O,O,O,O,E,F,O,O,O,O,O,W,W],
            [W,W,O,O,O,O,O,W,W,W,W,W,W,W,W,W],
            [W,W,O,O,O,O,O,O,O,O,O,O,O,G,W,W],
            [W,W,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//Tutorial：トランポリン＆壊せるブロック
            name:"Blocks 2",
            param:{
                impulse_pow:5.0,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,I,O,J,O,V,O,O,W,O,O,O,W],
            [W,O,O,O,I,O,I,O,V,O,O,O,O,O,O,W],
            [W,O,O,O,I,O,J,O,I,O,O,O,O,O,O,W],
            [W,O,O,O,I,O,I,O,I,O,O,W,O,O,O,W],
            [W,I,J,I,W,W,W,W,W,W,W,W,O,O,O,W],
            [W,O,O,O,W,W,W,W,W,W,W,Q,J,I,J,Q],
            [W,I,I,I,W,W,W,W,W,W,W,Q,I,J,I,Q],
            [W,O,P,O,W,W,W,W,W,W,W,Q,J,I,J,Q],
            [W,O,O,O,W,W,W,W,W,W,W,W,O,O,O,W],
            [W,O,O,O,W,W,W,W,W,W,W,W,O,G,O,W],
            [W,Q,Q,Q,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//チュートリアル：ミラー
            name:"Mirror",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,P,O,O,O,O,O,W,W,G,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,M,M,M,M,M,M,W,W,M,M,M,M,M,M,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,W,W,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//チュートリアル：シーソー
            name:"Seesaw",
            param:{
                block_z_density:0.1,
                dummy:0
            },
            append:[
                {
                    gimmick:GIMMICK_SEESAW,
                    x:10.5,
                    y:3.5,
                    w:1,
                    h:5,
                    ang:0
                },
                {
                    gimmick:GIMMICK_SEESAW,
                    x:5.5,
                    y:6.5,
                    w:1,
                    h:5,
                    ang:0
                },
                {
                    gimmick:GIMMICK_SEESAW,
                    x:10.5,
                    y:9.5,
                    w:1,
                    h:5,
                    ang:0
                },
            ],
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,P,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,O,O,O,O,W],
            [W,G,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy：トランポリン2
            name:"Timing",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,G,O,F,O,O,F,O,O,F,O,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,W,W,F,W,W,F,W,W,F,W,O,W,W],
            [W,W,W,P,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,W,W,W,W,Q,W,W,Q,W,W,Q,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy-mid：序盤：無回転ブロック後
            name:"Slide",
            param:{
                block_f_density:0.5,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,F,O,O,O,O,F,W,W],
            [W,O,O,O,O,O,O,O,F,O,O,O,O,F,W,W],
            [W,O,O,O,O,O,O,O,F,O,O,P,O,F,W,W],
            [W,O,O,O,O,O,O,O,F,F,F,F,F,F,W,W],
            [W,O,O,O,O,O,O,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,W,W,W,W,W,G,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy：できれば回転ブロック登場後：
            name:"Open",
            param:{
                block_a_density:0.05,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,A,A,A,A,A,O,O,O,O,O,O,W],
            [W,O,O,O,A,A,A,A,A,O,O,O,O,O,O,W],
            [W,O,O,O,A,A,A,A,A,O,O,O,O,O,O,W],
            [W,O,O,O,A,A,A,A,A,O,O,O,O,O,O,W],
            [W,O,O,O,A,A,A,A,A,O,O,O,O,O,O,W],
            [W,O,O,O,O,W,O,O,O,W,O,O,O,O,O,W],
            [W,O,P,O,O,W,O,O,G,W,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy：壊れるブロック後
            name:"Snipe",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,U,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,U,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,U,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,U,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,U,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,I,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,J,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,W,W,O,O,O,W],
            [W,O,P,O,O,O,O,O,O,O,W,W,O,O,G,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy-mid : 中盤：ミラー後
            name:"Forestall",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,O,O,O,O,O,O,O,O,W,W,W,W],
            [W,W,W,W,F,F,O,O,O,O,O,O,W,W,W,W],
            [W,O,O,O,F,F,O,O,O,O,O,O,O,O,O,W],
            [W,P,O,O,F,F,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,O,O,W],
            [W,W,W,W,W,W,O,O,O,O,W,W,W,M,M,W],
            [W,W,W,W,W,W,O,O,F,F,W,W,W,O,O,W],
            [W,O,O,O,O,O,O,O,F,F,O,O,O,O,O,W],
            [W,G,O,O,O,O,O,O,F,F,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy：中盤：通常ブロックの後
            name:"Plug",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,G,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,F,O,O,O,O,W],
            [W,O,O,O,O,O,O,F,F,F,F,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,F,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,O,O,P,O,O,O,O,W,W,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy
            name:"Sync",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,S,O,O,O,O,O,G,S,O,O,O,O,O,O,W],
            [W,S,O,O,O,O,O,O,S,O,O,O,O,O,O,W],
            [W,W,W,W,O,W,W,W,W,W,W,W,W,W,W,W],
            [W,S,O,O,O,O,O,O,S,O,O,O,O,O,O,W],
            [W,S,O,O,O,O,O,O,S,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,O,W,W],
            [W,S,O,O,O,O,O,O,S,O,O,O,O,O,O,W],
            [W,S,O,P,O,O,O,O,S,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy
            name:"Pull Up",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,S,S,S,S,S,S,S,S,S,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,P,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,S,S,S,S,S,S,S,S,S,W,O,W],
            [W,W,W,W,S,S,S,S,S,S,S,S,S,W,O,W],
            [W,G,O,O,S,S,S,S,S,S,S,S,S,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy-mid：中盤：ミラー後
            name:"Mirror Floor",
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,M,O,G,O,O,M,O,O,O,O,W],
            [W,O,O,O,O,M,O,O,O,O,M,O,O,O,O,W],
            [W,M,M,M,M,M,M,M,M,M,M,M,M,M,M,W],
            [W,O,O,O,O,M,O,O,O,O,M,O,O,O,O,W],
            [W,O,O,O,O,M,O,O,O,O,M,O,O,O,O,W],
            [W,O,O,O,O,M,O,O,O,O,M,O,O,O,O,W],
            [W,M,M,M,M,M,M,M,M,M,M,M,M,M,M,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,P,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//mid：前半
            name:"Upward",
            param:{
                block_f_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W],
            [W,O,O,O,O,O,W,W,W,W,W,O,W,W,W,W],
            [W,O,O,O,O,O,W,W,W,W,W,O,W,W,W,W],
            [W,F,F,F,F,F,W,W,W,W,W,O,W,W,W,W],
            [W,W,O,O,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,O,O,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,O,O,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,O,O,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,O,P,O,W,W,W,W,W,W,G,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//mid
            name:"Cage",
            param:{
                block_e_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,O,O,O,G,O,O,O,W],
            [W,W,W,W,W,W,W,W,O,O,O,O,O,O,O,W],
            [W,E,E,E,E,E,E,E,O,O,O,O,O,O,O,W],
            [W,E,O,O,O,O,O,E,O,O,O,O,O,O,O,W],
            [W,E,O,O,O,O,O,E,O,O,O,O,O,O,O,W],
            [W,E,O,O,O,O,O,E,O,O,O,O,O,O,O,W],
            [W,E,O,O,P,O,O,E,O,O,O,O,O,O,O,W],
            [W,E,E,E,E,E,E,E,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy-mid
            name:"Push-Up Door",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,O,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,W,O,W,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,W,S,W,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,S,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,S,O,O,W],
            [W,O,O,O,O,O,S,O,O,O,O,O,S,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,S,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,S,O,O,W],
            [W,P,O,O,O,O,O,O,O,O,O,O,S,O,G,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//easy-mid
            name:"Waiting",
            param:{
                impulse_pow:50.0,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,P,W,W,W,W,G,W,W,W,W,W],
            [W,W,W,W,W,O,W,W,W,W,O,W,W,W,W,W],
            [W,W,W,W,W,O,W,W,W,W,O,W,W,W,W,W],
            [W,W,W,W,W,O,W,W,W,W,O,W,W,W,W,W],
            [W,W,W,W,W,O,W,W,W,W,O,W,W,W,W,W],
            [W,O,O,O,O,O,F,F,F,F,O,O,O,Q,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//mid
            name:"Slash",
            param:{
                block_a_density:1.0,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,W,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,A,O,O,O,W],
            [W,P,O,O,O,O,O,O,W,O,O,A,W,O,G,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
        {//mid
            name:"Self Timer",
            param:{
                block_f_density:0.2,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,F,O,O,O,O,O,O,O,O,O,W],
            [W,P,O,O,O,F,O,O,O,W,W,W,O,O,O,W],
            [W,W,W,W,W,W,W,W,O,W,W,W,O,O,O,W],
            [W,G,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            ]
        },
/*
        {//easy-mid：地味
            name:"Kuguru",
            param:{
                block_f_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,O,O,O,O,O,O,W,W,W,W,W],
            [W,W,W,W,W,F,F,F,F,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,F,O,W,W,F,O,W,W,W,W,W],
            [W,W,W,W,W,P,O,W,W,O,G,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//easy：乗るだけでズラせてあまり意味がない
            name:"Pull",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,O,O,O,O,O,O,W,W,W,W,W],
            [W,W,W,W,W,O,O,S,O,O,S,W,W,W,W,W],
            [W,O,O,O,O,O,O,S,O,O,S,O,O,O,O,W],
            [W,P,O,O,O,O,O,S,O,O,S,O,O,O,G,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//かぶってる
            name:"Curgo",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,O,W],
            [W,S,S,S,S,O,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O],
            [S,S,S,S,S,S,O,O,O,O,O,O,O,O,O,O],
            [S,O,O,O,O,S,O,O,O,O,O,O,O,O,O,O],
            [S,O,O,O,O,S,O,O,O,O,O,O,O,O,O,O],
            [S,P,O,O,O,S,O,O,O,O,O,O,O,O,G,O],
            [S,S,S,S,S,S,O,O,W,O,O,O,O,O,O,O],
            ]
        },
        {//微妙
            name:"Auto Close",
            param:{
                impulse_pow:1.0,
                block_e_density:0.1,
                block_f_density:0.1,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,O,G,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,F,F,O,O,O,O,O,O,W],
            [W,O,W,W,W,W,W,F,F,W,W,W,W,W,O,W],
            [W,O,W,W,W,W,W,F,F,W,W,W,W,W,O,W],
            [Q,O,O,O,O,E,E,F,F,E,E,O,O,O,O,Q],
            [Q,O,O,O,O,E,F,F,F,F,E,O,O,O,O,Q],
            [Q,O,O,O,O,E,E,O,O,E,E,O,O,O,O,Q],
            [W,O,W,W,W,W,W,O,O,W,W,W,W,W,O,W],
            [W,O,W,W,W,W,W,O,O,W,W,W,W,W,O,W],
            [W,O,O,O,O,O,O,P,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//mid variation：ちょっと趣が違いすぎる
            name:"Trampolin Room",
            param:{
                impulse_pow:2.0,
                dummy:0
            },
            map:[
            [Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q],
            [Q,O,O,O,O,O,O,B,O,O,O,O,B,Q,O,Q],
            [Q,O,O,O,O,O,O,A,O,O,O,O,A,Q,O,Q],
            [Q,O,O,O,O,O,O,B,O,O,O,O,B,Q,O,Q],
            [Q,O,O,O,O,O,O,A,O,O,O,O,A,Q,O,Q],
            [Q,O,O,O,O,O,O,B,O,O,O,O,B,Q,O,Q],
            [Q,O,O,O,O,O,O,A,O,O,O,O,A,Q,O,Q],
            [Q,O,O,O,O,O,O,B,O,O,O,O,B,Q,O,Q],
            [Q,O,O,O,O,O,O,A,O,O,O,O,A,O,O,Q],
            [Q,O,O,O,O,O,O,B,O,O,O,O,B,Q,O,Q],
            [Q,P,O,O,O,O,O,A,O,O,O,O,A,Q,G,Q],
            [Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q,Q],
            ]
        },
        {//mid：ステージとしてやや微妙
            name:"Up & Rot",
            param:{
                block_a_density:0.04,
                block_z_density:0.01,
                dummy:0
            },
            append:[
                {
                    gimmick:GIMMICK_SEESAW,
                    x:7.5,
                    y:9.5,
                    w:1,
                    h:1,
                    ang:0
                },
            ],
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,O,O,W,W],
            [W,O,O,O,O,O,O,O,O,W,W,W,W,O,W,W],
            [W,O,O,O,O,O,A,A,A,O,W,W,W,O,W,W],
            [W,O,O,O,O,O,A,O,A,O,O,G,W,O,W,W],
            [W,O,P,O,O,O,A,O,A,W,W,W,W,O,W,W],
            [W,W,W,W,W,W,A,O,A,W,W,W,W,O,W,W],
            [W,W,W,W,W,W,A,A,O,W,W,W,W,O,W,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,W,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//xxひっかかる
            name:"Sync Bound",
            param:{
                impulse_pow:200.0,
                block_s_density:5,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,P,O,O,O,S,S,S,O,S,S,S,O,O,G,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [O,O,O,S,S,S,O,S,S,S,O,S,S,S,O,O],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,O,O,O,O,S,S,S,O,S,S,S,O,O,Q,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,W,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,O,O,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//不可能？（少なくとも想定通りの挙動はしない）
            name:"L Gate",
            param:{
                block_a_density:0.01,
                block_z_density:0.1,
                dummy:0
            },
            append:[
                {
                    gimmick:GIMMICK_SEESAW,
                    x:7.5,
                    y:6.5,
                    w:1,
                    h:1,
                    ang:0
                },
            ],
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,W],
            [W,W,W,W,W,W,O,O,O,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,A,A,A,A,A,A,O,O,O,W],
            [W,O,O,O,O,O,A,O,O,O,O,A,O,O,O,W],
            [W,O,O,O,O,O,A,O,A,A,A,A,O,O,O,W],
            [W,O,O,O,O,O,A,O,A,O,O,O,O,O,O,W],
            [W,O,O,O,O,O,A,O,A,O,O,O,O,O,O,W],
            [W,G,O,O,O,W,A,A,A,O,O,O,O,P,O,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//xx：左右移動の切替が難しい（プレイヤーの往復が早すぎる）
            name:"Slide 2",
            param:{
                block_s_density:0.01,
                dummy:0
            },
            map:[
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,O,O,F,F,F,F,F,F,F,F,O,O,O,G,W],
            [W,O,O,F,F,P,F,O,F,O,F,O,O,W,W,W],
            [W,O,O,F,F,O,F,O,F,O,F,O,O,W,W,W],
            [W,W,W,W,W,W,W,O,W,O,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,O,W,O,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,O,O,O,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            [W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W],
            ]
        },
        {//xx調整がうまくいかない
            name:"Start Up",
            param:{
                block_f_density:0.02,
                block_z_density:0.0002,
                impulse_pow:5.0,
                dummy:0
            },
            append:[
                {
                    gimmick:GIMMICK_SEESAW,
                    x:8,
                    y:12.5,
                    w:10,
                    h:1,
                    ang:0
                },
            ],
            map:[
            [W,W,W,W,Q,W,W,S,S,W,W,Q,W,W,W,W],
            [W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,O,O,O,O,O,O,O,O,O,O,O,W,W,W,W],
            [W,O,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,O,W,W,F,W,W,W,W,W,W,O,W,W,W,W],
            [W,O,W,W,F,W,W,W,W,W,W,O,W,W,W,W],
            [W,O,W,W,F,W,W,W,W,W,W,F,W,W,W,W],
            [W,O,W,W,F,W,W,W,W,W,W,F,W,W,W,W],
            [W,O,W,W,F,W,W,W,W,W,W,F,W,W,W,W],
            [W,P,O,O,F,O,O,O,O,O,O,F,O,O,G,W],
            [W,W,W,W,F,W,W,W,W,W,W,F,W,W,W,W],
            [W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            [W,W,W,W,S,W,W,W,W,W,W,S,W,W,W,W],
            [W,W,W,W,O,W,W,W,W,W,W,O,W,W,W,W],
            ]
        },
//*/
    ];

    //Box2Dとのスケーリング変換
    static public const PHYS_SCALE:Number = 100.0;

    //表示サイズ（外部から指定）
    static public var VIEW_W:int = 0;
    static public var VIEW_H:int = 0;

    //マップまわりのパラメータ（Resetのたびに再計算）
    static public var MAP:Array = null;
    static public var MAP_W:int = 0;
    static public var MAP_H:int = 0;

    //ボタン
    static public var s_ButtonIter:int = 0;
    static public const BUTTON_PAUSE    :int = s_ButtonIter++;
    static public const BUTTON_NUM        :int = s_ButtonIter;

    //レーザーの方向
    static public var s_LaserDirIter:int = 0;
    static public const LASER_DIR_DL    :int = s_LaserDirIter++;
    static public const LASER_DIR_UL    :int = s_LaserDirIter++;
    static public const LASER_DIR_UR    :int = s_LaserDirIter++;
    static public const LASER_DIR_DR    :int = s_LaserDirIter++;
    static public const LASER_DIR_NUM    :int = s_LaserDirIter;

    //モード
    static public var s_ModeIter:int = 0;
    static public const MODE_MAIN        :int = s_ModeIter++;
    static public const MODE_GOAL        :int = s_ModeIter++;
    static public const MODE_GAME_OVER    :int = s_ModeIter++;


    //==Var==

    //Pseudo Sigleton
    static public var Instance:ActGameEngine;

    //Phys World
    public var m_PhysWorld:b2World;

    //All GameObject List
    public var m_GameObject:Vector.<GameObject> = new Vector.<GameObject>;

    //Layer
    public var m_Root                :Sprite;
    public var  m_Root_UI            :Sprite;

    //3D
    public var m_Stage3D:Stage3D;
    public var m_Context3D:Context3D;

    //表示位置などの調整用パラメータ
    public var m_GlobalScale:Number = 1.0;
    public var m_GlobalScaleCandX:Number = 1.0;
    public var m_GlobalScaleCandY:Number = 1.0;
    public var m_GameLX:Number = 0;
    public var m_GameUY:Number = 0;

    //BG
    public var m_BG:BackGround;//遠景
    public var m_Terrain:Terrain;//近景
    public var m_Mirror:Mirror;//ミラー

    //Player
    public var m_Player:Player;

    //Goal
    public var m_Goal:Goal;

    //Block
    public var m_BlockArr:Vector.<Block>;

    //Text
    public var m_Text:TextField;

    //Button
    public var m_Bitmap_LaserButton:Vector.<Bitmap>;
    public var m_ButtonManager:ButtonManager = new ButtonManager();

    //Popup系UI
    public var m_Popup_Queue:Vector.<Popup> = new Vector.<Popup>();
    public var m_TopPopup:Popup = null;

    //モード
    public var m_Mode:int = MODE_MAIN;

    //Flag
//    public var m_IsGameOver:Boolean = false;


    //==Function==

    //Init
    public function ActGameEngine(in_Stage3D:Stage3D){
        m_Stage3D = in_Stage3D;
    }
    public function Init(in_ViewW:int, in_ViewH:int):void{
        //Pseudo Singleton
        {
            Instance = this;
        }

        //Const
        {
            VIEW_W = in_ViewW;
            VIEW_H = in_ViewH;
        }

        //Touch
        {
            //Listener
            stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP,   OnMouseUp);
        }
        //Key
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
        }

        //3D
        {
            m_Context3D = m_Stage3D.context3D;
            //m_Context3D.enableErrorChecking = true;
            m_Context3D.configureBackBuffer(GetTotalW(), GetTotalH(), 0, true);
        }

        //Reset
        {
            //残りはResetと共用
            Reset(true);
        }

        //最初のState
        {
            //ちょっと強引にステージ選択画面にする
            Push(new Popup_Title());
            Pop();//上のResetでPushされたものをPopしておく
        }

/*
        //Debug
        {
            var m_DebugLayer:Sprite = new Sprite();
            addChild(m_DebugLayer);

            // デバッグオブジェクト
            var debug:b2DebugDraw = new b2DebugDraw();
            
            debug.m_sprite            = m_DebugLayer;
            debug.m_drawScale        = PHYS_SCALE;
            debug.m_fillAlpha        = 0.3;
            debug.m_lineThickness    = 1.0;
            debug.m_drawFlags        = b2DebugDraw.e_shapeBit;
            
            // デバッグ描画
            m_PhysWorld.SetDebugDraw(debug);
        }
//*/
    }

    //Reset
    public function Reset(in_RestructFlag:Boolean):void{
        var i:int;
        var num:int;
        var bmd:BitmapData;
        var bmp:Bitmap;
        var button:Button;

        //Map
        {
            MAP = MAP_ARR[m_MapIndex].map;
            MAP_W = MAP[0].length * PANEL_W;
            MAP_H = MAP.length * PANEL_W;
        }

        //Mode
        {
            m_Mode = MODE_MAIN;
        }

        //Remove Old
        {
            //m_GameObject
            for(i = 0; i < m_GameObject.length; ++i){
                if(m_GameObject[i].parent != null){
                    m_GameObject[i].parent.removeChild(m_GameObject[i]);
                }
            }
            m_GameObject = new Vector.<GameObject>();

            //sprite
            while(0 < this.numChildren){
                removeChildAt(0);
            }

            //m_BlockArr
            m_BlockArr = new Vector.<Block>();
        }

        //Physics
        {
            //AABB
            const RANGE_LX:Number = -10 * PANEL_W;
            const RANGE_UY:Number = -10 * PANEL_W;
            const RANGE_RX:Number = 110 * PANEL_W;
            const RANGE_DY:Number = 110 * PANEL_W;
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(RANGE_LX/PHYS_SCALE, RANGE_UY/PHYS_SCALE);
            worldAABB.upperBound.Set(RANGE_RX/PHYS_SCALE, RANGE_DY/PHYS_SCALE);
            //Gravity
            var gravity:b2Vec2 = new b2Vec2(0.0, GRAVITY);
            //Sleep
            var useSleep:Boolean = true;
            //World
            m_PhysWorld = new b2World(worldAABB, gravity, useSleep);
        }

        //Layer
        {
            addChild(m_Root = new Sprite());
                m_Root.addChild(m_Root_UI = new Sprite());
        }

        //BG
        {
            m_BG = BackGround.Create(MAP, m_PhysWorld, m_Context3D);
            m_GameObject.push(m_BG);
        }

        //Mirror
        {
            m_Mirror = Mirror.Create(MAP, m_PhysWorld, m_Context3D);
            m_GameObject.push(m_Mirror);
        }

        //Player
        {
            m_Player = Player.Create(MAP, m_PhysWorld, m_Context3D);
            m_GameObject.push(m_Player);
        }

        //Terrain
        {
            m_Terrain = Terrain.Create(MAP, m_PhysWorld, m_Context3D);
            m_GameObject.push(m_Terrain);
        }

//        //Needle
//        {
//            var needle_arr:Vector.<Needle> = Needle.Create(MAP, m_PhysWorld);
//            //グラフィックがないので描画登録はなし
//        }

        //Block
        {
            m_BlockArr = Block.Create(MAP, m_PhysWorld, m_Context3D, MAP_ARR[m_MapIndex].param, MAP_ARR[m_MapIndex].append);
            num = m_BlockArr.length;
            for(i = 0; i < num; ++i){
                m_GameObject.push(m_BlockArr[i]);
            }
        }

        //Goal
        {
            m_Goal = Goal.Create(MAP, m_PhysWorld, m_Context3D);
            m_GameObject.push(m_Goal);
        }

        //Button
        {
//            var button_w:int = 0.5 * VIEW_W/LASER_DIR_NUM;
            var button_w:int = VIEW_W/LASER_DIR_NUM;
            var button_h:int = button_w;

            var button_ninepatch:NinePatch = NinePatch.Create(ImageManager.m_BitmapData_Ori, 16, 16, button_w, button_h, 0, 128, 64, 64);

            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            var blur:Number = button_w/8;
            if(ActGameEngine.IsClear(ActGameEngine.Instance.m_MapIndex)){
                shape.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_CLEAR, 1.0, blur,blur)];
            }else{
                shape.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_NORMAL, 1.0, blur,blur)];
            }

            var c:Number = button_w/2;
            var len:Number = button_w * 0.25;
            var point:Vector.<Vector.<Vector.<Number> > > = new <Vector.<Vector.<Number> > >[
                new <Vector.<Number> >[
                    new <Number>[c-len, c+len],
                    new <Number>[c+len, c-len],
                    new <Number>[c-len, c],
                    new <Number>[c, c+len],
                ],
                new <Vector.<Number> >[
                    new <Number>[c-len, c-len],
                    new <Number>[c+len, c+len],
                    new <Number>[c-len, c],
                    new <Number>[c, c-len],
                ],
                new <Vector.<Number> >[
                    new <Number>[c+len, c-len],
                    new <Number>[c-len, c+len],
                    new <Number>[c+len, c],
                    new <Number>[c, c-len],
                ],
                new <Vector.<Number> >[
                    new <Number>[c+len, c+len],
                    new <Number>[c-len, c-len],
                    new <Number>[c+len, c],
                    new <Number>[c, c+len],
                ],
            ];

            m_Bitmap_LaserButton = new Vector.<Bitmap>(LASER_DIR_NUM);
            for(i = 0; i < LASER_DIR_NUM; ++i){
                bmd = button_ninepatch.m_BitmapData.clone();

                g.clear();
                g.lineStyle(button_w/16, 0xFFFFFF, 1.0);
                g.moveTo(point[i][0][0], point[i][0][1]);
                g.lineTo(point[i][1][0], point[i][1][1]);
                g.moveTo(point[i][0][0], point[i][0][1]);
                g.lineTo(point[i][2][0], point[i][2][1]);
                g.moveTo(point[i][0][0], point[i][0][1]);
                g.lineTo(point[i][3][0], point[i][3][1]);
                bmd.draw(shape);

                bmp = new Bitmap(bmd);
                bmp.x = (i + 0.5) * VIEW_W/LASER_DIR_NUM - button_w/2;
                bmp.y = VIEW_H - button_h;

                m_Root_UI.addChild(bmp);

                m_Bitmap_LaserButton[i] = bmp;
            }

            //Pause
            {
                m_ButtonManager = new ButtonManager();

                button_w *= 0.5;
                button_h *= 0.5;

                bmd = new BitmapData(button_w, button_h, true, 0x00000000);
                bmd.draw(button_ninepatch.m_BitmapData, new Matrix(0.5, 0, 0, 0.5));

                g.clear();
                g.lineStyle(0,0,0);
                g.beginFill(0xFFFFFF, 1.0);
                g.drawRect(button_w*1/5, button_h*1/5, button_w*1/5, button_h*3/5);
                g.drawRect(button_w*3/5, button_h*1/5, button_w*1/5, button_h*3/5);
                g.endFill();
                bmd.draw(shape);

                button = new Button(bmd);
                button.x = VIEW_W - button_w/2;
                button.y = button_h/2;

                m_Root_UI.addChild(button);

                m_ButtonManager.AddButton(button);
            }
        }

        //Text
        {
            m_Text = new TextField();

            m_Text.selectable = false;
            m_Text.autoSize = TextFieldAutoSize.CENTER;
            m_Text.defaultTextFormat = new TextFormat('Verdana', 64, 0xFFFFFF, true);
            m_Text.text = "";
//            m_Text.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_NORMAL,1.0, 8,8)];
            m_Text.x = VIEW_W/2;
            m_Text.y = VIEW_H/2;

            m_Root_UI.addChild(m_Text);
        }

        //StageName
        if(in_RestructFlag)
        {
            Push(new Popup_StageName(MAP_ARR[m_MapIndex].name));
        }
    }

    //Touch
    public function OnMouseDown(e:Event):void{
        if(m_TopPopup != null){
            m_TopPopup.OnMouseDown();
            return;
        }

        if(m_Mode == MODE_GOAL){
            return;
        }

        for(var i:int = 0; i < LASER_DIR_NUM; ++i){
            var bmp:Bitmap = m_Bitmap_LaserButton[i];
            if(bmp.bitmapData.rect.contains(bmp.mouseX, bmp.mouseY)){
                Laser_Start(i);
                return;
            }
        }
        m_ButtonManager.OnMouseDown();
    }
    public function OnMouseMove(e:Event):void{
        if(m_TopPopup != null){
            m_TopPopup.OnMouseMove();
            return;
        }

        if(m_Mode == MODE_GOAL){
            return;
        }

        if(IsLaser()){
            return;
        }

        m_ButtonManager.OnMouseMove();
    }
    public function OnMouseUp(e:Event):void{
        if(m_TopPopup != null){
            m_TopPopup.OnMouseUp();
            return;
        }

        if(m_Mode == MODE_GOAL){
            return;
        }

        if(IsLaser()){
            Laser_End();
            return;
        }

        var index:int = m_ButtonManager.OnMouseUp();

        if(index < 0){//No Select
            return;
        }

        OnSelect(index);
    }
    protected function OnSelect(in_Index:int):void{
        switch(in_Index){
        case BUTTON_PAUSE:
            Push(new Popup_Pause());
            break;
        }
    }

    private function OnKeyDown(event:KeyboardEvent):void{
        switch(event.keyCode){
        case Keyboard.BACK://バックキー
//            case Keyboard.ESCAPE://PC動作チェック用
            //デフォルトの挙動をキャンセル
            event.preventDefault();

            if(m_TopPopup != null){
                m_TopPopup.OnBack();
            }else{
                //ゲーム中ならステージ選択に移行する
                Push(new Popup_StageSelect());
            }
            break;
        }
    }

    //Finish
    public function Finish(e:Event = null):void{
        removeEventListener(Event.ENTER_FRAME, Update);
//            removeEventListener(Event.REMOVED_FROM_STAGE, Finish);
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP,   OnMouseUp);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
        if(m_Context3D != null){
            m_Context3D.dispose();
            m_Context3D = null;
        }
    }
    static public function Exit():void{
        //Launcherからの起動から戻るため、アプリ自体を終わらせるのではなく自分を親から切り離す
/*
        NativeApplication.nativeApplication.exit();
/*/
        Instance.m_ExitFlag = true;
        Instance.Finish();
        Instance = null;
//*/
    }
    public var m_ExitFlag:Boolean = false;
    public function IsExit():Boolean{
        return m_ExitFlag;
    }

    //Laser : Start
    public function Laser_Start(in_LaserDir:int):void{
        //Player
        {
            m_Player.Laser_Start(in_LaserDir);
        }
    }
    public function OnLaser_Start():void{
        //実際にレーザー移動が開始された時の処理
    }
    //Laser : End
    public function Laser_End():void{
        //Player
        {
            m_Player.Laser_End();
        }
    }
    public function OnLaser_End():void{
        //実際にレーザー移動が終了した時の処理
    }
    //Laser : Check
    public function IsLaser():Boolean{
        return m_Player.IsLaser();
    }

    //Map
    public function IsWall(in_X:int, in_Y:int):Boolean{
        var index_x:int = in_X / PANEL_W;
        var index_y:int = in_Y / PANEL_W;

        var map_num_x:int = MAP[0].length;
        var map_num_y:int = MAP.length;

        //画面外は壁にしてみる
        if(index_x < 0){return true;}
        if(map_num_x <= index_x){return true;}
        if(index_y < 0){return true;}
        if(map_num_y <= index_y){return true;}

        //この関数を使うのはレーザー中のみなので、Mにも当たることにする
        var map_val:int = MAP[index_y][index_x];
        return (map_val == W) || (map_val == M);
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        Update_CPU(in_DeltaTime);

        Update_GPU();
    }
    //Update : CPU
    public function Update_CPU(in_DeltaTime:Number):void{
        //Popup
        if(Update_Popup(in_DeltaTime)){
            return;//ダイアログ表示中
        }

        if(m_Mode == MODE_GOAL){
            //Phys
            Update_Phys(in_DeltaTime);

            //GameObj
            Update_GameObj(in_DeltaTime);

            if(m_Goal.m_EndFlag){
                OnGoalEnd();
            }

            return;
        }

        //Button
        m_ButtonManager.Update(in_DeltaTime);

        //Phys
        Update_Phys(in_DeltaTime);

        //GameObj
        Update_GameObj(in_DeltaTime);

        //End Check
        Check_GameOver();
    }
    //Update : GPU
    public function Update_GPU():void{
        //Stage3Dを使うので毎フレーム必ず呼ぶ
        Update_Draw();
    }

    //Update : Popup
    public function Update_Popup(in_DeltaTime:Number):Boolean{
        if(m_TopPopup != null){
            m_TopPopup.Update(in_DeltaTime);
            if(m_TopPopup.IsEnd()){
                Pop();
            }
            return true;//ダイアログ表示中
        }

        return false;
    }

    //Update : Phys
    public function Update_Phys(in_DeltaTime:Number):void{
        //プレイヤーがレーザー化中は物理エンジンの更新は停止
        if(IsLaser()){
            return;
        }

        {
            //
            var iterations:int = 100;
            m_PhysWorld.Step(in_DeltaTime, iterations);
        }

        //Phys => GameObj
        {
            for(var iter:b2Contact = m_PhysWorld.m_contactList; iter != null; iter = iter.GetNext()){
                if(iter.GetManifoldCount() == 0){
                    continue;
                }

                var Obj1:GameObject = iter.GetShape1().m_body.m_userData as GameObject;
                var Obj2:GameObject = iter.GetShape2().m_body.m_userData as GameObject;

                var Nrm_Phys:b2Vec2 = iter.GetManifolds()[0].normal;
                var Nrm:Vector3D = new Vector3D(Nrm_Phys.x, Nrm_Phys.y);
                var Nrm_Neg:Vector3D = new Vector3D(-Nrm_Phys.x, -Nrm_Phys.y);
                Nrm.normalize();
                Nrm_Neg.normalize();

                Obj1.OnContact_Common(Obj2, Nrm);
                Obj2.OnContact_Common(Obj1, Nrm_Neg);

                Obj1.OnContact(Obj2, Nrm);
                Obj2.OnContact(Obj1, Nrm_Neg);
            }

            //Physics→GameObjectへの位置の反映
            {
                for(var bb:b2Body = m_PhysWorld.m_bodyList; bb; bb = bb.m_next) {
                    var Obj:GameObject = bb.m_userData as GameObject;
                    if(Obj != null){
                        Obj.Phys2Obj();
                    }
                }
            }
        }
    }

    //Update : GameObj
    public function Update_GameObj(in_DeltaTime:Number):void{
        var i:int;
        var obj:GameObject;

        var num:int = m_GameObject.length;

        //Update
        for(i = 0; i < num; ++i){
            m_GameObject[i].Update(in_DeltaTime);
        }

        //Remove : GameObj
        for(i = 0; i < num; ++i){
            obj = m_GameObject[i];
            if(obj.m_EndFlag){
                //Remove
                //- Phys
                if(obj.m_PhysBody != null){
                    m_PhysWorld.DestroyBody(obj.m_PhysBody);
                    obj.m_PhysBody = null;
                }
                //- Graphic
                if(obj.parent != null){
                    obj.parent.removeChild(obj);
                }
                //- List
                m_GameObject.splice(i,1);

                //Adjust
                --i;
                --num;
            }
        }

        //Remove : Block
        num = m_BlockArr.length;
        for(i = 0; i < num; ++i){
            obj = m_BlockArr[i];
            if(obj.m_EndFlag){
                //Remove
                //- List
                m_BlockArr.splice(i,1);

                //Adjust
                --i;
                --num;
            }
        }
    }

    //
    public function RecalcGlobalScale():void{
/*
        const BUTTON_H:int = GAME_W/4;
        const BUTTON_W:int = BUTTON_H;

        const BASE_W:int = GAME_W;
        const BASE_H:int = GAME_H + BUTTON_H;

        var total_w:Number = GetTotalW();
        var total_h:Number = GetTotalH();

        m_GlobalScaleCandX = total_w / BASE_W;
        m_GlobalScaleCandY = (total_h - total_w/4) / BASE_H;

        if(m_GlobalScaleCandX < m_GlobalScaleCandY){
            m_GlobalScale = m_GlobalScaleCandX;

            m_GlobalScaleCandX = total_w / BASE_W;
            m_GlobalScaleCandY = total_h / BASE_W;

            m_GameLX = 0;
            m_GameUY = 0;//1 - (total_w * (m_GlobalScale / m_GlobalScaleCandX)) / total_h;//0;

            //下のボタンを上に持ってくる
            for(var i:int = 0; i < 4; ++i){
                m_Bitmap_LaserButton[i].y = VIEW_W;
            }
        }else{
            m_GlobalScale = m_GlobalScaleCandY;

            //  total_h * (m_GlobalScale / m_GlobalScaleCandY)
            //= total_w * (m_GlobalScale / m_GlobalScaleCandX)
            //= total_h - total_w/4
            m_GlobalScaleCandX = total_w / BASE_H;
            m_GlobalScaleCandY = total_h / BASE_H;

            m_GameLX = 1 - (total_h * (m_GlobalScale / m_GlobalScaleCandY)) / total_w;//1;//total_w/2 - total_w/2 * m_GlobalScale / m_GlobalScaleCandX;
            m_GameUY = 0;
        }
/*/
        //Wonderfl用決め打ち
        m_GlobalScale = 465 / GAME_W;
        m_GlobalScaleCandX = 465 / GAME_W;
        m_GlobalScaleCandY = 465 / GAME_H;
        m_GameLX = 0;
        m_GameUY = 0;
//*/
    }

    //Update : Draw
    public function Update_Draw():void{
        //タイトルが表示されるまでは黒くしておく
        if(m_TopPopup != null && !(m_TopPopup is Popup_StageName && (m_TopPopup as Popup_StageName).IsFading())){
            m_Context3D.clear(0,0,0,1, 0);
            m_Context3D.present();
            return;
        }

        //Clear
        m_Context3D.clear(0,0,0,1, 0);

        //Alias
        var is_laser:Boolean = IsLaser();

        //Param
        RecalcGlobalScale();
        var scl_x:Number = 2 * m_GlobalScale / m_GlobalScaleCandX;
        var scl_y:Number = 2 * m_GlobalScale / m_GlobalScaleCandY;

        //Common Settings
        {
            //Verticesの設定は全員同じなので、ここで一回だけの設定にしてみる
            {
                //va0 : 座標：Float×3
                m_Context3D.setVertexBufferAt(0, m_Player.m_Vertices, 0, Context3DVertexBufferFormat.FLOAT_3);
                //va1 : UV：Float×２
                m_Context3D.setVertexBufferAt(1, m_Player.m_Vertices, 3, Context3DVertexBufferFormat.FLOAT_2);
            }
        }

        //Draw
        var num:int = m_GameObject.length;
        for(var i:int = 0; i < num; ++i){
            var obj:GameObject = m_GameObject[i];

            obj.Draw(m_Context3D, is_laser, scl_x, scl_y, m_GameLX, m_GameUY);
        }

        //反映
        m_Context3D.present();
    }

    //Check : GameOver
    public function Check_GameOver():void{
        //Goal
        if(m_Goal.m_GoalFlag){
            OnGoal();
            return;
        }

//        //Dead End
//        if(m_Player.m_HP <= 0){
//            OnDead();
//            return;
//        }
    }

    //GameOver : Goal
    public function OnGoal():void{
        if(IsLaser()){
            Laser_End();
            OnLaser_End();
            m_Player.OnLaser_End();
        }

        //Mode
        {
            m_Mode = MODE_GOAL;
        }

        m_Player.m_EndFlag = true;
    }

    public function OnGoalEnd():void{
        var IsAllClear_Old:Boolean = IsAllClear();

        //Set Clear Flag
        {
            SetClear(m_MapIndex);
        }

        var IsAllClear_New:Boolean = IsAllClear();

        //Popup
        if(IsAllClear_Old || !IsAllClear_New)
        {
            Push(new Popup_Result(true));
        }
        else
        {//今回が初めてのクリア→コングラッチュレーション
            Push(new Popup_AllClear());
        }
    }


    //Popup : Push
    public function Push(in_Popup:Popup):void{
        if(m_Popup_Queue.length <= 0){
            m_TopPopup = in_Popup;

            //Register View
            m_Root_UI.addChild(in_Popup);
        }

        //Push Stack
        m_Popup_Queue.push(in_Popup);
    }

    //Popup : Pop
    public function Pop():void{
        //Push Next
        {
            var next_popup:Popup = m_TopPopup.GetNextPopup();
            if(next_popup != null){
                Push(next_popup);
            }
        }

        //Remove Old
        {
            var popup:Popup = m_Popup_Queue.shift();
            popup.parent.removeChild(popup);
        }

        //Remember Top
        {
            var length:int = m_Popup_Queue.length;
            if(0 < length){
                m_TopPopup = m_Popup_Queue[length - 1];
                m_Root_UI.addChild(m_TopPopup);
            }else{
                m_TopPopup = null;
            }
        }
    }


    //ClearInfo
    //- Base
    static public var s_SharedObject:SharedObject = null;
    static public function GetSharedObject():SharedObject{
        if(s_SharedObject == null){
            s_SharedObject = SharedObject.getLocal("LaserBouncer_Wonderfl");
        }
        return s_SharedObject;
    }
    static public function GetClearInfo():Array{
        var so:SharedObject = GetSharedObject();

        var i:int;

        var arr:Array = so.data.clear_info;
        if(arr == null){
            //まだ作られていなかったらフラグを全てオフにして作成
            arr = new Array(MAP_ARR.length);
            for(i = 0; i < MAP_ARR.length; ++i){
                arr[i] = false;
            }
            so.data.clear_info = arr;
        }else{
            if(arr.length != MAP_ARR.length){
                //前回よりステージ数が増えているようなら、追加されたぶんはフラグをオフにして追加
                var new_arr:Array = new Array(MAP_ARR.length);
                for(i = 0; i < MAP_ARR.length; ++i){
                    if(i < arr.length){
                        new_arr[i] = arr[i];
                    }else{
                        new_arr[i] = false;
                    }
                }
                arr = new_arr;
                so.data.clear_info = arr;
            }
        }

        return arr;
    }
    //- Get
    static public function IsClear(in_StageIndex:int):Boolean{
        var arr:Array = GetClearInfo();
        return arr[in_StageIndex];
    }
    static public function IsAllClear():Boolean{
        var flag:Boolean = true;
        {
            var arr:Array = GetClearInfo();
            for(var i:int = 0; i < arr.length; ++i){
                if(! arr[i]){flag = false; break;}
            }
        }
        return flag;
    }
    //- Set
    static public function SetClear(in_StageIndex:int):void{
        var arr:Array = GetClearInfo();
        arr[in_StageIndex] = true;

        var so:SharedObject = GetSharedObject();
        so.data.clear_info = arr;
    }
}


//GameObject : Interface
class GameObject extends Sprite
{
    //==Const==

    static public const PHYS_SCALE:Number = ActGameEngine.PHYS_SCALE;

    static public const RESTITUTION:Number = 0.1;

    //衝突マスク
    static public const TERRAIN_BITS    :uint = 0x01;
    static public const TERRAIN_MASKBITS:uint = 0x01;
    static public const SEESAW_BITS        :uint = 0x02;
    static public const SEESAW_MASKBITS    :uint = 0x02;
    static public const BLOCK_BITS        :uint = 0x01 | 0x2;
    static public const BLOCK_MASKBITS    :uint = 0x01 | 0x2;

    //擬似定数（Mapで値を設定）
    static public var IMPULSE_POW:Number = 0.05;

    //==Var==

    //Pyhsics
    //!!

    //MapVal
    public var m_MapVal:int = -1;

    //Phys World
    public var m_PhysWorld:b2World;

    //Phys
    public var m_PhysBody:b2Body;
    public var m_Friction:Number = 0;//0.05;

    //3D
    public var m_Context3D:Context3D;
    public var m_BitmapData:BitmapData;
    public var m_BitmapData_Additional:BitmapData = null;
    public var m_Texture:Texture;
    public var m_Texture_Additional:Texture = null;
    public var m_Vertices:VertexBuffer3D;
    public var m_Matrix3D:Matrix3D;
    public var m_VertexAssembly:AGALMiniAssembler;
    public var m_FragmentAssembly_Normal:AGALMiniAssembler;
    public var m_FragmentAssembly_Monochrome:AGALMiniAssembler;
    public var m_ProgramPair_Normal:Program3D;
    public var m_ProgramPair_Monochrome:Program3D;
    public var m_Indices:IndexBuffer3D;
    public var m_RelLightDir:Vector3D = new Vector3D();

    public var m_BaseColor:uint = 0xFFFFFFFF;
    public var m_BaseColor_Additional:uint = 0xFFFFFFFF;

    public var m_LocalScl:Number = 1;

    //- Shader
//*
    //法線描画（テクスチャを法線マップとして使い、光源位置などから色々と表示）
    //- ノートPCでもそこそこの速度が出るようにする
    //-- Vertex
    static public const VERTEX_SHADER:String =
        "mov v1, va1                        \n" +//v1：UV座標
        "m44 op, va0, vc0                    ";//vt0：位置
    //-- Fragment
    //--- 法線と光源位置を元に明るさを求める
    static public const FRAGMENT_SHADER_NORMAL:String =
        //まずは法線を求め、ft0に格納する
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft0, ft0, fc0.yyyx                    \n" +    //(0～1)→(-0.5～0.5)にしつつ、αチェックのための値も引く
        "kil ft0.w                                \n" +    //この時点でαが０の時は表示を飛ばす（深度を更新しない）
        //法線と光源方向の内積から明るさを求め、ft2に格納する
        "dp3 ft2, ft0, fc1                        \n" +    //内積
        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-0.5, 0.5) => (0, 1)

        //基本色と掛け合わせて表示
        "add ft2.w, ft0.w, fc0.x                \n" +    //αを元に戻す
        "mul oc, ft2, fc2                        ";        //基本色をかける
    static public const FRAGMENT_SHADER_MONO:String =
        //まずは法線を求め、ft0に格納する
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft0, ft0, fc0.yyyx                    \n" +    //(0～1)→(-0.5～0.5)にしつつ、αチェックのための値も引く
        "kil ft0.w                                \n" +    //この時点でαが０の時は表示を飛ばす（深度を更新しない）
        //法線と光源方向の内積から明るさを求め、ft2に格納する
        "dp3 ft2, ft0, fc1                        \n" +    //内積
        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-0.5, 0.5) => (0, 1)

        //モノクロ表示
        "mul ft0.xyz, ft2.xyz, fc0.zzz            \n" +    //モノクロ色と法線による陰影の合成
        "mov oc, ft0                            ";        //表示
    static public const FRAGMENT_SHADER_LASER:String =
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft1.w, ft0.w, fc0.x                \n" +    //αを－１してKilチェック準備
        "kil ft1.w                                \n" +    //αが０の時は表示を飛ばす（深度を更新しない）
        "mov oc, ft0                            ";        //表示
    static public const FRAGMENT_SHADER_GOAL:String =
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft1.w, ft0.w, fc0.x                \n" +    //αを－１してKilチェック準備
        "kil ft1.w                                \n" +    //αが０の時は表示を飛ばす（深度を更新しない）
        "mul ft0.w, ft0.w, fc0.w                \n" +    //外部からα設定
        "mov oc, ft0                            ";        //表示
//*/
/*
    //法線描画（テクスチャを法線マップとして使い、光源位置などから色々と表示）
    //- 実際にはカメラ方向などまで考慮すべきだが、とりあえず光源の方を向いてれば明るくする
    //-- Vertex
    private const VERTEX_SHADER:String =
        "m44 vt0, va0, vc0                    \n" +//vt0：位置
        "mov v0, vt0                        \n" +//v0：位置
        "mov v1, va1                        \n" +//v1：UV座標
        "mov op, vt0                            \n";//出力：位置
    //-- Fragment
    //--- 法線と光源位置を元に明るさを求める
    private const FRAGMENT_SHADER_NORMAL:String =
        //まずは法線を求め、ft0に格納する
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft0, ft0, fc0.yyyx                    \n" +    //(0～1)→(-0.5～0.5)にしつつ、αチェックのための値も引く
        "kil ft0.w                                \n" +    //この時点でαが０の時は表示を飛ばす（深度を更新しない）
        "div ft0.xyz, ft0.xyz, fc0.yyy            \n" +    //(-0.5～0.5)→(-1～1)
        "m44 ft0, ft0, fc3                         \n" +    //グラフィックと同じく回転させる
        //次に光源方向を求め、ft1に格納する
//        "sub ft1, fc1, v0                        \n" +    //相対位置を求める
//        "nrm ft1.xyz, ft1.xyz                    \n" +    //正規化する（長さが０の時の挙動がよくわからないが、それは設定側で吸収することにした）
        "mov ft1, fc1                            \n" +    //光源を方向で扱う場合
        //法線と光源方向の内積から明るさを求め、ft2に格納する
        "dp3 ft2, ft0, ft1                        \n" +    //内積
        "mul ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-1, 1) => (-0.5, 0.5)
        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-0.5, 0.5) => (0, 1)
//        "mul ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(0, 1) => (0, 0.5)
//        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(0, 0.5) => (0.5, 1)

        //基本色と掛け合わせて表示
        "mov ft2.w, ft0.w                        \n" +    //表示
        "mul ft2, ft2, fc2                        \n" +    //基本色をかける
        "mov oc, ft2                            ";        //表示
    private const FRAGMENT_SHADER_MONO:String =
        //まずは法線を求め、ft0に格納する
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft0, ft0, fc0.yyyx                    \n" +    //(0～1)→(-0.5～0.5)にしつつ、αチェックのための値も引く
        "kil ft0.w                                \n" +    //この時点でαが０の時は表示を飛ばす（深度を更新しない）
        "div ft0.xyz, ft0.xyz, fc0.yyy            \n" +    //(-0.5～0.5)→(-1～1)
        "m44 ft0, ft0, fc3                         \n" +    //グラフィックと同じく回転させる
        //次に光源方向を求め、ft1に格納する
//        "sub ft1, fc1, v0                        \n" +    //相対位置を求める
//        "nrm ft1.xyz, ft1.xyz                    \n" +    //正規化する（長さが０の時の挙動がよくわからないが、それは設定側で吸収することにした）
        "mov ft1, fc1                            \n" +    //光源を方向で扱う場合
        //法線と光源方向の内積から明るさを求め、ft2に格納する
        "dp3 ft2, ft0, ft1                        \n" +    //内積
        "mul ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-1, 1) => (-0.5, 0.5)
        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(-0.5, 0.5) => (0, 1)
//        "mul ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(0, 1) => (0, 0.5)
//        "add ft2, ft2, fc0.yyyy                    \n" +    //値の補正：(0, 0.5) => (0.5, 1)

        //基本色の平均をとってモノクロとして表示する
        "mov ft3.x, fc2.x                        \n" +    //モノクロ化（R = R）
        "add ft3.x, ft3.x, fc2.y                \n" +    //モノクロ化（R = R+G）
        "add ft3.x, ft3.x, fc2.z                \n" +    //モノクロ化（R = R+G+B）
        "div ft3.xyz, ft3.x, fc0.z                \n" +    //モノクロ化（RGB = (R+G+B)/3）
        "mov ft2.w, ft0.w                        \n" +    //表示
        "mul ft2.xyz, ft2.xyz, ft3.xyz            \n" +    //基本色をかける
        "mov oc, ft2                            ";        //表示
    private const FRAGMENT_SHADER_LASER:String =
        "tex ft0, v1, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft1.w, ft0.w, fc0.x                \n" +    //αを－１してKilチェック準備
        "kil ft1.w                                \n" +    //αが０の時は表示を飛ばす（深度を更新しない）
        "mov oc, ft0                            ";        //表示
//*/
/*
    //通常描画（テクスチャをそのまま表示）
    //-- Vertex
    private const VERTEX_SHADER:String =
        "m44 op, va0, vc0                    \n" +
        "mov v0, va1";
    //-- Fragment
    private const FRAGMENT_SHADER_NORMAL:String =
        "tex ft0, v0, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft1.w, ft0.w, fc0.x                \n" +    //αを－１してKilチェック準備
        "kil ft1.w                                \n" +    //αが０の時は表示を飛ばす（深度を更新しない）
        "mov oc, ft0                            ";        //表示
    private const FRAGMENT_SHADER_MONO:String =
        "tex ft0, v0, fs0 <2d,linear,clamp>        \n" +    //ft0にテクスチャ参照の結果を入れる
        "sub ft1.w, ft0.w, fc0.x                \n" +    //αを－１してKilチェック準備
        "kil ft1.w                                \n" +    //αが０の時は表示を飛ばす（深度を更新しない）
        "add ft0.x, ft0.x, ft0.y                \n" +    //モノクロ化（R = R+G）
        "add ft0.x, ft0.x, ft0.z                \n" +    //モノクロ化（R = R+G+B）
        "div ft0.xyz, ft0.x, fc0.y                \n" +    //モノクロ化（RGB = (R+G+B)/3）
        "mov oc, ft0                            ";        //表示
//*/

    //Fragile
    public var m_FragileRatio:Number = 0;

    //Flag
    public var m_UseSleep:Boolean = true;
    public var m_GroundFlag:Boolean = false;
    public var m_EndFlag:Boolean = false;


    //==Function==

    //#Common

    //Init
    public function GameObject(in_Context3D:Context3D){
        m_Context3D = in_Context3D;
    }

    //Update
    public function Update(in_DeltaTime:Number):void{
        const FRAGILE_TIME:Number = 0.1;
        if(0 < m_FragileRatio){
            m_FragileRatio -= in_DeltaTime / FRAGILE_TIME;
            var alpha:uint = 0xFF * Math.max(m_FragileRatio, 0);
            m_BaseColor &= 0x00FFFFFF;
            m_BaseColor |= (alpha << 24);

            if(m_FragileRatio <= 0){
                m_EndFlag = true;
            }
        }
    }

    //Param for Draw
    public var m_OffsetX:Number = 0;
    public var m_OffsetY:Number = 0;
    public function SetOffset(in_OffsetX:Number, in_OffsetY:Number):void{
        m_OffsetX = in_OffsetX;
        m_OffsetY = in_OffsetY;
    }
    public function GetLX():Number{
        return this.x;
    }
    public function GetUY():Number{
        return this.y;
    }
    public function GetW():Number{
        return m_BitmapData.width;
    }
    public function GetH():Number{
        return m_BitmapData.height;
    }


    //Damage
    public function OnDamage(in_Val:int):void{
    }


    //#Physics

    //Ready : Body
    public function ReadyBody():void{
        //Check
        if(m_PhysBody != null){
            return;
        }

        //Definition
        //- Default
        var physBodyDef:b2BodyDef = new b2BodyDef();
        physBodyDef.position.Set(this.x / PHYS_SCALE, this.y / PHYS_SCALE);
        physBodyDef.fixedRotation = true;
        physBodyDef.allowSleep = m_UseSleep;
        physBodyDef.userData = this;
        //- Append
        switch(m_MapVal){
        case ActGameEngine.A:
        case ActGameEngine.B:
        case ActGameEngine.U:
        case ActGameEngine.V:
            physBodyDef.fixedRotation = false;
            break;
        case ActGameEngine.Z:
            physBodyDef.fixedRotation = false;
            physBodyDef.isBullet = true;
            break;
        }
        if(this is Player){
            physBodyDef.isBullet = true;
        }

        //Create
        m_PhysBody = m_PhysWorld.CreateBody(physBodyDef);
    }

    //Create : Box : Fix
    public function CreateCollision_Box_Fix(lx:int, uy:int, w:int, h:int):void{
        //Bodyの用意
        ReadyBody();

        var shapeDef:b2PolygonDef = new b2PolygonDef();
        shapeDef.SetAsOrientedBox(w/2/PHYS_SCALE, h/2/PHYS_SCALE, new b2Vec2((lx+w/2)/PHYS_SCALE, (uy+h/2)/PHYS_SCALE));
        //- default
        shapeDef.density = 0;//Fix
        shapeDef.friction = m_Friction;
        shapeDef.restitution = RESTITUTION;
        shapeDef.filter.categoryBits = TERRAIN_BITS;
        shapeDef.filter.maskBits = TERRAIN_MASKBITS;

        m_PhysBody.CreateShape(shapeDef);
    }

    //Create : Box : Dynamic
    public function CreateCollision_Box_Dynamic(lx:int, uy:int, w:int, h:int):void{
        //Bodyの用意
        ReadyBody();

        var shapeDef:b2PolygonDef = new b2PolygonDef();
        shapeDef.SetAsOrientedBox(w/2/PHYS_SCALE, h/2/PHYS_SCALE, new b2Vec2((lx+w/2)/PHYS_SCALE, (uy+h/2)/PHYS_SCALE));
        shapeDef.density = 0.01;
        shapeDef.friction = m_Friction;
        shapeDef.restitution = RESTITUTION;
//        shapeDef.filter.categoryBits = i_Param.category_bits;
//        shapeDef.filter.maskBits = i_Param.mask_bits;

        m_PhysBody.CreateShape(shapeDef);

        m_PhysBody.SetMassFromShapes();
    }

    //Create : Box : Sensor
    public function CreateSensor_Box(lx:int, uy:int, w:int, h:int):void{
        //Bodyの用意
        ReadyBody();

        var shapeDef:b2PolygonDef = new b2PolygonDef();
        shapeDef.SetAsOrientedBox(w/2/PHYS_SCALE, h/2/PHYS_SCALE, new b2Vec2((lx+w/2)/PHYS_SCALE, (uy+h/2)/PHYS_SCALE));
        shapeDef.density = 0;//Fix
        shapeDef.friction = m_Friction;
//        shapeDef.restitution = 0.5;
//        shapeDef.filter.categoryBits = i_Param.category_bits;
//        shapeDef.filter.maskBits = i_Param.mask_bits;
        shapeDef.isSensor = true;

        m_PhysBody.CreateShape(shapeDef);
    }

    //Create : Ball : Dynamic
    public function CreateCollision_Ball_Dynamic(rad:Number):void{
        //Bodyの用意
        ReadyBody();

        var shapeDef:b2CircleDef = new b2CircleDef();
        shapeDef.radius = rad/PHYS_SCALE;
        shapeDef.density = 1;
        shapeDef.friction = 0.5;//摩擦を大きめにして、地面のスライドは抑制してみる
        shapeDef.restitution = RESTITUTION;
        shapeDef.filter.categoryBits = BLOCK_BITS;
        shapeDef.filter.maskBits = BLOCK_MASKBITS;

        m_PhysBody.CreateShape(shapeDef);

        m_PhysBody.SetMassFromShapes();
    }

    //Contact : Common
    public function OnContact_Common(in_Obj:GameObject, in_Nrm:Vector3D):void{
        //コリジョンに接触したら必ず呼ばれる
    }

    //Contact : 
    public function OnContact(in_Obj:GameObject, in_Nrm:Vector3D):void{
        //こっちはオーバーライドして各自で使う
        //→内部分岐で使うことにした

        switch(m_MapVal){
        case ActGameEngine.Q:
        case ActGameEngine.R:
            OnContact_Trampolin(in_Obj, in_Nrm);
            break;
        case ActGameEngine.I:
        case ActGameEngine.J:
            OnContact_Fragile(in_Obj, in_Nrm);
            break;
        }
    }

    //Contact : Trampolin
    public function OnContact_Trampolin(in_Obj:GameObject, in_Nrm:Vector3D):void{
        var impulse:b2Vec2 = new b2Vec2(
            in_Nrm.x * IMPULSE_POW / PHYS_SCALE,
            in_Nrm.y * IMPULSE_POW / PHYS_SCALE
        );

        var point:b2Vec2 = new b2Vec2(
            this.x / PHYS_SCALE,
            this.y / PHYS_SCALE
        );

        if(in_Obj.m_PhysBody != null){
            in_Obj.m_PhysBody.ApplyImpulse(impulse, point);
//            in_Obj.m_PhysBody.ApplyForce(impulse, point);
        }
/*
            const W:int = ImageManager.PANEL_LEN;

            var Val:int;
            {
                if(m_Val > 0){
                    Val = m_Val;
                }else{
                    Val = 5;
                }
            }

            //#Y

            var VY:Number = MyMath.Sqrt(2 * PhysManager.GRAVITY * (Val * W*PhysManager.PHYS_SCALE + W/4*PhysManager.PHYS_SCALE))

            //上に乗られた
            {
                if(in_Nrm.y < -0.7){
                    //Valの数のブロック分、上に移動させる
                    //H = 0.5*VY^2/G
                    //VY = Sqrt(2 * G * Height)
                    in_Obj.SetVY(-VY);
                    return;
                }
            }

            //下に接触した
            {
                if(in_Nrm.y >  0.7){
                    //必要性が特にないので、適当に上とは逆のベクトルを設定するのみ
                    in_Obj.SetVY(VY);
                    return;
                }
            }


            //#X

            //空中で当たったときにやはりおかしいので、VYと共通の値にする
            var VX:Number = VY;

            //右側と接触
            {
                if(in_Nrm.x >  0.7){
                    in_Obj.SetVX(VX);
                    return;
                }
            }
            //左側と接触
            {
                if(in_Nrm.x < -0.7){
                    in_Obj.SetVX(-VX);
                    return;
                }
            }
        }
//*/
    }

    //Contact : Fragile
    public function OnContact_Fragile(in_Obj:GameObject, in_Nrm:Vector3D):void{
        if(0 < m_FragileRatio){
            return;
        }
        if(m_PhysBody == null){
            return;
        }

        if(in_Obj is Player){
            //プレイヤーとぶつかったら壊れる

            //一定速度以上での接触にのみ反応
            const ThresholdVel:Number = 0;//Player.LASER_VEL / 200;
            var Vel:b2Vec2 = in_Obj.m_PhysBody.GetLinearVelocity();

            if(Vel.Length() * PHYS_SCALE < ThresholdVel){
                return;
            }

            //m_EndFlag = true;
            m_FragileRatio = 1;
            ActGameEngine.Instance.m_PhysWorld.DestroyBody(m_PhysBody);
            m_PhysBody = null;
        }
    }

    //Sync : Physics=>Obj
    public function Phys2Obj():void{
        //コリジョンの位置を実際の位置として採用する

        //Check
        {
            if(m_PhysBody == null){
                return;
            }
        }

        //Pos
        {
            this.x = m_PhysBody.GetPosition().x * PHYS_SCALE;
            this.y = m_PhysBody.GetPosition().y * PHYS_SCALE;
        }

        //Rot
        {
            this.rotation = m_PhysBody.GetAngle() * 360/(2*Math.PI);
        }
    }


    //#3D
    public function Reset3D():void{
        //m_BitmapDataは設定されているという前提
        m_Texture = m_Context3D.createTexture(m_BitmapData.width, m_BitmapData.height, Context3DTextureFormat.BGRA, false);
        m_Texture.uploadFromBitmapData(m_BitmapData);

        m_Matrix3D = new Matrix3D();

        m_VertexAssembly = new AGALMiniAssembler();
        m_VertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

        m_FragmentAssembly_Normal = new AGALMiniAssembler();
        m_FragmentAssembly_Normal.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_NORMAL);
        m_ProgramPair_Normal    = m_Context3D.createProgram();
        m_ProgramPair_Normal.upload(m_VertexAssembly.agalcode, m_FragmentAssembly_Normal.agalcode);

        if(this is Player){
            m_FragmentAssembly_Monochrome = new AGALMiniAssembler();
            m_FragmentAssembly_Monochrome.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_LASER);
            m_ProgramPair_Monochrome        = m_Context3D.createProgram();
            m_ProgramPair_Monochrome.upload(m_VertexAssembly.agalcode, m_FragmentAssembly_Monochrome.agalcode);
        }else{
            m_FragmentAssembly_Monochrome = new AGALMiniAssembler();
            m_FragmentAssembly_Monochrome.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_MONO);
            m_ProgramPair_Monochrome        = m_Context3D.createProgram();
            m_ProgramPair_Monochrome.upload(m_VertexAssembly.agalcode, m_FragmentAssembly_Monochrome.agalcode);
        }

        const DEPTH:Number = 0.5;
        const VERTEX_DATA:Vector.<Number> = Vector.<Number>([
             0,-1,DEPTH, 0,1,  // x,y,z, u,v のフォーマット
             0, 0,DEPTH, 0,0,
             1, 0,DEPTH, 1,0,
             1,-1,DEPTH, 1,1
        ]);
        m_Vertices = m_Context3D.createVertexBuffer(4,5);
        m_Vertices.uploadFromVector(VERTEX_DATA, 0, 4);

        const INDEX_DATA:Vector.<uint> = Vector.<uint>([
            0, 1, 2,
            2, 3, 0,
        ]);
        m_Indices = m_Context3D.createIndexBuffer(6);
        m_Indices.uploadFromVector(INDEX_DATA, 0, 6);
    }
    public function Draw(in_Context3D:Context3D, in_IsLaser:Boolean, in_SclX:Number, in_SclY:Number, in_LX:Number, in_UY:Number):void{
        //未初期化なら何もしない
        if(m_Matrix3D == null){
            return;
        }

        Draw_CommonSettings(in_Context3D, in_IsLaser, in_SclX, in_SclY, in_LX, in_UY);

        if(m_Texture != null){
            Draw_Innner(in_Context3D, in_IsLaser, in_SclX, in_SclY, in_LX, in_UY, m_BaseColor, m_Texture);
        }

        if(m_Texture_Additional != null){
            Draw_Innner(in_Context3D, in_IsLaser, in_SclX, in_SclY, in_LX, in_UY, m_BaseColor_Additional, m_Texture_Additional);
        }
    }
    public function Draw_CommonSettings(in_Context3D:Context3D, in_IsLaser:Boolean, in_SclX:Number, in_SclY:Number, in_LX:Number, in_UY:Number):void{
        const GAME_W:int = ActGameEngine.GAME_W;
        const GAME_H:int = ActGameEngine.GAME_H;

        //ブレンドを行う
        in_Context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        //常時表示
        in_Context3D.setDepthTest(true, Context3DCompareMode.ALWAYS);

//        in_Context3D.setCulling();

//        //va0 : 座標：Float×3
//        in_Context3D.setVertexBufferAt(0, m_Vertices, 0, Context3DVertexBufferFormat.FLOAT_3);
//        //va1 : UV：Float×２
//        in_Context3D.setVertexBufferAt(1, m_Vertices, 3, Context3DVertexBufferFormat.FLOAT_2);

        //Vertex Param
        //- 初期化
        m_Matrix3D.identity();
/*
        //- スケーリング
        var local_scl_x:Number = m_LocalScl * m_BitmapData.width / GAME_W;
        var local_scl_y:Number = m_LocalScl * m_BitmapData.height / GAME_H;
        m_Matrix3D.appendScale(in_SclX * local_scl_x, in_SclY * local_scl_y, 1);
        //- オフセット
        m_Matrix3D.appendTranslation(m_OffsetX * 2/GAME_W, -m_OffsetY * 2/GAME_H, 0);
        //- 回転
        m_Matrix3D.appendRotation(-this.rotation, Vector3D.Z_AXIS);
        //- 位置調整
        var game_x:Number = in_LX + GetLX();
        var game_y:Number = in_UY + GetUY();
//        m_Matrix3D.appendTranslation(-1 + game_x * 2/GAME_W, +1 - game_y * 2/GAME_H, 0);
        m_Matrix3D.appendTranslation(-1 + game_x * 2/GAME_W, +1 - game_y * 2/(GAME_H + GAME_W/4), 0);
//*/
//*
        //- スケーリング
        var local_scl_x:Number = m_LocalScl * m_BitmapData.width / GAME_W;
        var local_scl_y:Number = m_LocalScl * m_BitmapData.height / GAME_H;
        m_Matrix3D.appendScale(local_scl_x, local_scl_y, 1);
        //- オフセット
//        m_Matrix3D.appendTranslation(m_OffsetX * 2/GAME_W / in_SclX, -m_OffsetY * 2/GAME_H / in_SclY, 0);
        //- 回転
        m_Matrix3D.appendRotation(-this.rotation, Vector3D.Z_AXIS);
        //- スケーリング
        m_Matrix3D.appendScale(in_SclX, in_SclY, 1);
        //- 位置調整
        var game_x:Number = GetLX();
        var game_y:Number = GetUY();
//        m_Matrix3D.appendTranslation(-1 + game_x * 2/GAME_W, +1 - game_y * 2/GAME_H, 0);
        m_Matrix3D.appendTranslation(-1 + in_LX + game_x * 2/(GAME_W / (in_SclX/2)), +1 - in_UY- game_y * 2/(GAME_H / (in_SclY/2)), 0);
//*/
        //- セット
        //-- 転置しないと正常に動作しないので注意
        in_Context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m_Matrix3D, true);

        //Light
        var player:Player = ActGameEngine.Instance.m_Player;
        const light_dir:Vector3D = new Vector3D(-0.5, -0.8, +0.9);
//        const light_dir:Vector3D = new Vector3D(-0.5 + 0.001*(player.x - GAME_W/2), -0.8 + 0.001*(player.y - GAME_H/2), +0.9);//いまいち
        const light_dir_len:Number = light_dir.length;
        var theta:Number = this.rotation * Math.PI/180;
        var cos:Number = Math.cos(theta);
        var sin:Number = Math.sin(theta);
        m_RelLightDir.x = (light_dir.x *  cos + light_dir.y * sin) / light_dir_len;
        m_RelLightDir.y = (light_dir.x * -sin + light_dir.y * cos) / light_dir_len;
        m_RelLightDir.z = light_dir.z / light_dir_len;
        //
        const frag_param1:Vector.<Number> = new <Number>[
            //光源位置
/*
            -1 + 2.0*player.x/GAME_W,
            -1 + 2.0*player.y/GAME_W,
            0.5 + 3.0,
            1,
/*/
            m_RelLightDir.x,
            m_RelLightDir.y,
            m_RelLightDir.z,
            1,
//*/
        ];
        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, frag_param1);

        //シェーダ
        in_Context3D.setProgram(in_IsLaser? m_ProgramPair_Monochrome: m_ProgramPair_Normal);
    }
    public function Draw_Innner(in_Context3D:Context3D, in_IsLaser:Boolean, in_SclX:Number, in_SclY:Number, in_LX:Number, in_UY:Number, in_BaseColor:uint, in_Texture:Texture):void{
        //テクスチャの設定
        in_Context3D.setTextureAt(0, in_Texture);

        //Fragment Param
        const r:uint = (in_BaseColor >> 16) & 0xFF;
        const g:uint = (in_BaseColor >>  8) & 0xFF;
        const b:uint = (in_BaseColor >>  0) & 0xFF;
        const alpha_threshold:Number = 1.0 * 0x01/0xFF;
        const frag_param0:Vector.<Number> = new <Number>[
            alpha_threshold,
            0.5,//法線計算用
            (r+g+b)/255.0 / 3,//モノクロ用のカラー
            this.alpha,
        ];
        const frag_param2:Vector.<Number> = new <Number>[
            ((in_BaseColor >> 16) & 0xFF) / 255.0,
            ((in_BaseColor >>  8) & 0xFF) / 255.0,
            ((in_BaseColor >>  0) & 0xFF) / 255.0,
            ((in_BaseColor >> 24) & 0xFF) / 255.0,
        ];
//        m_Matrix3D.identity();
//        m_Matrix3D.appendRotation(this.rotation, Vector3D.Z_AXIS);
//        m_Matrix3D.appendScale(2, 2, 1);//シェーダ内での計算を高速化するための設定
        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, frag_param0);
//        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, frag_param1);
        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, frag_param2);
//        in_Context3D.setProgramConstantsFromMatrix(Context3DProgramType.FRAGMENT, 3, m_Matrix3D, true);

        //描画
        in_Context3D.drawTriangles(m_Indices);
    }
}


//GameObject : BG
class BackGround extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D):BackGround{
        var bg:BackGround = new BackGround(in_Context3D);

        //Set Param
        {
            bg.m_PhysWorld = in_PhysWorld;
        }

        //Graphic
        {
            bg.m_BitmapData = ImageManager.CreateBackGroundGraphic(in_Map);
            bg.Reset3D();

//            bg.m_BaseColor = 0xFF202840;
//            bg.m_BaseColor = 0xFF251404;
            bg.m_BaseColor = 0xFF183043;
//            bg.m_BaseColor = 0xFF402002;
        }
/*
        {//!!test
            bg.m_FragmentAssembly_Normal = new AGALMiniAssembler();
            bg.m_FragmentAssembly_Normal.assemble(Context3DProgramType.FRAGMENT, GameObject.FRAGMENT_SHADER_LASER);
            bg.m_ProgramPair_Normal    = in_Context3D.createProgram();
            bg.m_ProgramPair_Normal.upload(bg.m_VertexAssembly.agalcode, bg.m_FragmentAssembly_Normal.agalcode);
        }
//*/
        return bg;
    }


    //==Function==

    //Init
    public function BackGround(in_Context3D:Context3D){
        super(in_Context3D);
    }
}

//GameObject : Mirror
class Mirror extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D):Mirror{
        var bg:Mirror = new Mirror(in_Context3D);

        //Set Param
        {
            bg.m_PhysWorld = in_PhysWorld;
        }

        //Graphic
        {
            bg.m_BitmapData = ImageManager.CreateMirrorGraphic(in_Map);
            bg.Reset3D();

            bg.m_BaseColor = 0x40888888;
        }

        return bg;
    }


    //==Function==

    //Init
    public function Mirror(in_Context3D:Context3D){
        super(in_Context3D);
    }
}

//GameObject : Terrain
class Terrain extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D):Terrain{
        var bg:Terrain = new Terrain(in_Context3D);

        //Set Param
        {
            bg.m_PhysWorld = in_PhysWorld;
        }

        //Graphic
        {
            bg.m_BitmapData = ImageManager.CreateTerrainGraphic(in_Map);
            bg.Reset3D();

//            bg.m_BaseColor = 0xFF4C5B80;
//            bg.m_BaseColor = 0xFF9D540D;
            bg.m_BaseColor = 0xFF2A6575;
//            bg.m_BaseColor = 0xFF906010;
        }
/*
        {//!!test
            bg.m_FragmentAssembly_Normal = new AGALMiniAssembler();
            bg.m_FragmentAssembly_Normal.assemble(Context3DProgramType.FRAGMENT, GameObject.FRAGMENT_SHADER_LASER);
            bg.m_ProgramPair_Normal    = in_Context3D.createProgram();
            bg.m_ProgramPair_Normal.upload(bg.m_VertexAssembly.agalcode, bg.m_FragmentAssembly_Normal.agalcode);
        }
//*/
        //Physics
        {
            CreateTerrainCollision(in_Map, bg);
        }

        return bg;
    }

    //Create : Collision
    static public function CreateTerrainCollision(in_Map:Array, bg:Terrain):void{
        var x:int;
        var y:int;
        var iter_x:int;
        var iter_y:int;

        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //Alias
        const W:int = ActGameEngine.W;
        const O:int = ActGameEngine.O;
        const PANEL_W:int = ActGameEngine.PANEL_W;

        var CopyMap:Array;
        {
            CopyMap = new Array(NumY);

            for(y = 0; y < NumY; y += 1){
                CopyMap[y] = new Array(NumX);

                for(x = 0; x < NumX; x += 1){
                    var m:int = in_Map[y][x];
//                    switch(m){
//                    case ActGameEngine.X:
//                        m = W;
//                        break;
//                    }
                    CopyMap[y][x] = m;
                }
            }
        }

        //左右に一列になってるブロックを探して連結
        //さらに、それらの下もブロックだったら連結
        for(y = 0; y < NumY; y += 1){

            var lx:int = -1;
            var rx:int = -1;

            for(x = -1; x < NumX+1; x += 1){

                //範囲外は空白とみなす
                var map:int;
                {
                    if(x < 0){map = O;}
                    else
                    if(x >= NumX){map = O;}
                    else
                    {map = CopyMap[y][x];}
                }

                //必要な処理をしつつ、ブロックの生成が必要になったらフラグを立てて伝達
                var CreateBlockFlag:Boolean = true;
                {
                    switch(map){
                    case ActGameEngine.W:
                        {
                            if(lx < 0){lx = x;}
                            rx = x;
                        }

                        //このブロックの上も元々ブロックであれば、横に長くせず、縦に長くする
                        {
                            //上がブロックじゃない時だけフラグを戻す。そうでなければ、下のブロック生成に移行する
                            if(y == 0){CreateBlockFlag = false;}//マップの上辺なら上がブロックなわけはない
                            else
                            if(in_Map[y-1][x] != W){CreateBlockFlag = false;}//一つ上がブロックでなければすぐには生成しない
                        }

                        break;
                    }
                }

                //必要ならブロックを生成
                {
                    if(CreateBlockFlag)
                    {
                        //左右に連結してるのがあれば、下方向を連結した後、採用
                        if(lx >= 0)
                        {//yの段のlx～rxが連結されている
                            //lx～rx, uy～dyを一つのブロックとみなす

                            //uyとdyを求める

                            var uy:int;
                            {
                                uy = y;//今の行が上辺
                            }

                            var dy:int;
                            {
                                var break_flag:Boolean = false;
                                for(dy = uy+1; dy < NumY; dy += 1){
                                    for(iter_x = lx; iter_x <= rx; iter_x += 1){
                                        if(CopyMap[dy][iter_x] != W){
                                            break_flag = true;
                                        }

                                        if(break_flag){break;}
                                    }
                                    if(break_flag){break;}
                                }
                                dy -= 1;
                            }

                            //ブロックを実際に生成
                            {
                                bg.CreateCollision_Box_Fix(lx * PANEL_W, uy * PANEL_W, (rx-lx+1) * PANEL_W, (dy-uy+1) * PANEL_W);
//                                var block:Block_Fix = new Block_Fix();
//                                block.Init(lx, rx, uy, dy);
                            }

                            //CopyMap上から、該当ブロックを消す
                            {
                                for(iter_y = uy; iter_y <= dy; iter_y += 1){
                                    for(iter_x = lx; iter_x <= rx; iter_x += 1){
                                        CopyMap[iter_y][iter_x] = O;
                                    }
                                }
                            }

                            //reset
                            {
                                lx = rx = -1;
                            }
                        }//lx >= 0
                    }//CreateBlockFlag
                }//Scope : Create Block
            }//loop x
        }//loop y
    }


    //==Function==

    //Init
    public function Terrain(in_Context3D:Context3D){
        super(in_Context3D);
    }
}


//GameObject : Block
class Block extends GameObject
{
    //==Var==

    public var m_PanelArr:Vector.<Panel> = new Vector.<Panel>();


    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D, in_Param:*, in_Append:*):Vector.<Block>{
        var result:Vector.<Block> = new Vector.<Block>();

        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //Temp
        var xx:int;
        var yy:int;
        var i:int;

        //擬似定数
        {
            if(in_Param == null || in_Param.impulse_pow == null){
                IMPULSE_POW = 0.05;//default
            }else{
                IMPULSE_POW = in_Param.impulse_pow;
            }
        }

        //m_Mapの内容をコピーして、連結したものは消せるようにしておく
        var CopyMap:Vector.<Vector.<int> >;
        {
            CopyMap = new Vector.<Vector.<int> >(NumY);

            for(yy = 0; yy < NumY; yy += 1){
                CopyMap[yy] = new Vector.<int>(NumX);

                for(xx = 0; xx < NumX; xx += 1){
                    CopyMap[yy][xx] = in_Map[yy][xx];
                }
            }
        }

        //連結ブロック
        const BLOCK_TYPE_ARR:Vector.<int> = new <int>[
            ActGameEngine.A,
            ActGameEngine.B,
            ActGameEngine.E,
            ActGameEngine.F,
            ActGameEngine.Q,
            ActGameEngine.R,
            ActGameEngine.I,
            ActGameEngine.J,
            ActGameEngine.U,
            ActGameEngine.V,
        ];
        for(i = 0; i < BLOCK_TYPE_ARR.length; ++i)
        {
            var link_info:Vector.<Point> = new Vector.<Point>();

            const MAP_W_MAX:int = 100;
            const MAP_H_MAX:int = 100;

            var link_lx:int = MAP_W_MAX;
            var link_rx:int = 0;
            var link_uy:int = MAP_H_MAX;
            var link_dy:int = 0;

            const gather_link_block:Function = function(in_X:int, in_Y:int):void{
                //Check
                {//L以外は飛ばす
                    if(CopyMap[in_Y][in_X] != BLOCK_TYPE_ARR[i]){
                        return;
                    }
                }

                //Lがあったので、これと連結しているLを全て集めて連結ブロックを生成

                //まずは自分を追加
                {
                    link_info.push(new Point(in_X, in_Y));
                }

                //ここは確認したので消す
                {
                    CopyMap[in_Y][in_X] = ActGameEngine.O;
                }

                //Lのある範囲を求める
                {
                    if(in_X < link_lx){link_lx = in_X;}
                    if(link_rx < in_X){link_rx = in_X;}
                    if(in_Y < link_uy){link_uy = in_Y;}
                    if(link_dy < in_Y){link_dy = in_Y;}
                }

                //上下左右について確認
                {
                    if(in_Y > 0){gather_link_block(in_X, in_Y-1);}
                    if(in_Y < NumY-1){gather_link_block(in_X, in_Y+1);}
                    if(in_X > 0){gather_link_block(in_X-1, in_Y);}
                    if(in_X < NumX-1){gather_link_block(in_X+1, in_Y);}
                }
            };

            for(yy = 0; yy < NumY; ++yy){
                for(xx = 0; xx < NumX; ++xx){
                    //
                    gather_link_block(xx, yy);

                    //
                    if(0 < link_info.length){
                        //Create
                        {
                            var block:Block = Create_One(in_Context3D, BLOCK_TYPE_ARR[i], link_info, link_lx, link_rx, link_uy, link_dy, in_PhysWorld, in_Param);

                            result.push(block);
                        }

                        //Reset
                        {
                            link_info = new Vector.<Point>();

                            link_lx = MAP_W_MAX;
                            link_rx = 0;
                            link_uy = MAP_H_MAX;
                            link_dy = 0;
                        }
                    }
                }
            }
        }

        //同期ブロック
        {//離れていても連結して良いので、そのまま渡す
            link_info = new Vector.<Point>();

            link_lx = MAP_W_MAX;
            link_rx = 0;
            link_uy = MAP_H_MAX;
            link_dy = 0;

            for(yy = 0; yy < NumY; ++yy){
                for(xx = 0; xx < NumX; ++xx){
                    if(CopyMap[yy][xx] != ActGameEngine.S){
                        continue;
                    }

                    //まずは自分を追加
                    {
                        link_info.push(new Point(xx, yy));
                    }

                    //ここは確認したので消す
                    {
                        CopyMap[yy][xx] = ActGameEngine.O;
                    }

                    //Lのある範囲を求める
                    {
                        if(xx < link_lx){link_lx = xx;}
                        if(link_rx < xx){link_rx = xx;}
                        if(yy < link_uy){link_uy = yy;}
                        if(link_dy < yy){link_dy = yy;}
                    }
                }
            }

            if(0 < link_info.length){
                result.push(Create_One(in_Context3D, ActGameEngine.S, link_info, link_lx, link_rx, link_uy, link_dy, in_PhysWorld, in_Param));
            }
        }

        //追加型ギミック
        if(in_Append != null)
        {
            var append_num:int = in_Append.length;
            for(i = 0; i < append_num; ++i){
                var append_map:Object = in_Append[i];

                switch(append_map.gimmick){
                case ActGameEngine.GIMMICK_SEESAW:
                    result.push(Create_Seesaw(in_PhysWorld, in_Context3D, in_Param, append_map.x, append_map.y, append_map.w, append_map.h, append_map.ang));
                    break;
                }
            }
        }

        return result;
    }

    //Create : Solo
    static public function Create_One(in_Context3D:Context3D, in_BlockType:int, in_PointList:Vector.<Point>, in_LX:int, in_RX:int, in_UY:int, in_DY:int, in_PhysWorld:b2World, in_Param:*):Block{
        const PANEL_W:int = ActGameEngine.PANEL_W;

        var Num:int = in_PointList.length;
        var NumX:int = in_RX - in_LX + 1;
        var NumY:int = in_DY - in_UY + 1;
        var i:int;
        var xx:int;
        var yy:int;

        var OffsetX:int = -in_LX * PANEL_W;
        var OffsetY:int = -in_UY * PANEL_W;


        var block:Block = new Block(in_Context3D);

        //CopyMap
        var CopyMap:Array;
        {
            //Init
            {
                CopyMap = new Array(NumY);
                for(yy = 0; yy < NumY; yy++){
                    CopyMap[yy] = new Array(NumX);
                    for(xx = 0; xx < NumX; xx++){
                        CopyMap[yy][xx] = ActGameEngine.O;
                    }
                }
            }

            //Set
            {
                for(i = 0; i < Num; i++){
                    var point:Point = in_PointList[i];

                    xx = point.x - in_LX;
                    yy = point.y - in_UY;

                    CopyMap[yy][xx] = in_BlockType;
                }
            }
        }


        //まずはコリジョンのRectangleのリストを求める
        var col_rect_list:Vector.<Rectangle> = new Vector.<Rectangle>();
        {//横方向に並んでるものはまとめて、さらに縦も同じ位置・同じ幅であればまとめる

            //まとめるための関数
            const clustering:Function = function(in_LX:int, in_RX:int, in_Y:int):void{
                //今回の分の範囲
                var rect:Rectangle = new Rectangle(in_LX, in_Y, in_RX-in_LX+1, 1);

                //すでに求めた範囲のやつと一体化できるなら一体化する
                var col_num:int = col_rect_list.length;
                for(i = 0; i < col_num; i++){
                    //検証対象
                    var trg_rect:Rectangle = col_rect_list[i];

                    //一体化できるか
                    var union_flag:Boolean = true;
                    {
                        //幅が違えば一体化しない
                        if(trg_rect.x != rect.x || trg_rect.width != rect.width){
                            union_flag = false;
                        }

                        //自分の一つ上でなければ一体化しない
                        {
                            var trg_next_y:int = trg_rect.y + trg_rect.height;
                            if(trg_next_y != in_Y){
                                union_flag = false;
                            }
                        }
                    }

                    //一体化
                    if(union_flag){
                        trg_rect.height += 1;//下にくっつけたことにすればOKのはず

                        return;//一体化したので新規登録はせずに終了
                    }
                }

                //一体化できるものがなければ、新規登録
                col_rect_list.push(rect);
            }

            //まとめ中かそうでないかのフラグ
            var NowClustering:Boolean = false;

            //イテレーション開始
            var lx:int, rx:int;
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    var IsBlock:Boolean = (CopyMap[yy][xx] == in_BlockType);

                    if(! NowClustering){//Lをまだ見つけていない
                        if(! IsBlock){//今回のもLじゃない
                            //何もせず次へ進む
                        }else{//Lを見つけた
                            //クラスタリング開始
                            NowClustering = true;
                            //左端はここ
                            lx = xx;
                            //右端もここ
                            rx = xx;
                        }
                    }else{//Lをすでに見つけていて、それを連結中
                        if(IsBlock){//今回のもLだった
                            //右端を伸ばす
                            rx = xx;
                        }else{//Lが途切れた
                            //前回位置までをクラスタリング
                            clustering(lx, rx, yy);
                            //クラスタリング終了
                            NowClustering = false;
                        }
                    }
                }

                if(NowClustering){//右端までLだった
                    //まとめる
                    rx = xx-1;
                    clustering(lx, rx, yy);
                    //クラスタリング終了
                    NowClustering = false;
                }
            }
        }

        //原点の調整をしつつ実際にコリジョンを生成
//        var block:Block = new Block();
        {
            //Create
            {
                block.x = -OffsetX;
                block.y = -OffsetY;
                block.m_PhysWorld = in_PhysWorld;
                block.m_MapVal = in_BlockType;
                block.ReadyBody();
            }

            //Add Shape
            {
                var shapeDef:b2PolygonDef = new b2PolygonDef();
                //- default
                shapeDef.density = 1.0;
                shapeDef.friction = 0;//0.1;//0.3;
//                shapeDef.restitution = ColParam.restitution;
                shapeDef.filter.categoryBits = BLOCK_BITS;
                shapeDef.filter.maskBits = BLOCK_MASKBITS;
                var block_a_density:Number = shapeDef.density;
                var block_b_density:Number = shapeDef.density;
                var block_e_density:Number = shapeDef.density;
                var block_f_density:Number = shapeDef.density;
                var block_s_density:Number = shapeDef.density;
                if(in_Param != null){
                    if(in_Param.hasOwnProperty("block_a_density")){
                        block_a_density = in_Param.block_a_density;
                    }
                    if(in_Param.hasOwnProperty("block_b_density")){
                        block_b_density = in_Param.block_b_density;
                    }
                    if(in_Param.hasOwnProperty("block_e_density")){
                        block_e_density = in_Param.block_e_density;
                    }
                    if(in_Param.hasOwnProperty("block_f_density")){
                        block_f_density = in_Param.block_f_density;
                    }
                    if(in_Param.hasOwnProperty("block_s_density")){
                        block_s_density = in_Param.block_s_density;
                    }
                }
                //- Append
                switch(in_BlockType){
                case ActGameEngine.A:
                    shapeDef.density = block_a_density;
                    break;
                case ActGameEngine.B:
                    shapeDef.density = block_b_density;
                    break;
                case ActGameEngine.E:
                    shapeDef.density = block_e_density;
                    break;
                case ActGameEngine.F:
                    shapeDef.density = block_f_density;
                    break;
                case ActGameEngine.S:
                    shapeDef.density = block_s_density;
                    break;
                case ActGameEngine.Q:
                case ActGameEngine.R:
                    shapeDef.density = 0;//fix
                    shapeDef.restitution = 1;//大きめに弾いてみる
                    break;
                case ActGameEngine.I:
                case ActGameEngine.J:
                    shapeDef.density = 0;//fix
                    shapeDef.restitution = 0.8;//大きめに弾いてみる
                    break;
                case ActGameEngine.U:
                case ActGameEngine.V:
                    shapeDef.density = 100;//Heavy
                    shapeDef.friction = 10;//摩擦によって移動もしにくくしてみる
                    break;
                }
                

                var center:b2Vec2 = new b2Vec2();

                var col_num:int = col_rect_list.length;
                for(i = 0; i < col_num; i++){
                    var rect:Rectangle = col_rect_list[i];

                    //W
                    var w:Number = (rect.width/2 * PANEL_W - 0.01) / ActGameEngine.PHYS_SCALE;
                    var h:Number = (rect.height/2 * PANEL_W - 0.01) / ActGameEngine.PHYS_SCALE;

                    //center
                    center.x = (PANEL_W * (in_LX + (rect.left + rect.right)/2) + OffsetX) / ActGameEngine.PHYS_SCALE;
                    center.y = (PANEL_W * (in_UY + (rect.top + rect.bottom)/2) + OffsetY) / ActGameEngine.PHYS_SCALE;

/*
                    shapeDef.SetAsOrientedBox(w, h, center);
/*/
                    {//八角形
                        var d:Number = 4.0 / ActGameEngine.PHYS_SCALE;//削り取る角の辺の長さ

                        shapeDef.vertexCount = 8;
                        //時計回りに頂点を設定
                        shapeDef.vertices[0].Set(center.x + w-d, center.y - h);//北北東
                        shapeDef.vertices[1].Set(center.x + w,   center.y - h+d);//東北東
                        shapeDef.vertices[2].Set(center.x + w,   center.y + h-d);//東南東
                        shapeDef.vertices[3].Set(center.x + w-d, center.y + h);//南南東
                        shapeDef.vertices[4].Set(center.x - w+d, center.y + h);//南南西
                        shapeDef.vertices[5].Set(center.x - w,   center.y + h-d);//西南西
                        shapeDef.vertices[6].Set(center.x - w,   center.y - h+d);//西北西
                        shapeDef.vertices[7].Set(center.x - w+d, center.y - h  );//北北西
                    }
//*/

                    block.m_PhysBody.CreateShape(shapeDef);

                    const panel_w_offset:int = 4;//両脇が壁の場合も微妙に隙間があいてレーザーが入れるので、それを塞ぐために少し大きくしてみる
                    block.m_PanelArr.push(new Panel(
                        PANEL_W * (in_LX + (rect.left + rect.right)/2) + OffsetX,
                        PANEL_W * (in_UY + (rect.top + rect.bottom)/2) + OffsetY,
                        rect.width * PANEL_W + panel_w_offset,
                        rect.height * PANEL_W + panel_w_offset
                    ));
                }

                if(0 < shapeDef.density){
                    block.m_PhysBody.SetMassFromShapes();
                }
            }
        }

        //画像
        {
//            var bmp:Bitmap = ImageManager.CreateBlockGraphic(CopyMap);
//            block.addChild(bmp);
            block.m_BitmapData = ImageManager.CreateBlockGraphic(CopyMap);
            block.SetSize(NumX * PANEL_W, NumY * PANEL_W);
            block.Reset3D();

            block.m_BitmapData_Additional = ImageManager.CreateBlockGraphic_Additional(CopyMap);
            block.m_Texture_Additional = in_Context3D.createTexture(block.m_BitmapData_Additional.width, block.m_BitmapData_Additional.height, Context3DTextureFormat.BGRA, false);
            block.m_Texture_Additional.uploadFromBitmapData(block.m_BitmapData_Additional);

            switch(in_BlockType){
            case ActGameEngine.A:
            case ActGameEngine.B:
                block.m_BaseColor = 0xFFD46252;
                block.m_BaseColor_Additional = 0xFFD54631;
                break;
            case ActGameEngine.E:
            case ActGameEngine.F:
                block.m_BaseColor = 0xFF4B69DB;
                block.m_BaseColor_Additional = 0xFF3157D5;
                break;
            case ActGameEngine.S:
                block.m_BaseColor = 0xFFD4CF52;//9DA434;
                block.m_BaseColor_Additional = 0xFFB4AF35;//FFFF00;
                break;
            case ActGameEngine.Q:
            case ActGameEngine.R:
                block.m_BaseColor = 0xFF68D26A;//427E34;
                block.m_BaseColor_Additional = 0xFF329835;
                break;
            case ActGameEngine.I:
            case ActGameEngine.J:
                block.m_BaseColor = 0xFF345E7E;
                block.m_BaseColor_Additional = 0xFF26455E;
                break;
            case ActGameEngine.U:
            case ActGameEngine.V:
                block.m_BaseColor = 0xFF7E5C34;
                block.m_BaseColor_Additional = 0xFF6F4C00;
                break;
            }
        }

        return block;
    }

    //Create : Seesaw
    static public function Create_Seesaw(in_PhysWorld:b2World, in_Context3D:Context3D, in_Param:*, in_CenterX:Number, in_CenterY:Number, in_W:int, in_H:int, in_Ang:Number):Block{
        const PANEL_W:int = ActGameEngine.PANEL_W;

        var x:Number = in_CenterX * PANEL_W;
        var y:Number = in_CenterY * PANEL_W;
        var w:Number = in_W * PANEL_W;
        var h:Number = in_H * PANEL_W;
        var ang:Number = in_Ang;

        var NumX:int = in_W;
        var NumY:int = in_H;

        var CopyMap:Array;
        {
            var xx:int;
            var yy:int;

            CopyMap = new Array(NumY);
            for(yy = 0; yy < NumY; yy++){
                CopyMap[yy] = new Array(NumX);
                for(xx = 0; xx < NumX; xx++){
                    CopyMap[yy][xx] = ActGameEngine.Z;
                }
            }
        }

        var block:Block = new Block(in_Context3D);
        {
            //Create
            {
                block.x = x - w/2;
                block.y = y - h/2;
                block.m_PhysWorld = in_PhysWorld;
                block.m_MapVal = ActGameEngine.Z;
                block.ReadyBody();
            }

            //Add Shape
            {
                var shapeDef:b2PolygonDef = new b2PolygonDef();
                //- default
                shapeDef.density = 1.0;
                shapeDef.friction = 0;//0.1;//0.3;
//                shapeDef.restitution = ColParam.restitution;
                shapeDef.filter.categoryBits = SEESAW_BITS;
                shapeDef.filter.maskBits = SEESAW_MASKBITS;
                if(in_Param != null){
                    if(in_Param.hasOwnProperty("block_z_density")){
                        shapeDef.density = in_Param.block_z_density;
                    }
                }

                var col_w:Number = w/2 / ActGameEngine.PHYS_SCALE;
                var col_h:Number = h/2 / ActGameEngine.PHYS_SCALE;
                var center:b2Vec2 = new b2Vec2(
                    col_w,//x / ActGameEngine.PHYS_SCALE,
                    col_h//y / ActGameEngine.PHYS_SCALE
                );
                shapeDef.SetAsOrientedBox(col_w, col_h, center);
//                shapeDef.SetAsBox(w/2 / ActGameEngine.PHYS_SCALE, h/2 / ActGameEngine.PHYS_SCALE);
                block.m_PhysBody.CreateShape(shapeDef);
//                block.m_PhysBody.SetXForm(center, ang * Math.PI/180);

                const panel_w_offset:int = 4;//両脇が壁の場合も微妙に隙間があいてレーザーが入れるので、それを塞ぐために少し大きくしてみる
                block.m_PanelArr.push(new Panel(
                    (w + panel_w_offset)/2,
                    (h + panel_w_offset)/2,
                    w + panel_w_offset,
                    h + panel_w_offset
                ));

                if(0 < shapeDef.density){
                    block.m_PhysBody.SetMassFromShapes();
                }

                //Joint
                {
                    var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
                    jointDef.Initialize(ActGameEngine.Instance.m_Terrain.m_PhysBody, block.m_PhysBody, block.m_PhysBody.GetWorldCenter());

                    var frontJoint:b2RevoluteJoint = b2RevoluteJoint(in_PhysWorld.CreateJoint(jointDef));
                }
            }
        }

        //画像
        {
//            var bmp:Bitmap = ImageManager.CreateBlockGraphic(CopyMap);
//            bmp.x -= bmp.width/2;
//            bmp.y -= bmp.height/2;
//            block.addChild(bmp);
            block.m_BitmapData = ImageManager.CreateBlockGraphic(CopyMap);
            block.SetSize(NumX * PANEL_W, NumY * PANEL_W);
            block.SetOffset(-NumX * PANEL_W/2, -NumY * PANEL_W/2);
            block.Reset3D();

            block.m_BitmapData_Additional = ImageManager.CreateBlockGraphic_Additional(CopyMap);
            block.m_Texture_Additional = in_Context3D.createTexture(block.m_BitmapData_Additional.width, block.m_BitmapData_Additional.height, Context3DTextureFormat.BGRA, false);
            block.m_Texture_Additional.uploadFromBitmapData(block.m_BitmapData_Additional);

            block.m_BaseColor = 0xFFA1A0B0;//0xFF8573AE;//0xFF9C81A8;
            block.m_BaseColor_Additional = 0xFFB0AAA0;//0xFF8D6783;
        }

        return block;
    }


    //==Function==

    //Init
    public function Block(in_Context3D:Context3D){
        super(in_Context3D);
    }

    //Param for Draw
//    override public function GetLX():Number{
//        return this.x + m_OffsetX;
//    }
//    override public function GetUY():Number{
//        return this.y + m_OffsetY;
//    }
    public var m_W:Number = 1;
    public var m_H:Number = 1;
    public function SetSize(in_W:Number, in_H:Number):void{
        m_W = in_W;
        m_H = in_H;
    }
    override public function GetW():Number{
        return m_W;
    }
    override public function GetH():Number{
        return m_H;
    }
}
class Panel
{
    public var rel_center_x:Number;
    public var rel_center_y:Number;
    public var w:Number;
    public var h:Number;

    public function Panel(in_RelCenterX:Number, in_RelCenterY:Number, in_W:Number, in_H:Number){
        rel_center_x = in_RelCenterX;
        rel_center_y = in_RelCenterY;
        w = in_W;
        h = in_H;
    }
}

/*
//GameObject : Needle
class Needle extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World):Vector.<Needle>{
        var result:Vector.<Needle> = new Vector.<Needle>();

        //
        var num_x:int = in_Map[0].length;
        var num_y:int = in_Map.length;
        for(var yy:int = 0; yy < num_y; ++yy){
            for(var xx:int = 0; xx < num_x; ++xx){
                if(in_Map[yy][xx] == ActGameEngine.X){
                    var obj:Needle = new Needle(xx, yy, in_PhysWorld);
                    result.push(obj);
                }
            }
        }

        return result;
    }

    //==Function==

    //Init
    public function Needle(in_IndexX:int, in_IndexY:int, in_PhysWorld:b2World){
        //Alias
        const PANEL_W:int = ActGameEngine.PANEL_W;

        //Param
        {
            m_PhysWorld = in_PhysWorld;

            this.x = in_IndexX * PANEL_W;
            this.y = in_IndexY * PANEL_W;
        }

        //Collision
        {
            CreateSensor_Box(-PANEL_W/16, -PANEL_W/16, PANEL_W*18/16, PANEL_W*18/16);
        }

        //No Graphic
    }

    //Contact :
    override public function OnContact(in_Obj:GameObject, in_Nrm:Vector3D):void{
        //Check
        if(! (in_Obj is Player)){
            return;
        }

        //
        const DamageVal:int = 1;
        in_Obj.OnDamage(DamageVal);
    }
}
//*/

//GameObject : Player
class Player extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D):Player{
        var player:Player = new Player(in_Context3D);

        //Set Param
        {
            player.m_PhysWorld = in_PhysWorld;
            player.m_UseSleep = false;

            var num_x:int = in_Map[0].length;
            var num_y:int = in_Map.length;
            for(var yy:int = 0; yy < num_y; ++yy){
                for(var xx:int = 0; xx < num_x; ++xx){
                    if(in_Map[yy][xx] == ActGameEngine.P){
                        player.x = (xx + 0.5) * ActGameEngine.PANEL_W;
                        player.y = (yy + 0.5) * ActGameEngine.PANEL_W;
                    }
                }
            }
        }

        //Init
        {
            player.Init();
        }

        return player;
    }


    //==Const==

    //レーザーの１秒あたりの移動ドット数
    //- DeltaTimeぶんの移動がPANEL_Wを越えると解除のタイミングが測りづらいかも
    static public const LASER_VEL:Number = 20 * 30;


    //==Var==


    //表示画像
    public var m_Bitmap:Bitmap = new Bitmap();

    //レーザー化まわり
    //- 進行方向
    public var m_LaserMoveRatioX:Number = 0;
    public var m_LaserMoveRatioY:Number = 0;
    //- 進むドット数（端数を持ち越すためにメンバ化）
    public var m_LaserRestMove:Number = 0;

    //レーザー描画用
    public var m_Shape_Laser:Shape;
    public var m_Graphics_Laser:Graphics;
    public var m_LastPoint:Point = new Point(-999, -999);
    //3D
    public var m_BitmapData_Laser_Done:BitmapData;
    public var m_BitmapData_Laser:BitmapData;
    public var m_Texture_Laser:Texture;

    //衝突の応急処置的な感じの処理用（つまりあまりいけてない処理）
    public var m_PrevHit:Boolean = false;
    public var m_LastRatioX:Number = 0;
    public var m_LastRatioY:Number = 0;

    //Flag
    public var m_IsLaser:Boolean = false;
    public var m_IsLaser_Input:Boolean = false;



    //==Function==

    //Init
    public function Player(in_Context3D:Context3D){
        super(in_Context3D);
    }

    //Init
    public function Init():void{
        //グラフィック
        {
            //!!Test
            {
                var bmd:BitmapData = ImageManager.CreatePlayerGraphic();

                m_Bitmap.bitmapData = bmd;
            }

            //表示画像の登録
            {
                m_Bitmap.x = -32/2;
                m_Bitmap.y = -32/2;
                addChild(m_Bitmap);
            }
        }
        {//Laser
            const Blur:Number = ActGameEngine.PANEL_W/2;

            m_Shape_Laser = new Shape();
            if(ActGameEngine.IsClear(ActGameEngine.Instance.m_MapIndex)){
                m_Shape_Laser.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_CLEAR, 1.0, Blur,Blur)];
            }else{
                m_Shape_Laser.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_NORMAL, 1.0, Blur,Blur)];
            }
            m_Shape_Laser.blendMode = BlendMode.LIGHTEN;

            m_Graphics_Laser = m_Shape_Laser.graphics;
        }
        //3D
        {
            m_BitmapData = bmd;
            Reset3D();
        }
        {//Normal
            m_FragmentAssembly_Normal = new AGALMiniAssembler();
            m_FragmentAssembly_Normal.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_LASER);
            m_ProgramPair_Normal    = m_Context3D.createProgram();
            m_ProgramPair_Normal.upload(m_VertexAssembly.agalcode, m_FragmentAssembly_Normal.agalcode);
        }
        {//Laser
            const w:int = Util.RoundUpPower2(ActGameEngine.GAME_W);
            const h:int = Util.RoundUpPower2(ActGameEngine.GAME_H);
            m_BitmapData_Laser_Done = new BitmapData(w, h, true, 0x00000000);
            m_BitmapData_Laser = new BitmapData(w, h, true, 0x00000000);
            m_Texture_Laser = m_Context3D.createTexture(w, h, Context3DTextureFormat.BGRA, false);
            m_Texture_Laser.uploadFromBitmapData(m_BitmapData_Laser);
        }

        //コリジョン
        {
            CreateCollision_Ball_Dynamic(32/2);
        }
    }

    override public function Draw(in_Context3D:Context3D, in_IsLaser:Boolean, in_SclX:Number, in_SclY:Number, in_LX:Number, in_UY:Number):void{
        const GAME_W:int = ActGameEngine.GAME_W;
        const GAME_H:int = ActGameEngine.GAME_H;

        if(! in_IsLaser){
            super.Draw(in_Context3D, in_IsLaser, in_SclX, in_SclY, in_LX, in_UY);
            return;
        }

        //独自レーザー描画

        //テクスチャに反映
//        m_BitmapData_Laser.draw(m_Shape_Laser);
        m_Texture_Laser.uploadFromBitmapData(m_BitmapData_Laser);

        //ブレンドは加算にする
        in_Context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);

        //テクスチャの設定
        in_Context3D.setTextureAt(0, m_Texture_Laser);

//        //va0 : 座標：Float×3
//        in_Context3D.setVertexBufferAt(0, m_Vertices, 0, Context3DVertexBufferFormat.FLOAT_3);
//        //va1 : UV：Float×２
//        in_Context3D.setVertexBufferAt(1, m_Vertices, 3, Context3DVertexBufferFormat.FLOAT_2);

        //Vertex Param
        //- 初期化
        m_Matrix3D.identity();
/*
        //- スケーリングは地形に合わせる
        var local_scl:Number = 1.0 * m_BitmapData_Laser.height / GAME_H;
        m_Matrix3D.appendScale(in_SclX * local_scl, in_SclY * local_scl, 1);
        //- 位置調整は地形に合わせる
        var game_x:Number = in_LX;
        var game_y:Number = in_UY;
        m_Matrix3D.appendTranslation(-1 + game_x * 2/GAME_W, +1 - game_y * 2/GAME_H, 0);
//*/
//*
        //- スケーリングは地形に合わせる
        var local_scl:Number = 1.0 * m_BitmapData_Laser.height / GAME_H;
        m_Matrix3D.appendScale(in_SclX * local_scl, in_SclY * local_scl, 1);
        //- 位置調整は地形に合わせる
        var game_x:Number = 0;
        var game_y:Number = 0;
//        m_Matrix3D.appendTranslation(-1 + game_x * 2/GAME_W, +1 - game_y * 2/GAME_H, 0);
        m_Matrix3D.appendTranslation(-1 + in_LX + game_x * 2/(GAME_W / (in_SclX/2)), +1 - in_UY - game_y * 2/(GAME_H / (in_SclY/2)), 0);
//*/
        //- セット
        //-- 転置しないと正常に動作しないので注意
        in_Context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m_Matrix3D, true);

        //Fragment Param
        const alpha_threshold:Number = 1.0 * 0x01/0xFF;
        const frag_param0:Vector.<Number> = new <Number>[
            alpha_threshold,
            0.5,//法線計算用
            3,//モノクロ用に(R+G+B)/3するための定数
            0,
        ];
        var player:Player = ActGameEngine.Instance.m_Player;
        const frag_param1:Vector.<Number> = new <Number>[
            //光源位置
            -1 + 2.0*player.x/GAME_W,
            -1 + 2.0*player.x/GAME_W,
            0.501,
            1,
        ];
        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, frag_param0);
        in_Context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, frag_param1);

        //常時表示
        in_Context3D.setDepthTest(true, Context3DCompareMode.ALWAYS);

        //シェーダは専用ので
        //- 今はMonoにLaserが入るようにしている
        in_Context3D.setProgram(m_ProgramPair_Monochrome);

        //描画
        in_Context3D.drawTriangles(m_Indices);
    }

    //Laser : Start
    public function Laser_Start(in_Dir:int):void{
        m_IsLaser_Input = true;

        if(m_IsLaser){
            //すでにレーザー中ならムシ
            return;
        }

        m_IsLaser = true;

        const val:Number = 1 / Math.sqrt(2);
        switch(in_Dir){
        case ActGameEngine.LASER_DIR_DL:
            m_LaserMoveRatioX = -val;
            m_LaserMoveRatioY =  val;
            break;
        case ActGameEngine.LASER_DIR_DR:
            m_LaserMoveRatioX =  val;
            m_LaserMoveRatioY =  val;
            break;
        case ActGameEngine.LASER_DIR_UL:
            m_LaserMoveRatioX = -val;
            m_LaserMoveRatioY = -val;
            break;
        case ActGameEngine.LASER_DIR_UR:
            m_LaserMoveRatioX =  val;
            m_LaserMoveRatioY = -val;
            break;
        }

        m_LaserRestMove = 0;

        m_Bitmap.visible = false;
        if(m_Shape_Laser.parent == null && parent != null){
            parent.addChild(m_Shape_Laser);
        }

        m_LastPoint.x = this.x;
        m_LastPoint.y = this.y;

        ActGameEngine.Instance.OnLaser_Start();
    }

    //Laser : End
    public function Laser_End():void{
        m_IsLaser_Input = false;
    }
    public function OnLaser_End():void{
        m_IsLaser = false;

        m_Bitmap.visible = true;
        m_Graphics_Laser.clear();

        m_BitmapData_Laser_Done.fillRect(m_BitmapData_Laser_Done.rect, 0x00000000);
        m_BitmapData_Laser.fillRect(m_BitmapData_Laser.rect, 0x00000000);

        ActGameEngine.Instance.OnLaser_End();
    }

    //Laser : Check
    public function IsLaser():Boolean{
        return m_IsLaser;
    }

    //Pos
    override public function GetLX():Number{
        return this.x - 32/2;
    }
    override public function GetUY():Number{
        return this.y - 32/2;
    }

    //Update
    override public function Update(in_DeltaTime:Number):void{
        //移動
        Update_Move(in_DeltaTime);
    }

    //Update : Move
    public function Update_Move(in_DeltaTime:Number):void{
        if(! IsLaser()){
            //レーザー化してなければ物理エンジン任せ
            return;
        }

        var hit_info:HitInfo = m_HitInfo;
        var nrm_dot:Number;

        //今回進むドット数
        var move:Number = LASER_VEL * in_DeltaTime;

        //前回の残りと合わせて移動
        m_LaserRestMove += move;

        //途中で衝突した場合、反射からの再計算を行うためis_continueのループを回す
        var is_continue:Boolean = true;
        while(is_continue){
            is_continue = false;

            if(! m_IsLaser_Input){
                //入力上はレーザー化が解除されている場合、周囲にめり込まなそうならここでレーザー化を解除する
                var is_dent:Boolean = false;

                const PANEL_W:int = ActGameEngine.PANEL_W;
                const MASK:int = PANEL_W-1;//PANEL_W = 2^nという前提
                const DENT_OFFSET:int = PANEL_W * 14/32;

                if(! is_dent){
                    OnLaser_End();
                    break;
                }
            }

            var src_x:int = this.x;
            var src_y:int = this.y;
            var gap_x:int = m_LaserRestMove * m_LaserMoveRatioX;
            var gap_y:int = m_LaserRestMove * m_LaserMoveRatioY;
            var dst_x:int = src_x + gap_x;
            var dst_y:int = src_y + gap_y;

            var next_x:int;
            var next_y:int;

            if(Math.abs(gap_y) < Math.abs(gap_x)){
                //Xへの移動量が大きいので、Xに１ドットずつ進めつつYはそれに合わせる
                var offset_x:int = (0 < gap_x)? +1: -1;
                for(var iter_x:int = src_x; iter_x != dst_x; iter_x += offset_x){
                    next_x = iter_x + offset_x;
                    next_y = Util.Lerp(src_y, dst_y, (next_x - src_x) / (dst_x - src_x));

                    hit_info.src_x = this.x;
                    hit_info.src_y = this.y;
                    hit_info.dst_x = next_x;
                    hit_info.dst_y = next_y;
                    //hit_info = HitCheck(next_x, next_y, this.x, this.y);
                    HitCheck();

                    if(hit_info.is_hit){
                        if(m_PrevHit){
                            //２連続でヒットしていたら停止の恐れがあるので逆走にする
                            m_LaserMoveRatioX = -m_LastRatioX;
                            m_LaserMoveRatioY = -m_LastRatioY;
                            is_continue = true;
                            m_LaserRestMove *= 1 - (next_x - src_x) / (dst_x - src_x);
                            break;
                        }

                        //ヒットしたので反射
                        nrm_dot = hit_info.nrm_x * m_LaserMoveRatioX + hit_info.nrm_y * m_LaserMoveRatioY;
                        m_LaserMoveRatioX -= 2 * nrm_dot * hit_info.nrm_x;
                        m_LaserMoveRatioY -= 2 * nrm_dot * hit_info.nrm_y;

                        //再計算
                        is_continue = true;
                        m_LaserRestMove *= 1 - (next_x - src_x) / (dst_x - src_x);

                        m_PrevHit = true;

                        break;
                    }else{
                        //ヒットしなかったので進める
                        this.x = next_x;
                        this.y = next_y;

                        //ヒットしたまま停止する場合があるのでそれを抑止するための逆走用記憶
                        m_PrevHit = false;
                        m_LastRatioX = m_LaserMoveRatioX;
                        m_LastRatioY = m_LaserMoveRatioY;
                    }
                }
            }else{
                //Yへの移動量が大きいので（ｒｙ
                var offset_y:int = (0 < gap_y)? +1: -1;
                for(var iter_y:int = src_y; iter_y != dst_y; iter_y += offset_y){
                    next_y = iter_y + offset_y;
                    next_x = Util.Lerp(src_x, dst_x, (next_y - src_y) / (dst_y - src_y));

                    hit_info.src_x = this.x;
                    hit_info.src_y = this.y;
                    hit_info.dst_x = next_x;
                    hit_info.dst_y = next_y;
                    //hit_info = HitCheck(next_x, next_y, this.x, this.y);
                    HitCheck();

                    if(hit_info.is_hit){
                        if(m_PrevHit){
                            //２連続でヒットしていたら停止の恐れがあるので逆走にする
                            m_LaserMoveRatioX = -m_LastRatioX;
                            m_LaserMoveRatioY = -m_LastRatioY;
                            is_continue = true;
                            m_LaserRestMove *= 1 - (next_y - src_y) / (dst_y - src_y);
                            break;
                        }

                        //ヒットしたので反射
                        nrm_dot = hit_info.nrm_x * m_LaserMoveRatioX + hit_info.nrm_y * m_LaserMoveRatioY;
                        m_LaserMoveRatioX -= 2 * nrm_dot * hit_info.nrm_x;
                        m_LaserMoveRatioY -= 2 * nrm_dot * hit_info.nrm_y;

                        //再計算
                        is_continue = true;
                        m_LaserRestMove *= 1 - (next_y - src_y) / (dst_y - src_y);
                        break;
                    }else{
                        //ヒットしなかったので進める
                        this.x = next_x;
                        this.y = next_y;

                        m_PrevHit = false;
                        m_LastRatioX = m_LaserMoveRatioX;
                        m_LastRatioY = m_LaserMoveRatioY;
                    }
                }
            }
        }

        //今のうちにBox2D側に位置と速度を反映させてみる
        {//Vel
            //PhysVel => GameVel
            var GameVX:Number = LASER_VEL * m_LaserMoveRatioX;
            var GameVY:Number = LASER_VEL * m_LaserMoveRatioY;

            //ミラーブロック内部など、埋まって動けない場合は０にしておく
            if(ActGameEngine.Instance.IsWall(this.x, this.y)){
                GameVX = GameVY = 0;
            }

            //PhysVel
            var PhysVel:b2Vec2 = new b2Vec2(
                GameVX / ActGameEngine.PHYS_SCALE,
                GameVY / ActGameEngine.PHYS_SCALE
            );

            //Apply
            m_PhysBody.SetLinearVelocity(PhysVel);
        }
        {//Pos
            var pos:b2Vec2 = m_PhysBody.GetPosition();
            pos.x = this.x / ActGameEngine.PHYS_SCALE;
            pos.y = this.y / ActGameEngine.PHYS_SCALE;

            m_PhysBody.SetXForm(pos, m_PhysBody.GetAngle());
        }

        //Graphic
        if(m_IsLaser)
        {
            var g:Graphics = m_Graphics_Laser;
            g.clear();
            g.lineStyle(ActGameEngine.PANEL_W/4, 0xEEFFFF,1.0);
            g.moveTo(m_LastPoint.x, m_LastPoint.y);
            g.lineTo(this.x, this.y);
        }
        {
            const POS_ZERO:Point = new Point(0,0);

            m_BitmapData_Laser.copyPixels(m_BitmapData_Laser_Done, m_BitmapData_Laser_Done.rect, POS_ZERO);

            m_BitmapData_Laser.draw(m_Shape_Laser, null, null, BlendMode.LIGHTEN);
        }

        m_LaserRestMove = 0;//とりあえず持ち越しはなしにしてみる
    }

    //HitCheck
    public var m_HitInfo:HitInfo = new HitInfo();
    public function HitCheck():void{
        HitCheck_Update();

        LaserPoint_Update();
    }
    public function HitCheck_Update():void{
        const PANEL_W:int = ActGameEngine.PANEL_W;

        var hit_info:HitInfo = m_HitInfo;

        //BG
        {
            hit_info.block_w = PANEL_W;
            hit_info.block_h = PANEL_W;

            if(ActGameEngine.Instance.IsWall(hit_info.dst_x, hit_info.dst_y)){
/*
                hit_info.block_center_x = (int(hit_info.dst_x / PANEL_W) + 0.5) * PANEL_W;
                hit_info.block_center_y = (int(hit_info.dst_y / PANEL_W) + 0.5) * PANEL_W;
                hit_info.block_angle = 0;

                hit_info.Calc();
/*/
                hit_info.is_hit = true;

                //法線の計算
                hit_info.nrm_x = 0;
                hit_info.nrm_y = 0;
                if(ActGameEngine.Instance.IsWall(hit_info.dst_x, hit_info.src_y)){
                    if(hit_info.src_x < hit_info.dst_x){
                        hit_info.nrm_x = -1;
                    }else{
                        hit_info.nrm_x = +1;
                    }
                }
                if(ActGameEngine.Instance.IsWall(hit_info.src_x, hit_info.dst_y)){
                    if(hit_info.src_y < hit_info.dst_y){
                        hit_info.nrm_y = -1;
                    }else{
                        hit_info.nrm_y = +1;
                    }
                }

                var nrm_len:Number = Math.sqrt(hit_info.nrm_x*hit_info.nrm_x + hit_info.nrm_y*hit_info.nrm_y);
                if(0 < nrm_len){
                    hit_info.nrm_x /= nrm_len;
                    hit_info.nrm_y /= nrm_len;
                }else{
                    //角にぶつかった
                    //- いちいち法線を求めるのが面倒なので、縦反射にする
                    hit_info.nrm_y = 1;
                }
//*/

                return;
            }
        }

        //Block
        {
            var block_arr:Vector.<Block> = ActGameEngine.Instance.m_BlockArr;
            var block_num:int = block_arr.length;

            var block_cand_index:int = -1;
            var panel_cand_index:int = -1;
            var timing_cand:Number = 1.001;
            for(var i:int = 0; i < block_num; ++i){
                var block:Block = block_arr[i];

                var angle:Number = block.rotation * Math.PI/180;
                hit_info.block_angle = angle;

                var cos:Number = Math.cos(-angle);
                var sin:Number = Math.sin(-angle);

                var panel_arr:Vector.<Panel> = block.m_PanelArr;
                var panel_num:int = panel_arr.length;
                for(var j:int = 0; j < panel_num; ++j){
                    var panel:Panel = panel_arr[j];

                    hit_info.block_center_x = block.x + ( panel.rel_center_x * cos + panel.rel_center_y * sin);
                    hit_info.block_center_y = block.y + (-panel.rel_center_x * sin + panel.rel_center_y * cos);
                    hit_info.block_w = panel.w;
                    hit_info.block_h = panel.h;

                    hit_info.Calc();
/*
                    //Debug
                    var bmp:Bitmap = new Bitmap(new BitmapData(hit_info.block_w, hit_info.block_h, false, 0xFF0000));
                    bmp.x = -hit_info.block_w/2;
                    bmp.y = -hit_info.block_h/2;
                    var sprite:Sprite = new Sprite();
                    sprite.x = hit_info.block_center_x;
                    sprite.y = hit_info.block_center_y;
                    sprite.rotation = block.rotation;
                    sprite.addChild(bmp);
                    ActGameEngine.Instance.m_Root_Game.addChild(sprite);
//*/
                    if(hit_info.is_hit){
                        //return;
                        if(hit_info.hit_timing_ratio < timing_cand){
                            timing_cand = hit_info.hit_timing_ratio;
                            block_cand_index = i;
                            panel_cand_index = j;
                        }
                    }
                }
            }

            if(0 <= block_cand_index){
                block = block_arr[block_cand_index];

                angle = block.rotation * Math.PI/180;
                hit_info.block_angle = angle;

                cos = Math.cos(-angle);
                sin = Math.sin(-angle);

                panel = block.m_PanelArr[panel_cand_index];

                hit_info.block_center_x = block.x + ( panel.rel_center_x * cos + panel.rel_center_y * sin);
                hit_info.block_center_y = block.y + (-panel.rel_center_x * sin + panel.rel_center_y * cos);
                hit_info.block_w = panel.w;
                hit_info.block_h = panel.h;

                hit_info.Calc();

                return;
            }
        }

        //No Hit
        hit_info.is_hit = false;
    }

    public function LaserPoint_Update():void{
        const POS_ZERO:Point = new Point(0,0);

        var hit_info:HitInfo = m_HitInfo;

        if(hit_info.is_hit){
            var g:Graphics = m_Graphics_Laser;

            //Graphics
            {
                //Reset
                {
                    g.clear();
                    g.lineStyle(ActGameEngine.PANEL_W/4, 0xEEFFFF,1.0);
                }

                //Line
                {
                    g.moveTo(m_LastPoint.x, m_LastPoint.y);
                    g.lineTo(hit_info.src_x, hit_info.src_y);
                }
            }

            //Trans
            {
                m_BitmapData_Laser_Done.draw(m_Shape_Laser, null, null, BlendMode.LIGHTEN);

                m_BitmapData_Laser.copyPixels(m_BitmapData_Laser_Done, m_BitmapData_Laser_Done.rect, POS_ZERO);
            }

            //Update LastPoint
            {
                m_LastPoint.x = hit_info.src_x;
                m_LastPoint.y = hit_info.src_y;
            }

            //Reset
            {
                g.clear();
            }
        }else{
//            //Trans
//            {
//                m_BitmapData_Laser.copyPixels(m_BitmapData_Laser_Done, m_BitmapData_Laser_Done.rect, POS_ZERO);
//
//                m_BitmapData_Laser.draw(m_Shape_Laser, null, null, BlendMode.LIGHTEN);
//            }
        }

/*
        //いま居るところの可視化
        //- 専用のグラフィックを用意しないと見た目が悪い
        var mtx:Matrix = new Matrix(m_LocalScl,0,0,m_LocalScl, this.x-16, this.y-16);
        const ct:ColorTransform = new ColorTransform(1,1,1,0.2);
        m_BitmapData_Laser.draw(m_BitmapData, mtx, ct);
//*/
    }
}
class HitInfo
{
    //==Var==

    //In
    //- move
    public var src_x:int;
    public var src_y:int;
    public var dst_x:int;
    public var dst_y:int;
    //- block
    public var block_center_x:Number;
    public var block_center_y:Number;
    public var block_w:Number;
    public var block_h:Number;
    public var block_angle:Number;

    //Out
    public var is_hit:Boolean;
    public var hit_timing_ratio:Number;
    public var nrm_x:Number;
    public var nrm_y:Number;


    //==Function==

    public function Calc():void{
        var sin:Number = Math.sin(block_angle);
        var cos:Number = Math.cos(block_angle);
        var neg_sin:Number = Math.sin(-block_angle);
        var neg_cos:Number = Math.cos(-block_angle);

        //ブロックに対する相対位置（Dst）
        var rel_x:Number = (dst_x - block_center_x);
        var rel_y:Number = (dst_y - block_center_y);
        var rel_x_ang:Number =  rel_x * cos + rel_y * sin;
        var rel_y_ang:Number = -rel_x * sin + rel_y * cos;

        if(-block_w/2 <= rel_x_ang && rel_x_ang <= block_w/2 && -block_h/2 <= rel_y_ang && rel_y_ang <= block_h/2){
            //相対位置がブロック内であればヒット
            is_hit = true;

            //法線計算
            {
                //ブロックに対する相対位置（Src）
                var old_rel_x:Number = (src_x - block_center_x);
                var old_rel_y:Number = (src_y - block_center_y);
                var old_rel_x_ang:Number =  old_rel_x * cos + old_rel_y * sin;
                var old_rel_y_ang:Number = -old_rel_x * sin + old_rel_y * cos;

/*
                //ヒット位置を近似
                var hit_rel_ang_x:Number = (rel_x_ang + old_rel_x_ang)/2;
                var hit_rel_ang_y:Number = (rel_y_ang + old_rel_y_ang)/2;

                //どこの辺に当たったか
                var rel_nrm_x:Number = 0;
                var rel_nrm_y:Number = 0;
                if(Math.abs(hit_rel_ang_y) < Math.abs(hit_rel_ang_x)){
                    //横に当たった
                    if(0 < hit_rel_ang_x){
                        rel_nrm_x = +1;
                    }else{
                        rel_nrm_x = -1;
                    }
                }else{
                    //上下に当たった
                    if(0 < hit_rel_ang_y){
                        rel_nrm_y = +1;
                    }else{
                        rel_nrm_y = -1;
                    }
                }
                hit_timing_ratio = 1;
/*/
                //ヒット位置をちゃんと計算
                //- どこの辺に当たったかも一緒に

                hit_timing_ratio = 1;
                var timing_cand:Number;

                var rel_nrm_x:Number = 0;
                var rel_nrm_y:Number = 0;

                if(rel_x_ang != old_rel_x_ang){
                    //- L
                    if(old_rel_x_ang < -block_w/2 && -block_w/2 <= rel_x_ang){
                        timing_cand = (-block_w/2 - old_rel_x_ang) / (rel_x_ang - old_rel_x_ang);
                        if(timing_cand <= hit_timing_ratio){
                            hit_timing_ratio = timing_cand;
                            rel_nrm_x = -1;
                            rel_nrm_y = 0;
                        }
                    }
                    //- R
                    if(block_w/2 < old_rel_x_ang && rel_x_ang <= block_w/2){
                        timing_cand = (old_rel_x_ang - block_w/2) / (old_rel_x_ang - rel_x_ang);
                        if(timing_cand <= hit_timing_ratio){
                            hit_timing_ratio = timing_cand;
                            rel_nrm_x = +1;
                            rel_nrm_y = 0;
                        }
                    }
                }
                if(rel_y_ang != old_rel_y_ang){
                    //- U
                    if(old_rel_y_ang < -block_h/2 && -block_h/2 <= rel_y_ang){
                        timing_cand = (-block_h/2 - old_rel_y_ang) / (rel_y_ang - old_rel_y_ang);
                        if(timing_cand <= hit_timing_ratio){
                            hit_timing_ratio = timing_cand;
                            rel_nrm_x = 0;
                            rel_nrm_y = -1;
                        }
                    }
                    //- D
                    if(block_h/2 < old_rel_y_ang && rel_y_ang <= block_h/2){
                        timing_cand = (old_rel_y_ang - block_h/2) / (old_rel_y_ang - rel_y_ang);
                        if(timing_cand <= hit_timing_ratio){
                            hit_timing_ratio = timing_cand;
                            rel_nrm_x = 0;
                            rel_nrm_y = +1;
                        }
                    }
                }

                var hit_rel_ang_x:Number = Util.Lerp(old_rel_x_ang, rel_x_ang, timing_cand);
                var hit_rel_ang_y:Number = Util.Lerp(old_rel_y_ang, rel_y_ang, timing_cand);
//*/

                //法線計算
                nrm_x =  rel_nrm_x * neg_cos + rel_nrm_y * neg_sin;
                nrm_y = -rel_nrm_x * neg_sin + rel_nrm_y * neg_cos;
            }
        }else{
            //相対位置がブロック外であればノーヒット
            is_hit = false;
        }
    }
}


//GameObject : Goal
class Goal extends GameObject
{
    //==Static==

    //Create
    static public function Create(in_Map:Array, in_PhysWorld:b2World, in_Context3D:Context3D):Goal{
        var goal:Goal = new Goal(in_Context3D);

        //Set Param
        {
            goal.m_PhysWorld = in_PhysWorld;
            goal.m_UseSleep = false;

            var num_x:int = in_Map[0].length;
            var num_y:int = in_Map.length;
            for(var yy:int = 0; yy < num_y; ++yy){
                for(var xx:int = 0; xx < num_x; ++xx){
                    if(in_Map[yy][xx] == ActGameEngine.G){
                        goal.x = xx * ActGameEngine.PANEL_W;
                        goal.y = yy * ActGameEngine.PANEL_W;
                    }
                }
            }
        }

        //Init
        {
            goal.Init();
        }

        return goal;
    }


    //==Var==

    public var m_GoalFlag:Boolean = false;

    public var m_Timer:Number = 0;
    public var m_OriX:Number = 0;
    public var m_OriY:Number = 0;


    //==Function==

    //Init
    public function Goal(in_Context3D:Context3D){
        super(in_Context3D);
    }
    //Init
    public function Init():void{
        //Alias
        const PANEL_W:int = ActGameEngine.PANEL_W;

        //Param
        {
            m_OriX = this.x;
            m_OriY = this.y;
        }

        //Collision
        {
            CreateSensor_Box(PANEL_W*2/16, PANEL_W*2/16, PANEL_W*12/16, PANEL_W*12/16);
        }

        //Graphic
        {
            //this.blendMode = BlendMode.ADD;
            //addChild(ImageManager.CreateGoalGraphic());
            m_BitmapData = ImageManager.CreateGoalGraphic();
            Reset3D();
        }
        {
            m_FragmentAssembly_Normal = new AGALMiniAssembler();
            m_FragmentAssembly_Normal.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_GOAL);
            m_ProgramPair_Normal    = m_Context3D.createProgram();
            m_ProgramPair_Normal.upload(m_VertexAssembly.agalcode, m_FragmentAssembly_Normal.agalcode);
        }
    }

    //Contact :
    override public function OnContact(in_Obj:GameObject, in_Nrm:Vector3D):void{
        //Check
        if(! (in_Obj is Player)){
            return;
        }
        if(m_GoalFlag){
            return;
        }

        //
        m_GoalFlag = true;
    }

    //Update
    override public function Update(in_DeltaTime:Number):void{
        if(! m_GoalFlag){
            //レーザー中もゴールできるようにするため、Updateでもチェックしてみる
            const PANEL_W:int = ActGameEngine.PANEL_W;
            var player:Player = ActGameEngine.Instance.m_Player;

            var gap_x:Number = player.x - (this.x + PANEL_W/2);
            var gap_y:Number = player.y - (this.y + PANEL_W/2);
            var distance:Number = Math.sqrt(gap_x*gap_x + gap_y*gap_y);
            if(distance < PANEL_W*12/16){
                m_GoalFlag = true;
            }
        }else{
            //ゴール後はしばらく演出を入れる
            const VANISH_TIME:Number = 1.0;
            const SCL_MAX:Number = 5.0;

            var ratio:Number = Math.max(m_Timer / VANISH_TIME, 0);
            ratio = Math.sin(Math.PI/2 * ratio);

            m_Timer += in_DeltaTime;
            var scl:Number = Util.Lerp(1, SCL_MAX, ratio);

            var ori_w:Number = m_BitmapData.width;
            var ori_h:Number = m_BitmapData.height;
            var center_x:Number = m_OriX + ori_w/2;
            var center_y:Number = m_OriY + ori_h/2;
            var w:Number = scl * ori_w;
            var h:Number = scl * ori_h;

            this.x = center_x - w/2;
            this.y = center_y - h/2;
            m_LocalScl = scl;

            this.alpha = 1 - ratio;

            if(VANISH_TIME <= m_Timer){
                m_EndFlag = true;
            }
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
//    static public const PLATE_H:int = 64;
    static public var PLATE_H:int = 64;
    //ついでに幅も
//    static public const PLATE_W:int = 400;
    static public var PLATE_W:int = 400;//表示幅に合わせてみる
    //スクロール用のもついでに求める
    static public var CONTENT_GAP_NORMAL        :int = 122;
    static public var CONTENT_GAP_STAGESELECT    :int = 70;



    //==Var==

    //次のポップアップ
    public var m_NextPopup:Popup = null;

    //Flag
    protected var m_EndFlag:Boolean = false;


    //==Function==

    //Init
    public function Popup(){
//        s_AllEndFlag = false;
        PLATE_W = ActGameEngine.VIEW_W * 0.9;
        PLATE_H = PLATE_W * 64/400;
        CONTENT_GAP_NORMAL = PLATE_W * 122/400;
        CONTENT_GAP_STAGESELECT = PLATE_W * 70/400;
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

    //On Back
    public function OnBack():void{
        //Override
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
//    static public var s_NinePatch_Button_Content:NinePatch;
    static public var s_BitmapData_Button_Content:BitmapData = null;
    static public var s_BitmapData_Button_ContentL:BitmapData = null;

    //==Const==

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

        //PerlinNoise
        const PanelLenX:int = 64;//GetTotalW() / 4;
        const PanelLenY:int = 4;//GetTotalW() / 4;
        const Octave:int = 2;//変化は雑でいい
        const stitch:Boolean = true;//端はループできる感じで
        const fractalNoise:Boolean = true;//なめらかな変化で
        const channel:uint = 0x7;//全色
        const grayScale:Boolean = true;//RGBは全て同じ値で

        const base_ratio_min:Number = 0.5;
        const base_ratio_max:Number = 1.0;
        const r_ratio:Number = 1.0 * 0x20/0xFF;
        const r_offset:uint = 0xFF - 0xFF*r_ratio;
        const g_ratio:Number = 1.0 * 0x20/0xFF;
        const g_offset:uint = 0xFF - 0xFF*g_ratio;
        const b_ratio:Number = 1.0 * 0x20/0xFF;
        const b_offset:uint = 0xFF - 0xFF*b_ratio;
        const ct:ColorTransform = new ColorTransform(r_ratio,g_ratio,b_ratio,1,r_offset,g_offset,b_offset,0);

        //Param
        const HeaderH:int = PLATE_H;//ActGameEngine.VIEW_H * 64/465;//64;
        const FooterH:int = 8;

        var CharW:int = ActGameEngine.VIEW_W/16;

        const offset:int = 0;//8;

        const TotalW:int = ActGameEngine.VIEW_W - 2*offset;
        const TotalH:int = ActGameEngine.VIEW_H - 2*offset;// - ActGameEngine.GetAdH();

        var ContentAreaH:int = TotalH - HeaderH - FooterH;

        var mtx:Matrix = new Matrix();

        var is_clear:Boolean = false;
        switch(m_Type){
        case TYPE_PAUSE:
        case TYPE_RESULT:
            is_clear = ActGameEngine.IsClear(ActGameEngine.Instance.m_MapIndex);
            break;
        case TYPE_STAGESELECT:
            //ここではタイトル部分だけ。アイテムは個別
            is_clear = ActGameEngine.IsAllClear();
            break;
        }

        //Layer
        {
            addChild(m_Layer_Root);
            //m_Layer_Root.y = ActGameEngine.GetAdH();

            m_Layer_Root.addChild(m_Layer_BG);

//            m_Layer_Content.x = ActGameEngine.VIEW_W/2;
//            m_Layer_Content.y = 88;
            m_Layer_Content.y = HeaderH + offset;
            m_Layer_Content.scrollRect = new Rectangle(-ActGameEngine.VIEW_W/2, -m_ContentGap/2, ActGameEngine.VIEW_W, ContentAreaH);
            m_Layer_Root.addChild(m_Layer_Content);

            m_Layer_Content.addChild(m_Layer_Scroll);
        }

        //BG
        {
            if(s_BitmapData_BG == null){
                s_BitmapData_BG = new BitmapData(TotalW, TotalH, true, 0x00000000);

                //PerlinNoise
                s_BitmapData_BG.perlinNoise(PanelLenX,PanelLenY, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);
                s_BitmapData_BG.colorTransform(s_BitmapData_BG.rect, ct);

                //Ori Graphic Top
                rad_x = 12;
                rad_y = 12;
                w = TotalW;
                h = HeaderH;
                ori_x = 0;
                ori_y = 128;
                ori_w = 64;
                ori_h = 64;
                s_BitmapData_BG.draw(NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h), mtx, null, BlendMode.MULTIPLY);
                mtx.ty += h;

                //Ori Graphic Else
                rad_x = 12;
                rad_y = 12;
                w = TotalW;
                h = TotalH - HeaderH;
                ori_x = 0;
                ori_y = 192;
                ori_w = 64;
                ori_h = 64;
                s_BitmapData_BG.draw(NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h), mtx, null, BlendMode.MULTIPLY);
                mtx.ty += h;
            }

            var bmp_bg:Bitmap = new Bitmap(s_BitmapData_BG);
            bmp_bg.x = offset;
            bmp_bg.y = offset;
            m_Layer_BG.addChild(bmp_bg);
        }

        //Title
        {
            m_BitmapData_Title = new BitmapData(ActGameEngine.VIEW_W, HeaderH, true, 0x00000000);
            FontText.DrawText(m_BitmapData_Title, in_Title, m_BitmapData_Title.width/2, m_BitmapData_Title.height/2, CharW, 0xFFFFFF, is_clear);
            var bmp_title:Bitmap = new Bitmap(m_BitmapData_Title);
            bmp_title.y = 4;
            m_Layer_Root.addChild(bmp_title);
        }

        //Content
        {
            if(s_BitmapData_Button_Content == null){
                w = PLATE_W - PLATE_H;
                h = PLATE_H;

                s_BitmapData_Button_Content = new BitmapData(w, h, true, 0x00000000);
                //PerlinNoise
                //s_BitmapData_Button_Content.perlinNoise(PanelLenX,PanelLenY, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);
                s_BitmapData_Button_Content.colorTransform(s_BitmapData_Button_Content.rect, ct);

                //Ori Graphic
                rad_x = 12;
                rad_y = 12;
                ori_x = 64;
                ori_y = 128;
                ori_w = 64;
                ori_h = 64;

                var ninepatch_content:NinePatch = NinePatch.Create(bmd_ori, rad_x, rad_y, w, h, ori_x, ori_y, ori_w, ori_h);
                s_BitmapData_Button_Content.draw(ninepatch_content);

                s_BitmapData_Button_ContentL = new BitmapData(PLATE_H, PLATE_H, true, 0x00000000);
                var ninepatch_content_l:NinePatch = NinePatch.Create(bmd_ori, rad_x, rad_y, PLATE_H, PLATE_H, ori_x, ori_y+64, ori_w, ori_h);
                s_BitmapData_Button_ContentL.draw(ninepatch_content_l);
            }

            var item_list:Vector.<String> = in_MesList;
//                new <String>["AA", "BB", "CC"];//!!test

            var num:int = item_list.length;
            m_BitmapData_Content = new Vector.<BitmapData>(num);
            var src_rect:Rectangle = new Rectangle(0,0,PLATE_W,PLATE_H);
            var dst_point:Point = new Point(0,0);
            mtx.scale(PLATE_H/64.0, PLATE_H/64.0);
            var bmd_icon_ori:BitmapData = new BitmapData(PLATE_H, PLATE_H, true, 0x0000000);
            var bmd_icon:BitmapData = new BitmapData(PLATE_H, PLATE_H, true, 0x0000000);
            for(var i:int = 0; i < num; ++i){
                //is_clear
                switch(m_Type){
                case TYPE_STAGESELECT:
                    is_clear = ActGameEngine.IsClear(i);
                    break;
                }

                //Frame
                {
                    bmd = new BitmapData(PLATE_W, PLATE_H, true, 0x00000000);

                    src_rect.x = 0;
                    src_rect.y = 0;
                    src_rect.width = PLATE_W - PLATE_H;
                    dst_point.x = PLATE_H;
                    bmd.copyPixels(s_BitmapData_Button_Content, src_rect, dst_point);

                    src_rect.x = 0;
                    src_rect.y = 0;
                    src_rect.width = PLATE_H;
                    dst_point.x = 0;
                    bmd.copyPixels(s_BitmapData_Button_ContentL, src_rect, dst_point);

                    switch(m_Type){
                    case TYPE_PAUSE:
                    case TYPE_RESULT:
                        if(num == 3){
                            switch(i){
                            case 0: src_rect.x = 128 + 64*0; src_rect.y = 128+64*0; break;
                            case 1: src_rect.x = 128 + 64*1; src_rect.y = 128+64*0; break;
                            case 2: src_rect.x = 128 + 64*1; src_rect.y = 128+64*1; break;
                            }
                        }else{
                            switch(i){
                            case 0: src_rect.x = 128 + 64*1; src_rect.y = 128+64*0; break;
                            case 1: src_rect.x = 128 + 64*1; src_rect.y = 128+64*1; break;
                            }
                        }
                        break;
                    case TYPE_STAGESELECT:
                        src_rect.x = 128 + 64*0; src_rect.y = 128+64*0; break;
                        break;
                    }
                    src_rect.width = 64;
                    dst_point.x = 0;
//                    bmd.copyPixels(bmd_ori, src_rect, dst_point, null, null, true);
                    mtx.tx = -src_rect.x * PLATE_H/64;
                    mtx.ty = -src_rect.y * PLATE_H/64;
                    const icon_rect:Rectangle = new Rectangle(0,0,PLATE_H,PLATE_H);
                    //bmd.draw(bmd_ori, mtx, null, null, icon_rect, true);
                    bmd_icon_ori.copyPixels(bmd_ori, src_rect, dst_point);

                    const POS_ZERO:Point = new Point(0,0);
                    const FILTER:GlowFilter = new GlowFilter(ActGameEngine.LASER_COLOR_NORMAL, 1.0, 6, 6);
                    const FILTER_CLEAR:GlowFilter = new GlowFilter(ActGameEngine.LASER_COLOR_CLEAR, 1.0, 6, 6);
                    if(is_clear){
                        bmd_icon.applyFilter(bmd_icon_ori, bmd_icon_ori.rect, POS_ZERO, FILTER_CLEAR);
                    }else{
                        bmd_icon.applyFilter(bmd_icon_ori, bmd_icon_ori.rect, POS_ZERO, FILTER);
                    }

                    bmd.draw(bmd_icon);

//                    bmd.draw(s_BitmapData_ContentLeftPN, null, null, BlendMode.MULTIPLY);
                }

                switch(m_ContentAlign){
                case FontText.ALIGN_LEFT:
                    FontText.DrawText(bmd, item_list[i], PLATE_H*1.3, bmd.height/2, CharW, 0xFFFFFF, is_clear, m_ContentAlign);
                    break;
                case FontText.ALIGN_CENTER:
                    FontText.DrawText(bmd, item_list[i], bmd.width/2, bmd.height/2, CharW, 0xFFFFFF, is_clear, m_ContentAlign);
                    break;
                case FontText.ALIGN_RIGHT:
                    //No Support
                    break;
                }
                var button_content:Button = new Button(bmd);

                button_content.x = 0;//ActGameEngine.VIEW_W/2;
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

    //On Back
    override public function OnBack():void{
        if(m_Type == TYPE_STAGESELECT){
            m_NextPopup = new Popup_Title();
        }else{
            m_NextPopup = new Popup_StageSelect();
        }
        m_EndFlag = true;
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
        var item_list_fail_jp:Vector.<String> =
            new <String>["もう一度", "ステージ選択"];
        var item_list_fail_en:Vector.<String> =
            new <String>["Replay", "Select Stage"];

        if(in_IsClear){
            return Util.IsJapanese()? item_list_clear_jp: item_list_clear_en;
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
                ActGameEngine.Instance.m_MapIndex++;
                if(ActGameEngine.MAP_ARR.length <= ActGameEngine.Instance.m_MapIndex){
                    ActGameEngine.Instance.m_MapIndex = 0;
                }
                //Reset
                m_NextPopup = new Popup_StageName(ActGameEngine.MAP_ARR[ActGameEngine.Instance.m_MapIndex].name);
                m_EndFlag = true;
                ActGameEngine.Instance.Reset(false);
                break;
            case 1:
                //Reset
                ActGameEngine.Instance.Reset(false);
                //End
                m_EndFlag = true;
                break;
            case 2:
                //Menu
//                ActGameEngine.Instance.Push(new Popup_StageSelect());
                m_NextPopup = new Popup_StageSelect();
                //End
                m_EndFlag = true;
                break;
            }
        }else{
            switch(in_Index){
            case 0:
                //Reset
                ActGameEngine.Instance.Reset(false);
                //End
                m_EndFlag = true;
                break;
            case 1:
                //Menu
//                ActGameEngine.Instance.Push(new Popup_StageSelect());
                m_NextPopup = new Popup_StageSelect();
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

    //On Back
    override public function OnBack():void{
        m_NextPopup = new Popup_StageSelect();
        m_EndFlag = true;
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
            m_NextPopup = new Popup_StageName(ActGameEngine.MAP_ARR[ActGameEngine.Instance.m_MapIndex].name);
            m_EndFlag = true;
            ActGameEngine.Instance.Reset(false);
            break;
        case 2:
            //Menu
//            ActGameEngine.Instance.Push(new Popup_StageSelect());
            m_NextPopup = new Popup_StageSelect();
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

    //On Back
    override public function OnBack():void{
        m_EndFlag = true;
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
        var num:int = ActGameEngine.MAP_ARR.length;

        var item_list:Vector.<String> = new Vector.<String>(num);

        for(var i:int = 0; i < num; ++i){
            item_list[i] = ActGameEngine.MAP_ARR[i].name;
        }

        return item_list;
    }

    //Touch
    override protected function OnSelect(in_Index:int):void{
        //Index
        ActGameEngine.Instance.m_MapIndex = in_Index;
        if(ActGameEngine.MAP_ARR.length <= ActGameEngine.Instance.m_MapIndex){
            ActGameEngine.Instance.m_MapIndex = 0;
        }
        //Reset
        m_NextPopup = new Popup_StageName(ActGameEngine.MAP_ARR[ActGameEngine.Instance.m_MapIndex].name);
        m_EndFlag = true;
        ActGameEngine.Instance.Reset(false);

        m_NextPopup = new Popup_StageName(ActGameEngine.MAP_ARR[ActGameEngine.Instance.m_MapIndex].name);
//        ActGameEngine.Instance.Push(new Popup_StageName(ActGameEngine.MAP_ARR[ActGameEngine.Instance.m_MapIndex].name));


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

    //On Back
    override public function OnBack():void{
        m_NextPopup = new Popup_Title();
        m_EndFlag = true;
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

        var bmd:BitmapData = new BitmapData(ActGameEngine.VIEW_W, ActGameEngine.VIEW_H, false, 0x000000);
        FontText.DrawText(bmd, in_StageName, bmd.width/2, bmd.height/2, 32, 0xFFFFFF, ActGameEngine.IsClear(ActGameEngine.Instance.m_MapIndex));
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

    //フェードイン中か
    public function IsFading():Boolean{
        return (m_Mode == MODE_FADE);
    }
}


//Base : Title
class Popup_Title extends Popup
{
    //==Const==


    //==Var==


    //==Function==

    //Init
    public function Popup_Title(){
        super();

        var BMD_W:int = ActGameEngine.VIEW_W;
        var BMD_H:int = ActGameEngine.VIEW_H;

        var bmd:BitmapData = new BitmapData(BMD_W, BMD_H, false, 0x000000);
        bmd.lock();

        //BG
        {
            //PerlinNoise + ColorTransform
            const PanelLen:int = BMD_W/32;//16;//VIEW_W / 4;
            const Octave:int = 2;//変化は雑でいい
            const stitch:Boolean = true;//端はループできる感じで
            const fractalNoise:Boolean = true;//なめらかな変化で
            const channel:uint = 0x7;//全色
            const grayScale:Boolean = true;//RGBは全て同じ値で

            const base_ratio_min:Number = 0.5;
            const base_ratio_max:Number = 1.0;
            var r_ratio:Number = 0.02;
            var r_offset:uint = 0x14;//0x80;
            var g_ratio:Number = 0.1;
            var g_offset:uint = 0x2C;//0x80;
            var b_ratio:Number = 0.1;
            var b_offset:uint = 0x34;//0x80;
            if(ActGameEngine.IsAllClear()){
                r_ratio    = 0.1;
                r_offset= 0x34;//0x80;
                g_ratio    = 0.1;
                g_offset= 0x2C;//0x80;
                b_ratio    = 0.02;
                b_offset= 0x14;//0x80;
            }

            //PerlinNoise
            bmd.perlinNoise(PanelLen,PanelLen, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);

            for(var yy:int = 0; yy < BMD_H; ++yy){
                var base_ratio:Number = Util.Lerp(base_ratio_min, base_ratio_max, 1.0 * (BMD_H - yy) / BMD_H);
                for(var xx:int = 0; xx < BMD_W; ++xx){
                    var color_ori:uint = bmd.getPixel(xx, yy);
                    var r:uint = (color_ori >> 16) & 0xFF;
                    var g:uint = (color_ori >>  8) & 0xFF;
                    var b:uint = (color_ori >>  0) & 0xFF;

                    r = base_ratio * (r * r_ratio + r_offset);
                    g = base_ratio * (g * g_ratio + g_offset);
                    b = base_ratio * (b * b_ratio + b_offset);

                    bmd.setPixel(xx, yy, (r << 16) | (g << 8) | (b << 0));
                }
            }
        }

        //Text
        {
            var text_format:TextFormat = new TextFormat();
            text_format.size = Math.min(BMD_W, BMD_H) * 35/100;//35/100;
            text_format.letterSpacing = BMD_W * 5/100;;//BMD_W * 10/100;
            text_format.leading = BMD_W * 5/100;//BMD_W * 25/100;//-SIZE/20;//-SIZE/7;
            text_format.color = 0xFFFFFF;
//            text_format.font = "myfont";

            var text_field:TextField = new TextField();
//            text_field.embedFonts = true;
            text_field.autoSize = TextFieldAutoSize.LEFT;
            text_field.defaultTextFormat = text_format;
            text_field.text = "閃光\n乱舞";

            text_field.x = BMD_W*17/32 - text_field.textWidth/2;
            text_field.y = BMD_H/2 - text_field.textHeight/2;

            var text_sprite:Sprite = new Sprite();
            text_sprite.addChild(text_field);
            const GLOW_COLOR:uint = 0x00AAAA;
            const GLOW_COLOR_CLEAR:uint = 0xAAAA00;
            const BLUR_W:int = BMD_W/10;
            const BLUR_STRENGTH:int = 1;
            if(ActGameEngine.IsAllClear()){
                text_sprite.filters = [new GlowFilter(GLOW_COLOR_CLEAR, 1.0, BLUR_W,BLUR_W, BLUR_STRENGTH)];//, 1, true
            }else{
                text_sprite.filters = [new GlowFilter(GLOW_COLOR, 1.0, BLUR_W,BLUR_W, BLUR_STRENGTH)];//, 1, true
            }

            bmd.draw(text_sprite);
        }

        //Touch to Start
        {
            FontText.DrawText(bmd, "Touch to Start", BMD_W/2, BMD_H - 32, 16, 0xFFFFFF, ActGameEngine.IsAllClear());
        }


        bmd.unlock();

        var bmp:Bitmap = new Bitmap(bmd);
//        bmp.y = ActGameEngine.GetAdH();
        addChild(bmp);
    }

    //Touch
    override public function OnMouseUp():void{
        //SS
        Util.SaveScreenShot(stage, "A");

        //タッチされたら開始（Upを検出するだけで十分）
//        ActGameEngine.Instance.Push(new Popup_StageSelect());
        m_NextPopup = new Popup_StageSelect();
        m_EndFlag = true;
    }

    //On Back
    override public function OnBack():void{
        //終了
        ActGameEngine.Exit();
    }
}


//Base : All Clear
class Popup_AllClear extends Popup
{
    //==Const==


    //==Var==

    public var m_TouchFlag:Boolean = false;


    //==Function==

    //Init
    public function Popup_AllClear(){
        super();

        var BMD_W:int = ActGameEngine.VIEW_W;
        var BMD_H:int = ActGameEngine.VIEW_H;// - ActGameEngine.Instance.GetAdH();

        var bmd:BitmapData = new BitmapData(BMD_W, BMD_H, false, 0x000000);
        bmd.lock();

        //BG
        {
            //PerlinNoise + ColorTransform
            const PanelLen:int = BMD_W/32;//16;//VIEW_W / 4;
            const Octave:int = 2;//変化は雑でいい
            const stitch:Boolean = true;//端はループできる感じで
            const fractalNoise:Boolean = true;//なめらかな変化で
            const channel:uint = 0x7;//全色
            const grayScale:Boolean = true;//RGBは全て同じ値で

            const base_ratio_min:Number = 0.5;
            const base_ratio_max:Number = 1.0;
            const r_ratio:Number = 0.1;
            const r_offset:uint = 0x34;//0x80;
            const g_ratio:Number = 0.1;
            const g_offset:uint = 0x2C;//0x80;
            const b_ratio:Number = 0.02;
            const b_offset:uint = 0x14;//0x80;

            //PerlinNoise
            bmd.perlinNoise(PanelLen,PanelLen, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);

            for(var yy:int = 0; yy < BMD_H; ++yy){
                var base_ratio:Number = Util.Lerp(base_ratio_min, base_ratio_max, 1.0 * (BMD_H - yy) / BMD_H);
                for(var xx:int = 0; xx < BMD_W; ++xx){
                    var color_ori:uint = bmd.getPixel(xx, yy);
                    var r:uint = (color_ori >> 16) & 0xFF;
                    var g:uint = (color_ori >>  8) & 0xFF;
                    var b:uint = (color_ori >>  0) & 0xFF;

                    r = base_ratio * (r * r_ratio + r_offset);
                    g = base_ratio * (g * g_ratio + g_offset);
                    b = base_ratio * (b * b_ratio + b_offset);

                    bmd.setPixel(xx, yy, (r << 16) | (g << 8) | (b << 0));
                }
            }
        }

        //Text
        {
            var text_format:TextFormat = new TextFormat();
            text_format.size = Math.min(BMD_W, BMD_H) * 35/100;//35/100;
            text_format.letterSpacing = BMD_W * 5/100;;//BMD_W * 10/100;
            text_format.leading = BMD_W * 5/100;//BMD_W * 25/100;//-SIZE/20;//-SIZE/7;
            text_format.color = 0xFFFFFF;
//            text_format.font = "myfont";

            var text_field:TextField = new TextField();
//            text_field.embedFonts = true;
            text_field.autoSize = TextFieldAutoSize.LEFT;
            text_field.defaultTextFormat = text_format;
            text_field.text = "完全\n制覇";

            text_field.x = BMD_W*17/32 - text_field.textWidth/2;
            text_field.y = BMD_H/2 - text_field.textHeight/2;

            var text_sprite:Sprite = new Sprite();
            text_sprite.addChild(text_field);
            const GLOW_COLOR:uint = 0xAAAA00;
            const BLUR_W:int = BMD_W/10;
            const BLUR_STRENGTH:int = 1;
            text_sprite.filters = [new GlowFilter(GLOW_COLOR, 1.0, BLUR_W,BLUR_W, BLUR_STRENGTH)];//, 1, true

            bmd.draw(text_sprite);
        }

        //Congratulations
        {
            FontText.DrawText(bmd, "Congratulations", BMD_W/2, BMD_H - 32, 16, 0xFFFFFF, true);
        }

        bmd.unlock();

        var bmp:Bitmap = new Bitmap(bmd);
        //bmp.y = ActGameEngine.Instance.GetAdH();
        addChild(bmp);
    }

    //Touch
    override public function OnMouseDown():void{
        m_TouchFlag = true;
    }
    override public function OnMouseUp():void{
        if(m_TouchFlag){
//            ActGameEngine.Instance.Push(new Popup_StageSelect());
            m_NextPopup = new Popup_StageSelect();
            m_EndFlag = true;
        }
    }

    //On Back
    override public function OnBack():void{
        m_NextPopup = new Popup_StageSelect();
        m_EndFlag = true;
    }
}


//ImageManager
class ImageManager
{
    //==Const==

    //Alias
    static public const PANEL_W:int = ActGameEngine.PANEL_W;
    static public const TILE_W:int    = PANEL_W / 2;


    //#enum:Quater
    static public const LU:int = 0;
    static public const RU:int = 1;
    static public const LD:int = 2;
    static public const RD:int = 3;

    //#enum:Pos
    static public const POS_X:int = 0;
    static public const POS_Y:int = 1;


    //#Graphic
    static public var m_BitmapData_Ori:BitmapData;
    //Noise
    static public var m_BitmapData_Noise:BitmapData;
    static public var m_BitmapData_Noise_Block:BitmapData;

    //#Mapping
    static public var m_Rect_Ground    :Vector.<Vector.<Rectangle> >;
    static public var m_Rect_Block    :Vector.<Vector.<Rectangle> >;
    static public var m_Rect_Mirror    :Vector.<Vector.<Rectangle> >;

    //Mark
    static public var m_BitmapData_Block_Normal        :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_RotFix        :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_Trampoline    :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_Fragile    :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_Heavy        :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_Sync        :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);
    static public var m_BitmapData_Block_Seesaw        :BitmapData = new BitmapData(PANEL_W, PANEL_W, true, 0x00000000);

    //Filter
    static public const divisor:Number = 1.0;
    static public const bias:Number = 0.0;
    static public const preserveAlpha:Boolean = true;
    static public const clamp:Boolean = false;
    static public const m_ConvFilter:Vector.<ConvolutionFilter> = new <ConvolutionFilter>[
        new ConvolutionFilter(3,3,
            [//LU
                1, 2, 0,
                4, 8, 0,
                0, 0, 0,
            ],divisor,bias,preserveAlpha,clamp
        ),
        new ConvolutionFilter(3,3,
            [//RU
                0, 2, 1,
                0, 8, 4,
                0, 0, 0,
            ],divisor,bias,preserveAlpha,clamp
        ),
        new ConvolutionFilter(3,3,
            [//LD
                0, 0, 0,
                4, 8, 0,
                1, 2, 0,
            ],divisor,bias,preserveAlpha,clamp
        ),
        new ConvolutionFilter(3,3,
            [//RD
                0, 0, 0,
                0, 8, 4,
                0, 2, 1,
            ],divisor,bias,preserveAlpha,clamp
        ),
    ];

    //Rect
    //- Empty
    static public const RECT_EMPTY            :Rectangle = new Rectangle( 4 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    //- BG
//    static public const RECT_BG                :Rectangle = new Rectangle( 3 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BG                :Rectangle = new Rectangle( 1 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    //- Goal
    static public const RECT_GOAL            :Rectangle = new Rectangle( 14 * TILE_W,  1 * PANEL_W, PANEL_W, PANEL_W);
    //- Player
    static public const RECT_PLAYER            :Rectangle = new Rectangle(0,  96, 32, 32);
    //- Wall
    static public const RECT_WALL            :Rectangle = new Rectangle( 1 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_L            :Rectangle = new Rectangle( 0 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_R            :Rectangle = new Rectangle( 2 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_U            :Rectangle = new Rectangle( 1 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_D            :Rectangle = new Rectangle( 1 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_LorU        :Rectangle = new Rectangle( 0 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_RorU        :Rectangle = new Rectangle( 2 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_LorD        :Rectangle = new Rectangle( 0 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_RorD        :Rectangle = new Rectangle( 2 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_LandU        :Rectangle = new Rectangle( 3 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_RandU        :Rectangle = new Rectangle( 4 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_LandD        :Rectangle = new Rectangle( 3 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_WALL_RandD        :Rectangle = new Rectangle( 4 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    //- Block
//*
    static public const RECT_BLOCK            :Rectangle = new Rectangle( 1 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_L        :Rectangle = new Rectangle( 0 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_R        :Rectangle = new Rectangle( 2 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_U        :Rectangle = new Rectangle( 1 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_D        :Rectangle = new Rectangle( 1 * TILE_W,  5 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LorU        :Rectangle = new Rectangle( 0 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RorU        :Rectangle = new Rectangle( 2 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LorD        :Rectangle = new Rectangle( 0 * TILE_W,  5 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RorD        :Rectangle = new Rectangle( 2 * TILE_W,  5 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LandU    :Rectangle = new Rectangle( 3 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RandU    :Rectangle = new Rectangle( 4 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LandD    :Rectangle = new Rectangle( 3 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RandD    :Rectangle = new Rectangle( 4 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
/*/
    static public const RECT_BLOCK            :Rectangle = new Rectangle( 1 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_L            :Rectangle = new Rectangle( 0 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_R            :Rectangle = new Rectangle( 2 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_U            :Rectangle = new Rectangle( 1 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_D            :Rectangle = new Rectangle( 1 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LorU        :Rectangle = new Rectangle( 0 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RorU        :Rectangle = new Rectangle( 2 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LorD        :Rectangle = new Rectangle( 0 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RorD        :Rectangle = new Rectangle( 2 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LandU        :Rectangle = new Rectangle( 3 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RandU        :Rectangle = new Rectangle( 4 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_LandD        :Rectangle = new Rectangle( 3 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_BLOCK_RandD        :Rectangle = new Rectangle( 4 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
//*/
    //- Mirror
    static public const RECT_STEEL            :Rectangle = new Rectangle( 6 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_L        :Rectangle = new Rectangle( 5 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_R        :Rectangle = new Rectangle( 7 * TILE_W,  1 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_U        :Rectangle = new Rectangle( 6 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_D        :Rectangle = new Rectangle( 6 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_LorU        :Rectangle = new Rectangle( 5 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_RorU        :Rectangle = new Rectangle( 7 * TILE_W,  0 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_LorD        :Rectangle = new Rectangle( 5 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_RorD        :Rectangle = new Rectangle( 7 * TILE_W,  2 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_LandU    :Rectangle = new Rectangle( 5 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_RandU    :Rectangle = new Rectangle( 6 * TILE_W,  3 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_LandD    :Rectangle = new Rectangle( 5 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);
    static public const RECT_STEEL_RandD    :Rectangle = new Rectangle( 6 * TILE_W,  4 * TILE_W, TILE_W, TILE_W);


    //#Utility
    static public const POS_ZERO:Point = new Point(0,0);


    //Static Init
    static public function Init(in_Graphic:DisplayObject):void
    {
        var x:int, y:int, i:int, j:int, index:int;

        //m_BitmapData_Ori
        {
            m_BitmapData_Ori = new BitmapData(256, 256, true, 0x00000000);
            m_BitmapData_Ori.draw(in_Graphic);
        }

        {
            const PanelLenX:int = 16;//64;//GetTotalW() / 4;
            const PanelLenY:int = 4;//GetTotalW() / 4;
            const Octave:int = 2;//変化は雑でいい
            const stitch:Boolean = true;//端はループできる感じで
            const fractalNoise:Boolean = true;//なめらかな変化で
            const channel:uint = 0x7;//全色
            const grayScale:Boolean = true;//RGBは全て同じ値で

            const ratio:Number = 1;//0.4;
            const alpha:Number = 0xA0;
            const ct:ColorTransform = new ColorTransform(ratio,ratio,ratio,0, 0x80*(1-ratio),0x80*(1-ratio),0x80*(1-ratio),alpha);
            const alpha_block:Number = 0x20;
            const ct_block:ColorTransform = new ColorTransform(ratio,ratio,ratio,0, 0x80*(1-ratio),0x80*(1-ratio),0x80*(1-ratio),alpha_block);

            const PANEL_W:int = ActGameEngine.PANEL_W;
            m_BitmapData_Noise = new BitmapData(PANEL_W*16, PANEL_W*16, true, 0x00000000);
            m_BitmapData_Noise.perlinNoise(PanelLenX,PanelLenY, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);
            m_BitmapData_Noise.colorTransform(m_BitmapData_Noise.rect, ct);

            m_BitmapData_Noise_Block = new BitmapData(PANEL_W*16, PANEL_W*16, true, 0x00000000);
            m_BitmapData_Noise_Block.perlinNoise(PanelLenX,PanelLenY, Octave, 1000*Math.random(), stitch, fractalNoise, channel, grayScale);
            m_BitmapData_Noise_Block.colorTransform(m_BitmapData_Noise_Block.rect, ct_block);
        }

        //m_Rect_Ground
        {
            m_Rect_Ground = new Vector.<Vector.<Rectangle> >(16);

            for(i = 0; i < 16; ++i){
                m_Rect_Ground[i] = new Vector.<Rectangle>(4);

                switch(i){
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    //Empty
                    for(j = 0; j < 4; ++j){
                        m_Rect_Ground[i][j] = RECT_EMPTY;
                    }
                    break;

                case 8:
                case 9:
                    //XorY
                    m_Rect_Ground[i][0] = RECT_WALL_LorU;
                    m_Rect_Ground[i][1] = RECT_WALL_RorU;
                    m_Rect_Ground[i][2] = RECT_WALL_LorD;
                    m_Rect_Ground[i][3] = RECT_WALL_RorD;
                    break;

                case 10:
                case 11:
                    //X
                    m_Rect_Ground[i][0] = RECT_WALL_L;
                    m_Rect_Ground[i][1] = RECT_WALL_R;
                    m_Rect_Ground[i][2] = RECT_WALL_L;
                    m_Rect_Ground[i][3] = RECT_WALL_R;
                    break;

                case 12:
                case 13:
                    //U
                    m_Rect_Ground[i][0] = RECT_WALL_U;
                    m_Rect_Ground[i][1] = RECT_WALL_U;
                    m_Rect_Ground[i][2] = RECT_WALL_D;
                    m_Rect_Ground[i][3] = RECT_WALL_D;
                    break;

                case 14:
                    //XandY
                    m_Rect_Ground[i][0] = RECT_WALL_LandU;
                    m_Rect_Ground[i][1] = RECT_WALL_RandU;
                    m_Rect_Ground[i][2] = RECT_WALL_LandD;
                    m_Rect_Ground[i][3] = RECT_WALL_RandD;
                    break;

                case 15:
                    //Default
                    for(j = 0; j < 4; ++j){
                        m_Rect_Ground[i][j] = RECT_WALL;
                    }
                    break;
                }
            }
        }

        //m_Rect_Block
        {
            m_Rect_Block = new Vector.<Vector.<Rectangle> >(16);

            for(i = 0; i < 16; ++i){
                m_Rect_Block[i] = new Vector.<Rectangle>(4);

                switch(i){
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    //Empty
                    for(j = 0; j < 4; ++j){
                        m_Rect_Block[i][j] = RECT_EMPTY;
                    }
                    break;

                case 8:
                case 9:
                    //XorY
                    m_Rect_Block[i][0] = RECT_BLOCK_LorU;
                    m_Rect_Block[i][1] = RECT_BLOCK_RorU;
                    m_Rect_Block[i][2] = RECT_BLOCK_LorD;
                    m_Rect_Block[i][3] = RECT_BLOCK_RorD;
                    break;

                case 10:
                case 11:
                    //X
                    m_Rect_Block[i][0] = RECT_BLOCK_L;
                    m_Rect_Block[i][1] = RECT_BLOCK_R;
                    m_Rect_Block[i][2] = RECT_BLOCK_L;
                    m_Rect_Block[i][3] = RECT_BLOCK_R;
                    break;

                case 12:
                case 13:
                    //U
                    m_Rect_Block[i][0] = RECT_BLOCK_U;
                    m_Rect_Block[i][1] = RECT_BLOCK_U;
                    m_Rect_Block[i][2] = RECT_BLOCK_D;
                    m_Rect_Block[i][3] = RECT_BLOCK_D;
                    break;

                case 14:
                    //XandY
                    m_Rect_Block[i][0] = RECT_BLOCK_LandU;
                    m_Rect_Block[i][1] = RECT_BLOCK_RandU;
                    m_Rect_Block[i][2] = RECT_BLOCK_LandD;
                    m_Rect_Block[i][3] = RECT_BLOCK_RandD;
                    break;

                case 15:
                    //Default
                    for(j = 0; j < 4; ++j){
                        m_Rect_Block[i][j] = RECT_BLOCK;
                    }
                    break;
                }
            }
        }

        //m_Rect_Mirror
        {
            m_Rect_Mirror = new Vector.<Vector.<Rectangle> >(16);

            for(i = 0; i < 16; ++i){
                m_Rect_Mirror[i] = new Vector.<Rectangle>(4);

                switch(i){
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    //Empty
                    for(j = 0; j < 4; ++j){
                        m_Rect_Mirror[i][j] = RECT_EMPTY;
                    }
                    break;

                case 8:
                case 9:
                    //XorY
                    m_Rect_Mirror[i][0] = RECT_STEEL_LorU;
                    m_Rect_Mirror[i][1] = RECT_STEEL_RorU;
                    m_Rect_Mirror[i][2] = RECT_STEEL_LorD;
                    m_Rect_Mirror[i][3] = RECT_STEEL_RorD;
                    break;

                case 10:
                case 11:
                    //X
                    m_Rect_Mirror[i][0] = RECT_STEEL_L;
                    m_Rect_Mirror[i][1] = RECT_STEEL_R;
                    m_Rect_Mirror[i][2] = RECT_STEEL_L;
                    m_Rect_Mirror[i][3] = RECT_STEEL_R;
                    break;

                case 12:
                case 13:
                    //U
                    m_Rect_Mirror[i][0] = RECT_STEEL_U;
                    m_Rect_Mirror[i][1] = RECT_STEEL_U;
                    m_Rect_Mirror[i][2] = RECT_STEEL_D;
                    m_Rect_Mirror[i][3] = RECT_STEEL_D;
                    break;

                case 14:
                    //XandY
                    m_Rect_Mirror[i][0] = RECT_STEEL_LandU;
                    m_Rect_Mirror[i][1] = RECT_STEEL_RandU;
                    m_Rect_Mirror[i][2] = RECT_STEEL_LandD;
                    m_Rect_Mirror[i][3] = RECT_STEEL_RandD;
                    break;

                case 15:
                    //Default
                    for(j = 0; j < 4; ++j){
                        m_Rect_Mirror[i][j] = RECT_STEEL;
                    }
                    break;
                }
            }
        }

        //Mark
        {
            var mtx:Matrix = new Matrix();
            mtx.tx = -8*16;
            mtx.ty = 0;

            m_BitmapData_Block_RotFix.draw(in_Graphic, mtx);
            mtx.tx -= 32;
            m_BitmapData_Block_Normal.draw(in_Graphic, mtx);
            mtx.tx -= 32;
            m_BitmapData_Block_Heavy.draw(in_Graphic, mtx);
            mtx.tx -= 32;
            m_BitmapData_Block_Trampoline.draw(in_Graphic, mtx);

            mtx.tx = -8*16;
            mtx.ty -= 32;
            m_BitmapData_Block_Sync.draw(in_Graphic, mtx);
            mtx.tx -= 32;
            m_BitmapData_Block_Fragile.draw(in_Graphic, mtx);
            mtx.tx -= 32;
            m_BitmapData_Block_Seesaw.draw(in_Graphic, mtx);
        }
//*
        {//法線化
            const MARK_NRM:uint = 0x8080FF;

            var convert_list:Vector.<BitmapData> = new <BitmapData>[
                m_BitmapData_Block_RotFix,
                m_BitmapData_Block_Normal,
                m_BitmapData_Block_Heavy,
                m_BitmapData_Block_Trampoline,
                m_BitmapData_Block_Sync,
                m_BitmapData_Block_Fragile,
            ];

            for(i = 0; i < convert_list.length; ++i){
                var convert_bmd:BitmapData = convert_list[i];
                for(y = 0; y < 32; ++y){
                    for(x = 0; x < 32; ++x){
                        var color_ori:uint = convert_bmd.getPixel32(x, y);

                        var color_new:uint = (color_ori & 0xFF000000) | MARK_NRM;

                        convert_bmd.setPixel32(x, y, color_new);
                    }
                }
            }
        }
//*/
    }



    //==BG==
    static public function CreateBackGroundGraphic(in_Map:Array):BitmapData
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //最終的な画像
        const w:int = Util.RoundUpPower2(ActGameEngine.GAME_W);
        const h:int = Util.RoundUpPower2(ActGameEngine.GAME_H);
        var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);

        bmd.lock();

        //遠景でクリア
        FillBG(bmd);

        bmd.unlock();

        return bmd;

    }
    static public function CreateTerrainGraphic(in_Map:Array):BitmapData
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //最終的な画像
        const w:int = Util.RoundUpPower2(ActGameEngine.GAME_W);
        const h:int = Util.RoundUpPower2(ActGameEngine.GAME_H);
        var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);

        bmd.lock();

        //鏡ブロック描画
//        DrawMirror(bmd, in_Map);

        //地形描画
        DrawGround(bmd, in_Map);

        bmd.unlock();

        return bmd;

    }
    static public function CreateMirrorGraphic(in_Map:Array):BitmapData
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //最終的な画像
        const w:int = Util.RoundUpPower2(ActGameEngine.GAME_W);
        const h:int = Util.RoundUpPower2(ActGameEngine.GAME_H);
        var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);

        bmd.lock();

        //鏡ブロック描画
        DrawMirror(bmd, in_Map);

        bmd.unlock();

        return bmd;

    }
    //遠景によるクリア
    static public function FillBG(io_BMD:BitmapData):void
    {
        var W:int = io_BMD.width;
        var H:int = io_BMD.height;

        var SrcRect:Rectangle = RECT_BG;
        var DstPoint:Point = new Point();
        for(var yy:int = 0; yy < H; yy += TILE_W){
            DstPoint.y = yy;
            for(var xx:int = 0; xx < W; xx += TILE_W){
                DstPoint.x = xx;
                io_BMD.copyPixels(m_BitmapData_Ori, SrcRect, DstPoint, null, null, true);
            }
        }

        //Noiseをかけてみる
        {
            io_BMD.draw(m_BitmapData_Noise);
        }
    }
//*
    //鏡ブロック描画
    static public function DrawMirror(io_BMD:BitmapData, in_Map:Array):void
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        var xx:int, yy:int, i:int;

        //Map => Bitmap_Base
        //Mapの要素を元に、「０：空白」「１：地形」というBitmapを生成
        var BitmapData_Base:BitmapData;
        {
            BitmapData_Base = new BitmapData(NumX, NumY, false, 0x0);
            BitmapData_Base.lock();
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    switch(in_Map[yy][xx]){
                    case ActGameEngine.M:
                        BitmapData_Base.setPixel(xx, yy, 1);
                        break;
                    }
                }
            }
        }

        //Bitmap_Base => Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD
        //Bitmap_Baseを元に、四隅の隣接状況をそれぞれ求める(Uniqueな値になるようにする)
        //Uniqueな値から、対応するIndexへと変換する
        var BitmapData_Quater:Vector.<BitmapData> = new Vector.<BitmapData>(4);
        {
            var rect:Rectangle = BitmapData_Base.rect;

            //
            for(i = 0; i < 4; i++){
                //Init
                var bmd:BitmapData = new BitmapData(NumX, NumY, false, 0x000000);
                bmd.lock();

                bmd.applyFilter(BitmapData_Base, rect, POS_ZERO, m_ConvFilter[i]);

                BitmapData_Quater[i] = bmd;
            }
        }

        //Draw
        //上で求めたIndexに基づき描画
        {
            var DstPoint:Point = new Point(0,0);
            var SrcRect:Rectangle = new Rectangle(0,0,TILE_W,TILE_W);
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    for(i = 0; i < 4; i++){
                        DstPoint.x = xx * PANEL_W + ((i&1)>>0) * TILE_W;
                        DstPoint.y = yy * PANEL_W + ((i&2)>>1) * TILE_W;

                        SrcRect = m_Rect_Mirror[BitmapData_Quater[i].getPixel(xx, yy)][i];

                        io_BMD.copyPixels(m_BitmapData_Ori, SrcRect, DstPoint, null, null, true);
                    }
                }
            }
        }
    }
//*/
    //地形描画
    static public function DrawGround(io_BMD:BitmapData, in_Map:Array):void
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        var xx:int, yy:int, i:int;

        //Map => Bitmap_Base
        //Mapの要素を元に、「０：空白」「１：地形」というBitmapを生成
        var BitmapData_Base:BitmapData;
        {
            BitmapData_Base = new BitmapData(NumX, NumY, false, 0x0);
            BitmapData_Base.lock();
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    switch(in_Map[yy][xx]){
                    case ActGameEngine.W:
                        BitmapData_Base.setPixel(xx, yy, 1);
                        break;
                    }
                }
            }
        }

        //Bitmap_Base => Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD
        //Bitmap_Baseを元に、四隅の隣接状況をそれぞれ求める(Uniqueな値になるようにする)
        //Uniqueな値から、対応するIndexへと変換する
        var BitmapData_Quater:Vector.<BitmapData> = new Vector.<BitmapData>(4);
        {
            var rect:Rectangle = BitmapData_Base.rect;

            //
            for(i = 0; i < 4; i++){
                //Init
                var bmd:BitmapData = new BitmapData(NumX, NumY, false, 0x000000);
                bmd.lock();

                bmd.applyFilter(BitmapData_Base, rect, POS_ZERO, m_ConvFilter[i]);

                BitmapData_Quater[i] = bmd;
            }
        }

        //Draw
        //上で求めたIndexに基づき描画
        {
            var DstPoint:Point = new Point(0,0);
            var SrcRect:Rectangle = new Rectangle(0,0,TILE_W,TILE_W);

            var noise_src_rect:Rectangle = new Rectangle(0,0,TILE_W,TILE_W);
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    for(i = 0; i < 4; i++){
                        DstPoint.x = xx * PANEL_W + ((i&1)>>0) * TILE_W;
                        DstPoint.y = yy * PANEL_W + ((i&2)>>1) * TILE_W;

                        SrcRect = m_Rect_Ground[BitmapData_Quater[i].getPixel(xx, yy)][i];

                        io_BMD.copyPixels(m_BitmapData_Ori, SrcRect, DstPoint, null, null, true);

                        //Noiseをかけてみる
                        if(SrcRect != RECT_EMPTY)
                        {
                            noise_src_rect.x = DstPoint.x;
                            noise_src_rect.y = DstPoint.y;
                            io_BMD.draw(m_BitmapData_Noise, null, null, null, noise_src_rect);
                        }
                    }
                }
            }
        }
    }


    //==Block==
    static public function CreateBlockGraphic(in_Map:Array):BitmapData
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //最終的な画像
        var bmd:BitmapData = new BitmapData(Util.RoundUpPower2(NumX * PANEL_W), Util.RoundUpPower2(NumY * PANEL_W), true, 0x00000000);

        bmd.lock();

        //ブロック描画
        DrawBlock(bmd, in_Map);

        bmd.unlock();

        return bmd;

    }
    //ブロック描画
    static public function DrawBlock(io_BMD:BitmapData, in_Map:Array):void
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        var xx:int, yy:int, i:int;

        var map_val:int = ActGameEngine.A;

        //Map => Bitmap_Base
        //Mapの要素を元に、「０：空白」「１：地形」というBitmapを生成
        var BitmapData_Base:BitmapData;
        {
            BitmapData_Base = new BitmapData(NumX, NumY, false, 0x0);
            BitmapData_Base.lock();
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    switch(in_Map[yy][xx]){
                    case ActGameEngine.A:
                    case ActGameEngine.B:
                    case ActGameEngine.E:
                    case ActGameEngine.F:
                    case ActGameEngine.Q:
                    case ActGameEngine.R:
                    case ActGameEngine.I:
                    case ActGameEngine.J:
                    case ActGameEngine.U:
                    case ActGameEngine.V:
                    case ActGameEngine.S:
                    case ActGameEngine.Z:
                        BitmapData_Base.setPixel(xx, yy, 1);
                        map_val = in_Map[yy][xx];
                        break;
                    }
                }
            }
        }

        //Bitmap_Base => Bitmap_LU,Bitmap_RU,Bitmap_LD,Bitmap_RD
        //Bitmap_Baseを元に、四隅の隣接状況をそれぞれ求める(Uniqueな値になるようにする)
        //Uniqueな値から、対応するIndexへと変換する
        var BitmapData_Quater:Vector.<BitmapData> = new Vector.<BitmapData>(4);
        {
            var rect:Rectangle = BitmapData_Base.rect;

            //
            for(i = 0; i < 4; i++){
                //Init
                var bmd:BitmapData = new BitmapData(NumX, NumY, false, 0x000000);
                bmd.lock();

                bmd.applyFilter(BitmapData_Base, rect, POS_ZERO, m_ConvFilter[i]);

                BitmapData_Quater[i] = bmd;
            }
        }

        //Draw
        //上で求めたIndexに基づき描画
        {
            var DstPoint:Point = new Point(0,0);
            var SrcRect:Rectangle = new Rectangle(0,0,TILE_W,TILE_W);
            var noise_src_rect:Rectangle = new Rectangle(0,0,TILE_W,TILE_W);
            for(yy = 0; yy < NumY; yy++){
                for(xx = 0; xx < NumX; xx++){
                    for(i = 0; i < 4; i++){
                        DstPoint.x = xx * PANEL_W + ((i&1)>>0) * TILE_W;
                        DstPoint.y = yy * PANEL_W + ((i&2)>>1) * TILE_W;

                        SrcRect = m_Rect_Block[BitmapData_Quater[i].getPixel(xx, yy)][i];

                        io_BMD.copyPixels(m_BitmapData_Ori, SrcRect, DstPoint, null, null, true);

                        //Noiseをかけてみる
                        if(SrcRect != RECT_EMPTY)
                        {
                            noise_src_rect.x = DstPoint.x;
                            noise_src_rect.y = DstPoint.y;
                            io_BMD.draw(m_BitmapData_Noise_Block, null, null, null, noise_src_rect);
                        }
                    }
                }
            }
        }
/*
        //マーク
        {
            var mtx:Matrix = new Matrix();
            for(yy = 0; yy < NumY; yy++){
                mtx.ty = PANEL_W * yy;
                for(xx = 0; xx < NumX; xx++){
                    mtx.tx = PANEL_W * xx;

                    switch(in_Map[yy][xx]){
                    case ActGameEngine.A:
                    case ActGameEngine.B:
                        io_BMD.draw(m_BitmapData_Block_Normal, mtx);
                        break;
                    case ActGameEngine.E:
                    case ActGameEngine.F:
                        io_BMD.draw(m_BitmapData_Block_RotFix, mtx);
                        break;
                    case ActGameEngine.Q:
                    case ActGameEngine.R:
                        io_BMD.draw(m_BitmapData_Block_Trampoline, mtx);
                        break;
                    case ActGameEngine.I:
                    case ActGameEngine.J:
                        io_BMD.draw(m_BitmapData_Block_Fragile, mtx);
                        break;
                    case ActGameEngine.U:
                    case ActGameEngine.V:
                        io_BMD.draw(m_BitmapData_Block_Heavy, mtx);
                        break;
                    case ActGameEngine.S:
                        io_BMD.draw(m_BitmapData_Block_Sync, mtx);
                        break;
                    case ActGameEngine.Z:
                        //io_BMD.draw(m_BitmapData_Block_Normal);
                        break;
                    }
                }
            }

            //Zの場合、中心にのみマーク
            //!!
        }

        //地形の色を変更
        //- マークも一緒に変更してみる
        {
            const max_val:Number = 0.9;
            const mid_val:Number = 0.6;
            const min_val:Number = 0.2;
            const CT_NORMAL        :ColorTransform = new ColorTransform(max_val, mid_val, mid_val);
            const CT_ROTFIX        :ColorTransform = new ColorTransform(mid_val, mid_val, max_val);
            const CT_TRAMPOLINE    :ColorTransform = new ColorTransform(mid_val, max_val, mid_val);
            const CT_FRAGILE    :ColorTransform = new ColorTransform(mid_val, mid_val, mid_val);
            const CT_HEAVY        :ColorTransform = new ColorTransform(mid_val, mid_val, min_val);
            const CT_SYNC        :ColorTransform = new ColorTransform(max_val, max_val, mid_val);
            const CT_SEESAW        :ColorTransform = new ColorTransform(max_val, max_val, max_val);

            switch(map_val){
            case ActGameEngine.A:
            case ActGameEngine.B:
                io_BMD.colorTransform(io_BMD.rect, CT_NORMAL);
                break;
            case ActGameEngine.E:
            case ActGameEngine.F:
                io_BMD.colorTransform(io_BMD.rect, CT_ROTFIX);
                break;
            case ActGameEngine.Q:
            case ActGameEngine.R:
                io_BMD.colorTransform(io_BMD.rect, CT_TRAMPOLINE);
                break;
            case ActGameEngine.I:
            case ActGameEngine.J:
                io_BMD.colorTransform(io_BMD.rect, CT_FRAGILE);
                break;
            case ActGameEngine.U:
            case ActGameEngine.V:
                io_BMD.colorTransform(io_BMD.rect, CT_HEAVY);
                break;
            case ActGameEngine.S:
                io_BMD.colorTransform(io_BMD.rect, CT_SYNC);
                break;
            case ActGameEngine.Z:
                io_BMD.colorTransform(io_BMD.rect, CT_SEESAW);
                break;
            }
        }
//*/
    }
    static public function CreateBlockGraphic_Additional(in_Map:Array):BitmapData
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        //最終的な画像
        var bmd:BitmapData = new BitmapData(Util.RoundUpPower2(NumX * PANEL_W), Util.RoundUpPower2(NumY * PANEL_W), true, 0x00000000);

        bmd.lock();

        //模様描画
        DrawBlock_Additional(bmd, in_Map);

        bmd.unlock();

        return bmd;

    }
    //模様描画
    static public function DrawBlock_Additional(io_BMD:BitmapData, in_Map:Array):void
    {
        //Alias
        var NumX:int = in_Map[0].length;
        var NumY:int = in_Map.length;

        var xx:int, yy:int;
//*
        //マーク
        {
            var seesaw_flag:Boolean = false;

            var mtx:Matrix = new Matrix();
            for(yy = 0; yy < NumY; yy++){
                mtx.ty = PANEL_W * yy;
                for(xx = 0; xx < NumX; xx++){
                    mtx.tx = PANEL_W * xx;

                    switch(in_Map[yy][xx]){
                    case ActGameEngine.A:
                    case ActGameEngine.B:
                        io_BMD.draw(m_BitmapData_Block_Normal, mtx);
                        break;
                    case ActGameEngine.E:
                    case ActGameEngine.F:
                        io_BMD.draw(m_BitmapData_Block_RotFix, mtx);
                        break;
                    case ActGameEngine.Q:
                    case ActGameEngine.R:
                        io_BMD.draw(m_BitmapData_Block_Trampoline, mtx);
                        break;
                    case ActGameEngine.I:
                    case ActGameEngine.J:
                        io_BMD.draw(m_BitmapData_Block_Fragile, mtx);
                        break;
                    case ActGameEngine.U:
                    case ActGameEngine.V:
                        io_BMD.draw(m_BitmapData_Block_Heavy, mtx);
                        break;
                    case ActGameEngine.S:
                        io_BMD.draw(m_BitmapData_Block_Sync, mtx);
                        break;
                    case ActGameEngine.Z:
                        //io_BMD.draw(m_BitmapData_Block_Normal);
                        seesaw_flag = true;
                        break;
                    }
                }
            }

            //Zの場合、中心にのみマーク
            if(seesaw_flag){
                mtx.tx = PANEL_W * (NumX-1)/2;
                mtx.ty = PANEL_W * (NumY-1)/2;
                io_BMD.draw(m_BitmapData_Block_Seesaw, mtx);
            }
        }
//*/
    }


    //==Player==

    static public function CreatePlayerGraphic():BitmapData{
        var bmd:BitmapData = new BitmapData(64, 64, true, 0x00000000);

        bmd.copyPixels(m_BitmapData_Ori, RECT_PLAYER, POS_ZERO);

        return bmd;
    }

    //==Goal==

    static public function CreateGoalGraphic():BitmapData{
        var bmd:BitmapData = new BitmapData(ActGameEngine.PANEL_W, ActGameEngine.PANEL_W, true, 0x88FFFFFF);

        bmd.copyPixels(m_BitmapData_Ori, RECT_GOAL, POS_ZERO);

        return bmd;
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
//    [Embed(source="wlcmaru2004emoji.ttf", fontFamily="myfont", embedAsCFF = "false", mimeType='application/x-font')]
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
    static public var s_TextSprite_Clear:Sprite = new Sprite();


    //==Function==

    static public function DrawText(out_BMD:BitmapData, in_Text:String, in_X:Number, in_Y:Number, in_Size:int, in_Color:uint, in_IsClear:Boolean, in_AlignX:int = 0, in_AlignY:int = 0):void{
        if(s_TextField == null){
            s_TextField = new TextField();
//            s_TextField.embedFonts = true;
            s_TextField.autoSize = TextFieldAutoSize.LEFT;

//            s_TextFormat.font = "myfont";

            var blur:Number = 4;
            s_TextSprite.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_NORMAL, 1.0, blur,blur)];
            s_TextSprite_Clear.filters = [new GlowFilter(ActGameEngine.LASER_COLOR_CLEAR, 1.0, blur,blur)];
        }

        //Param
        s_TextFormat.size = in_Size;
        s_TextFormat.color = in_Color;
        s_TextFormat.letterSpacing = in_Size/16;
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
        if(in_IsClear){
            s_TextSprite_Clear.addChild(s_TextField);
            out_BMD.draw(s_TextSprite_Clear);
        }else{
            s_TextSprite.addChild(s_TextField);
            out_BMD.draw(s_TextSprite);
        }
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

    //Round
    static public function RoundUpPower2(x:int):int{
        x = x - 1;
        x = x | (x >> 1);
        x = x | (x >> 2);
        x = x | (x >> 4);
        x = x | (x >> 8);
        x = x | (x >>16);
        return x + 1;
    }

    //Language
    static public function IsJapanese():Boolean{
//*
        return (Capabilities.language == "ja");
/*/
        return false;
//*/
    }

    //Screen Shot for iOS
    static public function SaveScreenShot(stage:Stage, suffix:String):void{
/*
        var BMD_W:int = stage.stageWidth;
        var BMD_H:int = stage.stageHeight;
        var bmd:BitmapData = new BitmapData(BMD_W, BMD_H, false, 0xFFFFFF);
        bmd.draw(stage);

        (new FileReference).save((new PNGEncoder()).encode(bmd), "SS_"+BMD_W+"_"+BMD_H+"_"+suffix+".png");
//*/
    }
}
