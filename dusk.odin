/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "base:builtin"
import "core:strings"
import "vendor:raylib"
import "core:log"
import "core:time"

import "delay"
import "logger"

run :: proc(game:^Game) {

    context.logger = logger.create()
    context.user_ptr = game

    // INIT RAYLIB WINDOW
    raylib.SetConfigFlags({.VSYNC_HINT})
    raylib.SetConfigFlags({.WINDOW_RESIZABLE})
    raylib.InitWindow(1280, 720, strings.clone_to_cstring(game.name))
    game.screenSize.x = f32(raylib.GetScreenWidth())
    game.screenSize.y = f32(raylib.GetScreenHeight())
    defer raylib.CloseWindow()

    useVirtualResolution := game.virtualResolution.x != 0 && game.virtualResolution.y != 0
    renderTexture:raylib.RenderTexture
    renderTextureSrc:Rectangle
    renderTextureDest:= Rectangle{0,0, game.screenSize.x, game.screenSize.y}
    renderTextureAspect :f32 = 16/9
    if(useVirtualResolution) {
        game.screenSize.x = f32(game.virtualResolution.x)
        game.screenSize.y = f32(game.virtualResolution.y)
        renderTexture = raylib.LoadRenderTexture(game.virtualResolution.x, game.virtualResolution.y)
        renderTextureSrc = Rectangle{0,0,f32(renderTexture.texture.width),f32(-renderTexture.texture.height)}
        renderTextureAspect = renderTextureSrc.width / -renderTextureSrc.height
    }

    // INIT RAYLIB AUDIO
    raylib.InitAudioDevice()
    defer raylib.CloseAudioDevice()
    
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
    for !raylib.WindowShouldClose() {
        startTime = time.tick_now()
        deltaTime := raylib.GetFrameTime()
        runTime := f32(raylib.GetTime())
        game.fps = int(raylib.GetFPS())
        screenWidth := f32(raylib.GetScreenWidth())
        screenHeight := f32(raylib.GetScreenHeight())
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
        if(raylib.IsMusicStreamPlaying(game.music)) {
            raylib.UpdateMusicStream(game.music)
        }
        updateMusicTime = time.tick_since(startTime)

        // UPDATE GAME
        startTime = time.tick_now()
        if game.update != nil {
            if !game->update(deltaTime, runTime) do break
        }
        updateGameTime = time.tick_since(startTime)

        startTime = time.tick_now()
        if game.lateUpdate != nil {
            game->lateUpdate(deltaTime, runTime)
        }
        lateUpdateGameTime = time.tick_since(startTime)

        // BEGIN DRAWINGr
        renderStartTime = time.tick_now()
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)
        if(useVirtualResolution) {
            raylib.BeginTextureMode(renderTexture)
        }
        
        raylib.ClearBackground(game.backgroundColor)
        
        startTime = time.tick_now()
        if game.render != nil {
            game->render()
        }
        gameRenderTime = time.tick_since(startTime)

        if(useVirtualResolution) {
            raylib.EndTextureMode()
        }

        startTime = time.tick_now()
        if game.postRender != nil {
            game->postRender()
        }
        gamePostRenderTime = time.tick_since(startTime)

        if(useVirtualResolution) {
            raylib.DrawTexturePro(renderTexture.texture, renderTextureSrc, renderTextureDest, V2ZERO, 0, raylib.WHITE)
        }

        startTime = time.tick_now()
        raylib.EndDrawing()
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


V2ZERO :: Vector2{0,0}

Sound :: raylib.Sound
Music :: raylib.Music
Texture2D :: raylib.Texture2D
Color :: raylib.Color
Rectangle :: raylib.Rectangle
Vector2 :: raylib.Vector2

LoadSound :: raylib.LoadSound
PlaySound :: raylib.PlaySound
SetSoundVolume :: raylib.SetSoundVolume
LoadMusicStream :: raylib.LoadMusicStream
PlayMusicStream :: raylib.PlayMusicStream
SetMusicVolume :: raylib.SetMusicVolume

LoadTexture :: raylib.LoadTexture
DrawTexturePro :: raylib.DrawTexturePro

MeasureText :: raylib.MeasureText
DrawText :: raylib.DrawText

IsKeyPressed :: raylib.IsKeyPressed
IsKeyPressedRepeat :: raylib.IsKeyPressedRepeat
IsKeyReleased :: raylib.IsKeyReleased
IsKeyDown :: raylib.IsKeyDown
IsKeyUp :: raylib.IsKeyUp
