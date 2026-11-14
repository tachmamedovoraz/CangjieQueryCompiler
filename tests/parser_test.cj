main() {
    println("--- KEYWORD BOUNDARIES ---")
    println(findKeyword("SELECT name", "SELECT").toString())
    println(findKeyword("SELECTX name", "SELECT").toString())
    println(findKeyword("MYSELECT name", "SELECT").toString())
    println(findKeyword("SELECT_ABC", "SELECT").toString())
    println(findKeyword("SELECT name", "select").toString())

    println("--- KEYWORD SEARCH ---")
    println(findKeyword("SELECT name FROM students", "select").toString())
    println(findKeyword("SELECT name FROM students", "FROM").toString())
    println(findKeyword("SELECT name FROM students", "where").toString())
    println(findKeyword("select name from students", "SELECT").toString())

    println("--- KEYWORD END ---")
    println(findKeywordEnd("SELECT name FROM students", "SELECT").toString())
    println(findKeywordEnd("SELECT name FROM students", "FROM").toString())
    println(findKeywordEnd("SELECT name FROM students", "WHERE").toString())

    let query1 = parseSelectQuery("SELECT * FROM students")

    println("--- TEST 1 ---")

    match (query1) {
        case AppResult.Success(query) =>
            println(query.tableName)
            println(query.selectAll)
            println(query.selectedColumns.size)
            println(query.conditions.size)
        case AppResult.Failure(error) =>
            println("Error: " + error.message)
    }

    let query2 = parseSelectQuery("SELECT name FROM students")

    println("--- TEST 2 ---")

    match (query2) {
        case AppResult.Success(query) =>
            println(query.tableName)
            println(query.selectAll)
            println(query.selectedColumns[0])
            println(query.conditions.size)
        case AppResult.Failure(error) =>
            println("Error: " + error.message)
    }

    println("--- MIXED CASE SQL ---")

let query3 = parseSelectQuery(
    "sElEcT name fRoM students wHeRe age >= 19"
)

match (query3) {
    case AppResult.Success(query) =>
        println("Table: " + query.tableName)
        println("Column: " + query.selectedColumns[0])
        println("Conditions: " + query.conditions.size.toString())
    case AppResult.Failure(error) =>
        println("Error: " + error.message)
}

println("--- QUOTE DETECTION ---")
println(isInsideQuotes("'FROM home'", 1).toString())
println(isInsideQuotes("'FROM home'", 6).toString())
println(isInsideQuotes("\"WHERE age\"", 3).toString())
println(isInsideQuotes("SELECT name", 7).toString())

println("--- QUOTED KEYWORD SEARCH ---")
println(findKeyword("SELECT 'FROM home' FROM students", "FROM").toString())
println(findKeyword("SELECT name FROM students WHERE name = 'WHERE'", "WHERE").toString())
println(findKeyword("SELECT 'WHERE age' FROM students", "WHERE").toString())

println("--- QUOTED SQL PARSING ---")

let query4 = parseSelectQuery("SELECT name FROM students WHERE name = 'FROM home'")

match (query4) {
    case AppResult.Success(q) =>
        println(q.tableName)
        println(q.conditions.size.toString())
    case AppResult.Failure(e) =>
        println("Error: " + e.message)
    }

println("--- AND INSIDE QUOTES ---")

let conditions = splitWhereConditions("name = 'Rock AND Roll' AND age >= 19")

println(conditions.size.toString())
println(conditions[0])
println(conditions[1])

println("--- AND SQL PARSING ---")

let query5 = parseSelectQuery(
    "SELECT name FROM students WHERE name = 'Rock AND Roll' AND age >= 19"
)

match (query5) {
    case AppResult.Success(q) =>
        println(q.tableName)
        println(q.conditions.size.toString())
    case AppResult.Failure(e) =>
        println("Error: " + e.message)
}

println("--- DOUBLE QUOTES AND ---")

let doubleConditions = splitWhereConditions(
    "name = \"Rock AND Roll\" AND age >= 19"
)

println(doubleConditions.size.toString())
println(doubleConditions[0])
println(doubleConditions[1])

println("--- MULTIPLE AND CONDITIONS ---")

let multiConditions = splitWhereConditions(
    "age >= 18 AND score >= 80 AND id != 3"
)

println(multiConditions.size.toString())

for (condition in multiConditions) {
    println(condition)
}

println("--- MULTIPLE CONDITIONS PARSING ---")

match (parseWhereConditions("age >= 18 AND score >= 80 AND id != 3")) {
    case Some(parsed) =>
        println(parsed.size.toString())
        for (condition in parsed) {
            println(condition.columnName)
        }
    case None =>
        println("Parsing failed")
}

println("--- COMPARISON OPERATORS ---")

let operatorTests = [
    "age = 19",
    "age != 19",
    "age > 19",
    "age < 19",
    "age >= 19",
    "age <= 19"
]

for (test in operatorTests) {
    match (parseCondition(test)) {
        case Some(condition) =>
            println(condition.columnName)
            match (condition.op) {
                case ComparisonOperator.Equal => println("=")
                case ComparisonOperator.NotEqual => println("!=")
                case ComparisonOperator.Greater => println(">")
                case ComparisonOperator.Less => println("<")
                case ComparisonOperator.GreaterOrEqual => println(">=")
                case ComparisonOperator.LessOrEqual => println("<=")
}
            match (condition.value) {
                case Value.Integer(v) => println(v.toString())
                case Value.Float(v) => println(v.toString())
                case Value.String(v) => println(v)
                case Value.Boolean(v) => println(v.toString())
                case Value.Null => println("NULL")
}
        case None =>
            println("Parsing failed")
    }
}

println("--- OPERATOR INSIDE QUOTES ---")

match (parseCondition("name = 'A>=B'")) {
    case Some(condition) =>
        println(condition.columnName)
        match (condition.value) {
            case Value.Integer(v) => println(v.toString())
            case Value.Float(v) => println(v.toString())
            case Value.String(v) => println(v)
            case Value.Boolean(v) => println(v.toString())
            case Value.Null => println("NULL")
}
    case None =>
        println("Parsing failed")
}
}

func operatorName(op: ComparisonOperator): String {
    match (op) {
        case ComparisonOperator.Equal => return "Equal"
        case ComparisonOperator.NotEqual => return "NotEqual"
        case ComparisonOperator.Greater => return "Greater"
        case ComparisonOperator.Less => return "Less"
        case ComparisonOperator.GreaterOrEqual => return "GreaterOrEqual"
        case ComparisonOperator.LessOrEqual => return "LessOrEqual"
    }
}