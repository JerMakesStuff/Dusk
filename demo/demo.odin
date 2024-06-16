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
	demoGame.render = demoRender
	demoGame.shutdown = demoShutdown
	demoGame.name = "DemoGame"
	demoGame.virtualResolution = {640, 360}
	dusk.run(&demoGame)
}

WHITE :: dusk.Color{255, 255, 255, 255}
DROP_SHADOW_COLOR :: dusk.Color{0, 0, 0, 128}
FPS_TEXT_COLOR :: dusk.Color{64,255,128,255}

MAX_BOUNCERS :: 500_000
BOUNCERS_PER_SPAWN :: 100
Position :: struct {
	using position: dusk.Vector2,
}

Bouncer :: struct {
	using velocity: dusk.Vector2,
}

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

Wiggler :: struct {
	origin:    dusk.Vector2,
	max:       dusk.Vector2,
	timeScale: dusk.Vector2,
}

LabelUpdater :: struct {
	update: proc(label: ^Label, position: ^Position, game: ^Demo),
}

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

    delay.start(spawnBouncers, 5, self)

    logoStartPos := Position {  
		x = screenSize.x / 2 - f32(testImage.width), 
		y = screenSize.y / 2 - f32(testImage.width)}
	logoEnt = createSprite(&world, testImage, 2, logoStartPos)
    logoWiggler := Wiggler { origin = logoStartPos, max = dusk.Vector2{16, 16}, timeScale = dusk.Vector2{1.6, 1}}
	ecs.addComponent(&world, logoEnt, logoWiggler)

	howdyWidth := f32(dusk.MeasureText("Howdy! o/", 32))
    howdyPosition := Position{
		x = screenSize.x / 2 - howdyWidth / 2, 
		y = screenSize.y / 2 + 100}
	howdyEnt = createLabel(&world, "Howdy! o/", 32, WHITE, howdyPosition, true)

    instructionsPosition := Position{
		x = 5, 
		y = screenSize.y - 13}
	instructionsEnt = createLabel(&world, "use the [-] and [=] keys to change the music volume", 8, WHITE, instructionsPosition, true)

    volumePosition := Position{
		x = 5, 
		y = screenSize.y - 24}
	volumeTextEnt = createLabel(&world, "MUSIC VOLUME: 75", 8, WHITE, volumePosition, true)
	ecs.addComponent(&world, volumeTextEnt, LabelUpdater{update = updateVolumeText})

    fpsPos := Position{x = 5, y = 5}
	fpsEnt := createLabel(&world, "FPS:", 8, FPS_TEXT_COLOR, fpsPos, true)
	ecs.addComponent(&world, fpsEnt, LabelUpdater{update = updateFpsText})

	return true
}

demoUpdate :: proc(game: ^dusk.Game, deltTime: f32, runTime: f32) -> bool {
	using self: ^Demo = transmute(^Demo)game

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

	backgroundColor.r = u8(255 * ((math.sin(runTime / 5) + 1) / 2))
	backgroundColor.g = u8(255 * ((math.sin(runTime / 6) + 1) / 2))
	backgroundColor.b = u8(255 * ((math.sin(runTime / 10) + 1) / 2))

	updateWigglers(&world, runTime)
    updateBouncers(self, deltTime)
	updateLabels(&world, self)


	return true
}

demoRender :: proc(game: ^dusk.Game) {
	using self: ^Demo = transmute(^Demo)game
	
	renderBouncers(&world)
	renderLogo(self)
	renderLabels(&world)
}

spawnBouncers :: proc(game:rawptr) {
    using self := transmute(^Demo)game

    logoPosition := ecs.getComponent(&world, logoEnt, Position)

	bouncers := ecs.query(&world, Bouncer)
	bouncerCount := len(bouncers)

	if(bouncerCount + BOUNCERS_PER_SPAWN > MAX_BOUNCERS) do return
    
    for i in 0..< BOUNCERS_PER_SPAWN {
		bouncerStartPos := Position {
			x = logoPosition.x + f32(testImage.width) / 2,
			y = logoPosition.y + f32(testImage.height) / 2, 
		}

        bouncer := Bouncer { 
			x = rand.float32_range(-100, 100), 
			y = rand.float32_range(-100, 100)
		}
		
		bouncerColor := dusk.Color { 
			u8(int(bouncer.x) % 256), 
			u8(i % 256), 
			u8(int(bouncer.y) % 256), 
			255
		}
        spriteEntity := createSprite(&world, testImage, 1, bouncerStartPos, bouncerColor)
		ecs.addComponent(&world, spriteEntity, bouncer)
    }

	if fps < 60 do return
    delay.start(spawnBouncers, 0, self)
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

updateBouncers :: proc(game:^Demo, deltaTime: f32) {
	using self := game
    bouncers := ecs.query(&world, Position, Bouncer)
    
	for entity in bouncers {
        position := entity.value1
        velocity := entity.value2

        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime

        right := screenSize.x - f32(testImage.width)
		bottom := screenSize.y - f32(testImage.width)

		if position.x <= 0 { 
			velocity.x *= -1
			position.x *= -1
		} else if position.x >= right{
			velocity.x *= -1
			position.x = right - (position.x - right)
		}
		if position.y <= 0 {
			velocity.y *= -1
			position.y *= -1
		} else if position.y >= bottom {
			velocity.y *= -1
			position.y = bottom - (position.y - bottom)
		}
    }
}

createLabel :: proc(world: ^ecs.World, text: string, fontSize: i32, color: dusk.Color, position: Position, dropShadow: bool = false, dropShadowColor: dusk.Color = DROP_SHADOW_COLOR ) -> ecs.Entity {
    label := ecs.createEntity(world)
    ecs.addComponent(world, label, position)
	ecs.addComponent(world, label, Label { text = text, fontSize = fontSize, color = color, dropShadow = dropShadow, dropShadowColor = dropShadowColor})
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
	labelRenderers := ecs.query(world, Position, Label)
	for ent in labelRenderers {
		position := ent.value1
		label := ent.value2
		text := strings.clone_to_cstring(label.text, context.temp_allocator)
		if (label.dropShadow) {
			dusk.DrawText(
				text,
				i32(position.x) + 1,
				i32(position.y) + 1,
				label.fontSize,
				label.dropShadowColor,
			)
		}
		dusk.DrawText(text, i32(position.x), i32(position.y), label.fontSize, label.color)
		
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
    return spriteEntity
}

renderBouncers :: proc(world: ^ecs.World) {
	spriteRenderers := ecs.query(world, Position, Sprite, Bouncer)

    slice.sort_by(spriteRenderers, proc(i, j:ecs.QueryResult3(Position,Sprite,Bouncer)) -> bool {
        return i.entity < j.entity
    })

	for ent in spriteRenderers {
		position   := ent.value1
		sprite     := ent.value2
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

renderLogo :: proc(game:^Demo) {
	using self := game

	position   := ecs.getComponent(&world, logoEnt, Position)
	sprite     := ecs.getComponent(&world, logoEnt, Sprite)
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
    strings.write_string(&builder, "\nBouncers: ")
	strings.write_int(&builder, bouncerCount)
	label.text = strings.to_string(builder)
}
