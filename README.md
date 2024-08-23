# Dusk

## What?

Dusk is a small game template / framework or whatever you want to call it.
I made it to make the start of a project more enjoyable for me.

## Features

* Abstracts away some of the boiler plate initialization and gameloop stuff.
* Virtual Resolutions
* Delayed procedure calls

## Roadmap

In no particular order here are some things I want to add.

* Some build in post processing with the option for custom stuff. IE. Scanlines
* Scripting via lua for states
* Build in settings saving and loading for graphics and sound options

## Build the demo

To build the demo use `odin build ./demo -out:bin/demo.exe`
and then `.\bin\demo.exe` to run the demo

I've only tired this on windows so far I'll update this when i get a chance to test it on other platforms.
Note: you may need to copy the art, music and sfx folders to the bin directory if you do are not seeing a bunch of spites bouncing around.

## How to use

- Clone dusk or download it as a zip
- You can also add it as a submodule to your project


## Minimal Example

see the [demo](demo/demo.odin) for a larger example

```Odin
package example

import "core:log"
import rl "vendor:raylib"

import dusk "path/to/dusk"
import delay "path/to/dusk/delay"

V2ZERO :: rl.Vector2{0,0}
WHITE :: rl.Color{255, 255, 255, 255}

main :: proc() {
    myGame : MyGame
    myGame.start = gameStart
	myGame.myGameState.enter = myGameStateEnter
    myGame.myGameState.update = myGameStateUpdate
    myGame.myGameState.render = myGameStateRender
    myGame.shutdown = gameShutdown
    myGame.name = "MyGame"
    dusk.run(&myGame)
}

MyGame :: struct {
    using game:dusk.Game,
    myGameState:MyGameState,
}

MyGameState :: struct {
    using state:dusk.State,
    testTexture:rl.Texture2D,
    someData:[10]u32,
    imagePosition:rl.Vector2,
}

logSomeData :: proc(state:rawptr) {
    state := cast(^MyGameState)state
    for data in state.someData {
        log.info("[Example] someData:", data)
    }
}

gameStart :: proc(game:^dusk.Game) -> bool {
    game := cast(^MyGame)game
    log.info("[MyGame]","gameStart")
    dusk.PushState(game, &game.myGameState)
	return true
}

myGameStateEnter :: proc(state:^dusk.State, game:^dusk.Game) -> bool {
    state := cast(^MyGameState)state
    state.testTexture = rl.LoadTexture("art/test.png")
    state.imagePosition = {20, 20} 

    for &data, i in state.someData {
        data = u32(i)
    }

    // Log out the values of someData in 3 seconds
    delay.start(logSomeData, 3, state)
    
    return true
}

myGameStateUpdate :: proc(state:^dusk.State, game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    state := cast(^MyGameState)state

    for &data in state.someData {
        data += 1
    }

    return true
}

myGameStateRender :: proc(state:^dusk.State, game:^dusk.Game) {
    state := cast(^MyGameState)state
    
    imgWidth := f32(state.testTexture.width)
    imgHeight := f32(state.testTexture.height)

    rl.DrawTexturePro(
        state.testTexture, 
        rl.Rectangle{0, 0, imgWidth, imgHeight}, 
        rl.Rectangle{state.imagePosition.x, state.imagePosition.y, imgWidth, imgHeight}, 
        V2ZERO, 0, WHITE)
}

gameShutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = cast(^MyGame)game
    log.info("[MyGame]","gameShutdown")
}
```
## What happened to ECS?

My implementation was bad / not as fast not using it, at least for the types of things i'm making.
So instead of bashing my head on trying to make it run faster I have refocused my efforts to other things.

## Weren't you replacing raylib

Long story short, hardware failure and some unfortunate mistakes on my part led me to lose a months worth of progress on my own renderer.
Due to actually having to make a game I am forgoing making my own renderer, at least for now.