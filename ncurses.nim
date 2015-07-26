 {.deadCodeElim: on.}
when defined(windows): 
  const 
    libncurses* = "libncurses.dll"
elif defined(macosx): 
  const 
    libncurses* = "libncurses.dylib"
else: 
  const 
    libncurses* = "libncurses.so.5.9"
type 
  ncurses_size_t* = cshort
  ncurses_color_t* = cshort
  chtype* = char
  mmask_t* = cuint
  attr_t* = chtype

# ...must be at least as wide as chtype 

type 
  SCREEN* = screen
  WINDOW* = win_st
  ldat* = object 
  
  pdat_18311999858060558205* = object 
    pad_y*: ncurses_size_t
    pad_x*: ncurses_size_t
    pad_top*: ncurses_size_t
    pad_left*: ncurses_size_t
    pad_bottom*: ncurses_size_t
    pad_right*: ncurses_size_t

  win_st* = object 
    cury*: ncurses_size_t
    curx*: ncurses_size_t     # current cursor position 
                              # window location and size 
    maxy*: ncurses_size_t
    maxx*: ncurses_size_t     # maximums of x and y, NOT window size 
    begy*: ncurses_size_t
    begx*: ncurses_size_t     # screen coords of upper-left-hand corner 
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
    regtop*: ncurses_size_t   # top line of scrolling region 
    regbottom*: ncurses_size_t # bottom line of scrolling region 
                               # these are used only if this is a sub-window 
    parx*: cint               # x coordinate of this window in parent 
    pary*: cint               # y coordinate of this window in parent 
    parent*: ptr WINDOW       # pointer to parent if a sub-window 
                              # these are used only if this is a pad 
    pad*: pdat_18311999858060558205
    yoffset*: ncurses_size_t  # real begy is _begy + _yoffset 
    color*: cint              # current color-pair for non-space character 
  

const 
  ERR* = (- 1)
  OK* = (0)

# Values for the _flags member 

const 
  _SUBWIN* = 0x00000001
  _ENDLINE* = 0x00000002
  _FULLWIN* = 0x00000004
  _SCROLLWIN* = 0x00000008
  _ISPAD* = 0x00000010
  _HASMOVED* = 0x00000020
  _WRAPPED* = 0x00000040

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

# Line graphics 

const 
  ACS_ULCORNER* = cast[cuchar](('l'))

# attributes 

template NCURSES_CAST*(`type`, value: expr): expr = 
  (`type`)(value)

const 
  NCURSES_ATTR_SHIFT* = 8

template NCURSES_BITS*(mask, shift: expr): expr = 
  (NCURSES_CAST(chtype, (mask)) shl ((shift) + NCURSES_ATTR_SHIFT))

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

var curscr* {.importc: "curscr", dynlib: libncurses.}: ptr WINDOW

var newscr* {.importc: "newscr", dynlib: libncurses.}: ptr WINDOW

var stdscr* {.importc: "stdscr", dynlib: libncurses.}: ptr WINDOW

var ttytype* {.importc: "ttytype", dynlib: libncurses.}: ptr char

var COLORS* {.importc: "COLORS", dynlib: libncurses.}: cint

var COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: cint

var COLS* {.importc: "COLS", dynlib: libncurses.}: cint

var ESCDELAY* {.importc: "ESCDELAY", dynlib: libncurses.}: cint

var LINES* {.importc: "LINES", dynlib: libncurses.}: cint

var TABSIZE* {.importc: "TABSIZE", dynlib: libncurses.}: cint

proc getcurx*(a2: ptr WINDOW): cint {.cdecl, importc: "getcurx", 
                                      dynlib: libncurses.}
# generated 

proc getcury*(a2: ptr WINDOW): cint {.cdecl, importc: "getcury", 
                                      dynlib: libncurses.}
# generated 

proc getbegx*(a2: ptr WINDOW): cint {.cdecl, importc: "getbegx", 
                                      dynlib: libncurses.}
# generated 

proc getbegy*(a2: ptr WINDOW): cint {.cdecl, importc: "getbegy", 
                                      dynlib: libncurses.}
# generated 

proc getmaxx*(a2: ptr WINDOW): cint {.cdecl, importc: "getmaxx", 
                                      dynlib: libncurses.}
# generated 

proc getmaxy*(a2: ptr WINDOW): cint {.cdecl, importc: "getmaxy", 
                                      dynlib: libncurses.}
# generated 

proc getparx*(a2: ptr WINDOW): cint {.cdecl, importc: "getparx", 
                                      dynlib: libncurses.}
# generated 

proc getpary*(a2: ptr WINDOW): cint {.cdecl, importc: "getpary", 
                                      dynlib: libncurses.}
# generated 

proc addch*(a2: chtype): cint {.cdecl, importc: "addch", dynlib: libncurses.}
# generated 

proc addchnstr*(a2: ptr chtype; a3: cint): cint {.cdecl, importc: "addchnstr", 
    dynlib: libncurses.}
# generated 

proc addchstr*(a2: ptr chtype): cint {.cdecl, importc: "addchstr", 
                                       dynlib: libncurses.}
# generated 

proc addnstr*(a2: cstring; a3: cint): cint {.cdecl, importc: "addnstr", 
    dynlib: libncurses.}
# generated 

proc addstr*(a2: cstring): cint {.cdecl, importc: "addstr", dynlib: libncurses.}
# generated 

proc attroff*(a2: cint): cint {.cdecl, importc: "attroff", dynlib: libncurses.}
# generated 

proc attron*(a2: cint): cint {.cdecl, importc: "attron", dynlib: libncurses.}
# generated 

proc attrset*(a2: cint): cint {.cdecl, importc: "attrset", dynlib: libncurses.}
# generated 

proc attr_get*(a2: ptr attr_t; a3: ptr cshort; a4: pointer): cint {.cdecl, 
    importc: "attr_get", dynlib: libncurses.}
# generated 

proc attr_off*(a2: attr_t; a3: pointer): cint {.cdecl, importc: "attr_off", 
    dynlib: libncurses.}
# generated 

proc attr_on*(a2: attr_t; a3: pointer): cint {.cdecl, importc: "attr_on", 
    dynlib: libncurses.}
# generated 

proc attr_set*(a2: attr_t; a3: cshort; a4: pointer): cint {.cdecl, 
    importc: "attr_set", dynlib: libncurses.}
# generated 

proc baudrate*(): cint {.cdecl, importc: "baudrate", dynlib: libncurses.}
# implemented 

proc beep*(): cint {.cdecl, importc: "beep", dynlib: libncurses.}
# implemented 

proc bkgd*(a2: chtype): cint {.cdecl, importc: "bkgd", dynlib: libncurses.}
proc bkgdset*(a2: chtype): cint {.cdecl, importc: "bkgdset", dynlib: libncurses.}
# generated 

proc border*(a2: chtype; a3: chtype; a4: chtype; a5: chtype; a6: chtype; 
             a7: chtype; a8: chtype; a9: chtype): cint {.cdecl, 
    importc: "border", dynlib: libncurses.}
# generated 

proc box*(a2: ptr WINDOW; a3: chtype; a4: chtype): cint {.cdecl, importc: "box", 
    dynlib: libncurses.}
# generated 

proc can_change_color*(): bool {.cdecl, importc: "can_change_color", 
                                 dynlib: libncurses.}
# implemented 

proc cbreak*(): cint {.cdecl, importc: "cbreak", dynlib: libncurses.}
# implemented 

proc chgat*(a2: cint; a3: attr_t; a4: cshort; a5: pointer): cint {.cdecl, 
    importc: "chgat", dynlib: libncurses.}
# generated 

proc clear*(): cint {.cdecl, importc: "clear", dynlib: libncurses.}
# generated 

proc clearok*(a2: ptr WINDOW; a3: bool): cint {.cdecl, importc: "clearok", 
    dynlib: libncurses.}
# implemented 

proc clrtobot*(): cint {.cdecl, importc: "clrtobot", dynlib: libncurses.}
# generated 

proc clrtoeol*(): cint {.cdecl, importc: "clrtoeol", dynlib: libncurses.}
# generated 

proc color_content*(a2: cshort; a3: ptr cshort; a4: ptr cshort; a5: ptr cshort): cint {.
    cdecl, importc: "color_content", dynlib: libncurses.}
# implemented 

proc color_set*(a2: cshort; a3: pointer): cint {.cdecl, importc: "color_set", 
    dynlib: libncurses.}
# implemented 

proc COLOR_PAIR*(a2: cint): cint {.cdecl, importc: "COLOR_PAIR", 
                                   dynlib: libncurses.}
# generated 

proc copywin*(a2: ptr WINDOW; a3: ptr WINDOW; a4: cint; a5: cint; a6: cint; 
              a7: cint; a8: cint; a9: cint; a10: cint): cint {.cdecl, 
    importc: "copywin", dynlib: libncurses.}
# implemented 

proc curs_set*(a2: cint): cint {.cdecl, importc: "curs_set", dynlib: libncurses.}
# implemented 

proc def_prog_mode*(): cint {.cdecl, importc: "def_prog_mode", 
                              dynlib: libncurses.}
# implemented 

proc def_shell_mode*(): cint {.cdecl, importc: "def_shell_mode", 
                               dynlib: libncurses.}
# implemented 

proc delay_output*(a2: cint): cint {.cdecl, importc: "delay_output", 
                                     dynlib: libncurses.}
# implemented 

proc delch*(): cint {.cdecl, importc: "delch", dynlib: libncurses.}
# generated 

proc delscreen*(a2: ptr SCREEN): cint {.cdecl, importc: "delscreen", 
                                        dynlib: libncurses.}
# implemented 

proc delwin*(a2: ptr WINDOW): cint {.cdecl, importc: "delwin", 
                                     dynlib: libncurses.}
# implemented 

proc deleteln*(): cint {.cdecl, importc: "deleteln", dynlib: libncurses.}
# generated 

proc derwin*(a2: ptr WINDOW; a3: cint; a4: cint; a5: cint; a6: cint): ptr WINDOW {.
    cdecl, importc: "derwin", dynlib: libncurses.}
# implemented 

proc doupdate*(): cint {.cdecl, importc: "doupdate", dynlib: libncurses.}
# implemented 

proc dupwin*(a2: ptr WINDOW): ptr WINDOW {.cdecl, importc: "dupwin", 
    dynlib: libncurses.}
# implemented 

proc echo*(): cint {.cdecl, importc: "echo", dynlib: libncurses.}
# implemented 

proc echochar*(a2: chtype): cint {.cdecl, importc: "echochar", 
                                   dynlib: libncurses.}
# generated 

proc endwin*(): cint {.cdecl, importc: "endwin", dynlib: libncurses.}
# implemented 

proc erase*(): cint {.cdecl, importc: "erase", dynlib: libncurses.}
# generated 

proc erasechar*(): char {.cdecl, importc: "erasechar", dynlib: libncurses.}
# implemented 

proc filter*() {.cdecl, importc: "filter", dynlib: libncurses.}
# implemented 

proc flash*(): cint {.cdecl, importc: "flash", dynlib: libncurses.}
# implemented 

proc flushinp*(): cint {.cdecl, importc: "flushinp", dynlib: libncurses.}
proc getbkgd*(a2: ptr WINDOW): chtype {.cdecl, importc: "getbkgd", 
                                        dynlib: libncurses.}
# generated 

proc getch*(): char {.cdecl, importc: "getch", dynlib: libncurses.}
# generated 

proc getnstr*(a2: cstring; a3: cint): cint {.cdecl, importc: "getnstr", 
    dynlib: libncurses.}
# generated 

proc getstr*(a2: cstring): cint {.cdecl, importc: "getstr", dynlib: libncurses.}
# generated 

proc getwin*(a2: ptr FILE): ptr WINDOW {.cdecl, importc: "getwin", 
    dynlib: libncurses.}
# implemented 

proc halfdelay*(a2: cint): cint {.cdecl, importc: "halfdelay", 
                                  dynlib: libncurses.}
# implemented 

proc has_colors*(): bool {.cdecl, importc: "has_colors", dynlib: libncurses.}
proc has_ic*(): bool {.cdecl, importc: "has_ic", dynlib: libncurses.}
# implemented 

proc has_il*(): bool {.cdecl, importc: "has_il", dynlib: libncurses.}
# implemented 

proc hline*(a2: chtype; a3: cint): cint {.cdecl, importc: "hline", 
    dynlib: libncurses.}
# generated 

proc init_color*(a2: cshort; a3: cshort; a4: cshort; a5: cshort): cint {.cdecl, 
    importc: "init_color", dynlib: libncurses.}
# implemented 

proc init_pair*(a2: cshort; a3: cshort; a4: cshort): cint {.cdecl, 
    importc: "init_pair", dynlib: libncurses.}
# implemented 

proc initscr*(): ptr WINDOW {.cdecl, importc: "initscr", dynlib: libncurses.}
# implemented 

proc move*(a2: cint; a3: cint): cint {.cdecl, importc: "move", 
                                       dynlib: libncurses.}
# generated 

proc mvaddch*(a2: cint; a3: cint; a4: chtype): cint {.cdecl, importc: "mvaddch", 
    dynlib: libncurses.}
# generated 

proc mvaddchnstr*(a2: cint; a3: cint; a4: ptr chtype; a5: cint): cint {.cdecl, 
    importc: "mvaddchnstr", dynlib: libncurses.}
# generated 

proc mvaddchstr*(a2: cint; a3: cint; a4: ptr chtype): cint {.cdecl, 
    importc: "mvaddchstr", dynlib: libncurses.}
# generated 

proc mvaddnstr*(a2: cint; a3: cint; a4: cstring; a5: cint): cint {.cdecl, 
    importc: "mvaddnstr", dynlib: libncurses.}
# generated 

proc mvaddstr*(a2: cint; a3: cint; a4: cstring): cint {.cdecl, 
    importc: "mvaddstr", dynlib: libncurses.}
# generated 

proc napms*(a2: cint): cint {.cdecl, importc: "napms", dynlib: libncurses.}
# implemented 

proc newwin*(a2: cint; a3: cint; a4: cint; a5: cint): ptr WINDOW {.cdecl, 
    importc: "newwin", dynlib: libncurses.}
proc nodelay*(a2: ptr WINDOW; a3: bool): cint {.cdecl, importc: "nodelay", 
    dynlib: libncurses.}
# implemented 

proc noecho*(): cint {.cdecl, importc: "noecho", dynlib: libncurses.}
# implemented 

proc printw*(a2: cstring): cint {.varargs, cdecl, importc: "printw", 
                                  dynlib: libncurses.}
# implemented 

proc refresh*(): cint {.cdecl, importc: "refresh", dynlib: libncurses.}
# generated 

proc scanw*(a2: cstring): cint {.varargs, cdecl, importc: "scanw", 
                                 dynlib: libncurses.}
proc start_color*(): cint {.cdecl, importc: "start_color", dynlib: libncurses.}
# implemented 

proc ungetch*(a2: cint): cint {.cdecl, importc: "ungetch", dynlib: libncurses.}
# implemented 

proc waddch*(a2: ptr WINDOW; a3: chtype): cint {.cdecl, importc: "waddch", 
    dynlib: libncurses.}
# implemented 

proc waddchnstr*(a2: ptr WINDOW; a3: ptr chtype; a4: cint): cint {.cdecl, 
    importc: "waddchnstr", dynlib: libncurses.}
# implemented 

proc waddchstr*(a2: ptr WINDOW; a3: ptr chtype): cint {.cdecl, 
    importc: "waddchstr", dynlib: libncurses.}
# generated 

proc waddnstr*(a2: ptr WINDOW; a3: cstring; a4: cint): cint {.cdecl, 
    importc: "waddnstr", dynlib: libncurses.}
# implemented 

proc waddstr*(a2: ptr WINDOW; a3: cstring): cint {.cdecl, importc: "waddstr", 
    dynlib: libncurses.}
# generated 

proc wattron*(a2: ptr WINDOW; a3: cint): cint {.cdecl, importc: "wattron", 
    dynlib: libncurses.}
# generated 

proc wattroff*(a2: ptr WINDOW; a3: cint): cint {.cdecl, importc: "wattroff", 
    dynlib: libncurses.}
# generated 

proc wattrset*(a2: ptr WINDOW; a3: cint): cint {.cdecl, importc: "wattrset", 
    dynlib: libncurses.}
# generated 

proc wattr_get*(a2: ptr WINDOW; a3: ptr attr_t; a4: ptr cshort; a5: pointer): cint {.
    cdecl, importc: "wattr_get", dynlib: libncurses.}
# generated 

proc wattr_on*(a2: ptr WINDOW; a3: attr_t; a4: pointer): cint {.cdecl, 
    importc: "wattr_on", dynlib: libncurses.}
# implemented 

proc wattr_off*(a2: ptr WINDOW; a3: attr_t; a4: pointer): cint {.cdecl, 
    importc: "wattr_off", dynlib: libncurses.}
# implemented 

proc wattr_set*(a2: ptr WINDOW; a3: attr_t; a4: cshort; a5: pointer): cint {.
    cdecl, importc: "wattr_set", dynlib: libncurses.}
# generated 

proc wbkgd*(a2: ptr WINDOW; a3: chtype): cint {.cdecl, importc: "wbkgd", 
    dynlib: libncurses.}
# implemented 

proc wgetch*(a2: ptr WINDOW): cint {.cdecl, importc: "wgetch", 
                                     dynlib: libncurses.}
# implemented 

proc wprintw*(a2: ptr WINDOW; a3: cstring): cint {.varargs, cdecl, 
    importc: "wprintw", dynlib: libncurses.}
# implemented 

proc wrefresh*(a2: ptr WINDOW): cint {.cdecl, importc: "wrefresh", 
                                       dynlib: libncurses.}
# implemented 

proc wscanw*(a2: ptr WINDOW; a3: cstring): cint {.varargs, cdecl, 
    importc: "wscanw", dynlib: libncurses.}
# implemented 
