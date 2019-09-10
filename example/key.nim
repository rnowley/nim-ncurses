# key example
# reference: http://www.tldp.org/HOWTO/NCURSES-Programming-HOWTO/keys.html

import ../ncurses


const
    WIDTH = 30
    HEIGHT = 10

var
    startx: cint = 0
    starty: cint = 0

let choices: seq[string] = @["Choice 1", "Choice 2", "Choice 3", "Choice 4", "Exit"]
let n_choices = choices.len()

proc print_menu(menu_win: PWindow, highlight: int) =
    var
        x: cint = 2
        y: cint = 2

    box(menu_win, 0, 0)
    for i in 0..<n_choices:
        if highlight == i + 1:
            wattron(menu_win, A_REVERSE)
            mvwprintw(menu_win, y, x, "%s", choices[i])
            wattroff(menu_win, A_REVERSE)
        else:
            mvwprintw(menu_win, y, x, "%s", choices[i])

        y += 1

    wrefresh(menu_win)

proc main() =
    var 
        menu_win: PWindow
        highlight = 1
        choice = 0
        c: cint = 0

    initscr()
    clear()
    noecho()
    cbreak()

    startx = (80 - WIDTH) div 2
    starty = (24 - HEIGHT) div 2
    menu_win = newwin(HEIGHT, WIDTH, starty, startx)

    keypad(menu_win, true)
    mvprintw(0, 0, "Use arrow keys to go up and down, Press enter to select a choice")
    refresh()
    print_menu(menu_win, highlight)

    while true:
        c = wgetch(menu_win)
        case c
        of KEY_UP:
            if highlight == 1: # wrap around
                highlight = n_choices
            else:
                highlight -= 1
        of KEY_DOWN:
            if highlight == n_choices:
                highlight = 1
            else:
                highlight += 1
        of 10: # enter
            choice = highlight
        else:
            mvprintw(24, 0, "Charcter pressed is = %3d Hopefully it can be printed as '%c'", c, c)
            refresh()

        print_menu(menu_win, highlight)
        if choice != 0: break

    mvprintw(23, 0, "You chose choice %d with choice string %s\n", choice, choices[choice - 1])
    clrtoeol()
    refresh()
    getch()
    endwin()

when isMainModule:
    main()