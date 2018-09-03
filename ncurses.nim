{.deadCodeElim: on.}
when defined(windows):
 const
   libncurses* = "libncurses.dll"
elif defined(macosx):
 const
   libncurses* = "libncurses.dylib"
else:
 const
   libncurses* = "libncursesw.so"
type
 chtype* = int64
 mmask_t* = uint32
 attr_t* = chtype

# ...must be at least as wide as chtype

type
 window* = win_st
 ldat* = object

 pdat_4299782170994856172* = object
   pad_y*: cshort
   pad_x*: cshort
   pad_top*: cshort
   pad_left*: cshort
   pad_bottom*: cshort
   pad_right*: cshort

 win_st* = object
   cury*: cshort
   curx*: cshort             # current cursor position
                             # window location and size
   maxy*: cshort
   maxx*: cshort             # maximums of x and y, NOT window size
   begy*: cshort
   begx*: cshort             # screen coords of upper-left-hand corner
   flags*: cshort            # window state flags
                             # attribute tracking
   attrs*: attr_t            # current attribute for non-space character
   bkgd*: chtype             # current background char/attribute pair
                             # option values set by user
   notimeout*: bool          # no time out on function-key entry?
   clear*: bool              # consider all data in the window invalid?
   leaveok*: bool            # OK to not reset cursor on exit?
   scroll*: bool             # OK to scroll this window?
   idlok*: bool              # OK to use insert/delete line?
   idcok*: bool              # OK to use insert/delete char?
   immed*: bool              # window in immed mode? (not yet used)
   sync*: bool               # window in sync mode?
   use_keypad*: bool         # process function keys into KEY_ symbols?
   delay*: cint              # 0 = nodelay, <0 = blocking, >0 = delay
   line*: ptr ldat           # the actual line data
                             # global screen state
   regtop*: cshort           # top line of scrolling region
   regbottom*: cshort        # bottom line of scrolling region
                             # these are used only if this is a sub-window
   parx*: cint               # x coordinate of this window in parent
   pary*: cint               # y coordinate of this window in parent
   parent*: ptr window       # pointer to parent if a sub-window
                             # these are used only if this is a pad
   pad*: pdat_4299782170994856172
   yoffset*: cshort          # real begy is _begy + _yoffset
   color*: cint              # current color-pair for non-space character


var COLORS* {.importc: "COLORS", dynlib: libncurses.}: int

var COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: int

const
 ERR* = (- 1)
 OK* = (0)

# keys

const
  KEY_CODE_YES* = 0o400
  KEY_MIN* = 0o401
  KEY_BREAK* = 0o401
  KEY_SRESET* = 0o530
  KEY_RESET* = 0o531
  KEY_DOWN* = 0o402
  KEY_UP* = 0o403
  KEY_LEFT* = 0o404
  KEY_RIGHT* = 0o405

# colors

const
 COLOR_BLACK* = 0
 COLOR_RED* = 1
 COLOR_GREEN* = 2
 COLOR_YELLOW* = 3
 COLOR_BLUE* = 4
 COLOR_MAGENTA* = 5
 COLOR_CYAN* = 6
 COLOR_WHITE* = 7

# attributes

template NCURSES_CAST*(`type`, value: expr): expr =
 (`type`)(value)

# attributes

const
 NCURSES_ATTR_SHIFT* = 8'i64

template NCURSES_BITS*(mask, shift: expr): expr =
 (NCURSES_CAST(int64, (mask)) shl ((shift) + NCURSES_ATTR_SHIFT))

const
 A_NORMAL* = 0
 A_BOLD* = 2097152
 A_UNDERLINE* = 131072
 A_ATTRIBUTES* = 4294967040'i64
 A_CHAR_TEXT* = 255
 A_REVERSE* = 262144
 A_BLINK* = 524288
 A_DIM* = 1048576
 A_ALT_CHARSET* = 4194304
 A_INVIS* = 8388608
 A_PROTECT* = 16777216
 A_HORIZONTAL* = 33554432
 A_LEFT* = 67108864
 A_LOW* = 34217728
 A_RIGHT* = 268435456
 A_TOP* = 536870912
 A_VERTICAL* = 1073741824
 A_ITALIC* = 2147483648'i64

#
#  These apply to the first 256 color pairs.
#

template COLOR_PAIR*(n: expr): expr =
 NCURSES_BITS((n), 0'i64)

template PAIR_NUMBER*(a: expr): expr =
 (NCURSES_CAST(int, ((NCURSES_CAST(uint64, (a)) and A_COLOR) shr
     NCURSES_ATTR_SHIFT)))

# mouse interface

template NCURSES_MOUSE_MASK*(b, m: expr): expr =
 ((m) shl (((b) - 1) * 5))

const
 NCURSES_BUTTON_RELEASED* = 1
 NCURSES_BUTTON_PRESSED* = 2
 NCURSES_BUTTON_CLICKED* = 4
 NCURSES_DOUBLE_CLICKED* = 0o000000000010
 NCURSES_TRIPLE_CLICKED* = 0o000000000020
 NCURSES_RESERVED_EVENT* = 0o000000000040

# event masks

const
 BUTTON1_RELEASED* = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_RELEASED)
 BUTTON1_PRESSED* = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_PRESSED)
 BUTTON1_CLICKED* = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_CLICKED)
 BUTTON1_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(1, NCURSES_DOUBLE_CLICKED)
 BUTTON1_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(1, NCURSES_TRIPLE_CLICKED)
 BUTTON2_RELEASED* = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_RELEASED)
 BUTTON2_PRESSED* = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_PRESSED)
 BUTTON2_CLICKED* = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_CLICKED)
 BUTTON2_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(2, NCURSES_DOUBLE_CLICKED)
 BUTTON2_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(2, NCURSES_TRIPLE_CLICKED)
 BUTTON3_RELEASED* = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_RELEASED)
 BUTTON3_PRESSED* = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_PRESSED)
 BUTTON3_CLICKED* = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_CLICKED)
 BUTTON3_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(3, NCURSES_DOUBLE_CLICKED)
 BUTTON3_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(3, NCURSES_TRIPLE_CLICKED)
 BUTTON4_RELEASED* = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_RELEASED)
 BUTTON4_PRESSED* = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_PRESSED)
 BUTTON4_CLICKED* = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_CLICKED)
 BUTTON4_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(4, NCURSES_DOUBLE_CLICKED)
 BUTTON4_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(4, NCURSES_TRIPLE_CLICKED)

#
#  In 32 bits the version-1 scheme does not provide enough space for a 5th
#  button, unless we choose to change the ABI by omitting the reserved-events.
#

const
 BUTTON5_RELEASED* = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_RELEASED)
 BUTTON5_PRESSED* = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_PRESSED)
 BUTTON5_CLICKED* = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_CLICKED)
 BUTTON5_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(5, NCURSES_DOUBLE_CLICKED)
 BUTTON5_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(5, NCURSES_TRIPLE_CLICKED)
 BUTTON_CTRL* = NCURSES_MOUSE_MASK(6, 1)
 BUTTON_SHIFT* = NCURSES_MOUSE_MASK(6, 2)
 BUTTON_ALT* = NCURSES_MOUSE_MASK(6, 4)

template BUTTON_RELEASE*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 1))

template BUTTON_PRESS*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 2))

template BUTTON_CLICK*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 4))

template BUTTON_DOUBLE_CLICK*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 0o000000000010))

template BUTTON_TRIPLE_CLICK*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 0o000000000020))

template BUTTON_RESERVED_EVENT*(e, x: expr): expr =
 ((e) and NCURSES_MOUSE_MASK(x, 0o000000000040))

type
 MEVENT* = object
   id*: cshort               # ID to distinguish multiple devices
   x*: cint
   y*: cint
   z*: cint                  # event coordinates (character-cell)
   bstate*: mmask_t          # button state bits


proc has_mouse*(): bool {.cdecl, importc: "has_mouse", dynlib: libncurses.}
proc getmouse*(a2: ptr MEVENT): cint {.cdecl, importc: "getmouse", dynlib: libncurses.}
proc ungetmouse*(a2: ptr MEVENT): cint {.cdecl, importc: "ungetmouse", dynlib: libncurses.}
proc mousemask*(a2: mmask_t; a3: ptr mmask_t): mmask_t {.cdecl, importc: "mousemask", dynlib: libncurses.}
proc wenclose*(a2: ptr window; a3: cint; a4: cint): bool {.cdecl, importc: "wenclose", dynlib: libncurses.}
proc mouseinterval*(a2: cint): cint {.cdecl, importc: "mouseinterval", dynlib: libncurses.}
proc wmouse_trafo*(a2: ptr window; a3: ptr cint; a4: ptr cint; a5: bool): bool {.cdecl, importc: "wmouse_trafo", dynlib: libncurses.}
proc mouse_trafo*(a2: ptr cint; a3: ptr cint; a4: bool): bool {.cdecl, importc: "mouse_trafo", dynlib: libncurses.}

#
#  These functions are not in X/Open, but we use them in macro definitions:
#

proc getattrs*(a2: ptr window): cint {.cdecl, discardable, importc: "getattrs", dynlib: libncurses.}
proc getcurx*(a2: ptr window): cint {.cdecl, discardable, importc: "getcurx", dynlib: libncurses.}
proc getcury*(a2: ptr window): cint {.cdecl, discardable, importc: "getcury", dynlib: libncurses.}
proc getbegx*(a2: ptr window): cint {.cdecl, discardable, importc: "getbegx", dynlib: libncurses.}
proc getbegy*(a2: ptr window): cint {.cdecl, discardable, importc: "getbegy", dynlib: libncurses.}
proc getmaxx*(a2: ptr window): cint {.cdecl, discardable, importc: "getmaxx", dynlib: libncurses.}
proc getmaxy*(a2: ptr window): cint {.cdecl, discardable, importc: "getmaxy", dynlib: libncurses.}
proc getparx*(a2: ptr window): cint {.cdecl, discardable, importc: "getparx", dynlib: libncurses.}
proc getpary*(a2: ptr window): cint {.cdecl, discardable, importc: "getpary", dynlib: libncurses.}

proc newwin*(lines, columns, begin_y, begin_x: int): ptr window {.cdecl, discardable, importc: "newwin", dynlib: libncurses.}

proc delwin*(win: ptr window): cint {.cdecl, discardable, importc: "delwin", dynlib: libncurses.}

proc mvwin*(win: ptr window, y, x: int): cint {.cdecl, discardable, importc: "mvwin", dynlib: libncurses.}

proc subpad*(orig: ptr window, lines, columns, begin_y, begin_x: int): ptr window {.cdecl, discardable, importc: "subpad", dynlib: libncurses.}

proc subwin*(orig: ptr window, lines, columns, begin_y, begin_x: int): ptr window {.cdecl, discardable, importc: "subwin", dynlib: libncurses.}

proc keypad*(win: ptr window, bf: bool): cint {.cdecl, discardable, importc: "keypad", dynlib: libncurses.}

proc scrollok*(win: ptr window, bf: bool): cint {.cdecl, discardable, importc: "scrollok", dynlib: libncurses.}

proc erase*(): cint {.cdecl, discardable, importc: "erase", dynlib: libncurses.}

proc werase*(win: ptr window): cint {.cdecl, discardable, importc: "werase", dynlib: libncurses.}

proc wclear*(win: ptr window): cint {.cdecl, discardable, importc: "wclear", dynlib: libncurses.}

proc wrefresh*(win: ptr window): cint {.cdecl, discardable, importc: "wrefresh", dynlib: libncurses.}

proc wattron*(win: ptr window, attributes: int): cint {.cdecl, discardable, importc: "wattron", dynlib: libncurses.}

proc wresize*(win: ptr window, line, column: int): cint {.cdecl, discardable, importc: "wresize", dynlib: libncurses.}

proc wmove*(win: ptr window, y, x: int): cint {.cdecl, discardable, importc: "wmove", dynlib: libncurses.}

proc wbkgd*(win: ptr window, character: chtype): cint {.cdecl, discardable, importc: "wbkgd", dynlib: libncurses.}

proc wprintw*(win: ptr window, formattedString: cstring): cint {.cdecl, discardable, importc: "wprintw", dynlib: libncurses.}

proc mvwaddch*(win: ptr window, y, x: int, character: chtype): cint {.cdecl, discardable, importc: "mvwaddch", dynlib: libncurses.}

proc mvwaddstr*(win: ptr window, y, x: int, str: cstring): cint {.cdecl, discardable, importc: "mvwaddstr", dynlib: libncurses.}

proc set_escdelay*(size: int): cint {.cdecl, discardable, importc: "set_escdelay", dynlib: libncurses.}

proc def_prog_mode*(): cint {.cdecl, discardable, importc: "def_prog_mode", dynlib: libncurses.}

proc reset_prog_mode*(): cint {.cdecl, discardable, importc: "reset_prog_mode", dynlib: libncurses.}

proc box*(a2: ptr window, x, y: int64): cint {.cdecl, discardable, importc: "box", dynlib: libncurses.}

proc raw*(): cint {.cdecl, discardable, importc: "raw", dynlib: libncurses.}

proc timeout*(delay: cint) {.cdecl, discardable, importc: "timeout", dynlib: libncurses.}

proc nodelay*(win: ptr window, bf: bool): cint {.cdecl, discardable, importc: "nodelay", dynlib: libncurses.}

proc noecho*(): cint {.cdecl, discardable, importc: "noecho", dynlib: libncurses.}

proc onecho*(): cint {.cdecl, discardable, importc: "echo", dynlib: libncurses.}

proc use_default_colors*(): cint {.cdecl, discardable, importc: "use_default_colors", dynlib: libncurses.}

proc curs_set*(visibility: int): cint {.cdecl, discardable, importc: "curs_set", dynlib: libncurses.}

proc clear*(): cint {.cdecl, discardable, importc: "clear", dynlib: libncurses.}

proc addch*(character: chtype): cint {.cdecl, discardable, importc: "addch", dynlib: libncurses.}
    ## Puts a character into the stdscr at its current window position and then advances
    ## the current window position to the next position.
    ## @Param: 'character' the character to put into the current window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc addstr*(stringToAdd: cstring): cint {.cdecl, discardable, importc: "addstr", dynlib: libncurses.}
    ## Adds a string of characters the the stdscr and advances the cursor.
    ## @Param: The string to add the stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc attroff*(attributes: int64): cint {.cdecl, discardable, importc: "attroff", dynlib: libncurses.}
    ## Turns off the named attributes without affecting any other attributes.
    ## @Param: 'attributes' the attributes to turn off for the current window.
    ## @Returns: An integer value, but the returned value does not have any meaning and can
    ## thus be ignored.

proc attron*(attributes: int64): cint {.cdecl, discardable, importc: "attron", dynlib: libncurses.}
    ## Turns on the named attributes without affecting any other attributes.
    ## @Param: 'attributes' the attributes to turn on for the current window.
    ## @Returns: An integer value, but the returned value does not have any meaning and can
    ## thus be ignored.

proc attrset*(attributes: int64): cint {.cdecl, discardable, importc: "attrset", dynlib: libncurses.}
    ## Sets the current attributes of the given window to the provided attributes.
    ## @Param: 'attributes', the attributes to apply to the current window.
    ## @Returns: An integer value, but the returned value does not have any meaning and can
    ## thus be ignored.

proc beep*(): cint {.cdecl, discardable, importc: "beep", dynlib: libncurses.}
    ## Sounds an audible alarm on the terminal, otherwise it flashes the screen (visible bell).
    ## @Returns: ERR on failure and OK upon successfully beeping.

proc bkgd*(background: int64): cint {.cdecl, discardable, importc: "bkgd", dynlib: libncurses.}
    ## Sets the background property of the current window and apply this setting to every
    ## character position in the window.
    ## @Param: 'background' the background property to apply.

proc can_change_color*(): bool {.cdecl, importc: "can_change_color", dynlib: libncurses.}
    ## Used to determine if the terminal supports colours and can change their definitions.
    ## @Returns: true if the terminal supports colours and can change their definitions or
    ## false otherwise.

proc cbreak*(): cint {.cdecl, discardable, importc: "cbreak", dynlib: libncurses.}
    ## The cbreak routine disables line buffering and erase/kill character-processing
    ## (interrupt and flow control characters are unaffected), making characters typed by
    ## the user immediately available to the program.
    ## @Returns: ERR on failure and OK upon successful completion.

proc delch*(): cint {.cdecl, discardable, importc: "delch", dynlib: libncurses.}
    ## Delete the character under the cursor in the stdscr.
    ## @Returns: ERR on failure and OK upon successfully flashing.

proc deleteln*(): cint {.cdecl, discardable, importc: "deleteln", dynlib: libncurses.}
    ## Deletes the line under the cursor in the stdscr. All lines below the current line are moved up one line.
    ## The bottom line of the window is cleared and the cursor position does not change.
    ## @Returns: ERR on failure and OK upon successful completion.

proc endwin*(): cint {.cdecl, discardable, importc: "endwin", dynlib: libncurses.}
    ## A program should always call endwin before exiting or escaping from curses mode temporarily. This routine
    ## restores tty modes, moves the cursor to the lower left-hand corner of the screen and resets the terminal into the
    ## proper non-visual mode. Calling refresh or doupdate after a temporary escape causes the program to resume visual mode.
    ## @Returns: ERR on failure and OK upon successful completion.

proc flash*(): cint {.cdecl, discardable, importc: "flash", dynlib: libncurses.}
    ## Flashes the screen and if that is not possible it sounds the alert. If this is not possible
    ## nothing happens.
    ## @Returns: ERR on failure and OK upon successfully flashing.

proc getch*(): cint {.cdecl, discardable, importc: "getch", dynlib: libncurses.}
    ## Read a character from the stdscr window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getnstr*(inputString: cstring; numberOfCharacters: int): cint {.cdecl, discardable, importc: "getnstr", dynlib: libncurses.}
    ## Reads at most the specified number of characters into the provided string.
    ## @Param: 'inputString' the variable to read the input into.
    ## @Param: 'numberOfCharacters' the maximum number of characters to read.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getstr*(inputString: cstring): cint {.cdecl, discardable, importc: "getstr", dynlib: libncurses.}
    ## Reads the inputted characters into the provided string.
    ## @Param: 'inputString' the variable to read the input into.
    ## @Returns: ERR on failure and OK upon successful completion.

proc has_colors*(): bool {.cdecl, importc: "has_colors", dynlib: libncurses.}
    ## Used to determine if the terminal can manipulate colours.
    ## @Returns: true if the terminal can manipulate colours or false if it cannot.

proc init_pair*(pair: cshort; foreground: cshort; background: cshort): cint {.cdecl, discardable, importc: "init_pair", dynlib: libncurses.}
    ## Changes the definition of a colour pair.
    ## @Param: 'pair' the number of the colour pair to change.
    ## @Param: 'foreground': the foreground colour number.
    ## @Param: 'background': the background colour number.
    ## @Returns: ERR on failure and OK upon successful completion.

proc initscr*(): ptr window {.cdecl, discardable, importc: "initscr", dynlib: libncurses.}
    ## Usually the first curses routine to be called when initialising a program
    ## The initscr code determines the terminal type and initialises  all curses data structures.  initscr also causes the
    ## first call to refresh to clear the screen.
    ## @Returns: A pointer to stdscr is returned if the operation is successful.
    ## @Note: If errors occur, initscr writes an appropriate error message to
    ## standard error and exits.

proc insch*(character: chtype): cint {.cdecl, discardable, importc: "insch", dynlib: libncurses.}
    ## Inserts a character before the cursor in the stdscr.
    ## @Param: 'character' the character to insert.
    ## @Returns: ERR on failure and OK upon successful completion.

proc insertln*(): cint {.cdecl, discardable, importc: "insertln", dynlib: libncurses.}
    ## Inserts a blank line above the current line in stdscr and the bottom line is lost.
    ## @Returns: ERR on failure and OK upon successful completion.

proc move*(y: int; x: int): cint {.cdecl, discardable, importc: "move", dynlib: libncurses.}
    ## Moves the cursor of stdscr to the specified coordinates.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvaddch*(y: int; x: int; character: chtype): cint {.cdecl, discardable, importc: "mvaddch", dynlib: libncurses.}
    ## Moves the cursor to the specified position and outputs the provided character.
    ## The cursor is then advanced to the next position.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'character' the character to put into the current window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvaddstr*(y: int; x: int; stringToOutput: cstring): cint {.cdecl, discardable, importc: "mvaddstr", dynlib: libncurses.}
    ## Moves the cursor to the specified position and outputs the provided string.
    ## The cursor is then advanced to the next position.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'stringToOutput' the string to put into the current window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvprintw*(y: int; x: int; formattedString: cstring): cint {.varargs, cdecl, discardable, importc: "mvprintw", dynlib: libncurses.}
    ## Prints out a formatted string to the stdscr at the specified row and column.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvwprintw*(destinationWindow: ptr window; y: int; x: int; formattedString: cstring): cint {.varargs, cdecl, discardable, importc: "mvwprintw", dynlib: libncurses.}
    ## Prints out a formatted string to the specified window at the specified row and column.
    ## @Param: 'destinationWindow' the window to write the string to.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc napms*(milliseconds: int): cint {.cdecl, discardable, importc: "napms", dynlib: libncurses.}
    ## Used to sleep for the specified milliseconds.
    ## @Params: 'milliseconds' the number of milliseconds to sleep for.
    ## @Returns: ERR on failure and OK upon successful completion.

proc nocbreak*(): cint {.cdecl, discardable, importc: "nocbreak", dynlib: libncurses.}
    ## Returns the terminal to normal (cooked mode).
    ## @Returns: ERR on failure and OK upon successful completion.

proc printw*(formattedString: cstring): cint {.varargs, cdecl, discardable, importc: "printw", dynlib: libncurses.}
    ## Prints out a formatted string to the stdscr.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc refresh*(): cint {.cdecl, discardable, importc: "refresh", dynlib: libncurses.}
    ## Must be called to get actual output to the terminal. refresh uses stdscr has the default window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc scanw*(formattedInput: cstring): int {.varargs, cdecl, discardable, importc: "scanw", dynlib: libncurses.}
    ## Converts formatted input from the stdscr.
    ## @Param: 'formattedInput' Contains the fields for the input to be mapped to.
    ## @Returns: The number of fields that were mapped in the call.

proc start_color*(): cint {.cdecl, discardable, importc: "start_color", dynlib: libncurses.}
    ## Initialises the the eight basic colours and the two global varables COLORS and COLOR_PAIRS.
    ## It also restores the colours on the terminal to the values that they had when the
    ## terminal was just turned on.
    ## @Note: It is good practice to call this routine right after initscr. It must be
    ## called before any other colour manipulating routines.

proc waddstr*(destinationWindow: ptr window; stringToWrite: cstring): cint {.cdecl, discardable, importc: "waddstr", dynlib: libncurses.}
    ## Writes a string to the specified window.
    ## @Param: 'destinationWindow' the window to write the string to.
    ## @Param: 'stringToWrite'
    ## @Returns: ERR on failure and OK upon successful completion.

proc wgetch*(sourceWindow: ptr window): cint {.cdecl, discardable, importc: "wgetch", dynlib: libncurses.}
    ## Read a character from the specified window.
    ## @Param: 'sourceWindow' the window to read a character from.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getmaxyx*(win: ptr window, y, x: var int) =
    ## retrieves the size of the specified window in the provided y and x parameters.
    ## @Param: 'win' the window to measure.
    ## @Param: 'y' stores the height of the window.
    ## @Param: 'x' stores the width of the window.
    y = getmaxy(win)
    x = getmaxx(win)

proc getyx*(win: ptr window, y, x: var int) =
    ## Reads the logical cursor location from the specified window.
    ## @Param: 'win' the window to get the cursor location from.
    ## @Param: 'y' stores the height of the window.
    ## @Param: 'x' stores the width of the window.
    y = getcury(win)
    x = getcurx(win)
