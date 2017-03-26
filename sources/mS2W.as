package {
  
  import flash.display.*;
  import flash.display3D.*;
  import flash.events.Event;
  import com.adobe.utils.AGALMiniAssembler;
  import flash.geom.Matrix3D;
  
  /**
   * atan2 in AGAL.
   */
  public class atan2 extends Sprite {
    private var stage3d : Stage3D ;
    private var quadIndices : IndexBuffer3D ;
    private var quadVertices : VertexBuffer3D ;
    public function atan2(  ){
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
      
      var vshader : AGALMiniAssembler = new AGALMiniAssembler();
      vshader.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0\nmov v0, va1\n");
      
      
      var fconstants : Vector.<Number> = new <Number> [
		0.4 /* center x (u) */,
		0.6 /* center y (v) */,
		Math.PI, 2*Math.PI,
		2.220446049250313e-16, 0.7853981634, 0.1821, 0.9675 /* atan2 magic numbers */
	  ];
      
      var fshader : AGALMiniAssembler = new AGALMiniAssembler();
      fshader.assemble(Context3DProgramType.FRAGMENT,
		"sub ft0, v0, fc0\n" +
		"sub ft0.zw, ft0.zw, ft0.zw\n" /* ft0 = radius vector */  +
		"dp3 ft1, ft0, ft0\n" +
		"sqt ft1, ft1\n" +
		
		/* In their eternal wisdom Adobe or whoever is responsible
		 * made no atan2 in AGAL, so we need to use approximation,
		 * for example the one by Eugene Zatepyakin, Joa Ebert and
		 * Patrick Le Clec'h http://wonderfl.net/c/1HbR/read */
		
		"abs ft2, ft0\n" /* ft2 = |x|, |y| */ +
		/* sge, because dated AGALMiniAssembler does not have seq */
		"sge ft2, ft0, ft2\n" /* ft2.zw are both =1 now, since ft0.zw were =0 */ +
		"add ft2.xyw, ft2.xyw, ft2.xyw\n" +
		"sub ft2.xy, ft2.xy, ft2.zz\n" /* ft2 = sgn(x), sgn(y), 1, 2 */ +
		"sub ft2.w, ft2.w, ft2.x\n" /* ft2.w = "(partSignX + 1.0)" = 2 - sgn(x) */ +
		"mul ft2.w, ft2.w, fc1.y\n" /* ft2.w = "(partSignX + 1.0) * 0.7853981634" */ +
		"mul ft2.z, ft2.y, ft0.y\n" /* ft2.z = "y * sign" */ +
		"add ft2.z, ft2.z, fc1.x\n" /* ft2.z = "y * sign + 2.220446049250313e-16" or "absYandR" initial value */ +
		"mul ft3.x, ft2.x, ft2.z\n" /* ft3.x = "signX * absYandR" */ +
		"sub ft3.x, ft0.x, ft3.x\n" /* ft3.x = "(x - signX * absYandR)" */ +
		"mul ft3.y, ft2.x, ft0.x\n" /* ft3.y = "signX * x" */ +
		"add ft3.y, ft3.y, ft2.z\n" /* ft3.y = "(signX * x + absYandR)" */ +
		"div ft2.z, ft3.x, ft3.y\n" /* ft2.z = "(x - signX * absYandR) / (signX * x + absYandR)" or "absYandR" final value */ +
		"mul ft3.x, ft2.z, ft2.z\n" /* ft3.x = "absYandR * absYandR" */ +
		"mul ft3.x, ft3.x, fc1.z\n" /* ft3.x = "0.1821 * absYandR * absYandR" */ +
		"sub ft3.x, ft3.x, fc1.w\n" /* ft3.x = "(0.1821 * absYandR * absYandR - 0.9675)" */ +
		"mul ft3.x, ft3.x, ft2.z\n" /* ft3.x = "(0.1821 * absYandR * absYandR - 0.9675) * absYandR" */ +
		"add ft3.x, ft3.x, ft2.w\n" /* ft3.x = "(partSignX + 1.0) * 0.7853981634 + (0.1821 * absYandR * absYandR - 0.9675) * absYandR" */ +
		"mul ft3.x, ft3.x, ft2.y\n" /* ft3.x = "((partSignX + 1.0) * 0.7853981634 + (0.1821 * absYandR * absYandR - 0.9675) * absYandR) * sign" */ +
		
		/* compress -pi..pi to 0..1: (angle+pi)/(2*pi) */
		"add ft3.x, ft3.x, fc0.z\n" +
		"div ft3.x, ft3.x, fc0.w\n" +
		
		"mov ft3.xyzw, ft3.xxxx\n" +
		"mov oc, ft3\n"
	  );
      
      var program : Program3D = stage3d.context3D.createProgram();
      program.upload(vshader.agalcode, fshader.agalcode);
      stage3d.context3D.setProgram(program);
      stage3d.context3D.configureBackBuffer(512, 512, 0);
      stage3d.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, new Matrix3D());
      stage3d.context3D.setRenderToBackBuffer();
      stage3d.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fconstants, fconstants.length / 4);
      stage3d.context3D.clear(0, 0, 0, 1);
      stage3d.context3D.drawTriangles(quadIndices);
      stage3d.context3D.present();
    }
  }
}



