package mazer

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH        :: 720
WINDOW_HEIGHT       :: 980
MAX_PLAYER_VELOCITY :: 300
BULLET_VELOCITY     :: 400
PLAYER_DRAG         :: f32(7)
FONT_SIZE           :: 16
ABERRATION_SIZE     :: 5
ULT_FREQ            :: 3
RESPAWN_FREQ        :: 2

Player_Flags :: enum {Ultimate, Respawning, Firing}

current_dt   :  f64 = 0 // The number of seconds since last frame
current_theta:  f32 = 0 // A 1hz counter (range of [0,2PI])
player_state :  bit_set[Player_Flags]

font    : rl.Font

// TODO(trp): Move to player entity
position: rl.Vector2
size    : rl.Vector2
velocity: rl.Vector2
fire_rate := f64(0.4)

Bullet :: struct {
    position: rl.Vector2
    size    : rl.Vector2
    velocity: rl.Vector2
}

bullets : [dynamic]Bullet

run :: proc() {
    using rl
    
    HideCursor()

    size     = Vector2{ 25, 35 }
    velocity = Vector2{  0,  0 }
    position = Vector2{
        f32(WINDOW_WIDTH) / 2 - size.x / 2,
        f32(WINDOW_HEIGHT)    - size.y - 70
    }
    
    font = LoadFont("fonts/son-of-phoenix.png")
    defer UnloadFont(font)

    tick := time.tick_now()
    for !WindowShouldClose() {
        PollInputEvents()
        
        elapsed   := time.tick_lap_time(&tick)
        current_dt = time.duration_seconds(elapsed)

        current_theta += f32(current_dt * math.TAU)
        current_theta  = (current_theta > math.TAU) ? 0 : current_theta

        handle_input()
        update()
        draw()
    }
}

phase :: proc(hz: f32) -> f32 {
    return (math.cos(current_theta * hz) + 1) * 0.5
}


handle_input :: proc() {
    using rl
    
    if IsKeyDown(KeyboardKey.RIGHT) do move_right()
    if IsKeyDown(KeyboardKey.LEFT)  do move_left()
    if IsKeyDown(KeyboardKey.SPACE) do start_firing()
    if IsKeyUp(KeyboardKey.SPACE)   do stop_firing()
}

move_right :: proc() {
    velocity.x = 1
}

move_left :: proc() {
    velocity.x = -1
}

start_firing :: proc() {
    player_state += {.Firing}
}

stop_firing :: proc() {
    player_state -= {.Firing}
}

update :: proc() {
    update_player()
    update_bullets()
}

update_player :: proc() {
    position += velocity * MAX_PLAYER_VELOCITY * f32(current_dt)
    velocity *= 1 - PLAYER_DRAG * f32(current_dt)

    fire_rate = fire_rate - current_dt
    if fire_rate < 0 && player_is(.Firing) {
        // TODO(trp): Extract to fire_bullet function
        b := Bullet{
            position = rl.Vector2{ position.x + size.x / 2, position.y },
            velocity = rl.Vector2{ 0, -1 },
            size = rl.Vector2{ 6, 6 },
        }
        append(&bullets, b)
        
        fire_rate = 0.4
    }
}

player_is :: proc(f: Player_Flags) -> bool {
    return f in player_state
}

update_bullets :: proc() {
    // TODO: Handle removal of bullets (and clean-up of their memory) once off screen (or colliding)
    for i := len(bullets) - 1; i >= 0; i -= 1 {
        b := &bullets[i]
        b.position += b.velocity * BULLET_VELOCITY * f32(current_dt)
    }
}

draw :: proc() {
    using rl
    
    {
        BeginDrawing()
        defer EndDrawing()
        ClearBackground(BLACK)
        
        draw_player_score()
        draw_high_score()
        draw_player()
        draw_bullets()
    }
}

draw_bullets :: proc() {
    for _, i in bullets {
        draw_bullet(&bullets[i])
    }
}

draw_bullet :: proc(bullet: ^Bullet) {
    using rl

    DrawRectangle(i32(bullet.position.x), i32(bullet.position.y),
                    i32(bullet.size.x), i32(bullet.size.y),
                    WHITE)
}

draw_player :: proc() {
    using rl

    if player_is(.Ultimate) {

        BeginBlendMode(BlendMode.ADDITIVE)

        aberration := phase(ULT_FREQ) * ABERRATION_SIZE
        DrawRectangle(i32(position.x - aberration), i32(position.y - aberration),
                        i32(size.x), i32(size.y),
                        BLUE)
        DrawRectangle(i32(position.x), i32(position.y),
                        i32(size.x), i32(size.y),
                        GREEN)
        DrawRectangle(i32(position.x + aberration), i32(position.y + aberration),
                        i32(size.x), i32(size.y),
                        RED)

        EndBlendMode()

    } else if player_is(.Respawning) {

        theta := u8(phase(RESPAWN_FREQ) * 255)
        DrawRectangle(i32(position.x), i32(position.y),
                        i32(size.x), i32(size.y),
                        Color{ 255, 255-theta, 255-theta, 255})

    } else {

        DrawRectangle(i32(position.x), i32(position.y),
                        i32(size.x), i32(size.y),
                        WHITE)
    }
}

draw_player_score :: proc() {
    using rl

    x: f32 = FONT_SIZE * 36 + (FONT_SIZE * 0.5)
    y: f32 = 16.0
    DrawTextEx(font, "Score", Vector2{x, y}, FONT_SIZE, 0, WHITE)

    x = FONT_SIZE * 35.0
    y = 16 + FONT_SIZE * 2.0
    DrawTextEx(font, "00000000", Vector2{x, y}, FONT_SIZE, 0, GRAY)
}

draw_high_score :: proc() {
    using rl

    DrawTextEx(font, "High Score", Vector2{ 16, 16 }, FONT_SIZE, 0, WHITE)

    x: f32 = 16 + FONT_SIZE
    y: f32 = 16 + FONT_SIZE * 2
    DrawTextEx(font, "00000000", Vector2{ x, y }, FONT_SIZE, 0, GRAY)
}