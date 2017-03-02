/*
　「反応拡散もどき」

　概要
　・ライフゲームの応用で、反応拡散っぽい動きをするものを作ってみた

　動作説明
　・毎回ちょっと違うパターンが生成される
　・マウスで色を消すことが可能。Shiftを押しながらだろさらに広範囲を消せる。

　解説
　・ベタに反応拡散系をいじろうとすると、パラメータの調整が難しかったので、
　　「生存（死亡）条件」がわかりやすいライフゲームを拡張してそれっぽいものを作ってみた
　・ConvolutionFilterでライフゲームもどきを実行しつつ、BlurFilterで拡散させているだけ
　・とりあえず「上下に移動するか斜めに移動するか(Alpha)」と「反応のしやすさ(Beta)」をなんとなくパラメータ化できた
　
*/

package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import flash.media.*;
 
    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x000000")]
    public class GameMain extends Sprite {

        //==Const==

        //サイズ
        static public const SCL:int = 2;//4;//大きくすると荒くなる（高速化される）
        static public const BMD_W:int = 465/SCL;//100;

        //速度
        static public const SPEED:int = 1;//試行回数（何倍速で実行するか）

        //Utility
        static public const BMD_RECT:Rectangle = new Rectangle(0,0,BMD_W,BMD_W);
        static public const POS_ZERO:Point = new Point(0,0);

        //Debug
        static public const DEBUG:Boolean = false;

//*
        //拡散反応もどき：乱数バージョン
        //Alphaが大きいと離れた位置に自然発生が起こり、小さいと四角い移動パターンになる
        //Betaが大きいと広がりやすく、小さいと広がりにくい
        //再現のため、乱数に桁数制限を入れてみる
        static public const Alpha:Number = 2.1 - 4.2*int(Math.random()*100)/100;//2.1～-2.1：実際には2.1～-5くらいまでOK
        static public const Beta:Number  = 0.3 - 0.6*int(Math.random()*100)/100;//0.3～-0.3
        //閾値
        static public const A:Number = 5.82 + Beta;
        //上下
        static public const B:Number = 2 + Alpha;
        static public const D:Number = -0.1 - Alpha;
        //斜め
        static public const C:Number = 0.2;
        static public const E:Number = -1.2 - 0.5*Alpha;
        static public const F:Number = -1 + Alpha;

        static public const Blur:Number = 4.5;

        //左下にデバッグ表示
        static public const DEBUG_NUMBER_LEN:int = 3;//桁数表示制限
        static public const DEBUG_STR:String =
            "A:" + A.toFixed(DEBUG_NUMBER_LEN) + "  " +
            "B:" + B.toFixed(DEBUG_NUMBER_LEN) + "  " +
            "C:" + C.toFixed(DEBUG_NUMBER_LEN) + "  " +
            "D:" + D.toFixed(DEBUG_NUMBER_LEN) + "  " +
            "E:" + E.toFixed(DEBUG_NUMBER_LEN) + "  " +
            "F:" + F.toFixed(DEBUG_NUMBER_LEN);
/*/
        static public const DEBUG_STR:String = "";
//*/

        //==Var==

        //表示用
        public var m_BitmapData_View:BitmapData;
        public var PALLETE_MAP:Array;

        //Debug
        public var m_BitmapData_View_U:BitmapData;
        public var m_BitmapData_View_V:BitmapData;

        //拡散反応用
        public var m_BitmapData_Src_U:BitmapData;

        //テキスト
        public var m_Text:TextField = new TextField();

        //==Function==

        //Init
        public function GameMain():void {
            //表示用
            {
                //画像
                {
                    m_BitmapData_View = new BitmapData(BMD_W, BMD_W, false, 0x000000);
                    var bmp_view:Bitmap = new Bitmap(m_BitmapData_View);
                    bmp_view.scaleX = SCL;
                    bmp_view.scaleY = SCL;
                    addChild(bmp_view);
                }

                //Palette
                {
                    const COLOR_00:uint = 0x111111;
                    const COLOR_FF:uint = 0xCCCC33;

                    const COLOR_00_R:uint = (COLOR_00 >> 16) & 0xFF;
                    const COLOR_00_G:uint = (COLOR_00 >>  8) & 0xFF;
                    const COLOR_00_B:uint = (COLOR_00 >>  0) & 0xFF;
                    const COLOR_FF_R:uint = (COLOR_FF >> 16) & 0xFF;
                    const COLOR_FF_G:uint = (COLOR_FF >>  8) & 0xFF;
                    const COLOR_FF_B:uint = (COLOR_FF >>  0) & 0xFF;

                    const Lerp:Function = function(in_Src:uint, in_Dst:uint, in_Ratio:Number):uint{
                        return (in_Src * (1-in_Ratio)) + (in_Dst * in_Ratio);
                    };

                    PALLETE_MAP = new Array(256);
                    for(var i:int = 0; i < 256; i++){
                        var ratio:Number = i / (255.0);
                        ratio = 0.5 - 0.5*Math.cos(Math.PI*ratio);//色をややくっきり分けてみる
                        ratio = 0.5 - 0.5*Math.cos(Math.PI*ratio);//さらにくっきり
                        ratio = 0.5 - 0.5*Math.cos(Math.PI*ratio);//さらにくっきり

                        var r:uint = Lerp(COLOR_00_R, COLOR_FF_R, ratio);
                        var g:uint = Lerp(COLOR_00_G, COLOR_FF_G, ratio);
                        var b:uint = Lerp(COLOR_00_B, COLOR_FF_B, ratio);

                        PALLETE_MAP[i] = (r << 16) | (g << 8) | (b << 0);
                    }
                }
            }

            //Debug
            if(DEBUG)
            {
                var bmp:Bitmap;

                m_BitmapData_View_U = new BitmapData(BMD_W, BMD_W, false, 0x000000);
                bmp = new Bitmap(m_BitmapData_View_U);
                addChild(bmp);

                m_BitmapData_View_V = new BitmapData(BMD_W, BMD_W, false, 0x000000);
                bmp = new Bitmap(m_BitmapData_View_V);
                bmp.x = BMD_W;
                addChild(bmp);
            }

            //拡散反応用
            {
                //生成
                {
                    m_BitmapData_Src_U = new BitmapData(BMD_W, BMD_W, false, 0x000000);
                }

                //初期値設定
                {
/*
                    //パーリンノイズ
                    m_BitmapData_Src_U.perlinNoise(BMD_W, BMD_W, 2, Math.random()*100, false, true, BitmapDataChannel.BLUE);
//*/
/*
                    //完全ランダム
                    m_BitmapData_Src_U.noise(Math.random()*100, 0x00,0xFF, BitmapDataChannel.BLUE);
//*/
//*
                    //中央に四角
                    m_BitmapData_Src_U.fillRect(new Rectangle(BMD_W*3/8, BMD_W*3/8, BMD_W/4, BMD_W/4), 0x0000FF);
//*/
                }
            }

            //Mouse
            {
                var shape:Shape = new Shape();
                var gr:Graphics = shape.graphics;

                var Draw:Function = function(in_SrcX:int, in_SrcY:int, in_DstX:int, in_DstY:int, in_IsShift:Boolean):void{
                    gr.clear();

                    var DOT_W:int = in_IsShift? BMD_W/4: BMD_W/16;
                    var color:uint = 0x000000;

                    if(Math.abs(in_SrcX - in_DstX) < 1 && Math.abs(in_SrcY - in_DstY) < 1){
                        //点
                        gr.lineStyle(0,0,0);
                        gr.beginFill(color, 1.0);
                        gr.drawCircle(in_SrcX, in_SrcY, DOT_W/2);
                        gr.endFill();
                    }else{
                        //線
                        gr.lineStyle(DOT_W, color, 1.0);

                        gr.moveTo(in_SrcX, in_SrcY);
                        gr.lineTo(in_DstX, in_DstY);
                    }

                    m_BitmapData_Src_U.draw(shape);
                };

                addEventListener(
                    Event.ADDED_TO_STAGE,
                    function(e:Event):void{
                        var IsMouseDown:Boolean = false;

                        var oldMouseX:int = bmp_view.mouseX;
                        var oldMouseY:int = bmp_view.mouseY;

                        stage.addEventListener(
                            MouseEvent.MOUSE_DOWN,
                            function(event:MouseEvent):void{
                                IsMouseDown = true;

                                Draw(oldMouseX, oldMouseY, bmp_view.mouseX, bmp_view.mouseY, event.shiftKey);
                            }
                        );
                        stage.addEventListener(
                            MouseEvent.MOUSE_MOVE,
                            function(event:MouseEvent):void{
                                if(IsMouseDown){
                                    Draw(oldMouseX, oldMouseY, bmp_view.mouseX, bmp_view.mouseY, event.shiftKey);
                                }
                                oldMouseX = bmp_view.mouseX;
                                oldMouseY = bmp_view.mouseY;
                            }
                        );
                        stage.addEventListener(
                            MouseEvent.MOUSE_UP,
                            function(event:MouseEvent):void{
                                IsMouseDown = false;
                            }
                        );
                    }
                );
            }

            //Text
            {
                m_Text.selectable = false;
                m_Text.autoSize = TextFieldAutoSize.LEFT;
                m_Text.defaultTextFormat = new TextFormat('Verdana', 12, 0x00FFFF, true);
                m_Text.text = DEBUG_STR;
                m_Text.filters = [new GlowFilter(0x000000, 1.0, 4,4, 255)];
                m_Text.x = 0;
                m_Text.y = 465 - 24;

                addChild(m_Text);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }
        }

        //Update
        public function Update(e:Event=null):void{
            //var DeltaTime:Number = 1.0 / stage.frameRate;

            //拡散反応処理
            for(var i:int = 0; i < SPEED; i++){
                Update_ReactionDiffusion();
            }

            //結果を可視化
            Redraw();
        }

        //Update：拡散反応（もどき）
        public function Update_ReactionDiffusion():void{
            //ライフゲーム相当

            //基本的な考え方
            //・隣接方向には拡大しようとする（中心に近い部分はプラス）
            //・まわりを全て囲まれたら消えようとする（配列の値を全て合計したらマイナス）
/*
            //ノーマル（曲がろうとする直線メイン、分離あり）
            const A:Number = 5;
            const B:Number = 1;
            const C:Number = 0.5;
            const D:Number = -1;
            const E:Number = -0.8;
            const F:Number = 0;

            const Blur:Number = 5.0;
//*/

/*
            //やや分離ありの直角メイン
            const A:Number = 5.82;
            const B:Number = 1;
            const C:Number = 0.2;
            const D:Number = -1;
            const E:Number = -0.71;
            const F:Number = 0;

            const Blur:Number = 5.0;
//*/

/*
            //分離あり
            const A:Number = 5.82;
            const B:Number = 1.1;
            const C:Number = 0.1;
            const D:Number = -0.88;
            const E:Number = -0.80;
            const F:Number = 0;

            const Blur:Number = 5.0;
//*/

/*
            //分離・合体
            const A:Number = 5.82;
            const B:Number = 2.2;
            const C:Number = 0.2;
            const D:Number = -0.1;
            const E:Number = -1.2;
            const F:Number = -1.25;

            const Blur:Number = 4.5;
//*/

/*
            //分離・合体2
            const A:Number = 5.82;
            const B:Number = 1.692;
            const C:Number = 0.2;
            const D:Number = 0.208;
            const E:Number = 1.046;
            const F:Number = -1.303;

            const Blur:Number = 4.5;
//*/

/*
            //遠隔発生
            const A:Number = 5.82;
            const B:Number = 4.0;
            const C:Number = 0.2;
            const D:Number = -2.1;
            const E:Number = -2.2;
            const F:Number = 1.0;

            const Blur:Number = 4.5;
//*/

/*
            //四角
            const A:Number = 5.82;
            const B:Number = -2.0;
            const C:Number = 0.2;
            const D:Number = 3.9;
            const E:Number = 0.8;
            const F:Number = -5.0;

            const Blur:Number = 4.5;
//*/

            const filter_conv:ConvolutionFilter = new ConvolutionFilter(
                5,5,
                [
                    F, E, D, E, F,
                    E, C, B, C, E,
                    D, B, A, B, D,
                    E, C, B, C, E,
                    F, E, D, E, F,
                ]
            );
            m_BitmapData_Src_U.applyFilter(m_BitmapData_Src_U, BMD_RECT, POS_ZERO, filter_conv);

            //拡散
            const filter_blur:BlurFilter = new BlurFilter(Blur, Blur);
            m_BitmapData_Src_U.applyFilter(m_BitmapData_Src_U, BMD_RECT, POS_ZERO, filter_blur);
        }

        //Redraw
        public function Redraw():void{
            //可視化
            {
                //m_BitmapData_Src_Uの可視化(Src側に今回の結果がフィードバックされているものとする)
                m_BitmapData_View.paletteMap(m_BitmapData_Src_U, BMD_RECT, POS_ZERO, null, null, PALLETE_MAP);
            }

            //Debug
            if(DEBUG){
                m_BitmapData_View_U.copyPixels(m_BitmapData_Src_U, BMD_RECT, POS_ZERO);
            }
        }
    }
}

