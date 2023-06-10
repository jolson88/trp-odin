package main;

import "znake";
import "vendor:raylib";

main :: proc() {
    using znake;
    
    raylib.InitWindow(i32(WINDOW_WIDTH), i32(WINDOW_HEIGHT), "Znake");
    defer raylib.CloseWindow();
    
	znake.run();
}