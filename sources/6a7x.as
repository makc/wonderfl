// Droid Invasion!
// Minimal 2d stage3d accelerated animation sprite engine
// based on work from Christer Kaitila/Chris Nuuja/Philippe Elsass/Iain Lobb - thx to all of them!
// Pushing @60fps over 500 64*64 animated sprites on Sony Xperia pro mini @1ghz Scorpion/Adreno 205/Android 2.3
// @Hasufel 2012 (2012-06-01 02:07:41)
// recompiled to get through wonderfl compiled code cache loss

package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.display3D.*;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import net.hires.debug.Stats;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
        
    public class DroidInvasion extends Sprite {
        private var _stageW:uint = stage.stageWidth;
        private var _stageH:uint = stage.stageHeight;
        private var _stageRect:Rectangle = new Rectangle(0,0,_stageW,_stageH);
        private const _textureb64:String = "iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAMAAADDpiTIAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ"+
"bWFnZVJlYWR5ccllPAAAAK5QTFRFACExhCkAAAgQAGN7AJS11mMACL3nAAAAAEJSKSlCezkh/9Zz"+
"CAgQSkJrOUJKAKXGIRAIvVo5/6Ux/4QAc3N7UikQtbW9GBgplO//7+/3zhgYpTEASs7vQkJr//f/"+
"QhgI50pKKWNzpZy9/wAA////KYSlEAgAa2OE75SU/3sx/61SOTlKzkoh/4SEQkJK/zEA94xC94SE"+
"/3t7nJS9UlJSxkP9Y1qEMTFK2OjQ////qvDC2gAAADp0Uk5T////////////////////////////"+
"////////////////////////////////////////////////ADfA/woAADJnSURBVHja7F0JY+M2"+
"rqZPWoqcyEmUZI6ONzMZt00yx77uO/z//9gjQOryJRKwLSkB2t120nwQAXwEQeqAWou8a1HiAiGA"+
"iBBARAggIgQQEQKICAFEhAAdk/t3HqT73hOAZ8H9f933nEAdtl+dw4NEC24mk8EA4N9aduBbtl+d"+
"zoB8/FQLbr5c3FxfD8j+L67PdeCbtl+dzIBy/DQLDN7Ab8gOqFyf6cA3bb86lQGV8VMdMLieDEwQ"+
"2P5jO/At269OZUBl/Ot7An7y5WZyY6Yg3QGV66/PH8C+2K9OZEB1/CQDJhfXgL+5uVlPJpPzX/+9"+
"2K9OZIAbP9mAgbP/i0nEgy+Dybmv/27sV6cxwI1/TTZgYC//5cKIUXAxOfP134396jQG2PGvyQas"+
"Bwa/HgwAfjG4vg52APP678d+dSIHwvgZBgDWRAHxphS7Pvf134/96kQGwA6aYUA+DWEmDlDOe/33"+
"Y7/qqAEWfg1IU4mbAQx6RaD+2K+6awBe2wzB4Cc314N+Eag39quOGnBv/Y+Xh+34Tf8I1A/7VccM"+
"uHfy572bgIDPD2R6RKDe2K+6ZYAB5mKUGP8PJjgFvXNw2wTqnf2qUwbcfwWZfLVyb2owU4jfDPpD"+
"oP7Zr7pkwP39H0YmXyZ/oNzj5V0Vtu4DgXpov+qSAQ5/gfgJ+v0Gbsl45+2WCdRH+1WXDLAZeHAx"+
"uTfgiwv0/+Bm4r0Ha5tAfbRfndyAwE304Ab2XHD+cpNXYQH4Xdc/H4G412/DfnXiAE4GF4GnKIOa"+
"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"+
"IYAIR/5fgAEAqY+r9KOk16wAAAAASUVORK5CYII=";

        private var _textureBgb64:String = "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"+
"f0p4kkPy0OXlzYLz9gVktw+sL083eRIBLucNnmbXezoveLlZ8LK8g1ntA+vL002eKHm8QuDLdUHt"+
"v6v20fvL97//9KLw6+r3pNFPvy6+Lt9fXrXZXp5u80QvXlxdvSjm6urq/ftfl7x/3257ebrNMxPg"+
"aSlJxbTgVbvt5ek2T/S0EmuLquTdp7083eapKAC+VwhAgCA2zjgbpW5ZefbMEyrAeUqzHaxbVp49"+
"80RPwjjf+aYZzvf9PXnq5YnOcasxCTQJBAFAABAABAABcMsEeBL+VfxwnYr7fclTP09Up+I+3W/j"+
"S576eaInuNUQgAAgAAgAAoAAIAAIAAKAACAAboEAd8O/ih+uU3G/L3nq54nqVNyn+218yVM/jyOA"+
"I4BXnCOAV9wtPgLgVkMAAoAAIAAIAAKAACAAbpEAz3Cr8SFRt/1DopZHgvO7CyGSbxqlbl15OsqT"+
"CpDScAdr1pWnozwmgc4CQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAAB"+
"QAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFA"+
"ABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABUEmAZ7jVROe41azeAs7vLoRIvmmUunXl6ShPKkBK"+
"wx2sWVeejvKYBDoLAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFA"+
"ABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAA"+
"EAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAEIAAKAACAACAAC"+
"gAAgAAgAAoAAIAAIAAKAACAACAACgAAgAAiAv70Az3Cric5xq1m9BZzfXQiRfNModevK01GeVICU"+
"hjtYs648HeUxCXQWAAKAACAACAACgAAgAAgAAoAAIAAIAAKAACAACAACgAAgAAgAAoAAIAAIAAKA"+
"ACAACAACgAAgAAgAAoAAIAAIAAKAACAACAACgAAgAAgAAoAAIAAIAAKAACAACAACgAAgAAgAAoAA"+
"IAAIAAKAACAACAACgAAgAAgAAoAAIAAIAAKAACAACAACgAAgAAgAAoAAIAAIAAIQAAQAAUAAEAAE"+
"AAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEwN9DgGe41UTnuNWs3gLO"+
"7y6ESL5plLp15ekoTypASsMdrFlXno7ymAQ6CwABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQA"+
"AUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAABAABQAAQAAQAAUAAEAAEAAFAABAAHfN/"+
"AQYA2Rwh7+QTsRcAAAAASUVORK5CYII=";
        private var _loader:Loader;
        private var _entities:EntityManager;
        private var _spriteStage:LiteSpriteStage;
        private var _bg:GameBackground;
        private var _context3D:Context3D;
        private var _textureDroids:BitmapData;
        private var _textureBg:BitmapData;
        //private var sc:BitmapData　=　new BitmapData(465,　465,　false);

        public function DroidInvasion():void {
            //Wonderfl.disable_capture();
            //addChild(new Bitmap(sc));
            stage?init():addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            setProps(stage, {quality:StageQuality.LOW, scaleMode:StageScaleMode.NO_SCALE, align:StageAlign.TOP_LEFT, stageFocusRect:false, tabChildren:false});
            stage.addEventListener(Event.RESIZE, onResizeEvent);
            loadTexture(_textureb64,saveDroids);
        }

        private function loadTexture(t:String,f:Function):void {
            var b:ByteArray = Base64.decode(t);
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,f);
            _loader.loadBytes(b);   
        }

        private function saveDroids(e:Event):void {
            _textureDroids = new BitmapData(_loader.content.width,_loader.content.height,true,0x00FFFFFF);
            _textureDroids.draw(_loader.content);
            loadTexture(_textureBgb64,saveBg);
        }

        private function saveBg(e:Event):void {
            _textureBg = new BitmapData(_loader.content.width,_loader.content.height,true,0x00FFFFFF);
            _textureBg.draw(_loader.content);
            _loader = null;
            initContext3D();
        }

        private function initContext3D():void {
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, errorHandler);
            stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
        }    

        private function onContext3DCreate(e:Event):void {
            _context3D = stage.stage3Ds[0].context3D;
            initSpriteEngine();
        }
        
        private function errorHandler(e:ErrorEvent):void {
            trace("Error while setting up Stage3D: "+e.errorID+" - " +e.text);
        }

        protected function onResizeEvent(event:Event):void {
            _stageW = stage.stageWidth;
            _stageH = stage.stageHeight;
            _stageRect = new Rectangle(0,0,_stageW,_stageH);
            if (_spriteStage != null ) _spriteStage.position = _stageRect;
            if(_entities != null) _entities.setPosition(_stageRect);
        }
        
        private function initSpriteEngine():void {
            var stats:Stats = new Stats();
            addChild(stats);

            _spriteStage = new LiteSpriteStage(stage.stage3Ds[0], _context3D, _stageRect);
            _spriteStage.configureBackBuffer(_stageW,_stageH);

               _bg = new GameBackground(_stageRect,_textureBg);
            _bg.createBatch(_context3D);
            _spriteStage.addBatch(_bg.batch);
               _bg.initBackground();
            
            _entities = new EntityManager(_stageRect,_textureDroids);
            _entities.createBatch(_context3D);
            _spriteStage.addBatch(_entities.batch);
            for (var i:uint = 0;i<400;++i) {
                if (Math.random()*10>6) {
                    if (Math.random()*10>1) {
                        if (Math.random()*10>9){
                            _entities.addEntity(42+(Math.random()*8)>>0,(Math.random()*_stageW)>>0,((i*.9)>>0)+80,3,0,0,true,3,42,13);
                        }
                        else {
                        _entities.addEntity(16+(Math.random()*8)>>0,(Math.random()*_stageW)>>0,((i*.9)>>0)+80 ,-.4,0,0,true,6,16,13);
                        }
                    }
                    else {
                        _entities.addEntity(32+(Math.random()*6)>>0,(Math.random()*_stageW)>>0,((i*.9)>>0)+80 ,-1,0,0,true,3,32,5);
                    }
                }
                else {
                    _entities.addEntity((Math.random()*8)>>0,(Math.random()*_stageW)>>0,((i*.9)>>0)+80 ,-1,0,0,true,3,0,15);
                }
            }
            stage.addEventListener(Event.ENTER_FRAME,gameEnterFrame);
        }
        
        private function gameEnterFrame(e:Event):void {
            try {
                _context3D.clear(0,0,0,1);
                _entities.update();
                _spriteStage.render();
               //_context3D.drawToBitmapData(sc);
                _context3D.present();
            }
            catch (e:Error) {}
        }

        private function setProps(o:*,p:Object):void {
            for (var k:String in p) o[k]=p[k];
        }
    }
}

class Entity {
        private var _speedX:Number;
        private var _orSpeedX:Number;
        private var _speedY:Number;
        private var _orSpeedY:Number;
        private var _sprite:LiteSprite;
        private var _innerTime:uint;
        private var _animDelay:uint;
        private var _animFrames:uint;
        private var _animations:Array;
        private var _animStartFrame:uint;
        private var _anim:Boolean;
        private var _rot:Number;

        public var active:Boolean = true;
        public var aiFunction:Function = null;
        public var isBullet:Boolean = false;

        public function Entity(ls:LiteSprite = null) {
            _sprite = ls;
            _speedX = 0;
            _speedY = 0;
            _rot = 0;
            _innerTime = 0;
        }
        
        public function die():void {
            active = false;
            sprite.visible = false;
        }
        
        public function get animations():Array {
            return _animations;
        }

        public function set animations(ar:Array):void {
            _animations = ar;
        }

        public function get speedX():Number {
            return _speedX;
        }

        public function set speedX(n:Number):void {
            _speedX = n;
        }

        public function get orSpeedX():Number {
            return _orSpeedX;
        }

        public function set orSpeedX(n:Number):void {
            _orSpeedX = n;
        }

        public function get speedY():Number {
            return _speedY;
        }

        public function set speedY(n:Number):void {
            _speedY = n;
        }

        public function get orSpeedY():Number {
            return _orSpeedY;
        }

        public function set orSpeedY(n:Number):void {
            _orSpeedY = n;
        }

        public function get sprite():LiteSprite {
            return _sprite;
        }

        public function set sprite(ls:LiteSprite):void {
            _sprite = ls;
        }

        public function get innerTime():uint {
            return _innerTime;
        }

        public function set innerTime(n:uint):void {
            _innerTime = n;
        }

        public function set animDelay(n:uint):void {
            _animDelay = n;
        }

        public function get animDelay():uint {
            return _animDelay;
        }

        public function set animStartFrame(n:uint):void {
            _animStartFrame = n;
        }

        public function get animStartFrame():uint {
            return _animStartFrame;
        }

        public function set animFrames(n:uint):void {
            _animFrames = n;
        }

        public function get animFrames():uint {
            return _animFrames;
        }

        public function set anim(n:Boolean):void {
            _anim = n;
        }

        public function get anim():Boolean {
            return _anim;
        }

        public function set rot(n:Number):void {
            _rot = n;
        }

        public function get rot():Number {
            return _rot;
        }
    }

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display3D.*;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    class EntityManager {
        private const _SpritesPerRow:int = 8;
        private const _SpritesPerCol:int = 8;

        private var _texture:BitmapData;
        private var _entityPool:Vector.<Entity>;
                
        private var _maxX:int;
        private var _minX:int;
        private var _maxY:int;
        private var _minY:int;

        public var numCreated:int = 0;
        public var spriteSheet:LiteSpriteSheet;
        public var batch:LiteSpriteBatch;

        
        public function EntityManager(r:Rectangle,t:BitmapData) {
            _texture = t;
            _entityPool = new Vector.<Entity>();
            setPosition(r);
        }

        public function setPosition(r:Rectangle):void {
            _maxX = r.width + 32;
            _maxY = r.height;
            _minX = r.x - 32;
            _minY = r.y;
        }
        
        public function createBatch(context3D:Context3D):LiteSpriteBatch {
            spriteSheet = new LiteSpriteSheet(_texture, _SpritesPerRow, _SpritesPerCol);
            batch = new LiteSpriteBatch(context3D, spriteSheet);            
            return batch;
        }
        
        public function respawn(sprID:uint=0):Entity{
            var currentEntityCount:int = _entityPool.length;
            var a:Entity;
            var i:uint = 0;
            for (i = 0; i < currentEntityCount; ++i) {
                a = _entityPool[i>>0];
                if (!a.active && (a.sprite.spriteId == sprID)){
                    a.active = true;
                    a.sprite.visible = true;
                    return a;
                }
            }
            var sprite:LiteSprite;
            sprite = batch.createChild(sprID);
            a = new Entity(sprite);
            _entityPool.push(a);
            return a;
        }

        public function shootBullet(owner:Entity):Entity {
            var a:Entity;        
            a = respawn(owner.animStartFrame==0?40:41);
            a.sprite.position.x = owner.sprite.position.x;
            a.sprite.position.y = owner.sprite.position.y;
            a.speedX = -15;
            a.speedY = 0;
            a.rot = 0;
            a.isBullet = true;
            return a;
        }
         
        public function addEntity(n:uint,x:Number=0,y:Number=0,spdX:Number=0,spdY:Number=0,rot:Number=0,anim:Boolean=false,animDelay:uint=0,animStartFrame:uint=0,animFrames:uint=0):void {
            var a:Entity;
            a = respawn(n);
            a.sprite.position.x = x;
            a.sprite.position.y = y;
            a.speedX = spdX;
            a.orSpeedX = spdX;
            a.speedY = spdY;
            a.orSpeedY = spdY;
            a.rot = rot;
            a.anim = anim;
            a.animDelay = animDelay;
            a.animFrames = animFrames;
            a.animStartFrame = animStartFrame;
        }
        
        public function update():void {
            var a:Entity;
            var l:uint = _entityPool.length;
            for(var i:uint=0; i<l ; ++i){
                a = _entityPool[i>>0];
                if (a.active){
                    if (a.anim) {
                        a.innerTime++;
                        if (a.innerTime - a.animDelay == 0) {
                            a.innerTime = 0;
                            var j:uint = a.sprite._spriteId+1;
                            if (a.animStartFrame != 42) {
                                if (j==a.animStartFrame+7 && Math.random()*10>5) {j=a.animStartFrame;}
                                if (j>a.animStartFrame+7) a.speedX = 0;
                                if (j>a.animStartFrame+a.animFrames) {shootBullet(a); j=a.animStartFrame; a.speedX = a.orSpeedX;}
                            }
                            else {
                                if (j>a.animStartFrame+a.animFrames) {j=a.animStartFrame;}
                            }
                            a.sprite._spriteId = j;
                            a.sprite.changeFrame();
                        }
                    }
                
                    a.sprite.position.x += a.speedX;
                    a.sprite.position.y += a.speedY;
                    a.sprite.rotation += a.rot;
                    if (a.sprite.position.x > _maxX){
                        a.sprite.position.x = _minX;
                    }
                    if (a.sprite.position.x < _minX){
                        if (a.isBullet) {
                            a.die();
                        }
                        else {
                            a.sprite.position.x = _maxX;
                        }
                    }
                }
            }
        }
    }

    import flash.display.Bitmap;
    import flash.display3D.*;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    class GameBackground extends EntityManager {
        private const _bgSpritesPerRow:uint = 1;
        private const _bgSpritesPerCol:uint = 1;
        private var _texture:BitmapData;
        
        public function GameBackground(r:Rectangle,t:BitmapData) {
            _texture = t;
            super(r,t);
        }
        
        override public function createBatch(context3D:Context3D):LiteSpriteBatch {
            spriteSheet = new LiteSpriteSheet(_texture, _bgSpritesPerRow, _bgSpritesPerCol);
            batch = new LiteSpriteBatch(context3D, spriteSheet);
            return batch;
        }
    
        public function initBackground():void {
            var a:Entity = respawn(0);
            a = respawn(0);
            a.sprite.position.x = a.sprite.position.y = 256;
        }    
    }

    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    class LiteSprite {
        internal var _parent:LiteSpriteBatch;    
        internal var _spriteId:uint;
        internal var _childId:uint;
        private var _pos:Point;
        private var _visible:Boolean;
        private var _scaleX:Number;
        private var _scaleY:Number;
        private var _rotation:Number;
        private var _alpha:Number;

        public function LiteSprite() {
            _parent = null;
            _spriteId = 0;
            _childId = 0;
            _pos = new Point();
            _scaleX = 1;
            _scaleY = 1;
            _rotation = 0;
            _alpha = 1;
            _visible = true;
        }

        public function get visible():Boolean {
            return _visible;
        }

        public function set visible(b:Boolean):void {
            _visible = b;
        }

        public function get alpha():Number {
            return _alpha;
        }

        public function set alpha(n:Number):void {
            _alpha = n;
        }
        
        public function get position():Point {
            return _pos;
        }

           public function set position(pt:Point):void {
            _pos = pt;
        }
    
        public function get scaleX():Number {
            return _scaleX;
        }

        public function set scaleX(n:Number):void {
            _scaleX = n;
        }
   
        public function get scaleY():Number {
            return _scaleY;
        }

        public function set scaleY(n:Number):void {
            _scaleY = n;
        }

        public function get rotation():Number {
            return _rotation;
        }

        public function set rotation(n:Number):void {
            _rotation = n;    
        }

        public function get spriteId():uint {
            return _spriteId;
        }

        public function set spriteId(n:uint):void {
            _spriteId = n;
        }

        public function get childId():uint {
            return _childId;
        }

        public function get rect():Rectangle {
            return _parent._sprites.getRect(_spriteId);
        }

        public function get uvCoords():Vector.<Number> {
            return _parent._sprites.getUVCoords(_spriteId);
        }

        public function get parent():LiteSpriteBatch {
            return _parent;
        }

        public function changeFrame():void {
            _parent.changeFrame(_spriteId,_childId);
        }
        
        public function traceInfos():void {
            trace('vertices:');
            trace(_parent._verteces);
            trace('indeces:');
            trace(_parent._indeces);
            trace('uvs:');
            trace(_parent._uvs);
        }

        public function removeMe():void {
             _parent.removeChild(this);   
        }
    }


    import com.adobe.utils.*;    
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    class LiteSpriteBatch {
        internal var _sprites:LiteSpriteSheet;        
        internal var _verteces:Vector.<Number>;
        internal var _indeces:Vector.<uint>;
        internal var _uvs:Vector.<Number>;
        
        protected var _context3D:Context3D;
        protected var _parent:LiteSpriteStage;
        protected var _children:Vector.<LiteSprite>;

        protected var _indexBuffer:IndexBuffer3D;
        protected var _vertexBuffer:VertexBuffer3D;
        protected var _uvBuffer:VertexBuffer3D;
        protected var _shader:Program3D;
        protected var _updateVBOs:Boolean;


        public function LiteSpriteBatch(context3D:Context3D, spriteSheet:LiteSpriteSheet) {
            _context3D = context3D;
            _sprites = spriteSheet;            
            _verteces = new Vector.<Number>();
            _indeces = new Vector.<uint>();
            _uvs = new Vector.<Number>();
            _children = new Vector.<LiteSprite>;
            _updateVBOs = true;
            setupShaders();
            updateTexture();  
        }
        
        public function get parent():LiteSpriteStage {
            return _parent;
        }
        
        public function set parent(parentStage:LiteSpriteStage):void {
            _parent = parentStage;
        }
        
        public function get numChildren():uint {
            return _children.length;
        }
        
        public function createChild(spriteId:uint):LiteSprite {
            var sprite:LiteSprite = new LiteSprite();
            addChild(sprite, spriteId);
            return sprite;
        }
        
        public function addChild(sprite:LiteSprite, spriteId:uint):void {
            sprite._parent = this;
            sprite._spriteId = spriteId;
            sprite._childId = _children.length;
            _children.push(sprite);
            var childVertexFirstIndex:uint = (sprite._childId * 12) / 3; 
            _verteces.push(0,0,1,0,0,1,0,0,1,0,0,1);
            _indeces.push(childVertexFirstIndex, childVertexFirstIndex+1, childVertexFirstIndex+2, childVertexFirstIndex, childVertexFirstIndex+2, childVertexFirstIndex+3);
            var childUVCoords:Vector.<Number> = _sprites.getUVCoords(spriteId);
            _uvs.push(childUVCoords[0], childUVCoords[1],childUVCoords[2], childUVCoords[3],childUVCoords[4], childUVCoords[5],childUVCoords[6], childUVCoords[7]);   
            _updateVBOs = true;
        }
        
        public function removeChild(child:LiteSprite):void {
            var childId:uint = child._childId;
            if (child._parent == this && childId < _children.length) {
                child._parent = null;
                _children.splice(childId,1);
                var idx:uint;
                for (idx = childId; idx < _children.length; ++idx) {
                    _children[idx>>0]._childId = idx;
                }
                var vertexIdx:uint = childId * 12;
                var indexIdx:uint= childId * 6;
                _verteces.splice(vertexIdx, 12);
                _indeces.splice(indexIdx, 6);
                _uvs.splice(vertexIdx, 8);                
                _updateVBOs = true;
            }
        }
        
        public function changeFrame(spriteId:uint,childId:uint):void {
            var vertexIdx:uint = childId<<3;
            _uvs.splice(vertexIdx, 8);
            var childUVCoords:Vector.<Number> = _sprites.getUVCoords(spriteId);
            _uvs.splice(vertexIdx,0,childUVCoords[0], childUVCoords[1], childUVCoords[2], childUVCoords[3], childUVCoords[4], childUVCoords[5], childUVCoords[6], childUVCoords[7]);
            _updateVBOs = true;
        }

        protected function setupShaders():void {
            var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "dp4 op.x, va0, vc0 \n"+ //transform from stream 0 to output clipspace
                "dp4 op.y, va0, vc1 \n"+ //do the same for the y coordinate
                "mov op.z, vc2.z    \n"+ //we don't need to change the z coordinate
                "mov op.w, vc3.w    \n"+ //unused, but we need to output all data
                "mov v0, va1.xy     \n"+ //copy UV coords from stream 1 to fragment program
                "mov v0.z, va0.z    \n"  //copy alpha from stream 0 to fragment program
            );
            
            var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
                "tex ft0, v0, fs0 <2d,clamp,linear,mipnearest> \n"+ //sample the texture
                "mul ft0, ft0, v0.zzzz\n" + //multiply by the alpha transparency
                "mov oc, ft0 \n" //output the final pixel color 
            );
            
            _shader = _context3D.createProgram();
            _shader.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode );
        }
        
        protected function updateTexture():void {
            _sprites.uploadTexture(_context3D);    
        }
        
        public function updateChildVertexData(sprite:LiteSprite):void {
            var childVertexIdx:uint = sprite._childId * 12;
            if (sprite.visible) {
                var x:Number = sprite.position.x;
                var y:Number = sprite.position.y;
                var rect:Rectangle = sprite.rect;
                var sinT:Number = Math.sin(sprite.rotation);
                var cosT:Number = Math.cos(sprite.rotation);
                var alpha:Number = sprite.alpha;
                
                var scaledWidth:Number = rect.width * sprite.scaleX;
                var scaledHeight:Number = rect.height * sprite.scaleY;
                var centerX:Number = scaledWidth * .5;
                var centerY:Number = scaledHeight * .5;
                
                _verteces[childVertexIdx>>0] = x - (cosT * centerX) - (sinT * (scaledHeight - centerY));
                _verteces[(childVertexIdx+1)>>0] = y - (sinT * centerX) + (cosT * (scaledHeight - centerY));
                _verteces[(childVertexIdx+2)>>0] = alpha;
                
                _verteces[(childVertexIdx+3)>>0] = x - (cosT * centerX) + (sinT * centerY);
                _verteces[(childVertexIdx+4)>>0] = y - (sinT * centerX) - (cosT * centerY);
                _verteces[(childVertexIdx+5)>>0] = alpha;
                
                _verteces[(childVertexIdx+6)>>0] = x + (cosT * (scaledWidth - centerX)) + (sinT * centerY);
                _verteces[(childVertexIdx+7)>>0] = y + (sinT * (scaledWidth - centerX)) - (cosT * centerY);
                _verteces[(childVertexIdx+8)>>0] = alpha;
                
                _verteces[(childVertexIdx+9)>>0] = x + (cosT * (scaledWidth - centerX)) - (sinT * (scaledHeight - centerY));
                _verteces[(childVertexIdx+10)>>0] = y + (sinT * (scaledWidth - centerX)) + (cosT * (scaledHeight - centerY));
                _verteces[(childVertexIdx+11)>>0] = alpha;                
            }
            else {
                for (var i:uint = 0; i < 12; ++i) {
                    _verteces[(childVertexIdx+i)>>0] = 0;
                }
            }
        }
        
        public function draw():void {
            var n:uint = _children.length;
            if (n == 0) return;
            for (var i:uint = 0; i < n; ++i) {
                updateChildVertexData(_children[i>>0]);
            }
            _context3D.setProgram(_shader);
            _context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);            
            _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _parent.modelViewMatrix, true); 
            _context3D.setTextureAt(0, _sprites._texture);
            if (_updateVBOs) {
                _vertexBuffer = _context3D.createVertexBuffer(_verteces.length/3, 3);   
                _indexBuffer = _context3D.createIndexBuffer(_indeces.length);
                _uvBuffer = _context3D.createVertexBuffer(_uvs.length>>1, 2);
                _indexBuffer.uploadFromVector(_indeces, 0, _indeces.length);  
                _uvBuffer.uploadFromVector(_uvs, 0, _uvs.length>>1);
                _updateVBOs = false;
            }
            _vertexBuffer.uploadFromVector(_verteces, 0, _verteces.length / 3);
            _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            _context3D.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);            
            _context3D.drawTriangles(_indexBuffer, 0, n<<1);
        }
    }

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    
    class LiteSpriteSheet {
        internal var _texture : Texture;        
        protected var _spriteSheet : BitmapData;    
        protected var _uvCoords : Vector.<Number>;
        protected var _rects : Vector.<Rectangle>;
        
        public function LiteSpriteSheet(SpriteSheetBitmapData:BitmapData, numSpritesW:int=8, numSpritesH:int=8) {
            _uvCoords = new Vector.<Number>();
            _rects = new Vector.<Rectangle>();
            _spriteSheet = SpriteSheetBitmapData;
            createUVs(numSpritesW, numSpritesH);
        }

        public function createUVs(numSpritesW:uint, numSpritesH:uint):void {
            var destRect:Rectangle;
            for (var y:uint = 0; y<numSpritesH; ++y){
                for (var x:uint = 0; x<numSpritesW; ++x){
                    _uvCoords.push(
                        x / numSpritesW, (y+1) / numSpritesH,
                        x / numSpritesW, y / numSpritesH,
                        (x+1) / numSpritesW, y / numSpritesH,
                        (x + 1) / numSpritesW, (y + 1) / numSpritesH);
                        
                        destRect = new Rectangle();
                        destRect.left = 0;
                        destRect.top = 0;
                        destRect.right = _spriteSheet.width / numSpritesW;
                        destRect.bottom = _spriteSheet.height / numSpritesH;
                        _rects.push(destRect);                    
                }
            }
        }

        public function removeSprite(spriteId:uint):void {
            if (spriteId < _uvCoords.length) {
                _uvCoords = _uvCoords.splice(spriteId<<3, 8);
                _rects.splice(spriteId, 1);
            }
        }

        public function get numSprites():uint {
            return _rects.length;
        }

        public function getRect(spriteId:uint):Rectangle {
            return _rects[spriteId];
        }
        
        public function getUVCoords(spriteId:uint):Vector.<Number>{
            var startIdx:uint = spriteId<<3;
            return _uvCoords.slice(startIdx, startIdx+8);
        }
        
        public function uploadTexture(context3D:Context3D):void {
            if (_texture == null) {
                _texture = context3D.createTexture(_spriteSheet.width, _spriteSheet.height, Context3DTextureFormat.BGRA, false);
            }
 
            _texture.uploadFromBitmapData(_spriteSheet);
            
            var currentWidth:int = _spriteSheet.width >> 1;
            var currentHeight:int = _spriteSheet.height >> 1;
            var canvas:BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
            var transform:Matrix = new Matrix(.5, 0, 0, .5);
            var level:uint = 1;
            
            while (currentWidth >= 1 || currentHeight >= 1) {
                canvas.fillRect(new Rectangle(0, 0, Math.max(currentWidth,1), Math.max(currentHeight,1)), 0);
                canvas.draw(_spriteSheet, transform, null, null, null, true);
                _texture.uploadFromBitmapData(canvas, level++);
                transform.scale(.5, .5);
                currentWidth = currentWidth >> 1;
                currentHeight = currentHeight >> 1;
            }
        }
    }

    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    
    class LiteSpriteStage {
        protected var _stage3D:Stage3D;
        protected var _context3D:Context3D;        
        protected var _rect:Rectangle;
        protected var _batches:Vector.<LiteSpriteBatch>;
        protected var _modelViewMatrix:Matrix3D;
        
        public function LiteSpriteStage(stage3D:Stage3D, context3D:Context3D, r:Rectangle) {
            _stage3D = stage3D;
            _context3D = context3D;
            _batches = new Vector.<LiteSpriteBatch>;
            this.position = r;
        }
        
        public function get position():Rectangle {
            return _rect;
        }
        
        public function set position(r:Rectangle):void {
            _rect = r;
            _stage3D.x = r.x;
            _stage3D.y = r.y;
            configureBackBuffer(r.width, r.height);            
            _modelViewMatrix = new Matrix3D();
            _modelViewMatrix.appendTranslation(-r.width/2, -r.height/2, 0);            
            _modelViewMatrix.appendScale(2.0/r.width, -2.0/r.height, 1);
        }
        
        internal function get modelViewMatrix():Matrix3D {
            return _modelViewMatrix;
        }
        
        public function configureBackBuffer(w:uint, h:uint):void {
             _context3D.configureBackBuffer(w, h, 0, false);
        }
 
        public function addBatch(b:LiteSpriteBatch):void {
            b.parent = this;
            _batches.push(b);
        }
        
        public function removeBatch(batch:LiteSpriteBatch):void {
            for (var i:uint = 0; i < _batches.length; ++i) {
                if (_batches[i>>0] == batch) {
                    batch.parent = null;
                    _batches.splice(i, 1);
                }
            }
        }
        
        public function render():void {
            for (var i:uint = 0; i < _batches.length; ++i) {
                _batches[i>>0].draw();       
            }
        }
    }

    import flash.utils.ByteArray;
    class Base64 {
        private static const _decodeChars:Vector.<int> = InitDecodeChar();

        public static function decode(str:String):ByteArray {
            var c1:int;
            var c2:int;
            var c3:int;
            var c4:int;
            var i:int;
            var len:int;
            var out:ByteArray;
            len = str.length;
            i = 0;
            out = new ByteArray();
            var byteString:ByteArray = new ByteArray();
            byteString.writeUTFBytes(str);
            while (i<len) {
                do {
                    c1 = _decodeChars[byteString[i++]];
                } while (i < len && c1 == -1);   
                if (c1 == -1) break;
                do {   
                    c2 = _decodeChars[byteString[i++]]; 
                } while (i < len && c2 == -1);   
                if (c2 == -1) break;

                out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));
                do {
                    c3 = byteString[i++];
                    if (c3 == 61) return out;    
                    c3 = _decodeChars[c3];
                } while (i < len && c3 == -1);
                if (c3 == -1) break;
                
                out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));
                do {
                    c4 = byteString[i++];
                    if (c4 == 61) return out;
                    
                    c4 = _decodeChars[c4];
                } while (i < len && c4 == -1);
                if (c4 == -1) break;
                out.writeByte(((c3 & 0x03) << 6) | c4);
            }
            return out;
        }

        public static function InitDecodeChar():Vector.<int> {
            var decodeChars:Vector.<int> = new Vector.<int>();
            decodeChars.push(-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,   
                             52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,   
                             -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,   
                             15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,   
                             -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,   
                             41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                             -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
            return decodeChars;
        }
    }