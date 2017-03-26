package 
{
    import Box2D.Collision.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.text.*;
    import flash.utils.*;
    
    
    [SWF(frameRate=60, width=465, height=465, backgroundColor=0x000000)] 
    public class Main extends Sprite 
    {
        ////////////////////////
        private var _S0:PushButton ; 
        private var _S1:PushButton ; 
        /////////////////////////////
        
        private const _GOAL:int = 10000 ;
        
        private var _t:TextField = new TextField();
        private var _w:b2World = null ;
        private var _h:Hero = null;
        private var _f:HeroFook = null ;
        private var _vp:Vector.<Pin> = new Vector.<Pin>();
        
        private var _back:BitmapData = null ;
        private var _p:Point = new Point() ;
        private var _s:Point = new Point() ;
        private var _b:Boolean = false;
        
        
        ///////////////////////////////
        public function Main () :void {
            
            addChild ( new Bitmap ( G._canvas ) ) ;
            
            _back = new BitmapData ( 200 , 200 , false , 0 ) ;
            _back.perlinNoise ( 200 , 200 , 9 , 0 , true , true , 7 , true ) ;
            
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set( -G.w * 10 , -G.h * 10 );
            worldAABB.upperBound.Set(  G.w * 10 ,  G.h * 10 );
            var b:b2Vec2 = new b2Vec2 ( 0 , 10 * G._SCALE ) ;
            _w = new b2World ( worldAABB , b , false ) ;
            _h = new Hero ( _w ) ;
            _f = new HeroFook( _h._p ) ;
            
            var I:int ;
            for ( I = 0 ; I < 9 ; ++ I ) {
                _vp.push ( new Pin ( _w ) ) ;
            }
            
            _t.defaultTextFormat = new TextFormat ( null , 55 ) ;
            _t.autoSize = "left";                    
            _t.filters = [ new GlowFilter ( 0x505050 , 1 ) ] ;
            
            _S0 = new PushButton ( this, 465-100 , 0, "Ad:kuma-flashgame" ) ;
            _S0.addEventListener ( MouseEvent.CLICK , function ():void { var url:URLRequest = new URLRequest ( "http://kuma-flashgame.blogspot.com/" ) ; navigateToURL( url ); } ) ;
            _S1 = new PushButton ( this , 0 , 0 , "Tweet" );
            _S1.x = ( 465 - _S1.width  ) / 2 ;
            _S1.y = ( 465 - _S1.height ) / 2 ;
            _S1.visible = false ;
            _S1.addEventListener ( MouseEvent.CLICK , function ():void { navigateToURL ( new URLRequest ( "http://twitter.com/home?status=" + escapeMultiByte ( _t.text + " http://kuma-flashgame.blogspot.com/2010/12/wiregameverwonderfl.html #WireGame" ) ) ); } ) ;
            
            init () ;
            
            stage.addEventListener ( MouseEvent.MOUSE_DOWN , function ( event:MouseEvent ) :void {G._lclick = true ;} );
            stage.addEventListener ( MouseEvent.MOUSE_UP   , function ( event:MouseEvent ) :void {G._lclick = false;} );
            addEventListener ( Event.ENTER_FRAME, run ) ; 
            
        }
        
        ///////////////////////////////
        public function init ():void {
            
            _s.x = 0 ;
            _s.y = 0 ;
            _h.init() ;
            
            var I:int ;
            for ( I = 0 ; I < _vp.length ; ++ I ) {
                _vp[I].setBodyPos( ( I * 100 ) / G._SCALE , 0 ) ; 
            }
            
            G._starttime = ( new Date() ).time ;
            
        }
        
        ///////////////////////////////
        private function run ( e:Event = null ) :void {
            
            var I:int ;
            
            if ( _b ) {
                
                _S1.visible = true ;
                
            } else {
                
                _w.Step ( 1 / 60 , 1 ) ;
                _h.update ( _s ) ;
                _f.input ( G._lclick ) ;
                
                if ( G._lclick ) {
                    if ( null == _h._j ) {
                        for ( I = 0 ; I < _vp.length ; ++ I ) {
                            if ( _f.chkFook ( _vp[I]._p ) ) {
                                _h.setFook ( _w , _vp[I]._b ) ; 
                                break;
                            }
                        }
                    }
                } else {
                    _h.offFook ( _w ) ;
                }
                
                if ( _h._j ) {
                    var P2:b2Vec2 = _h._j.m_body1.GetPosition() ;
                    _p.x = P2.x * G._SCALE - _s.x ;
                    _p.y = P2.y * G._SCALE - _s.y ;
                    _f.update1 ( _p ) ;
                } else {
                    _f.update2 ( _h._p ) ;
                }
                                
                for ( I = 0 ; I < _vp.length ; ++ I ) {
                    
                    if ( _GOAL < _s.x + 200 ) {
                        continue;
                    }
                    
                    if ( _vp[I]._p.x < - 500 ) { 
                        _vp[I].setBodyPos( ( _s.x + 500 ) / G._SCALE , 0 ) ; 
                    } 
                    
                }
                
                _t.text = Math.floor( ( _GOAL - _s.x ) / G._SCALE ) + "m" ;
                
                if ( _GOAL < _s.x ) {
                    
                    _b = true ;

                    var now:uint = ( new Date() ).time ;
                    var e2:uint = now - G._starttime ;
                    
                    var div:uint = 1000 * 60 * 60;
                    var hour:uint = e2 / div;
                    e2 -= hour * div;
                    div /= 60;
                    
                    var min:uint = e2 / div;
                    e2 -= min * div;
                    div /= 60;
                    
                    var sec:uint = e2 / div;
                    e2 -= sec * div;
                    
                    var tx:String = "";
                    if (min < 10) tx += "0";
                    tx += min.toString() + "\:";
                    if (sec < 10) tx += "0";
                    tx += sec.toString() + "\.";
                    if (e2 < 100) tx += "0";
                    tx += uint(e2 / 10).toString();
                    
                    _t.text = "Congratulations!\n[" + tx + "]" ;
                    
                    return ;
                    
                }
                
                if ( 600 < _s.y ) {
                    init() ;
                    return ;
                }
                
            }
            
            {
                var P:b2Vec2 = _h._b.GetPosition() ;
                _s.x = P.x * G._SCALE - G.w * 1 / 8 ;
                _s.y = P.y * G._SCALE - G.h * 6 / 8 ;
            }
            
            G._canvas.lock ( ) ;

            {
                var b:BitmapData = _back;
                for ( var X:int = -b.width ; X < G.w + b.width ; X += b.width ) {
                    for ( var Y:int = -b.height ; Y < G.h + b.height ; Y += b.height ) {
                        _p.x = -_s.x % b.width  + X ;
                        _p.y = -_s.y % b.height + Y ;
                        G._canvas.copyPixels ( b , b.rect , _p ) ;
                    }
                }
            }
            
            for ( I = 0 ; I < _vp.length ; ++ I ) {
                _vp[I].render ( _s ) ;
            }
            
            _f.render ( ) ;
            _h.render ( _f._p ) ;
            G._canvas.draw ( _t ) ;
            
            G._canvas.unlock ( ) ;
            
        }
        
    }
    
}

import Box2D.Collision.Shapes.*;
import Box2D.Common.Math.*;
import Box2D.Dynamics.*;
import Box2D.Dynamics.Joints.*;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;

class G {
    public static const w:uint = 465 ;
    public static const h:uint = 465 ;
    public static const _SCALE:Number = 10 ;
    public static var _canvas:BitmapData = new BitmapData ( w , h , false , 0 ) ;
    public static var _starttime:int = 0 ;
    public static var _lclick:Boolean = false ;
}

class HeroFook {
    
    public var _p:Point = new Point () ;
    public var _c:Number = 0 ;
    public var _bm:BitmapData = null ;
    
    public function HeroFook( pos:Point ) {
        
        var S:Sprite = new Sprite ;
        S.filters = [ new GlowFilter ( 0xFFFFFF , 1 ) ] ;
        var g:Graphics = S.graphics ;
        g.clear () ;
        g.beginFill ( 0xF0F0F0 , 1 ) ;
        g.drawCircle ( 15 , 15 , 10 ) ;
        g.endFill () ;
        _bm = new BitmapData ( 30 , 30 , true , 0 ) ;
        _bm.draw ( S ) ;
        
        _p.x = pos.x ;
        _p.y = pos.y ;
        
    }
    
    public function render ( ):void {
        G._canvas.copyPixels ( _bm , _bm.rect , _p ) ;
    }
    
    public function chkFook ( fpos:Point ):Boolean {
        var X:Number = ( fpos.x + 25 ) - ( _p.x + 15 ) ;
        var Y:Number = ( fpos.y + 25 ) - ( _p.y + 15 ) ;
        var L:Number = Math.sqrt ( X * X + Y * Y ) ;
        return L < 40 ;
    }
    
    public function input ( chk:Boolean ):void {
        if ( chk ) {
            _c += 0.1 ;
            if ( 1 < _c ) {_c = 1 ;}
        } else {
            _c = 0 ;
        }
    }
    
    public function update1 ( pos:Point ):void {
        _p.x = pos.x + 25 - 15 ;
        _p.y = pos.y + 25 - 15 ;
    }
    
    public function update2 ( pos:Point ):void {
        _p.x += ( pos.x + ( 150 * _c ) - _p.x ) * 0.5 ;
        _p.y += ( pos.y - ( 150 * _c ) - _p.y ) * 0.5 ;
    }
    
}

class Pin {
    
    public var _b:b2Body = null ;
    public var _p:Point = new Point () ;
    public var _bp:b2Vec2 = new b2Vec2 () ;
    private var _bm:BitmapData = null ;
    
    public function Pin( world:b2World ) {
        
        var S:Sprite = new Sprite () ;
        S.filters = [ new GlowFilter ( 0xFFFFFF , 1 ) ] ;
        var g:Graphics = S.graphics ;
        g.clear () ;
        g.beginFill ( 0x202020 , 1 ) ;
        g.drawCircle ( 25 , 25 , 20 ) ;
        g.endFill () ;
        _bm = new BitmapData ( 50 , 50 , true , 0 ) ;
        _bm.draw ( S ) ;
        
        var fd:b2CircleDef = new b2CircleDef();
        fd.radius = 26 / G._SCALE; 
        fd.density = 0.0; 
        fd.friction = 0;
        fd.restitution = 0.0;
        fd.filter.groupIndex = 55 ;
        fd.filter.maskBits = 0x0001;
        fd.filter.categoryBits = 0x0001;
        
        _b = world.CreateBody ( new b2BodyDef () ) ;
        _b.CreateShape ( fd );
        
    }

    public function setBodyPos ( x:Number , y:Number ) :void {
        _bp.x = x ;
        _bp.y = y ;
        _b.SetXForm ( _bp , 0 ) ;
    }
    
    public function render ( s:Point ) :void {
        _p.x = _b.GetPosition().x * G._SCALE - s.x ;
        _p.y = _b.GetPosition().y * G._SCALE - s.y ;
        G._canvas.copyPixels ( _bm , _bm.rect , _p ) ;
        
    }
    
}



class Hero {
    
    public var _p:Point = new Point () ;
    public var _b:b2Body = null ;
    public var _j:b2Joint = null ;
    private var _bm:BitmapData = null ;
    private var _S:Sprite = new Sprite () ;
    
    public function Hero ( world:b2World ) {
        
        _S.filters = [ new GlowFilter ( 0xFFFFFF , 1 ) ] ;
        
        var S:Sprite = new Sprite ;
        S.filters = [ new GlowFilter ( 0xFFFFFF , 1 ) ] ;
        var g:Graphics = S.graphics ;
        g.beginFill ( 0xF0F0F0 , 1 ) ;
        g.drawCircle ( 25 , 25 , 20 ) ;
        g.endFill () ;
        g.lineStyle ( 2 , 0 , 1 ) ;
        g.moveTo ( 10 , 15 ) ;
        g.lineTo ( 27 , 18 ) ;
        g.moveTo ( 35 , 18 ) ;
        g.lineTo ( 43 , 15 ) ;
        g.moveTo ( 20 , 25 ) ;
        g.lineTo ( 39 , 25 ) ;
        _bm = new BitmapData ( 50 , 50 , true , 0 ) ;
        _bm.draw ( S ) ;
        
        
        var fd:b2CircleDef = new b2CircleDef();
        fd.radius = 5 / G._SCALE; 
        fd.density = 1.0; 
        fd.friction = 0;
        fd.restitution = 1.0;
        fd.filter.groupIndex = -100 ;
        fd.filter.maskBits = 0x0002;
        fd.filter.categoryBits = 0x0002;
        
        _b = world.CreateBody ( new b2BodyDef () ) ;
        _b.CreateShape ( fd ) ;
        _b.SetMassFromShapes () ;
        
    }
    
    public function init () :void {
        _b.SetXForm ( new b2Vec2 ( 0 , 200 / G._SCALE ) , 0 ) ;
        _b.SetLinearVelocity ( new b2Vec2 ( 40 , - 45 ) ) ;
        update ( new Point ( 0 , 100 ) ) ;
    }
    
    public function update( s:Point ) :void {
        _p.x = _b.GetPosition().x * G._SCALE - s.x ;
        _p.y = _b.GetPosition().y * G._SCALE - s.y ;
    }
    
    public function render( wapos:Point ) :void {
        
        var g:Graphics = _S.graphics ;
        g.clear () ;
        g.lineStyle ( 2 , 0 , 1 ) ;
        g.moveTo ( wapos.x + 15 , wapos.y + 15 ) ;
        g.lineTo ( _p.x + 25 , _p.y + 25 ) ;
        
        G._canvas.draw ( _S  ) ;
        G._canvas.copyPixels ( _bm , _bm.rect , _p ) ;
        
    }
    
    public function setFook ( world:b2World , pin:b2Body ) :void {
        
        var jd :b2RevoluteJointDef = new b2RevoluteJointDef ( ) ;
        jd.Initialize ( pin , _b , pin.GetPosition() ) ;
        jd.collideConnected = true ;
        jd.enableLimit = false ;
        jd.enableMotor = false ;
        
        if (  _j ) {
            world.DestroyJoint ( _j ) ;
        }
        
        _j = world.CreateJoint ( jd ) ;
        
        var v:b2Vec2 = _b.GetLinearVelocity () ;
        v.x += 10 ;
        _b.SetLinearVelocity ( v );
        
    }

    public function offFook ( world:b2World ) :void {
        if (  _j ) {
            world.DestroyJoint ( _j ) ;
            _j = null ;
        }
    }
    
}