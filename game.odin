/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import rl "vendor:raylib"

MAX_STATES :: 10

Game :: struct {
    name:string,

    settings:Settings,

    screen_size:[2]i32,
    virtual_resolution:[2]i32,

    clear_color:rl.Color,
    post_processing_shader:rl.Shader,
    use_post_processing_shader:bool,

    fps:int,

    music:rl.Music,

    states:[MAX_STATES]^State,
    state_count:i32,

    // Return false if something went and you would like to abort the launch of the game
    start:proc(self:^Game) -> bool,

    // Handle anything that needs to happen when the game shutsdowns like last minute saves
    shutdown:proc(self:^Game),
}

push_state :: proc(game:^Game, state:^State) -> bool {
    if game.state_count == MAX_STATES do return false
    if game.state_count > 0 && game.states[game.state_count-1].exit != nil do game.states[game.state_count-1]->exit(game)
    game.states[game.state_count] = state
    if state.enter != nil do state->enter(game)
    game.state_count += 1
    return true
}

pop_state :: proc(game:^Game) -> bool {
    if game.state_count == 0 do return false
    if game.states[game.state_count-1].exit != nil do game.states[game.state_count-1]->exit(game)
    game.states[game.state_count-1] = nil
    game.state_count -= 1
    return true
}