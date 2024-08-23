/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "base:builtin"
import "core:strings"
import rl "vendor:raylib"
import "core:log"
import "core:time"

import "delay"
import "logger"

run :: proc(game:^Game) {

    context.logger = logger.create()
    context.user_ptr = game

    // INIT RAYLIB WINDOW
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(1280, 720, strings.clone_to_cstring(game.name))
    game.screenSize.x = f32(rl.GetScreenWidth())
    game.screenSize.y = f32(rl.GetScreenHeight())
    defer rl.CloseWindow()

    useVirtualResolution := game.virtualResolution.x != 0 && game.virtualResolution.y != 0
    renderTexture:rl.RenderTexture
    renderTextureSrc:rl.Rectangle
    renderTextureDest:= rl.Rectangle{0,0, game.screenSize.x, game.screenSize.y}
    renderTextureAspect :f32 = 16/9
    if(useVirtualResolution) {
        game.screenSize.x = f32(game.virtualResolution.x)
        game.screenSize.y = f32(game.virtualResolution.y)
        renderTexture = rl.LoadRenderTexture(game.virtualResolution.x, game.virtualResolution.y)
        renderTextureSrc = rl.Rectangle{0,0,f32(renderTexture.texture.width),f32(-renderTexture.texture.height)}
        renderTextureAspect = renderTextureSrc.width / -renderTextureSrc.height
    }

    // INIT RAYLIB AUDIO
    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()
    
    // START GAME
    if !game->start() do return
    defer game->shutdown()

    startTime:time.Tick
    renderStartTime:time.Tick
    updateDataTime:time.Duration
    updateDelaysTime:time.Duration
    updateMusicTime:time.Duration
    updateGameTime:time.Duration
    lateUpdateGameTime:time.Duration
    gameRenderTime:time.Duration
    gamePostRenderTime:time.Duration
    renderTime:time.Duration
    totalDrawingTime:time.Duration
    allocatorFreeTime:time.Duration

    // GAME LOOP
    for !rl.WindowShouldClose() {
        startTime = time.tick_now()
        deltaTime := rl.GetFrameTime()
        runTime := f32(rl.GetTime())
        game.fps = int(rl.GetFPS())
        screenWidth := f32(rl.GetScreenWidth())
        screenHeight := f32(rl.GetScreenHeight())
        if !useVirtualResolution {
            game.screenSize.x = screenWidth
            game.screenSize.y = screenHeight
        } else {
            renderTextureDest.height = screenHeight
            renderTextureDest.width = screenHeight*renderTextureAspect
            renderTextureDest.x = screenWidth / 2 - renderTextureDest.width / 2
        }
        updateDataTime = time.tick_since(startTime)

        startTime = time.tick_now()
        delay.update(deltaTime)
        updateDelaysTime = time.tick_since(startTime)

        startTime = time.tick_now()
        if(rl.IsMusicStreamPlaying(game.music)) {
            rl.UpdateMusicStream(game.music)
        }
        updateMusicTime = time.tick_since(startTime)

        // UPDATE GAME

        currentState := game.states[game.stateCount-1] if game.stateCount > 0 else nil
        if currentState == nil do break
    
        startTime = time.tick_now()
        if currentState.update != nil {
            if !currentState->update(game, deltaTime, runTime) do break
        }
        updateGameTime = time.tick_since(startTime)

        startTime = time.tick_now()
        if currentState.lateUpdate != nil {
            currentState->lateUpdate(game, deltaTime, runTime)
        }
        lateUpdateGameTime = time.tick_since(startTime)
    
        // BEGIN DRAWING
        renderStartTime = time.tick_now()
        rl.BeginDrawing()
        if(useVirtualResolution) {
            rl.BeginTextureMode(renderTexture)
        }
        
        rl.ClearBackground(game.backgroundColor)
        
        startTime = time.tick_now()
       
        if currentState.render != nil {
            currentState->render(game)
        }
        gameRenderTime = time.tick_since(startTime)

        if(useVirtualResolution) {
            rl.EndTextureMode()
        }

        startTime = time.tick_now()
        if currentState.postRender != nil {
            currentState->postRender(game)
        }
        gamePostRenderTime = time.tick_since(startTime)

        if(useVirtualResolution) {
            V2ZERO :: rl.Vector2{0,0}
            rl.DrawTexturePro(renderTexture.texture, renderTextureSrc, renderTextureDest, V2ZERO, 0, rl.WHITE)
        }

        startTime = time.tick_now()
        rl.EndDrawing()
        renderTime = time.tick_since(startTime)
        totalDrawingTime = time.tick_since(renderStartTime)

        startTime = time.tick_now()
        // FREE OUR TEMP ALLOCATOR AT THE END OF THE FRAME
        free_all(context.temp_allocator)
        allocatorFreeTime = time.tick_since(startTime)
    }

    log.info("[DUSK]", "Update Data Time:", updateDataTime)
    log.info("[DUSK]", "Update Delays:", updateDelaysTime)
    log.info("[DUSK]", "Update Music:", updateMusicTime)
    log.info("[DUSK]", "Update Game:", updateGameTime)
    log.info("[DUSK]", "Late Update Game:", lateUpdateGameTime)
    log.info("[DUSK]", "Render Game Time:", gameRenderTime)
    log.info("[DUSK]", "Post Render Game Time:", gamePostRenderTime)
    log.info("[DUSK]", "Present Time:", renderTime)
    log.info("[DUSK]", "Total Drawing Time:", totalDrawingTime)
    log.info("[DUSK]", "Temp Allocator Free Time:", allocatorFreeTime)
}
