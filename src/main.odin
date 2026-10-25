package main

import rl "vendor:raylib"
Vec2 :: rl.Vector2

WIDTH  :: 800
HEIGHT :: 600

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)
	if WIDTH == 1920 && HEIGHT == 1080 do rl.ToggleFullscreen()

	cam: rl.Camera2D = {
		offset = {WIDTH / 2, HEIGHT / 2},
		target = {0, 0},
		rotation = 0,
		zoom = 20
	}

	player: Player = Player {body_make({0.8, 1.8}, {0, 0.9})}
	floor: Body = body_make({20, 2}, {0, -1}, is_dynamic = false)

	bodies := [?]^Body{&player.body, &floor}
	
	for !rl.WindowShouldClose() {
		input_dir := input_dir()
		dt := rl.GetFrameTime()

		move_player(&player.body, input_dir, dt)

		for body in bodies {
			if body.is_dynamic do integrate(body, dt)
		}

		for i := 0; i < len(bodies); i += 1 {
			for j := i + 1; j < len(bodies); j += 1 {
				handle_collisions(bodies[i], bodies[j])
			}
		}

		rl.BeginDrawing()
		rl.ClearBackground({45, 45, 45, 255})

		rl.BeginMode2D(cam)

		for body in bodies {
			rl.DrawRectangleV(rectangle_pos_at_center(body.pos, body.size), body.size, rl.WHITE)
		}

		rl.EndDrawing()
	}
}

input_dir :: proc() -> Vec2 {
	dir: Vec2 = {0, 0}
	if rl.IsKeyPressed(.W) || rl.IsKeyPressed(.SPACE) do dir += {0, 1}
	if rl.IsKeyReleased(.W) || rl.IsKeyReleased(.SPACE) do dir -= {0, 1}

	if rl.IsKeyDown(.A) do dir += {-1, 0}
	if rl.IsKeyReleased(.A) do dir -= {-1, 0}

	if rl.IsKeyDown(.D) do dir += {1, 0}
	if rl.IsKeyReleased(.D) do dir -= {1, 0}

	return dir
}

to_screen :: proc(v: Vec2) -> Vec2 {
	return {v.x, -v.y}
}

rectangle_pos_at_center :: proc(pos: Vec2, size: Vec2) -> Vec2 {
	return to_screen({pos.x - size.x / 2, pos.y + size.y / 2})
}
