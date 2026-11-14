package CangjieQueryCompiler.storage
import CangjieQueryCompiler.common.*
import std.collection.*
import std.convert.*
import std.fs.*

public func parseCsvLine(line: String): AppResult<Array<String>> {
    var fields = ArrayList<String>()
    var current = ""
    var inQuotes = false
    var quoteClosed = false
    var fieldStarted = false

    for (ch in line) {
        if (inQuotes) {
            if (ch == 34u8) {
                quoteClosed = true
                inQuotes = false
            } else {
                current += String.fromUtf8([ch])
            }
        } else if (quoteClosed) {
            if (ch == 34u8) {
                current += String.fromUtf8([ch])
                inQuotes = true
                quoteClosed = false
            } else if (ch == 44u8) {
                fields.add(current)
                current = ""
                quoteClosed = false
                fieldStarted = false
            } else if (ch != 13u8) {
                return AppResult.Failure(AppError("INVALID_CSV_QUOTE", "Invalid CSV quotation marks."))
            }
        } else {
            if (ch == 34u8) {
                if (fieldStarted) {
                    return AppResult.Failure(AppError("INVALID_CSV_QUOTE", "Invalid CSV quotation marks."))
                }
                inQuotes = true
                fieldStarted = true
            } else if (ch == 44u8) {
                fields.add(current)
                current = ""
                fieldStarted = false
            } else if (ch != 13u8) {
                current += String.fromUtf8([ch])
                fieldStarted = true
            }
        }
    }

    if (inQuotes) {
        return AppResult.Failure(AppError("INVALID_CSV_QUOTE", "Invalid CSV quotation marks."))
    }

    fields.add(current)
    return AppResult.Success(fields.toArray())
}
public func parseCsvContent(content: String): AppResult<Array<Array<String>>> {
    var rows = ArrayList<Array<String>>()
    var recordStartLines = ArrayList<Int64>()

    var record = ""
    var inQuotes = false
    var quoteClosed = false

    var currentLine: Int64 = 1
    var recordStartLine: Int64 = 1

    for (ch in content) {
        if (inQuotes) {
            record += String.fromUtf8([ch])

            if (ch == 34u8) {
                quoteClosed = true
                inQuotes = false
            } else if (ch == 10u8) {
                currentLine += 1
            }
        } else if (quoteClosed) {
            if (ch == 34u8) {
                record += String.fromUtf8([ch])
                inQuotes = true
                quoteClosed = false
            } else if (ch == 44u8) {
                record += String.fromUtf8([ch])
                quoteClosed = false
            } else if (ch == 10u8) {
                match (parseCsvLine(record)) {
                    case AppResult.Success(fields) =>
                        rows.add(fields)
                        recordStartLines.add(recordStartLine)
                    case AppResult.Failure(error) =>
                        return AppResult.Failure(error)
                }

                record = ""
                quoteClosed = false
                currentLine += 1
                recordStartLine = currentLine
            } else {
                record += String.fromUtf8([ch])
            }
        } else {
            if (ch == 34u8) {
                inQuotes = true
                record += String.fromUtf8([ch])
            } else if (ch == 10u8) {
                if (record != "") {
                    match (parseCsvLine(record)) {
                        case AppResult.Success(fields) =>
                            rows.add(fields)
                            recordStartLines.add(recordStartLine)
                        case AppResult.Failure(error) =>
                            return AppResult.Failure(error)
                    }
                }

                record = ""
                currentLine += 1
                recordStartLine = currentLine
            } else {
                record += String.fromUtf8([ch])
            }
        }
    }

    if (inQuotes) {
        return AppResult.Failure(AppError("INVALID_CSV_QUOTE", "Invalid CSV quotation marks."))
    }

    if (record != "") {
        match (parseCsvLine(record)) {
            case AppResult.Success(fields) =>
                rows.add(fields)
                recordStartLines.add(recordStartLine)
            case AppResult.Failure(error) =>
                return AppResult.Failure(error)
        }
    }

    if (rows.size == 0) {
        return AppResult.Success([])
    }

    let columnCount = rows[0].size

    for (i in 1..rows.size) {
        if (rows[i].size != columnCount) {
            return AppResult.Failure(
                AppError("INVALID_CSV_ROW","CSV row " + recordStartLines[i].toString() + " has an incorrect number of fields."))
        }
    }

    return AppResult.Success(rows.toArray())
}
public func parseCsvValue(text: String): Value {
    if (text == "") {
        return Value.Null
    }

    match (Bool.tryParse(text)) {
        case Some(value) => return Value.Boolean(value)
        case None => ()
    }

    match (Int64.tryParse(text)) {
        case Some(value) => return Value.Integer(value)
        case None => ()
    }

    match (Float64.tryParse(text)) {
        case Some(value) => return Value.Float(value)
        case None => ()
    }

    return Value.String(text)
}
func validateCsvHeader(columns: Array<String>): AppResult<Unit> {
    for (i in 0..columns.size) {
        if (columns[i] == "") {
            return AppResult.Failure(AppError("EMPTY_CSV_HEADER", "CSV header contains an empty column name."))
        }

        for (j in 0..i) {
            if (i != j && columns[i] == columns[j]) {
                return AppResult.Failure(AppError("DUPLICATE_CSV_HEADER", "CSV header contains duplicate column name: " + columns[i]))
            }
        }
    }

    return AppResult.Success(())
}
public func loadCsv(path: String, tableName: String): AppResult<Table> {
    let content = try {
    let bytes = File.readFrom(path)
    var start = 0

    if (bytes.size >= 3 &&
        bytes[0] == 0xEFu8 &&
        bytes[1] == 0xBBu8 &&
        bytes[2] == 0xBFu8) {
        start = 3
    }

    String.fromUtf8(bytes[start..])
    } catch (error: Exception) {
    return AppResult.Failure(AppError("CSV_LOAD_ERROR", "Cannot read CSV file: " + path))
    }

    let parsed = parseCsvContent(content)

        match (parsed) {
        case AppResult.Success(data) =>
        if (data.size == 0) {
        return AppResult.Success(Table(tableName, [], []))
}
        let columns = data[0]

        match (validateCsvHeader(columns)) {
        case AppResult.Success(_) => ()
        case AppResult.Failure(error) =>
        return AppResult.Failure(error)
}

        var rows = ArrayList<Row>()
        for (i in 1..data.size) {
        var values = ArrayList<Value>()
        for (field in data[i]) {
        values.add(parseCsvValue(field))
        }
        rows.add(Row(values.toArray(), data[i]))
}
        return AppResult.Success(Table(tableName, columns, rows.toArray()))
        case AppResult.Failure(error) =>
        return AppResult.Failure(error)
    }
}