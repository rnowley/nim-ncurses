# window border example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/windows.html

import ../ncurses


proc create_newwin(height, width, starty, startx: cint): PWindow =
    var local_win: PWindow

    local_win = newwin(height, width, starty, startx)
    box(local_win, 0, 0)
    wrefresh(local_win)
    result = local_win

proc destroy_win(local_win: PWindow) =
    wborder(local_win, ord(' '), ord(' '), ord(' '), ord(' '), ord(' '), ord(' '), ord(' '), ord(' '))
    wrefresh(local_win)
    delwin(local_win)

proc main() =
    var 
        my_win: PWindow
        startx, starty, width, height: cint
        ch: int
        row, col: cint
    
    let stdscr = initscr()
    cbreak()
    keypad(stdscr, true)
    
    height = 3
    width = 10
    getmaxyx(stdscr, row, col)
    starty = (row - height) div 2
    startx = (col - width) div 2
    printw("Press F1 to exit")
    refresh()
    my_win = create_newwin(height, width, starty, startx)
    
    while true:
        ch = getch()
        if ch == KEY_F(1):
            break
    
        case ch
        of KEY_LEFT:
            startx -= 1
        of KEY_RIGHT:
            startx += 1
        of KEY_DOWN:
            starty += 1
        of KEY_UP:
            starty -= 1
        else:
            discard

        destroy_win(my_win)
        my_win = create_newwin(height, width, starty, startx)

    endwin()

when isMainModule:
    main()