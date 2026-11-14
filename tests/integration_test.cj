main() {
    match (loadCsv("src/data/students.csv", "students")) {
        case AppResult.Success(table) =>
            let sql = "SELECT name FROM students WHERE age >= 19 AND score >= 88"

            match (parseSelectQuery(sql)) {
                case AppResult.Success(query) =>
            match (validateQuery(query, table)) {
                case AppResult.Success(_) =>
                let result = executeQuery(query, table)
                printQueryResult(result)

                case AppResult.Failure(error) =>
                println("Error: " + error.message)
                }

                case AppResult.Failure(error) =>
                    println("Error: " + error.message)
            }

        case AppResult.Failure(error) =>
            println("CSV loading error: " + error.message)
    }
}