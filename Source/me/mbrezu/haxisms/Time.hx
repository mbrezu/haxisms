
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

import flash.Lib;

class TimeManager {
	var lastTime: Int;
	
	public function new() {
		lastTime = 0;
	}
	
	public function pause() {
		lastTime = 0;
	}
	
	public function resume() {
		lastTime = Lib.getTimer();
	}
	
	public function getDeltaTime() {
		var currentTime = Lib.getTimer();
		if (lastTime == 0) {
			lastTime = currentTime;
			return 0.0;
		} else {
			var result = (currentTime - lastTime) / 1000.0;
			lastTime = currentTime;
			return result;
		}
	}
}

class Cooldown {
	var interval: Float;
	var time: Float;

	public function new(interval: Float) {
		this.time = 0;
        this.interval = interval;
	}
	
	public function hot() {
        time = interval;
        return this;
	}
	
	public function update(deltaTime: Float) {
		time -= deltaTime;
		if (time < 0.0) {
			time = 0.0;
		}
        return this;
	}
	
	public function isCool() {
		return time <= 0.0;
	}
}
