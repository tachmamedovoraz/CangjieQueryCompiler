import std.collection.*

main() {
    var conditions = ArrayList<Option<Int64>>()
    conditions.add(Some(10))
    conditions.add(None)

    for (item in conditions) {
        match (item) {
            case Some(value) => println(value.toString())
            case None => println("Invalid")
        }
    }
}