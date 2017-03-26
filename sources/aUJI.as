package {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.geom.Point;
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.tweens.*;
    import org.libspark.betweenas3.events.*;
    import org.libspark.betweenas3.easing.*;
    import org.papervision3d.core.math.Quaternion;
    import net.hires.debug.Stats;
    import frocessing.color.ColorHSV;
        
    [SWF(backgroundColor="#000000", frameRate=60)]
    public class Test extends Sprite {
        private var _viewport : Shape;
        private var _matWorld : Matrix3D;
        private var _matView : Matrix3D;
        private var _matProj : Matrix3D;
        
        private var _tf : TextField;
        
        private var _vertices : Vector.<Number>; // 道を描く頂点の3D座標
        private var _centers : Array; // 道の中心の3D座標
        
        private const R : Number = 500; // 節点生成時の最大半径
  
        private var _nodes : Array; // Bスプラインの節点
        private var _cor : Array; // Bスプラインの係数
        private var _tween : ITween; // Tweener
        private var _tlap : Object; // t格納用
        
        private var _prevX : Vector3D; // 道路描画時の直前のX方向
        private var _prevY : Vector3D; // 道路描画時の直前のY方向(カメラの上)
        private var _prevZ : Vector3D; // 道路描画時の直前のZ方向(正面)
        
        private var _Ys : Array; // 道の各地点でのカメラの上方向
        
        private var _colors : Array;
        private var _hsv : ColorHSV;
        
        public function Test() {
            _viewport = new Shape();
            _viewport.x = stage.stageWidth / 2;
            _viewport.y = stage.stageHeight / 2;
            addChild(_viewport);
            
            _tf = new TextField();
            _tf.width = 465;
            _tf.height = 465;
            _tf.textColor = 0xffffff;
//            addChild(_tf);
            
            init();
        }
        
        private function init() : void
        {
            _tlap = {};
            _cor = [
                new Vector3D(),
                new Vector3D(),
                new Vector3D(),
                new Vector3D()
                ];
            
            _matWorld = new Matrix3D();
            _matView = new Matrix3D();
            _matProj = new Matrix3D(Vector.<Number>([
                20, 0, 0, 0,
                0, 20, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
                ]));
            
            _nodes = [];
            _nodes.push(new Vector3D(0, 0, 0));
            _nodes.push(new Vector3D(0, 0, 0));
            _nodes.push(new Vector3D(0, 0, 0));
            _nodes.push(new Vector3D(0, 0, R)); // 最初まっすぐ進まないとゆがむ?
            
            _vertices = new Vector.<Number>();
            
            _prevX = Vector3D.X_AXIS;
            _prevY = Vector3D.Y_AXIS;
            _prevZ = Vector3D.Z_AXIS;
            
            _centers = [new Vector3D(), new Vector3D()];
            _Ys = [Vector3D.Y_AXIS, Vector3D.Y_AXIS];
            _colors = [0xffffff, 0xffffff];
            _hsv = new ColorHSV(0, 1, 1, 1);
            
            // 先に道をいくらかつくっておく
            for(var r : uint = 0;r < 12;r++){
                for each(var k : String in ["x", "y", "z"]){
                    _cor[3][k] = (-_nodes[0][k] + 3 * _nodes[1][k] - 3 * _nodes[2][k] + _nodes[3][k]) / 6;
                    _cor[2][k] = (_nodes[0][k] - 2 * _nodes[1][k] + _nodes[2][k]) / 2;
                    _cor[1][k] = (-_nodes[0][k] + _nodes[2][k]) / 2;
                    _cor[0][k] = (_nodes[0][k] + 4 * _nodes[1][k] + _nodes[2][k]) / 6;
                }
                
                _nodes.shift();
                // 20度以下の鋭角カーブを除去
                var prevDir : Vector3D = _nodes[_nodes.length - 1].subtract(_nodes[_nodes.length - 2]);
                var node : Vector3D;
                do{
                    node = makeNode();
                }while(Vector3D.angleBetween(prevDir, node.subtract(_nodes[_nodes.length - 1])) > Math.PI * 160 / 180);
                _nodes.push(node);
                
                for(var t : Number = 0;t < 1.0;t += 0.7 / 25){
                    _tlap.t = t;
                    buildRoad(false);
                }
            }
            
            // 消える前5つぶんの箇所を現在地とするように
            _centers.splice(0, 5);
            _Ys.splice(0, 5);
            _colors.splice(0, 5);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addChild(new Stats());
            
            onComplete();
        }
        
        private function onEnterFrame(e : Event) : void
        {
            buildRoad(true);
            rotCamera();
            render();
        }
        
        // 節点を更新する
        private function onComplete() : void
        {
            // 係数を更新
            for each(var k : String in ["x", "y", "z"]){
                _cor[3][k] = (-_nodes[0][k] + 3 * _nodes[1][k] - 3 * _nodes[2][k] + _nodes[3][k]) / 6;
                _cor[2][k] = (_nodes[0][k] - 2 * _nodes[1][k] + _nodes[2][k]) / 2;
                _cor[1][k] = (-_nodes[0][k] + _nodes[2][k]) / 2;
                _cor[0][k] = (_nodes[0][k] + 4 * _nodes[1][k] + _nodes[2][k]) / 6;
            }
            
            //　節点の作成
            _nodes.shift();
            // 20度以下の鋭角カーブを除去
            var prevDir : Vector3D = _nodes[_nodes.length - 1].subtract(_nodes[_nodes.length - 2]);
            var node : Vector3D;
            do{
                node = makeNode();
            }while(Vector3D.angleBetween(prevDir, node.subtract(_nodes[_nodes.length - 1])) > Math.PI * 160 / 180);
            _nodes.push(node);
            
            // 新しいTween
            _tween = BetweenAS3.tween(_tlap, {t : 1.0}, {t : 0.0}, 0.7);
            _tween.onComplete = onComplete;
            _tween.play();
        }
        
        // 節点を作成する
        private function makeNode() : Vector3D
        {
            var theta : Number = Math.random() * Math.PI * 2;
            var phi : Number = Math.random() * Math.PI * 2;
            return new Vector3D(
                    Math.cos(theta) * Math.sin(phi) * R,
                    Math.sin(theta) * Math.sin(phi) * R,
                    Math.cos(phi) * R
                    );
        }
        
        // 道をつくる
        // @param erase 作成と同時に頂点集合を後ろから削るかどうか
        private function buildRoad(erase : Boolean = true) : void
        {
            // 新しい座標を得る
            var t : Number = _tlap.t;
            var curPos : Vector3D = new Vector3D(
                (((_cor[3].x * t + _cor[2].x) * t) + _cor[1].x) * t + _cor[0].x,
                (((_cor[3].y * t + _cor[2].y) * t) + _cor[1].y) * t + _cor[0].y,
                (((_cor[3].z * t + _cor[2].z) * t) + _cor[1].z) * t + _cor[0].z
                );
            var prevPos : Vector3D = _centers[_centers.length - 1];
            var curZ : Vector3D = curPos.subtract(prevPos);
            curZ.normalize();
            
            // 新しい座標に従ってX, Yを回転させる
            var curX : Vector3D, curY : Vector3D;
            var dot : Number = _prevZ.dotProduct(curZ);
            if(dot < 0.999999){
                var n : Vector3D = curZ.crossProduct(_prevZ);
                n.normalize();
                var angle : Number = Math.acos(dot);
                var q : Quaternion = Quaternion.createFromAxisAngle(n.x, n.y, n.z, angle);
                var qconj : Quaternion = Quaternion.conjugate(q);
                
                curX = applyQuaternion(_prevX, q, qconj);
                curY = applyQuaternion(_prevY, q, qconj);
            }else{
                curX = _prevX;
                curY = _prevY;
            }
            
            // 線の座標を格納。
            var W : Number = 10;
            _vertices.push(
                prevPos.x + _prevX.x * W,
                prevPos.y + _prevX.y * W,
                prevPos.z + _prevX.z * W,
                curPos.x + curX.x * W,
                curPos.y + curX.y * W,
                curPos.z + curX.z * W
                );
            _vertices.push(
                prevPos.x - _prevX.x * W,
                prevPos.y - _prevX.y * W,
                prevPos.z - _prevX.z * W,
                curPos.x - curX.x * W,
                curPos.y - curX.y * W,
                curPos.z - curX.z * W
                );
            _vertices.push(
                curPos.x - curX.x * W,
                curPos.y - curX.y * W,
                curPos.z - curX.z * W,
                curPos.x + curX.x * W,
                curPos.y + curX.y * W,
                curPos.z + curX.z * W
                );
            
            _prevX = curX;
            _prevY = curY;
            _prevZ = curZ;
            
            if(erase){
                _vertices.splice(0, 18);
                _colors.shift();
            }
            
            _centers.push(curPos);
            _Ys.push(_prevY.clone());
            _hsv.h += 0.6;
            _colors.push(_hsv.value);
        }
        
        // srcにクォータニオンqを適用して回転させる
        private function applyQuaternion(src : Vector3D, q : Quaternion, qc : Quaternion) : Vector3D
        {
            var qSrc : Quaternion = new Quaternion(src.x, src.y, src.z, 0);
            var qDst : Quaternion = Quaternion.multiply(qc, qSrc);
            qDst.mult(q);
            return new Vector3D(qDst.x, qDst.y, qDst.z);
        }
        
        // 道を描画する
        private function render() : void
        {
            // 変換用行列
            var m : Matrix3D = new Matrix3D();
            m.append(_matWorld);
            m.append(_matView);
            m.append(_matProj);
            
            // 頂点集合を変換
            var vout : Vector.<Number> = new Vector.<Number>(_vertices.length);
            m.transformVectors(_vertices, vout);
            
            var focalLength : Number = 10;
            var g : Graphics = _viewport.graphics;
            var mul2 : Number, mul5 : Number;
            g.clear();
            for(var i : uint = 0;i < vout.length;i += 6){
                // 線分の頂点のどちらも可視の場合
                if(vout[i+2] >= 0 && vout[i+5] >= 0){
                    g.lineStyle(2, _colors[uint(i / 18)], 0.5);
                    mul2 = focalLength / (focalLength + vout[i+2]);
                    mul5 = focalLength / (focalLength + vout[i+5]);
                    g.moveTo(vout[i] * mul2, vout[i+1] * mul2);
                    g.lineTo(vout[i+3] * mul5, vout[i+4] * mul5);
//                    g.moveTo(vout[i] / vout[i+2], vout[i+1] / vout[i+2]);
//                    g.lineTo(vout[i+3] / vout[i+5], vout[i+4] / vout[i+5]);
                    continue;
                }
                // 線分の頂点の一方が可視の場合
                if(vout[i+2] >= 0){
                    g.lineStyle(2, _colors[uint(i / 18)], 0.5);
                    mul2 = focalLength / (focalLength + vout[i+2]);
                    g.moveTo(vout[i] * mul2, vout[i+1] * mul2);
//                    g.moveTo(vout[i] / vout[i+2], vout[i+1] / vout[i+2]);
                    g.lineTo(vout[i] * 10, vout[i+1] * 10);
                    continue;
                }
                if(vout[i+5] >= 0){
                    g.lineStyle(2, _colors[uint(i / 18)], 0.5);
                    mul5 = focalLength / (focalLength + vout[i+5]);
//                    g.moveTo(vout[i+3] / vout[i+5], vout[i+4] / vout[i+5]);
                    g.moveTo(vout[i+3] * mul5, vout[i+4] * mul5);
                    g.lineTo(vout[i+3] * 10, vout[i+4] * 10);
                    continue;
                }
            }
        }
        
        // カメラをまわす
        private function rotCamera() : void
        {
            var pos : Vector3D = _centers.shift();
            var YCamera : Vector3D = _Ys.shift();
            
            // 10個分先を見る
            var curZCamera : Vector3D = _centers[10].subtract(pos);
            curZCamera.normalize();
            
            _matView = lookAt(curZCamera, YCamera);
            // ワールド座標系にはマイナスで足していく
            _matWorld.identity();
            _matWorld.appendTranslation(-pos.x, -pos.y, -pos.z);
            _matWorld.appendTranslation(-YCamera.x * 5, -YCamera.y * 5, -YCamera.z * 5);
            _matWorld.appendTranslation(-curZCamera.x * 5, -curZCamera.y * 5, -curZCamera.z * 5);
        }
        
        // Z・Y=0としたときのlookAt
        private function lookAt(Z : Vector3D, Y : Vector3D) : Matrix3D
        {
            var X : Vector3D = Z.crossProduct(Y);
            X.normalize();
            return new Matrix3D(Vector.<Number>([
                X.x, -Y.x, Z.x, 0,
                X.y, -Y.y, Z.y, 0,
                X.z, -Y.z, Z.z, 0,
                0, 0, 0, 1
                ]));
        }

        private function tr(...o : Array) : void
        {
            _tf.appendText(o + "\n");
        }
    }
}
