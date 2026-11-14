import CangjieQueryCompiler.common.*
import CangjieQueryCompiler.storage.*

func printFields(result: AppResult<Array<String>>) {
    match (result) {
        case AppResult.Success(fields) =>
            for (field in fields) {
                println("[${field}]")
            }
        case AppResult.Failure(error) =>
            println("ERROR: ${error.code} - ${error.message}")
    }
}

func printRows(result: AppResult<Array<Array<String>>>) {
    match (result) {
        case AppResult.Success(rows) =>
            for (row in rows) {
                for (field in row) {
                    print("${field} ")
                }
                println("")
            }
        case AppResult.Failure(error) =>
            println("ERROR: ${error.code} - ${error.message}")
    }
}

func printTable(result: AppResult<Table>) {
    match (result) {
        case AppResult.Success(table) =>
            println("Table: ${table.name}")
            println("Columns:")
            for (column in table.columns) {
                println(column)
            }
            println("Rows: ${table.rows.size}")
            for (row in table.rows) {
                for (value in row.values) {
                    match (value) {
                        case Value.Integer(v) => print("${v} ")
                        case Value.Float(v) => print("${v} ")
                        case Value.Boolean(v) => print("${v} ")
                        case Value.String(v) => print("${v} ")
                        case Value.Null => print("NULL ")
                    }
                }
                println("")
            }
        case AppResult.Failure(error) =>
            println("ERROR: ${error.code} - ${error.message}")
    }
}

main() {
    println("--- VALID CSV LINES ---")
    printFields(parseCsvLine("1,Alice,19,91"))
    printFields(parseCsvLine("1,\"Smith, John\",20,85"))
    printFields(parseCsvLine("1,\"He said \"\"Hi\"\"\",20,85"))
    printFields(parseCsvLine("1,,20,85"))
    printFields(parseCsvLine("1,\"\",20,85"))

    println("--- INVALID CSV LINES ---")
    printFields(parseCsvLine("1,\"Alice,19,91"))
    printFields(parseCsvLine("1,\"Alice\"\"Smith,19,91"))
    printFields(parseCsvLine("1,\"Alice\"Smith,19,91"))
    printFields(parseCsvLine("1,Ali\"ce,19,91"))
    
    println("--- CSV EDGE CASES ---")

    println("Trailing comma:")
    printFields(parseCsvLine("1,Alice,19,"))

    println("Empty quoted field:")
    printFields(parseCsvLine("1,\"\",19"))

    println("Space after closing quote:")
    printFields(parseCsvLine("1,\"Alice\" ,19"))

    println("Quote inside unquoted field:")
    printFields(parseCsvLine("1,Ali\"ce,19"))

    println("--- CSV CONTENT TEST ---")
    printRows(parseCsvContent("id,name,age\n1,Alice,19\n2,Bob,21"))
    
    println("--- MULTILINE CSV FIELD TEST ---")
    printRows(parseCsvContent("id,name,age\n1,Alice,19\n2,\"Bob\nSmith\",21"))

    println("--- MULTILINE STRUCTURE TEST ---")
    match (parseCsvContent("id,name,age\n1,Alice,19\n2,\"Bob\nSmith\",21")) {
    case AppResult.Success(rows) =>
        println("Total rows: " + rows.size.toString())
        println("Second data row fields: " + rows[2].size.toString())
        println("Multiline field preserved: " + (rows[2][1] == "Bob\nSmith").toString())
    case AppResult.Failure(error) =>
        println("ERROR: " + error.code)
    }
    println("--- MULTILINE CRLF TEST ---")
    match (parseCsvContent("id,name,age\r\n1,Alice,19\r\n2,\"Bob\r\nSmith\",21")) {
    case AppResult.Success(rows) =>
        println("Total rows: " + rows.size.toString())
        println("Fields: " + rows[2].size.toString())
        println("Value preserved: " + (rows[2][1] == "Bob\r\nSmith").toString())
    case AppResult.Failure(error) =>
        println("ERROR: " + error.code + " - " + error.message)
    }
        println("--- QUOTED FINAL FIELD WITHOUT NEWLINE ---")
    match (parseCsvContent("id,name\n1,\"Alice\"")) {
        case AppResult.Success(rows) =>
            println("Total rows: " + rows.size.toString())
            println("Final value: " + rows[1][1])
            println("PASS: " + (rows[1][1] == "Alice").toString())
        case AppResult.Failure(error) =>
            println("ERROR: " + error.code + " - " + error.message)
    }

    println("--- UNCLOSED QUOTE AT EOF ---")
    match (parseCsvContent("id,name\n1,\"Alice")) {
        case AppResult.Success(_) =>
            println("FAIL: Invalid CSV was accepted")
        case AppResult.Failure(error) =>
            println("PASS: " + error.code)
    }

    println("--- ESCAPED QUOTE AT EOF ---")
    match (parseCsvContent("id,name\n1,\"Alice\"\"")) {
        case AppResult.Success(_) =>
            println("FAIL: Invalid CSV was accepted")
        case AppResult.Failure(error) =>
            println("PASS: " + error.code)
    }
    println("--- INVALID CSV STRUCTURE TEST ---")
    printRows(parseCsvContent("id,name\n1,Alice\n2,Bob,20"))

    println("--- INVALID CSV QUOTE TEST ---")
    printRows(parseCsvContent("id,name\n1,\"Alice"))
    
    println("--- CSV HEADER EDGE CASES ---")

    println("Quoted comma in header:")
    printRows(parseCsvContent("\"student,id\",name\n1,Alice"))

    println("Quoted header with escaped quote:")
    printRows(parseCsvContent("\"student \"\"ID\"\"\",name\n1,Alice"))

    println("Header with spaces:")
    printRows(parseCsvContent("student id,full name\n1,Alice Smith"))

    println("--- VALUE TEST ---")
    let values = [
        parseCsvValue("123"),
        parseCsvValue("19.5"),
        parseCsvValue("true"),
        parseCsvValue("Alice"),
        parseCsvValue("")
    ]

    for (value in values) {
        match (value) {
            case Value.Integer(v) => println("Integer: ${v}")
            case Value.Float(v) => println("Float: ${v}")
            case Value.Boolean(v) => println("Boolean: ${v}")
            case Value.String(v) => println("String: ${v}")
            case Value.Null => println("Null")
        }
    }

    println("--- LOAD CSV TEST ---")
    printTable(loadCsv("./src/data/students.csv", "students"))

    println("--- MISSING FILE TEST ---")
    printTable(loadCsv("./src/data/missing.csv", "missing"))

    println("--- EMPTY CSV TEST ---")
    printTable(loadCsv("./src/data/empty.csv", "empty"))

    println("--- HEADER ONLY CSV TEST ---")
    printTable(loadCsv("./src/data/header_only.csv", "header_only"))
}