package CangjieQueryCompiler.parser
import CangjieQueryCompiler.common.*

@Test
func testFindKeyword() {@Expect(findKeyword("SELECT name", "SELECT"), 0)}
@Test
func testFindKeywordCaseInsensitive() {@Expect(findKeyword("select name", "SELECT"), 0)}
@Test
func testFindKeywordBoundary() {@Expect(findKeyword("SELECTX name", "SELECT"), -1)}
@Test
func testFindKeywordEnd() {@Expect(findKeywordEnd("SELECT name FROM students", "SELECT"), 6)}
@Test
func testFindKeywordEndFrom() {@Expect(findKeywordEnd("SELECT name FROM students", "FROM"), 16)}
@Test
func testFindKeywordWhere() {
    @Expect(findKeyword("SELECT name FROM students WHERE age > 18", "WHERE"),26)}
@Test
func testFindKeywordNotFound() {@Expect(findKeyword("SELECT name FROM students", "WHERE"),-1)}
@Test
func testFindKeywordInsideIdentifier() {@Expect(findKeyword("MYSELECT name", "SELECT"),-1)}
@Test
func testParseSelectAll() {
    let result = parseSelectQuery("SELECT * FROM students")

    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.selectAll, true)
            @Expect(query.selectedColumns.size, 0)
            @Expect(query.conditions.size, 0)
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseSelectedColumns() {
    let result = parseSelectQuery("SELECT name, age FROM students")

    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.selectAll, false)
            @Expect(query.selectedColumns.size, 2)
            @Expect(query.selectedColumns[0], "name")
            @Expect(query.selectedColumns[1], "age")
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseWhereCondition() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age > 18")

    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.conditions.size, 1)
            @Expect(query.conditions[0].columnName, "age")
            match (query.conditions[0].op) {
    case ComparisonOperator.Greater =>
        @Expect(true, true)
    case _ =>
        @Expect(false, true)
}

            match (query.conditions[0].value) {
                case Value.Integer(number) =>
                    @Expect(number, 18)
                case _ =>
                    @Expect(false, true)
            }
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseWhereEqual() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age = 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.conditions.size, 1)
            match (query.conditions[0].op) {
                case ComparisonOperator.Equal => @Expect(true, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereNotEqual() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age != 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.conditions.size, 1)
            match (query.conditions[0].op) {
                case ComparisonOperator.NotEqual => @Expect(true, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereLess() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age < 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.conditions.size, 1)
            match (query.conditions[0].op) {
                case ComparisonOperator.Less => @Expect(true, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereGreaterOrEqual() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age >= 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.conditions.size, 1)
            match (query.conditions[0].op) {
                case ComparisonOperator.GreaterOrEqual => @Expect(true, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereLessOrEqual() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age <= 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.conditions.size, 1)
            match (query.conditions[0].op) {
                case ComparisonOperator.LessOrEqual => @Expect(true, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereStringValue() {
    let result = parseSelectQuery("SELECT * FROM students WHERE name = 'Alice'")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.String(value) => @Expect(value, "Alice")
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereDoubleQuotedString() {
    let result = parseSelectQuery("SELECT * FROM students WHERE name = \"Alice\"")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.String(value) => @Expect(value, "Alice")
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereFloatValue() {
    let result = parseSelectQuery("SELECT * FROM students WHERE score > 85.5")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Float(value) => @Expect(value, 85.5)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereNegativeInteger() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age > -18")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Integer(value) => @Expect(value, -18)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereBooleanTrue() {
    let result = parseSelectQuery("SELECT * FROM students WHERE active = true")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Boolean(value) => @Expect(value, true)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereBooleanFalse() {
    let result = parseSelectQuery("SELECT * FROM students WHERE active = false")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Boolean(value) => @Expect(value, false)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereNullCurrentBehavior() {
    let result = parseSelectQuery("SELECT * FROM students WHERE name = NULL")
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.String(value) => @Expect(value, "NULL")
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseLowercaseKeywords() {
    let result = parseSelectQuery("select * from students")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.selectAll, true)
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseMixedCaseKeywords() {
    let result = parseSelectQuery("SeLeCt * FrOm students WhErE age > 18")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.conditions.size, 1)
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseMultipleSpaces() {
    let result = parseSelectQuery("SELECT    name,    age    FROM    students")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.selectedColumns.size, 2)
            @Expect(query.selectedColumns[0], "name")
            @Expect(query.selectedColumns[1], "age")
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseLeadingAndTrailingSpaces() {
    let result = parseSelectQuery("   SELECT * FROM students   ")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "students")
            @Expect(query.selectAll, true)
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseSingleSelectedColumn() {
    let result = parseSelectQuery("SELECT name FROM students")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.selectAll, false)
            @Expect(query.selectedColumns.size, 1)
            @Expect(query.selectedColumns[0], "name")
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseMultipleSelectedColumns() {
    let result = parseSelectQuery("SELECT id, name, age FROM students")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.selectedColumns.size, 3)
            @Expect(query.selectedColumns[0], "id")
            @Expect(query.selectedColumns[1], "name")
            @Expect(query.selectedColumns[2], "age")
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseUppercaseIdentifiers() {
    let result = parseSelectQuery("SELECT NAME, AGE FROM STUDENTS")
    match (result) {
        case AppResult.Success(query) =>
            @Expect(query.tableName, "STUDENTS")
            @Expect(query.selectedColumns[0], "NAME")
            @Expect(query.selectedColumns[1], "AGE")
        case AppResult.Failure(_) =>
            @Expect(false, true)
    }
}
@Test
func testParseEmptyQuery() {
    let result = parseSelectQuery("")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhitespaceOnlyQuery() {
    let result = parseSelectQuery("       ")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseMissingSelect() {
    let result = parseSelectQuery("FROM students")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseMissingFrom() {
    let result = parseSelectQuery("SELECT * students")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseMissingTableName() {
    let result = parseSelectQuery("SELECT * FROM")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseMissingColumnList() {
    let result = parseSelectQuery("SELECT FROM students")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseUnclosedSingleQuote() {
    let result = parseSelectQuery("SELECT * FROM students WHERE name = 'Alice")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseUnclosedDoubleQuote() {
    let result = parseSelectQuery("SELECT * FROM students WHERE name = \"Alice")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseMultipleStatements() {
    let result = parseSelectQuery("SELECT * FROM students; SELECT * FROM teachers;")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseUnexpectedSemicolon() {
    let result = parseSelectQuery("SELECT * FROM students; extra")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseRepeatedWhere() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age > 18 WHERE score > 80")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseUnsupportedOr() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age > 18 OR score > 80")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseUnsupportedOrderBy() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age > 18 ORDER BY age")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWildcardWithOtherColumns() {
    let result = parseSelectQuery("SELECT *, name FROM students")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseInvalidWhereCondition() {
    let result = parseSelectQuery("SELECT * FROM students WHERE age >")
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereColumnWithSpace() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age name > 18"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereColumnStartingWithDigit() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE 1age > 18"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereColumnWithHyphen() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE student-age > 18"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereColumnWithUnderscore() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE student_age > 18"
    )
    match (result) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereStringWithTrailingText() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = 'Alice' extra"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereEmptyString() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = ''"
    )
    match (result) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereEscapedSingleQuote() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = 'Alice''s'"
    )
    match (result) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereEscapedDoubleQuote() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = \"Alice\"\"s\""
    )
    match (result) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereStringContainingOperator() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = 'A>=B'"
    )
    match (result) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseTwoAndConditions() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18 AND score > 80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseThreeAndConditions() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18 AND score > 80 AND id < 10"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 3)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndInsideString() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE name = 'Rock AND Roll'"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 1)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndInsideIdentifier() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE candy = 10"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 1)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseLeadingAnd() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE AND age > 18"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseTrailingAnd() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18 AND"
    )
    match (result) {
        case AppResult.Failure(_) => @Expect(true, true)
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testParseAndWithoutSpacesAroundOperators() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age>18 AND score>=80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndWithMultipleSpaces() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age   >   18    AND    score   >=   80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndWithNewlines() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18\nAND\nscore >= 80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndWithTabs() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18\tAND\tscore >= 80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseAndMixedCase() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age > 18 aNd score >= 80"
    )
    match (result) {
        case AppResult.Success(query) => @Expect(query.conditions.size, 2)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereNegativeFloat() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE score > -85.5"
    )
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Float(value) => @Expect(value, -85.5)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereZero() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE age = 0"
    )
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Integer(value) => @Expect(value, 0)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWherePositiveFloat() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE score = 0.25"
    )
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Float(value) => @Expect(value, 0.25)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereNegativeZero() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE score = -0"
    )
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Integer(value) => @Expect(value, 0)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testParseWhereLargeInteger() {
    let result = parseSelectQuery(
        "SELECT * FROM students WHERE id = 9223372036854775807"
    )
    match (result) {
        case AppResult.Success(query) =>
            match (query.conditions[0].value) {
                case Value.Integer(value) =>
                    @Expect(value, 9223372036854775807)
                case _ => @Expect(false, true)
            }
        case AppResult.Failure(_) => @Expect(false, true)
    }
}