package main

import rl "vendor:raylib"

Shape :: enum{Rectangle}

Body :: struct {
	pos: Vec2,
	vel: Vec2,
	accel: Vec2,
	shape: Shape
}

// target_dir is assumed normalized
accel_towards :: proc(body: ^Body, accel, target_vel: f32, target_dir: Vec2) {
	if rl.Vector2LengthSqr(body.vel) >= target_vel * target_vel {
		body.accel = {0, 0}
		body.vel = rl.Vector2ClampValue(body.vel, 0.0, target_vel)
	}
	
	body.accel = accel * target_dir
}

integrate :: proc(body: ^Body, dt: f32) {
	body.vel += body.accel * dt
	body.pos += body.vel * dt
}
