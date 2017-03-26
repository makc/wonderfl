package
{
        
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.events.Event
    import flash.events.MouseEvent

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.display.BitmapData;

    import flash.system.System;
    import flash.system.Security;
    
    /**
     * ...
     * @author narutohyper
     */
    
    [SWF(width = 1200, height = 800, frameRate = 60)]
    public class Main extends Sprite {

        public var testPoint:Array
        private var _canvas:Sprite;
        private var _imgAndBone:ImgAndBone;
        
        
        private var _alert:AlertPanel;
        
        public function Main():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            //Sample画像の読み込み
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            
            Security.loadPolicyFile("http://marubayashi.net/crossdomain.xml");
            
            _canvas=new Sprite()
            this.addChild(_canvas);

            //---------------------------------
            //アーマチュア（枠組み）の作成
            //---------------------------------
            _imgAndBone = new Dolphin();
            //_imgAndBone = new SchoolGirl();

            _imgAndBone.addEventListener(ImgAndBone.LOADED, onImgLoaded);
                        
            _canvas.addChild(_imgAndBone);
            
            onStageResize();
            this.stage.addEventListener(Event.RESIZE, onStageResize);
            
            
            _alert = new AlertPanel('エラー')
            addChild(_alert);
            
        }
        
        private function onImgLoaded(e:Event = null):void {
            onStageResize();
        }
        
        private function onStageResize(e:Event=null):void {
            _canvas.x = int((this.stage.stageWidth - _imgAndBone.img.width) / 2);
            _canvas.y = 30

            if (_canvas.x < 10) {
                _canvas.x = 10;
            }
        }
        
        public function get alert():AlertPanel {
            return _alert;
        }

    }
    
}


//===========================================================================================
//IKクラス
//===========================================================================================
    import flash.display.Sprite;

    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.text.*
    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.ui.Keyboard;

    //-----------------------------------------
    //IKArmature2d
    //-----------------------------------------
    class IKArmature2d extends Sprite    {
        public static const MOUSE_DOWN:String = 'mouse_down';
        public static const MOUSE_UP:String = 'mouse_up';
        public static const MOUSE_MOVE:String = 'mouse_move';
        
        private var _rootJoint:IKJoint2d;
        private var _bones:Object;
        private var _mesh:ImgMesh2d;
        private var _data:XML;
        private var _vertecis:Array
        
        private var target:Sprite;
        private var IKBones:Array;
        private var oldPoint:Point;
        private var newPoint:Point;
        

        private var tempVector:Array
        private var tempArray:Array

        public var startBone:IKBone2d;
        
        public var test:Array
        private var testCounter:uint=0
        
        public function IKArmature2d ($test:Array=null) {
            test = $test;
            
            _vertecis=new Array()

            bones = new Object();
            bones['root'] = new IKBone2d('root',0);
            bones['root'].superRotation = -90;
            bones['root'].setDegree(0);
            bones['root'].addEventListener(IKBone2d.ROOT_DOWN,IKDrag)
            this.addChild(bones['root']);
        }

        
        public function init():void {
            bones['root'].move();

            var i:int;
            //配置の順番を変える
            //rootから順番に
            tempArray=new Array()
            node(bones['root'])
            for (i = tempArray.length - 1; i >= 0; i--) {
                this.addChild(tempArray[i]);
            }
        }


        public function node(bone:IKBone2d):void {
            var i:uint;
            tempArray.push(bone);
            for (i=0;i<bone.childs.length;i++) {
                node(bone.childs[i]);
            }
        }


        
        
        public function setBone(value:IKBone2d):void {
            bones[value.id] = value;
            bones[value.id].ikArmature = this;
            bones[value.id].addEventListener(IKBone2d.MOUSE_DOWN, IKStart)
            
            
            
            if (test && test.length > testCounter) {
                bones[value.id].testMc = test[testCounter]
            }
            
            
            
            testCounter++
        }
        
        public function joint($boneA:String = null, $boneB:String = null,$lock:Boolean=false):void {
            if (bones[$boneA] && bones[$boneB]) {
                bones[$boneA].setChild(bones[$boneB]);
                bones[$boneB].lock = $lock;
            } else {
                trace('Error:boneが存在しません。', $boneA + '=', bones[$boneA], $boneB + '=', bones[$boneB]);
            }
        }
        
        
        //Meshから送られてくるクリックされたVertex
        public function setVertex(value:uint):String {
            //現在ActiveなBoneにVertexにセットする。
            var result:String
            if (startBone) {
                _vertecis[value] = startBone.id;
                //ふりなおし
                var i:uint
                for each(var item:IKBone2d in bones) {
                    item.vartices = []
                }
                for (i = 0; i < _vertecis.length;i++ ) {
                    if (_vertecis[i] != "root") {
                        bones[_vertecis[i]].addVertex(mesh.vertices[i])
                    }
                }
                result = startBone.id
                startBone.selectOn()
            }

            return result;
        }
        
        
        
        //関連付けられたMesh2d
        public function set mesh(value:ImgMesh2d):void {
                _mesh = value;
        }
        
        public function get mesh():ImgMesh2d {
            return _mesh;
        }
        
        public function get data():XML {
            return _data;
        }
        
        public function set data(value:XML):void {
            _data = value;
            var tempStr:String
            for each (var item:XML in value.mesh.vertex) {
                tempStr = String(item.@bone);
                if (tempStr != "") {
                    _vertecis[item.@id] = item.@bone;
                    bones[tempStr].addVertex(mesh.vertices[uint(item.@id)])
                } else {
                    _vertecis[item.@id] = 'root';
                }
            }
            
        }
        
        public function set bones(value:Object):void {
                _bones = value;
        }
        
        public function get bones():Object {
            return _bones;
        }
        

        //-----------------------------------------------------
        //IKBoneのドラッグでアーマチュアを動かす系
        //-----------------------------------------------------
        private function IKDrag(e:MouseEvent):void {
            if (startBone) {
                startBone.selectOff()
                startBone = null;
            }
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onIKDragMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onIKDragUp);
            dispatchEvent(new Event(MOUSE_DOWN));
        }
        
        private function onIKDragMove(e:MouseEvent):void {
            x = parent.mouseX;
            y = parent.mouseY;
            bones['root'].move();
            mesh.draw()
            mesh.lineDraw();
            dispatchEvent(new Event(MOUSE_MOVE));
        }
        
        private function onIKDragUp(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onIKDragMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onIKDragUp);
            dispatchEvent(new Event(MOUSE_UP));
        }
        
        //-----------------------------------------------------
        //IKBoneのドラッグでターゲットを動かすMouseEvent系
        //-----------------------------------------------------

        private function IKStart(e:MouseEvent):void {
            //MouseDownしたObject
            if (startBone) {
                startBone.selectOff()
            }
            startBone = e.target as IKBone2d
            startBone.selectOn()

            //startBoneからkeyBone（無い場合はroot）までのIKbonesを作成する
            if (tempVector) {
                for (i = 0; i < tempVector.length; i++ ) {
                    this.removeChild(tempVector[i])
                }
            }
            
            IKBones=new Array()
            tempVector=new Array()
            var tempBone:IKBone2d = startBone

            if(e.ctrlKey) {
                IKBones.push(tempBone)
            } else {

                while (true) {
                    if (tempBone) {
                        IKBones.push(tempBone)
                        if (tempBone.keyBone) {
                            break;
                        } else {
                            tempBone = tempBone.parentBone
                        }
                    } else {
                        break;
                    }
                }
            }
            
            var i:uint
            IKBones.reverse();
            for (i = 0; i < IKBones.length; i++ ) {
                IKBones[i].arrowVisible = true;
                tempVector[i] = new Arrow(false)
                this.addChild(tempVector[i])
            }

            oldPoint = newPoint;
            newPoint=new Point(mouseX,mouseY);
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            dispatchEvent(new Event(MOUSE_DOWN));
        }


        private function onMouseUp(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            var i:uint
            startBone.setDefaultLength()
            for (i=0; i < IKBones.length;i++ ) {
                IKBones[i].arrowVisible = false;
            }
            dispatchEvent(new Event(MOUSE_UP));
        }
    
        private function onMouseMove(e:MouseEvent):void {
            oldPoint = newPoint;
            newPoint=new Point(mouseX,mouseY);
            var startVector:Point=new Point((mouseX-startBone.boneTailPoint.x),(mouseY-startBone.boneTailPoint.y));
            var targetPoint:Point

            if (startBone.lock) {
            } else {
                for (var i:int = IKBones.length - 1; i >= 0; i-- ) {
                    if (IKBones[i].id!='root') {
                    //------------------------------------------
                    //新しいポイントにボーンを向ける
                    //------------------------------------------
                        setVector(tempVector[i], IKBones[i].boneTailPoint, newPoint)
                        tension(tempVector[i],IKBones[i]);
                        targetPoint = tempVector[i].vector.add(IKBones[i].boneTailPoint)
                        
                        lookAt(IKBones[i], targetPoint)

                    //------------------------------------------
                    //向けた方向でtailpointを取得、張力を再調査
                    //------------------------------------------
                        setVector(tempVector[i], IKBones[i].boneTailPoint, newPoint)
                        //本来戻るはずの位置（張力MAXの状態）で次のターゲットの位置を決めておく
                        newPoint = tempVector[i].vector.add(IKBones[i].point)
                        //張力を再調査
                        tension(tempVector[i],IKBones[i]);
                        //ボーンを一旦移動
                        if(i>0) {
                            IKBones[i].point = tempVector[i].vector.add(IKBones[i].point)
                        }
                    }
                }

                //------------------------------------------
                //ボーンの位置を修正する
                //------------------------------------------
                if (IKBones[0].id!='root') {
                    IKBones[0].move()
                } else {
                    IKBones[1].move()
                }
            }
            mesh.draw()
            mesh.lineDraw();
            
            dispatchEvent(new Event(MOUSE_MOVE));
        }

        private function tension($temp:Arrow,$bone:IKBone2d):void {
            //張力：Max:boneの長さ
            var t:Number = ($temp.length > $bone.length) ? $bone.length : $temp.length;
            $temp.length = t*0.1
        }

        private function setVector($v:Arrow, $active:Point,$target:Point=null ):void {
            var tempPoint:Point;
            if (!$target) {
                $target = new Point($active.x+$v.length,$active.y);
            }

            tempPoint = $target.subtract($active);
            $v.length = Point.distance($active, $target);
            $v.rotation = Math.atan2(tempPoint.y, tempPoint.x) * 180 / Math.PI;
            $v.x=$active.x
            $v.y=$active.y

        }

        private function lookAt($active:IKJoint2d,$target:Point):Boolean {
            //$active（ジョイント）を$targetへ向ける
            var nowPoint:Point;
            var targetPoint:Point;
            var tempPoint:Point;
            nowPoint = $active.point;
            targetPoint = new Point($target.x, $target.y);
            tempPoint = targetPoint.subtract(nowPoint);
            
            return $active.setAngle(Math.atan2(tempPoint.y, tempPoint.x) * 180 / Math.PI);
        }
        
        private function lookAtBone($active:IKBone2d,$target:Point):Boolean {
            //$active（ジョイント）を$targetへ向ける
            var nowPoint:Point;
            var targetPoint:Point;
            var tempPoint:Point;
            nowPoint = $active.point;
            targetPoint = new Point($target.x, $target.y);
            tempPoint = targetPoint.subtract(nowPoint);
            
            return $active.setAngle(Math.atan2(tempPoint.y, tempPoint.x) * 180 / Math.PI);
        }

        private function angle360(value:Number):Number {
            return (value + 360) % 360
        }
        
        private function degree(value:Number):Number {
            value += 180;
            value %= 360;
            value += 360;
            value %= 360;
            value -= 180;
            return value;
        }

        public function Trace(... arguments):void {
                //bg.appendText(arguments.toString()+"\n");
                //trace(arguments);
        }



    }


    //-----------------------------------------
    //Joint2d
    //-----------------------------------------
    //計算に必要な位置x,y、長さlength、ベクトルvectorPointと「制限角度」を持ったJoint
    //テスト用では、制限角度、ベクトルが描画される

    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Matrix;

    class IKJoint2d extends Sprite {
        
        private var _id:String;

        private var _length:Number;
        private var _arrow:Arrow;
        private var _test:Boolean;
        private var _visible:Boolean;
        private var _x:Number;
        private var _y:Number;

        //ジョイント（Sprite）自体は回転させない。
        //その為、回転は以下の変数で保持
        private var _rotation:Number;
        private var _rotationRange:Shape;
        
        private var _minRotation:Number;
        private var _maxRotation:Number;
        private var _lockPoint:int=-1;
        private var _lockRotation:String;

        public var _circle:Shape;

        public function IKJoint2d($visible:Boolean=false,$test:Boolean=true,$color:uint=0x6666666) {
            arrow = new Arrow(true, $color);
            arrow.name = 'arrow';
            arrowVisible = $visible
            
            if (id == 'root') {
                _circle = new Shape();
                _circle.graphics.beginFill(0x333399,0.5);
                _circle.graphics.drawCircle(0, 0, 10);
                addChild(_circle);
            } else {
                _circle = new Shape();
                _circle.graphics.beginFill(0xFFFFFF,1);
                _circle.graphics.drawCircle(0, 0, 2);
                addChild(_circle);
            }
            
            length = 0;
            _test = $test;
            _rotationRange = new Shape();
            _rotationRange.name = 'rotationRange';
            x=0
            y=0

        }
        

        //------------------------------------------------------------------------------
        //Setter Getter
        //------------------------------------------------------------------------------
            //-------------------------------------------------------
            //id
            //-------------------------------------------------------
                public function get id():String {
                    return _id;
                }
    
            
                public function set id(value:String):void {
                    _id = value;
                }


                override public function get y():Number {
                    return _y;
                }
                
                override public function set y(value:Number):void {
                    _y = value;
                    if (arrowVisible) {
                        super.y = _y;
                    }
                }

                override public function get x():Number {
                    return _x;
                }
                
                override public function set x(value:Number):void {
                    _x = value;
                    if (arrowVisible) {
                        super.x = _x;
                    }
                }

                public function get superX():Number {
                    return super.x;
                }
                
                public function set superX(value:Number):void {
                    super.x = value;
                }
                
                public function get superY():Number {
                    return super.y;
                }
                
                public function set superY(value:Number):void {
                    super.y = value;
                }

            //-----------------------------------------------------
            //テスト用Arrowの表示
            //-----------------------------------------------------
                public function set arrowVisible(value:Boolean):void {
                    _visible = value;
                    if (_visible) {
                        addChild(_rotationRange);
                        addChild(arrow);
                    } else {
                        if (this.getChildByName('arrow')) {
                            removeChild(_rotationRange);
                            removeChild(arrow);
                        }
                    }

                }

                public function get arrowVisible():Boolean {
                    return _visible;
                }


            //-------------------------------------------------------
            //clone
            //-------------------------------------------------------
                public function get clone():Object {
                    var result:Object = new Object();
                    result.vector2d=this.vector2d
                    result.minRotation = this.minRotation;
                    result.maxRotation = this.maxRotation;
                    result.superRotation = this.superRotation
                    result.id = this.id;
                    return result;
                }
                
                public function set clone(value:Object):void {
                    this.id = value.id;
                    this.vector2d = value.vector2d
                    this.superRotation=value.superRotation
                    this.setRotationRange(value.minRotation, value.maxRotation)
                }


            //-------------------------------------------------------
            //Point
            //-------------------------------------------------------
                public function get point():Point {
                    return new Point(x, y);
                }
                
                public function set point(value:Point):void {
                    x = value.x;
                    y = value.y;
                    
                }
        
            //-------------------------------------------------------
            //長さ
            //-------------------------------------------------------
                public function get length():Number {
                    return _length;
                }
                
                public function set length(value:Number):void {
                    _length = value;
                    if(arrow) {
                        arrow.length = value;
                    }
                }


            //-------------------------------------------------------
            //回転
            //rotationでは、Joint自体は回転しない
            //自身の回転は、親ボーンに依存する
            //強制的に回転させる場合は、superRotationを使用
            //-------------------------------------------------------
                override public function set rotation(value:Number):void {
                    _rotation = value
                }

                override public function get rotation():Number {
                    return _rotation
                }

                public function set superRotation(value:Number):void {
                    super.rotation = value
                }
                
                public function get superRotation():Number {
                    return super.rotation
                }
            

            //-------------------------------------------------
            //superRotationに依存しない角度の指定
            //依存する設定はvectorRotation
            //-------------------------------------------------
                public function setAngle(value:Number):Boolean {
                    return vectorRotation(value-superRotation)
                }


            //------------------------------------------------
            //ベクトル（Boneの終端）を返す
            //------------------------------------------------
                public function get tailPoint():Point {
                    //trace(id,'length=',length,'x=',int(x),'y=',int(y),'sR=',superRotation,'R=',rotation)
                    var result:Point = new Point(length,0);
                    var mtx:Matrix = new Matrix();
                    mtx.rotate(superRotation*Math.PI/180);
                    mtx.rotate(rotation*Math.PI/180);
                    mtx.translate(x, y);
                    result = mtx.transformPoint(result);
                    return result;
                }
                


            //------------------------------------------------
            //vector2d
            //------------------------------------------------
                public function get vector2d():Vector2d {
                    return new Vector2d(x, y, length, rotation);
                }

                public function set vector2d(value:Vector2d):void {
                    x = value.x;
                    y = value.y;
                    length = value.length;
                    rotation = value.rotation;
                }
            
            //------------------------------------------------
            //回転制限
            //------------------------------------------------
                public function get minRotation():Number {
                    return _minRotation;
                }
                
                public function set minRotation(value:Number):void {
                    _minRotation = value;
                }
                
                public function get maxRotation():Number {
                    return _maxRotation;
                }
                
                public function set maxRotation(value:Number):void {
                    _maxRotation = value;
                }


            //------------------------------------------------
            //矢印
            //------------------------------------------------
                public function get arrow():Arrow {
                    return _arrow;
                }
                
                public function set arrow(value:Arrow):void {
                    _arrow = value;
                }
                



        //------------------------------------------------------------------------------
        //publicメソッド
        //------------------------------------------------------------------------------
            //---------------------------------------------------
            //テスト用
            //---------------------------------------------------
                public function active():void {
                    _circle.graphics.clear()
                    if (id == 'root') {
                        _circle.graphics.beginFill(0xFF0000,0.5);
                        _circle.graphics.drawCircle(0, 0, 10);
                    } else {
                        _circle.graphics.beginFill(0xFF0000,1);
                        _circle.graphics.drawCircle(0, 0, 4);
                    }
                }
                
                public function normal():void {
                    _circle.graphics.clear()
                    if (id == 'root') {
                        _circle.graphics.beginFill(0x339933,0.5);
                        _circle.graphics.drawCircle(0, 0, 10);
                    } else {
                        _circle.graphics.beginFill(0x339933,1);
                        _circle.graphics.drawCircle(0, 0, 4);
                    }
                    
                }
            //-------------------------------------------------
            //操作
            //-------------------------------------------------
                //-------------------------------------------------
                //可動範囲を設定する
                //-------------------------------------------------
                public function setRotationRange($min:Number = -180, $max:Number = 180):void {
                    _minRotation = $min;
                    _maxRotation = $max;
                    if (_rotationRange) {
                        _rotationRange.graphics.clear();
                        _rotationRange.graphics.lineStyle(0, 0xFF0000);
                        _rotationRange.graphics.lineTo(Math.cos($min*Math.PI/180) * 20, Math.sin($min*Math.PI/180) * 20);
                        _rotationRange.graphics.lineStyle(0, 0x0000FF);
                        _rotationRange.graphics.moveTo(0, 0);
                        _rotationRange.graphics.lineTo(Math.cos($max * Math.PI / 180) * 20, Math.sin($max * Math.PI / 180) * 20);
                    }
                }
            

                //-------------------------------------------------
                //矢印を回転させる。
                //可動範囲を超えた場合は、可動範囲内でとどめ、falseを返す
                //-------------------------------------------------
                public function vectorRotation(value:Number):Boolean {
                    var result:Boolean = true;
                    //可動範囲の比較
                    if (degree(value) < _minRotation) {
                        arrow.rotation = _minRotation;
                        rotation=_minRotation
                        result = false;

                    } else if (degree(value) > _maxRotation) {
                        arrow.rotation = _maxRotation;
                        rotation=_maxRotation
                        result = false;

                    } else {
                        rotation = value
                        arrow.rotation = rotation;
                    }
                    
                    
                    
                    
                    
                    
                    return result
                }

            //-------------------------------------------------
            //角度を常に-180～180で返す
            //-------------------------------------------------
            public function degree(value:Number):Number {
                value += 180;
                value %= 360;
                value += 360;
                value %= 360;
                value -= 180;
                return value;
            }

        //------------------------------------------------------------------------------
        //privateメソッド
        //------------------------------------------------------------------------------
        
    }


    //-----------------------------------------
    //Bone2d
    //-----------------------------------------
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.*
    import flash.geom.Point;
    import flash.geom.Matrix;

    class IKBone2d extends IKJoint2d {
        public static const MOUSE_DOWN:String = 'mouse_down';
        public static const ROOT_DOWN:String = 'root_down';
        
        
        
        //new IKBone2d('ID名':String,長さ:Number,初期角度:Number,稼動範囲角度(負):Number,稼動範囲角度(正):Number,色)
        public function IKBone2d($id:String,$length:Number=100,$angle:Number=0,$minAngle:Number=-180,$maxAngle:Number=180,$key:Boolean=false,$color:uint=0x66FF66) {
            id = $id;
            childs = new Array();
            _vartices = new Array();

            super(false,true,$color);

            _sAngle=$angle
            _sMinAngle=$minAngle
            _sMaxAngle=$maxAngle

            if (id != 'root') {
                bone=new Bone(true,$color);
                addChild(bone);
                
                length = $length;
                addEventListener(MouseEvent.MOUSE_DOWN, clickBone);
                keyBone = $key;

                var format:TextFormat=new TextFormat();
                format.color=0x666666
                format.size=14;
                format.font='_ゴシック';
                
                _Label = new TextField();
                _Label.autoSize=TextFieldAutoSize.LEFT
                _Label.selectable = false;
                _Label.mouseEnabled = false;
                _Label.multiline = false;
                _Label.x=-5
                _Label.y=10

                _Label.defaultTextFormat=format
                //addChild(Label);
                _Label.text = id;
            } else {
                keyBone = true;
                addEventListener(MouseEvent.MOUSE_DOWN, clickRoot);
            }
            

            this.addChild(_circle)


            //trace(superRotation,rotation)
        }

        
        //------------------------------------------------------------------------------
        //publicメソッド
        //------------------------------------------------------------------------------
            //---------------------------------------------------
            //操作
            //---------------------------------------------------
                //------------------------------------------
                //BoneをMouseDownした時のArrowの長さを元に戻す
                //------------------------------------------
                public function setDefaultLength():void {
                    _clickLength=0
                    arrow.length=length;
                }

                //------------------------------------------
                //見た目を選択状態を元に戻す
                //------------------------------------------
                public function selectOff():void {
                    bone.selectOff()
                    for (var i:int = 0; i < _vartices.length; i++) {
                        _vartices[i] .vertex.draw(0x000066,true)
                    }
                }
                
                //------------------------------------------
                //見た目を選択状態にする
                //------------------------------------------
                public function selectOn():void {
                    bone.selectOn()
                    
                //関連づけられたVertexの色変え
                    for (var i:int = 0; i < _vartices.length; i++) {
                        _vartices[i] .vertex.draw(0xFF0000,true)
                    }
                }
                

                //-------------------------------------------------
                //角度設定はrotationやrotationXを使わずにこちらを使う
                //ただし、相対的な角度での設定になるため、見た目上での角度設定を行う場合は、
                //setDegreeSpecialやsetAngle使用
                //-------------------------------------------------
                public function setDegree(value:Number):Boolean {
                    return boneRotation(degree(value))
                }
                
                //-----------------------------------------------------------------------
                //設定の時など、y軸を中心に、左右対称に-180～180で角度を設定したい場合
                //-----------------------------------------------------------------------
                public function setDegreeSpecial(value:Number):Boolean {
                    return boneRotation(degree(value-90)-superRotation)
                }
                
                //-------------------------------------------------
                //superRotationに依存しない角度の指定
                //-------------------------------------------------
                override public function setAngle(value:Number):Boolean {
                    return boneRotation(value-superRotation)
                }
                
                //-------------------------------------------------
                //子のジョイントを登録する
                //-------------------------------------------------
                public function setChild(value:IKBone2d):void {
                    value.parentBone=this;
                    childs.push(value);
                }

                //-------------------------------------------------
                //矢印（ボーン）を回転させる。
                //可動範囲を超えた場合は、可動範囲内でとどめ、falseを返す
                //-------------------------------------------------
                public function boneRotation(value:Number):Boolean {
                    var result:Boolean
                    result = vectorRotation(value);

                    if (bone) {
                        bone.rotation=arrow.rotation
                    }
                    for (var i:uint = 0; i < childs.length; i++) {
                        childs[i].move()
                    }

                    return result;
                }
            

                //-------------------------------------------------
                //親が動いた時に、親から呼ばれる
                //-------------------------------------------------
                public function move():void {
                    if (parentBone) {
                        x = parentBone.tailPoint.x
                        y = parentBone.tailPoint.y
                        super.superX=x
                        super.superY=y
                        superRotation = parentBone.rotation + parentBone.superRotation;
                        _Label.rotation = -superRotation
                        if (!rotation) {
                            setRotationRange(_sMinAngle,_sMaxAngle)
                            setDegree(_sAngle);
                        }
                        bone.rotation = arrow.rotation


                    }
                    
                    var i:int
                    var pt1:Point;
                    var pt2:Point;
                    var mtx:Matrix;

                    for (i = 0; i < _vartices.length; i++) {
                        pt1 = new Point(x,y);
                        mtx = new Matrix();
                        mtx.rotate(ikArmature.rotation * Math.PI / 180);
                        mtx.translate(ikArmature.x, ikArmature.y);
                        pt1 = mtx.transformPoint(pt1);
                        pt2 = new Point(_vartices[i].defaultPoint.x, _vartices[i].defaultPoint.y)
                        mtx = new Matrix();
                        mtx.rotate(superRotation * Math.PI / 180);
                        mtx.rotate(rotation * Math.PI / 180);
                        mtx.translate(pt1.x, pt1.y);
                        pt2 = mtx.transformPoint(pt2);
                        _vartices[i].vertex.x = pt2.x
                        _vartices[i].vertex.y = pt2.y
                    }
                    
                    
                    for (i = 0; i < childs.length; i++) {
                        childs[i].move()
                    }
                }
        
                
                public function addVertex(value:Vertex2d):void {
                    var tempObject:Object = new Object();
                    tempObject.vertex = value;
                    
                    //defaultPointは、現時点でのBoneとの相対位置
                    //アーマチュアが回転している場合があるので、回転を戻しアーマチュアの座標を足した物が、canvasでの位置
                    
                    var i:int
                    var pt1:Point;
                    var pt2:Point;
                    var mtx:Matrix;
                    //配置点
                    pt1 = new Point(x,y);
                    mtx = new Matrix();
                    mtx.rotate(ikArmature.rotation * Math.PI / 180);
                    mtx.translate(ikArmature.x, ikArmature.y);
                    pt1 = mtx.transformPoint(pt1);
                    pt2 = new Point(value.x - pt1.x, value.y - pt1.y)
                    mtx = new Matrix();
                    mtx.rotate(-rotation * Math.PI / 180);
                    mtx.rotate(-superRotation * Math.PI / 180);
                    tempObject.defaultPoint = mtx.transformPoint(pt2);
                    _vartices[_vartices.length] = tempObject
                    
                }
                
                
        
        //------------------------------------------------------------------------------
        //Setter Getter
        //------------------------------------------------------------------------------
            //-------------------------------------------------------
            //
            //-------------------------------------------------------
                public function set parentBone(value:IKBone2d):void {
                    _parentBone = value;
                }

                public function get parentBone():IKBone2d {
                    return _parentBone;
                }

                public function get childs():Array {
                    return _childs;
                }
                
                public function set childs(value:Array):void {
                    _childs = value;
                }

                public function set bone(value:Bone):void {
                    _bone = value;
                }

                public function get bone():Bone {
                    return _bone;
                }

            //------------------------------------------------
            //ベクトル（Boneの終端）を返す
            //------------------------------------------------
                public function get boneTailPoint():Point {
                    var result:Point
                    if (_clickLength) {
                        result = new Point(_clickLength,0);
                    } else {
                        result = new Point(length,0);
                    }
                    var mtx:Matrix = new Matrix();
                    mtx.rotate(superRotation*Math.PI/180);
                    mtx.rotate(rotation*Math.PI/180);
                    mtx.translate(x, y);
                    result = mtx.transformPoint(result);
                    return result;
                }



            //-------------------------------------------------------
            //長さ
            //-------------------------------------------------------
                override public function set length(value:Number):void {
                    super.length = value;
                    if (bone) {
                        bone.length = value;
                    }
                    for (var i:uint = 0; i < childs.length; i++) {
                        childs[i].move()
                    }
                }




            //-------------------------------------------------------
            //clone
            //-------------------------------------------------------
                override public function get clone():Object {
                    var result:Object = super.clone
                    result.parentBone = parentBone;
                    result.childs = childs;

                    return result;
                }
                
                override public function set clone(value:Object):void {
                    super.clone = value;
                    this.parentBone = value.parentBone;
                    this.childs = value.childs;

                }

                
                
                public function get keyBone():Boolean {
                    return _keyBone;
                }
                
                public function set keyBone(value:Boolean):void {
                    _keyBone = value;
                    if (bone) {
                        if (_keyBone) {
                            active()
                        } else {
                            normal()
                        }
                    }

                }
                
                public function get ikArmature():IKArmature2d {
                    return _ikArmature;
                }
                
                public function set ikArmature(value:IKArmature2d):void {
                    _ikArmature = value;
                }
                
                public function get vartices():Array {
                    return _vartices;
                }
                
                public function set vartices(value:Array):void
                {
                    _vartices = value;
                }
                
                public function get lock():Boolean { return _lock; }
                
                public function set lock(value:Boolean):void
                {
                    _lock = value;
                }
    
        
        //------------------------------------------------------------------------------
        //privateメソッド
        //------------------------------------------------------------------------------
            private var _sAngle:Number
            private var _sMinAngle:Number
            private var _sMaxAngle:Number
            private var _parentBone:IKBone2d;
            private var _childs:Array;
            private var _clickLength:Number;
            private var _bone:Bone;
            private var _Label:TextField;
            private var _keyBone:Boolean=false
            private var _ikArmature:IKArmature2d
            private var _vartices:Array
            private var _lock:Boolean;
        
        
            private function clickBone(e:MouseEvent):void {
                _clickLength=bone.mouseX
                if (_clickLength < 20) {
                    _clickLength = 20;
                    if (_clickLength > length) {
                        _clickLength = length;
                    }
                }
                
                arrow.length=_clickLength;
                dispatchEvent(new MouseEvent(MOUSE_DOWN,true,false,NaN,NaN,null,e.ctrlKey));


                
            }

            private function clickRoot(e:MouseEvent):void {
                dispatchEvent(new MouseEvent(ROOT_DOWN));

            }




    }


    import flash.display.Sprite;

    class Bone extends Sprite {
        private const SELECT_COLOR:uint = 0x0000FF;
        
        private var _length:Number;
        private var _color:uint;
        private var _nowColor:uint;
        private var _test:Boolean;

        public function Bone($test:Boolean=true,$color:uint = 0x66FF66, $length:Number = 100) {

            _test=$test;
            _color = $color;
            length = $length;
            _nowColor = _color;
        }


        public function set length(value:Number):void {
            _length = value;
            makeBone()
        }

        public function selectOn():void {
            _nowColor = SELECT_COLOR;
            makeBone();
        }
        
        public function selectOff():void {
            _nowColor = _color;
            makeBone();
        }

        
        private function makeBone():void {
            if (_test) {
                //bone画像の生成
                graphics.clear();
                graphics.beginFill(_nowColor, 0.3);
                graphics.moveTo(0, 0);
                if (_length > 10) {
                    graphics.lineTo(5,-7);
                    graphics.lineTo(_length - 5,-2);
                    graphics.lineTo(_length,0);
                    graphics.lineTo(_length - 5,2);
                    graphics.lineTo(5,7);
                } else {
                    graphics.lineTo(_length / 2, -7);
                    graphics.lineTo(_length - 5,-2);
                    graphics.lineTo(_length - 5,2);
                    graphics.lineTo(_length / 2, 7);
                }
                graphics.endFill();
                graphics.beginFill(0xFFFFFF, 0);
                graphics.drawCircle(_length, 0, 4);
            }
        }




        public function get length():Number {
            return _length;
        }
        
    }





    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Matrix;
    
    class Arrow extends Shape {
        private var _length:Number;
        private var _defColor:Number
        private var _color:Number;
        private var _test:Boolean;
        public var _vector:Point
        
        public function Arrow($test:Boolean=true,$color:uint = 0x666666, $length:Number = 100) {
            _test=$test;
            _color = $color;
            _defColor = _color;
            length = $length;
        }

        public function changeColor():void {
            _color = 0xFF0000;
        }

        public function defColor():void {
            _color = _defColor;
        }


        public function set length(value:Number):void {
            _length = value;
            if (_test) {
                graphics.clear();
                graphics.beginFill(_color);
                graphics.moveTo(_length, 0);
                graphics.lineTo(_length - 10,-6);
                graphics.lineTo(_length - 10,6);
                graphics.lineTo(_length, 0);
                graphics.endFill();
                graphics.lineStyle(0, _color);
                graphics.lineTo(0, 0);
            }
        }
        
        public function get length():Number {
            return _length;
        }

        public function get vector():Point {
            var result:Point = new Point(_length,0);
            var mtx:Matrix = new Matrix();
            mtx.rotate(rotation*Math.PI/180);
            return mtx.transformPoint(result);
        }

        public function set point(value:Point):void {
            x=value.x
            y=value.y
        }

        public function get point():Point {
            return new Point(x,y);
        }

        
    }



    import flash.geom.Point;

    class Vector2d extends Object {
        private var _x:Number;
        private var _y:Number;
        private var _rotation:Number;
        private var _length:Number;

        public function Vector2d ($x:Number = 0, $y:Number = 0, $length:Number = 0, $rotation:Number = 0) {
            x = $x;
            y = $y;
            length = $length;
            rotation = $rotation;
            
        }

        public function get x():Number {
            return _x;
        }
        
        public function set x(value:Number):void {
            _x = value;
        }
        
        public function get y():Number {
            return _y;
        }
        
        public function set y(value:Number):void {
            _y = value;
        }
        
        public function get rotation():Number {
            return _rotation;
        }
        
        public function set rotation(value:Number):void {
            _rotation = value;
        }
        
        public function get length():Number {
            return _length;
        }
        
        public function set length(value:Number):void {
            _length = value;
        }
        
        public function get point():Point {
            return new Point(x,y)
        }

        public function set point(value:Point):void {
            x = value.x;
            y = value.y;
            
        }

    }







//===========================================================================================
//画像をメッシュ化するClass
//===========================================================================================
    import flash.display.BitmapData;
    import flash.display.LineScaleMode;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    class ImgMesh2d extends Sprite {
        public static const CLOSED:String = "closed";
        public static const TOP_LEFT:uint = 0;
        public static const TOP_CENTER:uint = 1;
        public static const TOP_RIGHT:uint = 2;
        public static const MIDDLE_LEFT:uint = 3;
        public static const MIDDLE_CENTER:uint = 4;
        public static const MIDDLE_RIGHT:uint = 5;
        public static const BOTTOM_LEFT:uint = 6;
        public static const BOTTOM_CENTER:uint = 7;
        public static const BOTTOM_RIGHT:uint = 8;

        //モード用
        public static const EDIT:String = "edit";
        public static const SET:String = "set";
        public static const LOCK:String = "lock";

        private var _polygons:Vector.<Polygon2d>;
        private var _vertices:Vector.<Vertex2d>;
        private var _lines:Vector.<Line2d>;
        
        private var _imageLayer:Sprite
        private var _vertexLayer:Sprite
        private var _lineLayer:Sprite
        private var _polygonLayer:Sprite
        private var _frameLayer:Sprite
        
        private var _closed:Boolean = false;
        private var _meshed:Boolean = false;

        private var _bitmapData:BitmapData;
        private var _uvtData:Vector.<Number>
        private var _verticesData:Vector.<Number>;
        
        private var _lineLock:Boolean = false;
        private var _lineOverId:int = -1;
        
        private var _dragPoint:Point;
        
        //自動Mesh生成での基準点
        private var _meshBaseMarker:Sprite;
        private var _meshBasePoint:uint = TOP_CENTER;
        private var _clickArea:Array
        
        private var _mode:String = EDIT;
        private var _ikArmature:IKArmature2d;
        
        public function ImgMesh2d() {
            
            //クリックしたところにPointを置いていく
            _imageLayer = new Sprite();
            _vertexLayer = new Sprite();
            _lineLayer = new Sprite();
            _polygonLayer = new Sprite();
            _frameLayer = new Sprite();
            this.addChild(_imageLayer);
            this.addChild(_polygonLayer);
            this.addChild(_lineLayer);
            this.addChild(_vertexLayer);
            this.addChild(_frameLayer);

            _polygonLayer.visible = false;
            
            _vertices = new Vector.<Vertex2d>();
            _lines = new Vector.<Line2d>();
            _polygons = new Vector.<Polygon2d>();
            this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
            
            makeBaseFrame();
        }
        

    //===========================================================================================
    //MouseEvent
    //===========================================================================================
        private function onAdded(e:Event):void {
            if (!_meshed) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            }
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
            stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp)
        }
        
        
        private function onKeyDown(e:KeyboardEvent):void {
            if (e.shiftKey) {
                _polygonLayer.visible = true;
                if (_mode==SET) {
                    _vertexLayer.visible = true;
                    _lineLayer.visible = true;
                }
            }

        }
        
        private function onKeyUp(e:KeyboardEvent):void {
            _polygonLayer.visible = false;
            if (_mode==SET) {
                _vertexLayer.visible = false;
                _lineLayer.visible = false;
            }
        }
        
        private function onMouseMove(e:MouseEvent):void {
            if (_mode==SET) {
            } else if (_mode == EDIT) {
                if (_meshed) {
                    x=stage.mouseX-parent.x-_dragPoint.x
                    y=stage.mouseY-parent.y-_dragPoint.y
                } else if (_closed) {
                } else {
                    drawLine(mouseX, mouseY)
                }
            }
        }

        
        private function onMouseUp(e:MouseEvent):void {
            if (_mode==SET) {

            } else if(_mode==EDIT) {
                if (_meshed) {
                    stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                    stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
                    _imageLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
                }
            }
        }
        
        
        private function onMouseDown(e:MouseEvent):void {
            var no:uint;
            var i:uint;
            if (_mode == SET) {
                if (e.shiftKey) {
                    //シフトキーが押されていたらボーンに追加
                    if (_lineOverId >= 0) {
                    } else {
                        if (e.target.hasOwnProperty('type')) {
                            if (e.target.type == 'vertex') {
                                trace(e.target.id)
                                no = e.target.id;
                                _vertices[no].bone=ikArmature.setVertex(no);
                            } else if (e.target.type == 'polygon') {
                                trace(e.target.id)
                            }
                        }
                    }
                }
            } else if(_mode==EDIT) {
                if (_meshed) {
                    _imageLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
                    stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                    stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
                    _dragPoint = new Point(mouseX, mouseY);
                } else if (_closed) {
                    //line上の場合は、Pointの追加
                    if (_lineOverId>=0) {
                        _vertices.splice(_lineOverId + 1, 0, new Vertex2d(_lineOverId + 1, mouseX, mouseY));
                        _vertexLayer.addChild(_vertices[_lineOverId + 1])
                        //追加した、以降のIDふりなおし、
                        no = _lines.length;
                        _lines[no] = new Line2d();
                        _lineLayer.addChild(_lines[no]);
                        for (i = 0; i < _vertices.length; i++) {
                            _vertices[i].id = i;
                            if (i == _vertices.length - 1) {
                                _lines[i].setVertices(i, _vertices[i], _vertices[0]);
                            } else {
                                _lines[i].setVertices(i, _vertices[i], _vertices[i + 1]);
                            }
                        }
                    } else if (e.shiftKey) {
                        //シフトキーが押されていたら削除
                        if (e.target.hasOwnProperty('type')) {
                            if (e.target.type=='vertex') {
                                no = e.target.id;
                                _vertices[no].destroy();
                                _vertexLayer.removeChild(_vertices[no]);
                                _vertices[no] = null;
                                _vertices.splice(no, 1);

                                //追加した、以降のIDふりなおし、
                                no = _lines.length - 1;
                                _lines[no].destroy();
                                _lineLayer.removeChild(_lines[no]);
                                _lines[no] = null;
                                _lines.splice(no, 1);

                                for (i = 0; i < _vertices.length; i++) {
                                    _vertices[i].id = i;
                                    if (i == _vertices.length - 1) {
                                        _lines[i].setVertices(i, _vertices[i], _vertices[0]);
                                    } else {
                                        _lines[i].setVertices(i, _vertices[i], _vertices[i + 1]);
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (_vertices.length && _vertices[0].overFlag) {
                        //閉じる
                        stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)

                        no = _lines.length;
                        _lines[no] = new Line2d();
                        _lines[no].setVertices(no, _vertices[no], _vertices[0]);
                        _lineLayer.addChild(_lines[no]);
                        graphics.clear();
                        _closed = true;
                        
                        setBaseFrame()

                        dispatchEvent(new Event(CLOSED));
                    } else {
                        no = _vertices.length;
                    
                        _vertices[no] = new Vertex2d(no, mouseX, mouseY);
                        _vertexLayer.addChild(_vertices[no]);
                        if (_vertices.length > 1) {
                            no = _lines.length;
                            _lines[no] = new Line2d();
                            _lines[no].setVertices(no, _vertices[no], _vertices[no + 1]);
                            _lineLayer.addChild(_lines[no]);
                        }
                    }
                }
            }
        }



    //===========================================================================================
    //public
    //===========================================================================================
        //-----------------------------------------------
        //書き出し
        //-----------------------------------------------
        public function outputVertices():XML {
            var result:XML=<mesh>
            </mesh>
            result.@meshBasePoint=_meshBasePoint
            
            var tempXML:XML
            var i:uint
            for (i = 0; i < _vertices.length; i++) {
                tempXML=<vertex>
                </vertex>
                tempXML.@id=_vertices[i].id
                tempXML.@x=_vertices[i].x
                tempXML.@y = _vertices[i].y
                if (_vertices[i].bone) {
                    tempXML.@bone = _vertices[i].bone
                }
                result.data[i]=tempXML
            }

            for (i = 0; i < _polygons.length; i++) {
                tempXML =<polygon>
                </polygon>
                tempXML.@id = _polygons[i].id;
                tempXML.@p1 = _polygons[i].p1.id;
                tempXML.@p2 = _polygons[i].p2.id;
                tempXML.@p3 = _polygons[i].p3.id;
                result.data[i]=tempXML
            }
            
            
            return result;
        }
        
        
        
    
        //-----------------------------------------------
        //削除
        //-----------------------------------------------
        public function destroy():void {
            _imageLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp)
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown)
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)
            
            var i:uint
            for (i = 0; i < _polygons.length; i++) {
                _polygons[i].destroy()
                _polygonLayer.removeChild(_polygons[i]);
                _polygons[i] = null;
            }
            _polygons = null;
            for (i = 0; i < _lines.length; i++) {
                _lines[i].destroy()
                _lineLayer.removeChild(_lines[i]);
                _lines[i] = null;
            }
            _lines = null;

            for (i = 0; i < _vertices.length; i++) {
                _vertices[i].destroy()
                _vertexLayer.removeChild(_vertices[i]);
                _vertices[i] = null;
            }
            _vertices=null;

            for (i = 0; i < 9; i++) {
                _frameLayer.removeChild(_clickArea[i]);
                _clickArea[i].removeEventListener(MouseEvent.CLICK,baseChange)
                _clickArea[i] = null;
            }
            _clickArea = null;
            
            _imageLayer.graphics.clear();
            _frameLayer.graphics.clear();
            
        }

        //-----------------------------------------------
        //Mesh削除
        //-----------------------------------------------
        public function clearMesh($visible:Boolean=false):void {
            var i:uint
            for (i = 0; i < _polygons.length; i++) {
                _polygons[i].destroy()
                _polygonLayer.removeChild(_polygons[i]);
                _polygons[i] = null;
            }
            _polygons = new Vector.<Polygon2d>();
            _meshed = false;
            _imageLayer.graphics.clear();
            if ($visible) {
                _imageLayer.graphics.clear();
                _imageLayer.graphics.beginBitmapFill(_bitmapData,null,false,true);
                _imageLayer.graphics.drawRect(0,0,_bitmapData.width,_bitmapData.height)
                _imageLayer.graphics.endFill()
            }
            
            _imageLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            _frameLayer.visible = true;
        }
        
        
        //-----------------------------------------------
        //Mesh作成
        //-----------------------------------------------
        public function makeMesh($visible:Boolean=false):void {
        
            //頂点情報のclone
            var tempVerties:Vector.<Vertex2d> = _vertices.slice(0);
            var maxLength:Number = 0;
            var tempLength:Number = 0;
            var maxVertex:Vertex2d;
            var maxId:int = -1;
            
            var sA:Vertex2d;
            var sB:Vertex2d;
            var sC:Vertex2d;
            var sP:Vertex2d;
            var oldCross:int=-2;
            var newCross:int=-2;

            //基準点
            var basePoint:Point
            basePoint=new Point(_meshBaseMarker.x,_meshBaseMarker.y);

            while (tempVerties.length > 2) {
                maxLength = 0;
                tempLength = 0;
                maxVertex=null;
                maxId = -1;
            
                sA=null;
                sB=null;
                sC=null;
                sP=null;
                oldCross=-2;
                newCross=0;
                var i:int

                for (i = 0; i < tempVerties.length; i++) {
                    //中心点,0から各頂点への長さを求める
                    tempLength = Point.distance(basePoint, tempVerties[i].point);
                    if (maxLength < tempLength) {
                        maxLength = tempLength;
                        maxVertex = _vertices[i]
                        maxId = i;
                    }
                }
                var counter:uint=0
                while (counter<tempVerties.length) {
                    if (maxId>-1) {
                        if (maxId == 0) {
                            //三角形用の頂点
                            sA = tempVerties[tempVerties.length - 1]
                            sB = tempVerties[maxId];
                            sC = tempVerties[maxId + 1]
                        } else if (maxId == tempVerties.length - 1) {
                            sA = tempVerties[maxId - 1];
                            sB = tempVerties[maxId];
                            sC = tempVerties[0];
                        } else {
                            sA = tempVerties[maxId - 1];
                            sB = tempVerties[maxId];
                            sC = tempVerties[maxId + 1];
                        }
                    
                        //内包する頂点が無いかのチェック
                        var inDelta:Boolean=false;
                        for (i = 0; i < tempVerties.length; i++) {
                            if (tempVerties[i] != sA && tempVerties[i] != sB && tempVerties[i] != sC) {
                                if (InDeltaCheck(sA.point, sB.point, sC.point, tempVerties[i].point)) {
                                    inDelta = true;
                                    break
                                }
                            }
                        }
                        newCross = crossCheck(sB.point.subtract(sA.point), sB.point.subtract(sC.point));
                        if (!inDelta && (oldCross==-2 || oldCross==newCross)) {
                            //内包する点は無い
                            //三角を形成して、頂点を削除
                            _polygons[_polygons.length] = new Polygon2d(_polygons.length,sA, sB, sC);
                            _polygonLayer.addChild(_polygons[_polygons.length-1])
                            tempVerties.splice(maxId, 1);

                            break;
                        } else {
                            //sBからsAへのベクトルとsBからsCへのベクトルの外積を取って保管
                            if (oldCross==-2) {
                                oldCross = crossCheck(sB.point.subtract(sA.point), sB.point.subtract(sC.point))
                            }
                            if (maxId==0) {
                                maxId=tempVerties.length-1
                            } else {
                                maxId--;
                            }
                            counter++;
                        }
                    }
                }
            }
        
            //------------------------------------
            //uvtDataの作成
            //------------------------------------
            if (_bitmapData) {
                _uvtData = new Vector.<Number>();
                for (i = 0; i < _vertices.length; i++) {
                    _uvtData[_uvtData.length] = _vertices[i].x / _bitmapData.width
                    _uvtData[_uvtData.length] = _vertices[i].y / _bitmapData.height
                }
            }
            _meshed = true;
            draw();
            
            _imageLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            _frameLayer.visible=$visible
        }
        

        public function outlineEdit():void {
            _mode = EDIT
            clearMesh(true);
            _vertexLayer.visible = true;
            _lineLayer.visible = true;
        }
        
        public function outlineSet():void {
            _mode = SET
            makeMesh()
            _vertexLayer.visible = false;
            _lineLayer.visible = false;
        }
        
        
        //-----------------------------------------------
        //vertexが動いた時にvertexから呼ばれる命令
        //-----------------------------------------------
        public function vertexMove($id:uint):void {
            if ($id == 0) {
                _lines[_lines.length-1].draw()
                _lines[$id].draw()
            } else {
                _lines[$id-1].draw()
                _lines[$id].draw()
            }
            draw();
        }


    //===========================================================================================
    //private
    //===========================================================================================
        private function drawLine($x:Number, $y:Number):void {
            if (_vertices.length) {
                graphics.clear();
                graphics.lineStyle(0, 0xCC0000);
                graphics.moveTo(_vertices[_vertices.length - 1].x, _vertices[_vertices.length - 1].y)
                graphics.lineTo($x, $y)
            }
        }
        
        
        private function crossCheck($p1:Point, $p2:Point):int {
            var result:int = 0;
            var cross:Number=(($p1.x * $p2.y) - ($p1.y * $p2.x))
            if (cross < 0) {
                result = -1;
            } else if (cross > 0) {
                result = 1;
            }
            return result;
        }

        private function distance($p1:Point,$p2:Point,$p3:Point):Number {
            var vX:Number=$p1.x -$p2.x;
            var vY:Number=$p1.y -$p2.y;
            return (vY*$p3.x-vX*$p3.y+vX*$p1.y-vY*$p1.x)/Math.sqrt(Math.pow(vX,2)+Math.pow(vY,2));
        }


        private function isSide($p1:Point,$p2:Point,$p3:Point,$p4:Point):Boolean {
            return ((distance($p1,$p2,$p3)*distance($p1,$p2,$p4)) >= 0);
        }

        private function InDeltaCheck($p1:Point,$p2:Point,$p3:Point,$p4:Point):Boolean {
            return isSide($p1,$p2,$p3,$p4) && isSide($p2,$p3,$p1,$p4) && isSide($p3,$p1,$p2,$p4)
        }
        
        
        //---------------------------------------------------
        //関連付けられたBitmapDataをdrawTrianglesで描写する。
        //---------------------------------------------------
        public function draw():void {

            if (_meshed) {
                _verticesData = new Vector.<Number>();
                var i:uint;
                for (i = 0; i < _vertices.length; i++) {
                    _verticesData[_verticesData.length] = _vertices[i].x
                    _verticesData[_verticesData.length] = _vertices[i].y

                }
                var _indicesData:Vector.<int> = new Vector.<int>();
                for (i = 0; i < _polygons.length; i++) {
                    _indicesData[_indicesData.length] = _polygons[i].p1.id;
                    _indicesData[_indicesData.length] = _polygons[i].p2.id;
                    _indicesData[_indicesData.length] = _polygons[i].p3.id;
                    
                    _polygons[i].draw()
                }
                _imageLayer.graphics.clear();
                _imageLayer.graphics.beginBitmapFill(_bitmapData,null,false,true);
                _imageLayer.graphics.drawTriangles(_verticesData, _indicesData, _uvtData);
                _imageLayer.graphics.endFill()
            }
            
            
            
        }
        
        
        public function lineDraw():void {
            for (var i:int = 0; i < _lines.length; i++)
            {
                _lines[i].draw()
            }
        }
        
        //---------------------------------------------------
        //メッシュ化基準点UI
        //9つの基準点を選択できるようにする
        //---------------------------------------------------
        private function makeBaseFrame():void {
            _clickArea = [];
            for (var i:int=0;i<9;i++) {
                _clickArea[i] = new Sprite();
                _clickArea[i].graphics.beginFill(0x0,0.1)
                _clickArea[i].graphics.drawCircle(0,0,4)
                _frameLayer.addChild(_clickArea[i]);
                _clickArea[i].addEventListener(MouseEvent.CLICK,baseChange)

            }
            _meshBaseMarker  = new Sprite();
            _meshBaseMarker.graphics.beginFill(0xFF8800, 1);
            _meshBaseMarker.graphics.drawCircle(0, 0, 4);
            _frameLayer.addChild(_meshBaseMarker);
            _frameLayer.visible=false
        }

        private function setBaseFrame($visible:Boolean=true):void {
            var basePoint:Point
            
            var rect:Rectangle = _vertexLayer.getBounds(this)
            rect.x -= 10
            rect.y -= 10
            rect.width += 20
            rect.height += 20
            
            _frameLayer.graphics.clear();
            _frameLayer.graphics.lineStyle(0,0x000000,0.1,true,LineScaleMode.NONE)
            _frameLayer.graphics.drawRect(rect.x,rect.y,rect.width,rect.height)
            
            for (var i:int=0;i<9;i++) {
                switch (i) {
                    case 0:
                        basePoint=new Point(rect.x,rect.y);
                        break;
                    case 1:
                        basePoint=new Point(rect.x+rect.width/2,rect.y);
                        break;
                    case 2:
                        basePoint=new Point(rect.x+rect.width,rect.y);
                        break;
                    case 3:
                        basePoint=new Point(rect.x,rect.y+rect.height/2);
                        break;
                    case 4:
                        basePoint=new Point(rect.x+rect.width/2,rect.y+rect.height/2);
                        break;
                    case 5:
                        basePoint=new Point(rect.x+rect.width,rect.y+rect.height/2);
                        break;
                    case 6:
                        basePoint=new Point(rect.x,rect.y+rect.height);
                        break;
                    case 7:
                        basePoint=new Point(rect.x+rect.width/2,rect.y+rect.height);
                        break;
                    case 8:
                        basePoint=new Point(rect.x+rect.width,rect.y+rect.height);
                        break;
                }
                _clickArea[i].x=basePoint.x
                _clickArea[i].y=basePoint.y
            }
            _frameLayer.visible = $visible
            setBasePoint()
        }
        
        private function baseChange(e:MouseEvent):void {
            for (var i:int=0;i<9;i++) {
                if (e.target == _clickArea[i]) {
                    _meshBasePoint=i
                    break;
                }
            }
            setBasePoint()
        }
        
        private function setBasePoint():void {
            _meshBaseMarker.x=_clickArea[_meshBasePoint].x
            _meshBaseMarker.y=_clickArea[_meshBasePoint].y;
        }



    //===========================================================================================
    //Setter&Getter
    //===========================================================================================
        public function get bitmapData():BitmapData {
            return _bitmapData;
        }
        
        public function set bitmapData(value:BitmapData):void {
            _bitmapData = value;
        }
        
        public function get lineLock():Boolean {
            return _lineLock;
        }
        
        public function set lineLock(value:Boolean):void {
            _lineLock = value;
        }
        
        public function get lineOverId():int {
            return _lineOverId;
        }
        
        public function set lineOverId(value:int):void {
            _lineOverId = value;
        }
        
        public function get mode():String {
            return _mode;
        }
        
        public function set mode(value:String):void {
            _mode = value;
        }
        
        public function get vertices():Vector.<Vertex2d> {
            return _vertices;
        }
        
        public function set vertices(value:Vector.<Vertex2d>):void {
            _vertices = value;
        }
        
        
        //------------------------------------------
        //XMLデータ
        //------------------------------------------
        public function set data(value:XML):void {
            var i:uint;
            var no:uint;
            _meshBasePoint = uint(value.mesh.@meshBasePoint);
            for each (var item:XML in value.mesh.vertex) {
                _vertices[uint(item.@id)] = new Vertex2d(uint(item.@id), Number(item.@x), Number(item.@y));
                _vertices[uint(item.@id)].bone = String(item.@bone)
                _vertexLayer.addChild(_vertices[uint(item.@id)])
                no = _lines.length;
                _lines[no] = new Line2d();
                _lineLayer.addChild(_lines[no]);
            }

            for (i = 0; i < _vertices.length; i++) {
                if (i == _vertices.length - 1) {
                    _lines[i].setVertices(i, _vertices[i], _vertices[0]);
                } else {
                    _lines[i].setVertices(i, _vertices[i], _vertices[i + 1]);
                }
            }
            

            _closed = true;
            setBaseFrame();
            _mode = SET;
            makeMesh();
            
        
            _vertexLayer.visible = false;
            _lineLayer.visible = false;
            
        }
        
        public function get ikArmature():IKArmature2d {
            return _ikArmature;
        }
        
        public function set ikArmature(value:IKArmature2d):void {
            _ikArmature = value;
        }
        
        
    }


//===========================================================================================
//頂点クラス
//===========================================================================================
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Point;
    
    class Vertex2d extends Sprite {
        public static const MOVE:String = "move";
        public var overFlag:Boolean = false

        private var _id:uint;
        private var _defColor:uint;
        private var _pmc:ImgMesh2d;
        private var _size:Number;
        private var _bone:String
        private const _type:String="vertex";
        
        public function Vertex2d($id:uint, $x:Number, $y:Number,$size:Number=4, $color:uint=0x000066) {
            id = $id;
            this.x = $x;
            this.y = $y;
            _defColor=$color
            _size=$size;

            draw()
            this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown)
            this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
            this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
            this.addEventListener(Event.ADDED_TO_STAGE,onAdded)
        }

        
        private function onAdded(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE,onAdded)
            _pmc = this.parent.parent as ImgMesh2d;
        }
        
        private function onMouseOver(e:MouseEvent):void {
            draw(0xFF0000)
            overFlag=true
        }
        
        private function onMouseOut(e:MouseEvent):void {
            draw()
            overFlag=false
        }

        
        private function onMouseDown(e:MouseEvent):void {
            if (_pmc.mode==ImgMesh2d.EDIT) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove)
            }
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
            _pmc.lineLock = true;
        }

        private function onMouseMove(e:MouseEvent):void {
            x = _pmc.mouseX
            y = _pmc.mouseY

            _pmc.vertexMove(id)
            dispatchEvent(new Event(MOVE));
        }

        private function onMouseUp(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp)
            _pmc.lineLock = false;
        }

        public function draw($color:uint = 0,$lock:Boolean=false):void {
            if (!$color) {
                $color=_defColor
            }
            if ($lock) {
                _defColor = $color;
            }
            graphics.clear();
            graphics.beginFill($color)
            graphics.drawCircle(0,0,_size);
        }

        public function destroy():void {
            this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown)
            this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
            this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove)
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp)
        }
        
        
        public function get point():Point {
            return new Point(x,y)
        }
        
        public function get id():uint { return _id; }
        
        public function set id(value:uint):void
        {
            _id = value;
        }
        
        public function get bone():String { return _bone; }
        
        public function set bone(value:String):void
        {
            _bone = value;
        }
        
        public function get type():String { return _type; }

    }

//===========================================================================================
//ラインクラス
//===========================================================================================
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Point;
    
    class Line2d extends Sprite {
        public var overFlag:Boolean = false
        private var _id:uint;
        private var _v1:Vertex2d;
        private var _v2:Vertex2d;
        private var _pmc:ImgMesh2d;
        private var _defColor:uint=0x009900;
        private const _type:String="line";

        public function Line2d() {
            this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
            this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut)
            this.addEventListener(Event.ADDED_TO_STAGE,onAdded)
        }

        public function destroy():void {
            this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver)
            this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
        }
        
        private function onAdded(e:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE,onAdded)
            _pmc = this.parent.parent as ImgMesh2d;
        }
        
        public function setVertices($id:uint, $v1:Vertex2d, $v2:Vertex2d):void {
            _id = $id;
            _v1 = $v1;
            _v2 = $v2;
            draw();
        }
        
        public function draw($color:uint = 0):void {
            if (!$color) {
                $color=_defColor
            }
            graphics.clear()
            graphics.lineStyle(5, 0xFF0000,0);
            graphics.moveTo(_v1.x, _v1.y);
            graphics.lineTo(_v2.x, _v2.y);
            graphics.lineStyle(0, $color);
            graphics.moveTo(_v1.x, _v1.y);
            graphics.lineTo(_v2.x, _v2.y);
        }
        
        private function onMouseOver(e:MouseEvent):void {
            if (!_pmc.lineLock) {
                draw(0xFF0000)
                overFlag = true
                _pmc.lineOverId = _id;
            }
        }
        
        private function onMouseOut(e:MouseEvent):void {
            if (!_pmc.lineLock) {
                draw()
                overFlag = false
                _pmc.lineOverId = -1;
            }
        }
        
        public function get type():String { return _type; }
        
    }


//===========================================================================================
//ポリゴンクラス
//===========================================================================================

    import flash.display.Sprite;
    import flash.events.Event;

    class Polygon2d extends Sprite {
        private var _p1:Vertex2d
        private var _p2:Vertex2d
        private var _p3:Vertex2d
        private var _id:uint;
        private const _type:String="polygon";

        public function Polygon2d($id:uint, $p1:Vertex2d, $p2:Vertex2d, $p3:Vertex2d) {
            _id = $id;
            _p1 = $p1;
            _p2 = $p2;
            _p3 = $p3;

            _p1.addEventListener(Vertex2d.MOVE, draw);
            _p2.addEventListener(Vertex2d.MOVE, draw);
            _p3.addEventListener(Vertex2d.MOVE, draw);
            
            draw()
        }

        //-------------------------------------
        //テスト用三角の描画
        //-------------------------------------
        public function draw(e:Event=null):void {
            graphics.clear()
            graphics.lineStyle(0, 0x000000);
            graphics.beginFill(0x00FF00,0.1)
            graphics.moveTo(_p1.x, _p1.y);
            graphics.lineTo(_p2.x, _p2.y);
            graphics.lineTo(_p3.x, _p3.y);
            graphics.lineTo(_p1.x, _p1.y);
        }
        
        public function destroy():void {
            _p1.removeEventListener(Vertex2d.MOVE, draw);
            _p2.removeEventListener(Vertex2d.MOVE, draw);
            _p3.removeEventListener(Vertex2d.MOVE, draw);
            
        }
        
        public function get p1():Vertex2d { return _p1; }
        
        public function set p1(value:Vertex2d):void
        {
            _p1 = value;
        }
        
        public function get p2():Vertex2d { return _p2; }
        
        public function set p2(value:Vertex2d):void
        {
            _p2 = value;
        }
        
        public function get p3():Vertex2d { return _p3; }
        
        public function set p3(value:Vertex2d):void
        {
            _p3 = value;
        }
        
        public function get id():uint { return _id; }
        
        public function set id(value:uint):void
        {
            _id = value;
        }
        
        public function get type():String { return _type; }
        

    }



//===========================================================================================
//データクラス
//===========================================================================================

//-------------------------------------------------------
//Mesh&IKデータ
//-------------------------------------------------------

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;

    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.system.System;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.IOErrorEvent;


    import Main

    class ImgAndBone extends Sprite {
        public static const LOADED:String = 'loaded';
        
        public var _ika:IKArmature2d;
        public var _imgArea:Bitmap;
        
        public var _imgLoader:Loader
        private var _mesh:ImgMesh2d;
        public var _bmd:BitmapData;
        
        public var _data:XML;
        
        public function ImgAndBone() {
            _bmd = new BitmapData(100,100, true, 0x00000000);
            _imgArea = new Bitmap(_bmd)
            _mesh = new ImgMesh2d();
            //addChild(_imgArea)

        }
        
        
        //------------------------------------------------
        //画像の読み込み
        //------------------------------------------------
        public function imgLoad(url:String):void {

            if (_imgLoader) {
                _imgLoader.unload();
            }
            _imgLoader = new Loader();

            var urlReq:URLRequest=new URLRequest(url);
            var context :LoaderContext = new LoaderContext();
            context.applicationDomain = ApplicationDomain.currentDomain;
            //imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);

            _imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onImageIoerror);
            _imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImageLoaded)
            _imgLoader.load(urlReq, context);
            
        }

        private function onImageLoaded(e:Event):void {
            _bmd = new BitmapData(_imgLoader.width,_imgLoader.height, true, 0x00000000);
            _bmd.draw(_imgLoader, null, null, null, null, true);
            _imgArea.bitmapData = _bmd;
            _mesh.bitmapData = _bmd;
            _mesh.data = _data;
            _mesh.ikArmature = _ika;
            _ika.mesh = _mesh;
            _ika.data = _data;
            
            addChildAt(_mesh,0);
            dispatchEvent(new Event(LOADED));
        }
        
        private function onImageIoerror(e:IOErrorEvent):void {
            var _parent:Main = parent.parent as Main;
            var _alert:AlertPanel = _parent.alert;
            _alert.setText(e.text);
            _alert.addEventListener(myWindow.CLOSE, alertClose);
            function alertClose(e:Event):void {
                _alert.removeEventListener(myWindow.CLOSE, alertClose);
            }
        }
        
        public function outlineSet():void {
            _mesh.outlineSet()
        }
        
        public function outlineEdit():void {
            _mesh.outlineEdit()
        }
        
        
        public function get data():XML {
            return _data;
        }
        
        public function get ikArmature():IKArmature2d {
            return _ika;
        }
        
        public function get img():Bitmap {
            return _imgArea;
        }
        
        public function get mesh():ImgMesh2d { return _mesh; }
        
        public function set mesh(value:ImgMesh2d):void
        {
            _mesh = value;
        }
        
            
    }




//-------------------------------------------------------
//いるか用Mesh&IKデータ
//-------------------------------------------------------

    class Dolphin extends ImgAndBone {

        public function Dolphin() {
        
            

            //---------------------------------
            //Sample画像の読み込み
            //---------------------------------
            imgLoad('http://marubayashi.net/archive/sample/imagemesh/dolphin2.jpg');

            _ika = new IKArmature2d();
            _ika.setBone(new IKBone2d('tail1', 60, 94,90,120));
            _ika.setBone(new IKBone2d('tail2', 55, 1.79, -20, 40));
            _ika.setBone(new IKBone2d('tail3', 40, 0.50, -30, 30));
            _ika.setBone(new IKBone2d('tail4', 60, -2.28, -30, 18));
            _ika.setBone(new IKBone2d('body', 100,-80, -100,-70));
            _ika.setBone(new IKBone2d('neck', 40, -5.90, -10, 10));
            _ika.setBone(new IKBone2d('head', 80, -10, -20, 5));
        
            _ika.joint('root', 'body');
            _ika.joint('body','neck');
            _ika.joint('neck', 'head');

            _ika.joint('root', 'tail1');
            _ika.joint('tail1', 'tail2');
            _ika.joint('tail2', 'tail3');
            _ika.joint('tail3', 'tail4');
            _ika.x = 220
            _ika.y = 170
            _ika.rotation=0
            _ika.init();
            
            
            _data=<date>
                <mesh meshBasePoint="4" id="0">
                    <vertex id="0" x="173" y="117" bone="body"/>
                    <vertex id="1" x="189" y="89" bone="body"/>
                    <vertex id="2" x="219" y="74" bone="body"/>
                    <vertex id="3" x="250" y="69" bone="body"/>
                    <vertex id="4" x="262" y="79" bone="body"/>
                    <vertex id="5" x="257" y="91" bone="body"/>
                    <vertex id="6" x="244" y="99" bone="body"/>
                    <vertex id="7" x="234" y="121" bone="body"/>
                    <vertex id="8" x="256" y="128" bone="tail1"/>
                    <vertex id="9" x="276" y="135" bone="tail1"/>
                    <vertex id="10" x="297" y="143" bone="tail2"/>
                    <vertex id="11" x="317" y="150" bone="tail2"/>
                    <vertex id="12" x="334" y="156" bone="tail2"/>
                    <vertex id="13" x="352" y="162" bone="tail3"/>
                    <vertex id="14" x="371" y="165" bone="tail3"/>
                    <vertex id="15" x="379" y="165" bone="tail4"/>
                    <vertex id="16" x="396" y="156" bone="tail4"/>
                    <vertex id="17" x="422" y="152" bone="tail4"/>
                    <vertex id="18" x="442" y="160" bone="tail4"/>
                    <vertex id="19" x="424" y="184" bone="tail4"/>
                    <vertex id="20" x="437" y="224" bone="tail4"/>
                    <vertex id="21" x="410" y="221" bone="tail4"/>
                    <vertex id="22" x="394" y="214" bone="tail4"/>
                    <vertex id="23" x="371" y="195" bone="tail4"/>
                    <vertex id="24" x="352" y="199" bone="tail3"/>
                    <vertex id="25" x="333" y="202" bone="tail2"/>
                    <vertex id="26" x="312" y="205" bone="tail2"/>
                    <vertex id="27" x="292" y="206" bone="tail2"/>
                    <vertex id="28" x="273" y="208" bone="tail1"/>
                    <vertex id="29" x="254" y="209" bone="tail1"/>
                    <vertex id="30" x="234" y="210" bone="tail1"/>
                    <vertex id="31" x="188" y="213" bone="body"/>
                    <vertex id="32" x="188" y="251" bone="body"/>
                    <vertex id="33" x="147" y="252" bone="body"/>
                    <vertex id="34" x="120" y="245" bone="body"/>
                    <vertex id="35" x="105" y="238" bone="body"/>
                    <vertex id="36" x="92.8" y="217.45" bone="neck"/>
                    <vertex id="37" x="72.45" y="218.55" bone="head"/>
                    <vertex id="38" x="54.45" y="219.3" bone="head"/>
                    <vertex id="39" x="7.4" y="224.7" bone="head"/>
                    <vertex id="40" x="-12.15" y="194.4" bone="head"/>
                    <vertex id="41" x="11" y="177.7" bone="head"/>
                    <vertex id="42" x="24.4" y="149.9" bone="head"/>
                    <vertex id="43" x="53.55" y="138.3" bone="head"/>
                    <vertex id="44" x="74.6" y="133.55" bone="head"/>
                    <vertex id="45" x="92.25" y="129.45" bone="neck"/>
                    <vertex id="46" x="110.2" y="126.15" bone="neck"/>
                    <vertex id="47" x="131" y="124" bone="body"/>
                    <vertex id="48" x="152" y="122" bone="body"/>
    
                </mesh>
            </date>
            addChild(_ika)
        }
        
    }


//-------------------------------------------------------
//SchoolGirl Mesh&IKデータ
//-------------------------------------------------------

    class SchoolGirl extends ImgAndBone {

        public function SchoolGirl() {
        
            //---------------------------------
            //Sample画像の読み込み
            //---------------------------------
            imgLoad('http://marubayashi.net/archive/sample/imagemesh/img.jpg');
            
            _ika = new IKArmature2d();
            _ika.setBone(new IKBone2d('body', 50, 0,-30,30));
            _ika.setBone(new IKBone2d('breast',54, 0,-30,30));
            
            _ika.setBone(new IKBone2d('waistRight', 48, 146,146,146,true));
            _ika.setBone(new IKBone2d('upperFootRight', 108, 34,-60,60));
            _ika.setBone(new IKBone2d('lowerFootRight', 116, -1,-1,170));
            _ika.setBone(new IKBone2d('ankleRight', 30, -10,-30,30));
            
            _ika.setBone(new IKBone2d('shoulderRight',33,100,100,100,true));
            _ika.setBone(new IKBone2d('upperArmRight',86,25));
            _ika.setBone(new IKBone2d('lowerArmRight',58,-4));
            _ika.setBone(new IKBone2d('handRight', 42, -8,-30,30));
            
            _ika.setBone(new IKBone2d('waistLeft', 48, -146,-146,-146,true));
            _ika.setBone(new IKBone2d('upperFootLeft', 108, -34,-60,60));
            _ika.setBone(new IKBone2d('lowerFootLeft', 116, 1,-170,1));
            _ika.setBone(new IKBone2d('ankleLeft', 30, 10,-30,30));
                
            _ika.setBone(new IKBone2d('shoulderLeft',33,-100,-100,-100,true));
            _ika.setBone(new IKBone2d('upperArmLeft',86,-25));
            _ika.setBone(new IKBone2d('lowerArmLeft',58,4));
            _ika.setBone(new IKBone2d('handLeft', 42, 8,-30,30));
            
            _ika.setBone(new IKBone2d('neck',30,0,-30,30,true));
            _ika.setBone(new IKBone2d('head',50,0,-30,30));

            //-------------------------------------------------
            //ボーンをジョイント
            //IKArmature2d.joint('親Bone名 Or root','子Bone名'
            //-------------------------------------------------
            _ika.joint('root', 'body');
            _ika.joint('root', 'waistRight');
            _ika.joint('root', 'waistLeft');
            _ika.joint('body', 'breast');

            _ika.joint('breast', 'neck');
            _ika.joint('neck', 'head');
            
            _ika.joint('breast', 'shoulderRight');
            _ika.joint('breast', 'shoulderLeft');
            _ika.joint('shoulderRight','upperArmRight');
            _ika.joint('shoulderLeft', 'upperArmLeft');
            _ika.joint('upperArmRight','lowerArmRight');
            _ika.joint('upperArmLeft','lowerArmLeft');
            _ika.joint('lowerArmRight','handRight');
            _ika.joint('lowerArmLeft', 'handLeft');
            
            _ika.joint('waistRight','upperFootRight');
            _ika.joint('waistLeft','upperFootLeft');
            _ika.joint('upperFootRight','lowerFootRight');
            _ika.joint('upperFootLeft', 'lowerFootLeft');
            _ika.joint('lowerFootRight','ankleRight');
            _ika.joint('lowerFootLeft','ankleLeft');
            
            _ika.x = 200
            _ika.y = 193
            _ika.rotation=0
            _ika.init();
                    
            _data=<date>
                <mesh meshBasePoint="1" id="0">
                    <vertex id="0" x="165" y="115" bone="shoulderLeft"/>
                    <vertex id="1" x="116" y="150" bone="upperArmLeft"/>
                    <vertex id="2" x="106" y="160" bone="upperArmLeft"/>
                    <vertex id="3" x="90" y="165" bone="lowerArmLeft"/>
                    <vertex id="4" x="55" y="181" bone="lowerArmLeft"/>
                    <vertex id="5" x="36" y="207" bone="handLeft"/>
                    <vertex id="6" x="-2" y="198" bone="handLeft"/>
                    <vertex id="7" x="6" y="183" bone="handLeft"/>
                    <vertex id="8" x="27" y="174" bone="handLeft"/>
                    <vertex id="9" x="46" y="165" bone="lowerArmLeft"/>
                    <vertex id="10" x="79" y="143" bone="lowerArmLeft"/>
                    <vertex id="11" x="89" y="134" bone="lowerArmLeft"/>
                    <vertex id="12" x="103" y="127" bone="upperArmLeft"/>
                    <vertex id="13" x="161" y="87" bone="breast"/>
                    <vertex id="14" x="172" y="83" bone="breast"/>
                    <vertex id="15" x="171" y="73" bone="head"/>
                    <vertex id="16" x="164" y="59" bone="head"/>
                    <vertex id="17" x="163" y="24" bone="head"/>
                    <vertex id="18" x="177" y="1" bone="head"/>
                    <vertex id="19" x="202" y="-6" bone="head"/>
                    <vertex id="20" x="221" y="1" bone="head"/>
                    <vertex id="21" x="233" y="21" bone="head"/>
                    <vertex id="22" x="236" y="56" bone="head"/>
                    <vertex id="23" x="230" y="68" bone="head"/>
                    <vertex id="24" x="228" y="83" bone="breast"/>
                    <vertex id="25" x="240" y="86" bone="breast"/>
                    <vertex id="26" x="297" y="127" bone="upperArmRight"/>
                    <vertex id="27" x="309" y="131" bone="upperArmRight"/>
                    <vertex id="28" x="318" y="139" bone="lowerArmRight"/>
                    <vertex id="29" x="351" y="163" bone="lowerArmRight"/>
                    <vertex id="30" x="375" y="174" bone="handRight"/>
                    <vertex id="31" x="395" y="187" bone="handRight"/>
                    <vertex id="32" x="402" y="200" bone="handRight"/>
                    <vertex id="33" x="363" y="210" bone="handRight"/>
                    <vertex id="34" x="345" y="183" bone="lowerArmRight"/>
                    <vertex id="35" x="307" y="163" bone="lowerArmRight"/>
                    <vertex id="36" x="295" y="160" bone="upperArmRight"/>
                    <vertex id="37" x="285" y="150" bone="upperArmRight"/>
                    <vertex id="38" x="235" y="114" bone="shoulderRight"/>
                    <vertex id="39" x="241" y="129" bone="breast"/>
                    <vertex id="40" x="236" y="145" bone="breast"/>
                    <vertex id="41" x="234" y="176" bone="body"/>
                    <vertex id="42" x="247" y="197" bone="body"/>
                    <vertex id="43" x="244" y="215" bone="body"/>
                    <vertex id="44" x="262.9" y="244.2" bone="upperFootRight"/>
                    <vertex id="45" x="243.05" y="324.85" bone="upperFootRight"/>
                    <vertex id="46" x="243.1" y="337.8" bone="upperFootRight"/>
                    <vertex id="47" x="242.7" y="349.65" bone="lowerFootRight"/>
                    <vertex id="48" x="247.35" y="375.85" bone="lowerFootRight"/>
                    <vertex id="49" x="234.1" y="443.3" bone="lowerFootRight"/>
                    <vertex id="50" x="234.4" y="458.4" bone="lowerFootRight"/>
                    <vertex id="51" x="240.85" y="489.7" bone="ankleRight"/>
                    <vertex id="52" x="203.85" y="488.9" bone="ankleRight"/>
                    <vertex id="53" x="208.3" y="459.05" bone="lowerFootRight"/>
                    <vertex id="54" x="211.05" y="443.2" bone="lowerFootRight"/>
                    <vertex id="55" x="209.45" y="374" bone="lowerFootRight"/>
                    <vertex id="56" x="209.35" y="356" bone="lowerFootRight"/>
                    <vertex id="57" x="207.1" y="339.9" bone="upperFootRight"/>
                    <vertex id="58" x="207.05" y="323.9" bone="upperFootRight"/>
                    <vertex id="59" x="200" y="245" bone="body"/>
                    <vertex id="60" x="193" y="324" bone="upperFootLeft"/>
                    <vertex id="61" x="193" y="341" bone="upperFootLeft"/>
                    <vertex id="62" x="189" y="355" bone="lowerFootLeft"/>
                    <vertex id="63" x="188" y="374" bone="lowerFootLeft"/>
                    <vertex id="64" x="183" y="446" bone="lowerFootLeft"/>
                    <vertex id="65" x="184" y="461" bone="lowerFootLeft"/>
                    <vertex id="66" x="189" y="488" bone="ankleLeft"/>
                    <vertex id="67" x="149" y="489" bone="ankleLeft"/>
                    <vertex id="68" x="158" y="462" bone="lowerFootLeft"/>
                    <vertex id="69" x="161" y="445" bone="lowerFootLeft"/>
                    <vertex id="70" x="153" y="376" bone="lowerFootLeft"/>
                    <vertex id="71" x="157" y="348" bone="lowerFootLeft"/>
                    <vertex id="72" x="155" y="337" bone="upperFootLeft"/>
                    <vertex id="73" x="157" y="324" bone="upperFootLeft"/>
                    <vertex id="74" x="139" y="245" bone="upperFootLeft"/>
                    <vertex id="75" x="156" y="217" bone="body"/>
                    <vertex id="76" x="154" y="197" bone="body"/>
                    <vertex id="77" x="166" y="177" bone="body"/>
                    <vertex id="78" x="163" y="144" bone="breast"/>
                    <vertex id="79" x="159" y="131" bone="breast"/>
                    <polygon id="0" p1="66" p2="67" p3="68"/>
                    <polygon id="1" p1="50" p2="51" p3="52"/>
                    <polygon id="2" p1="50" p2="52" p3="53"/>
                    <polygon id="3" p1="65" p2="66" p3="68"/>
                    <polygon id="4" p1="65" p2="68" p3="69"/>
                    <polygon id="5" p1="64" p2="65" p3="69"/>
                    <polygon id="6" p1="49" p2="50" p3="53"/>
                    <polygon id="7" p1="49" p2="53" p3="54"/>
                    <polygon id="8" p1="64" p2="69" p3="70"/>
                    <polygon id="9" p1="63" p2="64" p3="70"/>
                    <polygon id="10" p1="48" p2="49" p3="54"/>
                    <polygon id="11" p1="48" p2="54" p3="55"/>
                    <polygon id="12" p1="63" p2="70" p3="71"/>
                    <polygon id="13" p1="47" p2="48" p3="55"/>
                    <polygon id="14" p1="62" p2="63" p3="71"/>
                    <polygon id="15" p1="47" p2="55" p3="56"/>
                    <polygon id="16" p1="47" p2="56" p3="57"/>
                    <polygon id="17" p1="61" p2="62" p3="71"/>
                    <polygon id="18" p1="46" p2="47" p3="57"/>
                    <polygon id="19" p1="61" p2="71" p3="72"/>
                    <polygon id="20" p1="60" p2="61" p3="72"/>
                    <polygon id="21" p1="45" p2="46" p3="57"/>
                    <polygon id="22" p1="45" p2="57" p3="58"/>
                    <polygon id="23" p1="60" p2="72" p3="73"/>
                    <polygon id="24" p1="44" p2="45" p3="58"/>
                    <polygon id="25" p1="60" p2="73" p3="74"/>
                    <polygon id="26" p1="59" p2="60" p3="74"/>
                    <polygon id="27" p1="44" p2="58" p3="59"/>
                    <polygon id="28" p1="31" p2="32" p3="33"/>
                    <polygon id="29" p1="5" p2="6" p3="7"/>
                    <polygon id="30" p1="30" p2="31" p3="33"/>
                    <polygon id="31" p1="30" p2="33" p3="34"/>
                    <polygon id="32" p1="5" p2="7" p3="8"/>
                    <polygon id="33" p1="4" p2="5" p3="8"/>
                    <polygon id="34" p1="59" p2="74" p3="75"/>
                    <polygon id="35" p1="43" p2="44" p3="59"/>
                    <polygon id="36" p1="43" p2="59" p3="75"/>
                    <polygon id="37" p1="29" p2="30" p3="34"/>
                    <polygon id="38" p1="4" p2="8" p3="9"/>
                    <polygon id="39" p1="29" p2="34" p3="35"/>
                    <polygon id="40" p1="3" p2="4" p3="9"/>
                    <polygon id="41" p1="43" p2="75" p3="76"/>
                    <polygon id="42" p1="3" p2="9" p3="10"/>
                    <polygon id="43" p1="42" p2="43" p3="76"/>
                    <polygon id="44" p1="28" p2="29" p3="35"/>
                    <polygon id="45" p1="41" p2="42" p3="76"/>
                    <polygon id="46" p1="41" p2="76" p3="77"/>
                    <polygon id="47" p1="2" p2="3" p3="10"/>
                    <polygon id="48" p1="28" p2="35" p3="36"/>
                    <polygon id="49" p1="28" p2="36" p3="37"/>
                    <polygon id="50" p1="1" p2="2" p3="10"/>
                    <polygon id="51" p1="1" p2="10" p3="11"/>
                    <polygon id="52" p1="41" p2="77" p3="78"/>
                    <polygon id="53" p1="40" p2="41" p3="78"/>
                    <polygon id="54" p1="27" p2="28" p3="37"/>
                    <polygon id="55" p1="27" p2="37" p3="38"/>
                    <polygon id="56" p1="1" p2="11" p3="12"/>
                    <polygon id="57" p1="0" p2="1" p3="12"/>
                    <polygon id="58" p1="26" p2="27" p3="38"/>
                    <polygon id="59" p1="0" p2="12" p3="13"/>
                    <polygon id="60" p1="25" p2="26" p3="38"/>
                    <polygon id="61" p1="39" p2="40" p3="78"/>
                    <polygon id="62" p1="39" p2="78" p3="79"/>
                    <polygon id="63" p1="39" p2="79" p3="0"/>
                    <polygon id="64" p1="38" p2="39" p3="0"/>
                    <polygon id="65" p1="38" p2="0" p3="13"/>
                    <polygon id="66" p1="25" p2="38" p3="13"/>
                    <polygon id="67" p1="25" p2="13" p3="14"/>
                    <polygon id="68" p1="24" p2="25" p3="14"/>
                    <polygon id="69" p1="24" p2="14" p3="15"/>
                    <polygon id="70" p1="23" p2="24" p3="15"/>
                    <polygon id="71" p1="23" p2="15" p3="16"/>
                    <polygon id="72" p1="22" p2="23" p3="16"/>
                    <polygon id="73" p1="22" p2="16" p3="17"/>
                    <polygon id="74" p1="21" p2="22" p3="17"/>
                    <polygon id="75" p1="21" p2="17" p3="18"/>
                    <polygon id="76" p1="20" p2="21" p3="18"/>
                    <polygon id="77" p1="20" p2="18" p3="19"/>
                </mesh>
            </date>;

            addChild(_ika);
        }
        
    }




//-------------------------------------------------------------------------------------------------------
//簡易コンポーネント
//-------------------------------------------------------------------------------------------------------


    import flash.text.*
    import flash.display.LineScaleMode;
    import flash.display.SimpleButton;
    //---------------------------------------
    //簡単ウインドクラス
    //---------------------------------------
    class myWindow extends Sprite {
        public static const CLOSE:String = 'close';
        
        public function myWindow($str:String = '', $x:Number = 0, $y:Number = 0, $w:Number = 100, $h:Number = 100) {
            //---------------------------------------------
            //title
            //---------------------------------------------
            var _label:TextField = new TextField();
            _label.autoSize =TextFieldAutoSize.LEFT
            _label.selectable=false;
            _label.mouseEnabled = false;
            _label.x=4
            _label.y=3
            var format:TextFormat=new TextFormat();
            format.color = 0xFFFFFF
            format.size=12;
            format.font='_ゴシック';
            _label.defaultTextFormat = format
            _label.text = $str;
            addChild(_label);
            
            this.x = $x;
            this.y = $y;

            resize($w, $h);
            
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            onStageResize();
            stage.addEventListener(Event.RESIZE, onStageResize);
        }
        
        public function onStageResize(e:Event=null):void {
            x = int((this.stage.stageWidth - width) / 2);
            y = int((this.stage.stageHeight - height) / 2);
        }
        
        public function resize($w:Number, $h:Number):void {
            graphics.clear()
            graphics.lineStyle(0, 0x666666, 1, true, LineScaleMode.NONE);
            graphics.beginFill(0xFFFFFF, 1);
            graphics.drawRect(0, 0, $w, $h);
            graphics.beginFill(0xCCCCCC, 1);
            graphics.drawRect(0, 0, $w, 20);
        }
        
        public function close(e:MouseEvent):void {
            visible = false;
            dispatchEvent(new Event(CLOSE));
        }
        
    }


    import flash.net.FileReference;
    import flash.net.FileReferenceList;
    import flash.utils.ByteArray;
    //------------------------------------------------------
    //アラートパネル
    //------------------------------------------------------
    class AlertPanel extends myWindow {
        private var _label:TextField;
        private var _closeBt:myButton;
        
        public function AlertPanel($str:String = 'エラーが発生しました') {
            
            super('エラー！', 0, 0, 300, 100);
            
            _label = new TextField();
            _label.autoSize =TextFieldAutoSize.LEFT
            _label.selectable=false;
            _label.mouseEnabled = false;
            _label.multiline = true;
            _label.wordWrap = true;
            _label.x=20
            _label.y = 40
            _label.width = 260;
            var format:TextFormat=new TextFormat();
            format.color = 0x666666
            format.size=12;
            format.font='_ゴシック';
            _label.defaultTextFormat = format
            _label.text = $str;
            addChild(_label);
            visible = false;
            
            _closeBt = new myButton('閉じる',0, 70);
            _closeBt.x = (300 - _closeBt.width)/2;
            _closeBt.addEventListener(MouseEvent.CLICK, close);
            addChild(_closeBt);
        }
        
        public function setText($str:String):void {
            _label.text = $str;
            visible = true;
            _closeBt.y = _label.y + _label.height + 20;
            resize(300,_label.y + _label.height + _closeBt.height+30);
            onStageResize();
        }
        

    }


    //---------------------------------------
    //簡単ボタンクラス
    //---------------------------------------
    class myButton extends SimpleButton {
        
        public static const CLICK:String = 'click2';
        
        public function myButton($str:String,$x:Number=0,$y:Number=0,$w:Number=0,$h:Number=0) {
            this.upState = state($str, $w, $h);
            this.overState = state($str, $w, $h,0xFFDDDD);
            this.downState = state($str, $w, $h, 0xDDDDFF);
            this.hitTestState = state($str, $w, $h, 0xDDDDFF);
            this.x = $x;
            this.y = $y;
            
            this.addEventListener(MouseEvent.CLICK,inClick)
        }
        
        private function state($str:String,$w:Number,$h:Number,$color:uint=0xFFFFFF):Sprite {
            var result:Sprite = new Sprite();
            var label:TextField=new TextField()
            label.autoSize=TextFieldAutoSize.LEFT
            label.selectable=false;
            label.mouseEnabled=false;
            var format:TextFormat=new TextFormat();
            format.color=0x666666
            format.size=12;
            format.font='_ゴシック';
            label.defaultTextFormat = format;
            label.htmlText = $str;
            if (!$w) {
                $w = label.width + 20;
            }
            if (!$h) {
                $h = label.height + 4;
            }
            label.x = int(($w - label.width) / 2);
            label.y = int(($h - label.height) / 2);
            result.addChild(label)
            result.graphics.lineStyle(0,0x666666,0.5,true,LineScaleMode.NONE)
            result.graphics.beginFill($color,1)
            result.graphics.drawRect(0,0,$w,$h)
            return result;
            

        }
        
        private function inClick(e:MouseEvent):void {
            if (enabled) {
                dispatchEvent(new MouseEvent(CLICK));
            }
        }
        
        
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            
            if (value) {
                this.alpha = 1
            } else {
                this.alpha = 0.2
            }
        }
        
    }


    //---------------------------------------
    //簡単インプットクラス
    //---------------------------------------
    class myInput extends Sprite {
        private var _label:TextField;
        
        public function myInput($str:String='', $x:Number=0, $y:Number=0, $w:Number = 100, $h:Number = 18) {
            this.x = $x;
            this.y = $y;
            graphics.lineStyle(0,0x666666,0.5,true,LineScaleMode.NONE)
            graphics.beginFill(0xFFFFFF,1)
            graphics.drawRect(0,0,$w,$h)
            _label = new TextField();
            _label.autoSize =TextFieldAutoSize.LEFT
            _label.selectable=true;
            _label.mouseEnabled = true;
            _label.mouseWheelEnabled = false;
            _label.border = false;
            _label.type = TextFieldType.INPUT;
            _label.width = $w-4;
            _label.height = $h - 2;
            _label.x=2
            _label.y=1
            var format:TextFormat=new TextFormat();
            format.color=0x666666
            format.size=12;
            format.font='_ゴシック';
            _label.defaultTextFormat = format
            _label.text = $str;
            addChild(_label);
        }
        
        public function get text():String {
            return _label.text;
        }
        
    }



