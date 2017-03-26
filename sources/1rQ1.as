// forked from itr0510's Voronoi 3D 
// forked from yamat1011's forked from: forked from: flash on 2011-3-14
// forked from yamat1011's forked from: flash on 2011-3-14
// forked from yamat1011's flash on 2011-3-14

// Frederik Vanhoutte氏のコードを参考にしています > http://www.wblut.com/2009/05/04/snippets-ii/

package
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import net.hires.debug.Stats;
    
    import org.papervision3d.core.geom.TriangleMesh3D;
    import org.papervision3d.lights.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.shadematerials.*;
    import org.papervision3d.render.QuadrantRenderEngine;
    import org.papervision3d.view.BasicView;
    
    [SWF(backgroundColor="#000000")]
    
    public class voronoi3D extends BasicView
    {
        private var center  :Point;
        
        //PV3D
        private var material:FlatShadeMaterial;
        private var wMaterial:FlatShadeMaterial;
        private var light   :PointLight3D;
        
        private var degX :Number = 90, degY :Number = 90;
        private var vDegX:Number = 0,  vDegY:Number = 0;
        
        private var cell_num   :int    = 5;
        private var offset_size:Number = 10;
        private var round_size :Number = 10;
        
        private var HALF_WIDTH :Number = 275;
        private var HALF_HEIGHT:Number = 275;
        private var HALF_DEPTH :Number = 275;
        
        private var sites       :Vector.<Vector3D>;
        private var container   :Mesh;
        private var voronoiCells:Vector.<Mesh> = new Vector.<Mesh>();;
        
        private var mouseLeave:Boolean = true;
        
        public  function voronoi3D()
        {
            stage.frameRate = 30;
            stage.align     = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality   = StageQuality.BEST;
            
            init();
        }
        
        private function init():void
        {
            var stats:Stats = new Stats();
            stats.x = stats.y = 10;
            addChild(stats);
            
            center  = new Point(stage.stageWidth / 2,stage.stageHeight / 2);
            
            // init PV3D //
            light =new PointLight3D();
            light.x = camera.x;
            light.y = camera.y;
            light.z = camera.z;
            material = new FlatShadeMaterial(light,0xFFFFFF, 0x333333);
            renderer = new QuadrantRenderEngine(QuadrantRenderEngine.ALL_FILTERS);
            
            createCells();
            createContainer();
            createVoronoi();
            
            // レンダリング開始 //
            startRendering();
            
            stage.addEventListener(Event.ENTER_FRAME,     onEnterFrame );
            stage.addEventListener(Event.RESIZE,          onStageResize);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown  );
            // マウスがステージの外にでたときのカメラの挙動が気になったので
            stage.addEventListener(Event.MOUSE_LEAVE,     function(e:Event)        :void {mouseLeave = true; });
            stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent)   :void {mouseLeave = false;});
        }
        
        private function createCells():void
        {
            sites = new Vector.<Vector3D>();
            for(var i:int=0;i<cell_num;i++){
                var c:Vector3D = new Vector3D(
                    Math.random() * HALF_WIDTH *2- HALF_WIDTH,
                    Math.random() * HALF_HEIGHT*2- HALF_HEIGHT,
                    Math.random() * HALF_DEPTH *2- HALF_DEPTH
                );
                sites.push(c);
            }
        }
        
        private function createContainer():void
        {
            var tmpVertices:Vector.<Vector3D> = new <Vector3D>[
                new Vector3D( HALF_WIDTH, HALF_HEIGHT, HALF_DEPTH),
                new Vector3D(-HALF_WIDTH, HALF_HEIGHT, HALF_DEPTH),
                new Vector3D(-HALF_WIDTH, HALF_HEIGHT,-HALF_DEPTH),
                new Vector3D( HALF_WIDTH, HALF_HEIGHT,-HALF_DEPTH),
                new Vector3D( HALF_WIDTH,-HALF_HEIGHT, HALF_DEPTH),
                new Vector3D(-HALF_WIDTH,-HALF_HEIGHT, HALF_DEPTH),
                new Vector3D(-HALF_WIDTH,-HALF_HEIGHT,-HALF_DEPTH),
                new Vector3D( HALF_WIDTH,-HALF_HEIGHT,-HALF_DEPTH)
            ];
            
            var tmpFacesIndex:Vector.< Vector.<int> > = new < Vector.<int> >[
                new <int>[0,1,2,3],
                new <int>[1,0,4,5],
                new <int>[0,3,7,4],
                new <int>[2,1,5,6],
                new <int>[5,4,7,6],
                new <int>[3,2,6,7]                
            ];
            
            container = new Mesh();    
            container.buildMesh(tmpVertices,tmpFacesIndex);
            container.roundEdges(round_size);
            container.roundCorners(round_size);
        }
        
        private function createVoronoi():void
        {    
            for(var i:int = 0;i < sites.length; i++){
                voronoiCells[i] = container.get();
            }
            
            
            for(i=0;i<sites.length;i++){
                for(var j:int=0;j<sites.length;j++){
                    if(i!=j){
                        var n:Vector3D = sites[i].subtract(sites[j]);
                        n.normalize();
                        var o:Vector3D = sites[i].add(sites[j]);
                        o.scaleBy(0.5);
                        o.x += n.x * offset_size;
                        o.y += n.y * offset_size;
                        o.z += n.z * offset_size;
                        var p:Plane = new Plane(o,n);
                        voronoiCells[i].splitMesh(p,sites[i]);
                    }
                }
                var name:String = "cell"+String(i);
                if(scene.getChildByName(name)!=null) scene.removeChildByName(name);
                scene.addChild(voronoiCells[i].toTriangleMesh3D(material),name);
            }
            
        }
        
        private function onEnterFrame(event:Event):void
        {
            updateCamera();
        }
        
        private function updateCamera():void
        {
            if(!mouseLeave){
                vDegX = (center.x - mouseX) / 50;
                vDegY = (center.y - mouseY) / 50;
            }
            degY += vDegX;
            degX -= vDegY;
            if     (degX< 0)  degX = 0.1;
            else if(degX>180) degX = 179.9;
            camera.orbit(degX,degY,true);
            light.x = camera.x;
            light.y = camera.y;
            light.z = camera.z;
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            var c:Vector3D = new Vector3D(
                Math.random() * HALF_WIDTH *2- HALF_WIDTH,
                Math.random() * HALF_HEIGHT*2- HALF_HEIGHT,
                Math.random() * HALF_DEPTH *2- HALF_DEPTH
            );
            sites.push(c);
            createVoronoi();
        }
        
        private function onStageResize(event:Event):void
        {
            center.x = stage.stageWidth / 2;
            center.y = stage.stageHeight/ 2;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// class Mesh
///////////////////////////////////////////////////////////////////////////////////////
import flash.geom.*;
import org.papervision3d.core.geom.TriangleMesh3D;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.math.NumberUV;
import org.papervision3d.core.proto.MaterialObject3D;

class Mesh
{
    public var vertices :Vector.<Vertex>;
    public var faces    :Vector.<Face>;
    public var halfEdges:Vector.<HalfEdge>;
    public var edges    :Vector.<Edge>;
    
    public function Mesh()
    {
        vertices = new Vector.<Vertex>();
        faces    = new Vector.<Face>();
        halfEdges= new Vector.<HalfEdge>();
        edges    = new Vector.<Edge>();
    }
    
    public function buildMesh(simpleVertices:Vector.<Vector3D>,faceIndex:Vector.< Vector.<int> >):void
    {
        vertices = new Vector.<Vertex>();
        faces    = new Vector.<Face>();
        halfEdges= new Vector.<HalfEdge>();
        edges    = new Vector.<Edge>();
        
        for(var i:int=0;i<simpleVertices.length;i++){
            vertices.push(new Vertex(simpleVertices[i].x, simpleVertices[i].y, simpleVertices[i].z, i));
        }
        
        for(i=0;i<faceIndex.length;i++){
            var faceEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
            var hef:Face = new Face();
            faces.push(hef);
            for(var j:int=0;j<faceIndex[i].length;j++){
                var he:HalfEdge = new HalfEdge();
                faceEdges.push(he);
                he.face = hef;
                if (hef.halfEdge==null) hef.halfEdge=he;
                he.vert = vertices[faceIndex[i][j]];
                if(he.vert.halfEdge==null) he.vert.halfEdge=he; 
            }
            cycleHalfEdges(faceEdges,false);    
            halfEdges = halfEdges.concat(faceEdges);
        }
        
        pairHalfEdges(halfEdges);
        createEdges(halfEdges,edges);
        reindex();
    }
    
    public function get():Mesh
    {
        var result:Mesh = new Mesh();
        reindex();
        var i:int = 0;
        for(i=0;i<vertices.length;i++){
            result.vertices.push(vertices[i].get());
        }
        for(i=0;i<faces.length;i++){
            result.faces.push(new Face());
        }
        for(i=0;i<halfEdges.length;i++){
            result.halfEdges.push(new HalfEdge());
        }
        for(i=0;i<edges.length;i++){
            result.edges.push(new Edge());
        }
        
        for(i=0;i<vertices.length;i++){
            var sv:Vertex = vertices[i];
            var tv:Vertex = result.vertices[i];
            tv.halfEdge=result.halfEdges[sv.halfEdge.id];
        }
        for(i=0;i<faces.length;i++){
            var sf:Face = faces[i];
            var tf:Face = result.faces[i];
            tf.id=i;
            tf.halfEdge=result.halfEdges[sf.halfEdge.id];
        }
        for(i=0;i<edges.length;i++){
            var se:Edge = edges[i];
            var te:Edge = result.edges[i];
            te.halfEdge = result.halfEdges[se.halfEdge.id];
            te.id=i;
        }
        for(i=0;i<halfEdges.length;i++){
            var she:HalfEdge = halfEdges[i];
            var the:HalfEdge = result.halfEdges[i];
            the.pair = result.halfEdges[she.pair.id];
            the.next = result.halfEdges[she.next.id];
            the.prev = result.halfEdges[she.prev.id];
            the.vert = result.vertices[she.vert.id];
            the.face = result.faces[she.face.id];
            the.edge = result.edges[she.edge.id];
            the.id=i;
        }
        return result;
    }
    
    public function getDual():Mesh
    {
        var result:Mesh = new Mesh();
        reindex();
        var f:Face;
        var he:HalfEdge;
        for(var i:int=0;i<faces.length;i++){
            f  = faces[i];
            he = f.halfEdge;
            var faceCenter:Vector3D = new Vector3D();
            var n:int       = 0;
            do{
                faceCenter = faceCenter.add(he.vert);
                he=he.next;
                n++;
            }while(he!=f.halfEdge);
            faceCenter.scaleBy(1/n);
            result.vertices.push(new Vertex(faceCenter.x,faceCenter.y,faceCenter.z,i));
        }
        
        for(i=0;i<vertices.length;i++){
            var v:Vertex   = vertices[i];
            he = v.halfEdge;
            f  = he.face;
            
            var faceHalfEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
            var nf:Face                         = new Face();
            result.faces.push(nf);
            
            do{
                var hen:HalfEdge = new HalfEdge();
                faceHalfEdges.push(hen);
                hen.face=nf;
                hen.vert=result.vertices[f.id];
                if(hen.vert.halfEdge==null) hen.vert.halfEdge=hen;
                if (nf.halfEdge==null) nf.halfEdge=hen;
                he=he.pair.next;
                f=he.face;
            } while(he!=v.halfEdge);
            cycleHalfEdges(faceHalfEdges,false);    
            result.halfEdges = result.halfEdges.concat(faceHalfEdges);
            
        }
        result.pairHalfEdges(result.halfEdges);
        result.createEdges(result.halfEdges,result.edges);
        result.reindex();
        
        return result;
    }
    
    public function cycleHalfEdges(halfEdges:Vector.<HalfEdge>, reverse:Boolean):void
    {   
        var he:HalfEdge;
        var n:int = halfEdges.length;
        if(!reverse){
            he      = halfEdges[0];
            he.next = halfEdges[1];
            he.prev = halfEdges[n-1];
            for(var i:int=1;i<n-1;i++){
                he      = halfEdges[i];
                he.next = halfEdges[i+1];
                he.prev = halfEdges[i-1];//                    
            }
            he      = halfEdges[n-1];
            he.next = halfEdges[0];
            he.prev = halfEdges[n-2];
        } else {
            he      = halfEdges[0];
            he.prev = halfEdges[1];
            he.next = halfEdges[n-1];
            for(var j:int=1;j<n-1;j++){
                he      = halfEdges[j];
                he.prev = halfEdges[j+1];
                he.next = halfEdges[j-1];                    
            }
            he      = halfEdges[n-1];
            he.prev = halfEdges[0];
            he.next = halfEdges[n-2];
        } 
    }
    
    public function pairHalfEdges(halfEdges:Vector.<HalfEdge>):void
    {
        var n:int = halfEdges.length;
        for(var i:int=0;i<n;i++){
            var he:HalfEdge = halfEdges[i];
            if(he.pair==null){
                for(var j:int=0;j<n;j++){
                    if(i!=j){
                        var he2:HalfEdge = halfEdges[j];
                        if((he2.pair==null)&&(he.vert==he2.next.vert)&&(he2.vert==he.next.vert)){
                            he.pair=he2;
                            he2.pair=he;
                            break;              
                        }
                    }
                }
            }
        }
    }
    
    public function createEdges(halfEdges:Vector.<HalfEdge>, target:Vector.<Edge>):void
    {
        var n:int = halfEdges.length;
        for(var i:int=0;i<n;i++){
            var he:HalfEdge = halfEdges[i];
            for(var j:int=0;j<n;j++){
                if(i!=j){
                    var he2:HalfEdge = halfEdges[j];
                    if(he.pair==he2){
                        var e:Edge = new Edge();
                        e.halfEdge = he;
                        target.push(e);
                        he.edge    = e;
                        he2.edge   = e;
                        break;
                    }
                }
            }
        }
    }
    
    public function reindex():void
    {
        var i:int;
        for(i=0;i<vertices.length;i++){
            vertices[i].id = i;
        }
        for(i=0;i<faces.length;i++){
            faces[i].id = i;
        }
        for(i=0;i<halfEdges.length;i++){
            halfEdges[i].id = i;
        }
        for(i=0;i<edges.length;i++){
            edges[i].id = i;
        }
    }
    
    public function retrieveSplitEdges(p:Plane):Vector.<SplitEdge>
    {
        var splitEdges:Vector.<SplitEdge> = new Vector.<SplitEdge>();
        for(var i:int=0;i<edges.length;i++){
            var edge:Edge = edges[i];
            var intersection:Vector3D = p.intersection(edge);
            if(intersection!=null) splitEdges.push(new SplitEdge(edge,intersection));
        }
        return splitEdges;
    }
    
    public function splitMesh(p:Plane,center:Vector3D):void
    {
        var centerSide:int = p.side(center);
        if(centerSide!=0){
            var newVertices:Vector.<Vertex>    = new Vector.<Vertex>();
            var newFaces:Vector.<Face>         = new Vector.<Face>();
            var newHalfEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
            var newEdges:Vector.<Edge>         = new Vector.<Edge>();
            
            var splitEdges:Vector.<SplitEdge>  = retrieveSplitEdges(p);
            
            var sides:Vector.<int> = new Vector.<int>(vertices.length,true);
            var i:int=0;
            
            //　すべての頂点が平面に対し表か裏かを調べる
            for(i=0;i<vertices.length;i++){
                var v:Vertex = vertices[i];
                sides[i] = p.side(v);
            }
            
            for(i=0;i<faces.length;i++){
                var face:Face         = faces[i];
                var halfEdge:HalfEdge = face.halfEdge;
                // 母点側の頂点を入れる配列
                var newFaceVertices1:Vector.<Vertex>    = new Vector.<Vertex>();
                // 母点とは反対側の頂点を入れる配列
                //var newFaceVertices2:Vector.<Vertex>    = new Vector.<Vertex>();
                
                do{
                    // 母点側の頂点を追加
                    if(sides[halfEdge.vert.id]*centerSide>=0){
                        newFaceVertices1.push(halfEdge.vert); 
                    }
                    // 母点とは反対側の頂点を追加 使わない
                    //if(sides[halfEdge.vert.id]*centerSide<=0){
                    //    newFaceVertices2.push(halfEdge.vert); 
                    //}
                    
                    // すべての辺を走査し、平面と交差する辺の交点を
                    //　newFaceVertices1、newFaceVertices2に追加
                    for(var j:int=0;j<splitEdges.length;j++){
                        var se:SplitEdge = splitEdges[j];
                        if(halfEdge.edge==se.edge){
                            // 交点を追加
                            newFaceVertices1.push(se.splitVertex);
                            //newFaceVertices2.push(se.splitVertex);
                            break;
                        }
                    }
                    halfEdge = halfEdge.next;
                } while(halfEdge!=face.halfEdge);
                
                // 母点側の配列に新しい頂点が三つ以上ある時、面をつくり、
                //　面に関する情報をデータ構造に追加
                if(newFaceVertices1.length>2){
                    var newFace:Face = new Face();
                    newFaces.push(newFace);
                    var faceEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
                    for(j=0;j<newFaceVertices1.length;j++){
                        v = newFaceVertices1[j];
                        if(newVertices.indexOf(v)==-1) newVertices.push(v);//
                        var newHalfEdge:HalfEdge = new HalfEdge();
                        faceEdges.push(newHalfEdge);
                        newHalfEdge.vert=v;
                        v.halfEdge=newHalfEdge;
                        newHalfEdge.face=newFace;
                        if(newFace.halfEdge==null) newFace.halfEdge=newHalfEdge;
                    }
                    cycleHalfEdges(faceEdges,false);
                    newHalfEdges = newHalfEdges.concat(faceEdges);                         
                }
            }
            
            var n:int=newHalfEdges.length;
            pairHalfEdges(newHalfEdges);
            createEdges(newHalfEdges,newEdges);
            
            var unpairedEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
            for(i=0;i<n;i++){
                var he:HalfEdge = newHalfEdges[i];
                if(he.pair==null) unpairedEdges.push(he);
            }
            
            if(unpairedEdges.length>0){
                var cutFace:Face = new Face(); 
                faceEdges        = new Vector.<HalfEdge>();  
                he               = unpairedEdges[0];
                var hen:HalfEdge = he;
                
                do{
                    hen=he.next.pair.next;        //
                    while(unpairedEdges.indexOf(hen)==-1) hen=hen.pair.next;
                    var newhe:HalfEdge =new HalfEdge(); //
                    faceEdges.push(newhe);
                    if(cutFace.halfEdge==null) cutFace.halfEdge=newhe;
                    newhe.vert=hen.vert;
                    newhe.pair=he;
                    he.pair=newhe;
                    var e:Edge = new Edge(); //
                    e.halfEdge=newhe;
                    he.edge=e;
                    newhe.edge=e;
                    newEdges.push(e);
                    newhe.face=cutFace;
                    he=hen;
                } while(hen!=unpairedEdges[0]);
                
                cycleHalfEdges(faceEdges, true);
                newHalfEdges = newHalfEdges.concat(faceEdges); 
                newFaces.push(cutFace);
            }              
            
            // 更新
            vertices = newVertices;
            faces    = newFaces;
            halfEdges= newHalfEdges;
            edges    = newEdges;
            reindex();
            ///////////////////////////////////////
        }
    }
    
    public function toTriangleMesh3D(material:MaterialObject3D,name:String=null):TriangleMesh3D
    {
        var result:TriangleMesh3D = new TriangleMesh3D(material,[],[],name);
        var faceNum:int = faces.length;
        
        var center   :Vector3D       = new Vector3D();
        for(var i:int=0;i<vertices.length;i++){
            var v:Vertex = vertices[i];
            center.x += v.x;
            center.y += v.y;
            center.z += v.z;
        }
        center.scaleBy(1/vertices.length);
        
        for(i=0;i<faceNum;i++){
            var face:Face = faces[i];
            var halfEdge:HalfEdge = face.halfEdge;
            var midFace:Vector3D  = new Vector3D();
            var c:int = 0;
            do{
                v=halfEdge.vert;
                midFace.x+=v.x;
                midFace.y+=v.y;
                midFace.z+=v.z;
                halfEdge=halfEdge.next;
                c++;
            }while(halfEdge!=face.halfEdge);
            midFace.scaleBy(1.0/Number(c));
            halfEdge = face.halfEdge;
            var newVertices:Array;
            if(c==3){
                newVertices = new Array();
                do { 
                    v = halfEdge.vert;
                    newVertices.push(new Vertex3D(v.x-center.x, v.y-center.y, v.z-center.z ));
                    halfEdge= halfEdge.next;
                } while(halfEdge!=face.halfEdge); 
                result.geometry.vertices = result.geometry.vertices.concat(newVertices);
                result.geometry.faces.push(new Triangle3D(result,newVertices,material));
            } else {
                do {
                    var v0:Vertex = halfEdge.vert;
                    var v1:Vertex = halfEdge.next.vert;
                    
                    newVertices   = new Array();
                    
                    newVertices.push(new Vertex3D(midFace.x-center.x, midFace.y-center.y, midFace.z-center.z ));
                    newVertices.push(new Vertex3D(v0.x-center.x, v0.y-center.y, v0.z-center.z ));
                    newVertices.push(new Vertex3D(v1.x-center.x, v1.y-center.y, v1.z-center.z ));
                    
                    result.geometry.vertices = result.geometry.vertices.concat(newVertices);
                    result.geometry.faces.push(new Triangle3D(result,newVertices,material));    
                    
                    halfEdge= halfEdge.next;
                } while(halfEdge!=face.halfEdge);
            }
        }
        
        result.x = center.x;
        result.y = center.y;
        result.z = center.z;
        result.mergeVertices();
        result.geometry.ready = true;
        
        return result;
    }
    
    
    public function roundCorners(d:Number):void
    {
        var cutPlanes:Vector.<Plane> = new Vector.<Plane>();
        var center   :Vector3D       = new Vector3D();
        for(var i:int=0;i<vertices.length;i++){
            var v:Vertex = vertices[i];
            center.x += v.x;
            center.y += v.y;
            center.z += v.z;
        }
        center.scaleBy(1.0/Number(vertices.length));
        for(i=0;i<vertices.length;i++){
            v = vertices[i];
            var n:Vector3D = v.subtract(center);
            var distToVertex:Number = n.length;
            if(distToVertex>d){
                var ratio:Number = (distToVertex-d)/distToVertex;
                var o:Vector3D = n.clone();
                o.scaleBy(ratio);
                o.x += center.x;
                o.y += center.y;
                o.z += center.z;
                cutPlanes.push(new Plane(o,n));
            }
        }
        for(i=0;i<cutPlanes.length;i++){
            splitMesh(cutPlanes[i],center);
        }
    }
    
    public function roundEdges(d:Number):void
    {
        var cutPlanes:Vector.<Plane> = new Vector.<Plane>();
        var center   :Vector3D       = new Vector3D();
        for(var i:int=0;i<vertices.length;i++){
            var v:Vertex = vertices[i];
            center.x += v.x;
            center.y += v.y;
            center.z += v.z;
        }
        center.scaleBy(1.0/Number(vertices.length));
        for(i=0;i<edges.length;i++){
            var e:Edge = edges[i];
            var v1:Vertex = e.halfEdge.vert;
            var v2:Vertex = e.halfEdge.pair.vert;
            v = new Vertex( 0.5*(v1.x+v2.x), 0.5*(v1.y+v2.y), 0.5*(v1.z+v2.z), 0);
            var n:Vector3D = v.subtract(center);
            var distToVertex:Number = n.length;
            if(distToVertex>d){
                var ratio:Number = (distToVertex-d)/distToVertex;
                var o:Vector3D = n.clone();
                o.scaleBy(ratio);
                o.x += center.x;
                o.y += center.y;
                o.z += center.z;
                cutPlanes.push(new Plane(o,n));
            }
        }
        for(i=0;i<cutPlanes.length;i++){
            splitMesh(cutPlanes[i],center);
        }
    }
    
}


///////////////////////////////////////////////////////////////////////////////////////
// class Vertex
///////////////////////////////////////////////////////////////////////////////////////
import flash.geom.Vector3D;

class Vertex extends Vector3D
{
    public var id:int;
    public var halfEdge:HalfEdge;
    
    public function Vertex(x:Number,y:Number,z:Number, id:int)
    {
        super(x,y,z);
        this.id = id;
    }
    
    // clone
    public function get():Vertex
    {
        return new Vertex(x,y,z,id);
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// class Edge
///////////////////////////////////////////////////////////////////////////////////////
class Edge
{
    public var id:int;
    public var halfEdge:HalfEdge;
}

///////////////////////////////////////////////////////////////////////////////////////
// class HalfEdge
///////////////////////////////////////////////////////////////////////////////////////
class HalfEdge
{
    public var id   :int;
    public var vert :Vertex;
    public var pair :HalfEdge;
    public var face :Face;
    public var next :HalfEdge;
    public var prev :HalfEdge;
    public var edge :Edge;
}

///////////////////////////////////////////////////////////////////////////////////////
// class Face
///////////////////////////////////////////////////////////////////////////////////////
class Face
{
    public var id:int;
    public var halfEdge:HalfEdge;
}

///////////////////////////////////////////////////////////////////////////////////////
// class Plane
///////////////////////////////////////////////////////////////////////////////////////
import flash.geom.Vector3D;

class Plane
{
    public var A:Number;
    public var B:Number;
    public var C:Number;
    public var D:Number;

    // AX + BY + CZ + D = 0
    public function Plane(p0:Vector3D,p1:Vector3D,p2:Vector3D = null)
    {
        var norm:Vector3D;
        if(p2 == null){
            norm = p1.clone();
            norm.normalize();
            A = norm.x;
            B = norm.y;
            C = norm.z;
            D = -A*p0.x-B*p0.y-C*p0.z;
        } else {
            A=p0.y*(p1.z-p2.z)+p1.y*(p2.z-p0.z)+p2.y*(p0.z-p1.z);
            B=p0.z*(p1.x-p2.x)+p1.z*(p2.x-p0.x)+p2.z*(p0.x-p1.x);
            C=p0.x*(p1.y-p2.y)+p1.x*(p2.y-p0.y)+p2.x*(p0.y-p1.y);
            norm = new Vector3D(A,B,C);
            norm.normalize();
            A=norm.x;
            B=norm.y;
            C=norm.z;
            D=-A*p0.x-B*p0.y-C*p0.z;
        }
    }
    
    public function flipNormal():void
    {
        A*=-1;
        B*=-1;
        C*=-1;
        D*=-1;
    }
    
    public function side(p:Vector3D):int 
    {
        var tmp:Number = A*p.x+B*p.y+C*p.z+D;
        if(tmp<-0.001)     return -1;
        else if(tmp>0.001) return  1;
        else               return  0;
    }
    
    //Paul Bourke, http://local.wasp.uwa.edu.au/~pbourke/geometry/planeline/
    public function intersection(e:Edge):Vector3D
    {
        var p0:Vector3D = e.halfEdge.vert;
        var p1:Vector3D = e.halfEdge.pair.vert;
        var denom:Number= this.A*(p0.x-p1.x)+
                          this.B*(p0.y-p1.y)+
                          this.C*(p0.z-p1.z);
        if ((denom<0.001)&&(denom>-0.001)) return null;
        var u:Number = (this.A*p0.x + this.B*p0.y + this.C*p0.z + this.D)/denom;
        if ((u<0.00)||(u>1.0)) return null;
        return new Vector3D(p0.x+u*(p1.x-p0.x),p0.y+u*(p1.y-p0.y),p0.z+u*(p1.z-p0.z));
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// class SplitEdge
///////////////////////////////////////////////////////////////////////////////////////
import flash.geom.Vector3D;
class SplitEdge
{
    public var edge       :Edge;
    public var splitVertex:Vertex;
    
    public function SplitEdge(e:Edge = null, p:Vector3D = null)
    {
        if(e!=null) edge        = e;
        if(p!=null) splitVertex = new Vertex(p.x,p.y,p.z,0);
    }
}