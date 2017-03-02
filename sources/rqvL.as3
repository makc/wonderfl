package {
    import flash.display.MovieClip;
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends MovieClip {
        public function Main() { loadMgl(this); }
        public function b():void { beginGame(); }
        public function u():void { update(); }
    }
}
function initialize() {
    Cursor.i();
    Turret.i();
    Missile.i();
    Enemy.i();
    Bullet.i();
    setBgm();
    drawBg();
    _.tt("LOCK ON TO", "ALL OF THEM").pl(new PlatformWonderfl).b;
}
var bs;
var addEnemyTicks;
var cursor, turret;
function beginGame() {
    cursor = new Cursor;
    turret = new Turret;
    Missile.s = new Array;
    Enemy.s = new Array;
    Bullet.s = new Array;
    addEnemyTicks = 0;
    bs.p;
}
var rank;
function update() {
    rank = sqrt(_.tc * .0002) + 1;
    if (--addEnemyTicks < 0) {
        new Enemy;
        addEnemyTicks = (cos(_.tc * .003) / 2 + 1.5) * 40 / rank;
    }
    _.dp;
    _.ua(Missile.s);
    if (_.ig) {
        turret.u();
        cursor.u();
        if (_.tc == 0) _t.i.t("MOUSE: MOVE A TURRET AND A SIGHT").xy(.4, .1).tc(180).ao;
    }
    _.ua(Enemy.s);
    _.ua(Bullet.s);
}
function setBgm() {
    bs = _s.i
        .l(64).rr(3).v(3).mm(0, .3)
        .n.m(107, 1, 3).lp.t(.5, 8)
        .l(32).rr(1).v(5).mm(0, .2).rp(2)
        .mn.m(107, 1, 3).lp.t(.4, 8).t(.3, 8)
        .mn.m(106, 1, 3).lp.t(.4, 8).t(.3, 8)
        .l(16).rr().v(6).mm().rp()
        .mn.m(112).lp.t(.3, 16).t(.2, 16)
        .e;
}
function drawBg() {
    var y = .875;
    var c = _c.ri.gd;
    while (y > 0) {
        if (c.r > 0) {
            c.r -= 12;
            c.b += 6;
        } else if (c.b > 0) {
            c.b -= 16;
        }
        c.r = _u.c(c.r, 0, 250);
        c.b = _u.c(c.b, 0, 250);
        _.frb(.5, y, 1, .06, c);
        y -= .05;
    }
    _.frb(.5, .95, 1, .1, _c.yi);
}
class Enemy {
    static var s;
    static var d, ld, dd;
    static var ds;
    static function i() {
        d = _d.i.c(_c.ri).cs(_c.ri.gd).cb(_c.ri.gb).si(0, 1).fr(.03, .03).
            c(_c.yi.gr.gr).cs(_c.yi.gr).cb(_c.yi.gd).si(0, 0, 1).
            o(.03, -.02).fr(.015, .03).o(-.03, -.02).fr(.015, .03);
        dd = _d.i.c(_c.ri.gb.gw).cs(_c.ri.gd.gb.gw).cb(_c.ri.gb.gb.gw).si(0, 1).fr(.03, .03).
            c(_c.yi.gr.gr.gb).cs(_c.yi.gr.gb).cb(_c.yi.gd.gb).si(0, 0, 1).
            o(.03, .02).fr(.015, .03).o(-.03, .02).fr(.015, .03);
        ld = _d.i.c(_c.gi.gd).o(.03, 0).fr(.01, .05).o( -.03, 0).fr(.01, .05);
        ds = _s.i.v(12).w(.4, 2).n.t(.8, 5, .2).e;
    }
    public var a = _a.i;
    var lockTicks = 0;
    var dstCount = 0;
    var fireTicks = 0;
    function Enemy() {
        a.p.xy(_r.n(), -.1);
        a.v.xy(_r.n(), .9).s(a.p).d(_r.i(60, 250));
        a.r(.04);
        fireTicks = _r.i(60);
        s.push(this);
    }
    public function u() {
        a.u;
        if (dstCount > 0) {
            a.v.y += .0003 * sqrt(dstCount);
            a.v.m(.96);
            dd.p(a.p).d;
        } else {
            d.p(a.p).d;
        }
        if (lockTicks > 0) {
            if (lockTicks < 20) lockTicks++;
            var lt = 20 - lockTicks;
            ld.p(a.p).r(lt * .2).s(lt * .1 + 1).d;
        }
        if (a.p.y > .9) {
            _p.i.p(a.p).c(_c.ri).cn(10).an(-HPI, PI).a;
            return false;
        }
        if (dstCount <= 0 && a.p.y > 0 && a.p.y < .5 && --fireTicks < 0) {
            fireTicks = 120 / sqrt(rank);
            new Bullet(a.p);
        }
        return true;
    }
    function lock() {
        if (lockTicks > 0) return;
        lockTicks = 1;
        new Missile(this);
    }
    function destroy(v) {
        if (a.p.y > .9) return;
        dstCount++;
        lockTicks = 0;
        a.v.a(v);
        _p.i.p(a.p).c(_c.ri.gg.gg).cn(10).sz(.05).an(v.an, .5).a;
        if (!_.ig) return;
        var s = _u.c(dstCount, 1, 10);
        _.sc(s);
        _t.i.t(s).p(a.p).v(_v.xy(0, -.1)).a;
        ds.p;
    }
}
class Bullet {
    static var s;
    static var d;
    static function i() {
        d = _d.i.c(_c.ri).cs(_c.mi).si(0, 0, 1).fr(.02, .04);
    }
    public var a = _a.i;
    function Bullet(p) {
        a.p.v(p);
        a.v.aa(HPI, 0.01);
        a.r(.02, .04);
        s.push(this);
    }
    public function u() {
        a.u;
        d.p(a.p).d;
        if (a.p.y > .9) {
            _p.i.p(a.p).c(_c.mi).cn(5).an(-HPI, PI).a;
            return false;
        }
        return true;
    }
}
class Cursor {
    static var d, td;
    static function i() {
        d = _d.i.c(_c.gi).cs(_c.ti).si(1).o(0, .02).fr(.07, .02).o(0, -.02).fr(.07, .02);
    }
    var a = _a.i;
    function Cursor() {
        a.r(.07);
    }
    function u() {
        a.p.v(_m.p);
        d.p(a.p).d;
        a.ir(Enemy.s, this);
    }
    public function hit(e) {
        e.lock();
    }
}
class Turret {
    static var d;
    static var ds;
    static function i() {
        d = _d.i.c(_c.gi.gr).cs(_c.gi.gd).cb(_c.gi.gd.gd).si(0, 1, 2).
            fr(.03, .05).o(0, .035).fr(.07, .03);
        ds = _s.v(10).i.w(.5, 3).ns.t(.9, 3, .3).t(.4, 7, .2).e;
    }
    var a = _a.i;
    function Turret() {
        a.p.xy(.5, .85);
    }
    var px = 0.5;
    var an = 0.0;
    function u() {
        a.p.x = _m.p.x;
        an += (a.p.x - px) * 3;
        an *= .9;
        d.p(a.p).r(an).d;
        px = a.p.x;
        if (a.ir(Enemy.s) || a.ir(Bullet.s)) {
            _p.i.p(a.p).c(_c.gi.gr).cn(100).sz(.1).s(.05).a;
            ds.p;
            _.e;
        }
    }
}
class Missile {
    static var s;
    static var d;
    static var ss;
    static function i() {
        d = _d.i.c(_c.ci.gd).cb(_c.ci.gd.gd.gd).cs(_c.ci.gr.gd).si(0, 1, 1).fr(.07, .02).
            c(_c.ci.gr.gd).si(1, 1).o( -.03, .02).fr(.04, .01).o( -.03, -.02).fr(.04, .01);
        ss = _s.n.w(.2, 1).t(.3, 4, .7).e;
    }
    var a = _a.i;
    var t;
    var ticks = 0;
    function Missile(t) {
        a.r(.07);
        this.t = t;
        a.p.x = cursor.a.p.x;
        a.p.y = .9;
        a.a = -HPI + turret.an;
        s.push(this);
        ss.p;
    }
    var pc = _c.ci.gd;
    public function u() {
        a.a = _u.aa(a.a, a.p.wt(t.a.p), ticks * .001);
        a.v.aa(a.a, .001).m(1 - abs(_u.na(a.p.wt(t.a.p) - a.a)) * .2);
        a.u;
        d.p(a.p).r(a.a).d;
        _p.i.p(a.p).an(a.a + PI, .2).sz(.01).c(pc).a;
        if (a.p.dt(t.a.p) < .1) {
            t.destroy(a.v);
            return false;
        }
        ticks++;
        return true;
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
    loader.load(new URLRequest("http://abagames.sakura.ne.jp/flash/mgl/mgl0_13.swf"), context);
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