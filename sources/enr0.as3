// マウスで描いた線が動く
//
// 描いた軌跡に沿って進んでいく。
// 速く書いた線は速く、ゆっくり描いた線はゆっくりと。
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
            stage.addEventListener(MouseEvent.MOUSE_UP,    MouseCheckUp);    
            stage.addEventListener(MouseEvent.MOUSE_DOWN,  MouseCheckDown);    
         }  
    }  
}          

import flash.display.Sprite;   
import flash.events.Event; 
import flash.events.MouseEvent;    
import flash.geom.*;
var Main:Sprite;  
var SCREEN_W:Number = 465; 
var SCREEN_H:Number = 465; 

var g_LineLst:Array;

function initialize():void{ 
    g_LineLst = new Array;
}  

function update(e :Event):void{  
    Main.graphics.clear(); 

    if( MouseData & MOUSE_LEFT_TRG ){
        g_LineLst.push( new LineList( new Point( Main.stage.mouseX, Main.stage.mouseY ) ) );
Main.graphics.lineStyle(3,0xd0d000);     
    Main.graphics.moveTo( -10240, 455 );     
    Main.graphics.lineTo( 10240, 455 );        
    }

    if( MouseData & MOUSE_LEFT ){
       g_LineLst[g_LineLst.length-1].addPoint( new Point( Main.stage.mouseX, Main.stage.mouseY ) );
    }

    for( var lp:int=0; lp<g_LineLst.length; lp++ ){
        if( !(lp == g_LineLst.length-1 && MouseData & MOUSE_LEFT) ) g_LineLst[lp].update();
        g_LineLst[lp].draw();
    }


    MouseUpdate(); 
} 


class LineList{  
    public var PosAry:Array; 
    public var StartPnt:int;
    public var Mx:Number= 1.005;
    public function LineList( p:Point ){  
        PosAry = new Array;
        PosAry.push( p );
        PosAry.push( p );
        StartPnt = 0;
    }  

    public function addPoint( p:Point ):void{  
        Main.graphics.lineStyle(3,0xd0d000);
        var l:int = PosAry.length-1;
        var lx:int = PosAry[l-1].x-PosAry[l].x;
        var ly:int = PosAry[l-1].y-PosAry[l].y;
        var len:int = lx*lx + ly*ly;
        var maxLen:int = 1;
        if( len > maxLen*maxLen ){
            PosAry.push( p );
        }else{
            PosAry[l] = p;
        }
    }  

    public function update():void{  
        if( PosAry.length == 0 ) return;
        var mi:int = StartPnt-1;
        var pl:int = StartPnt+1;
        if( mi < 0 ) mi = PosAry.length-1;
        if( pl > PosAry.length-1 ) pl = 0;
        var lx:int = PosAry[mi].x - PosAry[StartPnt].x;
        var ly:int = PosAry[mi].y - PosAry[StartPnt].y;
        PosAry[StartPnt].x = PosAry[pl].x + (lx * Mx);
        PosAry[StartPnt].y = PosAry[pl].y + (ly * Mx);

        StartPnt++;

        if( StartPnt > PosAry.length-1 ) {
            var del:int = PosAry.length/20 + 1;
            PosAry.splice(PosAry.length-del,del);
            StartPnt = 0;
        }
    }

    public function draw():void{  
        if( PosAry.length == 0 ) return;

        var s:int = StartPnt;

        var size:Number;

        var minX:int = 99999999;
        var minY:int = 99999999;
        var maxX:int = -99999999;
        var maxY:int = -99999999;
        for( var i:int=0; i<PosAry.length-1; i++ ){
            size = i / 8.0;
            if( size > 5.0 ) size = 5.0;
            if( size < 1.5 ) size = 1.5;
            var col:int = 0x40 * (PosAry.length-i) / PosAry.length + 0x60;
            var c:int = (col << 16) + (col << 8) + col;
            Main.graphics.lineStyle(size,c);     

            if( minX > PosAry[s].x ) minX = PosAry[s].x;
            if( minY > PosAry[s].y ) minY = PosAry[s].y;
            if( maxX < PosAry[s].x ) maxX = PosAry[s].x;
            if( maxY < PosAry[s].y ) maxY = PosAry[s].y;
            Main.graphics.moveTo( PosAry[s].x, PosAry[s].y );     
            s++;
            if( s > PosAry.length-1 ) s = 0;
            Main.graphics.lineTo( PosAry[s].x, PosAry[s].y );
            if( s > PosAry.length-1 ) s = 0;
        }
        
        size = PosAry.length/2;
        if( size > 3.5 ) size = 3.5;
        Main.graphics.lineStyle(0,0xc0c0c0);        
        Main.graphics.beginFill(0x000000,1);    
        Main.graphics.drawCircle(PosAry[s].x,PosAry[s].y, size);    
        Main.graphics.endFill();    

        var a:int;
        if( minX > SCREEN_W ){
            a = SCREEN_W + maxX - minX;
            for( i=0; i<PosAry.length; i++ ){
                PosAry[i].x -= a;
            }
        }
        if( minY > SCREEN_H ){
            a = SCREEN_H + maxY - minY;
            for( i=0; i<PosAry.length; i++ ){
                PosAry[i].y -= a;
            }
        }
        if( maxX < 0 ){
            a = SCREEN_W + maxX - minX;
            for( i=0; i<PosAry.length; i++ ){
                PosAry[i].x += a;
            }
        }
        if( maxY < 0 ){
            a = SCREEN_H + maxY - minY;
            for( i=0; i<PosAry.length; i++ ){
                PosAry[i].y += a;
            }
        }

    }  

}  



var MOUSE_LEFT:int = 0x01;   
var MOUSE_LEFT_TRG:int = 0x02;   
var MouseData:int;   
function MouseCheckDown(event:MouseEvent):void{   
    MouseData |= MOUSE_LEFT;   
    MouseData |= MOUSE_LEFT_TRG;   
}            

function MouseCheckUp(event:MouseEvent):void{   
    MouseData &= ~MOUSE_LEFT;   
}            

function MouseUpdate():void{   
    MouseData &= ~MOUSE_LEFT_TRG;   
} 
