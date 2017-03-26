package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.setTimeout;

    /** プラネタリウム(とりあえず恒星だけバージョン) */
    [SWF(backgroundColor="0x000000")]
    public class Planetarium extends Sprite {

        /**
         */
        public function Planetarium() {
            stage.quality   = StageQuality.MEDIUM;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            var back:Sprite = new Sprite();
            back.graphics.beginFill(0x0, 1);
            back.graphics.drawRect(0,0,500,500);
            back.graphics.endFill();
            addChild(back);

            // 観測地点
            // 北緯35度39分31.075秒(35.658632), 東経139度44分43.48秒(139.745411)
            var longitude:Degree = Degree.create(139, 44, 43.48); // 経度λ
            var latitude:Angle = DeclinationAngle.create(35, 39, 31.075); // 緯度φ
            // 観測日時は現在時刻
            var date:Date = new Date();

            // プラネタリウムビュー本体
            var view:View = new View();
            view.update(new Astro(longitude, latitude, date));
            addChild(view);

            // 観測日時を表示しています
            var status:Label = new Label("Date:", Color.WHITE, 12);
            status.y = stage.stageHeight - status.height;
            addChild(status);

            // 観測地点を表示しています。
            var place:Label = new Label("Place:", Color.WHITE, 12);
            addChild(place);

            // 1秒ごとに観測日時を現在時刻で更新します。
            var interval:Function = function():void {
                var date:Date = new Date();
                view.update(new Astro(longitude, latitude, date));
                status.text = new ISO8601Date(date).toString();
                place.text = longitude.toString() + latitude.toString();
                setTimeout(interval, 1000);
            };
            setTimeout(interval, 1000);

            // クリックで一時停止
            stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                view.pause();
            });
            // ホイールでズーム
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent):void {
                view.zoom(e.delta);
            });
            // リサイズで画面を作り直す
            stage.addEventListener(Event.RESIZE, function(e:Event):void {
                status.y = stage.stageHeight - status.height;
            });
        }
    }
}
import flash.display.Sprite;
import flash.events.Event;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.Viewport3D;

/** プラネタリウムビュー */
class View extends Sprite {

    /** 天体 {@link Heavenly} のリスト */
    private var list:Array;

    /** 3Dシーン */
    private var scene:Scene3D = new Scene3D();

    /** 視点 */
    private var camera:Camera3D = new Camera3D();

    /** ビューポート */
    private var viewport:Viewport3D = new Viewport3D(465, 465);

    /** レンダリングエンジン */
    private var renderer:BasicRenderEngine = new BasicRenderEngine();

    /** インタラクティブモード */
    private var interactive:Boolean = true;

    /** lookAt作業用 */
    private var zero:DisplayObject3D = new DisplayObject3D();

    /** プラネタリウムビューを構築
     */
    public function View() {
        var stars:Stars = new Stars_2000(); // 恒星データリスト
        var a:Array = []; // Heavenlyのリストを作る
        for each (var star:Star in stars.a) {
            var i:int = Magnitude.indexOf(star.magnitude);
            var w:int = Magnitude.getWidth(i);
            var heavenly:Heavenly = new Heavenly();
            heavenly.object = new Plane(Magnitude.getMaterial(i), w, w, 1, 1);
            heavenly.star = star;
            if (star.caption) {
                heavenly.caption = new Label3D(new Label(star.caption, Color.LILAC, 24));
            }
            a.push(heavenly);
        }
        this.list = a;
        // カメラは(0,0,0)に置く
        camera.x = camera.y = camera.z = 0;
        camera.focus = 100;
        camera.zoom = 5;
        // このSpriteにビューポートを追加
        addChild(viewport);
        // 天体の表示オブジェクトを登録
        for each (var h:Heavenly in list) {
            scene.addChild(h.object);
            if (h.caption != null) {
                scene.addChild(h.caption);
            }
        }
        // 方位表示を登録
        var news:Array = [
            {t:"S", x: 1000, z:    0},
            {t:"E", x:    0, z: 1000},
            {t:"N", x:-1000, z:    0},
            {t:"W", x:    0, z:-1000},
        ];
        for each (var entry:* in news) {
            var l:Label3D = new Label3D(new Label(entry.t, Color.YELLOW, 24));
            l.x = entry.x;
            l.y = 0;
            l.z = entry.z;
            lookAtCamera(l);
            scene.addChild(l);
        }
        // インタラクション用
        addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    /** マウスの方向にカメラを向けます
     * @param e フレームイベント
     */
    private function enterFrame(e:Event):void {
        if (interactive) {
            var cx:Number = camera.rotationY;
            var cy:Number = camera.rotationX;
            cx += (mouseX - width/2) / 50;
            cx %= 360;
            cy += (mouseY - height/2) / 50;
            cy = Math.min(Math.max(-90, cy), 0);
            camera.rotationY = cx;
            camera.rotationX = cy;
            renderer.renderScene(scene, camera, viewport);
        }
    }

    /** マウスインタラクションを一時停止
     */
    public function pause():void { interactive = !interactive; }

    /** カメラズーム
     * @param delta ズーム方向
     */
    public function zoom(delta:int):void {
        var z:Number = camera.zoom;
        z += (delta / 10);
        camera.zoom = Math.min(Math.max(5, z), 20); // 5～20の間
        if (!interactive) {
            renderer.renderScene(scene, camera, viewport);
        }
    }

    /** 指定の日付で天体位置を再計算する
     * @param astro 天文計算アルゴリズム
     */
    public function update(astro:Astro):void {
        var r:Number = 1000; // 天球儀の半径
        for each (var heavenly:Heavenly in list) {
            var star:Star = heavenly.star;
            var eq:Equatorial = star.equatorial;
            var pt:Pt = eq.toDirectionCosines();
            pt = astro.transform(pt);
            var horizon:Horizon = Horizon.fromDirectionCosines(pt);
            heavenly.horizon = horizon;
            // 天体の位置更新
            var theta:Number = -horizon.azimuth; // 方位角
            var phi:Number = horizon.altitude; // 仰角
            var p:Pt = Pt.euler(r, theta, phi);
            var o:DisplayObject3D = heavenly.object;
            o.x = p.x;
            o.y = p.y;
            o.z = p.z;
            lookAtCamera(o);
            // キャプションの位置更新
            var c:DisplayObject3D = heavenly.caption;
            if (c) {
                p = Pt.euler(r, theta, phi-Angle.toRadians(2)); // 被らないように2度下げる
                c.x = p.x;
                c.y = p.y;
                c.z = p.z;
                lookAtCamera(c);
            }
        }
        renderer.renderScene(scene, camera, viewport);
    }

    /** oをカメラに向けます。
     * o.lookAt(camera)だとdoubleSided=falseのマテリアルPlaneが逆を向くので
     * @param o カメラに向ける面
     */
    private function lookAtCamera(o:DisplayObject3D):void {
        zero.lookAt(o);
        o.rotationX = zero.rotationX;
        o.rotationY = zero.rotationY;
        o.rotationZ = zero.rotationZ;
    }
}

import org.papervision3d.objects.DisplayObject3D;

/** 描画用の天体をあらわすデータ構造 */
class Heavenly {

    /** 恒星データ */
    public var star:Star;

    /** 地平座標系 */
    public var horizon:Horizon;

    /** [PV3D] 天体 */
    public var object:DisplayObject3D;

    /** [PV3D] 天体表記キャプション */
    public var caption:DisplayObject3D;
}

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/** 文字列ラベル */
class Label extends TextField {

    /**
     * @param str 文字列
     * @param color 色
     * @param size 文字サイズ
     */
    public function Label(str:String, color:uint, size:Number) {
        autoSize = TextFieldAutoSize.LEFT;
        var fmt:TextFormat = new TextFormat();
        fmt.font = "Verdana";
        fmt.color = color;
        fmt.size = size;
        defaultTextFormat = fmt;
        text = str;
    }
}

import flash.display.BitmapData;
import flash.text.TextField;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.objects.primitives.Plane;

/** 3Dラベル */
class Label3D extends Plane {

    /**
     * @param tf テキストフィールド
     */
    public function Label3D(tf:TextField) {
        var t:BitmapData = new BitmapData(tf.width, tf.height, true, 0);
        t.draw(tf);
        var m:BitmapMaterial = new BitmapMaterial(t);
        super(m, tf.width, tf.height, 1, 1);
    }
}

import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import org.papervision3d.materials.BitmapMaterial;

/** 等級ユーティリティ */
class Magnitude {

    private static const SIZE:int = 5;

    /** pv3dマテリアルの配列 */
    private static var a:Array;

    /**
     * @param index インデックス
     * @return ビットマップの幅
     */
    public static function getWidth(index:int):int {
        return 2*(SIZE-1-index) + 1;
    }

    private static function init():Array {
        var a:Array = [];
        for (var i:int = 0; i < SIZE; ++i) {
            var w:int = getWidth(i);
            var b:BitmapData = new BitmapData(w, w, true, 0);
            if (w > 2) {
                b.fillRect(new Rectangle(1, 1, w-2, w-2), Color.WHITE);
                b.applyFilter(b, b.rect, b.rect.topLeft, new GlowFilter(Color.WHITE));
            } else {
                b.setPixel32(0, 0, Color.WHITE);
            }
            a.push(new BitmapMaterial(b));
        }
        return a;
    }

    /**
     * @param index インデックス
     * @return pv3dビットマップマテリアル
     */
    public static function getMaterial(index:int):BitmapMaterial {
        if (a == null) {
            a = init();
        }
        return a[index];
    }

    /** 等級をインデックスに変換します。
     * @param magnitude 等級 (-1くらいから+6くらい)
     * @return インデックス 
     */
    public static function indexOf(magnitude:Number):int {
        if (magnitude < 0) {
            return 0;
        }
        if (SIZE <= magnitude) {
            return SIZE-1;
        }
        return int(magnitude);
    }
}

/** 角度を抽象化するクラス */
class Angle {

    /** 角度値 単位はラジアン */
    public var value:Number;

    /** ラジアンを指定して構築する
     * @param rad 角度(ラジアン)
     */
    public function Angle(rad:Number) { this.value = rad; }

    /** 度をラジアンに変換
     * @param deg 度
     * @return ラジアン
     */
    public static function toRadians(deg:Number):Number {
        return deg * (2 * Math.PI) / 360;
    }

    /** ラジアンを度に変換
     * @param rad ラジアン
     * @return 度
     */
    public static function toDegrees(rad:Number):Number {
        return rad / (2 * Math.PI) * 360;
    }

    /**
     * @return 文字列表現
     */
    public function toString():String { return value + "rad"; }
}

/** 赤経のための角度 */
class AscensionAngle extends Angle {

    /** 時からラジアンに変換する定数 24時間が2πなので */
    private static const TIME_RAD:Number = 2 * Math.PI / (24 * 3600);

    /** ラジアンから赤経取得します。
     * @param radian ラジアン
     * @return 赤経
     */
    public static function valueOf(radian:Number):AscensionAngle {
        return new AscensionAngle(radian / TIME_RAD);
    }

    /**
     * @param s 角度(時分秒の秒単位)
     */
    public function AscensionAngle(s:Number) { super(s * TIME_RAD); }

    /** 時分秒の各要素から赤緯を得る.
     * <p>赤緯は普通時分秒で表すので</p>
     * @param h 時
     * @param m 分
     * @param s 秒
     */
    public static function create(h:Number, m:Number, s:Number):AscensionAngle {
        return new AscensionAngle(Num.sign(h) * ((Math.abs(h) * 3600) + (m * 60) + s));
    }

    /** 赤経値を時間の時分秒表現(hms形式の文字列)に変換する
     * @return hms形式の文字列
     */
    override public function toString():String {
        var a:Number = value;
        var x:Number = Math.abs(a) / TIME_RAD;
        var h:Number = Math.floor(x / 3600);
        x -= h * 3600;
        var m:Number = Math.floor(x / 60);
        x -= m * 60;
        var s:Number = x;
        return Num.signChar(a) + Num.format2(h) + "h" + Num.format2(m) + "m" + Num.format22(s) + "s";
    }
}

/** 天文計算アルゴリズム */
class Astro {

    /** 回転行列 */
    private var m:Mat;

    /** 観測地日時から天文計算アルゴリズムを構築する
     * @param longitude 観測地経度λ
     * @param latitude 観測地緯度φ
     * @param date 観測日時
     */
    public function Astro(longitude:Degree, latitude:Angle, date:Date) {
        // 恒星時Θを得る
        var ss:Number = Sidereal.build(longitude, date);
        // 恒星時Θ(時分秒)の秒をラジアンに変換する
        var theta:Angle = new AscensionAngle(ss);
        // 赤道座標系を地平座標系に変換する
        var mz:Mat = Mat.zRotate(theta.value);
        var my:Mat = Mat.yRotate(Math.PI / 2 - latitude.value);
        this.m = my.mult(mz);
    }

    /**
     * @param pt 観測対象の赤道座標系での方向余弦
     * @return 地平座標系での方向余弦
     */
    public function transform(pt:Pt):Pt {
        return m.apply(pt);
    }
}

/** 色定数 */
class Color {

    /** 黒 */
    public static const BLACK:uint = 0xFF000000;

    /** 灰 */
    public static const GRAY:uint = 0xFF888888;

    /** 明るい灰 */
    public static const LIGHT_GRAY:uint = 0xFFCCCCCC;

    /** 白 */
    public static const WHITE:uint = 0xFFFFFFFF;

    /** ネイビー */
    public static const NAVY:uint = 0xFF000080;

    /** 藤 */
    public static const LILAC:uint = 0xFF8080FF;

    /** 赤 */
    public static const RED:uint = 0xFFFF0000;

    /** 黄 */
    public static const YELLOW:uint = 0xFFFFFF00;
}

/** 赤緯のための角度 */
class DeclinationAngle extends Angle {

    /** 度からラジアンに変換する定数 360°が 2π なので */
    private static const DEGL_RAD:Number = 2 * Math.PI / (360 * 3600);

    /** ラジアンから赤緯取得します。
     * @param radian ラジアン
     * @return 赤緯
     */
    public static function valueOf(radian:Number):DeclinationAngle {
        return new DeclinationAngle(radian / DEGL_RAD);
    }

    /**
     * @param s 度分秒の秒単位
     */
    public function DeclinationAngle(s:Number) {
        super(s * DEGL_RAD);
    }

    /** 度分秒の各要素から赤緯を得る.
     * <p>赤緯は普通度分秒で表すので</p>
     * @param d 度
     * @param m 分
     * @param s 秒
     */
    public static function create(d:Number, m:Number, s:Number):DeclinationAngle {
        return new DeclinationAngle(Num.sign(d) * ((Math.abs(d) * 3600) + (m * 60) + s));
    }

    /** 赤緯値を角度の度分秒表現(゜’”形式文字列)に変換する
     * @return ゜’”形式の文字列
     */
    override public function toString():String {
        var a:Number = value;
        var x:Number = Math.abs(a) / DEGL_RAD;
        var d:Number = Math.floor(x / 3600);
        x -= d * 3600;
        var m:Number = Math.floor(x / 60);
        x -= m * 60;
        var s:Number = Math.round(x);
        //Num.signChar(a)
        var we:String = a < 0 ? "S" : "N";
        return we + Num.format2(d) +"°"+ Num.format2(m) +"′"+ Num.format22(s)+"″";
    }
}

/** 度分秒 */
class Degree {

    /** 秒単位 */
    private var sec:Number;

    /**
     * @param s 秒
     */
    public function Degree(s:Number = 0) { this.sec = s; }

    /** 度分秒を指定して構築
     * @param degree 度 (0～360)
     * @param m 分 (0～60)
     * @param s 秒 (0～60)
     */
    public static function create(degree:int, m:int, s:Number):Degree {
        return new Degree(degree * 3600 + m * 60 + s);
    }

    /**
     * @return 秒単位の度
     */
    public function value():Number { return sec; }

    /**
     * @return 度分秒で表したときの度パート
     */
    public function degree():int { return Math.floor(sec / 3600); }

    /**
     * @return 度分秒で表したときの分パート
     */
    public function minute():int { return Math.floor((sec % 3600) / 60); }

    /**
     * @return 度分秒で表したときの秒パート
     */
    public function second():int { return sec % 60; }

    /**
     * @return representation
     */
    public function toString():String {
        return "E"+degree()+"°"+Num.format2(minute())+"′"+Num.format2(second())+"″";
    }
}

/** 赤道座標(α,δ)をあらわすクラス。 */
class Equatorial {

    /** 赤経 α */
    private var ascension:Number;

    /** 赤緯 δ */
    private var declination:Number;

    /** 赤緯と赤経から構築する.
     * @param a 赤経
     * @param d 赤緯
     */
    public static function create(a:AscensionAngle, d:DeclinationAngle):Equatorial {
        return new Equatorial(a.value, d.value);
    }

    /** 赤緯と赤経から構築する.
     * @param ascension 赤経
     * @param declination 赤緯
     */
    public function Equatorial(ascension:Number, declination:Number) {
        this.ascension = ascension;
        this.declination = declination;
    }

    /** 方向余弦に変換する
     * @return 方向余弦
     */
    public function toDirectionCosines():Pt {
        var d:Number = declination;
        var a:Number = ascension;
        var cosd:Number = Math.cos(d);
        var x:Number = cosd * Math.cos(a);
        var y:Number = cosd * Math.sin(a);
        var z:Number = Math.sin(d);
        return new Pt(x, y, z);
    }

    /** 表示可能な文字列化する.
     * @return 表示可能な文字列
     */
    public function toString():String {
        return "<Equatorial" +
            " Alpha=\"" + AscensionAngle.valueOf(ascension) + "\"" +
            " Delta=\"" + DeclinationAngle.valueOf(declination) + "\"/>";
    }
}

/** 時分秒 */
class Hms {

    /** 時 */
    private var h:int;

    /** 分 */
    private var m:int;

    /** 秒 */
    private var s:Number;

    /** カレンダーから時分秒を構築
     * @param date カレンダー
     */
    public static function create(date:Date):Hms {
        return new Hms(date.hours, date.minutes, date.seconds);
    }

    /** 三つの成分を指定して構築
     * @param h 時
     * @param m 分
     * @param s 秒
     */
    public function Hms(h:int, m:int, s:Number) {
        this.h = h;
        this.m = m;
        this.s = s;
    }

    /**
     * @return 時
     */
    public function hour():int { return h; }

    /**
     * @return 分
     */
    public function min():int { return m; }

    /**
     * @return 秒
     */
    public function sec():Number { return s; }

    /**
     * @return 秒単位の値(3600*時+60*分+秒)
     */
    public function value():Number {
        return h * 60 * 60 + m * 60 + s;
    }

    /**
     * @return "時h分m秒s"形式の文字列
     */
    public function toString():String {
        return ""+h+"h"+m+"m"+s+"s";
    }
}

/** 地平座標系 */
class Horizon {

    /** 方位角 (ラジアン) */
    public var azimuth:Number;

    /** 高度 (ラジアン) */
    public var altitude:Number;

    /**
     * @param azimuth 方位角 (ラジアン)
     * @param altitude 高度 (ラジアン)
     */
    public function Horizon(azimuth:Number, altitude:Number) {
        this.azimuth = azimuth;
        this.altitude = altitude;
    }

    /**
     * @return 文字列表現
     */
    public function toString():String {
        return "[A=\""+azimuth+"\" h=\""+altitude+"\"]";
    }

    /** 方向余弦(l,m,n)を(方位角,高度)=(A,h)に変換する
     * @param pt 方向余弦(l, m, n)
     * @return 地平座標系(A,h)
     */
    public static function fromDirectionCosines(pt:Pt):Horizon {
        // 方位角A tan(A) = -m/l (l>0で1または4象限 l<0で2または3象限)
        // Math.atan2()は、象限の計算もしてくれる。便利。
        // pt.y が負なのは地平直交座標と地平座標でy軸の向きが違うから。
        // 方位角は南に向いて0度、西方向に増える。
        var a:Number = Math.atan2(-pt.y, pt.x);
        // 高度h   sin(h) = n
        var h:Number = Math.asin(pt.z);
        return new Horizon(a, h);
    }
}

/** 日付時刻の表記 */
class ISO8601Date {

    /** 日付時刻 */
    private var date:Date;

    /**
     * @param date 日付時刻
     */
    public function ISO8601Date(date:Date) { this.date = date; }

    /**
     * @param t タイムゾーンオフセット値
     */
    public static function tttt(t:int):String {
        var sign:String = Num.signChar(t);
        t = Math.abs(t);
        var h:int = t / 60;
        var m:int = t % 60;
        return sign + Num.format2(h) + Num.format2(m);
    }

    /**
     * @return 日付時刻の文字列表現
     */
    public function toString():String {
        var y:int = date.fullYear;
        var m:int = date.month + 1;
        var d:int = date.date;
        var h:int = date.hours;
        var min:int = date.minutes;
        var s:int = date.seconds;
        var tz:String = tttt(date.getTimezoneOffset());
        return y + "-" + Num.format2(m) + "-" + Num.format2(d)
            + " " + Num.format2(h) + ":" + Num.format2(min) + ":" + Num.format2(s) + tz;
    }
}

/** 3次元の回転行列 */
class Mat {

    public var m00:Number;
    public var m01:Number;
    public var m02:Number;
    public var m10:Number;
    public var m11:Number;
    public var m12:Number;
    public var m20:Number;
    public var m21:Number;
    public var m22:Number;

    /**
     */
    public function Mat(m00:Number = 1, m01:Number = 0, m02:Number = 0,
                        m10:Number = 0, m11:Number = 1, m12:Number = 0,
                        m20:Number = 0, m21:Number = 0, m22:Number = 1) {
        this.m00 = m00; this.m01 = m01; this.m02 = m02;
        this.m10 = m10; this.m11 = m11; this.m12 = m12;
        this.m20 = m20; this.m21 = m21; this.m22 = m22;
    }

    /** 回転
     * @param p 変換前の点
     * @return 変換後の新しい点
     */
    public function apply(p:Pt):Pt {
        var px:Number = p.x;
        var py:Number = p.y;
        var pz:Number = p.z;
        var x:Number = m00 * px + m01 * py + m02 * pz;
        var y:Number = m10 * px + m11 * py + m12 * pz;
        var z:Number = m20 * px + m21 * py + m22 * pz;
        return new Pt(x, y, z);
    }

    /**
     * @param matrix かける行列
     * @return かけられた行列
     */
    public function mult(b:Mat):Mat {
        //             b| 00 01 02 |
        //              | 10 11 12 |
        // m            | 20 21 22 |
        // | 00 01 02 |
        // | 10 11 12 |
        // | 20 21 22 |

        var n00:Number = m00 * b.m00 + m01 * b.m10 + m02 * b.m20;
        var n10:Number = m10 * b.m00 + m11 * b.m10 + m12 * b.m20;
        var n20:Number = m20 * b.m00 + m21 * b.m10 + m22 * b.m20;

        var n01:Number = m00 * b.m01 + m01 * b.m11 + m02 * b.m21;
        var n11:Number = m10 * b.m01 + m11 * b.m11 + m12 * b.m21;
        var n21:Number = m20 * b.m01 + m21 * b.m11 + m22 * b.m21;

        var n02:Number = m00 * b.m02 + m01 * b.m12 + m02 * b.m22;
        var n12:Number = m10 * b.m02 + m11 * b.m12 + m12 * b.m22;
        var n22:Number = m20 * b.m02 + m21 * b.m12 + m22 * b.m22;

        return new Mat(n00, n01, n02,
                       n10, n11, n12,
                       n20, n21, n22);
    }

    /**
     * @return 文字列表現
     */
    public function toString():String {
        return "["+m00+", "+m01+", "+m02+"]"
            +  "["+m10+", "+m11+", "+m12+"]"
            +  "["+m20+", "+m21+", "+m22+"]";
    }

    /** x軸を中心に回転する行列を作成する
     * @param t 回転角度θ
     */
    public static function xRotate(t:Number):Mat {
        return new Mat(1.0,   0.0,   0.0,
                       0.0,   Math.cos(t),   Math.sin(t),
                       0.0,  -Math.sin(t),   Math.cos(t));
    }

    /** y軸を中心に回転する行列を作成する
     * @param t 回転角度θ
     */
    public static function yRotate(t:Number):Mat {
        return new Mat(Math.cos(t),   0.0,   -Math.sin(t),
                       0.0,   1.0,   0.0,
                       Math.sin(t),   0.0,   Math.cos(t));
    }

    /** z軸を中心に回転する行列を作成する
     * @param t 回転角度θ
     */
    public static function zRotate(t:Number):Mat {
        return new Mat(Math.cos(t),   Math.sin(t),   0.0,
                       -Math.sin(t),   Math.cos(t),   0.0,
                       0.0,   0.0,   1.0);
    }
}

/** 数値ユーティリティ */
class Num {

    /** 符号文字を戻す
     * @param a 実数
     * @return " ":正または零 、 "-":負
     */
    public static function signChar(a:Number):String {
        return (a < 0) ? "-" : "+";
    }

    /** 符号を表す整数を戻す.
     * @param a 調べる数値
     * @return +1:正または零 、 -1:負
     */
    public static function sign(a:Number):int {
        return (a < 0) ? -1 : +1;
    }

    /** 頭に0をつけてでも二桁の数値表現にする
     * @param a a
     * @return formatted string
     */
    public static function format2(a:Number):String {
        var s:String = "0" + a.toString();
        return s.substring(s.length - 2);
    }

    /**
     * @param a a
     * @return formatted string
     */
    public static function format22(a:Number):String {
        return a.toString(); // TODO: ##.##
    }
}

/** 3値からなる座標を表すクラス
 * 方向余弦 (L, M, N) にもつかう。
 * 3行1列の行列にも使う。
 */
class Pt {

    /** x */
    public var x:Number;
    /** y */
    public var y:Number;
    /** z */
    public var z:Number;

    /**
     * @param x x
     * @param y y
     * @param z z
     */
    public function Pt(x:Number = 0, y:Number = 0, z:Number = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    /**
     * @return representation
     */
    public function toString():String {
        return "(" + x + "," + y + "," + z + ")";
    }

    /** (r,θ,φ)から3D点を得る
     * @param r 半径
     * @param theta 方位角θ(ラジアン)
     * @param phi 仰角φ(ラジアン)
     * @return (x,y,z)
     */
    public static function euler(r:Number, theta:Number, phi:Number):Pt {
        var w:Number = r * Math.cos(phi);
        var y:Number = r * Math.sin(phi);
        var x:Number = w * Math.cos(theta);
        var z:Number = w * Math.sin(theta);
        return new Pt(x, y, z);
    }        
}

/** 恒星時 */
class Sidereal {

    /** 時分秒の秒単位 */
    public var theta:Number;

    /** 恒星時を構築する
     * @param longitude 経度
     * @param date 年月日時分秒
     */
    public function Sidereal(longitude:Degree, date:Date) {
        this.theta = build(longitude, date);
    }

    /** 恒星時を得る
     * @param longitude 観測地の東経 (西経の場合は負値)
     * @param date 観測地の観測日、時刻、タイムゾーン
     * @return 恒星時
     *    Θ = Θ0 + λ + ti + 補正値
     */
    public static function build(longitude:Degree, date:Date):Number {
        var s0:Number = theta0(date);    // Θ0
        //trace("s0=", new Time(s0));
        var lamda:Number = d2h(longitude.value()); // λ
        //trace("lamda=", new Time(lamda));
        var tzoffset:Number = date.getTimezoneOffset() * 60; // タイムゾーンオフセット(秒)
        //trace("tzoffset=", new Time(tzoffset));
        var hms:Hms = Hms.create(date);
        //trace("hms=", hms);
        var ti:Number = hms.value() + tzoffset; // t(i)
        //trace("ti=", new Time(ti));
        var delta:Number = ti * 0.00273791; // 補正値
        //trace("delta=", new Time(delta));
        return s0 + lamda + ti + delta;
    }

    /** 角度の秒を時刻の秒に変換する
     * 12h = 180°
     *  1h = 15°
     *  1m = 15′
     *  1s = 15″
     * @param d 度分秒(°'″)の秒単位
     * @return 時分秒の秒単位
     */
    public static function d2h(d:Number):Number { return d / 15.0; }

    /** Θ0 グリニジ平均恒星時を得る
     * @return
     * グリニジ視恒星時
     *    Θ0 =6h38m45s.836 + 8640184s.542Tu + 0s.0929Tu^2
     * @param date 年月日
     */
    public static function theta0(date:Date):Number {
        var tu:Number = tu(date.fullYear, date.month + 1, date.date); // +1重要
        var a:Number = Time.create(6, 38, 45.836).value() + 8640184.542 * tu + 0.0929 * tu * tu;
        return new Time(a).compact().value();
    }

    /** Tuを求める。
     * @param y (世界時の)年 (2003年なら2003)
     * @param m (世界時の)月 (1月なら1)
     * @param d (世界時の)日 (1日なら1)
     * @return
     * Tu グリニジ1899年12月31日正午(1900年1月0日正午UT)からの
     *    経過日数を 36525 で割ったもの
     */
    public static function tu(y:int, m:int, d:int):Number {
        y -= 1900;
        if (m == 1 && m == 2) {
            m += 12;
            y--;
        }
        return k(y, m, d) / 36525.0;
    }

    /**
     * K グリニジ1899年12月31日正午(1900年1月0日正午UT)からの経過日数。
     * この式が使えるのは 1900年3月1日～2100年2月28日の期間だけ。
     * @param y 1月2月を前年に読み替えた年数 - 1900
     * @param m 1月2月を前年の13月14月に読み替えた月数
     * @param d 日数
     * @return 経過日数
     *    K = 365Y + 30M + D - 33.5 - [(3/5)(M+1)] + [Y/4]
     */
    public static function k(y:Number, m:Number, d:Number):Number {
        return 365.0 * y + 30.0 * m + d - 33.5 + Math.floor((m + 1) * 3.0 / 5.0) + Math.floor(y / 4.0);
    }
}

/** ひとつの恒星をあらわすデータ構造 */
class Star {

    /** 恒星の名前(星名,識別子)*/
    public var name:String;

    /** 赤道座標系 */
    public var equatorial:Equatorial;

    /** 等級 */
    public var magnitude:Number;

    /** 表示名(固有名) */
    public var caption:String;

    /** 各パラメータを指定して構築
     * @param name 識別名
     * @param equatorial 赤道座標
     * @param magnitude 明るさ
     * @param caption 表示名
     */
    public function Star(name:String, equatorial:Equatorial, magnitude:Number, caption:String = null) {
        this.name = name;
        this.equatorial = equatorial;
        this.magnitude = magnitude;
        this.caption = caption;
    }

    /**
     * @return このクラスの文字列表現
     */
    public function toString():String {
        return "<star name=\""+name+"\" equatorial=\""+equatorial+"\">";
    }
}

/** 恒星のコレクションを保持するデータ構造 */
class Stars {

    /** {@link Star} のリスト */
    public var a:Array = [];

    /** 構築ユーティリティ
     */
    public function _(name:String,
                      a1:Number, a2:Number, a3:Number,
                      d1:Number, d2:Number, d3:Number,
                      magnitude:Number, label:String = null):void {
        a.push(new Star(name,
                        new Equatorial(AscensionAngle.create(a1, a2, a3).value,
                                       DeclinationAngle.create(d1, d2, d3).value),
                        magnitude, label));
    }
}

/** 2000年分点 恒星データ */
class Stars_2000 extends Stars {

    /** 2000年分点 恒星データを構築
     */
    public function Stars_2000() {
        // 星名,赤経(時,分,秒), 赤緯(度,分,秒),等級,ラベル
        _("J000823.25+290525.5",0,8,23.2586,+29,5,25.555,2.06);
        _("J000910.68+590859.2",0,9,10.6851,+59,8,59.207,2.28);
        _("J000924.64-454450.7",0,9,24.642,-45,44,50.734,3.88);
        _("J001314.15+151100.9",0,13,14.1528,+15,11,0.945,2.83);
        _("J001925.67-084926.1",0,19,25.6746,-8,49,26.117,3.55);
        _("J002545.07-771515.2",0,25,45.0719,-77,15,15.284,2.82);
        _("J002612.20-434047.3",0,26,12.2018,-43,40,47.386,3.95);
        _("J002617.05-421821.5",0,26,17.051,-42,18,21.533,2.4);
        _("J003658.28+535348.8",0,36,58.2846,+53,53,48.874,3.68);
        _("J003919.67+305139.6",0,39,19.6758,+30,51,39.686,3.27);
        _("J004030.44+563214.3",0,40,30.4405,+56,32,14.392,2.25);
        _("J004335.37-175911.7",0,43,35.3711,-17,59,11.777,2.05);
        _("J004906.29+574854.6",0,49,6.2912,+57,48,54.674,3.45);
        _("J005642.53+604300.2",0,56,42.5317,+60,43,0.265,2.18);
        _("J005645.21+382957.6",0,56,45.2116,+38,29,57.641,3.87);
        _("J010605.04-464306.2",1,6,5.0468,-46,43,6.289,3.32);
        _("J010823.08-551444.7",1,8,23.0818,-55,14,44.737,3.98);
        _("J010835.39-101056.1",1,8,35.3916,-10,10,56.151,3.46);
        _("J010943.92+353714.0",1,9,43.9236,+35,37,14.008,2.08);
        _("J012401.40-081059.7",1,24,1.405,-8,10,59.724,3.61);
        _("J012548.95+601407.0",1,25,48.9523,+60,14,7.019,2.68);
        _("J012821.92-431905.6",1,28,21.9271,-43,19,5.642,3.44);
        _("J013115.10-490421.7",1,31,15.1046,-49,4,21.728,3.94);
        _("J013129.00+152044.9",1,31,29.0094,+15,20,44.963,3.63);
        _("J013742.84-571412.3",1,37,42.8466,-57,14,12.327,0.54, "Achernar");
        _("J013759.55+483741.5",1,37,59.5561,+48,37,41.567,3.59);
        _("J014404.08-155614.9",1,44,4.0829,-15,56,14.928,3.49);
        _("J015127.63-102006.1",1,51,27.6336,-10,20,6.136,3.73);
        _("J015304.90+293443.7",1,53,4.9079,+29,34,43.785,3.42);
        _("J015331.81+191737.8",1,53,31.8143,+19,17,37.866,3.88);
        _("J015423.72+634012.3",1,54,23.7255,+63,40,12.365,3.35);
        _("J015438.40+204828.9",1,54,38.4092,+20,48,28.926,2.66);
        _("J015557.47-513632.0",1,55,57.4724,-51,36,32.025,3.72);
        _("J015846.19-613411.4",1,58,46.1935,-61,34,11.493,2.86);
        _("J020202.69+024549.6",2,2,2.6975,+2,45,49.645,3.82);
        _("J020202.82+024549.5",2,2,2.8201,+2,45,49.534,3.82);
        _("J020326.10+722516.6",2,3,26.1054,+72,25,16.66,3.95);
        _("J020353.95+421947.0",2,3,53.9531,+42,19,47.009,2.17);
        _("J020710.40+232744.7",2,7,10.4071,+23,27,44.723,2.02);
        _("J020932.62+345914.2",2,9,32.6269,+34,59,14.269,3.02);
        _("J021630.58-513043.7",2,16,30.5853,-51,30,43.793,3.55);
        _("J023149.08+891550.7",2,31,49.0837,+89,15,50.794,2.0, "Polaris");
        _("J024318.03+031408.9",2,43,18.039,+3,14,8.947,3.47);
        _("J024959.03+271537.8",2,49,59.0323,+27,15,37.825,3.62);
        _("J025041.81+555343.7",2,50,41.8101,+55,53,43.786,3.76);
        _("J025415.46+524544.9",2,54,15.4606,+52,45,44.924,3.94);
        _("J025625.64-085353.3",2,56,25.6497,-8,53,53.32,3.9);
        _("J025815.67-401816.8",2,58,15.6747,-40,18,16.821,3.22);
        _("J030216.77+040523.0",3,2,16.7722,+4,5,23.042,2.55);
        _("J030447.79+533023.1",3,4,47.7907,+53,30,23.184,2.94);
        _("J030510.59+385024.9",3,5,10.5934,+38,50,24.986,3.41);
        _("J030810.13+405720.3",3,8,10.1316,+40,57,20.332,2.11, "Algol");
        _("J030929.77+445127.1",3,9,29.7715,+44,51,27.157,3.79);
        _("J031204.52-285915.4",3,12,4.5277,-28,59,15.425,3.8);
        _("J031931.00-214528.3",3,19,31.0019,-21,45,28.31,3.74);
        _("J032419.37+495140.2",3,24,19.3704,+49,51,40.247,1.81);
        _("J032448.79+090143.9",3,24,48.7938,+9,1,43.931,3.61);
        _("J032710.15+094357.6",3,27,10.1526,+9,43,57.647,3.73);
        _("J033255.84-092729.7",3,32,55.8442,-9,27,29.744,3.73);
        _("J034255.50+474715.1",3,42,55.5028,+47,47,15.185,3.02);
        _("J034314.90-094548.2",3,43,14.9018,-9,45,48.221,3.53);
        _("J034411.97-644824.8",3,44,11.9775,-64,48,24.85,3.84);
        _("J034419.13+321717.6",3,44,19.132,+32,17,17.693,3.86);
        _("J034452.53+240648.0",3,44,52.5373,+24,6,48.021,3.71);
        _("J034511.63+423442.7",3,45,11.6319,+42,34,42.775,3.78);
        _("J034549.60+242203.8",3,45,49.6066,+24,22,3.895,3.88);
        _("J034714.34-741420.2",3,47,14.3412,-74,14,20.264,3.26);
        _("J034729.07+240618.4",3,47,29.0765,+24,6,18.494,2.87);
        _("J034909.74+240312.2",3,49,9.7426,+24,3,12.296,3.63);
        _("J035407.92+315301.0",3,54,7.9215,+31,53,1.088,2.88);
        _("J035751.23+400036.7",3,57,51.2307,+40,0,36.773,2.91);
        _("J035801.76-133030.6",3,58,1.7664,-13,30,30.655,2.96);
        _("J040040.81+122925.2",4,0,40.8157,+12,29,25.248,3.42);
        _("J040309.38+055921.4",4,3,9.38,+5,59,21.498,3.9);
        _("J041400.11-421739.7",4,14,0.1143,-42,17,39.725,3.86);
        _("J041425.48-622825.8",4,14,25.4837,-62,28,25.889,3.34);
        _("J041753.66-334754.0",4,17,53.6623,-33,47,54.052,3.56);
        _("J041947.60+153739.5",4,19,47.6037,+15,37,39.512,3.65);
        _("J042256.09+173233.0",4,22,56.0933,+17,32,33.051,3.76);
        _("J042402.21-340100.6",4,24,2.2173,-34,1,0.647,3.96);
        _("J042834.49+155743.8",4,28,34.4959,+15,57,43.851,3.84);
        _("J042836.99+191049.5",4,28,36.9995,+19,10,49.554,3.54);
        _("J042839.74+155215.1",4,28,39.7408,+15,52,15.178,3.41);
        _("J043359.77-550241.9",4,33,59.7776,-55,2,41.909,3.26);
        _("J043533.03-303344.4",4,35,33.0386,-30,33,44.429,3.81);
        _("J043555.23+163033.4",4,35,55.2387,+16,30,33.485,0.99, "Aldebaran");
        _("J043619.14-032108.8",4,36,19.1416,-3,21,8.853,3.93);
        _("J043810.82-141814.4",4,38,10.8241,-14,18,14.471,3.87);
        _("J044950.41+065740.5",4,49,50.4106,+6,57,40.592,3.19);
        _("J045112.36+053618.3",4,51,12.3639,+5,36,18.374,3.68);
        _("J045415.09+022626.4",4,54,15.0965,+2,26,26.419,3.71);
        _("J045659.61+330957.9",4,56,59.6188,+33,9,57.925,2.68);
        _("J050158.13+434923.9",5,1,58.1342,+43,49,23.91,3.03);
        _("J050228.68+410433.0",5,2,28.6869,+41,4,33.015,3.76);
        _("J050527.66-222215.7",5,5,27.6642,-22,22,15.717,3.18);
        _("J050630.89+411404.1",5,6,30.8928,+41,14,4.108,3.17);
        _("J050750.98-050511.2",5,7,50.9851,-5,5,11.206,2.79);
        _("J051255.90-161219.6",5,12,55.9008,-16,12,19.686,3.29);
        _("J051432.27-081205.9",5,14,32.2723,-8,12,5.906,0.28, "Rigel");
        _("J051641.35+455952.7",5,16,41.3591,+45,59,52.768,0.08, "Capella");
        _("J051736.38-065039.8",5,17,36.3899,-6,50,39.874,3.6);
        _("J052428.61-022349.7",5,24,28.6167,-2,23,49.726,3.39);
        _("J052507.86+062058.9",5,25,7.8631,+6,20,58.928,1.66);
        _("J052617.51+283626.8",5,26,17.5134,+28,36,26.82,1.68);
        _("J052814.72-204533.9",5,28,14.7232,-20,45,33.988,2.84);
        _("J053112.75-352813.8",5,31,12.7558,-35,28,13.868,3.87);
        _("J053200.39-001756.6",5,32,0.3982,-0,17,56.686,2.23);
        _("J053243.81-174920.2",5,32,43.8159,-17,49,20.239,2.59);
        _("J053337.51-622923.3",5,33,37.5177,-62,29,23.371,3.76);
        _("J053508.27+095602.9",5,35,8.2771,+9,56,2.97,3.39);
        _("J053525.98-055435.6",5,35,25.9825,-5,54,35.645,2.78);
        _("J053612.81-011206.9",5,36,12.8134,-1,12,6.911,1.72);
        _("J053738.68+210833.1",5,37,38.6858,+21,8,33.177,3.0);
        _("J053844.76-023600.2",5,38,44.768,-2,36,0.248,3.8);
        _("J053938.93-340426.7",5,39,38.9399,-34,4,26.788,2.66);
        _("J054045.52-015633.2",5,40,45.5271,-1,56,33.26,1.74);
        _("J054427.79-222654.1",5,44,27.7904,-22,26,54.176,3.6);
        _("J054657.34-144919.0",5,46,57.3408,-14,49,19.02,3.55);
        _("J054717.08-510359.4",5,47,17.0876,-51,3,59.451,3.86);
        _("J054745.38-094010.5",5,47,45.3889,-9,40,10.577,2.06);
        _("J055057.59-354605.9",5,50,57.5929,-35,46,5.911,3.11);
        _("J055119.29-205244.7",5,51,19.2958,-20,52,44.719,3.78);
        _("J055129.39+390854.5",5,51,29.399,+39,8,54.529,3.97);
        _("J055510.30+072425.4",5,55,10.3053,+7,24,25.426,0.57, "Betelgeuse");
        _("J055624.29-141003.7",5,56,24.2929,-14,10,3.721,3.72);
        _("J055908.80-424854.4",5,59,8.8053,-42,48,54.488,3.94);
        _("J055931.63+541704.7",5,59,31.6366,+54,17,4.762,3.73);
        _("J055931.72+445650.7",5,59,31.7229,+44,56,50.758,1.9);
        _("J055943.26+371245.3",5,59,43.269,+37,12,45.307,2.65);
        _("J061451.33-061629.1",6,14,51.3328,-6,16,29.194,3.98);
        _("J061452.65+223024.4",6,14,52.6572,+22,30,24.476,3.3);
        _("J062018.79-300348.1",6,20,18.7925,-30,3,48.122,3.02);
        _("J062206.82-332611.0",6,22,6.8282,-33,26,11.04,3.85);
        _("J062241.98-175721.3",6,22,41.9853,-17,57,21.304,1.96);
        _("J062257.62+223048.9",6,22,57.627,+22,30,48.909,2.9);
        _("J062357.10-524144.3",6,23,57.1099,-52,41,44.378,-0.63, "Canopus");
        _("J063641.03-191521.1",6,36,41.0374,-19,15,21.165,3.95);
        _("J063742.70+162357.3",6,37,42.7011,+16,23,57.308,2.02);
        _("J063745.67-431145.3",6,37,45.6713,-43,11,45.361,3.18);
        _("J064355.92+250752.0",6,43,55.926,+25,7,52.047,3.01);
        _("J064508.91-164258.0",6,45,8.9173,-16,42,58.017,-1.44, "Sirius");
        _("J064517.36+125344.1",6,45,17.3646,+12,53,44.128,3.34);
        _("J064811.45-615629.0",6,48,11.4523,-61,56,29.01,3.25);
        _("J064950.45-323030.5",6,49,50.4591,-32,30,30.52,3.53);
        _("J064956.16-503652.4",6,49,56.1683,-50,36,52.415,2.94);
        _("J065247.33+335740.5",6,52,47.3382,+33,57,40.514,3.61);
        _("J065407.95-241103.1",6,54,7.9526,-24,11,3.159,3.84);
        _("J065837.54-285819.5",6,58,37.5484,-28,58,19.501,1.53);
        _("J070143.14-275605.3",7,1,43.1477,-27,56,5.389,3.47);
        _("J070301.47-234959.8",7,3,1.4726,-23,49,59.847,3.04);
        _("J070823.48-262335.5",7,8,23.4843,-26,23,35.519,1.84);
        _("J070844.86-702956.1",7,8,44.866,-70,29,56.154,3.76);
        _("J071649.82-675725.7",7,16,49.8244,-67,57,25.747,3.97);
        _("J071708.55-370550.8",7,17,8.5564,-37,5,50.892,2.71);
        _("J071805.57+163225.3",7,18,5.5787,+16,32,25.379,3.58);
        _("J072007.37+215856.3",7,20,7.3776,+21,58,56.354,3.54);
        _("J072405.70-291811.1",7,24,5.7025,-29,18,11.173,2.46);
        _("J072543.59+274753.0",7,25,43.5961,+27,47,53.089,3.79);
        _("J072709.04+081721.5",7,27,9.0427,+8,17,21.536,2.89);
        _("J072913.83-431805.1",7,29,13.8303,-43,18,5.157,3.26);
        _("J073435.86+315317.7",7,34,35.8628,+31,53,17.795,1.58, "Castor");
        _("J073436.10+315318.5",7,34,36.1004,+31,53,18.571,2.88);
        _("J073918.11+051329.9",7,39,18.1183,+5,13,29.975,0.4, "Procyon");
        _("J074114.83-093304.0",7,41,14.8324,-9,33,4.071,3.94);
        _("J074149.26-723621.9",7,41,49.2612,-72,36,21.953,3.95);
        _("J074348.46-285717.3",7,43,48.4691,-28,57,17.373,3.98);
        _("J074426.85+242352.7",7,44,26.8542,+24,23,52.773,3.57);
        _("J074515.29-375806.9",7,45,15.2959,-37,58,6.902,3.62);
        _("J074518.95+280134.3",7,45,18.9504,+28,1,34.315,1.22, "Pollux");
        _("J074917.65-245135.2",7,49,17.6552,-24,51,35.229,3.33);
        _("J075213.03-403432.8",7,52,13.0348,-40,34,32.83,3.72);
        _("J075646.71-525856.4",7,56,46.7143,-52,58,56.496,3.46);
        _("J080335.04-400011.3",8,3,35.0467,-40,0,11.332,2.22);
        _("J080732.64-241815.5",8,7,32.6488,-24,18,15.567,2.83);
        _("J080931.95-472011.7",8,9,31.9502,-47,20,11.716,1.79);
        _("J081630.92+091107.9",8,16,30.9206,+9,11,7.961,3.52);
        _("J082230.83-593034.1",8,22,30.8356,-59,30,34.139,1.95);
        _("J082539.63-035423.1",8,25,39.6323,-3,54,23.125,3.89);
        _("J082544.19-660812.8",8,25,44.1946,-66,8,12.805,3.77);
        _("J083015.87+604305.4",8,30,15.87,+60,43,5.409,3.36);
        _("J084006.14-351830.0",8,40,6.1435,-35,18,30.069,3.97);
        _("J084017.58-525518.7",8,40,17.5854,-52,55,18.794,3.6);
        _("J084037.56-463855.4",8,40,37.5699,-46,38,55.48,3.81);
        _("J084335.53-331110.9",8,43,35.5375,-33,11,10.988,3.69);
        _("J084441.09+180915.5",8,44,41.0996,+18,9,15.511,3.93);
        _("J084442.22-544231.7",8,44,42.2264,-54,42,31.756,1.94);
        _("J084601.64-460229.4",8,46,1.6444,-46,2,29.499,3.9);
        _("J084646.51+062507.7",8,46,46.5106,+6,25,7.713,3.4);
        _("J085502.82-603840.5",8,55,2.8281,-60,38,40.593,3.84);
        _("J085523.62+055644.0",8,55,23.6263,+5,56,44.028,3.12);
        _("J085912.45+480230.5",8,59,12.4539,+48,2,30.575,3.14);
        _("J090038.37+414658.4",9,0,38.3707,+41,46,58.48,3.97);
        _("J090337.53+470923.4",9,3,37.5319,+47,9,23.494,3.58);
        _("J090409.28-470551.8",9,4,9.2804,-47,5,51.853,3.75);
        _("J090759.75-432557.3",9,7,59.7585,-43,25,57.322,2.21);
        _("J091058.08-585800.8",9,10,58.0853,-58,58,0.825,3.43);
        _("J091116.72-621901.1",9,11,16.7201,-62,19,1.118,3.96);
        _("J091311.97-694301.9",9,13,11.9755,-69,43,1.948,1.67);
        _("J091421.85+021851.4",9,14,21.859,+2,18,51.409,3.89);
        _("J091705.40-591630.8",9,17,5.4067,-59,16,30.825,2.25);
        _("J091850.64+364809.3",9,18,50.6436,+36,48,9.348,3.82);
        _("J092103.30+342333.2",9,21,3.3013,+34,23,33.223,3.13);
        _("J092206.81-550038.4",9,22,6.8183,-55,0,38.405,2.48);
        _("J092735.24-083930.9",9,27,35.2433,-8,39,30.969,1.99);
        _("J093042.00-402800.3",9,30,42.0001,-40,28,0.37,3.59);
        _("J093113.31-570203.7",9,31,13.3188,-57,2,3.757,3.16);
        _("J093131.70+630342.6",9,31,31.7081,+63,3,42.699,3.65);
        _("J093251.43+514038.2",9,32,51.4343,+51,40,38.281,3.18);
        _("J093951.36-010834.1",9,39,51.3619,-1,8,34.117,3.9);
        _("J094109.03+095332.3",9,41,9.0328,+9,53,32.309,3.53);
        _("J094514.81-623028.4",9,45,14.8113,-62,30,28.451,3.69);
        _("J094551.07+234627.3",9,45,51.073,+23,46,27.317,2.97);
        _("J094706.12-650419.2",9,47,6.1216,-65,4,19.224,3.01);
        _("J095059.35+590219.4",9,50,59.3578,+59,2,19.448,3.78);
        _("J095245.81+260025.0",9,52,45.8173,+26,0,25.025,3.88);
        _("J095651.74-543404.0",9,56,51.7416,-54,34,4.046,3.54);
        _("J100719.95+164545.5",10,7,19.9523,+16,45,45.592,3.52);
        _("J100822.31+115801.9",10,8,22.3107,+11,58,1.945,1.41, "Regulus");
        _("J101035.27-122114.6",10,10,35.2775,-12,21,14.699,3.61);
        _("J101344.21-700216.4",10,13,44.2179,-70,2,16.452,3.3);
        _("J101444.15-420718.9",10,14,44.1553,-42,7,18.99,3.84);
        _("J101641.41+232502.3",10,16,41.4169,+23,25,2.318,3.44);
        _("J101704.97-611956.2",10,17,4.9758,-61,19,56.295,3.37);
        _("J101705.79+425451.7",10,17,5.7915,+42,54,51.714,3.44);
        _("J101958.35+195029.3",10,19,58.3545,+19,50,29.359,2.23);
        _("J101958.61+195026.7",10,19,58.6197,+19,50,26.704,3.47);
        _("J102219.74+412958.2",10,22,19.7406,+41,29,58.259,3.05);
        _("J102423.70-740153.8",10,24,23.7063,-74,1,53.803,3.99);
        _("J102605.42-165010.6",10,26,5.4267,-16,50,10.646,3.82);
        _("J102752.73-584421.8",10,27,52.7302,-58,44,21.851,3.83);
        _("J103201.46-614107.1",10,32,1.4634,-61,41,7.197,3.37);
        _("J103248.67+091823.7",10,32,48.6718,+9,18,23.708,3.85);
        _("J103718.14-481332.2",10,37,18.1416,-48,13,32.233,3.84);
        _("J104257.40-642340.0",10,42,57.4013,-64,23,40.02,2.74);
        _("J104646.17-492512.9",10,46,46.1782,-49,25,12.919,2.72);
        _("J104937.48-161137.1",10,49,37.4884,-16,11,37.134,3.11);
        _("J105318.70+341253.5",10,53,18.7051,+34,12,53.536,3.79);
        _("J105329.65-585111.4",10,53,29.6562,-58,51,11.415,3.79);
        _("J110150.47+562256.7",11,1,50.4768,+56,22,56.736,2.35);
        _("J110343.66+614503.7",11,3,43.6687,+61,45,3.72,1.82);
        _("J110835.38-585830.1",11,8,35.3899,-58,58,30.133,3.92);
        _("J110939.80+442954.5",11,9,39.8084,+44,29,54.553,3.0);
        _("J111406.50+203125.3",11,14,6.5014,+20,31,25.381,2.56);
        _("J111414.40+152546.4",11,14,14.4052,+15,25,46.453,3.33);
        _("J111810.94+313145.6",11,18,10.937,+31,31,45.25,3.79);
        _("J111828.73+330539.5",11,18,28.7368,+33,5,39.5,3.49);
        _("J111920.44-144642.7",11,19,20.4476,-14,46,42.749,3.57);
        _("J112100.40-542927.6",11,21,0.4068,-54,29,27.669,3.89);
        _("J112355.45+103146.2",11,23,55.4523,+10,31,46.231,3.96);
        _("J113124.22+691951.8",11,31,24.2205,+69,19,51.873,3.81);
        _("J113300.11-315127.4",11,33,0.1154,-31,51,27.451,3.54);
        _("J113546.88-630111.4",11,35,46.8848,-63,1,11.43,3.12);
        _("J114536.41-664343.5",11,45,36.4191,-66,43,43.546,3.63);
        _("J114603.01+474645.8",11,46,3.014,+47,46,45.861,3.7);
        _("J114903.57+143419.4",11,49,3.5776,+14,34,19.417,2.13);
        _("J115041.71+014552.9",11,50,41.7186,+1,45,52.985,3.6);
        _("J115349.84+534141.1",11,53,49.8475,+53,41,41.136,2.43);
        _("J120821.49-504320.7",12,8,21.4998,-50,43,20.732,2.58);
        _("J121007.48-223711.1",12,10,7.4807,-22,37,11.159,3.01);
        _("J121139.11-522206.4",12,11,39.1111,-52,22,6.457,3.96);
        _("J121508.71-584456.1",12,15,8.7157,-58,44,56.14,2.79);
        _("J121525.56+570157.4",12,15,25.5601,+57,1,57.421,3.3);
        _("J121548.37-173230.9",12,15,48.3702,-17,32,30.946,2.59);
        _("J121954.35-004000.4",12,19,54.3569,-0,40,0.492,3.89);
        _("J122121.60-602404.1",12,21,21.6093,-60,24,4.128,3.59);
        _("J122635.89-630556.7",12,26,35.8958,-63,5,56.73,1.28);
        _("J122636.44-630558.2",12,26,36.4422,-63,5,58.283,1.58);
        _("J122802.38-501350.2",12,28,2.382,-50,13,50.286,3.91);
        _("J122951.85-163055.5",12,29,51.8554,-16,30,55.557,2.97);
        _("J123109.95-570647.5",12,31,9.9593,-57,6,47.562,1.65);
        _("J123228.01-720758.7",12,32,28.0148,-72,7,58.758,3.84);
        _("J123328.94+694717.6",12,33,28.9443,+69,47,17.656,3.89);
        _("J123423.23-232348.3",12,34,23.2346,-23,23,48.333,2.66);
        _("J123711.01-690808.0",12,37,11.0184,-69,8,8.03,2.69);
        _("J123742.16-483228.6",12,37,42.1634,-48,32,28.694,3.85);
        _("J124131.03-485735.5",12,41,31.0386,-48,57,35.598,2.18);
        _("J124139.52-012657.9",12,41,39.522,-1,26,57.948,3.5);
        _("J124139.64-012657.7",12,41,39.6423,-1,26,57.75,3.48);
        _("J124616.80-680629.2",12,46,16.8064,-68,6,29.229,3.08);
        _("J124743.26-594119.5",12,47,43.2631,-59,41,19.549,1.31);
        _("J125401.74+555735.3",12,54,1.7494,+55,57,35.356,1.76);
        _("J125536.20+032350.8",12,55,36.2078,+3,23,50.893,3.42);
        _("J125601.66+381906.1",12,56,1.6674,+38,19,6.167,2.89);
        _("J130210.59+105732.9",13,2,10.5971,+10,57,32.941,2.84);
        _("J130216.26-713255.8",13,2,16.2633,-71,32,55.879,3.61);
        _("J131855.29-231017.4",13,18,55.2968,-23,10,17.444,3.0);
        _("J132035.81-364244.2",13,20,35.8176,-36,42,44.262,2.76);
        _("J132355.54+545531.3",13,23,55.5429,+54,55,31.302,2.22);
        _("J132356.32+545518.5",13,23,56.3298,+54,55,18.564,3.86);
        _("J132511.57-110940.7",13,25,11.5793,-11,9,40.759,1.06, "Spica");
        _("J133102.64-392426.2",13,31,2.6491,-39,24,26.294,3.9);
        _("J133441.59-003544.9",13,34,41.592,-0,35,44.953,3.38);
        _("J133953.25-532759.0",13,39,53.2584,-53,27,59.018,2.28);
        _("J134732.43+491847.7",13,47,32.4376,+49,18,47.754,1.86);
        _("J134930.27-414115.7",13,49,30.2771,-41,41,15.753,3.4);
        _("J134936.98-422825.4",13,49,36.989,-42,28,25.434,3.47);
        _("J135441.07+182351.7",13,54,41.0787,+18,23,51.781,2.68);
        _("J135532.38-471718.1",13,55,32.3858,-47,17,18.15,2.53);
        _("J135816.26-420602.7",13,58,16.2661,-42,6,2.712,3.82);
        _("J135840.74-444812.9",13,58,40.7484,-44,48,12.903,3.86);
        _("J140349.40-602222.9",14,3,49.4045,-60,22,22.942,0.64);
        _("J140423.34+642233.0",14,4,23.3498,+64,22,33.062,3.65);
        _("J140622.29-264056.5",14,6,22.2971,-26,40,56.5,3.26);
        _("J140640.94-362211.8",14,6,40.9485,-36,22,11.836,2.08);
        _("J141539.67+191056.6",14,15,39.6723,+19,10,56.688,0.16, "Arcturus");
        _("J141924.22-460329.1",14,19,24.222,-46,3,29.135,3.55);
        _("J143149.78+302217.1",14,31,49.7899,+30,22,17.174,3.57);
        _("J143204.67+381829.7",14,32,4.6719,+38,18,29.709,3.04);
        _("J143530.42-420928.1",14,35,30.4238,-42,9,28.168,2.34);
        _("J143935.08-605013.7",14,39,35.0803,-60,50,13.761,1.35);
        _("J143936.49-605002.3",14,39,36.495,-60,50,2.308,-0.01);
        _("J144108.90+134342.2",14,41,8.9045,+13,43,42.272,3.78);
        _("J144108.95+134341.8",14,41,8.9518,+13,43,41.881,3.78);
        _("J144155.75-472317.5",14,41,55.7556,-47,23,17.521,2.29);
        _("J144230.41-645830.4",14,42,30.4194,-64,58,30.499,3.18);
        _("J144303.62-053929.5",14,43,3.6234,-5,39,29.544,3.87);
        _("J144459.21+270427.2",14,44,59.2177,+27,4,27.201,2.5);
        _("J144614.92+015334.3",14,46,14.9241,+1,53,34.388,3.73);
        _("J144751.70-790241.1",14,47,51.7088,-79,2,41.103,3.81);
        _("J145042.32+740919.8",14,50,42.3264,+74,9,19.818,2.06);
        _("J145052.71-160230.4",14,50,52.7131,-16,2,30.401,2.75);
        _("J145831.92-430802.2",14,58,31.9268,-43,8,2.256,2.68);
        _("J145909.68-420615.0",14,59,9.684,-42,6,15.073,3.13);
        _("J150156.76+402326.0",15,1,56.7623,+40,23,26.036,3.48);
        _("J150404.21-251655.0",15,4,4.2156,-25,16,55.073,3.28);
        _("J150507.08-470304.4",15,5,7.0857,-47,3,4.483,3.91);
        _("J151156.07-484416.1",15,11,56.0757,-48,44,16.147,3.86);
        _("J151217.09-520557.2",15,12,17.095,-52,5,57.29,3.41);
        _("J151530.16+331853.4",15,15,30.163,+33,18,53.401,3.47);
        _("J151700.41-092258.5",15,17,0.4148,-9,22,58.503,2.61);
        _("J151854.58-684046.3",15,18,54.5822,-68,40,46.362,2.88);
        _("J152043.71+715002.4",15,20,43.7155,+71,50,2.458,3.03);
        _("J152122.32-403851.0",15,21,22.3217,-40,38,51.064,3.22);
        _("J152148.37-361540.9",15,21,48.37,-36,15,40.955,3.56);
        _("J152240.86-444122.5",15,22,40.868,-44,41,22.587,3.38);
        _("J152455.77+585757.8",15,24,55.7747,+58,57,57.836,3.3);
        _("J152749.73+290620.5",15,27,49.7308,+29,6,20.53,3.66);
        _("J153441.26+264252.8",15,34,41.2681,+26,42,52.895,2.22);
        _("J153508.44-411000.3",15,35,8.4479,-41,10,0.325,2.78);
        _("J153531.57-144722.3",15,35,31.579,-14,47,22.333,3.92);
        _("J153701.44-280806.2",15,37,1.4498,-28,8,6.286,3.6);
        _("J153839.36-294639.9",15,38,39.3695,-29,46,39.914,3.66);
        _("J154244.56+261744.2",15,42,44.565,+26,17,44.295,3.82);
        _("J154416.07+062532.2",15,44,16.0748,+6,25,32.257,2.63);
        _("J154611.25+152518.5",15,46,11.2564,+15,25,18.572,3.66);
        _("J154937.20-032548.7",15,49,37.2084,-3,25,48.748,3.55);
        _("J155048.96+042839.8",15,50,48.9661,+4,28,39.829,3.71);
        _("J155057.53-333737.7",15,50,57.5376,-33,37,37.796,3.96);
        _("J155508.56-632550.6",15,55,8.5623,-63,25,50.616,2.84);
        _("J155627.18+153941.8",15,56,27.1828,+15,39,41.821,3.85);
        _("J155653.07-291250.6",15,56,53.0765,-29,12,50.664,3.88);
        _("J155851.11-260650.7",15,58,51.1129,-26,6,50.779,2.89);
        _("J160007.32-382348.1",16,0,7.3282,-38,23,48.144,3.43);
        _("J160020.00-223718.2",16,0,20.0047,-22,37,18.228,2.3);
        _("J160526.23-194819.6",16,5,26.2307,-19,48,19.632,2.62);
        _("J160648.42-204009.0",16,6,48.4259,-20,40,9.093,3.95);
        _("J161420.73-034139.5",16,14,20.7395,-3,41,39.563,2.73);
        _("J161526.27-634108.4",16,15,26.2708,-63,41,8.454,3.85);
        _("J161819.28-044133.0",16,18,19.289,-4,41,33.038,3.24);
        _("J161944.43+461848.1",16,19,44.4368,+46,18,48.119,3.9);
        _("J162111.31-253534.0",16,21,11.316,-25,35,34.067,2.91);
        _("J162155.21+190911.2",16,21,55.2144,+19,9,11.269,3.74);
        _("J162359.48+613051.1",16,23,59.4861,+61,30,51.167,2.73);
        _("J162924.46-262555.2",16,29,24.4609,-26,25,55.209,1.07, "Antares");
        _("J163013.20+212922.6",16,30,13.2,+21,29,22.608,2.78);
        _("J163054.82+015902.1",16,30,54.8229,+1,59,2.123,3.9);
        _("J163327.08-785349.7",16,33,27.0835,-78,53,49.732,3.87);
        _("J163552.95-281257.6",16,35,52.9537,-28,12,57.658,2.83);
        _("J163709.53-103401.5",16,37,9.5378,-10,34,1.524,2.58);
        _("J164117.16+313609.8",16,41,17.1603,+31,36,9.812,2.85);
        _("J164253.76+385520.1",16,42,53.7652,+38,55,20.116,3.48);
        _("J164839.89-690139.7",16,48,39.8949,-69,1,39.774,1.91);
        _("J164947.15-590228.9",16,49,47.1563,-59,2,28.961,3.76);
        _("J165009.81-341735.6",16,50,9.813,-34,17,35.634,2.29);
        _("J165152.23-380250.5",16,51,52.2323,-38,2,50.567,3.0);
        _("J165220.14-380103.1",16,52,20.1439,-38,1,3.128,3.56);
        _("J165435.00-422140.7",16,54,35.0053,-42,21,40.726,3.61);
        _("J165740.09+092230.1",16,57,40.0974,+9,22,30.118,3.19);
        _("J165837.21-555924.5",16,58,37.2117,-55,59,24.507,3.11);
        _("J170017.37+305535.0",17,0,17.3738,+30,55,35.057,3.91);
        _("J170847.19+654252.8",17,8,47.1956,+65,42,52.86,3.18);
        _("J171022.68-154329.6",17,10,22.6873,-15,43,29.677,2.43);
        _("J171209.19-431421.0",17,12,9.1935,-43,14,21.08,3.32);
        _("J171438.85+142325.1",17,14,38.8584,+14,23,25.198,3.37);
        _("J171501.91+245021.1",17,15,1.9106,+24,50,21.135,3.13);
        _("J171502.83+364832.9",17,15,2.8344,+36,48,32.983,3.14);
        _("J172200.57-245958.3",17,22,0.5784,-24,59,58.364,3.26);
        _("J172517.98-553147.5",17,25,17.9887,-55,31,47.583,2.82);
        _("J172523.65-562239.8",17,25,23.659,-56,22,39.816,3.32);
        _("J173025.96+521804.9",17,30,25.962,+52,18,4.994,2.8);
        _("J173045.83-371744.9",17,30,45.8357,-37,17,44.92,2.68);
        _("J173105.91-604101.8",17,31,5.913,-60,41,1.854,3.6);
        _("J173150.49-495234.1",17,31,50.4933,-49,52,34.121,2.85);
        _("J173336.52-370613.7",17,33,36.52,-37,6,13.756,1.63);
        _("J173456.07+123336.1",17,34,56.0706,+12,33,36.125,2.09);
        _("J173719.13-425952.1",17,37,19.1306,-42,59,52.166,1.86);
        _("J173735.20-152354.8",17,37,35.2015,-15,23,54.806,3.54);
        _("J173927.88+460022.7",17,39,27.8864,+46,0,22.795,3.81);
        _("J174229.27-390147.9",17,42,29.2749,-39,1,47.939,2.39);
        _("J174328.35+043402.2",17,43,28.3531,+4,34,2.29,2.77);
        _("J174543.98-644325.9",17,45,43.9873,-64,43,25.937,3.59);
        _("J174627.52+274314.4",17,46,27.5269,+27,43,14.434,3.42);
        _("J174735.08-400737.1",17,47,35.0815,-40,7,37.191,3.01);
        _("J174753.56+024226.1",17,47,53.5605,+2,42,26.194,3.75);
        _("J174951.48-370235.8",17,49,51.482,-37,2,35.893,3.19);
        _("J175331.72+565221.5",17,53,31.7295,+56,52,21.514,3.74);
        _("J175615.18+371501.9",17,56,15.1805,+37,15,1.941,3.84);
        _("J175636.36+512920.0",17,56,36.3699,+51,29,20.022,2.23);
        _("J175745.88+291452.3",17,57,45.8857,+29,14,52.367,3.7);
        _("J175901.59-094625.0",17,59,1.5915,-9,46,25.075,3.32);
        _("J180038.71+025553.6",18,0,38.7158,+2,55,53.643,3.98);
        _("J180548.48-302526.7",18,5,48.4869,-30,25,26.729,3.63);
        _("J180637.87-500529.3",18,6,37.8711,-50,5,29.318,3.67);
        _("J180720.98+093349.8",18,7,20.9842,+9,33,49.85,3.72);
        _("J180732.55+284544.9",18,7,32.5507,+28,45,44.959,3.84);
        _("J181345.80-210331.8",18,13,45.8098,-21,3,31.801,3.84);
        _("J181737.63-364542.0",18,17,37.6351,-36,45,42.07,3.13);
        _("J182059.64-294941.1",18,20,59.6418,-29,49,41.172,2.7);
        _("J182103.38+724358.2",18,21,3.3826,+72,43,58.235,3.57);
        _("J182118.60-025355.7",18,21,18.6008,-2,53,55.77,3.25);
        _("J182341.88+214611.1",18,23,41.8896,+21,46,11.107,3.85);
        _("J182410.31-342304.6",18,24,10.3183,-34,23,4.618,1.81);
        _("J182658.41-455806.4",18,26,58.4163,-45,58,6.452,3.49);
        _("J182758.24-252518.1",18,27,58.2406,-25,25,18.12,2.83);
        _("J183512.42-081438.6",18,35,12.4267,-8,14,38.662,3.85);
        _("J183656.33+384701.2",18,36,56.3364,+38,47,1.291,0.03, "Vega");
        _("J184539.38-265926.8",18,45,39.3865,-26,59,26.802,3.17);
        _("J185004.79+332145.6",18,50,4.7947,+33,21,45.601,3.52);
        _("J185515.92-261748.2",18,55,15.9257,-26,17,48.2,2.07);
        _("J185743.80-210623.9",18,57,43.8016,-21,6,23.955,3.53);
        _("J185856.62+324122.4",18,58,56.6227,+32,41,22.407,3.25);
        _("J190236.71-295248.3",19,2,36.7139,-29,52,48.379,2.61);
        _("J190440.98-214429.3",19,4,40.9817,-21,44,29.384,3.77);
        _("J190524.60+135148.5",19,5,24.6082,+13,51,48.521,2.99);
        _("J190614.93-045257.1",19,6,14.9384,-4,52,57.195,3.44);
        _("J190656.40-274013.5",19,6,56.4089,-27,40,13.523,3.32);
        _("J190945.83-210125.0",19,9,45.833,-21,1,25.013,2.9);
        _("J191233.30+673941.5",19,12,33.3,+67,39,41.549,3.08);
        _("J191706.16+532206.4",19,17,6.1688,+53,22,6.454,3.8);
        _("J192140.35-175049.9",19,21,40.3588,-17,50,49.911,3.93);
        _("J192353.17-403657.3",19,23,53.1765,-40,36,57.384,3.96);
        _("J192529.90+030653.1",19,25,29.9005,+3,6,53.191,3.37);
        _("J192942.35+514347.2",19,29,42.359,+51,43,47.204,3.77);
        _("J193043.28+275734.8",19,30,43.2806,+27,57,34.852,3.08);
        _("J194458.47+450750.9",19,44,58.4778,+45,7,50.915,2.91);
        _("J194615.57+103647.7",19,46,15.5795,+10,36,47.74,2.71);
        _("J194723.25+183203.4",19,47,23.2598,+18,32,3.411,3.83);
        _("J194810.35+701604.5",19,48,10.3521,+70,16,4.549,3.84);
        _("J195046.99+085205.9",19,50,46.999,+8,52,5.959,0.93, "Altair");
        _("J195228.36+010020.3",19,52,28.3679,+1,0,20.378,3.87);
        _("J195518.79+062424.3",19,55,18.7934,+6,24,24.348,3.72);
        _("J195618.37+350500.3",19,56,18.3719,+35,5,0.325,3.9);
        _("J195845.42+192931.7",19,58,45.4275,+19,29,31.732,3.51);
        _("J200035.55-725437.8",20,0,35.5532,-72,54,37.813,3.95);
        _("J200843.60-661055.4",20,8,43.6084,-66,10,55.446,3.55);
        _("J201118.28-004917.2",20,11,18.2855,-0,49,17.26,3.25);
        _("J201337.90+464428.7",20,13,37.9063,+46,44,28.783,3.81);
        _("J201803.25-123241.4",20,18,3.2554,-12,32,41.467,3.58);
        _("J202100.67-144652.9",20,21,0.6756,-14,46,52.922,3.09);
        _("J202213.70+401524.0",20,22,13.7019,+40,15,24.045,2.23);
        _("J202538.85-564406.3",20,25,38.8578,-56,44,6.324,1.92);
        _("J203732.94+143542.3",20,37,32.9441,+14,35,42.327,3.63);
        _("J203734.03-471729.4",20,37,34.032,-47,17,29.406,3.11);
        _("J203938.28+155443.4",20,39,38.2874,+15,54,43.488,3.78);
        _("J204125.91+451649.2",20,41,25.9147,+45,16,49.217,1.33, "Deneb");
        _("J204457.49-661211.5",20,44,57.4944,-66,12,11.565,3.42);
        _("J204517.37+615019.6",20,45,17.375,+61,50,19.615,3.42);
        _("J204612.68+335812.9",20,46,12.6827,+33,58,12.922,2.49);
        _("J204740.55-092944.7",20,47,40.5514,-9,29,44.793,3.77);
        _("J205448.60-582714.9",20,54,48.6031,-58,27,14.957,3.65);
        _("J205710.41+411001.7",20,57,10.4197,+41,10,1.708,3.94);
        _("J210455.86+435540.2",21,4,55.8628,+43,55,40.267,3.71);
        _("J211256.18+301336.8",21,12,56.1862,+30,13,36.897,3.2);
        _("J211447.49+380243.1",21,14,47.4916,+38,2,43.141,3.74);
        _("J211549.43+051452.2",21,15,49.4317,+5,14,52.241,3.94);
        _("J211834.77+623508.0",21,18,34.7715,+62,35,8.061,2.47);
        _("J212640.02-222440.7",21,26,40.0261,-22,24,40.797,3.75);
        _("J212839.59+703338.5",21,28,39.5971,+70,33,38.578,3.23);
        _("J213133.53-053416.2",21,31,33.534,-5,34,16.22,2.89);
        _("J213358.85+453530.6",21,33,58.8525,+45,35,30.615,3.99);
        _("J214005.45-163944.3",21,40,5.4563,-16,39,44.308,3.68);
        _("J214128.64-772324.1",21,41,28.6463,-77,23,24.167,3.74);
        _("J214411.15+095230.0",21,44,11.1581,+9,52,30.041,2.39);
        _("J214702.44-160738.2",21,47,2.4451,-16,7,38.229,2.85);
        _("J215355.72-372153.4",21,53,55.7245,-37,21,53.468,3.01);
        _("J220547.03-001911.4",22,5,47.0357,-0,19,11.463,2.94);
        _("J220700.66+252042.4",22,7,0.6661,+25,20,42.402,3.77);
        _("J220813.98-465739.5",22,8,13.9855,-46,57,39.512,1.77);
        _("J221011.98+061152.3",22,10,11.9852,+6,11,52.314,3.53);
        _("J221051.27+581204.5",22,10,51.2767,+58,12,4.539,3.34);
        _("J221830.09-601534.5",22,18,30.0942,-60,15,34.515,2.86);
        _("J222139.37-012314.3",22,21,39.3754,-1,23,14.393,3.85);
        _("J222849.89-000113.8",22,28,49.8937,-0,1,13.878,3.659);
        _("J222916.17-432944.0",22,29,16.1747,-43,29,44.033,3.96);
        _("J223117.50+501656.9",22,31,17.501,+50,16,56.969,3.78);
        _("J224127.72+104952.9",22,41,27.7208,+10,49,52.912,3.42);
        _("J224240.05-465304.4",22,42,40.0507,-46,53,4.477,2.12);
        _("J224300.13+301316.4",22,43,0.1374,+30,13,16.483,2.94);
        _("J224631.87+233356.3",22,46,31.8787,+23,33,56.354,3.96);
        _("J224833.29-511900.7",22,48,33.2984,-51,19,0.71,3.49);
        _("J224940.81+661201.4",22,49,40.8166,+66,12,1.468,3.5);
        _("J225000.19+243605.6",22,50,0.1928,+24,36,5.685,3.51);
        _("J225236.87-073446.5",22,52,36.8759,-7,34,46.557,3.75);
        _("J225439.01-154914.9",22,54,39.0125,-15,49,14.953,3.27);
        _("J225739.04-293720.0",22,57,39.0465,-29,37,20.05,1.23, "Fomalhaut");
        _("J230155.26+421933.5",23,1,55.2647,+42,19,33.505,3.64);
        _("J230346.45+280458.0",23,3,46.4575,+28,4,58.041,2.47);
        _("J230445.65+151218.9",23,4,45.6538,+15,12,18.952,2.49);
        _("J230926.79-211020.6",23,9,26.7971,-21,10,20.675,3.68);
        _("J231021.53-451448.1",23,10,21.5377,-45,14,48.161,3.88);
        _("J231709.93+031656.2",23,17,9.9379,+3,16,56.24,3.7);
        _("J232258.22-200602.0",23,22,58.2268,-20,6,2.088,3.96);
        _("J233733.84+462729.3",23,37,33.8425,+46,27,29.347,3.87);
        _("J233920.84+773756.1",23,39,20.849,+77,37,56.193,3.22);
    }
}

/** 時分秒の秒 */
class Time {

    /** 1分=60秒 */
    private static const M:int = 60;

    /** 1時間=1分×60分=3600秒 */
    private static const H:int = M * 60;

    /** 1日=24時間 */
    private static const D:int = H * 24;

    /** 時分秒を指定して構築
     * @param h 時
     * @param m 分
     * @param s 秒
     */
    public static function create(h:int, m:int, s:Number):Time {
        return new Time(h * H + m * M + s);
    }

    /** 秒 */
    private var sec:Number;

    /**
     * @param s 秒換算値
     */
    public function Time(s:Number) { this.sec = s; }

    /**
     * @return 秒換算値
     */
    public function value():Number { return sec; }

    /**
     * @return 時分秒
     */
    public function toHms():Hms {
        var s:Number = this.sec;
        var h:int = s / H;
        s -= h * H;
        var m:int = s / M;
        s -= m * M;
        return new Hms(h, m, s);
    }

    /**
     * @return 時分秒形式の文字列
     */
    public function toString():String { return toHms().toString(); }

    /** この時分秒を角度として扱うために、
     * 24時間より大きい値を丸めて24時間未満に丸める
     * @return 24時間単位で丸めた値
     */
    public function compact():Time {
        var s:Number = this.sec;
        if (s < 0) {
            var t:int = s / D - 1;
            s -= t * D;
            return new Time(s);
        } else {
            t = s / D;
            s -= t * D;
            return new Time(s);
        }
    }
}
