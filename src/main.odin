package main

import "core:fmt"
import rl "vendor:raylib"
Vec2 :: rl.Vector2

WIDTH ::  800
HEIGHT :: 600

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(180)
	if WIDTH == 1920 && HEIGHT == 1080 do rl.ToggleFullscreen()

	cam: rl.Camera2D = {
		offset = {WIDTH / 2, HEIGHT / 2},
		target = {0, 0},
		rotation = 0,
		zoom = 20
	}

	player: Player = Player {{{0, 0}, {0, 0}, {0.6, 1.8}}}
	p2: Player = Player {{{0, 0}, {0, 0}, {0.5, 0.5}}}
	floor: Body = Body {{0, -5}, {0, 0}, {20, 2}}

	bodies := [?]^Body{&floor, &player.body, &p2.body}
	
	for !rl.WindowShouldClose() {
		dir := input_dir()
		dt := rl.GetFrameTime()

		mouse_pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), cam)
		p2.body.pos = {mouse_pos.x, -mouse_pos.y}

		// integrate(&player.body, dt)

		rl.BeginDrawing()
		rl.ClearBackground({45, 45, 45, 255})

		rl.BeginMode2D(cam)

		for i := 0; i < len(bodies); i += 1 {
			collided := false
			overlap: f32
			side: Side
			a := bodies[i]
			for j := i + 1; j < len(bodies); j += 1 {
				b := bodies[j]
				overlap, side, collided = check_collision(a, b)
			}
			if collided {
				rl.DrawRectangleV(rectangle_pos_at_center(a.pos, a.size), a.size, rl.RED)
				fmt.printfln("overlap: {},\nside: {}\n", overlap, side)
			} else {
				rl.DrawRectangleV(rectangle_pos_at_center(a.pos, a.size), a.size, rl.WHITE)
			}
		}

		rl.EndDrawing()
	}
}

input_dir :: proc() -> Vec2 {
	dir: Vec2 = {0, 0}
	if rl.IsKeyDown(.S) do dir += {0, -1}
	if rl.IsKeyReleased(.S) do dir -= {0, -1}

	if rl.IsKeyDown(.W) do dir += {0, 1}
	if rl.IsKeyReleased(.W) do dir -= {0, 1}

	if rl.IsKeyDown(.A) do dir += {-1, 0}
	if rl.IsKeyReleased(.A) do dir -= {-1, 0}

	if rl.IsKeyDown(.D) do dir += {1, 0}
	if rl.IsKeyReleased(.D) do dir -= {1, 0}

	return rl.Vector2Normalize(dir)
}

to_screen :: proc(v: Vec2) -> Vec2 {
	return {v.x, -v.y}
}

rectangle_pos_at_center :: proc(pos: Vec2, size: Vec2) -> Vec2 {
	return to_screen({pos.x - size.x / 2, pos.y + size.y / 2})
}
