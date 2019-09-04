# a printw example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/printw.html

import ../ncurses

let mesg = "Just a string"
var
    row: cint
    col: cint

let stdscr = initscr()
getmaxyx(stdscr, row, col)
mvprintw(row div 2, (cint)((col - mesg.len) div 2), "%s", mesg)
mvprintw(row - 2, 0, "This screen has %d rows and %d columns\n", row, col)
printw("Try resizing your window(if possible) and then run this program again")
refresh()
getch()
endwin()
