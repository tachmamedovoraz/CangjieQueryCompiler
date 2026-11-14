func testCondition(label: String, text: String, shouldPass: Bool) {
    var passed = false

    match (parseCondition(text)) {
        case Some(_) => passed = true
        case None => passed = false
    }

    if (passed == shouldPass) {
        println("PASS: " + label)
    } else {
        println("FAIL: " + label)
    }
}

func testConditionString(label: String, text: String, expectedValue: String) {
    var passed = false

    match (parseCondition(text)) {
        case Some(condition) =>
    match (condition.value) {
        case Value.String(value) =>
            passed = value == expectedValue
        case _ => passed = false
            }
        case None => passed = false
    }

    if (passed) {
        println("PASS: " + label)
    } else {
        println("FAIL: " + label)
    }
}

func testWhere(label: String, text: String, shouldPass: Bool) {
    var passed = false

    match (parseWhereConditions(text)) {
        case Some(_) => passed = true
        case None => passed = false
    }

    if (passed == shouldPass) {
        println("PASS: " + label)
    } else {
        println("FAIL: " + label)
    }
}

func testQuery(label: String, text: String, shouldPass: Bool) {
    var passed = false

    match (parseSelectQuery(text)) {
        case AppResult.Success(_) => passed = true
        case AppResult.Failure(_) => passed = false
    }

    if (passed == shouldPass) {
        println("PASS: " + label)
    } else {
        println("FAIL: " + label)
    }
}

main() {
    println("========== 1. UNCLOSED QUOTES ==========")

    testCondition("Unclosed single quote", "name = 'Alice", false)
    testCondition("Unclosed double quote", "name = \"Alice", false)
    testQuery("Unclosed quote in SQL","SELECT * FROM students WHERE name = 'Alice",false)
    testQuery("Unclosed quote before AND","SELECT * FROM students WHERE name = 'Alice AND age >= 19",false)

    println("\n========== 2. ESCAPED QUOTES ==========")

    testConditionString("Single quote escaping","name = 'John''s book'","John's book")
    testConditionString("Double quote empty string","name = \"\"","")
    testConditionString("Single quote empty string","name = ''","")
    testWhere("AND after escaped apostrophe","name = 'John''s AND book' AND age >= 18",true)
    testQuery("Quoted SQL keywords","SELECT * FROM students WHERE name = 'WHERE AND ORDER BY'",true)

    println("\n========== 3. STRING VALUE VALIDATION ==========")

    testConditionString("Preserve multiple spaces","name = 'John    Smith'","John    Smith")
    testConditionString("Preserve leading space","name = ' Alice'"," Alice")
    testConditionString("Preserve trailing space","name = 'Alice '","Alice ")
    testCondition("Normal quoted string", "name = 'Alice'", true)
    testCondition("Text after quoted string", "name = 'Alice' extra", false)
    testCondition("Unquoted string value", "name = Alice", true)

    println("\n========== 4. TABLE AND COLUMN NAMES ==========")

    testQuery("Normal table name", "SELECT * FROM students", true)
    testQuery("Empty table name", "SELECT * FROM", false)
    testQuery("Extra table tokens", "SELECT * FROM students extra", false)
    testQuery("Invalid table name", "SELECT * FROM students-name", false)
    testQuery("Normal column name", "SELECT name FROM students", true)
    testQuery("Invalid column symbol", "SELECT name$ FROM students", false)
    testQuery("Numeric column name", "SELECT 123 FROM students", false)

    println("\n========== 5. UNSUPPORTED SQL CLAUSES ==========")

    testQuery("ORDER BY rejection","SELECT * FROM students ORDER BY age",false)
    testQuery("GROUP BY rejection","SELECT * FROM students GROUP BY age",false)
    testQuery("LIMIT rejection","SELECT * FROM students LIMIT 10",false)
    testQuery("JOIN rejection","SELECT * FROM students JOIN departments",false)
    testQuery("OR rejection","SELECT * FROM students WHERE age >= 19 OR score >= 80",false)
    testQuery("Repeated WHERE rejection","SELECT * FROM students WHERE age >= 19 WHERE score >= 80",false)
    testQuery("ORDER BY after WHERE","SELECT * FROM students WHERE age >= 19 ORDER BY age",false)

    println("\n========== 6. QUOTED AND CONDITIONS ==========")

    testWhere("AND inside string","name = 'Rock AND Roll' AND age >= 19",true)
    testWhere("Multiple quoted conditions","name = 'John''s book' AND age >= 18",true)
    testWhere("Normal multiple conditions","age >= 18 AND score >= 80 AND id != 3",true)

        println("\n========== 7. SEMICOLON SUPPORT ==========")

    testQuery("Semicolon at query end","SELECT * FROM students;",true)
    testQuery("Space before semicolon","SELECT * FROM students ;",true)
    testQuery("Semicolon after WHERE","SELECT * FROM students WHERE age >= 19;",true)
    testQuery("Semicolon inside string","SELECT * FROM students WHERE name = 'Alice;'",true)
    testQuery("Semicolon after escaped quote","SELECT * FROM students WHERE name = 'John''s book';",true)
    testQuery("Double semicolon","SELECT * FROM students;;",false)
    testQuery("Two SQL statements","SELECT * FROM students; SELECT * FROM teachers",false)
    testQuery("Only semicolon",";",false)
    testQuery("Empty query","",false)
    testQuery("Semicolon before query","; SELECT * FROM students",false)

        println("\n========== 8. MALFORMED SQL ==========")

    testQuery("Missing SELECT", "FROM students", false)
    testQuery("Missing FROM", "SELECT * students", false)
    testQuery("Missing column list", "SELECT FROM students", false)
    testQuery("Missing table name", "SELECT * FROM", false)
    testQuery("Empty WHERE", "SELECT * FROM students WHERE", false)
    testQuery("Missing comparison value", "SELECT * FROM students WHERE age >=", false)
    testQuery("Missing comparison operator", "SELECT * FROM students WHERE age 19", false)
    testQuery("Trailing AND", "SELECT * FROM students WHERE age >= 19 AND", false)
    testQuery("Leading AND", "SELECT * FROM students WHERE AND age >= 19", false)
    testQuery("Duplicate FROM", "SELECT * FROM students FROM teachers", false)
    testQuery("Invalid operator", "SELECT * FROM students WHERE age => 19", false)
    testQuery("Mixed wildcard and column", "SELECT *, name FROM students", false)
    testQuery("Empty column between commas","SELECT name,,age FROM students",false)
    testQuery("Leading comma in columns","SELECT ,name FROM students",false)
    testQuery("Trailing comma in columns","SELECT name, FROM students",false)
    testQuery("Repeated wildcard","SELECT *, * FROM students",false)
    testQuery("Repeated AND","SELECT * FROM students WHERE age >= 19 AND AND score >= 80",false)
    testQuery("Incomplete second condition","SELECT * FROM students WHERE age >= 19 AND score >=",false)
    testQuery("Repeated comparison operator","SELECT * FROM students WHERE age === 19",false)
    testQuery("Invalid comparison operator order","SELECT * FROM students WHERE age >< 19",false)

    println("\n========== 9. WHITESPACE AROUND OPERATORS ==========")

    testQuery("No spaces around operator","SELECT * FROM students WHERE age>=19",true)
    testQuery("Space before operator","SELECT * FROM students WHERE age >=19",true)
    testQuery("Space after operator","SELECT * FROM students WHERE age>= 19",true)
    testQuery("Multiple spaces around operator","SELECT * FROM students WHERE age   >=   19",true)
    testQuery("Multiple spaces around AND","SELECT * FROM students WHERE age >= 19    AND    score >= 80",true)
    testQuery("No spaces around AND","SELECT * FROM students WHERE age >= 19 AND score >= 80",true)
    testQuery("Tabs around operator","SELECT * FROM students WHERE age\t>=\t19",true)
    testQuery("Spaces before semicolon","SELECT * FROM students WHERE age >= 19   ;",true)

    println("\n========== 10. STRING EDGE CASES ==========")

    testQuery("Empty single-quoted string","SELECT * FROM students WHERE name = ''",true)
    testQuery("Empty double-quoted string","SELECT * FROM students WHERE name = \"\"",true)
    testQuery("String containing AND","SELECT * FROM students WHERE name = 'A AND B'",true)
    testQuery("String containing OR","SELECT * FROM students WHERE name = 'A OR B'",true)
    testQuery("String containing semicolon","SELECT * FROM students WHERE name = 'A;B'",true)
    testQuery("String containing comparison symbols","SELECT * FROM students WHERE name = 'A >= B'",true)
    testQuery("String containing multiple spaces","SELECT * FROM students WHERE name = 'John    Smith'",true)
    testQuery("String containing escaped apostrophe","SELECT * FROM students WHERE name = 'O''Brien'",true)
    testQuery("String containing only spaces","SELECT * FROM students WHERE name = '   '",true)

    println("\n========== 11. NUMERIC EDGE CASES ==========")

    testQuery("Zero value","SELECT * FROM students WHERE age = 0",true)
    testQuery("Negative integer","SELECT * FROM students WHERE age = -1",true)
    testQuery("Negative comparison","SELECT * FROM students WHERE age > -10",true)
    testQuery("Positive decimal","SELECT * FROM students WHERE score > 85.5",true)
    testQuery("Negative decimal","SELECT * FROM students WHERE score < -0.5",true)
    testQuery("Zero decimal","SELECT * FROM students WHERE score = 0.0",true)
    testQuery("Large integer","SELECT * FROM students WHERE age > 999999999",true)
    testQuery("Decimal comparison operator","SELECT * FROM students WHERE score >= 87.25",true)

    println("\n========== 12. INVALID OPERATOR COMBINATIONS ==========")

    testQuery("Triple equal","SELECT * FROM students WHERE age === 19",false)
    testQuery("Greater then less","SELECT * FROM students WHERE age >< 19",false)
    testQuery("Equal then greater","SELECT * FROM students WHERE age => 19",false)
    testQuery("Equal then less","SELECT * FROM students WHERE age =< 19",false)
    testQuery("Triple greater","SELECT * FROM students WHERE age >>> 19",false)
    testQuery("Triple less","SELECT * FROM students WHERE age <<< 19",false)
    testQuery("Double equal","SELECT * FROM students WHERE age == 19",false)
    testQuery("Operator without value","SELECT * FROM students WHERE age >=",false)
    testQuery("Operator without column","SELECT * FROM students WHERE >= 19",false)
    testQuery("Two operators with spaces","SELECT * FROM students WHERE age > = 19",false)
    
    println("\n========== ALL STRESS TESTS COMPLETED ==========")
}