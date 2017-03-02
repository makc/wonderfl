package {
 
     /*
     Pedobear Metaballs
     The devil who sat on my shoulder said "go on, you can do it. Make a Pedobear metaball"
     So here it is. Devious devil sated.
     Quick bit of Friday Fun.
     by @Swingpants  http://www.swingpants.com  http://www.twitter.com/swingpants
     
     */
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import net.hires.debug.Stats;
 
    public class Main extends Sprite 
    {
        
        private var imgURL:String="http://www.swingpantsflash.com/images/pedobear_sm.png"
        
        private var numBalls:int=5
        private var balls:Array=[];
        private var displayBears:Array=[];
        private var ballBearContainer:Sprite;
        private var canvas:BitmapData;
        private var paletteArray:Array;
        private const ZERO_POINT:Point = new Point()
        
        private var pedoBear:Bitmap
        
        public function Main() 
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE , imageLoadedHandler);
            loader.load(new URLRequest(imgURL), new LoaderContext(true));
        }
        
        
        private function imageLoadedHandler(event:Event):void 
        {
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            
            loaderInfo.removeEventListener(Event.COMPLETE , imageLoadedHandler);
            
            pedoBear = loaderInfo.content as Bitmap;
            
            createBears()
        }
        
        private function createBears():void
        {
            ballBearContainer = new Sprite();
            ballBearContainer.filters = [new GlowFilter(0xFF, 1, 100, 100, 2, 2, false, false)]
            
            canvas = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
            addChild(new Bitmap(canvas));
            
            var i:int;
            for (i = 0; i < numBalls; i++) { addBear() }
            
            // Loop through palette array and apply colours
            paletteArray = new Array(256);
            for (i = 0; i < 256; i++) 
                {
                    if(i<120){ paletteArray[i] = 0x38200E; } //Dark brown bg
                    else if (i < 142) { paletteArray[i] = 0x0; }//Black border
                    else { paletteArray[i] = 0x8b5531; } //Pedobear brown
                }
            
            addEventListener(Event.ENTER_FRAME, update);
            
            //addChild(new Stats())
        }
        
        private function update(event:Event):void 
        {
            var len:int = balls.length
            var diffx:Number
            var diffy:Number
            
            for (var i:int = 0; i < len; i++)
            {
                balls[i].update();
                
                for (var j:int = i+1; j < len; j++)
                    {
                        if (i != j)
                            {
                                    diffx = balls[i].x - balls[j].x
                                    diffy = balls[i].y - balls[j].y
                                    if (diffx * diffx + diffy * diffy < 9000) //Lightweight proximity check
                                        {
                                            solveBearCollisions(balls[i], balls[j], Math.sqrt(diffx * diffx + diffy * diffy))
                                        }
                            }
                    }
                displayBears[i].x=balls[i].x
                displayBears[i].y=balls[i].y
                displayBears[i].rotation = balls[i].rotation
            }
            
            // Draw ball bears onto canavs then apply the palette map
            canvas.lock();
            canvas.fillRect(canvas.rect, 0xFF000000);
            canvas.draw(ballBearContainer);
            canvas.paletteMap(canvas, canvas.rect, ZERO_POINT, null, null, paletteArray, null);
            canvas.unlock();
        }
        
        private function addBear():void
        {
            var x:Number = Math.random() * stage.stageWidth;
            var y:Number = Math.random() * stage.stageHeight;
            
            var bear:Bitmap = new Bitmap(pedoBear.bitmapData)

            var bearContainer:Sprite
            var ballBear:Bear = new Bear(bear.bitmapData, x, y, stage.stageWidth, stage.stageHeight);
            ballBearContainer.addChild(ballBear);
            balls.push(ballBear);
            
            bearContainer=new Sprite()
            bear.smoothing = true
            bear.scaleX = bear.scaleY = 1.08
            bear.x=-bear.width*0.5
            bear.y = -bear.height * 0.5
            bearContainer.addChild(bear)
            displayBears.push(bearContainer)
    
            addChild(bearContainer)
        }
        

        private function solveBearCollisions ( bear1: Bear, bear2:Bear, distance:Number) : void
        {
            //Calc distances
            var distance_x:Number = bear2.x - bear1.x;//diff on the x axis
            var distance_y:Number = bear2.y - bear1.y;//diff on the y axis
            
            // find the angle between the balls
            var angle:Number = Math.atan2(distance_y, distance_x);

            var cosa:Number = Math.cos(angle);
            var sina:Number = Math.sin(angle);
                
            // find the current linear momentum on each axis for each ball
            var vx1p:Number = cosa * bear1.vx + sina * bear1.vy;
            var vy1p:Number = cosa * bear1.vy - sina * bear1.vx;
            var vx2p:Number = cosa * bear2.vx + sina * bear2.vy;
            var vy2p:Number = cosa * bear2.vy - sina * bear2.vx;

            var momentum:Number = vx1p*bear1.radius  + vx2p*bear2.radius ;
            var velocity:Number = vx1p - vx2p;

            vx1p = (momentum - velocity * bear2.radius)/(bear1.radius + bear2.radius);
            vx2p = velocity + vx1p;

            //trecalc speed post collision
            bear1.vx = cosa * vx1p - sina * vy1p;
            bear1.vy = cosa * vy1p + sina * vx1p;
            bear2.vx = cosa * vx2p - sina * vy2p;
            bear2.vy = cosa * vy2p + sina * vx2p;

            // Find the midpoint
            var diff:Number = ((bear1.radius+bear2.radius)-distance)*0.5
            var cosd:Number = cosa * diff;
            var sind:Number = sina * diff;

            // update the ball positions
            bear1.x -= cosd;
            bear1.y -= sind;
            bear2.x += cosd;
            bear2.y += sind;
        }
    }
}   
 import flash.display.Bitmap;
 import flash.display.BitmapData;
 import flash.display.Sprite;      
    
    class Bear extends Sprite 
    {
        private var xMax:Number;
        private var yMax:Number;
        private var xMin:Number;
        private var yMin:Number;
        public var vx:Number;
        public var vy:Number;
        
        public var radius:Number;
        
        private var bearBMD:BitmapData
        
        public function Bear(bmd:BitmapData, posx:Number, posy:Number, maxX:Number, maxY:Number) 
        {
            this.x = posx;
            this.y = posy;
            xMax = maxX - bmd.width * 0.5;
            yMax = maxY - bmd.width * 0.5;
            xMin = yMin = bmd.width * 0.5
            
            //random velocity
            vx = Math.random() * 8 - 4;
            vy = Math.random() * 8 - 4;
            
            //Assign a radius for collision calcs
            radius = bmd.width*0.5 

            //Add bear gfx
            var bmp:Bitmap = new Bitmap(bmd)
            bmp.x = -bmd.width * 0.5
            bmp.y = -bmd.height * 0.5
            addChild(bmp)
        }
        
        public function update():void 
        {
            // move the ball
            x += vx;
            y += vy;
            this.rotation -= 1 * vx
            
            // check for the ball hitting the bounds of the display
            if (x < xMin) {x=xMin; vx = -vx;}
                else if (x > xMax) {x=xMax; vx = -vx;}
            if (y < yMin) {y=yMin; vy = -vy;}
                else if (y > yMax) {y=yMax; vy = -vy;}
        }
        
    }
    
