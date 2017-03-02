
/*

Peak

Created in under 48 hours by John Nesky for Ludum Dare 14.  Requires Flash 10.

http://www.ludumdare.com/compo/tag/peak/

Compile with:
mxmlc -target-player=10.0.0 Peak.as

*/


package {
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.text.*;
  import flash.utils.*;
  
  [SWF(width=400, height=465, frameRate=15, backgroundColor=0x000000)]
  public class Peak extends Sprite {
    public static const STATIC_WIDTH: int = 200;
    public static const STATIC_HEIGHT: int = 200;
    public static const STATIC_EMPTY: int = -1;
    public static const STATIC_WATER: int = -2;
    public static const STATIC_SOURCE: int = 255;
    private const WIDTH: int = STATIC_WIDTH;
    private const HEIGHT: int = STATIC_HEIGHT;
    private const W_TIMES_H: int = WIDTH*HEIGHT;
    private const EMPTY: int = STATIC_EMPTY;
    private const WATER: int = STATIC_WATER;
    private const SOURCE: int = STATIC_SOURCE;
    private const SPECIES: int = 3;
    private const PLANT: int = 0;
    private const COORD_BURST: int = W_TIMES_H;
    private const HEAT_BURST: int = 1;
    private const LOOK_AHEAD: int = 7;
    private const SPAWN_COUNT: int = 10;
    private const GROW_TIME: int = 200;
    private const STARVE_TIME: int = 60;
    private const SPAWN_TIME: int = 3;
    private const UP: Point = new Point(0,-1);
    private const DOWN: Point = new Point(0,1);
    private const LEFT: Point = new Point(-1,0);
    private const RIGHT: Point = new Point(1,0);
    private const DIRECTIONS: Array = [UP, DOWN, LEFT, RIGHT];
    private const COLORS: Array = [
                                   0xff00ff00,
                                   0xffff0000,
                                   0xffffff00,
                                   0xff00ffff,
                                   0xffff00ff,
                                   0xff0000ff,
                                   0xffffffff,
                                   0xff999999,
                                   0xffcccccc,
                                   0xff666666,
                                   ];
    
    private var lifeMap: BitmapData = new BitmapData(WIDTH, HEIGHT, false , 0);
    //private var heatMap: BitmapData = new BitmapData(WIDTH, HEIGHT, false, 0);
    private var heightMap:BitmapData = new BitmapData(WIDTH,HEIGHT,false,0);
    private var tempMap:BitmapData = new BitmapData(WIDTH,HEIGHT,true,0);
    private var waterVec: Vector.<int> = new Vector.<int>(WIDTH * HEIGHT, true);
    public var lifeVec: Vector.<int>;
    public var allLife: Vector.<Life> = new Vector.<Life>(SPECIES, true);
    public var coords: Vector.<Point> = new Vector.<Point>(WIDTH * HEIGHT, true);
    private var frames: int;
    private var instructions: TextField;
    private var statusText: TextField;
    private var frameText: TextField;
    private var whiteFormat: TextFormat;
    private var redFormat: TextFormat;
    private var greenFormat: TextFormat;
    private var yellowFormat: TextFormat;
    
    public function Peak() {
      stage.align = StageAlign.BOTTOM;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      //generate(null)
      stage.addEventListener(MouseEvent.CLICK, generate);
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      stage.focus = stage;
      //onEnterFrame(null);
      
      /*var onScreenHeatMap: Bitmap = new Bitmap(heatMap);
      onScreenHeatMap.scaleX = 2;
      onScreenHeatMap.scaleY = 2;
      addChild(onScreenHeatMap);*/
      var screen: Bitmap = new Bitmap(lifeMap);
      screen.scaleX = 2;
      screen.scaleY = 2;
      //screen.x = stage.width / 2 - WIDTH;
      //screen.y = stage.height - HEIGHT * 2
      screen.y = 60;
      addChild(screen);
      
      
      whiteFormat = new TextFormat();
      whiteFormat.font="_sans";
      whiteFormat.align = TextFormatAlign.CENTER;
      whiteFormat.color = 0xffffffff;
      whiteFormat.size=12;
      
      redFormat = new TextFormat();
      redFormat.font="_sans";
      redFormat.align = TextFormatAlign.CENTER;
      redFormat.color = 0xffff0000;
      redFormat.size=12;
      
      greenFormat = new TextFormat();
      greenFormat.font="_sans";
      greenFormat.align = TextFormatAlign.CENTER;
      greenFormat.color = 0xff00ff00;
      greenFormat.size=12;
      
      yellowFormat = new TextFormat();
      yellowFormat.font="_sans";
      yellowFormat.align = TextFormatAlign.CENTER;
      yellowFormat.color = 0xffffff00;
      yellowFormat.size=12;
      
      instructions = new TextField();
      instructions.width = 0;
      instructions.x = stage.width / 2;
      instructions.y = 0;
      instructions.autoSize = TextFieldAutoSize.CENTER;
      
      addChild(instructions);
      drawInstructions("hunt.");
    }
    
    public function drawInstructions(yellowText: String): void {
      instructions.text = "";
      instructions.defaultTextFormat = whiteFormat;
      instructions.replaceSelectedText("You are a species of ");
      instructions.defaultTextFormat = redFormat;
      instructions.replaceSelectedText("red dots.");
      instructions.defaultTextFormat = whiteFormat;
      instructions.replaceSelectedText("\nPress 1 to ");
      instructions.defaultTextFormat = greenFormat;
      instructions.replaceSelectedText("harvest");
      instructions.defaultTextFormat = whiteFormat;
      instructions.replaceSelectedText(". Press 2 to ");
      instructions.defaultTextFormat = yellowFormat;
      instructions.replaceSelectedText(yellowText);
      instructions.defaultTextFormat = whiteFormat;
      instructions.replaceSelectedText(" Click to restart.");
    }
    
    public function generate(event: MouseEvent): void {
      var i: int;
      var j: int;
      var k: int;
      var palette: Array = new Array(256);
      var threshold: int;
      
      drawInstructions("hunt.");
      
      heightMap.perlinNoise(50,50,10,Math.random()*int.MAX_VALUE,true,true, 4, false);
      
      // solarize and copy into heightmap:
      threshold = 100;
      for (i = 0; i < 128; i++) {
        if (i < threshold) k = 0; else k = (i - threshold) * 255 / (127 - threshold);
        k = (k << 16) | (k << 8) | (k << 0);
      	palette[i] = k;
      	palette[255 - i] = k;
      }
      heightMap.paletteMap(heightMap, new Rectangle(0,0,WIDTH,HEIGHT), new Point(0,0), null, null, palette, null);
      
      // remove islands:
      var blackPalette: Array = new Array(256);
      for (i = 0; i < 256; i++) {
        blackPalette[i] = 0;
      }
      
      for (i = 0; i < 256; i++) {
        if (i == 0) palette[i] = 0; else palette[i] = 0xff;
      }
      tempMap.paletteMap(heightMap, new Rectangle(0,0,WIDTH,HEIGHT), new Point(0,0), blackPalette, blackPalette, palette, null);
      
      var color1: int = 0;
      var color2: int = 0;
      i = j = 0
      do {
      	i++;
      	if (i == heightMap.width) {
      	  i = 0;
      	  j++;
      	}
      	color1 = heightMap.getPixel(i,j);
      } while (color1 < (253 << 16))
      tempMap.floodFill(i,j,0xffffffff);
      
      for (i=0; i < heightMap.width; i++) {
        color1 = tempMap.getPixel(i,0);
        color2 = tempMap.getPixel(i,tempMap.height-1);
      	if (color1 == 0xff && color2 == 0xffffff) {
          tempMap.floodFill(i,0,0xffffffff);
      	} else if (color1 == 0xffffff && color2 == 0xff) {
          tempMap.floodFill(i,tempMap.height-1,0xffffffff);
      	}
      }
      for (i=0; i < heightMap.height; i++) {
        color1 = tempMap.getPixel(0,i);
        color2 = tempMap.getPixel(tempMap.width-1,i);
      	if (color1 == 0xff && color2 == 0xffffff) {
          tempMap.floodFill(0,i,0xffffffff);
      	} else if (color1 == 0xffffff && color2 == 0xff) {
          tempMap.floodFill(tempMap.width-1,i,0xffffffff);
      	}
      }
      
      
      palette[255] = 0x0;
      palette[0] = 0xff000066;
      
      tempMap.paletteMap(tempMap, new Rectangle(0,0,tempMap.width,tempMap.height), new Point(0,0), blackPalette, palette, blackPalette, blackPalette);
      
      //heightMap.copyPixels(tempMap, new Rectangle(0,0,tempMap.width,tempMap.height), new Point(0,0));
      lifeMap.fillRect(new Rectangle(0,0,WIDTH,HEIGHT), 0);
      lifeMap.copyPixels(tempMap, new Rectangle(0,0,tempMap.width,tempMap.height), new Point(0,0));
      
      for (j = 0; j < HEIGHT; j++) {
        for (i = 0; i < WIDTH; i++) {
          k = tempMap.getPixel32(i,j);
          if (k == 0) waterVec[i+j*WIDTH] = 0; else waterVec[i+j*WIDTH] = WATER;
        }
      }
      
      lifeVec = waterVec.concat();
      
      
      
      
      lifeMap.lock();
      
      for (j = 0; j < HEIGHT; j++) {
        for (i = 0; i < WIDTH; i++) {
          if (lifeVec[i + j*HEIGHT] == 0) lifeVec[i + j*HEIGHT] = EMPTY;
        }
      }
      
      allLife[PLANT] = new Life(PLANT, lifeVec, COLORS[PLANT], lifeMap, waterVec, GROW_TIME, 0);
      for (i = PLANT+1; i < SPECIES; i++) {
        allLife[i] = new Life(i, lifeVec, COLORS[i], lifeMap, waterVec, SPAWN_TIME, STARVE_TIME);
      }
      for (i = PLANT+1; i < SPECIES; i++) {
        //allLife[i].target = (i == SPECIES-1) ? allLife[0] : allLife[i+1];
        allLife[i].target = allLife[PLANT];
        
        while (allLife[i].count < SPAWN_COUNT) {
          allLife[i].spawn(Math.random()*WIDTH/3 + WIDTH/3, Math.random()*HEIGHT/3 + i*HEIGHT/3);
        }
      }
      
      while (allLife[PLANT].count < 1000) {
        allLife[PLANT].spawn(Math.random()*WIDTH, Math.random()*HEIGHT);
      }
      
      lifeMap.unlock();
      
      // generate all coords
      k = 0;
      for (j = 0; j < HEIGHT; j++) {
        for (i = 0; i < WIDTH; i++) {
          coords[k] = new Point(i,j);
          k++;
        }
      }
      // random sort coords
      var localRandom: Function = Math.random;
      for (i = 0; i < W_TIMES_H; i++) {
        j = localRandom() * W_TIMES_H;
        var temp: Point = coords[i];
        coords[i] = coords[j];
        coords[j] = temp;
      }
      
      if (frameText != null) removeChild(frameText);
      if (statusText != null) removeChild(statusText);
      
      frameText = new TextField();
      frameText.width = 0;
      frameText.x = stage.width / 2;
      frameText.y = 42;
      frameText.autoSize = TextFieldAutoSize.CENTER;
      frameText.defaultTextFormat = whiteFormat;
      addChild(frameText);
      
      statusText = new TextField();
      statusText.width = 0;
      statusText.x = stage.width / 2;
      statusText.y = 28;
      statusText.autoSize = TextFieldAutoSize.CENTER;
      addChild(statusText);
      
      setStatusText();
      
      frames = 0;
      yellowAlive = true;
    }
    
    private function setStatusText(): void {
      statusText.text = "";
      if (allLife[1].count <= 0) return;
      if (allLife[1].target == allLife[0]) {
        statusText.defaultTextFormat = greenFormat;
        statusText.replaceSelectedText("You are harvesting.");
      } else {
        statusText.defaultTextFormat = yellowFormat;
        if (allLife[2].count > 0) {
          statusText.replaceSelectedText("You are hunting.");
        } else {
          statusText.replaceSelectedText("You are wandering?");
        }
      }
    }
    
    private function wrapX(val: int): int {
      if (val < 0) val += WIDTH;
      else if (val >= WIDTH) val -= WIDTH;
      return val;
    }
    
    private function wrapY(val: int): int {
      if (val < 0) val += HEIGHT;
      else if (val >= HEIGHT) val -= HEIGHT;
      return val;
    }
    
    private function onKeyDown(event: KeyboardEvent): void {
      if (event.charCode == '1'.charCodeAt(0)) {
        allLife[1].target = allLife[0];
      } else if (event.charCode == '2'.charCodeAt(0)) {
        allLife[1].target = allLife[2];
      }
      setStatusText();
    }
    
    private var coordIndex: int = 0;
    private var yellowAlive: Boolean;
    private function onEnterFrame(event: Event): void {
      var i: int;
      var j: int;
      
      if (frameText == null) return;
      
      lifeMap.lock();
      
      for (i = 0; i < SPECIES; i++) {
      	for (j = 0; j < HEAT_BURST; j++) {
	        if (allLife[i].count > 0 && i != 1) allLife[i].updateHeat();
      	}
      }
      
      if (allLife[1].count > 0) {
        frames++;
        frameText.text = "You have been around for " + frames + " years";
      } else {
      	frameText.text = "You are extinct after " + frames + " years";
        setStatusText();
      }
      
      if (yellowAlive && allLife[2].count <= 0) {
      	yellowAlive = false;
      	drawInstructions("wander?");
        setStatusText();
      }
      
      var dest: Point = new Point();
      var dir: Point;
      
      for (i = 0; i < COORD_BURST; i++) {
        var coord: Point = coords[coordIndex];
        coordIndex++;
        if (coordIndex == W_TIMES_H) coordIndex = 0;
        
        var id: int = lifeVec[coord.x + coord.y * WIDTH];
        if (id > EMPTY) {
          var species: Life = allLife[id];
          if (id == PLANT) {
            species.spawnTimer--;
            if (species.spawnTimer <= 0) {
              dir = DIRECTIONS[int(Math.random() * DIRECTIONS.length)];
              dest.x = wrapX(coord.x + dir.x);
              dest.y = wrapY(coord.y + dir.y);
              if (lifeVec[dest.x + dest.y * WIDTH] == EMPTY) {
                species.spawn(dest.x, dest.y);
                species.spawnTimer = species.maxSpawnTime;
              }
            }
          } else {
            
            species.starveTimer--;
            if (species.starveTimer <= 0) {
              species.kill(coord.x, coord.y);
              species.starveTimer = species.maxStarveTime;
              continue;
            }
            
            if (species.id == 2 && Math.random() > 0.85) continue;
            
            if (species.target.count > 0) {
              var heat: Vector.<int> = species.target.heat;
              var chosenDirs: Array = [];
              var viableDirs: Array;
              dest.x = coord.x;
              dest.y = coord.y;
              
              for (j = 0; j < LOOK_AHEAD; j++) {
                var minHeat: int = int.MIN_VALUE;
                for each (dir in DIRECTIONS) {
                  var newHeat: int = heat[(wrapX(coord.x + dir.x)) + (wrapY(coord.y + dir.y)) * WIDTH];
                  if (newHeat > minHeat) {
                    minHeat = newHeat;
                    viableDirs = [dir];
                  } else if (newHeat == minHeat) {
                    viableDirs[viableDirs.length] = dir;
                  }
                }
                
                dir = viableDirs[int(Math.random() * viableDirs.length)];
                chosenDirs[chosenDirs.length] = dir;
                dest.x = wrapX(dest.x + dir.x);
                dest.y = wrapY(dest.y + dir.y);
                if (heat[dest.x + dest.y * WIDTH] == SOURCE) break;
              }
              
              dir = chosenDirs[int(Math.random() * chosenDirs.length)];
            } else {
              dir = DIRECTIONS[int(Math.random() * DIRECTIONS.length)];
            }
            
            dest.x = wrapX(coord.x + dir.x);
            dest.y = wrapY(coord.y + dir.y);
            id = lifeVec[(dest.x) + (dest.y) * WIDTH];
            if (id == EMPTY) {
              species.spawn(dest.x, dest.y);
              species.kill(coord.x, coord.y);
            } else if (id == WATER) {
              // do nothing?
            } else if (id == species.target.id || id == PLANT) {
              var target: Life = allLife[id];
              target.kill(dest.x, dest.y);
              species.spawn(dest.x, dest.y);
              
              species.spawnTimer--;
              if (species.spawnTimer <= 0) {
                species.spawnTimer = species.maxSpawnTime;
              } else {
                species.kill(coord.x, coord.y);
              }
            }
          }
        }
      }
      
      lifeMap.unlock();
      /*
      var bytes: ByteArray = new ByteArray();
      var asdf: Vector.<int> = allLife[0].heat;
      for (i = 0; i < W_TIMES_H; i++) {
      	bytes.writeInt(asdf[i]);
      }
      bytes.position = 0;
      heatMap.setPixels(new Rectangle(0,0,WIDTH, HEIGHT), bytes);
      */
    }
  }
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;
import flash.utils.*;

class Life {
  private static var _flip: Vector.<int> = new Vector.<int>(Peak.STATIC_WIDTH * Peak.STATIC_HEIGHT, true);
  
  private const WIDTH: int = Peak.STATIC_WIDTH;
  private const HEIGHT: int = Peak.STATIC_HEIGHT;
  private const EMPTY: int = Peak.STATIC_EMPTY;
  private const WATER: int = Peak.STATIC_WATER;
  private const SOURCE: int = Peak.STATIC_SOURCE;
  
  public var count: int = 0;
  public var color: uint;
  public var id: int;
  public var target: Life = null;
  public var heat: Vector.<int>;
  public var spawnTimer: int;
  public var starveTimer: int;
  public var maxSpawnTime: int;
  public var maxStarveTime: int;
  private var lifeMap: BitmapData;
  private var lifeVec: Vector.<int>;
  private var waterVec: Vector.<int>;
  
  public function Life(id: int, lifeVec: Vector.<int>, color: uint, lifeMap: BitmapData, waterVec: Vector.<int>, maxSpawnTime: int, maxStarveTime: int) {
    this.id = id;
    this.lifeVec = lifeVec;
    this.color = color;
    this.lifeMap = lifeMap;
    this.heat = waterVec.concat();
    this.spawnTimer = this.maxSpawnTime = maxSpawnTime;
    this.starveTimer = this.maxStarveTime = maxStarveTime;
  }
  
  public function spawn(x: int, y: int): void {
    var dest: int = x + y*WIDTH;
    if (lifeVec[dest] != EMPTY) return;
    heat[dest] = SOURCE;
    lifeVec[dest] = id;
    lifeMap.setPixel32(x,y,color);
    count++;
  }
  
  public function kill(x: int, y: int): void {
    var dest: int = x + y*WIDTH;
    heat[dest] = SOURCE-1;
    lifeVec[dest] = EMPTY;
    lifeMap.setPixel32(x,y,0);
    count--;
  }
  
  public function updateHeat(): void {
    var i: int;
    var j: int;
    var k: int;
    
    var sample: int = heat[0 + (HEIGHT-1) * WIDTH];
    var prevSample: int;
    
    var localRandom: Function = Math.random;
    
    if (localRandom() > 0.5) {
      for (j = 0; j < HEIGHT; j++) {
        k = j * WIDTH;
        if (localRandom() > 0.5) {
          for (i = 0; i < WIDTH; i++) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
          j++;
          k = j * WIDTH;
          for (i = WIDTH-1; i >= 0; i--) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
        } else {
          for (i = WIDTH-1; i >= 0; i--) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
          j++;
          k = j * WIDTH;
          for (i = 0; i < WIDTH; i++) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
        }
      }
      
      for (i = 0; i < WIDTH; i++) {
        if (localRandom() > 0.5) {
          for (j = 0; j < HEIGHT; j++) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
          i++;
          for (j = HEIGHT-1; j >= 0; j--) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
        } else {
          for (j = HEIGHT-1; j >= 0; j--) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
          i++;
          for (j = 0; j < HEIGHT; j++) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
        }
      }
    } else {
      for (i = 0; i < WIDTH; i++) {
        if (localRandom() > 0.5) {
          for (j = 0; j < HEIGHT; j++) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
          i++;
          for (j = HEIGHT-1; j >= 0; j--) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
        } else {
          for (j = HEIGHT-1; j >= 0; j--) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
          i++;
          for (j = 0; j < HEIGHT; j++) {
            prevSample = sample;
            k = i + j * WIDTH;
            sample = heat[k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[k] = sample;
          }
        }
      }
      
      for (j = 0; j < HEIGHT; j++) {
        k = j * WIDTH;
        if (localRandom() > 0.5) {
          for (i = 0; i < WIDTH; i++) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
          j++;
          k = j * WIDTH;
          for (i = WIDTH-1; i >= 0; i--) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
        } else {
          for (i = WIDTH-1; i >= 0; i--) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
          j++;
          k = j * WIDTH;
          for (i = 0; i < WIDTH; i++) {
            prevSample = sample;
            sample = heat[i + k];
            if (sample == SOURCE || sample == WATER) continue;
            if (prevSample > sample) sample = prevSample - 1; else sample-=4;
            if (sample < 0) sample = 0;
            heat[i + k] = sample;
          }
        }
      }
    }
  }
}

