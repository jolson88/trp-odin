package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:slice"
import "core:strings"

Project_Request :: struct {
    name: string,
    path: string,
    files: [dynamic]File_Request,
}

File_Request :: struct {
    path: string,
    src_path: string,
    content: []byte,
    is_dir: bool,
}

txts := []string{ ".bat", ".json", ".odin", ".txt" }
dirs := map[string]string{ "game" = "games", "tool" = "tools", "exp" = "exps" }


main :: proc() {
    if len(os.args) < 4 {
        report_usage_and_exit()
        return
    }

    // Our templates are super small, so 8MB should be just fine
    scratch: mem.Scratch_Allocator;
    mem.scratch_allocator_init(&scratch, 8 * mem.Megabyte, context.allocator)
    context.allocator = mem.scratch_allocator(&scratch)
    defer mem.scratch_allocator_destroy(&scratch)

    action   := os.args[1]
    category := os.args[2]
    params   := os.args[3:]

    if action == "new" {
        project := Project_Request{ name = params[0] }
        
        fmt.println("Creating project:", project.name)
        build_project(&project, category)

        is_dry_run := true if slice.contains(params, "--dry-run") else false
        fn := print_project if is_dry_run else create_project
        fn(&project)
    }
}

create_project :: proc(project: ^Project_Request) {
    fmt.println("Creating files...")

    for fr in project.files {
        if fr.is_dir {
            err := os.make_directory(fr.path)
            if err != os.ERROR_NONE {
                report_and_exit("Could not create destination directory", fr.path, err)
            }
            continue
        }
        
        ok := os.write_entire_file(fr.path, fr.content)
        if !ok {
            report_and_exit("Could not write file", fr.path, len(fr.content))
        }
    }

    fmt.println("Finished creating project from template:", project.path)
}

print_project :: proc(project: ^Project_Request) {
    for fr in project.files {
        if fr.is_dir {
            fmt.println("Create directory:", fr.path)
            continue
        }
        
        fmt.println("Create file:", fr.path)
        fmt.println("  Size (bytes):", len(fr.content))
    }
}

build_project :: proc(project: ^Project_Request, category: string) {
    dir, ok := dirs[category]
    if !ok {
        fmt.eprintln("Did not recognize category", category)
        report_usage_and_exit()
    }

    cwd := os.get_current_directory()
    project_dir  := filepath.join([]string{cwd, dir, project.name })
    template_dir := filepath.join([]string{cwd, dir, "_template"})

    dir_exists := os.exists(template_dir)
    if !dir_exists {
        report_and_exit("Could not find template for category:", category)
    }

    dir_exists = os.exists(project_dir)
    if dir_exists {
        report_and_exit("Project already exists:", project_dir)
    }
    
    project.path = project_dir
    build_project_dir(project, "", template_dir)
}

build_project_dir :: proc(project: ^Project_Request, target_dir_rel: string, source_path: string) {
    target_path := filepath.join([]string{project.path, target_dir_rel})
    append(&project.files, File_Request{
        path     = detemplatize(project, target_path),
        src_path = source_path,
        is_dir   = true,
    })
    
    f: os.Handle
    err := os.ERROR_NONE
    f, err = os.open(source_path)
    if err != os.ERROR_NONE {
        report_and_exit("Could not open directory for reading", err)
    }
    defer os.close(f)

    fis: []os.File_Info
    fis, err = os.read_dir(f, -1) // -1 -> read all entries
    if err != os.ERROR_NONE {
        report_and_exit("Could not read directory", err)
    }

    for fi in fis {
        file_name := detemplatize(project, fi.name)
        if fi.is_dir {
            build_project_dir(project, filepath.join([]string{target_dir_rel, file_name}), fi.fullpath)
            continue
        }
    
        append(&project.files, File_Request{
            path     = filepath.join([]string{project.path, target_dir_rel, file_name}),
            src_path = fi.fullpath,
            content  = read_file_contents(project, fi.fullpath),
            is_dir   = false,
        })
    }
}

read_file_contents :: proc(project: ^Project_Request, path: string) -> []byte {
    contents, ok := os.read_entire_file(path)
    if !ok {
        report_and_exit("Could not read contents of file", path)
    }
    ext := filepath.ext(path)
    if !slice.contains(txts, ext) do return contents
    
    new_contents, _ := strings.replace_all(string(contents), "!@#PROJECT", project.name)
    return transmute([]byte)new_contents
}

detemplatize :: proc(project: ^Project_Request, original: string) -> string {
    if strings.index(original, "!@#PROJECT") >= 0 {
        new_string, _ := strings.replace_all(original, "!@#PROJECT", project.name)
        return new_string
    }
    
    return original
}

report_and_exit :: proc(s: string, args: ..any) {
    fmt.eprintln(s, args)
    os.exit(1)
}

report_usage_and_exit :: proc() {
    fmt.eprintln("trp-odin [action] [category] [parameters]")
    fmt.eprintln()
    fmt.eprintln("Supported categories: game, tool, exp")
    fmt.eprintln()
    fmt.eprintln("Examples:")
    fmt.eprintln("\t- Create a new tool: `trp-odin new tool my-editor`")
    fmt.eprintln("\t- Run a game: `trp-odin run game mazer`")
    os.exit(1)
}