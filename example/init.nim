# an init example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/init.html

import ../ncurses

var pwin = initscr()
raw()
keypad(pwin, true)
noecho()

printw("Type any character to see it in bold\n")
var ch = getch()

case ch
of KEY_F(2):
    printw("F2 Key pressed")
else:
    printw("The pressed key is ")
    attron(A_BOLD)
    printw("%c", ch)
    attroff(A_BOLD)

refresh()
getch()
endwin()