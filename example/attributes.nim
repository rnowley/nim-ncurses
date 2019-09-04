# an attribute example, display file on the terminal
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/attrib.html

import ../ncurses, os

if paramCount() != 1:
    echo "Usage: " & getAppFilename().lastPathPart & " <a nim file name>"
    quit(1)

let file = commandLineParams()[0]
var fp: File
try:
    fp = open(file, fmRead)
except IOError:
    echo "Can not open input file"
    quit(1)

var
    prev, ch: char
    row,col: cint
    y, x: cint
    block_comm: bool

let pwin = initscr()
getmaxyx(pwin, row, col)

while fp.endOfFile() == false:
    ch = fp.readChar()
    getyx(pwin, y, x)
    if y == row - 1:
        printw("<-Press Any Key->")
        getch()
        clear()
        move(0, 0)

    #[
        block comment
    ]#
    if ch == '[' and prev == '#':
        attron(A_BOLD)
        getyx(pwin, y, x)
        move(y, x - 1)
        printw("%c%c", prev, ch)
        block_comm = true
    elif prev == ']' and ch == '#':
        getyx(pwin, y, x)
        move(y, x - 1)
        printw("%c%c", prev, ch)
        attroff(A_BOLD)
        block_comm = false

    # line comment
    elif block_comm == false and ch == '#' and (prev == '\r' or prev == '\n' or prev == '\0' or prev == ' '):
        attron(A_BOLD)
        getyx(pwin, y, x)
        move(y, x)
        printw("%c", ch)
    elif block_comm == false and ch == '\n' or ch == '\r':
        attroff(A_BOLD)
        getyx(pwin, y, x)
        move(y, x)
        printw("%c", ch)
    else:
        printw("%c", ch)

    prev = ch
    refresh()

getch()
endwin()
fp.close()
