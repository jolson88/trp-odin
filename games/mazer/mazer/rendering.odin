package mazer

import rl "vendor:raylib"

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

    if in_ultimate {
        aberration := phase(ULT_FREQ) * ABERRATION_SIZE

        BeginBlendMode(BlendMode.ADDITIVE)
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

    } else if invincible {

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
