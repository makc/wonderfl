package  {
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import org.papervision3d.core.geom.renderables.Triangle3D;
    import org.papervision3d.core.geom.TriangleMesh3D;
    import org.papervision3d.core.math.NumberUV;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.objects.primitives.Sphere;
    import org.papervision3d.render.QuadrantRenderEngine;
    import org.papervision3d.view.BasicView;
    public class Test extends BasicView {
        private var _obj1:Sphere;
        private var _obj2:Sphere;
        private var _mat1:BitmapMaterial;
        private var _mat2:BitmapMaterial;
        public function Test() {
            super(465, 465);
            renderer = new QuadrantRenderEngine(QuadrantRenderEngine.ALL_FILTERS);
            
            var tf:TextField = new TextField();
            tf.text = "BitmapMaterial";
                        
            var bmp1:BitmapData = new BitmapData(465, 465, false, 0);
            bmp1.perlinNoise(200, 200, 3, 1234, false, true);
            bmp1.draw(tf, new Matrix(5, 0, 0, 5, 30, 150));
            
            var bmp2:BitmapData = new BitmapData(465, 465, false, 0);
            bmp2.noise(1);
            bmp2.draw(bmp2, new Matrix(2, 0, 0, 1));
            bmp2.draw(tf, new Matrix(5, 0, 0, 5, 30, 150), new ColorTransform(1,1,1,1,0xFF,0xFF,0xFF));
            
            _mat1 = new BitmapMaterial(bmp1, true);
            _mat2 = new BitmapMaterial(bmp2, true);
            _mat1.tiled = true;
            _mat2.tiled = true;
            
            _obj1 = new Sphere(_mat1, 500, 4, 2);
            _obj2 = new Sphere(_mat2, 500, 3, 3);
            
            crashUV(_obj1);
            crashUV(_obj2);
            _mat1.resetMapping();
            _mat2.resetMapping();
            
            scene.addChild(_obj1);
            scene.addChild(_obj2);
            
            startRendering();
            
        }
        override protected function onRenderTick(event:Event = null):void {
            _obj1.rotationX += 0.8;
            _obj1.rotationY += 0.5;
            _obj2.rotationY -= 0.5;
            super.onRenderTick(event);
        }
        private function crashUV(mesh:TriangleMesh3D):void {
            //メッシュのUV値を大きくしすぎるとマテリアルの表示がおかしくなる
            for each(var face:Triangle3D in mesh.geometry.faces) {
                for each(var uv:NumberUV in face.uv) {
                    uv.v = Number.MAX_VALUE;
                }
            }
        }
    }
}