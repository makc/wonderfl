package {
import flash.display.*;
import flash.events.Event;
import flash.utils.setTimeout;

public class Dijkstra extends Sprite {
    private var maze:Array = [];            // 迷路を格納した配列
    private var open:Array = [];            // 未確定のノード一覧
    private var dx:Array = [0, 1, 0, -1];   // X方向移動用配列
    private var dy:Array = [1, 0, -1, 0];   // Y方向移動用配列
    private var W:int;                      // 迷路の横幅
    private var H:int;                      // 迷路の縦幅

    // コンストラクタ
    public function Dijkstra() {
        stage.scaleMode = "noScale";

        // wonderfl 背景色対策
        graphics.beginFill(0);
        graphics.drawRect(-Node.SIZE, -Node.SIZE, 465, 465);
        graphics.endFill();
        x = y = Node.SIZE;

        // MAZE のパースを行う
        var mazeArray:Array = MAZE.split(/\r?\n/);
        W = mazeArray[0].length;
        H = mazeArray.length;

        // 各マスを初期化する
        maze = [];
        for (var yy:int = 0; yy < H; yy++) {
            maze[yy] = [];
            for (var xx:int = 0; xx < W; xx++) {
                var block:Node = new Node(mazeArray[yy].charAt(xx), xx, yy);
                addChild(block);
                maze[yy][xx] = block;

                // スタート地点のみスコアを 0 とし、open に加える
                if (block.isStart) {
                    block.score = 0;
                    open.push(block);
                }
            }
        }

        // nextStep の定期呼び出しを開始する
        setTimeout(nextStep, 100);
    }

    // ダイクストラ法の１ステップを実行する
    private function nextStep():void {
        // 未確定ノードの中から、スコアが最小となるノード u を決定する
        var minScore:int = int.MAX_VALUE;
        var minIndex:int = -1;
        var u:Node = null;
        for (var i:int = 0; i < open.length; i++) {
            var block:Node = open[i] as Node;
            if (block.done) continue;
            if (block.score < minScore) {
                minScore = block.score;
                minIndex = i;
                u = block;
            }
        }

        // 未確定ノードがなかった場合は終了
        if (u == null) {
            return;
        }

        // ノード u を確定ノードとする
        open.splice(minIndex, 1);
        u.done = true;
        u.draw();

        // ノード u の周りのノードのスコアを更新する
        for (i = 0; i < dx.length; i++) {
            // 境界チェック
            if (u.yy + dy[i] < 0 || u.yy + dy[i] >= H || u.xx + dx[i] < 0 || u.xx + dx[i] >= W) continue;

            // ノード v を取得する
            var v:Node = maze[u.yy + dy[i]][u.xx + dx[i]] as Node;

            // 確定ノードや壁だったときにはパスする
            if (v.done || v.isWall) continue;

            // 既存のスコアより小さいときのみ更新する
            if (u.score + 1 < v.score) {
                v.score = u.score + 1;
                v.prev = u;
                v.draw();

                // open リストに追加
                if (open.indexOf(v) == -1) open.push(v);
            }
        }

        setTimeout(nextStep, 100);
    }

    private var MAZE:String = 
<>**************************
*S* *                    *
* * *  *  *************  *
* *   *    ************  *
*    *                   *
************** ***********
*                        *
** ***********************
*      *              G  *
*  *      *********** *  *
*    *        ******* *  *
*       *                *
**************************</>;
}
}

import flash.display.Sprite;
import flash.text.TextField;
import frocessing.color.ColorHSV;

class Node extends Sprite {
    public var score:Number;        // ダイクストラ法のノードのスコア
    public var done:Boolean;        // ダイクストラ法の確定ノード一覧
    public var prev:Node;          // ダイクストラ法の直前の頂点を記録
    public var isWall:Boolean;      // 壁かどうか
    public var isGoal:Boolean;      // ゴール地点かどうか
    public var isStart:Boolean;     // スタート地点かどうか
    public var isRoute:Boolean;     // スタートからゴールへのルート上の点かどうか
    public var xx:int;              // マスの x 方向インデックス
    public var yy:int;              // マスの y 方向インデックス

    public static const SIZE:Number = 16;   // 描画時の１ブロックサイズ
    public const WALL:uint = 0x666666;      // 壁の色
    public const NORMAL:uint = 0xffffff;    // 通行できる場所の色

    // マスの初期化
    public function Node(c:String, _xx:int, _yy:int) {
        isStart = (c == "S");
        isWall = (c == "*");
        isGoal = (c == "G");
        xx = _xx;
        yy = _yy;
        x = xx * SIZE;
        y = yy * SIZE;

        score = int.MAX_VALUE;
        done = false;
        prev = null;

        // スタートとゴールには文字列を表示する
        if (isStart || isGoal) {
            var t:TextField = addChild(new TextField()) as TextField;
            t.selectable = false;
            t.width = SIZE;
            t.htmlText = '<p align="center"><b>' + c + '</b></p>';
            t.x = t.y = -SIZE / 2;
        }

        draw();
    }

    // 描画する
    public function draw():void {
        graphics.clear();

        // 確定したノードはスコアに応じた色にする
        graphics.beginFill(isWall ? WALL : 
                           done ? new ColorHSV(score * 10, .5).value : NORMAL);
        graphics.drawRect(-SIZE / 2, - SIZE / 2, SIZE, SIZE);
        graphics.endFill();

        // prev ノードが存在する場合は矢印を描画する
        if (prev) {
            graphics.lineStyle(0, isRoute ? 0x000000 : new ColorHSV(score * 10, 1, .8).value);
            graphics.moveTo(SIZE * .4, 0);
            graphics.lineTo(-SIZE * .4, 0);
            graphics.lineTo(-SIZE * .2, SIZE * .1);
            graphics.lineTo(-SIZE * .4, 0);
            graphics.lineTo(-SIZE * .2, -SIZE * .1);
            if (prev.xx < xx) rotation = 0;
            if (prev.xx > xx) rotation = 180;
            if (prev.yy < yy) rotation = 90;
            if (prev.yy > yy) rotation = 270;
        }

        // ゴールが確定したときには、手前のノードを全て辿って
        // isRoute を true にする
        if (isGoal && done) {
            var b:Node = prev;
            while (b) {
                b.isRoute = true;
                b.draw();
                b = b.prev;
            }
        }
    }
}