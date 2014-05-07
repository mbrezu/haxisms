
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

import me.mbrezu.haxisms.Formatter;

using StringTools;

enum JsValue {
    JsInt(v: Int);
    JsFloat(v: Float);
    JsString(v: String);
    JsBool(v: Bool);
    JsNull;
    JsArray(v: Array<JsonValue>);
    JsObject(v: Map<String, JsonValue>);
}

class JsonValue {
    public var js: JsValue;
    
    public function new (js) {
        this.js = js;
    }
    
    public var obj(get, null): Map < String, JsonValue >;
    
    function get_obj() {
        switch (js) {
            case JsObject(v): return v;
            default: throw "Internal error.";
        }        
    }
    
    public var arr(get, null): Array<JsonValue>;

    function get_arr() {
        switch (js) {
            case JsArray(v): return v;
            default: throw "Internal error.";
        }        
    }
    
    public var float(get, null): Float;
    
    function get_float(): Float {
        switch (js) {
            case JsInt(v): return v;
            case JsFloat(v): return v;
            default: throw "Internal error.";
        }        
    }
    
    public var int(get, null): Int;
    
    function get_int() {
        switch (js) {
            case JsInt(v): return v;
            default: throw "Internal error.";
        }        
    }
    
    public var bool(get, null): Bool;
    
    function get_bool() {
        switch (js) {
            case JsBool(v): return v;
            default: throw "Internal error.";
        }        
    }
       
    public var isNull(get, null): Bool;
    
    function get_isNull(): Bool {
        return switch (js) {
            case JsNull: true;
            default: false;
        }
    }
    
    public var str(get, null): String;
    
    function get_str():String {
        switch (js) {
            case JsString(v): return v;
            default: throw "Internal error.";
        }
    }
    
}

interface IReader {
    public function readChar(): Int;
    public function peekChar(): Int;
    public function getPosition(): Int;
}

enum TokenType {
    OpenArray;
    CloseArray;
    OpenObject;
    CloseObject;
    Comma;
    Colon;
    String(v: String);
    NumberInt(v: Int);
    NumberDouble(v: Float);
    BooleanTrue;
    BooleanFalse;
    Null;
}

typedef Token = {
    type: TokenType,
    pos: Int    
};

class StringReader implements IReader {
    var str: String;
    var pos: Int;
    
    public function new (str) {
        this.str = str;
        pos = 0;
    }
    
    public function readChar(): Int {
        var result = peekChar();
        pos++;
        return result;
    }
    
    public function peekChar(): Int {
        var result = 0;
        if (pos == str.length) {
            result = -1;
        } else {
            result = str.charCodeAt(pos);
        }
        return result;
    }
    
    public function getPosition() {
        return pos;
    }
    
}

typedef JsonState = {
    buffer: Token,
    js: IReader
}

class Js {
    public static function stringify(js: JsonValue, prettyPrint: Bool = false, maxColumn: Int = 80) {
        if (!prettyPrint) {
            var sb = new StringBuf();
            stringifyImpl(js, sb);
            return sb.toString();
        } else {
            return Js.prettyPrint(js, maxColumn);
        }
    }
    
    public static function parse(js: IReader): JsonValue {
        var state = { buffer: null, js: js };
        return parseImpl(state);
    }
    
    public static function str(s: String) {
        return new JsonValue(JsString(s));
    }
    
    public static function int(i: Int) {
        return new JsonValue(JsInt(i));
    }
    
    public static function float(f: Float) {
        return new JsonValue(JsFloat(f));
    }
    
    public static function obj(dict) {
        return new JsonValue(JsObject(dict));
    }
    
    public static function arr(v) {
        return new JsonValue(JsArray(v));
    }
    
    public static var nil(get, null): JsonValue;
    
    public static function get_nil() {
        return new JsonValue(JsNull);
    }
    
    public static function bool(v) {
        return new JsonValue(JsBool(v));
    }
    
    //public static function tokenize(js: IReader) {
        //var state = { buffer: null, js: js };
        //while (true) {
            //var tok = nextToken(state);
            //if (tok == null) {
                //return;
            //}
        //}
    //}

    static function parseImpl(state: JsonState): JsonValue {
        var tok = peekToken(state);
        if (tok == null) {
            throw "Parse error.";
        }
        switch (tok.type) {
            case BooleanFalse: { 
                nextToken(state);
                return new JsonValue(JsBool(false));
            }
            case BooleanTrue: {
                nextToken(state);
                return new JsonValue(JsBool(true));
            }
            case Null: {
                nextToken(state);
                return new JsonValue(JsNull);
            }
            case OpenArray: return parseArray(state);
            case OpenObject: return parseObject(state);
            case String(v): {
                nextToken(state);
                return new JsonValue(JsString(v));
            }
            case NumberInt(v): {
                nextToken(state);
                return new JsonValue(JsInt(v));
            }
            case NumberDouble(v): {
                nextToken(state);
                return new JsonValue(JsFloat(v));
            }
            case Comma | Colon | CloseObject | CloseArray: throw "Parse error.";
        }
    }    
    
    static function parseObject(state: JsonState) {
        var result = new Map<String, JsonValue>();
        match(state, OpenObject, true);
        while (true) {
            var tok = nextToken(state);
            if (tok == null) {
                throw "Parse error.";                
            }
            switch(tok.type) {
                case String(key): {
                    match(state, Colon, true);
                    result[key] = parseImpl(state);
                    consumeCommaIfPresent(state);
                }
                case CloseObject: return new JsonValue(JsObject(result));
                default: throw "Parse error.";
            }
        }
    }
    
    static function parseArray(state: JsonState) {
        var result = [];
        match(state, OpenArray, true);
        while (true) {
            var tok = peekToken(state);
            if (tok == null) {
                throw "Parse error.";                
            }
            if (tok.type == CloseArray) {
                nextToken(state);
                break;
            } else {
                result.push(parseImpl(state));
                consumeCommaIfPresent(state);
            }
        }
        return new JsonValue(JsArray(result));
    }
    
    static private function consumeCommaIfPresent(state:JsonState) 
    {
        var tok = peekToken(state);
        if (tok != null && tok.type == Comma) {
            nextToken(state);
        }
    }
    
    static function match(state: JsonState, tt: TokenType, consume: Bool) {
        var tok = peekToken(state);
        if (tok == null || tok.type != tt) {
            throw "Parse error.";
        }
        if (consume) {
            nextToken(state);
        }
    }
    
    static function peekToken(state: JsonState): Token {
        if (state.buffer == null) {
            state.buffer = nextTokenImpl(state.js);
        }
        return state.buffer;
    }
    
    static function nextToken(state: JsonState): Token {
        if (state.buffer == null) {
            return nextTokenImpl(state.js);
        } else {
            var result = state.buffer;
            state.buffer = null;
            return result;
        }
    }
    
    static function nextTokenImpl(js: IReader): Token {
        var c = eatWhiteSpace(js);
        if (c == -1) {
            return null;
        }
        if (c == 't'.code || c == 'f'.code) {
            return booleanToken(js, c == 't'.code);
        } else if (c == 'n'.code) {
            return nullToken(js);
        } else if ((c >= '0'.code && c <= '9'.code) || c == '.'.code || c == '-'.code) {
            return numberToken(js, c);
        } else if (c == '"'.code) {
            return stringToken(js, c);
        } else if (c == '{'.code) {
            return { type: OpenObject, pos: js.getPosition() - 1 };
        } else if (c == '}'.code) {
            return { type: CloseObject, pos: js.getPosition() - 1 };
        } else if (c == '['.code) {
            return { type: OpenArray, pos: js.getPosition() - 1 };
        } else if (c == ']'.code) {
            return { type: CloseArray, pos: js.getPosition() - 1 };
        } else if (c == ','.code) {
            return { type: Comma, pos: js.getPosition() - 1 };
        } else if (c == ':'.code) {
            return { type: Colon, pos: js.getPosition() - 1 };
        } else {
            throw "Parse error.";
        }
    }
    
    static private function stringToken(js:IReader, c: Int) 
    {
        var pos = js.getPosition() - 1;
        
        var sb = new StringBuf();        
        var escaped = false;
        while (true) {
            c = js.readChar();
            if (c == -1) {
                throw "Parse error.";
            }
            if (!escaped) {
                if (c == '\"'.code) {
                    return { type: String(sb.toString()), pos: pos };
                } else if (c == '\\'.code) {
                    escaped = true;
                } else {
                    sb.addChar(c);
                }
            } else {
                escaped = false;
                switch (c) {
                case '\"'.code:
                    sb.addChar(c);
                case '\''.code:
                    sb.addChar (c);
                case 'b'.code:
                    sb.addChar ('\x09'.code);
                case 'f'.code:
                    sb.addChar ('\x0C'.code);
                case 'n'.code:
                    sb.addChar ("\n".code);
                case 'r'.code:
                    sb.addChar ('\r'.code);
                case 't'.code:
                    sb.addChar ('\t'.code);
                case '\\'.code:
                    sb.addChar ('\\'.code);
                case '/'.code:
                    sb.addChar ('/'.code);
                case 'u'.code:
                    throw "Parse error: unicode escapes not supported.";
                default:
                    throw "Parse error.";
                }
            }
        }
    }
    
    static private function numberToken(js:IReader, c: Int)
    {
        var pos = js.getPosition() - 1;
        var sb = new StringBuf();
        sb.addChar(c);
        
        var afterDot = c == '.'.code;
        var afterE = false;
        var  immediatelyAfterE = false;
        while (true) {
            c = js.peekChar();
            if (c == -1 || !(
                    (c >= '0'.code && c <= '9'.code)
                    || (!afterDot && c == '.'.code)
                    || (!afterE && (c == 'e'.code || c == 'E'.code))
                    || (immediatelyAfterE && (c == '+'.code || c == '-'.code)))) {
                var content = sb.toString();
                var type = if (afterDot || afterE) 
                    TokenType.NumberDouble(Std.parseFloat(content)) 
                    else TokenType.NumberInt(Std.parseInt(content));
                return { type: type, pos: pos };
            }
            sb.addChar(c);
            if (c == '.'.code) {
                afterDot = true;
            }
            if (c == 'e'.code || c == 'E'.code) {
                afterE = true;
                afterDot = true;
                immediatelyAfterE = true;
            } else {
                immediatelyAfterE = false;
            }
            js.readChar();
        }
    }
    
    static function nullToken(js): Token {
        var pos = js.getPosition() - 1;
        check(js, 'u'.code);
        check(js, 'l'.code);
        check(js, 'l'.code);
        return { type: Null, pos: pos };
    }
    
    static function check(js, code) {
        if (js.readChar() != code) {
            throw "Parse error.";
        }
    }
    
    static function booleanToken(js, isTrue) {
        var pos = js.getPosition() - 1;
        if (isTrue) {
            check(js, 'r'.code);
            check(js, 'u'.code);
            check(js, 'e'.code);
        } else {
            check(js, 'a'.code);
            check(js, 'l'.code);
            check(js, 's'.code);            
            check(js, 'e'.code);            
        }
        return { type: isTrue ? BooleanTrue : BooleanFalse, pos: pos };
    }
    
    static function eatWhiteSpace(js: IReader): Int {
        var result = js.readChar();
        while ((result > 8 && result < 14) || result == 32) {
            result = js.readChar();
        }
        return result;
    }
    
    static function jsonEscape(v: String): String {       
        return '"' + v.replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r").replace('"', '\\"') + '"';
    }
    
    static function addArray(arr: Array<JsonValue>, sb: StringBuf) {
        sb.add("[");
        for (i in 0...arr.length) {
            stringifyImpl(arr[i], sb);
            if (i < arr.length - 1) {
                sb.add(",");
            }
        }
        sb.add("]");
    }
    
    static function addDict(dict: Map < String, JsonValue > , sb: StringBuf) {
        sb.add("{");
        var keys = [];
        for (key in dict.keys()) {
            keys.push(key);
        }
        for (ik in 0...keys.length) {
            var key = keys[ik];
            sb.add(jsonEscape(key));
            sb.add(":");
            stringifyImpl(dict[key], sb);
            if (ik < keys.length - 1) {
                sb.add(",");
            }
        }
        sb.add("}");
    }
    
    static function stringifyImpl(js: JsonValue, sb: StringBuf) {
        switch (js.js) {
            case JsInt(v): sb.add(Std.string(v));
            case JsFloat(v): sb.add(Std.string(v));
            case JsString(v): sb.add(jsonEscape(v));
            case JsBool(v): sb.add(if (v) "true" else "false");
            case JsNull: sb.add("null");
            case JsArray(v): addArray(v, sb);
            case JsObject(v): addDict(v, sb);
        }
    }
    
    static function prettyPrint(js: JsonValue, maxColumn: Int) {
        var doc = docify(js);
        return Formatter.format(doc, maxColumn);
    }
    
    static function docify(js: JsonValue) {
        switch (js.js) {
            case JsInt(v): return Str(Std.string(v));
            case JsFloat(v): return Str(Std.string(v));
            case JsBool(v): return Str(if (v) "true" else "false");
            case JsNull: return Str("null");
            case JsString(v): return Str(jsonEscape(v));
            case JsArray(v): {
                var list = [];
                for (i in 0...v.length) {
                    if (i == v.length - 1) {
                        list.push(docify(v[i]));
                    } else {
                        list.push(NoBreak([docify(v[i]), Str(", ")]));
                    }
                }
                return NoBreak([Str('['), MaybeBreak(list), Str(']')]);
            }
            case JsObject(v): {
                var list = [];
                var keys = [];
                for (k in v.keys()) {
                    keys.push(k);
                }
                for (i in 0...keys.length) {
                    var key = keys[i];
                    if (i == keys.length - 1) {
                        list.push(NoBreak([Str(jsonEscape(key)), Str(": "), docify(v[key])]));
                    } else {
                        list.push(NoBreak([Str(jsonEscape(key)), Str(": "), docify(v[key]), Str(", ")]));
                    }
                }
                return NoBreak([Str('{'), MaybeBreak(list), Str('}')]);
            }
        }
    }
}