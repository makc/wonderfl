// forked from Seel's 3D and sound
package {
    import flash.display.*;
    import flash.events.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.TextField;
    import flash.ui.*;
    
    import sandy.core.Scene3D;
    import sandy.core.data.*;
    import sandy.core.scenegraph.*;
    import sandy.materials.*;
    import sandy.materials.attributes.*;
    import sandy.primitive.*;
    
    [SWF(width=465, height=465, backgroundColor = 0xFFFFFF, frameRate = 30)]
    public class Program extends Sprite {
        
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var info:TextField;
        private var status_text:TextField;
        private var keysDown:Object = new Object();
        private var box:Box;
        private var box_group:TransformGroup;
        private var s3d:Sound3D;
        
        public function Program() {
            camera = new Camera3D(465,465);
            camera.z = -400;
            
            info = new TextField();
            info.width = 500;
            //info.x = info.y = 5;
            info.text = "Press arrow keys and PgUp/PgDn to move the sound source around...";
            info.textColor = 0x0;
            
            status_text = new TextField();
            status_text.width = 100;
            status_text.x = status_text.y = 12;

            addChild(info);
            addChild(status_text);
            
            var root:Group = createScene (new URLRequest("http://www.newgrounds.com/audio/download/67185"));
            
            scene = new Scene3D("scene", this, camera, root);
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        }
        
        private function enterFrame(event:Event):void {
            scene.render();
            
            box.rotateX ++;
            box.rotateY ++;
            box.rotateZ ++;

            box.scaleX =
            box.scaleY =
            box.scaleZ = 1 + 0.03 * Math.random ();
            
            status_text.text =
                " x " + (box_group.x - camera.x) +
                " y " + (box_group.y - camera.y) +
                " z " + (box_group.z - camera.z);

            s3d.play ();
        }
        
        private function createScene (url:URLRequest):Group{
            var g:Group = new Group();

            var mat:ColorMaterial = new ColorMaterial ( 0x7FFF );
            mat.attributes = new MaterialAttributes (
                new LightAttributes ());
            mat.lightingEnable = true;

            box = new Box("box", 100, 100, 100);
            box.appearance = new Appearance (mat);

            s3d = new Sound3D ("song", url, 1, 1, 1500);

            box_group = new TransformGroup ("stuff");
            box_group.addChild (box);
            box_group.addChild (s3d);

            g.addChild (box_group);
            
            return g;
        }
        
        private function isDown(keyCode:uint):Boolean{
            return Boolean(keyCode in keysDown);
        }
        
        private function keyDown(event:KeyboardEvent):void{
            keysDown[event.keyCode] = true;
            if (isDown(Keyboard.UP)) box_group.z += 10;
            if (isDown(Keyboard.DOWN)) box_group.z -= 10;
            if (isDown(Keyboard.PAGE_UP)) box_group.y += 10;
            if (isDown(Keyboard.PAGE_DOWN)) box_group.y -= 10;
            if (isDown(Keyboard.LEFT)) box_group.x -= 10;
            if (isDown(Keyboard.RIGHT)) box_group.x += 10;
        }
        
        private function keyUp(event:KeyboardEvent):void{
            if(event.keyCode in keysDown){
                delete keysDown[event.keyCode];
            }
        }
    }
}



