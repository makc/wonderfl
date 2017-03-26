/*
   積分の復習
   区分求積法的なことをAS3でやってみる。
   微小な短冊形の長方形を敷き詰め、
   その長方形の面積の総和によって関数の面積を確定する方法。
 */
package {
    import flash.display.Sprite;
    
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends Sprite {
        public function Main() {
            // ビュー
            view = new View();
            addChild(view);
            // コントローラー
            controller = new Controller();
            addChild(controller);
            // モデル
            model = new Model(view, controller);
        }
        private var controller:Controller;
        private var model:Model;
        private var view:View;
    }
}
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import jp.nium.utils.NumberUtil;
import jp.progression.commands.Func;
import jp.progression.commands.lists.TweenList;

/**
 * MVCのModelを担当するクラスです。
 */
class Model {
    /**
     * 計算を行うxの最大値です。
     */
    public static const MAX_X:Number = 400;
    
    /**
     * 新しいModelインスタンスを作成します。
     */
    public function Model(view:View, controller:Controller):void {
        _view = view;
        _controller = controller;
        _controller.addEventListener(Controller.STEP_0_EVENT, _onClick);
        _controller.addEventListener(Controller.STEP_1_EVENT, _onClick);
        _controller.addEventListener(Controller.STEP_2_EVENT, _onClick);
        _controller.addEventListener(Controller.STEP_3_EVENT, _onClick);
    }
    private var _controller:Controller;
    private var _view:View;
    
    /**
     * 二次曲線の関数
     * @param value x
     * @return y
     */
    private function _func(value:Number):Number {
        return 0.002 * value * value + 50;
    }
    
    /**
     * コントローラーのイベントハンドラー
     * @param event
     */
    private function _onClick(event:Event):void {
        var calcStep:int;
        switch (event.type) {
            case Controller.STEP_0_EVENT:
                calcStep = Controller.STEP_0_NUM;
                break;
            case Controller.STEP_1_EVENT:
                calcStep = Controller.STEP_1_NUM;
                break;
            case Controller.STEP_2_EVENT:
                calcStep = Controller.STEP_2_NUM;
                break;
            case Controller.STEP_3_EVENT:
                calcStep = Controller.STEP_3_NUM;
                break;
        }
        var results:Vector.<Number> = new Vector.<Number>();
        for (var i:int = 0; i < MAX_X; i++) {
            results[ i ] = _func(i);
        }
        var integrate:Vector.<IntegrateData> = new Vector.<IntegrateData>();
        for (i = 0; i < calcStep; i++) {
            integrate[ i ] = new IntegrateData();
            integrate[ i ].value = _func(MAX_X / calcStep * i);
            var add:Number = integrate[ i ].value * MAX_X / calcStep;
            integrate[ i ].sum = i == 0 ? add : integrate[ i - 1 ].sum + add;
        }
        _view.draw(results, integrate);
    }
}

/**
 * 区分積分の値を保持するクラスです。
 */
class IntegrateData {
    /**
     * n=xまでの加算値を保持します。
     * Viewでの表示のために設けた変数です。
     */
    public var sum:Number = 0;
    /**
     * dxの計算結果を保持します。
     */
    public var value:Number = 0;
}

/**
 * MVCのViewを担当するクラスです。
 */
class View extends Sprite {
    private static const GRAPH_RECT:Rectangle = new Rectangle(15, 15, 440, 400);
    private static const STAGE_RECT:Rectangle = new Rectangle(0, 0, 465, 465);
    private static const STEP:Number = 20;
    
    /**
     * 新しいViewインスタンスを作成します。
     */
    public function View():void {
        // 背景
        _bg = new Shape();
        _bg.graphics.beginFill(0);
        _bg.graphics.drawRect(STAGE_RECT.x, STAGE_RECT.y, STAGE_RECT.width, STAGE_RECT.height);
        addChild(_bg);
        
        // 目盛り
        _division = new Shape();
        _division.graphics.lineStyle(1, 0x333333);
        for (var i:int = 0; i <= GRAPH_RECT.width; i++) {
            if (i % STEP == 0) {
                _division.graphics.moveTo(i, 0);
                _division.graphics.lineTo(i, GRAPH_RECT.height);
            }
        }
        for (var j:int = 0; j <= GRAPH_RECT.height; j++) {
            if (j % STEP == 0) {
                _division.graphics.moveTo(0, j);
                _division.graphics.lineTo(GRAPH_RECT.width, j);
            }
        }
        _division.x = GRAPH_RECT.x;
        _division.y = GRAPH_RECT.y;
        addChild(_division);
        
        // グラフ
        _canvas = new Sprite();
        _canvas.x = GRAPH_RECT.x;
        _canvas.y = GRAPH_RECT.y;
        addChild(_canvas);
        
        new Label(this, 17, 17, "INTEGRATION APP");
        _sumLabel = new Label(this, 17, 36, "SUM : 0");
    }
    private var _bg:Shape;
    private var _canvas:Sprite;
    private var _cmd:TweenList;
    private var _division:Shape;
    private var _integrate:Vector.<IntegrateData>;
    private var _results:Vector.<Number>;
    private var _sumLabel:Label;
    
    /**
     * Modelで計算した結果を描写します
     */
    public function draw(results:Vector.<Number>, integrate:Vector.<IntegrateData>):void {
        _results = results;
        _integrate = integrate;
        _canvas.graphics.clear();
        _drawResults();
        if (_cmd && _cmd.state != 0)
            _cmd.interrupt();
        _cmd = new TweenList(1);
        for (var i:int = 0; i < _integrate.length; i++) {
            _cmd.addCommand(new Func(_drawIntegrate, [ i ]));
        }
        _cmd.execute();
    }
    
    /**
     * 区分積分の結果を描写します
     */
    private function _drawIntegrate(i:int):void {
        _canvas.graphics.lineStyle(1, 0xFFFFFF);
        _canvas.graphics.beginFill(0xFFFFFF, 0.25);
        _canvas.graphics.drawRect(i * GRAPH_RECT.width / _integrate.length, GRAPH_RECT.height - _integrate[ i ].value, GRAPH_RECT.width / _integrate.length, _integrate[ i ].value);
        _canvas.graphics.endFill();
        _sumLabel.text = "SUM : " + NumberUtil.format(Math.round(_integrate[ i ].sum));
    }
    
    /**
     * 二次曲線の結果を描写します
     */
    private function _drawResults():void {
        for (var i:int = 0; i < _results.length; i++) {
            if (i == _results.length - 1)
                continue;
            _canvas.graphics.lineStyle(1, 0xFF0000);
            _canvas.graphics.moveTo(i * GRAPH_RECT.width / _results.length, GRAPH_RECT.height - _results[ i ]);
            _canvas.graphics.lineTo((i + 1) * GRAPH_RECT.width / _results.length, GRAPH_RECT.height - _results[ i + 1 ]);
        }
    }
}

/**
 * MVCのControllerを担当するクラスです。
 */
class Controller extends Sprite {
    public static const STEP_0_EVENT:String = "stepBig";
    public static const STEP_0_NUM:int = 10;
    public static const STEP_1_EVENT:String = "stepMiddle";
    public static const STEP_1_NUM:int = 20;
    public static const STEP_2_EVENT:String = "stepSmall";
    public static const STEP_2_NUM:int = 50;
    public static const STEP_3_EVENT:String = "stepNano";
    public static const STEP_3_NUM:int = 120;
    
    /**
     * 新しいControllerインスタンスを作成します。
     */
    public function Controller() {
        _btnA = new PushButton(this, 15, 430, "CALC n=" + STEP_0_NUM, _onClick);
        _btnB = new PushButton(this, 125, 430, "CALC n=" + STEP_1_NUM, _onClick);
        _btnC = new PushButton(this, 235, 430, "CALC n=" + STEP_2_NUM, _onClick);
        _btnD = new PushButton(this, 345, 430, "CALC n=" + STEP_3_NUM, _onClick);
    }
    private var _btnA:PushButton;
    private var _btnB:PushButton;
    private var _btnC:PushButton;
    private var _btnD:PushButton;
    
    /**
     * @private
     */
    private function _onClick(e:Event):void {
        switch (e.currentTarget) {
            case _btnA:
                dispatchEvent(new Event(STEP_0_EVENT));
                break;
            case _btnB:
                dispatchEvent(new Event(STEP_1_EVENT));
                break;
            case _btnC:
                dispatchEvent(new Event(STEP_2_EVENT));
                break;
            case _btnD:
                dispatchEvent(new Event(STEP_3_EVENT));
                break;
        }
    }
}