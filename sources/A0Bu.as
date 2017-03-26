package {
    import flash.display.ActionScriptVersion;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.geom.Point;
    import flash.text.TextField;
    public class Main extends Sprite {
        
        private var model:JintoriModel;
        private var view:JintoriView;
        private var reciever:Reciever;
        private var ai:AI;
        private var tf:TextField;
        private var dialog:Dialog;
        
        public function Main() {
            //Settings
            var N:int = Configurations.N;
            model = new JintoriModel(N);
            view = new JintoriView(N, 300);
            view.x = stage.stageWidth / 2 - view.width / 2;
            view.y = stage.stageWidth / 2 - view.height / 2;
            addChild(view);
            this.reciever = new Reciever(N, 300);
            reciever.x = view.x;
            reciever.y = view.y;
            reciever.addEventListener("show_suggestion", onShowSuggestion);
            reciever.addEventListener("clear_suggestion", onClearSuggestion);
            reciever.addEventListener("submit_hand", playMyHand);
            addChild(reciever);
            ai = new AI(N);
            
            tf = new TextField();
            tf.x = stage.stageWidth / 2;
            tf.y = view.y + view.height + 10;
            tf.width = stage.stageWidth / 2;
            tf.text = "You: 0  Com: 0";
            addChild(tf);
            dialog = new Dialog(stage.stageWidth, stage.stageHeight);
            dialog.visible = false;
            dialog.addEventListener(MouseEvent.CLICK, init);
            addChild(dialog);
            myTurn();
        }
        
        private function init(event:Event = null):void {
            dialog.visible = false;
            model.init();
            view.init();
            tf.text = "You: 0  Com: 0";
        }
        
        private function myTurn():void {
            reciever.willSuggest = true;
            reciever.clickable = true;
            // -> onSubmitHand -> playMyHand
        }
        
        private function playMyHand(event:JintoriEvent = null):void {
            if (model.exists(event.x, event.y, event.z)) return;
            reciever.willSuggest = false;
            reciever.clickable = false;
            var ps:Array = model.put(event.x, event.y, event.z, JintoriModel.WHITE);
            view.addLine(event.x, event.y, event.z);
            if (ps[0] != null) view.addRect(ps[0].x, ps[0].y, JintoriModel.WHITE);
            if (ps[1] != null) view.addRect(ps[1].x, ps[1].y, JintoriModel.WHITE);
            if (updateInformation()) {
                onGameEnd();
                return;
            }
            if (ps[0] != null || ps[1] != null) myTurn();
            else comTurn();
        }
        
        private function comTurn():void {
            myTurn();
            playComHand(ai.think(model.lines, model.rects));
        }
        
        private function playComHand(p:Point3D):void {
            if (model.exists(p.x, p.y, p.z)) return;
            var ps:Array = model.put(p.x, p.y, p.z, JintoriModel.BLACK);
            view.addLine(p.x, p.y, p.z);
            if (ps[0] != null) view.addRect(ps[0].x, ps[0].y, JintoriModel.BLACK);
            if (ps[1] != null) view.addRect(ps[1].x, ps[1].y, JintoriModel.BLACK);
            if (updateInformation()) {
                onGameEnd();
                return;
            }
            if (ps[0] != null || ps[1] != null) comTurn();
            else myTurn();
        }
        
        private function onGameEnd():void {
            var countW:int = model.count(JintoriModel.WHITE);
            var countB:int = model.count(JintoriModel.BLACK);
            if (countW > countB) dialog.setMessage("You Win!");
            else if (countW < countB) dialog.setMessage("You Lose...");
            else dialog.setMessage("Draw");
            dialog.visible = true;
        }
        
        private function updateInformation():Boolean {
            var countW:int = model.count(JintoriModel.WHITE);
            var countB:int = model.count(JintoriModel.BLACK);
            tf.text = "You: " + countW + "  Com: " + countB;
            var N:int = Configurations.N;
            if (countW + countB == N * N) return true;
            return false;
        }
        
        private function onShowSuggestion(event:JintoriEvent):void {
            if (model.exists(event.x, event.y, event.z)) view.clearSuggestion();
            else view.showSuggestion(event.x, event.y, event.z);
        }
        
        private function onClearSuggestion(event:Event):void{
            view.clearSuggestion();
        }
    }
}
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.*;

//var trace:Function = Wonderfl.log;

class Configurations {
    public static const sensitivity:int = 15;
    public static const dot_color:int = 0x0000ff;
    public static const line_color:int = 0xdddd33;
    public static const suggest_line_color:int = 0x88dddd;
    public static const N:int = 3;
}

class AI extends EventDispatcher {
    
    private var _size:int;
    
    public function AI(size:int) {
        _size = size;
    }
    
    public function think(lines:Array, rects:Array):Point3D {
        var x:int;
        var y:int;
        var z:int;
        loop: 
        for (x = 0; x < _size + 1; x++) {
            for (y = 0; y < _size + 1; y++) {
                if(x != _size){
                    z = 0;
                    if (lines[x][y][z] == false) break loop;
                }
                if(y != _size){
                    z = 1;
                    if (lines[x][y][z] == false) break loop;
                }
            }
        }
        //while (true) {
            //z = int(Math.random() * 2);
            //x = int(Math.random() * (_size + (z?1:0)));
            //y = int(Math.random() * (_size + (z?0:1)));
            //if (lines[x][y][z] == false) break;
        //}
        return new Point3D(x, y, z);
    }
}

class Dialog extends Sprite {
    
    private var _tf1:TextField;
    private var _tf2:TextField;
    
    public function Dialog(w:int, h:int) {
        var g:Graphics = graphics;
        g.beginFill(0x000000, 0.5);
        g.drawRect(0, 0, w, h);
        g.endFill();
        _tf2 = new TextField();
        _tf2.defaultTextFormat = new TextFormat("Meiryo", 18, 0xffffff);
        _tf2.autoSize = TextFieldAutoSize.LEFT;
        _tf2.text = "Click to play again.";
        _tf2.x = width / 2 - _tf2.width / 2;
        _tf2.y = height / 2 - _tf2.height / 2;
        addChild(_tf2);
        _tf1 = new TextField();
        _tf1.defaultTextFormat = new TextFormat("Meiryo", 32, 0xffffff);
        _tf1.autoSize = TextFieldAutoSize.LEFT;
        addChild(_tf1);
    }
    
    public function setMessage(text:String):void {
        _tf1.text = text;
        _tf1.x = width / 2 - _tf1.width / 2;
        _tf1.y = _tf2.y - _tf1.height;
    }
}

class Reciever extends Sprite{
    
    private var _size:int;
    private var _wh:int;
    
    public function get willSuggest():Boolean{ return hasEventListener(Event.ENTER_FRAME); }
    public function set willSuggest(value:Boolean):void{
         if(value)addEventListener(Event.ENTER_FRAME, onEnterFrame);
         else {
            dispatchEvent(new Event("clear_suggestion"));
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
         }
    }
    
    public function get clickable():Boolean{ return hasEventListener(MouseEvent.CLICK); }
    public function set clickable(value:Boolean):void{
        if(value)addEventListener(MouseEvent.CLICK, onClick);
        else  removeEventListener(MouseEvent.CLICK, onClick);
    }
    
    public function Reciever(size:int, wh:int){
        this._size = size;
        this._wh = wh;
        //var hoge:Shape = new Shape();
        var g:Graphics = graphics;
        var s:int = Configurations.sensitivity;
        g.beginFill(0, 0);
        g.drawRect( -s, -s, wh + 2 * s, wh + 2 * s);
        g.endFill();
    }
    
    public function onClick(event:MouseEvent=null):void{
        var p:Point3D = range(mouseX, mouseY);
        if (p != null) dispatchEvent(new JintoriEvent("submit_hand", p.x, p.y, p.z));
    }
    
    public function onEnterFrame(event:Event=null):void{
        var p:Point3D = range(mouseX, mouseY);
        if(p == null)dispatchEvent(new Event("clear_suggestion"));
        else dispatchEvent(new JintoriEvent("show_suggestion", p.x, p.y, p.z));
    }
    
    private function range(x:int, y:int):Point3D{
        var s:int = Configurations.sensitivity;
        if(x < -s || x > _wh + s || y < -s || y > _wh + s){
            return null;
        }
        var interval:int = _wh / _size;
        var distanceX:int = Math.min(x % interval, interval - (x % interval));
        var distanceY:int = Math.min(y % interval, interval - (y % interval));
        if(distanceX > s && distanceY > s){
            return null;
        }
        if(distanceX < distanceY){
            if(int(y /interval) >= _size){
                return null;
            }
            return new Point3D(Math.round(x / interval), int(y / interval), 1);
        }
        else{
            if(int(x /interval) >= _size){
                return null;
            }
            return new Point3D(int(x / interval), Math.round(y / interval), 0);
        }
        return null;
    }

}

class JintoriEvent extends Event{
    private var _x:int;
    private var _y:int;
    private var _z:int;
    
    public function get x():int{ return _x; }
    public function get y():int{ return _y; }
    public function get z():int { return _z; }
    
    public function JintoriEvent(type:String, x:int, y:int, z:int){
        super(type);
        this._x = x;
        this._y = y;
        this._z = z;
    }
}


class JintoriView extends Sprite{
    private var _size:int;
    private var _wh:int;
    
    private var _suggest:Shape;
    
    public function JintoriView(size:int, wh:int){
        this._size = size;
        this._wh = wh;
        this._suggest = new Shape();
        addChild(_suggest);
        init();
    }
    
    public function init():void{
        var g:Graphics = graphics;
        g.clear();
        g.beginFill(Configurations.dot_color);
        for(var i:int = 0; i < _size + 1; i++){
            for(var j:int = 0; j < _size + 1; j++){
                g.drawCircle(i * _wh / _size, j * _wh / _size, 5);
            }      
        }
        g.endFill();
    }

    public function addLine(x:int, y:int, z:int):void{
        var g:Graphics = graphics;
        var interval:int = _wh / _size;
        g.lineStyle(5, Configurations.line_color);
        g.moveTo(x * interval, y * interval);
        if (z == 0) g.lineTo((x + 1) * interval, y * interval);
        else g.lineTo(x * interval, (y + 1) * interval);
    }
    
    public function showSuggestion(x:int, y:int, z:int):void{
        var g:Graphics = _suggest.graphics;
        var interval:int = _wh / _size;
        g.clear();
        g.lineStyle(5, Configurations.suggest_line_color, 1);
        g.moveTo(x * interval, y * interval);
        if (z == 0) g.lineTo((x + 1) * interval, y * interval);
        else g.lineTo(x * interval, (y + 1) * interval);
    }
    
    public function clearSuggestion():void{
        _suggest.graphics.clear();
    }
    
    public function addRect(x:int, y:int, who:int):void
    {
        var g:Graphics = graphics;
        var interval:int = _wh / _size;
        g.beginFill(who);
        g.drawRect(x * interval, y * interval, interval, interval);
        g.endFill();
    }

}

class JintoriModel{
    public static const NUTRAL:int = 0;
    public static const BLACK :int = 0xff0000;
    public static const WHITE :int = 0x00ff00;
    
    private var l:Array/*Boolean[size+1][size+1][2]*/; 
    private var t:Array/*int[size][size]*/;
    private var _size:int;
    
    public function JintoriModel(size:int){
        if(size > 10)throw new Error("size too big.");
        this._size = size;
        init();
    }
    
    public function init():void{
        this.l = [];
        for(var i:int = 0; i < _size + 1; i++){
            l[i] = [];
            for(var j:int = 0; j < _size + 1; j++){
                if(i == _size && j == _size)l[i][j] == [null, null];
                else if (i == _size) l[i][j] = [null, false];
                else if (j == _size) l[i][j] = [false, null];
                else l[i][j] = [false,false];
            }
        }
        this.t = [];
        for(i = 0; i < _size; i++){
            t[i] = [];
            for(j = 0; j < _size; j++){
                t[i][j] = NUTRAL;
            }
        }
    }
    
    public function put(x:int, y:int, z:int, who:int):Array{
        lines[x][y][z] = true;
        var res:Array = [null, null];
        if(z == 0){
            if (y != 0 && l[x][y - 1][0] && l[x][y - 1][1] && l[x + 1][y - 1][1]){
                t[x][y - 1] = who;
                res[0] = new Point(x, y - 1);
            }
            if (y != size && l[x][y][1] && l[x][y + 1][0] && l[x + 1][y][1]){
                t[x][y] = who;
                res[1] = new Point(x, y);
            }
        }
        else{
            if (x != 0 && l[x - 1][y][0] && l[x - 1][y][1] && l[x - 1][y + 1][0]){
                t[x - 1][y] = who;
                res[0] = new Point(x - 1, y);
            }
            if (x != size && l[x][y][0] && l[x][y + 1][0] && l[x + 1][y][1]){
                t[x][y] = who;
                res[1] = new Point(x, y);
            }
        }
        return res;
    }
    
    public function exists(x:int, y:int, z:int):Boolean {
        return l[x][y][z];
    }
    
    public function count(who:int):int {
        var res:int = 0;
        for (var i:int = 0; i < _size; i++) {
            for (var j:int = 0; j < _size; j++) {
                if (t[i][j] == who) res++;
            }
        }
        return res;
    }
    
    public function get lines():Array{ return l; }
    public function get rects():Array{ return t; }
    public function get size ():int  { return _size;  }
}

class Point3D {
    private var _x:int;
    private var _y:int;
    private var _z:int;
    
    public function get x():int { return _x; }
    public function get y():int { return _y; }
    public function get z():int { return _z; }
    
    public function Point3D(x:int, y:int, z:int) {
        this._x = x;
        this._y = y;
        this._z = z;
    }
}