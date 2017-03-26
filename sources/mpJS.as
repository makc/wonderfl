/**
 * ふわふわしたラインを書いてみたくなった。
 * マウスでキャンバスをドラッグしてください。
 * ラインはCatmull-Romスプライン曲線で書いてみました。
 * 参考：http://l00oo.oo00l.com/blog/archives/264
 **/
package
{
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import net.hires.debug.Stats;
    
    [SWF(backgroundColor="0x000000",frameRate="60")]
    
    public class HuwahuwaLine extends Sprite
    {
        
        private var _canvas:Sprite;
        private var _lines:Vector.<Vector.<StrokePoint>>;
        private var _currentStroke:Vector.<StrokePoint>;
        private var _isRec:Boolean = false;
        
        private var _output:Label;
        
        public function HuwahuwaLine()
        {
            super();
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            stage.addChild(new Stats());
            
            Wonderfl.capture_delay( 60 );
            
            _init();
        }
        
        private function _init():void
        {
            _output = new Label(stage, 0, 100, "points");
            var _clear:PushButton = new PushButton(stage, stage.stageWidth - 70, 10, "CLEAR", _clearHandler);
            _clear.width = 60;
            
            _lines = new Vector.<Vector.<StrokePoint>>;
            
            _canvas = new Sprite();
            _canvas.graphics.beginFill(0x0, 1);
            _canvas.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            _canvas.graphics.endFill();
            addChild(_canvas);
            
            _canvas.addEventListener(MouseEvent.MOUSE_DOWN, _downHandler);
            _canvas.addEventListener(MouseEvent.MOUSE_UP, _upHandler);
            
            addEventListener(Event.ENTER_FRAME, _enterframeHandler);
        }
        
        private function _downHandler(e:MouseEvent):void
        {
            //_clearStroke();
            _lines[_lines.length] = _currentStroke = new Vector.<StrokePoint>;
            _isRec = true;
        }
        
        private function _upHandler(e:MouseEvent):void
        {
            _isRec = false;
        }
        
        private function _enterframeHandler(e:Event):void
        {
            if(_isRec) _recStroke();
            
            var g:Graphics = _canvas.graphics;
            g.clear();
            g.beginFill(0x0, 1);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            g.endFill();
            
            _drawStroke(g);
        }
        
        private function _recStroke():void
        {
            var point:StrokePoint = new StrokePoint(stage.mouseX, stage.mouseY);
            if(_currentStroke.length && _currentStroke[_currentStroke.length-1].near(point)) return;
            _currentStroke[_currentStroke.length] = point;
        }
        
        private function _drawStroke(g:Graphics):void
        {
            var points:int = 0;
            
            g.lineStyle(2, 0xFFFFFF, 1);
            for each(var stroke:Vector.<StrokePoint> in _lines) {
                if(stroke.length < 2) continue;
                stroke = stroke.concat();
                stroke.unshift(stroke[0]);
                stroke.push(stroke[stroke.length-1]);
                var first:Boolean = true;
                for(var i:int = 1, l:int = stroke.length-2; i < l; i++) {
                    var p0:StrokePoint = stroke[i-1];
                    var p1:StrokePoint = stroke[i];
                    var p2:StrokePoint = stroke[i+1];
                    var p3:StrokePoint = stroke[i+2];
                    for(var ii:Number = 0, ll:Number = 1; ii < ll; ii+=.2) {
                        var x:Number = catmullRom(p0.x, p1.x, p2.x, p3.x, ii);
                        var y:Number = catmullRom(p0.y, p1.y, p2.y, p3.y, ii);
                        if(first) g.moveTo(x, y);
                        else g.lineTo(x, y);
                        first = false;
                        points++;
                    }
                }
            }
            
            _output.text = points + "points";  
        }
        
        public function catmullRom(p0:Number,p1:Number,p2:Number,p3:Number,t:Number):Number
        {
              var v0:Number = (p2 - p0) * 0.5;
              var v1:Number = (p3 - p1) * 0.5;
              return (2*p1 - 2*p2 + v0 + v1)*t*t*t +
                    (-3*p1 + 3*p2 - 2*v0 - v1)*t*t + v0*t + p1;
        }
        
        private function _clearHandler(e:MouseEvent):void
        {
            _clearStroke();
        }
        
        private function _clearStroke():void
        {
            for each(var stroke:Vector.<StrokePoint> in _lines) {
                for each(var point:StrokePoint in stroke) {
                    point.destroy();
                } 
            }
            _lines.splice(0, _lines.length);
        }
    }
}

import flash.geom.Point;

import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Quad;
import org.libspark.betweenas3.tweens.ITween;

class StrokePoint extends Point {
    
    public var rawX:Number;
    public var rawY:Number;
    
    private var _tween:ITween;
    
    public function StrokePoint(x:Number=0, y:Number=0)
    {
        super(x, y);
        rawX = x;
        rawY = y;
        
        _update();
    }
    
    private function _update():void
    {
        _tween = BetweenAS3.to(this, {x: rawX + _getYuragi(), y: rawY + _getYuragi()}, .05, Quad.easeInOut);
        _tween.onComplete = _update;
        _tween.play();
    }
    
    public function destroy():void
    {
        if(_tween) _tween.stop();
    }
    
    private function _getYuragi():Number
    {
        return Math.random()*2-1;
    }
    
    public function near(pt:StrokePoint):Boolean
    {
        return Point.distance(this, pt) < 5;
    }
}