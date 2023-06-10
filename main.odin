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