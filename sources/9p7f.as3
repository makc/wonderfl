/*===================================================*//**
 * Generation Cluster with Twitter
 * ツイッターの世代をグループわけして表示するよ！
 * 
 * [参加方法]
 * ボタンをクリックして[]の中に自分の年齢を入れてつぶやくだけ
 * しばらくすると画面に表示されるよ！
 * 
 * @author Yasu
 * @see http://clockmaker.jp/blog/
 * @since 2009.09.17
 *//*===================================================*/
package {
    import Box2D.Collision.Shapes.*;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Joints.*;
    import Box2D.Dynamics.*;
    import com.bit101.components.*;
    
    import flash.system.LoaderContext;
    import flash.utils.*;
    import flash.net.*;
    import flash.ui.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    public class Main extends Sprite {
        // const vars
        static public const OBJ_SIZE:int = 36;
        
        // vars for Box2D
        private var worldWidth:Number;
        private var worldHeight:Number;
        private var m_iterations:int;
        private var m_wallWidth:Number;
        private var m_wallHeight:Number;
        private var m_timeStep:Number;
        private var m_physScale:Number;
        private var m_world:b2World;
        private var m_mouseJoint:b2MouseJoint;
        private var m_draggedBody:b2Body;
        private var mouseXWorldPhys:Number;
        private var mouseYWorldPhys:Number;
        private var isMouseDown:Boolean;
        private var arrayIndexI:int;
        private var arrayIndexJ:int;
        private var drawLayer:Sprite;
        
        // array of objs
        private var _mcArr:Array;
        private var _box2dArr:Array;
        private var _data:Dictionary;
        
        /**
         * Constructor
         */
        public function Main()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            
            addChild(new Bitmap(new BitmapData(465,465,false,0)));
            drawLayer = addChild(new Sprite) as Sprite;
            
            init()
            //stage.addEventListener(Event.RESIZE, init);
            
            
            var tweetButton:PushButton = new PushButton(this);
            tweetButton.label = "Tweet Age!";
            tweetButton.x = stage.stageWidth - tweetButton.width - 10;
            tweetButton.y = 10
            tweetButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                navigateToURL(new URLRequest("http://twitter.com/home/?status=" 
                    + escapeMultiByte("#MyAge [] http://bit.ly/MyAgeFriend")
                ));
            });
            
            var title:Label = new Label(this, 8, 0, "Generation Cluster with Twitter");
            title.scaleX = title.scaleY = 2;
            
            var des:Label = new Label(this, 10, 25, "Please click right button. And input your age in [].");
        }
            
        private function init(e:Event = null):void {
            _mcArr = [];
            _box2dArr = [];
            _data = new Dictionary();
            
            var loading:Label = new Label(this, stage.stageWidth / 2 - 40, stage.stageHeight / 2, "NOW LOADING");
            var tw:ITween = BetweenAS3.tween(loading, { alpha:1 }, { alpha:0.25 }, 0.05);
            tw = BetweenAS3.serial(tw, BetweenAS3.reverse(tw));
            tw.stopOnComplete = false;
            tw.play();
            
            var textLoader:URLLoader = new URLLoader();
            textLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
                removeChild(loading);
                tw.stop();
                tw = null;
                
                default xml namespace = new Namespace("http://www.w3.org/2005/Atom");
                var xml:XML = XML(e.target.data);
                myLabel : for (var i:int = 0; i < xml.entry.length(); i++) {
                    
                    // RT は除外
                    if(xml.entry[i].title.indexOf("RT") > -1){
                        continue;
                    }
                    
                    var age:int = int(scan(xml.entry[i].title,/\[(.+)\]/));
                    if(age > 0 && age < 99){
                        if (_data[age] == null) _data[age] = [];
                        
                        var l:int = _data[age].length;
                        while (l--) {
                            if (_data[age][l].name == xml.entry[i].author.name)
                                continue myLabel;
                        }
                        
                        _data[age].push({
                            img : xml.entry[i].link.(@type == "image/png").@href,
                            name : xml.entry[i].author.name,
                            uri : xml.entry[i].author.uri
                        });
                    }
                }
                
                initView();
            });
            //textLoader.load(new URLRequest("http://clockmaker.jp/labs/091023_nodes/search.atom"));
            textLoader.load(new URLRequest("http://search.twitter.com/search.atom?q=%23MyAge&rpp=" + 100));  
        }
        
        private function initView():void {
            // init 2D World
            create2dWorld();
            
            // init Box2D World
            createBox2dWorld();
            
            // init vars for drag
            arrayIndexI = -1;
            arrayIndexJ = -1;
            isMouseDown = false;
            
            // addEvent
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        }
        
        /**
         * Create 2D World
         */
        private function create2dWorld():void {
            var cnt:int = 0;
            var len:int = 0;
            var contextInfo:LoaderContext = new LoaderContext(true);
            for (var i:String in _data) {
                _mcArr[cnt] = [];
                for (var j:int = -1; j < _data[i].length; j++) {
                    var icon:MovieClip = addChild(new MovieClip()) as MovieClip;
                    
                    var bmpdata:BitmapData = new BitmapData(OBJ_SIZE, OBJ_SIZE, false, 0x333333);
                    var bmp:Bitmap = new Bitmap(bmpdata);
                    bmp.x = bmp.y = -OBJ_SIZE / 2;
                    icon.addChild(bmp);
                    //icon.graphics.beginFill(0x333333);
                    //icon.graphics.drawRect( -OBJ_SIZE / 2, -OBJ_SIZE / 2, OBJ_SIZE, OBJ_SIZE);
                    
                    icon.extra = { arrayPosI:cnt, arrayPosJ:j + 1 };
                    icon.x = (OBJ_SIZE * cnt) % stage.stageWidth;
                    icon.y = (OBJ_SIZE * j) % stage.stageHeight + Math.random() * 100 + 50;
                    
                    icon.addEventListener(MouseEvent.MOUSE_DOWN, iconMousePressHandler);
                    icon.addEventListener(MouseEvent.ROLL_OVER, iconMouseOverHandler);
                    icon.addEventListener(MouseEvent.ROLL_OUT, iconMouseOutHandler);
                    icon.addEventListener(MouseEvent.DOUBLE_CLICK, iconDoubleClickHandler);
                    
                    
                    if (j == -1) {
                        var label:Label = new Label(icon, 0, 0, i);
                        label.scaleX = label.scaleY = 2;
                        label.x = - 15;
                        label.y = - label.height;
                    }else {
                        var loader:Loader = new Loader();
                        loader.load(new URLRequest(_data[i][j].img), contextInfo);
                        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
                        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, trace);
                        icon.addChild(loader);
                        icon.extra.uri = _data[i][j].uri;
                        icon.doubleClickEnabled = true;
                        
                        var menu:ContextMenu = new ContextMenu();
                        menu.hideBuiltInItems();
                        var it:ContextMenuItem = new ContextMenuItem(_data[i][j].uri);
                        it.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
                            navigateToURL(new URLRequest(e.currentTarget.caption),"_blank");
                        });
                        menu.customItems = [it]
                        icon.contextMenu = menu;
                        
                        len ++;
                    }
                    _mcArr[cnt][j + 1] = icon;
                }
                cnt ++;
            }
            new Label(this, 10, 40, "DATA LENGTH : " + len);
        }
        
        private function loadComplete(e:Event):void {
            e.target.loader.width = OBJ_SIZE - 4;
            e.target.loader.height = OBJ_SIZE - 4;
            e.target.loader.x = -(OBJ_SIZE - 4) / 2;
            e.target.loader.y = -(OBJ_SIZE - 4) / 2;
        }
        
        private function iconDoubleClickHandler(e:MouseEvent):void {
            navigateToURL(new URLRequest(e.currentTarget.extra.uri), "_blank");
        }
        
        /**
         * Create Box2D World
         */
        private function createBox2dWorld():void {
            // init Box2D
            worldWidth = stage.stageWidth;
            worldHeight = stage.stageHeight;
            m_iterations = 10;
            m_timeStep = 1 / stage.frameRate;
            m_physScale = 30;
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set( 0, 0);
            worldAABB.upperBound.Set(stage.stageWidth, stage.stageHeight);
            var gravity:b2Vec2 = new b2Vec2(0, 10);
            var doSleep:Boolean = true;
            m_world = new b2World(worldAABB, gravity, doSleep);
            
            //デバック用
            //var dbgDraw:b2DebugDraw= new b2DebugDraw();
            //var dbgSprite:Sprite= new Sprite();
            //addChild(dbgSprite);
            //dbgDraw.m_sprite= dbgSprite;
            //dbgDraw.m_drawScale= 30.0;
            //dbgDraw.m_fillAlpha = 0.3;
            //dbgDraw.m_lineThickness = 1.0;
            //dbgDraw.m_alpha = 1.0;
            //dbgDraw.m_xformScale = 1.0;
            //dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
            //m_world.SetDebugDraw(dbgDraw);
            
            // craete wall for Box2D
            var wallShapeDef:b2PolygonDef = new b2PolygonDef();
            var wallBodyDef:b2BodyDef = new b2BodyDef();
            var wall:b2Body;
            m_wallWidth = stage.stageWidth;
            m_wallHeight = stage.stageHeight;
            // left wall
            wallShapeDef.SetAsBox(1 / m_physScale, m_wallHeight / 2 / m_physScale);
            wallBodyDef.position.Set(0, m_wallHeight / 2 / m_physScale);
            wall = m_world.CreateBody(wallBodyDef);
            wall.CreateShape(wallShapeDef);
            // right wall
            wallBodyDef.position.Set(m_wallWidth / m_physScale, m_wallHeight / 2 / m_physScale);
            wall = m_world.CreateBody(wallBodyDef);
            wall.CreateShape(wallShapeDef);
            // upper wall
            wallShapeDef.SetAsBox(m_wallWidth / 2 / m_physScale, 1 / m_physScale);
            wallBodyDef.position.Set(m_wallWidth / 2 / m_physScale, 0);
            wall = m_world.CreateBody(wallBodyDef);
            wall.CreateShape(wallShapeDef);
            
            // bottom wall
            wallBodyDef.position.Set(m_wallWidth / 2 / m_physScale, m_wallHeight / m_physScale);
            wall = m_world.CreateBody(wallBodyDef);
            wall.CreateShape(wallShapeDef);
            
            wall.SetMassFromShapes();
            for (var i:int = 0; i < _mcArr.length; i++) {
                _box2dArr[i] = [];
                for (var j:int = 0; j < _mcArr[i].length; j++) {
                    var icon:MovieClip = _mcArr[i][j];
                    var boxShape:b2PolygonDef = new b2PolygonDef();
                    boxShape.SetAsBox(OBJ_SIZE / m_physScale / 2, OBJ_SIZE / m_physScale / 2);
                    boxShape.density = 10;
                    boxShape.friction = 10;
                    boxShape.restitution = 0.5;
                    var bodyDef:b2BodyDef = new b2BodyDef();
                    bodyDef.position.Set(icon.x / m_physScale, icon.y / m_physScale);
                    var body:b2Body = m_world.CreateBody(bodyDef);
                    body.CreateShape(boxShape);
                    body.SetUserData(icon);
                    body.SetMassFromShapes();
                    
                    _box2dArr[i][j] = body;
                }
                // create joints
                for (j = 0; j < _mcArr[i].length; j++) {
                    var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
                    jointDef.Initialize(
                        _box2dArr[i][0], 
                        _box2dArr[i][j], 
                        _box2dArr[i][0].GetPosition(), 
                        _box2dArr[i][j].GetPosition());
                    var joint:b2DistanceJoint = m_world.CreateJoint(jointDef) as b2DistanceJoint;
                    joint.m_length = 1;
                    joint.m_frequencyHz = 1.5;
                    joint.m_dampingRatio = 0.5;
                }
            }
        }
        
        /**
         * get mouse position, and convert box2d scale
         */
        private function updateMouseWorld():void {
            mouseXWorldPhys = mouseX / m_physScale;
            mouseYWorldPhys = mouseY / m_physScale;
        }
        /**
         * Enter Frame
         * @param    event
         */
        private function enterFrameHandler(event:Event):void {
            // update Box2D step
            updateMouseWorld();
            mouseDrag();
            m_world.Step(m_timeStep, m_iterations);
            // sync position to PV3D from Box2D
            for (var bb:b2Body = m_world.GetBodyList(); bb; bb = bb.GetNext()) {
                if (bb.GetUserData()is MovieClip) {
                    bb.GetUserData().x = bb.GetPosition().x * m_physScale;
                    bb.GetUserData().y = bb.GetPosition().y * m_physScale;
                    bb.GetUserData().rotation = bb.GetAngle() * (180 / Math.PI);
                }
            }
            
            drawLayer.graphics.clear();
            
            for (var i:int = 0; i < _mcArr.length; i++) {
                for (var j:int = 0; j < _mcArr[i].length; j++) {
                    if(arrayIndexI == i)  drawLayer.graphics.lineStyle(1, 0x990000);
                    else  drawLayer.graphics.lineStyle(1, 0x333333);
                    var os:MovieClip = _mcArr[i][0];
                    var oe:MovieClip = _mcArr[i][j];
                    
                    // 一定の長さより短い場合は負荷を下げるため描かない
                    var len:Number = Math.sqrt( (os.x - oe.x)*(os.x - oe.x) + (os.y - oe.y)*(os.y - oe.y)); 
                    if(len > OBJ_SIZE * 1.5){
                        drawLayer.graphics.moveTo(os.x, os.y);
                        drawLayer.graphics.lineTo(oe.x, oe.y);
                    }
                }
            }
            
        }
        /**
         * Drag And Drop
         */
        private function mouseDrag():void {
            if (isMouseDown && ! m_mouseJoint){
                m_draggedBody = null;
                    
                if (arrayIndexI > -1)
                    m_draggedBody = _box2dArr[arrayIndexI][arrayIndexJ];
                
                if (m_draggedBody) {
                    var md:b2MouseJointDef = new b2MouseJointDef();
                    md.body1 = m_world.GetGroundBody();
                    md.body2 = m_draggedBody;
                    md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
                    md.maxForce = 3000 * m_draggedBody.GetMass();
                    md.timeStep = m_timeStep;
                    m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
                    m_draggedBody.WakeUp();
                }
            }
            if (!isMouseDown){
                if ( m_mouseJoint ) {
                    m_world.DestroyJoint( m_mouseJoint );
                    m_mouseJoint = null;
                }
            }
            if ( m_mouseJoint ) {
                var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
                m_mouseJoint.SetTarget(p2);
            }
        }
        
        /**
         * Mouse Down
         * @param    event
         */
        private function mouseDownHandler(event:MouseEvent):void {
            isMouseDown = true;
        }
        /**
         * Mouse Up
         * @param    event
         */
        private function mouseUpHandler(event:MouseEvent):void {
            Mouse.cursor = MouseCursor.ARROW;
            isMouseDown = false;
            arrayIndexI = -1;
            arrayIndexJ = -1;
        }
        
        /**
         * get number of clicked obj
         * @param    event
         */
        private function iconMousePressHandler(e:MouseEvent):void  {
            arrayIndexI = (e.currentTarget as MovieClip).extra.arrayPosI;
            arrayIndexJ = (e.currentTarget as MovieClip).extra.arrayPosJ;
        }
        
        private function iconMouseOverHandler(e:MouseEvent):void {
            Mouse.cursor = MouseCursor.HAND;
        }
        
        private function iconMouseOutHandler(e:MouseEvent):void {
            if(!isMouseDown) Mouse.cursor = MouseCursor.ARROW;
        }
        
        /**
         * @see http://takumakei.blogspot.com/2009/05/actionscriptrubystringscan.html
         */ 
        //package com.blogspot.takumakei.utils
        //{
            //public
            public function scan(str:String, re:RegExp):Array
            {
                if(!re.global){
                    var flags:String = 'g';
                    
                    if(re.dotall)
                        flags += 's';
                    if(re.multiline)
                        flags += 'm';
                    if(re.ignoreCase)
                        flags += 'i';
                    if(re.extended)
                        flags += 'x';
                    re = new RegExp(re.source, flags);                    
                }
                var r:Array = [];
                var m:Array = re.exec(str);
                while(null != m){
                    if(1 == m.length)
                        r.push(m[0]);
                    else
                        r.push(m.slice(1, m.length));
                    m = re.exec(str);
                }
                return r;
            }
        //}
    }
}
