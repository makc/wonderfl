package{
    //エフェクト作る
    import flash.events.Event;
    import flash.display.Sprite;
    
    public class FlashTest extends Sprite {
        public var field:DynamicSprite;
        public var down:Boolean;
        public function FlashTest() {
            // write as3 code here..
            var map:ErectBitmap = new ErectBitmap();
            field = new DynamicSprite(stage.getRect(stage));
            field.addChild(map);
            addChild(field);
            map.scaleX = 3;  map.scaleY = 3;
            
            addEventListener("mouseDown",onDown);
            addEventListener("mouseMove",onMove);
            addEventListener("mouseUp",onUp);
        }
        public function onDown(e:Event):void{
           field.zoom(mouseX*3/4,mouseY*3/4,4);
           down = true;
        }
        public function onMove(e:Event):void{
           if(down){field.zoom(mouseX*3/4,mouseY*3/4,4);}
        }
        public function onUp(e:Event):void{
           field.zoom(0,0,1,7);
           down = false;
        }
    }
}
import flash.geom.*;
import flash.events.Event;
import flash.display.*;

class ErectBitmap extends Bitmap{
    public static const WIDTH:int = 155;
    public static const HEIGHT:int = 155;
    public static const DIR:Array = [[1,0],[0,1],[-1,0],[0,-1]];
    public var baseBitmap:BitmapData;
    public var points:Vector.<Object>=new Vector.<Object>();
    private var count:int=0;
    
    public function ErectBitmap():void{
        baseBitmap = new BitmapData(WIDTH,HEIGHT,false,0x222222)      
        super(baseBitmap.clone());
        baseBitmap.lock();
        for(var i:int=1;i<WIDTH;i+=2){
            for(var j:int=1;j<HEIGHT;j+=2){
                baseBitmap.setPixel(i,j,0x000000);
            }
        }
        baseBitmap.unlock();
        for(i=0;i<300;i++){addPoint();}
        addEventListener(Event.ENTER_FRAME,onFrame);
    }
    public function onFrame(e:Event):void{
        count++
        baseBitmap.lock();
        bitmapData.merge(baseBitmap,baseBitmap.rect,new Point(),50,50,50,50);
        var size:int = points.length; 
        for(var i:int;i<size;i++){
            var point:Object = points[i];
            drow(point);  move(point);
            if(bitmapData.rect.contains(point.x,point.y)==false){
                points.splice(i,1);
                size--;
            }
            if(count%2==0){     
                var pDir:int = Math.random()*5;
                if(pDir<4){ point.dir=DIR[pDir] }
            }
        }
        if(count%2==0){addPoint();}
        baseBitmap.unlock();
    }
    private function drow(point:Object):void{
        bitmapData.setPixel(point.x,point.y,point.color);
    }
    private function move(point:Object):void{
        point.x += point.dir[0];
        point.y += point.dir[1];
    }
    
    private function addPoint():void{
        var px:int = WIDTH/2+0.5;
        var py:int = HEIGHT/2+0.5;
        var pDir:int = Math.random()*4;
        var pColor:int = Math.random()*0xFFFFFF;
        points.push({x:px,y:py,dir:DIR[pDir],color:pColor});
    }
}

//拡大、縮小、スライドが滑らかにできるSprite===============================================================
class DynamicSprite extends Sprite{
    public var rect:Rectangle;
    private var rate:Number = 1;
    private var speed:Number = 7;
    private var focusX:Number = 0;
    private var focusY:Number = 0;
    private static const MAX_RATE:Number = 64;
    private static const MIN_RATE:Number = 1/16;
    public function DynamicSprite(r:Rectangle){
        rect = r;
        x=rect.x;y=rect.y;
        focusX=x; focusY=y;
        addEventListener("enterFrame",focus);
    }

    //ズーム
    public function zoom(fx:Number,fy:Number,r:Number,s:int = 7):void{
        if(r>MAX_RATE){r=MAX_RATE;}
        if(r<MIN_RATE){r=MIN_RATE;}
        speed=s;
        rate=r;
        focusX=-fx*rate+rect.x+rect.width/2;
        focusY=-fy*rate+rect.y+rect.height/2;
    }

    //ズームのリセット
    public function reset():void{
        zoom(rect.width/2,rect.width/2,1,3);
    }
    
    //焦点の移動
    private function focus(e:Event):void{
        scaleX = ( scaleX*speed + rate) / (speed+1);
        scaleY = ( scaleY*speed + rate) / (speed+1);
        x = ( x*speed + focusX) / (speed+1);
        y = ( y*speed + focusY) / (speed+1);
    } 
}
//=====================================================================================================
