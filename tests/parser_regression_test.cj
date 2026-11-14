import std.collection.*
func testQuery(label: String, text: String, shouldPass: Bool) {
    let result = parseSelectQuery(text)
    var passed = false
    match (result) {
        case AppResult.Success(_) =>
            passed = true
        case AppResult.Failure(_) =>
            passed = false
    }
    if (passed == shouldPass) {
        println("PASS: " + label)
    } else {
        println("FAIL: " + label)
    }
}
main() {
    println("========== VALID QUERIES ==========")

    testQuery("Select all", "SELECT * FROM students", true)
    testQuery("Select one column", "SELECT name FROM students", true)
    testQuery("Select multiple columns", "SELECT name, age FROM students", true)
    testQuery("Select with equality", "SELECT * FROM students WHERE age = 19", true)
    testQuery("Select with not equal", "SELECT * FROM students WHERE age != 19", true)
    testQuery("Select with greater", "SELECT * FROM students WHERE age > 19", true)
    testQuery("Select with less", "SELECT * FROM students WHERE age < 19", true)
    testQuery("Select with greater or equal", "SELECT * FROM students WHERE age >= 19", true)
    testQuery("Select with less or equal", "SELECT * FROM students WHERE age <= 19", true)
    testQuery("Select with AND", "SELECT * FROM students WHERE age >= 19 AND score >= 80", true)
    testQuery("Case insensitive keywords", "select name from students", true)
    testQuery("Mixed keyword case", "SeLeCt name FrOm students WhErE age >= 19", true)
    testQuery("Extra whitespace", "  SELECT   name , age   FROM   students  ", true)
    testQuery("Semicolon at end", "SELECT * FROM students;", true)
    testQuery("Quoted string", "SELECT * FROM students WHERE name = 'Alice'", true)
    testQuery("String with spaces", "SELECT * FROM students WHERE name = 'John Smith'", true)
    testQuery("AND inside string", "SELECT * FROM students WHERE name = 'Rock AND Roll'", true)
    testQuery("Semicolon inside string", "SELECT * FROM students WHERE name = 'A;B';", true)

    println("\\n========== INVALID QUERIES ==========")

    testQuery("Empty query", "", false)
    testQuery("Only whitespace", "     ", false)
    testQuery("Missing SELECT", "FROM students", false)
    testQuery("Missing FROM", "SELECT name", false)
    testQuery("Missing table", "SELECT * FROM", false)
    testQuery("Missing WHERE value", "SELECT * FROM students WHERE age =", false)
    testQuery("Missing WHERE column", "SELECT * FROM students WHERE = 19", false)
    testQuery("Unsupported OR", "SELECT * FROM students WHERE age > 19 OR score > 80", false)
    testQuery("Unsupported ORDER BY", "SELECT * FROM students ORDER BY age", false)
    testQuery("Unsupported GROUP BY", "SELECT * FROM students GROUP BY age", false)
    testQuery("Multiple statements", "SELECT * FROM students; SELECT * FROM teachers;", false)
    testQuery("Unclosed string", "SELECT * FROM students WHERE name = 'Alice", false)
    testQuery("Wildcard with column", "SELECT *, name FROM students", false)
    testQuery("Empty column", "SELECT name,,age FROM students", false)
    testQuery("Repeated AND", "SELECT * FROM students WHERE age > 18 AND AND score > 80", false)

    println("\\n========== REGRESSION TESTS COMPLETED ==========")
}