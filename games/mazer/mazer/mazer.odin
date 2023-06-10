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

current_dt   :  f64 = 0 // The number of seconds since last frame
current_theta:  f32 = 0 // A 1hz counter (range of [0,2PI])

font    : rl.Font

// TODO(trp): Move to player entity
position: rl.Vector2
size    : rl.Vector2
velocity: rl.Vector2

in_ultimate := false
invincible  := false
is_firing   := false
fire_rate   := f64(0.4)

Bullet :: struct {
    position: rl.Vector2,
    size    : rl.Vector2,
    velocity: rl.Vector2,
}

bullets : [dynamic]Bullet

run :: proc() {
    using rl
    
    HideCursor()

    size     = Vector2{ 25, 35 }
    velocity = Vector2{  0,  0 }
    position = Vector2{
        f32(WINDOW_WIDTH) / 2 - size.x / 2,
        f32(WINDOW_HEIGHT)    - size.y - 70 }
    
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
    is_firing = true
}

stop_firing :: proc() {
    is_firing = false
}

update :: proc() {
    update_player()
    update_bullets()
}

update_player :: proc() {
    position += velocity * MAX_PLAYER_VELOCITY * f32(current_dt)
    velocity *= 1 - PLAYER_DRAG * f32(current_dt)

    fire_rate = fire_rate - current_dt
    if fire_rate < 0 && is_firing {
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

update_bullets :: proc() {
    // TODO: Handle removal of bullets (and clean-up of their memory) once off screen (or colliding)
    for i := len(bullets) - 1; i >= 0; i -= 1 {
        b := &bullets[i]
        b.position += b.velocity * BULLET_VELOCITY * f32(current_dt)
    }
}