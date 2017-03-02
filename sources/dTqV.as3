// Added turning, you can now freely move around the track
// Arrow Keys to move around
// test using boxes to render a 3d pathway
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
                            
                        clip = new MovieClip();
                        stage.addChild(clip);
                        clip2 = new MovieClip();
                        stage.addChild(clip2);
                        clip3 = new MovieClip();
                        stage.addChild(clip3);
                        
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
var clip2:MovieClip;
var clip3:MovieClip;
var Width:int;
var Height:int;

var debugText:TextField = new TextField();
//
var camera:Camera3D;
var root:Group;
var scene:Scene3D;
//
var camera2:Camera3D;
var root2:Group;
var scene2:Scene3D;
//
var box:Box;
var boxArray:Vector.<boxParticle> = new Vector.<boxParticle>;
var visibleBoxArray:Vector.<boxParticle> = new Vector.<boxParticle>

var particles:uint = 150;
var lookForward:Number = 2.5;
var road:Array = [
                       [   0,   0,   0], // start
    [    0,   0,  400],[   0, 100, 500], // anchor, end
    [    0, 300,  750],[   0,  50,1000],
    [    0,-450, 1500],[-500, -50,1500],
    [-1000, 450, 1500],[-1000,450,1000],
    [-1000, 450,    0],[-500, 225,-500],
    [    0,   0,-1000],[   0,   0,   0],
    [    0,   0,    0],[   0,   0,   0]
    ];
var roadTilt:Array = [
    [0,15],
    [0,10],[0,5],
    [0,4],[-0.5,6],
    [-0.6,8],[-0.7,10],
    [-0.7,15],[-0.6,20],
    [-0.5,15],[-0.4,15],
    [-0.8,20],[0,15]
    ];
var roadlength:int = 6;

function initialize():void {
  
    camera = new Camera3D( 465, 465);
    camera.x = 0;
    camera.y = 0;
    camera.z = 0;
    root = new Group();
    
    //camera.lookAt( 0, -150, 300);
    
    box = new Box("box", 10, 5, 20);
    box.y = 10;
    box.x = 200;
    box.z = 400;
    
    var mat:ColorMaterial = new ColorMaterial ( 0x7FDDFF );
            mat.attributes = new MaterialAttributes (
            new LightAttributes ());
            mat.lightingEnable = true;
    box.appearance = new Appearance (mat);
    
    root.addChild(box);
    
    scene = new Scene3D( "scene", clip3, camera, root );
    
    for(var i:int=0;i<particles;i++){
        for(var h:int=-4;h<=4;h++){
            var p:boxParticle = new boxParticle();   
           
            boxArray.push(p);
            clip2.addChild(p);
        }
    }
    
    camera2 = new CameraMode7( 465, 465);
    camera2.x = 0;
    camera2.y = 500;
    camera2.z = 0;
    root2 = new Group();
    
    var box2:Box = new Box("box2",100,1000,100, "tri",2)
    box2.y = 500;
    box2.x = 200;
    box2.z = 800;
    box2.appearance = new Appearance (mat);
    box2.useSingleContainer = true;
    
    root2.addChild(box2);
    
    var box3:Box = new Box("box3",100,1000,100, "tri",2)
    box3.y = 500;
    box3.x = -200;
    box3.z = 800;
    box3.appearance = new Appearance (mat);
    box3.useSingleContainer = true;
    
    root2.addChild(box3);
    
    var bmd:BitmapData = new BitmapData(400, 400, false, 0xCCCCCCCC);
    var channels:uint = BitmapDataChannel.RED | BitmapDataChannel.BLUE | BitmapDataChannel.GREEN;
    bmd.perlinNoise(400, 400, 5, int(Math.random() * 10), true, true, channels, false, null);
             
    //bmd.colorTransform(new Rectangle(0, 0, 400, 400), new ColorTransform(1,1,0.3,1, 40,20,-10, 0));
    bmd.applyFilter(bmd, bmd.rect, new Point(), new ColorMatrixFilter([
                 .5,  .2, .1, 0, 0, // red
                 .5,  .5, .1, 0, 0, // green
                  0,  .1, .3, 0, 0, // blue
                  0,   0,  0, 1, 0] // alpha
                 )
                );
    
    
    var ground:Mode7 = new Mode7();
    ground.setBitmap(bmd, 2, true, false);
    ground.setHorizon(false);
    //ground.setNearFar (true)
    root2.addChild(ground); 
    
    scene2 = new Scene3D( "scene2", clip, camera2, root2 );    
}
var courseposition:Number = roadlength;
var coursepositionspeed:Number = 0;
//
var carHorizontal:Number = 0;
var carRot:Number = 0;
var carRotSpeed:Number = 0;
function EveryFrame(event:Event):void{
   
    debugText.text = "";
    
    // Car model positioning
    
    var carposition:Array = TrackMath(courseposition);
    var carposition2:Array = TrackMath(courseposition-0.01);
    
    box.x = carposition[0];
    box.y = carposition[1];
    box.z = carposition[2];
       
    box.lookAt(carposition2[0],carposition2[1],carposition2[2]);
  
    var rot:Number = Math.atan2(box.x-carposition2[0],box.z-carposition2[2]);
    var carRotZ:Number = Math.atan2(carposition2[2]-carposition[2],carposition2[0]-carposition[0])

    box.roll += carposition[3]*180/Math.PI;
    box.pan += (carRot-rot)*180/Math.PI;
    
    box.x += Math.sin(carRotZ)*carHorizontal*10*Math.cos(carposition[3]);
    box.y += Math.sin(carposition[3])*carHorizontal*10;
    box.z += Math.sin(carRotZ-Math.PI/2)*carHorizontal*10*Math.cos(carposition[3]);
    
    // Camera
    
    var camerapos:Array = TrackMath(courseposition-0.25);
    var camerapos2:Array = TrackMath(courseposition+0.05+Math.abs(coursepositionspeed)-0.25);
    var rotxz:Number = Math.atan2(camerapos2[0]-camerapos[0],camerapos2[2]-camerapos[2])
    camerapos[1] += Math.sin(camerapos[3]+Math.PI/2)*50;
    
    camerapos2[1] += Math.sin(camerapos[3]+Math.PI/2)*50;
    
    camera.x += (camerapos[0]-camera.x)/2.5;
    camera.y += (camerapos[1]-camera.y)/2.5;
    camera.z += (camerapos[2]-camera.z)/2.5;
    camera.lookAt((camerapos2[0]+box.x)/2,(camerapos2[1]+box.y+50)/2,(camerapos2[2]+box.z)/2);
    
    // keys
    
    if(isDown(Keyboard.UP)){     
        coursepositionspeed+=0.005;
    }
    if(isDown(Keyboard.DOWN)){      
        coursepositionspeed-=0.005;
    }
    
    if(isDown(Keyboard.RIGHT)){     
       carRotSpeed += 0.05;
    }
    if(isDown(Keyboard.LEFT)){     
        carRotSpeed -= 0.05;
    }
    carRotSpeed *= 0.6;
    carRot += carRotSpeed;
    coursepositionspeed *= 0.8;
    
    // car movement
    
    var currentposition:Array = TrackMath(courseposition);
    var forwardposition:Array = TrackMath(courseposition+0.2);
    var dx:Number = forwardposition[0]-currentposition[0];
    var dy:Number = forwardposition[1]-currentposition[1];
    var dz:Number = forwardposition[2]-currentposition[2];
    var d:Number = Math.sqrt(dx*dx+dy*dy+dz*dz);
    
    var rotXZ:Number = Math.atan2(-dx,-dz);
    
    // may want to change how this is calculated....
        courseposition -= Math.cos(carRot-rotXZ)*coursepositionspeed*1000*(0.2/d); 
        carHorizontal +=  Math.sin(carRot-rotXZ)*coursepositionspeed*50;
    
    // walls on left and right side
    carHorizontal = Math.min(carHorizontal,currentposition[4]/2-1);
    carHorizontal = Math.max(carHorizontal,-currentposition[4]/2+1);
    // add (possible) falling off of track maybe?
    
    
    if(courseposition <= roadlength){
        courseposition += roadlength; 
    }
    
    // constuct the track
    
   var p:boxParticle
   
    var rotX:Number = 0;
    var rotY:Number = 0;
    var rotZ:Number = 0;
    
   var newpx:Number = 0;
   var newpy:Number = 0;
   var newpz:Number = 0;
    
   var oldpx:Number = 0;
   var oldpy:Number = 0;
   var oldpz:Number = 0;
    
    var h:int = -4;
    var i:int = 0;
    for each(p in boxArray){
        h++;
        
        if(h>4){
        
            var positions:Array = TrackMath(i/(particles/lookForward)+Math.floor(courseposition*lookForward)/lookForward-0.5);
        
            oldpx = newpx;
            oldpy = newpy;
            oldpz = newpz;
           newpx = positions[0];
           newpy = positions[1];
           newpz = positions[2];
            if(i==0){
                var positions2:Array = TrackMath((i-1)/(particles/lookForward)+courseposition-0.5);
        
                oldpx = positions2[0];
                oldpy = positions2[1];
                oldpz = positions2[2];
                //newpy -= 1000;
            }
            rotY = Math.atan2(newpx-oldpx,newpy-oldpy);
            rotZ = Math.atan2(oldpz-newpz,oldpx-newpx);
            rotX = positions[3];
            var roadwidth:Number = positions[4];
         
            i++;
            h = -4;
        } 
        p.px = newpx+Math.sin(rotZ)*h*roadwidth*Math.cos(rotX);
        p.py = newpy+Math.sin(rotX)*h*roadwidth;
        p.pz = newpz+Math.sin(rotZ-Math.PI/2)*h*roadwidth*Math.cos(rotX);         
        if(h == -4 || h == 4){
            p.py += 8;
            p.size = 5;
            p.red = 144+(i%3)*14;
            p.green = 144+(i%3)*8;
            p.blue = 144;
        }else{
            p.size = 10;
            p.red = 118;
            p.green = 124+((h+i)%3)*5;
            p.blue = 184;
        }
    }
    
    // render everything
   
    camera2.y = camera.y;
    camera2.x = camera.x;
    camera2.z = camera.z;
    camera.moveForward(100);
    camera2.lookAt(camera.x,camera.y,camera.z);
    camera.moveForward(-100);
    camera2.y += 500;
    
    scene2.render();  
    scene.render();
    clip2.graphics.clear();
    for each(p in boxArray){
        SortBox(p, camera);   
    }
    boxArray.sort(Zsort);
    function Zsort(p1:boxParticle, p2:boxParticle):Number{
        if (p1.depth < p2.depth)
          return 1;
        else if (p1.depth > p2.depth)
          return -1;
        else
          return 0;
    }
    for each(p in boxArray){
        DrawBox(p, clip2);   
    }
    
}

function SortBox(_box:boxParticle, camera:Camera3D):void{
            var _v:Vertex = new Vertex(_box.px,_box.py,_box.pz);
            var m:Matrix4 = camera.invModelMatrix;
            _v.wx = _v.x * m.n11 + _v.y * m.n12 + _v.z * m.n13 + m.n14;
            _v.wy = _v.x * m.n21 + _v.y * m.n22 + _v.z * m.n23 + m.n24;
            _v.wz = _v.x * m.n31 + _v.y * m.n32 + _v.z * m.n33 + m.n34;
            camera.projectVertex(_v);
            _box.depth = _v.wz+_v.sx/1000;
            _box.sx = _v.sx;
            _box.sy = _v.sy;
            _box.wz = _v.wz;
}  
function DrawBox(_box:boxParticle, _clip:MovieClip):void{
            if(_box.wz >= camera.near && _box.wz <= camera.far){
                var fadeout:Number = 1/(_box.wz/400);
                fadeout = Math.max(fadeout,0);
                fadeout = Math.min(fadeout,1);
                var _color:uint = 
                _box.red*fadeout+200*(1-fadeout) << 16 
                | _box.green*fadeout+200*(1-fadeout) << 8 
                | _box.blue*fadeout+205*(1-fadeout);
                _clip.graphics.beginFill(_color);
                var _size:Number = _box.size*1000/_box.wz;
                _clip.graphics.drawRect( _box.sx-_size/2, _box.sy-_size/2, _size, _size); 
                _clip.graphics.endFill();
           }
}    
function TrackMath(_position:Number):Array{
     var c:Number = Math.floor(_position)%roadlength;
     var a:Number = _position%1;
     var b:Number = 1-a;
        
     var px:Number = a*a*road[2+c*2][0]+2*a*b*road[1+c*2][0]+b*b*road[0+c*2][0];
     var py:Number = a*a*road[2+c*2][1]+2*a*b*road[1+c*2][1]+b*b*road[0+c*2][1];
     var pz:Number = a*a*road[2+c*2][2]+2*a*b*road[1+c*2][2]+b*b*road[0+c*2][2];
     
     // derivative isn't working for some reason...
     
     // (2*c+4*b+2*a)*x-2*c-2*b
     // 2*b*y+2*a*x
     
     //var dx:Number = 2*road[2+c*2][0]*a + 2*road[1+c*2][0]*b + 2*road[1+c*2][0]*a + 2*road[0+c*2][0]*b;
     //var dy:Number = 2*road[2+c*2][1]*a + 2*road[1+c*2][1]*b + 2*road[1+c*2][1]*a + 2*road[0+c*2][1]*b;
     //var dz:Number = 2*road[2+c*2][2]*a + 2*road[1+c*2][2]*b + 2*road[1+c*2][2]*a + 2*road[0+c*2][2]*b;
     //var dx:Number = (2*road[0+c*2][0]+4*road[1+c*2][0]+2*road[2+c*2][0])*a - 2*road[0+c*2][0] - 2*road[1+c*2][0];
     //var dy:Number = (2*road[0+c*2][1]+4*road[1+c*2][1]+2*road[2+c*2][1])*a - 2*road[0+c*2][1] - 2*road[1+c*2][1];
     //var dz:Number = (2*road[0+c*2][2]+4*road[1+c*2][2]+2*road[2+c*2][2])*a - 2*road[0+c*2][2] - 2*road[1+c*2][2];
     
     var roll:Number  = a*a*roadTilt[2+c*2][0]+2*a*b*roadTilt[1+c*2][0]+b*b*roadTilt[0+c*2][0];
     var width:Number = a*a*roadTilt[2+c*2][1]+2*a*b*roadTilt[1+c*2][1]+b*b*roadTilt[0+c*2][1];
     // to add later, other things (like boolean for walls existing, or halfpipe/cylinder
    
     return [px,py,pz,roll,width]
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
    public var sx:Number;
    public var sy:Number;
    public var wz:Number;
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
    


