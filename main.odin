package main

import "core:fmt"
import "core:os"

main :: proc() {
    if len(os.args) < 4 {
        print_usage()
        return
    }

    category := os.args[1]
    action   := os.args[2]
    params   := os.args[3:]

    fmt.println("Category: "  , category)
    fmt.println("Action: "    , action)
    fmt.println("Parameters: ", params)

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
    fmt.println("trp-odin [category] [action] [parameters]")
    fmt.println()
    fmt.println("Supported categories: games, tools, exps")
    fmt.println()
    fmt.println("Examples:")
    fmt.println("\t- Create a new tool: `trp-odin tools new my-editor`")
    fmt.println("\t- Run a game: `trp-odin games run mazer`")
}