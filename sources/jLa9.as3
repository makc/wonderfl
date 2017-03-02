// forked from checkmate's fladdict challenge for professionals
/**
 * Theme:
 * Play with BitmapPatterBuilder.
 * Purpose of this trial is to find the possibility of the dot pattern.
 *
 * by Takayuki Fukatsu aka fladdict
 **/
  /**
 * Cityscape Maker v0.1
 * 3D Cityscape, with dot pattern windows and 3D fly - To do: Camera flybys.
 *
 * by Swingpants
 **/
package 
{ 
    import flash.display.Sprite; 
    import flash.display.MovieClip;
    import flash.display.BitmapData 
    import flash.events.Event; 
    import flash.display.Graphics;
    import flash.display.StageQuality 
    import flash.text.*; 
    import flash.geom.Point;
    import org.papervision3d.materials.ColorMaterial; 
    import org.papervision3d.objects.primitives.Plane; 
    import org.papervision3d.objects.primitives.Cube; 
    import org.papervision3d.objects.primitives.Cylinder; 
    import org.papervision3d.scenes.Scene3D; 
    import org.papervision3d.view.Viewport3D; 
    import org.papervision3d.cameras.Camera3D; 
    import org.papervision3d.render.BasicRenderEngine; 
    import org.papervision3d.materials.shadematerials.FlatShadeMaterial
    import org.papervision3d.materials.utils.MaterialsList
    import org.papervision3d.materials.special.CompositeMaterial
    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.materials.BitmapMaterial
    import org.papervision3d.materials.*
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.objects.DisplayObject3D
    
    import caurina.transitions.*;
    
    import net.hires.debug.Stats;

  

    [SWF(width=480, height=480, backgroundColor=0x000000)] 

    public class Professional extends Sprite 
    { 
        private var tf:TextField=new TextField()
        public var renderer:BasicRenderEngine = new BasicRenderEngine();; 
        public var camera:Camera3D = new Camera3D(); 
        public var viewport:Viewport3D = new Viewport3D(600,600); 
        public var scene:Scene3D = new Scene3D(); 

        public var mat:ColorMaterial = new ColorMaterial(0xFF0000); 
        public var cubeMat:CompositeMaterial
        public var materialsList:MaterialsList = new MaterialsList();

        public var cube:Cube
        public var cylinder:Cylinder
        public var cubeSize:int=200
        
        public var panelMaterial:BitmapMaterial
        
        public var container3d:DisplayObject3D=new DisplayObject3D()
		
	public var window_pattern1:Array=[
						[0,0,0,0,0,0],
						[0,1,1,1,1,0],
						[0,1,2,2,1,0],
						[0,1,2,2,1,0],
						[0,1,1,1,1,0],
						[0,0,0,0,0,0]]
        public var window_pattern2:Array=[
						[2,2,2,2,2,2],
						[2,1,1,1,1,2],
						[2,1,1,1,1,2],
						[2,1,1,1,1,2],
						[2,1,1,1,1,2],
						[2,2,2,2,2,2]]
        public var window_pattern3:Array=[
						[1,1,1,1,1,1],
						[1,0,0,0,0,1],
						[1,0,0,0,0,1],
						[1,0,0,0,0,1],
						[1,0,0,0,0,1],
						[1,0,0,0,0,1]]
        public var window_pattern4:Array=[
						[1,1,1,1,1,1],
						[2,1,0,0,0,1],
						[2,0,1,0,0,1],
						[2,0,0,1,0,1],
						[2,0,0,0,1,1],
						[2,2,2,2,2,1]]
        public var window_pattern5:Array=[
						[0,0,0,0,0,0],
						[0,0,0,0,0,0],
						[0,0,1,1,1,0],
						[0,0,1,2,1,0],
						[0,0,1,1,1,0],
						[0,0,0,0,0,0]]
        public var windows:Array=[window_pattern1,window_pattern2,window_pattern3,window_pattern4,window_pattern4]
						
	private var col1:uint=0xff000000;
        private var col2:uint=0xff555555;
        private var col3:uint=0xffDDDDDD;

        private var colour_array:Array=[col1,col2,col3]	
        
        private var dir:int=15;
        
        private const maxNumLevels:int=5
        private const maxBaseSize:int=125
        private var buildingLevels:Array=[]
        
        private var buildings:Array=[]
        
        private var grid_width:int=5
        private var grid_height:int=6 
        
        private var cam_horiz:Boolean=false
        private var cam_pos:Point=new Point(Math.floor(grid_width/2),0)
        private var cam_target:Point=new Point(cam_pos.x,Math.floor(grid_height/2))
        
        private var diff:Number
        
        

        public function Professional() 
        { 
            scene.addChild(container3d)
            
            camera.x = 30;
            camera.y = 100
	    camera.z = -15*cubeSize;
            
	    camera.zoom = 30;
	    camera.focus = 60;
            //camera.lookAt(container3d)
            
            addChild(viewport) 
            
            createCityGrid(grid_width,grid_height) //Build the city
            addEventListener(Event.ENTER_FRAME,oef); 
            
            tf.textColor=0xffffff
            addChild(tf)
            
            stage.quality=StageQuality.LOW
            //var s:Stats = new Stats();
            //addChild(s);
        }
        
        public function createCityGrid(rows:int,cols:int):void
        {
            buildings=[]
             for(var i:int=0;i<cols;i++)
                {
                    for(var j:int=0;j<rows;j++)
                        {
                            
                            var tower:DisplayObject3D=createBuilding()
                            tower.x=j*maxBaseSize*2//+maxBaseSize*4
                            tower.z=i*maxBaseSize*2//+maxBaseSize*4
                            container3d.addChild(tower)
                            buildings.push(tower)
                        }
                }
            container3d.x-=rows*maxBaseSize
        }
        
       
        //#######Testing logic to randomise buildings - still needs lots of tweaking########
        private function createBuilding():DisplayObject3D
        {
            var container:DisplayObject3D=new DisplayObject3D()
            var levels:int=Math.ceil(Math.random()*maxNumLevels)
            var maxHeight:int=levels*maxBaseSize*(0.5+(Math.random()*0.5))
            var rnd:int
            var w:int=maxBaseSize*0.75 + maxBaseSize*Math.random()*0.25
            var h:int=maxHeight*0.5 + maxHeight*Math.random()*0.5
            maxHeight-=h
            var d:int=maxBaseSize*0.5 + maxBaseSize*Math.random()*0.5
            var ypos:int=0
            var buildingLevels:Array=[]
            
            for(var i:int=0;i<levels;i++)
                {
                    ypos+=Math.ceil(h*0.5)
                    rnd=Math.floor(Math.random()*10)
                    switch(rnd) //Ropey method of slanting the results towards the cube and restricting the tapered cylinder - need to improve...
                        {
                            case 0://Cube
                            case 1:
                            case 2: 
                            case 3:
                            case 4:
                            case 5:
                            case 6:
                                buildingLevels.push(buildCube(w,d,h))
                                break;
                            case 7://Cylinder
                            case 8:
                                if(i==0)
                                    {
                                        buildingLevels.push(buildCylinder(w*0.5,h))
                                    }
                                    else
                                    {
                                        w*=0.7//Reduce size of cylinder if not 1st
                                        buildingLevels.push(buildCylinder(w,h))
                                     }
                                break;
                            case 9://Tapered cylinder
                                if(i!=0)w*=0.7//Reduce size of cylinder if not 1st
                                buildingLevels.push(buildCylinder(w,h,true))
                                w*=0.6
                                break;
                        }
                   
                    buildingLevels[i].y=ypos
                    ypos+=Math.ceil(h*0.5)
                    w*=0.4+Math.random()*0.4
                    d*=0.4+Math.random()*0.4
                    h=maxHeight*0.2+maxHeight*Math.random()
                    maxHeight-=h
                    
                    container.addChild(buildingLevels[i])
                }
            return container
        }
        
        private function clearBuilding():void
        {
            var len:int=buildingLevels.length
            for (var i:int=0;i<len;i++)
                {
                    container3d.removeChild(buildingLevels[i])
                }
            buildingLevels=[]
        }
        
        private function buildCylinder(r:Number=100,h:Number=1000,tapered:Boolean=false):Cylinder
        {
            var cyl:Cylinder=new Cylinder(createDotTexture(r,h,false),r,h,8,6,tapered?r*0.8:-1,true,false)
            
            return cyl
        }
        
        private function buildCube(w:int=200,h:int=200,d:int=200):Cube
        {

            var cubeMatList:MaterialsList = new MaterialsList( ); 
            var main_mat:BitmapMaterial=createDotTexture(w,h)
            cubeMatList.addMaterial( main_mat, "left" ); 
            cubeMatList.addMaterial( main_mat, "right" ); 
            cubeMatList.addMaterial( main_mat, "front" ); 
            cubeMatList.addMaterial( main_mat, "back" ); 
            cubeMatList.addMaterial( new ColorMaterial(0x333333,1), "top" );
            var cubeObj:Cube = new Cube( cubeMatList, w, h, d, 4, 4, 4, 0, Cube.BOTTOM); 
            // cubeObj.replaceMaterialByName(new ColorMaterial(0xff0000,1), "top");

            return cubeObj
        }
        
	public function createBitmapMaterialTexture():BitmapMaterial
        {
            var dot_pattern:Array=choosePattern()
             return new BitmapMaterial(BitmapPatternBuilder.build(dot_pattern, colour_array))
        }
	
        private function createDotTexture(w:int=200,h:int=200, useBorder:Boolean=true ,win_w:int=20,win_h:int=40):BitmapMaterial
        {
            var sprite:Sprite=new Sprite()

            var dot_pattern:Array=choosePattern()
            var border_col:uint=0x666666+Math.ceil(Math.random()*9)*0x111111 //Randomise the border colour (greyscale)
            
            sprite.graphics.beginBitmapFill(BitmapPatternBuilder.build(dot_pattern, colour_array));
            if(useBorder)sprite.graphics.lineStyle(5+Math.ceil(Math.random()*5), border_col); //If using a border then have one that is a random width from 5 to 10
            sprite.graphics.drawRect(0,0,w,h)
            sprite.graphics.lineStyle(5, 0xffffff);
            sprite.graphics.endFill()
            
            var bmd_w:int=w>10?w:10
            var bmd_h:int=h>10?h:10
            var bmd:BitmapData = new BitmapData(bmd_w, bmd_h, false, 0x00000000);
            bmd.draw(sprite)
            
            return new BitmapMaterial(bmd)
        }
        
        private function choosePattern():Array
        {
            var rnd:int=Math.floor(Math.random()*windows.length) //Randomly select the pattern to use
            return windows[rnd]
        }
        	
        private function createTexture(w:int=200,h:int=200, win_w:int=20,win_h:int=40):BitmapMaterial
        {
            w=w>50?w:50 //Set minimum size for width and height
            h=h>50?h:50
            var sprite:Sprite=new Sprite()
            
            
            sprite.graphics.lineStyle(10, 0xffffff);
            sprite.graphics.drawRect(0,0,w,h)
            sprite.graphics.lineStyle(5, 0xffffff);
            
            var win_gap_w:Number=win_w*0.25
            var win_gap_h:Number=win_h*0.25
            var columns:int=(w-win_w/2)/(win_w+win_gap_w)
            var rows:int=(h-win_h/2)/(win_h+win_gap_h)
            win_gap_w=(w-columns*win_w)/(columns+1)
            win_gap_h=(h-rows*win_h)/(rows+1)
            
            for (var i:int=0;i<columns;i++)
                {
                    for(var j:int=0;j<rows;j++)
                        {
                            sprite.graphics.drawRect(win_gap_w+i*(win_w+win_gap_w), win_gap_h+j*(win_h+win_gap_h),win_w,win_h)
                        }
                }

            var bmd:BitmapData = new BitmapData(200, 200, false, 0x00000000);
            bmd.draw(sprite)
            return new BitmapMaterial(bmd)
        }
        
        private function rotateAndRaiseCamera():void
        {
            camera.y+=dir
            if(camera.y>1500 || camera.y<50) dir=-dir //Swing camera up and down

            camera.lookAt(container3d)          
            container3d.rotationY+=1.5; 
        }
        //###########CODE TO TRAVEL THROUGH CITY STREETS
        private function tweenToNextPoint():void
        {
            
            Tweener.addTween(camera,{x:maxBaseSize*2*cam_target.x, z:maxBaseSize*2*cam_target.y,time:diff*0.75,onComplete:rotateToDirection})
        }
        
        private function rotateToDirection():void
        {
            var to_x:int=cam_pos.x
            var to_y:int=cam_pos.y
   
            
            if(cam_horiz)
                {
                    to_x=1+Math.floor(grid_width-1)
                    if(to_x==cam_pos.x)
                        {
                           if((grid_width-to_x)>grid_width*0.5){to_x-=1}
                               else{to_x+=1}
                        }
                    diff=Math.abs(cam_pos.x-to_x)
                }
                else
                {
                    to_y=1+Math.floor(grid_height-1)
                    if(to_y==cam_pos.y)
                        {
                           if((grid_height-to_x)>grid_height*0.5){to_y-=1}
                               else{to_y+=1}
                        }
                    diff=Math.abs(cam_pos.y-to_y)
                }
             cam_target.x=to_x
             cam_target.y=to_y
             
             Tweener.addTween(camera,{rotationY:angleToPoint(cam_pos,cam_target)-90,time:0.75,onComplete:tweenToNextPoint})
             
             tf.text="ang:"+angleToPoint(cam_pos,cam_target)
         }
         
         public function angleToPoint(from:Point, to:Point):Number
		{
			var dx:Number = to.x - from.x
			var dy:Number = to.y - from.y

			return Math.atan2(dy,dx) *57.29577951308232   //  180/Math.PI=57.29577951308232
		}

        //##############OEF LOOP
        private function oef(evt:Event):void
	{ 
            rotateAndRaiseCamera()
            //rotateToDirection()
 
            renderer.renderScene(scene,camera,viewport); 
        } 
    } 
} 

/**-----------------------------------------------------
 * Use following BitmapPatternBuilder class 
 * 
 * DO NOT CHANGE any codes below this comment.
 *
 * -----------------------------------------------------
*/
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
    
class BitmapPatternBuilder{
    /**
     * creates BitmapData filled with dot pattern.
     * First parameter is 2d array that contains color index for each pixels;
     * Second parameter contains color reference table.
     *
     * @parameter pattern:Array 2d array that contains color index for each pixel.
     * @parameter colors:Array 1d array that contains color table.
     * @returns BitmapData
     */
    public static function build(pattern:Array, colors:Array):BitmapData{
        var bitmapW:int = pattern[0].length;
        var bitmapH:int = pattern.length;
        var bmd:BitmapData = new BitmapData(bitmapW,bitmapH,true,0x000000);
        for(var yy:int=0; yy<bitmapH; yy++){
            for(var xx:int=0; xx<bitmapW; xx++){
                var color:int = colors[pattern[yy][xx]];
                bmd.setPixel32(xx, yy, color);
            }
        }
        return bmd;
    }
    
    /**
     * short cut function for Graphics.beginBitmapFill with pattern.
     */
    public static function beginBitmapFill(pattern:Array, colors:Array, graphics:Graphics):void{
        var bmd:BitmapData = build(pattern, colors);
        graphics.beginBitmapFill(bmd);
        bmd.dispose();        
    }
}