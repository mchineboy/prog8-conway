%import math
%import textio

main {

    sub start() {
        txt.clear_screen()
        conway.initialize()
        repeat {
            conway.next_generation()
        }
    }
}

conway {
    sub initialize() {
        ubyte x = txt.width()
        ubyte y = txt.height()
        repeat txt.height() {
            repeat txt.width() {
                txt.color(math.rnd() % 16)
                if math.rnd() % 5 == 0 {
                    txt.setchr(x, y, $51)
                    txt.setclr(x, y, math.rnd() % 16)
                } else {
                    txt.setchr(x, y, $20)
                }
                x -= 1
            }
            y -= 1
            x = txt.width()
        }
        
    }

    sub next_generation() {
        ubyte x = txt.width()
        ubyte y = txt.height()
        repeat txt.height() {
            repeat  txt.width() {
                if txt.getchr(x, y) == $51 {
                    if conway.count_neighbours(x, y) < 2 {
                        txt.setchr(x, y, $20)
                    } else if conway.count_neighbours(x, y) > 3 {
                        txt.setchr(x, y, $20)
                    }
                } else {
                    if conway.count_neighbours(x, y) == 3 {
                        txt.setchr(x, y, $51)
                        txt.setclr(x, y, math.rnd() % 16)
                    }
                }
                x -= 1

            }
            y -= 1
            x = txt.width()
        }
    }
    ;Any live cell with two or three live neighbours survives.
    ;Any dead cell with three live neighbours becomes a live cell.
    ;All other live cells die in the next generation. Similarly, all other dead cells stay dead.

    sub count_neighbours(ubyte x, ubyte y) -> ubyte {
        ubyte count = 0
        ; upper left
        if txt.getchr(x - 1, y - 1) == $51 {
            count += 1
        }
        ; upper
        if txt.getchr(x, y - 1) == $51 {
            count += 1
        }
        ; upper right
        if txt.getchr(x + 1, y - 1) == $51 {
            count += 1
        }
        ; left
        if txt.getchr(x - 1, y) == $51 {
            count += 1
        }
        ; right
        if txt.getchr(x + 1, y) == $51 {
            count += 1
        }
        ; lower left
        if txt.getchr(x - 1, y + 1) == $51 {
            count += 1
        }
        ; lower
        if txt.getchr(x, y + 1) == $51 {
            count += 1
        }
        ; lower right
        if txt.getchr(x + 1, y + 1) == $51 {
            count += 1
        }

        return count
    }
}
