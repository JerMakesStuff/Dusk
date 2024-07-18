# Dusk

## Where are the updates?
I'm currently in the proccess of removing raylib and replacing it with my own rendering layer, this is taking longer than expected.

## What?

Dusk is a small game template / framework or whatever you want to call it.
I made it to make the start of a project more enjoyable for me.

## Features

* Abstracts away some of the boiler plate initialization and gameloop stuff.
* Virtual Resolutions
* Delayed procedure calls
* ECS (WIP)

## Roadmap

In no particular order here are some things I want to add.


* Some build in post processing with the option for custom stuff. IE. Scanlines
* Some prebuilt Components and Systems for doing standard stuff like drawing sprites.
* Scripting via lua
* Build in settings saving and loading for graphics and sound options

## Build the demo

To build the demo use `odin build ./demo -out:bin/demo.exe`
and then `.\bin\demo.exe` to run the demo

I've only tired this on windows so far i'll update this when i get a chance to test it on other platforms.

## How to use

- Clone dusk or download it as a zip
- You can also add it as a submodule to your project

## Minimal Example

see the [demo](demo/demo.odin) and [non ecs demo](demo_no_ecs/demo.odin) for a larger example

I'm providing a non ecs version of the example until i can get ecs performance up
So far in my testing my current implementation of ecs is about 10x slower than a non ecs implementation so something is definatly wrong with it.
```
package example

import "core:log"

import dusk "path/to/dusk"
import delay "path/to/dusk/delay"
WHITE :: dusk.Color{255, 255, 255, 255}

main :: proc() {
    myGame : MyGame
    myGame.start = gameStart
    myGame.update = gameUpdate
    myGame.render = gameRender
    myGame.shutdown = gameShutdown
    myGame.name = "MyGame"
    dusk.run(&myGame)
}

MyGame :: struct {
    using game:dusk.Game,
    testTexture:dusk.Texture2D,

    someData:[10]u32,
    imagePosition:dusk.Vector2,
}

logMyComponents :: proc(game:rawptr) {
    using self := transmute(^MyGame)game
    for data in someData {
        log.info("[Example] someData:", data)
    }
}

gameStart :: proc(game:^dusk.Game) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameStart")

    testTexture = dusk.LoadTexture("art/test.png")
    imagePosition = {20, 20} 

    for &data, i in someData{
        data = u32(i)
    }

    // Log out the values of someData in 3 seconds
    delay.start(logMyComponents, 3, self)
    
    return true
}

gameUpdate :: proc(game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    
    for &data in someData {
        data += 1
    }

    return true
}

gameRender :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^MyGame)game
    
    imgWidth : f32 = f32(testTexture.width)
    imgHeight : f32 = f32(testTexture.height)

    dusk.DrawTexturePro(testTexture, 
        dusk.Rectangle{0,0,imgWidth, imgHeight}, 
        dusk.Rectangle{imagePosition.x, imagePosition.y, imgWidth, imgHeight}, 
        dusk.V2ZERO, 0, WHITE)
}

gameShutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameShutdown")
}
```

Here is the ecs example
```Odin
package example

import "core:log"

import dusk "path/to/dusk"
import ecs "path/to/dusk/ecs"
import delay "path/to/dusk/delay"

WHITE :: dusk.Color{255, 255, 255, 255}

main :: proc() {
    myGame : MyGame
    myGame.start = gameStart
    myGame.update = gameUpdate
    myGame.render = gameRender
    myGame.shutdown = gameShutdown
    myGame.name = "MyGame"
    dusk.run(&myGame)
}

MyGame :: struct {
    using game:dusk.Game,
    world:ecs.World,
    testTexture:dusk.Texture2D,
}

DemoComponent :: struct {
    someData:u32,
}

TestImageComponent :: struct {
    position : dusk.Vector2
}

updateDemoComponents :: proc(game:^MyGame) {
    using self := game
    entities := ecs.query(&world, DemoComponent)
    for ent in entities {
        demoComp := ent.value1
        demoComp.someData += 1
    }
}

logMyComponents :: proc(ud:rawptr) {
    using self := transmute(^MyGame)ud
    entities := ecs.query(&world, DemoComponent)
    for ent in entities {
        demoComp := ent.value1
        log.info("[Example][DemoComponent] someData:", demoComp.someData)
    }
}

drawTestImageComponents :: proc(game:^MyGame) {
    using self := game
    imgWidth : f32 = f32(testTexture.width)
    imgHeight : f32 = f32(testTexture.height)
    images := ecs.query(&world, TestImageComponent)
    for image in images {
        position := image.value1.position
        dusk.DrawTexturePro(testTexture, 
            dusk.Rectangle{0,0,imgWidth,imgHeight}, 
            dusk.Rectangle{position.x, position.y, imgWidth, imgHeight}, 
            dusk.V2ZERO, 0, WHITE)
    }
}

gameStart :: proc(game:^dusk.Game) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameStart")

    testTexture = dusk.LoadTexture("art/test.png")

    imgEntity := ecs.createEntity(&world)
    ecs.addComponent(&world, imgEntity, TestImageComponent { position = {20, 20} })

    // Create some entities with the DemoComponent component
    for i in 0..<10 {
        ent := ecs.createEntity(&world)
        ecs.addComponent(&world, ent, DemoComponent{ someData = u32(i)})
    }

    // Log out the values of Entities with DemoComponent in 3 seconds
    delay.start(logMyComponents, 3, self)
    
    return true
}

gameUpdate :: proc(game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    updateDemoComponents(self)
    return true
}

gameRender :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^MyGame)game
    drawTestImageComponents(self)
}

gameShutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","gameShutdown")
}

```
