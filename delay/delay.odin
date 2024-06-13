/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package delay

@(private)
Delay :: struct {
	timeRemaining: f32,
	updatable:bool,
	call:          union {
		DelayCall,
		DelayCallWithI64,
		DelayCallWithF64,
		DelayCallWithBool,
		DelayCallWithString,
		DelayCallWithRawPtr,
	},
}
@(private)
DelayCall :: struct {
	callback: proc(),
}
@(private)
DelayCallWithI64 :: struct {
	callback: proc(_: i64),
	param:    i64,
}
@(private)
DelayCallWithF64 :: struct {
	callback: proc(_: f64),
	param:    f64,
}
@(private)
DelayCallWithBool :: struct {
	callback: proc(_: bool),
	param:    bool,
}
@(private)
DelayCallWithString :: struct {
	callback: proc(_: string),
	param:    string,
}
@(private)
DelayCallWithRawPtr :: struct {
	callback: proc(_: rawptr),
	param:    rawptr,
}

@(private)
delays: [dynamic]Delay

start_no_param :: proc(callback: proc(), delayInSeconds: f32) {
	append(&delays, Delay{timeRemaining = delayInSeconds, call = DelayCall{callback = callback}})
}

start_with_i64 :: proc(callback: proc(_: i64), delayInSeconds: f32, param: i64) {
	append(
		&delays,
		Delay {
			timeRemaining = delayInSeconds,
			call = DelayCallWithI64{callback = callback, param = param},
		},
	)
}

start_with_f64 :: proc(callback: proc(_: f64), delayInSeconds: f32, param: f64) {
	append(
		&delays,
		Delay {
			timeRemaining = delayInSeconds,
			call = DelayCallWithF64{callback = callback, param = param},
		},
	)
}

start_with_bool :: proc(callback: proc(_: bool), delayInSeconds: f32, param: bool) {
	append(
		&delays,
		Delay {
			timeRemaining = delayInSeconds,
			call = DelayCallWithBool{callback = callback, param = param},
		},
	)
}

start_with_string :: proc(callback: proc(_: string), delayInSeconds: f32, param: string) {
	append(
		&delays,
		Delay {
			timeRemaining = delayInSeconds,
			call = DelayCallWithString{callback = callback, param = param},
		},
	)
}

start_with_rawptr :: proc(callback: proc(_: rawptr), delayInSeconds: f32, param: rawptr) {
	append(
		&delays,
		Delay {
			timeRemaining = delayInSeconds,
			call = DelayCallWithRawPtr{callback = callback, param = param},
		},
	)
}

start :: proc {
	start_no_param,
	start_with_i64,
	start_with_f64,
	start_with_bool,
	start_with_string,
	start_with_rawptr,
}

update :: proc(dt: f32) {
	toremove: [dynamic]int
	for &delay, idx in delays {
		if !delay.updatable {
			delay.updatable = true
			continue
		}
		delay.timeRemaining -= dt
		if (delay.timeRemaining <= 0) {
			switch call in delay.call {
			case DelayCall:
				call.callback()
			case DelayCallWithI64:
				call.callback(call.param)
			case DelayCallWithF64:
				call.callback(call.param)
			case DelayCallWithBool:
				call.callback(call.param)
			case DelayCallWithString:
				call.callback(call.param)
			case DelayCallWithRawPtr:
				call.callback(call.param)
			}
			append(&toremove, idx)
		}
	}
	#reverse for idx in toremove {
		unordered_remove(&delays, idx)
	}
}
