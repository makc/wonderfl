package
{
    import com.bit101.components.CheckBox;
    import com.bit101.components.Label;
    import com.bit101.components.TextArea;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    

    /*
     * 
    Target:
    Generate tilings with two types of rhombs:
    angles 36, 144 degrees and 72, 108 degrees.
    
    Step one:
     - learn how to draw each rhomb by 3 points

    Step two:
     - Edit placement rules in a script

    Step three:
     - Highlight anchor layer/figure/point when typing (TODO)
    */
    /*
    10 t=36 side=19 cx=232 cy=270
T 0 1 18
T 0 2 126
t 0 3 144
T 0 3 -18, T 0 2 18, t 0 3 36
    */
    [SWF(width="465", height="465", backgroundColor="0xCCCCCC")]
    public class PenroseP3Tiling extends Sprite
    {
        protected var rhombs:Vector.<Rhomb>;
        protected var container:Sprite;
        
        protected var textArea:TextArea;
        protected var message:Label;
        protected var textAreaControl:CheckBox;
        
        public function PenroseP3Tiling()
        {
            //init
            rhombs = new Vector.<Rhomb>();
            container = new Sprite();
            addChild(container);
            Rhomb.rhombs = rhombs;
            
            //gui
            var script:String =
                "//header format - repeat count, shape type (t or T), turning angle, side length, center point:\n" +
                "5 T=72 side=18 cx=232 cy=270\n" +
                "//regular row: t or T, anchor figure from previous level,\n" +
                "//then anchor point on that figure (0 - 3), then angle:\n" +
                "t 0 2 126\n" +
                "T 0 0 -72, T 0 0 72, T 0 2 72\n" +
                "T 0 2 -36, t 0 2 54, t 0 2 -126, t 0 2 18, t 0 2 -90\n" +
                "T 0 2 72, T 0 2 -144, T 4 3 -108, T 3 1 36\n" +
                "T 0 0 0, T 0 0 -72, t 0 2 -54, t 1 2 -18\n" +
                "T 2 1 108, T 3 3 -180, t 1 2 54\n" +
                "t 0 2 -18, t 0 2 18, T 0 0 36, T 1 0 -108, T 2 3 36, T 2 3 -108, T 2 3 -36\n" +
                "T 2 0 -36, T 3 0 -36, t 0 2 -90, t 1 2 90, t 6 2 90, t 6 2 -162, T 0 1 0\n" +
                "T 0 2 0, t 0 2 54, t 0 2 -54, T 1 2 -72, t 1 2 -18, t 1 2 -126, T 4 3 -72, T 5 1 0, T 6 2 108, T 6 2 -108, T 6 2 36, T 6 2 -36\n" +
                "T 3 2 36, T 3 2 -36, T 3 2 -108, T 3 2 -180, T 0 2 108, T 0 2 -108, T 0 2 36, T 0 2 -36\n";
            /*
            //header format - repeat count, shape type (t or T), turning angle, side
            10 t=36 side=18 cx=232 cy=270
            T 0 1 18
            T 0 2 -90
            t 0 1 108, t 0 1 0
            T 0 0 54, T 0 2 -18, T 1 2 126, T 1 2 -126
            T 3 2 -18, t 2 0 72, t 2 0 -72
            T 1 3 -90,
            */
            textArea = new TextArea(container, 0, 0, script);
            textArea.width = 455;
            textArea.height = 120;
            textArea.addEventListener(Event.CHANGE, onScriptChanged);
            message = new Label(container, 0, 445);
            textAreaControl = new CheckBox(container, 455, 0, "x", onTextAreaToggle);
            textAreaControl.selected = true;
            
            onScriptChanged(null);
        }

        protected function onScriptChanged(event:Event):void
        {
            var result:String = parseString(textArea.text);
            message.text = result;
            updateTiling();
        }
        
        protected function onTextAreaToggle(event:Event):void
        {
            textArea.visible = textAreaControl.selected;
        }

        protected function parseString(script:String):String
        {
            //state machine stuff
            rhombs.length = 0;
            var angles:Vector.<Number> = new Vector.<Number>();
            var lastLevel:Vector.<Rhomb> = new Vector.<Rhomb>();
            var angle:Number;
            var rhombType:String;
            var rhombAngle:Number;
            var rhomb:Rhomb;
            var lastLevelLength:int = 1;
            var cx:Number = 465 * 0.5;
            var cy:Number = 465 * 0.5;
            var match:Object;
            var newLevelLength:int;
            var round:int, rounds:int;
            
            //parsing stuff
            var lines:Array = script.split(/\n|\r/);
            var stateHeader:Boolean = true;
            var headerRegex:RegExp = /(\d{1,2})\s?(t|T)=(\d{1,3})\s+side=(\d{1,3})\s+cx=(\d{1,4})\s+cy=(\d{1,4})/g;
            var normalRegex:RegExp = /(t|T)\s?(\d{1,3})\s([0-3])\s([-+]?\d{1,3})\,?\s?/g;
            var lineNo:int = 0;
            
            for each (var rawLine:String in lines)
            {
                lineNo++;
                if (!rawLine || !rawLine.length) continue;
                var comment:int = rawLine.indexOf("//");
                if (!comment) continue;
                var line:String = comment > 0 ? rawLine.substring(0, comment) : rawLine;
                trace(line);
                angle = 0;
                if (stateHeader)
                {
                    headerRegex.lastIndex = 0;
                    match = headerRegex.exec(line);
                    if (!match) return "Header invalid: line " + lineNo + ", pos " + headerRegex.lastIndex + ", line: \"" + line + "\"";
                    rounds = (int)(match[1]);
                    rhombType = match[2];
                    rhombAngle = (Number)(match[3]);
                    var side:Number = (Number)(match[4]);
                    if (side > 0)
                    {
                        var tcr:ThickRhomb = new ThickRhomb();
                        tcr.Side = side;
                        tcr.init();
                        var tnr:ThinRhomb = new ThinRhomb();
                        tnr.Side = side;
                        tnr.init();
                    }
                    cx = (int)(match[5]);
                    cy = (int)(match[6]);
                    for (round = 0; round < rounds; round++)
                    {
                        rhomb = (rhombType == "t") ? new ThinRhomb() : new ThickRhomb();
                        rhomb.byAxis(cx, cy, angle);
                        angles.push(rhombAngle);
                        angle += rhombAngle;
                        lastLevel.push(rhomb);
                    }
                    stateHeader = false;
                } else
                {
                    if (!angles) return "No header found: line " + lineNo;
                    var thisLevel:Vector.<Rhomb> = new Vector.<Rhomb>();
                    for (round = 0; round < rounds; round++)
                    {
                        normalRegex.lastIndex = 0;
                        newLevelLength = 0;
                        do
                        {
                            match = normalRegex.exec(line);
                            if (!match) return "Line invalid: line " + lineNo + ", pos " + normalRegex.lastIndex;
                            rhombType = match[1];
                            var anchorIndex:int = (int)(match[2]);
                            var anchorPoint:int = (int)(match[3]);
                            rhombAngle = (Number)(match[4]);
                            rhomb = (rhombType == "t") ? new ThinRhomb() : new ThickRhomb();
                            var lastFigureIndex:int = round * lastLevelLength + anchorIndex;
                            if (lastFigureIndex >= lastLevel.length)
                                return "Anchor figure index out of range: " + lastFigureIndex;
                            var anchorFigure:Rhomb = lastLevel[lastFigureIndex];
                            var anchorX:Number = anchorFigure.x(anchorPoint);
                            var anchorY:Number = anchorFigure.y(anchorPoint);
                            rhomb.byAxis(anchorX, anchorY, angle + rhombAngle);
                            thisLevel.push(rhomb);
                            newLevelLength++;
                        } while (normalRegex.lastIndex < line.length);
                        angle += angles[round];
                    }
                    lastLevelLength = newLevelLength;
                    lastLevel = thisLevel;
                }
            }
            
            return null;
        }

        protected function updateTiling():void
        {
            var g:Graphics = container.graphics;
            g.clear();
            g.lineStyle(1, 0xFFFFFF);
            g.drawRect(1, 1, 463, 463);
            g.lineStyle(1);
            for each (var rhomb:Rhomb in rhombs)
            {
                g.beginFill(rhomb.color, 0.5);
                g.moveTo(rhomb.p1x, rhomb.p1y);
                g.lineTo(rhomb.p2x, rhomb.p2y);
                g.lineTo(rhomb.p3x, rhomb.p3y);
                g.lineTo(rhomb.p4x, rhomb.p4y);
                g.endFill();
            }
        }
    }
}

class Rhomb
{
    public function get AcuteAngle():Number { return 0; }
    public function get ObtuseAngle():Number { return 0; }
    public function get Color():uint { return 0; }
    public function get BigDiag():Number { return 0; }
    public function get SmallDiag():Number { return 0; }

    protected static var side:Number = 10;

    public var p1x:Number, p1y:Number;
    public var p2x:Number, p2y:Number;
    public var p3x:Number, p3y:Number;
    public var p4x:Number, p4y:Number;

    public static var rhombs:Vector.<Rhomb>;

    public function get Side():Number
    {
        return side;
    }

    public function set Side(value:Number):void
    {
        side = value;
        init();
    }

    public function Rhomb():void
    {
        if (rhombs) rhombs.push(this);
    }
    
    public function get color():uint
    {
        return Color;
    }

    public function x(index:int):Number
    {
        switch (index)
        {
            case 0: return p1x;
            case 1: return p2x;
            case 2: return p3x;
            case 3: return p4x;
        }
        return NaN;
    }

    public function y(index:int):Number
    {
        switch (index)
        {
            case 0: return p1y;
            case 1: return p2y;
            case 2: return p3y;
            case 3: return p4y;
        }
        return NaN;
    }

    /*         p1
               ^
           . Obtuse .
       .               .
 p0 <  Acute)         (A > p2
       .               .
           .   O   .
               v
              p3
    */
    
    public function byAxis(i1x:Number, i1y:Number, angle:Number):void
    {
        var aRad:Number = angle * Math.PI / 180;
        p1x = i1x;
        p1y = i1y;
        p2x = p1x + Side * Math.sin(aRad + AcuteAngle * 0.5);
        p2y = p1y + Side * Math.cos(aRad + AcuteAngle * 0.5);
        p4x = p1x + Side * Math.sin(aRad - AcuteAngle * 0.5);
        p4y = p1y + Side * Math.cos(aRad - AcuteAngle * 0.5);
        p3x = p1x + BigDiag * Math.sin(aRad);
        p3y = p1y + BigDiag * Math.cos(aRad);
    }

    public function init():void {}
}

class ThinRhomb extends Rhomb
{
    protected static var bigDiag:Number, smallDiag:Number;

    override public function get AcuteAngle():Number
    {
        return 36 * Math.PI / 180;
    }
    
    override public function get ObtuseAngle():Number
    {
        return 144 * Math.PI / 180;
    }

    override public function get Color():uint
    {
        return 0xB00000;
    }

    override public function get BigDiag():Number
    {
        return bigDiag;
    }
    
    override public function get SmallDiag():Number
    {
        return smallDiag;
    }

    override public function init():void
    {
        bigDiag = side * 2 * Math.cos(AcuteAngle * 0.5);
        smallDiag = side * 2 * Math.sin(AcuteAngle * 0.5);
    }
}

class ThickRhomb extends Rhomb
{
    protected static var bigDiag:Number, smallDiag:Number;

    override public function get AcuteAngle():Number
    {
        return 72 * Math.PI / 180;
    }

    override public function get ObtuseAngle():Number
    {
        return 108 * Math.PI / 180;
    }

    override public function get Color():uint
    {
        return 0x00B000;
    }

    override public function get BigDiag():Number
    {
        return bigDiag;
    }

    override public function get SmallDiag():Number
    {
        return smallDiag;
    }
    
    override public function init():void
    {
        bigDiag = side * 2 * Math.cos(AcuteAngle * 0.5);
        smallDiag = side * 2 * Math.sin(AcuteAngle * 0.5);
    }
}