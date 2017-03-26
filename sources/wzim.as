/**
 * 注意：　Frocessing と　Papervision3D　が必要です
 * 
 * @author yooKo@selflash
 * @version 1.0.0
 * @date    2009/10/24
 * @see     http://selflash.jp/
 * 
 * Please click.
 * The flame becomes deformed.
 *
 * クリックすると炎でできたテキストが変形します
 * 変形中は激重いので注意
 * 誰かが最適化してくれる事を望む
 **/
package {	
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.StageQuality;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.filters.BlurFilter;
    import flash.filters.BitmapFilterQuality;	
    import flash.filters.ColorMatrixFilter;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.events.MouseEvent;		
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;	
    import flash.utils.Timer;
    import flash.utils.getTimer;
	
    import org.papervision3d.cameras.*;   
    import org.papervision3d.view.BasicView;	
    import org.papervision3d.view.layer.ViewportLayer;  
    import org.papervision3d.view.layer.BitmapEffectLayer;			
    import org.papervision3d.core.effects.BitmapLayerEffect;
    import org.papervision3d.core.effects.BitmapColorEffect;	
    import org.papervision3d.core.effects.utils.BitmapClearMode;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;	
    import org.papervision3d.objects.DisplayObject3D;
  
    import net.hires.debug.Stats;

    import frocessing.color.ColorHSV;
	
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]

    public class FireText3D extends BasicView {	
	private var _container:DisplayObject3D;
	private var _pixels:Pixels;
	private var _particles:Array/*Particle*/ = [];
	private var _startTime:int;
	private var _textW:Number;
	private var _textH:Number;
        private var _bmd:BitmapData;        
	private var _currentNum:int = 0;		
        private var _count:int = 0;
		
	//========================================================================
	// constructor
	//========================================================================
	public function FireText3D() {	
            super(0, 0, true, false);			
            
            init();
        }

	//========================================================================
	// init
	//========================================================================
        private function init(e:Event = null):void {	
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = StageQuality.LOW;
            
	    camera.z = -80;
			
            var _layer:BitmapEffectLayer = new BitmapEffectLayer(viewport, stage.stageWidth * 0.8, stage.stageHeight, true, 0, BitmapClearMode.CLEAR_PRE, false);
	    viewport.containerSprite.addLayer(_layer);
	    //_layer.addEffect(new BitmapColorEffect(1, 1, 1, .7));		
	    _layer.addEffect(new BitmapLayerEffect(new BlurFilter(10, 10, BitmapFilterQuality.LOW), true));
	    _layer.addEffect(new BitmapLayerEffect(new ColorMatrixFilter([1.1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0])));	
	    _pixels = new Pixels(_layer);
	    _layer.addDisplayObject3D(_pixels);
	    _container = scene.addChild(new DisplayObject3D());
	    _container.addChild(_pixels);	
			
	    createText();	
			
            createBody(0, .2, 0xFF000000);
	    //perlinNoise　は　重い為縦を3倍の長さでBitmapDataを作成する
	    _bmd = new BitmapData(465, 465 * 3.5, false, 0x00000000);
			
	    stage.addEventListener(MouseEvent.CLICK, onClickHandler);
		
	    upDate();
			
	    startRendering();
			
	    stage.addChild(new Stats());
	}
	//========================================================================
	// createText
	//========================================================================
	private function createText():void {
            var tf:TextField = new TextField();
            tf.defaultTextFormat = new TextFormat("小塚ゴシック Pro H", 18, 0x000000, true);
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.text = "FIRE";
            _textW = tf.textWidth;
            _textH = tf.textHeight;            
        
            _bmd = new BitmapData(_textW + 5, _textH + 5, false, 0xFFFFFF);
            _bmd.draw(tf);
	}			
	//========================================================================
	// onClickHandler
	//========================================================================
	private function onClickHandler(e:MouseEvent = null):void {
	    _startTime = getTimer();
	    (_currentNum < 3) ? _currentNum++ : _currentNum = 0; 
	}		
	//========================================================================
	//　onEnterFrameHandler
	//========================================================================
	private var _rotateX:Number = 0;
	    private var _rotateY:Number = 0;
	    override protected function onRenderTick(event:Event = null):void { 
	    super.onRenderTick();
	
	    drawEffect();
			
	    switch (_currentNum) {
                case 1: 
                   collapsesAnimation();
		   upDate();
                break;	
		case 3:
		   revivalAnimation();
		   upDate();
		break;
	    }
	    _count++;
			
	    _rotateX += (stage.mouseX - stage.stageWidth * 0.5 - _rotateX) * 0.1;
	    _rotateY += (stage.mouseY - stage.stageHeight * 0.5 - _rotateY) * 0.1;
	    _pixels.rotationY = _rotateX * 0.5;
	    _pixels.rotationX = _rotateY * 0.5;
	}	
	//========================================================================
	//　drawEffect
	//========================================================================
        private var _offset:Array = [new Point(), new Point()];		
	    private const DRAW_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
	    private function drawEffect():void {
	    _bmd.lock();		
	    //_countが100の倍数の時だけperlinNoise！
	    if (_count % 240 == 0)_bmd.perlinNoise(30, 50, 1, 0, false, false, 0, true, _offset);	
	    _bmd.scroll(0, -5);			
	    _pixels.layer.canvas.lock();			
	    _pixels.layer.canvas.draw(_bmd, DRAW_MATRIX, null, BlendMode.SUBTRACT);
	    _pixels.layer.canvas.scroll(0, -5);
	    _pixels.layer.canvas.unlock();			
	    _bmd.unlock();		
	}
	//========================================================================
	//　再生アニメーション
	//========================================================================
	private function revivalAnimation():void {
	    var now:int = getTimer();
	    var len:int = _particles.length;
	    for (var i:int = 0; i < len; i++) {
	        var p:Particle = _particles[i];
	        var x_delay:Number = (1 - ((p.tx + _textW * .5) / _textW )) * 5000;
	        var y_delay:Number = (1 - ((p.ty + _textH * .5) / _textH )) * 500;
	        var z_delay:Number = (1 - ((p.tz + 6) / 12 )) * 1000;
	        var delay:Number = x_delay + y_delay + z_delay;
	        if (_startTime + delay > now) continue ;
	        //Math.absの高速化？
	        var xx:Number = p.tx - p.x;
	        var yy:Number = p.ty - p.y;
	        var zz:Number = p.tz - p.z;
	        var x:Number = (xx < 0)?xx * -1:xx;
	        var y:Number = (yy < 0)?yy * -1:yy;
	        var z:Number = (zz < 0)?zz * -1:zz;
	        if (x < .5 && y < .5 && z < .5) {
                p.x = p.tx;
                p.y = p.ty;
	        p.z = p.tz;
	        p.r = 20;
	        p.degree = 10;
	        p.c += (p.tc - p.c) * .2;
            }else {
                p.x += (p.tx - p.x) * .08;
                p.y += (p.ty - p.y) * .08;
                p.z += (p.tz - p.z) * .08;
		color.h = (getTimer() / 20000) * 360;
		p.c = rgb2argb(color.value, 1);						
                if (p.r > 3) {
		    p.x += ((p.x + p.r * Math.sin(Math.PI / 180 * p.degree)) - p.x) * .1;
		    p.y += ((p.y + p.r * Math.cos(Math.PI / 180 * p.degree)) - p.y) * .1;
		    p.z += ((p.z + p.r * Math.sin(Math.PI / 180 * p.degree)) - p.z) * .1;
		}
		if (p.r > 0) p.r -= .3;
		p.degree += 10;
             }
	}
}
	//========================================================================
	// collapsesAnimation
	//========================================================================
	private var color:ColorHSV = new ColorHSV(0, 0.5); 
            private function collapsesAnimation():void {
	        var now:int = getTimer();
		var len:int = _particles.length;
		for (var i:int = 0; i < len; i++) {
		    var p:Particle = _particles[i];
		    var x_delay:Number = (1 - ((p.tx + _textW * .6) / _textW )) * 5000;
		    var y_delay:Number = (1 - ((p.ty + _textH * .8) / _textH )) * 500;
		    var z_delay:Number = (1 - ((p.tz + 8 * .5) / 8 )) * 1000;
		    var delay:Number = x_delay + y_delay + z_delay;
		    if (_startTime + delay > now) continue ;
		    //Math.absの高速化？
		    var xx:Number = p.ex - p.x;
		    var yy:Number = p.ey - p.y;
		    var zz:Number = p.ez - p.z;
		    var x:Number = (xx < 0)?xx * -1:xx;
		    var y:Number = (yy < 0)?yy * -1:yy;
		    var z:Number = (zz < 0)?zz * -1:zz;
		    if (x < .5 && y < .5 && z < .5) {
			p.x = p.ex;
			p.y = p.ey;
			p.z = p.ez;
			p.r = 20;
			p.degree = 10;
		    }else {
			p.x += (p.ex - p.x) * .08;
			p.y += (p.ey - p.y) * .08;
			p.z += (p.ez - p.z) * .08;
			if (p.r > 3) {
		            p.x += ((p.ex + p.r * Math.cos(Math.PI / 180 * p.degree)) - p.x) * .1;
			    p.y += ((p.ey + p.r * Math.cos(Math.PI / 180 * p.degree)) - p.y) * .1;
			    p.z += ((p.ez + p.r * Math.sin(Math.PI / 180 * p.degree)) - p.z) * .1;
			}
			if (p.r) p.r -= .3;
			p.degree += 10;
		    }
		}
	}
	//========================================================================
	//　Particleが保持している情報を元にPixelsにaddPixel3D()
	//========================================================================
	private var _pixel3Ds:Array/*Pixel3D*/ = [];		
	private function upDate():void {
	    _pixels.removeAllpixels();
	    var len:int = _particles.length;
	    for (var i:int = 0; i < len; i++) {
	        var p:Particle = _particles[i];				
		var px:Pixel3D;
		color.h = (getTimer() / 5000) * 360;
		var c:int = rgb2argb(color.value, 1);						
		if (_pixel3Ds[i]) {
		    px = _pixel3Ds[i];
		    px.color = c;
		    px.x = p.x;
		    px.y = p.y;
		    px.z = p.z;
		}else {
		    _pixel3Ds[i] = new Pixel3D(rgb2argb(0xEFDD6D, 1), p.x, p.y, p.z);
		};
	    px = _pixel3Ds[i];
	    _pixels.addPixel3D(px);
	    }			
	}
	//========================================================================
	// createBody
	//========================================================================
	private var _c:uint;
	private function createBody(depth:Number = 0, distance:Number = 2, color:Number = NaN):void {
	    var p:Particle;	
	    var w:Number = _textW * .5;
	    var h:Number = _textH * .4;			
				
	    for (var i:int = 0, _y:Number = 0; _y < _textH; _y += distance ) {
		for (var _x:Number = 0; _x < _textW; _x += distance ) {
	            _c = _bmd.getPixel( _x, _y );
		    if (_c != 0xFFFFFF) {
		        _c = (color)?color:rgb2argb(_c, 1);	
		        p = _particles[i] || new Particle();
		        p.c = _c;
                        p.x = _x - w;
		        p.y = - _y + h;
		        p.z = depth;
		        p.tx = p.x;
		        p.ty = p.y;
		        p.tz = p.z;
		        p.tc = p.c;
		        _particles[i] = p;
		        i++;					
		    }
	        }
	    }
        }	
	//========================================================================
        // RGBをARGBに変換する
        //========================================================================
        private function rgb2argb(rgb:uint, alpha:Number):uint {
            return ((alpha * 0xff) << 24) + rgb;
        }
    }
}
//========================================================================
// 座標、色情報を保持するクラス		
//========================================================================
class Particle {
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var c:int;	
    public var tx:Number;
    public var ty:Number;
    public var tz:Number;
    public var tc:int;	
    public var ex:Number = (Math.random() - .5) * 2;
    public var ey:Number = (Math.random() - .5) * 2 - 30;
    public var ez:Number = (Math.random() - .5) * 2;
    public var ec:int;	
    public var r:Number = 2;
    public var degree:Number = 5;
}
