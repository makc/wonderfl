// Flash 10 で被写界深度ネタ Z-sortつき
package{
  import flash.display.*
  import flash.events.*
  import flash.filters.BlurFilter;
  import flash.geom.*;
  
  [SWF(frameRate="90", width="465", height="465")]
  public class Main extends Sprite {

  public function Main() {
      
      var main :Sprite = Sprite(addChild(new Sprite()))
      main.x = stage.stageWidth / 2
      main.y = stage.stageHeight / 2
      var wrap :Sprite = Sprite(main.addChild(new Sprite()))
      
      var pp:PerspectiveProjection = root.transform.perspectiveProjection; 
      
      var objs:Array = []
      for(var i:int=0; i<15; i++)
      {
        var sp: Sprite = Sprite(wrap.addChild(new Sprite()))
        sp.graphics.beginFill(0xFFFFFF * Math.random())
        sp.graphics.drawRect(-25, -25, 50, 50)
        sp.x = 200 * Math.sin( i * 360 / 15 * Math.PI / 180)
        sp.z = 200 * Math.cos( i * 360 / 15 * Math.PI / 180)
        
        objs.push(sp)
      }
      
      stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void
      {
        pp.projectionCenter = new Point(stage.stageWidth / 2,
                  stage.stageHeight / 2 - 100)
        
        wrap.rotationY += (mouseX / stage.stageWidth * 480 - wrap.rotationY) * 0.05
        
        var arr:Array = []
        for (var i:int=0; i<objs.length; i++) {
          var ele:Sprite = objs[i] as Sprite
          ele.rotationY = -wrap.rotationY
          var mtx:Matrix3D = ele.transform.getRelativeMatrix3D(main)
          arr.push( { ele:ele, z:mtx.position.z } )
        }

        arr.sortOn("z", Array.NUMERIC | Array.DESCENDING)
        var baseZ:Number = wrap.z
        for (i=0; i<arr.length; i++) {
          ele = arr[i].ele as Sprite
          var z:Number = arr[i].z
          wrap.setChildIndex(ele, i)
          var b:Number = Math.abs(z)
          
          // focus depth blur effect, warning, very slow:
          b = z/10
          ele.filters = (b > 2) ? [new BlurFilter(b, b, 3)] : []
        }
      })
    }
  }
}