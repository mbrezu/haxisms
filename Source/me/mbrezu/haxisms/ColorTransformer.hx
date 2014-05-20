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
import flash.geom.ColorTransform;

class ColorTransformer
{
    var obj: DisplayObject;

    public function new(obj: DisplayObject) 
    {
        this.obj = obj;
    }
    
    public var redMultiplier(get, set): Float;
    
    public function get_redMultiplier() {
        return obj.transform.colorTransform.redMultiplier;
    }
    
    public function set_redMultiplier(value: Float) {
        var t = obj.transform.colorTransform;
        obj.transform.colorTransform = new ColorTransform(value, t.greenMultiplier, t.blueMultiplier);
        return value;
    }

    public var greenMultiplier(get, set): Float;
    
    public function get_greenMultiplier() {
        return obj.transform.colorTransform.greenMultiplier;
    }
    
    public function set_greenMultiplier(value: Float) {
        var t = obj.transform.colorTransform;
        obj.transform.colorTransform = new ColorTransform(t.redMultiplier, value, t.blueMultiplier);
        return value;
    }

    public var blueMultiplier(get, set): Float;
    
    public function get_blueMultiplier() {
        return obj.transform.colorTransform.blueMultiplier;
    }
    
    public function set_blueMultiplier(value: Float) {
        var t = obj.transform.colorTransform;
        obj.transform.colorTransform = new ColorTransform(t.redMultiplier, t.greenMultiplier, value);
        return value;
    }

    
}