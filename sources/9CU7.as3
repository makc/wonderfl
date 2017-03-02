package  
{
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.filters.DropShadowFilter;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import jp.progression.commands.lists.LoaderList;
    import jp.progression.commands.net.LoadBitmapData;
    import jp.progression.events.ExecuteEvent;
    import net.hires.debug.Stats;
    import flash.system.Security;
    /**
     * 
     * @Author motikawa / t.okazaki
     */
    [SWF(width = 465, height = 465, backgroundColor = 0xffffff, frameRate = 60)]
    public class Main extends Sprite
    {
        private static const CHAIN_NUM:int = 201;
        private var _chains:Vector.<IKChain>;
        private var _container:Sprite;
        public function Main() 
        {
            _init();
        }
        private function _init():void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            var llist:LoaderList = new LoaderList();
            llist.addCommand(new LoadBitmapData(new URLRequest("http://assets.wonderfl.net/images/related_images/4/44/4414/441464e04ce95146813dbe1d1cce43f6e8764828"), { context:new LoaderContext(true) } ));
            llist.addCommand(new LoadBitmapData(new URLRequest("http://assets.wonderfl.net/images/related_images/5/57/57e8/57e8d4f9a43047ff3636c836c072eea10b359446"), { context:new LoaderContext(true) } ));
            llist.addEventListener(ExecuteEvent.EXECUTE_COMPLETE, _onComplete);
            llist.execute();
            
        }
        
        private function _onComplete(e:Event):void
        {
            var llist:LoaderList = e.target as LoaderList;
                
            IKChain.center = new Point(stage.stageWidth * .5, stage.stageHeight * .5);
            Chain.initialize(llist.latestData[1], llist.latestData[0]);
            
            _chains = new Vector.<IKChain>(CHAIN_NUM, true);
            addChildAt(_container = new Sprite(), 0);
            addChild(new Stats());
            
            var c:IKChain,
                i:int = 0,
                len:int = CHAIN_NUM -1;
            //2010/09/17 深度の変更方法を追加
            for (i = 0 ; i < CHAIN_NUM; i++) _chains[i] = _container.addChildAt(new IKChain(i % 2), 0) as IKChain;
            //深度の変更
            for ( i = 1 ; i < CHAIN_NUM - 1; i += 2) _container.setChildIndex(_chains[i], _container.getChildIndex(_chains[i -1]));
            
            _container.filters = [new DropShadowFilter(4, 45, 0x0, .6, 4, 4, 1)];
            addEventListener(Event.ENTER_FRAME, _loop);
        }
        private function _loop(e:Event):void
        {
            var i:int = 0, len:int = _chains.length, c:IKChain;
            
            (_chains[0] as IKChain).dragTo(stage.mouseX, stage.mouseY);
            
            for (i = 1; i < len; i++)
            {
                c = _chains[i];
                c.dragToTarget(_chains[i - 1]);
            }
        }
    }
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.utils.ByteArray;
class Chain extends Bitmap
{
    private namespace type1 = "type1";
    private namespace type2 = "type2";
    private static const BLUR:BlurFilter = new BlurFilter(8, 8, 2);
    private static const OVERLAY_COLOR:uint = 0xcccccc;
    private static const ZERO_POS:Point = new Point();
    
    type1 static var _bytes:Vector.<ByteArray>;
    type2 static var _bytes:Vector.<ByteArray>;
    type1 static var _rect:Rectangle;
    type2 static var _rect:Rectangle;
    public static function initialize(bmd1:BitmapData,bmd2:BitmapData):void
    {
        type1::_bytes = new Vector.<ByteArray>(360, true);
        type2::_bytes = new Vector.<ByteArray>(360, true);
        type1::_rect = new Rectangle(0, 0, bmd1.width, bmd1.height);
        type2::_rect = new Rectangle(0, 0, bmd2.width, bmd2.height);
        
        var overlay:BitmapData = new BitmapData(1, 1, false, OVERLAY_COLOR),
            bevel:BevelFilter = new BevelFilter(2, 0, 0xffffff, 1, 0x444444, 1, 2, 2, 4, 1),
            i:int = 0 , len:int = 360;
        for (i = 0 ; i < len ; i++)
        {
            bevel.angle = i;
            type1::_bytes[i] = _makeChain(bevel, bmd1, overlay);
            type2::_bytes[i] = _makeChain(bevel, bmd2, overlay);
        }
    }
    private static function _makeChain(bevelFilter:BevelFilter,base:BitmapData,overlay:BitmapData):ByteArray
    {
        var bmd:BitmapData = base.clone(),
            mt:Matrix = new Matrix(base.width, 0, 0, base.height),
            newBmd:BitmapData = new BitmapData(base.width, base.height, true, 0x0);
        bmd.applyFilter(bmd, bmd.rect, ZERO_POS, BLUR);
        bmd.applyFilter(bmd, bmd.rect, ZERO_POS, bevelFilter);
        bmd.draw(overlay, mt, null, BlendMode.OVERLAY);
        newBmd.copyPixels(bmd, bmd.rect, ZERO_POS, base);
        return newBmd.getPixels(newBmd.rect);
    }
    
    private var _angle:Number;
    private var _ns:Namespace;
    public function Chain(type:uint)
    {
        if (type == 1) _ns = type1;
        else _ns = type2;
        
        super(new BitmapData(_ns::_rect.width, _ns::_rect.height, true, 0x0) , "auto", true);
        bevelAngle = 0;
    }
    public function get bevelAngle():int { return _angle; }
    public function set bevelAngle(value:int):void
    {
        if (_angle == value) return;
        while (value >= 360) value -= 360;
        while (value <  0  ) value += 360;
        _angle = int(value);
        _ns::_bytes[_angle].position = 0;
        bitmapData.setPixels(bitmapData.rect, _ns::_bytes[_angle]);
    }
}

class IKChain extends Sprite
{
    public static var center:Point;
    public static const RADIAN:Number = Math.PI / 180;
    private var _length:Number;
    private var _chain:Chain;
    public function IKChain(type:uint)
    {
        addChildAt(_chain = new Chain(type), 0);
        _chain.smoothing = true;
        _chain.scaleX = _chain.scaleY = .3;
        _length = width * .5;
        _chain.y -= _chain.height * .5;
    }
    public function dragTo(xpos:Number, ypos:Number):void
    {
        var dx:Number = xpos - x,
            dy:Number = ypos - y,
            rad:Number = Math.atan2(dy, dx),
            degree:Number = rad / RADIAN;
        rotation = degree;
        x = xpos - Math.cos(rad) * _length;
        y = ypos - Math.sin(rad) * _length;
        _updateAngle();
    }
    public function dragToTarget(chain:IKChain):void
    {
        var dx:Number = chain.x - x,
            dy:Number = chain.y - y,
            rad:Number = Math.atan2(dy, dx),
            degree:Number = rad / RADIAN;
        rotation = degree;
        x = chain.x - Math.cos(rad) * _length;
        y = chain.y - Math.sin(rad) * _length;
        _updateAngle();
    }
    private function _updateAngle():void
    {
        if (center)    _chain.bevelAngle = Math.atan2(center.y - y , center.x - x) / RADIAN  - 90;
    }
}