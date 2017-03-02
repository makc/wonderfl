// Voxcape
//  Voxel landscape test.
//  <Operation>
//   Movement: Arrow or [WASD] keys.
package {
	import flash.display.Sprite;
	[SWF(width="465", height="465", backgroundColor="0x44ff44", frameRate="30")]
	public class Main extends Sprite {
		public function Main() { main = this; initialize(); }
	}
}
import flash.display.*;
import flash.filters.*;
import flash.geom.*;
import flash.events.*;
const SCREEN_WIDTH:int = 465, SCREEN_HEIGHT:int = 465;
const MAP_SIZE:int = 512, MAP_VOXEL_INTERVAL:Number = 10;
const MAP_VOXEL_SIZE:Number = MAP_SIZE * MAP_VOXEL_INTERVAL;
const VOXEL_SIZE_COUNT:int = 10, VOXEL_COLOR_COUNT:int = 10;
var main:Main, bd:BitmapData;
var backRect:Rectangle, backColors:Vector.<int> = new Vector.<int>;
var keys:Vector.<Boolean> = new Vector.<Boolean>(256);
var voxelBds:Vector.<BitmapData> = new Vector.<BitmapData>;
var voxelRects:Vector.<Rectangle> = new Vector.<Rectangle>;
var heightMap:Vector.<int> = new Vector.<int>;
var pos:Vector3D = new Vector3D;
var i:int, j:int;
var point:Point = new Point;
// Initialize.
function initialize():void {
	backRect = new Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT / 16);
	var r:int, g:int, b:int;
	for (i = 0; i < 9; i++) {
		r = g = 0xa0 + i * 0x05;
		b = 0xff;
		backColors.push(r * 0x10000 + g * 0x100 + b);
	}
	createHeightMap();
	createVoxels();
	initalizeDrawVoxels();
	pos.y = -500;
	bd = new BitmapData(SCREEN_WIDTH, SCREEN_HEIGHT, false);
	main.addChild(new Bitmap(bd));
	main.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { keys[e.keyCode] = true; } );
	main.stage.addEventListener(KeyboardEvent.KEY_UP,   function(e:KeyboardEvent):void { keys[e.keyCode] = false; } );
	main.addEventListener(Event.ENTER_FRAME, update);
}
// Update the game frame.
function update(event:Event):void {
	for (i = 0 ; i < 9; i++) {
		backRect.y = SCREEN_HEIGHT / 16 * i;
		bd.fillRect(backRect, backColors[i]);
	}
	drawVoxels();
	var vx:Number = 0, vy:Number = 0;
	if (keys[0x25] || keys[0x41]) vx = -1;
	if (keys[0x27] || keys[0x44]) vx =  1;
    if (keys[0x26] || keys[0x57]) vy = -1;
    if (keys[0x28] || keys[0x53]) vy =  1;
	pos.x += vx * 24;
	if (pos.x < 0)
		pos.x += MAP_VOXEL_SIZE;
	else if (pos.x >= MAP_VOXEL_SIZE)
		pos.x -= MAP_VOXEL_SIZE;
	pos.y += vy * 24;
	if (pos.y > -100)
		pos.y = -100;
	else if (pos.y < -2000)
		pos.y = -2000;
	pos.z += 13;
	if (pos.z >= MAP_VOXEL_SIZE)
		pos.z -= MAP_VOXEL_SIZE;
}
// Draw the ground consist of voxels.
const DRAWING_VOXEL_DEPTH:int = 100;
var voxelStartZ:Number, voxelStartOffset:Number;
function initalizeDrawVoxels():void {
	voxelStartZ = voxelStartOffset = MAP_VOXEL_INTERVAL;
	for (i = DRAWING_VOXEL_DEPTH - 1; i >= 0; i--) {
		if (i < DRAWING_VOXEL_DEPTH / 2)
			voxelStartOffset += MAP_VOXEL_INTERVAL;
		voxelStartZ += voxelStartOffset;
	}
}
function drawVoxels():void {
	var z:Number = voxelStartZ;
	var oz:Number = voxelStartOffset;
	var xi:Number = 32 + DRAWING_VOXEL_DEPTH / 2;
	for (i = 0; i < DRAWING_VOXEL_DEPTH; i++) {
		for (var x:Number = -z * 2.3; x <= z * 2.3; x += z * 4.6 / xi) {
			drawHeight(x, z);
		}
		z -= oz;
		if (i < DRAWING_VOXEL_DEPTH / 2)
		{
			oz -= MAP_VOXEL_INTERVAL;
			xi--;
		}
	}
}
const PERSPECTIVE_RATIO:Number = 100;
function drawHeight(x:Number, z:Number):void {
	var xi:int = ((pos.x + x + MAP_VOXEL_SIZE * 100) / MAP_VOXEL_INTERVAL) % MAP_SIZE;
	var zi:int = ((pos.z + z + MAP_VOXEL_SIZE) / MAP_VOXEL_INTERVAL) % MAP_SIZE;
	var vy:Number = heightMap[xi + zi * MAP_SIZE];
	var vx:Number = x - x % MAP_VOXEL_INTERVAL;
	var vz:Number = z - z % MAP_VOXEL_INTERVAL;
	var vis:int = int(MAP_VOXEL_INTERVAL * 240 / vz);
	if (vis >= VOXEL_SIZE_COUNT)
		vis = VOXEL_SIZE_COUNT - 1;
	var vic:int = vy / 48 + VOXEL_COLOR_COUNT / 2;
	if (vic >= VOXEL_COLOR_COUNT)
		vic = VOXEL_COLOR_COUNT - 1;
	else if (vic < 0)
		vic = 0;
	var vi:int = vic + vis * VOXEL_COLOR_COUNT;
	var vr:Rectangle = voxelRects[vi];
	vy -= pos.y;
	point.x = vx * PERSPECTIVE_RATIO / vz - vr.width / 2 + SCREEN_WIDTH / 2;
	point.y = vy * PERSPECTIVE_RATIO / vz - vr.height / 2 + SCREEN_HEIGHT / 2;
	if (point.y > SCREEN_HEIGHT)
		return;
	bd.copyPixels(voxelBds[vi], vr, point);
}
// Create the height map representing a height of each ground position.
function createHeightMap():void {
	for (i = 0; i < MAP_SIZE * MAP_SIZE; i++)
		heightMap.push(0);
	for (i = 0; i < MAP_SIZE / 5; i++)
		changeHeight(randi(MAP_SIZE), randi(MAP_SIZE), randnc(400));
}
const ADD_HEIGHT_RANGE:int = 32;
function changeHeight(cx:int, cy:int, d:Number):void {
	for (var x:int = -ADD_HEIGHT_RANGE ; x <= ADD_HEIGHT_RANGE; x++) {
		for (var y:int = -ADD_HEIGHT_RANGE; y <= ADD_HEIGHT_RANGE; y++) {
			var hd:Number = d * (ADD_HEIGHT_RANGE * 2 - abs(x) - abs(y)) / (ADD_HEIGHT_RANGE * 2);
			addHeight(cx + x, cy + y, hd);
		}
	}
}
function addHeight(x:int, y:int, d:Number):void {
	if (x < 0) x += MAP_SIZE;
	else if (x >= MAP_SIZE) x -= MAP_SIZE;
	if (y < 0) y += MAP_SIZE;
	else if (y >= MAP_SIZE) y -= MAP_SIZE;
	heightMap[x + y * MAP_SIZE] += d;
}
// Create voxel bitmapdatas.
function createVoxels():void {
	var s:Shape, gr:Graphics, bd:BitmapData;
	var vcs:Vector.<int> = new Vector.<int>;
	var r:int = 0xff, g:int = 0xff, b:int = 0xff;
	for (i = 0; i < VOXEL_COLOR_COUNT; i++) {
		vcs.push(r * 0x10000 + g * 0x100 + b);
		if (i <= VOXEL_COLOR_COUNT / 2) {
			r -= 0x22; b -= 0x22;
		} else {
			g -= 0x22; b += 0x22;
		}
	}
	var blur:BlurFilter = new BlurFilter;
	blur.blurX = blur.blurY = 15;
	for (i = 1; i <= VOXEL_SIZE_COUNT; i++) {
		for (j = 0; j < VOXEL_COLOR_COUNT; j++) {
			s = new Shape;
			gr = s.graphics;
			gr.beginFill(vcs[j], 0.5);
			gr.drawRoundRect(i * 2, i * 6, i * 6, i * 18, i * 3, i * 9);
			gr.endFill();
			s.filters = [blur];
			var w:int = i * 10;
			var h:int = i * 30;
			bd = new BitmapData(w, h, true, 0);
			bd.draw(s);
			voxelBds.push(bd);
			voxelRects.push(new Rectangle(0, 0, w, h));
		}
	}
}
// Utility functions.
var abs:Function = Math.abs;
function randi(n:int):int {
	return Math.random() * n;
}
function randnc(v:int):Number {
	return Math.random() * v * 2 - v;
}