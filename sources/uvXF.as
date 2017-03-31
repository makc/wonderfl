/**
 * ネットで投稿されたメッセージが
 * クリスマスの夜空を飾ります
 * 
 * クリスマスメッセージは
 * 「Twitter」と「はてなブックマーク」で送ることができます
 * ※追記：11/5(木)、Twitter仕様変更によりTwitter投稿はできなくなりました
 * 
 * ※投稿はFlash内のボタンを押して、
 * Twitterの場合は[]内にコメントを
 * はてなブックマークの場合は、ブックマークコメントを記入下さい
 * 
 * このFlashはwonderfl上の様々なテクニックを元に作られました
 * 
 * Twitter連動
 * http://wonderfl.net/c/GO9L
 * 
 * キラキラ3D
 * http://wonderfl.net/c/rwYK
 * 
 * 文字のパーティクル化
 * http://wonderfl.net/c/1gVG
 * 
 * 木を作る再帰関数
 *　http://wonderfl.net/c/72PE 
 * 
 * 配列のシャッフル
 * http://wonderfl.net/c/k78X 
 * 
 * BetweenAS3の時間調整
 * http://wonderfl.net/c/cNoK
 * 
 */
package {
    import com.bit101.components.Label;    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    import flash.utils.*;
    
    import jp.progression.casts.*;
    import jp.progression.commands.lists.LoaderList;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.*;
    import jp.progression.data.getResourceById;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.effects.*;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;
    import org.papervision3d.core.math.Number3D;
    import org.papervision3d.materials.*;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.view.Viewport3D;
    import org.papervision3d.view.layer.BitmapEffectLayer;

    [SWF(width=465, height=465, frameRate=30, backgroundColor=0)]
    public class Main extends CastDocument {
        static public const URL_HATENA:String = "http://pipes.yahooapis.com/pipes/pipe.run?_id=a9fa16f111d33689315b50bd196f691e&_render=rss";
        //static public const URL_TWITTER:String = "http://search.twitter.com/search.atom?q=%23XmasMessage&rpp=50";
        static public const URL_TWITTER:String =  "http://clockmaker.jp/labs/091022_pv3d_xmas/search.atom";
        static public const URL_IMG_BG:String = "http://clockmaker.jp/labs/091021_checkmate/assets/bg.png";
        static public const URL_IMG_TITLE:String = "http://clockmaker.jp/labs/091021_checkmate/assets/title.png";
        static public const URL_IMG_BTN_HATENA:String = "http://clockmaker.jp/labs/091021_checkmate/assets/btn-hatena.png";
        static public const URL_IMG_BTN_TWITTER:String = "http://clockmaker.jp/labs/091021_checkmate/assets/btn-twitter.png";
        static private const MAX_PARTICLES:int = 2500;
        // color
        public static const WHITE:uint = 0xFFF0F0F0;
        public static const GREEN:uint = 0xFF008800;
        public static const RED:uint = 0xFFCC0000;
        public static const GOLD:uint = 0xFFFFCC66;
        public static const SILVER:uint = 0xFFCCCCCC;
        public static const COLORS:Array = [WHITE, GREEN, RED, GOLD, SILVER];
        // 3d
        private var scene:Scene3D = new Scene3D();
        private var renderer:BasicRenderEngine = new BasicRenderEngine();
        private var viewport:Viewport3D = new Viewport3D(465, 465);
        private var camera:Camera3D = new Camera3D()
        // 3d objects
        private const MAX_RADIUS:int = 10000;
        private const PIXCEL_MARGIN:Number = 1.25;
        private var textPixels:Pixels;
        private var treePixels:Pixels;
        private var pixelArr:Array = [];
        private var bfx:BitmapEffectLayer;
        private var dmyObjs:Array = [];
        private var tweens:Array = [];
        // 3d camera
        public var cameraDistance:Number  = 1000;
        public var cameraYaw:Number = 0;
        public var cameraPitch:Number = 0;
        // 2d 
        private var canvas:BitmapData;
        private var mtx:Matrix;
        private var progress:ProgressBar;
        private var loading:Label;
        private var loadingTween:ITween;
        // array of objs
        private var data:Array = [];
        // fractal
        private var level:int = 0;
        // data
        private var index:int = 0;
        private const RESET_TIMER:Timer = new Timer(11 * 1000);
        
        /**
         * Progression 4 では atReady から処理が始まります
         */        
        override protected function atReady() : void{
            stage.quality = StageQuality.MEDIUM;
            
            // 3D
            addChild(viewport);
            
            // progress bar
            progress = new ProgressBar();
            progress.value = 0;
            this.addChild(progress)
            progress.x = int(stage.stageWidth / 2 - progress.width/2);
            progress.y = int(stage.stageHeight / 2 + 10);
            
            // loading
            loading = new Label(this, stage.stageWidth / 2 - 33, stage.stageHeight / 2 - 10, "NOW LOADING");
            loadingTween = BetweenAS3.tween(loading, { alpha:1 }, { alpha:0.25 }, 0.05);
            loadingTween = BetweenAS3.serial(loadingTween, BetweenAS3.reverse(loadingTween));
            loadingTween.stopOnComplete = false;
            loadingTween.play();
            
            var context:LoaderContext = new LoaderContext(true);
            var loaderList:LoaderList = new LoaderList(null,
                new LoadBitmapData(new URLRequest(URL_IMG_BG), {context:context}),
                new LoadBitmapData(new URLRequest(URL_IMG_TITLE), {context:context}),
                new LoadURL(new URLRequest(URL_TWITTER), {context:context}),
                new LoadURL(new URLRequest(URL_HATENA), {context:context}),
                new LoadBitmapData(new URLRequest(URL_IMG_BTN_HATENA), {context:context}),
                new LoadBitmapData(new URLRequest(URL_IMG_BTN_TWITTER), {context:context})
                );
            loaderList.onProgress = function():void{
                progress.value = 0.5 * (loaderList.loaded / loaderList.numCommands)
            }
            
            new SerialList(null,
                loaderList,
                function():void{
                    
                    // Twitter連携 by　http://wonderfl.net/c/GO9L (coppieee)
                    default xml namespace = new Namespace("http://www.w3.org/2005/Atom");
                    var xml:XML = XML(getResourceById(URL_TWITTER).data);
                    for (var i:int = 0; i < xml.entry.length(); i++) {
                        // コメントを抽出
                        var comment:String = scan(xml.entry[i].title,/\[(.+)\]/);
                        // RT は除外
                        if(xml.entry[i].title.indexOf("RT") > -1) continue;
                        // コメントなしは除外
                        if(comment == "") continue;
                        // データに追加
                        data.push({
                            img : xml.entry[i].link.(@type == "image/png").@href,
                            name : xml.entry[i].author.name.split(" (")[0],
                            comment : comment
                        });
                    }
                    
                    xml = XML(getResourceById(URL_HATENA).data);
                    
                    for (i = 0; i < xml.channel.item.length(); i++) {
                        if(xml.channel.item[i].description != undefined){
                            comment = xml.channel.item[i].description;
                            var name:String = xml.channel.item[i].title;
                            var imgurl:String = "http://www.st-hatena.com/users/" + name.substr(0,2) + "/" + name + "/profile.gif";
                            data.push({
                                img : imgurl,
                                name : name,
                                comment : comment
                            });
                        }
                    }
                    
                    data = shuffle(data);
                    data = data.slice(0, 8)
                },
                init3d
            ).execute();
        }
        /**
         * Papervision3D関係のごにょごにょ 
         */        
        private function init3d():void {
            // カメラの設定
            camera.target = DisplayObject3D.ZERO;
            // ビットマップエフェクトレイヤー
            bfx = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight);
            bfx.addEffect(new BitmapColorEffect(1, 1, 1, 0.75));
            viewport.containerSprite.addLayer(bfx);
            // ピクセル3D
            textPixels = new Pixels(bfx);
            scene.addChild(textPixels);
            treePixels = new Pixels(bfx);
            scene.addChild(treePixels);
            
            var i:int;
            var arr:Array = [];
            // snow
            var star:Array = [0xFFFFFFFF, 0xFFcccccc, 0xFF666666, 0xFF333333]
            for (i = 0; i < 1500; i++) {
                treePixels.addPixel3D(new Pixel3D(star[star.length * Math.random() | 0],
                    10000 * (Math.random() - 0.5),
                    10000 * (Math.random()) - 1000,
                    10000 * (Math.random() - 0.5)));
            }
            for (i = 0; i < 255; i++) {
                treePixels.addPixel3D(new Pixel3D(0xFF0066CC,
                    100 * (Math.floor(i / 15) - 7),
                    -1000,
                    100 * (i % 15 - 7)));
            }
            // ダミーオブジェクトを作成
            for (var k:int = 0; k < data.length; k++) {
                dmyObjs[k] = new DisplayObject3D();
                while (true) {
                    var angle:Number = 360 * Math.random();
                    dmyObjs[k].x = 2000 * Math.sin(angle * Number3D.toRADIANS);
                    dmyObjs[k].y = 2000 * (Math.random() - 0.5);
                    dmyObjs[k].z = 2000 * Math.cos(angle * Number3D.toRADIANS);
                    if (k == 0)
                        break;
                    else {
                        if (DisplayObject3D(dmyObjs[k]).distanceTo(dmyObjs[k - 1]) >= 500)
                            break;
                    }
                }
                dmyObjs[k].lookAt(DisplayObject3D.ZERO);
                scene.addChild(dmyObjs[k]);
            }
            for (i = 0; i < MAX_PARTICLES; i++) {
                var p:Pixel3D = new Pixel3D(COLORS[COLORS.length * Math.random() | 0]);
                textPixels.addPixel3D(p);
            }
            drawTree(0, -1000, 0, 1000, 90, GOLD);
            
            loading.text = "NOW RENDERING"
            loading.x = stage.stageWidth / 2 - 39
            var cmd:SerialList = new SerialList();
            var renderIndex:int=0;
            for (i = 0; i < data.length; i++) {
                cmd.addCommand(
                    function():void{
                        preRenderText(renderIndex);
                        createText(renderIndex);
                        renderIndex ++;
                        
                        progress.value = 0.5 + 0.5 * (renderIndex / data.length);
                    },
                    0.05
                );
            }
            cmd.addCommand(
                function():void{
                    // remove loading
                    removeChild(loading);
                    removeChild(progress);
                    loadingTween.stop();
                    loadingTween = null;
                    
                    // ui
                    addChildAt(new CastBitmap(getResourceById(URL_IMG_BG).data), 0);
                    addChild(new CastBitmap(getResourceById(URL_IMG_TITLE).data, "auto", false, {x:20, y:376}));
                    
                    var hatenaBtn:CastButton = new CastButton({x:20, y:433});
                    hatenaBtn.addChild(new Bitmap(getResourceById(URL_IMG_BTN_HATENA).data));
                    hatenaBtn.onCastMouseUp = function():void{
                        navigateToURL(new URLRequest("http://b.hatena.ne.jp/append?http://wonderfl.net/c/uvXF"));
                    }
                    hatenaBtn.buttonMode = true;
                    addChild(hatenaBtn);
                    
                    var tweetBtn:CastButton = new CastButton({x:240, y:433});
                    tweetBtn.addChild(new Bitmap(getResourceById(URL_IMG_BTN_TWITTER).data));
                    tweetBtn.onCastMouseUp = function():void{
                        navigateToURL(new URLRequest("http://twitter.com/home/?status=" + escapeMultiByte("#XmasMessage [] http://j.mp/xmaswon")));
                    };
                    tweetBtn.buttonMode = true;
                    addChild(tweetBtn);
                    
                    // キラキラロジック by http://wonderfl.net/c/rwYK (sake)
                    canvas = new BitmapData(720 / 4, 485 / 4, false, 0x000000);
                    var bmp:Bitmap = new Bitmap(canvas, PixelSnapping.NEVER, false);
                    bmp.scaleX = bmp.scaleY = 4;
                    bmp.smoothing = true;
                    bmp.blendMode = BlendMode.ADD;
                    addChildAt(bmp,2);
                    mtx = new Matrix();
                    mtx.scale(0.25, 0.25);
                    // tree
                    drawTree(0, -1000, 0, 1000, 90, GOLD);
                    // タイマーを作る
                    RESET_TIMER.addEventListener(TimerEvent.TIMER, timerHandler);
                    RESET_TIMER.start();
                    // エンターフレーム
                    addEventListener(Event.ENTER_FRAME, loop);
                },
                timerHandler
            );
            cmd.execute();
        }

        private function timerHandler(e:TimerEvent = null):void {
            var i:int;
            var arr:Array = [];
            for (i = 0; i < textPixels.pixels.length; i++) {
                arr[i] = BetweenAS3.serial(
                    BetweenAS3.delay(
                        BetweenAS3.to(textPixels.pixels[i], getRandomPos(), 3, Expo.easeInOut),
                        Math.random()));
            }
            BetweenAS3.serial(
                BetweenAS3.parallelTweens(arr),
                BetweenAS3.func(function():void {
                    setTimeout(motionText, 2 * 1000);
                })
                ).play();
            //
            index++;
            if (index == data.length - 1)
                index = 0;
            //
            var cameraTarget:DisplayObject3D = new DisplayObject3D();
            cameraTarget.copyTransform(dmyObjs[index]);
            cameraTarget.moveBackward(250);
            var dis:Number = cameraTarget.distanceTo(DisplayObject3D.ZERO);
            var rot:Number = Math.atan2(cameraTarget.x, cameraTarget.z);
            
            BetweenAS3.parallel(
                BetweenAS3.delay(
                    BetweenAS3.bezier(this, {
                        cameraYaw: rot,
                        cameraDistance: dis,
                        cameraPitch: cameraTarget.y
                    }, null, getRandomPos(), 10.5, Expo.easeInOut),
                1.0) ,
                BetweenAS3.serial(
                    BetweenAS3.to(camera, {
                        fov: 60
                    }, 4, Sine.easeInOut),
                    BetweenAS3.to(camera, {
                        fov: 50
                    }, 8, Sine.easeInOut)
                    )
                ).play();
        }
        private var preRenderedTests:Array = [];

        private function preRenderText(itemIndex:int):void {
            preRenderedTests[itemIndex] = [];
            var text:TextField = new TextField();
            text.multiline = true;
            text.autoSize = "left";
            text.htmlText = "<font face='Arial' size='24'>WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW</font>";
            trace(data[itemIndex].comment);
            
            var size:int = 24;
            while(text.textWidth * text.textHeight > MAX_PARTICLES){
                text.htmlText = "<font face='Arial' size='" + size +"'>" + data[itemIndex].comment + "</font>"
//                                +"<br><font face='Arial' size='" + size / 2 + "'>" + String(data[itemIndex].name).toUpperCase() + "</font>";
                size--;
            }
            
            var cap:BitmapData = new BitmapData(text.textWidth + 10, text.textHeight, true, 0xFFFFFFFF);
            cap.lock();
            cap.draw(text);
            // particle motion
            var cnt:int = 0;
            for (var i:int = 0; i < text.textWidth + 10; i++) {
                for (var j:int = 0; j < text.textHeight; j++) {
                    if (cap.getPixel(i, j) == 0xFFFFFF)
                        continue;
                    if(preRenderedTests[itemIndex].length >= MAX_PARTICLES) break; 
                    preRenderedTests[itemIndex].push({x: i, y: j, textWidth: text.textWidth, textHeight: text.textHeight});
                }
            }
            cap.unlock();
            cap.dispose();
        }

        /**
         * テキストをBitmapData化してトゥイーンとして作成 
         * @param itemIndex
         */        
        private function createText(itemIndex:int):void {
            var t:DisplayObject3D = dmyObjs[itemIndex];
            // particle motion
            var cnt:int = 0;
            var arr:Array = [];
            for (var i:int = 0; i < preRenderedTests[itemIndex].length; i++) {
                var pix:Object = preRenderedTests[itemIndex][i];
                var p:Pixel3D = textPixels.pixels[i];
                var vec:DisplayObject3D = new DisplayObject3D();
                vec.x = (pix.x - pix.textWidth / 2) * PIXCEL_MARGIN;
                vec.y = (pix.textHeight / 2 - pix.y) * PIXCEL_MARGIN;
                vec.z = 0;
                vec.transform.calculateMultiply(t.transform, vec.transform);
                arr[i] = BetweenAS3.bezier(p, {
                        x: vec.x,
                        y: vec.y,
                        z: vec.z
                    }, null, getRandomPos(), 1.2 + Math.random() * 0.25 + i * 0.002, Expo.easeOut);
            }
            tweens.push(arr);
        }

        private function motionText():void {
            var tw:ITween = BetweenAS3.parallelTweens(tweens[index]);
            // トゥイーンのデュレーションを調整
            tw = BetweenAS3.scale(tw, 3.5 / tw.duration);
            tw.play();
        }

        /**
         * エンターフレームイベント 
         */        
        private function loop(e:Event = null):void {
            // カメラ
            camera.x = cameraDistance * Math.sin(cameraYaw);
            camera.y = cameraPitch;
            camera.z = cameraDistance * Math.cos(cameraYaw);
            
            // レンダリング
            renderer.renderScene(scene, camera, viewport);
            
            // キラキラ
            canvas.fillRect(canvas.rect, 0x000000);
            canvas.draw(viewport, mtx);
        }

        private function getRandomPos():Object {
            return {
                    x: MAX_RADIUS * (Math.random() - 0.5),
                    y: MAX_RADIUS * (Math.random() - 0.5),
                    z: MAX_RADIUS * (Math.random() - 0.5)
                };
        }
        /**
         * 木を作る再帰関数
         *　http://wonderfl.net/c/72PE 
         * @param x
         * @param y
         * @param z
         * @param length
         * @param angle
         * @param cf
         * 
         */
        private function drawTree(x:Number, y:Number, z:Number, length:Number, angle:Number, cf:int):void {
            level += 1;
            var destx:Number = x + length * Math.cos(angle * (Math.PI / 180));
            var desty:Number = y + length * Math.sin(angle * (Math.PI / 180));
            var destz:Number = z + length * (Math.random() - 0.5) * 2;
            if (Math.random() < 0.5)
                cf = COLORS[COLORS.length * Math.random() | 0];
            var max:int = 10 - level / 1.5;
            for (var i:int = 0; i < max; i++) {
                treePixels.addPixel3D(new Pixel3D(cf,
                    destx * i / max + x * (max - i) / max,
                    desty * i / max + y * (max - i) / max,
                    destz * i / max + z * (max - i) / max
                    ));
            }
            if (level < 6) {
                drawTree(destx, desty, destz, length * (1 + 3 * Math.random()) * 0.25, angle + 60 * (Math.random() - Math.random()), cf);
                drawTree(destx, desty, destz, length * (1 + 3 * Math.random()) * 0.25, angle + 60 * (Math.random() - Math.random()), cf);
                drawTree(destx, desty, destz, length * (1 + 3 * Math.random()) * 0.25, angle + 60 * (Math.random() - Math.random()), cf);
                drawTree(destx, desty, destz, length * (1 + 3 * Math.random()) * 0.25, angle + 60 * (Math.random() - Math.random()), cf);
            }
            level -= 1;
        }
        
        /**
         * １行でArrayをシャッフルする by nemu90kWw
         * http://wonderfl.net/c/k78X 
         */        
        public function shuffle(array:Array):Array{
            return array.sort(function():int{return int(Math.random()*3)-1});
        }
        
        /**
         * @see http://takumakei.blogspot.com/2009/05/actionscriptrubystringscan.html
         */ 
        //package com.blogspot.takumakei.utils
        //{
        //public
        public function scan(str:String, re:RegExp):Array
        {
            if(!re.global){
                var flags:String = 'g';
                
                if(re.dotall)
                    flags += 's';
                if(re.multiline)
                    flags += 'm';
                if(re.ignoreCase)
                    flags += 'i';
                if(re.extended)
                    flags += 'x';
                re = new RegExp(re.source, flags);                    
            }
            var r:Array = [];
            var m:Array = re.exec(str);
            while(null != m){
                if(1 == m.length)
                    r.push(m[0]);
                else
                    r.push(m.slice(1, m.length));
                m = re.exec(str);
            }
            return r;
        }
        //}
    }
}

import flash.display.*;
class ProgressBar extends Sprite {
    private var edge:Sprite = new Sprite;
    private var cont:Sprite = new Sprite;
    
    private var _value:Number = 0;
    
    public function set value(v:Number):void {
        _value = v;
        cont.scaleX = _value;
    }
    
    public function get value():Number {
        return _value;
    }
    
    public function ProgressBar() {
        edge.graphics.lineStyle(1, 0xFFFFFF);
        edge.graphics.drawRect(0.5, 0.5, 100, 10);
        
        cont.graphics.beginFill(0x555555);
        cont.graphics.drawRect(0, 0, 100, 10);
        
        addChild(cont);
        addChild(edge);
        
        value = 0;
    }
}