package CangjieQueryCompiler.output
import CangjieQueryCompiler.common.*

func valueToString(value: Value): String {
    match (value) {
        case Value.Integer(number) => return number.toString()
        case Value.Float(number) => return number.toString()
        case Value.String(text) => return text
        case Value.Boolean(flag) => return flag.toString()
        case Value.Null => return "NULL"
    }
}
public func printQueryResult(result: QueryResult) {
    for (column in result.columns) {
        print(column + " | ")
    }
    println()

    for (row in result.rows) {
    for (i in 0..row.values.size) {
        let value = row.values[i]

        match (value) {
            case Value.Float(number) =>
                if (row.originalValues.size > i) {
                    print(row.originalValues[i] + " | ")
                } else {
                    print(number.toString() + " | ")
                }
            case _ =>
                print(valueToString(value) + " | ")
        }
    }
    println()
}
    println(result.rows.size.toString() + " row(s) returned.")
}
public func printAppError(error: AppError) {
    let category = getErrorCategory(error.code)

    var categoryName = "UNKNOWN"

    match (category) {
        case ErrorCategory.PARSER => categoryName = "PARSER"
        case ErrorCategory.SEMANTIC => categoryName = "SEMANTIC"
        case ErrorCategory.STORAGE => categoryName = "STORAGE"
        case ErrorCategory.UNKNOWN => categoryName = "UNKNOWN"
    }

    println("[" + categoryName + "] " + error.code)
    println(error.message)
}