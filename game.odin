/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "vendor:raylib"

MAX_STATES :: 10

Game :: struct {
    name:string,
    backgroundColor:raylib.Color,
    music:raylib.Music,
    screenSize:raylib.Vector2,
    fps:int,
    virtualResolution:[2]i32,
    states:[MAX_STATES]^State,
    stateCount:i32,

    // Return false if something went and you would like to abort the launch of the game
    start:proc(self:^Game) -> bool,

    // Handle anything that needs to happen when the game shutsdowns like last minute saves
    shutdown:proc(self:^Game),
}

PushState :: proc(game:^Game, state:^State) -> bool {
    if game.stateCount == MAX_STATES do return false
    if game.stateCount > 0 && game.states[game.stateCount-1].exit != nil do game.states[game.stateCount-1]->exit(game)
    game.states[game.stateCount] = state
    if state.enter != nil do state->enter(game)
    game.stateCount += 1
    return true
}

PopState :: proc(game:^Game) -> bool {
    if game.stateCount == 0 do return false
    if game.states[game.stateCount-1].exit != nil do game.states[game.stateCount-1]->exit(game)
    game.states[game.stateCount-1] = nil
    game.stateCount -= 1
    return true
}