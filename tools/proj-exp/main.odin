package main

import "core:fmt"
import "core:odin/parser"
import "core:odin/ast"
import "core:os"
import "core:strings"

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
        fmt.println("Error: Could not parse file! Please ensure this file is a valid Odin file")
        return
    }

    pretty_print_file(&file)
}

Printer :: struct {
    prepend: strings.Builder,
}

pretty_print_file :: proc(file: ^ast.File) {
    p := Printer{ prepend = strings.builder_make() }

    fmt.printf("%vFile: %v\n", strings.to_string(p.prepend), file.fullpath)
    fmt.printf("%vPackage: %v\n", strings.to_string(p.prepend), file.pkg_name)
    fmt.printf("%v%v warnings\n%v errors\n\n", strings.to_string(p.prepend), file.syntax_warning_count, file.syntax_warning_count)

    fmt.printf("Declarations:\n")
    strings.write_string(&p.prepend, "  ")
    pretty_print_list(&p, file.decls[:])
    strings.builder_reset(&p.prepend)
}

pretty_print_expr :: proc(p: ^Printer, expr: ^ast.Expr) {
    using ast

    #partial switch e in expr.derived_expr {
    case ^Ident:
        fmt.printf("%vIdentifier: %v\n", strings.to_string(p.prepend), e.name)
    case:
        fmt.printf("%v%#v", strings.to_string(p.prepend), expr.derived_expr)
    }
}

pretty_print_stmt :: proc(p: ^Printer, stmt: ^ast.Stmt) {
    using ast

    #partial switch s in stmt.derived_stmt {
    case ^Value_Decl:
        pretty_print_list(p, s.names[:])
    case ^Import_Decl:
        fmt.printf("%vImport: %v\n", strings.to_string(p.prepend), s.fullpath)
    case:
        fmt.printf("%v%#v\n\n", strings.to_string(p.prepend), stmt.derived_stmt)
    }
}

pretty_print :: proc{pretty_print_expr, pretty_print_stmt}

pretty_print_stmt_list :: proc(p: ^Printer, list: []^ast.Stmt) {
    for x in list {
        pretty_print(p, x)
    }
}

pretty_print_expr_list :: proc(p: ^Printer, list: []^ast.Expr) {
    for x in list {
        pretty_print(p, x)
    }
}

pretty_print_list :: proc{pretty_print_stmt_list, pretty_print_expr_list}