//http://linktale.net/

package {

  import flash.display.Sprite; 

  [SWF(backgroundColor="0xffffff", frameRate="24")] 

  public class FlashTest extends Sprite { 
      public function FlashTest() { 
         var _trick:Sprite = new Kyu( this, stage.stageWidth / 2, stage.stageHeight / 2, -10, 3, 0x333333, 1, 3.0);
         addChild( _trick );
     } 

  } 

}

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;

class Kyu extends Sprite {
    //parent stage
    private var _w:int;
    private var _h:int;
    private var _center_x:Number;
    private var _center_y:Number;
    //main
    private var _nami_color:uint //波の色
    private var _cell_w:int = 1; //波の横幅
    private var _cell_h:int = 1; //波の縦幅
    private var _cell_amout:int; //セルの横幅
    private var _cell_cnt:int; //セルの数
    private var _cell_list:Array = new Array(); //波セルのリスト 
    private var _mouse_area:Number = 20.0;
    //nami
    private var _period:Number = 2.0; //周期T
    private var _a_min:Number = 0.0; //振幅の最小値（まるめ）
    private var _f:Number = 3.0; //振幅数
    private var _t:int = 1; //波時間
    private var _nami_spring:Number = 0.01; //ばね
    private var _nami_friction:Number = 0.8; //跳ね
    private var _up_rate:Number;
    //kyu
    private var _kyu_radius:int = 150; //球の半径
    private var _kyu_line:int //球の長さ
    private var _kyu_def_posi:Array = new Array(); //球のデフォルトポジション
    //nami patter
    private var _motion_y:Number = 0.0;
    private var _motion_vy:Number = 0.0;
    //count
    private var _enter_nami_cnt:int = 0; //Nami EnterFrame回数
    private var _motion_cnt:int = 0; //自動波用カウント
    //mouse
    private var _mousex_now:Number;
    private var _mousey_now:Number;
    private var _mousex_pre:Number;
    private var _mousey_pre:Number;
    
    //const
    private const DEBUG:Boolean = true; //デバッグモード
    private const AROUND_NAMI_A:Number = 0.2;
    private const AROUND_NAMI_POSI:Number = 0.3;
    
    public function Kyu( p_s:DisplayObjectContainer, p_x:int, p_y:int, p_w:int, p_h:int, p_color:uint, p_amount:int, p_up_rate:Number ) {
        //WORLD系
        _w = p_s.stage.stageWidth; _h = p_s.stage.stageHeight; 
        _center_x = p_x; _center_y = p_y;
        //波系
        _nami_color = p_color; 
        _cell_w = p_w;
        _cell_h = p_h; 
        _cell_amout = p_amount;
        _up_rate = p_up_rate;
        //球系
        _kyu_line = 2 * Math.PI * _kyu_radius; 
        //セル系
        _cell_cnt = _kyu_line / _cell_amout;
        //マウス系
        _mousex_now = _center_x;
        _mousey_now = _center_y;
        _mousex_pre = _center_x;
        _mousey_pre = _center_y;
        
        init();
    }
    
    private function init():void {
        setCell();
        addEventListener( Event.ENTER_FRAME, onEnterFrameNami );
    }
    
    //セルをセット
    private function setCell():void {
        var i:uint;
        var cell:Cell;
        var x:Number, y:Number, dx:Number, dy:Number, angle:Number, rotation:Number;
        
        //セルの配置
        for (i = 0; i < _cell_cnt; i++ ) {                
            //セルのデフォルト位置を定義
            /*var red:uint = 255 / _cell_cnt * i;
            var color:uint = i << 16 | 0 << 8 | 0;*/
            cell = new Cell( _cell_w, _cell_h, _nami_color );
            //セルのバーチャル位置セット
            cell._x = i * _cell_amout;
            cell._y = _center_y;
            
            //球のデフォルト位状態をセット
            angle = Math.PI * 2 / _cell_cnt * i - Math.PI / 2;
            x = _kyu_radius * Math.cos(angle) + _center_x;
            y = _kyu_radius * Math.sin(angle) + _center_y;
            dx = x - _center_x;
            dy = y - _center_y;
            angle = Math.atan2(dy, dx);
            rotation = ( angle - Math.PI / 2 ) * 180 / Math.PI;
            _kyu_def_posi.push(new Array(x-cell._x, y-cell._y, x, y, rotation));
            //_kyu_def_posi.push(new Array(0, 0, cell._x, cell._y, 0));
            
            //セル配置
            addChild(cell);
            _cell_list.push(cell);
            
            //if (DEBUG) cell.x = x; cell.y = y; cell.rotation = rotation; //デバッグ表示
        }
    }
    
    private function onEnterFrameNami(e:Event):void {
        mouseSet();
        namiMove(); //描画
        _enter_nami_cnt++;
    }
    
    private function mouseSet():void {
        _mousex_pre = _mousex_now;
        _mousey_pre = _mousey_now;
        
        _mousex_now = mouseX;
        _mousey_now = mouseY;
    }
    
    //波を動かす処理
    private function namiMove():void {
        var i:uint, x:Number, y:Number, dx:Number, dy:Number, dist:Number ,angle:Number;
        
        for (i = 0; i < _cell_cnt; i++ ) {
            //○目がうまくいっていない
            dx = _cell_list[i].x - _kyu_def_posi[i][2];
            dy = _cell_list[i].y - _kyu_def_posi[i][3];
            dist = Math.sqrt( dx * dx + dy * dy );
                
            if ( Math.abs(_cell_list[i]._a) <= AROUND_NAMI_A && dist <= AROUND_NAMI_POSI) {
                //丸め処理
                _cell_list[i].x = _kyu_def_posi[i][2];
                _cell_list[i].y = _kyu_def_posi[i][3];
                _cell_list[i]._a = 0;
            }else {
                //定常波の方程式
                y = _cell_list[i]._a * Math.sin( _t / _period - i * _cell_amout / _f );
                
                angle = _kyu_def_posi[i][4] * Math.PI / 180 - Math.PI / 2;
                x = Math.cos(angle) * y;
                y = Math.sin(angle) * y;
                
                y += _center_y;
                _cell_list[i]._v_x = _cell_list[i]._x + x;
                _cell_list[i]._v_y = y; //描画
                
                //加速度をばねる
                springA(_cell_list[i]); //振幅を変化

                //一時変換
                var flg:int = 1;
                if (flg == 1) {
                    //ここに処理を追加 CPU減
                    _cell_list[i].x = _cell_list[i]._v_x + _kyu_def_posi[i][0];
                    _cell_list[i].y = _cell_list[i]._v_y + _kyu_def_posi[i][1];
                    _cell_list[i].rotation = _kyu_def_posi[i][4];
                }else if(flg==2){
                    _cell_list[i].x = _cell_list[i]._x;
                    _cell_list[i].y = _cell_list[i]._y;
                }
            }
                            
            //マウスチェック
            //addMouseValue(_cell_list[i]);
            checkWave( i, mouseX, mouseY, _up_rate );
        }
        _t++; //波時間を進める
    }
    
    //波の振幅をばねで計算
    private function springA( p_cell:Cell ):void {
        var dx:Number, ax:Number;
        
        dx = _a_min - p_cell._a;
        ax = dx * _nami_spring;
        p_cell._vx += ax;
        p_cell._vx *= _nami_friction;
        p_cell._a += p_cell._vx;
    }
    
    private function addMouseValue( p_cell:Cell ):void{
        var dx:Number, dy:Number, dist:Number, max:Number, per:Number;
        
        max = _w;
        dx = p_cell.x - _mousex_now;
        dy = p_cell.y - _mousey_now;
        dist = Math.sqrt( dx * dx + dy * dy );
        per = ( max - dist ) / max;
        
        p_cell._a += (_mousex_now - _mousex_pre) * per * 0.1;
    }
    
    //マウスチェック
    private function checkWave(p_i:int, p_target_x:Number, p_target_y:Number, nami_rate:Number ):void {
        var dx:Number = _cell_list[p_i].x - p_target_x;
        var dy:Number = _cell_list[p_i].y - p_target_y;
        var dist:Number = Math.sqrt( dx * dx + dy * dy );
        
        if (dist < _mouse_area) {
            addWave(p_i, nami_rate);
        }
    }
    
    //波追加
    private function addWave(target:int,up_rate:Number):void {
        wavePattern1(target,up_rate);
    }

    //波パターン
    private function wavePattern1(p_i:int, up_rate:Number):void {
        var i:uint, y:Number;
        var start_i:int = p_i - 100; if (start_i < 0) { start_i = 0; }
        var end_i:int =  p_i + 100; if (end_i > _cell_cnt) { end_i = _cell_cnt; }
        var dist:Number;
        
        for (i = start_i; i < end_i; i++) {
            dist = Math.abs((p_i - i)); if (dist == 0) { dist = 1.0; }
            y = 1 / dist * up_rate;
            _cell_list[i]._a += y;
        }
    }
    
}

import flash.display.Sprite;

class Cell extends Sprite {
    public var _x:Number = 0;
    public var _y:Number = 0;
    public var _v_x:Number = 0;
    public var _v_y:Number = 0;
    public var _w:int = 0;
    public var _h:int = 0;
    public var _rotaion:Number = 0;
    public var _color:int = 0;
    public var _a:Number = 0.0; //振幅
    public var _vx:Number = 0.0; //速度
    
    public function Cell( p_w:Number = 1, p_h:Number = 1, p_color:uint = 0xffffff ) {
        _w = p_w;
        _h = p_h;
        _color = p_color;
        
        graphics.beginFill(_color); 
        graphics.drawRect(-_w/2, 0, _w, _h);  
    }        
}