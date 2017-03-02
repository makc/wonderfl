/*

Copyright (c) 2013 Stuffit at codepen.io (http://codepen.io/stuffit)

View this and others at http://lonely-pixel.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*/

package 
{

import com.bit101.components.Label;
import com.bit101.components.PushButton;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.display.Shape
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

/**
 * Ported to AS3 from http://codepen.io/stuffit/pen/KrAwx
 *
 * by
 * @author devon o.
 */

[SWF(width='465', height='465', backgroundColor='#232323', frameRate='60')]
public class Main extends Sprite 
{
    
    private var _cloth:Cloth;
    
    public function Main():void 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(event:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        
        Data.boundsx = stage.stageWidth - 1;
        Data.boundsy = stage.stageHeight - 1;
        
        var resetButton:PushButton = new PushButton(this, 10, stage.stageHeight - 30, "Reset", onRestart);
        var l1:Label = new Label(this, 10, 10, "Click and drag to tug cloth.");
        var l2:Label = new Label(this, 10, 20, "SHIFT + Click and drag to tear cloth.");
        
        initCloth();
    }
    
    private function onRestart(event:MouseEvent):void
    {
        initCloth();
    }
    
    private function initCloth():void
    {
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        removeEventListener(Event.ENTER_FRAME, update);
        
        
        this.graphics.clear();
        
        if (_cloth)
            _cloth = null;
        
        _cloth = new Cloth(this.stage);
        
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, update);
    }
    
    private function onMouseDown(event:MouseEvent):void
    {
        Data.mouse_down = true;
    }
    
    private function onMouseUp(event:MouseEvent):void
    {
        Data.mouse_down = false;
    }
    
    private function onKeyDown(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.SHIFT)
            Data.shift_down = true;
    }
    
    private function onKeyUp(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.SHIFT)
            Data.shift_down = false;
    }
    
    private function update(event:Event):void
    {
        Data.mouse_px = Data.mouse_x;
        Data.mouse_py = Data.mouse_y;
        
        Data.mouse_x = stage.mouseX;
        Data.mouse_y = stage.mouseY;
        
        this.graphics.clear();
        this.graphics.lineStyle(0, 0x999999);
        
        _cloth.update();
        _cloth.draw(this.graphics);

    }
}
    
}


import flash.display.Graphics;
import flash.display.Stage;

class Point
{
    private var _x:Number;
    private var _y:Number;
    private var _px:Number;
    private var _py:Number;
    private var _vx:Number = 0;
    private var _vy:Number = 0;
    private var _pin_x:Number = -1;
    private var _pin_y:Number = -1;
    private var _constraints:Array = [];
    
    public function Point(x:Number, y:Number)
    {
        _x = x;
        _y = y;
        _px = x;
        _py = y;
    }
    
    public function update(delta:Number):void
    {
        if (Data.mouse_down) 
        {
            var diff_x:Number     = _x - Data.mouse_x,
            diff_y:Number         = _y - Data.mouse_y,
            dist:Number           = Math.sqrt(diff_x * diff_x + diff_y * diff_y);

            if (!Data.shift_down) 
            {
                if (dist < Data.MOUSE_INFLUENCE) 
                {
                    _px = _x - (Data.mouse_x - Data.mouse_px) * 1.8;
                    _py = _y - (Data.mouse_y - Data.mouse_py) * 1.8;
                }

            } 
            else if (dist < Data.MOUSE_CUT) 
                _constraints = [];
        }

        addForce(0, Data.GRAVITY);

        delta *= delta;
        var nx:Number = _x + ((_x - _px) * .99) + ((_vx / 2) * delta);
        var ny:Number = _y + ((_y - _py) * .99) + ((_vy / 2) * delta);

        _px = _x;
        _py = _y;

        _x = nx;
        _y = ny;

        _vy = _vx = 0
    }
    
    public function draw(gfx:Graphics):void
    {
        if (_constraints.length <= 0) return;
    
        var i:int = _constraints.length;
        while (i--) 
            (_constraints[i] as Constraint).draw(gfx);
    }
    
    public function resolveConstraints():void
    {
        if (_pin_x >= 0 && _pin_y >= 0) 
        {
            _x = _pin_x;
            _y = _pin_y;
            return;
        }

        var i:int = _constraints.length;
        while (i--) 
            (_constraints[i] as Constraint).resolve();

        _x > Data.boundsx ? _x = 2 * Data.boundsx - _x : 1 > _x && (_x = 2 - _x);
        _y < 1 ? _y = 2 - _y : _y > Data.boundsy && (_y = 2 * Data.boundsy - _y);
    }
    
    public function attach(p:Point):void
    {
        _constraints.push(new Constraint(this, p));
    }

    public function removeConstraint(lnk:Constraint):void
    {

        var i:int = _constraints.length;
        while (i--)
        {
            if (_constraints[i] == lnk)
            {
                _constraints.splice(i, 1);
                break;
            }
        }
    }

    public function addForce(x:Number, y:Number):void
    {

        _vx += x;
        _vy += y;
    }

    public function pin(pinx:Number, piny:Number):void
    {
        _pin_x = pinx;
        _pin_y = piny;
    }
    
    public function get x():Number {return _x;}
    public function set x(value:Number):void {_x = value;}
    public function get y():Number {return _y;}
    public function set y(value:Number):void {_y = value;}
    
}


import flash.display.Graphics;
class Constraint
{
    private var _p1:Point;
    private var _p2:Point;
    private var _length:Number;
    
    public function Constraint(p1:Point, p2:Point)
    {
        _p1 = p1;
        _p2 = p2;
        _length = Data.SPACING;
    }
    
    public function draw(gfx:Graphics):void
    {
        gfx.moveTo(_p1.x, _p1.y);
        gfx.lineTo(_p2.x, _p2.y);
    }
    
    public function resolve():void
    {
        var diff_x:Number = _p1.x - _p2.x,
            diff_y:Number = _p1.y - _p2.y,
            dist:Number   = Math.sqrt(diff_x * diff_x + diff_y * diff_y),
            diff:Number   = (_length - dist) / dist;

        if (dist > Data.TEAR_DISTANCE)
            _p1.removeConstraint(this);

        var px:Number = diff_x * diff * 0.5;
        var py:Number = diff_y * diff * 0.5;

        _p1.x += px;
        _p1.y += py;
        _p2.x -= px;
        _p2.y -= py;
    }
}

import flash.display.Graphics;
import flash.display.Stage;
class Cloth
{
    
    private var _points:Vector.<Point>
    public function Cloth(stage:Stage)
    {
        _points = new Vector.<Point>();

        var start_x:Number = stage.stageWidth / 2 - Data.CLOTH_WIDTH * Data.SPACING / 2;

        for (var y:int = 0; y <= Data.CLOTH_HEIGHT; y++) 
        {
            for (var x:int = 0; x <= Data.CLOTH_WIDTH; x++) 
            {
                var p:Point = new Point(start_x + x * Data.SPACING, Data.START_Y + y * Data.SPACING);
                y == 0 && p.pin(p.x, p.y);
                y != 0 && p.attach(_points[x + (y - 1) * (Data.CLOTH_WIDTH + 1)]);
                x != 0 && p.attach(_points[_points.length - 1]);
                _points.push(p);
            }
        }
        
        _points.fixed = true;
    }
    
    public function update():void
    {
        var i:int =Data.PHYSICS_ACCURACY;

        while (i--) 
        {
            var p:int = _points.length;
            while(p--) _points[p].resolveConstraints();
        }

        i = _points.length;
        while (i--) 
            _points[i].update(.016);
    }
    
    public function draw(gfx:Graphics):void
    {
        var i:int = _points.length;
        while (i--) 
            _points[i].draw(gfx);
    }
}

class Data
{
    public static var mouse_down:Boolean        = false;
    public static var shift_down:Boolean        = false;
    public static var mouse_x:Number            = 0;
    public static var mouse_y:Number            = 0;
    public static var mouse_px:Number            = 0;
    public static var mouse_py:Number            = 0;
    
    public static var boundsx:Number;
    public static var boundsy:Number;
    
    public static const PHYSICS_ACCURACY:int     = 5;
    public static const MOUSE_INFLUENCE:int     = 20;
    public static const MOUSE_CUT:int            = 6;
    public static const GRAVITY:Number            = 900;
    public static const CLOTH_HEIGHT:Number        = 30;
    public static const CLOTH_WIDTH:Number        = 50;
    public static const START_Y:Number            = 70;
    public static const SPACING:Number            = 7;
    public static const TEAR_DISTANCE:Number     = 60;
}