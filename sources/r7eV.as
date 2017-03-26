/*
  3Dグラフを絵画します。
  使い方については、?ボタンを押してください。
  文字列で入力した数式の処理に四苦八苦しました。
*/
package {
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    [SWF(width = 465, height = 465, backgroundColor = 0x000000, frameRate = 30)]
    
    public class Graph extends Sprite {
        
        private const graph:Sprite = new Sprite();
        private const ggraph:Graphics = graph.graphics;
        private const forms:Sprite = new Sprite();
        private const form:KInput = new KInput(425, 16);
        private const smplButton:KButton = new KButton("Sample", 11);
        private const smplPanel:Sprite = new Sprite();
        private const gsmplPanel:Graphics = smplPanel.graphics;
        private const help:Sprite = new Sprite();
        
        public function Graph():void {
            
            // サムネ用
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 475, 475);
            graphics.endFill();
            
            // いろいろフォームの追加
            createForm();
            
            // ドラッグ
            stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
            stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
            
            // スプライトの追加
            stage.addChild(graph);
            stage.addChild(forms);
            
            // デモ
            formUpdate();
            
        }
        
        private function createForm():void {
            
            // 入力フォームの設置
            form.x = 20; form.y = 430; form.text = "{ e^(-10x^2) + e^(-10y^2) } / 3"; forms.addChild(form);
            form.input.addEventListener(KeyboardEvent.KEY_DOWN, formUpdate);
            
            var btn:KButton;
            
            // 勝手に回転ボタン
            btn = new KButton("Auto rotate", 11);
            btn.x = 40; btn.y = 408;
            btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                if (nowRotate) stage.removeEventListener(Event.ENTER_FRAME, autoRotate);
                else stage.addEventListener(Event.ENTER_FRAME, autoRotate);
                nowRotate = !nowRotate;
            });
            forms.addChild(btn);
            
            // サンプルボタン
            smplButton.x = 110; smplButton.y = 408;
            smplButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                smplPanel.visible = !smplPanel.visible;
            });
            forms.addChild(smplButton);
            
            // サンプルパネル
            gsmplPanel.beginFill(0x000000);
            gsmplPanel.drawRect(-3, -3, 101, 21);
            gsmplPanel.lineStyle(1, 0x333333);
            for (var i:uint = 0,panel:Sprite; i < 5; i++) {
                panel = new Sprite();
                panel.graphics.lineStyle(1, 0x555555);
                panel.graphics.beginFill(0x222222 * i);
                panel.graphics.drawRect(20 * i, 0, 15, 15);
                panel.buttonMode = true;
                panel.name = "sample" + i;
                panel.addEventListener(MouseEvent.CLICK, showSample);
                smplPanel.addChild(panel);
            }
            smplPanel.x = 160; smplPanel.y = 408; smplPanel.visible = false;
            forms.addChild(smplPanel);
            
            // ヘルプ画面
            writeHelp();
            help.visible = false;
            forms.addChild(help);
            
            // ヘルプ
            btn = new KButton("?", 11);
            btn.x = 20; btn.y = 408;
            btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                help.visible = !help.visible;
            });
            forms.addChild(btn);
            
        }
        
        private function writeHelp():void {
            
            help.graphics.beginFill(0x000000, 0.85);
            help.graphics.drawRect(0, 0, 465, 465);
            
            var makeText:Function = function(text:String, x:Number, y:*, size:uint = 12, align:String = "left"):TextField {
                var tfmt:TextFormat = new TextFormat("_ゴシック", size, 0xaaaaaa);
                tfmt.leading = 4; tfmt.align = align;
                var t:TextField = new TextField(); t.defaultTextFormat = tfmt;
                t.autoSize = "left"; t.type = "dynamic";
                t.text = text; t.x = x; t.y = (y is uint) ? y : y.value;
                if(!(y is uint)) y.value += (size + 5) * (text.match(/\n/g).length + 1) + 2;
                return t;
            }
            
            var y:Object = { value:10 };
            
            help.addChild(makeText("概要", 10, y, 15));
            help.addChild(
                makeText("z = f(x, y) の形で書かれた方程式を、3Dで画面に表示します。\n" +
                            "-1≦x≦1, -1≦y≦1 の範囲で絵画します。\n"+
                            "実際の数学の式の書き方に対応するよう、心がけました。\n", 25, y)
            );
            
            help.addChild(makeText("機能", 10, y, 15));
            help.addChild(
                makeText("しばらく使って頂ければ、分かるかと思います。\n", 25, y)
            );
            
            help.addChild(makeText("対応している演算子など", 10, y, 15));
            help.addChild(
                makeText("加算\n減算\n乗算\n除算\n累乗\n関数", 25, y.value, 12)
            );
            help.addChild(
                makeText("括弧\n定数", 230, y.value, 12)
            );
            help.addChild(
                makeText("( ), { }, [ ]\ne, pi", 265, y.value, 12)
            );
            help.addChild(
                makeText("+\n-\n*\n/\n^\nsin, cos, tan, asin, acos, atan,\nlog, sqrt, abs", 60, y, 12)
            );
            
            help.addChild(makeText("Tips", 10, y, 15));
            help.addChild(
                makeText("・関数のあとの()は省略できます\n" +
                            "・乗算の記号*は、適宜省略できます\n" +
                            "　　　また、それを一塊として解釈します\n\n" +
                            "　　　累乗の直前のみ例外です", 25, y.value)
            );
            help.addChild(
                makeText("sinx == sin(x)\n" +
                            "xy == x*y, (x+y)(y+2) == (x+y)*(y+2)\n" +
                            "sinxy == sin(x*y)\ncf)  sinx*y == (sinx)*y\n" +
                            "2x^2 == 2*(x^2)" , 225, y)
            );
            
        }
        
        private const samples:Array = [
            "sqrt( 1 - x^2 - y^2 )",
            "(x^2+y^2-0.3) (x^2+y^2-1.2) (x^2+y^2-1.6)",
            "log( absexy + 1 )" ,
            "sin2pi(x^2 + y^2) / 6",
            "{ 3(cos0.5pix * cos0.5piy) + abs ( sin2pix * sin2piy ) } / 4"
        ];
        private function showSample(e:MouseEvent):void {
            
            smplPanel.visible = false;
            form.text = samples[e.target.name.match(/\d/)];
            formUpdate();
            
        }
        
        private var nowRotate:Boolean = false;
        private var frameCount:uint = 0;
        private function autoRotate(e:Event):void {
            
            if (++frameCount != (frameCount %= 2)) {
                angZ += Math.PI / 180; createGraph();
            }
            
        }
        
        private var mX:Number = 0;
        private var mY:Number = 0;
        private function beginDrag(e:MouseEvent):void {
            
            // サンプルを消す
            if(e.target != smplButton && e.target != smplPanel && e.target.parent != smplPanel) smplPanel.visible = false;
            
            // 入力フォーム付近なら、return
            if (mouseY > 400) return;
            
            // 自動回転を止める
            if(nowRotate) stage.removeEventListener(Event.ENTER_FRAME, autoRotate);
            
            mX = mouseX; mY = mouseY;
            preangX = angX; preangZ = angZ;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, alterAngle);
            
        }
        private function alterAngle(e:MouseEvent):void {
            
            angZ = preangZ - (mouseX - mX) / 465 * Math.PI * 1;
            angX = Math.max( -Math.PI / 2, Math.min(Math.PI / 2, preangX - (mouseY - mY) / 465 * Math.PI * 1));
            createGraph();
            
        }
        private function endDrag(e:MouseEvent):void {
            
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, alterAngle);
            
            // 自動回転を再開
            if(nowRotate) stage.addEventListener(Event.ENTER_FRAME, autoRotate);
            
        }
        
        private const zs:Array = new Array();
        private function formUpdate(e:KeyboardEvent = null):void {
            
            //var t:Number = new Date().getTime();
            
            // エンターキーのみ
            if(e != null) if (e.keyCode != 13) return;
            
            // 関数作成
            var func:Function = createFunction(form.text);
            if (func == null) return;
            
            // z座標計算
            while (zs.pop()) { };
            var x:Number, y:Number, z:Array;
            for (x = -1; x <= 1; x += 1 / 32) {
                zs.push(z = []);
                for (y = -1; y <= 1; y += 1 / 32) {
                    z.push( { x:x, y:y, z:func(x, y) } );
                }
            }
            
            // グラフ作成
            createGraph();
            
            //trace(new Date().getTime() - t);
            
        }
        
        private var preangZ:Number;
        private var preangX:Number;
        private var angZ:Number = Math.PI / 12;
        private var angX:Number = -Math.PI / 6;
        private var screenY:Number = -1.5;
        private var cameraY:Number = -4;
        private function createGraph():void {
            
            ggraph.clear();
            
            // 変換したxy座標
            var points:Array = [];
            
            // 入れ物
            var ps:Array, p:Object, i:uint, x:uint, y:uint;
            
            // 軸、矢印の座標
            var axis:Array = [  { x: -1.2, y:0, z:0 }, { x:1.2, y:0, z:0 }, { x:1.1, y:0.03, z:0 }, { x:1.1, y:-0.03, z:0 },
                                { x:0, y: -1.2, z:0 }, { x:0, y:1.2, z:0 }, { x:0.03, y:1.1, z:0 }, { x:-0.03, y:1.1, z:0 },
                                { x:0, y:0, z: -1.2 }, { x:0, y:0, z:1.2 }, { x:0.03, y:0, z:1.1 }, { x:-0.03, y:0, z:1.1 } ];
            
            // 座標変換
            var pp:Array, x1:Number, y1:Number, z1:Number, x2:Number, y2:Number, dis:Number;
            var sinZ:Number = Math.sin(angZ), cosZ:Number = Math.cos(angZ), sinX:Number = Math.sin(angX), cosX:Number = Math.cos(angX);
            for each(ps in zs.concat([axis])) {
                points.push(pp = []);
                for each(p in ps) {
                    x1 = p.x * cosZ + p.y * sinZ;
                    y1 = -p.x * sinZ * cosX + p.y * cosZ * cosX + p.z * sinX;
                    if (y1 <= cameraY) {
                        pp.push( { x:NaN, y:NaN } ); continue;
                    }
                    z1 = p.x * sinZ * sinX - p.y * cosZ * sinX + p.z * cosX;
                    dis = (screenY - cameraY) / (y1 - cameraY);
                    x2 = dis * x1 * 230 + 230;
                    y2 = -dis * z1 * 230 + 230;
                    pp.push( { x:x2, y:y2 } );
                }
            }
            
            // グラフ絵画
            ggraph.lineStyle(1, 0xeeeeee);
            for (x = 0; x < 65; x++) {
                ps = points[x];
                ggraph.moveTo(ps[0].x, ps[0].y);
                loop1 : for (y = 0; y < 65; y++) {
                    if (isNaN(ps[y].x) || isNaN(ps[y].y)) {
                        do {
                            if (++y >= 65) break loop1;
                        } while (isNaN(ps[y].x) || isNaN(ps[y].y))
                        ggraph.moveTo(ps[y].x, ps[y].y);
                        continue;
                    }
                    ggraph.lineTo(ps[y].x, ps[y].y);
                }
            }
            
            for (y = 0; y < 65; y++) {
                ggraph.moveTo(points[0][y].x, points[0][y].y);
                loop2 : for (x = 0; x < 65; x++) {
                    if (isNaN(points[x][y].x) || isNaN(points[x][y].y)) {
                        do {
                            if (++x >= 65) break loop2;
                        } while (isNaN(points[x][y].x) || isNaN(points[x][y].y))
                        ggraph.moveTo(points[x][y].x, points[x][y].y);
                        continue;
                    }
                    ggraph.lineTo(points[x][y].x, points[x][y].y);
                }
            }
            
            // 軸
            ggraph.lineStyle(2, 0x555555, 0.5);
            ggraph.beginFill(0x555555, 0.5);
            for (i = 0; i < 12; i += 4) {
                ggraph.moveTo(points[65][i].x, points[65][i].y);
                ggraph.lineTo(points[65][i + 1].x, points[65][i + 1].y);
                ggraph.lineTo(points[65][i + 2].x, points[65][i + 2].y);
                ggraph.lineTo(points[65][i + 3].x, points[65][i + 3].y);
                ggraph.lineTo(points[65][i + 1].x, points[65][i + 1].y);
            }
            ggraph.endFill();
        }
        
        private const Rnum:String = "(?:[1-9]\\d*|0)(?:\\.\\d+)?";
        private const Rfun:String = "(?:sin|cos|tan|asin|acos|atan|log|sqrt|abs)";
        private const Rope:String = "[+\\-*/^#]";
        private const Rvar:String = "(?:[xy]|_\\d+|pi|e)";
        private const Rpal:String = "\\(";
        private const Rpar:String = "\\)";
        private function createFunction(exp:String):Function {
            
            var pat:String;
            
            // コメント削除
            exp = exp.replace(/\/\/.*$/, "");
            
            // 空白削除
            exp = exp.replace(/ |\n/g, "");
            
            // _#禁止
            if (exp.match(/[_#]/)) return null;
            
            // キャプチャグループを作っておく
            var _num:String = "(" + Rnum + ")";
            var _fun:String = "(" + Rfun + ")";
            var _ope:String = "(" + Rope + ")";
            var _var:String = "(" + Rvar + ")";
            var _pal:String = "(" + Rpal + ")";
            var _par:String = "(" + Rpar + ")";
            var _l_:String  = "^((?:.*?\\()?[^)]*?)";
            var _r_:String  = "([^(]*(?:\\).*)?)$";
            
            // ----- 自動補充 -----
                // # (どの演算子よりも優先的に掛け算を行う)
                for each(pat in
                    [_num + _fun, _num + _var, _var + _fun, _var + _var, _var + _var,
                     _num + _pal, _var + _pal, _par + _fun, _par + _var, _par + _pal]
                ) exp = exp.replace(new RegExp(pat, "g"), "$1#$2");
            
            // ----- 計算式が正しいか検査 -----
                // ")数"はダメ
                if (exp.match(new RegExp(Rpar + Rnum))) return null;
                
                // 括弧のくくり方が正しいか
                var pars:String = exp.match(/[(){}\[\]]/g).join("");
                while (pars != (pars = pars.replace(/\(\)|{}|\[\]/g, ""))) { }
                if (pars) return null;
                
                // 先頭の"+-", 途中の"(+", "(-", "(", ")" をはずしても成立
                var exp2:String = exp.replace(/[{\[]/g, "(").replace(/[}\]]/g, ")")
                                    .replace(/^[+-]/, "").replace(/\([+-]?|\)/g, "") + "+";
                if (!exp2.match(new RegExp("^(" + Rfun + "*(?:" + Rnum + Rvar + "*|" + Rvar + "+)" + Rope + ")+$"))){
                    return null;
                }
            
            // ----- 処理しやすいように変形 -----
                // 括弧の形
                exp = exp.replace(/[{[]/g, "(").replace(/[}\]]/g, ")");
                
                // 先頭の + -, (+ (-
                exp = exp.replace(/^\+/g, ""); exp = exp.replace(/^\-/g, "0-");
                exp = exp.replace(/\(\+/g, "("); exp = exp.replace(/\(\-/g, "(0-");
                
                // 無意味な先頭と末尾の括弧組
                while(exp.match(/^\(.*\)$/)){
                    pars = exp.match(/[(){}\[\]]/g).join("").replace(/^\(/, "<").replace(/\)$/, ">");
                    while (pars != (pars = pars.replace(/\(\)|{}|\[\]/g, ""))) { }
                    if (pars == "<>") exp = exp.replace(/^\((.*)\)$/, "$1");
                    else break;
                }
                
                // 定数関数とか
                exp = exp.replace(new RegExp("^(" + Rnum + "|" + Rvar + ")$", "g"), "$1+0");
            
            //trace(exp);
            
            // 関数の作成
            var funcs:Array = new Array(), count:uint = 0, i:uint = 0;
            var toNumber:Function = function(val:*):*{ return isNaN(Number(val)) ? val : Number(val); };
            var doOperation:Function = function(type:String, addBefore:String = "_"):Function {
                return function(m:String, l:String, val1:*, val2:*, r:String, ...rest:Array):String {
                    val1 = toNumber(val1); val2 = toNumber(val2);
                    funcs.push(Calcs[type](val1, val2));
                    return l + addBefore + count++ + r;
                };
            }
            while (!exp.match(/^_\d+$/)) {
                
                // 優先乗算の後についた累乗
                while (exp != (exp = exp.replace(new RegExp(_l_ + "#(" + Rvar + "|" + Rnum + ")\\^(" + Rvar + "|" + Rnum + ")" + _r_),
                    doOperation("pow", "#_")
                ))) { }
                
                // 優先乗算
                while (exp != (exp = exp.replace(new RegExp(_l_ + "(" + Rvar + "|" + Rnum + ")#(" + Rvar + "|" + Rnum + ")" + _r_),
                    doOperation("mult")
                ))) { }
                
                // 関数
                while (exp != (exp = exp.replace(new RegExp(_l_ + _fun + "(" + Rvar + "|" + Rnum + ")" + _r_),
                    function(m:String, l:String, type:String, val:*, r:String, ...rest:Array):String {
                        val = toNumber(val);
                        funcs.push(Calcs.math(type, val));
                        return l + "_" + count++ + r;
                    }
                ))) { }
                
                // 累乗
                while (exp != (exp = exp.replace(new RegExp(_l_ + "(" + Rvar + "|" + Rnum + ")\\^(" + Rvar + "|" + Rnum + ")" + _r_),
                    doOperation("pow")
                ))) { }
                
                // 乗除
                while (exp != (exp = exp.replace(new RegExp(_l_ + "(" + Rvar + "|" + Rnum + ")([*/])(" + Rvar + "|" + Rnum + ")" + _r_),
                    function(m:String, l:String, val1:*, type:String, val2:*, r:String, ...rest:Array):String {
                        return doOperation(type == "*"?"mult":"div")(m, l, val1, val2, r);
                    }
                ))) { }
                
                // 加減
                while (exp != (exp = exp.replace(new RegExp(_l_ + "(" + Rvar + "|" + Rnum + ")([+-])(" + Rvar + "|" + Rnum + ")" + _r_),
                    function(m:String, l:String, val1:*, type:String, val2:*, r:String, ...rest:Array):String {
                        return doOperation(type == "+"?"add":"sub")(m, l, val1, val2, r);
                    }
                ))) { }
                
                // 括弧をはずす
                exp = exp.replace(new RegExp(Rpal + "(" + Rvar + "|" + Rnum + ")" + Rpar, "g"), "$1");
                
                if (i++ > 1000) {
                    //trace("overflow");
                    return null;
                }
            }
            
            return function(x:Number, y:Number):Number {
                var o:Object = { x:x, y:y, pi:Math.PI, e:Math.E };
                for (var i:uint = 0; i < funcs.length; i++) o["_" + i] = funcs[i](o);
                return o["_" + (i - 1)];
            }
            
        }
        
    }
    
}

class Calcs {
    public static function add(s1:*, s2:*):Function {
        return function(o:Object):Number {
            return ((s1 is Number)?s1:o[s1]) + ((s2 is Number)?s2:o[s2]);
        }
    }
    public static function sub(s1:*, s2:*):Function {
        return function(o:Object):Number {
            return ((s1 is Number)?s1:o[s1]) - ((s2 is Number)?s2:o[s2]);
        }
    }
    public static function mult(s1:*, s2:*):Function {
        return function(o:Object):Number {
            return ((s1 is Number)?s1:o[s1]) * ((s2 is Number)?s2:o[s2]);
        }
    }
    public static function div(s1:*, s2:*):Function {
        return function(o:Object):Number {
            return ((s1 is Number)?s1:o[s1]) / ((s2 is Number)?s2:o[s2]);
        }
    }
    public static function pow(s1:*, s2:*):Function {
        return function(o:Object):Number {
            return Math.pow(((s1 is Number)?s1:o[s1]), ((s2 is Number)?s2:o[s2]));
        }
    }
    public static function math(type:String, s1:*):Function {
        return function(o:Object):Number {
            return Math[type]((s1 is Number)?s1:o[s1]);
        }
    }
}
    
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.events.FocusEvent;
import flash.filters.GlowFilter;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;

class KButton extends Sprite {
    
    public const label:TextField = new TextField();
    
    function KButton(text:String, size:uint = 12, textColor:uint = 0xaaaaaa, backgroundColor:uint = 0x000000, lineColor:uint = 0x555555) {
        
        // ラベルの作成
        label.x = 3; label.y = 1; label.autoSize = TextFieldAutoSize.LEFT;
        var tfmt:TextFormat = label.getTextFormat();
        tfmt.color = textColor; tfmt.font = "_ゴシック"; tfmt.size = size;
        label.defaultTextFormat = tfmt;
        label.text = text;
        label.mouseEnabled = false;
        addChild(label);
        
        // 枠の作成
        graphics.lineStyle(1, lineColor); graphics.beginFill(backgroundColor);
        graphics.drawRect(0, 0, label.textWidth + 8, label.textHeight + 4);
        graphics.endFill();
        
        // クリック
        buttonMode = true;
        
        // イベント
        addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
            //y++;
            filters = [new GlowFilter(0xffffff, 0.5)];
        });
        addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
            //y--;
            filters = [];
        });
        
    }
    
}

class KInput extends Sprite {
    
    public const input:TextField = new TextField();
    
    function KInput(width:Number, size:uint = 12, textColor:uint = 0xffffff, backgroundColor:uint = 0x333333, glowColor:uint = 0xffffff) {
        
        // 背景
        graphics.beginFill(backgroundColor);
        graphics.drawRoundRect(0, 0, width, size + 8, 10, 10);
        
        // テキスト
        input.defaultTextFormat = new TextFormat("_ゴシック", size, textColor);
        input.type = TextFieldType.INPUT;
        input.height = size + 4; input.width = width - 10;
        input.x = 5; input.y = 2;
        addChild(input);
        
        //　イベント
        input.addEventListener(FocusEvent.FOCUS_IN, function(e:FocusEvent):void {
            filters = [new GlowFilter(glowColor, 0.5, 8, 8)];
        });
        input.addEventListener(FocusEvent.FOCUS_OUT, function(e:FocusEvent):void {
            filters = [];
        });
        
    }
    
    public function get text():String {
        return input.text;
    }
    public function set text(newVal:String):void {
        input.text = newVal;
    }
    
}