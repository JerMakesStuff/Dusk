/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE
package logger

import "core:log"

create :: proc () -> log.Logger {
    return log.create_console_logger(opt = log.Options{
        .Level,
        .Date,
        .Time,
        .Short_File_Path,
        .Line,
        .Terminal_Color,
    })
}