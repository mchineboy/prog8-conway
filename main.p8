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
            sys.memset($1000,
                       txt.width() as uword * txt.height(), 
                       $20)
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
    uword memoffset = (maxx * maxy)+512
    uword lowmemory = memoffset + $1000

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

        sys.memcopy($1000, lowmemory, maxx * maxy)

        for y in 0 to maxy {
            ; Cycle each column
            for x in 0 to maxx {
                ubyte chr = @(bytes+lowmemory)
                if chr == $51 {
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
                chr = @(bytes+$1000)
                txt.setchr(x, y, chr)
                bytes++
            }
        }

        return generation_changes
    }
    
    ; Count the number of neighbours
    ; Returns the number of neighbours
    sub count_neighbours(ubyte x, ubyte y) -> uword {
        uword highmemory = lowmemory + maxx * maxy
        uword count = 0
        ubyte chr = $20

        uword address = y * maxx + x + lowmemory

        ubyte offset
        uword neighbour

        for offset in 0 to 7 {
            when offset {
                0 -> neighbour = address - maxx - 1
                1 -> neighbour = address - maxx
                2 -> neighbour = address - maxx + 1
                3 -> neighbour = address - 1
                4 -> neighbour = address + 1
                5 -> neighbour = address + maxx - 1
                6 -> neighbour = address + maxx
                7 -> neighbour = address + maxx + 1
            }
            if neighbour >= lowmemory and neighbour < highmemory {
                chr = @(neighbour)
                if chr == $51 {
                    count++
                }
                if count > 4 {
                    break
                }
            }
        }

        return count
    }
}
