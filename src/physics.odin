package main

import rl "vendor:raylib"

GRAVITY_ACCEL :: -9.81

Side :: enum { None, Left, Right, Top, Bottom }

Body :: struct {
	pos: Vec2,
	vel: Vec2,
	size: Vec2
}

integrate :: proc(body: ^Body, dt: f32) {
	body.vel.y += GRAVITY_ACCEL * dt
	body.pos += body.vel * dt
}

check_collision :: proc(a: ^Body, b: ^Body) -> (overlap: f32, side: Side, collided: bool) {
	// get the position of every edge of each body
	// compare their relative positions and conclude if they're intersecting each other
	// return if collided and collision information (overlap and side)

	le_a := a.pos.x - a.size.x / 2; re_a := le_a + a.size.x
	te_a := a.pos.y + a.size.y / 2; be_a := te_a - a.size.y

	le_b := b.pos.x - b.size.x / 2; re_b := le_b + b.size.x
	te_b := b.pos.y + b.size.y / 2; be_b := te_b - b.size.y

	a_is_right := le_a > re_b; a_is_left := re_a < le_b
	a_is_top := be_a > te_b; a_is_bottom := te_a < be_b

	if a_is_right || a_is_bottom || a_is_left || a_is_top do return 0, .None, false

	switch {
		case a_is_right
	}

	return 0, .Left, true
}
