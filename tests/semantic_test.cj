func printResult(result: AppResult<Bool>) {
    match (result) {
        case AppResult.Success(value) => println("Validation successful")
        case AppResult.Failure(error) => println(error.message)
    }
}
main() {
    let query = SelectQuery("students",true,[],[])
    let table = Table("students",["id", "name", "age", "score"],[])

    match (validateTableExists(query, table)) {
        case AppResult.Success(value) => println("Table exists")
        case AppResult.Failure(error) => println(error.message)
    }

    let wrongQuery = SelectQuery("employees",true,[],[])

    match (validateTableExists(wrongQuery, table)) {
        case AppResult.Success(value) => println("Table exists")
        case AppResult.Failure(error) => println(error.message)
    }

    let validQuery = SelectQuery("students",false,["name", "age"],[])
    printResult(validateSelectedColumns(validQuery, table))
    let invalidQuery = SelectQuery("students",false,["salary"],[])
    printResult(validateSelectedColumns(invalidQuery, table))
    let whereQuery = SelectQuery("students",false,["name"],[Condition("age", ComparisonOperator.Greater, Value.Integer(18)),Condition("score", ComparisonOperator.Greater, Value.Integer(80))])
    printResult(validateConditionColumns(whereQuery, table))
    let invalidWhereQuery = SelectQuery("students",false,["name"],[Condition("height", ComparisonOperator.Greater, Value.Integer(180))])
    printResult(validateConditionColumns(invalidWhereQuery, table))

        println("--- validateQuery test ---")

    let combinedValidQuery = SelectQuery("students",false,["name", "age"],[Condition("age", ComparisonOperator.Greater, Value.Integer(18))])
    printResult(validateQuery(combinedValidQuery, table))
    let combinedInvalidQuery = SelectQuery("students",false,["salary"],[])
    printResult(validateQuery(combinedInvalidQuery, table))

        println("--- validateTableStructure tests ---")

    let validStructureTable = Table("students",["id", "name"],[Row([Value.Integer(1), Value.String("Alice")]),Row([Value.Integer(2), Value.String("Bob")])])
    printResult(validateTableStructure(validStructureTable))
    let invalidStructureTable = Table("students",["id", "name"],[Row([Value.Integer(1), Value.String("Alice")]),Row([Value.Integer(2)])])
    printResult(validateTableStructure(invalidStructureTable))
}