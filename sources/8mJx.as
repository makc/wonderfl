package {
    import flash.display.*;
    import com.actionsnippet.qbox.*;

    public class FlashTest extends MovieClip {
        public function FlashTest() {
            // write as3 code here..
 
            stage.frameRate = 60;
 
            var sim:QuickBox2D = new QuickBox2D(this);
 
            sim.createStageWalls();
 
            sim.addBox({x:5, y:5, width:1, height:1});
            sim.addCircle({x:4, y:8, radius:2});
 
            sim.start();
            sim.mouseDrag();                        
        }
    }
}
