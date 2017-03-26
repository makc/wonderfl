// forked from rsakane's 迷路自動生成(棒倒し法)
// use WASD + mouse drag
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
		
		public function Maze()
		{
			initialize();
			boutaoshi();
			draw();
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
		private var cam_da:Number = 0;
		private var cam_mx:Number = 465 / 2;

		private function draw():void
		{
			scene = new Scene3D; scene.root = new Object3D;
			view = new View; view.camera = new Camera3D; scene.root.addChild (view.camera);
  			view.width = view.height = 465; view.camera.z = -500; addChild (view);
			wasd = new CameraController (stage); wasd.camera = view.camera;

			// set up limited WASD bindings
			wasd.bindKey (65, CameraController.ACTION_LEFT);
			wasd.bindKey (68, CameraController.ACTION_RIGHT);
			wasd.bindKey (87, CameraController.ACTION_FORWARD);
			wasd.bindKey (83, CameraController.ACTION_BACK);

			wasd.checkCollisions = true;
			wasd.collisionRadius = 3;
			wasd.controlsEnabled = true;
			wasd.mouseSensitivity = 0;
			wasd.speed = 20;

			var i0:int = 1, j0:int = 1;
			for (var i:int = 0; i < SIZE; i++)
			{
				for (var j:int = 0; j < SIZE; j++)
				{
					if (maze[i][j])
					{
						var box:Box = new Box (10, 6, 10);
						box.x = i * 10; box.y = -1; box.z = j * 10;
						box.cloneMaterialToAllSurfaces (
							new FillMaterial (0xFF00, 1,
								BlendMode.NORMAL, 2, 0));
						scene.root.addChild (box);
					}
					else
					{
						i0 = i; j0 = j;
					}
				}
			}

			view.camera.x = i0 * 10;
			view.camera.z = j0 * 10;
			view.camera.rotationY = -3;

			addEventListener (Event.ENTER_FRAME, function (e:Event):void {
				view.camera.rotationY += cam_da; cam_da *= 0.9;
				wasd.processInput (); scene.calculate ();
			});

			stage.addEventListener (MouseEvent.MOUSE_MOVE, function (e:MouseEvent):void {
				if (e.buttonDown) cam_da += (mouseX > cam_mx) ? 0.005 : -0.005;
				cam_mx = mouseX;
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