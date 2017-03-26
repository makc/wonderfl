// forked from egyu2's 3d wire
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Vector3D;
	
	[SWF(width=465, height=465, backgroundColor=0xFFFFFF, frameRate="30")] 
	public class Main extends Sprite 
	{
		protected var vec:Vector.<Line>;
		
		protected var lines:Vector.<Vector.<Line>>;
		
		private var sp:Sprite;
		private var cameraPosition:Line;
		private var cameraRotationX:Number = 0;
		private var cameraRotationY:Number = 0;
		private var cameraRotationZ:Number = 0;
		private var cameraScaleNow:Number = 1;
		private var cameraScaleTarget:Number = 1;
		private var cameraScaleAc:Number = 1;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			this.vec = new Vector.<Line>();
			this.lines = new Vector.<Vector.<Line>>;
			for (var i:int = 0; i < 4; i++)
			{
				var tmp:Vector.<Line> = new Vector.<Line>;
				this.lines.push(tmp);
			}
			this.sp = new Sprite();
			this.sp.x = this.stage.stageWidth / 2;
			this.sp.y = this.stage.stageHeight / 2;
			this.sp.scaleX = this.sp.scaleY = this.sp.scaleZ = 1;
			this.addChild(this.sp);
			this.cameraPosition = new Line();
			
			this.sp.addEventListener(Event.ENTER_FRAME , onEnterFrame);
			
		}
		
		private function onEnterFrame(e:Event):void
		{
			this.cameraPosition.xAc = Math.random() * 14 - 7;
			this.cameraPosition.yAc = Math.random() * 14 - 7;
			this.cameraPosition.zAc = Math.random() * 14 - 7;
			this.cameraPosition.xSpeed += this.cameraPosition.xAc;
			this.cameraPosition.ySpeed += this.cameraPosition.yAc;
			this.cameraPosition.zSpeed += this.cameraPosition.zAc;
			this.cameraPosition.xOld = this.cameraPosition.x;
			this.cameraPosition.yOld = this.cameraPosition.y;
			this.cameraPosition.zOld = this.cameraPosition.z;
			this.cameraPosition.x += this.cameraPosition.xSpeed;
			this.cameraPosition.y += this.cameraPosition.ySpeed;
			this.cameraPosition.z += this.cameraPosition.zSpeed;
			this.cameraPosition.xSpeed *= 0.9;
			this.cameraPosition.ySpeed *= 0.9;
			this.cameraPosition.zSpeed *= 0.9;
			
			this.vec.push(this.cameraPosition.copy());
			if (this.vec.length > 10) this.vec.shift();
			
			this.setPosition();
			this.setPosition2();
			
			this.sp.graphics.clear();
			//this.draw();
			this.drawChildren();
			
			//this.cameraChange();
			
		}
		private function cameraChange():void
		{
			if (Math.random() > 0.95)
			{
				this.cameraScaleTarget = Math.random() * 1.5 + 0.2;
			}
			this.cameraScaleAc = (this.cameraScaleTarget - this.cameraScaleNow)*0.1;
			this.cameraScaleNow += this.cameraScaleAc;
			this.sp.scaleX = this.sp.scaleY = this.sp.scaleZ = this.cameraScaleNow;
			
		}
		
		private function draw():void
		{
			var a:Line;
			for each(a in this.vec)
			{
				this.sp.graphics.lineStyle(20, 0xff5500);
				this.sp.graphics.moveTo(a.xOld, a.yOld);
				this.sp.graphics.lineTo(a.x, a.y);
			}
		}
		
		private function drawChildren():void
		{
			var isRotateflg:Boolean = true;
			if (isRotateflg)
			{
				this.cameraRotationX += 1;
				this.cameraRotationY += 1;
				this.cameraRotationZ += 1;
				this.cameraRotationX %= 360;
				this.cameraRotationY %= 360;
				this.cameraRotationZ %= 360;
				
				var m3d:Matrix3D = new Matrix3D();
				m3d.appendRotation(cameraRotationX, Vector3D.X_AXIS);
				m3d.appendRotation(cameraRotationY, Vector3D.Y_AXIS);
				m3d.appendRotation(cameraRotationZ, Vector3D.Z_AXIS);
			}
			var a:Vector.<Line>;
			for each(a in this.lines)
			{
				var b:Line;
				for each(b in a)
				{
					if (isRotateflg)
					{
						var tv:Vector3D = m3d.transformVector(b as Vector3D);
						var tv2:Vector3D = new Vector3D();
						tv2.x = b.xOld;
						tv2.y = b.yOld;
						tv2.z = b.zOld;
						tv2 = m3d.transformVector(tv2 as Vector3D);
					}
					var thic:Number = (b.z + 10) / 10;
					var color:Number = (256 * thic * 10 as int) + (36 * thic as int) + (thic as int);
					this.sp.graphics.lineStyle(thic, color);
					if (isRotateflg)
					{
						this.sp.graphics.moveTo(tv2.x, tv2.y);
						this.sp.graphics.lineTo(tv.x, tv.y);
					}
					else
					{
						this.sp.graphics.moveTo(b.xOld, b.yOld);
						this.sp.graphics.lineTo(b.x, b.y);
					}
				}
				
			}
		}
		
		private function setPosition2():void
		{
			var a:Line;
			for each(a in this.vec)
			{
				a.x -= this.cameraPosition.x;
				a.y -= this.cameraPosition.y;
				a.z -= this.cameraPosition.z;
				a.xOld -= this.cameraPosition.x;
				a.yOld -= this.cameraPosition.y;
				a.zOld -= this.cameraPosition.z;
			}
			var xDiff:Number = this.cameraPosition.x;
			var yDiff:Number = this.cameraPosition.y;
			var zDiff:Number = this.cameraPosition.z;
			
			this.cameraPosition.xOld -= xDiff;
			this.cameraPosition.yOld -= yDiff;
			this.cameraPosition.zOld -= zDiff;
			this.cameraPosition.x -= xDiff;
			this.cameraPosition.y -= yDiff;
			this.cameraPosition.z -= zDiff;
		}
		
		private function setPosition():void
		{
			var a:Vector.<Line>;
			var tmpLines:Vector.<Vector.<Line>> = new Vector.<Vector.<Line>>;
			for (var i:int = 0; i < this.lines.length; i++)
			{
				
				a = this.lines[i];
				
				var b:Line;
				for each(b in a)
				{
					b.x -= this.cameraPosition.x;
					b.y -= this.cameraPosition.y;
					b.z -= this.cameraPosition.z;
					b.xOld -= this.cameraPosition.x;
					b.yOld -= this.cameraPosition.y;
					b.zOld -= this.cameraPosition.z;
				}
				
				var tmpLine:Line = new Line();
				var lastLineNum:int = a.length - 1;
				if (a.length)
				{
					
					tmpLine.xAc = a[lastLineNum].xAc;
					tmpLine.yAc = a[lastLineNum].yAc;
					tmpLine.zAc = a[lastLineNum].zAc;
					if (Math.random() > 0.7)
					{
						tmpLine.xAc += (Math.random() * 60 - 30);
						tmpLine.yAc += (Math.random() * 60 - 30);
						tmpLine.zAc += (Math.random() * 60 - 30);
					}
					else
					{
						var xDiff:Number = a[lastLineNum].x;
						var yDiff:Number = a[lastLineNum].y;
						var zDiff:Number = a[lastLineNum].z;
						tmpLine.xAc -= xDiff * 0.3;
						tmpLine.yAc -= yDiff * 0.3;
						tmpLine.zAc -= zDiff * 0.3;
					}
					tmpLine.xAc *= 0.5;
					tmpLine.yAc *= 0.5;
					tmpLine.zAc *= 0.5;
					
					tmpLine.xSpeed = a[lastLineNum].xSpeed;
					tmpLine.ySpeed = a[lastLineNum].ySpeed;
					tmpLine.zSpeed = a[lastLineNum].zSpeed;
					tmpLine.xSpeed += a[lastLineNum].xAc;
					tmpLine.ySpeed += a[lastLineNum].yAc;
					tmpLine.zSpeed += a[lastLineNum].zAc;
					
					tmpLine.xOld = a[lastLineNum].x;
					tmpLine.yOld = a[lastLineNum].y;
					tmpLine.zOld = a[lastLineNum].z;
					
					tmpLine.x += a[lastLineNum].xSpeed;
					tmpLine.y += a[lastLineNum].ySpeed;
					tmpLine.z += a[lastLineNum].zSpeed;
				}
				
				a.push(tmpLine);
				if (a.length > 80) a.shift();
				tmpLines.push(a);
			}
			
			this.lines = tmpLines;
			
		}
	}
}
	import flash.geom.Vector3D;
	class Line extends Vector3D
	{
		public var xOld:Number = 0;
		public var yOld:Number = 0;
		public var zOld:Number = 0;
		public var xSpeed:Number = 0;
		public var ySpeed:Number = 0;
		public var zSpeed:Number = 0;
		public var xAc:Number = 0;
		public var yAc:Number = 0;
		public var zAc:Number = 0;
		public var fr:Number = 0.5;
		
		public function Line() 
		{
			
		}
		
		public function copy():Line
		{
			var self:Line = new Line();
			
			self.x = this.x;
			self.y = this.y;
			self.z = this.z;
			self.xOld = this.xOld;
			self.yOld = this.yOld;
			self.zOld = this.zOld;
			self.xSpeed = this.xSpeed;
			self.ySpeed = this.ySpeed;
			self.zSpeed = this.zSpeed;
			self.xAc = this.xAc;
			self.yAc = this.yAc;
			self.zAc = this.zAc;
			self.fr = this.fr;
			return self;
		}
		
	}