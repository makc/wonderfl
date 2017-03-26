package  {
    import flash.display.*;
    import flash.filters.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.system.*;
    import flash.ui.*;
    import net.hires.debug.Stats;
    
    [SWF(width=465,height=465,backgroundColor=0x666666,frameRate=60)]
    public class expokision extends Sprite {
        private var loader:Loader;
        private var surface:MovieClip = new MovieClip();
        private var blender:MovieClip = new MovieClip();
        
        private var expoDots:Array = new Array();
        private var exposNum:int = 30;
        private var particles:Array = new Array();
        private var particlesNum:int = 0;
        private var expoDist:Number = 0.9;
        private var expoRange:Number = 5;
        private var radius:Number = 1;
        private var D2R:Number = Math.PI/180;
        private var R2D:Number = 180/Math.PI;
        private var damp:Number = 0.97;
        private var uncertainFactor:Number = 0.45;
        private var scaleFactor:Number = 0.45;
        private var randomFactor:Number = 0.6;
        private var angDist:Number = 25;
        private var maxlen:Number = 100;
        private var sv:int = 40;
        private var sh:int = 40;
        
        private var tex:BitmapData;
        private var heightMap:BitmapData;
        private var texture:BitmapData;
        private var smoker:Bitmap;
        private var origin:uint = 0xFFFFFF;
        
        private var target0:uint = 0xFFFFFF;
        private var target1:uint = 0xFFFFDD;
        private var target2:uint = 0xFFFF00;
        private var target3:uint = 0xFF9600;
        private var target4:uint = 0x542400;
        private var target5:uint = 0x261200;
        
        private var d:BitmapData;
        
        private var sampler:Number = 0;
        private var sample:Number = 0;
        private var sampleIndex:Number = 0;
        private var sampleTaken:Boolean = false;
        
        private var viewport:Shape = new Shape();
        private var world:Matrix3D = new Matrix3D();
        private var vertices:Vector.<Number>  = new Vector.<Number>(0, false);
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        private var indices:Vector.<int>      = new Vector.<int>(0, false);
        private var uvtData:Vector.<Number>   = new Vector.<Number>(0, false);
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        
        private var sortedIndices:Vector.<int>;
        private var faces:Array = [];
        private var org_vecs:Vector.<Number> = new Vector.<Number>(0 , false);
        private var vec_vecs:Vector.<Number> = new Vector.<Number>(0 , false);
        
        private var sort_count:int = 0;
        private var rotate:Number = 0;
        
        public function expokision() {
            Wonderfl.capture_delay( 30 );
            loader = new Loader();
            var requestPic:URLRequest = new URLRequest()
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            requestPic.url = "http://assets.wonderfl.net/images/related_images/0/0b/0bf9/0bf9825c56a8027ac80186ed182457c566d5a4c3";
            loader.load(requestPic, new LoaderContext(true));
        }

        public function completeHandler(e:Event):void
        {
            init3D();
        }
        
        public function init3D():void
        {
            var i:int = 0;
            smoker = Bitmap(loader.content);
            surface.addChild(smoker);
            d = new BitmapData(500, 500, true, 0x0)
            heightMap = new BitmapData(500, 500, false);
            texture   = new BitmapData(500, 500, false);
            tex = new BitmapData(500, 500, false, 0xFFFFFFFF);
            
            surface.addChild(blender);
            blender.blendMode = BlendMode.HARDLIGHT;
            reset();
            
            viewport.x = stage.stageWidth / 2;
            viewport.y = stage.stageHeight / 2;
            addChild(viewport);
            projection.fieldOfView = 45;
            createGeometry();
            addChild(new Stats());
            
            stage.addEventListener(Event.ENTER_FRAME, processing);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
        }
        
        private function createGeometry():void {
            var xDiv:uint = sv;
            var yDiv:uint = sh;
            for (var y:uint=0; y<=yDiv; y++) {
                var yr:Number = y / yDiv;
                var cy:Number = Math.cos(yr * Math.PI);
                var sy:Number = Math.sin(yr * Math.PI);
                for (var x:uint=0; x<=xDiv; x++) {
                    var xr:Number = x / xDiv;
                    var cx:Number = Math.cos(xr * Math.PI * 2);
                    var sx:Number = Math.sin(xr * Math.PI * 2);
                    org_vecs.push(cx * sy * radius, cy * radius, sx * sy * radius);
                    vertices.push(cx * sy * radius, cy * radius, sx * sy * radius);
                    vec_vecs.push(0, 0, 0);
                    uvtData.push(xr, yr, 0);
                    if (y < yDiv) {
                        var i1:uint = y       * (xDiv + 1) + x;
                        var i2:uint = y       * (xDiv + 1) + ((x + 1) % (xDiv + 1));
                        var i3:uint = (y + 1) * (xDiv + 1) + x;
                        var i4:uint = (y + 1) * (xDiv + 1) + ((x + 1) % (xDiv + 1));
                        indices.push(i1, i2, i3, i3, i2, i4);

                        faces.push(new Vector3D(), new Vector3D());
                    }
                }
            }
            sortedIndices= new Vector.<int>(indices.length, true);
        }
        
        public function onmouseDown(e:MouseEvent):void
        {
            reset();
            var i:uint = 0;
            var j:uint = 0;
            var evx:Number = 0;
            var evy:Number = 0;
            var evz:Number = 0;
            var evlen:Number = 0;
            var speed:Number = 0;
            var pvx:Number = 0;
            var pvy:Number = 0;
            var pvz:Number = 0;
            var pvlen:Number = 0;
            var eradian:Number = 0;
            var jradian:Number = 0;
            var sinwave:Number = 0;
            var sinwave2:Number = 0;
            var coswave:Number = 0;
            var coswave2:Number = 0;
            var rand:Number = 0;
            var ang:Number = 0;

            var hheight:uint = 0x0;

            sampleTaken = false;
            var rad:Number = 0;
            var rad2:Number = 0;
            
            var x_d:int = 0;
            var y_d:int = 0;
            var x_d_b:int = 0;
            var y_d_b:int = 0;
            
            for(i = 0; i < vertices.length; i+=3)
            {
                y_d = ((i / 3) / (sv+1));
                x_d = ((i / 3) % (sh+1));
                pvx = org_vecs[i];
                pvy = org_vecs[i+1];
                pvz = org_vecs[i+2];
                pvlen = Math.sqrt(pvx * pvx + pvy * pvy + pvz * pvz);
                x_d_b = x_d * heightMap.width / sv;
                if(x_d_b == heightMap.width)
                    x_d_b = 0;
                y_d_b = y_d * heightMap.height / sh;
                if(y_d_b == heightMap.height)
                    y_d_b = 0;
                    
                hheight = heightMap.getPixel(x_d_b, y_d_b) & 0xFF;
                
                if(hheight<0x20)
                    hheight = 0x20;
                
                vec_vecs[i] += pvx/pvlen * expoRange * ( Number(hheight) / 256 );
                vec_vecs[i+1] += pvy/pvlen * expoRange * ( Number(hheight) / 256 );
                vec_vecs[i+2] += pvz/pvlen * expoRange * ( Number(hheight) / 256 );
                if(!sampleTaken)
                {
                    if(Math.abs(vec_vecs[i]) != 0)
                    {
                        sampler = Math.abs(vec_vecs[i]);
                        sample = Math.abs(vec_vecs[i]);
                        sampleTaken = true;
                    }
                }
            }
        }
        
        public function reset():void
        {
            sample = 0;
            sampler = 0;
            for(var i:int = 0; i < vertices.length; i+=3){
                vec_vecs[i] = 0;
                vec_vecs[i+1] = 0;
                vec_vecs[i+2] = 0;
                vertices[i] = 0;
                vertices[i+1] = 0;
                vertices[i+2] = 0;
            }
            heightMap.perlinNoise(120, 120, 20, Math.random() * 1000, true, true, 5, true);
            heightMap.colorTransform(heightMap.rect, new ColorTransform(1.5, 1.5, 1.5, 1, -0x40, -0x40, -0x40));
        }
        
        public function processing(e:Event):void
        {
            update();
            paint();
        }
        
        public function update():void
        {
            var i:int = 0;
            for( i = 0; i < vertices.length; i+=3)
            {
                vec_vecs[i] *= damp;
                vec_vecs[i+1] *= damp;
                vec_vecs[i+2] *= damp;
                
                vertices[i] += vec_vecs[i];
                vertices[i+1] += vec_vecs[i+1];
                vertices[i+2] += vec_vecs[i+2];
            }
            sampler *= damp;
        }
        
        public function paint():void
        {
            var i:int = 0;
            
            var seaHeight:uint = 0x00;
            var paletteR:Array = [];
            var paletteG:Array = [];
            var paletteB:Array = [];
            var r:Number;
            
            for (i=0; i<256; i++) {
                if(sample != 0)
                    r = (i - seaHeight) / (256 - seaHeight) * (1 - sampler/sample);
                
                if (r > 0.8) {
                    
                    paletteR[i] = (0x26 - (0x26 - 0x00) * (r - 0.8) / 0.2) << 16;
                    paletteG[i] = (0x12 - (0x12 - 0x00) * (r - 0.8) / 0.2) << 8;
                    paletteB[i] = (0x00 - (0x00 - 0x00) * (r - 0.8) / 0.2);
                } else if (r > 0.7) {
                    paletteR[i] = (0x54 - (0x54 - 0x26) * (r - 0.7) / 0.1) << 16;
                    paletteG[i] = (0x32 - (0x32 - 0x12) * (r - 0.7) / 0.1) << 8;
                    paletteB[i] = (0x00 - (0x00 - 0x00) * (r - 0.7) / 0.1);
                } else if (r > 0.6) {
                    paletteR[i] = (0xFF - (0xFF - 0x54) * (r - 0.6) / 0.1) << 16;
                    paletteG[i] = (0x96 - (0x96 - 0x32) * (r - 0.6) / 0.1) << 8;
                    paletteB[i] = (0x00 - (0x00 - 0x00) * (r - 0.6) / 0.1);
                } else if (r > 0.45) {
                    paletteR[i] = (0xFF - (0xFF - 0xFF) * (r - 0.45) / 0.15) << 16;
                    paletteG[i] = (0xFF - (0xFF - 0x96) * (r - 0.45) / 0.15) << 8;
                    paletteB[i] = (0x00 - (0x00 - 0x00) * (r - 0.45) / 0.15);
                } else if (r > 0.35) {
                    paletteR[i] = (0xFF - (0xFF - 0xFF) * (r - 0.35) / 0.10) << 16;
                    paletteG[i] = (0xFF - (0xFF - 0xFF) * (r - 0.35) / 0.10) << 8;
                    paletteB[i] = (0xDD - (0xDD - 0x00) * (r - 0.35) / 0.10);
                } else {
                    paletteR[i] = (0xFF - (0xFF - 0xFF) * r / 0.35) << 16;
                    paletteG[i] = (0xFF - (0xFF - 0xFF) * r / 0.35) << 8;
                    paletteB[i] = (0xFF - (0xFF - 0xDD) * r / 0.35);
                }
            }
            
            texture.paletteMap(heightMap, texture.rect, texture.rect.topLeft, paletteR, paletteG, paletteB);
            
            d.lock();
            d.draw(texture);
            d.unlock();
            
            blender.graphics.clear();
            blender.graphics.beginBitmapFill(d);
            blender.graphics.drawRect(0, 0, 500, 500);
            blender.graphics.endFill();
            
            tex.lock();
            tex.draw(surface);
            tex.unlock();
                
            world.identity();
            world.appendRotation(getTimer() * -0.03, Vector3D.Y_AXIS);
            world.appendTranslation(0, 0, 700);
            world.append(projection.toMatrix3D());
            Utils3D.projectVectors(world, vertices, projected, uvtData);
            
            rotate = getTimer() * -0.03;
            
            if((rotate-60)/-60>sort_count) //only sort per 60 degree
            {
                resort();
                sort_count++;
            }
            viewport.graphics.clear();
            viewport.graphics.beginBitmapFill(tex, null, false, false);
            viewport.graphics.drawTriangles(projected, sortedIndices, uvtData, TriangleCulling.POSITIVE);
            viewport.graphics.endFill();
        }
        
        private function resort():void
        {
            var i:int = 0;
            var face:Vector3D;
            var inc:int = 0;
            var i1:uint = 0x0;
            var i2:uint = 0x0;
            var i3:uint = 0x0;
            for (i = 0; i<indices.length; i+=3){
                i1 = indices[ i+0 ];
                i2 = indices[ i+1 ];
                i3 = indices[ i+2 ];
                face = faces[inc];
                face.x = i1;
                face.y = i2;
                face.z = i3;
                face.w = Math.min(uvtData[i1 * 3 + 2], uvtData[i2 * 3 + 2], uvtData[i3 * 3 + 2]);
                inc++;
            }
            faces.sortOn("w", Array.NUMERIC);
            inc = 0;
            for each (face in faces){
                sortedIndices[inc++] = face.x;
                sortedIndices[inc++] = face.y;
                sortedIndices[inc++] = face.z;
            }
        }
    }
}