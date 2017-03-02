package {
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.geom.Vector3D;
	[SWF(width = "240",height = "180")]
	public class GettingAngle extends Sprite {
		private const AMOUNT:uint = 1000000;
		private var myVector:Vector.<Vector3D> = new Vector.<Vector3D>(AMOUNT);
		private var my_txt:TextField = new TextField();
		private var label_txt:TextField = new TextField();
		private var my_fmt:TextFormat = new TextFormat();
		public function GettingAngle() {
			// Creating a TextField for display
			createTextField();
			createVector3Ds();
			// Starting Test
			testMath();
			testVector3D();
			testMath();
			testVector3D();
		}
		private function testMath():void {
			var _vector:Vector.<Vector3D>  = clone(myVector);
			var nAmount:uint = _vector.length - 1;
			var started:int = getTimer();
			for (var i:uint = 0; i < nAmount; i++) {
				var beginVector3D:Vector3D = _vector[i];
				var endVector3D:Vector3D = _vector[uint(i + 1)];
				var angle:Number = useMath(beginVector3D, endVector3D);
			}
			xTrace("Math.acos()" ,getTimer() - started);
		}
		private function testVector3D():void {
			var _vector:Vector.<Vector3D>  = clone(myVector);
			var nAmount:uint = _vector.length - 1;
			var started:int = getTimer();
			for (var i:uint = 0; i < nAmount; i++) {
				var beginVector3D:Vector3D = _vector[i];
				var endVector3D:Vector3D = _vector[uint(i + 1)];
				var angle:Number = useVector3D(beginVector3D, endVector3D);
			}
			xTrace("Vector3D.angleBetween", getTimer() - started);
		}
		private function useVector3D(beginVector3D:Vector3D, endVector3D:Vector3D):Number {
			var angle:Number = Vector3D.angleBetween(beginVector3D, endVector3D);
			return angle;
		}
		private function useMath(firstVector3D:Vector3D, secondVector3D:Vector3D):Number {
			var nDotProduct:Number = firstVector3D.dotProduct(secondVector3D);
			var nMultipliedLength:Number = firstVector3D.length * secondVector3D.length;
			var nCos:Number = nDotProduct / nMultipliedLength;
			if (nCos > 1) {
				return 0;
			} else if (nCos < -1) {
				return Math.PI;
			} else {
				return Math.acos(nCos);
			}
		}
		private function warmingUp(beginVector3D:Vector3D, endVector3D:Vector3D):Number {
			return 0;
		}
        private function createVector3Ds():void {
            var nAmount:uint = AMOUNT;
            for (var i:uint = 0; i < nAmount; i++) {
				var nX:Number = Math.random() * 1000;
				var nY:Number = Math.random() * 1000;
				var nZ:Number = Math.random() * 1000;
                myVector[i] = new Vector3D(nX, nY, nZ);
            }
        }
		private function clone(_vector:Vector.<Vector3D>):Vector.<Vector3D> {
			var nLength:uint = _vector.length;
			var cloneVector:Vector.<Vector3D> = new Vector.<Vector3D>(nLength);
			for (var i:uint = 0; i < nLength; i++) {
				var myVector3D:Vector3D = _vector[i];
				cloneVector[i] = myVector3D.clone();
			}
			return cloneVector;
		}
        private function createTextField():void {
            addChild(my_txt);
            addChild(label_txt);
            my_fmt.align = TextFormatAlign.RIGHT;
            my_txt.x +=  50;
            my_txt.defaultTextFormat = my_fmt;
            my_txt.autoSize = TextFieldAutoSize.RIGHT;
            label_txt.autoSize = TextFieldAutoSize.LEFT;
        }
        private function xTrace(_str:String, n:int):void {
            my_txt.appendText(String(n) + "\n");
            label_txt.appendText(_str + ":" + "\n");
        }
	}
}