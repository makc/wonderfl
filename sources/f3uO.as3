/**
* スライム
*/
package 
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.geom.Matrix;
    import flash.display.BitmapData;
    import com.actionsnippet.qbox.QuickBox2D;
    import com.actionsnippet.qbox.QuickObject;
    
    import flash.system.LoaderContext;
    
    public class FlashTest extends Sprite 
    {
            private var points:Array;
            private var centerObj:QuickObject;
            private var shape:Shape;
            private var loader:Loader;
            private var faceMatrix:Matrix;
            private var face:BitmapData;
            
            
            private const url:String = "http://assets.wonderfl.net/images/related_images/c/c4/c47a/c47a1475f2e789c8b0f7533f0875095377ade1af";
            
        public function FlashTest() 
        {
            // write as3 code here..
            Wonderfl.capture_delay( 30 );
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void
        {
                //
                stage.align = StageAlign.TOP_LEFT;
                stage.scaleMode = StageScaleMode.NO_SCALE;
                
                faceMatrix = new Matrix();
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
                loader.load(new URLRequest(url), new LoaderContext(true));
                
        }

        private function onComp(e:Event):void
        {
                face = Bitmap(loader.content).bitmapData;
                var mc:MovieClip = new MovieClip();
                addChild(mc);
                var sim:QuickBox2D = new QuickBox2D(mc);
                centerObj = sim.addCircle({x:5, y:5, radius: 1.2, lineAlpha: 0, fillAlpha: 0 });
                var rot:Number = 0, n:int = 10, i:int, rn:Number = 180 / n, xx:Number, yy:Number, 
                    pB:QuickObject, pC:QuickObject, pD:QuickObject, pE:QuickObject, pF:QuickObject, pG:QuickObject, 
                    arr1:Array = [], arr2:Array = [];
                for (i = 0; i < n; i++)
                {
                    xx = Math.sin(rot * Math.PI / 180) * 2 + 5;
                    yy = Math.cos(rot * Math.PI / 180) * 2 + 5;
                    pB = sim.addCircle(
                        {x: xx, y: yy, radius: 0.01, density: 250, lineAlpha: 0, fillAlpha: 0 }
                    );
                    xx = Math.sin((rot + 180) * Math.PI / 180) * 2 + 5;
                    yy = Math.cos((rot + 180) * Math.PI / 180) * 2 + 5;
                    pC = sim.addCircle(
                        {x: xx, y: yy, radius: 0.01, density: 250, lineAlpha: 0, fillAlpha: 0 }
                    );
                    sim.addJoint({a: centerObj.body, b: pB.body, frequencyHz: 10, lineAlpha: 0});
                    sim.addJoint({a: centerObj.body, b: pC.body, frequencyHz: 10, lineAlpha: 0});
                    arr1[i] = pB, arr2[i] = pC;
                    if (pD)
                    {
                        sim.addJoint( {a: pB.body, b: pD.body, frequencyHz: 50, lineAlpha: 0} );
                        sim.addJoint( {a: pC.body, b: pE.body, frequencyHz: 50, lineAlpha: 0} );
                    }
                    else
                    {
                        pF = pB, pG = pC;
                    }
                    pD = pB, pE = pC;
                    rot += rn;
                }
                
                sim.addJoint( {a: pB.body, b: pG.body, frequencyHz: 50, lineAlpha: 0} );
                sim.addJoint( {a: pC.body, b: pF.body, frequencyHz: 50, lineAlpha: 0} );
                
                points = arr2.concat(arr1);
                
                sim.createStageWalls();
                sim.start();
                sim.mouseDrag();
                //removeChild(mc);
                addChild(shape = new Shape());
                addEventListener(Event.ENTER_FRAME, loop);
                
        }
        
        private function loop(e:Event):void
        {
                var g:Graphics = shape.graphics, p1:QuickObject = points[0], p2:QuickObject,
                    i:int, n: int = points.length, px:Number, py:Number,
                    tx:Number, ty:Number;
                g.clear();
                g.beginFill(0x3399CC);
                g.moveTo(p1.x * N, p1.y * N);
                for (i = 0; i < n; i += 2)
                {
                    p1 = points[i    ];
                    p2 = points[i + 1];
                    px = (centerObj.x - p2.x) * 0.05 + p2.x;
                    py = (centerObj.y - p2.y) * 0.05 + p2.y;
                    g.curveTo(p1.x * N, p1.y * N, px * N, py * N);
                }
                px = centerObj.x * N;
                py = centerObj.y * N;
                tx = stage.mouseX - px;
                ty = stage.mouseY - py;
                tx = tx / stage.stageWidth  * 3;
                ty = ty / stage.stageHeight * 3;
                faceMatrix.tx = px - 35;
                faceMatrix.ty = py - 35;
                g.beginBitmapFill(face, faceMatrix, false, true);
                g.drawRect(faceMatrix.tx, faceMatrix.ty, 70, 70);
                g.beginFill(0x000000);
                g.drawCircle(px - 20 + tx, py - 20 + ty, 7);
                g.drawCircle(px + 20 + tx, py - 20 + ty, 7);
        }
    }
}
/// 実際のx,yがちいさいからとりあえず30倍したら丁度よかった。
const N:int = 30;

