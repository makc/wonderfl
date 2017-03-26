package{
    import flash.events.*;
    import flash.text.*;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.utils.*;
    import flash.display.*;
    import flash.events.MouseEvent;
    import mx.controls.Label;

    public class test extends Sprite {        
        public var isdrawing:int;
        public var lines_array:Array = new Array();
        public var cnt:int;

        public function test() {
            isdrawing = 0;
            cnt = 0;
            this.stage.addEventListener( MouseEvent.MOUSE_DOWN , onMouseDown );
            this.stage.addEventListener( MouseEvent.MOUSE_UP , onMouseUp );
            this.stage.addEventListener( MouseEvent.MOUSE_MOVE , onMouseMove );
            addEventListener( Event.ENTER_FRAME , onIdle );

            cnt = 1;
            lines_array.push( new lines() );
            lines_array[0].push( 10 , 10 );
            lines_array[0].push( 20 , 20 );

            cnt = 2;
            lines_array.push( new lines() );
            lines_array[1].push( 30 , 30 );
            lines_array[1].push( 40 , 40 );
        }

        public function onIdle( e:Event ) : void {
            var i:int;
            graphics.clear();
            graphics.lineStyle( 1 , 0 );

            for( i = 0 ; i < cnt ; i++ ) {
                var ls:lines = lines_array[i];
                ls.draw( graphics );
            }
        }

        public function onMouseDown( e:MouseEvent ) : void {
            var ls:lines = new lines();
            lines_array.push( ls );
            lines_array[cnt].push( mouseX , mouseY );
            cnt++;
            isdrawing = 1;
        }

        public function onMouseUp( e:MouseEvent ) : void {
            isdrawing = 0;
        }

        public function onMouseMove( e:MouseEvent ) : void {
            if( isdrawing ) {
                lines_array[cnt-1].push( mouseX , mouseY );
            }
        }
    }
}

import flash.display.Graphics;

class lines {        
    public var ax:Array = new Array();
    public var ay:Array = new Array();
    public var cnt:int;

    public function lines() {
        cnt = 0;
    }

    public function draw( g:Graphics ) : void {
        var i:int;

        if( cnt == 1 ) return;
        g.moveTo( int(ax[0])+(Math.random()*10.0)-5 , int(ay[0])+(Math.random()*10.0)-5 );
        for( i = 1 ; i < cnt ; i++ ) {
            g.lineTo( int(ax[i])+(Math.random()*10.0)-5 , int(ay[i])+(Math.random()*10.0)-5 );
        }
    }

    public function push( x:int , y:int ) : void {
        ax.push( x );
        ay.push( y );

        cnt++;
    }
}
