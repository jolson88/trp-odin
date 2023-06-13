package main

import "core:fmt"
import "core:os"
import "core:path/filepath"

dirs := map[string]string{ "game" = "games", "tool" = "tools", "exp" = "exps" }

main :: proc() {
    if len(os.args) < 4 {
        print_usage_and_exit()
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
    dir, ok := dirs[category]
    if !ok {
        fmt.eprintln("Did not recognize category", category)
        print_usage_and_exit()
    }

    fmt.printf("\nCreating %v\n\n", name)
    cwd := os.get_current_directory()
    project_dir  := filepath.join([]string{cwd, dir, name })
    template_dir := filepath.join([]string{cwd, dir, "_template"})

    dir_exists := os.exists(template_dir)
    if !dir_exists {
        fmt.eprintln("Could not find template for category:", category)
        os.exit(1)
    }

    dir_exists = os.exists(project_dir)
    if dir_exists {
        fmt.eprintln("Project already exists:", project_dir)
        os.exit(1)
    }

    create_from_template(template_dir, project_dir)
}

create_from_template :: proc(template_dir: string, target_dir: string) {
    fmt.println("Copying from project template")
    fmt.println("Template: ", template_dir)
    fmt.println("Target: ", target_dir)
}

walk_dir :: proc(dir: string) {
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

print_usage_and_exit :: proc() {
    fmt.eprintln("trp-odin [action] [category] [parameters]")
    fmt.eprintln()
    fmt.eprintln("Supported categories: game, tool, exp")
    fmt.eprintln()
    fmt.eprintln("Examples:")
    fmt.eprintln("\t- Create a new tool: `trp-odin new tool my-editor`")
    fmt.eprintln("\t- Run a game: `trp-odin run game mazer`")
    os.exit(1)
}