/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

@(private)
Delay :: struct {
	time_remaining: f32,
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

start_delay_no_param :: proc(callback: proc(), delay_in_seconds: f32) {
	append(&delays, Delay{time_remaining = delay_in_seconds, call = DelayCall{callback = callback}})
}

start_delay_with_i64 :: proc(callback: proc(_: i64), delay_in_seconds: f32, param: i64) {
	append(
		&delays,
		Delay {
			time_remaining = delay_in_seconds,
			call = DelayCallWithI64{callback = callback, param = param},
		},
	)
}

start_delay_with_f64 :: proc(callback: proc(_: f64), delay_in_seconds: f32, param: f64) {
	append(
		&delays,
		Delay {
			time_remaining = delay_in_seconds,
			call = DelayCallWithF64{callback = callback, param = param},
		},
	)
}

start_delay_with_bool :: proc(callback: proc(_: bool), delay_in_seconds: f32, param: bool) {
	append(
		&delays,
		Delay {
			time_remaining = delay_in_seconds,
			call = DelayCallWithBool{callback = callback, param = param},
		},
	)
}

start_delay_with_string :: proc(callback: proc(_: string), delay_in_seconds: f32, param: string) {
	append(
		&delays,
		Delay {
			time_remaining = delay_in_seconds,
			call = DelayCallWithString{callback = callback, param = param},
		},
	)
}

start_delay_with_rawptr :: proc(callback: proc(_: rawptr), delay_in_seconds: f32, param: rawptr) {
	append(
		&delays,
		Delay {
			time_remaining = delay_in_seconds,
			call = DelayCallWithRawPtr{callback = callback, param = param},
		},
	)
}

start_delay :: proc {
	start_delay_no_param,
	start_delay_with_i64,
	start_delay_with_f64,
	start_delay_with_bool,
	start_delay_with_string,
	start_delay_with_rawptr,
}

update_delays :: proc(dt: f32, allocator:=context.temp_allocator) {
	toremove := make([dynamic]int, allocator)
	for &delay, idx in delays {
		if !delay.updatable {
			delay.updatable = true
			continue
		}
		delay.time_remaining -= dt
		if (delay.time_remaining <= 0) {
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
