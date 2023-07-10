package main

import "core:fmt"
import "core:os"

main :: proc() {
	story_mem, ok := os.read_entire_file("stories/zork1.z3")
	if !ok {
		fmt.println("Uh oh! Couldn't read the file!")
	}

	fmt.printf("Story file size: %v\n\n", len(story_mem))

	state: ZState
	init_state(&state, story_mem)

	print_header(&state)
	print_prop_defaults(&state)
}

ZState :: struct {
	mem:        []byte,

	// HEADER
	version:    u8,
	high_mem:   u16,
	init_pc:    u16,
	dict_loc:   u16,
	obj_loc:    u16,
	glob_loc:   u16,
	static_mem: u16,
	abbr_loc:   u16,
	file_len:   u32,
	checksum:   u16,

	// OBJECTS
	prop_def:   []u16,
}

init_state :: proc(state: ^ZState, data: []byte) {
	state.mem = data

	parse_header(state)
	parse_objects(state)
}

parse_header :: proc(state: ^ZState) {
	state.version = u8(state.mem[0])
	state.high_mem = read_word(state, 0x04)
	state.init_pc = read_word(state, 0x06)
	state.dict_loc = read_word(state, 0x08)
	state.obj_loc = read_word(state, 0x0A)
	state.glob_loc = read_word(state, 0xC)
	state.static_mem = read_word(state, 0x0E)
	state.abbr_loc = read_word(state, 0x18)
	state.file_len = u32(read_word(state, 0x1A)) * 2
	state.checksum = read_word(state, 0x1C)
}

parse_objects :: proc(state: ^ZState) {
	parse_prop_defaults(state)

	obj_tree_base := state.obj_loc + u16(len(state.prop_def) * 2)
}

parse_prop_defaults :: proc(state: ^ZState) {
	state.prop_def = make([]u16, 31)

	for i := 0; i < len(state.prop_def); i += 1 {
		state.prop_def[i] = read_word(state, state.obj_loc + u16(i * 2))
	}
}

print_header :: proc(state: ^ZState) {
	fmt.printf("Version:     %v\n", state.version)
	fmt.printf("File Length: %v\n", state.file_len)
	fmt.printf("Checksum:    %v\n\n", state.checksum)
	fmt.printf("High mem:    0x%4X\n", state.high_mem)
	fmt.printf("Static mem:  0x%4X\n", state.static_mem)
	fmt.printf("Init pc:     0x%4X\n\n", state.init_pc)
	fmt.printf("Dict loc:    0x%4X\n", state.dict_loc)
	fmt.printf("Obj loc:     0x%4X\n", state.obj_loc)
	fmt.printf("Globals loc: 0x%4X\n", state.glob_loc)
	fmt.printf("Abbrevs loc: 0x%4X\n", state.abbr_loc)
}

print_prop_defaults :: proc(state: ^ZState) {
	fmt.printf("\nProp defaults:\n-------\n")
	for i := 0; i < len(state.prop_def); i += 1 {
		fmt.printf("[%2d]: %5d\n", i + 1, state.prop_def[i])
	}
}

read_word :: proc(state: ^ZState, addr: u16) -> u16 {
	return u16(state.mem[addr]) << 8 | u16(state.mem[addr + 1])
}
