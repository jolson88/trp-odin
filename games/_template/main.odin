package main;

import "!@#PROJECT";
import "vendor:raylib";

main :: proc() {
    using !@#PROJECT;
    
    raylib.InitWindow(i32(WINDOW_WIDTH), i32(WINDOW_HEIGHT), "!@#PROJECT");
    defer raylib.CloseWindow();
    
    !@#PROJECT.run();
}