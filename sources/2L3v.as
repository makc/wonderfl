// forked from Event's SPEC vol.5 投稿用コード
package {
    import flash.display.Sprite;
    import a24.tween.Tween24;

    [SWF(backgroundColor=0x000000, frameRate=60)]
    public class Main extends Sprite {

        public function Main() {
            Resources.loadAll(complete);
            Wonderfl.capture_delay(3.2);
        }

        private function complete():void {
            Resources.shuffle();
            FeatureFall.initDescriptions();

            var fs:FallScene, ls:LandScene, rs:ResultScene;
            Tween24.serial(
                Tween24.func(function ():void {
                    fs = new FallScene();
                    addChild(fs);
                }),
                Tween24.wait(9.5),
                Tween24.func(function ():void {
                    removeChild(fs);
                    fs = null;
                    ls = new LandScene();
                    addChild(ls);
                }),
                Tween24.wait(2.1),
                Tween24.func(function ():void {
                    removeChild(ls);
                    ls = null;
                    rs = new ResultScene();
                    addChild(rs);
                })
            ).play();
        }

    }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.system.*;
import flash.text.*;

import a24.tween.Tween24;
import a24.tween.plugins.TextPlugin;

internal class Resources {

    private static const images:Object = {
        silver: 'http://jsdo.it/img/event/spec/vol5/material_fl/card02.jpg',
        gold: 'http://jsdo.it/img/event/spec/vol5/material_fl/card01.jpg',
        lvup: 'http://jsdo.it/img/event/spec/vol5/material_fl/lvup.png',
        circle: 'http://jsdo.it/img/event/spec/vol5/material_fl/magic.png',
        flare: 'http://jsdo.it/img/event/spec/vol5/material_fl/kira02.png',
        card1: 'http://jsdo.it/img/event/spec/vol5/material_js/1.jpg',
        card2: 'http://jsdo.it/img/event/spec/vol5/material_js/2.jpg',
        card3: 'http://jsdo.it/img/event/spec/vol5/material_js/3.jpg',
        card4: 'http://jsdo.it/img/event/spec/vol5/material_js/4.jpg',
        card5: 'http://jsdo.it/img/event/spec/vol5/material_js/5.jpg',
        card6: 'http://jsdo.it/img/event/spec/vol5/material_js/6.jpg',
        card7: 'http://jsdo.it/img/event/spec/vol5/material_js/7.jpg',
        card8: 'http://jsdo.it/img/event/spec/vol5/material_js/8.jpg',
        card9: 'http://jsdo.it/img/event/spec/vol5/material_js/9.jpg',
        card10: 'http://jsdo.it/img/event/spec/vol5/material_js/10.jpg',
        card11: 'http://jsdo.it/img/event/spec/vol5/material_js/11.jpg'
    };
    private static const sounds:Object = {
        feature_sound: 'http://www.apmmusic.com/audio/BEE/BRU_BEE_0008/BRU_BEE_0008_00201.mp3',
        result_sound: 'http://www.apmmusic.com/audio/BEE/BRU_BEE_0002/BRU_BEE_0002_00601.mp3'
    };
    private static const texts:Object = {
        patents: 'http://www.google.com/search?q=site:www.google.com/patents&tbm=pts&tbs=sbd:1&gws_rd=ssl&start=' + Math.floor(Math.random() * 40) * 10
    };

    public static var r:Object;
    private static var cards:Array;
    private static var onComplete:Function;
    private static var pending:int;

    private static function loadImage(key:String, url:String):void {
        pending++;
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
            r[key] = (l.content as Bitmap).bitmapData;
            if (!--pending) onComplete();
        });
        l.load(new URLRequest(url), new LoaderContext(true));
    }

    private static function loadSound(key:String, url:String):void {
        pending++;
        var s:Sound = new Sound();
        s.addEventListener(Event.COMPLETE, function (e:Event):void {
            r[key] = s;
            if (!--pending) onComplete();
        });
        s.load(new URLRequest(url));
    }

    private static function loadText(key:String, url:String):void {
        pending++;
        var t:URLLoader = new URLLoader(new URLRequest(url));
        t.addEventListener(Event.COMPLETE, function (e:Event):void {
            r[key] = t.data;
            if (!--pending) onComplete();
        });
    }

    private static function proxy(url:String):String {
        return 'http://p.jsapp.us/proxy/' + url;
    }

    public static function loadAll(callback:Function):void {
        if (r) return;
        r = {};
        pending = 0;
        onComplete = callback;

        var key:String;
        for (key in images) loadImage(key, proxy(images[key]));
        for (key in sounds) loadSound(key, proxy(sounds[key]));
        for (key in texts) loadText(key, proxy(texts[key]));
    }

    public static function shuffle():void {
        cards = [r.card1, r.card2, r.card3, r.card4, r.card5, r.card6, r.card7, r.card8, r.card9, r.card10, r.card11];
    }

    public static function draw():BitmapData {
        return pickRandom(cards);
    }

}

internal class Callout extends Sprite {

    private static const FILTERS:Array = [new GlowFilter(0x000000, 1, 3, 3)];
    private static const FORMAT:TextFormat = new TextFormat("Small Fonts", 7, 0xffffff);

    public function Callout(dx:Number, dy:Number, t:String) {
        filters = FILTERS;
        var dir:Number = dx < 0 ? -1 : 1;
        var cap:String = t.toUpperCase();

        var tf:TextField = new TextField();
        tf.width = 0;
        tf.x = dx + 8 * dir - 1; tf.y = dy - 10;
        tf.defaultTextFormat = FORMAT;
        tf.mouseEnabled = false;
        tf.text = cap;
        tf.autoSize = dx < 0 ? TextFieldAutoSize.RIGHT : TextFieldAutoSize.LEFT;
        var textWidth:Number = tf.width - 2;
        tf.autoSize = TextFieldAutoSize.NONE;
        tf.text = '';
        addChild(tf);

        var diag:Shape = new Shape();
        diag.graphics.lineStyle(0, 0xffffff);
        diag.graphics.lineTo(dx, dy);
        addChild(diag);

        var horiz:Shape = new Shape();
        horiz.graphics.lineStyle(0, 0xffffff);
        horiz.graphics.lineTo((textWidth + 8) * dir, 0);
        addChild(horiz);

        Tween24.serial(
            Tween24.prop(diag).scaleXY(0, 0),
            Tween24.prop(horiz).xy(dx, dy).scaleX(0),
            Tween24.tween(diag, 0.1).scaleXY(1, 1),
            Tween24.tween(horiz, 0.3).scaleX(1),
            Tween24.wait(1.2),
            Tween24.tween(tf, 0.1).$height(-7).$y(7),
            Tween24.tween(horiz, 0.3).xy(dx, dy).scaleX(0),
            Tween24.tween(diag, 0.1).scaleXY(0, 0)
        ).play();

        Tween24.serial(
            Tween24.wait(0.4),
            TextPlugin.typingTween(tf, cap, 0.005)
        ).play();

    }

}

internal function pickRandom(pool:Array):* {
    var pick:int = Math.random() * pool.length;
    var result:* = pool[pick];
    pool[pick] = pool[pool.length - 1];
    pool.pop();
    return result;
}

internal class Card extends Sprite {

    private static const ORIGIN:Vector3D = new Vector3D(0, 0, 0, 0);
    private static const FORWARD:Vector3D = new Vector3D(0, 0, 1, 0);
    private static const LIGHT:Vector3D = new Vector3D(0, 0, 1, 0);
    private static const HALF:Vector3D = new Vector3D(-0.5, 0.5, 1, 0);

    {
        LIGHT.normalize();
        HALF.normalize();
    }

    protected var bitmap:Bitmap;

    public function Card(bd:BitmapData) {
        bitmap = new Bitmap(bd);
        bitmap.width = 120;
        bitmap.height = 160;
        bitmap.x = -60;
        bitmap.y = -80;
        addChild(bitmap);
        addEventListener(Event.ENTER_FRAME, frame);
    }

    protected function frame(e:Event):void {
        // lighting
        var m:Matrix3D = transform.matrix3D;
        var normal:Vector3D = m.transformVector(FORWARD).subtract(m.transformVector(ORIGIN));
        var ambient:Number = 0.1;
        var diffuse:Number = Math.abs(LIGHT.dotProduct(normal)) * 0.9;
        var specular:Number = Math.pow(HALF.dotProduct(normal), 32);
        var ct:ColorTransform = transform.colorTransform;
        ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = diffuse + ambient;
        ct.redOffset = ct.greenOffset = ct.blueOffset = specular * 255;
        transform.colorTransform = ct;
    }

}

internal class TwoSidedCard extends Card {

    private static const P00:Point = new Point(0, 0);
    private static const P01:Point = new Point(0, 100);
    private static const P10:Point = new Point(100, 0);

    private var front:BitmapData;
    private var back:BitmapData;

    public function TwoSidedCard(f:BitmapData, b:BitmapData) {
        super(f);
        front = f;
        back = b;
    }

    override protected function frame(e:Event):void {
        // side
        var o:Point = localToGlobal(P00);
        var dx:Point = localToGlobal(P01).subtract(o);
        var dy:Point = localToGlobal(P10).subtract(o);
        bitmap.bitmapData = dx.x * dy.y - dx.y * dy.x < 0 ? front : back;
        bitmap.width = 120;
        bitmap.height = 160;
        super.frame(e);
    }

}

internal class Fall extends Sprite {

    protected var card:Card;
    protected var x0:Number, rx0:Number, ry0:Number, rz0:Number;
    protected var x1:Number, rx1:Number, ry1:Number, rz1:Number;
    protected var duration:Number, scale:Number, ease:Function;

    public function Fall() {
        card = new TwoSidedCard(Resources.draw(), Resources.r.silver);
        addChild(card);
        initCoords();
        Tween24.serial(
            Tween24.prop(card).xy(x0, -100).scale(scale).rotationXYZ(rx0, ry0, rz0),
            Tween24.tween(card, duration, ease).xy(x1, 565).rotationXYZ(rx1, ry1, rz1),
            Tween24.prop(card).visible(false)
        ).play();
    }

    protected function symmetricRotate():void {
        rx0 = -Math.random() * 200;
        ry0 = -Math.random() * 200;
        rz0 = Math.random() * 120 - 60;
        rx1 = -rx0;
        ry1 = -ry0;
        rz1 = -rz0;
    }

    protected function initCoords():void {
        x0 = Math.random() * 400 + 32;
        x1 = x0 + Math.random() * 100 - 50;
        symmetricRotate();
        duration = 3.0;
        scale = 0.75;
        ease = null;
    }

}

internal class FeatureFall extends Fall {

    private static const TITLE_MATCHER:RegExp = /<h3 class="r"><a href=".*?">(.*?)<\/a><\/h3>/g

    private static var descriptions:Array;

    public static function initDescriptions():void {
        var m:Object;
        descriptions = [];
        TITLE_MATCHER.lastIndex = 0;
        while (m = TITLE_MATCHER.exec(Resources.r.patents)) {
            descriptions.push(m[1]);
        }
    }

    private static function slowdownEase(t:Number, b:Number, c:Number, d:Number):Number {
        var r:Number = t - 0.5;
        var u:Number = r * r * r * 4 + 0.5;
        return u * 0.9 + t * 0.1;
    }

    private var callout:Callout;
    private var feature:Point;

    public function FeatureFall() {
        super();
        feature = new Point(Math.random() * 60 - 30, Math.random() * 80 - 40);
        callout = new Callout(feature.x < 0 ? 20 : -20, feature.y < 0 ? -20 : 20, pickRandom(descriptions).substr(0, 30));
        addChild(callout);
        addEventListener(Event.ENTER_FRAME, frame);
    }

    override protected function initCoords():void {
        x0 = Math.random() * 100 + 182;
        x1 = Math.random() * 100 + 182;
        symmetricRotate();
        duration = 2.2;
        scale = 1;
        ease = slowdownEase;
    }

    private function frame(e:Event):void {
        var p:Point = card.localToGlobal(feature);
        callout.x = p.x; callout.y = p.y;
    }

}

internal class FallScene extends Sprite {

    private var backLayer:Sprite;
    private var frontLayer:Sprite;

    public function FallScene() {
        // draw black background for capture
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, 465, 465);

        backLayer = new Sprite();
        Tween24.prop(backLayer).color(0x000000, 0.3).play();
        addChild(backLayer);
        frontLayer = new Sprite();
        addChild(frontLayer);
        Tween24.parallel(
            Tween24.func(dropFront).delay(1.4),
            Tween24.func(dropFront).delay(3.8),
            Tween24.func(dropFront).delay(7.4),
            Tween24.func(dropBack),
            Tween24.func(dropBack).delay(2.6),
            Tween24.func(dropBack).delay(5.0),
            Tween24.func(dropBack).delay(6.2)
        ).play();
        Resources.r.feature_sound.play();
    }

    private function dropBack():void {
        backLayer.addChild(new Fall());
    }

    private function dropFront():void {
        frontLayer.addChild(new FeatureFall());
    }

}

internal class LandScene extends Sprite {

    private static function slowEase(t:Number, b:Number, c:Number, d:Number):Number {
        if (t < 0.75) return t * 1.2;
        else return t * 0.4 + 0.6;
    }

    private static function lightBounceEase(t:Number, b:Number, c:Number, d:Number):Number {
        if (t < 0.75) return t / 0.75;
        else return 1.6 * t * t - 2.8 * t + 2.2;
    }

    private var circle:Bitmap;
    private var center:Card;
    private var cards:Array;
    private var cardContainer:Sprite;

    public function LandScene() {
        rotationX = -60;
        z = 400;
        y = 200;

        circle = new Bitmap(Resources.r.circle);
        addChild(circle);

        center = new Card(Resources.r.gold);
        addChild(center);

        cards = [];
        cardContainer = new Sprite();
        addChild(cardContainer);

        var beam:Shape = new Shape();
        beam.graphics.beginFill(0xffffff);
        beam.graphics.drawRect(0, 0, 120, 400);
        beam.alpha = 0.5;
        beam.x = 232 - 60;
        beam.y = 232 + 80;
        beam.rotationX = -90;
        beam.scaleY = 0;
        addChild(beam);

        Tween24.serial(
            Tween24.prop(circle).scale(2).xy(24, 27).fadeOut(),
            Tween24.prop(center).xy(232, 232),
            Tween24.func(drop),
            Tween24.wait(0.1),
            Tween24.func(drop),
            Tween24.wait(0.1),
            Tween24.func(drop),
            Tween24.wait(0.1),
            Tween24.func(drop),
            Tween24.wait(0.1),
            Tween24.func(drop),
            Tween24.wait(0.1),
            Tween24.func(drop),
            Tween24.wait(0.5),
            Tween24.func(collect),
            Tween24.wait(0.5),
            Tween24.tween(beam, 0.2, Tween24.ease.QuadIn).scaleY(1),
            Tween24.tween(beam, 0.4, Tween24.ease.QuadIn).scaleY(2).rotationX(-44).alpha(1)
        ).play();
    }

    private function drop():void {
        var card:Card = new Card(Resources.r.silver);
        cards.push(card);
        cardContainer.addChild(card);

        Tween24.serial(
            Tween24.prop(card).
                xyz(Math.random() * 200 + 132, Math.random() * 200 + 132, -600).
                rotationXYZ(Math.random() * 60 - 30, Math.random() * 60 - 30, Math.random() * 60 - 30),
            Tween24.parallel(
                Tween24.tween(card, 0.5, slowEase).
                    xy(Math.random() * 40 + 212, Math.random() * 40 + 212).
                    rotationZ(Math.random() * 20 - 10),
                Tween24.tween(card, 0.5, lightBounceEase).
                    z(0).
                    rotationXY(0, 0)
            )
        ).play();
    }

    private function collect():void {
        Tween24.parallel(
            Tween24.tween(cardContainer, 0.5, Tween24.ease.QuadIn).color(0xffffff),
            Tween24.tween(cards, 0.5, Tween24.ease.QuadIn).xy(232, 232).rotationZ(0),
            Tween24.tween(circle, 0.5).fadeIn()
        ).play();
    }

}

internal class Flare extends Sprite {

    public function Flare() {
        var b:Bitmap = new Bitmap(Resources.r.flare);
        b.x = -35; b.y = -35;
        addChild(b);

        Tween24.serial(
            Tween24.prop(this).fadeOut().rotation(-45).scale(0.2),
            Tween24.wait(0.2),
            Tween24.tween(this, 0.2, Tween24.ease.SineIn).fadeIn().rotation(0).scale(1),
            Tween24.tween(this, 0.2, Tween24.ease.SineOut).fadeOut().rotation(45).scale(0.2)
        ).play();
    }

}

internal class ResultScene extends Sprite {

    // just googled list of abstract nouns, lol
    private static const STATS:Array = [
        'ability', 'adoration', 'adventure', 'amazement', 'anger', 'anxiety', 'apprehension', 'artistry', 'awe', 'beauty', 'belief',
        'bravery', 'brutality', 'calm', 'chaos', 'charity', 'childhood', 'clarity', 'coldness', 'comfort', 'communication', 'compassion',
        'confidence', 'contentment', 'courage', 'crime', 'curiosity', 'customer service', 'death', 'deceit', 'dedication', 'defeat',
        'delight', 'democracy', 'despair', 'determination', 'dexterity', 'dictatorship', 'disappointment', 'disbelief', 'disquiet',
        'disturbance', 'education', 'ego', 'elegance', 'energy', 'enhancement', 'enthusiasm', 'envy', 'evil', 'excitement', 'failure',
        'faith', 'faithfulness', 'faithlessness', 'fascination', 'favouritism', 'fear', 'forgiveness', 'fragility', 'frailty', 'freedom',
        'friendship', 'generosity', 'goodness', 'gossip', 'grace', 'graciousness', 'grief', 'happiness', 'hate', 'hatred', 'hearsay',
        'helpfulness', 'helplessness', 'homelessness', 'honesty', 'honour', 'hope', 'humility', 'humour', 'hurt', 'idea', 'idiosyncrasy',
        'imagination', 'impression', 'improvement', 'infatuation', 'inflation', 'insanity', 'intelligence', 'jealousy', 'joy', 'justice',
        'kindness', 'knowledge', 'laughter', 'law', 'liberty', 'life', 'loss', 'love', 'loyalty', 'luck', 'luxury', 'maturity', 'memory',
        'mercy', 'motivation', 'movement', 'music', 'need', 'omen', 'opinion', 'opportunism', 'opportunity', 'pain', 'patience', 'peace',
        'peculiarity', 'perseverance', 'pleasure', 'poverty', 'power', 'pride', 'principle', 'reality', 'redemption', 'refreshment',
        'relaxation', 'relief', 'restoration', 'riches', 'romance', 'rumour', 'sacrifice', 'sadness', 'sanity', 'satisfaction',
        'self-control', 'sensitivity', 'service', 'shock', 'silliness', 'skill', 'slavery', 'sleep', 'sophistication', 'sorrow', 'sparkle',
        'speculation', 'speed', 'strength', 'strictness', 'stupidity', 'submission', 'success', 'surprise', 'sympathy', 'talent', 'thrill',
        'tiredness', 'tolerance', 'trust', 'uncertainty', 'unemployment', 'unreality', 'victory', 'wariness', 'warmth', 'weakness',
        'wealth', 'weariness', 'wisdom', 'wit', 'worry'
    ];
    private static const STAT_FORMAT:TextFormat = new TextFormat('Arial', 16, 0xffffff);
    private static const AMOUNT_FORMAT:TextFormat = new TextFormat('Arial', 16, 0x00c000, true);

    private var card:Card;
    private var pool:Array;
    private var cursor:Number;

    public function ResultScene() {
        card = new TwoSidedCard(Resources.draw(), Resources.r.gold);
        addChild(card);
        pool = STATS.concat();
        cursor = 124;

        var lvup:Bitmap = new Bitmap(Resources.r.lvup);
        addChild(lvup);
        Tween24.serial(
            Tween24.wait(1.5),
            Tween24.prop(lvup).xyz(142, 189, 100),
            Tween24.tween(lvup, 1.8, Tween24.ease.CubicOut).z(0),
            Tween24.tween(lvup, 0.4, Tween24.ease.CubicIn).z(-200).fadeOut()
        ).play();

        Tween24.serial(
            Tween24.prop(this).color(0xffffff),
            Tween24.prop(card).xy(232, 232).scale(6).rotationY(-180),
            Tween24.wait(1.0),
            Tween24.func(Resources.r.result_sound.play),
            Tween24.wait(0.5),
            Tween24.parallel(
                Tween24.tween(card, 1.8, Tween24.ease.CubicOut).scale(2),
                Tween24.tween(this, 1.8, Tween24.ease.CubicOut).color(0xffffff, 0)
            ),
            Tween24.tween(card, 1.8, Tween24.ease.CubicIn).x(305).rotationXY(-10, 30).scale(1.5),
            Tween24.func(show), Tween24.wait(0.4),
            Tween24.func(show), Tween24.wait(0.4),
            Tween24.func(show), Tween24.wait(0.4),
            Tween24.func(show), Tween24.wait(0.4),
            Tween24.func(show), Tween24.wait(0.4),
            Tween24.func(show)
        ).play();
    }

    private function show():void {
        var stat:TextField = new TextField();
        stat.x = 115; stat.y = cursor;
        stat.defaultTextFormat = STAT_FORMAT;
        stat.autoSize = TextFieldAutoSize.LEFT;
        stat.text = pickRandom(pool);
        stat.mouseEnabled = false;
        addChild(stat);

        var amount:TextField = new TextField();
        amount.x = -10; amount.y = cursor;
        amount.defaultTextFormat = AMOUNT_FORMAT;
        amount.autoSize = TextFieldAutoSize.RIGHT;
        amount.text = '+' + Math.floor(-10 * Math.log(Math.random()) + 1);
        amount.mouseEnabled = false;
        addChild(amount);

        Tween24.serial(
            Tween24.prop(stat).fadeOut(),
            Tween24.prop(amount).fadeOut(),
            Tween24.tween(stat, 0.2).fadeIn().x(95),
            Tween24.tween(amount, 0.1, Tween24.ease.QuadOut).fadeIn().y(cursor - 5),
            Tween24.tween(amount, 0.1, Tween24.ease.QuadIn).fadeIn().y(cursor)
        ).play();
        var feature:Point = card.localToGlobal(new Point(Math.random() * 60 - 30, Math.random() * 80 - 40));
        var flare:Flare = new Flare();
        flare.x = feature.x; flare.y = feature.y;
        addChild(flare);

        cursor += 38;
    }

}
