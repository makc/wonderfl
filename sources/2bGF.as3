// test using 1600 boxes to render a 3d pathway
// inspired by ABA's UpDownRoad
package {
	import flash.display.*
	import flash.events.*;
        import flash.text.*;

	[SWF(width="465",height="465",backgroundColor="0xFFFFFF",frameRate="45")]
	public class AS3Code extends Sprite{
		public function AS3Code() {
			main=this;
                        Width = stage.stageWidth;
                        Height = stage.stageHeight;
                        stage.addChild(main);
                        
                            debugText = new TextField();
                            debugText.width = 400;
                            debugText.height = 300;
                            debugText.multiline = true;
                            debugText.wordWrap = true;
                            debugText.textColor = 0x0000FF;
                            debugText.selectable = false;
                            stage.addChild(debugText);
                        
			initialize();

                        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			
			addEventListener(Event.ENTER_FRAME, EveryFrame);
        }
    }
}
import flash.display.*;
import flash.events.*;
import flash.ui.*;
import flash.utils.*;
import flash.filters.*
import flash.text.*;
import flash.geom.*
import flash.media.*
import flash.net.*
//
import sandy.core.*;
import sandy.core.data.*;
import sandy.core.scenegraph.*;
import sandy.events.*
import sandy.materials.*;
import sandy.materials.attributes.*;
import sandy.primitive.*;
import sandy.core.scenegraph.mode7.*; 
//
var main:Sprite;
var clip:MovieClip;
var Width:int;
var Height:int;

var debugText:TextField = new TextField();
//
var camera:Camera3D;
var root:Group;
var scene:Scene3D;
//
var box:Box;
var boxArray:Vector.<boxParticle> = new Vector.<boxParticle>;
var visibleBoxArray:Vector.<boxParticle> = new Vector.<boxParticle>
function initialize():void {
    camera = new Camera3D( 465, 465);
    camera.x = 0;
    camera.y = 0;
    camera.z = 0;
    root = new Group();
    
    //camera.lookAt( 0, -150, 300);
    
    box = new Box("box", 50, 50, 50);
    box.x = 50;
    box.z = 2200;
    
    root.addChild(box);
    
    scene = new Scene3D( "scene", main, camera, root );
    clip = new MovieClip();
    main.addChild(clip);
    //clip.x = int(Width/2);
    //clip.y = int(Height/2);
    var rotX:Number = 0;
    var count:Number = 0;
    for(var i:int=0;i<200;i++){
        rotX = Math.sin(count+=Math.PI*0.02)/4;
        for(var h=-4;h<4;h++){
            var p:boxParticle = new boxParticle();
            
            if(h == 3 || h == -4){
                p.px = h*9.7*Math.cos(rotX);
                p.py = -20+h*9*Math.sin(rotX)+2;
                p.pz = i*10-5;
                p.size = 5;
                p.red = 144+(i%3)*14;
                p.green = 144+(i%3)*8;
                p.blue = 144+Math.random()*12;
            }else{
                p.px = h*10*Math.cos(rotX);
                p.py = -20+h*Math.sin(rotX)*10;
                p.pz = i*10;
                p.size = 8;
                p.red = 118+Math.random()*20;
                p.green = 124+(i%2)*14;
                p.blue = 184+Math.random()*20;
            }
            p.depth = i;
            boxArray.push(p);
            clip.addChild(p);
        }
    }
}
function EveryFrame(event:Event):void{
    debugText.text = "";
    
    clip.graphics.clear();
 
    for each(var p:boxParticle in boxArray){
        DrawBox(p, camera);   
    }
    boxArray.sort(Zsort); // the sorting is delayed one frame...
    function Zsort(p1:boxParticle, p2:boxParticle):Number{
        if (p1.depth < p2.depth)
          return 1;
        else if (p1.depth > p2.depth)
          return -1;
        else
          return 0;
    }
    //camera.rotateZ++;
    //camera.z += 5;
    for each(p in boxArray){
        p.pz-=15;
        if(p.pz < 0){
            p.pz += 200*10;
        }
    }
    box.z -= 15;
    scene.render();
    
}
function DrawBox(_box:boxParticle, camera:Camera3D):void{
            _box.graphics.clear();
            var _v:Vertex = new Vertex(_box.px,_box.py,_box.pz);
            var m:Matrix4 = camera.invModelMatrix;
            _v.wx = _v.x * m.n11 + _v.y * m.n12 + _v.z * m.n13 + m.n14;
            _v.wy = _v.x * m.n21 + _v.y * m.n22 + _v.z * m.n23 + m.n24;
            _v.wz = _v.x * m.n31 + _v.y * m.n32 + _v.z * m.n33 + m.n34;
            camera.projectVertex(_v);
            //_box.x = _v.sx;
            //_box.y = _v.sy;
            //_box.z = -_v.wz
            _box.depth = _v.wz+_v.sx/1000;
            //boxArray.sort(Zsort);
            if(_v.wz >= camera.near && _v.wz <= camera.far){
                //var fadeout:Number = 1-(_v.wz)/2000;
                var fadeout:Number = 1/(_v.wz/400);
                fadeout = Math.max(fadeout,0);
                fadeout = Math.min(fadeout,1);
                var _color:uint = 
                _box.red*fadeout+200*(1-fadeout) << 16 
                | _box.green*fadeout+200*(1-fadeout) << 8 
                | _box.blue*fadeout+205*(1-fadeout);
                clip.graphics.beginFill(_color);
                clip.graphics.drawRect( _v.sx, _v.sy, _box.size*1000/_v.wz, _box.size*1000/_v.wz); 
                clip.graphics.endFill();
                //_box.graphics.beginFill(_box.color);
                //_box.graphics.drawRect( 0, 0, _box.size*1000/_v.wz, _box.size*1000/_v.wz); 
                //_box.graphics.endFill();
                
           }
}    
var initialized:Boolean = false;// marks whether or not the class has been initialized
var keysDown:Object = new Object();// stores key codes of all keys pressed
function isDown(keyCode:uint):Boolean {
	return Boolean(keyCode in keysDown);
}
function keyPressed(event:KeyboardEvent):void {
       	keysDown[event.keyCode] = true;
}
function keyReleased(event:KeyboardEvent):void {
	if (event.keyCode in keysDown) {
		delete keysDown[event.keyCode];
	}
}
class boxParticle extends Sprite{
    public var px:Number;
    public var py:Number;
    public var pz:Number;
    public var depth:Number;
    public var size:Number;
    public var red:Number;
    public var green:Number;
    public var blue:Number;
    /*
    public function boxParticle(_X:Number, _Y:Number, _Z:Number, _size:Number, _color:uint) {
        pos[0] = _X;
        pos[1] = _Y;
        pos[2] = _Z;
        size = _size;
        color = _color;
    }
    */
}
    


