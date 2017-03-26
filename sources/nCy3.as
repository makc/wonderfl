package {
    import alternativ7.engine3d.containers.KDContainer;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.core.View;
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    /**
     * ...
     * @author AtuyL
     */
    [SWF(width=465,height=465,backgroundColor=0xFFFFFF,frameRate=60)]
    public class Main extends Sprite{
        private var camera:Camera3D;
        private var world:Object3DContainer;
        private var physics:Alternativa3DPhysics;
        public function Main():void{
            super();
            
            world = new KDContainer();
            camera = new Camera3D();
            camera.view = new View(0,0);
            world.addChild(camera);
            addChild(camera.view);
            
            
            if(this.stage){
                onAddedToStage();
            }else{
                addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
            }
        }
        
        // asset image の読み込み
        private var preloaded:Boolean = false;
        private function preload():void{
            var target:Main = this;
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(event:Event):void{
                event.currentTarget.removeEventListener(event.type,arguments.callee);
                var bitmapData:BitmapData = Bitmap(loader.content).bitmapData;
                IkasamaRoll.TEXTURE = bitmapData
                CreatedBy.TEXTURE = bitmapData;
                preloaded = true;
                onAddedToStage();
            });
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/6/62/621e/621e05886fa5bbd91e3b1eeea31666e6fdab803c"),new LoaderContext(true));
        }
        
        private function onAddedToStage(event:Event = null):void{
            if(event != null) event.currentTarget.removeEventListener(event.type,arguments.callee);
            if(!preloaded){
                preload();
                return;
            }
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            physics = new Alternativa3DPhysics(world,stage.frameRate);
            
            setup();
            
            DiceRoll.init(stage,physics);
            
            new PushButton(this,0,0,"CREATED BY",onClick);
            stage.addEventListener(MouseEvent.CLICK,onClick);
            onClick();
            
            stage.addEventListener(Event.RESIZE,onResize);
            onResize();
            stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
            onEnterFrame();
        }
        
        private var diceroll:DiceRoll;
        private function setup():void{
            camera.z = -500;
            camera.y = -200;
            camera.rotationX = Math.PI / -4;
            camera.rotationX = Math.PI / -4;
        }
        
        private var currentWalls:Vector.<Wall>;
        private function onClick(event:MouseEvent = null):void{
            if(diceroll != null){
                diceroll.dispose();
            }
            
            if(currentWalls != null){
                currentWalls.forEach(function(value:Wall,index:int,array:Vector.<Wall>):void{
                    physics.removeBody(value);
                });
            }
            if(event == null || event.currentTarget == stage){
                //trace("IkasamaRoll");
                currentWalls = InvertBoxFactory.create(500,false);
                currentWalls.forEach(function(value:Wall,index:int,array:Vector.<Wall>):void{
                    physics.addBody(value);
                });
                diceroll = new IkasamaRoll();
            }else{
                //trace("CreatedBy");
                currentWalls = InvertBoxFactory.create(600,false);
                currentWalls.forEach(function(value:Wall,index:int,array:Vector.<Wall>):void{
                    physics.addBody(value);
                });
                diceroll = new CreatedBy();
                event.stopPropagation();
            }
        }
        
        private function onResize(event:Event = null):void{
            camera.view.width = stage.stageWidth;
            camera.view.height = stage.stageHeight;
        }
        
        private var logview:Bitmap;
        private function onEnterFrame(event:Event = null):void{
            if(diceroll != null) diceroll.step();
            camera.render();
        }
    }
}

import alternativ7.engine3d.core.Face;
import alternativ7.engine3d.core.MipMapping;
import alternativ7.engine3d.core.Object3D;
import alternativ7.engine3d.core.Object3DContainer;
import alternativ7.engine3d.materials.Material;
import alternativ7.engine3d.materials.TextureMaterial;
import alternativ7.engine3d.primitives.Box;
import alternativ7.engine3d.primitives.Plane;
import flash.display.BitmapData;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import jiglib.geometry.JBox;
import jiglib.geometry.JPlane;
import jiglib.physics.PhysicsState;
import jiglib.physics.RigidBody;
import jiglib.plugin.AbstractPhysics;
import jiglib.plugin.ISkin3D;

class DiceRoll{
    static public var stage:Stage;
    static public var physics:Alternativa3DPhysics;
    static public function init(stage:Stage,physics:Alternativa3DPhysics):void{
        DiceRoll.stage = stage;
        DiceRoll.physics = physics;
    }
    
    public var dices:Vector.<Dice>;
    public function DiceRoll(){
        calc();
    }
    
    protected function createDices():Vector.<Dice>{
        return new Vector.<Dice>();
    }
    
    public function calc():void{
        this.dices = createDices();
        
        const NUM_DICES:int = dices.length;
        if(NUM_DICES <= 0) return;
        
        var i:int,dice:Dice;
        
        for(i = 0;i < NUM_DICES;i++){
            physics.addBody(dices[i]);
        }
        
        var frameCount:int = 0;
        var frameRate:int = stage.frameRate;
        var freezeCount:int = 0;
        while(freezeCount < 30){
            var sec:int = (frameCount / frameRate) >> 0;
            
            physics.integrate(1 / frameRate);
            var isFreezed:Boolean = true;
            for(i = 0;i < dices.length;i++){
                dice = dices[i];
                dice.pushLog();
                
                if(!dice.movable && i <= sec){
                    dice.movable = true;
                }
                
                if(!dice.movable || !dice.isFreezed){
                    isFreezed = false;
                }
            }
            frameCount++;
            
            // 30秒以上かかるようなら再計算
            if(frameCount > frameRate * 30){
                dispose();
                calc();
                return;
            }
            
            if(isFreezed){
                freezeCount += 1;
            }else{
                freezeCount = 0;
            }
        }
        
        for(i = 0;i < dices.length;i++){
            dice = dices[i];
            dice.fix();
        }
        
        onFixed();
        
        this.isFreezed = true;
    }
    
    protected function onFixed():void{}
    
    private var isFreezed:Boolean;
    public function step():void{
        if(isFreezed){
            for(var i:int = 0;i < dices.length;i++){
                dices[i].step();
            }
        }
    }
    
    public function dispose():void{
        physics.afterPause();
        for(var i:int = 0;i < dices.length;i++){
            physics.removeBody(dices[i]);
        }
    }
}

class IkasamaRoll extends DiceRoll{
    public static var TEXTURE:BitmapData;
    
    public function IkasamaRoll(){
        super();
    }
    override protected function createDices():Vector.<Dice>{
        const NUM_DICES:int = 3;
        
        var dices:Vector.<Dice> = new Vector.<Dice>(NUM_DICES);
        for(var i:int = 0;i < NUM_DICES;i++){
            var dice:Dice = new Dice();
            dice.x = NUM_DICES > 1 ? (i / (NUM_DICES - 1) - 0.5) * 2.0 * 200 : 0;
            dice.z = NUM_DICES > 1 ? (Math.random() - 0.5) * 2.0 * 200 : 0;
            dice.y = -1000;
            dice.rotationX = Math.random() * 90;
            dice.rotationY = Math.random() * 90;
            dice.rotationZ = Math.random() * 90;
            dice.movable = false;
            dices[i] = dice;
        }
        
        return dices;
    }
    
    override protected function onFixed():void{
        super.onFixed();
        
        var i:int;
        
        var textures:Vector.<TextureMaterial> = new Vector.<TextureMaterial>();
        var sourceRect:Rectangle = new Rectangle(0,0,64,64);
        var destPoint:Point = new Point();
        for(i = 0; i < 6;i++){
            sourceRect.x = i * sourceRect.width;
            var tex:BitmapData = new BitmapData(sourceRect.width,sourceRect.height,false,0x0);
            tex.copyPixels(TEXTURE,sourceRect,destPoint);
            textures.push(new TextureMaterial(tex,false,true,MipMapping.NONE));
        }
        
        var diceTextures:Vector.<TextureMaterial> = new Vector.<TextureMaterial>(6);
        diceTextures[0] = textures[0];
        diceTextures[1] = textures[5];
        diceTextures[2] = textures[1];
        diceTextures[3] = textures[4];
        diceTextures[4] = textures[2];
        diceTextures[5] = textures[3];
        
        const NUM_DICES:int = dices.length;
        for(i = 0;i < NUM_DICES;i++){
            dices[i].setTextures(diceTextures);
            diceTextures.push(diceTextures.shift());
            diceTextures.push(diceTextures.shift());
        }
    }
}

class CreatedBy extends DiceRoll{
    public static var TEXTURE:BitmapData;
    
    public function CreatedBy(){
        super();
    }
    
    override protected function createDices():Vector.<Dice>{
        const NUM_DICES:int = 6;
        
        var dices:Vector.<Dice> = new Vector.<Dice>(NUM_DICES);
        for(var i:int = 0;i < NUM_DICES;i++){
            var dice:Dice = new Dice();
            dice.x = NUM_DICES > 1 ? (i / (NUM_DICES - 1) - 0.5) * 2.0 * 200 : 0;
            dice.z = NUM_DICES > 1 ? (Math.random() - 0.5) * 2.0 * 200 : 0;
            dice.y = -1000;
            dice.rotationX = Math.random() * 90;
            dice.rotationY = Math.random() * 90;
            dice.rotationZ = Math.random() * 90;
            dice.movable = false;
            dices[i] = dice;
        }
        
        return dices;
    }
    
    override protected function onFixed():void{
        super.onFixed();
        
        var i:int;
        
        var textures:Vector.<TextureMaterial> = new Vector.<TextureMaterial>();
        var sourceRect:Rectangle = new Rectangle(0,0,64,64);
        
        var matrix:Matrix = new Matrix();
        matrix.scale(1,-1);
        matrix.translate(0,sourceRect.height);
        
        var destPoint:Point = new Point();
        for(i = 0; i < 6;i++){
            sourceRect.x = i * sourceRect.width;
            sourceRect.y = 64;
            var clipped:BitmapData = new BitmapData(sourceRect.width,sourceRect.height,false,0x0);
            clipped.copyPixels(TEXTURE,sourceRect,destPoint);
            var tex:BitmapData = new BitmapData(sourceRect.width,sourceRect.height,false,0x0);
            tex.draw(clipped,matrix);
            textures.push(new TextureMaterial(tex,false,true,MipMapping.NONE));
        }
        textures.push(textures.shift());
        textures.push(textures.shift());
        textures.push(textures.shift());
        
        const NUM_DICES:int = dices.length;
        
        // 左から扇状に判定
        dices.sort(function(a:Dice,b:Dice):int{
            return a.dot.x <= b.dot.x ? -1 : 1;
        });
        
        for(i = 0;i < NUM_DICES;i++){
            dices[i].setTextures(textures);
            textures.push(textures.shift());
        }
    }
}

interface IRigidObject3D extends ISkin3D{
    function get object3d():Object3D;
}

class Dice extends JBox implements IRigidObject3D{
    private var _object3d:Object3D;
    private var box:Box;
    public function Dice(){
        const SIZE:Number = 100;
        
        box = new Box(SIZE,SIZE,SIZE);
        
        var container:Object3DContainer = new Object3DContainer();
        container.addChild(box);
        super(this, SIZE, SIZE, SIZE);
        
        this.restitution = 10;
        
        _object3d = container;
        log = new Vector.<Matrix3D>();
    }
    
    public function setTextures(textures:Vector.<TextureMaterial>):void{
        var faces:Vector.<Face> = box.faces;
        faces[0].material = textures[0];//right
        faces[1].material = textures[1];//left
        faces[2].material = textures[2];//bottom
        faces[3].material = textures[3];//top
        faces[4].material = textures[4];//back
        faces[5].material = textures[5];//front
    }
    
    public var dot:Vector3D;
    public function fix():void{
        var transform:Matrix3D = this.transform;
        var position:Vector3D = transform.position;
        transform.position = new Vector3D();
        transform = Matrix3DModifier.snapMatrix(transform);
        
        /**
         * Alternativa3Dは整数Matrixが認められていない(？)為、値をわずかに揺らす
         * (Away3D等では整数Matrixのままでいけた)
         */
        transform = Matrix3D.interpolate(new Matrix3D(),transform,0.9999999);
        
        transform.transpose();
        this.box.matrix = transform;
        
        position.z += 1000;
        position.normalize();
        dot = new Vector3D();
        dot.x = position.dotProduct(Vector3D.X_AXIS);
        dot.y = position.dotProduct(Vector3D.Y_AXIS);
        dot.z = position.dotProduct(Vector3D.Z_AXIS);
    }
    
    private var log:Vector.<Matrix3D>;
    public function pushLog():void{
        log.push(transform);
    }
    public function step():void{
        if(log.length > 0) transform = log.shift();
    }
    
    private var freezeCount:int;
    public function get isFreezed():Boolean{
        const currentState:PhysicsState = this.currentState;
        const oldState:PhysicsState = this.oldState;
        
        var dot:Number = currentState.linVelocity.dotProduct(oldState.linVelocity);
        var distance:Number = Vector3D.distance(currentState.position,oldState.position);
        
        return distance < 0.001 && dot < 0.001;
    }
    
    /**
     * Alternativa3Dは左手系。
     * 対してjiglibは右手系なので変換を行う。
     */
    public function get transform():Matrix3D{
        var matrix:Matrix3D = this._object3d.matrix.clone();
        matrix.appendScale(1.0,1.0,-1.0);
        return matrix;
    }
    public function set transform(m:Matrix3D):void{
        var matrix:Matrix3D = m.clone();
        matrix.appendScale(1.0,1.0,-1.0);
        this._object3d.matrix = matrix;
    }
    
    public function get object3d():Object3D{
        return _object3d;
    }
}

class Wall extends JPlane implements IRigidObject3D{
    private var _object3d:Object3D;
    public function Wall(width:Number = 1000, length:Number = 1000, widthSegments:uint = 1, lengthSegments:uint = 1, twoSided:Boolean = true, reverse:Boolean = false, triangulate:Boolean = false, bottom:Material = null, top:Material = null){
        var plane:Plane = new Plane(width, length, widthSegments, lengthSegments, twoSided, reverse, triangulate, bottom, top);
        //plane.setMaterialToAllFaces(new FillMaterial(0xFF9900,0.5,1,0xFFFF9900));
        
        super(this, new Vector3D(0, 0, 1));
        movable = false;
        
        _object3d = plane;
    }
    
    public function get transform():Matrix3D{
        return this._object3d.matrix;
    }
    
    public function set transform(m:Matrix3D):void{
        this._object3d.matrix = m.clone();
    }
    
    public function get object3d():Object3D{
        return _object3d;
    }
}

class InvertBoxFactory{
    static public function create(size:Number,useCap:Boolean):Vector.<Wall>{
        var ret:Vector.<Wall> = new Vector.<Wall>();
        var half:Number = size / 2;
        
        var wall:Wall;
        
        wall = new Wall(size,size);
        wall.rotationX = 90;
        wall.y = half;
        ret.push(wall);
        
        if(useCap){
            wall = new Wall(size,size);
            wall.rotationX = -90;
            wall.y = -half;
            ret.push(wall);
        }
        
        wall = new Wall(size,size);
        wall.rotationY = 180;
        wall.z = half;
        ret.push(wall);
        
        wall = new Wall(size,size);
        wall.rotationY = 0;
        wall.z = -half;
        ret.push(wall);
        
        wall = new Wall(size,size);
        wall.rotationY = 90;
        wall.x = -half;
        ret.push(wall);
        
        wall = new Wall(size,size);
        wall.rotationY = -90;
        wall.x = half;
        ret.push(wall);
        
        return ret;
    }
}

class Alternativa3DPhysics extends AbstractPhysics{
    private var speed:Number;
    private var world:Object3DContainer;
    public function Alternativa3DPhysics(world:Object3DContainer,speed:Number = 60.0){
        super(this.speed = speed);
        this.engine.setGravity(Vector3D.Y_AXIS);
        this.world = world;
    }
    
    override public function addBody(body:RigidBody):void{
        super.addBody(body);
        if(body is IRigidObject3D){
            this.world.addChild(IRigidObject3D(body).object3d);
        }
    }
    
    override public function removeBody(body:RigidBody):void{
        super.removeBody(body);
        if(body is IRigidObject3D){
            this.world.removeChild(IRigidObject3D(body).object3d);
        }
    }
    
    public function integrate(deltaTime:Number):void{
        this.engine.integrate(deltaTime * this.speed);
    }
}

class Matrix3DModifier{
    /**
     * 対象のMatrixを最寄りのXYZ軸にスナップさせたMatrix3Dを返す
     * @param    target    対象となるMatrix3D
     * @return    ワールド軸にスナップされたMatrix3D
     */
    static public function snapMatrix(target:Matrix3D):Matrix3D{
        var rawData:Vector.<Number> = target.rawData;
        
        // 0 , 1 , 2 , 3
        // 4 , 5 , 6 , 7
        // 8 , 9 ,10 ,11
        // 12,13 ,14 ,15
        var vectors:Vector.<Vector3D> = Vector.<Vector3D>([
            new Vector3D(rawData[0],rawData[1],rawData[2]),
            new Vector3D(rawData[4],rawData[5],rawData[6]),
            new Vector3D(rawData[8],rawData[9],rawData[10])
        ]);
        
        vectors = snapVectors(vectors);
        
        var ret:Matrix3D = new Matrix3D();
        rawData = ret.rawData;
        rawData[0] = vectors[0].x;
        rawData[1] = vectors[0].y;
        rawData[2] = vectors[0].z;
        rawData[4] = vectors[1].x;
        rawData[5] = vectors[1].y;
        rawData[6] = vectors[1].z;
        rawData[8] = vectors[2].x;
        rawData[9] = vectors[2].y;
        rawData[10] = vectors[2].z;
        ret.rawData = rawData;
        return ret;
    }
    
    /**
     * スナップに用いる正負のワールド軸定数
     */
    static private const X_AXIS:Vector3D = Vector3D.X_AXIS.clone();
    static private const X_AXIS_R:Vector3D = Vector3D.X_AXIS.clone();
    static private const Y_AXIS:Vector3D = Vector3D.Y_AXIS.clone();
    static private const Y_AXIS_R:Vector3D = Vector3D.Y_AXIS.clone();
    static private const Z_AXIS:Vector3D = Vector3D.Z_AXIS.clone();
    static private const Z_AXIS_R:Vector3D = Vector3D.Z_AXIS.clone();
    {
        X_AXIS_R.scaleBy(-1);
        Y_AXIS_R.scaleBy(-1);
        Z_AXIS_R.scaleBy(-1);
    }
    
    /**
     * 対象のVector3Dに最も近いVector3Dのインデックスを返す
     * @param    target    対象となるVector3D
     * @param    vectors    スナップ対象が格納された配列。nullの場合は正負両方のXYZ軸を対象とする。
     * @return    スナップ対象の何番目が選ばれたか
     */
    static public function snapVector(target:Vector3D,vectors:Vector.<Vector3D> = null):int{
        if(vectors == null){
            vectors = Vector.<Vector3D>([
                X_AXIS,X_AXIS_R,
                Y_AXIS,Y_AXIS_R,
                Z_AXIS,Z_AXIS_R
            ]);
        }
        
        var betweens:Vector.<Number> = new Vector.<Number>(vectors.length);
        vectors.forEach(function(value:Vector3D,index:int,array:Vector.<Vector3D>):void{
            betweens[index] = Vector3D.angleBetween(target,value)
        });
        var min:Number = Infinity;
        var ret:int = 0;
        betweens.forEach(function(value:Number,index:int,array:Vector.<Number>):void{
            if(value < min){
                min = value;
                ret = index;
            }
        });
        return ret;
    }
    
    /**
     * targetsに格納された各Vector3Dをワールド軸にスナップさせた配列を返す
     * @param    targets    対象となるVector3D配列
     * @return    第一引数に1:1で対応したVector3D配列
     */
    static public function snapVectors(targets:Vector.<Vector3D>):Vector.<Vector3D>{
        var vectors:Vector.<Vector3D> = Vector.<Vector3D>([
            X_AXIS,X_AXIS_R,
            Y_AXIS,Y_AXIS_R,
            Z_AXIS,Z_AXIS_R
        ]);
        var ret:Vector.<Vector3D> = new Vector.<Vector3D>(targets.length);
        targets.forEach(function(value:Vector3D,index:int,array:Vector.<Vector3D>):void{
            var snapIndex:int = snapVector(value,vectors);
            ret[index] = vectors[snapIndex].clone();
            var evenIndex:int = snapIndex % 2 ? snapIndex - 1 : snapIndex;
            vectors.splice(evenIndex,2);
        });
        return ret;
    }
}