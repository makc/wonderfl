package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    import net.user1.logger.Logger;
    import net.user1.reactor.Reactor;
    import net.wonderfl.utils.WonderflAPI;
/*    import ore.orelib.assets.Artist;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.Input;
    import ore.orelib.commons.Preloader;
    import ore.orelib.commons.TileSheet;
    import ore.orelib.commons.UnionStats;
    import ore.orelib.data.Const;
    import ore.orelib.scenes.IScene;
    import ore.orelib.scenes.TitleScene;
*/    
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "0x000000")]
    public class Main extends Sprite {
        private var _reactor:Reactor;
        private var _synchronizer:Timer;
        private var _api:WonderflAPI;
        private var _scene:IScene;
        private var _timestamp:Number;
        
        public function Main() {
            // Reactorの初期設定
            _reactor = new Reactor();
            _reactor.getConnectionMonitor().setHeartbeatFrequency(1000);
            _reactor.getConnectionMonitor().setConnectionTimeout(5000);
            _reactor.getConnectionMonitor().setAutoReconnectFrequency(5000);
            _reactor.getLog().setLevel(Logger.FATAL);
            //_reactor.getLog().setLevel(Logger.DEBUG);
            
            var stats:UnionStats = new UnionStats(_reactor);
            stats.y = 465 - stats.height;
            stats.alpha = 0.8;
            stage.addChild(stats);
            
            // Reactor接続、各アセット読み込み
            var preloader:Preloader = new Preloader(this);
            preloader.addReactorConnectionRequest(_reactor);
            preloader.addLoaderRequest(Const.IMAGE_URL);
            preloader.addFontLoaderRequest(Const.FONT);
            preloader.addEventListener(Event.COMPLETE, initialize);
            preloader.load();
        }
        
        private function initialize(event:Event):void {
            var preloader:Preloader = event.currentTarget as Preloader;
            preloader.removeEventListener(event.type, arguments.callee);
            
            // 画像アセットの登録
            var sheet:TileSheet = new TileSheet(preloader.loaders[Const.IMAGE_URL]);
            Assets.images["characters"] = sheet.blit(new Rectangle(0, 0, 16, 16), 3, 6);
            Assets.images["weapons"] = sheet.blit(new Rectangle(48, 0, 32, 24), 3, 4);
            Assets.images["background"] = Artist.createBackground();
            Assets.images["actorShadow"] = Artist.createActorShadow();
            Assets.images["muzzleFlashes"] = Artist.createMuzzleFlashes(10);
            Assets.images["bloods"] = Artist.createBloods(10);
            
            // 静的クラスの初期化
            Input.setup(stage);
            GeomPool.setup(5);
            
            // サーバーとの同期
            synchronize();
            _synchronizer = new Timer(30000, 0);
            _synchronizer.addEventListener(TimerEvent.TIMER, synchronize);
            _synchronizer.start();
            
            _api = new WonderflAPI(root.loaderInfo.parameters);
            _scene = new TitleScene(this);
            _timestamp = _reactor.getServer().getServerTime();
            
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function synchronize(event:TimerEvent = null):void {
            if (_reactor.isReady()) { _reactor.getServer().syncTime(); }
        }
        
        private function update(event:Event):void {
            var serverTime:Number = _reactor.getServer().getServerTime();
            
            _scene.update(serverTime, Math.max(0, serverTime - _timestamp));
            _timestamp = serverTime;
            
            Input.record();
        }
        
        public function changeScene(scene:IScene):void { _scene = scene; }
        public function get reactor():Reactor { return _reactor; }
        public function get api():WonderflAPI { return _api; }
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
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import net.user1.reactor.ReactorEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.RoomManagerEvent;
    import net.user1.reactor.UpdateLevels;
/*    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
*/    
    //public 
    class TitleScene extends Sprite implements IScene {
        private var _main:Main;
        private var _nameInput:TextField;
        private var _buttons:Vector.<PushButton>;
        
        private static const NUM_ROOMS:int = 1;
        
        public function TitleScene(main:Main) {
            _main = main;
            _main.addChild(this);
            
            addChild(
                new TextBuilder().align(TextBuilder.CENTER).autoSize()
                .font(Const.FONT, 0, 400).fontColor(0xFFFFFF).fontSize(50)
                .pos(0, 100).size(465, 132).build("全ほ連")
            );
            
            addChild(_nameInput = createNameInput());
            
            _buttons = new Vector.<PushButton>(NUM_ROOMS, true);
            for (var i:int = 0; i < NUM_ROOMS; i++) {
                _buttons[i] = new PushButton(this, 182, 310 + 30 * i, "join (0)", startPlaying);
            }
            
            _main.reactor.addEventListener(ReactorEvent.READY, enableToJoin);
            _main.reactor.addEventListener(ReactorEvent.CLOSE, disableToJoin);
            (_main.reactor.isReady()) ? enableToJoin() : disableToJoin();
        }
        
        private function createNameInput():TextField {
            var result:TextField = new TextField();
            result.x = 142; result.y = 270;
            result.width = 180; result.height = 20;
            result.defaultTextFormat = new TextFormat("_sans", 14, 0x000000, null, null, null, null, null, TextFormatAlign.CENTER);
            result.background = true; result.backgroundColor = 0xFFFFFF;
            result.filters = [new BevelFilter(1, 225, 0xC0C0C0, 1, 0x404040, 1, 1, 1)];
            result.maxChars = 12;
            result.selectable = true;
            result.type = TextFieldType.INPUT;
            result.text = SaveData.instance.player.name || "魔法少女" + _main.reactor.self().getClientID() + "番";
            return result;
        }
        
        private function startPlaying(event:MouseEvent):void {
            SaveData.instance.player.name = _nameInput.text || "魔法少女" + _main.reactor.self().getClientID() + "番";
            
            // 各リスナの削除
            _main.reactor.removeEventListener(ReactorEvent.READY, enableToJoin);
            _main.reactor.removeEventListener(ReactorEvent.CLOSE, disableToJoin);
            _main.reactor.getRoomManager().stopWatchingForRooms(String(_main.api.appID) + ".game");
            _main.reactor.getRoomManager().removeEventListener(RoomManagerEvent.ROOM_ADDED, roomAddedHandler);
            for (var i:int = 0; i < NUM_ROOMS; i++) {
                var room:Room = _main.reactor.getRoomManager().getRoom(String(_main.api.appID) + ".game." + i);
                if (room) { room.removeEventListener(RoomEvent.OCCUPANT_COUNT, roomClientCountHandler); }
            }
            
            _main.removeChild(this);
            _main.changeScene(new PlayingScene(_main, _buttons.indexOf(event.currentTarget as PushButton)));
        }
        
        /** サーバーと正常に接続されている場合に、ゲーム参加を可能する */
        private function enableToJoin(event:ReactorEvent = null):void {
            _main.reactor.getRoomManager().watchForRooms(String(_main.api.appID) + ".game");
            _main.reactor.getRoomManager().addEventListener(RoomManagerEvent.ROOM_ADDED, roomAddedHandler);
            
            for (var i:int = 0; i < NUM_ROOMS; i++) {
                _buttons[i].enabled = true;
                _buttons[i].label = "join (0)";
            }
        }
        
        /** 新しい部屋が作成されたら監視する */
        private function roomAddedHandler(event:RoomManagerEvent):void {
            var room:Room = event.getRoom();
            var roomID:int = int(room.getSimpleRoomID());
            if (roomID >= NUM_ROOMS) { return; }
            
            // 部屋の参加人数のみを監視する
            var updateLevels:UpdateLevels = new UpdateLevels();
            updateLevels.clearAll();
            updateLevels.occupantCount = true;
            room.addEventListener(RoomEvent.OCCUPANT_COUNT, roomClientCountHandler, false, 0, true);
            room.observe(String(_main.api.apiKey), updateLevels);
        }
        
        /** 参加者人数が変わったら更新する */
        private function roomClientCountHandler(event:RoomEvent):void {
            for (var i:int = 0; i < NUM_ROOMS; i++) {
                var room:Room = _main.reactor.getRoomManager().getRoom(String(_main.api.appID) + ".game." + i);
                var numClients:int = (room) ? room.getNumOccupants() : 0;
                _buttons[i].label = "join (" + numClients + ")";
            }
        }
        
        /** サーバーとの接続が切れた場合に、ゲーム参加不能にする */
        private function disableToJoin(event:ReactorEvent = null):void {
            for (var i:int = 0; i < NUM_ROOMS; i++) {
                _buttons[i].enabled = false;
                _buttons[i].label = "connecting...";
            }
        }
        
        public function update(serverTime:Number, elapsedTime:int):void { }
    }
//}
//package ore.orelib.scenes {
    import com.bit101.components.PushButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomSettings;
    import net.user1.reactor.UpdateLevels;
/*    import ore.orelib.actors.EffectManager;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.actors.FriendManager;
    import ore.orelib.assets.PlayingView;
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
        
        private var _isPlaying:Boolean;
        
        public function PlayingScene(main:Main, roomNo:int) {
            _main = main;
            _main.addChild(this);
            
            var roomSettings:RoomSettings = new RoomSettings();
            roomSettings.password = String(_main.api.apiKey);
            _room = _main.reactor.getRoomManager().createRoom(String(_main.api.appID) + ".game." + roomNo, roomSettings);
            
            addChild(_view = new PlayingView());
            _friends = new FriendManager(_room);
            _enemies = new EnemyManager(_room);
            _effects = new EffectManager(_view);
            
            _player = new Player(_room, _main.reactor.self());
            _host = new Host(_room, _main.reactor);
            
            _view.setupHUD(_player);
            addChild(_view.createChatWindow(String(_main.api.appID) + ".chat." + roomNo, _main.reactor));
            
            stage.focus = null;
            _room.join(String(_main.api.apiKey), new UpdateLevels());
            _room.stopObserving();
            _isPlaying = true;
        }
        
        public function update(serverTime:Number, elapsedTime:int):void {
            if (!_isPlaying) { return; }
            
            _player.update(elapsedTime, _enemies, (stage.focus == null));
            _host.update(serverTime, elapsedTime);
            _friends.update(elapsedTime);
            _enemies.update(serverTime, elapsedTime, _host.isHost);
            _effects.update();
            
            _view.update(_player, _host);
            
            // 接続が切れるか、QBの契約ノルマが達成されたらゲームオーバー
            if (!_main.reactor.isReady() || _host.numContracts >= Const.FIELD_QB_QUOTA) { onGameover(); }
        }
        
        private function onGameover():void {
            _isPlaying = false;
            _room.leave();
            
            _player.removeEventListeners();
            _host.removeEventListeners();
            _view.removeEventListeners();
            _friends.removeEventListeners();
            _enemies.removeEventListeners();
            _effects.removeEventListeners();
            
            _view.setupGameoverDisplay(new PushButton(null, 182, 300, "leave", leaveWorld), _main.reactor.isReady());
        }
        
        private function leaveWorld(event:MouseEvent):void {
            _main.removeChild(this);
            _main.changeScene(new TitleScene(_main));
        }
    }
//}
//package ore.orelib.logic {
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    import net.user1.reactor.Attribute;
    import net.user1.reactor.AttributeEvent;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Room;
/*    import ore.orelib.actors.Enemy;
    import ore.orelib.actors.EnemyManager;
    import ore.orelib.actors.Friend;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.Input;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerData;
    import ore.orelib.data.PlayerStatus;
    import ore.orelib.data.SaveData;
    import ore.orelib.data.WeaponSmith;
    import ore.orelib.events.ActorEvent;
    import ore.orelib.events.EffectEvent;
*/    
    //public 
    class Player {
        private var _room:Room;
        private var _self:IClient;
        // プレイヤーのステータス・装備
        private var _status:PlayerStatus;
        private var _equip:PlayerEquipment;
        private var _hp:int;
        private var _invincibleCount:int;
        private var _recoverCount:int;
        private var _recoverTime:int;
        // プレイヤーのビュー
        private var _view:Friend;
        private var _playerBounds:Rectangle;
        private var _posSendCount:int;
        // 撃退数
        private var _killCount:int;
        
        public static const BOUNDS_HALF_WIDTH:int = 10;
        public static const BOUNDS_HEIGHT:int = 28;
        
        public function Player(room:Room, self:IClient) {
            _room = room;
            _self = self;
            
            var playerData:PlayerData = SaveData.instance.player;
            var primary:Weapon = WeaponSmith.createWeaponFromData(SaveData.instance.inventory[playerData.primaryWeaponIndex]);
            var secondary:Weapon = WeaponSmith.createWeaponFromData(SaveData.instance.inventory[playerData.secondaryWeaponIndex]);
            
            _status = new PlayerStatus(
                Math.min(Math.max(10, playerData.status.str + primary.strBonus + secondary.strBonus), 200),
                Math.min(Math.max(10, playerData.status.vit + primary.vitBonus + secondary.vitBonus), 200),
                Math.min(Math.max(10, playerData.status.dex + primary.dexBonus + secondary.dexBonus), 200),
                Math.min(Math.max(10, playerData.status.luc + primary.lucBonus + secondary.lucBonus), 200)
            );
            _equip = new PlayerEquipment(primary, secondary);
            _hp = _status.vit;
            _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
            _recoverCount = 0;
            _recoverTime = Const.PLAYER_RECOVER_TIME * _status.vit / 100;
            
            _view = new Friend(
                playerData.name,
                Const.FIELD_SIZE,
                Const.FIELD_SIZE * Math.random(),
                Const.PLAYER_SPEED * _status.dex / 100,
                _hp,
                _status.vit,
                playerData.characterID,
                primary.id
            );
            _self.setAttribute(Friend.ATTR_NAME, playerData.name);
            _self.setAttribute(Friend.ATTR_X, _view.x.toFixed(0));
            _self.setAttribute(Friend.ATTR_Y, _view.y.toFixed(0));
            _self.setAttribute(Friend.ATTR_SPEED, _view.speed.toFixed(0));
            _self.setAttribute(Friend.ATTR_HP, _hp.toString());
            _self.setAttribute(Friend.ATTR_MAXHP, _status.vit.toString());
            _self.setAttribute(Friend.ATTR_CHARACTER, playerData.characterID.toString());
            _self.setAttribute(Friend.ATTR_WEAPON, primary.id.toString());
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, _view, _view.overlay));
            _playerBounds = new Rectangle(
                _view.x - Player.BOUNDS_HALF_WIDTH,
                _view.y - Player.BOUNDS_HEIGHT,
                Player.BOUNDS_HALF_WIDTH * 2,
                Player.BOUNDS_HEIGHT
            );
            _posSendCount = Const.PLAYER_POS_SEND_INTERVAL;
            
            _killCount = 0;
            _room.addEventListener(AttributeEvent.UPDATE, onKillEnemy);
        }
        
        private function onKillEnemy(event:AttributeEvent):void {
            var attr:Attribute = event.getChangedAttr();
            var idAndName:Array = attr.name.split(".");
            if (idAndName[1] != Enemy.ATTR_HP) { return; }
            
            if (int(attr.value) <= 0) {
                _room.deleteAttribute(idAndName[0] + "." + Enemy.ATTR_STATUS);
                _room.deleteAttribute(idAndName[0] + "." + Enemy.ATTR_HP);
                _room.deleteAttribute(idAndName[0] + "." + Enemy.ATTR_SPAWN_X);
                
                if (int(attr.oldValue) > 0) {
                    _killCount++;
                }
            }
        }
        
        private function changeHp(value:int):void {
            if (value <= 0) {
                _invincibleCount = _recoverTime;
                _recoverCount = _recoverTime;
            } else if (value < _hp) {
                _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_DAMAGED;
            }
            
            _hp = Math.max(0, value);
            _view.changeHp(_hp);
            _self.setAttribute(Friend.ATTR_HP, _hp.toString());
        }
        
        public function update(elapsedTime:int, enemies:EnemyManager, isControllable:Boolean):void {
            _equip.update(elapsedTime);
            
            if (_invincibleCount > 0) { _invincibleCount -= elapsedTime; }
            if (_recoverCount > 0) {
                _recoverCount -= elapsedTime;
                if (_recoverCount <= 0) {
                    changeHp(_status.vit);
                    _invincibleCount = Const.PLAYER_INVINCIBLE_TIME_ON_RECOVER;
                }
            }
            
            if (isControllable) { processInput(elapsedTime, enemies); }
            
            _view.update(elapsedTime);
            _posSendCount -= elapsedTime;
            if (_posSendCount < 0) {
                _posSendCount += Const.PLAYER_POS_SEND_INTERVAL;
                _self.setAttribute(Friend.ATTR_X, _view.x.toFixed(0));
                _self.setAttribute(Friend.ATTR_Y, _view.y.toFixed(0));
            }
            
            if (_invincibleCount <= 0) {
                var collidingEnemies:Vector.<Enemy> = enemies.acquireCollidingEnemies(_playerBounds);
                if (collidingEnemies.length > 0) {
                    changeHp(_hp - collidingEnemies[0].str);
                }
            }
        }
        
        private function processInput(elapsedTime:int, enemies:EnemyManager):void {
            if (_recoverCount > 0) { return; }
            move(elapsedTime);
            if (_equip.isSwapping()) { return; }
            if (Input.key.isPressed(Input.C)) {
                _equip.swap();
                _view.swapWeapon(_equip.currentWeapon.id);
                _self.setAttribute(Friend.ATTR_WEAPON, _equip.currentWeapon.id.toString());
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
                    var range:int = _equip.attack(_room, _view.x, _view.y, _status, enemies);
                    _view.attack(_equip.currentWeapon.id, range);
                    _room.sendMessage(Friend.MESSAGE_ATTACK, false, null, _equip.currentWeapon.id.toString(), range.toString());
                    EventManager.instance.dispatchEvent(new EffectEvent(
                        EffectEvent.ATTACK_WEAPON,
                        _view.x, _view.y,
                        { id: _equip.currentWeapon.id, range: range }
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
                    Math.min(Math.max(0, _view.y + velocity.y), Const.FIELD_SIZE)
                );
                _playerBounds.x = _view.x - Player.BOUNDS_HALF_WIDTH;
                _playerBounds.y = _view.y - Player.BOUNDS_HEIGHT;
            }
        }
        
        public function removeEventListeners():void {
            _room.removeEventListener(AttributeEvent.UPDATE, onKillEnemy);
        }
        
        public function get characterID():int { return int(_self.getAttribute(Friend.ATTR_CHARACTER)); }
        public function get hp():int { return _hp; }
        public function get maxHp():int { return _status.vit; }
        public function get hpRate():Number { return _hp / _status.vit; }
        public function get ammo():int { return _equip.currentWeaponAmmo; }
        public function get maxAmmo():int { return _equip.currentWeapon.maxAmmo; }
        public function get hpGaugeRate():Number {
            return (_recoverCount > 0) ? 1 - (_recoverCount / _recoverTime) : _hp / _status.vit;
        }
        public function get ammoGaugeRate():Number { return _equip.ammoGaugeRate; }
    }
//}
//package ore.orelib.logic {
    import net.user1.reactor.Room;
/*    import ore.orelib.actors.EnemyManager;
    import ore.orelib.actors.Friend;
    import ore.orelib.data.Const;
    import ore.orelib.data.PlayerStatus;
*/    
    //public 
    class PlayerEquipment {
        private var _currentWeapon:Weapon;
        private var _currentWeaponAmmo:int;
        private var _theOtherWeapon:Weapon;
        private var _theOtherWeaponAmmo:int;
        
        private var _attackCount:int;
        private var _reloadCount:int;
        private var _swapCount:int;
        
        private var _reloadTime:int;
        
        public function PlayerEquipment(primary:Weapon, secondary:Weapon) {
            _currentWeapon = primary;
            _currentWeaponAmmo = primary.maxAmmo;
            _theOtherWeapon = secondary;
            _theOtherWeaponAmmo = secondary.maxAmmo;
            
            _attackCount = _reloadCount = _swapCount = 0;
            _reloadTime = 1;
        }
        
        public function update(elapsedTime:int):void {
            if (_attackCount > 0) {
                _attackCount -= elapsedTime;
            }
            
            if (_reloadCount > 0) {
                _reloadCount -= elapsedTime;
                if (_reloadCount <= 0) { _currentWeaponAmmo = _currentWeapon.maxAmmo; }
            }
            
            if (_swapCount > 0) {
                _swapCount -= elapsedTime;
            }
        }
        
        public function attack(room:Room, x:int, y:int, status:PlayerStatus, enemies:EnemyManager):int {
            // if(isAmmoEmpty()) reload()
            // if(canAttack() && !isReloading() && !isSwapping())
            var range:int = _currentWeapon.attack(room, x, y, status, enemies);
            _currentWeaponAmmo--;
            _attackCount = _currentWeapon.attackRate;
            return range;
        }
        
        public function reload(status:PlayerStatus):void {
            // if(!isAmmoFull() && !isReloading() && !isSwapping())
            _attackCount = 0;
            _reloadCount = _reloadTime = _currentWeapon.reloadRate * 100 / status.dex;
        }
        
        
        public function swap():void {
            // if(!isSwapping())
            var tempWeapon:Weapon = _currentWeapon;
            var tempWeaponAmmo:int = _currentWeaponAmmo;
            _currentWeapon = _theOtherWeapon;
            _currentWeaponAmmo = _theOtherWeaponAmmo;
            _theOtherWeapon = tempWeapon;
            _theOtherWeaponAmmo = tempWeaponAmmo;
            
            _attackCount = _reloadCount = 0;
            _swapCount = Const.PLAYER_SWAP_TIME;
        }
        
        public function isAmmoEmpty():Boolean { return _currentWeaponAmmo <= 0; }
        public function isAmmoFull():Boolean { return _currentWeaponAmmo == _currentWeapon.maxAmmo; }
        public function canAttack():Boolean { return _attackCount <= 0; }
        public function isReloading():Boolean { return _reloadCount > 0; }
        public function isSwapping():Boolean { return _swapCount > 0; }
        
        public function get currentWeapon():Weapon { return _currentWeapon; }
        public function get currentWeaponAmmo():int { return _currentWeaponAmmo; }
        public function get ammoGaugeRate():Number {
            return (_reloadCount > 0) ? 1 - (_reloadCount / _reloadTime) : _currentWeaponAmmo / _currentWeapon.maxAmmo;
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
    import ore.orelib.data.WeaponSmith;
*/    
    //public 
    class Weapon {
        private var _id:int;
        private var _name:String;
        private var _buffs:String;
        
        private var _minDamage:int;
        private var _randDamage:int;
        private var _attackRate:int;
        private var _reloadRate:int;
        private var _ammo:int;
        private var _criticalRate:int;
        private var _knockback:int;
        private var _bonus:PlayerStatus;
        
        private var _range:int;
        private var _penetration:int;
        
        public function Weapon(
            id:int, name:String, buffs:String,
            minDamage:int, randDamage:int,
            attackRate:int, reloadRate:int, ammo:int,
            criticalRate:int, knockback:int, bonus:PlayerStatus,
            range:int, penetration:int
        ) {
            _id = id;
            _name = name;
            _buffs = buffs;
            _minDamage = minDamage;
            _randDamage = randDamage;
            _attackRate = attackRate;
            _reloadRate = reloadRate;
            _ammo = ammo;
            _criticalRate = criticalRate;
            _knockback = knockback;
            _bonus = bonus;
            _range = range;
            _penetration = penetration;
        }
        
        public function attack(room:Room, x:int, y:int, status:PlayerStatus, enemies:EnemyManager):int {
            var attackType:int = WeaponSmith.acquireAttackTypeOf(_id);
            var bounds:Rectangle;
            var collidingEnemies:Vector.<Enemy>;
            var i:int, enemy:Enemy, collidingEnemiesLength:int;
            var range:int = 0;
            
            switch(attackType) {
                case Const.ATTACKTYPE_SHOOTING:
                {
                    bounds = new Rectangle(x - 508, y - 16, 500, 1);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    range = 500;
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        enemy = collidingEnemies[i];
                        // 敵との距離に応じてダメージを減衰させる
                        var distX:int = x - 8 - collidingEnemies[i].x;
                        var distMultiplier:Number = (distX < _range) ? 1
                            : (distX < _range * 2) ? 1 - 0.9 * (distX - _range) / _range
                            : 0.1;
                        collidingEnemies[i].damaged(room, calculateDamage(status, distMultiplier), _knockback);
                        // 貫通しなかったら終了
                        if (i >= _penetration) { range = distX; break; }
                    }
                    break;
                }
                
                case Const.ATTACKTYPE_EXPLOSIVE:
                {
                    bounds = new Rectangle(x - 508, y - 16, 500, 1);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    range = 500;
                    if (collidingEnemies.length == 0) { break; }
                    //　一番先頭の敵の頭を爆心地にする
                    enemy = collidingEnemies[0];
                    var halfRange:Number = _range / 2;
                    bounds = new Rectangle(enemy.x + 16 - halfRange, y - 16 - halfRange, _range, _range);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    range = (x - 8) - (enemy.x + 16);
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        collidingEnemies[i].damaged(room, calculateDamage(status), _knockback);
                    }
                    break;
                }
                
                case Const.ATTACKTYPE_MELEE:
                {
                    bounds = new Rectangle(x - 8 - _range, y - 40, _range, 40);
                    collidingEnemies = enemies.acquireCollidingEnemies(bounds);
                    collidingEnemiesLength = collidingEnemies.length;
                    range = _range;
                    for (i = 0; i < collidingEnemiesLength; i++) {
                        collidingEnemies[i].damaged(room, calculateDamage(status), _knockback);
                    }
                    break;
                }
                
                default: { break; }
            }
            
            return range;
        }
        
        private function calculateDamage(status:PlayerStatus, distMultiplier:Number = 1):int {
            var baseDamage:int = _minDamage + int(_randDamage * distMultiplier * Math.random());
            var crits:Boolean = (int(100 * Math.random()) < _criticalRate * (status.luc / 100));
            return baseDamage * (status.str / 100) * ((crits) ? 10 : 1);
        }
        
        public function get id():int { return _id; }
        public function get name():String { return _name; }
        public function get buffs():String { return _buffs; }
        public function get minDamage():int { return _minDamage; }
        public function get randDamage():int { return _randDamage; }
        public function get maxDamage():int { return _minDamage + _randDamage; }
        public function get attackRate():int { return _attackRate; }
        public function get reloadRate():int { return _reloadRate; }
        public function get maxAmmo():int { return _ammo; }
        public function get criticalRate():int { return _criticalRate; }
        public function get knockback():int { return _knockback; }
        public function get strBonus():int { return _bonus.str; }
        public function get vitBonus():int { return _bonus.vit; }
        public function get dexBonus():int { return _bonus.dex; }
        public function get lucBonus():int { return _bonus.luc; }
        public function get range():int { return _range; }
        public function get penetration():int { return _penetration; }
    }
//}
//package ore.orelib.logic {
    import net.user1.reactor.Attribute;
    import net.user1.reactor.AttributeEvent;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.RoomManagerEvent;
    import net.user1.reactor.Status;
/*    import ore.orelib.actors.Enemy;
    import ore.orelib.data.Const;
*/    
    //public 
    class Host {
        private var _room:Room;
        private var _reactor:Reactor;
        private var _startTime:Number;
        private var _playTime:int;
        private var _spawnTimeCount:int;
        private var _spawnUniqueCount:int;
        
        public static const ATTR_HOST:String = "h";
        public static const ATTR_HOST_CANDIDACY:String = "i";
        public static const ATTR_START_TIME:String = "t";
        public static const ATTR_NUM_CONTRACTS:String = "c";
        
        public function Host(room:Room, reactor:Reactor) {
            _room = room;
            _reactor = reactor;
            _startTime = _playTime = 0;
            _spawnTimeCount = _spawnUniqueCount = 0;
            
            _reactor.getRoomManager().addEventListener(RoomManagerEvent.CREATE_ROOM_RESULT, initialize);
            _room.addEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.addEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
            _room.addEventListener(AttributeEvent.DELETE, attributeDeleteHandler);
        }
        
        private function initialize(event:RoomManagerEvent):void {
            if (event.getRoomID() != _room.getRoomID()) { return; }
            _reactor.getRoomManager().removeEventListener(RoomManagerEvent.CREATE_ROOM_RESULT, initialize);
            if(event.getStatus() != Status.SUCCESS) { return; }
            
            _room.setAttribute(Host.ATTR_HOST, _reactor.self().getClientID());
            _room.setAttribute(Host.ATTR_START_TIME, _reactor.getServer().getServerTime().toString());
            _room.setAttribute(Host.ATTR_NUM_CONTRACTS, "0");
        }
        
        private function removeOccupantHandler(event:RoomEvent):void {
            /**
             * 1. 退室者が出た際、ホストがいないなら、ホストに立候補する
             * 2. 立候補には退室者IDを送信する
             * 3. attributeUpdateHandlerで、最初に立候補したのが自分なら自分がホストになる
             */
            if (!_room.clientIsInRoom(_room.getAttribute(Host.ATTR_HOST))) {
                _room.setAttribute(Host.ATTR_HOST_CANDIDACY, event.getClientID());
            }
        }
        
        private function attributeUpdateHandler(event:AttributeEvent):void {
            var attr:Attribute = event.getChangedAttr();
            
            switch(attr.name) {
                case Host.ATTR_START_TIME:
                {
                    _startTime = Number(attr.value);
                    break;
                }
                
                // 最初に立候補したのが自分なら自分がホストになる
                case Host.ATTR_HOST_CANDIDACY:
                {
                    if (attr.byClient && attr.byClient.isSelf()) {
                        _room.setAttribute(Host.ATTR_HOST, _reactor.self().getClientID());
                    }
                    break;
                }
                
                default: { break; }
            }
        }
        
        private function attributeDeleteHandler(event:AttributeEvent):void {
            // 自分がホストでないなら終了
            if (!isHost) { return; }
            
            var attr:Attribute = event.getChangedAttr();
            var idAndProp:Array = attr.name.split(".");
            // HPがある状態で削除(契約成立)なら、契約数を増やす
            if (idAndProp[1] == Enemy.ATTR_HP && int(attr.oldValue) > 0) {
                _room.setAttribute(Host.ATTR_NUM_CONTRACTS, "%v+1", true, false, true);
            }
        }
        
        public function update(serverTime:Number, elapsedTime:int):void {
            if (_startTime > 0) { _playTime = serverTime - _startTime; }
            // 自分がホストでないなら終了
            if (!isHost) { return; }
            
            // 敵の生成
            _spawnTimeCount += elapsedTime;
            var spawnTime:int = Math.max(50, 1500 - 150 * wave);
            if (_spawnTimeCount > spawnTime) {
                _spawnTimeCount -= spawnTime;
                var enemyID:String = _reactor.self().getClientID() + ("000" + _spawnUniqueCount).substr(-3);
                _spawnUniqueCount++;
                Enemy.spawn(_room, enemyID, 100, 10, 40, serverTime);
            }
        }
        
        public function removeEventListeners():void {
            _room.removeEventListener(RoomEvent.REMOVE_OCCUPANT, removeOccupantHandler);
            _room.removeEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
            _room.removeEventListener(AttributeEvent.DELETE, attributeDeleteHandler);
        }
        
        public function get isHost():Boolean { return _room.getAttribute(Host.ATTR_HOST) == _reactor.self().getClientID(); }
        public function get wave():int { return (_startTime > 0) ? int(_playTime / Const.FIELD_WAVE_TIME) + 1 : 1; }
        public function get numContracts():int { return int(_room.getAttribute(Host.ATTR_NUM_CONTRACTS)); }
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    
    //public 
    interface IActor {
        function draw(target:BitmapData):void;
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
    import flash.text.TextField;
/*    import ore.orelib.anim.ArmAnim;
    import ore.orelib.anim.BodyAnim;
    import ore.orelib.anim.WeaponAnim;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.WeaponSmith;
    import ore.orelib.events.EffectEvent;
*/    
    //public 
    class Friend implements IActor {
        // 移動関連
        private var _currentPosition:Point;
        private var _destPosition:Point;
        private var _speed:int;
        private var _velocityPerMs:Point;
        // 描画関連
        private var _nameLabel:TextField;
        private var _hp:int;
        private var _maxHp:int;
        private var _body:BodyAnim;
        private var _arm:ArmAnim;
        private var _weapon:WeaponAnim;
        private var _worldTrans:Matrix;
        private var _effectColorOffset:int;
        
        public static const ATTR_NAME:String = "n";
        public static const ATTR_X:String = "x";
        public static const ATTR_Y:String = "y";
        public static const ATTR_SPEED:String = "s";
        public static const ATTR_HP:String = "h";
        public static const ATTR_MAXHP:String = "m";
        public static const ATTR_CHARACTER:String = "c";
        public static const ATTR_WEAPON:String = "w";
        public static const MESSAGE_ATTACK:String = "a";
        
        public function Friend(
            name:String, x:Number, y:Number, speed:int,
            hp:int, maxHp:int, characterID:int, weaponID:int
        ) {
            _currentPosition = new Point(x, y);
            _destPosition = new Point(x, y);
            _speed = speed;
            _velocityPerMs = new Point(0, 0);
            
            _nameLabel = new TextBuilder()
                .align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(10)
                .size(140, 20).build(name);
            _hp = hp;
            _maxHp = maxHp;
            _body = new BodyAnim(characterID);
            if (_hp <= 0) { _body.transition(BodyAnim.RECOVER); }
            _arm = new ArmAnim();
            _weapon = new WeaponAnim(weaponID);
            _worldTrans = new Matrix();
            _effectColorOffset = 0;
        }
        
        /** 目的位置を更新する */
        public function moveTo(x:Number, y:Number):void {
            _destPosition.x = x;
            _destPosition.y = y;
            
            var angle:Number = Math.atan2(_destPosition.y - _currentPosition.y, _destPosition.x - _currentPosition.x);
            _velocityPerMs.x = _speed * Math.cos(angle) / 1000;
            _velocityPerMs.y = _speed * Math.sin(angle) / 1000;
        }
        
        /** 攻撃モーションを行う */
        public function attack(weaponID:int, range:int = 0):void {
            var attackTypeID:int = WeaponSmith.acquireAttackTypeOf(weaponID);
            _arm.transition((attackTypeID == Const.ATTACKTYPE_MELEE) ? ArmAnim.SWING : ArmAnim.RECOIL);
        }
        
        /** 武器変更モーションを行う */
        public function swapWeapon(weaponID:int):void {
            _arm.transition(ArmAnim.SWAP);
            _weapon.transition(weaponID);
        }
        
        /** 残りHPに応じた更新を行う */
        public function changeHp(value:int):void {
            if (value <= 0) {
                _body.transition(BodyAnim.RECOVER);
                // 休憩エフェクトはここ
            } else if (value < _hp) {
                _effectColorOffset = 300;
                EventManager.instance.dispatchEvent(new EffectEvent(
                    EffectEvent.DAMAGED_ACTOR,
                    _currentPosition.x,
                    _currentPosition.y,
                    { num: _hp - value, isEnemy: false }
                ));
            } else if (value > _hp) {
                _body.transition(BodyAnim.IDLE);
                // 復帰エフェクトはここ
            }
            
            _hp = value;
        }
        
        public function update(elapsedTime:int):void {
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
                    
                    _body.transition(BodyAnim.RUN);
                }else {
                    _body.transition(BodyAnim.IDLE);
                }
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
            var effect:ColorTransform = GeomPool.colorTransform(1, 1, 1, 1, _effectColorOffset, _effectColorOffset, _effectColorOffset);
            target.draw(Assets.images["actorShadow"], GeomPool.matrix(1, 0, 0, 1, _worldTrans.tx - 14, _worldTrans.ty - 4));
            if (_hp > 0) {
                _weapon.draw(target, effect);
                _arm.draw(target, effect);
            }
            _body.draw(target, effect);
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 34, 32, 1), 0xFFCC0000);
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 34, 32 * _hp / _maxHp, 1), 0xFF00FF00);
        }
        
        public function get x():Number { return _currentPosition.x; }
        public function get y():Number { return _currentPosition.y; }
        public function get speed():int { return _speed; }
        public function get overlay():DisplayObject { return _nameLabel; }
        public function get depth():Number { return _currentPosition.y; }
    }
//}
//package ore.orelib.actors {
    import flash.utils.Dictionary;
    import net.user1.reactor.Attribute;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
/*    import ore.orelib.commons.EventManager;
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
        }
        
        /** プレイヤーが入室した際の処理 */
        private function addOccupantHandler(event:RoomEvent):void {
            var client:IClient = event.getClient();
            if (client.isSelf()) { return; }
            
            var friend:Friend = new Friend(
                client.getAttribute(Friend.ATTR_NAME),
                Number(client.getAttribute(Friend.ATTR_X)),
                Number(client.getAttribute(Friend.ATTR_Y)),
                int(client.getAttribute(Friend.ATTR_SPEED)),
                int(client.getAttribute(Friend.ATTR_HP)),
                int(client.getAttribute(Friend.ATTR_MAXHP)),
                int(client.getAttribute(Friend.ATTR_CHARACTER)),
                int(client.getAttribute(Friend.ATTR_WEAPON))
            );
            _friendList[client.getClientID()] = friend;
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, friend, friend.overlay));
        }
        
        /** プレイヤーが退室した際の処理 */
        private function removeOccupantHandler(event:RoomEvent):void {
            var friend:Friend = _friendList[event.getClientID()];
            delete _friendList[event.getClientID()];
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
                case Friend.ATTR_X:
                case Friend.ATTR_Y:
                {
                    friend.moveTo(
                        Number(client.getAttribute(Friend.ATTR_X)),
                        Number(client.getAttribute(Friend.ATTR_Y))
                    );
                    break;
                }
                
                // 残りHPの更新
                case Friend.ATTR_HP:
                {
                    friend.changeHp(int(attr.value));
                    break;
                }
                
                // 使用武器の変更
                case Friend.ATTR_WEAPON:
                {
                    friend.swapWeapon(int(attr.value));
                    break;
                }
                
                default: { break; }
            }
        }
        
        /** プレイヤーが攻撃を行った際の処理 */
        private function attackFriendHandler(from:IClient, weaponID:String, range:String):void {
            var friend:Friend = _friendList[from.getClientID()];
            friend.attack(int(weaponID), int(range));
            EventManager.instance.dispatchEvent(new EffectEvent(
                EffectEvent.ATTACK_WEAPON,
                friend.x, friend.y,
                { id: int(weaponID), range: int(range) }
            ));
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
    import ore.orelib.data.Const;
    import ore.orelib.events.EffectEvent;
*/    
    //public 
    class Enemy implements IActor {
        private var _id:String;
        private var _hp:int;
        private var _maxHp:int;
        private var _str:int;
        // 移動関連
        private var _currentPosition:Point;
        private var _vx:int;
        private var _spawnPosition:Point;
        private var _spawnTime:Number;
        private var _bounds:Rectangle;
        // 描画関連
        private var _body:BodyAnim;
        private var _worldTrans:Matrix;
        private var _effectColorOffset:int;
        
        public static const BOUNDS_HALF_WIDTH:int = 14;
        public static const BOUNDS_HEIGHT:int = 20;
        
        public static const ATTR_STATUS:String = "s"; // maxHp,str,spawnY,vx,spawnTime
        public static const ATTR_HP:String = "h";
        public static const ATTR_SPAWN_X:String = "x";
        
        public static function spawn(room:Room, id:String, hp:int, str:int, vx:int, time:Number):void {
            room.setAttribute(id + "." + Enemy.ATTR_HP, hp.toString());
            room.setAttribute(id + "." + Enemy.ATTR_SPAWN_X, Const.FIELD_LFET_BOUND.toString());
            room.setAttribute(id + "." + Enemy.ATTR_STATUS,
                hp.toString() + "," +
                str.toString() + "," +
                int(Const.FIELD_SIZE * Math.random()) + "," +
                vx.toString() + "," +
                time.toString()
            );
        }
        
        public function Enemy(id:String, status:String, hp:String, spawnX:String) {
            var statusArray:Array = status.split(",");
            _id = id;
            _hp = (hp) ? int(hp) : int.MAX_VALUE;
            _maxHp = statusArray[0];
            _str = statusArray[1];
            _currentPosition = new Point(int(spawnX), statusArray[2]);
            _vx = statusArray[3];
            _spawnPosition = new Point(int(spawnX), statusArray[2]);
            _spawnTime = statusArray[4];
            _bounds = new Rectangle(
                _currentPosition.x - Enemy.BOUNDS_HALF_WIDTH,
                _currentPosition.y - Enemy.BOUNDS_HEIGHT,
                Enemy.BOUNDS_HALF_WIDTH * 2,
                Enemy.BOUNDS_HEIGHT
            );
            _body = new BodyAnim(Const.CHARACTER_QB);
            _body.transition(BodyAnim.RUN);
            _worldTrans = new Matrix();
            _worldTrans.ty = int(_currentPosition.y + Const.FIELD_OFFSET_Y);
            _effectColorOffset = 0;
        }
        
        /** HP変更,ノックバック: プレイヤーが直接ダメージを与える際に呼ぶ */
        public function damaged(room:Room, amount:int, knockback:int):void {
            _effectColorOffset = 300;
            EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DAMAGED_ACTOR,
                _currentPosition.x,
                _currentPosition.y,
                { num: amount, isEnemy: true }
            ));
            room.setAttribute(_id + "." + Enemy.ATTR_HP, "%v-" + amount, true, false, true);
            
            _hp -= amount;
            if (knockback > 0) {
                _spawnPosition.x -= knockback;
                room.setAttribute(_id + "." + Enemy.ATTR_SPAWN_X, "%v-" + knockback, true, false, true);
            }
        }
        
        /** HP変更: サーバーから更新メッセージを受け取った際に呼ぶ */
        public function changeHp(value:int, oldValue:int, bySelf:Boolean):void {
            if (_hp != int.MAX_VALUE && !bySelf) {
                _effectColorOffset = 300;
                EventManager.instance.dispatchEvent(new EffectEvent(EffectEvent.DAMAGED_ACTOR,
                    _currentPosition.x,
                    _currentPosition.y,
                    { num: oldValue - value, isEnemy: true }
                ));
            }
            if (value < _hp) { _hp = value; }
        }
        
        /** ノックバック: サーバーからの更新メッセージを受け取った際に呼ぶ */
        public function changeSpawnX(spawnX:int):void {
            _spawnPosition.x = spawnX;
        }
        
        public function update(serverTime:Number, elapsedTime:int):void {
            var lifeTime:Number = serverTime - _spawnTime;
            _currentPosition.x = _spawnPosition.x + _vx * lifeTime / 1000;
            _worldTrans.tx = int(_currentPosition.x + Const.FIELD_OFFSET_X);
            _bounds.x = _currentPosition.x - Enemy.BOUNDS_HALF_WIDTH;
            _bounds.y = _currentPosition.y - Enemy.BOUNDS_HEIGHT;
            _body.update(elapsedTime, _worldTrans);
            _effectColorOffset = Math.max(0, _effectColorOffset - 60);
        }
        
        public function draw(target:BitmapData):void {
            var effect:ColorTransform = GeomPool.colorTransform(1, 1, 1, 1, _effectColorOffset, _effectColorOffset, _effectColorOffset);
            target.draw(Assets.images["actorShadow"], GeomPool.matrix(1, 0, 0, 1, _worldTrans.tx - 14, _worldTrans.ty - 4));
            _body.draw(target, effect);
            var hpRate:Number = Math.min(Math.max(0, _hp), _maxHp) / _maxHp;
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 28, 32, 1), 0xFFCC0000);
            target.fillRect(GeomPool.rectangle(_worldTrans.tx - 16, _worldTrans.ty - 28, 32 * hpRate, 1), 0xFF00FF00);
        }
        
        public function get id():String { return _id; }
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
    import ore.orelib.data.Const;
    import ore.orelib.events.ActorEvent;
*/    
    //public 
    class EnemyManager {
        private var _room:Room;
        private var _enemyList:Dictionary;
        
        public function EnemyManager(room:Room) {
            _room = room;
            _enemyList = new Dictionary();
            
            _room.addEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
            _room.addEventListener(AttributeEvent.DELETE, attributeDeleteHandler);
        }
        
        private function attributeUpdateHandler(event:AttributeEvent):void {
            var attr:Attribute = event.getChangedAttr();
            var idAndName:Array = attr.name.split(".");
            var enemy:Enemy;
            switch(idAndName[1]) {
                // 敵の出現
                case Enemy.ATTR_STATUS:
                {
                    enemy = new Enemy(
                        idAndName[0],
                        attr.value,
                        _room.getAttribute(idAndName[0] + "." + Enemy.ATTR_HP),
                        _room.getAttribute(idAndName[0] + "." + Enemy.ATTR_SPAWN_X)
                    );
                    _enemyList[idAndName[0]] = enemy;
                    EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.ADD, enemy));
                    break;
                }
                
                // HPの変化(HP0でサーバーから削除は、撃破したクライアントのPlayerクラスで行う)
                case Enemy.ATTR_HP:
                {
                    enemy = _enemyList[idAndName[0]];
                    var bySelf:Boolean = (attr.byClient && attr.byClient.isSelf());
                    if (enemy) { enemy.changeHp(int(attr.value), int(attr.oldValue), bySelf); }
                    break;
                }
                
                // ノックバック
                case Enemy.ATTR_SPAWN_X:
                {
                    enemy = _enemyList[idAndName[0]];
                    if (enemy) { enemy.changeSpawnX(int(attr.value)); }
                    break;
                }
                
                default: { break; }
            }
        }
        
        private function attributeDeleteHandler(event:AttributeEvent):void {
            var idAndName:Array = event.getChangedAttr().name.split(".");
            if (idAndName[1] != Enemy.ATTR_STATUS) { return; }
            
            var enemy:Enemy = _enemyList[idAndName[0]];
            if (enemy) { deleteEnemy(enemy); }
        }
        
        private function deleteEnemy(enemy:Enemy):void {
            delete _enemyList[enemy.id];
            EventManager.instance.dispatchEvent(new ActorEvent(ActorEvent.REMOVE, enemy));
        }
        
        public function update(serverTime:Number, elapsedTime:int, isHost:Boolean):void {
            for each(var enemy:Enemy in _enemyList) {
                // 撃破されていたら削除して次へ
                if (!enemy.isAlive) {
                    deleteEnemy(enemy);
                    // 死亡エフェクトはここ
                    continue;
                }
                
                enemy.update(serverTime, elapsedTime);
                
                // 自分がホストで、敵が画面右端に到達していたらサーバーから削除
                if (isHost && enemy.x > Const.FIELD_RIGHT_BOUND) {
                    deleteEnemy(enemy);
                    _room.deleteAttribute(enemy.id + "." + Enemy.ATTR_STATUS);
                    _room.deleteAttribute(enemy.id + "." + Enemy.ATTR_HP);
                    _room.deleteAttribute(enemy.id + "." + Enemy.ATTR_SPAWN_X);
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
        
        public function removeEventListeners():void {
            _room.removeEventListener(AttributeEvent.UPDATE, attributeUpdateHandler);
            _room.removeEventListener(AttributeEvent.DELETE, attributeDeleteHandler);
        }
    }
//}
//package ore.orelib.actors {
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
        
        public function initialize(x:Number, y:Number, num:int, isEnemy:Boolean):void {
            _text.x = x - 25 + Const.FIELD_OFFSET_X;
            _text.y = y - 20 + Const.FIELD_OFFSET_Y;
            _text.text = num.toString();
            _text.textColor = (isEnemy) ? 0xFFCC44 : 0xFF8888;
            _text.alpha = 1;
            _frameCount = 0;
        }
        
        public function update():void {
            _frameCount++;
            _text.y -= 3;
            _text.alpha -= 0.05;
        }
        
        public function get overlay():DisplayObject { return _text; }
        public function get exists():Boolean { return _frameCount <= 10; }
    }
//}
//package ore.orelib.actors {
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Matrix;
/*    import ore.orelib.assets.PlayingView;
    import ore.orelib.commons.Assets;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.data.Const;
    import ore.orelib.data.WeaponSmith;
    import ore.orelib.events.EffectEvent;
*/    
    //public 
    class EffectManager {
        private var _view:PlayingView
        private var _shape:Shape;
        private var _popUpList:Vector.<PopUp>;
        private var _popUpPool:Vector.<PopUp>;
        
        public function EffectManager(view:PlayingView) {
            _view = view;
            _shape = new Shape();
            _popUpList = new Vector.<PopUp>();
            _popUpPool = new Vector.<PopUp>();
            
            EventManager.instance.addEventListener(EffectEvent.ATTACK_WEAPON, attackWeaponHandler);
            EventManager.instance.addEventListener(EffectEvent.DAMAGED_ACTOR, damagedActorHandler);
        }
        
        private function attackWeaponHandler(event:EffectEvent):void {
            var attackType:int = WeaponSmith.acquireAttackTypeOf(event.option.id);
            var g:Graphics = _shape.graphics; g.clear();
            
            switch(attackType) {
                case Const.ATTACKTYPE_SHOOTING:
                {
                    var color:uint;
                    switch(event.option.id) {
                        case Const.WEAPON_ROSEBOW: { color = 0xFF00FF; break; }
                        case Const.WEAPON_BLACKBOW: { color = 0xFF00FF; break; }
                        case Const.WEAPON_PISTOL: { addMuzzleFlash(event.x, event.y, 20); /*fallthrough*/ }
                        case Const.WEAPON_MASKET: { addMuzzleFlash(event.x, event.y, 36); /*fallthrough*/ }
                        case Const.WEAPON_MINIMI: { addMuzzleFlash(event.x, event.y, 38); /*fallthrough*/ }
                        default: { color = 0xFFFF00 + uint(0x88 * Math.random()); break; }
                    }
                    var matrix:Matrix = GeomPool.matrix();
                    matrix.createGradientBox(event.option.range, 1);
                    g.beginGradientFill(GradientType.LINEAR, [color, color], [1, 0], [0, 255], matrix);
                    g.drawRect(0, 0, event.option.range, 1);
                    g.endFill();
                    _view.effect.draw(_shape, GeomPool.matrix(1, 0, 0, 1,
                        int(event.x - 8 - event.option.range + Const.FIELD_OFFSET_X),
                        int(event.y - 20 + int(9 * Math.random()) + Const.FIELD_OFFSET_Y)
                    ));
                    break;
                }
                
                case Const.ATTACKTYPE_EXPLOSIVE:
                {
                    
                }
                
                case Const.ATTACKTYPE_MELEE:
                {
                    g.beginFill(0xFFFFFF);
                    g.moveTo(event.x, event.y - 40);
                    g.curveTo(
                        event.x - 8 - event.option.range,
                        event.y - 40,
                        event.x - 8 - event.option.range,
                        event.y + 10
                    );
                    g.lineTo(event.x - event.option.range + 9, event.y);
                    g.curveTo(
                        event.x - 8 - event.option.range,
                        event.y - 40,
                        event.x,
                        event.y - 40
                    );
                    g.endFill();
                    _view.effect.draw(_shape, GeomPool.matrix(1, 0, 0, 1, Const.FIELD_OFFSET_X, Const.FIELD_OFFSET_Y));
                    break;
                }
                
                default: { break; }
            }
        }
        
        private function addMuzzleFlash(x:int, y:int, offsetX:int):void {
            var muzzleFlashes:Vector.<BitmapData> = Assets.images["muzzleFlashes"];
            _view.effect.draw(muzzleFlashes[int(muzzleFlashes.length * Math.random())],
                GeomPool.matrix(1, 0, 0, 1,
                    int(x - offsetX - 32 + Const.FIELD_OFFSET_X),
                    int(y - 35 + int(7 * Math.random()) + Const.FIELD_OFFSET_Y)
                )
            );
        }
        
        private function damagedActorHandler(event:EffectEvent):void {
            var popUp:PopUp = (_popUpPool.length) ? _popUpPool.pop() : new PopUp();
            popUp.initialize(event.x, event.y, event.option.num, event.option.isEnemy);
            _popUpList.push(popUp);
            _view.overlay.addChild(popUp.overlay);
            
            if (event.option.isEnemy) {
                /*
                var bloods:Vector.<BitmapData> = Assets.images["bloods"];
                _view.effect.draw(bloods[int(bloods.length * Math.random())],
                    GeomPool.matrix(1, 0, 0, 1,
                        int(event.x - 16 + Const.FIELD_OFFSET_X),
                        int(event.y - 28 + Const.FIELD_OFFSET_Y)
                    )
                );*/
            }
        }
        
        public function update():void {
            for (var i:int = _popUpList.length - 1; i >= 0; i--) {
                var popUp:PopUp = _popUpList[i];
                popUp.update();
                
                if (!popUp.exists) {
                    _view.overlay.removeChild(popUp.overlay);
                    _popUpList.splice(_popUpList.indexOf(popUp), 1);
                    _popUpPool.push(popUp);
                }
            }
        }
        
        public function removeEventListeners():void {
            EventManager.instance.removeEventListener(EffectEvent.ATTACK_WEAPON, attackWeaponHandler);
            EventManager.instance.removeEventListener(EffectEvent.DAMAGED_ACTOR, damagedActorHandler);
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
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;
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
                    _angle = 3;
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
    import ore.orelib.data.Const;
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
        public static const DAMAGED_ACTOR:String = "effect_damaged_enemy";
        
        public function EffectEvent(type:String, x:int, y:int, option:Object = null) {
            super(type);
            _x = x;
            _y = y;
            _option = option;
        }
        
        public override function clone():Event { return new EffectEvent(type, _x, _y, _option); }
        public override function toString():String { return formatToString("EffectEvent", "type", "x", "y"); }
        
        public function get x():int { return _x; }
        public function get y():int { return _y; }
        public function get option():Object { return _option; }
    }
//}
//package ore.orelib.assets {
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.filters.GlowFilter;
    import net.user1.reactor.Reactor;
/*    import ore.orelib.actors.IActor;
    import ore.orelib.commons.EventManager;
    import ore.orelib.commons.GeomPool;
    import ore.orelib.commons.MiniChat;
    import ore.orelib.commons.TextBuilder;
    import ore.orelib.data.Const;
    import ore.orelib.data.SaveData;
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
        
        public function setupHUD(player:Player):void {
            addChild(_hud = new HUD(player));
        }
        
        public function createChatWindow(roomID:String, reactor:Reactor):MiniChat {
            var result:MiniChat = new MiniChat(
                roomID,
                {
                    logSize: 7,
                    defaultUserName: SaveData.instance.player.name,
                    draggable: false,
                    minimizable: false,
                    renamable: false,
                    reactor: reactor
                }
            );
            result.x = 465 - result.width;
            result.y = -20;
            return result;
        }
        
        public function setupGameoverDisplay(leaveButton:PushButton, isReactorReady:Boolean):void {
            var disp:Sprite = new Sprite();
            disp.graphics.beginFill(0x000000, 0.8);
            disp.graphics.drawRect(0, 0, 465, 465);
            disp.graphics.endFill();
            addChild(disp);
            
            var gameoverReason:String = (isReactorReady)
                ? "QBがノルマを達成しちゃいました！\nこの世界は破滅です。"
                : "接続がタイムアウトしました。";
            disp.addChild(
                new TextBuilder().align(TextBuilder.CENTER)
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(24)
                .pos(0, 150).size(465, 100).build(gameoverReason)
            );
            disp.addChild(leaveButton);
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
            _actorList.sort(compareDepthOfActor);
            _screen.lock();
            _screen.fillRect(GeomPool.rectangle(0, 0, 465, 465), 0x00FFFFFF);
            for each(var actor:IActor in _actorList) {
                actor.draw(_screen);
            }
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
        
        public function HUD(player:Player) {
            var bmd:BitmapData = new BitmapData(48, 48, true, 0xFF404040);
            bmd.draw(Assets.images["characters"][player.characterID + 1], new Matrix(4, 0, 0, 4, -4, 4));
            _characterFace = new Bitmap(bmd);
            _characterFace.x = 13;
            _characterFace.y = 6;
            addChild(_characterFace);
            addChild(_borders = new Shape());
            
            var builder:TextBuilder = new TextBuilder()
                .filters([new GlowFilter(0x000000, 1, 2, 2, 8)])
                .font(Const.FONT, -400, 400).fontColor(0xFFFFFF).fontSize(12);
            addChild(_nameLabel = builder.autoSize().pos(70, 5).size(150, 25).build(SaveData.instance.player.name));
            builder.autoSize(false);
            
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
//package ore.orelib.assets {
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
            g.beginFill(0xFFFFFF);
            g.drawEllipse(22, 4, 8, 24);
            g.endFill();
            g.beginFill(0xFFFFFF);
            g.moveTo(2, 16); g.lineTo(26, 10); g.lineTo(26, 22); g.lineTo(2, 16);
            g.endFill();
            g.beginFill(0xFFFFFF);
            g.moveTo(12, 4); g.lineTo(26, 8); g.lineTo(26, 16); g.lineTo(12, 4);
            g.moveTo(12, 28); g.lineTo(26, 24); g.lineTo(26, 16); g.lineTo(12, 28);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                4, 16, DisplacementMapFilterMode.CLAMP
            ));
            result.applyFilter(result, result.rect, new Point(), new GlowFilter(0xFFCC00, 1, 4, 4));
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
            var result:BitmapData = new BitmapData(32, 32, true, 0x00FFFFFF);
            var noise:BitmapData = result.clone();
            noise.perlinNoise(4, 4, 4, seed, false, true, BitmapDataChannel.RED | BitmapDataChannel.GREEN);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            g.beginFill(0x880000);
            g.drawCircle(16, 16, 12);
            g.drawCircle(16, 16, 10);
            g.endFill();
            
            result.draw(sp);
            result.applyFilter(result, result.rect, new Point(), new DisplacementMapFilter(
                noise, new Point(), BitmapDataChannel.RED, BitmapDataChannel.GREEN,
                32, 32, DisplacementMapFilterMode.CLAMP
            ));
            return result;
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
        private var _loaders:Dictionary;
        private var _fonts:Vector.<String>;
        
        public function Preloader(parent:DisplayObjectContainer) {
            _progressBar = new ProgressBar(parent, 182, 227);
            _progressBar.maximum = 0;
            
            _reactor = null;
            _loaders = new Dictionary();
            _fonts = new Vector.<String>();
        }
        
        public function addReactorConnectionRequest(reactor:Reactor):void {
            _reactor = reactor;
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
        
        public function load():void {
            if (_reactor) {
                _reactor.addEventListener(ReactorEvent.READY, onLoaded);
                _reactor.connect("tryunion.com", 80);
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
        }
        
        public static function record():void {
            _key.record();
            _mouse.record();
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
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Timer;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.Statistics;
    
    //public 
    class UnionStats extends Sprite {
        private var _reactor:Reactor;
        private var _fpsCount:int;
        private var _timer:Timer;
        
        private var _fps:TextField, _stageFps:TextField;
        private var _mem:TextField, _peakMem:TextField;
        private var _ping:TextField;
        private var _recv:TextField, _peakRecv:TextField;
        private var _send:TextField, _peakSend:TextField;
        private var _msg:TextField, _peakMsg:TextField;
        
        public function UnionStats(reactor:Reactor) {
            _reactor = reactor;
            _reactor.enableStatistics();
            
            _fpsCount = 0;
            addEventListener(Event.ENTER_FRAME, function(event:Event):void { _fpsCount++; } );
            
            _timer = new Timer(1000, 0);
            _timer.addEventListener(TimerEvent.TIMER, update);
            _timer.start();
            
            graphics.beginFill(0x404040);
            graphics.drawRect(0, 0, 100, 100);
            graphics.endFill();
            graphics.lineStyle(1, 0xFFFFFF, 1, true, "normal", "none", "bevel");
            graphics.moveTo(5, 34);
            graphics.lineTo(95, 34);
            
            addChild(createTextField("FPS ", 0, 0, 30, TextFieldAutoSize.LEFT));
            addChild(createTextField("Mem ", 0, 16, 30, TextFieldAutoSize.LEFT));
            addChild(createTextField("Ping ", 0, 36, 30, TextFieldAutoSize.LEFT));
            addChild(createTextField("Down ", 0, 52, 30, TextFieldAutoSize.LEFT));
            addChild(createTextField("Up ", 0, 68, 30, TextFieldAutoSize.LEFT));
            addChild(createTextField("Msg ", 0, 84, 30, TextFieldAutoSize.LEFT));
            
            addChild(_fps = createTextField("0", 30, 0, 30, TextFieldAutoSize.RIGHT));
            addChild(_mem = createTextField("0", 30, 16, 30, TextFieldAutoSize.RIGHT));
            addChild(_recv = createTextField("0", 30, 52, 30, TextFieldAutoSize.RIGHT));
            addChild(_send = createTextField("0", 30, 68, 30, TextFieldAutoSize.RIGHT));
            addChild(_msg = createTextField("0", 30, 84, 30, TextFieldAutoSize.RIGHT));
            
            addChild(createTextField("/", 60, 0, 7, TextFieldAutoSize.CENTER));
            addChild(createTextField("/", 60, 16, 7, TextFieldAutoSize.CENTER));
            addChild(_ping = createTextField("0", 30, 36, 70, TextFieldAutoSize.CENTER));
            addChild(createTextField("/", 60, 52, 7, TextFieldAutoSize.CENTER));
            addChild(createTextField("/", 60, 68, 7, TextFieldAutoSize.CENTER));
            addChild(createTextField("/", 60, 84, 7, TextFieldAutoSize.CENTER));
            
            addChild(_stageFps = createTextField("0", 67, 0, 30, TextFieldAutoSize.LEFT));
            addChild(_peakMem = createTextField("0", 67, 16, 30, TextFieldAutoSize.LEFT));
            addChild(_peakRecv = createTextField("0", 67, 52, 30, TextFieldAutoSize.LEFT));
            addChild(_peakSend = createTextField("0", 67, 68, 30, TextFieldAutoSize.LEFT));
            addChild(_peakMsg = createTextField("0", 67, 84, 30, TextFieldAutoSize.LEFT));
        }
        
        private function update(event:TimerEvent):void {
            _fps.text = _fpsCount.toString();
            _fpsCount = 0;
            if (stage) { _stageFps.text = stage.frameRate.toString(); }
            
            if (!_reactor.isReady()) { return; }
            _ping.text = _reactor.self().getPing().toString();
            var stats:Statistics = _reactor.getStatistics();
            _mem.text = stats.getTotalMemoryMB().toFixed(2);
            _recv.text = stats.getKBReceivedPerSecond().toFixed(2);
            _send.text = stats.getKBSentPerSecond().toFixed(2);
            _msg.text = stats.getMessagesPerSecond().toString();
            _peakMem.text = stats.getPeakMemoryMB().toFixed(2);
            _peakRecv.text = stats.getPeakKBReceivedPerSecond().toFixed(2);
            _peakSend.text = stats.getPeakKBSentPerSecond().toFixed(2);
            _peakMsg.text = stats.getPeakMessagesPerSecond().toString();
        }
        
        private function createTextField(text:String, x:int, y:int, width:int, autoSize:String):TextField {
            var result:TextField = new TextField();
            result.x = x;
            result.width = width;
            result.autoSize = autoSize;
            result.defaultTextFormat = new TextFormat("_sans", 9, 0xFFFFFF, true);
            result.text = text;
            result.y = y;
            result.mouseEnabled = result.selectable = false;
            return result;
        }
    }
//}
//package ore.orelib.commons {
    import com.bit101.components.PushButton;
    import com.bit101.components.Style;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.filters.DropShadowFilter;
    import flash.net.SharedObject;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import net.user1.logger.Logger;
    import net.user1.reactor.IClient;
    import net.user1.reactor.Reactor;
    import net.user1.reactor.ReactorEvent;
    import net.user1.reactor.Room;
    import net.user1.reactor.RoomEvent;
    import net.user1.reactor.UpdateLevels;
    
    //public 
    class MiniChat extends Sprite {
        private var _so:SharedObject;
        private var _isReactorShared:Boolean;
        private var _reactor:Reactor;
        private var _roomID:String;
        private var _room:Room;
        private var _messageLogSize:int;
        private var _messages:Vector.<String>;
        // ステータスバー
        private var _statusBar:TextField;
        private var _minimizeButton:PushButton;
        // ウインドウ
        private var _window:Sprite;
        private var _messageDisplay:TextField;
        private var _nameInput:TextField;
        private var _messageInput:TextField;
        private var _sendButton:PushButton;
        
        /**
         * ミニチャットウインドウを作成します。表示リストに追加されているかどうかで、自動的に接続・切断を行います。
         * @param    roomID チャットルームのIDです。他と被らないような名前を設定して下さい。
         * @param    args   任意で指定する引数です。
         *      "logSize"            表示するメッセージの数を指定します。初期値は5です。指定数に応じて、ウインドウの高さが調整されます。
         *      "textColor"          上部ステータスバーの文字の色を指定します。
         *      "backgroundColor"    上部ステータスバーの背景の色を指定します。
         *      "defaultUserName"    デフォルトの参加者の名前を指定します。指定しない場合、"名無し"または前回参加時の名前になります。
         *      "initiallyMinimized" 最初に最小化された状態にするかどうかを指定します。初期値はfalseです。
         *      "draggable"          ドラッグ可能にするかどうかを指定します。初期値はtrueです。
         *      "minimizable"        最小化可能にするかどうかを指定します。初期値はtrueです。falseの場合、最小化ボタンは表示されません。
         *      "renamable"          名前変更可能にするかどうかを指定します。初期値はtrueです。falseの場合、名前入力欄は表示されません。
         *      "reactor"            メッセージ通信に、指定したReactorを使用するようにします。指定した場合、自動的な接続・切断は無効になります。
         */
        public function MiniChat(roomID:String, args:Object = null) {
            _so = SharedObject.getLocal("MiniChat");
            if (!_so.data.name) { _so.data.name = "名無し"; }
            
            if (!args) { args = { }; }
            var logSize:int = ("logSize" in args) ? args["logSize"] : 5;
            var textColor:uint = ("textColor" in args) ? args["textColor"] : 0xFFFFFF;
            var backgroundColor:uint = ("backgroundColor" in args) ? args["backgroundColor"] : 0x404040;
            var defaultUserName:String = ("defaultUserName" in args) ? args["defaultUserName"] : _so.data.name;
            var initiallyMinimized:Boolean = ("initiallyMinimized" in args) ? args["initiallyMinimized"] : false;
            var draggable:Boolean = ("draggable" in args) ? args["draggable"] : true;
            var minimizable:Boolean = ("minimizable" in args) ? args["minimizable"] : true;
            var renamable:Boolean = ("renamable" in args) ? args["renamable"] : true;
            
            _isReactorShared = ("reactor" in args) ? true : false;
            _reactor = (_isReactorShared) ? args["reactor"] : new Reactor();
            _roomID = roomID;
            _messageLogSize = Math.max(1, logSize);
            _messages = new Vector.<String>();
            
            // MinimalcompsのStyleを一時保存してから変更する
            var tempEmbedFonts:Boolean = Style.embedFonts;
            var tempFontName:String = Style.fontName;
            var tempFontSize:Number = Style.fontSize;
            Style.embedFonts = false;
            Style.fontName = "_sans";
            Style.fontSize = 10;
            // UIの作成
            addChild(_statusBar = createStatusBar(draggable, textColor, backgroundColor));
            if (minimizable) { addChild(_minimizeButton = createMinimizeButton()); }
            _messageDisplay = createMessageDisplay(logSize);
            _window = createWindow(_messageDisplay.height);
            addChild(_window);
            _window.addChild(_messageDisplay);
            _nameInput = createInputText(1, _window.height - 19, 50, 8, defaultUserName);
            if (renamable) {
                _window.addChild(_nameInput);
                _window.addChild(_messageInput = createInputText(51, _window.height - 19, 150, 50, ""));
            }else {
                _window.addChild(_messageInput = createInputText(1, _window.height - 19, 200, 50, ""));
            }
            _window.addChild(_sendButton = createSendButton(_window.height - 19));
            // MinimalcompsのStyleを元に戻す
            Style.embedFonts = tempEmbedFonts;
            Style.fontName = tempFontName;
            Style.fontSize = tempFontSize;
            
            if (initiallyMinimized) { minimize(); }
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
        }
        
        private function createStatusBar(draggable:Boolean, textColor:uint, backgroundColor:uint):TextField {
            var result:TextField = new TextField();
            result.width = 232; result.height = 20;
            var format:TextFormat = new TextFormat("_sans", 10, textColor);
            format.align = TextFormatAlign.CENTER;
            result.defaultTextFormat = format;
            result.background = true; result.backgroundColor = backgroundColor;
            result.filters = [new BevelFilter(1, 45, 0xFFFFFF, 0.8, 0x000000, 0.8, 1, 1)];
            result.mouseEnabled = result.selectable = false;
            if (draggable) {
                result.mouseEnabled = true;
                result.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
                result.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
            }
            return result;
        }
        private function startDragHandler(event:MouseEvent):void { startDrag(); }
        private function stopDragHandler(event:MouseEvent):void { stopDrag(); }
        
        private function createMinimizeButton():PushButton {
            var result:PushButton = new PushButton(null, 215, 3, "-", minimize);
            result.width = result.height = 14; result.draw();
            return result;
        }
        
        private function createWindow(messageDisplayHeight:int):Sprite {
            var result:Sprite = new Sprite();
            result.y = 20;
            result.graphics.beginFill(0x808080, 0.5);
            result.graphics.drawRect(0, 0, 232, messageDisplayHeight + 20);
            result.graphics.endFill();
            return result;
        }
        
        private function createMessageDisplay(logSize:int):TextField {
            var result:TextField = new TextField();
            result.width = 232;
            result.defaultTextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
            result.filters = [new DropShadowFilter(1, 45, 0x404040, 1, 1, 1)];
            result.mouseEnabled = result.selectable = false;
            
            for (var i:int = 0; i < logSize; i++) { result.appendText(i + "\n"); }
            result.height = result.textHeight + 4; result.text = "";
            return result;
        }
        
        private function createInputText(x:int, y:int, width:int, maxChars:int, text:String):TextField {
            var result:TextField = new TextField();
            result.x = x; result.y = y;
            result.width = width; result.height = 18;
            result.defaultTextFormat = new TextFormat("_sans", 10, 0x000000);
            result.background = true; result.backgroundColor = 0xFFFFFF;
            result.filters = [new BevelFilter(1, 225, 0xC0C0C0, 1, 0x404040, 1, 1, 1)];
            result.maxChars = maxChars;
            result.selectable = true;
            result.type = TextFieldType.INPUT;
            result.text = text;
            return result;
        }
        
        private function createSendButton(y:int):PushButton {
            var result:PushButton = new PushButton(null, 201, y, "送信", sendMessage);
            result.width = 30; result.height = 18; result.draw();
            return result;
        }
        
        private function addedToStageHandler(event:Event):void {
            _reactor.addEventListener(ReactorEvent.READY, joinRoom);
            _reactor.addEventListener(ReactorEvent.CLOSE, leaveRoom);
            leaveRoom();
            
            if (_isReactorShared) {
                if (_reactor.isReady()) { joinRoom(); }
            } else {
                _reactor.getConnectionMonitor().setAutoReconnectFrequency(5000);
                _reactor.getLog().setLevel(Logger.FATAL);
                _reactor.connect("tryunion.com", 80);
            }
        }
        
        private function removedFromStageHandler(event:Event):void {
            _reactor.removeEventListener(ReactorEvent.READY, joinRoom);
            _reactor.removeEventListener(ReactorEvent.CLOSE, leaveRoom);
            leaveRoom();
            
            if (!_isReactorShared) { _reactor.disconnect(); }
        }
        
        private function joinRoom(event:ReactorEvent = null):void {
            var updateLevels:UpdateLevels = new UpdateLevels();
            updateLevels.clearAll();
            updateLevels.occupantCount = updateLevels.roomMessages = true;
            
            _room = _reactor.getRoomManager().createRoom(_roomID);
            _room.addEventListener(RoomEvent.OCCUPANT_COUNT, roomOccupantCountHandler);
            _room.addMessageListener("CHAT_MESSAGE", receiveMessage);
            _room.join(null, updateLevels);
            
            _sendButton.enabled = true;
        }
        
        private function roomOccupantCountHandler(event:RoomEvent):void {
            _statusBar.text = "現在の閲覧者数 " + _room.getNumOccupants() + "人";
        }
        
        private function leaveRoom(event:ReactorEvent = null):void {
            if (_room) {
                _room.removeEventListener(RoomEvent.OCCUPANT_COUNT, roomOccupantCountHandler);
                _room.removeMessageListener("CHAT_MESSAGE", receiveMessage);
                _room.leave();
            }
            
            _statusBar.text = "サーバーに接続中...";
            _sendButton.enabled = false;
        }
        
        private function sendMessage(event:MouseEvent):void {
            if (_messageInput.text == "") { return; }
            
            _room.sendMessage("CHAT_MESSAGE", true, null, _nameInput.text, _messageInput.text);
            _so.data.name = _nameInput.text;
            _messageInput.text = "";
            
            stage.focus = null;
        }
        
        private function receiveMessage(from:IClient, senderName:String, messageText:String):void {
            _messages.push(senderName + ": " + messageText);
            if (_messages.length > _messageLogSize) { _messages.shift(); }
            
            _messageDisplay.text = "";
            var messagesLength:int = _messages.length;
            for (var i:int = 0; i < messagesLength; i++) {
                _messageDisplay.appendText(_messages[i] + "\n");
            }
        }
        
        private function minimize(event:MouseEvent = null):void {
            _window.visible = !_window.visible;
            if (_minimizeButton) { _minimizeButton.label = (_window.visible) ? "-" : "+"; }
        }
    }
//}
//package ore.orelib.data {
    import flash.errors.IllegalOperationError;
    import flash.net.registerClassAlias;
    import flash.net.SharedObject;
    
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
            if (!_so.data.player) {
                _so.data.player = new PlayerData();
                _so.data.inventory = WeaponSmith.createInitialEquipment();
            }
        }
        
        public function get player():PlayerData { return _so.data.player; }
        public function get inventory():Array { return _so.data.inventory; }
    }
//}
//package ore.orelib.data {
    
    //public 
    class PlayerData {
        public var name:String = "";
        public var characterID:int = Const.CHARACTER_HOMURA;
        public var level:int = 1;
        public var exp:Number = 0;
        public var statusPoints:int = 2;
        public var status:PlayerStatus = new PlayerStatus(100, 100, 100, 100);
        public var primaryWeaponIndex:int = 0;
        public var secondaryWeaponIndex:int = 1;
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
        public var id:int = 0;
        public var prefix:int = 0;
        public var prefixLevel:int = 0;
        public var base:int = 0;
        public var baseLevel:int = 0;
    }
//}
//package ore.orelib.data {
/*    import ore.orelib.logic.Weapon;
*/    
    //public 
    class WeaponSmith {
        
        /**
         *  0. requirementScore
         *  1. baseMinDamage
         *  2. baseRandDamage
         *  3. multDamage
         *  4. addMinDamage
         *  5. addRandDamage
         *  6. baseAttackRate
         *  7. multAttackRate
         *  8. baseReloadRate
         *  9. multReloadRate
         * 10. baseAmmo
         * 11. addAmmo
         * 12. criticalRate
         * 13. knockback
         * 14. strBonus
         * 15. vitBonus
         * 16. dexBonus
         * 17. lucBonus
         * 18. baseRange
         * 19. multRange
         * 20. penetration
         */
        
        private static const WEAPONS:Array = [
            {
                baseName: "ピストル",
                mods: [
                    [0, 15, 15, 0, 0, 0, 100, 0, 1500, 0, 100, 0, 0, 1, 0, 0, 0, 0, 100, 0, 10]
                ]
            },
            null,
            {
                baseName: "ミニミ",
                mods:[
                    [0, 8, 32, 0, 0, 0, 100, 0, 2500, 0, 50, 0, 3, 0, 0, 0, 0, 0, 150, 0, 1]
                ]
            },
            null,
            null,
            null,
            null,
            null,
            {
                baseName: "ゴルフクラブ",
                mods: [
                    [0, 45, 25, 0, 0, 0, 500, 0, 500, 0, 1, 0, 15, 10, 0, 0, 0, 0, 36, 0, 0]
                ]
            },
            null,
            null,
            null
        ];
        
        public static function createWeaponFromData(data:WeaponData):Weapon {
            var name:String = WEAPONS[data.id].baseName;
            var mods:Array = WEAPONS[data.id].mods[0];
            
            var buffs:String = "";
            if (mods[3] > 0) { buffs += "ダメージ +" + mods[3] + "%\n"; }
            if (mods[4] > 0) { buffs += "最小ダメージ +" + mods[4] + "\n"; }
            if (mods[5] > 0) { buffs += "最大ダメージ　+" + mods[5] + "\n"; }
            if (mods[7] > 0) { buffs += "攻撃速度 +" + mods[7] + "%\n"; }
            if (mods[9] > 0) { buffs += "リロード速度 +" + mods[9] + "%\n"; }
            if (mods[11] > 0) { buffs += "装弾数 +" + mods[11] + "\n"; }
            if (mods[12] > 0) { buffs += "命中時 " + mods[12] + "%　の確率でクリティカル\n"; }
            if (mods[13] > 0) { buffs += "命中時ノックバック +" + mods[13] + "\n"; }
            if (mods[14] > 0) { buffs += "魔力ボーナス +" + mods[14] + "\n"; }
            if (mods[15] > 0) { buffs += "体力ボーナス +" + mods[15] + "\n"; }
            if (mods[16] > 0) { buffs += "敏捷ボーナス +" + mods[16] + "\n"; }
            if (mods[17] > 0) { buffs += "幸運ボーナス +" + mods[17] + "\n"; }
            if (mods[19] > 0) { buffs += "範囲 +" + mods[19] + "%\n"; }
            if (mods[20] > 0) { buffs += "貫通力 +"　+ mods[20] +　"\n"; }
            
            return new Weapon(
                data.id,
                name,
                buffs,
                (mods[1] * (100 + mods[3]) / 100) + mods[4],
                (mods[2] * (100 + mods[3]) / 100) + mods[5],
                mods[6] * (100 + mods[7]) / 100,
                mods[8] * (100 + mods[9]) / 100,
                mods[10] + mods[11],
                mods[12],
                mods[13],
                new PlayerStatus(mods[14], mods[15], mods[16], mods[17]),
                mods[18] + mods[19],
                mods[20]
            );
        }
        
        public static function createInitialEquipment():Array {
            var result:Array = [];
            var primary:WeaponData = new WeaponData();
            primary.id = Const.WEAPON_MINIMI;
            var secondary:WeaponData = new WeaponData();
            secondary.id = Const.WEAPON_GOLFCLUB;
            result.push(primary, secondary);
            return result;
        }
        
        public static function acquireAttackTypeOf(weaponID:int):int {
            switch(weaponID) {
                case Const.WEAPON_PIPEBOMB:
                case Const.WEAPON_RPG7:
                {
                    return Const.ATTACKTYPE_EXPLOSIVE;
                }
                
                case Const.WEAPON_GOLFCLUB:
                case Const.WEAPON_METALBAT:
                case Const.WEAPON_SABER:
                case Const.WEAPON_SPEAR:
                {
                    return Const.ATTACKTYPE_MELEE;
                }
                
                case Const.WEAPON_PISTOL:
                case Const.WEAPON_MASKET:
                case Const.WEAPON_MINIMI:
                case Const.WEAPON_ROSEBOW:
                case Const.WEAPON_BLACKBOW:
                case Const.WEAPON_EXTINGUISHER:
                default:
                {
                    return Const.ATTACKTYPE_SHOOTING;
                }
            }
        }
    }
//}
//package ore.orelib.data {
    
    //public 
    class Const {
        // プレイフィールドの設定
        public static const FIELD_SIZE:int = 300;
        public static const FIELD_OFFSET_X:int = 100;
        public static const FIELD_OFFSET_Y:int = 165;
        public static const FIELD_LFET_BOUND:int = -130;
        public static const FIELD_RIGHT_BOUND:int = 370;
        public static const FIELD_WAVE_TIME:int = 30000; //(ms)
        public static const FIELD_QB_QUOTA:int = 50;
        // プレイヤーの基礎値
        public static const PLAYER_SPEED:Number = 60; //(px/s)
        public static const PLAYER_SWAP_TIME:int = 500; //(ms)
        public static const PLAYER_INVINCIBLE_TIME_ON_DAMAGED:int = 250; //(ms)
        public static const PLAYER_INVINCIBLE_TIME_ON_RECOVER:int = 2000; //(ms)
        public static const PLAYER_RECOVER_TIME:int = 20000; //(ms)
        public static const PLAYER_POS_SEND_INTERVAL:int = 250; //(ms)
        // キャラクターのID
        public static const CHARACTER_MADOKA:int = 0;
        public static const CHARACTER_HOMURA:int = 3;
        public static const CHARACTER_SAYAKA:int = 6;
        public static const CHARACTER_MAMI:int = 9;
        public static const CHARACTER_KYOKO:int = 12;
        public static const CHARACTER_QB:int = 15;
        // 武器のID
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
        // 武器攻撃タイプのID
        public static const ATTACKTYPE_SHOOTING:int = 0;
        public static const ATTACKTYPE_EXPLOSIVE:int = 1;
        public static const ATTACKTYPE_MELEE:int = 2;
        
        public static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
        
        public static const IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/2/25/254f/254f80e0e624453eb301e9ac682271758303c507";
        public static const FONT:String = "Azuki";
    }
//}