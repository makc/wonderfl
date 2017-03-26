// お好きなBGMを流しながらどうぞ。
// マウスオーバーでサムネイル
// クリックで画像ページに飛ぶよ
// 
// @see http://www.nicovideo.jp/watch/sm11464969
// @see http://www.youtube.com/watch?v=x08R89_zRSs
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*;
    import flash.ui.*;
    import flash.system.LoaderContext;
    import flash.text.*;
    import flash.filters.*;
    import flash.utils.*;
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.*;
    import com.bit101.components.*;
    
    [SWF(backgroundColor="#f3f3f3")]
    public class BrokenPieces extends Sprite {
        private const FEEDURL : String = "http://api.flickr.com/services/feeds/photos_public.gne?format=rss_200&tags=";
        private const media : Namespace = new Namespace("http://search.yahoo.com/mrss/");
        
        // stageの大きさ情報
        private var SW : Number;
        private var SH : Number;
        private const N : uint = 7; // 断片の個数
        
        private var _msg : Label; // メッセージボックス
        private var _searchBox : Text; // タグクエリ入力
        private var _searchBtn : PushButton; // タグ検索ボタン
        private var _thumb : Bitmap; // サムネイル
        
        private var _ul : URLLoader; // フィードローダー
        private var _loadingQueue : Array; // 未ロードのpicture <String>
        private var _loadingTween : ITween; // ローディング用tween
        private var _urlInfoMap : Object = {}; // ロード中の、URLとpictureの情報を対応

        private var _nValid : uint; // フィード内にある有効なpictureの個数
        private var _blurs : Array; // ピンぼけ用blur <Array<BlurFilter>>
        private var _parts : Array; // 断片のリスト <ExSprite>
        private var _step : Number = -9999999; // 時間
        private var _useBlur : Boolean; // ブラー使用フラグ
        private var _selectSmall : Boolean; // 小サイズ限定フラグ
        
        private var _tf : TextField; // デバッグ用
        private var _jobs : Array; // 負荷分散用ジョブ配列
        
        public function BrokenPieces() {
            Wonderfl.capture_delay(20);
            
            _tf = new TextField();
            _tf.width = 465;
            _tf.height = 465;
            _tf.y = 250;
//            addChild(_tf);
            
//            stage.scaleMode = "noScale";
            SW = stage.stageWidth;
            SH = stage.stageHeight;
            
            _parts = [];
            _loadingQueue = [];
            _jobs = [];
            
            // ブラー格納
            _blurs = [[]];
            for(var i : uint = 1;i < 100;i++){
                _blurs.push([new BlurFilter(i, i)]);
            }
            
            _ul = null;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            _searchBox = new Text(this, 10, SH - 23);
            _searchBox.height = 21;
            _searchBox.editable = true;
            // 日本語対応
            _searchBox.textField.embedFonts = false;
            _searchBox.textField.defaultTextFormat = new TextFormat(null, 9, Style.INPUT_TEXT);
            
            // エンター決定対応
            var flagEnter : Boolean = false;
            _searchBox.textField.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) : void {if(e.keyCode == Keyboard.ENTER){flagEnter = true; }});
            _searchBox.textField.addEventListener(TextEvent.TEXT_INPUT, function(e:TextEvent) : void {if(flagEnter){e.preventDefault();}});
            _searchBox.textField.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) : void {if(e.keyCode == Keyboard.ENTER && flagEnter){onTagSearch(null);} flagEnter = false; });
            _searchBtn = new PushButton(this, 220, SH - 23, "TagSearch!", onTagSearch);
            _searchBtn.setSize(70, 22);
            
            var checkBlur : CheckBox = new CheckBox(this, 300, SH - 30, "Blur", function(e:MouseEvent) : void {_useBlur = e.currentTarget.selected; });
            checkBlur.selected = true;
            _useBlur = true;
            
            var checkSmall : CheckBox = new CheckBox(this, 300, SH - 15, "Small pictures only", function(e:MouseEvent) : void {_selectSmall = e.currentTarget.selected; });
            checkSmall.selected = true;
            _selectSmall = true;
            
            _thumb = new Bitmap();
            _thumb.x = 400;
//            _thumb.y = SH - 90;
            addChild(_thumb);
            
            _msg = new Label(this, 10, SH - 43);
            _msg.autoSize = true;
            _loadingTween = null;
            
            _nValid = 999;
        }
        
        // タグ検索
        private function onTagSearch(e : MouseEvent) : void
        {
            if(_ul != null){
                _ul.removeEventListener(Event.COMPLETE, onFeedLoadComplete);
                _ul.close();
            }
            _ul = new URLLoader();
            _ul.addEventListener(Event.COMPLETE, onFeedLoadComplete);
            _ul.load(new URLRequest(FEEDURL + encodeURIComponent(_searchBox.text)));
            _msg.text = "Loading feed..";
            _loadingQueue = [];
            if(_loadingTween != null){
                _loadingTween.stop();
                _loadingTween = BetweenAS3.to(_msg, {x:10}, 1.0);
                _loadingTween.play();
            }
        }
        
        private function onEnterFrame(e : Event) : void
        {
            if(_loadingQueue.length == 0){
                // ロード中のフィードがなく、フィード内の有効なpictureが存在するとき、フィードをロード
                if(_ul == null && _nValid > 0){
                    _ul = new URLLoader();
                    _ul.addEventListener(Event.COMPLETE, onFeedLoadComplete);
                    _ul.load(new URLRequest(FEEDURL + encodeURIComponent(_searchBox.text)));
                    _msg.text = "Loading feed..";
                }
            }else{
                // 6秒ごとに、断片の数が20個以下のときloadingQueueにあるpictureをひとつロード
                if(_step % 180 == 0 && _parts.length <= 20){
                    var l : Loader = new Loader();
                    l.load(new URLRequest(_loadingQueue.pop()), new LoaderContext(true));
                    l.contentLoaderInfo.addEventListener(Event.COMPLETE, onPictureLoadComplete);
                }
            }

            stepJobs();
            stepParts();
            _step++;
        }
        
        // 断片を動かす
        private function stepParts() : void
        {
            for(var i : int = 0;i < _parts.length;i++){
                var sp : ExSprite = _parts[i];
                if(sp.y >= SH){
                    // 断片消去処理
                    removeChild(sp);
                    sp.removeEventListener(MouseEvent.CLICK, onPartClick);
                    sp.removeEventListener(MouseEvent.MOUSE_OVER, onPartOver);
                    sp.removeEventListener(MouseEvent.MOUSE_OUT, onPartOut); 
                    sp.bmp.bitmapData.dispose();
                    sp.thumb.dispose();
                    if(i == _parts.length - 1){
                        _parts.pop();
                    }else{
                        _parts[i] = _parts.pop();
                        i--;
                    }
                    continue;
                }
                sp.x += sp.v[0];
                sp.y += sp.v[1];
                if(_useBlur){
                    var oaz : int = Math.abs(sp.z) / 10;
                    sp.z += sp.v[2];
                    var az : int = Math.abs(sp.z) / 10;
                    if(oaz != az || sp.alpha == 0){
                        sp.bmp.filters = _blurs[az]; // 必要なときだけフィルタを変更
                    }
                }else{
                    sp.z += sp.v[2];
                    sp.bmp.filters = null;
                } 

                sp.rotationX += sp.omega[0];
                sp.rotationY += sp.omega[1];
                sp.rotationZ += sp.omega[2];
                if(sp.alpha < 1)sp.alpha += 0.05;
            }
        } 
        
        // pictureを断片に分割
        // pictureに断片の種をばらまいて成長させていく。
        // 色差が激しい時は乗り越えるのに時間がかかるようにする。
        public function stepJobs() : void
        {
            if(_jobs.length == 0)return;
            var n : uint = 10000 / _jobs.length;
            for(var i : int = 0;i < _jobs.length;i++){
                var job : Object = _jobs[i];
                var p : uint = job.p;
                var map : BitmapData = job.map;
                var q : Vector.<uint> = job.q;
                var base : BitmapData = job.base;
                var xsums : Vector.<Number> = job.xsums;
                var ysums : Vector.<Number> = job.ysums;
                var nums : Vector.<uint> = job.nums;
                
                var step : uint = 0;
                for(;p < q.length && step <= n;step++){
                    var x : uint = q[p++];
                    var y : uint = q[p++];
                    var left : uint = q[p++];
                    if(left >= 1){
                        q.push(x, y, left - 1);
                    }else{
                        var c : uint = map.getPixel(x, y);
                        xsums[c-1] += x;
                        ysums[c-1] += y;
                        nums[c-1]++;
                        var oc : uint = base.getPixel(x, y);
                        for(var u : int = -1;u <= 1;u++){ 
                            for(var v : int = -1;v <= 1;v++){
                                if(u == 0 && v == 0)continue;
                                var nx : int = x + u;
                                var ny : int = y + v; 
                                if(nx >= 0 && nx < map.width && ny >= 0 && ny < map.height && map.getPixel(nx, ny) == 0){
                                    var dc : Number = deltaColor(base.getPixel(nx, ny), oc);
                                    map.setPixel(nx, ny, c);
                                    q.push(nx, ny, Math.min(dc / 7, 20));
                                }
                            }
                        }
                    }
                }
                
                if(p >= q.length){
                    makeParts(map, base, job.thumb, job.info, job.xsums, job.ysums, job.nums);
                    if(i == _jobs.length - 1){
                        _jobs.pop();
                    }else{
                        _jobs[i] = _jobs.pop();
                        i--;
                    }
                }else{
                    job.p = p;
                }
            }
        }
       
        // フィード読み込み完了時
        public function onFeedLoadComplete(e : Event) : void
        {
            _ul.removeEventListener(Event.COMPLETE, onFeedLoadComplete);
            var xl : XMLList = XML(_ul.data)..media::content;
            var len : uint = xl.length();
            _nValid = 0;
            for(var i : uint = 0;i < len;i++){
                if(!_selectSmall || xl[i].@height * xl[i].@width <= 1500 * 1500){
                    _nValid++;
                    _urlInfoMap[xl[i].@url.toXMLString()] = {
                        link : XML(_ul.data)..link[i+2].text().toXMLString(),
                        thumbnail : XML(_ul.data)..media::thumbnail[i].@url.toXMLString()
                    }
//                    tr(XML(_ul.data)..link[i+1].text().toXMLString());
//                    tr(XML(_ul.data)..media::thumbnail[i].@url.toXMLString());
  
                    _loadingQueue.push(xl[i].@url.toXMLString());
                }
            }
            _msg.text = len == 0 ? "Contents not found." : (_nValid == 0 ? "Every content is too large!" : "Loading contents...");
            if(_nValid > 0){
                if(_loadingTween != null)_loadingTween.stop();
                 _loadingTween = BetweenAS3.repeat(
                    BetweenAS3.serial(
                        BetweenAS3.to(_msg, {x:200}, 0.5, Cubic.easeInOut),
                        BetweenAS3.to(_msg, {x:10}, 0.5, Cubic.easeInOut)
                        ), 9999);
                 _loadingTween.play();
            }
            _ul = null;
        }
        
        // picture読み込み完了時
        public function onPictureLoadComplete(e : Event) : void
        {
            e.currentTarget.removeEventListener(Event.COMPLETE, onPictureLoadComplete);
            _msg.text = "Enjoy!";
            if(_loadingTween != null){
                _loadingTween.stop();
                _loadingTween = BetweenAS3.to(_msg, {x:10}, 1.0);
                _loadingTween.play();
            }
            
            var l : Loader = e.currentTarget.loader as Loader;
            
            // 縮小
            var shrink : Number = 200 / Math.sqrt(l.width * l.height);
            if(shrink > 1.0)shrink = 1.0;
            var base : BitmapData = new BitmapData(l.width * shrink, l.height * shrink, false, 0x000000);
            base.lock();
            base.draw(l.content, new Matrix(shrink, 0, 0, shrink), null, null, null, true);
//            tr(l.width, l.height, shrink);

            // サムネイル用に縮小
            var shrink2 : Number = 80 / Math.sqrt(l.width * l.height);
            if(shrink2 > 1.0)shrink2 = 1.0;
            var thumb : BitmapData = new BitmapData(l.width * shrink2, l.height * shrink2, false, 0x000000);
            thumb.lock();
            thumb.draw(l.content, new Matrix(shrink2, 0, 0, shrink2), null, null, null, true);
             
            var i : uint;
            // 断片の重心計算用
            var xsums : Vector.<Number> = new Vector.<Number>(N);
            var ysums : Vector.<Number> = new Vector.<Number>(N);
            var nums : Vector.<uint> = new Vector.<uint>(N);
            for(i = 0;i < N;i++){
                xsums[i] = 0;
                ysums[i] = 0;
                nums[i] = 0;
            }

            // 断片情報格納用
            var map : BitmapData = new BitmapData(base.width, base.height, false, 0);
            map.lock();
            
            var q : Vector.<uint> = new Vector.<uint>();
            for(i = 0;i < N;i++){
                var x : uint = Math.random() * base.width;
                var y : uint = Math.random() * base.height;
                map.setPixel(x, y, i + 1);
                q.push(x, y, 0);
            }
            
            _jobs.push({
                map : map,
                p : 0,
                q : q,
                base : base,
                thumb : thumb,
                info : _urlInfoMap[l.contentLoaderInfo.url],
                xsums : xsums,
                ysums : ysums,
                nums : nums
            });
            _urlInfoMap[l.contentLoaderInfo.url] = null;
            l.unload();
        }

        private function makeParts(map : BitmapData, base : BitmapData, thumb : BitmapData, info : Object, xsums : Vector.<Number>, ysums : Vector.<Number>, nums : Vector.<uint>) : void
        {
            // 断片実体の作成
            var targX : Number = SW / 2 + Math.random() * SW / 2.5 - SW / 5; // 合体予定座標
            var targY : Number = SH / 2 + Math.random() * SH / 2.5 - SH / 5;
            var T : Number = targY + SW / 3; // 合体予定時刻
            var i : uint;
            for(i = 0;i < N;i++){
                var bb : BitmapData = new BitmapData(base.width, base.height, true, 0);
                bb.copyPixels(base, base.rect, new Point());
                bb.threshold(map, map.rect, new Point(), "!=", i+1, 0, 0xffffff);
                
                var sp : ExSprite = new ExSprite();
                var g : Array = [xsums[i] / nums[i], ysums[i] / nums[i]];
                var bmp : Bitmap = new Bitmap(bb);
                bmp.x = -g[0];
                bmp.y = -g[1];
                sp.addChild(bmp);
                _parts.push(sp);
                addChildAt(sp, 0);
//                sp.mouseEnabled = false;
                sp.mouseChildren = false;
                
                sp.v = [
                    (Math.random() - 0.5) * 1.5,
                    (Math.random() + 0.5) * 1,
                    (Math.random() + 0.5) * -1
                    ]; // 並進速度
                sp.omega = [
                    (Math.random() - 0.5) * 2,
                    (Math.random() - 0.5) * 2,
                    (Math.random() - 0.5) * 0
                    ]; // 回転速度
                sp.bmp = bmp;
                sp.alpha = 0.0;
                sp.x = targX - base.width / 2 + g[0] - sp.v[0] * T;
                sp.y = targY - base.height / 2 + g[1] - sp.v[1] * T;
                sp.z = 0 - sp.v[2] * T;
                sp.rotationX = -sp.omega[0] * T;
                sp.rotationY = -sp.omega[1] * T;
                sp.rotationZ = -sp.omega[2] * T;
                sp.thumb = thumb.clone();

                sp.info = info;
                sp.addEventListener(MouseEvent.CLICK, onPartClick);
                sp.addEventListener(MouseEvent.MOUSE_OVER, onPartOver);
                sp.addEventListener(MouseEvent.MOUSE_OUT, onPartOut); 
            }
            thumb.dispose();
            base.dispose();
            var gg : Number = getTimer();
        }
        
        // 断片をクリックしたら画像を開く
        private function onPartClick(e : MouseEvent) : void
        {
             navigateToURL(new URLRequest(e.currentTarget.info.link), "_blank");
        }
        
        // 断片にマウスオーバーしたらサムネイルを表示
        private function onPartOver(e : MouseEvent) : void
        {
            _thumb.bitmapData = e.currentTarget.thumb;
            _thumb.y = SH - 5 - _thumb.bitmapData.height;
        }
        
        // 断片からマウスアウトしたらサムネイルを消す
        private function onPartOut(e : MouseEvent) : void
        {
            _thumb.bitmapData = null;
        }
        
        // 色差を計算
        public function deltaColor(a : uint, b : uint) : Number
        {
            var ra : uint = (a >> 16) & 0xff;
            var ga : uint = (a >> 8) & 0xff;
            var ba : uint = (a >> 0) & 0xff;
            var rb : uint = (b >> 16) & 0xff;
            var gb : uint = (b >> 8) & 0xff;
            var bb : uint = (b >> 0) & 0xff;
            return Math.abs(ra - rb) + Math.abs(ga - gb) + Math.abs(ba - bb);
        }
        
        private function tr(...o : Array) : void
        {
            _tf.appendText(o + "\n");
            _tf.scrollV = _tf.maxScrollV;
        }
    }
}

import flash.display.*;

class ExSprite extends Sprite
{
    public var v : Array;
    public var omega : Array;
    public var bmp : Bitmap;
    public var thumb : BitmapData;
    public var info : Object;
}
