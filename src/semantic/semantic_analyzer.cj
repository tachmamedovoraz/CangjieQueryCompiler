package CangjieQueryCompiler.semantic
import CangjieQueryCompiler.common.*
import std.collection.*

func validateTableExists(query: SelectQuery, table: Table): AppResult<Bool> {
    if (query.tableName != table.name) {
        return AppResult.Failure(AppError("TABLE_NOT_FOUND", "Table does not exist: " + query.tableName))
    }
    return AppResult.Success(true)
}
func validateSelectedColumns(query: SelectQuery, table: Table): AppResult<Bool> {
    if (query.selectAll) {
        return AppResult.Success(true)
    }

    for (column in query.selectedColumns) {
        var found = false

        for (tableColumn in table.columns) {
            if (column == tableColumn) {
                found = true
                break
            }
        }

        if (!found) {
            return AppResult.Failure(AppError("COLUMN_NOT_FOUND", "Column does not exist: " + column))
        }
    }
    return AppResult.Success(true)
}
func validateConditionColumns(query: SelectQuery, table: Table): AppResult<Bool> {
    for (condition in query.conditions) {
        var found = false

        for (column in table.columns) {
            if (condition.columnName == column) {
                found = true
                break
            }
        }

        if (!found) {
            return AppResult.Failure(
                AppError("COLUMN_NOT_FOUND","Column does not exist in WHERE: " + condition.columnName))
        }
    }
    return AppResult.Success(true)
}
func validateTableStructure(table: Table): AppResult<Bool> {
    for (i in 0..table.rows.size) {
        if (table.rows[i].values.size != table.columns.size) {
            return AppResult.Failure(
                AppError("INVALID_TABLE_STRUCTURE","Row " + i.toString() + " has an incorrect number of values."))
        }
    }

    return AppResult.Success(true)
}
func validateConditionTypes(query: SelectQuery, table: Table): AppResult<Bool> {
    for (condition in query.conditions) {
        var columnIndex = -1
        var index = 0

        for (column in table.columns) {
            if (column == condition.columnName) {
                columnIndex = index
                break
            }
            index++
        }

        if (columnIndex < 0) {
            return AppResult.Failure(AppError("COLUMN_NOT_FOUND", "Column does not exist: " + condition.columnName))
        }

        var hasInteger = false
        var hasFloat = false
        var hasString = false
        var hasBoolean = false

        for (row in table.rows) {
            match (row.values[columnIndex]) {
                case Value.Integer(_) => hasInteger = true
                case Value.Float(_) => hasFloat = true
                case Value.String(_) => hasString = true
                case Value.Boolean(_) => hasBoolean = true
                case Value.Null => ()
            }
        }

        let isNumeric = hasInteger || hasFloat
        let hasMultipleTypes =
            (if (isNumeric) { 1 } else { 0 }) +
            (if (hasString) { 1 } else { 0 }) +
            (if (hasBoolean) { 1 } else { 0 }) > 1

        if (hasMultipleTypes) {
            return AppResult.Failure(AppError("TYPE_MISMATCH", "Column contains incompatible value types: " + condition.columnName))
        }

        var compatible = false

        if (isNumeric) {
            match (condition.value) {
                case Value.Integer(_) => compatible = true
                case Value.Float(_) => compatible = true
                case _ => ()
            }
        } else if (hasString) {
            match (condition.value) {
                case Value.String(_) =>
                    match (condition.op) {
                    case ComparisonOperator.Equal => compatible = true
                    case ComparisonOperator.NotEqual => compatible = true
                    case _ => compatible = false
        }
                case _ => ()
            }
        } else if (hasBoolean) {
            match (condition.value) {
                case Value.Boolean(_) =>
                    match (condition.op) {
                    case ComparisonOperator.Equal => compatible = true
                    case ComparisonOperator.NotEqual => compatible = true
                    case _ => compatible = false
        }
                case _ => ()
            }
        } else {
            compatible = true
        }

        if (!compatible) {
            return AppResult.Failure(AppError("TYPE_MISMATCH", "Incompatible comparison for column: " + condition.columnName))
        }
    }

    return AppResult.Success(true)
}
public func validateQuery(query: SelectQuery, table: Table): AppResult<Bool> {
    match (validateTableExists(query, table)) {
        case AppResult.Success(value) => ()
        case AppResult.Failure(error) => return AppResult.Failure(error)
    }
        match (validateTableStructure(table)) {
        case AppResult.Success(value) => ()
        case AppResult.Failure(error) => return AppResult.Failure(error)
    }
    match (validateSelectedColumns(query, table)) {
        case AppResult.Success(value) => ()
        case AppResult.Failure(error) => return AppResult.Failure(error)
    }

    match (validateConditionColumns(query, table)) {
        case AppResult.Success(value) => ()
        case AppResult.Failure(error) => return AppResult.Failure(error)
    }
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(value) => ()
        case AppResult.Failure(error) => return AppResult.Failure(error)
    }

    return AppResult.Success(true)
}
public func validateQueryDetailed(
    query: SelectQuery,
    table: Table
): ValidationResult {
    var errors = ArrayList<AppError>()

    match (validateTableExists(query, table)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
            errors.add(error)
    }

    match (validateTableStructure(table)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
            errors.add(error)
    }

    if (errors.size > 0) {
        return ValidationResult(errors.toArray())
    }

    match (validateSelectedColumns(query, table)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
            errors.add(error)
    }

    match (validateConditionColumns(query, table)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
            errors.add(error)
    }

    if (errors.size > 0) {
        return ValidationResult(errors.toArray())
    }

    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
            errors.add(error)
    }

    return ValidationResult(errors.toArray())
}