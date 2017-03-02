package {
    import flash.geom.Vector3D;
    import flash.geom.Matrix3D;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.display.Sprite;
    public class FlashTest extends Sprite {
        public function FlashTest() {
             
           var a:xVert;
              vecVert = new Vector.<xVert>(0, false);
              vecBuff = myDraw.initVert(1024);
        
          var n:int;
              n = 16;
          
          //body
          makeBlob(vecVert, 32,    0, 0, 0,    0,  32, 64);
          makeBlob(vecVert, n,    0, -40, 0,    0xDF,  32, 64);
          makeBlob(vecVert, n,    0, -80, 0,    0xDF,  32, 64);
            
            //arm
            makeBlob(vecVert, n,    -40, -80, 0,    0xFF,  32, 64);
            makeBlob(vecVert, n,    -80, -80, 0,    0xFF,  32, 64);
            makeBlob(vecVert, n,    -90, -40, 0,    0x349142,  32, 32);
            makeBlob(vecVert, n,    -90, 0, 0,    0x348142,  32, 32);
            
            //arm
            makeBlob(vecVert, n,    40, -80, 0,    0xFF,  32, 48);
            makeBlob(vecVert, n,    80, -80, 0,    0xFF,  32, 48);
            makeBlob(vecVert, n,    90, -40, 0,    0x349142,  32, 32);
            makeBlob(vecVert, n,    90, 0, 0,    0x348142,  32, 32);
            
            //leg
             makeBlob(vecVert, n,    -40, 40, 0,    0,  32, 32);
             makeBlob(vecVert, n,    -40, 80, 0,    0,  32, 32);
             makeBlob(vecVert, n,    -40, 120, 0,    0,  32, 32);
             makeBlob(vecVert, n,    -40, 130, 0,    0,  32, 32);
             makeBlob(vecVert, n,    -40, 135, 20,    0,  32, 32);
          
            //leg
             makeBlob(vecVert, n,    40, 40, 0,    0,  32, 32);
             makeBlob(vecVert, n,    40, 80, 0,    0,  32, 32);
             makeBlob(vecVert, n,    40, 120, 0,    0,  32, 32);
             makeBlob(vecVert, n,    40, 130, 0,    0,  32, 32);
             makeBlob(vecVert, n,    40, 135, 20,    0,  32, 32);
             
           
          //head
            makeBlob(vecVert, 32,    0, -140, 0,    0x349142,  24, 48);
            makeBlob(vecVert, 32,    0, -160, 0,    0x247132,  24, 48);
             
          //eye
              makeBlob(vecVert, 4,    23, -160, 24,    0,  8, 8);
              makeBlob(vecVert, 4,    -23, -160, 24,    0,  8, 8);
         
          //nose
             makeBlob(vecVert, 8,    0, -150, 48,    0xFF0080,  16, 16);
         
            //buttons
              makeBlob(vecVert, 4,   0, -90, 40,    0,  8, 8);
              makeBlob(vecVert, 4,   0, -70, 40,    0,  8, 8);
              makeBlob(vecVert, 4,   0, -50, 40,    0,  8, 8);
        
              stage.addEventListener(Event.ENTER_FRAME, onEnter);
        }//ctor
        
        public var gameTime:int = 0;
        
        public var myDraw:xVertDraw = new xVertDraw();
        
        public var tempMat:Matrix3D = new Matrix3D();
        
        public var vecBuff:Vector.<xVert>;
        public var vecVert:Vector.<xVert> = new Vector.<xVert>(0, false);
        public static var vecIdent:Vector.<Number> = Vector.<Number>([
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1]);
        
           
        public function makeBlob(vec:Vector.<xVert>, num:int, 
        ax:Number, ay:Number, az:Number, c:uint, br:Number=8, r:Number=16):void
        {
          var i:int;
          var kx:Number; var ky:Number; var kz:Number;
         
          
          for (i = 0; i < num; i++)
          {
            kx = Math.random() * r - (r *0.5);
            ky = Math.random() * r - (r *0.5);
            kz = Math.random() * r - (r * 0.5);
            vec.push(new xVert(ax + kx, ay + ky, az + kz, br, c) );
          }//nexti      
        }//makecube
    
        
        public function onEnter(e:Event):void
        {
          var it:int;
          
          graphics.clear();
          
          //it = projectVert(vecVert, vecIdent, 0, vecBuff); 
          
          tempMat.identity();
          tempMat.appendRotation(120+gameTime*6, Vector3D.Y_AXIS, null);
          
          var w:Number;
          w = gameTime * 0.01;
          tempMat.appendRotation(Math.sin(w)*Math.cos(w)*32, Vector3D.X_AXIS, null);
          
          vecIdent = tempMat.rawData;
          it = myDraw.projectVert(vecVert, vecIdent, 0, vecBuff); 
        
          myDraw.sortVert(vecBuff, it);
          myDraw.renderVert(graphics, vecBuff, it, 225,225);
          
          
          gameTime += 1;
        }//onenter
            
        
        
    }//classend
}

import flash.display.Graphics;

internal class xVertDraw
{
  
  
      //create a vert buffer
    public function initVert(num:int):Vector.<xVert>
    {
      var ret:Vector.<xVert>;      var i:int;
      ret = new Vector.<xVert>(num, false);
      for (i = 0; i < num; i++) { ret[i] = new xVert(); }
      return ret;
    }//initvert
    
 
    
    //g -- graphics to render to
    //vec -- buffer of verts
    //num -- number of verts to render (less or equal to vec.length)
    //ax ay -- center of screen
    public function renderVert(g:Graphics, vec:Vector.<xVert>, num:int, ax:Number=320,ay:Number=240):void
    {
      var a:xVert;       var i:int;     
      
      num = vec.length;
      //g.lineStyle(2, 0);
      
      for (i = 0; i < num; i++)
      {
        a = vec[i];
        g.beginFill(a.col, a.sw);
          //g.drawCircle(a.sx + ax, a.sy + ay, a.sr);
          g.drawRect(a.sx +ax-a.sr*0.5, a.sy + ay-a.sr*0.5, a.sr, a.sr);
        g.endFill();
      }//nexti
      
    }//rendervert
    
    
    //vec -- verts to project
    //mat -- projection matrix (combined with view matrix)
    //st -- iterator for tv
    //tv buffer of projected verts
    public function projectVert(vec:Vector.<xVert>, mat:Vector.<Number>, st:int, tv:Vector.<xVert>  ):int
    {
      var a:xVert; var b:xVert;
      var i:int;
      var num:int; var tnum:int;
      var w:Number;
      var sz:Number;
      
      num = vec.length;
      tnum = tv.length;
      
      for (i = 0; i < num; i++)
      {
        a = vec[i];
        w = a.cx * mat[3] + a.cy * mat[7] + a.cz * mat[11] + mat[15];          
        if (w <= 0) { continue; } 
        //trace("w ",w,w*16384);
       // trace("z ", a.cz, a.cz+8192);

        b = tv[st]; 

        b.sx = a.cx * mat[0] + a.cy * mat[4] + a.cz * mat[8] + mat[12];
        b.sy = a.cx * mat[1] + a.cy * mat[5] + a.cz * mat[9] + mat[13]; 
        sz = a.cx * mat[2] + a.cy * mat[6] + a.cz * mat[10] + mat[14]; 
        b.sx /= w;        b.sy /= w;
        b.sr = a.rad; //todo -- calculate projected radius
        b.col = a.col;
        b.sortCode = 65536 - int( sz + 16384);  //cheating -- sort by z coordinate (no camera pos yet)
        //b.sortCode =( a.cz + 8192);
        //b.sortCode = Math.random() * 65536;
        
       // trace("sortcode ", a.cz, b.sortCode);
        b.sw = 1.0 - ((sz+100)*0.005) +0.3   //w;
       // b.sw = 1;
        
        st += 1; if (st >= tnum) { return st; }
      }//nexti
      
      return st;
    }//project

    
    public function sortVert(vec:Vector.<xVert>, num:int):void
    {
      radixSortVert(vec, num);
    }//sortvert
  
    public var tempVec:Vector.<xVert> = new Vector.<xVert>(8192, false);
    public var tempBuck:Vector.<int> = new Vector.<int>(256, false);

    public function radixSortVert(vec:Vector.<xVert>, num:int):void
    {
      var a:xVert;          var temp:Vector.<xVert>;          var buck:Vector.<int>;
      var i:int;          var k:uint;          var shift:int;          var g:int;

      if (vec.length < num) { num = vec.length; }
      temp = tempVec;    if (temp.length < num) { return; }
      buck = tempBuck;    shift = 0;
        
      while (shift < 32)  {   
        for (k = 0; k < 256; k++) { buck[k] = 0; }      //reset bucket
        for (i = 0; i < num; i++)  {  g = (vec[i].sortCode >> shift) &0xFF;  buck[g]++; }              
        for (i = 1; i < 256; i++)   {  buck[i] += buck[i - 1];  }               
        for (i = num - 1; i >= 0; i--)  { g = (vec[i].sortCode >> shift) &0xFF;  temp[--buck[g] ] = vec[i];  }        
        for (i = 0; i < num; i++) { vec[i] = temp[i];   }
        shift += 8; 
      }//wend
    }//radixsort  
  

}//vertdraw


internal class xVert
{
  public function xVert(ax:Number = 0, ay:Number = 0, az:Number = 0, ar:Number = 4, c:uint = 0)
  {
    cx = ax; cy = ay; cz = az; rad = ar; col = c;
  }//ctor
  
  
  public var cx:Number = 0;
  public var cy:Number = 0;
  public var cz:Number = 0;
  public var rad:Number = 8;
  public var col:uint = 0;
  
  public var sx:Number = 0;
  public var sy:Number = 0;
  public var sr:Number = 0;
  public var sw:Number = 1;
  public var sortCode:int = 0;
  
}//xvert
