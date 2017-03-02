package 
{
    import adobe.utils.CustomActions;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;

    [SWF(width = "465", height = "465", frameRate = "60")]
  
    public class Main extends Sprite
    {
        public static const WIDTH:int = 465;
        public static const HEIGHT:int = 465; 
          
        private var ball:Ball;
        private var drag:Boolean = false;

        private var canvas:BitmapData;
        
        public function Main()
        {
          if(stage) init();
          else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event=null):void
        {
              removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            graphics.beginFill(0);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            ball = new Ball();
            ball.x = WIDTH / 2;
            ball.y = HEIGHT / 2;
            
            canvas = new BitmapData(WIDTH, HEIGHT, true, 0);
            addChild( new Bitmap(canvas) );
            
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
            stage.addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
            stage.addEventListener( MouseEvent.MOUSE_UP, MouseUp );
            trace( -10 % 100 );
        }
        
        private function MouseDown( e:MouseEvent ) : void
        {
            drag = true;
        }
        
        private function MouseUp( e:MouseEvent ) : void
        {
            drag = false;
        }

        private function EnterFrameHandler( e:Event ) : void
        {
            var i:int, j:int;

            ball.Update( stage.mouseX, stage.mouseY, drag );
            
            //    描画
            canvas.lock();
            canvas.fillRect(canvas.rect, 0);
            
            var points:Vector.<Point> = GetPointList();
            
            for ( i = 1; i < points.length; i++ )
            {
                var p0:Point = points[i - 1];
                var p1:Point = points[i];
                BresenhamDraw( p0, p1, canvas );
            }
            
            canvas.unlock();
            
        }
        
        /**
         * p1からp2の間の値を取る
         * @param    p0
         * @param    p1
         * @param    p2
         * @param    p3
         * @param    t
         * @return
         */
        public function catmullRom(p0:Point, p1:Point, p2:Point, p3:Point, t:Number ) : Point 
        {
            var point:Point = new Point();
            
            var v0:Number = (p2.x - p0.x) * 0.5;
            var v1:Number = (p3.x - p1.x) * 0.5;
            point.x = (2*p1.x - 2*p2.x + v0 + v1)*t*t*t + (-3*p1.x + 3*p2.x - 2*v0 - v1)*t*t + v0*t + p1.x;
            
            
            v0 = (p2.y - p0.y) * 0.5;
            v1 = (p3.y - p1.y) * 0.5;  
            point.y = (2*p1.y - 2*p2.y + v0 + v1)*t*t*t + (-3*p1.y + 3*p2.y - 2*v0 - v1)*t*t + v0*t + p1.y;
            
            return    point;
        }
        
        /**
         * 現在のPathから描画用のキーポイントを作成して返す
         * @return
         */
        private function GetPointList() : Vector.<Point>
        {
            var list:Vector.<Point> = new Vector.<Point>();
            
            for ( var i:int = 0; i < ball.paths.length - 3; i++ )
            {
                var p0:Point = ball.GetPathPoint(i);
                var p1:Point = ball.GetPathPoint(i+1);
                var p2:Point = ball.GetPathPoint(i+2);
                var p3:Point = ball.GetPathPoint(i+3);
                
                trace(p0.x, p0.y);
                
                for ( var j:int = 0; j < 20; j++ )
                {
                    list.push( catmullRom(p0, p1, p2, p3, (j+1) / 20) );
                }
            }
            
            return    list;
        }
        
        private function BresenhamDraw( p1:Point, p2:Point, canvas:BitmapData ) : void
        {
            var x1:int, y1:int, x2:int, y2:int;
            var dx:int, dy:int;
            var rev:Boolean = Math.abs( p2.y - p1.y ) > Math.abs( p2.x - p1.x );
            if ( rev )
            {
                x1 = p1.y;
                y1 = p1.x;
                x2 = p2.y;
                y2 = p2.x;
            }else
            {
                x1 = p1.x;
                y1 = p1.y;
                x2 = p2.x;
                y2 = p2.y;                
            }
            
            if ( x2 < x1 )
            {
                var tmp:int = x1;
                x1 = x2;
                x2 = tmp;
                
                tmp = y1;
                y1 = y2;
                y2 = tmp;
            }
            
            dx = x2 - x1;
            dy = y2 - y1;
            var minus:Boolean = false;
            var step:int = 1;
            if ( dy < 0 )
            {
                dy *= -1;
                step = -1;
            }            
            var e:Number = (( rev ) ? dy : dx) / 2;
            
            var x:int = x1, y:int = y1;
            for ( x = x1; x <= x2; x++ )
            {
                if ( rev )    canvas.setPixel32( y, x, 0xFFFFFFFF );
                else        canvas.setPixel32( x, y, 0xFFFFFFFF );
                
                e = e - dy;
                if ( e < 0 )
                {
                    y = y + step;
                    e = e + dx;
                }
            }            
        }
    }
    
}

import flash.geom.Point;

class Path {
    private var _x:Number = 0;
    private var _y:Number = 0;
    private var _viewX:Number;
    private var _viewY:Number;
    
    public var angle:Number;
    public var tmpA:Number = 1;
    public var tmpB:Number = 1;
    public var speedRotation:Number;
    
    public function Path() {
        
        angle = Math.random() * 360;
        speedRotation = Math.random() * 4 - 2;

        var sin:Number = Math.sin( angle * Math.PI / 180 );
        var cos:Number = Math.cos( angle * Math.PI / 180 );
        
        _viewX = _x = cos * 150;
        _viewY = _y = sin * 150;        
    }
    
    public function Move(tx:Number, ty:Number, drag:Boolean) : void
    {
        var rad:Number = angle * Math.PI / 180;
        var sin:Number = Math.sin( rad );
        var cos:Number = Math.cos( rad );
        
        _x = cos * 150;
        _y = sin * 150;
        
        if ( drag )
        {
            _viewX += (tx - _viewX) * 0.5;
            _viewY += (ty - _viewY) * 0.5;
        }else
        {
            _viewX += (_x - _viewX) * 0.5;
            _viewY += (_y - _viewY) * 0.5;
        }
        
        angle = (angle + speedRotation) % 360;
    }
    
    public function get x() : Number {
        return    _viewX;
    }
    
    public function get y() : Number {
        return    _viewY;
    }
}



class Ball {
    private static const NUMPATH:int = 100;
    public var x:Number;
    public var y:Number;
    public var paths:Vector.<Path>;
    public var pathsPoint:Vector.<Point>;
    
    private var dragCt:Number = 0;
    
    public function Ball() {
        
        paths = new Vector.<Path>();
        pathsPoint = new Vector.<Point>();
            
        for ( var i:int = 0; i < NUMPATH; i++ )
        {
            var path:Path = new Path();
            paths.push( path );
            pathsPoint.push( new Point() );
        }
        paths.splice(0, 0, paths[0]);
        paths.push(paths[paths.length - 1]);
        
        pathsPoint.push( new Point() );
        pathsPoint.push( new Point() );
    }
    
    public function Update(mouseX:Number, mouseY:Number, drag:Boolean) : void
    {
        var i:int;
            
        if ( drag )    Drag();
        else         Drop();
        
        //    パス移動
        for ( i = 1; i < paths.length - 1; i++ )
        {
            paths[i].Move(mouseX-x, mouseY-y, (dragCt > i) );
        }    
    }
    
    public function Drag() : void
    {
        dragCt += 0.5;
        if ( dragCt >= paths.length )    dragCt = paths.length;
    }
    
    public function Drop() : void
    {
        dragCt -= 0.5;
        if ( dragCt <= 0 )    dragCt = 0;
    }
    
    public function GetPathPoint( i:int ) : Point {
        pathsPoint[i].x = paths[i].x + x;
        pathsPoint[i].y = paths[i].y + y;
        return    pathsPoint[i]
    }
}

