// forked from FLASHMAFIA's Lil' Boxes...
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import org.si.b3.*;

    [SWF(width = '465', height = '465', frameRate = '1')]
    public class main extends Sprite
    {
        private const NUM_BOXES : uint = 250;

        private var boxes:Vector.<CMLMovieClipTexture> = new Vector.<CMLMovieClipTexture>(NUM_BOXES, true);
        private var bmp:Bitmap = new Bitmap;

        function main() {
            addChild(bmp);
            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e:Event):void
        {
            for(var i:int=0; i<NUM_BOXES; i++) {
                var h:int = 2 + 52 * Math.random();
                var w:int = 2 + 52 * Math.random();
                var color:uint = Math.random() * 0xffffff;
                var bmd:BitmapData = new BitmapData(w, h, false, color);
                bmd.fillRect(new Rectangle(1, 1, w-2, h-2), color >> 1 & 0x7f7f7f);
                boxes[i] = new CMLMovieClipTexture(bmd);
            }
            var packedBmds:Array = pack(boxes, 465, 465);
            bmp.bitmapData = packedBmds[0];
        }

        /**
        *  @param textures textures to pack (textures' bitmapData and rect properties will be modified)
        *  @param width bin (packed bitmap) width
        *  @param height bin (packed bitmap) height
        *  @param destroyOriginals if true dispose() will be called on the textures' original bitmapData
        *  @return Array of bin (packed BitmapData objects)
        */
        public function pack(textures:Vector.<CMLMovieClipTexture>, width:uint = 2048, height:uint = 2048, destroyOriginals:Boolean = true):Array {
            var tex:CMLMovieClipTexture, ptn:CMLMovieClipTexture;
            var disposables:Array = [], patterns:Array = [], bmds:Array = [], bins:Array = [];
            var placement:PackerNode;

            for each(tex in textures) {
                for each(ptn in tex.animationPattern) {
                    if(patterns.indexOf(ptn) == -1) patterns.push(ptn);
                }
            }
            for each(tex in patterns) {
                if(tex.width>width || tex.height>height) throw(new Error("Texture larger than requested bin size."));
                if(destroyOriginals && disposables.indexOf(tex.bitmapData) == -1) disposables.push(tex.bitmapData);
                var i:int = 0;
                while(i < bins.length && (placement = bins[i].place(tex)) == null) i++;
                if(!placement) {
                    bins[i] = new PackerNode(0, 0, width, height);
                    bmds[i] = new BitmapData(width, height, false, 0);
                    placement = bins[i].place(tex);
                }
                bmds[i].copyPixels(tex.bitmapData, tex.rect, placement.r.topLeft);
                tex.bitmapData = bmds[i];
                tex.rect = placement.r;
            }
            for each(var bmd:BitmapData in disposables) bmd.dispose();
            return bmds;
        }
    }
}

import flash.geom.*;

/** Recursive texture packer, based on http://www.blackpawn.com/texts/lightmaps/default.html */
class PackerNode {
    public var a:PackerNode, b:PackerNode;
    public var r:Rectangle;
    public var content:Object;

    public function PackerNode(x:Number, y:Number, width:Number, height:Number) { r = new Rectangle(x, y, width, height); }

    /**
    *  @param tex anything with width and height properties
    *  @return empty node with same dimensions as tex, or null on failure.
    */
    public function place(tex:Object):PackerNode {
        if(content || r.width < tex.width || r.height < tex.height) return null; // full or too small
        if(a) return(a.place(tex) || b.place(tex)); // not a leaf node, try placing in children
        if(r.width == tex.width && r.height == tex.height) { // exact fit
            content = tex;
            return this;
        }
        // too large - split this node
        var dw:Number = r.width - tex.width;
        var dh:Number = r.height - tex.height;
        if(dw > dh) {
            a = new PackerNode(r.x, r.y, tex.width, r.height);
            b = new PackerNode(r.x+tex.width, r.y, dw, r.height);
        } else {
            a = new PackerNode(r.x, r.y, r.width, tex.height);
            b = new PackerNode(r.x, r.y+tex.height, r.width, dh);
        }
        return a.place(tex);
    }
}
