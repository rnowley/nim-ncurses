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
  
  pdat_2691410692* = object 
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
    pad*: pdat_2691410692
    yoffset*: cshort          # real begy is _begy + _yoffset 
    color*: cint              # current color-pair for non-space character 
  

const 
  NCURSES_ATTR_T* = int

template NCURSES_CAST*(`type`, value: expr): expr = 
  (`type`)(value)

const 
  NCURSES_ATTR_SHIFT* = 8

template NCURSES_BITS*(mask, shift: expr): expr = 
  (NCURSES_CAST(int, (mask)) shl ((shift) + NCURSES_ATTR_SHIFT))

const 
  A_NORMAL* = (1 - 1)
  A_ATTRIBUTES* = NCURSES_BITS(not (1 - 1), 0)
  A_CHARTEXT* = (NCURSES_BITS(1, 0) - 1)
  A_COLOR* = NCURSES_BITS(((1) shl 8) - 1, 0)
  A_STANDOUT* = NCURSES_BITS(1, 8)
  A_UNDERLINE* = NCURSES_BITS(1, 9)
  A_REVERSE* = NCURSES_BITS(1, 10)
  A_BLINK* = NCURSES_BITS(1, 11)
  A_DIM* = NCURSES_BITS(1, 12)
  A_BOLD* = NCURSES_BITS(1, 13)
  A_ALTCHARSET* = NCURSES_BITS(1, 14)
  A_INVIS* = NCURSES_BITS(1, 15)
  A_PROTECT* = NCURSES_BITS(1, 16)
  A_HORIZONTAL* = NCURSES_BITS(1, 17)
  A_LEFT* = NCURSES_BITS(1, 18)
  A_LOW* = NCURSES_BITS(1, 19)
  A_RIGHT* = NCURSES_BITS(1, 20)
  A_TOP* = NCURSES_BITS(1, 21)
  A_VERTICAL* = NCURSES_BITS(1, 22)

proc addch*(a2: chtype): cint {.cdecl, importc: "addch", dynlib: libncurses.}
# generated 

proc addstr*(a2: cstring): cint {.cdecl, importc: "addstr", dynlib: libncurses.}
# generated 

proc attroff*(a2: cint): cint {.cdecl, importc: "attroff", 
    dynlib: libncurses.}
# generated 

proc attron*(a2: cint): cint {.cdecl, importc: "attron", 
    dynlib: libncurses.}
# generated 

proc attrset*(a2: cint): cint {.cdecl, importc: "attrset", 
    dynlib: libncurses.}
# generated 

proc endwin*(): cint {.cdecl, importc: "endwin", dynlib: libncurses.}
# implemented 

proc getch*(): char {.cdecl, importc: "getch", dynlib: libncurses.}
# generated 

proc getnstr*(a2: cstring; a3: cint): cint {.cdecl, importc: "getnstr", 
    dynlib: libncurses.}
# generated 

proc getstr*(a2: cstring): cint {.cdecl, importc: "getstr", dynlib: libncurses.}
# generated 

proc initscr*(): ptr WINDOW {.cdecl, importc: "initscr", dynlib: libncurses.}
# implemented 

proc move*(a2: cint; a3: cint): cint {.cdecl, importc: "move", 
                                       dynlib: libncurses.}
# generated 

proc napms*(a2: cint): cint {.cdecl, importc: "napms", dynlib: libncurses.}
# implemented 

proc printw*(a2: cstring): cint {.varargs, cdecl, importc: "printw", 
                                  dynlib: libncurses.}
# implemented 

proc refresh*(): cint {.cdecl, importc: "refresh", dynlib: libncurses.}
# generated 

proc scanw*(a2: cstring): cint {.varargs, cdecl, importc: "scanw", 
                                 dynlib: libncurses.}
# implemented 
