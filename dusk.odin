/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "base:builtin"

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import "core:time"

import rl "vendor:raylib"

V2ZERO :: rl.Vector2{0,0}
TIMING_FRAMES_TO_AVERAGE    :: 60
SECONDS_BETWEEN_TIMING_LOGS :: 60

run :: proc(game:^Game) {

    default_allocator := context.allocator
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, default_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    context.logger = create_logger()
    context.user_ptr = game

    game.settings = load_settings("settings.ini")

    // INIT RAYLIB WINDOW
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    if(game.settings.vsync) {
        rl.SetConfigFlags({.VSYNC_HINT}) 
    }
    if(game.settings.fullscreen) {
        rl.SetConfigFlags({.FULLSCREEN_MODE})
    }
    
    rl.InitWindow(game.settings.resolution.x, game.settings.resolution.y, strings.clone_to_cstring(game.name, context.temp_allocator))
    game.screen_size.x = rl.GetScreenWidth()
    game.screen_size.y = rl.GetScreenHeight()
    defer rl.CloseWindow()

    use_vertual_resolution := game.virtual_resolution.x != 0 && game.virtual_resolution.y != 0
    renderTexture:rl.RenderTexture
    renderTextureSrc:rl.Rectangle
    renderTextureDest:= rl.Rectangle{0,0, cast(f32)game.screen_size.x, cast(f32)game.screen_size.y}
    renderTextureAspect :f32 = 16/9
    
    if(use_vertual_resolution) {
        game.screen_size = game.virtual_resolution
    }

    renderTexture = rl.LoadRenderTexture(game.screen_size.x, game.screen_size.y)
    renderTextureSrc = rl.Rectangle{0,0,f32(renderTexture.texture.width),f32(-renderTexture.texture.height)}
    renderTextureAspect = renderTextureSrc.width / -renderTextureSrc.height

    // INIT RAYLIB AUDIO
    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()
    
    // START GAME
    if !game->start() do return
    defer game->shutdown()

    screenWidth := f32(rl.GetScreenWidth())
    screenHeight := f32(rl.GetScreenHeight())

    timings:Timings
    prev_timings:[TIMING_FRAMES_TO_AVERAGE]Timings
    prev_timing_index := 0
    last_timing_log := time.tick_now()

    // GAME LOOP
    for !rl.WindowShouldClose() {
        timings.start_time = time.tick_now()
        deltaTime := rl.GetFrameTime()
        runTime := f32(rl.GetTime())
        game.fps = int(rl.GetFPS())

        if rl.IsWindowResized() {
            screenWidth = f32(rl.GetScreenWidth())
            screenHeight = f32(rl.GetScreenHeight())
            if !use_vertual_resolution {
                game.screen_size.x = cast(i32)screenWidth
                game.screen_size.y = cast(i32)screenHeight
                renderTextureDest.width = screenWidth
                renderTextureDest.height = screenHeight
            } else {
                renderTextureDest.width = screenHeight*renderTextureAspect
                renderTextureDest.height = screenHeight
                renderTextureDest.x = screenWidth / 2 - renderTextureDest.width / 2
            }
        }       

        timings.update_data_time = time.tick_since(timings.start_time)

        timings.start_time = time.tick_now()
        update_delays(deltaTime)
        timings.update_delays_time = time.tick_since(timings.start_time)

        timings.start_time = time.tick_now()
        if(rl.IsMusicStreamPlaying(game.music)) {
            rl.UpdateMusicStream(game.music)
        }
        timings.update_music_time = time.tick_since(timings.start_time)

        // UPDATE GAME

        current_state := game.states[game.state_count-1] if game.state_count > 0 else nil
        if current_state == nil do break
    
        timings.start_time = time.tick_now()
        if current_state.update != nil {
            if !current_state->update(game, deltaTime, runTime) do break
        }
        timings.update_game_time = time.tick_since(timings.start_time)
    
        // BEGIN DRAWING
        timings.render_start_time = time.tick_now()
        {
            rl.BeginTextureMode(renderTexture)
            defer rl.EndTextureMode()

            rl.ClearBackground(game.clear_color)

            timings.start_time = time.tick_now()
            if current_state.render != nil {
                current_state->render(game)
            }
            timings.game_render_time = time.tick_since(timings.start_time)
        }        
        
        timings.start_time = time.tick_now()
        {
            rl.BeginDrawing()
            defer rl.EndDrawing()

            {
                if(game.use_post_processing_shader) {
                    rl.BeginShaderMode(game.post_processing_shader)
                }
                defer if(game.use_post_processing_shader) {
                    rl.EndShaderMode()
                }
                rl.DrawTexturePro(renderTexture.texture, renderTextureSrc, renderTextureDest, V2ZERO, 0, rl.WHITE)
            }

            averaged_timings:Timings
            for pt in prev_timings {
                averaged_timings.allocator_free_time += pt.allocator_free_time
                averaged_timings.game_render_time    += pt.game_render_time
                averaged_timings.render_time         += pt.render_time
                averaged_timings.total_drawing_time  += pt.total_drawing_time
                averaged_timings.update_data_time    += pt.update_data_time
                averaged_timings.update_delays_time  += pt.update_delays_time
                averaged_timings.update_game_time    += pt.update_game_time
                averaged_timings.update_music_time   += pt.update_music_time
            }
            
            averaged_timings.allocator_free_time /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.game_render_time    /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.render_time         /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.total_drawing_time  /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.update_data_time    /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.update_delays_time  /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.update_game_time    /= TIMING_FRAMES_TO_AVERAGE
            averaged_timings.update_music_time   /= TIMING_FRAMES_TO_AVERAGE

            if should_draw_frame_info {
                draw_frame_info(averaged_timings)
            }

            if time.duration_seconds(time.tick_diff(last_timing_log, time.tick_now())) > SECONDS_BETWEEN_TIMING_LOGS {
                log_timings(averaged_timings)
                last_timing_log = time.tick_now()
            }
        }

        timings.render_time = time.tick_since(timings.start_time)
        timings.total_drawing_time = time.tick_since(timings.render_start_time)
        timings.start_time = time.tick_now()

        // CHECK FOR BAD FREES
        if len(tracking_allocator.bad_free_array) > 0 {
            for bad_free in tracking_allocator.bad_free_array {
                log.error("[DUSK]", "Bad free at:", bad_free.location)
            }
            log.panic("[DUSK]", "Detected", len(tracking_allocator.bad_free_array), "bad frees!!")
        }

        // FREE OUR TEMP ALLOCATOR AT THE END OF THE FRAME
        free_all(context.temp_allocator)
        timings.allocator_free_time = time.tick_since(timings.start_time)

        prev_timings[prev_timing_index] = timings
        prev_timing_index += 1
        if(prev_timing_index >= TIMING_FRAMES_TO_AVERAGE) {
            prev_timing_index = 0
        }
    }

    // LOG MEMORY LEAKS
    for _, value in tracking_allocator.allocation_map {
        log.warn("[DUSK]", value.location, ": Leaked", value.size, "bytes!")
    }

}

@private should_draw_frame_info:bool

toggle_draw_frame_info :: proc() {
    should_draw_frame_info = !should_draw_frame_info
}

@private draw_frame_info :: proc(timings:Timings) {
    FONT_SIZE :: 16
    SPACING :: FONT_SIZE+2
    X :: 10
    COLOR :: rl.GREEN

    y : i32 = 10
    builder:strings.Builder

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "FPS:", rl.GetFPS())
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Delays:", timings.update_delays_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Music:", timings.update_music_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Game Update:", timings.update_game_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Rendering:", timings.game_render_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Present Time:", timings.render_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING

    strings.builder_init(&builder, allocator = context.temp_allocator)
    fmt.sbprint(&builder, "Temp Allocator Free Time:", timings.allocator_free_time)
    rl.DrawText(strings.to_cstring(&builder), X, y, FONT_SIZE, COLOR)
    y+=SPACING
}

@private
Timings :: struct {
    start_time:time.Tick,
    render_start_time:time.Tick,
    update_data_time:time.Duration,
    update_delays_time:time.Duration,
    update_music_time:time.Duration,
    update_game_time:time.Duration,
    game_render_time:time.Duration,
    render_time:time.Duration,
    total_drawing_time:time.Duration,
    allocator_free_time:time.Duration,
}

@private
log_timings :: proc(timings:Timings) {
    log.debug("[DUSK]", "Averaged Timings for the last", TIMING_FRAMES_TO_AVERAGE, "frames.")
    log.debug("[DUSK]", "Delays:",                   timings.update_delays_time)
    log.debug("[DUSK]", "Music:",                    timings.update_music_time)
    log.debug("[DUSK]", "Game:",                     timings.update_game_time)
    log.debug("[DUSK]", "Render Game:",              timings.game_render_time)
    log.debug("[DUSK]", "Present:",                  timings.render_time)
    log.debug("[DUSK]", "Temp Allocator Free Time:", timings.allocator_free_time)
}
