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

        // UPDATE GAME
        if game.update != nil {
            if !game->update(deltaTime, runTime) do break
        }

        if game.lateUpdate != nil {
            game->lateUpdate(deltaTime, runTime)
        }

        // BEGIN DRAWING
        raylib.BeginDrawing()
        //raylib.BeginTextureMode(renderTexture)
        raylib.ClearBackground(game.backgroundColor)
        
        if game.render != nil {
            game->render()
        }

        //raylib.EndTextureMode()

        if game.postRender != nil {
            game->postRender()
        }

        raylib.EndDrawing()

        // FREE OUR TEMP ALLOCATOR AT THE END OF THE FRAME
        free_all(context.temp_allocator)
    }

}


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
