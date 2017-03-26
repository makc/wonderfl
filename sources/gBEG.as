//
//    ColorfulRiver
//        流れていく色の帯を堪能しようず
//
package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    
    [SWF(width="465",height="465")]
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        private var _lines:/*LineObj*/Array;
        private var _sprite:Sprite;
        private var _bmd:BitmapData;
        
        private var _ct:int;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            graphics.beginFill(0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            
            _bmd = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
            addChild( new Bitmap(_bmd) );
            
            _sprite = new Sprite();
            _sprite.blendMode = "add";
            addChild( _sprite );
            
            
            _lines = new Array();
            _ct = 0;
            GenerationLine();
            
            addEventListener( Event.ENTER_FRAME, Update );
        }
        
        private function GenerationLine() : void
        {
            var line:LineObj = new LineObj();
            var angle:Number = Math.random() * 360;
            var speed:Number = 10 + Math.random() * 10;
            var moveangle:Number = Math.atan2( (stage.stageHeight / 2 - stage.mouseY), (stage.stageWidth / 2  - stage.mouseX) );
            moveangle = moveangle * 180 / Math.PI;
            line.Shoot( stage.mouseX, stage.mouseY, angle, speed, moveangle, 1 );
            
            _lines[_lines.length] = line;
        }
        
        private function Update(e:Event) : void
        {
            var i:int = 0;
            
            _ct++;
            if ( _ct % 3 == 0 )
            {
                GenerationLine();
            }
            
            
            for ( i = _lines.length - 1; i >= 0; i-- )
            {
                if ( !_lines[i].Update() )
                {
                    _lines.splice( i, 1 );
                }
            }
            
            _sprite.graphics.clear();
            for ( i = 0; i < _lines.length; i++ )
            {
                _lines[i].Draw( _sprite.graphics );
            }
            
            _bmd.draw( _sprite );
            _bmd.applyFilter( _bmd, _bmd.rect, new Point(), new BlurFilter(8,8,3) );
            
        }
    }
    
}
import flash.display.Graphics;
import flash.geom.Point;
import flash.display.Sprite;
import frocessing.color.ColorHSV;

class Path {
    private var _x:Number;
    private var _y:Number;
    private var _angle:Number;
    private var _step:int;
    
    public function get x():Number { return _x;    }
    public function set x(val:Number) : void { _x = val;    }
    public function get y():Number { return _y;    }
    public function set y(val:Number) : void { _y = val;    }
    public function get angle():Number { return _angle; }
    public function set angle(val:Number) : void { _angle = val;    }
    public function get step():int { return _step;    }
    
    public function Path() {
        _step = 0;
    }
    
    public function Copy( obj:Path ) : void
    {
        _x = obj.x;
        _y = obj.y;
        _angle = obj.angle;
        _step = obj.step;
    }
    
    public function Set( x:Number, y:Number, angle:Number ) : void
    {
        _x = x;
        _y = y;
        _angle = angle;
    }
    
    public function Step() : void { _step++;    }
}

class LineObj {
    
    private var _pos:Point;
    private var _move:Point;
    private var _power:Point;
    
    private var _path:/*Path*/Array;
    private static const PATH_NUM:int = 30;
    
    private var _geneCt:int;
    private var _color:ColorHSV;
    
    public function LineObj() {
        
    }
    
    public function Shoot(x:Number, y:Number, angle:Number, speed:Number, moveangle:Number, movepower:Number) : void
    {
        _pos = new Point(x, y);
        _move = new Point( Math.cos( angle * Math.PI / 180 ) * speed, Math.sin( angle * Math.PI / 180 ) * speed );
        _power = new Point( Math.cos( moveangle * Math.PI / 180 ) * movepower, Math.sin( moveangle * Math.PI / 180 ) * movepower );
    
        _path = new Array();
        _path[0] = new Path();
        _path[0].Set( x, y, angle );
        
        _geneCt = 0;
        
        _color = new ColorHSV( Math.random() * 360, 1, 1, 0.5 );
    }
    
    public function Update() : Boolean
    {
        _move.x += _power.x;
        _move.y += _power.y;
        _pos.x += _move.x;
        _pos.y += _move.y;
                
        // Add Path
        if ( _geneCt < PATH_NUM )
        {
            var path:Path = new Path();
            path.Copy( _path[_path.length - 1] );
            _path[_path.length] = path;
            _geneCt++;
        }
        //    Copy
        for ( var i:int = _path.length - 1; i >= 1; i-- )
        {
            _path[i].Copy( _path[i - 1] );
        }
        if ( _path.length > 0 )
        {
            _path[0].x += _move.x;
            _path[0].y += _move.y;
            _path[0].Step();
        }
        //    Delete
        if ( _path[0].step == 100 )
        {
            _path.splice( 0, 1 );
        }
        
        if ( _path.length == 0 )    return    false;
        return    true;
    }
    
    public function Draw( g:Graphics ) : void
    {
        if ( _path.length == 0 ) return;
        
        var i:int;
        var x:Number;
        var y:Number;
        g.beginFill( _color.value, _color.a );
        x = Math.cos((_path[0].angle - 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
        y = Math.sin((_path[0].angle - 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
        g.moveTo( x + _path[0].x, y + _path[0].y );
        for ( i = 1; i < _path.length; i++ )
        {
            //    Left
            x = Math.cos((_path[i].angle - 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
            y = Math.sin((_path[i].angle - 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
            g.lineTo( x + _path[i].x, y + _path[i].y );
        }
        for ( i = _path.length - 1; i >= 0; i-- )
        {
            //    Right
            x = Math.cos((_path[i].angle + 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
            y = Math.sin((_path[i].angle + 90) * Math.PI / 180 ) * (2 + _path[i].step * 2);
            g.lineTo( x + _path[i].x, y + _path[i].y );
        }
        g.endFill();
    }
    
    
}
