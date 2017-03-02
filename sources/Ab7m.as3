package {
    
    import flash.events.*;
    import flash.display.*;
    import gs.TweenMax
    import gs.easing.*;
    
    public class FlashTest extends MovieClip {
        
        private var c:Sprite;
        
        public function FlashTest() {
            // write as3 code here..
            addEventListener( Event.ADDED_TO_STAGE , onStage );
            
        }
        
        private function onStage( e:Event ) : void {
            
            removeEventListener( Event.ADDED_TO_STAGE , onStage );
            init();
        } 
        
        private function init() : void {
            
            for( var i:uint = 0 ; i < 10 ; i++ )
            {
               var c:Sprite = createCircle();
               c.rotation = Math.random()*360;
               c.addEventListener( MouseEvent.MOUSE_MOVE , moveit ); 
            }
            
             var face:Sprite = new Sprite();
             face.graphics.beginFill(0x000000);
             face.graphics.drawCircle( -25 , 0 , 10 );
             face.graphics.drawCircle( 25 , 0 , 10 );
             face.graphics.endFill();
             face.graphics.lineStyle( 5 , 0x000000 );
             face.graphics.moveTo( -10 , 20 );
             face.graphics.lineTo( 10 , 20 );
             addChild(face);     
             face.x = stage.stageWidth/2;           
             face.y = stage.stageHeight/2;             
        }
        
        private function moveit( e:MouseEvent ) : void {
            
            TweenMax.to( e.currentTarget , 1 , { rotation:e.currentTarget.rotation+60 } ); 
            
        }
        
        private function createCircle() : Sprite {
            
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(0x000000);
            sp.graphics.drawCircle( -50 , -50 , 50 );
            sp.graphics.endFill();
            sp.graphics.beginFill(0xffffff);
            sp.graphics.drawRoundRect( -60 , -60 , 70 , 70 , 10 , 10 );
            sp.graphics.endFill();
            sp.x = stage.stageWidth/2;
            sp.y = stage.stageHeight/2;
            addChild( sp );               
            return sp;
        }

    }
}