# chgat example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/attrib.html

import ../ncurses


initscr()
start_color()
init_pair(1, COLOR_CYAN, COLOR_BLACK)
printw("A Big string which i didn't care to type fully ")
mvchgat(0, 0, -1, A_BLINK, 1, nil)

refresh()
getch()
endwin()
