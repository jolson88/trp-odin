package main

import "core:fmt"
import mu "vendor:microui"
import rl "vendor:raylib"

WIDTH  :: 1024
HEIGHT :: 768

mu_ctx: mu.Context

main :: proc() {
    rl.InitWindow(i32(WIDTH), i32(HEIGHT), "microui demo")
    defer rl.CloseWindow()
    
    ctx := mu.Context{}
    mu.init(&ctx)
    
    ctx.text_width = mu.default_atlas_text_width
    ctx.text_height = mu.default_atlas_text_height

    for !rl.WindowShouldClose() {
        mu.begin(&ctx)
        all_windows(&ctx)
        mu.end(&ctx)

        render(&ctx)
    }
}

render :: proc(ctx: ^mu.Context) {
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.GRAY)
    
    command_backing: ^mu.Command
    for variant in mu.next_command_iterator(ctx, &command_backing) {
        #partial switch cmd in variant {
            case ^mu.Command_Rect:
                using cmd.rect, cmd.color
                rl.DrawRectangle(x, y, w, h, rl.Color{ r, g, b, a })
        }
    }
}

all_windows :: proc(ctx: ^mu.Context) {
    @static opts := mu.Options{ .NO_CLOSE }
    
    if mu.window(ctx, "My Window", {10, 10, 400, 300}, opts) {
        mu.layout_row(ctx, { 60, -1 }, 0)
        
        mu.label(ctx, "First:")
        if .SUBMIT in mu.button(ctx, "Button1") {
            fmt.println("Button1 Pressed")
        }

        mu.label(ctx, "Second:")
        if .SUBMIT in mu.button(ctx, "Button2") {
            mu.open_popup(ctx, "My Popup")
        }

        if mu.begin_popup(ctx, "My Popup") {
            mu.label(ctx, "Hello World!")
            mu.end_popup(ctx)
        }
    }
}