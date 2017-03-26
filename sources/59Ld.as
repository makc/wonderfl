// forked from FLASHMAFIA's RAYMAFIA
package {
    import flash.display.*;
    import flash.events.Event;
    import com.bit101.components.*;

    [SWF(width = '465', height = '465')]
    public class MiauRay02 extends Sprite {
        private var bmd : BitmapData;
        private var buf : Vector.<uint>;
        private var th : Number;
        private var fcnt : int;
        
        private var lw : Number = 1.0; //left wall
        private var rw : Number = 1.0; //right wall
        private var floor: Number = 1.0; //floor
        private var ceil : Number = 2.0; //ceil
        
        private var panel: SlidePanel;

        function MiauRay02() {
            //stage.stageFocusRect = tabChildren = tabEnabled = mouseChildren = mouseEnabled = false;
            stage.scaleMode = "noScale";
            stage.align = "TL";
            stage.quality = "low";
            stage.frameRate = 32;
            opaqueBackground = 0x0;

            var bm : Bitmap = new Bitmap(bmd = new BitmapData(512, 512, false));
            bm.x = bm.y = (465 - 512) / 2;
            bm.opaqueBackground = 0x0;
            addChild(bm);

            buf = new Vector.<uint>(512 * 512, true);

            th = 2 * Math.PI * Math.random();

            panel = new SlidePanel( 0, 0, 465, 110, 0.7 );
            
            var inpLW : HSlider = new HSlider(panel.panel.content, 10,40, onlw);
            var inpRW : HSlider = new HSlider(panel.panel.content, 200,40, onrw);
            var inpCeil : VSlider = new VSlider(panel.panel.content, 140,20, onceil);
            var inpFloor : VSlider = new VSlider(panel.panel.content, 160,20, onfloor);
            
            inpLW.setSliderParams    (-5, -1, -lw);
            inpRW.setSliderParams    ( 1,  5,  rw);
            inpCeil.setSliderParams  ( 1,  5, -ceil);
            inpFloor.setSliderParams (-5, -1,  floor);
            inpCeil.height = 60;
            inpFloor.height = 60;

            stage.addEventListener(Event.ENTER_FRAME, oef);
            addChild(panel);            
        }

        private function oef(e : Event) : void {
            fcnt++;

            th += 0.053;

            var cx : Number = -2 + 4 * (stage.mouseX / 465);
            var cy : Number = -2 + 4 * (stage.mouseY / 465);

            var amp1 : Number = 0.5 * Math.sin(th);
            var amp2 : Number = 0.5 * Math.cos(th / 4);
            var amp3 : Number = Math.sin(th / 9);

            var lx0 : Number = cx + amp1;
            var ly0 : Number = cy;
            var lz0 : Number = amp2;
            var lx1 : Number = cx;
            var ly1 : Number = cy + amp1;
            var lz1 : Number = amp2;
            var lx2 : Number = cx + amp2;
            var ly2 : Number = cy + amp1;
            var lz2 : Number = 0;
            var lx3 : Number = cx;
            var ly3 : Number = cy;
            var lz3 : Number = cy;

            var ox : Number = amp1;
            var oy : Number = amp2;
            var oz : Number = -2 - 0.9 * amp3;

            var vr : Number;
            var vg : Number;
            var vb : Number;

            var n : uint = (512 * 512) - 512 - (fcnt & 1);
            while (n > 512) {
                n--;
                n--;

                var nx : uint = n & 511;
                var ny : uint = n >> 9;

                var vx : Number = (nx * (2 / 512)) - 1 - ox;
                var vy : Number = (ny * (2 / 512)) - 1 - oy;
                var vz : Number = - 1 - oz;

                var a : Number = ((1 - oz) / vz * vx) + ox;
                var b : Number = ((1 - oz) / vz * vy) + oy;

                if ((a >= -lw) && (a <= rw) && (b >= -ceil) && (b <= floor)) {
                    //back wall
                    vr = a;
                    vg = b;
                    vb = 1;
                } else {
                    a = ((-lw - ox) / vx * vz) + oz;
                    b = ((-lw - ox) / vx * vy) + oy;

                    if ((b >= -ceil) && (b <= floor) && (a >= -1) && (a <= 1)) {
                        //left wall
                        vr = -lw;
                        vg = b;
                        vb = a;
                    } else {
                        a = ((rw - ox) / vx * vz) + oz;
                        b = ((rw - ox) / vx * vy) + oy;

                        if ((b >= -ceil) && (b <= floor) && (a >= -1) && (a <= 1)) {
                            //right wall
                            vr = rw;
                            vg = b;
                            vb = a;
                        } else {
                            a = ((-ceil - oy) / vy * vx) + ox;
                            b = ((-ceil - oy) / vy * vz) + oz;

                            if ((a >= -lw) && (a <= rw) && (b >= -1) && (b <= 1)) {
                                //ceil
                                vr = a;
                                vg = -ceil;
                                vb = b;
                            } else {
                                //floor
                                vr = ((floor - oy) / vy * vx) + ox;
                                vg = floor;
                                vb = ((floor - oy) / vy * vz) + oz;
                           }
                        }
                    }
                }

                var lr : Number = 0xFF / (((vr - lx0) * (vr - lx0)) + ((vg - ly0) * (vg - ly0)) + ((vb - lz0) * (vb - lz0)));
                var lg : Number = 0xFF / (((vr - lx1) * (vr - lx1)) + ((vg - ly1) * (vg - ly1)) + ((vb - lz1) * (vb - lz1)));
                var lb : Number = 0xFF / (((vr - lx2) * (vr - lx2)) + ((vg - ly2) * (vg - ly2)) + ((vb - lz2) * (vb - lz2)));

                var d : Number = 0xFF / (((vr - lx3) * (vr - lx3)) + ((vg - ly3) * (vg - ly3)) + ((vb - lz3) * (vb - lz3)));
                lr += d * 0.5;
                lg += d * 0.5;

                if (lr > 0xFF) lr = 0xFF;
                if (lg > 0xFF) lg = 0xFF;
                if (lb > 0xFF) lb = 0xFF;

                buf[n] = (lr << 16) | (lg << 8) | lb;
            }

            bmd.setVector(bmd.rect, buf);
        }
        
       private function onlw(e: Event): void
       {
           lw = -e.target.value;
       }
       
       private function onrw(e: Event): void
       {
           rw = e.target.value;
       }
       
       private function onceil(e: Event): void
       {
           ceil = e.target.value;
       }
       
       private function onfloor(e: Event): void
       {
           floor = -e.target.value;
       }
   }
}

import flash.display.*;
import flash.events.*;
import com.bit101.components.*;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Cubic;

class SlidePanel extends Sprite {
    public var panel:Window;
    private var openCloseSwitchButton:PushButton;
    private var open:Boolean;

    public override function set width(value:Number):void 
    {
        super.width = value;
        panel.width = value;
        openCloseSwitchButton.x = width - 20;
    }

    public override function set height(value:Number):void 
    {
        super.height = height;
        panel.height = value;
    }

   public function SlidePanel( x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0, alpha:Number = 1) {
        this.x = x;
        this.y = y;
        
        this.alpha = alpha;
        panel = new Window(this, 0, -height, "left, ceiling, floor, right wall");
        panel.width = width - 18;
        panel.height = height;
        
        openCloseSwitchButton = new PushButton(this, width - 18, 0);
        openCloseSwitchButton.width = 18;
        openCloseSwitchButton.addEventListener(MouseEvent.CLICK, openCloseSwitchButtonClickHandler );
        openCloseSwitchButton.label = "+";
        open = false;
    }

    

    private function openCloseSwitchButtonClickHandler( event:MouseEvent=null ):void {
        if ( open )
            hide();
        else
            show();
    }

    private function hide():void {
        open = false;
        openCloseSwitchButton.label = "+";
        BetweenAS3.tween(panel, {y: -panel.height}, null, 0.5, Cubic.easeInOut ).play();
    }

    private function show():void {
        open = true;
        openCloseSwitchButton.label = "-";
        BetweenAS3.tween(panel, { y: 0 }, null, 0.5, Cubic.easeInOut ).play();
    }
}