package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import net.hires.debug.Stats;
   
    [SWF (backgroundColor="#aaaaaa", frameRate="60")]
    
    /**
     * Simple OpenGL. Highly not optimized.
     *
     * @author Tim Knip / floorplanner.com
     */
    public class FlashGL extends Sprite {
        public static var LEFT_HANDED :int = 1;
        public static var RIGHT_HANDED :int = 0;
        public var gl :GL;
        public var container :Sprite;
        public var info :TextField;
        public var stats :Stats;
        
        /** 
         * OpenGL works in a right handed coordinate space (positive rotations are counter-clockwise).
         * Flash works in a left handed space (positive rotations are clockwise).
         * Set to #LEFT_HANDED to have flash behaviour.
         */
        public var coordinateSpaceType :int = RIGHT_HANDED;

        /**
         *
         */
        public function FlashGL() {
            stage.quality = "low";

            container = new Sprite();
            addChild(container);
            container.x = stage.stageWidth / 2;
            container.y = stage.stageHeight / 2;

            info = new TextField(); 
            info.x = info.y = 5;
            info.width = info.height = 400;   
            info.multiline = true;
            info.selectable = false;
            addChild(info);

            stats = new Stats();
            addChild(stats);

            gl = new GL(this.container.graphics);
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            addEventListener(Event.ENTER_FRAME, render);

            onStageResize();
        }
        
        public function render(e:Event=null):void {
            test();
            gl.flush();
        }

        public function reshape(w:Number, h:Number):void {
            gl.viewport(0, 0, w, h);
            gl.matrixMode(GL.PROJECTION);
            gl.loadIdentity();
            gl.gluPerspective(90, w/h, 1, 5000);
            gl.matrixMode(GL.MODELVIEW);
            gl.loadIdentity();
        }

        private var _r :Number = 0;
        private function test():void {
            gl.pushMatrix();
                // translate our scene into view
                if(coordinateSpaceType == LEFT_HANDED) {
                    gl.scale(1, 1, -1);
                    gl.translate(0, 0, 200);
                } else {
                    gl.translate(0, 0, -200);
                }
                gl.rotate(0, 1, 0, _r++);_r++;

                gl.polygonMode(GL.FRONT_AND_BACK, GL.LINE);
                gl.pushMatrix();
                    gl.scale(200, 200, 1);
                    gl.begin(GL.QUADS);
                        gl.color(0xff0000);
                        gl.vertex(-0.5, 0.5, 0);
                        gl.texCoord(0, 0);

                        gl.vertex(-0.5, -0.5, 0);
                        gl.texCoord(0, 1);

                        gl.vertex(0.5, -0.5, 0);
                        gl.texCoord(1, 1);

                        gl.vertex(0.5, 0.5, 0);
                        gl.texCoord(1, 0);
                    gl.end();
                gl.popMatrix();

                gl.polygonMode(GL.FRONT, GL.FILL);

                gl.pushMatrix();                    
                    gl.translate(-100, 0, 0);
                    gl.rotate(0, 1, 0, _r);
                    gl.begin(GL.TRIANGLES);
                        gl.color(0x00ff00);
                        gl.vertex(0, 100, 0);
                        gl.vertex(-50, 0, 0);
                        gl.vertex(50, 0, 0);
                    gl.end();
                gl.popMatrix();

                gl.pushMatrix();
                    gl.translate(100, 0, 0);
                    gl.rotate(0, 1, 0, _r);
                    gl.begin(GL.TRIANGLES);
                        gl.color(0x0000ff);
                        gl.vertex(0, 100, 0);
                        gl.vertex(-50, 0, 0);
                        gl.vertex(50, 0, 0);
                    gl.end();
                gl.popMatrix();

                gl.pushMatrix();                    
                    gl.translate(-100, 0, 0);
                    gl.rotate(0, 1, 0, _r+180);
                    gl.begin(GL.TRIANGLES);
                        gl.color(0xff00ff);
                        gl.vertex(0, 100, 0);
                        gl.vertex(-50, 0, 0);
                        gl.vertex(50, 0, 0);
                    gl.end();
                gl.popMatrix();

                gl.pushMatrix();
                    gl.translate(100, 0, 0);
                    gl.rotate(0, 1, 0, _r+180);
                    gl.begin(GL.TRIANGLES);
                        gl.color(0x00ffff);
                        gl.vertex(0, 100, 0);
                        gl.vertex(-50, 0, 0);
                        gl.vertex(50, 0, 0);
                    gl.end();
                gl.popMatrix();

                gl.pushMatrix();
                    gl.begin(GL.LINES);
                        gl.color(0xff0000);
                        gl.vertex(0, 0, 0);
                        gl.vertex(50, 0, 0);
                    gl.end();
                    gl.begin(GL.LINES);
                        gl.color(0x00ff00);
                        gl.vertex(0, 0, 0);
                        gl.vertex(0, 50, 0);
                    gl.end();
                    gl.begin(GL.LINES);
                        gl.color(0x0000ff);
                        gl.vertex(0, 0, 0);
                        gl.vertex(0, 0, 50);
                    gl.end();
                gl.popMatrix();
            gl.popMatrix();
        }

        private function onStageResize(e:Event=null):void {
            reshape(stage.stageWidth, stage.stageHeight);
            stats.x = stage.stageWidth - stats.width;
        }
    }
}

import flash.display.*;
import flash.errors.*;
import flash.geom.*;


internal class GLMatrixStack {
    public var stack :Vector.<Matrix3D>;
    public function GLMatrixStack() {
        stack = new Vector.<Matrix3D>();
    }
    public function set current(value:Matrix3D):void {
        if(!stack.length) {
            stack.push(value);
        } else {
            stack[stack.length-1] = value;
        }
    }
    public function get current():Matrix3D {
        if(!stack.length) {
            stack.push(new Matrix3D());
        }
        return stack[stack.length-1];
    }
    public function getTransform():Matrix3D {
        var m:Matrix3D = stack.length ? stack[0].clone() : new Matrix3D();
        var i:int;
        for(i = 1; i < stack.length; i++) {
            m.append(stack[i]);
        }
        return m; 
    }
}

internal class GL {
    public static const MODELVIEW :int = 0;
    public static const PROJECTION :int = 1;
    public static const TEXTURE :int = 2;
    public static const TRIANGLES :int = 0;
    public static const QUADS :int = 1;
    public static const LINES :int = 2;
    public static const FRONT :int = 1;
    public static const BACK :int = 2;
    public static const FRONT_AND_BACK :int = 3;
    public static const POINT :int = 1;
    public static const LINE :int = 2;
    public static const FILL:int = 3;

    private var _modelStack :GLMatrixStack;
    private var _projectionStack :GLMatrixStack;
    private var _matrixMode :int = 0;
    private var _modelVerts :Vector.<Number>;
    private var _viewVerts :Vector.<Number>;
    private var _screenVerts :Vector.<Number>;
    private var _uvtData :Vector.<Number>;
    private var _beginMode :int = -1;
    private var _tmpViewMatrix :Matrix3D;
    private var _triangleIndices :Vector.<int>;
    private var _graphicsData:Vector.<IGraphicsData>;
    private var _graphics :Graphics;
    private var _viewportWidth :Number;
    private var _viewportHeight :Number;
    private var _fillColor :int;
    private var _polygonMode :int = FILL;
    private var _polygonFace :String = TriangleCulling.NONE;
    private var _primitiveCount :int = 0;

    /**
     * Constructor.
     *
     * @param graphics
     */
    public function GL(graphics:Graphics) {
        _graphics = graphics;
        _modelStack = new GLMatrixStack();
        _projectionStack = new GLMatrixStack();
        _modelVerts = new Vector.<Number>();
        _viewVerts = new Vector.<Number>();
        _screenVerts = new Vector.<Number>();
        _uvtData = new Vector.<Number>();
        _tmpViewMatrix = new Matrix3D();
        _graphicsData = new Vector.<IGraphicsData>();
        _fillColor = -1;

        gluPerspective(40, 1.333, 1, 5000);

        _viewportTransform = new Matrix3D();
    }

    /**
     * glBegin
     *
     * @param mode
     */
    public function begin(mode:int=1):void {
        _beginMode = mode;
    }

    /**
     * glColor
     *
     * @param mode
     */
    public function color(rgb:int=-1):void {
        _fillColor = rgb;
    }

    /**
     * glEnd
     */
    public function end():void {
        if(_beginMode < 0) throw new Error("glEnd called without a preceding glBegin!");

        if(_uvtData.length != _modelVerts.length) {
            _uvtData = new Vector.<Number>(_modelVerts.length);
        }

        _tmpViewMatrix.rawData = _modelStack.current.rawData;
        _tmpViewMatrix.transformVectors(_modelVerts, _viewVerts);

        Utils3D.projectVectors(_projectionStack.current, _viewVerts, _screenVerts, _uvtData);
        
        if(_beginMode == LINES) {
            _graphicsData.push(new GraphicsStroke(0, false, "normal", "none", 
                               "round", 1, new GraphicsSolidFill(_fillColor)));
        } else {
            if(_polygonMode == POINT) {
                return;
            } else if(_polygonMode == LINE) {
                _graphicsData.push(new GraphicsStroke(0, false, "normal", "none", 
                                   "round", 1, new GraphicsSolidFill(_fillColor)));
            } else if(_polygonMode == FILL) {
                _graphicsData.push(new GraphicsSolidFill(_fillColor));
                _graphicsData.push(new GraphicsStroke());
            }
        }

        var i :int = 0;
        var indices :Vector.<int> = new Vector.<int>();

        switch(_beginMode) {
            case LINES:
                var path :GraphicsPath = new GraphicsPath();
                path.moveTo(_screenVerts[0], _screenVerts[1]);
                for(i = 2; i < _screenVerts.length; i += 2) {
                    path.lineTo(_screenVerts[i], _screenVerts[i+1]);
                }
                path.lineTo(_screenVerts[0], _screenVerts[1]);    
                _graphicsData.push(path);
                break;
            case TRIANGLES:
                for(i = 0; i < _viewVerts.length; i += 3) {
                    indices.push(i, i+1, i+2);
                }
                _graphicsData.push(new GraphicsTrianglePath(_screenVerts, indices, null, _polygonFace));
                break;
            case QUADS:
                for(i = 0; i < _viewVerts.length; i += 4) {
                    indices.push(i, i+1, i+2);
                    indices.push(i, i+2, i+3);
                }
                _graphicsData.push(new GraphicsTrianglePath(_screenVerts, indices, null, _polygonFace));
                break;
            default:
                break;
        }

        if(_polygonMode == FILL && _beginMode != LINES) {
            _graphicsData.push(new GraphicsEndFill());
        }
        _modelVerts = new Vector.<Number>();
        _viewVerts = new Vector.<Number>();
        _screenVerts = new Vector.<Number>();
        _uvtData = new Vector.<Number>();
        _beginMode = _fillColor = -1;
    }

    /**
     * glFlush
     */
    public function flush():void {
        _graphics.clear();
        _graphics.drawGraphicsData(_graphicsData);
        _graphicsData = new Vector.<IGraphicsData>();
        _primitiveCount = 0;
    }

    /**
     * glLoadIdentity
     */
    public function loadIdentity():void {
        var stack :GLMatrixStack;
        switch(_matrixMode) {
            case PROJECTION:
                stack = _projectionStack;
                break;
            case MODELVIEW:
                stack = _modelStack;
                break;
            default:
                throw new Error("Invalid matrixMode!");
        }
        stack.stack = new Vector.<Matrix3D>();
        stack.current.identity();
    }
    /**
     * glMatrixMode
     * @param mode
     */
    public function matrixMode(mode:int):void {
        switch(mode) {
            case PROJECTION:
            case MODELVIEW:
                break;
            default:
                throw new ArgumentError("Invalid matrixMode!");
        }
        _matrixMode = mode;
    }
    
    /**
     * glPolygonMode
     */
    public function polygonMode(face:int, mode:int):void {
        if(_beginMode >= 0) {
            var message :String = "glPolygonMode is executed between the execution of ";
            message += "glBegin and the corresponding execution of glEnd.";
            throw new IllegalOperationError(message);
        }

        if(face != FRONT && face != BACK && face != FRONT_AND_BACK) {
            throw new ArgumentError("Invalid value for param @face");
        }
        if(mode != POINT && mode != LINE && mode != FILL) {
            throw new ArgumentError("Invalid value for param @mode");
        }

        switch(face) {
            case FRONT:
                _polygonFace = TriangleCulling.POSITIVE;
                break;
            case BACK:
                _polygonFace = TriangleCulling.NEGATIVE;
                break;
            case FRONT_AND_BACK:
            default:
                _polygonFace = TriangleCulling.NONE;
                break;
        }
        _polygonMode = mode;
    }

    /**
     * glPopMatrix
     */
    public function popMatrix():Matrix3D {
        var current :Matrix3D;
        switch(_matrixMode) {
            case PROJECTION:
                current = _projectionStack.stack.pop();
                break;
            case MODELVIEW:
                current = _modelStack.stack.pop();
                break;
            default:
                throw new Error("Invalid matrixMode!");
        }
        return current;
    }

    /**
     * glPushMatrix
     */
    public function pushMatrix():Matrix3D {    
        var current :GLMatrixStack;
        var matrix :Matrix3D;
        switch(_matrixMode) {
            case PROJECTION:
                current = _projectionStack;
                break;
            case MODELVIEW:
                current = _modelStack;
                break;
            default:
                break;
        }
        if(!current) return null;
        matrix = current.getTransform();
        current.stack.push(matrix);
        return matrix;
    }

    /**
     * glNormal
     */
    public function normal(x:Number, y:Number, z:Number):void {
    }

    /**
     * glRotate
     */
    public function rotate(x:Number, y:Number, z:Number, degrees:Number):void {
        _rotation.x = x;
        _rotation.y = y;
        _rotation.z = z;
        if(_matrixMode == MODELVIEW) {
            _modelStack.current.prependRotation(degrees, _rotation);
        }
    }

    /**
     * glScale
     */
    public function scale(x:Number, y:Number, z:Number):void {
        if(_matrixMode == MODELVIEW) {
            _modelStack.current.prependScale(x, y, z);
        }
    }
    
    /**
     * glTexCoord
     */
    public function texCoord(s:Number, t:Number, p:Number=0):void {
        _uvtData.push(s, t, p);
    }

    /**
     * glTranslate
     */
    public function translate(x:Number, y:Number, z:Number):void {
        if(_matrixMode == MODELVIEW) {
            _modelStack.current.prependTranslation(x, y, z);
        }
    }

    /**
     * glVertex
     */
    public function vertex(x:Number, y:Number, z:Number):void {
        _modelVerts.push(x, y, z);
        _viewVerts.push(0, 0, 0);
        _screenVerts.push(0, 0);
    }
    
    /**
     * glViewport
     */
    public function viewport(x:Number=0, y:Number=0, w:Number=640, h:Number=480):void {
        _viewportTransform = _viewportTransform || new Matrix3D();
        _viewportTransform.identity();
        _viewportTransform.prependScale(w/2, -h/2, 1);
    }

    /**
     * gluPerspective
     */
    public function gluPerspective(fovy:Number, aspect:Number, zNear:Number, zFar:Number):void {
        var fov :Number = (fovy/2) * (Math.PI/180);
        var tan:Number = Math.tan(fov);
        var f:Number = 1 / tan;
        var proj:Matrix3D = new Matrix3D(Vector.<Number>([
            f / aspect, 0, 0, 0,
            0, f, 0, 0,
            0, 0, (zNear+zFar) / (zNear-zFar), (2*zFar*zNear) / (zNear-zFar),
            0, 0, -1, 0
        ]));

        // HACK! should be done elsewhere
        if(!_viewportTransform) {
            viewport(0, 0, 640, 480);
        }
        proj.prepend(_viewportTransform);
        _projectionStack.current = proj;
    }

    private var _rotation :Vector3D = new Vector3D();
    private var _viewportTransform :Matrix3D;
}


