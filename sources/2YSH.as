package {

    import frocessing.color.ColorHSV;

    import com.bit101.components.Label;

    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.utils.getTimer;
    
    [SWF(backgroundColor="0xffffff", frameRate="30", width="465", height="465")]


    public class OpticalFlowLK extends Sprite {
        
        
        private static const WIDTH:int = 320;
        private static const HEIGHT:int = 240;
        
        private static const toDegree:Number = 180 / Math.PI;


        public function OpticalFlowLK() {
            scaleX = -1;
            x = 465;
            
            var container:Sprite = Sprite(addChild(new Sprite()));
            container.scaleX = container.scaleY = 465 / 320;
            container.y = (465 - 240 * container.scaleY) / 2;
            
            var currImage:BitmapData = new BitmapData(320, 240);
            var prevImage:BitmapData = new BitmapData(320, 240);
            
            var camera:Camera = Camera.getCamera();
            camera.setMode(320, 240, 30);
            var video:Video = Video(container.addChild(new Video(320, 240)));
            video.alpha = 0.5;
            video.smoothing = true;
            video.attachCamera(camera);

            var arrow:Shape = Shape(addChild(new Shape()));
            arrow.x = arrow.y = 465 / 2;

            var obj:Shape = Shape(addChild(new Shape()));
            obj.graphics.lineStyle(10, 0xff0000);
            obj.graphics.drawCircle(0, 0, 30);
            obj.x = obj.y = 465 / 2;

            var dir:Shape = Shape(container.addChild(new Shape()));
            var g:Graphics = dir.graphics;
            var color:ColorHSV = new ColorHSV();
            
            var status:Label = new Label(this, 5, 5);
            
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                var start:int = getTimer();
                
                var tmp:BitmapData = prevImage;
                prevImage = currImage;
                currImage = tmp;
                currImage.draw(video);

                var curr:Vector.<uint> = currImage.getVector(currImage.rect);
                var prev:Vector.<uint> = prevImage.getVector(prevImage.rect);
                
                var winSize:int = 8;
                var winStep:int = winSize * 2 + 1;
                
                var i:int, j:int, k:int, l:int;
                var address:int;
                
                var gradX:int, gradY:int, gradT:int;
                var A2:Number, A1B2:Number, B1:Number, C1:Number, C2:Number;
                var u:Number, v:Number, uu:Number, vv:Number, n:int;
                
                var wmax:int = WIDTH - winSize - 1;
                var hmax:int = HEIGHT - winSize - 1;
                
                g.clear();
                
                uu = vv = n = 0;
                
                for (i = winSize + 1; i < hmax; i += winStep) { // y
                    for (j = winSize + 1; j < wmax; j += winStep) { // x
                        A2 = 0;
                        A1B2 = 0;
                        B1 = 0;
                        C1 = 0;
                        C2 = 0;
                        for (k = -winSize; k <= winSize; k++) { // y
                            for (l = -winSize; l <= winSize; l++) { // x
                                address = (i + k) * WIDTH + j + l;
                                
                                gradX = (curr[address - 1] & 0xff) - (curr[address + 1] & 0xff);
                                gradY = (curr[address - WIDTH] & 0xff) - (curr[address + WIDTH] & 0xff);
                                gradT = (prev[address] & 0xff) - (curr[address] & 0xff);
                                
                                A2 += gradX * gradX;
                                A1B2 += gradX * gradY;
                                B1 += gradY * gradY;
                                C2 += gradX * gradT;
                                C1 += gradY * gradT;
                            }
                        }
                        var delta:Number = (A1B2 * A1B2 - A2 * B1);
    
                        if (delta) {
                            /* system is not singular - solving by Kramer method */
                            var deltaX:Number;
                            var deltaY:Number;
                            var Idelta:Number = 8 / delta;
    
                            deltaX = -(C1 * A1B2 - C2 * B1);
                            deltaY = -(A1B2 * C2 - A2 * C1);
    
                            u = deltaX * Idelta;
                            v = deltaY * Idelta;
                            
                        } else {
                            /* singular system - find optical flow in gradient direction */
                            var Norm:Number = (A1B2 + A2) * (A1B2 + A2) + (B1 + A1B2) * (B1 + A1B2);
    
                            if (Norm) {
                                var IGradNorm:Number = 8 / Norm;
                                var temp:Number = -(C1 + C2) * IGradNorm;
    
                                u = (A1B2 + A2) * temp;
                                v = (B1 + A1B2) * temp;
                                
                            } else {
                                u = v = 0;
                            }
                        }
                        
                        if (-winStep < u && u < winStep && -winStep < v && v < winStep) {
                            uu += u;
                            vv += v;
                            n++;
                            color.h = Math.atan2(v, u) * toDegree + 360;
                            g.lineStyle(0, color.value);
                            g.moveTo(j, i);
                            g.lineTo(j + u * 3, i + v * 3);
                        }
                    }
                }
                
                uu /= n;
                vv /= n;
                
                status.text = (getTimer() - start) + 'ms';
                
                var a:Number = Math.atan2(vv, uu) * toDegree + 360;
                color.h = a;
                arrow.graphics.clear();
                arrow.graphics.beginFill(color.value);
                arrow.graphics.drawRect(0, -0.5, 10, 1);
                arrow.graphics.moveTo(10, -2);
                arrow.graphics.lineTo(13.5, 0);
                arrow.graphics.lineTo(10, 2);
                arrow.graphics.endFill();
                arrow.scaleX = arrow.scaleY= Math.sqrt(uu * uu + vv * vv) * 10;
                arrow.rotation = a;
                
                obj.x += uu * 10;
                obj.y += vv * 10;
                if (obj.x < 0) obj.x = 0;
                else if (465 < obj.x) obj.x = 465;
                if (obj.y < 0) obj.y = 0;
                else if (465< obj.y) obj.y = 465;
            });
        }
    }
}
