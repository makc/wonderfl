package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Matrix;
	import flash.text.*;
	
	// My first use of Tweener. Brilliant library!
    import caurina.transitions.Tweener;
	import caurina.transitions.properties.CurveModifiers;
	
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor="0x38502A")]
	public class TriangleTrick extends Sprite {
		private const W:Number = stage.stageWidth;
		private const H:Number = stage.stageHeight;
		
		private const ORIGIN_X:Number = W * 0.06;
		private const ORIGIN_Y:Number = H * 0.63;
		private const GRID_SPACING:int = 30;
		
		private var polygons:Vector.<Shape> = new Vector.<Shape>();
		private var polygonData:Array = [
			{ x:[0, 5], y:[0, 2], bezier:{ x:0, y:9, rotation:20 }, color:0xFF3300, vertices:[0, 0,  8, 0,  8, 3] }, 
			{ x:[8, 0], y:[3, 0], bezier:{ x:4, y:4, rotation:-5 }, color:0x0033FF, vertices:[0, 0,  5, 0,  5, 2] }, 
			{ x:[8, 5], y:[1, 0], bezier:{ x:5, y:1, rotation:10 }, color:0xFFFF33, vertices:[0, 0,  2, 0,  2, 1,  5, 1,  5, 2,  0, 2] }, 
			{ x:[8, 8], y:[0, 0], bezier:{ x:9, y:-2.5, rotation:20 }, color:0x00FF00, vertices:[0, 0,  5, 0,  5, 2,  2, 2,  2, 1,  0, 1] }, 
		];
		private var triangleState:int = 0;
		
		private const MESSAGES:Array = [
			// Want some nifty messages but I'm not good at English... Please help!
			"Click it!", 
			"What the hell happened!?", 
			"Check it carefully!", 
			"Don't you understand?", 
		];
		private var messageNo:int = 0;
		private var textField:TextField = new TextField();
		
		private var circle:Shape = new Shape();
		private var cursor:Shape = new Shape();
		
		private const CURSOR_Y:Number = H * 0.95;
		
		public function TriangleTrick():void {
			CurveModifiers.init();
			
			var grid:Shape = new Shape();
			var g:Graphics = grid.graphics;
			g.lineStyle(1, 0x000000, 0.2);
			for (var i:int = -30; i < 30; i++) {
				g.drawRect(ORIGIN_X + GRID_SPACING * i + 2, -400, 0, 1600);
				g.drawRect(-400, ORIGIN_Y + GRID_SPACING * i + 2, 1600, 0);
			}
			addChild(grid);
			
			textField.defaultTextFormat = new TextFormat("Helvetica", 20, 0x444444, true, false);
			textField.text = MESSAGES[messageNo];
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.selectable = false;
			textField.x = W * 0.42;
			textField.y = H * 0.73;
			textField.filters = [ new GlowFilter(0xFFFFFF, 1, 40, 30, 8) ];
			addChild(textField);
			
			// Couldn't use DisplayObject.transform to zoom because lines' thickness is treated as integer.
			function toPixelX(graphX:Number):Number { return ORIGIN_X + graphX * GRID_SPACING; }
			function toPixelY(graphY:Number):Number { return ORIGIN_Y - graphY * GRID_SPACING; }
			
			var triangle:Sprite = new Sprite();
			for (i = 0; i < polygonData.length; i++) {
				var pd:Object = polygonData[i];
				
				// scale polygon data
				for (var j:int = 0; j < pd.x.length; j++) {
					pd.x[j] = toPixelX(pd.x[j]);
					pd.y[j] = toPixelY(pd.y[j]);
				}
				pd.bezier.x = toPixelX(pd.bezier.x);
				pd.bezier.y = toPixelY(pd.bezier.y);
				for (j = 0; j < pd.vertices.length; j += 2) {
					pd.vertices[j    ] *=  GRID_SPACING;
					pd.vertices[j + 1] *= -GRID_SPACING;
				}
				
				// create a polygon
				var polygon:Shape = new Shape();
				g = polygon.graphics;
				g.lineStyle(4, 0xFFFFFF);
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(GRID_SPACING * 4, GRID_SPACING * 4, 70 * Math.PI / 180, 0, -95);
				g.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, pd.color], [0.5, 0.6], [0, 255], matrix);
				var commands:Vector.<int> = Vector.<int>([GraphicsPathCommand.MOVE_TO]);
				for (j = 0; j < pd.vertices.length / 2; j++) {
					commands.push(GraphicsPathCommand.LINE_TO);
				}
				g.drawPath(commands, Vector.<Number>(pd.vertices.concat(pd.vertices[0], pd.vertices[1])));
				g.endFill();

				polygon.x = pd.x[0];
				polygon.y = pd.y[0];
				triangle.addChild(polygon);
				polygons.push(polygon);
			}
			triangle.filters = [ new DropShadowFilter(4, 45, 0x000000, 0.5, 0, 0) ];
			addChild(triangle);
			
			g = circle.graphics;
			g.lineStyle(8, 0xFF0000, 0.8);
			g.drawCircle(toPixelX(7.5), toPixelY(0.5), 1.2 * GRID_SPACING);
			circle.alpha = 0;
			addChild(circle);
			
			g = cursor.graphics;
			g.beginFill(0xFFFFFF);
			g.drawPath(Vector.<int>([1, 2, 2, 2]), Vector.<Number>([0, 0,  -1, -1.7,  1, -1.7,  0, 0]));
			cursor.x = W * 0.945;
			cursor.y = CURSOR_Y;
			cursor.scaleX = cursor.scaleY = 5;
			cursor.filters = [ new DropShadowFilter(3, 45, 0x000000, 0.5, 0, 0) ];
			addChild(cursor);
			enableClick();
		}
		
		private function enableClick():void {
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			tickCursor();
		}
		
		private function disableClick():void {
			stage.removeEventListener(MouseEvent.CLICK, clickHandler);
			Tweener.removeTweens(cursor);
			cursor.alpha = 0;
		}
		
		private function clickHandler(event:MouseEvent):void {
			disableClick();
			
			// an easy way to flip integers
			triangleState = 1 - triangleState;
			
			for (var i:int = 0; i < polygons.length; i++) {
				Tweener.addTween(polygons[i], { 
					// Which transition type do you like?
					time:0.7, transition:"easeOutCubic", 
					x:polygonData[i].x[triangleState], 
					y:polygonData[i].y[triangleState], 
					rotation:0, 
					_bezier:polygonData[i].bezier} );
			}
			
			if (triangleState == 1) {
				circle.x = -0;
				circle.y = -30;
				Tweener.addTween(circle, { delay:0.7, time:0.6, transition:"easeOutElastic", x:0, y:0 } );
				Tweener.addTween(circle, { delay:0.7, time:0.2, transition:"easeOutQuart", alpha:1 });
			} else {
				Tweener.addTween(circle, { time:0.2, transition:"easeOutQuart", alpha:0 });
			}
			
			if (++messageNo >= MESSAGES.length) {
				messageNo = 1;
			}
			textField.text = MESSAGES[messageNo];
			textField.alpha = 0;
			Tweener.addTween(textField, { delay:0.6, time:0.2, transition:"easeInQuart", alpha:1, onComplete:enableClick } );
		}
		
		private function tickCursor():void {
			cursor.y = CURSOR_Y;
			Tweener.addTween(cursor, { time:0.25, transition:"linear", y:CURSOR_Y + 3 } );
			Tweener.addTween(cursor, { time:0.1, transition:"easeOutSine", alpha:1 } );
			Tweener.addTween(cursor, { delay:0.15, time:0.1, transition:"easeOutSine", alpha:0 } );
			Tweener.addTween(cursor, { delay:0.45, onComplete:tickCursor } );
		}
	}
}
