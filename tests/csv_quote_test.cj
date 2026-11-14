main() {
    let line = "1,\"Smith, John\",20,85"

    for (ch in line) {
        if (ch == 34u8) {
            println("QUOTE")
        } else if (ch == 44u8) {
            println("COMMA")
        } else {
            println(String.fromUtf8([ch]))
        }
    }
}