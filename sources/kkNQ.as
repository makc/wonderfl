package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    /**
     * ...
     * @author Thi
     * Graph v. 1.65 / 2.0
     * 
     * 
     * some expresison samples:
     * 0 + 1 - 2 * 3 / 4 ^ -5 +6143 = 0
     * -1 ^ round (x) - sin (x) + asin(x²) + (.08x² + .1x - 1)
     * 
     * pi = PI = 3.1415
     * e = E = 2.7182
     * round (x), floor (x), ceil (x)
     * log (x), exp (x)
     * sen (x) = seno (x) = sin (x)
     * cosseno (x) = cos (x)
     * tangente (x) = tangent (x) = tgt (x) = tg (x) = tan (x)
     * absoluto (x) = modulo (x) = abs (x)
     * aleatorio = random, 0 <= random > 1
     * raiz (x) = sqrt (x) = x ^ (1/2)
     * acos (x), asin (x), atan (x)
     * 
     * 
     * syntax observations:
     * a + b, a - b, a * b, a / b, a ^ b
     * a + b * c = a + (b * c)
     * a * b ^ c = a * (b ^ c)
     * a + b ^ c = a + (b ^ c)
     * a² = a ^ 2
     * a³ = a ^ 3
     * 1x = (1)x = 1(x) = (1)(x) = x(1) = (x)1 = 1 * x
     * 
     * 
     * The calculator works using 3 main functions:
     * - Translate the string to an array, so it can be read
     * - Arranje it using Reverse Polish Notation (RPN)
     * - Return the value
     * We do this for 465 x points for each function for each graph!
     * 
     * 
     * TODO:
     * The scene 1 features (add new 'function', 'var', 'graph' etc)
     * but u can transit to scene 1 by DOUBLE_CLICK
     */
    public class Main extends Sprite 
    {
        
        
        
        public var // libraly
        txt_libraly:Array = [new TextFormat("Tahoma", 16), 
        new TextFormat("Tahoma", 10)], // text libraly, like 'format, glow'
        lib:Array = ["x", 0, "y", 0]; // default libraly, like 'x = 0, y = 0'
        
        public var // proprieties
        w:Number = 465, h:Number = 465;
        
        private var 
        calc:Calculator = new Calculator();
        // calculator, who have 3 public functions: 
        // translate:Array , RPN:Array, calculate:Number
        
        private var // grid, the text border = scene 1 background
        back_lines_data:BitmapData = new BitmapData(w, h, false, 0xFFFFFF),
        back_lines:Bitmap = new Bitmap(back_lines_data, "auto", true),
        back_menu:Shape = new Shape();
        
        private var // dynamic DisplayObjects displayed in scene 0
        zero_point:Shape = new Shape(), // zero point place or direction
        ballon:Ballon = new Ballon(txt_libraly),
        ballon_delay:int = 60;
        
        public var // setup
        min:Point = new Point(-10,-10), // the initial x & y value @ graph
        max:Point = new Point(10, 10), // the final x & y value @ graph
        step:Point = new Point((max.x - min.x) / w, (max.y - min.y) / h),
        step_back_constrain:Boolean = true,
        step_back:Point = new Point(1, 1);
        public var setup:Array = 
        [w, h, min, max, step];
        
        private var // functions
        function_main:Function_, // scene 0 function
        func_delay:int = 10, // frames to graph updates when the function expression changes
        func_title_old:String = "",
        func_input_old:String = "",
        functions:Vector.<Function_> = new Vector.<Function_>(); // functions vector
        
        private var 
        graphs:Vector.<Graph> = new Vector.<Graph>(), // graphs vector
        graph_delay:int = 150; // how many times graph will update its lines (cuz the easying)
        
        
        private var 
        scene:int = 0, // scene index
        scene_transit_delay:int = 0,
        scrool_old:Array = [new Point()], // scrool old poisition
        scrool_vel:Point = new Point(), // scrool velocity
        scrool:Boolean, // is scrooling ?
        scrool_delay:int = 0; // the frames the scrool will keep scroolin' when mouse UP
        
        private var 
        menu_background_setup:Vector.<Number> = new Vector.<Number>(6, true),
        menu_background_setup2:Vector.<Number> = new Vector.<Number>(6, true);
        
        
        public function Main():void 
        {
            functions[0] = new Function_(txt_libraly); // create first func
            graphs[0] = new Graph(lib, setup); // create first graph
            function_main = functions[0]; // set that scene 0 function as index '0'
            function_main.input.text = "sin (x)" // setup the function expression; the Y is default
            
            drawBackgrounds(); // draw grid and the 'around text semi black thing'
            var g:Graphics = zero_point.graphics;
            g.beginFill(0, .1); g.drawCircle(0, 0, 4);
            zero_point.cacheAsBitmap = true;
            
            this.addChild(back_lines); // add everyone
            this.addChild(back_menu);
            this.addChild(graphs[0]);
            this.addChild(function_main);
            this.addChild(zero_point);
            this.addChild(ballon) // mousePoint or help
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); // scrooling true
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp); // scrooling false
            this.addEventListener(Event.ENTER_FRAME, ef); // alot of things
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove); 
            stage.doubleClickEnabled = true;
            stage.addEventListener(MouseEvent.DOUBLE_CLICK, mouseDouble);
        }
        
        private function drawBackgrounds():void
        {
            var vec:Vector.<Number>, vec2:Vector.<Number>;
            vec = menu_background_setup;
            vec2 = menu_background_setup2;
            updateLineBackground() // grid
            vec[0] = vec2[0] = 0;
            vec[1] = vec2[1] = 0;
            vec[2] = vec2[2] = 465;
            vec[3] = vec2[3] = 30;
            vec[4] = vec2[4] = 0;
            vec[5] = vec2[5] = 0;
            updateMenuBackground(menu_background_setup)
            
        }
        
        private function updateMenuBackground (vec:Vector.<Number> = null):void
        {
            // some trasparent background, around the text
            var 
            g:Graphics;
            g = back_menu.graphics;
            g.clear();
            g.beginFill(0, .8);
            g.drawRoundRect(vec[0], vec[1], vec[2], vec[3], vec[4], vec[5]);
            g.endFill();
            g = null;
        }
        
        private function updateLineBackground():void
        {
            // grid draw
            
            var 
            i:int = -1,
            s:Shape = new Shape(),
            g:Graphics = s.graphics;
            
            // lines
            var 
            n:Number = Math.floor(((min.x - 1) / step_back.x)) * step_back.x,
            n2:Number = w / (max.x - min.x);
            // vertical lines
            while (n <= max.x)
            {
                g.lineStyle(1, 0, .2, true);
                n += step_back.x;
                if(n == 0) g.lineStyle(2, 0, 1, true); // zero line
                g.moveTo((n - min.x) * n2, 0);
                g.lineTo((n - min.x) * n2, h);
            }
            
            // horizontal lines
            n = Math.ceil(min.y / step_back.y) * step_back.y;
            n2 = h / (max.y - min.y)
            while (n < max.y)
            {
                g.lineStyle(1, 0, .2, true);
                n += step_back.y;
                if(n == 0) g.lineStyle(2, 0, 1, true); // zero line
                g.moveTo(0,(n - min.y) * n2);
                g.lineTo(w,(n - min.y) * n2)
            }
            
            // bitmap stuff
            back_lines_data.fillRect(back_lines_data.rect, 0xFFFFFF);
            back_lines_data.draw(s);
            g.clear(); s = null;
        }
        
        private function ef(e:Event = null):void
        {
            var i:int = -1, vec:Vector.<Number>, vec2:Vector.<Number>;
            
            if (scene == 0)
            {
                
                // scene transit
                if (scene_transit_delay > 0)
                {
                    trace("hum")
                    vec = menu_background_setup;
                    vec2 = menu_background_setup2;
                    vec[0] += (vec2[0] - vec[0]) * .6
                    vec[1] += (vec2[1] - vec[1]) * .6
                    vec[2] += (vec2[2] - vec[2]) * .6
                    vec[3] += (vec2[3] - vec[3]) * .6
                    vec[4] += (vec2[4] - vec[4]) * .6
                    vec[5] += (vec2[5] - vec[5]) * .6
                    --scene_transit_delay;
                    updateMenuBackground(vec)
                    
                    if (scene_transit_delay == 0)
                    {
                        scene = 1;
                        ballon.alpha = 0;
                        return;
                    }
                } 
                
                // update function expression
                if (func_title_old != function_main.title.text || func_input_old != function_main.input.text)
                {
                    func_title_old = function_main.title.text;
                    func_input_old = function_main.input.text;
                    func_delay = 10; // waits 10 frames to update function calculations
                    function_main.update();
                }
                // we translate and RPN each function
                if (--func_delay == 0)
                {
                    var func:Function_;
                    while (++i < functions.length)
                    {
                        func = functions[i];
                        func.rpn = calc.translate(func.input.text);
                        func.preventError = calc.preventError;
                        trace("______")
                        trace(func.rpn)
                        func.rpn = calc.RPN(func.rpn, func.preventError);
                        trace(func.rpn);
                        trace("______");
                        lib[1] = 0;
                        lib [3] = 0;
                        ballon.title.text = func.title.text +": " + calc.calculate(func.rpn, lib);
                        ballon.alpha = 1;
                        ballon_delay = 59;
                    }
                    
                    // clear graphs, and activate it 'draw' boolean
                    graph_delay = 150;
                    clearGraphs()
                    // now we start to (calculate functions) (update graphs points)
                    drawGraphs();
                }
                
                // we draw the shape lines, 
                // if the delay is > 0 and if its not scrooling 
                if (!scrool || scrool_delay <= 0) lineGraphs();
                
                // scrooling
                moveLineBackroung()
                
                var // some relation numbers
                a:Number = 0, b:Number = 0,
                c:Number = - (min.x / step.x), d:Number = - (min.y / step.y);
                a = c; b = d;
                
                // zero point
                if (a < 10) a = 10;
                if (a > w - 10) a = w - 10;
                if (b < 40) b = 40;
                if (b > h - 10) b = h - 10;
                zero_point.x = a;
                zero_point.y = b;
                
                // ballon (x:0, y:0)
                if (--ballon_delay < 0)
                {
                    ballon.alpha *= .9;
                }
                ballon.target.x = mouseX;
                ballon.target.y = mouseY;
                if (ballon_delay == 59)
                {
                    ballon.title.text = "x: " + Math.round((mouseX - c) * step.x * 10)/10 + 
                "\ny: " + Math.round(-( (mouseY - d) * step.y)*10)/10;
                }
                ballon.update();
                ballon.move();
                
                
            } else if (scene == 1)
            {
                // scene transit
                if (scene_transit_delay > 0)
                {
                    trace("hum")
                    vec = menu_background_setup;
                    vec2 = menu_background_setup2;
                    vec[0] += (vec2[0] - vec[0]) * .6
                    vec[1] += (vec2[1] - vec[1]) * .6
                    vec[2] += (vec2[2] - vec[2]) * .6
                    vec[3] += (vec2[3] - vec[3]) * .6
                    vec[4] += (vec2[4] - vec[4]) * .6
                    vec[5] += (vec2[5] - vec[5]) * .6
                    --scene_transit_delay;
                    updateMenuBackground(vec)
                    
                    if (scene_transit_delay == 0)
                    {
                        scene = 0;
                        ballon.alpha = 0;
                        return;
                    }
                }
            }
            
        }
        
        private function clearGraphs():void
        {
            // clear graphs, and activate it 'draw' boolean
            var i:int = -1;
            while (++i < graphs.length)
            {
                graphs[i].clear();
                graphs[i].cacheAsBitmap = false;
            }
        }
        
        private function drawGraphs():void
        {
            // calculate functions, update graphs points
            var 
            X:Number = min.x, graph:Graph, i:int, a:int = -1, func:Function_;
            while ((X += step.x) < max.x) // 465 loops
            {
                updateLibraly("x", X);
                i = -1;
                while (++i < functions.length) // function loops
                {
                    func = functions[i];
                    updateLibraly(func.title.text, calc.calculate(func.rpn, lib) );
                }
                i = -1;
                while (++i < graphs.length) // graphics loops
                {
                    graph = graphs[i];
                    graph.update();
                }
            }
        }
        
        private function lineGraphs(delay:Number = .3):void
        {
            // the shape lines drawing
            var i:int;
            if (-- graph_delay > 0)
            {
                i = -1;
                while (++i < graphs.length)
                {
                    graphs[i].clear();
                    graphs[i].line(delay);
                }
                if (graph_delay == 1)
                {
                    i = -1;
                    while (++i < graphs.length)
                    {
                        // its the last 'draw lines', so we cache as bitmap
                        graphs[i].cacheAsBitmap = true;
                    }
                }
            }
        }
        
        private function updateLibraly(item:String, value:Number):void
        {
            var i:int = -1;
            while (++i < lib.length)
            {
                if (item == lib[i])
                {
                    lib[++i] = value;
                    return;
                }
                ++i;
            }
        }
        
        private function moveLineBackroung():void
        {
            var i:int = -1;
            if (scrool)
            {
                // velocity
                scrool_vel.x = (scrool_old[0].x - mouseX) * (max.x - min.x) / w;
                scrool_vel.y = (scrool_old[0].y - mouseY) * (max.y - min.y) / h;
                scrool_old[0].x  = mouseX
                scrool_old[0].y  = mouseY                
                
                // position
                min.x += scrool_vel.x;
                max.x += scrool_vel.x;
                min.y += scrool_vel.y;
                max.y += scrool_vel.y;
                step.x = (max.x - min.x) / w;
                step.y =  (max.y - min.y) / h;
                setup[2] = min;
                setup[3] = max;
                setup[4] = step;
                
                // functions that update graphs, considerating the scrooling
                scroolGraphs()
                
            } else if (-- scrool_delay > 0)
            {
                // mouseUp has been fired, but it has an delay, and keeps drawing
                min.x += scrool_vel.x *= .6;
                max.x += scrool_vel.x;
                min.y += scrool_vel.y *= .6;
                max.y += scrool_vel.y;
                step.x = (max.x - min.x) / w;
                step.y =  (max.y - min.y) / h;
                setup[2] = min;
                setup[3] = max;
                setup[4] = step;
                
                //
                
                // functions that update graphs, considerating the scrooling
                scroolGraphs()
            }
        }
        
        private function scroolGraphs():void
        {
            // we do some functions, considering the scrool
            updateLineBackground() // back has scrooled..
            var i :int = -1;
            while (++i < graphs.length)
            {
                // the setup has been changed, so we send the new one
                graphs[i].updateSetup(setup); 
            }
            clearGraphs();
            
            graph_delay = 10;
            drawGraphs();
            lineGraphs(1); // instant shape lines delay
        }
        
        private function mouseDown(e:MouseEvent):void
        {
            if(scene == 0 && mouseY > 30)
            {
                scrool_old[0].x = mouseX
                scrool_old[0].y = mouseY
                scrool = true;
            }
        }
        
        private function mouseUp(e:MouseEvent):void
        {
            if (scene == 0)
            {
                scrool = false;
                scrool_delay = 10;
            }
        }
        
        private function mouseMove(e:MouseEvent):void
        {
            if (scene == 0)
            {
                ballon.alpha = 1;
                ballon_delay = 60;
            }
            
        }
        
        private function mouseDouble(e:MouseEvent):void
        {
            trace("DOUBLE")
            var vec:Vector.<Number>, vec2:Vector.<Number>;
            // scene transit
            if (scene == 0)
            {
                vec2 = menu_background_setup2
                vec2[0] = 5;
                vec2[1] = 5;
                vec2[2] = 455;
                vec2[3] = 425;
                vec2[4] = 10;
                vec2[5] = 10;
                scene_transit_delay = 10;
                
                this.addChildAt(back_menu, graphs.length +2 );
                
            } else
            {
                vec2 = menu_background_setup2
                vec2[0] = 0;
                vec2[1] = 0;
                vec2[2] = 465;
                vec2[3] = 30;
                vec2[4] = 0;
                vec2[5] = 0;
                scene_transit_delay = 10;
                
                this.addChildAt(back_menu, 2 );
            }
        }
        
    }    
}


//package  
//{
    import flash.display.Sprite;
import flash.display.Shape
import flash.text.TextField;
import flash.display.Graphics;
import flash.text.TextFieldAutoSize;
import flash.geom.Point;
    /**
     * ...
     * @author Thi
     */
    /*public*/ class Calculator
{
    public var 
    lib:Array, preventError:Boolean;
    
    private var 
    char:String, // used by several methods
    e2:Array, e3:Array; // arrays, used by the #2 method
    
    public function translate(expression:String = null):Array
    {
        var 
        // storage
        s:String = expression,
        e:Array = [], num:Array = [], 
        // loops
        i:int = 0, j:int = 0, 
        // Other
        length:int = s.length, last:String = "";
        char = "";
        
        
        preventError = false;
        
        while ( i < length)
        {
            char = s.charAt(i);
            if (Number(char) || char == "0")
            {
                // whos 'is' in the left of the char
                last = e[e.length - 1];
                if (last == ")")
                {
                    e.push("*");
                }
                
                // we build the number, by each character
                j = i;
                while (Number(char) || char == "," || char == "." || char == "0") 
                {
                    num.push(char)
                    ++j
                    char = s.charAt(j)
                }
                if (last == "-")
                {
                    last = e[e.length - 2];
                    if (last == "+" || last == "-" || last == "*" || last == "/" || last == "^" ||
                    last == "(" || last == null)
                    {
                        // 2,*,-,1 -> 2,*,-1
                        e[e.length-1] = String(0-Number(num.join("")));
                    } else
                    {
                        e.push(num.join(""));
                    }
                } else
                {
                    e.push(num.join(""));
                }
                num = [];
                i = j-1;
                j = 0;
                
            } else if (char == "*" || char == "+" || char == "-" || char == "/" || char == "^") 
            {
                // push all operators
                e.push(char);
                
            } else if (char == "." || char == ",")
            {
                // create a decimal, example: .2 -> 0.2
                num.push("0");
                num.push(".");
                //
                j = i;
                if (Number(char) || char == "0")
                {
                    while (Number(char) || char == "0")
                    {
                        num.push(char);
                        ++j;
                        char = s.charAt(j);
                    }
                    e.push(num.join(""));
                    i = j - 1;
                    num = [];
                    j = 0;
                }
                
            } else if (char == "(" || char == "[" || char == "{")
            {
                preventError = true
                // take the last element
                last = e[e.length - 1]
                /*if (last != "+" && last != "-" && last != "*" && last != "/" && last != "^" && 
                last != "undefined" && last != null && last != "sin" && last != "cos" && 
                last != "tan" && last != "log" && last != "e" && last != "pi" && last != "asin" &&
                last != "acos" && last != "atan" && last != "random" && last != "round" && last != "floor" && 
                last != "ceil" && last != "exp" && last != "sqrt" && last != "abs")*/
                
                // if last cahr is different of an operator or 'function that uses ()'
                if (last != "+" && last != "-" && last != "*" && last != "/" && last != "^" && 
                last != "undefined" && last != null && last != "sin" && last != "cos" && 
                last != "tan" && last != "log" && last != "asin" &&    last != "acos" && 
                last != "atan" && last != "round" && last != "floor" && 
                last != "ceil" && last != "exp" && last != "sqrt" && last != "abs")
                
                {
                    // add an multiplication
                    e.push("*")
                }
                e.push("(")
                // 2(x -> 2 * (x
                
            } else if (char == "²")
            {
                // ² -> ^ 2
                e.push("^")
                e.push("2")
                
            } else if (char == "³")
            {
                // ³ -> ^ 3
                e.push("^")
                e.push("3")
                
            } else if (char == ")" || char == "]" || char == "}")
            {
                // )]} -> )))
                e.push(")")
                
            } else if (char != " ")
            {
                last = e[e.length -1]
                if (last != "+" && last != "-" && last != "*" && last != "/" && last != "^" && 
                last != "undefined" && last != null && last != "(")  
                {
                    // add an multiply
                    e.push("*")
                    // y x -> y * x
                }
                j = i
                while (char != "," && char != "." && char != "+" && char != "-" && char != "*" && char != "/" && char != "^" && char != "(" && char != "[" && char != "{" && char != ")" && char != "]" && char != "}" && char != " " && char != null && char != "undefined" && char != "" && char != "²" && char != "³") 
                {
                    num.push(char)
                    ++j;
                    char = s.charAt(j)
                }
                // we just formed an word, char by char.
                
                var temp:String = num.join("")
                if (temp == "sen" || temp == "seno")
                {
                    temp = "sin"
                } else if (temp == "cosseno")
                {
                    temp = "cos"
                } else if (temp == "tangent" || temp == "tangente" || temp == "tgt" || temp == "tg")
                {
                    temp = "tan"
                } else if (temp == "E")
                {
                    temp = "e"
                } else if (temp == "PI")
                {
                    temp = "pi"
                } else if (temp == "absoluto" || temp == "modulo")
                {
                    temp = "abs"
                } else if (temp == "aleatorio")
                {
                    temp = "random"
                } else if (temp == "raiz")
                {
                    temp = "sqrt"
                }
                e.push(temp)
                num = []
                temp = ""
               i = j-1
            }
            ++i
        }
        return e;
    }
    
    public function RPN(elements:Array = null, PreventError:Boolean = false):Array
    {
        e2 = []; // temp elements
        e3 = []; // final (returned) elements
        char = "";
        
        var
        e:Array = elements.concat(), // initial elements
        i:int = 0, j:int = 0,
        length:int = e.length;
        preventError = PreventError;
        
        while (i < length)
        {
            char = e[i];
            if (Number(char) || char == "0")
            {
                e3.push(char)
            } else if (char == "(")
            {
                e2.push(char)
            } else if (char == "+" || char == "-" || char == "*" || char == "/" || char == "^" || 
            char == "sin" || char == "cos" || char == "tan" || char == "acos" || char == "asin" || 
            char == "atan" || char == "round" || char == "floor" || 
            char == "ceil" || char == "log" || char == "exp" || char == "sqrt" || char == "abs"  )
            {
                e2.push(char)
                // call a function that organizes the order
                OperatorLevel() // send the e2 and e3 local vars
            }  else if (char == ")")
            {
                e2.push(char)
                CloseParantesis()
            } else
            {    
                e3.push(char)
            }
            ++i
        }
        
        // now add 'calculation' array (reverse) to the result array
        j = e2.length
        while (j > 0)
        {
            if (e2[j - 1] != "")
            {
                e3.push(e2[j-1])
            }
            --j
        }
        
        return e3;
    }
    
    private function OperatorLevel():void
    {
        var 
        level1:int, level2:int;
        
        if (char == "+" || char == "-") 
        {
            level1 = 1;
        } else if (char == "*" || char == "/") 
        {
            level1 = 2;
        } else if (char == "^")
        {
            level1 = 4;
        } else if (char == "sin" || char == "cos" || char == "tan" || char == "asin" || 
        char == "acos" || char == "atan" || char == "round" || char == "floor" || char == "ceil" ||
        char == "log" || char == "exp" || char == "sqrt" || char == "abs")
        {
            level1 = 8
        }
        if (e2[e2.length - 2] == "+" || e2[e2.length - 2] == "-") 
        {
            level2 = 1;
        } else if (e2[e2.length - 2] == "*" || e2[e2.length - 2] == "/") 
        {
            level2 = 2;
        } else if (e2[e2.length - 2] == "^") 
        {
            level2 = 3;
        } else if (e2[e2.length - 2] == "sin" || e2[e2.length - 2] == "cos" || e2[e2.length - 2] == "tan" ||
        e2[e2.length - 2] == "asin" || e2[e2.length - 2] == "acos" || e2[e2.length - 2] == "atan" ||
        e2[e2.length - 2] == "round" || e2[e2.length - 2] == "floor" || e2[e2.length - 2] == "ceil" ||
        e2[e2.length - 2] == "log" || e2[e2.length - 2] == "exp" || e2[e2.length - 2] == "sqrt" ||
        e2[e2.length - 2] == "abs")
        {
            level2 = 4;
        } else 
        {
            level2 = 0;
        }
        if (level1 <= level2) 
        {
            e3.push(e2[e2.length-2]);
            e2.splice(e2.length - 2, 1);
            // repeats
            OperatorLevel();
        }
    }
    
    private function CloseParantesis():void
    {
        if (e2[e2.length - 2] != "(")
        {
            e3.push(e2[e2.length - 2])
            e2.splice(e2.length - 2, 1)
            if (preventError)
            {
                CloseParantesis();
            }
        } else 
        {
            e2.splice(e2.length-2,2)
        }
    }
    
    public function calculate(elements:Array = null, libraly:Array = null):Number
    {
        var
        e:Array = elements.concat(),
        n0:Boolean, n1:Boolean,
        i:int, j:int, lib:Array = libraly.concat(),
        num:Number;
        char = "";
        
        while (i < e.length)
        {
            char = e[i];
            //{
                
                if (char == "+")
                {
                    e[i] = Number(e[i - 2]) + Number(e[i - 1]);
                    e.splice(i - 2, 2);
                    --i; --i;
                } else if (char == "-")
                {
                    if (Number(e[i - 2]))
                    {
                        e[i] = Number(e[i - 2]) - Number(e[i - 1]);
                        e.splice(i - 2, 2);
                    } else
                    {
                        e[i] = - Number(e[i - 1]);
                        e.splice(i - 1, 1);
                    }
                    --i; --i;
                } else if (char == "*")
                {
                    e[i] = Number(e[i - 2]) * Number(e[i - 1]);
                    e.splice(i - 2, 2);
                    --i; --i;
                } else if (char == "/")
                {
                    e[i] = Number(e[i - 2]) / Number(e[i - 1]);
                    e.splice(i - 2, 2);
                    --i; --i;
                } else if (char == "^")
                {
                    e[i] = Math.pow(Number(e[i - 2]) , Number(e[i - 1]));
                    e.splice(i - 2, 2);
                    --i; --i;
                } else if (!Number(char) && char != "0")
                {
                    if (char == "sin")
                    {
                        e[i] = Math.sin(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "cos")
                    {
                        e[i] = Math.cos(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "tan")
                    {
                        e[i] = Math.tan(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "asin")
                    {
                        num = Number(e[i - 1]);
                        if (num * num <= 1)
                        {
                            e[i] = Math.asin( num );
                        } else
                        {
                            e[i] = 0;
                        }
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "acos")
                    {
                        num = Number(e[i - 1]);
                        if (num * num <= 1)
                        {
                            e[i] = Math.acos( num );
                        } else
                        {
                            e[i] = 0;
                        }
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "atan")
                    {
                        e[i] = Math.atan(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "random")
                    {
                        e[i] = Math.random();
                        --i;
                    } else if (char == "pi")
                    {
                        e[i] = Math.PI;
                        --i;
                    } else if (char == "e")
                    {
                        e[i] = Math.E;
                        --i;
                    } else if (char == "round")
                    {
                        e[i] = Math.round(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "floor")
                    {
                        e[i] = Math.floor(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "ceil")
                    {
                        e[i] = Math.ceil(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "log")
                    {
                        e[i] = Math.log(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "exp")
                    {
                        e[i] = Math.exp(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "sqrt")
                    {
                        e[i] = Math.sqrt(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else if (char == "abs")
                    {
                        e[i] = Math.abs(Number(e[i - 1]));
                        e.splice(i - 1, 1);
                        --i;
                    } else
                    {
                        // ITS A WORD, we search in the libraly for it
                        //var found:Boolean;
                        j = 0;
                        while (j < lib.length)
                        {
                            if (char == lib[j])
                            {
                                e[i] = lib[++j]
                                --i
                                //found = true;
                                break;
                            }
                            ++j; ++j;
                        }
                        // the index of the value has been found (j)    
                        if (j == 0 && lib[0] != char)
                        {
                            ++i
                        }
                        /*if (!found) 
                        {
                            trace("POHA");
                            return NaN;
                        }*/
                    }
                    
                    
                    
                    
                } 
                
                ++i
                if (e.length == 1)
                {
                    return Number(e[0]);
                }
                
                
                
            /*} else
            {
                
            }*/
            
            
            
            
            
        }
        
        return 0;
        
        
    }
    
}
//}


//package  
//{
    import flash.display.Sprite;
import flash.display.Shape
import flash.text.TextField;
import flash.display.Graphics;
import flash.text.TextFieldAutoSize;
import flash.geom.Point;
    /**
     * ...
     * @author Thi
     */
    /*public*/ class Function_ extends Sprite
{
    public var 
    title:TextField = new TextField(),
    input:TextField = new TextField(),
    symbol:TextField = new TextField(),
    rpn:Array, preventError:Boolean;
    
    private var 
    lib:Array;
    
    public function Function_(lib:Array):void
    {
        this.lib = lib;
        this.addChild(title);
        this.addChild(input);
        this.addChild(symbol);
        
        title.defaultTextFormat = lib[0];
        title.type = "input";
        title.text = "y";
        title.autoSize = TextFieldAutoSize.LEFT;
        title.width = title.width;
        title.autoSize = TextFieldAutoSize.NONE;
        title.textColor = 0xFFFFFF;
        title.multiline = false;
        
        symbol.defaultTextFormat = lib[0];
        symbol.selectable = false;
        symbol.text = "=";
        symbol.autoSize = TextFieldAutoSize.LEFT;
        symbol.width = symbol.width;
        symbol.autoSize = TextFieldAutoSize.NONE;
        symbol.textColor = 0xFFFFFF;
        
        input.defaultTextFormat = lib[0];
        input.type = "input";
        input.text = "x";
        input.autoSize = TextFieldAutoSize.LEFT;
        input.width = input.width;
        input.autoSize = TextFieldAutoSize.NONE;
        input.textColor = 0xFFFFFF;
        title.multiline = false;
        
        if (title.width < 10) title.width = 10;
        if (title.width > 435 - symbol.width) title.width = 435 - symbol.width;
        symbol.x = title.width + 10;
        input.x = symbol.x + symbol.width + 10;
        input.width = 465 - input.x + input.width;
    }
    
    public function update():void
    {
        var w:Number;
        title.autoSize = TextFieldAutoSize.LEFT;
        w = title.width;
        title.autoSize = TextFieldAutoSize.NONE;
        title.width = w;
        if (title.width < 10) title.width = 10;
        if (title.width > 435 - symbol.width) 
        {
            title.width = 435 - symbol.width; 
        }
        symbol.x = title.width + 10;
        input.x = symbol.x + symbol.width + 10;
        input.width = 465 - input.x + input.width;
    }
}
//}


//package  
//{
    import flash.display.Sprite;
    import flash.display.Shape
    import flash.text.TextField;
    import flash.display.Graphics;
    import flash.text.TextFieldAutoSize;
    import flash.geom.Point;
    /**
     * ...
     * @author Thi
     */
    /*public*/ class Graph extends Shape
{
    public var
    color:uint = 0xFF0000,
    g:Graphics,
    X:String = "x", Y:String = "y";
    
    private var 
    points:Vector.<Point> = new Vector.<Point>(465, true),
    points2:Vector.<Point> = new Vector.<Point>(465, true),
    j:int;
    
    private var 
    lib:Array, setup:Array;
    
    private var 
    w:Number,
    h:Number,
    min:Point,
    max:Point,
    step:Point;
    
    public function Graph(libraly:Array = null, setup:Array = null):void
    {
        g = this.graphics;
        g.lineStyle(1, color);
        this.lib = libraly;
        this.setup = setup;
        updateSetup(setup);
        j = -1;
        while (++j < 465)
        {
            points[j] = new Point();
            points2[j] = new Point();
        }
    }
    
    public function update():void
    {
        //trace(j);
        ++j;
        points[j].x = search(X);
        points[j].y = search(Y);
    }
    
    public function line(delay:Number = .3):void
    {
        var a:Number = 0, b:Number = 0,
        c:Number = min.x / step.x, d:Number = min.y / step.y;
        j = 0;
        
        // the first point
        a = (points2[0].x += (points[0].x - points2[0].x) * delay) / step.x - c;
        b = -((points2[0].y += (points[j].y - points2[j].y) * delay) / step.y + d);
        if (a < 0) a = -1;
        if (a > w) a = w + 1;
        if (b < 0) b = -1;
        if (b > h) b = h + 1;
        g.moveTo(a, b);
        
        // other points
        while (++j < 465)
        {
            a = points2[j].x += (points[j].x - points2[j].x) * delay; // easying
            b = points2[j].y += (points[j].y - points2[j].y) * delay;
            if (a == Infinity || b == Infinity) continue;
            a = a / step.x - c;
            b = -(b / step.y + d)
            if (a < 0) a = -1; // dont line outside the corners.
            if (a > w) a = w + 1;
            if (b < 0) b = -1;
            if (b > h) b = h + 1;
            g.lineTo(a, b);
        }
    }
    
    public function clear():void
    {
        j = -1;
        g.clear();
        g.lineStyle(1, color);
    }
    
    private function search(item:String = null):Number
    {
        var i:int = -1;
        while (++i < lib.length)
        {
            if (item == lib[i])
            {
                if (Number(lib[++i])) 
                {
                    if ((lib[i]) == -Infinity )
                    {
                        return Infinity;
                    }
                    return lib[i];
                }
                return 0;
            }
            ++i;
        }
        if (Number (item)) return Number(item);
        return 0;
    }
    
    public function updateSetup(Setup:Array = null):void
    {
        this.setup = Setup;
        w = setup[0],
        h = setup[1],
        min = setup[2],
        max = setup[3],
        step = setup[4];
    }
}
//}


//package  
//{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    /**
     * ...
     * @author Thi
     */
    /*public*/ class Ballon extends Sprite
    {
        private var lib:Array;
        public const title:TextField = new TextField();
        
        private var 
        X:Number = 0, Y:Number = 0,
        w:Number = 465, h:Number = 465;
        
        public var target:Point = new Point();
        
        public function Ballon(lib:Array = null) 
        {
            this.lib = lib;
            
            var g:Graphics = this.graphics;
            title.defaultTextFormat = lib[1];
            title.selectable = false;
            title.text = "Hello, I'm ballon";
            title.autoSize = TextFieldAutoSize.LEFT;
            title.textColor = 0xFFFFFF;
            this.addChild(title);
        }
        
        public function move():void
        {
            this.x += (target.x - this.x) * .5
            this.y += (target.y - this.y) * .5
        }
        
        public function update():void
        {
            
            if (target.x + title.width + 17 > w)
            {
                target.x = (target.x - title.width ) - 17
            } else
            {
                target.x += 15;
            }
            if (target.y + title.height + 17 > h)
            {
                target.y = (target.y - title.height) - 17
            } else
            {
                target.y += 15;
            }
            
            if (target.x < 2)
            {
                target.x = 2;
            } else if (target.x + title.width > w)
            {
                target.x = w - title.width;
            }
            if (target.y < 32)
            {
                target.y = 32;
            } else if (target.y + title.height > h)
            {
                target.y = h - title.height;
            }
            
            var g:Graphics = this.graphics;
            g.clear();
            g.beginFill(0x000000, .8);
            g.drawRoundRect( -2, -2, title.width + 4, title.height + 4, 10, 10);
            g.endFill();
        }    
    }
//}