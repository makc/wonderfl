// forked from makc3d's AGAL zoom blur filter
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
   * Another attempt using non-circular "radius".
   */
  public class Filter extends Sprite {
    private var image : BitmapData ;
	private var diamond : RadioButton ;
    private var strength : HSlider ;
    private var stage3d : Stage3D ;
    private var texture : Texture ;
    private var quadIndices : IndexBuffer3D ;
    private var quadVertices : VertexBuffer3D ;
    public function Filter(  ){
      var loader : Loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImage);
      loader.load(new URLRequest("http://farm3.static.flickr.com/2784/4272833528_33ab1e208c.jpg"), new LoaderContext(true));
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
      
      strength = new HSlider(this, 10, 150);
	  strength.minimum = 1;
	  strength.maximum = 23;
	  strength.tick = 0.1;
	  strength.value = 10;
      
	  diamond =
	  new RadioButton(this, 10, 110, "Diamond \"radius\"");
	  new RadioButton(this, 10, 130, "Rectangular \"radius\"");
	  diamond.selected = true;
	  
      new PushButton(this, 10, 180, "apply", applyFilter);
	  new Label(this, int(0.4 * 512) - 2, int(0.6 * 512) - 10, "x Center");
    }
    private function applyFilter ( e : * = null ) : void {
      while ( numChildren > 0 ) {
        removeChildAt(0);
      }
      
      var vshader : AGALMiniAssembler = new AGALMiniAssembler();
      vshader.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0\nmov v0, va1\n");
      
      
      var fconstants : Vector.<Number> = new <Number> [
		0.4 /* center x (u) */,
		0.6 /* center y (v) */,
		0.4 /* radius of the circle fully inside 1x1 uv quad */,
		strength.value /* p > 1, to compress image radially */
	  ];
      
      var fshader : AGALMiniAssembler = new AGALMiniAssembler();
      fshader.assemble(Context3DProgramType.FRAGMENT,
		"sub ft0, v0, fc0\n" +
		"sub ft0.zw, ft0.zw, ft0.zw\n" /* ft0 = radius vector */  +
		"abs ft1, ft0\n" +
		(diamond.selected ? "add" : "max") +
			" ft1.xy, ft1.xx, ft1.yy\n" /* ft1.xy = |x| + |y| or max (|x|, |y|) "radius" */ +
		"div ft1.xy, ft1.xy, fc0.zz\n" /* ft1.xy = normalized radius */ +
		"pow ft1.x, ft1.x, fc0.w\n" /* ft1.x = normalized radius ^ p */ +
		"mul ft0.xy, ft0.xy, ft1.xx\n" +
		"div ft0.xy, ft0.xy, ft1.yy\n" /* ft0 = scaled radius vector */ +
		"add ft0.xy, ft0.xy, fc0.xy\n" /* ft0 = corresponding uv */ +
		"tex oc, ft0, fs0<2d,clamp,linear>\n"
	  );
      
      var program : Program3D = stage3d.context3D.createProgram();
      program.upload(vshader.agalcode, fshader.agalcode);
      stage3d.context3D.setProgram(program);
      
      stage3d.context3D.configureBackBuffer(512, 512, 0);
	  var tmp:Texture = stage3d.context3D.createTexture (512, 512, Context3DTextureFormat.BGRA, true);
	  stage3d.context3D.setRenderToTexture (tmp);
      stage3d.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, new Matrix3D());
      stage3d.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fconstants, fconstants.length / 4);
      stage3d.context3D.clear(0, 0, 0, 1);
      stage3d.context3D.drawTriangles(quadIndices);
	  
	  // now apply inverse transform
	  fconstants [3] = 1 / fconstants [3];
      stage3d.context3D.setRenderToBackBuffer();
	  stage3d.context3D.setTextureAt (0, tmp);
      stage3d.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fconstants, fconstants.length / 4);
      stage3d.context3D.clear(0, 0, 0, 1);
      stage3d.context3D.drawTriangles(quadIndices);
      stage3d.context3D.present();
    }
  }
}



