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
                ubyte dots_left = 0
                dots_left = conway.next_generation()
                if dots_left <= 12 {
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
        txt.print_uw(basememory)
        sys.wait(120)
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
                
                uword address = y * maxx + x + basememory

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

    sub next_generation() -> ubyte {
        ubyte dots_left = 0
        uword bytes = 0
        ; x and y
        uword x = 0
        uword y = 0
        ; First calculate the next generation
        ; Cycle each row

        sys.memcopy(basememory, calcmemory, memoffset)

        repeat maxy as ubyte {
            ; Cycle each column
            repeat maxx as ubyte {
                uword calcaddress = y * maxx + x + memoffset
                ubyte chr = @(calcaddress)
                uword address = y * maxx + x + basememory
                ubyte neighbours = 0

                if chr == $51 {
                    ; Any live cell with fewer than two live neighbours dies, 
                    ; as if caused by under-population.
                    neighbours = conway.count_neighbours(calcaddress)
                    
                    if neighbours < 2 {
                        @($d020) = $0
                        @(address) = $20
                    }
                    ; Any live cell three live neighbours survives.
                    else if neighbours > 3 {
                        @($d020) = $0
                        @(address) = $20
                    }
                } else {
                    ; Any dead cell with three live neighbours becomes a live cell.
                    neighbours = conway.count_neighbours(calcaddress)
                    if neighbours == 3 {
                        @($d020) = $1
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
                address = y * maxx + x + basememory
                chr = @(address)
                txt.setchr(x as ubyte, y as ubyte, chr)
                if chr == $51 {
                    dots_left++
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
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - maxx
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - maxx + 1
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address - 1
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address + 1
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address + maxx - 1
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address + maxx
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        neighbour = address + maxx + 1
        conway.print_address(neighbour,count)
        chr = conway.get_cell(neighbour)
        if chr == $51 {
            count = count + 1
        }
        txt.row(20)
        txt.column(0)
        txt.print("count: ")
        txt.print_ub(count)
        return count
    }

    sub get_cell(uword address) -> ubyte {
        if address >= calcmemory and address < calcmemory + maxx * maxy {
            return @(address)
        } else {
            return $20
        }
    }

    sub print_address(uword address, ubyte count) {
        uword x = address % maxx
        uword y = address / maxx
        txt.row(0)
        txt.column(0)
        txt.print("x: ")
        txt.print_uw(x)
        txt.print(" y: ")
        txt.print_uw(y)
        txt.print(" memory location: ")
        txt.print_uw(address)
        txt.print(" count: ")
        txt.print_ub(count)
        sys.wait(30)
    }
}
