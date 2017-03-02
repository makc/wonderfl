package 
{

    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    [SWF ( width = 465, height = 465, frameRate = 60 )];
    public class Main extends Sprite 
    {
        private final COLOR1:uint = 0x000000;
        private final COLOR2:uint = 0x836034;
        private final COLOR3:uint = 0xF7E779;
        private final COLOR4:uint = 0x80A2F0;

        //画面全体を覆うキャンバスを作っておく
        private var _CANVAS:BitmapData = new BitmapData ( stage.stageWidth , stage.stageHeight , false , 0 ) ;

        //宣伝用//////////////////////
        private var _S0:PushButton ; 
        /////////////////////////////
       
        //画面上部にならんでるボタン
        private var _B0:PushButton ; 
        private var _B1:PushButton ; 
        private var _B2:PushButton ; 
        private var _B3:PushButton ;         

        //クリック判定用
        private var _CLICK:Boolean = false ;

        //現在の描画色
        private var _COLOR:uint = COLOR2;
        private var _BX:int = 0 ;
        private var _BY:int = 0 ;


        public function Main():void {
            addChild ( new Bitmap ( _CANVAS ) ) ;

            //宣伝用////////////////////////////////////////////////////
            _S0 = new PushButton ( this, 465-100 , 0, "Ad:kuma-flashgame" ) ;
            _S0.addEventListener ( MouseEvent.CLICK , function ():void { var url:URLRequest = new URLRequest ( "http://kuma-flashgame.blogspot.com/" ) ; navigateToURL( url ); } ) ;
            //////////////////////////////////////////////////////////

            {//画面上部にならんでるボタン
                _B0 = new PushButton ( this,  10 , 25, "ERASE" ) ;
                _B1 = new PushButton ( this, 120 , 25, "WALL" ) ;
                _B2 = new PushButton ( this, 230 , 25, "SAND" ) ;
                _B3 = new PushButton ( this, 340 , 25, "WATER" ) ;
                _B1.enabled = false ;

                _B0.addEventListener ( MouseEvent.CLICK , function ():void { _COLOR = COLOR1 ; _B0.enabled = false ; _B1.enabled = true  ; _B2.enabled = true  ; _B3.enabled = true  ; } ) ;
                _B1.addEventListener ( MouseEvent.CLICK , function ():void { _COLOR = COLOR2 ; _B0.enabled = true  ; _B1.enabled = false ; _B2.enabled = true  ; _B3.enabled = true  ; } ) ;
                _B2.addEventListener ( MouseEvent.CLICK , function ():void { _COLOR = COLOR3 ; _B0.enabled = true  ; _B1.enabled = true  ; _B2.enabled = false ; _B3.enabled = true  ; } ) ;
                _B3.addEventListener ( MouseEvent.CLICK , function ():void { _COLOR = COLOR4 ; _B0.enabled = true  ; _B1.enabled = true  ; _B2.enabled = true  ; _B3.enabled = false ; } ) ;
            }

            //マウスをクリックしたときの動作 座標はmouseX,mouseYの変数からとれるので、クリック判定だけ
            stage.addEventListener ( MouseEvent.MOUSE_DOWN , function ():void { _CLICK = true ; } ) ;
            stage.addEventListener ( MouseEvent.MOUSE_UP   , function ():void { _CLICK = false; } ) ;

            //メインループを開始
            addEventListener ( Event.ENTER_FRAME , RUN ) ;
        }
       

        public function RUN ( e:Event ):void {
            
            _CANVAS.lock() ;

            //上から降ってくる砂
            for ( var I:int = 200 ; I < 250 ; ++ I ) {
                if ( Math.random() < .1 ) {
                    _CANVAS.setPixel ( I , 60 , COLOR3 ) ;
                }
            }

            //クリックしたところに出てくる物
            if ( _CLICK && 60 < mouseY && 60 < _BY ) {
                for ( var J:int = 0 ; J < 20 ; ++ J ) {
                    var R:Number = J / 20 ;
                    _CANVAS.fillRect ( new Rectangle ( _BX * R + mouseX * ( 1 - R ) , _BY * R + mouseY * ( 1 - R ) , 5 , 5 ) , _COLOR ) ;
                }
            }
            _BX = mouseX ;
            _BY = mouseY ;
          
            //画面全体の砂の動きを処理
            for ( var X:int = 0 ; X < _CANVAS.width ; ++ X ) {
                for ( var Y:int = _CANVAS.height - 1 ; Y >= 0 ; -- Y ) {
                    process_core(X,Y);
                }
            }

            _CANVAS.unlock() ;
        }
    }


    private function process_core(var X:int , var Y:int):void {
        var C:uint = _CANVAS.getPixel ( X , Y ) ;
        if ( C == 0 ) {
            return ;
        }

        process3(C,X,Y);
        process4(C,X,Y);
    }

    //砂の処理
    private function process3(var C:uint, var X:int , var Y:int):void {
        if ( C != COLOR3 ) {
            return;
        }
        var T:uint ;
        var TX:int ;

        {//落下
            T = _CANVAS.getPixel ( X , Y + 1 ) ;
            if ( T == 0 ) {
                _CANVAS.setPixel ( X , Y     , T ) ;
                _CANVAS.setPixel ( X , Y + 1 , C ) ;
                return ;
            }

            //水より砂の方が重い,適当な確率で場所の置換を許す。
            if ( T == COLOR4 && Math.random() < .5 ) {
                _CANVAS.setPixel ( X , Y     , T ) ;
                _CANVAS.setPixel ( X , Y + 1 , C ) ;
                return ;
            }
        }

        {//左右移動
            TX = X + Math.floor ( Math.random() * 7 ) - 3 ;
            T = _CANVAS.getPixel ( TX , Y ) ;
            if ( T == 0 ) {
                _CANVAS.setPixel (  X , Y , T ) ;
                _CANVAS.setPixel ( TX , Y , C ) ;
                return ;
            }

            //水より砂の方が重い,適当な確率で場所の置換を許す。
            if ( T == COLOR4 && Math.random() < .8 ) {
                _CANVAS.setPixel (  X , Y , T ) ;
                _CANVAS.setPixel ( TX , Y , C ) ;
                return ;
            }
        }
    }


    //水の処理
    private function process4(var C:uint, var X:int , var Y:int):void {
        if ( C != COLOR4 ) {
            return;
        }
        var T:uint ;
        var TX:int ;

        {//落下
            T = _CANVAS.getPixel ( X , Y + 1 ) ;
            if ( T == 0 ) {
                _CANVAS.setPixel ( X , Y     , T ) ;
                _CANVAS.setPixel ( X , Y + 1 , C ) ;
                return ;
            }
        }

        {//左右移動
            TX = X + Math.floor ( Math.random() * 7 ) - 3 ;
            T = _CANVAS.getPixel ( TX , Y ) ;
            if ( T == 0 ) {
                _CANVAS.setPixel (  X , Y , T ) ;
                _CANVAS.setPixel ( TX , Y , C ) ;
                return ;
            }
        }
    }



}

