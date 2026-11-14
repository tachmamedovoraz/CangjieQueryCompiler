import std.collection.*

main() {
    var fields = ArrayList<String>()

    fields.add("Alice")
    fields.add("Bob")
    fields.add("Chen")

    for (field in fields) {
        println(field)
    }

    println("Count: ${fields.size}")
}