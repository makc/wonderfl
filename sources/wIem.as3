/**
* 
* Sample code for FITC
* Smoke particle effect
* 
*/
package {
    import flash.display.Sprite;    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.ByteArray;
    
    public class FlashTest extends Sprite {
       //View
        protected var canvas:BitmapData;
        protected var canvasBitmap:Bitmap;
        
        //BitmapData that contains the actual froce that is applied to particles.
        protected var forceMap:BitmapData;
        
        //BitmapData that contains the force of the storm.
        protected var stormMap0:BitmapData;
        protected var stormMap1:BitmapData;
        
        //BitmapData that contains the mouse repulsion force of the stage.
        protected var repulsionMap:BitmapData;
        protected var repulsionHistoryMap:BitmapData;
        protected var repulsionFadeMap:BitmapData;
        
        //the number of particles. 5000-200000
        protected var particleNum:int = 10000;
        protected var particles:Vector.<Particle>
        
        //
        protected var stormScaleRatioX:Number;
        protected var stormScaleRatioY:Number;
        protected var stormCycle:Number = 0;
        
        //color transform that guradually changes canvas.
        protected var fadeCanvasColt:ColorTransform;
        protected var canvasBlurFilter:BlurFilter;
        
        //temporaly variables
        protected var tempColt:ColorTransform = new ColorTransform();
        protected var tempPt:Point = new Point();
        protected var tempMat:Matrix = new Matrix();
        
        public function FlashTest() {
            init();
            reset();
        }
        
        protected function init():void
        {
            //build View
            canvasBitmap = new Bitmap(null, "auto", false);
            // because canvas is 25% size of screen, we make view 400% bigger.
            canvasBitmap.scaleX = 4;
            canvasBitmap.scaleY = 4;
            addChild(canvasBitmap);
            
            //initialize the map that contains force of the storm;
            stormMap0 = new BitmapData(256,256,false,0x000000);
            stormMap0.perlinNoise(128,128,3,Math.random()*100,false,true,3,false);
            stormMap1 = new BitmapData(256,256,false,0x000000);
            stormMap1.perlinNoise(128,128,3,Math.random()*100,false,true,3,false);
            
            //
            forceMap = new BitmapData(256,256,false,0x000000);
            
            //initialize repulsionMap
            repulsionHistoryMap = new BitmapData(256,256,false,0x000000);
            repulsionFadeMap = new BitmapData(256,256,true,0x20808000);
            repulsionMap = new BitmapData(256,256,false,0);
            
            /**
            * First we preculculate the repulsion force field that mouse cursor generates as a bitmapdata. 
            * Red channel of bitmap data contains horizontal force.
            * Green channel of bitmap data contains vertical force. 
            */
            var dx:int, dy:int;
            var dist:Number, fx:Number, fy:Number;
            var col:int;
            for(var yy:int=0; yy<256; yy++)
            {
                for(var xx:int=0; xx<256; xx++){
                    dx = xx-128;
                    dy = yy-128;
                    dist = Math.sqrt(dx*dx+dy*dy);
                    if(dist<1){
                        fx = 0;
                        fy = 0;
                    }else{
                        fx = dx / dist / dist / dist * 50000;
                        fy = dy / dist / dist / dist * 50000;
                    }
                    fx = (fx<-128)? -128 : (fx>127)? 127 : fx;
                    fy = (fy<-128)? -128 : (fy>127)? 127 : fy;
                    fx += 128;
                    fy += 128;
                    col = (fx<<16) + (fy<<8)
                    repulsionMap.setPixel(xx,yy,col);
                }
            }
            //You can see 
            canvasBitmap.bitmapData = repulsionMap;
            
            //initialize particle
            particles = new Vector.<Particle>(particleNum);
            
            var particle:Particle;
            var rr:int;
            for(var i:int=0; i<particleNum; i++)
            {
                particle = new Particle();
                particle.x = Math.random() * stage.stageWidth >> 2;
                particle.y = Math.random() * stage.stageHeight >> 2;
                
                //Customize the range of the particle color according to the amount of the particle and stage size.
                particle.r = particle.g = particle.b = Math.min(Math.random()*8+4,255);  
                
                //Customize the rage of the scaleFactor according to the amount of the particle and stage size.
                particle.scaleFactor = (Math.random()*0.1 + 0.95) * 0.003;
                particles[i] = particle;
            }
            
            fadeCanvasColt = new ColorTransform(1,1,1,1,-2,-1,-1,0);
            canvasBlurFilter = new BlurFilter(2,2,3);
            
            //set event listeners
            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(Event.RESIZE, resizeHandler);
        }
        
        /**
        *
        * Called when you need reset the view. E.G. resizing screen.
        */
        protected function reset():void
        {
            if(canvas)
                canvas.dispose();
                
            //build view, to optimize we use 25% size BitmapData of actual screensize.
            canvas = new BitmapData((stage.stageWidth>>2)+1, (stage.stageHeight>>2)+1, false, 0x000000);
            canvasBitmap.bitmapData = canvas;
            
            //precalculate ratio that converts screen coordinate to stomMapBitmap coodinate;
            stormScaleRatioX = 1 / (stage.stageWidth>>2)*255;
            stormScaleRatioY = 1 / (stage.stageHeight>>2)*255;
            
           //canvasBitmap.bitmapData = stormMap1;  //if you want to see stormMap;
           //canvasBitmap.bitmapData = repulsionHistoryMap;
           //canvasBitmap.bitmapData = forceMap; //if you want to see forceMap;
           
           //canvasBitmap.scaleX = 1;
           //canvasBitmap.scaleY = 1;
        }
        
        
        //We rebuild screen when swf is reseized.
        //It is not required if you only run it on wonderfl.
        protected function resizeHandler(e:Event):void
        {
            reset();
        }

        
        //Update storm and particle every frame.
        protected function enterFrameHandler(e:Event):void
        { 
           updateStormMap();
           updateRepulsionMap();
           updateForceMap();
           updateParticles();
        }
        
        /**
        * We calculate current forcefielde's state by blending two stormMap.
        * Therefore force field gradually changes every frame.
        */
        protected function updateStormMap():void
        {
            stormCycle++;
            if(stormCycle == 180){
                stormMap0.perlinNoise(256,256,3,Math.random()*100,false,true,3,false);
            }else if(stormCycle==360){
                stormMap1.perlinNoise(256,256,3,Math.random()*100,false,true,3,false);
                stormCycle = 0;
            }
        }
        
        /**
        * We update repulsionMap according to the current mouse position.
        */
        protected function updateRepulsionMap():void
        {
            tempMat.a = 1;
            tempMat.b = 0;
            tempMat.c = 0;
            tempMat.d = 1;
            tempMat.tx = 0;
            tempMat.ty = 0;
            
            repulsionHistoryMap.draw(repulsionFadeMap, tempMat);
            
            tempMat.translate(-128,-128);
            
            tempMat.scale(1/stormScaleRatioX, 1/stormScaleRatioY);
            tempMat.translate(mouseX/4*stormScaleRatioX, mouseY/4*stormScaleRatioY);
            repulsionHistoryMap.draw(repulsionMap, tempMat, null, BlendMode.HARDLIGHT);
        }
        
        protected function updateForceMap():void
        {
            //generate current force fieldes state with blending two stormMaps.
            forceMap.copyPixels(stormMap1, stormMap0.rect, tempPt);
            tempColt.alphaMultiplier = Math.cos(stormCycle*Math.PI/180)*0.5+0.5;
            forceMap.draw(stormMap0, null, tempColt);
            
            //add mouse repulsion force
            forceMap.draw(repulsionHistoryMap,null,null,BlendMode.HARDLIGHT);
            forceMap.draw(repulsionHistoryMap,null,null,BlendMode.HARDLIGHT);
        }
        
        protected function updateParticles():void
        {
            var forceBytes:ByteArray = forceMap.getPixels(forceMap.rect);
            
            var stageW:int = canvas.width;
            var stageH:int = canvas.height;
            var loopW:int = stageW-1;
            var loopH:int = stageH-1;
            var byteIndex:int;
            
            canvas.lock();
            canvas.colorTransform(canvas.rect, fadeCanvasColt);
            
            //Update Paritcle position and draw.
            var col:int, r:int, g:int, b:int;
            for(var i:int=0; i<particleNum; i++)
            {
                var prt:Particle = particles[i];
                byteIndex = (int(prt.y*stormScaleRatioY)*256 + int(prt.x*stormScaleRatioX))<<2;
                prt.vx = prt.vx * 0.96 + (forceBytes[byteIndex+1]-128)*prt.scaleFactor;
                prt.vy = prt.vy * 0.96 + (forceBytes[byteIndex+2]-128)*prt.scaleFactor;
                prt.x += prt.vx;
                prt.y += prt.vy;
                if(prt.x<0){
                    prt.x = loopW;
                }else if(prt.x > loopW){
                    prt.x = 1;
                }
                if(prt.y<0){
                    prt.y = loopH;
                }else if(prt.y > loopH){
                    prt.y = 1;
                }
                
                //Self implimentation of addtive color blend mode.
                //Because there is too many particle, blending particle with low brightness color is much effective.
                col = canvas.getPixel(int(prt.x), int(prt.y));
                r = (col>>16&0xff) + prt.r;
                g = (col>>8&0xff) + prt.g;
                b = (col&0xff) + prt.b;
                r = (r<0xff)? r : 0xff;
                g = (g<0xff)? g : 0xff;
                b = (b<0xff)? b : 0xff;
                canvas.setPixel(int(prt.x), int(prt.y), (r<<16)|(g<<8)|b);
            }
            canvas.applyFilter(canvas, canvas.rect, tempPt, canvasBlurFilter);
            canvas.unlock();
        }
    }
    
}


class Particle
{
    //particle position
    public var x:Number = 0;
    public var y:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    
    //particle color
    public var r:int;
    public var g:int;
    public var b:int;
    
    //scale factor that affects the force applied to the particle.
    public var scaleFactor:Number;
}