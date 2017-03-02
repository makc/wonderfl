//Sadly the Kuler Api is currently down as its being updated.
//Using ColorUtils from dreaminginflash, eventually will give users option to choose both shader colors.


package 
{
    import com.bit101.components.ColorChooser;
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import com.greensock.TweenLite;
    import com.greensock.easing.Sine;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.net.FileReference;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import flash.utils.Timer;

    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.geom.renderables.Triangle3D;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.core.math.Number3D;
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Sphere;
    import org.papervision3d.view.BasicView;
    

    [SWF(frameRate="30",width="500",height="500")]
    
    public class Main extends BasicView 
    {
        
        private var light:PointLight3D;
        private var mat:FlatShadeMaterial;
        private var mesh:DisplayObject3D;
        private var mesh2:DisplayObject3D;
        private var n3dArr:Array = [];
        private var n3dArr2:Array = [];
        private var timer:Timer;
        private var tfholder:MovieClip;
        private var isplaying:Boolean = false;
        private var fr:FileReference;
        private var sc:SoundChannel;
        private var cc:ColorChooser;
        
        public function Main() 
        {
            initMesh();            
            initData();
            startRendering();
            addEventListener(Event.ENTER_FRAME, loop);

            var songchooser:PushButton = new PushButton(this,5,5,"Load your own track",onloadsong);
            
            var info:Label = new Label(this,5,35,"Choose your Color");
            info.draw();
            
            cc = new ColorChooser(this,5,50,0xCCCCCC,oncolorselect);
            cc.draw();
            
            cc.usePopup = true;
            cc.popupAlign = "bottom";
        }

        private function oncolorselect(e:Event):void
        {
            var n:Number = cc.value;
            var rgb:Number = n;
            var hls:Object = ColorUtils.RGBtoHLS(rgb);
            var darkL:Number  = Math.max(hls.l - 0.2,0);
            var lightL:Number  = Math.min(hls.l + 0.2,1);
            var dark:Number = ColorUtils.HLStoRGB(hls.h,darkL,hls.s);
            var lightn:Number = ColorUtils.HLStoRGB(hls.h,lightL,hls.s);
            
            mat = new FlatShadeMaterial(light,rgb,dark,1);
            mesh.material = mat;
            mesh2.material = mat;
        }
        
        private function initMesh():void 
        {
            light = new PointLight3D();
            light.y = -8000;
            light.x = -8000;
            light.z = -8000;
            mat = new FlatShadeMaterial(light, 0xffff99, 0xff9900);
            
            mesh = new Sphere(mat, 300, 17, 17);
            scene.addChild(mesh);
            mesh.x = -320;
            mesh.rotationX = 120;
            
            mesh2 = new Sphere(mat, 300, 20, 20);
            scene.addChild(mesh2);
            mesh2.x = 320;
            mesh2.rotationX = -240;
        }
        
        private function initData():void 
        {
            for each( var vertice:Vertex3D in mesh.geometry.vertices) 
            {
                n3dArr.push(vertice.toNumber3D());
            }
            
            for each( var vertice2:Vertex3D in mesh2.geometry.vertices) 
            {
                n3dArr2.push(vertice2.toNumber3D());
            }
        }
        
        private function loop(e:Event):void 
        {
            //mesh.rotationY++
            mesh.yaw(-1);
            mesh2.yaw(1);

            for each(var vertice:Vertex3D in mesh.geometry.vertices) 
            {
                vertice.calculateNormal();
            }
            for each(var face:Triangle3D in mesh.geometry.faces) 
            {
                face.createNormal();
            }
            for each(var verticemesh2:Vertex3D in mesh2.geometry.vertices) 
            {
                verticemesh2.calculateNormal();
            }
            for each(var face2:Triangle3D in mesh2.geometry.faces) 
            {
                face2.createNormal();
            }
            
            if(isplaying == true)
            {
                var _byte:ByteArray = new ByteArray();
                SoundMixer.computeSpectrum(_byte);
                for (var i:int = 0; i < 256; i++)
                {
                    var data:Number = Math.abs(_byte.readFloat()) * 3;
                    var vertice2:Vertex3D = mesh.geometry.vertices[i] as Vertex3D;
                    var vertice3:Vertex3D = mesh2.geometry.vertices[i] as Vertex3D;
                    var n3d:Number3D = n3dArr[i] as Number3D;
                    var tx:Number = (.5 + Math.random() * 1.5) * n3d.x;
                    var ty:Number = (.5 + Math.random() * 1.5) * n3d.y;
                    var tz:Number = (.5 + Math.random() * 1.5) * n3d.z;
                    TweenLite.to(vertice2, .8, { y:ty * data, ease:Sine.easeOut} );
                    
                    //TweenLite.to(mesh, .5, { rotationX:rx, rotationY:ry, rotationZ:rz, ease:Sine.easeOut} );
                    TweenLite.to(vertice3, .8, {  y:ty * data, ease:Sine.easeOut} );
                }
            }
        }
        
        private function onloadsong(e:MouseEvent):void
        {
            if(isplaying == true)
            {
                sc.stop();
            }
            isplaying = false;
            
            fr = new FileReference();
            fr.addEventListener(Event.SELECT,onselected);
            fr.addEventListener(Event.COMPLETE,onfileload);
            fr.browse();
        }
        
        private function onselected(e:Event):void
        {
            fr.load();
        }
        
        private function onfileload(e:Event):void
        {
            trace("loaded");
            var s:Sound = new Sound();
            s.loadCompressedDataFromByteArray(fr.data,fr.data.length);
            sc = new SoundChannel();
            if(isplaying == false)
            {
                sc = s.play(0, 10, new SoundTransform(0.7, 0));
                isplaying = true;
            }

        }    
        
    }
    
}
    
     class ColorUtils {

        public static function HuetoRGB(m1:Number,m2:Number,h:Number):Number {
            if ( h < 0 ) {
                h += 1.0;
            }
            if ( h > 1 ) {
                h -= 1.0;
            }
            if ( 6.0*h < 1 ) {
                return (m1 + (m2 - m1) * h * 6.0);
            }
            if ( 2.0*h < 1 ) {
                return m2;
            }
            if ( 3.0*h < 2.0 ) {
                return (m1 + (m2 - m1) * ((2.0 / 3.0) - h) * 6.0);
            }
            return m1;
        }
        /**
         * Converte an HLS color to RGB color
         * 
         * @example <listing version="3.0">
         * 
         * ColorUtils.HLStoRGB(34,3,23);
         * 
         * </listing>
         * 
         * @param h Hue value 
         * @param l Luminance value
         * @param s Saturation value
         *
         * @return an integer that represents an RGB color.
         */ 
        public static function HLStoRGB(H:Number,L:Number,S:Number):Number 
        {
            var r:Number;
            var g:Number;
            var b:Number;
            var m1:Number;
            var m2:Number;
        
            if (S==0) {
                r=g=b=L;
            } else {
                if (L <=0.5) {
                    m2 = L*(1.0+S);
                } else {
                    m2 = L+S-L*S;
                }
                m1 = 2.0*L-m2;
                r = HuetoRGB(m1,m2,H+1.0/3.0);
                g = HuetoRGB(m1,m2,H);
                b = HuetoRGB(m1,m2,H-1.0/3.0);
            }
            r = int(r*255);
            g = int(g*255);
            b = int(b*255);
            return r << 16 | g << 8 | b;
        }

        /**
        * Converte an RGB color to HLS color
        * 
        * @example <listing version="3.0">
         * 
         * ColorUtils.RGBtoHLS(65280);
         * 
         * </listing>
        * 
        * @param rgb24 an integer that represents an RGB color.
        *
        * @return an object with h,l,s properties
        */ 
        public static function RGBtoHLS(rgb24:Number):Object 
        {
            var h:Number;
            var l:Number;
            var s:Number;
            var r:Number = (rgb24 >> 16)/255;
            var g:Number = (rgb24 >> 8 & 0xFF)/255;
            var b:Number = (rgb24 & 0xFF)/255;
            var delta:Number;
            var cmax:Number = Math.max(r,Math.max(g,b));
            var cmin:Number = Math.min(r,Math.min(g,b));
            l=(cmax+cmin)/2.0;
            if (cmax==cmin) {
                s = 0;
                h = 0;
            } else {
                if (l < 0.5) {
                    s = (cmax-cmin)/(cmax+cmin);
                } else {
                    s = (cmax-cmin)/(2.0-cmax-cmin);
                }
                delta = cmax - cmin;
                if (r==cmax) {
                    h = (g-b)/delta;
                } else if (g==cmax) {
                    h = 2.0 +(b-r)/delta;
                } else {
                    h =4.0+(r-g)/delta;
                }
                h /= 6.0;
                if (h < 0.0) {
                    h += 1;
                }
            }
            return {h:h,l:l,s:s};
        }



    }