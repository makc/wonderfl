//
// 伝染病のシミュレーション
//
// 緑：健康
// 黄：潜伏期間
// 赤：発症
// 青：免疫獲得
// 灰：死亡
//
//
// 感染率：接触時の感染率(0～100％)
// 毒性の強さ：発症時のＨＰ減少の大きさ(0-999)
// 潜伏期間：感染から発症までの期間
// 発症時間：周りに感染を広めながらＨＰが減少していく期間
// 免疫期間：発症終了後に抗体ができて再感染しない期間
//
// 移動：人の移動量の設定(４段階)
// 国境：国境移動の制限(検疫：発症している人のみ通行不可　封鎖：完全封鎖)
// 隔離：「ON」にすると発症している人を画面右下方向に隔離
//
// 左クリックでワクチンを適用(30%の確率で免疫を獲得)
//
//
//　解説など：http://game.g.hatena.ne.jp/Nao_u/20090430#p1
//
package {      
    import flash.display.Sprite;      
    import flash.events.*;      
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="20")]       
         
    public class FlashTest extends Sprite {      
        public function FlashTest() {      
            Main = this;      
            initialize();      
            stage.addEventListener(Event.ENTER_FRAME,update);       
            stage.addEventListener(MouseEvent.MOUSE_DOWN,  viewClickEvent);    
        }      
    }      
}  

var kansen:int  = 80;       // 感染率(%)
var dokusei:int = 5;       // 毒性の強さ
var senpuku:int = 10;       // 潜伏期間
var hassyou:int = 7;        // 発症時間
var meneki:int  = 50;       // 免疫期間

var moveRate:Number = 0.55; // 移動の自由度
var kakuri:Number = 0;

var MoveRateAry:Array = new Array();

import flash.display.Bitmap;  
import flash.display.BitmapData;  
import flash.display.Sprite;       
import flash.events.* 
import flash.text.TextField;      
import flash.geom.*; 
import flash.utils.getTimer; 
var Main:Sprite;      
var SCREEN_W:Number = 465; 
var SCREEN_H:Number = 465; 
var View: Bitmap;  
var BmpData: BitmapData;  
var BgColor:int = 0x101010;
var WallColor:int = 0xf08080;
var WallColor2:int = 0x807070;

var ColGreen:int  = 0x408040;
var ColYellow:int = 0xffff40;
var ColRed0:int    = 0xff6060;
var ColRed1:int    = 0xff4040;
var ColBlue:int   = 0x2070a0;
var ColGray:int   = 0x404040;

var BITMAP_W:int = 384; 
var BITMAP_H:int = 384; 

var AgentAry:Vector.<Agent> = new Vector.<Agent>;
var Text0:TextField = new TextField();
var Text1:TextField = new TextField();
var Time:int = 0;
var StateAry:Array = new Array();

var ResetButton:Button;
var KakuriButton:Button;
var Idou:TextField = new TextField();
var Kokkyou:TextField = new TextField();
var IdouType:int = 2;
var KokkyouType:int = 2;

function initialize():void{      

    MoveRateAry.push( 0.05 );
    MoveRateAry.push( 0.25 );
    MoveRateAry.push( 0.55 );
    MoveRateAry.push( 0.85 );

    BmpData = new BitmapData(BITMAP_W, BITMAP_H, false, 0xffffff);  
    View = new Bitmap(BmpData);  
    View.scaleX = 1.0; 
    View.scaleY = 1.0; 
    Main.addChild(View);       

    clearBmp();    
    createAgent();

    Text0.x = 10;
    Text0.y = 386;
    Text0.defaultTextFormat = new TextFormat( "AXIS Std R", 13, 0, false );
    Main.addChild(Text0); 
    
    Text1.x = 59;
    Text1.y = 388;
    Text1.width = 384;
    Text1.defaultTextFormat = new TextFormat( "AXIS Std R", 10, 0, false );
    Main.addChild(Text1); 

    createResetButton();
    createKakuriButton();
    createIdouButton();
    createKokkyouButton();

    new InputArea(10,410, "感染率   ", kansen.toString(), function(str:String):void{kansen=parseInt(str)} );
    new InputArea(10,426, "毒性の強さ ", dokusei.toString(), function(str:String):void{dokusei=parseInt(str)} );

    new InputArea(118,410, "潜伏期間 ", senpuku.toString(), function(str:String):void{senpuku=parseInt(str)} );
    new InputArea(118,426, "発症時間 ", hassyou.toString(), function(str:String):void{hassyou=parseInt(str)} );
    new InputArea(118,442, "免疫期間 ", meneki.toString(), function(str:String):void{meneki=parseInt(str)} );

    var t:TextField;
    t = new TextField();
    t.text = "%";
    t.x = 95;
    t.y = 410;
    t.width = 16;
    t.height = 16;
    Main.addChild(t); 

    t = new TextField();
    t.text = "日";
    t.x = 193;
    t.y = 410;
    t.width = 16;
    t.height = 19;
    Main.addChild(t); 

    t = new TextField();
    t.text = "日";
    t.x = 193;
    t.y = 426;
    t.width = 16;
    t.height = 19;
    Main.addChild(t); 

    t = new TextField();
    t.text = "日";
    t.x = 193;
    t.y = 442;
    t.width = 16;
    t.height = 19;
    Main.addChild(t); 
} 

function viewClickEvent(event:MouseEvent):void{
    var mx:Number = Main.stage.mouseX;    
    var my:Number = Main.stage.mouseY;    
    
    for each( var agent:Agent in AgentAry ){
        if( agent.Status == 0 && Math.random() < 0.3 ){
            var dx:Number = mx-agent.X;
            var dy:Number = my-agent.Y;
            var dist:Number = Math.sqrt( dx*dx + dy*dy );
            if( dist < 35 ){
                agent.Status = 3;
                agent.CountDown = meneki * 10;
            }
        }
    }
}

function createAgent():void{
    AgentAry = new Vector.<Agent>;

    var i:int;
    var agent:Agent;
    for( i=0; i<4096; i++ ){
        agent = new Agent( 0,0,BITMAP_W,BITMAP_H );
    }
    for( i=0; i<1500; i++ ){
        agent = new Agent( 0,60,128, BITMAP_H-128);
    }
    for( i=0; i<1024; i++ ){
        agent = new Agent( 128,0,BITMAP_W,80 );
    }
    for( i=0; i<2048; i++ ){
        agent = new Agent( 128,0,BITMAP_W,80 );
    }
    for( i=0; i<4096; i++ ){
        agent = new Agent( 0,200,BITMAP_W,180 );
    }
}

function createResetButton():void{
    ResetButton = new Button(64, 18, 8, "Reset", 16);
    ResetButton.x = 468-120
    ResetButton.y = 468-22
    ResetButton.addEventListener(MouseEvent.CLICK, 
        function(event:MouseEvent):void{createAgent();Time=0;}
    ); 
    Main.addChild(ResetButton);
}

function createKakuriButton():void{
    KakuriButton = new Button(64, 18, 8, "隔離 OFF", 10);
    KakuriButton.x = 468-120
    KakuriButton.y = 468-52
    KakuriButton.addEventListener(MouseEvent.CLICK, 
        function(event:MouseEvent):void{
            if( kakuri == 0.0 ) {
                KakuriButton.setLabel("隔離 ON");
                kakuri = 0.45;
            }else{
                KakuriButton.setLabel("隔離 OFF");
                kakuri = 0.0;
            }
        }
    ); 
    Main.addChild(KakuriButton);
}

function createIdouButton():void{

    Idou.border = true;
    Idou.borderColor = 0xCCCCCC;
    Idou.x = 234;
    Idou.y = 415;
    Idou.width = 79;
    Idou.height = 17;
    Idou.defaultTextFormat = new TextFormat( "AXIS Std R", 10, 0, false );
    Idou.text = "移動：通常"
    Main.addChild(Idou); 

    var up:Button   = new Button(14,9, 1, "▲", 9);
    var down:Button = new Button(14,9, 1, "▼", 9);
    up.x = 317;
    up.y = 409;
    down.x = 317;
    down.y = 424;
    Main.addChild(up);
    Main.addChild(down);

    up.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{ IdouType--; updateIdouType(); } ); 
    down.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{ IdouType++; updateIdouType(); } ); 
}

function updateIdouType():void{
    if( IdouType < 0 ) IdouType = 3;
    if( IdouType > 3 ) IdouType = 0;
    switch( IdouType ){
    case 0: Idou.text = "移動：厳戒態勢   "; moveRate = MoveRateAry[IdouType]; break;
    case 1: Idou.text = "移動：外出制限   "; moveRate = MoveRateAry[IdouType]; break;
    case 2: Idou.text = "移動：通常   "; moveRate = MoveRateAry[IdouType]; break;
    case 3: Idou.text = "移動：活発   "; moveRate = MoveRateAry[IdouType]; break;
    }
}


function createKokkyouButton():void{

    Kokkyou.border = true;
    Kokkyou.borderColor = 0xCCCCCC;
    Kokkyou.x = 234;
    Kokkyou.y = 443;
    Kokkyou.width = 79;
    Kokkyou.height = 17;
    Kokkyou.defaultTextFormat = new TextFormat( "AXIS Std R", 10, 0, false );
    Kokkyou.text = "国境：自由"
    Main.addChild(Kokkyou); 

    var up:Button   = new Button(14,9, 2, "▲", 9);
    var down:Button = new Button(14,9, 2, "▼", 9);
    up.x = 317;
    up.y = 440;
    down.x = 317;
    down.y = 454;
    Main.addChild(up);
    Main.addChild(down);

    up.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{ KokkyouType--; updateKokkyouType(); } ); 
    down.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{ KokkyouType++; updateKokkyouType(); } ); 
}

function updateKokkyouType():void{
    if( KokkyouType < 0 ) KokkyouType = 2;
    if( KokkyouType > 2 ) KokkyouType = 0;
    switch( KokkyouType ){
    case 0: Kokkyou.text = "国境：封鎖"; break;
    case 1: Kokkyou.text = "国境：検疫"; break;
    case 2: Kokkyou.text = "国境：通常"; break;
    }
}


function update(e :Event):void{      

    var num:int = 0;
    for( var i:int=0; i<5; i++ ) StateAry[i] = 0;

    var agent:Agent;
    for each( agent in AgentAry )  { agent.update(); num++; }
    clearBmp();    
    
    for each( agent  in AgentAry ) agent.draw();

    Time++;
    var date:int = Time/10;
    var n0:String = (StateAry[0]/num*100).toFixed(2);
    var n1:String = (StateAry[1]/num*100).toFixed(2);
    var n2:String = (StateAry[2]/num*100).toFixed(2);
    var n3:String = (StateAry[3]/num*100).toFixed(2);
    var n4:String = (StateAry[4]/num*100).toFixed(2);
    Text0.text = ""+ date +"日目";
    Text1.htmlText = 
        "<font color='#006000'>健康</font>: "+n0+"%   " +
        "<font color='#b0b000'>潜伏</font>: "+n1+"%   " +
        "<font color='#b00000'>発症</font>: "+n2+"%   " +
        "<font color='#003090'>免疫</font>: "+n3+"%   " +
        "<font color='#303030'>死亡</font>: "+n4+"%   " ;
            
}


function clearBmp():void{
    var col:int = 0xc0c0c0;
    for( var x:int=0; x<BITMAP_W; x++){
        for( var y:int=0; y<BITMAP_H; y++){
            BmpData.setPixel(x, y, BgColor);  
        }
    }

    if( KokkyouType <= 1 ){
        col = WallColor;
        if( KokkyouType == 1 ) col = WallColor2;
        for( x=0; x<BITMAP_W; x++){
            BmpData.setPixel(x, 86, col);  
            BmpData.setPixel(x, 87, col);  
            BmpData.setPixel(x, 88, col);  
            BmpData.setPixel(128, x, col);  
            BmpData.setPixel(129, x, col);  
            BmpData.setPixel(130, x, col);  
            BmpData.setPixel(x,201, col);  
            BmpData.setPixel(x,202, col);  
            BmpData.setPixel(x,203, col);  
        }
    }

    for( x=0; x<BITMAP_W; x++){
        BmpData.setPixel(x, 0, WallColor);  
        BmpData.setPixel(x, BITMAP_W-1, WallColor);  
        BmpData.setPixel(0, x, WallColor);  
        BmpData.setPixel(BITMAP_W-1, x, WallColor);  
        if( x<25 || (x>55 && x<170) || (x>178 && x<297) || (x>300) ){
            BmpData.setPixel(x, 85, WallColor);  
            BmpData.setPixel(x, 86, WallColor);  
            BmpData.setPixel(x, 87, WallColor);  
            BmpData.setPixel(x, 88, WallColor);  
            BmpData.setPixel(x, 89, WallColor);  
            BmpData.setPixel(127, x, WallColor);  
            BmpData.setPixel(128, x, WallColor);  
            BmpData.setPixel(129, x, WallColor);  
            BmpData.setPixel(130, x, WallColor);  
            BmpData.setPixel(131, x, WallColor);  
            BmpData.setPixel(x,200, WallColor);  
            BmpData.setPixel(x,201, WallColor);  
            BmpData.setPixel(x,202, WallColor);  
            BmpData.setPixel(x,203, WallColor);  
            BmpData.setPixel(x,204, WallColor);  
        }
    }

}


class Agent{  
    public var X:Number;
    public var Y:Number;
    public var Hp:int, HpMax:int;
    public var Status:int = 0;    // 0:健康 1:潜伏期間 2:発病
     public var CountDown:int = 0;
    public function Agent( x:Number, y:Number, px:Number, py:Number ){  
        do{
            X = x + px*Math.random();
            Y = y + py*Math.random();
        } while( BmpData.getPixel(X, Y) != BgColor );

        Hp = 5000 + Math.random() * 5000;
        AgentAry.push(this);
        if( Math.random() < 0.001 ) Status = 1;
    }

    public function update():void{
        StateAry[Status]++;

        if( Status != 4 ){
            var add:Number = 0;
            if( Status == 2 ) add = kakuri;    // 隔離パラメータ

            var sx:Number = moveRate * (Math.random()*5 - 2.5) + add;
            var sy:Number = moveRate * (Math.random()*5 - 2.5) + add;
            var bgCol:int = BmpData.getPixel(X+sx, Y+sy);
            if( bgCol != WallColor && !(Status == 2 && KokkyouType == 1 && bgCol == WallColor2) ){
                X += sx;
                Y += sy;
                if( X < 2 ) X = 2; 
                if( X > BITMAP_W-4 ) X = BITMAP_W-4; 
                if( Y < 2 ) Y = 2; 
                if( Y > BITMAP_H-4 ) Y = BITMAP_H-4; 
            }  
        }
        if( Status == 0 ){
            if( Hp < HpMax ) {
                Hp+=3;
            }
            if( BmpData.getPixel(X+sx, Y+sy) == ColRed0 ){
                if( Math.random()*100 < kansen ) {    // 感染力
                    Status = 1;
                    CountDown = senpuku * 10;    // 潜伏期間
                }
            }  
        }
        if( Status == 1 ){
            CountDown--;
            if( CountDown <= 0 ) {
                CountDown = hassyou * 10;    // 発症時間
                Status = 2;
            }
        }
        if( Status == 2 ){
            Hp-= dokusei * 10;              // 毒性の強さ
            CountDown--;
            if( CountDown <= 0 ) {
                CountDown = meneki * 10;    // 免疫期間
                Status = 3;
            }
            if( Hp <= 0 ) {
                Status = 4;
            }
        }
        if( Status == 3 ){
            CountDown--;
            if( CountDown <= 0 ) {
                CountDown = 0;    // 
                Status = 0;
            }
        }

    }

    public function draw():void{
        var col0:int, col1:int;
        switch( Status ){
        case 0: col0 = col1 = ColGreen;   break;
        case 1: col0 = col1 = ColYellow;  break;
        case 2: col0 = ColRed0; col1 = ColRed1; break;
        case 3: col0 = col1 = ColBlue;    break;
        case 4: col0 = col1 = ColGray;    break;
        }
        BmpData.setPixel(X,   Y, col0);  
        setPixel(X+1, Y, col1);  
        setPixel(X,   Y+1, col1);  
        setPixel(X+1, Y+1, col1);  
    }
}

function setPixel( x:int, y:int, col:int):void{
    if( BmpData.getPixel(x, y) == BgColor ){    
        BmpData.setPixel(x,y, col);  
    }
}
        


import flash.events.*;
import flash.utils.*;
import flash.text.*;
import flash.ui.Keyboard;

class InputArea {
    public function InputArea( x:int, y:int, str:String, num:String, func:Function ){
        var tx:TextField = new TextField();
        tx.text = str;
        tx.x = x;
        tx.y = y;
        Main.addChild(tx); 

        var textArea:InputTextArea = new InputTextArea(func);
        textArea.x = 1 + x + str.length * 10;
        textArea.y = y;
        textArea.text = num;
        Main.addChild(textArea); 
    }
}

class InputTextArea extends TextField {
    public var Func:Function;
    public var myTimer:Timer = new Timer(2, 1);

    public function InputTextArea( func:Function ) {
        border = true;
        borderColor = 0xCCCCCC;
        width = 24;
        height = 16;
        type = TextFieldType.INPUT;
        restrict = "0-9";
        Func = func;
        var format:TextFormat = new TextFormat( "AXIS Std R", 12, 0, true );
        format.align = "right";
 
        defaultTextFormat = format;
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        addEventListener(Event.CHANGE, function(e:Event):void{Func(text);});


        myTimer.addEventListener(TimerEvent.TIMER, timerHandler);
        addEventListener(FocusEvent.FOCUS_IN, function(e:Event):void{ myTimer.start(); });
    }

    private function timerHandler(e:Event):void {
        setSelection(0, length);
    } 

    private function keyDownHandler(event:KeyboardEvent):void {
        if ( event.keyCode == Keyboard.ENTER ) {
            var inputText:String = text;
            Func(text);
            dispatchEvent( new InputEvent( InputEvent.INPUT_ENTER, inputText ) );
        }
    }
}



flash.events.Event;

class InputEvent extends Event {
    public static const INPUT_ENTER:String = "InputEvent.inputEnter";
    private var _text:String = "";
		
    public function InputEvent(type:String, text:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
        super(type, bubbles, cancelable);
        _text = text;
    } 
		
    public override function clone():Event { 
        return new InputEvent(type, _text, bubbles, cancelable);
    } 
		
    public override function toString():String { 
        return formatToString("InputEvent", "text", "type", "bubbles", "cancelable", "eventPhase"); 
    }
		
    public function get text():String { return _text; }
}


import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.geom.Matrix;
import flash.filters.ColorMatrixFilter;
import flash.filters.GlowFilter;

class Button extends Sprite{
    private static const mono:ColorMatrixFilter = new ColorMatrixFilter([
        1 / 3, 1 / 3, 1 / 3, 0, 10,
        1 / 3, 1 / 3, 1 / 3, 0, 10,
        1 / 3, 1 / 3, 1 / 3, 0, 10,
            0,     0,     0, 1, 0
    ]);

    private var _textField:TextField = new TextField();
    private var _size:int;

    private var _hover:Boolean = false;
    public function get hover():Boolean{
        return _hover;
    }
    public function set hover(value:Boolean):void{
        if(_hover != value){
            _hover = value;
            filters = (_hover ? null : [mono]);
        }
    }

    public function Button(W:Number, H:Number, R:Number, label:String = "", size:int = 11){
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(W, H, Math.PI / 2);

        var bg:Sprite = new Sprite();

        bg.graphics.beginGradientFill("linear", [0x8c99a4, 0xc5d4e1, 0xBAD2E8], [1, 1, 1],
            [0, 120, 136], matrix);
        bg.graphics.drawRoundRect(0, 0, W, H, R, R);
        bg.graphics.endFill();

        bg.filters = [new GlowFilter(0xFFFFBE, .5, 10, 10, 2, 1, true)];
        addChild(bg);

        var line:Sprite = new Sprite();
        line.graphics.lineStyle(3, 0xBAD2E8);
        line.graphics.drawRoundRect(0, 0, W, H, R, R);
        addChild(line);

        filters = [mono];
        buttonMode = true;
        mouseChildren = false;

        if (label != ""){
            _size = size;
            _textField.selectable = false;
            _textField.autoSize = "left";
            _textField.htmlText = <font size={size} color="#4B4349">{label}</font>.toXMLString();
            _textField.x = (W - _textField.width) / 2;
            _textField.y = (H - _textField.height) / 2;
            addChild(_textField);
        }

        addEventListener("rollOver", buttonRollOver);
        addEventListener("rollOut", buttonRollOut);
        addEventListener("removed", function(event:Event):void{
            removeEventListener("rollOver", buttonRollOver);
            removeEventListener("rollOut", buttonRollOut);
            removeEventListener("removed", arguments.callee);
        });
    }
    public function setLabel( label:String ):void{
        _textField.htmlText = <font size={_size} color="#4B4349">{label}</font>.toXMLString();
    }

    protected function buttonRollOver(event:Event):void{
        hover = true;
    }

    protected function buttonRollOut(event:Event):void{
        hover = false;
    }
}

