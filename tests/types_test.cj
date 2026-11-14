package CangjieQueryCompiler

main() {
    let value = Value.Integer(19)

    let row = Row([value, Value.String("Alice")])

    let table = Table(
        "students",
        ["age", "name"],
        [row]
    )

    let condition = Condition(
        "age",
        ComparisonOperator.GreaterOrEqual,
        Value.Integer(18)
    )

    let query = SelectQuery(
        "students",
        false,
        ["name"],
        [condition]
    )

    let result: AppResult<QueryResult> =
        AppResult.Success(QueryResult(["name"], [row]))

    println(table.name)
    println(query.tableName)

    match (result) {
        case AppResult.Success(r) => println("SUCCESS")
        case AppResult.Failure(e) => println(e.message)
    }
}