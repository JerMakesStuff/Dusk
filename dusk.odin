/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "base:builtin"
import "core:strings"
import rl "vendor:raylib"
import "core:log"
import "core:time"

run :: proc(game:^Game) {

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
    
    rl.InitWindow(game.settings.resolution.x, game.settings.resolution.y, strings.clone_to_cstring(game.name))
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

    start_time:time.Tick
    render_start_time:time.Tick
    update_data_time:time.Duration
    update_delays_time:time.Duration
    update_music_time:time.Duration
    update_game_time:time.Duration
    game_render_time:time.Duration
    render_time:time.Duration
    total_drawing_time:time.Duration
    allocator_free_time:time.Duration

    screenWidth := f32(rl.GetScreenWidth())
    screenHeight := f32(rl.GetScreenHeight())

    // GAME LOOP
    for !rl.WindowShouldClose() {
        start_time = time.tick_now()
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

        update_data_time = time.tick_since(start_time)

        start_time = time.tick_now()
        update_delays(deltaTime)
        update_delays_time = time.tick_since(start_time)

        start_time = time.tick_now()
        if(rl.IsMusicStreamPlaying(game.music)) {
            rl.UpdateMusicStream(game.music)
        }
        update_music_time = time.tick_since(start_time)

        // UPDATE GAME

        current_state := game.states[game.state_count-1] if game.state_count > 0 else nil
        if current_state == nil do break
    
        start_time = time.tick_now()
        if current_state.update != nil {
            if !current_state->update(game, deltaTime, runTime) do break
        }
        update_game_time = time.tick_since(start_time)
    
        // BEGIN DRAWING
        render_start_time = time.tick_now()
        {
            rl.BeginTextureMode(renderTexture)
            defer rl.EndTextureMode()

            rl.ClearBackground(game.clear_color)

            start_time = time.tick_now()
            if current_state.render != nil {
                current_state->render(game)
            }
            game_render_time = time.tick_since(start_time)
        }        
        
        start_time = time.tick_now()
        {
            rl.BeginDrawing()
            defer rl.EndDrawing()

            if(game.use_post_processing_shader) {
                rl.BeginShaderMode(game.post_processing_shader)
            }
            defer if(game.use_post_processing_shader) {
                rl.EndShaderMode()
            }
            
            rl.DrawTexturePro(renderTexture.texture, renderTextureSrc, renderTextureDest, V2ZERO, 0, rl.WHITE)
        }

        render_time = time.tick_since(start_time)
        total_drawing_time = time.tick_since(render_start_time)
        start_time = time.tick_now()

        // FREE OUR TEMP ALLOCATOR AT THE END OF THE FRAME
        free_all(context.temp_allocator)
        allocator_free_time = time.tick_since(start_time)
    }

    log.info("[DUSK]", "Update Data Time:", update_data_time)
    log.info("[DUSK]", "Update Delays:", update_delays_time)
    log.info("[DUSK]", "Update Music:", update_music_time)
    log.info("[DUSK]", "Update Game:", update_game_time)
    log.info("[DUSK]", "Render Game Time:", game_render_time)
    log.info("[DUSK]", "Present Time:", render_time)
    log.info("[DUSK]", "Total Drawing Time:", total_drawing_time)
    log.info("[DUSK]", "Temp Allocator Free Time:", allocator_free_time)
}

V2ZERO :: rl.Vector2{0,0}