// Paint.as
//  Paint screen with the old good days BASIC style.
package
{
    import flash.display.Sprite;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]
    public class Paint extends Sprite
    {
        public function Paint()
        {
            main = this;
            initialize();
        }
    }
}

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Vector3D;
import flash.events.Event;

const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
var main:Sprite;
var screen:BitmapData = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false, 0);
var rand:Function = Math.random, abs:Function = Math.abs;
var paintPointStack:Vector.<Vector3D> = new Vector.<Vector3D>;
var paintColor:int, paintedColor:int;
var pos:Vector3D = new Vector3D, offset:Vector3D = new Vector3D;
var leftPixels:int;

function initialize():void
{
    main.addChild(new Bitmap(screen));
    main.addEventListener(Event.ENTER_FRAME, update);
}

function update(event:Event):void
{
    screen.lock();
    if (paintPointStack.length <= 0)
    {
        setNewTriangle();
    }
    else
    {
        leftPixels = 50;
        while (leftPixels > 0 && paintPointStack.length > 0) paintOneLine(paintPointStack.pop());
    }
    screen.unlock();
}

function paintOneLine(p:Vector3D):void
{
    var beginX:int = p.x, endX:int = p.x;
    for (;;)
    {
        if (beginX < 0 || screen.getPixel(beginX, p.y) != paintedColor) break;
        beginX--;
    }
    beginX++;
    for (;;)
    {
        if (endX >= SCREEN_WIDTH || screen.getPixel(endX, p.y) != paintedColor) break;
        endX++;
    }
    endX--;
    var x:int;
    for (x = beginX; x <= endX; x++) screen.setPixel(x, p.y, paintColor);
    leftPixels -= endX - beginX + 1;
    for (var oy:int = -1; oy <= 1; oy += 2)
    {
        var y:int = p.y - oy;
        if (y < 0 || y >= SCREEN_HEIGHT) continue;
        var isPaintingNext:Boolean = true;
        for (x = beginX; x <= endX; x++)
        {
            var pc:int = screen.getPixel(x, y);
            if (isPaintingNext && pc == paintedColor)
            {
                paintPointStack.push(new Vector3D(x, y));
                isPaintingNext = false;
            }
            if (!isPaintingNext && pc != paintedColor) isPaintingNext = true;
        }
    }
}

function setNewTriangle():void
{
    var tps:Vector.<Vector3D> = new Vector.<Vector3D>(3, true);
    var i:int;
    for (i = 0; i < 3; i++) tps[i] = new Vector3D(rand() * SCREEN_WIDTH, rand() * SCREEN_HEIGHT);
    paintColor = (int)(rand() * 127 + 128) * 0x10000 + (int)(rand() * 127 + 128) * 0x100 + (int)(rand() * 127 + 128);
    for (i = 0; i < 3; i++)
    {
        var ni:int = i + 1; if (ni >= 3) ni = 0;
        drawLine(tps[i], tps[ni], paintColor);
    }
    var cp:Vector3D = new Vector3D;
    for (i = 0; i < 3; i++) cp.incrementBy(tps[i]);
    cp.scaleBy(1.0 / 3);
    paintedColor = screen.getPixel(cp.x, cp.y);
    if (paintColor == paintedColor)
    {
        screen.fillRect(screen.rect, 0);
        return;
    }
    paintPointStack.push(cp);
}

function drawLine(from:Vector3D, to:Vector3D, color:int):void
{
    offset.x = to.x - from.x; offset.y = to.y - from.y;
    var length:Number;
    var ox:Number = abs(offset.x), oy:Number = abs(offset.y);
    if (ox > oy) length = ox;
    else         length = oy;
    offset.x /= length; offset.y /= length;
    pos.x = from.x; pos.y = from.y;
    for (var i:int = 0; i <= length; i++)
    {
        screen.setPixel(pos.x, pos.y, color);
        pos.incrementBy(offset);
    }
}
