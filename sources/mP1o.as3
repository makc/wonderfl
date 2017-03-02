/**
* 3D Typography
* 参照 : http://clockmaker.jp/blog/2008/12/papervision_vector_font/
*/
package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.view.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Text3D;
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.Tweener;
	
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0")]
	
	public class Main extends BasicView 
	{
		public function Main():void 
		{
			CurveModifiers.init()
			stage.quality = StageQuality.MEDIUM;
 			motion();
			stage.addEventListener(MouseEvent.CLICK, motion);
			startRendering();
		}
		
		private function motion(e:Event = null):void
		{
			// create letter
			var text:TextField = new TextField();
			text.htmlText = "<font face='Arial' size='14'>PV3D</font>";
			text.autoSize = "left";
			
			var cap:BitmapData = new BitmapData(text.textWidth, text.textHeight, true, 0xFFFFFFFF);
			cap.draw(text);
			//addChild(new Bitmap(cap))
			
			var wrap:DisplayObject3D = scene.addChild(new DisplayObject3D());
			
			// particle motion
			var cnt:int = 0;
			for (var i:int = 0; i < text.textWidth; i++ )
			{
				for (var j:int = 0; j < text.textHeight; j++ )
				{
					if (cap.getPixel(i, j) == 0xFFFFFF) continue;
					
					// A-Z
					var char:String = String.fromCharCode(65 + 25 * Math.random() | 0);
					
					// letter
					var lettermat:Letter3DMaterial = new Letter3DMaterial();
					lettermat.fillColor = 0xFFFFFF * Math.random();
					var word:Text3D = new Text3D(char , new HelveticaBold() , lettermat);
					
					word.x = 1000 * Math.random() - 500 - 500;
					word.y = 1000 * Math.random() - 500;
					word.z = -5000;
					word.scale = 1;
					word.rotationZ = 720 * Math.random();
					wrap.addChild(word);
					
					Tweener.addTween(word,
					{
						x : (i - text.textWidth / 2) * 30,
						y : (text.textHeight / 2 - j) * 30,
						z : 0,
						scale : 0.5,
						rotationZ: 0,
						_bezier : [{x : 1000, y : 0}],
						time : 5,
						transition : "easeInOutExpo",
						delay : cnt++ * 0.0175
					});
				}
			}
			
			// wrap motion
			wrap.z = 4000;
			Tweener.addTween(wrap,
			{
				z : -1000,
				time : 10,
				transition : "easeInExpo",
				onComplete : function():void
				{
					scene.removeChild(wrap);
				}
			});
            
			// camera motion
			camera.x = -200
			Tweener.addTween(camera,
			{
				x : 200,
				time : 10,
				transition : "easeInExpo"
			});
		}
		
	}
}