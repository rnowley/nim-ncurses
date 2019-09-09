# color example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/color.html

import ../ncurses


var stdscr: PWindow

proc print_in_middle(win: var PWindow, starty, startx: cint, width: var cint, str: cstring) =
    var
        length, y, x: cint
        temp: float

    if win == nil: win = stdscr
    getyx(win, y, x)

    if startx != 0: x = startx
    if starty != 0: y = starty
    if width == 0: width = 80
    
    length = (cint)str.len()
    temp = (width - length) / 2
    x = startx + (cint)temp
    mvwprintw(win, y, x, "%s", str)
    refresh()

proc main() =
    stdscr = initscr()
    if has_colors() == false:
        endwin()
        echo "You terminal does not support color"
        quit(1)

    var x, y, width: cint = 0
    getmaxyx(stdscr, y, x)

    start_color()
    init_pair(1, COLOR_RED, COLOR_BLACK)

    attron(COLOR_PAIR(1))
    print_in_middle(stdscr, y div 2, 0, width, "Viola !!! In color ...")
    attroff(COLOR_PAIR(1))
    getch()
    endwin()

when isMainModule:
    main()