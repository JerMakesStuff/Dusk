/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package demo

import "core:log"
import "core:math"
import "core:math/rand"
import "core:strings"

import dusk ".."
import delay "../delay"

main :: proc() {
	demoGame: ^Demo = new(Demo)
	demoGame.start = demoStart
	demoGame.update = demoUpdate
	demoGame.render = demoRender
	demoGame.shutdown = demoShutdown
	demoGame.name = "DemoGame"
	demoGame.virtualResolution = {640, 360}
	dusk.run(demoGame)
}

WHITE :: dusk.Color{255, 255, 255, 255}
DROP_SHADOW_COLOR :: dusk.Color{0, 0, 0, 128}
FPS_TEXT_COLOR :: dusk.Color{64,255,128,255}

MAX_BOUNCERS :: 500_000
BOUNCERS_PER_SPAWN :: 100

Wiggler :: struct {
	position:  dusk.Vector2,
	origin:    dusk.Vector2,
	max:       dusk.Vector2,
	timeScale: dusk.Vector2,
}

Bouncer :: struct {
	x:f32, y:f32, w:f32, h:f32,
	vx:f32, vy:f32,
	active:bool,
	color:dusk.Color
}

Demo :: struct {
	using game:      dusk.Game,

	musicVolume:     f32,
	soundVolume:     f32,

	testImage:       dusk.Texture2D,
	testImgSource:   dusk.Rectangle,
	testSound:       dusk.Sound,

	bouncers:#soa[MAX_BOUNCERS]Bouncer,

	bouncerCount:int,
	logo:Wiggler,
	fpsString:string,
	volumeString:string,
	prevFps:int,
	prevVolume:f32,

	howdyTextPos:dusk.Vector2,
	fpsTextPos:dusk.Vector2,
	volumeTextPos:dusk.Vector2,
	instructionTextPos:dusk.Vector2,
}

demoStart :: proc(game: ^dusk.Game) -> bool {
	using self: ^Demo = transmute(^Demo)game

	log.info("[DEMO]", "Howdy! o/")

	testSound = dusk.LoadSound("sfx/test.wav")
	music = dusk.LoadMusicStream("music/test.mp3")
	testImage = dusk.LoadTexture("art/test.png")
	testImgSource.x = 0
	testImgSource.y = 0
	testImgSource.width = f32(testImage.width)
	testImgSource.height = f32(testImage.height)

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

    delay.start(spawnBouncers, 1, self)

	logo.origin.x = screenSize.x / 2 - f32(testImage.width)
	logo.origin.y =  screenSize.y / 2 - f32(testImage.height)
	logo.max.x = 16
	logo.max.y = 16
	logo.timeScale.x = 1.6
	logo.timeScale.y = 1
	log.info("LOGO @", logo.origin)
	
	howdyWidth := f32(dusk.MeasureText("Howdy! o/", 32))
	howdyTextPos.x = screenSize.x / 2 - howdyWidth / 2
	howdyTextPos.y = screenSize.y / 2 + 100
	log.info("Howdy @", howdyTextPos)

	instructionTextPos.x = 5 
	instructionTextPos.y = screenSize.y - 13
	log.info("Instruction @", instructionTextPos)

	volumeString = "MUSIC VOLUME: 75"
	volumeTextPos.x = 5
	volumeTextPos.y = screenSize.y - 24
	log.info("Volume @", volumeTextPos)

	fpsString = "FPS: 0"
	fpsTextPos.x = 5
	fpsTextPos.y = 5
	log.info("Volume @", fpsTextPos)
	
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
	
	logo.position.x = logo.origin.x + math.sin(runTime * logo.timeScale.x) * logo.max.x
	logo.position.y = logo.origin.y + math.sin(runTime * logo.timeScale.y) * logo.max.y

	for i in 0..<bouncerCount {
		bouncers[i].x += bouncers[i].vx * deltTime
		bouncers[i].y += bouncers[i].vy * deltTime
		right := screenSize.x - bouncers[i].w
		bottom := screenSize.y - bouncers[i].h
		if bouncers[i].x <= 0 { 
			bouncers[i].vx *= -1
			bouncers[i].x *= -1
		} else if bouncers[i].x >= right{
			bouncers[i].vx *= -1
			bouncers[i].x = right - (bouncers[i].x - right)
		}
		if bouncers[i].y <= 0 {
			bouncers[i].vy *= -1
			bouncers[i].y *= -1
		} else if bouncers[i].y >= bottom {
			bouncers[i].vy *= -1
			bouncers[i].y = bottom - (bouncers[i].y - bottom)
		}
	}

	builder1: strings.Builder
	strings.builder_init_len_cap(&builder1, 0, 256, context.temp_allocator)
	strings.write_string(&builder1, "MUSIC VOLUME: ")
	strings.write_int(&builder1, int(musicVolume * 100))
	volumeString = strings.to_string(builder1)
	
	builder2: strings.Builder
	strings.builder_init_len_cap(&builder2, 0, 256, context.temp_allocator)
	strings.write_string(&builder2, "FPS: ")
	strings.write_int(&builder2, game.fps)
	strings.write_string(&builder2, "\nBouncers: ")
	strings.write_int(&builder2, bouncerCount)
	fpsString = strings.to_string(builder2)
		
	return true
}

demoRender :: proc(game: ^dusk.Game) {
	using self: ^Demo = transmute(^Demo)game
	
	for i in 0..<bouncerCount {
		dstRect := dusk.Rectangle {
			x=bouncers[i].x, y=bouncers[i].y, width=bouncers[i].w, height = bouncers[i].h
		}
		dusk.DrawTexturePro(testImage, testImgSource, dstRect, dusk.V2ZERO, 0, bouncers[i].color)
	}

	dusk.DrawTexturePro(testImage, testImgSource, { x = logo.position.x,  y = logo.position.y,  width = testImgSource.width*2,  height = testImgSource.height*2}, dusk.V2ZERO, 0, WHITE)
	
	dusk.DrawText("Howdy! o/", i32(howdyTextPos.x) + 1, i32(howdyTextPos.y) + 1, 32, DROP_SHADOW_COLOR)
	dusk.DrawText("Howdy! o/", i32(howdyTextPos.x),     i32(howdyTextPos.y),     32, WHITE)
	
	fpsCStr := strings.clone_to_cstring(fpsString)
	dusk.DrawText(fpsCStr, i32(fpsTextPos.x) + 1, i32(fpsTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	dusk.DrawText(fpsCStr, i32(fpsTextPos.x),     i32(fpsTextPos.y),     8, FPS_TEXT_COLOR)
	
	volumeCStr := strings.clone_to_cstring(volumeString) 
	dusk.DrawText(volumeCStr, i32(volumeTextPos.x) + 1, i32(volumeTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	dusk.DrawText(volumeCStr, i32(volumeTextPos.x),     i32(volumeTextPos.y),     8, WHITE)
	
	dusk.DrawText("Press the [-] or [+] keys to change the volume.", i32(instructionTextPos.x) + 1, i32(instructionTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	dusk.DrawText("Press the [-] or [+] keys to change the volume.", i32(instructionTextPos.x),     i32(instructionTextPos.y),     8, WHITE)
}

spawnBouncers :: proc(game:rawptr) {
    using self := transmute(^Demo)game

	if(bouncerCount + BOUNCERS_PER_SPAWN > MAX_BOUNCERS) do return
    for i in 0..< BOUNCERS_PER_SPAWN {
		bouncers[bouncerCount+i].x = logo.position.x + f32(testImage.width)/2
		bouncers[bouncerCount+i].y = logo.position.y + f32(testImage.height)/2
		bouncers[bouncerCount+i].w = f32(testImage.width) //* scale
		bouncers[bouncerCount+i].h = f32(testImage.height) //* scale
		bouncers[bouncerCount+i].vx = rand.float32_range(-100, 100)
		bouncers[bouncerCount+i].vy = rand.float32_range(-100, 100)
        bouncers[bouncerCount+i].color = dusk.Color{ 
			u8(int(bouncers[bouncerCount+i].vx) % 256), 
			u8(i % 256), 
			u8(int(bouncers[bouncerCount+i].vy) % 256), 
			255}
		bouncers[bouncerCount+i].active = true
    }

	bouncerCount += BOUNCERS_PER_SPAWN

	if fps < 60 do return
    delay.start(spawnBouncers, 0, self)
}

demoShutdown :: proc(game: ^dusk.Game) {
	using self: ^Demo = transmute(^Demo)game
}