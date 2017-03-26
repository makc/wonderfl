package {
    import mx.graphics.shaderClasses.ColorShader;
    import flash.utils.getTimer;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.display.*;
    public class FlashTest extends Sprite {
        
        private static const s:Number = 10. / 0x4000;
        private static const t:Number = 360. / 20000;
        
        private var dim:Number = 700;
        private var loader:Loader;
        private var icon:Loader;
        private var grad:Shape;
        
        public function FlashTest() {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
            loader.load(new URLRequest(loaderInfo.parameters['viewer.iconURL']));
            grad = new Shape();
            grad.graphics.beginGradientFill(
                GradientType.LINEAR,
                [0xffc000, 0xff0060],
                [1, 1],
                [0, 255],
                new Matrix(s * dim, 0, 0, 1, 0, 0)
            );
            grad.graphics.drawRect(-dim / 2, -dim / 2, dim, dim);
            grad.x = stage.stageWidth / 2;
            grad.y = stage.stageHeight / 2;
            grad.blendShader = new ColorShader();
            addEventListener(Event.ENTER_FRAME, frame);
        }
        
        private function complete(e:Event):void {
            icon = new Loader();
            icon.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                icon.width = 465;
                icon.height = 465;
            });
            icon.loadBytes(loader.contentLoaderInfo.bytes);
            addChild(icon);
            addChild(grad);
        }
        
        private function frame(e:Event):void {
            grad.rotation = getTimer() * t;
        }
        
    }
}