/**
 * Impossible Is Possible
 * interaction: mouse drag
 * @see http://www.crookedbrains.net/2007/03/top-5-impossible-structures-well-here.html
 * @author Yukiya Okuda<http://alumican.net/>
 */
package {
    import flash.events.Event;
    import flash.events.MouseEvent;
    import org.papervision3d.core.math.Quaternion;
    import org.papervision3d.core.proto.MaterialObject3D;
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Cube;
    import org.papervision3d.render.QuadrantRenderEngine;
    import org.papervision3d.view.BasicView;
    
    public class Main extends BasicView {
        public var light:PointLight3D;
        
        public function Main():void {
            var tx:Number, ty:Number,
                cx:Number = 0, cy:Number = 0,
                sx:Number, sy:Number,
                isMouseDown:Boolean = false,
                q:Quaternion = new Quaternion(),
                container:DisplayObject3D = scene.addChild(new DisplayObject3D());
            
            Wonderfl.disable_capture();
            stage.frameRate = 60;
            opaqueBackground = 0x0;
            
            //create 3d world
            camera.ortho = true;
            camera.orthoScale = 0.15;
            camera.x = 0;
            camera.y = 0;
            camera.z = -2000;
            light = new PointLight3D();
            light.x = 100;
            light.y = 500;
            light.z = -1000;
            renderer = new QuadrantRenderEngine(1);
            container.addChild(getCubeStructure());
            startRendering();
            
            //mouse interaction
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
                isMouseDown = true;
                sx = mouseX;
                sy = mouseY;
            });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
                isMouseDown = false;
            });
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                if (isMouseDown) {
                    tx = (sx - mouseX) / 465 * 180;
                    ty = (sy - mouseY) / 465 * 180;
                } else {
                    tx = ty = 0;
                }
                cx += (tx - cx) * 0.1;
                cy += (ty - cy) * 0.1;
                q.setFromEuler(cx, 0, cy, true);
                container.transform = q.matrix;
            });
        }
        
        public function getCubeStructure():DisplayObject3D {
            var w:Number = 100,
            h:Number = 1000,
            space:Number = 0,
            r:Number = 45,
            l:Number = 0.3,
            h2:Number = h - w - space * 2,
            o:DisplayObject3D = new DisplayObject3D(),
            ox:Number, oy:Number, oz:Number,
            c:DisplayObject3D;
            
            ox = -h * 0.5;
            oy = 0;
            oz = -h * 0.5;
            o.addChild(    getCube(ox + 0, oy + 0, oz + 0, 0, 0, 0, w, h));
            o.addChild(    getCube(ox + h, oy + 0, oz + 0, 0, 0, 0, w, h));
            o.addChild(c = getCube(ox + h, oy + 0, oz + h, 0, 0, 0, w, h));
            o.addChild(    getCube(ox + 0, oy + 0, oz + h, 0, 0, 0, w, h));
            c.replaceMaterialByName(getMaterial(0xd3d3d3), "top");
            
            ox = -h * 0.5;
            oy = -h * 0.5 - w * 0.5;
            oz = 0;
            o.addChild(getCube(ox + 0, oy + w, oz, 90, 0, 0, w, h2));
            o.addChild(getCube(ox + h, oy + w, oz, 90, 0, 0, w, h2));
        //    o.addChild(getCube(ox + h, oy + h, oz, 90, 0, 0, w, h2));
            o.addChild(getCube(ox + 0, oy + h, oz, 90, 0, 0, w, h2));
            
            ox = 0;
            oy = -h * 0.5 - w * 0.5;
            oz = -h * 0.5;
            o.addChild(getCube(ox, oy + w, oz + 0, 0, 0, -90, w, h2));
            o.addChild(getCube(ox, oy + h, oz + 0, 0, 0, -90, w, h2));
            o.addChild(getCube(ox, oy + h, oz + h, 0, 0, -90, w, h2));
            o.addChild(getCube(ox, oy + w, oz + h, 0, 0, -90, w, h2));
            
            ox = -h * 0.5;
            oy = -h * 0.5 - w * 0.5;
            oz = (l - 1) * h2 * 0.5;
            o.addChild(getCube(ox + h, oy + h, oz, 90, 0, 0, w, h2 * l, Cube.TOP));
            
            var x:Number = -(h + space) * Math.cos(r * Math.PI / 180);
            var y:Number = -(h + space);
            var z:Number = -(h + space) * Math.sin(r * Math.PI / 180);
            ox = -h * 0.5;
            oy = -h * 0.5 - w * 0.5;
            oz = l * h2 * 0.5;
            o.addChild(c = getCube(ox + h + x, oy + h + y, oz + z, 90, 0, 0, w, h2 * (1 - l), 0));
            c.replaceMaterialByName(getMaterial(0xdddddd), "back");
            c.replaceMaterialByName(getMaterial(0x666666), "right");
            
            var o2:DisplayObject3D = new DisplayObject3D();
            o2.addChild(o);
            var o3:DisplayObject3D = new DisplayObject3D();
            o3.addChild(o2);
            o.rotationY  = r;
            o2.rotationZ = -r;
            o3.rotationY = r * 2;
            return o3;
        }
        
        public function getCube(x:Number, y:Number, z:Number, rx:Number, ry:Number, rz:Number, w:Number, h:Number, excludeFaces:int = 0, color:int = 0xffffff):DisplayObject3D {
            var o:Cube = new Cube(new MaterialsList({top:getMaterial(color), bottom:getMaterial(color), front:getMaterial(color), back:getMaterial(color), left:getMaterial(color), right:getMaterial(color)}), w, w, h, 1, 1, 1, 0, excludeFaces);
            o.x = x; o.y = y; o.z = z;
            o.rotationX = rx; o.rotationY = ry; o.rotationZ = rz;
            return o;
        }
        
        public function getMaterial(color1:int, color2:int = 0x666666):MaterialObject3D {
            return new FlatShadeMaterial(light, color1, color2);
        }
    }
}