package {
    import flash.display.MovieClip;
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends MovieClip {
        public function Main() { loadMgl(this); }
        public function b():void { beginGame(); }
        public function u():void { update(); }
    }
}
var box;
var bonus;
var spikeAddDist, starAddDist, scoreAddDist;
var nextBonusScore;
var ts;
var sse;
function beginGame() {
    spikeAddDist = starAddDist = scoreAddDist = 0.0;
    nextBonusScore = 100;
    ts = _s.i.bmn().t(0.3, 2, 0.2).e;
    box = new Box;
    Spike.s = new Array;
    Star.s = new Array;
    bonus = new Bonus;
    for (var i = 0; i < 20; i++) Star.s.push(new Star(true));
    if (!sse) sse = _s.i.bmj(16).w(0.3, 3).t(0.2, 3, 0.4).t(0.1, 5, 0.5).t(0.7, 7, 0.2).e;
    sse.p;
}
function update() {
    scroll(_v.xy(0, sqrt(_.tc * 0.000000001)));
    _.dp;
    _.ua(Star.s);
    bonus.update();
    box.update();
    _.ua(Spike.s);
    if (_.ig) {
        if (_.tc % 60 == 0) ts.p;
        if (_.tc == 0) _t.i.xy(0.2, 0.1).t("[WASD]: THRUST").tc(180).ao;
        if (_.tc == 60) _t.i.xy(0.5, 0.05).t("uu GO UP! uu").tc(180).ao;
    }
}
function scroll(o) {
    if (o.y < 0) o.y = 0;
    spikeAddDist -= o.y;
    while (spikeAddDist < 0) {
        Spike.s.push(new Spike);
        spikeAddDist += _r.n(0.1, 0.1);
    }
    starAddDist -= o.y;
    while (starAddDist < 0) {
        Star.s.push(new Star);
        starAddDist += 0.1;
    }
    if (_.ig) scoreAddDist -= o.y;
    while (scoreAddDist < 0) {
        _.sc(1);
        scoreAddDist += 0.01;
    }
    box.a.p.a(o);
    bonus.a.p.a(o);
    for each (var s in Spike.s) s.a.p.a(o);
    o.d(2);
    for each (var s in Star.s) s.p.a(o);
}
class Bar {
    static var d;
    static var se;
    var a = _a.i;
    var l = _l.i;
    var box;
    function Bar() {
        if (!d) d = _d.i.c(_c.di).cs(_c.gi.gr.gd).cb(_c.gi).cbs(_c.gi.gg).
            lr(5, 25).si(1, 2, 3).fr(3, 23);
        if (!se) se = _s.i.bn().t(0.2, 4, 0.1).e;
        a.p.y = 0.01;
    }
    var lo = _v.i.xy(0, 0.1);
    function update() {
        var bp = box.a.p;
        var ba = a.a + box.a.a;
        d.p(_v.v(a.p).r(ba).a(bp)).r(ba).d;
        l.p(_v.v(a.p).a(lo).r(ba).a(bp)).d;
    }
    var po = _.v.i.xy(0, 0.08);
    function thrust() {
        var bp = box.a.p;
        var ba = a.a + box.a.a;
        a.p.x += _r.pn(sqrt(_.tc * 0.000000003));
        a.p.x = _u.c(a.p.x, -0.1, 0.1);
        _p.i.p(_v.v(a.p).a(po).r(ba).a(bp)).ag(ba, 0.3).c(_c.yi.gr.gr).a;
        box.thrust(-a.p.x * 0.03, a.a);
        se.p;
    }
    function checkHit(cp, sp) {
        return _v.v(cp).s(box.a.p).r(box.a.a).s(a.p).r(a.a).
            ii(0, -0.08 - sp, 0.08 + sp, -0.02 - sp, 0.02 + sp);
    }
}
class Box {
    static var d;
    static var se;
    var bs = new Array;
    var a = _a.i;
    var av = 0.0;
    function Box() {
        if (!d) d = _d.i.c(_c.ci).cs(_c.gi.gb).cb(_c.ci.gd).si(0, 0, 2).fr(20, 4).fr(4, 20);
        if (!se) se = _s.i.bns().t(0.9, 3, 0.2).t(0.5, 8, 0).e;
        var strs = ['W', 'A', 'S', 'D'];
        for (var i = 0; i < 4; i++) {
            var b = new Bar;
            b.a.a = (i + 2) * HPI;
            b.l.t(strs[i]);
            b.box = this;
            bs.push(b);
        }
        a.p.n(0.5);
    }
    var cp = _v.i.xy(0.5, 0.5);
    function update() {
        a.a += av;
        av *= 0.98;
        a.u;
        a.v.m(0.98);
        scroll(_v.v(a.p).s(cp).m(-0.03));
        if (_.ig) {
            if (_k.iu) bs[0].thrust();
            if (_k.il) bs[1].thrust();
            if (_k.id) bs[2].thrust();
            if (_k.ir) bs[3].thrust();
            d.p(a.p).r(a.a).d;
            for each (var b in bs) b.update();
        }
        if (a.p.y > 1.0) destroy();
    }
    function thrust(avv, vva) {
        av += avv;
        a.v.aa(a.a + vva, -0.0002);
    }
    function checkHit(cp, sp = 0.0) {
        for each (var b in bs) if (b.checkHit(cp, sp)) return true;
        return false;
    }
    function destroy() {
        if (!_.ig) return;
        _p.i.p(a.p).c(_c.ri.gg.gg).cn(100).sz(0.1).s(0.05).a;
        se.p;
        _.eg;
    }
}
class Spike {
    static var s;
    static var d;
    public var a = _a.i;
    function Spike() {
        if (!d) d = _d.i.c(_c.ri).cs(_c.mi).cb(_c.ri.gb).si(0, 0, 2).fr(2, 6).fr(6, 2);
        a.p.x = _r.n();
        a.p.y = -0.2;
    }
    public function update() {
        a.p.x = _u.cr(a.p.x, 1.1, -0.1);
        d.p(a.p).r(PI / 4).d;
        if (box.checkHit(a.p)) box.destroy();
        return a.p.y < 1.1;
    }
}
class Bonus {
    static var d;
    static var se;
    var a = _a.i;
    var sc;
    function Bonus() {
        if (!d) d = _d.i.c(_c.yi).cs(_c.yi.gg).cb(_c.yi.gd).lc(4).si(1, 2, 3).fc(3);
        if (!se) se = _s.i.bmj().t(0.1, 3, 0.5).t(0.7, 3, 0.4).e;
        a.c(0.1);
        for (var i = 0; i < 10; i++) {
            a.p.x = _r.n();
            a.p.y = -0.1;
            if (!a.ic(Spike.s)) break;
        }
        sc = nextBonusScore;
    }
    var so = _v.i.xy(0, -0.05);
    public function update() {
        a.p.x = _u.cr(a.p.x, 1.1, -0.1);
        d.p(a.p).d;
        _l.t(sc).p(_v.v(a.p).a(so)).d;
        if (_.ig && box.checkHit(a.p, 0.05)) {
            _p.i.p(a.p).c(_c.yi).cn(20).a;
            _.sc(sc);
            _t.i.t(sc).p(a.p).v(_v.xy(0, -0.1)).a;
            se.p;
            if (nextBonusScore < 1000) nextBonusScore += 100;
            bonus = new Bonus;
        }
        if (a.p.y >= 1.1) {
            nextBonusScore = 100;
            bonus = new Bonus;
        }
    }
}
class Star {
    static var s;
    var p = _v.i;
    var c = _c.wi;
    function Star(ias = false) {
        p.x = _r.n();
        if (ias) p.y = _r.n();
        else p.y = -0.1;
        c.v(c.gd.gbl);
    }
    public function update() {
        p.x = _u.cr(p.x, 1.1, -0.1);
        _.fr(p.x, p.y, 0.01, 0.01, c);
        return p.y < 1.1;
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
    loader.load(new URLRequest("http://abagames.sakura.ne.jp/flash/mgl/mgl0_1.swf"), context);
}
function onLibLoaded(e:Event):void {
    var G:Class = loader.contentLoaderInfo.applicationDomain.getDefinition("mgl.G") as Class;
    _ = new G(main, main);
    _a = _.a; _c = _.c; _d = _.d; _k = _.k; _l = _.l; _m = _.m;
    _p = _.p; _s = _.s; _t = _.t; _r = _.r; _u = _.u; _v = _.v;
    _.tt("WASD THRUST").pl(new PlatformWonderfl).b;
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