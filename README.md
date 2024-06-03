# Dusk

## Build the demo
To build the demo use `odin build ./demo -out:bin/demo.exe`
and then `.\bin\demo.exe` to run the demo

## How to use
- Clone dusk or download it as a zip
- You can alos add it as a submodule to your project

## Minimal Example
see [Demo](demo/demo.odin) for a larger example

```Odin
import "core:log"
import dusk "path/to/dusk"

main :: proc() {
    myGame : MyGame
    myGame.start = GameStart
    myGame.update = GameUpdate
    myGame.shutdown = GameShutdown
    myGame.name = "MyGame"
    dusk.run(&myGame)
}

MyGame :: struct {
    using game:dusk.Game,
}

GameStart :: proc(game:^dusk.Game) -> bool {
    using self:^MyGame = transmute(^MyGame)game
    log.info("[MyGame]","GameStart")
}

GameUpdate :: proc(game:^dusk.Game, deltTime:f32, runTime:f32) -> bool {
    using self:^MyGame = transmute(^MyGame)game
}

GameShutdown :: proc(game:^dusk.Game) {
    using self:^MyGame = transmute(^Demo)game
    log.info("[MyGame]","GameShutdown")
}

```