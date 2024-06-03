# Dusk

## What?

Dusk is a small game template / framework or whatever you want to call it.
I made it to make the start of a project more enjoyable for me.

## Features

* Abstracts away some of the boiler plate initialization and gameloop stuff.
* ECS
* Delayed procedure calls

## Roadmap

In no particular order here are some things I want to add.

* Virtual Resolutions
* Some build in post processing with the option for custom stuff. IE. Scanlines
* Some prebuilt Components and Systems for doing standard stuff like drawing sprites.
* Scripting via lua
* Abstract away more of raylib by default
* Build in settings saving and loading for graphics and sound options

## Build the demo

To build the demo use `odin build ./demo -out:bin/demo.exe`
and then `.\bin\demo.exe` to run the demo

I've only tired this on windows so far i'll update this when i get a chance to test it on other platforms.

## How to use

- Clone dusk or download it as a zip
- You can also add it as a submodule to your project

## Minimal Example

see the [demo](demo/demo.odin) for a larger example

```Odin
package example

import "core:log"

import dusk "path/to/dusk"
import ecs "path/to/dusk/ecs"
import delay "path/to/dusk/delay"

main :: proc() {
    myGame : MyGame
    myGame.start = gameStart
    myGame.update = gameUpdate
    myGame.shutdown = gameShutdown
    myGame.name = "MyGame"
    dusk.run(&myGame)
}

MyGame :: struct {
    using game:dusk.Game,
    world:ecs.World,
}

DemoComponent :: struct {
    someData:u32,
}

demoSystem :: proc(game:^MyGame) {
    using self := game
    entities := ecs.queryComponents(&world, DemoComponent)
    for ent in entities {
        demoComp := ecs.getComponent(&world, ent, DemoComponent)
        demoComp.someData += 1
    }
}

logMyComponents :: proc(ud:any) {
    game := transmute(^MyGame)ud.data
    entities := ecs.queryComponents(&game.world, DemoComponent)
    for ent in entities {
        demoComp := ecs.getComponent(&game.world, ent, DemoComponent)
        log.info("[Example][DemoComponent] someData:", demoComp.someData)
    }
}

gameStart :: proc(game:^dusk.Game) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameStart")

    // Create some entities with the DemoComponent component
    for i in 0..<10 {
        ent := ecs.createEntity(&world)
        ecs.addComponent(&world, ent, DemoComponent{ someData = u32(i)})
    }

    // Log out the values of Entities with DemoComponent in 3 seconds
    delay.start(logMyComponents, 3, game)
    
    return true
}

gameUpdate :: proc(game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    demoSystem(self)
    return true
}

gameShutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameShutdown")
}
```
