package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    [SWF(width="465", height="465", backgroundColor="#ffffff",frameRate="60")]
    public class rubik2 extends Sprite
    {
        public var date:Date;
        public var str:String = new String();
        public var videoArr:Array = new Array();
        public var text:TextField = new TextField();
        public var clockStart:Boolean = false;
        public var urlstr:String = "http://www5.pf-x.net/~aomori-ringo/doc/rubik/";
        public var firstStr:TextField = new TextField();
     
        public function rubik2()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            clockInit();
            videoInit();
            
            stage.addEventListener(MouseEvent.CLICK, onClick);
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function clockInit():void{
            var format:TextFormat = new TextFormat();
            format.size = 20;
            format.color = 0x000000;
            
            text.defaultTextFormat = format;
            text.x = 60;
            text.y = 360;
            text.width = 800;
            text.scaleX = text.scaleY = 2;
            
            stage.addChild(text);
            
        }
        
        private function videoInit():void{
            for(var i:int = 0; i<12 ; i++){
                var v:myVideo;
                if(i<4){
                    v = new myVideo(i*112+10, 90, i);
                }
                else if(i<8){
                    v = new myVideo((i-4)*112+10, 180, i);
                }
                else{
                    v = new myVideo((i-8)*112+10, 270, i);
                }
                
                addChild(v);
                videoArr.push(v);
            }
        }
        
        private function videoClick(e:MouseEvent):void{
            for(var i:int=0 ; i<12 ; i++){
                if(e.target.name != String(i)) continue;
                
                var str:String = stringDate(10);
                e.target.play(urlstr + "_" + str.charAt(i) + "_10sec.flv");
            }
        }
        
        private function onClick(e:MouseEvent):void{
            allVideoPlay();
            stage.removeEventListener(MouseEvent.CLICK, onClick);
            
            for(var i:int=0 ; i<12 ; i++){
                videoArr[i].addEventListener(MouseEvent.CLICK, videoClick);
            }
        }
        
        private function allVideoPlay():void{
            // 11秒後の時刻
            str = stringDate(11);
            clockStart = true;
            
            for(var i:int=0 ; i<videoArr.length ; i++){
                videoArr[i].play(urlstr + "_"+ str.charAt(i) + "_10sec.flv");
            }
        }
        
        // 年・月・日・HOUR・MINをstringにして返す
        private function stringDate(n:int):String{
            date = new Date();
            str = "";
            
            var year:Number = date.fullYear;
            var month:Number = date.month+1;
            var day:Number = date.date;
            var hour:Number = date.hours;
            var min:Number = date.minutes;
            var sec:Number = date.seconds + n;
            
            if(sec >= 60){
                min += 1;
                sec -= 60;
            }
            
            if(min==60){
                min=0;
                hour+=1;
            }
            if(hour==24){
                hour=0;
                day++;
            }
            
            if(day==32){
                month++;
                day-=31;
            }

            
            str += year;
            str += (month<10 ? "0" : "") +month;
            str += (day<10 ? "0" : "") + day;
            str += (hour<10 ? "0" : "") + hour;
            str += (min<10 ? "0" : "") + min;
            
            return str;
        }
        
        private function onEnterFrame(e:Event):void{
            date = new Date();
            
            str = "";
            str += date.fullYear + "/";
            str += (date.month<9 ? "0" : "") + (date.month+1) +"/";
            str += (date.date < 10 ? "0" : "") + date.date +" ";
            str += (date.hours<10 ? "0" : "") + date.hours +":";
            str += (date.minutes < 10 ? "0" : "") + date.minutes +":";
            str += (date.seconds < 10 ? "0" : "") + date.seconds;
            
            text.text = str;
            
            if(int(date.seconds)==49 && clockStart){
                var str1:String = stringDate(0);
                var str2:String = stringDate(11);
            
                for(var i:int=0 ; i<12 ; i++){
                    if(str1.charAt(i)==str2.charAt(i)) continue;
                    
                    if(i==8 && str1.charAt(i)==String(2)) videoArr[i].play( urlstr + "_" + str2.charAt(i) + "_10sec.flv");
                    else if(i==10 && str1.charAt(i)==String(5)) videoArr[i].play( urlstr + "_" + str2.charAt(i) + "_10sec.flv");
                    else videoArr[i].play( urlstr + str1.charAt(i) + "_" + str2.charAt(i) + "_10sec.flv" );
                }
            }
        }
    }
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class myVideo extends Sprite{
    public var video:Video = new Video(112,84);
    public var nc:NetConnection = new NetConnection();
    public var ns:NetStream;
    public var path:String;
    public var totalTime:Number;
    public var num:int;
    public var urlstr:String = "http://www5.pf-x.net/~aomori-ringo/doc/rubik/";
    
    public function myVideo(x:Number, y:Number, n:int):void{
        
        num = n;
        
        this.buttonMode = true;
        this.useHandCursor = true;
        
        this.name = String(num);
        this.x = x;
        this.y = y;
        
        nc.connect(null);
        ns = new NetStream(nc);
        var meta:Object = new Object();
        ns.client = meta;
        video.attachNetStream(ns);    
        this.addChild(video);
        this.mouseChildren = false;
        
        ns.play(urlstr + "_0_10sec.flv");
        stop();
        ns.seek(0);
    }
    
    public function play(s:String):void{
        ns.seek(0);
        ns.play(s);
        path = s;
    }
    
    public function stop():void{
        ns.pause();
    }
    
}