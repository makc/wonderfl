package {
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {

            stage.quality = StageQuality.LOW;

            vecBlob = new Vector.<xBlob>(0, false);
            var a:xBlob;
             var i:int;
             for(i=0;i<256;i+=1)
             {
                 a = new xBlob();
                 a.cx = 320; a.cy = 320;
                 vecBlob.push(a);
                 a.cx = 30 + Math.random()*250;
                 a.cy = 30+ Math.random()*250;
                 a.id = i+1;
             }//nexti
             
             
             mw = 48;
             mh = 48;
             vecGrid = new Vector.<int>(mw*mh, false);
             
             cw= 32; ch=32;
             cw=8; ch=8;
             cw=16;ch=16;
             
             for (i=0;i<64;i+=1)
             {
               setGrid(Math.random()*mw,Math.random()*mw , -1);  
               setGrid(i/4, 12, -1);
             }

            stage.addEventListener(Event.ENTER_FRAME, onEnter);            
        }//ctor
        
        public var vecBlob:Vector.<xBlob>;
        
        public var vecGrid:Vector.<int>;
        public var mw:int=  1;
        public var mh:int = 1;
        public var cw:Number = 16;
        public var ch:Number = 16;
        
        public function setGrid(ax:int, ay:int, t:int):void
        { if (ax<0||ax>=mw||ay<0||ay>=mh){return;} vecGrid[ax+(ay*mw)]=t; }
        
        public function getGrid(ax:int, ay:int):int
        { if (ax<0||ax>=mw||ay<0||ay>=mh){return 1;} return vecGrid[ax+(ay*mw)]; }
        
        public function setTile(ax:Number, ay:Number, t:int):void
        { setGrid(Math.floor(ax/cw),Math.floor(ay/ch), t);    }
        
        public function isTile(ax:Number, ay:Number):Boolean
        { return getGrid(Math.floor(ax/cw),Math.floor(ay/ch)) != 0; }

        public function getTile(ax:Number, ay:Number):int
        {  return getGrid(Math.floor(ax/cw),Math.floor(ay/ch));    }

        
        public function getMag(ax:Number,ay:Number):Number
        { return Math.sqrt(ax*ax+ay*ay); }
        
        public function onEnter(e:Event):void
        {
           graphics.clear();
           graphics.lineStyle(2, 0); 
            
            mx = stage.mouseX;
            my = stage.mouseY;

           var yt:int; var t:int;
           for (i=0;i<mh;i+=1)
           { yt=i*mw;
            for (k=0;k<mw;k+=1)
            {
               t = vecGrid[yt+k];
               if (t>0)
               { graphics.drawRect(k*cw,i*ch, cw,ch); } 
               else if (t<0)
               {
                 graphics.beginFill(0, 1);
                 graphics.drawRect(k*cw,i*ch, cw,ch);
                 graphics.endFill();   
               }
            }//nextk
           }//nexti

            
            var ta:Number; var ms:Number;
            var mx:Number; var my:Number;
            var ax:Number; var ay:Number;
           var a:xBlob;  var d:Number;
           var i:int; var k:int; var num:int; 
            num = vecBlob.length;
           for(i=0;i<num;i+=1)
           {
             a = vecBlob[i];
             
             if (getTile(a.cx, a.cy)==a.id)
             {  setTile(a.cx,a.cy, 0);  }
             ms = 2;
             d = getMag(a.cx-mx, a.cy-my);
             if (ms>d){ms=d;}
                ta = Math.atan2(my-a.cy, mx-a.cx);
                ax = Math.cos(ta)*ms;
                ay = Math.sin(ta)*ms;
                
                if (getTile(a.cx, a.cy) >= 0)
                {
                if (isTile(a.cx+4, a.cy) && ax > 0){ ax=0;}
                if (isTile(a.cx-4, a.cy) && ax < 0){ ax=0;}
                if (isTile(a.cx, a.cy+4) && ay > 0){ ay=0;}
               if (isTile(a.cx, a.cy-4) && ay < 0){ ay=0;}
                }
                
                a.cx += ax;
                a.cy +=ay;
             if (isTile(a.cx,a.cy)==false)
             {  setTile(a.cx,a.cy, a.id); }


            graphics.beginFill(0xFFffFF, 1);
             graphics.drawCircle(a.cx, a.cy, 8);  
            graphics.endFill(); 
            graphics.moveTo(a.cx,a.cy);
            graphics.lineTo(a.cx+Math.cos(ta)*8,a.cy+Math.sin(ta)*8);
             
           }//nexti
           
           graphics.drawRect(0,0, mw*cw,mh*ch); 
           
           
            
        }//onenter
        
    }//classend
}

internal class xBlob
{
 public var cx:Number = 0;
 public var cy:Number = 0;   
 public var id:int = 0;   
}//xblob