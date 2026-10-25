package main

import "core:math/linalg"
import "core:math"
import rl "vendor:raylib"

GRAVITY_ACCEL :: -9.81

Side :: enum { None, Left, Right, Top, Bottom }

Body :: struct {
	size: Vec2,
	pos: Vec2,
	vel: Vec2,
	restitution: f32,
	inv_mass: f32,
}

body_make :: proc(size, pos: Vec2, vel: Vec2 = {0, 0}, restitution: f32 = 0.7, mass: f32 = 0) -> Body {
	return Body {
		size        = size,
		pos         = pos,
		vel         = vel,
		restitution = restitution,
		inv_mass    = 1 / mass if mass > 0 else 0
	}
}

integrate :: proc(body: ^Body, dt: f32) {
	body.vel.y += GRAVITY_ACCEL * dt
	body.pos += body.vel * dt
}

handle_collisions :: proc(a, b: ^Body) {
	overlap, side, collided := check_collision(a, b)
	if collided do resolve_collision(a, b, overlap, side)
}

check_collision :: proc(a, b: ^Body) -> (overlap: f32, side: Side, collided: bool) {
	// get the position of every edge of each body
	// compare their relative positions and conclude if they're intersecting each other
	// return if collided and collision information (overlap and side)

	le_a := a.pos.x - a.size.x / 2; re_a := le_a + a.size.x
	te_a := a.pos.y + a.size.y / 2; be_a := te_a - a.size.y

	le_b := b.pos.x - b.size.x / 2; re_b := le_b + b.size.x
	te_b := b.pos.y + b.size.y / 2; be_b := te_b - b.size.y

	overlap_x := math.min(re_a, re_b) - math.max(le_a, le_b)
	overlap_y := math.min(te_a, te_b) - math.max(be_a, be_b)

	if overlap_x > 0 && overlap_y > 0 {
		min_overlap := overlap_x if overlap_x < overlap_y else overlap_y
		side: Side
		if min_overlap == overlap_x {
			side = .Right if a.pos.x > b.pos.x else .Left
		} else {
			side = .Top if a.pos.y > b.pos.y else .Bottom
		}
		return min_overlap, side, true
	}

	return 0, .None, false
}

resolve_collision :: proc(a, b: ^Body, overlap: f32, side: Side) {
	// normal is a <- b
	n := side_to_dir(side)
	vn := linalg.dot(a.vel - b.vel, n)
	e := math.max(a.restitution, b.restitution)

	j := -(1 + e) * vn / (a.inv_mass + b.inv_mass)
	impulse := j * n

	a.vel += impulse * a.inv_mass
	b.vel -= impulse * b.inv_mass
}

side_to_dir :: proc(side: Side) -> Vec2 {
	switch side {
	case .None: return {0, 0}
	case .Left: return {-1, 0}
	case .Right: return {1, 0}
	case .Top: return {0, 1}
	case .Bottom: return {0, -1}
	}
	unreachable()
}
