/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package demo

import "core:log"
import "core:math"
import "core:strings"

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
    textDropShadowColor:dusk.Color,

    // Assets
    testImage:dusk.Texture2D,
    testSound:dusk.Sound,

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
    testSound = dusk.LoadSound("sfx/test.wav")
    dusk.SetSoundVolume(testSound, 0.5)

    delay.start(proc(sound:any) {
            dusk.PlaySound((transmute(^dusk.Sound)sound.data)^)
    }, 2, testSound)

    delay.start(proc(sound:any) {
        dusk.PlaySound((transmute(^dusk.Sound)sound.data)^)
    }, 3, testSound)

    music = dusk.LoadMusicStream("music/test.mp3")

    delay.start(proc(music:any){
            dusk.PlayMusicStream((transmute(^dusk.Music)music.data)^)
    }, 5, music)

    i:int = 1
    delay.start(proc(val:any){
        log.info(val)
    }, 0.5, i)

    musicVolume = 0.75
    dusk.SetMusicVolume(music, musicVolume)

    // Load a test image
    testImage = dusk.LoadTexture("art/test.png")
    backgroundColor = dusk.Color{255, 255, 255, 255}
    textDropShadowColor = dusk.Color{0, 0, 0, 128}

    // Create some entities
    logoEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, logoEnt, Position{x = 0, y = 0})
    ecs.addComponent(&world, logoEnt, Sprite{ 
        texture  = testImage, 
        source   = {0, 0, f32(testImage.width), f32(testImage.height)},
        scale    = {8, 8},
        origin   = {0, 0},
        rotation = 0,
        color    = dusk.Color{255, 255, 255, 255},
    })
    ecs.addComponent(&world, logoEnt, Renderable(true))
    ecs.addComponent(&world, logoEnt, Wiggler{
        origin = dusk.Vector2{ 
            screenSize.x/2 - f32(testImage.width * 8)/2, 
            screenSize.y/2 - f32(testImage.height * 8)/2 - 140,
        },
        max = dusk.Vector2{16, 16},
        timeScale = dusk.Vector2{1.6, 1},
    })

    howdyEnt = ecs.createEntity(&world)
    howdyWidth := f32(dusk.MeasureText("Howdy! o/", 60))
    ecs.addComponent(&world, howdyEnt, Position{
        x = screenSize.x/2 - howdyWidth/2, 
        y = screenSize.y - 240,
    })
    ecs.addComponent(&world, howdyEnt, Label{
        text = "Howdy o/",
        fontSize = 60,
        color = dusk.Color{255, 255, 255, 255},
        dropShadow = true,
        dropShadowColor = textDropShadowColor,
    })
    ecs.addComponent(&world, howdyEnt, Renderable(true))

    instructionsEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, instructionsEnt, Position{x = 20, y = screenSize.y - 24})
    ecs.addComponent(&world, instructionsEnt, Label{
        text = "use the [-] and [=] keys to change the music volume",
        fontSize = 20,
        color = dusk.Color{255, 255, 255, 255},
        dropShadow = true,
        dropShadowColor = textDropShadowColor,
    })
    ecs.addComponent(&world, instructionsEnt, Renderable(true))

    volumeTextEnt = ecs.createEntity(&world)
    ecs.addComponent(&world, volumeTextEnt, Position{x = 20, y = screenSize.y - 55})
    ecs.addComponent(&world, volumeTextEnt, Label{
        text = "MUSIC VOLUME: 75",
        fontSize = 28,
        color = dusk.Color{255, 255, 255, 255},
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
    if(dusk.IsKeyPressed(.MINUS)) {
        musicVolume -= 0.01
        musicVolume = math.min(math.max(musicVolume,0),1)
        dusk.SetMusicVolume(music, musicVolume)
    }
    
    if(dusk.IsKeyPressedRepeat(.MINUS)) {
        musicVolume -= 0.005
        musicVolume = math.min(math.max(musicVolume,0),1)
        dusk.SetMusicVolume(music, musicVolume)
    }

    if(dusk.IsKeyPressed(.EQUAL)) {
        musicVolume += 0.01
        musicVolume = math.min(math.max(musicVolume,0),1)
        dusk.SetMusicVolume(music, musicVolume)
    }

    if(dusk.IsKeyPressedRepeat(.EQUAL)) {
        musicVolume += 0.005
        musicVolume = math.min(math.max(musicVolume,0),1)
        dusk.SetMusicVolume(music, musicVolume)
    }

    // Update Background Color
    backgroundColor.r = u8(255 * ((math.sin(runTime/5)+1)/2))
    backgroundColor.g = u8(255 * ((math.sin(runTime/6)+1)/2))
    backgroundColor.b = u8(255 * ((math.sin(runTime/10)+1)/2))
    
    // Update Wigglers
    wigglers := ecs.query(&world, Position, Wiggler)
    for ent in wigglers {
        position := ent.value1  
        wiggler := ent.value2
        position.x = wiggler.origin.x + math.sin(runTime * wiggler.timeScale.x) * wiggler.max.x
        position.y = wiggler.origin.y + math.sin(runTime * wiggler.timeScale.y) * wiggler.max.y
    }

    // Update Labels
    labelUpdaters := ecs.query(&world, Position, Label, LabelUpdater)
    for ent in labelUpdaters {
        position := ent.value1
        label := ent.value2
        updater := ent.value3
        updater.update(label, position, self)
    }

    // Render Sprites
    spriteRenderers := ecs.query(&world, Position, Sprite, Renderable)
    for ent in spriteRenderers {     
        position := ent.value1
        sprite := ent.value2
        renderable := ent.value3
        if(renderable^) {
            dstWidth := f32(sprite.texture.width) * sprite.scale.x
            dstHeight := f32(sprite.texture.height) * sprite.scale.y
            dusk.DrawTexturePro(
                sprite.texture,
                sprite.source,
                {x = position.x, y = position.y, width = dstWidth, height = dstHeight},
                sprite.origin,  sprite.rotation, sprite.color)
        }
    }

    // Render Labels
    @(static) first:bool = true
    labelRenderers := ecs.query(&world, Position, Label, Renderable)
    for ent in labelRenderers {
        position := ent.value1
        label := ent.value2
        renderable := ent.value3
        
        if first {
            log.info(position)
            log.warn(label)
        }
        if(renderable^) {
            // only do this allocation once
            text := strings.clone_to_cstring(label.text, context.temp_allocator)
            if(label.dropShadow) {
                dusk.DrawText(text, i32(position.x)+2, i32(position.y)+2, label.fontSize, label.dropShadowColor)
            }
            dusk.DrawText(text, i32(position.x), i32(position.y), label.fontSize, label.color)
        }
    }
    first = false
        
    return true
}

demoShutdown :: proc(game:^dusk.Game) {
    using self:^Demo = transmute(^Demo)game
}

updateVolumeText :: proc(label:^Label, position:^Position, game:^Demo) {
    using self := game
    builder : strings.Builder
    strings.builder_init_none(&builder)
    strings.write_string(&builder, "MUSIC VOLUME: ")
    strings.write_int(&builder, int(musicVolume*100))
    label.text = strings.to_string(builder)
}

// Defining the components

Position :: struct {
    using pos:dusk.Vector2,
}
 
Label :: struct {
    text:string,
    fontSize:i32,
    color:dusk.Color,
    dropShadow:bool,
    dropShadowColor:dusk.Color,
}

Sprite :: struct {
    texture:dusk.Texture2D,
    source:dusk.Rectangle,
    scale:dusk.Vector2,
    origin:dusk.Vector2,
    rotation:f32,
    color:dusk.Color,
}

Renderable :: distinct bool

Wiggler :: struct {
    origin:dusk.Vector2,
    max:dusk.Vector2,
    timeScale:dusk.Vector2,
}

LabelUpdater :: struct {
    update:proc(label:^Label, position:^Position, game:^Demo),
}