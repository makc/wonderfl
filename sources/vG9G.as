package {
  import flash.display.*;
  import flash.events.Event;
  import flash.geom.*;
  import flash.net.URLRequest;
  import flash.system.LoaderContext;
  [SWF(backgroundColor="#B0E1E3")]
  public class ch40ex5 extends Sprite {
    protected var viewMatrix:Matrix3D;
    protected var modelMatrix:Matrix3D;
    protected var model:Torus3D;
    protected var texture:BitmapData;
    protected var projectedPoints:Vector.<Number> = new Vector.<Number>();
    public function ch40ex5() {
      stage.quality = StageQuality.LOW;
      this.x = stage.stageWidth/2;
      this.y = stage.stageHeight/2;
      var perspective:PerspectiveProjection = new PerspectiveProjection();
      perspective.fieldOfView = 80;
      perspective.projectionCenter = new Point(0, 0); 
      viewMatrix = new Matrix3D();
      viewMatrix.appendTranslation(0, 7, 12);
      viewMatrix.appendRotation(40, Vector3D.X_AXIS);
      viewMatrix.append(perspective.toMatrix3D());
      modelMatrix = new Matrix3D();
      model = new Torus3D(2, 6, 40, 40);
      var l:Loader = new Loader();
      l.load(new URLRequest(
        "http://actionscriptbible.com/files/texture-donut.jpg"),
        new LoaderContext(true));
      l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
    }
    protected function onLoad(event:Event):void {
      texture = Bitmap(LoaderInfo(event.target).content).bitmapData;
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    protected function onEnterFrame(event:Event):void {
      modelMatrix.appendRotation(2, Vector3D.Y_AXIS);
      var concatenatedMatrix:Matrix3D = modelMatrix.clone();
      concatenatedMatrix.append(viewMatrix);
      Utils3D.projectVectors(
        concatenatedMatrix, model.vertices, projectedPoints, model.uvt);
      graphics.clear();
      graphics.beginBitmapFill(texture, null, false, false);
      graphics.drawTriangles(projectedPoints, model.indices, model.uvt, TriangleCulling.POSITIVE);
    }
  }
}
import flash.geom.Rectangle;
import flash.geom.Vector3D;
class Torus3D {
  public var vertices:Vector.<Number> = new Vector.<Number>();
  public var uvt:Vector.<Number> = new Vector.<Number>();
  public var indices:Vector.<int> = new Vector.<int>();
  public function Torus3D(crossSectionRadius:Number, radiusToTube:Number, uResolution:Number = 50, vResolution:Number = 50) {
    var R:Number = radiusToTube, r:Number = crossSectionRadius;
    var uStep:Number = Math.PI * 2 / uResolution;
    var vStep:Number = Math.PI * 2 / vResolution;
    var FLOAT_ERROR:Number = 0.0001;
    for (var u:Number = 0; u <= Math.PI*2 + FLOAT_ERROR; u += uStep) {
      for (var v:Number = 0; v <= Math.PI*2 + FLOAT_ERROR; v += vStep) {
        var x:Number = (R + r * Math.cos(v)) * Math.cos(u);
        var y:Number = r * Math.sin(v);
        var z:Number = (R + r * Math.cos(v)) * Math.sin(u);
        vertices.push(x, y, z);
        uvt.push(u / (Math.PI*2), v / (Math.PI*2), 0);
      }
    }
    for (var ui:int = 0; ui <= uResolution; ui++) {
      for (var vi:int = 0; vi <= vResolution; vi++) {
        var thisSlice:int = ui * vResolution + vi;
        var nextSlice:int = (ui+1) * vResolution + vi;
        indices.push(thisSlice, nextSlice + 1, nextSlice,
          thisSlice, thisSlice + 1, nextSlice + 1);
      }
    }
  } 
}