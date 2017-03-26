package {
    import flash.display.LoaderInfo;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.display.StageScaleMode;
    import flash.net.URLRequest;
    import flash.ui.Mouse;
    import flash.system.ApplicationDomain; 
    import flash.system.SecurityDomain;
    import flash.system.LoaderContext;
    
    public class CharlotteChaser extends Sprite {
        public var Character:Class;
        public var Cursor:Class;
        
        public const MOUSE_SPEED:Number = 0.07;
        public const CHASE_SPEED:Number = 0.5;
            
        private var arr:Vector.<MovieClip> = new Vector.<MovieClip>;
        private var cursor:Sprite;
        
        private var loader:Loader;
        
        public function CharlotteChaser() {
            this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function onAddedToStage(e:Event):void {
            loader = new Loader();
            var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.load(new URLRequest('http://cfs.tistory.com/custom/blog/87/874645/skin/images/_CharlotteAsset.swf'), lc);
        }

        
        private function onLoadComplete(e:Event):void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            Character = (e.target as LoaderInfo).applicationDomain.getDefinition("Character") as Class;
            Cursor = (e.target as LoaderInfo).applicationDomain.getDefinition("Cursor") as Class;
            
            var prev:MovieClip;
            var now:MovieClip = new Character();
            arr.push(now);
            now.gotoAndStop(1);
            now.addEventListener(Event.ENTER_FRAME, chaseMouse);
            now.x = stage.stageWidth/2;
            now.y = stage.stageHeight/2;
            
            this.addChild(now);
            
            var i:int;
            for(i=2; i<=now.totalFrames; i++){
                prev = now;
                now = new Character();
                arr.push(now);
                now.gotoAndStop(i);
                now.addEventListener(Event.ENTER_FRAME, chaseTarget);
                now.x = stage.stageWidth/2;
                now.y = stage.stageHeight/2;
                this.addChildAt(now, 0);
            }
            
            cursor = new Cursor();
            cursor.mouseEnabled = false;
            this.addChild(cursor);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, setCursor);
        }
        
        private function chaseMouse(e:Event):void {
            e.target.x += (stage.mouseX-e.target.x)*MOUSE_SPEED;
            e.target.y += (stage.mouseY-e.target.y)*MOUSE_SPEED;
        }
        
        private function chaseTarget(e:Event):void {
            e.target.x += (arr[e.target.currentFrame-2].x-e.target.x)*CHASE_SPEED;
            e.target.y += (arr[e.target.currentFrame-2].y-e.target.y)*CHASE_SPEED;
        }
        
        private function setCursor(e:MouseEvent):void {
            cursor.x = stage.mouseX;
            cursor.y = stage.mouseY;
            Mouse.hide();
        }

     }
}