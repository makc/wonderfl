/**
 * Ginny Effect (Flash Player 9 or 10 compare version)
 * drawTriangles の速度検証
 *
 * -- run about --
 * StageQuality - HIGH
 * BitmapSmoothing - true
 *
 * -- 考察 --
 * ・drawTrianglesのほうが処理負荷が軽い
 * ・smoothingあるなし、ともに同じ結果が確認している
 * ・drawTrianglesを使うと妙なスムージングが適用される(解決法求む)
 *
 * Photo by
 * http://www.flickr.com/photos/88403964@N00/179493851/ (by clockmaker)
 */
package {
    import com.bit101.components.RadioButton;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import net.hires.debug.Stats;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor=0x0)]
    public class Main extends Sprite {
        public function Main():void {
            // init
            stage.quality = StageQuality.HIGH;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, 465, 465);
            // load
            var context:LoaderContext = new LoaderContext(true);
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, compHandler);
            loader.load(new URLRequest(IMAGE_URL), context);
            // stats
            addChild(new Stats());
            // ui
            radioA = new RadioButton(this, 10, 400, "FLASH PLAYER 10 (DRAW TRIANGLES)", true, onRadioChange);
            radioB = new RadioButton(this, 10, 430, "FLASH PLAYER 9 (CUSTOM)", false, onRadioChange);
        }
        private const IMAGE_URL:String = "http://farm1.static.flickr.com/44/179493851_5775990a83.jpg";
        private const IMG_H:int = 375;
        private const IMG_W:int = 500;
        private const SEGMENT:int = 30;
        private var isFp10Selected:Boolean = true;
        private var isHide:Boolean = false;
        private var isShift:Boolean = false;
        private var loader:Loader;
        private var radioA:RadioButton;
        private var radioB:RadioButton;
        private var sprite:Sprite;
        private var vertexs:Array;
        
        private function compHandler(e:Event):void {
            sprite = new Sprite();
            addChildAt(sprite, 0);
            vertexs = [];
            for (var xx:int = 0; xx <= SEGMENT; xx++) {
                vertexs[ xx ] = [];
                for (var yy:int = 0; yy <= SEGMENT; yy++) {
                    vertexs[ xx ][ yy ] = new Point(xx * IMG_W / SEGMENT, yy * IMG_H / SEGMENT);
                }
            }
            draw();
            addEventListener(Event.ENTER_FRAME, draw);
            stage.addEventListener(MouseEvent.CLICK, clickHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        }
        
        private function clickHandler(e:MouseEvent):void {
            var tweens:Array = [];
            var xx:int, yy:int, delay:Number;
            var px:Number = SEGMENT * (mouseX / IMG_W);
            var py:Number = SEGMENT * (mouseY / IMG_H);
            if (!isHide) {
                for (xx = 0; xx <= SEGMENT; xx++) {
                    for (yy = 0; yy <= SEGMENT; yy++) {
                        vertexs[ xx ][ yy ] = new Point(xx * IMG_W / SEGMENT, yy * IMG_H / SEGMENT);
                        delay = Math.sqrt((xx - px) * (xx - px) + (yy - py) * (yy - py)) / 40;
                        tweens.push(
                            BetweenAS3.delay(
                            BetweenAS3.tween(vertexs[ xx ][ yy ], {
                                x: Math.round(px * IMG_W / SEGMENT),
                                y: Math.round(py * IMG_H / SEGMENT)
                            }, null, delay, Cubic.easeIn),
                            delay / 2
                            )
                            )
                    }
                }
            } else {
                var max:Number = 0;
                for (xx = 0; xx <= SEGMENT; xx++) {
                    for (yy = 0; yy <= SEGMENT; yy++) {
                        vertexs[ xx ][ yy ] = new Point(px * IMG_W / SEGMENT, py * IMG_H / SEGMENT);
                        delay = Math.sqrt((xx - px) * (xx - px) + (yy - py) * (yy - py))
                        max = Math.max(max, delay);
                    }
                }
                for (xx = 0; xx <= SEGMENT; xx++) {
                    for (yy = 0; yy <= SEGMENT; yy++) {
                        delay = (max - Math.sqrt((xx - px) * (xx - px) + (yy - py) * (yy - py))) / 40;
                        tweens.push(
                            BetweenAS3.delay(
                            BetweenAS3.tween(vertexs[ xx ][ yy ], {
                                x: Math.round(xx * IMG_W / SEGMENT),
                                y: Math.round(yy * IMG_H / SEGMENT)
                            }, null, delay + 0.05, Quad.easeOut),
                            delay / 2
                            )
                            )
                    }
                }
            }
            var itw:ITween = BetweenAS3.parallelTweens(tweens);
            if (isShift)
                itw = BetweenAS3.scale(itw, 5);
            itw.play();
            isHide = !isHide;
        }
        
        /**
         * drawTriangles でテクスチャを貼り付けるメソッド
         * 参考： http://wonderfl.net/code/e7e1e28a9f20d73f11f0bb02d3e4b5f512c7cc0f
         */
        private function draw(e:Event = null):void {
            var vertices:Array /* of Number */ = [];
            var indices:Array /* of int */ = [];
            var uvtData:Array /* of Number */ = [];
            var xx:int, yy:int;
            for (yy = 0; yy <= SEGMENT; yy++) {
                for (xx = 0; xx <= SEGMENT; xx++) {
                    vertices.push(vertexs[ xx ][ yy ].x, vertexs[ xx ][ yy ].y);
                    uvtData.push(xx / SEGMENT, yy / SEGMENT);
                }
            }
            for (yy = 0; yy < SEGMENT; yy++) {
                for (xx = 0; xx < SEGMENT; xx++) {
                    indices.push(
                        xx + yy * (SEGMENT + 1),
                        xx + 1 + yy * (SEGMENT + 1),
                        xx + (yy + 1) * (SEGMENT + 1)
                        );
                    indices.push(
                        xx + 1 + yy * (SEGMENT + 1),
                        xx + 1 + (yy + 1) * (SEGMENT + 1),
                        xx + (yy + 1) * (SEGMENT + 1)
                        );
                }
            }
            var g:Graphics = sprite.graphics;
            g.clear();
            if (isFp10Selected) {
                var verticesV:Vector.<Number> = Vector.<Number>(vertices);
                var indicesV:Vector.<int> = Vector.<int>(indices);
                var uvtDataV:Vector.<Number> = Vector.<Number>(uvtData);
                g.beginBitmapFill(Bitmap(loader.content).bitmapData, null, false, true);
                g.drawTriangles(verticesV, indicesV, uvtDataV);
                g.endFill();
            } else {
                GraphicUtil.drawTriangles(g, Bitmap(loader.content).bitmapData, vertices, indices, uvtData);
            }
        }
        
        /**
         * Shiftキーを押してるとスローモーションになる
         * macの挙動と同じように
         */
        private function keyUpHandler(e:KeyboardEvent):void {
            if (e.keyCode == 16)
                isShift = false;
        }
        
        private function keyDownHandler(e:KeyboardEvent):void {
            if (e.keyCode == 16)
                isShift = true;
        }
        
        private function onRadioChange(e:Event):void {
            isFp10Selected = e.currentTarget == radioA;
            e.stopPropagation();
        }
    }
}
import flash.display.*;
import flash.geom.*;

class GraphicUtil {
    public static function drawTriangles(g:Graphics, bitmapData:BitmapData, vertices:Array /*Number*/, indices:Array /*int*/, uvtData:Array /*Number*/):void {
        if (vertices.length % 2 != 0)
            throw new Error();
        if (indices.length % 3 != 0)
            throw new Error();
        if (uvtData.length % 2 != 0)
            throw new Error();
        for (var i:int = 0; i < indices.length; i += 3) {
            var p0:Point = new Point(bitmapData.width * uvtData[ indices[ i ] * 2 ], bitmapData.height * uvtData[ indices[ i ] * 2 + 1 ]);
            var p1:Point = new Point(bitmapData.width * uvtData[ indices[ i + 1 ] * 2 ], bitmapData.height * uvtData[ indices[ i + 1 ] * 2 + 1 ]);
            var p2:Point = new Point(bitmapData.width * uvtData[ indices[ i + 2 ] * 2 ], bitmapData.height * uvtData[ indices[ i + 2 ] * 2 + 1 ]);
            var a0:Point = new Point(vertices[ indices[ i ] * 2 ], vertices[ indices[ i ] * 2 + 1 ]);
            var a1:Point = new Point(vertices[ indices[ i + 1 ] * 2 ], vertices[ indices[ i + 1 ] * 2 + 1 ]);
            var a2:Point = new Point(vertices[ indices[ i + 2 ] * 2 ], vertices[ indices[ i + 2 ] * 2 + 1 ]);
            var matrix:Matrix = _buildTransformMatrix(p0, p1, p2, a0, a1, a2);
            g.beginBitmapFill(bitmapData, matrix, false, true);
            _drawTriangle(g, p0, p1, p2, matrix);
            g.endFill();
        }
    }
    
    private static function _buildTransformMatrix(
        a0:Point, a1:Point, a2:Point,
        b0:Point, b1:Point, b2:Point):Matrix {
        var matrixA:Matrix = new Matrix(
            a1.x - a0.x, a1.y - a0.y,
            a2.x - a0.x, a2.y - a0.y);
        matrixA.invert();
        var matrixB:Matrix = new Matrix(
            b1.x - b0.x, b1.y - b0.y,
            b2.x - b0.x, b2.y - b0.y);
        var matrix:Matrix = new Matrix();
        matrix.translate(-a0.x, -a0.y); // (原点)へ移動 
        matrix.concat(matrixA); // 単位行列に変換(aの座標系の逆行列)
        matrix.concat(matrixB); // bの座標系に変換 
        matrix.translate(b0.x, b0.y); // b0へ移動 
        return matrix;
    }
    
    private static function _drawTriangle(g:Graphics, p0:Point, p1:Point, p2:Point, matrix:Matrix):void {
        p0 = matrix.transformPoint(p0);
        p1 = matrix.transformPoint(p1);
        p2 = matrix.transformPoint(p2);
//        g.lineStyle(2, 0x808080); // debug
        g.moveTo(p0.x, p0.y);
        g.lineTo(p1.x, p1.y);
        g.lineTo(p2.x, p2.y);
        g.lineTo(p0.x, p0.y);
    }
}