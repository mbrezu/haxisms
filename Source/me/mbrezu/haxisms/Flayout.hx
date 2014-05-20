
/*
Copyright (c) 2014, Miron Brezuleanu
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package me.mbrezu.haxisms;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import me.mbrezu.haxisms.Flayout.Layout;
import flash.display.Sprite;

enum Alignment {
    TopLeft;
    TopCenter;
    TopRight;
    MiddleLeft;
    MiddleCenter;
    MiddleRight;
    BottomLeft;
    BottomCenter;
    BottomRight;
    Stretch;
}

class Layout {
    private var children: Array<Layout>;
    public var area(default, null): Rectangle;
    public var id(default, null): String;
    public var parent(default, null): Layout;
    public var remainingArea(default, null): Rectangle;
    public var quantity: Float;
    public var debugSprite(default, default): Sprite;
    private var reduce: Bool;
    
    private function new(area: Rectangle, id: String = "", parent: Layout = null) {
        this.area = area;
        this.remainingArea = area;
        this.id = id;
        this.parent = parent;
        this.children = new Array<Layout>();
        if (parent != null) {
            parent.children.push(this);
        }
        reduce = true;
    }
    
    public function findById(id: String) {
        if (this.id == id) {
            return this;
        }
        for (child in children) {
            var result = child.findById(id);
            if (result != null) {
                return result;
            }
        }
        return null;
    }
    
    public function name(id: String) {
        this.id = id;
        return this;
    }
    
    public static function make(area: Rectangle, name: String = "", parent: Layout = null) {
        return new Layout(area, name, parent);
    }
    
    private function spaceCheck() {
        if (remainingArea == null) {
            throw "Flayout: no space left.";
        }
    }
    
    public function left() {
        spaceCheck();
        var ra = remainingArea;
        var child = make(new Rectangle(ra.x, ra.y, quantity, ra.height), "", this);
        if (ra.width - quantity <= 0) {
            setRemainingArea(null);
        } else {
            setRemainingArea(new Rectangle(ra.x + quantity, ra.y, ra.width - quantity, ra.height));
        }
        return child;
    }
    
    public function resetArea() {
        remainingArea = area;
        return this;
    }
    
    public function right() {
        spaceCheck();
        var ra = remainingArea;
        var child = make(new Rectangle(ra.x + ra.width - quantity, ra.y, quantity, ra.height), "", this);
        if (ra.width - quantity <= 0) {
            setRemainingArea(null);            
        } else {
            setRemainingArea(new Rectangle(ra.x, ra.y, ra.width - quantity, ra.height));
        }
        return child;
    }
    
    public function top() {
        spaceCheck();
        var ra = remainingArea;
        var child = make(new Rectangle(ra.x, ra.y, ra.width, quantity), "", this);
        if (ra.height - quantity <= 0) {
            setRemainingArea(null);            
        } else {
            setRemainingArea(new Rectangle(ra.x, ra.y + quantity, ra.width, ra.height - quantity));
        }
        return child;
    }
    
    public function dontReduceNext() {
        reduce = false;
        return this;
    }
    
    private function setRemainingArea(newArea: Rectangle) {
        if (reduce) {
            remainingArea = newArea;
        } else {
            reduce = true;
        }
    }
    
    public function bottom() {
        spaceCheck();
        var ra = remainingArea;
        var child = make(new Rectangle(ra.x, ra.y + ra.height - quantity, ra.width, quantity), "", this);
        if (ra.height - quantity <= 0) {
            setRemainingArea(null);
        } else {
            setRemainingArea(new Rectangle(ra.x, ra.y, ra.width, ra.height - quantity));
        }
        return child;
    }
    
    public function middle() {
        var child = make(remainingArea, "", this);
        setRemainingArea(null);
        return child;
    }
    
    public function margin() {
        return left().parent
            .top().parent
            .right().parent
            .bottom().parent
            .middle();
    }
    
    public function pixels(pixels: Float) {
        quantity = pixels;
        return this;
    }
    
    public function width(percent: Float) {
        quantity = area.width * percent;
        return this;
    }
    
    public function height(percent: Float) {
        quantity = area.height * percent;  
        return this;
    }
    
    public function remainingWidth(percent: Float) {
        quantity = remainingArea.width * percent;
        return this;
    }
    
    public function remainingHeight(percent: Float) {
        quantity = remainingArea.height * percent;
        return this;
    }
    
    public function root() {
        if (parent == null) {
            return this;
        } else {
            return parent.root();
        }
    }
    
    public function centerAspectRatio(w: Float, h: Float) {
        spaceCheck();
        var ar1 = w / h;
        var ar2 = remainingArea.width / remainingArea.height;
        if (ar2 < ar1) {
            var y = (remainingArea.height - remainingArea.width / ar1) / 2;
            return pixels(y).top().parent.bottom().parent.middle();
        } else if (ar2 > ar1) {
            var x = (remainingArea.width - ar1 * remainingArea.height) / 2;
            return pixels(x).left().parent.right().parent.middle();
        } else {
            return this;
        }
    }
    
    private function offset(dx: Float, dy: Float) {
        area.x += dx;
        area.y += dy;
        if (remainingArea != null && remainingArea != area) {
            remainingArea.x += dx;
            remainingArea.y += dy;
        }
        return this;
    }
    
    public function moveLeft() {
        return offset( -quantity, 0);
    }
    
    public function moveUp() {
        return offset( 0, -quantity);
    }
    
    public function moveRight() {
        return offset(quantity, 0);
    }
    
    public function moveDown() {
        return offset(0, quantity);
    }
    
    public function fitInto(
        size: { width: Float, height: Float },
		maxWidth: Float = 0, maxHeight: Float = 0,
        align: Alignment = null)
    {
		var targetWidth = if (maxWidth != 0) Math.min(area.width, maxWidth) else area.width;
		var targetHeight = if (maxHeight != 0) Math.min(area.height, maxHeight) else area.height;
		var factor = Math.min(targetWidth / size.width, targetHeight / size.height);
        if (align == null) {
            align = MiddleCenter;
        }
        var result = new Rectangle(area.x, area.y, size.width * factor, size.height * factor);
        switch (align) {
            case TopLeft: 0;
            case TopCenter: result.x += (area.width - result.width) / 2;
            case TopRight: result.x += (area.width - result.width);
            case MiddleLeft: result.y += (area.height - result.height) / 2;
            case MiddleCenter: {
                result.x += (area.width - result.width) / 2;
                result.y += (area.height - result.height) / 2;
            }
            case MiddleRight: {
                result.y += (area.height - result.height) / 2;
                result.x += (area.width - result.width);
            }
            case BottomLeft: result.y += (area.height - result.height);
            case BottomCenter: {
                result.y += (area.height - result.height);
                result.x += (area.width - result.width) / 2;
            }
            case BottomRight: {
                result.y += (area.height - result.height);
                result.x += (area.width - result.width);
            }
            case Stretch: {
                result.copyFrom(area);
            }
        }
        var dbg = root().debugSprite;
        if (dbg != null) {
            dbg.graphics.lineStyle(1);
            dbg.graphics.drawRect(area.x, area.y, area.width, area.height);
            dbg.graphics.drawRect(result.x, result.y, result.width, result.height);        
        }
        return result;
    }    
    
    public function fitSprite(
        spr: DisplayObject, 
        maxWidth: Float = 0, maxHeight: Float = 0, align: Alignment = null ) 
    {
        //trace("*** fitSprite", id);
        spr.scaleX = 1;
        spr.scaleY = 1;
        var size = { width: spr.width, height: spr.height };
        //trace("size", size);
        var rect = fitInto(size, maxWidth, maxHeight, align);
        //trace("layout", rect);
        var factorX = rect.width / spr.width;
        var factorY = rect.height / spr.height;
        spr.scaleX = factorX;
        spr.scaleY = factorY;
        spr.x = rect.x;
        spr.y = rect.y;
    }
    
    public function debug(debugSprite: Sprite) {
        this.debugSprite = debugSprite;
        return this;
    }
}