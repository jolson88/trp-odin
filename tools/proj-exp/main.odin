package main

import "core:fmt"
import "core:odin/parser"
import "core:odin/ast"
import "core:os"

main :: proc() {
    filepath := "main.odin"

    data, ok := os.read_entire_file("main.odin")
	if !ok {
		fmt.println("Uh oh! Couldn't read the file!")
	}
	
	source := string(data)

    pkg := ast.Package {
        kind = .Normal,
    }

    file := ast.File {
        pkg = &pkg,
        src = source,
        fullpath = filepath,
    }

    p := parser.default_parser()
    ok = parser.parse_file(&p, &file)
    if !ok || file.syntax_error_count > 0 {
        fmt.println("Could not parse file!")
        return
    }

    for decl in file.decls {
        fmt.printf("\n%#v\n", decl.derived_stmt)
    }
}