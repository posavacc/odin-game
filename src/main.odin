package main

import "core:fmt"
import rl "vendor:raylib"
Vec2 :: rl.Vector2

WIDTH ::  600
HEIGHT :: 400

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(180)
	if WIDTH == 1920 && HEIGHT == 1080 do rl.ToggleFullscreen()

	cam: rl.Camera2D = {
		offset = {WIDTH / 2, HEIGHT / 2},
		target = {0, 0},
		rotation = 0,
		zoom = 1
	}

	player: Player = Player{10.0, {{0, 0}, {0, 0}, {0, 0}, Shape.Rectangle}}
	
	for !rl.WindowShouldClose() {
		dir := input_dir()

		dt := rl.GetFrameTime()

		player_move(&player, dir)
		integrate(&player.body, dt)

		fmt.printfln("speed: {}\naccel: {}", rl.Vector2Length(player.body.vel), rl.Vector2Length(player.body.accel))

		rl.BeginDrawing()
		rl.ClearBackground({45, 45, 45, 255})

		rl.BeginMode2D(cam)
		rl.DrawRectangleV({-500, 0}, {1000, 100}, rl.GRAY)
		rl.DrawCircleV(to_screen(player.body.pos), 10.0, rl.BLUE)

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
