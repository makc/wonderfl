package {
	import com.bit101.components.Label;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	/**
	 * Демка для объяснения принципа работы генетических алгоритмов.
	 * @author makc
	 */
	public class GA extends Sprite {
		public var phase:Label;
		public var target:Target;
		public var delay:int = 4000;
		public var population:Vector.<Creature>;
		public function GA () {
			stage.scaleMode = "noScale";
			phase = new Label (this, 10, 10);
			addChild (target = new Target);
			target.x = 200; target.y = CoordinateTransform.screenY (0);
			stage.addEventListener (MouseEvent.CLICK, changeTarget);

			// создаём популяцию из 3-х случайных особей
			population = new <Creature> [new Creature, new Creature, new Creature];
			population [0].gene = 30 * (1 + Math.random ());
			population [1].gene = 30 * (1 + Math.random ());
			population [2].gene = 30 * (1 + Math.random ());

			// и запускаем алгоритм
			calculateFitness ();
		}

		private function calculateFitness ():void {
			startNewPhase ("FITNESS CALCULATION\n" +
				"CIRCLE SIZE IS PROPORTIONAL TO FITNESS");

			for each (var c:Creature in population) {
				// устанавливаем фитнес равным модулю высоты траектории над целью
				c.fitness = Math.abs (Physics.yx (Number (c.gene), CoordinateTransform.actualX (target.x)));

				drawCreature (c, 0x9F9F9F, true);
			}

			waitAndCall (makeOffspring);
		}
		
		private function makeOffspring ():void {
			startNewPhase ("SELECTION, CROSSOVER & MUTATION\n" +
				"RED IS DEAD, GREEN ARE PARENTS, BLUE IS NEW GENERATION");

			// сортируем популяцию по фитнесу
			population.sort (Creature.compare);

			drawCreature (population [0], 0xFF00);
			drawCreature (population [1], 0xFF00);
			drawCreature (population [2], 0xFF0000);

			// особь 2 - лузер, её место займт потомок особей 0 и 1
			population [2].gene = 0.5 * (
				Number (population [0].gene) +
				Number (population [1].gene)
			);

			// этот потомок может быть как лучше, так и хуже своих родителей;
			// чтобы увеличить его шансы во втором случае, подвергнем его гены мутации
			population [2].gene = Number (population [2].gene) + 10 * (Math.random () - Math.random ())

			drawCreature (population [2], 0x7FFF);

			waitAndCall (calculateFitness);
		}

		private function waitAndCall (f:Function):void {
			delay = 100 + (delay - 100) * 0.9; setTimeout (f, delay);
		}

		private function changeTarget (e:MouseEvent):void {
			target.x = Math.max (mouseX, CoordinateTransform.screenX (50));
		}

		private function startNewPhase (text:String):void {
			graphics.clear ();
			graphics.lineStyle (0, 0x7f7f7f);
			var y0:Number = CoordinateTransform.screenY (0);
			graphics.moveTo (0, y0); graphics.lineTo (465, y0);
			phase.text = text;
		}

		private function drawCreature (c:Creature, color:uint, showFitness:Boolean = false):void {
			graphics.lineStyle (0, color);
			var x0:Number = CoordinateTransform.screenX (0);
			var x1:Number = target.x;
			var y0:Number = CoordinateTransform.screenY (0);
			graphics.moveTo (x0, y0);
			for (var xi:int = x0 + 5; xi < 465; xi += 5) {
				var yi:Number = CoordinateTransform.screenY (
					Physics.yx (Number (c.gene),
						CoordinateTransform.actualX (xi)
					)
				);
				graphics.lineTo (xi, yi);
				if (yi > 465) break;
			}
			if (showFitness) {
				graphics.beginFill (0xFFFFFF);
				var y1:Number = CoordinateTransform.screenY (
					Physics.yx (Number (c.gene),
						CoordinateTransform.actualX (x1)
					)
				);
				graphics.drawCircle (x1, y1, 0.2 * c.fitness);
				graphics.endFill ();
			}
		}
	}
}

/** уравнения движения нашего тела под действием силы
    тяжести (не содержат решения задачи в явном виде) */
class Physics {
	static private var g:Number = 10;
	/** дальность полёта в момент t */
	static public function x (v:Number, t:Number):Number {
		var vx:Number = v / Math.SQRT2;
		return vx * t;
	}
	/** высота траектории в момент t */
	static public function y (v:Number, t:Number):Number {
		var vy:Number = v / Math.SQRT2;
		return vy * t - g * t * t / 2;
	}
	/** высота траектории над точкой x */
	static public function yx (v:Number, x:Number):Number {
		var vx:Number = v / Math.SQRT2;
		var t:Number = x / vx;
		return y (v, t);
	}
}

/** преобразования координат для рисования на экране */
class CoordinateTransform {
	static public function screenX (x:Number):Number { return x + 50; }
	static public function actualX (x:Number):Number { return x - 50; }
	static public function screenY (y:Number):Number { return 200 - y; }
	static public function actualY (y:Number):Number { return 200 - y; }
}

/** виртуальная "особь" */
class Creature {
	public var gene:Object;
	public var fitness:Number;

	static public function compare (c1:Creature, c2:Creature):Number {
		if (c1.fitness > c2.fitness) return +1;
		if (c1.fitness < c2.fitness) return -1;
		return 0;
	}
}

import flash.display.Shape;
class Target extends Shape {
	public function Target () {
		graphics.lineStyle (5, 0, 1, false, "normal", "none");
		graphics.moveTo (-5, -5);
		graphics.lineTo (+5, +5);
		graphics.moveTo (-5, +5);
		graphics.lineTo (+5, -5);
	}
}