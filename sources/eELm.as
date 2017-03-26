//
//    曇りガラス ～fogged glass～
//
//    [Click] effect on / off
//    クリックでエフェクトの切り替えができます    
//
package 
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.display.BlendMode;
    import flash.events.Event;
    
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import flash.filters.BlurFilter;
    
    import flash.events.MouseEvent;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        private var lightlayer:Sprite;
        private var lightcanvas:BitmapData;
        private var lightsp:Sprite;
        
        private var glasslayer:Sprite;
        private var glasscanvas:BitmapData;
        
        private var glass:Glass;

        
        private var lightlist:/*LightParticle*/Array;
        private var blur:BlurFilter = new BlurFilter(8, 8, 2);
        private var blur2:BlurFilter = new BlurFilter(20, 20, 2);
        
        private var step:int = 0;
        private var effect:Boolean = false;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            graphics.beginFill(0);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            //    光源用レイヤー
            lightlayer = new Sprite();
            addChild( lightlayer );
            
            lightcanvas = new BitmapData( WIDTH, HEIGHT, true, 0 );
            lightlayer.addChild( new Bitmap( lightcanvas ) );
            
            lightsp = new Sprite();
            lightsp.blendMode = BlendMode.ADD;
            lightlayer.addChild( lightsp );
            
            lightlist = new Array();
            EraseLightLayer();
            
            //    ガラスレイヤー
            glasslayer = new Sprite();
            addChild( glasslayer );
            
            glasscanvas = new BitmapData(WIDTH, HEIGHT, true, 0);
            glasslayer.addChild( new Bitmap(glasscanvas) );
            
            glass = new Glass();
            glass.alpha = 0.5;
            glasslayer.addChild(glass);
            
            var mask:Glass = new Glass();
            glasslayer.mask = mask;
            glasslayer.addChild( mask );            
            
            stage.addEventListener(MouseEvent.CLICK, ChangeEffect );
            addEventListener( Event.ENTER_FRAME, EnterFrameHandler );
        }
        
        /**
         * 光源用レイヤーをガラスレイヤーで切り抜く
         */
        private function EraseLightLayer() : void
        {
            var glass:Glass = new Glass();
            glass.blendMode = BlendMode.ERASE;
            lightlayer.blendMode = BlendMode.LAYER;
            lightlayer.addChild( glass );            
        }
        
        /**
         * 光源追加
         */
        private function AddLight() : void
        {
            var light:LightParticle = new LightParticle();
            lightlist.push( light );    
        }
        
        /**
         * エフェクト切り替え
         * @param    e
         */
        private function ChangeEffect(e:MouseEvent) : void
        {
            effect = !effect;
        }
        
        private function EnterFrameHandler( e:Event ) : void
        {
            
            lightsp.graphics.clear();
            
            var num:int = lightlist.length;
            for ( var i:int = num - 1; i >= 0; i-- )
            {
                lightlist[i].y += lightlist[i].my;
                if ( lightlist[i].y > HEIGHT + lightlist[i].size )
                {
                    lightlist.splice( i, 1 );
                }else
                {
                    lightlist[i].Draw( lightsp.graphics );
                }
            }
            
            lightcanvas.lock();
            lightcanvas.fillRect(lightcanvas.rect, 0);
            lightcanvas.draw(lightsp);
            lightcanvas.applyFilter( lightcanvas, lightcanvas.rect, new Point(), blur );
            lightcanvas.unlock();
            
            
            glasscanvas.lock();
            if( !effect )    glasscanvas.fillRect(glasscanvas.rect, 0);
            glasscanvas.draw( lightcanvas );
            glasscanvas.applyFilter( glasscanvas, glasscanvas.rect, new Point(), blur2 );
            glasscanvas.unlock();
            
            step++;
            if( step % 10 == 0 )    AddLight();
        }
        
        
    }
    
}

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Graphics;

import frocessing.color.ColorHSV;

class Glass extends Sprite {
    
    private static const PARTSIZE:int = 50;

    private  var part:Array;
    public function Glass() {
        
        part = new Array();
        for ( var y:int = 0; y < int(HEIGHT / PARTSIZE) + 1; y++ )
        {
            for ( var x:int = 0; x < int(WIDTH / PARTSIZE) + 1; x++ )
            {
                var p:Shape = new Shape();
                p.x = x * PARTSIZE + PARTSIZE / 2;
                p.y = y * PARTSIZE + PARTSIZE / 2;
                p.graphics.beginFill(0xFFFFFF);
                p.graphics.moveTo( 0, 0 - PARTSIZE / 2 );
                p.graphics.lineTo( 0 + PARTSIZE / 2, 0 );
                p.graphics.lineTo( 0, 0 + PARTSIZE / 2 );
                p.graphics.lineTo( 0 - PARTSIZE / 2, 0 );
                p.graphics.endFill();
                part.push( p );
                
                this.addChild( p );
            }
        }    
        
        this.x = (WIDTH - (int(WIDTH / PARTSIZE) + 1) * PARTSIZE) / 2;
        this.y = (HEIGHT - (int(HEIGHT / PARTSIZE) + 1) * PARTSIZE) / 2;
    }
}

class LightParticle {
    
    public var my:Number = 0;
    public var size:Number;
    public var color:uint;
    
    public var x:Number;
    public var y:Number;
    
    public function LightParticle() {
        
        this.x = Math.random() * WIDTH;
        this.y = -20;
        size = Math.random() * 20 + 10;
        my = Math.random() * 5 + 1;
        
        colorhsv.h = Math.random() * 360;
        
        color = colorhsv.value;
    }

    public function Draw( g:Graphics ) : void
    {
        g.beginFill( color, 0.9);
        g.drawCircle( this.x, this.y, size );
        g.endFill();
    }
}

const WIDTH:int = 465;
const HEIGHT:int = 465;

var colorhsv:ColorHSV = new ColorHSV();