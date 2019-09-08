# another window border example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/windows.html

import ../ncurses


type
    WIN_BORDER = ref object
        ls*, rs*, ts*, bs*: cint
        tl*, tr*, bl*, br*: cint
    WIN = ref object
        startx*, starty*: cint
        height*, width*: cint
        border*: WIN_BORDER

proc newWinBorder(): WIN_BORDER =
    result = new(WIN_BORDER)

proc newWin(): WIN =
    result = new(WIN)
    result.border = newWinBorder()

var row, col: cint
let DEBUG = true

proc init_win_params(p_win: ptr WIN) = 
    p_win.height = 3
    p_win.width = 10
    p_win.starty = (row - p_win.height) div 2
    p_win.startx = (col - p_win.width) div 2

    p_win.border.ls = ord('|')
    p_win.border.rs = ord('|')
    p_win.border.ts = ord('-')
    p_win.border.bs = ord('-')

    p_win.border.tl = ord('+')
    p_win.border.tr = ord('+')
    p_win.border.bl = ord('+')
    p_win.border.br = ord('+')

proc print_win_params(p_win: ptr WIN) = 
    if DEBUG:
        mvprintw(row - 1, 0, "%d %d %d %d", p_win.startx, p_win.starty, p_win.width, p_win.height)
        refresh()

proc create_box(p_win: ptr WIN, flag: bool) =
    var x, y, w, h: cint

    x = p_win.startx
    y = p_win.starty
    w = p_win.width
    h = p_win.height

    if flag:
        mvaddch(y, x, p_win.border.tl)
        mvaddch(y, x + w, p_win.border.tr)
        mvaddch(y + h, x, p_win.border.bl)
        mvaddch(y + h, x + w, p_win.border.br)
        
        mvhline(y, x + 1, p_win.border.ts, w - 1)
        mvhline(y + h, x + 1, p_win.border.bs, w - 1)
        mvvline(y + 1, x, p_win.border.ls, h - 1)
        mvvline(y + 1, x + w, p_win.border.rs, h - 1)
    else:
        for j in y..y+h:
            for i in x..x+w:
                mvaddch(j, i, ord(' '))

    refresh()

proc main() =
    let stdscr = initscr()
    getmaxyx(stdscr, row, col)
    start_color()
    cbreak()
    keypad(stdscr, true)
    noecho()
    init_pair(1, COLOR_CYAN, COLOR_BLACK)

    var 
        win: WIN = newWin()
        ch: cint

    init_win_params(addr win)
    print_win_params(addr win)

    attron(COLOR_PAIR(1))
    printw("Press F1 to exit")
    refresh()
    attroff(COLOR_PAIR(1))

    create_box(addr win, true)
    while true:
        ch = getch()
        if ch == KEY_F(1):
            break

        case ch
        of KEY_LEFT:
            create_box(addr win, false)
            win.startx -= 1
            create_box(addr win, true)
        of KEY_RIGHT:
            create_box(addr win, false)
            win.startx += 1
            create_box(addr win, true)
        of KEY_UP:
            create_box(addr win, false)
            win.starty -= 1
            create_box(addr win, true)
        of KEY_DOWN:
            create_box(addr win, false)
            win.starty += 1
            create_box(addr win, true)
        else:
            discard

    endwin()

when isMainModule:
    main()
