package  
{
    import com.bit101.components.HBox;
    import com.bit101.components.PushButton;
    import com.bit101.components.TextArea;
    import com.codeazur.as3swf.SWF;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    /**
     * ...
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0xFFFFFF", frameRate = "30", width = "465", height = "465")]
    public class AS3SWFTest extends Sprite
    {
        private var loadBtn: PushButton;
        private var txtArea: TextArea;
        private var file: FileReference;
        private var swf: SWF;
        private var tagBtn: PushButton;
        private var sceneBtn: PushButton;
        private var frameBtn: PushButton;
        private var layerBtn: PushButton;
        private var resultBtn: PushButton;
        private var viewBtns: HBox;
        private var selectedView: PushButton;
        
        
        public function AS3SWFTest() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            file = new FileReference();
            file.addEventListener(Event.SELECT, onSelectSWF);
            file.addEventListener(Event.COMPLETE, onLoadSWF);
            var hbox: HBox = new HBox(this);
            hbox.spacing = 10;
            loadBtn = new PushButton(hbox, 0, 0, "load swf", onClickBtn);
            viewBtns = new HBox(hbox);
            tagBtn = new PushButton(viewBtns, 0, 0, "tags", onClickTag);
            sceneBtn = new PushButton(viewBtns, 0, 0, "scenes", onClickScene);
            frameBtn = new PushButton(viewBtns, 0, 0, "frames", onClickFrame);
            layerBtn = new PushButton(viewBtns, 0, 0, "layers", onClickLayers);
            resultBtn = new PushButton(viewBtns, 0, 0, "result", onClickResult);
            tagBtn.width = sceneBtn.width = frameBtn.width = layerBtn.width = resultBtn.width = 50;
            tagBtn.toggle = sceneBtn.toggle = frameBtn.toggle = layerBtn.toggle = resultBtn.toggle = true;
            tagBtn.selected = true, selectedView = tagBtn;
            viewBtns.enabled = false;
            
            txtArea = new TextArea(this, 0, 20);
            txtArea.setSize(stage.stageWidth, stage.stageHeight - 20);
        }
        
        private function onClickBtn(e: Event):void 
        {
            file.browse([new FileFilter("swf", "*.swf")]);
        }
        
        private function onSelectSWF(e:Event):void 
        {
            txtArea.text = "";
            file.load();
        }
        
        private function onLoadSWF(e:Event):void 
        {
            swf = new SWF(file.data);
            viewBtns.enabled = true;
            showData();
        }
        
        private function showData(): void 
        {
            var str: String = "";
            var i: int, n: int;
            switch (selectedView)
            {
                case tagBtn:
                    str = "" + swf.tags;
                break;
                case sceneBtn:
                    str = "" + swf.scenes;
                break;
                case frameBtn:
                    str = "frameRate : " + swf.frameRate + "\nframeSize : " + swf.frameSize + "\nframeCount : " + swf.frameCount + "\n-----\n" + swf.frames;
                break;
                case layerBtn:
                    //str = "" + swf.layers;
                    n = swf.layers.length;
                    for (i = 0; i < n; i ++)
                    {
                        str += "depth: " + swf.layers[i].depth + ",  ";
                        str += "frameCount: " + swf.layers[i].frameCount + ",  ";
                        str += "frameStripMap: " + swf.layers[i].frameStripMap + ",  ";
                        str += "strips: " + swf.layers[i].strips + "\n"
                    }
                break;
                case resultBtn:
                    str = swf.toString();
                break;
            }
            txtArea.text = str;
        }
        
        private function onClickTag(e: Event):void 
        {
            if (selectedView) selectedView.selected = false;
            selectedView = tagBtn;
            selectedView.selected = true;
            showData();
        }
        
        private function onClickScene(e: Event):void 
        {
            if (selectedView) selectedView.selected = false;
            selectedView = sceneBtn;
            selectedView.selected = true;
            showData();
        }
        
        private function onClickFrame(e: Event):void 
        {
            if (selectedView) selectedView.selected = false;
            selectedView = frameBtn;
            selectedView.selected = true;
            showData();
        }
        
        private function onClickLayers(e: Event):void 
        {
            if (selectedView) selectedView.selected = false;
            selectedView = layerBtn;
            selectedView.selected = true;
            showData();
        }
        
        private function onClickResult(e: Event):void 
        {
            if (selectedView) selectedView.selected = false;
            selectedView = resultBtn;
            selectedView.selected = true;
            showData();
        }
        
    }

}