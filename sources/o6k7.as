package
{
    import flash.display.*;
    import flash.filters.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.system.*;
    import flash.ui.*;
    import flash.media.*;
    import net.hires.debug.Stats;
    import frocessing.color.ColorHSV;
    import com.bit101.components.PushButton;
    import com.bit101.components.InputText;
    
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=30)]
    public class therockcityMAX extends Sprite
    {
        private var SECTOR:int = 10;
        private var LEVEL:int = 3;
        private var LEVEL_HEIGHT:int = 20;
        private var RADIUSX:int = 30;
        private var RADIUSZ:int = 15;

        private var edgeA:Array = new Array();
        private var edgeB:Array = new Array();
        
        private var D2R:Number = Math.PI/180;
        private var R2D:Number = 180/Math.PI;
        
        private var cPos:Dot = new Dot(0, 0);
        
        private var points:Array = new Array();
        
        //planning
        private var regions:Array = new Array();
        private var gCount:int = 300;
        private var gwidth:int = 1000;//stage.stageWidth;
        private var gheight:int = 1000;//stage.stageHeight;
        
        //building
        
        private var blength:Number = 100;
        private var bwidth:Number = 200;
        private var bheight:Number = 200;
        
        private var offset:Dot = new Dot(-gwidth/2, -gheight/2);

        
        private var autoAlign:Boolean = false;
        
//////////////////////////////////////////////////////////////////////////////////////////////////
// drawTriangles
//////////////////////////////////////////////////////////////////////////////////////////////////
        
        private var viewport:Shape = new Shape();
        private var world:Matrix3D = new Matrix3D();
        private var vertices:Vector.<Number>  = new Vector.<Number>(0, false);
        private var projected:Vector.<Number> = new Vector.<Number>(0, false);
        private var indices:Vector.<int>      = new Vector.<int>(0, false);
        private var uvtData:Vector.<Number>   = new Vector.<Number>(0, false);
        private var projection:PerspectiveProjection = new PerspectiveProjection();
        
        private var sortedIndices:Vector.<int>;
        private var faces:Array = [];
        /**/
        
        
/////////////////////////////////////////////////////////////////////////////////////////////////
        private var sort_count:int = 0;
        private var rotate:Number = 0;
        private var refrest_sort_at:int = 100;
/////////////////////////////////////////////////////////////////////////////////////////////////

        private var snd:Sound;
        private var bytes:ByteArray = new ByteArray();
        private var bitmapData:BitmapData = new BitmapData(500,500, false, 0xFFFFFFFF);

        private var colors:Array = [0xFFCC32,0x333333,0x333333];
        private var alphas:Array = [1,0,0];
        private var ratios:Array = [0,64,255];
        private var m:Matrix = new Matrix();
        private var light:Sprite = new Sprite();
        private var lightRatio:Number = 48;
        

        private var ct:ColorTransform =  new ColorTransform(1,1,1,0.8);
        
        private var transparent:Boolean = false;
        
////////////////////////////////////////////////////////////////////////////////////////////////
        private var landVertices:Vector.<Number> = new Vector.<Number>(0, false);
        private var landProjected:Vector.<Number> = new Vector.<Number>(0, false);
        private var landIndices:Vector.<int> = new Vector.<int>(0, false);
        private var landUvtData:Vector.<Number> = new Vector.<Number>(0, false);
        
        
////////////////////////////////////////////////////////////////////////////////////////////////
        private var traffic:Array = new Array();
        private var landResizing:Number = 0.3;
        
        private var land_bmpd:BitmapData = new BitmapData(gwidth*landResizing, gheight*landResizing,false,0x0);
        
        private var top_down_view:Boolean = false;
        private var white_buildings:Boolean = false;
        
///////////////////////////////////////////////////////////////////
        private var windowX:int = 32;
        private var windowY:int = 16;
        
        private var trafficTimer:Timer;
        private var timerSpeed:int = 3;
        private var timerCount:int = 0;
        
        private var trafficSpeedLabel:TextField = new TextField();
        private var buildingsTxt:String = "";
        private var tf:TextFormat = new TextFormat();
        
        private var vcolor:ColorHSV = new ColorHSV(0);
        private var varyColor:int = 0;
        private var staticColor:uint = 0xFFFFCC32;

// dynamic link to url
/////////////////////////////////////////////////////////////////////
        private var url:String = "http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3";
        private var inputText:InputText;
        private var playButton:PushButton;
        private var soundChannel:SoundChannel = new SoundChannel();
        
        [SWF(width=465,height=465,backgroundColor=0x000011,frameRate=60)]
        public function therockcityMAX()
        {
            addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000011)));
            addChild(new Stats());
            addChild(light);
            trafficSpeedLabel.text = "traffic speed: 1";
            
            tf.size = 10;
            tf.font = "Arial"
            trafficSpeedLabel.textColor = 0xFFFFFF;
            trafficSpeedLabel.setTextFormat(tf);
            trafficSpeedLabel.autoSize = "left";
            addChild(trafficSpeedLabel);
            trafficSpeedLabel.x = stage.stageWidth - trafficSpeedLabel.width -5;
            var mc:MovieClip = new MovieClip();
            with(mc.graphics)
            {
                beginFill(0x0);
                drawRect(0,0, stage.stageWidth, 130);
                endFill();
            }
            mc.y = stage.stageHeight - mc.height;

            m.translate(stage.stageWidth/2, stage.stageHeight-130);

            regions.push(new Region);
            
            regions[0].vertices.push(new Dot(0 ,0));
            regions[0].vertices.push(new Dot(gwidth, 0));
            regions[0].vertices.push(new Dot(gwidth, gheight));
            regions[0].vertices.push(new Dot(0, gheight));
            
            init3D();
            
        }
        
        private function init3D(e:Event = null):void
        {

            viewport.x = stage.stageWidth / 2;
            viewport.y = stage.stageHeight / 2;
            addChild(viewport);
            projection.fieldOfView = 45;
            
            //add input mp3 url
            var panel:Sprite = new Sprite();
            inputText = new InputText(panel, stage.stageWidth - 250, 20, "http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3");
            playButton = new PushButton(panel, stage.stageWidth - 45, 20, "play", onClickPlay);
            inputText.setSize(200,20);
            playButton.setSize(40,20);
            addChild(panel);
            
            //planning
            generateCity();
            constructLand();

            snd = new Sound();
            snd.load(new URLRequest("http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3"), new SoundLoaderContext(10,true));
            soundChannel = snd.play(0, 9999);
            
            trafficTimer = new Timer(10);
            trafficTimer.addEventListener(TimerEvent.TIMER, updateTraffic);
            trafficTimer.start();
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
            stage.addEventListener(Event.ENTER_FRAME, processing);
        }
        
        private function onClickPlay(...arg):void
        {
            soundChannel.stop();
            snd = new Sound();
            snd.load(new URLRequest(inputText.text), new SoundLoaderContext(10,true));
            soundChannel = snd.play(0, 9999);
        }

        
        private function generateCity(m:* = null):void
        {
            var i:int = 0;
            var j:int = 0;
            var k:int = 0;
            var randomlyPick:int = 0;
            var randomlyRatio:Number = 0;
            var rFactor:int = 1
            var rFrom:int = 2;
            var rTo:int = 3;
            var limitLength:Number = 10;
            var limitSize:Number = 3000;
            var align:Boolean = true;
            var detectLongest:Boolean = true;
            var randomAlign:Boolean = autoAlign;
            var aRFactor:int = 1;
            
            while(i<gCount)
            {
                randomlyPick = int(multipleRandom(rFactor) * regions.length);
                randomlyRatio = rFrom+Math.round(multipleRandom(rFactor) * (rTo - rFrom));

                if(regions[randomlyPick].pass)
                {
                    if(regions[randomlyPick].needPush2Region(regions, 1/randomlyRatio, limitLength, limitSize, align, detectLongest, randomAlign, aRFactor))
                    {
                        regions.splice(randomlyPick,1);
                    }
                }
                i++;
            }
            
            var tempvertices:Array = new Array();
            for(i = 0; i < regions.length; i++)
            {
                regions[i].getResizedRegionVerticesByRatio(tempvertices, 0.7);
                constructBuildingByVertices(tempvertices, m);
                tempvertices.splice(0, tempvertices.length);
                regions[i].getResizedRegionVerticesByRatio(tempvertices, 0.9);
                if(area(tempvertices)>8000)
                {
                    
                    traffic.push(new Array());
                    for(j = 0; j < tempvertices.length; j++)
                    {
                        traffic[traffic.length-1].push(tempvertices[j]);
                    }
                }
                tempvertices.splice(0, tempvertices.length);
            }
            buildingsTxt = "total "+regions.length+" buildings";
            updateLabel();
        }
        
        private function onmouseDown(e:MouseEvent):void
        {
            vertices.splice(0, vertices.length);
            projected.splice(0, projected.length);
            faces.splice(0, faces.length);
            indices.splice(0, indices.length);
            uvtData.splice(0, uvtData.length);
            regions.splice(0, regions.length);
            regions.push(new Region);
            regions[0].vertices.push(new Dot(0 ,0));
            regions[0].vertices.push(new Dot(gwidth, 0));
            regions[0].vertices.push(new Dot(gwidth, gheight));
            regions[0].vertices.push(new Dot(0, gheight));
            
            traffic.splice(0, traffic.length);
            generateCity();
        }
        
        private function onkeyDown(e:KeyboardEvent):void
        {
            switch(e.keyCode)
            {
                case Keyboard.SPACE:
                    autoAlign = !autoAlign;
                    updateLabel();
                    break;
                case Keyboard.SHIFT:
                    transparent = !transparent;
                    if(transparent)
                        bitmapData = new BitmapData(500,500, true, 0xFFFFFFFF);
                    else
                        bitmapData = new BitmapData(500,500, false, 0xFFFFFFFF);
                    break;
                case Keyboard.UP:
                    top_down_view = !top_down_view;
                    break;
                case Keyboard.LEFT:
                    white_buildings = !white_buildings;
                    if(white_buildings)
                        bitmapData = new BitmapData(500,500, true, 0xFFFFFFFF);
                    else
                        bitmapData = new BitmapData(500,500, false, 0xFFFFFFFF);
                    break;
                case Keyboard.RIGHT:
                    if(++timerSpeed==4) timerSpeed = 0;
                    timerCount = 0;
                    updateLabel();
                    break;
                case Keyboard.DOWN:
                    if(++varyColor>4) varyColor = 0;
                    updateLabel();
                    break;
            }
        }
        
        private function processing(e:Event):void
        {
            update();
            render();
        }
        
        private function render():void
        {
            world.identity();
            rotate = getTimer() * -0.005;
            world.appendRotation(getTimer() * -0.005, Vector3D.Y_AXIS);
            if(top_down_view) world.appendRotation(90, Vector3D.X_AXIS);
            world.appendTranslation(0, 220, 1000);
            world.append(projection.toMatrix3D());
            Utils3D.projectVectors(world, vertices, projected, uvtData);

            if((rotate-180)/-180>sort_count)
            {
                resort();
                sort_count++;
            }
            viewport.graphics.clear();
            
            Utils3D.projectVectors(world, landVertices, landProjected, landUvtData);
            viewport.graphics.beginBitmapFill(land_bmpd, null, false, false);
            viewport.graphics.drawTriangles(landProjected, landIndices, landUvtData, TriangleCulling.NEGATIVE);
            viewport.graphics.endFill();
            
            if(white_buildings)
                viewport.graphics.beginBitmapFill(new BitmapData(100, 100, true, 0x55FFFFFF), null, false, false);
            else
                viewport.graphics.beginBitmapFill(bitmapData, null, false, false);
            viewport.graphics.drawTriangles(projected, sortedIndices, uvtData, TriangleCulling.NEGATIVE);
            viewport.graphics.endFill();
            /**/
        }
        
        private function resort():void
        {
            var face:Vector3D;
            var inc:int = 0;
            var i1:uint = 0x0;
            var i2:uint = 0x0;
            var i3:uint = 0x0;
            var i4:int = 0;
            for (var i:int = 0; i<indices.length; i+=3){
                i1 = indices[ i+0 ];
                i2 = indices[ i+1 ];
                i3 = indices[ i+2 ];
                face = faces[inc];
                face.x = i1;
                face.y = i2;
                face.z = i3;
                face.w = (uvtData[i1 * 3 + 2] + uvtData[i2 * 3 + 2] + uvtData[i3 * 3 + 2]) * 0.333333;
                inc++;
            }
            
            faces.sortOn("w", Array.NUMERIC);
            
            inc = 0;
            for each (face in faces){
                sortedIndices[inc++] = face.x;
                sortedIndices[inc++] = face.y;
                sortedIndices[inc++] = face.z;
            }
            sort_count = 0;
        }
        
        private function update():void
        {
            SoundMixer.computeSpectrum(bytes, false, 0);
            var byteTotal:Number = 0;
            var i:int = 0;
            var byte:Number = 0;
            bytes.position = 0;
            var w:int = 20;
            var h:int = 25;
            bitmapData.colorTransform(bitmapData.rect, ct);
            //bitmapData.fillRect(bitmapData.rect, 0x000000);
            //bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), blurEffect);
            var size:Number = bitmapData.width*0.8;
            
            var tcolor:uint = 0;
            

            for(i = 0; i < 512; i++)
            {
                byte = Math.abs(bytes.readFloat());
                byteTotal += byte;
                if(byte>0.2)
                {
                    switch(varyColor)
                    {
                        case 0:
                            tcolor = staticColor;
                            break;
                        case 1:
                            vcolor.h = getTimer()/5 + (i)*(360/512);
                            tcolor = vcolor.value32;
                            break;
                        case 2:
                            vcolor.h = getTimer()/5 + 10.5*i;
                            tcolor = vcolor.value32;
                            break;
                        case 3:
                            vcolor.h = getTimer()/5 + 100/1000*i;
                            tcolor = vcolor.value32;
                            break;
                        case 4:
                            vcolor.h = getTimer()/5 + getTimer()*i;
                            tcolor = vcolor.value32;
                            break;
                    }
                    bitmapData.fillRect(new Rectangle((i%windowX)*(size/windowX),int(i/windowX)*(size/windowY), (size/windowX)-8, (size/windowY)-8), tcolor);
                }
            }
            
            byteTotal /= 512;
            
            if(300 * byteTotal > lightRatio) lightRatio = 400 * byteTotal;
            lightRatio -= (lightRatio-32) * 0.03333333;
            
            ratios[1] = lightRatio;
            with(light.graphics)
            {
                clear();
                beginGradientFill(GradientType.RADIAL,colors,alphas,ratios,m);
                drawRect(0,0,stage.stageWidth,stage.stageHeight);
                endFill();
            }
        }
        
        private function updateTraffic(e:TimerEvent):void
        {
            if(++timerCount==timerSpeed)
            {
                var i:int = 0;
                var j:int = 0;
                var k:int = 0;
                var l:int = 0;
                var vx:Number = 0;
                var vy:Number = 0;
                var vlen:Number = 0;
                var tm:Number = 0;
                var theRect:Rectangle = new Rectangle();
                theRect.width = 2;
                theRect.height = 2;
                //land_bmpd.fillRect(land_bmpd.rect, 0x0);
                land_bmpd.colorTransform(land_bmpd.rect, ct);
                for(i = 0; i < traffic.length; i++)
                {
                    for(j = 0; j < traffic[i].length; j++)
                    {
                        k = (j+1) % traffic[i].length;
                        vx = traffic[i][k].x*landResizing - traffic[i][j].x*landResizing;
                        vy = traffic[i][k].y*landResizing - traffic[i][j].y*landResizing;
                        vlen = Math.sqrt(vx*vx+vy*vy);
                        for(l = 0; l < 5; l++)
                        {
                            tm = (getTimer()/timerSpeed)%1000 * vlen/1000;
                            if(tm > vlen/5) tm %= vlen/5;
                            theRect.x = traffic[i][j].x*landResizing + vx/vlen * (vlen/5 * l + tm);
                            theRect.y = traffic[i][j].y*landResizing + vy/vlen * (vlen/5 * l + tm);
                            
                            land_bmpd.fillRect(theRect, 0xFFFF0000);
                            theRect.x += vx/vlen * vlen/5*0.1;
                            theRect.y += vy/vlen * vlen/5*0.1;
                            land_bmpd.fillRect(theRect, 0xFFAA7732);
                        }
                    }
                }
                timerCount = 0;
            }
        }
        
        private function updateLabel():void
        {
            var scolor:String = "";
            switch(varyColor)
            {
                case 0:
                    scolor = "color: Yellow; ";
                    break;
                case 1:
                    scolor = "color: HSV 1; ";
                    break;
                case 2:
                    scolor = "color: HSV 2; ";
                    break;
                case 3:
                    scolor = "color: HSV 3; ";
                    break;
                case 4:
                    scolor = "color: HSV 4; ";
                    break;
            }
            if(autoAlign)
                scolor += "align: gridless; ";
            else
                scolor += "align: by grid; ";
            if(timerSpeed == 0)
                trafficSpeedLabel.text = scolor + buildingsTxt + "; traffic pause!";
            else
                trafficSpeedLabel.text = scolor + buildingsTxt + "; traffic speed: "+(4 - timerSpeed);
            trafficSpeedLabel.x = stage.stageWidth - trafficSpeedLabel.width;
            trafficSpeedLabel.setTextFormat(tf);
        }

        private function constructBuildingByVertices(va:Array, m:* = null):void
        {
            var i:int = 0;
            var j:int = 0;

            var min:Number = bheight*0.20;
            var max:Number = bheight*0.80;
            var randomlyHeight:Number = min+multipleRandom(2)*max;
            
            var i1:uint = 0;
            var i2:uint = 0;
            var i3:uint = 0;
            var i4:uint = 0;
            var indexer:int = 0;
            
            var vratio:Number = 0.8;
            
            for(i = 0; i < va.length; i++)
            {
                j = (i+1)%va.length;
                indexer = vertices.length/3;
                
                vertices.push(va[i].x+offset.x, -randomlyHeight, va[i].y+offset.y); //TL
                vertices.push(va[j].x+offset.x, -randomlyHeight, va[j].y+offset.y); //TR
                vertices.push(va[i].x+offset.x, 0, va[i].y+offset.y); //BL
                vertices.push(va[j].x+offset.x, 0, va[j].y+offset.y); //BR
                
                
                uvtData.push(0+i*vratio/4, 0, 0); //1
                uvtData.push((i+1)*vratio/4, 0, 0); //2
                uvtData.push(0+i*vratio/4, vratio, 0); //3
                uvtData.push((i+1)*vratio/4, vratio, 0); //4
                /**/
                
                i1 = indexer;
                i2 = indexer + 1;
                i3 = indexer + 2;
                i4 = indexer + 3;

                indices.push(i1, i2, i3, i3, i2, i4);
                
                faces.push(new Vector3D(), new Vector3D());
            }
            /**/
            
            indexer = vertices.length/3;
            
            // top
            vertices.push(va[1].x+offset.x, -randomlyHeight, va[1].y+offset.y); //TL
            vertices.push(va[0].x+offset.x, -randomlyHeight, va[0].y+offset.y); //TR
            vertices.push(va[2].x+offset.x, -randomlyHeight, va[2].y+offset.y); //BL
            vertices.push(va[3].x+offset.x, -randomlyHeight, va[3].y+offset.y); //BR
            if(transparent)
            {
                uvtData.push(0, 0, 0); //1
                uvtData.push(0, 0, 0); //2
                uvtData.push(0, 0, 0); //3
                uvtData.push(0, 0, 0); //4
            } else {
                uvtData.push(vratio, vratio, 0); //1
                uvtData.push(1, vratio, 0); //2
                uvtData.push(vratio, 1, 0); //3
                uvtData.push(1, 1, 0); //4
            }
            
            i1 = indexer;
            i2 = indexer + 1;
            i3 = indexer + 2;
            i4 = indexer + 3;
            indices.push(i1, i2, i3, i3, i2, i4);
            
            faces.push(new Vector3D(), new Vector3D());
            /**/
            //if(!sortedIndices)
            sortedIndices= new Vector.<int>(indices.length, true);
        }
        
        private function constructLand():void
        {
            var i1:uint = 0;
            var i2:uint = 1;
            var i3:uint = 2;
            var i4:uint = 3;
            
            landVertices.push(gwidth-gwidth/2, 0, 0-gheight/2); //TR
            landVertices.push(0-gwidth/2, 0, 0-gheight/2); //TL
            
            landVertices.push(gwidth-gwidth/2, 0, gheight-gheight/2); //BL
            landVertices.push(0-gwidth/2, 0, gheight-gheight/2); //BR
            
            
            landUvtData.push(1, 0, 0); //2
            landUvtData.push(0, 0, 0); //1
            landUvtData.push(1, 1, 0); //4
            landUvtData.push(0, 1, 0); //3
            
            
            landIndices.push(i1, i2, i3, i3, i2, i4);
        }
        
        private function multipleRandom(factor:int):Number
        {
            var counter:int = 0;
            var rand:Number = 1;
            while(counter++<factor)
            {
                rand *= Math.random();
            }
            return rand;
        }
        
        private function area(p:Array):Number
        {
            var i:int = 0;
            var j:int = 0;
            var a:Number = 0;
            i = 0;
            while (i < p.length)
            {
                j = (i + 1) % p.length;
                a = a + p[i].x * p[j].y;
                a = a - p[i].y * p[j].x;
                i++;
            }
            a = a / 2;
            return a;
        }
    }
}

import flash.display.*;
import flash.text.*;
import flash.events.*;
import flash.display.Sprite;
import flash.net.*;
import flash.filters.*;
import flash.geom.*;
import flash.ui.*;

class Region
{
    public var vertices:Array = new Array();
    public var pass:Boolean = true;
    
    public function Region()
    {
    }
    
    // right is always equal to edge index, so skip the right function
    public function getVerticeAtEdgeLeft(index:int):int
    {
        return (index+1>3)?0:index+1;
    }
    
    public function getOppositeEdgeOfEdge(index:int):int
    {
        return (index+2>3)?(index+2)%4:index+2;
    }
    
    public function needPush2Region(origin:Array, ratio:Number, limitLength:Number = 0.0, limitSize:Number = 0.0, align:Boolean = true, detectLongest:Boolean = true, randomAlign:Boolean = false, aRFactor:int = 1):Boolean
    {
        var rIndex:int = int(Math.random() * 4);
        if(detectLongest)
            rIndex = getLongestEdgeStartFromEdge(rIndex);
        var rLeft:int = getVerticeAtEdgeLeft(rIndex);
        var rRight:int = rIndex;
        
        var vx:Number = vertices[rLeft].x - vertices[rRight].x;
        var vy:Number = vertices[rLeft].y - vertices[rRight].y;
        var vlen:Number = Math.sqrt(vx*vx+vy*vy);
        
        if(limitLength == 0.0 || vlen>limitLength)
        {
            var oIndex:int = getOppositeEdgeOfEdge(rIndex);
            var oLeft:int = getVerticeAtEdgeLeft(oIndex);
            var oRight:int = oIndex;
            
            var rPoint:Dot;
            rPoint = getPointAtEdgeByRatio(rIndex, ratio);
            var oPoint:Dot;
            //oPoint = getPointAtEdgeByPoint(oIndex, rPoint);
            
            
            if(!randomAlign)
                if(align)
                    oPoint = getPointAtEdgeByRatio(oIndex, 1-ratio);
                else
                    oPoint = getPointAtEdgeByRatio(oIndex, ratio);
            else {
                if(multipleRandom(aRFactor)<0.5)
                {
                    //oPoint = getPointAtEdgeByRatio(oIndex, 1-ratio);
                    oPoint = getPointAtEdgeByPoint(oIndex, rPoint);
                    if(oPoint == null)
                    {
                        oPoint = getPointAtEdgeByRatio(oIndex, Math.random()*(1-ratio));
                    }
                } else
                    oPoint = getPointAtEdgeByRatio(oIndex, ratio);
            }/**/
            
            var regionLeft:Region = new Region();
            var regionRight:Region = new Region();
            
            regionLeft.vertices.push(vertices[oRight].clone());
            regionLeft.vertices.push(oPoint);
            regionLeft.vertices.push(rPoint);
            regionLeft.vertices.push(vertices[rLeft].clone());
            
            if(limitSize != 0.0 && regionLeft.area()<limitSize)
            {
                regionLeft.pass = false;
            }
            origin.push(regionLeft);
            
            regionRight.vertices.push(oPoint);
            regionRight.vertices.push(vertices[oLeft].clone());
            regionRight.vertices.push(vertices[rRight].clone());
            regionRight.vertices.push(rPoint);
            
            if(limitSize != 0.0 && regionRight.area()<limitSize)
            {
                regionRight.pass = false;
            }
            origin.push(regionRight);
            return true;
        }
        return false;
    }
    
    public function getPointAtEdgeByRatio(index:int, ratio:Number):Dot
    {
        var jndex:int = (index+1)%4;
        var vx:Number = vertices[jndex].x - vertices[index].x;
        var vy:Number = vertices[jndex].y - vertices[index].y;
        return new Dot(vertices[index].x+vx*ratio, vertices[index].y+vy*ratio);
    }
    
    public function getPointAtEdgeByPoint(index:int, p:Dot):Dot
    {
        var jndex:int = (index+1)%4;
        var avx:Number = vertices[jndex].x - vertices[index].x;
        var avy:Number = vertices[jndex].y - vertices[index].y;
        var vlena:Number = Math.sqrt(avx*avx+avy*avy);
        var dist:Number = pdis(vertices[index], vertices[jndex], p);
        var bvx:Number = p.x - vertices[index].x;
        var bvy:Number = p.y - vertices[index].y;
        var vlenb:Number = Math.sqrt(bvx*bvx+bvy*bvy);

        var nvlena:Number = Math.sqrt(vlenb*vlenb - dist*dist); 

        if(nvlena<vlena)
            return new Dot(vertices[index].x+nvlena*avx/vlena, vertices[index].y+nvlena*avy/vlena);
        return null;
    }
    
    public function getLengthOfEdge(index:int):Number
    {
        var nextIndex:int = (index+1)%4;
        var vx:Number = vertices[nextIndex].x - vertices[index].x;
        var vy:Number = vertices[nextIndex].y - vertices[index].y;
        return Math.sqrt(vx*vx+vy*vy);
    }
    
    public function getLongestEdgeStartFromEdge(index:int):int
    {
        var li:int = index;
        var ci:int = index;
        var startIndex:int = index;
        var longestLength:Number = getLengthOfEdge(index);
        var currLength:Number = 0;
        do{
            ci = (ci+1)%4;
            currLength = getLengthOfEdge(ci);
            if(currLength>longestLength)
            {
                longestLength = currLength;
                li = ci;
            }
        } while(ci != startIndex);
        return li;
    }
    
    public function area():Number
    {
        var i:int = 0;
        var j:int = 0;
        var a:Number = 0;
        i = 0;
        while (i < vertices.length)
        {
            j = (i + 1) % vertices.length;
            a = a + vertices[i].x * vertices[j].y;
            a = a - vertices[i].y * vertices[j].x;
            i++;
        }
        a = a / 2;
        return a;
    }
    
    public function multipleRandom(factor:int):Number
    {
        var counter:int = 0;
        var rand:Number = 1;
        while(counter++<factor)
        {
            rand *= Math.random();
        }
        return rand;
    }
    
    public function pdis(a:Dot, b:Dot, c:Dot):Number
    {
        var t:Dot =  new Dot(b.x-a.x, b.y-a.y);//           # Vector ab
        var dd:Number = Math.sqrt(t.x*t.x+t.y*t.y);//         # Length of ab
        t.val_p_(t.x/dd, t.y/dd);//               # unit vector of ab
        var n:Dot = new Dot(-t.y, t.x);//                    # normal unit vector to ab
        var ac:Dot = new Dot(c.x-a.x, c.y-a.y);//          # vector ac
        return Math.abs(ac.x*n.x+ac.y*n.y);
    }
    
    public function com() : Dot// centre of mass
    {
        var cm:Dot = new Dot(0, 0);
        var tx:Number = 0;
        var ty:Number = 0;
        var a:Number = area();
        var i:int = 0;
        var j:int = 0;
        var d:Number = 0;
        i = 0;
        while (i < vertices.length)
        {
            
            j = (i + 1) % vertices.length;
            d = vertices[i].x * vertices[j].y - vertices[j].x * vertices[i].y;
            tx = tx + (vertices[i].x + vertices[j].x) * d;
            ty = ty + (vertices[i].y + vertices[j].y) * d;
            i++;
        }
        a = a * 6;
        d = 1 / a;
        tx = tx * d;
        ty = ty * d;
        cm.x = tx;
        cm.y = ty;
        return cm;
    }
    
    public function getResizedRegionVerticesByRatio(target:Array, ratio:Number = 1.0):void
    {
        var centerOfMass:Dot = com();
        var vx:Number = 0;
        var vy:Number = 0;
        var i:int = 0;
        for(i = 0; i < vertices.length; i++)
        {
            vx = vertices[i].x - centerOfMass.x;
            vy = vertices[i].y - centerOfMass.y;
            target.push(new Dot(centerOfMass.x+vx*ratio, centerOfMass.y+vy*ratio));
        }
    }
}

class Dot
{
    public var x:Number = 0;
    public var y:Number = 0;
    public var tx:Number = 0;
    public var ty:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var angle:Number = 0;
    public var size:Number = 0;
    public var speed:Number = 0;
    public var m:Number = 0;
    public var rad:Number = 0;

    public function Dot(px:Number,py:Number)
    {
        x = px;
        y = py;
        tx = x;
        ty = y;
    }
    
    public function clone():Dot
    {
        return new Dot(this.x, this.y);
    }
    
    public function val_(p:Dot):Dot
    {
        x = p.x;
        y = p.y;
        return this;
    }
    
    public function val_p_(px:Number, py:Number):Dot
    {
        x = px;
        y = py;
        return this;
    }
    
    public function add_(px:Number, py:Number):Dot
    {
        x += px;
        y += py;
        return this;
    }
}