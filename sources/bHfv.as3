/*
BetweenAS3 Transition cheat sheet
Tweenerのやつのパクリ版。
FULL SCREENにすると広く見えるよ。

ちなみにeasingのデフォルト値は
Linear.linear

★参考
Tweener Transition cheat sheet
http://www.tonpoo.com/tweener/misc/transitions.html
*/
package
{
    import flash.display.Sprite;
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.printing.PrintJob;
    import flash.text.TextField;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.core.easing.IEasing;
    
    public class Main extends Sprite
    {
        private var _cellRect:Rectangle = new Rectangle(0,0,155,110);
        private var _tableType:String = "Medium";
        public function Main()
        {
            stage.align = "TL";
            stage.scaleMode = "noScale";
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            BetweenAS3.delay(BetweenAS3.func(mouseUpHandler,[null]),0.5).play();
            
            addBtn(3,0,"Simple");
            addBtn(66,0,"Medium");
            addBtn(129,0,"Complete");
            addBtn(402,0,"Print");
        }
        
        private function mouseUpHandler(e:MouseEvent):void
        {
            if(e){
                if(e.target is TextField){
                    return;
                }
            }
            while (numChildren > 4) {
                removeChildAt(4);
            }
            
            var stageWidth:int = stage.stageWidth;
            var stageHeight:int = stage.stageHeight;
            if(e){
                if(e.target.name == "Simple" || e.target.name == "Medium" || e.target.name == "Complete"){
                    _tableType = e.target.name;
                }else if(e.target.name == "Print"){
                    if(stageWidth < stageHeight){
                        stageWidth = 550;
                        stageHeight = 800;
                    }else{
                        stageWidth = 790;
                        stageHeight = 550;
                    }
                    BetweenAS3.delay(BetweenAS3.func(setPrint, [stageWidth, stageHeight]), 4).play();
                }
            }
            
            var partitionX:int = 3;
            var partitionY:int = 5;
            
            if(_tableType == "Simple"){
                partitionX = 2;
            }else if(_tableType == "Complete"){
                partitionX = 4;
            }
            
            var h:int = 20;
            var dW:int = 0;
            
            if(stageWidth > 465 || stageHeight > 465){
                if(stageWidth > stageHeight){
                    partitionX *= 2;
                    dW = 5;
                }else{
                    partitionY *= 2;
                }
            }
            _cellRect.width = Math.floor((stageWidth-dW)/partitionX);
            _cellRect.height = Math.floor((stageHeight-h)/partitionY);
                
            addCell(0,h,Sine.easeIn,"Sine.easeIn");
            addCell(0,_cellRect.height+h,Cubic.easeIn,"Cubic.easeIn");
            addCell(0,_cellRect.height*2+h,Quint.easeIn,"Quint.easeIn");
            addCell(0,_cellRect.height*3+h,Circ.easeIn,"Circ.easeIn");
            addCell(0,_cellRect.height*4+h,Back.easeIn,"Back.easeIn");
            
            addCell(_cellRect.width,h,Sine.easeOut,"Sine.easeOut");
            addCell(_cellRect.width,_cellRect.height+h,Cubic.easeOut,"Cubic.easeOut");
            addCell(_cellRect.width,_cellRect.height*2+h,Quint.easeOut,"Quint.easeOut");
            addCell(_cellRect.width,_cellRect.height*3+h,Circ.easeOut,"Circ.easeOut");
            addCell(_cellRect.width,_cellRect.height*4+h,Back.easeOut,"Back.easeOut");
            
            if(_tableType == "Medium" || _tableType == "Complete"){
                addCell(_cellRect.width*2,h,Sine.easeInOut,"Sine.easeInOut");
                addCell(_cellRect.width*2,_cellRect.height+h,Cubic.easeInOut,"Cubic.easeInOut");
                addCell(_cellRect.width*2,_cellRect.height*2+h,Quint.easeInOut,"Quint.easeInOut");
                addCell(_cellRect.width*2,_cellRect.height*3+h,Circ.easeInOut,"Circ.easeInOut");
                addCell(_cellRect.width*2,_cellRect.height*4+h,Back.easeInOut,"Back.easeInOut");
            }
            if(_tableType == "Complete"){
                addCell(_cellRect.width*3,h,Sine.easeOutIn,"Sine.easeOutIn");
                addCell(_cellRect.width*3,_cellRect.height+h,Cubic.easeOutIn,"Cubic.easeOutIn");
                addCell(_cellRect.width*3,_cellRect.height*2+h,Quint.easeOutIn,"Quint.easeOutIn");
                addCell(_cellRect.width*3,_cellRect.height*3+h,Circ.easeOutIn,"Circ.easeOutIn");
                addCell(_cellRect.width*3,_cellRect.height*4+h,Back.easeOutIn,"Back.easeOutIn");
            }
            
            if(stageWidth > 465 || stageHeight > 465){
                var w:int = _cellRect.width*partitionX/2+dW;
                if(stageWidth < stageHeight){
                    w = 0;
                    h += _cellRect.height*5;
                }
                addCell(w,h,Quad.easeIn,"Quad.easeIn");
                addCell(w,_cellRect.height+h,Quart.easeIn,"Quart.easeIn");
                addCell(w,_cellRect.height*2+h,Expo.easeIn,"Expo.easeIn");
                addCell(w,_cellRect.height*3+h,Elastic.easeIn,"Elastic.easeIn");
                addCell(w,_cellRect.height*4+h,Bounce.easeIn,"Bounce.easeIn");
                
                addCell(_cellRect.width+w,h,Quad.easeOut,"Quad.easeOut");
                addCell(_cellRect.width+w,_cellRect.height+h,Quart.easeOut,"Quart.easeOut");
                addCell(_cellRect.width+w,_cellRect.height*2+h,Expo.easeOut,"Expo.easeOut");
                addCell(_cellRect.width+w,_cellRect.height*3+h,Elastic.easeOut,"Elastic.easeOut");
                addCell(_cellRect.width+w,_cellRect.height*4+h,Bounce.easeOut,"Bounce.easeOut");
                
                if(_tableType == "Medium" || _tableType == "Complete"){
                    addCell(_cellRect.width*2+w,h,Quad.easeInOut,"Quad.easeInOut");
                    addCell(_cellRect.width*2+w,_cellRect.height+h,Quart.easeInOut,"Quart.easeInOut");
                    addCell(_cellRect.width*2+w,_cellRect.height*2+h,Expo.easeInOut,"Expo.easeInOut");
                    addCell(_cellRect.width*2+w,_cellRect.height*3+h,Elastic.easeInOut,"Elastic.easeInOut");
                    addCell(_cellRect.width*2+w,_cellRect.height*4+h,Bounce.easeInOut,"Bounce.easeInOut");
                }
                if(_tableType == "Complete"){
                    addCell(_cellRect.width*3+w,h,Quad.easeOutIn,"Quad.easeOutIn");
                    addCell(_cellRect.width*3+w,_cellRect.height+h,Quart.easeOutIn,"Quart.easeOutIn");
                    addCell(_cellRect.width*3+w,_cellRect.height*2+h,Expo.easeOutIn,"Expo.easeOutIn");
                    addCell(_cellRect.width*3+w,_cellRect.height*3+h,Elastic.easeOutIn,"Elastic.easeOutIn");
                    addCell(_cellRect.width*3+w,_cellRect.height*4+h,Bounce.easeOutIn,"Bounce.easeOutIn");
                }
            }
        }
        private function addCell(x:Number ,y:Number,easing:IEasing,title:String):void
        {
            var c:Cell = new Cell(title,_cellRect);
            c.x = x;
            c.y = y;
            this.addChild(c);
            var array:Array = [];
            for (var i:int = 0; i < 75; i++) {
                array[i] = easing.calculate(i / 74, 0, 1, 1);
            }
            c.start(array);
        }
        private function setPrint(stageWidth:int,stageHeight:int):void {
            var pj:PrintJob = new PrintJob();
            if (pj.start()) {
                pj.addPage(this, new Rectangle(0, 20, stageWidth,stageHeight));
            }
            pj.send();
        }
        
        private function addBtn(x:Number,y:Number,txt:String):void{
            var sb:SimpleButton = new SimpleButton(getRoundRect(0xEEEEEE,txt),getRoundRect(0xDDDDDD,txt),getRoundRect(0xFFFFFF,txt),getRoundRect(0xFF0000,txt));
            sb.x = x;
            sb.y = y;
            sb.name = txt;
            addChild(sb);
        }
        private function getRoundRect(c:int,txt:String):Sprite{
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(c);
            sp.graphics.drawRoundRect(0,0,60,18,2);
            sp.graphics.endFill();
            var tf:TextField = new TextField();
            tf.text = txt;
            tf.autoSize = "left";
            tf.x = (60-tf.width)/2;
            sp.addChild(tf);
            return sp;
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextField;
class Cell extends Sprite
{
    private var _bitmapData:BitmapData;
    private var _bitmap:Bitmap;
    private var _dotstage:Sprite;
    private var _dot:Sprite;
    private var _cellRect:Rectangle;// = new Rectangle(0,0,157,110);
    private var _coreRect:Rectangle;// = new Rectangle(3,20,150,80);
    private var _count:int;
    private var _easing_array:Array;
    public function Cell(txt:String,_cellRect:Rectangle)
    {
        this._cellRect = new Rectangle();
        this._coreRect = new Rectangle();
        
        this._cellRect = _cellRect;
        this._coreRect.x = _cellRect.x+3;
        this._coreRect.y = _cellRect.y+20;
        this._coreRect.width = _cellRect.width-7;
        this._coreRect.height = _cellRect.height-30;
        setupScreen();
        _dotstage = new Sprite();
        _dot = new Sprite();
        _dot.graphics.beginFill(0xFF);
        _dot.graphics.drawCircle(0,0,1);
        _dot.graphics.endFill();
        _dot.x = _coreRect.x+1;
        _dot.y = _coreRect.y+_coreRect.height;
        _dotstage.addChild(_dot);
        this.addChild(_dotstage);
        addNewText(4,4,txt);
    }
    private function setupScreen():void {
        _bitmapData = new BitmapData(_cellRect.width, _cellRect.height, false, 0xFFFFFF);
        var sp:Sprite = new Sprite();
        sp.graphics.lineStyle(1,0x999999);
        sp.graphics.beginFill(0xDDDDDD);
        sp.graphics.drawRect(_coreRect.x,_coreRect.y,_coreRect.width,_coreRect.height);
        sp.graphics.endFill();
        sp.graphics.lineStyle(1,0xCCCCCC);
        sp.graphics.moveTo(_coreRect.x+_coreRect.width/4,_coreRect.y+1);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width/4,_coreRect.y+_coreRect.height);
        sp.graphics.moveTo(_coreRect.x+_coreRect.width/2,_coreRect.y+1);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width/2,_coreRect.y+_coreRect.height);
        sp.graphics.moveTo(_coreRect.x+_coreRect.width*3/4,_coreRect.y+1);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width*3/4,_coreRect.y+_coreRect.height);
        //
        sp.graphics.moveTo(_coreRect.x+1,_coreRect.y+_coreRect.height/4);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width,_coreRect.y+_coreRect.height/4);
        sp.graphics.moveTo(_coreRect.x+1,_coreRect.y+_coreRect.height/2);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width,_coreRect.y+_coreRect.height/2);
        sp.graphics.moveTo(_coreRect.x+1,_coreRect.y+_coreRect.height*3/4);
        sp.graphics.lineTo(_coreRect.x+_coreRect.width,_coreRect.y+_coreRect.height*3/4);
        _bitmapData.draw(sp);
        _bitmap = new Bitmap(_bitmapData);
        this.addChild(_bitmap);
    }
    private function bitmapDataDraw():void
    {
        var bitmapData:BitmapData = _bitmapData;
        bitmapData.draw(_dotstage)
    }
    public function start(array:Array):void {
        _easing_array = array;
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    private function onEnterFrame(e:Event):void {
        _dot.x = (_coreRect.width - 1) * _count / (_easing_array.length - 1) +_coreRect.x + 1;
        _dot.y = _coreRect.y + _coreRect.height - _easing_array[_count] * (_coreRect.height - 1);
        bitmapDataDraw();
        _count ++;
        if (_count >= _easing_array.length) {
            this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
    }
    private function addNewText(x:Number, y:Number, txt:String):void
    {
        var tf:TextField = new TextField();
        tf.text = txt;
        tf.width = _coreRect.width;
        tf.height = 19;
        tf.x = x;
        tf.y = y;
        this.addChild(tf);
    }
}