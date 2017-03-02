// forked from checkmate's colin challenge for professionals
/**
 * Create a Flash app using Union Platform,
 * where you can collaborate with more than 4 people online.
 *
 * UnionRamen is an example app,
 * you can write code based on this, or build from scratch.
 *
 * UnionRamen is a multiuser bowl of ramen built on the Union Platform.
 * Press the 'n' key to add naruto to the bowl.
 * For Union Platform documentation, see www.unionplatform.com.
 * 
 * @author   Colin Moock
 * @date     July 2009
 * @location Toronto, Canada
 */
 /**
  * テノリオンのオンライン共有型で3Dで作ってみました。
  * ネット上の誰かが変更すると、その変更が反映されます。
  * 
  * 音 powered by SiONライブラリ
  * ネット共有 powered by Union プラットフォーム
  * 3D powered by Papervision3D
  */
  
package
{
    // Flash
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.utils.*;
    
    // Union
    import net.user1.reactor.*;
    import net.user1.logger.Logger;
    
    // SiON
    import org.si.sion.*;
    import org.si.sion.events.*;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.utils.SiONPresetVoice;
    
    // PV3D
    import org.papervision3d.core.proto.MaterialObject3D;
    import org.papervision3d.lights.PointLight3D;
    import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.events.InteractiveScene3DEvent;
    import org.papervision3d.materials.special.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.objects.special.*;
    
    [SWF(width = "465", height = "465", backgroundColor = "0", frameRate = 30)]
    
    public class Main extends Sprite
    {
        static private const USER_COLOR:uint = Math.random() * 0xFF0000;
        static private const MATRIX_NUM:int = 16;
        static private const DEF_COLOR:int = 0x555555;
        static private const ACTIVE_COLOR:int = 0xEEEEEE;
        static private const OVER_COLOR:int = 0x999999;
            
        //-----------------------------------
        // Union
        //-----------------------------------
        protected var reactor:Reactor;
        protected var room:Room;
        
        
        //-----------------------------------
        // SiON
        //-----------------------------------
        
        // driver
        public var driver:SiONDriver = new SiONDriver();
        
        // preset voice
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        
        // voices, notes and tracks
        public var tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>(16);
        public var voices:Vector.<int> = Vector.<int>([ 0, 1, 2, 3,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4]);
        public var notes:Vector.<int>  = Vector.<int>([36,48,60,72, 43,48,55,60, 65,67,70,72, 77,79,82,84]);
        
        // beat counter
        public var beatCounter:int;
        
        
        //-----------------------------------
        // PV3d
        //-----------------------------------
        private var world:BasicView = new BasicView(465, 465, false, true);
        private var light:PointLight3D = new PointLight3D();
        private var cubes:Array = [];
        private var logicMatrix:Array = [];
        private var oldDispMatrix:Array = [];
        private var dispMatrix:Array = [];
        private var rollOverMatrix:Array = [];
        
        
        /**
         * コンストラクタ
         */
        public function Main()
        {
            stage.quality = StageQuality.MEDIUM;
            
            setupUnion();
            setupPV3D();
            setupSiON();
            setupUI();
            
            Wonderfl.capture_delay( 10 );
        }
        
        //-----------------------------------
        // Union
        //-----------------------------------
        
        private function setupUnion():void
        {
            // 接続用のReactorオブジェクトを作成
            reactor = new Reactor();
            // 接続完了したら readyListener() を起動
            reactor.addEventListener(ReactorEvent.READY, readyListener);
            // Unionに接続。
            // "tryunion.com:9100"は自由に使えるUnionテスト用の公開サーバーです
            reactor.connect("tryunion.com", 9100);
            reactor.getLog().setLevel(Logger.DEBUG);
        }
        
        // 接続完了時に起動されるメソッド
        protected function readyListener (e:ReactorEvent):void
        {
            reactor.getMessageManager().addMessageListener("GIVE_ME_LOG", sendLog);
            reactor.getMessageManager().addMessageListener("THIS_IS_LOG", happyToReceiveLog);
            
            // このアプリ用のルームを作成
            room = reactor.getRoomManager().createRoom("wonderfl.clockmaker.tenorion");
            // 他ユーザーがこのルームに送信する"SOMEONE_CHANGE"メッセージを監視します
            room.addMessageListener("SOMEONE_CHANGE", changeCellHandler);
            room.addEventListener(RoomEvent.SYNCHRONIZE, onSynchronize);
            // ルームに入室
            room.join();
        }
        
        // invoked when received map from someone
        protected function happyToReceiveLog(from:IClient, data:String):void
        {
            trace(data);
            var arr:Array = data.split(",");
            
            for (var i:int = 0; i < arr.length; i++) 
            {
                var u:int = i % MATRIX_NUM;
                var v:int = Math.floor(i / MATRIX_NUM);
                
                logicMatrix[u][v] = arr[i];
            }
        }
        
        // send map to new comer
        protected function sendLog(from:IClient):void
        {
            var data:Array = [];
            for (var i:int = 0; i < logicMatrix.length; i++) 
                for (var j:int = 0; j < logicMatrix[i].length; j++) 
                    data.push(logicMatrix[i][j]);

            from.sendMessage("THIS_IS_LOG", data.join(","));
        }
        
        private function onSynchronize(e:RoomEvent):void 
        {
            if ( room.getClients().length == 1 ) {
                // 何もしない
            } else {
                var topClient:IClient = room.getClients()[0];
                topClient.sendMessage("GIVE_ME_LOG");
            }
        }
        
        protected function sendCellStatus (o:Object):void
        {
            // 未接続だったら何もしない
            if (!reactor.isReady()) return;
            room.sendMessage("SOMEONE_CHANGE", true, null, o.colorId, o.u, o.v);
        }

        // 他ユーザーの"ADD_NARUTO"メッセージ受信時に起動するメソッド
        protected function changeCellHandler (fromClient:IClient, colorId:uint, u:int, v:int):void
        {
            logicMatrix[u][v] = colorId;
        }
        
        
        
        //-----------------------------------
        // SiON
        //-----------------------------------
        
        private function setupSiON():void
        {
            driver.setVoice(0, presetVoice["valsound.percus1"]);  // bass drum
            driver.setVoice(1, presetVoice["valsound.percus28"]); // snare drum
            driver.setVoice(2, presetVoice["valsound.percus17"]); // close hihat
            driver.setVoice(3, presetVoice["valsound.percus23"]); // open hihat
            driver.setVoice(4, presetVoice["valsound.bass18"]);
            
            // listen click
            driver.setTimerInterruption(1, _onTimerInterruption);
            driver.setBeatCallbackInterval(1);
            driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
            driver.addEventListener(SiONEvent.STREAM_START, _onStreamStart);

            // start streaming
            driver.play();
        }
        
        // _onStreamStart (SiONEvent.STREAM_START) is called back first of all after SiONDriver.play().
        private function _onStreamStart(e:SiONEvent) : void
        {
            // create new controlable tracks and set voice
            for (var i:int=0; i<MATRIX_NUM; i++) {
                tracks[i] = driver.sequencer.newControlableTrack();
                tracks[i].setChannelModuleType(6, 0, voices[i]);
                tracks[i].velocity = 64;
            }
            beatCounter = 0;
        }
        
        
        // _onBeat (SiONTrackEvent.BEAT) is called back in each beat at the sound timing.
        private function _onBeat(e:SiONTrackEvent) : void 
        {
            //matrixPad.beat(e.eventTriggerID & 15);
            beat(e.eventTriggerID & MATRIX_NUM - 1);
        }
        
        
        // _onTimerInterruption (SiONDriver.setTimerInterruption) is called back in each beat at the buffering timing.
        private function _onTimerInterruption() : void
        {
            var beatIndex:int = beatCounter & (MATRIX_NUM - 1);
            for (var i:int = 0; i < MATRIX_NUM; i++)
            {
                if (logicMatrix[beatIndex][i] != DEF_COLOR)
                    tracks[i].keyOn(notes[i]);
            }
            
            beatCounter++;
        }
        
        
        
        //-----------------------------------
        // PV3d
        //-----------------------------------
        
        private function setupPV3D():void
        {
            addChild(world);
            world.startRendering();
            
            for (var i:int = 0; i < MATRIX_NUM; i++) 
            {
                cubes[i] = [];
                logicMatrix[i] = [];
                rollOverMatrix[i] = [];
                for (var j:int = 0; j < MATRIX_NUM; j++) 
                {
                    var material:MaterialObject3D = new FlatShadeMaterial(light, DEF_COLOR);
                    //var material:MaterialObject3D = new ColorMaterial(DEF_COLOR);
                    material.interactive = true;
                    var cube:Plane = new Plane(material, 70, 70);
                    cube.x = 80 * (i - MATRIX_NUM / 2);
                    cube.z = 80 * (j - MATRIX_NUM / 2);
                    cube.y = 100;
                    cube.extra = { u:i, v:j };
                    cube.rotationX = 90;
                    cube.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, cubeClickHandler);
                    world.scene.addChild(cube);
                    cubes[i][j] = cube;
                    logicMatrix[i][j] = DEF_COLOR;
                    rollOverMatrix[i][j] = false;
                }
            }
            
            // ついでにパーティクルを生成します(彗星)
            var particleMat:ParticleMaterial = new ParticleMaterial(0xFFFFFF, 1);
            var particles:ParticleField = new ParticleField(particleMat, 500, 5, 6000, 4000, 6000);
            particles.y = -150;
            world.scene.addChild( particles );
            
            dispMatrix = copyArray2(logicMatrix);
            oldDispMatrix = copyArray2(dispMatrix);
            
            // ライト
            light.x = 200;
            light.y = 400;
            light.z = 200;
            
            world.camera.zoom = 1;
            world.camera.focus = 400;
            
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function beat(beat16th:int):void 
        {
            for (var i:int = 0; i < dispMatrix.length; i++) 
            {
                for (var j:int = 0; j < dispMatrix[i].length; j++) 
                {
                    if (beat16th == i)
                    {
                        dispMatrix[i][j] = ACTIVE_COLOR;
                        
                        if (logicMatrix[i][j] != DEF_COLOR)
                            dispMatrix[i][j] = uint(logicMatrix[i][j] * 0x666666);
                    }
                    else
                    {
                        dispMatrix[i][j] = logicMatrix[i][j];
                    }
                    
                    if (rollOverMatrix[i][j]) dispMatrix[i][j] = OVER_COLOR;
                }
            }
            
            update();
        }
        
        private function cubeClickHandler(e:InteractiveScene3DEvent):void 
        {
            var u:int = e.target.extra.u;
            var v:int = e.target.extra.v;
            
            if (logicMatrix[u][v] == DEF_COLOR)
            {
                logicMatrix[u][v] = USER_COLOR;
                sendCellStatus( { colorId:USER_COLOR, u:u, v:v } );
            }
            else
            {
                logicMatrix[u][v] = DEF_COLOR;
                sendCellStatus( { colorId:DEF_COLOR, u:u, v:v } );
            }
            
            update();
        }
        
        private function update():void
        {
            var oldTime:Number = getTimer();
            for (var i:int = 0; i < dispMatrix.length; i++) 
            {
                for (var j:int = 0; j < dispMatrix[i].length; j++) 
                {
                    var c:Plane = cubes[i][j];
                    if (dispMatrix[i][j] != oldDispMatrix[i][j])
                    {
                        var material:MaterialObject3D = new FlatShadeMaterial(light, dispMatrix[i][j]);
                        material.interactive = true;
                        c.material = material;
                    }
                }
            }
            
            oldDispMatrix = copyArray2(dispMatrix);
            //trace((getTimer() - oldTime) / 1000);
        }
        
        private function copyArray2(arr:Array):Array
        {
            var r:Array = [];
            for (var i:int = 0; i < arr.length; i++) 
            {
                r[i] = arr[i].concat();
            }
            return r;
        }

        // アニメーション
        private var rot:Number = 45; // 角度
        private var pitch:Number = 500; // 高さ
        private function loop(e:Event):void
        {
            rot += 0.1;
            pitch = 500 * Math.sin(getTimer() / 2500) + 900;
            
            // 角度に応じてカメラの位置を設定
            world.camera.x = 1000 * Math.sin(rot * Math.PI / 180);
            world.camera.z = 1000 * Math.cos(rot * Math.PI / 180);
            world.camera.y = pitch;
        }
        
        private function setupUI():void
        {
            var bmp:Bitmap = new Bitmap(new BitmapData(10, 10, false, USER_COLOR));
            bmp.x = 10;
            bmp.y = 26;
            addChild(bmp);
            
            var txtFormat:TextFormat = new TextFormat();
            txtFormat.font = "Arial";
            
            var text1:TextField = new TextField();
            text1.selectable = false;
            text1.defaultTextFormat = txtFormat;
            text1.x = 8;
            text1.y = 6;
            text1.autoSize = "left";
            text1.htmlText = "<font color='#FFFFFF' size='14'>Online Share Tenorion</font>";
            addChild(text1);
            
            var text:TextField = new TextField();
            text.selectable = false;
            text.defaultTextFormat = txtFormat;
            text.x = 25;
            text.y = 24;
            text.htmlText = "<font color='#FFFFFF' size='9'>YOUR COLOR</font>";
            addChild(text);
            
            // BackGround Color
            var bgMatrix:Matrix = new Matrix();
            bgMatrix.rotate(90 * Math.PI / 180);
            graphics.clear()
            graphics.beginGradientFill("linear", [0x332244, 0x000000], [100, 100], [0, 255], bgMatrix);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        }
    }
}














