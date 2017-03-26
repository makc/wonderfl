// forked from zonnbe's there is no spoon
package 
{
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.materials.shadematerials.EnvMapMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.parsers.Collada;
    import org.papervision3d.events.FileLoadEvent;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.view.Viewport3D;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.system.LoaderContext;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.geom.Point;
    import com.bit101.components.PushButton;
    import flash.media.Camera;
    import flash.media.Video;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="0x000000")] 
    public class thereisnospoon  extends Sprite
    {
        public static var GRAPHIC_URL:String ="http://zonnbeapp.appspot.com/neo.jpg";
        public static var MONK_GRAPHIC_URL:String ="http://zonnbeapp.appspot.com/kmonk.jpg";
        public static var COLLADA_URL:String ="http://zonnbeapp.appspot.com/spoon.dae"
        private var viewport:Viewport3D;
        private var scene:Scene3D;
        private var camera:Camera3D = new Camera3D();
        private var renderer:BasicRenderEngine;
        private var loader:Loader;
        private var monk_loader:Loader = new Loader();
        private var c:Collada;
        private var vert:Array = new Array();
        private var org_vert:Array = new Array();
        private var guider:MovieClip = new MovieClip();
        
        private var drag:Boolean = false;
        private var daeLoaded:Boolean = false;
        
        private var maxX:Number = 0;
        private var minX:Number = 0;
        private var maxY:Number = 0;
        private var minY:Number = 0;
        private var curvePadding:Point = new Point();
        private var daeMaxDistX:Number = 0;
        private var daeMaxDistY:Number = 0;
        private var curveZoomX:Number = 0;
        private var curveZoomY:Number = 0;
        private var monk_bmpd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
        private var bend_x:Boolean = true;
        private var rotate:int = 0;
        private var ba:Point = new Point();
        private var bb:Point = new Point();
        private var bc:Point = new Point();
        private var bd:Point = new Point();
        
        public function thereisnospoon ()
        {
            if (stage) doLoad();
            else addEventListener(Event.ADDED_TO_STAGE, doLoad);
        }
        
        private function doLoad(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            loader = new Loader();
            var requestPic:URLRequest = new URLRequest()
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            requestPic.url = GRAPHIC_URL;
            loader.load(requestPic, new LoaderContext(true));
            requestPic.url = MONK_GRAPHIC_URL;
            monk_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, drawMonk);
            monk_loader.load(requestPic, new LoaderContext(true));
        }
        
        private function drawMonk(e:Event):void
        {
            var bmpd:BitmapData = Bitmap(monk_loader.content).bitmapData;
            monk_bmpd.copyPixels(bmpd, bmpd.rect, new Point());
        }
        
        private function init(e:Event):void 
        {
           
            addChild(new Bitmap(monk_bmpd));
            viewport=new Viewport3D(0,0,true,true);
            addChild( viewport );
            renderer = new BasicRenderEngine();
            scene = new Scene3D();            

            ba.x = stage.stageWidth/2;
            ba.y = stage.stageHeight;
            
            bb.x = stage.stageWidth/2;
            bb.y = stage.stageHeight*2/4;
            
            bc.x = stage.stageWidth/2;
            bc.y = stage.stageHeight*1/4;
            
            bd.x = stage.stageWidth/2;
            bd.y = -30;
            
             getCam()
            var _castbitmap:Bitmap = new Bitmap(reflexBMP);
           // addChild(_castbitmap)
            var light:PointLight3D = new PointLight3D(false, true);
            var envMapMaterial:EnvMapMaterial = new EnvMapMaterial(light, reflexBMP, reflexBMP, 0);
            var materialsList:MaterialsList = new MaterialsList(); 
            materialsList.addMaterial( envMapMaterial, "Mat"); 
            c = new Collada(COLLADA_URL, materialsList, 0.05);
            c.addEventListener(FileLoadEvent.LOAD_COMPLETE, daeLoadComplete);
            c.y = -120;
            scene.addChild(c);
            addChild(guider);
            new PushButton(guider, 5, 5, "Change Bend Direction", onCBD).setSize(120, 16);
            new PushButton(guider, 130, 5, "Change Rotate Mode", onCRM).setSize(120, 16);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onmouseUp);
            stage.addEventListener(Event.ENTER_FRAME, processing);
        }
        
        private function onCBD(...arg):void
        {
            bend_x = !bend_x;
            var i:int = 0;
            for(i = 0; i < org_vert.length; i++)
            {
                vert[i].x = org_vert[i].x;
                vert[i].y = org_vert[i].y;
                vert[i].z = org_vert[i].z;
            }
        }
        
        private function onCRM(...arg):void
        {
            rotate++;
            if(rotate==3) 
            {
                c.rotationX = 0;
                c.rotationY = 0;
                c.rotationZ = 0;
                rotate = 0;
            }
            
        }
        
        private function onmouseDown(e:MouseEvent):void
        {
            drag = true;
        }
        
        private function onmouseUp(e:MouseEvent):void
        {
            drag = false;
        }
        
        private function processing(e:Event):void
        {
            update();
            paint();
        }
        
        private function update():void
        {
            if(drag)
            {
                bd.x = mouseX;
                bd.y = mouseY;
            }
            
            c.yaw(1);
            switch(rotate)
            {
                case 1:
                    c.roll(1);
                    break;
                case 2:
                    c.pitch(1);
                    break;
            }
            with(guider.graphics)
            {
                clear();
                if(drag)
                {
                    lineStyle(0.1, 0xFFFFFFFF);
                    moveTo(stage.stageWidth/2, 0);
                    lineTo(stage.stageWidth/2, stage.stageHeight);
                    moveTo(0, stage.stageHeight/2);
                    lineTo(stage.stageWidth, stage.stageHeight/2);
                    drawCubicBezier(guider);
                }
            }
            
            if(daeLoaded)
            {
                var i:int = 0;
                var p_at_t:Point;
                var pp_at_t:Point;
                var np_at_t:Point;
                var cpv:Point;
                var fake_o_y:Number = 0;
                var fake_y:Number = 0;
                var search_t:Number = 0;
                
                for(i = 0; i < org_vert.length; i++)
                {
                    fake_o_y = org_vert[i].y + Math.abs(minY);
                    if(org_vert[i].y == maxY)
                        fake_y = fake_o_y - 1;
                    else if(org_vert[i].y == minY)
                        fake_y = fake_o_y + 1;
                    else
                        fake_y = fake_o_y;
                    search_t = (fake_y)/daeMaxDistY;
                    p_at_t = getValue(search_t);
                    search_t -= 0.01;
                    if(search_t < 0) search_t = 0;
                    pp_at_t = getValue(search_t);
                    search_t = (fake_y)/daeMaxDistY;
                    search_t += 0.01;
                    if(search_t > 1) search_t = 1;
                    np_at_t = getValue(search_t);
                    
                    
                    cpv = vertexNormal(pp_at_t, p_at_t, np_at_t);
                    
                    cpv.y = -cpv.y;
                    
                    if(bend_x)
                    {
                        vert[i].x = (p_at_t.x - curvePadding.x) * curveZoomY + cpv.x * org_vert[i].x;
                        vert[i].y = -(p_at_t.y - curvePadding.y) * curveZoomY + cpv.y * org_vert[i].x;
                    } else {
                        vert[i].z = (p_at_t.x - curvePadding.x) * curveZoomY + cpv.x * org_vert[i].z;
                        vert[i].y = -(p_at_t.y - curvePadding.y) * curveZoomY + cpv.y * org_vert[i].z;
                    }
                }
            }
        }
        
        private function paint():void
        {
            
            renderer.renderScene(scene, camera, viewport);
        }
        
        private function daeLoadComplete(e:FileLoadEvent=null):void
        {
            if(c.getChildByName("Spring01")) // COLLADA skips COLLADA_Scene
            {
                var clen:int = c.getChildByName("Spring01").geometry.vertices.length;
                var i:int = 0;
                for(i = 0; i < clen; i++)
                {
                    vert.push(c.getChildByName("Spring01").geometry.vertices[i]);
                    org_vert.push(new Vertex3D(vert[i].x, vert[i].y, vert[i].z));
                }
                vert.sortOn("x", Array.NUMERIC);
                maxX = vert[vert.length-1].x;
                minX = vert[0].x;
                daeMaxDistX = maxX - minX;
                vert.sortOn("y", Array.NUMERIC);
                org_vert.sortOn("y", Array.NUMERIC);
                maxY = vert[vert.length-1].y;
                minY = vert[0].y;
                daeMaxDistY = maxY - minY;
                curvePadding.x = stage.stageWidth/2;
                curvePadding.y = (stage.stageHeight - ( -minY * stage.stageHeight / daeMaxDistY ));
                curveZoomX = daeMaxDistX/stage.stageWidth;
                curveZoomY = daeMaxDistY/stage.stageHeight;
                daeLoaded = true;
            }
        }
        
        private function drawCubicBezier(m:MovieClip):void
        {
            var P0:Point = ba;
            var P1:Point = bb;
            var P2:Point = bc;
            var P3:Point = bd;

            var PA:Point = getPointOnSegment(P0, P1, 3/4);
            var PB:Point = getPointOnSegment(P3, P2, 3/4);

            var dx:Number = (P3.x - P0.x)/16;
            var dy:Number = (P3.y - P0.y)/16;

            var Pc_1:Point = getPointOnSegment(P0, P1, 3/8);
            var Pc_2:Point = getPointOnSegment(PA, PB, 3/8);
            Pc_2.x -= dx;
            Pc_2.y -= dy;

            var Pc_3:Point = getPointOnSegment(PB, PA, 3/8);
            Pc_3.x += dx;
            Pc_3.y += dy;
            var Pc_4:Point = getPointOnSegment(P3, P2, 3/8);

            var Pa_1:Point = getMiddle(Pc_1, Pc_2);
            var Pa_2:Point = getMiddle(PA, PB);
            var Pa_3:Point = getMiddle(Pc_3, Pc_4);
            
            with(m.graphics)
            {
                moveTo(P0.x, P0.y);
                curveTo(Pc_1.x, Pc_1.y, Pa_1.x, Pa_1.y);
                curveTo(Pc_2.x, Pc_2.y, Pa_2.x, Pa_2.y);
                curveTo(Pc_3.x, Pc_3.y, Pa_3.x, Pa_3.y);
                curveTo(Pc_4.x, Pc_4.y, P3.x, P3.y);
            }
        }
        
        private function getMiddle(p1:Point, p2:Point):Point
        {
            return new Point((p1.x + p2.x)/2, (p1.y + p2.y)/2);
        }
    
        private function getPointOnSegment(p1:Point, p2:Point, tT:Number):Point 
        {
            return new Point(p1.x + tT*(p2.x - p1.x), p1.y + tT*(p2.y - p1.y));
        }
        
        private function getValue(tT:Number):Point {
            var p00:Point = new Point(ba.x, ba.y);
            var p01:Point = new Point(bb.x, bb.y);
            var p02:Point = new Point(bc.x, bc.y);
            var p03:Point = new Point(bd.x, bd.y);
    
            var p10:Point = getPointOnSegment(p00, p01, tT);
            var p11:Point = getPointOnSegment(p01, p02, tT);
            var p12:Point = getPointOnSegment(p02, p03, tT);
    
            var p20:Point = getPointOnSegment(p10, p11, tT);
            var p21:Point = getPointOnSegment(p11, p12, tT);
    
            return getPointOnSegment(p20, p21, tT);
        }
        
        private function vertexNormal(np:Point, n:Point, nn:Point):Point
        {
            var dpx:Number=np.x-n.x;
            var dpy:Number=np.y-n.y;
            var dnx:Number=nn.x-n.x;
            var dny:Number=nn.y-n.y;

            var nx:Number=-dny;
            var ny:Number=dnx;
            var na:Number=Math.sqrt(nx*nx+ny*ny);
            if (na==0)
            {
                nx=1;
                ny=0;
            } else {
                nx/=na;
                ny/=na;
            }

            var px:Number=dpy;
            var py:Number=-dpx;
            var pa:Number=Math.sqrt(px*px+py*py);
            if (pa==0)
            {
                px=1;
                py=0;
            } else {
                px/=pa;
                py/=pa;
            }

            var fx:Number=nx+px;
            var fy:Number=ny+py;
            var fa:Number=Math.sqrt(fx*fx+fy*fy);
            if (fa==0)
            {
                fx=1;
                fy=0;
            } else {
                fx/=fa;
                fy/=fa;
            }

            return new Point(fx,fy);
        }
        private var cam_width:Number = 320;
        private var cam_height:Number = 240;
        private var reflexBMP:BitmapData;
        private var video:Video
        private function getCam():void{
            var camera:Camera = Camera.getCamera();
            camera.setMode(cam_width,cam_height,20, true);
            video = new Video();
            video.attachCamera(camera);
           //addChild(video);
            reflexBMP = new BitmapData(cam_width, cam_height, false);
            this.addEventListener(Event.ENTER_FRAME, refreshCam);
        }
        private function refreshCam(e:Event):void{
            reflexBMP.draw(video);
        }
    }
}//zonnbe@Wonderfl:2010