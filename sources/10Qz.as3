package {

    import flash.display.Stage;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.events.MouseEvent;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")];

    public class FlashTest extends Sprite {

        private const nums:uint = 10000;
        private var bmpDat:BitmapData;
        private var vectorDat:BitmapData;
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var bmp:Bitmap;
        private var vectorList:Array;
        private var rect:Rectangle; 
        private var cTra:ColorTransform;

        public function FlashTest() {
            initialize();
        }
        private function initialize():void {

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            bmpDat= new BitmapData( 465, 465, false, 0x000000 );
            vectorDat= new BitmapData( 465, 465, false, 0x000000 );
            randomSeed= Math.floor( Math.random() * 0xFFFF );
            vectorDat.perlinNoise( 230, 230, 4,randomSeed, false, true, 1|2|0|0 );

            bmp= new Bitmap( bmpDat );
            addChild( bmp );

            rect= new Rectangle( 0, 0, 465, 465 );
            cTra= new ColorTransform( 0, .8, .8, .9 );

            vectorList= new Array();

            for (var i:uint = 0; i < nums; i++) {
                var px:Number = Math.random()*465;
                var py:Number = Math.random()*465;
                var av:Point = new Point( 0, 0 );
                var vv:Point = new Point( 0, 0 );
                var pv:Point = new Point( px, py );
                var hoge:VectorDat = new VectorDat( av, vv, pv);
                vectorList.push( hoge );
            }
            addEventListener( Event.ENTER_FRAME, loop );
            stage.addEventListener( MouseEvent.CLICK, resetFunc );
        }
        private function loop( e:Event ):void {
            bmpDat.colorTransform( rect, cTra );

            var list:Array = vectorList;
            var len:uint = list.length;
            for (var i:uint = 0; i < len; i++) {

                var dots:VectorDat = list[i];

                var col:Number = vectorDat.getPixel( dots.pv.x, dots.pv.y );
                var r:uint = col >> 16 & 0xff;
                var g:uint = col >> 8 & 0xff;
                //var b:uint = col & 0xff;

                dots.av.x += ( r - 128 ) * .0005;
                dots.av.y += ( g - 128 ) * .0005;
                dots.vv.x += dots.av.x;
                dots.vv.y += dots.av.y;
                dots.pv.x += dots.vv.x;
                dots.pv.y += dots.vv.y;

                var _posX:Number = dots.pv.x;
                var _posY:Number = dots.pv.y;

                dots.av.x *= .96;
                dots.av.y *= .96;
                dots.vv.x *= .92;
                dots.vv.y *= .92;

                ( _posX > 465 )?dots.pv.x = 0:
                ( _posX < 0 )?dots.pv.x = 465:0;
                ( _posY > 465 )?dots.pv.y = 0:
                ( _posY < 0 )?dots.pv.y = 465:0;

                bmpDat.fillRect( new Rectangle( dots.pv.x, dots.pv.y, 1, 1), 0xFFFFFF );

            }
        }

        private function resetFunc(e:MouseEvent):void{
            randomSeed= Math.floor( Math.random() * 0xFFFF );
            vectorDat.perlinNoise( 230, 230, 4,randomSeed, false, true, 1|2|0|0 );
            vectorList= new Array();
            
            for (var i:uint = 0; i < nums; i++) {

                var px:Number = Math.random()*465;
                var py:Number = Math.random()*465;

                var av:Point = new Point( 0, 0 );
                var vv:Point = new Point( 0, 0 );
                var pv:Point = new Point( px, py );

                var hoge:VectorDat = new VectorDat( av, vv, pv);

                vectorList.push( hoge );
            }
        }
    }
}

import flash.geom.Point;
class VectorDat {

    public var vv:Point;
    public var av:Point;
    public var pv:Point;

    function VectorDat( _av:Point, _vv:Point, _pv:Point ) {
        vv = _vv;
        av = _av;
        pv = _pv;
    }
}