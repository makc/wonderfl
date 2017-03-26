/*
   Depth of Field Demo
   with Papervision3D, BetweenAS3, Progression 4

   被写界深度的なエフェクトのかかったパーティクルデモ
   練習がてら和製ライブラリを使って見よう見まねで作ってみた

   inspired by mr.doob
   http://blog.papervision3d.org/2007/09/04/mrdoobs-dof-experiments/
 */
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.LoadBitmapData;
    import jp.progression.data.getResourceById;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.core.easing.*;
    import org.libspark.betweenas3.easing.Bounce;
    import org.libspark.betweenas3.easing.Expo;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.core.math.Number3D;
    import org.papervision3d.core.proto.MaterialObject3D;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;
    
    [SWF(width=465, height=465, frameRate=90)]
    /**
     * Depth of Field Demo
     * @author yasu
     */
    public class Main extends BasicView {
        public static const IMG_URL:String = "http://assets.wonderfl.net/images/related_images/0/05/0577/05777317b05c43a2aa44e3c2e13d71b01d561497";
        private static const FOCUS_POSITION:int = 1000;
        private static const MAX_NUM:int = 150;
        private static const SNOW_MAX_DEPTH:int = 24;
        
        public function Main() {
            stage.quality = StageQuality.LOW;
            new SerialList(null,
                new LoadBitmapData(new URLRequest(IMG_URL), { context: new LoaderContext(true)}),
                init).execute();
        }
        private var _blurs:Vector.<BitmapData>;
        private var _particles:Vector.<Plane>;
        private var _pitch:Number = 0;
        private var _radius:Number = 1000;
        private var _targetVertexs:Vector.<Vertex3D>;
        private var _yaw:Number = 0;
        
        protected function init():void {
            // bmp
            var bmd:BitmapData = getResourceById(IMG_URL).toBitmapData();
            // create blur field material
            _blurs = new Vector.<BitmapData>(SNOW_MAX_DEPTH, true);
            for (var i:int = 0; i < SNOW_MAX_DEPTH; i++) {
                // create circle graphics
                var sp:Sprite = new Sprite();
                //sp.addChild(new BallImage());
                sp.addChild(new Bitmap(bmd));
                // ぼかしの適用値
                var blurFilter:BlurFilter = new BlurFilter(i, i, 4);
                // add Fileter
                sp.filters = [ blurFilter ];
                // copy bitmapdata
                var bitmapData:BitmapData = new BitmapData(100, 100, true, 0x00000000);
                bitmapData.draw(sp);
                // save
                _blurs[ i ] = bitmapData;
            }
            var vertexts:Array = [];
            // sphere
            vertexts[ 0 ] = [];
            var w:MaterialObject3D = new MaterialObject3D();
            var d:DisplayObject3D = new Sphere(w, 700, 13, 13);
            vertexts[ 0 ] = d.geometry.vertices;
            // cube
            d = new Cube(new MaterialsList({ all: w }), 1000, 1000, 1000, 5, 5, 5);
            vertexts[ 1 ] = d.geometry.vertices;
            // random
            vertexts[ 2 ] = [];
            for (i = 0; i < MAX_NUM; i++)
                vertexts[ 2 ][ i ] = new Vertex3D((Math.random() - 0.5) * 3000, (Math.random() - 0.5) * 3000, (Math.random() - 0.5) * 3000);
            // earth
            vertexts[ 3 ] = [];
            for (i = 0; i < MAX_NUM; i++) {
                vertexts[ 3 ][ i ] = vertexts[ 2 ][ i ].clone();
                vertexts[ 3 ][ i ].y = -1500;
            }
            // cylinder
            d = new Cylinder(w, 500, 1500, 15, 9);
            vertexts[ 4 ] = d.geometry.vertices;
            // init particle 
            _particles = new Vector.<Plane>(MAX_NUM, true);
            for (i = 0; i < MAX_NUM; i++) {
                // ボール
                var mt:MaterialObject3D = new BitmapMaterial(_blurs[ 0 ]);
                var ball:Plane = new Plane(mt, 100, 100);
                scene.addChild(ball);
                _particles[ i ] = ball;
            }
            // init tween
            _targetVertexs = new Vector.<Vertex3D>(MAX_NUM, true);
            var tweenArr:Array = [];
            var ease:IEasing = new CubicEaseIn();
            for (i = 0; i < MAX_NUM; i++) {
                var t1:Vertex3D = vertexts[ 0 ][ i ];
                var t2:Vertex3D = vertexts[ 1 ][ i ];
                var t3:Vertex3D = vertexts[ 2 ][ i ];
                var t4:Vertex3D = vertexts[ 3 ][ i ];
                var t5:Vertex3D = vertexts[ 4 ][ i ];
                // init
                _targetVertexs[ i ] = t4;
                // sphere
                var tw1:ITween = BetweenAS3.delay(BetweenAS3.tween(_targetVertexs[ i ],
                    { x: t1.x, y: t1.y, z: t1.z },
                    { x: t5.x, y: t5.y, z: t5.z },
                    4, Expo.easeInOut), 1);
                // cube
                var tw2:ITween = BetweenAS3.delay(BetweenAS3.tween(_targetVertexs[ i ],
                    { x: t2.x, y: t2.y, z: t2.z },
                    { x: t1.x, y: t1.y, z: t1.z },
                    4, Expo.easeInOut), 1);
                // random
                var tw3:ITween = BetweenAS3.delay(BetweenAS3.tween(_targetVertexs[ i ],
                    { x: t3.x, y: t3.y, z: t3.z },
                    { x: t2.x, y: t2.y, z: t2.z },
                    3, Expo.easeInOut), 0.5);
                // earth
                var tw4:ITween = BetweenAS3.delay(BetweenAS3.tween(_targetVertexs[ i ],
                    { x: t4.x, y: t4.y, z: t4.z },
                    { x: t3.x, y: t3.y, z: t3.z },
                    1, Bounce.easeOut), 1);
                // cylinder
                var tw5:ITween = BetweenAS3.delay(BetweenAS3.tween(_targetVertexs[ i ],
                    { x: t5.x, y: t5.y, z: t5.z },
                    { x: t4.x, y: t4.y, z: t4.z },
                    4, Expo.easeInOut), 1);
                tweenArr[ i ] = BetweenAS3.delay(BetweenAS3.serial(tw1, tw2, tw3, tw4, tw5), ease.calculate(i, 0, 0.75, MAX_NUM));
            }
            var masterTw:ITween = BetweenAS3.parallelTweens(tweenArr);
            masterTw.stopOnComplete = false;
            masterTw.play();
            // start render
            startRendering();
        }
        
        override protected function onRenderTick(event:Event = null):void {
            // camera
            _pitch += (mouseY / stage.stageHeight - 0.5) * 1;
            _yaw += (mouseX / stage.stageWidth - 0.5) * 4;
            camera.x = Math.sin(_yaw * Number3D.toRADIANS) * _radius;
            camera.z = Math.cos(_yaw * Number3D.toRADIANS) * _radius;
            camera.y = _pitch * _radius * 0.01;
            // particle
            for (var i:int = 0; i < MAX_NUM; i++) {
                var p:Plane = _particles[ i ];
                p.x = _targetVertexs[ i ].x;
                p.y = _targetVertexs[ i ].y;
                p.z = _targetVertexs[ i ].z;
                p.scale = Math.sin(getTimer() / 150 + i * 0.04) * 0.5 + 1.1;
                // calc distance
                var f:Number = Math.abs(camera.distanceTo(p) - FOCUS_POSITION);
                var deg:Number = (f ^ (f >> 31)) - (f >> 31); // Math.abs(f)と同等
                // calc blur val
                var blurVal:int = deg * .02 << 1; //ココの調整が絶妙
                blurVal = blurVal > SNOW_MAX_DEPTH - 1 ? SNOW_MAX_DEPTH - 1 : blurVal;
                p.material.bitmap = _blurs[ blurVal ];
                // lookat camera
                p.lookAt(camera);
                p.yaw(180);
            }
            super.onRenderTick(event);
        }
    }
}