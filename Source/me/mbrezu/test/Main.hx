
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

package me.mbrezu.test;

import flash.display.Sprite;
import flash.geom.Rectangle;
import haxe.ds.HashMap;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import me.mbrezu.haxisms.Json;
import me.mbrezu.haxisms.Flayout;
import me.mbrezu.haxisms.Random;
import me.mbrezu.haxisms.Random.SeedableRng;

class Main extends Sprite {
	public function new () {
		super ();
        var r = new TestRunner();
        r.add(new TestJson());
        r.add(new TestLayout());
        r.run();
        
        var r = new Random(1010);
        var buckets = new Array<Int>();
        for (i in 0...10) {
            buckets.push(0);
        }
        for (i in 0...1000000) {
            var n = r.int(0, 9);
            buckets[n]++;
        }
        trace(buckets);
	}
       
}

// TODO: formatter tests

class TestLayout extends TestCase {
    
    private function recteq(r1: Rectangle, r2: Rectangle) {
        return r1.x == r2.x && r1.y == r2.y && r1.width == r2.width && r1.height == r2.height;
    }
    
    public function testLeft() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .pixels(100).left().name("foo").parent
            .pixels(100).left().name("bar").parent
            .middle().name("baz").parent
            .root();
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(0, 0, 100, 480)));
        assertTrue(recteq(layout.findById("bar").area, new Rectangle(100, 0, 100, 480)));
        assertTrue(recteq(layout.findById("baz").area, new Rectangle(200, 0, 120, 480)));
    }
    
    public function testRight() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .pixels(100).right().name("foo").parent
            .pixels(100).right().name("bar").parent
            .middle().name("baz").parent
            .root();
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(220, 0, 100, 480)));
        assertTrue(recteq(layout.findById("bar").area, new Rectangle(120, 0, 100, 480)));
        assertTrue(recteq(layout.findById("baz").area, new Rectangle(0, 0, 120, 480)));
    }
    
    public function testTop() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .pixels(100).top().name("foo").parent
            .pixels(100).top().name("bar").parent
            .middle().name("baz").parent
            .root();
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(0, 0, 320, 100)));
        assertTrue(recteq(layout.findById("bar").area, new Rectangle(0, 100, 320, 100)));
        assertTrue(recteq(layout.findById("baz").area, new Rectangle(0, 200, 320, 280)));
    }
    
    public function testBottom() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .pixels(100).bottom().name("foo").parent
            .pixels(100).bottom().name("bar").parent
            .middle().name("baz").parent
            .root();
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(0, 380, 320, 100)));
        assertTrue(recteq(layout.findById("bar").area, new Rectangle(0, 280, 320, 100)));
        assertTrue(recteq(layout.findById("baz").area, new Rectangle(0, 0, 320, 280)));
    }
    
    public function testPercentages() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .width(0.5).bottom().name("foo").parent
            .remainingHeight(0.2).bottom().name("bar").parent
            .middle().name("baz").parent
            .root();
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(0, 320, 320, 160)));
        assertTrue(recteq(layout.findById("bar").area, new Rectangle(0, 256, 320, 64)));
        assertTrue(recteq(layout.findById("baz").area, new Rectangle(0, 0, 320, 256)));
    }
    
    public function testMargin() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .width(0.05).margin().name("foo").parent
            .root();            
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("foo").area, new Rectangle(16, 16, 288, 448)));
    }
    
    public function testComplex() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .width(0.05).margin()
                .height(0.15).top()
                    .width(0.25).left().name("btn1").parent
                    .width(0.25).right().name("btn2").parent
                    .parent
                .height(0.15).bottom()
                    .width(0.25).left().name("btn3").parent
                    .width(0.25).right().name("btn4").parent
                    .parent
                .middle().name("content").parent
                .parent
            .root();
        complexTestFinish(layout);
    }
    
    public function testComplex2() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480));
        var body = layout.width(0.05).margin();
        var top = body.height(0.15).top();
        var btn1 = top.width(0.25).left().name("btn1");
        var btn2 = top.width(0.25).right().name("btn2");
        var bottom = body.height(0.15).bottom();
        var btn3 = bottom.width(0.25).left().name("btn3");
        var btn4 = bottom.width(0.25).right().name("btn4");
        var content = body.middle().name("content");                
        complexTestFinish(layout);
    }
    
    private function complexTestFinish(layout: Layout) {
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("content").area, new Rectangle(16, 83.2, 288, 313.6)));
        assertTrue(recteq(layout.findById("btn1").area, new Rectangle(16, 16, 72, 67.2)));
        assertTrue(recteq(layout.findById("btn2").area, new Rectangle(232, 16, 72, 67.2)));
        assertTrue(recteq(layout.findById("btn3").area, new Rectangle(16, 396.8, 72, 67.2)));
        assertTrue(recteq(layout.findById("btn4").area, new Rectangle(232, 396.8, 72, 67.2)));        
    }
    
    public function testFitInto() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .width(0.05).margin()
                .height(0.15).top()
                    .width(0.25).left().name("btn1").parent
                    .width(0.25).right().name("btn2").parent
                    .parent
                .height(0.15).bottom()
                    .width(0.25).left().name("btn3").parent
                    .width(0.25).right().name("btn4").parent
                    .parent
                .middle().name("content").parent
                .parent
            .root();
        var btn1 = layout.findById("btn1");
        assertTrue(recteq(btn1.area, new Rectangle(16, 16, 72, 67.2)));
        var result = btn1.fitInto( { width: 48, height: 48 } );
        assertTrue(recteq(result, new Rectangle(18.4, 16, 67.2, 67.2)));
        var result2 = btn1.fitInto( { width: 48, height: 48 }, 64 );
        assertTrue(recteq(result2, new Rectangle(20, 17.6, 64, 64)));
    }
    
    public function testMove() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .height(0.5).top()
                .height(0.5).moveUp().name("tested")
                .parent;
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("tested").area, new Rectangle(0, -120, 320, 240)));
    }
    
    public function testAspectRatio() {
        var layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .centerAspectRatio(100, 100).name("tested").parent;
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("tested").area, new Rectangle(0, 80, 320, 320)));

        layout = Layout.make(new Rectangle(0, 0, 320, 480))
            .centerAspectRatio(100, 200).name("tested").parent;
        assertTrue(recteq(layout.area, new Rectangle(0, 0, 320, 480)));
        assertTrue(recteq(layout.findById("tested").area, new Rectangle(40, 0, 240, 480)));
    }
}

class TestJson extends TestCase {
    
    private function jsonRoundTrip(str: String) {
        var parsed = Js.parse(new StringReader(str));
        var stringified = Js.stringify(parsed);
        assertTrue(Std.is(parsed, JsonValue));
        assertTrue(str == stringified);        
    }
    
    public function testJsonParserArray() {
        jsonRoundTrip('{"a":1}');
    }

    public function testJsonParserDict() {
        jsonRoundTrip('[1,2,3]');
    }
    
    public function testJsonParser() {
        var parsed = Js.parse(new StringReader('[1,2,3]'));
        assertTrue(Std.is(parsed, JsonValue));
        var arr = parsed.arr;
        assertTrue(Type.enumEq(arr[0].js, JsInt(1)));
        assertTrue(Type.enumEq(arr[1].js, JsInt(2)));
        assertTrue(Type.enumEq(arr[2].js, JsInt(3)));
    }
   
    public function testJsonStringifier() {
        var arr = new Array<JsonValue>();
        arr.push(Js.int(3));
        arr.push(Js.int(2));
        arr.push(Js.str("test"));
        var original = Js.arr(arr);
        assertEquals('[3, 2, "test"]', Js.stringify(original, true));
    }      
}