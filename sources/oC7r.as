package {
    import flash.text.TextField;
    import flash.display.Sprite;
    import com.adobe.viewsource.ViewSource;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // ViewSource.addMenuItem(this, "http://wonderfl.net/c/<codeid>/read");
            ViewSource.addMenuItem(this, "http://wonderfl.net/c/oC7r/read");
            
            var txt:TextField = new TextField();
            txt.appendText("right click!");
            addChild(txt);
        }
    }
}