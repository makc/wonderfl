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
    _.tt("DUAL PISTOLS", "RG").pl(new PlatformWonderfl).b;
}
var player;
var addBallTicks;
var ballScore, scoreColor, ballDstTicks;
var item;
var ss;
function beginGame() {
    if (!ss) ss = _s.i.mn(16).w(.3, 2).t(.2, 5, .4).t(.5, 7, .1).e;
    player = new Player;
    Ball.s = new Array;
    Shot.s = new Array;
    item = new Item;
    addBallTicks = 0;
    ballScore = 10;
    scoreColor = -1;
    ballDstTicks = 0;
    ss.p;
}
var rank;
function update() {
    rank = sqrt(_.tc * .0003) + 1;
    if (Ball.s.length <= 0) addBallTicks = 0;
    if (--addBallTicks < 0 && Ball.s.length < 16) {
        var ci = _r.i(2);
        new Ball(ci);
        new Ball(ci);
        addBallTicks += 60 * (Ball.s.length / 2) / rank;
    }
    _.ua(Shot.s);
    _.dp;
    if (_.ig) {
        item.update();
        player.update();
        if (_.tc == 0) _t.i.t("[WASD] MOVE / LEFT PISTOL").xy(.3, .1).tc(180).ao;
        if (_.tc == 0) _t.i.t("[uldr]        RIGHT PISTOL").xy(.3, .15).tc(180).ao;
        if (_.tc == 120) _t.i.t("SHOOT SAME COLOR BALLS AT A TIME").xy(.4, .25).tc(180).ao;
    }
    _.ua(Ball.s);
    if (_.ig && scoreColor >= 0) {
        var bd;
        switch (scoreColor) {
            case 0: bd = Ball.rd; break;
            case 1: bd = Ball.bd; break;
        }
        bd.p(_v.xy(.03, .03)).sc(.6).d;
        _l.xy(.1, .02).t(ballScore).d;
    }
}
class Player {
    static var bd, ad, ld;
    static var ws, ds;
    var a = _a.i;
    var fla = _a.i;
    function Player() {
        if (!bd) {
            bd = _d.i.c(_c.yi).cb(_c.yi.gg).fr(.02, .07).o(.015, -.04).fr(.03, .015);
            ad = _d.i.c(_c.yi.gg.gg).cb(_c.yi.gg.gg.gd).o(0, .02).fr(.015, .04).o(.02, .04).fr(.04, .015);
            ld = _d.i.c(_c.yi).cb(_c.yi.gd).o(0, .02).fr(.02, .04).o(-.02, .04).fr(.04, .02);
            ws = _s.i.m(64, 7).t(.4, 2, .3).t(.3, 2, .5).e;
            ds = _s.i.w(.3, 1).mn().t(.8, 4, .4).t(.6, 4, .2).t(.4, 8, .1).e;
        }
        a.p.n(.5);
        fla.c(.05);
    }
    var mt = 0;
    var lst = _v.i, rst = _v.i;
    var ap = _v.i;
    var lp = _v.i;
    var ls = 1;
    var laa = 0;
    var raa = 0;
    var hc = 0;
    function update() {
        checkStick();
        hc = 0;
        if (lst.l > 0) {
            if (mt++ % 15 == 0) ws.p;
            if (lst.x > 0) ls = 1;
            if (lst.x < 0) ls = -1;
            laa = _u.aa(laa, lst.an, .1);
            ap.xy(.04, .04).r(laa).a(a.p);
            drawFireLine(ap, laa);
        }
        if (rst.l > 0) {
            raa = _u.aa(raa, rst.an, .1);
            ap.xy(.04, .04).r(raa).a(a.p);
            drawFireLine(ap, raa);
            lst.d(3);
        }
        a.p.a(lst.m(.01));
        a.p.x = _u.c(a.p.x, .05, .95);
        a.p.y = _u.c(a.p.y, .05, .95);
        bd.p(a.p).sc(ls, 1).d;
        lp.v(a.p);
        lp.y += 0.035;
        ld.p(lp).r(sin(mt * .25) * .5 - HPI / 2 * ls).sc(ls, 1).d;
        ld.p(lp).r(sin(mt * .25 + PI) * .5 - HPI / 2 * ls).sc(ls, 1).d;
        ap.v(a.p);
        ap.y -= .01;
        ad.p(ap).r(laa).d;
        ad.p(ap).r(raa).d;
        if (a.ic(Ball.s)) destroy();
    }
    function checkStick() {
        lst.n(0);
        if (_k.s[0x57]) lst.y -= 1;
        if (_k.s[0x53]) lst.y += 1;
        if (_k.s[0x44]) lst.x += 1;
        if (_k.s[0x41]) lst.x -= 1;
        if (lst.x != 0 && lst.y != 0) lst.m(.7);    
        rst.n(0);
        if (_k.s[0x26]) rst.y -= 1;
        if (_k.s[0x28]) rst.y += 1;
        if (_k.s[0x27]) rst.x += 1;
        if (_k.s[0x25]) rst.x -= 1;
        if (rst.x != 0 && rst.y != 0) rst.m(.7);    
    }
    var lr = _c.ri.gg;
    var ifh = false;
    function drawFireLine(p, an) {
        lp.v(p);
        ifh = false;
        for (var i = 0; i < 20; i++) {
            _.fr(lp.x, lp.y, .01, .01, lr);
            fla.p.v(lp);
            fla.ic(Ball.s, this);
            if (ifh) break;
            lp.aa(an, .05);
            if (!lp.ii()) break;
        }
    }
    var hci = 0;
    public function hit(b) {
        if (b.appTicks > 0 || b.isTargeted || b.isFired || ifh) return;
        b.isFired = true;
        ifh = true;
        if (hc == 0) hci = b.ci;
        else if (hci != b.ci) return;
        hc++;
    }
    function destroy() {
        if (!_.ig) return;
        _p.i.p(a.p).cn(100).sz(.05).s(.05).c(_c.yi.gr).a;
        ds.p;
        _.eg;
    }
}
class Ball {
    static var s;
    static var rd, bd;
    static var ds;
    public var a = _a.i;
    var r, rsc;
    var appTicks = 30;
    var isFired = false;
    var isTargeted = false;
    var isDestroyed = false;
    var ci, c;
    var d;
    function Ball(ci) {
        if (!rd) {
            rd = _d.i.c(_c.ri).cb(_c.ri.gd).cs(_c.ri.gg).lc(.03).si(2).fc(.03, 1);
            bd = _d.i.c(_c.bi.gw).cb(_c.bi).cs(_c.bi.gr).lc(.03).si(2).fc(.03, 1);
            ds = _s.i.w(.5, 2).m().t(.5, 5, 0).t(0, 10, 1).e;
        }
        setColor(ci);
        a.v.xy(_r.n(.005, .005)).r(player.a.p.wt(a.p) + _r.n(PI, -HPI));
        rsc = _r.n(2, 1);
        a.v.d(rsc);
        r = .03 * rsc;
        a.c(r);
        for (var i = 0; i < 20; i++) {
            a.p.x = _r.n(.8, .1);
            a.p.y = _r.n(.8, .1);
            if (a.p.dt(player.a.p) > .4 && !a.ic(Ball.s)) break;
        }
        s.push(this);
    }
    function setColor(ci) {
        this.ci = ci;
        switch (ci) {
            case 0: d = rd; c = _c.ri; break;
            case 1: d = bd; c = _c.bi.gw; break;
        }
    }
    public function update() {
        if (isDestroyed) return false;
        if (!isTargeted && isFired) {
            if (player.hc >= 2) {
                new Shot(this);
                isTargeted = true;
            } else {
                isFired = false;
            }
        }
        a.u;
        if (a.p.x < r) hitAd(PI, r - a.p.x);
        if (a.p.x > 1 - r) hitAd(0, a.p.x - (1 - r));
        if (a.p.y < r) hitAd(-HPI, r - a.p.y);
        if (a.p.y > 1 - r) hitAd(HPI, a.p.y - (1 - r));
        if (--appTicks >= 0) d.sc(rsc * (appTicks * .1 + 1)).dd;
        else d.sc(rsc).ed;
        d.p(a.p).d;
        a.ic(s, this);
        if (a.v.l > .01 / rsc) a.v.m(.95);
        return true;
    }
    public function hit(b) {
        hitAd(a.p.wt(b.a.p), a.p.dt(b.a.p));
    }
    function hitAd(an, d) {
        a.v.s(_v.n().aa(an, d).d(10).d(rsc));
        _p.i.p(_v.v(a.p).aa(an, d)).an(an, .3).c(c).cn(3).a;
    }
    function destroy() {
        isDestroyed = true;
        _p.i.p(a.p).cn(50).c(c).a;
        if (scoreColor != -1 && scoreColor != ci) ballScore = 10;
        _.sc(ballScore);
        _t.i.t(ballScore).p(a.p).v(_v.xy(0, -.1)).a;
        if ((++ballDstTicks % 2) == 0 &&
            (scoreColor == -1 || scoreColor == ci) && ballScore < 160) ballScore *= 2;
        scoreColor = ci;
        ds.p;
    }
    function changeColor() {
        setColor((ci + 1) % 2);
    }
}
class Shot {
    static var s;
    static var ds;
    static var ss;
    var a = _a.i;
    var t;
    var ticks = 7;
    function Shot(t) {
        if (!ds) {
            ds = _d.i.c(_c.ri).cs(_c.yi).si(0, 0, 1).fc(.02);
            ss = _s.i.n().t(.5, 2, .6).t(.7, 4, .2).e;
        }
        this.t = t;
        a.p.v(player.a.p);
        _p.i.p(a.p).an(a.p.wt(t.a.p), .4).c(_c.yi.gr).cn(10).sz(.03).s(.01).a;
        ss.p;
        s.push(this);
    }
    public function update() {
        a.v.v(t.a.p).s(a.p).d(ticks);
        a.u;
        _p.i.p(a.p).an(a.v.an + PI, .2).c(_c.ri.gg).s(.01).a;
        ds.p(a.p).d;
        if (--ticks <= 0) {
            t.destroy();
            return false;
        }
        return true;
    }
}
class Item {
    static var ds;
    static var gs;
    var a = _a.i;
    function Item() {
        if (!ds) {
            ds = _d.i.c(_c.yi).cs(_c.yi.gg).lc(.03).si(1, 0, 1).fc(.03, 1);
            gs = _s.i.m(32, 10).w(.4, 2).t(.7, 5, .2).e;
        }
        for (var i = 0; i < 10; i++) {
            a.p.x = _r.n(.8, .1);
            a.p.y = _r.n(.8, .1);
            if (a.p.dt(player.a.p) > .4) break;
        }
    }
    function update() {
        ds.p(a.p).d;
        if (a.p.dt(player.a.p) < .07) {
            for each (var b in Ball.s) b.changeColor();
            item = new Item;
            gs.p;
        }
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
    loader.load(new URLRequest("http://abagames.sakura.ne.jp/flash/mgl/mgl0_12.swf"), context);
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