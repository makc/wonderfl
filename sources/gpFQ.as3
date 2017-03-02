// forked from Vladik's Flash to Hex ( Coordiante system )
package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    
    public class FlashTest extends Sprite
    {
        private var axis:AXIS_HEX;
        
        private var a:HEX;
        
        private var t:T;
        
        public function FlashTest()
        {
            axis = new AXIS_HEX();
            addChild( axis );
            
            t = new T();
            addChild(t);
            t.multiline = true;
            t.x = t.y = 20;
            
            a = new HEX(0,0,0);
            
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function loop(e:Event):void 
        {
            axis.graphics.clear();
            
            a.x = mouseX;
            a.y = mouseY;
            
            a.render( axis.graphics, 30, 0xEA382F );
            
            
            var p:Point = new Point(a.x - axis.convas.x, a.y - axis.convas.y);
            //
            //var cX:Number = axis.lineX.V.distToPoint( p );
            //var cY:Number = axis.lineY.V.distToPoint( p );
            //var cZ:Number = axis.lineZ.V.distToPoint( p );
            //
            //
            //var cX:Number = axis.lineX.V.projection( Vec.P2V( p ) ).lenght;
            //var cY:Number = axis.lineY.V.projection( Vec.P2V( p ) ).lenght;
            //var cZ:Number = axis.lineZ.V.projection( Vec.P2V( p ) ).lenght;
            //
            
            var cVX:Vec = axis.lineX.V.clone();
            
            var cVXp:Vec = Vec.PallarelProjection(cVX, Vec.P2V( p ));
            var cVXd:Number = cVX.dot(cVXp);
            
            var cVY:Vec = axis.lineY.V.clone();
            var cVYp:Vec = Vec.PallarelProjection(cVY, Vec.P2V( p ));
            var cVYd:Number = cVY.dot(cVYp);
            
            var cVZ:Vec = axis.lineZ.V.clone();
            var cVZp:Vec = Vec.PallarelProjection(cVZ, Vec.P2V( p ));
            var cVZd:Number = cVZ.dot(cVZp);
            
            var cX:Number = cVXp.lenght;
            var cY:Number = cVYp.lenght;
            var cZ:Number = cVZp.lenght;
            
            //if ( cVXp.degrees == -180 ) cX = -Math.abs(cX); // Can be used
            if ( cVXd < 0 ) cX = -Math.abs(cX);
            if ( cVYd < 0 ) cY = -Math.abs(cY);
            if ( cVZd < 0 ) cZ = -Math.abs(cZ);
            
            t.text =     "CUBE X: " + cX.toFixed(2) + 
                        "\nCUBE Y: " + cY.toFixed(2) +  
                        "\nCUBE Z: " + cZ.toFixed(2) + 
                        "\n CUBE SUM: " + (cX + cY + cZ).toFixed(2) +
                        "\n\nCart X: " + p.x.toFixed(2) + 
                        "\nCart Y: " + p.y.toFixed(2);
                        //"\n Test:\n" + Vec.RadiansBetween( axis.lineX.V, axis.lineY.V )
                        //"\n" + cVY.degrees.toFixed(2);
                        
                        //"\n Test:\n" + (axis.lineY.V.dot( axis.lineX.V )/ (axis.lineX.V.lenght + axis.lineY.V.lenght)).toFixed(2);
                        
                        
                        
                            //Math.acos( A.dot(B) / ( A.lenght + B.lenght )
                        
                            //Vec.RadiansBetween( axis.lineX.V, axis.lineY.V ).toFixed(2);
        }
        
        
    }
}
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;


class AXIS_HEX extends Sprite
{
    public var lineX:Line;
    public var lineY:Line;
    public var lineZ:Line;
    
    
    private var GIRD:HEX_GIRD;
    
    public var convas:Shape = new Shape();
    
    public function AXIS_HEX():void
    {
        //GIRD = new HEX_GIRD(465, 465, 10);
        //GIRD.alpha = 0.5;
        //addChild( GIRD );
        
        addChild( convas );
        
        convas.x = 465 / 2;
        convas.y = 465 / 2;
        
        var v:Vec = new Vec(200, 0);
        var p:Point = new Point();
        
        lineX = new Line(p, v);
        lineX.render( convas.graphics, 0x367BE2 );
        
        v.degrees += 120;
        
        lineY = new Line(p, v);
        lineY.render( convas.graphics, 0x52D643 );
        
        v.degrees += 120;
        
        lineZ = new Line(p, v);
        lineZ.render( convas.graphics, 0xEB9F2E );
    }
    
}

class HEX 
{
    public var z:Number;
    public var y:Number;
    public var x:Number;
    public function HEX(x:Number, y:Number, z:Number)
    {
        this.z = z;
        this.y = y;
        this.x = x;
        
    }
    public function render(g:Graphics, size:Number, line:Number = NaN, fill:Number = NaN):void
    {
        if ( isNaN( line ) && isNaN( fill ) ) return;
        
        var v:Vec = new Vec(size, 0);
        var p:Point = this.p;
        
        if ( !isNaN( line ) ) g.lineStyle( 2, line );
        if ( !isNaN( fill ) ) g.beginFill( fill );
        
        g.moveTo( p.x + size, p.y );
        var i:int = 0;
        while ( i < 6 )
        {
            i++;
            
            v.degrees += 60;
            
            g.lineTo( p.x + v.x, p.y + v.y );
        }
        
        if ( !isNaN( fill ) ) g.endFill();
        
    }
    public function get p():Point
    {
        return new Point( x, y );
    }
}

class HEX_GIRD extends Shape
{
    public function HEX_GIRD( w:Number , h:Number, size:Number = 10, origin:Point = null, color:uint = 0x333333, alpha:Number = 0.5, thikness:Number = 1) 
    {
        if ( origin == null ) origin = new Point(w / 2, h / 2);
        
        var v:Vec = new Vec(w * 2, 0);
        
        graphics.lineStyle( thikness, color );
        
        // PLOT X
        
        var pos:Number = origin.y;
        
        var sizeH:Number = Math.sqrt( 3 ) * size / 2;
        
        while ( pos < h )
        {
            graphics.moveTo(0, pos);
            graphics.lineTo(w, pos);
            
            pos += sizeH;
        }
        
        pos = origin.y - sizeH;
        
        while ( pos > 0 )
        {
            graphics.moveTo(0, pos);
            graphics.lineTo(w, pos);
            
            pos -= sizeH;
        }
        
        v.degrees += 120;
        
        // PLOT Y
        
        pos = origin.x;
        
        while ( pos < w * 2 )
        {
            graphics.moveTo( pos, 0 );
            graphics.lineTo( pos + v.x, v.y );
            
            pos += size;
        }
        
        pos = origin.x - size;
        
        while ( pos > -w )
        {
            graphics.moveTo( pos, 0 );
            graphics.lineTo( pos + v.x, v.y );
            
            pos -= size;
        }
        
        pos = origin.x;
        
        v.degrees += 120;
        
        while ( pos < w * 2 )
        {
            graphics.moveTo( pos, h );
            graphics.lineTo( pos + v.x, v.y );
            
            pos += size;
        }
        
        pos = origin.x - size;
        
        while ( pos > -w )
        {
            graphics.moveTo( pos, h );
            graphics.lineTo( pos + v.x, v.y );
            
            pos -= size;
        }
        
        
    }
}

class Line
{
    
    /** @author http://wonderfl.net/user/Vladik */
    
    public var O:Point;
    public var V:Vec;
    
    public function get A():Point{return O.clone();}
    public function get B():Point{return new Point(O.x + V.x, O.y + V.y);}
    
    public function get m():Number {return ( B.y - A.y ) / ( B.x - A.x );}
    public function get c():Number{return A.y - A.x * m;}
    
    public function Fx(x:Number):Number{return x * m + c;}
    
    public function Line(O:Point, V:Vec)
    {
        this.O = O.clone();
        this.V = V.clone();
    }
    public function render( g:Graphics, color:uint = 0xFF0000, thikness:uint = 3 ):void
    {
        g.beginFill( color );
        g.lineStyle( thikness, color);
        g.moveTo( O.x, O.y);
        
        var B:Point = this.B;
        
        g.lineTo( B.x, B.y);
        
        var v:Vec = Vec.PP2V( O, B );
        v.lenght = 5;
        
        v.degrees -= 45 + 180;
        g.lineTo( B.x + v.x, B.y + v.y );
        
        v.degrees += 90;
        g.lineTo( B.x + v.x, B.y + v.y );
        
        g.lineTo( B.x, B.y );
        
        g.endFill();
    }
    
}

class P 
{
    public var x:Number;
    public var y:Number;
    
    
    public function P(x:Number, y:Number)
    {
        this.x = x;
        this.y = y;
    }
    
    public function render( g:Graphics, color:uint = 0x89CF49 ):void
    {
        g.beginFill(color);
        g.drawCircle(x, y, 7);
        g.endFill();
    }
}

class Vec
{
    // Convert a line between two point into a vector
    static public function PP2V(a:Point, b:Point):Vec{return new Vec(b.x - a.x, b.y - a.y);}
    // Convert line 2 point
    static public function P2V(p:Point):Vec{return new Vec(p.x,p.y);}
    
    // Angle between two vectors in radians
    static public function RadiansBetween( A:Vec, B:Vec):Number
    {
        return Math.acos( A.clone().normalise().dot( B.clone().normalise() ) );
        //return Math.acos( A.dot(B) / ( A.lenght + B.lenght );
    }
    
    // Example: http://wonderfl.net/c/4Zft
    static public function PallarelProjection( V:Vec, U:Vec ):Vec
    {
        return V.projection(U);
    }
    
    
    /** @author http://wonderfl.net/user/Vladik */
    public var x:Number, y:Number;
    public function Vec(x:Number = 0, y:Number = 0){this.x = x;this.y = y;}
    public function get lenght():Number{return Math.sqrt(x * x + y * y);}
    public function set lenght(value:Number):void{lenght == 0 ? scale(0) : scale(value / lenght);}
    public function set degrees(value:Number):void{radians = value * Math.PI / 180;}
    public function get degrees():Number{return radians * 180 / Math.PI;}
    public function set radians(value:Number):void{var f:Number = lenght;x = Math.cos(value) * f;y = Math.sin(value) * f;}
    public function scale(n:Number):Vec { x *= n; y *= n; return this; }
    public function clone():Vec{return new Vec(x, y);}
    public function get radians():Number { return Math.atan2(y, x); }
    public function dot( v:Vec ):Number { return x * v.x + y * v.y; }
    public function get point():Point { return new Point(x, y); }
    //Projection method credits: http://jccc-mpg.wikidot.com/vector-projection
    public function projection( u:Vec ):Vec{var l:Number = lenght;return clone().scale( u.dot( this ) / (l * l) );}
    public function normalise():Vec{scale(1);return this;}
    public function distToPoint( p:Point ):Number {return p.length * Math.sin( Vec.RadiansBetween( this, Vec.P2V(p) ) );}
    public function render( g:Graphics, o:Point = null, color:uint = 0xFF0000, thikness:uint = 3 ):void
    {g.beginFill( color );g.lineStyle( thikness, color);g.moveTo( o.x, o.y);var B:Point = new Point(o.x + x, o.y + y);g.lineTo( B.x, B.y);
    var v:Vec = Vec.PP2V( o, B );v.lenght = 7;v.degrees -= 45 + 180;g.lineTo( B.x + v.x, B.y + v.y );
    v.degrees += 90;g.lineTo( B.x + v.x, B.y + v.y );g.lineTo( B.x, B.y );g.endFill();}
    public function add( V:Vec ):Vec{this.x += V.x;this.y += V.y;return this;}
    public function subtract(V:Vec):Vec { this.x -= V.x; this.y -= V.y; return this; }
    public function toString():String{return "["+x.toFixed(2)+","+y.toFixed(2)+"]";}
}

class T extends TextField
{
    /** @author http://wonderfl.net/user/Vladik */
    public function T(txt:String = "Text", x:Number = 0, y:Number = 0)
    {
        var tf:TextFormat = new TextFormat("_sans", 12, 0x000000);
        this.setTextFormat(tf);
        this.defaultTextFormat = tf;
        this.autoSize = 'left';
        this.text = txt;
        this.selectable = this.wordWrap = this.multiline = this.mouseEnabled = false;
        
        this.x = x - this.width / 2;
        this.y = y - this.height / 2;
    }

}