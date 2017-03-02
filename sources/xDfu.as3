// forked from checkmate's Saqoosha challenge for amateurs
package {
    import flash.display.*;
    import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import com.bit101.components.Label;
	/**
	 * 
	 * @author k3lab
	 */
	[SWF(width="465", height="465", frameRate="60")] 
	public class Main extends Sprite {
		private static const PARTICLE_NUM:int = 500;
		private static const SPRING:Number = 0.18;
		private static const FRICTION:Number = 0.75;
		
		private var canvas:BitmapData; 
        private var clones:BitmapData;
		
		private var pArr:Array = [];
		private var volArr:Array = []
		private var colorArr:Array = []
		
		private var clt:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, -10, -10, -10);
		private var sp:Sprite;
		private var trail:Sprite;
		
		private var vx:Number = 0;
		private var vy:Number = 0;
		private var ratio:Number = 0;
		
		private var grad:Gradation;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//BGM
			var sound:Sound = new Sound (new URLRequest ("http://www.k3lab.com/wonderfl/Euphoria/bgm.mp3"));  
            sound.play (0, int.MAX_VALUE); 
			
			canvas = new BitmapData(465, 465, false, 0x00000000);    
            clones = canvas.clone(); 
            addChild(new Bitmap(clones)) as Bitmap; 
			grad = new Gradation(0xff0000, 0x00ff00, 0x0000ff);
			var a:Number = 0;
			sp = addChild(new Sprite()) as Sprite;
			sp.blendMode = "screen";
			for (var i:int = 0; i < PARTICLE_NUM; i++) {
				a += 0.2
				var p:Particle =sp.addChild(new Particle()) as Particle;
				p._x = 240 * Math.sin(a);
				p._y  = 240 * Math.cos(a);
				p._z = 0;
				pArr[i] = p
				p.draw(grad.getColor(i / PARTICLE_NUM), 0.6,  Math.random() * 0.6);
			}
			//******************************************
			//付属品
			mouseTrail();
			createBg();
			createHeader();
			createBar();
			createVolume();
			//******************************************
			addEventListener(Event.ENTER_FRAME, loop);
		}
		//************************************************************
		//マウストレイル
		private function mouseTrail():void {
			trail = addChild(new Sprite()) as Sprite;
			trail.graphics.beginFill(0xFFFFFF);
			trail.graphics.drawRect( -10, 0, 20, 1);
			trail.graphics.drawRect(0 , -10, 1, 20);
			trail.graphics.endFill();
			var circles:Sprite=trail.addChild(new Sprite()) as Sprite;
			circles.graphics.beginFill(0xFFFFFF);
			circles.graphics.drawRect( -465, 0, 1030, 1);
			circles.graphics.drawRect( 0, -465, 1, 1030);
			circles.graphics.endFill();
			circles.alpha = 0.2;	
		}
		//全体のBG
		private function createBg():void {
			var pattern:BitmapData = background()
			var bg:Sprite = addChild(new Sprite()) as Sprite;
			bg.graphics.beginBitmapFill(pattern);
			bg.graphics.drawRect(0, 0, 465, 465)
			bg.graphics.endFill();
			bg.alpha = 0.3;
		}
		//上のTitle&BG
		private function createHeader():void {
			var tbg:Sprite = addChild(new Sprite()) as Sprite;
			tbg.graphics.beginFill(0);
			tbg.graphics.drawRect( 0, 0, 465, 18);
			tbg.graphics.endFill();
			var title:Label = new Label(this, 147, 0, "Barrage of Rainbow Exploration ver.0.1"); 
			title.blendMode = "invert"
		}
		//左上のColor Bar
		private function createBar():void {
			var cl:Array = [0xff0000, 0x00ff00, 0x0000ff]
			var clsp:Sprite = addChild(new Sprite()) as Sprite;
			for (var i:int = 0; i < 3; i++) {
				var colors:Sprite = clsp.addChild(new Sprite()) as Sprite;
				colors.graphics.beginFill(cl[i]);
				colors.graphics.drawRect( 0, 0, 10,10);
				colors.graphics.endFill();
				colors.x = 11 * i;
			}
			clsp.x = 4;
			clsp.y = 4;
		}
		//右上のvoloume
		private function createVolume():void {
			var volsp:Sprite = addChild(new Sprite()) as Sprite;
			for (var i:int = 0; i < 7; i++) {
				var vol:Sprite = volsp.addChild(new Sprite()) as Sprite;
				vol.graphics.beginFill(0xFFFFFF);
				vol.graphics.drawRect( 0, 0, 1, -10);
				vol.graphics.endFill();
				vol.x=2*i
				volArr[i] = vol;
			}
			volsp.x = stage.stageWidth - volsp.width - 5;
			volsp.y = 15;
		}
		private function voloop():void {
			for each(var v:Sprite in volArr) {
				v.height = Math.sin(getTimer() / 500 * Math.random() * 5) * 10;
			}	
		}
		private function trailoop():void {
			vx += (mouseX - trail.x) * SPRING;
			vy += (mouseY - trail.y) * SPRING;
			vx *= FRICTION;
			vy *= FRICTION;
			trail.x += int(vx);
			trail.y += int(vy);
		}
		//************************************************************
		private function loop(e:Event):void {
			voloop();
			trailoop();
			var zp:Number = 0;
			var i:int;
			for each(var p:Particle in pArr) {
				var xa:Number = Math.sin(Math.PI * (getTimer()+i*100) % 30000 / 30000 * 360 / 180) / 20;
                var ya:Number = Math.sin(Math.PI * (getTimer()+i*100) % 1500 / 1500 * 360 / 180) / 20;
                var yp:Number = p._y * Math.cos(ya) -p._z * Math.sin(ya);
                zp =p._y * Math.sin(ya) + p._z * Math.cos(ya);
                var xp:Number = p._x * Math.cos(xa) + zp * Math.sin(xa);
                zp = ( -p._x) * Math.sin(xa) + zp * Math.cos(xa);
				p._x = xp;
				p._y = yp;
                p._z = zp;
				p.alpha = Math.random() * 1;
				(p._z < -95)?p.visible = false:p.visible = true;
				ratio = 1 / (p._z /100 + 1)
				var num:Number = 0;
				p.scaleY = num = ratio * 7;
				p.scaleX = num;
				p.x += (p._x * ratio + (mouseX) - p.x) / 10;
				p.y += (p._y * ratio +( mouseY) - p.y) / 10;
				canvas.setPixel(p.x, p.y, grad.getColor(i /PARTICLE_NUM)); 
				i++;
			}
			clones.lock(); 
            canvas.lock();
			canvas.draw(sp)
			clones.merge(canvas, canvas.rect, new Point(),zp/10,zp/100, zp*10,0.5);
			clones.draw(canvas, null, new ColorTransform(100 * zp, 10, 10), "add");
            canvas.applyFilter(canvas, canvas.rect, new Point(0, 0), new BlurFilter(20, 20, 1)); 
			clones.scroll(0, 1);
            clones.colorTransform(clones.rect, clt); 
            canvas.colorTransform(canvas.rect, clt);
			clones.unlock(); 
            canvas.unlock();			
		}
        public function background():BitmapData{ 
            return BitmapPatternBuilder.build( 
                [[1, 0, 0], 
                [0, 1, 0],
				[0, 0, 1]],
                [0xFF000000, 0xffffffff] 
            ); 
        } 
	}
}

import flash.display.Graphics;
import flash.display.Sprite;
class Particle extends Sprite {
	public var _x:Number=0;
	public var _y:Number=0;
	public var _z:Number=0;
	public function draw(color:int, alpha:Number, size:Number):void {
		graphics.beginFill(color, alpha);
		graphics.drawCircle(0, 0, size);
		graphics.endFill();
    }
}

import frocessing.color.ColorLerp;

import org.libspark.betweenas3.core.easing.IEasing;
import org.libspark.betweenas3.easing.Linear;

class Gradation {
    
    private var _colors:Array;
    private var _easing:IEasing;
    
    public function Gradation(...args) {
        _colors = args.concat();
        _easing = Linear.linear
    }
    
    public function setEasing(easing:IEasing):void {
        _easing = easing;
    }
    
    public function getColor(position:Number):uint {
        position = (position < 0 ? 0 : position > 1 ? 1 : position) * (_colors.length - 1);
        var idx:int = position;
        var alpha:Number = _easing.calculate(position - idx, 0, 1, 1);
        if (alpha == 0) {
            return _colors[idx];
        } else {
            return ColorLerp.lerp(_colors[idx], _colors[idx + 1], alpha);
        }
    }
}


/**-----------------------------------------------------
 * @see http://wonderfl.net/code/5f88476bd21cac4d45ad2086af2333782a5d3cb8
 * ----------------------------------------------------- 
*/ 
import flash.display.Bitmap; 
import flash.display.BitmapData; 
import flash.display.Graphics; 
     
class BitmapPatternBuilder{ 
    /** 
     * creates BitmapData filled with dot pattern. 
     * First parameter is 2d array that contains color index for each pixels; 
     * Second parameter contains color reference table. 
     * 
     * @parameter pattern:Array 2d array that contains color index for each pixel. 
     * @parameter colors:Array 1d array that contains color table. 
     * @returns BitmapData 
     */ 
    public static function build(pattern:Array, colors:Array):BitmapData{ 
        var bitmapW:int = pattern[0].length; 
        var bitmapH:int = pattern.length; 
        var bmd:BitmapData = new BitmapData(bitmapW,bitmapH,true,0x000000); 
        for(var yy:int=0; yy<bitmapH; yy++){ 
            for(var xx:int=0; xx<bitmapW; xx++){ 
                var color:int = colors[pattern[yy][xx]]; 
                bmd.setPixel32(xx, yy, color); 
            } 
        } 
        return bmd; 
    } 
     
    /** 
     * short cut function for Graphics.beginBitmapFill with pattern. 
     */ 
    public static function beginBitmapFill(pattern:Array, colors:Array, graphics:Graphics):void{ 
        var bmd:BitmapData = build(pattern, colors); 
        graphics.beginBitmapFill(bmd); 
        bmd.dispose();         
    } 
} 
