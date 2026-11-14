main() {
    let table = Table("students",["id", "name", "age", "score"],[])

    println("--- SELECT specific columns ---")

    let query = SelectQuery("students",false,["name", "score"],[])

    let indexes = getSelectedColumnIndexes(query, table)

    for (index in indexes) {
        println(index)
    }

    println("--- SELECT * ---")

    let allQuery = SelectQuery("students",true,[],[])

    let allIndexes = getSelectedColumnIndexes(allQuery, table)

    for (index in allIndexes) {
        println(index)
    }

        println("--- projectRow test ---")

    let sourceRow = Row([
        Value.Integer(1),
        Value.String("Alice"),
        Value.Integer(19),
        Value.Integer(91)
    ])

    let selectedIndexes: Array<Int64> = [1, 3]

    let projectedRow = projectRow(sourceRow, selectedIndexes)

    println("Projected values: " + projectedRow.values.size.toString())

    match (projectedRow.values[0]) {
        case Value.String(value) => println(value)
        case _ => println("Unexpected value")
    }

    match (projectedRow.values[1]) {
        case Value.Integer(value) => println(value)
        case _ => println("Unexpected value")
    }

        println("--- executeQuery test ---")

    let studentsTable = Table(
        "students",
        ["id", "name", "age", "score"],
        [
            Row([Value.Integer(1), Value.String("Alice"), Value.Integer(19), Value.Integer(91)]),
            Row([Value.Integer(2), Value.String("Bob"), Value.Integer(21), Value.Integer(76)]),
            Row([Value.Integer(3), Value.String("Chen"), Value.Integer(20), Value.Integer(88)]),
            Row([Value.Integer(4), Value.String("David"), Value.Integer(18), Value.Integer(95)]),
            Row([Value.Integer(5), Value.String("Emma"), Value.Integer(22), Value.Integer(67)])
        ]
    )

    let sqlQuery = SelectQuery(
        "students",
        false,
        ["name", "score"],
        [
            Condition("age", ComparisonOperator.GreaterOrEqual, Value.Integer(20)),
            Condition("score", ComparisonOperator.Greater, Value.Integer(80))
        ]
    )

    let queryResult = executeQuery(sqlQuery, studentsTable)

    println("Columns:")
    for (column in queryResult.columns) {
        println(column)
    }

    println("Rows: " + queryResult.rows.size.toString())

    for (row in queryResult.rows) {
        for (value in row.values) {
            match (value) {
                case Value.String(text) => print(text + " ")
                case Value.Integer(number) => print(number.toString() + " ")
                case _ => print("? ")
            }
        }
        println()
    }
}