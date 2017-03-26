package  
{
    import flash.events.KeyboardEvent;
    import com.bit101.components.RadioButton;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.GestureEvent;
    import flash.events.GesturePhase;
    import flash.events.MouseEvent;
    import flash.events.PressAndTapGestureEvent;
    import flash.events.TouchEvent;
    import flash.events.TransformGestureEvent;
    import flash.text.TextField;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    import flash.utils.getDefinitionByName;
    
    /**
     * ジェスチャーイベントとタッチイベントのテスト
     * とりあえず関係しそうなのを色々ともじゃもじゃ入れた。
     * AIR exit : MENU, BACK or HOME
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0xFFFFFF", frameRate = "30", width = "640", height = "800")]
    public class GestureTest extends Sprite 
    {
        private var txt: TextField;
        private var radioBtns: Array/*RadioButton*/ = [];
        private var sp:Sprite;
        
        public function GestureTest() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            addChild(sp = new Sprite());
            addChild(txt = new TextField());
            txt.selectable = txt.mouseEnabled = false;
            txt.scaleX = txt.scaleY = 1.5;
            var i: int, n: int;
            if (Multitouch.supportsGestureEvents)
            {
                txt.appendText("Multitouch.supportsGestureEvents == true\n");
                n = Multitouch.supportedGestures.length;
                for (i = 0; i < n; i++) 
                {
                    txt.appendText("\t" + Multitouch.supportedGestures[i] + " is Supported.\n");
                    switch (Multitouch.supportedGestures[i])
                    {
                        case GestureEvent.GESTURE_TWO_FINGER_TAP:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGestureTwoFingerTap)
                        break;
                        case PressAndTapGestureEvent.GESTURE_PRESS_AND_TAP:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGesturePressAndTap)
                        break;
                        case TransformGestureEvent.GESTURE_PAN:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGesturePan)
                        break;
                        case TransformGestureEvent.GESTURE_ROTATE:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGestureRotate)
                        break;
                        case TransformGestureEvent.GESTURE_SWIPE:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGestureSwipe)
                        break;
                        case TransformGestureEvent.GESTURE_ZOOM:
                            sp.addEventListener(Multitouch.supportedGestures[i], onGestureZoom);
                        break;
                    }
                }
            }
            else 
            {
                txt.appendText("Multitouch.supportsGestureEvents == false\n");
            }
            if (Multitouch.supportsTouchEvents)
            {
                txt.appendText("Multitouch.supportsTouchEvents == true\n");
                txt.appendText("Multitouch.maxTouchPoints == " + Multitouch.maxTouchPoints + "\n");
                sp.addEventListener(TouchEvent.TOUCH_BEGIN,     onTouch);
                sp.addEventListener(TouchEvent.TOUCH_END,       onTouch);
                sp.addEventListener(TouchEvent.TOUCH_MOVE,      onTouch);
                sp.addEventListener(TouchEvent.TOUCH_OUT,       onTouch);
                sp.addEventListener(TouchEvent.TOUCH_OVER,      onTouch);
                sp.addEventListener(TouchEvent.TOUCH_ROLL_OUT,  onTouch);
                sp.addEventListener(TouchEvent.TOUCH_ROLL_OVER, onTouch);
                sp.addEventListener(TouchEvent.TOUCH_TAP,       onTouch);
            }
            else 
            {
                txt.appendText("Multitouch.supportsTouchEvents == false\n");
            }
            radioBtns.push(new RadioButton(this, 0, 0, MultitouchInputMode.GESTURE,     true,  onClickRadio));
            radioBtns.push(new RadioButton(this, 0, 0, MultitouchInputMode.NONE,        false, onClickRadio));
            radioBtns.push(new RadioButton(this, 0, 0, MultitouchInputMode.TOUCH_POINT, false, onClickRadio));
            n = radioBtns.length;
            for (i = 0; i < n; i++) 
            {
                radioBtns[i].scaleX = radioBtns[i].scaleY = 1.5;
                radioBtns[i].draw();
            }
            stage.addEventListener(Event.RESIZE, onResize);
            onResize();
            stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
        }
        
        private function onKey(e:KeyboardEvent):void 
        {
            switch (e.keyCode)
            {
                case 36: // HOME
                case 0x01000016: // BACK
                case 0x01000012: // MENU
                    try
                    {
                        
                        (getDefinitionByName("flash.desktop.NativeApplication") as Class).nativeApplication.exit();
                    }
                    catch (err: Error) { }
                break;
            }
        }
        
        private function onTouch(e: TouchEvent): void 
        {
            if (e.type == TouchEvent.TOUCH_BEGIN && e.isPrimaryTouchPoint)
            {
                txt.text = e.type + ", localX: " + e.localX + ", localY: " + e.localY + ", touchPointID: " + e.touchPointID + 
                    "\n\tsizeX: " + e.sizeX + ", offsetY: " + e.sizeY + ", pressure: " + e.pressure + "\n";
            }
            else 
            {
                txt.appendText(
                    e.type + ", localX: " + e.localX + ", localY: " + e.localY + ", touchPointID: " + e.touchPointID + 
                    "\n\tsizeX: " + e.sizeX + ", offsetY: " + e.sizeY + ", pressure: " + e.pressure + "\n"
                );
                txt.scrollV = txt.maxScrollV;
            }
        }
        
        private function onResize(e: Event = null): void 
        {
            sp.graphics.clear();
            sp.graphics.beginFill(0xCCCCCC, 1);
            sp.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            var i:int, n: int = radioBtns.length, r: RadioButton;
            for (i = 0; i < n; i++) 
            {
                r = radioBtns[i];
                r.x = stage.stageWidth  - r.width * r.scaleX;
                r.y = stage.stageHeight - ((r.height + 5) * (i + 1) * r.scaleY);
            }
            txt.width = stage.stageWidth, txt.height = stage.stageHeight;
        }
        
        private function onClickRadio(e: MouseEvent): void 
        {
            Multitouch.inputMode = RadioButton(e.target).label;
            txt.text = "Multitouch.inputMode == " + Multitouch.inputMode;
        }
        
        private function onGestureZoom(e: TransformGestureEvent): void 
        {
            if (e.phase == GesturePhase.BEGIN) 
            {
                txt.text = e.type + ", phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + ", rotation:" + e.rotation + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + ", scaleX: " + e.scaleX + ", scaleY: " + e.scaleY +
                    "\n";
            }
            else
            {
                txt.appendText(
                    "phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + ", rotation:" + e.rotation + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + ", scaleX: " + e.scaleX + ", scaleY: " + e.scaleY +
                    "\n"
                );
                txt.scrollV = txt.maxScrollV;
            }
        }
        
        private function onGestureSwipe(e: TransformGestureEvent): void 
        {
            txt.text = 
                e.type + ", phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + "\n"
            ;
            txt.scrollV = txt.maxScrollV;
        }
        
        private function onGestureRotate(e: TransformGestureEvent):void 
        {
            if (e.phase == GesturePhase.BEGIN) 
            {
                txt.text = e.type + ", phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + ", scaleX: " + e.scaleX + ", scaleY: " + e.scaleY +
                    ", rotation:" + e.rotation + "\n";
            }
            else
            {
                txt.appendText(
                    "phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + ", scaleX: " + e.scaleX + ", scaleY: " + e.scaleY +
                    ", rotation:" + e.rotation + "\n"
                );
                txt.scrollV = txt.maxScrollV;
            }
        }
        
        private function onGesturePan(e: TransformGestureEvent): void 
        {
            if (e.phase == GesturePhase.BEGIN) 
            {
                txt.text = e.type + ", phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + "\n";
            }
            else
            {
                txt.appendText(
                    "phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\toffsetX: " + e.offsetX + ", offsetY: " + e.offsetY + "\n"
                );
                txt.scrollV = txt.maxScrollV;
            }
        }
        
        private function onGesturePressAndTap(e: PressAndTapGestureEvent): void 
        {
            if (e.phase == GesturePhase.BEGIN) 
            {
                txt.text = e.type + ", phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\ttapLocalX: " + e.tapLocalX + ", tapLocalY: " + e.tapLocalY + "\n"
            }
            else
            {
                txt.appendText(
                    "phase: " + e.phase + ", localX: " + e.localX + ", localY: " + e.localY + 
                    "\n\ttapLocalX: " + e.tapLocalX + ", tapLocalY: " + e.tapLocalY + "\n"
                );
                txt.scrollV = txt.maxScrollV;
            }
        }
        
        private function onGestureTwoFingerTap(e: GestureEvent):void 
        {
            txt.text = e.type + "\n phase: " + e.phase + "\n localX: " + e.localX + "\n localY: " + e.localY;
        }
        
    }

}