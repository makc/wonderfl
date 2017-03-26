package {
    
    import caurina.transitions.Equations;
    import caurina.transitions.Tweener;
    import caurina.transitions.properties.CurveModifiers;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.utils.setTimeout;
    
    [SWF(width=465, height=465, backgroundColor=0xffffff, frameRate=60)]
    
    public class Sewing extends Sprite {

        private var _loader:URLLoader;
        private var _canvas:Sprite;
        private var _paths:Array;
    
        public function Sewing() {
            Wonderfl.capture_delay(8);
            
            this.stage.quality = StageQuality.BEST;
            this.stage.align = StageAlign.TOP_LEFT;
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            
            CurveModifiers.init();
            
            this._canvas = this.addChild(new Sprite()) as Sprite;
            
            this._loader = new URLLoader();
            this._loader.dataFormat = URLLoaderDataFormat.TEXT;
            this._loader.addEventListener(Event.COMPLETE, this._handleLoaded);
            this._loader.load(new URLRequest('http://saqoo.sh/a/labs/wonderfl/saqoosha.svg'));
        }
        
        private function _handleLoaded(e:Event):void {
            var svg:XML = new XML(this._loader.data);
            this._paths = [];
            var path:SVGPath;
            var delay:Number = 2.0;
            var cx:Number = parseInt(svg.@width) / 2;
            var cy:Number = parseInt(svg.@height) / 2;
            this._canvas.x = this.stage.stageWidth / 2 - cx;
            this._canvas.y = this.stage.stageHeight / 2 - cy;
            for each (var pathNode:XML in svg..*::path) {
                path = new SVGPath(pathNode);
                this._paths.push(path);
                var i:Number = 0;
                var di:Number = Math.PI * 2 / path.points.length;
                var px:Number = cx;
                var py:Number = this.stage.stageHeight - this._canvas.y;
                for each (var pt:Point in path.points) {
                    Tweener.addTween(pt, {
                        x: pt.x,
                        y: pt.y,
                        _bezier:[
                            { x:cx + Math.sin(delay * 1.3) * 300 + Math.sin(delay * 10.3) * 80, y:50 },
                            { x:100 - Math.sin(delay * 7.2) * 80, y:50 }
                        ],
                        time: 1.0,
                        delay: delay,
                        transition: Equations.easeNone
                    });
                    pt.x = px;
                    pt.y = py;
                    delay += 0.004;
                    i += di;
                }
            }
            this.addEventListener(Event.ENTER_FRAME, this._drawPaths);
            setTimeout(function ():void {
                removeEventListener(Event.ENTER_FRAME, _drawPaths);
            }, (delay + 1) * 1000);
        }
        
        private function _drawPaths(e:Event):void {
            this._canvas.graphics.clear();
            for each (var path:SVGPath in this._paths) {
                path.draw(this._canvas.graphics);
            }
        }
    }
}















import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;


/**
* @class PathToArray
* @author Helen Triolo (with contributions from many people)
* @version 1.01 
* @description  Takes as input an SVG Path node (eg, from Illustrator 10, SVG Factory, etc, but must
*            not contain any CRLF characters), and an empty array. 
*            Parses the path node to make an array of drawing commands, which include cubic bezier 
*            draw commands.  Converts the cubic beziers to an array of equivalent quad beziers, 
*            using Robert Penner's code to convert with accuracy within 1 pixel.  
*            Drawing commands are produced in the format originally devised by Peter Hall
*           in his ASVDrawing class.  These are the possible elements in array dCmds (and the 
*            corresponding Flash drawing API commands to apply them):
*                ['M',[x,y]]                    moveTo(x,y)
*                ['L',[x,y]]                    lineTo(x,y)
*                ['C',[cx,cy,ax,ay]]            moveTo(cx,cy,ax,ay)
*                ['S',[width,color,alpha]]    lineStyle(widtb,color,alpha)
*                ['F',[color,alpha]]            beginFill(color,alpha)
*                ['EF']                        endFill()
* History:
*    v1.00        2005/11/13    Original release
*    v1.01        2006/05/06    Stroke corrected to stroke, line 250 (thanks Gábor Szabó)
*
* @param svgnode (XMLNode) Path node from SVG file
* @param dCmds (Array) Empty array to write commands to
*/

class SVGPath {

    private var _commands:Array;
    public function get commands():Array { return this._commands }
    
    private var _points:Array;
    public function get points():Array { return this._points }
    private function addPoint(... points:Array):void {
        for each (var pt:Point in points) {
            this._addPoint(pt);
        }
    }
    private function _addPoint(pt:Point):void {
        if (pt.x < this._bounds.left) {
            this._bounds.left = pt.x;
        } else if (this._bounds.right < pt.x) {
            this._bounds.right = pt.x;
        }
        if (pt.y < this._bounds.top) {
            this._bounds.top = pt.y;
        } else if (this._bounds.bottom < pt.y) {
            this._bounds.bottom = pt.y;
        }
        this._points.push(pt);
    }
    
    private var _bounds:Rectangle;
    public function get boundsRect():Rectangle { return this._bounds }

    private var _hasFill:Boolean;
    public function get hasFill():Boolean { return this._hasFill }
    
    private var _hasStroke:Boolean;
    public function get hasStroke():Boolean { return this._hasStroke }
    
    public function swapFillAndStroke():void {
        var flg:Boolean = this._hasFill;
        this._hasFill = this._hasStroke;
        this._hasStroke = flg;
        
        var val:Number = this._fillColor;
        this._fillColor = this._strokeColor;
        this._strokeColor = val;
        
        val = this._fillAlpha;
        this._fillAlpha = this._strokeAlpha;
        this._strokeAlpha = val;
    }

    private var _fillColor:Number;
    public function get fillColor():Number { return this._fillColor }
    public function set fillColor(col:Number):void { this._fillColor = col }
    
    private var _fillAlpha:Number;
    public function get fillAlpha():Number { return this._fillAlpha }
    public function set fillAlpha(al:Number):void { this._fillAlpha = al }
    
    private var _strokeColor:Number;
    public function get strokeColor():Number { return this._strokeColor }
    public function set strokeColor(col:Number):void { this._strokeColor = col }
    
    private var _strokeAlpha:Number;
    public function get strokeAlpha():Number { return this._strokeAlpha }
    public function set strokeAlpha(al:Number):void { this._strokeAlpha = al }
    
    private var _strokeWidth:Number;
    public function get strokeWidth():Number { return this._strokeWidth }
    public function set strokeWidth(wd:Number):void { this._strokeWidth = wd }

    /**
     * 
     */
    public function SVGPath(svgNode:XML) {
        this._commands = [];
        this._points = [];
        this._bounds = new Rectangle();
        this._bounds.top = this._bounds.left = Number.MAX_VALUE;
        this._bounds.bottom = this._bounds.right = Number.MIN_VALUE;
        this._hasFill = false;
        this._hasStroke = false;
        
        this.makeDrawCmds(this.extractCmds(svgNode));
    }

    /**
    * @method extractCmds ()
    * @param node (XMLNode) SVG path node
    * @description Parse path node and convert to array of SVG drawing commands and data
    *            eg, M,250.8,33.8,c,-33.6,-9.7,-42,19.1,-48.2,22.6,s,-27.9,2.2,-33.3,5.8,
    *                c,-5.3,3.5,-17.3,23.5,-8.4,41.6
    * @returns (Array) array of drawing commands
    */    
    private function extractCmds(node:XML):Array {
        var i:Number;
        var startColor:Number;
        var thisColor:Number;

        //var hasFill:Boolean = false;
        var hasTransform:Boolean = false;
        //var hasStroke:Boolean = false;
        var hasStrokeWidth:Boolean = false;
        var hasRotate:Number = 0;
        var dstring:String = "";
        var rotation:Number;

        // is there a fill attribute, a transform attribute, a stroke attribute?
        for each (var a:XML in node.attributes()) {
            switch (a.name().toString()) {
                case 'fill': this._hasFill = true; break;
                case 'transform': hasTransform = true; break;
                case 'stroke': this._hasStroke = true; break;
                case 'stroke-width': hasStrokeWidth = true; break;
            }
        }
        if (this._hasFill) {
            // parse for fill color specification
            // if a hex number is specified, startColor will be > 0
            // if a color name is specified, startColor will be 0
            var fillStr:String = node.@fill;
            if (fillStr == 'none') {
                this._hasFill = false;
            } else {
                startColor = fillStr.indexOf("#") + 1;
                if (startColor == 0) {   // name specified instead of color number
                    thisColor = SVGColor.getByName(fillStr);
                    if (isNaN(thisColor)) {
                        this._hasFill = false;
                    } else {
                        this._fillColor = thisColor;
                        this._fillAlpha = 1.0;
                    }
                } else {
                    this._fillColor = parseInt(fillStr.substr(startColor, 6), 16);
                    this._fillAlpha = 1.0;
                }
            }
        }
        
        // stroke: color, width, alpha
        if (this._hasStroke) {
            // parse for stroke color specification
            var strokeStr:String = node.@stroke;
            if (strokeStr == 'none') {
                this._hasStroke = false;
            } else {
                startColor = strokeStr.indexOf("#")+1;        
                if (startColor == 0) {   // name specified instead of color number
                    thisColor = SVGColor.getByName(strokeStr);
                    if (isNaN(thisColor)) {
                        this._hasStroke = false;
                    } else {
                        this._strokeWidth = 0;
                        this._strokeColor = SVGColor.getByName(strokeStr);
                        this._strokeAlpha = 1.0;
                    }
                } else {
                    this._strokeWidth = 0;
                    this._strokeColor = parseInt(strokeStr.substr(startColor,6),16);
                    this._strokeAlpha = 1.0;
                }
            }
        }
        
        if (hasStrokeWidth) this._strokeWidth = Number(node.attribute("stroke-width"));
    
        // if stroke and fill are both undefined, set fill to black 
        if (!this._hasFill && !this._hasStroke) {
            this._hasFill = true;
            this._fillColor = 0;
            this._fillAlpha = 1.0;
        }
        
        if (hasTransform) {
            // parse for rotation specification
            var transformStr:String = node.@transform;
            hasRotate = transformStr.indexOf("rotate");
            if (hasRotate > -1) {
                var startRotate:Number = transformStr.indexOf("(");
                var endRotate:Number = transformStr.indexOf(")");
                rotation = parseInt(transformStr.substr(startRotate+1, endRotate-startRotate));
            } else {
                rotation = 0;
            }
    
        } else rotation = 0;
        
        // if commas included, is it Adobe Illustrator (no spaces) or SVG Factory/other?
        dstring = node.@d;
        if (dstring.indexOf(",") > -1) {  // has commas?
            if (dstring.indexOf(" ") > -1) {  // yes, has spaces?
                // change spaces to commas, then deal as for Illustrator
                dstring = String2.replace(dstring," ",",");
            }
        } else {  // no commas
            // get rid of extra spaces and change rest to commas
            dstring = String2.shrinkSequencesOf(dstring, " ");
            dstring = String2.replace(dstring, " ",",");
        }        
        dstring = String2.replace(dstring, "c",",c,");
        dstring = String2.replace(dstring, "C",",C,");
        dstring = String2.replace(dstring, "S",",S,");
        dstring = String2.replace(dstring, "s",",s,");
        // separate the z from the last element
        dstring = String2.replace(dstring, "z",",z");
        // change the following if M can be mid-path
        dstring = String2.replace(dstring, "M","M,");
        dstring = String2.replace(dstring, "L",",L,");
        dstring = String2.replace(dstring, "l",",l,");
        dstring = String2.replace(dstring, "H",",H,");
        dstring = String2.replace(dstring, "h",",h,");
        dstring = String2.replace(dstring, "V",",V,");
        dstring = String2.replace(dstring, "v",",v,");
        dstring = String2.replace(dstring, "Q",",Q,");
        dstring = String2.replace(dstring, "q",",q,");
        dstring = String2.replace(dstring, "T",",T,");
        dstring = String2.replace(dstring, "t",",t,");
        // Adobe includes no delimiter before negative numbers
        dstring = String2.replace(dstring, "-",",-");
        // get rid of any dup commas we might have introduced
        dstring = String2.replace(dstring, ",,",",");
        // get rid of spaces
        // (cr/lf's have to be removed before the xml object can be created,
        //  so that is done in xml.onData method)
        dstring = String2.replace(dstring, " ","");
        dstring = String2.replace(dstring, "\t","");

        return dstring.split(",");    
    }

    /**
    * @method makeDrawCmds
    * @param svgCmds (Array) array of svg draw commands (as output from extractCmds)
    * @description Convert svg draw commands to array of ASVDrawing commands: _commands
    */    
    private function makeDrawCmds(svgCmds:Array):void {
        var j:Number = 0, ii:int;
        var qc:Array;
        var firstP:Point;
        var lastP:Point;
        var lastC:Point;
        var cmd:String;
        var cp:Point, pp:Point;
        
        do {
            cmd = svgCmds[j++];
            switch (cmd) {
            case "M" :
                // moveTo point
                firstP = lastP = new Point(Number(svgCmds[j]), Number(svgCmds[j+1]));
                if (this._hasFill) {
                    _commands.push(new BeginFillCommand(this._fillColor, this._fillAlpha));
                }
                if (this._hasStroke) {
                    _commands.push(new LineStyleCommand(this._strokeWidth, this._strokeColor, this._strokeAlpha));
                }
                _commands.push(new MoveToCommand(firstP));
                this.addPoint(firstP);
                j += 2;
                if (j < svgCmds.length && !isNaN(Number(svgCmds[j]))) {  
                    do {
                        // if multiple points listed, add the rest as lineTo points
                        lastP = new Point(Number(svgCmds[j]), Number(svgCmds[j+1]));
                        _commands.push(new LineToCommand(lastP));
                        this.addPoint(lastP);
                        firstP = lastP;
                        j += 2;
                    } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                }
                break;
                
            case "l" :
                do {
                    lastP = new Point(lastP.x+Number(svgCmds[j]), lastP.y+Number(svgCmds[j+1]));
                    _commands.push(new LineToCommand(lastP));
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 2;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "L" :
                do {
                    lastP = new Point(Number(svgCmds[j]), Number(svgCmds[j+1]));
                    _commands.push(new LineToCommand(lastP));                
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 2;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "h" :
                do {
                    lastP = new Point(lastP.x+Number(svgCmds[j]), lastP.y);
                    _commands.push(new LineToCommand(lastP));
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 1;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "H" :
                do {
                    lastP = new Point(Number(svgCmds[j]), lastP.y);
                    _commands.push(new LineToCommand(lastP));
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 1;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "v" :
                do {
                    lastP = new Point(lastP.x, lastP.y+Number(svgCmds[j]));
                    _commands.push(new LineToCommand(lastP));
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 1;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "V" :
                do {
                    lastP = new Point(lastP.x, Number(svgCmds[j]));
                    _commands.push(new LineToCommand(lastP));
                    this.addPoint(lastP);
                    firstP = lastP;
                    j += 1;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
    
            case "q" :
                do {
                    // control is relative to lastP, not lastC
                    lastC = new Point(lastP.x+Number(svgCmds[j]), lastP.y+Number(svgCmds[j+1]));
                    lastP = new Point(lastP.x+Number(svgCmds[j+2]), lastP.y+Number(svgCmds[j+3]));
                    _commands.push(new CurveToCommand(lastC, lastP));
                    this.addPoint(lastC, lastP);
                    firstP = lastP;
                    j += 4;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "Q" :
                do {
                    lastC = new Point(Number(svgCmds[j]), Number(svgCmds[j+1]));
                    lastP = new Point(Number(svgCmds[j+2]), Number(svgCmds[j+3]));
                    _commands.push(new CurveToCommand(lastC, lastP));
                    this.addPoint(lastC, lastP);
                    firstP = lastP;
                    j += 4;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "c" :
                do {
                // don't save if c1.x=c1.y=c2.x=c2.y=0 
                    if (!Number(svgCmds[j]) && !Number(svgCmds[j+1]) && !Number(svgCmds[j+2]) && !Number(svgCmds[j+3])) {
                    } else {
                        qc = [];
                        Math2.getQuadBez_RP(
                            {x:lastP.x, y:lastP.y},   
                            {x:lastP.x+Number(svgCmds[j]), y:lastP.y+Number(svgCmds[j+1])},
                            {x:lastP.x+Number(svgCmds[j+2]), y:lastP.y+Number(svgCmds[j+3])},
                            {x:lastP.x+Number(svgCmds[j+4]), y:lastP.y+Number(svgCmds[j+5])},
                            1, qc);
                        for (ii=0; ii<qc.length; ii++) {
                            cp = new Point(qc[ii].cx, qc[ii].cy);
                            pp = new Point(qc[ii].p2x, qc[ii].p2y);
                            _commands.push(new CurveToCommand(cp, pp));
                            this.addPoint(cp, pp);
                        }
                        lastC = new Point(lastP.x+Number(svgCmds[j+2]), lastP.y+Number(svgCmds[j+3]));
                        lastP = new Point(lastP.x+Number(svgCmds[j+4]), lastP.y+Number(svgCmds[j+5]));
                        this.addPoint(lastC, lastP);
                        firstP = lastP;
                    }
                    j += 6;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
    
            case "C" :
                do {
                // don't save if c1.x=c1.y=c2.x=c2.y=0 
                    if (!Number(svgCmds[j]) && !Number(svgCmds[j+1]) && !Number(svgCmds[j+2]) && !Number(svgCmds[j+3])) {
                    } else {
                        qc = [];
                        Math2.getQuadBez_RP(
                            {x:firstP.x, y:firstP.y},   
                            {x:Number(svgCmds[j]), y:Number(svgCmds[j+1])},
                            {x:Number(svgCmds[j+2]), y:Number(svgCmds[j+3])},
                            {x:Number(svgCmds[j+4]), y:Number(svgCmds[j+5])},
                            1, qc);
                        for (ii=0; ii<qc.length; ii++) {
                            cp = new Point(qc[ii].cx, qc[ii].cy);
                            pp = new Point(qc[ii].p2x, qc[ii].p2y);
                            _commands.push(new CurveToCommand(cp, pp));
                            this.addPoint(cp, pp);
                        }
                        lastC = new Point(lastP.x+Number(svgCmds[j+2]), lastP.y+Number(svgCmds[j+3]));
                        lastP = new Point(Number(svgCmds[j+4]), Number(svgCmds[j+5]));
                        this.addPoint(lastC, lastP);
                        firstP = lastP;
                    }
                    j += 6;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "s" :
                do {
                // don't save if c1.x=c1.y=c2.x=c2.y=0 
                    if (!Number(svgCmds[j]) && !Number(svgCmds[j+1]) && !Number(svgCmds[j+2]) && !Number(svgCmds[j+3])) {
                    } else {
                        qc = [];
                        Math2.getQuadBez_RP(
                            {x:firstP.x, y:firstP.y},   
                            {x:lastP.x + (lastP.x - lastC.x), y:lastP.y + (lastP.y - lastC.y)},
                            {x:lastP.x+Number(svgCmds[j]), y:lastP.y+Number(svgCmds[j+1])},
                            {x:lastP.x+Number(svgCmds[j+2]), y:lastP.y+Number(svgCmds[j+3])},
                            1, qc);
                        for (ii=0; ii<qc.length; ii++) {
                            cp = new Point(qc[ii].cx, qc[ii].cy);
                            pp = new Point(qc[ii].p2x, qc[ii].p2y);
                            _commands.push(new CurveToCommand(cp, pp));
                            this.addPoint(cp, pp);
                        }
                        lastC = new Point(lastP.x+Number(svgCmds[j]), lastP.y+Number(svgCmds[j+1]));
                        lastP = new Point(lastP.x+Number(svgCmds[j+2]), lastP.y+Number(svgCmds[j+3]));
                        this.addPoint(lastC, lastP);
                        firstP = lastP;
                    }
                    j += 4;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "S" :
                do {
                // don't save if c1.x=c1.y=c2.x=c2.y=0 
                    if (!Number(svgCmds[j]) && !Number(svgCmds[j+1]) && !Number(svgCmds[j+2]) && !Number(svgCmds[j+3])) {
                    } else {
                        qc = [];
                        Math2.getQuadBez_RP(
                            {x:firstP.x, y:firstP.y},   
                            {x:lastP.x + (lastP.x - lastC.x), y:lastP.y + (lastP.y - lastC.y)},
                            {x:Number(svgCmds[j]), y:Number(svgCmds[j+1])},
                            {x:Number(svgCmds[j+2]), y:Number(svgCmds[j+3])}, 
                            1, qc);
                        for (ii=0; ii<qc.length; ii++) {
                            cp = new Point(qc[ii].cx, qc[ii].cy);
                            pp = new Point(qc[ii].p2x, qc[ii].p2y);
                            _commands.push(new CurveToCommand(cp, pp));
                            this.addPoint(cp, pp);
                        }
                        lastC = new Point(Number(svgCmds[j]), Number(svgCmds[j+1]));
                        lastP = new Point(Number(svgCmds[j+2]), Number(svgCmds[j+3]));
                        this.addPoint(lastC, lastP);
                        firstP = lastP;
                    }
                    j += 4;
                } while (j < svgCmds.length && !isNaN(Number(svgCmds[j])));
                break;
                
            case "z" :
            case "Z" :
                if (!firstP.equals(lastP)) {
                    _commands.push(new LineToCommand(firstP));
                    this.addPoint(firstP);
                }
                j++;
                break;        
                
            } // end switch
        }  while (j < svgCmds.length);
    }
    
    /**
     * 
     */
    public function draw(graphics:Graphics):void {
        for each (var command:SVGPathCommand in this._commands) {
            command.execute(graphics);
        }
    }
    
}



class String2 {
    
    /**
    * @class String2
    * @author Helen Triolo, with inclusions from Tim Groleau
    * @description String functions not included in String needed for path->array conversion
    */

    /**
    * @method replace ()
    * @description Replaces sFind in s with sReplace
    * @param s (String) original string
    * @param sFind (String) part to be replaced
    * @param sReplace (String) string to replace it with
    * @returns (String) string with replacement
    */
    public static function replace(s:String, sFind:String, sReplace:String):String {
      return s.split(sFind).join(sReplace);
    }
    
    /**
    * @method shrinkSequencesOf (Groleau)
    * @description Shrinks all sequences of a given character in a string to one
    * @param s (String) original string
    * @param ch (String) character to be found
    * @returns (String) string with sequences shrunk
    */
    public static function shrinkSequencesOf(s:String, ch:String):String {
        var len:Number = s.length;
        var idx:Number = 0;
        var idx2:Number = 0;
        var rs:String = "";
        
        while ((idx2 = s.indexOf(ch, idx) + 1) != 0) {
            // include string up to first character in sequence
            rs += s.substring(idx, idx2);
            idx = idx2;
            
            // remove all subsequent characters in sequence
            while ((s.charAt(idx) == ch) && (idx < len)) idx++;
        }
        return rs + s.substring(idx, len);    
    }
}


class Math2 {
    
    /**
    * @class Math2
    * @author Helen Triolo, with inclusions from Robert Penner, Tim Groleau
    * @description Math functions not included in Math needed for path->array conversion
    */
    
    /**
    * @method ratioTo (Groleau)
    * @description Returns the point on segment [p1,p2] which is ratio times the total distance 
    *                between p1 and p2 away from p1
    * @param p1 (Object) x and y values of point p1
    * @param p2 (Object) x and y values of point p2
    * @param ratio (Number) real
    * @returns Object
    */
    public static function ratioTo(p1:Object, p2:Object, ratio:Number):Object {
        return {x:p1.x + (p2.x - p1.x) * ratio, y:p1.y + (p2.y - p1.y) * ratio };
    }

    /**
    * @method intersect2Lines (Penner)
    * @description Returns the point of intersection between two lines
    * @param p1, p2 (Objects) points on line 1
    * @param p3, p4 (Objects) points on line 2
    * @returns Object (point of intersection)
    */
    public static function intersect2Lines (p1:Object, p2:Object, p3:Object, p4:Object):Object {
        var x1:Number = p1.x; var y1:Number = p1.y;
        var x4:Number = p4.x; var y4:Number = p4.y;
        var dx1:Number = p2.x - x1;
        var dx2:Number = p3.x - x4;

       if (!(dx1 || dx2)) return NaN;
       var m1:Number = (p2.y - y1) / dx1;
       var m2:Number = (p3.y - y4) / dx2;
       if (!dx1) {
          return { x:x1, y:m2 * (x1 - x4) + y4 };
       } else if (!dx2) {
          return { x:x4, y:m1 * (x4 - x1) + y1 };
       }
       var xInt:Number = (-m2 * x4 + y4 + m1 * x1 - y1) / (m1 - m2);
       var yInt:Number = m1 * (xInt - x1) + y1;
       return { x:xInt,y:yInt };
    }

    /**
    * @method rotation
    * @description Returns the angle in degrees from the horizontal to a point dy up and dx over
    * @param dy (Number) pixels
    * @param dx (Number) pixels
    * @returns Number (angle, degrees)
    */
    public static function rotation(dy:Number, dx:Number):Number {
        return Math.atan2(dy, dx) * 180/Math.PI;
    }

    /**
    * @method midPt
    * @description Returns the midpoint (x/y) of a line segment from p1x/p1y to p2x/p2y
    * @param p1x (Number) pixels
    * @param p1y (Number) pixels
    * @param p2x (Number) pixels
    * @param p2y (Number) pixels
    * @returns Object (midpoint)
    */
    public static function midPt(p1x:Number, p1y:Number, p2x:Number, p2y:Number):Object {
        return {x:(p1x + p2x)/2, y:(p1y + p2y)/2};
    }

    /**
    * @method getQuadBez_RP (Penner)
    * @description  Approximates a cubic bezier with as many quadratic bezier segments (n) as required 
    *            to achieve a specified tolerance
    * @param p1 (Object) endpoint
    * @param c1 (Object) 1st control point
    * @param c2 (Object) 2nd control point
    * @param p2 (Object) endpoint
    * @param k: tolerance (low number = most accurate result)
    * @param qcurves (Array) will contain array of quadratic bezier curves, each element containing
    *        p1x, p1y, cx, cy, p2x, p2y
    */
     public static function getQuadBez_RP(p1:Object, c1:Object, c2:Object, p2:Object, k:Number, qcurves:Array):void {
        // find intersection between bezier arms
        var s:Object = Math2.intersect2Lines (p1, c1, c2, p2);
        // find distance between the midpoints
        var dx:Number = (p1.x + p2.x + s.x * 4 - (c1.x + c2.x) * 3) * .125;
        var dy:Number = (p1.y + p2.y + s.y * 4 - (c1.y + c2.y) * 3) * .125;
        // split curve if the quadratic isn't close enough
        if (dx*dx + dy*dy > k) {
            var halves:Object = Math2.bezierSplit (p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y);
            var b0:Object = halves.b0; var b1:Object = halves.b1;
            // recursive call to subdivide curve
            getQuadBez_RP (p1,     b0.c1, b0.c2, b0.p2, k, qcurves);
            getQuadBez_RP (b1.p1,  b1.c1, b1.c2, p2,    k, qcurves);
        } else {
            // end recursion by saving points
            qcurves.push({p1x:p1.x, p1y:p1.y, cx:s.x, cy:s.y, p2x:p2.x, p2y:p2.y});
        }
    }
        
    /**
    * @method bezierSplit (Penner)
    * @description    Divides a cubic bezier curve into two halves (each also cubic beziers)
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param c1x (Number) pixels, control point 1
    * @param c1y (Number) pixels
    * @param c2x (Number) pixels, control point 2
    * @param c2y (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @returns Object (object with two cubic bezier definitions, b0 and b1)
    */
    public static function bezierSplit(p1x:Number, p1y:Number, c1x:Number, c1y:Number, c2x:Number, c2y:Number, p2x:Number, p2y:Number):Object {
        var m:Function = Math2.midPt;
        var p1:Object = {x:p1x, y:p1y};
        var p2:Object = {x:p2x, y:p2y};
        var p01:Object = m (p1x, p1y, c1x, c1y);
        var p12:Object = m (c1x, c1y, c2x, c2y);
        var p23:Object = m (c2x, c2y, p2x, p2y);
        var p02:Object = m (p01.x, p01.y, p12.x, p12.y);
        var p13:Object = m (p12.x, p12.y, p23.x, p23.y);
        var p03:Object = m (p02.x, p02.y, p13.x, p13.y);

        /*
        b0:{a:p0,  b:p01, c:p02, d:p03},
        b1:{a:p03, b:p13, c:p23, d:p3 }  
        */

        return { b0:{p1:p1, c1:p01, c2:p02, p2:p03}, b1:{p1:p03, c1:p13, c2:p23, p2:p2} };
    }

    /**
    * @method pointOnCurve (Penner)
    * @description Returns a point on a quadratic bezier curve with Robert Penner's optimization 
    *                of the standard equation:
    *                    {x:p1x * (1-t) * (1-t) + 2 * cx * t * (1-t) + p2x * t * t,
    *                     y:p1y * (1-t) * (1-t) + 2 * cy * t * (1-t) + p2y * t * t }
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param cx (Number) pixels, control point 
    * @param cy (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @param t (Number) if time is 0-1 along curve, value of t to find point at
    * @returns Object (point at time t)
    */
    public static function pointOnCurve(p1x:Number, p1y:Number, cx:Number, cy:Number, p2x:Number, p2y:Number, t:Number):Object {
        var o:Object = new Object();
        o.x = p1x + t*(2*(1-t)*(cx-p1x) + t*(p2x - p1x));
        o.y = p1y + t*(2*(1-t)*(cy-p1y) + t*(p2y - p1y));
        return o;
    }

    /**
    * @method pointsOnCurve (Penner)
    * @description Returns an array of objects defining points on a quadratic bezier curve, each of which
    *                includes:
    *                    x,y = location of point defining start of segment
    *                    r = rotation of segment (last entry has none because it's just a point)
    *                    n = number of subdivisions into which curve will be divided (pts = n+1)
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param cx (Number) pixels, control point 
    * @param cy (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @param n (Number) number of points to return
    * @returns Array
    */
    public static function pointsOnCurve(p1x:Number, p1y:Number, cx:Number, cy:Number, p2x:Number, p2y:Number, n:Number):Array {
        var pts:Array = [];
        for (var i:Number=0; i <= n; i++) {
           pts.push(Math2.pointOnCurve(p1x, p1y, cx, cy, p2x, p2y, i/n));
           if (i > 0) {
               pts[i].r = Math2.rotation(pts[i].y-pts[(i-1)].y, pts[i].x-pts[(i-1)].x);
           }
        }
        pts.splice(0,1);  // remove 1st element to return 1/n, 2/n,... n
        return pts;
    }

    /**
    * @method pointsOnLine (Penner)
    * @description Returns an array of point positions and rotations for n evenly spaced points 
    *                    along a line segment
    *                    x,y = location of point defining start of segment
    *                    r = rotation of segment (last entry has none because it's just a point)
    *                    n = number of subdivisions into which curve will be divided (pts = n+1)
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @param n (Number) number of points to return
    * @returns Array
    *//* ....................................................................
       Returns an array of point positions and rotation for n evenly spaced points along a line segment
    */
    public static function pointsOnLine(p1x:Number, p1y:Number, p2x:Number, p2y:Number, n:Number):Array {
        var pts:Array = [];
        if (p2x != p1x) {
            var m:Number = (p2y-p1y)/(p2x-p1x);
            var b:Number = p1y - p1x * m;
            for (var i:Number=0; i <= n; i++) {
                var x:Number = p1x + ((p2x-p1x)/n) * i;
                pts.push({x:x, y:m*x+b});
                if (i > 0) {
                    pts[i].r = Math2.rotation(pts[i].y-pts[(i-1)].y, pts[i].x-pts[(i-1)].x);
                }
            }
        // vertical segment
        } else {
            for (i=0; i<=n; i++) {
                pts.push({x:p1x, y:p1y + ((p2y-p1y)/n) * i, r:90});
            }
        }            
        pts.splice(0,1);  // remove 1st element to return 1/n, 2/n,... n
        return pts;
    }

    /**
    * @method curveApproxLen
    * @description Returns the approximate length of a curved segment, found by dividing it 
    *                into two segments at t=0.5
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param cx (Number) pixels, control point 
    * @param cy (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @returns Number
    */
    public static function curveApproxLen(p1x:Number, p1y:Number, cx:Number, cy:Number, p2x:Number, p2y:Number):Number {
        var mp:Object = Math2.pointOnCurve(p1x, p1y, cx, cy, p2x, p2y, 0.5);
        var len1:Number = Math.sqrt((mp.x - p1x) * (mp.x - p1x) + (mp.y - p1y) * (mp.y - p1y));
        var len2:Number = Math.sqrt((mp.x - p2x) * (mp.x - p2x) + (mp.y - p2y) * (mp.y - p2y));
        return len1+len2;
    }

    /**
    * @method lineLen
    * @description Returns the length of a line segment
    * @param p1x (Number) pixels, endpoint 1
    * @param p1y (Number) pixels
    * @param p2x (Number) pixels, endpoint 2
    * @param p2y (Number) pixels
    * @returns Number
    */
    public static function lineLen(p1x:Number, p1y:Number, p2x:Number, p2y:Number):Number {
        return Math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y));
    }

    /**
    * @method roundTo
    * @description Returns a number rounded to specified number of decimals 
    * @param n (Number) 
    * @param ndec (Number) number of decimals to round to
    * @returns Number
    */
    public static function roundTo(n:Number, ndec:Number):Number {
        var multiplier:Number = Math.pow(10, ndec);
        return Math.round(n*multiplier)/multiplier;
    }
}



class SVGColor {
    
    public static function getByName(name:String):Number {
        var col:Number = SVGColor._colorTable[name];
        return isNaN(col) ? 0 : col;
    }
    
    private static const _colorTable:Object = {
        blue:0x0000ff,
        green:0x008000,
        red:0xff0000,
        aliceblue:0xf0f8ff,
        antiquewhite:0xfaebd7,
        aqua:0x00ffff,
        aquamarine:0x7fffd4,
        azure:0xf0ffff,
        beige:0xf5f5dc,
        bisque:0xffe4c4,
        black:0x000000,
        blanchedalmond:0xffebcd,
        blueviolet:0x8a2be2,
        brown:0xa52a2a,
        burlywood:0xdeb887,
        cadetblue:0x5f9ea0,
        chartreuse:0x7fff00,
        chocolate:0xd2691e,
        coral:0xff7f50,
        cornflowerblue:0x6495ed,
        cornsilk:0xfff8dc,
        crimson:0xdc143c,
        cyan:0x00ffff,
        darkblue:0x00008b,
        darkcyan:0x008b8b,
        darkgoldenrod:0xb8860b,
        darkgray:0xa9a9a9,
        darkgreen:0x006400,
        darkgrey:0xa9a9a9,
        darkkhaki:0xbdb76b,
        darkmagenta:0x8b008b,
        darkolivegreen:0x556b2f,
        darkorange:0xff8c00,
        darkorchid:0x9932cc,
        darkred:0x8b0000,
        darksalmon:0xe9967a,
        darkseagreen:0x8fbc8f,
        darkslateblue:0x483d8b,
        darkslategray:0x2f4f4f,
        darkslategrey:0x2f4f4f,
        darkturquoise:0x00ced1,
        darkviolet:0x9400d3,
        deeppink:0xff1493,
        deepskyblue:0x00bfff,
        dimgray:0x696969,
        dimgrey:0x696969,
        dodgerblue:0x1e90ff,
        firebrick:0xb22222,
        floralwhite:0xfffaf0,
        forestgreen:0x228b22,
        fuchsia:0xff00ff,
        gainsboro:0xdcdcdc,
        ghostwhite:0xf8f8ff,
        gold:0xffd700,
        goldenrod:0xdaa520,
        gray:0x808080,
        grey:0x808080,
        greenyellow:0xadff2f,
        honeydew:0xf0fff0,
        hotpink:0xff69b4,
        indianred:0xcd5c5c,
        indigo:0x4b0082,
        ivory:0xfffff0,
        khaki:0xf0e68c,
        lavender:0xe6e6fa,
        lavenderblush:0xfff0f5,
        lawngreen:0x7cfc00,
        lemonchiffon:0xfffacd,
        lightblue:0xadd8e6,
        lightcoral:0xf08080,
        lightcyan:0xe0ffff,
        lightgoldenrodyellow:0xfafad2,
        lightgray:0xd3d3d3,
        lightgreen:0x90ee90,
        lightgrey:0xd3d3d3,
        lightpink:0xffb6c1,
        lightsalmon:0xffa07a,
        lightseagreen:0x20b2aa,
        lightskyblue:0x87cefa,
        lightslategray:0x778899,
        lightslategrey:0x778899,
        lightsteelblue:0xb0c4de,
        lightyellow:0xffffe0,
        lime:0x00ff00,
        limegreen:0x32cd32,
        linen:0xfaf0e6,
        magenta:0xff00ff,
        maroon:0x800000,
        mediumaquamarine:0x66cdaa,
        mediumblue:0x0000cd,
        mediumorchid:0xba55d3,
        mediumpurple:0x9370db,
        mediumseagreen:0x3cb371,
        mediumslateblue:0x7b68ee,
        mediumspringgreen:0x00fa9a,
        mediumturquoise:0x48d1cc,
        mediumvioletred:0xc71585,
        midnightblue:0x191970,
        mintcream:0xf5fffa,
        mistyrose:0xffe4e1,
        moccasin:0xffe4b5,
        navajowhite:0xffdead,
        navy:0x000080,
        oldlace:0xfdf5e6,
        olive:0x808000,
        olivedrab:0x6b8e23,
        orange:0xffa500,
        orangered:0xff4500,
        orchid:0xda70d6,
        palegoldenrod:0xeee8aa,
        palegreen:0x98fb98,
        paleturquoise:0xafeeee,
        palevioletred:0xdb7093,
        papayawhip:0xffefd5,
        peachpuff:0xffdab9,
        peru:0xcd853f,
        pink:0xffc0cb,
        plum:0xdda0dd,
        powderblue:0xb0e0e6,
        purple:0x800080,
        rosybrown:0xbc8f8f,
        royalblue:0x4169e1,
        saddlebrown:0x8b4513,
        salmon:0xfa8072,
        sandybrown:0xf4a460,
        seagreen:0x2e8b57,
        seashell:0xfff5ee,
        sienna:0xa0522d,
        silver:0xc0c0c0,
        skyblue:0x87ceeb,
        slateblue:0x6a5acd,
        slategray:0x708090,
        slategrey:0x708090,
        snow:0xfffafa,
        springgreen:0x00ff7f,
        steelblue:0x4682b4,
        tan:0xd2b48c,
        teal:0x008080,
        thistle:0xd8bfd8,
        tomato:0xff6347,
        turquoise:0x40e0d0,
        violet:0xee82ee,
        wheat:0xf5deb3,
        white:0xffffff,
        whitesmoke:0xf5f5f5,    
        yellow:0xffff00,
        yellowgreen:0x9acd32
    }
    
}


class SVGPathCommandType {

    public static const BEGIN_FILL_COMMAND:Number = 1;
    public static const LINE_STYLE_COMMAND:Number = 2;
    public static const MOVE_TO_COMMAND:Number = 3;
    public static const LINE_TO_COMMAND:Number = 4;
    public static const CURVE_TO_COMMAND:Number = 5;
    
}


interface ISVGPathCommand {
        
    function execute(graphics:Graphics):void;
    
}


class SVGPathCommand implements ISVGPathCommand {
    
    private var _type:Number;
    public function get type():Number { return this._type; }
    
    public function SVGPathCommand(type:Number = 0) {
        this._type = type;
    }
    
    public function execute(graphics:Graphics):void {
        throw new Error('Subclass must be implement execute method.');
    }
    
}


class BeginFillCommand extends SVGPathCommand {
    
    private var _color:Number;
    public function get color():Number { return this._color; }
    
    private var _alpha:Number;
    public function get alpha():Number { return this._alpha; }
    
    public function BeginFillCommand(color:Number, alpha:Number) {
        super(SVGPathCommandType.BEGIN_FILL_COMMAND);
        this._color = color;
        this._alpha = alpha;
    }
    
    public override function execute(graphics:Graphics):void {
        graphics.beginFill(this._color, this._alpha);
    }
    
}


class CurveToCommand extends SVGPathCommand implements ISVGPathCommand {
    
    private var _pt1:Point;
    public function get x1():Number { return this._pt1.x; }
    public function get y1():Number { return this._pt1.y; }
    
    private var _pt2:Point;
    public function get x2():Number { return this._pt2.x; }
    public function get y2():Number { return this._pt2.y; }
    
    public function CurveToCommand(pt1:Point, pt2:Point) {
        super(SVGPathCommandType.CURVE_TO_COMMAND);
        this._pt1 = pt1;
        this._pt2 = pt2;
    }
    
    public override function execute(graphics:Graphics):void {
        graphics.curveTo(this._pt1.x, this._pt1.y, this._pt2.x, this._pt2.y);
    }
    
}


class LineStyleCommand extends SVGPathCommand implements ISVGPathCommand {
    
    private var _width:Number;
    public function get width():Number { return this._width; }
    
    private var _color:Number;
    public function get color():Number { return this._color; }
    
    private var _alpha:Number;
    public function get alpha():Number { return this._alpha; }
    
    public function LineStyleCommand(width:Number, color:Number, alpha:Number) {
        super(SVGPathCommandType.LINE_STYLE_COMMAND);
        this._width = width;
        this._color = color;
        this._alpha = alpha;
    }
    
    public override function execute(graphics:Graphics):void {
        graphics.lineStyle(this._width, this._color, this._alpha);
    }
}


class LineToCommand extends SVGPathCommand implements ISVGPathCommand {
    
    private var _pt:Point;
    public function get x():Number { return this._pt.x; }
    public function get y():Number { return this._pt.y; }
    
    public function LineToCommand(pt:Point) {
        super(SVGPathCommandType.LINE_TO_COMMAND);
        this._pt = pt;
    }
    
    public override function execute(graphics:Graphics):void {
        graphics.lineTo(this._pt.x, this._pt.y);
    }
    
}


class MoveToCommand extends SVGPathCommand implements ISVGPathCommand {
    
    private var _pt:Point;
    public function get x():Number { return this._pt.x; }
    public function get y():Number { return this._pt.y; }
    
    public function MoveToCommand(pt:Point) {
        super(SVGPathCommandType.MOVE_TO_COMMAND);
        this._pt = pt;
    }
    
    public override function execute(graphics:Graphics):void {
        graphics.moveTo(this._pt.x, this._pt.y);
    }
    
}
