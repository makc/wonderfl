// forked from makc3d's forked from: 3D and sound
// forked from Seel's 3D and sound
package {
    import flash.display.*;
    import flash.events.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.TextField;
    import flash.ui.*;
    import flash.utils.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.media.*;
    
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
        private var playing:Boolean = true;
        private var dx:Number = 0;
        private var dy:Number = 0;
        private var dz:Number = 0;
        
        public function Program() {
            camera = new Camera3D(465,465);
            camera.z = -400;
            
            info = new TextField();
            info.width = 500;
            //info.x = info.y = 5;
            info.text = "Press arrow keys and PgUp/PgDn to move the sound source around...";
            info.textColor = 0x0;
            
            status_text = new TextField();
            status_text.width = 200;
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
            
            if (isDown(Keyboard.UP)) dz += 1;
            if (isDown(Keyboard.DOWN)) dz -= 1;
            if (isDown(Keyboard.PAGE_UP)) dy += 1;
            if (isDown(Keyboard.PAGE_DOWN)) dy -= 1;
            if (isDown(Keyboard.LEFT)) dx -= 1;
            if (isDown(Keyboard.RIGHT)) dx += 1;
            
            
            box_group.y += dy;
            box_group.x += dx;
            box_group.z += dz;
            
            dy = subtract(dy*0.9,.1);
            dx = subtract(dx*0.9,.1);
            dz = subtract(dz*0.9,.1);
            
            box.rotateX ++;
            box.rotateY ++;
            box.rotateZ ++;
            
            var b:String = "Stopped";
            if(playing == true){
                b = "Playing"
            }
            
            status_text.text =
                " x " + int(box_group.x - camera.x) +
                " y " + int(box_group.y - camera.y) +
                " z " + int(box_group.z - camera.z) +
                " "+b;
            
            
            if(playing == true){
                s3d.play ();
            }
            
            var a:Number =
            s3d.soundChannel.leftPeak+s3d.soundChannel.rightPeak;
            
            box.scaleX =
            box.scaleY =
            box.scaleZ = 1 + a/5;
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
         
             if(event.keyCode == Keyboard.SPACE){
                playing = !playing;
                if(playing == false){
                    s3d.stop();
                }
            }
        }
        
        private function keyUp(event:KeyboardEvent):void{
            if(event.keyCode in keysDown){
                delete keysDown[event.keyCode];
            }
        }
        private function subtract(num:Number, num2:Number):Number{
            if(num > 0){
                num = Math.max(0, num-num2);     
            }else{
                num = Math.min(0, num+num2);   
            }
            return num;
        }
    }
}
