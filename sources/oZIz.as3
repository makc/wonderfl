package  
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	[SWF(backgroundColor="0x000000", frameRate="30")]
	public class Sphere extends Sprite
	{
		private var screen:Sprite
		
		private var vertices:Vector.<Number>
		private var indices:Vector.<int>
		private var uvtData:Vector.<Number>		
		private var matrix3D:Matrix3D 					= new Matrix3D()
		private var projectedVertices:Vector.<Number>	= new Vector.<Number>()

		private var rx:Number = 0
		private var ry:Number = 0
		private var radius:Number = 200
		private var detail:Number = 50
		private var stripes:Number = 7
		private var fill:Boolean = true

		public function Sphere() 
		{
			addChild(screen = new Sprite())

			var tf:TextField = new TextField()
			tf.defaultTextFormat = new TextFormat('verdana', 10,0xffffff)
			tf.x = tf.y = 5
			tf.autoSize = 'left'
			tf.selectable = false
			tf.text = 'left/right : change detail\nup/down : change stripes\nspace : toggle fill'
			addChild(tf)

			init()

			stage.align = 'TL'
			stage.quality = 'MEDIUM'
			stage.scaleMode = 'noScale'
			stage.addEventListener('resize', onStageResize)
			stage.addEventListener ('enterFrame', render)
			stage.addEventListener('keyDown', onKeyDown)
			onStageResize()
		}
		
		private function init():void
		{
			vertices = new Vector.<Number>()
			indices = new Vector.<int>()
			
			var frh:Number = radius * 2 / (stripes * 2 +1)
			var yc:Number = -radius 
			var rad:Number 
			var last:Boolean
			var yUp:Number
			var yDown:Number
			var rUp:Number
			var rDown:Number
			var i:Number
			
			for (var s:Number = 0; s < stripes ; s++ )
			{
				yUp = yc += frh 
				yDown = yc += frh
				rUp = getR(yUp,radius)
				rDown = getR(yDown, radius)
				i = detail*2*s
				
				for (var c:Number = 0; c < detail; c++ )
				{
					rad = (2 * Math.PI) / detail * c
					vertices.push(Math.cos(rad) * rUp, Math.sin(rad) * rUp, yUp )
					vertices.push(Math.cos(rad) * rDown, Math.sin(rad) * rDown, yDown )

					last = c == (detail - 1)
					indices.push(i + c * 2, i + c * 2 + 1, i + (last?0:c * 2 + 2))
					indices.push(i + c * 2 + 1, i +  (last?1:c * 2 + 3), i +  (last?0:c * 2 + 2))
				}
			}

			uvtData = new Vector.<Number>(indices.length)
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case 32: { fill = !fill;  break }
				case 37: { detail = Math.max(3, detail - 1); init(); break }
				case 38: { stripes = Math.min(20, stripes + 1);	init(); break }				
				case 39: { detail = Math.min(80, detail + 1); init(); break }
				case 40: { stripes = Math.max(1, stripes - 1); init(); break }
			}
		}		
		
		private function getR(a:Number, c:Number):Number { return Math.sqrt(c * c - a * a) }
		
		private function render(...e):void
		{
			matrix3D = new Matrix3D()
			matrix3D.prependRotation( rx+=.5 , Vector3D.X_AXIS)
			matrix3D.prependRotation( ry+=1.25  , Vector3D.Y_AXIS)

			Utils3D.projectVectors(matrix3D, vertices, projectedVertices, uvtData)

			screen.graphics.clear()			
			screen.graphics.lineStyle(0, fill?0:0x0080FF, fill?.2:1)
			if(fill)screen.graphics.beginFill(0xffffff)
			screen.graphics.drawTriangles(projectedVertices, indices, null, 'negative')
			if(fill)screen.graphics.beginFill(0x0080FF)
			screen.graphics.drawTriangles(projectedVertices, indices, null, 'positive')
			screen.graphics.endFill()
		}
		
		private function onStageResize(...e):void 
		{
			screen.x = stage.stageWidth / 2 
			screen.y = stage.stageHeight / 2 
		}
	}
}