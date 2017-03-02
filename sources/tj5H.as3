package
{
    import flash.display.Sprite;
    
    /**
     * こっそり開発している、3DライブラリにIKを実装しようと思ったのだけど、
     * いきなり3Dで考えると訳わからなくなってきたので、ちょっと試しに2Dでプロトタイプを作成。
     *
     * 先の事考えて、余分なクラスとか入ってますが気にしないでください。
     * 
     * Joint部分の、抵抗値や、稼動範囲値などは、まだ未実装
     * 次Verでは、自作Meshやシェイプに関連付けられるようにする予定
     *
     * @author narutohyper
     */
    [SWF(width = 465, height = 465, frameRate = 60)]
    
    public class Main extends Sprite {
        private var ika:IKArmature2d;

        private var segments:Array;
        private var num:Number = 10;

        public function Main() {
            this.stage.quality = "BEST";

            //アーマチュアの作成
            ika = new IKArmature2d();
            //ボーンの作成
            var test:uint = 0;
            if (test) {
                ika.setBone(new IKBone2d('test1', 100, 0));
                ika.setBone(new IKBone2d('test2', 50, 70));
                ika.joint('root', 'test1');
                ika.joint('test1', 'test2');
            } else {
            
                ika.setBone(new IKBone2d('body', 60, 0));
                
                ika.setBone(new IKBone2d('breast', 50, 0));
                
                ika.setBone(new IKBone2d('waistRight', 50, 140));
                ika.setBone(new IKBone2d('upperFootRight', 80, 180));
                ika.setBone(new IKBone2d('lowerFootRight', 70, 180));
                ika.setBone(new IKBone2d('ankleRight', 30, 120));
                
                ika.setBone(new IKBone2d('shoulderRight',50,100));
                ika.setBone(new IKBone2d('upperArmRight',50,150));
                ika.setBone(new IKBone2d('lowerArmRight',50,170));
                ika.setBone(new IKBone2d('handRight', 20, 180));
                
                ika.setBone(new IKBone2d('waistLeft', 50, -140));
                ika.setBone(new IKBone2d('upperFootLeft', 80, -180));
                ika.setBone(new IKBone2d('lowerFootLeft', 70, -180));
                ika.setBone(new IKBone2d('ankleLeft', 30, -120));
                    
                ika.setBone(new IKBone2d('shoulderLeft',50,-100));
                ika.setBone(new IKBone2d('upperArmLeft',50,-150));
                ika.setBone(new IKBone2d('lowerArmLeft',50,-170));
                ika.setBone(new IKBone2d('handLeft', 20, -180));
                
                ika.setBone(new IKBone2d('neck',20,0));
                ika.setBone(new IKBone2d('head',40,0));

                //ボーンをジョイント              
                ika.joint('root', 'body');
                ika.joint('root', 'waistRight');
                ika.joint('root', 'waistLeft');
                ika.joint('body', 'breast');

                ika.joint('breast', 'neck');
                ika.joint('neck', 'head');
                
                ika.joint('breast', 'shoulderRight');
                ika.joint('breast', 'shoulderLeft');
                ika.joint('shoulderRight','upperArmRight');
                ika.joint('shoulderLeft', 'upperArmLeft');
                ika.joint('upperArmRight','lowerArmRight');
                ika.joint('upperArmLeft','lowerArmLeft');
                ika.joint('lowerArmRight','handRight');
                ika.joint('lowerArmLeft', 'handLeft');
                
                ika.joint('waistRight','upperFootRight');
                ika.joint('waistLeft','upperFootLeft');
                ika.joint('upperFootRight','lowerFootRight');
                ika.joint('upperFootLeft', 'lowerFootLeft');
                ika.joint('lowerFootRight','ankleRight');
                ika.joint('lowerFootLeft','ankleLeft');
            }
            

            
            this.addChild(ika);
            ika.x = 465/2;
            ika.y = 465/2;

        }

    }
}


    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;


    
    class IKArmature2d extends Sprite  {
        private var _rootJoint:IKJoint2d;
        private var _bones:Object;
        private var _mesh:Mesh2d;

        
        public function IKArmature2d () {
            bones = new Object;
            rootJoint = new IKJoint2d('root')
            
            this.addChild(rootJoint)
            

        }

        
        public function setBone(value:IKBone2d):void {
            bones[value.id]=value;
            value.mesh = mesh;
            this.addChild(value);
        }
        
        public function joint($boneA:String = null, $boneB:String = null):void {
            if ($boneA) {
                if ($boneA == 'root') {
                    if (bones[$boneB]) {
                        bones[$boneB].jointRoot(rootJoint);
                    } else {
                        trace('Error:boneが存在しません。', $boneB + '=', bones[$boneB]);
                    }
                } else if (bones[$boneB] && bones[$boneA]) {
                    bones[$boneB].setParentBone(bones[$boneA]);
                    bones[$boneA].setChildBone(bones[$boneB]);
                } else {
                    trace('Error:boneが存在しません。', $boneA + '=', bones[$boneA], $boneA + '=', bones[$boneB]);
                }
            } else {

            }
        }
        
        
        
        
        //関連付けられたMesh2d
        public function set mesh(value:Mesh2d):void {
                _mesh = value;
        }
        
        public function get mesh():Mesh2d {
            return _mesh;
        }
        
        
        //基準となるジョイント
        public function set rootJoint(value:IKJoint2d):void {
                _rootJoint = value;
        }
        
        public function get rootJoint():IKJoint2d {
            return _rootJoint;
        }
        
        public function set bones(value:Object):void {
                _bones = value;
        }
        
        public function get bones():Object {
            return _bones;
        }
        
    }
    
    
    
    
    
    class IKBone2d extends Sprite {
        public static const MOVE_BONE:String = 'move_bone';
        
        private var _me:IKBone2d;
        private var _headJoint : IKJoint2d;
        private var _tailJoint : IKJoint2d;

        private var _parentBones : Array;
        private var _childBones : Array;
        
        private var _length : Number;
        private var _vectors : Vector.<Vector2d>;
        private var _mesh:Mesh2d;
        private var _bone:Shape;
        private var _id:String;
        private var _rootFlag:Boolean = false
        
        private var _clickPoint:Point
        
        public function IKBone2d ($id:String = 'null', $length:Number=100, $rotation:Number=0) {
            id = $id;
            _me = this;
            _clickPoint = new Point();
            _parentBones = [];
            _childBones = [];
            _bone = new Shape();
            addChild(_bone);
            headJoint = new IKJoint2d();
            addChild(headJoint);
            tailJoint = new IKJoint2d();
            addChild(tailJoint)
            length = $length;
            rotationZ = $rotation;
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

        }
        
        //ドラッグの仕組み
        private function onMouseOver(event:MouseEvent):void {
            changeColor(0x3333ff);
        }
        
        private function onMouseOut(event:MouseEvent):void {
            changeColor();
        }
        
        private function onMouseDown(event:MouseEvent):void {
            _clickPoint = new Point(mouseX, mouseY);
            
            removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
        }
        
        private function onMouseUp(event:MouseEvent):void {
            _clickPoint = new Point(0, 0);
            if (event.target != this) {
                changeColor();
            }
             addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
        }
        
        private function onMouseMove($color:uint = 0x006600):void {
            move(headJoint, new Point(parent.mouseX, parent.mouseY), new Point(x, y),null,null,'mouseMove')

            //親と子両方に伝達
            var i:uint;
            if (_childBones.length) {
                for (i = 0; i < _childBones.length;i++) {
                    _childBones[i].parentMove(this,new Point(tailJoint.jx+x, tailJoint.jy+y))
                }
            }
            if (_parentBones.length) {
                for (i = 0; i < _parentBones.length;i++) {
                    _parentBones[i].childMove(this,new Point(x, y))
                }
            }
        }

        public function parentMove($target:IKBone2d,$pt:Point):void {
            move(null, $pt, new Point(tailJoint.jx+x, tailJoint.jy+y),$target,'parent')
            //親から回ってきたら、子に伝達
            var i:uint;
            if (_childBones.length) {
                for (i = 0; i < _childBones.length;i++) {
                    _childBones[i].parentMove(this,new Point(tailJoint.jx+x, tailJoint.jy+y));
                }
            }
        }
        
        public function childMove($target:IKBone2d, $pt:Point):void {
            move(headJoint, $pt, new Point(x, y),$target)
            //子から回ってきたら、親に伝達
            var i:uint;
            if (_parentBones.length) {
                for (i = 0; i < _parentBones.length;i++) {
                    _parentBones[i].childMove(this,new Point(x, y))
                }
            }

        }
        
        
        private function move($j:IKJoint2d, $p1:Point, $p2:Point, $target:IKBone2d = null , $type:String = null,$mode:String = null):void {
            
      var dx:Number = $p1.x-$p2.x;
      var dy:Number = $p1.y-$p2.y;
      var angle:Number = Math.atan2( dy, dx );
            if (!$type) {
                rotationZ = angle * 180 / Math.PI + 90;
            } else {
                rotationZ = angle * 180 / Math.PI - 90;
            }

            //もし、headerJointが固定点（rootJoint）に繋がっていたら、動かさない
            if (!_rootFlag) {
                if ($mode) {
                    var v3d:Vector3D = new Vector3D(0 ,_clickPoint.y, 0);
                    var mtx:Matrix3D = new Matrix3D();
                    mtx.prependRotation(rotationZ, Vector3D.Z_AXIS);
                    v3d = mtx.transformVector(v3d);
                    x = $p1.x - v3d.x
                    y = $p1.y - v3d.y;
                } else if ($j) {
                    x = $p1.x - $j.jx;
                    y = $p1.y - $j.jy;
                } else {
                    x = $p1.x;
                    y = $p1.y;
                }

            } else {
                if ($target) {
                    $target.parentMove(null,new Point(tailJoint.jx+x, tailJoint.jy+y));
                }
            }
            
        }
        
        
        
        
        private function changeColor($color:uint = 0x006600):void {
            var tc:ColorTransform = new ColorTransform()
            tc.color = $color;
            transform.colorTransform = tc;
            
        }

        
        //関連付けられたMesh2d
        public function set mesh(value:Mesh2d):void {
            _mesh = value;
        }
        
        public function get mesh():Mesh2d {
            return _mesh;
        }
                
        
        //ボーンが影響するVector2d
        public function set vectors(value:Vector.<Vector2d>):void {
            _vectors = value;
        }
        
        public function get vectors():Vector.<Vector2d> {
            return _vectors;
        }
        
        //ボーンの長さ
        public function set length(value:Number):void {
            makeBone(value)
            _length = value;
            tailJoint.y = -value;
            
            tailJoint.v3d = new Vector3D(0,-_length, 0);
            var mtx:Matrix3D = new Matrix3D();
            mtx.prependRotation(rotationZ, Vector3D.Z_AXIS);
            tailJoint.v3d = mtx.transformVector(tailJoint.v3d);
            

        }
        
        public function get length():Number {
            return _length;
        }
        
        //ボーンの回転
        //単にrotationでもいいのだが、3D化に備えあえてrotationZ&Vector3D
        override public function set rotationZ(value:Number):void {
            super.rotationZ = value;
            tailJoint.v3d = new Vector3D(0,-_length, 0);
            var mtx:Matrix3D = new Matrix3D();
            mtx.prependRotation(value, Vector3D.Z_AXIS);
            tailJoint.v3d = mtx.transformVector(tailJoint.v3d);
        }
        
        override public function get rotationZ():Number {
            return super.rotationZ;
        }
        

        
        
        
        //始点ジョイント
        public function set headJoint(value:IKJoint2d):void {
            _headJoint = value;
        }
        
        public function get headJoint():IKJoint2d {
            return _headJoint;
        }
        
        //終点ジョイント
        public function set tailJoint(value:IKJoint2d):void {
            _headJoint = value;
        }
        
        public function get tailJoint():IKJoint2d {
            return _headJoint;
        }
        
        //JointBone(始点Jointを親BoneのtailJointに結合する)
        public function jointBone(value:IKBone2d):void {
            x = value.tailJoint.jx;
            y = value.tailJoint.jy;
            if (value){
                x += value.x
                y += value.y
            }
        }

        //JointRoot(始点JointをrootJointに結合する)
        public function jointRoot(value:IKJoint2d):void {
            _rootFlag=true
            x = value.jx;
            y = value.jy;
        }
        

        
        //親Boneのセット
        public function setParentBone(value:IKBone2d):void {
            _parentBones.push(value);
            jointBone(value);
        }
        

        //子Boneのセット
        public function setChildBone(value:IKBone2d):void {
            _childBones.push(value);
        }
        
        
        
        //関連付けられたMesh2d
        public function set id(value:String):void {
            _id = value;
        }
        
        public function get id():String {
            return _id;
        }
        
        
        
        private function makeBone(no:Number=100,$color:uint=0x006600):void {
            //bone画像の生成
            _bone.graphics.clear();
            _bone.graphics.beginFill($color, 1);
            _bone.graphics.moveTo(0, 0);
            if (no > 10) {
                _bone.graphics.lineTo(5,-7);
                _bone.graphics.lineTo(no - 5,-2);
                _bone.graphics.lineTo(no,-2);
                _bone.graphics.lineTo(no - 5,2);
                _bone.graphics.lineTo(5,7);
            } else {
                _bone.graphics.lineTo(no / 2, -7);
                _bone.graphics.lineTo(no - 5,-2);
                _bone.graphics.lineTo(no - 5,2);
                _bone.graphics.lineTo(no / 2, 7);
            }
            _bone.graphics.endFill();
            _bone.rotation=-90

        }
        
        
        
    }
    
    class IKJoint2d extends Sprite  {

        public var v3d:Vector3D;
        
        private var _type:String;
        
        public function IKJoint2d ($type:String = 'default') {
            _type = $type;
            v3d = new Vector3D(0, 0, 0);
            if (_type == 'root') {
                drawRoot();
            } else {
                drawDefault();
            }
        }
        
        private function drawRoot():void {
            graphics.lineStyle(4, 0x006600,1);
            graphics.drawCircle(0, 0, 10);
        }
        
        private function drawDefault():void {
            graphics.lineStyle(3, 0x006600,1);
            graphics.drawCircle(0, 0, 3);
        }
        
        
        //rootJointの場合は、自分自身の位置を返す。
        //defaultJointは、位置、回転変換された座標を返す。
        public function get jx():Number {
            return v3d.x
        }
        
        public function get jy():Number {
            return v3d.y
        }
        
        public function get type():String {
            return _type;
        }
        
    }
    
    
        
    class Object2d {
        public function Object2d () {
            
        }
    
    }
    
    
    class Mesh2d extends Object2d {
        public function Mesh2d () {
            
        }
    }
    

    
    
    class Vector2d {
        private var _x:Number;
        private var _y:Number;
        private var _name:String;

        public function Vector2d ($name:String=null,$x:Number=0,$y:Number=0) {
            name = $name;
            x = $x;
            y = $y;
        }
        
        public function set x(value:Number):void {
                _x = value;
        }
        
        public function get x():Number {
            return _x;
        }
            
        public function set y(value:Number):void {
                _y = value;
        }
        
        public function get y():Number {
            return _y;
        }

        public function set name(value:String):void {
                _name = value;
        }
        
        public function get name():String {
            return _name;
        }
        
    }
    
    
    

