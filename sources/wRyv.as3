// @thanks WireFrame SpaceShip | http://wonderfl.net/code/99ba3f5409b660f700f5df4df4ca7f6eb1a7ab92
package {
    import org.papervision3d.view.BasicView;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;

    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.objects.special.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.special.*;
    import org.papervision3d.core.geom.*;
    import org.papervision3d.core.geom.renderables.*;
    import org.papervision3d.core.math.*;
    import org.papervision3d.core.proto.*;
    import org.papervision3d.core.render.command.*;
    import net.hires.debug.Stats;
    import org.papervision3d.core.data.*;
    import org.papervision3d.view.layer.*;
    import org.papervision3d.core.effects.utils.*;
    
    import frocessing.color.*;
    
    [SWF(backgroundColor="0x000000", frameRate="60")]
    public class PV3D extends BasicView {
        private var _tf : TextField;
        private var _particles : Array;
        private var _pm : ParticleMaterial;
        private var _self : DisplayObject3D;
        private var _selfTrack : Track;
        private var _wf : MaterialObject3D;
        
        // debris
        private var _ds : Pixels;
        private var _cm : ColorMaterial;
        
        private var _v : Number3D = new Number3D(0, 0, 1); // front and velocity unit vector
        private var _up : Number3D = new Number3D(0, 1, 0); // up unit vector
        
        private var _locked : Dictionary = new Dictionary(); // particles locked on <star:Particle, time:int>
        
        private var _hsv : ColorHSV = new ColorHSV();
        
        private var _time : Number = 0;
        private var _aams : Array = [];
        
        private var _tracks : Array = []; // tracks who have no parent AAM.
        
        public function PV3D() {
            super(0, 0, true, false);
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            
            _tf = new TextField();
//            addChild(_tf);
            _tf.textColor = 0xffffff;
            _tf.width = 200;
            _tf.height = 465;
            
//            addChild(new Stats());
            
            // stars
            _pm = new ParticleMaterial(0xffffff, 1, ParticleMaterial.SHAPE_SQUARE);
            var pf : ParticleField = new ParticleField(_pm, 50, 10, 2000, 2000, 2000);
            scene.addChild(pf);
            _particles = pf.particles;
            
            var bel : BitmapEffectLayer = new BitmapEffectLayer(viewport, 465, 465, true, 0, BitmapClearMode.CLEAR_PRE, false, true);
            viewport.containerSprite.addLayer(bel);
            
            _ds = new Pixels(bel);
            scene.addChild(_ds);
            
            // self
            _wf = new WireframeMaterial(0xff00ff);
            _wf.doubleSided = true;
            var v : Array = 
            		[
            			new Vertex3D(-14.5, 0.0, 0.4),
            			new Vertex3D(14.5, 0.0, 0.4),
            			new Vertex3D(0.0, 22.0, 4.2),
            			new Vertex3D(0.0, 0.0, 69.0),
            			new Vertex3D(0.0, 12.0, -32.4),
            			new Vertex3D(25.5, 3.6, -17.1),
            			new Vertex3D(86.0, -16.7, -16.8),
            			new Vertex3D(-25.5, 3.6, -17.1),
            			new Vertex3D(-86.0, -16.7, -16.8),
            			new Vertex3D(26.5, 23.3, -10.2),
            			new Vertex3D(36.1, 35.2, -44.7),
            			new Vertex3D(-26.5, 23.3, -10.2),
            			new Vertex3D(-36.1, 35.2, -44.7)
            		];
            _self = new TriangleMesh3D(_wf, v, []);
            _self.geometry.faces = 
	            	[
            			new Triangle3D(_self, [v[0], v[1], v[2]]),
            			new Triangle3D(_self, [v[0], v[1], v[3]]),
            			new Triangle3D(_self, [v[0], v[1], v[4]]),
            			new Triangle3D(_self, [v[0], v[2], v[3]]),
            			new Triangle3D(_self, [v[0], v[2], v[4]]),
            			new Triangle3D(_self, [v[1], v[5], v[6]]),
            			new Triangle3D(_self, [v[0], v[7], v[8]]),
            			new Triangle3D(_self, [v[1], v[9], v[10]]),
            			new Triangle3D(_self, [v[0], v[11], v[12]])
  	          	];
//            _self = new PaperPlane(wm);
  	        scene.addChild(_self);
  	        
  	        var cm : ColorMaterial = new ColorMaterial(0x7fffff, 0.3);
  	        cm.doubleSided = true;
  	        _selfTrack = new Track(
  	        		cm, 100, 
  	        		-10, 0, 0,
  	        		10, 0, 0,
  	        		5);
  	        scene.addChild(_selfTrack);
  	        
        		_cm = new ColorMaterial(0xffffff, 0.5);
        		_cm.doubleSided = true;
  	        
  	        // camera
  	        _camera = new RidingCamera(_self, new Number3D(0, 1, 0));
            
            stage.addEventListener(MouseEvent.CLICK, onClick);
            startRendering();
            
            mouseChildren = false;
        }
        
        override protected function onRenderTick(e : Event = null) : void
        {
        		// move self
        		var nx : Number = -(stage.mouseY - stage.stageHeight / 2);
        		var ny : Number = -(stage.mouseX - stage.stageWidth / 2);
        		if(Math.abs(nx) < 100)nx = 1;
        		if(Math.abs(ny) < 100)ny = 1;
        		
        		var X : Number3D = Number3D.cross(_v, _up);
        		if(nx != 0 || ny != 0){
	        		var N : Number3D = new Number3D(
	        			nx * X.x + ny * _up.x,
	        			nx * X.y + ny * _up.y,
	        			nx * X.z + ny * _up.z
	        		);
	        		var nn : Number = N.modulo;
	        		N.normalize();
	        		
			    var retaq : Array = QCamera3D.applyQuaternion([_v, _up], N, nn * 0.00015);
			    _v = retaq[0];
			    _up = retaq[1];
        		}
		    
		    var L : Number = 10;
		    _selfTrack.push(
		    		_self.x - X.x * L, _self.y - X.y * L, _self.z - X.z * L,
		    		_self.x + X.x * L, _self.y + X.y * L, _self.z + X.z * L
		    	);
		    
//		    _self.position.plusEq(_v);
			_self.x += _v.x * 8;
			_self.y += _v.y * 8;
			_self.z += _v.z * 8;
			QCamera3D.setLookAt(_self, _v, _up);
		    
		    if(Math.abs(_self.x) > 2000)_self.x = -_self.x;
		    if(Math.abs(_self.y) > 2000)_self.y = -_self.y;
		    if(Math.abs(_self.z) > 2000)_self.z = -_self.z;
        	
        		RidingCamera(_camera).move(150, 500);
			
        		// stars
            for each(var p : Particle in _particles){
				if(_locked[p] == null && p.renderScale < 20 && p.renderScale >= 0.2){
	            		var dx : Number = p.renderRect.x + p.renderRect.width / 2 - (stage.mouseX - stage.stageWidth / 2);
	            		var dy : Number = p.renderRect.y + p.renderRect.height / 2 - (stage.mouseY - stage.stageHeight / 2);
	            		if(dx * dx + dy * dy < 100 * 100){
						_locked[p] = _time;
	            		}
				}
            }
            
            super.onRenderTick(e);
            
            // lock-on gauge
        		graphics.clear();
        		graphics.lineStyle(1, 0xffffff);
        		graphics.drawCircle(stage.mouseX, stage.mouseY, 100);
        	
        		var i : int;
        		for(var key : Object in _locked){
        			p = Particle(key);
	        		graphics.lineStyle(1, _locked[p] >= 1 ? 0xffff00 : 0xff0000);
        			var t : Number = Math.min((_time - _locked[p]) / 10, 0.98);
        			var w : Number = stage.stageWidth * 5 * (1 - t) + p.renderRect.width * t;
        			var x : Number = p.renderRect.x + p.renderRect.width / 2 + stage.stageWidth / 2 - w / 2;
        			var y : Number = p.renderRect.y + p.renderRect.height / 2 + stage.stageHeight / 2 - w / 2;
        			var cx : Number = p.renderRect.x + p.renderRect.width / 2 + stage.stageWidth / 2;
        			var cy : Number = p.renderRect.y + p.renderRect.height / 2 + stage.stageHeight / 2;
        			
        			var offI : Number = w / 6;
        			var offO : Number = w / 8;
        			graphics.moveTo(cx, cy - offI);
        			graphics.lineTo(cx - offO, cy - w / 2);
        			graphics.lineTo(cx + offO, cy - w / 2);
        			graphics.lineTo(cx, cy - offI);
        			
        			graphics.moveTo(cx, cy + offI);
        			graphics.lineTo(cx - offO, cy + w / 2);
        			graphics.lineTo(cx + offO, cy + w / 2);
        			graphics.lineTo(cx, cy + offI);
        			
        			graphics.moveTo(cx - offI, cy);
        			graphics.lineTo(cx - w / 2, cy - offO);
        			graphics.lineTo(cx - w / 2, cy + offO);
        			graphics.lineTo(cx - offI, cy);
        			
        			graphics.moveTo(cx + offI, cy);
        			graphics.lineTo(cx + w / 2, cy - offO);
        			graphics.lineTo(cx + w / 2, cy + offO);
        			graphics.lineTo(cx + offI, cy);
        			
        			/*
        			graphics.drawRect(
        				p.renderRect.x + p.renderRect.width / 2 + stage.stageWidth / 2 - w / 2, 
        				p.renderRect.y + p.renderRect.height / 2 + stage.stageHeight / 2 - w / 2,
        				w, w);
        				*/
        		}
        		
        		// AAM
			var TL : Number = 3;
        		for(i = _aams.length - 1;i >= 0;i--){
        			var aam : AAM = _aams[i];
        			aam.step();
		
				var AX : Number3D = Number3D.cross(aam._front, aam._up);
				aam.track.push(
					aam.x - X.x * TL, aam.y - X.y * TL, aam.z - X.z * TL,
					aam.x + X.x * TL, aam.y + X.y * TL, aam.z + X.z * TL
					);
					
        			var d2 : Number = 
        				(aam.x - aam._targ.x) * (aam.x - aam._targ.x) +
        				(aam.y - aam._targ.y) * (aam.y - aam._targ.y) +
        				(aam.z - aam._targ.z) * (aam.z - aam._targ.z);
        				
        			if(d2 < 100){
        				scene.removeChild(_aams[i]);
        				removeElement(_aams, i);
        				
        				// explode
                     _hsv.hsv(Math.random() * 360, 1, 1);
   					var V : Number = Math.random() * 1.5 + 2.5;
        				for(var j : uint = 0;j < 500;j++){
        					var dbz : Number = Math.random() * 2 - 1;
        					var dbphi : Number = Math.random() * 2 * Math.PI;
        					var dbxy : Number = Math.sqrt(1 - dbz * dbz);
        					
        					_ds.addPixel3D(new Debris(
        						_hsv.value | 0xff000000,
        						aam._targ.x, aam._targ.y, aam._targ.z, 
        						V * dbxy * Math.cos(dbphi), V * dbxy * Math.sin(dbphi), V * dbz,
        						60));
        				}
        				
        				delete _locked[aam._targ];
        				aam._targ.x = Math.random() * 2000 - 1000;
        				aam._targ.y = Math.random() * 2000 - 1000;
        				aam._targ.z = Math.random() * 2000 - 1000;
        				
        				_tracks.push(aam.track);
        			}
        		}
        		
        		// tracks
        		for(i = _tracks.length - 1;i >= 0;i--){
        			var tr : Track = _tracks[i];
        			if(tr.rollUp()){
        				scene.removeChild(tr);
        				removeElement(_tracks, i);
        			}
        		}
        		
        		// Debris
        		for(i = _ds.pixels.length - 1;i >= 0;i--){
        			var db : Debris = Debris(_ds.pixels[i]);
        			db.step();
        			if(db.life == 0){
        				removeElement(_ds.pixels, i);
        			}
        		}
        		
        		_time++;
        }
        
        private function onClick(e : MouseEvent) : void
        {
        		for(var key : Object in _locked){
        			if(_locked[key] != -1){
	        			var aam : AAM = new AAM(_self.x, _self.y, _self.z, _v, _up, 12, 0.02, Particle(key));
	        			aam.track = new Track(_cm, 80, _self.x, _self.y, _self.z, _self.x, _self.y, _self.z, 4);
	        			scene.addChild(aam);
	        			scene.addChild(aam.track);
	        			_aams.push(aam);
	        			_locked[key] = -1;
        			}
        		}
        }
        
        private static function removeElement(a : Array, ind : uint) : Array
        {
        		if(ind == a.length - 1){
        			a.pop();
        		}else{
        			a[ind] = a.pop();
        		}
        		return a;
        }
        
        private function tr(...o : Array) : void
        {
            _tf.appendText(o + "\n");
            _tf.scrollV = _tf.maxScrollV;
        }
    }
}

class Debris extends Pixel3D
{
	private var _vx : Number;
	private var _vy : Number;
	private var _vz : Number;
	public var life : int;

	public function Debris(color : uint, x : Number, y : Number, z : Number, vx : Number, vy : Number, vz : Number, life : int)
	{
		super(color, x, y, z);
		_vx = vx; _vy = vy; _vz = vz;
		this.life = life;
	}
	
	public function step() : void
	{
		x += _vx;
		y += _vy;
		z += _vz;
		life--;
	}
}

import org.papervision3d.core.geom.*;

class Track extends TriangleMesh3D
{
	private var _len : uint;
	private var _nRoll : uint;
	
	public function Track(material : MaterialObject3D, len : uint, ax : Number, ay : Number, az : Number, bx : Number, by : Number, bz : Number, interval : uint = 1)
	{
		_len = len;
		_nRoll = 0;
		
		var i : uint;
		var vertices : Array = [];
		for(i = 0;i < len;i++){
			vertices.push(new Vertex3D(ax, ay, az));
			vertices.push(new Vertex3D(bx, by, bz));
		}
		var triangles : Array = [];
		for(i = 0;i < len - interval;i+=interval){
			triangles.push(new Triangle3D(this, [vertices[2*i], vertices[2*i+1], vertices[2*i+2*interval]], material));
			triangles.push(new Triangle3D(this, [vertices[2*i+1], vertices[2*i+2*interval], vertices[2*i+2*interval+1]], material));
		}
		super(material, vertices, triangles);
	}
	
	public function push(ax : Number, ay : Number, az : Number, bx : Number, by : Number, bz : Number) : void
	{
		for(var i : int = 2 * _len - 3;i >= 0;i--){
			geometry.vertices[i+2].x = geometry.vertices[i].x;
			geometry.vertices[i+2].y = geometry.vertices[i].y;
			geometry.vertices[i+2].z = geometry.vertices[i].z;
		}
		geometry.vertices[0].x = ax;
		geometry.vertices[0].y = ay;
		geometry.vertices[0].z = az;
		geometry.vertices[1].x = bx;
		geometry.vertices[1].y = by;
		geometry.vertices[1].z = bz;
	}
	
	public function rollUp() : Boolean
	{
		for(var i : int = 2 * _len - 3;i >= 0;i--){
			geometry.vertices[i+2].x = geometry.vertices[i].x;
			geometry.vertices[i+2].y = geometry.vertices[i].y;
			geometry.vertices[i+2].z = geometry.vertices[i].z;
		}
		_nRoll++;
		return _nRoll >= _len;
	}
}

import org.papervision3d.core.math.*;
import org.papervision3d.objects.*;
import org.papervision3d.cameras.*;
import org.papervision3d.objects.primitives.*;
import org.papervision3d.core.proto.*;
import org.papervision3d.materials.*;
import org.papervision3d.core.geom.renderables.*;

class AAM extends Cone
{
	public var _front : Number3D;
	public var _up : Number3D;
	private var _v : Number;
	private var _omega : Number;
//	private var _targ : DisplayObject3D;
	public var _targ : Particle;
	private static var _m : MaterialObject3D = new WireframeMaterial(0x00ff00);
	public var track : Track = null;
	
	public function AAM(x : Number, y : Number, z : Number, front : Number3D, up : Number3D, v : Number, omega : Number, targ : Particle)
	{
		super(_m, 8, 40, 4, 1);
		this.x = x;
		this.y = y;
		this.z = z;
		_front = front.clone();
		_up = up.clone();
		_v = v;
		_omega = omega;
		_targ = targ;
	}
	
	public function step() : void
	{ 
//		var t : Number3D = Number3D.sub(_targ.vertex3D.position, this.position);
		var t : Number3D = new Number3D(
			_targ.x - position.x,
			_targ.y - position.y,
			_targ.z - position.z
			);
		t.normalize();
		var cost : Number = Number3D.dot(_front, t);
		if(cost < 0.999){
			var N : Number3D = Number3D.cross(_front, t);
			cost = Math.acos(cost);
			var theta : Number = cost < _omega ? cost : _omega;
		    var retaq : Array = QCamera3D.applyQuaternion([_front, _up], N, theta);
		    _front = retaq[0];
		    _up = retaq[1];
		}
		x += _front.x * _v;
		y += _front.y * _v;
		z += _front.z * _v;
		
		_omega += 0.002; // :P
		
		this.localRotationX = 0;
		QCamera3D.setLookAt(this, _front, _up); 
		this.localRotationX = 90;
	}
}

// ジンバルロックを解消した以外はCamera3Dと同じ
class QCamera3D extends Camera3D
{
    public var _up : Number3D; // カメラの上の向きの単位ベクトル
    protected var _front : Number3D;
    private var _prevDir : Number3D;
    
    public function QCamera3D(up : Number3D, front : Number3D = null)
    {
        super();
        _up = null;
        init(up, front);
    }
    
    // prevDirからcurDirへ向ける回転を_upにかけるだけ。カメラ自体に操作はしない
    public function rotate(curDir : Number3D) : void
    {
        if(_prevDir != null){
            var n : Number3D = Number3D.cross(_prevDir, curDir);
//            if(n.moduloSquared > 0.00000001){
            if(n.moduloSquared != 0){
                n.normalize();
                var angle : Number = Math.acos(Number3D.dot(_prevDir, curDir));
                if(_front != null){
                    var a : Array = applyQuaternion([_front, _up], n, angle);
                    _front = a[0];
                    _up = a[1];
                }else{
                    _up = applyQuaternion([_up], n, angle)[0];
                }
            }
            _prevDir.copyFrom(curDir);
        }else{
            _prevDir = curDir.clone();
        }
    }
    
    // カメラの右方向へx[rad], 上方向へy[rad]回転させる
    public function rotateXY(x : Number, y : Number) : void
    {
        if(_front == null)return;
        
        // X方向の移動
        _front = applyQuaternion([_front], _up, -x)[0];
        
        // Y方向の移動
        var right : Number3D = Number3D.cross(_up, _front);
        right.normalize();
        var ret : Array = applyQuaternion([_front, _up], right, y);
        _front = ret[0];
        _up = ret[1];
    }
    
    public function head() : void
    {
        if(_front != null){
            var Z : Number3D = _front.clone();
            Z.normalize();
            
	    		var X : Number3D = Number3D.cross(Z, _up);
	    		X.normalize();
	    		
	    		var Y : Number3D = Number3D.cross(Z, X);
	    		Y.normalize();
	    		
	    		var look : Matrix3D = this.transform;
	    		look.n11 = X.x*this.scaleX; look.n21 = X.y*this.scaleY; look.n31 = X.z*this.scaleZ;
	    		look.n12 = -Y.x*this.scaleX; look.n22 = -Y.y*this.scaleY; look.n32 = -Y.z*this.scaleZ;
	    		look.n13 = Z.x*this.scaleX; look.n23 = Z.y*this.scaleY; look.n33 = Z.z*this.scaleZ;
        }
    } 
    
    public function init(up : Number3D = null, front : Number3D = null) : void
    {
        if(up != null){
            _up = up.clone();
            _up.normalize();
        }
        if(front != null){
            _front = front.clone();
            _front.normalize();
        }else{
            _front = null;
        }
        _prevDir = null;
    }
    
    // axisを軸にangle回転させる変換を、srcsの要素それぞれに適用する
    public static function applyQuaternion(srcs : Array, axis : Number3D, angle : Number) : Array
    {
        var q : Quaternion = Quaternion.createFromAxisAngle(
            axis.x / axis.modulo, 
            axis.y / axis.modulo, 
            axis.z / axis.modulo,
            angle
            );
        var qc : Quaternion = Quaternion.conjugate(q);
        
        var ret : Array = [];
        for each(var src : Number3D in srcs){
            var qSrc : Quaternion = new Quaternion(src.x, src.y, src.z, 0);
            var qDst : Quaternion = Quaternion.multiply(qc, qSrc);
            qDst.mult(q);
            ret.push(new Number3D(qDst.x, qDst.y, qDst.z));
        }
        return ret;
    }
    
    public static function setLookAt(d : DisplayObject3D, front : Number3D, up : Number3D) : void
    {
    		var X : Number3D = Number3D.cross(front, up);
    		var look : Matrix3D = d.transform;
    		look.n11 = X.x; look.n21 = X.y; look.n31 = X.z;
    		look.n12 = -up.x; look.n22 = -up.y; look.n32 = -up.z;
    		look.n13 = front.x; look.n23 = front.y; look.n33 = front.z;
    }
    
}

class RidingCamera extends QCamera3D
{
    private var _ride : DisplayObject3D;
    private var _prevPos : Number3D;
    
    public function RidingCamera(ride : DisplayObject3D, up : Number3D, front : Number3D = null)
    {
        super(up, front);
        _ride = ride;
        _prevPos = _ride.position.clone();
    }

    public function move(up : Number = 0, back : Number = 0) : void
    {
        var curDir : Number3D = Number3D.sub(_ride.position, _prevPos);
        curDir.normalize();
        if(_front == null){
            _front = curDir.clone();
        }
        rotate(curDir);
        
        var curPos : Number3D = _ride.position.clone();
        var temp : Number3D;
        temp = _up.clone();
        temp.multiplyEq(up);
        curPos.plusEq(temp);
        temp = _front.clone();
        temp.multiplyEq(-back);
        curPos.plusEq(temp);
        this.position = curPos;
        
        head();
        _prevPos.copyFrom(_ride.position);
    }
}

