/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package demo

import "core:log"
import "core:math"
import "core:math/rand"
import "core:strings"
import "core:slice"

import dusk ".."
import delay "../delay"
import ecs "../ecs"

main :: proc() {
	demoGame: Demo
	demoGame.start = demoStart
	demoGame.update = demoUpdate
	demoGame.shutdown = demoShutdown
	demoGame.name = "DemoGame"
	dusk.run(&demoGame)
}

WHITE :: dusk.Color{255, 255, 255, 255}
DROP_SHADOW_COLOR :: dusk.Color{0, 0, 0, 128}

Demo :: struct {
	using game:      dusk.Game,

	// State
	musicVolume:     f32,
	soundVolume:     f32,

	// Assets
	testImage:       dusk.Texture2D,
	testSound:       dusk.Sound,

	// ECS
	world:           ecs.World,
	logoEnt:         ecs.Entity,
	howdyEnt:        ecs.Entity,
	instructionsEnt: ecs.Entity,
	volumeTextEnt:   ecs.Entity,
}

demoStart :: proc(game: ^dusk.Game) -> bool {
	using self: ^Demo = transmute(^Demo)game

	log.info("[DEMO]", "Howdy! o/")

	// LOAD Assets
	testSound = dusk.LoadSound("sfx/test.wav")
	music = dusk.LoadMusicStream("music/test.mp3")
	testImage = dusk.LoadTexture("art/test.png")

	musicVolume = 0.75
	soundVolume = 0.5
	dusk.SetMusicVolume(music, musicVolume)
	dusk.SetSoundVolume(testSound, soundVolume)

	delay.start(proc(sound: rawptr) {
			dusk.PlaySound((transmute(^dusk.Sound)sound)^)
		}, 2, &testSound)

	delay.start(proc(sound: rawptr) {
			dusk.PlaySound((transmute(^dusk.Sound)sound)^)
		}, 3, &testSound)

	delay.start(proc(music: rawptr) {
			dusk.PlayMusicStream((transmute(^dusk.Music)music)^)
		}, 5, &music)

	delayTestMessage: string = "This is a test!"
	delay.start(proc(message: string) {
			log.info(message)
		}, 0.5, delayTestMessage)

	backgroundColor = WHITE

    // spawn a bunch of stuff every few seconds
    delay.start(spawnBouncers, 1, self)

    
	// Create some entities
    logoStartPos := Position {  x = screenSize.x / 2 - f32(testImage.width * 8) / 2, y = screenSize.y / 2 - f32(testImage.height * 8) / 2 - 140 }
	logoEnt = createSprite(&world, testImage, 8, logoStartPos)
    logoWiggler := Wiggler { origin = logoStartPos, max = dusk.Vector2{16, 16}, timeScale = dusk.Vector2{1.6, 1}}
	ecs.addComponent(&world, logoEnt, logoWiggler)

	howdyWidth := f32(dusk.MeasureText("Howdy! o/", 60))
    howdyPosition := Position{x = screenSize.x / 2 - howdyWidth / 2, y = screenSize.y - 240}
	howdyEnt = createLabel(&world, "Howdy! o/", 60, WHITE, howdyPosition, true)

    instructionsPosition := Position{x = 20, y = screenSize.y - 24}
	instructionsEnt = createLabel(&world, "use the [-] and [=] keys to change the music volume", 20, WHITE, instructionsPosition, true)

    volumePosition := Position{x = 20, y = screenSize.y - 55}
	volumeTextEnt = createLabel(&world, "MUSIC VOLUME: 75", 28, WHITE, volumePosition, true)
	ecs.addComponent(&world, volumeTextEnt, LabelUpdater{update = updateVolumeText})

    
    fpsPos := Position{x = 20, y = 20}
	fpsEnt := createLabel(&world, "FPS:", 28, dusk.Color{64,255,128,255}, fpsPos, true)
	ecs.addComponent(&world, fpsEnt, LabelUpdater{update = updateFpsText})

	return true
}

demoUpdate :: proc(game: ^dusk.Game, deltTime: f32, runTime: f32) -> bool {
	using self: ^Demo = transmute(^Demo)game

	// Volume Controls
	if (dusk.IsKeyPressed(.MINUS)) {
		musicVolume -= 0.01
		musicVolume = math.min(math.max(musicVolume, 0), 1)
		dusk.SetMusicVolume(music, musicVolume)
	}

	if (dusk.IsKeyPressedRepeat(.MINUS)) {
		musicVolume -= 0.005
		musicVolume = math.min(math.max(musicVolume, 0), 1)
		dusk.SetMusicVolume(music, musicVolume)
	}

	if (dusk.IsKeyPressed(.EQUAL)) {
		musicVolume += 0.01
		musicVolume = math.min(math.max(musicVolume, 0), 1)
		dusk.SetMusicVolume(music, musicVolume)
	}

	if (dusk.IsKeyPressedRepeat(.EQUAL)) {
		musicVolume += 0.005
		musicVolume = math.min(math.max(musicVolume, 0), 1)
		dusk.SetMusicVolume(music, musicVolume)
	}

	// Update Background Color
	backgroundColor.r = u8(255 * ((math.sin(runTime / 5) + 1) / 2))
	backgroundColor.g = u8(255 * ((math.sin(runTime / 6) + 1) / 2))
	backgroundColor.b = u8(255 * ((math.sin(runTime / 10) + 1) / 2))

	updateWigglers(&world, runTime)
    updateBouncers(&world, deltTime)
	updateLabels(&world, self)

	renderSprites(&world)
	renderLabels(&world)

	return true
}

spawnBouncers :: proc(game:rawptr) {
    using self := transmute(^Demo)game

    logoPosition := ecs.getComponent(&world,logoEnt, Position)
    logoSprite := ecs.getComponent(&world,logoEnt, Sprite)

    for _ in 0..< 10 {
        scale := rand.float32_range(0.5, 1.5)
        
        screenBounds := Bounds {x = 0, y = 0, width = screenSize.x - f32(testImage.width) * scale, height = screenSize.y - f32(testImage.height) * scale}
        bouncerStartPos := Position { x = logoPosition.x + (logoSprite.source.width * logoSprite.scale.x) / 2, y = logoPosition.y + (logoSprite.source.height * logoSprite.scale.y) / 2}
        bouncerVelocity := Velocity { x = rand.float32_range(-200, 200), y = rand.float32_range(-200, 200)}
        
        bouncerColor := dusk.Color{ u8(rand.int31() % 256), u8(rand.int31() % 256), u8(rand.int31() % 256), 255}

        bouncerEnt := createSprite(&world, testImage, scale, bouncerStartPos, bouncerColor)
        addBouncerToEntity(&world, bouncerEnt, bouncerVelocity, screenBounds)
    }

    // and again....
    delay.start(spawnBouncers, 1, self)
}

updateWigglers :: proc(world: ^ecs.World, runTime: f32) {
	wigglers := ecs.query(world, Position, Wiggler)
	for ent in wigglers {
		position := ent.value1
		wiggler := ent.value2
		position.x = wiggler.origin.x + math.sin(runTime * wiggler.timeScale.x) * wiggler.max.x
		position.y = wiggler.origin.y + math.sin(runTime * wiggler.timeScale.y) * wiggler.max.y
	}
}

updateBouncers :: proc(world: ^ecs.World, deltaTime: f32) {
    bouncers := ecs.query(world, Position, Velocity, Bounds, Bouncer)
    for entity in bouncers {
        position := entity.value1
        velocity := entity.value2
        bounds := entity.value3

        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime

        if(position.x <= bounds.x) {
            position.x = bounds.x
            velocity.x *= -1
        } else if ( position.x >= bounds.x + bounds.width) {
            position.x = bounds.x + bounds.width
            velocity.x *= -1
        }

        if(position.y <= bounds.y) {
            position.y = bounds.y
            velocity.y *= -1
        } else if ( position.y >= bounds.y + bounds.height) {
            position.y = bounds.y + bounds.height
            velocity.y *= -1
        }
    }
}

createLabel :: proc(world: ^ecs.World, text: string, fontSize: i32, color: dusk.Color, position: Position, dropShadow: bool = false, dropShadowColor: dusk.Color = DROP_SHADOW_COLOR ) -> ecs.Entity {
    label := ecs.createEntity(world)
    ecs.addComponent(world, label, position)
	ecs.addComponent(world, label, Label { text = text, fontSize = fontSize, color = color, dropShadow = dropShadow, dropShadowColor = dropShadowColor})
	ecs.addComponent(world, label, Renderable(true))
    return label
}

updateLabels :: proc(world: ^ecs.World, game: ^Demo) {
	labelUpdaters := ecs.query(world, Position, Label, LabelUpdater)
	for ent in labelUpdaters {
		position := ent.value1
		label := ent.value2
		updater := ent.value3
		updater.update(label, position, game)
	}
}

renderLabels :: proc(world: ^ecs.World) {
	labelRenderers := ecs.query(world, Position, Label, Renderable)
	for ent in labelRenderers {
		position := ent.value1
		label := ent.value2
		renderable := ent.value3
		if (renderable^) {
			// only do this allocation once
			text := strings.clone_to_cstring(label.text, context.temp_allocator)
			if (label.dropShadow) {
				dusk.DrawText(
					text,
					i32(position.x) + 2,
					i32(position.y) + 2,
					label.fontSize,
					label.dropShadowColor,
				)
			}
			dusk.DrawText(text, i32(position.x), i32(position.y), label.fontSize, label.color)
		}
	}
}

createSprite :: proc(world: ^ecs.World, texture: dusk.Texture2D, scale:f32, position:Position, color:dusk.Color = WHITE) -> ecs.Entity {  
	spriteEntity := ecs.createEntity(world)
    ecs.addComponent(world, spriteEntity, position)
	ecs.addComponent(
		world,
		spriteEntity,
		Sprite { texture = texture, source = {0, 0, f32(texture.width), f32(texture.height)},
			scale = {scale, scale}, origin = {0, 0}, rotation = 0, color = color, 
        }
	)
	ecs.addComponent(world, spriteEntity, Renderable(true))
    return spriteEntity
}

addBouncerToEntity :: proc(world:^ecs.World, spriteEntity:ecs.Entity, velocity:Velocity, bounds:Bounds) {
    position : = ecs.getComponent(world, spriteEntity, Position)
    if(position == nil) {
        ecs.addComponent(world, spriteEntity, Position{})
    }
    ecs.addComponent(world, spriteEntity, velocity)
    ecs.addComponent(world, spriteEntity, bounds)
    ecs.addComponent(world, spriteEntity, Bouncer{})
}

renderSprites :: proc(world: ^ecs.World) {
	spriteRenderers := ecs.query(world, Position, Sprite, Renderable)

    slice.sort_by(spriteRenderers, proc(i, j:ecs.QueryResult3(Position,Sprite,Renderable)) -> bool {
        return i.value2.scale.x < j.value2.scale.x
    })

	for ent in spriteRenderers {
		position := ent.value1
		sprite := ent.value2
		renderable := ent.value3
		if (renderable^) {
			dstWidth := f32(sprite.texture.width) * sprite.scale.x
			dstHeight := f32(sprite.texture.height) * sprite.scale.y
			dusk.DrawTexturePro(
				sprite.texture,
				sprite.source,
				{x = position.x, y = position.y, width = dstWidth, height = dstHeight},
				sprite.origin,
				sprite.rotation,
				sprite.color,
			)
		}
	}
}

demoShutdown :: proc(game: ^dusk.Game) {
	using self: ^Demo = transmute(^Demo)game
}

updateVolumeText :: proc(label: ^Label, position: ^Position, game: ^Demo) {
	using self := game


	builder: strings.Builder
	strings.builder_init_none(&builder)
	strings.write_string(&builder, "MUSIC VOLUME: ")
	strings.write_int(&builder, int(musicVolume * 100))
	label.text = strings.to_string(builder)
}

updateFpsText :: proc(label: ^Label, position: ^Position, game: ^Demo) {
    using self := game

    bouncers := ecs.query(&world, Bouncer)
    bouncerCount := len(bouncers)

	builder: strings.Builder
	strings.builder_init_none(&builder)
	strings.write_string(&builder, "FPS: ")
	strings.write_int(&builder, game.fps)
    strings.write_string(&builder, "\n\nBouncers: ")
	strings.write_int(&builder, bouncerCount)
	label.text = strings.to_string(builder)
}

// Defining the components

Position :: struct {
	using _: dusk.Vector2,
}

Velocity :: struct {
	using _: dusk.Vector2,
}

Bounds :: struct {
    using _: dusk.Rectangle,
}

Bouncer :: struct {}

Label :: struct {
	text:            string,
	fontSize:        i32,
	color:           dusk.Color,
	dropShadow:      bool,
	dropShadowColor: dusk.Color,
}

Sprite :: struct {
	texture:  dusk.Texture2D,
	source:   dusk.Rectangle,
	scale:    dusk.Vector2,
	origin:   dusk.Vector2,
	rotation: f32,
	color:    dusk.Color,
}

Renderable :: distinct bool

Wiggler :: struct {
	origin:    dusk.Vector2,
	max:       dusk.Vector2,
	timeScale: dusk.Vector2,
}

LabelUpdater :: struct {
	update: proc(label: ^Label, position: ^Position, game: ^Demo),
}
