package {
    import flash.filters.DisplacementMapFilterMode;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.BlurFilter;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    public class ActionPainting extends Sprite {
        private const WIDTH:int = 513;
        private const HEIGHT:int = 513;
        
        private var pArr:Array = [];
        private var container:Sprite = new Sprite();
        private var bmpd:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0x0);
        private var bmp:Bitmap = new Bitmap(bmpd);
        private var blurFilter:BlurFilter = new BlurFilter(2.2, 2.2, 2);
        private var rect:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
        private var point:Point = new Point();
        
        private var redOffset:int = Math.random()*300 - 100;
        private var greenOffset:int = Math.random()*300 - 100;
        private var blueOffset:int = Math.random()*300 - 100;
        
        private var cTr:ColorTransform = new ColorTransform(1, 1, 1, 1, redOffset, greenOffset, blueOffset);
        
        public function ActionPainting() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            this.graphics.beginFill(0x222222);
            this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
            this.graphics.endFill();
            
            addPtc();
            
            var map:BitmapData = new BitmapData(WIDTH, HEIGHT);
            map.perlinNoise(84, 84, 5, Math.random()*100, false, true, 1, true);
            bmp.filters = [new DisplacementMapFilter(map, point, 1, 1, 64, 64, DisplacementMapFilterMode.CLAMP)];
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
            stage.addEventListener(MouseEvent.CLICK, mouseClick);
        }

        private function addPtc():void{
            var pCount:uint = 40;
            while(pCount--){
                var p:Ptc = new Ptc(6+Math.random()*14);
                p.x = Math.random()*553 - 20;
                p.y = Math.random()*553 - 20;
                container.addChild(p);
                pArr.push(p);
            }
            addChild(bmp);
        }

        private function enterFrame(evt:Event):void{
            for(var i:String in pArr){
                pArr[i].process();
            }
            if(redOffset !== cTr.redOffset){
                (redOffset>cTr.redOffset)?(cTr.redOffset++):(cTr.redOffset--);
            }else{
                redOffset = Math.random()*300 - 100;
            }
            if(greenOffset !== cTr.greenOffset){
                (greenOffset>cTr.greenOffset)?(cTr.greenOffset++):(cTr.greenOffset--);
            }else{
                greenOffset = Math.random()*300 - 100;
            }
            if(blueOffset !== cTr.blueOffset){
                (blueOffset>cTr.blueOffset)?(cTr.blueOffset++):(cTr.blueOffset--);
            }else{
                blueOffset = Math.random()*300 - 100;
            }
            
            bmpd.draw(container);
            bmpd.applyFilter(bmpd, rect, point, blurFilter);
            bmp.transform.colorTransform = cTr;
        }
        
        private function mouseClick(evt:MouseEvent):void{
            for(var i:String in pArr){
                pArr[i].stopFlag = false;
                pArr[i].destPoint.x = evt.stageX;
                pArr[i].destPoint.y = evt.stageY;
            }

        }

    }
}

import flash.events.Event;
import flash.display.BlendMode;
import flash.geom.Point;
import flash.display.Shape;

class Ptc extends Shape{
    public var destPoint:Point = new Point();
    private var vx:Number = 0;
    private var vy:Number = 0;
    private var easing:Number = 0.02 + Math.random()*0.03;
    private var rNum:int;
    public var stopFlag:Boolean = false;

    public function Ptc(radius:Number){
        this.graphics.beginFill(Math.random()*0x1000000);
        this.graphics.drawCircle(0, 0, radius);
        this.graphics.endFill();
        this.blendMode = BlendMode.LIGHTEN;
    }

    public function process():void{
        if(stopFlag){
            rNum = Math.random()*20;
            if(rNum == 0){
                destPoint.x = Math.random()*553 - 20;
                destPoint.y = Math.random()*553 - 20;
                stopFlag = false;
            }
        }else{
            movePtc();
            if(Math.round(vx)==0 && Math.round(vy)==0){
            stopFlag = true;
            }
        }
    }

    private function movePtc():void{
        vx = (destPoint.x - this.x)*easing;
        vy = (destPoint.y - this.y)*easing;
        this.x += vx;
        this.y += vy;
    }
}