package dusk

import "core:log"
import "core:encoding/ini"
import "core:strconv"
@require import "core:fmt"

Settings :: struct {
    resolution:[2]i32,
    fullscreen:bool,
    vsync:bool,
    master_volume:f64,
    music_volume:f64,
    sfx_volume:f64,

    _map : ini.Map,
}

load_settings :: proc(filename:string) -> Settings {
    settings : Settings = {}

    settings_map, _, settings_loaded := ini.load_map_from_path(filename, context.temp_allocator)
    settings._map = settings_map

    if(!settings_loaded) {
        log.error("[dusk]", "!!! Failed to load ", filename, "file !!!")
    } else {
        log.info("[dusk]", "Settings loaded from", filename)
    }
    
    _, has_graphics_settings := settings_map["graphics"]
    if(!has_graphics_settings) {
        log.warn("[dusk]", "Settings did not contain graphics settings")
    }
        
    settings.resolution.x = auto_cast get_setting_from_map_as_int (settings_map, "graphics", "width",  1280 )
    settings.resolution.y = auto_cast get_setting_from_map_as_int (settings_map, "graphics", "height", 720  )

    settings.fullscreen   = get_setting_from_map_as_bool(settings_map, "graphics", "fullscreen", false)
    settings.vsync        = get_setting_from_map_as_bool(settings_map, "graphics", "vsync",      true )
        
    _, has_audio_settings := settings_map["audio"]
    if(has_audio_settings) {} else {
        log.warn("[dusk]", "Settings did not contain audio settings")
    }

    settings.master_volume = get_setting_from_map_as_float(settings_map, "audio", "master", 1.0)
    settings.music_volume  = get_setting_from_map_as_float(settings_map, "audio", "music",  1.0)
    settings.sfx_volume    = get_setting_from_map_as_float(settings_map, "audio", "sfx",    1.0)
    
    return settings
}

get_setting_as_string :: proc(game:^Game, category:string, setting_name:string, default_value:string) -> string {
    return get_setting_from_map_as_string(game.settings._map, category, setting_name, default_value)
}

get_setting_as_int :: proc(game:^Game, category:string, setting_name:string, default_value:int) -> int {
    return get_setting_from_map_as_int(game.settings._map, category, setting_name, default_value)
}

get_setting_as_float :: proc(game:^Game, category:string, setting_name:string, default_value:f64) -> f64 {
    return get_setting_from_map_as_float(game.settings._map, category, setting_name, default_value)
}

get_setting_as_bool :: proc(game:^Game, category:string, setting_name:string, default_value:bool) -> bool {
    return get_setting_from_map_as_bool(game.settings._map, category, setting_name, default_value)
}

// NOTE: this is case sensitive
get_setting_as_enum :: proc(game:^Game, category:string, setting_name:string, default_value:$T) -> T {
    return get_setting_from_map_as_enum(game.settings._map, category, setting_name, default_value)
}

@private
get_setting_from_map_as_string :: proc(settings_map:ini.Map, category:string, setting_name:string,  default_value:string) -> string {
    category_map, has_category := settings_map[category]
    if(!has_category) {
        return default_value
    }
    value, ok := category_map[setting_name]
    if(!ok) {
        value = default_value
        log.warn("[dusk]", "--- Settings did not contain", category, "setting for", setting_name, "using default of", default_value, "instead. ---")
    }
    return value
}

@private
get_setting_from_map_as_int :: proc(settings_map:ini.Map, category:string, setting_name:string,  default_value:int) -> int {
    buffer:[32]byte = {}
    value := get_setting_from_map_as_string(settings_map, category, setting_name, strconv.itoa(buffer[:], default_value))
    return strconv.atoi(value)
}

@private
get_setting_from_map_as_float :: proc(settings_map:ini.Map, category:string, setting_name:string,  default_value:f64) -> f64 {
    buffer:[32]byte = {}
    value := get_setting_from_map_as_string(settings_map, category, setting_name, strconv.ftoa(buffer[:], default_value, 'f', 2, 64))
    return strconv.atof(value)
}

@private
get_setting_from_map_as_bool :: proc(settings_map:ini.Map, category:string, setting_name:string,  default_value:bool) -> bool {
    value := get_setting_from_map_as_string(settings_map, category, setting_name, "true" if default_value else "false") 
    return_value, _ :=  strconv.parse_bool(value)
    return return_value
}

@private
get_setting_from_map_as_enum :: proc(settings_map:ini.Map, category:string, setting_name:string, default_value:$T) -> T {
    default_string, _ := fmt.enum_value_to_string(default_value)
    value := get_setting_from_map_as_string(settings_map, category, setting_name, default_string)
    
    return_value, ok := fmt.string_to_enum_value(T, value)
    if !ok {
        return_value = default_value
    }
    return return_value
}