package !@#PROJECT

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH  :: 1024
WINDOW_HEIGHT :: 768

FONT_SIZE :: 16
font: rl.Font

current_theta := f32(0) // A 1hz counter (range of [0,2PI])

run :: proc() {
    using rl
    
    HideCursor()
    
    font = LoadFont("fonts/8-bit.png")
    defer UnloadFont(font)

    tick := time.tick_now()
    current_dt := f64(0)
    for !WindowShouldClose() {
        elapsed   := time.tick_lap_time(&tick)
        current_dt = time.duration_seconds(elapsed)

        current_theta += f32(current_dt * math.TAU)
        current_theta  = (current_theta > math.TAU) ? 0 : current_theta

        handle_input()
        update(current_dt)
        draw()
    }
}

phase :: proc(hz: f32) -> f32 {
    return (math.cos(current_theta * hz) + 1) * 0.5
}

handle_input :: proc() {

}

update :: proc(current_dt: f64) {

}

draw :: proc() {
    using rl

    {
        BeginDrawing()
        defer EndDrawing()

        ClearBackground(BLACK)
    }
}