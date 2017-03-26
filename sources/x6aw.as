package {
    import flash.display.*;
    import flash.text.TextField;
    import flash.events.*;
    import flash.net.*;
    import com.bit101.components.*;
    import flash.utils.*;
    import com.adobe.serialization.json.*;

    public class Test extends Sprite {
        private var _tf : TextField;
        private var _apikey : String;
        private var _text : InputText;
        private var _canvas : Sprite; // グラフ描画先
        private var _tree : Object;　// <id:String, json:Object>
        private var _root : String; // ルートID
        
        private var _openangle : HUISlider;
  
        public function Test() {
            _tf = new TextField();
            _tf.width = 200;
            _tf.height = 400;
//            addChild(_tf); 
            
            _apikey = loaderInfo.parameters["open_api_key"];
            
        		_canvas = new Sprite();
        		addChild(_canvas);
        		_canvas.scaleX = 1;
        		_canvas.scaleY = 1;
        		_canvas.x = 465 / 2;
        		_canvas.y = 400;
        		_canvas.mouseChildren = false;
        		_canvas.mouseEnabled = false;
        		
        		stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e : MouseEvent) : void { if(e.target == stage)_canvas.startDrag(); });
        		stage.addEventListener(MouseEvent.MOUSE_UP, function(e : MouseEvent) : void { if(e.target == stage)_canvas.stopDrag(); });
        		
            _text = new InputText(this, 10, 10, "http://wonderfl.net/c/sFXf");
            _text.width = 200;
            _text.height = 20;
            var submit : PushButton = new PushButton(this, 220, 10, "Submit", onSubmit);
            
            var zoom : HUISlider = new HUISlider(this, 10, 40, "ZOOM", function(e : Event) : void { 
            		var prev : Number = _canvas.scaleX;
            		_canvas.scaleX = zoom.value;
            		_canvas.scaleY = zoom.value;
            		_canvas.x = 465/2 - (465/2 - _canvas.x) * zoom.value / prev;
            		_canvas.y = 465/2 - (465/2 - _canvas.y) * zoom.value / prev;
            });
            zoom.labelPrecision = 2; zoom.tick = 0.01;
            zoom.minimum = 0.1; zoom.maximum = 1.0; zoom.value = 1.0;
            _openangle = new HUISlider(this, 10, 60, "ANGLE", function(e : Event) : void {
            		arrange(_root);
            });
            _openangle.labelPrecision = 0; _openangle.tick = 1;
            _openangle.minimum = 0; _openangle.maximum = 360; _openangle.value = 150;
        }
        
        private function onSubmit(e : MouseEvent) : void
        {
        		var id : String = _text.text.match(/(?<=\/)[0-9A-Za-z]*$/)[0];
        		if(id == "")return;
        		
        		if(_tree){
        			for each(var val : Object in _tree){
        				if(val.loader)_canvas.removeChild(val.loader);
        			}
        		}
        		_canvas.graphics.clear();
        		_root = id;
            _tree = {};
            _tree[id] = {};
            
        		loadCode(id); // ルートノードの情報はforkでは得られないのでcodeで得る
        		loadFork(id); // forkを探索
        }
        
        private function loadCode(id : String) : void
        {
        		if(id == null)return;
        		tr(id);
        		var ul : URLLoader = new URLLoader(new URLRequest(
        			"http://api.wonderfl.net/code/" + id + "?api_key=" + _apikey
        			));
        		ul.addEventListener(Event.COMPLETE, onCodeLoaded);
        }
        
        private function onCodeLoaded(e : Event) : void
        {
        		var ul : URLLoader = URLLoader(e.target);
        		ul.removeEventListener(Event.COMPLETE, onCodeLoaded);
        		
        		var json : Object = JSON.decode(ul.data);
//        		tr(ObjectUtil.toString(json));
			if(!_tree[json.code.id])_tree[json.code.id] = {};
			for(var key : String in json.code){
				_tree[json.code.id][key] = json.code[key];
			}
//			_tree[json.code.id] = json.code;
         		
    			var container : Sprite = createContainer(json.code);
    			_canvas.addChild(container);
        		_tree[json.code.id].loader = container;
        		arrange(_root);
        }

        private function loadFork(id : String) : void
        {
        		if(id == null)return;
//        		tr(id);
        		var ul : URLLoader = new URLLoader(new URLRequest(
        			"http://api.wonderfl.net/code/" + id + "/forks?api_key=" + _apikey
        			));
        		ul.addEventListener(Event.COMPLETE, onForkLoaded);
        }
        
        private function onForkLoaded(e : Event) : void
        { 
        		var ul : URLLoader = URLLoader(e.target);
        		ul.removeEventListener(Event.COMPLETE, onForkLoaded);
        		
        		var json : Object = JSON.decode(ul.data);
//        		tr(ObjectUtil.toString(json));
        		if(json.forks){
	        		for each(var fork : Object in json.forks){
	        			// 親に子を追加
	        			if(!_tree[fork.parent])_tree[fork.parent] = {};
	        			if(!_tree[fork.parent].children)_tree[fork.parent].children = [];
	        			_tree[fork.parent].children.push(fork.id);
	        			
	        			// 木にノードを追加
	        			_tree[fork.id] = fork;
	        			
	        			// フォークを探索
	        			loadFork(fork.id);
	        			
	        			// サムネイルをロード
	        			var container : Sprite = createContainer(fork);
		        		_canvas.addChild(container);
		        		_tree[fork.id].loader = container;
	        		}
	        		arrange(_root);
	        }
        }
        
        private function createContainer(data : Object) : Sprite
        {
    			var container : Sprite = new Sprite();
    			container.mouseEnabled = false;
    			container.mouseChildren = false;
    			
        		var l : Loader = new Loader();
        		l.load(new URLRequest(data.thumbnail));
        		l.x = -50; l.y = -50;
        		container.addChild(l);
        		
        		var tfUser : TextField = new TextField();
        		tfUser.x = -50; tfUser.y = 50;
        		tfUser.text = data.user.name;
        		tfUser.selectable = false;
        		container.addChild(tfUser);
        		
        		return container;
        }
        
        // グラフの配置 
        private function arrange(id : String, x : Number = 0, y : Number = 0, theta : Number = 0) : void
        {
        		if(id == null)return;
        		if(id == _root){
        			_canvas.graphics.clear();
        		}
        	
        		var node : Object = _tree[id];
        		if(node == null)return;
        		var dobj : DisplayObject = DisplayObject(node.loader);
        		if(node.loader == null)return;
        		dobj.x = x;
        		dobj.y = y;
        		if(node.children){
        			var angle : Number = _openangle.value / 180 * Math.PI;
        			var base : Number = theta - angle / 2;
        			var step : Number = angle / (node.children.length + 1);
        			_canvas.graphics.lineStyle(3, 0xdddddd);
        			for each(var child : String in node.children){
        				base += step;
        				var d : Number = _tree[child].diff || 0;
       				var r : Number = Math.log(d + 10) * 100;
        				var cx : Number = x + r * Math.sin(base);
        				var cy : Number = y - r * Math.cos(base);
        				_canvas.graphics.moveTo(x, y);
        				_canvas.graphics.lineTo(cx, cy);
        				arrange(child, cx, cy, base);
        			}
        		}
        }

        private function tr(...o : Array) : void
        {
            _tf.appendText(o + "\n");
        }
    }
}
