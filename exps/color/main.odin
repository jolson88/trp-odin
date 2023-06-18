package main

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH  :: 800
WINDOW_HEIGHT :: 800
BOARD_START_X :: 20
BOARD_START_Y :: 20
CELL_SIZE     :: 16
ROWS          :: 38
COLUMNS       :: 38
PADDING       :: 4

current_theta := f32(0) // A 1hz counter (range of [0,2PI])

start_h := 10
start_s := 170
start_v := 240
final_h := 180
final_s := 230
final_v := 240

main :: proc() {
    rl.InitWindow(i32(WINDOW_WIDTH), i32(WINDOW_HEIGHT), "HSV");
    defer rl.CloseWindow();
    
    tick := time.tick_now()
    current_dt := f64(0)
    for !rl.WindowShouldClose() {
        elapsed   := time.tick_lap_time(&tick)
        current_dt = time.duration_seconds(elapsed)

        current_theta += f32(current_dt * math.TAU)

        handle_input()
        update(current_dt)
        draw()
    }
}

phase :: proc(hz: f32, offset: f32 = 0) -> f32 {
    return (math.cos((current_theta + offset) * hz) + 1) * 0.5
}

handle_input :: proc() {
    using rl
    
    //if IsKeyPressed(KeyboardKey.F1) do show_debug = !show_debug
}

update :: proc(current_dt: f64) {

}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.BLACK)

    for row in 0..<ROWS {
        for column in 0..<COLUMNS {
            t := (f32(row) / f32(ROWS) + f32(column) / f32(COLUMNS)) * 0.5

            h := math.lerp(f32(start_h), f32(final_h), t)
            s := math.lerp(f32(start_s), f32(final_s), t)
            v := math.lerp(f32(start_v), f32(final_v), t)
            x := BOARD_START_X + column * CELL_SIZE + column * PADDING
            y := BOARD_START_Y + row * CELL_SIZE + row * PADDING
            
            size := math.lerp(f32(4), f32(CELL_SIZE), phase(0.5, t * math.TAU))
            offset := (CELL_SIZE - size) * 0.5
            rl.DrawRectangle(i32(f32(x) + offset), i32(f32(y) + offset), i32(size), i32(size), rl.ColorFromHSV(h, s / 255, v / 255))
        }
    }
}
