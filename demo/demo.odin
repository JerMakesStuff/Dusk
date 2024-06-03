/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package demo

import "core:log"
import "core:math"
import "core:strings"
import "vendor:raylib"

import dusk  ".."
import delay "../delay"
import ecs   "../ecs"

main :: proc() {
    demoGame : Demo
    demoGame.start = demoStart
    demoGame.update = demoUpdate
    demoGame.shutdown = demoShutdown
    demoGame.name = "DemoGame"
    dusk.run(&demoGame)
}

Demo :: struct {
    using game:dusk.Game,

    // State
    musicVolume:f32,
    textDropShadowColor:Color,

    // Assets
    testImage:Texture2D,
    testSound:Sound,

    // ECS
    world:ecs.World,
    logoEnt:ecs.Entity,
    howdyEnt:ecs.Entity,
    instructionsEnt:ecs.Entity,
    volumeTextEnt:ecs.Entity,
}

demoStart :: proc(game:^dusk.Game) -> bool {
    using self:^Demo = transmute(^Demo)game

    log.info("[DEMO]","Howdy! o/")

    // LOAD AND PLAY SOME SOUNDS
    testSound = Sound{ sound = raylib.LoadSound("sfx/test.wav") }
    raylib.SetSoundVolume(testSound, 0.5)

    delay.start(proc(sound:any) {
        if sound.id == typeid_of(raylib.Sound) {
            raylib.PlaySound((transmute(^raylib.Sound)sound.data)^)
        }
    }, 2, testSound)

    delay.start(proc(sound:any) {
        if sound.id == typeid_of(raylib.Sound) {
            raylib.PlaySound((transmute(^raylib.Sound)sound.data)^)
        }
    }, 3, testSound)

    music = raylib.LoadMusicStream("music/test.mp3")

    delay.start(proc(music:any){
        if music.id == typeid_of(raylib.Music) {
            raylib.PlayMusicStream((transmute(^raylib.Music)music.data)^)
        }
    }, 5, music)

    musicVolume = 0.75
    raylib.SetMusicVolume(music, musicVolume)

    // Load a test image
    testImage = Texture2D{ texture = raylib.LoadTexture("art/test.png") }
    backgroundColor = raylib.WHITE
    textDropShadowColor = Color{r = 0, g = 0, b = 0, a = 128}

    // Create some entities
    logoEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, logoEnt, Position{x = 0, y = 0})
    ecs.addComponent(&world, logoEnt, Sprite{ 
        texture  = testImage, 
        source   = {x = 0, y = 0, width = f32(testImage.width), height = f32(testImage.height)},
        scale    = {x = 8, y = 8},
        origin   = {x = 0, y = 0},
        rotation = 0,
        color    = Color{r = 255, g = 255, b = 255, a = 255},
    })
    ecs.addComponent(&world, logoEnt, Renderable(true))
    ecs.addComponent(&world, logoEnt, Wiggler{
        origin = Vec2{ 
            x = screenSize.x/2 - f32(testImage.width * 8)/2, 
            y = screenSize.y/2 - f32(testImage.height * 8)/2 - 140,
        },
        max = Vec2{x = 16, y = 16},
        timeScale = Vec2{x = 1.6, y = 1},
    })

    howdyEnt = ecs.createEntity(&world)
    howdyWidth := f32(raylib.MeasureText("Howdy! o/", 60))
    ecs.addComponent(&world, howdyEnt, Position{
        x = screenSize.x/2 - howdyWidth/2, 
        y = screenSize.y - 240,
    })
    ecs.addComponent(&world, howdyEnt, Label{
        text = "Howdy o/",
        fontSize = 60,
        color = Color{r = 255, g = 255, b = 255, a = 255},
        dropShadow = true,
        dropShadowColor = textDropShadowColor,
    })
    ecs.addComponent(&world, howdyEnt, Renderable(true))

    instructionsEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, instructionsEnt, Position{x = 20, y = screenSize.y - 24})
    ecs.addComponent(&world, instructionsEnt, Label{
        text = "use the [-] and [=] keys to change the music volume",
        fontSize = 20,
        color = Color{r = 255, g = 255, b = 255, a = 255},
        dropShadow = true,
        dropShadowColor = textDropShadowColor,
    })
    ecs.addComponent(&world, instructionsEnt, Renderable(true))

    volumeTextEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, volumeTextEnt, Position{x = 20, y = screenSize.y - 55})
    ecs.addComponent(&world, volumeTextEnt, Label{
        text = "MUSIC VOLUME: 75",
        fontSize = 28,
        color = Color{r = 255, g = 255, b = 255, a = 255},
        dropShadow = true,
        dropShadowColor = textDropShadowColor,
    })
    ecs.addComponent(&world, volumeTextEnt, Renderable(true))
    ecs.addComponent(&world, volumeTextEnt, LabelUpdater{update = updateVolumeText})

    return true
}

demoUpdate :: proc(game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    using self:^Demo = transmute(^Demo)game

    // Volume Controls
    if(raylib.IsKeyPressed(.MINUS)) {
        musicVolume -= 0.01
        musicVolume = math.min(math.max(musicVolume,0),1)
        raylib.SetMusicVolume(music, musicVolume)
    }
    
    if(raylib.IsKeyPressedRepeat(.MINUS)) {
        musicVolume -= 0.005
        musicVolume = math.min(math.max(musicVolume,0),1)
        raylib.SetMusicVolume(music, musicVolume)
    }

    if(raylib.IsKeyPressed(.EQUAL)) {
        musicVolume += 0.01
        musicVolume = math.min(math.max(musicVolume,0),1)
        raylib.SetMusicVolume(music, musicVolume)
    }

    if(raylib.IsKeyPressedRepeat(.EQUAL)) {
        musicVolume += 0.005
        musicVolume = math.min(math.max(musicVolume,0),1)
        raylib.SetMusicVolume(music, musicVolume)
    }

    // Update Background Color
    backgroundColor.r = u8(255 * ((math.sin(runTime/5)+1)/2))
    backgroundColor.g = u8(255 * ((math.sin(runTime/6)+1)/2))
    backgroundColor.b = u8(255 * ((math.sin(runTime/10)+1)/2))
    
    // Update Wigglers
    wigglers := ecs.queryComponents(&world, Position, Wiggler)
    for ent in wigglers {
        wiggler := ecs.getComponent(&world, ent, Wiggler)
        position := ecs.getComponent(&world, ent, Position)        
        position.x = wiggler.origin.x + math.sin(runTime * wiggler.timeScale.x) * wiggler.max.x
        position.y = wiggler.origin.y + math.sin(runTime * wiggler.timeScale.y) * wiggler.max.y
    }

    // Update Labels
    labelUpdaters := ecs.queryComponents(&world, Position, Label, LabelUpdater)
    for ent in labelUpdaters {
        updater := ecs.getComponent(&world,ent,LabelUpdater)
        updater.update(ent, self)
    }

    // Render Sprites
    spriteRenderers := ecs.queryComponents(&world, Position, Sprite, Renderable)
    for ent in spriteRenderers {     
        renderable := ecs.getComponent(&world, ent, Renderable)
        if(renderable^) {
            sprite := ecs.getComponent(&world, ent, Sprite)
            position := ecs.getComponent(&world, ent, Position)
            dstWidth := f32(sprite.texture.width) * sprite.scale.x
            dstHeight := f32(sprite.texture.height) * sprite.scale.y
            
            raylib.DrawTexturePro(
                sprite.texture,
                sprite.source,
                {x = position.x, y = position.y, width = dstWidth, height = dstHeight},
                sprite.origin,  sprite.rotation, sprite.color)
        }
    }

    // Render Labels
    labelRenderers := ecs.queryComponents(&world, Position, Label, Renderable)
    for ent in labelRenderers {
        renderable := ecs.getComponent(&world, ent, Renderable)
        if(renderable^) {
            label := ecs.getComponent(&world, ent, Label)
            position := ecs.getComponent(&world, ent, Position)

            // only do this allocation once
            text := strings.clone_to_cstring(label.text, context.temp_allocator)
            if(label.dropShadow) {
                raylib.DrawText(text, i32(position.x)+2, i32(position.y)+2, label.fontSize, label.dropShadowColor)
            }
            raylib.DrawText(text, i32(position.x), i32(position.y), label.fontSize, label.color)

        }
    }
        
    return true
}

demoShutdown :: proc(game:^dusk.Game) {
    using self:^Demo = transmute(^Demo)game
}

updateVolumeText :: proc(ent:ecs.Entity, game:^Demo) {
    using self := game
    label := ecs.getComponent(&world, ent, Label)    
    builder : strings.Builder
    strings.builder_init_none(&builder)
    strings.write_string(&builder, "MUSIC VOLUME: ")
    strings.write_int(&builder, int(musicVolume*100))
    label.text = strings.to_string(builder)
}

// Defining the components

Vec2 :: struct {
    using vec:raylib.Vector2,
}

Rect :: struct {
    using rect:raylib.Rectangle,
}

Position :: struct {
    using pos:Vec2,
}

Color :: struct {
    using color:raylib.Color,
}

Texture2D :: struct {
    using texture:raylib.Texture2D,
}

Sound :: struct {
    using sound:raylib.Sound,
}
 
Label :: struct {
    text:string,
    fontSize:i32,
    color:Color,
    dropShadow:bool,
    dropShadowColor:Color,
}

Sprite :: struct {
    texture:Texture2D,
    source:Rect,
    scale:Vec2,
    origin:Vec2,
    rotation:f32,
    color:Color,
}

Renderable :: distinct bool

Wiggler :: struct {
    origin:Vec2,
    max:Vec2,
    timeScale:Vec2,
}

LabelUpdater :: struct {
    update:proc(ent:ecs.Entity, game:^Demo),
}