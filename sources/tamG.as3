package {
	import flash.display.*;
	import flash.geom.*;
	import com.bit101.components.*;
	public class Test extends Sprite {
                public var ta:TextArea;
		public function Test () {
			ta = new TextArea (this, 10, 10,
				"ans=(-b+sqrt(b^2-4ac))/2a\n"+
				"ax^3+bx^2+cx+d=0\n"+
				"3+sqrt(sqrt(a^2+b^2))+pow(a,1/3)+exp(1234/5)\n"+
				"Y^4*(0.04/2)/39-cos(PI/2)=pow(2000/3*5,3)+sqrt(4/2)+sin(2)"
			);
			ta.width = 445; ta.height = 100;
			
			new PushButton (this, 10, 120, "render", render);
		}
		private function render (...fu):void {
			if (numChildren == 3) {
				removeChildAt (2);
			}
			
			var canvas:Sprite = new Sprite;
			canvas.x = 10; canvas.y = 140; addChild (canvas);
			
			var offset:int = 0;
			var lines:Array = ta.text.split (/[\n\r]+/);
			for (var i:int = 0; i < lines.length; i++) {
				var clip:EquationDisplayer = new EquationDisplayer;
				canvas.addChild (clip);
				clip.setEquation (lines[i]);
				clip.render ();
				var b:Rectangle = clip.getBounds(canvas);
				clip.y += offset-b.y;
				offset += clip.height+5;
			}
		}
	}
}

import flash.display.*;
import flash.geom.*;
import flash.text.*;

// port of http://ericlin2.tripod.com/math2/eqDisplayert.html
// this is dumb port: everything is public, needless code is possible

class EquationDisplayer extends Sprite {
	public var eqObject:EquationObject;
	public var equation:String = "";
	public function setEquation(str:String):void {
		eqObject = new EquationObject(str);
		equation = str;
	}
	public function setEquationObject(obj:EquationObject):void {
		eqObject = obj;
		equation = eqObject.equation;
	}
	public function getEquationObject():EquationObject {
		return eqObject;
	}
	public function clean():void {
		while (numChildren > 0) removeChildAt (0);
	}
	//######################################################
	public function render():void {
		clean();
		var obj:EquationObject = eqObject;
		var info:Object = obj.info;
		if (info == null) {
			return;
		}
		if (info.type == "operator") {
			operatorLayout(info);
			return;
		}
		if (info.type == "function") {
			functionLayout(info);
			return;
		}
		stringLayout(info);
	}
	//#######################################################
	public function lineUp(...args):void {
		//clips in arguments
		var offset:int = 0;
		for (var k:int = 0; k<args.length; k++) {
			var clip:Sprite = args[k];
			var b:Rectangle = clip.getBounds(clip.parent);
			clip.x += offset-b.x;
			offset += clip.width;
		}
	}
	//#########################################################
	public function operatorLayout(info:Object):void {
		var hiddenMultiplier:String = "\u0012";
		var operatorChar:String = info.typeData;
		var childObjects:Array = info.childObjects;
		var clip1:EquationDisplayer = new EquationDisplayer; addChild (clip1);
		clip1.setEquationObject(childObjects[0]);
		clip1.render();
		var clip2:EquationDisplayer = new EquationDisplayer; addChild (clip2);
		clip2.setEquationObject(childObjects[1]);
		clip2.render();
		//------------------------
		if (operatorChar == "^") {
			var b:Rectangle = clip1.getBounds(this);
			clip2.y = b.y+5;
			clip2.scaleX = clip2.scaleY=0.60;
			lineUp(clip1, clip2);
			return;
		}
		if (operatorChar == "/") {
			var w:Number = Math.max(clip1.width, clip2.width);
			var b1:Rectangle = clip1.getBounds(this);
			var b2:Rectangle = clip2.getBounds(this);
			var line:Sprite = attachMovie("divide", this);
			w = line.width = w+6;
			clip1.y += b1.y;
			clip1.x += (w/2-(b1.right+b1.x)/2);
			clip2.y += b2.bottom+3;
			clip2.x += (w/2-(b2.right+b2.x)/2);
			return;
		}
		//others
		var opClip:Sprite;
		if (operatorChar == "*") {
			opClip = attachMovie("multiply", this);
		} else if (operatorChar == hiddenMultiplier) {
			opClip = attachMovie("empty", this);
		} else {
			opClip = attachMovie("char", this, operatorChar);
		}
		lineUp(clip1, opClip, clip2);
	}
	//#####################################################
	public function functionLayout(info:Object):void {
		var functionName:String = info.typeData;
		var childObjects:Array = info.childObjects;
		var clipArray:Array = [];
		for (var i:int = 0; i<childObjects.length; i++) {
			var clip0:EquationDisplayer = clipArray[i]= new EquationDisplayer;
			addChild (clip0);
			clip0.setEquationObject(childObjects[i]);
			clip0.render();
		}
		//-----------------------
		if (functionName == "sqrt") {
			var line:Sprite = attachMovie("sqrtLine", this);
			var hook:Sprite = attachMovie("sqrtHook", this);
			var clip:Sprite = clipArray[0];
			var b:Rectangle = clip.getBounds(this);
			clip.y -= (b.y+b.bottom)/2;
			clip.x = hook.width+3;
			line.x = hook.width;
			hook.height = clip.height;
			var b2:Rectangle = hook.getBounds(this);
			line.y = b2.y;
			line.width = clip.width+6;
			return;
		}
		//-----------------------------------------------
		if (functionName == "pow") {
			var d:Number = 2;
			var clip1:Sprite = clipArray[0];
			var clip2:Sprite = clipArray[1];
			b = clip1.getBounds(this);
			//var offset = clip1._width;
			if (childObjects[0].info.type != "string") {
				//-------- add parenthesis to clip1 to avoid this condition: pow(3+4,2); ->2+4^2
				var leftParen:Sprite = attachMovie("char", this, "(");
				var rightParen:Sprite = attachMovie("char", this, ")");
				lineUp(leftParen, clip1, rightParen, clip2);
				leftParen.height = rightParen.height=2*Math.max(b.bottom, -b.y);
			} else {
				lineUp(clip1, clip2);
			}
			clip2.y = b.y+5;
			clip2.scaleX = clip2.scaleY=0.60;
			return;
		}
		//------------------------------------------------
		if (functionName == "exp") {
			clip1 = attachMovie("exp", this);
			clip2 = clipArray[0];
			clip2.x = clip1.width+4;
			b = clip1.getBounds(this);
			clip2.y = b.y;
			clip2.scaleX = clip2.scaleY=0.60;
			return;
		}
		//--------------------------------------------------
		d = 50;
		var funClip:Sprite = attachMovie("char", this, functionName);
		leftParen = attachMovie("char", this, "(");
		rightParen = attachMovie("char", this, ")");
		var tempArray:Array = [funClip, leftParen];
		var yMin:Number = 0;
		var yMax:Number = 0;
		for (var k:int = 0; k<clipArray.length; k++) {
			tempArray.push(clipArray[k]);
			b = clipArray[k].getBounds(this);
			if (b.y<yMin) {
				yMin = b.y;
			}
			if (b.bottom>yMax) {
				yMax = b.bottom;
			}
			if (k<clipArray.length-1) {
				var comaClip:Sprite = attachMovie("char", this, ",");
				tempArray.push(comaClip);
			}
		}
		tempArray.push(rightParen);
		lineUp.apply(null, tempArray);
		rightParen.height = leftParen.height=2*Math.max(yMax, -yMin);
	}
	//#######################################################
	public function stringLayout(info:Object):void {
		//trace("info="+info);
		//trace("stringData="+info.stringData);
		var str:String = info.typeData;
		//trace("---------------end str="+str);
		if ((str == "PI") || (str == "pi")) {
			attachMovie("pi", this);
			return;
		}
		var clip:Sprite = attachMovie("char", this, str);
	}
	public function attachMovie (movie:String, to:Sprite, label:String = null):Sprite {
		// this imitates original FLA assets
		var s:Sprite = new Sprite; s.graphics.lineStyle (0, 0);
		switch (movie) {
			case "divide":
				s.graphics.lineTo (25, 0);
				s.graphics.lineStyle();
				s.graphics.beginFill(0,0);
				s.graphics.drawRect(0,-1,25,1);
				s.graphics.endFill();
			break;
			case "multiply":
				s.graphics.moveTo (2, -2);
				s.graphics.lineTo (7, 3);
				s.graphics.moveTo (7, -2);
				s.graphics.lineTo (2, 3);
				s.graphics.lineStyle();
				s.graphics.beginFill(0,0);
				s.graphics.drawRect(0,-3,10,6);
				s.graphics.endFill();
			break;
			case "char":
			case "exp":
			case "pi":
				var italic:Boolean = (movie != "char");
				var tf:TextField = new TextField;
				tf.y = -14;
				tf.selectable = false;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.defaultTextFormat = new TextFormat ('Times New Roman', 20, 0, false, italic);
				switch (movie) {
					case "char":
						tf.text = label;
					break;
					case "exp":
						tf.text = "e";
					break;
					case "pi":
						tf.text = "\u03C0";
					break;
				}
				s.addChild(tf);
			break;
			case "sqrtLine":
				s.graphics.lineTo(43,0);
				s.graphics.lineStyle();
				s.graphics.beginFill(0,0);
				s.graphics.drawRect(0,-5.5,43.5,5.5);
				s.graphics.endFill();
			break;
			case "sqrtHook":
				s.graphics.moveTo(1,4);
				s.graphics.lineTo(2,1);
				s.graphics.lineTo(4,8);
				s.graphics.lineTo(10.5,-7.5);
			break;
		}
		to.addChild(s);
		return s;
	}
}

class EquationObject {
	public function EquationObject(str:String) {
		equation = str;
		parse();
	}
	//#########################################################
	public var equation:String = "";
	public var hiddenMultiplier:String = "\u0012";
	public var info:Object = {type:"string", typeData:"", childObjects:{}};
	//type: operator, function and string; and childObject
	//equation supplied by initObject
	public var operatorSet:String = "+-=><*/"+hiddenMultiplier+"^+-";
	//becareful, it is important  for the order of operator in this operatorSet 
	//the first  +- is for addition and subtracftion and the last +- is for sign
	//###############################################################
	public function setEquation(str:String):void {
		if (str == null) {
			str = "";
		}
		equation = str;
		parse();
	}
	//##############################################################
	public function parse():void {
		if (equation == null) {
			return;
		}
		var str:String = equation;
		//trim space
		str = str.split(" ").join("");
		//-----------------------------------------------------
		//handle the hidden multiplier such as (a-b)(c+d); there is an omitted multiplier between parenthesis block
		var strArr:Array = str.split(")");
		for (var k:int = 1; k<strArr.length; k++) {
			if (strArr[k].substr(0, 1) == "(") {
				strArr[k] = hiddenMultiplier+strArr[k];
			}
		}
		str = strArr.join(")");
		var str2:String = maskParenthesis(str);
		//search for  +,-,=,>,<    , skip string in parenthesis and cut into pieces accordingly
		//after the first step ,  only function and parenthesis and variable or number is left
		for (k = 0; k<operatorSet.length; k++) {
			var op:String = operatorSet.charAt(k);
			var start:int = str.length-1;
			var i:int = 0;
			while ((i=str2.lastIndexOf(op, start))>=0) {
				if ((k<=1) && operatorSet.indexOf(str2.charAt(i-1))>=0) {
					//something like 3*-4;  
					start = i-1;
					continue;
				}
				//split  to recursive function and return;
				var lStr:String = str.substr(0, i);
				var rStr:String = str.substr(i+1, str.length-i-1);
				//trace(lStr+"["+op+"]"+rStr);
				var childObjects:Array = [];
				childObjects[0] = new EquationObject(lStr);
				childObjects[1] = new EquationObject(rStr);
				info = {type:"operator", typeData:op, childObjects:childObjects};
				return;
			}
		}
		//------------------------------------------
		//now we get only the parenthesis,function and pure number/variable here;
		start = str.indexOf("(");
		if (start>=0) {
			var functionName:String = (str.substr(0, start)).toLowerCase();
			var contentInParenthesis:String = str.substr(start+1, str.length-start-2);
			//trace("content="+contentInParenthesis);
			//there might be more than one parameters separated by ',', so parese the parameter and create clip for each parameter;
			childObjects = parseFunctionArgument(contentInParenthesis);
			info = {type:"function", typeData:functionName, childObjects:childObjects};
			//layoutManager.layout(info);
			//here arrange these clips, parenthesis and function name
			return;
		}
		//---------------------------------------------
		//After those steps , only pure number, and variable left here now
		info = {type:"string", typeData:str};
		//layoutManager.layout(info);
		//most of the time, we display Number, but sometime we need to convert PI  into symbol, so I add this function here
	}
	//#################################################
	public function parseFunctionArgument(str:String):Array {
		// cut arguments into parameters
		var childObjects:Array = [];
		var start:int = 0;
		var paramStr:Array = [];
		var parenthesisStack:int = 0;
		for (var i:int = 0; i<str.length; i++) {
			var char:String = str.substr(i, 1);
			if (char == "(") {
				parenthesisStack++;
			}
			if (char == ")") {
				parenthesisStack--;
			}
			if ((char == ",") && parenthesisStack == 0) {
				paramStr.push(str.substr(start, i-start));
				start = i+1;
			}
		}
		paramStr.push(str.substr(start, str.length-start));
		for (var j:int = 0; j<paramStr.length; j++) {
			childObjects[j] = new EquationObject(paramStr[j]);
		}
		return childObjects;
	}
	//---------------------------------------------------
	public function maskParenthesis(str:String):String {
		var parenthesisStack:int = 0;
		//prepare to skip the first level parenthesis
		var temp:Array = [];
		for (var i:int = 0; i<str.length; i++) {
			var char:String = str.substr(i, 1);
			if (char == ")") {
				parenthesisStack++;
			}
			if (char == "(") {
				parenthesisStack--;
			}
			if (parenthesisStack == 0) {
				temp.push(char);
			} else {
				temp.push("(");
			}
		}
		if (parenthesisStack != 0) {
			trace("parenthesis not match");
			return "";
		}
		var str2:String = temp.join("");
		//trace(str+"=="+str2);
		return str2;
	}
}