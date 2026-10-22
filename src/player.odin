package main

import rl "vendor:raylib"
import "core:math"

MAX_VEL :: 3000
ACCEL   :: 4000
DECEL   :: 50

Player :: struct {
	health: f32,
	body: Body
}

player_move :: proc(player: ^Player, input_dir: Vec2) {
	dir := input_dir
	len_sqr := rl.Vector2LengthSqr(dir)
	if len_sqr != 1.0 && len_sqr != 0.0	do dir = dir / math.sqrt(len_sqr)
	
	accel_towards(&player.body, ACCEL, MAX_VEL, dir)
}
