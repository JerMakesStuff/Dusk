/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE
package dusk

import "core:log"

create_logger :: proc () -> log.Logger {
    return log.create_console_logger(
        lowest = .Debug when ODIN_DEBUG else .Info,
        opt = log.Options{
            .Level,
            .Date,
            .Time,
            .Short_File_Path,
            .Line,
            .Terminal_Color,
        },
    )
}