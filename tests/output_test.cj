main() {
    let resultColumns = ["name", "score"]

    let resultRows = [
        Row([Value.String("Alice"), Value.Integer(91)]),
        Row([Value.String("Chen"), Value.Integer(88)])
    ]

    let queryResult = QueryResult(resultColumns, resultRows)

    printQueryResult(queryResult)
}