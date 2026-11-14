package CangjieQueryCompiler.semantic
import CangjieQueryCompiler.common.*

@Test
func testValidateTableExists() {
    let query = SelectQuery("students", true, [], [])
    let table = Table("students", ["id", "name"], [])
    match (validateTableExists(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateTableDoesNotExist() {
    let query = SelectQuery("employees", true, [], [])
    let table = Table("students", ["id", "name"], [])
    match (validateTableExists(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TABLE_NOT_FOUND")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateSelectedColumns() {
    let query = SelectQuery("students", false, ["id", "name"], [])
    let table = Table("students", ["id", "name"], [])
    match (validateSelectedColumns(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateMissingSelectedColumn() {
    let query = SelectQuery("students", false, ["salary"], [])
    let table = Table("students", ["id", "name"], [])
    match (validateSelectedColumns(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "COLUMN_NOT_FOUND")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateConditionColumns() {
    let query = SelectQuery(
        "students",
        false,
        ["name"],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    let table = Table("students", ["id", "name", "age"], [])
    match (validateConditionColumns(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateMissingConditionColumn() {
    let query = SelectQuery(
        "students",
        true,
        [],
        [Condition("height", ComparisonOperator.Greater, Value.Integer(180))]
    )
    let table = Table("students", ["id", "name"], [])
    match (validateConditionColumns(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "COLUMN_NOT_FOUND")
        case AppResult.Success(_) => @Expect(false, true)
    }
}

@Test
func testValidateTableStructure() {
    let table = Table(
        "students",
        ["id", "name"],
        [
            Row([Value.Integer(1), Value.String("Alice")]),
            Row([Value.Integer(2), Value.String("Bob")])
        ]
    )
    match (validateTableStructure(table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateInvalidTableStructure() {
    let table = Table(
        "students",
        ["id", "name"],
        [Row([Value.Integer(1)])]
    )
    match (validateTableStructure(table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "INVALID_TABLE_STRUCTURE")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateCompleteQuery() {
    let table = Table(
        "students",
        ["id", "name", "age"],
        [Row([Value.Integer(1), Value.String("Alice"), Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students",
        false,
        ["name"],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    match (validateQuery(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateCompleteQueryWithMissingColumn() {
    let table = Table("students", ["id", "name"], [])
    let query = SelectQuery("students", false, ["salary"], [])
    match (validateQuery(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "COLUMN_NOT_FOUND")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateIntegerCondition() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateIntegerFloatCondition() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Float(18.5))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateStringEquality() {
    let table = Table(
        "students",
        ["name"],
        [Row([Value.String("Alice")])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("name", ComparisonOperator.Equal, Value.String("Alice"))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testRejectStringGreaterComparison() {
    let table = Table(
        "students",
        ["name"],
        [Row([Value.String("Alice")])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("name", ComparisonOperator.Greater, Value.String("Bob"))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TYPE_MISMATCH")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testRejectIntegerStringComparison() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Equal, Value.String("19"))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TYPE_MISMATCH")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateBooleanEquality() {
    let table = Table(
        "users",
        ["active"],
        [Row([Value.Boolean(true)])]
    )
    let query = SelectQuery(
        "users", true, [],
        [Condition("active", ComparisonOperator.Equal, Value.Boolean(true))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testRejectBooleanGreaterComparison() {
    let table = Table(
        "users",
        ["active"],
        [Row([Value.Boolean(true)])]
    )
    let query = SelectQuery(
        "users", true, [],
        [Condition("active", ComparisonOperator.Greater, Value.Boolean(false))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TYPE_MISMATCH")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateNullColumnValues() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Null]), Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateMixedNumericColumn() {
    let table = Table(
        "students",
        ["score"],
        [
            Row([Value.Integer(90)]),
            Row([Value.Float(85.5)])
        ]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("score", ComparisonOperator.Greater, Value.Integer(80))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testRejectMixedIncompatibleColumn() {
    let table = Table(
        "students",
        ["value"],
        [
            Row([Value.Integer(90)]),
            Row([Value.String("Alice")])
        ]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("value", ComparisonOperator.Equal, Value.Integer(90))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TYPE_MISMATCH")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testValidateEmptyTable() {
    let table = Table("students", ["age"], [])
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateAllNullColumn() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Null]), Row([Value.Null])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )
    match (validateConditionTypes(query, table)) {
        case AppResult.Success(_) => @Expect(true, true)
        case AppResult.Failure(_) => @Expect(false, true)
    }
}
@Test
func testValidateQueryRejectsTypeMismatch() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Equal, Value.String("19"))]
    )

    match (validateQuery(query, table)) {
        case AppResult.Failure(error) =>
            @Expect(error.code, "TYPE_MISMATCH")
        case AppResult.Success(_) => @Expect(false, true)
    }
}
@Test
func testDetailedValidationSuccess() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Greater, Value.Integer(18))]
    )

    let result = validateQueryDetailed(query, table)

    @Expect(result.isValid, true)
    @Expect(result.errors.size, 0)
}
@Test
func testDetailedValidationTypeMismatch() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )
    let query = SelectQuery(
        "students", true, [],
        [Condition("age", ComparisonOperator.Equal, Value.String("19"))]
    )

    let result = validateQueryDetailed(query, table)

    @Expect(result.isValid, false)
    @Expect(result.errors.size, 1)
    @Expect(result.errors[0].code, "TYPE_MISMATCH")
}
@Test
func testDetailedValidationMultipleErrors() {
    let table = Table(
        "students",
        ["age"],
        [Row([Value.Integer(19)])]
    )

    let query = SelectQuery(
        "students",
        false,
        ["unknown_column"],
        [
            Condition(
                "missing_column",
                ComparisonOperator.Equal,
                Value.Integer(1)
            )
        ]
    )

    let result = validateQueryDetailed(query, table)

    @Expect(result.isValid, false)
    @Expect(result.errors.size, 2)
    @Expect(result.errors[0].code, "COLUMN_NOT_FOUND")
    @Expect(result.errors[1].code, "COLUMN_NOT_FOUND")
}
@Test
func testParserErrorCategory() {
    match (getErrorCategory("PARSE_ERROR")) {
        case ErrorCategory.PARSER => @Expect(true, true)
        case _ => @Expect(false, true)
    }
}
@Test
func testSemanticErrorCategory() {
    match (getErrorCategory("TABLE_NOT_FOUND")) {
        case ErrorCategory.SEMANTIC => @Expect(true, true)
        case _ => @Expect(false, true)
    }

    match (getErrorCategory("COLUMN_NOT_FOUND")) {
        case ErrorCategory.SEMANTIC => @Expect(true, true)
        case _ => @Expect(false, true)
    }

    match (getErrorCategory("TYPE_MISMATCH")) {
        case ErrorCategory.SEMANTIC => @Expect(true, true)
        case _ => @Expect(false, true)
    }
}
@Test
func testStorageErrorCategory() {
    match (getErrorCategory("INVALID_CSV_QUOTE")) {
        case ErrorCategory.STORAGE => @Expect(true, true)
        case _ => @Expect(false, true)
    }

    match (getErrorCategory("CSV_LOAD_ERROR")) {
        case ErrorCategory.STORAGE => @Expect(true, true)
        case _ => @Expect(false, true)
    }
}
@Test
func testUnknownErrorCategory() {
    match (getErrorCategory("SOME_UNKNOWN_ERROR")) {
        case ErrorCategory.UNKNOWN => @Expect(true, true)
        case _ => @Expect(false, true)
    }
}