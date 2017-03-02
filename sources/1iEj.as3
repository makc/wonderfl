package {
  
  import flash.display.*;
  import com.bit101.components.*;
  import flash.display3D.textures.Texture;
  import flash.display3D.*;
  import flash.events.Event;
  import com.adobe.utils.AGALMiniAssembler;
  import flash.geom.Matrix3D;
  import flash.net.URLRequest;
  import flash.system.LoaderContext;
  
  /**
   * AGAL convolution filter
   */
  public class Filter extends Sprite {
    private var image : BitmapData ;
    private var coefs : Vector.<InputText> = new Vector.<InputText>() ;
    private var stage3d : Stage3D ;
    private var texture : Texture ;
    private var quadIndices : IndexBuffer3D ;
    private var quadVertices : VertexBuffer3D ;
    public function Filter(  ){
      var loader : Loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImage);
      //loader.load(new URLRequest("http://farm3.static.flickr.com/2784/4272833528_33ab1e208c.jpg"), new LoaderContext(true));
      loader.load(new URLRequest("http://farm8.staticflickr.com/7024/6821514805_c41e7b597f.jpg"), new LoaderContext(true));
    }
    private function onImage ( e : Event ) : void {
      var info : LoaderInfo = e.target as LoaderInfo;
      info.removeEventListener(Event.COMPLETE, onImage);
      image = (info.content as Bitmap).bitmapData;
      
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.align = StageAlign.TOP_LEFT;
      
      stage3d = stage.stage3Ds[0];
      stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContext);
      stage3d.requestContext3D();
    }
    private function onContext ( e : Event ) : void {
      stage3d.removeEventListener(Event.CONTEXT3D_CREATE, onContext);
      
      quadIndices = stage3d.context3D.createIndexBuffer(6);
      quadIndices.uploadFromVector(Vector.<uint>([0, 2, 1, 1, 2, 3]), 0, 6);
      
      quadVertices = stage3d.context3D.createVertexBuffer(4, 4);
      quadVertices.uploadFromVector(Vector.<Number>([-1, -1, 0, 1, -1, 1, 0, 0, 1, -1, 1, 1, 1, 1, 1, 0]), 0, 4);
      stage3d.context3D.setVertexBufferAt(0, quadVertices, 0, Context3DVertexBufferFormat.FLOAT_2);
      stage3d.context3D.setVertexBufferAt(1, quadVertices, 2, Context3DVertexBufferFormat.FLOAT_2);
      
      texture = stage3d.context3D.createTexture(512, 512, Context3DTextureFormat.BGRA, false);
      texture.uploadFromBitmapData(image);
      stage3d.context3D.setTextureAt(0, texture);
      
      for ( var i : int = 0 ; i < 5 ; i++ ) {
        for ( var j : int = 0 ; j < 5 ; j++ ) {
          var input : InputText = new InputText(this, 10 + i * 50, 10 + j * 20, ((i == 2) && (j == 2)) ? "1" : "");
          input.width = 40;
          coefs.push(input);
        }
      }
      
      new PushButton(this, 10, 110, "3x3 blur", set3x3Blur);
      new PushButton(this, 10, 130, "5x5 bevel", set5x5Bevel);
      new PushButton(this, 10, 150, "5x5 blur", set5x5Blur);
      new PushButton(this, 10, 170, "3x3 sharpen", set3x3Sharpen);
      new PushButton(this, 10, 210, "apply", applyFilter);
    }
    private function applyFilter ( e : * = null ) : void {
      while ( numChildren > 0 ) {
        removeChildAt(0);
      }
      
      var vshader : AGALMiniAssembler = new AGALMiniAssembler();
      vshader.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0\nmov v0, va1\n");
      
      
      var fconstants : Vector.<Number> = new Vector.<Number>();
      for ( var i : int = 0 ; i < 5 ; i++ ) {
        for ( var j : int = 0 ; j < 5 ; j++ ) {
          var input : InputText = coefs.shift();
          if ( input.text != "" ) {
            fconstants.push((i - 2) / 512, (j - 2) / 512, 0, parseFloat(input.text));
          }
        }
      }
      
      var fcode : String = "sub ft0, v0, v0\n";
      for ( var k : int = 0 ; k < fconstants.length / 4 ; k++ ) {
        fcode += "add ft1, v0, fc" + k + "\n";
        fcode += "tex ft1, ft1, fs0<2d,repeat,linear>\n";
        fcode += "mul ft1.xyzw, ft1.xyzw, fc" + k + ".wwww\n";
        fcode += "add ft0, ft0, ft1\n";
      }
      fcode += "mov oc, ft0\n";
      
      var fshader : AGALMiniAssembler = new AGALMiniAssembler();
      fshader.assemble(Context3DProgramType.FRAGMENT, fcode);
      
      var program : Program3D = stage3d.context3D.createProgram();
      program.upload(vshader.agalcode, fshader.agalcode);
      stage3d.context3D.setProgram(program);
      
      stage3d.context3D.configureBackBuffer(512, 512, 0);
      stage3d.context3D.setRenderToBackBuffer();
      stage3d.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, new Matrix3D());
      stage3d.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fconstants, fconstants.length / 4);
      stage3d.context3D.clear(0, 0, 0, 1);
      stage3d.context3D.drawTriangles(quadIndices);
      stage3d.context3D.present();
    }
    private function setCoefs ( data : Vector.<Number> ) : void {
      for ( var i : int = 0 ; i < 25 ; i++ ) {
        coefs[i].text = (data[i] != 0) ? data[i].toFixed(2) : "";
      }
    }
    private function set3x3Blur ( e : * = null ) : void {
      var data : Vector.<Number> = new Vector.<Number>();
      data.push(0.00, 0.00, 0.00, 0.00, 0.00);
      data.push(0.00, 0.01, 0.08, 0.01, 0.00);
      data.push(0.00, 0.08, 0.64, 0.08, 0.00);
      data.push(0.00, 0.01, 0.08, 0.01, 0.00);
      data.push(0.00, 0.00, 0.00, 0.00, 0.00);
      setCoefs(data);
    }
    private function set5x5Bevel ( e : * = null ) : void {
      var data : Vector.<Number> = new Vector.<Number>();
      var s : Number = 0.3;
      data.push( s,    s,    s,    s,    s);
      data.push( s,    s,    s,   -s,   -s);
      data.push( s,    s,    0,   -s,   -s);
      data.push( s,    s,   -s,   -s,   -s);
      data.push(-s,   -s,   -s,   -s,   -s);
      setCoefs(data);
    }
    private function set5x5Blur ( e : * = null ) : void {
      var data : Vector.<Number> = new Vector.<Number>();
      data.push(0.01, 0.02, 0.04, 0.02, 0.01);
      data.push(0.02, 0.04, 0.08, 0.04, 0.02);
      data.push(0.04, 0.08, 0.16, 0.08, 0.04);
      data.push(0.02, 0.04, 0.08, 0.04, 0.02);
      data.push(0.01, 0.02, 0.04, 0.02, 0.01);
      setCoefs(data);
    }
    private function set3x3Sharpen ( e : * = null ) : void {
      var data : Vector.<Number> = new Vector.<Number>();
      data.push(0.00, 0.00, 0.00, 0.00, 0.00);
      data.push(0.00, -0.1, -0.1, -0.1, 0.00);
      data.push(0.00, -0.1, 1.80, -0.1, 0.00);
      data.push(0.00, -0.1, -0.1, -0.1, 0.00);
      data.push(0.00, 0.00, 0.00, 0.00, 0.00);
      setCoefs(data);
    }
  }
}


