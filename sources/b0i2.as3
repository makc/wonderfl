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
        private var song:Sound;
        private var channel:SoundChannel = new SoundChannel();
        private var info:TextField;
        private var status_text:TextField;
        private var song_status:String;
        private var keysDown:Object = new Object();
        private var song_pos:int;
        private var box:Box;
        
        public function Program() {
            camera = new Camera3D(465,465);
            camera.z = -400;
            
            var root:Group = createScene();
            
            scene = new Scene3D("scene", this, camera, root);
            
            song_status = "stopped";
            
            info = new TextField();
            info.width = 500;
            //info.x = info.y = 5;
            info.text = "Press Space to play/pause (hold space long enough for the song to... Restart Õ.o)";
            info.textColor = 0x0;
            
            status_text = new TextField();
            status_text.width = 100;
            status_text. x = status_text.y = 12;
            status_text.text = song_status;
            
            addChild(info);
            addChild(status_text);
            
            var url:URLRequest = new URLRequest("http://www.newgrounds.com/audio/download/67185");
            
            song = new Sound();
            song.load(url);
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        }
        
        private function enterFrame(event:Event):void {
            scene.render();
            
            song_pos = channel.position;
            
            if(song_status == "playing"){
                box.rotateX += 100;
                box.rotateY += 100;
                box.rotateZ += 100;
            }
            
            status_text.text = song_status;
        }
        
        private function createScene():Group{
            var g:Group = new Group();
            
            box = new Box("box", 100, 100, 100);
            box.rotateX = 30;
            box.rotateY = 30;
            
            g.addChild(box);
            
            return g;
        }
        
        private function isDown(keyCode:uint):Boolean{
            return Boolean(keyCode in keysDown);
        }
        
        private function keyDown(event:KeyboardEvent):void{
            keysDown[event.keyCode] = true;
            if(isDown(Keyboard.SPACE)){
                if(song_status == "stopped"){
                    song_status = "playing";
                    channel = song.play(song_pos);
                }else{
                    song_status = "stopped";
                    channel.stop();
                }
            }
        }
        
        private function keyUp(event:KeyboardEvent):void{
            if(event.keyCode in keysDown){
                delete keysDown[event.keyCode];
            }
        }
    }
}



