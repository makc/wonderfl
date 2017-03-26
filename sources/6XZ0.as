package {
    import flash.display.Bitmap;
  import flash.display.Graphics;
  import flash.display.Sprite;
  import flash.display.BitmapData;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.geom.Matrix3D;
  import flash.geom.Rectangle;
  import flash.geom.Vector3D;
  import flash.text.TextField;
  import flash.ui.Keyboard;
 
 
    public class FlashTest extends Sprite {
        public function FlashTest() {
            
            deb = new TextField();
              deb.width = 320; deb.height = 240; deb.mouseEnabled = false;
              deb.textColor = 0xFF0000;
              addChild(deb);
           
              
              miniRend = new xMiniRender();
              addChild(miniRend);
              
              stage.addEventListener(Event.ENTER_FRAME, onEnter);
              miniRend.init();

                stage.addEventListener(MouseEvent.MOUSE_DOWN, click);            
        }//ctor
           
           
         public function click(e:MouseEvent):void
        {
             if (miniRend.cready == false) {  return; }
             if (stage.mouseX < 400) { return;}
             if (stage.mouseY < 400) { return; }
            
            graphics.lineStyle(6,0xFF0000);
            graphics.drawCircle(128,128,128);
            
              var pic:Bitmap;
            pic = new Bitmap(new BitmapData(400,400,false,0));
          
             miniRend.context.clear();
              miniRend.projmat.identity();
              
                 xMiniRender.setLookAtMatrix(miniRend.cammat, cx, cy, cz, cyaw); 
                 xMiniRender.setProjectionMatrix(miniRend.projmat, 90, 1, 0.1, 1000);

                 miniRend.draw2();
            miniRend.context.drawToBitmapData(pic.bitmapData);
                   
            addChild(pic);
            
            //pic.x = 200;
           // pic.y = 100; 
            
        }//click           
           
          public var deb:TextField;
            
          public var miniRend:xMiniRender;
          public var firstRun:Boolean = true;
        
          public var gameTime:int = 0;
            
          public var cx:Number = 0;
          public var cy:Number = 0;
          public var cz:Number = 10; //+ towards viewer  - away from viewer
          public var cyaw:Number = 0;
            
        public function onEnter(e:Event):void
        {
          if (miniRend.cerr) 
          {
              graphics.clear();
              graphics.lineStyle(2,0);
              graphics.drawCircle(128,128, 64);
              deb.text = miniRend.cerr_msg;
           }  
              
          if (miniRend.cready == false) {  return; }
          if (firstRun)
          {
           
            firstRun = false;
            initAsset();
            deb.text = miniRend.context.driverInfo;
          }//endif
     
     
             miniRend.vecEnt[1].visible = true;
             miniRend.vecEnt[1].transmat.identity();
             miniRend.vecEnt[1].transmat.appendRotation(gameTime*3, Vector3D.X_AXIS);
             miniRend.vecEnt[1].transmat.appendTranslation( Math.sin(gameTime*0.1)*8,0,0);
          
            var i:int;
            var a:xEnt;
            for (i =0; i < 16; i++)
            {
              a = miniRend.vecEnt[2+i];
              a.visible = true;
              a.transmat.identity();
              a.transmat.appendTranslation(i-8, Math.sin(i+gameTime*0.05)*4, 0);
              a.setColor(Math.sin(i+gameTime*0.1),Math.cos(gameTime*0.1),1,1);
            }//nexti
          
            //render
              miniRend.context.clear();
              miniRend.projmat.identity();
              
                 xMiniRender.setLookAtMatrix(miniRend.cammat, cx, cy, cz, cyaw); 
                 xMiniRender.setProjectionMatrix(miniRend.projmat, 90, 1, 0.1, 1000);

                 miniRend.draw2();
             miniRend.context.present();
      
            gameTime += 1;
        }//onenter
        
        
        public function initAsset():void
        {
          //F texture for testing
          var bm:BitmapData;
              bm = xTex.getXor(64, 64,  false, true, false);
              bm.noise(2,32,128);
              bm.fillRect(new Rectangle(24, 8, 8, 64), 0xFFffFFff);
              bm.fillRect(new Rectangle(32, 8, 16, 8), 0xFFffFFff);
              bm.fillRect(new Rectangle(32, 8+16, 16, 8), 0xFFffFFff);
              miniRend.initTex(bm, 0);
              
          var g:xGeo;
            g = new xGeo();
              g.initCube(1);
              g.upload(miniRend.context);
            miniRend.vecGeo[0] = g;
   
            //seems easy enough .. not sure if the tex coordinates the right way
            miniRend.vecEnt[0].visible = true;
            miniRend.vecEnt[0].geoid = 0;
            miniRend.vecEnt[0].texid = 0;
            miniRend.vecEnt[0].blend = 0;
            miniRend.vecEnt[0].transmat.appendScale(8, 32, 8);
            miniRend.vecEnt[0].transmat.appendRotation(20, Vector3D.X_AXIS);
            miniRend.vecEnt[0].transmat.appendRotation(25, Vector3D.Y_AXIS);        
            miniRend.vecEnt[0].transmat.appendTranslation(5, 5, -20);
            miniRend.vecEnt[0].texmat.appendScale(3, 3, 3);  
              
              
        }//initasset

        
        
    }//classend
}

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.*;
import flash.display3D.textures.Texture;

internal class xMiniRender extends Sprite
{ 
  
  public var cready:Boolean = false;
  public var cerr:Boolean = false;
  public var cerr_msg:String = "noerror";
  
  public var context:Context3D = null;
  public var scrWidth:int = 400;
  public var scrHeight:int = 400;

  public var prog:Program3D;
 
  public var projmat:Matrix3D = new Matrix3D();
  public var cammat:Matrix3D = new Matrix3D();
  public var mat:Matrix3D = new Matrix3D();
  public var texMat:Matrix3D = new Matrix3D();
  
  
  public var maxEnt:int = 1024;
  public var vecEnt:Vector.<xEnt>;

  public var maxTex:int = 128; //4096 max textures (also 128mb)
  public var vecTex:Vector.<xTex>;
  
  public var maxGeo:int = 1024; //4096 max vertex buffers (2 per geo for now, unoptimised for mem)
  public var vecGeo:Vector.<xGeo>;
  

  public function xMiniRender()
  { 
         

  }//ctor
  
  public function init():void
  {
    stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, contReady);
    stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, onError);
    stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);   
  }//init
  

  public function onError(e:ErrorEvent):void { trace("context error: ", e.text); cerr_msg = e.text; cerr = true; }
  public function contReady(e:Event):void
  {
    context = stage.stage3Ds[0].context3D;
    context.addEventListener(ErrorEvent.ERROR, onError);
    context.configureBackBuffer(scrWidth, scrHeight, 0, true);
    context.enableErrorChecking = true; // false; //set true for debug  false for speed
    initProgram(context);    
    context.setProgram(prog);
    
    vecTex = new Vector.<xTex>(maxTex, false);
    vecGeo = new Vector.<xGeo>(maxGeo, false);
    vecEnt = new Vector.<xEnt>(maxEnt, false);
    var i:int;
    for (i = 0; i < maxEnt; i++) { vecEnt[i] = new xEnt(); }
       
    cready = true;
  }//contready
  
    public function initTex(dat:BitmapData, id:int):void
  {
    //todo -- error handling
    var a:xTex;    
    a = new xTex();
    a.genTex(dat, context);
    vecTex[id] = a;
  }//inittex
  
  
  public function initProgram(c:Context3D):void
  { 
      prog = c.createProgram();
     
      var code:String;
      var vert:ByteArray;
      var frag:ByteArray;
      var assembler:AGALMiniAssembler = new AGALMiniAssembler();
          code = "";
    
           code += "m44 vt0, va0, vc4\n"; //pos * objmatrix
           code += "m44 op, vt0, vc0\n"; // * cammatrix
           code += "m44 v0, va1, vc8\n"  // uv*texture matrix to fragment    
           code += "mov v1, va2\n" // vertex color to fragment
           vert = assembler.assemble(Context3DProgramType.VERTEX, code);
    
          code = "";
          code += "tex ft0 v0, fs0 <2d, linear, miplinear, wrap>\n";
          code += "mul ft1, fc0, v1\n"; //color*vertex color
          code += "mul oc, ft1, ft0\n"; //texture * color
    
          frag = assembler.assemble(Context3DProgramType.FRAGMENT, code);

      prog.upload(vert, frag);
  }//initprogram


  public function draw2():void
  {
    var c:Context3D;
    c = context;
    
    //i insist on the opengl winding order: opengl back face equals context3d front (aka directx front)
    c.setCulling(Context3DTriangleFace.FRONT);
    //c.setCulling(Context3DTriangleFace.BACK);
    
    //combine camera and projection matrix
     mat.identity();
      mat.append(cammat);
      mat.append(projmat);

      c.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mat, true); 

      
    var i:int;    var num:int;    var a:xEnt;
    var g:xGeo;
    var curtexid:int;    curtexid = -1;
    var curblend:int;    curblend = -1;
    
    num = vecEnt.length;
    for (i = 0; i < num; i++)
    {
      a = vecEnt[i];
      if (a.visible == false) { continue; }
      
      g = vecGeo[a.geoid];
      
      if (curtexid != a.texid)
      {
        curtexid = a.texid;
        c.setTextureAt(0, vecTex[curtexid].tex);
      }//endif
      
      if (curblend != a.blend)
      {
        curblend = a.blend;
        if (curblend == 0) // solid
        {
          c.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
          c.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
        }
        else if (curblend == 1) //transparent
        { 
          c.setDepthTest(false, Context3DCompareMode.ALWAYS);
          c.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        }//endif2
        
        //experiment
        if (curblend == 99)
        {
          c.setDepthTest(false, Context3DCompareMode.GREATER);
          c.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); 
          
        }//endif3
      }//endif
        
      c.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, a.transmat, true);
      c.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, a.texmat, true);
      c.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, a.color);

      c.setVertexBufferAt(0, g.bufVert, 0, Context3DVertexBufferFormat.FLOAT_3);    
      c.setVertexBufferAt(1, g.bufUv, 0, Context3DVertexBufferFormat.FLOAT_2);
      c.setVertexBufferAt(2, g.bufColor, 0, Context3DVertexBufferFormat.FLOAT_4);
      c.drawTriangles(g.bufFace, 0, g.numFace);
      //todo -- use entity to check tris to use
      // start index  
      // numtriangles (3 index per tri) ( -1 for render all)
      
    }//nexti
  }//draw2

  public static function setProjectionMatrix(m:Matrix3D,
    fovdeg:Number = 90.0, aspect:Number = 1.0,
    nearp:Number = 0.1, farp:Number=1000.0):void
    {
        var vec:Vector.<Number> = m.rawData;   var f:Number;   var i:int;
        for (i = 0; i < 16; i++) { vec[i] = 0.0;  } 
        f = 1.0 / Math.tan( (fovdeg * (3.1415 / 180.0)) * 0.5 );
        if (nearp == 0) { nearp = 0.0001; }
        if (farp == 0) { farp = 0.0001; }
        vec[0] = f / aspect;            vec[5] = f;
        vec[10] = (farp + nearp) / (nearp - farp);
        vec[14] = (2.0 * farp * nearp) / (nearp - farp);
        vec[11] = -1.0;            vec[15] = 0.0;
        m.rawData = vec;
    }//projmatrix


    public static function setLookAtMatrix(m:Matrix3D,  x:Number, y:Number, z:Number, yaw:Number):void 
        {
          var forwx:Number;     var forwy:Number;    var forwz:Number;
          var sidex:Number;     var sidey:Number;     var sidez:Number;
          var upx:Number;     var upy:Number;     var upz:Number;      
          var i:int;
          var vec:Vector.<Number> = m.rawData;
          
          for (i = 0; i < 16; i++) { vec[i] = 0.0;  } 
          
          forwx = -Math.sin(yaw);          forwy = 0;          forwz = -Math.cos(yaw);   
          upx = 0; upy = 1; upz = 0;        
          sidex = -Math.cos(yaw);          sidey = 0;          sidez = Math.sin(yaw);          
          
          vec[0] = vec[5] = vec[10] = vec[15] = 1.0; 
          vec[0] = -sidex;    vec[4] = -sidey;    vec[8] = -sidez;
          vec[1] = upx;        vec[5] = upy;        vec[9] = upz;
          vec[2] = -forwx;    vec[6] = -forwy;    vec[10] = -forwz;
          
          vec[12] = (-sidex *-x) + (-sidey * -y) + (-sidez * -z);
          vec[13] = (upx *-x) + (upy * -y) + (upz * -z);
          vec[14] = (-forwx *-x) + (-forwy * -y) + (-forwz * -z);
          
          m.rawData = vec;
        }//setlookat

}//classend minirender


internal class xEnt
{
  public var visible:Boolean = false; //skipped if false
  public var transmat:Matrix3D = new Matrix3D(); //3d transformation
  public var texmat:Matrix3D = new Matrix3D(); //texture matrix
  public var color:Vector.<Number> = Vector.<Number>([1.0,1.0,1.0,1.0]);
  public var geoid:int = 0; //0-1024 geometry id to use
  public var texid:int = 0;  //0-127 texture id to render
  public var blend:int = 0; //0 solid   1 transparent   
  
  public function setColor(r:Number, g:Number, b:Number, a:Number):void
  { color[0] = r; color[1] = g; color[2] = b; color[3] = a; }
}//classend xent        


internal class xGeo
{
    public var vecVert:Vector.<Number> ;    public var vecUv:Vector.<Number> ;    public var vecFace:Vector.<uint> ;
    public var vecColor:Vector.<Number>;
    //todo --  vert,uv,color in a single buffer
    public var bufVert:VertexBuffer3D;    public var bufUv:VertexBuffer3D;    
    public var bufColor:VertexBuffer3D;
    public var bufFace:IndexBuffer3D;
    public var numVert:int=0;  public var numFace:int=0;

    //todo -- update
    public function upload(c:Context3D):void
    {
      if (bufVert != null) { bufVert.dispose(); }
      if (bufUv != null) { bufUv.dispose(); }
      if (bufFace != null) { bufFace.dispose(); }
      if (bufColor != null) { bufColor.dispose(); }
     
      numVert = Math.floor( vecVert.length / 3);
      numFace = Math.floor( vecFace.length / 3);
      
      bufVert = c.createVertexBuffer(numVert, 3);
      bufUv = c.createVertexBuffer(numVert, 2);
      bufColor = c.createVertexBuffer(numVert, 4);
      bufFace = c.createIndexBuffer(numFace * 3);
      
    
      bufVert.uploadFromVector(vecVert, 0, numVert);
      bufUv.uploadFromVector(vecUv, 0, numVert);   
      bufColor.uploadFromVector(vecColor, 0, numVert);
      
      bufFace.uploadFromVector(vecFace, 0, numFace * 3);
   
    }//upload
    
  public function initCube(s:Number=1.0):void
  {
    var n:Number;            var pa:Number;
        n = -0.5 * s;            pa = 0.5 * s;
    numFace = 12;    numVert = 24;

    vecFace  = Vector.<uint>([
                1, 0, 2, 1, 2, 3,
                1 + 4, 2 + 4, 0 + 4,  1 + 4, 3 + 4, 2 + 4,
                1 + 8, 2 + 8, 0 + 8,  1 + 8, 3 + 8, 2 + 8,
                1 + 12, 0 + 12, 2 + 12,  1 + 12, 2 + 12, 3 + 12,
                1 + 16, 2 + 16, 0 + 16,  1 + 16, 3 + 16, 2 + 16,
                1 + 20, 0 + 20, 2 + 20,  1 + 20, 2 + 20, 3 + 20
                ]);
        
        vecVert  = Vector.<Number>([
              n,  n,  n,             pa,  n,  n,              n, pa,  n,             pa, pa,  n,             
              n,  n,  pa,             pa,  n,  pa,              n, pa,  pa,             pa, pa,  pa,             
              pa,  n,  n,              pa, pa,  n,              pa,  n,  pa,              pa, pa,  pa,             
              n,  n,  n,              n, pa,  n,              n,  n,  pa,              n, pa,  pa,              
              n,   n,  n,              pa,  n,  n,              n,   n,  pa,              pa,  n,  pa,              
              n,  pa,  n,              pa, pa,  n,              n,  pa,  pa,              pa, pa,  pa
            ]);
                    
            vecUv = Vector.<Number>([
            1.0, 1.0,            0.0, 1.0,            1.0, 0.0,            0.0, 0.0,        
            0.0, 1.0,            1.0, 1.0,            0.0, 0.0,            1.0, 0.0,
            1.0, 1.0,            1.0, 0.0,            0.0, 1.0,            0.0, 0.0,
            0.0, 1.0,            0.0, 0.0,            1.0, 1.0,            1.0, 0.0,                        
            1.0, 0.0,            0.0, 0.0,            1.0, 1.0,            0.0, 1.0,    
            1.0, 1.0,            0.0, 1.0,            1.0, 0.0,            0.0, 0.0
            ]);
      
      var i:int;      var num:int;
      num = numVert * 4;
      vecColor = new Vector.<Number>(num, false);
      for (i = 0; i < num; i++) { vecColor[i] = 1.0; }
      
  }//initbox    
    

};//classend xgeo



internal class xTex
{
  public var tex:Texture = null;
  public static function getXor(w:int, h:int, red:Boolean=true,green:Boolean=true,blue:Boolean=true):BitmapData
  {
      var bm:BitmapData;        var k:int;        var i:int;      
      bm = new BitmapData(w,h,false,0);     
      for (i = 0; i < h; i++)  {   for (k = 0; k < w; k++)      {
              bm.setPixel(k,i, (red ? ((i^k)<<16):0) | (green ? ((i ^ k) << 8):0) | (blue ? (i^k):0));
      }} 
      return bm;
  }//getxor
 
   
    private var tempMat:Matrix = new Matrix();
    public function genTex(bm:BitmapData, c:Context3D):void
    {
      var s:int;   var m:int;  var tmp:BitmapData;
      
      tex = c.createTexture(bm.width, bm.height, Context3DTextureFormat.BGRA, false);
      tex.uploadFromBitmapData( bm , 0);
      
      tempMat.identity();
       m = 1;
       s = bm.width * 0.5;
       
       while (s > 0)
       { 
        tempMat.a = s / bm.width;
        tempMat.d = s / bm.height;
        tmp = new BitmapData(s, s, bm.transparent, 0);
        tmp.draw(bm, tempMat, null, null, null, true);
        tex.uploadFromBitmapData(tmp, m); m += 1;  s *= 0.5; 
       }//wend
        
    }//gentex
    

    
};//classend xtex








