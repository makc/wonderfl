/**
 * [ Queen and Manservant 女王様と下僕 ]
 *
 * --------------------------------------------------
 *
 * 女王様の気分となって
 * あなたの足で下僕を、思う存分踏みつけてやってください。
 * アイコンたちは女王様に忠誠を誓った下僕の方々です。
 *
 * 思う存分、下僕を踏みつけたら、Replayボタンをおしてみましょう。
 * 様々なアングルから踏みつけた感触に思い浸ることができます。
 *
 * --------------------------------------------------
 *
 * inspired by
 * 女王様とおつぶやき
 * http://joousama.kayac.com/
 *
 * resource by
 * 女王様の下僕一覧 (Twitterのリプレイを参照)
 * http://joousama.kayac.com/footman/list
 * http://twitter.com/JOOUSAMA/followers
 *
 * --------------------------------------------------
 *
 * <注意>
 * Flash Player 10.1 beta2だと、なぜかクロスドメインエラーで再生できません。
 * FP10.0だと問題ないので、見れないと思ったらFP10をご利用下さい。
 *
 */
// forked from checkmate's Checkmate Vol.6 Professional
package {
    
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.ui.*;
    import flash.utils.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Joints.*;
    import jp.progression.casts.CastDocument;
    import jp.progression.commands.lists.LoaderList;
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.LoadBitmapData;
    import jp.progression.commands.net.LoadURL;
    import jp.progression.data.Resource;
    import jp.progression.data.getResourceById;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Cubic;
    import org.libspark.betweenas3.easing.Quad;
    import org.libspark.betweenas3.easing.Sine;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.cameras.CameraType;
    import org.papervision3d.core.effects.view.ReflectionView;
    import org.papervision3d.core.proto.MaterialObject3D;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.WireframeMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.*;

    [SWF(width="465", height="465", frameRate="30", backgroundColor="0x0")]

    public class CheckmateProfessional extends CastDocument {
        public static const OBJ_NUM:int = 40;
        public static const OBJ_SIZE:int = 40;
        public static const URL_QUEEN_IMG:String = "http://assets.wonderfl.net/images/related_images/1/10/10b4/10b47406acc3bb8fcb59297590b1d953ceab8df2";
        public static const URL_TWITTER_API:String = "http://search.twitter.com/search.atom?q=%40JOOUSAMA&rpp=" + OBJ_NUM;
        private static const IMG_HEIGHT:int = 465 * 2;
        private static const IMG_WIDTH:int = 121;
        private static const IS_DEBUG:Boolean = false;
        private static const LOADER_CONTEXT:LoaderContext = new LoaderContext(true);

        // array of objs
        private var _2dIcon:Array = [];
        private var _2dQueen:MovieClip;

        private var _3dCubes:Array = [];
        private var _3dQueen:Plane;
        private var _3dWorld:ReflectionView;

        private var _arrayIndex:int;
        private var _box2dArr:Array = [];
        private var _data:Array = [];

        private var _iconContainer:Sprite;
        private var _isMouseDown:Boolean;
        private var _isRecording:Boolean = false;
        private var _isReplay:Boolean = false;
        private var _loadingLabel:Label;
        private var _loadingProgress:ProgressBar;
        private var _loadingTween:ITween;
        private var _recoardSprite:Sprite;
        private var _recordIconsArr:Array = [];
        private var _recordQueenArr:Array = [];
        private var _replayCnt:int;
        private var _replayDirection:int = 1;
        private var _uiBtn:PushButton;

        private var m_draggedBody:b2Body;
        private var m_iterations:int;
        private var m_mouseJoint:b2MouseJoint;
        private var m_physScale:Number;
        private var m_timeStep:Number;
        private var m_wallHeight:Number;
        private var m_wallWidth:Number;
        private var m_world:b2World;
        private var mouseXWorldPhys:Number;
        private var mouseYWorldPhys:Number;

        override protected function atReady():void {

            /*
               アルゴリズムでエロスを表現してください。
               公序良俗は守ってください。

               Create sexy expression through algorithm.
               DO NOT be offensive to public order and morals.
             */
            new SerialList(null,
                initSwf,
                startLoading,
                new LoadURL(new URLRequest(URL_TWITTER_API)),
                parseXml,
                function():void {
                    var cmd:LoaderList = new LoaderList();
                    cmd.onProgress = function():void {
                        _loadingProgress.value = cmd.percent / 100;
                    };
                    for (var i:int = 0; i < _data.length; i++)
                        cmd.addCommand(
                            new LoadBitmapData(new URLRequest(_data[i].img), {
                                context: LOADER_CONTEXT,
                                catchError: function(target:Object, error:Error):void {
                                // targetはCommand.scopeプロパティ。何もしなければエラーが発生したコマンド
                                target.executeComplete();
                            }
                            })
                            );
                    cmd.addCommand(new LoadBitmapData(new URLRequest(URL_QUEEN_IMG), {context: LOADER_CONTEXT}));
                    this.parent.insertCommand(cmd);
                },
                stopLoading,
                initView,
                record
                ).execute();
        }

        /**
         * Create Box2D World
         */
        private function createBox2dWorld():void {
            // init Box2D
            m_iterations = 10;
            m_timeStep = 1 / stage.frameRate;
            m_physScale = 30;
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(0, 0);
            worldAABB.upperBound.Set(stage.stageWidth, stage.stageHeight);
            var gravity:b2Vec2 = new b2Vec2(0, 10);
            var doSleep:Boolean = true;
            m_world = new b2World(worldAABB, gravity, doSleep);

            //デバック用
            if (IS_DEBUG) {
                var dbgDraw:b2DebugDraw = new b2DebugDraw();
                var dbgSprite:Sprite = new Sprite();
                dbgSprite.mouseChildren = false;
                dbgSprite.mouseEnabled = false;
                addChild(dbgSprite);
                dbgDraw.m_sprite = dbgSprite;
                dbgDraw.m_drawScale = 30.0;
                dbgDraw.m_fillAlpha = 0.3;
                dbgDraw.m_lineThickness = 1.0;
                dbgDraw.m_alpha = 1.0;
                dbgDraw.m_xformScale = 1.0;
                dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
                m_world.SetDebugDraw(dbgDraw);
            }
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
            var upperWall:b2Body = m_world.CreateBody(wallBodyDef);
            upperWall.CreateShape(wallShapeDef);

            // bottom wall
            wallBodyDef.position.Set(m_wallWidth / 2 / m_physScale, m_wallHeight / m_physScale);
            wall = m_world.CreateBody(wallBodyDef);
            wall.CreateShape(wallShapeDef);
            wall.SetMassFromShapes();

            //
            var jShape:b2PolygonDef = new b2PolygonDef();
            jShape.SetAsBox(IMG_WIDTH / m_physScale / 2, IMG_HEIGHT / m_physScale / 2);
            jShape.density = 10;
            jShape.friction = 10;
            jShape.restitution = 0.5;
            var jBodyDef:b2BodyDef = new b2BodyDef();
            jBodyDef.position.Set(200 / m_physScale, 200 / m_physScale);
            var jBody:b2Body = m_world.CreateBody(jBodyDef);
            jBody.CreateShape(jShape);
            jBody.SetUserData(_2dQueen);
            jBody.SetMassFromShapes();

            _box2dArr.push(jBody);

            // create joints
            var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
            jointDef.Initialize(
                upperWall,
                jBody,
                upperWall.GetPosition(),
                jBody.GetPosition());
            var joint:b2DistanceJoint = m_world.CreateJoint(jointDef) as b2DistanceJoint;
            joint.m_length = 1;
            joint.m_frequencyHz = 1.5;
            joint.m_dampingRatio = 1;

            for (var i:int = 0; i < _2dIcon.length; i++) {
                var icon:MovieClip = _2dIcon[i];
                var boxShape:b2PolygonDef = new b2PolygonDef();
                boxShape.SetAsBox(OBJ_SIZE / m_physScale / 2, OBJ_SIZE / m_physScale / 2);
                boxShape.density = 10;
                boxShape.friction = 10;
                boxShape.restitution = 0.5;
                var bodyDef:b2BodyDef = new b2BodyDef();
                bodyDef.position.Set(icon.x / m_physScale, icon.y / m_physScale);
                var body:b2Body = m_world.CreateBody(bodyDef);
                body.CreateShape(boxShape);
                body.SetUserData(i);
                body.SetMassFromShapes();

                _box2dArr.push(body);
            }
        }

        private function getUrl(e:Event):void {
            navigateToURL(new URLRequest("http://joousama.kayac.com/"), "_blank");
        }

        private function iconDoubleClickHandler(e:MouseEvent):void {
            navigateToURL(new URLRequest(e.currentTarget.extra.uri), "_blank");
        }

        private function iconMouseOutHandler(e:MouseEvent):void {
            if (!_isMouseDown)
                Mouse.cursor = MouseCursor.ARROW;
        }

        private function iconMouseOverHandler(e:MouseEvent):void {
            Mouse.cursor = MouseCursor.HAND;
        }

        /**
         * get number of clicked obj
         * @param    event
         */
        private function iconMousePressHandler(e:MouseEvent):void {
            _arrayIndex = (e.currentTarget as MovieClip).extra.arrayPosI;
        }

        /**
         * Create 2D World
         */
        private function initIcon2D():void {
            _iconContainer = new Sprite();
            addChild(_iconContainer);

            var cnt:int = 0;
            _2dIcon = [];
            for (var i:int = 0; i < _data.length; i++) {
                var icon:MovieClip = new MovieClip();
                icon.graphics.beginFill(0x333333);
                icon.graphics.drawRect(-OBJ_SIZE / 2, -OBJ_SIZE / 2, OBJ_SIZE, OBJ_SIZE);

                icon.extra = {arrayPosI: i};
                icon.x = (OBJ_SIZE * i) % stage.stageWidth + Math.random() * 20;
                icon.y = (OBJ_SIZE * i) % stage.stageHeight + Math.random() * 20 + 50;

                var res:Resource = getResourceById(_data[i].img);
                var img:Bitmap = new Bitmap(res.toBitmapData());

                img.width = OBJ_SIZE - 4;
                img.height = OBJ_SIZE - 4;
                img.x = -(OBJ_SIZE - 4) / 2 >> 0;
                img.y = -(OBJ_SIZE - 4) / 2 >> 0;

                icon.addChild(img);
                icon.extra.uri = _data[i].uri;
                icon.doubleClickEnabled = true;

                var menu:ContextMenu = new ContextMenu();
                menu.hideBuiltInItems();
                var it:ContextMenuItem = new ContextMenuItem(_data[i].uri);
                it.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:Event):void {
                        navigateToURL(new URLRequest(e.currentTarget.caption), "_blank");
                    });
                menu.customItems = [it]
                icon.contextMenu = menu;

                _iconContainer.addChild(icon);
                _2dIcon[i] = icon;
            }
            cnt++;
        }

        private function initPV3D():void {
            _3dWorld = new ReflectionView(0, 0, true, false, CameraType.TARGET);
            addChild(_3dWorld);
            _3dWorld.surfaceHeight = -465;

            var res:Resource = getResourceById(URL_QUEEN_IMG);
            var m:BitmapMaterial = new BitmapMaterial(res.toBitmapData());
            m.doubleSided = true;
            _3dQueen = new Plane(m, IMG_WIDTH, IMG_HEIGHT, 2, 2);
            _3dWorld.scene.addChild(_3dQueen);

            for (var i:int = 0; i < _data.length; i++) {
                res = getResourceById(_data[i].img);
                var mat:MaterialObject3D;
                if (res.data == null)
                    mat = new WireframeMaterial(0x808080);
                else
                    mat = new BitmapMaterial(res.toBitmapData());
                var cube:Cube = new Cube(new MaterialsList({all: mat}), OBJ_SIZE, OBJ_SIZE, OBJ_SIZE, 1, 1, 1, 0, Cube.FRONT);
                _3dWorld.scene.addChild(cube);

                _3dCubes[i] = cube;
            }
        }

        private function initQueen():void {
            _2dQueen = new MovieClip()

            var res:Resource = getResourceById(URL_QUEEN_IMG);

            var img:Bitmap = new Bitmap(res.toBitmapData());
            img.x = -IMG_WIDTH / 2 >> 0;
            img.y = -IMG_HEIGHT / 2 >> 0;
            _2dQueen.addChild(img);
            _2dQueen.addEventListener(MouseEvent.MOUSE_DOWN, iconMousePressHandler);
            _2dQueen.addEventListener(MouseEvent.ROLL_OVER, iconMouseOverHandler);
            _2dQueen.addEventListener(MouseEvent.ROLL_OUT, iconMouseOutHandler);
            _2dQueen.addEventListener(MouseEvent.DOUBLE_CLICK, iconDoubleClickHandler);
            _2dQueen.extra = {arrayPosI: 0};
            _iconContainer.addChild(_2dQueen);
        }

        private function initSwf():void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;

            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.height);
        }

        private function initUI():void {
            var title:Label = new Label(this, 10, 10, "Queen and Manservant");
            title.scaleX = title.scaleY = 2;
            new Label(this, 10, 40, "DRAG FOOT OF QUEEN, AND REPLAY");

            _uiBtn = new PushButton(this, 10, 60, "Replay", replayTo3D);


            new Label(this, 280, 20, "INSPIRED BY http://joousama.kayac.com/");
            new PushButton(this, 360, 40, "LINK", getUrl);
        }

        private function initView():void {
            // init 2D World
            initIcon2D();
            initQueen();

            // init Box2D World
            createBox2dWorld()

            initPV3D();

            // init vars for drag
            _arrayIndex = -1;
            _isMouseDown = false;

            // addEvent
            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

            initUI();

        }

        /**
         * Enter Frame
         * @param    event
         */
        private function loop(event:Event):void {
            // update Box2D step
            if (_isRecording) {
                updateMouseWorld();
                mouseDrag();
                m_world.Step(m_timeStep, m_iterations);
                // sync position to PV3D from Box2D
                for (var bb:b2Body = m_world.GetBodyList(); bb; bb = bb.GetNext()) {
                    if (bb.GetUserData() is int) {
                        var cnt:int = bb.GetUserData();
                        _2dIcon[cnt].x = bb.GetPosition().x * m_physScale;
                        _2dIcon[cnt].y = bb.GetPosition().y * m_physScale;
                        _2dIcon[cnt].rotation = bb.GetAngle() * (180 / Math.PI);

                        // save
                        if (_recordIconsArr[cnt] == null)
                            _recordIconsArr[cnt] = [];
                        _recordIconsArr[cnt].push({x: _2dIcon[cnt].x, y: _2dIcon[cnt].y, rotation: _2dIcon[cnt].rotation});
                    }

                    if (bb.GetUserData() == _2dQueen) {
                        _2dQueen.x = bb.GetPosition().x * m_physScale;
                        _2dQueen.y = bb.GetPosition().y * m_physScale;
                        _2dQueen.rotation = bb.GetAngle() * (180 / Math.PI);
                        // save
                        _recordQueenArr.push({x: _2dQueen.x, y: _2dQueen.y, rotation: _2dQueen.rotation});
                    }
                }

                // 点滅
                _recoardSprite.visible = getTimer() % 500 > 250;

            } else if (_isReplay) {
                if (_replayCnt >= _recordQueenArr.length - 1)
                    _replayDirection = -1;
                else if (_replayCnt == 0)
                    _replayDirection = 1;
                var sabunX:int = -_3dWorld.viewport.width / 2 >> 0;
                var sabunY:int = +_3dWorld.viewport.height / 2 >> 0;

                for (var i:int = 0; i < _3dCubes.length; i++) {
                    var o:Object = _recordIconsArr[i][_replayCnt];

                    _3dCubes[i].x = o.x + sabunX;
                    _3dCubes[i].y = -1 * o.y + sabunY;
                    _3dCubes[i].rotationZ = -1 * o.rotation;
                }

                _3dQueen.x = _recordQueenArr[_replayCnt].x + sabunX;
                _3dQueen.y = -1 * _recordQueenArr[_replayCnt].y + sabunY;
                _3dQueen.z = 0;
                _3dQueen.rotationZ = -1 * _recordQueenArr[_replayCnt].rotation;

                _replayCnt += _replayDirection;

                _3dWorld.singleRender();
            }
        }

        /**
         * Mouse Down
         * @param    event
         */
        private function mouseDownHandler(event:MouseEvent):void {
            _isMouseDown = true;
        }

        /**
         * Drag And Drop
         */
        private function mouseDrag():void {
            if (_isMouseDown && !m_mouseJoint) {
                m_draggedBody = null;

                if (_arrayIndex > -1)
                    m_draggedBody = _box2dArr[_arrayIndex];

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
            if (!_isMouseDown) {
                if (m_mouseJoint) {
                    m_world.DestroyJoint(m_mouseJoint);
                    m_mouseJoint = null;
                }
            }
            if (m_mouseJoint) {
                var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
                m_mouseJoint.SetTarget(p2);
            }
        }

        /**
         * Mouse Up
         * @param    event
         */
        private function mouseUpHandler(event:MouseEvent):void {
            Mouse.cursor = MouseCursor.ARROW;
            _isMouseDown = false;
            _arrayIndex = -1;
        }

        private function parseXml():void {
            default xml namespace=new Namespace("http://www.w3.org/2005/Atom");
            var xml:XML = XML(getResourceById(URL_TWITTER_API).toString());
            for (var i:int = 0; i < xml.entry.length(); i++) {
                var img:String = xml.entry[i].link.(@type == "image/png").@href;
                _data.push({
                        img: xml.entry[i].link.(@type == "image/png").@href,
                        name: xml.entry[i].author.name,
                        uri: xml.entry[i].author.uri
                    });
            }
        }

        private function record():void {
            _isRecording = true;
            _isReplay = false;
            _recoardSprite = new Sprite();
            _recoardSprite.graphics.beginFill(0xFF0000);
            _recoardSprite.graphics.drawCircle(130, 68, 10);
            addChild(_recoardSprite);
        }

        private function replayTo3D(e:Event):void {
            _isRecording = false;
            _isReplay = true;
            _replayCnt = 0;
            removeChild(_iconContainer);
            removeChild(_uiBtn);
            removeChild(_recoardSprite);

            var tw:ITween = BetweenAS3.serial(
                BetweenAS3.tween(_3dWorld.camera, {x: 0, y: 0, z: -446}, {x: 0, y: 0, z: -346}, 7, Quad.easeInOut),
                BetweenAS3.tween(_3dWorld.camera, {x: 300, y: -200, z: -346}, {x: -300, y: -200, z: -346}, 8, Sine.easeInOut),
                BetweenAS3.func(function():void {
                    _3dWorld.camera.target = null;
                    _3dWorld.camera.rotationX = 0;
                    _3dWorld.camera.rotationY = 20;
                    _3dWorld.camera.rotationZ = 0;
                }),
                BetweenAS3.tween(_3dWorld.camera, {x: -100, y: -150, z: -150}, {x: 300, y: -150, z: -150}, 8, Sine.easeInOut),
                BetweenAS3.func(function():void {
                    _3dWorld.camera.target = DisplayObject3D.ZERO;
                }),
                BetweenAS3.tween(_3dWorld.camera, {x: 300, y: 300, z: -346}, {x: 400, y: 400, z: -200}, 7, Cubic.easeInOut),
                BetweenAS3.tween(_3dWorld.camera, {x: -200, y: -200, z: -346}, {x: 0, y: -300, z: -340}, 10, Sine.easeInOut)
                );
            tw.stopOnComplete = false;
            tw.play();
        }

        private function startLoading():void {
            _loadingLabel = new Label(this, stage.stageWidth / 2 - 40, stage.stageHeight / 2 - 10, "NOW LOADING");
            _loadingTween = BetweenAS3.tween(_loadingLabel, {alpha: 1}, {alpha: 0.25}, 0.05);
            _loadingTween = BetweenAS3.serial(_loadingTween, BetweenAS3.reverse(_loadingTween));
            _loadingTween.stopOnComplete = false;
            _loadingTween.play();

            _loadingProgress = new ProgressBar(this, stage.stageWidth / 2 - 57, stage.stageHeight / 2 + 10);
        }

        private function stopLoading():void {
            removeChild(_loadingLabel);
            removeChild(_loadingProgress);
            _loadingTween.stop();
            _loadingTween = null;
        }

        /**
         * get mouse position, and convert box2d scale
         */
        private function updateMouseWorld():void {
            mouseXWorldPhys = mouseX / m_physScale;
            mouseYWorldPhys = mouseY / m_physScale;
        }
    }
}
