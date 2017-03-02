package  

{

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.media.Sound;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    /**
     * You're a blind samurai, use your ears to beat the bad ninjas
     * Listen to the sound if they are close enough and coming from left, right or in front of you
     * @author Jacky Riawan
     */
    public class Main extends Sprite   {
        private const mainMenu:Sprite = new Sprite();
        private const gameScreen:Sprite = new Sprite();
        private const _soundTransform:SoundTransform = new SoundTransform();
        private var enemyInRange:Array = new Array();
        private var slash:Array = new Array();
        private var hit:Sound;
        private var swing:Sound;
        private var pain:Sound;
        private var step:Sound;
        private var soundLoaded:int = 0;
        private const soundNum:int = 4;
        private var clearEnemyTimer:int;
        private var canAttack:Boolean;
        private var stepDelay:int;
        private var timer:int;
        private var kill:int;
        private var combo:int;
        private var score:int;
        private var score_txt:TextField;
        private var result:TextField;
        private var haveToKill:Boolean;
        private var topScore:int = 0;
        private var topScore_txt:TextField= new TextField();
        public function Main() 
        {
            loadingAssets();
        }       
        private function loadingAssets():void 
        {
            hit = new Sound(new URLRequest("http://k007.kiwi6.com/hotlink/15859r8024/"));
            swing = new Sound(new URLRequest("http://k007.kiwi6.com/hotlink/wr1h4eoe9i/swing.mp3"));
            pain = new Sound(new URLRequest("http://k007.kiwi6.com/hotlink/x8d17vhx4b/pain.mp3"));
            step = new Sound(new URLRequest("http://k007.kiwi6.com/hotlink/767q28u682/step.mp3"));
            hit.addEventListener(Event.COMPLETE, soundLoadComplete);
            pain.addEventListener(Event.COMPLETE, soundLoadComplete);
            step.addEventListener(Event.COMPLETE, soundLoadComplete;
            swing.addEventListener(Event.COMPLETE, soundLoadComplete);
        }        
        private function soundLoadComplete(e:Event):void 
        {
            soundLoaded++;
            if (soundLoaded == soundNum) {
                gameReady();
            }
        }        
        private function buildGameScreen():void 
        {
            var instructions:TextField = new TextField();
            instructions.text = "Listen to the sound for the enemy position and attack when the opponent get close\nAttack left [LEFT ARROW KEY]\nAttack front [UP ARROW KEY]\nAttack right [RIGHT ARROW KEY]";
            instructions.textColor = 0xFFFFFF;
            result = new TextField();
            result.defaultTextFormat = new TextFormat(null, 20, 0xFF0000, true, null, null, null, null, "center");
            result.autoSize = "center";
            instructions.autoSize = "left";
            score_txt = new TextField();
            score_txt.textColor = 0xFFFFFF;
            score_txt.text = "Score:9999\nKill: 9999\nTime: 00:00";
            score_txt.autoSize = "left";
            score_txt.y = stage.stageHeight - score_txt.height;
            result.x = (stage.stageWidth - result.width) / 2;
            result.y = (stage.stageWidth - result.height) / 2;
            result.selectable = score_txt.selectable = instructions.selectable = false;
            gameScreen.addChild(instructions);
            gameScreen.addChild(result);
            gameScreen.addChild(score_txt);
            gameScreen.addEventListener(Event.ADDED_TO_STAGE, gameStartedHandler);
            gameScreen.addEventListener(Event.REMOVED_FROM_STAGE, gameStoppedHandler);
        }        
        private function gameStoppedHandler(e:Event):void 
        {
            removeEventListener(Event.ENTER_FRAME, gameStep);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, attackHandler);
            stage.removeEventListener(KeyboardEvent.KEY_UP, attackReleaseHandler);
        }        
        private function gameStartedHandler(e:Event):void 
        {
            canAttack = true;
            stepDelay = 50;
            clearEnemyTimer = 0;
            timer = stage.frameRate * 120;
            combo = 0;
            kill = 0;
            score = 0;
            updateScoreTxt();
            result.text = "";
            enemyInRange = [];
            slash = [];
            addEventListener(Event.ENTER_FRAME, gameStep);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, attackHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, attackReleaseHandler);
        }
        private function updateScoreTxt():void {
            var min:int = timer / (60 * stage.frameRate);
            var sec:int = (timer - (min * 60 * stage.frameRate)) / stage.frameRate;
            var timeString:String = "";
            if (min < 10) {
                timeString = "0" + min + ":";
            }else {
                timeString = min.toString() + ":";
            }
            if (sec < 10) {
                timeString += "0" + sec;
            }else {
                timeString += sec.toString();
            }
            score_txt.text = "Score: " + score + "\nKill: " + kill + "\nTime: " + timeString;
        }
        private function attackReleaseHandler(e:KeyboardEvent):void 
        {
            canAttack = true;
        }        
        private function attackHandler(e:KeyboardEvent):void 
        {
            var direction:int = -2;
            switch(e.keyCode) {
                case 37:
                    direction = -1;
                    break;
                case 38:
                    direction = 0;
                    break;
                case 39:
                    direction = 1;
                    break;
            }
            if(direction>=-1){
                if (canAttack) {
                    var hitSound:Boolean=true;
                    _soundTransform.volume = 1;
                    _soundTransform.pan = direction;
                    swing.play(0, 0, _soundTransform);
                    var origin:Point;
                    var vec:Point;
                    switch(direction) {
                        case -1:
                        origin = new Point(0, stage.stageHeight/2);
                        vec = new Point(stage.stageWidth * .1 + Math.random() * stage.stageWidth * .1, (Math.random()-.5) * stage.height * .2);
                        break;
                    case 0:
                        origin = new Point(stage.stageWidth/2, stage.height);
                        vec = new Point((Math.random()-.5) * stage.stageWidth * .1, -stage.height * .1-Math.random() * stage.height * .2);
                        break;
                    case 1:
                        origin = new Point(stage.stageWidth, stage.stageHeight/2);
                        vec = new Point(-stage.stageWidth * .1 - Math.random() * stage.stageWidth * .1, (Math.random()-.5) * stage.height * .2);
                        break;
                    }
                    slash.push([origin, vec, 1,[]]);
                    if (enemyInRange.length > 0) {
                        for (var i:int = 0; i < enemyInRange.length; i++) {                            
                            if (enemyInRange[i] == direction) {
                                enemyInRange.splice(i, 0);
                                kill++;
                                score += 100 + combo * 10;
                                combo++;
                                haveToKill = false;
                                if (hitSound) {
                                    hitSound = false;
                                    hit.play(0,0,_soundTransform);
                                    if (Math.random() < .5) {
                                        pain.play(0,0,_soundTransform);
                                    }
                                }
                            }
                        }
                    }
                    if (hitSound) {
                        combo = 0;
                        result.text = "";
                    }else{
                        switch(combo) {
                            case 1:
                                result.text = "Kill!";
                                break;
                            default:
                                result.text=combo.toString()+"x Combo Kill!!"
                                break;
                        }
                        clearEnemyTimer = -1;
                        enemyInRange = [];
                    }
                    canAttack = false;
                }
            }
        }        
        private function gameStep(e:Event):void 
        {
            if(stepDelay==0){
                var distance:Number = Math.random();
                var position:Number = (Math.random() - .5) * 2;
                if (distance >= .65) {
                    distance = 1;
                    position = Math.round(position);
                    if (position == 0) {
                        if (Math.random() > .25) {
                            if (Math.random() < .5) {
                                position = 1;
                            }else {
                                position = -1;
                            }
                        }
                    }
                    haveToKill = true;
                    enemyInRange.push(position);
                    clearEnemyTimer = 20;
                }else {
                    distance *= .1;
                }
                _soundTransform.volume = distance
                _soundTransform.pan = position
                step.play(0,0,_soundTransform);
                stepDelay = 30 + 20 * Math.random();
            }else {
                stepDelay--;
            }
            if (clearEnemyTimer == 0) {
                if (haveToKill) {
                    combo = 0;
                    result.text = "";
                    haveToKill = false;
                }
                enemyInRange = [];
            }
            gameScreen.graphics.clear();
            gameScreen.graphics.beginFill(0);
            gameScreen.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            gameScreen.graphics.endFill();            
            if (slash.length > 0) {                
                for (var i:int = 0; i < slash.length; i++) {
                    var data:Array = slash[i];
                    var origin:Point = data[0];
                    var vec:Point = data[1];
                    var _alpha:Number = data[2];
                    var lineData:Array = data[3];                    
                    if (_alpha > 0) {
                        data[2] = _alpha-.1;
                        data[0] = origin.add(vec);
                        vec.x *= .9;
                        vec.y *= .9;
                        data[1] = vec;
                        lineData.push(origin);
                        data[3] = lineData;
                        slash[i] = data;
                    }else {
                        if (lineData.length == 0) {
                            slash.splice(i, 1);
                        }else {
                            lineData.splice(0, 1);
                            data[3] = lineData;
                            slash[i] = data;
                        }
                    }
                    for (var j:int = 0; j < lineData.length; j++) {
                        gameScreen.graphics.lineStyle(3*j/lineData.length, 0xFFFFFF, _alpha);
                        var targetPo:Point = lineData[j];
                        if (j == 0) {
                            gameScreen.graphics.moveTo(targetPo.x, targetPo.y);
                        }else {
                            gameScreen.graphics.lineTo(targetPo.x, targetPo.y);
                        }
                    }
                }
            }
            clearEnemyTimer--;
            if (timer == 0) {
                topScore = Math.max(score, topScore);
                removeChild(gameScreen);
                addChild(mainMenu);
            }else {
                timer--;
                updateScoreTxt();
            }
        }
        private function buildMainMenu():void 
        {         
            var title:TextField = new TextField();
            title.defaultTextFormat = new TextFormat(null, 30, null, true, null, null, null, null, "center");
            title.text = "Blind Samurai";
            var startGameText:TextField = new TextField();
            title.defaultTextFormat = new TextFormat(null, null, null, true, null, null, null, null, "center");
            startGameText.text = "Start Game";
            topScore_txt.selectable=startGameText.selectable = title.selectable = false;
            startGameText.autoSize = title.autoSize = "center";
            topScore_txt.autoSize = "left";
            addChild(startGameText);
            startGameText.addEventListener(MouseEvent.CLICK, startTheGame);
            title.x = (stage.stageWidth - title.width) / 2;
            title.y = stage.stageHeight * .15;
            startGameText.x = (stage.stageWidth - startGameText.width) / 2;
            startGameText.y = stage.stageHeight * .5;
            mainMenu.addChild(title);
            mainMenu.addChild(startGameText);
            mainMenu.addChild(topScore_txt);
            mainMenu.addEventListener(Event.ADDED_TO_STAGE, updateTopScore);
        }        
        private function updateTopScore(e:Event):void 
        {
            topScore_txt.text = "Top Score: " + topScore;
        }
        private function startTheGame(e:MouseEvent):void 
        {
            removeChild(mainMenu);
            addChild(gameScreen);
        }
        private function gameReady():void {
            buildMainMenu();
            buildGameScreen();
            addChild(mainMenu);
        }

    }
}