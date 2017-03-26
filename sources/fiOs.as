// forked from makc3d's Butterfly
package {
    import com.bit101.components.PushButton;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import frocessing.color.ColorHSV;
    [SWF (backgroundColor = "0x000000", frameRate = "60", width = "465", height = "465")]
    public class Butterfly extends Sprite{
        public function Butterfly () {
            color = new ColorHSV(0, 0.7);
            addChild(main = new ButterflyMain());
            addChild(canvas = new Shape());
            canvas.alpha = 0.5;
            btn = new PushButton(this, 0, 0, "Make Butterfly", onClick);
            addEventListener (Event.ENTER_FRAME, loop);
            onClick();
        }
        private var cnt: int = 0;
        private var t: Number = 6;
        private var btn: PushButton;
        private var main: ButterflyMain;
        private var canvas:Shape;
        private var bmd:BitmapData = new BitmapData(465, 465, true, 0);
        private var color:ColorHSV;
        private function loop(e: Event): void {
            var r: Number = Math.exp (Math.sin (t)) - 2 * Math.cos (4 * t) + Math.pow (Math.sin ((t - Math.PI / 2) / 12), 5);
            canvas.graphics.lineTo (465 / 2 + 50 * r * Math.cos (t), 465 / 2 - 30 * r * Math.sin (t));
            t += 0.03;
            cnt++;
            if (cnt == 205) btn.enabled = true;
        }
        
        private function onClick(e: MouseEvent = null): void 
        {
            if (e != null)
            {
                bmd.fillRect(bmd.rect, 0);
                bmd.draw(canvas, null, null, null, null, true);
                main.addButterfly(bmd);
            }
            t -= 0.03;
            canvas.graphics.clear();
            color.h = Math.random() * 360;
            canvas.graphics.beginFill(color.value);
            var r: Number = Math.exp (Math.sin (t)) - 2 * Math.cos (4 * t) + Math.pow (Math.sin ((t - Math.PI / 2) / 12), 5);
            canvas.graphics.moveTo (465 / 2 + 50 * r * Math.cos (t), 465 / 2 - 30 * r * Math.sin (t));
            t += 0.03;
            btn.enabled = false;
            cnt = 0;
        }
    }
}
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getTimer;
import org.papervision3d.core.effects.view.ReflectionView;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.WireframeMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Plane;

/**
 * 参考 MoviePuzzle : Reflection Butterfly
 * @see http://wonderfl.net/c/yLth 
 */
class ButterflyMain extends ReflectionView
{
    private var earth:Plane;
    function ButterflyMain()
    {
        super(465, 465, false);
        opaqueBackground = 0;
        surfaceHeight = 0;
        addEventListener(Event.ENTER_FRAME, function(e: Event): void {
            camera.x = 500 * Math.sin(getTimer() / 2000);
            camera.y = 600;
            camera.z = 500 * Math.cos(getTimer() / 2000);
            camera.zoom = 10 * Math.sin(getTimer() / 2000) + 40;
            singleRender();
        } );
    }
    
    public function addButterfly(bmd: BitmapData): void
    {
        if (earth == null)
        {
            earth = new Plane(new WireframeMaterial(0xCCCCCC, 0.5), 1000, 1000, 5, 5);
            earth.rotationX = 90;
            scene.addChild(earth);
        }
        var butterfly: DisplayObject3D = new DisplayObject3D();
        var left: DisplayObject3D = new DisplayObject3D();
        var right: DisplayObject3D = new DisplayObject3D();
        
        var bmdL: BitmapData = new BitmapData(bmd.width >> 1, bmd.height, true, 0);
        var bmdR: BitmapData = bmdL.clone();
        bmdL.copyPixels(bmd, bmd.rect, new Point());
        bmdR.copyPixels(bmd, bmd.rect, new Point(- bmd.width >> 1));
        var matL: BitmapMaterial = new BitmapMaterial(bmdL);
        var matR: BitmapMaterial = new BitmapMaterial(bmdR);
        matL.doubleSided = matR.doubleSided = true;
        
        var planeL: Plane = new Plane(matL, 200, 200, 1, 1);
        var planeR: Plane = new Plane(matR, 200, 200, 1, 1);
        
        //planeL.scaleX = -1;
        planeL.x = -100
        planeR.x =  100;
        
        left.addChild(planeL);
        right.addChild(planeR);
        
        butterfly.addChild(left);
        butterfly.addChild(right);
        butterfly.rotationX = 90;
        //butterfly.yaw(Math.random() * 360);
        butterfly.rotationY = Math.random() * 360;
        scene.addChild(butterfly);
        addEventListener(Event.ENTER_FRAME, makeButterflyMove(butterfly, left, right));
    }
    
    private function makeButterflyMove(butterfly:DisplayObject3D, left:DisplayObject3D, right:DisplayObject3D): Function 
    {
        var n: int = 0;
        var handler: Function = function(e: Event): void {
            n ++;
            butterfly.y     = - Math.sin(n/10) * 25 + 240;
            left.rotationY  =   Math.sin(n/10) * 60;
            right.rotationY = - Math.sin(n / 10) * 60;
            left.y = right.y = n;
            if (n > 3000)
            {
                scene.removeChild(butterfly);
                removeEventListener(Event.ENTER_FRAME, handler);
            }
        };
        return handler;
    }
}
