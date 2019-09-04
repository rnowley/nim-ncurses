# a hello world example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/helloworld.html

import ../ncurses

initscr()
printw("hello world")
refresh()
getch()
endwin()
