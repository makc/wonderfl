//All credits for this code and swf go to Eduardo Omine.
//I ablsolutely love his work and just wanted the c ommunity to see this and work on it.
// it is a brilliant use of peak values of the mp3 along with pixel bender filters.

//This is only for the community to see and i do not intend to violate any rights / laws.

//Change values and get different results, the pixel bender filter has values size,angle,dx,dy
/*
            shader.data.size.value = [float value];
            shader.data.angle.value = [float value];
            shader.data.dx.value = [float value];
            shader.data.dy.value = [float value];
            
            multiply size by peak and dx and dy by posX and posY
*/
//todo - get it to work with computeSpectrum

package 
{
    import flash.system.Security;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.*;
    import flash.ui.*;
    import flash.utils.*;
    import flash.utils.ByteArray;
    
     
    public class Main extends Sprite
    {
         private var CENTER:Point=new Point(WIDTH * 0.5, HEIGHT * 0.5);

        private var ZERO_POINT:Point=new Point();

        private var HEX_RANGE:Number=Math.PI / 3;

        private var WIDTH:uint = 500;

        private var HEIGHT:uint= 450;

        private var LOUDNESS:Number=0.5;

        private var PEAK_FACTOR:Number=(1 - LOUDNESS) * 3 + 1;

        private var IHEX_RANGE:Number=1 / HEX_RANGE;

        private var TWO_PI:Number=Math.PI * 2;

        private var MUSIC_FILE:String="music.mp3";

        private var FADE_FACTOR:Number=LOUDNESS * -2.55 - 10;

        private var PEAK_DECAY:Number=0.98;

        private var channel:flash.media.SoundChannel;

        private var posY:Number;

        private var level:Number;

        private var gradientMatrix:Matrix;

        private var posX:Number;

        private var sound:Sound;

        private var shaderJob:ShaderJob;

        private var volume:Number;

        private var blurFilter:BlurFilter;

        private var offscreenSprite:Sprite;

        private var windowButton:Sprite;

        private var offscreenGraphics:Graphics;

        private var fullscreenButton:Sprite;

        private var fadeTransform:ColorTransform;

        private var angle:Number;

        private var peak:Number;

        private var renderBitmap:Bitmap;

        private var targetX:Number;

        private var targetY:Number;

        private var renderColor:ColorTransform;

        private var shader:Shader;

        private var renderBuffer:BitmapData;

        private var renderMatrix:Matrix;

        private static var ShaderAsset:Class;
        
        private var loader:URLLoader = new URLLoader(); 
        
        
        
        
        public function Main()
        {
            if (stage)
            {
                init();
            }
            else 
            {
                addEventListener(Event.ADDED_TO_STAGE, init);
            }
            return;
        }

        private function init(arg1:flash.events.Event=null):void
        {
            Security.allowDomain("http://www.doorknobdesign.com");
            removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
            contextMenu = new flash.ui.ContextMenu();
            contextMenu.hideBuiltInItems();
            sound = new flash.media.Sound(new flash.net.URLRequest("http://www.doorknobdesign.com/wfl/tgm.mp3"));
            //sound.addEventListener(flash.events.ProgressEvent.PROGRESS, soundProgress);
            //sound.addEventListener(flash.events.Event.COMPLETE, soundComplete);
            level = 0;
            peak = 0;
            volume = 0;
            
            loader.dataFormat = URLLoaderDataFormat.BINARY; 
            loader.addEventListener(Event.COMPLETE, onLoadComplete); 
            loader.load(new URLRequest("http://www.doorknobdesign.com/wfl/Main_ShaderAsset.dat")); 
            function onLoadComplete(e:Event):void
            {
            soundComplete();
            }
            return;
        }

        private function tick(arg1:flash.events.Event):void
        {
            var loc2:*=NaN;
            var loc3:*=NaN;
            var loc4:*=NaN;
            var loc5:*=NaN;
            level = (channel.leftPeak + channel.rightPeak) * 0.4;
            peak = peak * PEAK_DECAY;
            if (level > peak)
            {
                peak = level;
                targetX = Math.random() * WIDTH;
                targetY = Math.random() * HEIGHT;
            }
            var loc1:*=peak * PEAK_FACTOR * 100;
            gradientMatrix.createGradientBox(loc1 * 2, loc1 * 2, 0, -loc1, -loc1);
            offscreenGraphics.clear();
            offscreenGraphics.beginGradientFill("radial", [16777215, 16777215], [1, 0], [0, 255], gradientMatrix);
            offscreenGraphics.drawCircle(0, 0, loc1);
            offscreenGraphics.endFill();
            renderMatrix.identity();
            var loc8:*;
            angle = loc8 = flash.utils.getTimer() * 0.001;
            renderMatrix.rotate(loc8);
            renderMatrix.translate(CENTER.x, CENTER.y);
            renderColor.alphaMultiplier = peak;
            renderBuffer.colorTransform(renderBuffer.rect, fadeTransform);
            renderBuffer.draw(offscreenSprite, renderMatrix, renderColor, "add");
            renderBuffer.applyFilter(renderBuffer, renderBuffer.rect, ZERO_POINT, blurFilter);
            loc5 = peak * TWO_PI;
            var loc6:*;
            if ((loc6 = int(loc5 * IHEX_RANGE)) == 0)
            {
                loc2 = 1;
                loc4 = 0;
            }
            if (loc6 == 1)
            {
                loc3 = 1;
                loc4 = 0;
            }
            if (loc6 == 2)
            {
                loc2 = 0;
                loc3 = 1;
            }
            if (loc6 == 3)
            {
                loc2 = 0;
                loc4 = 1;
            }
            if (loc6 == 4)
            {
                loc3 = 0;
                loc4 = 1;
            }
            if (loc6 == 5)
            {
                loc2 = 1;
                loc3 = 0;
            }
            if (isNaN(loc2))
            {
                loc5 = loc5 - loc6 * HEX_RANGE;
                if (loc6 % 2 != 0)
                {
                    loc5 = HEX_RANGE - loc5;
                }
                loc2 = loc5 * IHEX_RANGE;
            }
            else 
            {
                if (isNaN(loc3))
                {
                    loc5 = loc5 - loc6 * HEX_RANGE;
                    if (loc6 % 2 != 0)
                    {
                        loc5 = HEX_RANGE - loc5;
                    }
                    loc3 = loc5 * IHEX_RANGE;
                }
                else 
                {
                    if (isNaN(loc4))
                    {
                        loc5 = loc5 - loc6 * HEX_RANGE;
                        if (loc6 % 2 != 0)
                        {
                            loc5 = HEX_RANGE - loc5;
                        }
                        loc4 = loc5 * IHEX_RANGE;
                    }
                }
            }
            var loc7:*=(1 - peak) * FADE_FACTOR;
            fadeTransform.redOffset = loc7 - loc2 * 10;
            fadeTransform.greenOffset = loc7 - loc3 * 10;
            fadeTransform.blueOffset = loc7 - loc4 * 10;
            posX = posX + (targetX - posX) * 0.02;
            posY = posY + (targetY - posY) * 0.02;
            shader.data.size.value = [peak * 25];
            shader.data.angle.value = [-angle];
            shader.data.dx.value = [0.01 * WIDTH / posX];
            shader.data.dy.value = [0.01 * HEIGHT / posY];
            shaderJob = new ShaderJob(shader, renderBuffer, WIDTH, HEIGHT);
            shaderJob.start();
         
        }


        private function start():void
        {
            channel = sound.play(0);
            addEventListener(flash.events.Event.ENTER_FRAME, tick);
        }

        private function soundComplete():void
        {
            gradientMatrix = new Matrix();
            offscreenSprite = new Sprite();
            offscreenGraphics = offscreenSprite.graphics;
            angle = 0;
            renderMatrix = new Matrix();
            renderBuffer = new BitmapData(WIDTH, HEIGHT, false, 0);
            renderBitmap = new Bitmap(renderBuffer);
            addChild(renderBitmap);
            renderColor = new ColorTransform();
            fadeTransform = new ColorTransform(1, 1, 1, 1, -8, -8, -8, 0);
            blurFilter = new flash.filters.BlurFilter(2, 2, 1);
            shader = new Shader();
            shader.byteCode = loader.data; 
            shader.data.src.input = renderBuffer;
            shader.data.size.value = [100];
            posX = 0;
            posY = 0;
            targetX = 0;
            targetY = 0;
            
            start();
         
        }

        
        {
          
        }

       
    }
}


