// forked from Event's Human Clock

/**
 * 時：曲がっている足の位置
 * 分：伸びている足の位置
 * 秒：両腕の傾き（腕同士が重なる側が秒針の方向）
 * 
 * ・表示時間に応じて筋肉が増加。
 * ・時刻に応じて体の色が変化。
 * ・画面クリックで腕の上下動を反転。（何もしなくても1分毎に自動反転）
 *
 * IK制御に関しては narutohyper さんの IK Bone Sample を使わせていただいてます。
 * http://wonderfl.net/c/tj5H
 */
package {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import net.hires.debug.Stats;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.events.TweenEvent;
    import frocessing.color.FColor;
    import frocessing.color.ColorHSV;
    import flash.utils.Timer;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    [SWF(width = 465, height = 465, frameRate = 60)]
    
    public class HumanClock extends Sprite {
        private var _stageW:Number;
        private var _stageH:Number;
        private static const MUSCLE_GAIN:Number = .01;    //一回の動作での筋肉増加値
        //ボーン制御用のコントロールポイント
        private var _armLPt:Point = new Point();
        private var _armRPt:Point = new Point();
        private var _legLPt:Point = new Point();
        private var _legRPt:Point = new Point();
        private var _footLPt:Point = new Point();
        private var _footRPt:Point = new Point();
        //
        private var _ika:IKArmature2d;
        private var _IKBones:Vector.<IKBone2d>;
        private var _legL:IKBone2d;
        private var _legR:IKBone2d;
        private var _footL:IKBone2d;
        private var _footR:IKBone2d;
        private var _armL:IKBone2d;
        private var _armR:IKBone2d;
        private var _head:IKBone2d;
        private var _armIT:ITween;            //腕のトゥイーン
        private var _legIT:ITween;            //脚のトゥイーン
        private var _nowSeconds:Number;
        private var _isArmUp:Boolean;        //腕を上げるか下げるか
        private var _isHoursLegL:Boolean;    //左脚で時刻を示すか
        private var _oldHAngle:Number = 0;    //針の角度を保持（時）
        private var _oldMAngle:Number = 0;    //針の角度を保持（分）
        //
        private var _musRatio:Number = 0;    //現在の筋肉増加率 0~1
        private var _musTimer:Timer;        //筋肉増加タイマー
        private var _reverseCount:Number = 0;
        
        public function HumanClock() {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            _stageW = stage.stageWidth;
            _stageH = stage.stageHeight;
            //addChild( new Stats() );
            
            graphics.beginFill (0x000000, 1);
            graphics.drawRect  (0, 0, _stageW , _stageH);
            
            var clockDisk:Sprite = new ClockDisk();
            clockDisk.x = _stageW/2;
            clockDisk.y = _stageH/2;
            addChild( clockDisk );
            
            _musTimer = new Timer(2000, 1);
            _musTimer.addEventListener(TimerEvent.TIMER, musTimerHandler);
            
            //アーマチュアの作成
            _ika = new IKArmature2d();
            //ボーンの作成
            _IKBones = new Vector.<IKBone2d>();
            //
            _footL = makeIKBone('ankleLeft', 30, -120,            0x6D6D6D, 0x616161, 0);
            _ika.setBone( _footL );
            _legL = makeIKBone('lowerFootLeft', 70, -180,        0x898989, 0x6D6D6D, 1);
            _ika.setBone( _legL );
            _ika.setBone(makeIKBone('upperFootLeft', 80, -180,    0xA7A7A7, 0x898989, 2));
            _ika.setBone(makeIKBone('waistLeft', 20, -120,        0xA7A7A7, 0xA7A7A7, 2));
            //
            _footR = makeIKBone('ankleRight', 30, 120,            0x6D6D6D, 0x616161, 0);
            _ika.setBone( _footR );
            _legR = makeIKBone('lowerFootRight', 70, 180,        0x898989, 0x6D6D6D, 1);
            _ika.setBone( _legR );
            _ika.setBone(makeIKBone('upperFootRight', 80, 180,    0xA7A7A7, 0x898989, 2));
            _ika.setBone(makeIKBone('waistRight', 20, 120,        0xA7A7A7, 0xA7A7A7, 2));
            //
            _ika.setBone(makeIKBone('body', 30, 0,                0xA7A7A7, 0xA7A7A7, 1.5));
            _ika.setBone(makeIKBone('belly', 30, 0,                0xA7A7A7, 0xC3C3C3, 2));
            _ika.setBone(makeIKBone('breast', 45, 0,            0xC3C3C3, 0xDADADA, 3));
            //
            _ika.setBone(makeIKBone('handLeft',20,-180,            0x979797, 0x909090, 0));
            _armL = makeIKBone('lowerArmLeft',50,-170,            0xABABAB, 0x959595, 2);
            _ika.setBone( _armL );
            _ika.setBone(makeIKBone('upperArmLeft',45,-150,        0xC4C4C4, 0xADADAD, 3));
            _ika.setBone(makeIKBone('shoulderLeft',40,-100,        0xDBDBDB, 0xC9C9C9, 3));
            //
            _ika.setBone(makeIKBone('handRight', 20, 180,        0x979797, 0x909090, 0));
            _armR = makeIKBone('lowerArmRight',50,170,            0xABABAB, 0x959595, 2);
            _ika.setBone(_armR);
            _ika.setBone(makeIKBone('upperArmRight',45,150,        0xC4C4C4, 0xADADAD, 3));
            _ika.setBone(makeIKBone('shoulderRight',40,100,        0xDBDBDB, 0xC9C9C9, 3));
            //
            _ika.setBone(makeIKBone('neck', 25, 0,                0xE0E0E0, 0xE2E2E2, 2));
            _head = makeIKBone('head', 40, 0,                    0xE5E5E5, 0xFFFFFF, 0);
            _ika.setBone( _head );
            
            //ボーンをジョイント              
            _ika.joint('root', 'body');
            _ika.joint('root', 'waistRight');
            _ika.joint('root', 'waistLeft');
            _ika.joint('body', 'belly');
            _ika.joint('belly', 'breast');
            //
            _ika.joint('breast', 'neck');
            _ika.joint('neck', 'head');
            //
            _ika.joint('breast', 'shoulderRight');
            _ika.joint('breast', 'shoulderLeft');
            _ika.joint('shoulderRight','upperArmRight');
            _ika.joint('shoulderLeft', 'upperArmLeft');
            _ika.joint('upperArmRight','lowerArmRight');
            _ika.joint('upperArmLeft','lowerArmLeft');
            _ika.joint('lowerArmRight','handRight');
            _ika.joint('lowerArmLeft', 'handLeft');
            //
            _ika.joint('waistRight','upperFootRight');
            _ika.joint('waistLeft','upperFootLeft');
            _ika.joint('upperFootRight','lowerFootRight');
            _ika.joint('upperFootLeft', 'lowerFootLeft');
            _ika.joint('lowerFootRight','ankleRight');
            _ika.joint('lowerFootLeft','ankleLeft');
            //
            addChild(_ika);
            _ika.x = _stageW/2;
            _ika.y = _stageH/2;
            //
            
            initMove();
            changeColor();
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(MouseEvent.CLICK, onMClickHandler);
        }
        
        private function makeIKBone($id:String, $length:Number, $rotation:Number, $colorA:Number, $colorB:Number, $mus:Number):IKBone2d {
            var ikBone:IKBone2d = new IKBone2d($id, $length, $rotation, $colorA, $colorB, $mus);
            _IKBones.push( ikBone );
            return ikBone;
        }
        
        private function onMClickHandler(e:MouseEvent):void {
            _isArmUp = !_isArmUp;
            _reverseCount = -1;
        }
        
        
        private function initMove():void {
            var ca:Object = getClockHandAngle( new Date );
            //足を動かす
            var tObjLegL:Object = getLegTweenPt( ca.h, ca.m, _oldHAngle, _oldMAngle, _isHoursLegL, true );
            var tObjLegR:Object = getLegTweenPt( ca.h, ca.m, _oldHAngle, _oldMAngle, _isHoursLegL, false );
            _isHoursLegL = !_isHoursLegL;
            //
            _legLPt.x = tObjLegL.legGoalX;
            _legLPt.y = tObjLegL.legGoalY;
            _legRPt.x = tObjLegR.legGoalX;
            _legRPt.y = tObjLegR.legGoalY;
            _footLPt.x = tObjLegL.footGoalX;
            _footLPt.y = tObjLegL.footGoalY;
            _footRPt.x = tObjLegR.footGoalX;
            _footRPt.y = tObjLegR.footGoalY;
            //
            _oldHAngle = ca.h;
            _oldMAngle = ca.m;
        }
        
        private function getClockHandAngle($time:Date):Object {
            var h:Number = $time.hours;
            var m:Number = $time.minutes;
            var s:Number = $time.seconds;
            var ca:Object = new Object();
            ca.h = ( ((h % 12) * 30) + (m / 2) +270 )%360;
            ca.m = ( (m * 6) +270 )%360;
            ca.s = ( s * 6 +270 )%360;
            return ca;
        }
        
        private function enterFrameHandler(e:Event):void {
            var time:Date = new Date();
            if ( _nowSeconds != time.seconds ) {
                _nowSeconds = time.seconds;
                var ca:Object = getClockHandAngle( time );
                if(_nowSeconds%5 == 0){
                    reverseCountUp();
                    //腕を動かす
                    var tObjArmL:Object = getArmTweenPt( ca.s, _isArmUp, true );
                    var tObjArmR:Object = getArmTweenPt( ca.s, _isArmUp, false );
                    _isArmUp = !_isArmUp;
                    //
                    if(_armIT != null) _armIT.stop();
                    _armIT =     BetweenAS3.serial(
                                    BetweenAS3.parallel(
                                        BetweenAS3.bezier(_armLPt, { x:tObjArmL.tempX, y:tObjArmL.tempY }, null, {x:tObjArmL.x, y:tObjArmL.y}, 2, Cubic.easeInOut),
                                        BetweenAS3.bezier(_armRPt, { x:tObjArmR.tempX, y:tObjArmR.tempY }, null, {x:tObjArmR.x, y:tObjArmR.y}, 2, Cubic.easeInOut)
                                    ),
                                    BetweenAS3.parallel(
                                        BetweenAS3.tween(_armLPt, { x:tObjArmL.goalX, y:tObjArmL.goalY }, null, 1, Elastic.easeOut),
                                        BetweenAS3.tween(_armRPt, { x:tObjArmR.goalX, y:tObjArmR.goalY }, null, 1, Elastic.easeOut)
                                    )
                                );
                    _armIT.play();
                    _musTimer.start();
                }
            
                if(_nowSeconds%10 == 0){
                    //足を動かす
                    var tObjLegL:Object = getLegTweenPt( ca.h, ca.m, _oldHAngle, _oldMAngle, _isHoursLegL, true );
                    var tObjLegR:Object = getLegTweenPt( ca.h, ca.m, _oldHAngle, _oldMAngle, _isHoursLegL, false );
                    _isHoursLegL = !_isHoursLegL;
                    //
                    if(_legIT != null) _legIT.stop();
                    _legIT =    BetweenAS3.parallel(
                                    BetweenAS3.delay(BetweenAS3.bezier(_legLPt, { x:tObjLegL.legGoalX, y:tObjLegL.legGoalY }, null, {x:tObjLegL.legCtX, y:tObjLegL.legCtY}, 1.5, Cubic.easeInOut), tObjLegL.delay),
                                    BetweenAS3.delay(BetweenAS3.bezier(_legRPt, { x:tObjLegR.legGoalX, y:tObjLegR.legGoalY }, null, {x:tObjLegR.legCtX, y:tObjLegR.legCtY}, 1.5, Cubic.easeInOut), tObjLegR.delay),
                                    BetweenAS3.delay(BetweenAS3.bezier(_footLPt, { x:tObjLegL.footGoalX, y:tObjLegL.footGoalY }, null, {x:0, y:0}, 1.5, Cubic.easeInOut), tObjLegL.delay),
                                    BetweenAS3.delay(BetweenAS3.bezier(_footRPt, { x:tObjLegR.footGoalX, y:tObjLegR.footGoalY }, null, {x:0, y:0}, 1.5, Cubic.easeInOut), tObjLegR.delay)
                                );
                    _legIT.play();
                    //
                    _oldHAngle = ca.h;
                    _oldMAngle = ca.m;
                }
            }
            _legL.boneMove(new Point(_legLPt.x, _legLPt.y), -40);
            _legR.boneMove(new Point(_legRPt.x, _legRPt.y), -40);
            _footL.boneMove(new Point(_footLPt.x, _footLPt.y), -20);
            _footR.boneMove(new Point(_footRPt.x, _footRPt.y), -20);
            _armL.boneMove(new Point(_armLPt.x, _armLPt.y), -35);
            _armR.boneMove(new Point(_armRPt.x, _armRPt.y), -35);
            _head.boneMove(new Point(0, -190), -70);
        }
        
        private function reverseCountUp():void {
            _reverseCount++;
            if(_reverseCount >= 12){
                _reverseCount = 0;
                _isArmUp = !_isArmUp;
            }
        }
        
        private function musTimerHandler(e:TimerEvent):void {
            changeMuscle();
            changeColor();
        }
        
        private function changeMuscle():void {
            _armIT.removeEventListener(TweenEvent.COMPLETE, changeMuscle);
            _musRatio += MUSCLE_GAIN;
            if( _musRatio>1 ) _musRatio = 1;
            for(var i:uint=0; i<_IKBones.length; i++){
                _IKBones[i].changeMuscul( _musRatio );
            }
        }
        private function changeColor():void {
            for(var i:uint=0; i<_IKBones.length; i++){
                _IKBones[i].drawBone( _oldHAngle );
            }
        }
        
        // 脚のトゥイーン情報を返す
        private function getLegTweenPt( $hAngle:Number, $mAngle:Number, $oldHAngle:Number, $oldMAngle:Number, $isHoursLegL:Boolean, $isArmLeft:Boolean ):Object {
            var tweenObj:Object = new Object();
            var legCtX:Array = new Array();
            var legCtY:Array = new Array();
            var legLength:Number = 130;    //脚の半径
            var diffLeg:Number;
            var angle:Number;
            var oldAngle:Number;
            
            if( ($isArmLeft && $isHoursLegL) || (!$isArmLeft && !$isHoursLegL) ){
                //短針
                angle = $hAngle;
                oldAngle = $oldMAngle;
                diffLeg = -70;
                tweenObj.delay = 3.5;
            }else{
                //長針
                angle = $mAngle;
                oldAngle = $oldHAngle;
                diffLeg = 0;
                tweenObj.delay = 3;
            }
            
            //ベジェトゥイーンのコントロールポイント
            legCtX.push( Math.cos((oldAngle-angle)*Math.PI/180)*20 );
            legCtY.push( Math.sin((oldAngle-angle)*Math.PI/180)*20 );
            tweenObj.legCtX = legCtX;
            tweenObj.legCtY = legCtY;
            //
            tweenObj.footCtX = 0;
            tweenObj.footCtY = 0;
            //
            tweenObj.legGoalX = Math.cos((angle+3)*Math.PI/180)*(legLength+diffLeg);
            tweenObj.legGoalY = Math.sin((angle+3)*Math.PI/180)*(legLength+diffLeg);
            //
            tweenObj.footGoalX = Math.cos(angle*Math.PI/180)*(legLength+diffLeg+35);
            tweenObj.footGoalY = Math.sin(angle*Math.PI/180)*(legLength+diffLeg+35);
            return tweenObj;
        }
        
        // 腕のトゥイーン情報を返す
        private function getArmTweenPt( $angle:Number, $isArmUp:Boolean, $isArmLeft:Boolean ):Object {
            var tweenObj:Object = new Object();
            var armBase:Number = -100;
            var ctX:Array = new Array();
            var ctY:Array = new Array();
            var angle:Number;
            var turn:Number;    //回転方向
            var armLength:Number = 100;    //腕の長さ
            var diffArm:Number = (_isArmUp)? 20 : 0;
            if($isArmLeft){
                //左腕
                angle = ($isArmUp)? $angle += 6 : $angle -= 205;
                turn = ($isArmUp)? 1 : -1;
            }else{
                //右腕
                angle = ($isArmUp)? $angle -= 6 : $angle -= 155;
                turn = ($isArmUp)? -1 : 1;
            }
            
            //ベジェトゥイーンのコントロールポイント
            ctX.push( Math.cos((angle+(160*turn))*Math.PI/180)*(armLength*1.5) );
            ctY.push( Math.sin((angle+(160*turn))*Math.PI/180)*(armLength*1.5) +armBase);
            ctX.push( Math.cos((angle+(135*turn))*Math.PI/180)*(armLength*1.5) );
            ctY.push( Math.sin((angle+(135*turn))*Math.PI/180)*(armLength*1.5) +armBase);
            ctX.push( Math.cos((angle+(90*turn))*Math.PI/180)*(armLength*1.5) );
            ctY.push( Math.sin((angle+(90*turn))*Math.PI/180)*(armLength*1.5) +armBase);
            ctX.push( Math.cos((angle+(45*turn))*Math.PI/180)*(armLength*1.5) );
            ctY.push( Math.sin((angle+(45*turn))*Math.PI/180)*(armLength*1.5) +armBase);
            tweenObj.x = ctX;
            tweenObj.y = ctY;
            //一時的なゴール
            tweenObj.tempX = Math.cos(angle*Math.PI/180)*(armLength+diffArm);
            tweenObj.tempY = Math.sin(angle*Math.PI/180)*(armLength+diffArm) +armBase;
            //最終的なゴール
            tweenObj.goalX = Math.cos(angle*Math.PI/180)*(armLength+diffArm-30);
            tweenObj.goalY = Math.sin(angle*Math.PI/180)*(armLength+diffArm-30) +armBase;
            return tweenObj;
        }
    }
}

import flash.display.Sprite;
class IKArmature2d extends Sprite  {
    private var _rootJoint:IKJoint2d;    //基準となるジョイント
    private var _bones:Object;
    
    public function IKArmature2d () {
        _bones = new Object;
        _rootJoint = new IKJoint2d('root');
        addChild(_rootJoint);
    }
    
    public function get bones():Object {
        return _bones;
    }
    
    public function setBone(value:IKBone2d):void {
        _bones[value.id]=value;
        addChild(value);
    }
    
    public function joint($boneA:String = null, $boneB:String = null):void {
        if ($boneA) {
            if ($boneA == 'root') {
                if (_bones[$boneB]) {
                    _bones[$boneB].jointRoot(_rootJoint);
                } else {
                    trace('Error:boneが存在しません。', $boneB + '=', _bones[$boneB]);
                }
            } else if (bones[$boneB] && bones[$boneA]) {
                _bones[$boneB].setParentBone(bones[$boneA]);
                _bones[$boneA].setChildBone(bones[$boneB]);
            } else {
                trace('Error:boneが存在しません。', $boneA + '=', _bones[$boneA], $boneA + '=', _bones[$boneB]);
            }
        }
    }
}


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Matrix;
import frocessing.color.FColor;
import frocessing.color.ColorHSV;

class IKBone2d extends Sprite {
    public static const MOVE_BONE:String = 'move_bone';
    private var _tailJoint:IKJoint2d;
    private var _parentBones:Vector.<IKBone2d>;
    private var _childBones:Vector.<IKBone2d>;
    private var _boneLength:Number;                //ボーンの長さ
    private var _bone:Sprite;
    private var _id:String;                        //関連付けられたMesh2d
    private var _isRootJoint:Boolean = false;
    private var _clickPoint:Point;
    private var _gradA:Number;
    private var _gradB:Number;
    private var _mus:Number;                    //筋肉増加量
    
    public function IKBone2d ($id:String='null', $length:Number=100, $rotation:Number=0, $colorA:Number=0x006600, $colorB:Number=0x006600, $mus:Number=1) {
        _id = $id;
        _clickPoint = new Point();
        _parentBones = new Vector.<IKBone2d>();
        _childBones = new Vector.<IKBone2d>();
        _bone = new Sprite();
        addChild(_bone);
        _tailJoint = new IKJoint2d( "default", $colorB );
        addChild(_tailJoint)
        _boneLength = $length;
        drawBone();
        changeTailJoint(_boneLength);
        rotationZ = $rotation;
        _mus = $mus;
        _gradA = $colorA / 0xFFFFFF;
        _gradB = $colorB / 0xFFFFFF;
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    
    //ドラッグの仕組み
    private function onMouseOver(e:MouseEvent):void {
        changeColor(0xFF0000);
    }
    
    private function onMouseOut(e:MouseEvent):void {
        changeColor();
    }
    
    private function onMouseDown(e:MouseEvent):void {
        _clickPoint = new Point(mouseX, mouseY);
        removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMUpHandler);
        stage.addEventListener(MouseEvent.MOUSE_MOVE,onMMoveHandler);
    }
    
    
    
    private function onMUpHandler(event:MouseEvent):void {
        _clickPoint = new Point(0, 0);
        if (event.target != this) {
            changeColor();
        }
        addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMMoveHandler);
    }
    
    private function onMMoveHandler(e:MouseEvent/*$color:uint = 0x006600*/):void {
        move(_tailJoint, new Point(parent.mouseX, parent.mouseY), new Point(x, y),null,null,'mouseMove')
        
        //親と子両方に伝達
        var i:uint;
        if (_childBones.length) {
            for (i = 0; i < _childBones.length;i++) {
                _childBones[i].parentMove(this,new Point(_tailJoint.jx+x, _tailJoint.jy+y))
            }
        }
        if (_parentBones.length) {
            for (i = 0; i < _parentBones.length;i++) {
                _parentBones[i].childMove(this,new Point(x, y))
            }
        }
    }
    
    /****************************
     * 自動ボーン操作
     */
    public function boneMove($pt:Point, $deffNum:Number=NaN):void {
        if($deffNum) _clickPoint = new Point(0, $deffNum);
        move(_tailJoint, $pt, new Point(x, y),null,null,'mouseMove');
        //親と子両方に伝達
        var i:uint;
        if (_childBones.length) {
            for (i = 0; i < _childBones.length;i++) {
                _childBones[i].parentMove(this,new Point(_tailJoint.jx+x, _tailJoint.jy+y))
            }
        }
        if (_parentBones.length) {
            for (i = 0; i < _parentBones.length;i++) {
                _parentBones[i].childMove(this,new Point(x, y))
            }
        }
        _clickPoint = new Point(0, 0);
    }
    
    public function parentMove($target:IKBone2d,$pt:Point):void {
        move(null, $pt, new Point(_tailJoint.jx+x, _tailJoint.jy+y),$target,'parent')
        //親から回ってきたら、子に伝達
        var i:uint;
        if (_childBones.length) {
            for (i = 0; i < _childBones.length;i++) {
                _childBones[i].parentMove(this,new Point(_tailJoint.jx+x, _tailJoint.jy+y));
            }
        }
    }
    
    public function childMove($target:IKBone2d, $pt:Point):void {
        move(_tailJoint, $pt, new Point(x, y),$target)
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
        if (!_isRootJoint) {
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
    
    private function changeColor($color:Number=NaN):void {
        var tc:ColorTransform;
        if(!isNaN($color)){
            tc = new ColorTransform()
            tc.color = $color;
        }else{
            //割り当てた色を初期化
            tc = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
        }
        transform.colorTransform = tc;
    }
    
    //終点ジョイントの座標を変換？
    private function changeTailJoint(value:Number):void {
        tailJoint.y = -value;
        tailJoint.v3d = new Vector3D(0,-_boneLength, 0);
        var mtx:Matrix3D = new Matrix3D();
        mtx.prependRotation(rotationZ, Vector3D.Z_AXIS);
        tailJoint.v3d = mtx.transformVector(tailJoint.v3d);
    }
    
    //ボーンの回転
    //単にrotationでもいいのだが、3D化に備えあえてrotationZ&Vector3D
    override public function set rotationZ(value:Number):void {
        super.rotationZ = value;
        tailJoint.v3d = new Vector3D(0,-_boneLength, 0);
        var mtx:Matrix3D = new Matrix3D();
        mtx.prependRotation(value, Vector3D.Z_AXIS);
        tailJoint.v3d = mtx.transformVector(tailJoint.v3d);
    }
    
    override public function get rotationZ():Number {
        return super.rotationZ;
    }
    
    //終点ジョイント
    public function get tailJoint():IKJoint2d {
        return _tailJoint;
    }
    
    //JointBone(始点Jointを親BoneのtailJointに結合する)
    public function jointBone(value:IKBone2d):void {
        x = value.tailJoint.jx;
        y = value.tailJoint.jy;
        if(value){
            x += value.x
            y += value.y
        }
    }
    
    //JointRoot(始点JointをrootJointに結合する)
    public function jointRoot(value:IKJoint2d):void {
        _isRootJoint = true;
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
    
    public function get id():String {
        return _id;
    }
    
    // 筋肉量変化
    public function changeMuscul( volume:Number ):void {
        _bone.scaleY = _mus*volume + 1;
    }
    
    public function drawBone( $colorAngle:Number=0 ):void {
        var rgbA:Object = FColor.HSVtoRGB($colorAngle+120-(60*(1-_gradA)), 1, _gradA);
        var colorA:Number = (rgbA.r << 16) | (rgbA.g << 8) | (rgbA.b);
        var rgbB:Object = FColor.HSVtoRGB($colorAngle+120-(60*(1-_gradB)), 1, _gradB);
        var colorB:Number = (rgbB.r << 16) | (rgbB.g << 8) | (rgbB.b);
        //bone画像の生成
        _bone.graphics.clear();
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(_boneLength, _boneLength, 0, 0, 0);
        _bone.graphics.beginGradientFill("linear", [colorA, colorB], [1,1], [0, 255], matrix);
        _bone.graphics.moveTo(0, 0);
        _bone.graphics.lineTo(5, -7);
        _bone.graphics.lineTo(_boneLength-5, -2);
        _bone.graphics.lineTo(_boneLength, 0);
        _bone.graphics.lineTo(_boneLength-5, 2);
        _bone.graphics.lineTo(5, 7);
        _bone.graphics.endFill();
        _bone.rotation=-90;
        //
        _tailJoint.changeColor(colorB);
    }
}


import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
class IKJoint2d extends Sprite {
    private var _v3d:Vector3D;
    private var _type:String;
    
    public function IKJoint2d ($type:String = 'default', $color:Number=0x787878) {
        _type = $type;
        _v3d = new Vector3D(0, 0, 0);
        if (_type == 'root') {
            //drawRoot( $color );
        } else {
            changeColor( $color );
        }
    }
    
    public function changeColor( $color:Number ):void {
        graphics.clear();
        graphics.lineStyle(3, $color, 1);
        graphics.drawCircle(0, 0, 3);
    }
    
    
    public function set v3d(v:Vector3D):void {
        _v3d = v;
    }
    
    public function get v3d():Vector3D {
        return _v3d;
    }
    
    //rootJointの場合は、自分自身の位置を返す。
    //defaultJointは、位置、回転変換された座標を返す。
    public function get jx():Number {
        return _v3d.x;
    }
    
    public function get jy():Number {
        return _v3d.y;
    }
    
    public function get type():String {
        return _type;
    }
}


import flash.display.Sprite;
import frocessing.color.FColor;
import frocessing.color.ColorHSV;

class ClockDisk extends Sprite {
    public function ClockDisk() {
        var h:Number = 160;    //半径
        for(var i:uint=0; i<60; i++){
            var angle:Number = i*6;
            var radian:Number = angle*Math.PI/180;
            var rgb:Object = FColor.HSVtoRGB(angle+90, 1, 1);
            var color:Number = (rgb.r << 16) | (rgb.g << 8) | (rgb.b);
            var l:Number = (angle%30 == 0)? 5 : 1;    //線の長さ
            
            graphics.lineStyle(0, color);
            graphics.moveTo(Math.cos(radian)*(h-l), Math.sin(radian)*(h-l));
            graphics.lineTo(Math.cos(radian)*h, Math.sin(radian)*h);
        }
    }
}
