package mazer

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH        :: 720
WINDOW_HEIGHT       :: 980
MAX_PLAYER_VELOCITY :: 300
PLAYER_DRAG         :: f32(7)
FONT_SIZE           :: 16
ABERRATION_SIZE     :: 5
ULT_FREQ            :: 3
RESPAWN_FREQ        :: 2

current_dt   : f64 = 0 // The number of seconds since last frame
current_theta: f32 = 0 // A 1hz counter (range of [0,2PI])
current_phase: f32 = 0 // The cos value of the current_theta in any given frame

font    : rl.Font
position: rl.Vector2
size    : rl.Vector2
velocity: rl.Vector2

// TODO: Turn into bit set
ult_active: bool = false
respawning: bool = false

run :: proc() {
    using rl
    
    size     = Vector2{ 25, 35 }
    velocity = Vector2{  0,  0 }
    position = Vector2{
        f32(WINDOW_WIDTH) / 2 - size.x / 2,
        f32(WINDOW_HEIGHT)    - size.y - 10
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

cos_freq :: proc(freq_mult: f32) -> f32 {
    return (math.cos(current_theta * freq_mult) + 1) * 0.5
}

// HACK: Remove once not needed (this is just for prototyping)
state_timer := 2.0

handle_input :: proc() {
    using rl
    
    if IsKeyDown(KeyboardKey.RIGHT) do velocity.x =  1
    if IsKeyDown(KeyboardKey.LEFT)  do velocity.x = -1
    if IsKeyDown(KeyboardKey.UP)    do velocity.y = -1
    if IsKeyDown(KeyboardKey.DOWN)  do velocity.y =  1

    // TODO: Change to key presses for these controls
    state_timer -= current_dt
    if IsKeyDown(KeyboardKey.R) && state_timer <= 0 {
        state_timer = 2.0
        ult_active = !ult_active
    }
    if IsKeyDown(KeyboardKey.T) && state_timer <= 0{
        state_timer = 2.0
        respawning = !respawning
    }
}

update :: proc() {
    position += velocity * MAX_PLAYER_VELOCITY * f32(current_dt)
    velocity *= 1 - PLAYER_DRAG * f32(current_dt)
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
    }
}

draw_player :: proc() {
    using rl

    if ult_active {
        {
            BeginBlendMode(BlendMode.ADDITIVE)
            defer EndBlendMode()

            aberration := cos_freq(ULT_FREQ) * ABERRATION_SIZE
            DrawRectangle(i32(position.x - aberration), i32(position.y - aberration),
                            i32(size.x), i32(size.y),
                            BLUE)
            DrawRectangle(i32(position.x), i32(position.y),
                            i32(size.x), i32(size.y),
                            GREEN)
            DrawRectangle(i32(position.x + aberration), i32(position.y + aberration),
                            i32(size.x), i32(size.y),
                            RED)
        }
    } else if respawning {
        theta := u8(cos_freq(RESPAWN_FREQ) * 255)
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
    x: f32 = FONT_SIZE * 36 + (FONT_SIZE * 0.5)
    y: f32 = 16.0
    rl.DrawTextEx(font, "Score", rl.Vector2{x, y}, FONT_SIZE, 0, rl.WHITE)

    x = FONT_SIZE * 35.0
    y = 16 + FONT_SIZE * 2.0
    rl.DrawTextEx(font, "00000000", rl.Vector2{x, y}, FONT_SIZE, 0, rl.GRAY)
}

draw_high_score :: proc() {
    rl.DrawTextEx(font, "High Score", rl.Vector2{ 16, 16 }, FONT_SIZE, 0, rl.WHITE)

    x: f32 = 16 + FONT_SIZE
    y: f32 = 16 + FONT_SIZE * 2
    rl.DrawTextEx(font, "00000000", rl.Vector2{ x, y }, FONT_SIZE, 0, rl.GRAY)
}