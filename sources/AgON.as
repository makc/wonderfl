package
{
    import flash.display.*;
    import flash.events.*;
    import flash.media.*;
    import flash.net.URLRequest;
	
    import org.papervision3d.cameras.*;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.render.*;
    import org.papervision3d.scenes.*;
    import org.papervision3d.view.Viewport3D;
    import org.papervision3d.view.stats.StatsView;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
	import org.papervision3d.core.math.*;

    [SWF(width=465, height=465, frameRate=30, backgroundColor=0x000000)]
    public class Main extends Sprite
    {
        public function Main()
        {    	
        		camera = new Camera3D( 35, 2, 5000, false, false );
            renderer = new BasicRenderEngine();
            scene = new Scene3D();
            viewport = new Viewport3D( 465, 465 );
            addChild( viewport );
            //addChild( new StatsView(renderer ) );

            boxArray = [];
            var size:Number = 100;
            var initialPower:Number = 10;

     		boxInRow = 8;
            for( var iy:int = 0; iy < boxInRow; iy++ )
            {
	            for( var ix:int = 0; ix < boxInRow; ix++ )
	            {
		            var colorMats:Array = [];
		            for( var j:int = 0; j < 6; j++ )
		            {
		            	    colorMats.push( new ColorMaterial( 0x00a0d0 ) );
		            }
		            colorMats[0].name = "left";
		            colorMats[1].name = "right";
		            colorMats[2].name = "top";
		            colorMats[3].name = "bottom";
		            colorMats[4].name = "front";
		            colorMats[5].name = "back";

	            	    var cube:Cube = new Cube( new MaterialsList( colorMats ), size, size, initialPower );
	            		boxArray.push( cube );
	            		cube.x = ix * size - boxInRow * size * 0.5 + size * 0.5;
	            		cube.z = iy * size - boxInRow * size * 0.5 + size * 0.5;
	            		cube.y = 0;
	            		cube.scaleY = 1.0;
	            		scene.addChild( cube );
	            }
	        }
            
            addEventListener( Event.ENTER_FRAME, loop );
            var url:URLRequest = new URLRequest( "http://scfire-ntc-aa03.stream.aol.com:80/stream/1025" );
            sound = new Sound( url );
            soundChannel = sound.play();
            mouseYs = stage.stageHeight * 0.5;
        }

        private var rot:Number = 0.0;
        private var mouseYs:Number;
        private function loop( event:Event ):void
        {
        		//mouseYs = mouseY;
            rot += ( mouseX - stage.stageWidth * 0.5 ) * 0.0003;
            camera.x = 2000 * Math.sin( rot );
            camera.z = 2000 * Math.cos( rot );
            camera.y = mouseYs / stage.stageHeight * 3000;

            camera.lookAt( DisplayObject3D.ZERO );

            var dt:Number = 0.05;
            var randX:int = Math.random()* (boxInRow - 2) + 1;
            var randY:int = Math.random()* (boxInRow - 2) + 1;
			var cubex:Cube = boxArray[ randX + boxInRow * randY ] as Cube;
			cubex.scaleY = soundChannel.leftPeak * 100;
			hueShift += soundChannel.rightPeak * 0.05;
      		if ( hueShift > 6.0 ) hueShift -= 6.0;
			
            for( var iy:int = 1; iy < boxInRow - 1; iy++ )
            {
	            for( var ix:int = 1; ix < boxInRow - 1; ix++ )
	            {
					var cube:Cube = boxArray[ ix + boxInRow * iy ] as Cube;
					var cube1:Cube = boxArray[ ix + boxInRow * ( iy + 1 ) ] as Cube;
					var cube2:Cube = boxArray[ ix + boxInRow * ( iy - 1 ) ] as Cube;
					var cube3:Cube = boxArray[ ix + 1 + boxInRow * iy ] as Cube;
					var cube4:Cube = boxArray[ ix - 1 + boxInRow * iy ] as Cube;
					var s1:Number = cube1.scaleY;
					var s2:Number = cube2.scaleY;
					var s3:Number = cube3.scaleY;
					var s4:Number = cube4.scaleY;
					var newScale:Number = ( s1 + s2 + s3 + s4 + cube.scaleY * 6 ) * 0.1;
					cube.scaleY = newScale;
					cube.y = newScale * 0.5 * 10;
					var hue:Number = newScale / 100 * 6.0 + hueShift;
					if ( hue > 6.0 ) hue -= 6.0;
					var newColor:uint = HSVtoRGB( hue, soundChannel.rightPeak * 0.4 + 0.6, 0.9 );
	            	    var mat1:ColorMaterial = cube.materials.getMaterialByName( "top" ) as ColorMaterial;
	            	    var mat2:ColorMaterial = cube.materials.getMaterialByName( "bottom" ) as ColorMaterial;
	            	    var mat3:ColorMaterial = cube.materials.getMaterialByName( "left" ) as ColorMaterial;
	            	    var mat4:ColorMaterial = cube.materials.getMaterialByName( "right" ) as ColorMaterial;
	            	    var mat5:ColorMaterial = cube.materials.getMaterialByName( "front" ) as ColorMaterial;
	            	    var mat6:ColorMaterial = cube.materials.getMaterialByName( "back" ) as ColorMaterial;
	            	    mat1.fillColor = newColor;
	            	    mat2.fillColor = newColor;
	            	    mat3.fillColor = newColor;
	            	    mat4.fillColor = newColor;
	            	    mat5.fillColor = newColor;
	            	    mat6.fillColor = newColor;

	            }
	        }
            
            renderer.renderScene( scene, camera, viewport );
        }
        
        // helper functions rewriten from my C++ code :)
		private function makeColor( r:Number, g:Number, b:Number ):uint
		{
			var ri:uint = uint(r * 255.0);
			var gi:uint = uint(g * 255.0);
			var bi:uint = uint(b * 255.0);
			return ( ( ri & 0x0000FF ) | ( ( gi & 0x0000FF ) << 8 ) | ( ( bi & 0x0000FF ) << 16 ) );
		}
		// hue => [0.0;6.0] sat => [0.0;1.0] val [0.0;1.0]
		private function HSVtoRGB( hue:Number, sat:Number, val:Number ):uint
		{
			var I:int = Math.floor( hue );
			var F:Number = hue - I; 
			if ( !( I & 1 ) )
			{
				F = 1 - F;
			}
			var M:Number = val * ( 1.0 - sat     );
			var N:Number = val * ( 1.0 - sat * F );
			var V:Number = val;
			switch( I )
			{
			case 6:
			case 0:
				return makeColor( V, N, M );
			case 1:
				return makeColor( N, V, M );
			case 2:
				return makeColor( M, V, N );
			case 3:
				return makeColor( M, N, V );
			case 4:
				return makeColor( N, M, V );
			case 5:
				return makeColor( V, M, N );
			default:
				return makeColor( 0.0, 0.0, 0.0 );
			}
		}

		private var hueShift:Number = 0.0;
		private var boxInRow:int = 10;
        private var boxArray:Array;
        private var camera:Camera3D;
        private var renderer:BasicRenderEngine;
        private var scene:Scene3D;
        private var viewport:Viewport3D;
        private var sound:Sound;
        private var soundChannel:SoundChannel;
    }
}