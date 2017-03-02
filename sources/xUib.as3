// forked from itr0510's Voronoi 3D 
// forked from yamat1011's forked from: forked from: flash on 2011-3-14
// forked from yamat1011's forked from: flash on 2011-3-14
// forked from yamat1011's flash on 2011-3-14

// Frederik Vanhoutte氏のコードを参考にしています > http://www.wblut.com/2009/05/04/snippets-ii/
// ちょろっとバグフィックス
// ついでにkey pressでボロノイの更新をストップできるようにしました

// やっつけでコードきたないです
package
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import net.hires.debug.Stats;
  
    [SWF(backgroundColor="#000000",width = "465", height = "465")]
    
    public class voronoi3D extends Sprite
    {
        
        private var center  :Point;
        private var proj    :PerspectiveProjection;
        private var projMat :Matrix3D;
        private var mat     :Matrix3D;
        
        private var viewport  :Shape;
        private var csViewport:Shape;
        
        private var degX    :Number = 0;
        private var degY    :Number = 0;
        
        private var sites   :Vector.<Vector3D>;
        
        private var CELL_NUM  :int    = 10;
        private var MAX_VEL      :Number = 1.0;
        private var HALF_WIDTH :Number= 100;
        private var HALF_HEIGHT:Number= 100;
        private var HALF_DEPTH :Number= 100;
        
        private var container   :Mesh;
        private var voronoiCells:Vector.<Mesh> = new Vector.<Mesh>();
        private var crossSection:Vector.<Mesh> = new Vector.<Mesh>();
        
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
            center  = new Point(stage.stageWidth / 2,stage.stageHeight / 2);
            mat     = new Matrix3D();
            
            proj    = new PerspectiveProjection();
            proj.fieldOfView      = 70;
            proj.projectionCenter = center;
            projMat               = proj.toMatrix3D();
            
            viewport   = new Shape();
            viewport.x = center.x;
            viewport.y = center.y;
            viewport.z = 0;
            addChild(viewport);
            
            csViewport   = new Shape();
            csViewport.x = 70;
            csViewport.y = 395;
            addChild(csViewport);
            
            createCells();
            createContainer();
            createVoronoi();
            createCrossSection();
            
            var stats:Stats = new Stats();
            stats.x = stats.y = 10;
            addChild(stats);
            
            stage.addEventListener(Event.ENTER_FRAME,    onEnterFrame );
            stage.addEventListener(Event.RESIZE,         onStageResize);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown  );
        }
        
        private function createCells():void
        {
            sites = new Vector.<Vector3D>();
            for(var i:int=0;i<CELL_NUM;i++){
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
            container.roundCorners(10);
            container.roundEdges(10);
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
                        o.x += n.x * 2;
                        o.y += n.y * 2;
                        o.z += n.z * 2;
                        var p:Plane = new Plane(o,n);
                        voronoiCells[i].splitMesh(p,sites[i]);
                    }
                }
            }
            
            
        }
        
        private function createCrossSection():void
        {
            crossSection = new Vector.<Mesh>();
            for(var i:int = 0;i<sites.length;i++){
                crossSection.push(voronoiCells[i].crossSection(new Vector3D(0,mouseY-stage.stageHeight/2,0),Vector3D.Y_AXIS));
            }
        }
        
        private function onEnterFrame(event:Event):void
        {
            updateMatrix();
            render();
            createCrossSection();
        }
        
        private function render():void
        {
            var g  :Graphics = viewport.graphics;
            var csg:Graphics = csViewport.graphics;
            
            g.clear();
            csg.clear();
            
            var p0:Vector3D;
            var p1:Vector3D;
            
            //draw voronoi mesh//////////////////////////
            g.lineStyle(1,0x666666,0.5);
            for(var i:int = 0;i<voronoiCells.length;i++)
            {
                for(var j:int=0;j<voronoiCells[i].edges.length;j++){
                    var ed:Edge = voronoiCells[i].edges[j];
                    p0 = Utils3D.projectVector(mat,ed.halfEdge.vert);
                    p1 = Utils3D.projectVector(mat,ed.halfEdge.pair.vert);
                    g.moveTo(p0.x,p0.y);
                    g.lineTo(p1.x,p1.y);
                }
            }
            
            //draw crossSection mesh/////////////////////////////
            csg.lineStyle(1,0x333333);
            csg.beginFill(0x000000,0.5);
            csg.drawRect(-60,-60,120,120);
            for(i=0;i<crossSection.length;i++)
            {
                var he:HalfEdge;
                if(crossSection[i].halfEdges.length>0){
                    g.beginFill(0x0077CC,0.5);
                    g.lineStyle(1,0x0099CC);
                    he = crossSection[i].halfEdges[0];
                    p0 = Utils3D.projectVector(mat,he.vert);
                    g.moveTo(p0.x,p0.y);
                    he = he.next;
                    do{
                        p0 = Utils3D.projectVector(mat,he.vert);
                        g.lineTo(p0.x,p0.y);
                        he = he.next;
                    }while(he != crossSection[i].halfEdges[0]);
                    g.endFill();
                    
                    he = crossSection[i].halfEdges[0];
                    g.beginFill(0xFFFFFF);
                    g.lineStyle();
                    do{
                        p0 = Utils3D.projectVector(mat,he.vert);
                        g.drawCircle(p0.x-0.5,p0.y-0.5,1);
                        he = he.next;
                    }while(he != crossSection[i].halfEdges[0]);
                    g.endFill();
                    
                }
                //draw 2d//
                if(crossSection[i].halfEdges.length>0){
                    csg.beginFill(0xFFFFFF,0.4);
                    csg.lineStyle(1,0xFFFFFF);
                    he = crossSection[i].halfEdges[0];
                    p0 = he.vert.clone();
                    p0.scaleBy(0.5);
                    csg.moveTo(p0.x,p0.z);
                    he = he.next;
                    do{
                        p0 = he.vert.clone();
                        p0.scaleBy(0.5);
                        p1.scaleBy(0.5);
                        csg.lineTo(p0.x,p0.z);
                        he = he.next;
                    }while(he != crossSection[i].halfEdges[0]);
                    csg.endFill();
                }

            }
            
        }
        
        private function updateMatrix():void
        {
            degY -= (center.x - mouseX) /50;
            degX = 30;//+= (center.y - mouseY) /50;
            mat.identity();
            mat.appendRotation(degY,Vector3D.Y_AXIS);
            mat.appendRotation(degX,Vector3D.X_AXIS);
            mat.appendTranslation(0, 0, 300);
            mat.append(projMat);
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            createCells();
            createVoronoi();
            createCrossSection();
        }
        
        private function onStageResize(event:Event):void
        {
            center.x = viewport.x = stage.stageWidth / 2;
            center.y = viewport.y = stage.stageHeight/ 2;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// class Mesh
///////////////////////////////////////////////////////////////////////////////////////
import flash.geom.*;
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
                    if(!he.next || !he.next.pair || !he.next.pair.next) break;
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
    
    /*public function unwrap():Mesh
    {
        var result:Mesh = new Mesh();
        //
        
        //
        return result;
    }*/
    
    public function  crossSection(origin:Vector3D, normal:Vector3D):Mesh
    {
        var p:Plane    = new Plane(origin, normal);
        var o:Vector3D = origin.add(normal);
        
        var ret       :Mesh = new Mesh();
        var centerSide:int  = p.side(o);
        
        if(centerSide!=0){
            var newVertices:Vector.<Vertex>    = new Vector.<Vertex>();
            var newFaces:Vector.<Face>         = new Vector.<Face>();
            var newHalfEdges:Vector.<HalfEdge> = new Vector.<HalfEdge>();
            var newEdges:Vector.<Edge>         = new Vector.<Edge>();
            var splitEdges:Vector.<SplitEdge>  = retrieveSplitEdges(p);
            
            if(splitEdges.length<=0) return ret;
            
            var sides:Vector.<int> = new Vector.<int>(vertices.length,true);
            for(var i:int=0;i<vertices.length;i++){
                var v:Vertex = vertices[i];
                sides[i] = p.side(v);
            }
            
            for(i=0;i<faces.length;i++){
                var face:Face         = faces[i];
                var halfEdge:HalfEdge = face.halfEdge;
                var newFaceVertices1:Vector.<Vertex>    = new Vector.<Vertex>();
                do{
                    if(sides[halfEdge.vert.id]*centerSide>0){
                        newFaceVertices1.push(halfEdge.vert); 
                    }
                    for(var j:int=0;j<splitEdges.length;j++){
                        var se:SplitEdge = splitEdges[j];
                        if(halfEdge.edge==se.edge){
                            newFaceVertices1.push(se.splitVertex);
                            break;
                        }
                    }
                    halfEdge = halfEdge.next;
                } while(halfEdge!=face.halfEdge);
                
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
                    ret.cycleHalfEdges(faceEdges,false);
                    newHalfEdges = newHalfEdges.concat(faceEdges);                         
                }
            }
            
            var n:int=newHalfEdges.length;
            ret.pairHalfEdges(newHalfEdges);
            ret.createEdges(newHalfEdges,newEdges);
            
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
                    
                    if(!he.next || !he.next.pair || !he.next.pair.next) break;
                    
                    hen=he.next.pair.next;
                    while(unpairedEdges.indexOf(hen)==-1) hen=hen.pair.next;
                    var newhe:HalfEdge =new HalfEdge(); 
                    faceEdges.push(newhe);
                    if(cutFace.halfEdge==null) cutFace.halfEdge=newhe;
                    newhe.vert=hen.vert;
                    newhe.pair=he;
                    he.pair=newhe;
                    var e:Edge = new Edge(); 
                    e.halfEdge=newhe;
                    he.edge=e;
                    newhe.edge=e;
                    newEdges.push(e);        
                    newhe.face=cutFace;
                    he=hen;
                } while(hen!=unpairedEdges[0]);
                
                ret.cycleHalfEdges(faceEdges, true);
                newHalfEdges = faceEdges;
                newFaces.push(cutFace);
            }              
            
            // 更新
            
            ret.vertices = newVertices;
            ret.faces    = newFaces;
            ret.halfEdges= newHalfEdges;
            ret.edges    = newEdges;
            ret.reindex();
            //
            reindex();
            ///////////////////////////////////////
        }
        //
        return ret;
    }
    
    private function mergeVertices(verts:Vector.<Vertex>):void
    {
        for(var i:int=0;i<verts.length;i++){
            var v1:Vertex = verts[i];
            for(var j:int=0;j<verts.length;j++){
                if(i!=j){
                    var v2:Vertex = verts[j];
                    if(v1.nearEquals(v2,0.0001)){
                        verts[i] = verts[j];
                        verts.splice(j,1);
                        //halfedgeの処理もしとくべきかな
                        break;
                    }                        
                }
            }
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