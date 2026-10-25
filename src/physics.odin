package main

import "core:math"
import rl "vendor:raylib"

GRAVITY_ACCEL :: -9.81

Side :: enum { None, Left, Right, Top, Bottom }

Body :: struct {
	pos: Vec2,
	vel: Vec2,
	size: Vec2,
	is_dynamic: bool,
}

integrate :: proc(body: ^Body, dt: f32) {
	body.vel.y += GRAVITY_ACCEL * dt
	body.pos += body.vel * dt
}

handle_collisions :: proc(a: ^Body, b: ^Body) {
	overlap, side, collided := check_collision(a, b)
	if collided do resolve_collision(a, b, overlap, side)
}

check_collision :: proc(a: ^Body, b: ^Body) -> (overlap: f32, side: Side, collided: bool) {
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

resolve_collision :: proc(a: ^Body, b: ^Body, overlap: f32, side: Side) {
	switch {
	case a.is_dynamic && !b.is_dynamic:
		dir: Vec2
		#partial switch side {
		case .Left:
			dir = {-1, 0}
			a.vel.x = -a.vel.x
		case .Right:
			dir = {1, 0}
			a.vel.x = -a.vel.x
		case .Top:
			dir = {0, 1}
			a.vel.y = -a.vel.y
		case .Bottom:
			dir = {0, -1}
			a.vel.y = -a.vel.y
		}

		a.pos += dir * overlap
	case !a.is_dynamic && b.is_dynamic:
		dir: Vec2
		#partial switch side {
		case .Left:
			dir = {-1, 0}
			b.vel.x = -b.vel.x
		case .Right:
			dir = {1, 0}
			b.vel.x = -b.vel.x
		case .Top:
			dir = {0, 1}
			b.vel.y = -b.vel.y
		case .Bottom:
			dir = {0, -1}
			b.vel.y = -b.vel.y
		}

		b.pos -= dir * overlap
	case a.is_dynamic && b.is_dynamic:
		dir: Vec2
		#partial switch side {
		case .Left:
			dir = {-1, 0}
			b.vel.x = -b.vel.x
			a.vel.x = -a.vel.x
		case .Right:
			dir = {1, 0}
			b.vel.x = -b.vel.x
			a.vel.x = -a.vel.x
		case .Top:
			dir = {0, 1}
			b.vel.y = -b.vel.y
			a.vel.y = -a.vel.y
		case .Bottom:
			dir = {0, -1}
			b.vel.y = -b.vel.y
			a.vel.y = -a.vel.y
		}

		a.pos += dir * overlap * 0.5
		b.pos -= dir * overlap * 0.5
	}
}
