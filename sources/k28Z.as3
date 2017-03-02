package  {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;
    
    /**
     * ...
     * @author http://wonderfl.net/user/Vladik
     */
    public class Main2 extends Sprite 
    {

        public function Main2():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.align = "topLeft";
            stage.scaleMode = "noScale";
            stage.addEventListener(Event.RESIZE, onStageResize);
            stage.addEventListener(MouseEvent.RIGHT_CLICK, showInfo);
            
            //Theme.skin();
            
            build(); 
            onStageResize();
            
            preview.render( components.ui.points, components.fractal.value );
            
            var temp:int = setInterval( function() {
                
                clearInterval( temp );
                onStageResize();
                
            }, 100);
        }
        
        private function showInfo(e:MouseEvent):void 
        {
            // TODO: show info on right click
            
            //preview.visible = ! preview.visible;
        }
        
            
        
        private var sw:Number;
        private var sh:Number;
        
        private function onStageResize(e:Event = null):void 
        {
            sw = stage.stageWidth;
            sh = stage.stageHeight;
            
            layout();
        }
        
        public var preview:Preview;
        public var components:Components;
        
        private function build():void 
        {
            preview = new Preview();
            addChild( preview );
            
            components = new Components( onApply );
            addChild( components );
        }
        
        private function onApply( points:Vector.<Point> ):void 
        {
            //trace( points );
            
            preview.render( points, components.fractal.value );
        }
        
        private function layout():void
        {
            preview.x = 0;
            preview.y = 0;
            preview.width = sw;
            preview.height = sh * 0.65;
            preview.draw();
            
            components.x = 0;
            components.y = preview.height;
            components.width = sw;
            components.height = sh - preview.height;
            components.draw();
            
            graphics.clear();
            graphics.beginFill( Theme.SG_Background );
            graphics.drawRect( 0, 0, sw, sh);
            graphics.endFill();
        }
                
    }

}

import Main2;
import com.bit101.components.Component;
import com.bit101.components.HBox;
import com.bit101.components.NumericStepper;
import com.bit101.components.ProgressBar;
import com.bit101.components.PushButton;
import com.bit101.components.RadioButton;
import com.bit101.components.Style;
import com.bit101.components.VBox;

import com.bit101.components.Knob;
import com.bit101.components.Label;
import com.bit101.components.RotarySelector;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import com.greensock.TweenLite;

class Theme 
{
    
    
    /// UI
    static public const UI_backgroundColor:uint = 0x1ABC9C;
    static public const UI_AxisSize:Number = 0.05;
    static public const UI_AxisColor:uint = 0x1BC5A3;
    static public const UI_LineSize:uint = 6;
    static public const UI_LineColor:uint = 0xFFFFFF;
    static public const UI_LineAlpha:Number = 1;
    
    /// DragablePoint
    //static public const DP_Static:Object = 
    //{ 
        //border: 0xFFFFFF, 
        //bg: 0x417671, 
        //// Border size
        //bs: 2, 
        //radius: 4 
    //};
    
    static public const PW_DP_Normal:Object = 
    {
        border: 0xFFFFFF, 
        bg: 0x3498DB, 
        bs: 3, 
        radius: 6
    };
    static public const PW_DP_Down:Object = 
    {
        border: 0xFFFFFF, 
        bg: 0xFFFFFF, 
        bs: 12, 
        radius: 9, 
        lineAlpha: 0.2
    };
    
    static public const DP_Normal:Object = 
    { 
        border: 0xFFFFFF, 
        bg: 0x1ABC9C, 
        bs: 3, 
        radius: 6 
    };
    static public const DP_Static:Object = 
    { 
        border: 0xFFFFFF, 
        bg: 0xFFFFFF, 
        bs: 0, 
        radius: 6, 
        alpha: 0.5
    };
    static public const DP_Down:Object = 
    { 
        border: 0xFFFFFF, 
        bg: 0xFFFFFF, 
        bs: 12, 
        radius: 9, 
        lineAlpha: 0.2
    };
    
    /// Preview
    
    static public const PW_Background:uint = 0x3498DB;
    static public const PW_Border:uint = 0x354B62;
    
    static public const PW_LineSize:uint = 2;
    static public const PW_LineAlpha:Number = 1;
    static public const PW_LineColor:uint = 0xFFFFFF;
    
    /// Components
    static public const CP_Background:uint = 0x2C3E50;
    static public const CP_BackgroundLeft :uint = 0xE74C3C;
    static public const CP_Border:uint = 0x2C3E50;
    
    /// Stage
    static public const SG_Background:uint = 0x2C3E50;
    
    /// Minimal Components Skin
    
    static public function skin():void
    {
        Style.LABEL_TEXT = 0xFFFFFF;
        Style.DROPSHADOW = 0xFFFFFF;
        Style.embedFonts = false;
        Style.fontName = "_sans";
        Style.fontSize = 12;
        Style.INPUT_TEXT = 0xFFFFFF;
        Style.PANEL = 0xC0392B;
        Style.BACKGROUND = 0xC0392B;
        //Style.BUTTON_DOWN = 0xC0392B;
        Style.BUTTON_FACE = 0xC0392B;
        Style.PROGRESS_BAR = 0xFFFFFF;
        
        // Knob effected by
        //Style.BACKGROUND;
        //Style.BUTTON_FACE;
    }
}


class DragablePoint extends Sprite 
{
    private var isStatic:Boolean;
    private var onMove:Function;
    
    public function DragablePoint( onMove:Function = null , isStatic:Boolean = false ) 
    {
        this.onMove = onMove;
        this.isStatic = isStatic;
        useHandCursor = buttonMode = true;
        addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        draw( isStatic ? styleStatic : styleNormal );
        addEventListener(MouseEvent.MOUSE_DOWN, onMD);
        
    }
    
    public var styleDown:Object = Theme.DP_Normal;
    public var styleStatic:Object = Theme.DP_Normal;
    public var styleNormal:Object = Theme.DP_Normal;
    
    private function onMD(e:MouseEvent):void 
    {
        draw( styleDown );
        
        stage.addEventListener(MouseEvent.MOUSE_UP, onMU);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, update);
    }
    
    public var dragBounds:Rectangle = null;
    
    private function update(e:MouseEvent):void 
    {
        if( !isStatic ) this.x = parent.mouseX;
        this.y = parent.mouseY;
        
        if ( dragBounds )
        {
            if ( !isStatic) 
            {
                if ( this.x - radius < dragBounds.x )
                    this.x = dragBounds.x + radius;
                if ( this.x + radius > dragBounds.right )
                    this.x = dragBounds.right - radius;                
            }
            
            if ( this.y - radius < dragBounds.y )
                this.y = dragBounds.y + radius;
            
            if ( this.y + radius > dragBounds.bottom )
                this.y = dragBounds.bottom - radius;
        }
        
        if ( onMove != null ) 
        {
            if ( onMove.length == 1 ) onMove( this );
            else onMove();
        }
    }
    
    private function onMU(e:MouseEvent):void 
    {
        if ( !stage ) 
        {
            trace("Critical Error - how the hell the draggablePoint have lost a stage referance while the mouse was down a moment ago?" , new Error().getStackTrace() );
            return;
        }
        
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMU);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, update);
        
        draw( isStatic ?  styleStatic : styleNormal );
    }
    
    private var radius:Number = 0;
    
    public function draw( style:Object ):void
    {
        var lineAlpha:Number  = style.hasOwnProperty("lineAlpha") ? style.lineAlpha : 1;
        
        graphics.clear();
        graphics.lineStyle( style.bs, style.border, lineAlpha );
        graphics.beginFill( style.bg );
        graphics.drawCircle( 0, 0, style.radius );
        graphics.endFill();
        
        if ( style.hasOwnProperty("alpha") ) alpha = style.alpha;
        else alpha = 1;
        
        radius = style.radius + style.bs / 2;
    }
}


class Field extends Component 
{
    protected var g:Graphics;
    protected var backgroundShape:Shape;
    
    protected var container:Sprite;
    
    protected var border:int;
    protected var margin:int;
    protected var padding:int;
    
    public function Field() 
    {    
        //Style.setStyle( Style.DARK );
        
        backgroundShape = new Shape();
        addChildAt( backgroundShape, 0 );
        
        container = new Sprite();
        addChildAt( container, 1 );
        
        border = 4;
        margin = 5;
        padding = 5;
        
        g = this.graphics;
        
        super();
    }
    
    override public function addChild(child:DisplayObject):DisplayObject 
    {
        return container.addChild(child);
    }
    
    public function renderBackground( backgroundColor:uint, borderColor:uint ):void
    {
        backgroundShape.graphics.clear();
        backgroundShape.graphics.lineStyle
        ( 
            border, 
            borderColor,
            1,
            true,
            "normal",
            "none",
            "miter"
        );
        backgroundShape.graphics.beginFill( backgroundColor );
        backgroundShape.graphics.drawRect
        ( 
            border / 2 + margin, 
            border / 2 + margin, 
            _width - border - margin * 2, 
            _height - border - margin * 2 
        );
        backgroundShape.graphics.endFill();
    }

    public function autoClipMask(x:Number = NaN, y:Number = NaN, w:Number = NaN, h:Number = NaN):Shape
    {
        if ( isNaN( x ) ) x = 0;
        if ( isNaN( y ) ) y = 0;
        if ( isNaN( w ) ) w = innerWidth;
        if ( isNaN( h ) ) h = innerHeight;
        
        var s:Shape = new Shape();
        s.graphics.beginFill(0xFF00FF);
        s.graphics.drawRect(x, y, w, h);
        s.graphics.endFill();
        return s;
    }
    
    override public function draw():void 
    {
        super.draw();
        
        container.x = margin + padding + border;
        container.y = margin + padding + border;
    }
    
    
    protected function combine(...arguments):HBox
    {
        var box:HBox = new HBox();
        for each( var o:DisplayObject in arguments )
            box.addChild( o );
        return box;
    }
    
    public function get innerWidth():Number
    {
        return _width - container.x * 2;
    }
    
    public function get innerHeight():Number
    {
        return _height - container.y * 2;
    }
}

class Preview extends Field
{    
    override protected function init():void 
    {
        super.init();
        
        useHandCursor = buttonMode = true;
        
        addEventListener(MouseEvent.MOUSE_DOWN, down);
        addEventListener(MouseEvent.ROLL_OVER, over);
        addEventListener(MouseEvent.ROLL_OUT, out);
    }
    
    private var _down:Boolean = false;
    private var _out:Boolean = true;
    private function down(e:MouseEvent):void {
        _down = true;
        stage.addEventListener(MouseEvent.MOUSE_UP, up);
    }
    private function up(e:MouseEvent):void     {    
        _down = false;    if ( _out ) hide(); 
        stage.removeEventListener(MouseEvent.MOUSE_UP, up);
    }        
    private function over(e:MouseEvent):void {    _out = false;    show();    }
    private function out(e:MouseEvent):void  {    _out = true;    if ( !_down ) hide();    }
    private function show():void {TweenLite.to(ui, 0.4, { alpha:1 } );}
    private function hide():void {TweenLite.to(ui, 0.8, { alpha:0 } );}
    
    private var ui:Sprite;
    private var knob:Knob;
    private var rotary:RotarySelector;
    
    private var canvas:Shape;
    private var points:Vector.<Point>;
    private var fractal:int;
    
    /// TOP LEFT
    private var p1:DragablePoint;
    /// BOTTOM RIGHT
    private var p2:DragablePoint;
    
    private var length:Label;
    
    override protected function addChildren():void 
    {    
        super.addChildren();
        
        canvas = new Shape();
        addChild( canvas );
        
        ui = new Sprite();
        addChild( ui );
        
        Theme.skin();
        //Style.LABEL_TEXT = 0xABE6FC;
        Style.LABEL_TEXT = 0xFFFFFF;
        length = new Label( ui );
        
        //knob = new Knob( ui, 10, 10, "Knob");
        //rotary = new RotarySelector( ui, 0, 10, "RotarySelector", onRotary);
        
        //ui.blendMode = "add";
        
        //knob.blendMode = rotary.blendMode = "add";
        
        p1 = new DragablePoint( onMove );
        p1.styleNormal = Theme.PW_DP_Normal;
        p1.styleDown = Theme.PW_DP_Down;
        ui.addChild( p1 );
        
        p2 = new DragablePoint( onMove );
        p2.styleNormal = Theme.PW_DP_Normal;
        p2.styleDown = Theme.PW_DP_Down;
        ui.addChild( p2 );
        
        ui.alpha = 0;
    }
    
    private function onMove( p:DragablePoint ):void 
    {
        renderUpdate();
    }
    //
    //private function onRotary(e:Event):void 
    //{
        //skin();
    //}
    
    override public function draw():void 
    {
        super.draw();
        
        renderBackground( Theme.PW_Background, Theme.PW_Border);
        
        canvas.mask = autoClipMask(20,20,innerWidth-20,innerHeight-20);
        
        var bw:Number = _width / 3;
        var bh:Number = _height / 3 ;
        
        p1.x = p1.y = 30;
        p1.dragBounds = new Rectangle(30, 30, bw, bh);
        
        
        p2.x = _width - 60;
        p2.y = _height - 60;
        p2.dragBounds = new Rectangle(p2.x - bw, p2.y - bh, bw, bh);
        
        length.x = 5;
        length.y = innerHeight - 20;
        
        //knob.y = _height - 110;
        
        //rotary.x = _width - 110;
        //rotary.y = _height - 110;
        
        // skin();
        
        renderUpdate();
    }
    
    public function renderUpdate( newPoints:Vector.<Point> = null ):void
    {
        if ( newPoints ) points = newPoints;
        if( points ) render( points, Main2(root).components.fractal.value );
    }
    
    public function render(points:Vector.<Point>, fractal:int, target:Graphics = null , totalW:Number = NaN, totalH:Number = NaN):void 
    {
        this.points = points;
        
        var g:Graphics = target == null ? canvas.graphics : target;
        
        g.clear();
        g.lineStyle( Theme.PW_LineSize, Theme.PW_LineColor, Theme.PW_LineAlpha, false, "none", "round", "miter" );
        
        var left:Point =     new Point(    p1.x, (p2.y - p1.y)/2 + p1.y );
        var right:Point =     new Point(    p2.x, (p2.y - p1.y)/2 + p1.y );
        
        var pt1:Point = points[0];
        var pt2:Point = points[points.length - 1];
        
        w2hRatio = ( p2.y - p1.y ) / ( p2.x - p1.x );
        
        var pStart:Point = cubicCoord( left, right, pt1.x, pt1.y );
        var pEnd:Point = cubicCoord( left, right, pt2.x, pt2.y );
        
        g.moveTo(pStart.x, pStart.y);
        
        var l:Number = drawKoch( g, points, pStart, pEnd, fractal );
        
        length.text = "Length:" + l.toFixed(3) + " px";
    }
    
    /// How much height per 1 width ( value less then 1 )
    private var w2hRatio:Number = 0;
    
    private function drawKoch( g:Graphics, points:Vector.<Point>, from:Point, to:Point, fractal:int = 0):Number
    {
        var l:Number = 0;
        
        var p:Point, p2:Point;
        
        for ( var i:int = 0; i < points.length; i++ )
        {
            p = cubicCoord( from, to, points[i].x, points[i].y );
            
            if ( fractal > 0 && i < points.length - 1 ) 
            {
                p2 = cubicCoord( from, to, points[i + 1].x, points[i + 1].y );
                
                l += drawKoch( g, points, p, p2, fractal - 1 );
            }
            
            else {
                
                if ( i > 0 ) l += Point.distance( p , p2 );
                
                g.lineTo( p.x, p.y );
                
                p2 = p;
            }
        }
        
        return l;
    }
    
    // URL : http://wonderfl.net/c/ebj9
    private function cubicCoord( start:Point, end:Point, x:Number, y:Number ):Point
    {
        // x-dist & y-dist between two points a & b
        var line:Point = new Point( end.x - start.x, end.y - start.y );
        
        // Top left
        var tl:Point = start.clone();
        tl.x += w2hRatio*line.y/2;
        tl.y -= w2hRatio*line.x/2;
        
        // Bottom right
        var br:Point = tl.clone();
        br.x += line.x - w2hRatio*line.y;
        br.y += line.y + w2hRatio*line.x;
        
        // Bottom left
        var bl:Point = tl.clone();
        bl.x -= w2hRatio*line.y;
        bl.y += w2hRatio*line.x;
        
        // Top Right
        var tr:Point = tl.clone();
        tr.x += line.x;
        tr.y += line.y;
        
        var px:Point = interpolate( tl, tr, x );
        px.x -= tl.x;
        px.y -= tl.y;
        
        var py:Point = interpolate( tl, bl, y );
        py.x -= tl.x;
        py.y -= tl.y;
        
        var p:Point = tl.clone();
        p.x += px.x + py.x;
        p.y += px.y + py.y;
        
        return p;
    }
    
    
    
    public function interpolate(pt1:Point, pt2:Point, f:Number):Point
    {
         // Work's inverse to flash.geom.Point.interpolate()..
         //var x:Number = f * pt1.x + (1 - f) * pt2.x;
         
         var x:Number = (1 - f) * pt1.x + f * pt2.x;
         var y:Number = (1 - f) * pt1.y + f * pt2.y;
         return new Point(x, y);
    }
    
    
    /*
    private function skin():void
    {
        var i:int;
        
        Style.BACKGROUND = 0xB5BC25;
        Style.BUTTON_FACE = 0x2980B9;
        Style.LABEL_TEXT = 0xABE6FC;
        
        knob.draw();
        for ( i = 0; i < knob.numChildren; i++)
            if ( knob.getChildAt(i) is Component )
                Component(knob.getChildAt(i)).draw();
        rotary.draw();
        for ( i = 0; i < rotary.numChildren; i++)
            if ( rotary.getChildAt(i) is Component )
                Component(rotary.getChildAt(i)).draw();
        
        Theme.skin();
    }
    */
}


class Components extends Field 
{
    private var onApply:Function;
    public function Components( onApply:Function )
    {
        this.onApply = onApply;
    }
    
    /// 0 - 1
    public function set progresValue( val:Number ):void
    {
        //progress.value = val;
    }
    
    public var ui:UI;
    
    
    private var pointsCount:NumericStepper;
    internal var fractal:NumericStepper;
    
    private var progress:ProgressBar;
    private var apply:PushButton;
    private var fullscreen:PushButton;
    private var mode1:RadioButton;
    private var mode2:RadioButton;
    
    private var components:VBox;
    private var box:HBox;
    
    override protected function addChildren():void 
    {
        super.addChildren();
        
        Theme.skin();
        
        var label:Label;
        
        components = new VBox();
        components.spacing = 10;
        
        label = new Label(null, 0, 0, "Points");
        
        pointsCount = new NumericStepper(null, 0, 0, onChange);
        pointsCount.minimum = 3;
        pointsCount.maximum = 10;
        pointsCount.step = 1;
        pointsCount.value = 5;
        
        components.addChild( combine( label, pointsCount ) );
        
        label = new Label(null, 0, 0, "Fractal Depth");
        
        fractal = new NumericStepper();
        fractal.minimum = 1;
        fractal.maximum = 5;
        fractal.step = 1;
        fractal.value = 2;
        fractal.width = 47;
        
        components.addChild( combine( label, fractal ) );
        
        //label = new Label(null, 0, 0, "Render");
        //
        //progress = new ProgressBar();
        //progress.value = 0;
        //progress.width = 80;
        //progress.maximum = 1;
        //
        //components.addChild( combine( label, progress ) );
        //
        
        apply = new PushButton(components, 0, 0, "APPLY", onApplyPush);
        fullscreen = new PushButton(components, 0, 0, "FullScreen", toogleFullscreen);
        //temp
        apply.width = 5;fullscreen.width = 5;
        
        //components.addChild( combine( apply, fullscreen ) );
        
        ui = new UI();
        ui.addEventListener("update", onUIUpdate);
        
        box = combine( components, ui );
        box.spacing = 20;
        
        addChild( box );
        
        //bruteForceFilterAttack();
    }
    
    private function onUIUpdate(e:Event):void 
    {
        pointsCount.value = ui.pointsCount;
    }
    //
    //private function bruteForceFilterAttack():void 
    //{
        //pointsCount.addEventListener("draw", demolishFilter);
        //apply.addEventListener("draw", demolishFilter);
        //fullscreen.addEventListener("draw", demolishFilter);
    //}
    //
    //private function demolishFilter(e:Event):void
    //{
        //e.target.filters = null;
        //for ( var i:int = 0; i < e.target.numChildren; i++) 
        //e.target.getChildAt(i).filters = null;
    //}
    
    private function toogleFullscreen(e:*= null):void
    {
        if( stage.displayState != "fullScreen" ) stage.displayState = "fullScreen";
        else stage.displayState = "normal";
    }
    
    private function onApplyPush(e:*= null):void
    {
        onApply( ui.points );
    }
    
    private function onChange(e:*= null):void
    {
        fractal.value = 2;
        
        draw();
    }
    
    override public function draw():void 
    {    
        super.draw();
        
        renderBackground( Theme.CP_Background, Theme.CP_Border );
        
        ui.width = innerWidth - components.width - padding - box.spacing;
        ui.height = innerHeight;
        ui.x = components.width + padding + box.spacing;
        
        // Prevent fractal reset on fullscreen
        if( pointsCount.value != ui.pointsCount )
            ui.pointsCount = pointsCount.value;
        else ui.resize();
            
        ui.dragBounds = new Rectangle(0, 0, ui.width, ui.height);
        ui.draw();
        
        components.height = innerHeight;
        components.graphics.clear();
        components.graphics.beginFill( Theme.CP_BackgroundLeft );
        components.graphics.drawRect
        (
            -padding, 
            -padding, 
            components.width + padding * 2, 
            components.height + padding * 2
        );
        components.graphics.endFill();
        
        //pointsCount.height = 20;
        
        for ( var i:int = 0; i < pointsCount.numChildren; i++)
            pointsCount.getChildAt(i).height = 20;
            
        for ( i = 0; i < fractal.numChildren; i++)
            fractal.getChildAt(i).height = 20;
        
        pointsCount.width = 85;
        
        apply.width = components.width;
        fullscreen.width = components.width;
        //apply.width = 50;
        //fullscreen.width = 75;
        //
        
        //progress.height = 18;
        
        killFilters( components );
    }
    
    private function killFilters( c:Component ):void
    {
        c.filters = null;
        if ( c.numChildren > 0 )
            for ( var i:int = 0 ; i < c.numChildren; i++)
            {
                if ( c.getChildAt(i) is Component ) 
                    killFilters( Component( c.getChildAt(i) ) );
                    
                c.getChildAt(i).filters = null;
            }
    }
    
}

class UI extends Component
{    
    override protected function init():void 
    {
        super.init();
        
        doubleClickEnabled = true;
        addEventListener(MouseEvent.DOUBLE_CLICK, addNewPoint);
    }
    
    private function addNewPoint(e:MouseEvent):void 
    {
        var p:DragablePoint = newPoint();
        p.y  = mouseY;
        p.x = mouseX;
        p.scaleX = p.scaleY = 0;
        
        TweenLite.to( p, .8, { scaleX:1, scaleY:1 } );
        
        var left:DragablePoint = _first;// , right:DragablePoint = _last;
        forEach( function( point:DragablePoint ):void
        {
            if ( point.x > left.x && point.x < p.x ) left = point;
            //if ( point.x < right.x && point.x > p.x ) right = point;
        });
        
        pointsContainer.addChildAt( p, pointsContainer.getChildIndex( left ) + 1 );
        
        _pointsCount++;
        
        onMove( p );
        
        dispatchEvent(new Event("update"));
    }
    
    private function newPoint( isStatic:Boolean = false ):DragablePoint
    {
        var p:DragablePoint = new DragablePoint(onMove, isStatic);
        
        p.dragBounds = dragBounds;
        
        p.styleNormal = Theme.DP_Normal;
        p.styleStatic = Theme.DP_Static;
        p.styleDown = Theme.DP_Down;
        
        if( ! isStatic ) p.addEventListener(MouseEvent.RIGHT_CLICK, deletePoint);
        
        pointsContainer.addChild( p );
        
        return p;
    }
    
    private function deletePoint(e:MouseEvent):void 
    {
        //if ( !e.ctrlKey ) return;
        
        var p:DragablePoint = DragablePoint( e.target );
        
        TweenLite.killTweensOf( p );
        
        _pointsCount--;
        
        pointsContainer.removeChild( p );
        
        onMove( _first );
    }
    
    private var pointsContainer:Sprite;
    private var linePreview:Shape;
    
    override protected function addChildren():void 
    {
        super.addChildren();
        
        linePreview = new Shape();
        addChild( linePreview );
        
        pointsContainer = new Sprite();
        addChild( pointsContainer );
        
    }
    
    override public function draw():void 
    {
        super.draw();
        
        graphics.clear();
        graphics.beginFill(Theme.UI_backgroundColor);
        graphics.drawRect(0, -5, _width, _height + 10);
        graphics.endFill();
        
        
        graphics.lineStyle( _height * Theme.UI_AxisSize, Theme.UI_AxisColor, 1, true, "normal", "none");
        
        var step:uint = _height * Theme.UI_AxisSize * 4;
        
        for ( var i:int = 15; i < _height - 10; i += step )    drawHLine(i);
        
        graphics.lineStyle( 8  , Theme.UI_backgroundColor, 1, true, "normal", "none");
        
        graphics.beginFill( Theme.UI_AxisColor );
        graphics.drawCircle( _width/2, _height/2, _height/6);
        graphics.endFill();
        
        /*
        var r:Number = _height / 4;
        
        /// invisible ILLUMINATI 
        
        graphics.moveTo( _width / 2 - r, _height / 2 + r * 0.6 );
        graphics.lineTo( _width / 2 + r, _height / 2 + r * 0.6 );
        graphics.lineTo( _width / 2, _height / 2 - r );
        graphics.lineTo( _width / 2 - r, _height / 2 + r * 0.6  );
        graphics.endFill();
        
        var w:Number = r / 5;
        var h:Number = r / 13;
        
        graphics.beginFill( Theme.UI_backgroundColor );
        graphics.drawEllipse( _width / 2 - w/2, _height / 2 - h*3, w, h);
        graphics.endFill();
        */
    }
    
    /// draw horizontal line
    private function drawHLine( value:Number ):void
    {
        graphics.moveTo(5, value);
        graphics.lineTo(_width-5, value);
    }
    
    public var dragBounds:Rectangle = null;
    
    private var _pointsCount:uint = 0;
    public function get pointsCount():uint { return _pointsCount; }
    public function set pointsCount( value:uint ):void
    {
        _pointsCount = value;
        
        while ( pointsContainer.numChildren > 0 ) 
            pointsContainer.removeChildAt( 0 );
            
        var startX:Number = _width * 0.0;
        var length:Number = _width - startX * 2;
        
        var p:DragablePoint;
        var staticPoint:Boolean;
        
        for ( var i:int = 0; i < value; i++)
        {
            staticPoint = i == 0 || i == value - 1;
            
            p = newPoint( staticPoint );
            p.y  = _height / 2 + ( Math.random() - 0.5 ) * ( _height / 4 );
                
            if ( staticPoint )
            {
                if ( i == 0 ) _first = p;
                else _last = p;
                p.y  = _height / 2;
            }
            
            p.x = startX + length * ( i / (value-1) );
        }
        
        drawLine();
    }
    
    
    public function resize():void 
    {
        var list:Vector.<Point> = points;
        
        var startX:Number = _width * 0.0;
        var length:Number = _width - startX * 2;
        
        forEach( function( p:DragablePoint, i:int ):void
        {
            p.dragBounds = dragBounds;
            p.x = startX + length * list[i].x;
            p.y = _height  * list[i].y;    
        });
        
        drawLine();
    }
    
    
    
    public var onPointMove:Function = null;
    
    public function get points():Vector.<Point>
    {
        var v:Vector.<Point> = new Vector.<Point>();
        
        forEach( function( p:DragablePoint ):void
        {
            
            if (dragBounds) v.push( new Point
            (
                (p.x - dragBounds.x) / (dragBounds.width - dragBounds.x),
                (p.y - dragBounds.y) / (dragBounds.height - dragBounds.y)
            ));
            else v.push( new Point( p.x , p.y ) );
            
        } );
        
        return v;
    }
    
    private function onMove( p:DragablePoint ):void 
    {
        //if ( p == _first ) _last.y = _first.y;
        //else if ( p == _last ) _first.y = _last.y;
        
        drawLine();
        
        Main2(root).preview.renderUpdate( points );
        
        if ( onPointMove )    onPointMove( p );
    }
    
    private var _first:DragablePoint;
    private var _last:DragablePoint;
    
    private function drawLine():void 
    {
        var g:Graphics = linePreview.graphics;
        
        g.clear();
        
        g.lineStyle( 
            Theme.UI_LineSize, 
            Theme.UI_LineColor, 
            Theme.UI_LineAlpha 
        );
        
        forEach( function( p:DragablePoint, i:int ):void
        {
            if ( i == 0 ) g.moveTo( p.x, p.y );
            else g.lineTo( p.x, p.y );
        } );
    }
    
    /// function( element ), function( element, index )
    public function forEach( callBack:Function ):void
    {
        for ( var i:int = 0; i < pointsContainer.numChildren; i++)
            if ( callBack.length == 1 )
                callBack( DragablePoint( pointsContainer.getChildAt(i) ) );
            else if( callBack.length == 2 )
                callBack( DragablePoint( pointsContainer.getChildAt(i) ) , i );
    }
    
}