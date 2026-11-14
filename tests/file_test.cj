import std.fs.*

main() {
    let bytes = File.readFrom("./src/data/students.csv")
    let content = String.fromUtf8(bytes)
    println(content)
}