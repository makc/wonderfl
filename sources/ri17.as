/*
* Flash初作品です。
* 以前作った流砂のシミュレーションをASで実装してみるテスト。
* 右クリックメニューから描くタイプを選べます。
*/
package {
    import flash.ui.*;
    import fl.controls.*;
    import flash.text.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
    [SWF(frameRate = "50")]
    public class Sand extends Sprite {
        private const WIDTH:int = 465;
        private const HEIGHT:int = 465;
        private const BACK:uint = 0x000000;
        private const WALL:uint = 0x333333;
        private const SAND:uint = 0xff0000;
        private var draw:uint;
        private var prevMouseX:int;
        private var prevMouseY:int;
        private var world:BitmapData;
        private var bitmap:Bitmap;
        private var count:int;
        private var mousePressed:Boolean;
        private var sandBitmap:BitmapData;
        private var randX:uint;
        private var randY:uint;
        private var randZ:uint;
        private var t:uint;

        public function Sand() {
            initialize();
        }

        private function initialize():void {
            randX = 123456789;
            randY = 987654321;
            randZ = 193865735;
            var sand:ContextMenuItem = new ContextMenuItem("Sand");
            sand.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void {
                    draw = SAND;
                });
            var wall:ContextMenuItem = new ContextMenuItem("Wall");
            wall.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void {
                    draw = WALL;
                });
            var erase:ContextMenuItem = new ContextMenuItem("Erase");
            erase.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function():void {
                    draw = BACK;
                });
            sandBitmap = new BitmapData(2, 2);
            sandBitmap.setPixel(0, 0, 0x00ffff);
            sandBitmap.setPixel(1, 0, 0xffffff);
            sandBitmap.setPixel(0, 1, 0x0055ff);
            sandBitmap.setPixel(1, 1, 0x00ff55);
            contextMenu = new ContextMenu();
            contextMenu.hideBuiltInItems();
            contextMenu.customItems = [sand, wall, erase];
            draw = SAND;
            count = 0;
            world = new BitmapData(WIDTH, HEIGHT, false, BACK);
            world.draw(stage);
            bitmap = new Bitmap(world);
            addChild(bitmap);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,
                function():void {
                    mousePressed = true;
                });
            stage.addEventListener(MouseEvent.MOUSE_UP,
                function():void {
                    mousePressed = false;
                });
            addEventListener(Event.ENTER_FRAME, frame);
            stage.quality = StageQuality.LOW;
        }

        private function frame(e:Event):void {
            //TODO
            var s:Sprite = new Sprite();
            world.lock();
            if(mousePressed) {
                if(draw == SAND) {
                    s.graphics.beginBitmapFill(sandBitmap);
                    s.graphics.drawEllipse(mouseX - 3, mouseY - 3, 6, 6);
                    s.graphics.endFill();
                    s.graphics.lineStyle(6);
                    s.graphics.lineBitmapStyle(sandBitmap);
                    s.graphics.moveTo(prevMouseX, prevMouseY);
                    s.graphics.lineTo(mouseX, mouseY);
                    world.draw(s);
                } else {
                    s.graphics.beginFill(draw);
                    s.graphics.drawEllipse(mouseX - 3, mouseY - 3, 6, 6);
                    s.graphics.endFill();
                    s.graphics.lineStyle(6, draw);
                    s.graphics.moveTo(prevMouseX, prevMouseY);
                    s.graphics.lineTo(mouseX, mouseY);
                    world.draw(s);
                }
            }
            world.fillRect(new Rectangle(0, 0, WIDTH, 70), BACK);
            world.fillRect(new Rectangle(0, HEIGHT - 70, WIDTH, 70), BACK);
            world.fillRect(new Rectangle(0, 70, 70, HEIGHT - 140), BACK);
            world.fillRect(new Rectangle(WIDTH - 70, 70, 70, HEIGHT - 140), BACK);
            prevMouseX = mouseX;
            prevMouseY = mouseY;
            var i:int;
            var j:int;
            var pixel:uint;
            if(count % 2 == 0)
                for(j = HEIGHT - 71; j >= 70; j--) {
                    for(i = 70; i < WIDTH - 70; i++) {
                        pixel = world.getPixel(i, j);
                        if(pixel != BACK && pixel != WALL) {
                            t = randX ^ (randX << 11);
                            randX = randY;
                            randY = randZ;
                            if((randZ = (randZ ^ (randZ >> 19)) ^ (t ^ (t >> 8))) % 20 != 0)
                                if (world.getPixel(i, j + 1) == BACK) {
                                   world.setPixel(i, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i + 1, j + 1) == BACK) {
                                   world.setPixel(i + 1, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i - 1, j + 1) == BACK) {
                                   world.setPixel(i - 1, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i + 1, j) == BACK) {
                                   world.setPixel(i + 1, j, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i - 1, j) == BACK) {
                                   world.setPixel(i - 1, j, pixel);
                                   world.setPixel(i, j, BACK);
                                }
                        }
                    }
                }
            else
                for(j = HEIGHT - 71; j >= 70; j--) {
                    for(i = WIDTH - 71; i >= 70; i--) {
                        pixel = world.getPixel(i, j);
                        if(pixel != BACK && pixel != WALL) {
                            t = randX ^ (randX << 11);
                            randX = randY;
                            randY = randZ;
                            if((randZ = (randZ ^ (randZ >> 19)) ^ (t ^ (t >> 8))) % 20 != 0)
                                if (world.getPixel(i, j + 1) == BACK) {
                                   world.setPixel(i, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i - 1, j + 1) == BACK) {
                                   world.setPixel(i - 1, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i + 1, j + 1) == BACK) {
                                   world.setPixel(i + 1, j + 1, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i - 1, j) == BACK) {
                                   world.setPixel(i - 1, j, pixel);
                                   world.setPixel(i, j, BACK);
                                } else if (world.getPixel(i + 1, j) == BACK) {
                                   world.setPixel(i + 1, j, pixel);
                                   world.setPixel(i, j, BACK);
                                }
                        }
                    }
                }
            world.fillRect(new Rectangle(0, 0, WIDTH, 70), 0x808080);
            world.fillRect(new Rectangle(0, HEIGHT - 70, WIDTH, 70), 0x808080);
            world.fillRect(new Rectangle(0, 70, 70, HEIGHT - 140), 0x808080);
            world.fillRect(new Rectangle(WIDTH - 70, 70, 70, HEIGHT - 140), 0x808080);
            world.unlock();
            count = (count + 1) % 2;
        }
    }
}