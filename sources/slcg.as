/**
 * 桜の木の描画の練習用
 */
package {
  import flash.display.Sprite;
  import flash.display.Stage;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.geom.Point;

  public class FlashTest extends Sprite {
    private var STAGE:Stage;
    private var generations:int = 10;
    private var branches:Array = [];
    private var leaves:Array = [];

    public function FlashTest() {
      STAGE = this.stage;
      STAGE.align = StageAlign.TOP_LEFT;
      STAGE.scaleMode = StageScaleMode.SHOW_ALL;
      init();
    }
 
    private function init():void {
      var w:Number = STAGE.stageWidth / 2;
      var h:Number = STAGE.stageHeight;
      var mstep:int = Math.round(Util.getRandomRange(1, 3));
      var p:Point = new Point(w, h);
      branches[0] = new Branch(0, mstep, p, Math.PI / 2);
      grow();
    }

    private function grow():void {
      var branch:Branch;
      var branchPoint:Point;
      var nextSlot:int = 1;
      var leaf:Leaf;

      var i:int = 0;
      var slots:int = (Math.pow(2, generations + 1) >> 0) - 1;
      for(i = 0; i < slots; i++) {
        branch = branches[i] as Branch;
        while(branch != null && branch.steps > 0) {
          branch.draw();
          addChild(branch);
        }
        if(nextSlot <= slots - 2) {
          branches[nextSlot++] = branch.createChild(0);
          branches[nextSlot++] = branch.createChild(1);
        }
        if(branch.generation == generations) {
          branchPoint = branch.endPoint;
          leaf = new Leaf(branchPoint.x, branchPoint.y);
          addChild(leaf);
          leaves.push(leaf);
        }
      }
    }
  }
}

/*
 * Internal classes
 */
import flash.display.Shape;
import flash.display.Graphics;
import flash.geom.Point;

// Branch class
internal class Branch extends Shape {
  private var maxSteps:int;
  private var stepLength:Number;
  private var angle:Number;
  private var maxAngleVar:Number = 0.2;
  private var startPoint:Point;
  public var endPoint:Point;
  public var generation:int;
  public var steps:int;

  public function Branch(gen:int, mstep:int, p:Point, ang:Number) {
    generation = gen;
    maxSteps = mstep;
    steps = mstep;
    stepLength = 100.0 / (generation + 1);
    startPoint = new Point(p.x, p.y);
    endPoint = new Point(p.x, p.y);
    angle = ang;
  }

  public function draw():void {
    angle += maxAngleVar * Util.getRandomRange(-1, 1);
    stepLength *= 0.8;
    endPoint.x += stepLength * Math.cos(angle);
    endPoint.y -= stepLength * Math.sin(angle);

    // draw branch
    var g:Graphics = this.graphics;
    g.clear();
    g.beginFill(0x000000);
    g.lineStyle(Math.floor(20 / (generation + 1)), 0x332010);
    g.moveTo(startPoint.x, startPoint.y);
    g.lineTo(endPoint.x, endPoint.y);
    g.endFill();

    steps -= 1;
  }

  // create child branch
  public function createChild(cnt:int):Branch {
    var newGen:int = generation + 1;
    var newMstep:int = Math.floor(Util.getRandomRange(1, 4));
    var angleShift:Number = 0.5;
    if(cnt == 1) {
      angleShift = -1 * angleShift;
    }
    var childAngle:Number = angle + angleShift;
    var parentPoint:Point = new Point(endPoint.x, endPoint.y);
    return new Branch(newGen, newMstep, parentPoint, childAngle);
  }
}

// Leaf class
internal class Leaf extends Shape {
  private var _x:Number;
  private var _y:Number;

  public function Leaf(dx:Number, dy:Number) {
    _x = dx;
    _y = dy;

    draw();
  }

  private function draw():void {
    // draw leaf
    var g:Graphics = this.graphics;
    g.clear();
    g.beginFill(0xf2afc1);
    g.drawEllipse(_x + 1.5, _y, Util.getRandomRange(2, 10), Util.getRandomRange(2, 10));
    g.endFill();

    g.beginFill(0xed719e);
    g.drawEllipse(_x, _y + 1.5, Util.getRandomRange(2, 10), Util.getRandomRange(2, 10));
    g.endFill();

    g.beginFill(0xe54c7c);
    g.drawEllipse(_x - 1.5, _y, Util.getRandomRange(2, 10), Util.getRandomRange(2, 10));
    g.endFill();
  }
}

// Util class that contains static methods
internal class Util {
  public static function getRandomRange(min:Number, max:Number):Number {
    return (max - min) * Math.random() + min;
  }
}