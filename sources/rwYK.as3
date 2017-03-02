/*
     お手軽キラキラPixel3D！
     キラキラ方法はこちらを使わせてもらいましたー：http://wonderfl.net/code/71344f9a655053d9f793a32c68f00921c67f1977    
*/
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.PixelSnapping;
    import flash.events.Event;
    import flash.geom.Matrix;
    import org.papervision3d.core.effects.utils.BitmapClearMode;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.BitmapEffectLayer;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="40")]
    public class Papervision3D_sample95 extends BasicView
    {
        private var pixels:Pixels;
        private var canvas:BitmapData;
        private var mtx:Matrix;

        public function Papervision3D_sample95()
        {
            super(0, 0, true, true);

            var layer:BitmapEffectLayer=new BitmapEffectLayer(viewport, 465, 465, true, 0, BitmapClearMode.CLEAR_PRE, true);
            layer.clearBeforeRender=true;
            viewport.containerSprite.addLayer(layer);

            camera.z=-500;
            pixels=new Pixels(layer);
            scene.addChild(pixels);

            for(var i:int=0; i < 5000; i++)
            {
                var theta1:Number=360 * Math.random() * Math.PI / 180;
                var theta2:Number=(180 * Math.random() - 90) * Math.PI / 180;
                var radius:Number=230;
                var xx:Number=radius * Math.cos(theta2) * Math.sin(theta1);
                var yy:Number=radius * Math.sin(theta2);
                var zz:Number=radius * Math.cos(theta2) * Math.cos(theta1);
                var p:Pixel3D=new Pixel3D((0xff << 24 | 0xff * Math.random() << 16 | 0xff * Math.random() << 8 | 0xff), xx, yy, zz);
                pixels.addPixel3D(p);
            }

            canvas=new BitmapData(465 / 4, 465 / 4, false, 0x000000);
            var bmp:Bitmap=new Bitmap(canvas, PixelSnapping.NEVER, true);
            bmp.scaleX=bmp.scaleY=4;
            bmp.smoothing=true;
            bmp.blendMode=BlendMode.ADD;
            addChild(bmp);
            mtx = new Matrix(0.25, 0, 0, 0.25);
           
            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function onFrame(e:Event):void
        {
            canvas.fillRect(canvas.rect, 0x000000);
            canvas.draw(viewport, mtx);
            
            pixels.rotationY+=0.5;
            pixels.rotationX+=0.5;
        
            singleRender();
        }
    }
}