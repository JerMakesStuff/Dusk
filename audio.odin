package dusk

import rl "vendor:raylib"

play_sfx :: proc(game:^Game, sfx:rl.Sound) {
    rl.SetSoundVolume(sfx, cast(f32)(game.settings.sfx_volume * game.settings.master_volume))
    rl.PlaySound(sfx)
}

play_music :: proc(game:^Game, music:rl.Music) {
    if rl.IsMusicStreamPlaying(music) {
        return
    }
    if rl.IsMusicStreamPlaying(game.music) {
        rl.StopMusicStream(game.music)
    }
    game.music = music
    rl.SetMusicVolume(game.music, cast(f32)(game.settings.music_volume * game.settings.master_volume))
    rl.PlayMusicStream(game.music)
}