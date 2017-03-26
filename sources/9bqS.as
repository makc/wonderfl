package{
	
	import flash.display.*
	import flash.events.*
	import flash.net.*
	import flash.geom.*
	import flash.system.*

	public class FlashTest extends Sprite{
		
		private var url:String = "http://moringo.moo.jp/p9.jpg";
		private var loader:Loader;
		private var sw:int = stage.stageWidth;
		private var sh:int = stage.stageHeight;
		private var bm:Bitmap;
		private var sp:Sprite = new Sprite();
		
		private var vs:Vector.<Number>
		private var ind:Vector.<int>
		private var uv:Vector.<Number>
		
		private var particles:Array = [];
				
		//分割の数
		private var h_num:int = 5;
		private var v_num:int = 5;
		private var h_interval:Number
		private var v_interval:Number
		
		
		public function FlashTest(){
			loader = new Loader();			
			configureListeners(loader.contentLoaderInfo);
			var req:URLRequest = new URLRequest(url);
            loader.load(req,new LoaderContext(true));	
		}
		
		 private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        }	
		
		 private function completeHandler(event:Event):void {
			bm = loader.content as Bitmap;
			h_interval = bm.width/h_num
			v_interval = bm.height/v_num
			
			vs = new Vector.<Number>();
			ind = new Vector.<int>();
			uv = new Vector.<Number>();
			
			addChild(sp);
			
			//格子点の作成			
			var sq_num:int = (h_num-1)*(v_num-1);
			
			for(var i:int=0; i<v_num; i++){
				for(var j:int=0; j<h_num; j++){
					var rand:Number = Math.random()*20;
					if(Math.random() < 0.5){
						vs.push(h_interval*j+rand, v_interval*i+rand);
						particles.push(new P(h_interval*j+rand, v_interval*i+rand))
					}else{
						vs.push(h_interval*j-rand, v_interval*i-rand);
						particles.push(new P(h_interval*j-rand, v_interval*i-rand))
					}
					uv.push(j*1/h_num, i*1/v_num)					
				}
			}
			
			
			for(var k:int=0; k<sq_num+v_num-2; k++){
				if((k+1)%h_num==0){
					//右端の頂点は無視
				}else{
					var i1:int = k
					var i2:int = k+1
					var i3:int = k+h_num
					var i4:int = k+1;
					var i6:int = k+h_num;
					var i5:int = k+1+h_num;
					ind.push(i1,i2,i3,i4,i5,i6)
				}
			}
						
			sp.x =sp.y = 20;
			
			addEventListener(Event.ENTER_FRAME,enf)
		 }
		 
		 private function enf(e:Event){
			 			
			for(var k:int = 0; k<vs.length/2; k++){
				var dis:Number = Math.sqrt(Math.pow(particles[k].x-sp.mouseX,2)+Math.pow(particles[k].y-sp.mouseY,2));
				var pow:Number
				var powX:Number
				var powY:Number
				
				//マウスからの距離に応じて適当にマウスへの反発力を計算
				//上限は適当に130に
				if(dis!=0) pow = 15000/dis;
				else pow = 130;
				if(pow > 130) pow = 130;
				
				//XY方向に分解
				powX = pow* Math.abs(particles[k].x-sp.mouseX) /(Math.abs(particles[k].x-sp.mouseX)+Math.abs(particles[k].y-sp.mouseY))
				powY = pow* Math.abs(particles[k].y-sp.mouseY) /(Math.abs(particles[k].x-sp.mouseX)+Math.abs(particles[k].y-sp.mouseY))
				
				//方向を調整
				if(vs[k*2]-sp.mouseX > 0) {
					particles[k].x = particles[k].original_x+powX
				}else{
					particles[k].x = particles[k].original_x-powX
				}
				
				if(vs[k*2+1]-sp.mouseY > 0) {
					particles[k].y = particles[k].original_y+powY
				}else{
					particles[k].y = particles[k].original_y-powY
				}
				
				vs[k*2] = particles[k].x
				vs[k*2+1] = particles[k].y				
			}
			
									
			sp.graphics.clear();
			sp.graphics.lineStyle(1,0xFFFFFF);
			sp.graphics.beginBitmapFill(bm.bitmapData);
			sp.graphics.drawTriangles(vs,ind,uv,TriangleCulling.NONE);
			sp.graphics.endFill();
			
		}
	}
}

class P{
		public var x:Number;
		public var y:Number;
		
		public var original_x:Number
		public var original_y:Number
		
		public function P(xx:Number,yy:Number){
			x = xx;
			y = yy;
			
			original_x = xx;
			original_y = yy;
     }
 }
