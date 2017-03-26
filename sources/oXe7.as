package {
	// Phlashers 2009 AS3 Contest
// http://www.phlashers.com
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.media.*;
	import flash.utils.*;
	[SWF(width=480, height=500, frameRate=61, backgroundColor="#000000")]
	public class Phlashers extends Sprite {
		private var blit:Bitmap;
		private var canvas:MovieClip;
		private var amount:Number = 20;
		private var fnode:dnode;
		private var bdata:BitmapData;
		private var beats:Sound;
		private var towrite:ByteArray;
		private var slen:Number;
		private var tone:Array;
		private var splaying:Boolean = false;
		function Phlashers() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(evt:Event):void {
			blit = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00ffffff), "auto", true);
			addChild(blit);
			canvas = new MovieClip();
			canvas.graphics.beginFill(0, .004);
			canvas.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			canvas.graphics.endFill();
			addChild(canvas);
			stage.addEventListener(Event.ENTER_FRAME, render);
			setTones();
			createnodes();
			beats = new Sound();
			beats.addEventListener(SampleDataEvent.SAMPLE_DATA, onSoundSample);
			beats.play()
		}
		private function setTones():void{
			tone = new Array();
			for(var i:Number = 1;i<3;i++){
				tone.push({len:800/i, tone:24/i});
				tone.push({len:600/i, tone:22/i});
				tone.push({len:800/i, tone:28/i});
				tone.push({len:600/i, tone:40/i});
				tone.push({len:2000/i, tone:30/i});
			}
		}
		private function writeSound(tone:Number, life:Number):void {
			towrite = new ByteArray();
			if(life) addnodes(Math.ceil(life));
			for ( var i:int = 0; i < 4800; i++ ) {
				var value:Number = Math.sin( i / tone ) * 0.7;
				towrite.writeFloat(value);
				towrite.writeFloat(value);
			}
			setTimeout(createnodes, life);
		}
		private function onSoundSample(evt:SampleDataEvent):void {
			try{
				evt.data.writeBytes(towrite, 0, towrite.length); 
			}catch(e:Error){}
		}
		private function addnodes(len:Number):void {
			var i:int = -1;
			var clr:uint = Math.floor(Math.random() * 0xffffff);
			var pnode:dnode;
			amount = len/20;
			while (++i <= amount) {
				var d:dnode = new dnode(stage.stageWidth / 2, stage.stageHeight / 2, len, clr);
				if (pnode && !fnode) {
					fnode = pnode;
					fnode.next = d;
				}
				if(pnode){
					pnode.next = d;
				}
				pnode = d;
				canvas.addChild(pnode);
			}
		}
		private function createnodes():void {
			var c:Object = tone.shift();
			fnode = null
			if (!c) {
				setTones();
				createnodes();
				return;
			}
			
			writeSound(c.tone, c.len);
		}
		private function render(evt:Event):void {
			var d:dnode = fnode;
			try{
				while ((d = d.next) != null) d.step();
			}catch (e:Error) {}
			blit.bitmapData.draw(canvas);
		}
	}
}
import flash.display.*;
import flash.filters.*;
import flash.utils.*;
dynamic class dnode extends flash.display.Sprite {
	public var next:dnode;
	private var cx, cy, ang, color, px, py, rad, sline;
	function dnode(xx, yy, life, clr) {
		color = clr;
		sline = 5;
		px = cx = xx;
		py = cy = yy;
		rad = 2;
		ang = Math.random() * 360;
		
		blendMode = BlendMode.ADD;
		setTimeout(die, life);
	}
	public function step():void {
		if (ang > 360) ang = 0
		graphics.clear();
		graphics.moveTo(px, py);
		graphics.lineStyle(sline, color, .6, true, "normal", CapsStyle.ROUND, JointStyle.ROUND);
		sline -= .1;
		cx = px + Math.cos(ang * Math.PI/180) * rad;
		cy = py + Math.sin(ang * Math.PI/180) * rad;
		rad += Math.random() < .5 ? 1 : -1;
		if(Math.random() < .5){
			ang +=  Math.random()*80;
		}else {
			ang -=  Math.random()*80;
		}
		graphics.lineTo(cx, cy);
		px = cx;
		py = cy;
		if(cx < 20 || cx > stage.stageWidth-20 || cy < 20  || cy > stage.stageHeight-20) rad *= -1;
	}
	public function die():void {
		visible = false;
		parent.removeChild(this);
	}
}