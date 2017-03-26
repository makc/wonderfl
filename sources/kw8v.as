package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.utils.getTimer;
    
    [SWF(width="465",height="465",backgroundColor="#000000",frameRate="60")]
    public class Main extends Sprite 
    {
        
        public function Main():void 
        {
            const W: uint = this.stage.stageWidth;
            const H: uint = this.stage.stageHeight;
            
            //light
            var light: BallLight = new BallLight(new Vector3D(100, 100, 1000));
            light.strength = 2.0;
            light.color = 0xFFFFFFFF;
            
            //ball
            var ball: Ball = new Ball(new Vector3D(-100, 100, 800));
            ball.radius = 100;
            ball.refractiveIndex = 1.5;
            ball.color = 0xFFFF0000;
            var ball2: Ball = new Ball(new Vector3D(300, 100, 1200));
            ball2.radius = 100;
            ball2.refractiveIndex = 1.5;
            ball2.color = 0xFF0000FF;
            
            //picture
            var picture: Picture = new Picture(new Vector3D(0, 200, 1200));
            picture.load("http://assets.wonderfl.net/images/related_images/4/4e/4e20/4e202e6c59444724301938ea72697188440a719b", 600, 600, complete);
            picture.refractiveIndex = 1.5;            
            picture.scaleX = 10;
            picture.scaleY = 10;
            picture.vector1 = new Vector3D(- 1, 0, - 1);
            picture.vector2 = new Vector3D(1, 0, - 1);
            
            //world
            var world: World = new World(stage, W, H, light, ball, ball2, picture);
            
            //fps counter
            var tf: TextField = new TextField();
            tf.x = tf.y = 0;
            tf.width = W;
            tf.height = 20;
            tf.autoSize = "right";
            tf.textColor = 0xFFFFFF;
            stage.addChild(tf);
            
            var time: uint = getTimer();
            
            function complete(e: Event): void {
                stage.addEventListener(Event.ENTER_FRAME, ef);
            }
            
            var i: uint = 0;            
            function ef(e: Event): void {
                world.render(i, i + 1);
                i += 1;
                if (i >= H) {
                    i = 0;
                    light.position.y -= 50;
                    light.position.z -= 50;
                    world.sample();
                }
                tf.text = Math.floor(1000 / (getTimer() - time)) + "fps";
                time = getTimer();
            }
        }
    }
}

import flash.geom.Vector3D;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.net.URLRequest;
import flash.system.LoaderContext;
class Model
{
    private var _position: Vector3D;
    private var _refractiveIndex: Number;
    private var _color: uint;
    private var _strength: Number;
    
    public function Model(_position: Vector3D = null, _refractiveIndex: Number = 1., _color: uint = 0xFFFFFFFF) {
        if(_position) {
            position = _position;
        }else {
            position = new Vector3D();
        }
        refractiveIndex = _refractiveIndex;
        color = _color;
        strength = 1.;
    }
    
    public function clone(): Model {
        return new Model(position, refractiveIndex, color);
    }
    
    public function get position():Vector3D { return _position; }
    
    public function set position(value:Vector3D):void 
    {
        _position = value;
    }
    
    public function get refractiveIndex():Number { return _refractiveIndex; }
    
    public function set refractiveIndex(value:Number):void 
    {
        _refractiveIndex = value;
    }
    
    public function get color():uint { return _color; }
    
    public function set color(value:uint):void 
    {
        _color = value;
    }
    
    public function get strength():Number { return _strength; }
    
    public function set strength(value:Number):void 
    {
        _strength = value;
    }
    
    public function intersection(ray: Ray): void {
        //setting of position, color and strength
        //if ray does not intersect, set strength 0
        ray.strength = 0;
    }
    
    public function normalVector(ray: Ray): Vector3D {
        return Vector3D.Z_AXIS;
    }
}
class Ball extends Model
{
    private var _radius: Number;
    
    public function Ball(_position: Vector3D = null) {
        super(_position);
    }
    
    public function get radius():Number { return _radius; }
    
    public function set radius(value:Number):void 
    {
        _radius = value;
    }
    
    public override function intersection(ray: Ray): void {
        var point: Vector3D;
        var p: Vector3D = ray.position;
        var v: Vector3D = ray.vector;
        var o: Vector3D = position;
        var r: Number = radius;
        var a: Number = v.lengthSquared;
        var b: Number = p.dotProduct(v) - o.dotProduct(v);
        var c: Number = p.subtract(o).lengthSquared - r * r;
        var t: Number = - b - Math.sqrt(b * b - a * c);
        if (!t || t < 0.001) {
            t = - b + Math.sqrt(b * b - a * c);
        }
        point = v.clone();
        point.scaleBy(t);
        point.incrementBy(p);
        if (!t || t < 0.001) {
            ray.strength = 0;
        }
        ray.position = point;
        ray.color = color;
    }
    
    public override function normalVector(ray: Ray): Vector3D {
        //set the position of rays before use this
        var normal: Vector3D = ray.position.subtract(position);
        normal.normalize();
        if (position.subtract(ray.position).dotProduct(ray.vector) < 0) {
            normal.negate();
        }
        return normal;
    }
}
class Light extends Model
{
    public function Light(_position: Vector3D = null) {
        super(_position);
    }
}
class BallLight extends Light 
{
    private var _radius: Number;
    
    public function BallLight(_position: Vector3D = null) {
        super(_position);
        radius = 100;
    }
    
    public function get radius():Number { return _radius; }
    
    public function set radius(value:Number):void 
    {
        _radius = value;
    }
    
    public override function intersection(ray: Ray): void {
        var point: Vector3D;
        var p: Vector3D = ray.position;
        var v: Vector3D = ray.vector;
        var o: Vector3D = position;
        var r: Number = radius;
        var a: Number = v.lengthSquared;
        var b: Number = p.dotProduct(v) - o.dotProduct(v);
        var c: Number = p.subtract(o).lengthSquared - r * r;
        var t: Number = - b - Math.sqrt(b * b - a * c);
        if (!t || t < 0.001) {
            t = - b + Math.sqrt(b * b - a * c);
        }
        point = v.clone();
        point.scaleBy(t);
        point.incrementBy(p);
        if (!t || t < 0.001) {
            ray.strength = 0;
        }
        ray.position = point;
        ray.color = color;
    }
    
    public override function normalVector(ray: Ray): Vector3D {
        //set the position of rays before use this
        var normal: Vector3D = ray.position.subtract(position);
        normal.normalize();
        if (position.subtract(ray.position).dotProduct(ray.vector) < 0) {
            normal.negate();
        }
        return normal;
    }
}
class Picture extends Model
{
    private var _image: BitmapData;
    private var _width: uint;
    private var _height: uint;
    private var _scaleX: Number;
    private var _scaleY: Number;
    private var _vector1: Vector3D;
    private var _vector2: Vector3D;
    
    public function Picture(_position: Vector3D = null) {
        super(_position);
        scaleX = 1.;
        scaleY = 1.;
        vector1 = Vector3D.X_AXIS;
        vector2 = Vector3D.Y_AXIS;
    }
    
    public function get image():BitmapData { return _image; }
    
    public function set image(value:BitmapData):void 
    {
        _image = value;
    }
    
    public function get width():uint { return _width; }
    
    public function set width(value:uint):void 
    {
        _width = value;
    }
    
    public function get height():uint { return _height; }
    
    public function set height(value:uint):void 
    {
        _height = value;
    }
    
    public function get vector1():Vector3D { return _vector1; }
    
    public function set vector1(value:Vector3D):void 
    {
        _vector1 = value;
        _vector1.normalize();
    }
    
    public function get vector2():Vector3D { return _vector2; }
    
    public function set vector2(value:Vector3D):void 
    {
        _vector2 = value;
        _vector2.normalize();
    }
    
    public function get scaleX():Number { return _scaleX; }
    
    public function set scaleX(value:Number):void 
    {
        _scaleX = value;
    }
    
    public function get scaleY():Number { return _scaleY; }
    
    public function set scaleY(value:Number):void 
    {
        _scaleY = value;
    }
    
    public function load(url: String, _width: uint, _height: uint, callback: Function): void {
        var loader: Loader = new Loader();
        var request: URLRequest = new URLRequest(url);
        var context: LoaderContext = new LoaderContext(true);
        width = _width;
        height = _height;
        image = new BitmapData(width, height, true);
        loader.load(request, context);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, callback);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
        function complete(e: Event): void {
            image.draw(loader);
        }
    }
    
    public override function intersection(ray: Ray): void {
        var point: Vector3D;
        var p: Vector3D = ray.position;
        var v: Vector3D = ray.vector;
        var q: Vector3D = position;
        var u: Vector3D = vector1;
        var w: Vector3D = vector2;
        var matrixA: Matrix3D, matrixB: Matrix3D;
        var k: Number, s: Number, t: Number;
        matrixA = new Matrix3D(Vector.<Number>(new Array(1, 0, 0, 0, 0, v.x, - u.x, - w.x, 0, v.y, - u.y, - w.y, 0, v.z, - u.z, - w.z)));
        matrixA.invert();
        matrixB = new Matrix3D(Vector.<Number>(new Array(1, 0, 0, 0, 0, 1, 0, q.x - p.x, 0, 0, 1, q.y - p.y, 0, 0, 0, q.z - p.z)));
        matrixA.append(matrixB);
        k = matrixA.rawData[7];
        s = matrixA.rawData[11];
        t = matrixA.rawData[15];
        point = v.clone();
        point.scaleBy(k);
        point.incrementBy(p);
        if (k < 0.001 || s > width / 2 * scaleX || s < - width / 2 * scaleX || t > height / 2 * scaleY || t < - height / 2 * scaleY) {
            //point = new Vector3D();
            ray.strength = 0;
        }
        ray.position = point;
        ray.color = image.getPixel32(Math.round(s / scaleX + width / 2), Math.round(t / scaleY + height / 2));
    }
    
    public override function normalVector(ray: Ray): Vector3D {
        var normal: Vector3D = vector1.crossProduct(vector2);
        normal.normalize();
        return normal;
    }
}
class Pixel 
{
    private var _rays: Vector.<Ray>;
    
    public function Pixel(_ray: Ray = null) {
        rays = new Vector.<Ray>();
        if(_ray) {
            rays[0] = _ray;
        }
    }
    
    public function get rays():Vector.<Ray> { return _rays; }
    
    public function set rays(value:Vector.<Ray>):void 
    {
        _rays = value;
    }
    
    public function color(): uint {
        var i: uint, l: uint = rays.length,
        red: uint, green: uint, blue: uint;
        red = green = blue = 0;
        for (i = 0; i < l; i ++ ) {
            red += ((0xFF0000 & rays[i].color) >> 16) * rays[i].strength;
            green += ((0xFF00 & rays[i].color) >> 8) * rays[i].strength;
            blue += (0xFF & rays[i].color) * rays[i].strength;
        }
        
        if (red > 0xFF) {
            red = 0xFF;
        }
        if (green > 0xFF) {
            green = 0xFF;
        }
        if (blue > 0xFF) {
            blue = 0xFF;
        }
        return 0xFF000000 | (red << 16) | (green << 8) | (blue);
    }
    
    public function rayTrace(models: Vector.<Model>): void {
        var i: uint, j: uint, l: uint = models.length,
        temporaryRay: Ray, nearestRay: Ray, reflectRay: Ray, refractRay: Ray, normal: Vector3D, n: uint,
        distance: Number, object: Number, reflectance: Number;
        for (i = 0; i < rays.length && i < 8; i ++ ) {
            object = Infinity;
            n = l;
            for (j = 0; j < l; j ++ ) {
                temporaryRay = rays[i].clone();
                models[j].intersection(temporaryRay);
                if (temporaryRay.strength > 0) {
                    distance = rays[i].position.subtract(temporaryRay.position).length;
                    if (distance < object) {
                        object = distance;
                        nearestRay = temporaryRay;
                        n = j;
                    }
                }
            }
            if (n < l) {
                rays[i] = nearestRay;
                //attenuation by distance
                rays[i].strength *= 1 / Math.pow(object / 2000 + 1, 2);
                normal = models[n].normalVector(rays[i]);
                if (models[n] is Light) {
                    rays[i].strength *= models[n].strength;
                }else {
                    reflectRay = rays[i].clone();
                    reflectance = reflectRay.strength;
                    reflectRay.reflect(normal, 1, models[n].refractiveIndex);
                    reflectRay.strength *= 1;
                    reflectance = reflectRay.strength / reflectance;
                    rays.push(reflectRay);
                    rays[i].strength *= 1 - reflectance;
                    rays[i].vector = models[0].position.subtract(rays[i].position);
                    //lighting
                    if(rays[i].vector.dotProduct(normal) > 0 && rays[i].strength > 0) {
                        object = Infinity;
                        n = l;
                        for (j = 0; j < l; j ++ ) {
                            temporaryRay = rays[i].clone();
                            models[j].intersection(temporaryRay);
                            if (temporaryRay.strength > 0) {
                                distance = rays[i].position.subtract(temporaryRay.position).length;
                                if (distance < object) {
                                    object = distance;
                                    nearestRay = temporaryRay;
                                    n = j;
                                }
                            }
                        }
                        if (models[n] is Light) {
                            rays[i].strength *= models[n].strength;
                            //attenuation by polygon
                            rays[i].strength *= rays[i].vector.dotProduct(normal);
                            //attenuation by distance
                            rays[i].strength *= 1 / Math.pow(object / 2000 + 1, 2);
                        }else {
                            rays[i].strength = 0;
                        }
                    }else {
                        rays[i].strength = 0;
                    }
                }
            }else {
                rays[i].strength = 0;
            }
        }
    }
}
class Ray
{
    private var _position: Vector3D;
    private var _vector: Vector3D;
    private var _strength: Number;
    private var _color: uint;
    
    public function Ray(_position: Vector3D = null, _vector: Vector3D = null, _strength: Number = 1., _color: uint = 0x0) {
        if(_position) {
            position = _position;
        }else {
            position = new Vector3D();
        }
        if(_vector) { 
            vector = _vector;
        }else {
            vector = new Vector3D();
        }
        strength = _strength;
        color = _color;
    }
    
    public function clone(): Ray {
        return new Ray(position.clone(), vector.clone(), strength, color);
    }
    
    public function get position():Vector3D { return _position; }
    
    public function set position(value:Vector3D):void 
    {
        _position = value;
    }
    
    public function get vector():Vector3D { return _vector; }
    
    public function set vector(value:Vector3D):void 
    {
        _vector = value;
        if (_vector) {
            _vector.normalize();
        }
    }
    
    public function get strength():Number { return _strength; }
    
    public function set strength(value:Number):void 
    {
        _strength = value;
    }
    
    public function get color():uint { return _color; }
    
    public function set color(value:uint):void 
    {
        _color = value;
    }
    
    public function reflect(_normal: Vector3D, refractiveIndex1: Number, refractiveIndex2: Number): void {
        var normal: Vector3D = _normal.clone();
        var r1: Number = refractiveIndex1;
        var r2: Number = refractiveIndex2;
        var cosI: Number = normal.dotProduct(vector) * - 1;
        var sinI: Number = Math.sqrt(1 - cosI * cosI);
        var sinR: Number = (r1 / r2) * sinI;
        var cosR: Number = Math.sqrt(1 - sinR * sinR);
        var rvector: Vector3D = normal.clone();
        rvector.scaleBy(normal.dotProduct(vector) * - 2);
        vector.incrementBy(rvector);
        //reflectance
        strength *= Math.pow((r1 * cosI - r2 * cosR) / (r1 * cosI + r2 * cosR), 2);
    }

}
class World 
{
    private var _models: Vector.<Model>;
    private var _width: uint;
    private var _height: uint;
    private var _depth: Number;
    private var _bmpData: BitmapData;
    
    public function World(display: DisplayObjectContainer, _width: uint, _height: uint, ..._models: Array) {
        models = Vector.<Model>(_models);
        width = _width;
        height = _height;
        bmpData = new BitmapData(width, height, true, 0x0);
        display.addChild(new Bitmap(bmpData));
    }
    
    public function get models():Vector.<Model> { return _models; }
    
    public function set models(value:Vector.<Model>):void 
    {
        _models = value;
    }
    
    public function get width():uint { return _width; }
    
    public function set width(value:uint):void 
    {
        _width = value;
        depth = _width / 2 / Math.tan(Math.PI / 360 * 60);
    }
    
    public function get height():uint { return _height; }
    
    public function set height(value:uint):void 
    {
        _height = value;
    }
    
    public function get depth():Number { return _depth; }
    
    public function set depth(value:Number):void 
    {
        _depth = value;
    }
    
    public function get bmpData():BitmapData { return _bmpData; }
    
    public function set bmpData(value:BitmapData):void 
    {
        _bmpData = value;
    }
    
    public function render(start: uint = 0, end: uint = 0): void {
        var i: uint, j: uint, l: uint = width;
        var ray: Ray = new Ray();
        var pixel: Pixel = new Pixel();
        if (!end || end > height) {
            end = height;
        }
        bmpData.lock();
        for (j = start; j < end; j ++ ) {
            for (i = 0; i < l; i ++ ) {            
                ray.position = new Vector3D();
                ray.vector = new Vector3D(i - width / 2, j - height / 2, depth);
                ray.strength = 1.;
                ray.color = 0x0;
                pixel.rays = new Vector.<Ray>();
                pixel.rays[0] = ray;
                pixel.rayTrace(models);
                bmpData.setPixel32(i, j, pixel.color());
            }
        }
        bmpData.unlock();
    }
    
    public function sample(): void {
        var i: uint, j: uint;
        var red: uint, green: uint, blue: uint, color: uint;
        for (i = 0; i < width / 2; i ++ ) {
            for (j = 0; j < height / 2; j ++ ) {
                red = green = blue = 0;
                color = bmpData.getPixel32(i * 2, j * 2);
                red += ((0xFF0000 & color) >> 16) / 4;
                green += ((0xFF00 & color) >> 8) / 4;
                blue += (0xFF & color) / 4;
                color = bmpData.getPixel32(i * 2 + 1, j * 2);
                red += ((0xFF0000 & color) >> 16) / 4;
                green += ((0xFF00 & color) >> 8) / 4;
                blue += (0xFF & color) / 4;
                color = bmpData.getPixel32(i * 2 + 1, j * 2 + 1);
                red += ((0xFF0000 & color) >> 16) / 4;
                green += ((0xFF00 & color) >> 8) / 4;
                blue += (0xFF & color) / 4;
                color = bmpData.getPixel32(i * 2, j * 2 + 1);
                red += ((0xFF0000 & color) >> 16) / 4;
                green += ((0xFF00 & color) >> 8) / 4;
                blue += (0xFF & color) / 4;
                bmpData.setPixel32(i, j, 0xFF000000 | (red << 16) | (green << 8) | (blue));
            }
        }
    }
}