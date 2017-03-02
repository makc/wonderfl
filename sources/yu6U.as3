//最初は赤い四画だけですが、時間が経つと・・・
package
{
    import flash.display.*;

    import org.libspark.thread.Thread;
    import org.libspark.thread.EnterFrameThreadExecutor;

	[SWF(width = 465, height = 465, frameRate = 60)]
	public class SoumenTest extends Sprite {

		public function SoumenTest() {
                        Thread.initialize(new EnterFrameThreadExecutor());

			var main:MainThread = new MainThread(this);
			main.start();
			var main2:MainThread2 = new MainThread2(this);
			main2.start();
		}
	}
}

//-------------------------------------------------------------
//MainThread
//そうめん処理クラス
//-------------------------------------------------------------

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweener.TweenerThread;

internal class MainThread extends Thread {
	public function MainThread(layer:DisplayObjectContainer) {
		_layer = layer;
	}
	
	private var _layer:DisplayObjectContainer;
	private var _shape:DisplayObject;
	
	override protected function run():void {
		// シェイプを作成
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000);
		shape.graphics.drawRect(0, 0, 30, 30);
		shape.graphics.endFill();
		shape.x = 0;
		shape.y = 0;
		_shape = _layer.addChild(shape);

		// アニメーション開始
		moveRight();
	}
	
	/**
	 * 右アニメ
	 */
	private function moveRight():void {
		var tween:Thread = new TweenerThread(_shape, { x: 435, y: 0, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveDown);
	}
	
	/**
	 * 下アニメ
	 */
	private function moveDown():void {
		var tween:Thread = new TweenerThread(_shape, { x: 435, y: 435, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveLeft);
	}
	
	/**
	 * 左アニメ
	 */
	private function moveLeft():void {
		var tween:Thread = new TweenerThread(_shape, { x: 0, y: 435, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveUp);
	}
	
	/**
	 * 上アニメ
	 */
	private function moveUp():void {
		var tween:Thread = new TweenerThread(_shape, { x: 0, y: 0, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveRight);
        }
}



//-------------------------------------------------------------
//MainThread
//そうめん処理クラス
//-------------------------------------------------------------

internal class MainThread2 extends Thread {
	public function MainThread2(layer:DisplayObjectContainer)
	{
		_layer = layer;
	}
	
	private var _layer:DisplayObjectContainer;
	private var _shape:DisplayObject;
	
	override protected function run():void
	{
		// シェイプを作成
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 30, 30);
		shape.graphics.endFill();
		shape.x = 0;
		shape.y = 0;
		_shape = _layer.addChild(shape);

		// アニメーション開始
		moveRight();
	}
	
	/**
	 * 右アニメ
	 */
	private function moveRight():void
	{
		var tween:Thread = new TweenerThread(_shape, { x: 435, y: 0, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveDown);
	}
	
	/**
	 * 下アニメ
	 */
	private function moveDown():void
	{
		var tween:Thread = new TweenerThread(_shape, { x: 435, y: 435, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveLeft);
	}
	
	/**
	 * 左アニメ
	 */
	private function moveLeft():void
	{
		var tween:Thread = new TweenerThread(_shape, { x: 0, y: 435, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveUp);
	}
	
	/**
	 * 上アニメ
	 */
	private function moveUp():void
	{
		var tween:Thread = new TweenerThread(_shape, { x: 0, y: 0, time: 1.0 } );
		tween.start();
		tween.join();
		next(moveLast);

        }

	/**
	 * 最後に時間を置く
	 */
	private function moveLast():void
	{
		sleep(100)
		next(moveRight);

        }
}
