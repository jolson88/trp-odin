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

font : rl.Font
cells: [ROWS * COLUMNS]int

run :: proc() {
    using rl
    
    HideCursor()
    
    font = LoadFont("fonts/8-bit.png")
    defer UnloadFont(font)

    game_init()

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

cell_get :: proc(row, col: int) -> int {
    return cells[row * col + col]
}

cell_set :: proc(row, col, val: int) {
    cells[row * col + col] = val
}

game_init :: proc() {
    for _, i in cells {
        cells[i] = 0
    }

    start_row := ROWS    * 0.5 + rl.GetRandomValue(-5, 5)
    start_col := COLUMNS * 0.5 + rl.GetRandomValue(-5, 5)
    cell_set(int(start_row), int(start_col), 1)
}

handle_input :: proc() {
    using rl
    
    if IsKeyPressed(KeyboardKey.F1) do show_debug = !show_debug
}

update :: proc(current_dt: f64) {

}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.BLACK)

    draw_cells()
    draw_grid()
}

draw_cells :: proc() {
    for row in 0..<ROWS {
        for column in 0..<COLUMNS {
            c := rl.BLACK
            life := cell_get(row, column)
            if (life > 0) do c = rl.WHITE

            x := BOARD_START_X + column * CELL_SIZE
            y := BOARD_START_Y + row * CELL_SIZE
            rl.DrawRectangle(i32(x), i32(y), CELL_SIZE, CELL_SIZE, c)
        }
    }
}

draw_grid :: proc() {
    x := i32(BOARD_START_X)
    y := i32(BOARD_START_Y)
    for i in 0..=COLUMNS {
        rl.DrawLine(x, y, x, y + ROWS * CELL_SIZE, rl.GRAY)
        x += CELL_SIZE
    }

    x = BOARD_START_X
    y = BOARD_START_Y
    for i in 0..=ROWS {
        rl.DrawLine(x, y, x + COLUMNS * CELL_SIZE, y, rl.GRAY)
        y += CELL_SIZE
    }

    rl.DrawRectangleLines(BOARD_START_X,
        BOARD_START_Y, 
        COLUMNS * CELL_SIZE,
        ROWS * CELL_SIZE,
        rl.GREEN)
}