/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package demo

import "core:log"
import "core:math"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

import dusk ".."
import delay "../delay"

main :: proc() {
	demoGame: ^Demo = new(Demo)
	demoGame.start = demoStart
	demoGame.demoState.enter = demoStateEnter
	demoGame.demoState.update = demoStateUpdate
	demoGame.demoState.render = demoStateRender
	demoGame.shutdown = demoShutdown
	demoGame.name = "DemoGame"
	demoGame.virtualResolution = {640, 360}
	dusk.run(demoGame)
}

V2ZERO :: rl.Vector2{0,0}
WHITE  :: rl.Color{255, 255, 255, 255}
DROP_SHADOW_COLOR :: rl.Color{0, 0, 0, 128}
FPS_TEXT_COLOR :: rl.Color{64,255,128,255}

MAX_BOUNCERS :: 500_000
BOUNCERS_PER_SPAWN :: 100

Wiggler :: struct {
	position:  rl.Vector2,
	origin:    rl.Vector2,
	max:       rl.Vector2,
	timeScale: rl.Vector2,
}

Bouncer :: struct {
	x:f32, y:f32, w:f32, h:f32,
	vx:f32, vy:f32,
	active:bool,
	color:rl.Color
}

Demo :: struct {
	using game:      dusk.Game,
	musicVolume:     f32,
	soundVolume:     f32,
	demoState:       DemoState,
}

DemoState :: struct {
	using state: dusk.State,
	testImage:       rl.Texture2D,
	testImgSource:   rl.Rectangle,
	testSound:       rl.Sound,

	bouncers:[MAX_BOUNCERS]Bouncer,

	bouncerCount:int,
	logo:Wiggler,
	fpsString:string,
	volumeString:string,
	prevFps:int,
	prevVolume:f32,

	howdyTextPos:rl.Vector2,
	fpsTextPos:rl.Vector2,
	volumeTextPos:rl.Vector2,
	instructionTextPos:rl.Vector2,
}

demoStart :: proc(game:^dusk.Game) -> bool {
	game := cast(^Demo)game
	log.info("[DEMO]", "Howdy! o/")
	dusk.PushState(game, &game.demoState)
	return true
}

demoStateEnter :: proc(state:^dusk.State, game: ^dusk.Game) -> bool {
	log.info("[DEMO]", "Demo State Enter")
	game := cast(^Demo)game
	state := cast(^DemoState)state

	state.testSound = rl.LoadSound("sfx/test.wav")
	game.music = rl.LoadMusicStream("music/test.mp3")
	state.testImage = rl.LoadTexture("art/test.png")
	state.testImgSource.x = 0
	state.testImgSource.y = 0
	state.testImgSource.width = f32(state.testImage.width)
	state.testImgSource.height = f32(state.testImage.height)

	game.musicVolume = 0.75
	game.soundVolume = 0.5
	rl.SetMusicVolume(game.music, game.musicVolume)
	rl.SetSoundVolume(state.testSound, game.soundVolume)

	delay.start(proc(sound: rawptr) {
		rl.PlaySound((cast(^rl.Sound)sound)^)
		}, 2, &state.testSound)

	delay.start(proc(sound: rawptr) {
		rl.PlaySound((cast(^rl.Sound)sound)^)
		}, 3, &state.testSound)

	delay.start(proc(music: rawptr) {
		rl.PlayMusicStream((cast(^rl.Music)music)^)
		}, 5, &game.music)

	delayTestMessage: string = "This is a test!"
	delay.start(proc(message: string) {
			log.info(message)
		}, 0.5, delayTestMessage)

	game.backgroundColor = WHITE

    delay.start(spawnBouncers, 1, state)

	state.logo.origin.x = game.screenSize.x / 2 - f32(state.testImage.width)
	state.logo.origin.y =  game.screenSize.y / 2 - f32(state.testImage.height)
	state.logo.max.x = 16
	state.logo.max.y = 16
	state.logo.timeScale.x = 1.6
	state.logo.timeScale.y = 1
	log.info("LOGO @", state.logo.origin)
	
	howdyWidth := f32(rl.MeasureText("Howdy! o/", 32))
	state.howdyTextPos.x = game.screenSize.x / 2 - howdyWidth / 2
	state.howdyTextPos.y = game.screenSize.y / 2 + 100
	log.info("Howdy @", state.howdyTextPos)

	state.instructionTextPos.x = 5 
	state.instructionTextPos.y = game.screenSize.y - 13
	log.info("Instruction @", state.instructionTextPos)

	state.volumeString = "MUSIC VOLUME: 75"
	state.volumeTextPos.x = 5
	state.volumeTextPos.y = game.screenSize.y - 24
	log.info("Volume @", state.volumeTextPos)

	state.fpsString = "FPS: 0"
	state.fpsTextPos.x = 5
	state.fpsTextPos.y = 5
	log.info("Volume @", state.fpsTextPos)
	
	return true
}

demoStateUpdate :: proc(state:^dusk.State, game: ^dusk.Game, deltTime: f32, runTime: f32) -> bool {
	game := cast(^Demo)game
	state := cast(^DemoState)state

	if (rl.IsKeyPressed(.MINUS)) {
		game.musicVolume -= 0.01
		game.musicVolume = math.min(math.max(game.musicVolume, 0), 1)
		rl.SetMusicVolume(game.music, game.musicVolume)
	}

	if (rl.IsKeyPressedRepeat(.MINUS)) {
		game.musicVolume -= 0.005
		game.musicVolume = math.min(math.max(game.musicVolume, 0), 1)
		rl.SetMusicVolume(game.music, game.musicVolume)
	}

	if (rl.IsKeyPressed(.EQUAL)) {
		game.musicVolume += 0.01
		game.musicVolume = math.min(math.max(game.musicVolume, 0), 1)
		rl.SetMusicVolume(game.music, game.musicVolume)
	}

	if (rl.IsKeyPressedRepeat(.EQUAL)) {
		game.musicVolume += 0.005
		game.musicVolume = math.min(math.max(game.musicVolume, 0), 1)
		rl.SetMusicVolume(game.music, game.musicVolume)
	}

	game.backgroundColor.r = u8(255 * ((math.sin(runTime / 5) + 1) / 2))
	game.backgroundColor.g = u8(255 * ((math.sin(runTime / 6) + 1) / 2))
	game.backgroundColor.b = u8(255 * ((math.sin(runTime / 10) + 1) / 2))
	
	state.logo.position.x = state.logo.origin.x + math.sin(runTime * state.logo.timeScale.x) * state.logo.max.x
	state.logo.position.y = state.logo.origin.y + math.sin(runTime * state.logo.timeScale.y) * state.logo.max.y

	for i in 0..<state.bouncerCount {
		state.bouncers[i].x += state.bouncers[i].vx * deltTime
		state.bouncers[i].y += state.bouncers[i].vy * deltTime
		right := game.screenSize.x - state.bouncers[i].w
		bottom := game.screenSize.y - state.bouncers[i].h
		if state.bouncers[i].x <= 0 { 
			state.bouncers[i].vx *= -1
			state.bouncers[i].x *= -1
		} else if state.bouncers[i].x >= right{
			state.bouncers[i].vx *= -1
			state.bouncers[i].x = right - (state.bouncers[i].x - right)
		}
		if state.bouncers[i].y <= 0 {
			state.bouncers[i].vy *= -1
			state.bouncers[i].y *= -1
		} else if state.bouncers[i].y >= bottom {
			state.bouncers[i].vy *= -1
			state.bouncers[i].y = bottom - (state.bouncers[i].y - bottom)
		}
	}

	builder1: strings.Builder
	strings.builder_init_len_cap(&builder1, 0, 256, context.temp_allocator)
	strings.write_string(&builder1, "MUSIC VOLUME: ")
	strings.write_int(&builder1, int(game.musicVolume * 100))
	state.volumeString = strings.to_string(builder1)
	
	builder2: strings.Builder
	strings.builder_init_len_cap(&builder2, 0, 256, context.temp_allocator)
	strings.write_string(&builder2, "FPS: ")
	strings.write_int(&builder2, game.fps)
	strings.write_string(&builder2, "\nBouncers: ")
	strings.write_int(&builder2, state.bouncerCount)
	state.fpsString = strings.to_string(builder2)
		
	return true
}

demoStateRender :: proc(state:^dusk.State, game: ^dusk.Game) {
	state := cast(^DemoState)state
	
	for i in 0..<state.bouncerCount {
		dstRect := rl.Rectangle {
			x=state.bouncers[i].x, y=state.bouncers[i].y, width=state.bouncers[i].w, height = state.bouncers[i].h
		}
		rl.DrawTexturePro(state.testImage, state.testImgSource, dstRect, V2ZERO, 0, state.bouncers[i].color)
	}

	rl.DrawTexturePro(
		state.testImage, 
		state.testImgSource, 
		{ 
			x = state.logo.position.x,  
			y = state.logo.position.y,  
			width = state.testImgSource.width*2,  
			height = state.testImgSource.height*2,
		}, 
		V2ZERO, 
		0, 
		WHITE,
	)
	
	rl.DrawText("Howdy! o/", i32(state.howdyTextPos.x) + 1, i32(state.howdyTextPos.y) + 1, 32, DROP_SHADOW_COLOR)
	rl.DrawText("Howdy! o/", i32(state.howdyTextPos.x),     i32(state.howdyTextPos.y),     32, WHITE)
	
	fpsCStr := strings.clone_to_cstring(state.fpsString)
	rl.DrawText(fpsCStr, i32(state.fpsTextPos.x) + 1, i32(state.fpsTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText(fpsCStr, i32(state.fpsTextPos.x),     i32(state.fpsTextPos.y),     8, FPS_TEXT_COLOR)
	
	volumeCStr := strings.clone_to_cstring(state.volumeString) 
	rl.DrawText(volumeCStr, i32(state.volumeTextPos.x) + 1, i32(state.volumeTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText(volumeCStr, i32(state.volumeTextPos.x),     i32(state.volumeTextPos.y),     8, WHITE)
	
	rl.DrawText("Press the [-] or [+] keys to change the volume.", i32(state.instructionTextPos.x) + 1, i32(state.instructionTextPos.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText("Press the [-] or [+] keys to change the volume.", i32(state.instructionTextPos.x),     i32(state.instructionTextPos.y),     8, WHITE)
}

spawnBouncers :: proc(state:rawptr) {
	state := cast(^DemoState)state

	if(state.bouncerCount + BOUNCERS_PER_SPAWN > MAX_BOUNCERS) do return
    for i in 0..< BOUNCERS_PER_SPAWN {
		state.bouncers[state.bouncerCount+i].x = state.logo.position.x + f32(state.testImage.width)/2
		state.bouncers[state.bouncerCount+i].y = state.logo.position.y + f32(state.testImage.height)/2
		state.bouncers[state.bouncerCount+i].w = f32(state.testImage.width) //* scale
		state.bouncers[state.bouncerCount+i].h = f32(state.testImage.height) //* scale
		state.bouncers[state.bouncerCount+i].vx = rand.float32_range(-100, 100)
		state.bouncers[state.bouncerCount+i].vy = rand.float32_range(-100, 100)
        state.bouncers[state.bouncerCount+i].color = rl.Color{ 
			u8(int(state.bouncers[state.bouncerCount+i].vx) % 256), 
			u8(i % 256), 
			u8(int(state.bouncers[state.bouncerCount+i].vy) % 256), 
			255}
			state.bouncers[state.bouncerCount+i].active = true
    }

	state.bouncerCount += BOUNCERS_PER_SPAWN

	fps := rl.GetFPS()
	if fps < 30 do return
    delay.start(spawnBouncers, 0, state)
}

demoShutdown :: proc(game: ^dusk.Game) {
	log.info("[DEMO]", "Later! o/")
}