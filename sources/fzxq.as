/**
 * Copyright (c) 2011 - 2100 Sindney&Glidias
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package 
{
    import alternativ7.engine3d.animation.AnimationClip;
    import alternativ7.engine3d.animation.AnimationController;
    import alternativ7.engine3d.animation.AnimationSwitcher;
    import alternativ7.engine3d.core.Debug;
    import alternativ7.engine3d.core.Face;
    import alternativ7.engine3d.loaders.MaterialLoader;
    import alternativ7.engine3d.loaders.ParserCollada;
    import alternativ7.engine3d.objects.Joint;
    import alternativ7.engine3d.objects.Skin;

    import flash.system.LoaderContext;

    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import mx.utils.StringUtil;
    
    import alternativ7.engine3d.containers.ConflictContainer;
    import alternativ7.engine3d.controllers.SimpleObjectController;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.View;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.materials.Material;
    import alternativ7.engine3d.materials.TextureMaterial;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.primitives.Plane;
    import alternativ7.engine3d.objects.Mesh;
    
    import com.bit101.components.*
    
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * MS3D file watcher
     * @version 0.2
     * @date 2011/7/11 15:46
     * @author sindney
     * 
     * @version 0.35 - New version from MS3DWatcher.as . Uses minimal comps. 
     * Can load animations.
     * @date 2011/10/1 21:21
     * @author Glidias
     */
    [SWF(backgroundColor = 0x000000, frameRate = 40, width = 900, height = 500)]
    public class MS3DViewerAndParser extends Sprite {
        
        private const aboutInfo:String = "ParserMS3D (v.1.8.4 of MS3D) for alternativa3d v7.7.0 or v7.8.0\n\nLoad a model first and then load it's texture.\n\nAnimation support available. \n\nLicense: \nhttp://creativecommons.org/licenses/by-sa-nc/3.0/\n\nSource: \nhttp://sindney.com/blog";
        private const d90:Number = Math.PI / 2;
        
        private var scene:ConflictContainer;
        private var camera:Camera3D;
        private var controller:SimpleObjectController;
        private var defaultSkin:FillMaterial;
        private var plane:Plane;
        private var objects:Vector.<Mesh> = new Vector.<Mesh>();
        
        private var parser:ParserMS3D;
        private var data:ByteArray;
        private var bitmap:Bitmap;
        private var load:Loader;
        
        private var fileFilter:FileFilter = new FileFilter("MS3D (*.ms3d)", "*.ms3d");
        private var fileFilter1:FileFilter = new FileFilter("Image (jpg/gif/png)", "*.jpg;*.gif;*.png");
        private var fileReference:FileReference = new FileReference();
        private var loadFile:Boolean = false;
        private var loadTexture:Boolean = false;
        private var loadMS3D:Boolean = false;
        
        private var panel:Panel;
        private var content:VBox;
        private var loadModel:PushButton;
        private var loadSkin:PushButton;
        private var rotationFix:CheckBox;
        private var showPlane:CheckBox;
        private var about:PushButton;
        private var info:TextArea;
        
        private var mainAnimation:AnimationClip;
        private var animationSwitcher:AnimationSwitcher;
        private var animationController:AnimationController;
        private var groupBox:com.bit101.components.List;
        private var parseOption:ComboBox;
        private var baseURLField:InputText;
        
        
        public function MS3DViewerAndParser() {
            super();
            
            var comp:Component;
            
            stage.align = "TL";
            stage.scaleMode = "noScale";
            stage.quality = "Low";
            stage.showDefaultContextMenu = false;
            
            //TipBase.enabled = true;
            //TipBase.stage = stage;
            
            // 3d scene
            camera = new Camera3D();
            camera.view = new View(stage.stageWidth, stage.stageHeight);
            camera.diagramAlign = "left";
            addChild(camera.view);
            addChild(camera.diagram);
            
            scene = new ConflictContainer();
            defaultSkin = new FillMaterial(0xffffff, .5, 1, 0x0066ff);
            
            camera.rotationX = -120*Math.PI/180;
            camera.y = -200;
            camera.z = 100;
            controller = new SimpleObjectController(stage, camera, 100);
            scene.addChild(camera);
            
            plane = new Plane(200, 200, 4, 4, true);
            plane.setMaterialToAllFaces(new FillMaterial(0x000000, 0, 1, 0xffffff));
            scene.addChild(plane);
            
        //    camera.addToDebug(Debug.BONES, Skin);
            //camera.addToDebug(Debug.BONES, Joint);
        //    camera.debug = true;
            parser = new ParserMS3D();
            parser.devMode = true; // <- important for editor/viewer!
            load = new Loader();
    
            
            fileReference.addEventListener(Event.SELECT, function(e:Event):void {
                if (loadFile) {
                    fileReference.load();
                }
            });
            fileReference.addEventListener(Event.COMPLETE, function(e:Event):void {
                loadFile = false;

                if (loadMS3D) {
                    loadMS3D = false;
                    animationSwitcher = null;
                    animationController = null;
                    mainAnimation = null;
                    
                    data = fileReference.data;
                    info.text = parser.parse(data);
                    info.textField.appendText( parser.debug.text);
                    
                    if (parseOption.selectedIndex <= 0) {
                        objects = parser.objects;
                    }
                    else if (parseOption.selectedIndex == 1) {
                        objects = new <Mesh>[parser.getMesh()];
                    ///*
                    }
                    else {
                        objects = new <Mesh>[parser.getSkin()];
                        mainAnimation = parser.getMainAnimation();
                        mainAnimation.loop = true;
                        
                        animationSwitcher = new AnimationSwitcher();
                        animationSwitcher.addAnimation(mainAnimation);
                        animationSwitcher.activate(mainAnimation);

                        
                        animationController = new AnimationController();
                        animationController.root = animationSwitcher;
                    }
                    //*/
                                
                    showObjects();
                    
                }
                
                if (loadTexture) {
                    loadModel.enabled = loadSkin.enabled = loadTexture = false;
                    load.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                        info.textField.appendText("\nTexture Loaded.");
                        bitmap = (e.target as LoaderInfo).content as Bitmap;
                        if (_groupLoadIndex < 0) {
                            skinObjects();
                        }
                        else {
                            skinFaces();
                        }
                        loadModel.enabled = loadSkin.enabled = true;
                    });
                    load.loadBytes(fileReference.data);
                    return;
                }
                
            });
            
            content = new VBox(panel = new Panel(this, 0, 0));
            content.x = 3;
            panel.addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation);
                var hBox:HBox = new HBox(content);
                hBox.height = 20;
            new Label(hBox, 0, 0, "Load as:");
            parseOption = new ComboBox(hBox, 0, 0, "Mesh Groups", ["Mesh Groups", "Combined Mesh", "Animated Skin"]);
            
            loadModel = new PushButton(content, 0,0,"Load Model", onLoadModelClick);
            //loadModel.tip = "Load a ms3d model here.";
            //loadModel.showTip = true;
            loadSkin = new PushButton(content, 0,0,"Load Texture", onLoadSkinClick);
            //loadSkin.tip = "Load model's texture here.\nMake sure you've loaded a model first.\n * You may need to enable this file to read local data.";
            //loadSkin.showTip = true;
            hBox = new HBox(content);
            hBox.height = 20;
            rotationFix = new CheckBox(hBox, 0, 0, "Auto Rotate");
            rotationFix.selected =  true;
            //rotationFix.tip = "Rotate the model by 90 along x axis.\nSo that you'll get the same view as milkshape.";
            //rotationFix.showTip = true;
            rotationFix.addEventListener(MouseEvent.CLICK, function(e:Event):void {
            
                var boo:Boolean = rotationFix.selected;
                if (objects != null) {
                    var i:int, l:int = objects.length;
                    for (i = 0; i < l; i++) {
                        objects[i].rotationX = boo ? d90 : 0;    
                    }
                }
            });
            showPlane = new CheckBox(hBox, 0, 0, "Show Plane");
            showPlane.selected = true;
            showPlane.addEventListener(MouseEvent.CLICK, function(e:Event):void {
                var added:Boolean = scene.contains(plane);
                plane.visible = showPlane.selected;
            });
            
            
            about = new PushButton(content,0,0, "About", function(e:MouseEvent):void {
                info.text = aboutInfo;
            });
            content.width = loadModel.width = loadSkin.width = about.width = 200;
            info = new TextArea(content, 0, 0, "");
            info.editable = false;
            info.setSize(200, 400);
            info.text = aboutInfo;
            
            var vBox:VBox = new VBox(content);
            vBox.spacing = 5;
            
            hBox = new HBox(content);
            hBox.height = 20;
            new Label(hBox, 0, 0, "Groups:");
            new Label(hBox, 0, 0, "loadAllBaseUrl:");
            comp = baseURLField  = new InputText(hBox, 0, 0, "");
            comp.width = 88;
            groupBox = new com.bit101.components.List(content, 0, 0);
            groupBox.setSize(200, 60);
            
            
            hBox = new HBox(content);
            hBox.height = 20;
            comp = new PushButton(hBox, 0, 0, "Load All", onLoadAllClick);
            comp.width = 40;
            comp = new PushButton(hBox, 0, 0, "Load For Group", onLoadForGroupClick);
            comp.width = 75
            comp = new PushButton(hBox, 0, 0, "Load For File", onLoadForFileNameClick);
            comp.width = 70;
            onResize();
            
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(Event.RESIZE, onResize);
        }
        
        private function onLoadForFileNameClick(e:Event):void 
        {
        
            if (groupBox.selectedIndex < 0 || groupBox.selectedItem.matName == null) return;
            _fileLoadName = groupBox.selectedItem.matName;
            fileReference.browse([fileFilter1]);
            setState(true, false, true);
        
            
            _groupLoadIndex = groupBox.selectedIndex;
        }
        
        private var _fileLoadName:String;
        private var _groupLoadIndex:int = -1;
        private function onLoadForGroupClick(e:Event):void 
        {
            
            ///*
            if (groupBox.selectedIndex < 0) return;
            _fileLoadName = null;
            fileReference.browse([fileFilter1]);
            setState(true, false, true);
        
            
            _groupLoadIndex = groupBox.selectedIndex;
            
            //objects[_groupLoadIndex].setMaterialToAllFaces( defaultSkin);
            
            
            //*/
        }
        private function setState(file:Boolean=false, model:Boolean=false, texture:Boolean = false):void {
            loadFile = file;
            loadMS3D = model;
            loadTexture = texture;
        }
        
        
        
        private function onLoadAllClick(e:Event):void 
        {
            parser.urlPrefix = baseURLField.text;
            parser.loadTextureMaterials(onLoadMaterialsComplete, new LoaderContext(true) );
        }
        
        private function onLoadMaterialsComplete(e:Event):void 
        {
            parser._bindMaterials(objects);
        }
        
        private function stopPropagation(e:Event):void 
        {
            e.stopPropagation();
        }
        
    
        
        private function vecToArray(vec:*):Array {
            var len:int = vec.length;
            var arr:Array = [];
            for (var i:int = 0; i < len; i++) {
                arr.push(vec[i]);
            }
            return arr;
        }
        private function onLoadModelClick(e:MouseEvent):void {
            _groupLoadIndex = -1;
            fileReference.browse([fileFilter]);
            setState(true, true);
            data = null;
            info.text = "";
            clearScene();
        }
        
        private function onLoadSkinClick(e:MouseEvent):void {
            _groupLoadIndex = -1;
            fileReference.browse([fileFilter1]);
            setState(true, false, true);
            /*
            if (bitmap != null) {
                if (objects != null) {
                    var i:int, l:int = objects.length;
                    for (i = 0; i < l; i++) {
                        var tmp:Mesh = objects[i] as Mesh;
                        tmp.setMaterialToAllFaces(defaultSkin);
                    }
                }
                bitmap.bitmapData.dispose();
                bitmap = null;
            }
            */
        }
        
        private function showObjects():void {
            var i:int, l:int = objects.length;
            var mat:Material = bitmap == null ? defaultSkin : new TextureMaterial(bitmap.bitmapData)
            for (i = 0; i < l; i++) {
                var tmp:Object3D = objects[i];
                if (rotationFix) tmp.rotationX = d90;
                (tmp as Mesh).setMaterialToAllFaces(mat);
                scene.addChild(tmp);
            }
            
            groupBox.removeAll();
            groupBox.items = vecToArray(parser.groups)
        }
        
        private function clearScene():void {
            if (objects == null) return;
            var i:int, l:int = objects.length;
            for (i = 0; i < l; i++) {
                var tmp:Object3D = objects[i];
                scene.removeChild(tmp);
                tmp = null;
            }
            objects = new Vector.<Mesh>();
            if (bitmap != null) {
                bitmap.bitmapData.dispose();
                bitmap = null;
            }
        }
        
        private function skinObjects():void {
            if (objects == null || objects.length == 0) return;
            var i:int, l:int = objects.length;
            var mat:TextureMaterial = new TextureMaterial(bitmap.bitmapData);
            
        
            for (i = 0; i < l; i++) {
                var tmp:Mesh = objects[i] as Mesh;
                tmp.setMaterialToAllFaces(mat);
            }
            
        }
        
        private function skinFaces():void {
            parser._skinFaces(objects, bitmap.bitmapData, _groupLoadIndex, _fileLoadName, _fileLoadName!= null);
            
        }
        
        private function onEnterFrame(e:Event):void {
        
            if (animationController) {
                animationController.update();
            }
            controller.update();
            camera.render();
        }
        
        private function onResize(e:Event = null):void {
            camera.view.width = stage.stageWidth - 210;
            camera.view.height = stage.stageHeight;
            panel.move(camera.view.width, 0);
            panel.setSize(210, camera.view.height);
            info.setSize(200, panel.height - 375);
            content.draw();
        }
        
    }

}

/**
 * Copyright (c) 2011 - 2100 Sindney&Glidias
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
//package alternativa.engine3d.parsers
//{
    import alternativ7.engine3d.animation.AnimationClip;
    import alternativ7.engine3d.animation.keys.Keyframe;
    import alternativ7.engine3d.animation.keys.Track;
    import alternativ7.engine3d.animation.keys.TransformTrack;
    import alternativ7.engine3d.core.Face;
    import alternativ7.engine3d.core.Wrapper;
    import alternativ7.engine3d.loaders.MaterialLoader;
    import alternativ7.engine3d.loaders.ParserCollada;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.materials.Material;
    import alternativ7.engine3d.materials.TextureMaterial;
    import alternativ7.engine3d.objects.Joint;
    import alternativ7.engine3d.objects.Skin;
    import flash.display.BitmapData;

    import flash.events.Event;
    import flash.system.LoaderContext;

    import flash.geom.Vector3D;
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Vertex;
    import alternativ7.engine3d.objects.Mesh;
    
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * ParserMS3D for alternativa3d v7.8.0
     * 
     * @version 0.2
     * @date 2011/7/14 21:21
     * @author sindney
     * 
     * @version 0.3  - Animation support provided for v1.8.4 of Milkshape3D
     * @date 2011/10/1 21:21
     * @author Glidias
     */
    class ParserMS3D {
        
        public var objects:Vector.<Mesh>;  // MS3d mesh groups.
        public var debug:Object = { text:"" };
        
        public var animations:Vector.<AnimationClip>;
        public function getMainAnimation():AnimationClip {
            return animations != null && animations.length > 0 ? animations[0] : null;
        }
        
        private var _animFPS:Number;
        public function get animFPS():Number { return _animFPS; }
        private var _animTotalFrames:int;
        public function get animTotalFrames():Number { return _animTotalFrames; }
        public function get animTotalDurationSec():Number { return _animTotalFrames / _animFPS };
        public function get animIntendedSpeed():Number { return animTotalDurationSec / _animTotalFrames };
        
        private var textureURLS:Vector.<String>;
        
        public function get urlPrefix():String 
        {
            return _urlPrefix;
        }
        
        public function set urlPrefix(value:String):void 
        {
            
            _urlPrefix = value;
            if (textureMaterials == null) return;
            var i:int = textureMaterials.length;
            while ( --i > -1) {
                textureMaterials[i].diffuseMapURL = value+textureURLS[i];
            }
            
        }

        public var materials:Vector.<Material> ; 
        public var textureMaterials:Vector.<TextureMaterial> ; 
        public static var DEFAULT_MATERIAL:Material;
        private function getDefaultMaterial():Material {
            return DEFAULT_MATERIAL || (DEFAULT_MATERIAL =  new FillMaterial(0xffffff, .5, 1, 0x0066ff));
        }
        private var _jointList:Vector.<Joint>;
        private var _transformTracks:Vector.<TransformTrack>;
        private var _vertices:Vector.<Vertex>;
        public var groups:Vector.<MS3DGroup>;
        
        public var devMode:Boolean=false;   // this flag indicates whether to identify faces by their MS3D groups + MS3D materials via FaceInfo
        private var _urlPrefix:String = "";
        
        public function loadTextureMaterials(completeHandler:Function = null, context:LoaderContext = null):MaterialLoader {
            if (textureMaterials == null || textureMaterials.length == 0 ) return null;
            var matLoader:MaterialLoader = new MaterialLoader();
            if (completeHandler != null) matLoader.addEventListener(Event.COMPLETE, completeHandler);
            matLoader.load(textureMaterials, context);
            //throw new Error(textureMaterials[0].diffuseMapURL);
            return matLoader;
        }
        
        public function getSkin(looping:Boolean=false):Skin {  // create skin from exisitng mesh groups, bind vertices to current jointList, transformTrack, and links skin to use animationClips with the transformtrack
            var i:int; var len:int;
            var count:int;
            
            var skin:Skin = getCombinedMesh(Skin, objects) as Skin;
            var joint:Joint;
            

            // Add joints
            len = _jointList.length;
            count = 0;
            for (i = 0; i < len; i++) {
                joint = _jointList[i];
                if (joint._parentJoint == null) {
                    skin.addJoint(joint); 
                    count++;
                }
            }
                
            // Bind vertices to joints
            for (var v:Vertex = skin.vertexList; v != null; v = v.next) {
                var b:VertexBindingToBone;
                for ( b = v.id as VertexBindingToBone;  b != null; b = b.next) {
                    b.bone.bindVertex(v, b.weight);
                }
            }
        
            // Setup
            skin.calculateBindingMatrices();
            
        
            var anim:AnimationClip = animations[0];
            anim.time = 0;
            anim.speed =  animIntendedSpeed * 16;
            anim.attach(skin, true);  // include descendants,, i guess
            
            return skin;
        }
        public function getMesh():Mesh {  // combines all mesh groups into a singular mesh!
            return getCombinedMesh(Mesh, objects);
        }
        /*
        public function getNewSkinOf(groups:Vector.<Mesh>, looping:Boolean=false):Skin { // creates duplicate Joints/TransformTracks and AnimationClip for a new vertex binded model parsed with ParserMS3D (using objects property) to create a new Skin instance (this is great for reusing the animation data on one model.
            return null;
        }
        */
        
        
        
        public function _bindMaterials(objects:Vector.<Mesh>):void {
            var num_groups:int = objects.length;
            var i:int;
            var f:Face;
            for (i = 0; i < num_groups; i++) {
                f = objects[i].faceList;
                while ( f != null) {
                    var indexer:int = f.id is FaceInfo ? (f.id as FaceInfo).materialIndex : f.id as int;
                    f.material =indexer >=0 ? materials[indexer] : null;
                    f = f.next;
                }
            }
        }
        
        public function _skinFaces(objects:Vector.<Mesh>, bitmapData:BitmapData, groupIndex:int, fileName:String = null, applyAllWithSameFileName:Boolean=false):void   //, 
        {
            var num_groups:int = objects.length;
            var i:int;
            var f:Face;
            
            var textureMat:TextureMaterial = fileName == null ? new TextureMaterial(bitmapData) : getMaterialByFileName(fileName, bitmapData);
            
            for (i = 0; i < num_groups; i++) {
                f = objects[i].faceList;
                while ( f != null) {
                    var indexer:int = f.id is FaceInfo ?  (f.id as FaceInfo).groupIndex : i;
                    if (indexer == groupIndex || (applyAllWithSameFileName&& groups[indexer].matName === fileName) ) {
                        f.material = textureMat;
                    }
                    f = f.next;
                }
            }
        }
        
        private function getMaterialByFileName(arg1:String, bitmapData:BitmapData):TextureMaterial 
        {
            var len:int = textureURLS.length;
            for (var i:int = 0; i < len; i++) {
                
                if (textureURLS[i] === arg1) {
                    textureMaterials[i].texture = bitmapData;
                    return textureMaterials[i];
                }
            }
            throw new Error("Could not find material by filename:" + arg1);
            return null;
        }
        
        
    
        
        private function getCombinedMesh(classe:Class, groups:Vector.<Mesh>):Mesh {
            var mesh:Mesh = new classe();
            var len:int;
            var i:int;
            var group:Mesh ;
            var v:Vertex; var f:Face; var w:Wrapper;

            var count:int;
            const verticesToDraw:Vector.<Vertex> = new Vector.<Vertex>();
        
            const vertexBuffer:Vector.<Vertex> = new Vector.<Vertex>();
    
            
            var newV:Vertex;
            var newF:Face;
            len = groups.length;
            for (i = 0; i < len; i++) {
                group = groups[i];
                
                // setup new vertex list
                count = 0;
                for (v = group.vertexList; v != null; v = v.next) {
                    newV = mesh.addVertex(v.x, v.y, v.z, v.u, v.v, _vertices[v.index].id);
                    newV.index = count;
                    v.index = count;
                    vertexBuffer[count] = newV;
                    count++;
                }

            
                // setup new face list 
                var materialIndex:int = group.faceList.id as int;
                for (f = group.faceList; f != null; f = f.next) {
                    count = 0;
                    for (w = f.wrapper; w != null; w = w.next) {
                        verticesToDraw[count++] = vertexBuffer[w.vertex.index];
                    }

                    verticesToDraw.length = count;
                    newF = mesh.addFace(verticesToDraw, f.material, devMode ? new FaceInfo(i, materialIndex) : f.id );
                }
            }
            
            mesh.calculateFacesNormals();
            mesh.calculateVerticesNormals();
            mesh.calculateBounds();
            
            return mesh;
        }
        
        public function ParserMS3D() {
            
            
        }
        
        public function getObjectByName(name:String):Object3D {
            if (objects != null) {
                var i:int, l:int = objects.length;
                var target:Object3D;
                for (i = 0; i < l; i++) {
                    target = objects[i];
                    if (target.name == name) return target;
                }
            }
            return null;
        }
        
        private function _findJointByName(name:String):Joint {
            var i:int = _jointList.length;
            while ( --i > -1) {
                var peekArr:Array = _jointList[i].name.split(">");
                if (peekArr[peekArr.length-1] === name) {
                    return _jointList[i];
                }
            }
            return null;
        }
        
        
        /**
         * Parse a given model.
         * @param    data Model's source.
         * @return Model's information.<p>NumVertices, NumTriangles, NumGroups</p>
         */
        public function parse(data:ByteArray):String {
            // init
            animations = new Vector.<AnimationClip>();
            textureURLS = new Vector.<String>();            
            _jointList = new Vector.<Joint>();
            _transformTracks = new Vector.<TransformTrack>();
            materials = new Vector.<Material>();
            textureMaterials = new Vector.<TextureMaterial>();
            groups = new Vector.<MS3DGroup>();
            
            debug.text = "\n\n////////";
            
            var i:int, j:int, char:int;
            var int0:int, int1:int, int2:int;
            var num0:Number, num1:Number;
            
            var version:int
            var bool:Boolean;
            var id:String = "";
            var name:String = "";
            var parent_name:String = "";
            
            // read header
            data.endian = Endian.LITTLE_ENDIAN;
            data.position = 0;
            for (i = 0; i < 10; i++) {
                char = data.readUnsignedByte();
                id += String.fromCharCode(char);
            }
            if (id != "MS3D000000" ) throw new Error("Error loading MS3D file: Not a valid MS3D file");
            if (data.readInt() != 4) throw new Error("Error loading MS3D file: Bad version");
            
            // read vertices
            var num_vertices:int = data.readUnsignedShort();
            var vertices:Vector.<Vertex> = new Vector.<Vertex>(num_vertices, true);
            _vertices = vertices;
            for (i = 0; i < num_vertices; i++) {
                // flag
                if (data.readUnsignedByte() != 2) {
                    var tmp:Vertex = new Vertex();
                    // position
                    tmp.x = data.readFloat();
                    tmp.y = data.readFloat();
                    tmp.z = data.readFloat();
                    // bone -1 no bone
                    tmp.id = data.readByte(); // this would later become VertexBindingToBone reference
                    // refCount
                    data.readUnsignedByte();
                    tmp.index = i;
                    vertices[i] = tmp;
                }
            }
            
            
            // read triangles
            var num_triangles:int = data.readUnsignedShort();
            var faceIndices:Vector.<int> = new Vector.<int>();
            var uvs:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
            var v1:Vertex, v2:Vertex, v3:Vertex;
            for (i = 0, j = 0; i < num_triangles; i++, j += 3) {
                // flag
                if (data.readUnsignedShort() != 2) {
                    faceIndices[j] = data.readUnsignedShort();
                    faceIndices[j + 1] = data.readUnsignedShort();
                    faceIndices[j + 2] = data.readUnsignedShort();
                    v1 = vertices[faceIndices[j]];
                    v2 = vertices[faceIndices[j + 1]];
                    v3 = vertices[faceIndices[j + 2]];
                    v1.normalX = data.readFloat();
                    v1.normalY = data.readFloat();
                    v1.normalZ = data.readFloat();
                    v2.normalX = data.readFloat();
                    v2.normalY = data.readFloat();
                    v2.normalZ = data.readFloat();
                    v3.normalX = data.readFloat();
                    v3.normalY = data.readFloat();
                    v3.normalZ = data.readFloat();
                    uvs[j] = new Vector.<Number>(2, true);
                    uvs[j + 1] = new Vector.<Number>(2, true);
                    uvs[j + 2] = new Vector.<Number>(2, true);
                    uvs[j][0] = data.readFloat();
                    uvs[j + 1][0] = data.readFloat();
                    uvs[j + 2][0] = data.readFloat();
                    uvs[j][1] = data.readFloat();
                    uvs[j + 1][1] = data.readFloat();
                    uvs[j + 2][1] = data.readFloat();
                    // smoothGroup
                    data.readUnsignedByte();
                    // groupIndex
                    data.readUnsignedByte();
                }
            }
            
            
            
            // read groups
            var num_groups:int = data.readUnsignedShort();
            
            objects = new Vector.<Mesh>(num_groups, true);
            for (i = 0; i < num_groups; i++) {
                // flag
                int0 = data.readUnsignedByte();
                // name
                var mesh:Mesh = new Mesh(); 
                mesh.name = "";
                for (j = 0; j < 32; j++) {
                    char = data.readUnsignedByte();
                    mesh.name += char != 0 ?  String.fromCharCode(char) : "";
                    
                }
                // numtriangles
                int0 = data.readUnsignedShort();
                //int1 = int0 / 2; // <- what's this for?
                // triangles
                var v4:Vertex, v5:Vertex, v6:Vertex;
            
    
                for (j = 0; j < int0; j++) {
                    int1 = data.readUnsignedShort() * 3;
                    v1 = vertices[faceIndices[int1]];
                    v2 = vertices[faceIndices[int1 + 1]];
                    v3 = vertices[faceIndices[int1 + 2]];
                    v4 = mesh.addVertex(v1.x, v1.y, v1.z, uvs[int1][0], uvs[int1][1]);    
                    v5 = mesh.addVertex(v2.x, v2.y, v2.z, uvs[int1 + 1][0], uvs[int1 + 1][1]);
                    v6 = mesh.addVertex(v3.x, v3.y, v3.z, uvs[int1 + 2][0], uvs[int1 + 2][1]);
                    v4.normalX = v1.normalX;
                    v4.normalY = v1.normalY;
                    v4.normalZ = v1.normalZ;
                    v5.normalX = v2.normalX;
                    v5.normalY = v2.normalY;
                    v5.normalZ = v2.normalZ;
                    v6.normalX = v3.normalX;
                    v6.normalY = v3.normalY;
                    v6.normalZ = v3.normalZ;
                    
                     mesh.addTriFace(v4, v5, v6);
                    
                    
                    v4.index = v1.index;
                    v5.index = v2.index;
                    v6.index = v3.index; 
                    v1.u = v4.u; v1.v = v4.v;
                    v2.u = v5.u; v2.v = v5.v;
                    v3.u = v6.u; v3.v = v6.v;
                }
                
                // material index
            
                //var lastCount:int = mesh.vertices.length;
                mesh.weldVertices();
                //throw new Error(mesh.vertices.length + ", " + lastCount);
                    int2 = data.readUnsignedByte(); 
                
                objects[i] = mesh;
                    
                mesh.calculateFacesNormals();
                mesh.calculateBounds();
                
                for (var f:Face = mesh.faceList; f != null; f=f.next ) {
                    f.id = int2;
                }
                
                debug.text += "\nName: " + mesh.name + "\nNumTriangles:" + int1 + "\nMaterial Index: " + int2 + "\n";
                
            }
            
        
                 // read materials
            var num_materials:uint = data.readUnsignedShort();
 
            debug.text += "\n\n///////////////////////////////////\n// Materials \n///////////////////////////////////\n\n";
            debug.text += "Total: " + num_materials + "\n";
 
            var url:String;
            var textureMaterial:TextureMaterial;
            
            for (i = 0; i < num_materials; i++) {
                textureMaterial = null;
                url = "";
                // name
                name = "";
                for (j = 0; j < 32; j++) {
                    char = data.readUnsignedByte();
                    name += char != 0 ? String.fromCharCode(char) : "";
                }
                
                // ambient   
                for (j = 0; j < 4; j++) {
                    data.readFloat();
                }
                // diffuse
                for (j = 0; j < 4; j++) {
                    data.readFloat();
                }
                // specular
                for (j = 0; j < 4; j++) {
                    data.readFloat();
                }
                // emissive
                for (j = 0; j < 4; j++) {
                    data.readFloat();
                }
                // shininess 0 - 128
                num0 = data.readFloat();
                // transparency 0 - 1
                num1 = data.readFloat();
                // mode 0, 1, 2 is unused now
                int0 = data.readUnsignedByte();
                // texture
                
                
                // Only texture materials supported at the moment
                
                bool = true;
                for (j = 0; j < 128; j++) { 
                    char = data.readUnsignedByte();
                    if (char == 63) bool = false;  // 63 is "?" mark character to denote end of url
                    url +=  bool && char != 0 ?  String.fromCharCode(char) : "";
                }
            
                
                if (url != "") {
                    url = urlPrefix + url;
                    url = url.slice(0,url.length -1); // trim invisible string at end!?
                    textureMaterial = new TextureMaterial();
                    textureMaterial.diffuseMapURL = url;
                }
                
                // alphamap
                bool = true;
                url = "";
                for (j = 0; j < 128; j++) { 
                    char = data.readUnsignedByte();
                    if (char == 63) bool = false;
                    url +=  bool && char != 0 ?  String.fromCharCode(char) : "";
                }
                if (false &&  url != "" && textureMaterial != null) {  // currently disabled..buggy due to putput url
                    url = urlPrefix + url;
                    textureMaterial.opacityMapURL = url;
                }
            
                
                debug.text += "\nName: " + name + "\n";
                
                if (textureMaterial != null) {
                    textureMaterials.push(textureMaterial);
                    textureURLS.push(textureMaterial.diffuseMapURL);
                    materials.push(textureMaterial);
                    textureMaterial.name = name;
                }
                else materials.push( getDefaultMaterial() );
            }
            
            
            for (i = 0; i < num_groups; i++) {
                f = objects[i].faceList;
                f.material = f.id != null && f.id >= 0 ? materials[f.id] : null;
                //if (f.material == null) throw new Error("WH?"+f.id);
                groups.push( new MS3DGroup( (f.material is TextureMaterial) ? (f.material as TextureMaterial).diffuseMapURL : null, objects[i].name, f.id as int) );
                f = f.next;
                while ( f != null) {
                    f.material = f.id!=null && f.id >=0 ? materials[f.id] : null;
                    f = f.next;
                }
            }
            
            var num2:Number;
            var num3:Number;
            var num4:Number;
            var num5:Number;
        
            // read keyframer data
            var anim_fps:Number = data.readFloat(); _animFPS = anim_fps;
            var anim_currenttime:Number = data.readFloat();
            var anim_frames:int = data.readInt();  _animTotalFrames = anim_frames;
            var keyFramesToAdd:Vector.<KeyFramesForBone> = new Vector.<KeyFramesForBone>();
            var num_joints:int = data.readUnsignedShort();
        
            debug.text += "\nAnimation\n";
            debug.text += "FPS: " + anim_fps + " CurrentTime: " + anim_currenttime + " Frames: " + anim_frames;
 
            var joint:Joint;
            var track:TransformTrack;
            var animClip:AnimationClip = new AnimationClip();

            
            // matrix
            for (i = 0; i < num_joints; i++) {  // Start creation of joints
                // flag
                joint = new Joint();
                _jointList.push(joint);
                int0 = data.readUnsignedByte();
                // name
                name = "";
                for (j = 0; j < 32; j++) {
                    char = data.readUnsignedByte();
                    name += char != 0 ?  String.fromCharCode(char) : "";
                }
                
                // parent name
                parent_name = "";
                for (j = 0; j < 32; j++) {
                    char = data.readUnsignedByte();
                    parent_name += char!=0 ? String.fromCharCode(char) : ""
                }
                joint.name = parent_name != "" ? parent_name + ">" + name : name;
                
                // local reference matrix
                // rotation
                num0 = data.readFloat(); 
                num1 = data.readFloat();
                num2 = data.readFloat();
                // position
                num3 = data.readFloat();
                num4 = data.readFloat();
                num5 = data.readFloat();
                
                joint.rotationX = num0;
                joint.rotationY = num1;
                joint.rotationZ = num2;
                //throw new Error( new Vector3D(num0, num1, num2) );
            
                joint.x = num3;
                joint.y = num4;
                joint.z = num5;
                
                //var jointMatrix:Matrix3D = new Matrix3D();
                //jointMatrix.appendRotation( joint.rotationZ, new Vector3D(0, 0, 1) );
                //jointMatrix.appendRotation( joint.rotationY, new Vector3D(0, 0,1) );
                //jointMatrix.appendRotation( joint.rotationX, new Vector3D(1, 0, 0) );
                //jointMatrix.appendTranslation( joint.x, joint.y, joint.z);
                //joint.matrix = jointMatrix;
 
                // numKeyFramesRot
                int1 = data.readUnsignedShort();
                // numKeyFramesTrans
                int2 = data.readUnsignedShort();
                
                //throw new Error(int2);
 
                track = int1 > 0 || int2 > 0 ? new TransformTrack(name) : null;
                if (track != null) {  // ********Start track creation branch
            
                
                var arrKeyFrames:Array = [];
            
                
                // local animation matrices
                // rotation in angle
                for (j = 0; j < int1; j++) {
                    // time in second
                    num0 = data.readFloat();
                    // rotation x,y,z
                    num1 = data.readFloat();
                    num2 = data.readFloat();
                    num3 = data.readFloat();

                    arrKeyFrames.push( new MyKeyFrame(num0, num1, num2, num3, false, joint) );
                    
                }
                // position
                for (j = 0; j < int2; j++) {
                    // time in second
                    num0 = data.readFloat();
                    // position x,y,z
                    num1 = data.readFloat();
                    num2 = data.readFloat();
                    num3 = data.readFloat();
                    
                    arrKeyFrames.push( new MyKeyFrame(num0, num1, num2, num3, true, joint) );
                }
            
                ///* 
                var lastKeyFrame:MyKeyFrame = null;
                var vecKeyFrames:Vector.<MyKeyFrame> = new Vector.<MyKeyFrame>();
                arrKeyFrames.sortOn("_time", Array.NUMERIC);
                int1 = arrKeyFrames.length;
                
                
                for ( j = 0; j < int1; j++) {
                    var myKeyFrame:MyKeyFrame =  arrKeyFrames[j] as MyKeyFrame;
    
                    ///*
                    if (lastKeyFrame != null && myKeyFrame._time == lastKeyFrame._time) {
                        
                        if (myKeyFrame._translation == lastKeyFrame._translation) {
                            throw new Error("SHould not be. Should alternate rotaiton and translation!");
                        }
                    
                        lastKeyFrame.mergeWithOther(myKeyFrame);
                    }
                    else {
                        myKeyFrame.mergeWithJoint();
                        vecKeyFrames.push(myKeyFrame);
                    }
                
                
                    lastKeyFrame = myKeyFrame;
                }
            
            
                
                var keyFrameForBone:KeyFramesForBone = new KeyFramesForBone();
                keyFrameForBone.bone = joint;
                keyFrameForBone.track = track;
                keyFrameForBone.keyFrames = vecKeyFrames;
                keyFramesToAdd.push( keyFrameForBone);
                
            
                //*/
                    
                
                } // ****End track creation branch
                
    
                debug.text += "\n"+i+". Joint: " + name + "./" + "Parent: " + parent_name;
            }  // End creation of joints
            
                
    
            // setup joint hierachy
            var rootJ:Joint;
            for (i = 0; i < num_joints; i++) {
                joint = _jointList[i];
                arrKeyFrames = joint.name.split(">");
                if (arrKeyFrames.length > 1) {
                    joint._parentJoint =  _findJointByName(arrKeyFrames[0]);
                    if (joint._parentJoint == null) throw new Error("Couldn't find parent joint:" + arrKeyFrames[0]);
                     joint.name = arrKeyFrames[1];
                     joint._parentJoint.addChild( joint);
                }
                else {
                    rootJ = joint;
                }
            }
            
            debug.text += "\n"+ getJointXML(rootJ).toXMLString();
            
            int0 = keyFramesToAdd.length;
            for ( i = 0; i < int0; i++) {
                keyFrameForBone = keyFramesToAdd[i];
                vecKeyFrames = keyFrameForBone.keyFrames;
                int1 = vecKeyFrames.length;
                track =keyFrameForBone.track;
                joint = keyFrameForBone.bone;

                for (j = 0; j < int1; j++) {
                        myKeyFrame = vecKeyFrames[j];
                //    if (j == 0) throw new Error(new Vector3D(myKeyFrame._rotationX, myKeyFrame._rotationY, myKeyFrame._rotationZ) );
                    var keyMatrix:Matrix3D = joint.matrix;
                    keyMatrix.prependTranslation( myKeyFrame.x, myKeyFrame.y, myKeyFrame.z);                
                    keyMatrix.prependRotation(  myKeyFrame.rotationZ * 180 / Math.PI, new Vector3D(0, 0, 1), new Vector3D() );
                    keyMatrix.prependRotation(  myKeyFrame.rotationY*180/Math.PI, new Vector3D(0, 1,0),new Vector3D());
                    keyMatrix.prependRotation( myKeyFrame.rotationX*180/Math.PI, new Vector3D(1, 0, 0),new Vector3D() );
                    

                    track.addKey(myKeyFrame._time, keyMatrix);
                      //track.addKeyComponents( myKeyFrame._time, joint.x + myKeyFrame.x, joint.y + myKeyFrame.y, joint.z + myKeyFrame.z, joint.rotationX+myKeyFrame.rotationX, joint.rotationY + myKeyFrame.rotationY, joint.rotationZ + myKeyFrame.rotationZ);
                    }
                    _transformTracks.push(track);
                     animClip.addTrack(track);
    
            }
            if (animClip.numTracks > 0) {
                animations.push(animClip);
            }
            
            
            
            debug.text += "\Bytes Left:" + data.position + "/" + data.length;
            
            // subversion
            if (data.position < data.length) {
                version = data.readInt();
                debug.text += "\n\nSubversion: " + version + "\n";
                
                // group comments
                int0 = data.readInt();
                for (i = 0; i < int0; i++) {     //ms3d_comment_t
                    //throw new Error("GOt comment!");
                    int1 = data.readInt();  // index
                    int2 = data.readInt(); //commentLength
                    for (j = 0; j < int2; j++) {
                        data.readUnsignedByte();
                        
                    }
                }
                // material comments
                int0 = data.readInt();
                for (i = 0; i < int0; i++) {  // ms3d_comment_t
                    //throw new Error("GOt comment!");
                    int1 = data.readInt();  // index
                    int2 = data.readInt(); //commentLength
                    for (j = 0; j < int2; j++) {
                        data.readUnsignedByte();
                    }
                }
                // joint  comments
                int0 = data.readInt();
                for (i = 0; i < int0; i++) {  // ms3d_comment_t
                    //throw new Error("GOt comment!");
                    int1 = data.readInt();  // index
                    int2 = data.readInt(); //commentLength
                    for (j = 0; j < int2; j++) {
                        data.readUnsignedByte();
                    }
                }
                
                // MODEL Commenets
                // model  comments  (no index being used!)
                int0 = data.readInt();
                for (i = 0; i < int0; i++) {  // ms3d_comment_t
                    //throw new Error("GOt comment!");
                    int2 = data.readInt(); //commentLength
                    for (j = 0; j < int2; j++) {
                        data.readUnsignedByte();
                    }
                }
                
        
                // Vertex extra info part
                
                version = data.readInt();
                debug.text += "\n\nSubversion weights: " + version + "\n";

                var weights:Vector.<int> = new Vector.<int>();
                var boneIds:Vector.<int> = new Vector.<int>();
                num0 = version == 2 ? 100 : 255;  // weight divider
                num0 = 1 / num0;
                for (i = 0; i < num_vertices; i++) {
                    /*
                                    char boneIds[3];                                    
                    // index of joint or -1, if -1, then that weight is ignored, since subVersion 1
                byte weights[3];                                    // vertex weight ranging from 0 - 255 (or 0-100) if version==2, last weight is computed by 1.0 - sum(all weights), since subVersion 1
                // weight[0] is the weight for boneId in ms3d_vertex_t
                // weight[1] is the weight for boneIds[0]
                // weight[2] is the weight for boneIds[1]
                // 1.0f - weight[0] - weight[1] - weight[2] is the weight for boneIds[2]
                    */
                
                    /*  // old vesrsion i think without multiple weights
                    int0 = data.readByte();  // secondid
                    data.readByte(); // dummy
                    data.readByte(); // dummy
                    int1 = data.readByte(); // primarywt
                    int2 = data.readByte(); // secondarywt
                    data.readByte(); // dummy
                    if (version == 2) {
                         data.readInt();
                    }
                    if ( int0 == -1  ) { // extra for version2
                        
                    }
                    weights.push(int2);
        */
            //        /*
            
                    
                    for (j = 0; j < 3; j++) {  // char boneIds[3]
                        int0  = data.readByte();
                        boneIds.push(int0  );
                    }
                    for (j = 0; j < 3; j++) { // byte  weights[3]
                        weights.push( data.readByte() );
                    }
                    
                    
                    v1 = vertices[i];
                    if (v1.id >= 0) {
                        var binding:VertexBindingToBone = new VertexBindingToBone();
                        j = boneIds.length - 3;
                        binding.weight = weights[j] > 0 ? weights[j] * num0 : 1;
                        binding.bone = _jointList[v1.id];
                        v1.id = binding;
                        
                        if (boneIds[j] >= 0) {
                            binding = binding.next = new VertexBindingToBone();
                            binding.weight = weights[j+1] * num0;
                            if (boneIds[j] == v1.id) {
                                throw new Error("Assumption bone vertex id to be different failed!");
                            }
                            binding.bone = _jointList[boneIds[j]];  
                        }
                        if (boneIds[j + 1] >= 0) {
                            binding = binding.next =  new VertexBindingToBone();
                            binding.weight = weights[j+2] * num0;
                            binding.bone = _jointList[boneIds[j+1]];  
                        }
                        if (boneIds[j + 2] >= 0 ) {  // Not sure about this part..
                            binding = binding.next =  new VertexBindingToBone();
                            //(v1.id as VertexBindingToBone).weight
                            binding.weight = 1 - weights[j]*num0 - weights[j+1]*num0 - weights[j+2]*num0;
                            binding.bone = _jointList[boneIds[j+2]];  
                        }
                    }
                    else {
                        v1.id = null;
                    }
            
                    if (version == 2) data.readUnsignedInt(); // extra for version2
                //    */
                }
                
                debug.text += String(boneIds);
                
        
                
            }
            else debug.text += "\nEOF";
            
            version = data.readInt();
            debug.text +=  "\nJoint Version:"+version;
            
    debug.text += "\nBytes Left:" + data.position + "/" + data.length;
            
            return "Vertices: " + num_vertices + "\nTriangles: " + num_triangles + "\nGroups: " + num_groups +"\nMaterials: " + num_materials + "\nJoints:"+num_joints;
            
        }
        

        
        private function getJointXML(joint:Joint, parentXML:XML=null):XML 
        {
            var xml:XML = new XML(<j name={joint.name} x={joint.x}  y={joint.y} z={joint.z} rotX= {radToDeg(joint.rotationX)} rotY={radToDeg(joint.rotationY)} rotZ = {radToDeg(joint.rotationZ)} />);
            
            for (var j:Joint = joint.childrenList; j != null; j = j.nextJoint) {
                getJointXML(j, xml);
            }
            if (parentXML != null) parentXML.appendChild(xml);
            return xml;
        }
        
        
        private function radToDeg(val:Number ):Number {
            return val * 180 / Math.PI;
        }
        

        

    }
    
//}
import alternativ7.engine3d.animation.keys.TransformTrack;
import alternativ7.engine3d.materials.Material;
import alternativ7.engine3d.materials.TextureMaterial;
import alternativ7.engine3d.objects.Bone;
import alternativ7.engine3d.objects.Joint;
import flash.geom.Vector3D;


internal class MyKeyFrame {
    public var _translation:Boolean;
    public var _time:Number;
    private var _x:Number;
    private var _y:Number;
    public var _z:Number;
    public var joint:Joint;
    
    private var _rotationX:Number;
    private var _rotationY:Number;
    private var _rotationZ:Number;

    
    public function MyKeyFrame(time:Number, x:Number , y:Number, z:Number, translation:Boolean, joint:Joint) {
        this._translation = translation;
        if (translation) {
            this._z = z;
            this._y = y;
            this._x = x;
            this._rotationX = 0;
            this._rotationY =0;
            this._rotationZ = 0;
        }
        else {
            this._rotationX = x;
            this._rotationY = y;
            this._rotationZ = z;
            this._x = 0;
            this._y = 0;
            this._z = 0;
            
        }
        this._time = time;
        this.joint = joint;
       
        
    }
    

    
    public function mergeWithJoint():void {
        if (!_translation) {
            _x = 0;
            _y = 0;
            _z = 0;
        }
        else {
            _rotationX = 0;
            _rotationY = 0;
            _rotationZ = 0;
        }
    }
    
    public var merged:Boolean = false;  // debug flag
    public function mergeWithOther(other:MyKeyFrame):void {
        if (merged) throw new Error("Already merged with another keyframe! Current other intended:"+other);
        doMergeWithOther(other);
        merged = true;
    }
    
    public function doMergeWithOther(other:MyKeyFrame):void 
    {
        if (other._translation) {
            _x = other._x;
            _y = other._y;
            _z = other._z;
        }
        else {
            _rotationX = other._rotationX;
            _rotationY = other._rotationY;
            _rotationZ = other._rotationZ;
        }
    }
    
    public function get rotationX():Number { 
        return _rotationX; // return _rotationX; 
    }
    
    public function get rotationY():Number { 
        var ider:String = joint.name.split(" ").pop();
        return _rotationY;
        return 0;// _rotationY;    
    }
    
    public function get rotationZ():Number { 
        var ider:String = joint.name.split(" ").pop();
        //if (ider === "Leg" && _rotationZ != 0) throw new Error(joint.parentJoint.rotationY );
return _rotationZ;
        //if (ider === "Leg" && _rotationZ != 0) throw new Error(_rotationZ );
        return joint.parentJoint!=null && joint.parentJoint.rotationX > 0 && joint.parentJoint.rotationY > 0 ?  -_rotationZ : _rotationZ;// ider === "Leg" ? -_rotationZ : _rotationZ;//ider === "Leg" ? -_rotationZ :
    }
    
    public function get x():Number { return _x; }
    
    public function get y():Number { return _y; }
    
        public function get z():Number { return _z; }
        
        public function toString():String {
            return 'MyKeyFrame::'+ new Vector3D(_x, _y, _z) + ", " + new Vector3D(_rotationX, _rotationY, _rotationZ);
        }
    
}

internal class VertexBindingToBone {
    
    public var bone:Joint;
    public var weight:Number;
    public var next:VertexBindingToBone;
}

internal class KeyFramesForBone {
    public var bone:Joint;
    public var keyFrames:Vector.<MyKeyFrame>;
    public var track:TransformTrack;
}

internal class MS3DGroup {
    public var matName:String;
    public var name:String;
    public var matIndex:int;

    
    public function MS3DGroup(matName:String, name:String, matIndex:int) {
        this.matName =matName;
        this.name = name;
        this.matIndex = matIndex;
    }
    
    public function toString():String {
        return (matName!= null ? name + "<" + matName + ">" : name);
    }
    
}

internal class FaceInfo {
    public var groupIndex:int;
    public var materialIndex:int;
    
    public function FaceInfo(groupIndex:int, materialIndex:int) {
        this.groupIndex = groupIndex;
        this.materialIndex = materialIndex;
    }

}