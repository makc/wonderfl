/*
    Made by wonderwhy-er in 2008, modified and published to wonderfl in 2010,
    feel free to use and modyfy ;)
*/
package  {
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.geom.ColorTransform;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    
    [SWF(frameRate="30")]
    
    public class RampantGrowth extends MovieClip {
        
        private var bmp:BitmapData;
        private var bm:Bitmap;
        private var degree:Number;
        private var sprouts:Array;
        private var sp:Sprite;
        private var g:Graphics;
        private var cf:int;
        private var ct:ColorTransform;
        private var ct2:ColorTransform;
        private var count:Number;
        private var cc:int;
        private var glow:GlowFilter;

        public function RampantGrowth() {
            
            var txt:TextField = new TextField();
            txt.textColor=0xFFFF00;
            txt.selectable=false;
            txt.autoSize=TextFieldAutoSize.LEFT;
            txt.htmlText="<a href=\"http://www.wonderwhy-er.com\" target=\"_blank\">made by wonderwhy-er</a>";
            addChild(txt);
            
            stage.scaleMode= StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.addEventListener(Event.RESIZE,resize);
            
            
            
            bm = new Bitmap();
            resize();
            degree = Math.PI/180;
            
            sp = new Sprite();
            g = sp.graphics;
            cf = -3;
            ct = new ColorTransform(1,0.97,0.97,1,0,0,0,0);
            ct2 = new ColorTransform(1,1,1,1,-1,0,0,0);
            count = 5000;
            cc=0;
            glow = new GlowFilter(0x00FFFF,0.5,4,4,3,1,false,false);
            sp.filters=[glow];
            addChildAt(bm,0);
            stage.addEventListener(MouseEvent.CLICK,Click);
            addEventListener(Event.ENTER_FRAME,frame);
        
        }
        
        private function resize(e:Event=null):void{
            sprouts = [[stage.stageWidth/2,stage.stageHeight/2,Math.random()*7,0,2]];
            bmp = new BitmapData(stage.stageWidth ,stage.stageHeight,false,0);
            bm.bitmapData=bmp;
        }
        
        private function frame(evt:Event):void{
            cc++;
            //InterfaceMC.Count.text=sprouts.length.toString();
            bmp.lock();
            bmp.colorTransform(bmp.rect,ct);
            if(cc%3){
                bmp.colorTransform(bmp.rect,ct2);
            }
            g.clear();
            for(var i:int=0;i<sprouts.length;i++){
                var sprout:Array=sprouts[i];
                if(Math.random()<0.1){
                    var angle:Number = (Math.round(Math.random())*2-1)*(15+Math.random()*10)*degree;
                    var newSprout:Array = [sprout[0],sprout[1],sprout[2]+angle,sprout[3],sprout[4]*0.8];
                    var dirV2:Point = new Point(Math.sin(newSprout[2]),Math.cos(newSprout[2]));
                    while((bmp.getPixel(newSprout[0],newSprout[1])>>8)%256>100){
                        newSprout[0]+=dirV2.x;
                        newSprout[1]+=dirV2.y;
                    }
                    sprouts.push(newSprout);
                }
                var dir:Number = (Math.round(Math.random())*2-1);
                sprout[3]+=dir;
                if(sprout[3]>0){
                    dir=sprout[2]+1*degree;
                }else{
                    dir=sprout[2]-1*degree;
                }
                var dirV:Point = new Point(Math.sin(dir),Math.cos(dir));
                
                g.moveTo(sprout[0],sprout[1]);
                sprout[0]+=dirV.x*sprout[4];
                sprout[1]+=dirV.y*sprout[4];
                if(sprout[0]>bmp.width){
                    sprout[0]=0;
                    g.moveTo(sprout[0],sprout[1]);
                }
                if(sprout[1]>bmp.height){
                    sprout[1]=0;
                    g.moveTo(sprout[0],sprout[1]);
                }
                if(sprout[0]<0){
                    sprout[0]=bmp.width;
                    g.moveTo(sprout[0],sprout[1]);
                }
                if(sprout[1]<0){
                    sprout[1]=bmp.height;
                    g.moveTo(sprout[0],sprout[1]);
                }
                if((bmp.getPixel(sprout[0],sprout[1])>>16)>50){
                    sprouts.splice(i,1);
                    i--;
                }else{
                    sprout[4]+=0.01;
                    sprout[2]=dir;
                    g.lineStyle(sprout[4],0x88FF00);
                    g.lineTo(sprout[0],sprout[1]);
                    
                }
            }
            bmp.draw(sp);
            bmp.unlock();
        }


        private function Click(evt:Event):void{
            sprouts.push([mouseX,mouseY,Math.random()*7,0,2]);
        }

    }
}