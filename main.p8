%import math
%import textio

; Conway's game of life in 6502
; http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
; Should be able to run on any 6502 system with 1K of RAM
; Targets tested: 
; - C128
; - C64
; - CX16

; 2023-02-05: Initial version

main {

    sub start() {
        txt.clear_screen()
        ; Draw a random pattern
        conway.initialize()
        ; Run the game
        repeat {
            conway.next_generation()
        }
    }
}

conway {
    ; $20 = space (dead)
    ; $51 = O (alive)

    ; Get max x and y
    ubyte maxx = txt.width()
    ubyte maxy = txt.height()

    ; Global x and y
    ubyte x
    ubyte y

    sub initialize() {
        ; Random pattern
        ; Cycle each row
        for y in 0 to maxy {
            ; Cycle each column
            for x in 0 to maxx {
                ; Set a random color
                txt.color(math.rnd() / 16)
                ; Set a random character (dead or alive)
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
        ; Cycle each row
        for y in 0 to maxy {
            ; Cycle each column
            for x in 0 to maxx {
                if txt.getchr(x, y) == $51 {
                ; Any live cell with fewer than two live neighbours dies, 
                ; as if caused by under-population.
                    if conway.count_neighbours(x, y) < 2 {
                        txt.setchr(x, y, $20)
                    } 
                    ; Any live cell with two or three live neighbours survives.
                    else if conway.count_neighbours(x, y) > 3 {
                        txt.setchr(x, y, $20)
                    }
                } else {
                    ; Any dead cell with three live neighbours becomes a live cell.
                    if conway.count_neighbours(x, y) == 3 {
                        txt.setchr(x, y, $51)
                        txt.setclr(x, y, math.rnd() % 16)
                    }
                }
            }
        }
    }
    
    ; Count the number of neighbours
    ; Returns the number of neighbours
    sub count_neighbours(ubyte x, ubyte y) -> ubyte {
        ubyte count = 0
        ; upper left
        if x >= 0  {
            if y > 0 {
                if txt.getchr(x - 1, y - 1) == $51 {
                    count++
                }
            }
        }
        if y > 0 {
            ; upper
            if txt.getchr(x, y - 1) == $51 {
                count++
            }
            ; upper right
            if txt.getchr(x + 1, y - 1) == $51 {
                count++
            }
        }
        ; Early exit
        if count > 3 {
            return count
        }
        if x > 0 {
        ; left
            if txt.getchr(x - 1, y) == $51 {
                count++
            }
            ; Early exit
            if count > 3 {
                return count
            }
            if ( y < maxy ) {
                ; lower left
                if txt.getchr(x - 1, y + 1) == $51 {
                    count++
                }
            }
            if count > 3 {
                return count
            }
        }
        if x < maxx {
            ; right
            if txt.getchr(x + 1, y) == $51 {
                count++
            }
            if count > 3 {
                return count
            }
        }
        if y < maxy {
            ; lower
            if txt.getchr(x, y + 1) == $51 {
                count++
            }
            ; Early exit
            if count > 3 {
                return count
            }
            if x < maxx {
                ; lower right
                if txt.getchr(x + 1, y + 1) == $51 {
                    count++
                }
            }
        }

        return count
    }
}
