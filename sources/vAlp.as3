//Mouseで移動 
//Zで攻撃 
//Xでジャンプ
//Z,Xを一緒に押しとくと投石できます。
//
//MRSSつかってみました。いろんなところで戦えます。
//雑魚絵は友人作成です。
//
//Aキーでステージセレクトに戻れるようにしてみましたが、何かリークしてるみたいです。
//removeEventListenerとかGCと上手く付き合う為の作法がよくわかりません。
package 
{
    import flash.display.*;
    import flash.events.*;
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    
    [SWF(width = 465 , height = 465 , backgroundColor = '#FFFFFF' , frameRate = '60')]
    public class Main extends Sprite {
            
        private var _sceneManager:SceneManager ;
        
        public function Main() {
            
            //入力用
            var I:int = 0 ;
            for ( I = 0; I < 256; ++I ) { Global._key[I] = false; }
            stage.addEventListener( KeyboardEvent.KEY_DOWN, function ( E:KeyboardEvent ):void { Global._key[ E.keyCode ] = true;  } );
            stage.addEventListener( KeyboardEvent.KEY_UP  , function ( E:KeyboardEvent ):void { Global._key[ E.keyCode ] = false; } );
            
            //ゲーム開始
            _sceneManager = new SceneManager ;
            SceneManager._next = new SceneStageSelect;
            addChild ( _sceneManager ) ;
            
        }
        
    }
    
       
}


import caurina.transitions.AuxFunctions;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;
import org.libspark.betweenas3.*;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.easing.Cubic;

import flash.display.*;
import flash.events.*;
import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.escapeMultiByte;



///
class Global {
    public static var _key:Array = new Array ( 256 ) ;
    public static var _canvas:BitmapData = new BitmapData ( 465 , 465 , false , 0 ) ;
    public static var _back  :BitmapData = new BitmapData ( 465 , 465 , false , 0 ) ;
}


///
class Effect {
    
    private var _img:BitmapData = null ;
    private var _V:Vector.<Object> = new Vector.<Object> ;
    
    ////////////////////////////////////
    public function Effect() {
    
        _img = new BitmapData ( 50 , 50 , true , 0 ) ;
        
        var S:Sprite = new Sprite ;
        var G:Graphics = S.graphics ;
        var M:Matrix = new Matrix ;
        M.createGradientBox ( 50 , 50 , 0 , 0 , 0 ) ;
        G.lineStyle ( 1 ) ;
        G.lineGradientStyle ( "radial" , [ 0xFFFFFF , 0xFFA020 ] , [ 1 , 0 ] , [ 0 , 255 ] , M ) ;
        for ( var I:int = 0 ; I < 50 ; ++ I ) {
            G.moveTo ( 25 , 25 ) ;
            var R:Number = I / 50 * 360 * Math.PI / 180 ;
            G.lineTo ( Math.cos ( R ) * 25 + 25 , Math.sin ( R ) * 25 + 25 ) ;
        }
        S.filters = [ new BlurFilter ] ;
        _img.draw ( S ) ;
        
    }
    
    ////////////////////////////////////
    public function release ( ) :void {
        _img.dispose ( ) ;
        _img = null ;
    }
    
    ////////////////////////////////////
    public function push ( x:int , y:int ) :void {
        _V.push ( { P:new Point ( x - _img.width * .5 , y - _img.height * 1.5 ) , T:6 } ) ;
    }
    
    ////////////////////////////////////
    public function update () :void {
        for ( var I:int = 0 ; I < _V.length ; ++ I ) {
            if ( -- _V[I].T < 0 ) {
                _V.splice ( I , 1 ) ;
            }
        }
    }
    
    ////////////////////////////////////
    public function render ( ) :void {
        for each ( var O:Object in _V ) {
            Global._canvas.copyPixels ( _img , _img.rect , O.P ) ;
        }
    }
    
}


//
interface Iactor {
    function render_shadow ( ) :void ;
    function render ( ) :void ;
    function get pos ( ) :Vector3D ;
}


//
class BaseActor {
    
    //固有ID
    private static var UNIQUE:uint = 0 ;
    private var _id:uint = 0 ;
    
    //座標
    protected var _pos:Vector3D = new Vector3D ;
    protected var _velocity:Vector3D = new Vector3D ;
    
    //描画用
    protected var _renderpos:Point = new Point ;
    protected var _shadowpos:Point = new Point ;
    
    public function BaseActor() {
        _id = UNIQUE ++ ;
    }
    
    public function get id ( ) :uint {
        return _id ;
    }
    
    public function get pos ( ) :Vector3D {
        return _pos ;
    }
    
}


//
class ActorParam extends BaseActor {
    
    //キャラクタのスケール
    protected const SCALE:Number = 1.5 ;
    
    //キャラクタの実サイズ
    protected var SIZE :int = 0 ;
    protected var _render_rect:Rectangle = null ;
    
    //画像
    protected var _img:BitmapData = null ;
    protected var _img_r:BitmapData = null ;
    protected var _shadow:BitmapData = null ;
    
    public function ActorParam ( B:Bitmap , C:ColorTransform , charctorSize:int ) {
        
        super ( ) ;
        
        SIZE = charctorSize * SCALE ;
        
        var M:Matrix = new Matrix ;
        var S:Sprite = new Sprite;
        var G:Graphics = S.graphics;
        var I:int = 0 ;
        var J:int = 0 ;
        
        var S1:Number = SIZE/4   * SCALE ;
        var S2:Number = SIZE/8   * SCALE ;
        var S3:Number = B.width  * SCALE ;
        var S4:Number = B.height * SCALE ;
        
        //スケーリング
        M.scale ( SCALE , SCALE ) ;
        
        //影
        G.beginFill ( 0 , .5 ) ;
        G.drawEllipse ( 0 , 0 , S1 , S2 ) ;
        G.endFill () ;
        _shadow = new BitmapData ( S1 , S2 , true , 0 ) ;
        _shadow.draw ( S ) ;
        
        //キャラクタ-
        _img = new BitmapData ( S3 , S4 , true , 0 ) ;
        _img.draw ( B , M , C ) ;
        
        //反転キャラクター
        _img_r = new BitmapData ( S3 , S4 , true , 0 ) ;
        for ( I = 0 ; I < S3 ; I += SIZE ) {
            for ( J = 0 ; J < SIZE ; ++ J ) {
                _img_r.copyPixels ( 
                    _img , 
                    new Rectangle ( I + J , 0 , 1 , S4 ) , 
                    new Point ( I + SIZE - J , 0 ) 
                ) ;
            }
        }
        
        //
        _pos.x = Math.random ( ) * 465 ;
        _pos.y = 0 ;
        _pos.z = Math.random ( ) * 100 + 300 ;
        
        _render_rect  = new Rectangle ( 0 , 0 , SIZE , SIZE ) ;
        
    }
    
    public function release ( ):void {
        
        _img.dispose ( ) ;
        _img = null ;
        
        _img_r.dispose ( ) ;
        _img_r = null ;
        
        _shadow.dispose ( ) ;
        _shadow = null ;
        
    }

}


//
class CharctorBase extends ActorParam implements Iactor {
    
    //アニメーションテーブル
    private var $A:Array = null ;
    private var $B:Array = null ;
    private var $C:Array = null ;
    private var $D:Array = null ;
    private var $E:Array = null ;
    private var $F:Array = null ;
    
    //体力
    private var _hp:int = 0 ;
    private var _death:Boolean = false ;
    private var _death_cnt:int = 0;
    
    //アニメーション用
    private var _anim:int = 0 ;
    private var _animwait:int = 0 ;
    private var _action:int = 0 ;
    private var _actionstep:int = 0 ;
    private var _dirc:Boolean = false;
    
    //入力用
    private var _input_damage:Boolean = false ;
    private var _input_attack:Boolean = false ;
    private var _input_jump  :Boolean = false ;
    private var _target_x:int = 0 ;
    private var _target_z:int = 0 ;
    private var _speed:Number = 0 ;
    
    //ジャンプ管理
    private var _jump_state:Boolean = false;
    
    //攻撃管理
    private var _attack_state:int = 0 ;
    private var _attack_shake:int = 0 ;
    private var _hitRegist:Vector.<int> = new Vector.<int> ;
    
    //被ダメージ管理
    private var _damage_action:int = 0 ;
    private var _damage_shake:int = 0 ;
    
    ////////////////////////////////////
    public function CharctorBase ( B:Bitmap , C:ColorTransform , $$A:Array , $$B:Array , $$C:Array , $$D:Array , $$E:Array , $$F:Array ) {
        
        super ( B , C , 64 ) ;
        
        $A = $$A ;
        $B = $$B ;
        $C = $$C ;
        $D = $$D ;
        $E = $$E ;
        $F = $$F ;
        
        _hp = 3 ;
        _death = false ;
        _death_cnt = 0 ;
        input ( Math.random() * 400 , 300 + Math.random() * 150 , false , false ) ;
        
    }
    
    ////////////////////////////////////
    public function input ( x:int , y:int , keyA:Boolean , keyJ:Boolean ):void {
        _input_attack = keyA ;
        _input_jump   = keyJ ;
        _target_x     = x ;
        _target_z     = y ;
    }
    
    ////////////////////////////////////
    public function inputAuto ( ):void {
        
        _input_attack = Math.random() < 0.03 ;
        _input_jump   = Math.random() < 0.01 ;
        
        var V:Vector3D = _pos.clone() ;
        V.x -= _target_x ;
        V.z -= _target_z ;
        if ( V.length < 20 * SCALE ) {
            _target_x = Math.random() * 465 ;
            _target_z = Math.random() * 120 + 300 ;
        }
    }
    
    ////////////////////////////////////
    public function getDeath ( ) :Boolean {
        return _death ;
    }
    
    
    ////////////////////////////////////
    public function update ( item:Vector.<Item> , mainHero:CharctorBase ):void {
        
        var CHK:Boolean = true ;
        var TC:int = $C[_action][_actionstep] ;
        var Ba:int = _action;
        var Bas:int = _actionstep;
        var X:Number = 0 ;
        var Y:Number = 0 ;
        var L:Number = 0 ;
        
        if ( _death ) {
            
            if ( 60 < ++ _death_cnt && this != mainHero ) {
                
                _hp = 3 ;
                _death = false ;
                _death_cnt = 0 ;
                
                _pos.x = ( Math.random() < .5 )? -100 : 500 ;
                _pos.y = 0 ;
                _velocity.y = 0 ;
                
                _action = 12 ;
                
            }
            
        }
        
        if ( 0 < _damage_shake ) {
            CHK = false ;
            -- _damage_shake ;
        }
        
        if ( 0 < _attack_shake ) {
            CHK = false ;
            -- _attack_shake ;
        }
        
        {//入力の反映
            
            if ( 1 & TC ) {
                
                X = _pos.x - _target_x ;
                Y = _pos.z - _target_z ;
                L = X * X + Y * Y ;
                _action = ( 10 * 10 < L )? 1 : 0 ;
                
            }
            
            if ( 2 & TC ) {
                
                if ( _input_attack ) {
                    
                    if ( _jump_state ) {
                        
                        _action = 6 ;
                        
                    } else {
                        
                        switch ( _attack_state ) {
                            case 0 : _attack_state = 1 ;  _action = 3 ; break ;
                            case 1 : _attack_state = 2 ;  _action = 7 ; break ;
                            case 2 : _attack_state = 0 ;  _action = 4 ; break ;
                        }
                    }
                    
                } else {
                    
                    _attack_state = 0 ; 
                    
                }
                
            }
            
            if ( 4 & TC ) {
                if ( _input_jump ) {
                    _action = 2 ;
                }
            }
            
            if ( 8 & TC ) {
                if ( _input_attack && _input_jump ) {
                    _action = 13 ;
                }
            }
            
            //強制動作
            if ( _damage_action ) {
                _action = _damage_action ;
                _damage_action = 0 ;
            }
            
            if ( Ba != _action ) {
                _actionstep = 0 ;
                _animwait = 0 ;
            }
            
        }
        
        if ( CHK ) 
        {//アニメーション
            
            var TD:int = $D[_action][_actionstep];
            switch ( TD ) {
                
                case 0 :
                    ++ _animwait;
                    break ;
                
                case 1 :
                    if ( 0 < _velocity.y ) {
                        ++ _animwait ;
                    }
                    break ;
                
                case 2:
                    if ( false == _jump_state ) {
                        ++ _animwait ;
                    }
                    break;
                    
                case 3:
                    break;
            }
            
            if ( $B[_action][_actionstep] <= _animwait ) {
                
                _animwait = 0 ;
                
                switch ( $E[_action][_actionstep] ) {
                    case 1: _velocity.y = -5 ; break;
                    case 2: _action = (_jump_state)? 12 : 0 ; break ;
                    case 3: item.push ( new Item ( id , _pos , new Vector3D ( (_dirc)? -8 : 8 , -3 , 0 ) ) ) ; break ;
                    default: break;
                }
                
                if ( $A[_action].length <= ++ _actionstep ) {
                    _actionstep = 0 ;
                }
                
                while ( _hitRegist.length ) {
                    _hitRegist.pop () ;
                }
                
            }
            
        }
        
        if ( CHK && ( 1 & TC ) )
        {//加速
            
            _dirc = ( _target_x < _pos.x ) ;
            
            var ty:Number = _velocity.y;
            _velocity.y = 0 ;
            
            X = ( _target_x - _pos.x ) ;
            Y = ( _target_z - _pos.z ) ;
            L = X * X + Y * Y ;
            if ( 10 * 10 < L ) {
                _velocity.x += X * .01 ;
                _velocity.z += Y * .01 ;
            }
            
            _speed = _velocity.length ;
            _speed = ( 2 < _speed )? 2 : _speed ;
            
            _velocity.normalize ( ) ;
            _velocity.scaleBy ( _speed ) ;
            
            _velocity.y = ty ;
            
        }
        
        if ( CHK ) 
        {//移動
            
            _pos.x += _velocity.x * SCALE ;
            _pos.y += _velocity.y * SCALE ;
            _pos.z += _velocity.z * SCALE *.5 ;
            _velocity.y += .2 ;
            
            if ( false == _jump_state ) {
                _velocity.x *= .9 ;
                _velocity.z *= .9 ;
            }
            
            if ( 0 <= _pos.y ) {
                _pos.y = 0 ;
                _jump_state = false ;
            } else {
                _jump_state = true ;
            }
            
            if ( _pos.z < ZMAX ) {
                _pos.z = ZMAX ;
            }
            
        }
        
        _anim = $A[_action][_actionstep] ;
        
    }
    
    ////////////////////////////////////
    public function attackChk ( e:Hero , effect:Effect , mainHero:Hero ):void {
        
        if ( this == e ) {
            return ;
        }
        
        if ( e._death ) {
            return ;
        }
        
        for each ( var N:int in _hitRegist ) {
            if ( N == e.id ) {
                return ;
            }
        }
        
        var temp:int = $F[_action][_actionstep] ;
        if ( temp != 0 ) {
            
            var V:Vector3D = _pos.subtract ( e._pos ) ;
            
            if ( _dirc ) {
                V.x -= 16 * SCALE ;
            } else {
                V.x += 16 * SCALE ;
            }
            
            if ( V.length < 30 ) {
                
                _attack_shake = 10 ;
                
                if ( e.damage () && this==mainHero ) {
                    if ( _end == false ) {
                        ++ _score ;
                    }
                }
                
                _hitRegist.push ( e.id ) ;
                effect.push ( e.pos.x , e.pos.z + e.pos.y ) ;
            }
            
        }
        
    }
    
    ////////////////////////////////////
    public function damage ( ) :Boolean {
        
        var B:Boolean = false ;
        
        //死亡チェック
        if ( -- _hp <= 0 ) {
            
            _death = true ;
            _death_cnt = 0 ;
            _damage_action = 11 ;
            B = true ;
            
        } else {
            
            _damage_action = 8 + Math.floor ( Math.random() * 3 ) ;
            
        }
        
        //ノックバック
        _velocity.x = (_dirc)? -1 : 1 ;
        _damage_shake = 15 ;
        
        return B ;
    }
        
    ////////////////////////////////////
    public function moveChk ( e:Hero ):void {
        
        if ( this == e ) {
            return ;
        }
    
        var V:Vector3D = _pos.subtract ( e._pos ) ;
        if ( V.length < 20 * SCALE ) {
            V.normalize();
            _velocity.x = V.x * 1 ;
            _velocity.z = V.z * 1 ;
        }
        
    }

    ////////////////////////////////////
    public function render_shadow ( ):void {
        _shadowpos.x = _pos.x - SIZE/4/2 * SCALE ;
        _shadowpos.y = _pos.z - SIZE/8/2 * SCALE ;
        Global._canvas.copyPixels ( _shadow , _shadow.rect , _shadowpos ) ;
    }
    
    ////////////////////////////////////
    public function render ( ):void {
                
        if ( _death ) {
            if ( _death_cnt % 10 < 5 ) {
                return ;
            }
        }

        _anim %= 40 ;
        _render_rect.x = Math.floor ( _anim % 8 ) * SIZE ;
        _render_rect.y = Math.floor ( _anim / 8 ) * SIZE ;
        
        _renderpos.x = _pos.x          - SIZE /2 ;
        _renderpos.y = _pos.z + _pos.y - SIZE ;
        
        if ( _damage_shake ) {
            _renderpos.x += Math.random() * 10 - 5 ;
            _renderpos.y += Math.random() * 10 - 5 ;
        }
        
        if ( _dirc ) {
            Global._canvas.copyPixels ( _img_r , _render_rect , _renderpos ) ;
        } else {
            Global._canvas.copyPixels ( _img   , _render_rect , _renderpos ) ;
        }
        
    }
    
}


//投擲アイテム
class Item extends BaseActor implements Iactor {
    
    private const SIZE:int = 10 ;
    
    //画像
    private var _img:BitmapData = null ;
    private var _shadow:BitmapData = null ;
    
    //
    private var _manage_id:uint = 0 ;
    private var _timer:int = 0 ;
    private var _hit:Boolean = false ;
    
    ////////////////////////////////////
    public function Item ( manage_id:uint , pos:Vector3D , velocty:Vector3D ) :void {
        
        super ( ) ;
        
        _manage_id = manage_id ;
        _timer = 80 ;
        
        //描画用
        var S:Sprite = new Sprite ;
        var G:Graphics = S.graphics ;
        
        //石本体
        G.clear ( ) ;
        G.beginFill ( 0x404040 , 1 ) ;
        G.drawCircle ( SIZE/2 , SIZE/2 , SIZE/2 ) ;
        G.endFill ( ) ;
        _img = new BitmapData ( SIZE , SIZE , true , 0 ) ;
        _img.draw ( S ) ;
        
        //影
        G.clear ( ) ;
        G.beginFill ( 0 , .5 ) ;
        G.drawEllipse ( 0 , 0 , SIZE , SIZE/2 ) ;
        G.endFill () ;
        _shadow = new BitmapData ( SIZE , SIZE/2 , true , 0 ) ;
        _shadow.draw ( S ) ;
        
        //座標
        _pos.x = pos.x ;
        _pos.y = pos.y - 40 ;
        _pos.z = pos.z ;
        _velocity.x = velocty.x ;
        _velocity.y = velocty.y ;
        _velocity.z = velocty.z ;
        
    }
    
    ////////////////////////////////////
    public function release ( ) :void {
        _img.dispose ( ) ;
        _img = null ;
    }
    
    ////////////////////////////////////
    public function update ( ) :void {
        
        -- _timer ;
        
        _velocity.y += .3 ;
        _pos.x += _velocity.x ;
        _pos.y += _velocity.y ;
        _pos.z += _velocity.z * .5 ;
        
        if ( 0 <= _pos.y ) {
            _pos.y = 0 ;
            _velocity.y = - _velocity.y * .5 ;
        }
        
    }
    
    ////////////////////////////////////
    public function get death ( ) :Boolean {
        return _timer < 0 ;
    }
    
    ////////////////////////////////////
    public function render_shadow ( ):void {
        _shadowpos.x = _pos.x - SIZE/2   ;
        _shadowpos.y = _pos.z - SIZE/2/2 ;
        Global._canvas.copyPixels ( _shadow , _shadow.rect , _shadowpos ) ;
    }
    
    ////////////////////////////////////
    public function render ( ):void {
        _renderpos.x = _pos.x          - SIZE/2 ;
        _renderpos.y = _pos.z + _pos.y - SIZE ;
        Global._canvas.copyPixels ( _img , _img.rect , _renderpos ) ;
    }
    
    ////////////////////////////////////
    public function attackChk ( e:Hero , effect:Effect , mainHero:Hero ):void {
        
        if ( death ) {
            return ;
        }
        
        if ( _hit ) {
            return ;
        }
        
        if ( _manage_id == e.id ) {
            return ;
        }
        
        var V:Vector3D = _pos.subtract ( e.pos ) ;
        V.y += 30 ;
        
        if ( V.length < 30 ) {
            
            _hit = true ;
            _velocity.x = - _velocity.x * .2 ;
            _velocity.y = - 6 ;
            _timer = 40 ;
            
            if ( e.damage () ) {
                if ( _end == false ) {
                    ++ _score ;
                }
            }
                
            effect.push ( e.pos.x , e.pos.z + e.pos.y ) ;
            
        }
        
        
    }
    
}



///
class ImageButton extends Sprite {
    
    private var IT:ITween = null ;
    
    ///////////
    public function ImageButton ( data:Bitmap , cnt:int ) {
        
        addChild ( data ) ;
        
        var X:int = Math.floor( cnt % 5 ) * ( 90 ) + 15 /2 ;
        var Y:int = Math.floor( cnt / 5 ) * ( 90 ) + 90 /2 ;
        
        var SIT:ITween = BetweenAS3.delay (
            BetweenAS3.tween (
                this ,
                { _blurFilter: { blurX:0 , blurY:0  }, alpha:1, x:X, y:Y      },
                { _blurFilter: { blurX:20, blurY:20 }, alpha:0, x:X, y:Y + 20 },
                .5 ,
                Cubic.easeOut
            ) ,
            Math.random ( ) * .5
        ) ;
        
        SIT.addEventListener ( Event.COMPLETE , run ) ;
        SIT.play ( ) ;
        
    }
    
    ///////////
    private function run ( e:Event ) :void {
        addEventListener ( MouseEvent.CLICK , click ) ;
        addEventListener ( MouseEvent.MOUSE_OVER , over ) ;
        addEventListener ( MouseEvent.MOUSE_OUT , out ) ;
    }
    
    ///////////
    private function click ( e:MouseEvent ):void {
        
        var decide:Bitmap = null ;
        decide = getChildAt(0) as Bitmap ;
        if ( null != decide ) {
            
            var SX:Number = 465 / decide.width  * decide.scaleX ;
            var SY:Number = 465 / decide.height * decide.scaleY ;
            
            var M:Matrix = new Matrix ;
            if ( SX < SY ) { 
                M.scale ( SY , SY ) ;
            } else { 
                M.scale ( SX , SX ) ;
            }
            
            Global._back.draw ( decide , M ) ;
            
            if ( IT ) { IT.stop() ; }
            IT = BetweenAS3.to ( this , {transform: { colorTransform: {redOffset: 250 , greenOffset: 250 , blueOffset: 250 } }} , .2 , Cubic.easeOut ) ;
            IT.play ( ) ;
            
            dispatchEvent ( new Event ( "DECIDE" ) ) ;
            
        }
        
        
    }
    
    ///////////
    private function over ( e:MouseEvent ) :void {
        if ( IT ) { IT.stop() ; }
        IT = BetweenAS3.to ( this , {transform: { colorTransform: {redOffset: 60 , greenOffset: 60 , blueOffset: 60 } }} , .2 , Cubic.easeOut ) ;
        IT.play() ;
    }
    
    ///////////
    private function out ( e:MouseEvent ) :void {
        if ( IT ) { IT.stop() ; }
        IT = BetweenAS3.to ( this , {transform: {colorTransform: {redOffset: 0 , greenOffset: 0 , blueOffset: 0 }}} , .2 , Cubic.easeOut ) ;
        IT.play() ;
    }
    
    ///////////
    public function release ( ) :void {
        removeEventListener ( MouseEvent.CLICK , click ) ;
        removeEventListener ( MouseEvent.MOUSE_OVER , over ) ;
        removeEventListener ( MouseEvent.MOUSE_OUT , out ) ;
    }
    
}


///
class Mrss extends Sprite {
    
    private const _feed:String = "http://api.flickr.com/services/feeds/photos_public.gne?tags=landscape&format=rss_200";
    private const _media:Namespace = new Namespace ( "http://search.yahoo.com/mrss/" ) ;
    private var _ib:Vector.<ImageButton> = new Vector.<ImageButton> ;
    private var _v:Vector.<String> = new Vector.<String> ;
    
    private var _decide:Bitmap = null ;
    private var _cnt:int = 0 ;
    
    ////////////////////////////////////
    public function Mrss ( ) {
        
        var ldr:URLLoader = new URLLoader;
        
        ldr.addEventListener (
            Event.COMPLETE,
            function (e:Event):void {
                ldr.removeEventListener( Event.COMPLETE, arguments.callee );
                loadImg ( XML(ldr.data).._media::thumbnail.@url.toXMLString().split('\n') );
            }
        );
        
        ldr.load ( new URLRequest ( _feed ) ) ;
        
    }
    
    ////////////////////////////////////
    private function loadImg ( $images:Array ) :void {
        
        var len:uint = $images.length ;
        for ( var i:int = 0 ; i < len ; ++i ) {
            
            var ldr:Loader = new Loader ;
            ldr.contentLoaderInfo.addEventListener ( Event.COMPLETE , loadImgComp ) ;
            
            var str:String = $images[ i ].replace ( "_s" , "" ) ;
            ldr.load ( new URLRequest ( str ) , new LoaderContext ( true ) ) ;
            
        }
        
    }
   
    ////////////////////////////////////
    private function loadImgComp ( e:Event ) :void {
        
        var data:Bitmap = e.target.content as Bitmap ;
        if ( data ) {
            
            data.scaleX  = 80 / data.width ;
            data.scaleY  = 80 / data.height ;
            data.filters = [ new DropShadowFilter ] ;
            
            var IB:ImageButton = new ImageButton ( data , _cnt ) ;
            
            IB.addEventListener (
                "DECIDE" ,
                function ( e:Event ) :void {
                    IB.removeEventListener ( "DECIDE" , arguments.callee ) ;
                    dispatchEvent ( new Event ( "DECIDE" ) ) ;
                }
            ) ;
            
            _ib.push ( IB ) ;
            addChild ( IB ) ;
            
            ++ _cnt ;
        }
        
    }
    
    ////////////////////////////////////
    public function release ( ) :void {
        
        for each ( var IB:ImageButton in _ib ) {
            IB.release ( ) ;
        }
        
    }
    
}


//シーン管理
class SceneManager extends Sprite {
    
    private var _step:int = 0 ;
    private var _scene:SceneBase = null ;
    public static var _next:SceneBase = null ;
    
    public function SceneManager ( ) {
        
        _next = new SceneStageSelect ;
        addEventListener ( Event.ENTER_FRAME , run ) ;

    }

    private function run ( e:Event ):void {
        
        if ( null == _scene ) {
            
            _scene = _next ;
            stage.addChild ( _scene ) ;
            _scene.alpha = 0 ;
            
            _next = null ;
            _step = 0 ;
            
        } else {
            
            switch ( _step ) {
                case 0: 
                    {
                        _step = 1 ;
                        
                        BetweenAS3.to ( _scene , { alpha:1 } , .5 ).play() ;
                        
                        _scene.init ();
                        
                    }
                    break ;
                    
                case 1: 
                    {
                        
                        _scene.core () ; 
                        if ( _next ) {
                            _step = 2 ;
                        }
                        
                    }
                    break ;
                    
                case 2: 
                    {
                        _step = 3 ;
                        
                        _scene.filters = [ new BlurFilter ( 10, 10 ) ] ;
                        var it:ITween = BetweenAS3.to ( _scene , { alpha:0 } , .5 ) ;
                        
                        it.addEventListener (
                            Event.COMPLETE ,
                            function ( e:Event ) :void {
                                it.removeEventListener ( Event.COMPLETE , arguments.callee ) ;
                                _step = 4;
                            }
                        );
                        
                        it.play() ;
                        
                    }
                    break; 
                    
                case 3: 
                    {
                        //待ち
                    }
                    break ;
                    
                case 4:
                    {
                        _scene.release ( ) ;
                        
                        stage.removeChild ( _scene ) ;
                        _scene = null ;
                        
                    }
                    break ;
                
            }
            
        }
        
    }    
    
}


//シーンの基礎
class SceneBase extends Sprite {
    public function init( ):void { } ;
    public function core( ):void { } ;
    public function release( ):void { } ;
}


//ステージセレクト
class SceneStageSelect extends SceneBase {
    
    private var _mrss:Mrss = new Mrss ;
    
    ////////////////////////////////////
    public function SceneStageSelect () :void {
        
        _mrss.addEventListener (
            "DECIDE" ,
            function ( e:Event ) :void {
                _mrss.removeEventListener ( "DECIDE" , arguments.callee ) ;
                SceneManager._next = new SceneBattle ;
            }
        ) ;
        
        addChild ( _mrss ) ;
        
    }
    
    
    public override function release ( ) :void {
        _mrss.release ( ) ;
    }
    
}


//戦闘シーン
class SceneBattle extends SceneBase {
    
    private var _rendering_container:Vector.<Iactor> = new Vector.<Iactor> ( ) ;
    private var _h:Vector.<Hero> = null ;
    private var _i:Vector.<Item> = null ;
    private var _mainHero:Hero = null ;
    private var _effect:Effect = null ;
    private var _scoreText:TextField = new TextField ;

    //宣伝用//////////////////////
    private var _S0:PushButton ; 
    private var _S1:PushButton ; 
    private var _S2:PushButton ; 
    /////////////////////////////
    
    ////////////////////////////////////
    public function SceneBattle ( ) {
        
        
        //キャラクター用
        _h = new Vector.<Hero>;
        
        //アイテム用
        _i = new Vector.<Item>;
        
        //ヒットマーク用
        _effect = new Effect ;
        
        //キャラクタ画像読み込み(雑魚)
        var L:Loader = new Loader;
        L.contentLoaderInfo.addEventListener ( Event.COMPLETE, compLoad ) ;
        L.contentLoaderInfo.addEventListener ( IOErrorEvent.IO_ERROR , function ():void { } ) ;
        L.load ( new URLRequest ( FILENAME ) , new LoaderContext ( true ) ) ;
        
        addChild ( new Bitmap ( Global._canvas ) ) ;
        
        //宣伝用////////////////////////////////////////////////////
        _S0 = new PushButton ( this, 465-100 , 0, "Ad:kuma-flashgame" ) ;
        _S0.addEventListener ( MouseEvent.CLICK , function ( ) :void { var url:URLRequest = new URLRequest ( "http://kuma-flashgame.blogspot.com/" ) ; navigateToURL ( url ) ; } ) ;
        ////////////////////////////////////////////////////////////
        
        //送信ボタン////////////////////////////////////////////////////
        _score = 0 ;
        _scoreText.autoSize = "left" ;
        _scoreText.defaultTextFormat = new TextFormat ( null , 50 , 0xFFFFFF ) ;
        _scoreText.text = _score.toString () ;
        addChild ( _scoreText ) ;
        _S1 = new PushButton ( this , 0 , 0 , "Tweet" );
        _S1.x = ( 465 - _S1.width  ) / 2 ;
        _S1.y = ( 465 - _S1.height ) / 2 ;
        _S1.visible = false ;
        _S1.addEventListener ( MouseEvent.CLICK , function ():void { navigateToURL ( new URLRequest ( "http://twitter.com/home?status=" + escapeMultiByte ( "score=" + _score + "  http://kuma-flashgame.blogspot.com/2010/08/blog-post_20.html #ZAKOgame" ) ) ); } ) ;
        //////////////////////////////////////////////////////////
        _S2 = new PushButton ( this, 0 , 0, "Retry" ) ;
        _S2.x = ( 465 - _S1.width  ) / 2 ;
        _S2.y = ( 465 - _S1.height ) / 2 + 40 ;
        _S2.visible = false ;
        _S2.addEventListener ( MouseEvent.CLICK , function ( ) :void { 
            SceneManager._next = new SceneStageSelect ;
         } ) ;
        ////////////////////////////////////////////////////////////
        
        _end = false ;
        
    }
    
    ////////////////////////////////////
    public override function release ( ) :void {
        
        _mainHero = null ;
        
        _S0 = null ; 
        _S1 = null ;
        _S2 = null ;
        
        _effect.release ( ) ;
        
        for each ( var H:Hero in _h ) {
            H.release ( ) ;
        }
        
        for each ( var I:Item in _i ) {
            I.release ( ) ;
        }
        
        _h = null ;
        _i = null ;
        
    }
    
    
    
    ////////////////////////////////////
    private function compLoad( e:Event ):void {
        
        var B:Bitmap = e.target.content as Bitmap ;
        
        _mainHero = new Hero ( B ) ;
        _h.push ( _mainHero ) ;
        
        _h.push ( new Hero ( B , new ColorTransform ( .2 , 1 , .4 , 1 ) ) ) ;
        _h.push ( new Hero ( B , new ColorTransform ( .2 , 1 , .4 , 1 ) ) ) ;
        _h.push ( new Hero ( B , new ColorTransform ( .2 , 1 , .4 , 1 ) ) ) ;
        _h.push ( new Hero ( B , new ColorTransform ( .2 , 1 , .4 , 1 ) ) ) ;
        
    }
    
    ////////////////////////////////////
    public override function core ( ):void {
        
        var TH1:Hero ;
        var TH2:Hero ;
        var ITEM:Item ;
        var SB:Iactor ;
        
        //背景
        Global._canvas.copyPixels ( Global._back , Global._back.rect , ZERO_POINT ) ;
        
        if ( _mainHero == null ) {
            return ;
        }
        
        //アイテム更新
        for each ( ITEM in _i ) {
            ITEM.update ( ) ;
        }
        
        //アイテム消去
        for ( var I:int = 0 ; I < _i.length ; ++ I ) {
            if ( _i[I].death ) {
                _i.splice ( I , 1 ) ;
            }
        }
        
        //入力
        for each ( TH1 in _h ) {
            if ( TH1 == _mainHero ) {
                _mainHero.input ( mouseX , mouseY , Global._key[90] , Global._key[88] ) ;
            } else {
                TH1.inputAuto() ;
            }
        }
        
        //更新
        for each ( TH1 in _h ) {
            TH1.update ( _i , _mainHero ) ;
        }
        
        //攻撃判定
        for each ( TH1 in _h ) {
            for each ( TH2 in _h ) {
                TH1.attackChk ( TH2 , _effect , _mainHero ) ;
            }
        }
        
        //アイテムの攻撃判定
        for each ( ITEM in _i ) {
            for each ( TH1 in _h ) {
                ITEM.attackChk ( TH1 , _effect , _mainHero ) ;
            }
        }
        
        //移動判定
        for each ( TH1 in _h ) {
            for each ( TH2 in _h ) {
                TH1.moveChk ( TH2 ) ;
            }
        }
        
        
        
        //描画順決定
        _rendering_container = _rendering_container.concat ( _h ) ;
        _rendering_container = _rendering_container.concat ( _i ) ;
        _rendering_container.sort ( function ( A:Iactor , B:Iactor ) :Number { return A.pos.z - B.pos.z ; } ) ;
        
        //影描画
        for each ( SB in _rendering_container ) {
            SB.render_shadow ( ) ;
        }
        
        //描画
        for each ( SB in _rendering_container ) {
            SB.render ( ) ;
        }
        
        while ( _rendering_container.length ) {
            _rendering_container.pop ( ) ;
        }
        
        _effect.update ( ) ;
        _effect.render ( ) ;
        
        _scoreText.text = _score.toString () ;
        if ( _mainHero.getDeath ( ) ) {
            _end = true ;
            _S1.visible = true ;
            _S2.visible = true ;
        }
        
    }
    
    
}


//雑魚のモーション
class Hero extends CharctorBase {
        
    //アニメパターン
    private const $HERO_A:Array = [
        [ 0 , 1 , 2 , 3 ] , //歩く
        [ 32 , 33 , 34 , 35 , 36 , 37 ] , //走る
        [ 4 , 5 , 6 , 7 , 4 ] , //飛ぶ
        [ 8 , 9 ] , //パンチ
        [ 10 , 11 , 12 ] , //強いパンチ
        [ 13 , 4 ] , //ジャンプパンチ
        [ 14 , 4 ] , //ジャンプキック
        [ 29 , 15 ] , //キック
        [ 16 ] , //弱ダメージ
        [ 17 ] , //中ダメージ
        [ 18 ] , //強ダメージ
        [ 19 , 20 , 21 , 22 , 22 ] , //ダウン
        [ 7 , 4 ] ,//落下
        [ 24 , 25 , 26 , 27 , 0 ] //投擲 
    ];

    //ウェイト
    private const $HERO_B:Array = [
        [ 8 , 8 , 8 , 8 ] , //歩く
        [ 5 , 5 , 5 , 5 , 5 , 5 ] , //走る
        [ 2 , 2 , 5 , 2 , 5 ] , //飛ぶ
        [ 9 , 9 ] , //パンチ
        [ 7, 7, 8 ] , //強いパンチ
        [ 2 , 5 ] , //ジャンプパンチ
        [ 2 , 5 ] , //ジャンプキック
        [ 3 , 6 ] , //キック
        [ 15 ] , //弱ダメージ
        [ 15 ] , //中ダメージ
        [ 15 ] , //強ダメージ
        [ 9 , 9 , 9 , 9 , 99 ] , //ダウン
        [ 2 , 5 ] ,//落下
        [ 20 , 7 , 4 , 12 , 5 ] //投擲
    ] ;
    
    //入力の許可 1=移動 + 2=攻撃 + 4=ジャンプ + 8=投擲
    private const $HERO_C:Array = [
        [ 15, 15, 15, 15] , //歩く
        [ 15, 15, 15, 15, 15, 15] , //走る
        [ 0 , 2 , 2 , 2 , 0 ] , //飛ぶ
        [ 0 , 0 ] , //パンチ
        [ 0 , 0 , 0 ] , //強いパンチ
        [ 0 , 0 ] , //ジャンプパンチ
        [ 0 , 0 ] , //ジャンプキック
        [ 0 , 0 ] , //キック
        [ 0 ] , //弱ダメージ
        [ 0 ] , //中ダメージ
        [ 0 ] , //強ダメージ
        [ 0 , 0 , 0 , 0 , 0 ] , //ダウン
        [ 0 , 0 ] ,//落下
        [ 0 , 0 , 0 , 0 , 0 ] //投擲
    ] ;

    //アニメーションの条件 0=ウェイト 1=_velocity.yが+方向 2=地面に接地 3=終わらない
    private const $HERO_D:Array = [
        [ 0 , 0 , 0 , 0 ] , //歩く
        [ 0 , 0 , 0 , 0 , 0 , 0 ] , //走る
        [ 0 , 1 , 0 , 2 , 0 ] , //飛ぶ
        [ 0 , 0 ] , //パンチ
        [ 0 , 0 , 0 ] , //強いパンチ
        [ 2 , 0 ] , //ジャンプパンチ
        [ 2 , 0 ] , //ジャンプキック
        [ 0 , 0 ] , //キック
        [ 0 ] , //弱ダメージ
        [ 0 ] , //中ダメージ
        [ 0 ] , //強ダメージ
        [ 0 , 0 , 0 , 0 , 3 ] , //ダウン
        [ 2 , 0 ] ,//落下
        [ 0 , 0 , 0 , 0 , 0 ] //投擲
    ] ;

    //アニメーション切り替わりの際の特殊動作ＩＤ 1=ジャンプ 2=[歩くor落下]状態に戻る 3=飛び道具発生
    private const $HERO_E:Array = [
        [ 0 , 0 , 0 , 0 ] , //歩く
        [ 0 , 0 , 0 , 0 , 0 , 0 ] , //走る
        [ 1 , 0 , 0 , 0 , 2 ] , //飛ぶ
        [ 0 , 2 ] , //パンチ
        [ 0 , 0 , 2 ] , //強いパンチ
        [ 0 , 2 ] , //ジャンプパンチ
        [ 0 , 2 ] , //ジャンプキック
        [ 0 , 2 ] , //キック
        [ 2 ] , //弱ダメージ
        [ 2 ] , //中ダメージ
        [ 2 ] , //強ダメージ
        [ 0 , 0 , 0 , 0 , 2 ] , //ダウン
        [ 0 , 2 ] ,//落下
        [ 0 , 0 , 3 , 0 , 2 ] //投擲
    ] ;

    //攻撃判定
    private const $HERO_F:Array = [
        [ 0 , 0 , 0 , 0 ] , //歩く
        [ 0 , 0 , 0 , 0 , 0 , 0 ] , //走る
        [ 0 , 0 , 0 , 0 , 0 ] , //飛ぶ
        [ 0 , 1 ] , //パンチ
        [ 0 , 1 , 0 ] , //強いパンチ
        [ 1 , 0 ] , //ジャンプパンチ
        [ 1 , 0 ] , //ジャンプキック
        [ 0 , 1 ] , //キック
        [ 0 ] , //弱xダメージ
        [ 0 ] , //中ダメージ
        [ 0 ] , //強ダメージ
        [ 0 , 0 , 0 , 0 , 0 ] , //ダウン
        [ 0 , 0 ] ,//落下
        [ 0 , 0 , 0 , 0 , 0 ] //投擲
    ] ;

    public function Hero ( B:Bitmap , C:ColorTransform = null ) :void {
        super ( B , C , $HERO_A , $HERO_B , $HERO_C , $HERO_D , $HERO_E , $HERO_F ) ;
    }
    
}


////////////////////////////////////
const FILENAME:String = "http://assets.wonderfl.net/images/related_images/a/a7/a79f/a79f6550f46ab03e548ec7fee72569ee99b89823" ;
const ZERO_POINT:Point = new Point ( 0 , 0 ) ;
const ZMAX:int = 300 ;
var _score:uint = 0 ;
var _end:Boolean = false ;