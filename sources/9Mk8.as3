/**
 *  ActionScript3 Thread library のサンプルになれば幸いです :-)
 *
 *  @see    http://www.flickr.com/photos/auroracrowley/
 *  @see    http://www.libspark.org/htdocs/as3/thread-files/document/
 */
package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import org.libspark.thread.EnterFrameThreadExecutor;
    import org.libspark.thread.Thread;

    [SWF(frameRate=60, width=465, height=465, backgroundColor=0x000000)]

    public class Tmp extends Sprite
    {
        public function Tmp()
        {
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }

        private function initialize(evt:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, initialize);

            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            if (!Thread.isReady)
            {
                Thread.initialize(new EnterFrameThreadExecutor());
            }
            new MainThread(this).start();
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Mouse;
import com.adobe.serialization.json.JSON;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.display.LoaderThread;
import org.libspark.thread.threads.net.URLLoaderThread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.MultiProgress;
import org.libspark.thread.utils.ParallelExecutor;
import org.libspark.thread.utils.SerialExecutor;


internal var FILTER_BLUR:BlurFilter = new BlurFilter(4, 4, BitmapFilterQuality.LOW);
internal var POINT_ZERO:Point = new Point();

import flash.display.Shape;

internal class Indicator extends Shape
{
    public function Indicator()
    {
        var i:uint,
            cx:Number, cy:Number,
            numNeedles:uint = 12,
            innerR:Number = 7,
            outerR:Number = 5,
            cAngle:Number = -Math.PI / 2,
            nAngle:Number;

        nAngle = Math.PI * 2 / numNeedles;
        for (i=0; i<numNeedles; i++)
        {
            cAngle += nAngle;
            cx = Math.cos(cAngle) * innerR;
            cy = Math.sin(cAngle) * innerR;
            graphics.moveTo(cx, cy);

            cx = Math.cos(cAngle) * outerR;
            cy = Math.sin(cAngle) * outerR;
            graphics.lineStyle(2, 0xffffff, i/numNeedles);
            graphics.lineTo(cx, cy);
        }
    }
}

internal class MainThread extends Thread
{
    private var layer:DisplayObjectContainer;
    private var imageLoader:LoadImageThread;
    private var contents:Array;
    private var canvas:Bitmap;
    private var currentIndex:uint;

    public function MainThread(layer:DisplayObjectContainer)
    {
        this.layer = layer;
    }

    override protected function run():void
    {
        var t:Thread;

        t = new WaitAnimationThread(layer);
        t.start();
        t.join();

        next(loadImage);
    }

    private function loadImage():void
    {
        var executor:ParallelExecutor;

        executor = new ParallelExecutor();
        imageLoader = new LoadImageThread();
        executor.addThread(imageLoader);
        executor.addThread(new LoadImageProgressThread(layer, imageLoader.progress));

        executor.start();
        executor.join();

        next(loadComplete);
    }

    private function loadComplete():void
    {
        var s:Stage,
            data:BitmapData;

        contents = imageLoader.contents.concat();
        imageLoader.contents.length = 0;
        imageLoader.contents = null;

        currentIndex = 0;

        s = layer.stage;
        data = new BitmapData(450, 450, true, 0);
        canvas = new Bitmap(data);
        canvas.x = (s.stageWidth - canvas.width) / 2;
        canvas.y = (s.stageHeight - canvas.height) / 2;
        layer.addChild(canvas);

        next(changeImage);
    }

    private function changeImage():void
    {
        if (currentIndex >= contents.length)
        {
            currentIndex = 0;
        }

        var image:Bitmap,
            th:Thread;

        image = contents[currentIndex++] as Bitmap;
        th = new HandleImageThread(image, canvas);
        th.start();
        th.join();

        next(changeImage);
    }

    override protected function finalize():void
    {
        layer = null;
        imageLoader = null;
    }
}

internal class WaitAnimationThread extends Thread
{
    private var layer:DisplayObjectContainer;
    private var message:Bitmap;

    public function WaitAnimationThread(layer:DisplayObjectContainer)
    {
        this.layer = layer;
    }

    override protected function run():void
    {
        var s:Stage,
            txt:TextField,
            fmt:TextFormat,
            bmd:BitmapData;

        s = layer.stage;

        fmt = new TextFormat();
        fmt.color = 0x000000;
        fmt.size = 24;
        fmt.font = 'Trebuchet MS';
        txt = new TextField();
        txt.autoSize = TextFieldAutoSize.LEFT;
        txt.defaultTextFormat = fmt;
        txt.text = 'click to start.';

        bmd = new BitmapData(txt.textWidth, txt.textHeight, true, 0);
        bmd.draw(txt);
        message = new Bitmap(bmd);
        message.blendMode = BlendMode.INVERT;
        message.x = (s.stageWidth - message.width) / 2;
        message.y = (s.stageHeight - message.height) / 2;

        layer.addChild(message);

        event(s, MouseEvent.CLICK, hideMessage);
    }

    private function hideMessage(evt:MouseEvent):void
    {
        new HideMessageThread(message).start();
    }

    override protected function finalize():void
    {
        layer = null;
        message = null;
    }
}

internal class HideMessageThread extends Thread
{
    private var message:DisplayObject;
    private var wrapper:Bitmap;
    private var parent:DisplayObjectContainer;
    private var film:BitmapData;
    private var particles:Vector.<HideMessageParticle>;

    public function HideMessageThread(message:DisplayObject)
    {
        this.message = message;
        this.parent = message.parent;
        this.particles = new Vector.<HideMessageParticle>();
    }

    override protected function run():void
    {
        var s:Stage,
            c:uint,
            w:Number, h:Number,
            offsetX:Number, offsetY:Number,
            i:uint, j:uint,
            bmd:BitmapData;

        s = message.stage;
        bmd = Bitmap(message).bitmapData;
        w = bmd.width;
        h = bmd.height;
        offsetX = message.x;
        offsetY = message.y;

        for (i=0; i<w; i++)
        {
            for (j=0; j<h; j++)
            {
                c = bmd.getPixel32(i,j);
                if (!c) continue;

                particles.push(new HideMessageParticle(offsetX + i, offsetY + j, c));
            }
        }
        bmd.dispose();

        film = new BitmapData(s.stageWidth, s.stageHeight, true, 0);
        wrapper = new Bitmap(film);
        wrapper.blendMode = BlendMode.INVERT;

        parent.addChild(wrapper);
        parent.removeChild(message);

        next(step);
    }

    private function step():void
    {
        var i:uint,
            l:uint,
            s:Stage,
            p:HideMessageParticle;

        film.lock();
        film.applyFilter(film, film.rect, POINT_ZERO, FILTER_BLUR);

        l = particles.length;
        for (i=0; i<l; i++)
        {
            p = particles[i];
            p.update();
            film.setPixel32(p.x, p.y, p.color);
            if (!film.rect.contains(p.x, p.y))
            {
                particles.splice(i, 1);
                i--;
                l = particles.length;
            }
        }
        film.unlock();

        if (l) next(step);
    }

    override protected function finalize():void
    {
        parent.removeChild(wrapper);
        film.dispose();

        parent = null;
        wrapper = null;
        message = null;
    }
}

internal class LoadImageThread extends Thread
implements IProgressNotifier
{
    public var contents:Array;
    private var mainProgress:MultiProgress;
    private var subProgress:MultiProgress;
    private var jsonLoader:URLLoaderThread;
    private var imageLoader:SerialExecutor;

    public function get progress():IProgress
    {
        return mainProgress;
    }

    public function LoadImageThread()
    {
        var req:URLRequest,
            data:URLVariables;

        req = new URLRequest('http://query.yahooapis.com/v1/public/yql');
        data = new URLVariables();
        data['q'] = "SELECT * FROM flickr.photos.search(10) WHERE user_id='25105339@N07'";
        data['format'] = 'json';
        req.data = data;

        jsonLoader = new URLLoaderThread(req);
        mainProgress = new MultiProgress();
        subProgress = new MultiProgress();

        mainProgress.addProgress(jsonLoader.progress, 0.1);
        mainProgress.addProgress(subProgress);
    }

    override protected function run():void
    {
        jsonLoader.start();
        jsonLoader.join();

        next(loadDataComplete);
    }

    private function loadDataComplete():void
    {
        var json:Object,
            row:Object,
            th:LoaderThread,
            req:URLRequest,
            ctx:LoaderContext,
            flickr:FlickrPhoto;

        json = JSON.decode(jsonLoader.loader.data);
        ctx = new LoaderContext(true);

        imageLoader = new SerialExecutor();

        for each (row in json.query.results.photo)
        {
            flickr = new FlickrPhoto(row);
            req = new URLRequest(flickr.thumbnailURL);
            th = new LoaderThread(req, ctx);
            imageLoader.addThread(th);
            subProgress.addProgress(th.progress);
        }
        imageLoader.start();
        imageLoader.join();

        next(loadImageComplete);
    }

    private function loadImageComplete():void
    {
        var i:uint,
            l:uint,
            th:LoaderThread;

        contents = [];
        l = imageLoader.numThreads;
        for (i=0; i<l; i++)
        {
            th = imageLoader.getThreadAt(i) as LoaderThread;
            contents.push(th.loader.content);
        }
    }

    override protected function finalize():void
    {
        jsonLoader = null;
        imageLoader = null;
    }
}

internal class LoadImageProgressThread extends Thread
{
    private var progress:IProgress;
    private var layer:DisplayObjectContainer;
    private var indicator:HandleIndicatorThread;

    public function LoadImageProgressThread(layer:DisplayObjectContainer, progress:IProgress)
    {
        this.layer = layer;
        this.progress = progress;
    }

    override protected function run():void
    {
        indicator = new HandleIndicatorThread(layer);
        indicator.start();

        next(step);
    }

    private function step():void
    {
        if (progress.isCompleted||progress.isFailed||progress.isCanceled)
        {
            next(shutDown);

            return;
        }

        //  TODO: なにかしらやる。
        var percent:Number = progress.percent;

        if (percent >= 1)
        {
            next(shutDown);
        }
        else
        {
            next(step);
        }
    }

    private function shutDown():void
    {
        indicator.interrupt();
    }

    override protected function finalize():void
    {
        progress = null;
        layer = null;
        indicator = null;
    }
}

internal class HandleImageThread extends Thread
{
    public static const PARTICLE_MARGIN:Number = 6;

    private var original:Bitmap;
    private var destination:Bitmap;
    private var showParticles:Vector.<ShowImageParticle>;
    private var hideParticles:Vector.<HideImageParticle>;

    public function HandleImageThread(original:Bitmap, destination:Bitmap)
    {
        this.original = original;
        this.destination = destination;
        this.showParticles = new Vector.<ShowImageParticle>();
        this.hideParticles = new Vector.<HideImageParticle>();
    }

    override protected function run():void
    {
        var w:Number, h:Number, c:uint,
            tx:Number, ty:Number,
            sx:Number, sy:Number,
            cx:Number, cy:Number,
            angle:Number,
            i:uint, j:uint,
            s:Stage,
            data:BitmapData;

        s = destination.stage;
        data = original.bitmapData;
        w = data.width;
        h = data.height;
        cx = s.stageWidth / 2;
        cy = s.stageHeight / 2;

        for (i=0; i<w; i++)
        {
            for (j=0; j<h; j++)
            {
                c = data.getPixel32(i, j);

                if (!c) continue;

                angle = Math.random() * Math.PI * 2;
                sx = Math.cos(angle) * 500 + cx;
                sy = Math.sin(angle) * 500 + cy;
                tx = i * PARTICLE_MARGIN;
                ty = j * PARTICLE_MARGIN;
                showParticles.push(new ShowImageParticle(sx, sy, tx, ty, c));
                hideParticles.push(new HideImageParticle(tx, ty, sx, sy, c, s.frameRate));
            }
        }

        next(showStep);
    }

    private function showStep():void
    {
        var i:uint,
            l:uint,
            c:uint,
            a:Number,
            f:Boolean,
            p:ShowImageParticle,
            data:BitmapData;

        data = destination.bitmapData;
        data.lock();
        data.applyFilter(data, data.rect, POINT_ZERO, FILTER_BLUR);

        l = showParticles.length;
        f = false;
        for (i=0; i<l; i++)
        {
            p = showParticles[i];

            if (p.isAlive)
            {
                f = true;
                p.update();
            }
            data.setPixel32(p.x, p.y, p.color);
        }
        data.unlock();

        if (!f)
        {
            next(fixedImage);
        }
        else
        {
            next(showStep);
        }
    }

    private function hideStep():void
    {
        var i:uint,
            l:uint,
            c:uint,
            a:Number,
            f:Boolean,
            p:HideImageParticle,
            data:BitmapData;

        data = destination.bitmapData;
        data.lock();
        data.colorTransform(data.rect, new ColorTransform(1, 1, 1, .97, 0, 0, 0, 0));
        data.applyFilter(data, data.rect, POINT_ZERO, FILTER_BLUR);

        l = hideParticles.length;
        for (i=0; i<l; i++)
        {
            p = hideParticles[i];
            p.update();
            data.setPixel32(p.x, p.y, p.color);

            if (!data.rect.contains(p.x, p.y))
            {
                hideParticles.splice(i, 1);
                i--;
                l = hideParticles.length;
            }
        }
        data.unlock();
        //trace(p.x, p.y);

        if (l) next(hideStep);
    }

    private function fixedImage():void
    {
        sleep(3000);

        next(hideStep);
    }

    override protected function finalize():void
    {
        original = null;
        destination = null;
        showParticles.length = 0;
        showParticles = null;
        hideParticles.length = 0;
        hideParticles = null;
    }
}

internal class HandleIndicatorThread extends Thread
{
    private var layer:DisplayObjectContainer;
    private var indicator:DisplayObject;

    public function HandleIndicatorThread(layer:DisplayObjectContainer)
    {
        this.layer = layer;
    }

    override protected function run():void
    {
        Mouse.hide();

        layer.stage.mouseChildren = false;

        indicator = new Indicator();
        indicator.x = layer.mouseX;
        indicator.y = layer.mouseY;

        layer.addChild(indicator);

        next(step);
    }

    private function step():void
    {
        if (checkInterrupted()) return;

        indicator.rotation = (indicator.rotation + 360 / indicator.stage.frameRate) % 360;
        indicator.x = layer.mouseX;
        indicator.y = layer.mouseY;

        next(step);
    }

    override protected function finalize():void
    {
        Mouse.show();

        layer.stage.mouseChildren = true;
        layer.removeChild(indicator);
        layer = null;
        indicator = null;
    }
}

internal class HideMessageParticle
{
    public var x:Number;
    public var y:Number;
    public var ax:Number;
    public var ay:Number;
    public var vx:Number;
    public var vy:Number;
    public var color:uint;

    public function HideMessageParticle(x:Number, y:Number, color:Number)
    {
        var len:Number,
            angle:Number;

        len = Math.random() * 5;
        angle = Math.random() * Math.PI * 2;

        this.ax = Math.cos(angle) * len;
        this.ay = Math.sin(angle) * len;
        this.x = x;
        this.y = y;
        this.color = color;
        this.vx = 0;
        this.vy = 0;
    }

    public function update():void
    {
        vx += ax;
        vy += ay;
        x += vx;
        y += vy;
    }
}

import flash.geom.Point;

internal class ShowImageParticle
{
    public var x:Number;
    public var y:Number;
    public var color:uint;
    private var targetX:Number;
    private var targetY:Number;
    private var _isAlive:Boolean;

    public function get isAlive():Boolean
    {
        return _isAlive;
    }

    public function ShowImageParticle(x:Number, y:Number, targetX:Number, targetY:Number, color:uint)
    {
        this.x = x;
        this.y = y;
        this.color = color;
        this.targetX = targetX;
        this.targetY = targetY;
        this._isAlive = true;
    }

    public function update():void
    {
        x += (targetX - x) * .05;
        y += (targetY - y) * .05;

        if (Math.abs(targetX - x) < .5 && Math.abs(targetY - y) < .5)
        {
            x = targetX;
            y = targetY;
            _isAlive = false;
        }
    }
}

internal class HideImageParticle
{
    public var x:Number;
    public var y:Number;
    public var color:uint;
    private var vx:Number;
    private var vy:Number;
    private var ax:Number;
    private var ay:Number;
    private var rate:Number;

    public function HideImageParticle(x:Number, y:Number, targetX:Number, targetY:Number, color:uint, rate:Number)
    {
        var dx:Number,
            dy:Number,
            len:Number,
            angle:Number;

        dx = targetX - x;
        dy = targetY - y;
        len = 9.8;
        angle = Math.atan2(dy, dx);

        this.x = x;
        this.y = y;
        this.vx = 0;
        this.vy = 0;
        this.ax = Math.cos(angle) * len;
        this.ay = Math.sin(angle) * len;
        this.color = color;
        this.rate = rate;
    }

    public function update():void
    {
        vx += ax / rate;
        vy += ay / rate;
        x += vx;
        y += vy;
    }
}

internal class FlickrPhoto
{
    private var _id:String;
    public function get id():String
    {
        return _id;
    }

    private var _secret:String;
    public function get secret():String
    {
        return _secret;
    }

    private var _server:String;
    public function get server():String
    {
        return _server;
    }

    private var _farm:String;
    public function get farm():String
    {
        return _farm;
    }

    public function get thumbnailURL():String
    {
        return ['http://farm', farm, '.static.flickr.com/', server, '/', id, '_', secret, '_s.jpg'].join('');
    }

    public function FlickrPhoto(data:Object)
    {
        this._id = data['id'] || '';
        this._secret = data['secret'] || '';
        this._server = data['server'] || '';
        this._farm = data['farm'] || '';
    }
}

