# Dusk

## What?

Dusk is a small game template / framework or whatever you want to call it.
I made it to make the start of a project more enjoyable for me.

## Breaking Changes (12/12/2024)
* I've renamed some stuff to match my new coding convention. I think I got everything in this pass so hopefuly this won't happen again.
* I moved the delay out of its own package.
* Removed late update and post render callbacks from the state as they didn't seem super usefull.

## Template
I've made a repository template starting new dusk based projects.

[dusk-project-template](https://github.com/JerMakesStuff/dusk-project-tempate)

## Features

* Abstracts away some of the boiler plate initialization and gameloop stuff. 
* Virtual Resolutions
* Delayed procedure calls
* Game settings - loading only
* Added suport for a post processing shader - untested

## Roadmap

In no particular order here are some things I want to add.

* Animated Sprites
* Game settings save
* Better volume handling

## Build the demo

To build the demo use `odin build ./demo -out:bin/demo.exe`
and then `.\bin\demo.exe` to run the demo

I've only tired this on windows so far I'll update this when i get a chance to test it on other platforms.
Note: you may need to copy the art, music and sfx folders to the bin directory if you do are not seeing a bunch of spites bouncing around.

## How to use

- Clone dusk or download it as a zip
- You can also add it as a submodule to your project.

## Minimal Example

see the [demo](demo/demo.odin) for a larger example

```Odin
package example

import "core:log"
import rl "vendor:raylib"

import dusk "path/to/dusk"

main :: proc() {
    game : MyGame
    game.start = start
	game.game_state.enter = game_state_enter
    game.game_state.update = game_state_update
    game.game_state.render = game_state_render
    game.shutdown = shutdown
    game.name = "Game Name Goes Here"
    dusk.run(&game)
}

MyGame :: struct {
    using game:dusk.Game,
    game_state:MyGameState,
    some_game_setting:int,
}

MyGameState :: struct {
    using state:dusk.State,
    test_texture:rl.Texture2D,
    some_data:[10]u32,
    image_position:rl.Vector2,
}

log_some_data :: proc(state:rawptr) {
    state := cast(^MyGameState)state
    for data in state.some_data {
        log.info("[Example] some_data:", data)
    }
}

start :: proc(game:^dusk.Game) -> bool {
    game := cast(^MyGame)game
    log.info("[MyGame]","gameStart")
    game.some_game_setting = dusk.get_setting_as_int(game, "gameplay", "some", 9999)
    dusk.push_state(game, &game.game_state)
	return true
}

game_state_enter :: proc(state:^dusk.State, game:^dusk.Game) -> bool {
    state := cast(^MyGameState)state
    state.test_texture = rl.LoadTexture("art/test.png")
    state.image_position = {20, 20} 

    for &data, i in state.some_data {
        data = u32(i)
    }

    // Log out the values of someData in 3 seconds
    dusk.start_delay(log_some_data, 3, state)
    
    return true
}

game_state_update :: proc(state:^dusk.State, game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    state := cast(^MyGameState)state

    for &data in state.some_data {
        data += 1
    }

    return true
}

game_state_render :: proc(state:^dusk.State, game:^dusk.Game) {
    state := cast(^MyGameState)state
    
    image_width := f32(state.test_texture.width)
    image_height := f32(state.test_texture.height)

    rl.DrawTexturePro(
        state.test_texture, 
        rl.Rectangle{0, 0, image_width, image_height}, 
        rl.Rectangle{state.image_position.x, state.image_position.y, image_width, image_height}, 
        dusk.V2ZERO, 0, rl.WHITE)
}

shutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = cast(^MyGame)game
    log.info("[MyGame]","shutdown")
}
```

## What happened to ECS?

My implementation was bad / not as fast not using it, at least for the types of things i'm making.
So instead of bashing my head on trying to make it run faster I have refocused my efforts to other things.

## Weren't you replacing raylib

Long story short, hardware failure and some unfortunate mistakes on my part led me to lose a months worth of progress on my own renderer.
Due to actually having to make a game I am forgoing making my own renderer, at least for now.