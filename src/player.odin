package main

import "core:math"

Player :: struct {
	body: Body
}

MAX_SPEED :: 20
ACCEL :: 400

move_player :: proc(body: ^Body, wish_dir: Vec2, dt: f32) {
	current_vel := body.vel.x
	target_vel := wish_dir.x * MAX_SPEED
	max_delta := ACCEL * dt

	if math.abs(target_vel - current_vel) <= max_delta {
		body.vel.x = target_vel
	} else {
		body.vel.x = current_vel + math.sign(target_vel - current_vel) * max_delta
	}

	if wish_dir.y > 0 {
		body.vel.y = 10
	}
}
