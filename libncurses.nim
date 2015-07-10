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
  chtype* = char
  mmask_t* = cuint
  attr_t* = chtype

# ...must be at least as wide as chtype 

type 
  WINDOW* = win_st
  ldat* = object 
  
  pdat_18314018518274554323* = object 
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
    parent*: ptr WINDOW       # pointer to parent if a sub-window 
                              # these are used only if this is a pad 
    pad*: pdat_18314018518274554323
    yoffset*: cshort          # real begy is _begy + _yoffset
    color*: cint              # current color-pair for non-space character

  mevent* = object
    id*: cshort               # ID to distinguish multiple devices
    x*, y*, z*: cint          # event coordinates (character-cell)
    bstate*: mmask_t          # button state bits

const 
  ERR* = (- 1)
  OK* = (0)

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

# mouse events

template NCURSES_MOUSE_MASK*(b: expr, m: expr): int =
  m shl (((b) - 1) * 6)

const
  KEY_MOUSE*               = 0o631 # Mouse event has occurred
  REPORT_MOUSE_POSITION*   = NCURSES_MOUSE_MASK(5, 0o10)
  ALL_MOUSE_EVENTS*        = (REPORT_MOUSE_POSITION - 1)

  NCURSES_BUTTON_RELEASED* = 0o01
  NCURSES_BUTTON_PRESSED*  = 0o02
  NCURSES_BUTTON_CLICKED*  = 0o04
  NCURSES_DOUBLE_CLICKED*  = 0o10
  NCURSES_TRIPLE_CLICKED*  = 0o20
  NCURSES_RESERVED_EVENT*  = 0o40

  BUTTON1_RELEASED*        = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_RELEASED)
  BUTTON1_PRESSED*         = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_PRESSED)
  BUTTON1_CLICKED*         = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_CLICKED)
  BUTTON1_DOUBLE_CLICKED*  = NCURSES_MOUSE_MASK(1, NCURSES_DOUBLE_CLICKED)
  BUTTON1_TRIPLE_CLICKED*  = NCURSES_MOUSE_MASK(1, NCURSES_TRIPLE_CLICKED)

  BUTTON2_RELEASED*        = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_RELEASED)
  BUTTON2_PRESSED*         = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_PRESSED)
  BUTTON2_CLICKED*         = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_CLICKED)
  BUTTON2_DOUBLE_CLICKED*  = NCURSES_MOUSE_MASK(2, NCURSES_DOUBLE_CLICKED)
  BUTTON2_TRIPLE_CLICKED*  = NCURSES_MOUSE_MASK(2, NCURSES_TRIPLE_CLICKED)

  BUTTON3_RELEASED*        = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_RELEASED)
  BUTTON3_PRESSED*         = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_PRESSED)
  BUTTON3_CLICKED*         = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_CLICKED)
  BUTTON3_DOUBLE_CLICKED*  = NCURSES_MOUSE_MASK(3, NCURSES_DOUBLE_CLICKED)
  BUTTON3_TRIPLE_CLICKED*  = NCURSES_MOUSE_MASK(3, NCURSES_TRIPLE_CLICKED)

  BUTTON4_RELEASED*        = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_RELEASED)
  BUTTON4_PRESSED*         = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_PRESSED)
  BUTTON4_CLICKED*         = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_CLICKED)
  BUTTON4_DOUBLE_CLICKED*  = NCURSES_MOUSE_MASK(4, NCURSES_DOUBLE_CLICKED)
  BUTTON4_TRIPLE_CLICKED*  = NCURSES_MOUSE_MASK(4, NCURSES_TRIPLE_CLICKED)

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

proc addstr*(a2: cstring): cint {.cdecl, importc: "addstr", dynlib: libncurses.}
# generated 

proc attroff*(a2: cint): cint {.cdecl, importc: "attroff", dynlib: libncurses.}
# generated 

proc attron*(a2: cint): cint {.cdecl, importc: "attron", dynlib: libncurses.}
# generated 

proc attrset*(a2: cint): cint {.cdecl, importc: "attrset", dynlib: libncurses.}
# generated 

proc bkgd*(a2: chtype): cint {.cdecl, importc: "bkgd", dynlib: libncurses.}
proc can_change_color*(): bool {.cdecl, importc: "can_change_color", 
                                 dynlib: libncurses.}
# implemented 

proc clear*(): cint {.cdecl, importc: "clear", dynlib: libncurses.}
# generated 

proc clrtobot*(): cint {.cdecl, importc: "clrtobot", dynlib: libncurses.}
# generated 

proc clrtoeol*(): cint {.cdecl, importc: "clrtoeol", dynlib: libncurses.}
# generated 

proc COLOR_PAIR*(a2: cint): cint {.cdecl, importc: "COLOR_PAIR", 
                                   dynlib: libncurses.}
# generated 

proc echo*(): cint {.cdecl, importc: "echo", dynlib: libncurses.}
# implemented 

proc endwin*(): cint {.cdecl, importc: "endwin", dynlib: libncurses.}
# implemented 

proc erase*(): cint {.cdecl, importc: "erase", dynlib: libncurses.}
# generated 

proc flushinp*(): cint {.cdecl, importc: "flushinp", dynlib: libncurses.}
proc getch*(): char {.cdecl, importc: "getch", dynlib: libncurses.}
# generated 

proc getnstr*(a2: cstring; a3: cint): cint {.cdecl, importc: "getnstr", 
    dynlib: libncurses.}
# generated 

proc getstr*(a2: cstring): cint {.cdecl, importc: "getstr", dynlib: libncurses.}
# generated 

proc has_colors*(): bool {.cdecl, importc: "has_colors", dynlib: libncurses.}
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

proc mousemask*(newmask: mmask_t, oldmask: ptr mmask_t): mmask_t {.cdecl, importc: "mousemask", dynlib: libncurses.}
# implemented

proc getmouse*(event: ptr mevent): cint {.cdecl, importc: "getmouse", dynlib: libncurses.}
# implemented

proc keypad*(win: ptr WINDOW, b: bool): cint {.cdecl, importc: "keypad", dynlib: libncurses.}
# implemented
