package CangjieQueryCompiler.executor
import CangjieQueryCompiler.common.*
import CangjieQueryCompiler.filter.*
import std.collection.*

func getSelectedColumnIndexes(
    query: SelectQuery,
    table: Table
): Array<Int64> {
    var indexes = ArrayList<Int64>()

    if (query.selectAll) {
        var index: Int64 = 0

        for (column in table.columns) {
            indexes.add(index)
            index += 1
        }

        return indexes.toArray()
    }

    for (selectedColumn in query.selectedColumns) {
        var index: Int64 = 0

        for (tableColumn in table.columns) {
            if (selectedColumn == tableColumn) {
                indexes.add(index)
                break
            }

            index += 1
        }
    }

    return indexes.toArray()
}
func projectRow(
    row: Row,
    indexes: Array<Int64>
): Row {
    var values = ArrayList<Value>()
    var originalValues = ArrayList<String>()

    for (index in indexes) {
        values.add(row.values[index])

        if (row.originalValues.size > index) {
            originalValues.add(row.originalValues[index])
        }
    }

    if (row.originalValues.size == 0) {
        return Row(values.toArray())
    }

    return Row(values.toArray(), originalValues.toArray())
}
public func executeQuery(
    query: SelectQuery,
    table: Table
): QueryResult {
    let indexes = getSelectedColumnIndexes(query, table)

    let filteredRows = filterRows(table, query.conditions)

    var resultRows = ArrayList<Row>()

    for (row in filteredRows) {
        resultRows.add(projectRow(row, indexes))
    }

    var resultColumns = ArrayList<String>()

    for (index in indexes) {
        resultColumns.add(table.columns[index])
    }

    return QueryResult(
        resultColumns.toArray(),
        resultRows.toArray()
    )
}