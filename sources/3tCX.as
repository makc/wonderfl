package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    [SWF(width="465",height="465",frameRate="60",backgroundColor="0xFFFFFF")]
    public class FlashTest extends Sprite {
        private var cloud1:Cloud;
        private var cloud2:Cloud;
        
        public function FlashTest() {
            // write as3 code here..
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            cloud1 = new Cloud(465,465,2,3,false);
            cloud2 = new Cloud(465,465,1,1,true,0x2255AA);
            cloud1.alpha = .4;
            cloud1.startScroll();
            cloud2.startScroll();
            addChild(cloud2);
            addChild(cloud1);
            
        }
    }
}



import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.display.Shape;

class ScrollingPerlinNoise extends Sprite
{
    
    public var numOctaves:int;
    public var skyColor:uint;
    public var cloudsHeight:int;
    public var cloudsWidth:int;
    public var periodX:Number;
    public var periodY:Number;
    public var scrollAmountX:int;
    public var scrollAmountY:int;
    public var cloudsBitmapData:BitmapData;
    private var cloudsBitmap:Bitmap;
    private var cmf:ColorMatrixFilter;
    private var colorBackground:Shape;
    private var displayWidth:Number;
    private var displayHeight:Number;
    private var seed:int;
    private var sliceDataH:BitmapData;
    private var sliceDataV:BitmapData;
    private var sliceDataCorner:BitmapData;
    private var horizCutRect:Rectangle;
    private var vertCutRect:Rectangle;
    private var cornerCutRect:Rectangle;
    private var horizPastePoint:Point;
    private var vertPastePoint:Point;
    private var cornerPastePoint:Point;
    private var origin:Point;
    private var cloudsMask:Shape;
    private var grayScale:Boolean;
    
    public function ScrollingPerlinNoise(w:int = 300, h:int = 200, scrollX:int = 0, scrollY:int = -4, useBG:Boolean = true, col:uint = 0x000000, nOctaves:Number = 5, perlinPeriodX:Number = 150, perlinPeriodY:Number = 150, gray:Boolean = true)
    {
        
        displayWidth = w;
        displayHeight = h;
        //the code can be modified so that the clouds are bigger than the display
        cloudsWidth = displayWidth;
        cloudsHeight = displayHeight;
        periodX = perlinPeriodX;
        periodY = perlinPeriodY;
        scrollAmountX = scrollX;
        scrollAmountY = scrollY;
        grayScale = gray;
        
        numOctaves = nOctaves;
        
        skyColor = col;
        
        cloudsBitmapData = new BitmapData(cloudsWidth, cloudsHeight, true);
        cloudsBitmap = new Bitmap(cloudsBitmapData);
        
        origin = new Point(0, 0);
        
        if (useBG)
        {
            colorBackground = new Shape();
            colorBackground.graphics.beginFill(skyColor);
            colorBackground.graphics.drawRect(0, 0, displayWidth, displayHeight);
            colorBackground.graphics.endFill();
            
            this.addChild(colorBackground);
        }
        this.addChild(cloudsBitmap);
        
        makeClouds();
        setRectangles();
    }
    
    public function startScroll():void
    {
        this.addEventListener(Event.ENTER_FRAME, onEnter);
    }
    
    public function stopScroll():void
    {
        this.removeEventListener(Event.ENTER_FRAME, onEnter);
    }
    
    private function setRectangles():void
    {
        
        if (scrollAmountX != 0)
        {
            sliceDataV = new BitmapData(Math.abs(scrollAmountX), cloudsHeight - Math.abs(scrollAmountY), true);
        }
        if (scrollAmountY != 0)
        {
            sliceDataH = new BitmapData(cloudsWidth, Math.abs(scrollAmountY), true);
        }
        if ((scrollAmountX != 0) && (scrollAmountY != 0))
        {
            sliceDataCorner = new BitmapData(Math.abs(scrollAmountX), Math.abs(scrollAmountY), true);
        }
        horizCutRect = new Rectangle(0, cloudsHeight - scrollAmountY, cloudsWidth - Math.abs(scrollAmountX), Math.abs(scrollAmountY));
        vertCutRect = new Rectangle(cloudsWidth - scrollAmountX, 0, Math.abs(scrollAmountX), cloudsHeight - Math.abs(scrollAmountY));
        cornerCutRect = new Rectangle(cloudsWidth - scrollAmountX, cloudsHeight - scrollAmountY, Math.abs(scrollAmountX), Math.abs(scrollAmountY));
        
        horizPastePoint = new Point(scrollAmountX, 0);
        vertPastePoint = new Point(0, scrollAmountY);
        cornerPastePoint = new Point(0, 0);
        
        if (scrollAmountX < 0)
        {
            cornerCutRect.x = vertCutRect.x = 0;
            cornerPastePoint.x = vertPastePoint.x = cloudsWidth + scrollAmountX;
            horizCutRect.x = -scrollAmountX;
            horizPastePoint.x = 0;
        }
        if (scrollAmountY < 0)
        {
            cornerCutRect.y = horizCutRect.y = 0;
            cornerPastePoint.y = horizPastePoint.y = cloudsHeight + scrollAmountY;
            vertCutRect.y = -scrollAmountY;
            vertPastePoint.y = 0;
        }
    
    }
    
    public function makeClouds():void
    {
        seed = int(Math.random() * 0xFFFFFF);
        
        //draw clouds
        if (grayScale)
        {
            cloudsBitmapData.perlinNoise(periodX, periodY, numOctaves, seed, true, true, 1, true);
        }
        else
        {
            cloudsBitmapData.perlinNoise(periodX, periodY, numOctaves, seed, true, true, 7, false);
        }
        alphaAdjust();
        colorAdjust();
    }
    
    //alpha adjust
    protected function alphaAdjust():void 
    {

    }

    // color adjust
    protected function colorAdjust():void 
    {
        
    }
    
    private function onEnter(evt:Event):void
    {
        cloudsBitmapData.lock();
        
        //copy to buffers the part that will be cut off
        if (scrollAmountX != 0)
        {
            sliceDataV.copyPixels(cloudsBitmapData, vertCutRect, origin);
        }
        if (scrollAmountY != 0)
        {
            sliceDataH.copyPixels(cloudsBitmapData, horizCutRect, origin);
        }
        if ((scrollAmountX != 0) && (scrollAmountY != 0))
        {
            sliceDataCorner.copyPixels(cloudsBitmapData, cornerCutRect, origin);
        }
        
        //scroll
        cloudsBitmapData.scroll(scrollAmountX, scrollAmountY);
        
        //draw the buffers on the opposite sides
        if (scrollAmountX != 0)
        {
            cloudsBitmapData.copyPixels(sliceDataV, sliceDataV.rect, vertPastePoint);
        }
        if (scrollAmountY != 0)
        {
            cloudsBitmapData.copyPixels(sliceDataH, sliceDataH.rect, horizPastePoint);
        }
        if ((scrollAmountX != 0) && (scrollAmountY != 0))
        {
            cloudsBitmapData.copyPixels(sliceDataCorner, sliceDataCorner.rect, cornerPastePoint);
        }
        
        cloudsBitmapData.unlock();
    }

}

class Cloud extends ScrollingPerlinNoise
{
    public function Cloud(w:int = 300, h:int = 200, scrollX:int = 0, scrollY:int = -4, useBG:Boolean = true, col:uint = 0x000000, nOctaves:Number = 5, perlinPeriodX:Number = 150, perlinPeriodY:Number = 150, gray:Boolean = true)
    {
        super(w, h, scrollX, scrollY, useBG, col, nOctaves, perlinPeriodX, perlinPeriodY, gray);
    }
    
    override protected function colorAdjust():void
    {
        var cmf:ColorMatrixFilter = new ColorMatrixFilter(
                                        [0,0,0,0,255,
                                         0,0,0,0,255,
                                         0,0,0,0,255,
                                         1,0,0,0,0]);
        
        cloudsBitmapData.applyFilter(cloudsBitmapData, cloudsBitmapData.rect, new Point(), cmf);
    }
}
