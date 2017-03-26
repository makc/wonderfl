/**
 * アリの巣を見てるだけ
 * 
 * @author tencho
 */
package
{
    import com.bit101.components.Style;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.UncaughtErrorEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class AntColony  extends Sprite
    {
        private var _time:int;
        private var _world:World;
        private var _speed:int;
        private var _drag:DragManager = new DragManager();
        private var _tool:ToolMenu = new ToolMenu();
        private var _tracking:TrackingMenu = new TrackingMenu();
        private var _isTracking:Boolean = false;
        private var _webScroll:WebScrollStopper;
        
        public function AntColony()
        {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError);
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function onGlobalError(e:UncaughtErrorEvent):void 
        {
            e.preventDefault();
        }
        
        private function init(e:Event = null):void
        {
            Style.LABEL_TEXT = 0xFFFFFF;
            Display.init(stage, 465, 465);
            stage.frameRate = 30;
            stage.quality = "low";
            Image.load(onReady);
        }
        
        private function onReady():void
        {
            _world = new World();
            _world.init();
            Status.init();
            _speed = Param.normalSpeed;
            
            _webScroll = new WebScrollStopper(Display.width, Display.height);
            var cp:Point = _world.toCanvasXY(_world.colony.getRooms(Primitive.QUEEN)[0].point);
            _drag.init(_webScroll, cp.x, cp.y, 1);
            _drag.addEventListener(MouseEvent.MOUSE_MOVE, onDragCanvas);
            _drag.addEventListener(MouseEvent.CLICK, onClickCanvas);
            _drag.setScaleRange(0.3, 2.5);
            _drag.setDragArea(new Rectangle(0, 0, 150 * 6, 170 * 6));
            _drag.dragSpeed.x = _drag.dragSpeed.y = -1;
            
            addChild(SpriteUtil.box((Display.width - 4000) / 2, (Display.height - 4000) / 2, 4000, 4000, 0));
            addChild(_world.canvas);
            addChild(_webScroll);
            addChild(_tool.sprite);
            addChild(_tracking.sprite);
            addChild(SpriteUtil.box((Display.width - 4000) / 2, - 2000, 4000, 2000, 0));
            
            _tool.init();
            _tracking.init();
            _tracking.sprite.x = 205;
            _tool.addEventListener(Event.CHANGE, onChangeSpeed);
            _tracking.addEventListener(MouseEvent.CLICK, onCloseTracking);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onCloseTracking(e:MouseEvent):void 
        {
            cancelTracking();
            cancelAnt();
        }
        
        private function onChangeSpeed(e:Event):void 
        {
            _speed = _tool.speed? Param.highSpeed : Param.normalSpeed;
        }
        
        private function onDragCanvas(e:MouseEvent):void 
        {
            cancelTracking();
        }
        
        private function onEnterFrame(e:Event = null):void
        {
            _time++;
            
            for (var i:int = 1; i <= _speed; i++) _world.simulate();
            
            var p:Point = _isTracking? _world.toCanvasXY(_world.trackingAnt.point) : _drag.position;
            _world.updateDraw(p, _drag.scale);
            
            if(_world.trackingAnt) _tracking.update(_world.trackingAnt);
            if(_time % 10 == 0) _tool.update(_world);
        }
        
        private function onClickCanvas(e:MouseEvent = null):void
        {
            cancelTracking();
            var a:Ant = _world.getAntXY(_world.toColonyXY(mouseX, mouseY));
            if (!a) return;
            cancelAnt();
            _isTracking = true;
            _world.trackingAnt = a;
            _world.trackingAnt.addEventListener(Event.REMOVED, onRemoveAnt);
            _tracking.sprite.visible = true;
        }
        
        private function cancelAnt():void 
        {
            _tracking.sprite.visible = false;
            if (!_world.trackingAnt) return;
            _world.trackingAnt.removeEventListener(Event.REMOVED, onRemoveAnt);
            _world.trackingAnt = null;
        }
        
        private function cancelTracking():void 
        {
            
            if (_isTracking)
            {
                _drag.setPoint(_world.toCanvasXY(_world.trackingAnt.point));
            }
            _isTracking = false;
        }
        
        private function onRemoveAnt(e:Event):void 
        {
            cancelTracking();
            cancelAnt();
        }
        
    }

}

import com.bit101.components.Component;
import com.bit101.components.FPSMeter;
import com.bit101.components.HBox;
import com.bit101.components.Label;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.utils.describeType;
import flash.utils.Dictionary;

class Param
{
    static public var antNum:int = 40;
    static public var antMax:int = 1000;
    static public var normalSpeed:int = 1;
    static public var highSpeed:int = 10;
    
    static public var clumpNum:Array = [30, 70];
    static public var foodNutrients:Array = [1500, 2200];
    static public var antSpeed:Array = [0.3, 0.45];
    static public var queenSpeed:Number = 0.25;
    static public var workerLife:Array = [40000, 70000];
    static public var queenLife:int = 5000000;
    static public var foodLife:int = 50;
    static public var clumpLife:int = 100;
    static public var wanderFreq:Number = 0.7;
    static public var exploreFreq:Number = 0.1;
    static public var assetPath:String = "http://assets.wonderfl.net/images/related_images/f/fe/fe2b/fe2b013816f9c4d2328e8ed533b930b8d5b97a01";
}

class WebScrollStopper extends Sprite
{
    private var _txt:TextField = new TextField();
    
    public function WebScrollStopper(width:Number, height:Number)
    {
        _txt.width = width;
        _txt.height = height;
        _txt.alpha = 0;
        _txt.selectable = false;
        _txt.addEventListener(Event.ENTER_FRAME, onTick);
        _txt.addEventListener(Event.SCROLL, function(e:Event):void { _txt.scrollV = 2; } );
        addChild(_txt);
    }
    
    private function onTick(e:Event):void 
    {
        _txt.removeEventListener(Event.ENTER_FRAME, onTick);
        while (_txt.maxScrollV <= 3) _txt.appendText(" \n");
    }
    
}

class TrackingMenu extends EventDispatcher
{
    public var sprite:Sprite = new Sprite();
    
    private var _container:HBox;
    private var _button:Sprite = new Sprite();
    private var _action:Label;
    private var _life:Label;
    private var _hungry:Label;
    
    public function TrackingMenu()
    {
    }
    
    public function init():void
    {
        _container = new HBox(null, 5, 6);
        sprite.visible = false;
        
        _button.buttonMode = true;
        _button.addEventListener(MouseEvent.CLICK, onClickClose);
        _button.addChild(new Bitmap(Image.icons[7]));
        
        _container.addChild(_button)
        new Component(_container).width = -1;
        
        var ct:ColorTransform = new ColorTransform();
        ct.color = 0xFFFF00;
        sprite.transform.colorTransform = ct;
        
        _container.addChild(new Bitmap(Image.icons[0]));
        _action = new Label(_container, 0, 0, "");
        new Component(_container).width = 45;
        _container.addChild(new Bitmap(Image.icons[4]));
        _life = new Label(_container, 0, 0, "");
        new Component(_container).width = 30;
        _container.addChild(new Bitmap(Image.icons[3]));
        _hungry = new Label(_container, 0, 0, "");
        new Component(_container).width = 5;
        
        sprite.addChild(_container);
    }
    
    private function onClickClose(e:MouseEvent):void 
    {
        dispatchEvent(e);
    }
    
    public function update(a:Ant):void
    {
        _action.text = Status.LABEL[a.status];
        _hungry.text = String(a.hungry);
        _life.text = String(a.life);
    }
    
}

class ToolMenu extends EventDispatcher
{
    public var sprite:Sprite = new Sprite();
    
    private var _bg:Sprite;
    private var _container:HBox;
    private var _status:HBox;
    private var _antNum:Label;
    private var _foodNum:Label;
    private var _eggNum:Label;
    private var _pupaeNum:Label;
    private var _button:Sprite;
    private var _buttonImage:Bitmap;
    private var _speed:Boolean = false;
    
    public function ToolMenu()
    {
    }
    
    public function get speed():Boolean {return _speed;}
    
    public function init():void
    {
        _bg = SpriteUtil.box(0, 0, Display.width, 30, 0, 0.7);
        _container = new HBox(null, 5, 6);
        _button = new Sprite();
        _button.buttonMode = true;
        _button.addEventListener(MouseEvent.CLICK, onClickSpeed);
        _buttonImage = _button.addChild(new Bitmap(Image.icons[6])) as Bitmap;
        
        _container.addChild(_button);
        new Component(_container).width = -1;
        
        _container.addChild(new Bitmap(Image.icons[0]));
        _antNum = new Label(_container, 0, 0, "");
        new Component(_container).width = 15;
        _container.addChild(new Bitmap(Image.icons[1]));
        _eggNum = new Label(_container, 0, 0, "");
        new Component(_container).width = 5;
        _container.addChild(new Bitmap(Image.icons[2]));
        _pupaeNum = new Label(_container, 0, 0, "");
        new Component(_container).width = 5;
        _container.addChild(new Bitmap(Image.icons[3]));
        _foodNum = new Label(_container, 0, 0, "");
        new Component(_container).width = 5;
        
        sprite.addChild(_bg);
        sprite.addChild(_container);
        new FPSMeter(sprite, Display.width - 45, 6);
    }
    
    private function onClickSpeed(e:MouseEvent):void 
    {
        _speed = !_speed;
        _buttonImage.bitmapData = _speed? Image.icons[5] : Image.icons[6];
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    public function update(w:World):void
    {
        _antNum.text = String(w.ants.length);
        _foodNum.text = String(w.colony.getFoodNum());
        _eggNum.text = String(w.colony.getItemNum(Primitive.EGG));
        _pupaeNum.text = String(w.colony.getItemNum(Primitive.PUPAE));
    }
    
}

class World
{
    public const SCALE:Number = 6;
    public const PI2:Number = Math.PI * 2;
    private const XY:int = 4;
    
    public var canvas:Sprite = new Sprite();
    public var queen:Ant;
    public var ants:Vector.<Ant> = new Vector.<Ant>();
    public var colony:Colony;
    public var ground:Ground;
    public var time:int = 0;
    
    public var exploringRate:Number = 0;
    public var foodRate:Number = 0;
    public var trackingAnt:Ant;
    public var wanderFreq:Number = 0.7;
    
    private var _xy:Array = [];
    private var _updateImage:Boolean = false;
    private var _updatePath:Boolean = false;
    
    private var _bgCanvas:BitmapData;
    private var _antsCanvas:BitmapData;
    private var _shadow:DropShadowFilter = new DropShadowFilter(3, 90, 0, 0.7, 4, 4, 1, 1);
    private var _drawMatrix:Matrix = new Matrix();
    
    public function World()
    {
    }
    
    public function init():void
    {
        var i:int, ix:int, iy:int;
        //コロニー
        colony = new Colony(150, 170, SCALE);
        colony.build(8);
        colony.initPath();
        
        //地上
        ground = new Ground();
        ground.init(this, 30, Random.rangeInt(1, 300));
        _antsCanvas = colony.canvas.clone();
        _bgCanvas = new BitmapData(200, 200, false);
        _bgCanvas.noise(1234, 0x80, 0xFF, 7, true);
        _bgCanvas.colorTransform(_bgCanvas.rect, Color.dirtColor);
        colony.updateColonyImage();
        
        //蟻
        for (i = 0; i < Param.antNum; i++) addAnt(colony.rooms[0].getSpacePoint(), Ant.JOB_WORKER);
        queen = addAnt(colony.rooms[0].getSpacePoint(), Ant.JOB_QUEEN);
        
        //蟻の空間探査処理用配列の初期化
        for (iy = -XY; iy <= XY; iy++)
        for (ix = -XY; ix <= XY; ix++)
        {
            var d:int = Math.max(Math.abs(ix), Math.abs(iy));
            if (!d) continue;
            if (!_xy[d]) _xy[d] = [];
            _xy[d].push([ix, iy]);
        }
    }
    
    /**
     * キャンバス座標とスケールでワールド描画
     * @param    tx
     * @param    ty
     * @param    scale
     */
    public function draw(tx:Number, ty:Number, scale:Number):void
    {
        _drawMatrix.identity();
        _drawMatrix.scale(scale, scale);
        _drawMatrix.translate(-tx * scale + Display.width / 2, -ty * scale + Display.height / 2);
        var g:Graphics = canvas.graphics;
        g.clear();
        g.beginBitmapFill(_bgCanvas, _drawMatrix, true, false);
        g.drawRect(0, 0, Display.width, Display.height);
        g.beginBitmapFill(colony.canvas, _drawMatrix, false, false);
        g.drawRect(0, 0, Display.width, Display.height);
        
        var gy:Number = _drawMatrix.ty;
        g.beginBitmapFill(ground.canvas, _drawMatrix, true, false);
        g.drawRect(0, gy, Display.width, ground.canvas.height * scale);
        g.beginFill(Color.sky);
        g.drawRect(0, gy + 2 * scale, Display.width, -1000);
        
        g.beginBitmapFill(_antsCanvas, _drawMatrix, false, false);
        g.drawRect(0, 0, Display.width, Display.height);
        g.endFill();
    }
    
    /**
     * シミュレーション
     */
    public function simulate():void
    {
        time++;
        wanderFreq = Math.min(time / 25000, Param.wanderFreq);
        var enum:int = 0;
        //蟻の処理
        for each (var a:Ant in ants)
        {
            a.simulate();
            if (a.mode != Ant.MODE_WANDER) enum++;
            if (a.digging) _updatePath = _updateImage = true;
        }
        exploringRate = enum / ants.length;
        foodRate = colony.getFoodNum() / 10 / (ants.length + colony.getItemNum(Primitive.EGG) + colony.getItemNum(Primitive.PUPAE));
        
        //通路検索
        if (time % 5 == 0 && _updatePath)
        {
            _updatePath = false;
            colony.nextPath();
        }
        
        //部屋の時間経過
        if (time % 50 == 0) colony.grow();
        
        //トンネル描画
        if (time % 30 == 0 && _updateImage)
        {
            _updateImage = false;
            colony.updateColonyImage();
        }
    }
    
    /**
     * キャンバス座標で描画更新
     */
    public function updateDraw(p:Point, scale:Number):void
    {
        var img:BitmapData;
        
        _antsCanvas.lock();
        
        //部屋内のアイテムを描画
        _antsCanvas.fillRect(_antsCanvas.rect, 0);
        for each(var room:Room in colony.rooms)
        for (var k:* in room.item)
        for each(var item:Primitive in room.item[k])
        {
            img = getItemImage(item);
            item.setSize(img.width, img.height);
            item.updatePosition(this);
            _antsCanvas.copyPixels(img, img.rect, item.plot, null, null, true);
        }
        
        //蟻の処理
        for each (var a:Ant in ants)
        {
            if (!a.visible) continue;
            //蟻描画
            img = getItemImage(a);
            _antsCanvas.copyPixels(img, img.rect, a.plot, null, null, true);
            //咥えている物描画
            if (a.baggage)
            {
                img = getItemImage(a.baggage);
                a.mouth.x -= img.width / 2;
                a.mouth.y -= img.height / 2;
                _antsCanvas.copyPixels(img, img.rect, a.mouth, null, null, true);
            }
        }
        
        //蟻の影
        _antsCanvas.applyFilter(_antsCanvas, _antsCanvas.rect, PointUtil.ZERO, _shadow);
        _antsCanvas.unlock();
        
        draw(p.x, p.y, scale);
        //draw(ants[0].plot.x, ants[0].plot.y, 1);
    }
    
    /**
     * 各種アイテムの画像取得
     * @param    item
     * @return
     */
    private function getItemImage(item:Primitive):BitmapData
    {
        var img:BitmapData;
        switch(item.type)
        {
            case Primitive.ANT:
                var a:Ant = Ant(item);
                var aimg:Vector.<BitmapData> = (a.job != Ant.JOB_QUEEN)? (trackingAnt === a)? Image.antsSelected : Image.ants : Image.queens;
                img = aimg[(a.rotation % PI2 + PI2) % PI2 / PI2 * Image.DIRECTIONS | 0];
                break;
            case Primitive.PUPAE: img = Image.pupae; break;
            case Primitive.DIRT: img = Image.dirts[Dirt(item).seed]; break;
            case Primitive.EGG: img = Image.eggs[Egg(item).rate * (Image.eggs.length - 1) | 0]; break;
            case Primitive.FOOD: img = Image.foods[Food(item).seed]; break;
            case Primitive.CLUMP: img = Image.clumps[Clump(item).seed]; break;
            case Primitive.GARBAGE: img = Image.garbages[Garbage(item).seed]; break;
        }
        return img;
    }
    
    /**
     * 卵追加
     * @param    p
     * @return
     */
    public function addEgg(p:Point):Egg
    {
        var egg:Egg = new Egg(p.x, p.y);
        egg.setSize(Image.eggs[0].width, Image.eggs[0].height);
        egg.onEclose = onEcloseEgg;
        colony.dropItem(egg, p.x, p.y);
        return egg;
    }
    
    /**
     * ゴミ追加
     * @param    p
     * @return
     */
    public function addGarbage(p:Point, type:int):Garbage
    {
        var g:Garbage = new Garbage(p.x, p.y, type);
        g.setSize(Image.garbages[type].width, Image.garbages[type].height);
        colony.dropItem(g, p.x, p.y);
        return g;
    }
    
    /**
     * 蛹追加
     * @param    p
     * @return
     */
    public function addPupae(p:Point):Pupae
    {
        var pp:Pupae = new Pupae(p.x, p.y);
        pp.setSize(Image.pupae.width, Image.pupae.height);
        pp.onEclose = onEclosePupae;
        colony.dropItem(pp, p.x, p.y);
        return pp;
    }
    
    /**
     * 卵成長MAX時
     * @param    e
     */
    private function onEcloseEgg(e:Egg):void
    {
        addPupae(e.point);
    }
    
    /**
     * 蛹羽化時
     * @param    e
     */
    private function onEclosePupae(e:Egg):void
    {
        var xy:Point = e.point.clone();
        for (var i:int = 0; i < 2; i++) 
        {
            addGarbage(new Point(e.point.x + Random.range(-1, 1), e.point.y + Random.range( -2, 2)), Garbage.FILAMENT);
        }
        addAnt(e.point, Ant.JOB_WORKER);
    }
    
    /**
     * アリ追加
     * @param    p
     * @param    job
     * @return
     */
    public function addAnt(p:Point, job:int):Ant
    {
        var a:Ant = new Ant(p.x, p.y, job);
        a.id = ants.length;
        a.world = this;
        var size:int = (job == Ant.JOB_QUEEN)? Image.QUEEN_SIZE : Image.WORKER_SIZE;
        a.setSize(size, size);
        a.currentRoom = colony.getRoomXY(p.x, p.y);
        a.rotation = Math.random() * PI2;
        a.speed = (job == Ant.JOB_QUEEN)? Param.queenSpeed : Random.range.apply(null, Param.antSpeed);
        a.onRemove = onRemoveAnt;
        a.onLayEgg = onLayEgg;
        a.onKill = onKill;
        a.think();
        a.updatePosition(this);
        ants.push(a);
        return a;
    }
    
    private function onLayEgg(a:Ant):void 
    {
        if (ants.length + colony.getItemNum(Primitive.EGG) + colony.getItemNum(Primitive.PUPAE) < Param.antMax)
        {
            addEgg(a.point);
        }
    }
    
    private function onKill(a:Ant):void
    {
        addGarbage(a.point, Garbage.DEADANT);
    }
    
    private function onRemoveAnt(a:Ant):void 
    {
        var i:int = ants.indexOf(a);
        if (i != -1) ants.splice(i, 1);
    }
    
    /**
     * 一番近い空間へ出るための角度を調べる
     * @param    p
     * @return
     */
    public function getRotation(p:Point):Number
    {
        var r:Number = 0, vx:Number = 0, vy:Number = 0;
        var d:int = 0;
        while (++d <= XY)
        {
            var loop:Boolean = true;
            for each(var xy:Array in _xy[d])
            {
                var argb:uint = colony.map.getPixel32(p.x + xy[0], p.y + xy[1]);
                if (argb >>> 8 & 0xFF)
                {
                    vx += xy[0];
                    vy += xy[1];
                    loop = false;
                }
            }
            if (!loop) break;
        }
        return Math.atan2(vy, vx);
    }
    
    /**
     * マウス座標をコロニー座標に変換
     * @param    mouseX
     * @param    mouseY
     * @return
     */
    public function toColonyXY(mouseX:Number, mouseY:Number):Point 
    {
        var s:Number = SCALE * _drawMatrix.a;
        return new Point((mouseX - _drawMatrix.tx) / s, (mouseY - _drawMatrix.ty) / s);
    }
    
    /**
     * コロニー座標をキャンバス座標に変換する
     * @param    point
     * @return
     */
    public function toCanvasXY(point:Point):Point
    {
        return new Point(point.x * SCALE, point.y * SCALE);
    }
    
    /**
     * 地上で餌を取得する
     * @return
     */
    public function getClump():Clump
    {
        var c:Clump = new Clump(Random.rangeInt.apply(null, Param.clumpNum));
        c.onRot = onRotFood;
        return c;
    }
    
    /**
     * コロニー座標で近いアリを取得
     * @param    p
     */
    public function getAntXY(p:Point):Ant 
    {
        var ds:Array = [];
        for each (var a:Ant in ants) 
        {
            var d:Number = Point.distance(a.point, p);
            if (d < 4) ds.push( { distance:d, ant:a } );
        }
        if (!ds.length) return null;
        return ds.sortOn("distance", Array.NUMERIC)[0].ant;
    }
    
    private function onRotFood(f:Food):void 
    {
        var g:Garbage = addGarbage(f.point, Garbage.FUNGUS);
        g.offset.x = f.offset.x;
        g.offset.y = f.offset.y;
    }
    
}

class Display
{
    static public var width:int = 465;
    static public var height:int = 465;
    static public var stage:Stage;
    
    static public function init(stage:Stage, w:int, h:int):void
    {
        Display.stage = stage;
        width = w;
        height = h;
    }
}

/**
 * 地上
 */
class Ground
{
    public var canvas:BitmapData;
    public var edges:Vector.<Target> = new Vector.<Target>();
    private var _scale:Number;
    private var _heights:Vector.<Number> = new Vector.<Number>();
    private var _angles:Vector.<Number> = new Vector.<Number>();
    private var _grass:uint = 0x5CA849;
        
    public function Ground()
    {
    }
    
    /**
     * サイズ指定で初期化
     * @param    w
     * @param    height
     * @param    seed    地上の起伏シード値
     */
    public function init(w:World, height:int, seed:int):void
    {
        _scale = w.SCALE;
        var bmd:BitmapData = new BitmapData(w.colony.width * w.SCALE, 1, false);
        bmd.perlinNoise(bmd.width / 2, 1, 4, seed, true, true, 7, true);
        var ty:Number = w.colony.gateway.point.y * w.SCALE;
        canvas = new BitmapData(w.colony.width * w.SCALE, height + ty + 1, true);
        bmd.draw(SpriteUtil.gradientBox(w.colony.gateway.point.x * w.SCALE - 75, 0, 150, 1, true, 0, [0x505050, 0x505050, 0x505050, 0x505050], [0, 1, 1, 0], [0, 0.44, 0.55, 1]));
        
        var min:uint = 80, max:uint = 175, h2:int = 0;
        for (var ix:int = 0; ix < canvas.width; ix++)
        {
            var h:int = ((bmd.getPixel(ix, 0) & 0xFF) - min) / (max - min) * height + ty;
            for (var iy:int = 0; iy < canvas.height; iy++)
            {
                var rgb:uint = iy > h - 5 ? _grass : Color.mix(Color.sky, Color.horizon, iy / canvas.height);
                canvas.setPixel32(ix, iy, (!iy || iy > h)? 0 : 0xFF << 24 | rgb);
            }
            _heights.push(h / _scale);
            _angles[ix] = ix? Math.atan2(h - h2, 1) : 0;
            h2 = h;
        }
        bmd.dispose();
        var hh:Number = getHeight(0);
        edges.push(new Target(new Point(0, hh), 5));
        edges.push(new Target(new Point(w.colony.width, hh), 5));
    }
    
    public function getAngle(x:Number):Number
    {
        var i:int = x * _scale | 0;
        i = (i % canvas.width + canvas.width) % canvas.width;
        return _angles[i];
    }
    
    public function getHeight(x:Number):Number
    {
        var i:int = x * _scale | 0;
        i = (i % canvas.width + canvas.width) % canvas.width;
        return _heights[i] - 1;
    }
    
}

class Color
{
    static public var sky:uint = 0xC4E1FF;
    static public var dirt:uint = 0xAE8E5A;
    static public var tunnel:uint = 0x876E46;
    static public var food1:uint = 0xDD8800;
    static public var food2:uint = 0xDDBB00;
    static public var dirtColor:ColorTransform = new ColorTransform((dirt >>> 16) / 0xFF, (dirt >>> 8 & 0xFF) / 0xFF, (dirt & 0xFF) / 0xFF);
    static public var tunnelColor:ColorTransform = new ColorTransform((tunnel >>> 16) / 0xFF, (tunnel >>> 8 & 0xFF) / 0xFF, (tunnel & 0xFF) / 0xFF);
    static public var filament:uint = 0xCED1D4;
    static public var fungus:uint = 0xCC66CC;
    static public var horizon:uint = 0xE7F3FF;
    
    static public function mix(rgb1:uint, rgb2:uint, per:Number):uint 
    {
        var r:uint = (rgb2 >> 16) * per + (rgb1 >> 16) * (1 - per);
        var g:uint = (rgb2 >> 8 & 0xFF) * per + (rgb1 >> 8 & 0xFF) * (1 - per);
        var b:uint = (rgb2 & 0xFF) * per + (rgb1 & 0xFF) * (1 - per);
        return r << 16 | g << 8 | b;
    }
}

class Image
{
    static public var icons:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var ants:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var antsSelected:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var queens:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var dirts:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var foods:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var clumps:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var eggs:Vector.<BitmapData> = new Vector.<BitmapData>();
    static public var garbages:Vector.<BitmapData> = new Vector.<BitmapData>(3);
    static public var pupae:BitmapData;
    static public const DIRECTIONS:int = 360;
    static public const WORKER_SIZE:int = 38;
    static public const QUEEN_SIZE:int = 57;
    public function Image()
    {
    }
    
    static public function load(complete:Function):void
    {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
            onLoad(e);
            complete();
        });
        loader.load(new URLRequest(Param.assetPath), new LoaderContext(true));
    }
    
    static private function onLoad(e:Event):void
    {
        var i:int, j:int, bmd:BitmapData;
        
        var img:BitmapData = Bitmap(LoaderInfo(e.currentTarget).content).bitmapData;
        var a:BitmapData = trim(img, new Rectangle(0, 0, 47, 31));
        for (i = 0; i < 19; i++) icons.push(trim(img, new Rectangle(47 + 13 * i, 0, 13, 18)));
        
        eggs = icons.splice(0, 7);
        pupae = icons.splice(0, 1)[0];
        for (i = 0; i < eggs.length; i++) eggs[i] = cutTransparent(eggs[i]);
        garbages[Garbage.FUNGUS] = cutTransparent(icons.shift());
        garbages[Garbage.FILAMENT] = cutTransparent(icons.shift());
        garbages[Garbage.DEADANT] = cutTransparent(icons.shift());
        
        for (i = 0; i < 10; i++) dirts.push(createDrop(7, 7, 0, Color.dirt, i + 1));
        for (i = 0; i < 10; i++) foods.push(createDrop(4, 4, 0, Color.mix(Color.food1, Color.food2, i/10), i + 10));
        for (i = 0; i < 10; i++) clumps.push(createDrop(i + 6, i + 6, 0, Color.mix(Color.food2, Color.food1, i/10), i + 1));
        
        Display.stage.quality = StageQuality.BEST;
        for (j = 0; j <= 1; j++)
        for (i = 0; i < DIRECTIONS; i++)
        {
            var size:int = j? QUEEN_SIZE : WORKER_SIZE;
            bmd = new BitmapData(size, size, true, 0);
            var mtx:Matrix = new Matrix();
            mtx.translate(-a.width / 2, -a.height / 2);
            mtx.rotate(Math.PI * 2 * i / DIRECTIONS);
            mtx.scale(size / 80, size / 80);
            mtx.translate(size / 2, size / 2);
            bmd.draw(a, mtx);
            if (!j)
            {
                ants.push(bmd);
                bmd = bmd.clone();
                bmd.colorTransform(bmd.rect, new ColorTransform(1, 1, 10, 1, 0, 0, 0));
                antsSelected.push(bmd);
            }
            else queens.push(bmd);
        }
        Display.stage.quality = StageQuality.LOW;
    }
    
    static public function createDrop(width:int, height:int, glow:int = 2, color:uint = 0xFFFFFF, seed:int = 1234):BitmapData
    {
        var img:BitmapData = new BitmapData(width, height, true, 0);
        img.perlinNoise(width / 2, height / 2, 3, seed, false, true, 7, true);
        img.draw(SpriteUtil.gradientBox(0, 0, img.width, img.height, false, 0, [0x0, 0x0], [0, 1], [0.5, 1]));
        img.threshold(img, img.rect, PointUtil.ZERO, "<", 0xFF606060, 0x00000000, 0xFFFFFFFF, true);
        img.colorTransform(img.rect, new ColorTransform(0, 0, 0, 1, color >> 16, color >> 8 & 0xFF, color & 0xFF));
        if(glow > 0) img.applyFilter(img, img.rect, PointUtil.ZERO, new GlowFilter(color, 1, glow, glow, 100, 2));
        var rect:Rectangle = img.getColorBoundsRect(0xFF000000, 0x00000000, false);
        img = cutTransparent(img);
        return img;
    }
    
    static public function trim(bmd:BitmapData, rect:Rectangle):BitmapData
    {
        var img:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
        img.copyPixels(bmd, rect, PointUtil.ZERO);
        return img;
    }
    
    static public function cutTransparent(bmd:BitmapData):BitmapData
    {
        return trim(bmd, bmd.getColorBoundsRect(0xFF000000, 0x00000000, false));
    }
    
}

/**
 * 移動先座標
 */
class Target
{
    public var type:int = Primitive.OTHER;
    public var point:Point;
    public var radian:Number;
    public var onDrop:Function = null;
    
    public function Target(p:Point = null, radian:Number = 1)
    {
        if (p) point = p.clone();
        this.radian = radian;
    }
    
    public function drop(obj:Primitive, p:Point):void
    {
        if (onDrop != null) onDrop(obj, p);
    }
    
}

/**
 * 移動先
 */
class Destination extends Target
{
    
    public var allMap:RectPathFinding = new RectPathFinding();
    public var foundMap:RectPathFinding = new RectPathFinding();
    
    public function Destination()
    {
        type = Primitive.OTHER;
    }
    
    public function updateFound(bmd:BitmapData, mask:uint = 0x0000FF00):void
    {
        foundMap.setEnabledByImage(bmd, mask);
        foundMap.search();
    }
    
    public function setGoal(bmd:BitmapData, mask:uint):void
    {
        allMap.createNodesByImage(bmd, mask);
        foundMap.createNodesByImage(bmd, mask);
        allMap.goals.push(allMap.getNodeXY(point.x, point.y));
        foundMap.goals.push(foundMap.getNodeXY(point.x, point.y));
        allMap.search();
    }
    
}

/**
 * 蟻塚
 */
class Gateway extends Destination
{
    public function Gateway()
    {
        type = Primitive.DIRT | Primitive.GARBAGE;
        radian = 3;
    }
    
}

/**
 * 各種オブジェクト
 */
class Primitive extends EventDispatcher
{
    static public const OTHER:int     = 0;
    static public const ALL:int     = parseInt("111111111", 2);
    static public const GARBAGE:int = parseInt("100000000", 2);
    static public const EGG:int     = parseInt("010000000", 2);
    static public const PUPAE:int     = parseInt("001000000", 2);
    static public const ANT:int     = parseInt("000100000", 2);
    static public const FOOD:int     = parseInt("000010000", 2);
    static public const CLUMP:int     = parseInt("000001000", 2);
    static public const DIRT:int     = parseInt("000000100", 2);
    static public const QUEEN:int     = parseInt("000000010", 2);
    static public const REST:int     = parseInt("000000001", 2);
    static public const ITEMS:Array = [EGG, FOOD, CLUMP, PUPAE, GARBAGE];
    
    public var type:int;
    public var plot:Point = new Point();
    public var point:Point = new Point();
    public var offset:Point = new Point();
    public var width:Number = 0;
    public var height:Number = 0;
    public var onRemove:Function = null;
    
    public function Primitive(type:int, x:Number = 0, y:Number = 0)
    {
        this.type = type;
        point.x = x;
        point.y = y;
    }
    
    protected function randomOffset():void 
    {
        offset.x = Random.rangeInt( -2, 2);
        offset.y = Random.rangeInt( -2, 2);
    }
    
    public function setSize(width:Number = 0, height:Number = 0):void
    {
        this.width = width;
        this.height = height;
    }
    
    public function remove():void
    {
        dispatchEvent(new Event(Event.REMOVED));
        if (onRemove != null) onRemove(this);
    }
    
    public function updatePosition(w:World):void
    {
        plot.x = point.x * w.SCALE - width / 2 + offset.x;
        plot.y = point.y * w.SCALE - height / 2 + offset.y;
    }
    
}

/**
 * ゴミ
 */
class Garbage extends Primitive
{
    public var seed:int = 0;
    public var time:int = 50;
    
    static public const FILAMENT:int = 0;
    static public const FUNGUS:int = 1;
    static public const DEADANT:int = 2;
    
    public function Garbage(x:Number = 0, y:Number = 0, type:int = 0)
    {
        super(GARBAGE, x, y);
        seed = type;
        randomOffset();
    }
    
    public function tick():void
    {
        if (--time <= 0)
        {
            remove();
        }
    }
    
}

/**
 * 卵
 */
class Egg extends Primitive
{
    public var age:int = 0;
    public var max:int = 25;//100
    public var rate:Number = 0;
    public var onEclose:Function = null;
    
    public function Egg(x:Number = 0, y:Number = 0)
    {
        super(EGG, x, y);
        randomOffset();
    }
    
    public function grow():void
    {
        age++;
        rate = age / max;
        if (rate > 1) rate = 1;
        if (rate == 1)
        {
            if (onEclose != null) onEclose(this);
            remove();
        }
    }
    
}

/**
 * 蛹
 */
class Pupae extends Egg
{
    public function Pupae(x:Number = 0, y:Number = 0)
    {
        super(x, y);
        type = PUPAE;
        max = 20;
    }
    
}

/**
 * 土
 */
class Dirt extends Primitive
{
    public var seed:int;
    public function Dirt(seed:int = 0)
    {
        super(DIRT);
        this.seed = seed;
    }
    
}

/**
 * 餌の粒
 */
class Food extends Primitive
{
    public var seed:int;
    public var life:int;
    public var mass:int;
    public var onRot:Function = null;
    public function Food(mass:int)
    {
        super(FOOD);
        life = Param.foodLife;
        this.mass = mass;
        this.seed = Math.random() * Image.foods.length;
        randomOffset();
    }
    
    public function cut(num:int):Food
    {
        if (num > mass) num = mass;
        mass -= num;
        if (mass <= 0) remove();
        var f:Food = new Food(num);
        f.onRot = onRot;
        return f;
    }
    
    public function tick():void 
    {
        if (--life <= 0)
        {
            remove();
            if (onRot != null) onRot(this);
        }
    }
    
}

/**
 * 餌の塊
 */
class Clump extends Food
{
    public function Clump(mass:int)
    {
        super(mass);
        type = CLUMP;
        life = Param.clumpLife;
    }
    
    override public function cut(num:int):Food 
    {
        var f:Food = super.cut(num);
        seed = Math.min(mass / 10 | 0, Image.clumps.length - 1);
        return f;
    }
}


class Status
{
    static public const RESTING:int = 0;
    static public const WANDERING:int = 1;
    static public const DIGGING:int = 2;
    static public const EXPLORING:int = 3;
    static public const CARRYING:int = 4;
    static public const MOVING:int = 5;
    static public const SEACHING:int = 6;
    static public const EATING:int = 7;
    static public const LABEL:Array = [];
    
    public function Status()
    {
    }
    
    static public function init():void
    {
        for each (var name:String in describeType(Status).constant.@name)
        {
            if (name != "LABEL") LABEL[Status[name]] = name;
        }
    }
    
}

/**
 * 蟻
 */
class Ant extends Primitive
{
    static public const MODE_WANDER:int = 0;
    static public const MODE_EXPLORE:int = 1;
    static public const MODE_BACK:int = 2;
    
    static public const JOB_QUEEN:int = 0;
    static public const JOB_WORKER:int = 1;
    static public const JOB_SOLDIER:int = 2;
    
    public var world:World;
    public var rotation:Number = 0;
    public var speed:Number = 0.2;
    public var id:int = 0;
    public var age:int = 0;
    public var status:int = Status.RESTING;
    public var hungry:int = 1000;
    public var life:int = 50000;
    public var job:int;
    public var mode:int = MODE_WANDER;
    public var mouth:Point = new Point();
    
    public var target:Target = null;
    public var currentRoom:Room = null;
    public var baggage:Primitive = null;
    
    public var xray:Boolean = false;
    public var digEnabled:Boolean = true;
    public var waitTime:int = 0;
    public var carryWait:int = 0;
    public var movableTime:int = 0;
    public var visible:Boolean = true;
    public var digging:Boolean = false;
    
    private var _offsetAngle:Number = 0;
    private var _offsetCnt:int = 0;
    private var _nextLay:int;
    
    public var onLayEgg:Function = null;
    public var onKill:Function = null;
    
    public function Ant(x:Number = 0, y:Number = 0, job:int = JOB_WORKER)
    {
        super(ANT, x, y);
        this.job = job;
        if (job == JOB_WORKER) life = Random.rangeInt.apply(null, Param.workerLife);
        if (job == JOB_QUEEN) life = Param.queenLife;
    }
    
    /**
     * メイン処理
     */
    public function simulate():void
    {
        ++age;
        digging = false;
        if (carryWait > 0) carryWait--;
        if (movableTime-- < 0)
        {
            movableTime = Random.rangeInt(30, 250);
            wait(0, 40);
        }
        if (job == JOB_QUEEN && age > _nextLay)
        {
            _nextLay = age + 250 / (world.colony.digNum / 4000 + 1);
            onLayEgg(this);
        }
        
        if (waitTime-- > 0)
        {
            updatePosition(world);
            return;
        }
        if (_offsetCnt-- < 0)
        {
            _offsetCnt = 30;
            _offsetAngle = Random.range( -0.25, 0.25);
        }
        
        visible = true;
        switch(mode)
        {
            case MODE_WANDER: wander(); break;
            case MODE_EXPLORE: case MODE_BACK: explore(); break;
        }
        updatePosition(world);
        
        if (!baggage && digEnabled && job != JOB_QUEEN) checkMap();
        if (age % 4 == 0) checkDestination();
        if (--hungry <= 0) life--;
        life--;
        if (life < 0) life = 0;
        if (hungry < 0) hungry = 0;
    }
    
    public function kill():void
    {
        remove();
        onKill(this);
    }
    
    /**
     * 室内アイテムをチェック
     */
    private function checkMap():void
    {
        var c:Colony = world.colony;
        var nx:int = point.x, ny:int = point.y;
        var lv:int = world.ants.length;        
        var argb:uint = c.map.getPixel32(nx, ny);
        var troom:Destination;
        if (!carryWait)
        {
            for each (var map:ItemMap in c.itemMap)
            {
                if (!map.bmd.getPixel(nx, ny)) continue;
                var item:Primitive = c.getItem(nx, ny, map.type);
                if (!item) continue;
                //塊があったら削る
                if (map.type == Primitive.CLUMP) {
                    if (hungry <= 0)
                    {
                        eat(item, 10);
                        break;
                    }
                    troom = c.getDestination(Primitive.FOOD, true, lv, currentRoom);
                    if (troom && carryTo(Clump(item).cut(10), troom)) break;
                }
                //餌があったら食べる
                if (map.type == Primitive.FOOD)
                {
                    if (hungry <= 0)
                    {
                        eat(item, 10);
                        break;
                    }
                    //卵部屋でないなら餌を移動する
                    if (currentRoom && !(currentRoom.type & Primitive.EGG))
                    {
                        if (carryTo(item, c.getDestination(Primitive.FOOD | Primitive.EGG, true, lv, currentRoom))) break;
                    }
                }
                //アイテムと部屋のタイプが一致していれば運ばない
                if (c.getRoomXY(nx, ny).type & map.type) continue;
                //運べる部屋が他にあれば運ぶ
                if (carryTo(item, c.getDestination(map.type, true, lv, currentRoom)))
                {
                    wait(30, 60);
                    break;
                }
            }
        }
        if (baggage) return;
        //土を削る
        if ((argb >>> 16 & 0xFF) == 0xFF && (argb >>> 8 & 0xFF) == 0)
        {
            digging = true;
            carryTo(c.dig(nx, ny), c.gateway);
            status = Status.DIGGING;
            wait(30, 60);
        }
    }
    
    /**
     * 何かを食べる
     * @param    item
     */
    public function eat(item:Primitive, num:int = 10):void 
    {
        wait(120, 200);
        hungry = Random.rangeInt.apply(null, Param.foodNutrients);
        status = Status.EATING;
        if (item as Food) Food(item).cut(num);
        else item.remove();
    }
    
    //探索行動
    private function explore():void
    {
        var angle:Number = world.ground.getAngle(point.x);
        if (point.x > target.point.x) angle += Math.PI; 
        easeRotation(angle, 0.25);
        point.x += Math.cos(rotation) * speed;
        point.y = world.ground.getHeight(point.x);
    }
    
    //コロニー内徘徊行動
    private function wander():void
    {
        var node:PathNode, r:Number, d:Number, a:Number, ease:Number = 0.16;
        if (!target) return;
        if (!(target is Destination))
        {
            r = Math.atan2(target.point.y - point.y, target.point.x - point.x);
            d = Point.distance(target.point, point);
            if (d < 5) ease = 1;
        }
        if (target is Destination)
        {
            var tgt:RectPathFinding = (xray)? Destination(target).allMap : Destination(target).foundMap;
            node = tgt.getNodeXY(point.x, point.y);
            a = (d < 5)? 0 : _offsetAngle;
            r = (node && node.enabled)? node.rotation + a : world.getRotation(point);
        }
        easeRotation(r, ease);
        point.x += Math.cos(rotation) * speed;
        point.y += Math.sin(rotation) * speed;
    }
    
    //回転処理
    private function easeRotation(r:Number,  ease:Number = 0.16):void
    {
        var r2:Number = ((rotation - r) % world.PI2 + world.PI2) % world.PI2;
        if (r2 > Math.PI) r2 -= world.PI2;
        rotation = r2 + r;
        rotation += (r - rotation) * ease;
    }
    
    /**
     * 一定時間停止
     * @param    min
     * @param    max
     */
    public function wait(min:int, max:int):void
    {
        waitTime = Math.random() * (max + 1) + min;
    }
    
    /**
     * 何かをどこかへ運ぶ
     * @param    p
     * @param    target
     * @return
     */
    public function carryTo(p:Primitive, target:Target):Boolean
    {
        if (!p || !target) return false;
        status = Status.CARRYING;
        mode = MODE_WANDER;
        baggage = p;
        goto(target);
        p.remove();
        return true;
    }
    
    //static private const TO_ROOM:int = 0;
    
    /**
     * 次の行動を決める
     */
    public function think():void
    {
        var c:Colony = world.colony;
        var lv:int = world.ants.length;
        if (life <= 0 && currentRoom)
        {
            kill();
            return;
        }
        //女王
        if (job == JOB_QUEEN)
        {
            wait(100, 1000);
            status = Status.WANDERING;
            goto(new Target(currentRoom.getSpacePoint(), 1), true);
            return;
        }
        //帰宅中-----------------------------------------------------
        if (mode == MODE_BACK)
        {
            status = Status.MOVING;
            goto(c.getDestination(baggage? baggage.type : Primitive.ALL, !!baggage, lv, currentRoom), !baggage);
            return;
        }
        //探索中-----------------------------------------------------
        if (mode == MODE_EXPLORE)
        {
            visible = false;
            rotation += Math.PI;
            if (world.foodRate < 1)
            {
                wait(500, 1500);    
                baggage = world.getClump();
            }
            else wait(100, 200);
            goto(c.anthill, false, true, MODE_BACK);
            return;
        }
        
        //コロニー内-----------------------------------------------------
        
        //暇ならどこかの部屋へ向かう
        if (!target)
        {
            status = Status.MOVING;
            goto(c.getDestination(Primitive.ALL, ! !baggage, lv, currentRoom), !baggage);
            return;
        }
        //巣穴に着いたら一定確率で外に出る
        if (target is Gateway)
        {
            wait(20, 50);
            if (world.exploringRate < Param.exploreFreq && Math.random() < 0.4)
            {
                status = Status.EXPLORING;
                goto(world.ground.edges[Math.random() * world.ground.edges.length | 0], false, false, MODE_EXPLORE);
                return;
            }
            status = Status.MOVING;
            goto(c.getDestination(Primitive.ALL, ! !baggage, lv), !baggage);
            return;
        }
        //部屋に着いた時
        var room:Room = currentRoom as Room;
        if (!room)
        {
            status = Status.MOVING;
            goto(c.getDestination(Primitive.ALL, ! !baggage, lv, currentRoom), true);
            return;
        }
        //土を掘りにいく
        if (room.dirts.length && !baggage && (room.spaces.length < 20 || Math.random() < 0.5))
        {
            carryWait = 100;
            goto(new Target(room.getDirtPoint(), 1), true);
            return;
        }
        //部屋の中を散策
        if (Math.random() < world.wanderFreq && room.spaces.length)
        {
            if (currentRoom.type & Primitive.REST) wait(300, 1800);
            else wait(30, 180);
            status = Status.WANDERING;
            goto(new Target(room.getSpacePoint(), 1), true);
            return;
        }
        var items:Vector.<Primitive> = room.getItems(Primitive.ALL);
        //食料、卵、ゴミを探す
        if (Math.random() < Math.min(items.length / (items.length + 10), 0.7))
        {
            status = Status.SEACHING;
            goto(new Target(items[Math.random() * items.length | 0].point, 1), true);
            return;
        }
        //一直線に巣穴に向かう
        if (world.exploringRate < 0.2 && Math.random() < 0.2)
        {
            status = Status.MOVING;
            goto(c.gateway, !!baggage, false);
            return;
        }
        //
        status = Status.MOVING;
        goto(c.getDestination(Primitive.ALL, !!baggage, lv, currentRoom), true);
    }
    
    /**
     * 目的地セット
     * @param    target
     * @param    xray
     * @param    dig
     * @param    mode
     */
    public function goto(target:Target, xray:Boolean = false, dig:Boolean = true, mode:int = MODE_WANDER):void
    {
        this.target = target;
        this.xray = xray;
        digEnabled = dig;
        this.mode = mode;
    }
    
    /**
     * 目的地についたかチェック
     */
    public function checkDestination():void
    {
        var arrive:Boolean = false;
        if (target && (!(target is Destination) || target is Gateway) && Point.distance(target.point, point) < target.radian)
        {
            if (target is Gateway) currentRoom = null;
            arrive = true;
        }
        var room:Room = target as Room;
        if (room && room.contains(point.x, point.y))
        {
            currentRoom = room;
            if (baggage && (room.type & baggage.type))
            {
                target = new Target(room.getSpacePoint(), 1);
                target.type = room.type;
                target.onDrop = room.onDrop;
            }
            else
            {
                arrive = true;
            }
        }
        if (arrive)
        {
            if (baggage && (baggage.type & target.type))
            {
                target.drop(baggage, point);
                carryWait = 100;
                baggage = null;
            }
            think();
        }
    }
    
    override public function updatePosition(w:World):void
    {
        super.updatePosition(w);
        mouth.x = plot.x + width / 2 + Math.cos(rotation) * width / 3.5;
        mouth.y = plot.y + height / 2 + Math.sin(rotation) * width / 3.5;
    }
    
}

class ItemMap
{
    public var bmd:BitmapData;
    public var type:int;
    
    public function ItemMap(width:int, height:int, type:int)
    {
        bmd = new BitmapData(width, height, false, 0);
        this.type = type;
    }
    
    public function addItem(x:int, y:int):Boolean
    {
        var rgb:uint = bmd.getPixel(x, y);
        if (rgb == 0xFFFFFF) return false;
        bmd.setPixel32(x, y, ++rgb);
        return true;
    }
    
    public function removeItem(x:int, y:int):Boolean
    {
        var rgb:uint = bmd.getPixel(x, y);
        if (!rgb) return false;
        bmd.setPixel32(x, y, --rgb);
        return true;
    }
    
}

/**
 * コロニー
 */
class Colony
{
    public var width:Number;
    public var height:Number;
    public var map:BitmapData;
    public var itemMap:Dictionary = new Dictionary();
    public var canvas:BitmapData;
    public var rooms:Vector.<Room> = new Vector.<Room>();
    public var gateway:Gateway = new Gateway();
    public var anthill:Target;
    public var digNum:int = 0;
    
    private var _lines:Vector.<Line>;
    private var _ends:Vector.<Point>;
    
    private var _filter1:GlowFilter = new GlowFilter(0xFFFFFF, 1, 15, 15, 3, 1, false);
    private var _filter2:GlowFilter = new GlowFilter(0x0, 0.4, 40, 40, 2, 1, true);
    private var _temp:BitmapData;
    private var _dirtImage:BitmapData;
    private var _scaleMatrix:Matrix = new Matrix();
    private var _aa:Array = [];
    private var _pathCnt:int = -1;
    private var _types:Array =    [Primitive.QUEEN | Primitive.FOOD | Primitive.CLUMP
                                ,Primitive.FOOD | Primitive.EGG
                                ,Primitive.PUPAE
                                ,Primitive.CLUMP
                                ,Primitive.FOOD | Primitive.EGG
                                ,Primitive.REST | Primitive.GARBAGE
                                ,Primitive.FOOD
                                ,Primitive.REST];
    
    public function Colony(width:Number, height:Number, scale:Number)
    {
        this.width = width;
        this.height = height;
        map = new BitmapData(width, height, true, 0);
        
        for each (var type:int in Primitive.ITEMS)
        {
            itemMap[type] = new ItemMap(width, height, type);
        }
        
        canvas = new BitmapData(width * scale, height * scale, true, 0);
        _scaleMatrix.scale(scale, scale);
        _temp = canvas.clone();
        _dirtImage = canvas.clone();
        _dirtImage.noise(1234, 0x80, 0xFF, 7, true);
        _dirtImage.colorTransform(_dirtImage.rect, Color.tunnelColor);
        for (var i:int = 0; i <= 0xFF; i++) _aa.push(i < 0x85? 0x00000000 : 0xFF000000);
        _filter1.blurX = _filter1.blurY = 2.4 * scale;
        _filter2.blurX = _filter2.blurY = 6.4 * scale;
    }
        
    public function updateColonyImage():void
    {
        canvas.lock();
        _temp.lock();
        _temp.fillRect(_temp.rect, 0);
        _temp.draw(map, _scaleMatrix, null, null, null, false);
        _temp.threshold(_temp, _temp.rect, PointUtil.ZERO, "!=", 0xFFFFFFFF, 0x0, 0x000FF00);
        _temp.applyFilter(_temp, _temp.rect, PointUtil.ZERO, _filter1);
        _temp.paletteMap(_temp, _temp.rect, PointUtil.ZERO, null, null, null, _aa);
        canvas.copyPixels(_dirtImage, _dirtImage.rect, PointUtil.ZERO);
        canvas.copyChannel(_temp, _temp.rect, PointUtil.ZERO, 8, 8);
        canvas.applyFilter(canvas, canvas.rect, PointUtil.ZERO, _filter2);
        _temp.unlock();
        canvas.unlock();
    }
    
    public function build(num:int = 8):void
    {
        gateway.point = new Point(width / 2 + Random.range( -width, width) / 6, 5);
        anthill = new Target(gateway.point, 3);
        map.fillRect(map.rect, 0);
        var map2:BitmapData = map.clone();
        rooms.length = 0;
        
        var found:Sprite = new Sprite();
        var sprite:Sprite = new Sprite();
        var padding:Number = 4;
        var topPadding:Number = 15;
        var paddingRect:Rectangle = new Rectangle(padding, topPadding, width - padding * 2, height - (padding + topPadding));
        var segments:int = 15;
        
        var ss:SpatialSearch = new SpatialSearch(map.width, map.height);
        ss.image.fillRect(ss.image.rect, 0xFFFFFFFF);
        ss.image.fillRect(paddingRect, 0);
        
        var line:Line;
        _lines = Vector.<Line>([new Line()]);
        _lines[0].origin = gateway.point.clone();
        _lines[0].end = gateway.point.add(new Point(0, topPadding));
        _lines[0].draw(sprite.graphics, 0xFFFF00, 3);
        map.draw(sprite);
        
        var room:Room;
        for (var i:int = 0; i < num; i++)
        {
            room = new Room(25, 7);
            room.onDrop = onDropRoom;
            room.lv = (i - 1) * 35;
            var margin:int = i? 10 : 50;
            var p:Point = ss.getRandom(room.rect.width + margin, room.rect.height + margin);
            if (!p) continue;
            rooms.push(room);
            room.setCenter(p);
            room.type = _types[i % _types.length];
            map.copyPixels(room.image, room.image.rect, room.rect.topLeft, null, null, true);
            ss.image.copyPixels(room.image, room.image.rect, room.rect.topLeft, null, null, true);
            
            var lines:Vector.<Line> = createLines(room.point, _lines[Math.random() * _lines.length | 0].end, segments, i? 30 : 20);
            var tunnel:Vector.<Line> = new Vector.<Line>();
            for each (line in lines)
            {
                tunnel.push(line);
                var cp:Point = line.cut(_lines);
                line.flat(paddingRect);
                if (cp) break;
            }
            _lines = _lines.concat(tunnel);
            sprite.graphics.clear();
            for each (line in tunnel)
            {
                line.draw(sprite.graphics, 0xFF0000, Random.range(2, 3));
            }
            map.draw(sprite);
            ss.image.draw(sprite);
            if (!i)
            {
                room.digAll()
                for each (line in _lines)
                {
                    line.draw(found.graphics, 0xFFFF00, 3);
                }
            }
        }
        _lines.length = 0;
        ss.dispose();
        
        map2.draw(found);
        smooth(map2, 2, 0xFFFF00);
        smooth(map, 2, 0xFF0000);
        map.copyPixels(map2, map2.rect, PointUtil.ZERO, null, null, true);
        
        var ct:ColorTransform = new ColorTransform();
        for each (room in rooms)
        {
            smooth(room.image);
            var tl:Point = room.rect.topLeft;
            ct.color = (room.type & Primitive.QUEEN)? 0xFFFFFF : 0xFF00FF;
            map.draw(room.image, new Matrix(1,0,0,1,tl.x, tl.y), ct);
        }
    }
    
    private function onDropRoom(obj:Primitive, p:Point):void
    {
        dropItem(obj, p.x, p.y);
    }
    
    public function initPath():void
    {
        gateway.setGoal(map, 0x00FF0000);
        for each (var room:Room in rooms) room.setGoal(map, 0x00FF0000);
        for (var i:int = 0; i < rooms.length + 1; i++) nextPath();
    }
    
    public function smooth(bmd:BitmapData, size:int = 2, color:uint = 0xFFFFFF):void
    {
        var img:BitmapData = new BitmapData(bmd.width + size * 2, bmd.height + size * 2, true, 0);
        img.copyPixels(bmd, bmd.rect, new Point(size, size));
        img.applyFilter(img, img.rect, PointUtil.ZERO, new GlowFilter(color, 1, size * 2, size * 2, 1000, 1));
        img.applyFilter(img, img.rect, PointUtil.ZERO, new GlowFilter(0x000000, 1, size * 2, size * 2, 1000, 1, true));
        img.threshold(img, img.rect, PointUtil.ZERO, "==", 0xFF000000, 0);
        bmd.copyPixels(img, img.rect, new Point( -size, -size));
    }
    
    public function createLines(origin:Point, end:Point, segments:int = 10, curve:Number = 30):Vector.<Line>
    {
        var lines:Vector.<Line> = new Vector.<Line>();
        var line:Line;
        var p:Point = new Point();
        var radian:Number = 0;
        for (var i:int = 0; i < segments; i++)
        {
            line = new Line();
            line.origin = p.clone();
            line.end = line.origin.add(new Point(Math.cos(radian), Math.sin(radian)));
            radian += Random.range( -1, 1) * Math.PI / 180 * curve;
            p = line.end;
            lines.push(line);
        }
        var mtx:Matrix = new Matrix();
        var scale:Number = !p.length? 0 : Point.distance(origin, end) / p.length;
        mtx.scale(scale, scale);
        mtx.rotate( -Math.atan2(p.y, p.x) + Math.atan2(end.y - origin.y, end.x - origin.x));
        mtx.translate(origin.x, origin.y);
        for each (line in lines)
        {
            line.origin = mtx.transformPoint(line.origin);
            line.end = mtx.transformPoint(line.end);
        }
        return lines;
    }
    
    public function nextPath():void
    {
        _pathCnt = ++_pathCnt % (rooms.length + 1);
        var d:Destination = (!_pathCnt)? gateway : rooms[_pathCnt - 1];
        d.updateFound(map, 0x0000FF00);
    }
    
    public function getRoomXY(x:int, y:int):Room
    {
        for each (var room:Room in rooms)
        {
            if (room.contains(x, y)) return room;
        }
        return null;
    }
    
    /**
     * 条件に一致する部屋、出口等を1つ選ぶ
     * @param    type
     * @param    checkOpen
     * @param    lv
     * @param    ignore
     * @return
     */
    public function getDestination(type:int, checkOpen:Boolean = true, lv:int = int.MAX_VALUE, ignore:Room = null):Destination
    {
        var rooms:Vector.<Room> = getRooms.apply(null, arguments);
        var list:Array = [];
        for each (var r:Room in rooms) list.push(r);
        if (type & gateway.type) list.push(gateway);
        return (!list.length)? null : list[list.length * Math.random() | 0];
    }
    
    public function getRooms(type:int, checkOpen:Boolean = true, lv:int = int.MAX_VALUE, ignore:Room = null):Vector.<Room>
    {
        var list:Vector.<Room> = new Vector.<Room>();
        for each (var room:Room in rooms)
        {
            if ((room.type & type)
                && ignore !== room
                && (!checkOpen || room.spaces.length)
                && (room.lv <= lv)
                ) list.push(room);
        }
        return list;
    }
    
    public function dropItem(p:Primitive, x:Number, y:Number):void
    {
        var room:Room = getRoomXY(x, y);
        if (!room) return;
        p.onRemove = onRemoveItem;
        if (room.addItem(p, x, y))
        {
            ItemMap(itemMap[p.type]).addItem(x, y);
        }
    }
    
    private function onRemoveItem(p:Primitive):void
    {
        ItemMap(itemMap[p.type]).removeItem(p.point.x, p.point.y);
        var room:Room = getRoomXY(p.point.x, p.point.y);
        room.removeItem(p);
    }
    
    public function getItem(x:int, y:int, type:int):Primitive
    {
        var room:Room = getRoomXY(x, y);
        return room? room.getItemXY(x, y, type) : null;
    }
    
    public function dig(x:int, y:int):Dirt
    {
        map.setPixel32(x, y, map.getPixel32(x, y) | 0xFF00);
        var room:Room = getRoomXY(x, y);
        if (room) room.removeDirt(x, y);
        digNum++;
        return new Dirt(Image.dirts.length * Math.random());
    }
    
    public function getItemNum(type:int):int 
    {
        var n:int = 0;
        for each(var r:Room in rooms) n += r.item[type].length;
        return n;
    }
    
    public function getFoodNum():int
    {
        var n:int = 0;
        for each(var r:Room in rooms)
        {
            for each(var f:Food in r.item[Primitive.FOOD]) n += f.mass;
            for each(var c:Clump in r.item[Primitive.CLUMP]) n += c.mass;
        }
        return n;
    }
    
    public function grow():void 
    {
        for each (var r:Room in rooms) r.tick();
    }
    
}

class Space
{
    public var point:Point;
    public var item:Dictionary = new Dictionary();
    public var center:Boolean = true;
    
    public function Space(x:int, y:int, center:Boolean)
    {
        point = new Point(x, y);
        this.center = center;
    }
    
}

class Room extends Destination
{
    public var rect:Rectangle;
    public var image:BitmapData;
    public var spaces:Vector.<Space> = new Vector.<Space>();
    public var dirts:Vector.<Space> = new Vector.<Space>();
    public var item:Dictionary = new Dictionary();
    public var dirtXY:Array = [];
    public var size:int;
    public var lv:int;
    private var _isFound:Boolean = false;
    
    public function Room(rh:Number, rv:Number)
    {
        type = Primitive.OTHER;
        image = Image.createDrop(rh * 2, rv * 2, 2, 0xFFFFFF, Random.rangeInt(1, 300));
        rect = image.rect.clone();
        for each (var id:String in Primitive.ITEMS) 
        {
            item[id] = new Vector.<Primitive>();
        }
    }
    
    public function setCenter(p:Point):void
    {
        point = p.clone();
        rect.x = int(point.x - rect.width / 2);
        rect.y = int(point.y - rect.height / 2);
        image.applyFilter(image, image.rect, PointUtil.ZERO, new GlowFilter(0x000000, 1, 3, 3, 10, 1, true));
        for (var ix:int = 0; ix < image.width; ix++)
        {
            if (!dirtXY[ix]) dirtXY[ix] = [];
            for (var iy:int = 0; iy < image.height; iy++)
            {
                var argb:uint = image.getPixel32(ix, iy);
                if (argb >>> 24 == 0xFF)
                {
                    var sp:Space = new Space(ix + rect.x, iy + rect.y, (argb >>> 16 & 0xFF) != 0x00);
                    dirts.push(sp);
                    dirtXY[ix][iy] = sp;
                }
            }
        }
        size = dirts.length;
        image.colorTransform(image.rect, new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF, 0));
    }
    
    public function getSpaceXY(x:int, y:int):Space
    {
        return (!dirtXY[x - rect.x])? null : dirtXY[x - rect.x][y - rect.y];
    }
    
    public function removeDirt(x:int, y:int):void
    {
        var sp:Space = getSpaceXY(x, y);
        if (!sp) return;
        if (!_isFound) initFoundPath(sp);
        dirts.splice(dirts.indexOf(sp), 1);
        if (sp.center) spaces.push(sp);
    }
    
    private function initFoundPath(sp:Space):void
    {
        _isFound = true;
        foundMap.goals[0] = foundMap.getNodeXY(sp.point.x, sp.point.y);
    }
    
    public function getSpacePoint():Point
    {
        return (!spaces.length)? null : spaces[Math.random() * spaces.length | 0].point;
    }
    
    public function getDirtPoint():Point
    {
        return (!dirts.length)? null : dirts[Math.random() * dirts.length | 0].point;
    }
    
    public function digAll():void
    {
        for each (var sp:Space in dirts) if (sp.center) spaces.push(sp);
        dirts.length = 0;
    }
    
    public function addItem(p:Primitive, x:Number, y:Number):Boolean
    {
        var sp:Space = getSpaceXY(x, y);
        if (!sp) return false;
        if(!sp.item[p.type]) sp.item[p.type] = new Vector.<Primitive>();
        sp.item[p.type].push(p);
        item[p.type].push(p);
        p.point.x = x;
        p.point.y = y;
        return true;
    }
    
    public function getItems(type:int):Vector.<Primitive>
    {
        if (type == Primitive.ALL)
        {
            var prs:Vector.<Primitive> = new Vector.<Primitive>();
            return prs.concat(item[Primitive.CLUMP], item[Primitive.EGG]);
        }
        return item[type];
    }
    
    public function getItemXY(x:int, y:int, type:int):Primitive
    {
        var sp:Space = getSpaceXY(x, y);
        if (!sp) return null;
        var items:Vector.<Primitive> = sp.item[type];
        if (!items || !items.length) return null;
        return items[items.length - 1];
    }
    
    public function removeItem(p:Primitive):void
    {
        item[p.type].splice(item[p.type].indexOf(p), 1);
        var sp:Space = getSpaceXY(p.point.x, p.point.y);
        if(sp) sp.item[p.type].splice(sp.item[p.type].indexOf(p), 1);
    }
    
    public function tick():void
    {
        for each (var p:Pupae in item[Primitive.PUPAE]) p.grow();
        for each (var egg:Egg in item[Primitive.EGG])
        {
            if (item[Primitive.FOOD].length) item[Primitive.FOOD][0].cut(1);
            else if (item[Primitive.CLUMP].length) item[Primitive.CLUMP][0].cut(1);
            else break;
            egg.grow();
        }
        for each (var g:Garbage in item[Primitive.GARBAGE]) g.tick();
        for each (var f:Food in item[Primitive.FOOD]) f.tick();
        for each (var c:Food in item[Primitive.CLUMP]) c.tick();
    }
    
    public function contains(x:Number, y:Number):Boolean 
    {
        return rect.contains(x, y) && getSpaceXY(x, y) != null;
    }
    
}

class Line
{
    public var origin:Point = new Point();
    public var end:Point = new Point();
    
    public function Line()
    {
    }
    
    public function draw(g:Graphics, color:uint = 0x0, thickness:Number = 0):void
    {
        g.lineStyle(thickness, color);
        g.moveTo(origin.x, origin.y);
        g.lineTo(end.x, end.y);
    }
    
    public function getCrossPoint(line:Line):Point
    {
        var ax1:Number = line.origin.x, ay1:Number = line.origin.y, ax2:Number = line.end.x, ay2:Number = line.end.y;
        var bx1:Number = origin.x, by1:Number = origin.y, bx2:Number = end.x, by2:Number = end.y;
        if (((ax1 - ax2) * (by1 - ay1) + (ay1 - ay2) * (ax1 - bx1)) * ((ax1 - ax2) * (by2 - ay1) + (ay1 - ay2) * (ax1 - bx2)) > 0) return null;
        if (((bx1 - bx2) * (ay1 - by1) + (by1 - by2) * (bx1 - ax1)) * ((bx1 - bx2) * (ay2 - by1) + (by1 - by2) * (bx1 - ax2)) > 0) return null;
        var v1x:Number = ax2 - ax1, v1y:Number = ay2 - ay1;
        var v2x:Number = bx1 - ax1, v2y:Number = by1 - ay1;
        var v3x:Number = bx2 - bx1, v3y:Number = by2 - by1;
        var cross:Number = v3x * v1y - v3y * v1x;
        if (!cross) return null;
        var scale:Number = (v3x * v2y - v3y * v2x) / cross;
        return new Point(v1x * scale + ax1, v1y * scale + ay1);    
    }
    
    public function cut(lines:Vector.<Line>):Point
    {
        var cp:Point = null;
        for each (var item:Line in lines)
        {
            var p:Point = getCrossPoint(item);
            if (p)
            {
                if (p.equals(origin)) continue;
                end = p;
                cp = p.clone();
            }
        }
        return cp;
    }
    
    public function flat(rect:Rectangle):void
    {
        flatPoint(origin, rect);
        flatPoint(end, rect);
    }
    
    private function flatPoint(point:Point, rect:Rectangle):void
    {
        if (rect.containsPoint(point)) return;
        if (point.x < rect.left) point.x = rect.left;
        if (point.x > rect.right) point.x = rect.right;
        if (point.y < rect.top) point.y = rect.top;
        if (point.y > rect.bottom) point.y = rect.bottom;
    }
    
}

class PointUtil
{
    static public const ZERO:Point = new Point();
}

class SpatialSearch
{
    private var _image:BitmapData;
    private var _tmp:BitmapData;
    
    public function SpatialSearch(width:int, height:int)
    {
        _image = new BitmapData(width, height, true, 0);
        _tmp = _image.clone();
    }
    
    public function get image():BitmapData { return _image; }
    
    public function getRandom(width:Number, height:Number, mask:uint = 0xFF000000):Point
    {
        _tmp.applyFilter(_image, _image.rect, PointUtil.ZERO, new GlowFilter(0xFFFFFF, 1, width, height, 1000, 1));
        var pixels:Vector.<uint> = _tmp.getVector(_tmp.rect);
        var spaces:Vector.<int> = new Vector.<int>();
        var l:int = pixels.length;
        for (var i:int = 0; i < l; i++)
        {
            if (!(pixels[i] & mask)) spaces.push(i);
        }
        if (!spaces.length) return null;
        var index:int = spaces[Math.random() * spaces.length | 0];
        return new Point(index % _tmp.width, index / _tmp.width | 0);
    }
    
    public function dispose():void
    {
        _image.dispose();
        _tmp.dispose();
    }
    
}

class RectPathFinding
{
    public var width:int;
    public var height:int;
    public var goals:Vector.<PathNode> = new Vector.<PathNode>();
    public var nodes:Vector.<PathNode>;
    
    public function RectPathFinding()
    {
    }
    
    public function setEnabledByImage(bmd:BitmapData, mask:uint = 0xFF000000):void
    {
        for each (var node:PathNode in nodes)
        {
            if (!node) continue;
            node.enabled = ((bmd.getPixel32(node.x, node.y) & mask) != 0);
        }
    }
    
    public function createNodesByImage(bmd:BitmapData, mask:uint = 0xFF000000):void
    {
        this.width = bmd.width;
        this.height = bmd.height;
        nodes = new Vector.<PathNode>(width * height);
        
        var ix:int, iy:int, nx:int, ny:int, node:PathNode;
        
        for (iy = 0; iy < height; iy++)
        for (ix = 0; ix < width; ix++)
        {
            if ((bmd.getPixel32(ix, iy) & mask) == 0) continue;
            node = new PathNode(ix, iy);
            nodes[ix + iy * width] = node;
        }
        
        for (iy = 0; iy < height; iy++)
        for (ix = 0; ix < width; ix++)
        {
            node = nodes[ix + iy * width];
            if (!node) continue;
            for (ny = -1; ny <= 1; ny++) 
            for (nx = -1; nx <= 1; nx++)
            {
                var px:int = ix + nx;
                var py:int = iy + ny;
                if (px < 0 || py < 0 || px >= width || py >= height || (!nx && !ny)) continue;
                var link:PathNode = nodes[px + py * width];
                if (!link) continue;
                node.addLink(Math.sqrt(nx * nx + ny * ny), link);
            }
        }
    }
    
    public function getNodeXY(x:int, y:int):PathNode
    {
        var index:int = x + y * width;
        if (index < 0 || index >= nodes.length) return null;
        return nodes[index];
    }
    
    public function search():void
    {
        var node:PathNode;
        for each (node in nodes)
        {
            if (!node) continue;
            node.cost = -1;
            node.next = null;
        }
        for each (node in goals)
        {
            node.cost = 0;
            scanNode(node);
        }
        for each (node in nodes)
        {
            if (!node || !node.next) continue;
            node.rotation = Math.atan2(node.next.y - node.y, node.next.x - node.x);
        }
    }
    
    public function scanNode(target:PathNode):void
    {
        var scanList:Vector.<PathNode> = Vector.<PathNode>([target]);
        var nextList:Vector.<PathNode> = Vector.<PathNode>([]);
        while (scanList.length)
        {
            for each (var node:PathNode in scanList)
            for each (var link:PathLink in node.links)
            {
                var cost:Number = node.cost + link.cost;
                if (!link.to.enabled || link.to.cost != -1 && link.to.cost <= cost) continue;
                link.to.next = node;
                link.to.cost = node.cost + link.cost;
                nextList.push(link.to);
            }
            scanList = nextList.concat();
            nextList.length = 0;
        }
    }
    
}

class PathLink
{
    public var cost:Number = 1;
    public var to:PathNode = null;
    
    public function PathLink(cost:Number, to:PathNode)
    {
        this.cost = cost;
        this.to = to;
    }
    
}

class PathNode
{
    public var x:int = 0;
    public var y:int = 0;
    public var rotation:Number = 0;
    public var enabled:Boolean = true;
    public var cost:Number = -1;
    public var links:Vector.<PathLink> = new Vector.<PathLink>();
    public var next:PathNode = null;
    
    public function PathNode(x:int = 0, y:int = 0)
    {
        this.x = x;
        this.y = y;
    }
    
    public function addLink(cost:Number, node:PathNode):PathLink
    {
        var link:PathLink = new PathLink(cost, node);
        links.push(link);
        return link;
    }
    
}

class DragManager extends EventDispatcher
{
    public var position:Point = new Point();
    public var dragSpeed:Point = new Point(1, 1);
    public var scaleSpeed:Number = 1.2;
    public var scale:Number = 1;
    public var clickRange:Number = 2;
    public var wheelEnabled:Boolean = true;
    
    private var _iobject:InteractiveObject;
    private var _stage:Stage;
    private var _isDragged:Boolean = false;
    private var _isMouseDown:Boolean = false;
    private var _savePosition:Point = new Point();
    private var _saveMousePos:Point;
    private var _scaleMin:Number = Number.MIN_VALUE;
    private var _scaleMax:Number = Number.MAX_VALUE;
    private var _dragTop:Number = Number.MIN_VALUE;
    private var _dragBottom:Number = Number.MAX_VALUE;
    private var _dragLeft:Number = Number.MIN_VALUE;
    private var _dragRight:Number = Number.MAX_VALUE;
    
    public function get isMouseDown():Boolean { return _isMouseDown; }
    public function get isDragged():Boolean { return _isDragged; }
    
    public function DragManager()
    {
    }
    
    public function init(target:InteractiveObject, x:Number = 0, y:Number = 0, scale:Number = 1):void
    {
        this.scale = scale;
        position.x = x;
        position.y = y;
        _iobject = target;
        _iobject.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
        _iobject.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
    }
    
    public function setDragArea(rect:Rectangle):void
    {
        _dragTop = rect.y;
        _dragLeft = rect.x;
        _dragBottom = rect.y + rect.height;
        _dragRight = rect.x + rect.width;
    }
    
    public function setScaleRange(min:Number, max:Number):void 
    {
        _scaleMin = min;
        _scaleMax = max;
    }
    
    private function onMsWheel(e:MouseEvent):void 
    {
        if (!wheelEnabled) return;
        var d:int = e.delta < 0? -1 : 1;
        scale *= Math.pow(scaleSpeed, d);
        if (scale < _scaleMin) scale = _scaleMin; 　
        if (scale > _scaleMax) scale = _scaleMax;　
        dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL));
    }
    
    private function onMsDown(e:Event = null):void
    {
        _isMouseDown = true;
        _isDragged = false;
        _stage = _iobject.stage;
        _stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
        _stage.addEventListener(Event.MOUSE_LEAVE, onMsUp);
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        _savePosition = position.clone();
        _saveMousePos = new Point(_iobject.mouseX, _iobject.mouseY);
        dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
    }
    
    private function onMsUp(e:Event = null):void
    {
        _isMouseDown = false;
        _stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
        _stage.removeEventListener(Event.MOUSE_LEAVE, onMsUp);
        _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
        checkDrag();
        dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
        if (!_isDragged) dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }
    
    private function onMsMove(e:Event = null):void
    {
        checkDrag();
    }
    
    private function checkDrag():void
    {
        var drag:Point = new Point(_iobject.mouseX, _iobject.mouseY).subtract(_saveMousePos);
        if (!_isDragged && drag.length > clickRange) _isDragged = true;
        if (_isDragged)
        {
            position.x = _savePosition.x + drag.x * dragSpeed.x / scale;
            position.y = _savePosition.y + drag.y * dragSpeed.y / scale;
            if (position.x < _dragLeft) position.x = _dragLeft; 
            if (position.x > _dragRight) position.x = _dragRight; 
            if (position.y < _dragTop) position.y = _dragTop; 
            if (position.y > _dragBottom) position.y = _dragBottom; 
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
        }
    }
    
    public function setPoint(p:Point):void
    {
        _savePosition.x = position.x = p.x;
        _savePosition.y = position.y = p.y;
    }
    
}

class SpriteUtil
{
    static public function box(x:Number, y:Number, width:Number, height:Number, rgb:uint = 0x000000, alpha:Number = 1, tx:Number = 0, ty:Number = 0):Sprite
    {
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(rgb, alpha);
        sp.graphics.drawRect(x, y, width, height);
        sp.graphics.endFill();
        sp.x = tx;
        sp.y = ty;
        return sp;
    }
    
    static public function gradientBox(x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):Sprite
    {
        var sp:Sprite = new Sprite();
        var i:int, mtx:Matrix = new Matrix(), len:int = rgbs.length;
        mtx.createGradientBox(width, height, rotation * Math.PI / 180, x, y);
        if (!ratios)
        {
            ratios = [];
            for (i = 0; i < len; i++) ratios[i] = i / (len - 1);
        }
        for (i = 0; i < len; i++) ratios[i] *= 0xFF;
        sp.graphics.beginGradientFill(isLinear? GradientType.LINEAR : GradientType.RADIAL, rgbs, alphas, ratios, mtx);
        sp.graphics.drawRect(x, y, width, height);
        sp.graphics.endFill();
        return sp;
    }
    
}

class Random
{
    static public function range(min:Number, max:Number):Number
    {
        return Math.random() * (max - min) + min;
    }
    
    static public function rangeInt(min:int, max:int):int
    {
        return int(Math.random() * (max + 1 - min)) + min;
    }
}