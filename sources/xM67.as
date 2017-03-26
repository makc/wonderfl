// fork to add 3rd dimension :)
package {
	import com.bit101.components.*;
	import flash.display.*;
	import flash.net.*;
	import flash.system.*;
	import flash.geom.*;
	import flash.events.*;
	public class FlashTest extends Sprite {
		
		private static const CONTEXT:LoaderContext = new LoaderContext(true);
		
		private const cx:Number = transform.perspectiveProjection.projectionCenter.x;
		private const cy:Number = transform.perspectiveProjection.projectionCenter.y;
		private const cz:Number = transform.perspectiveProjection.focalLength;
		
		private const back:Loader = new Loader();
		private const front:Loader = new Loader();
		private const m3:Matrix3D = new Matrix3D();
		private const handles:Vector.<Sprite> = new Vector.<Sprite>(4, true);
		private const box:Shape = new Shape();
		
		private const obj:Sprite = new Sprite;
		private const objX:Shape = new Shape;
		private const objY:Shape = new Shape;
		private const objZ:Shape = new Shape;
		private var backURL:InputText;
		private var frontURL:InputText;
		private var m3Text:Text;
		
		public function FlashTest() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Security.loadPolicyFile('http://farm4.static.flickr.com/crossdomain.xml');
			
			addChild(back);
			front.contentLoaderInfo.addEventListener(Event.COMPLETE, recalc);
			obj.transform.matrix3D = m3;
			addChild(obj); obj.addChild(front); obj.addChild(objX); obj.addChild(objY); obj.addChild(objZ);
			addChild(box);
			
			backURL = new InputText(this, 10, 10, 'http://farm4.static.flickr.com/3358/3197122530_29f4d9dc8f.jpg');
			backURL.width = 340;
			backURL.alpha = 0.5;
			new PushButton(this, 360, 10, 'Load BG', resetBack).alpha = 0.5;
			frontURL = new InputText (this, 10, 40, 'https://farm4.static.flickr.com/3167/3064119280_13385c7c65_m.jpg');
			frontURL.width = 340;
			frontURL.alpha = 0.5;
			new PushButton(this, 360, 40, 'Load FG', resetFront).alpha = 0.5;
			m3Text = new Text(this, 10, 340);
			m3Text.height = 120;
			m3Text.alpha = 0.5;
			
			for (var i:int = 0; i < 4; i++) {
				var s:Sprite = new Sprite();
				s.graphics.beginFill(0xffffff, 0.5);
				s.graphics.drawRect(-4, -4, 8, 8);
				s.graphics.endFill();
				s.addEventListener(MouseEvent.MOUSE_DOWN, handleDown);
				handles[i] = s;
				addChild(s);
			}
			handles[0].x = 182;
			handles[0].y = 119;
			handles[1].x = 296;
			handles[1].y = 83;
			handles[2].x = 182;
			handles[2].y = 306;
			handles[3].x = 296;
			handles[3].y = 300;
			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp);
			
			resetBack(null);
			resetFront(null);
		}
		
		private function resetBack(e:Event):void {
			back.load(new URLRequest(backURL.text), CONTEXT);
		}
		
		private function resetFront(e:Event):void {
			front.load(new URLRequest(frontURL.text), CONTEXT);
		}
		
		private function recalc(e:Event):void {
			solve(handles[0].x, handles[1].x, handles[2].x, handles[3].x, handles[0].y, handles[1].y, handles[2].y, handles[3].y, front.content.width, front.content.height);
			box.graphics.clear();
			box.graphics.lineStyle(0);
			box.graphics.moveTo(handles[0].x, handles[0].y);
			box.graphics.lineTo(handles[1].x, handles[1].y);
			box.graphics.lineTo(handles[3].x, handles[3].y);
			box.graphics.lineTo(handles[2].x, handles[2].y);
			box.graphics.lineTo(handles[0].x, handles[0].y);
			m3Text.text =
				'X·Y / |X||Y| = ' + (X.dotProduct (Y)/X.length/Y.length).toFixed (3) + ' (ideally 0)\n' +
				'|X| = ' + X.length.toFixed (3) + '\n' +
				'|Y| = ' + Y.length.toFixed (3) + '\n' +
				'|Z| = ' + Z.length.toFixed (3) + '\n';

			objX.x = 0.5 * front.content.width;
			objX.y = 0.5 * front.content.height;
			objX.graphics.clear ();
			objX.graphics.lineStyle (3, 0xFF0000);
			objX.graphics.lineTo (0, objX.x);
			objY.x = objX.x;
			objY.y = objX.y;
			objY.graphics.clear ();
			objY.graphics.lineStyle (3, 0x0000FF);
			objY.graphics.lineTo (objX.y, 0);
			objZ.x = objX.x;
			objZ.y = objX.y;
			objZ.graphics.clear ();
			objZ.graphics.lineStyle (3, 0x00FF00);
			objZ.graphics.lineTo (50, 0);
			objZ.rotationY = 90;
		}
		
		private var X:Vector3D = new Vector3D;
		private var Y:Vector3D = new Vector3D;
		private var Z:Vector3D;
		private function solve(x0:Number, x1:Number, x2:Number, x3:Number, y0:Number, y1:Number, y2:Number, y3:Number, w:Number, h:Number):void {
			// solution extended to be true 3D matrix ;)
			var v:Vector.<Number> = m3.rawData;
			var d:Number = x3*(y1-y2) + x2*(y3-y1) + x1*(y2-y3);
			var a:Number = x3*(y0-y1) + x2*(y1-y0) + x1*(y3-y2) + x0*(y2-y3);
			var b:Number = x3*(y0-y2) + x2*(y3-y1) + x1*(y2-y0) + x0*(y1-y3);
			X.x = -(cx*a + (x1*x2-x1*x3)*y0 + (x0*x3-x0*x2)*y1 + (x1*x3-x0*x3)*y2 + (x0*x2-x1*x2)*y3);
			X.y = -(cy*a + (y1*y3-y1*y2)*x0 + (y0*y2-y0*y3)*x1 + (y0*y3-y1*y3)*x2 + (y1*y2-y0*y2)*x3);
			X.z = +(cz*a); X.scaleBy (1.0 / (d * w));
			Y.x = +(cx*b + (x1*x2-x2*x3)*y0 + (x2*x3-x0*x3)*y1 + (x0*x3-x0*x1)*y2 + (x0*x1-x1*x2)*y3);
			Y.y = +(cy*b + (y2*y3-y1*y2)*x0 + (y0*y3-y2*y3)*x1 + (y0*y1-y0*y3)*x2 + (y1*y2-y0*y1)*x3);
			Y.z = -(cz*b); Y.scaleBy (1.0 / (d * h));
			Z = X.crossProduct (Y); Z.normalize (); Z.scaleBy (0.5 * (X.length + Y.length));
			v[12] = x0;
			v[13] = y0;
			v[0] = X.x;
			v[1] = X.y;
			v[2] = X.z;
			v[4] = Y.x;
			v[5] = Y.y;
			v[6] = Y.z;
			v[8] =  Z.x;
			v[9] =  Z.y;
			v[10] = Z.z;
			m3.rawData = v;
		}
		
		private function handleDown(e:MouseEvent):void {
			e.target.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, recalc);
			front.alpha = 0.5;
		}
		
		private function handleUp(e:MouseEvent):void {
			e.target.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, recalc);
			front.alpha = 1;
		}
		
	}
}