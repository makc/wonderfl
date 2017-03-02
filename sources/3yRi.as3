/**
 * 解説
 * http://miniapp.org/blog/2010/01/15/176/
 *
 * マウスドラッグすると、クリックした付近の時間を早送りしたり、
 * 巻き戻したりします。
 *
 * 上下の線に囲まれた部分が対象範囲です。
 * y方向にドラッグすると、適用範囲を広げられます。
 * 
 * x方向にドラッグすると、早送り or 巻き戻しの量を変化させます。
 * 右方向にドラッグで早送り、左方向で巻き戻しです。
 * 長くドラッグするほど、時間が早くなる or 遅れます。
 * 
 * ガイドの有無はチェックボックスで変えられます
 * 
 * 動画はこちらを使わせて頂きました。
 * YouTube - ムーンウォークからの、、、スライド
 * http://www.youtube.com/watch?v=fWMBIncDQtA
 */

package {
    import com.bit101.components.CheckBox;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NetStatusEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.NetStreamInfo;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    [SWF(backgroundColor=0x0, width=465, height=465, frameRate=60)]
    public class SlitScan3 extends Sprite {
        private static const PLAYER_WIDTH:int = 465;
        private static const PLAYER_HEIGHT:int = 348;
        private static const NUM_FRAMES:int = 400;
        private static const MAX_DELAY:int = NUM_FRAMES / 2 - 1;
        private static const PLAY_FRAME:int = NUM_FRAMES / 2;//通常再生させるフレーム番号
        
        public function SlitScan3() {
            Wonderfl.capture_delay( 32 );
            
            for (var i:int = 0; i < NUM_FRAMES; ++i) {
                frames[i] = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, false, 0x0);
            }
            
            for (var yy:int = 0; yy < PLAYER_HEIGHT; ++yy) {
                var line:Line = new Line();
                lines[yy] = line;
            }
            
            loadInfoTf = new TextField();
            var fmt:TextFormat = new TextFormat();
            fmt.size = 16;
            loadInfoTf.defaultTextFormat = fmt;
            loadInfoTf.text = 'start';
            loadInfoTf.textColor = 0xFFFFFF;
            loadInfoTf.autoSize = TextFieldAutoSize.CENTER;
            loadInfoTf.selectable = false;
            loadInfoTf.x = 0;
            loadInfoTf.y = stage.stageHeight - loadInfoTf.height - 10;
            loadInfoTf.width = stage.stageWidth;
            addChild(loadInfoTf);
            
            displayData = new BitmapData(PLAYER_WIDTH, PLAYER_HEIGHT, false, 0x0)
            display = new Bitmap(displayData);
            guideLayer = new Sprite();
            display.x = guideLayer.x = (stage.stageWidth - display.width) / 2;
            display.y = guideLayer.y = (stage.stageHeight - display.height) / 2;
            addChild(display);
            
            guideTf = new TextField();
            fmt.size = 14;
            guideTf.textColor = 0xffffff;
            guideTf.backgroundColor = 0x0;
            guideTf.autoSize = TextFieldAutoSize.LEFT;
            guideTf.selectable = false;
            guideTf.defaultTextFormat = fmt;
            guideLayer.addChild(guideTf);
            addChild(guideLayer);
            
            drawGuideCheck = new CheckBox(this, 10, stage.stageHeight - 20, "guide", checkClickHandler);
            drawGuideCheck.selected = true;
            
            loadVideo("http://dust.heteml.jp/wonderfl/flv/moonwalk.mp4");
            
            //音はOFFにしておく。
            var s:SoundTransform = SoundMixer.soundTransform;
            s.volume=0;
            SoundMixer.soundTransform = s;
            
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        
        private var index:int = 0;
        private var applyDist:Number;
        
        private var destPoint:Point = new Point();
        private var sourceRect:Rectangle = new Rectangle(0, 0, PLAYER_WIDTH, 1);
        
        private var pressX:Number;
        private var pressY:Number;
        private var mousePressed:Boolean = false;
        
        private var frames:Vector.<BitmapData> = new Vector.<BitmapData>(NUM_FRAMES, true);
        private var lines:Vector.<Line> = new Vector.<Line>(PLAYER_HEIGHT, true);
        
        private var loadInfoTf:TextField;
        
        private var drawGuideCheck:CheckBox;
        private var guideTf:TextField;
        private var showGuide:Boolean = true;
        
        private var display:Bitmap;
        private var displayData:BitmapData;
        private var guideLayer:Sprite;
        private var videoLayer:Sprite;
        private var netStream:NetStream;//ローカル変数にすると、drawする時にセキュリティエラーが出る
        
        private function checkClickHandler(event:MouseEvent):void {
            showGuide = event.currentTarget.selected;
        }
        
        private function loadVideo(url:String):void{
            var netConnection:NetConnection = new NetConnection();
            netConnection.connect(null);
            
            netStream = new NetStream(netConnection);
            netStream.client = {
                onMetaData:function(args:*):void
                {
                }
            };
            netStream.checkPolicyFile = true;
            netStream.play(url);
            
            videoLayer = new Sprite();
            var video:Video = new Video();
            video.width  = PLAYER_WIDTH;
            video.height = PLAYER_HEIGHT;
            video.attachNetStream(netStream);
            videoLayer.addChild(video);
            //addChild(videoLayer);
            
            addEventListener(Event.ENTER_FRAME, function(event:Event):void {
                var per:Number = Math.ceil(netStream.bytesLoaded * 100 / netStream.bytesTotal);
                if (per >= 100) {
                    loadInfoTf.text = "now initializing. please wait.";
                    if (index >= PLAY_FRAME) {
                        removeChild(loadInfoTf);
                        removeEventListener(Event.ENTER_FRAME, arguments.callee);
                    }
                }
                else {
                    loadInfoTf.text = "loading " + String(per) + "%" + "loaded";
                }
            });
            
            
            netStream.addEventListener (NetStatusEvent.NET_STATUS , function(event:NetStatusEvent):void {
                switch(event.info.code) {                    
                    case "NetStream.Play.Start":
                        stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
                    break;
                    case "NetStream.Play.Stop":
                        //終わったら最初から開始
                        netStream.seek(0);
                    break;
                }
            });
        }
        
        
        private function mouseDownHandler(e:MouseEvent):void {
            mousePressed = true;
            
            pressX = display.mouseX;
            pressY = display.mouseY;
        }
        
        private function mouseUpHandler(e:MouseEvent):void {
            mousePressed = false;
            
            guideTf.visible = false;
            guideLayer.graphics.clear();
        }
        
        private function drawGuide(delay:Number):void {
            guideLayer.graphics.clear();
            guideLayer.graphics.lineStyle(1, 0xFFFFFF, 0.5);
            
            var up:Number = pressY + applyDist;
            guideLayer.graphics.moveTo(0, up);
            guideLayer.graphics.lineTo(PLAYER_WIDTH, up);
            
            var bottom:Number = pressY - applyDist;
            guideLayer.graphics.moveTo(0, bottom);
            guideLayer.graphics.lineTo(PLAYER_WIDTH, bottom);
            
            guideLayer.graphics.moveTo(pressX, pressY);
            guideLayer.graphics.lineTo(guideLayer.mouseX, guideLayer.mouseY);
            
            guideTf.visible = true;
            guideTf.x = guideLayer.mouseX;
            guideTf.y = guideLayer.mouseY - guideTf.textHeight;
            var str:String = '';
            if (delay > 0) {
                str = '+';
            }
            
            guideTf.text = str + String(delay) + "frame";
        }
        
        private function enterFrameHandler(event:Event):void {
            if(mousePressed){
                var delay:int = (display.mouseX - pressX);
                if (delay > MAX_DELAY) {
                    delay = MAX_DELAY
                }
                else if (delay < -MAX_DELAY) {
                    delay = -MAX_DELAY;
                }
                
                applyDist = display.mouseY - pressY;
                if (applyDist < 0) applyDist *= -1;
                
                if(showGuide)
                    drawGuide(delay);
            }
            
            update(applyDist, delay);
            
            ++index;
            index %= NUM_FRAMES;
        }
        
        private function update(applyDist:int, delay:int = 0):void {
            frames[index].draw(videoLayer);
            
            for (var yy:int = 0; yy < PLAYER_HEIGHT; ++yy) {
                var line:Line = lines[yy];
                sourceRect.y = yy;
                destPoint.y = yy;
                
                if (mousePressed) {
                    var dist:Number = pressY - yy;
                    if (dist < 0) dist *= -1;
                    
                    if(dist <= applyDist){
                        var per:Number = dist / applyDist;
                        line.changeDelayDirect(delay * (1 - per));
                    }
                    else {
                        line.changeDelay(0);
                    }
                }
                else {
                    line.changeDelay(0);
                }
                
                var targetFrame:int = (index + PLAY_FRAME + line.delay) % NUM_FRAMES;
                if (targetFrame < 0) {
                    targetFrame = NUM_FRAMES + targetFrame;
                }
                
                displayData.copyPixels(frames[targetFrame], sourceRect, destPoint);
            }
        }
    }
}

import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.easing.Linear;
import org.libspark.betweenas3.easing.Bounce;
import org.libspark.betweenas3.easing.Elastic;
class Line { 
    
    public var delay:int = 0;
    private var t:ITween;
    private var prev:int = 0;
    
    public function changeDelayDirect(value:int):void {
        if(t && t.isPlaying) t.stop();
        delay = value;
        prev = value;
    }
    
    public function changeDelay(value:int):void {
        if (prev != value) {
            if(t && t.isPlaying) t.stop();
            //t = BetweenAS3.tween(this, { delay: value }, null, 1.5, Bounce.easeOut);
            t = BetweenAS3.tween(this, { delay: value }, null, 3, Elastic.easeOut);
            //t = BetweenAS3.tween(this, { delay: value }, null, 0.5, Linear.easeNone);
            t.play();
            prev = value;
        }
    }
}