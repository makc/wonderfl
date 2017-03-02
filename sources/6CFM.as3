/*=====================================================*//**
* Papervison3Dを利用したリボン表現
*
* Tweenerを使って作成したベジェ曲線に
* Planeを位置と角度を調整して並べています。
* 強引なやり方なので、いい方法があったら教えてください！
* 
* @author Yasu (clockmaker.jp)
*//*======================================================*/
package
{
    import caurina.transitions.properties.CurveModifiers;
    import caurina.transitions.Tweener;
    import flash.display.*;
    import flash.events.*;
    import flash.utils.getTimer;
    import org.papervision3d.core.geom.*;
    import org.papervision3d.core.geom.renderables.*;
    import org.papervision3d.core.proto.*;
    import org.papervision3d.materials.shadematerials.*;
    import org.papervision3d.materials.special.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.*;
    import org.papervision3d.cameras.*;
    import org.papervision3d.lights.*
    import org.papervision3d.materials.*
    import org.papervision3d.materials.utils.*
    import org.papervision3d.core.math.Matrix3D;
    
    [SWF(width = "720", height = "480", frameRate = "60", backgroundColor="0xFFFFFF")]

    public class Main extends BasicView
    {
                private var lineMaterial            :LineMaterial;
                private var _arrLines                :Array     = [];
                private var _objArray                :Array     = [];
                private var LINES_NUM        :int     = 1
                private var MAX_RADIUS        :int    = 3000;
                private var POINT_NUM        :uint     = 5
                private var VERTICES_NUM    :uint     = 400
                private var CAMERA_POSITION    :uint     = 3000;
        
        public function Main()
        {
            super(0, 0, true, false, CameraType.FREE);
            CurveModifiers.init();
            camera.focus = 250
            camera.zoom = 1
            init()
            startRendering()
        }

        private function init():void
        {
            // 3d
            for (var i:int = 0; i < LINES_NUM; i++)
            {
                _arrPlanes[i] = [];
            }
            
            // 2d
            for (i = 0; i < LINES_NUM; i++)
            {
                var newPos:Object = getRandomPos()
                var o:Object =
                {
                    x         : newPos.x,
                    prevX     : newPos.x,
                    y         : newPos.y,
                    prevY     : newPos.y,
                    z         : newPos.z,
                    prevZ     : newPos.z,
                    color     : Math.random() * 0xFFFFFF
                }
                
                _objArray.push(o)
                randomTween(getRandomData(o))
            }
        }

        private function randomTween(o:Object):void
        {
            Tweener.addTween(o,
            { 
                x            :    o.x1,
                y            :    o.y1, 
                z            :    o.z1, 
                _bezier        :    o.bezier, 
                time                :    o.time,
                transition            :    "linear", 
                onComplete    :    function():void
                {
                    randomTween(getRandomData(o));
                }
            });
        }
        
        private function getRandomData(o:Object):Object
        {
            o.time = (POINT_NUM * 0.5) + (POINT_NUM * .75);
            var newPos:Object = getRandomPos();
            o.x1 = newPos.x;
            o.y1 = newPos.y;
            o.z1 = newPos.z;
            o.bezier = [];
            for (var i:int = 0; i < POINT_NUM; i++)
            {
                var newBezierPos:Object = getRandomPos();
                o.bezier.push(
                {
                    x : newBezierPos.x,
                    y : newBezierPos.y,
                    z : newBezierPos.z
                });
            }
            return o;
        }

        private function getRandomPos():Object
        {
            var angleY:Number = Math.random() * 2 * Math.PI;
            var angleXZ:Number = Math.random() * 2 * Math.PI;
            return {
                x : Math.cos(angleY) * Math.sin(angleXZ) * MAX_RADIUS,
                y : Math.sin(angleY) * Math.sin(angleXZ) * MAX_RADIUS,
                z : Math.cos(angleXZ) * MAX_RADIUS
            };
        }
        
        private var _arrPlanes:Array = []
        
        override protected function onRenderTick(e:Event = null):void
        {
            for (var i:int = 0; i < LINES_NUM; i++)
            {
                var d1:DisplayObject3D = new DisplayObject3D()
                d1.x = _objArray[i].x
                d1.y = _objArray[i].y
                d1.z = _objArray[i].z
                var d2:DisplayObject3D = new DisplayObject3D()
                d2.x = _objArray[i].prevX
                d2.y = _objArray[i].prevY
                d2.z = _objArray[i].prevZ
                
                d1.lookAt(d2);
            
                // Planes
                var len:Number = Math.sqrt(
                    (_objArray[i].x - _objArray[i].prevX) * (_objArray[i].x - _objArray[i].prevX)
                    + (_objArray[i].y - _objArray[i].prevY) * (_objArray[i].y - _objArray[i].prevY)
                    + (_objArray[i].z - _objArray[i].prevZ) * (_objArray[i].z - _objArray[i].prevZ)
                )
                
                var mat:MaterialObject3D = new WireframeMaterial(_objArray[i].color)
                mat.doubleSided = true
                var o:DisplayObject3D = scene.addChild(new Plane(mat, 100, 100))

                o.copyTransform(d1.transform)
                o.pitch(90)
                
                _arrPlanes[i].push(o);
                
                if (_arrPlanes[i].length > 10)
                {
                    var tmp:DisplayObject3D = _arrPlanes[i][0]
                    
                    var cameraTarget :DisplayObject3D = new DisplayObject3D();
                    cameraTarget.copyTransform( tmp );
                    cameraTarget.moveBackward(100);
                    cameraTarget.moveUp(100);
                    camera.copyTransform(cameraTarget)
                    
                    camera.lookAt(_arrPlanes[i][10])
                    cameraTarget = null
                }
                
                if (_arrPlanes[i].length > VERTICES_NUM)
                {
                    scene.removeChild(_arrPlanes[i].shift())
                }
                
                _objArray[i].prevX = _objArray[i].x;
                _objArray[i].prevY = _objArray[i].y;
                _objArray[i].prevZ = _objArray[i].z;
            }
            
            super.onRenderTick(e);
        }
    }
}