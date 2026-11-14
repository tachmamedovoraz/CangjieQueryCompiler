package CangjieQueryCompiler.parser
import CangjieQueryCompiler.common.*
import std.collection.*
import std.convert.*

func normalizeWhitespace(text: String): String {
    var result = ""
    var started = false
    var pendingSpace = false
    var singleQuote = false
    var doubleQuote = false
    var i = 0
    while (i < text.size) {
        let ch = text[i]
        if (ch == 39u8 && !doubleQuote) {
            if (
                singleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 39u8
            ) {
                if (pendingSpace) {
                    result += " "
                    pendingSpace = false
                }
                result += text[i..(i + 1)]
                result += text[(i + 1)..(i + 2)]
                i += 2
                continue
            }
            if (pendingSpace) {
                result += " "
                pendingSpace = false
            }
            result += String.fromUtf8([ch])
            singleQuote = !singleQuote
            started = true
        } else if (ch == 34u8 && !singleQuote) {
            if (
                doubleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 34u8
            ) {
                if (pendingSpace) {
                    result += " "
                    pendingSpace = false
                }
                result += text[i..(i + 1)]
                result += text[(i + 1)..(i + 2)]
                i += 2
                continue
            }
            if (pendingSpace) {
                result += " "
                pendingSpace = false
            }
            result += String.fromUtf8([ch])
            doubleQuote = !doubleQuote
            started = true
        } else if (
            !singleQuote &&
            !doubleQuote &&
            (ch == 32u8 || ch == 9u8 || ch == 10u8 || ch == 13u8)
        ) {
            if (started) {
                pendingSpace = true
            }
        } else {
            if (pendingSpace) {
                result += " "
                pendingSpace = false
            }
            result += String.fromUtf8([ch])
            started = true
        }
        i += 1
    }
    return result
}
func toLowerAscii(text: String): String {
    var result = ""

    for (ch in text) {
        if (ch >= 65u8 && ch <= 90u8) {
            result += String.fromUtf8([ch + 32u8])
        } else {
            result += String.fromUtf8([ch])
        }
    }
    return result
}
func isIdentifierChar(ch: UInt8): Bool {
    return (
        (ch >= 65u8 && ch <= 90u8) ||
        (ch >= 97u8 && ch <= 122u8) ||
        (ch >= 48u8 && ch <= 57u8) ||
        ch == 95u8
    )
}
func isValidIdentifier(text: String): Bool {
    if (text.size == 0) {
        return false
    }
    let first = text[0]
    if (
        !(
            (first >= 65u8 && first <= 90u8) ||
            (first >= 97u8 && first <= 122u8) ||
            first == 95u8
        )
    ) {
        return false
    }
    var i = 1
    while (i < text.size) {
        if (!isIdentifierChar(text[i])) {
            return false
        }
        i += 1
    }
    return true
}
func isInsideQuotes(text: String, position: Int64): Bool {
    var singleQuote = false
    var doubleQuote = false
    var i = 0
    while (i < position) {
        if (text[i] == 39u8 && !doubleQuote) {
            singleQuote = !singleQuote
        } else if (text[i] == 34u8 && !singleQuote) {
            doubleQuote = !doubleQuote
        }
        i += 1
    }
    return singleQuote || doubleQuote
}
func hasUnclosedQuotes(text: String): Bool {
    var singleQuote = false
    var doubleQuote = false
    var i = 0
    while (i < text.size) {
        let ch = text[i]
        if (ch == 39u8 && !doubleQuote) {
            if (
                singleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 39u8
            ) {
                i += 2
                continue
            }
            singleQuote = !singleQuote
        } else if (ch == 34u8 && !singleQuote) {
            if (
                doubleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 34u8
            ) {
                i += 2
                continue
            }
            doubleQuote = !doubleQuote
        }
        i += 1
    }
    return singleQuote || doubleQuote
}
func findKeyword(text: String, keyword: String): Int64 {
    let lowerText = toLowerAscii(text)
    let lowerKeyword = toLowerAscii(keyword)
    if (lowerKeyword.size > lowerText.size) {
        return -1
    }
    var i = 0
    while (i <= lowerText.size - lowerKeyword.size) {
        let insideQuotes = isInsideQuotes(text, Int64(i))
        if (!insideQuotes) {
            let part = lowerText[i..(i + lowerKeyword.size)]
            if (part == lowerKeyword) {
                let leftValid = (
                    i == 0 ||
                    !isIdentifierChar(lowerText[i - 1])
                )
                let end = i + lowerKeyword.size
                let rightValid = (
                    end == lowerText.size ||
                    !isIdentifierChar(lowerText[end])
                )
                if (leftValid && rightValid) {
                    return Int64(i)
                }
            }
        }
        i += 1
    }
    return -1
}
func findKeywordEnd(text: String, keyword: String): Int64 {
    let position = findKeyword(text, keyword)
    if (position < 0) {
        return -1
    }
    return position + Int64(keyword.size)
}
func parseSelectColumns(text: String): Array<String> {
    let normalized = normalizeWhitespace(text)
    if (normalized.size == 0) {
        return []
    }
    if (normalized == "*") {
        return ["*"]
    }
    var columns = ArrayList<String>()
    for (column in normalized.split(",")) {
        let normalizedColumn = normalizeWhitespace(column)
        if (normalizedColumn.size == 0) {
            return []
        }
        columns.add(normalizedColumn)
    }
    return columns.toArray()
}
func parseFromTableName(text: String): String {
    let normalized = normalizeWhitespace(text)
    let parts = normalized.split(" ")
    return parts[1]
}
func parseComparisonOperator(text: String): ComparisonOperator {
    if (text == "=") {
        return ComparisonOperator.Equal
    } else if (text == "!=") {
        return ComparisonOperator.NotEqual
    } else if (text == ">") {
        return ComparisonOperator.Greater
    } else if (text == "<") {
        return ComparisonOperator.Less
    } else if (text == ">=") {
        return ComparisonOperator.GreaterOrEqual
    } else {
        return ComparisonOperator.LessOrEqual
    }
}
func splitWhereConditions(text: String): Array<String> {
    let normalized = normalizeWhitespace(text)
    var conditions = ArrayList<String>()
    var start = 0
    var i = 0
    while (i + 3 <= normalized.size) {
        let insideQuotes = isInsideQuotes(normalized, Int64(i))
        if (!insideQuotes) {
            let part = toLowerAscii(normalized[i..(i + 3)])
            if (part == "and") {
                let leftValid = (
                    i == 0 ||
                    !isIdentifierChar(normalized[i - 1])
                )
                let end = i + 3
                let rightValid = (
                    end == normalized.size ||
                    !isIdentifierChar(normalized[end])
                )
                if (leftValid && rightValid) {
                    conditions.add(
                        normalizeWhitespace(normalized[start..i])
                    )
                    start = end
                    i = end
                    continue
                }
            }
        }
        i += 1
    }
    conditions.add(
        normalizeWhitespace(normalized[start..normalized.size])
    )
    return conditions.toArray()
}
func parseLiteralValue(text: String): Value {
    let normalized = normalizeWhitespace(text)
    if (normalized.size >= 2) {
        let quoteChar = normalized[0]
        if (
            (quoteChar == 39u8 || quoteChar == 34u8) &&
            normalized[normalized.size - 1] == quoteChar
        ) {
            var value = ""
            var i = 1
            while (i < normalized.size - 1) {
                if (
                    normalized[i] == quoteChar &&
                    i + 1 < normalized.size - 1 &&
                    normalized[i + 1] == quoteChar
                ) {
                    value += normalized[i..(i + 1)]
                    i += 2
                } else {
                    value += normalized[i..(i + 1)]
                    i += 1
                }
            }
            return Value.String(value)
        }
    }
    match (Bool.tryParse(normalized)) {
        case Some(value) => return Value.Boolean(value)
        case None => ()
    }
    match (Int64.tryParse(normalized)) {
        case Some(value) => return Value.Integer(value)
        case None => ()
    }
    match (Float64.tryParse(normalized)) {
        case Some(value) => return Value.Float(value)
        case None => ()
    }
    return Value.String(normalized)
}
func parseCondition(text: String): Option<Condition> {
    let normalized = normalizeWhitespace(text)

    if (hasUnclosedQuotes(normalized)) {
    return None
    }
    let operators = [">=", "<=", "!=", "=", ">", "<"]
    var i = 0
    while (i < normalized.size) {

    if (!isInsideQuotes(normalized, Int64(i))) {
    for (opText in operators) {

    if (i + opText.size <= normalized.size) {
    let part = normalized[i..(i + opText.size)]

    if (part == opText) {
    let end = i + opText.size
    let leftIsOperator = (
        i > 0 && (
            normalized[i - 1] == 61u8 ||
            normalized[i - 1] == 33u8 ||
            normalized[i - 1] == 62u8 ||
            normalized[i - 1] == 60u8
        )
    )
    let rightIsOperator = (
        end < normalized.size && (
            normalized[end] == 61u8 ||
            normalized[end] == 33u8 ||
            normalized[end] == 62u8 ||
            normalized[end] == 60u8
        )
    )

    if (leftIsOperator || rightIsOperator) {
        return None
    }
    let columnName = normalizeWhitespace(normalized[0..i])
    let valueText = normalizeWhitespace(normalized[(i + opText.size)..normalized.size])

    if (!isValidIdentifier(columnName) || valueText.size == 0) {
    return None
    }
    if (
    valueText[0] == 61u8 ||
    valueText[0] == 33u8 ||
    valueText[0] == 62u8 ||
    valueText[0] == 60u8
    ) {
    return None
    }

    if (valueText[0] == 39u8 || valueText[0] == 34u8) {

    if (valueText.size < 2 || valueText[valueText.size - 1] != valueText[0]) {
        return None
    }
    }
    let op = parseComparisonOperator(opText)
    let value = parseLiteralValue(valueText)
                        return Some(Condition(columnName, op, value))
                    }
                }
            }
        }
        i += 1
    }
    return None
}
func parseWhereConditions(text: String): Option<Array<Condition>> {
    let parts = splitWhereConditions(text)
    var conditions = ArrayList<Condition>()
    for (part in parts) {
        match (parseCondition(part)) {
            case Some(condition) =>
                conditions.add(condition)
            case None =>
            return None
        }
    }
    return Some(conditions.toArray())
}
func hasSemicolonOutsideQuotes(text: String): Bool {
    var singleQuote = false
    var doubleQuote = false
    var i = 0
    while (i < text.size) {
        let ch = text[i]
        if (ch == 39u8 && !doubleQuote) {
            if (
                singleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 39u8
            ) {
                i += 2
                continue
            }
            singleQuote = !singleQuote
        } else if (ch == 34u8 && !singleQuote) {
            if (
                doubleQuote &&
                i + 1 < text.size &&
                text[i + 1] == 34u8
            ) {
                i += 2
                continue
            }
            doubleQuote = !doubleQuote
        } else if (ch == 59u8 && !singleQuote && !doubleQuote) {
            return true
        }
        i += 1
    }
    return false
}
protected func parseSelectQuery(text: String): AppResult<SelectQuery> {
    var normalized = normalizeWhitespace(text)
    if (normalized.size == 0) {
    return AppResult.Failure(AppError("PARSE_ERROR", "Empty SQL query."))
    }
    if (hasUnclosedQuotes(normalized)) {
        return AppResult.Failure(AppError("PARSE_ERROR", "Unclosed quotation marks."))
    }
    if (hasSemicolonOutsideQuotes(normalized)) {
        if (normalized[normalized.size - 1] != 59u8) 
            {
            return AppResult.Failure(AppError("PARSE_ERROR", "Unexpected semicolon."))
        }
        normalized = normalizeWhitespace(normalized[0..(normalized.size - 1)])
        if (hasSemicolonOutsideQuotes(normalized)) 
        {
            return AppResult.Failure(AppError("PARSE_ERROR", "Multiple SQL statements are not supported."))
        }
    }
    if (normalized.size == 0) {
    return AppResult.Failure(AppError("PARSE_ERROR", "Empty SQL query."))
    }
    let selectPosition = findKeyword(normalized, "SELECT")
    let selectEnd = findKeywordEnd(normalized, "SELECT")
    let fromPosition = findKeyword(normalized, "FROM")
    let wherePosition = findKeyword(normalized, "WHERE")
    if (selectPosition != 0 || fromPosition < selectEnd) {
        return AppResult.Failure(AppError("PARSE_ERROR", "Invalid SELECT or FROM clause."))
    }
    if (wherePosition >= 0 && wherePosition < fromPosition) {
        return AppResult.Failure(AppError("PARSE_ERROR", "Invalid WHERE clause."))
    }
    if (findKeyword(normalized, "OR") >= 0) {
    return AppResult.Failure(AppError("PARSE_ERROR", "OR operator is not supported."))
    }
    if (wherePosition >= 0) {
    let validationWhereText = normalized[(wherePosition + 5)..normalized.size]
    if (findKeyword(validationWhereText, "WHERE") >= 0 || findKeyword(validationWhereText, "ORDER") >= 0) 
    {
        return AppResult.Failure(AppError("PARSE_ERROR", "Unsupported or repeated SQL clause."))
    }
    }
    let selectPart = normalized[selectEnd..fromPosition]
    let columns = parseSelectColumns(selectPart)
    if (columns.size == 0) {
    return AppResult.Failure(AppError("PARSE_ERROR", "Missing column list after SELECT."))
    }
    for (column in columns) {
    if (column != "*" && !isValidIdentifier(column)) {
        return AppResult.Failure(AppError("PARSE_ERROR", "Invalid column name."))
        }
    }
    var hasWildcard = false
    for (column in columns) {
    if (column == "*") {
        hasWildcard = true
        }
    }
    if (hasWildcard && columns.size != 1) {
        return AppResult.Failure(AppError("PARSE_ERROR", "Wildcard cannot be combined with other columns."))
    }
    var selectAll = false
    var selectedColumns = columns
    if (columns.size == 1 && columns[0] == "*") {
        selectAll = true
        selectedColumns = []
    }
    let fromStart = fromPosition + 4
    var tablePart = ""
    if (wherePosition >= 0) {
        tablePart = normalized[fromStart..wherePosition]
    } else {
        tablePart = normalized[fromStart..normalized.size]
    }
    tablePart = normalizeWhitespace(tablePart)
    if (tablePart.size == 0) {

        return AppResult.Failure(AppError("PARSE_ERROR", "Missing table name."))
    }
    if (!isValidIdentifier(tablePart)) {

        return AppResult.Failure(AppError("PARSE_ERROR", "Invalid table name."))
    }
    let tableName = parseFromTableName("FROM " + tablePart)
    var conditions = ArrayList<Condition>()
    if (wherePosition >= 0) {
        let whereStart = wherePosition + 5
        let whereText = normalized[whereStart..normalized.size]
        match (parseWhereConditions(whereText)) {
            case Some(parsedConditions) =>
                for (condition in parsedConditions) {
                    conditions.add(condition)
                }
            case None =>
                return AppResult.Failure(AppError("PARSE_ERROR", "Invalid WHERE condition."))
        }
    }
    let query = SelectQuery(tableName,selectAll,selectedColumns,conditions.toArray())
    return AppResult.Success(query)
}