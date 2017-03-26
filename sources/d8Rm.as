package {
    import flash.display.MovieClip;
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends MovieClip {
        public function Main() { loadMgl(this); }
        public function b():void { beginGame(); }
        public function u():void { update(); }
    }
}
var wd;
var skyAddDist;
var ss;
function initialize() {
    _.tt("TOSSED HUMANS", "SPLIT OVER").pl(new PlatformWonderfl).b;
}
function beginGame() {
    if (!ss) ss = _s.i.bmj(16).w().t(0.5, 3, 0.1).w(0.2, 1).t(0.1, 5, 0.6).e;
    if (!wd) wd = Wall.getShape().dd;
    ss.p;
    Human.s = new Array;
    Wall.s = new Array;
    if (_.ig) {
        var h = new Human;
        h.a.p.xy(0.5, 0.2);
        var w = new Wall;
        w.a.p.xy(0.5, 0.7);
    }
    Sky.s = new Array;
    for (var i = 0; i < 5; i++) new Sky(i * 0.2 + 0.1);
    skyAddDist = 0;
}
var ip = false;
var wallAddTicks = 0;
var rank;
function update() {
    rank = 1 + sqrt(_.tc * 0.0003);
    _.ua(Sky.s);
    _.dp;
    _.ua(Wall.s);
    if (_.ig) {
        if (--wallAddTicks < 0) {
            var w = new Wall;
            w.a.p.v(_m.p);
            wallAddTicks = 10;
        } else {
            wd.p(_m.p).sc(wallAddTicks * 0.2 + 1).d;
        }
        if (Human.s.length <= 0) _.eg;
    } else {
        scroll(0.003);
    }
    _.ua(Human.s);
}
function scroll(y) {
    if (y < 0) return;
    for each (var s in Sky.s) s.y += y;
    for each (var h in Human.s) h.a.p.y += y;
    for each (var w in Wall.s) w.a.p.y += y;
    skyAddDist -= y;
    while (skyAddDist < 0) {
        new Sky(skyAddDist - 0.1);
        skyAddDist += 0.2;
    }
}
class Human {
    static var s;
    static var db, dl;
    static var bs, ds;
    var a = _a.i;
    var lv = 0.0, la = 0.0;
    function Human() {
        if (!db) {
            db = _d.i.c(_c.yi).cb(_c.yi.gd).sz(2).fr(3, 10).fr(12, 3);
            dl = _d.i.c(_c.yi.gd).sz(2).o(2, 0).fr(3, 10).o(0, 2).fr(10, 3);
        }
        if (!bs) {
            bs = _s.i.bmj().w(0.5, 1).t(0.4, 7, 0.4).e;
            ds = _s.i.bmn().w(0.3, 1).t(0.6, 5, 0.2).t(0.2, 5, 0.1).e;
        }
        a.r(0.07, 0.1);
        s.push(this);
    }
    var bo = _v.i.xy(0, -0.04);
    public function update() {
        a.v.y += 0.0005 * rank;
        a.v.m(0.99);
        a.u;
        a.ir(Wall.s, this);
        if (a.v.y < 0 && a.p.y < 0.4) scroll((0.4 - a.p.y) * 0.1);
        if ((a.p.x < 0.03 && a.v.x < 0) || (a.p.x > 0.97 && a.v.x > 0)) a.v.x *= -1;
        lv += a.v.x * 2;
        lv -= la * 0.1;
        lv *= 0.98;
        la += lv;
        db.p(_v.v(a.p).a(bo)).r(-la / 2).d;
        dl.p(a.p).r(-PI / 4 * 3 + la).d;
        if (a.p.y > 1.1) {
            _p.i.p(a.p).c(_c.yi.gr).cn(10).sz(0.05).s(0.03).ag(a.v.ga + PI, 0.5).a;
            ds.p;
            return false;
        }
        return true;
    }
    public function hit(w) {
        if (a.v.y > 0) {
            var vy = a.v.y;
            a.p.y = w.a.p.y - 0.085;
            a.v.y *= -2;
            a.v.x += (a.p.x - w.a.p.x) * 0.2;
            if (Human.s.length < 100) {
                var h = new Human;
                h.a.p.v(a.p);
                h.a.v.v(a.v);
                h.a.v.x *= 1.4;
                h.a.v.y *= 0.8;
            }
            _.sc(1);
            _p.i.p(a.p).c(_c.gi.gr).ag(a.v.ga, 0.3).cn(10).s(0.01).a;
            bs.p;
        } else {
            _p.i.p(a.p).c(_c.yi.gr.gr).cn(20).sz(0.04).s(0.03).a;
            a.p.y = 99;
            ds.p;
        }
    }
}
class Wall {
    static var s;
    static var d;
    static function getShape() {
        return _d.i.c(_c.gi).cb(_c.ri.gg).cs(_c.ci.gg).lr(22, 10).si(0, 0, 2).fr(20, 8);
    }
    public var a = _a.i;
    function Wall() {
        if (!d) d = getShape();
        a.r(0.14, 0.06);
        s.push(this);
    }
    public function update() {
        d.p(a.p).d;
        return a.p.y < 1.1;
    }
}
class Sky {
    static var s;
    static var ct = 0;
    var y;
    var c = _c.wi;
    function Sky(y) {
        this.y = y;
        c.r = sin(ct * 0.1) * 50 + 80;
        c.g = sin(ct * 0.15) * 50 + 50;
        c.b = sin(ct * 0.1 + PI) * 50 + 80;
        ct++;
        s.push(this);
    }
    public function update() {
        _.fr(0.5, y, 1, 0.005, c);
        return y < 1.1;
    }
}
import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.system.*;
var main:Main;
var loader:Loader;
var _;
var _a, _c, _d, _k, _l, _m, _p, _s, _t, _r, _u, _v;
var sin:Function = Math.sin, cos:Function = Math.cos, atan2:Function = Math.atan2; 
var sqrt:Function = Math.sqrt, abs:Function = Math.abs;
var PI:Number = Math.PI, PI2:Number = PI * 2, HPI:Number = PI / 2;
// load mgl (Mini Game programming Library) (https://github.com/abagames/mgl)
function loadMgl(main:Main):void {
    this.main = main;
    loader = new Loader();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLibLoaded);
    var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
    context.securityDomain = SecurityDomain.currentDomain;
    loader.load(new URLRequest("http://abagames.sakura.ne.jp/flash/mgl/mgl0_11.swf"), context);
}
function onLibLoaded(e:Event):void {
    var G:Class = loader.contentLoaderInfo.applicationDomain.getDefinition("mgl.G") as Class;
    _ = new G(main, main);
    _a = _.a; _c = _.c; _d = _.d; _k = _.k; _l = _.l; _m = _.m;
    _p = _.p; _s = _.s; _t = _.t; _r = _.r; _u = _.u; _v = _.v;
    initialize();
}
import net.wonderfl.score.basic.BasicScoreForm;
import net.wonderfl.score.basic.BasicScoreRecordViewer;
class PlatformWonderfl {
    public var clickStr = "CLICK";
    public var isTouchDevice = false;
    public var titleX = 0.85;
    const HIGHSCORE_COUNT = 50;
    var scoreRecordViewer:BasicScoreRecordViewer;
    var scoreForm:BasicScoreForm;
    public function recordHighScore(score:int):void {
        scoreForm = new BasicScoreForm(main, 5, 5, score);
        scoreForm.onCloseClick = function():void {
            closeHighScore();
            showHighScore();
        }    
    }
    public function showHighScore():void {
        scoreRecordViewer =
            new BasicScoreRecordViewer(main, 5, 220, "SCORE RANKING", HIGHSCORE_COUNT);
    }
    public function closeHighScore():void {
        if (scoreRecordViewer) {
            main.removeChild(scoreRecordViewer);
            scoreRecordViewer = null;
        }
        if (scoreForm) {
            main.removeChild(scoreForm);
            scoreForm = null;
        }
    }
}