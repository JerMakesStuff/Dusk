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

main :: proc() {
	demo: ^Demo = new(Demo)
	demo.start = demo_start
	demo.demo_state.enter = demo_state_enter
	demo.demo_state.update = demo_state_update
	demo.demo_state.render = demo_state_render
	demo.shutdown = demo_shutdown
	demo.name = "Demo Game"
	demo.virtual_resolution = {640, 360}
	dusk.run(demo)
}

DROP_SHADOW_COLOR :: rl.Color{0, 0, 0, 128}
FPS_TEXT_COLOR    :: rl.Color{64,255,128,255}

MAX_BOUNCERS       :: 500_000
BOUNCERS_PER_SPAWN :: 100

Wiggler :: struct {
	position   : rl.Vector2,
	origin     : rl.Vector2,
	max        : rl.Vector2,
	time_scale : rl.Vector2,
}

Bouncer :: struct {
	position : rl.Vector2,
	size     : rl.Vector2,
	velocity : rl.Vector2,
	active   : bool,
	color    : rl.Color
}

Demo :: struct {
	using game : dusk.Game,
	demo_state  : DemoState,
}

DemoState :: struct {
	using state: dusk.State,
	image        : rl.Texture2D,
	image_source : rl.Rectangle,
	sound        : rl.Sound,

	bouncers      : [MAX_BOUNCERS]Bouncer,
	bouncer_count : int,

	logo          : Wiggler,
	
	fps_string        : string,
	fps_text_position : rl.Vector2,
	prev_fps          : int,

	volume_string        : string,
	volume_text_position : rl.Vector2,
	prev_volume          : f32,

	howdy_text_position       : rl.Vector2,
	instruction_text_position : rl.Vector2,
}

demo_start :: proc(game:^dusk.Game) -> bool {
	game := cast(^Demo)game
	log.info("[DEMO]", "Howdy! o/")
	dusk.push_state(game, &game.demo_state)
	return true
}

demo_state_enter :: proc(state:^dusk.State, game: ^dusk.Game) -> bool {
	log.info("[DEMO]", "Demo State Enter")
	game := cast(^Demo)game
	state := cast(^DemoState)state

	state.sound = rl.LoadSound("sfx/test.wav")
	game.music  = rl.LoadMusicStream("music/test.mp3")
	state.image = rl.LoadTexture("art/test.png")
	
	state.image_source.x = 0
	state.image_source.y = 0

	state.image_source.width  = cast(f32)state.image.width
	state.image_source.height = cast(f32)state.image.height

	rl.SetMusicVolume(game.music, cast(f32)(game.settings.master_volume * game.settings.music_volume))
	rl.SetSoundVolume(state.sound, cast(f32)(game.settings.master_volume * game.settings.sfx_volume))

	dusk.start_delay(proc(sound: rawptr) {
		rl.PlaySound((cast(^rl.Sound)sound)^)
		}, 2, &state.sound)

	dusk.start_delay(proc(sound: rawptr) {
		rl.PlaySound((cast(^rl.Sound)sound)^)
		}, 3, &state.sound)

	dusk.start_delay(proc(music: rawptr) {
		rl.PlayMusicStream((cast(^rl.Music)music)^)
		}, 5, &game.music)

	delay_message: string = "This is a test!"
	dusk.start_delay(proc(message: string) {
			log.info(message)
		}, 0.5, delay_message)

	game.clear_color = rl.WHITE

    dusk.start_delay(spawn_bouncers, 1, state)

	state.logo.origin.x = cast(f32)game.screen_size.x / 2 - f32(state.image.width)
	state.logo.origin.y = cast(f32)game.screen_size.y / 2 - f32(state.image.height)
	state.logo.max.x = 16
	state.logo.max.y = 16
	state.logo.time_scale.x = 1.6
	state.logo.time_scale.y = 1
	log.info("LOGO @", state.logo.origin)
	
	howdyWidth := f32(rl.MeasureText("Howdy! o/", 32))
	state.howdy_text_position.x = cast(f32)game.screen_size.x / 2 - howdyWidth / 2
	state.howdy_text_position.y = cast(f32)game.screen_size.y / 2 + 100
	log.info("Howdy @", state.howdy_text_position)

	state.instruction_text_position.x = 5 
	state.instruction_text_position.y = cast(f32)game.screen_size.y - 13
	log.info("Instruction @", state.instruction_text_position)

	state.volume_string = "MUSIC VOLUME: 75"
	state.volume_text_position.x = 5
	state.volume_text_position.y = cast(f32)game.screen_size.y - 24
	log.info("Volume @", state.volume_text_position)

	state.fps_string = "FPS: 0"
	state.fps_text_position.x = 5
	state.fps_text_position.y = 5
	log.info("Volume @", state.fps_text_position)
	
	return true
}

demo_state_update :: proc(state:^dusk.State, game: ^dusk.Game, deltTime: f32, runTime: f32) -> bool {
	game := cast(^Demo)game
	state := cast(^DemoState)state

	if (rl.IsKeyPressed(.MINUS)) {
		game.settings.music_volume -= 0.01
		game.settings.music_volume = math.min(math.max(game.settings.music_volume, 0), 1)
		rl.SetMusicVolume(game.music, cast(f32)(game.settings.master_volume * game.settings.music_volume))
	}

	if (rl.IsKeyPressedRepeat(.MINUS)) {
		game.settings.music_volume -= 0.005
		game.settings.music_volume = math.min(math.max(game.settings.music_volume, 0), 1)
		rl.SetMusicVolume(game.music, cast(f32)(game.settings.master_volume * game.settings.music_volume))
	}

	if (rl.IsKeyPressed(.EQUAL)) {
		game.settings.music_volume += 0.01
		game.settings.music_volume = math.min(math.max(game.settings.music_volume, 0), 1)
		rl.SetMusicVolume(game.music, cast(f32)(game.settings.master_volume * game.settings.music_volume))
	}

	if (rl.IsKeyPressedRepeat(.EQUAL)) {
		game.settings.music_volume += 0.005
		game.settings.music_volume = math.min(math.max(game.settings.music_volume, 0), 1)
		rl.SetMusicVolume(game.music, cast(f32)(game.settings.master_volume * game.settings.music_volume))
	}

	game.clear_color.r = u8(255 * ((math.sin(runTime / 5) + 1) / 2))
	game.clear_color.g = u8(255 * ((math.sin(runTime / 6) + 1) / 2))
	game.clear_color.b = u8(255 * ((math.sin(runTime / 10) + 1) / 2))
	
	state.logo.position.x = state.logo.origin.x + math.sin(runTime * state.logo.time_scale.x) * state.logo.max.x
	state.logo.position.y = state.logo.origin.y + math.sin(runTime * state.logo.time_scale.y) * state.logo.max.y

	for i in 0..<state.bouncer_count {
		state.bouncers[i].position.x += state.bouncers[i].velocity.x * deltTime
		state.bouncers[i].position.y += state.bouncers[i].velocity.y * deltTime
		right := cast(f32)game.screen_size.x - state.bouncers[i].size.x
		bottom := cast(f32)game.screen_size.y - state.bouncers[i].size.y
		if state.bouncers[i].position.x <= 0 { 
			state.bouncers[i].velocity.x *= -1
			state.bouncers[i].position.x *= -1
		} else if state.bouncers[i].position.x >= right{
			state.bouncers[i].velocity.x *= -1
			state.bouncers[i].position.x = right - (state.bouncers[i].position.x - right)
		}
		if state.bouncers[i].position.y <= 0 {
			state.bouncers[i].velocity.y *= -1
			state.bouncers[i].position.y *= -1
		} else if state.bouncers[i].position.y >= bottom {
			state.bouncers[i].velocity.y *= -1
			state.bouncers[i].position.y = bottom - (state.bouncers[i].position.y - bottom)
		}
	}

	builder1: strings.Builder
	strings.builder_init_len_cap(&builder1, 0, 256, context.temp_allocator)
	strings.write_string(&builder1, "MUSIC VOLUME: ")
	strings.write_int(&builder1, int(game.settings.music_volume * 100))
	state.volume_string = strings.to_string(builder1)
	
	builder2: strings.Builder
	strings.builder_init_len_cap(&builder2, 0, 256, context.temp_allocator)
	strings.write_string(&builder2, "FPS: ")
	strings.write_int(&builder2, game.fps)
	strings.write_string(&builder2, "\nBouncers: ")
	strings.write_int(&builder2, state.bouncer_count)
	state.fps_string = strings.to_string(builder2)
		
	return true
}

demo_state_render :: proc(state:^dusk.State, game: ^dusk.Game) {
	state := cast(^DemoState)state
	
	for i in 0..<state.bouncer_count {
		dstRect := rl.Rectangle {
			x=state.bouncers[i].position.x, y=state.bouncers[i].position.y, width=state.bouncers[i].size.x, height = state.bouncers[i].size.y
		}
		rl.DrawTexturePro(state.image, state.image_source, dstRect, dusk.V2ZERO, 0, state.bouncers[i].color)
	}

	rl.DrawTexturePro(
		state.image, 
		state.image_source, 
		{ 
			x = state.logo.position.x,  
			y = state.logo.position.y,  
			width = state.image_source.width*2,  
			height = state.image_source.height*2,
		}, 
		dusk.V2ZERO, 
		0, 
		rl.WHITE,
	)
	
	rl.DrawText("Howdy! o/", i32(state.howdy_text_position.x) + 1, i32(state.howdy_text_position.y) + 1, 32, DROP_SHADOW_COLOR)
	rl.DrawText("Howdy! o/", i32(state.howdy_text_position.x),     i32(state.howdy_text_position.y),     32, rl.WHITE)
	
	fpsCStr := strings.clone_to_cstring(state.fps_string)
	rl.DrawText(fpsCStr, i32(state.fps_text_position.x) + 1, i32(state.fps_text_position.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText(fpsCStr, i32(state.fps_text_position.x),     i32(state.fps_text_position.y),     8, FPS_TEXT_COLOR)
	
	volumeCStr := strings.clone_to_cstring(state.volume_string) 
	rl.DrawText(volumeCStr, i32(state.volume_text_position.x) + 1, i32(state.volume_text_position.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText(volumeCStr, i32(state.volume_text_position.x),     i32(state.volume_text_position.y),     8, rl.WHITE)
	
	rl.DrawText("Press the [-] or [+] keys to change the volume.", i32(state.instruction_text_position.x) + 1, i32(state.instruction_text_position.y) + 1, 8, DROP_SHADOW_COLOR)
	rl.DrawText("Press the [-] or [+] keys to change the volume.", i32(state.instruction_text_position.x),     i32(state.instruction_text_position.y),     8, rl.WHITE)
}

spawn_bouncers :: proc(state:rawptr) {
	state := cast(^DemoState)state

	if(state.bouncer_count + BOUNCERS_PER_SPAWN > MAX_BOUNCERS) do return
    for i in 0..< BOUNCERS_PER_SPAWN {
		state.bouncers[state.bouncer_count+i].position.x = state.logo.position.x + f32(state.image.width)/2
		state.bouncers[state.bouncer_count+i].position.y = state.logo.position.y + f32(state.image.height)/2
		state.bouncers[state.bouncer_count+i].size.x = f32(state.image.width) //* scale
		state.bouncers[state.bouncer_count+i].size.y = f32(state.image.height) //* scale
		state.bouncers[state.bouncer_count+i].velocity.x = rand.float32_range(-100, 100)
		state.bouncers[state.bouncer_count+i].velocity.y = rand.float32_range(-100, 100)
        state.bouncers[state.bouncer_count+i].color = rl.Color{ 
			u8(int(state.bouncers[state.bouncer_count+i].velocity.x) % 256), 
			u8(i % 256), 
			u8(int(state.bouncers[state.bouncer_count+i].velocity.y) % 256), 
			255}
			state.bouncers[state.bouncer_count+i].active = true
    }

	state.bouncer_count += BOUNCERS_PER_SPAWN

	fps := rl.GetFPS()
	if fps < 30 do return
    dusk.start_delay(spawn_bouncers, 0, state)
}

demo_shutdown :: proc(game: ^dusk.Game) {
	log.info("[DEMO]", "Later! o/")
}