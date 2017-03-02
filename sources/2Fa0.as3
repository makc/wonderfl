// forked from actionscriptbible's Chapter 40 Example 6
package {
  import flash.display.*;
  import flash.events.Event;
  import flash.geom.*;
  import flash.net.URLRequest;
  import flash.system.LoaderContext;
  [SWF(backgroundColor="#FFFFFF")]
  public class ch40ex6 extends Sprite {
    protected var viewMatrix:Matrix3D;
    protected var modelMatrix:Matrix3D;
    protected var model:Torus3D;
    protected var texture:BitmapData= new BitmapData(750, 400, true,0);
    protected var projectedPoints:Vector.<Number> = new Vector.<Number>();
    public function ch40ex6() {
      Wonderfl.disable_capture();
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
      model = new Torus3D(2, 4, 20, 20);
      var l:Loader = new Loader();
      l.load(new URLRequest(
        "http://actionscriptbible.com/files/texture-donut.jpg"),
        new LoaderContext(true));
      l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
      var l2:Loader = new Loader();
      l2.load(new URLRequest(
        "http://chococornet.sakura.ne.jp/img/fork.png"),
        new LoaderContext(true));
      l2.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad2);
    }
    protected function onLoad(event:Event):void {
      texture.draw(Bitmap(LoaderInfo(event.target).content).bitmapData);
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    protected function onLoad2(event:Event):void {
      var m:Matrix = new Matrix();
      m.tx = 600;
      texture.draw(Bitmap(LoaderInfo(event.target).content).bitmapData,m);
    }
    protected function onEnterFrame(event:Event):void {
      modelMatrix.appendRotation(0.3, Vector3D.Z_AXIS);
      modelMatrix.appendRotation(0.6, Vector3D.X_AXIS);
      modelMatrix.appendRotation(-1, Vector3D.Y_AXIS);
      var concatenatedMatrix:Matrix3D = modelMatrix.clone();
      concatenatedMatrix.append(viewMatrix);
      Utils3D.projectVectors(
        concatenatedMatrix, model.vertices, projectedPoints, model.uvt);
      graphics.clear();
      graphics.beginBitmapFill(texture, null, false, false);
      graphics.drawTriangles(projectedPoints, model.getZSortedIndices(),
        model.uvt);
    }
  }
}
import flash.geom.Vector3D;
class Torus3D {
  public var vertices:Vector.<Number> = new Vector.<Number>();
  public var uvt:Vector.<Number> = new Vector.<Number>();
  public var indices:Vector.<int> = new Vector.<int>();
  private var zSort:Vector.<ZSort>;
  public function Torus3D(crossSectionRadius:Number, radiusToTube:Number, 
                          uResolution:Number = 50, vResolution:Number = 50) {
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
        uvt.push(u / (Math.PI*2)*0.795, v / (Math.PI*2), 0);
      }
    }
    zSort = new Vector.<ZSort>();
    for (var ui:int = 0; ui < uResolution; ui++) {
      for (var vi:int = 0; vi < vResolution; vi++) {
        var index:int = ui * (vResolution + 1)+vi;
        indices.push(index , index + 1, index + vResolution + 1,
        index + 1, index + vResolution + 2, index + vResolution + 1)
        zSort.push(new ZSort(index, index + 1, index + vResolution + 1),
        new ZSort(index + 1, index + vResolution + 2, index + vResolution + 1));
      }
    }
    //フォークの頂点、UV、インデックス
    var vertices2:Vector.<Number> = new Vector.<Number>();
    var uvt2:Vector.<Number> = new Vector.<Number>();
    var indices2:Vector.<int> = new Vector.<int>();
    var zSort2:Vector.<ZSort>= new Vector.<ZSort>();
    for (var Y:int = 0; Y < 5; Y++) {
      for (var X:int = 0; X < 4; X++) {
        var vertexZ:Number = (X >= 2)? 0.7:0;
        var vertexX:Number = 
          (X == 0 && Y == 1) || (X == 0 && Y == 3)?  5.9:
          (X == 0 && Y == 2)? 6:
          (X == 1)? 6.752:
          (X == 2)? 8.12:
          5.6 + X * 2.4;
        vertices2.push(vertexX, 1.2 - Y * 0.6, vertexZ);
        uvt2.push(0.81 + Y * 0.045, (vertices2[(Y*4+X)*3]-5.6)/7.2, 0);
        if (Y < 4 && X < 3) {
          index = 4 * Y + X ;
          indices2.push(index, index + 1, index + 4, index + 1, index + 5, index + 4);
          zSort2.push(new ZSort(index, index + 1, index + 4), new ZSort(index + 1, index + 5, index + 4));
        }
      }
    }
    for (var i:int = 0; i < indices.length; i++) {
      indices[i] += 20;
      if (i%3==0) {
        zSort[i/3].i1 += 20; zSort[i/3].i2 += 20; zSort[i/3].i3 += 20;
      }
    }
    vertices = vertices2.concat(vertices);
    uvt = uvt2.concat(uvt);
    indices = indices2.concat(indices);
    zSort = zSort2.concat(zSort);
  }
  public function getZSortedIndices():Vector.<int> {
    var node:ZSort;
    for each (node in zSort) {
      node.t = Math.min(uvt[node.i1*3+2], uvt[node.i2*3+2], uvt[node.i3*3+2]);
    }
    zSort = zSort.sort(ZSort.compare);
    var zSortedIndices:Vector.<int> = new Vector.<int>();
    for each (node in zSort) zSortedIndices.push(node.i1, node.i2, node.i3);
    return zSortedIndices;
  }
}
class ZSort {
  public var i1:int, i2:int, i3:int, t:Number;
  public function ZSort(i1:int, i2:int, i3:int) {
    this.i1 = i1; this.i2 = i2; this.i3 = i3;
  }
  public static function compare(a:ZSort, b:ZSort):int {
    return (a.t < b.t)?-1:1;
  }
}