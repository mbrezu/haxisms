
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

using Lambda;
using StringTools;

enum Doc {
    NoBreak(v: Array<Doc>);
    AlwaysBreak(v: Array<Doc>);
    MaybeBreak(v: Array<Doc>);
    Str(v: String);
}

enum ConsList<T> {
    Nil;
    Cons(item: T, next: ConsList<T>);
}

typedef FormatterState = {
    maxColumn: Int,
    lines: ConsList<String>
};

class Formatter {
    
    public static function format(input: Doc, maxColumn: Int) {
        var state = { maxColumn: maxColumn, lines: Nil };
        state = formatImpl(input, state);
        return render(state, true);
    }
    
    static function formatImpl(input: Doc, state: FormatterState): FormatterState {
        switch (input) {
            case NoBreak(list): {
                for (item in list) {
                    state = formatImpl(item, state);
                }
                return state;
            }
            case Str(str): return append(str, state);
            case MaybeBreak(list): return formatMaybeBreak(list, state);
            case AlwaysBreak(list): return formatAlwaysBreak(list, state);            
        }
    }
    
    static function formatMaybeBreak(list: Array<Doc>, state: FormatterState): FormatterState {
        var oneLiner = formatImpl(NoBreak(list), { maxColumn: -1, lines: Nil } );
        if (state.maxColumn == -1 || getIndent(oneLiner) + getIndent(state) < state.maxColumn) {
            return append(render(oneLiner), state);
        } else {
            return formatAlwaysBreak(list, state);
        }
    }
    
    static function formatAlwaysBreak(list: Array<Doc>, state: FormatterState): FormatterState {
        var indent = getIndent(state);
        if (list.length == 0) {
            return state;
        } else if (list.length == 1) {
            return formatImpl(list[0], state);
        } else {
            for (i in 0...list.length) {
                var item = list[i];
                state = formatImpl(item, state);
                if (i < list.length - 1) {
                    state = newLine(indent, state);
                }
            }
            return state;
        }        
    }
    
    static function append(str: String, state: FormatterState): FormatterState {
        return switch (state.lines) {
            case Nil: { maxColumn: state.maxColumn, lines: Cons(str, Nil) };
            case Cons(h, t): { maxColumn: state.maxColumn, lines: Cons(h + str, t) }
        }
    }
    
    static function newLine(indent: Int, state: FormatterState): FormatterState {
        var sb = new StringBuf();
        for (i in 0...indent) {
            sb.addChar(32);
        }        
        return { maxColumn: state.maxColumn, lines: Cons(sb.toString(), state.lines) };
    }
    
    static function render(state: FormatterState, final: Bool = false) {
        var lines = [];
        var consLines = state.lines;
        var done = false;
        while (!done) {
            switch (consLines) {
                case Nil: done = true;
                case Cons(h, t): {
                    lines.unshift(h);
                    consLines = t;
                }
            }
        }
        var sb = new StringBuf();
        for (i in 0...lines.length) {
            var line = lines[i];
            sb.add(final ? line.rtrim() : line);
            if (i < lines.length - 1) {
                sb.add("\n");            
            }
        }
        return sb.toString();
    }
    
    static function getIndent(state: FormatterState) {
        return switch (state.lines) {
            case Nil: 0;
            case Cons(h, _): h.length;
        }
    }    
}