// IndentedTextParseTest
//  Convert an indented text to XML for parsing with E4X.
package {
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor="0", frameRate="30")]
	public class Main extends Sprite {
		public function Main() { main = this; initialize(); }
	}
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
import flash.text.*;
import org.si.sion.*;
import org.si.sion.utils.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const TEXT_COUNTS:int = 8;
var main:Main;
var indentedTexts:Vector.<TextField> = new Vector.<TextField>;
var xmlTexts:Vector.<TextField> = new Vector.<TextField>;
var driver:SiONDriver = new SiONDriver();
var percusVoices:Array = new SiONPresetVoice()["valsound.percus"];
var drum1:SiONData, drum2:SiONData, drum3:SiONData;
// Initialize.
function initialize():void {
	for (var i:int = 0; i < TEXT_COUNTS; i++) {
		var it:TextField = createTextField(0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT, 0xffffff);
		var xt:TextField = createTextField(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT, 0xffffff);
		if (i > 0) {
			var bf:BlurFilter = new BlurFilter;
			bf.blurX = bf.blurY = i * 5;
			it.filters = xt.filters = [bf];
		}
		indentedTexts.push(it);
		xmlTexts.push(xt);
	}
	for (i = TEXT_COUNTS - 1; i >= 0; i--) {
		main.addChild(indentedTexts[i]);
		main.addChild(xmlTexts[i]);
	}
	drum1 = createDrum(14);
	drum2 = createDrum(27);
	drum3 = createDrum(0);
	main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the frame.
var ticks:int = 0;
var it:String;
var drumPattern:Vector.<Boolean> = new Vector.<Boolean>(4);
function update(event:Event):void {
	var t:int = ticks % 60;
	if (t == 0) {
		it = createIndentedText();
		for (var i:int = 0; i < TEXT_COUNTS; i++) {
			indentedTexts[i].text = it;
			indentedTexts[i].visible = true;
		}
		driver.play(drum1);
		if (ticks >= 120) for (i = 1; i < 4; i++) drumPattern[i] = (randi(3) == 0);
	} else if (t < TEXT_COUNTS) {
		indentedTexts[TEXT_COUNTS - t].visible = false;
	} else if (t == 30) {
		var xts:Vector.<XML> = parseIndentedText(it);
		var xs:String = "";
		for each (var xt:XML in xts) xs += xt + "\n";
		for (i = 0; i < TEXT_COUNTS; i++) {
			xmlTexts[i].text = xs;
			xmlTexts[i].visible = true;
		}
		driver.play(drum2);
	} else if (t > 30 && t < 30 + TEXT_COUNTS) {
		xmlTexts[30 + TEXT_COUNTS - t].visible = false;
	}
	if (t > 0 && t <= 21 && t % 7 == 0 && drumPattern[t / 7])
		driver.play(drum3);
	ticks++;
}
// Create a source random text.
function createIndentedText():String {
	var s:String = "";
	var indentSpaceCount:int = 0;
	var lc:int = 5 + randi(5);
	for (var i:int = 0; i < lc; i++) {
		for (var j:int = 0; j < indentSpaceCount * 2; j++) s += " ";
		s += createRandomString() + "\n";
		if (indentSpaceCount == 0) {
			indentSpaceCount = 1;
		} else {
			indentSpaceCount += randi(3) - 1;
			if (indentSpaceCount > 4) indentSpaceCount = 0;
		}
	}
	return s;
}
function createRandomString():String {
	var s:String = "";
	var l:int = 3 + randi(5);
	var ac:int = randi(4);
	for (var i:int = 0; i < l; i++) s += String.fromCharCode('a'.charCodeAt(0) + randi(26));
	for (i = 0; i < ac; i++) {
		s += " ";
		var nl:int = 1 + randi(2);
		for (var j:int = 0; j < nl; j++) s += String.fromCharCode('0'.charCodeAt(0) + randi(10));
	}
	return s;
}
// Parser.
function parseIndentedText(s:String):Vector.<XML> {
	var indentSpaceCounts:Vector.<int> = new Vector.<int>;
	var indentSpaceCount:int = 0;
	var parentXmls:Vector.<XML> = new Vector.<XML>;
	indentSpaceCounts.push(indentSpaceCount);
	var lines:Array = s.split("\r\n").join("\n").split("\n");
	var texts:Vector.<XML> = new Vector.<XML>;
	var parent:XML, current:XML;
	for each (var line:String in lines) {
		var l:String = trimStart(line);
		if (l.length <= 0) continue;
		var strs:Array = l.split(" ");
		var isc:int = line.length  - l.length;
		if (isc > indentSpaceCount) {
			indentSpaceCounts.push(indentSpaceCount);
			indentSpaceCount = isc;
			parentXmls.push(parent);
			var lineXml:XML = new XML("<_line />");
			current.appendChild(lineXml);
			parent = lineXml;
		} else if (isc < indentSpaceCount) {
			while (isc < indentSpaceCount) {
				indentSpaceCount = indentSpaceCounts.pop();
				parent = parentXmls.pop();
			}
		}
		if (parentXmls.length == 0 && parent != null) {
			texts.push(parent);
			parent = null;
		}
		current = new XML("<" + strs[0] + " />");
		for (var i:int = 1; i < strs.length; i++) {
			current.appendChild(new XML("<_arg>" + strs[i] + "</_arg>"));
		}
		if (parent != null) parent.appendChild(current);
		else                parent = current;
	}
	if (parentXmls.length > 0) texts.push(parentXmls[0]);
	return texts;
}
// Utility functions.
function createTextField(x:int, y:int, width:int, height:int, color:int):TextField {
	var fm:TextFormat = new TextFormat, fi:TextField = new TextField;
	fm.font = "_typewriter"; fm.bold = true; fm.size = 12; fm.color = color;
	fi.defaultTextFormat = fm; fi.x = x; fi.y = y; fi.width = width; fi.height = height;  fi.selectable = false;
	return fi;
}
function createDrum(voiceNum:int):SiONData {
	var drum:SiONData = driver.compile("#EFFECT0{ws95lf4000}; %6@0o2v1c16");
	drum.setVoice(0, percusVoices[voiceNum]);
	return drum;
}
function randi(n:int):int {
	return Math.random() * n;
}
function trimStart(s:String):String {
        if (s.charAt(0) == ' ') s = trimStart(s.substring(1));
        return s;
}