package
{
    import flash.display.Sprite;
    import flash.events.Event;
  
    public class Icosohedron extends Sprite
    {
        private var vertices:Array;
        private var fl:Number = 4000;
        private var VP_X:Number = stage.stageWidth / 2;
        private var VP_Y:Number = stage.stageHeight / 2;
        private var Planes:Array;
        public function Icosohedron()
        {
            initIcosohedron();
        }
      
        private function initIcosohedron():void

        {
            //stage.scaleMode = StageScaleMode.NO_SCALE;
            vertices = new Array();
            vertices[0] = new getPoints(0,0,40);
            vertices[1] = new getPoints(35.76,0,17.8);
            vertices[2] = new getPoints(11.04,34.04,17.8);
            vertices[3] = new getPoints(-28.96,21.04,17.8);
            vertices[4] = new getPoints(-28.96,-21.05,17.8);
            vertices[5] = new getPoints(11.04,-34.04,17.8); 
            vertices[6] = new getPoints(28.96,21.04,-17.8); 
            vertices[7] = new getPoints(-11.04,34.04,-17.8); 
            vertices[8] = new getPoints(-35.76,0,-17.8); 
            vertices[9] = new getPoints(-11.04,-34.04,-17.8);
            vertices[10] = new getPoints(28.96,-21.05,-17.8);
            vertices[11] = new getPoints( 0, 0, -40); 
          
            for(var i:uint = 0 ; i < vertices.length ; i++){
                vertices[i].setVanishingPoint(VP_X,VP_Y);
                vertices[i].SetCenter(0,0,200);
            }
           
            Planes = new Array();
            Planes[0] =  new ThreePointPlane(vertices[0],vertices[1],vertices[2],0x33cc44);
            Planes[1] =  new ThreePointPlane(vertices[0],vertices[2],vertices[3],0x33cc44);
            Planes[2] =  new ThreePointPlane(vertices[0],vertices[3],vertices[4],0x33cc44);
            Planes[3] =  new ThreePointPlane(vertices[0],vertices[4],vertices[5],0x33cc44);
            Planes[4] =  new ThreePointPlane(vertices[0],vertices[5],vertices[1],0x33cc44);
            Planes[5] =  new ThreePointPlane(vertices[5],vertices[10],vertices[1],0x33cc44);
            Planes[6] =  new ThreePointPlane(vertices[1],vertices[10],vertices[6],0x33cc44);
            Planes[7] =  new ThreePointPlane(vertices[2],vertices[1],vertices[6],0x33cc44);
            Planes[8] =  new ThreePointPlane(vertices[2],vertices[6],vertices[7],0x33cc44);
            Planes[9] =  new ThreePointPlane(vertices[3],vertices[2],vertices[7],0x33cc44);
            Planes[10] =  new ThreePointPlane(vertices[3],vertices[7],vertices[8],0x33cc44);
            Planes[11] =  new ThreePointPlane(vertices[4],vertices[3],vertices[8],0x33cc44);
            Planes[12] =  new ThreePointPlane(vertices[4],vertices[8],vertices[9],0x33cc44);
            Planes[13] =  new ThreePointPlane(vertices[4],vertices[9],vertices[5],0x33cc44);
            Planes[14] =  new ThreePointPlane(vertices[5],vertices[9],vertices[10],0x33cc44);
            Planes[15] =  new ThreePointPlane(vertices[10],vertices[11],vertices[6],0x33cc44);
            Planes[16] =  new ThreePointPlane(vertices[6],vertices[11],vertices[7],0x33cc44);
            Planes[17] =  new ThreePointPlane(vertices[7],vertices[11],vertices[8],0x33cc44);
            Planes[18] =  new ThreePointPlane(vertices[8],vertices[11],vertices[9],0x33cc44);
            Planes[19] =  new ThreePointPlane(vertices[9],vertices[11],vertices[10],0x33cc44);
           
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
class ThreePointPlane {
    private var vertice_A:getPoints;
    private var vertice_B:getPoints;
    private var vertice_C:getPoints;
    private var color:uint;
    public var shadow:ShadoW;
    public function ThreePointPlane(a:getPoints, b:getPoints, c:getPoints, color:uint)
    {
        vertice_A = a;
        vertice_B = b;
        vertice_C = c;
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
        g.lineTo(vertice_A.screenX, vertice_A.screenY);
        g.endFill();
    }
    
    private function getAdjustedColor():uint
    {
        var red:Number = color >> 16;
        var green:Number = color >> 8 & 0xff;
        var blue:Number =color & 0xff;
        var shadowFactor:Number = getShadoWFactor();

        red *= shadowFactor;
        green *= shadowFactor;
        blue *= shadowFactor;
        
        return red << 16 | green << 8 | blue;

    }

    

    private function getShadoWFactor():Number
    {
        var ab:Object = new Object();
        ab.x = vertice_A.x - vertice_B.x;
        ab.y = vertice_A.y - vertice_B.y;
        ab.z = vertice_A.z - vertice_B.z;
       
        var bc:Object = new Object();
        bc.x = vertice_B.x - vertice_C.x;
        bc.y = vertice_B.y - vertice_C.y;
        bc.z = vertice_B.z - vertice_C.z;
       
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
        
        var cax:Number = vertice_C.screenX - vertice_A.screenX;
        var cay:Number = vertice_C.screenY - vertice_A.screenY;
        var bcx:Number = vertice_B.screenX - vertice_C.screenX;
        var bcy:Number = vertice_B.screenY - vertice_C.screenY;
        
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