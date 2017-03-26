// Another Alternativa3D maze :)
// use WASD + mouse to fly around
package
{
	import flash.display.*;
	import flash.events.*;

	import alternativ5.engine3d.controllers.*
	import alternativ5.engine3d.core.*
	import alternativ5.engine3d.display.*
	import alternativ5.engine3d.materials.*
	import alternativ5.engine3d.primitives.*

	[SWF(backgroundColor="0")]	
	public class Maze extends Sprite
	{
		private var maze:Array;
		private var SIZE:int = 11;
		private var N:int = 3; // don't go crazy :)

		private var q:int;
		private var colors:Array = [0x20100, 0x10200, 0x102];

		public function Maze()
		{
			scene = new Scene3D; scene.root = new Object3D; 
			view = new View; view.camera = new Camera3D; scene.root.addChild (view.camera); 
			view.width = view.height = 465; view.camera.z = -500; addChild (view); 
			wasd = new CameraController (stage); wasd.camera = view.camera; 
			wasd.setDefaultBindings ();
			wasd.checkCollisions = true; 
			wasd.collisionRadius = 3; 
			wasd.controlsEnabled = true; 
			wasd.mouseSensitivity *= 0.4; 
			wasd.speed = 20; 

			var p:Plane = new Plane (SIZE * 10, SIZE * 10);
			p.cloneMaterialToAllSurfaces (new FillMaterial (0x700000));
			p.x = (SIZE - 1) * 5; p.y = (SIZE - 1) * 5; p.z = -5;
			scene.root.addChild (p);

			p = p.clone () as Plane;
			p.x = (SIZE - 1) * 5; p.y = (SIZE - 1) * 5; p.z = N*10 -5;
			scene.root.addChild (p);

			// the reason for this fork is great idea by paq,
			// http://wonderfl.kayac.com/code/7cbc840af08054aa087e2fdf8b8f1b01b222f752
			for (q = 0; q < N; q++) {
				initialize(); 
				boutaoshi(); 
				draw(); 
			}

		}
		
		private function boutaoshi():void
		{
			for (var y:int = 2; y < SIZE - 1; y += 2)
			{
				var dx:int = 2;
				var dy:int = y;
				
				switch (Math.floor(Math.random() * 4))
				{
					case 0:
						dx++;
						break;
					case 1:
						dx--;
						break;
					case 2:
						dy++;
						break;
					case 3:
						dy--;
						break;
				}
				
				if (!maze[dx][dy])
				{
					maze[dx][dy] = true;
				}
				else
				{
					y -= 2;
				}
			}
			
			for (var x:int = 4; x < SIZE - 1; x += 2)
			{
				for (y = 2; y < SIZE - 1; y += 2)
				{
					dx = x;
					dy = y;
					
					switch (Math.floor(Math.random() * 3))
					{
						case 0:
							dy++;
							break;
						case 1:
							dy--;
							break;
						case 2:
							dx++;
							break;
					}
					
					if (!maze[dx][dy])
					{
						maze[dx][dy] = true;
					}
					else
					{
						y -= 2;
					}
				}
			}
		}
		
		private var scene:Scene3D;
		private var view:View;
		private var wasd:CameraController;

		private function draw():void
		{
			var i0:int = 1, j0:int = 1;
			for (var i:int = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (maze[i][j])
					{
						var box:Box = new Box (10, 10, 10);
						box.mobility = 1;
						box.x = i * 10; box.y = j * 10; box.z = q * 10; 
						// I like the look-and-feel of DevMaterial
						// (clockmaker's idea), but I shall use simple
						// ColorMaterial to avoid possible overhead
						for each (var s:Surface in box.surfaces) s.material =
							new FillMaterial (colors [q] *
								int (90 + 37 * Math.random ())); 
						scene.root.addChild (box); 
					}
					else
					{
						i0 = i; j0 = j;
					}
				}
			}

			view.camera.x = i0 * 10; 
			view.camera.y = j0 * 10;
			view.camera.z = q * 10; 
			view.camera.rotationX = -Math.PI / 2; 
			view.camera.rotationZ = -3;

			addEventListener (Event.ENTER_FRAME, function (e:Event):void {
				wasd.processInput (); scene.calculate ();
			});
		}
		
		private function initialize():void
		{
			maze = new Array(SIZE);
			for (var i:int = 0; i < SIZE; i++)
			{
				maze[i] = new Array(SIZE);
			}
			
			for (i = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (i == 0 || j == 0 || i == SIZE - 1 || j == SIZE - 1 || i % 2 == 0 && j % 2 == 0)
					{
						maze[i][j] = true;
					}
					else
					{
						maze[i][j] = false;
					}
				}
			}
		}
	}
}