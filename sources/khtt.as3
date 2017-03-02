package {
    import flash.geom.Point;
    import flash.ui.Mouse;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Dynamics.*;
    import Box2D.Dynamics.Joints.*;
    public class Fui extends Sprite {
        public var spr:Sprite=new Sprite();
        public var curWorld:b2World,fuiWorld:b2World;
        public var ws:Number=465/2;
        public var sz:Number=30;
        public var boxPos:Array=[0,0,ws-sz,ws-sz,-ws+sz,ws-sz];
        public var color:Array=[0xffff00,0xff00ff,0x00ffff];
        public var curBodies:Array=new Array(),fuiBodies:Array=new Array();
        public var grav:Number=1.0;
        public var mu:Number=0.2,e:Number=0;
        public var i:int=0,j:int=0;
        public var mouseDrag:Boolean=false;
        public var bodyId:int=-1;
        public var mousePos:b2Vec2;
        public var trace:Array=new Array();
        public var stepCnt:int=128;
        public var traced:Boolean=false;
        public function Fui(){
            this.x=ws;
            this.y=ws;
            var worldAABB:b2AABB=new b2AABB();
            worldAABB.lowerBound.Set(-ws*2/100,-ws*2/100);
            worldAABB.upperBound.Set(ws*2/100,ws*2/100);
            curWorld=new b2World(worldAABB,new b2Vec2(0,grav),false);
            fuiWorld=new b2World(worldAABB,new b2Vec2(0,grav),false);
            var fu:Number=50;
            var bgBodyDef:b2BodyDef=new b2BodyDef();
            bgBodyDef.position.Set(0,0);
            var curBackground:b2Body=curWorld.CreateBody(bgBodyDef);
            var fuiBackground:b2Body=fuiWorld.CreateBody(bgBodyDef);
            var vertWall:b2PolygonDef=new b2PolygonDef(),horiWall:b2PolygonDef=new b2PolygonDef();
            vertWall.SetAsBox(fu/100,ws/100);
            horiWall.SetAsBox(ws/100,fu/100);
            vertWall.density=horiWall.density=0;
            horiWall.friction=vertWall.friction=mu;
            horiWall.restitution=0;
            vertWall.restitution=e;
            var wall:b2BodyDef=new b2BodyDef();
            wall.position.Set((-ws-fu)/100,0);
            curWorld.CreateBody(wall).CreateShape(vertWall);
            fuiWorld.CreateBody(wall).CreateShape(vertWall);
            wall.position.Set((ws+fu)/100,0);
            curWorld.CreateBody(wall).CreateShape(vertWall);
            fuiWorld.CreateBody(wall).CreateShape(vertWall);
            wall.position.Set(0,(-ws-fu)/100);
            curWorld.CreateBody(wall).CreateShape(horiWall);
            fuiWorld.CreateBody(wall).CreateShape(horiWall);
            wall.position.Set(0,(ws+fu)/100);
            curWorld.CreateBody(wall).CreateShape(horiWall);
            fuiWorld.CreateBody(wall).CreateShape(horiWall);
            for(i=0;i<3;i++){
                var boxDef:b2PolygonDef=new b2PolygonDef();
                boxDef.SetAsBox(sz/100,sz/100);
                boxDef.density=1;
                boxDef.friction=0;
                boxDef.restitution=0.8;
                var bodyDef:b2BodyDef=new b2BodyDef();
                bodyDef.position.Set(boxPos[i*2]/100,boxPos[i*2+1]/100);
                if(i==0)bodyDef.angularDamping=0.1;
                curBodies.push(curWorld.CreateBody(bodyDef));
                fuiBodies.push(fuiWorld.CreateBody(bodyDef));
                curBodies[i].CreateShape(boxDef);
                fuiBodies[i].CreateShape(boxDef);
                curBodies[i].SetMassFromShapes();
                fuiBodies[i].SetMassFromShapes();
            }
            var curJointDef:b2DistanceJointDef=new b2DistanceJointDef();
            var fuiJointDef:b2DistanceJointDef=new b2DistanceJointDef();
            curJointDef.Initialize(curBackground,curBodies[0],new b2Vec2(0,0),new b2Vec2(0,0));
            fuiJointDef.Initialize(fuiBackground,fuiBodies[0],new b2Vec2(0,0),new b2Vec2(0,0));
            curJointDef.collideConnected=fuiJointDef.collideConnected=false;
            curJointDef.frequencyHz=fuiJointDef.frequencyHz=0.2;
            curJointDef.dampingRatio=fuiJointDef.dampingRatio=0;
            curWorld.CreateJoint(curJointDef);
            fuiWorld.CreateJoint(fuiJointDef);
            this.addChild(spr);
            this.addEventListener(Event.ENTER_FRAME,frame);
            addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
            addEventListener(MouseEvent.MOUSE_UP,MouseUp);
            addEventListener(MouseEvent.MOUSE_MOVE,MouseMove);
        }
        public function frame(e:Event):void{
            if(!mouseDrag){
                curWorld.Step(0.1,10);
                if(traced){
                    addPoint();
                    fuiWorld.Step(0.1,10);
                }
            }
            spr.graphics.clear();
            spr.graphics.beginFill(0x000000);
            spr.graphics.drawRect(-ws,-ws,ws*2,ws*2);
            spr.graphics.endFill();
            if(traced){
                for(j=stepCnt-2;j>-1;j--){
                    for(i=0;i<3;i++){
                        spr.graphics.lineStyle(5,color[i]/0xff*(128-j));
                        spr.graphics.moveTo(trace[i][j].x*100,trace[i][j].y*100);
                        spr.graphics.lineTo(trace[i][j+1].x*100,trace[i][j+1].y*100);
                    }
                }
            }
            for(i=0;i<3;i++){
                var p:b2Vec2=fuiBodies[i].GetPosition();
                var a:Number=fuiBodies[i].GetAngle();
                if(i==0){
                    spr.graphics.lineStyle(5,0xffffff,0.1);
                    spr.graphics.moveTo(0,0);
                    spr.graphics.lineTo(p.x*100,p.y*100);
                }
                spr.graphics.lineStyle(3,color[i],0.2);
                spr.graphics.moveTo(p.x*100+Math.cos((0*90+45)*Math.PI/180+a)*sz*Math.sqrt(2),p.y*100+Math.sin((0*90+45)*Math.PI/180+a)*sz*Math.sqrt(2));
                for(j=0;j<4;j++){
                    spr.graphics.lineTo(p.x*100+Math.cos(((j+1)*90+45)*Math.PI/180+a)*sz*Math.sqrt(2),p.y*100+Math.sin(((j+1)*90+45)*Math.PI/180+a)*sz*Math.sqrt(2));
                }
            }
            for(i=0;i<3;i++){
                p/*var p:b2Vec2*/=curBodies[i].GetPosition();
                a/*var a:Number*/=curBodies[i].GetAngle();
                if(i==0){
                    spr.graphics.lineStyle(5,0xffffff,0.5);
                    spr.graphics.moveTo(0,0);
                    spr.graphics.lineTo(p.x*100,p.y*100);
                }
                spr.graphics.lineStyle(3,color[i]);
                spr.graphics.moveTo(p.x*100+Math.cos((0*90+45)*Math.PI/180+a)*sz*Math.sqrt(2),p.y*100+Math.sin((0*90+45)*Math.PI/180+a)*sz*Math.sqrt(2));
                for(j=0;j<4;j++){
                    spr.graphics.lineTo(p.x*100+Math.cos(((j+1)*90+45)*Math.PI/180+a)*sz*Math.sqrt(2),p.y*100+Math.sin(((j+1)*90+45)*Math.PI/180+a)*sz*Math.sqrt(2));
                }
            }
            if(mouseDrag){
                spr.graphics.lineStyle(5,color[bodyId],0.5);
                spr.graphics.moveTo(mousePos.x*100,mousePos.y*100);
                spr.graphics.lineTo(mouseX,mouseY);
            }else update(false);
        }
        public function MouseDown(e:MouseEvent):void{
            if(!mouseDrag){
                mousePos=new b2Vec2(e.stageX/100-ws/100,e.stageY/100-ws/100);
                for(var k:int=0;k<3;k++){
                    if(curBodies[k].GetShapeList().TestPoint(curBodies[k].GetXForm(),mousePos)){
                        mouseDrag=true;
                        bodyId=k;
                    }
                }
            }
        }
        public function MouseUp(e:MouseEvent):void{
            if(mouseDrag){
                update(true);
                var va:Number=2;
                var v:b2Vec2=new b2Vec2((mouseX/100-mousePos.x)/va,(mouseY/100-mousePos.y)/va);
                curBodies[bodyId].ApplyImpulse(v,mousePos);
                mouseDrag=false;
            }
        }
        public function MouseMove(e:MouseEvent):void{
            if(mouseDrag){
                update(true);
            }
        }
        public function update(b:Boolean):void{
            for(var m:int=0;m<3;m++){
                fuiBodies[m].SetXForm(curBodies[m].GetPosition(),curBodies[m].GetAngle());
                fuiBodies[m].SetLinearVelocity(curBodies[m].GetLinearVelocity());
                fuiBodies[m].SetAngularVelocity(curBodies[m].GetAngularVelocity());
            }
            var va:Number=2;
            var v:b2Vec2=new b2Vec2((mouseX/100-mousePos.x)/va,(mouseY/100-mousePos.y)/va);
            if(b)fuiBodies[bodyId].ApplyImpulse(v,mousePos);
            trace=new Array();
            for(m=0;m<3;m++)trace.push(new Array());
            for(m=0;m<stepCnt;m++){
                for(var l:int=0;l<3;l++){
                    var w:b2Vec2=new b2Vec2();
                    w.x=fuiBodies[l].GetPosition().x;
                    w.y=fuiBodies[l].GetPosition().y;
                    trace[l].push(w);
                }
                fuiWorld.Step(0.1,10);
            }
            traced=true;
        }
        public function addPoint():void{
            for(var l:int=0;l<3;l++){
                trace[l].shift();
                var w:b2Vec2=new b2Vec2();
                w.x=fuiBodies[l].GetPosition().x;
                w.y=fuiBodies[l].GetPosition().y;
                trace[l].push(w);
            }
        }
    }
}