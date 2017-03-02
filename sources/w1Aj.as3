package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.filters.BlurFilter;
    
    import flash.geom.ColorTransform;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {        
        public static const WIDTH:int = 465;
        public static const HEIGHT:int = 465;
        
        private var label:Label;
        private var labelMat:Matrix;
        private var back:BitmapData;
        private var backMask:Sprite;
        private var canvas:BitmapData;
        private var shadow:BitmapData;
        private var perlin:BitmapData;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            this.cacheAsBitmap = true;
            
            
            perlin = new BitmapData(WIDTH, HEIGHT, true, 0);
        
            //    背景のノイズ初期化
            var mat:Matrix = new Matrix();
            mat.createGradientBox(WIDTH, HEIGHT, Math.PI / 2, 0, 0);
            backMask = new Sprite();
            backMask.cacheAsBitmap = true;
            backMask.graphics.beginGradientFill(
                                "linear", 
                                [0, 0, 0],
                                [0.5, 0.1, 0.5],
                                [0, 128, 255],
                                mat
            );
            backMask.graphics.drawRect(0, 0, WIDTH, HEIGHT);
            backMask.graphics.endFill();        
            back = new BitmapData(WIDTH, HEIGHT, true, 0);
            var backbmp:Bitmap = new Bitmap(back);
            backbmp.cacheAsBitmap = true;
            backbmp.mask = backMask;
            addChild( backbmp );
            addChild( backMask );
            
            //    テキストの影
            shadow = new BitmapData(WIDTH, HEIGHT, true, 0);
            addChild( new Bitmap(shadow) );
        
            
            label = new Label("wonderfl");
            labelMat = new Matrix(1, 0, 0, 1, WIDTH / 2 - label.width / 2, HEIGHT / 2 - label.height / 2);
            canvas = new BitmapData(WIDTH, HEIGHT, true, 0);
            addChild( new Bitmap(canvas) );
            
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
        }
        
        private function EnterFrameHandler( e:Event ) : void
        {
            perlin.perlinNoise(
                20,
                20,
                1,
                Math.random() * 100,
                true,
                false,
                BitmapDataChannel.ALPHA | BitmapDataChannel.RED,
                false,
                [0]
            );            
            
            canvas.fillRect(canvas.rect, 0 );
            labelMat.tx = WIDTH / 2 - label.width / 2 + (Math.random() * 4 - 2);
            labelMat.ty = HEIGHT / 2 - label.height / 2 + (Math.random() * 4 - 2);
            canvas.draw( label, labelMat );
            
            
            var scale:Number = 5;
            if ( int(Math.random() * 30) == 0 )    scale = 40;
            
            canvas.applyFilter(
                canvas,
                canvas.rect,
                new Point(),
                new DisplacementMapFilter(
                    perlin,
                    new Point(),
                    BitmapDataChannel.ALPHA,
                    BitmapDataChannel.RED,
                    scale,
                    scale,
                    DisplacementMapFilterMode.CLAMP,
                    0,
                    0
                )
            );
            
            shadow.fillRect(shadow.rect, 0);
            shadow.draw(canvas, null, new ColorTransform(0,0,0,1,50,50,50,0) );
            shadow.applyFilter( shadow, shadow.rect, new Point(), new BlurFilter(10, 10,3) );
            
            
            //    後ろのノイズ部分
            back.noise( 
                Math.random() * 100,
                0,
                255,
                8 | 4 | 2 | 1,
                true
            );
            
            
        }
        
    }
    
}

import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Sprite;

class Label extends Sprite {
    
    private var text:TextField;
    
    public function Label( t:String ) {
        
        var tf:TextFormat = new TextFormat();
        tf.font = "_ゴシック";
        tf.size = 80;
        tf.bold = true;
        
        text = new TextField();
        text.defaultTextFormat = tf;
        text.textColor = 0;
        text.selectable = false;
        text.text = t;
        text.autoSize = "left";
        
        addChild( text );
    }
    
}