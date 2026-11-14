package CangjieQueryCompiler.filter
import CangjieQueryCompiler.common.*
import std.collection.*

func compareValues(
    left: Value,
    op: ComparisonOperator,
    right: Value
): Bool {
    match (left) {
        case Value.Integer(a) =>
    match (right) {
        case Value.Integer(b) =>
    match (op) {
        case ComparisonOperator.Equal => return a == b
        case ComparisonOperator.NotEqual => return a != b
        case ComparisonOperator.Greater => return a > b
        case ComparisonOperator.Less => return a < b
        case ComparisonOperator.GreaterOrEqual => return a >= b
        case ComparisonOperator.LessOrEqual => return a <= b
                }
        case Value.Float(b) =>
        let left = Float64(a)
    match (op) {
        case ComparisonOperator.Equal => return left == b
        case ComparisonOperator.NotEqual => return left != b
        case ComparisonOperator.Greater => return left > b
        case ComparisonOperator.Less => return left < b
        case ComparisonOperator.GreaterOrEqual => return left >= b
        case ComparisonOperator.LessOrEqual => return left <= b
            }
        case _ => return false
            }

        case Value.Float(a) =>
    match (right) {
        case Value.Float(b) =>
    match (op) {
        case ComparisonOperator.Equal => return a == b
        case ComparisonOperator.NotEqual => return a != b
        case ComparisonOperator.Greater => return a > b
        case ComparisonOperator.Less => return a < b
        case ComparisonOperator.GreaterOrEqual => return a >= b
        case ComparisonOperator.LessOrEqual => return a <= b
                    }
        case Value.Integer(b) =>
        let rightValue = Float64(b)
    match (op) {
        case ComparisonOperator.Equal => return a == rightValue
        case ComparisonOperator.NotEqual => return a != rightValue
        case ComparisonOperator.Greater => return a > rightValue
        case ComparisonOperator.Less => return a < rightValue
        case ComparisonOperator.GreaterOrEqual => return a >= rightValue
        case ComparisonOperator.LessOrEqual => return a <= rightValue
                }
        case _ => return false
        }

        case Value.String(a) =>
    match (right) {
        case Value.String(b) =>
    match (op) {
        case ComparisonOperator.Equal => return a == b
        case ComparisonOperator.NotEqual => return a != b
        case _ => return false
            }
        case _ => return false
        }

        case Value.Boolean(a) =>
    match (right) {
        case Value.Boolean(b) =>
    match (op) {
        case ComparisonOperator.Equal => return a == b
        case ComparisonOperator.NotEqual => return a != b
        case _ => return false
            }
        case _ => return false
        }

        case Value.Null => return false
    }
}
func evaluateCondition(
    row: Row,
    columns: Array<String>,
    condition: Condition
): Bool {
    var index = 0

    for (column in columns) {
        if (column == condition.columnName) {
        if (index >= row.values.size) {
            return false
            }

            return compareValues(row.values[index],condition.op,condition.value)
        }
    index += 1
    }
    return false
}
func evaluateConditions(
    row: Row,
    columns: Array<String>,
    conditions: Array<Condition>
): Bool {
    for (condition in conditions) {
        if (!evaluateCondition(row, columns, condition)) {
            return false
        }
    }
    return true
}
protected func filterRows(
    table: Table,
    conditions: Array<Condition>
): Array<Row> {
    var result = ArrayList<Row>()

    for (row in table.rows) {
        if (evaluateConditions(row, table.columns, conditions)) {
            result.add(row)
        }
    }
    return result.toArray()
}