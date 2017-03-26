//http://linktale.net/

package {

  import flash.display.Sprite; 

  [SWF(backgroundColor="0xffffff", frameRate="24")] 

  public class FlashTest extends Sprite { 
      public function FlashTest() { 
                //背景
                var bg_color:Number = 0xffffff;
                var background:Sprite = new Sprite();
                background.graphics.beginFill(bg_color);
                background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
                addChild(background);

        var _trick:Sprite = new Sen(this, 10, 0x000000, false);
        addChild( _trick );


     } 

  } 

}

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Point;
import flash.utils.Timer;
import flash.display.CapsStyle;

class Sen extends Sprite {
    //ワールド系
    private var _s:DisplayObjectContainer;
    private var _w:int;
    private var _h:int;
    private var _center_x:Number;
    private var _center_y:Number;
    private var _line_sp:Sprite = new Sprite();
    private var _light_sp:Sprite = new Sprite();
    
    //光系
    private var _light:Sprite = new Sprite();
    private var _light_list:Array = new Array();
    private var _light_num:int = 50;
    private var _light_flg:Boolean = false;
    
    //ポイント系
    private var _point:ekPoint;
    private var _point_list:Array = new Array();
    private var _point_size:Number = 1.0;
    private var _point_head:ekPoint;
    
    //設定系
    private var _rand_rate:Number;
    private var _friction:Number = 0.8 //跳ね
    private var _gravity_x:Number = 10.0; //重力
    private var _gravity_y:Number =  10.0; //重力
    private var _gravity_xvec:Number = 1; //重力方向
    private var _gravity_yvec:Number = 1; //重力方向
    private var _spring:Number = 0.003; //ばね
    private var _line_radius:Number = 30.0; //線の太さ
    private var _line_alpha:Number = 1.0; //線のアルファ
    private var _line_color:Number; //線の色
    private var _point_num:int = 50; //ポイント数

    //その他
    private var update_ctn:Number = 0;
                                                
    public function Sen( p_s:DisplayObjectContainer, p_rand_rate:Number = 5.0, p_line_color:Number = 0x000000, p_light_flg:Boolean = false ) {
        //WORLD系
        _s = p_s;
        _w = _s.stage.stageWidth; _h = _s.stage.stageHeight; 
        _center_x = _w / 2; _center_y = _h / 2;
        _rand_rate = p_rand_rate;
        _line_color = p_line_color;
        _light_flg = p_light_flg;
        
        init();
    }
    
    private function init():void {            
        //光のセット
        if(_light_flg){ setLight(); }
        
        //ポイントの先頭
        _point_head = new ekPoint(_w, _center_y);
        
        //配置
        addChild(_light_sp);
        addChild(_line_sp);
        
        var timer:Timer = new Timer(50, 0); 
          timer.addEventListener(TimerEvent.TIMER, createPoint); 
          timer.start(); 
        
        addEventListener( Event.ENTER_FRAME, update );
        addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
        addEventListener( Event.REMOVED, remove );
        _s.stage.addEventListener( Event.RESIZE, resize );
    }
    
    private function remove(e:Event):void {
        removeEventListener( Event.ENTER_FRAME, update );
        _s.stage.removeEventListener( Event.RESIZE, remove );
        removeEventListener( Event.REMOVED, resize );
    }
    
    private function resize( e:Event ):void {
        _w = _s.stage.stageWidth;
        _h = _s.stage.stageHeight;
        _center_x = _w / 2;
        _center_y = _h / 2;
    }
    
    private function setLight():void {
        var i:int;
        var blur_sp:Sprite = new Sprite();
        var blur:BlurFilter, filters:Array, blur_size:Number;
        var radius_rate:Number = 3.0;
        
        for ( i = 0; i < _light_num; i++) {
            var light:Sprite = new Sprite();
            light.x = -i * radius_rate * 2;
            light.y = -i * radius_rate * 2;
            
            light.graphics.clear();
            light.graphics.beginFill(0xffffff, 1.0);
            light.graphics.drawCircle( 0, 0, i * radius_rate);
            light.graphics.endFill();
            
            blur_size = 20;
            blur = new BlurFilter( blur_size , blur_size, BitmapFilterQuality.HIGH );
            filters = [blur];
            light.filters = filters;
            
            
            _light_list.push(light);
            
            _light_sp.addChild(light);
        }
            
    }
    
    private function createPoint(e:TimerEvent):void {        
        var i:Number;
        
        _point = new ekPoint(_point_head.x, _point_head.y);
        _point._vx = ( Math.random()) * _rand_rate;
        _point._vy = ( Math.random()) * _rand_rate;
        _point_list.push(_point);
        
        for (i = 0; i < _point_list.length; i++){
            if ( _point_list.length > _point_num ) {
                _point = _point_list.shift();
                
                break;
            }
        }
        
    }
    
    private function mouseMove(e:MouseEvent):void {
        e.updateAfterEvent () ;
    }
    
    private function update(e:Event):void {
        setPointHead();
        drawLine();
        move();
        follow();
        
        update_ctn++;
    }
    
    private function setPointHead():void {
        var vx:Number = ( _s.stage.mouseX - _point_head.x ) / 10;
        var vy:Number = ( _s.stage.mouseY - _point_head.y ) / 10;
        _point_head.x += vx;
        _point_head.y += vy;
    }
    
    private function drawLine():void {
        _line_sp.graphics.clear();
        
        if (_point_list.length >= 3) {
            var i:Number;
            var length_last:int = _point_list.length - 1;
            
            _line_sp.graphics.moveTo(_point_list[length_last].x, _point_list[length_last].y);
            
            var angle:Number = 0.0;
            //_point_list.reverse();
            for (i = length_last - 1; i >= 2; i-- ) {
                
                _point_size = Math.sin( angle ) * _line_radius;
                
                _line_sp.graphics.lineStyle(_point_size, _line_color, _line_alpha ,true, "normal", CapsStyle.ROUND); 
                _line_sp.graphics.curveTo( _point_list[i].x,
                                  _point_list[i].y,
                                  (_point_list[i].x + _point_list[i - 1].x) / 2,
                                  (_point_list[i].y + _point_list[i - 1].y) / 2);
                
                angle = angle + 0.1;
            }
            _line_sp.graphics.curveTo( _point_list[1].x, 
                              _point_list[1].y,
                              _point_list[0].x, 
                              _point_list[0].y);

            _point_size++;
        }
        
    }
    
    private function moveLight(p_i:Number, p_point:ekPoint):void {
        _light_list[p_i].x = p_point.x;
        _light_list[p_i].y = p_point.y;
    }
    
    private function follow():void {
        var i:Number;
        var dy:Number, ay:Number;
        
        for (i = _point_list.length - 1; i > 0; i-- ) {        
            dy = _point_list[i].y - _point_list[i - 1].y;
            ay = dy * _spring;
            _point_list[i]._vy += ay;
            
        }
        
        
    }
    
    private function move():void {
        var i:Number;
        var mx_vec:Number = 0;
        var mousex:Number = _s.stage.mouseX;
        var mousey:Number = _s.stage.mouseY;
        
        var x_rate:Number = Math.abs(mousex - _center_x) / _center_x;
        var y_rate:Number = Math.abs(mousey - _center_y) / _center_y;
        
        for (i = 0; i < _point_list.length; i++ ) {
            
            if ( mousex < _center_x) {
                _gravity_xvec = 1;
            }else {
                _gravity_xvec = -1;
            }
            
            if (_s.stage.mouseY < _center_y) {
                _gravity_yvec = 1;
            }else {
                _gravity_yvec = -1;
            }
            
            _point_list[i]._vx += _gravity_x * x_rate * _gravity_xvec;
            _point_list[i]._vx *= _friction;
            _point_list[i]._vy += _gravity_y * y_rate * _gravity_yvec;
            _point_list[i]._vy *= _friction;
            
            _point_list[i].x += _point_list[i]._vx;
            _point_list[i].y += _point_list[i]._vy;
            
            if(_light_flg){ moveLight(i, _point_list[i]); }
        }
        
        
        
    }
    
}

import flash.display.Sprite;

class ekPoint extends Sprite {
    public var _vx:Number = 0;
    public var _vy:Number = 0;
    public var _radius:Number = 0;
    
    public function ekPoint( p_x:Number, p_y:Number, p_radius:Number = 3 ) {
        x = p_x;
        y = p_y;
        _radius = p_radius;
        
        init();
    }
    
    public function init():void {
        var point_radius:Number = _radius;
        graphics.beginFill( 0x000000 , 1.0 );
        graphics.drawCircle( point_radius / 2, point_radius / 2, point_radius);
        graphics.endFill();    
    }
    
    public function changeRadius( p_radius:Number ):void {
        graphics.clear();
        graphics.beginFill( 0x000000 , 1.0 );
        graphics.drawCircle( p_radius / 2, p_radius / 2, p_radius);
        graphics.endFill();    
    }
    
}