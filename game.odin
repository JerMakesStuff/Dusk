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

    // Return false if something went and you would like to abort the launch of the game
    start:proc(self:^Game) -> bool,

    // Return false if you would like to close the game.
    update:proc(self:^Game, deltaTime:f32, runTime:f32) -> bool,

    // This is called right before we render and after all the other
    // update stuff
    lateUpdate:proc(self:^Game, deltaTime:f32, runTime:f32),

    // This is called first thing after we clear the background.
    render:proc(self:^Game),

    // This is called after we render everything to the renderTexture but before we
    // draw the render textrure to the frame buffer.
    postRender:proc(self:^Game),

    // Handle anything that needs to happen when the game shutsdowns like last minute saves
    shutdown:proc(self:^Game),
}