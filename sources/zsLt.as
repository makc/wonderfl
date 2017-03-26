package
{
    import caurina.transitions.Tweener;
    
    import com.bit101.components.ComboBox;
    import com.bit101.components.HUISlider;
    import com.demonsters.debugger.MonsterDebugger;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.utils.ByteArray;    
    
    /**
     * ...
     * @author rettuce
     * 
     * Sound パラメータあてこんでみた
     * 音はYoodaさんのKasanaを拝借。
     * http://soundcloud.com/yooda/kasana
     * 
     */
    
    [SWF(width = 465, height = 465, backgroundColor = 0xFFFFFF, frameRate = 40)]
    
    public class Main extends Sprite
    {
        public function Main()
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init );
        }        
        private function init(e:Event = null ):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init );
            setStage();
                        
            // SoundMixer
            playSoundMixer();

                        
            loaderInfo.addEventListener(Event.UNLOAD, function(e:Event):void {
                stage.removeEventListener(Event.RESIZE, resizeEvent);
                loaderInfo.removeEventListener(Event.UNLOAD, arguments.callee );
            });
        }
        
        
        /* UI Setting */
        ///////////////////////////////////////////////////////////////////////
        
        private var _blmodeSelect:ComboBox;
        private var _slider1:HUISlider;
        private var _slider2:HUISlider;
        private var _slider3:HUISlider;
        private var _slider4:HUISlider;
        private var _slider5:HUISlider;
        private var _slider6:HUISlider;
        private function uiSet():void
        {
            var blArr:Array = [
                BlendMode.NORMAL,
                BlendMode.LAYER,
                BlendMode.OVERLAY,
                BlendMode.HARDLIGHT,
                BlendMode.DARKEN,
                BlendMode.DIFFERENCE
            ];
            _blmodeSelect = new ComboBox(this,10,10,'BlendMode',blArr);
            _blmodeSelect.selectedIndex = 3;
            
            _slider1 = new HUISlider(this, 340, 10, "Num");
            _slider2 = new HUISlider(this, 340, 25, "Length");
            _slider3 = new HUISlider(this, 340, 40, "Width ");
            _slider4 = new HUISlider(this, 340, 55, "Shape1");
            _slider5 = new HUISlider(this, 340, 70, "Shape2");
            _slider6 = new HUISlider(this, 340, 85, "Shape3");
            
            _slider1.width = _slider2.width = _slider3.width = _slider4.width = _slider5.width = _slider6.width = 150;
            
            _slider1.value = 50;
            _slider2.value = 50;
            _slider3.value = 50;
            _slider4.value = 50;
            _slider5.value = 50;
            _slider6.value = 50;
        }

                
        /* Sound Mixer */
        ///////////////////////////////////////////////////////////////////////
        
        private var _bArr:ByteArray = new ByteArray();
        private var _bg:Bitmap;
        private var _num:Object = new Object();
        
        private function playSoundMixer():void
        {            
            _bg = new Bitmap();
            _bg.smoothing = true;
            _bg.bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight );
            addChild(_bg);
            
            var sound:Sound = new Sound(new URLRequest('http://lab.rettuce.com/common/src/kasana.mp3'), new SoundLoaderContext(1, true));
            sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler );
            sound.addEventListener ( ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
                txt.text =  "Now loading... "+Math.floor(e.bytesLoaded / e.bytesTotal * 100) + "%";
            });
            sound.addEventListener(Event.COMPLETE, function(e:Event):void {
                sound.removeEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
                    txt.text =  Math.floor(e.bytesLoaded / e.bytesTotal * 100) + "%";
                });
                removeChild(txt);
                
                // UI SET
                uiSet();
                
                // Flower SET
                flowerInit();
                
                sound.play();
                addEventListener( Event.ENTER_FRAME, beatCheck2 );
            });
            
            var txt:TextField = new TextField();
            txt.width = 120;
            txt.x = stage.stageWidth / 2 -60;
            txt.y = stage.stageHeight / 2-20;
            addChild(txt);
        }
        
        private function beatCheck2(e:Event):void
        {
            SoundMixer.computeSpectrum(_bArr, false, 0);    //　byteArr(length=512), FFT, rate 0->44.1 KHz, 1->22.05KHz...
            _bArr.position = 0;
            
            var byteTotal:Number = 0;    // 両音
            var byte:Number      = 0;
            
            for(var i:int = 0; i < 512; i++)
            {
                byte = Math.abs(_bArr.readFloat());
                byteTotal += byte;
            };
            
            byteTotal /= 512;            
            if(byteTotal>0.01){
                Tweener.addTween( _num, { x:byteTotal, time:0.4, transition:'easeOutQuad' });
            }
            
//            _bg.bitmapData.draw( stage, new Matrix(3,0,0,3,-stage.stageWidth,-stage.stageHeight), null, _blmodeSelect.selectedItem.toString() );
            _bg.bitmapData.draw( stage, new Matrix(2,0,0,2,-stage.stageWidth/2,-stage.stageHeight/2), null, _blmodeSelect.selectedItem.toString());
            
            var num:int = Math.round(_num.x*(_slider1.value))+6;
            _flower.NUM = num;
            _flower.W   = _num.x*(25*(_slider2.value)*0.5+500);
            _flower.H   = (180*(_slider3.value)*0.01)/num + _num.x*100;
            _flower.FY  = _num.x*(0.1*(_slider4.value)+1);
            _flower.FT  = _num.x*(0.08*(_slider5.value)+2);
            _flower.K   = _num.x*(8*(_slider6.value));
            _flower.Z   = _num.x*10;
            _flower.drawFlower();
        }
        
        
        
        /* Flower Setting */
        /////////////////////////////////////////////////////////////////////////　        
        private var _flower:Flower;
        private var _s:Flower;
        
        private function flowerInit():void
        {
            _flower = new Flower();
//            _flower._fillFlg = false;
            addChildAt(_flower,1);
            
            _flower.x = stage.stageWidth/2;
            _flower.y = stage.stageHeight/2;
        }        
        
        
        
        
        /* Error Handler */
        //////////////////////////////////////////////////////////////////
        
        private function errorHandler(e:IOErrorEvent):void
        {
            MonsterDebugger.trace( 'Error...', e );
        }
        
        
        /* stage set */
        //////////////////////////////////////////////////////////////////
        
        private function setStage():void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, resizeEvent);
            resizeHandler();
        }
        private function resizeEvent(e:Event = null):void
        {
            resizeHandler();
        }        
        public function resizeHandler():void
        {
            
        }

    }
}


import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.geom.Point;

class Flower extends Sprite
{
    private var _g:Graphics;
    
    private var _NUM:uint = 10;            // 枚数
    private var _W:uint = 180;            //幅
    private var _H:uint = 30;            //高さ
    private var _FY:Number = 0.7;        //膨らみ位置 横
    private var _FT:Number = 0.5;        //膨らみ位置 縦
    private var _K:uint    = 20;        //深さ
    private var _Z:Number  = 5;            //ズレ
    private var _zure:Array = [];
    
    public var _fillFlg:Boolean = true;
    
    public function Flower()
    {
        _g = this.graphics;
        
        for (var i:int = 0; i < 7; i++) { _zure[i] = new Point();}
        drawFlower();
    }
    
    public function drawFlower($num:Number=0):void
    {            
        // Line&Color Setting
        if(!_fillFlg){
            _g.clear();
            _g.lineStyle( 0.5, 0 );
            _g.beginFill(0xFFFFFF);
        }else{
            _g.clear();
            //                _g.lineStyle( 1, 0xca4000 );
            var fillType:String = GradientType.RADIAL;
            
            
            var colors:Array;
            var dropColor:Number;
            
            switch($num){
                case 0:
                    colors    = [0xca4000, 0xde878b, 0xffaec1, 0xffd4ef];
                    //                        colors    = [0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF];
                    dropColor = 0xca4000;
                    break;
                
                case 1:
                    colors    = [0xca4000, 0xde878b, 0xffaec1, 0xffd4ef];
                    dropColor = 0xca4000;
                    break;
                
                case 2:
                    colors    = [0x0040cd, 0x5990ff, 0x90c9ff, 0xd7ebff];
                    dropColor = 0x5990ff;
                    break;
                
                case 3:
                    colors    = [0xffd4ef, 0xffaec1, 0xde878b, 0xca4000 ];
                    dropColor = 0xffd4ef;                        
                    break;
            };
            
            
            var alphas:Array = [1, 1, 1, 1];
            //                var alphas:Array = [1 , Math.random()+0.3, Math.random()+0.3, 1];
            var ratios:Array = [0, 80, 180, 255];
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(-_W*2, -_W*2, 0, _W, _W );
            _g.beginGradientFill(fillType, colors, alphas, ratios, matrix);                
        }
        
        
        // draw Petal
        for(var i:int=0; i < _NUM; i++){
            var ang:Number = ( 2*Math.PI/_NUM*i - Math.PI/2 );
            drawPetal(ang);
        }
        
        // DropShadow
        var filArr:Array = new Array();
        var dsFilter:DropShadowFilter = new DropShadowFilter( 0, 10, dropColor, 0.7, 15, 15, 3);
        filArr.push(dsFilter);
        filters = filArr;
    }
    
    private function drawPetal(ang:Number):void
    {
        
        for (var u:int = 0; u < 7; u++) {
            _zure[u].x = Math.random()*_Z-_Z/2;
            _zure[u].y = Math.random()*_Z-_Z/2;
        }
        
        var pointArr:Array = [];
        var px:Number;
        var py:Number
        
        var x1:Number = _W*_FY/2;
        var x2:Number = _W*_FY;
        var x3:Number = _W;
        var x4:Number = _W-_K;
        var y1:Number = _H*_FT;
        var y2:Number = _H;
        var y3:Number = _H*_FT/2;
        var y4:Number = 0;
        
        var leng1:Number = Math.sqrt( x1*x1 + y1*y1 );
        var leng2:Number = Math.sqrt( x2*x2 + y2*y2 );
        var leng3:Number = Math.sqrt( x3*x3 + y3*y3 );
        var leng4:Number = Math.sqrt( x4*x4 + y4*y4 );
        
        var ang1:Number = y1/leng1;
        var ang2:Number = y2/leng2;
        var ang3:Number = y3/leng3;
        var ang4:Number = y4/leng4;
        
        pointArr.push(new Point(0, 0));
        pointArr.push( new Point( Math.cos(ang-ang1)*leng1+_zure[0].x , Math.sin(ang-ang1)*leng1+_zure[0].y ));
        pointArr.push( new Point( Math.cos(ang-ang2)*leng2+_zure[1].x , Math.sin(ang-ang2)*leng2+_zure[1].y ));
        pointArr.push( new Point( Math.cos(ang-ang3)*leng3+_zure[2].x , Math.sin(ang-ang3)*leng3+_zure[2].y ));            
        
        _g.moveTo(pointArr[0].x, pointArr[0].y);
        for(var i:int=0; i<pointArr.length-1; i++){
            px = (pointArr[i+1].x + pointArr[i].x)/2;
            py = (pointArr[i+1].y + pointArr[i].y)/2;                
            _g.curveTo(pointArr[i].x, pointArr[i].y, px, py);
        }
        _g.lineTo(pointArr[pointArr.length-1].x+_zure[3].x , pointArr[pointArr.length-1].y+_zure[3].y );
        
        _g.lineTo( Math.cos(ang+ang4)*leng4, Math.sin(ang+ang4)*leng4 );
        _g.lineTo( Math.cos(ang+ang3)*leng3+_zure[4].x  , Math.sin(ang+ang3)*leng3+_zure[4].y  );
        
        pointArr = [];
        pointArr.push( new Point( Math.cos(ang+ang3)*leng3+_zure[4].x , Math.sin(ang+ang3)*leng3+_zure[4].y ));            
        pointArr.push( new Point( Math.cos(ang+ang2)*leng2+_zure[5].x , Math.sin(ang+ang2)*leng2+_zure[5].y ));
        pointArr.push( new Point( Math.cos(ang+ang1)*leng1+_zure[6].x , Math.sin(ang+ang1)*leng1+_zure[6].y ));
        pointArr.push(new Point(0, 0));
        
        for(i=0; i<pointArr.length-1; i++){
            px = (pointArr[i+1].x + pointArr[i].x)/2;
            py = (pointArr[i+1].y + pointArr[i].y)/2;                
            _g.curveTo(pointArr[i].x, pointArr[i].y, px, py);
        }
        _g.lineTo(pointArr[pointArr.length-1].x, pointArr[pointArr.length-1].y );
    }
    
    private function angleMath($x:Number, $y:Number):Number
    {
        var dx:Number = $x - $x;
        var dy:Number = $y - 0;
        return Math.atan2(dy , dx)*180/Math.PI;
    }
    
    
    
    
    
    /* Setter & Getter */
    /////////////////////////////////////////////////////////////////////////
    
    public function set NUM($NUM:uint):void{ _NUM = $NUM; }
    public function set W  ($W:uint):void  { _W   = $W;   }
    public function set H  ($H:uint):void  { _H   = $H;   }
    public function set FY ($FY:Number):void{ _FY = $FY;  }
    public function set FT ($FT:Number):void{ _FT = $FT;  }
    public function set K  ($K:uint):void  { _K   = $K;   }
    public function set Z  ($Z:uint):void  { _Z   = $Z;   }
}




