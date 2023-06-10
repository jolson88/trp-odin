package znake

import "core:fmt"
import "core:math"
import "core:time"
import rl "vendor:raylib"

WINDOW_WIDTH  :: 1024
WINDOW_HEIGHT :: 768
FONT_SIZE     :: 16
DEBUG_COLOR   :: rl.MAGENTA

BOARD_START_X :: 388
BOARD_START_Y :: 30
CELL_SIZE     :: 16
ROWS          :: 44
COLUMNS       :: 38

current_theta := f32(0) // A 1hz counter (range of [0,2PI])
show_debug    := false

font: rl.Font

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
    using rl
    
    if IsKeyPressed(KeyboardKey.F1) do show_debug = !show_debug
}

update :: proc(current_dt: f64) {

}

draw :: proc() {
    using rl

    {
        BeginDrawing()
        defer EndDrawing()
        ClearBackground(BLACK)

        draw_board()

        if show_debug do draw_debug()
    }
}

draw_board :: proc() {
    using rl
    
    for row in 0..<ROWS {
        for column in 0..<COLUMNS {
            r := GetRandomValue(0, 255)
            g := GetRandomValue(0, 255)
            b := GetRandomValue(0, 255)
            c := Color{ u8(r), u8(g), u8(b), 255 }
            
            x := BOARD_START_X + column * CELL_SIZE
            y := BOARD_START_Y + row * CELL_SIZE
            DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, c)
        }
    }

    DrawRectangleLines(BOARD_START_X,
        BOARD_START_Y, 
        COLUMNS * CELL_SIZE,
        ROWS * CELL_SIZE,
        GREEN)
}

draw_debug :: proc() {
    using rl

    x := i32(BOARD_START_X)
    y := i32(BOARD_START_Y)
    for i in 0..=COLUMNS {
        DrawLine(x, y, x, y + ROWS * CELL_SIZE, DEBUG_COLOR)
        x += CELL_SIZE
    }

    x = BOARD_START_X
    y = BOARD_START_Y
    for i in 0..=ROWS {
        DrawLine(x, y, x + COLUMNS * CELL_SIZE, y, DEBUG_COLOR)
        y += CELL_SIZE
    }
}