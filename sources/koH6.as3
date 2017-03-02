package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.utils.*;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.cameras.CameraType;
    import org.papervision3d.core.effects.BitmapLayerEffect;
    import org.papervision3d.core.effects.utils.BitmapDrawCommand;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.special.ParticleMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.objects.special.ParticleField;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.BitmapEffectLayer;

    public class Main extends BasicView {
        private const PIXEL_NUM     :int    = 22;
        private const MAX_RADIUS    :int    = 20000;
        private const PLANE_SIZE    :int    = 100;
        private const PLANE_MARGIN  :int    = 20;
        private var pixelArr        :Array  = [];
        private var dmyObjs         :Array  = [];
        private var dmyPixels       :Array  = [];
        private var index           :int    = 0;
        
        
        private var bfx:BitmapEffectLayer;
        static private const IMAGE_LIST:Array = [
            [
                [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            ],
                        [
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0], 
                [0,0,0,1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,0,0,0], 
                [0,1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,0], 
                [0,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [0,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0], 
                [0,1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,0], 
                [0,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0]
            ],
            [
                [0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,1,1,1,1,1,0,1,1,0,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0]
            ]
        ];
        
        public function Main() {
            super(0, 0, true, false, CameraType.FREE);
            viewport.opaqueBackground = 0x0;
            stage.quality = StageQuality.MEDIUM;
            
            // create the effect layer
            bfx = new BitmapEffectLayer(viewport, 465, 465);
            bfx.addEffect(new BitmapLayerEffect(new BlurFilter(16, 16, 1)));
            bfx.clippingPoint = new Point(0, -5);
            bfx.drawCommand = new BitmapDrawCommand(null, new ColorTransform(0.9, 0.8, 1, 0.2), BlendMode.ADD);
            viewport.containerSprite.addLayer(bfx);
            
            camera.focus = 150;
            camera.zoom = 1;
            
            var timer:Timer = new Timer(9000);
            timer.addEventListener(TimerEvent.TIMER, loop);
            timer.start()
            
            init()
            setTimeout(loop, 100);
            
            startRendering()
        }
        
        private function init():void {
            var stars:ParticleField = new ParticleField(new ParticleMaterial(0xFFFFFF, 2, 0), 1000, 100, MAX_RADIUS * 3, MAX_RADIUS * 3, MAX_RADIUS * 3);
            scene.addChild(stars);
            
            var material:ColorMaterial = new ColorMaterial(0xEECCFF);
            
            for (var i:int = 0; i < PIXEL_NUM; i++) {
                pixelArr[i] = [];
                for (var j:int = 0; j < PIXEL_NUM; j++ ) {
                    var o:Plane = new Plane(material, PLANE_SIZE, PLANE_SIZE);
                    scene.addChild(o);
                    pixelArr[i][j] = o;
                    bfx.addDisplayObject3D(o);
                }
            }
            
            for (var k:int = 0; k < IMAGE_LIST.length; k++) 
            {
                dmyObjs[k] = new DisplayObject3D();
                dmyObjs[k].x = MAX_RADIUS * (Math.random() - 0.5);
                dmyObjs[k].y = MAX_RADIUS * (Math.random() - 0.5);
                dmyObjs[k].z = MAX_RADIUS * (Math.random() - 0.5);
                dmyObjs[k].rotationX = 360 * Math.random();
                dmyObjs[k].rotationY = 360 * Math.random();
                dmyObjs[k].rotationZ = 360 * Math.random();
                
                scene.addChild(dmyObjs[k]);
                
                dmyPixels[k] = [];
                
                for (i = 0; i < PIXEL_NUM; i++) {
                    dmyPixels[k][i] = [];
                    
                    for (j = 0; j < PIXEL_NUM; j++ ) {
                        dmyPixels[k][i][j] = new DisplayObject3D();
                        dmyPixels[k][i][j].x = (+i - PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                        dmyPixels[k][i][j].y = (-j + PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                        dmyObjs[k].addChild(dmyPixels[k][i][j]);
                    }
                }
            }
        }
        
        private function loop(e:TimerEvent = null):void {
            index ++;
            if (index == IMAGE_LIST.length) index = 0;
            
            var cameraTarget :DisplayObject3D = new DisplayObject3D();
            cameraTarget.copyTransform( dmyObjs[index] );
            cameraTarget.moveBackward(2500);
            
            BetweenAS3.parallel(
                BetweenAS3.delay(
                    BetweenAS3.bezier(camera, {
                            x : cameraTarget.x,
                            y : cameraTarget.y,
                            z : cameraTarget.z,
                            rotationX : cameraTarget.rotationX,
                            rotationY : cameraTarget.rotationY,
                            rotationZ : cameraTarget.rotationZ
                        },null, getRandomPos(), 6.5, Quint.easeInOut ),
                        1.4)
                ).play();
            
            for (var i:int = 0; i < PIXEL_NUM; i++) {
                for (var j:int = 0; j < PIXEL_NUM; j++ ) {
                    var o:DisplayObject3D = pixelArr[i][j];
                    var t:DisplayObject3D = dmyPixels[index][j][i];
                    var s:Object = IMAGE_LIST[index][i][j];
                    
                    BetweenAS3.delay(
                        BetweenAS3.bezier(o,{
                            x : t.sceneX,
                            y : t.sceneY,
                            z : t.sceneZ,
                            scale : s,
                            rotationX : dmyObjs[index].rotationX,
                            rotationY : dmyObjs[index].rotationY,
                            rotationZ : dmyObjs[index].rotationZ
                        },null, getRandomPos(), 7 + Math.random(), Quart.easeInOut),
                        Math.random() * 1).play();
                }
            }
            
            setTimeout(function():void
            {
                bfx.drawCommand = new BitmapDrawCommand(null, new ColorTransform(0.7, 0.4, 1, 1), BlendMode.ADD);
                bfx.clippingPoint = new Point(0, -5);
            }, 1900);
            
            setTimeout(function():void
            {
                bfx.drawCommand = new BitmapDrawCommand(null, new ColorTransform(0.9, 0.8, 1, 0.05), BlendMode.ADD);
                bfx.clippingPoint = new Point(0, 0);
            }, 5000);
        }
        
        private function getRandomPos():Object {
            return {
                x : MAX_RADIUS * (Math.random() - 0.5),
                y : MAX_RADIUS * (Math.random() - 0.5),
                z : MAX_RADIUS * (Math.random() - 0.5)
            };
        }
    }
}
