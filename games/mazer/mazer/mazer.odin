package mazer

import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH        :: 720
WINDOW_HEIGHT       :: 980
MAX_PLAYER_VELOCITY :: 300
PLAYER_DRAG         :: f32(7)
FONT_SIZE           :: 16

current_dt: f64 = 0

font:     rl.Font
position: rl.Vector2
size:     rl.Vector2
velocity: rl.Vector2

run :: proc() {
    using rl
    
    size     = Vector2{ 25, 35 }
    velocity = Vector2{ 0, 0 }
    position = Vector2{
        f32(WINDOW_WIDTH) / 2 - size.x / 2,
        f32(WINDOW_HEIGHT) - size.y - 10
    }
    
    font = LoadFont("fonts/son-of-phoenix.png")
    defer UnloadFont(font)
    
    tick := time.tick_now()
    for !WindowShouldClose() {
        PollInputEvents()
        
        elapsed   := time.tick_lap_time(&tick)
        current_dt = time.duration_seconds(elapsed)
        
        handle_input()
        simulate()
        render()
    }
}

handle_input :: proc() {
    using rl
    
    if IsKeyDown(KeyboardKey.RIGHT) do velocity.x =  1
    if IsKeyDown(KeyboardKey.LEFT)  do velocity.x = -1
    if IsKeyDown(KeyboardKey.UP)    do velocity.y = -1
    if IsKeyDown(KeyboardKey.DOWN)  do velocity.y =  1
}

simulate :: proc() {
    position += velocity * MAX_PLAYER_VELOCITY * f32(current_dt)
    velocity *= 1 - PLAYER_DRAG * f32(current_dt)
}

render :: proc() {
    using rl
    
    {
        BeginDrawing()
        defer EndDrawing()
        ClearBackground(BLACK)
        
        DrawRectangle(i32(position.x), i32(position.y), i32(size.x), i32(size.y), GREEN)
        
        DrawTextEx(font, "Score",
                   Vector2{FONT_SIZE * 36 + (FONT_SIZE * 0.5), 16},
                   FONT_SIZE, 0, WHITE)
        DrawTextEx(font, "00000000",
                   Vector2{FONT_SIZE * 35, 16 + FONT_SIZE * 2},
                   FONT_SIZE, 0, GRAY)
        DrawTextEx(font, "High Score",
                   Vector2{ 16, 16 },
                   FONT_SIZE, 0, WHITE)
        DrawTextEx(font, "00000000",
                   Vector2{ 16 + FONT_SIZE, 16 + FONT_SIZE * 2 },
                   FONT_SIZE, 0, GRAY)
        
        {
            BeginBlendMode(BlendMode.ADDITIVE)
            defer EndBlendMode()
            
            ABERRATION_SIZE :: 3
            
            DrawRectangle(i32(position.x) - ABERRATION_SIZE,
                          i32(position.y - ABERRATION_SIZE),
                          i32(size.x), i32(size.y),
                          BLUE)
            DrawRectangle(i32(position.x), i32(position.y),
                          i32(size.x), i32(size.y),
                          GREEN)
            DrawRectangle(i32(position.x) + ABERRATION_SIZE,
                          i32(position.y + ABERRATION_SIZE),
                          i32(size.x), i32(size.y),
                          RED)
        }
    }
}