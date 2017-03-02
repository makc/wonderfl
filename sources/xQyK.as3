package
{
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
    import flash.display.Sprite;
    import flash.net.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.ui.*;
    import flash.system.*;
    import flash.utils.*;
    import com.bit101.components.PushButton;
    import net.hires.debug.Stats;
    
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class BlobWorld extends Sprite
    {
        public static var GRAPHIC_URL:String ="https://www.dropbox.com/s/4yi7pzmfl00cwu2/loco3.png?raw=1";
        private var loader      :Loader;
        private var bmpd        :BitmapData;
        
        private var mouth_bmpd  :BitmapData;
        private var mouth2_bmpd :BitmapData;
        private var eyes_bmpd   :BitmapData;
        private var hair_bmpd   :BitmapData;
        
        private var painter     :MovieClip          = new MovieClip();
        private var blobs       :Vector.<xBlob>     = new Vector.<xBlob>();
        private var blobCount   :int                = 3;
        private var blobsMouth  :Vector.<Bitmap>    = new Vector.<Bitmap>(0, false);
        private var blobsFace   :Vector.<MovieClip> = new Vector.<MovieClip>(0, false);
        private var blobsEyes   :Vector.<MovieClip> = new Vector.<MovieClip>(0, false);
        
        private var show_bone   :Boolean   = false;
        
        public function BlobWorld()
        {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest(GRAPHIC_URL), new LoaderContext(true));
        }
        
        private function init(e:Event = null):void
        {
            addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x6699CC)));
            addChild(new Stats());
            bmpd = Bitmap(loader.content).bitmapData;
            mouth_bmpd = new BitmapData(7, 7, true, 0x0);
            mouth_bmpd.copyPixels(bmpd, new Rectangle(17,0,7,7), new Point());
            mouth2_bmpd = new BitmapData(7, 7, true, 0x0);
            mouth2_bmpd.copyPixels(bmpd, new Rectangle(24,0,3,7), new Point(3,0));
            eyes_bmpd = new BitmapData(17, 7, true, 0x0);
            eyes_bmpd.copyPixels(bmpd, new Rectangle(0,0,17,7), new Point());
            hair_bmpd = new BitmapData(25, 13, true, 0x0);
            hair_bmpd.copyPixels(bmpd, new Rectangle(0,8,25,14), new Point());
            
            addChild( painter );
            
            for(var i:int = 0; i<blobCount; i++)
            {
                addBlob(i);
            }
            var panel:Sprite = new Sprite();
            addChild(panel);
            //new PushButton(panel, stage.stageWidth-170, 5, "show bones", showBones).setSize(80, 16);
            //new PushButton(panel, stage.stageWidth-85, 5, "add blob", addMoreBlob).setSize(80, 16);
            
            stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown  );
            stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove  );
            stage.addEventListener( MouseEvent.MOUSE_UP,   mouseUp    );
            stage.addEventListener( Event.ENTER_FRAME,     processing );
        }
        
        private function addMoreBlob(...arg):void
        {
            addBlob(blobs.length);
        }
        
        private function addBlob(id:int):void
        {
            
            var plastic_organs:Bitmap;
            blobsFace.push(new MovieClip());
            addChild(blobsFace[id]);
            
            // plastic surgery
            plastic_organs = new Bitmap(hair_bmpd);
            plastic_organs.x = -hair_bmpd.width/2; plastic_organs.y = -hair_bmpd.height*0.9;
            blobsFace[id].addChild(plastic_organs);
            //eye
            blobsEyes.push(new MovieClip());
            plastic_organs = new Bitmap(eyes_bmpd);
            blobsEyes[id].addChild(plastic_organs);
            plastic_organs.y = -eyes_bmpd.height/2;
            blobsEyes[id].x = -eyes_bmpd.width/2; blobsEyes[id].y = 3+eyes_bmpd.height/2;
            blobsFace[id].addChild(blobsEyes[id]);
            //mouth
            plastic_organs = new Bitmap(mouth_bmpd);
            plastic_organs.x = -mouth_bmpd.width/2; plastic_organs.y = eyes_bmpd.height+3;
            blobsFace[id].addChild(plastic_organs);
            blobsMouth.push(plastic_organs);
            
            blobs.push(new xBlob(50+Math.random()*365, 100, 30+Math.random()*40, 15));
            blobs[id].blink = Math.random() * 3000;
            blobs[id].update();
            
        }
        
        public function processing(e:Event):void
        {
            var i:int = 0;
            var j:int = 0;

            //calculate diff
            for(i = 0; i<blobs.length; i++)
                blobs[i].setup();
            
            //check contacts
            for(i = 0; i<blobs.length; i++)
                for(j = 0; j <blobs.length; j++)
                    if(i != j)
                        blobs[i].xcontact(blobs[j]);
                        
            //response
            for(i = 0; i<blobs.length; i++)
                blobs[i].update();
            
            
            paint();
        }
        
        public function mouseDown(em:MouseEvent):void
        {
            for(var i:int = 0; i<blobs.length; i++)
                blobs[i].dragStart(mouseX, mouseY);
        }
        
        public function mouseMove(em:MouseEvent):void
        {
            for(var i:int = 0; i<blobs.length; i++)
                blobs[i].dragAt(mouseX, mouseY);
        }
        
        public function mouseUp(em:MouseEvent):void
        {
            for(var i:int = 0; i<blobs.length; i++)
                blobs[i].dragStop(mouseX, mouseY);
        }
        
        private function showBones(...arg):void
        {
            show_bone = !show_bone;
        }
        
        public function paint():void
        {
            // with(){} is slower?
            painter.graphics.clear();
            
            var i:int = 0;
            var j:int = 0;
            var k:int = 0;

            for(i = 0; i<blobs.length; i++)
            {
                painter.graphics.beginFill(0xFFCC32);
                painter.graphics.lineStyle(0.1, 0xFFCC32,1,false,LineScaleMode.HORIZONTAL,CapsStyle.ROUND,JointStyle.ROUND,4);

                blobsFace[i].x = blobs[i].points[0].x;
                blobsFace[i].y = blobs[i].points[0].y;
                blobsFace[i].rotation = Math.atan2(blobs[i].pvn[0].y, blobs[i].pvn[0].x)/(Math.PI/180) - 90;
                if(int((blobs[i].blink+getTimer())%3000)<200) blobsEyes[i].scaleY = ((blobs[i].blink+getTimer())%200)/200;
                
                if(blobs[i].dragging!=-1)
                {
                    blobsMouth[i].bitmapData = mouth2_bmpd;
                } else 
                    blobsMouth[i].bitmapData = mouth_bmpd;
                painter.graphics.moveTo(blobs[i].mid[0].x, blobs[i].mid[0].y);
                for(j = 0;j<blobs[i].points.length;j++)
                {
                    k = (j+1) % blobs[i].points.length;
                    if(show_bone)
                    {
                        painter.graphics.moveTo(blobs[i].points[j].x, blobs[i].points[j].y);
                        painter.graphics.lineTo(blobs[i].points[j].x+blobs[i].pvn[j].x*blobs[i].r, blobs[i].points[j].y+blobs[i].pvn[j].y*blobs[i].r);
                    
                        painter.graphics.moveTo(blobs[i].points[j].x, blobs[i].points[j].y);
                        painter.graphics.lineTo(blobs[i].points[k].x, blobs[i].points[k].y);
                    }
                    painter.graphics.curveTo(blobs[i].points[k].x, blobs[i].points[k].y, blobs[i].mid[k].x, blobs[i].mid[k].y);/**/
                }
                painter.graphics.endFill();
            }
        }
    }
}

class xBlob
{
    public var points   :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var mid      :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var ppoints  :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var disp     :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var vlen     :Vector.<Number> = new Vector.<Number>(0, false);
    public var fdiv     :Vector.<Number> = new Vector.<Number>(0, false);
    public var ad       :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var d        :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var pvn      :Vector.<Dot>    = new Vector.<Dot>(0, false);

    public var nc       :Number  = 15;
    public var r        :Number  = 30;
    public var comp     :Number  = 0.033;
    public var sd       :Number  = 0.3;
    public var fa       :Number  = 0.9;
    public var g        :Number  = 0.5;

    public var OArea    :Number  = 0;

    public var left     :Boolean = false;
    public var right    :Boolean = false;

    public var clipping :Dot     = new Dot(0,0);
    public var dragging :int     = -1;
    
    public var mouse_x  :Number  = 0;
    public var mouse_y  :Number  = 0;
    
    // extra for rectangle (not working)
    public var w        :Number  = r*2;
    public var h        :Number  = r*2;
    public var cp       :Dot;
    public var org      :Vector.<Dot>    = new Vector.<Dot>(0, false);
    public var olen     :Vector.<Number> = new Vector.<Number>(0, false);
    
    public var blink    :int     = 0;

    public function xBlob(cx:Number=0, cy:Number=0, size:Number=30, nodeCount:Number=15)
    {
        cp = new Dot(cx, cy);
        r = size;
        nc = nodeCount;
        var i:int = 0;
        var j:int = 0;
        var px:Number;
        var py:Number;
        var vx:Number = 0;
        var vy:Number = 0;

        clipping.l = 0;
        clipping.r = 465;
        clipping.t = 0;
        clipping.b = 465;
        
        for (; i<nc; i++)
        {
            px = r*Math.cos(i/nc*Math.PI*2)+cx;
            py = r*Math.sin(i/nc*Math.PI*2)+cy;
            fullpush(px,py);
        }
        
        for(i=0; i < points.length; i++)
        {
            j = (j+1)%points.length;
            vx = points[j].x - points[i].x;
            vy = points[j].y - points[i].y;
            vlen.push(Math.sqrt(vx*vx+vy*vy));
        }
        OArea=calcArea();
    }
    
    public function fullpush(px:Number, py:Number):void
    {
        var tx:Number = px - cp.x;
        var ty:Number = py - cp.y;
        var xlen:Number = Math.sqrt(tx * tx + ty * ty);
        points.push(new Dot(px,py));
        org.push(new Dot(tx,ty));
        disp.push(new Dot(0, 0));
        fdiv.push(0);
        ppoints.push(new Dot(0, 0));
        mid.push(new Dot(0, 0));
        d.push(new Dot(0, 0));
        ad.push(new Dot(0, 0));
        pvn.push(new Dot(tx/xlen, ty/xlen));
        olen.push(xlen);
    }

    public function update():void
    {
        var NArea:Number = calcArea();
        var i:int = 0;
        var j:int = 0;
        var p:Number = (NArea - OArea)*comp/nc;
        var n1:Dot;
        var n2:Dot;
        var np:Dot;
        var n:Dot;
        var nn:Dot;
        var vn:Dot;
        var fx:Number=0;
        var fy:Number=0;
        var dx:Number=0;
        var dy:Number=0;
        var da:Number=0;
        var px:Number=0;
        var py:Number=0;
        var gx:Number =0;
        var gy:Number = 0;
        var vx:Number = 0;
        var vy:Number = 0;
        var xlen:Number = 0;

        for(i = 0; i < points.length; i++)
            if(fdiv[i] > 0)
            {

                gx = disp[i].x / fdiv[i];// / 2;
                gy = disp[i].y / fdiv[i];// / 2;

                points[i].x = points[i].x + gx;
                points[i].y = points[i].y + gy;

                points[i].vx = points[i].vx + gx;
                points[i].vy = points[i].vy + gy;
                
                disp[i].x = 0.0;
                disp[i].y = 0.0;
                
                fdiv[i] = 0;

            }

        for (i=0; i<points.length; i++)
        {
            j = (i+1)%points.length;
            n1 = points[i];
            n2 = points[j];
            
            fx = (n1.x - n2.x) * sd;
            fy = (n1.y - n2.y) * sd;
            
            n1.vx -= fx;
            n1.vy -= fy;
            fdiv[i]   = fdiv[i]   + 1;
            n2.vx += fx;
            n2.vy += fy;
            fdiv[j]   = fdiv[j]   + 1;

        }

        for (i=0; i<points.length; i++)
        {
            np = points[(points.length+i-1)%points.length];
            n = points[i];
            nn = points[(i+1)%points.length];
            vn = vertexNormal(np,n,nn);
            pvn[i].x = vn.x;
            pvn[i].y = vn.y;
            n.vx += vn.x*p;
            n.vy += vn.y*p;
        }

        var pp:Dot;
        for (i = 0; i<nc; i++)
        {
            if (i == dragging)
            {
                points[i].x = mouse_x;
                points[i].y = mouse_y;
                points[i].vx = 0;
                points[i].vy = 0;
            } else {
                n = points[i];
                pp = ppoints[i];

                pp.x = n.x;
                pp.y = n.y;
                pp.vx = n.vx;
                pp.vy = n.vy;

                n.vy += g;
                
                if (isNaN(n.vx))
                {
                    trace("NaN");
                    break;
                }

                n.x += n.vx *= fa;
                n.y += n.vy *= fa;

                if (n.x<clipping.l)
                {
                    n.x=clipping.l;
                    n.vx=0;
                }
                if (n.x>clipping.r)
                {
                    n.x=clipping.r;
                    n.vx=0;
                }
                if (n.y<clipping.t)
                {
                    n.y=clipping.t;
                    n.vy=0;
                }
                if (n.y>clipping.b)
                {
                    n.y=clipping.b;
                    n.vy=0;
                }
            }
        }
        
        for (i = 0; i < points.length; i++)
        {
            j = (i + 1) % points.length;
            vx=points[j].x-points[i].x;
            vy=points[j].y-points[i].y;
            xlen=Math.sqrt(vx*vx+vy*vy);

            if (xlen>0)
            {
                ad[i].x=vx/xlen;
                ad[i].y=vy/xlen;
            }
        }

        if (left)
        {
            for (i = 0; i < nc; i++)
            {
                j = (i + 1) % nc;
                points[j].x-=2*ad[i].x;
                points[j].y-=2*ad[i].y;
            }
        }
        if (right)
        {
            for (i = 0; i < nc; i++)
            {
                points[i].x+=2*ad[i].x;
                points[i].y+=2*ad[i].y;
            }
        }

        for (i=0; i<points.length; i++)
        {
            j = (i+1) % points.length;
            mid[i].x = (points[i].x+points[j].x)/2;
            mid[i].y = (points[i].y+points[j].y)/2;
        }
    }
    
    public function setup():void
    {
        var i    :int = 0;
        var k    :int;
        var vx   :Number = 0;
        var vy   :Number = 0;
        var len  :Number = 0;
        var diff :Number = 0;
        var nx   :Number = 0;
        var ny   :Number = 0;
        var ux   :Number = 0;
        var uy   :Number = 0;
        
        for(; i < points.length; i++)
        {
            k = (i + 1) % points.length;
            
            vx = points[k].x - points[i].x;
            vy = points[k].y - points[i].y;
            len = Math.sqrt(vx * vx + vy * vy);
            diff = vlen[i] - len;

            nx = vx / len;
            ny = vy / len;

            ux = diff * nx;
            uy = diff * ny;

            d[i].x = nx;
            d[i].y = ny;
        }
    }
    
    public function inside(p0:Number, p1:Number, p2:Number):Boolean
    {
        if(p0>p1 && p0<p2)
            return true;
        return false;
    }
    
    public function inBetween(p0:Dot, p1:Dot, p2:Dot):Boolean
    {
        if(inside(p0.x, p1.x, p2.x) || inside(p0.x, p2.x, p1.x) || inside(p0.y, p1.y, p2.y) || inside(p0.y, p2.y, p1.y))
            return true;
        return false;
    }
    
    public function xcontact(blob:xBlob):void
    {
        var i:int = 0;
        var j:int;
        var l:int = 0;
        var k:int = 0;
        var o:int = 0;
        var sx:Number = 0;
        var sy:Number = 0;
        var angle:Number = 0;
        var cosa:Number = 0;
        var sina:Number = 0;
        var x1:Number = 0;
        var y1:Number = 0;
        var vx1:Number = 0;
        var yb:Number = 0;
        var vy1:Number = 0;
        var yy1:Number = 0;
        var adj:Number = 0;
        
        var gx   :Number = 0;
        var gy   :Number = 0;
        var cx   :Number = 0;
        var cy   :Number = 0;
        var dp   :Number = 0;
        var f1   :Number = 0;
        var f2   :Number = 0;
        var vx   :Number = 0;
        var vy   :Number = 0;
        var len  :Number = 0;
        var diff :Number = 0;

        var bvx:Number = 0;
        var bvy:Number = 0;
        var blen:Number = 0;
        var pavn:Dot = new Dot(0, 0);

        for(i = 0; i < points.length; i++) {
            l = (i+1) % points.length;
            if(blob.inPoly(points[i].x, points[i].y))
            {
                for(o = 0; o < blob.points.length; o++) {
                    k = (o+1) % blob.points.length;
                    //if(inBetween(points[o], points[i], points[l]) || ){
                        sx = points[i].x-blob.points[o].x;
                        sy = points[i].y-blob.points[o].y;
                        angle = Math.atan2(blob.points[k].y-blob.points[o].y,blob.points[k].x-blob.points[o].x);
                        cosa = Math.cos(angle);
                        sina = Math.sin(angle);
                        x1 = sx*cosa+sy*sina;
                        y1 = sy*cosa-sx*sina;
                        vx = points[i].x - blob.points[o].x;
                        vy = points[i].y - blob.points[o].y;
                        
                        dp = vx * blob.d[o].x + vy * blob.d[o].y;

                        bvx = blob.points[k].x-blob.points[o].x;
                        bvy = blob.points[k].y-blob.points[o].y;
                        
                        blen = Math.sqrt(bvx*bvx+bvy*bvy);

                        pavn.x = points[i].x + pvn[i].x * r;
                        pavn.y = points[i].y + pvn[i].y * r;

                        if (y1>0 && intersected(points[i], pavn, blob.points[k], blob.points[o])) {
                            cx = blob.points[o].x + dp * blob.d[o].x;
                            cy = blob.points[o].y + dp * blob.d[o].y;
                            
                            vx = points[i].x - cx;
                            vy = points[i].y - cy;
                            
                            len = Math.sqrt(vx * vx + vy * vy);
                            
                            diff = 4 /4;
                            gx = diff * vx;
                            gy = diff * vy;

                            disp[i].x = disp[i].x - gx;
                            disp[i].y = disp[i].y - gy;
                            fdiv[i] = fdiv[i] + 1;

                            f1 = dp / blen;
                            f2 = 1.0 - f1;

                            blob.disp[j].x = blob.disp[j].x + f2 * gx;
                            blob.disp[j].y = blob.disp[j].y + f2 * gy;
                            blob.fdiv[j] = blob.fdiv[j] + 1;
                            blob.disp[k].x = blob.disp[k].x + f1 * gx;
                            blob.disp[k].y = blob.disp[k].y + f1 * gy;
                            blob.fdiv[k] = blob.fdiv[k] + 1;
    
                            points[i].vx = vx1*cosa-vy1*sina;
                            points[i].vy = vy1*cosa+vx1*sina;
                            points[i].x += points[i].vx;
                            points[i].y += points[i].vy;
                            break;
                        }
                    }
                //}
            }
        }
    }

    public function inPoly(px:Number, py:Number):Boolean
    {
        var i:int, j:int;
        var c:Boolean = false;
        for (i = 0, j = points.length-1; i < points.length; j = i++) {
        if ( ((points[i].y>py) != (points[j].y>py)) && (px < (points[j].x-points[i].x) * (py-points[i].y) / (points[j].y-points[i].y) + points[i].x) )
            c = !c;
        }
        return c;
    }
    
    public function dragStart(m_x:Number, m_y:Number):void
    {
        mouse_x = m_x;
        mouse_y = m_y;
        
        var distance:Number = 15;
        var target:int = -1;
        var curr_distance:Number = 0;
        var vx:Number = 0;
        var vy:Number = 0;
        for (var i:int = 0; i<points.length; i++)
        {
            vx = points[i].x - m_x;
            vy = points[i].y - m_y;
            curr_distance = Math.sqrt(vx*vx+vy*vy);
            if(curr_distance<distance)
            {
                distance = curr_distance;
                target = i;
            }
        }
        dragging = target;
    }
    
    public function dragAt(m_x:Number, m_y:Number):void
    {
        if(dragging>=0)
        {
            mouse_x = m_x;
            mouse_y = m_y;
        }
    }
    
    public function dragStop(m_x:Number, m_y:Number):void
    {
        dragging = -1;
    }

    private function calcArea():Number
    {
        var a:Number=0;
        var n1:Dot;
        var n2:Dot;
        var i:int=0;
        //a = 0;
        for (i=0; i<points.length; i++)
        {
            n1=points[i];
            n2 = points[(i+1)%points.length];
            a += (n1.x-n2.x)*(n1.y+n2.y);
        }
        return a/2;
    }
    
    public function intersected(p1:Dot, p2:Dot, p3:Dot, p4:Dot):Boolean
    {
        var s1_x:Number, s1_y:Number, s2_x:Number, s2_y:Number;
        s1_x = p2.x - p1.x;     s1_y = p2.y - p1.y;
        s2_x = p4.x - p3.x;     s2_y = p4.y - p3.y;
    
        var s:Number, t:Number;
        s = (-s1_y * (p1.x - p3.x) + s1_x * (p1.y - p3.y)) / (-s2_x * s1_y + s1_x * s2_y);
        t = ( s2_x * (p1.y - p3.y) - s2_y * (p1.x - p3.x)) / (-s2_x * s1_y + s1_x * s2_y);
    
        if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
        {
            return true;
        }
    
        return false;
    }
    
    private function vertexNormal(np:Dot, n:Dot, nn:Dot):Dot
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

        //rotate dp anti-clockwise by 90C
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
        
        return new Dot(fx,fy);
    }
}

class Dot {
    public var x:Number = 0;
    public var y:Number = 0;
    public var tx:Number = 0;
    public var ty:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var nx:Number = 0;
    public var ny:Number = 0;
    public var dx:Number = 0;
    public var dy:Number = 0;
    public var fx:Number = 0;
    public var fy:Number = 0;
    public var angle:Number = 0;
    public var size:Number = 0;
    public var speed:Number = 0;
    public var m:Number = 0;
    public var rad:Number = 0;
    public var a:Number = 0;
    public var drag:Boolean = false;
    public var l:Number = 0;
    public var r:Number = 0;
    public var t:Number = 0;
    public var b:Number = 0;
    
    public function Dot(px:Number=0,py:Number=0) {
        x = px;
        y = py;
        tx = x;
        ty = y;
    }
}