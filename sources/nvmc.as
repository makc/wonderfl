/* ------------------------------------------------------
 * Ver.0.7214545
 * ------------------------------------------------------
 * [HotKey]
 * 1-7   : select a tower to build
 * 0,ESC : cancel a selection
 * U     : upgrade the selected tower
 * S     : sell the selected tower
 * M     : show menu window
 * N     : send the next wave
 * ------------------------------------------------------
 * [inspired by]
 * Desktop Tower Defense
 * http://www.handdrawngames.com/DesktopTD/game.asp
 * ------------------------------------------------------
 * [適当な取説]
 * ・ルールとか遊び方とかよくワカランという方は以下を参照。
 * Tower Defense Wiki - TD系とは
 * http://www32.atwiki.jp/tower_d/pages/32.html
 * 
 * [タワーの特徴]
 * Arrow   : 弱いが安価。しかしレベルを上げると…
 * Gatling : 攻撃速度が速く、安定した強さを誇る。
 * Bomb    : 範囲攻撃できる。空中に攻撃できない。
 * Missile : 強力な対空兵器。地上に攻撃できない。
 * Frost   : 威力は無いが、敵を一定時間スローにする。
 * Vortex  : 地上のみで範囲も狭いが、高威力全体攻撃。
 * Laser   : 高価だが、弾が貫通する！
 * 
 * [敵の特徴]
 * Normal  : 数だけの雑魚。
 * Immune  : スロー効果を受けない。
 * Fast    : 移動が速いぞ。
 * Flying  : 一直線に向かってくる、要注意！
 * ------------------------------------------------------
 * [更新]
 * ・敵を倒した時、皆さんの大好きなお金がピョッと飛び出るエフェクトを追加 (Ver.0.7214545)
 * ・Wave数を50に、バランスを調整、弾の画像追加 (Ver.0.721454)
 * ・範囲攻撃が範囲内の敵全てに当たっていなかったバグを修正 (Ver.0.72145)
 * ・簡単な操作説明を追加 (Ver.0.7214)
 * ・とりあえずランキング設置 (Ver.0.721)
 * ・最低限遊べるバランスに修正 (Ver.0.72)
 * ・公開 (Ver.0.7)
 */

/* ---------------------------------------------------------------------------------------------------------
 * Main
 * ---------------------------------------------------------------------------------------------------------
 */
package {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    
    public class Main extends Sprite {
        // 各状態を表す定数
        public static const STATE_READY:int = 0;
        public static const STATE_PLAYING:int = 1;
        public static const STATE_MENU:int = 2;
        public static const STATE_GAMEOVER:int = 3;
        
        private var _states:Vector.<IState>;    // 状態のコレクション
        private var _currentState:IState;        // 現在の状態の参照
        private var _previousState:IState;        // 一つ前の状態の参照
        
        private var _world:World;                // フィールド・タワー・敵等を表示する画面
        private var _frontend:Frontend;            // ステータス・メニュー等を表示するウインドウ
        private var _waveManager:WaveManager;    // Waveを管理・表示するウインドウ
        private var _nextWaveButtonHandler:Function;
        
        public function get world():World { return _world; }
        public function get waveManager():WaveManager { return _waveManager; }
        
        public function Main() {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            // 外部アセットを読み込んだ後に初期化を開始する
            var imagePaths:Dictionary = ImageFactory.getExternalImagePaths();
            var imageHolder:Dictionary = ImageFactory.load();
            var preloader:Preloader = new Preloader(this, imagePaths, imageHolder);
            preloader.addEventListener(Event.COMPLETE, initialize);
        }
        
        // 全体の初期化
        private function initialize(e:Event):void {
            e.target.removeEventListener(Event.COMPLETE, initialize);
            HotKey.setStage(this.stage);
            EnemyType.initialize();
            
            // 各状態の初期化
            _states = new Vector.<IState>();
            _states[Main.STATE_READY] = new ReadyState(this);
            _states[Main.STATE_PLAYING] = new PlayingState(this);
            _states[Main.STATE_MENU] = new MenuState(this);
            _states[Main.STATE_GAMEOVER] = new GameoverState(this);
            
            // 画面の初期化
            addChild(_world = new World( -9, 12));
            addChild(_frontend = new Frontend(0, 0));
            _frontend.addChild(_waveManager = new WaveManager(0, 415, _world));
            
            // 各ボタンの初期化と、対応するホットキーを設定する
            var window:Sprite = _frontend.addChild(ImageFactory.createWindow(365, 415, 100, 50)) as Sprite;
            var menuButton:PushButton = new PushButton(window, 5, 4, "Menu (M)", onClickMenuButton);
            var nextWaveButton:PushButton = new PushButton(window, 5, 26, "Next Wave (N)", onClickNextWaveButton);
            menuButton.width = nextWaveButton.width = 90;
            
            HotKey.bind(Keyboard.M, onClickMenuButton);
            HotKey.bind(Keyboard.N, onClickNextWaveButton);
            
            // 初期状態の設定
            _currentState = _states[Main.STATE_GAMEOVER];
            _currentState.enter();
            
            addEventListener(Event.ENTER_FRAME, mainLoop);
        }
        private function onClickMenuButton(e:MouseEvent = null):void { changeState(Main.STATE_MENU); }
        private function onClickNextWaveButton(e:MouseEvent = null):void { _nextWaveButtonHandler(); }
        private function mainLoop(e:Event):void { _currentState.update(); }
        
        // NextWaveボタンを押した時の処理を設定する
        public function setNextWaveButtonHandler(handler:Function = null):void {
            _nextWaveButtonHandler = (handler != null) ? handler : doNothing;
        }
        private function doNothing():void { }
        
        // ゲームの状態を変更する
        public function changeState(stateType:int):void {
            _previousState = _currentState;
            
            _currentState.exit();
            _currentState = _states[stateType];
            _currentState.enter();
        }
        
        // ゲームの状態を一つ前の状態に戻す
        public function revertToPreviousState():void {
            _currentState.exit();
            _currentState = _previousState;
            _currentState.enter();
        }
    }
}
/* ----------------------------------------------------------------------------------------------------------------------
 * IState
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    interface IState {
        function enter():void;
        function update():void;
        function exit():void;
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * GameoverState
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import net.wonderfl.score.basic.BasicScoreForm;
    import net.wonderfl.score.basic.BasicScoreRecordViewer;
    
    //public 
    class GameoverState implements IState {
        private var _main:Main;
        private var _gameoverScreen:Sprite;
        private var _instructionWindow:Sprite;
        private var _isBeginning:Boolean;
        
        private var _scoreForm:BasicScoreForm;
        private var _ranking:BasicScoreRecordViewer;
        
        public function GameoverState(main:Main) {
            _main = main;
            _gameoverScreen = createGameoverScreen();
            _instructionWindow = createInstructionWindow();
            _isBeginning = true;
        }
        
        private function createGameoverScreen():Sprite {
            var screen:Sprite = new Sprite();
            screen.graphics.beginFill(0x000000, 0.5);
            screen.graphics.drawRect(0, 0, 465, 465);
            screen.graphics.endFill();
            new PushButton(screen, 182, 182, "Start Game", onClickStartButton);
            return screen;
        }
        private function onClickStartButton(e:MouseEvent):void { _main.changeState(Main.STATE_READY); }
        
        private function createInstructionWindow():Sprite {
            var container:Sprite = new Sprite();
            
            var window1:Sprite = container.addChild(ImageFactory.createWindow(180, 60, 190, 70)) as Sprite;
            window1.addChild(ImageFactory.createInstructionText(5, 7, 190, 24, "Select a tower to build\nby clicking right button.", 12));
            window1.addChild(ImageFactory.createInstructionText(5, 39, 190, 24, "設置したいタワーを、\n右のボタンから選択できます。", 12));
            
            var window2:Sprite = container.addChild(ImageFactory.createWindow(30, 220, 190, 70)) as Sprite;
            window2.addChild(ImageFactory.createInstructionText(5, 7, 190, 24, "Click on the map\nto build the selected tower.", 12));
            window2.addChild(ImageFactory.createInstructionText(5, 39, 190, 24, "マップをクリックすると、\n選択したタワーを設置できます。", 12));
            
            var window3:Sprite = container.addChild(ImageFactory.createWindow(240, 270, 190, 70)) as Sprite;
            window3.addChild(ImageFactory.createInstructionText(5, 7, 190, 24, "Click on a tower on the map\nto upgrade or sell it.", 12));
            window3.addChild(ImageFactory.createInstructionText(5, 39, 190, 24, "マップ上のタワーをクリックすると、\nレベルアップや売却を行えます。", 12));
            
            var window4:Sprite = container.addChild(ImageFactory.createWindow(170, 380, 190, 70)) as Sprite;
            window4.addChild(ImageFactory.createInstructionText(5, 7, 190, 24, "Press \"Next Wave\" button\nto send the next wave.", 12));
            window4.addChild(ImageFactory.createInstructionText(5, 39, 190, 24, "「Next Wave」ボタンを押すと、\nゲームを進めることができます。", 12));
            
            return container;
        }
        
        public function enter():void {
            _main.addChild(_gameoverScreen);
            
            if (_isBeginning) {
                _main.addChild(_instructionWindow);
            }else {
                if (_scoreForm != null) { _gameoverScreen.removeChild(_scoreForm); }
                _scoreForm = new BasicScoreForm(_gameoverScreen, 92, 10, GameData.instance.score, "Score", showRanking);
                showRanking(false);
            }
        }
        private function showRanking(b:Boolean):void {
            if (_ranking != null) { _gameoverScreen.removeChild(_ranking); }
            _ranking = new BasicScoreRecordViewer(_gameoverScreen, 122, 215, "Ranking", 99, true, null);
        }
        
        public function update():void { }
        
        public function exit():void {
            if (_isBeginning) {
                _main.removeChild(_instructionWindow);
                _instructionWindow = null;
            }
            _isBeginning = false;
            _main.removeChild(_gameoverScreen);
            
            _main.world.clear();
            _main.waveManager.initialize();
            GameData.instance.initialize();
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * ReadyState
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class ReadyState implements IState {
        private var _main:Main;
        
        public function ReadyState(main:Main) {
            _main = main;
        }
        
        public function enter():void {
            _main.setNextWaveButtonHandler(startPlaying);
            HotKey.enable();
        }
        private function startPlaying():void { _main.changeState(Main.STATE_PLAYING); }
        
        public function update():void {
            _main.world.update();
        }
        
        public function exit():void {
            HotKey.disable();
            _main.setNextWaveButtonHandler(_main.waveManager.sendNextWave);
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * PlayingState
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class PlayingState implements IState {
        private var _main:Main;
        
        public function PlayingState(main:Main) {
            _main = main;
        }
        
        public function enter():void {
            GameData.instance.sellingRatio = 0.8;
            HotKey.enable();
        }
        
        public function update():void {
            _main.world.update();
            _main.waveManager.update();
            
            // ライフが0になるか、全ての敵を倒したら、ゲームオーバー
            if ((GameData.instance.lives <= 0) || (_main.world.numEnemies() == 0 && _main.waveManager.finished())) {
                _main.changeState(Main.STATE_GAMEOVER);
            }
        }
        
        public function exit():void {
            HotKey.disable();
            GameData.instance.sellingRatio = 1;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * MenuState
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    //public 
    class MenuState implements IState {
        private var _main:Main;
        private var _menuScreen:Sprite;
        
        public function MenuState(main:Main) {
            _main = main;
            _menuScreen = createMenuScreen();
        }
        
        private function createMenuScreen():Sprite {
            var screen:Sprite = new Sprite();
            screen.graphics.beginFill(0x000000, 0.5);
            screen.graphics.drawRect(0, 0, 465, 465);
            screen.graphics.endFill();
            
            var window:Sprite = screen.addChild(ImageFactory.createWindow(122, 172, 120, 95)) as Sprite;
            window.addChild(ImageFactory.createWindow(0, 0, 120, 25));
            window.addChild(ImageFactory.createSimpleText(0, 0, 120, 25, "Menu", 12, 0xffffff));
            new PushButton(window, 10, 35, "Resume", onClickResumeButton);
            new PushButton(window, 10, 65, "Give up", onClickGiveUpButton);
            return screen;
        }
        private function onClickResumeButton(e:MouseEvent):void { _main.revertToPreviousState(); }
        private function onClickGiveUpButton(e:MouseEvent):void { _main.changeState(Main.STATE_GAMEOVER); }
        
        public function enter():void { _main.addChild(_menuScreen); }
        
        public function update():void { }
        
        public function exit():void { _main.removeChild(_menuScreen); }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * World
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    //public 
    class World extends Sprite {
        private var _nodes:Vector.<Vector.<Node>>;
        private var _starts:Vector.<Start>;
        private var _goals:Vector.<Goal>;
        
        private var _towers:Vector.<Tower>;
        private var _bullets:Vector.<Bullet>;
        private var _groundEnemies:Vector.<Enemy>;
        private var _flyingEnemies:Vector.<Enemy>;
        
        private var _towerLayer:Sprite;
        private var _enemyLayer:Sprite;
        private var _bulletLayer:Sprite;
        private var _effectLayer:Sprite;
        private var _cursor:Cursor;
        
        public function getNode(col:int, row:int):Node { return _nodes[row][col]; }
        public function getStartingPos(startIndex:int):TileBasedPoint {
            return _starts[startIndex].getRandomSpawningPosition();
        }
        public function numEnemies():int { return _groundEnemies.length + _flyingEnemies.length; }
        
        public function World(posx:int, posy:int) {
            x = posx;
            y = posy;
            
            initializeNodes();
            initializeStarts();
            initializeGoals();
            
            _towers = new Vector.<Tower>();
            _bullets = new Vector.<Bullet>();
            _groundEnemies = new Vector.<Enemy>();
            _flyingEnemies = new Vector.<Enemy>();
            
            addChild(new Bitmap(ImageFactory.getImage("World")));
            addChild(_towerLayer = new Sprite());
            addChild(_enemyLayer = new Sprite());
            addChild(_bulletLayer = new Sprite());
            addChild(_effectLayer = new Sprite());
            addChild(_cursor = new Cursor(this));
            _enemyLayer.mouseChildren = _bulletLayer.mouseChildren = false;
            _enemyLayer.mouseEnabled = _bulletLayer.mouseEnabled = false;
            
            addEventListener(MouseEvent.CLICK, addTower);
        }
        
        private function initializeNodes():void {
            _nodes = new Vector.<Vector.<Node>>();
            for (var row:int = 0; row < Const.NODE_ROWS; row++) {
                _nodes[row] = new Vector.<Node>();
                for (var col:int = 0; col < Const.NODE_COLS; col++) {
                    _nodes[row][col] = new Node(col, row, Config.NODE_TYPE[row][col]);
                }
            }
        }
        
        private function initializeStarts():void {
            _starts = Config.getStarts();
        }
        
        private function initializeGoals():void {
            _goals = Config.getGoals();
            for (var i:int = 0; i < _goals.length; i++) {
                var goal:Goal = _goals[i];
                goal.setNode(_nodes[goal.tileY][goal.tileX]);
                goal.search(this);
            }
        }
        
        public function update():void {
            var i:int;
            
            for (i = 0; i < _towers.length; i++) {
                _towers[i].update();
            }
            
            for (i = 0; i < _groundEnemies.length; i++) {
                var groundEnemy:Enemy = _groundEnemies[i];
                _nodes[groundEnemy.tileY][groundEnemy.tileX].numEnemy--;
                _groundEnemies[i].update(this);
                _nodes[groundEnemy.tileY][groundEnemy.tileX].numEnemy++;
            }
            
            for (i = 0; i < _flyingEnemies.length; i++) {
                _flyingEnemies[i].update(this);
            }
            
            for (i = 0; i < _bullets.length; i++) {
                _bullets[i].update();
            }
            
            _cursor.update(mouseX - Const.CURSOR_OFFSET, mouseY - Const.CURSOR_OFFSET);
        }
        
        // すべてのタワー・弾・敵を消去する
        public function clear():void {
            var i:int;
            for (i = _towers.length - 1; i >= 0; i--) { removeTower(_towers[i], true); }
            for (i = 0; i < _goals.length; i++) { _goals[i].search(this); }
            for (i = _groundEnemies.length - 1; i >= 0; i--) { removeEnemy(_groundEnemies[i]); }
            for (i = _flyingEnemies.length - 1; i >= 0; i--) { removeEnemy(_flyingEnemies[i]); }
            for (i = _bullets.length - 1; i >= 0; i--) { removeBullet(_bullets[i]); }
        }
        
        // タワーを（設置できるなら）設置する
        private function addTower(e:MouseEvent):void {
            var position:TileBasedPoint = TileBasedPoint.createFromWorldPos(mouseX - Const.CURSOR_OFFSET, mouseY - Const.CURSOR_OFFSET);
            position.setTilePos(position.tileX, position.tileY);
            
            if (canBuildTower(position.tileX, position.tileY)) {
                var i:int, j:int;
                var tower:Tower = new Tower(position.x, position.y, GameData.instance.selectedTower.type, this);
                
                // タワーが設置される場所を通行不能にする
                for (var row:int = 0; row < 2; row++) {
                    for (var col:int = 0; col < 2; col++) {
                        var node:Node = _nodes[position.tileY + row][position.tileX + col];
                        node.passable = node.buildable = false;
                    }
                }
                
                // 全ての経路の最探索
                for (i = 0; i < _goals.length; i++) {
                    _goals[i].search(this);
                }
                
                // 全てのスタート、全ての敵（地上）、のゴールを更新
                // ブロッキングが発生していたら中断
                var nearestGoal:Goal;
                var blocking:Boolean = false;
                for (i = 0; !blocking && (i < _starts.length); i++) {
                    var start:Start = _starts[i];
                    if (start.forFlying) { continue; }
                    nearestGoal = getNearestGoalFrom(start.posX, start.posY, false);
                    if (!nearestGoal.hasPath(start.tileX,start.tileY)) { blocking = true; }
                }
                for (i = 0; !blocking && (i < _groundEnemies.length); i++) {
                    var enemy:Enemy = _groundEnemies[i];
                    nearestGoal = getNearestGoalFrom(enemy.posX, enemy.posY, false);
                    enemy.setGoal(nearestGoal);
                    if (!enemy.hasPathToGoal()) { blocking = true; }
                }
                
                // ブロッキングが発生していたら、
                // 全ての変更を元に戻してタワー設置失敗で終了
                // そうでなければ、実際にタワーを設置する
                if (blocking) {
                    // 通行不能にした場所を元に戻す
                    for (row = 0; row < 2; row++) {
                        for (col = 0; col < 2; col++) {
                            node = _nodes[position.tileY + row][position.tileX + col];
                            node.passable = node.buildable = true;
                        }
                    }
                    // 全ての経路を元に戻す
                    for (i = 0; i < _goals.length; i++) {
                        _goals[i].revertToPrevious();
                    }
                    // 全ての敵（地上）のゴールを更新
                    for (i = 0; i < _groundEnemies.length; i++) {
                        _groundEnemies[i].setGoal(getNearestGoalFrom(_groundEnemies[i].posX, _groundEnemies[i].posY, false));
                    }
                }else {
                    _towers.push(tower);
                    _towerLayer.addChild(tower);
                    
                    GameData.instance.gold -= tower.type.getStatus(tower.level).cost;
                }
            }
        }
        
        public function canBuildTower(tilex:int, tiley:int):Boolean {
            var selectedTower:Tower = GameData.instance.selectedTower;
            // タワー選択ボタンを選択中か、十分な所持金があるか調べる
            if (selectedTower == null || selectedTower.active || (GameData.instance.gold < selectedTower.type.getStatus(selectedTower.level).cost)) { return false; }
            
            // 引数で指定した場所にタワーが建てられるか調べる
            for (var row:int = 0; row < 2; row++) {
                for (var col:int = 0; col < 2; col++) {
                    var node:Node = _nodes[tiley + row][tilex + col];
                    if (!node.buildable || (node.numEnemy > 0)) { return false; }
                }
            }
            
            return true;
        }
        
        // タワーのターゲットを探してそれを返す（いなければnullを返す）
        public function findTarget(posx:Number, posy:Number, range:int, ground:Boolean, air:Boolean):Enemy {
            var i:int, enemy:Enemy, diffX:Number, diffY:Number;
            var rangeSq:int = range * range;
            
            // 地上に攻撃できるなら、地上の敵のターゲットを探す
            if (ground) {
                for (i = 0; i < _groundEnemies.length; i++) {
                    enemy = _groundEnemies[i];
                    diffX = posx - enemy.posX;
                    diffY = posy - enemy.posY;
                    if (diffX * diffX + diffY * diffY < rangeSq) {
                        return enemy;
                    }
                }
            }
            
            // 空中に攻撃できるなら、飛んでいる敵のターゲットを探す
            if (air) {
                for (i = 0; i < _flyingEnemies.length; i++) {
                    enemy = _flyingEnemies[i];
                    diffX = posx - enemy.posX;
                    diffY = posy - enemy.posY;
                    if (diffX * diffX + diffY * diffY < rangeSq) {
                        return enemy;
                    }
                }
            }
            
            // ターゲットが見つからなければnull
            return null;
        }
        
        // 引数で指定した位置から最も近いゴールを返す
        private function getNearestGoalFrom(posx:Number, posy:Number, flying:Boolean):Goal {
            var nearest:Goal = _goals[0];
            for (var i:int = 1; i < _goals.length; i++) {
                if (_goals[i].getCost(posx, posy, flying) < nearest.getCost(posx, posy, flying)) {
                    nearest = _goals[i];
                }
            }
            return nearest;
        }
        
        // タワーを消去する
        public function removeTower(tower:Tower, clear:Boolean = false):void {
            var position:TileBasedPoint = TileBasedPoint.createFromWorldPos(tower.x, tower.y);
            for (var row:int = 0; row < 2; row++) {
                for (var col:int = 0; col < 2; col++) {
                    var node:Node = _nodes[position.tileY + row][position.tileX + col];
                    node.passable = node.buildable = true;
                }
            }
            
            // ブロッキングを考慮せずに
            // 全ての経路の最探索と、全ての敵（地上）のゴールを更新
            // clear()時は最探索する必要
            if (!clear) {
                var i:int;
                for (i = 0; i < _goals.length; i++) {
                    _goals[i].search(this);
                }
                for (i = 0; i < _groundEnemies.length; i++) {
                    _groundEnemies[i].setGoal(getNearestGoalFrom(_groundEnemies[i].posX, _groundEnemies[i].posY, false));
                }
            }
            
            _towerLayer.removeChild(tower);
            _towers.splice(_towers.indexOf(tower), 1);
        }
        
        // 弾を出現させる
        public function addBullet(bullet:Bullet):void {
            _bullets.push(bullet);
            _bulletLayer.addChild(bullet);
        }
        
        // 弾を消去する
        public function removeBullet(bullet:Bullet):void {
            _bulletLayer.removeChild(bullet);
            _bullets.splice(_bullets.indexOf(bullet), 1);
        }
        
        // 敵を出現させる
        public function addEnemy(enemy:Enemy):void {
            enemy.setGoal(getNearestGoalFrom(enemy.posX, enemy.posY, enemy.type.flying));
            
            if (enemy.type.flying) {
                _flyingEnemies.push(enemy);
            }else {
                _groundEnemies.push(enemy);
                _nodes[enemy.tileY][enemy.tileX].numEnemy++;
            }
            _enemyLayer.addChild(enemy);
        }
        
        // 敵を消去する
        public function removeEnemy(enemy:Enemy):void {
            _enemyLayer.removeChild(enemy);
            if (enemy.type.flying) {
                _flyingEnemies.splice(_flyingEnemies.indexOf(enemy), 1);
            }else {
                _nodes[enemy.tileY][enemy.tileX].numEnemy--;
                _groundEnemies.splice(_groundEnemies.indexOf(enemy), 1);
            }
        }
        
        // エフェクトを発生させる
        public function addEffect(effect:Sprite):void {
            _effectLayer.addChild(effect);
        }
        
        public function damageSurroundingEnemies(bullet:Bullet):void {
            var i:int, enemy:Enemy;
            if (bullet.ground) {
                for (i = _groundEnemies.length - 1; i >= 0; i--) {
                    enemy = _groundEnemies[i];
                    if (bullet.isHitTarget(enemy, bullet.splashRadius)) { bullet.damageTarget(enemy); }
                }
            }
            if (bullet.air) {
                for (i = _flyingEnemies.length - 1; i >= 0; i--) {
                    enemy = _flyingEnemies[i];
                    if (bullet.isHitTarget(enemy, bullet.splashRadius)) { bullet.damageTarget(enemy); }
                }
            }
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Node
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class Node {
        private var _center:TileBasedPoint;    // 中心の座標
        private var _passable:Boolean;        // 敵が通れるかどうか
        private var _buildable:Boolean;        // タワーが建てられるかどうか
        private var _numEnemy:int;            // このノード上にいる敵の数
        
        public function get tileX():int { return _center.tileX; }
        public function get tileY():int { return _center.tileY; }
        public function get centerX():Number { return _center.x; }
        public function get centerY():Number { return _center.y; }
        public function get passable():Boolean { return _passable; }
        public function get buildable():Boolean { return _buildable; }
        public function get numEnemy():int { return _numEnemy; }
        
        public function set passable(value:Boolean):void { _passable = value; }
        public function set buildable(value:Boolean):void { _buildable = value; }
        public function set numEnemy(value:int):void { _numEnemy = value; }
        
        public function Node(tilex:int, tiley:int, type:int) {
            _center = TileBasedPoint.createFromTilePos(tilex, tiley);
            _center.x += Const.NODE_SIZE / 2;
            _center.y += Const.NODE_SIZE / 2;
            
            switch(type) {
                case 0: { _passable = true; _buildable = true; break; }
                case 1: { _passable = false; _buildable = false; break; }
                case 2: { _passable = true; _buildable = false; break; }
            }
            _numEnemy = 0;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Start
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class Start {
        private var _position:TileBasedPoint;
        private var _width:int;
        private var _forFlying:Boolean;
        
        public function get posX():Number { return _position.x; }
        public function get posY():Number { return _position.y; }
        public function get tileX():int { return _position.tileX; }
        public function get tileY():int { return _position.tileY; }
        public function get forFlying():Boolean { return _forFlying; }
        
        public function Start(tilex:int, tiley:int, width:int, forFlying:Boolean) {
            _position = TileBasedPoint.createFromTilePos(tilex, tiley);
            _width = width * Const.NODE_SIZE;
            _forFlying = forFlying;
        }
        
        // ランダムな出現位置を取得する
        public function getRandomSpawningPosition():TileBasedPoint {
            var posx:int = int(_position.x + ((2 * _width * Math.random()) - _width));
            var posy:int = int(_position.y + Const.NODE_SIZE);
            return TileBasedPoint.createFromWorldPos(posx, posy);
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Goal
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class Goal {
        private static const DX:Array = [0, -1, 1, 0, -1, 1, -1, 1];
        private static const DY:Array = [ -1, 0, 0, 1, -1, -1, 1, 1];
        private static const DCOST:Array = [1, 1, 1, 1, Math.SQRT2, Math.SQRT2, Math.SQRT2, Math.SQRT2];
        
        private var _center:TileBasedPoint;
        private var _node:Node;
        private var _openNodes:Vector.<Node>;            // 保留ノードリスト
        private var _nodeCost:Vector.<Vector.<Number>>;    // 各ノードの移動コスト
        private var _nodeNext:Vector.<Vector.<Node>>;    // 各ノードの次の経路となるノード
        
        private var _previousNodeCost:Vector.<Vector.<Number>>;    // 以前のnodeCost
        private var _previousNodeNext:Vector.<Vector.<Node>>;    // 以前のnodeNext
        
        public function get tileX():int { return _center.tileX; }
        public function get tileY():int { return _center.tileY; }
        
        public function Goal(tilex:int, tiley:int) {
            _center = TileBasedPoint.createFromTilePos(tilex, tiley);
            _center.setWorldPos(_center.x + Const.NODE_SIZE / 2, _center.y + Const.NODE_SIZE / 2);
            _openNodes = new Vector.<Node>();
            _nodeCost = null; _nodeNext = null;
        }
        public function setNode(node:Node):void { _node = node; }
        
        // 引数で指定した位置から、ゴールまでのコストを返す
        public function getCost(posx:Number, posy:Number, flying:Boolean):Number {
            if (flying) {
                var diffx:Number = _center.x - posx;
                var diffy:Number = _center.y - posy;
                return diffx * diffx + diffy * diffy;
            }
            
            var postion:TileBasedPoint = TileBasedPoint.createFromWorldPos(posx, posy);
            return _nodeCost[postion.tileY][postion.tileX];
        }
        
        // 引数で指定した位置から、ゴールへ向かう経路が存在しているかどうか
        public function hasPath(tilex:int, tiley:int):Boolean {
            return _nodeCost[tiley][tilex] != Number.MAX_VALUE;
        }
        
        // 引数で指定した位置から、ゴールへ向かう為の次のノードを返す
        public function getNext(posx:Number, posy:Number, flying:Boolean):Node {
            if (flying) {
                return _node;
            }
            
            var position:TileBasedPoint = TileBasedPoint.createFromWorldPos(posx, posy);
            return _nodeNext[position.tileY][position.tileX];
        }
        
        // Dijkstra法による経路探索
        public function search(world:World):void {
            setup(world);
            
            while (_openNodes.length > 0) {
                var subject:Node = _openNodes.pop() as Node;
                
                // 周囲8方向のノードを訪問する
                for (var i:int = 0; i < 8; i++) {
                    // 画面外の存在しないノードを指すなら次の周囲ノードへ進む
                    if (!isValid(subject.tileX + Goal.DX[i], subject.tileY + Goal.DY[i])) { continue; }
                    // 通れないノード、計算済み（確定）ノード、直進することができないノードなら次の周囲ノードへ進む
                    var test:Node = world.getNode(subject.tileX + Goal.DX[i], subject.tileY + Goal.DY[i]);
                    if (!test.passable || isCalculatedNode(test) || !canGoStraightTo(subject, test, world)) { continue; }
                    
                    // 移動コストを計算する
                    _nodeCost[test.tileY][test.tileX] = _nodeCost[subject.tileY][subject.tileX] + Goal.DCOST[i];
                    // 次の経路ノードをsubjectノードに設定する
                    _nodeNext[test.tileY][test.tileX] = subject;
                    // 保留ノードリストに追加する
                    insertToOpenNodes(test);
                }
            }
        }
        
        // 探索前の準備
        private function setup(world:World):void {
            _previousNodeCost = _nodeCost;
            _previousNodeNext = _nodeNext;
            
            _nodeCost = new Vector.<Vector.<Number>>();
            _nodeNext = new Vector.<Vector.<Node>>();
            for (var row:int = 0; row < Const.NODE_ROWS; row++) {
                _nodeCost[row] = new Vector.<Number>();
                _nodeNext[row] = new Vector.<Node>();
                for (var col:int = 0; col < Const.NODE_COLS; col++) {
                    _nodeCost[row][col] = Number.MAX_VALUE;
                    _nodeNext[row][col] = world.getNode(col, row);
                }
            }
            
            // Goalのノードを経路探索のスタートノードとする
            _nodeCost[_center.tileY][_center.tileX] = 0;
            _openNodes.push(_node);
        }
        
        // indexの値が有効な値かどうか
        private function isValid(col:int, row:int):Boolean {
            return (col >= 0) && (col < Const.NODE_COLS) && (row >= 0) && (row < Const.NODE_ROWS);
        }
        
        // 既にコストを計算済みのノードかどうか
        private function isCalculatedNode(node:Node):Boolean {
            return _nodeCost[node.tileY][node.tileX] != Number.MAX_VALUE;
        }
        
        // subjectノードからtestノードへ直進できるかどうか
        private function canGoStraightTo(subject:Node, test:Node, world:World):Boolean {
            return world.getNode(subject.tileX, test.tileY).passable && world.getNode(test.tileX, subject.tileY).passable;
        }
        
        // nodeを保留ノードリストの適切な場所に挿入する
        private function insertToOpenNodes(node:Node):void {
            var insertIndex:int;
            var nodeCost:Number = _nodeCost[node.tileY][node.tileX];
            
            for (insertIndex = 0; insertIndex < _openNodes.length; insertIndex++) {
                var openNode:Node = _openNodes[insertIndex];
                if (nodeCost > _nodeCost[openNode.tileY][openNode.tileX]) { break; }
            }
            _openNodes.splice(insertIndex, 0, node);
        }
        
        // 最探索更新前の経路情報に戻す
        public function revertToPrevious():void {
            _nodeCost = _previousNodeCost;
            _nodeNext = _previousNodeNext;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Tower
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    
    //public 
    class Tower extends Sprite {
        private var _center:TileBasedPoint;
        private var _type:TowerType;        // 種類
        private var _level:int;                // 現在のレベル
        private var _world:World;
        private var _target:Enemy;            // 現在のターゲット
        private var _reloadCount:Number;    // 100を超えたら弾発射
        
        private var _body:Sprite;
        private var _levelText:TextField;
        
        public function get tileX():int { return _center.tileX; }
        public function get tileY():int { return _center.tileY; }
        public function get type():TowerType { return _type; }
        public function get level():int { return _level; }
        public function get active():Boolean { return _world != null; }
        
        public function Tower(posx:int, posy:int, type:TowerType, world:World = null) {
            x = posx;
            y = posy;
            
            _center = TileBasedPoint.createFromWorldPos(posx + Const.TOWER_SIZE / 2, posy + Const.TOWER_SIZE / 2);
            _type = type;
            _level = 1;
            _world = world;
            _target = null;
            _reloadCount = 0;
            
            draw();
            
            buttonMode = true;
            mouseChildren = false;
            addEventListener(MouseEvent.CLICK, isSelected, false, 0, true);
        }
        
        // タワーの画像を描画する
        private function draw():void {
            addChild(new Bitmap(ImageFactory.getImage("Base")));
            _body = addChild(new Sprite()) as Sprite;
            var bitmap:Bitmap = _body.addChild(new Bitmap(ImageFactory.getImage(_type.name), "auto", true)) as Bitmap;
            bitmap.x = bitmap.y = int( -Const.TOWER_SIZE / 2);
            _body.x = _body.y = int(Const.TOWER_SIZE / 2);
            
            if (active) {
                _body.rotation = 360 * Math.random() - 180;
                addChild(_levelText = ImageFactory.createBorderedText(Const.TOWER_SIZE - 10, Const.TOWER_SIZE - 10, 10, 10, _level.toString(), 10, 0xffffff, 0x000000));
            }
        }
        
        public function isSelected(e:MouseEvent = null):void {
            GameData.instance.selectedTower = this;
        }
        
        public function update():void {
            var range:int = _type.getStatus(_level).range;
            // ターゲット無しかターゲットがやられていたら、新しいターゲットを探す
            if (_target == null || _target.isDead()) {
                _target = _world.findTarget(_center.x, _center.y, range, _type.ground, _type.air);
            }
            
            // リロードカウントを進める
            if (_reloadCount < 100) { _reloadCount += _type.getStatus(_level).reloadSpeed; }
            
            if (_target != null) {
                var rangeSq:int = range * range;
                var diffX:Number = _target.posX - _center.x;
                var diffY:Number = _target.posY - _center.y;
                if (diffX * diffX + diffY * diffY < rangeSq) {
                    _body.rotation = _type.adjustBodyRotation(diffX, diffY, _body.rotation);
                    // リロードを終えていて、ターゲットがいるなら弾を発射する
                    if (_reloadCount >= 100 && _target != null) {
                        _reloadCount = 0;
                        _world.addBullet(type.createBullet(_center.x, _center.y, _level, _target, _world));
                    }
                }else {
                    // ターゲットが射程外になっていたらターゲットから外す
                    _target = null;
                }
            }
        }
        
        public function upgrade():void {
            // 既に最高レベルになっていたら終了
            if (!_type.hasStatus(_level + 1)) { return; }
            
            // アップグレードするだけの所持金があれば、アップグレード
            var upgradeCost:int = _type.getStatus(_level + 1).cost - _type.getStatus(_level).cost;
            if (upgradeCost <= GameData.instance.gold) {
                _level++;
                _levelText.text = _level.toString();
                GameData.instance.gold -= upgradeCost;
                GameData.instance.selectedTower = this;
            }
        }
        
        public function sell():void {
            _world.removeTower(this);
            GameData.instance.gold += _type.getStatus(_level).cost * GameData.instance.sellingRatio;
            GameData.instance.selectedTower = null;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * TowerType
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    
    //public 
    class TowerType {
        private var _name:String;                    // 種類名
        private var _ground:Boolean;                // 対地攻撃可能か
        private var _air:Boolean;                    // 対空攻撃可能か
        private var _slow:Boolean;                    // スロー効果有か
        private var _splash:Boolean;                // 範囲攻撃か
        private var _status:Vector.<TowerStatus>;    // （レベルごとの）各ステータス
        
        public function get name():String { return _name; }
        public function get ground():Boolean { return _ground; }
        public function get air():Boolean { return _air; }
        public function get slow():Boolean { return _slow; }
        public function get splash():Boolean { return _splash; }
        public function getStatus(level:int):TowerStatus { return _status[level - 1]; }
        
        // ※インスタンスは Config.getTowerType() から生成する
        public function TowerType(name:String, ground:Boolean, air:Boolean, slow:Boolean, splash:Boolean) {
            _name = name;
            _ground = ground;
            _air = air;
            _slow = slow;
            _splash = splash;
            _status = Config.getTowerStatus(_name);
        }
        
        // 指定したレベルのステータスがあるかどうか
        public function hasStatus(level:int):Boolean {
            return level <= _status.length;
        }
        
        // 種類に応じて、砲頭の角度を調整する
        public function adjustBodyRotation(diffx:Number, diffy:Number, currentRotation:Number):Number {
            switch(_name) {
                case "Vortex": { return currentRotation + 20; }
                default: { return Math.atan2(diffy, diffx) * 180 / Math.PI; }
            }
        }
        
        // 種類に応じた弾を生成する
        public function createBullet(posx:int, posy:int, level:int, target:Enemy, world:World):Bullet {
            var image:BitmapData = ImageFactory.getImage("Bullet_" + _name);
            var pos:TileBasedPoint = TileBasedPoint.createFromWorldPos(posx, posy);
            var status:TowerStatus = getStatus(level);
            
            switch(_name) {
                case "Arrow":
                { return new Bullet(pos, status.range, status.damage, 0, 6, _ground, _air, _slow, false, false, target, image, world); }
                case "Gatling":
                { return new Bullet(pos, status.range, status.damage, 0, 10, _ground, _air, _slow, false, false, target, image, world); }
                case "Bomb":
                { return new Bullet(pos, status.range, status.damage, 24, 3, _ground, _air, _slow, true, false, target, image, world); }
                case "Missile":
                { return new Bullet(pos, status.range, status.damage, 0, 8, _ground, _air, _slow, true, false, target, image, world); }
                case "Frost":
                { return new Bullet(pos, status.range, status.damage, 12, 6, _ground, _air, _slow, false, false, target, image, world); }
                case "Vortex":
                { return new Bullet(pos, 0, status.damage, status.range, 0, _ground, _air, _slow, false, false, target, image, world); }
                case "Laser":
                { return new Bullet(pos, 900, status.damage, (Const.ENEMY_SIZE + Const.BULLET_SIZE) / 2, Const.NODE_SIZE, _ground, _air, _slow, false, true, target, image, world); }
            }
            return null; // never called
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * TowerStatus
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class TowerStatus {
        private var _level:int;            // レベル 
        private var _cost:int;            // コスト
        private var _damage:int;        // ダメージ
        private var _range:int;            // 射程
        private var _firerate:Number;    // 射撃間隔（発/秒）
        private var _reloadSpeed:Number;
        
        public function get level():int { return _level; }
        public function get cost():int { return _cost; }
        public function get damage():int { return _damage; }
        public function get range():int { return _range; }
        public function get firerate():Number { return _firerate; }
        public function get reloadSpeed():Number { return _reloadSpeed; }
        
        // ※インスタンスは Config.getTowerStatus() から生成する
        public function TowerStatus(level:int, cost:int, damage:int, range:int, firerate:Number) {
            _level = level;
            _cost = cost;
            _damage = damage;
            _range = range;
            _firerate = firerate;
            _reloadSpeed = _firerate * 100 / Const.FRAME_RATE;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Bullet
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    
    //public 
    class Bullet extends Sprite {
        private var _life:int;            // 寿命（最大射程）
        private var _power:int;            // 威力
        private var _splashRadius:int;    // 範囲攻撃の半径（範囲攻撃で無いなら0）
        private var _speed:int;            // 速さ
        private var _ground:Boolean;    // 地上の敵に当たるか
        private var _air:Boolean;        // 空中の敵にあたるか
        private var _slow:Boolean;        // スロー効果
        private var _homing:Boolean;    // 追尾能力
        private var _pierce:Boolean;    // 貫通力
        private var _target:Enemy;        // ターゲット
        private var _world:World;
        
        private var _position:TileBasedPoint;    // 位置
        private var _velocity:Point;            // 速度
        
        public function get splashRadius():int { return _splashRadius; }
        public function get ground():Boolean { return _ground; }
        public function get air():Boolean { return _air; }
        
        public function Bullet(
            pos:TileBasedPoint, 
            life:int, power:int, radius:int, speed:int, 
            ground:Boolean, air:Boolean, slow:Boolean, 
            homing:Boolean, pierce:Boolean, 
            target:Enemy, image:BitmapData, world:World)
        {
            _life = life;
            _power = power;
            _splashRadius = radius;
            _speed = speed;
            _ground = ground;
            _air = air;
            _slow = slow;
            _homing = homing;
            _pierce = pierce;
            _target = target;
            _world = world;
            
            _position = pos;
            x = int(_position.x);
            y = int(_position.y);
            _velocity = new Point();
            changeVelocity();
            draw(image);
        }
        
        private function draw(image:BitmapData):void {
            var bitmap:Bitmap = new Bitmap(image);
            bitmap.x = bitmap.y = -int(Const.BULLET_SIZE / 2);
            addChild(bitmap);
        }
        
        // 速度を変更し、向きを変える
        private function changeVelocity():void {
            var diffX:Number = _target.posX - _position.x;
            var diffY:Number = _target.posY - _position.y;
            var radian:Number = Math.atan2(diffY, diffX);
            _velocity.x = _speed * Math.cos(radian);
            _velocity.y = _speed * Math.sin(radian);
            
            var degree:Number = radian * 180 / Math.PI;
            rotation = degree;
        }
        
        public function update():void {
            // 移動する
            _life -= _speed;
            x = int(_position.x += _velocity.x);
            y = int(_position.y += _velocity.y);
            if (_homing) { changeVelocity(); }
            
            // 画面外に出たら、消滅する
            if (_position.x < 0 || _position.x > 465 || _position.y < 0 || _position.y > 465) {
                _world.removeBullet(this);
                return;
            }
            
            // 射程外に出たら、（範囲攻撃の弾なら周辺の敵にダメージを与え）消滅する
            if (_life <= 0) {
                if (_splashRadius > 0) { _world.damageSurroundingEnemies(this); }
                _world.removeBullet(this);
                return;
            }
            
            // 貫通力ありなら、（ターゲットを問わず）周辺の敵にダメージを与える
            // ターゲットが死んでいたら、直線軌道に変更
            // ターゲットに当たっていたら、ダメージを与え消滅する
            if (_pierce) {
                _world.damageSurroundingEnemies(this);
            }else if (_target.isDead()) {
                _homing = false;
            }else if (isHitTarget(_target, (Const.BULLET_SIZE + Const.ENEMY_SIZE) / 2)) {
                if (_splashRadius > 0) { _world.damageSurroundingEnemies(this); }
                else { damageTarget(_target); }
                _world.removeBullet(this);
                return;
            }
        }
        
        public function isHitTarget(target:Enemy, radius:Number):Boolean {
            var diffX:Number = target.posX - _position.x;
            var diffY:Number = target.posY - _position.y;
            return diffX * diffX + diffY * diffY < radius * radius;
        }
        
        public function damageTarget(target:Enemy):void {
            target.damage(_power, _slow);
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Enemy
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    
    //public 
    class Enemy extends Sprite {
        private var _world:World;
        private var _center:TileBasedPoint;    // 中心の座標
        private var _velocity:Point;        // 速度
        private var _type:EnemyType;        // 種族
        private var _HP:int;                // 現在のHP
        private var _maxHP:int;                // 最大HP
        private var _point:int;                // 倒した時のポイント
        private var _money:int;                // 倒した時のお金
        private var _slowingCount:int;
        
        private var _image:Sprite;
        private var _HPbar:Sprite;
        
        private var _goal:Goal;
        private var _nextNode:Node;
        
        public function get posX():Number { return _center.x; }
        public function get posY():Number { return _center.y; }
        public function get tileX():int { return _center.tileX; }
        public function get tileY():int { return _center.tileY; }
        public function get type():EnemyType { return _type; }
        public function isDead():Boolean { return _HP <= 0; }
        public function setGoal(value:Goal):void {
            _goal = value;
            _nextNode = _goal.getNext(_center.x, _center.y, _type.flying);
        }
        
        public function Enemy(center:TileBasedPoint, type:EnemyType, HP:int, point:int, money:int, world:World) {
            _world = world;
            _center = center;
            x = int(_center.x);
            y = int(_center.y);
            _velocity = new Point();
            _type = type;
            _HP = _maxHP = HP;
            _point = point;
            _money = money;
            _slowingCount = 0;
            
            draw();
        }
        
        private function draw():void {
            _image = addChild(new Sprite()) as Sprite;
            var bitmap:Bitmap = _image.addChild(new Bitmap(ImageFactory.getImage(_type.name), "auto", true)) as Bitmap;
            bitmap.x = bitmap.y = int( -Const.ENEMY_SIZE / 2);
            
            var HPbarBackground:Sprite = addChild(new Sprite()) as Sprite;
            HPbarBackground.x = -Const.ENEMY_SIZE / 2;
            HPbarBackground.y = -(Const.ENEMY_SIZE / 2 + 2);
            HPbarBackground.graphics.beginFill(0xff0000);
            HPbarBackground.graphics.drawRect(0, 0, Const.ENEMY_SIZE, 1);
            HPbarBackground.graphics.endFill();
            
            _HPbar = HPbarBackground.addChild(new Sprite()) as Sprite;
            _HPbar.graphics.beginFill(0x00ff00);
            _HPbar.graphics.drawRect(0, 0, Const.ENEMY_SIZE, 1);
            _HPbar.graphics.endFill();
        }
        
        public function update(world:World):void {
            // スロー状態を更新
            var slowed:Boolean = (_slowingCount > 0);
            if (slowed) { _slowingCount--; }
            else { _image.filters = CONDITION_GOOD; }
            
            // 移動する
            x = int(_center.x += (slowed ? _velocity.x * 0.7 : _velocity.x));
            y = int(_center.y += (slowed ? _velocity.y * 0.7 : _velocity.y));
            
            // ゴールに到着していたら、ライフを減らして消滅
            if (_center.tileX == _goal.tileX && _center.tileY == _goal.tileY) {
                GameData.instance.lives--;
                _HP = 0;
                _world.removeEnemy(this);
                return;
            }
            
            // 次に進むべきノードに到着していたら、その次に進むべきノードに更新
            if (_center.tileX == _nextNode.tileX && _center.tileY == _nextNode.tileY) {
                _nextNode = _goal.getNext(_center.x, _center.y, _type.flying);
            }
            
            // 速度と向きの更新
            var radian:Number = Math.atan2(_nextNode.centerY - _center.y, _nextNode.centerX - _center.x);
            _velocity.x = (_velocity.x + _type.speed * Math.cos(radian)) * 0.5;
            _velocity.y = (_velocity.y + _type.speed * Math.sin(radian)) * 0.5;
            var degree:Number = radian * 180 / Math.PI;
            _image.rotation = degree;
        }
        
        private static const CONDITION_GOOD:Array = [];
        private static const CONDITION_SLOWED:Array = [new GlowFilter(0x0088ff, 1, 4, 4)];
        
        // ダメージを受ける
        public function damage(amount:int, slow:Boolean):void {
            _HP -= amount;
            if (_HP <= 0) {
                GameData.instance.score += _point;
                GameData.instance.gold += _money;
                _world.removeEnemy(this);
                _world.addEffect(new Coin(_center.x, _center.y));
                return;
            }
            _HPbar.scaleX = _HP / _maxHP;
            
            
            // 攻撃にスロー効果が付いていて、それに免疫が無かったら、スロー状態になる
            if (slow && !_type.immunity) { 
                _slowingCount = Const.SLOWING_DURATION;
                _image.filters = CONDITION_SLOWED;
            }
        }
        
        public function hasPathToGoal():Boolean {
            return _goal.hasPath(_center.tileX, _center.tileY);
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * EnemyType
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.utils.Dictionary;
    
    //public 
    class EnemyType {
        private static var _types:Dictionary;
        public static function initialize():void { _types = Config.getEnemyType(); }
        public static function getType(typeName:String):EnemyType { return _types[typeName]; }
        
        private var _name:String;        // 種族名称
        private var _speed:Number;        // 移動の速さ
        private var _flying:Boolean;    // 飛んでいるかどうか
        private var _immunity:Boolean;    // 免疫（状態異常スローに対する）があるかどうか
        
        public function get name():String { return _name; }
        public function get speed():Number { return _speed; }
        public function get flying():Boolean { return _flying; }
        public function get immunity():Boolean { return _immunity; }
        
        // ※インスタンスは Config.getEnemyType() から生成する
        public function EnemyType(name:String, speed:Number, flying:Boolean, immunity:Boolean) {
            _name = name;
            _speed = speed;
            _flying = flying;
            _immunity = immunity;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Coin
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Back;
    import org.libspark.betweenas3.easing.Expo;
    
    //public 
    class Coin extends Sprite {
        public function Coin(posx:int, posy:int) {
            x = posx;
            y = posy;
            
            draw();
            
            BetweenAS3.serial (
                BetweenAS3.tween(this, { $y: -16 }, null, 0.4, Back.easeOut),
                BetweenAS3.tween(this, { alpha: 0 }, null, 0.4, Expo.easeIn),
                BetweenAS3.removeFromParent(this)
            ).play();
        }
        
        private function draw():void {
            var bitmap:Bitmap = new Bitmap(ImageFactory.getImage("Coin"));
            bitmap.smoothing = true;
            bitmap.x = bitmap.y = -4;
            addChild(bitmap);
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Cursor
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    
    //public 
    class Cursor extends Sprite {
        private var _world:World;
        private var _border:Sprite;        // 枠線
        private var _towerImage:Sprite;    // タワーの画像
        private var _towerBody:Bitmap;    // タワー本体の画像
        
        public function Cursor(world:World) {
            _world = world;
            _border = createBorder();
            _towerImage = new Sprite();
            _towerImage.addChild(new Bitmap(ImageFactory.getImage("Base")));
            _towerImage.addChild(_towerBody = new Bitmap());
            _towerImage.alpha = 0.5;
            
            mouseChildren = mouseEnabled = false;
            
            GameData.instance.addEventListener(Const.EVENT_CHANGE_SELECTEDTOWER, onUpdateSelectedTower);
        }
        
        private function createBorder():Sprite {
            var sprite:Sprite = new Sprite();
            sprite.graphics.lineStyle(2, 0xffff00);
            sprite.graphics.drawRect(0, 0, Const.TOWER_SIZE, Const.TOWER_SIZE);
            return sprite;
        }
        
        public function update(posx:int, posy:int):void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            var position:TileBasedPoint;
            
            if (selectedTower != null && selectedTower.active) {
                position = TileBasedPoint.createFromWorldPos(selectedTower.x, selectedTower.y);
            }else {
                position = TileBasedPoint.createFromWorldPos(posx, posy);
                position.setTilePos(position.tileX, position.tileY);
            }
            
            x = position.x;
            y = position.y;
            
            updateRangeCircle(position.tileX, position.tileY);
        }
        
        private static const POSSIBLE:uint = 0xffffff;
        private static const IMPOSSIBLE:uint = 0xff0000;
        
        private function updateRangeCircle(tilex:int, tiley:int):void {
            graphics.clear();
            
            var selectedTower:Tower = GameData.instance.selectedTower;
            if (selectedTower == null) { return; }
            
            var color:uint = (selectedTower.active || _world.canBuildTower(tilex, tiley)) ? POSSIBLE : IMPOSSIBLE;
            graphics.lineStyle(0, color, 0.6);
            graphics.beginFill(color, 0.2);
            graphics.drawCircle(int(Const.TOWER_SIZE / 2), int(Const.TOWER_SIZE / 2), selectedTower.type.getStatus(selectedTower.level).range);
            graphics.endFill();
        }
        
        private function onUpdateSelectedTower(e:Event):void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            if (contains(_border)) { removeChild(_border); }
            if (contains(_towerImage)) { removeChild(_towerImage); }
            
            if (selectedTower == null) { return; }
            
            if (selectedTower.active) {
                addChild(_border);
            }else {
                _towerBody.bitmapData = ImageFactory.getImage(selectedTower.type.name);
                _towerBody.smoothing = true;
                addChild(_towerImage);
            }
            
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Frontend
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    
    //public 
    class Frontend extends Sprite {
        private var _wave:TextField;
        private var _score:TextField;
        private var _lives:TextField;
        private var _gold:TextField;
        
        private var _buttons:Sprite;                    // ボタンをまとめる表示オブジェクト
        private var _towerStatus:TowerStatusWindow;        // タワーのステータスを表示するウインドウ
        
        public function Frontend(posx:int, posy:int) {
            x = posx;
            y = posy;
            
            addChild(createGameStatusWindow(0, 0));
            addChild(createTowerSelectionWindow(365, 0));
            
            GameData.instance.addEventListener(Const.EVENT_CHANGE_GAMESTATUS, onUpdateGameStatus);
            GameData.instance.addEventListener(Const.EVENT_CHANGE_SELECTEDTOWER, onUpdateSelectedTower);
        }
        
        // ゲームのステータスを表示するウインドウを作成する
        private function createGameStatusWindow(posx:int, posy:int):Sprite {
            var gameStatus:Sprite = ImageFactory.createWindow(posx, posy, 365, 25);
            gameStatus.addChild(ImageFactory.createBorderedText(14, 0, 40, 25, "Wave :", 12, 0xffffff, 0x808080));
            gameStatus.addChild(_wave = ImageFactory.createScoreText(54, 0, 25, 25, "0", 14, 0xffffff));
            gameStatus.addChild(ImageFactory.createBorderedText(93, 0, 40, 25, "Score :", 12, 0xffffff, 0x808080));
            gameStatus.addChild(_score = ImageFactory.createScoreText(133, 0, 50, 25, "0", 14, 0xffffff));
            gameStatus.addChild(ImageFactory.createBorderedText(197, 0, 40, 25, "Lives :", 12, 0xffffff, 0xf00000));
            gameStatus.addChild(_lives = ImageFactory.createScoreText(237, 0, 20, 25, "0", 14, 0xff0000));
            gameStatus.addChild(ImageFactory.createBorderedText(271, 0, 35, 25, "Gold :", 12, 0xffffff, 0xb0b000));
            gameStatus.addChild(_gold = ImageFactory.createScoreText(306, 0, 45, 25, "0", 14, 0xffff00));
            return gameStatus;
        }
        
        // タワー選択ボタンを配置するウインドウと、タワーのステータスを表示するウインドウを作成する
        private function createTowerSelectionWindow(posx:int, posy:int):Sprite {
            var towerSelection:Sprite = ImageFactory.createWindow(posx, posy, 100, 415);
            towerSelection.addChild(_buttons = new Sprite());
            
            // タワー選択ボタンを7つ作成して配置する
            var towertypes:Vector.<TowerType> = Config.getTowerType();
            for (var i:int = 0; i < 7; i++) {
                var tower:Tower = _buttons.addChild(new Tower(((i < 4) ? 15 : 53), 7 + 38 * (i % 4), towertypes[i])) as Tower;
                tower.addChild(ImageFactory.createSimpleText(((i < 4) ? -12 : 32), 0, 12, 32, String(i + 1), 10, 0xffffff));
                HotKey.bind(Keyboard.NUMBER_1 + i, tower.isSelected);
                HotKey.bind(Keyboard.NUMPAD_1 + i, tower.isSelected);
            }
            // 選択キャンセルボタンを作成して配置する
            var cancelButton:Sprite = towerSelection.addChild(createCancelButton(53, 7 + 38 * 3)) as Sprite;
            cancelButton.addChild(ImageFactory.createSimpleText(32, 0, 12, 32, "0", 10, 0xffffff));
            HotKey.bind(Keyboard.NUMBER_0, isSelectedCancelButton);
            HotKey.bind(Keyboard.NUMPAD_0, isSelectedCancelButton);
            HotKey.bind(Keyboard.ESCAPE, isSelectedCancelButton);
            
            towerSelection.addChild(_towerStatus = new TowerStatusWindow(5, 160));
            _towerStatus.visible = false;
            return towerSelection;
        }
        
        // 選択キャンセルボタンを作成する
        private function createCancelButton(posx:int, posy:int):Sprite {
            var cancel:Sprite = new Sprite();
            cancel.x = posx;
            cancel.y = posy;
            cancel.addChild(new Bitmap(ImageFactory.getImage("Base")));
            cancel.addChild(new Bitmap(ImageFactory.getImage("Cancel")));
            cancel.buttonMode = true;
            cancel.addEventListener(MouseEvent.CLICK, isSelectedCancelButton);
            return cancel;
        }
        private function isSelectedCancelButton(e:MouseEvent = null):void { GameData.instance.selectedTower = null; }
        
        private static const LIGHTEN:ColorTransform = new ColorTransform();
        private static const DARKEN:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
        
        public function onUpdateGameStatus(e:Event):void {
            var data:GameData = GameData.instance;            
            _wave.text = data.wave.toString();
            _score.text = data.score.toString();
            _lives.text = data.lives.toString();
            _gold.text = data.gold.toString();
            
            // タワーが購入できるかどうかで、タワー選択ボタンに明暗をつける
            for (var i:int = 0; i < _buttons.numChildren; i++) {
                var button:Tower = _buttons.getChildAt(i) as Tower;
                button.transform.colorTransform = ((button.type.getStatus(button.level).cost <= data.gold) ? LIGHTEN: DARKEN);
            }
            
            // アップグレードボタンの有効/無効を反映させる
            if (_towerStatus.visible) { _towerStatus.updateUpgradeButton(); }
        }
        
        private static const NON_GLOW:Array = [];
        private static const GLOW:Array = [new GlowFilter(0xffff00, 1, 8, 8)];
        
        public function onUpdateSelectedTower(e:Event):void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            
            // タワー選択ボタンのハイライトを解除する
            for (var i:int = 0; i < _buttons.numChildren; i++) {
                _buttons.getChildAt(i).filters = NON_GLOW;
            }
            
            if (selectedTower != null) {
                _buttons.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverButton);
                _buttons.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutButton);
                
                _towerStatus.update(selectedTower);
                _towerStatus.visible = true;
                // 選択されたボタンにハイライトをつける
                if (!selectedTower.active) { selectedTower.filters = GLOW; }
            }else {
                _buttons.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverButton);
                _buttons.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutButton);
                _towerStatus.visible = false;
            }
        }
        
        // タワー非選択時、選択ボタンにマウスオーバーでステータスを表示するようにする
        private function onMouseOverButton(e:MouseEvent):void {
            _towerStatus.update(Tower(e.target));
            _towerStatus.visible = true;
        }
        private function onMouseOutButton(e:MouseEvent):void {
            _towerStatus.visible = false;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * TowerStatusWindow
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;
    
    //public 
    class TowerStatusWindow extends Sprite {
        private var _towerName:TextField;
        private var _attlibuteGround:TextField;
        private var _attlibuteAir:TextField;
        private var _attlibuteSlow:TextField;
        private var _attlibuteSplash:TextField;
        private var _level:TextField;
        private var _cost:TextField;
        private var _damage:TextField;
        private var _range:TextField;
        private var _firerate:TextField;
        
        private var _upgradeButton:PushButton;
        private var _sellButton:PushButton;
        
        private static const LIGHTEN:uint = 0xffffff;
        private static const DARKEN:uint = 0x606060;
        
        public function TowerStatusWindow(posx:int, posy:int):void {
            x = posx;
            y = posy;
            
            addChild(ImageFactory.createWindow(0, 0, 90, 250));
            addChild(ImageFactory.createWindow(0, 0, 90, 20));
            addChild(_towerName = ImageFactory.createSimpleText(0, 0, 90, 20, "Tower", 12, 0xffffff));
            addChild(_attlibuteGround = ImageFactory.createSimpleText(5, 25, 40, 10, "Ground", 10, TowerStatusWindow.LIGHTEN));
            addChild(_attlibuteAir = ImageFactory.createSimpleText(5, 35, 40, 10, "Air", 10, TowerStatusWindow.LIGHTEN));
            addChild(_attlibuteSlow = ImageFactory.createSimpleText(45, 25, 40, 10, "Slow", 10, TowerStatusWindow.DARKEN));
            addChild(_attlibuteSplash = ImageFactory.createSimpleText(45, 35, 40, 10, "Splash", 10, TowerStatusWindow.DARKEN));
            addChild(ImageFactory.createBorderedText(0, 50, 90, 10, "Level", 10, 0xffffff, 0x00b000));
            addChild(_level = ImageFactory.createStatusText(0, 62, 90, 15, "E", 14, 0x00ff00));
            addChild(ImageFactory.createBorderedText(0, 80, 90, 10, "Cost", 10, 0xffffff, 0xb0b000));
            addChild(_cost = ImageFactory.createStatusText(0, 92, 90, 15, "0", 14, 0xffff00));
            addChild(ImageFactory.createBorderedText(0, 110, 90, 10, "Damage", 10, 0xffffff, 0xf00000));
            addChild(_damage = ImageFactory.createStatusText(0, 122, 90, 15, "0", 14, 0xff0000));
            addChild(ImageFactory.createBorderedText(0, 140, 90, 10, "Range", 10, 0xffffff, 0x00b0b0));
            addChild(_range = ImageFactory.createStatusText(0, 152, 90, 15, "0", 14, 0x00ffff));
            addChild(ImageFactory.createBorderedText(0, 170, 90, 10, "FireRate", 10, 0xffffff, 0xb000b0));
            addChild(_firerate = ImageFactory.createStatusText(0, 182, 90, 15, "0", 14, 0xff00ff));
            
            _upgradeButton = new PushButton(this, 5, 204, "Upgrade (U)", upgradeSelectedTower);
            _sellButton = new PushButton(this, 5, 225, "Sell (S)", sellSelectedTower);
            _upgradeButton.width = _sellButton.width = 80;
            
            // 各ボタンに対応するホットキーを設定する
            HotKey.bind(Keyboard.U, upgradeSelectedTower);
            HotKey.bind(Keyboard.S, sellSelectedTower);
        }
        
        private function upgradeSelectedTower(e:MouseEvent = null):void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            if (selectedTower != null && selectedTower.active) {
                selectedTower.upgrade();
            }
        }
        
        private function sellSelectedTower(e:MouseEvent = null):void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            if (selectedTower != null && selectedTower.active) {
                selectedTower.sell();
            }
        }
        
        // 引数で与えたタワーのステータス表示に更新する
        public function update(tower:Tower):void {
            var type:TowerType = tower.type;
            _towerName.text = type.name + " Tower";
            _attlibuteGround.textColor = (type.ground ? TowerStatusWindow.LIGHTEN : TowerStatusWindow.DARKEN);
            _attlibuteAir.textColor = (type.air ? TowerStatusWindow.LIGHTEN : TowerStatusWindow.DARKEN);
            _attlibuteSlow.textColor = (type.slow ? TowerStatusWindow.LIGHTEN : TowerStatusWindow.DARKEN);
            _attlibuteSplash.textColor = (type.splash ? TowerStatusWindow.LIGHTEN : TowerStatusWindow.DARKEN);
            
            var status:TowerStatus = type.getStatus(tower.level);
            _level.text = tower.level.toString();
            _cost.text = status.cost.toString();
            _damage.text = status.damage.toString();
            _range.text = status.range.toString();
            _firerate.text = status.firerate.toFixed(1);
            
            // タワーが選択ボタンのものならボタンを隠して、処理を終える
            if (!tower.active) {
                _upgradeButton.visible = _sellButton.visible = false;
                return;
            }
            
            // アップグレード可能か、アップグレード時の上昇値はいくつかを表示に反映させる
            _upgradeButton.visible = _sellButton.visible = true;
            updateUpgradeButton();
            if (type.hasStatus(tower.level + 1)) {
                var nextStatus:TowerStatus = type.getStatus(tower.level + 1);
                _level.appendText(" → " + nextStatus.level);
                _cost.appendText(" + " + (nextStatus.cost - status.cost));
                if (nextStatus.damage - status.damage > 0) { _damage.appendText(" + " + (nextStatus.damage - status.damage)); }
                if (nextStatus.range - status.range > 0) { _range.appendText(" + " + (nextStatus.range - status.range)); }
                if (nextStatus.firerate - status.firerate >= 0.09) { _firerate.appendText(" + " + (nextStatus.firerate - status.firerate).toFixed(1)); }
                else if (nextStatus.firerate - status.firerate < 0) { _firerate.appendText(" - " + Math.abs(nextStatus.firerate - status.firerate).toFixed(1)); }
            }
        }
        
        public function updateUpgradeButton():void {
            var selectedTower:Tower = GameData.instance.selectedTower;
            if (selectedTower == null || !selectedTower.active || !selectedTower.type.hasStatus(selectedTower.level + 1)) {
                _upgradeButton.enabled = false;
                return;
            }
            
            var upgradeCost:int = selectedTower.type.getStatus(selectedTower.level + 1).cost - selectedTower.type.getStatus(selectedTower.level).cost;
            _upgradeButton.enabled = (GameData.instance.gold >= upgradeCost) ? true : false;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * WaveManager
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    //public 
    class WaveManager extends Sprite {
        private var _currentWave:int;
        private var _waves:Vector.<Wave>;
        private var _onScreen:BitmapData;
        private var _offScreen:Sprite;
        private var _offScreenPosX:int;
        private var _nextWaveCount:int;
        
        public function finished():Boolean { return _currentWave == _waves.length; }
        
        public function WaveManager(posx:int, posy:int, world:World) {
            x = posx;
            y = posy;
            
            _waves = Config.getWaves();
            _offScreen = new Sprite();
            for (var i:int = 0; i < _waves.length; i++) {
                var wave:Wave = _waves[i];
                wave.x = i * Const.WAVE_WIDTH;
                wave.setWorld(world);
                _offScreen.addChild(wave);
            }
            createWaveManagementWindow();
            initialize();
        }
        
        public function initialize():void {
            _currentWave = 0;
            _offScreenPosX = 301;
            _offScreen.x = _offScreenPosX / 10;
            updateOnScreen();
            _nextWaveCount = 1;
            
            for (var i:int = 0; i < _waves.length; i++) {
                _waves[i].initialize();
            }
        }
        
        private function updateOnScreen():void {
            _onScreen.fillRect(ONSCREEN_RECT, 0x000000);
            _onScreen.draw(_offScreen, _offScreen.transform.matrix);
        }
        
        private function createWaveManagementWindow():void {
            var window:Sprite = addChild(ImageFactory.createWindow(-10, 0, 475, 50)) as Sprite;
            _onScreen = new BitmapData(365, 30, false, 0x000000);
            var bitmap:Bitmap = window.addChild(new Bitmap(_onScreen)) as Bitmap;
            bitmap.x = bitmap.y = 10;
            
            var line:Sprite = window.addChild(new Sprite()) as Sprite;
            line.graphics.lineStyle(1, 0xffff00);
            line.graphics.moveTo(40, 2);
            line.graphics.lineTo(40, 48);
        }
        
        private static const ONSCREEN_RECT:Rectangle = new Rectangle(0, 0, 365, 30);
        
        public function update():void {
            _offScreenPosX--;
            if (_offScreenPosX % 10 == 0) { _offScreen.x = _offScreenPosX / 10; }
            updateOnScreen();
            
            _nextWaveCount--;
            if (_nextWaveCount == 0) {
                sendNextWave();
            }
            
            for (var i:int = 0; i < _waves.length; i++) {
                _waves[i].update();
            }
        }
        
        public function sendNextWave():void {
            // 全てのWaveが送出されていたら何もせずに終了する
            if (_currentWave == _waves.length) { return; }
            
            _currentWave++;
            GameData.instance.wave = _currentWave;
            _waves[_currentWave - 1].send();
            
            // 先送りしていたら、その分をスコアに加算する
            GameData.instance.score += int(_nextWaveCount / 10);
            _offScreenPosX -= _nextWaveCount;
            _offScreen.x = _offScreenPosX / 10;
            updateOnScreen();
            _nextWaveCount = Const.WAVE_INTERVAL;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Wave
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    
    //public 
    class Wave extends Sprite {
        private var _world:World;
        private var _number:int;            // Wave数
        
        private var _enemyType:EnemyType;    // 敵のタイプ
        private var _enemyHP:int;            // 敵のHP
        private var _enemyPoint:int;        // 敵を倒した時のポイント
        private var _enemyMoney:int;        // 敵を倒した時の入手金
        private var _enemyNum:Vector.<int>;    // 出現する敵の数
        
        private var _isActivated:Boolean;        // 送出中かどうか
        private var _allEnemiesSent:Boolean;     // 全ての敵が送出されたかどうか
        private var _spawnInterval:int;            // 敵の出現間隔
        private var _spawnCount:int;            // 出現カウント
        private var _waitingNum:Vector.<int>;    // 待機中の敵の数
        
        public function setWorld(value:World):void { _world = value; }
        
        public function Wave(number:int, type:EnemyType, HP:int, point:int, money:int, numSpawning:Vector.<int>) {
            _number = number
            _enemyType = type;
            _enemyHP = HP;
            _enemyPoint = point;
            _enemyMoney = money;
            _enemyNum = numSpawning;
            
            initialize();
            var max:int = 0;
            for (var i:int = 0; i < _enemyNum.length; i++) {
                if (_enemyNum[i] > max) { max = _enemyNum[i]; }
            }
            _spawnInterval = int((Const.WAVE_INTERVAL / 4) / max);
            _spawnCount = 0;
            _waitingNum = new Vector.<int>(_enemyNum.length);
            
            draw();
        }
        
        public function initialize():void {
            _isActivated = false;
            _allEnemiesSent = false;
        }
        
        private function draw():void {
            var bodyColor:uint, borderColor:uint;
            switch(_enemyType.name) {
                case "Immune": { bodyColor = 0xcc00cc; borderColor = 0x660066; break; }
                case "Fast":   { bodyColor = 0x4444ff; borderColor = 0x222288; break; }
                case "Flying": { bodyColor = 0xffcc00; borderColor = 0x886600; break; }
                default:       { bodyColor = 0xff0000; borderColor = 0x880000; break; }
            }
            
            graphics.lineStyle(1, borderColor);
            graphics.beginFill(bodyColor);
            graphics.drawRect(0.5, 0, Const.WAVE_WIDTH - 1, 30);
            graphics.endFill();
            
            addChild(ImageFactory.createStatusText(0, 0, Const.WAVE_WIDTH, 30, _number.toString(), 30, borderColor));
            addChild(ImageFactory.createBorderedText(0, 0, Const.WAVE_WIDTH, 30, _enemyType.name, 12, 0xffffff, borderColor));
            cacheAsBitmap = true;
        }
        
        // 敵の送出を開始する
        public function send():void {
            _isActivated = true;
            _spawnCount = 0;
            for (var i:int = 0; i < _enemyNum.length; i++) {
                _waitingNum[i] = _enemyNum[i];
            }
        }
        
        public function update():void {
            if (!_isActivated || _allEnemiesSent) { return; }
            
            // カウントを進める
            _spawnCount--;
            if (_spawnCount > 0) { return; }
            _spawnCount = _spawnInterval;
            
            // カウントが0になったら、敵を出現させる
            _allEnemiesSent = true;
            for (var i:int = 0; i < _waitingNum.length; i++) {
                if (_waitingNum[i] > 0) {
                    _waitingNum[i]--;
                    _allEnemiesSent = false;
                    
                    var enemy:Enemy = new Enemy(_world.getStartingPos(i), _enemyType, _enemyHP, _enemyPoint, _enemyMoney, _world);
                    _world.addEnemy(enemy);
                }
            }
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * GameData
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    //public 
    class GameData extends EventDispatcher {
        private var _wave:int;
        private var _score:int;
        private var _lives:int;
        private var _gold:int;
        private var _selectedTower:Tower;
        private var _sellingRatio:Number;
        
        public function get wave():int { return _wave; }
        public function get score():int { return _score; }
        public function get lives():int { return _lives; }
        public function get gold():int { return _gold; }
        public function get selectedTower():Tower { return _selectedTower; }
        public function get sellingRatio():Number { return _sellingRatio; }
        
        public function set wave(value:int):void { _wave = value; dispatchEvent(new Event(Const.EVENT_CHANGE_GAMESTATUS)); }
        public function set score(value:int):void { _score = value; dispatchEvent(new Event(Const.EVENT_CHANGE_GAMESTATUS)); }
        public function set lives(value:int):void { _lives = Math.max(0, value); dispatchEvent(new Event(Const.EVENT_CHANGE_GAMESTATUS)); }
        public function set gold(value:int):void { _gold = value; dispatchEvent(new Event(Const.EVENT_CHANGE_GAMESTATUS)); }
        public function set selectedTower(value:Tower):void { _selectedTower = value; dispatchEvent(new Event(Const.EVENT_CHANGE_SELECTEDTOWER)); }
        public function set sellingRatio(value:Number):void { _sellingRatio = value; }
        
        private static var _instance:GameData = null;
        public static function get instance():GameData {
            if (GameData._instance == null) { _instance = new GameData(new SingletonEnforcer()); }
            return _instance;
        }
        public function GameData(enforcer:SingletonEnforcer) { initialize(); }
        
        public function initialize():void {
            _wave = 0;
            _score = 0;
            _lives = Config.INITIAL_LIVES;
            _gold = Config.INITIAL_GOLD;
            _selectedTower = null;
            _sellingRatio = 1;
            
            dispatchEvent(new Event(Const.EVENT_CHANGE_GAMESTATUS));
            dispatchEvent(new Event(Const.EVENT_CHANGE_SELECTEDTOWER));
        }
    }
//}
internal class SingletonEnforcer { }
/* ----------------------------------------------------------------------------------------------------------------------
 * Const
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class Const {
        public static const FRAME_RATE:int = 30;    // フレームレート
        public static const NODE_SIZE:int = 16;        // ノードの大きさ
        public static const NODE_COLS:int = 24;        // ノードの列数
        public static const NODE_ROWS:int = 26;        // ノードの行数
        public static const TOWER_SIZE:int = 32;    // タワーの大きさ
        public static const BULLET_SIZE:int = 8;    // 弾の大きさ
        public static const ENEMY_SIZE:int = 16;    // 敵の大きさ
        
        public static const SLOWING_DURATION:int = 5 * Const.FRAME_RATE;
        public static const WAVE_INTERVAL:int = 20 * Const.FRAME_RATE;
        public static const WAVE_WIDTH:int = int(WAVE_INTERVAL / 10);
        public static const CURSOR_OFFSET:int = Const.NODE_SIZE / 2;
        
        public static const EVENT_CHANGE_GAMESTATUS:String = "change_gamestatus";
        public static const EVENT_CHANGE_SELECTEDTOWER:String = "change_selectedtower";
        
        //availableFonts["Aqua","Azuki","Cinecaption","Mona","Sazanami","YSHandy","VLGothic","IPAGP","IPAM","UmeUgo","UmePms","Bebas"]
        public static const EMBED_FONT:String = "IPAGP";
        public static const USE_FONTLOADER:Boolean = true;
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * HotKey
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    
    //public 
    class HotKey {
        private static var _keymap:Vector.<Function> = new Vector.<Function>(256, true);
        private static var _stage:Stage;
        
        public static function setStage(value:Stage):void { HotKey._stage = value; }
        public static function enable():void { HotKey._stage.addEventListener(KeyboardEvent.KEY_DOWN, HotKey.onKeyDown); _stage.focus = null; }
        public static function disable():void { HotKey._stage.removeEventListener(KeyboardEvent.KEY_DOWN, HotKey.onKeyDown); }
        
        // 押したキーに処理が割り当てられていたら、それを実行する
        private static function onKeyDown(e:KeyboardEvent):void {
            var command:Function = HotKey._keymap[e.keyCode];
            if (command != null) { command(); }    // command.execute
            _stage.focus = null;
        }
        
        // keyCodeに対応するキーに、commandで指定した処理を割り当てる
        public static function bind(keyCode:uint, command:Function):void {
            HotKey._keymap[keyCode] = command;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Preloader
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import com.bit101.components.ProgressBar;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import net.wonderfl.utils.FontLoader;
    
    //public 
    class Preloader extends EventDispatcher {
        private var _assetsNum:int;                // 読み込むアセットの数
        private var _loadedNum:int;                // 読み込み完了したアセットの数
        private var _progressBar:ProgressBar;    // プログレスバー
        
        private var _imageLoaders:Dictionary;    // 画像のローダを保持する連想配列
        private var refImageHolder:Dictionary;    // 画像を保持する連想配列の参照
        
        public function Preloader(parentOfProgressBar:DisplayObjectContainer, imagePaths:Dictionary, imageHolder:Dictionary) {
            _assetsNum = _loadedNum = 0;
            _progressBar = new ProgressBar(parentOfProgressBar, 182, 227);
            
            startLoadingImages(imagePaths, imageHolder);
            if (Const.USE_FONTLOADER) { startLoadingFont(); }
            
            _progressBar.maximum = _assetsNum;
        }
        
        // 外部画像の読み込みを開始する
        private function startLoadingImages(imagePaths:Dictionary, imageHolder:Dictionary):void {
            _imageLoaders = new Dictionary();
            refImageHolder = imageHolder;
            
            for (var imageName:String in imagePaths) {
                _assetsNum++;
                var imageLoader:ExternalImageLoader = new ExternalImageLoader();
                _imageLoaders[imageName] = imageLoader;
                imageLoader.addEventListener(Event.COMPLETE, assetLoaded);
                imageLoader.load(imagePaths[imageName]);
            }
        }
        
        // フォントの読み込みを開始する
        private function startLoadingFont():void {
            _assetsNum++;
            
            var fontLoader:FontLoader = new FontLoader();
            fontLoader.addEventListener(Event.COMPLETE, assetLoaded);
            fontLoader.load(Const.EMBED_FONT);
        }
        
        // 一つのアセットの読み込みが完了した際に呼ばれるメソッド
        private function assetLoaded(e:Event):void {
            e.target.removeEventListener(Event.COMPLETE, assetLoaded);
            
            _loadedNum++;
            _progressBar.value = _loadedNum;
            checkLoadComplete();
        }
        
        // 読み込んだアセット数を調べ、全て読み込んでいたら完了イベントを通知する
        private function checkLoadComplete():void {
            if (_loadedNum == _assetsNum) {
                for (var imageName:String in _imageLoaders) {
                    refImageHolder[imageName] = _imageLoaders[imageName].content;
                }
                
                _progressBar.parent.removeChild(_progressBar);
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * ExternalImageLoader
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    //public 
    class ExternalImageLoader extends EventDispatcher {
        private var _content:BitmapData;
        private var _tempA:Loader;
        private var _tempB:Loader;
        
        public function get content():BitmapData { return _content; }
        
        public function ExternalImageLoader() {
            _content = null; _tempA = new Loader(); _tempB = new Loader();
        }
        
        public function load(url:String):void {
            _tempA.contentLoaderInfo.addEventListener(Event.INIT, tempALoaded);
            _tempA.load(new URLRequest(url), new LoaderContext(true));
        }
        
        private function tempALoaded(e:Event):void {
            _tempA.contentLoaderInfo.removeEventListener(Event.INIT, tempALoaded);
            _content = new BitmapData(int(_tempA.width), int(_tempA.height), true, 0x00ffffff);
            _tempB.contentLoaderInfo.addEventListener(Event.INIT, tempBLoaded);
            _tempB.loadBytes(_tempA.contentLoaderInfo.bytes);
        }
        
        private function tempBLoaded(e:Event):void {
            _tempB.contentLoaderInfo.removeEventListener(Event.INIT, tempBLoaded);
            _content.draw(_tempB); _tempA.unload(); _tempB.unload();
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * TileBasedPoint
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class TileBasedPoint {
        private static const TILE_SIZE:int = Const.NODE_SIZE;
        private static const TILE_COLS:int = Const.NODE_COLS;
        private static const TILE_ROWS:int = Const.NODE_ROWS;
        
        // ワールド座標
        private var _worldX:Number;
        private var _worldY:Number;
        // タイル座標
        private var _tileX:int;
        private var _tileY:int;
        
        private var _isInvalidWorldPos:Boolean;    // ワールド座標値を更新する必要があるかどうか
        private var _isInvalidTilePos:Boolean;    // タイル座標値を更新する必要があるかどうか
        
        // Creation Method でインスタンスを生成する
        public static function createFromWorldPos(x:Number, y:Number):TileBasedPoint { return new TileBasedPoint(true, x, y, 0, 0); }
        public static function createFromTilePos(x:int, y:int):TileBasedPoint { return new TileBasedPoint(false, 0, 0, x, y); }
        public function TileBasedPoint(isWorldPos:Boolean, worldx:Number, worldy:Number, tilex:int, tiley:int) {
            _worldX = worldx;
            _worldY = worldy;
            _tileX = tilex;
            _tileY = tiley;
            _isInvalidWorldPos = !isWorldPos;
            _isInvalidTilePos = isWorldPos;
        }
        
        private function updateWorldPos():void {
            _worldX = Math.max(0, Math.min(_tileX * TILE_SIZE, (TILE_COLS - 1) * TILE_SIZE));
            _worldY = Math.max(0, Math.min(_tileY * TILE_SIZE, (TILE_ROWS - 1) * TILE_SIZE));
        }
        
        private function updateTilePos():void {
            _tileX = Math.max(0, Math.min(int(_worldX / TILE_SIZE), TILE_COLS - 1));
            _tileY = Math.max(0, Math.min(int(_worldY / TILE_SIZE), TILE_ROWS - 1));
        }
        
        // ワールド座標を有効にする
        private function validateWorldPos():void {
            if (_isInvalidWorldPos) {
                updateWorldPos();
                _isInvalidWorldPos = false;
            }
        }
        
        // タイル座標を有効にする
        private function validateTilePos():void {
            if (_isInvalidTilePos) {
                updateTilePos();
                _isInvalidTilePos = false;
            }
        }
        
        public function get x():Number { validateWorldPos(); return _worldX; }
        public function get y():Number { validateWorldPos(); return _worldY; }
        public function get tileX():int { validateTilePos(); return _tileX; }
        public function get tileY():int { validateTilePos(); return _tileY; }
        
        public function set x(value:Number):void { validateWorldPos(); _worldX = value; _isInvalidTilePos = true; }
        public function set y(value:Number):void { validateWorldPos(); _worldY = value; _isInvalidTilePos = true; }
        public function setWorldPos(x:Number, y:Number):void { validateWorldPos(); _worldX = x; _worldY = y; _isInvalidTilePos = true; }
        public function set tileX(value:int):void { validateTilePos(); _tileX = value; _isInvalidWorldPos = true; }
        public function set tileY(value:int):void { validateTilePos(); _tileX = value; _isInvalidWorldPos = true; }
        public function setTilePos(x:int, y:int):void { validateTilePos(); _tileX = x; _tileY = y; _isInvalidWorldPos = true; }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * ImageFactory
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.filters.BevelFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    
    //public 
    class ImageFactory {
        private static var _images:Dictionary;    // 画像を保持する連想配列
        
        public static function getImage(imageName:String):BitmapData {
            return ImageFactory._images[imageName];
        }
        
        // 外部画像のパスをまとめた配列を取得する
        public static function getExternalImagePaths():Dictionary {
            var imagePaths:Dictionary = new Dictionary();
            
            imagePaths["World"] = "http://assets.wonderfl.net/images/related_images/5/5f/5ff7/5ff7c989b7a1068c50a7008713931f651804468c";
            imagePaths["Arrow"] = "http://assets.wonderfl.net/images/related_images/9/90/90ce/90ce1e3f8938a517e1c47d21113e102e5b6a57b0";
            imagePaths["Gatling"] = "http://assets.wonderfl.net/images/related_images/7/70/701a/701ad9fbaa38a010a872676925fac4af33693305";
            imagePaths["Bomb"] = "http://assets.wonderfl.net/images/related_images/a/ab/ab27/ab270254fb43e2f47b8c1229c6e2e951b92de429";
            imagePaths["Missile"] = "http://assets.wonderfl.net/images/related_images/4/43/43f8/43f8fa0a40ee6080d29f0ef32e2c6b7600ce7c7f";
            imagePaths["Frost"] = "http://assets.wonderfl.net/images/related_images/8/86/8639/8639eba0d7f33aa2d1dcc1eb78165ffbb8872f29";
            imagePaths["Vortex"] = "http://assets.wonderfl.net/images/related_images/0/01/016d/016d884b33e407fbcd6cb9df98a117b4cf7550fb";
            imagePaths["Laser"] = "http://assets.wonderfl.net/images/related_images/f/f5/f508/f5082ab1d35ab1b1ee2e74669fe9aaaf923ae9c9";
            
            return imagePaths;
        }
        
        // （内部で作成できる）画像の読み込みを行う
        public static function load():Dictionary {
            ImageFactory._images = new Dictionary();
            
            ImageFactory._images["Base"] = ImageFactory.createTowerBase();
            ImageFactory._images["Cancel"] = ImageFactory.createCancelMark();
            ImageFactory._images["Normal"] = ImageFactory.createNormalEnemy(0xff0000, 0x880000);
            ImageFactory._images["Immune"] = ImageFactory.createNormalEnemy(0xcc00cc, 0x660066);
            ImageFactory._images["Fast"] = ImageFactory.createNormalEnemy(0x4444ff, 0x222288);
            ImageFactory._images["Flying"] = ImageFactory.createFlyingEnemy(0xffcc00, 0x886600);
            
            ImageFactory._images["Bullet_Arrow"] = ImageFactory.createArrowBullet();
            ImageFactory._images["Bullet_Gatling"] = ImageFactory.createNormalBullet(2);
            ImageFactory._images["Bullet_Bomb"] = ImageFactory.createNormalBullet(3);
            ImageFactory._images["Bullet_Missile"] = ImageFactory.createMissileBullet();
            ImageFactory._images["Bullet_Frost"] = ImageFactory.createNormalBullet(2);
            ImageFactory._images["Bullet_Vortex"] = ImageFactory.createNormalBullet(1);
            ImageFactory._images["Bullet_Laser"] = ImageFactory.createArrowBullet();
            
            ImageFactory._images["Coin"] = ImageFactory.createCoin();
            
            return ImageFactory._images;
        }
        
        // タワーの土台の画像を作成する
        private static function createTowerBase():BitmapData {            
            var bitmapData:BitmapData = new BitmapData(32, 32);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(0xc0c0c0);
            sprite.graphics.drawRect(0, 0, 32, 32);
            sprite.graphics.endFill();
            sprite.filters = [new BevelFilter(1, 45, 0xffffff, 1, 0x606060, 1, 8, 8, 255)];
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // キャンセルマークの画像を作成する
        private static function createCancelMark():BitmapData {
            var bitmapData:BitmapData = new BitmapData(32, 32, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.lineStyle(4, 0xff0000);
            sprite.graphics.drawCircle(16, 16, 12);
            sprite.graphics.moveTo(16 + (12 * Math.cos(9 * Math.PI / 8)), 16 + (12 * Math.sin(9 * Math.PI / 8)));
            sprite.graphics.lineTo(16 + (12 * Math.cos(Math.PI / 8)), 16 + (12 * Math.sin(Math.PI / 8)));
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // Normal タイプの敵の画像を作成する
        private static function createNormalEnemy(bodyColor:uint, borderColor:uint):BitmapData {
            var bitmapData:BitmapData = new BitmapData(16, 16, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(bodyColor);
            sprite.graphics.drawRect(4, 2, 4, 12);
            sprite.graphics.drawRect(8, 6, 4, 4);
            sprite.graphics.endFill();
            sprite.filters = [new GlowFilter(borderColor, 1, 2, 2, 255)];
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // Flying タイプの敵の画像を作成する
        private static function createFlyingEnemy(bodyColor:uint, borderColor:uint):BitmapData {
            var bitmapData:BitmapData = new BitmapData(16, 16, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.lineStyle(0, borderColor, 1, true);
            sprite.graphics.beginFill(bodyColor);
            sprite.graphics.moveTo(2, 4);
            sprite.graphics.lineTo(14, 8);
            sprite.graphics.lineTo(2, 12);
            sprite.graphics.lineTo(2, 4);
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        private static function createArrowBullet():BitmapData {
            var bitmapData:BitmapData = new BitmapData(8, 8, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.lineStyle(2);
            sprite.graphics.moveTo(1, 4);
            sprite.graphics.lineTo(7, 4);
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // 普通の弾の画像を作成する
        private static function createNormalBullet(radius:int):BitmapData {
            var bitmapData:BitmapData = new BitmapData(8, 8, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(0x000000);
            sprite.graphics.drawCircle(4, 4, radius);
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        private static function createMissileBullet():BitmapData {
            var bitmapData:BitmapData = new BitmapData(8, 8, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(0x000000);
            sprite.graphics.drawCircle(3, 2, 2);
            sprite.graphics.drawCircle(3, 6, 2);
            sprite.graphics.drawCircle(5, 4, 2);
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // エフェクトのコインの画像を作成する
        private static function createCoin():BitmapData {
            var bitmapData:BitmapData = new BitmapData(8, 8, true, 0x00ffffff);
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(0xcccc00);
            sprite.graphics.drawEllipse(2, 1, 4, 6);
            sprite.graphics.endFill();
            sprite.filters = [new BevelFilter(1, 45, 0xffffff, 1, 0x000000, 1, 0, 0)];
            bitmapData.draw(sprite);
            return bitmapData;
        }
        
        // 普通のテキストを作成する
        public static function createSimpleText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
            return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER);
        }
        
        // 縁取り付きのテキストを作成する
        public static function createBorderedText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint, borderColor:uint):TextField {
            return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER, false, true, borderColor);
        }
        
        // スコア表示用のテキストを作成する
        public static function createScoreText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
            return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.RIGHT, true);
        }
        
        // タワーのステータス表示用テキストを作成する
        public static function createStatusText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint):TextField {
            return ImageFactory.createText(posx, posy, width, height, text, fontSize, textColor, TextFieldAutoSize.CENTER, true);
        }
        
        private static function createText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int, textColor:uint, autoSize:String, bold:Boolean = false, border:Boolean = false, borderColor:uint = 0x000000, embed:Boolean = false):TextField {
            var textField:TextField = new TextField();
            if (embed) {
                textField.embedFonts = true;
                textField.antiAliasType = AntiAliasType.ADVANCED;
            }
            var font:String = embed ? Const.EMBED_FONT : "Arial";
            textField.defaultTextFormat = new TextFormat(font, fontSize, null, bold);
            textField.text = text;
            textField.x = posx;
            textField.y = posy + Math.ceil((height - (textField.textHeight + 4)) / 2);
            textField.width = Math.max(width, textField.textWidth + 4);
            textField.height = textField.textHeight + 4;
            textField.textColor = textColor;
            if (border) { textField.filters = [new GlowFilter(borderColor, 1, 4, 4)]; }
            textField.autoSize = autoSize;
            textField.mouseEnabled = textField.selectable = false;
            return textField;
        }
        
        // 説明用のテキストを作成する
        public static function createInstructionText(posx:int, posy:int, width:int, height:int, text:String, fontSize:int):TextField {
            return ImageFactory.createText(posx, posy, width, height, text, fontSize, 0xffffff, TextFieldAutoSize.LEFT, false, false, 0x000000, Const.USE_FONTLOADER);
        }
        
        // ウインドウを作成する
        public static function createWindow(posx:int, posy:int, width:int, height:int):Sprite {
            var sprite:Sprite = new Sprite();
            sprite.x = posx;
            sprite.y = posy;
            sprite.mouseEnabled = false;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(width, height, Math.PI / 2);
            sprite.graphics.lineStyle(2);
            sprite.graphics.lineGradientStyle(GradientType.LINEAR, [0xf0f0f0, 0x808080], [1, 1], [0, 255], matrix);
            sprite.graphics.beginGradientFill(GradientType.LINEAR, [0x303090, 0x000030], [1, 1], [0, 255], matrix);
            sprite.graphics.drawRoundRect(1, 1, width - 2, height - 2, 10);
            sprite.graphics.endFill();
            return sprite;
        }
    }
//}
/* ----------------------------------------------------------------------------------------------------------------------
 * Config
 * -----------------------------------------------------------------------------------------------------------------------
 */
//package {
    import flash.utils.Dictionary;
    
    //public 
    class Config {
        public static const INITIAL_LIVES:int = 20;
        public static const INITIAL_GOLD:int = 100;
        
        public static const NODE_TYPE:Array = [
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1],
            [1,0,0,0,0,0,0,0,0,0,2,1,1,2,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,1,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1],
            [1,1,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1]
        ];
        
        private static const XML_DATA:XML =
        <root>
            <starts>
                <start x="4"  y="25" width="2" flying="0" />
                <start x="20" y="25" width="2" flying="0" />
                <start x="12" y="25" width="2" flying="1" />
            </starts>
            <goals>
                <goal x="10" y="3" /><goal x="13" y="3" />
                <goal x="10" y="4" /><goal x="11" y="4" />
                <goal x="12" y="4" /><goal x="13" y="4" />
            </goals>
            <tower>
                <type name="Arrow" ground="1" air="1" slow="0" splash="0">
                    <status level="1" cost="8"    damage="10"   range="60"  firerate="1.5" />
                    <status level="2" cost="16"   damage="20"   range="60"  firerate="1.5" />
                    <status level="3" cost="32"   damage="40"   range="60"  firerate="1.5" />
                    <status level="4" cost="64"   damage="80"   range="60"  firerate="1.5" />
                    <status level="5" cost="192"  damage="320"  range="180" firerate="0.8" />
                </type>
                <type name="Gatling" ground="1" air="1" slow="0" splash="0">
                    <status level="1" cost="20"   damage="5"    range="55"  firerate="4.0" />
                    <status level="2" cost="35"   damage="9"    range="60"  firerate="4.3" />
                    <status level="3" cost="65"   damage="17"   range="65"  firerate="4.6" />
                    <status level="4" cost="110"  damage="28"   range="70"  firerate="5.0" />
                    <status level="5" cost="310"  damage="45"   range="80"  firerate="9.9" />
                </type>
                <type name="Bomb" ground="1" air="0" slow="0" splash="1">
                    <status level="1" cost="12"   damage="10"   range="80"  firerate="0.8" />
                    <status level="2" cost="24"   damage="30"   range="88"  firerate="0.8" />
                    <status level="3" cost="52"   damage="60"   range="96"  firerate="0.9" />
                    <status level="4" cost="100"  damage="120"  range="104" firerate="1.0" />
                    <status level="5" cost="240"  damage="300"  range="112" firerate="1.0" />
                </type>        
                <type name="Missile" ground="0" air="1" slow="0" splash="0">
                    <status level="1" cost="25"   damage="15"   range="48"  firerate="3.0" />
                    <status level="2" cost="40"   damage="40"   range="48"  firerate="3.0" />
                    <status level="3" cost="75"   damage="80"   range="64"  firerate="3.0" />
                    <status level="4" cost="130"  damage="150"  range="64"  firerate="3.0" />
                    <status level="5" cost="370"  damage="290"  range="80"  firerate="4.5" />
                </type>        
                <type name="Frost" ground="1" air="1" slow="1" splash="1">
                    <status level="1" cost="50"   damage="10"   range="32"  firerate="1.2" />
                    <status level="2" cost="70"   damage="15"   range="40"  firerate="1.2" />
                    <status level="3" cost="90"   damage="20"   range="48"  firerate="1.2" />
                    <status level="4" cost="120"  damage="25"   range="56"  firerate="1.2" />
                    <status level="5" cost="300"  damage="50"   range="64"  firerate="2.4" />
                </type>        
                <type name="Vortex" ground="1" air="0" slow="0" splash="1">
                    <status level="1" cost="70"   damage="80"   range="42"  firerate="0.6" />
                    <status level="2" cost="130"  damage="150"  range="42"  firerate="0.6" />
                    <status level="3" cost="250"  damage="300"  range="42"  firerate="0.6" />
                    <status level="4" cost="490"  damage="600"  range="42"  firerate="0.7" />
                    <status level="5" cost="990"  damage="990"  range="42"  firerate="1.0" />
                </type>        
                <type name="Laser" ground="1" air="1" slow="0" splash="1">
                    <status level="1" cost="150"  damage="135"  range="80"  firerate="1.1" />
                    <status level="2" cost="270"  damage="255"  range="80"  firerate="1.1" />
                    <status level="3" cost="510"  damage="510"  range="80"  firerate="1.3" />
                    <status level="4" cost="990"  damage="990"  range="80"  firerate="1.5" />
                    <status level="5" cost="2000" damage="2500" range="80"  firerate="1.5" />
                </type>        
            </tower>
            <enemy>
                <type name="Normal" speed="1.0" flying="0" immunity="0" />
                <type name="Immune" speed="0.9" flying="0" immunity="1" />
                <type name="Fast"   speed="1.4" flying="0" immunity="0" />
                <type name="Flying" speed="1.0" flying="1" immunity="0" />
            </enemy>
            <waves>
                <wave type="Normal" HP="20"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="25"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="30"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="40"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="40"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="50"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="70"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="80"   point="8"   money="1"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Flying" HP="70"   point="10"  money="2"  ><spawn num="0"  /><spawn num="0"  /><spawn num="15" /></wave>
                <wave type="Normal" HP="400"  point="50"  money="20" ><spawn num="2"  /><spawn num="2"  /><spawn num="0"  /></wave>
                
                <wave type="Normal" HP="100"  point="10"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="110"  point="10"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="150"  point="10"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="140"  point="10"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Flying" HP="120"  point="12"  money="2"  ><spawn num="0"  /><spawn num="0"  /><spawn num="15" /></wave>
                <wave type="Normal" HP="150"  point="12"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="170"  point="12"  money="2"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="1000" point="60"  money="25" ><spawn num="2"  /><spawn num="2"  /><spawn num="0"  /></wave>
                <wave type="Flying" HP="150"  point="14"  money="3"  ><spawn num="8"  /><spawn num="8"  /><spawn num="0"  /></wave>
                <wave type="Normal" HP="200"  point="12"  money="3"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                
                <wave type="Normal" HP="240"  point="12"  money="3"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="260"  point="12"  money="3"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="300"  point="12"  money="3"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Flying" HP="3200" point="300" money="120"><spawn num="0"  /><spawn num="0"  /><spawn num="1"  /></wave>
                <wave type="Normal" HP="350"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="400"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="450"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="500"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="560"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="610"  point="14"  money="4"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                
                <wave type="Flying" HP="480"  point="14"  money="4"  ><spawn num="0"  /><spawn num="0"  /><spawn num="20" /></wave>
                <wave type="Fast"   HP="4000" point="150" money="80" ><spawn num="1"  /><spawn num="1"  /><spawn num="0"  /></wave>
                <wave type="Normal" HP="650"  point="15"  money="5"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="750"  point="15"  money="5"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="900"  point="15"  money="5"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Flying" HP="800"  point="15"  money="5"  ><spawn num="6"  /><spawn num="6"  /><spawn num="6"  /></wave>
                <wave type="Normal" HP="1000" point="15"  money="5"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="1800" point="30"  money="10" ><spawn num="5"  /><spawn num="5"  /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="1200" point="15"  money="5"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="1800" point="20"  money="6"  ><spawn num="20" /><spawn num="20" /><spawn num="0"  /></wave>
                
                <wave type="Fast"   HP="1500" point="15"  money="7"  ><spawn num="20" /><spawn num="0"  /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="1500" point="15"  money="7"  ><spawn num="0"  /><spawn num="20" /><spawn num="0"  /></wave>
                <wave type="Normal" HP="2200" point="15"  money="7"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="2500" point="15"  money="7"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Flying" HP="1500" point="15"  money="7"  ><spawn num="0"  /><spawn num="0"  /><spawn num="20" /></wave>
                <wave type="Normal" HP="2800" point="15"  money="8"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Fast"   HP="3000" point="15"  money="8"  ><spawn num="10" /><spawn num="10" /><spawn num="0"  /></wave>
                <wave type="Immune" HP="18000"point="200" money="100"><spawn num="1"  /><spawn num="1"  /><spawn num="0"  /></wave>
                <wave type="Normal" HP="24000"point="200" money="100"><spawn num="1"  /><spawn num="1"  /><spawn num="0"  /></wave>
                <wave type="Flying" HP="10000"point="200" money="100"><spawn num="1"  /><spawn num="1"  /><spawn num="1"  /></wave>
            </waves>
        </root>;
        
        // スタート地点の配列を返す
        public static function getStarts():Vector.<Start> {
            var value:Vector.<Start> = new Vector.<Start>();
            for each(var s:XML in Config.XML_DATA.starts.*) {
                value.push(new Start(int(s.@x), int(s.@y), int(s.@width), Boolean(int(s.@flying))));
            }
            return value;
        }
        
        // ゴールの配列を返す
        public static function getGoals():Vector.<Goal> {
            var value:Vector.<Goal> = new Vector.<Goal>();
            for each(var g:XML in Config.XML_DATA.goals.*) {
                value.push(new Goal(int(g.@x), int(g.@y)));
            }
            return value;
        }
        
        // タワーの種類の配列を返す
        public static function getTowerType():Vector.<TowerType> {
            var value:Vector.<TowerType> = new Vector.<TowerType>();
            for each(var t:XML in Config.XML_DATA.tower.*) {
                value.push(new TowerType(t.@name, Boolean(int(t.@ground)), Boolean(int(t.@air)), Boolean(int(t.@slow)), Boolean(int(t.@splash))));
            }
            return value;
        }
        
        // 引数で指定した種類の、ステータスの配列を返す
        public static function getTowerStatus(towerTypeName:String):Vector.<TowerStatus> {
            var value:Vector.<TowerStatus> = new Vector.<TowerStatus>();
            for each(var s:XML in Config.XML_DATA.tower.*.(@name == towerTypeName).*) {
                value.push(new TowerStatus(int(s.@level), int(s.@cost), int(s.@damage), int(s.@range), Number(s.@firerate)));
            }
            //value.sortOn("level", Array.NUMERIC);
            return value;
        }
        
        // 敵の種類の連想配列を返す
        public static function getEnemyType():Dictionary {
            var value:Dictionary = new Dictionary();
            for each(var e:XML in Config.XML_DATA.enemy.*) {
                var typeName:String = e.@name;
                value[typeName] = new EnemyType(typeName, Number(e.@speed), Boolean(int(e.@flying)), Boolean(int(e.@immunity)));
            }
            return value;
        }
        
        // ウェーブの配列を返す
        public static function getWaves():Vector.<Wave> {
            var waveNumber:int = 1;
            var value:Vector.<Wave> = new Vector.<Wave>();
            for each(var w:XML in Config.XML_DATA.waves.*) {
                var spawn:Vector.<int> = new Vector.<int>();
                for each(var s:XML in w.*) { spawn.push(int(s.@num)); }
                value.push(new Wave(waveNumber, EnemyType.getType(String(w.@type)), int(w.@HP), int(w.@point), int(w.@money), spawn));
                waveNumber++;
            }
            return value;
        }
    }
//}