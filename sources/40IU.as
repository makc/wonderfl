//
//　カーソルキーで左右移動
//  左クリックで引っ張る
//
//    http://game.g.hatena.ne.jp/Nao_u/20090416
//
package {
    import flash.display.Sprite;
    import flash.events.*;
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="60")] 
   
    public class FlashTest extends Sprite {
        public function FlashTest() {
            Main = this;
            initialize();
            stage.addEventListener(Event.ENTER_FRAME,update); 
            stage.addEventListener(KeyboardEvent.KEY_UP,   keyCheckUp); 
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyCheckDown); 
            stage.addEventListener(MouseEvent.MOUSE_UP,    MouseCheckUp); 
            stage.addEventListener(MouseEvent.MOUSE_DOWN,  MouseCheckDown); 
        }
    }
}        

var Main:Sprite;
var PointAry:Vector.<MovePoint> = new Vector.<MovePoint>;
var ConnectAry:Vector.<Connect> = new Vector.<Connect>;
var MousePos:Object = new Object;

import flash.display.Sprite; 
import flash.events.Event;
import flash.events.KeyboardEvent; 
import flash.events.MouseEvent; 
import flash.ui.Keyboard; 

function initialize():void{
    createModel();
}

function createModel():void{
    var i:int;
    var c0:int = 0xb0b000;
    var c1:int = 0xd0d000;
    var pa:Vector.<MovePoint> = new Vector.<MovePoint>;
    var ca:Vector.<Connect> = new Vector.<Connect>;

    addPoint(    0.0, -102.0, pa );    // 0
    addPoint(    0.0, -124.0, pa );    // 1

    addPoint(   71.0, -124.0, pa );    // 2

    addPoint(  129.0, -142.0, pa );    // 3
    addPoint(   57.0, -184.0, pa );    // 4
    addPoint(  116.0, -205.0, pa );    // 5
    addPoint(   93.0,  -64.0, pa );    // 6
    addPoint(   28.0, -270.0, pa );    // 7

    addPoint(  -71.0, -124.0, pa );    // 8

    addPoint( -129.0, -142.0, pa );    // 9
    addPoint(  -57.0, -184.0, pa );    // 10
    addPoint( -116.0, -205.0, pa );    // 11
    addPoint(  -93.0,  -64.0, pa );    // 12
    addPoint(  -28.0, -270.0, pa );    // 13


    addPoint(    0.0, -146.0, pa );    // 14

    addPoint(  129.0, -106.0, pa );    // 15
    addPoint(   93.0, -181.0, pa );    // 16
    addPoint(  153.0, -165.0, pa );    // 17
    addPoint(   55.0,  -62.0, pa );    // 18
    addPoint(  117.0, -270.0, pa );    // 19

    addPoint( -129.0, -106.0, pa );    // 20
    addPoint(  -93.0, -181.0, pa );    // 21
    addPoint( -153.0, -165.0, pa );    // 22
    addPoint(  -55.0,  -62.0, pa );    // 23
    addPoint( -117.0, -270.0, pa );    // 24

    addPoint(   22.0, -124.0, pa );    // 25
    addPoint(  -22.0, -124.0, pa );    // 26
    

    addConnect( 0, 1, c0, pa, ca);
    addConnect( 1,14, c0, pa, ca);

    addConnect( 1, 2, c0, pa, ca);
    addConnect( 1, 8, c0, pa, ca);

    addConnectM( 2, 8, 1, c1, pa, ca);

    addConnect( 0, 4, c0, pa, ca);
    addConnect( 0, 6, c0, pa, ca);
    addConnect( 2, 3, c0, pa, ca);
    addConnect( 2, 4, c0, pa, ca);
    addConnect( 2, 6, c0, pa, ca);
    addConnect( 3, 5, c0, pa, ca);
    addConnect( 3, 6, c0, pa, ca);
    addConnect( 4, 5, c0, pa, ca);
    addConnect( 4, 7, c0, pa, ca);
    addConnect( 5, 7, c0, pa, ca);

    addConnect( 0,10, c0, pa, ca);
    addConnect( 0,12, c0, pa, ca);
    addConnect( 8, 9, c0, pa, ca);
    addConnect( 8,10, c0, pa, ca);
    addConnect( 8,12, c0, pa, ca);
    addConnect( 9,11, c0, pa, ca);
    addConnect( 9,12, c0, pa, ca);
    addConnect(10,11, c0, pa, ca);
    addConnect(10,13, c0, pa, ca);
    addConnect(11,13, c0, pa, ca);

    addConnect( 2,18, c0, pa, ca);

    addConnect(14,16, c1, pa, ca);
    addConnect(14,18, c1, pa, ca);
    addConnect( 2,15, c1, pa, ca);
    addConnect( 2,16, c1, pa, ca);
    addConnect( 2,18, c1, pa, ca);
    addConnect(15,17, c1, pa, ca);
    addConnect(15,18, c1, pa, ca);
    addConnect(16,17, c1, pa, ca);
    addConnect(16,19, c1, pa, ca);
    addConnect(17,19, c1, pa, ca);

    addConnect(14,21, c1, pa, ca);
    addConnect(14,23, c1, pa, ca);
    addConnect( 8,20, c1, pa, ca);
    addConnect( 8,21, c1, pa, ca);
    addConnect( 8,23, c1, pa, ca);
    addConnect(20,22, c1, pa, ca);
    addConnect(20,23, c1, pa, ca);
    addConnect(21,22, c1, pa, ca);
    addConnect(21,24, c1, pa, ca);
    addConnect(22,24, c1, pa, ca);

    addConnect( 0,14, c1, pa, ca);

    addConnect(25,14, c1, pa, ca);
    addConnect(25, 0, c1, pa, ca);
    addConnect(25, 1, c1, pa, ca);
    addConnect(26,14, c1, pa, ca);
    addConnect(26, 0, c1, pa, ca);
    addConnect(26, 1, c1, pa, ca);
    
    for each( var p:MovePoint in pa ) PointAry.push( p );
    for each( var c:Connect   in ca ) ConnectAry.push( c );
}

var m0:Number = 100;
var m1:Number =-350;
var m2:Number =-700;
var mh:Number = 100;
var friction:Number = 0.6;    

function addPoint( x:Number, y:Number, pa:Vector.<MovePoint> ):void{
    var ofsX:Number = 250.0;
    var ofsY:Number = 0.0;
    var pnt:MovePoint = new MovePoint( Main, x+ofsX, -y+ofsY, false );
    pa.push(pnt);
}

function addConnect( st:int, ed:int, col:int, pa:Vector.<MovePoint>, ca:Vector.<Connect> ):void{
    var cnt:Connect = new Connect( Main, col, pa[st], pa[ed] );
    ca.push(cnt);
}

function addConnectM( st:int, ed:int, mid:int, col:int, pa:Vector.<MovePoint>, ca:Vector.<Connect> ):void{
    var cnt:Connect = new Connect( Main, col, pa[st], pa[ed], pa[mid] );
    ca.push(cnt);
}


function update(e :Event):void{
    Main.graphics.clear(); 
    MousePos.x = Main.stage.mouseX; 
    MousePos.y = Main.stage.mouseY; 
    
    var cnt:Connect;
    var pnt:MovePoint;
    var gravity:Number = 0.03;
    for each( pnt in PointAry ) pnt.addSpeed(0,gravity);
    
    var j:int;
    for( var i:int=0; i<20; i++){
        var num:int = ConnectAry.length;
        for( j=0; j<num; j++)    ConnectAry[j].update();
        for( j=num-1; j>=0; j--) ConnectAry[j].update();
        for each( pnt in PointAry ) pnt.update();
    }

    Main.graphics.lineStyle(3,0xd0d000);   
    Main.graphics.moveTo( -10240, 400 );   
    Main.graphics.lineTo( 10240, 400 );  
    for( i=0; i<40; i++ ){
        Main.graphics.moveTo( (i-10)*150, 400 );   
        Main.graphics.lineTo( (i-10)*150, 410 );   
    }
    Main.graphics.moveTo(  m0, 400 );   
    Main.graphics.lineTo(  m1, 400 - mh );   
    Main.graphics.lineTo(  m2, 400 );   
    
    Main.x -= (Main.x - (-PointAry[0].Pos.x + (465/2))) * 0.06;

    for each( cnt in ConnectAry ) cnt.draw();
    addPower();
    for each( pnt in PointAry ) pnt.draw();
}

function addPower():void{
    var pow:Number = 0.0035;
    var pnt:MovePoint = PointAry[1];
    var vx:Number = ((MousePos.x-Main.x) - pnt.Pos.x) * pow;
    var vy:Number = ((MousePos.y)        - pnt.Pos.y) * pow * 4;
    if( MouseData & MOUSE_LEFT ){
        PointAry[1].addSpeed( vx, vy );
        PointAry[2].addSpeed( vx*0.3, vy*0.3 );
        PointAry[8].addSpeed( vx*0.3, vy*0.3 );
        Main.graphics.lineStyle(0,0xff0000);   
        Main.graphics.moveTo( pnt.Pos.x, pnt.Pos.y );   
        Main.graphics.lineTo( MousePos.x-Main.x, MousePos.y );   
    }

    var rot:Number = 0.0;
    if( KeyData & KEY_LEFT )  rot =  1.0;
    if( KeyData & KEY_RIGHT ) rot = -1.0;

    addPowerTurn( rot,  0, 14 );
    addPowerTurn( rot, 26, 25 );
}

function addPowerTurn( rot:Number, p1:int, p2:int ):void{
    var pnt0:MovePoint  = PointAry[p1];
    var pnt1:MovePoint  = PointAry[1];
    var pnt14:MovePoint = PointAry[p2];

    var vx:Number = pnt0.Pos.x - pnt1.Pos.x;
    var vy:Number = pnt0.Pos.y - pnt1.Pos.y;
        
    var arwPow:Number = 0.0065 * rot;
    var ax:Number =  vy * arwPow;
    var ay:Number = -vx * arwPow;
    
    pnt0.Pos.x += ax;
    pnt0.Pos.y += ay;

    Main.graphics.lineStyle(0,0xff6060);   
    Main.graphics.moveTo( pnt0.Pos.x, pnt0.Pos.y );   
    Main.graphics.lineTo( pnt0.Pos.x + ax * 100, pnt0.Pos.y + ay * 100 );   

    ax *= -1;
    ay *= -1;
    pnt14.Pos.x += ax;
    pnt14.Pos.y += ay;

    Main.graphics.lineStyle(1,0x6060ff);   
    Main.graphics.moveTo( pnt14.Pos.x, pnt14.Pos.y );   
    Main.graphics.lineTo( pnt14.Pos.x + ax * 100, pnt14.Pos.y + ay * 100 );   
}


class MovePoint{
    private var Sp:Sprite;
    public var Pos:Object = new Object;
    public var Prev:Object = new Object;
    public var IsFix:Boolean;
    public var Parent:Sprite;

    public function MovePoint( parent:Sprite, x:Number, y:Number, isFix:Boolean ){
        Pos.x = Prev.x = x;
        Pos.y = Prev.y = y;
        IsFix = isFix;
        Sp=new Sprite();  
        Sp.graphics.beginFill(0xb0a000,1);  
        Sp.graphics.drawCircle(0,0,2.5);  
        Sp.graphics.endFill();  
        Sp.x = Pos.x;
        Sp.y = Pos.y;
        parent.stage.addChild(Sp); 
        Parent = parent;

    }

    public function update():void {
        if( IsFix == true ){
            Pos.x = Prev.x;
            Pos.y = Prev.y;
            return;
        }
        var sx:Number = Pos.x - Prev.x;
        var sy:Number = Pos.y - Prev.y;
        Prev.x = Pos.x;
        Prev.y = Pos.y;
        
        Pos.x += sx * 0.997;
        Pos.y += sy * 0.997;

        if( Pos.y > 400 ) {
            Pos.x += (Prev.x - Pos.x) * friction;
            Pos.y = 400;        
        }
        if( Pos.x < m0 && Pos.x > m2) {
            var st:Number, ed:Number, ratio:Number, height:Number;
            if( Pos.x > m1 ){
                st =  m0;
                ed = m1;
                ratio = (st - Pos.x) / (st-ed);
                height = 400 - ratio * mh;

                if( Pos.y > height ){
                    Pos.x += (Prev.x - Pos.x) * friction;
                    Pos.y = height;        
                }
            }
            else if( Pos.x > m2 ){
                st = m1;
                ed = m2;
                ratio = (st - Pos.x) / (st-ed);
                height = 400 - (1.0-ratio) * mh;

                if( Pos.y > height ){
                    Pos.x += (Prev.x - Pos.x) * friction;
                    Pos.y = height;        
                }
            }
        }
    }
    
    public function addSpeed( px:Number, py:Number ):void{
        Pos.x += px;
        Pos.y += py;
    }

    public function draw():void {
        Sp.x = Pos.x + Main.x;
        Sp.y = Pos.y;   
    }
}

class Connect{
    public var Parent:Sprite;
    public var St:MovePoint;
    public var Ed:MovePoint;
    public var Mid:MovePoint;
    public var Length:Number;
    public var Color:int
    public function Connect( parent:Sprite, col:int, st:MovePoint, ed:MovePoint, mid:MovePoint=null ){
            parent.graphics.beginFill(0xFFFF00,1);   
            parent.graphics.drawRect(0,0,256,256);   
            parent.graphics.endFill();   
        Color = col;
        St = st;
        Ed = ed;
        Mid = mid;
        
        var vx:Number = Ed.Pos.x - St.Pos.x;
        var vy:Number = Ed.Pos.y - St.Pos.y;
        Length = Math.sqrt( vx*vx + vy*vy );
        Parent = parent; 
    }

    public function update():void {
        var vx:Number = Ed.Pos.x - St.Pos.x;
        var vy:Number = Ed.Pos.y - St.Pos.y;
        var hx:Number = St.Pos.x + vx * 0.5;
        var hy:Number = St.Pos.y + vy * 0.5;
        var length:Number = Math.sqrt( vx*vx + vy*vy );
        vx /= length;
        vy /= length;
        
        var m:Number = 0.00;
        if( length > Length-m && length < Length+m ){
        }else{
            if( length > Length ) length = Length+m;
            else                  length = Length-m;

            var ratio:Number = 1.0;
            St.Pos.x -= (St.Pos.x - (hx - vx * length * 0.5)) * ratio;
            St.Pos.y -= (St.Pos.y - (hy - vy * length * 0.5)) * ratio;

            Ed.Pos.x -= (Ed.Pos.x - (hx + vx * length * 0.5)) * ratio;
            Ed.Pos.y -= (Ed.Pos.y - (hy + vy * length * 0.5)) * ratio;
        }

        if( Mid != null ){
            var ratio2:Number = 0.15;
            Mid.Pos.x -= (Mid.Pos.x - hx) * ratio2;
            Mid.Pos.y -= (Mid.Pos.y - hy) * ratio2;
        }
    }

    public function draw():void {
        Parent.graphics.lineStyle(4,Color);   
        Parent.graphics.moveTo( St.Pos.x, St.Pos.y );   
        Parent.graphics.lineTo( Ed.Pos.x, Ed.Pos.y );   
    }
}





var KEY_UP:int    = 0x01;
var KEY_DOWN:int  = 0x02;
var KEY_LEFT:int  = 0x04;
var KEY_RIGHT:int = 0x08;
var KeyData:int;
function keyCheckDown(event:KeyboardEvent):void { 
    switch (event.keyCode){ 
        case Keyboard.UP:	    KeyData |= KEY_UP; break;
        case Keyboard.DOWN:	    KeyData |= KEY_DOWN; break;
        case Keyboard.LEFT:    KeyData |= KEY_LEFT; break;
        case Keyboard.RIGHT:   KeyData |= KEY_RIGHT; break;
    }
} 
function keyCheckUp(event:KeyboardEvent):void { 
    switch (event.keyCode){ 
        case Keyboard.UP:      KeyData &= ~KEY_UP; break;
        case Keyboard.DOWN:    KeyData &= ~KEY_DOWN; break;
        case Keyboard.LEFT:    KeyData &= ~KEY_LEFT; break;
        case Keyboard.RIGHT:   KeyData &= ~KEY_RIGHT; break;
    }
} 

var MOUSE_LEFT:int = 0x01;
var MouseData:int;
function MouseCheckDown(event:MouseEvent):void{
    MouseData |= MOUSE_LEFT;
}         

function MouseCheckUp(event:MouseEvent):void{
    MouseData &= ~MOUSE_LEFT;
}         

