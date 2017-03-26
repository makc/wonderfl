package 
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import net.hires.debug.Stats;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * ...
     * @author ze
     */
     [SWF(frameRate='60')]

    public class Main extends Sprite 
    {
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.BEST;
            var fd:FluidDrawer = new FluidDrawer(stage);
            addChild(fd);
            var stats:Stats = new Stats();
            addChild(stats);           
        }
        
    }
 }
     import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    class FluidDrawer extends Sprite
    {
        //public var h:Silks;
        //public var a:Object; //audio
        //public var b; //controls
        //public var c:Function;
        //public var e, f:int, g;
        //public static var silks:Silks;
        
        //public var c, e, f, j, g, k, C:*, m, n:Number, t, l:Number, p, r, E:Shape, u:Shape, zProperty, q, s, v, F;
        private var finalResult:Bitmap;
        private var bitmapData:BitmapData;
        private var targetSilk:Shape;
        //private var cntr:int = 0;
        private var stageRef:Stage;
        public function FluidDrawer(stageRef:Stage)
        {
            this.stageRef = stageRef;
            //addChild(this);
            
            bitmapData = new BitmapData(stageRef.stageWidth, stageRef.stageHeight, false, 0x0);
            finalResult = new Bitmap(bitmapData);
            addChild(finalResult);
            
            //this.stage = stageRef;
            var audio:Object, controls:Object, animateFunction:Function, /*e, f, g,*/ silks:Silks;
            var silkOne:Shape = new Shape();
            var silkTwo:Shape = new Shape();
            var sparks:Shape = new Shape();
            
            //silkOne.cacheAsBitmap = true;
            //silkTwo.cacheAsBitmap = true;
            //sparks.cacheAsBitmap = true;
            
            targetSilk = silkOne;
            //this.addChild(silkOne);
            //this.addChild(silkTwo);
            this.addChild(sparks);
            
            silks = new Silks(stage, silkOne, silkTwo, sparks);
            //a = initAudio();
            controls = initControls(silks, audio);
            //f = document.location.href.indexOf("?");
            //- 1 < f ? (g = document.location.href.indexOf("&"), e = document.location.href.substring(f + 1), -1 < g && (e = e.substring(0, g - f - 1)), d("Loading silk", e), h.load(e)) : refreshCarbonAd();
            
            
            var cntr:int = 0;
            animateFunction = function():int
            {
                var degree:Number = (cntr+=7) % 360;
                var angle:Number = degree / 180 * Math.PI;
                //
                var radius:Number = 300;
                //trace("angle: " + angle);
                var xPos:Number, yPos:Number;
                xPos = 500 + Math.sin(angle) * radius;
                yPos = 500 + Math.cos(angle) * radius;
                //simulateMouseMove(xPos, yPos);
                //silkOne.graphics.lineStyle(2, 0xFF0000, 1);
                //silkOne.graphics.drawRect(xPos, yPos, 3, 3);
                for (var i:int = 0; i < 2; i++)
                {
                    controls.exist();
                    silks.exist();
                }
                //a.modulateDrawSound(b.vmouse());
                copyToBitmap();

                return Global.requestAnimFrame(animateFunction);
            };
            animateFunction();
            //return ko.applyBindings(b.ui, $("#body")[0])
        }
        private function copyToBitmap():void {
            var g:Graphics = targetSilk.graphics;
            var rect:Rectangle = new Rectangle(0, 0, targetSilk.width, targetSilk.height);
            //bitmapData.copyPixels(targetSilk.graphics, rect, new Point(0,0));
            bitmapData.draw(targetSilk, null, null, BlendMode.ADD);
            
            //if (cntr % 20 == 0)
            //{
                targetSilk.graphics.clear();
            //}
            //cntr++;
            
        }
        
        private function simulateMouseMove(xPos:Number, yPos:Number):void {
            var b:Number, e:Number;
                //b = c.offset();
                //e = c.x; //b.left;
                //b = c.y; //b.top;
                //trace("xPos: " + xPos + " yPos: " +yPos);
                n = xPos;
                t = yPos;
                
        }
        private var n:*, t:*;
        public function initControls(a:Silks, b:Object):Object
        {
            var c:Shape, e:*, f:*, j:*, g:*, k:*, h:*, C:*, isMouseDown:Boolean, l:*, p:*, r:*, startDraw:Function, w:Function, stopDraw:Function, E:*, u:*, z:*, q:*, s:*, v:String, F:Array;
            C = a.silkOne;
            E = a.silkTwo;
            u = a.sparksCanvas;
            initResizeHandler(C, E, u);
            l = n = u.width / 2;
            p = t = u.height / 2;
            z = q = s = 0;
            isMouseDown = false;
            r = null;
            C = !1;
            /*try
               {
               (h = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")) && (C = !0)
               }
               catch (K)
               {
               null != navigator.mimeTypes["application/x-shockwave-flash"] && (C = !0)
             }*/
            
            c = u;
            
            startDraw = function():Boolean
            {
                //b.start();
                isMouseDown = true;
                r = a.add();
                //b.playDrawSound();
                //k.ui.replayUrl("");
                return false;
            }
            
            w = function(mevent:MouseEvent):void
            {
                var b:Number, e:Number;
                //b = c.offset();
                e = c.x; //b.left;
                b = c.y; //b.top;
                n = mevent.localX - e;
                t = mevent.localY - b;
            }
            
            stopDraw = function():void
            {
                isMouseDown = false;
                a.complete(r);
                //return b.stopDrawSound()
            }
            
            var onTouchEnd:Function = function(e:TouchEvent):void
            {
                stopDraw();
            }
            
            var onTouchMove:Function = function(e:TouchEvent):void
            {
                //'a' is the name of the original param: ...mousemove(function (a) {...
                ////w(a.originalEvent.touches[0] || a.originalEvent.changedTouches[0]);
            }
            
            var onTouchStart:Function = function(e:TouchEvent):void
            {
                //'a' is the name of the original param: ...mousemove(function (a) {...
            /*w(a.originalEvent.touches[0] || a.originalEvent.changedTouches[0]);
               l = n;
               p = t;
             D();*/
            }
            
            var onMouseMove:Function = function(event:MouseEvent):void
            {
                //'a' is the name of the original param: ...mousemove(function (a) {...
                /*return*/
                
                w(event);
            }
            
            var onMouseDown:Function = function(e:MouseEvent):void
            {
                /*if (1 === a.which) return*/
                //k.ui.showAbout.value = false;
                startDraw();
            }
            
            var onMouseUp:Function = function(e:MouseEvent):void
            {
                /*if (1 ===a.which) return*/
                stopDraw();
            }
            stageRef.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stageRef.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stageRef.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stageRef.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchStart);
            stageRef.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            stageRef.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
            
            k = {
                exist: function():void{
                    
                    var b:Number;
                    
                    if (isMouseDown)
                    {
                        a.addPoint(r, n, t, n - l, t - p);
                        q = l - n;
                        s = p - t;
                        b = q * q + s * s;
                        z = 0 < b ? Global.sqrt(b) : 0
                    } else {
                        q = s = z = 0;
                    }
                    
                    l = n;
                    p = t
                }, vmouse: function():Number
                {
                    //mouse speed
                    return z
                }, ui: {pristine: a.pristine, dirty: a.dirty, canUndo: a.canUndo, replayUrl: a.replayUrl, saving: a.saving, canClip: C, 
                     symmetry: new Observable(""),
                     color: new Observable(""),
                     setColor: function(a:*):*
                {
                    k.ui.color(a);
                    return b.blip()
                }, setSymmetry: function(a:*):*
                {
                    return k.ui.symmetry(a)
                },  randomize: function():*
                {
                    return a.setRandomParams()
                }, unrandomize: function():*
                {
                    return a.unsetRandomParams()
                },  bloop: function():*
                {
                    return b.bloop()
                }}};
           
            g = {blue: "#3d95cc", green: "#53BD39", yellow: "#E3BF30", orange: "#EB5126", pink: "#dd4876", grey: "#555555"};
            j = function():String
            {
                return g[k.ui.color.value()];
            };
            
            var outerSilks:Silks = a;
            (k.ui.color as Observable).addEventListener(Observable.VALUE_CHANGE, function(e:*):* {
                var currSilks:Silks = outerSilks;
                var colorName:String = k.ui.color.value;
                var colorValue:String = g[colorName];
                
                    currSilks.setRGB(colorValue);
            } );
            /*for (f in g)
                h = g[f], $("#colors ." + f).css("background", h);*/
            /*k.ui.symmetry.subscribe(function(b)
                {
                    //sessionStorage.symmetryKind = b;
                    switch (b)
                    {
                        case "none": 
                            return a.setSymmetryTypes();
                        case "vertical": 
                            return a.setSymmetryTypes("vertical");
                        case "both": 
                            return a.setSymmetryTypes("horizontal", "vertical", "diagonal")
                    }
                });*/
            (k.ui.symmetry as Observable).addEventListener(Observable.VALUE_CHANGE, function(e:*):* {
                switch (b)
                    {
                        case "none": 
                            return a.setSymmetryTypes();
                        case "vertical": 
                            return a.setSymmetryTypes("vertical");
                        case "both": 
                            return a.setSymmetryTypes("horizontal", "vertical", "diagonal")
                    }
            } );
            //k.ui.color(null != (v = sessionStorage.colorName) ? v : "blue");
            k.ui.color.value = "blue";
            //k.ui.symmetry(null != (F = sessionStorage.symmetryKind) ? F : "vertical");
            k.ui.symmetry.value = "vertical";
            /*key("x, space", function()
                {
                    return k.ui.clear()
                });
            key("u", function()
                {
                    return k.ui.undo()
                });*/
            return k;
        }
        
        public function initResizeHandler(... params):void
        {
        /*var a:Array, b:Function;
           a = (1 <= arguments.length ? y.call(arguments, 0) : []);
           b = function()
           {
           var b:Stage, e, f, j, g, k, h;
           h = [];
           g = 0;
           for (k = a.length; g < k; g++)
           {
           e = a[g];
           b = e.getContext("2d");
           j = e.width;
           f = e.height;
           f = b.getImageData(0, 0, j - 1, f - 1);
           b = stage;
           e.width = b.stageWidth;
           e.height = b.stageHeight;
           b = e.getContext("2d");
           h.push(b.putImageData(f, 0, 0));
           }
           return h
           };
           b();
           //return $(window).resize(b)
         */
        }
    
    }
    
    
    //SILKS
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.IEventDispatcher;
    
    /**
     * ...
     * @author ze
     */
    class Silks
    {
        public var silkOne:Shape;
        public var silkTwo:Shape;
        public var sparksCanvas:Shape;
        public var bufferCanvas:Shape;
        public var silkCanvas:Shape;
        public var silks:Object;
        public var time:Number;
        public var pristine:Observable;
        public var dirty:Observable;
        public var undoState:Observable;
            
        //this.tape = new Tape(this);
        //this.replay = new Tape(this);
        public var sparks:Sparks;
        public var replayUrl:Observable;
        public var saving:Observable;
            
        public var drawScale:Number;
        
        public var rgb:Array;
        public var symmetryTypes:*;
        private var stage:Stage;
        
        public function Silks(stage:Stage,silkOne:Shape, silkTwo:Shape, sparksCanvas:Shape)
        {
            this.stage = stage;
            //this.getPictureURL = G(this.getPictureURL, this);
            //this.toBlob = G(this.toBlob, this);
            //var e = this;
            this.silkOne = silkOne;
            this.silkTwo = silkTwo;
            this.silkCanvas = this.silkOne;
            this.bufferCanvas = this.silkTwo;
            this.sparksCanvas = sparksCanvas;
            this.silkTwo.visible = false;
            this.silks = {};
            this.time = 0;
            this.pristine = new Observable(true); // ko.observable(!0);
            this.dirty = new Observable(false); //ko.observable(!1);
            this.undoState = new Observable(null); //ko.observable(null);
            /*this.canUndo = ko.computed(function()
                {
                    return null != e.undoState() && !e.dirty()
                });*/
            //this.tape = new Tape(this);
            //this.replay = new Tape(this);
            this.sparks = new Sparks();
            this.replayUrl = new Observable("");//ko.observable("");
            this.saving = new Observable(false);//ko.observable(!1);
            this.setRGB("dd4876");
            //this.setSymmetryTypes("vertical");
            this.setSymmetryTypes();
            this.drawScale = 1;
        }
        
        public function canUndo():Boolean
        {
            return null != undoState && !dirty.value;
        }
        
        public function load(a:String):*
        {
            /*var b = this;
            $.ajax({type: "GET", url: "/v1/load", data: {id: a}, success: function(a)
                {
                    a = JSON.parse(a);
                    b.replay = new Tape(b);
                    return b.replay.load(a)
                }});
            return this.replayUrl("/?" + a)*/
            
            return null;
        }
        
        public function save():*
        {
            /*
            var a, b = this;
            a = JSON.stringify(this.tape.get());
            $.ajax({type: "POST", url: "/v1/save", data: {contents: a}, success: function(a)
                {
                    b.replayUrl("/?" + a);
                    return b.saving(!1)
                }});
            return this.saving(!0)*/
            
            return null;
        }
        
        public function toBlob():*
        {
            /*return this.silkCanvas.toBlob(function(a)
                {
                    return saveAs(a, "silk.png")
                })*/
            return null;
        }
        
        public function getPictureURL():String
        {
            /*var a, b, c, e, f, j;
            a = this.silkCanvas;
            c = a.getContext("2d");
            j = a.width;
            f = a.height;
            e = c.getImageData(0, 0, j, f);
            b = c.globalCompositeOperation;
            c.globalCompositeOperation = "destination-over";
            c.fillStyle = "#000";
            c.fillRect(0, 0, j, f);
            a = a.toDataURL("image/png");
            c.clearRect(0, 0, j, f);
            c.putImageData(e, 0, 0);
            c.globalCompositeOperation = b;
            return a*/
            return "";
        }
        
        public function swapSilkCanvii():void
        {
            trace("3: swap");
            this.silkCanvas === this.silkOne ? (this.bufferCanvas = this.silkOne, this.silkCanvas = this.silkTwo) : (this.silkCanvas = this.silkOne, this.bufferCanvas = this.silkTwo);
            var bufferCanvasChildIdx:int = silkCanvas.parent.getChildIndex(bufferCanvas);
            silkCanvas.parent.setChildIndex(silkCanvas, bufferCanvasChildIdx);
            //$(this.silkCanvas).insertBefore($(this.bufferCanvas));
            //$(this.silkCanvas).addClass("active");
            //return $(this.bufferCanvas).removeClass("active")
        }
        
        public function add(a:*=null, b:*=null, c:*=null, e:*=null, f:*=null, j:*=null):Number
        {
            var g:Silk;
            (null == a && (a = (new Date).getTime()));
            (null == b && (b = this.rgb));
            (null == c && (c = this.symmetryTypes));
            (null == e && (e = this.silkCanvas.width));
            (null == f && (f = this.silkCanvas.height));
            (null == j && (j = Global.randrange(0, 1E6) | 0));
            //this.tape.recStart();
            //this.tape.rec("add", a, b, c, e, f, j);
            this.silks[a] = new Silk(stage, this.silkCanvas, e, f, j);
            g = this.silks[a] as Silk;
            g.drawScale = this.drawScale;
            
            g.setRGB.apply(g, b);
            g.setSymmetryTypes(c);
            this.dirty.value=true;
            this.pristine.value = false;
            return a;
        }
        
        public function addPoint(a:Number, b:Number, c:Number, e:Number, f:Number):void
        {            
            //this.tape.rec("addPoint", a, b, c, e, f);
            var j:Silk = this.silks[a] as Silk;
            if (j != null)
            {
                j.add2(b, c, e, f);
            }
        }
        
        public function complete(a:Number):void
        {
            var b:Boolean, c:Silk, e:Object;
            if (null != this.silks[a] && !this.silks[a].completed)
            {
                /*this.tape.rec("complete", a);*/
                this.silks[a].complete();
                b = true;
                e = this.silks;
                for (var key:String in e)
                    if (c = e[key], !c.completed)
                    {
                        b = !1;
                        break
                    }
                /*if (b && (this.tape.recStop(), 10 < this.tape.time - this.tape.startedTime))
                    return this.tape.advance(15)
                    */
            }
        }
        
        public function clear():void
        {
            var a:*, b:Object;
            if (this.dirty.value)
            {
                /*b = this.tape.eject();
                this.replay.eject();*/
                this.undoState.value={time: this.time, tapeContents: b, replayUrl: this.replayUrl.value};
                this.replayUrl.value = "";
                b = this.silks;
                for (a in b)
                    this.complete(a);
                this.silks = {};
                this.dirty.value = false;
                this.time = 0;
                //a = this.bufferCanvas.getContext("2d");
                //a.clearRect(0, 0, this.bufferCanvas.width, this.bufferCanvas.height);
                
                this.bufferCanvas.graphics.clear();
                
                //$(this.silkCanvas).addClass("hidden");
                //$(this.bufferCanvas).removeClass("hidden");
                this.silkCanvas.visible = false;
                this.bufferCanvas.visible = true;
                this.swapSilkCanvii();
            }
            this.sparks.addClear(this.sparksCanvas, 100);
        }
        
        public function undoClear():void
        {
            var a:*;
            if (this.canUndo())
            {
                a = this.undoState.value;
                this.time = a.time;
                //this.tape.load(a.tapeContents);
                this.replayUrl.value = a.replayUrl;
                this.undoState.value = null;
                this.dirty.value = true;
                //$(this.bufferCanvas).removeClass("hidden");
                this.bufferCanvas.visible = true;
                this.swapSilkCanvii();
                this.sparks.addClear(this.sparksCanvas, 100, -1);
            }
        }
        
        public function exist():int
        {
            
            var a:String, b:Silk, c:Shape, e:Shape, f:int, j:Object;
            c = this.silkCanvas//.getContext("2d");
            e = this.sparksCanvas//.getContext("2d");
            //c.globalCompositeOperation = "lighter";
            //c.blendMode = BlendMode.DARKEN;
            
            j = this.silks;
            for (a in j)
            {
                if (b = j[a], b.alive)
                {
                    //trace("silk alive: " + b.alive + " " + b);
                    this.sparks.addFromSilk(b);
                    for (f = 1; 6 >= f; ++f)
                    {
                        b.exist(c);
                    }
                    b.tick();
                }
                else
                {
                    trace("delete silk");
                    delete this.silks[a];
                }
            }
            //e.clearRect(0, 0, this.sparksCanvas.width, this.sparksCanvas.height);
            e.graphics.clear();
            this.sparks.exist(e);
            //this.replay.play();
            //this.tape.recording && this.tape.tick();
            //this.replay.tick();
            
            return this.tick()
        }
        
        public function tick():int
        {
            return this.time += 1
        }
        
        public function setRandomParams(a:Object=null):void
        {
            (null == a && (a = Silk.randomParams()));
            Silk.setDefaultParams(a)
        }
        
        public function unsetRandomParams():void
        {
            return Silk.resetDefaultParams();
        }
        
        public function setSymmetryTypes(...params):*
        {
            var arr:Array = params as Array;
            if (params.length >= 1)
            {
                this.symmetryTypes = params.slice(0);
            } else {
                this.symmetryTypes = [];
            }
            return this.symmetryTypes;
            //return null;
        }
        
        public function setRGB(a:String):Array
        {
            return this.rgb = Global.hexToRGB(a)
        }
    
    }


//GLOBAL

import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    /**
     * ...
     * @author ze
     * AS3 version of http://new.weavesilk.com/
     */
    class Global
    {
        
        //this.SilkDomain = "http://new.weavesilk.com";
        
        //extend function
        /**
           public static function h(a:*, b:Array):* {
           function c() {
           this.constructor = a
           }
           for (var e in b) J.call(b, e) && (a[e] = b[e]);
           c.prototype = b.prototype;
           a.prototype = new c;
           a.__super__ = b.prototype;
           return a
         }**/
        
        //~bind function
        public static function G(a:*, b:Array):*
        {
            return function():*
            {
                return a.apply(b, arguments);
            }
        }
        public static var J:Function = Object.prototype.hasOwnProperty;
        public static var y:Function = Array.prototype.slice;
        public static var min:Function = Math.min;
        public static var max:Function = Math.max;
        public static var rand:Function = Math.random;
        public static var abs:Function = Math.abs;
        public static var round:Function = Math.round;
        public static var floor:Function = Math.floor;
        public static var ceil:Function = Math.ceil;
        public static var log:Function = Math.log;
        public static var pow:Function = Math.pow;
        
        public static var sin:Function = Math.sin;
        public static var cos:Function = Math.cos;
        public static var sqrt:Function = Math.sqrt;
        public static var atan2:Function = Math.atan2;
        public static var Pi:Number = Math.PI;
        
        public static var TwoPi:Number = 2 * Pi;
        public static var HalfPi:Number = Pi / 2;
        public static var QuarterPi:Number = Pi / 4;
        public static var EighthPi:Number = Pi / 8;
        public static var E:Number = Math.E;
        public static var Epsilon:Number = 1E-4;
        
        public static var Paused:Boolean = false;
        
        public static function hexToRGB(input:String):Array
        {
            var a:int;
            var c:int;
            var b:Array = /^#?([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})$/i.exec(input).slice(1);
            var e:Array = [];
            for (a = c = 0; 2 >= c; a = ++c)
                e.push(parseInt(b[a], 16));
            return e;
        }
        
        public static function brightenRGB(a:int, b:int, c:int, e:Number):Array
        {
            return [floor(min(255, a + 255 * e)), floor(min(255, b + 255 * e)), floor(min(255, c + 255 * e))]
        }
        
        public static function contrain(a:Number, b:Number, c:Number):Number
        {
            //returns x where b<=x(=a)<=c 
            return a > c ? c : a < b ? b : a
        }
        
        public static function randrange(a:Number, b:Number):Number
        {
            //returns random number(=x) between a and b (a.....x...b)
            return a + rand() * (b - a);
        }
        
        public static var H:int = 0; //some kind of counter...
        
        public static function autoinc():void
        {
            H++;
        }
        
        public static function d(params:*):void
        {
            //debug function
            trace(params);
        /*this.d = function () {
           return "undefined" !== typeof console && null !== console ? console.log.apply(console, Array.prototype.slice.call(arguments)) : void 0
         };*/
        }
        
        /*this.requestAnimationFrame || this.webkitRequestAnimationFrame || this.mozRequestAnimationFrame || this.oRequestAnimationFrame || this.msRequestAnimationFrame ||*/
        public static function requestAnimFrame(a:Function):int {
            var delayMsec:int = 1E3 / 60;
            return setTimeout(a, delayMsec);
        };
        /*
    this.cancelAnimationFrame || this.webkitCancelAnimationFrame || this.mozCancelAnimationFrame || this.oCancelAnimationFrame || this.msCancelAnimationFrame ||*/
        public var cancelAnimFrame:Function = clearTimeout;
    }


//OBSEVABLE

import flash.events.Event;
    import flash.events.EventDispatcher;
    /**
     * ...
     * @author ze
     */
    class Observable extends EventDispatcher
    {
        public static var VALUE_CHANGE:String = "onChanged";
        private var currentValue:*;
        
        public function Observable(initValue:*) 
        {
            currentValue = initValue;
        }
        
        public function get value():* {
            return currentValue;
        }
        
        public function set value(newValue:*):void {
            currentValue = newValue;
            dispatchEvent(new Event(VALUE_CHANGE));
        }
        
    }

   //PARTICLES
  
  import flash.display.Shape;
    
    /**
     * ...
     * @author ze
     */
    class Particles
    {
        public var maxParticles:int;
        public var start:int = 0;
        public var end:int = 0;
        public var all:Array;
        
        public function Particles(maxParticles:Number)
        {
            this.maxParticles = (!isNaN(maxParticles) ? maxParticles : 500);
            this.start = this.end = 0;
            this.all = new Array(this.maxParticles);
            this.all.length = this.maxParticles; //should have the same effect..
        }
        
        public function newParticle():Object
        {
            return {age: 0, alive: true};
        }
        
        public function shouldNotExist():Boolean
        {
            return this.start === this.end
        }
        
        public function exist(a:Shape):*
        {
            for (; !(this.start === this.end || this.all[this.start].alive); )
            {
                this.all[this.start] = null, this.start = this.inc(this.start);
            }
            if (!this.shouldNotExist())
            {
                return this.foreach(function(a:Object):Boolean
                    {
                        a.px = a.x;
                        a.py = a.y;
                        a.age += 1;
                        return this.update(a)
                    }), this.drawAll(a); //the drawAll() result will be returned! 
            }
            return [];
        }
        
        protected var drawStart:Function;
        protected var drawEnd:Function;
        protected var symmetries:Array = null;
        
        public function drawAll(a:Shape):Array
        {
            //NO OP
            //return [];

           var b:*, c:int, e:int, f:Array, j:Array;
            if (!this.shouldNotExist() && (drawStart!=null && drawStart(a), this.foreach(function (b:*):* {
                if (b.alive) return this.draw(b, a)
            }), drawEnd!=null && drawEnd(a), this.symmetries)) {
                f = this.symmetries;
                j = [];
                c = 0;
                for (e = f.length; c < e; c++) 
                {
                    b = f[c];
                    this.foreach(b.trans);
                    drawStart != null && drawStart(a), this.foreach(function (b:*):* {
                        if (b.alive) return this.draw(b, a)
                    }), drawEnd != null && drawEnd(a), j.push(this.foreach(b.inv));
                }
                return j
            }
            return [];
        }
        
        public function foreach(funct:Function):void
        {
            var b:int;
            for (b = this.start; b !== this.end; )
                funct.call(this, this.all[b]), b = this.inc(b)
        }
        
        public function add(xPos:Number, yPos:Number):Object
        {
            var c:int;
            var e:Object;
            c = this.inc(this.end);
            this.start === c && (this.start = this.inc(this.start));
            e = newParticle();
            e.x = xPos;
            e.y = yPos;
            this.all[this.end] = e;
            this.end = c;
            return e;
        }
        
        public function inc(a:int):int
        {
            return (a + 1) % this.maxParticles
        }
        
        public function dec(a:int):int
        {
            return (a - 1) % this.maxParticles;
        }
    }


//SPARKS

import flash.display.ShaderParameter;
    import flash.display.Shape;
    
    /**
     * ...
     * @author ze
     */
    class Sparks extends Particles
    {
        
        public function Sparks(maxParticles:Number=Number.NaN)
        {
            super(maxParticles);
        }
        
        override public function newParticle():Object
        {
            var obj:Object = super.newParticle();
            obj.r = 255;
            obj.g = 255;
            obj.b = 255;
            obj.maxA = 1;
            obj.radius = 0.75;
            obj.vx = Global.randrange( -1, 1);
            obj.vy = Global.randrange( -1, 0);
            obj.dieAt = 25;
            obj.fadeIn = false;
            return obj;
        }
        
        
        public function update(a:Object):Boolean
        {
            var b:Number;
            a.x += a.vx;
            a.y += a.vy;
            b = 1 - a.age / a.dieAt;
            a.a = a.fadeIn ? a.maxA * Global.sin(Global.Pi * b) : b;
            ///a.color = "rgba(" + a.r + ", " + a.g + ", " + a.b + ", " + a.a + ")"; //TODO: fix this!
            a.color = { r:a.r, g:a.g, b:a.b, a:a.a };
            return a.alive && (a.alive = a.age < a.dieAt)
        }
        public function draw(a:Object, b:Shape):void
        {
            if (a.alive)
            {
                //b.beginPath();
                //b.fillStyle = a.color;
                var tmpColor:int = ((a.color.r & 0xff) << 16) + ((a.color.g & 0xff) << 8)
                + (a.color.b & 0xff);
                b.graphics.beginFill(tmpColor, a.color.a);
                b.graphics.drawCircle(a.x, a.y, a.radius);// = b.arc(a.x, a.y, a.radius, 0, Global.TwoPi, !1);
                b.graphics.endFill();
                //b.fill();
                //b.closePath();
            }
        }
        public function addFromSilk(a:Silk):void
        {
            var b:Sparks = this;
            a.foreach(function(c:Object):void
                {
                    var e:Array;
                    if (0.03 > Global.rand())
                    {
                        c = b.add(c.x, c.y);
                        e = a.sparkRGB;
                        c.r = e[0];
                        c.g = e[1];
                        c.b = e[2];
                        e
                    }
                })
        }
        public function addClear (a:Shape, b:*, c:*=null):void
        {
            var e:Number, f:Number, j:Number, B:Number, k:*, g:int;
            (null == b && (b = 100));
            (null == c && (c = 1));
            f = a.width / 2;
            j = a.height / 2;
            for (g = 1; 1 <= b ? g <= b : g >= b; 1 <= b ? ++g : --g)
            {
                B = Global.randrange(0, a.width);
                k = Global.randrange(0, a.height);
                e = Global.atan2(k - j, B - f);
                e += Global.randrange( -Global.QuarterPi, Global.QuarterPi);
                k = this.add(B, k);
                B = 0.25 * c;
                k.vx = B * Global.cos(e);
                k.vy = B * Global.sin(e);
                k.dieAt = Global.randrange(25, 85);
            }
        }
        
    
    }
    
    

//SILK


import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Stage;
    
    /**
     * ...
     * @author ze
     */
    class Silk extends Particles
    {
        public var canvas:Shape;
        public var width:int;
        public var height:int;
        public var seed:Number;
        public var offx:Number;
        public var offy:Number;
        public var perlin:PerlinNoise;
        private var stage:Stage;
        public var age:int;
        public var completed:Boolean;
        public var alive:Boolean;
        public var color:Object;
        public var sparkRGB:Array;
        public var num:int;
        //public var symmetries:Array;
        
        
        //props
        
        public var noiseOctaves:int;
        public var noiseFallout: Number;
        public var noiseScale: Number;
        public var wind:Boolean;
        public var windAngle:Number;
        public var windForce:Number;
        public var friction:Number;
        public var springLength:Number;
        public var rigidity:Number;
        public var reverseMouseVelocity:Boolean;
        public var mouseDamp:Number;
        
        public var drawScale:int = 1;
        private var prevParticle:Object;
        
        public function Silk(stage:Stage, a:Shape, width:int, height:int, seed:Number)
        {
            this.canvas = a;
            this.width = width;
            this.height = height;
            this.seed = seed;
            super(Number.NaN); //g.__super__.constructor.call(this);
            this.offx = 0;//(this.width - stage.stageWidth) / 2;
            this.offy = 0;//(this.height - stage.stageHeight) / 2;
            this.age = 0;
            this.alive = true;
            this.completed = false;
            this.setParams(defaultParams);
            this.perlin = new PerlinNoise(0);
            this.color = {r: 255, g: 255, b: 255, a: 0.07};
            this.sparkRGB = [255, 255, 255];
            this.num = 0;
            this.drawStart = drawStartX;
            this.drawEnd = drawEndX;
        }
        
        public function setSymmetryTypes(a:Array):void
        {
            var c:int;
            var e:*;
            var b:*;
            var j:Silk = this;
            var f:Array = [];
            c = 0;
            for (e = a.length; c < e; c++)
                switch (b = a[c], b)
            {
                case "vertical": 
                    f.push({trans: function(a:*):Number
                        {
                            return a.x = j.canvas.width - a.x
                        }});
                    break;
                case "horizontal": 
                    f.push({trans: function(a:*):Number
                        {
                            return a.y = j.canvas.height - a.y
                        }});
                    break;
                case "diagonal": 
                    f.push({trans: function(a:*):Number
                        {
                            a.x = j.canvas.width - a.x;
                            return a.y = j.canvas.height - a.y
                        }});
                    break;
                default: 
                    f.push(void 0)
            }
            e = this.symmetries = f;
            b = 0;
            for (c = e.length; b < c; b++)
            {
                var obj:* = e[b];
                if (obj.inv == null)
                {
                    obj.inv = obj.trans;
                }
            }
        }
        
        override public function newParticle():Object
        {
            /*return $.extend(g.__super__["new"].call(this), {
               accx: 0,
               accy: 0,
               friction: this.friction,
               mass: 1,
               springLength: this.springLength,
               rigidity: this.rigidity,
               death: 250
             })*/
            var obj:Object = super.newParticle();
            obj.accx = 0;
            obj.accy = 0, obj.friction = this.friction;
            obj.mass = 1;
            obj.springLength = this.springLength;
            obj.rigidity = this.rigidity;
            obj.death = 250;
            return obj;
        }
        
        public function add2(aa:Number, bb:Number, c:Number, e:Number):Object
        {
            //TODO: test this!
            var f:*;
            f = (this.start === this.end);
            var a:Object = super.add(aa - this.offx, bb - this.offy);
            f || (this.prevParticle.next = a);
            f = this.mouseDamp;
            this.reverseMouseVelocity && (f *= -1);//ha reverse, akkor -1xf
            a.vmx = c * f;
            a.vmy = e * f;
            a.num = this.num++;
            return (this.prevParticle = a);
        }
        
        override public function shouldNotExist():Boolean
        {
            
            return super.shouldNotExist() || !this.alive
        }
        
        override public function exist(a:Shape):*
        {
            var start:Number = new Date().getTime();
            super.exist(a);
            if (this.completed && (this.color.a -= 5E-4, this.color.a < Global.Epsilon))
            {
                return this.die();
            }
            //return; //TODO: wrong return value?
            var end:Number = new Date().getTime();
            //trace("2: silks exist duration: " + (end - start));
        }
        //private var updateccntr:Number=0;
        public function update(a:Object):Boolean
        {
            //updateccntr++;
            //if (updateccntr % 100 == 0) trace("3: updateccntr: " + updateccntr);
            var b:Number, c:Number;
            Noise.noiseDetail(this.noiseOctaves, this.noiseFallout);
            c = 2 * Global.TwoPi * Noise.noise((a.x + this.offx) * this.noiseScale, (a.y + this.offy) * this.noiseScale, this.seed + 0.008 * this.age, this.perlin);
            c *= 2;
            b = Global.Pi / 2;
            (0 !== a.vmx || 0 !== a.vmy) && Global.atan2(a.vmx, a.vmy);
            this.addAngleForce(a, c + b, 1);
            this.addForce(a, a.vmx, a.vmy);
            a.vmx *= 0.99;
            a.vmy *= 0.99;
            a.rigidity *= 0.999;
            this.wind && this.addAngleForce(a, this.windAngle, this.windForce);
            null != a.next && (this.move(a), this.constrain(a));
            return a.alive && (a.alive = a.age < a.death)
        }
        
        
        public function move(a:Object):Number
        {
            a.x += (a.x - a.px) * a.friction + a.accx;
            a.y += (a.y - a.py) * a.friction + a.accy;
            return a.accx = a.accy = 0
        }
        
        public function addForce(a:Object, b:Number, c:Number):Number
        {
            a.accx += b / a.mass;
            return a.accy += c / a.mass
        }
        
        public function addAngleForce(a:Object, b:Number, c:Number):Number
        {
            c /= a.mass;
            a.accx += c * Global.cos(b);
            return a.accy += c * Global.sin(b)
        }
        
        public function addPosition(a:Object, b:Number, c:Number):Number
        {
            a.x += b;
            return a.y += c;
        }
        
        public function constrain(a:Object):Number
        {
            var b:Number, c:Number, e:Number;
            c = a.next.x - a.x;
            e = a.next.y - a.y;
            b = Math.sqrt(c * c + e * e);
            if (0 !== b && (b = 1 - a.springLength / b, c = a.rigidity * c * b, e = a.rigidity * e * b, this.addPosition(a, c, e), null != a.next.next))
                return this.addPosition(a.next, -c, -e)
            return 0; //added by me
        }
        
        public function drawStartX(a:Shape):void
        {
            var b:Object;
            //a.beginPath(); //not needed
            
            //added by ze
            var tmpColor:int = ((this.color.r & 0xff) << 16) + ((this.color.g & 0xff) << 8) + (this.color.b & 0xff);
            a.graphics.lineStyle(this.drawScale*1, tmpColor, this.color.a,true); 
            //end
            
            b = this.all[this.start];
            if (this.drawScale === 1)
            {
                a.graphics.moveTo(b.x * this.drawScale, b.y * this.drawScale);
            } else {
                a.graphics.moveTo((b.x - stage.stageWidth / 2) * this.drawScale + stage.stageWidth / 2, (b.y - stage.stageHeight / 2) * this.drawScale + stage.stageHeight / 2);
            }
            
        }
        
        public function draw(a:Object, b:Shape):void
        {
            var c:Number, e:Number, f:*, j:Number;
            f = a.next;
            if (null != (null != f ? f.next : void 0))
            {
                if (1 === this.drawScale)
                {
                    b.graphics.curveTo(a.x * this.drawScale, a.y * this.drawScale, (a.x * this.drawScale + f.x * this.drawScale) / 2, (a.y * this.drawScale + f.y * this.drawScale) / 2);
                    return;
                }
                c = (a.x - stage.stageWidth / 2) * this.drawScale + stage.stageWidth / 2;
                e = (a.y - stage.stageHeight / 2) * this.drawScale + stage.stageHeight / 2;
                j = (f.x - stage.stageWidth / 2) * this.drawScale + stage.stageWidth / 2;
                f = (f.y - stage.stageHeight / 2) * this.drawScale + stage.stageHeight / 2;
                b.graphics.curveTo(c, e, (c + j) / 2, (e + f) / 2)
                return;
            }
        }
        
        public function drawEndX(a:Shape):void
        {
            //var tmpColor:int = ((this.color.r & 0xff) << 16) + ((this.color.g & 0xff) << 8) + (this.color.b & 0xff);
            //a.graphics.lineStyle(this.drawScale,tmpColor,this.color.a,true); 
            //a.lineWidth = this.drawScale;
            //a.strokeStyle = "rgba(" + this.color.r + ", " + this.color.g + ", " + this.color.b + ", " + this.color.a + ")";
            //a.stroke();
            //return a.closePath()
            //NO OP
        }
        
        
        
        /*
        override public function drawAll(a:Shape):Array {
            var b:*, c:int, e:int, f:Array, j:Array;
            if (!this.shouldNotExist() && (this.drawStart(a), this.foreach(function (b:Object):void {
                if (b.alive)  this.draw(b, a)
            }), this.drawEnd(a), this.symmetries)) {
                f = this.symmetries;
                j = [];
                c = 0;
                for (e = f.length; c < e; c++) b = f[c], this.foreach(b.trans), this.drawStart(a), this.foreach(function (b:Object):void {
                        if (b.alive) this.draw(b, a)
                    }), this.drawEnd(a), j.push(this.foreach(b.inv));
                return j
            }
            return [];
        }*/
        
        public function setParams(a:Object):void
        {
            
            for (var key:String in a) {
                this[key] = a[key];
            }
            //return $.extend(this, a)
        }
        
        public function setRGB(a:int, b:int, c:int):Array
        {
            this.color.r = a;
            this.color.g = b;
            this.color.b = c;
            return this.sparkRGB = Global.brightenRGB(a, b, c, 0.3)
        }
        
        public function tick():int
        {
            return this.age += 1;
        }
        
        public function complete():Boolean
        {
            return this.completed = true;
        }
        
        public function die():Boolean
        {
            return this.alive = false;
        }
        
        private static var originalParams:Object = {noiseOctaves: 8, noiseFallout: 0.65, noiseScale: 0.01, wind: !1, windAngle: -Global.Pi, windForce: 0.75, friction: 0.975, springLength: 0, rigidity: 0.3, reverseMouseVelocity: false, mouseDamp: 0.2};
        
        public static function randomParams():Object
        {
            return {noiseOctaves: Global.randrange(2, 9), noiseFallout: Global.randrange(0.25, 1), noiseScale: Global.randrange(0.001, 0.1), wind: 0.5 > Global.rand(), windAngle: Global.randrange(0, Global.TwoPi), windForce: Global.randrange(0.5, 1), friction: Global.randrange(0, 1), springLength: Global.randrange(0, 20), rigidity: Global.randrange(0, 1), reverseMouseVelocity: 0.5 > Global.rand(), mouseDamp: Global.randrange(0, 1)}
        }
        
        private static var defaultParams:Object = originalParams;
        
        public static function setDefaultParams(a:Object):void
        {
            defaultParams = a;
        }
        
        public static function resetDefaultParams():void
        {
            setDefaultParams(originalParams);
        }
    }


//PERLINNOISE

import flash.utils.ByteArray;
    
    /**
     * ...
     * @author ze
     */
    class PerlinNoise
    {
        
        private var perm:ByteArray;
        function PerlinNoise(seed:Number)
        {
            var rnd:Marsaglia = (!isNaN(seed) ? new Marsaglia(seed,0) : Marsaglia.createRandomized());
            var i:int
            var j:int;
            // http://www.noisemachine.com/talk1/17b.html
            // http://mrl.nyu.edu/~perlin/noise/
            // generate permutation
            perm = new ByteArray(); //new Uint8Array(512);
            perm.length = 512;
            
            for (i = 0; i < 256; ++i)
            {
                perm[i] = i;
            }
            for (i = 0; i < 256; ++i)
            {
                var t:int = perm[j = rnd.nextInt() & 0xFF];
                perm[j] = perm[i];
                perm[i] = t;
            }
            // copy to avoid taking mod in perm[0];
            for (i = 0; i < 256; ++i)
            {
                perm[i + 256] = perm[i];
            }
            
        }
        
        public function noise3d(x:Number, y:Number, z:Number):Number
        {
            //var X = Math.floor(x)&255, Y = Math.floor(y)&255, Z = Math.floor(z)&255;
            //x -= Math.floor(x); y -= Math.floor(y); z -= Math.floor(z);
            var X:int = (x | 0) & 255, Y:int = (y | 0) & 255, Z:int = (z | 0) & 255;
            x -= (x | 0);
            y -= (y | 0);
            z -= (z | 0);
            var fx:Number = (3 - 2 * x) * x * x, fy:Number = (3 - 2 * y) * y * y, fz:Number = (3 - 2 * z) * z * z;
            var p0:int = perm[X] + Y, p00:int = perm[p0] + Z, p01:int = perm[p0 + 1] + Z, p1:int = perm[X + 1] + Y, p10:int = perm[p1] + Z, p11:int = perm[p1 + 1] + Z;
            return lerp(fz, lerp(fy, lerp(fx, grad3d(perm[p00], x, y, z), grad3d(perm[p10], x - 1, y, z)), lerp(fx, grad3d(perm[p01], x, y - 1, z), grad3d(perm[p11], x - 1, y - 1, z))), lerp(fy, lerp(fx, grad3d(perm[p00 + 1], x, y, z - 1), grad3d(perm[p10 + 1], x - 1, y, z - 1)), lerp(fx, grad3d(perm[p01 + 1], x, y - 1, z - 1), grad3d(perm[p11 + 1], x - 1, y - 1, z - 1))));
        }
        
        public function noise2d(x:Number, y:Number):Number
        {
            var X:int = Math.floor(x) & 255, Y:int = Math.floor(y) & 255;
            x -= Math.floor(x);
            y -= Math.floor(y);
            var fx:Number = (3 - 2 * x) * x * x, fy:Number = (3 - 2 * y) * y * y;
            var p0:Number = perm[X] + Y, p1:Number = perm[X + 1] + Y;
            return lerp(fy, lerp(fx, grad2d(perm[p0], x, y), grad2d(perm[p1], x - 1, y)), lerp(fx, grad2d(perm[p0 + 1], x, y - 1), grad2d(perm[p1 + 1], x - 1, y - 1)));
        }
        
        public function noise1d(x:Number):Number
        {
            var X:int = Math.floor(x) & 255;
            x -= Math.floor(x);
            var fx:Number = (3 - 2 * x) * x * x;
            return lerp(fx, grad1d(perm[X], x), grad1d(perm[X + 1], x - 1));
        }
        
        // TODO: Benchmark
        public function grad3d(i:int, x:Number, y:Number, z:Number):Number
        {
            var h:int = i & 15; // convert into 1   2 gradient directions
            // var u = h<8 ? x : y,
            //     v = h<4 ? y : h===12||h===14 ? x : z;
            // return ((h&1) === 0 ? u : -u) + ((h&2) === 0 ? v : -v);
            
            // Optimization from 
            // http://riven8192.blogspot.com/2010/08/calculate-perlinnoise-twice-as-fast.html
            //
            // inline float grad(int hash, float x, float y, float z)
            //    {  
            //float u = (h < 8) ? x : y;
            //float v = (h < 4) ? y : ((h == 12 || h == 14) ? x : z);
            //return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
            
            switch (h & 0xF)
            {
                case 0x0: 
                    return x + y;
                case 0x1: 
                    return -x + y;
                case 0x2: 
                    return x - y;
                case 0x3: 
                    return -x - y;
                case 0x4: 
                    return x + z;
                case 0x5: 
                    return -x + z;
                case 0x6: 
                    return x - z;
                case 0x7: 
                    return -x - z;
                case 0x8: 
                    return y + z;
                case 0x9: 
                    return -y + z;
                case 0xA: 
                    return y - z;
                case 0xB: 
                    return -y - z;
                case 0xC: 
                    return y + x;
                case 0xD: 
                    return -y + z;
                case 0xE: 
                    return y - x;
                case 0xF: 
                    return -y - z;
                default: 
                    return 0; // never happens
            }
        
        }
        
        public function grad2d(i:int, x:Number, y:Number):Number
        {
            var v:Number = (i & 1) === 0 ? x : y;
            return (i & 2) === 0 ? -v : v;
        }
        
        public function grad1d(i:int, x:Number):Number
        {
            return (i & 1) === 0 ? -x : x;
        }
        
        public function lerp(t:Number, a:Number, b:Number):Number
        {
            return a + t * (b - a);
        }
    }
    
    
    //MARSAGLIA
    
    class Marsaglia
    {
        
        // Pseudo-random generator
        private var z:int;
        private var w:int;
        public function Marsaglia(i1:Number, i2:Number)
        {
            // from http://www.math.uni-bielefeld.de/~sillke/ALGORITHMS/random/marsaglia-c
            z = i1 || 362436069
            w = i2 || 521288629;
        
        }
        
        public function nextInt():int
        {
            z = (36969 * (z & 65535) + (z >>> 16)) & 0xFFFFFFFF;
            w = (18000 * (w & 65535) + (w >>> 16)) & 0xFFFFFFFF;
            return (((z & 0xFFFF) << 16) | (w & 0xFFFF)) & 0xFFFFFFFF;
        }
        
        public function nextDouble():Number
        {
            var i:Number = nextInt() / 4294967296.0;
            return i < 0 ? 1 + i : i;
        }
        
        public static function createRandomized():Marsaglia
        {
            var now:int = new Date().getTime();
            return new Marsaglia((now / 60000) & 0xFFFFFFFF, now & 0xFFFFFFFF);
        }
    
    }
    
    
    //NOISE
    class Noise
    {
        
        //private static var undef:Object=new Object();
        
        // Noise functions and helpers
        
        // processing defaults
        public static var noiseProfile:Object = {generator: null, octaves: 4, fallout: 0.5, seed: null};
        
        /**
         * Returns the Perlin noise value at specified coordinates. Perlin noise is a random sequence
         * generator producing a more natural ordered, harmonic succession of numbers compared to the
         * standard random() function. It was invented by Ken Perlin in the 1980s and been used since
         * in graphical applications to produce procedural textures, natural motion, shapes, terrains etc.
         * The main difference to the random() function is that Perlin noise is defined in an infinite
         * n-dimensional space where each pair of coordinates corresponds to a fixed semi-random value
         * (fixed only for the lifespan of the program). The resulting value will always be between 0.0
         * and 1.0. Processing can compute 1D, 2D and 3D noise, depending on the number of coordinates
         * given. The noise value can be animated by moving through the noise space as demonstrated in
         * the example above. The 2nd and 3rd dimension can also be interpreted as time.
         * The actual noise is structured similar to an audio signal, in respect to the function's use
         * of frequencies. Similar to the concept of harmonics in physics, perlin noise is computed over
         * several octaves which are added together for the final result.
         * Another way to adjust the character of the resulting sequence is the scale of the input
         * coordinates. As the function works within an infinite space the value of the coordinates
         * doesn't matter as such, only the distance between successive coordinates does (eg. when using
         * noise() within a loop). As a general rule the smaller the difference between coordinates, the
         * smoother the resulting noise sequence will be. Steps of 0.005-0.03 work best for most applications,
         * but this will differ depending on use.
         *
         * @param {float} x          x coordinate in noise space
         * @param {float} y          y coordinate in noise space
         * @param {float} z          z coordinate in noise space
         *
         * @returns {float}
         *
         * @see random
         * @see noiseDetail
         */
        public static function noise(x:Number, y:Number, z:Number, generator:PerlinNoise):Number
        {
            
            // if(noiseProfile.generator === undef) {
            //   // caching
            //   noiseProfile.generator = new PerlinNoise(noiseProfile.seed);
            // }
            // var generator = noiseProfile.generator;
            
            var effect:Number = 1, k:Number = 1, sum:Number = 0;
            for (var i:int = 0; i < noiseProfile.octaves; ++i)
            {
                effect *= noiseProfile.fallout;
                // Yuriedit
                // switch (arguments.length) {
                // case 2:
                //   sum += effect * (1 + generator.noise1d(k*x))/2; break;
                // case 3:
                //   sum += effect * (1 + generator.noise2d(k*x, k*y))/2; break;
                // case 4:
                sum += effect * (1 + generator.noise3d(k * x, k * y, k * z)) / 2; // break;
                // }
                k *= 2;
            }
            return sum;
        }
        
        
        /**
         * Adjusts the character and level of detail produced by the Perlin noise function.
         * Similar to harmonics in physics, noise is computed over several octaves. Lower octaves
         * contribute more to the output signal and as such define the overal intensity of the noise,
         * whereas higher octaves create finer grained details in the noise sequence. By default,
         * noise is computed over 4 octaves with each octave contributing exactly half than its
         * predecessor, starting at 50% strength for the 1st octave. This falloff amount can be
         * changed by adding an additional function parameter. Eg. a falloff factor of 0.75 means
         * each octave will now have 75% impact (25% less) of the previous lower octave. Any value
         * between 0.0 and 1.0 is valid, however note that values greater than 0.5 might result in
         * greater than 1.0 values returned by noise(). By changing these parameters, the signal
         * created by the noise() function can be adapted to fit very specific needs and characteristics.
         *
         * @param {int} octaves          number of octaves to be used by the noise() function
         * @param {float} falloff        falloff factor for each octave
         *
         * @see noise
         */
        public static function noiseDetail(octaves:int, fallout:Number):void
        {
            noiseProfile.octaves = octaves;
            if (!isNaN(fallout))
            {
                noiseProfile.fallout = fallout;
            }
        }
        
        
        /**
         * Sets the seed value for noise(). By default, noise() produces different results each
         * time the program is run. Set the value parameter to a constant to return the same
         * pseudo-random numbers each time the software is run.
         *
         * @param {int} seed         int
         *
         * @returns {float}
         *
         * @see random
         * @see radomSeed
         * @see noise
         * @see noiseDetail
         */
        public static function noiseSeed(seed:Number):void
        {
            noiseProfile.seed = seed;
            noiseProfile.generator = null;
        }
    
    }
    