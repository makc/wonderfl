package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;
    
    [SWF(frameRate="12")]
    /**
     * 補間して曲線を引きます
     * @author @kndys
     */
    public class Main extends Sprite 
    {
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            var curve:Curve = new Curve();
            var lastX:Number = mouseX, lastY:Number = mouseY;
            var press:Boolean = false;
            // MOUSE_MOVE ではなく ENTER_FRAME を使う。
            stage.addEventListener(Event.ENTER_FRAME, 
            function(e:Event):void 
            { 
                if (press)
                {
                    graphics.lineStyle(0, 0x4488ff, 0.5);
                    graphics.moveTo(lastX, lastY);
                    graphics.lineTo(lastX = mouseX, lastY = mouseY);
                    graphics.drawCircle(lastX, lastY, 2.5);
                    
                    graphics.lineStyle(0, 0x110022, 0.5);
                    curve.push(lastX, lastY, getTimer()); // 点(x,y,t)を追加
                    curve.draw(graphics); // 線を引く
                }
            } );
                
            stage.addEventListener(MouseEvent.MOUSE_DOWN, 
            function (e:Event):void 
            {
                press = true;
                graphics.lineStyle(0, 0x4488ff, 0.5);
                graphics.drawCircle(lastX = mouseX, lastY = mouseY, 2.5);
                curve.push(lastX, lastY, getTimer()); // 点(x,y,t)を追加
            } );
                
            stage.addEventListener(MouseEvent.MOUSE_UP, 
            function (e:Event):void 
            {
                if (press)
                {
                    graphics.lineStyle(0, 0x110022, 0.5);
                    curve.drawEnd(graphics); // 線を最後の点まで引く
                    curve.reset();
                }
                press = false;
            } );
        }
    }
}

    import flash.display.Graphics;
    /**
     * 動点にはたらく加速度が時間tの1次関数になっているという前提のもと
     * 離散点(x,y,t)間を曲線で補間する方法を思いつきました
     * どうせ車輪の再発明でしょうけど
     * @author @kndys
     */
    internal class Curve 
    {
        // (x,y,t) 3点と 初速(u0,v0) から曲線の式を求める
        private var _x0:Number, _y0:Number,
            _x1:Number, _y1:Number,
            _x2:Number, _y2:Number;
        private var _t0:int, _t1:int, _t2:int;
        private var _u0:Number, _v0:Number;
        
        // dt = t - t0 として
        // 位置を x(dt) = ax*dt^3 + bx*dt^2 + u0*dt + x0
        // 速度を u(dt) = 3*ax*dt^2 + 2*bx*dt + u0;
        // という関数でフィッティングする
        private var _ax:Number, _bx:Number,
            _ay:Number, _by:Number;
        // 上記係数が求まると次回計算の初速も求まる
        private var _u1:Number, _v1:Number;
        
        // pushされた点の数
        private var _sampleNum:uint;
            
        public function Curve() 
        {
            reset();
        }
        
        public function push(x:Number, y:Number, t:int):void
        {
            _x0 = _x1;
            _x1 = _x2;
            _x2 =  x;
            _y0 = _y1;
            _y1 = _y2;
            _y2 =  y;
            _t0 = _t1;
            _t1 = _t2;
            _t2 =  t;
            _sampleNum++;
            
            if (_sampleNum < 3) return; // 3点目までは計算しない
            
            _u0 = _u1;
            _v0 = _v1;
            
            var dx1:Number = _x1 - _x0;
            var dx2:Number = _x2 - _x0;
            var dy1:Number = _y1 - _y0;
            var dy2:Number = _y2 - _y0;
            var dt1:Number = _t1 - _t0;
            var dt2:Number = _t2 - _t0;
            if (dt2 == 0) dt2 = 1.0;
            if (dt1 == 0) dt1 = 0.5 * dt2;
            var k1:Number = 1.0 / (dt1 * dt1 * (dt1 - dt2)); 
            var k2:Number = 1.0 / (dt2 * dt2 * (dt2 - dt1)); 
            
            if (_sampleNum == 3)
            {
                _u0 = 0.0;//0.5 * dx1 / dt1;
                _v0 = 0.0;//0.5 * dy1 / dt1;
            }
            
            var p1:Number = dx1 - _u0 * dt1;
            var p2:Number = dx2 - _u0 * dt2;
            var q1:Number = dy1 - _v0 * dt1;
            var q2:Number = dy2 - _v0 * dt2;
            _ax = p1 * k1 + p2 * k2;
            _ay = q1 * k1 + q2 * k2;
            _bx = - p1 * k1 * dt2 - p2 * k2 * dt1;
            _by = - q1 * k1 * dt2 - q2 * k2 * dt1;
            // 次回の初速を求めておく
            _u1 = 3 * _ax * dt1 * dt1 + 2 * _bx * dt1 + _u0;
            _v1 = 3 * _ay * dt1 * dt1 + 2 * _by * dt1 + _v0;
        }
        
        public function draw(g:Graphics):void
        {
            if (_sampleNum < 3) return; // 線が引けない
            
            var dx1:Number = _x1 - _x0;
            var dy1:Number = _y1 - _y0;
            var dt1:Number = _t1 - _t0;
            
            // 曲線の分割数 直線距離ピクセル数の半分とした
            var n:int = (0.5 * Math.sqrt(dx1 * dx1 + dy1 * dy1) | 0) + 1;
            
            g.moveTo(_x0, _y0);
            for (var i:int = 1; i <= n; i++)
            {
                var tt:Number = dt1 * i / n;
                var tt2:Number = tt * tt;
                var tt3:Number = tt2 * tt;
                var xt:Number = _ax * tt3 + _bx * tt2 + _u0 * tt + _x0;
                var yt:Number = _ay * tt3 + _by * tt2 + _v0 * tt + _y0;
                g.lineTo(xt, yt);
            }
            
        }
        
        public function drawEnd(g:Graphics):void
        {
            if (_sampleNum < 2) return;
            else if (_sampleNum == 2)
            {
                g.moveTo(_x0, _y0);
                g.lineTo(_x1, _y1);
                return;
            }
            
            // 最後の1点まで線を引くために、前回計算した係数の値をそのまま利用する。
            var dx:Number = _x2 - _x1;
            var dy:Number = _y2 - _y1;
            var dt10:Number = _t1 - _t0;
            var dt21:Number = _t2 - _t1;
            var n:int = (0.5 * Math.sqrt(dx * dx + dy * dy) | 0) + 1;
            g.moveTo(_x1, _y1);
            for (var i:int = 1; i <= n; i++)
            {
                var tt:Number = dt10 + (dt21 * i / n);
                var tt2:Number = tt * tt;
                var tt3:Number = tt2 * tt;
                var xt:Number = _ax * tt3 + _bx * tt2 + _u0 * tt + _x0;
                var yt:Number = _ay * tt3 + _by * tt2 + _v0 * tt + _y0;
                g.lineTo(xt, yt);
            }
        }
        
        public function reset():void
        {
            _sampleNum = 0;
        }
    }