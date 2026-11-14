main() {
        println("--- Integer comparison tests ---")

    println(compareValues(Value.Integer(10),ComparisonOperator.Equal,Value.Integer(10)))
    println(compareValues(Value.Integer(10),ComparisonOperator.Greater,Value.Integer(5)))
    println(compareValues(Value.Integer(10),ComparisonOperator.Less,Value.Integer(5)))
    println(compareValues(Value.Integer(10),ComparisonOperator.GreaterOrEqual,Value.Integer(10)))
    println(compareValues(Value.Integer(10),ComparisonOperator.LessOrEqual,Value.Integer(5)))
    println(compareValues(Value.Integer(10),ComparisonOperator.NotEqual,Value.Integer(5)))

        println("--- Float comparison tests ---")

    println(compareValues(Value.Float(10.5),ComparisonOperator.Greater,Value.Float(5.5)))
    println(compareValues(Value.Float(3.5),ComparisonOperator.Equal,Value.Float(3.5)))

        println("--- Mixed Integer / Float comparison tests ---")

    println(compareValues(Value.Integer(19), ComparisonOperator.Equal, Value.Float(19.0)))
    println(compareValues(Value.Integer(19), ComparisonOperator.Less, Value.Float(19.5)))
    println(compareValues(Value.Float(19.5), ComparisonOperator.Greater, Value.Integer(19)))
    println(compareValues(Value.Float(19.0), ComparisonOperator.NotEqual, Value.Integer(20)))
    println(compareValues(Value.Integer(19), ComparisonOperator.GreaterOrEqual, Value.Float(19.5)))

        println("--- String comparison tests ---")

    println(compareValues(Value.String("Alice"),ComparisonOperator.Equal,Value.String("Alice")))
    println(compareValues(Value.String("Alice"),ComparisonOperator.NotEqual,Value.String("Bob")))

        println("--- Boolean comparison tests ---")

    println(compareValues(Value.Boolean(true),ComparisonOperator.Equal,Value.Boolean(true)))
    println(compareValues(Value.Boolean(true),ComparisonOperator.NotEqual,Value.Boolean(false)))

        println("--- evaluateCondition tests ---")

    let row = Row([Value.Integer(1),Value.String("Alice"),Value.Integer(19),Value.Integer(91)])
    let columns = ["id", "name", "age", "score"]
    let condition1 = Condition("age",ComparisonOperator.GreaterOrEqual,Value.Integer(18))
    let condition2 = Condition("score",ComparisonOperator.Greater,Value.Integer(95))
    let condition3 = Condition("height",ComparisonOperator.Greater,Value.Integer(180))

    println(evaluateCondition(row, columns, condition1))
    println(evaluateCondition(row, columns, condition2))
    println(evaluateCondition(row, columns, condition3))

        println("--- evaluateConditions tests ---")

    let row1 = Row([Value.Integer(1),Value.String("Alice"),Value.Integer(19),Value.Integer(91)])
    let row2 = Row([Value.Integer(2),Value.String("Bob"),Value.Integer(21),Value.Integer(76)])
    let row3 = Row([Value.Integer(3),Value.String("Chen"),Value.Integer(20),Value.Integer(88)])
    let conditions = [Condition("age",ComparisonOperator.GreaterOrEqual,Value.Integer(20)),Condition("score",ComparisonOperator.Greater,Value.Integer(80))]
    let testColumns = ["id", "name", "age", "score"]

    println(evaluateConditions(row1, testColumns, conditions))
    println(evaluateConditions(row2, testColumns, conditions))
    println(evaluateConditions(row3, testColumns, conditions))

        println("--- filterRows test ---")

    let filterTable = Table("students",testColumns,[row1, row2, row3])
    let filteredRows = filterRows(filterTable, conditions)

    println("Filtered rows: " + filteredRows.size.toString())
}