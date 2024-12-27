package dusk

import "core:encoding/json"
import "core:log"
import "core:os"
import "core:strings"

import rl "vendor:raylib"

Sprite :: struct {
    texture     : rl.Texture2D,
    source_rect : rl.Rectangle,
    origin      : rl.Vector2,
    tint        : rl.Color,
}

Frame :: struct {
    sprite:Sprite,
    duration_in_seconds:f32,
}

Animation :: struct {
    frames             : []Frame,
    current_frame      : u8,
    current_frame_time : f32,
}

AnimatedSprite :: struct {
    animations : []Animation,
    current_animation : u8,
}

SpriteSheet :: struct {
    sprites : map[string]Sprite,
    texture : rl.Texture2D,
}

TileSheet :: struct {
    tiles : []Sprite,
}

draw_sprite :: proc(sprite:Sprite, position:rl.Vector2, scale:f32=1.0, rotation:f32=0) {
    destination_rect := rl.Rectangle {
        x = position.x,
        y = position.y,
        width = sprite.source_rect.width * scale,
        height = sprite.source_rect.height * scale,
    }
    rl.DrawTexturePro(sprite.texture, sprite.source_rect, destination_rect, sprite.origin, rotation, sprite.tint )
}

draw_animated_sprite :: proc(sprite:AnimatedSprite, position:rl.Vector2, scale:f32=1.0, rotation:f32=0) {
    animation := sprite.animations[sprite.current_animation]
    frame := animation.frames[animation.current_frame]
    draw_sprite(frame.sprite, position, scale, rotation)
}

update_animated_sprite :: proc(sprite:^AnimatedSprite, delta_time:f32) {
    animation := &sprite.animations[sprite.current_animation]
    frame := animation.frames[animation.current_frame]
    animation.current_frame_time += delta_time
    if(animation.current_frame_time > frame.duration_in_seconds) {
        animation.current_frame_time -= frame.duration_in_seconds
        animation.current_frame += 1
        if animation.current_frame >= cast(u8)len(animation.frames) {
            animation.current_frame = 0
        }
    }    
}

load_sprite :: proc(filename:string) -> Sprite {
    texture := rl.LoadTexture(strings.clone_to_cstring(filename))
    sprite := Sprite {
        texture = texture,
        source_rect = {
            x = 0,
            y = 0,
            width  = cast(f32)texture.width,
            height = cast(f32)texture.height,
        },
        origin = {0, 0},
        tint = rl.WHITE,
    }
    return sprite   
}

unload_sprite :: proc(sprite:^Sprite) {
    rl.UnloadTexture(sprite.texture)
    sprite^ = {}
}

load_sprite_sheet :: proc(filename:string) -> SpriteSheet {
    last_forward_slash := strings.last_index(filename, "/")
    last_back_slash := strings.last_index(filename, "\\")
    image_root_path := ""

    if last_forward_slash != -1 && last_forward_slash > last_back_slash {
        image_root_path = string(filename[:last_forward_slash+1])
    } else if last_back_slash != -1 && last_back_slash > last_forward_slash {
        image_root_path = string(filename[:last_back_slash+1])
    }

    data, ok := os.read_entire_file_from_filename(filename, context.temp_allocator)
    if !ok {
        log.panic("[DUSK]", "Failed to load sprite sheet from", filename)
    }

    json_data, err := json.parse(data)
    if err != .None {
        log.error("[DUSK]", "Failed to parse sprite sheet from json file", filename)
        log.error("[DUSK]", err)
    }
    defer json.destroy_value(json_data)

    root := json_data.(json.Object)

    meta := root["meta"].(json.Object)
    image_filename := meta["image"].(json.String)
    if image_root_path != "" {
        image_filename = strings.concatenate({image_root_path, image_filename}, context.temp_allocator)
    }

    sprite_sheet:SpriteSheet
    sprite_sheet.texture = rl.LoadTexture(strings.clone_to_cstring(image_filename, context.temp_allocator))

    frames := root["frames"].(json.Object)

    for sprite_name, value in frames {
        sprite_data := value.(json.Object)
        frame := sprite_data["frame"].(json.Object)
        sprite := Sprite {
            texture = sprite_sheet.texture,
            source_rect = {
                x      = cast(f32)frame["x"].(json.Float),
                y      = cast(f32)frame["y"].(json.Float),
                width  = cast(f32)frame["w"].(json.Float),
                height = cast(f32)frame["h"].(json.Float),
            },
            origin = {},
            tint = rl.WHITE,
        }
        cloned_name := strings.clone(sprite_name)
        sprite_sheet.sprites[cloned_name] = sprite
        log.info("sprite_name:", sprite_name)
    }
    return sprite_sheet    
}

unload_sprite_sheet :: proc(sprite_sheet:^SpriteSheet) {
    rl.UnloadTexture(sprite_sheet.texture)
    for key in sprite_sheet.sprites {
        delete(key)
    }
    clear(&sprite_sheet.sprites)
    delete(sprite_sheet.sprites)
}

draw_tile :: proc(tilesheet:TileSheet, tile_index:u32, position:rl.Vector2, scale:f32=1.0, rotation:f32=0.0) {
    draw_sprite(tilesheet.tiles[tile_index], position, scale, rotation)
}

load_tile_sheet :: proc(filename:string, tile_width:i32, tile_height:i32=0) -> TileSheet {
    tile_height:=tile_height
    if tile_height == 0 {
        tile_height = tile_width
    }    
    texture := rl.LoadTexture(strings.clone_to_cstring(filename))
    
    tiles_per_row := texture.width / tile_width
    number_of_rows := texture.height / tile_height
    tile_count := tiles_per_row * number_of_rows
    tile_sheet : TileSheet
    tile_sheet.tiles = make([]Sprite, tile_count)

    for tile_index in 0..<tile_count {
        x_index := tile_index % tiles_per_row
        y_index := tile_index / tiles_per_row
        tile_sheet.tiles[tile_index] = {
            texture = texture,
            source_rect = {
                x      = cast(f32)(x_index * tile_width),
                y      = cast(f32)(y_index * tile_height),
                width  = cast(f32)tile_width,
                height = cast(f32)tile_height,
            },
            origin = {0, 0},
            tint = rl.WHITE,
        }
    }    
    return tile_sheet
}

unload_tile_sheet :: proc(tile_sheet:^TileSheet) {
    rl.UnloadTexture(tile_sheet.tiles[0].texture)
    delete(tile_sheet.tiles)
    tile_sheet^ = {}
}