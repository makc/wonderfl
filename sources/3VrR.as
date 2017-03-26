package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.utils.Timer;
    import net.user1.logger.Logger;
    import net.user1.reactor.Reactor;
    import net.wonderfl.utils.WonderflAPI;
/*    import ore.orelib.assets.Artist;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.Chat;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.Input;
    import ore.orelib.commons.Preloader;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.commons.TileSheet;
    import ore.orelib.commons.UnionStats;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.scenes.IScene;
    import ore.orelib.scenes.TitleScene;
*/    
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "0x000000")]
    public class Main extends Sprite {
        private var _reactor:Reactor;
        
        private var _fps:int;
        private var _fpsLabel:TextField;
        private var _fpsCount:int;
        private var _fpsTimer:Timer;
        
        private var _api:WonderflAPI;
        private var _scene:IScene;
        private var _timestamp:Number;
        
        private var _chat:Chat;
        private var _stats:UnionStats;
        
        private static const SERVER_HOST:String = "tryunion.com";
        private static const SERVER_PORT:int = 80;
        
        public function Main() {
            // Reactorの初期設定
            _reactor = new Reactor();
            _reactor.disableHTTPFailover();
            _reactor.getConnectionMonitor().setHeartbeatFrequency(2000);
            _reactor.getConnectionMonitor().setConnectionTimeout(10000);
            //_reactor.getConnectionMonitor().setAutoReconnectFrequency(20000);
            _reactor.getLog().setLevel(Logger.FATAL);
            
            // Reactor接続、各アセット読み込み
            var preloader:Preloader = new Preloader(this);
            _api = new WonderflAPI(root.loaderInfo.parameters, root.loaderInfo.url.substring(root.loaderInfo.url.lastIndexOf("/") + 1, root.loaderInfo.url.lastIndexOf(".")));
            preloader.addReactorConnectionRequest(_reactor, Main.SERVER_HOST, Main.SERVER_PORT);
            preloader.addLoaderRequest(Const.IMAGE_URL);
            preloader.addFontLoaderRequest(Const.FONT);
            preloader.addEventListener(Event.COMPLETE, initialize);
            preloader.load(_api.appID);
        }
        
        private function initialize(event:Event):void {
            var preloader:Preloader = event.currentTarget as Preloader;
            preloader.removeEventListener(event.type, arguments.callee);
            //Wonderfl.log(_reactor.getSystem().getClientVersion());
            
            // 画像アセットの登録
            var sheet:TileSheet = new TileSheet(preloader.loaders[Const.IMAGE_URL]);
            Assets.images["characters"] = sheet.blit(new Rectangle(0, 0, 16, 16), 3, 11);
            Assets.images["weapons"] = sheet.blit(new Rectangle(48, 0, 32, 24), 3, 5);
            Assets.images["background"] = Artist.createBackground();
            Assets.images["actorShadow"] = Artist.createActorShadow();
            Assets.images["muzzleFlashes"] = Artist.createMuzzleFlashes(10);
            Assets.images["tirofinale"] = Artist.createTirofinaleFire();
            Assets.images["explosions"] = Artist.createExplosions(10);
            Assets.images["impacts"] = Artist.createImpacts(5);
            Assets.images["bloods"] = Artist.createBloods(20);
            Assets.images["damagedScreen"] = Artist.createDamagedScreen();
            Assets.images["madoCircle"] = Artist.createMadoCircle();
            
            // 静的クラスの初期化
            Input.setup(stage);
            GeomPool.setup(5);
            
            // fps,pingの計測
            _fps = 30;
            _fpsLabel = new TextBuilder().align(TextBuilder.RIGHT)
                .fontColor(0xFFFFFF).pos(400, 0).size(65, 20).build("30:-1");
            _fpsCount = 0;
            _fpsTimer = new Timer(1000, 0);
            _fpsTimer.addEventListener(TimerEvent.TIMER, updateFPS);
            _fpsTimer.start();
            
            _stats = new UnionStats(_reactor);
            _scene = new TitleScene(this);
            _timestamp = _reactor.getServer().getServerTime();
            
            stage.addChild(_chat = createChat());
            stage.addChild(_fpsLabel);
            
            _stats.x = 465 - _stats.width;
            if (SaveData.instance.stats) {
                stage.addChild(stats);
            } else {
                _stats.disable();
            }
            
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function updateFPS(event:TimerEvent):void {
            _fps = _fpsCount;
            _fpsLabel.text = _fps + " : " + ((_reactor.self()) ? _reactor.self().getPing() : -1);
            _fpsCount = 0;
        }
        
        private function createChat():Chat {
            var result:Chat = new Chat(_reactor, String(_api.appID) + ".c");
            result.x = 233;
            result.changeName(SaveData.instance.player.name);
            return result;
        }
        
        private function update(event:Event):void {
            var serverTime:Number = _reactor.getServer().getServerTime();
            
            _fpsCount++;
            _scene.update(serverTime, Math.max(0, serverTime - _timestamp));
            _timestamp = serverTime;
            
            Input.record();
        }
        
        public function changeScene(scene:IScene):void { _scene = scene; }
        public function get reactor():Reactor { return _reactor; }
        public function get fps():int { return _fps; }
        public function get api():WonderflAPI { return _api; }
        public function get chat():Chat { return _chat; }
        public function get stats():UnionStats { return _stats; }
    }
}
//package ore.orelib.scenes {
    import flash.events.IEventDispatcher;
    
    //public 
    interface IScene extends IEventDispatcher {
        function update(serverTime:Number, elapsedTime:int):void;
    }
//}
//package ore.orelib.scenes {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import net.user1.reactor.ReactorEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.RoomManagerEvent;
    import net.user1.reactor.UpdateLevels;
/*    import ore.orelib.assets.Artist;
    import ore.orelib.assets.CharacterSelectionWindow;
    import ore.orelib.assets.InfoWindow;
    import ore.orelib.assets.InstructionWindow;
    import ore.orelib.assets.InventoryWindow;
    import ore.orelib.assets.SettingsWindow;
    import ore.orelib.assets.StatusWindow;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
*/    
    //public 
    class TitleScene extends Sprite implements IScene {
        private var _main:Main;
        
        private var _statusWindow:StatusWindow;
        private var _inventoryWindow:InventoryWindow;
        private var _infoWindow:InfoWindow;
        private var _howToPlayWindow:InstructionWindow;
        private var _FAQWindow:InstructionWindow;
        private var _historyWindow:InstructionWindow;
        private var _characterSelectionWindow:CharacterSelectionWindow;
        private var _settingsWindow:SettingsWindow;
        
        private var _joinButtons:Vector.<PushButton>;
        private var _howToPlayButton:PushButton;
        private var _FAQButton:PushButton;
        private var _historyButton:PushButton;
        private var _selectCharacterButton:PushButton;
        private var _settingsButton:PushButton;
        
        private var _numRooms:int;
        private var _maxClients:Array;
        
        public function TitleScene(main:Main) {
            _main = main;
            _main.addChild(this);
            if (_main.api.appID == "3VrR") {
                _numRooms = 30;
                _maxClients = [
                    80, 40, 36, 32, 28,
                    24, 20, 16, 12, 10,
                    8, 8, 8, 8, 8,
                    8, 8, 8, 8, 8,
                    5, 5, 5, 5, 5,
                    5, 5, 5, 5, 5
                ];
            } else {
                _numRooms = 1;
                _maxClients = [8];
            }
            
            var id:String = (_main.reactor.isReady()) ? _main.reactor.self().getClientID() : "0";
            addChild(_statusWindow = new StatusWindow(5, 110, id));
            _statusWindow.addEventListener(Event.CHANGE, changeName);
            _inventoryWindow = new InventoryWindow(210, 66, new Rectangle( -210, 44, 465, 355));
            _inventoryWindow.addEventListener(Event.CHANGE, _statusWindow.update);
            addChild(_infoWindow = new InfoWindow(5, 443));
            _howToPlayWindow = new InstructionWindow(Const.HOWTOPLAY_TEXTS);
            _FAQWindow = new InstructionWindow(Const.FAQ_TEXTS);
            _historyWindow = new InstructionWindow(Const.HISTORY_TEXTS);
            
            _characterSelectionWindow = new CharacterSelectionWindow();
            _characterSelectionWindow.addEventListener(Event.CHANGE, _statusWindow.update);
            _settingsWindow = new SettingsWindow(_main.stats);
            
            _joinButtons = new Vector.<PushButton>(_numRooms, true);
            for (var i:int = 0; i < _numRooms; i++) {
                addChild(_joinButtons[i] = Artist.createPushButtonWithDeviceFont(
                    46 * (i % 5) + 1,
                    18 * int(i / 5) + 1,
                    (i + 1) + "(0/0)",
                    startPlaying
                ));
                _joinButtons[i].width = 46;
                _joinButtons[i].height = 18;
                if (i > 0) { _joinButtons[i].enabled = false; }
            }
            addChild(_howToPlayButton = Artist.createPushButtonWithDeviceFont(7, 393, "あそび方", showInstructionWindow));
            addChild(_FAQButton = Artist.createPushButtonWithDeviceFont(73, 393, "よくある質問", showFAQWindow));
            addChild(_historyButton = Artist.createPushButtonWithDeviceFont(139, 393, "更新履歴", showHistoryWindow));
            _howToPlayButton.width = _FAQButton.width = _historyButton.width = 64;
            _howToPlayButton.draw(); _FAQButton.draw(); _historyButton.draw();
            
            addChild(_selectCharacterButton = Artist.createPushButtonWithDeviceFont(7, 415, "キャラクター変更", showCharacterSelectionWindow));
            addChild(_settingsButton = Artist.createPushButtonWithDeviceFont(106, 415, "オプション (options)", showSettingsWindow));
            _selectCharacterButton.width = _settingsButton.width = 97;
            _selectCharacterButton.draw(); _settingsButton.draw();
            
            addChild(_inventoryWindow);
            
            _main.reactor.addEventListener(ReactorEvent.READY, enableToJoin);
            _main.reactor.addEventListener(ReactorEvent.CLOSE, disableToJoin);
            (_main.reactor.isReady()) ? enableToJoin() : disableToJoin();
        }
        
        private function changeName(event:Event):void { _main.chat.changeName(SaveData.instance.player.name); }
        private function showInstructionWindow(event:MouseEvent):void { addChild(_howToPlayWindow); }
        private function showFAQWindow(event:MouseEvent):void { addChild(_FAQWindow); }
        private function showHistoryWindow(event:MouseEvent):void { addChild(_historyWindow); }
        private function showSettingsWindow(event:MouseEvent):void { addChild(_settingsWindow); }
        private function showCharacterSelectionWindow(event:MouseEvent):void { addChild(_characterSelectionWindow); }
        
        private function startPlaying(event:MouseEvent):void {
            var roomNo:int = _joinButtons.indexOf(event.currentTarget as PushButton);
            // 各リスナの削除
            _main.reactor.removeEventListener(ReactorEvent.READY, enableToJoin);
            _main.reactor.removeEventListener(ReactorEvent.CLOSE, disableToJoin);
            for (var i:int = 0; i < _numRooms; i++) {
                var room:Room = _main.reactor.getRoomManager().getRoom(String(_main.api.appID) + ".g." + UPCConv.toCode(i));
                if (room) {
                    room.removeEventListener(RoomEvent.OCCUPANT_COUNT, roomClientCountHandler);
                    room.stopObserving();
                }
            }
            _main.reactor.getRoomManager().stopWatchingForRooms(String(_main.api.appID) + ".g");
            _main.reactor.getRoomManager().removeEventListener(RoomManagerEvent.ROOM_ADDED, roomAddedHandler);
            
            _main.removeChild(this);
            _main.changeScene(new PlayingScene(_main, roomNo));
        }
        
        /** サーバーと正常に接続されている場合に、ゲーム参加を可能する */
        private function enableToJoin(event:ReactorEvent = null):void {
            _main.reactor.getRoomManager().watchForRooms(String(_main.api.appID) + ".g");
            _main.reactor.getRoomManager().addEventListener(RoomManagerEvent.ROOM_ADDED, roomAddedHandler);
            
            for (var i:int = 0; i < _numRooms; i++) {
                _joinButtons[i].label = (i + 1) + "(0/" + _maxClients[i] + ")";
            }
        }
        
        /** 新しい部屋が作成されたら監視する */
        private function roomAddedHandler(event:RoomManagerEvent):void {
            var room:Room = event.getRoom();
            var roomID:int = UPCConv.toInt(room.getSimpleRoomID());
            if (room.getQualifier() != String(_main.api.appID) + ".g" || roomID >= _numRooms) { return; }
            
            // 部屋の参加人数のみを監視する
            var updateLevels:UpdateLevels = new UpdateLevels();
            updateLevels.clearAll();
            updateLevels.occupantCount = true;
            room.addEventListener(RoomEvent.OCCUPANT_COUNT, roomClientCountHandler, false, 0, true);
            room.observe(String(_main.api.apiKey), updateLevels);
        }
        
        /** 参加者人数が変わったら更新する */
        private function roomClientCountHandler(event:RoomEvent):void {
            for (var i:int = 0; i < _numRooms; i++) {
                var roomID:String = String(_main.api.appID) + ".g." + UPCConv.toCode(i);
                var numClients:int = 0;
                if (_main.reactor.getRoomManager().roomIsKnown(roomID)) {
                    numClients = _main.reactor.getRoomManager().getRoom(roomID).getNumOccupants();
                }
                _joinButtons[i].label = (i + 1) + "(" + numClients + "/" + _maxClients[i] + ")";
                _joinButtons[i].enabled = (_main.reactor.isReady() && numClients < _maxClients[i]);
            }
        }
        
        /** サーバーとの接続が切れた場合に、ゲーム参加不能にする */
        private function disableToJoin(event:ReactorEvent = null):void {
            for (var i:int = 0; i < _numRooms; i++) {
                _joinButtons[i].enabled = false;
                _joinButtons[i].label = "connecting...";
            }
        }
        
        public function update(serverTime:Number, elapsedTime:int):void { }
    }
//}
//package ore.orelib.scenes {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.system.IME;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomSettings;
    import net.user1.reactor.UpdateLevels;
/*    import ore.orelib.actors.EffectManager;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.actors.FriendManager;
    import ore.orelib.assets.PlayingView;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
    import ore.orelib.logic.Host;
    import ore.orelib.logic.Player;
*/    
    //public 
    class PlayingScene extends Sprite implements IScene {
        private var _main:Main;
        private var _room:Room;
        private var _view:PlayingView;
        
        private var _player:Player;
        private var _host:Host;
        private var _friends:FriendManager;
        private var _enemies:EnemyManager;
        private var _effects:EffectManager;
        
        private var _isActive:Boolean;
        
        public function PlayingScene(main:Main, roomNo:int) {
            _main = main;
            _main.addChild(this);
            
            var roomSettings:RoomSettings = new RoomSettings();
            roomSettings.password = String(_main.api.apiKey);
            _room = _main.reactor.getRoomManager().createRoom(String(_main.api.appID) + ".g." + UPCConv.toCode(roomNo), roomSettings);
            
            addChild(_view = new PlayingView());
            _friends = new FriendManager(_room);
            _enemies = new EnemyManager(_room);
            _effects = new EffectManager(_view);
            
            _player = new Player(_room, _main.reactor.self());
            _host = new Host(_room, _main);
            _view.setupHUD(_player, roomNo);
            
            _isActive = true;
            addEventListener(Event.ACTIVATE, onActivate);
            addEventListener(Event.DEACTIVATE, onDeactivate);
            
            stage.focus = null;
            IME.enabled = false;
            addEventListener(MouseEvent.MOUSE_DOWN, disableIME);
            
            _room.join(String(_main.api.apiKey), new UpdateLevels());
        }
        
        private function onActivate(event:Event):void { _isActive = true; }
        private function onDeactivate(event:Event):void { _isActive = false; }
        private function disableIME(event:MouseEvent):void { IME.enabled = false; }
        
        public function update(serverTime:Number, elapsedTime:int):void {
            var isControllable:Boolean = (_isActive && stage.focus == null);
            _player.update(elapsedTime, _enemies, isControllable);
            _friends.update(elapsedTime);
            _enemies.update(serverTime, elapsedTime, _host.isHost);
            _effects.update();
            _host.update(serverTime, elapsedTime, _enemies);
            
            _view.update(_player, _host);
            
            // 接続が切れるか、バックグランド動作に入ったら強制退出
            // QBの契約ノルマが達成されたら（正常な）ゲームオーバー
            if (!_main.reactor.isReady() || (_room.clientIsInRoom() && _main.fps < 5) || !_player.isValid) {
                exit();
                _main.changeScene(new ResultScene(_main, _view, _host.wave, _player.killCount, _player.isValid, _player.luc, false));
            } else if (_room.clientIsInRoom() && _host.numContracts >= Const.FIELD_QB_QUOTA) {
                exit();
                _main.changeScene(new ResultScene(_main, _view, _host.wave, _player.killCount, _player.isValid, _player.luc, true));
            }
        }
        
        private function exit():void {
            _room.leave();
            
            _player.removeEventListeners();
            _host.removeEventListeners();
            _view.removeEventListeners();
            _friends.removeEventListeners();
            _enemies.removeEventListeners();
            _effects.removeEventListeners();
            
            removeEventListener(Event.ACTIVATE, onActivate);
            removeEventListener(Event.DEACTIVATE, onDeactivate);
            
            _main.removeChild(this);
        }
    }
//}
//package ore.orelib.scenes {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
/*    import ore.orelib.assets.Artist;
    import ore.orelib.assets.InventoryWindow;
    import ore.orelib.assets.PlayingView;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerData;
    import ore.orelib.data.SaveData;
    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class ResultScene extends Sprite implements IScene {
        private var _main:Main;
        private var _gameoverDisplay:Sprite;
        private var _newWeaponDisplay:Sprite;
        
        public function ResultScene(main:Main, view:PlayingView, wave:int, killCount:int, isValid:Boolean, luc:int, willGetNewWeapon:Boolean) {
            _main = main;
            _main.addChild(this);
            addChild(view);
            addChild(createBackground());
            
            var exp:int = (isValid) ? killCount : 0;
            var isPlayerLevelup:Boolean = gainExperience(exp);
            if (willGetNewWeapon) {
                SaveData.instance.inventory[12] = WeaponSmith.createWeaponData(
                    SaveData.instance.player.level, wave, exp, luc
                );
            }
            SaveData.instance.flush();
            
            _gameoverDisplay = createGameoverDisplay(wave, killCount, isPlayerLevelup, willGetNewWeapon);
            _newWeaponDisplay = createNewWeaponDisplay();
            addChild(_gameoverDisplay);
        }
        
        private function createBackground():Sprite {
            var result:Sprite = new Sprite();
            result.graphics.beginFill(0x000000, 0.8);
            result.graphics.drawRect(0, 0, 465, 465);
            result.graphics.endFill();
            return result;
        }
        
        private function gainExperience(killCount:int):Boolean {
            var isPlayerLevelup:Boolean = false;
            var playerData:PlayerData = SaveData.instance.player;
            playerData.next = Math.max(-10000, playerData.next - killCount);
            
            // レベルアップ
            if (playerData.next <= 0 && Const.EXP_TABLE[playerData.level]) {
                playerData.next = Const.EXP_TABLE[playerData.level];
                playerData.level++;
                playerData.statusPoints++;
                isPlayerLevelup = true;
            }
            
            return isPlayerLevelup;
        }
        
        private function createGameoverDisplay(wave:int, killCount:int, isPlayerLevelup:Boolean, gotNewWeapon:Boolean):Sprite {
            var result:Sprite = new Sprite();
            
            if (gotNewWeapon) {
                result.addChild(Artist.createPushButtonWithDeviceFont(66, 45, "武器入手画面へ", showNewWeaponDisplay));
            } else {
                result.addChild(Artist.createPushButtonWithDeviceFont(66, 45, "タイトル画面に戻る", backToTitle));
            }
            
            var gameoverReason:String = (gotNewWeapon)
                ? "QBがノルマを達成しちゃいました！\nこの世界は破滅です。"
                : "この世界から離脱しました。";
            gameoverReason += "\n\n";
            gameoverReason += "到達Wave: " + wave + "\n";
            gameoverReason += "QB撃退数: " + killCount + "\n";
            result.addChild(
                new TextBuilder().align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(24)
                .pos(0, 150).size(465, 200).build(gameoverReason)
            );
            
            var bulider:TextBuilder = new TextBuilder().align(TextBuilder.CENTER)
                .filters([new GlowFilter(0xFFFF88, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0x888800).fontSize(24)
                .size(465, 100);
            var posY:int = 300;
            if (isPlayerLevelup) {
                result.addChild(bulider.pos(0, posY).build("レベルアップ！！"));
                posY += 30;
            }
            if (gotNewWeapon) {
                result.addChild(bulider.pos(0, posY).build("新しい武器を入手しました！！"));
            }
            
            return result;
        }
        
        private function createNewWeaponDisplay():Sprite {
            var result:Sprite = new Sprite();
            
            result.addChild(
                new TextBuilder().align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFF0000).fontSize(12)
                .pos(0, 15).size(232, 30).build("タイトル画面に戻ると、\n入手武器欄にある武器は破棄されます。")
            );
            
            result.addChild(Artist.createPushButtonWithDeviceFont(66, 60, "タイトル画面に戻る", backToTitle));
            
            result.addChild(new InventoryWindow(108, 91, new Rectangle( -108, 20, 465, 354), _main.reactor.isReady()));
            
            return result;
        }
        
        private function showNewWeaponDisplay(event:MouseEvent):void {
            removeChild(_gameoverDisplay);
            addChild(_newWeaponDisplay);
        }
        
        private function backToTitle(event:MouseEvent):void {
            _main.removeChild(this);
            _main.changeScene(new TitleScene(_main));
        }
        
        public function update(serverTime:Number, elapsedTime:int):void { }
    }
//}
//package ore.orelib.logic {
    import flash.display.BitmapData;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Room;
/*    import ore.orelib.actors.Enemy;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.actors.Friend;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.Input;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerData;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.SaveData;
    import ore.orelib.data.Weapon;
    import ore.orelib.events.ActorEvent;
    import ore.orelib.events.EffectEvent;
    import ore.orelib.events.KillEvent;
*/    
    //public 
    class Player {
        private var _room:Room;
        private var _self:IClient;
        // プレイヤーのステータス・装備
        private var _status:PlayerStatus;
        private var _equip:PlayerEquipment;
        private var _hp:int;
        private var _maxHp:int;
        private var _invincibleCount:int;
        private var _recoverCount:int;
        private var _recoverTime:int;
        private var _gasCount:int; // 仁美の毒ガス用
        private var _isValid:Boolean;
        // プレイヤーのビュー
        private var _view:Friend;
        private var _viewBitmapData:BitmapData;
        private var _viewHighlight:BitmapData;
        private var _playerBounds:Rectangle;
        private var _attrPosition:Point;
        private var _sendCount:int;
        // 撃退数
        private var _killCount:int;
        
        private static const HIGHLIGHT:GlowFilter = new GlowFilter(0x00FFFF, 1, 4, 4, 4, 1, false, true);
        
        public function Player(room:Room, self:IClient) {
            _room = room;
            _self = self;
            
            SaveData.instance.validate();
            var playerData:PlayerData = SaveData.instance.player;
            var primary:Weapon = WeaponSmith.createWeaponFrom(SaveData.instance.inventory[0]);
            var secondary:Weapon = WeaponSmith.createWeaponFrom(SaveData.instance.inventory[1]);
            
            _status = Calculator.playerStatus(playerData.status, primary, secondary);
            _equip = new PlayerEquipment(primary, secondary);
            _maxHp = _status.vit;
            _hp = _maxHp;
            _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
            _recoverCount = 0;
            _recoverTime = Calculator.recoverTime(_status.vit, SaveData.instance.player.characterID);
            _gasCount = 0;
            _isValid = true;
            EventManager.instance.addEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
            
            var speed:int = Calculator.speed(_status);
            _attrPosition = new Point(Const.FIELD_SIZE, Const.FIELD_SIZE * Math.random());
            _view = new Friend(
                playerData.name,
                speed,
                _maxHp,
                playerData.characterID,
                _attrPosition.x,
                _attrPosition.y,
                _hp,
                primary.id
            );
            _self.setAttribute(Friend.ATTR_STATUS, playerData.name + "," + UPCConv.toCode((speed << 16) + (_maxHp << 6) + playerData.characterID));
            _self.setAttribute(Friend.ATTR_POS, UPCConv.toCode((int(_attrPosition.x.toFixed(0)) << 9) + int(_attrPosition.y.toFixed(0))));
            _self.setAttribute(Friend.ATTR_HP, UPCConv.toCode(_hp));
            _self.setAttribute(Friend.ATTR_WEAPON, UPCConv.toCode(primary.id));
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, _view, _view.overlay));
            _viewBitmapData = new BitmapData(465, 465, true, 0x00FFFFFF);
            _viewHighlight = new BitmapData(96, 96, true, 0x00FFFFFF);
            _playerBounds = new Rectangle(
                _view.x - Const.PLAYER_BOUNDS_HALF_WIDTH,
                _view.y - Const.PLAYER_BOUNDS_HEIGHT,
                Const.PLAYER_BOUNDS_HALF_WIDTH * 2,
                Const.PLAYER_BOUNDS_HEIGHT
            );
            _sendCount = Const.PLAYER_SEND_INTERVAL;
            
            _killCount = 0;
            EventManager.instance.addEventListener(KillEvent.KILL, onKillEnemy);
        }
        
        private function godBlessHandler(event:EffectEvent):void {
            var blessBounds:Rectangle = GeomPool.rectangle(event.x - 48, event.y - 64, 96, 96);
            if (
                _hp > 0 &&
                _playerBounds.top < blessBounds.bottom &&
                _playerBounds.bottom > blessBounds.top &&
                _playerBounds.left < blessBounds.right &&
                _playerBounds.right > blessBounds.left
            ) {
                _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
                _view.beBlessed();
            }
        }
        
        private function onKillEnemy(event:KillEvent):void {
            _room.setAttribute(event.enemyID + "." + Enemy.ATTR_STATUS, "," + UPCConv.toCode(0));
            _killCount++;
        }
        
        private function changeHp(value:int):void {
            if (value <= 0) {
                _invincibleCount = _recoverTime;
                _recoverCount = _recoverTime;
                if (Calculator.gas()) { _gasCount = Const.PLAYER_GAS_INTERVAL; }
            } else if (value < _hp) {
                _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_DAMAGED;
            }
            
            _hp = Math.max(0, value);
            _view.changeHp(_hp);
            _self.setAttribute(Friend.ATTR_HP, UPCConv.toCode(_hp));
        }
        
        public function update(elapsedTime:int, enemies:EnemyManager, isControllable:Boolean):void {
            _equip.update(elapsedTime);
            
            if (_invincibleCount > 0) { _invincibleCount -= elapsedTime; }
            if (_recoverCount > 0) {
                _recoverCount -= elapsedTime;
                if (_recoverCount <= 0) {
                    changeHp(_maxHp);
                    _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
                    _gasCount = 0;
                }
            }
            
            if (isControllable) { processInput(elapsedTime, enemies); }
            
            _view.update(elapsedTime);
            _sendCount -= elapsedTime;
            if (_sendCount < 0) {
                _sendCount = Const.PLAYER_SEND_INTERVAL;
                if (Math.abs(_view.x - _attrPosition.x) > 8 || Math.abs(_view.y - _attrPosition.y) > 8) {
                    _attrPosition.x = _view.x;
                    _attrPosition.y = _view.y;
                    _self.setAttribute(Friend.ATTR_POS, UPCConv.toCode((int(_attrPosition.x.toFixed(0)) << 9) + int(_attrPosition.y.toFixed(0))));
                }
            }
            
            var collidingEnemies:Vector.<Enemy> = enemies.acquireCollidingEnemies(_playerBounds);
            if (_invincibleCount <= 0) {
                if (collidingEnemies.length > 0) {
                    changeHp(_hp - Calculator.enemyStr(collidingEnemies[0].str));
                    if (Calculator.counter()) { collidingEnemies[0].damaged(_room, 44444, 0); }
                    EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DAMAGED_PLAYER));
                }
            } else if (_gasCount > 0) {
                _gasCount -= elapsedTime;
                if (_gasCount <= 0) {
                    _gasCount = Const.PLAYER_GAS_INTERVAL;
                    for (var i:int = collidingEnemies.length - 1; i >= 0; i--) {
                        var enemy:Enemy = collidingEnemies[i];
                        enemy.damaged(_room, 100 + int(enemy.hp / 8), 0);
                    }
                    _room.sendMessage(Friend.MESSAGE_GAS, false, null);
                    EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.EMIT_GAS, _view.x, _view.y));
                }
            }
            
            validate();
        }
        
        private function processInput(elapsedTime:int, enemies:EnemyManager):void {
            if (_recoverCount > 0) { return; }
            move(elapsedTime);
            if (_equip.isSwapping()) { return; }
            if (Input.key.isPressed(Input.C)) {
                _equip.swap();
                _view.swapWeapon(_equip.currentWeapon.id);
                _self.setAttribute(Friend.ATTR_WEAPON, UPCConv.toCode(_equip.currentWeapon.id));
                return;
            }
            if (_equip.isReloading()) { return; }
            if (Input.key.isPressed(Input.X) && !_equip.isAmmoFull()) {
                _equip.reload(_status);
                return;
            }
            if (Input.key.isDown(Input.Z)) {
                if (_equip.isAmmoEmpty()) {
                    _equip.reload(_status);
                } else if (_equip.canAttack()) {
                    var carry:int = _equip.attack(_room, _view.x, _view.y, _hp / _maxHp, _status, enemies);
                    _view.attack();
                    _room.sendMessage(
                        Friend.MESSAGE_ATTACK, false, null,
                        UPCConv.toCode((Calculator.range(_equip.currentWeapon) << 9) + carry)
                    );
                    EventManager.instance.dispatchEvent(new EffectEvent(
                        EffectEvent.ATTACK_WEAPON,
                        _view.x, _view.y,
                        { 
                            id: _equip.currentWeapon.id,
                            range: Calculator.range(_equip.currentWeapon),
                            carry: carry,
                            bySelf: true
                        }
                    ));
                }
            }
        }
        
        private function move(elapsedTime:int):void {
            var delta:Number = _view.speed * elapsedTime / 1000;
            var velocity:Point = GeomPool.point(0, 0);
            
            if (Input.key.isDown(Keyboard.LEFT)) { velocity.x -= delta; }
            if (Input.key.isDown(Keyboard.RIGHT)) { velocity.x += delta; }
            if (Input.key.isDown(Keyboard.UP)) { velocity.y -= delta; }
            if (Input.key.isDown(Keyboard.DOWN)) { velocity.y += delta; }
            
            if (velocity.x || velocity.y) {
                velocity.normalize(delta);
                _view.moveTo(
                    Math.min(Math.max(0, _view.x + velocity.x), Const.FIELD_SIZE),
                    Math.min(Math.max(0, _view.y + velocity.y), Const.FIELD_SIZE),
                    true
                );
                _playerBounds.x = _view.x - Const.PLAYER_BOUNDS_HALF_WIDTH;
                _playerBounds.y = _view.y - Const.PLAYER_BOUNDS_HEIGHT;
            }
        }
        
        private function validate():void {
            if (_status.str > 200 || _status.vit > 200 || _status.dex > 200 || _status.luc > 250 ||
                _hp > 200 || _maxHp > 200 || _hp > _maxHp || _hp > _status.vit || _maxHp > _status.vit ||
                _invincibleCount > _recoverTime
            ) {
                _isValid = false;
            }
        }
        
        public function drawHighlight(target:BitmapData):void {
            if (!SaveData.instance.highlight) { return; }
            
            _viewBitmapData.fillRect(GeomPool.rectangle(0, 0, 465, 465), 0x00FFFFFF);
            _view.drawBody(_viewBitmapData, GeomPool.colorTransform());
            var drawPos:Point = GeomPool.point(
                int(_view.x - 48 + Const.FIELD_OFFSET_X),
                int(_view.y - 64 + Const.FIELD_OFFSET_Y)
            );
            _viewHighlight.applyFilter(
                _viewBitmapData,
                GeomPool.rectangle(drawPos.x, drawPos.y, 96, 96),
                GeomPool.point(0, 0),
                Player.HIGHLIGHT
            );
            target.copyPixels(
                _viewHighlight,
                GeomPool.rectangle(0, 0, 96, 96),
                GeomPool.point(drawPos.x, drawPos.y),
                null, null, true
            );
        }
        
        public function removeEventListeners():void {
            EventManager.instance.removeEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
            EventManager.instance.removeEventListener(KillEvent.KILL, onKillEnemy);
        }
        
        public function get characterID():int { return SaveData.instance.player.characterID; }
        public function get hp():int { return _hp; }
        public function get maxHp():int { return _maxHp; }
        public function get hpRate():Number { return _hp / _maxHp; }
        public function get ammo():int { return _equip.currentWeaponAmmo; }
        public function get maxAmmo():int { return _equip.currentWeaponMaxAmmo; }
        public function get hpGaugeRate():Number {
            return (_recoverCount > 0) ? 1 - (_recoverCount / _recoverTime) : _hp / _maxHp;
        }
        public function get ammoGaugeRate():Number { return _equip.ammoGaugeRate; }
        public function get killCount():int { return _killCount; }
        public function get isValid():Boolean { return _isValid; }
        public function get luc():int { return _status.luc; }
    }
//}
//package ore.orelib.logic {
    import net.user1.reactor.Room;
/*    import ore.orelib.actors.EnemyManager;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.Weapon;
*/    
    //public 
    class PlayerEquipment {
        private var _currentWeapon:Weapon;
        private var _currentWeaponMaxAmmo:int;
        private var _currentWeaponAmmo:int;
        private var _theOtherWeapon:Weapon;
        private var _theOtherWeaponMaxAmmo:int;
        private var _theOtherWeaponAmmo:int;
        
        private var _attackCount:int;
        private var _reloadCount:int;
        private var _swapCount:int;
        
        private var _reloadTime:int;
        
        public function PlayerEquipment(primary:Weapon, secondary:Weapon) {
            _currentWeapon = primary;
            _currentWeaponMaxAmmo = Calculator.maxAmmo(primary);
            _currentWeaponAmmo = _currentWeaponMaxAmmo;
            _theOtherWeapon = secondary;
            _theOtherWeaponMaxAmmo = Calculator.maxAmmo(secondary);
            _theOtherWeaponAmmo = _theOtherWeaponMaxAmmo;
            
            _attackCount = _reloadCount = _swapCount = 0;
            _reloadTime = 1;
        }
        
        public function update(elapsedTime:int):void {
            if (_attackCount > 0) {
                _attackCount -= elapsedTime;
            }
            
            if (_reloadCount > 0) {
                _reloadCount -= elapsedTime;
                if (_reloadCount <= 0) { _currentWeaponAmmo = _currentWeaponMaxAmmo; }
            }
            
            if (_swapCount > 0) {
                _swapCount -= elapsedTime;
            }
        }
        
        public function attack(room:Room, x:int, y:int, hpRate:Number, status:PlayerStatus, enemies:EnemyManager):int {
            // if(isAmmoEmpty()) reload()
            // if(canAttack() && !isReloading() && !isSwapping())
            var carry:int = Calculator.attack(room, _currentWeapon, x, y, hpRate, status, enemies);
            _currentWeaponAmmo--;
            _attackCount = Calculator.attackRate(_currentWeapon);
            return carry;
        }
        
        public function reload(status:PlayerStatus):void {
            // if(!isAmmoFull() && !isReloading() && !isSwapping())
            _attackCount = 0;
            _reloadCount = _reloadTime = Calculator.reloadRate(_currentWeapon, status);
        }
        
        
        public function swap():void {
            // if(!isSwapping())
            var tempWeapon:Weapon = _currentWeapon;
            var tempWeaponMaxAmmo:int = _currentWeaponMaxAmmo;
            var tempWeaponAmmo:int = _currentWeaponAmmo;
            _currentWeapon = _theOtherWeapon;
            _currentWeaponMaxAmmo = _theOtherWeaponMaxAmmo;
            _currentWeaponAmmo = _theOtherWeaponAmmo;
            _theOtherWeapon = tempWeapon;
            _theOtherWeaponMaxAmmo = tempWeaponMaxAmmo;
            _theOtherWeaponAmmo = tempWeaponAmmo;
            
            _attackCount = _reloadCount = 0;
            _swapCount = Const.PLAYER_SWAP_TIME;
        }
        
        public function isAmmoEmpty():Boolean { return _currentWeaponAmmo <= 0; }
        public function isAmmoFull():Boolean { return _currentWeaponAmmo == _currentWeaponMaxAmmo; }
        public function canAttack():Boolean { return _attackCount <= 0; }
        public function isReloading():Boolean { return _reloadCount > 0; }
        public function isSwapping():Boolean { return _swapCount > 0; }
        
        public function get currentWeapon():Weapon { return _currentWeapon; }
        public function get currentWeaponAmmo():int { return _currentWeaponAmmo; }
        public function get currentWeaponMaxAmmo():int { return _currentWeaponMaxAmmo; }
        public function get ammoGaugeRate():Number {
            return (_reloadCount > 0) ? 1 - (_reloadCount / _reloadTime) : _currentWeaponAmmo / _currentWeaponMaxAmmo;
        }
    }
//}
//package ore.orelib.logic {
    import flash.geom.Rectangle;
    import net.user1.reactor.Room;
/*    import ore.orelib.actors.Enemy;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.SaveData;
    import ore.orelib.data.Weapon;
*/    
    //public 
    class Calculator {
        
        /** 各計算で反映されるキャラクターごとのスキルの記述を取得します。 */
        public static function skillDescription(characterID:int):String {
            switch(characterID) {
                case Const.CHARACTER_MADOKA: { return "全ステータス+20\n射撃武器の貫通力2倍"; }
                case Const.CHARACTER_HOMURA: { return "射撃武器の射程無限\n装弾数2倍"; }
                case Const.CHARACTER_SAYAKA: { return "近接武器2回攻撃\n復帰速度2倍"; }
                case Const.CHARACTER_MAMI: { return "ダメージ+50%\nクリティカル率+15%"; }
                case Const.CHARACTER_KYOKO: { return "近接武器の射程+40%\nノックバック+8"; }
                case Const.CHARACTER_MADOGAMI: { return "上限無視で幸運+50\n復帰時周囲の仲間も無敵化"; }
                case Const.CHARACTER_MEGAHOMU: { return "爆発武器の範囲+20%\n攻撃速度+30%"; }
                case Const.CHARACTER_KUROSAYA: { return "近接武器2回攻撃\n被ダメージ4分の1"; }
                case Const.CHARACTER_CHARLOTTE: { return "移動速度2倍\n接触したQBを捕食する"; }
                case Const.CHARACTER_HITOMI: { return "戦闘不能時毒ガス発生\n近距離で常にクリティカル"; }
                default: { return ""; }
            }
        }
        
        public static function playerStatus(base:PlayerStatus, primary:Weapon, secondary:Weapon):PlayerStatus {
            // まどかなら全ステータス+
            var madokaBonus:int = 0;
            if (SaveData.instance.player.characterID == Const.CHARACTER_MADOKA) {
                madokaBonus = 20;
            }
            
            // まど神様なら幸運+
            var madogamiBonus:int = 0;
            if (SaveData.instance.player.characterID == Const.CHARACTER_MADOGAMI) {
                madogamiBonus = 50;
            }
            
            return new PlayerStatus(
                Math.min(Math.max(10, base.str + primary.strBonus + secondary.strBonus + madokaBonus), 200),
                Math.min(Math.max(10, base.vit + primary.vitBonus + secondary.vitBonus + madokaBonus), 200),
                Math.min(Math.max(10, base.dex + primary.dexBonus + secondary.dexBonus + madokaBonus), 200),
                Math.min(Math.max(10, base.luc + primary.lucBonus + secondary.lucBonus + madokaBonus + madogamiBonus), 200 + madogamiBonus)
            );
        }
        
        public static function recoverTime(vit:int, characterID:int):int {
            var result:int = Const.PLAYER_RECOVER_TIME * 100 / vit;
            
            // さやかなら復帰時間減
            if (characterID == Const.CHARACTER_SAYAKA) {
                result /= 2;
            }
            
            return result;
        }
        
        public static function speed(status:PlayerStatus):int {
            var result:int = Const.PLAYER_SPEED * status.dex / 100;
            
            // シャルロッテなら移動速度+
            if (SaveData.instance.player.characterID == Const.CHARACTER_CHARLOTTE) {
                result *= 2;
            }
            
            return result;
        }
        
        public static function attackRate(weapon:Weapon):int {
            var result:int = weapon.attackRate;
            
            // メガほむなら攻撃速度+
            if (SaveData.instance.player.characterID == Const.CHARACTER_MEGAHOMU) {
                var lowBound:int = (WeaponSmith.acquireAttackTypeOf(weapon.id) != Const.ATTACKTYPE_MELEE) ? 100 : 150;
                result = Math.max(lowBound, result * 100 / 130);
            }
            
            return result;
        }
        
        public static function reloadRate(weapon:Weapon, status:PlayerStatus):int {
            var result:int = weapon.reloadRate * 100 / status.dex;
            
            if (WeaponSmith.acquireAttackTypeOf(weapon.id) == Const.ATTACKTYPE_MELEE) {
                // メガほむなら近接武器の攻撃速度+
                if (SaveData.instance.player.characterID == Const.CHARACTER_MEGAHOMU) {
                    result = weapon.reloadRate * 10000 / (status.dex * 130);
                }
            }
            
            return Math.max(Calculator.attackRate(weapon), result);
        }
        
        public static function maxAmmo(weapon:Weapon):int {
            var result:int = weapon.maxAmmo;
            
            var attackType:int = WeaponSmith.acquireAttackTypeOf(weapon.id);
            if (attackType == Const.ATTACKTYPE_MELEE) {
                // さやかか、黒さやかなら近接２回攻撃
                if (
                    SaveData.instance.player.characterID == Const.CHARACTER_SAYAKA ||
                    SaveData.instance.player.characterID == Const.CHARACTER_KUROSAYA
                ) {
                    result++;
                }
            } else {
                // ほむらなら装弾数+
                if (SaveData.instance.player.characterID == Const.CHARACTER_HOMURA) {
                    result *= 2;
                }
            }
            
            return result;
        }
        
        public static function attack(room:Room, weapon:Weapon, x:int, y:int, hpRatio:Number, status:PlayerStatus, enemies:EnemyManager):int {
            var attackType:int = WeaponSmith.acquireAttackTypeOf(weapon.id);
            var bounds:Rectangle, collidingEnemies:Vector.<Enemy>;
            var i:int, enemy:Enemy, distX:int, collidingEnemiesLength:int;
            var range:int, carry:int = 0;
            
            switch(attackType) {
                case Const.ATTACKTYPE_SHOOTING:
                {
                    if (weapon.id == Const.WEAPON_TIROFINALE) {
                        bounds = new Rectangle( -Const.FIELD_OFFSET_X, y - 40, x - 8 + Const.FIELD_OFFSET_X, 40);
                    } else {
                        bounds = new Rectangle( -Const.FIELD_OFFSET_X, y - 18, x - 8 + Const.FIELD_OFFSET_X, 4);
                    }
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    carry = 400;
                    
                    // まどかなら貫通力+
                    var penetration:int = weapon.penetration;
                    if (SaveData.instance.player.characterID == Const.CHARACTER_MADOKA) {
                        penetration = penetration * 2 + 1;
                    }
                    
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        distX = x - 8 - collidingEnemies[i].x;
                        
                        // 敵との距離に応じてダメージを減衰させる（ほむらなら距離減衰無し）
                        var distMultiplier:Number = 1;
                        if (SaveData.instance.player.characterID != Const.CHARACTER_HOMURA) {
                            distMultiplier = Math.min(Math.max(0.1, 1 - 0.9 * (distX - weapon.range) / weapon.range), 1);
                        }
                        
                        collidingEnemies[i].damaged(
                            room,
                            Calculator.damage(weapon, hpRatio, status, distX, distMultiplier),
                            Calculator.knockback(weapon, status)
                        );
                        // 貫通しなかったら終了
                        if (i >= penetration) { carry = distX; break; }
                    }
                    break;
                }
                
                case Const.ATTACKTYPE_EXPLOSIVE:
                {
                    bounds = new Rectangle( -Const.FIELD_OFFSET_X, y - 18, x - 8 + Const.FIELD_OFFSET_X, 4);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    carry = 500;
                    if (collidingEnemies.length == 0) { break; }
                    // 一番先頭の敵を爆心地にする
                    enemy = collidingEnemies[0];
                    
                    range = Calculator.range(weapon);
                    var halfRange:int = range / 2;
                    bounds = new Rectangle(enemy.x + 16 - halfRange, y - 16 - halfRange, range, range);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    carry = x - 24 - enemy.x;
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        distX = x - 8 - collidingEnemies[i].x;
                        collidingEnemies[i].damaged(
                            room,
                            Calculator.damage(weapon, hpRatio, status, distX),
                            Calculator.knockback(weapon, status)
                        );
                    }
                    break;
                }
                
                case Const.ATTACKTYPE_MELEE:
                {
                    range = Calculator.range(weapon);
                    bounds = new Rectangle(x - 8 - range, y - 40, range, 40);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    carry = range;
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        distX = x - 8 - collidingEnemies[i].x;
                        collidingEnemies[i].damaged(
                            room,
                            Calculator.damage(weapon, hpRatio, status, distX),
                            Calculator.knockback(weapon, status)
                        );
                    }
                    break;
                }
                
                default: { break; }
            }
            
            return carry;
        }
        
        public static function range(weapon:Weapon):int {
            var result:int = weapon.range;
            var attackType:int = WeaponSmith.acquireAttackTypeOf(weapon.id);
            
            // メガほむなら爆発武器の範囲+
            if (attackType == Const.ATTACKTYPE_EXPLOSIVE && SaveData.instance.player.characterID == Const.CHARACTER_MEGAHOMU) {
                result *= 1.2;
            }
            
            // 杏子なら近接武器の射程+
            if (attackType == Const.ATTACKTYPE_MELEE && SaveData.instance.player.characterID == Const.CHARACTER_KYOKO) {
                result *= 1.4;
            }
            
            return result;
        }
        
        private static function damage(weapon:Weapon, hpRate:Number, status:PlayerStatus, distX:int, distMultiplier:Number = 1):int {
            var baseDamage:Number = weapon.minDamage + weapon.randDamage * distMultiplier * Math.random();
            var criticalRate:Number = weapon.criticalRate * status.luc / 100;
            
            // マミならダメージ+, クリティカル率+
            if (SaveData.instance.player.characterID == Const.CHARACTER_MAMI) {
                baseDamage *= 1.5;
                criticalRate += 15;
            }
            
            // 仁美なら至近距離で常にクリティカル
            if (SaveData.instance.player.characterID == Const.CHARACTER_HITOMI) {
                if (distX - 16 <= 32) { criticalRate += 100; }
            }
            
            var crits:Boolean = (int(100 * Math.random()) < int(criticalRate));
            return baseDamage * ((crits) ? 5 : 1) * status.str / 100;
        }
        
        private static function knockback(weapon:Weapon, status:PlayerStatus):int {
            var result:int = weapon.knockback * status.str / 100;
            
            // 杏子ならノックバック量+
            if (SaveData.instance.player.characterID == Const.CHARACTER_KYOKO) {
                result += 8;
            }
            
            return result;
        }
        
        public static function enemyStr(str:int):int {
            var result:int = str;
            
            // 黒さやかなら被ダメージ減
            if (SaveData.instance.player.characterID == Const.CHARACTER_KUROSAYA) {
                result = Math.max(1, str / 4);
            }
            
            return result;
        }
        
        public static function counter():Boolean {
            var result:Boolean = false;
            
            // シャルロッテなら接触時QBを食べる
            if (SaveData.instance.player.characterID == Const.CHARACTER_CHARLOTTE) {
                result = true;
            }
            
            return result;
        }
        
        public static function gas():Boolean {
            var result:Boolean = false;
            
            // 仁美なら戦闘不能時毒ガス発生
            if (SaveData.instance.player.characterID == Const.CHARACTER_HITOMI) {
                result = true;
            }
            
            return result;
        }
    }
//}
//package ore.orelib.logic {
    import net.user1.reactor.Attribute;
    import net.user1.reactor.AttributeEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.RoomManagerEvent;
    import net.user1.reactor.Status;
/*    import ore.orelib.actors.Enemy;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
*/    
    //public 
    class Host {
        private var _room:Room;
        private var _main:Main;
        
        private var _isHost:Boolean;
        private var _wave:int;
        private var _waveXML:XML;
        private var _startTime:Number;
        private var _numContracts:int;
        
        private var _spawnInterval:int;
        private var _spawnIntervalCount:int;
        
        private var _leaveCount:int; // 生成失敗したRoomからの退出用
        
        public static const TIME_MODULO:int = 10000000;
        public static const MAX_PLAY_TIME:int = 9900000;
        
        // 4: code(clientID)
        public static const ATTR_HOST:String = "h";
        // 4: code(clientID)
        public static const ATTR_HOST_CANDIDACY:String = "i";
        // 2: code(wave)
        public static const ATTR_WAVE:String = "w";
        // 4: code(startTime % TIME_MODULO)
        public static const ATTR_START_TIME:String = "t";
        // 2: numContracts
        public static const ATTR_NUM_CONTRACTS:String = "c";
        
        public function Host(room:Room, main:Main) {
            _room = room;
            _main = main;
            
            _isHost = false;
            _wave = 1;
            _waveXML = Const.ENEMY_TABLE.*.(@num == "1")[0];
            _startTime = -1;
            _numContracts = 0;
            
            _spawnInterval = int((Const.FIELD_WAVE_TIME - 5000) / int(_waveXML.@amount));
            _spawnIntervalCount = 0;
            
            _leaveCount = 5000;
            
            _main.reactor.getRoomManager().addEventListener(RoomManagerEvent.CREATE_ROOM_RESULT, createRoomHandler);
            _room.addEventListener(RoomEvent.JOIN, initialize);
            _room.addEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.addEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
        }
        
        private function createRoomHandler(event:RoomManagerEvent):void {
            if (event.getRoomID() != _room.getRoomID()) { return; }
            event.currentTarget.removeEventListener(event.type, arguments.callee);
            
            // 自分が部屋作成者なら、ホストになる
            if (event.getStatus() == Status.SUCCESS) { _isHost = true; }
        }
        
        private function initialize(event:RoomEvent):void {
            event.currentTarget.removeEventListener(event.type, arguments.callee);
            if (_isHost || _numContracts >= Const.FIELD_QB_QUOTA) {
                _room.setAttribute(Host.ATTR_HOST, UPCConv.toCode(int(_main.reactor.self().getClientID())));
                _room.setAttribute(Host.ATTR_WAVE, UPCConv.toCode(1));
                _room.setAttribute(Host.ATTR_START_TIME, UPCConv.toCode(_main.reactor.getServer().getServerTime() % Host.TIME_MODULO));
                _room.setAttribute(Host.ATTR_NUM_CONTRACTS, "0");
            }
    }
        
        private function removeOccupantHandler(event:RoomEvent):void {
            // 退室者が出たらホスト立候補戦を行う（立候補は退室者のID送信）
            // 回線状態が良い人のみ立候補（ホストがいない場合は基準を緩める）
            var ping:int = _main.reactor.self().getPing();
            if (_main.fps >= 30 
                && 0 < ping
                && (ping < 50 || (ping < 500 && !_room.clientIsInRoom(UPCConv.toInt(_room.getAttribute(Host.ATTR_HOST)).toString())))
            ) {
                _room.setAttribute(Host.ATTR_HOST_CANDIDACY, UPCConv.toCode(int(event.getClientID())));
            }
        }
        
        private function attributeUpdateHandler(event:AttributeEvent):void {
            var attr:Attribute = event.getChangedAttr();
            
            switch(attr.name) {
                case Host.ATTR_HOST:
                {
                    _isHost = (UPCConv.toInt(attr.value) == int(_main.reactor.self().getClientID()));
                    break;
                }
                
                case Host.ATTR_HOST_CANDIDACY:
                {
                    // 最初に立候補したのが自分なら、自分がホストになる
                    if (attr.byClient && attr.byClient.isSelf()) {
                        _room.setAttribute(Host.ATTR_HOST, UPCConv.toCode(int(_main.reactor.self().getClientID())));
                    }
                    break;
                }
                
                case Host.ATTR_WAVE:
                {
                    // waveの変わり目にサーバーと同期する
                    _main.reactor.getServer().syncTime();
                    
                    // wave数が変わったことがサーバーから送られたらホスト立候補戦を行う（立候補はwave数送信）
                    // 回線状態が良い人のみ立候補
                    if (int(attr.oldValue) > 0) {
                        var ping:int = _main.reactor.self().getPing();
                        if (_main.fps >= 30 && 0 < ping && ping < 50) {
                            _room.setAttribute(Host.ATTR_HOST_CANDIDACY, "." + attr.value);
                        }
                    }
                    break;
                }
                
                case Host.ATTR_START_TIME: {
                    if (_startTime < 0) {
                        _startTime = UPCConv.toInt(attr.value);
                    } else {
                        _room.setAttribute(Host.ATTR_START_TIME, UPCConv.toCode(_startTime));
                    }
                    break;
                }
                
                case Host.ATTR_NUM_CONTRACTS: {
                    _numContracts = int(attr.value);
                    break;
                }
                
                default: { break; }
            }
        }
        
        public function update(serverTime:Number, elapsedTime:int, enemies:EnemyManager):void {
            // 開始時刻がわからない時間が長かったら強制退出
            if (_startTime < 0) {
                _leaveCount -= elapsedTime;
                if (_leaveCount < 0) { _numContracts = Const.FIELD_QB_QUOTA; }
                return; 
            }
            // プレイ時間（wave1の初めから今までの時間）を求める
            var playTime:Number = (serverTime - _startTime) % Host.TIME_MODULO;
            if (playTime > Host.MAX_PLAY_TIME) { playTime = 0; }
            
            // wave数がかわったら更新する
            var currentWave:int = int(playTime / Const.FIELD_WAVE_TIME) + 1;
            if (currentWave != _wave) {
                _wave = currentWave;
                _waveXML = Const.ENEMY_TABLE.*.(@num == Math.min(Math.max(1, _wave), Const.ENEMY_TABLE.*.length()).toString())[0];
                _spawnInterval = int((Const.FIELD_WAVE_TIME - 5000) / int(_waveXML.@amount));
                _spawnIntervalCount = 0;
                
                if (_isHost) { _room.setAttribute(Host.ATTR_WAVE, UPCConv.toCode(_wave)); }
            }
            
            // 敵の出現処理はホストがやる（ホストでないなら終了）
            if (!_isHost) { return; }
            // wave開始直後と終了間際は敵が出現しない
            var currentWaveTime:int = int(playTime % Const.FIELD_WAVE_TIME);
            if (1500 < currentWaveTime && currentWaveTime < Const.FIELD_WAVE_TIME - 3500) {
                _spawnIntervalCount += elapsedTime;
            }
            // 敵を出現させる
            if (_spawnIntervalCount > _spawnInterval) {
                _spawnIntervalCount -= _spawnInterval;
                var enemyID:int = enemies.acquireFreeID();
                if (enemyID > 0) {
                    Enemy.spawn(
                        _room, enemyID,
                        int(_waveXML.@hp), int(_waveXML.@str), int(_waveXML.@vx), serverTime
                    );
                }
            }
        }
        
        public function removeEventListeners():void {
            _room.removeEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.removeEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
        }
        
        public function get isHost():Boolean { return _isHost; }
        public function get wave():int { return _wave; }
        public function get numContracts():int { return _numContracts; }
    }
//}
//package ore.orelib.logic {
/*    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.Weapon;
    import ore.orelib.data.WeaponData;
*/    
    //public 
    class WeaponSmith {
        
        public static function createWeaponData(level:int, wave:int, killCount:int, luc:int):WeaponData {
            var score:int = ((wave * 20 + killCount) * luc / 100);
            if (killCount < wave) {
                score = 0;
            } else if (killCount < wave * 5) {
                score *= killCount / (wave * 5);
            }
            
            // クオリティの種類を決定（上位２種からランダム）
            var qualityList:Vector.<XML> = new Vector.<XML>();
            var quality:XML;
            for each(quality in Const.WEAPON_QUALITY_TABLE.*) {
                if (level >= int(quality.@lv) && wave >= int(quality.@wave) && score >= int(quality.@score)) {
                    qualityList.push(quality);
                }
            }
            qualityList.sort(compareScore);
            quality = qualityList[int(Math.min(qualityList.length, 2) * Math.random())];
            score -= int(quality.@score);
            
            // 武器の種類を決定（全種からランダム）
            var baseList:XMLList = Const.WEAPON_BASE_TABLE.*;
            var base:XML = baseList[int(baseList.length() * Math.random())];
            //score -= int(base.@rscore);
            
            // クオリティのレベルを決定（全種からランダム）
            var qualityLevelList:XMLList = quality.*.(score >= int(@score));
            var qualityLevel:XML = qualityLevelList[int(qualityLevelList.length() * Math.random())];
            score -= int(qualityLevel.@score);
            
            // 接頭語の種類を決定（上位２０種からランダム）
            var prefixList:Vector.<XML> = new Vector.<XML>();
            var prefix:XML;
            for each(prefix in Const.WEAPON_PREFIX_TABLE.*) {
                if (level >= int(prefix.@lv) && wave >= int(prefix.@wave) && score >= int(prefix.@score)
                    && int(Number(prefix.@base) / Math.pow(10, (Const.NUM_WEAPONS - 1) - int(base.@id)) % 10) == 1
                ) {
                    prefixList.push(prefix);
                }
            }
            prefixList.sort(compareScore);
            var prefixListIndex:int = 20 * Math.random();
            prefix = (prefixListIndex < prefixList.length)
                ? prefixList[prefixListIndex]
                : Const.WEAPON_PREFIX_TABLE.*.(@id == "none")[0];
            score -= int(prefix.@score);
            
            // 接頭語のレベルを決定（全種からランダム）
            var prefixLevelList:XMLList = prefix.*.(score >= int(@score));
            var prefixLevel:XML = prefixLevelList[int(prefixLevelList.length() * Math.random())];
            score -= int(prefixLevel.@score);
            
            // 武器のレベルを決定（全種からランダム）
            var baseLevelList:XMLList = base.*.(score >= int(@score));
            var baseLevel:XML = baseLevelList[int(baseLevelList.length() * Math.random())];
            score -= int(baseLevel.@score);
            
            var result:WeaponData = new WeaponData();
            result.id = int(base.@id);
            result.baseLevel = int(baseLevel.@num);
            result.quality = quality.@id;
            result.qualityLevel = int(qualityLevel.@num);
            result.prefix = prefix.@id;
            result.prefixLevel = int(prefixLevel.@num);
            return result;
            
            function compareScore(a:XML, b:XML):Number {
                return (int(a.@score) < int(b.@score)) ? 1 : -1;
            }
        }
        
        public static function createWeaponFrom(data:WeaponData):Weapon {
            var dmg:int, min:int, rand:int, range:int, attack:int, reload:int, ammo:int;
            var str:int, vit:int, dex:int, luc:int, crit:int, kb:int, pene:int;
            
            var base:XML = Const.WEAPON_BASE_TABLE.base.(int(@id) == data.id)[0];
            var quality:XML = Const.WEAPON_QUALITY_TABLE.quality.(@id == data.quality)[0];
            var prefix:XML = Const.WEAPON_PREFIX_TABLE.prefix.(@id == data.prefix)[0];
            if (int(Number(prefix.@base) / Math.pow(10, (Const.NUM_WEAPONS - 1) - int(base.@id)) % 10) != 1) {
                data = new WeaponData();
                base = Const.WEAPON_BASE_TABLE.base.(int(@id) == data.id)[0];
                quality = Const.WEAPON_QUALITY_TABLE.quality.(@id == data.quality)[0];
                prefix = Const.WEAPON_PREFIX_TABLE.prefix.(@id == data.prefix)[0];
            }
            
            // 補正の合計を計算する
            addMods(base.level.(@num == data.baseLevel)[0]);
            addMods(quality.level.(@num == data.qualityLevel)[0]);
            addMods(prefix.level.(@num == data.prefixLevel)[0]);
            
            // 攻撃タイプに無関係な補正を無視する
            var attackType:int = acquireAttackTypeOf(data.id);
            switch(attackType) {
                case Const.ATTACKTYPE_EXPLOSIVE: { pene = 0; break; }
                case Const.ATTACKTYPE_MELEE: { attack = ammo = pene = 0; break; }
                default: { break; }
            }
            
            // スペックを計算する
            var minDamage:int = Math.max(1, int(int(base.@bmin) * (100 + dmg) / 100) + min);
            var randDamage:int = Math.max(0, int(int(base.@brand) * (100 + dmg) / 100) - min + rand);
            var finalRange:int = Math.max(16, int(int(base.@brange) * (100 + range) / 100));
            var attackRate:int = Math.max(100, int(int(base.@battack) * 100 / (100 + attack)));
            var reloadRate:int = Math.max(300, int(int(base.@breload) * 100 / (100 + reload)));
            var maxAmmo:int = Math.max(1, int(int(base.@bammo) * (100 + ammo) / 100));
            
            // スペック表記リストを作成する
            var specs:Vector.<String> = new Vector.<String>();
            var specColors:Vector.<uint> = new Vector.<uint>();
            addSpec("ダメージ: " + minDamage + " ～ " + int(minDamage + randDamage), 0xFFFFFF);
            addSpec(((attackType == Const.ATTACKTYPE_EXPLOSIVE) ? "範囲" : "射程") + ": " + finalRange, 0xFFFFFF);
            if (attackType != Const.ATTACKTYPE_MELEE) {
                addSpec("攻撃速度(ms): " + attackRate, 0xFFFFFF);
                addSpec("リロード速度(ms): " + reloadRate, 0xFFFFFF);
                addSpec("装弾数: " + maxAmmo, 0xFFFFFF);
            } else {
                addSpec("攻撃速度(ms): " + reloadRate, 0xFFFFFF);
            }
            if (dmg != 0) { addSpec("ダメージ" + ((dmg > 0) ? "+" : "") + dmg + "%", (dmg > 0) ? 0x00FF00 : 0xFF0000); }
            if (min != 0) { addSpec("最小ダメージ" + ((min > 0) ? "+" : "") + min, (min > 0) ? 0x00FF00 : 0xFF0000); }
            if (rand != 0) { addSpec("最大ダメージ" + ((rand > 0) ? "+" : "") + rand, (rand > 0) ? 0x00FF00 : 0xFF0000); }
            if (range != 0) { addSpec(((attackType == Const.ATTACKTYPE_EXPLOSIVE) ? "範囲" : "射程") + ((range > 0) ? "+" : "") + range + "%", (range > 0) ? 0x00FF00 : 0xFF0000); }
            if (attack != 0) { addSpec("攻撃速度" + ((attack > 0) ? "+" : "") + attack + "%", (attack > 0) ? 0x00FF00 : 0xFF0000); }
            if (reload != 0) { addSpec(((attackType == Const.ATTACKTYPE_MELEE) ? "攻撃速度" : "リロード速度") + ((reload > 0) ? "+" : "") + reload + "%", (reload > 0) ? 0x00FF00 : 0xFF0000); }
            if (ammo != 0) { addSpec("装弾数" + ((ammo > 0) ? "+" : "") + ammo + "%", (ammo > 0) ? 0x00FF00 : 0xFF0000); }
            if (str != 0) { addSpec("魔力" + ((str > 0) ? "+" : "") + str, (str > 0) ? 0x00FF00 : 0xFF0000); }
            if (vit != 0) { addSpec("精神" + ((vit > 0) ? "+" : "") + vit, (vit > 0) ? 0x00FF00 : 0xFF0000); }
            if (dex != 0) { addSpec("敏捷" + ((dex > 0) ? "+" : "") + dex, (dex > 0) ? 0x00FF00 : 0xFF0000); }
            if (luc != 0) { addSpec("幸運" + ((luc > 0) ? "+" : "") + luc, (luc > 0) ? 0x00FF00 : 0xFF0000); }
            if (crit > 0) { addSpec("クリティカル率+" + crit + "%", 0x00FF00); }
            if (kb > 0) { addSpec("ノックバック+" + kb, 0x00FF00); }
            if (pene > 0) { addSpec("最大" + pene + "匹の敵を貫通", 0x00FF00); }
            
            var totalLevel:int = data.baseLevel + data.qualityLevel + data.prefixLevel;
            return new Weapon(
                data.id,
                prefix.@name + quality.@name + base.@name + ((totalLevel > 0) ? "+" + totalLevel : ""),
                specs,
                specColors,
                minDamage,
                randDamage,
                finalRange,
                attackRate,
                reloadRate,
                maxAmmo,
                new PlayerStatus(str, vit, dex, luc),
                Math.max(0, crit),
                Math.max(0, kb),
                Math.max(0, pene)
            );
            
            function addMods(level:XML):void {
                if ("@dmg" in level) { dmg += int(level.@dmg); }
                if ("@min" in level) { min += int(level.@min); }
                if ("@rand" in level) { rand += int(level.@rand); }
                if ("@range" in level) { range += int(level.@range); }
                if ("@attack" in level) { attack += int(level.@attack); }
                if ("@reload" in level) { reload += int(level.@reload); }
                if ("@ammo" in level) { ammo += int(level.@ammo); }
                if ("@str" in level) { str += int(level.@str); }
                if ("@vit" in level) { vit += int(level.@vit); }
                if ("@dex" in level) { dex += int(level.@dex); }
                if ("@luc" in level) { luc += int(level.@luc); }
                if ("@crit" in level) { crit += int(level.@crit); }
                if ("@kb" in level) { kb += int(level.@kb); }
                if ("@pene" in level) { pene += int(level.@pene); }
            }
            
            function addSpec(text:String, textColor:uint):void {
                specs.push(text);
                specColors.push(textColor);
            }
        }
        
        public static function createInitialEquipment(characterID:int):Array {
            var result:Array = [];
            
            var primary:WeaponData = new WeaponData();
            switch(characterID) {
                case Const.CHARACTER_MADOKA: { primary.id = Const.WEAPON_ROSEBOW; break; }
                case Const.CHARACTER_HOMURA: { primary.id = Const.WEAPON_PIPEBOMB; break; }
                case Const.CHARACTER_SAYAKA: { primary.id = Const.WEAPON_SABER; break; }
                case Const.CHARACTER_MAMI: { primary.id = Const.WEAPON_MASKET; break; }
                case Const.CHARACTER_KYOKO: { primary.id = Const.WEAPON_SPEAR; break; }
                default: { break; }
            }
            
            var secondary:WeaponData = new WeaponData();
            secondary.id = Const.WEAPON_PISTOL;
            
            result.push(primary, secondary);
            return result;
        }
        
        public static function acquireAttackTypeOf(weaponID:int):int {
            switch(weaponID) {
                case Const.WEAPON_EXTINGUISHER:
                case Const.WEAPON_PIPEBOMB:
                case Const.WEAPON_RPG7:
                {
                    return Const.ATTACKTYPE_EXPLOSIVE;
                }
                
                case Const.WEAPON_GOLFCLUB:
                case Const.WEAPON_METALBAT:
                case Const.WEAPON_SABER:
                case Const.WEAPON_SPEAR:
                case Const.WEAPON_PUNCH:
                {
                    return Const.ATTACKTYPE_MELEE;
                }
                
                case Const.WEAPON_PISTOL:
                case Const.WEAPON_MASKET:
                case Const.WEAPON_MINIMI:
                case Const.WEAPON_ROSEBOW:
                case Const.WEAPON_BLACKBOW:
                case Const.WEAPON_TIROFINALE:
                default:
                {
                    return Const.ATTACKTYPE_SHOOTING;
                }
            }
        }
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    
    //public 
    interface IActor {
        function draw(target:BitmapData):void;
        function drawOverlay(target:BitmapData):void;
        function get depth():Number;
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
/*    import ore.orelib.anim.ArmAnim;
    import ore.orelib.anim.BodyAnim;
    import ore.orelib.anim.WeaponAnim;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.events.EffectEvent;
    import ore.orelib.logic.Calculator;
    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class Friend implements IActor {
        // 移動関連
        private var _currentPosition:Point;
        private var _destPosition:Point;
        private var _speed:int;
        private var _velocityPerMs:Point;
        private var _bounds:Rectangle;
        // 描画関連
        private var _nameLabel:TextField;
        private var _hp:int;
        private var _maxHp:int;
        private var _invincibleCount:int;
        private var _blinkCount:int;
        private var _recoverCount:int;
        private var _recoverTime:int;
        
        private var _body:BodyAnim;
        private var _arm:ArmAnim;
        private var _weapon:WeaponAnim;
        private var _characterID:int;
        private var _weaponID:int;
        private var _attackTypeID:int;
        private var _worldTrans:Matrix;
        private var _effectColorOffset:int;
        
        // 文字数: 式 ビット列
        // 4+: name,code((speed << 16) + (maxHp << 6) + chara) bit{8,10,6}
        public static const ATTR_STATUS:String = "t";
        // 3: code((x << 9) + y) bit{9,9}
        public static const ATTR_POS:String = "p";
        // 2: code(hp)
        public static const ATTR_HP:String = "h";
        // 1: code(weaponID)
        public static const ATTR_WEAPON:String = "w";
        // 3: code((range << 9) + carry) bit{9,9}
        public static const MESSAGE_ATTACK:String = "a";
        public static const MESSAGE_GAS:String = "g";
        
        public function Friend(
            name:String, speed:int, maxHp:int, characterID:int,
            x:Number, y:Number, hp:int, weaponID:int
        ) {
            _currentPosition = new Point(x, y);
            _destPosition = new Point(x, y);
            _speed = speed;
            _velocityPerMs = new Point(0, 0);
            _bounds = new Rectangle(
                _currentPosition.x - Const.PLAYER_BOUNDS_HALF_WIDTH,
                _currentPosition.y - Const.PLAYER_BOUNDS_HEIGHT,
                Const.PLAYER_BOUNDS_HALF_WIDTH * 2,
                Const.PLAYER_BOUNDS_HEIGHT
            );
            
            _nameLabel = new TextBuilder()
                .align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(10)
                .size(140, 20).build(name);
            _hp = hp;
            _maxHp = maxHp;
            _invincibleCount = _blinkCount = _recoverCount = 0;
            _recoverTime = Calculator.recoverTime(_maxHp, characterID);
            if (_hp <= 0) { _recoverCount = _recoverTime; }
            
            _body = new BodyAnim(characterID);
            if (_hp <= 0) { _body.transition(BodyAnim.RECOVER); }
            _arm = new ArmAnim();
            _weapon = new WeaponAnim(weaponID);
            _characterID = characterID;
            _weaponID = weaponID;
            _attackTypeID = WeaponSmith.acquireAttackTypeOf(_weaponID);
            _worldTrans = new Matrix();
            _effectColorOffset = 0;
            
            moveTo(x, y, false); // ちらつき防止
        }
        
        /** 目的位置を更新する */
        public function moveTo(x:Number, y:Number, isSelf:Boolean):void {
            _destPosition.x = x;
            _destPosition.y = y;
            
            // 同じy座標のactor同士のちらつきを無くす
            if (!isSelf) { _destPosition.y += Math.random(); }
            
            var angle:Number = Math.atan2(_destPosition.y - _currentPosition.y, _destPosition.x - _currentPosition.x);
            _velocityPerMs.x = _speed * Math.cos(angle) / 1000;
            _velocityPerMs.y = _speed * Math.sin(angle) / 1000;
        }
        
        /** 攻撃モーションを行う */
        public function attack():void {
            _arm.transition((_attackTypeID == Const.ATTACKTYPE_MELEE) ? ArmAnim.SWING : ArmAnim.RECOIL);
        }
        
        /** 武器変更モーションを行う */
        public function swapWeapon(weaponID:int):void {
            _arm.transition(ArmAnim.SWAP);
            _weapon.transition(weaponID);
            _weaponID = weaponID;
            _attackTypeID = WeaponSmith.acquireAttackTypeOf(_weaponID);
        }
        
        /** 残りHPに応じた更新を行う */
        public function changeHp(value:int):void {
            if (value <= 0) {
                _invincibleCount = 0;
                _recoverCount = _recoverTime;
                _body.transition(BodyAnim.RECOVER);
            } else if (value < _hp) {
                _invincibleCount = 0;
                _effectColorOffset = 300;
                EventManager.instance.dispatchEvent(new EffectEvent(
                    EffectEvent.DAMAGED_ACTOR,
                    _currentPosition.x,
                    _currentPosition.y,
                    { num: _hp - value, color: 0xFF8888, isEnemy: false }
                ));
            } else if (value > _hp) {
                _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
                _body.transition(BodyAnim.IDLE);
                
                // まど神様なら祝福発生
                if (_characterID == Const.CHARACTER_MADOGAMI) {
                    EventManager.instance.dispatchEvent(new EffectEvent(
                        EffectEvent.GOD_BLESS,
                        _currentPosition.x, _currentPosition.y
                    ));
                }
            }
            
            _hp = value;
        }
        
        public function beBlessed():void {
            if (_hp > 0) {
                _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
            }
        }
        
        public function update(elapsedTime:int):void {
            if (_invincibleCount > 0) {
                _invincibleCount -= elapsedTime;
                _blinkCount++;
            } else {
                _blinkCount = 0;
            }
            
            if (_hp > 0) {
                if (!_currentPosition.equals(_destPosition)) {
                    var diff:Point = GeomPool.point(_destPosition.x - _currentPosition.x, _destPosition.y - _currentPosition.y);
                    var delta:Point = GeomPool.point(_velocityPerMs.x * elapsedTime, _velocityPerMs.y * elapsedTime);
                    
                    if ((diff.x * diff.x + diff.y * diff.y) < (delta.x * delta.x + delta.y * delta.y)) {
                        _currentPosition.x = _destPosition.x;
                        _currentPosition.y = _destPosition.y;
                    }else {
                        _currentPosition.x += delta.x;
                        _currentPosition.y += delta.y;
                    }
                    
                    _bounds.x = _currentPosition.x - Const.PLAYER_BOUNDS_HALF_WIDTH;
                    _bounds.y = _currentPosition.y - Const.PLAYER_BOUNDS_HEIGHT;
                    
                    _body.transition(BodyAnim.RUN);
                }else {
                    _body.transition(BodyAnim.IDLE);
                }
            } else {
                _recoverCount = Math.max(0, _recoverCount - elapsedTime);
            }
            
            _worldTrans.tx = int(_currentPosition.x + Const.FIELD_OFFSET_X);
            _worldTrans.ty = int(_currentPosition.y + Const.FIELD_OFFSET_Y);
            _nameLabel.x = _worldTrans.tx - 70;
            _nameLabel.y = _worldTrans.ty - 50;
            _body.update(elapsedTime, _worldTrans);
            _arm.update(elapsedTime, _body.worldTrans);
            _weapon.update(elapsedTime, _arm.worldTrans);
            _effectColorOffset = Math.max(0, _effectColorOffset - 60);
        }
        
        public function draw(target:BitmapData):void {
            target.copyPixels(
                Assets.images["actorShadow"],
                GeomPool.rectangle(0, 0, 465, 465),
                GeomPool.point(_worldTrans.tx - 14, _worldTrans.ty - 4),
                null, null, true
            );
            
            drawBody(
                target,
                GeomPool.colorTransform(1, 1, 1, (_blinkCount % 6 >= 3) ? 0.5 : 1, _effectColorOffset, _effectColorOffset, _effectColorOffset)
            );
        }
        
        public function drawBody(target:BitmapData, effect:ColorTransform):void {
            if (_hp > 0) {
                _weapon.draw(target, effect);
                _arm.draw(target, effect);
            }
            _body.draw(target, effect);
        }
        
        public function drawOverlay(target:BitmapData):void {
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 34, 32, 1), 0xFFFF0000);
            var hpGaugeRate:Number = (_hp > 0) ? _hp / _maxHp : 1 - (_recoverCount / _recoverTime);
            var hpGaugeColor:uint = (_hp > 0) ? 0xFF00FF00 : 0xFFFFFF00;
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 34, 32 * hpGaugeRate, 1), hpGaugeColor);
        }
        
        public function get x():Number { return _currentPosition.x; }
        public function get y():Number { return _currentPosition.y; }
        public function get speed():int { return _speed; }
        public function get bounds():Rectangle { return _bounds; }
        public function get hp():int { return _hp; }
        public function get overlay():DisplayObject { return _nameLabel; }
        public function get weaponID():int { return _weaponID; }
        public function get depth():Number { return _currentPosition.y; }
    }
//}
//package ore.orelib.actors {
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import net.user1.reactor.Attribute;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
/*    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.events.ActorEvent;
    import ore.orelib.events.EffectEvent;
*/    
    //public 
    class FriendManager {
        private var _room:Room;
        private var _friendList:Dictionary;
        
        public function FriendManager(room:Room) {
            _room = room;
            _friendList = new Dictionary();
            
            _room.addEventListener(RoomEvent.ADD_OCCUPANT, addOccupantHandler);
            _room.addEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.addEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, updateClientAttrHandler);
            _room.addMessageListener(Friend.MESSAGE_ATTACK, attackFriendHandler);
            _room.addMessageListener(Friend.MESSAGE_GAS, emitGasHandler);
            EventManager.instance.addEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
        }
        
        /** プレイヤーが入室した際の処理 */
        private function addOccupantHandler(event:RoomEvent):void {
            var client:IClient = event.getClient();
            if (client.isSelf()) { return; }
            
            var attrStatus:String = client.getAttribute(Friend.ATTR_STATUS);
            var delimiterIndex:int = attrStatus.lastIndexOf(",");
            var speed_maxHp_characterID:int = UPCConv.toInt(attrStatus.substring(delimiterIndex + 1));
            var x_y:int = UPCConv.toInt(client.getAttribute(Friend.ATTR_POS));
            var friend:Friend = new Friend(
                attrStatus.substring(0, delimiterIndex),
                speed_maxHp_characterID >> 16,
                (speed_maxHp_characterID & 0xFFFF) >> 6,
                speed_maxHp_characterID & 0x3F,
                x_y >> 9,
                x_y & 0x1FF,
                UPCConv.toInt(client.getAttribute(Friend.ATTR_HP)),
                UPCConv.toInt(client.getAttribute(Friend.ATTR_WEAPON))
            );
            _friendList[client.getClientID()] = friend;
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, friend, friend.overlay));
        }
        
        /** プレイヤーが退室した際の処理 */
        private function removeOccupantHandler(event:RoomEvent):void {
            var friend:Friend = _friendList[event.getClientID()];
            delete _friendList[event.getClientID()];
            
            if (!friend) { return; }
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.REMOVE, friend, friend.overlay));
        }
        
        /** プレイヤーの属性が更新された際の処理 */
        private function updateClientAttrHandler(event:RoomEvent):void {
            var client:IClient = event.getClient();
            if (client.isSelf()) { return; }
            
            var friend:Friend = _friendList[client.getClientID()];
            var attr:Attribute = event.getChangedAttr();
            switch(attr.name) {
                // 位置の更新
                case Friend.ATTR_POS:
                {
                    var x_y:int = UPCConv.toInt(attr.value);
                    friend.moveTo(x_y >> 9, x_y & 0x1FF, false);
                    break;
                }
                
                // 残りHPの更新
                case Friend.ATTR_HP:
                {
                    friend.changeHp(UPCConv.toInt(attr.value));
                    break;
                }
                
                // 使用武器の変更
                case Friend.ATTR_WEAPON:
                {
                    friend.swapWeapon(UPCConv.toInt(attr.value));
                    break;
                }
                
                default: { break; }
            }
        }
        
        /** プレイヤーが攻撃を行った際の処理 */
        private function attackFriendHandler(from:IClient, message:String):void {
            var friend:Friend = _friendList[from.getClientID()];
            if (!friend) { return; }
            
            friend.attack();
            var range_carry:int = UPCConv.toInt(message);
            EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.ATTACK_WEAPON,
                friend.x, friend.y,
                {
                    id: friend.weaponID,
                    range: range_carry >> 9,
                    carry: range_carry & 0x1FF,
                    bySelf: false
                }
            ));
        }
        
        private function emitGasHandler(from:IClient):void {
            var friend:Friend = _friendList[from.getClientID()];
            if (!friend) { return; }
            
            EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.EMIT_GAS, friend.x, friend.y));
        }
        
        private function godBlessHandler(event:EffectEvent):void {
            var blessBounds:Rectangle = GeomPool.rectangle(event.x - 48, event.y - 64, 96, 96);
            for each(var friend:Friend in _friendList) {
                var friendBounds:Rectangle = friend.bounds;
                if (
                    friend.hp > 0 &&
                    friendBounds.top < blessBounds.bottom &&
                    friendBounds.bottom > blessBounds.top &&
                    friendBounds.left < blessBounds.right &&
                    friendBounds.right > blessBounds.left
                ) {
                    friend.beBlessed();
                }
            }
        }
        
        public function update(elapsedTime:int):void {
            for each(var friend:Friend in _friendList) {
                friend.update(elapsedTime);
            }
        }
        
        public function removeEventListeners():void {
            _room.removeEventListener(RoomEvent.ADD_OCCUPANT, addOccupantHandler);
            _room.removeEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.removeEventListener(RoomEvent.UPDATE_CLIENT_ATTRIBUTE, updateClientAttrHandler);
            _room.removeMessageListener(Friend.MESSAGE_ATTACK, attackFriendHandler);
            _room.removeMessageListener(Friend.MESSAGE_GAS, emitGasHandler);
            EventManager.instance.removeEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
        }
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import net.user1.reactor.Room;
/*    import ore.orelib.anim.BodyAnim;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.events.EffectEvent;
    import ore.orelib.events.KillEvent;
*/    
    //public 
    class Enemy implements IActor {
        private var _id:int;
        private var _hp:int;
        private var _maxHp:int;
        private var _str:int;
        // 移動関連
        private var _currentPosition:Point;
        private var _vx:int;
        private var _spawnPosition:Point;
        private var _spawnTime:int;
        private var _bounds:Rectangle;
        // 描画関連
        private var _body:BodyAnim;
        private var _worldTrans:Matrix;
        private var _effectColorOffset:int;
        
        public static const BOUNDS_HALF_WIDTH:int = 14;
        public static const BOUNDS_HEIGHT:int = 20;
        public static const TIME_MODULO:int = 100000;
        
        // 式 ビット列
        // code((maxHp << 16) + (str << 9) + vx),code(((spawnTime % TIME_MODULO) << 10) + (spawnY << 1) + exists) {15,7,9},{17,9,1}
        public static const ATTR_STATUS:String = "s";
        // code((hp << 16) + damageAmount),code(spawnX) {15,16}
        public static const ATTR_DAMAGE:String = "d";
        
        public static function spawn(room:Room, enemyID:int, baseHp:int, baseStr:int, baseVx:int, time:Number):void {
            var hp:int = baseHp;
            var str:int = baseStr;
            var vx:int = baseVx;
            if (Math.random() < 0.15) {
                if (Math.random() < 0.5) {
                    // 頑丈タイプ
                    hp *= 5; str *= 0.5; vx *= 0.75;
                } else {
                    // 速攻タイプ
                    hp *= 0.75; str *= 2; vx *= 1.5;
                }
            }
            
            room.setAttribute(enemyID + "." + Enemy.ATTR_DAMAGE,
                UPCConv.toCode(hp << 16) + "," + UPCConv.toCode(int(Const.FIELD_LEFT_BOUND - vx))
            );
            room.setAttribute(enemyID + "." + Enemy.ATTR_STATUS,
                UPCConv.toCode((hp << 16) + (str << 9) + vx) + "," +
                UPCConv.toCode((int(time % Enemy.TIME_MODULO) << 10) + (int(Const.FIELD_SIZE * Math.random()) << 1) + 1)
            );
        }
        
        public function Enemy() {
            _id = 0;
            _hp = _maxHp = _str = 0;
            _currentPosition = new Point();
            _vx = 0;
            _spawnPosition = new Point();
            _spawnTime = 0;
            _bounds = new Rectangle(0, 0, Enemy.BOUNDS_HALF_WIDTH * 2, Enemy.BOUNDS_HEIGHT);
            _body = new BodyAnim(Const.CHARACTER_QB);
            _body.transition(BodyAnim.RUN);
            _worldTrans = new Matrix();
            _effectColorOffset = 0;
        }
        
        public function initialize(id:int, maxHp_str_vx:int, spawnTime_spawnY:int, hp:int, spawnX:int):void {
            _id = id;
            _hp = (hp > 0) ? hp : int.MAX_VALUE;
            _maxHp = maxHp_str_vx >> 16;
            _str = (maxHp_str_vx >> 9) & 0x7F;
            _currentPosition.x = _spawnPosition.x = spawnX;
            _currentPosition.y = _spawnPosition.y = spawnTime_spawnY & 0x1FF;
            _vx = maxHp_str_vx & 0x1FF;
            _spawnTime = spawnTime_spawnY >> 9;
            _bounds.x = _currentPosition.x - Enemy.BOUNDS_HALF_WIDTH;
            _bounds.y = _currentPosition.y - Enemy.BOUNDS_HEIGHT;
            _worldTrans.ty = int(_currentPosition.y + Const.FIELD_OFFSET_Y);
            _effectColorOffset = 0;
            
            // 同じy座標のactor同士のちらつきを無くす
            _currentPosition.y += Math.random();
        }
        
        /** HP変更,ノックバック: プレイヤーが直接ダメージを与える際に呼ぶ */
        public function damaged(room:Room, amount:int, knockback:int):void {
            _effectColorOffset = 300;
            EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DAMAGED_ACTOR,
                _currentPosition.x,
                _currentPosition.y,
                { num: amount, color: 0xFFCC44, isEnemy: true }
            ));
            
            _hp = Math.max(0, _hp - amount);
            _spawnPosition.x -= knockback;
            
            room.setAttribute(_id + "." + Enemy.ATTR_DAMAGE,
                UPCConv.toCode((_hp << 16) + amount) + "," + UPCConv.toCode(_spawnPosition.x)
            );
            
            if (_hp <= 0) { EventManager.instance.dispatchEvent(new KillEvent(_id)); }
        }
        
        /** HP変更,ノックバック: サーバーから更新メッセージを受け取った際に呼ぶ */
        public function damagedByOther(hp:int, amount:int, spawnX:int, bySelf:Boolean):void {
            if (_hp != int.MAX_VALUE && amount > 0 && !bySelf) {
                _effectColorOffset = 300;
                
                if (SaveData.instance.popup) {
                    EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DAMAGED_ACTOR,
                        _currentPosition.x,
                        _currentPosition.y,
                        { num: amount, color: 0xFFFFAA, isEnemy: true }
                    ));
                }
            }
            if (hp < _hp) { _hp = hp; }
            if (spawnX < _spawnPosition.x) { _spawnPosition.x = spawnX; }
        }
        
        public function update(serverTime:Number, elapsedTime:int):void {
            var lifeTime:Number = (serverTime - _spawnTime) % Enemy.TIME_MODULO;
            if (lifeTime > Enemy.TIME_MODULO - 5000) { lifeTime = 0; }
            _currentPosition.x = _spawnPosition.x + _vx * lifeTime / 1000;
            _worldTrans.tx = int(_currentPosition.x + Const.FIELD_OFFSET_X);
            _bounds.x = _currentPosition.x - Enemy.BOUNDS_HALF_WIDTH;
            _bounds.y = _currentPosition.y - Enemy.BOUNDS_HEIGHT;
            _body.update(elapsedTime, _worldTrans);
            _effectColorOffset = Math.max(0, _effectColorOffset - 60);
        }
        
        public function draw(target:BitmapData):void {
            var effect:ColorTransform = GeomPool.colorTransform(1, 1, 1, 1, _effectColorOffset, _effectColorOffset, _effectColorOffset);
            target.copyPixels(
                Assets.images["actorShadow"],
                GeomPool.rectangle(0, 0, 465, 465),
                GeomPool.point(_worldTrans.tx - 14, _worldTrans.ty - 4),
                null, null, true
            );
            _body.draw(target, effect);
        }
        
        public function drawOverlay(target:BitmapData):void {
            var hpRate:Number = Math.min(_hp, _maxHp) / _maxHp;
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 28, 32, 1), 0xFFFF0000);
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 28, 32 * hpRate, 1), 0xFF00FF00);
        }
        
        public function get id():int { return _id; }
        public function get hp():int { return _hp; }
        public function get isAlive():Boolean { return _hp > 0; }
        public function get str():int { return _str; }
        public function get x():Number { return _currentPosition.x; }
        public function get y():Number { return _currentPosition.y; }
        public function get bounds():Rectangle { return _bounds; }
        public function get depth():Number { return _currentPosition.y; }
    }
//}
//package ore.orelib.actors {
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import net.user1.reactor.Attribute;
    import net.user1.reactor.AttributeEvent;
    import net.user1.reactor.Room;
/*    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.UPCConv;
    import ore.orelib.data.Const;
    import ore.orelib.events.ActorEvent;
    import ore.orelib.events.EffectEvent;
    import ore.orelib.logic.Host;
*/    
    //public 
    class EnemyManager {
        private var _room:Room;
        private var _enemyList:Dictionary;
        private var _enemyPool:Vector.<Enemy>;
        private var _freeIDqueue:Vector.<int>;
        
        private static const MAX_ENEMIES:int = 250;
        
        public function EnemyManager(room:Room) {
            _room = room;
            _enemyList = new Dictionary();
            _enemyPool = new Vector.<Enemy>();
            _freeIDqueue = new Vector.<int>();
            for (var i:int = 0; i < EnemyManager.MAX_ENEMIES; i++) {
                _freeIDqueue.push(i);
            }
            
            _room.addEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
        }
        
        private function attributeUpdateHandler(event:AttributeEvent):void {
            var attr:Attribute = event.getChangedAttr();
            var delimiterIndex:int = attr.name.indexOf(".");
            var enemyID:int = int(attr.name.substring(0, delimiterIndex));
            var enemy:Enemy, IDindex:int, hp:int, spawnX:int;
            
            switch(attr.name.substring(delimiterIndex + 1)) {
                // 敵の出現と消滅
                case Enemy.ATTR_STATUS:
                {
                    delimiterIndex = attr.value.indexOf(",");
                    var maxHp_str_vx:int = UPCConv.toInt(attr.value.substring(0, delimiterIndex));
                    var spawnTime_spawnY_exists:int = UPCConv.toInt(attr.value.substring(delimiterIndex + 1));
                    var exists:int = spawnTime_spawnY_exists & 0x1;
                    
                    if (exists) {
                        // 敵の出現
                        enemy = (_enemyPool.length) ? _enemyPool.pop() : new Enemy();
                        
                        var attrDamage:String = _room.getAttribute(enemyID + "." + Enemy.ATTR_DAMAGE);
                        if (attrDamage) {
                            delimiterIndex = attrDamage.indexOf(",");
                            hp = UPCConv.toInt(attrDamage.substring(0, delimiterIndex)) >> 16;
                            spawnX = UPCConv.toInt(attrDamage.substring(delimiterIndex + 1));
                        } else {
                            hp = 0
                            spawnX = Const.FIELD_LEFT_BOUND;
                        }
                        
                        enemy.initialize(
                            enemyID,
                            maxHp_str_vx,
                            spawnTime_spawnY_exists >> 1,
                            hp,
                            spawnX
                        );
                        if (_enemyList[enemyID]) { deleteEnemy(_enemyList[enemyID]); }
                        _enemyList[enemyID] = enemy;
                        
                        IDindex = _freeIDqueue.indexOf(enemyID);
                        if (IDindex >= 0) { _freeIDqueue.splice(IDindex, 1); }
                        
                        EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, enemy));
                    } else {
                        // 敵の消滅
                        enemy = _enemyList[enemyID];
                        
                        IDindex = _freeIDqueue.indexOf(enemyID);
                        if (IDindex < 0) { _freeIDqueue.push(enemyID); }
                        
                        if (enemy) { deleteEnemy(enemy); }
                    }
                    break;
                }
                
                // ダメージ処理(HP0でサーバーから削除は、撃破したクライアントのPlayerクラスで行う)
                case Enemy.ATTR_DAMAGE:
                {
                    enemy = _enemyList[enemyID];
                    if (enemy) {
                        delimiterIndex = attr.value.indexOf(",");
                        var hp_damageAmount:int = UPCConv.toInt(attr.value.substring(0, delimiterIndex));
                        spawnX = UPCConv.toInt(attr.value.substring(delimiterIndex + 1));
                        
                        enemy.damagedByOther(
                            hp_damageAmount >> 16,
                            hp_damageAmount & 0xFFFF,
                            spawnX,
                            (attr.byClient && attr.byClient.isSelf())
                        );
                        
                        if (!enemy.isAlive) {
                            deleteEnemy(enemy);
                            EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DEAD_ENEMY, enemy.x, enemy.y));
                        }
                    }
                    break;
                }
                
                default: { break; }
            }
        }
        
        private function deleteEnemy(enemy:Enemy):void {
            delete _enemyList[enemy.id];
            _enemyPool.push(enemy);
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.REMOVE, enemy));
        }
        
        public function update(serverTime:Number, elapsedTime:int, isHost:Boolean):void {
            for each(var enemy:Enemy in _enemyList) {
                // 撃破されていたら削除して次へ
                if (!enemy.isAlive) {
                    deleteEnemy(enemy);
                    EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DEAD_ENEMY, enemy.x, enemy.y));
                    continue;
                }
                
                enemy.update(serverTime, elapsedTime);
                
                // 自分がホストで、敵が画面右端に到達していたらサーバーから削除
                if (isHost && enemy.x > Const.FIELD_RIGHT_BOUND) {
                    deleteEnemy(enemy);
                    _room.setAttribute(enemy.id + "." + Enemy.ATTR_STATUS, "," + UPCConv.toCode(0));
                    _room.setAttribute(Host.ATTR_NUM_CONTRACTS, "%v+1", true, false, true);
                }
            }
        }
        
        /** 引数で与えた境界と衝突している敵のリストを取得する */
        public function acquireCollidingEnemies(bounds:Rectangle):Vector.<Enemy> {
            var result:Vector.<Enemy> = new Vector.<Enemy>();
            
            for each(var enemy:Enemy in _enemyList) {
                var enemyBounds:Rectangle = enemy.bounds;
                if (
                    bounds.top < enemyBounds.bottom && 
                    bounds.bottom > enemyBounds.top && 
                    bounds.left < enemyBounds.right &&
                    bounds.right > enemyBounds.left
                ) {
                    result.push(enemy);
                }
            }
            result.sort(compareXOfEnemy);
            
            return result;
        }
        
        private function compareXOfEnemy(a:Enemy, b:Enemy):Number {
            return (a.x < b.x) ? 1 : -1; // xが大きい順に並べる
        }
        
        /** 空きIDを取得する（無ければ-1を返す） */
        public function acquireFreeID():int {
            return (_freeIDqueue.length) ? _freeIDqueue.shift() : -1;
        }
        
        public function removeEventListeners():void {
            _room.removeEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
        }
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
/*    import ore.orelib.anim.Blood;
    import ore.orelib.anim.Explosion;
    import ore.orelib.anim.PopUp;
    import ore.orelib.assets.PlayingView;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.events.EffectEvent;
    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class EffectManager {
        private var _view:PlayingView;
        private var _popUpList:Vector.<PopUp>;
        private var _popUpPool:Vector.<PopUp>;
        private var _explosionList:Vector.<Explosion>;
        private var _explosionPool:Vector.<Explosion>;
        private var _bloodList:Vector.<Blood>;
        private var _bloodPool:Vector.<Blood>;
        
        private var _shape:Shape;
        private var _meleeGradientBox:Matrix;
        
        private static const FILTERS_NONE:Array = [];
        private static const FILTERS_ROSEBOW:Array = [new GlowFilter(0xFF88FF, 1, 2, 2, 4)];
        private static const FILTERS_BLACKBOW:Array = [new GlowFilter(0x8844CC, 1, 2, 2, 4)];
        private static const SHOOTING_ALPHAS:Array = [1, 0];
        private static const EXPLOSIVE_COLORS:Array = [0xFFFFFF, 0xFFFFFF];
        private static const MELEE_COLORS:Array = [0x88CCFF, 0xFFFFFF];
        private static const MELEE_ALPHAS:Array = [0.5, 1];
        private static const RATIOS:Array = [0, 255];
        
        public function EffectManager(view:PlayingView) {
            _view = view;
            _popUpList = new Vector.<PopUp>();
            _popUpPool = new Vector.<PopUp>();
            _explosionList = new Vector.<Explosion>();
            _explosionPool = new Vector.<Explosion>();
            _bloodList = new Vector.<Blood>();
            _bloodPool = new Vector.<Blood>();
            
            _shape = new Shape();
            _meleeGradientBox = new Matrix();
            _meleeGradientBox.createGradientBox(100, 55, Math.PI / 2);
            
            EventManager.instance.addEventListener(EffectEvent.ATTACK_WEAPON, attackWeaponHandler);
            EventManager.instance.addEventListener(EffectEvent.EMIT_GAS, emitGasHandler);
            EventManager.instance.addEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
            EventManager.instance.addEventListener(EffectEvent.DAMAGED_PLAYER, damagedPlayerHandler);
            EventManager.instance.addEventListener(EffectEvent.DAMAGED_ACTOR, damagedActorHandler);
            EventManager.instance.addEventListener(EffectEvent.DEAD_ENEMY, deadEnemyHandler);
        }
        
        private function attackWeaponHandler(event:EffectEvent):void {
            var attackType:int = WeaponSmith.acquireAttackTypeOf(event.option.id);
            _shape.filters = EffectManager.FILTERS_NONE;
            var g:Graphics = _shape.graphics; g.clear(); 
            var matrix:Matrix;
            
            switch(attackType) {
                case Const.ATTACKTYPE_SHOOTING:
                {
                    var color:uint;
                    switch(event.option.id) {
                        case Const.WEAPON_ROSEBOW:
                        {
                            color = 0xFFFFFF;
                            _shape.filters = EffectManager.FILTERS_ROSEBOW;
                            break;
                        }
                        case Const.WEAPON_BLACKBOW:
                        {
                            color = 0xFF88FF;
                            _shape.filters = EffectManager.FILTERS_BLACKBOW;
                            break;
                        }
                        default:
                        {
                            switch(event.option.id) {
                                case Const.WEAPON_PISTOL: { addMuzzleFlash(event.x, event.y, 20); break; }
                                case Const.WEAPON_MASKET: { addMuzzleFlash(event.x, event.y, 36); break; }
                                case Const.WEAPON_MINIMI: { addMuzzleFlash(event.x, event.y, 38); break; }
                                default: { break; }
                            }
                            color = 0xFFFF00 + uint(0x88 * Math.random());
                            break;
                        }
                    }
                    
                    // 射線表示しないならここで終了
                    if (!(SaveData.instance.fireline || event.option.bySelf)) { break; }
                    // ティロフィナーレ用特殊エフェクト
                    if (event.option.id == Const.WEAPON_TIROFINALE) {
                        _view.effect.copyPixels(Assets.images["tirofinale"],
                            GeomPool.rectangle(0, 0, 380, 80),
                            GeomPool.point(
                                event.x - 400 + Const.FIELD_OFFSET_X,
                                event.y - 60 + Const.FIELD_OFFSET_Y
                            ),
                            null, null, true
                        );
                        break;
                    }
                    
                    matrix = GeomPool.matrix();
                    matrix.createGradientBox(event.option.carry, 1);
                    g.beginGradientFill(
                        GradientType.LINEAR,
                        [color, color],
                        EffectManager.SHOOTING_ALPHAS,
                        EffectManager.RATIOS,
                        matrix
                    );
                    g.drawRect(0, 0, event.option.carry, 1);
                    g.endFill();
                    _view.effect.draw(_shape,
                        GeomPool.matrix(1, 0, 0, 1,
                            int(event.x - 8 - event.option.carry + Const.FIELD_OFFSET_X),
                            int(event.y - 20 + int(9 * Math.random()) + Const.FIELD_OFFSET_Y)
                        ),
                        GeomPool.colorTransform()
                    );
                    break;
                }
                
                case Const.ATTACKTYPE_EXPLOSIVE:
                {
                    if (SaveData.instance.explosion || event.option.bySelf) {
                        var explosion:Explosion = (_explosionPool.length) ? _explosionPool.pop() : new Explosion();
                        explosion.initialize(
                            event.x - 8 - event.option.carry,
                            event.y - 20,
                            event.option.range,
                            (event.option.id == Const.WEAPON_EXTINGUISHER) ? 255 : 0
                        );
                        _explosionList.push(explosion);
                    }
                    
                    if (event.option.id != Const.WEAPON_EXTINGUISHER) {
                        // ロケランはマズルフラッシュ追加
                        if (event.option.id == Const.WEAPON_RPG7) { addMuzzleFlash(event.x, event.y, 18); }
                        // 射線表示しないならここで終了
                        if (!(SaveData.instance.fireline || event.option.bySelf)) { break; }
                        
                        matrix = GeomPool.matrix();
                        matrix.createGradientBox(event.option.carry, 64);
                        g.beginGradientFill(
                            GradientType.LINEAR,
                            EffectManager.EXPLOSIVE_COLORS,
                            EffectManager.SHOOTING_ALPHAS,
                            EffectManager.RATIOS,
                            matrix
                        );
                        
                        // パイプ爆弾は放物線、ロケランは直線
                        if (event.option.id == Const.WEAPON_PIPEBOMB) {
                            g.moveTo(0, 63);
                            g.curveTo(event.option.carry / 2, 0, event.option.carry, 63);
                            g.lineTo(event.option.carry, 64);
                            g.curveTo(event.option.carry / 2, 1, 0, 64);
                            g.lineTo(0, 63);
                            g.endFill();
                            _view.effect.draw(_shape,
                                GeomPool.matrix(1, 0, 0, 1,
                                    int(event.x - 8 - event.option.carry + Const.FIELD_OFFSET_X),
                                    int(event.y - 18 + int(5 * Math.random()) - 64 + Const.FIELD_OFFSET_Y)
                                ),
                                GeomPool.colorTransform()
                            );
                        } else {
                            g.drawRect(0, 0, event.option.carry, 1);
                            g.endFill();
                            _view.effect.draw(_shape,
                                GeomPool.matrix(1, 0, 0, 1,
                                    int(event.x - 8 - event.option.carry + Const.FIELD_OFFSET_X),
                                    int(event.y - 18 + int(5 * Math.random()) + Const.FIELD_OFFSET_Y)
                                ),
                                GeomPool.colorTransform()
                            );
                        }
                    } else {
                        // 射線表示しないならここで終了
                        if (!(SaveData.instance.fireline || event.option.bySelf)) { break; }
                        
                        var quarterRange:int = event.option.range / 4;
                        var eighthRange:int = event.option.range / 8;
                        
                        matrix = GeomPool.matrix();
                        matrix.createGradientBox(event.option.carry, quarterRange, 0, 0, -eighthRange);
                        g.beginGradientFill(
                            GradientType.LINEAR,
                            EffectManager.EXPLOSIVE_COLORS,
                            EffectManager.SHOOTING_ALPHAS,
                            EffectManager.RATIOS,
                            matrix
                        );
                        g.moveTo(event.option.carry, eighthRange);
                        g.lineTo(0, 0);
                        g.lineTo(0, quarterRange);
                        g.moveTo(event.option.carry, eighthRange);
                        g.endFill();
                        _view.effect.draw(_shape,
                            GeomPool.matrix(1, 0, 0, 1,
                                event.x - 8 - event.option.carry + Const.FIELD_OFFSET_X,
                                event.y - 16 - eighthRange + Const.FIELD_OFFSET_Y
                            ),
                            GeomPool.colorTransform()
                        );
                    }
                    break;
                }
                
                case Const.ATTACKTYPE_MELEE:
                {
                    g.beginGradientFill(
                        GradientType.LINEAR,
                        EffectManager.MELEE_COLORS,
                        EffectManager.MELEE_ALPHAS,
                        EffectManager.RATIOS,
                        _meleeGradientBox
                    );
                    g.moveTo(event.option.carry + 8, 0);
                    g.curveTo(0, 0, 0, 52);
                    g.lineTo(21, 40);
                    g.curveTo(10, 10, event.option.carry + 8, 0);
                    g.endFill();
                    _view.effect.draw(_shape,
                        GeomPool.matrix(1, 0, 0, 1,
                            int(event.x - 8 - event.option.carry + Const.FIELD_OFFSET_X),
                            int(event.y - 40 + Const.FIELD_OFFSET_Y)
                        ),
                        GeomPool.colorTransform()
                    );
                    break;
                }
                
                default: { break; }
            }
        }
        
        private function addMuzzleFlash(x:int, y:int, offsetX:int):void {
            var muzzleFlashes:Vector.<BitmapData> = Assets.images["muzzleFlashes"];
            _view.effect.copyPixels(
                muzzleFlashes[int(muzzleFlashes.length * Math.random())],
                GeomPool.rectangle(0, 0, 32, 32),
                GeomPool.point(
                    int(x - offsetX - 32 + Const.FIELD_OFFSET_X),
                    int(y - 34 + int(5 * Math.random()) + Const.FIELD_OFFSET_Y)
                ),
                null, null, true
            );
        }
        
        private function emitGasHandler(event:EffectEvent):void {
            var explosions:Vector.<BitmapData> = Assets.images["explosions"];
            
            var matrix:Matrix = GeomPool.matrix(0.2, 0, 0, 0.2, -15, -15);
            matrix.translate(
                int(event.x + 8 * Math.random() - 4 + Const.FIELD_OFFSET_X),
                int(event.y + 8 * Math.random() - 32 + Const.FIELD_OFFSET_Y)
            );
            
            _view.effect.draw(
                explosions[int(explosions.length * Math.random())],
                matrix,
                GeomPool.colorTransform(1, 1, 1, 1, 0, 255, 0)
            );
        }
        
        private function godBlessHandler(event:EffectEvent):void {
            _view.effect.copyPixels(
                Assets.images["madoCircle"],
                GeomPool.rectangle(0, 0, 106, 106),
                GeomPool.point(
                    int(event.x - 53 + Const.FIELD_OFFSET_X),
                    int(event.y - 69 + Const.FIELD_OFFSET_Y)
                ),
                null, null, true
            );
        }
        
        private function damagedPlayerHandler(event:EffectEvent):void {
            _view.effect.copyPixels(
                Assets.images["damagedScreen"],
                GeomPool.rectangle(0, 0, 465, 465),
                GeomPool.point(0, 0),
                null, null, true
            );
        }
        
        private function damagedActorHandler(event:EffectEvent):void {
            var popUp:PopUp = (_popUpPool.length) ? _popUpPool.pop() : new PopUp();
            popUp.initialize(event.x, event.y, event.option.num, event.option.color);
            _popUpList.push(popUp);
            _view.overlay.addChild(popUp.overlay);
            
            if (event.option.isEnemy && SaveData.instance.grotesque) {
                var bloods:Vector.<BitmapData> = Assets.images["bloods"];
                _view.ground.draw(
                    bloods[int(bloods.length * Math.random())],
                    GeomPool.matrix(2, 0, 0, 0.5,
                        int(event.x - 16 + Const.FIELD_OFFSET_X),
                        int(event.y - 4 + Const.FIELD_OFFSET_Y)
                    ),
                    GeomPool.colorTransform(0.8, 0.8, 0.8, 0.8),
                    BlendMode.HARDLIGHT,
                    null, true
                );
            }
        }
        
        private function deadEnemyHandler(event:EffectEvent):void {
            if (!SaveData.instance.qblimb) { return; }
            
            var impacts:Vector.<BitmapData> = Assets.images["impacts"];
            _view.effect.copyPixels(
                impacts[int(impacts.length * Math.random())],
                GeomPool.rectangle(0, 0, 64, 64),
                GeomPool.point(
                    int(event.x - 32 + Const.FIELD_OFFSET_X),
                    int(event.y - 44 + Const.FIELD_OFFSET_Y)
                ),
                null, null, true
            );
            
            var blood:Blood = (_bloodPool.length) ? _bloodPool.pop() : new Blood();
            blood.initialize(event.x, event.y);
            _bloodList.push(blood);
            
            if (SaveData.instance.grotesque) {
                _view.ground.draw(
                    impacts[int(impacts.length * Math.random())],
                    GeomPool.matrix(1, 0, 0, 0.25,
                        int(event.x - 32 + Const.FIELD_OFFSET_X),
                        int(event.y - 8 + Const.FIELD_OFFSET_Y)
                    ),
                    GeomPool.colorTransform(1, 1, 1, 0.8),
                    BlendMode.HARDLIGHT,
                    null, true
                );
            }
        }
        
        public function update():void {
            var i:int;
            for (i = _popUpList.length - 1; i >= 0; i--) {
                var popUp:PopUp = _popUpList[i];
                popUp.update();
                
                if (!popUp.exists) {
                    _view.overlay.removeChild(popUp.overlay);
                    _popUpList.splice(_popUpList.indexOf(popUp), 1);
                    _popUpPool.push(popUp);
                }
            }
            
            for (i = _explosionList.length - 1; i >= 0; i--) {
                var explosion:Explosion = _explosionList[i];
                explosion.update(_view.effect);
                
                if (!explosion.exists) {
                    _explosionList.splice(_explosionList.indexOf(explosion), 1);
                    _explosionPool.push(explosion);
                }
            }
            
            for (i = _bloodList.length - 1; i >= 0; i--) {
                var blood:Blood = _bloodList[i];
                blood.update(_view.effect);
                
                if (!blood.exists) {
                    _bloodList.splice(_bloodList.indexOf(blood), 1);
                    _bloodPool.push(blood);
                }
            }
        }
        
        public function removeEventListeners():void {
            EventManager.instance.removeEventListener(EffectEvent.ATTACK_WEAPON, attackWeaponHandler);
            EventManager.instance.removeEventListener(EffectEvent.EMIT_GAS, emitGasHandler);
            EventManager.instance.removeEventListener(EffectEvent.GOD_BLESS, godBlessHandler);
            EventManager.instance.removeEventListener(EffectEvent.DAMAGED_PLAYER, damagedPlayerHandler);
            EventManager.instance.removeEventListener(EffectEvent.DAMAGED_ACTOR, damagedActorHandler);
            EventManager.instance.removeEventListener(EffectEvent.DEAD_ENEMY, deadEnemyHandler);
        }
    }
//}
//package ore.orelib.anim {
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    
    //public 
    interface IAnim {
        function transition(state:int):void;
        function update(elapsedTime:int, parentWorldTrans:Matrix):void;
        function draw(target:BitmapData, effect:ColorTransform = null, blendMode:String = null):void;
        function get worldTrans():Matrix;
    }
//}
//package ore.orelib.anim {
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    
    //public 
    class AbstractAnim implements IAnim {
        protected var _image:BitmapData;
        protected var _state:int;
        protected var _frameCount:int;
        protected var _timeCount:int;
        protected var _worldTrans:Matrix;
        
        public function AbstractAnim() {
            _image = null;
            _state = 0;
            _frameCount = _timeCount = 0;
            _worldTrans = new Matrix();
        }
        
        public function transition(state:int):void {
            if (_state != state) {
                _state = state;
                _frameCount = _timeCount = 0;
            }
        }
        
        public function update(elapsedTime:int, parentWorldTrans:Matrix):void {
            _frameCount++;
            _timeCount += elapsedTime;
            _worldTrans.identity();
            _worldTrans.concat(parentWorldTrans);
        }
        
        public function draw(target:BitmapData, effect:ColorTransform = null, blendMode:String = null):void {
            var smoothing:Boolean = (_worldTrans.b != 0 || _worldTrans.c != 0);
            target.draw(_image, _worldTrans, effect, blendMode, null, smoothing);
        }
        
        public final function get worldTrans():Matrix { return _worldTrans; }
    }
//}
//package ore.orelib.anim {
    import flash.geom.Matrix;
/*    import ore.orelib.commons.Assets;
*/    
    //public 
    class BodyAnim extends AbstractAnim implements IAnim {
        private var _imageIndex:int;
        private var _imageOffset:int;
        
        public static const IDLE:int = 0;
        public static const RUN:int = 1;
        public static const RECOVER:int = 2;
        
        public function BodyAnim(characterID:int) {
            _imageIndex = characterID;
            _imageOffset = 0;
        }
        
        public override function update(elapsedTime:int, parentWorldTrans:Matrix):void {
            _frameCount++;
            _worldTrans.identity();
            _worldTrans.translate( -8, -16);
            _worldTrans.scale(2, 2);
            _worldTrans.concat(parentWorldTrans);
            
            switch(_state) {
                case BodyAnim.RUN:
                {
                    _imageOffset = (_frameCount % 10 < 5) ? 1 : 0;
                    break;
                }
                
                case BodyAnim.RECOVER:
                {
                    _imageOffset = 2;
                    break;
                }
                
                default:
                {
                    _imageOffset = 0;
                    break;
                }
            }
            
            _image = Assets.images["characters"][_imageIndex + _imageOffset];
        }
    }
//}
//package ore.orelib.anim {
    import flash.geom.Matrix;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.data.Const;
*/    
    //public 
    class ArmAnim extends AbstractAnim implements IAnim {
        private var _angle:Number;
        
        public static const HOLD:int = 0;
        public static const SWING:int = 1;
        public static const RECOIL:int = 2;
        public static const SWAP:int = 3;
        
        public function ArmAnim() {
            _image = Assets.images["characters"][17];
        }
        
        public override function update(elapsedTime:int, parentWorldTrans:Matrix):void {
            _frameCount++;
            _timeCount += elapsedTime;
            
            switch(_state) {
                case ArmAnim.SWING:
                {
                    _angle = (_frameCount > 2) ? -75 : 75;
                    if (_frameCount > 4) { transition(ArmAnim.HOLD); }
                    break;
                }
                
                case ArmAnim.RECOIL:
                {
                    _angle = 5;
                    if (_frameCount > 1) { transition(ArmAnim.HOLD); }
                    break;
                }
                
                case ArmAnim.SWAP:
                {
                    _angle = 45;
                    if (_timeCount > Const.PLAYER_SWAP_TIME) { transition(ArmAnim.HOLD); }
                    break;
                }
                
                default:
                {
                    _angle = 0;
                    break;
                }
            }
            
            _worldTrans.identity();
            _worldTrans.translate( -8, -8);
            if (_angle != 0) { _worldTrans.rotate(_angle * Const.DEGREES_TO_RADIANS); }
            _worldTrans.translate(6, 10);
            _worldTrans.concat(parentWorldTrans);
        }
    }
//}
//package ore.orelib.anim {
    import flash.geom.Matrix;
/*    import ore.orelib.commons.Assets;
*/    
    //public 
    class WeaponAnim extends AbstractAnim implements IAnim {
        
        public function WeaponAnim(weaponID:int) {
            _state = weaponID;
            _image = Assets.images["weapons"][_state];
        }
        
        public override function update(elapsedTime:int, parentWorldTrans:Matrix):void {
            _timeCount += elapsedTime;
            _worldTrans.identity();
            //_worldTrans.translate( -16, -16);
            _worldTrans.translate( -11, -8);
            //_worldTrans.translate(5, 8);
            _worldTrans.concat(parentWorldTrans);
            
            if (_timeCount > 200) {
                _image = Assets.images["weapons"][_state];
            }
        }
    }
//}
//package ore.orelib.anim {
    import flash.display.DisplayObject;
    import flash.filters.GlowFilter;
    import flash.text.TextField;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
*/    
    //public 
    class PopUp {
        private var _text:TextField;
        private var _frameCount:int;
        
        public function PopUp() {
            _text = 
                new TextBuilder().align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x440000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontSize(12)
                .size(50, 20).build("0");
            _frameCount = 0;
        }
        
        public function initialize(x:Number, y:Number, num:int, color:uint):void {
            _text.x = x - 25 + Const.FIELD_OFFSET_X;
            _text.y = y - 20 + Const.FIELD_OFFSET_Y;
            _text.text = num.toString();
            _text.textColor = color;
            _text.alpha = 1;
            _frameCount = 0;
        }
        
        public function update():void {
            _frameCount++;
            _text.y -= 3;
            if (_frameCount > 5) {
                _text.alpha -= 0.1;
            }
        }
        
        public function get overlay():DisplayObject { return _text; }
        public function get exists():Boolean { return _frameCount <= 10; }
    }
//}
//package ore.orelib.anim {
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.geom.Matrix;
    import flash.geom.Point;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.data.Const;
*/    
    //public 
    class Explosion {
        private var _position:Point;
        private var _scale:Number;
        private var _colorOffset:int;
        private var _frameCount:int;
        
        public function Explosion() {
            _position = new Point();
            _scale = 1;
            _frameCount = 0;
        }
        
        public function initialize(x:Number, y:Number, range:int, colorOffset:int = 0):void {
            _position.x = x;
            _position.y = y;
            _scale = range / 100;
            _colorOffset = colorOffset;
            _frameCount = 0;
        }
        
        public function update(target:BitmapData):void {
            _frameCount++;
            
            var matrix:Matrix = GeomPool.matrix(1, 0, 0, 1, -75, -75);
            matrix.scale(_scale, _scale);
            matrix.translate(
                int(_position.x + 16 * Math.random() - 8 + Const.FIELD_OFFSET_X),
                int(_position.y + 16 * Math.random() - 8 + Const.FIELD_OFFSET_Y)
            );
            
            var explosions:Vector.<BitmapData> = Assets.images["explosions"];
            target.draw(
                explosions[int(explosions.length * Math.random())],
                matrix,
                GeomPool.colorTransform(1, 1, 1, 1, _colorOffset, _colorOffset, _colorOffset),
                BlendMode.LIGHTEN, null, true
            );
        }
        
        public function get exists():Boolean { return _frameCount < 5; }
    }
//}
//package ore.orelib.anim {
    import flash.display.BitmapData;
    import flash.geom.Point;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.data.Const;
*/    
    //public 
    class Blood {
        private var _particleStarts:Vector.<Point>;
        private var _particleEnds:Vector.<Point>;
        private var _t:Number;
        private var _frameCount:int;
        
        private static const NUM_PARTICLES:int = 10;
        private static const TOTAL_FRAMES:int = 6;
        
        public function Blood() {
            _particleStarts = new Vector.<Point>();
            _particleEnds = new Vector.<Point>();
            for (var i:int = 0; i < Blood.NUM_PARTICLES; i++) {
                _particleStarts[i] = new Point();
                _particleEnds[i] = new Point();
            }
            _t = _frameCount = 0;
        }
        
        public function initialize(x:Number, y:Number):void {
            for (var i:int = 0; i < Blood.NUM_PARTICLES; i++) {
                _particleStarts[i].x = x - 8;
                _particleStarts[i].y = y - 20;
                _particleEnds[i].x = x - 104 + 128 * Math.random();
                _particleEnds[i].y = y - 100 + 128 * Math.random();
            }
            _t = _frameCount = 0;
        }
        
        public function update(target:BitmapData):void {
            _frameCount++;
            _t = 1 - _frameCount / Blood.TOTAL_FRAMES;
            _t = _t * _t * _t;
            
            var bloods:Vector.<BitmapData> = Assets.images["bloods"];
            for (var i:int = 0; i < Blood.NUM_PARTICLES; i++) {
                var start:Point = _particleStarts[i];
                var end:Point = _particleEnds[i];
                target.copyPixels(
                    bloods[int(bloods.length * Math.random())],
                    GeomPool.rectangle(0, 0, 465, 465),
                    GeomPool.point(
                        int(easeOut(start.x, end.x) + Const.FIELD_OFFSET_X),
                        int(easeOut(start.y, end.y) + Const.FIELD_OFFSET_Y)
                    ),
                    null, null, true
                );
            }
        }
        
        private function easeOut(start:Number, end:Number):Number {
            return end - (end - start) * _t;
        }
        
        public function get exists():Boolean { return _frameCount < Blood.TOTAL_FRAMES; }
    }
//}
//package ore.orelib.events {
    import flash.display.DisplayObject;
    import flash.events.Event;
/*    import ore.orelib.actors.IActor;
*/    
    //public 
    class ActorEvent extends Event {
        private var _actor:IActor;
        private var _overlay:DisplayObject;
        
        public static const ADD:String = "actor_add";
        public static const REMOVE:String = "actor_remove";
        
        public function ActorEvent(type:String, actor:IActor, overlay:DisplayObject = null) {
            super(type);
            _actor = actor;
            _overlay = overlay;
        }
        
        public override function clone():Event { return new ActorEvent(type, _actor, _overlay); }
        public override function toString():String { return formatToString("ActorEvent", "type", "actor", "overlay"); }
        
        public function get actor():IActor { return _actor; }
        public function get overlay():DisplayObject { return _overlay; }
    }
//}
//package ore.orelib.events {
    import flash.events.Event;
    
    //public 
    class EffectEvent extends Event {
        private var _x:int;
        private var _y:int;
        private var _option:Object;
        
        public static const ATTACK_WEAPON:String = "effect_attack_weapon";
        public static const EMIT_GAS:String = "effect_emit_gas";
        public static const GOD_BLESS:String = "effect_god_bless";
        public static const DAMAGED_PLAYER:String = "effect_damaged_player";
        public static const DAMAGED_ACTOR:String = "effect_damaged_actor";
        public static const DEAD_ENEMY:String = "effect_dead_enemy";
        
        public function EffectEvent(type:String, x:int = 0, y:int = 0, option:Object = null) {
            super(type);
            _x = x;
            _y = y;
            _option = option;
        }
        
        public override function clone():Event { return new EffectEvent(type, _x, _y, _option); }
        public override function toString():String { return formatToString("EffectEvent", "type", "x", "y", "option"); }
        
        public function get x():int { return _x; }
        public function get y():int { return _y; }
        public function get option():Object { return _option; }
    }
//}
//package ore.orelib.events {
    import flash.events.Event;
    
    //public 
    class KillEvent extends Event {
        private var _enemyID:int;
        
        public static const KILL:String = "kill_kill";
        
        public function KillEvent(enemyID:int) {
            super(KillEvent.KILL);
            _enemyID = enemyID;
        }
        
        public override function clone():Event { return new KillEvent(_enemyID); }
        public override function toString():String { return formatToString("KillEvent"); }
        
        public function get enemyID():int { return _enemyID; }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import com.bit101.components.Style;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.filters.BlurFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    //public 
    class Artist {
        
        public static function createBackground():BitmapData {
            var result:BitmapData = new BitmapData(465, 465, true, 0x00FFFFFF);
            drawSky(result);
            drawBuildings(result);
            drawFog(result);
            drawGround(result);
            return result;
        }
        
        private static function drawSky(target:BitmapData):void {
            var sp:Sprite = new Sprite();
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(865, 400, Math.PI / 2, -200, -200);
            sp.graphics.beginGradientFill(GradientType.RADIAL, [0x000000, 0x707050, 0xFFFFFF], [1, 1, 1], [0, 128, 255], matrix);
            sp.graphics.drawRect(0, 0, 465, 155);
            sp.graphics.endFill();
            var noise:BitmapData = new BitmapData(465, 155, true, 0x00FFFFFF);
            noise.perlinNoise(155, 31, 8, 0, false, false);
            sp.filters = [new DisplacementMapFilter(noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN, 31, 93, DisplacementMapFilterMode.CLAMP)];
            
            target.draw(sp);
        }
        
        private static function drawBuildings(target:BitmapData):void {
            var near:BitmapData = new BitmapData(465, 155, true, 0x00FFFFFF);
            var far:BitmapData = near.clone();
            near.fillRect(new Rectangle(0, 55, 10, 100), 0xFF000000);
            near.fillRect(new Rectangle(100, 75, 50, 80), 0xFF000000);
            near.fillRect(new Rectangle(300, 55, 50, 100), 0xFF000000);
            near.fillRect(new Rectangle(450, 75, 15, 80), 0xFF000000);
            far.fillRect(new Rectangle(0, 140, 465, 15), 0xFF000000);
            far.fillRect(new Rectangle(0, 115, 50, 40), 0xFF000000);
            far.fillRect(new Rectangle(160, 115, 30, 40), 0xFF000000);
            far.fillRect(new Rectangle(250, 125, 30, 30), 0xFF000000);
            far.fillRect(new Rectangle(400, 105, 30, 50), 0xFF000000);
            
            var noise:BitmapData = new BitmapData(465, 155, true, 0x00FFFFFF);
            noise.perlinNoise(20, 50, 8, 0, false, false);
            near.applyFilter(near, near.rect, new Point(), new DisplacementMapFilter(noise, new Point(), 0, BitmapDataChannel.GREEN, 0, 20, DisplacementMapFilterMode.CLAMP));
            near.applyFilter(near, near.rect, new Point(), new BlurFilter(4, 4));
            far.applyFilter(far, far.rect, new Point(), new DisplacementMapFilter(noise, new Point(), 0, BitmapDataChannel.GREEN, 0, 20, DisplacementMapFilterMode.CLAMP));
            far.applyFilter(far, far.rect, new Point(), new BlurFilter(8, 8));
            
            target.draw(far);
            target.draw(near);
        }
        
        private static function drawFog(target:BitmapData):void {
            var sp:Sprite = new Sprite();
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(465, 155, Math.PI / 2, 0, 0);
            sp.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xFFFFFF], [0, 1], [128, 255], matrix);
            sp.graphics.drawRect(0, 0, 465, 155);
            sp.graphics.endFill();
            var noise:BitmapData = new BitmapData(465, 155, true, 0x00FFFFFF);
            noise.perlinNoise(155, 31, 8, 0, false, false);
            sp.filters = [new DisplacementMapFilter(noise, new Point(), 0, BitmapDataChannel.GREEN, 0, 31, DisplacementMapFilterMode.CLAMP)];
            
            target.draw(sp);
        }
        
        private static function drawGround(target:BitmapData):void {
            var sp:Sprite = new Sprite();
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(1465, 620, Math.PI / 2, -500, -310);
            sp.graphics.beginGradientFill(GradientType.RADIAL, [0xF0F0F0, 0x303030], [1, 1], [0, 255], matrix);
            sp.graphics.drawRect(0, 0, 465, 310);
            sp.graphics.endFill();
            
            target.draw(sp, new Matrix(1, 0, 0, 1, 0, 155));
        }
        
        public static function createActorShadow():BitmapData {
            var result:BitmapData = new BitmapData(28, 8, true, 0x00FFFFFF);
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(0x000000, 0.5);
            sp.graphics.drawEllipse(2, 2, 24, 4);
            sp.graphics.endFill();
            sp.filters = [new BlurFilter(4, 4)];
            result.draw(sp);
            return result;
        }
        
        public static function createMuzzleFlashes(num:int):Vector.<BitmapData> {
            var result:Vector.<BitmapData> = new Vector.<BitmapData>(num, true);
            for (var i:int = 0; i < result.length; i++) {
                result[i] = createMuzzleFlash(i);
            }
            return result;
        }
        
        private static function createMuzzleFlash(seed:int):BitmapData {
            var result:BitmapData = new BitmapData(32, 32, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(4, 4, 4, seed, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var ellipseHalfWidth:Number = 3 + 2 * Math.random();
            var ellipseCenterX:Number = 30 - ellipseHalfWidth;
            var controlY1:Number = 2 + 4 * Math.random();
            var controlX2:Number = 3 + 5 * Math.random();
            var controlY2:Number = 2 + 3 * Math.random();
            
            g.beginFill(0xFFFFFF);
            g.drawEllipse(30 - 2 * ellipseHalfWidth, 4, 2 * ellipseHalfWidth, 24);
            g.endFill();
            g.beginFill(0xFFFFFF);
            g.moveTo(2, 16);
            g.lineTo(ellipseCenterX, 16 - controlY1); g.lineTo(ellipseCenterX, 16 + controlY1);
            g.lineTo(2, 16);
            g.endFill();
            g.beginFill(0xFFFFFF);
            g.moveTo(16 - controlX2, 16 - 3 * controlY2);
            g.lineTo(ellipseCenterX, 16 - 2 * controlY2); g.lineTo(ellipseCenterX, 16); 
            g.lineTo(16 - controlX2, 16 - 3 * controlY2);
            g.moveTo(16 - controlX2, 16 + 3 * controlY2);
            g.lineTo(ellipseCenterX, 16 + 2 * controlY2); g.lineTo(ellipseCenterX, 16);
            g.lineTo(16 - controlX2, 16 + 3 * controlY2);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                4, 16, DisplacementMapFilterMode.CLAMP
            ));
            result.applyFilter(result, result.rect, new Point(), new GlowFilter(0xFFCC00, 1, 4, 4));
            return result;
        }
        
        public static function createTirofinaleFire():BitmapData {
            var result:BitmapData = new BitmapData(380, 80, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(38, 2, 4, 0, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            g.beginFill(0xFFFFFF); g.drawRect(0, 32, 360, 16); g.endFill();
            g.beginFill(0xFFFFFF, 0.8); g.drawEllipse(-90, 24, 180, 32); g.endFill();
            g.beginFill(0xFFFFFF, 0.8); g.drawEllipse(180, 24, 180, 32); g.endFill();
            g.beginFill(0xFFFFFF, 0.9); g.moveTo(330, 16); g.curveTo(390, 40, 330, 64); g.curveTo(334, 40, 330, 16); g.endFill();
            g.beginFill(0xFFFFFF, 0.9); g.moveTo(340, 8); g.curveTo(380, 40, 340, 72); g.curveTo(350, 40, 340, 8); g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                4, 8, DisplacementMapFilterMode.CLAMP
            ));
            result.applyFilter(result, result.rect, new Point(), new GlowFilter(0xFF8800, 1, 16, 16));
            return result;
        }
        
        public static function createExplosions(num:int):Vector.<BitmapData> {
            var result:Vector.<BitmapData> = new Vector.<BitmapData>(num, true);
            for (var i:int = 0; i < result.length; i++) {
                result[i] = createExplosion(i);
            }
            return result;
        }
        
        private static function createExplosion(seed:int):BitmapData {
            var result:BitmapData = new BitmapData(150, 150, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(25, 25, 8, seed, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(100, 100, 0, 25, 25);
            g.beginGradientFill(GradientType.RADIAL,
                [0xFFFFFF, 0xFFFF88, 0xFF8844, 0xCC4444, 0x000000],
                [0, 1, 1, 1, 0.5],
                [0, 128, 176, 192, 255],
                matrix
            );
            g.drawCircle(75, 75, 50);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                50, 50, DisplacementMapFilterMode.CLAMP
            ));
            return result;
        }
        
        public static function createImpacts(num:int):Vector.<BitmapData> {
            var result:Vector.<BitmapData> = new Vector.<BitmapData>(num, true);
            for (var i:int = 0; i < result.length; i++) {
                result[i] = createImpact(i);
            }
            return result;
        }
        
        private static function createImpact(seed:int):BitmapData {
            var result:BitmapData = new BitmapData(64, 64, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(8, 8, 4, seed, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(64, 64);
            g.beginGradientFill(GradientType.RADIAL, [0x000000, 0xFF0000], [1, 1], [0, 255], matrix);
            g.drawCircle(32, 32, 20);
            g.drawCircle(32, 32, 8);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                48, 48, DisplacementMapFilterMode.CLAMP
            ));
            return result;
        }
        
        public static function createBloods(num:int):Vector.<BitmapData> {
            var result:Vector.<BitmapData> = new Vector.<BitmapData>(num, true);
            for (var i:int = 0; i < result.length; i++) {
                result[i] = createBlood(i);
            }
            return result;
        }
        
        private static function createBlood(seed:int):BitmapData {
            var result:BitmapData = new BitmapData(16, 16, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(8, 8, 4, seed, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(16, 16);
            g.beginGradientFill(GradientType.RADIAL, [0x880000, 0xFF8888], [1, 1], [0, 255], matrix);
            g.drawCircle(8, 8, 2 + int(4 * Math.random()));
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                16, 16, DisplacementMapFilterMode.CLAMP
            ));
            return result;
        }
        
        public static function createDamagedScreen():BitmapData {
            var result:BitmapData = new BitmapData(465, 465, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(31, 31, 4, 0, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(465, 465);
            g.beginGradientFill(GradientType.RADIAL, [0xFF0000, 0xFF0000], [0.2, 0.4], [192, 255], matrix);
            g.drawRect(0, 0, 465, 465);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                155, 155, DisplacementMapFilterMode.CLAMP
            ));
            return result;
        }
        
        public static function createMadoCircle():BitmapData {
            var result:BitmapData = new BitmapData(106, 106, true, 0x00FFFFFF);
            
            var sp:Sprite = new Sprite();
            sp.scaleX = sp.scaleY = 1.5;
            var g:Graphics = sp.graphics;
            
            g.lineStyle(0, 0xFFFFFF, 1);
            g.drawCircle(34, 9, 5); g.drawCircle(34, 9, 3); g.drawCircle(34, 9, 1);
            g.drawCircle(23, 16, 4); g.drawCircle(23, 16, 2); g.drawCircle(23, 16, 1);
            g.drawCircle(48, 15, 3); g.drawCircle(48, 15, 2); g.drawCircle(48, 15, 1);
            g.drawCircle(34, 22, 7); g.drawCircle(34, 22, 4); g.drawCircle(34, 22, 2);
            g.drawCircle(15, 28, 6); g.drawCircle(15, 28, 4); g.drawCircle(15, 28, 2);
            g.drawCircle(56, 26, 7); g.drawCircle(56, 26, 5); g.drawCircle(56, 26, 2);
            g.drawCircle(39, 33, 3); g.drawCircle(39, 33, 2); g.drawCircle(39, 33, 1);
            g.drawCircle(34, 38, 2); g.drawCircle(34, 38, 1);
            g.drawCircle(64, 37, 4); g.drawCircle(64, 37, 2); g.drawCircle(64, 37, 1);
            g.drawCircle(27, 42, 3); g.drawCircle(27, 42, 2); g.drawCircle(27, 42, 1);
            g.drawCircle(42, 44, 3); g.drawCircle(42, 44, 2); g.drawCircle(42, 44, 1);
            g.drawCircle(54, 45, 7); g.drawCircle(54, 45, 4); g.drawCircle(54, 45, 2);
            g.drawCircle(13, 47, 7); g.drawCircle(13, 47, 5); g.drawCircle(13, 47, 2);
            g.drawCircle(44, 56, 3); g.drawCircle(44, 56, 2); g.drawCircle(44, 56, 1);
            g.drawCircle(23, 59, 5); g.drawCircle(23, 59, 3); g.drawCircle(23, 59, 2);
            g.drawCircle(34, 64, 3); g.drawCircle(34, 64, 2); g.drawCircle(34, 64, 1);
            
            g.moveTo(31, 10); g.lineTo(24, 15);
            g.moveTo(39, 17); g.lineTo(39, 13); g.lineTo(45, 13);
            g.moveTo(22, 17); g.lineTo(15, 22);
            g.moveTo(50, 17); g.lineTo(54, 21);
            g.moveTo(27, 22); g.lineTo(21, 27);
            g.moveTo(34, 29); g.lineTo(34, 36);
            g.moveTo(34, 30); g.lineTo(42, 36);
            g.moveTo(11, 33); g.lineTo(8, 33); g.lineTo(8, 42);
            g.moveTo(20, 32); g.lineTo(23, 35); g.lineTo(34, 35);
            g.moveTo(27, 35); g.lineTo(27, 39);
            g.moveTo(50, 29); g.lineTo(35, 43);
            g.moveTo(60, 30); g.lineTo(63, 33);
            g.moveTo(34, 40); g.lineTo(34, 61);
            g.moveTo(39, 39); g.lineTo(41, 41);
            g.moveTo(24, 44); g.lineTo(21, 47);
            g.moveTo(20, 49); g.lineTo(27, 49); g.lineTo(34, 56);
            g.moveTo(34, 53); g.lineTo(40, 53); g.lineTo(47, 48);
            g.moveTo(41, 47); g.lineTo(44, 50);
            g.moveTo(26, 54); g.lineTo(29, 51);
            g.moveTo(28, 59); g.lineTo(34, 59);
            g.moveTo(37, 62); g.lineTo(51, 51);
            
            g.moveTo(12, 25); g.lineTo(12, 31);
            g.moveTo(57, 27); g.lineTo(60, 24);
            g.moveTo(14, 48); g.lineTo(18, 48);
            g.moveTo(49, 40); g.lineTo(52, 43);
            g.moveTo(56, 47); g.lineTo(59, 50);
            
            result.draw(sp, sp.transform.matrix);
            result.applyFilter(result, result.rect, new Point(), new GlowFilter(0xFF88FF, 1, 2, 2));
            return result;
        }
        
        public static function createPushButtonWithDeviceFont(x:Number, y:Number, label:String = "", handler:Function = null):PushButton {
            var tempEmbedFonts:Boolean = Style.embedFonts;
            var tempFontName:String = Style.fontName;
            var tempFontSize:Number = Style.fontSize;
            Style.embedFonts = false;
            Style.fontName = "_sans";
            Style.fontSize = 10;
            
            var result:PushButton = new PushButton(null, x, y, label, handler);
            
            Style.embedFonts = tempEmbedFonts;
            Style.fontName = tempFontName;
            Style.fontSize = tempFontSize;
            
            return result;
        }
        
        public static function drawWindow(graphics:Graphics, x:Number, y:Number, width:Number, height:Number):void {
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(width, height, Math.PI / 2, x, y);
            graphics.beginGradientFill(GradientType.LINEAR, [0x555577, 0x333344], [1, 1], [0, 255], matrix);
            graphics.drawRect(x, y, width, height);
            graphics.endFill();
        }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.CapsStyle;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.geom.Matrix;
    import flash.net.SharedObject;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerData;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.SaveData;
    import ore.orelib.logic.Calculator;
    import ore.orelib.logic.WeaponSmith;
*/    
    [Event(name = "change", type = "flash.events.Event")]
    //public 
    class StatusWindow extends Sprite {
        private var _selfID:String;
        private var _nameInput:TextField;
        private var _characterView:Bitmap;
        private var _characterNameLabel:TextField;
        private var _levelLabel:TextField;
        private var _nextLabel:TextField;
        private var _statusPointsLabel:TextField;
        private var _strLabel:TextField;
        private var _vitLabel:TextField;
        private var _dexLabel:TextField;
        private var _lucLabel:TextField;
        private var _strDetailLabel:TextField;
        private var _vitDetailLabel:TextField;
        private var _dexDetailLabel:TextField;
        private var _lucDetailLabel:TextField;
        private var _strButton:PushButton;
        private var _vitButton:PushButton;
        private var _dexButton:PushButton;
        private var _lucButton:PushButton;
        private var _skillLabel:TextField;
        
        public function StatusWindow(x:int, y:int, selfID:String) {
            drawBackground();
            this.x = x;
            this.y = y;
            
            _selfID = selfID;
            SaveData.instance.player.name ||= "魔法少女" + _selfID + "番";
            
            var builder:TextBuilder = new TextBuilder().autoSize().font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12);
            addChild(builder.size(200, 20).build("ステータス"));
            
            addChild(_nameInput = createNameInput());
            _nameInput.addEventListener(Event.CHANGE, changeName);
            
            addChild(_characterView = new Bitmap());
            _characterView.x = 5; _characterView.y = 50;
            
            addChild(_levelLabel = builder.pos(60, 52).size(40, 20).build("Lv."));
            addChild(_characterNameLabel = builder.pos(45, 0, true).size(100, 20).build("魔法少女"));
            addChild(builder.pos(60, 76).size(100, 20).build("次のLvまで"));
            addChild(_nextLabel = builder.align(TextBuilder.RIGHT).fontSize(16).size(120, 20).build("0"));
            
            builder.align(TextBuilder.LEFT).fontSize(12).pos(20, 84);
            addChild(builder.pos(0, 25, true).build("残りポイント"));
            addChild(builder.pos(0, 25, true).build("魔力"));
            addChild(builder.pos(0, 25, true).build("精神"));
            addChild(builder.pos(0, 25, true).build("敏捷"));
            addChild(builder.pos(0, 25, true).build("幸運"));
            
            builder.align(TextBuilder.RIGHT).fontSize(16).pos(115, 84).size(30, 20);
            addChild(_statusPointsLabel = builder.pos(0, 25, true).build("0"));
            builder.pos( -35, 0, true);
            addChild(_strLabel = builder.pos(0, 25, true).build("100"));
            addChild(_vitLabel = builder.pos(0, 25, true).build("100"));
            addChild(_dexLabel = builder.pos(0, 25, true).build("100"));
            addChild(_lucLabel = builder.pos(0, 25, true).build("100"));
            
            builder.fontSize(10).pos(95, 112).size(50, 20);
            addChild(_strDetailLabel = builder.pos(0, 25, true).build("(100)"));
            addChild(_vitDetailLabel = builder.pos(0, 25, true).build("(100)"));
            addChild(_dexDetailLabel = builder.pos(0, 25, true).build("(100)"));
            addChild(_lucDetailLabel = builder.pos(0, 25, true).build("(100)"));
            
            addChild(_strButton = createAddPointButton(135));
            addChild(_vitButton = createAddPointButton(160));
            addChild(_dexButton = createAddPointButton(185));
            addChild(_lucButton = createAddPointButton(210));
            
            builder.autoSize(false).fontSize(12);
            addChild(builder.align(TextBuilder.LEFT).pos(10, 242).size(100, 20).build("スキル"));
            addChild(_skillLabel = builder.align(TextBuilder.CENTER).pos(40, 242).size(150, 30).build("無し"));
            
            changeName();
            update();
        }
        
        private function drawBackground():void {
            Artist.drawWindow(graphics, 0, 20, 200, 255);
            graphics.lineStyle(2, 0xFFFFFF, 1, false, "normal", CapsStyle.NONE);
            graphics.moveTo(5, 104); graphics.lineTo(195, 104);
            graphics.moveTo(5, 236); graphics.lineTo(195, 236);
            graphics.lineStyle();
            Artist.drawWindow(graphics, 0, 280, 200, 48);
        }
        
        private function createNameInput():TextField {
            var result:TextField = new TextField();
            result.x = 10; result.y = 25;
            result.width = 180; result.height = 20;
            result.defaultTextFormat = new TextFormat("_sans", 14, 0x000000, null, null, null, null, null, TextFormatAlign.CENTER);
            result.background = true; result.backgroundColor = 0xFFFFFF;
            result.filters = [new BevelFilter(1, 225, 0xC0C0C0, 1, 0x404040, 1, 1, 1)];
            result.maxChars = 12;
            result.selectable = true;
            result.type = TextFieldType.INPUT;
            result.text = SaveData.instance.player.name;
            return result;
        }
        
        private function changeName(event:Event = null):void {
            _nameInput.text = _nameInput.text.replace(/[|<>]/g, "");
            SaveData.instance.player.name = _nameInput.text || "魔法少女" + _selfID + "番";
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        private function createAddPointButton(y:int):PushButton {
            var result:PushButton = new PushButton(null, 160, y, "+", addPoint);
            result.width = result.height = 20; result.draw();
            return result;
        }
        
        private function addPoint(event:MouseEvent):void {
            if (SaveData.instance.player.statusPoints > 0) {
                SaveData.instance.player.statusPoints--;
                switch(event.currentTarget) {
                    case _strButton: { SaveData.instance.player.status.str++; break; }
                    case _vitButton: { SaveData.instance.player.status.vit++; break; }
                    case _dexButton: { SaveData.instance.player.status.dex++; break; }
                    case _lucButton: { SaveData.instance.player.status.luc++; break; }
                    default: { break; }
                }
                SaveData.instance.flush();
            }
            
            update();
        }
        
        public function update(event:Event = null):void {
            var playerData:PlayerData = SaveData.instance.player;
            
            var bmd:BitmapData = new BitmapData(48, 48, true, 0x80FFFFFF);
            bmd.draw(Assets.images["characters"][17], new Matrix(3, 0, 0, 3, -6, 6));
            bmd.draw(Assets.images["characters"][playerData.characterID], new Matrix(3, 0, 0, 3));
            _characterView.bitmapData = bmd;
            switch(playerData.characterID) {
                case Const.CHARACTER_MADOKA: { _characterNameLabel.text = Const.CHARACTER_NAME_MADOKA; break; }
                case Const.CHARACTER_HOMURA: { _characterNameLabel.text = Const.CHARACTER_NAME_HOMURA; break; }
                case Const.CHARACTER_SAYAKA: { _characterNameLabel.text = Const.CHARACTER_NAME_SAYAKA; break; }
                case Const.CHARACTER_MAMI: { _characterNameLabel.text = Const.CHARACTER_NAME_MAMI; break; }
                case Const.CHARACTER_KYOKO: { _characterNameLabel.text = Const.CHARACTER_NAME_KYOKO; break; }
                case Const.CHARACTER_MADOGAMI: { _characterNameLabel.text = Const.CHARACTER_NAME_MADOGAMI; break; }
                case Const.CHARACTER_MEGAHOMU: { _characterNameLabel.text = Const.CHARACTER_NAME_MEGAHOMU; break; }
                case Const.CHARACTER_KUROSAYA: { _characterNameLabel.text = Const.CHARACTER_NAME_KUROSAYA; break; }
                case Const.CHARACTER_CHARLOTTE: { _characterNameLabel.text = Const.CHARACTER_NAME_CHARLOTTE; break; }
                case Const.CHARACTER_HITOMI: { _characterNameLabel.text = Const.CHARACTER_NAME_HITOMI; break; }
                default: { break; }
            }
            _levelLabel.text = "Lv." + playerData.level;
            _nextLabel.text = Math.max(0, int(playerData.next)).toString();
            
            _statusPointsLabel.text = playerData.statusPoints.toString();
            var status:PlayerStatus = Calculator.playerStatus(
                playerData.status,
                WeaponSmith.createWeaponFrom(SaveData.instance.inventory[0]),
                WeaponSmith.createWeaponFrom(SaveData.instance.inventory[1])
            );
            _strLabel.text = status.str.toString();
            _vitLabel.text = status.vit.toString();
            _dexLabel.text = status.dex.toString();
            _lucLabel.text = status.luc.toString();
            _strDetailLabel.text = "(" + playerData.status.str + ")";
            _vitDetailLabel.text = "(" + playerData.status.vit + ")";
            _dexDetailLabel.text = "(" + playerData.status.dex + ")";
            _lucDetailLabel.text = "(" + playerData.status.luc + ")";
            _strButton.enabled = _vitButton.enabled = _dexButton.enabled = _lucButton.enabled = (playerData.statusPoints > 0);
            _skillLabel.text = Calculator.skillDescription(playerData.characterID);
        }
    }
//}
//package ore.orelib.assets {
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.data.WeaponData;
*/    
    [Event(name = "change", type = "flash.events.Event")]
    //public 
    class InventoryWindow extends Sprite {
        private var _descriptionBounds:Rectangle;
        private var _descriptionWindow:WeaponDescriptionWindow;
        private var _items:Vector.<InventoryItem>;
        private var _selectedItem:InventoryItem;
        private var _selectBorder:Sprite;
        
        private static const ITEM_Y:Array = [64, 88, 132, 156, 180, 204, 228, 252, 276, 300, 324, 348, 20];
        
        public function InventoryWindow(x:int, y:int, descriptionBounds:Rectangle, gotNewWeapon:Boolean = false) {
            this.x = x;
            this.y = y;
            
            var builder:TextBuilder = new TextBuilder().autoSize()
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, 0, 400).fontColor(0xFFFFFF).fontSize(12).size(250, 20);
            if (gotNewWeapon) { addChild(builder.build("入手武器")); }
            addChild(builder.pos(0, 44).build("装備"));
            addChild(builder.pos(0, 112).build("所持品"));
            
            _descriptionBounds = descriptionBounds;
            _descriptionWindow = new WeaponDescriptionWindow();
            _items = new Vector.<InventoryItem>();
            for (var i:int = 0; i < 12; i++) {
                var item:InventoryItem = new InventoryItem(i);
                item.y = InventoryWindow.ITEM_Y[i];
                addChild(item);
                _items[i] = item;
            }
            if (gotNewWeapon) {
                item = new InventoryItem(12);
                item.y = InventoryWindow.ITEM_Y[12];
                addChild(item);
                _items[12] = item;
            } else {
                // 入手武器欄の武器を削除する
                SaveData.instance.inventory[12] = null;
                SaveData.instance.flush();
            }
            _selectedItem = null;
            _selectBorder = createSelectBorder();
            
            addEventListener(MouseEvent.CLICK, clickItemHandler);
            addEventListener(MouseEvent.MOUSE_OVER, showDescriptionWindow);
            addEventListener(MouseEvent.MOUSE_OUT, hideDescriptionWindow);
        }
        
        private function createSelectBorder():Sprite {
            var result:Sprite = new Sprite();
            result.graphics.lineStyle(1, 0xFFFF00, 1, false, "normal", CapsStyle.NONE, JointStyle.MITER);
            result.graphics.drawRect(0, 0, 250, 24);
            addChild(result);
            result.mouseEnabled = result.visible = false;
            return result;
        }
        
        private function clickItemHandler(event:MouseEvent):void {
            var item:InventoryItem = event.target as InventoryItem;
            if (!item) { return; }
            
            // 選択されていなかったら、選択状態にする
            if (!_selectedItem) {
                _selectedItem = item;
                _selectBorder.y = item.y;
                _selectBorder.visible = true;
                return;
            }
            
            // 同じ武器を選択・装備武器がはずれるのでなければ、武器の位置を交換する
            if (!(item == _selectedItem ||
                ((item == _items[0] || item == _items[1]) && !_selectedItem.exists) ||
                ((_selectedItem == _items[0] || _selectedItem == _items[1]) && !item.exists))
            ) {
                var index1:int = _items.indexOf(item);
                var index2:int = _items.indexOf(_selectedItem);
                
                var inventory:Array = SaveData.instance.inventory;
                var tempWeaponData:WeaponData = inventory[index1];
                _items[index1] = _selectedItem;
                inventory[index1] = inventory[index2];
                _items[index2] = item;
                inventory[index2] = tempWeaponData;
                
                var tempItemY:int = item.y;
                item.y = _selectedItem.y;
                _selectedItem.y = tempItemY;
                
                dispatchEvent(new Event(Event.CHANGE));
            }
            
            _selectedItem = null;
            _selectBorder.visible = false;
        }
        
        private function showDescriptionWindow(event:MouseEvent):void {
            var item:InventoryItem = event.target as InventoryItem;
            if (!item || !item.exists) { return; }
            
            _descriptionWindow.update(item.weapon);
            moveDescriptionWindow();
            
            addChild(_descriptionWindow);
            addEventListener(MouseEvent.MOUSE_MOVE, moveDescriptionWindow);
        }
        
        private function hideDescriptionWindow(event:MouseEvent):void {
            var item:InventoryItem = event.target as InventoryItem;
            if (!item) { return; }
            
            removeEventListener(MouseEvent.MOUSE_MOVE, moveDescriptionWindow);
            if (contains(_descriptionWindow)) { removeChild(_descriptionWindow); }
        }
        
        private function moveDescriptionWindow(event:MouseEvent = null):void {
            if (mouseX + _descriptionWindow.bounds.width + 5 > _descriptionBounds.right - 10) {
                _descriptionWindow.x = Math.max(_descriptionBounds.left + 10, mouseX - _descriptionWindow.bounds.right - 5);
            } else {
                _descriptionWindow.x = mouseX - _descriptionWindow.bounds.left + 5;
            }
            
            if (mouseY + _descriptionWindow.bounds.height + 5 > _descriptionBounds.bottom - 10) {
                _descriptionWindow.y = Math.max(_descriptionBounds.top + 10, mouseY - _descriptionWindow.bounds.bottom - 5);
            } else {
                _descriptionWindow.y = mouseY - _descriptionWindow.bounds.top + 5;
            }
        }
    }
//}
//package ore.orelib.assets {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.data.Weapon;
    import ore.orelib.data.WeaponData;
    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class InventoryItem extends Sprite {
        private var _weapon:Weapon;
        
        private static const ICON_OFFSET_X:Array = [3, 1, 0, 1, 1, 1, 3, 4, 1, 1, 1, 0, 0, 5];
        private static const ICON_OFFSET_Y:Array = [3, 3, 3, 1, 2, 3, 5, 3, 0, 0, 0, 0, 1, 5];
        
        public function InventoryItem(index:int) {
            buttonMode = true;
            draw();
            addEventListener(MouseEvent.ROLL_OVER, draw);
            addEventListener(MouseEvent.ROLL_OUT, draw);
            
            
            var data:WeaponData = SaveData.instance.inventory[index];
            if (!data) { return; }
            _weapon = WeaponSmith.createWeaponFrom(data);
            var icon:BitmapData = new BitmapData(25, 24, true, 0x00FFFFFF);
            icon.draw(
                Assets.images["weapons"][_weapon.id],
                new Matrix(1, 0, 0, 1, -InventoryItem.ICON_OFFSET_X[_weapon.id], -InventoryItem.ICON_OFFSET_Y[_weapon.id])
            );
            addChild(new Bitmap(icon));
            addChild(
                new TextBuilder().autoSize()
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(8)
                .pos(25, 0).size(100, 24).build(_weapon.name)
            );
        }
        
        private function draw(event:MouseEvent = null):void {
            graphics.clear();
            Artist.drawWindow(graphics, 0, 0, 250, 24);
            if (event && event.type == MouseEvent.ROLL_OVER) {
                graphics.beginFill(0xFFFFFF, 0.5);
                graphics.drawRect(0, 0, 250, 24);
                graphics.endFill();
            }
        }
        
        public function get exists():Boolean { return _weapon != null; }
        public function get weapon():Weapon { return _weapon; }
    }
//}
//package ore.orelib.assets {
    import flash.display.CapsStyle;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.TextField;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.Weapon;
    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class WeaponDescriptionWindow extends Sprite {
        private var _bounds:Rectangle;
        private var _nameLabel:TextField;
        private var _specLabels:Vector.<TextField>;
        
        public function WeaponDescriptionWindow() {
            mouseChildren = mouseEnabled = false;
            
            _bounds = new Rectangle();
            var builder:TextBuilder =
                new TextBuilder().align(TextBuilder.CENTER).autoSize()
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12)
                .pos(0, 0).size(250, 16);
            addChild(_nameLabel = builder.build("name"));
            _specLabels = new Vector.<TextField>(20, true);
            for (var i:int = 0; i < 20; i++) {
                _specLabels[i] = builder.build("mod");
            }
        }
        
        public function update(weapon:Weapon):void {
            var attackType:int = WeaponSmith.acquireAttackTypeOf(weapon.id);
            graphics.clear();
            _nameLabel.text = weapon.name;
            
            var posY:int = 26;
            for (var i:int = 0; i < 20; i++) {
                if (i < weapon.specs.length) {
                    var specLabel:TextField = _specLabels[i];
                    specLabel.y = posY;
                    specLabel.text = weapon.specs[i];
                    specLabel.textColor = weapon.specColors[i];
                    addChild(specLabel);
                    posY += 16;
                } else {
                    if (contains(_specLabels[i])) { removeChild(_specLabels[i]); }
                }
            }
            
            _bounds.x = 125 - 5 - this.width / 2;
            _bounds.y = -5;
            _bounds.width = this.width + 10;
            _bounds.height = this.height + 10;
            
            graphics.beginFill(0x000000, 0.8);
            graphics.drawRect(_bounds.x, _bounds.y, _bounds.width, _bounds.height);
            graphics.endFill();
            graphics.lineStyle(1, 0xFFFFFF, 1, false, "normal", CapsStyle.NONE);
            graphics.moveTo(_bounds.left + 5, 21);
            graphics.lineTo(_bounds.right - 5, 21);
        }
        
        public function get bounds():Rectangle { return _bounds; }
    }
//}
//package ore.orelib.assets {
    import flash.display.Sprite;
    import flash.text.TextField;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
*/    
    //public 
    class InfoWindow extends Sprite {
        
        public function InfoWindow(x:int, y:int) {
            Artist.drawWindow(graphics, 0, 0, 455, 22);
            
            this.x = x;
            this.y = y;
            
            var tf:TextField = new TextBuilder().autoSize()
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12)
                .size(455, 22).build(Const.INFO_MESSAGE);
            tf.mouseEnabled = tf.selectable = true;
            addChild(tf);
        }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.text.TextField;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerData;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.SaveData;
    import ore.orelib.logic.Calculator;
*/    
    [Event(name = "change", type = "flash.events.Event")]
    //public 
    class CharacterSelectionWindow extends Sprite {
        private var _characterViews:Vector.<Sprite>;
        private var _selectedCharacter:Sprite;
        private var _selectBorder:Sprite;
        private var _profile:Sprite;
        private var _nameLabel:TextField;
        private var _skillLabel:TextField;
        private var _changeButton:PushButton;
        private var _cancelButton:PushButton;
        
        public function CharacterSelectionWindow() {
            drawBackground();
            
            _characterViews = new Vector.<Sprite>();
            _selectedCharacter = null;
            for (var i:int = 0; i < 10; i++) {
                var view:Sprite = createCharacterView(
                    Const.CHARACTER_IDS[i],
                    92 + 58 * (i % 5),
                    150 + 58 * int(i / 5)
                );
                addChild(view);
                _characterViews.push(view);
                
                view.addEventListener(MouseEvent.CLICK, selectCharacter);
                view.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
                view.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            }
            _selectBorder = createSelectBorder();
            
            var builder:TextBuilder = new TextBuilder().autoSize().font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12);
            addChild(builder.pos(82, 120).size(300, 20).build("キャラクター変更"));
            addChild(_profile = new Sprite());
            _profile.addChild(builder.pos(137, 295).size(100, 20).build("スキル"));
            _profile.addChild(_nameLabel = builder.align(TextBuilder.CENTER).pos(82, 270).size(300, 20).build("名前"));
            _profile.addChild(_skillLabel = builder.autoSize(false).pos(167, 295).size(150, 30).build("無し"));
            addChild(builder.fontColor(0xFF0000).pos(82, 345).size(300, 30).build("キャラクターを変更すると、\nLvが5減少し、ポイントがリセットされます。"));
            _profile.visible = false;
            
            addChild(_changeButton = Artist.createPushButtonWithDeviceFont(102, 380, "変更する", changeCharacter));
            _changeButton.enabled = false;
            addChild(_cancelButton = Artist.createPushButtonWithDeviceFont(262, 380, "キャンセル", backToTitle));
        }
        
        private function drawBackground():void {
            graphics.beginFill(0x000000, 0.8);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            Artist.drawWindow(graphics, 82, 140, 300, 270);
            graphics.lineStyle(2, 0xFFFFFF, 1, false, "normal", CapsStyle.NONE);
            graphics.moveTo(87, 336); graphics.lineTo(377, 336);
        }
        
        private function createSelectBorder():Sprite {
            var result:Sprite = new Sprite();
            result.graphics.lineStyle(1, 0xFFFF00, 1, false, "normal", CapsStyle.NONE, JointStyle.MITER);
            result.graphics.drawRect(0, 0, 48, 48);
            addChild(result);
            result.mouseEnabled = result.visible = false;
            return result;
        }
        
        private function createCharacterView(characterID:int, x:int, y:int):Sprite {
            var result:Sprite = new Sprite();
            var bmd:BitmapData = new BitmapData(48, 48, true, 0x80FFFFFF);
            bmd.draw(Assets.images["characters"][17], new Matrix(3, 0, 0, 3, -6, 6));
            bmd.draw(Assets.images["characters"][characterID], new Matrix(3, 0, 0, 3));
            result.addChild(new Bitmap(bmd));
            result.x = x;
            result.y = y;
            result.buttonMode = true;
            return result;
        }
        
        private function selectCharacter(event:MouseEvent):void {
            var character:Sprite = event.currentTarget as Sprite;
            _selectedCharacter = character;
            _selectBorder.x = character.x;
            _selectBorder.y = character.y;
            _selectBorder.visible = true;
            _changeButton.enabled = true;
        }
        
        private function rollOverHandler(event:MouseEvent):void {
            var index:int = _characterViews.indexOf(event.currentTarget as Sprite);
            var characterID:int = Const.CHARACTER_IDS[index];
            updateProfile(characterID);
            _profile.visible = true;
        }
        
        private function rollOutHandler(event:MouseEvent):void {
            if (!_selectedCharacter) { _profile.visible = false; }
            
            var index:int = _characterViews.indexOf(_selectedCharacter);
            var characterID:int = Const.CHARACTER_IDS[index];
            updateProfile(characterID);
        }
        
        private function updateProfile(characterID:int):void {
            switch(characterID) {
                case Const.CHARACTER_MADOKA: { _nameLabel.text = Const.CHARACTER_NAME_MADOKA; break; }
                case Const.CHARACTER_HOMURA: { _nameLabel.text = Const.CHARACTER_NAME_HOMURA; break; }
                case Const.CHARACTER_SAYAKA: { _nameLabel.text = Const.CHARACTER_NAME_SAYAKA; break; }
                case Const.CHARACTER_MAMI: { _nameLabel.text = Const.CHARACTER_NAME_MAMI; break; }
                case Const.CHARACTER_KYOKO: { _nameLabel.text = Const.CHARACTER_NAME_KYOKO; break; }
                case Const.CHARACTER_MADOGAMI: { _nameLabel.text = Const.CHARACTER_NAME_MADOGAMI; break; }
                case Const.CHARACTER_MEGAHOMU: { _nameLabel.text = Const.CHARACTER_NAME_MEGAHOMU; break; }
                case Const.CHARACTER_KUROSAYA: { _nameLabel.text = Const.CHARACTER_NAME_KUROSAYA; break; }
                case Const.CHARACTER_CHARLOTTE: { _nameLabel.text = Const.CHARACTER_NAME_CHARLOTTE; break; }
                case Const.CHARACTER_HITOMI: { _nameLabel.text = Const.CHARACTER_NAME_HITOMI; break; }
                default: { break; }
            }
            _skillLabel.text = Calculator.skillDescription(characterID);
        }
        
        private function changeCharacter(event:MouseEvent):void {
            var index:int = _characterViews.indexOf(_selectedCharacter);
            var characterID:int = Const.CHARACTER_IDS[index];
            
            var playerData:PlayerData = SaveData.instance.player;
            playerData.characterID = characterID;
            playerData.level = Math.max(1, playerData.level - 5);
            playerData.next = Const.EXP_TABLE[playerData.level - 1];
            playerData.statusPoints = playerData.level + 1;
            playerData.status = new PlayerStatus(100, 100, 100, 100);
            SaveData.instance.flush();
            
            backToTitle();
            dispatchEvent(new Event(Event.CHANGE));
        }
        
        private function backToTitle(event:MouseEvent = null):void {
            _selectedCharacter = null;
            _selectBorder.visible = false;
            _profile.visible = false;
            _changeButton.enabled = false;
            parent.removeChild(this);
        }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
*/    
    //public 
    class InstructionWindow extends Sprite {
        private var _texts:Array;
        private var _titleLabel:TextField;
        private var _body:TextField;
        private var _naviLabel:TextField;
        private var _prevButton:PushButton;
        private var _nextButton:PushButton;
        private var _backToTitleButton:PushButton;
        private var _pageIndex:int = 0;
        
        public function InstructionWindow(texts:Array) {
            _texts = texts;
            drawBackground();
            
            var builder:TextBuilder = new TextBuilder().font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12);
            addChild(_titleLabel = builder.pos(32, 120).size(400, 20).build("タイトル"));
            builder.font(Const.FONT, 0, 0);
            addChild(_body = builder.pos(42, 150).size(380, 280).build("本文"));
            _body.mouseEnabled = _body.selectable = _body.wordWrap = true;
            addChild(_naviLabel = builder.align(TextBuilder.CENTER).pos(152, 410).size(50, 20).build("1 / 1"));
            
            addChild(_prevButton = Artist.createPushButtonWithDeviceFont(52, 410, "前の説明へ", prevButtonHandler));
            addChild(_nextButton = Artist.createPushButtonWithDeviceFont(202, 410, "次の説明へ", nextButtonHandler));
            addChild(_backToTitleButton = Artist.createPushButtonWithDeviceFont(312, 410, "タイトル画面に戻る", backToTitle));
            
            update();
        }
        
        private function drawBackground():void {
            graphics.beginFill(0x000000, 0.8);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            Artist.drawWindow(graphics, 32, 140, 400, 300);
        }
        
        private function prevButtonHandler(event:MouseEvent):void {
            _pageIndex--;
            update();
        }
        
        private function nextButtonHandler(event:MouseEvent):void {
            _pageIndex++;
            update();
        }
        
        private function update():void {
            _titleLabel.text = _texts[_pageIndex].title;
            _body.text = _texts[_pageIndex].body;
            _naviLabel.text = (_pageIndex + 1) + " / " + _texts.length;
            
            _prevButton.enabled = (_pageIndex > 0) ? true : false;
            _nextButton.enabled = (_pageIndex < _texts.length - 1) ? true : false; 
        }
        
        private function backToTitle(event:MouseEvent):void {
            _pageIndex = 0;
            update();
            parent.removeChild(this);
        }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.MouseEvent;
    import flash.text.TextField;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.commons.UnionStats;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
*/    
    //public 
    class SettingsWindow extends Sprite {
        private var _stats:UnionStats;
        
        private var _qualityValueLabel:TextField;
        private var _highlightValueLabel:TextField;
        private var _popupValueLabel:TextField;
        private var _firelineValueLabel:TextField;
        private var _explosionValueLabel:TextField;
        private var _qblimbValueLabel:TextField;
        private var _grotesqueValueLabel:TextField;
        private var _statsValueLabel:TextField;
        
        private var _qualityButton:PushButton;
        private var _highlightButton:PushButton;
        private var _popupButton:PushButton;
        private var _firelineButton:PushButton;
        private var _explosionButton:PushButton;
        private var _qblimbButton:PushButton;
        private var _grotesqueButton:PushButton;
        private var _statsButton:PushButton;
        private var _backToTitleButton:PushButton;
        
        public function SettingsWindow(stats:UnionStats) {
            _stats = stats;
            drawBackground();
            
            var builder:TextBuilder = new TextBuilder().autoSize().font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12);
            addChild(builder.pos(82, 120).size(300, 20).build("オプション"));
            builder.align(TextBuilder.CENTER).size(180, 30);
            addChild(builder.pos(92, 150).build("画質"));
            addChild(builder.pos(92, 180).build("自分のキャラクターを強調"));
            addChild(builder.pos(92, 210).build("他プレイヤーの与ダメージ表示"));
            addChild(builder.pos(92, 240).build("他プレイヤーの射線表示"));
            addChild(builder.pos(92, 270).build("他プレイヤーの爆発エフェクト"));
            addChild(builder.pos(92, 300).build("QB撃退エフェクト"));
            addChild(builder.pos(92, 330).build("血だまりスケッチ"));
            addChild(builder.pos(92, 360).build("Show Stats"));
            
            builder.size(30, 30);
            addChild(_qualityValueLabel = builder.pos(282, 150).build(getQualityValueLabelText()));
            addChild(_highlightValueLabel = builder.pos(282, 180).build(getBooleanValueText(SaveData.instance.highlight)));
            addChild(_popupValueLabel = builder.pos(282, 210).build(getBooleanValueText(SaveData.instance.popup)));
            addChild(_firelineValueLabel = builder.pos(282, 240).build(getBooleanValueText(SaveData.instance.fireline)));
            addChild(_explosionValueLabel = builder.pos(282, 270).build(getBooleanValueText(SaveData.instance.explosion)));
            addChild(_qblimbValueLabel = builder.pos(282, 300).build(getBooleanValueText(SaveData.instance.qblimb)));
            addChild(_grotesqueValueLabel = builder.pos(282, 330).build(getBooleanValueText(SaveData.instance.grotesque)));
            addChild(_statsValueLabel = builder.pos(282, 360).build(getBooleanValueText(SaveData.instance.stats)));
            
            addChild(_qualityButton = Artist.createPushButtonWithDeviceFont(322, 155, "変更", changeQuality));
            addChild(_highlightButton = Artist.createPushButtonWithDeviceFont(322, 185, "変更", changeHighlight));
            addChild(_popupButton = Artist.createPushButtonWithDeviceFont(322, 215, "変更", changePopup));
            addChild(_firelineButton = Artist.createPushButtonWithDeviceFont(322, 245, "変更", changeFireline));
            addChild(_explosionButton = Artist.createPushButtonWithDeviceFont(322, 275, "変更", changeExplosion));
            addChild(_qblimbButton = Artist.createPushButtonWithDeviceFont(322, 305, "変更", changeQblimb));
            addChild(_grotesqueButton = Artist.createPushButtonWithDeviceFont(322, 335, "変更", changeGrotesque));
            addChild(_statsButton = Artist.createPushButtonWithDeviceFont(322, 365, "change", changeStats));
            _qualityButton.width = _highlightButton.width = _popupButton.width = _firelineButton.width =
            _explosionButton.width = _qblimbButton.width = _grotesqueButton.width = _statsButton.width = 50;
            _qualityButton.draw(); _highlightButton.draw(); _popupButton.draw(); _firelineButton.draw();
            _explosionButton.draw(); _qblimbButton.draw(); _grotesqueButton.draw(); _statsButton.draw();
            
            addChild(_backToTitleButton = Artist.createPushButtonWithDeviceFont(182, 405, "タイトル画面に戻る", backToTitle));
            
        }
        
        private function drawBackground():void {
            graphics.beginFill(0x000000, 0.8);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            Artist.drawWindow(graphics, 82, 140, 300, 300);
        }
        
        private function getQualityValueLabelText():String {
            switch(SaveData.instance.quality) {
                case StageQuality.MEDIUM: { return "中"; }
                case StageQuality.LOW: { return "低"; }
                case StageQuality.HIGH:
                default: { return "高"; }
            }
        }
        
        private function getBooleanValueText(value:Boolean):String {
            return (value) ? "ON" : "OFF";
        }
        
        private function changeQuality(event:MouseEvent):void {
            var value:String = SaveData.instance.quality;
            switch(value) {
                case StageQuality.HIGH: { SaveData.instance.quality = StageQuality.MEDIUM; break; }
                case StageQuality.MEDIUM: { SaveData.instance.quality = StageQuality.LOW; break; }
                case StageQuality.LOW:
                default: { SaveData.instance.quality = StageQuality.HIGH; break; }
            }
            _qualityValueLabel.text = getQualityValueLabelText();
            
            stage.quality = SaveData.instance.quality;
        }
        
        private function changeHighlight(event:MouseEvent):void {
            SaveData.instance.highlight = !SaveData.instance.highlight;
            _highlightValueLabel.text = getBooleanValueText(SaveData.instance.highlight);
        }
        
        private function changePopup(event:MouseEvent):void {
            SaveData.instance.popup = !SaveData.instance.popup;
            _popupValueLabel.text = getBooleanValueText(SaveData.instance.popup);
        }
        
        private function changeFireline(event:MouseEvent):void {
            SaveData.instance.fireline = !SaveData.instance.fireline;
            _firelineValueLabel.text = getBooleanValueText(SaveData.instance.fireline);
        }
        
        private function changeExplosion(event:MouseEvent):void {
            SaveData.instance.explosion = !SaveData.instance.explosion;
            _explosionValueLabel.text = getBooleanValueText(SaveData.instance.explosion);
        }
        
        private function changeQblimb(event:MouseEvent):void {
            SaveData.instance.qblimb = !SaveData.instance.qblimb;
            _qblimbValueLabel.text = getBooleanValueText(SaveData.instance.qblimb);
        }
        
        private function changeGrotesque(event:MouseEvent):void {
            SaveData.instance.grotesque = !SaveData.instance.grotesque;
            _grotesqueValueLabel.text = getBooleanValueText(SaveData.instance.grotesque);
        }
        
        private function changeStats(event:MouseEvent):void {
            SaveData.instance.stats = !SaveData.instance.stats;
            _statsValueLabel.text = getBooleanValueText(SaveData.instance.stats);
            
            if (SaveData.instance.stats) {
                _stats.enable();
                stage.addChild(_stats);
            } else {
                _stats.disable();
                stage.removeChild(_stats);
            }
        }
        
        private function backToTitle(event:MouseEvent):void {
            parent.removeChild(this);
        }
    }
//}
//package ore.orelib.assets {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
/*    import ore.orelib.actors.IActor;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.events.ActorEvent;
    import ore.orelib.logic.Host;
    import ore.orelib.logic.Player;
*/    
    //public 
    class PlayingView extends Sprite {
        private var _actorList:Vector.<IActor>;
        private var _ground:BitmapData;
        private var _screen:BitmapData;
        private var _effect:BitmapData;
        private var _overlay:Sprite;
        private var _hud:HUD;
        
        public function PlayingView() {
            _actorList = new Vector.<IActor>();
            
            addChild(new Bitmap(_ground = Artist.createBackground()));
            addChild(new Bitmap(_screen = new BitmapData(465, 465, true, 0x00FFFFFF)));
            addChild(new Bitmap(_effect = new BitmapData(465, 465, true, 0x00FFFFFF)));
            addChild(_overlay = new Sprite());
            
            EventManager.instance.addEventListener(ActorEvent.ADD, addActorHandler);
            EventManager.instance.addEventListener(ActorEvent.REMOVE, removeActorHandler);
        }
        
        public function setupHUD(player:Player, roomNo:int):void {
            addChild(_hud = new HUD(player, roomNo));
        }
        
        private function addActorHandler(event:ActorEvent):void {
            _actorList.push(event.actor);
            if (event.overlay) { _overlay.addChild(event.overlay); }
        }
        
        private function removeActorHandler(event:ActorEvent):void {
            if (event.overlay) { _overlay.removeChild(event.overlay); }
            _actorList.splice(_actorList.indexOf(event.actor), 1);
        }
        
        public function update(player:Player, host:Host):void {
            var actor:IActor;
            _actorList.sort(compareDepthOfActor);
            _screen.lock();
            _screen.fillRect(GeomPool.rectangle(0, 0, 465, 465), 0x00FFFFFF);
            for each(actor in _actorList) { actor.draw(_screen); }
            player.drawHighlight(_screen);
            for each(actor in _actorList) { actor.drawOverlay(_screen); }
            _screen.unlock();
            _effect.colorTransform(GeomPool.rectangle(0, 0, 465, 465), GeomPool.colorTransform(1, 1, 1, 0.8));
            _hud.update(player, host);
        }
        
        private function compareDepthOfActor(a:IActor, b:IActor):Number {
            return (a.depth > b.depth) ? 1 : -1; // depthが小さい順に並べる
        }
        
        public function removeEventListeners():void {
            EventManager.instance.removeEventListener(ActorEvent.ADD, addActorHandler);
            EventManager.instance.removeEventListener(ActorEvent.REMOVE, removeActorHandler);
        }
        
        public function get ground():BitmapData { return _ground; }
        public function get effect():BitmapData { return _effect; }
        public function get overlay():Sprite { return _overlay; }
    }
//}
//package ore.orelib.assets {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.text.TextField;
/*    import ore.orelib.commons.Assets;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
    import ore.orelib.logic.Host;
    import ore.orelib.logic.Player;
*/    
    //public 
    class HUD extends Sprite {
        private var _characterFace:Bitmap;
        private var _borders:Shape;
        private var _nameLabel:TextField;
        private var _hpSlashLabel:TextField;
        private var _ammoSlashLabel:TextField;
        private var _hpLabel:TextField;
        private var _maxHpLabel:TextField;
        private var _ammoLabel:TextField;
        private var _maxAmmoLabel:TextField;
        private var _waveLabel:TextField;
        private var _quotaLabel:TextField;
        private var _gaugeGradientBox:Matrix;
        
        public function HUD(player:Player, roomNo:int) {
            var bmd:BitmapData = new BitmapData(48, 48, true, 0xFF404040);
            bmd.draw(Assets.images["characters"][player.characterID + 1], new Matrix(4, 0, 0, 4, -4, 4));
            _characterFace = new Bitmap(bmd);
            _characterFace.x = 13;
            _characterFace.y = 6;
            addChild(_characterFace);
            addChild(_borders = new Shape());
            
            var builder:TextBuilder = new TextBuilder()
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF);
            addChild(_nameLabel = builder.autoSize()
                .fontSize(10)
                .pos(70, 5).size(150, 25)
                .build(SaveData.instance.player.name + " @" + (roomNo + 1))
            );
            builder.autoSize(false).fontSize(12);
            
            builder.align(TextBuilder.CENTER);
            addChild(_hpSlashLabel = builder.pos(178, 24).size(10, 16).build("/"));
            addChild(_ammoSlashLabel = builder.pos(178, 39).size(10, 16).build("/"));
            
            builder.align(TextBuilder.RIGHT);
            addChild(_hpLabel = builder.pos(153, 24).size(25, 16).build(player.hp.toString()));
            addChild(_ammoLabel = builder.pos(153, 39).size(25, 16).build(player.ammo.toString()));
            
            builder.align(TextBuilder.LEFT);
            addChild(_maxHpLabel = builder.pos(188, 24).size(25, 16).build(player.maxHp.toString()));
            addChild(_maxAmmoLabel = builder.pos(188, 39).size(25, 16).build(player.maxAmmo.toString()));
            
            builder.autoSize();
            addChild(builder.pos(24, 60).size(74, 30).build("Wave:"));
            addChild(builder.pos(110, 60).size(98, 30).build("契約ノルマ:"));
            
            builder.align(TextBuilder.RIGHT).fontSize(18);
            addChild(_waveLabel = builder.pos(24, 60).size(74, 30).build("1"));
            addChild(_quotaLabel = builder.pos(110, 60).size(98, 30).build(Const.FIELD_QB_QUOTA.toString()));
            
            _gaugeGradientBox = new Matrix();
            _gaugeGradientBox.createGradientBox(150, 8);
            
            drawGauge(1, 1);
            drawBorders(0xFFFFFF);
        }
        
        private function drawGauge(hpRate:Number, ammoRate:Number):void {
            var g:Graphics = graphics;
            g.clear();
            
            g.beginFill(0xC00000);
            g.drawRoundRect(69, 31, 150, 8, 8, 8);
            g.endFill();
            g.beginGradientFill(GradientType.LINEAR, [0x004000, 0x00FF00], [1, 1], [0, 255], _gaugeGradientBox);
            g.drawRoundRect(69, 31, 150 * hpRate, 8, 8, 8);
            g.endFill();
            
            g.beginFill(0x000000);
            g.drawRoundRect(69, 46, 150, 8, 8, 8);
            g.endFill();
            g.beginGradientFill(GradientType.LINEAR, [0x800000, 0xFFC000], [1, 1], [0, 255], _gaugeGradientBox);
            g.drawRoundRect(69, 46, 150 * ammoRate, 8, 8, 8);
            g.endFill();
        }
        
        private function drawBorders(color:uint):void {
            var g:Graphics = _borders.graphics;
            g.clear();
            
            g.lineStyle(2, color);
            g.drawRoundRect(13, 6, 48, 48, 8, 8);
            g.drawRoundRect(69, 31, 150, 8, 8, 8);
            g.drawRoundRect(69, 46, 150, 8, 8, 8);
        }
        
        public function update(player:Player, host:Host):void {
            var borderColor:uint = (player.hpRate <= 0) ? 0xFF0000 : (player.hpRate < 0.3) ? 0xFFFF00 : 0xFFFFFF;
            
            _hpLabel.text = player.hp.toString();
            _ammoLabel.text = player.ammo.toString();
            _maxAmmoLabel.text = player.maxAmmo.toString();
            _waveLabel.text = host.wave.toString();
            _quotaLabel.text = Math.max(0, (Const.FIELD_QB_QUOTA - host.numContracts)).toString();
            
            drawGauge(player.hpGaugeRate, player.ammoGaugeRate);
            drawBorders(borderColor);
            
            _nameLabel.textColor = borderColor;
            _hpSlashLabel.textColor = borderColor;
            _ammoSlashLabel.textColor = borderColor;
            _hpLabel.textColor = borderColor;
            _ammoLabel.textColor = borderColor;
            _maxHpLabel.textColor = borderColor;
            _maxAmmoLabel.textColor = borderColor;
        }
    }
//}
//package ore.orelib.commons {
    import com.bit101.components.ProgressBar;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.ReactorEvent;
    import net.wonderfl.utils.FontLoader;
    
    [Event(name = "complete", type = "flash.events.Event")]
    //public 
    class Preloader extends EventDispatcher {
        private var _progressBar:ProgressBar;
        private var _reactor:Reactor;
        private var _host:String;
        private var _port:int;
        private var _loaders:Dictionary;
        private var _fonts:Vector.<String>;
        
        public function Preloader(parent:DisplayObjectContainer) {
            _progressBar = new ProgressBar(parent, 182, 227);
            _progressBar.maximum = 0;
            
            _reactor = null;
            _loaders = new Dictionary();
            _fonts = new Vector.<String>();
        }
        
        public function addReactorConnectionRequest(reactor:Reactor, host:String, port:int):void {
            _reactor = reactor;
            _host = host;
            _port = port;
        }
        
        public function addLoaderRequest(...urls):void {
            for each(var url:String in urls) {
                _loaders[url] = new Loader();
            }
        }
        
        public function addFontLoaderRequest(...fontNames):void {
            for each(var fontName:String in fontNames) {
                _fonts.push(fontName);
            }
        }
        
        public function load(appID:String):void {
            if (_reactor) {
                _reactor.addEventListener(ReactorEvent.READY, onLoaded);
                if (appID == "3VrR") {
                    _reactor.connect("49.212.45.166", 80);
                } else {
                    _reactor.connect(_host, _port);
                }
                _progressBar.maximum++;
            }
            
            for (var url:String in _loaders) {
                var loader:Loader = _loaders[url];
                loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaded);
                loader.load(new URLRequest(url), new LoaderContext(true));
                _progressBar.maximum++;
            }
            
            for each(var fontName:String in _fonts) {
                var fontLoader:FontLoader = new FontLoader();
                fontLoader.addEventListener(Event.COMPLETE, onLoaded);
                fontLoader.load(fontName);
                _progressBar.maximum++;
            }
            
            if (_progressBar.maximum == 0) { onLoaded(); }
            
            function onLoaded(event:Event = null):void {
                if (event) { event.currentTarget.removeEventListener(event.type, arguments.callee); }
                if (++_progressBar.value >= _progressBar.maximum) {
                    _progressBar.parent.removeChild(_progressBar);
                    dispatchEvent(new Event(Event.COMPLETE));
                }
            }
        }
        
        public function get loaders():Dictionary { return _loaders; }
    }
//}
//package ore.orelib.commons {
    import flash.utils.Dictionary;
    
    //public 
    class Assets {
        public static var images:Dictionary = new Dictionary();
    }
//}
//package ore.orelib.commons {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    /** 読み込んだ画像をクリッピングして、新しい BitmapData クラスを作成します。 */
    //public 
    class TileSheet {
        private var _source:BitmapData;
        
        public function TileSheet(loader:Loader) {
            _source = Bitmap(loader.content).bitmapData;
        }
        
        public function clip(rect:Rectangle):BitmapData {
            var result:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00FFFFFF);
            var matrix:Matrix = new Matrix();
            matrix.translate( -rect.x, -rect.y);
            result.draw(_source, matrix);
            return result;
        }
        
        public function blit(first:Rectangle, cols:int, rows:int):Vector.<BitmapData> {
            var result:Vector.<BitmapData> = new Vector.<BitmapData>();
            for (var row:int = 0; row < rows; row++) {
                for (var col:int = 0; col < cols; col++) {
                    var left:Number = col * first.width + first.x;
                    var top:Number = row * first.height + first.y;
                    result.push(clip(new Rectangle(left, top, first.width, first.height)));
                }
            }
            result.fixed = true;
            return result;
        }
    }
//}
//package ore.orelib.commons {
    import flash.display.Stage;
    
    /** 入力状態を取得するクラスです。 */
    //public 
    class Input {
        private static var _key:KeyWatcher;
        private static var _mouse:MouseWatcher;
        
        public static function setup(stage:Stage):void {
            _key = new KeyWatcher(stage);
            _mouse = new MouseWatcher(stage);
            
            stage.addEventListener(Event.ACTIVATE, function(event:Event):void {
                Input.clear();
            });
        }
        
        public static function record():void {
            _key.record();
            _mouse.record();
        }
        
        public static function clear():void {
            _key.clear();
            _mouse.clear();
        }
        
        public static function get key():KeyWatcher { return _key; }
        public static function get mouse():MouseWatcher { return _mouse; }
        
        public static const NUM_0:uint = 48; public static const NUM_1:uint = 49;
        public static const NUM_2:uint = 50; public static const NUM_3:uint = 51;
        public static const NUM_4:uint = 52; public static const NUM_5:uint = 53;
        public static const NUM_6:uint = 54; public static const NUM_7:uint = 55;
        public static const NUM_8:uint = 56; public static const NUM_9:uint = 57; 
        public static const A:uint = 65; public static const B:uint = 66; public static const C:uint = 67;
        public static const D:uint = 68; public static const E:uint = 69; public static const F:uint = 70;
        public static const G:uint = 71; public static const H:uint = 72; public static const I:uint = 73;
        public static const J:uint = 74; public static const K:uint = 75; public static const L:uint = 76;
        public static const M:uint = 77; public static const N:uint = 78; public static const O:uint = 79;
        public static const P:uint = 80; public static const Q:uint = 81; public static const R:uint = 82;
        public static const S:uint = 83; public static const T:uint = 84; public static const U:uint = 85;
        public static const V:uint = 86; public static const W:uint = 87; public static const X:uint = 88;
        public static const Y:uint = 89; public static const Z:uint = 90;
    }
//}
//package ore.orelib.commons {
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    
    /** キーボード入力状態を監視します。 */
    //public 
    class KeyWatcher {
        private var _currentStates:Vector.<Boolean>;
        private var _previousStates:Vector.<Boolean>;
        
        public function KeyWatcher(stage:Stage) {
            _currentStates = new Vector.<Boolean>(256, true);
            _previousStates = new Vector.<Boolean>(256, true);
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
        }
        
        private function keyDownHandler(event:KeyboardEvent):void { _currentStates[event.keyCode] = true; }
        private function keyUpHandler(event:KeyboardEvent):void { _currentStates[event.keyCode] = false; }        
        
        public function record():void {
            for (var i:int = 0; i < 256; i++) {
                _previousStates[i] = _currentStates[i];
            }
        }
        
        public function clear():void {
            for (var i:int = 0; i < 256; i++) {
                _currentStates[i] = false;
            }
        }
        
        public function isDown(keycode:uint):Boolean { return _currentStates[keycode]; }
        public function isPressed(keycode:uint):Boolean { return !_previousStates[keycode] && _currentStates[keycode]; }
    }
//}
//package ore.orelib.commons {
    import flash.display.Stage;
    import flash.events.MouseEvent;
    
    /** マウス左ボタン入力状態を監視します。 */
    //public 
    class MouseWatcher {
        private var _currentState:Boolean;
        private var _previousState:Boolean;
        
        public function MouseWatcher(stage:Stage) {
            _currentState = false;
            _previousState = false;
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        }
        
        private function mouseDownHandler(event:MouseEvent):void { _currentState = true; }
        private function mouseUpHandler(event:MouseEvent):void { _currentState = false; }
        
        public function record():void {
            _previousState = _currentState;
        }
        
        public function clear():void {
            _currentState = false;
        }
        
        public function isDown():Boolean { return _currentState; }
        public function isPressed():Boolean { return !_previousState && _currentState; }
    }
//}
//package ore.orelib.commons {
    import flash.errors.IllegalOperationError;
    import flash.events.EventDispatcher;
    
    /** グローバルなイベント処理を行うためのクラスです。 */
    //public 
    class EventManager extends EventDispatcher {
        private static var _instance:EventManager;
        private static var _allowsInstantiation:Boolean;
        
        public static function get instance():EventManager {
            if (!_instance) {
                _allowsInstantiation = true;
                _instance = new EventManager();
                _allowsInstantiation = false;
            }
            
            return _instance;
        }
        
        public function EventManager() {
            if (!_allowsInstantiation) { throw new IllegalOperationError("EventManager class is a Singleton!"); }
        }
    }
//}
//package ore.orelib.commons {
    import flash.geom.Point;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    /** 複雑な設定の flash.text.TextField クラスの生成を単純化します。 */
    //public 
    class TextBuilder {
        private var _align:String;
        private var _autoSize:Boolean;
        private var _bold:Boolean;
        private var _filters:Array;
        private var _fontName:String;
        private var _sharpness:Number;
        private var _thickness:Number;
        private var _fontColor:uint;
        private var _fontSize:int;
        private var _position:Point;
        private var _size:Point;
        
        public static const LEFT:String = "left";
        public static const RIGHT:String = "right";
        public static const CENTER:String = "center";
        
        public function TextBuilder() {
            _align = TextBuilder.LEFT;
            _autoSize = _bold = false;
            _filters = [];
            _fontName = null;
            _sharpness = _thickness = 0;
            _fontColor = 0x000000;
            _fontSize = 12;
            _position = new Point(0, 0);
            _size = new Point(100, 100);
        }
        
        public function align(value:String):TextBuilder { _align = value; return this; }        
        public function autoSize(enabled:Boolean = true):TextBuilder { _autoSize = enabled; return this; }
        public function bold(enabled:Boolean = true):TextBuilder { _bold = enabled; return this; }
        public function filters(value:Array):TextBuilder { _filters = value; return this; }
        public function font(name:String, sharpness:Number = 0, thickness:Number = 0):TextBuilder {
            _fontName = name;
            _sharpness = sharpness; _thickness = thickness;
            return this;
        }
        public function fontColor(value:uint):TextBuilder { _fontColor = value; return this; }
        public function fontSize(value:int):TextBuilder { _fontSize = value; return this; }
        public function pos(x:Number, y:Number, relative:Boolean = false):TextBuilder {
            _position.x = ((relative) ? _position.x : 0) + x;
            _position.y = ((relative) ? _position.y : 0) + y;
            return this;
        }
        public function size(width:Number, height:Number):TextBuilder {
            _size.x = width;
            _size.y = height;
            return this;
        }
        
        public function build(text:String):TextField {
            var tf:TextField = new TextField();
            var format:TextFormat = new TextFormat(_fontName, _fontSize, _fontColor, _bold);
            if (_fontName) {
                tf.embedFonts = true;
                tf.antiAliasType = AntiAliasType.ADVANCED;
                tf.gridFitType = (_align == TextBuilder.LEFT) ? GridFitType.PIXEL : GridFitType.SUBPIXEL;
                tf.sharpness = _sharpness;
                tf.thickness = _thickness;
            }
            
            tf.x = _position.x;
            tf.width = _size.x;
            tf.height = _size.y;
            if (_autoSize) {
                switch(_align) {
                    case TextBuilder.LEFT: { tf.autoSize = TextFieldAutoSize.LEFT; break; }
                    case TextBuilder.RIGHT: { tf.autoSize = TextFieldAutoSize.RIGHT; break; }
                    case TextBuilder.CENTER: { tf.autoSize = TextFieldAutoSize.CENTER; break; }
                }
            }else {
                switch(_align) {
                    case TextBuilder.LEFT: { format.align = TextFormatAlign.LEFT; break; }
                    case TextBuilder.RIGHT: { format.align = TextFormatAlign.RIGHT; break; }
                    case TextBuilder.CENTER: { format.align = TextFormatAlign.CENTER; break; }
                }
            }
            
            tf.defaultTextFormat = format;
            tf.text = text;
            tf.y = _position.y + ((_autoSize) ? Math.max(0, int((_size.y - (tf.textHeight + 4)) / 2)) : 0);
            tf.filters = _filters.concat();
            tf.mouseEnabled = tf.selectable = false;
            
            return tf;
        }
        
        public function clone():TextBuilder {
            return new TextBuilder().align(_align).autoSize(_autoSize).bold(_bold).filters(_filters)
            .font(_fontName, _sharpness, _thickness).fontColor(_fontColor).fontSize(_fontSize)
            .pos(_position.x, _position.y).size(_size.x, _size.y);
        }
    }
//}
//package ore.orelib.commons {
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /** flash.geom パッケージ内クラスのインスタンスを再利用するためのクラスです。 */
    //public 
    class GeomPool {
        private static var _colorTransforms:Vector.<ColorTransform>;
        private static var _matrices:Vector.<Matrix>;
        private static var _points:Vector.<Point>;
        private static var _rectangles:Vector.<Rectangle>;
        
        private static var _colorTransformsIndex:int;
        private static var _matricesIndex:int;
        private static var _pointsIndex:int;
        private static var _rectanglesIndex:int;
        
        public static function setup(capacity:int):void {
            capacity = Math.max(1, capacity);
            
            _colorTransforms = new Vector.<ColorTransform>(capacity, true);
            _matrices = new Vector.<Matrix>(capacity, true);
            _points = new Vector.<Point>(capacity, true);
            _rectangles = new Vector.<Rectangle>(capacity, true);
            
            for (var i:int = 0; i < capacity; i++) {
                _colorTransforms[i] = new ColorTransform();
                _matrices[i] = new Matrix();
                _points[i] = new Point();
                _rectangles[i] = new Rectangle();
            }
            
            _colorTransformsIndex = _matricesIndex = _pointsIndex = _rectanglesIndex = 0;
        }
        
        public static function colorTransform(
            redMultiplier:Number = 1, greenMultiplier:Number = 1, blueMultiplier:Number = 1, alphaMultiplier:Number = 1,
            redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0
        ):ColorTransform {
            var result:ColorTransform = _colorTransforms[_colorTransformsIndex++];
            if (_colorTransformsIndex >= _colorTransforms.length) { _colorTransformsIndex = 0; }
            
            result.redMultiplier = redMultiplier;
            result.greenMultiplier = greenMultiplier;
            result.blueMultiplier = blueMultiplier;
            result.alphaMultiplier = alphaMultiplier;
            result.redOffset = redOffset;
            result.greenOffset = greenOffset;
            result.blueOffset = blueOffset;
            result.alphaOffset = alphaOffset;
            
            return result;
        }
        
        public static function matrix(a:Number = 1, b:Number = 0, c:Number = 0, d:Number = 1, tx:Number = 0, ty:Number = 0):Matrix {
            var result:Matrix = _matrices[_matricesIndex++];
            if (_matricesIndex >= _matrices.length) { _matricesIndex = 0; }
            
            result.a = a;
            result.b = b;
            result.c = c;
            result.d = d;
            result.tx = tx;
            result.ty = ty;
            
            return result;
        }
        
        public static function point(x:Number = 0, y:Number = 0):Point {
            var result:Point = _points[_pointsIndex++];
            if (_pointsIndex >= _points.length) { _pointsIndex = 0; }
            
            result.x = x;
            result.y = y;
            
            return result;
        }
        
        public static function rectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0):Rectangle {
            var result:Rectangle = _rectangles[_rectanglesIndex++];
            if (_rectanglesIndex >= _rectangles.length) { _rectanglesIndex = 0; }
            
            result.x = x;
            result.y = y;
            result.width = width;
            result.height = height;
            
            return result;
        }
    }
//}
//package ore.orelib.commons {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.DropShadowFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Timer;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.Statistics;
    
    //public 
    class UnionStats extends Sprite {
        private var _reactor:Reactor;
        private var _fpsCount:int;
        private var _updateTimer:Timer;
        
        private var _fpsLabel:TextField;
        private var _stageFpsLabel:TextField;
        private var _pingLabel:TextField;
        private var _memLabel:TextField;
        private var _downLabel:TextField;
        private var _upLabel:TextField;
        private var _peakMemLabel:TextField;
        private var _peakDownLabel:TextField;
        private var _peakUpLabel:TextField;
        
        public function UnionStats(reactor:Reactor) {
            _reactor = reactor;
            _fpsCount = 0;
            _updateTimer = new Timer(1000);
            _updateTimer.addEventListener(TimerEvent.TIMER, update);
            
            graphics.beginFill(0x444444, 0.8);
            graphics.drawRect(0, 0, 110, 92);
            graphics.endFill();
            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(5, 37, 100, 2);
            graphics.endFill();
            
            addChild(createTextField("FPS:", 2, 2, 35, "left"));
            addChild(createTextField("Mem:", 2, 18, 35, "left"));
            addChild(createTextField("Ping:", 2, 42, 35, "left"));
            addChild(createTextField("Down:", 2, 58, 35, "left"));
            addChild(createTextField("Up:", 2, 74, 35, "left"));
            addChild(createTextField("/", 69, 2, 7, "center"));
            addChild(createTextField("/", 69, 18, 7, "center"));
            addChild(createTextField("/", 69, 58, 7, "center"));
            addChild(createTextField("/", 69, 74, 7, "center"));
            
            addChild(_fpsLabel = createTextField("0", 37, 2, 32, "right"));
            addChild(_stageFpsLabel = createTextField("0", 76, 2, 32, "left"));
            addChild(_pingLabel = createTextField("-1", 37, 42, 71, "center"));
            addChild(_memLabel = createTextField("0.00", 37, 18, 32, "right"));
            addChild(_downLabel = createTextField("0.00", 37, 58, 32, "right"));
            addChild(_upLabel = createTextField("0.00", 37, 74, 32, "right"));
            addChild(_peakMemLabel = createTextField("0.00", 76, 18, 32, "left"));
            addChild(_peakDownLabel = createTextField("0.00", 76, 58, 32, "left"));
            addChild(_peakUpLabel = createTextField("0.00", 76, 74, 32, "left"));
            
            addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
            addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
            enable();
        }
        
        private function createTextField(text:String, x:int, y:int, width:int, align:String):TextField {
            var result:TextField = new TextField();
            result.x = x; result.y = y;
            result.width = width;
            result.filters = [new DropShadowFilter(1, 45, 0x444444, 1, 1, 1)];
            result.mouseEnabled = result.selectable = false;
            var format:TextFormat = new TextFormat("_sans", 9, 0xFFFFFF, true);
            format.align = align;
            result.defaultTextFormat = format;
            result.text = text;
            return result;
        }
        
        private function startDragHandler(event:MouseEvent):void { startDrag(); }
        private function stopDragHandler(event:MouseEvent):void { stopDrag(); }
        private function enterFrameHandler(event:Event):void { _fpsCount++; }
        
        private function update(event:TimerEvent):void {
            _fpsLabel.text = _fpsCount.toString();
            _fpsCount = 0;
            if (stage) { _stageFpsLabel.text = stage.frameRate.toString(); }
            
            if (!_reactor.isReady()) { return; }
            var stats:Statistics = _reactor.getStatistics();
            _pingLabel.text = _reactor.self().getPing().toString();
            _memLabel.text = stats.getTotalMemoryMB().toFixed(2);
            _downLabel.text = stats.getKBReceivedPerSecond().toFixed(2);
            _upLabel.text = stats.getKBSentPerSecond().toFixed(2);
            _peakMemLabel.text = stats.getPeakMemoryMB().toFixed(2);
            _peakDownLabel.text = stats.getPeakKBReceivedPerSecond().toFixed(2);
            _peakUpLabel.text = stats.getPeakKBSentPerSecond().toFixed(2);
        }
        
        public function enable():void {
            _reactor.enableStatistics();
            _reactor.getStatistics().start();
            _fpsCount = 0;
            _updateTimer.start();
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        public function disable():void {
            _reactor.getStatistics().stop();
            _reactor.disableStatistics();
            _updateTimer.stop();
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
    }
//}
//package ore.orelib.commons {
    /** Unionのメッセージ・属性値用の圧縮変換アルゴリズム */
    //public 
    class UPCConv {
        // "*|.,-<> "を除くASCII印字可能文字
        private static const CHARS_LENGTH:int = 87;
        private static const CHARS:String =
            "0123456789"
            + "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            + "abcdefghijklmnopqrstuvwxyz"
            + "!\"#$%&\'()+/:;=?@[\\]^_`{}~";
        
        /** 整数値を符号に変換する */
        public static function toCode(value:int):String {
            if (value == 0) { return "0"; }
            
            var result:String = (value < 0) ? (value = -(value), "-") : "";
            while (value) {
                result += UPCConv.CHARS.charAt(value % UPCConv.CHARS_LENGTH);
                value /= UPCConv.CHARS_LENGTH;
            }
            return result;
        }
        
        /** 符号を整数値に変換する */
        public static function toInt(code:String):int {
            var result:uint = 0;
            while (code) {
                var lastChar:String = code.substr(-1);
                if (lastChar == "-") {
                    result = -(result);
                } else {
                    result *= UPCConv.CHARS_LENGTH;
                    result += UPCConv.CHARS.indexOf(lastChar);
                }
                code = code.slice(0, code.length - 1);
            }
            return result;
        }
    }
//}
//package ore.orelib.commons {
    import com.bit101.components.PushButton;
    import com.bit101.components.VScrollBar;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BevelFilter;
    import flash.filters.DropShadowFilter;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.ReactorEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.UpdateLevels;
    
    //public 
    class Chat extends Sprite {
        private var _reactor:Reactor;
        private var _selfID:String;
        private var _roomID:String;
        private var _userName:String;
        
        private var _room:Room;
        private var _messages:Vector.<TextField>;
        private var _messagePool:Vector.<TextField>;
        private var _selectedMessageIndex:int;
        private var _filterList:Vector.<String>;
        private var _resizeOffset:Point;
        // 連投規制関連
        private var _lastPostedMessage:String;
        private var _sendDelayTimer:Timer;
        private var _lastPostedTime:int;
        private var _restrictionCount:int;
        private var _isRestricted:Boolean;
        // 表示関連
        private var _statusBar:TextField;
        private var _messageArea:Sprite;
        private var _messageAreaMask:Sprite;
        private var _messageDisplay:Sprite;
        private var _scrollBar:VScrollBar;
        private var _sayLabel:TextField;
        private var _inputForm:TextField;
        private var _addFilterButton:PushButton;
        private var _clearFilterButton:PushButton;
        private var _resizeGrip:Sprite;
        
        private static const DEFAULT_USER_NAME:String = "名無し";
        private static const MESSAGE_NAME:String = "m";
        private static const MESSAGE_LOG_SIZE:int = 50;
        private static const MESSAGE_MAX_CHARS:int = 50;
        private static const SEND_RATE_LIMIT_HIGH:int = 1000;
        private static const SEND_RATE_LIMIT_LOW:int = 10000;
        private static const SEND_RESTRICTION:int = 3;
        private static const WINDOW_MIN_WIDTH:int = 232;
        private static const WINDOW_MIN_HEIGHT:int = 110;
        private static const STATUS_ON_CONNECTED:String = "現在の魔法少女の数 %v 人";
        private static const STATUS_ON_DISCONNECTED:String = "サーバーに接続中です...";
        
        public function Chat(reactor:Reactor, roomID:String) {
            _reactor = reactor;
            _selfID = (_reactor.isReady()) ? _reactor.self().getClientID() : "";
            _roomID = roomID;
            _userName = Chat.DEFAULT_USER_NAME;
            
            _messages = new Vector.<TextField>();
            _messagePool = new Vector.<TextField>();
            for (var i:int = 0; i < Chat.MESSAGE_LOG_SIZE; i++) {
                _messagePool.push(createMessageBlock());
            }
            _selectedMessageIndex = -1;
            _filterList = new Vector.<String>();
            _resizeOffset = new Point();
            
            _lastPostedMessage = "";
            _sendDelayTimer = new Timer(Chat.SEND_RATE_LIMIT_HIGH, 1);
            _sendDelayTimer.addEventListener(TimerEvent.TIMER, sendMessage);
            _lastPostedTime = _restrictionCount = 0;
            _isRestricted = false;
            
            addChild(_messageArea = new Sprite());
            _messageArea.addChild(_messageAreaMask = new Sprite());
            _messageArea.mask = _messageAreaMask;
            _messageArea.addChild(_messageDisplay = new Sprite());
            addChild(_scrollBar = createScrollBar());
            addChild(_sayLabel = createSayLabel());
            addChild(_inputForm = createInputForm());
            addChild(_addFilterButton = createFilterButton("+"));
            addChild(_clearFilterButton = createFilterButton("-"));
            addChild(_resizeGrip = createResizeGrip());
            addChild(_statusBar = createStatusBar());
            resize(Chat.WINDOW_MIN_WIDTH, Chat.WINDOW_MIN_HEIGHT);
            
            _statusBar.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
            _statusBar.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
            _messageDisplay.addEventListener(MouseEvent.CLICK, onClickMessageBlock);
            _messageDisplay.addEventListener(MouseEvent.MOUSE_OVER, updateMessageCursor);
            _messageDisplay.addEventListener(MouseEvent.ROLL_OUT, updateMessageCursor);
            _scrollBar.addEventListener(Event.CHANGE, scrollMessageDisplay);
            _inputForm.addEventListener(KeyboardEvent.KEY_DOWN, postMessage);
            _addFilterButton.addEventListener(MouseEvent.CLICK, addClientToFilterList);
            _clearFilterButton.addEventListener(MouseEvent.CLICK, clearFilterList);
            _resizeGrip.addEventListener(MouseEvent.MOUSE_DOWN, startResizing);
            _resizeGrip.addEventListener(MouseEvent.MOUSE_UP, stopResizing);
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
        }
        
        private function createMessageBlock():TextField {
            var result:TextField = new TextField();
            result.filters = [new DropShadowFilter(1, 45, 0x444444, 1, 1, 1)];
            result.autoSize = TextFieldAutoSize.LEFT;
            result.wordWrap = true;
            result.defaultTextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
            return result;
        }
        
        private function createStatusBar():TextField {
            var result:TextField = new TextField();
            result.height = 20;
            result.background = true; result.backgroundColor = 0x444444;
            result.filters = [new BevelFilter(1, 45, 0xCCCCCC, 1, 0x000000, 1, 0, 0)];
            result.selectable = false;
            var format:TextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
            format.align = TextFormatAlign.CENTER;
            result.defaultTextFormat = format;
            result.text = Chat.STATUS_ON_DISCONNECTED;
            return result;
        }
        
        private function createScrollBar():VScrollBar {
            var result:VScrollBar = new VScrollBar(null, 0, 20);
            result.lineSize = result.pageSize = 10;
            result.setSliderParams(0, 0, 0);
            return result;
        }
        
        private function createSayLabel():TextField {
            var result:TextField = new TextField();
            result.width = 25; result.height = 18;
            result.filters = [new DropShadowFilter(1, 45, 0x444444, 1, 1, 1)];
            result.mouseEnabled = result.selectable = false;
            var format:TextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
            format.align = TextFormatAlign.CENTER;
            result.defaultTextFormat = format;
            result.text = "say";
            return result;
        }
        
        private function createInputForm():TextField {
            var result:TextField = new TextField();
            result.x = 25;
            result.height = 18;
            result.background = true; result.backgroundColor = 0xFFFFFF;
            result.filters = [new BevelFilter(1, 225, 0xCCCCCC, 1, 0x444444, 1, 1, 1)];
            result.maxChars = Chat.MESSAGE_MAX_CHARS;
            result.type = TextFieldType.INPUT;
            result.defaultTextFormat = new TextFormat("_sans", 10, 0x000000);
            return result;
        }
        
        private function createFilterButton(label:String):PushButton {
            var result:PushButton = new PushButton(null, 0, 0, label);
            result.width = result.height = 16; result.draw();
            result.enabled = false;
            return result;
        }
        
        private function createResizeGrip():Sprite {
            var result:Sprite = new Sprite();
            result.alpha = 0.5;
            result.buttonMode = true;
            var size:int = 18;
            result.graphics.beginFill(0xFFFFFF, 1);
            result.graphics.moveTo(size, 0);
            result.graphics.lineTo(0, size);
            result.graphics.lineTo(size, size);
            result.graphics.lineTo(size, 0);
            result.graphics.endFill();
            return result;
        }
        
        private function startDragHandler(event:MouseEvent):void { startDrag(); }
        private function stopDragHandler(event:MouseEvent):void { stopDrag(); }
        
        private function onClickMessageBlock(event:MouseEvent):void {
            var messageBlock:TextField = event.target as TextField;
            if (!messageBlock || messageBlock.name == _selfID) { return; }
            
            var clickedMessageIndex:int = _messages.indexOf(messageBlock);
            setSelectedMessageIndex((clickedMessageIndex != _selectedMessageIndex) ? clickedMessageIndex : -1);
            updateMessageCursor();
        }
        
        private function scrollMessageDisplay(event:Event):void {
            _messageDisplay.y = -_scrollBar.value;
        }
        
        private function addClientToFilterList(event:MouseEvent):void {
            var messageBlock:TextField = _messages[_selectedMessageIndex];
            var filteredID:String = messageBlock.name;
            _filterList.push(filteredID);
            _clearFilterButton.enabled = true;
            
            for (var i:int = _messages.length - 1; i >= 0; i--) {
                messageBlock = _messages[i];
                if (messageBlock.name == filteredID) {
                    _messages.splice(i, 1);
                    _messagePool.push(messageBlock);
                    _messageDisplay.removeChild(messageBlock);
                }
            }
            
            setSelectedMessageIndex(-1);
            updateMessageDisplay();
            updateMessageCursor();
        }
        
        private function clearFilterList(event:MouseEvent):void {
            _filterList.length = 0;
            _clearFilterButton.enabled = false;
        }
        
        private function startResizing(event:MouseEvent):void {
            _resizeOffset.setTo(_resizeGrip.x + 18 - mouseX, _resizeGrip.y + 18 - mouseY);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onResizing);
            addEventListener(MouseEvent.MOUSE_UP, stopResizing);
        }
        
        private function onResizing(event:MouseEvent):void {
            resize(mouseX + _resizeOffset.x, mouseY + _resizeOffset.y);
        }
        
        private function stopResizing(event:Event):void {
            removeEventListener(MouseEvent.MOUSE_UP, stopResizing);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResizing);
        }
        
        private function addedToStageHandler(event:Event):void {
            _reactor.addEventListener(ReactorEvent.READY, joinRoom);
            _reactor.addEventListener(ReactorEvent.CLOSE, leaveRoom);
            if (_reactor.isReady()) { joinRoom(); }
        }
        
        private function removedFromStageHandler(event:Event):void {
            _reactor.removeEventListener(ReactorEvent.READY, joinRoom);
            _reactor.removeEventListener(ReactorEvent.CLOSE, leaveRoom);
            if (_room) { leaveRoom(); }
        }
        
        private function joinRoom(event:ReactorEvent = null):void {
            _selfID = _reactor.self().getClientID();
            
            var updateLevels:UpdateLevels = new UpdateLevels();
            updateLevels.clearAll();
            updateLevels.occupantCount = updateLevels.roomMessages = true;
            
            _room = _reactor.getRoomManager().createRoom(_roomID);
            _room.addEventListener(RoomEvent.OCCUPANT_COUNT, roomOccupantCountHandler);
            _room.addMessageListener(Chat.MESSAGE_NAME, receiveMessage);
            _room.join(null, updateLevels);
        }
        
        private function leaveRoom(event:ReactorEvent = null):void {
            _room.removeMessageListener(Chat.MESSAGE_NAME, receiveMessage);
            _room.removeEventListener(RoomEvent.OCCUPANT_COUNT, roomOccupantCountHandler);
            _room.leave();
            
            _statusBar.text = Chat.STATUS_ON_DISCONNECTED;
        }
        
        private function roomOccupantCountHandler(event:RoomEvent):void {
            _statusBar.text = Chat.STATUS_ON_CONNECTED.replace(/%v/, event.getNumClients().toString());
        }
        
        private function postMessage(event:KeyboardEvent):void {
            if (!_reactor.isReady() || event.keyCode != Keyboard.ENTER || _inputForm.text == "") { return; }
            
            var postedTime:int = getTimer();
            _restrictionCount = (postedTime - _lastPostedTime < Chat.SEND_RATE_LIMIT_LOW || _inputForm.text.length == Chat.MESSAGE_MAX_CHARS) ? _restrictionCount + 1 : 0;
            _lastPostedTime = postedTime;
            if (_sendDelayTimer.running || _restrictionCount >= Chat.SEND_RESTRICTION) { _isRestricted = true; }
            
            if (!_isRestricted) {
                _lastPostedMessage = _inputForm.text;
                _sendDelayTimer.start();
            }
            addMessage(_reactor.self().getClientID(), _userName, _inputForm.text);
            _inputForm.text = "";
        }
        
        private function sendMessage(event:TimerEvent):void {
            if (!_isRestricted) { _room.sendMessage(Chat.MESSAGE_NAME, false, null, _userName, _lastPostedMessage); }
        }
        
        private function receiveMessage(from:IClient, senderName:String, messageText:String):void {
            var senderID:String = from.getClientID();
            if (_filterList.indexOf(senderID) == -1) { addMessage(senderID, senderName, messageText); }
        }
        
        private function addMessage(senderID:String, senderName:String, messageText:String):void {
            var messageBlock:TextField;
            if (_messagePool.length) {
                messageBlock = _messagePool.pop();
            } else {
                messageBlock = _messages.shift();
                setSelectedMessageIndex(_selectedMessageIndex - 1);
            }
            messageBlock.name = senderID;
            messageBlock.text = "(" + senderID + ") " + senderName + ": " + messageText;
            _messages.push(messageBlock);
            _messageDisplay.addChild(messageBlock);
            
            updateMessageDisplay();
            updateMessageCursor();
        }
        
        private function setSelectedMessageIndex(value:int):void {
            _selectedMessageIndex = value;
            _addFilterButton.enabled = (_selectedMessageIndex >= 0);
        }
        
        private function updateMessageDisplay():void {
            var top:int = 0;
            for (var i:int = _messages.length - 1; i >= 0; i--) {
                var messageBlock:TextField = _messages[i];
                messageBlock.width = width - 10;
                top -= messageBlock.textHeight;
                messageBlock.y = top - 2;
            }
            top = Math.min(top, -_scrollBar.height);
            
            _scrollBar.minimum = top + _scrollBar.height;
            _scrollBar.setThumbPercent(_scrollBar.height / -top);
            _messageDisplay.y = -_scrollBar.value;
        }
        
        private function updateMessageCursor(event:MouseEvent = null):void {
            var messageBlock:TextField;
            if (_selectedMessageIndex >= 0) {
                messageBlock = _messages[_selectedMessageIndex];
            } else if (event) {
                messageBlock = event.target as TextField;
            }
            
            _messageDisplay.graphics.clear();
            if (messageBlock) {
                _messageDisplay.graphics.beginFill(0xFF0000, 0.5);
                _messageDisplay.graphics.drawRect(0, messageBlock.y + 2, messageBlock.width, messageBlock.textHeight);
                _messageDisplay.graphics.endFill();
            }
        }
        
        public function resize(width:int, height:int):void {
            width = Math.max(Chat.WINDOW_MIN_WIDTH, width);
            height = Math.max(Chat.WINDOW_MIN_HEIGHT, height);
            
            graphics.clear();
            graphics.beginFill(0x444444, 0.5);
            graphics.drawRect(0, 20, width, height - 20);
            graphics.endFill();
            _statusBar.width = width;
            _messageArea.y = height - 20;
            _messageAreaMask.graphics.clear();
            _messageAreaMask.graphics.beginFill(0x000000);
            _messageAreaMask.graphics.drawRect(0, -(height - 40), width - 10, height - 40);
            _messageAreaMask.graphics.endFill();
            _scrollBar.x = width - 10;
            _scrollBar.height = height - 40;
            _scrollBar.draw();
            _sayLabel.y = _inputForm.y = height - 19;
            _inputForm.width = width - 80;
            _addFilterButton.x = width - 53;
            _clearFilterButton.x = width - 36;
            _resizeGrip.x = width - 18;
            _addFilterButton.y = _clearFilterButton.y = _resizeGrip.y = height - 18;
            
            updateMessageDisplay();
            updateMessageCursor();
        }
        
        public function changeName(value:String):void { _userName = value || Chat.DEFAULT_USER_NAME; }
    }
//}
//package ore.orelib.data {
    import flash.display.StageQuality;
    import flash.errors.IllegalOperationError;
    import flash.net.registerClassAlias;
    import flash.net.SharedObject;
/*    import ore.orelib.logic.WeaponSmith;
*/    
    //public 
    class SaveData {
        private var _so:SharedObject;
        
        private static var _instance:SaveData;
        private static var _allowsInstantiation:Boolean;
        
        public static function get instance():SaveData {
            if (!_instance) {
                _allowsInstantiation = true;
                _instance = new SaveData();
                _allowsInstantiation = false;
            }
            return _instance;
        }
        
        public function SaveData() {
            if (!_allowsInstantiation) { throw new IllegalOperationError("SaveData class is a Singleton!"); }
            
            registerClassAlias("ore.orelib.data.PlayerData", PlayerData);
            registerClassAlias("ore.orelib.data.PlayerStatus", PlayerStatus);
            registerClassAlias("ore.orelib.data.WeaponData", WeaponData);
            _so = SharedObject.getLocal("SaveData");
            
            validate();
            
            if (_so.data.quality == null) { _so.data.quality = StageQuality.HIGH; }
            if (_so.data.highlight == null) { _so.data.highlight = true; }
            if (_so.data.popup == null) { _so.data.popup = true; }
            if (_so.data.fireline == null) { _so.data.fireline = true; }
            if (_so.data.explosion == null) { _so.data.explosion = true; }
            if (_so.data.qblimb == null) { _so.data.qblimb = true; }
            if (_so.data.grotesque == null) { _so.data.grotesque = false; }
            if (_so.data.stats == null) { _so.data.stats = false; }
        }
        
        public function validate():void {
            if (!(_so.data.player && isPlayerDataValid())) {
                _so.data.player = new PlayerData();
                _so.data.inventory = WeaponSmith.createInitialEquipment(_so.data.player.characterID);
                _so.flush();
            }
        }
        
        private function isPlayerDataValid():Boolean {
            var playerData:PlayerData = _so.data.player;
            var playerStatus:PlayerStatus = playerData.status;
            
            var isValidCharacterID:Boolean = false;
            for (var i:int = Const.CHARACTER_IDS.length - 1; i >= 0; i--) {
                if (playerData.characterID == Const.CHARACTER_IDS[i]) {
                    isValidCharacterID = true;
                }
            }
            
            return (isValidCharacterID && (playerStatus.str + playerStatus.vit + playerStatus.dex + playerStatus.luc + playerData.statusPoints) <= 500);
        }
        
        public function flush():void { _so.flush(); }
        
        public function get player():PlayerData { return _so.data.player; }
        public function get inventory():Array { return _so.data.inventory; }
        
        public function get quality():String { return _so.data.quality; }
        public function set quality(value:String):void { _so.data.quality = value; }
        public function get highlight():Boolean { return _so.data.highlight; }
        public function set highlight(value:Boolean):void { _so.data.highlight = value; }
        public function get popup():Boolean { return _so.data.popup; }
        public function set popup(value:Boolean):void { _so.data.popup = value; }
        public function get fireline():Boolean { return _so.data.fireline; }
        public function set fireline(value:Boolean):void { _so.data.fireline = value; }
        public function get explosion():Boolean { return _so.data.explosion; }
        public function set explosion(value:Boolean):void { _so.data.explosion = value; }
        public function get qblimb():Boolean { return _so.data.qblimb; }
        public function set qblimb(value:Boolean):void { _so.data.qblimb = value; }
        public function get grotesque():Boolean { return _so.data.grotesque; }
        public function set grotesque(value:Boolean):void { _so.data.grotesque = value; }
        public function get stats():Boolean { return _so.data.stats; }
        public function set stats(value:Boolean):void { _so.data.stats = value; }
    }
//}
//package ore.orelib.data {
    
    //public 
    class PlayerData {
        public var name:String = "";
        public var characterID:int = 3 * int(5 * Math.random());
        public var level:int = 1;
        public var next:int = Const.EXP_TABLE[0];
        public var statusPoints:int = 2;
        public var status:PlayerStatus = new PlayerStatus(100, 100, 100, 100);
    }
//}
//package ore.orelib.data {
    
    //public 
    class PlayerStatus {
        public var str:int;
        public var vit:int;
        public var dex:int;
        public var luc:int;
        
        public function PlayerStatus(str:int = 0, vit:int = 0, dex:int = 0, luc:int = 0) {
            this.str = str;
            this.vit = vit;
            this.dex = dex;
            this.luc = luc;
        }
    }
//}
//package ore.orelib.data {
    
    //public 
    class WeaponData {
        public var id:int = Const.WEAPON_PISTOL;
        public var baseLevel:int = 0;
        public var quality:String = "normal";
        public var qualityLevel:int = 0;
        public var prefix:String = "none";
        public var prefixLevel:int = 0;
    }
//}
//package ore.orelib.data {
    
    //public 
    class Weapon {
        private var _id:int;
        private var _name:String;
        private var _specs:Vector.<String>;
        private var _specColors:Vector.<uint>;
        
        private var _minDamage:int;
        private var _randDamage:int;
        private var _range:int;
        private var _attackRate:int;
        private var _reloadRate:int;
        private var _maxAmmo:int;
        private var _bonus:PlayerStatus;
        private var _criticalRate:int;
        private var _knockback:int;
        private var _penetration:int;
        
        public function Weapon(
            id:int, name:String, specs:Vector.<String>, specColors:Vector.<uint>,
            minDamage:int, randDamage:int, range:int,
            attackRate:int, reloadRate:int, maxAmmo:int,
            bonus:PlayerStatus,
            criticalRate:int, knockback:int, penetration:int
        ) {
            _id = id;
            _name = name;
            _specs = specs;
            _specColors = specColors;
            _minDamage = minDamage;
            _randDamage = randDamage;
            _range = range;
            _attackRate = attackRate;
            _reloadRate = reloadRate;
            _maxAmmo = maxAmmo;
            _bonus = bonus;
            _criticalRate = criticalRate;
            _knockback = knockback;
            _penetration = penetration;
        }
        
        public function get id():int { return _id; }
        public function get name():String { return _name; }
        public function get specs():Vector.<String> { return _specs; }
        public function get specColors():Vector.<uint> { return _specColors; }
        public function get minDamage():int { return _minDamage; }
        public function get randDamage():int { return _randDamage; }
        public function get range():int { return _range; }
        public function get attackRate():int { return _attackRate; }
        public function get reloadRate():int { return _reloadRate; }
        public function get maxAmmo():int { return _maxAmmo; }
        public function get strBonus():int { return _bonus.str; }
        public function get vitBonus():int { return _bonus.vit; }
        public function get dexBonus():int { return _bonus.dex; }
        public function get lucBonus():int { return _bonus.luc; }
        public function get criticalRate():int { return _criticalRate; }
        public function get knockback():int { return _knockback; }
        public function get penetration():int { return _penetration; }
    }
//}
//package ore.orelib.data {
    
    //public 
    class Const {
        // プレイフィールドの設定
        public static const FIELD_SIZE:int = 300;
        public static const FIELD_OFFSET_X:int = 100;
        public static const FIELD_OFFSET_Y:int = 165;
        public static const FIELD_LEFT_BOUND:int = -120;
        public static const FIELD_RIGHT_BOUND:int = 370;
        public static const FIELD_WAVE_TIME:int = 30000; //(ms)
        public static const FIELD_QB_QUOTA:int = 20;
        // プレイヤーの基礎値
        public static const PLAYER_SPEED:Number = 60; //(px/s)
        public static const PLAYER_SWAP_TIME:int = 500; //(ms)
        public static const PLAYER_INVINCIBLE_TIME_ON_DAMAGED:int = 250; //(ms)
        public static const PLAYER_INVINCIBLE_TIME_ON_RECOVER:int = 5000; //(ms)
        public static const PLAYER_RECOVER_TIME:int = 20000; //(ms)
        public static const PLAYER_GAS_INTERVAL:int = 500; //(ms)
        public static const PLAYER_SEND_INTERVAL:int = 250; //(ms)
        public static const PLAYER_BOUNDS_HALF_WIDTH:int = 10;
        public static const PLAYER_BOUNDS_HEIGHT:int = 28;
        // キャラクターのID
        public static const CHARACTER_MADOKA:int = 0;
        public static const CHARACTER_HOMURA:int = 3;
        public static const CHARACTER_SAYAKA:int = 6;
        public static const CHARACTER_MAMI:int = 9;
        public static const CHARACTER_KYOKO:int = 12;
        public static const CHARACTER_QB:int = 15;
        public static const CHARACTER_MADOGAMI:int = 18;
        public static const CHARACTER_MEGAHOMU:int = 21;
        public static const CHARACTER_CHARLOTTE:int = 24;
        public static const CHARACTER_HITOMI:int = 27;
        public static const CHARACTER_KUROSAYA:int = 30;
        public static const CHARACTER_IDS:Array = [
            Const.CHARACTER_MADOKA,
            Const.CHARACTER_HOMURA,
            Const.CHARACTER_SAYAKA,
            Const.CHARACTER_MAMI,
            Const.CHARACTER_KYOKO,
            Const.CHARACTER_MADOGAMI,
            Const.CHARACTER_MEGAHOMU,
            Const.CHARACTER_KUROSAYA,
            Const.CHARACTER_CHARLOTTE,
            Const.CHARACTER_HITOMI
        ];
        // キャラクターの名前
        public static const CHARACTER_NAME_MADOKA:String = "まどっち";
        public static const CHARACTER_NAME_HOMURA:String = "ほむほむ";
        public static const CHARACTER_NAME_SAYAKA:String = "さやかちゃん";
        public static const CHARACTER_NAME_MAMI:String = "マミさん";
        public static const CHARACTER_NAME_KYOKO:String = "あんこ";
        public static const CHARACTER_NAME_MADOGAMI:String = "まど神様";
        public static const CHARACTER_NAME_MEGAHOMU:String = "メガほむ";
        public static const CHARACTER_NAME_KUROSAYA:String = "黒さやか";
        public static const CHARACTER_NAME_CHARLOTTE:String = "シャルロッテ";
        public static const CHARACTER_NAME_HITOMI:String = "腹パン";
        // 武器のID
        public static const NUM_WEAPONS:int = 14;
        public static const WEAPON_PISTOL:int = 0;
        public static const WEAPON_MASKET:int = 1;
        public static const WEAPON_MINIMI:int = 2;
        public static const WEAPON_ROSEBOW:int = 3;
        public static const WEAPON_BLACKBOW:int = 4;
        public static const WEAPON_EXTINGUISHER:int = 5;
        public static const WEAPON_PIPEBOMB:int = 6;
        public static const WEAPON_RPG7:int = 7;
        public static const WEAPON_GOLFCLUB:int = 8;
        public static const WEAPON_METALBAT:int = 9;
        public static const WEAPON_SABER:int = 10;
        public static const WEAPON_SPEAR:int = 11;
        public static const WEAPON_TIROFINALE:int = 12;
        public static const WEAPON_PUNCH:int = 13;
        // 武器攻撃タイプのID
        public static const ATTACKTYPE_SHOOTING:int = 0;
        public static const ATTACKTYPE_EXPLOSIVE:int = 1;
        public static const ATTACKTYPE_MELEE:int = 2;
        
        public static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
        
        public static const IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/2/2e/2e4b/2e4bd35a75f5c41025a94ee0f953e5cff554dfb7";
        
        public static const FONT:String = "Azuki";
        
        public static const EXP_TABLE:Array = [
              50,   70,  100,  120,  140,  170,  210,  250,  300,
             350,  410,  470,  530,  600,  670,  740,  820,  900,
            1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800,
            2000, 2200, 2400, 2600, 2800, 3000, 3200, 3400, 3600,
            3900, 4200, 4500, 4800, 5100, 5400, 5700, 6000, 6300,
            7000, 7400, 7800, 8200, 8600, 9000, 9400, 9800, 9999,
            9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999,
            9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999,
            9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999,
            9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999,
            9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999, 9999
        ];
        
        public static const ENEMY_TABLE:XML =
        <root>
            <wave num= "1" amount= "15" hp= "100" str= "5" vx= "40" />
            <wave num= "2" amount= "18" hp= "100" str= "5" vx= "40" />
            <wave num= "3" amount= "20" hp= "100" str= "5" vx= "40" />
            <wave num= "4" amount= "22" hp= "100" str= "5" vx= "40" />
            <wave num= "5" amount= "25" hp= "100" str= "5" vx= "40" />
            <wave num= "6" amount= "30" hp= "102" str= "5" vx= "41" />
            <wave num= "7" amount= "35" hp= "104" str= "5" vx= "41" />
            <wave num= "8" amount= "40" hp= "106" str= "5" vx= "41" />
            <wave num= "9" amount= "45" hp= "108" str= "5" vx= "41" />
            <wave num="10" amount= "50" hp= "110" str= "6" vx= "42" />
            <wave num="11" amount= "55" hp= "112" str= "6" vx= "42" />
            <wave num="12" amount= "60" hp= "114" str= "6" vx= "42" />
            <wave num="13" amount= "65" hp= "116" str= "6" vx= "42" />
            <wave num="14" amount= "70" hp= "118" str= "6" vx= "43" />
            <wave num="15" amount= "75" hp= "120" str= "7" vx= "43" />
            <wave num="16" amount= "80" hp= "122" str= "7" vx= "43" />
            <wave num="17" amount= "85" hp= "124" str= "7" vx= "44" />
            <wave num="18" amount= "90" hp= "126" str= "7" vx= "44" />
            <wave num="19" amount= "95" hp= "128" str= "7" vx= "44" />
            <wave num="20" amount="100" hp= "130" str= "8" vx= "45" />
            <wave num="21" amount="110" hp= "132" str= "8" vx= "45" />
            <wave num="22" amount="120" hp= "134" str= "8" vx= "46" />
            <wave num="23" amount="130" hp= "136" str= "8" vx= "46" />
            <wave num="24" amount="140" hp= "138" str=" 8" vx= "47" />
            <wave num="25" amount="150" hp= "140" str= "9" vx= "47" />
            <wave num="26" amount="160" hp= "142" str= "9" vx= "48" />
            <wave num="27" amount="170" hp= "144" str= "9" vx= "48" />
            <wave num="28" amount="180" hp= "146" str= "9" vx= "49" />
            <wave num="29" amount="190" hp= "148" str= "9" vx= "49" />
            <wave num="30" amount="200" hp= "150" str="10" vx= "50" />
            <wave num="31" amount="210" hp= "155" str="10" vx= "51" />
            <wave num="32" amount="220" hp= "160" str="10" vx= "52" />
            <wave num="33" amount="230" hp= "165" str="11" vx= "53" />
            <wave num="34" amount="240" hp= "170" str="11" vx= "54" />
            <wave num="35" amount="250" hp= "175" str="11" vx= "55" />
            <wave num="36" amount="260" hp= "180" str="12" vx= "56" />
            <wave num="37" amount="270" hp= "185" str="12" vx= "57" />
            <wave num="38" amount="280" hp= "190" str="12" vx= "58" />
            <wave num="39" amount="290" hp= "195" str="13" vx= "59" />
            <wave num="40" amount="300" hp= "200" str="13" vx= "60" />
            <wave num="41" amount="320" hp= "220" str="13" vx= "62" />
            <wave num="42" amount="340" hp= "240" str="14" vx= "64" />
            <wave num="43" amount="360" hp= "260" str="14" vx= "66" />
            <wave num="44" amount="380" hp= "280" str="14" vx= "68" />
            <wave num="45" amount="400" hp= "300" str="15" vx= "70" />
            <wave num="46" amount="420" hp= "320" str="15" vx= "72" />
            <wave num="47" amount="440" hp= "340" str="15" vx= "74" />
            <wave num="48" amount="460" hp= "360" str="16" vx= "76" />
            <wave num="49" amount="480" hp= "380" str="16" vx= "78" />
            <wave num="50" amount="500" hp= "400" str="16" vx= "80" />
            <wave num="51" amount="530" hp= "450" str="17" vx= "84" />
            <wave num="52" amount="560" hp= "500" str="17" vx= "88" />
            <wave num="53" amount="590" hp= "550" str="17" vx= "92" />
            <wave num="54" amount="620" hp= "600" str="18" vx= "96" />
            <wave num="55" amount="650" hp= "650" str="18" vx="100" />
            <wave num="56" amount="680" hp= "700" str="18" vx="104" />
            <wave num="57" amount="710" hp= "750" str="19" vx="108" />
            <wave num="58" amount="740" hp= "800" str="19" vx="112" />
            <wave num="59" amount="770" hp= "850" str="19" vx="116" />
            <wave num="60" amount="800" hp= "900" str="20" vx="120" />
            <wave num="61" amount="800" hp="1330" str="25" vx="123" />
            <wave num="62" amount="800" hp="1460" str="25" vx="126" />
            <wave num="63" amount="800" hp="1590" str="25" vx="129" />
            <wave num="64" amount="800" hp="1720" str="25" vx="132" />
            <wave num="65" amount="800" hp="1850" str="25" vx="135" />
            <wave num="66" amount="800" hp="1980" str="25" vx="138" />
            <wave num="67" amount="800" hp="2110" str="25" vx="141" />
            <wave num="68" amount="800" hp="2240" str="25" vx="144" />
            <wave num="69" amount="800" hp="2370" str="25" vx="147" />
            <wave num="70" amount="800" hp="2500" str="25" vx="150" />
            <wave num="71" amount="800" hp="2630" str="25" vx="153" />
            <wave num="72" amount="800" hp="2760" str="25" vx="156" />
            <wave num="73" amount="800" hp="2890" str="25" vx="159" />
            <wave num="74" amount="800" hp="3020" str="25" vx="162" />
            <wave num="75" amount="800" hp="3150" str="25" vx="165" />
            <wave num="76" amount="800" hp="3280" str="25" vx="168" />
            <wave num="77" amount="800" hp="3410" str="25" vx="171" />
            <wave num="78" amount="800" hp="3540" str="25" vx="174" />
            <wave num="79" amount="800" hp="3670" str="25" vx="177" />
            <wave num="80" amount="800" hp="3800" str="25" vx="180" />
            <wave num="81" amount="800" hp="3930" str="25" vx="183" />
            <wave num="82" amount="800" hp="4060" str="25" vx="186" />
            <wave num="83" amount="800" hp="4190" str="25" vx="189" />
            <wave num="84" amount="800" hp="4320" str="25" vx="192" />
            <wave num="85" amount="800" hp="4450" str="25" vx="195" />
            <wave num="86" amount="800" hp="4580" str="25" vx="198" />
            <wave num="87" amount="800" hp="4710" str="25" vx="201" />
            <wave num="88" amount="800" hp="4840" str="25" vx="204" />
            <wave num="89" amount="800" hp="4970" str="25" vx="207" />
            <wave num="90" amount="800" hp="5100" str="25" vx="210" />
            <wave num="91" amount="800" hp="5230" str="25" vx="213" />
            <wave num="92" amount="800" hp="5360" str="25" vx="216" />
            <wave num="93" amount="800" hp="5490" str="25" vx="219" />
            <wave num="94" amount="800" hp="5620" str="25" vx="222" />
            <wave num="95" amount="800" hp="5750" str="25" vx="225" />
            <wave num="96" amount="800" hp="5880" str="25" vx="228" />
            <wave num="97" amount="800" hp="6010" str="25" vx="231" />
            <wave num="98" amount="800" hp="6140" str="25" vx="234" />
            <wave num="99" amount="800" hp="6270" str="25" vx="237" />
            <wave num="100" amount="800" hp="6400" str="25" vx="240" />
        </root>;
        
        public static const WEAPON_QUALITY_TABLE:XML =
        <root>
            <quality id="bonecrash" name="ボンクラ" lv="1" wave="1" score="0">
                <level num="0" score="0" dmg="-20" />
                <level num="1" score="30" dmg="-5" crit="3" />
                <level num="2" score="70" dmg="10" crit="5" pene="1" />
            </quality>
            <quality id="normal" name="" lv="1" wave="1" score="50">
                <level num="0" score="0" />
                <level num="1" score="50" dmg="12" crit="3" />
                <level num="2" score="100" dmg="24" crit="5" pene="1" />
            </quality>
            <quality id="irregular" name="イレギュラー" lv="10" wave="10" score="200">
                <level num="0" score="0" dmg="35" />
                <level num="1" score="80" dmg="48" crit="3" />
                <level num="2" score="150" dmg="60" crit="5" pene="1" />
            </quality>
            <quality id="magical" name="マジカル" lv="20" wave="25" score="400">
                <level num="0" score="0" dmg="75" crit="3" pene="1" />
                <level num="1" score="150" dmg="90" crit="5" pene="1" />
                <level num="2" score="300" dmg="100" crit="7" pene="2" />
            </quality>
            <quality id="ultimate" name="アルティメット" lv="30" wave="35" score="700">
                <level num="0" score="0" dmg="125" crit="6" pene="1" />
                <level num="1" score="200" dmg="160" crit="8" pene="2" />
                <level num="2" score="400" dmg="200" crit="10" pene="3" />
            </quality>
        </root>;
        
        public static const WEAPON_BASE_TABLE:XML =
        <root>
            <base id={Const.WEAPON_PISTOL.toString()} name="ピストル" bmin="15" brand="25" brange="100" battack="400" breload="1000" bammo="12">
                <level num="0" score="0" />
                <level num="1" score="100" range="20" attack="10" str="2" vit="2" dex="2" luc="2" />
                <level num="2" score="300" range="40" attack="20" str="6" vit="6" dex="6" luc="6" />
                <level num="3" score="900" range="100" attack="40" str="15" vit="15" dex="15" luc="15" />
            </base>
            <base id={Const.WEAPON_MASKET.toString()} name="マスケット銃" bmin="55" brand="40" brange="180" battack="600" breload="2400" bammo="8">
                <level num="0" score="0" crit="15" />
                <level num="1" score="100" range="10" crit="20" />
                <level num="2" score="300" range="20" ammo="25" crit="25" />
                <level num="3" score="900" range="50" ammo="50" crit="30" />
            </base>
            <base id={Const.WEAPON_MINIMI.toString()} name="ミニミ" bmin="5" brand="25" brange="150" battack="150" breload="4000" bammo="50">
                <level num="0" score="0" dex="-2" />
                <level num="1" score="100" attack="10" ammo="10" dex="-4" />
                <level num="2" score="300" min="5" attack="20" ammo="20" dex="-6" />
                <level num="3" score="900" min="15" attack="30" ammo="50" dex="-8" />
            </base>
            <base id={Const.WEAPON_ROSEBOW.toString()} name="ローズボウ" bmin="10" brand="15" brange="120" battack="200" breload="2500" bammo="24">
                <level num="0" score="0" pene="3" />
                <level num="1" score="100" range="10" luc="3" pene="4" />
                <level num="2" score="300" range="20" luc="9" pene="5" />
                <level num="3" score="900" range="50" luc="20" pene="10" />
            </base>
            <base id={Const.WEAPON_BLACKBOW.toString()} name="ブラックボウ" bmin="10" brand="40" brange="130" battack="300" breload="2600" bammo="18">
                <level num="0" score="0" pene="1" />
                <level num="1" score="100" range="10" dex="3" crit="3" pene="1" />
                <level num="2" score="300" range="20" dex="9" crit="5" pene="2" />
                <level num="3" score="900" range="50" dex="20" crit="10" pene="5" />
            </base>
            <base id={Const.WEAPON_EXTINGUISHER.toString()} name="消火器" bmin="5" brand="15" brange="36" battack="500" breload="2500" bammo="10">
                <level num="0" score="0" kb="14" />
                <level num="1" score="100" crit="3" kb="17" />
                <level num="2" score="300" crit="5" kb="20" />
                <level num="3" score="900" crit="10" kb="30" />
            </base>
            <base id={Const.WEAPON_PIPEBOMB.toString()} name="パイプ爆弾" bmin="20" brand="30" brange="36" battack="350" breload="2700" bammo="15">
                <level num="0" score="0" kb="2" />
                <level num="1" score="100" attack="5" reload="5" kb="3" />
                <level num="2" score="300" attack="10" reload="10" kb="4" />
                <level num="3" score="900" attack="30" reload="30" kb="5" />
            </base>
            <base id={Const.WEAPON_RPG7.toString()} name="ロケットランチャー" bmin="40" brand="100" brange="45" battack="1000" breload="3500" bammo="4">
                <level num="0" score="0" dex="-3" kb="10" />
                <level num="1" score="100" range="5" dex="-6" kb="12" />
                <level num="2" score="300" range="10" ammo="25" dex="-9" kb="14" />
                <level num="3" score="900" range="30" ammo="50" dex="-12" kb="20" />
            </base>
            <base id={Const.WEAPON_GOLFCLUB.toString()} name="ゴルフクラブ" bmin="25" brand="20" brange="38" battack="150" breload="450" bammo="1">
                <level num="0" score="0" />
                <level num="1" score="100" reload="10" crit="5" />
                <level num="2" score="300" reload="20" crit="10" />
                <level num="3" score="900" reload="40" crit="20" />
            </base>
            <base id={Const.WEAPON_METALBAT.toString()} name="金属バット" bmin="0" brand="89" brange="38" battack="150" breload="600" bammo="1">
                <level num="0" score="0" crit="10" kb="4" />
                <level num="1" score="100" rand="10" crit="15" kb="6" />
                <level num="2" score="300" rand="30" crit="20" kb="8" />
                <level num="3" score="900" rand="100" crit="25" kb="10" />
            </base>
            <base id={Const.WEAPON_SABER.toString()} name="サーベル" bmin="45" brand="10" brange="38" battack="150" breload="600" bammo="1">
                <level num="0" score="0" />
                <level num="1" score="100" dmg="10" reload="5" vit="3" />
                <level num="2" score="300" dmg="30" reload="10" vit="9" />
                <level num="3" score="900" dmg="50" reload="20" vit="20" />
            </base>
            <base id={Const.WEAPON_SPEAR.toString()} name="スピア" bmin="40" brand="40" brange="48" battack="150" breload="900" bammo="1">
                <level num="0" score="0" />
                <level num="1" score="100" range="10" str="3" kb="3" />
                <level num="2" score="300" range="20" str="9" kb="6" />
                <level num="3" score="900" range="40" str="20" kb="9" />
            </base>
            <base id={Const.WEAPON_TIROFINALE.toString()} name="ティロフィナーレ" bmin="30" brand="50" brange="200" battack="100" breload="20000" bammo="5">
                <level num="0" score="0" vit="-3" pene="10" />
                <level num="1" score="100" vit="-6" crit="5" kb="5" pene="20" />
                <level num="2" score="300" vit="-9" crit="10" kb="7" pene="30" />
                <level num="3" score="900" vit="-12" crit="20" kb="10" pene="40" />
            </base>
            <base id={Const.WEAPON_PUNCH.toString()} name="パンチ" bmin="70" brand="30" brange="24" battack="150" breload="450" bammo="1">
                <level num="0" score="0" kb="10" />
                <level num="1" score="100" min="10" kb="12" />
                <level num="2" score="300" min="25" kb="16" />
                <level num="3" score="900" min="50" kb="24" />
            </base>
        </root>;
        
        public static const WEAPON_PREFIX_TABLE:XML =
        <root>
            <prefix id="none" name="" lv="1" wave="1" score="0" base="11111111111111">
                <level num="0" score="0" />
            </prefix>
            <prefix id="syosinsya" name="初心者用" lv="1" wave="1" score="20" base="11111111111111">
                <level num="0" score="0" dmg="4" />
                <level num="1" score="10" dmg="8" />
                <level num="2" score="20" dmg="12" />
                <level num="3" score="30" dmg="16" />
                <level num="4" score="40" dmg="20" />
            </prefix>
            <prefix id="syobokure" name="しょぼくれた" lv="1" wave="1" score="20" base="11111111111111">
                <level num="0" score="0" dmg="-20" str="1" vit="1" dex="1" luc="1" />
                <level num="1" score="10" dmg="-40" str="2" vit="2" dex="2" luc="2" />
                <level num="2" score="20" dmg="-60" str="3" vit="3" dex="3" luc="3" />
                <level num="3" score="30" dmg="-80" str="4" vit="4" dex="4" luc="4" />
                <level num="4" score="40" dmg="-100" str="5" vit="5" dex="5" luc="5" />
            </prefix>
            <prefix id="kegare" name="穢れた" lv="1" wave="1" score="20" base="11111111111111">
                <level num="0" score="0" min="2" rand="-4" />
                <level num="1" score="10" min="4" rand="-8" />
                <level num="2" score="20" min="6" rand="-12" />
                <level num="3" score="30" min="8" rand="-16" />
                <level num="4" score="40" min="10" rand="-20" />
            </prefix>
            <prefix id="horobinageki" name="滅びと嘆きの" lv="1" wave="1" score="20" base="11111111111111">
                <level num="0" score="0" min="-2" rand="4" />
                <level num="1" score="10" min="-4" rand="8" />
                <level num="2" score="20" min="-6" rand="12" />
                <level num="3" score="30" min="-8" rand="16" />
                <level num="4" score="40" min="-10" rand="20" />
            </prefix>
            <prefix id="yurusarenai" name="許されない" lv="1" wave="1" score="20" base="11111000111111">
                <level num="0" score="0" range="4" />
                <level num="1" score="10" range="8" />
                <level num="2" score="20" range="12" />
                <level num="3" score="30" range="16" />
                <level num="4" score="40" range="20" />
            </prefix>
            <prefix id="inga" name="因果の" lv="1" wave="1" score="20" base="11111111111111">
                <level num="0" score="0" dmg="-8" min="-4" attack="3" reload="2" />
                <level num="1" score="10" dmg="-9" min="-4" attack="6" reload="4" />
                <level num="2" score="20" dmg="-10" min="-4" attack="9" reload="6" />
                <level num="3" score="30" dmg="-11" min="-4" attack="12" reload="8" />
                <level num="4" score="40" dmg="-12" min="-4" attack="15" reload="10" />
            </prefix>
            <prefix id="hidosugi" name="ひどすぎる" lv="1" wave="1" score="20" base="11111111000010">
                <level num="0" score="0" attack="5" ammo="-10" />
                <level num="1" score="10" attack="10" ammo="-20" />
                <level num="2" score="20" attack="15" ammo="-30" />
                <level num="3" score="30" attack="20" ammo="-40" />
                <level num="4" score="40" attack="25" ammo="-50" />
            </prefix>
            <prefix id="hituyounai" name="必要のない" lv="1" wave="1" score="20" base="11111111000010">
                <level num="0" score="0" attack="-3" reload="4" />
                <level num="1" score="10" attack="-6" reload="8" />
                <level num="2" score="20" attack="-9" reload="12" />
                <level num="3" score="30" attack="-12" reload="16" />
                <level num="4" score="40" attack="-15" reload="20" />
            </prefix>
            <prefix id="sagi" name="詐欺の" lv="1" wave="1" score="20" base="111111110000000">
                <level num="0" score="0" range="-8" ammo="4" />
                <level num="1" score="10" range="-16" ammo="8" />
                <level num="2" score="20" range="-24" ammo="12" />
                <level num="3" score="30" range="-32" ammo="16" />
                <level num="4" score="40" range="-40" ammo="20" />
            </prefix>
            <prefix id="zettaiokasi" name="絶対おかしい" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" min="1" rand="1" />
                <level num="1" score="15" min="2" rand="2" />
                <level num="2" score="30" min="3" rand="3" />
                <level num="3" score="45" min="4" rand="4" />
                <level num="4" score="60" min="5" rand="5" />
            </prefix>
            <prefix id="gusya" name="愚者の" lv="2" wave="3" score="60" base="00000000111101">
                <level num="0" score="0" reload="3" />
                <level num="1" score="15" reload="6" />
                <level num="2" score="30" reload="9" />
                <level num="3" score="45" reload="12" />
                <level num="4" score="60" reload="15" />
            </prefix>
            <prefix id="mubousugi" name="無謀すぎる" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" str="2" />
                <level num="1" score="15" str="3" />
                <level num="2" score="30" str="4" />
                <level num="3" score="45" str="5" />
                <level num="4" score="60" str="6" />
            </prefix>
            <prefix id="hakanaiasita" name="儚い明日の" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" vit="2" />
                <level num="1" score="15" vit="3" />
                <level num="2" score="30" vit="4" />
                <level num="3" score="45" vit="5" />
                <level num="4" score="60" vit="6" />
            </prefix>
            <prefix id="mienai" name="人には見えない" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" dex="2" />
                <level num="1" score="15" dex="3" />
                <level num="2" score="30" dex="4" />
                <level num="3" score="45" dex="5" />
                <level num="4" score="60" dex="6" />
            </prefix>
            <prefix id="hadesugi" name="派手すぎる" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" luc="2" />
                <level num="1" score="15" luc="3" />
                <level num="2" score="30" luc="4" />
                <level num="3" score="45" luc="5" />
                <level num="4" score="60" luc="6" />
            </prefix>
            <prefix id="wakewakaran" name="わけがわからない" lv="2" wave="3" score="60" base="11111111111111">
                <level num="0" score="0" crit="1" pene="1" />
                <level num="1" score="15" crit="2" pene="1" />
                <level num="2" score="30" crit="3" pene="1" />
                <level num="3" score="45" crit="4" pene="1" />
                <level num="4" score="60" crit="5" pene="1" />
            </prefix>
            <prefix id="benri" name="便利な" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" str="1" vit="1" />
                <level num="1" score="25" str="2" vit="2" />
                <level num="2" score="50" str="3" vit="3" />
                <level num="3" score="75" str="4" vit="4" />
                <level num="4" score="100" str="5" vit="5" />
            </prefix>
            <prefix id="jiman" name="自慢の" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" str="1" dex="1" />
                <level num="1" score="25" str="2" dex="2" />
                <level num="2" score="50" str="3" dex="3" />
                <level num="3" score="75" str="4" dex="4" />
                <level num="4" score="100" str="5" dex="5" />
            </prefix>
            <prefix id="yuuki" name="勇気の" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" str="1" luc="1" />
                <level num="1" score="25" str="2" luc="2" />
                <level num="2" score="50" str="3" luc="3" />
                <level num="3" score="75" str="4" luc="4" />
                <level num="4" score="100" str="5" luc="5" />
            </prefix>
            <prefix id="yakudati" name="役に立つ" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" vit="1" dex="1" />
                <level num="1" score="25" vit="2" dex="2" />
                <level num="2" score="50" vit="3" dex="3" />
                <level num="3" score="75" vit="4" dex="4" />
                <level num="4" score="100" vit="5" dex="5" />
            </prefix>
            <prefix id="omosiromi" name="面白みのある" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" vit="1" luc="1" />
                <level num="1" score="25" vit="2" luc="2" />
                <level num="2" score="50" vit="3" luc="3" />
                <level num="3" score="75" vit="4" luc="4" />
                <level num="4" score="100" vit="5" luc="5" />
            </prefix>
            <prefix id="suteki" name="素敵な" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" dex="1" luc="1" />
                <level num="1" score="25" dex="2" luc="2" />
                <level num="2" score="50" dex="3" luc="3" />
                <level num="3" score="75" dex="4" luc="4" />
                <level num="4" score="100" dex="5" luc="5" />
            </prefix>
            <prefix id="jihi" name="慈悲の" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" dmg="-50" vit="10" />
                <level num="1" score="25" dmg="-50" vit="12" />
                <level num="2" score="50" dmg="-50" vit="14" />
                <level num="3" score="75" dmg="-50" vit="16" />
                <level num="4" score="100" dmg="-50" vit="18" />
            </prefix>
            <prefix id="nazonosiroi" name="謎の白い" lv="4" wave="6" score="100" base="11111111111111">
                <level num="0" score="0" dmg="-50" luc="10" />
                <level num="1" score="25" dmg="-50" luc="12" />
                <level num="2" score="50" dmg="-50" luc="14" />
                <level num="3" score="75" dmg="-50" luc="16" />
                <level num="4" score="100" dmg="-50" luc="18" />
            </prefix>
            <prefix id="gouyoku" name="強欲の" lv="4" wave="6" score="100" base="11011011111111">
                <level num="0" score="0" crit="1" kb="1" />
                <level num="1" score="25" crit="2" kb="2" />
                <level num="2" score="50" crit="3" kb="3" />
                <level num="3" score="75" crit="4" kb="4" />
                <level num="4" score="100" crit="5" kb="5" />
            </prefix>
            <prefix id="minnaninaisyo" name="みんなには内緒の" lv="4" wave="6" score="100" base="11111000000000">
                <level num="0" score="0" pene="2" />
                <level num="1" score="25" pene="3" />
                <level num="2" score="50" pene="4" />
                <level num="3" score="75" pene="5" />
                <level num="4" score="100" pene="6" />
            </prefix>
            <prefix id="tokubetu" name="特別な" lv="8" wave="10" score="160" base="11111111111111">
                <level num="0" score="0" dmg="25" />
                <level num="1" score="40" dmg="30" />
                <level num="2" score="80" dmg="35" />
                <level num="3" score="120" dmg="40" />
                <level num="4" score="160" dmg="45" />
            </prefix>
            <prefix id="zankoku" name="残酷な" lv="8" wave="10" score="160" base="11111111111111">
                <level num="0" score="0" dmg="50" vit="-6" dex="-6" luc="-6" />
                <level num="1" score="40" dmg="60" vit="-7" dex="-7" luc="-7" />
                <level num="2" score="80" dmg="70" vit="-8" dex="-8" luc="-8" />
                <level num="3" score="120" dmg="80" vit="-9" dex="-9" luc="-9" />
                <level num="4" score="160" dmg="90" vit="-10" dex="-10" luc="-10" />
            </prefix>
            <prefix id="burai" name="無頼の" lv="8" wave="10" score="160" base="11111111111111">
                <level num="0" score="0" min="2" />
                <level num="1" score="40" min="4" />
                <level num="2" score="80" min="6" />
                <level num="3" score="120" min="8" />
                <level num="4" score="160" min="10" />
            </prefix>
            <prefix id="futeki" name="不敵の" lv="8" wave="10" score="160" base="11111111111111">
                <level num="0" score="0" rand="5" />
                <level num="1" score="40" rand="10" />
                <level num="2" score="80" rand="15" />
                <level num="3" score="120" rand="20" />
                <level num="4" score="160" rand="25" />
            </prefix>
            <prefix id="kagayaki" name="輝きの" lv="8" wave="10" score="160" base="11111111000010">
                <level num="0" score="0" attack="4" />
                <level num="1" score="40" attack="8" />
                <level num="2" score="80" attack="12" />
                <level num="3" score="120" attack="16" />
                <level num="4" score="160" attack="20" />
            </prefix>
            <prefix id="seigi" name="正義の" lv="8" wave="10" score="160" base="11111111111111">
                <level num="0" score="0" crit="5" kb="2" />
                <level num="1" score="40" crit="6" kb="2" />
                <level num="2" score="80" crit="7" kb="2" />
                <level num="3" score="120" crit="8" kb="2" />
                <level num="4" score="160" crit="9" kb="2" />
            </prefix>
            <prefix id="kindan" name="禁断の" lv="10" wave="12" score="180" base="00000000111101">
                <level num="0" score="0" dmg="100" reload="-60" />
                <level num="1" score="50" dmg="110" reload="-60" />
                <level num="2" score="100" dmg="120" reload="-60" />
                <level num="3" score="150" dmg="130" reload="-60" />
                <level num="4" score="200" dmg="140" reload="-60" />
            </prefix>
            <prefix id="risou" name="理想の" lv="10" wave="12" score="180" base="11111111000010">
                <level num="0" score="0" reload="3" ammo="4" />
                <level num="1" score="50" reload="6" ammo="8" />
                <level num="2" score="100" reload="9" ammo="12" />
                <level num="3" score="150" reload="12" ammo="16" />
                <level num="4" score="200" reload="15" ammo="20" />
            </prefix>
            <prefix id="kakugo" name="覚悟の" lv="10" wave="12" score="180" base="11111111111111">
                <level num="0" score="0" dmg="2" str="8" vit="-2" />
                <level num="1" score="50" dmg="4" str="9" vit="-2"  />
                <level num="2" score="100" dmg="6" str="10" vit="-2" />
                <level num="3" score="150" dmg="8" str="11" vit="-2" />
                <level num="4" score="200" dmg="10" str="12" vit="-2" />
            </prefix>
            <prefix id="fukutu" name="不屈の" lv="10" wave="12" score="180" base="11111111111111">
                <level num="0" score="0" dmg="2" str="-2" vit="8" />
                <level num="1" score="50" dmg="4" str="-2" vit="9" />
                <level num="2" score="100" dmg="6" str="-2" vit="10" />
                <level num="3" score="150" dmg="8" str="-2" vit="11" />
                <level num="4" score="200" dmg="10" str="-2" vit="12" />
            </prefix>
            <prefix id="kareina" name="華麗なる" lv="10" wave="12" score="180" base="11111111111111">
                <level num="0" score="0" dmg="2" dex="8" luc="-2" />
                <level num="1" score="50" dmg="4" dex="9" luc="-2" />
                <level num="2" score="100" dmg="6" dex="10" luc="-2" />
                <level num="3" score="150" dmg="8" dex="11" luc="-2" />
                <level num="4" score="200" dmg="10" dex="12" luc="-2" />
            </prefix>
            <prefix id="kakkoii" name="かっこいい" lv="10" wave="12" score="180" base="11111111111111">
                <level num="0" score="0" dmg="2" dex="-2" luc="8" />
                <level num="1" score="50" dmg="4" dex="-2" luc="9" />
                <level num="2" score="100" dmg="6" dex="-2" luc="10" />
                <level num="3" score="150" dmg="8" dex="-2" luc="11" />
                <level num="4" score="200" dmg="10" dex="-2" luc="12" />
            </prefix>
            <prefix id="yakusoku" name="約束の" lv="10" wave="12" score="180" base="11111000000010">
                <level num="0" score="0" min="1" rand="2" pene="2" />
                <level num="1" score="50" min="2" rand="4" pene="2" />
                <level num="2" score="100" min="3" rand="6" pene="2" />
                <level num="3" score="150" min="4" rand="8" pene="2" />
                <level num="4" score="200" min="5" rand="10" pene="2" />
            </prefix>
            <prefix id="tottemouresi" name="とっても嬉しい" lv="12" wave="15" score="200" base="11111111111111">
                <level num="0" score="0" str="1" vit="1" dex="1" luc="1" />
                <level num="1" score="50" str="2" vit="2" dex="2" luc="2" />
                <level num="2" score="100" str="3" vit="3" dex="3" luc="3" />
                <level num="3" score="150" str="4" vit="4" dex="4" luc="4" />
                <level num="4" score="200" str="5" vit="5" dex="5" luc="5" />
            </prefix>
            <prefix id="erabaresi" name="選ばれし" lv="12" wave="15" score="200" base="11111111111111">
                <level num="0" score="0" rand="2" str="6" luc="6" />
                <level num="1" score="50" rand="4" str="7" luc="7" />
                <level num="2" score="100" rand="6" str="8" luc="8" />
                <level num="3" score="150" rand="8" str="9" luc="9" />
                <level num="4" score="200" rand="10" str="10" luc="10" />
            </prefix>
            <prefix id="syugo" name="守護の" lv="12" wave="15" score="200" base="11111111111111">
                <level num="0" score="0" min="1" vit="6" dex="6" />
                <level num="1" score="50" min="2" vit="7" dex="7" />
                <level num="2" score="100" min="3" vit="8" dex="8" />
                <level num="3" score="150" min="4" vit="9" dex="9" />
                <level num="4" score="200" min="5" vit="10" dex="10" />
            </prefix>
            <prefix id="tokiwokoe" name="時を越えた" lv="12" wave="15" score="200" base="11111111111111">
                <level num="0" score="0" dmg="3" reload="8" crit="5" />
                <level num="1" score="50" dmg="6" reload="9" crit="5" />
                <level num="2" score="100" dmg="9" reload="10" crit="5" />
                <level num="3" score="150" dmg="12" reload="11" crit="5" />
                <level num="4" score="200" dmg="15" reload="12" crit="5" />
            </prefix>
            <prefix id="kokoroduyo" name="心強い" lv="12" wave="15" score="200" base="11111111111111">
                <level num="0" score="0" dmg="3" range="8" kb="2" />
                <level num="1" score="50" dmg="6" range="9" kb="2" />
                <level num="2" score="100" dmg="9" range="10" kb="2" />
                <level num="3" score="150" dmg="12" range="11" kb="2" />
                <level num="4" score="200" dmg="15" range="12" kb="2" />
            </prefix>
            <prefix id="kansya" name="感謝の" lv="12" wave="15" score="200" base="11111111000010">
                <level num="0" score="0" attack="5" ammo="30" dex="2" />
                <level num="1" score="50" attack="5" ammo="35" dex="2" />
                <level num="2" score="100" attack="5" ammo="40" dex="2" />
                <level num="3" score="150" attack="5" ammo="45" dex="2" />
                <level num="4" score="200" attack="5" ammo="50" dex="2" />
            </prefix>
            <prefix id="inori" name="祈りの" lv="12" wave="15" score="200" base="00000000111101">
                <level num="0" score="0" dmg="8" range="10" reload="6" />
                <level num="1" score="50" dmg="8" range="12" reload="8" />
                <level num="2" score="100" dmg="8" range="14" reload="10" />
                <level num="3" score="150" dmg="8" range="16" reload="12" />
                <level num="4" score="200" dmg="8" range="18" reload="14" />
            </prefix>
            <prefix id="subarasi" name="素晴らしい" lv="15" wave="18" score="250" base="11111111111111">
                <level num="0" score="0" dmg="32" min="4" rand="8" />
                <level num="1" score="60" dmg="35" min="5" rand="10" />
                <level num="2" score="120" dmg="38" min="6" rand="12" />
                <level num="3" score="180" dmg="41" min="7" rand="14" />
                <level num="4" score="240" dmg="44" min="8" rand="16" />
            </prefix>
            <prefix id="miryokuteki" name="魅力的な" lv="15" wave="18" score="250" base="11111111111111">
                <level num="0" score="0" rand="20" str="10" crit="4" />
                <level num="1" score="60" rand="25" str="10" crit="4" />
                <level num="2" score="120" rand="30" str="10" crit="4" />
                <level num="3" score="180" rand="35" str="10" crit="4" />
                <level num="4" score="240" rand="40" str="10" crit="4" />
            </prefix>
            <prefix id="gisei" name="犠牲の" lv="15" wave="18" score="250" base="11111111111111">
                <level num="0" score="0" dmg="-22" str="-6" vit="6" dex="6" luc="6" />
                <level num="1" score="60" dmg="-24" str="-7" vit="7" dex="7" luc="7" />
                <level num="2" score="120" dmg="-26" str="-8" vit="8" dex="8" luc="8" />
                <level num="3" score="180" dmg="-28" str="-9" vit="9" dex="9" luc="9" />
                <level num="4" score="240" dmg="-30" str="-10" vit="10" dex="10" luc="10" />
            </prefix>
            <prefix id="negai" name="願いの" lv="15" wave="18" score="250" base="11000011111111">
                <level num="0" score="0" attack="8" reload="10" kb="6" />
                <level num="1" score="60" attack="10" reload="10" kb="7" />
                <level num="2" score="120" attack="12" reload="10" kb="8" />
                <level num="3" score="180" attack="14" reload="10" kb="9" />
                <level num="4" score="240" attack="16" reload="10" kb="10" />
            </prefix>
            <prefix id="aino" name="愛の" lv="15" wave="18" score="250" base="11111000000010">
                <level num="0" score="0" dmg="20" ammo="20" pene="1" />
                <level num="1" score="60" dmg="25" ammo="20" pene="1" />
                <level num="2" score="120" dmg="30" ammo="20" pene="1" />
                <level num="3" score="180" dmg="35" ammo="20" pene="1" />
                <level num="4" score="240" dmg="40" ammo="20" pene="1" />
            </prefix>
            <prefix id="sinjitu" name="真実の" lv="15" wave="18" score="250" base="00000111000000">
                <level num="0" score="0" min="8" range="30" reload="-16" />
                <level num="1" score="60" min="9" range="35" reload="-18" />
                <level num="2" score="120" min="10" range="40" reload="-20" />
                <level num="3" score="180" min="11" range="45" reload="-22" />
                <level num="4" score="240" min="12" range="50" reload="-24" />
            </prefix>
            <prefix id="daisyou" name="代償の" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" dmg="160" min="8" rand="16" vit="-11" dex="-11" luc="-11" />
                <level num="1" score="75" dmg="170" min="9" rand="18" vit="-12" dex="-12" luc="-12" />
                <level num="2" score="150" dmg="180" min="10" rand="20" vit="-13" dex="-13" luc="-13" />
                <level num="3" score="225" dmg="190" min="11" rand="22" vit="-14" dex="-14" luc="-14" />
                <level num="4" score="300" dmg="200" min="12" rand="24" vit="-15" dex="-15" luc="-15" />
            </prefix>
            <prefix id="syuuen" name="終焉の" lv="20" wave="24" score="300" base="11111000000010">
                <level num="0" score="0" rand="80" range="-90" pene="3" />
                <level num="1" score="75" rand="85" range="-90" pene="3" />
                <level num="2" score="150" rand="90" range="-90" pene="3" />
                <level num="3" score="225" rand="95" range="-90" pene="3" />
                <level num="4" score="300" rand="100" range="-90" pene="3" />
            </prefix>
            <prefix id="yamifuriharau" name="闇をふり払う" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" reload="28" str="12" crit="5" pene="1" />
                <level num="1" score="75" reload="31" str="14" crit="5" pene="1" />
                <level num="2" score="150" reload="34" str="16" crit="5" pene="1" />
                <level num="3" score="225" reload="37" str="18" crit="5" pene="1" />
                <level num="4" score="300" reload="40" str="20" crit="5" pene="1" />
            </prefix>
            <prefix id="kensin" name="献身の" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" dmg="28" vit="12" crit="5" kb="3" />
                <level num="1" score="75" dmg="31" vit="14" crit="5" kb="3" />
                <level num="2" score="150" dmg="34" vit="16" crit="5" kb="3" />
                <level num="3" score="225" dmg="37" vit="18" crit="5" kb="3" />
                <level num="4" score="300" dmg="40" vit="20" crit="5" kb="3" />
            </prefix>
            <prefix id="kakusei" name="覚醒の" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" rand="24" dex="12" crit="5" pene="1" />
                <level num="1" score="75" rand="26" dex="14" crit="5" pene="1" />
                <level num="2" score="150" rand="28" dex="16" crit="5" pene="1" />
                <level num="3" score="225" rand="30" dex="18" crit="5" pene="1" />
                <level num="4" score="300" rand="32" dex="20" crit="5" pene="1" />
            </prefix>
            <prefix id="saikonisiawase" name="最高に幸せな" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" min="12" luc="12" kb="3" pene="1" />
                <level num="1" score="75" min="13" luc="14" kb="3" pene="1" />
                <level num="2" score="150" min="14" luc="16" kb="3" pene="1" />
                <level num="3" score="225" min="15" luc="18" kb="3" pene="1" />
                <level num="4" score="300" min="16" luc="20" kb="3" pene="1" />
            </prefix>
            <prefix id="bannou" name="万能の" lv="20" wave="24" score="300" base="11111111111111">
                <level num="0" score="0" dmg="22" str="6" vit="6" dex="6" luc="6" />
                <level num="1" score="75" dmg="24" str="7" vit="7" dex="7" luc="7" />
                <level num="2" score="150" dmg="26" str="8" vit="8" dex="8" luc="8" />
                <level num="3" score="225" dmg="28" str="9" vit="9" dex="9" luc="9" />
                <level num="4" score="300" dmg="30" str="10" vit="10" dex="10" luc="10" />
            </prefix>
            <prefix id="inisie" name="古の" lv="20" wave="24" score="300" base="00000000111101">
                <level num="0" score="0" dmg="18" range="18" str="17" dex="-7" />
                <level num="1" score="75" dmg="20" range="21" str="19" dex="-7" />
                <level num="2" score="150" dmg="22" range="24" str="21" dex="-7" />
                <level num="3" score="225" dmg="24" range="27" str="23" dex="-7" />
                <level num="4" score="300" dmg="26" range="30" str="25" dex="-7" />
            </prefix>
            <prefix id="zetubouaragau" name="絶望に抗う" lv="20" wave="24" score="300" base="00000000111101">
                <level num="0" score="0" dmg="30" range="11" vit="17" luc="-7" />
                <level num="1" score="75" dmg="35" range="12" vit="19" luc="-7" />
                <level num="2" score="150" dmg="40" range="13" vit="21" luc="-7" />
                <level num="3" score="225" dmg="45" range="14" vit="23" luc="-7" />
                <level num="4" score="300" dmg="50" range="15" vit="25" luc="-7" />
            </prefix>
            <prefix id="hikariyobisamasu" name="光を呼び覚ます" lv="20" wave="24" score="300" base="00000000111101">
                <level num="0" score="0" dmg="30" range="11" str="-7" dex="17" />
                <level num="1" score="75" dmg="35" range="12" str="-7" dex="19" />
                <level num="2" score="150" dmg="40" range="13" str="-7" dex="21" />
                <level num="3" score="225" dmg="45" range="14" str="-7" dex="23" />
                <level num="4" score="300" dmg="50" range="15" str="-7" dex="25" />
            </prefix>
            <prefix id="unmei" name="運命の" lv="20" wave="24" score="300" base="00000000111101">
                <level num="0" score="0" dmg="18" range="18" vit="-7" luc="17" />
                <level num="1" score="75" dmg="20" range="21" vit="-7" luc="19" />
                <level num="2" score="150" dmg="22" range="24" vit="-7" luc="21" />
                <level num="3" score="225" dmg="24" range="27" vit="-7" luc="23" />
                <level num="4" score="300" dmg="26" range="30" vit="-7" luc="25" />
            </prefix>
            <prefix id="kuukai" name="空海の" lv="25" wave="28" score="350" base="11111111111111">
                <level num="0" score="0" range="36" ammo="20" />
                <level num="1" score="80" range="37" ammo="21" />
                <level num="2" score="160" range="38" ammo="22" />
                <level num="3" score="240" range="39" ammo="23" />
                <level num="4" score="320" range="40" ammo="24" />
            </prefix>
            <prefix id="majogorosi" name="魔女殺しの" lv="25" wave="28" score="350" base="11111111000010">
                <level num="0" score="0" attack="80" reload="-42" crit="6" kb="2" pene="3" />
                <level num="1" score="80" attack="85" reload="-44" crit="7" kb="2" pene="3" />
                <level num="2" score="160" attack="90" reload="-46" crit="8" kb="2" pene="3" />
                <level num="3" score="240" attack="95" reload="-48" crit="9" kb="2" pene="3" />
                <level num="4" score="320" attack="100" reload="-50" crit="10" kb="2" pene="3" />
            </prefix>
            <prefix id="wasuresarare" name="忘れ去られた" lv="25" wave="28" score="350" base="11111111000010">
                <level num="0" score="0" attack="11" reload="13" ammo="24" str="16" dex="-6" />
                <level num="1" score="80" attack="12" reload="16" ammo="28" str="17" dex="-6" />
                <level num="2" score="160" attack="13" reload="19" ammo="32" str="18" dex="-6" />
                <level num="3" score="240" attack="14" reload="22" ammo="36" str="19" dex="-6" />
                <level num="4" score="320" attack="15" reload="25" ammo="40" str="20" dex="-6" />
            </prefix>
            <prefix id="syokuzai" name="贖罪の" lv="25" wave="28" score="350" base="11111111000010">
                <level num="0" score="0" attack="12" reload="13" ammo="18" vit="16" luc="-6" />
                <level num="1" score="80" attack="14" reload="16" ammo="21" vit="17" luc="-6" />
                <level num="2" score="160" attack="16" reload="19" ammo="24" vit="18" luc="-6" />
                <level num="3" score="240" attack="18" reload="22" ammo="27" vit="19" luc="-6" />
                <level num="4" score="320" attack="20" reload="25" ammo="30" vit="20" luc="-6" />
            </prefix>
            <prefix id="kyoufu" name="恐怖の" lv="25" wave="28" score="350" base="11111111000010">
                <level num="0" score="0" attack="13" reload="11" ammo="24" str="-6" dex="16" />
                <level num="1" score="80" attack="16" reload="12" ammo="28" str="-6" dex="17" />
                <level num="2" score="160" attack="19" reload="13" ammo="32" str="-6" dex="18" />
                <level num="3" score="240" attack="22" reload="14" ammo="36" str="-6" dex="19" />
                <level num="4" score="320" attack="25" reload="15" ammo="40" str="-6" dex="20" />
            </prefix>
            <prefix id="hangyaku" name="反逆の" lv="25" wave="28" score="350" base="11111111000010">
                <level num="0" score="0" attack="13" reload="12" ammo="18" vit="-6" luc="16" />
                <level num="1" score="80" attack="16" reload="14" ammo="21" vit="-6" luc="17" />
                <level num="2" score="160" attack="19" reload="16" ammo="24" vit="-6" luc="18" />
                <level num="3" score="240" attack="22" reload="18" ammo="27" vit="-6" luc="19" />
                <level num="4" score="320" attack="25" reload="20" ammo="30" vit="-6" luc="20" />
            </prefix>
            <prefix id="yumekibou" name="夢と希望の" lv="25" wave="28" score="350" base="11111111111111">
                <level num="0" score="0" dmg="-100" luc="30" />
                <level num="1" score="80" dmg="-100" luc="35" />
                <level num="2" score="160" dmg="-100" luc="40" />
                <level num="3" score="240" dmg="-100" luc="45" />
                <level num="4" score="320" dmg="-100" luc="50" />
            </prefix>
            <prefix id="jouka" name="浄化の" lv="25" wave="28" score="350" base="11111111111111">
                <level num="0" score="0" crit="18" />
                <level num="1" score="80" crit="21" />
                <level num="2" score="160" crit="24" />
                <level num="3" score="240" crit="27" />
                <level num="4" score="320" crit="30" />
            </prefix>
            <prefix id="kiseki" name="奇跡の" lv="30" wave="35" score="500" base="11111111111111">
                <level num="0" score="0" str="30" attack="16" reload="42" ammo="50" pene="2" />
                <level num="1" score="100" str="35" attack="17" reload="44" ammo="50" pene="2" />
                <level num="2" score="200" str="40" attack="18" reload="46" ammo="50" pene="2" />
                <level num="3" score="300" str="45" attack="19" reload="48" ammo="50" pene="2" />
                <level num="4" score="400" str="50" attack="20" reload="50" ammo="50" pene="2" />
            </prefix>
            <prefix id="enkan" name="円環の" lv="30" wave="35" score="500" base="11111111111111">
                <level num="0" score="0" rand="60" range="26" vit="30" crit="6" kb="5" pene="2" />
                <level num="1" score="100" rand="70" range="27" vit="35" crit="7" kb="5" pene="2" />
                <level num="2" score="200" rand="80" range="28" vit="40" crit="8" kb="5" pene="2" />
                <level num="3" score="300" rand="90" range="29" vit="45" crit="9" kb="5" pene="2" />
                <level num="4" score="400" rand="100" range="30" vit="50" crit="10" kb="5" pene="2" />
            </prefix>
            <prefix id="kyuusai" name="救済の" lv="30" wave="35" score="500" base="11111111111111">
                <level num="0" score="0" dmg="42" min="11" rand="22" dex="30" crit="8" pene="2" />
                <level num="1" score="100" dmg="44" min="12" rand="24" dex="35" crit="8" pene="2" />
                <level num="2" score="200" dmg="46" min="13" rand="26" dex="40" crit="8" pene="2" />
                <level num="3" score="300" dmg="48" min="14" rand="28" dex="45" crit="8" pene="2" />
                <level num="4" score="400" dmg="50" min="15" rand="30" dex="50" crit="8" pene="2" />
            </prefix>
            <prefix id="vswarupuru" name="対ワルプルギス" lv="30" wave="35" score="500" base="11111111111111">
                <level num="0" score="0" dmg="80" str="12" luc="12" crit="8" />
                <level num="1" score="100" dmg="85" str="13" luc="13" crit="8" />
                <level num="2" score="200" dmg="90" str="14" luc="14" crit="8" />
                <level num="3" score="300" dmg="95" str="15" luc="15" crit="8" />
                <level num="4" score="400" dmg="100" str="16" luc="16" crit="8" />
            </prefix>
            <prefix id="eien" name="永遠の" lv="30" wave="35" score="500" base="11111111000010">
                <level num="0" score="0" reload="80" ammo="80" vit="12" dex="12" />
                <level num="1" score="100" reload="85" ammo="90" vit="13" dex="13" />
                <level num="2" score="200" reload="90" ammo="90" vit="14" dex="14" />
                <level num="3" score="300" reload="95" ammo="95" vit="15" dex="15" />
                <level num="4" score="400" reload="100" ammo="100" vit="16" dex="16" />
            </prefix>
            <prefix id="madan" name="魔弾の" lv="30" wave="35" score="500" base="11111000000010">
                <level num="0" score="0" dmg="46" attack="26" reload="30" ammo="60" pene="3" />
                <level num="1" score="100" dmg="47" attack="27" reload="35" ammo="70" pene="3" />
                <level num="2" score="200" dmg="48" attack="28" reload="40" ammo="80" pene="3" />
                <level num="3" score="300" dmg="49" attack="29" reload="45" ammo="90" pene="3" />
                <level num="4" score="400" dmg="50" attack="30" reload="50" ammo="100" pene="3" />
            </prefix>
            <prefix id="megami" name="女神の" lv="30" wave="35" score="500" base="11111000000010">
                <level num="0" score="0" min="26" rand="52" range="60" attack="30" kb="2" pene="4" />
                <level num="1" score="100" min="27" rand="54" range="70" attack="35" kb="3" pene="5" />
                <level num="2" score="200" min="28" rand="56" range="80" attack="40" kb="4" pene="6" />
                <level num="3" score="300" min="29" rand="58" range="90" attack="45" kb="5" pene="7" />
                <level num="4" score="400" min="30" rand="60" range="100" attack="50" kb="6" pene="8" />
            </prefix>
            <prefix id="tyoudokyu" name="超弩級の" lv="30" wave="35" score="500" base="00000111000000">
                <level num="0" score="0" dmg="72" reload="30" ammo="100" crit="6" />
                <level num="1" score="100" dmg="74" reload="35" ammo="100" crit="7" />
                <level num="2" score="200" dmg="76" reload="40" ammo="100" crit="8" />
                <level num="3" score="300" dmg="78" reload="45" ammo="100" crit="9" />
                <level num="4" score="400" dmg="80" reload="50" ammo="100" crit="10" />
            </prefix>
            <prefix id="watasinosaikyou" name="わたしの最高の" lv="30" wave="35" score="500" base="00000111000000">
                <level num="0" score="0" min="36" range="20" reload="80" dex="12" />
                <level num="1" score="100" min="37" range="25" reload="85" dex="14" />
                <level num="2" score="200" min="38" range="30" reload="90" dex="16" />
                <level num="3" score="300" min="39" range="35" reload="95" dex="18" />
                <level num="4" score="400" min="40" range="40" reload="100" dex="20" />
            </prefix>
            <prefix id="syunsatu" name="瞬殺の" lv="30" wave="35" score="500" base="00000000111101">
                <level num="0" score="0" dmg="46" range="16" reload="30" kb="6" />
                <level num="1" score="100" dmg="47" range="18" reload="35" kb="7" />
                <level num="2" score="200" dmg="48" range="20" reload="40" kb="8" />
                <level num="3" score="300" dmg="49" range="22" reload="45" kb="9" />
                <level num="4" score="400" dmg="50" range="24" reload="50" kb="10" />
            </prefix>
            <prefix id="saigoninokotta" name="最後に残った" lv="30" wave="35" score="500" base="00000000111101">
                <level num="0" score="0" reload="80" vit="12" dex="12" crit="6" />
                <level num="1" score="100" reload="90" vit="14" dex="14" crit="7" />
                <level num="2" score="200" reload="100" vit="16" dex="16" crit="8" />
                <level num="3" score="300" reload="110" vit="18" dex="18" crit="9" />
                <level num="4" score="400" reload="120" vit="20" dex="20" crit="10" />
            </prefix>
            <prefix id="gainen" name="概念の" lv="30" wave="35" score="500" base="11111111111111">
                <level num="0" score="0" dmg="-200" str="17" vit="17" dex="16" luc="17" />
                <level num="1" score="100" dmg="-200" str="19" vit="19" dex="17" luc="19" />
                <level num="2" score="200" dmg="-200" str="21" vit="21" dex="18" luc="21" />
                <level num="3" score="300" dmg="-200" str="23" vit="23" dex="23" luc="23" />
                <level num="4" score="400" dmg="-200" str="25" vit="25" dex="25" luc="25" />
            </prefix>
            <prefix id="eigaka" name="映画化決定の" lv="35" wave="50" score="1500" base="11111111111111">
                <level num="4" score="0" dmg="200" range="50" attack="50" ammo="100" vit="-120" dex="120" luc="-120" kb="5" pene="5" />
            </prefix>
        </root>;
        
        public static const HOWTOPLAY_TEXTS:Array = [
            {
                title: "プレイ開始！",
                body: "魔法少女としてQBを撃退し、世界を守ってください！\n"
                    + "QBが契約ノルマを達成してしまうとゲームオーバーです！\n\n"
                    + "[はじめ方]\n"
                    + "左上のボタンの一つを押すと、すぐにゲームがはじまります！\n"
                    + "かっこ内の数字が、その世界で戦闘中の魔法少女の人数です。\n"
                    + "はじめての人は8～24人くらいの世界がオススメです。\n\n"
                    + "[操作方法]\n"
                    + "矢印キー: 移動\n"
                    + "Zキー: 武器で攻撃\n"
                    + "Xキー: 射撃武器のリロード（弾補充）\n"
                    + "Cキー: 武器の持ち替え\n\n"
                    + "[ダメージを受けて、HPが0になると？]\n"
                    + "戦闘不能になり、復帰するまで一切の行動が出来なくなります。\n\n"
                    + "[契約ノルマが0になると？]\n"
                    + "世界が破滅しますが、新しい武器が手に入ったり、キャラクターがレベルアップしたりします。\n\n"
            },
            {
                title: "ステータスについて",
                body: "ステータス画面で、キャラクターの能力を確認することができます。\n\n"
                    + "[詳細]\n"
                    + "名前: あなたのニックネームを入力してください。\n"
                    + "Lv.: レベルです。高くなると良い武器が手に入るようになります。\n"
                    + "次のLvまで: この数以上のQBを撃退するとレベルアップします。\n\n"
                    + "残りポイント: 能力に割り振ることでキャラクターが強くなります。ポイントはレベルアップで1ずつ増えます。"
                    + "割り振りをリセットしたい場合は、キャラクターの変更を行ってください。\n\n"
                    + "魔力: 与えるダメージ、ノックバックに影響します。\n"
                    + "精神: 最大HP、戦闘不能からの復帰時間に影響します。\n"
                    + "敏捷: 移動速度、リロード速度、近接武器の攻撃速度に影響します。\n"
                    + "幸運: 入手武器の質、クリティカル率に影響します。\n\n"
                    + "スキル: キャラクター固有の特殊能力です。\n\n"
            },
            {
                title: "武器について",
                body: "武器は２つ装備でき、プレイ中に自由に持ち替えることができます。状況に応じて使い分けましょう！\n\n"
                    + "[攻撃タイプ]\n"
                    + "射撃: ピストル、ローズボウなど。遠距離から攻撃する基本的な武器です。"
                    + "弾は射程外の敵にも当たりますが、その際は大きく威力が落ちます。貫通して複数の敵に当たるものがあります。\n\n"
                    + "爆発: 消火器、パイプ爆弾など。当たった敵を中心に広範囲の爆発が発生する武器です。"
                    + "強力な反面それぞれにクセがあり、使いこなすのが難しいかもしれません。\n\n"
                    + "近接: サーベル、スピアなど。他のタイプに比べて射程は短いですが、範囲が広くリロード無しで攻撃ができる武器です。"
                    + "敵に近づかなければいけないので、ダメージを受けないように注意しましょう。\n\n"
                    + "[特殊効果]\n"
                    + "クリティカル: 発生すると、与えるダメージが５倍になります。\n"
                    + "ノックバック: 当たった敵を後ろへ押し戻します。"
            },
            {
                title: "ヒント",
                body: "[難易度]\n"
                    + "難易度は参加人数には関係なく固定です。自分に合った人数の世界に参加しよう。\n\n"
                    + "[特殊な敵]\n"
                    + "敵の一部には、移動速度・攻撃力が高い速攻タイプ、移動速度は低いがHPが多い頑丈タイプが紛れ込んでいることがあります。"
                    + "他と移動速度が違う敵を見つけたら、早めに倒すようにしましょう！\n\n"
                    + "[入手武器の質]\n"
                    + "ゲームオーバー後に手に入る武器は、キャラクターのレベル、幸運、到達Wave、QB撃退数によって大きく変わります。"
                    + "特に到達Waveは重要なので、仲間と協力して高いWaveを目指しレア武器をゲットしよう！\n\n"
            }
        ];
        
        public static const FAQ_TEXTS:Array = [
            {
                title: "基本的な質問",
                body: "[プレイ途中で退出するには？]\n"
                    + "ブラウザを最小化するか他のタブを開くと、自動的に離脱します。"
                    + "ただしその場合、経験値は入りますが武器は入手できません。\n\n"
                    + "[いつ終わるの？いつまで続くの？]\n"
                    + "Waveが進行する度に、敵はより強くなっていきます。"
                    + "とりあえず続けてみて下さい。1プレイの想定時間は15～30分程度です。\n\n"
                    + "[すぐゲームから離脱するんだけど？]\n"
                    + "一定以上処理が遅れると、他のプレイヤーに悪影響が及ぶ前に自動的に離脱するようになっています。"
                    + "PCや回線の性能が低い人は、オプションでエフェクトを切って負荷を下げてください。"
                    + "それでも駄目な場合はもっと少人数の世界で遊びましょう。\n\n"
                    + "[セーブデータが消えるんだけど？]\n"
                    + "ブラウザのcookie削除などを行うと、セーブデータも一緒に消えてしまいます。"
                    + "ブラウザの履歴の自動削除などを設定している人は、"
                    + "セーブデータもまとめて削除されてしまわないよう十分に注意して下さい。"
            },
            {
                title: "基本的な質問",
                body: "[右上の数字は何？]\n"
                    + "FPS : PINGです。FPSは30が正常で、下がるほど処理落ちが発生します。"
                    + "PINGは300以下が正常で、上がるほどラグが発生します。"
                    + "どちらも一定以上悪くなると、自動的に離脱するようになっていますので、十分に注意して下さい。\n\n"
                    + "[チャット荒らしはどうすればいいの？]\n"
                    + "チャット欄に表示されている発言の一つをクリックして選択した後、チャット欄右下の[+]ボタンを押すと"
                    + "その発言したプレイヤーの発言を全て削除し非表示にすることができます。"
                    + "無視を取り消したい場合には、[-]ボタンを押してください。\n\n"
                    + "[チャットの発言の頭に付く()の数字は？]\n"
                    + "騙り防止用のプレイヤーのIDです。\n\n"
                    + "[チャット欄が邪魔・狭い]\n"
                    + "人数が表示されているバーをドラッグすると、チャット欄を移動できます。"
                    + "また、右下の三角部分をドラッグすると、チャット欄のサイズを変更できます。"
                    + "自分の好きな場所・大きさで利用してください。\n\n"
            },
            {
                title: "基本的な質問",
                body: "[プレイ中の名前の後ろに付く@は何？]\n"
                    + "あなたが現在参加している世界の番号です。\n\n"
                    + "[画面下が切れて見えない]\n"
                    + "フルスクリーンでプレイしている場合は下にスクロールして下さい。"
                    + "もしくは、右上の[X]を押して全体が表示されるようにして下さい。"
                    + "また、フルスクリーンは負荷が大きくなるので、\"この作品のコードを見る\"を押して、"
                    + "普通のサイズでプレイするのもオススメです。\n\n"
                    + "[どの世界に参加するのがいいの？]\n"
                    + "大人数の世界は、お祭り騒ぎ好きな人と高難易度へのチャレンジに適しています。"
                    + "少人数の世界は、本格的な協力プレイを求める人に適しています。"
                    + "初心者は8～24人程度の世界がオススメです。\n\n"
                    + "[何故かダメージを受けているプレイヤーがいる！？]\n"
                    + "PCや回線が不安定な人のラグです。\n\n"
            },
            {
                title: "マナーとモラル",
                body: "[チャットでの発言について]\n"
                    + "基本的にチャットでは自由に好きな話をしても構いません。"
                    + "ただし、様々な人達がチャットを見ているということは常に意識して、"
                    + "過度の下ネタや内輪ネタ等は自重するよう心がけて下さい。\n\n"
                    + "[放置行為について]\n"
                    + "世界に参加したまま離席するのは、その世界の他プレイヤーの迷惑になりますし、"
                    + "ちゃんと遊びたい人が参加出来なくなることもあるのでやめて下さい。\n\n"
                    + "[海外のプレイヤーに関して]\n"
                    + "このゲームのメインターゲットは日本人プレイヤーですが、海外のプレイヤーも歓迎しています。"
                    + "国や言語などにとらわれず、全員で協力して楽しくプレイして下さい。"
                    + "今後海外のIPを遮断するようなことは絶対にありません。\n\n"
            },
            {
                title: "ゲームのシステムに関する質問",
                body: "[威力が低い、敵が倒せない]\n"
                    + "射撃武器には射程が設定されています。射程外の敵にも弾は当たりますが、その際には大きく威力が落ちてしまいます。"
                    + "武器の火力を最大限に生かすために、射撃武器でも積極的に前に出て攻撃しましょう。\n"
                    + "ちなみにマップの全長（左端から右端まで）は465です。\n\n"
                    + "[どのキャラ（武器）が強いの？]\n"
                    + "全てのキャラには、得意な部分と苦手な部分があり、どれが最強というものはありません。"
                    + "自分の好きなキャラ、自分のプレイスタイルに合ったキャラを選んで下さい。武器も同様です。\n\n"
                    + "[サブ武器の補正はメイン武器に影響するの？]\n"
                    + "影響するのはステータス補正のみです。\n\n"
                    + "[キャラのスキル補正はどう計算されるの？]\n"
                    + "一番最後に乗算されます。よってかなり強力に影響します。\n"
            },
            {
                title: "要望について",
                body: "[プレイ中に撃退数を表示して欲しい]\n"
                    + "個人の記録より仲間との協力を意識しましょう。\n\n"
                    + "[他の種類の敵やボスが欲しい]\n"
                    + "正直種類が増えてもあまり変わらないと思いますよ。\n\n"
                    + "[キャラ毎に得意武器が欲しい]\n"
                    + "キャラのビルドが制限されるのでやりません。\n\n"
                    + "[HPを回復する要素が欲しい]\n"
                    + "戦闘不能になったら終わりというゲームではありません。\n\n"
                    + "[BGMは無いの？]\n"
                    + "あなたの好きな音楽を鳴らしてプレイして下さい。\n\n"
                    + "[プレイ中にオプション変更機能・離脱ボタンが欲しい]\n"
                    + "プレイ中にごちゃごちゃした機能をつけたくないのでやりません。\n\n"
                    + "[レベル上限・所持品欄を増やして欲しい]\n"
                    + "絶対にやりません。\n\n"
            },
            {
                title: "要望について",
                body: "[プレイ中に表情やエモーションを出せるようにして欲しい]\n"
                    + "面白いアイデアですが負荷が増えるので難しいです。\n\n"
                    + "[ゲームの進行が遅くて退屈、もっと早くして欲しい]\n"
                    + "緊張感のあるプレイが楽しめる少人数世界がオススメです。\n\n"
                    + "[ゲームバランスが悪い]\n"
                    + "現在、武器の性能は意図的にインフレさせた値になっています。\n"
                    + "根本的なバランス改善の声が大きくなった場合には、全武器の大幅な下方修正で調整を行う予定です。今のところはありません。\n\n"
                    + "[プレイヤーの意見を聞く気が無いのか？]\n"
                    + "自分が面白いと思ったら、修正がどんなに大変なものでもやります。そうでないならやりません。"
                    + "どうしてもという方は自身でforkして実装して下さい。元々そういうサイトの投稿作品ですので。\n\n"
                    + "[次はいつ更新するんですか？]\n"
                    + "未定です。\n\n"
            }
        ];
        
        public static const INFO_MESSAGE:String = "チャット荒らしの発言をクリックで選択して[+]ボタンを押すと非表示にできるよ！";
        public static const HISTORY_TEXTS:Array = [
            {
                title: "更新履歴",
                body: ""
                    + "2012/02/12 まど神様の無敵化の範囲を広くしました\n"
                    + "2012/02/10 崩壊直後の世界の人数を正しく表示するようにしました\n"
                    + "2012/02/10 よくある質問を加筆しました\n"
                    + "2012/02/09 黒さやかのスキルを変更しました\n"
                    + "2012/02/09 次のLvまでの値がアンダーフローしないようにしました\n"
                    + "2012/02/09 あそび方・よくある質問を整理しました\n"
                    + "2012/02/04 ティロフィナーレの性能を多段ヒットタイプにしました\n"
                    + "2012/02/03 復帰時の無敵時間を3秒から5秒に変更しました\n"
                    + "2012/02/03 無敵中のプレイヤーが点滅するようになりました\n"
                    + "2012/02/03 まど神様のスキルを変更しました\n"
                    + "2012/02/03 メガほむの近接の攻撃速度を正しく修正しました\n"
                    + "2012/02/03 腹パンの毒ガスにエフェクトを追加しました\n"
                    + "2012/02/03 毒ガスをQBの現在HP依存ダメージに変更しました\n"
                    + "2012/02/03 武器に「ティロフィナーレ」を追加しました\n"
                    + "2012/02/03 武器に「パンチ」を追加しました\n"
                    + "2012/01/13 接続が切れた際チャット欄がバグる問題を修正しました\n"
                    + "2012/01/13 オプションにStats表示ON/OFFを追加しました\n"
                    + "2012/01/12 世界の初期化が失敗するバグを修正しました\n"
                    + "2012/01/12 Wave330から開始することがあるバグを修正しました\n"
                    + "2012/01/08 よくある質問のチャット部分を更新しました\n"
            },
            {
                title: "更新履歴",
                body: ""
                    + "2012/01/08 チャット欄のサイズを変更できるようにしました\n"
                    + "2012/01/04 よくある質問のチャット部分を更新しました\n"
                    + "2012/01/04 チャット欄に様々な機能を追加しました\n"
                    + "2011/12/30 よくある質問を加筆しました\n"
                    + "2011/12/22 リロード速度が攻撃速度を上回らないようにしました\n"
                    + "2011/12/18 チャット欄をドラッグできるようにしました\n"
                    + "2011/12/18 よくある質問を加筆しました\n"
                    + "2011/12/17 名前に | が含まれるとバグる問題を修正しました\n"
                    + "2011/12/16 QBの速度がオーバーフローするバグを修正しました\n"
                    + "2011/12/15 Wave61以降の難易度を調整しました\n"
                    + "2011/12/14 ステータス画面に補正前の値を表示するようにしました\n"
                    + "2011/12/13 オプションにQB撃退エフェクトON/OFFを追加しました\n"
                    + "2011/12/13 他プレイヤーの回復速度が確認できるようになりました\n"
                    + "2011/12/12 あそび方・よくある質問を加筆しました\n"
                    + "2011/12/12 更新履歴を追加しました\n"
                    + "2011/11/03 公開\n"
            }
        ];
    }
//}