package CangjieQueryCompiler

import CangjieQueryCompiler.common.*
import CangjieQueryCompiler.executor.executeQuery
import CangjieQueryCompiler.output.printQueryResult
import CangjieQueryCompiler.output.printAppError
import CangjieQueryCompiler.parser.*
import CangjieQueryCompiler.semantic.*
import CangjieQueryCompiler.storage.loadCsv
import std.env.*

func getTableName(path: String): String {
    let parts = path.replace("\\", "/").split("/")
    let fileName = parts[parts.size - 1]
    let nameParts = fileName.split(".")
    return nameParts[0]
}

main() {
    println("=== Cangjie Query Compiler ===")
    println("Enter CSV file path:")
    print("> ")

    let pathInput = getStdIn().readln()

    match (pathInput) {
        case Some(path) =>
            let tableName = getTableName(path)

    match (loadCsv(path, tableName)) {
        case AppResult.Success(table) =>
            println("Table loaded: " + table.name)
            println("Rows: " + table.rows.size.toString())
            println()
            println("Type 'exit' to quit.")

    var running = true

    while (running) {
        print("\nEnter SQL query:\n> ")
    let input = getStdIn().readln()

    match (input) {
    case Some(sql) =>
    if (sql == "exit" || sql == "quit") {
        running = false
        println("Goodbye!/再见!")
        } else {
    match (parseSelectQuery(sql)) {
    case AppResult.Success(query) =>
    match (validateQuery(query, table)) {
    case AppResult.Success(_) =>
    let result = executeQuery(query, table)
        printQueryResult(result)
    case AppResult.Failure(error) =>
        printAppError(error)
    }
    case AppResult.Failure(error) =>
        printAppError(error)
        }
    }
    case None =>
        println("\nNo input received.")
    running = false
                        }
                    }
    case AppResult.Failure(error) =>
        printAppError(error)
    }
    case None =>
        println("No CSV path received.")
    }
}