package  
{
	import flash.display.Sprite;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
        [SWF(backgroundColor="0x000000", frameRate="30")]
	public class Globe extends Sprite
	{
		private var world:Sprite

		public function Globe() 
		{
			addChild(world = new Sprite()).transform.perspectiveProjection = new PerspectiveProjection()
			
			stage.scaleMode = 'noScale'
			stage.align = 'TL'
			stage.quality = 'LOW'
			stage.addEventListener('resize', onStageResize)
			onStageResize()
			
			for (var c:Number = 0; c < 500; c++ )
			{
				with (world.addChild(new Sprite()))
				{
					with (addChild(new Sprite()))
					{
						graphics.beginFill(0xffffff * Math.random(), .5)
						graphics.drawRect( -20, -20, 40, 40)
						//graphics.drawCircle(0,0,5+10*Math.random())
						z = 300 * Math.random() 
						alpha = 0
						blendMode = 'add' 
					}
					rotationY = Math.random() * 360
					rotationX = Math.random() * 360
				}
			}

			addEventListener('enterFrame', onEnterFrame)
		}
		
		private function onEnterFrame(...e):void 
		{
			world.rotationY += .5
			world.rotationX += .1
			var child:Sprite
			for (var c:Number = 0; c < world.numChildren; c++ )
			{
				child = (world.getChildAt(c) as Sprite)
				child = (child.getChildAt(0) as Sprite)
				if (child.z++ > 300) child.z = 0
				child.alpha = 1 - (child.z /300)
			}
		}

		private function onStageResize(...e):void 
		{
			world.x = stage.stageWidth / 2
			world.y = stage.stageHeight / 2
			world.transform.perspectiveProjection.projectionCenter = new Point( world.x , world.y )
		}		
	}

}