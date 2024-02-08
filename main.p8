%import math
%import textio
%import syslib

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
        repeat {
            txt.clear_screen()
            uword screensize = txt.width() as uword * txt.height()
            sys.memset($1000, screensize, $20)
            ; Draw a random pattern
            conway.initialize()
            ; Run the game
            repeat {
                ubyte generation_changes = 0
                generation_changes = conway.next_generation()
                if generation_changes <= 8 {
                    break
                }
            }
        }
    }
}

conway {
    ; $20 = space (dead)
    ; $51 = O (alive)

    ; Get max x and y
    ubyte maxx = txt.width()
    ubyte maxy = txt.height()


    sub initialize() {
        ; Random pattern
        ; Cycle each row
        ; x and y
        ubyte x
        ubyte y
        uword bytes = 0
        for y in 0 to maxy {
            ; Cycle each column
            for x in 0 to maxx {
                ubyte color = math.rnd() / 16
                ; Avoid black
                if color == 0 {
                    color = 1
                }
                txt.setclr(x, y, color)
                ; Set a random character (dead or alive)
                if math.rnd() % 3 == 0 {
                    txt.setchr(x, y, $51)
                    @(bytes+$1000) = $51
                } else {
                    txt.setchr(x, y, $20)
                    @(bytes+$1000) = $20
                }
                bytes++
            }
        }
        
    }

    sub next_generation() -> ubyte {
        ubyte generation_changes = 0
        uword bytes = 0
        ; x and y
        ubyte x
        ubyte y
        uword neighbours
        ; First calculate the next generation
        ; Cycle each row
        for y in 0 to maxy {
            ; Cycle each column
            for x in 0 to maxx {
                if txt.getchr(x, y) == $51 {
                    ; Any live cell with fewer than two live neighbours dies, 
                    ; as if caused by under-population.
                    neighbours = conway.count_neighbours(x, y)
                    if neighbours < 2 {
                        @(bytes+$1000) = $20
                        generation_changes++
                    } 
                    ; Any live cell three live neighbours survives.
                    else if neighbours > 3 {
                        @(bytes+$1000) = $20
                        generation_changes++
                    }
                } else {
                    ; Any dead cell with three live neighbours becomes a live cell.
                    neighbours = conway.count_neighbours(x, y)
                    if neighbours == 3 {
                        @(bytes+$1000) = $51
                        generation_changes++
                    }
                }
                bytes++
            }
        }
        
        ; Now draw the next generation

        bytes = 0

        for y in 0 to maxy {
            for x in 0 to maxx {
                ubyte chr = @(bytes+$1000)
                txt.setchr(x, y, chr)
                bytes++
            }
        }

        return generation_changes
    }
    
    ; Count the number of neighbours
    ; Returns the number of neighbours
    sub count_neighbours(ubyte x, ubyte y) -> uword {
        uword count = 0
        ; upper left
        if x > 0  {
            ; left
            if txt.getchr(x - 1, y) == $51 {
                count++
            }
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
            if count > 3 {
                return count
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
