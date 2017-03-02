package
{
    import flash.display.Sprite;
    public class Main extends Sprite
    {
        public function Main()
        {
            // 背景を真っ黒に
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();

            var panel:Panel = new Panel();
            addChild(panel);
        }
    }
}

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BevelFilter;
import flash.geom.Point;
import org.libspark.betweenas3.BetweenAS3;

class Panel extends Sprite // ブロックはパネルに貼る
{
    public static const WIDTH:int = 15;     // ブロックの数 - 横
    public static const HEIGHT:int = 15;     // ブロックの数　- 縦
    private var blocks:Array;

    public function Panel()
    {
        createBlocks();
    }

    private function createBlocks():void

    {
        blocks = [];
        for (var y:int = 0; y < HEIGHT; y++)
        {
            blocks[y] = [];
            for (var x:int = 0; x < WIDTH; x++)
            {
                var block:Block = new Block();
                block.x = x * Block.WIDTH;
                block.y = y * Block.HEIGHT;
                addChild(block);
                blocks[y][x] = block;
            }
        }
    }

    // 二次元配列から引数のブロック位置を検索。
    // 見つかったらPoint(x, y)で返却。
    // 見つからなかったらnullを返す
    public function searchBlock(block:Block):Point
    {
        for (var y:int = 0; y < HEIGHT; y++)
        {
            for (var x:int = 0; x < WIDTH; x++)
            {
                if (blocks[y][x] == block)
                {
                    return new Point(x, y); // ブロックが見つかったので、Pointで返却。
                }
            }
        }        
        return null; // 見つからなかったのでnullを返す。
    }

    // ブロックを消す処理
    // block[ty][tx].colorが引数で渡されたcolorと同じなら削除
    // 上下左右のブロックを調べる
    public function deleteBlock(tx:int, ty:int, color:int):void
    {
        if (tx < 0 || WIDTH  <= tx || 
            ty < 0 || HEIGHT <= ty) return; // 配列外ならリターン
        if (blocks[ty][tx] == null) return; // nullだったらリターン
        if (blocks[ty][tx].color != color) return; // クリックしたブロックの色と違っていたらリターン

        // 条件は満たしたのでブロックを消す
        removeChild(blocks[ty][tx]);
        blocks[ty][tx] = null;

        // 周りの色を調べる
        deleteBlock(tx - 1, ty, color); // 左へ
        deleteBlock(tx + 1, ty, color); // 右へ
        deleteBlock(tx, ty - 1, color); // 上へ
        deleteBlock(tx, ty + 1, color); // 下へ
    }

    // ブロックを消すと隙間が空くので縦に詰める処理
    // 左から右へ、下から上へ走査する
    public function vPack():void
    {
        for (var x:int = 0; x < WIDTH; x++)
        {
            for (var y:int = HEIGHT - 1; y >= 0; y--)
            {
                if (blocks[y][x] == null) // 隙間を見つけた
                {
                    for (var yy:int = y - 1; yy >= 0; yy--) // その一つ上から縦に走査
                    {
                        if (blocks[yy][x] != null) // ブロックを見つけたので[y][x]まで詰めなければならない
                        {
                            blocks[y][x] = blocks[yy][x]; // 配列の位置を変更
                            blocks[yy][x] = null;    //　元にあった位置は削除しておく

                            // 0.3秒かけて下にずらす。
                            BetweenAS3.tween(blocks[y][x], {y:y * Block.HEIGHT}, null, 0.3).play(); 
                            break;
                        }
                    }
                }
            }
        }
    }

    public function hPack():void
    {
        var y:int = HEIGHT - 1; //　一番下の段だけ走査
        for (var x:int = 0; x < WIDTH; x++)
        {
            if (blocks[y][x] == null) // 一番下の段に何もないということは、ここに右のブロックを詰めなければならない
            {
                for (var xx:int = x + 1; xx < WIDTH; xx++) // その一つ右から走査。
                {
                    if (blocks[y][xx] != null) // ブロックを見つけた
                    {
                        for (var yy:int = HEIGHT - 1; yy >= 0; yy--) // 縦の一段をまるまる左に詰める処理
                        {
                            if (blocks[yy][xx] == null) break; // もうずらすブロックが無いということでbreak
                            blocks[yy][x] = blocks[yy][xx]; // 配列の位置を変更
                            blocks[yy][xx] = null; // 元の位置にnullを入れておく

                            // 0.3秒かけて左にずらす。
                            BetweenAS3.tween(blocks[yy][x], {x:x * Block.WIDTH}, null, 0.3).play(); 
                        }
                        break;
                    }
                }
            }
        }
    }

    // 周りに自分の色と同じマスが1つでもあったらtrue, なかったらfalse.
    public function colorCheck(tx:int, ty:int, color:int):Boolean
    {
        var check:Boolean = false;
        if (0 <= tx - 1 && blocks[ty][tx - 1] != null && blocks[ty][tx - 1].color == color) check = true;
        else if (tx + 1 < WIDTH && blocks[ty][tx + 1] != null && blocks[ty][tx + 1].color == color) check = true;
        else if (0 <= ty - 1 && blocks[ty - 1][tx] != null && blocks[ty - 1][tx].color == color) check = true;
        else if (ty + 1 < HEIGHT && blocks[ty + 1][tx] != null && blocks[ty + 1][tx].color == color) check = true;
        return check;
    }

    // もう消せるブロックが無いならtrue, まだ消せるブロックがあるようならfalseを返す
    public function endCheck():Boolean
    {
        for (var y:int = 0; y < HEIGHT; y++)
        {
            for (var x:int = 0; x < WIDTH; x++)
            {
                if (blocks[y][x] == null) continue;
                if (colorCheck(x, y, blocks[y][x].color)) return false; // 周りに同じ色が一つでもあったら
            }
        }
        return true;
    }
}

class Block extends Sprite
{
    public static const COLORS:Array = [0xED1A3D, 0x00B16B, 0x007DC5];
    public static const WIDTH:int = 31; // ブロックの横幅
    public static const HEIGHT:int = 31; // ブロックの縦幅
    public static const MARGIN_W:int = 1;
    public static const MARGIN_H:int = 1;
    public static const ELLIPSE_WIDTH:int = 15;
    public static const ELLIPSE_HEIGHT:int = 15;
    public var color:int;
    public function Block()
    { 
        graphics.beginFill(0x0, 0);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        color = COLORS[int(Math.random() * COLORS.length)];
        graphics.beginFill(color); // 色をランダムで指定
        graphics.drawRoundRect(MARGIN_W, MARGIN_H, WIDTH - MARGIN_W * 2, HEIGHT - MARGIN_H * 2, ELLIPSE_WIDTH, ELLIPSE_HEIGHT);
        graphics.endFill();

        // ベベルフィルターでブロックに質感を持たせる
        this.filters = [new BevelFilter(4, 45, 0xFFFFFF, 1, 0x0, 1, 20, 20, 1, 3, "inner")];
        addEventListener(MouseEvent.CLICK, onMouseDown);
    }
    private function onMouseDown(event:MouseEvent):void 
    {
        var panel:Panel = this.parent as Panel
        var point:Point = panel.searchBlock(this);
        if (point)
        {
            if (!panel.colorCheck(point.x, point.y, color)) return;
            panel.deleteBlock(point.x, point.y, this.color);
            panel.vPack();
            panel.hPack();

            // 終了判定
            if (panel.endCheck())
            {
                trace("END");
            }
        }
    }
}