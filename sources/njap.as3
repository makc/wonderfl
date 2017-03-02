/**
 * コースは毎回微妙に変わります
 * ちょっとだけバランス調整しました
 * 
 * [UP] : Accelerate
 * [RIGHT/LEFT] Steer
 * [DOWN] Reverse
 * [SHIFT] : Brake
 */
package {
    import Box2D.Common.Math.*;
    import com.actionsnippet.qbox.*;
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.ui.*;
    import flash.utils.*;
    public class Race extends Sprite {
        private var _display:Sprite = new Sprite();
        private var _scene:Sprite = new Sprite();
        private var _ground:Sprite;
        private var _container:MovieClip;
        private var _sim:QuickBox2D;
        private var _world:World = new World();
        //敵の数
        private const ENEMY_NUM:int = 14;
        //周回数
        private const LAP_NUM:int = 4;
        private var _fogColor:uint = 0x73BCFC;
        private var _viewRadius:Number = 1000;
        private var _car:Car;
        private var _cars:Vector.<Car> = new Vector.<Car>();
        private var _sprite3d:Dictionary = new Dictionary();
        private var _b2dObjects:Vector.<QuickObject> = new Vector.<QuickObject>();
        private var _movableObjects:Vector.<QuickObject> = new Vector.<QuickObject>();
        private var _sorts:Vector.<QuickObject> = new Vector.<QuickObject>();
        private var _texture:BitmapData;
        private var _map:Sprite = new Sprite();
        private var _rank:Label;
        private var _speed:Label;
        private var _message:Label;
        private var _mapScale:Point = new Point(1, 1);
        
        public function Race() {
            stage.frameRate = 30;
            stage.quality = StageQuality.BEST;
            transform.perspectiveProjection.fieldOfView = 70;
            transform.perspectiveProjection.projectionCenter = new Point(465 / 2, 300);
            
            addChild(Draw.box(-1000, -1000, 2465, 2465, _fogColor));
            addChild(_display);
            addChild(_map);
            _display.addChild(_scene);
            _scene.x = 232.5;
            _scene.y = 330;
            _scene.scaleX = _scene.scaleY = _scene.scaleZ = 3;
            _scene.rotationX = -60;
            _scene.z = 100;
            _ground = _scene.addChild(new Sprite()) as Sprite;
            _ground.addChild(Draw.circle(0, 0, _viewRadius + 5, _viewRadius + 5, [_fogColor, _fogColor], [0, 1], [100, 250]));
            _container = _ground.addChild(new MovieClip()) as MovieClip;
            
            _sim = new QuickBox2D(_container, { gravityY:0, bounds:[$.SIZE_QBOX.x, $.SIZE_QBOX.y, $.SIZE_QBOX.right, $.SIZE_QBOX.bottom] } );
            _sim.setDefault( { lineAlpha:0 } );
            
            _texture = new BitmapData($.SIZE_QBOX.width * $.QtoF * $.SCALE_MAP, $.SIZE_QBOX.height * $.QtoF * $.SCALE_MAP, true, 0xFF9DE624);
            _world.dirtMap = new BitmapData(_texture.width, _texture.height, false, 0xFF808080);
            
            var i:int, n:Number, p:Point, tp:Point, lines:Shape = new Shape();
            //コース生成
            for (i = 0; i < 20; i ++) {
                var radius:Number = (i <= 2 || i == 19)? 50 : (Math.random() * 25 + 50);
                _world.course.push(new Point(Math.cos(Math.PI * i / 10) * radius, Math.sin(Math.PI * i / 10) * radius));
            }
            _world.calculateTightness();
            _world.course.push(_world.course[0].clone());
            
            //コースを描画
            lines.graphics.lineStyle(2, 0xFFFFFF, 1);
            for (i = 0; i < _world.course.length; i++) {
                p = _world.course[i];
                if (!i) lines.graphics.moveTo($.QtoM(p.x), $.QtoM(p.y));
                else {
                    if (i % 4) {
                        //木を植える
                        for (n = 1; n <= 3; n++) {
                            tp = Point.interpolate(p, _world.course[i - 1], n / 3);
                            createObject(tp.x * (Math.random() * 0.05 + 0.85), tp.y * (Math.random() * 0.05 + 0.85), Dot.tree, 15, 0.3, 0, 0.2);
                            createObject(tp.x * (Math.random() * 0.05 + 1.1), tp.y * (Math.random() * 0.05 + 1.1), Dot.tree, 15, 0.3, 0, 0.2);
                        }
                    } else {
                        //カラーコーンとドラム缶を置く
                        tp = Point.interpolate(p, _world.course[i - 1], 0.4);
                        for (n = 1; n <= 3; n++) createObject(tp.x*1.08+Math.random(), tp.y*1.08+Math.random(), Dot.drum, 3, 0.3, 0.7, 0.2);
                        for (n = 0.7; n <= 1; n+=0.1) {
                            tp = Point.interpolate(p, _world.course[i - 1], n);
                            createObject(tp.x * 0.93, tp.y * 0.93, Dot.cone, 3, 0.2, 0.1, 0.2);
                        }
                    }
                    lines.graphics.lineTo($.QtoM(p.x), $.QtoM(p.y));
                }
            }
            _world.course.pop();
            
            //テクスチャにコースを貼りつけ
            lines.filters = [new GlowFilter(0x4A4A4A, 1, 20, 20, 100, 2), new GlowFilter(0xD9C364, 1, 15, 15, 3, 2),new GlowFilter(0x53BA37, 1, 50, 50, 3, 2)];
            _texture.draw(lines);
            
            //マップ
            var temp:BitmapData = new BitmapData(_texture.width, _texture.height, true, 0);
            temp.draw(lines);
            var miniMap:BitmapData = new BitmapData(250, 250, true, 0);
            _mapScale = new Point(miniMap.width / _texture.width, miniMap.height / _texture.height);
            miniMap.draw(temp, new Matrix(_mapScale.x, 0, 0, _mapScale.y, 0, 0), null, null, null, true);
            _map.addChild(new Bitmap(miniMap)).alpha = 0.5;
            _map.x = -20;
            _map.y = 465 - _map.height + 20;
            temp.dispose();
            
            lines.filters = [new GlowFilter(0xFFFFFF, 1, 20, 20, 100, 2), new GlowFilter(0xFFFFFF, 1, 10, 10, 2, 2)];
            _world.dirtMap.draw(lines, null, new ColorTransform(0, 0, 0, 1, 0xFF, 0xFF, 0xFF));
            
            
            //スタートライン
            p = Point.interpolate(_world.course[0], _world.course[1], 0.5);
            tp = _world.course[1].subtract(_world.course[0]);
            var mtx:Matrix = new Matrix();
            mtx.rotate(Math.atan2(tp.y, tp.x)+Math.PI/2);
            mtx.translate($.QtoM(p.x), $.QtoM(p.y));
            _texture.draw(Draw.spriteBmp(Dot.startingLine, 2.8, -7, -2), mtx);
            
            //テクスチャに木の影を焼き込む
            for each(qobj in _b2dObjects) qobj.body.IsStatic() && _texture.draw(Draw.circle(0, 0, 20, 20, [0, 0], [0.2, 0], [100, 255]), new Matrix(1, 0, 0, 1, $.QtoM(qobj.x), $.QtoM(qobj.y)));
            
            //ワールドの壁
            for (i = 0; i < 4; i++) _b2dObjects.push(_sim.addBox( { mass:0, x:[-95,95,0,0][i], y:[0,0,-95,95][i], width:[10,10,180,180][i], height:[200,200,10,10][i], fillAlpha:0.5, fillColor:0x000000 } ));
            
            //湖
            var lake:QuickObject = _sim.addCircle( { mass:0, x:0, y:0, radius:40, fillColor:0x21429E } );
            Sprite(lake.userData).filters = [new GlowFilter(0x85C0FB, 1, 10, 10, 2, 2, true), new GlowFilter(0xD9C364, 1, 50, 50, 3, 2)];
            _b2dObjects.push(lake);
            
            //テクスチャに雲の影とノイズを焼き込む
            var noise:BitmapData = _texture.clone();
            noise.perlinNoise(150, 150, 5, Math.random() * 300, true, true, 7, true);
            noise.threshold(noise, noise.rect, new Point(), "<=", 0xFF90FFFF, 0x00000000);
            noise.applyFilter(noise, noise.rect, new Point(), new BlurFilter(6, 3, 3));
            noise.colorTransform(noise.rect, new ColorTransform(1, 1, 1, 0.7));
            _texture.draw(noise, null, null, BlendMode.MULTIPLY);
            noise.noise(123, 0x0, 0x30, 7, true);
            _texture.draw(noise, null, null, BlendMode.SUBTRACT);
            _texture.draw(_container, new Matrix($.SCALE_MAP, 0, 0, $.SCALE_MAP, 3000*$.SCALE_MAP, 3000*$.SCALE_MAP));
            
            //車
            _car = createCar(false, 0xFFE31A, 2.3, Dot.car1);
            _car.setStartPosition(_world.course[0].x, _world.course[0].y);
            _cameraAngle = _car.qobject.angle;
            var cornerNum:int = _world.course.length;
            var handicap:Number = Math.min(1, _world.totalTightness / 3.5) * 0.3 + 0.7;
            for (i = 0; i < ENEMY_NUM; i++) {
                var index:int = Math.min(10, cornerNum-1) - (i % Math.min(10, cornerNum-1));
                var skin:BitmapData = (index >= 9)? [Dot.car4, Dot.car3][index - 9] : Dot.car2;
                var enemy:Car = createCar(true, 0xFF0000, 0.3, skin);
                enemy.accel = (6.5 + index / 10 * 2) * handicap;
                enemy.setStartPosition(_world.course[index].x + (Math.random() - 0.5) * 5, _world.course[index].y + (Math.random() - 0.5) * 5, (index + 1) % cornerNum);
                enemy.proactiveRate = Math.random() * 0.6 + 0.4;
            }
            
            for each (var qobj:QuickObject in _b2dObjects) qobj.userData && qobj.userData.parent.removeChild(qobj.userData);
            
            //もじゃ
            createObject(50, 50, Dot.fl, 5, 0.5, 0.02, 3);
            createObject(-50, -50, Dot.ps, 5, 0.5, 0.02, 3);
            
            Style.LABEL_TEXT = 0xFFFFFF;
            Style.fontSize *= 2;
            var labels:Sprite = addChild(new Sprite()) as Sprite;
            _rank = new Label(labels, 370, 370);
            _speed = new Label(labels, 200, 5);
            _message = new Label(labels, 160, 200, "PRESS ANY KEY");
            _rank.scaleX = _rank.scaleY = 3;
            new Label(labels, 420, 430, "/ " + (ENEMY_NUM + 1));
            labels.filters = [new DropShadowFilter(1, 45, 0, 1, 5, 5, 100, 1)];
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUpDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpDown);
            stage.quality = StageQuality.LOW;
            addEventListener(Event.EXIT_FRAME, onTickSimurate);
            _sim.start();
        }
        
        private function createCar(isCPU:Boolean = true, rgb:uint = 0xC80000, density:Number = 0.3, bmd:BitmapData = null):Car {
            var car:Car = new Car(_sim, isCPU, rgb, density);
            car.qobject.angle = Math.PI;
            car.sprite.graphics.clear();
            car.sprite.addChild(Draw.bitmap(bmd, 4, -3, -4));
            _sprite3d[car.qobject] = car.sprite;
            _b2dObjects.push(car.qobject);
            _cars.push(car);
            _map.addChild(car.mark);
            return car;
        }
        
        private function createObject(xp:Number, yp:Number, bmd:BitmapData, scale:Number = 1, radius:Number = 0.3, density:Number = 1, restitution:Number = 0.2):QuickObject {
            var sp:Sprite = new Sprite();
            sp.addChild(Draw.bitmap(bmd, scale, -bmd.width / 2, -bmd.height));
            var qobj:QuickObject = _sim.addCircle( { density:density, restitution:restitution, x:xp, y:yp, radius:radius, skin:"none" } );
            _sprite3d[qobj] = sp;
            _b2dObjects.push(qobj);
            if (density > 0) _movableObjects.push(qobj);
            return qobj;
        }
        
        private function onKeyUpDown(e:KeyboardEvent):void {
            if (!_isPlaying) {
                _time = getTimer();
                _isPlaying = true;
                _message.text = "";
            }
            var isDown:Boolean = (e.type == KeyboardEvent.KEY_DOWN);
            switch(e.keyCode) {
                case Keyboard.UP: _world.key = (isDown)? _world.key | 0xF0000 : _world.key & 0x0FFFF; break;
                case Keyboard.DOWN: _world.key = (isDown)? _world.key | 0x0F000 : _world.key & 0xF0FFF; break;
                case Keyboard.LEFT: _world.key = (isDown)? _world.key | 0x00F00 : _world.key & 0xFF0FF; break;
                case Keyboard.RIGHT: _world.key = (isDown)? _world.key | 0x000F0 : _world.key & 0xFFF0F; break;
                case Keyboard.SHIFT: _world.key = (isDown)? _world.key | 0x0000F : _world.key & 0xFFFF0; break;
            }
        }
        
        private var _lap:Number = 1;
        private var _time:Number = 0;
        private var _cameraAngle:Number;
        private var _isPlaying:Boolean = false;
        private var _isFinish:Boolean = false;
        
        private function onTickSimurate(e:Event):void {
            var i:int, qobj:QuickObject;
            if (_isPlaying) {
                if (_message.text != "" && getTimer() - _time > 4000) _message.text = "";
                for each (var car:Car in _cars) {
                    car.update(_world);
                    car.mark.x = $.QtoM(car.qobject.x) * _mapScale.x;
                    car.mark.y = $.QtoM(car.qobject.y) * _mapScale.y;
                }
                if (!_isFinish) {
                    _cameraAngle = ease(_cameraAngle, -_car.qobject.angle, 0.1, Math.PI * 2);
                    _cars.sort(function(a:Car, b:Car):int { return int(a.lap < b.lap) - int(a.lap > b.lap) } );
                    for (i = 0; i < _cars.length; i++) _cars[i].rank = i + 1;
                    _rank.text = String(_car.rank);
                    if (_car.lap >= _lap) {
                        var sec:Number = (getTimer() - _time) / 1000;
                        var lapTime:String = int(sec / 60) + ":" + (sec % 60).toFixed(3);
                        _message.text = (LAP_NUM - _lap > 1)? lapTime : [(_car.rank == 1)?"WINNER" : "FINISH", "FINAL LAP"][LAP_NUM - _lap];
                        if (_isFinish = (_lap++ == LAP_NUM)) {
                            _message.scaleX = _message.scaleY = 2;
                            _car.isCPU = true;
                        }
                        _time = getTimer();
                    }
                }
                _speed.text = String(_car.speed * 5 | 0) + " kph";
            }
            _container.x = -_car.qobject.userData.x;
            _container.y = -_car.qobject.userData.y;
            _ground.rotation = _cameraAngle / Math.PI * 180;
            _ground.graphics.clear();
            _ground.graphics.beginBitmapFill(_texture, new Matrix(1/$.SCALE_MAP, 0, 0, 1/$.SCALE_MAP, _container.x - 3000, _container.y - 3000));
            _ground.graphics.drawCircle(0, 0, _viewRadius);
            
            _sorts.length = 0;
            for each (qobj in _movableObjects) {
                if (!qobj.body.IsSleeping()) {
                    qobj.body.GetLinearVelocity().Multiply(0.95);
                    if (qobj.body.GetLinearVelocity().Length() < 0.1) qobj.body.PutToSleep();
                }
            }
            for each (qobj in _b2dObjects) update(qobj) && _sorts.push(qobj);
            _sorts.sort(function(a:QuickObject, b:QuickObject):int {
                var az:Number = a.x * Math.sin(_cameraAngle) + a.y * Math.cos(_cameraAngle);
                var bz:Number = b.x * Math.sin(_cameraAngle) + b.y * Math.cos(_cameraAngle);
                return int(az > bz) - int(az < bz);
            });
            for (i = 0; i < _sorts.length; i++)_container.setChildIndex(_sprite3d[_sorts[i]], i + 1);
            
            _display.x = _car.dirtRate * _car.speedRate * Math.random() * 15;
            _display.y = _car.dirtRate * _car.speedRate * Math.random() * 15;
        }
        
        private function update(obj:QuickObject):Boolean {
            var sprite:Sprite = _sprite3d[obj];
            if (!sprite) return false;
            var vp:Point = new Point(Math.cos(-_cameraAngle), Math.sin(-_cameraAngle));
            var bp:Point = new Point(Math.cos(-_cameraAngle + Math.PI / 2), Math.sin(-_cameraAngle + Math.PI / 2));
            bp.normalize(150);
            var cp:Point = new Point(_car.qobject.userData.x, _car.qobject.userData.y);
            var dp:Point = new Point(obj.x * $.QtoF, obj.y * $.QtoF);
            var sp:Point = dp.subtract(cp.add(bp));
            var dist:Number = Point.distance(dp, cp);
            if ((vp.x * sp.y) - (vp.y * sp.x) < 0 && dist < _viewRadius) {
                sprite.x = dp.x;
                sprite.y = dp.y;
                if(obj.userData !== sprite){
                    sprite.rotationZ = -_ground.rotation;
                    sprite.rotationX = 90;
                }
                var per:Number = 1-Math.max(0, (dist - _viewRadius + 400) / 400);
                sprite.transform.colorTransform = new ColorTransform(per, per, per, 1, (_fogColor>>16&0xFF)*(1-per), (_fogColor>>8&0xFF)*(1-per), (_fogColor&0xFF)*(1-per));
                if (!sprite.parent) _container.addChild(sprite);
            } else if (sprite.parent) sprite.parent.removeChild(sprite);
            return !!sprite.parent;
        }
        
        private function ease(value:Number, target:Number, easing:Number, loopLimit:Number):Number {
            var offset:Number = target - value;
            if (Math.abs(offset) > loopLimit / 2) target -= offset / Math.abs(offset) * loopLimit;
            return (value + (target - value) * easing + loopLimit) % loopLimit;
        }
    }
}

import Box2D.Common.Math.*;
import com.actionsnippet.qbox.*;
import com.bit101.components.*;
import flash.display.*;
import flash.geom.*;

class World {
    public var key:uint = 0x00000;
    public var startRotation:Number = 10;
    public var dirtMap:BitmapData;
    public var course:Vector.<Point> = new Vector.<Point>();
    public var tightness:Vector.<Number> = new Vector.<Number>();
    public var totalTightness:Number = 0;
    public function World() {
    }
    public function calculateTightness():void {
        course.push(course[0].clone());
        course.unshift(course[course.length - 2].clone());
        
        for (var i:int = 1; i < course.length - 1; i++) {
            var c0:Point = course[i].subtract(course[i - 1]);
            var c1:Point = course[i].subtract(course[i + 1]);
            var rot:Number = 180 - Math.acos(Math.min(1, Math.max(-1, (c0.x * c1.x + c0.y * c1.y) / (c0.length * c1.length)))) / Math.PI * 180;
            var t:Number = Math.max(0, rot - 45) / 45;
            tightness.push(t);
            totalTightness += t;
        }
        course.pop();
        course.shift();
    }
}

class $ {
    static public const QtoF:Number = 30;
    static public const FtoQ:Number = 1 / QtoF;
    static public const SCALE_MAP:Number = 1/5;
    static public const SCALE_DIRT:Number = 1/10;
    static public const SIZE_QBOX:Rectangle = new Rectangle(-100, -100, 200, 200);
    static public function QtoM(num:Number):Number { return (num + SIZE_QBOX.width / 2) * QtoF * SCALE_MAP; }
}

class Draw {
    static public function circle(x:Number, y:Number, width:Number, height:Number, rgbs:Array, alphas:Array, ratios:Array):Sprite {
        var sp:Sprite = new Sprite();
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(width*2, height*2, 0, x - width, y - height);
        sp.graphics.beginGradientFill(GradientType.RADIAL, rgbs, alphas, ratios, mtx);
        sp.graphics.drawEllipse(x - width, y - height, width * 2, height * 2);
        return sp;
    }
    static public function box(x:Number, y:Number, width:Number, height:Number, rgb:uint):Sprite {
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(rgb);
        sp.graphics.drawRect(x, y, width, height);
        return sp;
    }
    static public function spriteBmp(bmd:BitmapData, scale:Number = 1, x:Number = 0, y:Number = 0):Sprite {
        var sp:Sprite = new Sprite();
        sp.addChild(bitmap.apply(null, arguments));
        return sp;
    }
    static public function bitmap(bmd:BitmapData, scale:Number = 1, x:Number = 0, y:Number = 0):Bitmap {
        var bmp:Bitmap = new Bitmap(bmd);
        bmp.scaleX = bmp.scaleY = scale;
        bmp.x = x * scale;
        bmp.y = y * scale;
        return bmp;
    }
}

class Dot {
    static public var tree:BitmapData = image([5, 9, "01110,11222,12233,22332,23434,04440,00500,00500,00500", [0x70E000, 0x40B913, 0x009933, 0x506418, 0xCC6600]]);
    static public var car1:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0xFF9900, 0xFFFF00, 0x333333]]);
    static public var car2:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0x0052EA, 0x00B0EA, 0x333333]]);
    static public var car3:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0x6D0402, 0xED0B0B, 0x333333]]);
    static public var car4:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0xCFDDEC, 0xECF1F7, 0x333333]]);
    static public var drum:BitmapData = image([6, 8, "011110,211112,322221,334111,134112,344221,334111,034110", [0x5A7A85, 0x415C5D, 0x91B7CC, 0x7497A6]]);
    static public var cone:BitmapData = image([5, 7, "00300,00100,03340,01120,03440,31224,33444", [0xFFFF00, 0xCC9900, 0xFF3333, 0x990000]]);
    static public var startingLine:BitmapData = image([14, 4, "11111111111111,01010101010101,10101010101010,11111111111111", [0xFFFFFF]]);
    static public var ps:BitmapData = image([8, 8, "3111111032222222321112233212121332111133321233133213313302333333", [0x6DC8F0, 0x2075B9, 0x054680]]);
    static public var fl:BitmapData = image([8, 8, "41111110,42222222,42111213,42122213,42111313,42123313,42133313,02333333", [0xF59234, 0xD42F40, 0x9E222D, 0x801220]]);
    static public function image(data:Array):BitmapData {
        var bmd:BitmapData = new BitmapData(data[0], data[1], true, 0);
        var list:Array = String(data[2]).replace(/,/g, "").split("");
        for (var i:int = 0; i < list.length; i++) bmd.setPixel32(i % bmd.width, int(i / bmd.width), (list[i]=="0")? 0 : 0xFF << 24 | data[3][int(list[i]) - 1]);
        return bmd;
    }
}

class Car {
    public var qobject:QuickObject;
    public var sprite:Sprite;
    public var mark:Sprite;
    //自動操縦
    public var isCPU:Boolean = true;
    //加速スピード
    public var accel:Number = 7.5;
    //大きいほど自動操縦時にカーブを早めに曲がる（0～1）
    public var proactiveRate:Number = 1;
    public var speedRate:Number = 0;
    public var dirtRate:Number = 0;
    public var lap:Number = 0;
    public var rank:int = 0;
    public var speed:Number = 0;
    
    private var _lastRotation:Number = 0;
    private var _loop:int = 0;
    private var _front:Point = new Point();
    private var _targetIndex:int = 1;
    private var _slip:Number = 0;
    private var _stress:int = 0;
    private var _backMode:Boolean = false;
    public function Car(sim:QuickBox2D, isCPU:Boolean = true, rgb:uint = 0xC80000, density:Number = 0.3) {
        this.isCPU = isCPU;
        qobject = sim.addBox( { density:density, restitution:[0, 0.8][int(isCPU)], friction:0.01, fillColor:rgb, x:0, y:0, width:0.6, height:1.2 } );
        sprite = qobject.userData;
        mark = Draw.box( -2, -2, 4, 4, rgb);
        Style.LABEL_TEXT = 0xFFFFFF;
    }
    public function setStartPosition(x:Number, y:Number, index:int = 1):void {
        qobject.x = x;
        qobject.y = y;
        qobject.angle = Math.atan2(y, x) + Math.PI;
        _targetIndex = index;
                _lastRotation = (Math.atan2(qobject.y, qobject.x) / Math.PI * 180 + 360) % 360;
    }
    public function getAutoKey(w:World):uint {
        var key:uint = 0xF0000;
        var p:Point = new Point(qobject.x, qobject.y), cp:Point = w.course[_targetIndex], ofp:Point = cp.subtract(p);
        var d:Number = Point.distance(p, cp);
        if (d < 10 + speed / 10 * proactiveRate || (cp.x * p.y) - (cp.y * p.x)>0) _targetIndex = ++_targetIndex % w.course.length;
        if (Math.acos((ofp.x * _front.x + ofp.y * _front.y) / (ofp.length * _front.length)) > 0.12) {
            key |= (ofp.x * _front.y - ofp.y * _front.x > 0)? 0x00F00 : 0x000F0;
        }
        if (!_backMode && speed < 2 && ++_stress > 80) _backMode = true;
        else if (_backMode && --_stress <= 0) _backMode = false;
        if (_backMode) key ^= 0xFFFF0;
        if (speed > 7 && w.tightness[_targetIndex] > 1 && d < 20) key |= 0x0000F;
        return key;
    }
    public function update(w:World):void {
        var rotation:Number = (Math.atan2(qobject.y, qobject.x) / Math.PI * 180 + 360) % 360;
        if (_lastRotation - rotation > 180) _loop++;
        else if (_lastRotation - rotation < -180) _loop--;
        _lastRotation = rotation;
        lap = (_loop * 360 + rotation - w.startRotation) / 360;
        
        qobject.angle = qobject.angle % (Math.PI * 2);
        var key:uint = (isCPU)? getAutoKey(w) : w.key;
        _front.x = Math.cos(qobject.angle - Math.PI / 2);
        _front.y = Math.sin(qobject.angle - Math.PI / 2);
        var fv0:Point = _front.clone(), fv:Point = _front.clone(), vec:b2Vec2 = qobject.body.GetLinearVelocity();
        speed = vec.x * fv0.x + vec.y * fv0.y;
        fv.normalize(speed);
        speedRate = Math.max(0, Math.min(1, vec.Length()/12));
        dirtRate = 1 - (w.dirtMap.getPixel($.QtoM(qobject.x), $.QtoM(qobject.y)) & 0xFF) / 0xFF;
        var friction:Number = ((key & 0x0000F)? 0.96 : 0.996) * (1 - dirtRate * 0.025);
        _slip += (Math.min(0.99, Math.abs(qobject.body.GetAngularVelocity()) / 3 * speedRate * 2) - _slip)*0.13;
        vec.x = (vec.x * _slip + fv.x * (1-_slip)) * friction;
        vec.y = (vec.y * _slip + fv.y * (1-_slip)) * friction;
        qobject.body.SetAngularVelocity(qobject.body.GetAngularVelocity() * 0.8);
        qobject.body.SetLinearVelocity(vec);
        fv0.normalize(qobject.body.GetMass() * accel * int(! !(key & 0xF0000)) - qobject.body.GetMass() * accel / 2 * int(! !(key & 0x0F000)));
        qobject.body.ApplyForce(new b2Vec2(fv0.x, fv0.y) , qobject.body.GetPosition());
        var t:Number = 10 * (int(!!(key & 0x000F0)) - int(!!(key & 0x00F00))) * (int(speed > 0) * 2 - 1);
        qobject.body.ApplyTorque(qobject.params.density * vec.Length() / (20 + speedRate*50) * t);
    }
}