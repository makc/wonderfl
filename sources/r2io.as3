package {
    import flash.display.Sprite;
    import flash.events.Event;
    public class FlashTest extends Sprite {
    	 private var n : Number = 0;
		private const r : Number = 200;
        public function FlashTest() {
           
			stage.addEventListener(Event.ENTER_FRAME, draw);
		}

		private function draw(event : Event) : void
		{
			graphics.clear();
			graphics.lineStyle(1,0,.5);
			graphics.moveTo(r,r);
			
			for (var i : int = 0;i < r; i += 1) 
				graphics.lineTo(r + (i * Math.cos(i + (i * n))), r + (i * Math.sin(i + (i * n))));
				
			n += .001;
		}
            
        }
    }
