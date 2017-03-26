package {
    import flash.display.Sprite;
    
    import sandy.core.*;
    import sandy.core.scenegraph.*;
    import sandy.materials.*;
    import sandy.primitive.*;

    public class FlashTest extends Sprite {
        public function FlashTest() {
            var cam:Camera3D = new Camera3D(600, 450, 45, 0, 2000);
            var rootGroup :Group = new Group("world_root_group");
            var myScene:Scene3D = new Scene3D("scene_name", this, cam, rootGroup);

            var shape :Shape3D = new Plane3D('plane',100,100,10,10);
            shape.appearance = new Appearance( new WireFrameMaterial() );
            rootGroup.addChild( shape );

            myScene.render();
        }
    }
}
