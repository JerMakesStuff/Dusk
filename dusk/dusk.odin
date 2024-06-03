/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "base:builtin"
import "core:strings"
import "vendor:raylib"

import "delay"
import "logger"

run :: proc(game:^Game) {
    context.logger = logger.create()

    // INIT RAYLIB WINDOW
    raylib.SetConfigFlags({.VSYNC_HINT})
    raylib.InitWindow(1280, 720, strings.clone_to_cstring(game.name))
    game.screenSize.x = f32(raylib.GetScreenWidth())
    game.screenSize.y = f32(raylib.GetScreenHeight())
    defer raylib.CloseWindow()

    // INIT RAYLIB AUDIO
    raylib.InitAudioDevice()
    defer raylib.CloseAudioDevice()
    
    // START GAME
    if !game->start() do return
    defer game->shutdown()

    // GAME LOOP
    for !raylib.WindowShouldClose() {
        deltaTime := raylib.GetFrameTime()
        runTime := f32(raylib.GetTime())

        game.screenSize.x = f32(raylib.GetScreenWidth())
        game.screenSize.y = f32(raylib.GetScreenHeight())

        delay.update(deltaTime)
        if(raylib.IsMusicStreamPlaying(game.music)) {
            raylib.UpdateMusicStream(game.music)
        }

        // Begin Drawing
        raylib.BeginDrawing()
        raylib.EndDrawing()
        raylib.ClearBackground(game.backgroundColor)
        
        // Update Game
        if !game->update(deltaTime, runTime) do break
    
        // Free our temp allocator at the end of the frame
        free_all(context.temp_allocator)
    }

}