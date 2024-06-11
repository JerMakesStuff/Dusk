/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package delay

DelayProc :: proc(_:any)

@private
Delay :: struct {
    timeRemaining: f32,
    call: DelayProc,
    data: any,
}

@private
delays:[dynamic]Delay


start :: proc(call: DelayProc, time: f32, data:any = nil) {
    append(&delays, Delay{call = call, timeRemaining = time, data = data})
}

update :: proc(dt: f32) {
    toremove:[dynamic]int
    for &d, idx in delays {
        d.timeRemaining -= dt
        if(d.timeRemaining <= 0) {
            d.call(d.data)
            append(&toremove, idx)
        }
    }
    #reverse for idx in toremove {
        unordered_remove(&delays, idx)
    }
}