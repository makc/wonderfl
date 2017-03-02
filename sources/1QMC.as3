package 
{
    import away3d.core.render.BitmapRenderSession;
    import flash.display.Bitmap;
    import flash.display.LineScaleMode;
    import flash.display.Sprite;
    import flash.display.BitmapData;    
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.text.*;
    import flash.utils.Timer;
    
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.GlowFilter;    


    import flash.net.*;
    import flash.utils.escapeMultiByte;
    import flash.system.Security;
    import flash.net.URLRequest; 

    import flash.system.LoaderContext;
    import flash.media.SoundLoaderContext;    

    import jp.progression.casts.CastDocument;
    import jp.progression.commands.lists.LoaderList;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.LoadBitmapData;
    import jp.progression.commands.net.LoadSound;
    import jp.progression.commands.net.LoadURL;
    import jp.progression.commands.Func
    import jp.progression.data.Resource;
    import jp.progression.data.getResourceById;

    
    [SWF(backgroundColor="#FFFFFF", frameRate="60", width="465", height="465")]

    /**
     * heartBeatClock
     * 
     * なぜかどきどきする時計です
     * 
     * @author narutohyper
     */
    public class Main extends Sprite 
    {
        private var monitor:Sprite; 
        private var line:Sprite;        
        private var back:Sprite;
        private var clock:TextField;
        private var heart:Sprite;
        private var marker:Sprite;        
        
        private var hourStr:String;
        private var minStr:String;
        private var secStr:String;
        private var sec:int;
        private var counter:uint;
        private var update:Boolean;
        private    var points:Array;
        private var startTime:Array;
        
        private var sound:Array;        
        public var baseBmd:BitmapData;
        
        public function Main():void 
        {
            if (stage) loadContents();
            else addEventListener(Event.ADDED_TO_STAGE, loadContents);
        }
        
        private function loadContents(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point            
            
            var imgUrl:String = 'http://marubayashi.net/archive/sample/heart/heart.png';
            var soundUrl:Array = new Array('http://marubayashi.net/archive/sample/heart/heart.mp3','http://marubayashi.net/archive/sample/heart/beep.mp3');
            
            sound=[];

            new SerialList(null,
                function():void {
                    var cmd:LoaderList = new LoaderList();
                    cmd.addCommand(
                        new LoadBitmapData(new URLRequest(imgUrl),
                            {
                                context: new LoaderContext(true),
                                catchError: function(target:Object, error:Error):void {
                                    target.executeComplete();
                                }
                            }
                        )
                    );
                    for (var i:uint=0;i<2;i++) {
                        cmd.addCommand(
                            new LoadSound(new URLRequest(soundUrl[i]),
                                {
                                    context: new SoundLoaderContext(1000,true),
                                    catchError: function(target:Object, error:Error):void {
                                        target.executeComplete();
                                    }
                                }
                            )
                        );
                    }
                    this.parent.insertCommand(cmd);
                }
                ,
                function():void {
                    baseBmd = getResourceById(imgUrl).toBitmapData();
                    for (var i:uint=0;i<2;i++) {
                        sound[i] = getResourceById(soundUrl[i]).toSound();
                    }
                    init()
                }
            ).execute();


        }

        
        
        
        private function init():void 
        {
            //心電図画面のデザイン
            monitor = new Sprite();
            this.addChild(monitor);
            back = new Sprite();
            back.graphics.beginFill(0x000000,1)
            back.graphics.drawRect(0, 0, 450, 400)
            back.x = 8;
            back.y = 27;
            
            var i:uint
            var pitch:uint = 30;
            var sp:uint = 15;
            for (i = 0; i < 15; i++ ) {
                back.graphics.lineStyle(0, 0x005500, 1, true, LineScaleMode.NONE);
                back.graphics.moveTo(i * pitch + sp, 0);
                back.graphics.lineTo(i * pitch + sp, 400-1);
                if (i < 13) {
                back.graphics.moveTo(0,i * pitch + sp);
                back.graphics.lineTo(450-1, i * pitch + sp);
                }
                for (var n:uint = 0; n < 13; n++) {
                    back.graphics.beginFill(0x005500, 1);
                    back.graphics.drawCircle(i * pitch + sp, n * pitch + sp, 2);
                    back.graphics.endFill();
                }
            }            
            monitor.addChild(back);
            
            line = new Sprite();
            line.x = 8
            line.y = 33 + 250
            monitor.addChild(line);

            line.filters = new Array(getBitmapFilter(0x00FF00));
            
            //マーカー
            marker = new Sprite();
            marker.graphics.beginFill(0xFFFFFF,1)
            marker.graphics.drawCircle(0, 0, 4);
            monitor.addChild(marker)
            marker.filters = new Array(getBitmapFilter(0xFFFFFF));
            
            
            //デジタル時計部分
            clock = new TextField();
            clock.autoSize = TextFieldAutoSize.CENTER;
            clock.selectable = false;
            clock.mouseEnabled = false;
            var format:TextFormat = new TextFormat();
            format.color = 0x00CC00;
            format.size = 80;
            format.bold = true;
            format.font = '_等幅';
            format.align = 'center';
            clock.defaultTextFormat = format;
            
            monitor.addChild(clock);
            clock.x = 232;
            clock.y = 40
            
            //心臓画像
            heart = new Sprite()
            var hbt:Bitmap = new Bitmap(baseBmd)
            heart.addChild(hbt)
            hbt.x = hbt.width / -2;
            hbt.y = hbt.height / -2;
            heart.scaleX = 2;
            heart.scaleY = 2;
            heart.alpha = 0;
            heart.x = (465 / 2);
            heart.y = (465 / 2);            
            this.addChild(heart);
            
            
            var timer:Timer = new Timer(10);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start();

            points = new Array()
            points[0] = new Vector.<lineParts>;
            points[1] = new Vector.<lineParts>;
            
            for (i = 0; i < 100;i++ ) {
                points[0][i] = new lineParts((450 / 100) * (i % 100), 0,true);
                points[1][i] = new lineParts((450 / 100) * (i % 100), 0,true);                
            }
    
            var tempArray:Array = new Array(5,-10,5,0,0,0,10,-45,-100,-45,30,15,0,0,0,0,0,0,-5,-12,-17,-19,-20,-19,-17,-12,-5,0,5,0,-5,0)
            
            for (i = 0; i < 32; i++ ) {
                if (tempArray[i] == -1) {
                    points[0][i + 12].visible = false;
                    points[1][i + 12].visible = false;
                    points[0][i + 62].visible = false;
                    points[1][i + 62].visible = false;                    
                } else {
                    points[0][i + 12].y = tempArray[i];
                    points[1][i + 12].y = tempArray[i];
                    points[0][i + 62].y = tempArray[i];
                    points[1][i + 62].y = tempArray[i];
                }    
            }
            startTime=new Array()
        }
        
    
    private function onTimer(e:TimerEvent):void {
      var nowTime:Date = new Date();
      updateView(nowTime);
    }

    private function updateView(nowTime:Date):void {
            var i:uint, n:uint;
            //ラインの更新
            line.graphics.clear();
            line.graphics.moveTo(0, 0);            

            var passTime:Array = new Array();
            
            for (n = 0; n < 2;n++ ) {
                if (startTime[n]) {
                    passTime[n] = getPassTime(startTime[n],nowTime)
                    line.graphics.moveTo(0, 0);            
                    for (i = 0; i < passTime[n]; i++) {
                        if (i < 100) {
                            if (points[n][i].visible) {
                                line.graphics.lineStyle(2, 0x00FF00, points[n][i].alpha);                                
                                line.graphics.lineTo(points[n][i].x, points[n][i].y);
                            }
                        }
                    }
                }
            }
            if (passTime[0]<100) {
                marker.x = points[0][passTime[0]].x + 8;
                marker.y = points[0][passTime[0]].y + 33 + 250;
            } else {
                if (passTime[1]<100) {                
                    marker.x = points[1][passTime[1]].x + 8;
                    marker.y = points[1][passTime[1]].y + 33 + 250;
                }
            }
            
            //時計の更新
            if (secStr!=addZero(nowTime.getSeconds())) {
                hourStr = addZero(nowTime.getHours())
                minStr = addZero(nowTime.getMinutes()); 
                secStr = addZero(nowTime.getSeconds());

                if (nowTime.getSeconds() % 4==0) {
                    initLine(0)
                } else if (nowTime.getSeconds() % 4 == 2) {
                    initLine(1)
                }
                startTime[2] = new Date()
                update=true
            }
            
            //0.5秒後に更新
            if (startTime[2]) {
                passTime[2] = getPassTime(startTime[2],nowTime)
                if (update && passTime[2] > 20) {
                    sound[0].play(0)
                    sound[1].play(0)                    
                    heart.alpha = 0.3
                    heart.scaleX=2
                    clock.text = hourStr + ":" + minStr + ":" + secStr;
                    update = false;
                }
            }
            heart.alpha -= 0.01
            heart.scaleX -= 0.01
            if (heart.scaleX<1.5) {
                heart.scaleX=1.5
                
            }
    }
        
        private function initLine(id:uint):void {
            startTime[id] = new Date();
            for (var i:uint = 0; i < 100; i++) {
                points[id][i].init()
            }                                
        }
        

        private function getPassTime(startTime:Date,nowTime:Date):Number {
                var passTime:Number = startTime.getTime() - nowTime.getTime();
                var result:Number = -1 * Math.floor(passTime / 20);    
                return result;
        }
        
        
        private function addZero(no:int):String {
            var result:String = (no < 10)? "0" + no.toString() : no.toString();
            
            return result;
        }
        
        
        private function getBitmapFilter(_color:uint):BitmapFilter {
            var color:Number = _color;
            var alpha:Number = 1;
            var blurX:Number = 16;
            var blurY:Number = 16;
            var strength:Number = 3;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
            alpha,blurX,blurY,strength,quality,inner,knockout);
        }
        
        
    }
    
}


import flash.geom.Point;

class lineParts {
    //寿命つきのラインパーツ
    public var _point:Point;
    public var _alpha:Number;
    public var _color:uint;
    public var _visible:Boolean
    private var _startTime:Date;
    private var _counter:uint;
    
    public function lineParts(_x:Number,_y:Number,_vi:Boolean):void {
        _point = new Point(_x,_y);
        _color = 0x000000;
        _alpha = 1;
        _visible = _vi
        _startTime = new Date();        
    }

    public function init():void {
        _alpha = 1
        _counter = 0
    }
    
    public function get alpha():Number {
        if (!_counter) {
            _startTime = new Date();
            _counter = 1;
        }
    
        var    _nowTime:Date = new Date()
        var _passTime:Number = Math.round((_nowTime.getTime() - _startTime.getTime()) / 100);
        if (_passTime>5) {
            _alpha-=1/70
        }
        return _alpha
    }
    
    public function get x():Number {
        return _point.x
    }

    public function get y():Number {
        return _point.y
    }

    public function set visible(value:Boolean):void {
        _visible = value;
    }    
    
    public function get visible():Boolean {
        return _visible
    }
    
    public function set y(no:Number):void {
        _point.y=no
    }
    
}




