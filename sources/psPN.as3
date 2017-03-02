package {
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.LineScaleMode;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.BlurFilter;
    import flash.filters.BevelFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    [SWF(width=465,height=465,backgroundColor=0x666666,frameRate=60)]
    public class liquidRect extends Sprite {
        private var loader:Loader;
        private var dots:Array = new Array();
        private var mid:Array = new Array();
        private var dotPerPixel:Number = 1;
    
        private var leavesBitmap:Bitmap;
        private var leavesBaseMap:BitmapData;
        private var leaves:MovieClip = new MovieClip();
        private var logo:MovieClip = new MovieClip();
        private var m:Matrix;
        private var tempMap:BitmapData;
        private var displaceMap:BitmapData;
        private var mergeBitmap:Bitmap;
        private var mergeMap:BitmapData;
        private var displaceFilter:DisplacementMapFilter;
        private var blurFilter:BlurFilter = new BlurFilter (1.5, 1.5, 1.5);
        private var zero:Point;
        
        // lqd attributes
        private var w:Number = 300;
        private var h:Number = 50;
        private var bmpPaddingX:Number = 0;
        private var bmpPaddingY:Number = 0;
    
        public function liquidRect() {
            Wonderfl.capture_delay( 30 );
            loader = new Loader();
            var requestPic:URLRequest = new URLRequest();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            requestPic.url = "http://assets.wonderfl.net/images/related_images/4/42/42c0/42c01a397b5136d63ffc61fc1b2caf05db124635";
            loader.load(requestPic, new LoaderContext(true));
        }
        
        public function init(e:Event):void
        {
            leavesBitmap = Bitmap(loader.content);
            leavesBaseMap = leavesBitmap.bitmapData;
            
            bmpPaddingX = stage.stageWidth/2 - leavesBitmap.width/2;
            bmpPaddingY = stage.stageHeight/2 - leavesBitmap.height/2;
            
            leavesBitmap.x = bmpPaddingX;
            leavesBitmap.y = bmpPaddingY;
            
            moveTo(stage.stageWidth/2 - w/2, stage.stageHeight/2 - h/2);
            lineTo(stage.stageWidth/2 + w/2, stage.stageHeight/2 - h/2);
            lineTo(stage.stageWidth/2 + w/2, stage.stageHeight/2 + h/2);
            lineTo(stage.stageWidth/2 - w/2, stage.stageHeight/2 + h/2);
            lineTo(stage.stageWidth/2 - w/2, stage.stageHeight/2 - h/2);
            
            logo.graphics.clear();
            logo.graphics.lineStyle(0.1, 0x00808080,1,false,LineScaleMode.HORIZONTAL,CapsStyle.ROUND,JointStyle.ROUND,4);
            logo.graphics.beginFill(0x00808080);
            logo.graphics.drawRect(bmpPaddingX, bmpPaddingY, leavesBaseMap.width, leavesBaseMap.height);
            logo.graphics.endFill();
            
            
            m = new Matrix (1, 0, 0, 1, -bmpPaddingX, -bmpPaddingY);
            tempMap = new BitmapData (leavesBaseMap.width, leavesBaseMap.height, true, 0x00808080);
            displaceMap = new BitmapData (leavesBaseMap.width, leavesBaseMap.height, false, 0x00808080);
            mergeMap = new BitmapData (tempMap.width, tempMap.height, true, 0x00808080);
            leaves.addChild(leavesBitmap);
            mergeBitmap = new Bitmap(mergeMap);
            mergeBitmap.x = bmpPaddingX;
            mergeBitmap.y = bmpPaddingY;
            
            addChild(leaves);
            addChild(mergeBitmap);
            
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        public function moveTo(posX:Number,posY:Number):void {
            dots.push(new Dot(posX,posY));
            dots[dots.length-1].tx = dots[dots.length-1].x;
            dots[dots.length-1].ty = dots[dots.length-1].y;
            mid.push(new Dot(0,0));
        }
        
        public function lineTo(posX:Number, posY:Number):void {
            var lx:Number = dots[dots.length-1].x;
            var ly:Number = dots[dots.length-1].y;
            var dx:Number = posX - lx;
            var dy:Number = posY - ly;
            var dist:Number = Math.sqrt(dx*dx+dy*dy);
            var ix:Number = dx/(dist/dotPerPixel);
            var iy:Number = dy/(dist/dotPerPixel);
            for(var i:int = 0; i < (dist/dotPerPixel); i++) {
                dots.push(new Dot(lx + i*ix,ly + i*iy));
                dots[dots.length-1].tx = dots[dots.length-1].x;
                dots[dots.length-1].ty = dots[dots.length-1].y;
                mid.push(new Dot(0,0));
            }
        }
        
        public function doFilter():void {
            zero = new Point(0, 0);
            displaceFilter = new DisplacementMapFilter (displaceMap, zero, 1, 2, 300, 300, "wrap");
            var bevel:BevelFilter = new BevelFilter (-4, 10, 0xffffff, 1, 0x000000, 1, 10, 10, 1, BitmapFilterQuality.HIGH, "inner");
            logo.filters = [bevel];
            tempMap.fillRect (tempMap.rect, 0x00808080);
            tempMap.draw (logo,m,new ColorTransform (1, 0, 0, 1, 0, 0, 0, 0),"normal",null,true);
            bevel.angle += 10;
            logo.filters = [bevel];
            tempMap.draw (logo,m,new ColorTransform (0, 1, 0, 1, 0, 0, 0, 0),"add",null,true);
            tempMap.applyFilter (tempMap, tempMap.rect, zero, blurFilter);
            displaceMap.draw (tempMap);
        }
        
        private function doCalculate():void {
            var dot:Dot;
            var rains:Dot;
            var dx:Number,dy:Number,dist:Number,drx:Number,dry:Number;
            var angle:Number,tx:Number,ty:Number;
            var i:int,j:int;
            for (i=1; i < dots.length; i++) {
                dot = dots[i];
                dx = mouseX-dot.x;
                dy = mouseY-dot.y;
                dist = Math.sqrt(dx*dx+dy*dy);
                if (dist<100) {
                    angle = Math.atan2(dy, dx);
                    tx = mouseX-Math.cos(angle)*100;
                    ty = mouseY-Math.sin(angle)*100;
                    dot.vx += (tx-dot.x)*.4;
                    dot.vy += (ty-dot.y)*.4;
                }/**/
                dot.vx += (dot.tx-dot.x)*.9;
                dot.vy += (dot.ty-dot.y)*.9;
                dot.vx *= .8;
                dot.vy *= .8;
                dot.x += dot.vx;
                dot.y += dot.vy;
            }
            for (i = 0; i < dots.length; i++) {
                if(i == dots.length-1)    {
                    mid[i].x = (dots[i].x+dots[0].x)/2;
                    mid[i].y = (dots[i].y+dots[0].y)/2;
                } else {
                    mid[i].x = (dots[i].x+dots[i+1].x)/2;
                    mid[i].y = (dots[i].y+dots[i+1].y)/2;
                }
            }
        }

        private function doPaint():void {
            var i:int;
            logo.graphics.clear();
            logo.graphics.lineStyle(1, 0x00808080,1,false,LineScaleMode.HORIZONTAL,CapsStyle.ROUND,JointStyle.ROUND,4);
            logo.graphics.beginFill(0x00808080, 100);
            logo.graphics.moveTo(mid[0].x, mid[0].y);
            logo.graphics.lineTo(dots[1].x, dots[1].y);
            for (i = 2; i < dots.length; i++) {
                logo.graphics.curveTo(dots[i].x, dots[i].y, mid[i].x, mid[i].y);
            }
            logo.graphics.curveTo(dots[0].x, dots[0].y, mid[0].x, mid[0].y);
            logo.graphics.endFill();
        }
        
        private function loop (e:Event):void
        {
            doCalculate();
            doPaint();
            doFilter();
            var rect:Rectangle = new Rectangle (0, 0, leavesBaseMap.width, leavesBaseMap.height);
            mergeMap.copyPixels (leavesBaseMap, rect, zero);
            mergeMap.applyFilter (mergeMap, rect, zero, blurFilter);
            mergeMap.applyFilter (mergeMap, rect, zero, displaceFilter);
            mergeMap.copyChannel (tempMap, tempMap.rect, zero, 8, 8);
        }
    }
}

class Dot {
    public var x:Number = 0;
    public var y:Number = 0;
    public var tx:Number = 0;
    public var ty:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
        
    public function Dot(px:Number,py:Number) {
        x = px;
        y = py;
        tx = x;
        ty = y;
    }
}