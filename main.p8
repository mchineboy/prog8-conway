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
            ; Draw a random pattern
            conway.initialize()

            ; Run the game
            repeat {
                uword dots_left = conway.next_generation()
                txt.row(0)
                txt.column(0)
                txt.print("Dots left: ")
                txt.print_uw(dots_left)
                if dots_left <= 5 {
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
    uword maxx = txt.width() as uword
    uword maxy = txt.height() as uword
    uword memoffset = (maxx * maxy) + 1
    uword basememory = sys.progend()
    uword calcmemory = memoffset + basememory

    sub initialize() {
        ; Random pattern
        ; Cycle each row
        ; x and y
        txt.clear_screen()
        sys.memset(basememory,
                    memoffset as uword, 
                    $20)
        sys.memset(calcmemory,
                    memoffset as uword,
                    $20)
        uword x = 0
        uword y = 0
        repeat maxy as ubyte {
            ; Cycle each column
            repeat maxx as ubyte  {
                ubyte color = math.rnd() / 16
                ; Avoid black
                if color == 0 {
                    color = 1
                }
                txt.setclr(x as ubyte, y as ubyte, color)
                ; Set a random character (dead or alive)
                
                uword address = conway.calculate_address(basememory, x, y)

                if math.rnd() % 3 == 0 {
                    txt.setchr(x as ubyte, y as ubyte, $51)
                    @(address) = $51
                } else {
                    txt.setchr(x as ubyte, y as ubyte, $20)
                    @(address) = $20
                }
                x++
            }
            x = 0
            y++
        }
        
    }

    sub next_generation() -> uword {
        uword dots_left = maxx * maxy
        ; x and y
        uword x = 0
        uword y = 0
        ; First calculate the next generation
        ; Cycle each row

        sys.memcopy(basememory, calcmemory, memoffset)

        repeat maxy as ubyte {
            ; Cycle each column
            repeat maxx as ubyte {
                uword calcaddress = conway.calculate_address(calcmemory, x, y)
                ubyte chr = @(calcaddress)
                uword address = conway.calculate_address(basememory, x, y)
                ubyte neighbours = conway.count_neighbours(calcaddress)

                if chr == $51 {
                    ; Any live cell with fewer than two live neighbours dies, 
                    ; as if caused by under-population.
                    if neighbours < 2 {
                        @(address) = $20
                    }
                    ; Any live cell three live neighbours survives.
                    else if neighbours > 3 {
                        @(address) = $20
                    }
                } else {
                    ; Any dead cell with three live neighbours becomes a live cell.
                    if neighbours == 3 {
                        @(address) = $51
                    }
                }
                x++
            }
            x = 0
            y++
        }

        x = 0
        y = 0
        
        ; Now draw the next generation

        repeat maxy as ubyte {
            repeat maxx as ubyte {
                address = conway.calculate_address(basememory, x, y)
                chr = @(address)
                txt.setchr(x as ubyte, y as ubyte, chr)
                if chr == $20 {
                    dots_left = dots_left - 1
                }
                x++
            }
            x = 0
            y++
        }

        return dots_left
    }
    
    ; Count the number of neighbours
    ; Returns the number of neighbours
    sub count_neighbours(uword address) -> ubyte {
        ubyte count = 0
        ubyte chr = $20

        uword neighbour = address - maxx - 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - maxx
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - maxx + 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        if count > 3 {
            return count
        }
        neighbour = address + 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        if count > 3 {
            return count
        }
        neighbour = address + maxx - 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        if count > 3 {
            return count
        }
        neighbour = address + maxx
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        if count > 3 {
            return count
        }
        neighbour = address + maxx + 1
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        return count
    }

    sub get_cell(uword address) -> ubyte {
        if address >= calcmemory and address < conway.calculate_address(calcmemory, maxx, maxy) {
            return @(address)
        } else {
            return $20
        }
    }

    sub calculate_address(uword base, uword x, uword y) -> uword {
        uword offset = (y * maxx) + x
        uword faddress = base + offset
        return faddress
    }
}
