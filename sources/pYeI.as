package {
    import flash.display.MovieClip;
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends MovieClip {
        public function Main() { loadMgl(this); }
        public function b():void { beginGame(); }
        public function u():void { update(); }
    }
}
var ss, bgm;
function initialize() {
    _.tt("LASER WINDER").pl(new PlatformWonderfl).b;
    bgm = _s.i.l(32).rr(1).v(12).mn.m(151, 3, 10).mm(-.2, 0).lp.t(.3, 8).t(.2, 8).
        v(10).mn.m(151, 3, 10).mm(-.2, 0).r(64).lp.t(.4, 8).t(.3, 8).e;
    ss = _s.i.l(16).v(8).mn.m(450, 1).t(.4, 8).t(.5, 8).
        mn.m(372).t(.4, 8).t(.5, 8).e;
    Ship.i();
    Laser.i();
    Block.i();
}
var ship;
var blockAddCount;
function beginGame() {
    ship = new Ship;
    Laser.s = new Array;
    Block.s = new Array;
    Star.s = new Array;
    blockAddCount = 0;
}
var rank, sec;
function update() {
    rank = sqrt(_.tc * .0005) + 1;
    sec = int(_.tc / 60);
    if (--blockAddCount < 0) {
        if (Block.s.length < 512) createBlock();
        blockAddCount = _r.i(20, 80) / rank;
    }
    if (_.tc % 10 == 0) new Star();
    _.ua(Star.s);
    _.dp;
    if (_.ig) {
        if (_.tc == 0) ss.p;
        if (_.tc == 240) bgm.p;
        if (_.tc == 0) _t.i.t("[uldr] MOVE").xy(.2, .05).tc(180).ao;
        if (_.tc == 60) _t.i.t("[Z] LASER").xy(.2, .1).tc(180).ao;
        _.ua(Laser.s);
        ship.u();
    }
    _.ua(Block.s);
}
class Ship {
    static var d;
    static var ss, ds;
    static function i() {
        d = _d.i.c(_c.gi).cb(_c.gi.gd).cs(_c.gi.gr.gr).si(1, 0, 2).fr(.05, .02).
            o( -.01, .02).c(_c.gi.gb).fr(.03, .01).o( -.02, -.02).c(_c.gi.gr).fr(.03, .01);
        ss = _s.i.v(8).mj.t(.5, 3).e;
        ds = _s.i.ns.w(.2, 2).t(.7, 4, .5).t(.6, 4, .4).t(.5, 4, .3).e;
    }
    var a = _a.i;
    function Ship() {
        a.p.xy(.2, .5);
    }
    var fireEng = 10;
    var isCharging = false;
    function u() {
        a.v.v(a.p);
        a.p.a(_k.st.m(.015));
        a.p.x = _u.c(a.p.x, 0, 1);
        a.p.y = _u.c(a.p.y, 0, 1);
        a.v.s(a.p).m(-1);
        d.p(a.p).d;
        if (_k.ib && !isCharging && fireEng > 0) {
            new Laser();
            _p.i.p(a.p).c(_c.ci.gg).an(0, .2).a;
            if (--fireEng <= 0) isCharging = true;
            ss.p;
        } else {
            fireEng++;
            if (fireEng > 10) {
                fireEng = 10;
                isCharging = false;
            }
        }
        if (a.ir(Block.s)) {
            _p.i.p(a.p).c(_c.gi.gr).cn(100).sz(.1).s(.04).a;
            ds.p;
            _.e;
        }
    }
}
class Laser {
    static var d;
    static var s;
    static function i() {
        d = _d.i.c(_c.ci).cb(_c.ci.gw).fr(.03, .015);
    }
    public var a = _a.i;
    function Laser() {
        a.r(.03, .015);
        a.p.v(ship.a.p);
        a.v.x = .03;
        s.push(this);
    }
    public function u() {
        a.u;
        a.p.a(ship.a.v);
        d.p(a.p).d;
        if (a.ir(Block.s, this)) return false;
        return a.p.x < 1;
    }
    public function h(b) {
        b.destroy();
    }
}
class Block {
    static var bd, cd;
    static var ds, cds;
    static var s;
    static var cx, cy, vx, vy;
    static var nextCoreId = 0;
    static function i() {
        bd = _d.i.c(_c.mi).cb(_c.mi.gd).cs(_c.mi.gr).si(3, 2, 1).fr(.03, .03);
        cd = _d.i.c(_c.ci).lc(.02).cb(_c.ci.gd.gd).fc(.02, 1);
        ds = _s.i.n.t(.5, 2, .3).e;
        cds = _s.i.mj.w(.3, 1).t(.7, 3, .2).t(.2, 5, .5).e;
    }
    static function add() {
        nextCoreId++;
        cy = _r.n(.8, .1);
        cx = 1.2;
        vx = -_r.n(.002 * rank, .004);
        vy = (_r.n() - cy) / (cx / -vx);
    }
    static function destroyCore(id) {
        var sc = 0;
        for each (var b in s) {
            if (b.coreId == id) if (b.destroy()) sc++;
        }
        return sc;
    }
    public var a = _a.i;
    var coreId;
    var isCore = false;
    var isDestroyed = false;
    function Block(ox, oy, isCore = false) {
        this.isCore = isCore;
        coreId = nextCoreId;
        a.p.xy(cx + ox, cy + oy);
        a.v.xy(vx, vy);
        if (isCore) a.r(.04);
        else a.r(.02);
        s.push(this);
    }
    public function u() {
        if (isDestroyed) return false;
        a.u;
        if (isCore) cd.p(a.p).d;
        else bd.p(a.p).d;
        if (a.p.x < -.05) a.p.x += 1.1;
        a.p.y = _u.cr(a.p.y, -.05, 1.05);
        return true;
    }
    function destroy() {
        if (isDestroyed) return false;
        isDestroyed = true;
        if (isCore) {
            var s = destroyCore(coreId);
            s++;
            _.sc(s);
            _t.i.t(s).p(a.p).v(_v.xy(0, -.1)).a;
            _p.i.p(a.p).c(_c.ci.gr).cn(50).s(.03).sz(.03).a;
            cds.p;
        } else {
            _p.i.p(a.p).c(_c.mi.gr).cn(5).t(20).a;
            ds.p;
        }
        return true;
    }
}
function createBlock() {
    var w = _r.i(7, 7);
    var h = _r.i(7, 7);
    var bs = new Array;
    for (var x = 0; x < w; x++) bs.push(new Array);
    for (x = 0; x < w; x++) {
        var r = Number(x) / w;
        addBlock(bs, x, int(h / 2), _u.c(sin(r * PI) * h / 2 + _r.i(3, -1), 0, 999), -1);
        addBlock(bs, x, int(h / 2), _u.c(sin(r * PI) * h / 2 + _r.i(3, -1), 0, 999), 1);
    }
    var cx = w - _r.i(3, 1);
    var cy = int(h / 2) + _r.i(3, -1);
    var type = _r.i(4, 1);
    if (sec % 50 < 20 && type == 3 || type == 4) type -= 2;
    var y = 0.0;
    y = cy;
    var du = 0, dd = 0;
    for (x = cx; x >= 0; x--) {
        switch (type) {
        case 1:
            du = 99;
            break;
        case 2:
            dd = 99;
            break;
        case 3:
            du = _r.i(2, 1);
            break;
        case 4:
            dd = _r.i(2, 1);
            break;
        }
        removeBlock(bs, x, _u.c(int(y) - du, 0, h), _u.c(int(y) + dd, 0, h));
        if (x < cx - 1) {
            switch (type) {
                case 1:
                case 3:
                    y -= _r.n(.5);
                    break;
                case 2:
                case 4:
                    y += _r.n(.5);
                    break;
            }
        }
    }
    bs[cx][cy] = 2;
    Block.add();
    for (x = 0; x < w; x++) {
        for (y = 0; y < h; y++) {
            if (bs[x][y] > 0) new Block((x - w / 2) * .03, (y - h / 2) * .03, bs[x][y] == 2);
        }
    }
}
function addBlock(bs, x, sy, h, vy) {
    var y = sy;
    for (var i = 0; i < h; i++) {
        bs[x][y] = 1;
        y += vy;
    }
}
function removeBlock(bs, x, fy, ty) {
    for (var y = fy; y <= ty; y++) bs[x][y] = 0;
}
class Star {
    static var s;
    var a = _a.i;
    var c = _c.wi;
    function Star() {
        a.p.y = _r.n();
        a.p.x = 1.05;
        a.v.x = -_r.n(.01, .01);
        c.v(c.gd.gbl);
        s.push(this);
    }
    public function u() {
        a.u;
        _.fr(a.p.x, a.p.y, 0.01, 0.01, c);
        return a.p.x > -.05;
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
    loader.load(new URLRequest("http://abagames.sakura.ne.jp/flash/mgl/mgl0_14.swf"), context);
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