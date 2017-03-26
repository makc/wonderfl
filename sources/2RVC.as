// forked from glasses_factory's ribbon test
//気になるとこ直した
/**
眠たい…curveToのあたりがあやしい…
*/
package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Study3 extends Sprite
	{
		public function Study3()
		{
			init();
		}
		
		public function init():void
		{
			pt0 = [];
			pt1 = [];
			fNode = new Node();
			fNode.x = mouseX;
			fNode.y = mouseY;
			
			for( var i:int = 0; i < _length; i++ )
			{
				var n0:Node = new Node();
				pt0.push( n0 );
				var n1:Node = new Node();
				pt1.push( n1 );
			}
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
		
		private function enterFrameHandler( e:Event ):void
		{
			moveNode( new Node( mouseX, mouseY ), fNode );
			
			pt0[0].x = fNode.x + fNode.vy * _wd;
			pt0[0].y = fNode.y - fNode.vx * _wd;
			pt1[0].x = fNode.x - fNode.vy * _wd;
			pt1[0].y = fNode.y + fNode.vx * _wd;
			
			for( var i:int = 1; i < _length; i++ )
			{
				moveNode( pt0[ i - 1 ], pt0[i] );
				moveNode( pt1[ i - 1 ], pt1[i] );
			}
			
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill( 0 );
			g.moveTo( fNode.x, fNode.y );
			g.curveTo( fNode.x, fNode.y, ( fNode.x + pt0[0].x ) * 0.5, ( fNode.y + pt0[0].y ) * 0.5 );
			
			for( i = 0; i < _length - 1; i++ )
			{
				g.curveTo( pt0[i].x, pt0[i].y, ( pt0[i].x + pt0[ i + 1 ].x ) * 0.5, ( pt0[i].y + pt0[ i + 1 ].y ) * 0.5 );
			}
			g.curveTo( pt0[ _length - 1 ].x, pt0[ _length - 1].y, ( pt0[ _length - 1 ].x + pt1[ _length -1 ].x ) * 0.5, ( pt0[ _length - 1 ].y + pt1[ _length - 1 ].y ) * 0.5 );
			for( i = _length - 1; i > 0; i-- )
			{
				g.curveTo( pt1[i].x , pt1[i].y, ( pt1[i].x + pt1[i - 1].x ) * 0.5, ( pt1[i].y + pt1[ i - 1 ].y ) * 0.5 );
			}
			
			g.curveTo( pt0[ 0 ].x, pt0[ 0 ].y, ( pt0[ 0 ].x + pt1[ 0 ].x ) * 0.5, ( pt0[0 ].y + pt1[ 0 ].y ) *0.5 );
		}
		
		private function moveNode( ndA:Node, ndB:Node ):void
		{
			var dx:Number = ndB.x - ndA.x;
			var dy:Number = ndB.y - ndA.y;
			var ang:Number = Math.atan2( dy, dx );
			var tx:Number = ndA.x + Math.cos( ang ) * _offset;
			var ty:Number = ndA.y + Math.sin( ang ) * _offset;
			ndB.vx += ( tx - ndB.x ) * _ac;
			ndB.vy += ( ty - ndB.y ) * _ac;
			ndB.vx *= _fric;
			ndB.vy *= _fric;
			ndB.x += ndB.vx;
			ndB.y += ndB.vy;
		}
		
		private var fNode:Node;
		
		//node入物
		private var pt0:Array, pt1:Array;
		
		//ノードの数
		private var _length:uint = 20;
		
		//線の太さ
		private var _wd:Number = 0.05;
		
		//加速度
		private var _ac:Number = 0.251;
		
		//抵抗
		private var _fric:Number = 0.668;
		
		//ノード間の最低距離
		private var _offset:Number = 0.5;
	}
}

class Node
{
	public var x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0;
	
	public function Node( xx:Number = 0, yy:Number = 0 )
	{
		x = xx;
		y = yy;
	}
}