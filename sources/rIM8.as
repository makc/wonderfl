package  
{
    import alternativ7.engine3d.containers.BSPContainer;
    import alternativ7.engine3d.containers.KDContainer;
    import alternativ7.engine3d.controllers.SimpleObjectController;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Debug;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.core.View;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.primitives.Box;
    import flash.text.TextField;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.ui.Keyboard;
    

    /**
     * Visual tool to visualise KDContainer tree structure in Alternativa3d.
     * Use arrow keys (up/down, left/right) to navigate tree.
     
     * Ignore the backbuffer arc circle (radius-sort) nonsense. That's just leftover
     * code used to sort concentric kd-container circles from a previous project.
     
     * Scroll to bottom for visualiser utility class.
     
     * @author Glenn Ko
     */
    public class TreeVisualiserTool extends Sprite
    {
  
 
    
        private var _visualiser:TreeVisualiser;
        protected var controller:SimpleObjectController;
        private var _kdContainer:KDContainer;
        
        private var _autoStartRender:Boolean;
        private var _autoSize:Boolean;
        public var scene:Object3DContainer;
        
        public var camera:Camera3D;
        protected var _debugField:TextField;

        
        public function TreeVisualiserTool() {
        
            
            this._autoSize = true;
            this._autoStartRender = true;
            scene = new RadiusSortContainer();
            // Camera and view
            // Создание камеры и вьюпорта
            camera = new Camera3D();
            
            camera.view = new View(stage.stageWidth, stage.stageHeight);
            addChild(camera.view);
            addChild(camera.diagram);
            
            
            
            
            // Initial position
            // Установка положения камеры
            scene.addChild(camera);
            
            // Listeners
            // Подписка на события
            
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            camera.y = -600;
            camera.z = 1000;
            camera.rotationX = 140 * (180 / Math.PI);
            
            controller = new SimpleObjectController(stage, camera, 500);
            controller.unbindKey(Keyboard.LEFT);
            controller.unbindKey(Keyboard.UP);
            controller.unbindKey(Keyboard.DOWN);
            controller.unbindKey(Keyboard.RIGHT);
        
            _kdContainer = new CircleObject(500);
        
            
            var targ:* = _kdContainer;  // switch to different container for setup
            
            //camera.debug = true;
            //camera.addToDebug( Debug.NODES, CircleObject);
            scene.addChild(targ);
            
            _visualiser = new TreeVisualiser(null, stage);
            _visualiser.setTreeObject3D(targ);
            
            setupDebugField();
            
            stage.addEventListener(Event.RESIZE, onResize);
            stage.addEventListener(Event.ENTER_FRAME, renderEvent);
        }
        
        public function setupDebugField():void {
            if (_debugField == null) {
                _debugField = new TextField();
                _debugField.autoSize = "left";
                addChild(_debugField);
            }
        }
        protected function startRendering():void {
             stage.addEventListener(Event.ENTER_FRAME, renderEvent);
        }
        public function stopRendering():void {
             stage.removeEventListener(Event.ENTER_FRAME, renderEvent);
        }
        
        protected function onResize(e:Event=null):void 
        {
            camera.view.width = stage.stageWidth;
            camera.view.height = stage.stageHeight;
        }
        
        protected   function renderEvent(e:Event=null):void 
        {
            
            controller.update();
            _kdContainer.rotationZ += .01;
            //throw new Error(camera.rotationX);
            camera.render();
            _visualiser.renderTo(camera);
            
            _debugField.text = (_visualiser.isRoot ? "ROOT " : "") + (_visualiser.isLeft ? "left" : "right");
            _debugField.appendText(", " + _visualiser.numChildren);
        }

    }

}

//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Canvas;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    /**
     * Back-buffer for back-facing rings segments
     * @author Glenn Ko
     */
    //public
    class BackBuffer implements IBackDraw
    {
        public var backArcList:Vector.<IBackDraw> = new Vector.<IBackDraw>();
        public var numBackChildren:int = 0;
        
        public function set backBufferLen(amt:int):void {
            backArcList.fixed = false;
            backArcList.length = amt;
            backArcList.fixed = true;
        }
        
        public function get backBufferLen():int {
            return backArcList.length;
        }
        
        private static var INSTANCE:BackBuffer;
        public static function getInstance():BackBuffer {
            return INSTANCE || (INSTANCE = new BackBuffer() );
        }
        
        public function BackBuffer() 
        {
            
        }
        
        
        public function flush(camera:Camera3D):void {
            
            // Draw back-facing ring segments in reverse order
            var i:int = numBackChildren;
            while (--i > -1) {
                backArcList[i].flush(camera);
                backArcList[i] = null;
            }
            numBackChildren = 0;
        }
            
        
    }

//}


//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.core.Camera3D;
    /**
     * Back buffer being held for each circle for drawing each back-ringed item.
     * @author Glenn Ko
     */
    //public 
    class BackBuffer2 implements IBackDraw
    {
        public var backArcList:Vector.<IBackDraw> = new Vector.<IBackDraw>();
        public var numBackChildren:int = 0;
        
        public function set backBufferLen(amt:int):void {
            backArcList.fixed = false;
            backArcList.length = amt;
            backArcList.fixed = true;
        }
        
        public function get backBufferLen():int {
            return backArcList.length;
        }
        
        public function BackBuffer2() 
        {
            
        }
        
        /* INTERFACE circlesortexample.IBackDraw */
        
        // Does drawing of each individual item within each back-ring segment
        public function flush(camera:Camera3D):void {

            // Draw items in order as they were checked in
            for (var i:int = 0; i < numBackChildren; i++) {
                backArcList[i].flush(camera);
                backArcList[i] = null;
            }
        
            numBackChildren = 0;
        }
        
    }

//}



//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.containers.BSPContainer;
    import alternativ7.engine3d.containers.ConflictContainer;
    import alternativ7.engine3d.containers.KDContainer;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Canvas;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.objects.Mesh;
    import alternativ7.engine3d.primitives.Box;
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    /**
     * This is a circle ring container
     * @author Glenn Ko
     */
    //public 
    class CircleObject extends KDContainer 
    {
        public var _radius:Number;
        public var ang_speed:Number;
        public static var COUNT:int = 0;
        private var _rootBackBuffer:BackBuffer = BackBuffer.getInstance();
        public var _backBuffer:BackBuffer2 = new BackBuffer2();
        
        public function CircleObject(radius:Number, numItems:int =64 ) 
        {
        
            this.distance = radius;
            this._radius = radius;
            COUNT += numItems;
            ang_speed = -.005 + Math.random() * .005;
            
            var meshes:Vector.<Object3D> = new Vector.<Object3D>(numItems, true);
            
            // fixed length buffer setting. (adjust this if required to best fit).
            _backBuffer.backBufferLen = numItems;
            
            var degToRad:Number = 180 / Math.PI;
            var angInc:Number =Math.PI * 2 / numItems;
            var ang:Number = 0;
            for (var i:int = 0; i < numItems; i++) {
                var cube:CuberBox = new CuberBox(16, 16, 16, 1, 1, 1);
                //cube.parentCircle = this;        // tight coupling
                cube.setMaterialToAllFaces( new FillMaterial( int(Math.random() * 0xFFFFFF) ) );
                cube.x = Math.cos( ang ) * radius;
                cube.y = Math.sin( ang ) * radius;
                cube.rotationZ = ang;
                meshes[i] = cube;
                ang += angInc;
            }
            createTree(meshes, null);
        }
        
        override alternativa3d function draw(camera:Camera3D, parentCanvas:Canvas):void {
            super.draw(camera, parentCanvas);
            if (_backBuffer.numBackChildren > 0) {
                _rootBackBuffer.backArcList[_rootBackBuffer.numBackChildren++] = _backBuffer;
            }
        }
        
    
        
    }

//}


//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Canvas;
    import alternativ7.engine3d.core.Face;
    import alternativ7.engine3d.core.Vertex;
    import alternativ7.engine3d.materials.Material;
    import alternativ7.engine3d.primitives.Box;
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * ...
     * @author Glenn Ko
     */
    //public 
    class CuberBox extends Box 
    {
        
        
        public function CuberBox(width:Number = 100, length:Number = 100, height:Number = 100, widthSegments:uint = 1, lengthSegments:uint = 1, heightSegments:uint = 1, reverse:Boolean = false, triangulate:Boolean = false, left:Material = null, right:Material = null, back:Material = null, front:Material = null, bottom:Material = null, top:Material = null) 
        {
            super(width, length, height, widthSegments, lengthSegments, heightSegments, reverse, triangulate, left, right, back, front, bottom, top);
        }
        
        
        
    
        
    }

//}



//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.core.Camera3D;
    
    /**
     * Draw payload for backbuffer. A backbuffer implements IBackDraw as well and can be composited
     * to parent backbuffers.
     * @author Glenn Ko
     */
    //public
    interface IBackDraw 
    {
        function flush(camera:Camera3D):void;
    }
    
//}


//package iss.engine3d.proto 
//{
    import alternativ7.engine3d.alternativa3d;
    import alternativ7.engine3d.containers.DistanceSortContainer;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Canvas;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * Uses "distance" value of any added child as a way of determining it's radial offset from container's
     * center origin. Currently, we just assume the added children is already added in the order
     * of distance from the center. Consider todo: pre-sorting method call and insertion sort algorithms.
     * 
     * Objects are sorted from the nearest radial offset from camera's radial offsets, with various 
     * public canvas buffers for "back/front-facing" vs outer/inner objects that can be accessed by inner children
     * to perform rendering to specific back-buffer canvases.
     * 
     * @author Glenn Ko
     */
    //public
    class RadiusSortContainer extends Object3DContainer
    {
        private var _backBuffer:BackBuffer = BackBuffer.getInstance();
        // precomputed depth order of canvas layers
        public static var ROOT_OUTER:Canvas;    // convex ring canvas
        public static var ROOT_INNER:Canvas;    // concave ring canvas
        // for concave ring
        public static var ROOT_INNER_INNER:Canvas;
        public static var ROOT_INNER_OUTER:Canvas;  // back buffer canvas
        // for convex ring
        public static var ROOT_OUTER_OUTER:Canvas; 
        public static var ROOT_OUTER_INNER:Canvas;  // back buffer canvas
        
        public static var ROOT_DRAW:Canvas;
        
        public function RadiusSortContainer() 
        {
        
        }
        
        override alternativa3d function draw(camera:Camera3D, parentCanvas:Canvas ):void {

            ROOT_OUTER = parentCanvas.getChildCanvas(false, false);
            ROOT_INNER = parentCanvas.getChildCanvas(false, false);
            
            ROOT_INNER_INNER = ROOT_INNER.getChildCanvas(false, false);
            ROOT_INNER_OUTER = ROOT_INNER.getChildCanvas(false, false);
            
            ROOT_OUTER_OUTER = ROOT_OUTER.getChildCanvas(false, false);
            ROOT_OUTER_INNER = ROOT_OUTER.getChildCanvas(false, false);
            
            super.draw(camera, parentCanvas);
            
            _backBuffer.flush(camera);
        }
        

        
        override alternativa3d function drawVisibleChildren(camera:Camera3D, canvas:Canvas):void {
            // Camera radius 'd' calculation assumes camera and RadiusSortContainer is in same coordinate space, 
            // and container has no local rotation applied. (Consider:: more accruate calculation..)
            var nx:Number = camera.x - x;
            var ny:Number = camera.y - y;
            var nz:Number = camera.z - z;
            var d:Number = Math.sqrt( nx * nx + ny * ny + nz * nz );
            camera.distance = d;

            
            // This approach assumes all objects are pre-sorted from smallest radial distance to furthest.
            var child:Object3D;
            var i:int;
            var c:int;
            var rootDraw:Canvas;
            
            // Find middle point (this linear search is incredibly dumb and should be improved...).
            for ( i = 0; i < numVisibleChildren; i++ ) {   
                child = visibleChildren[i];
                if (child.distance > d) break;  
            }
            
            // Draw inner concave faces to inner canvas
            rootDraw = ROOT_INNER;
            ROOT_DRAW = rootDraw;
            for ( c = i; c < numVisibleChildren; c++ ) {   
                child = visibleChildren[c];
                child.draw(camera, rootDraw);  // draw this as a inner face
            }
            
            // Draw outer convex faces to outer canvas
            rootDraw = ROOT_OUTER;
            ROOT_DRAW = rootDraw;
            c = i;
            while (--c > -1) {
                child = visibleChildren[c];
                child.draw(camera, rootDraw);  // draw this as a outer face
            
            }
            
    
        }

    }




//package utils.tree 
//{
    /**
     * ...
     * @author Glenn Ko
     */
    //public 
    class TreeNodeType 
    {
        public static const NONE:int = 0;
        public static const BSP_CONTAINER_NODE:int = 1;
        public static const KD_CONTAINER_NODE:int = 2;
        public static const BSP_NODE:int = 3;
    }

//}


//package utils.tree 
//{
    import alternativ7.engine3d.containers.BSPContainer;
    import alternativ7.engine3d.containers.KDContainer;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Canvas;
    import alternativ7.engine3d.core.Debug;
    import alternativ7.engine3d.core.Face;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Object3DContainer;
    import alternativ7.engine3d.core.Vertex;
    import alternativ7.engine3d.core.Wrapper;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.objects.BSP;
    import alternativ7.engine3d.objects.Mesh;
    import de.polygonal.ds.TreeBuilder;
    import de.polygonal.ds.TreeNode;
    import flash.events.IEventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Vector3D;
    import flash.media.Camera;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    import alternativ7.engine3d.alternativa3d;
    use namespace alternativa3d;
    /**
     * General visualiser for tree-based sorting structures under Alternativa3D
     * @author Glenn Ko
     */
    //public 
    class TreeVisualiser 
    {
        private var _type:int = 0;
        private var _treeBuilder:TreeBuilder;
        private var _keyboardListener:IEventDispatcher;
        private var _bindings:Dictionary = new Dictionary();
        private var _treeObject:Object3D;
        private static var IDENTITY:Object3D = new Object3D();
        private var _isLeft:Boolean = true;
        //public var bspMesh:Mesh = new Mesh();
        public var bspPlaneColor:uint = 0x00FF00;
    
        
        public function TreeVisualiser(object:Object3D=null, keyboardListener:IEventDispatcher=null) 
        {
            if ( keyboardListener != null) setKeyboardListener(keyboardListener)
            if (object != null) {
                setTreeObject3D(object);
            }
            
            _bindings[Keyboard.UP] = up;
            _bindings[Keyboard.DOWN]= down;
            _bindings[Keyboard.LEFT]= prevChild;
            _bindings[Keyboard.RIGHT] = nextChild;
            
            
        
            
            
        }
        public function setKeyboardListener(value:IEventDispatcher):void 
        {
            if (_keyboardListener != null) {
                _keyboardListener.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _keyboardListener = null;
            }
            if (value == null) return;
            _keyboardListener = value;
            _keyboardListener.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false , 0, true);
        }
        
        private function up():Boolean {
            //if (_treeBuilder.getNode().parent == null) return false;
            var result:Boolean =  _treeBuilder.up();

            if (result) {
                //_isLeft = true;
            //    _treeBuilder.childStart();
            
            
            }
            return result;
        }
        private function down():Boolean {
            if (_treeBuilder.getNode().children == null) return false;
            var result:Boolean = _treeBuilder.down();
    
            
            if (result) {
                _isLeft = true;
                _treeBuilder.childStart();
            
            
            }
            return result;
        }
        private function prevChild():Boolean {
    
            
            var result:Boolean = _treeBuilder._child ?  _treeBuilder._child.prev != null : false;// _treeBuilder.prevChild()
        
                
            if (result) {
                _treeBuilder._child = _treeBuilder._child.prev;  // inline result
                _isLeft = true;
            }
            return result;
        }
        private function nextChild():Boolean {
        
            var result:Boolean =  _treeBuilder._child ?  _treeBuilder._child.next != null : false;// _treeBuilder.nextChild();    
        
            if (result) {
                    _treeBuilder._child = _treeBuilder._child.next; // inline result
                _isLeft = false;
                
                
            }
            return result;
        }
        
        private function onKeyDown(e:KeyboardEvent):void 
        {
            if (_treeBuilder == null) return;
            if ( _bindings[e.keyCode]!=null ) {
                if ( _bindings[e.keyCode]() ) {
                    onKeyPress();
                }
            }
        }
        
        protected function onKeyPress():void 
        {
            
        }

        
        public function renderTo(camera:Camera3D):void {
            if (_treeBuilder == null) return;
            
            var node:TreeNode;
            
            if (_type  === TreeNodeType.KD_CONTAINER_NODE ) {
                node = _treeBuilder.getNode();
                if (node) debugDrawKDNode(camera, node.val, (_treeBuilder.getChildNode() ? .35 : 1) );
                    //validateBinaryTree(node, false);
                    
                node = _treeBuilder.getChildNode();
                if (node) debugDrawKDNode(camera, node.val, 1);
                
                if (node != null && node.val.objectList != null) {
                    for (var obj:Object3D = node.val.objectList; obj != null; obj = obj.next) {
                        
                        Debug.drawBounds(camera, camera.view.getChildCanvas(true, false, null, 1), obj,  obj.boundMinX, obj.boundMinY, obj.boundMinZ, obj.boundMaxX, obj.boundMaxY, obj.boundMaxZ, 0xFFFF00, 1);
                    //    throw new Error("DONE!"+node.val.axis + "," +node.val.minCoord + ", " +node.val.coord + ", "+node.val.maxCoord + "::"+ String(node.next!=null) + ", "+ Bounds3D.getBoundsOf( node.val.objectBoundList).equals(Bounds3D.getBoundsOf(obj)) + ", "+ Bounds3D.getBoundsOf(node.val.objectBoundList) );
                    }
                    if (node.val.negative != null  ) {  //|| node.val.positive != null
                        throw new Error("Node isn't terminal!:"+node.val.negative + ", "+node.val.positive);
                    }
                    
                }
                
            
                
            
            }
            else {
                node = _treeBuilder.getChildNode();
                if (node) debugDrawBSPContainerNode(camera, node.val, 1);
                node = _treeBuilder.getNode();
                if (node) debugDrawBSPContainerNode(camera, node.val, (_treeBuilder.getChildNode() ? .15 : 1) );
            }

        }
        
        private function errorvalue():*{
            throw new Error("Not applicable value!");
        }
        
        private function debugDrawKDNode(camera:Camera3D, node:*, alpha:Number = 1):void {
            var canvas:Canvas = camera.view.getChildCanvas(true, false, null, alpha);
                var alpha:Number = node.objectBoundList != null ? 1 : .2;

    
                Debug.drawKDNode(camera, canvas, _treeObject , node.axis, node.coord, node.boundMinX, node.boundMinY, node.boundMinZ, node.boundMaxX, node.boundMaxY, node.boundMaxZ, alpha);
            Debug.drawBounds(camera, canvas, _treeObject, node.boundMinX, node.boundMinY, node.boundMinZ, node.boundMaxX, node.boundMaxY, node.boundMaxZ, alpha);
            
        }
        
        private function drawPointBounds(camera:Camera3D, canvas:Canvas, _treeObject:Object3D, x:Number, y:Number, z:Number):void {
            Debug.drawBounds(camera, canvas, _treeObject, x-15, y-15, z-15, x+15, y+15, z+15, 1);
        }
        
        private function debugDrawBSPContainerNode(camera:Camera3D, node:*, alpha:Number = 1):void {
            
            Debug.drawBounds(camera, camera.view.getChildCanvas(true, false, null, alpha), _treeObject, node.boundMinX, node.boundMinY, node.boundMinZ, node.boundMaxX, node.boundMaxY, node.boundMaxZ, 0xFF0000, alpha);
            //bspPlaneFace.normalX = node.normalX;
            //bspPlaneFace.normalY = node.normalY;
        //    bspPlaneFace.normalZ = node.normalZ;
        //    bspPlaneFace.offset = node.offset;
        //    bspPlaneFace.offset = 
            //Debug.drawEdges(camera, camera.view.getChildCanvas(true, false, null, alpha), bspPlaneFace , bspPlaneColor);
            
        }
        
        public function setTreeObject3D(object:Object3D):void {
            var oldTree:TreeBuilder = _treeBuilder;
            var oldType:int = _type;
            _treeObject = object;
                if (object is BSPContainer) {
                 _type = TreeNodeType.BSP_CONTAINER_NODE;
                _treeBuilder = createBinaryTree((object as BSPContainer).root );
                }
                else if (object is BSP) {
                    // No longer supported
                    //case BSP:    _type = TreeNodeType.BSP_NODE;
                    //_treeBuilder  = createBinaryTree((object as BSP).root );
                    //break;
                    throw new Error("BSP no longer supported! Use BSPCOntainer instead!");
                }
                else if (object is KDContainer ) {
                    _type = TreeNodeType.KD_CONTAINER_NODE;
                    _treeBuilder = createBinaryTree( Object(object).root);
                }
                else {
                    throw new Error("Could not resolve tree type!:"+Object(object).constructor);
                }
        
            
            if (oldTree != null) {
                oldTree.free();
            }
            
            
            _treeBuilder.root();

            
            validateBinaryTree(_treeBuilder.getNode());
            //throw new Error(_count);
        }
        private var _count:int = 0;
        public function validateBinaryTree(node:TreeNode, recurse:Boolean=true):void {
            //if ( !(node.numChildren() == 2 || node.numChildren() == 0) ) throw new Error("Invalid size!:"+node.numChildren());
            _count++;
            if (node.children != null) {
                if (recurse) {
                    validateBinaryTree(node.children );
                    if (node.children.next) validateBinaryTree(node.children.next );
                }
            }
        }
        
        private function createBinaryTree(rootData:*):TreeBuilder {
            if (rootData == null) throw new Error("Null root data!");
            var node:TreeNode =  new TreeNode(rootData);
            var newTree:TreeBuilder = new TreeBuilder( node );
            if (node.val.positive || node.val.negative) {
                populateNodeBinary(node);
            }
            else {
                throw new Error("no children from root!!");
            }
            return newTree;
        }
        
        private function populateNodeBinary(node:TreeNode):void {
            
            


            if (node.val.negative) {
                newNode = new TreeNode(node.val.negative, node )
            node.appendNode(newNode );
                populateNodeBinary(newNode);
            }
            
            if (node.val.positive) {
                var newNode:TreeNode = new TreeNode( node.val.positive, node);
                node.appendNode(newNode );
                populateNodeBinary(newNode);
            }
        
        }
        
        public function get isLeft():Boolean { return _isLeft; }
        
        public function get isRoot():Boolean { return _treeBuilder.getNode().isRoot(); }
        
        public function get numChildren():int {
            return _treeBuilder.getChildNode() ? _treeBuilder.getNode().numChildren() : 0;
        }

        
    }

//}
