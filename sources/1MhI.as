// forked from ADO's forked from: QuickBox2D sample
// forked from mash's QuickBox2D sample
package {
    import flash.display.*;
    import com.actionsnippet.qbox.*;

    public class FlashTest extends MovieClip {
        public function FlashTest() {
            // write as3 code here..
 
            stage.frameRate = 60;
            stage.quality = "low";
            var sim:QuickBox2D = new QuickBox2D(this);
 
            sim.createStageWalls();
 
            // testing stacking
            for (var i:int = 0; i < 35; i++)
            for (var j:int = 0; j < 2; j++)
                sim.addBox({x:3 + 8 * j, y:0.4+0.6*i, width:2, height:0.5});
 
            sim.start();
            sim.mouseDrag();                        
        }
    }
}
