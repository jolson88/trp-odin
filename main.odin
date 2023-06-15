package main

import "core:fmt"
import "core:os"
import "core:path/filepath"

Project_Request :: struct {
    name: string,
    path: string,
    files: [dynamic]File_Request,
}

File_Request :: struct {
    path: string,
    contents: string,
    is_dir: bool,
}

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
        project := Project_Request{ name = params[0] }
        create_project(&project, category)
        fmt.println(project)
    }
}

create_project :: proc(project: ^Project_Request, category: string) {
    dir, ok := dirs[category]
    if !ok {
        fmt.eprintln("Did not recognize category", category)
        print_usage_and_exit()
    }

    cwd := os.get_current_directory()
    project_dir  := filepath.join([]string{cwd, dir, project.name })
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
    
    project.path = project_dir
    walk_template_dir(project, "", template_dir)
}

walk_template_dir :: proc(project: ^Project_Request, dest_dir_rel: string, source_dir: string) {
    dir_path := filepath.join([]string{project.path, dest_dir_rel})
    append(&project.files, File_Request{
        path   = detemplatize(project, dir_path),
        is_dir = true,
    })
    
    f: os.Handle
    err := os.ERROR_NONE
    f, err = os.open(source_dir)
    if err != os.ERROR_NONE {
        fmt.eprintln("Could not open directory for reading", err)
        os.exit(1)
    }
    defer os.close(f)

    fis: []os.File_Info
    fis, err = os.read_dir(f, -1) // -1 -> read all entries
    if err != os.ERROR_NONE {
        fmt.eprintln("Could not read directory", err)
        os.exit(1)
    }
    defer os.file_info_slice_delete(fis)

    for fi in fis {
        file_name := detemplatize(project, fi.name)
        if fi.is_dir {
            walk_template_dir(project, filepath.join([]string{dest_dir_rel, file_name}), fi.fullpath)
        } else {
            append(&project.files, File_Request{
                path = filepath.join([]string{project.path, dest_dir_rel, file_name}),
                contents = read_file_contents(project, fi.fullpath),
                is_dir = false,
            })
        }
    }
}

read_file_contents :: proc(project: ^Project_Request, path: string) -> string {
    return "TODO"
}

detemplatize :: proc(project: ^Project_Request, original: string) -> string {
    return original
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