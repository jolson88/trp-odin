package main;

import "mazer";
import "vendor:raylib";

main :: proc() {
    using mazer;
    
    raylib.InitWindow(i32(WINDOW_WIDTH), i32(WINDOW_HEIGHT), "Mazer");
    defer raylib.CloseWindow();
    
	mazer.run();
}