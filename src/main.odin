package game

import rl "vendor:raylib"

Vec2 :: rl.Vector2

WIDTH :: 1920
HEIGHT :: 1080

Player :: struct {
	health: f32,
	pos: Vec2,
	vel: Vec2
}

player_move :: proc(player: ^Player, dt: f32) {
	player.pos += player.vel * dt
}

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

	player: Player = Player{health = 10.0, pos = Vec2{0.0, 0.0}, vel = Vec2{100.0, 0.0}}
	
	for !rl.WindowShouldClose() {
		player_move(&player, rl.GetFrameTime())

		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		rl.BeginMode2D(cam)
		rl.DrawCircleV(player.pos, 5.0, rl.BLUE)

		rl.EndDrawing()
	}
}
