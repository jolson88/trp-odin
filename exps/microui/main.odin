package main

import "core:fmt"
import mu "vendor:microui"
import rl "vendor:raylib"

WIDTH  :: 1024
HEIGHT :: 768

mu_ctx: mu.Context
atlas_texture: rl.Texture2D

main :: proc() {
    rl.InitWindow(i32(WIDTH), i32(HEIGHT), "microui demo")
    defer rl.CloseWindow()
    
    ctx := mu.Context{}
    mu.init(&ctx)
    
    ctx.text_width = mu.default_atlas_text_width
    ctx.text_height = mu.default_atlas_text_height

    pixels := make([][4]u8, mu.DEFAULT_ATLAS_WIDTH * mu.DEFAULT_ATLAS_HEIGHT)
    for alpha, i in mu.default_atlas_alpha {
        pixels[i].rgb = 0xff
        pixels[i].a   = alpha
    }

    atlas_image := rl.Image{
        data = raw_data(pixels),
        width = mu.DEFAULT_ATLAS_WIDTH,
        height = mu.DEFAULT_ATLAS_HEIGHT,
        mipmaps = 1,
        format = rl.PixelFormat.UNCOMPRESSED_R8G8B8A8,
    }
    
    atlas_texture = rl.LoadTextureFromImage(atlas_image)
    
    for !rl.WindowShouldClose() {
        // Handle input
        mouse_x := i32(rl.GetMouseX())
        mouse_y := i32(rl.GetMouseY())
        mu.input_mouse_move(&ctx, mouse_x, mouse_y)

        if rl.IsMouseButtonPressed(.LEFT)  do mu.input_mouse_down(&ctx, mouse_x, mouse_y, .LEFT)
        if rl.IsMouseButtonReleased(.LEFT) do mu.input_mouse_up(&ctx, mouse_x, mouse_y, .LEFT)
        
        // Rendering
        mu.begin(&ctx)
        all_windows(&ctx)
        mu.end(&ctx)

        render(&ctx)
    }
}

render :: proc(ctx: ^mu.Context) {
    render_texture :: proc(texture: rl.Texture2D, src: mu.Rect, dst: mu.Vec2, color: mu.Color) {
        rl.DrawTextureRec(texture,
            rl.Rectangle{ f32(src.x), f32(src.y), f32(src.w), f32(src.h) },
            rl.Vector2{ f32(dst.x), f32(dst.y) },
            rl.Color{ color.r, color.g, color.b, color.a })
    }
    
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.GRAY)
    
    command_backing: ^mu.Command
    for variant in mu.next_command_iterator(ctx, &command_backing) {
        #partial switch cmd in variant {
            case ^mu.Command_Text:
                dst := cmd.pos
                for ch in cmd.str do if ch&0xc0 != 0x80 {
                    r := min(int(ch), 127)
                    src := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r]
                    render_texture(atlas_texture, src, dst, cmd.color)
                    dst.x += src.w                    
                }
            case ^mu.Command_Icon:
                src := mu.default_atlas[cmd.id]
                x := cmd.rect.x + (cmd.rect.w - src.w) / 2
                y := cmd.rect.y + (cmd.rect.h - src.h) / 2
                render_texture(atlas_texture, src, mu.Vec2{ x, y }, cmd.color)
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