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
    
    ubyte maxx = txt.width()
    ubyte maxy = txt.height()
    ubyte x
    ubyte y

    sub initialize() {
        for y in 0 to maxy {
            for x in 0 to maxx {
                txt.color(math.rnd() / 16)
                if math.rnd() % 5 == 0 {
                    txt.setchr(x, y, $51)
                    txt.setclr(x, y, math.rnd() % 16)
                } else {
                    txt.setchr(x, y, $20)
                }
            }
        }
        
    }

    sub next_generation() {
        for y in 0 to maxy {
            for x in 0 to maxx {
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
            }
        }
    }
    ;Any live cell with two or three live neighbours survives.
    ;Any dead cell with three live neighbours becomes a live cell.
    ;All other live cells die in the next generation. Similarly, all other dead cells stay dead.

    sub count_neighbours(ubyte x, ubyte y) -> ubyte {
        ubyte count = 0
        ; upper left
        if x > 0 and y > 0 {
            if txt.getchr(x - 1, y - 1) == $51 {
                count += 1
            }
        }
        ; upper
        if y > 0 {
            if txt.getchr(x, y - 1) == $51 {
                count += 1
            }
            ; upper right
            if txt.getchr(x + 1, y - 1) == $51 {
                count += 1
            }
        }
        ; Early exit
        if count > 3 {
            return count
        }
        if x > 0 {
        ; left
            if txt.getchr(x - 1, y) == $51 {
                count += 1
            }
            ; Early exit
            if count > 3 {
                return count
            }
            if ( y < maxy ) {
                ; lower left
                if txt.getchr(x - 1, y + 1) == $51 {
                    count += 1
                }
            }
        }
        if count > 3 {
            return count
        }
        if x < maxx {
            ; right
            if txt.getchr(x + 1, y) == $51 {
                count += 1
            }
        }
        if count > 3 {
            return count
        }
        if y < maxy {
            ; lower
            if txt.getchr(x, y + 1) == $51 {
                count += 1
            }
            ; Early exit
            if count > 3 {
                return count
            }
            if x < maxx {
                ; lower right
                if txt.getchr(x + 1, y + 1) == $51 {
                    count += 1
                }
            }
        }

        return count
    }
}
