/**
Random labyrinth BY Yukulélé

keyboard shortcuts :
        [+],[-]  Change Build Speed
        [Enter]  Complete Build
    [Backspace]  New Labyrinth
        [Array]  Move (after build)
*/
package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    /**
     * @author Yukulélé
     */
    public class Main extends Sprite 
    {
        private var labyrinthe:Labyrinthe;
        private var largeur:int=25;
        private var hauteur:int=25;
        private var vitConstr:int=35;
        public function Main():void 
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, kd)
                        var i:int=0;
            nouveau();
        }
        private function kd(e:KeyboardEvent):void
        {
            switch(e.keyCode)
            {
                case Keyboard.BACKSPACE:
                    nouveau();
                    break;
                case Keyboard.NUMPAD_ADD:
                    if (vitConstr <= 0)
                        break;
                    labyrinthe.vitConstr=--vitConstr;
                    break;
                case Keyboard.NUMPAD_SUBTRACT:
                    if (vitConstr >= 200)
                        break;
                    labyrinthe.vitConstr=++vitConstr;
                    break;
                case Keyboard.ENTER:
                case Keyboard.NUMPAD_ENTER:
                    labyrinthe.finirConstr();
                    break;
            }
        }
        private function nouveau():void
        {
            
            while(numChildren > 0)
            {
                removeChildAt(0);
            }
            labyrinthe = new Labyrinthe(largeur, hauteur);
            labyrinthe.vitConstr = vitConstr;
            addChild(labyrinthe);
        }
    }
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;

class Labyrinthe extends Sprite
{
    private var 
        timerCrea:Timer = new Timer(35),
        timerMvt:Timer = new Timer(60),
        _cases:Vector.<Vector.<Case>>,
        historique:Vector.<Case> = new Vector.<Case>(0),
        max:int = 0,
        bifurcations:int = 0,
        largeur:int,
        hauteur:int,
        caseFin:Case,
        caseActu:Case,
        keys:Vector.<Boolean>=new Vector.<Boolean>(4,true);
    public function Labyrinthe(x:int,y:int) 
    {
        addEventListener(Event.ADDED_TO_STAGE, suite);
        trace("nombre de case : " + x * y);
        largeur = x;
        hauteur = y;
        _cases = new Vector.<Vector.<Case>>(x,true);
        for (var i:int = 0; i < x; i++)
        {
            _cases[i] = new Vector.<Case>(y,true);
            for (var j:int = 0; j < y; j++)
            {
                var newCase:Case = new Case(i, j, this);
                _cases[i][j] =  newCase;
                addChild(newCase);
            }
        }
    }
    private function suite(e:Event):void
    {
        caseActu = cases(Math.random()*largeur, Math.random()*hauteur);
        historique.push(caseActu);
        timerCrea.addEventListener(TimerEvent.TIMER, creation);
        timerCrea.start();
        timerMvt.addEventListener(TimerEvent.TIMER, mouvement);
        addEventListener(Event.REMOVED_FROM_STAGE, retirer);
    }
    private function clavier(e:KeyboardEvent):void
    {
        var dir:int;
        if(e.type==KeyboardEvent.KEY_DOWN)
        {
            dir = Case.key2sens(e.keyCode);
            if (dir == -1)
                return;
            keys[dir]=true;
        }
        else if(e.type==KeyboardEvent.KEY_UP)
        {
            dir = Case.key2sens(e.keyCode);
            if (dir == -1)
                return;
            keys[dir]=false;

        }
    }
    private function mouvement(e:TimerEvent):void
    {
        //var mvt:Boolean=false;
        for(var dir:int=0;dir<4;dir++)
        {
            if (keys[dir] && !caseActu.getMur(dir))
            {
                //mvt=true;
                caseActu = suivante(caseActu, dir);
                caseActu.setActu();
                break;
            }
            /*if(!mvt)
                stage.removeEventListener(TimerEvent.TIMER,mouvement);*/
        }
    }
    private function retirer(e:Event):void
    {
        removeEventListener(Event.REMOVED_FROM_STAGE, retirer);
        timerCrea.stop();
        timerCrea = null;
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, clavier);
        stage.removeEventListener(KeyboardEvent.KEY_UP, clavier);
        timerMvt.stop();
        
    }
    private function cases(x:int, y:int):Case
    {
        if (x<0 || x>=largeur || y<0 || y>=hauteur)
        {
            return null;
        }
        return _cases[x][y];
    }
    public function maj(c:Case):void
    {
        for (var i:int = 0; i < 4; i++)
        {
            var suiv:Case = suivante(c, i);
            if (suiv == null)
                continue;
            if (c.getMur(i) != suiv.getMur(Case.murOpose(i)))
            {
                suiv.setMur(Case.murOpose(i), c.getMur(i));
            }
        }
    }
    public function suivante(c:Case, dir:Number):Case
    {
        var actuX:int = c._x;
        var actuY:int = c._y;
        switch(dir)
        {
            case Case.MURHAUT:      actuY--;    break;
            case Case.MURBAS:       actuY++;    break;
            case Case.MURGAUCHE:    actuX--;    break;
            case Case.MURDROITE:    actuX++;    break;
        }
        
        if (actuX < 0) actuX += largeur;
        if (actuX >= largeur) actuX -= largeur;
        if (actuY < 0) actuY += hauteur;
        if (actuY >= hauteur) actuY -= hauteur;
        return cases(actuX, actuY);
    }
    private function creation(e:TimerEvent=null):void
    {
        var dir:int;
        
        
        var suiv:Case;
        var tabl:Vector.<Object>= new Vector.<Object>(0);
        for (var i:int = 0; i < 4; i++)
        {
            var s:Case = suivante(caseActu, i);
            if (s != null && !s.active)
                tabl.push({s:s,d:i});
        }
        if (tabl.length == 0)
        {
            historique.pop();
            
            if (historique.length == 0)
            {
                trace("fini ! deplacement mini : " + max + "bifurcations : "+bifurcations);
                caseActu.setActu();
                timerCrea.stop();
                stage.addEventListener(KeyboardEvent.KEY_DOWN, clavier);
                stage.addEventListener(KeyboardEvent.KEY_UP, clavier);
                timerMvt.start();
                return;
            }
            suiv = historique[historique.length - 1];
        }
        else
        {
            if (caseActu.active)
                bifurcations++;
            var obj:Object = tabl[Math.floor(Math.random() * tabl.length)];
            suiv = obj.s;
            caseActu.setMur(obj.d, false);
            historique.push(suiv);
            if (historique.length > max)
            {
                max = historique.length;
                caseFin = suiv;
                caseFin.setFin();
            }
            
        }
        caseActu.active = true;
        caseActu = suiv;
        caseActu.setDebut();
    }
    /**
     * regler la vitesse de construction (ms/action)
     */
    public function set vitConstr(val:int):void
    {
        if (val < 0) val = 0;
        timerCrea.delay = val;
    }
    public function finirConstr():void
    {
        timerCrea.stop();
        timerCrea.removeEventListener(TimerEvent.TIMER, creation);
        while (historique.length > 0)
            creation();
        return;
    }
}


import flash.display.Shape;
import flash.display.Sprite;
import flash.ui.Keyboard;

class Case extends Sprite
{
    
    private static const debut:Shape = creePointeur(0xff0000);
    private static const fin:Shape = creePointeur(0x0000ff);
    private static const actu:Shape = creePointeur(0x00ff00);
    public static const 
        MURHAUT:int = 0,
        MURBAS:int = 1,
        MURGAUCHE:int = 2,
        MURDROITE:int = 3,
        largeur:Number=15;
    public var 
        _x:int,
        _y:int;
    private var 
        mur:Vector.<Boolean> = new Vector.<Boolean>(4,true),
        _active:Boolean = false,
        labyrinthe:Labyrinthe;

    public function Case(_x:int,_y:int, labyrinthe:Labyrinthe) 
    {
        mur[0] = mur[1] = mur[2] = mur[3] = true;
        this.labyrinthe = labyrinthe;
        this._x = _x;
        this._y = _y;
        x = _x * largeur;
        y = _y * largeur;
        dessiner();
    }
    private static function creePointeur(couleur:uint):Shape
    {
        var pointeur:Shape = new Shape();
        pointeur.graphics.beginFill(couleur);
        pointeur.graphics.drawCircle(largeur / 2, largeur / 2, largeur / 4);
        return pointeur;

    }
    public function getMur(mur:int):Boolean
    {
        return this.mur[mur];
    }
    public function setMur(mur:int,val:Boolean):void
    {
        this.mur[mur] = val;
        labyrinthe.maj(this);
        dessiner();
    }
    public override function toString():String
    {
        return "["+_x+","+_y+"]";
    }
    public function set active(val:Boolean):void
    {
        _active = val;
        dessiner();
    }
    public function setDebut():void
    {
        addChild(debut);
    }
    public function setFin():void
    {
        addChild(fin);
    }
    public function setActu():void
    {
        addChild(actu);
    }
    public function get active():Boolean
    {
        return _active;
        
    }
    private function dessiner():void
    {
        graphics.clear();
        
        if(_active)
                    graphics.beginFill(0xffff00);
        graphics.drawRect(0 ,0 , largeur, largeur);
        graphics.lineStyle(1);
        
        if (mur[MURHAUT])
        {
            graphics.moveTo(0, 0);
            graphics.lineTo(largeur, 0);
        }
        if (mur[MURBAS])
        {
            graphics.moveTo(0, largeur);
            graphics.lineTo(largeur, largeur);
        }
        if (mur[MURGAUCHE])
        {
            graphics.moveTo(0, 0);
            graphics.lineTo(0, largeur);
        }
        if (mur[MURDROITE])
        {
            graphics.moveTo(largeur, 0);
            graphics.lineTo(largeur, largeur);
        }
    }
    public static function murOpose(mur:int):int
    {
        switch(mur)
        {
            case Case.MURHAUT:  return Case.MURBAS;
            case Case.MURBAS:   return Case.MURHAUT;
            case Case.MURGAUCHE:    return Case.MURDROITE;
            case Case.MURDROITE:    return Case.MURGAUCHE;
        }
        return -1;
    }
    public static function key2sens(k:uint):int
    {
        switch(k)
        {
            case Keyboard.UP:return     Case.MURHAUT;
            case Keyboard.DOWN:return   Case.MURBAS;    
            case Keyboard.LEFT:return   Case.MURGAUCHE;
            case Keyboard.RIGHT:return  Case.MURDROITE;
        }
        return -1;
    }
}