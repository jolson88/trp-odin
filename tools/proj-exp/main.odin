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
        fmt.println("Error: Could not parse file!")
        return
    }

    pretty_print_file(&file)
}

Printer :: struct {
    // TODO: Turn into reference instead
    prepend: strings.Builder,
}

printlnf :: proc(p: ^Printer, s: string, args: ..any) {
    using strings
    pp_line := fmt.tprintf("%s%s\n", to_string(p.prepend), fmt.tprintf(s, ..args))
    fmt.print(pp_line)
}

println :: proc(p: ^Printer, s: string) {
    fmt.printf("%s%s\n", strings.to_string(p.prepend), s)
}

pretty_print_file :: proc(file: ^ast.File) {
    b := strings.builder_make()
    defer strings.builder_destroy(&b)
    p := Printer{ prepend = b }

    printlnf(&p, "File: %s", file.fullpath)
    printlnf(&p, "Package: %s", file.pkg_name)
    printlnf(&p, "%v warnings", file.syntax_warning_count)
    printlnf(&p, "%v errors", file.syntax_warning_count)
    fmt.println()

    println(&p, "Declarations:")
    strings.write_string(&p.prepend, "  ")
    pretty_print_list(&p, file.decls[:])
    strings.builder_reset(&p.prepend)
}

pretty_print_expr :: proc(p: ^Printer, expr: ^ast.Expr) {
    using ast

    #partial switch e in expr.derived_expr {
    case ^Ident:
        printlnf(p, "Identifier: %s", e.name)
    case:
        printlnf(p, "%#v", expr.derived_expr)
    }
}

pretty_print_stmt :: proc(p: ^Printer, stmt: ^ast.Stmt) {
    using ast

    #partial switch s in stmt.derived_stmt {
    case ^Value_Decl:
        pretty_print_list(p, s.names[:])
    case ^Import_Decl:
        printlnf(p, "Import: %s", s.fullpath)
    case:
        printlnf(p, "%#v", stmt.derived_stmt)
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