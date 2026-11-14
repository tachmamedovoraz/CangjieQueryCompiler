main() {
    let line = "1,Alice,19,91"
    let fields = line.split(",")

    for (field in fields) {
        println(field)
    }
}