package main

import "core:fmt"
import "core:os"

main :: proc() {
    if len(os.args) < 4 {
        print_usage()
        return
    }

    action   := os.args[1]
    category := os.args[2]
    params   := os.args[3:]

    if action == "new" {
        create_project(params[0], category)
    }
}

create_project :: proc(name: string, category: string) {
    fmt.println("Creating new project")
    fmt.println("Name: ", name)
    fmt.println("Category: ", category)
}

walk_dir :: proc() {
    dir := os.get_current_directory()
    fmt.println("Current directory: ", dir)

    f: os.Handle
    err := os.ERROR_NONE
    f, err = os.open(dir)
    if err != os.ERROR_NONE {
        fmt.println("Could not open directory for reading", err)
    }
    defer os.close(f)

    fis: []os.File_Info
    fis, err = os.read_dir(f, -1) // -1 -> read all entries
    if err != os.ERROR_NONE {
        fmt.println("Could not read directory", err)
    }
    defer os.file_info_slice_delete(fis)

    for fi in fis {
        fmt.println("Found: ", fi.fullpath)
        fmt.println("Is directory? ", fi.is_dir)
        fmt.println("Size: ", fi.size)
        fmt.println()
    }
}

print_usage :: proc() {
    fmt.println("trp-odin [action] [category] [parameters]")
    fmt.println()
    fmt.println("Supported categories: game, tool, exp")
    fmt.println()
    fmt.println("Examples:")
    fmt.println("\t- Create a new tool: `trp-odin new tool my-editor`")
    fmt.println("\t- Run a game: `trp-odin run game mazer`")
}