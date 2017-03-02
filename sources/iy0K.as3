// gentic algorithm test2
// the road to Unko is looooong.

/*
うんこへの道は長く険しい
時には100世代ほどかかることもあるという
だが私たちは目指し続ける
そこにうんこがある限り
*/


package 
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickContacts;
	import com.actionsnippet.qbox.QuickObject;
	import com.bit101.components.Label;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Sine;
	import net.wonderfl.widget.Wanco;


	[SWF(width=465, height=465, frameRate=30, backgroundColor=0x333333)]
	public class GameStage extends MovieClip
	{
		private var box:QuickBox2D;
		private var a1:QuickObject;
		private var popul:Population;
		private var time:Number = 0;
		private var lifeCycle:Number = 200;
		private var contact:QuickContacts;
		private var j1:QuickObject;
		private var j2:QuickObject;
		private var n1:QuickObject;
		private var k:QuickObject;
		private var p1:QuickObject;
		private var p2:QuickObject;
		private var AddedCount:Number = 0;
		private var n2:QuickObject;
		private var o:QuickObject;
		private var disp:Sprite;
		private var gen:Label;
                  private var un:Label;
                   private var unCount:int = 0;
		private var popul2:Population;
		public function GameStage():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			createBoxWorld();
			disp = new Sprite();
			addChild(disp);
		        var w:Wanco = new Wanco();
                            disp.addChild(w);
                            w.x = 220;
                            w.y = 285;
                            w.scaleX = 1.3;
                            w.scaleY = 1.4;
			gen = new Label(disp, 15, 15, "aa");
                            un = new Label(disp, 15, 25, "unko = 0");
			popul = new Population(box);
			addEventListener(Event.ENTER_FRAME, onEnter);
			//stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function createBoxWorld():void
		{
			box = new QuickBox2D(this, { gravityX:0.0, gravityY:0, 
										iterations: 8, timeStep: 1 / 30, 
										bounds: [ -50, -100, 100, 100], debug:true, 
										simpleRender:false, renderJoints:true, 
										frim:false, customMouse:false } );
			box.setDefault( { categoryBits:0x01, maskBits:0x04 , density:0.1, restitution:0.1 } );
			box.w.m_debugDraw.m_drawFlags = 0x0001;
			box.createStageWalls();
			var u:QuickObject = box.addPoly( { x:7.5, y:7 , density:0, categoryBits:0x01, maskBits:0x04 ,
				points:[-3.82,-10.03,-3.09,4.07,5.54,2.8,4.58,-2.83,3.04,2.1,-2.29,2.77,-2.82,-4.6] } );
			n2 = box.addPoly( { x:9.5, y:3.5, density:0.1, 
				points:[ -0.34,-0.58,-0.47,0.22,-2.88,1.49,0.19,0.82,2.93,0.89,0.29,0.16] } );
			
			
			p2 = box.addCircle( { radius:0.1, x:9.5, y:3.5, density:0 } );
			j2 = box.addJoint( { type:"revolute", a:p2.body, b:n2.body , enableMotor:true, motorSpeed:-1.2, maxMotorTorque:150} );
			
			var goal:QuickObject = box.addPoly( { x:7.5, y:9, density:0, categoryBits:0x10, 			points:[ -0.14,-1.69,-1.31,0.08,0,0.5,1.1,-0.31] } );
			contact = box.addContactListener();
			contact.addEventListener(QuickContacts.ADD, onADD);
			//contact.addEventListener(QuickContacts.PERSIST, onPersist);
			contact.addEventListener(QuickContacts.REMOVE, onRemove);
			
			
			box.start();
			box.mouseDrag();
			
			
		}
		
		private function onRemove(e:Event):void 
		{
			var body1:b2Body = contact.currentPoint.shape1.GetBody();
			var shape1:b2Shape = contact.currentPoint.shape1;
			var body2:b2Body = contact.currentPoint.shape2.GetBody();
			var shape2:b2Shape = contact.currentPoint.shape2;
			if (shape1.m_filter.categoryBits == 0x00 ) body1.PutToSleep();
			if (shape2.m_filter.categoryBits == 0x00) body2.PutToSleep();
		}
		
		private function onPersist(e:Event):void 
		{
		}
		
		private function onADD(e:Event):void 
		{
			var body1:b2Body = contact.currentPoint.shape1.GetBody();
			var shape1:b2Shape = contact.currentPoint.shape1;
			var body2:b2Body = contact.currentPoint.shape2.GetBody();
			var shape2:b2Shape = contact.currentPoint.shape2;
			if ((shape1.m_filter.categoryBits == 0x10 && shape2.m_filter.categoryBits == 0x04) ||
                                (shape1.m_filter.categoryBits == 0x04 && shape2.m_filter.categoryBits == 0x10) ) 
                            {     unCount += 1;
                                  un.text = "unko = " + unCount;
            }
			if (shape1.m_filter.categoryBits == 0x04 )
			{
				//body1.m_linearVelocity = new b2Vec2();
				body1.SetLinearVelocity(new b2Vec2());
				body1.PutToSleep();
				AddedCount += 1;
				shape1.m_filter.categoryBits = 0x00;
				shape1.m_filter.maskBits = 0x00;
				body1.m_userData = true;
			}
			if (shape2.m_filter.categoryBits == 0x04)
			{
				body2.SetLinearVelocity(new b2Vec2());
				body2.PutToSleep();
				AddedCount += 1;
				shape2.m_filter.categoryBits = 0x00;
				shape2.m_filter.maskBits = 0x00;
				body2.m_userData = true;
			}
			
			
		}
		private function unko():void
		{
                            unCount += 1;
                            un.text = "unko = " + unCount;
			 		}
		private function onClick(e:MouseEvent):void 
		{
			disp.graphics.beginFill(0xffffff);
			disp.graphics.drawCircle(320, 370, 40);
			disp.graphics.drawCircle(400, 130, 40);
			disp.graphics.drawCircle(250, 250, 40);

		}
		
		private function onEnter(e:Event = null):void 
		{
			gen.text = "generation = " + popul.generation;
			if (time < lifeCycle && AddedCount < Population.NUM)
			{
				popul.live();
				time += 1;
			}else {
				lifeCycle += 2;
				AddedCount = time = 0;
				n2.angle = 0;
				popul.destroy();
				popul.calcFitness();
				popul.naturalSelection();
				popul.generate();
				
			}
		}
		
			
		
	}
	
}
import com.actionsnippet.qbox.QuickBox2D;
import com.actionsnippet.qbox.QuickObject;
import flash.geom.Point;

class Population
{
	public static var  NUM:int = 85;
	public const dnaSize:int =  Math.floor(465 / Creature.Scale) * Math.floor(465 / Creature.Scale);
	
	private const CreatureSize:Number = 0.05;
	private const MutationRate:Number = 0.04;
	public var population:Vector.<Creature>;
	private var darwin:Vector.<Creature>;
	public var generation:int;
	public var box:QuickBox2D;
	private var boxArray:Array = new Array();
	private var startPoint:Point = new Point(50,50);
	public function Population(b:QuickBox2D, ss:Boolean = false)
	{
		box = b;
		if (ss) startPoint = new Point(60, 50);
		population = new Vector.<Creature>();
		darwin = new Vector.<Creature>();
		generation = 0;
		for (var i:int = 0; i < NUM; i++) 
		{
			
			var q:QuickObject = box.addCircle( { x:2, y:2, radius:CreatureSize, density:0.1 , categoryBits:0x04, maskBits:0x11, allowSleep:false } );
			boxArray.push(q);
		}
		for (var ii:int = 0; ii < NUM; ii++) 
		{
			
			population[ii] = new Creature(boxArray[ii], new Point(startPoint.x + Math.random() , startPoint.y + Math.random()), new DNA(dnaSize), NUM);
		}
	}
	
	public function live():void
	{
		for each(var c:Creature in population)
		{
			c.run();
		}
	}
	public function calcFitness():void
	{
		for each(var c:Creature in population)
		{
			c.calcFitness();
		}
	}
	public function naturalSelection():void
	{
		var totalFitness:Number = getTotalFitness();
		
		darwin.length = 0;
		for each(var c:Creature in population)
		{
			var f:Number = c.fitness / totalFitness;
                           f = Math.floor(f*f*3000);
			for (var i:Number = 0; i < f; i++) 
			{
				darwin.push(c);
			}
			
		}
	}
	public function generate():void
	{
		for (var i:int = 0; i < NUM; i++) 
		{
			
			var m:int = Math.floor(Math.random() * darwin.length);
			var d:int = Math.floor(Math.random() * darwin.length);
			var mom:Creature = darwin[m];
			var dad:Creature = darwin[d];
			
			var childGene:DNA = mom.gene.mate(dad.gene);
			childGene.mutate(MutationRate);
			
			var q:QuickObject = getBox(i);   //boxArray[i];//box.addCircle( { x:2, y:2, radius:CreatureSize, density:0.1 , categoryBits:0x08, maskBits:0x01, allowSleep:false} );
			q.body.m_shapeList.m_filter.categoryBits = 0x04;
			q.body.m_shapeList.m_filter.maskBits = 0x11;
			q.body.m_userData = false;
			q.body.WakeUp();
			population[i] = new Creature(q,  new Point(startPoint.x +Math.random()*0.1, startPoint.y+Math.random()*0.1), childGene, NUM);
			
		}
		generation += 1;
	}
	private function getBox(i:int):QuickObject
	{
		if (boxArray.length <= i) {
			var a:QuickObject = box.addCircle( { x:2, y:2, radius:CreatureSize, density:0.1 , categoryBits:0x04, maskBits:0x11, allowSleep:false } );
			boxArray.push(a);
			return a;
		}else {
			return boxArray[i];
		}
	}
	private function getTotalFitness():Number
	{
		var f:Number = 0;
		for each(var c:Creature in population)
		{
			f += c.fitness;
		}
		return f;
	}
	public function destroy():void
	{
		for each(var c:Creature in population) {
			//c.obj.destroy();
		}
	}
}


import flash.geom.Point;
import com.actionsnippet.qbox.QuickObject;

class Creature
{
	public static const Scale:int = 16;
	private static var check:Vector.<Point> = new Vector.<Point>(4);
	
	private const CheckDistance:Number = 60;
	private var loc:Point;
	private var vel:Point;
	private var acc:Point;
	
	public var fitness:Number =0;
	public var gene:DNA;
	public var stopped:Boolean = false;
	public var finishedOrder:int;
	public var recordDist:Number;
	
	public var obj:QuickObject;
	
	private var checks:Array = new Array(false, false, false, false);
	
	private var now:int = 0;
	public function Creature(o:QuickObject, l:Point, d:DNA, f:int)
	{
		check[0] = new Point(320, 370);
		check[1] = new Point(400, 110);
		check[2] = new Point(210, 90);
		check[3] = new Point(250, 250);
		
		loc = l.clone();
		vel = new Point(0, 0);
		acc = new Point(0, 0);
		gene = d;
		finishedOrder = f;
		recordDist = 465;
		obj = o;
		obj.body.m_userData = false;	
		
	}
	public function calcFitness():void
	{
		if (obj.body.m_userData == false) fitness *= 0.1;
                    if(checks[3] == true) fitness += 5;
		//fitness = (1 / Math.pow(finishedOrder, 1.5)) * (1 / Math.pow(d, 6));
		for (var i:int = 0; i < checks.length; i++) 
		{
			if (checks[i] == true)
			{
				fitness += i * 0.5;
				checks[i] = false;
			}
		}
		
	}
	public function run():void
	{
		
		if (obj.body.m_userData == false)
		{
			update();
			var d:Number = Point.distance(loc, check[now]);

			if (d < CheckDistance) 
			{
				checks[now] = true;
				if(now < 3) now = now + 1;
			}				

			var f:Number = 0.001 / (0.001 + d * d * d);
			f = f * (now*20+1);
			fitness += f;
		}
		
	}
	public function update():void
	{
		
		var xx:int = Math.floor(loc.x / Scale);
		var yy:int = Math.floor(loc.y / Scale);
		acc = acc.add(gene.dna[xx + yy * Math.floor(465 / Scale)]);
		vel = vel.add(acc);
		if (vel.length > 8) vel.normalize(8);
		loc = loc.add(vel);
		acc.normalize(0);
		
		obj.x = loc.x/30;
		obj.y = loc.y/30;
		
	}
	
	
	
}

class DNA
{
	public var dna:Vector.<Point>;
	public function DNA(num:int)
	{
		dna = new Vector.<Point>(num, true);
		for (var i:int = 0; i < num; i++) 
		{
			dna[i] = getNewVec();
		}
	}	
	public function mate(partner:DNA):DNA
	{
		var child:Vector.<Point> = this.dna.concat();
		var crossover:int = Math.floor(Math.random() * dna.length);
		for (var i:int = 0; i < dna.length; i++) 
		{
			if (crossover < i) child[i] = partner.dna[i];
		}
		
		var newDNA:DNA = new DNA(dna.length);
		newDNA.dna = child;
		return newDNA;
	}
	
	public function mutate(p:Number):void
	{
		for (var i:int = 0; i < dna.length; i++) 
		{
			if (Math.random() < p) dna[i] = getNewVec();
		}
	}
	private function getNewVec():Point
	{
		var p:Point = new Point(Math.random() * 2 - 1, Math.random() * 2 - 1);
		p.normalize(1);
		return p;
	}
	
}









