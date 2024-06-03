/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package dusk

import "vendor:raylib"

Game :: struct {
    name:string,
    backgroundColor:raylib.Color,
    music:raylib.Music,
    screenSize:raylib.Vector2,

    /// Return false if something went and you would like to abort the launch of the game
    start:proc(self:^Game) -> bool,

    /// Return false if you would like to close the game.
    update:proc(self:^Game, deltaTime:f32, runTime:f32) -> bool,

    /// Handle anything that needs to happen when the game shutsdowns like last minute saves
    shutdown:proc(self:^Game),
}