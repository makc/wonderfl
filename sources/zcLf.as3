/**
 * 
 * "Use Flash Player 10 drawing API,
 *  specifically drawTriangles.
 *  My favorite part of the new capabilities
 *  is the ability to specify
 *  UVT texture mapping data."
 *                     by Justin Everett-Church
 *  
 * This code is a example of drawTriangle.
 */
package {
    
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    
    [SWF(width="600", height="600", backgroundColor="0x000000", frameRate="20")]

    public class drawTriangleTest extends Sprite{
    
        private var bmpd     :BitmapData;
        private var spCircle :Sprite;
        private var spBmpd   :Sprite;
        private var spLine   :Sprite;

        private var verD     :Vector.<Number>;
        private var indD     :Vector.<int>;
        private var uvtD     :Vector.<Number>;

        private var gCircle  :Graphics;
        private var gLine    :Graphics;

        private var dp_1     :Dragpoint;
        private var dp_2     :Dragpoint;
        private var dp_3     :Dragpoint;

        public function drawTriangleTest() {

            spCircle=new Sprite();
            spBmpd=new Sprite();
            spLine=new Sprite();
            spLine.y=spLine.x=spCircle.y=spCircle.x=100; 
                        
            spBmpd.graphics.beginFill(0xfe0000);
            spBmpd.graphics.drawCircle(100,100,50);
            spBmpd.graphics.endFill();   
            bmpd=new BitmapData(400,400,true,0xffffff);
            bmpd.draw(spBmpd);

            gCircle = spCircle.graphics;
            gLine= spLine.graphics;

            verD = new Vector.<Number>();
            verD.push(0, 0);
            verD.push(400, 0);
            verD.push(200, 340);    
            dp_1=new Dragpoint(0, 0);
            dp_2=new Dragpoint(400, 0);
            dp_3=new Dragpoint(0, 400);

            indD = new Vector.<int>();
            indD.push(1,2,0);

            uvtD = new Vector.<Number>();
            uvtD.push(0, 0);
            uvtD.push(1, 0);
            uvtD.push(0, 1);

            addChild(spCircle);
            addChild(spLine);

            spLine.addChild(dp_1);
            spLine.addChild(dp_2);
            spLine.addChild(dp_3);

            addEventListener(Event.ENTER_FRAME, handleEnterFrame);

        } 

        private function handleEnterFrame(e:Event):void{
            gLine.clear();
            gCircle.clear();
            gCircle.beginBitmapFill(bmpd);
            gCircle.drawTriangles(verD, indD, uvtD);

            verD[0] = dp_1.x;
            verD[1] = dp_1.y;
            verD[2] = dp_2.x;
            verD[3] = dp_2.y;
            verD[4] = dp_3.x;
            verD[5] = dp_3.y;

            gLine.lineStyle(0,0xfe0000);
            gLine.moveTo(verD[0],verD[1]);
            gLine.lineTo(verD[2],verD[3]);
            gLine.lineTo(verD[4],verD[5]);
            gLine.lineTo(verD[0],verD[1]);
        }

    }
}

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.display.Graphics;

class Dragpoint extends Sprite{
    public function Dragpoint (xPos:Number,yPos:Number){
        this.graphics.beginFill(0xFFFFFF);
        this.graphics.drawCircle(0,0,5);
        this.graphics.endFill();
        this.x=xPos;
        this.y=yPos;
        this.buttonMode=true;
        this.addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
        this.addEventListener(MouseEvent.MOUSE_UP,upHandler);
    }
    private function downHandler(e:MouseEvent):void{
        this.startDrag();
    }
    private function upHandler(e:MouseEvent):void {
        this.stopDrag();
    }
}
