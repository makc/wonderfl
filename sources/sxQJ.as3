/*
multipart project 2
part 4 of, I don't know, like 5

Background:
Okay, so it's really easy to spin a plane in 3D. But what I
really need is to be able to overlay a rectangular
DisplayObject over someting in an image. That is, I need to
find the appropriate Matrix3D given 4 points.

Task:
- generate a Matrix3D given points
- make a UI to to customize this
*/
package {
    import com.bit101.components.*;
    import flash.display.*;
    import flash.net.*;
    import flash.system.*;
    import flash.geom.*;
    import flash.events.*;
    public class FlashTest extends Sprite {
        
        private static const PROXY:String = 'http://p.jsapp.us/proxy/';
        private static const CONTEXT:LoaderContext = new LoaderContext(true);
        
        private const cx:Number = transform.perspectiveProjection.projectionCenter.x;
        private const cy:Number = transform.perspectiveProjection.projectionCenter.y;
        private const cz:Number = transform.perspectiveProjection.focalLength;
        
        private const back:Loader = new Loader();
        private const front:Loader = new Loader();
        private const m3:Matrix3D = new Matrix3D();
        private const handles:Vector.<Sprite> = new Vector.<Sprite>(4, true);
        private const box:Shape = new Shape();
        
        private var backURL:InputText;
        private var frontURL:InputText;
        private var m3Text:Text;
        
        public function FlashTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            addChild(back);
            front.contentLoaderInfo.addEventListener(Event.COMPLETE, recalc);
            front.transform.matrix3D = m3;
            addChild(front);
            addChild(box);
            
            backURL = new InputText(this, 10, 10, 'http://farm4.static.flickr.com/3358/3197122530_29f4d9dc8f.jpg');
            backURL.width = 340;
            backURL.alpha = 0.5;
            new PushButton(this, 360, 10, 'Load BG', resetBack).alpha = 0.5;
            frontURL = new InputText(this, 10, 40, loaderInfo.parameters['viewer.iconURL']);
            frontURL.width = 340;
            frontURL.alpha = 0.5;
            new PushButton(this, 360, 40, 'Load FG', resetFront).alpha = 0.5;
            m3Text = new Text(this, 10, 340);
            m3Text.height = 120;
            m3Text.alpha = 0.5;
            
            for (var i:int = 0; i < 4; i++) {
                var s:Sprite = new Sprite();
                s.graphics.beginFill(0xffffff, 0.5);
                s.graphics.drawRect(-4, -4, 8, 8);
                s.graphics.endFill();
                s.addEventListener(MouseEvent.MOUSE_DOWN, handleDown);
                handles[i] = s;
                addChild(s);
            }
            handles[0].x = 182;
            handles[0].y = 119;
            handles[1].x = 296;
            handles[1].y = 83;
            handles[2].x = 182;
            handles[2].y = 306;
            handles[3].x = 296;
            handles[3].y = 300;
            stage.addEventListener(MouseEvent.MOUSE_UP, handleUp);
            
            resetBack(null);
            resetFront(null);
        }
        
        private function resetBack(e:Event):void {
            back.load(new URLRequest(PROXY + backURL.text), CONTEXT);
        }
        
        private function resetFront(e:Event):void {
            front.load(new URLRequest(PROXY + frontURL.text), CONTEXT);
        }
        
        private function recalc(e:Event):void {
            solve(handles[0].x, handles[1].x, handles[2].x, handles[3].x, handles[0].y, handles[1].y, handles[2].y, handles[3].y, front.content.width, front.content.height);
            box.graphics.clear();
            box.graphics.lineStyle(0);
            box.graphics.moveTo(handles[0].x, handles[0].y);
            box.graphics.lineTo(handles[1].x, handles[1].y);
            box.graphics.lineTo(handles[3].x, handles[3].y);
            box.graphics.lineTo(handles[2].x, handles[2].y);
            box.graphics.lineTo(handles[0].x, handles[0].y);
            m3Text.text =
                'v[12] = ' + m3.rawData[12] + ';\n' +
                'v[13] = ' + m3.rawData[13] + ';\n' +
                'v[0] = ' + m3.rawData[0] + ';\n' +
                'v[1] = ' + m3.rawData[1] + ';\n' +
                'v[2] = ' + m3.rawData[2] + ';\n' +
                'v[4] = ' + m3.rawData[4] + ';\n' +
                'v[5] = ' + m3.rawData[5] + ';\n' +
                'v[6] = ' + m3.rawData[6] + ';';
        }
        
        private function solve(x0:Number, x1:Number, x2:Number, x3:Number, y0:Number, y1:Number, y2:Number, y3:Number, w:Number, h:Number):void {
            // I got these equations from matlab ):
            var v:Vector.<Number> = m3.rawData;
            v[12] = x0;
            v[13] = y0;
            v[0] = -(cx*x0*y2-cx*x2*y0-cx*x0*y3-cx*x1*y2+cx*x2*y1+cx*x3*y0+cx*x1*y3-cx*x3*y1-x0*x2*y1+x1*x2*y0+x0*x3*y1-x1*x3*y0+x0*x2*y3-x0*x3*y2-x1*x2*y3+x1*x3*y2)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / w;
            v[1] = -(cy*x0*y2-cy*x2*y0-cy*x0*y3-cy*x1*y2+cy*x2*y1+cy*x3*y0+cy*x1*y3-cy*x3*y1-x0*y1*y2+x1*y0*y2+x0*y1*y3-x1*y0*y3+x2*y0*y3-x3*y0*y2-x2*y1*y3+x3*y1*y2)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / w;
            v[2] = (cz*x0*y2-cz*x2*y0-cz*x0*y3-cz*x1*y2+cz*x2*y1+cz*x3*y0+cz*x1*y3-cz*x3*y1)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / w;
            v[4] = (cx*x0*y1-cx*x1*y0-cx*x0*y3+cx*x1*y2-cx*x2*y1+cx*x3*y0+cx*x2*y3-cx*x3*y2-x0*x1*y2+x1*x2*y0+x0*x1*y3-x0*x3*y1+x0*x3*y2-x2*x3*y0-x1*x2*y3+x2*x3*y1)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / h;
            v[5] = (cy*x0*y1-cy*x1*y0-cy*x0*y3+cy*x1*y2-cy*x2*y1+cy*x3*y0+cy*x2*y3-cy*x3*y2-x0*y1*y2+x2*y0*y1+x1*y0*y3-x3*y0*y1+x0*y2*y3-x2*y0*y3-x1*y2*y3+x3*y1*y2)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / h;
            v[6] = -(cz*x0*y1-cz*x1*y0-cz*x0*y3+cz*x1*y2-cz*x2*y1+cz*x3*y0+cz*x2*y3-cz*x3*y2)/(x1*y2-x2*y1-x1*y3+x3*y1+x2*y3-x3*y2) / h;
            m3.rawData = v;
        }
        
        private function handleDown(e:MouseEvent):void {
            e.target.startDrag();
            stage.addEventListener(MouseEvent.MOUSE_MOVE, recalc);
            front.alpha = 0.5;
        }
        
        private function handleUp(e:MouseEvent):void {
            e.target.stopDrag();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, recalc);
            front.alpha = 1;
        }
        
    }
}