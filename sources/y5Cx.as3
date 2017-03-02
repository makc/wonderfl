// forked from keim_at_Si's Nomltest on Flash

// Explosion renderer: http://wonderfl.net/c/g9Cm
// Wonderfl score SWF: http://wonderfl.net/c/hxAb forked from http://wonderfl.net/c/cuY4
// Ball texture used in Painter class created from http://www.flickr.com/photos/c0t0s0d0/2363125133/ and http://www.flickr.com/photos/crystalflickr/53184232/

package {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
    import org.si.b3.*;

    [SWF(width="465", height="465", frameRate="30", backgroundColor="0")]
    public class main extends Sprite {
        private var tf:TextField;

        function main() {
            Wonderfl.capture_delay(30);
            stage.scaleMode = "noScale";
            stage.quality = "medium";
            tf = new TextField();
            tf.text = "arranging, please wait...";
            tf.scaleX = tf.scaleY = 2;
            tf.textColor = 0xA09080;
            tf.width = 225;
            tf.autoSize = "center";
            tf.y = (450-tf.height)/3;
            addChild(tf);
            resManager = new ResourceManager(onResourceLoaded, loaderInfo.parameters);
            scrManager = new ScoreManager();
            actManager = new ActorManager();
            painter = new Painter();
            occ = new Sprite();
            occ.addChild(bg = new Background(3));
            x=y=8;
        }
        
        public function onResourceLoaded() : void {
            removeChild(tf);
            mc = new CMLMovieClipEx(occ, 0, 0, 450, 450, 0xffffff, true, setup);
            mc.screen = mc.bitmapData = new BitmapData(450, 450, true, 0); // hack - should work as long as setSize isn't called.
            mc.control.map(CMLMovieClip.KEY_ESCAPE, "Q");
            mc.scene.register("title",     new TitleScene());
            mc.scene.register("main",      new MainScene());
            mc.scene.register("gameover",  new GameoverScene());
            mc.scene.id = "title";
            fx = new VolumetricPointLight(450, 450, occ, [0xc06030, 0x3060c0]);
            fx.setBufferSize(0x2000);
            fx.intensity = 4;
            addChild(fx);
        }
        
        public function setup() : void {
            resManager.sionDriver.bpm = 152;
            resManager.sionDriver.play();
        }
    }
}


// import --------------------------------------------------------------------------------
import flash.net.*;
import flash.geom.*;
import flash.events.*;
import flash.display.*;
import flash.filters.*;
import flash.utils.*;
import org.si.sion.*;
import org.si.sion.utils.soundloader.*;
import org.si.cml.*;
import org.si.cml.extensions.*;
import org.si.cml.namespaces.*;
import org.si.b3.*;
import frocessing.color.*;
import net.wonderfl.utils.WonderflAPI;

// constant variables --------------------------------------------------------------------------------
const extendScore:int = 200000;
const defaultLife:int = 3;
const RANKING_WINDOW_URL:String = "http://swf.wonderfl.net/swf/usercode/7/7a/7af0/7af0cf8f5b74242e7eb21337bfd241a9682d2407.swf";
const checkPolicyFile:Boolean = true;
/* // local
const EXPLOSION_URL :String = "explosion.swf";
const BALL_URL :String = "ball.png";
const CHARA_MAP_URL :String = "charactor.png";
const SOUND_FONT_URL:String = "sound.png";
/*/ // wonderfl
const EXPLOSION_URL :String = "http://swf.wonderfl.net/swf/usercode/7/71/7139/71392303d34b641ce53a4768c89007ebe31181c5.swf"; // keim_at_Si's Explosion Rendering - http://wonderfl.net/c/g9Cm
const BALL_URL :String = "http://assets.wonderfl.net/images/related_images/8/8d/8d27/8d27f29ab81436f237eff1edc5efb90d38e5289e";
const CHARA_MAP_URL :String = "http://assets.wonderfl.net/images/related_images/e/e4/e488/e4889d7b98486f0edf339bb45c0a4114255988c2";
const SOUND_FONT_URL:String = "http://assets.wonderfl.net/images/related_images/a/aa/aa9a/aa9a00df008e71a100500b5c90da9b71734af5e8";
//*/

// global instance --------------------------------------------------------------------------------
var mc:CMLMovieClipEx;
var resManager:ResourceManager;
var scrManager:ScoreManager;
var actManager:ActorManager;
var painter:Painter;
var occ:Sprite;
var bg:Background;
var fx:VolumetricPointLight;

// Scenes -------------------------------------------------------------------------------- 
class TitleScene {
    private var menuIndex:int, startLevel:int;
    private var menu:Array = ["Press [Z] Key To Start", "Show Net Ranking", "Clear Cookie", "Debug Mode"];
    private var anim:Array = [0, 4, 7, 9, 10, 9, 7, 4];
    public function enter() : void {
        mc.fps.reset();
        menuIndex = 0;
        startLevel = 0;
        scrManager.reset(true);
        actManager.reset();
        scrManager.debugMode = false;
    }
    
    public function update() : void {
        if (!mc.pause) {
            if (mc.control.isHitted(CMLMovieClip.KEY_BUTTON0)) {
                if (menuIndex == 2) {
                    scrManager.clearCookie();
                    scrManager.reset(true);
                } else if (menuIndex == 1) {
                    mc.pause = true;
                    resManager.showRanking(function(e:Event) : void { mc.pause = false; });
                } else mc.scene.id = "main";
            } else if (mc.control.isHitted(CMLMovieClip.KEY_RIGHT)) {
                if (--menuIndex == -1) menuIndex = menu.length-1;
                resManager.sionDriver.noteOn(67, resManager.beep, 1);
            } else if (mc.control.isHitted(CMLMovieClip.KEY_LEFT)) {
                if (++menuIndex == menu.length) menuIndex = 0;
                resManager.sionDriver.noteOn(67, resManager.beep, 1);
            } else {
                startLevel -= mc.control.y * 5;
                if (startLevel < 0) startLevel = 0;
                else if (startLevel > 250) startLevel = 250;
            }
        }
    }
    
    public function draw() : void {
        var menuString:String = menu[menuIndex], width:int = menuString.length * 8, 
            frameCount:int = mc.fps.totalFrame;
        bg.draw();
        scrManager.draw();
        resManager.print(-166, -56, "NOMLBIRD FL", resManager.lfonttex, 32);
        resManager.print(-width, 160, menuString, resManager.fonttex, 16);
        resManager.print(-196-anim[frameCount&7], 160, "{", resManager.fonttex, 16);
        resManager.print( 180+anim[frameCount&7], 160, "}", resManager.fonttex, 16);
        resManager.print(-128, 90, "START LEVEL : " + startLevel.toString(), resManager.fonttex, 16); 
        fx.render();
    }
    
    public function exit() : void {
        scrManager.startLevel = startLevel;
        scrManager.debugMode = (menuIndex == 3);
    }
}

class MainScene {
    public function enter() : void {
        mc.fps.reset();
        scrManager.reset(false);
        actManager.reset();
        actManager.start();
        resManager.sionDriver.play(resManager.bgm);
        resManager.sionDriver.playSound(6,1,0,0,2);
    }
    
    public function update() : void {
        scrManager.update();
        actManager.update();
        if (mc.control.getPressedFrame(CMLMovieClip.KEY_ESCAPE) > 15) {
            resManager.sionDriver.play();
            mc.scene.id = "title";
        }
    }
    
    public function draw() : void {
        var f:int, t:Number;
        bg.draw();
        scrManager.draw();
        actManager.draw();
        if (mc.fps.totalFrame < 90) {
            f = mc.fps.totalFrame;
            if (f < 70) {
                t = (f<50) ? ((40-f) * (40-f) - 100) * 0.2 : 0;
                resManager.print(-102-t, -32, "ARE YOU", resManager.lfonttex, 32);
                resManager.print(-102+t,   0, "READY ?", resManager.lfonttex, 32);
            } else {
                resManager.print(-70, -16, "GO !!", resManager.lfonttex, 32);
            }
        }
        fx.render();
    }

    public function exit() : void {}
}

class GameoverScene {
    private var referenceRecord:Boolean;
    public function enter() : void {
        referenceRecord = (scrManager.delayedFrames > mc.fps.totalFrame*0.1);
        mc.fps.reset();
        resManager.sionDriver.play(resManager.gameover);
        resManager.sionDriver.playSound(2,1,0,0,2);
    }
    
    public function update() : void {
        if (!mc.pause) {
            scrManager.update();
            actManager.update();
            if (mc.fps.totalFrame > 60 && mc.control.isHitted(CMLMovieClip.KEY_BUTTON0)) {
                if (!referenceRecord && scrManager.checkResult()) {
                    mc.pause = true;
                    resManager.registerRanking(function(e:Event) : void {
                        mc.pause = false;
                        mc.scene.id = "title";
                    });
                } else mc.scene.id = "title";
            }
        }
    }
    
    public function draw() : void {
        bg.draw();
        scrManager.draw();
        actManager.draw();
        resManager.print(-136, -32, "GAME OVER", resManager.lfonttex, 32);
        if (referenceRecord) resManager.print(-96, 16, "REFERENCE=RECORD", resManager.numtex, 12, 48);
        fx.render();
    }
    
    public function exit() : void {}
}

// Managers --------------------------------------------------------------------------------
class ResourceManager {
    public var bgangle:Number = -90;
    public var sionDriver:SiONDriver = new SiONDriver();
    public var damageColt:ColorTransform = new ColorTransform(1,1,1,1,-128,-128,-128,0);
    public var playerTexture:CMLMovieClipTexture, shotTexture:CMLMovieClipTexture;
    public var fonttex:CMLMovieClipTexture, lfonttex:CMLMovieClipTexture;
    public var numtex:CMLMovieClipTexture, lnumtex:CMLMovieClipTexture;
    public var scoreTextures:Array, explosionTextures:Array, enemyTextures:Array, flashingEnemyTextures:Array, bulletTextures:Array;
    public var lifeUpTexture:CMLMovieClipTexture;
    public var bgm:SiONData, gameover:SiONData, sequences:*, beep:SiONVoice;
    public var charactorMap:BitmapData, stageSequence:CMLSequence;
    public var groupID:Array = [0, 0, 0, 3, 3, 3, 6, 7, 7, 9, 10, 9, 0, 13, 0];
    public var shotSeq:Array, groupSeq:Array, enemySeq:Array;
    public var onResourceLoaded:Function, rankingMaker:*, loaderInfoParameters:*;
    function ResourceManager(onResourceLoaded:Function, loaderInfoParameters:*) {
        this.loaderInfoParameters = loaderInfoParameters;
        // Loader --------------------------------------------------
        var loader:SoundLoader = new SoundLoader();
        this.onResourceLoaded = onResourceLoaded;
        loader.setURL(new URLRequest(EXPLOSION_URL), "exp", null, checkPolicyFile);
        loader.setURL(new URLRequest(BALL_URL), "ball", "img", checkPolicyFile);
        loader.setURL(new URLRequest(CHARA_MAP_URL), "cmap", "img", checkPolicyFile);
        loader.setURL(new URLRequest(SOUND_FONT_URL), "sample", "ssfpng", checkPolicyFile);
        loader.setURL(new URLRequest(RANKING_WINDOW_URL), "ranking", "swf");
        //loader.setURL(new URLRequest("nomltest.mml"), "bgm", "txt");
        //loader.setURL(new URLRequest("gameover.mml"), "gameover", "txt");
        //loader.setURL(new URLRequest("script.cml"), "script", "txt");
        loader.addEventListener(Event.COMPLETE, _onComplete);
        loader.loadAll();
    }
    private function _onComplete(e:Event) : void {
        var data:* = SoundLoader(e.target).hash, bmp:BitmapData = new BitmapData(128, 128, true, 0xffffffff),
            red:Array=[0.7,0.4,0.4], grn:Array=[0.4,0.7,0.4], blu:Array=[0.4,0.4,0.7], 
            i:int, j:int, c:int, mat:Matrix = new Matrix(), t:CMLMovieClipTexture, bd:BitmapData, lbl:String;
        
        // CannonML --------------------------------------------------
        CMLObject.setGlobalRankRange(0, 999);
        CMLSequence.registerUserCommand("rungroup",   _onRunGroup, 1);
        CMLSequence.registerUserCommand("groupbonus", _onGroupBonus, 1);
        
        // Textures --------------------------------------------------
        painter.ball = data["ball"].bitmapData;
        painter.createSprites();
        charactorMap = data["cmap"].bitmapData;
        bmp.copyChannel(charactorMap, bmp.rect, bmp.rect.topLeft, 1, 8);
        playerTexture = painter.birdCMCT;
        shotTexture   = painter.shotCMCT;
        fonttex  = newTexture(bmp, 0, 64, 8, 8, 96, 2, [0.65, 0.6, 0.5], true, false);
        lfonttex = newTexture(bmp, 0, 64, 8, 8, 96, 4, [0.65, 0.6, 0.5], true, false);
        numtex   = newTexture(bmp, 0, 112, 6, 6, 42, 2, [0.375, 0.375, 0.375], false, false);
        lnumtex  = newTexture(bmp, 0, 112, 6, 6, 42, 4, [0.5, 0.5, 0.5],    false, false);
        // text
        scoreTextures = [];
        for (i=0; i<=50; i++) scoreTextures.push(renderText(i.toString()+"0", numtex));
        for (i=1; i<4; i++) scoreTextures[i*100] = renderText(i.toString()+"000", lnumtex);
        lifeUpTexture = renderText("1UP", lnumtex);
        enemyTextures = [];
        flashingEnemyTextures = [];
        explosionTextures = [];
        // enemies
        var rr:CMLMovieClipTexture = painter.rollerCMCT;
        var gr:CMLMovieClipTexture = painter.texColorMatrix(painter.rollerCMCT, Painter.hue110);
        var br:CMLMovieClipTexture = painter.texColorMatrix(painter.rollerCMCT, Painter.hue220);
        var fr:CMLMovieClipTexture = painter.texColorMatrix(painter.rollerCMCT, Painter.flash);
        for (i=0; i<4; i++) {
            enemyTextures.push(br, gr, rr);
            flashingEnemyTextures.push(fr, fr, fr);
        }
        var o1:CMLMovieClipTexture = painter.octopusCMCT;
        var o2:CMLMovieClipTexture = painter.texColorMatrix(painter.octopusCMCT, Painter.hue90);
        var o3:CMLMovieClipTexture = painter.texColorMatrix(painter.octopusCMCT, Painter.hue180);
        var o4:CMLMovieClipTexture = painter.texColorMatrix(painter.octopusCMCT, Painter.hue270);
        var fo:CMLMovieClipTexture = painter.texColorMatrix(painter.octopusCMCT, Painter.flash);
        enemyTextures.push(o1, o2, o3, o4);
        flashingEnemyTextures.push(fo, fo, fo, fo);
        // explosions
        var expBmds:Vector.<BitmapData> = data["exp"].explosion();
        var patterns:Vector.<CMLMovieClipTexture> = new Vector.<CMLMovieClipTexture>();
        var exp:CMLMovieClipTexture;
        var f:ColorMatrixFilter = new ColorMatrixFilter([
                1,0,0,0,0,
                0,1,0,0,0,
                0,0,1,0,0,
                0.66,0.66,0.66,0,0
            ]);
        var bmd:BitmapData;
        for(i=0; i<(expBmds.length-2); i+=2) {
            bmd = new BitmapData(expBmds[i].width, expBmds[i].height, true);
            bmd.applyFilter(expBmds[i], expBmds[i].rect, expBmds[i].rect.topLeft, f);
            patterns[i/2] = new CMLMovieClipTexture(bmd);
        }
        patterns[0].animationPattern = patterns;
        painter.autocrop(patterns[0]);
        for(i=0; i<12; i++) explosionTextures.push(patterns[0]); // small explosions
        patterns = new Vector.<CMLMovieClipTexture>();
        for(i=0; i<(expBmds.length-2); i+=2) {
            bmd = new BitmapData(expBmds[i].width*2, expBmds[i].height*2, true);
            bmd.draw(expBmds[i], new Matrix(2, 0, 0, 2, 0, 0));
            bmd.applyFilter(bmd, bmd.rect, bmd.rect.topLeft, f);
            patterns[i/2] = new CMLMovieClipTexture(bmd);
        }
        patterns[0].animationPattern = patterns;
        painter.autocrop(patterns[0]);
        explosionTextures.push(patterns[0], patterns[0], patterns[0]); // large explosions
        for(i=0; i<expBmds.length; i++) expBmds[i].dispose(); // destroy original bitmaps
        
        // bullets
        bulletTextures = [
            painter.ellipse([14541823,2640639,5911706,4210752],[1,1,1,0],[40,82,172,255]   , 16, 16),
            painter.ellipse([14541823,9699112,3447413,4210752],[1,1,1,0],[40,82,172,255]   , 16, 16),
            painter.ellipse([14541823,16728360,10105932,4210752],[1,1,1,0],[40,82,172,255] , 16, 16),
            painter.ellipse([14541823,2640639,5911706,4210752],[1,1,1,0],[40,82,172,255]   , 24, 7),
            painter.ellipse([14541823,9699112,3447413,4210752],[1,1,1,0],[40,82,172,255]   , 24, 7),
            painter.ellipse([14541823,16728360,10105932,4210752],[1,1,1,0],[40,82,172,255] , 24, 7),
            painter.ellipse([14541823,2640639,5911706,4210752],[1,1,1,0],[40,82,172,255]   , 24, 7)
        ];
            
        // Sound --------------------------------------------------
        beep = new SiONVoice(0, 0, 63, 36, 4, 0, 0, -4);
        sionDriver.noteOnExceptionMode = SiONDriver.NEM_IGNORE;
        sionDriver.setSamplerTable(0, data["sample"].samplerTables[0]);
        //bgm = sionDriver.compile(data["bgm"]);
        bgm = sionDriver.compile(mmlMain);
        //gameover = sionDriver.compile(data["gameover"]);
        gameover = sionDriver.compile(mmlGameOver);
        
        // Sequences --------------------------------------------------
        //stageSequence = new CMLSequence(data["script"]);
        stageSequence = new CMLSequence(cmlScript);
        sequences = stageSequence.childSequence;
        shotSeq = [sequences["S1"],sequences["S2"],sequences["S3"]];
        groupSeq = [];
        enemySeq = [];
        for (i=0; i<32; i++) {
            if ((lbl = "G" + i.toString()) in sequences) groupSeq[i] = sequences[lbl];
            if ((lbl = "E" + i.toString()) in sequences) enemySeq[i] = sequences[lbl];
        }

        // Ranking window
        var param:* = {
            tweet:"N0MLB1RD FL [SCORE:%SCORE%/LEVEL:%SCORE2%] #wonderfl", 
            scoreTitle:"SCORE", 
            title:"N0MLB1RD FL Net Ranking"
        }
        rankingMaker = data["ranking"];
        rankingMaker.initialize(new WonderflAPI(loaderInfoParameters), param);
        rankingMaker.score2(12, "Lv.%SCORE%", "LEVEL");
        rankingMaker.score3(15, "%SCORE% eat", "EATEN");

        onResourceLoaded();
    }
    
    private var shadow:DropShadowFilter = new DropShadowFilter(3, 45, 0, 0.5, 4, 4);
    private function newTexture(bmp:BitmapData, x:Number, y:Number, w:Number, h:Number, a:int, scale:Number, c:Array, shd:Boolean, flash:Boolean) : CMLMovieClipTexture {
        var org:CMLMovieClipTexture = new CMLMovieClipTexture(bmp, x, y, w, h, false, a, int(bmp.width/w)*w-w), tex:CMLMovieClipTexture; // int(bmp.width/w)*w-w (for avoid bug)
        tex = org.cutout(scale, scale, 0, new ColorTransform(c[0],c[1],c[2],1), 0, (shd)?6:0);
        if (flash) {
            tex.animationPattern = new Vector.<CMLMovieClipTexture>(2, true);
            tex.animationPattern[0] = tex;
            tex.animationPattern[1] = org.cutout(scale, scale, 0, new ColorTransform(1-(1-c[0])*0.6,1-(1-c[1])*0.6,1-(1-c[2])*0.6,1), 0, (shd)?6:0);
        }
        if (shd) {
            var i:int, imax:int = tex.animationCount, bmd:BitmapData;
            for (i=0; i<imax; i++) {
                bmd = tex.animationPattern[i].bitmapData;
                bmd.applyFilter(bmd, bmd.rect, bmd.rect.topLeft, shadow);
            }
        }
        return tex;
    }

    public function renderText(txt:String, font:CMLMovieClipTexture, asciiOffset:int=48) : CMLMovieClipTexture {
        var pt:Point = new Point(), i:int, imax:int=txt.length, t:CMLMovieClipTexture, 
            bd:BitmapData = new BitmapData(font.width*imax, font.height, true, 0);
        for (i=0; i<imax; i++) {
            t = font.animationPattern[txt.charCodeAt(i) - asciiOffset];
            bd.copyPixels(t.bitmapData, t.rect, pt);
            pt.x += font.width;
        }
        return new CMLMovieClipTexture(bd);
    }
    
    public function print(x:Number, y:Number, txt:String, font:CMLMovieClipTexture, pitch:int, asciiOffset:int=32) : void {
        var tx:Number=x+8, ty:Number=y+8, i:int, imax:int=txt.length;
        for (i=0; i<imax; i++) {
            mc.copyTexture(font, tx, ty, txt.charCodeAt(i)-asciiOffset);
            tx += pitch;
        }
    }
    
    public function showRanking(onClose:Function) : void {
        var window:* = rankingMaker.makeRankingWindow();
        window.addEventListener(Event.CLOSE, onClose);
        mc.parent.addChild(window);
    }
    
    public function registerRanking(onClose:Function) : void {
        var window:* = rankingMaker.makeScoreWindow(scrManager.score, scrManager.level, scrManager.eaten);
        window.addEventListener(Event.CLOSE, onClose);
        mc.parent.addChild(window);
    }
    
    // called from &rungroup command in CML
    private function _onRunGroup(fbr:CMLFiber, args:Array) : void {
        var enemyType:int = (args[0]==0) ? int(Math.random()*15) : (args[0]-1);
        Group.run(groupID[enemyType], enemyType);
    }
    
    // called from &groupbonus command in CML
    private function _onGroupBonus(fbr:CMLFiber, args:Array) : void {
        var g:Group = fbr.object as Group;
        if (g) {
            g.finished = true;
            g.bonus = args[0];
        }
    }
}

//--------------------------------------------------------------------------------
class ScoreManager {
    public var score:int, level:int, eaten:int, life:int, eatBonus:int, nextExtend:int, gameoverLevel:int;
    public var bestResult:*, startLevel:int, debugMode:Boolean, delayedFrames:int;
    private var _scoreDraw:int, _levelDraw:int, _eatenDraw:int, _lifeDraw:int;
    private var _scoreText:String, _levelText:String, _eatenText:String, _lifeText:String;

    function ScoreManager() {
        _loadCookie();
        reset(false);
    }
    
    public function reset(setHighScore:Boolean) : void {
        CMLObject.globalRank = startLevel;
        _scoreDraw = score = (setHighScore) ? bestResult.score : 0;
        _levelDraw = level = (setHighScore) ? bestResult.level : startLevel;
        _eatenDraw = eaten = (setHighScore) ? bestResult.eaten : 0;
        _scoreText = "SCORE:" + ("000000000" + _scoreDraw.toString()).substr(-10);
        _levelText = "LEVEL:" + ("00" + _levelDraw.toString()).substr(-3);
        _eatenText = "EATEN:" + ("00000" + _eatenDraw.toString()).substr(-6);
        _lifeText  = "LIFE :";
        _lifeDraw = 0;
        life = (debugMode) ? 0 : defaultLife;
        eatBonus = 2;
        nextExtend = extendScore;
        delayedFrames = 0;
    }
    
    public function update() : void {
        var dif:int = (score - _scoreDraw + 7) >> 3;
        level = int(CMLObject.globalRank);
        _scoreDraw += dif;
        if (dif > 0) {
            _scoreText = "SCORE:" + ("000000000" + _scoreDraw.toString()).substr(-10);
        }
        if (_levelDraw != level) {
            _levelDraw = level;
            _levelText = "LEVEL:" + ("00" + _levelDraw.toString()).substr(-3);
        }
        if (_eatenDraw != eaten) {
            _eatenDraw = eaten;
            _eatenText = "EATEN:" + ("00000" + _eatenDraw.toString()).substr(-6);
        }
        if (_lifeDraw != life) {
            _lifeDraw = life;
            if (debugMode) {
                _lifeText = "MISS :" + _lifeDraw.toString();
            } else {
                _lifeText = "LIFE :";
                for (var i:int=0; i<_lifeDraw; i++) _lifeText += "|";
            }
        }
        if (mc.fps.frameSkipLevel > 3) delayedFrames++;
    }
    
    public function draw() : void {
        resManager.print(-220, -220, _scoreText, resManager.fonttex, 16);
        resManager.print(-220, -204, _levelText, resManager.fonttex, 16);
        resManager.print(-220, -188, _eatenText, resManager.fonttex, 16);
        resManager.print(-220, -172, _lifeText,  resManager.fonttex, 16);
        if (debugMode) {
            resManager.print(-223, 190, "PRESS [Q] TO EXIT", resManager.fonttex, 16);
            resManager.print(-223, 209, "FRAME DELAY :"+mc.fps.delayedFrames.toFixed(2), resManager.fonttex, 16);
        }
    }
    
    public function checkResult() : Boolean {
        return _updateCookie();
    }
    
    public function destroyAll(groupBonus:int) : void {
        eatBonus += 3;
        if (eatBonus > 50) eatBonus = 50;
        addScore(groupBonus);
    }
    
    public function destroyAllFailed() : void {
        eatBonus -= 2;
        if (eatBonus < 1) eatBonus = 1;
    }
    
    public function miss() : Boolean {
        actManager.destroyAllEnemies();
        eatBonus>>= 1;
        if (eatBonus < 1) eatBonus = 1;
        if (debugMode) {
            life++;
        } else {
            if (--life < 0) {
                gameoverLevel = level;
                mc.scene.id = "gameover"
                return true;
            }
        }
        return false;
    }
    
    public function eat() : int {
        eaten++;
        addScore(eatBonus * 10);
        return eatBonus;
    }
    
    public function addScore(gain:int) : void {
        score += gain;
        if (score >= nextExtend) {
            nextExtend += extendScore;
            life++;
            resManager.sionDriver.playSound(5,1,0,0,3);
            Particle.$(actManager.player.x, actManager.player.y, 0, -10, 0, 0.75, resManager.lifeUpTexture);
        }
    }
    
    public function clearCookie() : void {
        var so:SharedObject = SharedObject.getLocal("savedData");
        if (so) so.clear();
        bestResult = {"score":0, "level":0, "lines":0};
    }
    
    private function _loadCookie() : void {
        var so:SharedObject = SharedObject.getLocal("savedData");
        bestResult = (so && "bestResult" in so.data) ? (so.data.bestResult) : {"score":0, "level":0, "eaten":0};
    }
    
    private function _updateCookie() : Boolean {
        if (startLevel != 0 || debugMode) return false;
        var updated:Boolean = false, so:SharedObject, isHighScore:Boolean = (score > bestResult.score);
        if (score > bestResult.score) { updated = true; bestResult.score = score; }
        if (gameoverLevel > bestResult.level) { updated = true; bestResult.level = gameoverLevel; }
        if (eaten > bestResult.eaten) { updated = true; bestResult.eaten = eaten; }
        if (updated && (so = SharedObject.getLocal("savedData"))) {
            so.data.bestResult = bestResult;
            so.flush();
        }
        return (isHighScore);
    }
}

//--------------------------------------------------------------------------------
class ActorManager {
    public var shots:ActorFactory;
    public var enemies:ActorFactory;
    public var bullets:ActorFactory;
    public var player:Player;
    public var master:Group;
    public var frameCounter:int;
    public var groupID:int;
    public var pauseRoot:Boolean = false;
    
    function ActorManager() {
        shots     = new ActorFactory(Shot, 0, 0);
        enemies   = new ActorFactory(Enemy, 0, 1);
        bullets   = new ActorFactory(Bullet, 0, 2);
        player = new Player();
        player.evalIDNumber = 3;
        player.drawPriority = enemies.drawPriority;
        Particle.initialize(640);
    }
    
    public function reset() : void {
        CMLObject.destroyAll(0);
        Particle.reset();
    }
    
    public function start() : void {
        player.create(0, 180);
        master = new Group();
        master.create(0, 0);
        master.execute(resManager.stageSequence);
    }
    
    public function draw() : void {
        Particle.draw();
        Actor.draw();
    }
    
    public function update() : void {
        // Actor.update() is called from CMLMovieClip
        Particle.update();
        if (player.status != Player.STATUS_INVISIBLE) Actor.testf(bullets.evalIDNumber, player.evalIDNumber);
        Actor.testf(shots.evalIDNumber, enemies.evalIDNumber);
    }
    
    public function destroyAllEnemies() : void {
        eval(enemies.evalIDNumber, function(act:Actor) : void { 
            act.destroy(2); 
        });
        eval(bullets.evalIDNumber, function(act:Actor) : void { 
            act.destroy(0);
        });
    }
    
    static public function eval(evalID:int, func:Function) : void {
        var act:Actor, list:Actor = Actor._cml_internal::_evalLayers[evalID];
        for (act=list._cml_internal::_nextEval; act!=list; act=act._cml_internal::_nextEval) func(act);
    }
}

// Actors --------------------------------------------------------------------------------
class Player extends Actor {
    static public const STATUS_TRANSPARENT:int = 0;
    static public const STATUS_NORMAL:int = 1;
    static public const STATUS_INVISIBLE:int = 2;
    public var status:int, statuFrameCount:int, animationCount:int, hitSize2:Number;
    public var shotFlag:int, eatRangeShape:Shape, eatRangeAngle:Number;
    public var eatRangeDraw:Number;
    public var playerSpeed:Array = [10, 9, 9, 5];
    public var eatRange:Array = [60, 45, 30, 55];
    public var roll:int = 0;
    
    public function Player() {
        scopeEnabled = false;
        eatRangeAngle = 0;
        size = 60;
        hitSize2 = 16;
        eatRangeDraw = 0;
        eatRangeShape = new Shape();
    }
    
    override public function onCreate() : void {
        animationCount = 0;
        shotFlag = 0;
        setAsDefaultTarget();
        expandScope(-16-mc.scopeMargin, -16-mc.scopeMargin);
        status = STATUS_INVISIBLE;
        statuFrameCount = 30;
    }
    
    override public function onUpdate() : void {
        var ix:int = mc.control.x, iy:int = mc.control.y,
            flg:uint = (mc.control.flag >> 4) & 3,
            dx:Number = ix * ((iy==0) ? 1 : 0.707), dy:Number = iy * ((ix==0) ? 1 : 0.707),
            spd:Number = playerSpeed[flg];
        if (status != STATUS_INVISIBLE) {
            x += dx * spd;
            y += dy * spd;
            limitScope();
            if (shotFlag != flg) {
                halt();
                shotFlag = flg;
                if (shotFlag > 0) execute(resManager.shotSeq[shotFlag-1]);
                size = eatRange[shotFlag];
            }
            eatRangeAngle += eatRangeDraw * 0.002;
                 if (size > eatRangeDraw) eatRangeDraw += 2;
            else if (size < eatRangeDraw) eatRangeDraw -= 2;
        }
        
        if (--statuFrameCount == 0) {
            if (status == STATUS_TRANSPARENT) status = STATUS_NORMAL;
            else setTransparent();
        }

        if(mc.control.x) {
            roll += mc.control.x;
            if(roll>9) roll = 9;
            if(roll<-9) roll = -9;
        } else {
            if(roll) roll += (roll>0 ? -1 : 1);
        }

        if(fx.intensity > 4) fx.intensity *= 0.9;
        else fx.intensity = 4;
    }

    override public function onDraw() : void {
        var frame:int = (animationCount % 15) * 7;
        frame += 3 + Math.round(roll/3);
        animationCount++;
        if (status != STATUS_INVISIBLE) {
            if ((status == STATUS_NORMAL) || (animationCount & 1)) {
                mc.copyTexture(resManager.playerTexture, x, y, frame);
            }
            updateEatRange();
            mc.draw(eatRangeShape, x, y)
        } else {
            mc.copyTexture(resManager.playerTexture, x, y + ((statuFrameCount-6) * (statuFrameCount-6) - 36) * 0.4, frame);
        }
    }
    
    override public function onFireObject(args:Array) : CMLObject {
        return actManager.shots.newInstance();
    }
    
    override public function onHit(act:Actor) : void {
        if (status == STATUS_TRANSPARENT) return;
        var dx:Number = act.x - x, dy:Number = act.y - y, i:int;
        if (dx * dx + dy * dy < hitSize2) {
            setDestruction(scrManager.miss());
            fx.intensity = 128;
        }
    }
    
    public function setTransparent() : void {
        status = STATUS_TRANSPARENT;
        statuFrameCount = 60;
    }
    
    public function setDestruction(gameover:Boolean) : void {
        halt();
        status = STATUS_INVISIBLE;
        if (!gameover) {
            statuFrameCount = 30;
            resManager.sionDriver.playSound(2,1,0,0,2);
        } else {
            statuFrameCount = -1;
        }
    }
    
    private var cmd:Vector.<int> = Vector.<int>([1,2,2,2,2]);
    private var path:Vector.<Number> = new Vector.<Number>();
    private function updateEatRange() : void {
        var g:Graphics = eatRangeShape.graphics,
            sin:Number = Math.sin(eatRangeAngle) * eatRangeDraw,
            cos:Number = Math.cos(eatRangeAngle) * eatRangeDraw,
            asin:Number = (sin<0) ? -sin : sin,
            acos:Number = (cos<0) ? -cos : cos;
        path[0] =  cos; path[1] = sin;
        path[2] = -sin; path[3] = cos;
        path[4] = -cos; path[5] = -sin;
        path[6] =  sin; path[7] = -cos;
        path[8] =  cos; path[9] =  sin;
        g.clear();
        g.lineStyle(1, 0xffffff, 0.4);
        g.drawPath(cmd, path);
        g.drawRect(-acos, -asin, acos*2, asin*2);
    }
}

//--------------------------------------------------------------------------------
class Shot extends Actor {
    public function Shot() { size = 10; }
    override public function onCreate() : void { }//scopeYmax = 400; }
    override public function onDraw() : void { 
        mc.copyTexture(resManager.shotTexture, x, y,  31 & (angleVelocity*0.0888+16.5)); 
    }
    override public function onHit(act:Actor) : void { destroy(1); }
}

//--------------------------------------------------------------------------------
class Group extends CMLObject {
    static private var _freeList:Array = [];
    static public function run(groupType:int, enemyType:int) : void { 
        var group:Group = _freeList.pop() || new Group();
        group.create(0, 0);
        group.execute(resManager.groupSeq[groupType]);
        group.enemyType = enemyType;
        group.bonus = group.childCount = 0;
        group.destroyAll = true;
        group.finished = false;
    }
    public var enemyType:int, childCount:int, finished:Boolean, destroyAll:Boolean, bonus:int;
    function Group() { }
    public function onChildDestroy(enemy:Enemy) : int {
        if (enemy.destructionStatus == 0) destroyAll = false;
        if (--childCount == 0 && finished) {
            if (bonus>0) {
                if (destroyAll) {
                    scrManager.destroyAll(bonus);
                    Particle.$(enemy.x, enemy.y, 0, -6, 0, 0.5, resManager.scoreTextures[bonus]);
                } else {
                    scrManager.destroyAllFailed();
                }
            }
            destroy(0);
        }
        return 0;
    }
    override public function onDestroy() : void { _freeList.push(this); }
    override public function onNewObject(args:Array) : CMLObject {
        var enemy:Enemy = actManager.enemies.newInstance();
        enemy.type = enemyType;
        enemy.group = this;
        childCount++;
        return enemy;
    }
}

//--------------------------------------------------------------------------------
class Enemy extends Actor {
    private var flagDamage:int = 0, animationCount:int = 0;
    public  var type:int, group:Group, texture:CMLMovieClipTexture, flashTexture:CMLMovieClipTexture, bonus:int;
    public function Enemy() {}
    override public function onCreate() : void {
        var seq:CMLSequence = resManager.enemySeq[type];
        flagDamage = 0;
        life = seq.getParameter(0);
        bonus = seq.getParameter(1);
        texture = resManager.enemyTextures[type];
        flashTexture = resManager.flashingEnemyTextures[type];
        size = texture.center.x;
        execute(seq);
    }
    override public function onDestroy() : void {
        group.onChildDestroy(this);
        if (destructionStatus > 0) {
            Particle.$(x, y, vx, vy, -vx*0.04, -vy*0.04, resManager.explosionTextures[type]);
            if (destructionStatus == 1) {
                Particle.$(x, y, 0, -6, 0, 0.5, resManager.scoreTextures[bonus]);
            }
        }
    }
    override public function onDraw() : void { 
        --flagDamage;
        animationCount = (animationCount+1) % texture.animationCount;
        var tex:CMLMovieClipTexture = isFlashing() ? flashTexture : texture;
        if(type>=12) { // octopus
            mc.copyTexture(tex, x, y, animationCount);
        } else { // roller
            var rot:int = 31 & (angleVelocity*0.0888+16.5);
            var anim:int = (animationCount << 5) % texture.animationCount;
            var frame:int = anim | rot;
            mc.copyTexture(tex, x, y, frame);
        }
    }
    override public function onFireObject(args:Array) : CMLObject { return actManager.bullets.newInstance().init(args); }
    override public function onHit(act:Actor) : void {
        flagDamage = 6;
        if (life != 0) {
            life -= 1;
            if (life <= 0) {
                destroy(1);
                resManager.sionDriver.playSound((size>24)?1:3,1,0,0,1);
                scrManager.addScore(bonus * 10);
            }
        }
    }
    private function isFlashing() : int {
        return (flagDamage>0) ? (flagDamage&1) : 0;
    }
}

//--------------------------------------------------------------------------------
class Bullet extends Actor {
    public var texture:CMLMovieClipTexture;
    public var ac:int = 0, acmax:int = 0, acspd:int = 0;
    public var shape:int = 0;
    
    public function Bullet() { size = 4; }
    public function init(args:Array) : Bullet { 
        shape = args[0];
        texture = resManager.bulletTextures[shape];
        acspd = 1;
        life = 1;
        acmax = texture.animationCount << acspd;
        return this;
    }
    override public function onCreate() : void { ac = (shape<3) ? 0 : ((angleOnStage*0.08888888888888889+8.5)&15); }
    override public function onUpdate()       : void { if (shape<3 && ++ac==acmax) ac = 0; super.onUpdate(); }
    override public function onDraw()         : void { mc.copyTexture(texture, x, y,  31 & (angleVelocity*0.0888+16.5)/*ac>>acspd*/); }
    override public function onFireObject(args:Array) : CMLObject { return actManager.bullets.newInstance().init(args); }
    override public function onHit(act:Actor) : void {
        var dx:Number = (vx < 0) ? -vx : vx, dy:Number = (vy < 0) ? -vy : vy,
            v:Number = (dx > dy) ? (dx + dy * 0.2928932188134524) : (dy + dx * 0.2928932188134524);
        life -= v * 0.0125;
        if (life <= 0) {
            destroy(1);
            resManager.sionDriver.playSound(4,1,0,0,4);
            dx = actManager.player.x - x;
            dy = actManager.player.y - y;
            v = 3 / Math.sqrt(dx*dx+dy*dy);
            Particle.$(x, y, -dx*v, -dy*v, dx*v*0.18, dy*v*0.18, resManager.scoreTextures[scrManager.eat()]);
        }
    }
}

//--------------------------------------------------------------------------------
class Particle {
    public var x:Number, y:Number, vx:Number, vy:Number, ax:Number, ay:Number, anim:int, tex:CMLMovieClipTexture, next:Particle;
    public function Particle(next_:Particle) { next = next_; }
    static private var _freeList:Particle = null, _particles:Particle = new Particle(null);
    static private var _width:Number, _height:Number, _rc:Rectangle = new Rectangle(0, 0, 2, 2);
    static public function initialize(particleMax:int) : void {
        for (var i:int=0; i<particleMax; i++) _freeList = new Particle(_freeList);
        _width = 450;
        _height = 450;
    }
    static public function reset() : void {
        var i:int, p:Particle;
        p = _particles.next;
        if (p) {
            while (p.next != null) p = p.next;
            p.next = _freeList;
            _freeList = _particles.next;
            _particles.next = null;
        }
    }
    static public function update() : void {
        var p:Particle, prev:Particle;
        prev = _particles;
        for (p = prev.next; p != null; p = p.next) {
            p.x += (p.vx += p.ax);
            p.y += (p.vy += p.ay);
            if (p.y>_height || ++p.anim == (p.tex.animationCount>16 ? p.tex.animationCount : 16)) {
                prev.next = p.next;
                p.next = _freeList;
                _freeList = p;
                p = prev;
            } else {
                prev = p;
            }
        }
    }
    static public function draw() : void {
        var p:Particle, screen:BitmapData = mc.screen;
        for (p = _particles.next; p != null; p = p.next) {
            mc.copyTexture(p.tex, p.x, p.y, (p.tex.animationCount>1)?p.anim:0);
        }
    }
    static public function $(x:Number, y:Number, vx:Number, vy:Number, ax:Number, ay:Number, tex:CMLMovieClipTexture) : void {
        if (!_freeList) return;
        var newParticle:Particle = _freeList, list:Particle;
        _freeList = _freeList.next;
        newParticle.x = x;
        newParticle.y = y;
        newParticle.anim = 0;
        list = _particles;
        newParticle.vx = vx;
        newParticle.vy = vy;
        newParticle.ax = ax;
        newParticle.ay = ay;
        newParticle.tex = tex;
        newParticle.next = list.next;
        list.next = newParticle;
    }
}

//--------------------------------------------------------------------------------
class Painter {
    public var ball:BitmapData;

    // luminance-preserving hue rotation matrices, output from huerotatemat - http://www.graficaobscura.com/matrix/index.html
    public static const hue0:Array = [1.000000,-0.000000,-0.000000,0.000000,0,0.000000,1.000000,0.000000,0.000000,0,0.000000,0.000000,1.000000,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue10:Array = [0.936621,-0.068280,0.131659,0.000000,0,0.052069,1.016784,-0.068853,0.000000,0,-0.148442,0.132232,1.016210,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue20:Array = [0.854160,-0.115968,0.261808,0.000000,0,0.111933,1.021190,-0.133123,0.000000,0,-0.282998,0.278962,1.004035,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue30:Array = [0.755123,-0.141617,0.386494,0.000000,0,0.177772,1.013083,-0.190856,0.000000,0,-0.399578,0.435733,0.963845,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue40:Array = [0.642518,-0.144447,0.501929,0.000000,0,0.247587,0.992711,-0.240298,0.000000,0,-0.494640,0.597780,0.896860,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue50:Array = [0.519767,-0.124371,0.604604,0.000000,0,0.319255,0.960693,-0.279948,0.000000,0,-0.565297,0.760181,0.805116,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue60:Array = [0.390600,-0.082000,0.691400,0.000000,0,0.390600,0.918000,-0.308600,0.000000,0,-0.609400,0.918000,0.691400,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue70:Array = [0.258942,-0.018621,0.759680,0.000000,0,0.459453,0.865931,-0.325384,0.000000,0,-0.625610,1.066442,0.559168,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue80:Array = [0.128792,0.063840,0.807368,0.000000,0,0.523723,0.806067,-0.329790,0.000000,0,-0.613435,1.200998,0.412438,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue90:Array = [0.004105,0.162877,0.833017,0.000000,0,0.581456,0.740228,-0.321683,0.000000,0,-0.573245,1.317578,0.255667,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue100:Array = [-0.111329,0.275482,0.835847,0.000000,0,0.630898,0.670413,-0.301311,0.000000,0,-0.506260,1.412640,0.093620,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue110:Array = [-0.214004,0.398233,0.815771,0.000000,0,0.670548,0.598745,-0.269293,0.000000,0,-0.414516,1.483296,-0.068781,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue120:Array = [-0.300800,0.527400,0.773400,0.000000,0,0.699200,0.527400,-0.226600,0.000000,0,-0.300800,1.527400,-0.226600,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue130:Array = [-0.369080,0.659058,0.710021,0.000000,0,0.715984,0.458547,-0.174531,0.000000,0,-0.168568,1.543610,-0.375042,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue140:Array = [-0.416768,0.789208,0.627560,0.000000,0,0.720390,0.394277,-0.114667,0.000000,0,-0.021838,1.531435,-0.509598,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue150:Array = [-0.442417,0.913894,0.528523,0.000000,0,0.712283,0.336544,-0.048828,0.000000,0,0.134933,1.491245,-0.626178,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue160:Array = [-0.445247,1.029329,0.415918,0.000000,0,0.691911,0.287102,0.020987,0.000000,0,0.296981,1.424260,-0.721240,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue170:Array = [-0.425171,1.132004,0.293167,0.000000,0,0.659893,0.247452,0.092655,0.000000,0,0.459381,1.332515,-0.791897,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue180:Array = [-0.382800,1.218800,0.164000,0.000000,0,0.617200,0.218800,0.164000,0.000000,0,0.617200,1.218800,-0.836000,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue190:Array = [-0.319421,1.287080,0.032341,0.000000,0,0.565131,0.202016,0.232853,0.000000,0,0.765642,1.086568,-0.852210,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue200:Array = [-0.236960,1.334768,-0.097808,0.000000,0,0.505267,0.197610,0.297123,0.000000,0,0.900198,0.939838,-0.840035,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue210:Array = [-0.137923,1.360417,-0.222494,0.000000,0,0.439428,0.205717,0.354856,0.000000,0,1.016778,0.783067,-0.799845,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue220:Array = [-0.025318,1.363247,-0.337929,0.000000,0,0.369613,0.226089,0.404298,0.000000,0,1.111840,0.621019,-0.732860,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue230:Array = [0.097433,1.343171,-0.440604,0.000000,0,0.297945,0.258107,0.443948,0.000000,0,1.182497,0.458619,-0.641116,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue240:Array = [0.226600,1.300800,-0.527400,0.000000,0,0.226600,0.300800,0.472600,0.000000,0,1.226600,0.300800,-0.527400,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue250:Array = [0.358259,1.237421,-0.595680,0.000000,0,0.157747,0.352869,0.489384,0.000000,0,1.242810,0.152358,-0.395168,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue260:Array = [0.488408,1.154960,-0.643368,0.000000,0,0.093477,0.412733,0.493790,0.000000,0,1.230635,0.017802,-0.248438,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue270:Array = [0.613095,1.055923,-0.669017,0.000000,0,0.035744,0.478572,0.485683,0.000000,0,1.190445,-0.098778,-0.091667,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue280:Array = [0.728529,0.943318,-0.671847,0.000000,0,-0.013698,0.548387,0.465311,0.000000,0,1.123460,-0.193840,0.070380,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue290:Array = [0.831204,0.820567,-0.651771,0.000000,0,-0.053348,0.620055,0.433293,0.000000,0,1.031716,-0.264497,0.232781,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue300:Array = [0.918000,0.691400,-0.609400,0.000000,0,-0.082000,0.691400,0.390600,0.000000,0,0.918000,-0.308600,0.390600,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue310:Array = [0.986280,0.559741,-0.546021,0.000000,0,-0.098784,0.760253,0.338531,0.000000,0,0.785768,-0.324810,0.539042,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue320:Array = [1.033968,0.429592,-0.463560,0.000000,0,-0.103190,0.824523,0.278667,0.000000,0,0.639038,-0.312635,0.673598,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue330:Array = [1.059617,0.304905,-0.364523,0.000000,0,-0.095083,0.882256,0.212828,0.000000,0,0.482267,-0.272445,0.790178,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue340:Array = [1.062447,0.189471,-0.251918,0.000000,0,-0.074711,0.931698,0.143013,0.000000,0,0.320220,-0.205460,0.885240,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const hue350:Array = [1.042371,0.086796,-0.129167,0.000000,0,-0.042693,0.971348,0.071345,0.000000,0,0.157819,-0.113716,0.955897,0.000000,0,0.000000,0.000000,0.000000,1.000000,0];
    public static const flash:Array = [0.5,0.2,0.2,0.5,0, 0.2,0.5,0.2,0.25,0, 0.2,0.2,0.5,0.125,0, 0,0,0,1,0];

    public function hexTiling(height:Number, color:uint, alpha:Number = 1):BitmapData {
        var width:Number = height * 2 * Math.sin(Math.PI/3);
        var radius:Number = height / 2;
        var bmd:BitmapData = new BitmapData(width, height, true, 0);
        var s:Shape = new Shape;
        var g:Graphics = s.graphics;

        function drawHex(x:Number, y:Number):void {
            g.beginFill(color, alpha);
            g.moveTo(x, y + radius);
            for(var i:int=0; i<6; i++) g.lineTo(x + radius * Math.sin(Math.PI*i/3), y + radius * Math.cos(Math.PI*i/3));
            g.endFill();
        }

        drawHex(0, 0);
        for(var i:int=0; i<3; i++) drawHex(height * Math.sin(Math.PI/6 + Math.PI*i/3), height * Math.cos(Math.PI/6 + Math.PI*i/3));
        var m:Matrix = new Matrix;
        m.rotate(Math.PI/2);
        m.translate(width/2, 0);
        bmd.draw(s, m, null, null, null, true);
        return bmd;
    }

    public function octopusFrame(p:Number = 0):CMLMovieClipTexture {
        var shape:Shape = new Shape;
        var i:int, j:int;
        var tt:Turtle = new Turtle;
        var sin:Number = Math.sin(Math.PI*2*p);
        var arms:int = 9;

        tt.setColor(0x60,0x18,0,0.5).t(ball).fd(1000).pitch(-250).scale(0.5).push().a(0.3).v(0.2).scale(4).p().pop().scale(1.25).h(120).yaw(p*360/arms);
        function arm(parts:int, angle:Number):void {
            while(parts--) {
                tt.p().fd(50).pitch(angle).scale(0.95).h(4).s(-0.02).roll(sin/2);
            }
        }

        for(i=0;i<arms;i++) {
            tt.push().fd(300).pitch(45+15*Math.cos(6*(p+i)/arms*Math.PI*2));
            arm(50, 9+3*Math.cos(3*(p+i)/arms*Math.PI*2));
            tt.pop().yaw(360/arms);
        }

        return tt.renderCMLTexture(200);
    }

    public function rollerFrame(p:Number, rotAngle:Number):CMLMovieClipTexture {
        var shape:Shape = new Shape;
        var i:int, ii:int=3, j:int, jj:int = 3;
        var tt:Turtle = new Turtle;
        function arm(parts:int, angle:Number, len:Number):void {
            while(parts--) {
                tt.p().fd(len).pitch(angle).scaleXYZ(0.8, 1.2, 0.8).ps(0.9).h(-7).s(-0.04).v(-0.05);
            }
        }
        tt.fd(1000).setColor(100,50,25,1).setSize(200).t(ball).scale(0.14).roll(rotAngle).s(0.6).v(0.3).pitch(p*360/ii);
        for(j=0;j<jj;j++) {
            tt.yaw(360/ii/2);
            for(i=0;i<ii;i++) {
                tt.yaw(360/ii).push().fd(450);
                arm(12, -20, 100);
                tt.pop();
            }
            tt.yaw(-360/ii/2);
            tt.pitch(360/jj);
        }
        return tt.renderCMLTexture(200);
    }

    public function bird(p:Number, roll:Number):CMLMovieClipTexture {
        var shape:Shape = new Shape;
        var tt:Turtle = new Turtle;
        function line(parts:int, len:Number, ac:Number = -0.05, hc:Number = 8, p:Number = -5, vc:Number = -0.01):void {
            while(parts--) {
                tt.p().fd(len).s(0.05).v(vc).scale(0.95).pitch(p).a(ac).h(hc);
            }
        }
        function span(parts:int, len:Number, ya:Number):void {
            var cnt:int = parts;
            while(cnt--) {
                tt.p().fd(len).push().yaw(90 + (1-cnt/parts)*ya)
                line(10, 50);
                tt.pop().scale(0.98);
            }
        }
        function wing():void {
            tt.yaw(10).pitch(-15+50*sp);
            span(10,50,20);
            tt.yaw(10).pitch(-15+25*sp);
            span(10,50,20);
            tt.yaw(10).pitch(-15+30*sp);
            span(10,50,20);
        }

        var sp:Number = Math.sin(Math.pow(p,1.5)*Math.PI*2);
        tt.fd(950).setColor(25,75,100,0.9).s(-0.3).setSize(50).t(ball).scale(0.22);
        tt.yaw(roll); // player roll
        tt.fd(150*sp).push();
        // wings
        tt.push().pitch(80).yaw(65);
        wing();
        tt.pop().scaleXYZ(-1,1,1).pitch(80).yaw(65);
        wing();
        // body
        tt.pop().scale(3).fd(-3).pitch(95).push().a(-0.25);
        line(30, -20, -0.035, 6, 0, 0);
        tt.pop().pitch(-90).fd(-10).pitch(90);
        tt.h(-60).a(-0.75);
        line(30, 6, 0.01, -8, -2, -0.015);

        var cmct:CMLMovieClipTexture = tt.renderCMLTexture(200);
        var r:Rectangle = new Rectangle(cmct.center.x-5, cmct.center.y-5, 10, 10);
        return cmct;
    }

    public function ellipse(colors:Array, alphas:Array, ratios:Array, w:Number, h:Number):CMLMovieClipTexture {
        var s:Shape = new Shape;
        var container:Sprite = new Sprite;
        var m:Matrix = new Matrix;
        m.createGradientBox(w, h, 0, -w/4, -h/2);
        s.graphics.beginGradientFill("radial", colors, alphas, ratios, m, "pad", "rgb", -0.75);
        s.graphics.drawRect(-w/4, -h/2, w, h);
        s.graphics.endFill();
        s.rotation = -90;
        container.addChild(s);

        var patterns:Vector.<CMLMovieClipTexture> = new Vector.<CMLMovieClipTexture>(32, true);
        for(var i:int=0; i<32; i++) {
            var r:Rectangle = container.getBounds(container);
            r.x = Math.floor(r.x);
            r.y = Math.floor(r.y);
            r.width = Math.ceil(r.width);
            r.height = Math.ceil(r.height);
            var bmd:BitmapData = new BitmapData(r.width, r.height, true, 0);
            bmd.draw(container, new Matrix(1, 0, 0, 1, -r.x, -r.y), null, null, null, true);
            var cmct:CMLMovieClipTexture  = new CMLMovieClipTexture(bmd);
            cmct.center.x = -r.x;
            cmct.center.y = -r.y;
            patterns[i] = cmct;
            s.rotation += 360/32;
        }
        patterns[0].animationPattern = patterns;
        return patterns[0];
    }

    public var octopusCMCT:CMLMovieClipTexture;
    public var rollerCMCT:CMLMovieClipTexture;
    public var shotCMCT:CMLMovieClipTexture;
    public var birdCMCT:CMLMovieClipTexture;

    public function createSprites():void {
        var i:int, frames:int;
        var patterns:Vector.<CMLMovieClipTexture>;

        // create octopus
        frames = 15;
        patterns = new Vector.<CMLMovieClipTexture>(frames, true);
        for(i=0; i<frames; i++) {
            patterns[i] = octopusFrame(i/frames);
        }
        patterns[0].animationPattern = patterns;
        octopusCMCT = patterns[0];

        // create rollerthing
        frames = 8;
        var frame:int = 0;
        patterns = new Vector.<CMLMovieClipTexture>(frames*32, true);
        for(i=0; i<frames; i++) {
            for(var rot:int=0; rot<32; rot++) {
                patterns[frame++] = rollerFrame(i/frames, rot/32*360);
            }
        }
        patterns[0].animationPattern = patterns;
        rollerCMCT = patterns[0];

        // create shots
        shotCMCT = ellipse([16777215,15723829,15828736,14685754],[1,0.9607843137254902,1,0],[48,95,151,255], 18, 6);

        // create player
        frames = 15;
        patterns = new Vector.<CMLMovieClipTexture>(frames*7, true);
        var patIdx:int = 0;
        for(i=0; i<frames; i++) {
            for(var r:int=-3; r<4; r++) {
                patterns[patIdx++] = bird(i/frames, -r*15);
            }
        }
        patterns[0].animationPattern = patterns;
        birdCMCT = patterns[0];
    }

    public function texColorMatrix(tex:CMLMovieClipTexture, mtx:Array):CMLMovieClipTexture {
        var f:ColorMatrixFilter = new ColorMatrixFilter(mtx);
        var ret:CMLMovieClipTexture = cloneTexture(tex);
        for(var i:int=0; i<ret.animationPattern.length; i++) {
            var tbmd:BitmapData = tex.animationPattern[i].bitmapData;
            ret.animationPattern[i].bitmapData = new BitmapData(tbmd.width, tbmd.height, true);
            var bmd:BitmapData = ret.animationPattern[i].bitmapData;
            bmd.applyFilter(tbmd, tbmd.rect, tbmd.rect.topLeft, f);
        }
        return ret;
    }

    public function autocrop(tex:CMLMovieClipTexture):void {
        for each(var t:CMLMovieClipTexture in tex.animationPattern) {
            var r:Rectangle = t.bitmapData.getColorBoundsRect(0xff000000, 0, false);
            var bmd:BitmapData = new BitmapData(r.width, r.height, true);
            bmd.copyPixels(t.bitmapData, r, new Point());
            t.bitmapData.dispose();
            t.bitmapData = bmd;
            t.center.x -= r.x;
            t.center.y -= r.y;
            t.rect.x = t.rect.y = 0;
            t.rect.width = r.width;
            t.rect.height = r.height;
        }
    }

    private function cloneTexture(tex:CMLMovieClipTexture) : CMLMovieClipTexture 
    {
        var newTexture:CMLMovieClipTexture = new CMLMovieClipTexture(tex.bitmapData, tex.rect.x, tex.rect.y, tex.rect.width, tex.rect.height),
        i:int, imax:int = tex.animationPattern.length;
        newTexture.cutoutBitmapData = tex.cutoutBitmapData;
        newTexture.alphaMap = tex.alphaMap;
        newTexture.animationPattern = new Vector.<CMLMovieClipTexture>(imax, true);
        newTexture.animationPattern[0] = newTexture;
        newTexture.center.x = tex.center.x;
        newTexture.center.y = tex.center.y;
        for (i=1; i<imax; i++) {
            newTexture.animationPattern[i] = cloneTexture(tex.animationPattern[i]);
        }
        return newTexture;
    }
}

import flash.display.*;
import flash.geom.*;
import org.si.b3.*;

class Turtle {
    private var _stack:Array = []; // state stack
    private var _particles:Array = [];
    public var matrix:Matrix3D = new Matrix3D;
    public var color:FColor = new FColor;
    public var pSize:Number = 100;
    public var texture:BitmapData;
    public function clear():Turtle { _stack.length = _particles.length = 0; return setColor(1).id(); }
    public function push():Turtle { _stack.push({m: matrix.clone(), c:cloneColor(color), s:pSize}); return this; }
    public function pop():Turtle {
        if(!_stack.length) throw(new Error("Can't pop empty stack."));
        var state:Object = _stack.pop();
        matrix = state.m;
        color = state.c;
        pSize = state.s;
        return this;
    }
    public function id():Turtle { matrix.identity(); return this; }
    public function fd(n:Number):Turtle        { matrix.prependTranslation(0, 0, n); return this; }
    public function pitch(angle:Number):Turtle { matrix.prependRotation(angle, Vector3D.X_AXIS); return this; }
    public function yaw(angle:Number):Turtle   { matrix.prependRotation(angle, Vector3D.Y_AXIS); return this; }
    public function roll(angle:Number):Turtle  { matrix.prependRotation(angle, Vector3D.Z_AXIS); return this; }
    public function h(n:Number):Turtle { color.h+=n; return this; }
    public function s(n:Number):Turtle { color.s+=n; return this; }
    public function v(n:Number):Turtle { color.v+=n; return this; }
    public function a(n:Number):Turtle { color.a+=n; return this; }
    public function setSize(n:Number):Turtle { pSize=n; return this; }
    public function setColor(...args):Turtle { color.color.apply(color, args); return this; }
    public function t(t:BitmapData):Turtle { texture = t; return this; }
    public function ps(s:Number):Turtle { pSize *= s; return this; }
    public function scaleXYZ(x:Number, y:Number, z:Number):Turtle { matrix.prependScale(x, y, z); return this; } // doesn't touch pSize!
    public function scale(s:Number):Turtle { return ps(s).scaleXYZ(s, s, s); }
    public function cloneColor(c:FColor):FColor { return new FColor(c.r, c.g, c.b, c.a); }

    public function p():Turtle {
        var p:PParticle = new PParticle;
        p.x = matrix.position.x;
        p.y = matrix.position.y;
        p.z = matrix.position.z;
        p.r = color.r;
        p.g = color.g;
        p.b = color.b;
        p.a = color.a;
        p.size = pSize;
        p.texture = texture;
        _particles.push(p);
        return this;
    }

    private var _mtx:Matrix = new Matrix;
    private var _buffer:BitmapData = new BitmapData(513, 513, true, 0);
    private var _ct:ColorTransform = new ColorTransform;
    public function renderCMLTexture(focus:Number):CMLMovieClipTexture {
        var p:PParticle;
        var z:Number;
        var top:Number = 512, left:Number = 512, bottom:Number = 0, right:Number = 0;
        _particles.sortOn("z", Array.NUMERIC | Array.DESCENDING);
        _buffer.fillRect(_buffer.rect, 0);
        for each(p in _particles) {
            var scale:Number = focus/(focus+p.z);
            var radius:Number = p.size*scale;
            var htw:Number = p.texture.width/2;
            var hth:Number = p.texture.height/2;
            var x:Number = 256+p.x*scale;
            var y:Number = 256+p.y*scale;
            if(x-radius < left) left = x-radius;
            if(y-radius < top) top = y-radius;
            if(x+radius > right) right = x+radius;
            if(y+radius > bottom) bottom = y+radius;
            _mtx.identity();
            _mtx.translate(-htw, -hth);
            _mtx.scale(radius/htw, radius/hth);
            _mtx.translate(x, y);
            _ct.redMultiplier   = p.r/64;
            _ct.greenMultiplier = p.g/64;
            _ct.blueMultiplier  = p.b/64;
            _ct.alphaMultiplier = p.a;
            _ct.redOffset   = p.r/16;
            _ct.greenOffset = p.g/16;
            _ct.blueOffset  = p.b/16;
            _buffer.draw(p.texture, _mtx, _ct, null, null, true);
        }
        var bmd:BitmapData = new BitmapData(right-left+1, bottom-top+1, true, 0);
        var cmct:CMLMovieClipTexture  = new CMLMovieClipTexture(bmd);
        cmct.center.x = 256 - left;
        cmct.center.y = 256 - top;
        left = Math.floor(left);
        top = Math.floor(top);
        right = Math.ceil(right);
        bottom = Math.ceil(bottom);
        bmd.copyPixels(_buffer, new Rectangle(left, top, right-left+1, bottom-top+1), bmd.rect.topLeft);
        return cmct;
    }
}

class PParticle {
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var r:uint;
    public var g:uint;
    public var b:uint;
    public var a:Number;
    public var size:Number;
    public var texture:BitmapData;
}

class Background extends Shape {
    protected var _tilings:Array = [];
    protected var _layers:uint;
    public var smallScale:Number = 0.25;
    public var scaleFactor:Number = 2;

    public function Background(layers:uint) {
        _layers = layers;
        var color:uint = 0x404040;
        var alpha:Number = 1.05 - layers*0.2;
        for(var i:int=0; i<_layers; i++) {
            _tilings.push(painter.hexTiling(450/2, 0, alpha));
            color -= 0x202020;
            alpha += 0.2;
        }
    }

    public function draw():void {
        var x:Number = -actManager.player.x;
        var y:Number = mc.fps.totalFrame*7.5 - actManager.player.y/2;
        var m:Matrix = new Matrix;
        var s:Number = smallScale;
        fx.srcX = 225 + actManager.player.x;
        fx.srcY = 225 + actManager.player.y;
        mc.clearScreen();
        graphics.clear();
        for(var i:int=0; i<_layers; i++) {
            m.identity();
            m.translate(x, y % _tilings[i].height);
            m.scale(s, s);
            s *= scaleFactor;
            m.translate(450/2, 450/2);
            graphics.beginBitmapFill(_tilings[i], m);
            graphics.drawRect(0, 0, 450, 450);
            graphics.endFill();
        }
    }
}

// overrides --------------------------------------------------------------------------------
class CMLMovieClipEx extends CMLMovieClip {
    public var __pt:Point = new Point();
    public var __offsetX:Number;
    public var __offsetY:Number;

    function CMLMovieClipEx(parent:DisplayObjectContainer, xpos:int, ypos:int, width:int, height:int, clearColor:int=0x000000,
        addEnterFrameListener:Boolean=true, onFirstEnterFrame:Function=null, scopeMargin:Number=32, scrollDirecition:String="vertical") : void
    {
        __offsetX = width/2;
        __offsetY = height/2;
        super(parent, xpos, ypos, width, height, clearColor, addEnterFrameListener, onFirstEnterFrame, scopeMargin, scrollDirecition);
    }

    override public function copyTexture(texture:CMLMovieClipTexture, x:int, y:int, animIndex:int=0) : CMLMovieClip
    {
        var tex:CMLMovieClipTexture = texture.animationPattern[animIndex];
        __pt.x = x - tex.center.x + __offsetX;
        __pt.y = y - tex.center.y + __offsetY;
        screen.copyPixels(tex.bitmapData, tex.rect, __pt, null, null, tex.bitmapData.transparent);
        return this;
    }
}

// volumetrics ------------------------------------------------------------------------------
class EffectContainer extends Sprite {
	public var blur:Boolean = false;
	public var colorIntegrity:Boolean = false;
	public var intensity:Number = 4;
	public var passes:uint = 6;
	public var rasterQuality:String = null;
	public var scale:Number = 2;
	public var smoothing:Boolean = true;
	public var srcX:Number;
	public var srcY:Number;

	protected var _blurFilter:BlurFilter = new BlurFilter(2, 2);
	protected var _emission:DisplayObject;
	protected var _occlusion:DisplayObject;
	protected var _ct:ColorTransform = new ColorTransform;
	protected var _halve:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
	protected var _occlusionLoResBmd:BitmapData;
	protected var _occlusionLoResBmp:Bitmap;
	protected var _baseBmd:BitmapData;
	protected var _bufferBmd:BitmapData;
	protected var _lightBmp:Bitmap = new Bitmap;
	protected var _bufferSize:uint = 0x8000;
	protected var _bufferWidth:uint;
	protected var _bufferHeight:uint;
	protected var _viewportWidth:uint;
	protected var _viewportHeight:uint;
	protected var _mtx:Matrix = new Matrix;

	public function EffectContainer(width:uint, height:uint, emission:DisplayObject, occlusion:DisplayObject = null) {
		if(!emission) throw(new Error("emission DisplayObject must not be null."));
		addChild(_emission = emission);
		if(occlusion) addChild(_occlusion = occlusion);
		setViewportSize(width, height);
		_lightBmp.blendMode = BlendMode.ADD;
		addChild(_lightBmp);
		srcX = width / 2;
		srcY = height / 2;
	}

	public function setViewportSize(width:uint, height:uint):void {
		_viewportWidth = width;
		_viewportHeight = height;
		scrollRect = new Rectangle(0, 0, width, height);
		_updateBuffers();
	}

	public function setBufferSize(size:uint):void {
		_bufferSize = size;
		_updateBuffers();
	}

	protected function _updateBuffers():void {
		var aspect:Number = _viewportWidth / _viewportHeight;
		_bufferHeight = Math.max(1, Math.sqrt(_bufferSize / aspect));
		_bufferWidth  = Math.max(1, _bufferHeight * aspect);
		dispose();
		_baseBmd           = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
		_bufferBmd         = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
		_occlusionLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, true, 0);
		_occlusionLoResBmp = new Bitmap(_occlusionLoResBmd);
	}

	public function render(e:Event = null):void {
		if(!(_lightBmp.visible = intensity > 0)) return;
		var savedQuality:String = stage.quality;
		if(rasterQuality) stage.quality = rasterQuality;
		var mul:Number = colorIntegrity ? intensity : intensity/(1<<passes);
		_ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
		_drawLoResEmission();
		if(_occlusion) _eraseLoResOcclusion();
		if(rasterQuality) stage.quality = savedQuality;
		var s:Number = 1 + (scale-1) / (1 << passes);
		var tx:Number = srcX/_viewportWidth*_bufferWidth;
		var ty:Number = srcY/_viewportHeight*_bufferHeight;
		_mtx.identity();
		_mtx.translate(-tx, -ty);
		_mtx.scale(s, s);
		_mtx.translate(tx, ty);
		_lightBmp.bitmapData = _applyEffect(_baseBmd, _bufferBmd, _mtx, passes);
		_lightBmp.width = _viewportWidth;
		_lightBmp.height = _viewportHeight;
		_lightBmp.smoothing = smoothing;
	}

	protected function _drawLoResEmission():void {
		_copyMatrix(_emission.transform.matrix, _mtx);
		_mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
		_baseBmd.fillRect(_baseBmd.rect, 0);
		_baseBmd.draw(_emission, _mtx, colorIntegrity ? null : _ct);
	}

	protected function _eraseLoResOcclusion():void {
		_occlusionLoResBmd.fillRect(_occlusionLoResBmd.rect, 0);
		_copyMatrix(_occlusion.transform.matrix, _mtx);
		_mtx.scale(_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
		_occlusionLoResBmd.draw(_occlusion, _mtx);
		_baseBmd.draw(_occlusionLoResBmp, null, null, BlendMode.ERASE);
	}

	public function startRendering():void {
		addEventListener(Event.ENTER_FRAME, render);
	}

	public function stopRendering():void {
		removeEventListener(Event.ENTER_FRAME, render);
	}

	protected function _applyEffect(src:BitmapData, buffer:BitmapData, mtx:Matrix, passes:uint):BitmapData {
		var tmp:BitmapData;
		while(passes--) {
			if(colorIntegrity) src.colorTransform(src.rect, _halve);
			buffer.copyPixels(src, src.rect, src.rect.topLeft);
			buffer.draw(src, mtx, null, BlendMode.ADD, null, true);
			mtx.concat(mtx);
			tmp = src; src = buffer; buffer = tmp;
		}
		if(colorIntegrity) src.colorTransform(src.rect, _ct);
		if(blur) src.applyFilter(src, src.rect, src.rect.topLeft, _blurFilter);
		return src;
	}

	public function dispose():void {
		if(_baseBmd) _baseBmd.dispose();
		if(_occlusionLoResBmd) _occlusionLoResBmd.dispose();
		if(_bufferBmd) _bufferBmd.dispose();
		_baseBmd = _occlusionLoResBmd = _bufferBmd = _lightBmp.bitmapData = null;
	}

	protected function _copyMatrix(src:Matrix, dst:Matrix):void {
		dst.a = src.a;
		dst.b = src.b;
		dst.c = src.c;
		dst.d = src.d;
		dst.tx = src.tx;
		dst.ty = src.ty;
	}
}

class VolumetricPointLight extends EffectContainer {
	protected var _colors:Array;
	protected var _alphas:Array;
	protected var _ratios:Array;
	protected var _gradient:Shape = new Shape;
	protected var _gradientMtx:Matrix = new Matrix;
	protected var _gradientBmp:Bitmap = new Bitmap;
	protected var _lastSrcX:Number;
	protected var _lastSrcY:Number;
	protected var _lastIntensity:Number;
	protected var _lastColorIntegrity:Boolean = false;
	protected var _gradientLoResBmd:BitmapData;
	protected var _gradientLoResDirty:Boolean = true;

	public function VolumetricPointLight(width:uint, height:uint, occlusion:DisplayObject, colorOrGradient:*, alphas:Array = null, ratios:Array = null) {
		if(colorOrGradient is Array) {
			_colors = colorOrGradient.concat();
			_ratios = ratios || _colors.map(function(item:*, i:int, arr:Array):int { return 0x100*i/(colorOrGradient.length+i-1) });
			_alphas = alphas || _colors.map(function(..._):Number { return 1 });
		} else {
			_colors = [colorOrGradient, 0];
			_ratios = [0, 255];
		}
		super(width, height, _gradientBmp, occlusion);
		if(!occlusion) throw(new Error("An occlusion DisplayObject must be provided."));
		if(!(colorOrGradient is Array || colorOrGradient is uint)) throw(new Error("colorOrGradient must be either an Array or a uint."));
	}

	protected function _drawGradient():void {
		var size:Number = 2 * Math.sqrt(_viewportWidth*_viewportWidth + _viewportHeight*_viewportHeight);
		_gradientMtx.createGradientBox(size, size, 0, -size/2 + srcX, -size/2 + srcY);
		_gradient.graphics.clear();
		_gradient.graphics.beginGradientFill(GradientType.RADIAL, _colors, _alphas, _ratios, _gradientMtx);
		_gradient.graphics.drawRect(0, 0, _viewportWidth, _viewportHeight);
		_gradient.graphics.endFill();
		if(_gradientBmp.bitmapData) _gradientBmp.bitmapData.dispose();
		_gradientBmp.bitmapData = new BitmapData(_viewportWidth, _viewportHeight, true, 0);
		_gradientBmp.bitmapData.draw(_gradient);
	}

	override protected function _drawLoResEmission():void {
		if(_gradientLoResDirty) {
			super._drawLoResEmission();
			_gradientLoResBmd.copyPixels(_baseBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
			_gradientLoResDirty = false;
		} else {
			_baseBmd.copyPixels(_gradientLoResBmd, _baseBmd.rect, _baseBmd.rect.topLeft);
		}
	}

	override protected function _updateBuffers():void {
		super._updateBuffers();
		_gradientLoResBmd = new BitmapData(_bufferWidth, _bufferHeight, false, 0);
		_gradientLoResDirty = true;
	}

	override public function setViewportSize(width:uint, height:uint):void {
		super.setViewportSize(width, height);
		_drawGradient();
		_gradientLoResDirty = true;
	}

	override public function render(e:Event = null):void {
		var srcChanged:Boolean = _lastSrcX != srcX || _lastSrcY != srcY;
		if(srcChanged) _drawGradient();
		_gradientLoResDirty ||= srcChanged;
		_gradientLoResDirty ||= (!colorIntegrity && (_lastIntensity != intensity));
		_gradientLoResDirty ||= (_lastColorIntegrity != colorIntegrity);
		_lastSrcX = srcX;
		_lastSrcY = srcY;
		_lastIntensity = intensity;
		_lastColorIntegrity = colorIntegrity;
		super.render(e);
	}

	override public function dispose():void {
		super.dispose();
		if(_gradientLoResBmd) _gradientLoResBmd.dispose();
		_gradientLoResBmd = null;
	}
}

// scripts --------------------------------------------------------------------------------
var cmlScript:String = String(<cml><![CDATA[
w60[[w60-$l*5&rungroup0l$r+=0.5]10w70];
#S1{@{^f-12[q-14f{vx-6a0.3,-1}q14f{vx8a-0.4,-1}w2q-14f{vx-2a0.1,-1}q14f{vx4a-0.2,-1}w2q-14f{vx-8a0.4,-1}q14f{vx6a-0.3,-1}w2q-14f{vx-4a0.2,-1}q14f{vx2a-0.1,-1}w2]}
^f12{ay-1}[ha0q-12fq0fq12fw2q-14fq0fq14fw2ha0q-12fq0fq12fw2q-10fq0fq10fw2]};
#S2{ha0[[bm4,30+$l*10f30w2]3[bm4,60-$l*10f30w2]3]};
#S3{ha0[[qx$l*10-30f30]7w2]};
#G0{qy-225[?$?<0.4qx-$?*150-25n{}qx$?*150+25n{}:qx$??*175n{}]&groupbonus0};
#G3{l$1=$i?(3)[?$1==2{qx-225[qy-160n{}w5]5}{qx225[qy-160n{}w5]5}:qx$1*450-225[qy-160n{}w5]10]&groupbonus200};
#G6{l$1=$i?(3)[?$1==2{qx-225[qy-$l*20n{}w5]5}{qx225[qy-$l*20n{}w5]5}:qx$1*450-225[qy-$l*15n{}w5]10]&groupbonus200};
#G7{l$1=$i?(3)[?$1==2{qx-225[qy-120+$l*20n{}w5]5}{qx225[qy-120+$l*20n{}w5]5}:qx$1*450-225[qy-120+$l*15n{}w5]10]&groupbonus200};
#G9{qy-225[s?$i?(5)[qx$??*200n{}w3]10:1[qx$l*40-180n{}w3]10:2[qx180-$l*40n{}w3]10:3[qx180-$l*40n{}qx$l*40-180n{}w3]5:4[qx20+$l*40n{}qx-$l*40-20n{}w3]5]&groupbonus200};
#G10{qy-225[s?$i?(3)[qx$l*40-180n{}w3]10:1[qx180-$l*40n{}w3]10:2[qx180-$l*40n{}qx$l*40-180n{}]10]&groupbonus200};
#G13{q175,-225[?$?<0.4n{}w15n{}:n{}]&groupbonus0};
#E0{20,100#T{[bm$2,$1,,2bm2,2f$3{3}w$2*2bm$2,-$1,,2bm2,2f$3{3}w]3}i20py-120~ha180[s?$r&T 160,8,6:35&T 160,8,7:70&T 160,9,8:105&T 160,10,8:140&T 140,10,10:180&T 140,10,12]ay0.1};
#E1{16,100#B{bm$1,360bm$2,15,5,1}i20py-120~ha$?*360[s?$r&B 12,12:40&B 12,14:70&B 14,14:110&B 16,14:140&B 18,14:190&B 20,14]f7{1}w60ay0.1};
#E2{20,100i20py-120~bs37,10,,1bm2,,0.2^f{2}ha90[s?$rf4:30[hs180f4.5]2f:60[hs120f5]3:90[hs90f5]4:130[hs88f5.5]4]w90ay0.1};
#E3{9,5{l$1=$sx*-12l$2=$sx*6[v$1,0w6v$2,10w9v$1,0w6v$2,-10w9]} br1,40[s?$rw70-$r*0.4f3{0}:110w25f3{0}:250w22br1,40bm2,3f4{0}]};
#E4{9,5^f{4}{[s?$r[w45-$r*0.3f6+$r*0.08]:70[w15f12]:100[w15f13.5]:130[w15f15]:190[w12ht$??*10f16]]}{[csa10w]}l$1=$sx*270l$2=$sx*-90[i0ha$1rcw10i45ha$2rc~]};
#E5{9,5vx$sx*-5ha180[s?$rbr1,30,2^f4{2}:30br1,40,2^f4{2}:55br1,30,2^f4{2}:80br2,30,2^f4{2}:105br2,30,3^f6{2}:140br2,60,4bm2,20^f7{2}:220br2,30,3bm2,,0.8^f10{5}][vy-8ay0.8w22f4]};
#E6{7,3{[s?$rw30bm2,80-$r*0.4f6{0}:100w30bm4,160-$r*0.4f6{0}:200:w8bm4,90f6{0}w22f12{3}]}v$sx*-24,0i45v$sx*8,4~ay-0.5};
#E7{7,3{w$?*40+10ha[s?$r[f4{1ay0.2+$r*0.003}w80-$r*0.4]:120ha$??*30[f4{1ay0.5}w25]:220bm2,30,2ha$??*20[f4{1ay0.6}w20]]}v,-4i60px$sx*-200v$sx*6,4~htad-0.3};
#E8{7,3{w20[s?$rbr$r*0.02+1,120,2,2f4+$r*0.03{2}:210br4,120,2,2bm2,,2f14{5}]}v$sx*-12,-8i60p$sx*120,0v$sx*-12,4~ay-0.5};
#E9{3,1^f{0}{ht$??*5ad1.2w14ad-1.2}[s?$rbm2,,1{w25-$r*0.3f6+$r*0.12}w25[w18-$r*0.1f6+$r*0.12+$l]:80w10bm3,,2f14{3}w15[w10f16+$l]:140w10bm4,,3f16{3}w15[w10f18+$l*2]]};
#E10{3,1^f{1}vy48i12vy0~ha$?*360[s?$rbm2+$r*0.03,360:230bm10,360]f$?*1.5+3w5ay-0.12[w20ha$?*360f]};
#E11{3,1[s?$rvy24:85vy32:175vy40]i8vy0~[s?$rbm3,,1:30bm3,,1.5:60bm2,360bm3,,1.5:125bm3,240bm3,,1.5:260bm3,40bm3,,1.5]f-8{5hoad0.6}w5ad1};
#E12{35,300i20py-120~[s?$rl$1=75l$2=6:25l$1=60l$2=7:50l$1=45l$2=8:70l$1=30l$2=9:90l$1=25l$2=10:150l$1=15l$2=10][i0vx$i?(2)*8-4i12vx~bm12,360f40{wbm2,$1f$2{0}ko}$1,$2w12]5ay1};
#E13{35,300i20py-120~{w25[s?$rbm4,270:40bm5,360:80bm5,288:120bm7,309][ht-24bv0.5f4{4}hs4[f]5bv-0.5[f]7w50]6}i50[px-175v~px175v~]3ay1};
#E14{35,300i20py-120~vy-0.25[ht-90f8{5hoad-0.5ht-30*$1f6{2}hs$r*0.04*$1[w4f]7ko}1w30ht90f8{.}-1w]3ay1};
]]></cml>);

// mml --------------------------------------------------------------------------------
var mmlMain:String = String(<mml><![CDATA[#TITLE{Nomltest main theme};t152;
#A=v12c4v6c8;#C=e.f.dc4d;#B=C>a1rg4.<c4.;#T=s28dd8ff8gg8aa8<crd8s24[>d<c>d<cd8]20>d<c>d<c;
#S=s20[dfgagf]8s28aa8<cc8dd8ff8s25grars20[[a8gfd8]s25a8a8]a8gfdefgfedc>a<c>agfgfededc>a<c>agfaf<c;
%1r1r1$[@4q1s24o6l8[r4A(5)A(4)A(0)A(2)v12>a<rr4A(5)A(4)A(7)A(5)v12cr]|
@2q2s22l4[d2r8ef2rgf2rgfedc|d2ref2rga2rgagfer8]d2ref2rga2r<cdc>agf8
@3q3s20l8B>f4.e2.r<Ca1rg4.a4.<c1rr>Bf4.e2.re.f.dc.d.>ag.<c.>ag.a.fd.f.ab-.<d.f(c+.e.g ar4.
@2q2s22f2.ef2.rgf4e4d4c4>a2.rfg2.fag2.fecde4f4g4a4<c+4d4e4.f2.ef2.rga4g4f4e4c2.r>fg2.fal4gfec.d.a.<d.q5a2.r8]4
@3q0s20l16S[>a<c>a<cd8>a<c>a<cd8erf8]3Td8d8;
#A=v8a4v4a8;#B=degfgea4degf<c4d4>degf;#C=l8a.a.fe4f;#D=v10q0s24a8a8r4v8q3s20;#E=d>a<cd4>a<cd4>a<cdfecl4dc>ag;
%1r1r1$[@4q1s24v8l8[r4AAAAv8gr|r4AAA(2)A(3)v8gr]
v4q0o4l16a<(cdega<(cdl32s28edgeag<(c>a<dcedgeag<(cd>(a<c>gaegdecd>))a<c>gal16s24edc>))agedc|
v8s20o5l8[aB<c4>a4gaegde|f4B<c4d4cd>a<c>gec]f4B<e4f4egdecd>a
q3o5Cd1rl4c.f.d.c.DC<d1rl4c.d.e2.>DCd1rl4c.f.a.g.Dl8a.a.fe.f.dc.e.ec.e.c>a.<c.df.a.<d>(g.a.<d(er4.
v8o6Efedcl8d4ced4ced4cfe4c>ga b-<l4cdefab-<c+l8c+Eagfel8d4ced4cfl4edc>a.b-.<g.b-.<q5g2.l8r]4
@1v6q0l16r8.S[>a<c>a<cd8>a<c>a<v12crdrv6erf]3Td;
#A=v8d4v4d8;#B=[aaeeffdd];
%1l8r1r1$[@4q1s24v8l8[r4AA(-2)AA(3)v8err4AA(-2)AA(7)v8er]|
@1q1s32o7v8l16B32[B4[ggddeecc]3v10q0s24>c8c8<v8q1s32aacc]3B[ggddeecc]
@4q0s20o4v6l8f.g.a<d.g.ad.g.b<d.e.g
@4q1s24o5v8[a4A(3)A(2)AA(-2)v8drr4A(3)A(2)A(-2)A(-5)v8>a<rr4A(-7)A(-9)A(-5)A(-7)|
>v8efgl4ab-<c+defgl8g]v8grs20>l4f.<d.g.q5<d2.l8r]4
@4q1s24o5v8l8[r4AA(-2)AA(3)v8err4AA(-2)AA(7)v8gr]5;
#A=dd<d>d<d>d<cd>;#B=>b-b-<b->b-<b->b-<ab-;#C=>g8.g<g8>g8rrgg<g8g8;#D=dd<d8>dr<d8>;#M=[A]3d<cd>a<cd>a<c>;
%1@2v10q0s30o3l16M$[[M]4|[[B]3>b-<ab->b-<ab-ab-[B(2)]3c-b<c>cb-<c>c<c>[M]]
q1s24[[C(3)][C(2)]]3CC(2)l8>b-.b-.<b->e-.e-.<e-l8e.e.eq0s26(a.((a.((l16aa
v10[[D]4[D(-4)]4[D(-7)][D(-5)]|[D(-4)][D(-5)]][D(1)]4]4
[[>b-b-<b->b-<b->b-<ab-][cc<c>c<c>cb-<c>][dd<d>d<d>d<cd>]4]5;
#B=o2v10c;#W=o2v6c;#S=o4v12c;#H=o6v6g;#F=o4v10c))c(c(c(c(c(c;
#A=BHHWSHHBr))c)cHSHHB;#C=BS))cWSr))ccBF;#D=BHHWSHBrHrB))cSHBr;
%2@0q0s29l16AC$[[A]7C|[[D]7C][BrHHo2v8crHHSrv6cHrrHHo2v10rrcHrro2v7crSr|v10cHrrgg]4
o4v6crc((c((c((c[BrHHSrHHrHB))cSo2v10rcHBrHo2v8cSrHHrHB))cSrHH]3
BrHo2v12crHo4v10cro2v12crHo2v12crHSv9cs28(c8.s28(c8.s27(c8 s26c8 s29o2v12rc o4v10c(c(c(c
[[A]6|S8c8Brs27S4c8s29Brs27o4v13c4c8s29Brs27o4v15c4c8s29Bro4v13c((c]AC]4
[D]7C[BHHWSHBrHrB))cSrcH]3S))cWS))cWS))cWS))cWSrv14s27c8s29[[D]3C];
]]></mml>);

var mmlGameOver:String = String(<mml><![CDATA[#TITLE{Nomltest gameover};t152;
%1@3v12o6q6s26l8r2e.f.dc.d.>ag.<c.>ag.a.fe1;%1@4v8o5q6s26l8r2b-.b-.b-g.g.gf.f.fe.e.e >a1;
%1@4v6 o5q6s26l2r2fed>b-<c1;%1@2v10o3q0s26l8r2g.g.ga.a.ab-.b-.b-<c.c.c q6s18d1;
%2@0q0s28l16r4o4v14cv12c((c((co2v12co6v8rgg o2v10co6v8rgg o4v14crv8c o6v8g o6v8rrgg o2v12rrc o6v8grr o2v10cr o4v14cr v12c o6v8grrggq2s20 o6v5g1;
]]></mml>);
