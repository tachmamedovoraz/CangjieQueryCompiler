package CangjieQueryCompiler.common

public enum Value {
    | Integer(Int64)
    | Float(Float64)
    | String(String)
    | Boolean(Bool)
    | Null
}

public enum ComparisonOperator {
    | Equal
    | NotEqual
    | Greater
    | Less
    | GreaterOrEqual
    | LessOrEqual
}

public struct Row {
    public let values: Array<Value>
    public let originalValues: Array<String>

    public init(values: Array<Value>) {
        this.values = values
        this.originalValues = []
    }

    public init(values: Array<Value>, originalValues: Array<String>) {
        this.values = values
        this.originalValues = originalValues
    }
}

public struct Table {
    public let name: String
    public let columns: Array<String>
    public let rows: Array<Row>

    public init(name: String, columns: Array<String>, rows: Array<Row>) {
        this.name = name
        this.columns = columns
        this.rows = rows
    }
}

public struct Condition {
    public let columnName: String
    public let op: ComparisonOperator
    public let value: Value

    public init(columnName: String, op: ComparisonOperator, value: Value) {
        this.columnName = columnName
        this.op = op
        this.value = value
    }
}

public struct SelectQuery {
    public let tableName: String
    public let selectAll: Bool
    public let selectedColumns: Array<String>
    public let conditions: Array<Condition>

    public init(
        tableName: String,
        selectAll: Bool,
        selectedColumns: Array<String>,
        conditions: Array<Condition>
    ) {
        this.tableName = tableName
        this.selectAll = selectAll
        this.selectedColumns = selectedColumns
        this.conditions = conditions
    }
}

public struct QueryResult {
    public let columns: Array<String>
    public let rows: Array<Row>

    public init(columns: Array<String>, rows: Array<Row>) {
        this.columns = columns
        this.rows = rows
    }
}

public struct AppError {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        this.code = code
        this.message = message
    }
}

public enum AppResult<T> {
    | Success(T)
    | Failure(AppError)
}

public struct ValidationResult {
    public let isValid: Bool
    public let errors: Array<AppError>

    public init(errors: Array<AppError>) {
        this.errors = errors
        this.isValid = errors.size == 0
    }
}
public enum ErrorCategory {
    | PARSER
    | SEMANTIC
    | STORAGE
    | UNKNOWN
}
public func getErrorCategory(code: String): ErrorCategory {
    match (code) {
        case "PARSE_ERROR" => ErrorCategory.PARSER

        case "TABLE_NOT_FOUND" => ErrorCategory.SEMANTIC
        case "COLUMN_NOT_FOUND" => ErrorCategory.SEMANTIC
        case "TYPE_MISMATCH" => ErrorCategory.SEMANTIC

        case "INVALID_CSV_QUOTE" => ErrorCategory.STORAGE
        case "CSV_LOAD_ERROR" => ErrorCategory.STORAGE
        case "INVALID_CSV_ROW" => ErrorCategory.STORAGE
        case "EMPTY_CSV_HEADER" => ErrorCategory.STORAGE
        case "DUPLICATE_CSV_HEADER" => ErrorCategory.STORAGE

        case _ => ErrorCategory.UNKNOWN
    }
}