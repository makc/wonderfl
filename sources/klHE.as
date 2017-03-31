package
{
    import flash.display.Sprite;
    import flash.events.Event;
    public class SoccerBall extends Sprite
    {
        private var vertices:Array;
        private var fl:Number = 4000;
        private var VP_X:Number = stage.stageWidth / 2;
        private var VP_Y:Number = stage.stageHeight / 2;
        private var Planes:Array;
        public function SoccerBall()
        {
            initSoccerBall();
        }
        private function initSoccerBall():void
        {
            //stage.scaleMode = StageScaleMode.NO_SCALE;
            vertices = new Array();
            vertices[0] = new getPoints(0,10,48.54101966249685);
            vertices[1] = new getPoints(16.18033988749895,20,42.3606797749979);
            vertices[2] = new getPoints(10,36.18033988749895,32.3606797749979);
            vertices[3] = new getPoints(-10,36.18033988749895,32.3606797749979);
            vertices[4] = new getPoints(-16.18033988749895,20,42.3606797749979);
           
            vertices[5] = new getPoints(0,-10,48.54101966249685); 
            vertices[6] = new getPoints(-16.18033988749895,-20,42.3606797749979); 
            vertices[7] = new getPoints(-10,-36.18033988749895,32.3606797749979); 
            vertices[8] = new getPoints(10,-36.18033988749895,32.3606797749979); 
            vertices[9] = new getPoints(16.18033988749895,-20,42.3606797749979);
            //------------------------------------------------------------------------------    
            vertices[10] = new getPoints(0,10,-48.54101966249685);
            vertices[11] = new getPoints(16.18033988749895,20,-42.3606797749979);
            vertices[12] = new getPoints(10,36.18033988749895,-32.3606797749979);
            vertices[13] = new getPoints(-10,36.18033988749895,-32.3606797749979);
            vertices[14] = new getPoints(-16.18033988749895,20,-42.3606797749979);
            
            vertices[15] = new getPoints(0,-10,-48.54101966249685); 
            vertices[16] = new getPoints(-16.18033988749895,-20,-42.3606797749979); 
            vertices[17] = new getPoints(-10,-36.18033988749895,-32.3606797749979); 
            vertices[18] = new getPoints(10,-36.18033988749895,-32.3606797749979); 
            vertices[19] = new getPoints(16.18033988749895,-20,-42.3606797749979);
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
            vertices[20] = new getPoints(10,48.54101966249685,0); 
            vertices[21] = new getPoints(20,42.3606797749979,-16.18033988749895); 
            vertices[22] = new getPoints(36.18033988749895,32.3606797749979,-10); 
            vertices[23] = new getPoints(36.18033988749895,32.3606797749979,10); 
            vertices[24] = new getPoints(20,42.3606797749979,16.18033988749895);
           
            vertices[25] = new getPoints(-10,48.54101966249685,0); 
            vertices[26] = new getPoints(-20,42.3606797749979,16.18033988749895); 
            vertices[27] = new getPoints(-36.18033988749895,32.3606797749979,10); 
            vertices[28] = new getPoints(-36.18033988749895,32.3606797749979,-10); 
            vertices[29] = new getPoints(-20,42.3606797749979,-16.18033988749895);
            //-------------------------------------------------------------------------------
            vertices[30] = new getPoints(10,-48.54101966249685,0); 
            vertices[31] = new getPoints(20,-42.3606797749979,-16.18033988749895); 
            vertices[32] = new getPoints(36.18033988749895,-32.3606797749979,-10); 
            vertices[33] = new getPoints(36.18033988749895,-32.3606797749979,10); 
            vertices[34] = new getPoints(20,-42.3606797749979,16.18033988749895);
            
            vertices[35] = new getPoints(-10,-48.54101966249685,0); 
            vertices[36] = new getPoints(-20,-42.3606797749979,16.18033988749895); 
            vertices[37] = new getPoints(-36.18033988749895,-32.3606797749979,10); 
            vertices[38] = new getPoints(-36.18033988749895,-32.3606797749979,-10); 
            vertices[39] = new getPoints(-20,-42.3606797749979,-16.18033988749895);
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            vertices[40] = new getPoints(48.54101966249685,0,10); 
            vertices[41] = new getPoints(42.3606797749979,-16.18033988749895,20); 
            vertices[42] = new getPoints(32.3606797749979,-10,36.18033988749895); 
            vertices[43] = new getPoints(32.3606797749979,10,36.18033988749895); 
            vertices[44] = new getPoints(42.3606797749979,16.18033988749895,20);
            
            vertices[45] = new getPoints(48.54101966249685,0,-10); 
            vertices[46] = new getPoints(42.3606797749979,16.18033988749895,-20); 
            vertices[47] = new getPoints(32.3606797749979,10,-36.18033988749895); 
            vertices[48] = new getPoints(32.3606797749979,-10,-36.18033988749895); 
            vertices[49] = new getPoints(42.3606797749979,-16.18033988749895,-20);
            //-----------------------------------------------------------------------------------
            vertices[50] = new getPoints(-48.54101966249685,0,10); 
            vertices[51] = new getPoints(-42.3606797749979,-16.18033988749895,20); 
            vertices[52] = new getPoints(-32.3606797749979,-10,36.18033988749895); 
            vertices[53] = new getPoints(-32.3606797749979,10,36.18033988749895); 
            vertices[54] = new getPoints(-42.3606797749979,16.18033988749895,20);
            
            vertices[55] = new getPoints(-48.54101966249685,0,-10); 
            vertices[56] = new getPoints(-42.3606797749979,16.18033988749895,-20); 
            vertices[57] = new getPoints(-32.3606797749979,10,-36.18033988749895); 
            vertices[58] = new getPoints(-32.3606797749979,-10,-36.18033988749895); 
            vertices[59] = new getPoints(-42.3606797749979,-16.18033988749895,-20);

            for(var i:uint = 0 ; i < vertices.length ; i++){
                vertices[i].setVanishingPoint(VP_X,VP_Y);
                vertices[i].SetCenter(0,0,200);
            }
            
            Planes = new Array();
            Planes[0] =  new HexaPointPlane(vertices[0],vertices[1],vertices[43],vertices[42],vertices[9],vertices[5],0xffffff);
            Planes[1] =  new HexaPointPlane(vertices[5],vertices[6],vertices[52],vertices[53],vertices[4],vertices[0],0xffffff);
            Planes[2] =  new HexaPointPlane(vertices[10],vertices[14],vertices[57],vertices[58],vertices[16],vertices[15],0xffffff);
            Planes[3] =  new HexaPointPlane(vertices[15],vertices[19],vertices[48],vertices[47],vertices[11],vertices[10],0xffffff);
            Planes[4] =  new HexaPointPlane(vertices[40],vertices[44],vertices[23],vertices[22],vertices[46],vertices[45],0xffffff);
            Planes[5] =  new HexaPointPlane(vertices[45],vertices[49],vertices[32],vertices[33],vertices[41],vertices[40],0xffffff);
            Planes[6] =  new HexaPointPlane(vertices[50],vertices[51],vertices[37],vertices[38],vertices[59],vertices[55],0xffffff);
            Planes[7] =  new HexaPointPlane(vertices[55],vertices[56],vertices[28],vertices[27],vertices[54],vertices[50],0xffffff);
            Planes[8] =  new HexaPointPlane(vertices[20],vertices[24],vertices[2],vertices[3],vertices[26],vertices[25],0xffffff);
            Planes[9] =  new HexaPointPlane(vertices[25],vertices[29],vertices[13],vertices[12],vertices[21],vertices[20],0xffffff);
            Planes[10] =  new HexaPointPlane(vertices[30],vertices[31],vertices[18],vertices[17],vertices[39],vertices[35],0xffffff);
            Planes[11] =  new HexaPointPlane(vertices[35],vertices[36],vertices[7],vertices[8],vertices[34],vertices[30],0xffffff);
            Planes[12] =  new HexaPointPlane(vertices[24],vertices[23],vertices[44],vertices[43],vertices[1],vertices[2],0xffffff);
            Planes[13] =  new HexaPointPlane(vertices[8],vertices[9],vertices[42],vertices[41],vertices[33],vertices[34],0xffffff);
            Planes[14] =  new HexaPointPlane(vertices[36],vertices[37],vertices[51],vertices[52],vertices[6],vertices[7],0xffffff);
            Planes[15] =  new HexaPointPlane(vertices[3],vertices[4],vertices[53],vertices[54],vertices[27],vertices[26],0xffffff);
            Planes[16] =  new HexaPointPlane(vertices[12],vertices[11],vertices[47],vertices[46],vertices[22],vertices[21],0xffffff);
            Planes[17] =  new HexaPointPlane(vertices[29],vertices[28],vertices[56],vertices[57],vertices[14],vertices[13],0xffffff);
            Planes[18] =  new HexaPointPlane(vertices[17],vertices[16],vertices[58],vertices[59],vertices[38],vertices[39],0xffffff);
            Planes[19] =  new HexaPointPlane(vertices[31],vertices[32],vertices[49],vertices[48],vertices[19],vertices[18],0xffffff);
           //
            Planes[20] =  new PentaPointPlane(vertices[0],vertices[4],vertices[3],vertices[2],vertices[1],0x000000);
            Planes[21] =  new PentaPointPlane(vertices[5],vertices[9],vertices[8],vertices[7],vertices[6],0x000000);
            Planes[22] =  new PentaPointPlane(vertices[10],vertices[11],vertices[12],vertices[13],vertices[14],0x000000);
            Planes[23] =  new PentaPointPlane(vertices[15],vertices[16],vertices[17],vertices[18],vertices[19],0x000000);
            Planes[24] =  new PentaPointPlane(vertices[20],vertices[21],vertices[22],vertices[23],vertices[24],0x000000);
            Planes[25] =  new PentaPointPlane(vertices[25],vertices[26],vertices[27],vertices[28],vertices[29],0x000000);
            Planes[26] =  new PentaPointPlane(vertices[30],vertices[34],vertices[33],vertices[32],vertices[31],0x000000);
            Planes[27] =  new PentaPointPlane(vertices[35],vertices[39],vertices[38],vertices[37],vertices[36],0x000000);
            Planes[28] =  new PentaPointPlane(vertices[40],vertices[41],vertices[42],vertices[43],vertices[44],0x000000);
            Planes[29] =  new PentaPointPlane(vertices[45],vertices[46],vertices[47],vertices[48],vertices[49],0x000000);
            Planes[30] =  new PentaPointPlane(vertices[50],vertices[54],vertices[53],vertices[52],vertices[51],0x000000);
            Planes[31] =  new PentaPointPlane(vertices[55],vertices[59],vertices[58],vertices[57],vertices[56],0x000000);
          
            var shadow : ShadoW = new ShadoW();
            for (var i = 0 ; i < Planes.length ; i++){
                Planes[i].shadow = shadow ; 
            }
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        private function onEnterFrame (event:Event):void {
            var ang_X : Number = (mouseY - VP_Y)* 0.001;
            var ang_Y : Number = (mouseX - VP_X)* 0.001;
           
            for (var i : uint = 0 ; i < vertices.length ; i++){
                var vertice:getPoints = vertices[i];
                vertice.rotx(ang_X);
                vertice.roty(ang_Y);
            }
            
            Planes.sortOn("depth", Array.DESCENDING | Array.NUMERIC);
            
            graphics.clear();
            for(i = 0; i < Planes.length; i++)
            {
                Planes[i].draw(graphics);
            }
        }
    }
}

class getPoints{
    private var VP_X:Number = 0;
    private var VP_Y:Number = 0;
    private var C_X:Number = 0;
    private var C_Y:Number = 0;
    private var C_Z:Number = 0;
    public var fl:Number = 10000;
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    
    public function getPoints(x:Number=0, y:Number=0, z:Number=0){
        this.x = x;
        this.y = y;
        this.z = z;
    }
    public function setVanishingPoint(VP_X:Number, VP_Y:Number):void
    {
        this.VP_X = VP_X;
        this.VP_Y = VP_Y;
    }
    
    public function SetCenter(C_X:Number, C_Y:Number, C_Z:Number=0):void
    {
        this.C_X = C_X;
        this.C_Y = C_Y;
        this.C_Z = C_Z;
    }
   
    public function get screenX():Number
    {
        var scale:Number = fl / (fl + z + C_Z);
        return VP_X + (C_X + x) * scale;
    }
    public function get screenY():Number
    {
        var scale:Number = fl / (fl + z + C_Z);
        return VP_Y + (C_Y + y) * scale;
    }
    public function rotx(ang_X:Number):void
    {
        var cos_X:Number = Math.cos(ang_X);
        var sin_X:Number = Math.sin(ang_X);
        var y1:Number = y * cos_X - z * sin_X;
        var z1:Number = z * cos_X + y * sin_X;

        y = y1;
        z = z1;
    }
    public function roty(ang_Y:Number):void
    {
        var cos_Y:Number = Math.cos(ang_Y);
        var sin_Y:Number = Math.sin(ang_Y);
        var x1:Number = x * cos_Y - z * sin_Y;
        var z1:Number = z * cos_Y + x * sin_Y;

        x = x1;
        z = z1;
    }
    public function rotz(ang_Z:Number):void
    {
        var cos_Z:Number = Math.cos(ang_Z);
        var sin_Z:Number = Math.sin(ang_Z);
        var x1:Number = x * cos_Z - y * sin_Z;
        var y1:Number = y * cos_Z + x * sin_Z;

        x = x1;
        y = y1;
    }
}
import flash.display.Graphics;
class HexaPointPlane {
    private var vertice_A:getPoints;
    private var vertice_B:getPoints;
    private var vertice_C:getPoints;
    private var vertice_D:getPoints;
    private var vertice_E:getPoints;
    private var vertice_F:getPoints;
    private var color:uint;
    public var shadow:ShadoW;
   
    public function HexaPointPlane(a:getPoints, b:getPoints, c:getPoints, d:getPoints , e:getPoints ,f:getPoints , color:uint)
    {
        vertice_A = a;
        vertice_B = b;
        vertice_C = c;
        vertice_D = d;
        vertice_E = e;
        vertice_F = f;
        this.color = color;
    }
    public function draw(g:Graphics):void
    {
        if(isBackFace())
        {
            return;
        }
        g.beginFill(getAdjustedColor());
        g.moveTo(vertice_A.screenX, vertice_A.screenY);
        g.lineTo(vertice_B.screenX, vertice_B.screenY);
        g.lineTo(vertice_C.screenX, vertice_C.screenY);
        g.lineTo(vertice_D.screenX, vertice_D.screenY);
        g.lineTo(vertice_E.screenX, vertice_E.screenY);
        g.lineTo(vertice_F.screenX, vertice_F.screenY);
        g.lineTo(vertice_A.screenX, vertice_A.screenY);
        g.endFill();
    }
    private function getAdjustedColor():uint
    {
        var red:Number = color >> 16;
        var green:Number = color >> 8 & 0xff;
        var blue:Number =color & 0xff;
        var lightFactor:Number = getLightFactor();
        red *= lightFactor;
        green *= lightFactor;
        blue *= lightFactor;
        return red << 16 | green << 8 | blue;
    }
    private function getLightFactor():Number
    {
        var ab:Object = new Object();
        ab.x = vertice_A.x - vertice_C.x;
        ab.y = vertice_A.y - vertice_C.y;
        ab.z = vertice_A.z - vertice_C.z;
        var bc:Object = new Object();
        bc.x = vertice_C.x - vertice_E.x;
        bc.y = vertice_C.y - vertice_E.y;
        bc.z = vertice_C.z - vertice_E.z;
        var norm:Object = new Object();
        norm.x = (ab.y * bc.z) - (ab.z * bc.y);
        norm.y = -((ab.x * bc.z) - (ab.z * bc.x));
        norm.z = (ab.x * bc.y) - (ab.y * bc.x);
        var dotProd:Number = norm.x * shadow.x + 
            norm.y * shadow.y + 
            norm.z * shadow.z;
        var normMag:Number = Math.sqrt(norm.x * norm.x + 
            norm.y * norm.y +
            norm.z * norm.z);
        var shadowMagnitude:Number = Math.sqrt(shadow.x * shadow.x +
            shadow.y * shadow.y +
            shadow.z * shadow.z);
        return (((Math.acos(dotProd / (normMag * shadowMagnitude)) / Math.PI)
        * shadow.darkness)*0.4)+.6;
    }
    private function isBackFace():Boolean
    {
        var cax:Number = vertice_F.screenX - vertice_A.screenX;
        var cay:Number = vertice_F.screenY - vertice_A.screenY;
        var bcx:Number = vertice_C.screenX - vertice_F.screenX;
        var bcy:Number = vertice_C.screenY - vertice_F.screenY;
        return cax * bcy > cay * bcx;
    }
    public function get depth():Number
    {
        var Z_pos:Number = Math.min(vertice_A.z,vertice_B.z);
        Z_pos = Math.min(Z_pos, vertice_C.z);
        return Z_pos;
    }
}
import flash.display.Graphics;
class PentaPointPlane {
    private var vertice_A:getPoints;
    private var vertice_B:getPoints;
    private var vertice_C:getPoints;
    private var vertice_D:getPoints;
    private var vertice_E:getPoints;
    //    private var vertice_F:getPoints;
    private var color:uint;
    public var shadow:ShadoW;
    public function PentaPointPlane(a:getPoints, b:getPoints, c:getPoints, d:getPoints , e:getPoints , color:uint)
    {
        vertice_A = a;
        vertice_B = b;
        vertice_C = c;
        vertice_D = d;
        vertice_E = e;
        //    vertice_F = f;
        this.color = color;
    }
    public function draw(g:Graphics):void
    {
        if(isBackFace())
        {
            return;
        }
        g.beginFill(getAdjustedColor());
        g.moveTo(vertice_A.screenX, vertice_A.screenY);
        g.lineTo(vertice_B.screenX, vertice_B.screenY);
        g.lineTo(vertice_C.screenX, vertice_C.screenY);
        g.lineTo(vertice_D.screenX, vertice_D.screenY);
        g.lineTo(vertice_E.screenX, vertice_E.screenY);
        //    g.lineTo(vertice_F.screenX, vertice_F.screenY);
        g.lineTo(vertice_A.screenX, vertice_A.screenY);
        g.endFill();
    }
    private function getAdjustedColor():uint
    {
        var red:Number = color >> 16;
        var green:Number = color >> 8 & 0xff;
        var blue:Number =color & 0xff;
        var lightFactor:Number = getLightFactor();
        red *= lightFactor;
        green *= lightFactor;
        blue *= lightFactor;
        return red << 16 | green << 8 | blue;
    }
    private function getLightFactor():Number
    {
        var ab:Object = new Object();
        ab.x = vertice_A.x - vertice_C.x;
        ab.y = vertice_A.y - vertice_C.y;
        ab.z = vertice_A.z - vertice_C.z;
        var bc:Object = new Object();
        bc.x = vertice_C.x - vertice_D.x;
        bc.y = vertice_C.y - vertice_D.y;
        bc.z = vertice_C.z - vertice_D.z;
        var norm:Object = new Object();
        norm.x = (ab.y * bc.z) - (ab.z * bc.y);
        norm.y = -((ab.x * bc.z) - (ab.z * bc.x));
        norm.z = (ab.x * bc.y) - (ab.y * bc.x);
        var dotProd:Number = norm.x * shadow.x + 
            norm.y * shadow.y + 
            norm.z * shadow.z;
        var normMag:Number = Math.sqrt(norm.x * norm.x + 
            norm.y * norm.y +
            norm.z * norm.z);
        var shadowMagnitude:Number = Math.sqrt(shadow.x * shadow.x +
            shadow.y * shadow.y +
            shadow.z * shadow.z);
        return (Math.acos(dotProd / (normMag * shadowMagnitude)) / Math.PI)
        * shadow.darkness;
    }
    private function isBackFace():Boolean
    {
        var cax:Number = vertice_D.screenX - vertice_A.screenX;
        var cay:Number = vertice_D.screenY - vertice_A.screenY;
        var bcx:Number = vertice_C.screenX - vertice_D.screenX;
        var bcy:Number = vertice_C.screenY - vertice_D.screenY;
        return cax * bcy > cay * bcx;
    }
    public function get depth():Number
    {
        var Z_pos:Number = Math.min(vertice_A.z,vertice_B.z);
        Z_pos = Math.min(Z_pos, vertice_C.z);
        return Z_pos;
    }
}
class ShadoW
{
    public var x:Number;
    public var y:Number;
    public var z:Number;
    private var _darkness:Number;
    public function ShadoW(x:Number = 100, y:Number = 100, z:Number = 100, darkness:Number = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.darkness = darkness;
    }
     public function set darkness(b:Number):void
    {
        _darkness = Math.max(b, 1);
        _darkness = Math.min(_darkness, 1);
    }
     public function get darkness():Number
    {
        return _darkness;
    }
}