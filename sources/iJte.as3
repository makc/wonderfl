/*
   久々のPV3D。
   やっぱASは打ってて楽しい。
*/
package
{
    import flash.events.Event;
    import flash.filters.BlurFilter;

    import org.papervision3d.core.effects.BitmapLayerEffect;
    import org.papervision3d.core.effects.utils.BitmapClearMode;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.BitmapEffectLayer;

    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="40")]

    public class PV3D_pixels extends BasicView
    {
        private var pixels:Pixels;
        private var rotateX:Number;
        private var rotateY:Number;

        public function PV3D_pixels()
        {
            super(0, 0, true, true);

            var layer:BitmapEffectLayer=new BitmapEffectLayer(viewport, 800, 800, true, 0, BitmapClearMode.CLEAR_PRE, true);
            viewport.containerSprite.addLayer(layer);
            layer.addEffect(new BitmapLayerEffect(new BlurFilter(8, 8, 4), false));

            camera.z=-500;

            rotateX=rotateY=0;

            pixels=new Pixels(layer);
            scene.addChild(pixels);

            for(var i:int=0; i < 1000; i++)
            {
                // 赤
                var theta1:Number=360 * Math.random() * Math.PI / 180;
                var theta2:Number=(180 * Math.random() - 90) * Math.PI / 180;
                var radius:Number=200;
                var xx:Number=radius * Math.cos(theta2) * Math.sin(theta1);
                var yy:Number=radius * Math.sin(theta2);
                var zz:Number=radius * Math.cos(theta2) * Math.cos(theta1);
                var p:Pixel3D=new Pixel3D((0xffff0000), xx, yy, zz);
                pixels.addPixel3D(p);

                // 黄色
                theta1=360 * Math.random() * Math.PI / 180;
                theta2=(180 * Math.random() - 90) * Math.PI / 180;
                radius=200;
                xx=radius * Math.cos(theta2) * Math.sin(theta1);
                yy=radius * Math.sin(theta2);
                zz=radius * Math.cos(theta2) * Math.cos(theta1);
                p=new Pixel3D((0xffffff00), xx, yy, zz);
                pixels.addPixel3D(p);

                // 白
                theta1=360 * Math.random() * Math.PI / 180;
                theta2=(180 * Math.random() - 90) * Math.PI / 180;
                radius=200;
                xx=radius * Math.cos(theta2) * Math.sin(theta1);
                yy=radius * Math.sin(theta2);
                zz=radius * Math.cos(theta2) * Math.cos(theta1);
                p=new Pixel3D((0xffffffff), xx, yy, zz);
                pixels.addPixel3D(p);

                // オレンジ
                theta1=360 * Math.random() * Math.PI / 180;
                theta2=(180 * Math.random() - 90) * Math.PI / 180;
                radius=200;
                xx=radius * Math.cos(theta2) * Math.sin(theta1);
                yy=radius * Math.sin(theta2);
                zz=radius * Math.cos(theta2) * Math.cos(theta1);
                p=new Pixel3D((0xffff8c00), xx, yy, zz);
                pixels.addPixel3D(p);
            }

            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function onFrame(e:Event):void
        {
            rotateX+=(-viewport.containerSprite.mouseX - rotateX) * 0.1;
            rotateY+=(-viewport.containerSprite.mouseY - rotateY) * 0.1;
            pixels.rotationY=rotateX;
            pixels.rotationX=rotateY;

            singleRender();
        }
    }
}

