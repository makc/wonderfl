package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.getTimer
    import flash.geom.*;
    import flash.filters.*;
    import net.hires.debug.Stats;
    
    /**
    copyPixelsとbeginBitmapFillの計算速度比較
    
    クリックすると両者が切り替わります。
    しかもフルスクリーンになってうざいです
    
    **/
    
    public class FlashTest extends Sprite {
        
        private var _srcBmpd:BitmapData;
        private var _outBmpd:BitmapData;
        private var _outBmp:Bitmap;
        
 
        
        private var srcW:Number=50;
        private var srcH:Number=50;
        
        
        private var outW:Number=2000;
        private var outH:Number=1000;
        
        private var _numX:uint=outW/srcW;
        private var _numY:uint=outH/srcH
        
        private var _flag:Boolean=true
        private var _txt:TextField=new TextField();
        
        private var _p:Point=new Point();
        private var _mat:Matrix = new Matrix();
        
        private var _oldTime:Number=0
        
        
        public function FlashTest() {
            // write as3 code here..
            stage.scaleMode="noScale";
            stage.align="TL";
            
            _srcBmpd=new BitmapData(srcW,srcH,true,0);
            _outBmpd=new BitmapData(outW,outH,true,0xff0000);
            _outBmp=new Bitmap(_outBmpd);
            addChild(_outBmp);
            addChild(_txt);
            addChild(new Stats())
            _txt.filters=[new GlowFilter(0xffffff,4,4,4,8)];
            _txt.x=100
            _txt.width=400;            
            addEventListener(Event.ENTER_FRAME,onFrame);
            stage.addEventListener(MouseEvent.CLICK,onClick);
        }
        
        private function onClick(e:Event):void{
            stage.displayState = "fullScreen";
           
            _flag=!_flag;    
        }
        
        //
        private function onFrame(e:Event):void{
            _srcBmpd.noise(getTimer())
            _srcBmpd.fillRect(new Rectangle(0,0,40,40),0xff000000)
        
            var time:Number=getTimer();        
             graphics.clear();
         
            if(_flag){
                
                _txt.text="CopyPiexls";
                _outBmp.visible=true;
                doCopyPixel();
            }else{
                 _txt.text="beginBitmapFill";
                _outBmp.visible=false;
                doBeginBitmapFill();
            }
            
            _txt.appendText("  " +(getTimer()-time) + "msec/calc     " + (getTimer()-_oldTime) +"msec/frame ");           
            _oldTime=getTimer();
        }
        
        
        
        //CopyPiexl
        private function doCopyPixel():void{
            
            
            for(var i:uint=0;i<_numX;i++){
                for(var j:uint=0;j<_numY;j++){
                    _p.x=i*srcW
                    _p.y=j*srcH
                    _outBmpd.copyPixels(_srcBmpd,_srcBmpd.rect,_p);
                }
            }
        }
        
        
        
        //BitmapFill
        private function doBeginBitmapFill():void{
            
            //いっきにびょうが
            //graphics.beginBitmapFill(_srcBmpd,null,true);
            //graphics.drawRect(0,0,outW,outH);
            //return;
            
            //いっこいっこ描画
             for(var i:uint=0;i<_numX;i++){
                for(var j:uint=0;j<_numY;j++){
                   _mat.identity(); 
   		   _mat.translate(i*srcW,j*srcW);
   		   _mat.scale(1,1);
   
                   graphics.beginBitmapFill(_srcBmpd, _mat,false);
		   graphics.drawRect(i*srcW,j*srcW,srcW,srcH);
                   graphics.endFill();    
                }
            }
            
            
            
        }
        
        
        
        
        
        
        
    }
}