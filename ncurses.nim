{.deadCodeElim: on.}
when defined(windows):
  const libncurses* = "libncurses.dll"
elif defined(macosx):
  const libncurses* = "libncurses.dylib"
else:
  const libncurses* = "libncursesw.so"
{.pragma: ncurses_default, discardable, cdecl, dynlib: libncurses.}

type
  # 32 or 64
  chtype*  = cuint ## Holds a character and possibly an attribute
  # ...must be at least as wide as chtype
  attr_t*  = chtype ## Attribute

  cchar_t* = object #E complex char
    attr: attr_t
    chars: WideCString #5
    ext_color: cint

  ldat = object ## line data
  Screen* {.ncurses_default, importc: "struct SCREEN".} = object
  Terminal {.ncurses_default, importc: "struct TERMINAL".} = object
  Window* = win_st
  win_st = object ## window struct
    cury*, curx*: cshort      # current cursor position
    
    # window location and size
    maxy*, maxx*: cshort      # maximums of x and y, NOT window size
    begy*, begx*: cshort      # screen coords of upper-left-hand corner
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
    pary*, parx*: cint        # y, x coordinates of this window in parent
    parent*: PWindow       # pointer to parent if a sub-window
    
    # these are used only if this is a pad
    pad*: pdat
    yoffset*: cshort          # real begy is _begy + _yoffset
    bkgrnd*: cchar_t          # current background char/attribute pair
    color*: cint              # current color-pair for non-space character
  
  pdat = object ## pad data
    pad_y*,      pad_x*:     cshort
    pad_top*,    pad_left*:  cshort
    pad_bottom*, pad_right*: cshort

  mmask_t* = uint32
  Mevent* = object ## mouse event
    id*: cshort               # ID to distinguish multiple devices
    x*, y*, z*: cint          # event coordinates (character-cell)
    bstate*: mmask_t          # button state bits
  
  #not ncurses but used to make things easier
  ErrCode = cint ## Returns ERR upon failure or OK on success.
  PWindow = ptr Window
  PScreen = ptr Screen

const
  ERR* = (-1)
  OK*  = (0)

template NCURSES_CAST(`type`, value: untyped): untyped = (`type`)(value)

#color: color manipulation routines
#https://invisible-island.net/ncurses/man/curs_color.3x.html
const
  COLOR_BLACK*   = 0
  COLOR_RED*     = 1
  COLOR_GREEN*   = 2
  COLOR_YELLOW*  = 3
  COLOR_BLUE*    = 4
  COLOR_MAGENTA* = 5
  COLOR_CYAN*    = 6
  COLOR_WHITE*   = 7
var
  COLORS* {.importc: "COLORS", dynlib: libncurses.}: int
    ## is initialized by start_color to the maximum number of colors the
    ## terminal can support.
  COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: int
    ## is initialized by start_color to the maximum number of color pairs the
    ## terminal can support.
template COLOR_PAIR*(n: untyped): untyped = NCURSES_BITS((n), 0'i64)
template PAIR_NUMBER*(a: untyped): untyped =
  (NCURSES_CAST(int, ((NCURSES_CAST(uint64, (a)) and A_COLOR) shr
    NCURSES_ATTR_SHIFT)))

proc start_color*(): ErrCode {.ncurses_default, importc: "start_color".}
  ## Initialises the the eight basic colours and the two global varables COLORS and COLOR_PAIRS.
  ## It also restores the colours on the terminal to the values that they had when the
  ## terminal was just turned on.
  ## @Note: It is good practice to call this routine right after initscr. It must be
  ## called before any other colour manipulating routines.
proc has_colors*(): bool {.ncurses_default, importc: "has_colors".}
  ## Used to determine if the terminal can manipulate colours.
  ## @Returns: true if the terminal can manipulate colours or false if it cannot.
proc can_change_color*(): bool {.ncurses_default, importc: "can_change_color".}
  ## Used to determine if the terminal supports colours and can change their definitions.
  ## @Returns: true if the terminal supports colours and can change their definitions or
  ## false otherwise.
proc init_pair*(pair, f,b: cshort): ErrCode {.ncurses_default, importc: "init_pair".}
  ## Changes the definition of a colour pair.
  ## @Param: 'pair' the number of the colour pair to change.
  ## @Param: 'foreground': the foreground colour number.
  ## @Param: 'background': the background colour number.
  ## @Returns: ERR on failure and OK upon successful completion.
proc init_color*(color: cshort, r, g, b: cshort): ErrCode {.ncurses_default, importc: "init_color".}
proc init_extended_pair*(pair, f,b: cint): ErrCode {.ncurses_default, importc: "init_extended_pair".}
proc init_extended_color*(color: cint, r, g, b: cint): ErrCode {.ncurses_default, importc: "init_extended_color".}
proc color_content*(color: cshort, r, g, b: ptr cshort): ErrCode {.ncurses_default, importc: "color_content".}
proc pair_content*(pair: cshort, f,b: ptr cshort): ErrCode {.ncurses_default, importc: "pair_content".}
proc extended_color_content*(color: cint, r, g, b: ptr cint): ErrCode {.ncurses_default, importc: "extended_color_content".}
proc pair_content*(pair: cint, f,b: ptr cint): ErrCode {.ncurses_default, importc: "extended_pair_content".}
proc reset_color_pairs*(): void {.ncurses_default, importc: "reset_color_pairs".}

#threads: thread support
proc get_escdelay*(): cint {.ncurses_default, importc: "get_escdelay".}
proc set_escdelay*(size: cint): ErrCode {.ncurses_default, importc: "set_escdelay".}
proc set_tabsize*(size: cint): ErrCode {.ncurses_default, importc: "use_tabsize".}
proc use_screen*(scr: PScreen, screen_cb: proc(scr: PScreen, pt: pointer): cint): ErrCode {.ncurses_default, importc: "use_screen".}
proc use_window*(win: PWindow, screen_cb: proc(win: PWindow, pt: pointer): cint): ErrCode {.ncurses_default, importc: "use_window".}

#add_wchs: Adding complex characters to a window
proc add_wch*(wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "add_wch".}
proc wadd_wch*(win: PWindow, wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "wadd_wch".}
proc mvadd_wch*(y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvadd_wch".}
proc mvwadd_wch*(win: PWindow, y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvwadd_wch".}
proc echo_wchar*(wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "echo_wchar".}
proc wech_wchar*(win: PWindow, wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "wech_wchar".}

#add_wchstr: Adding an array of complex characters to a window
proc add_wchstr*(wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "add_wchstr".}
proc add_wchnstr*(wchstr: ptr cchar_t, numberOfCharacters: cint): ErrCode {.ncurses_default, importc: "add_wchnstr".}
proc wadd_wchstr*(win: PWindow, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "wadd_wchstr".}
proc wadd_wchnstr*(win: PWindow, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "wadd_wchnstr".}
proc mvadd_wchstr*(y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvadd_wchstr".}
proc mvadd_wchnstr*(y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvadd_wchnstr".}
proc mvwadd_wchstr*(win: PWindow, y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvwadd_wchstr".}
proc mvwadd_wchnstr*(win: PWindow, y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvwadd_wchnstr".}

#addch: Adding a character (with attributes) to a window
proc addch*(character: chtype): ErrCode {.ncurses_default, importc: "addch".}
  ## Puts a character into the stdscr at its current window position and then advances
  ## the current window position to the next position.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddch*(win: PWindow, ch: chtype): ErrCode {.ncurses_default, importc: "waddch".}
proc mvaddch*(y: int; x: int; character: chtype): cint {.ncurses_default, importc: "mvaddch".}
  ## Moves the cursor to the specified position and outputs the provided character.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvwaddch*(win: PWindow, y, x: int, ch: chtype): ErrCode {.ncurses_default, importc: "mvwaddch".}
proc echochar*(ch: chtype): ErrCode {.ncurses_default, importc: "echochar".}
proc wechochar*(win: PWindow, ch: chtype): ErrCode {.ncurses_default, importc: "wechochar".}

#addchstr: Adding a string of characters (and attributes) to a window
proc addchstr*(chstr: ptr chtype): ErrCode {.ncurses_default, importc: "addchstr".}
proc addchnstr*(chstr: ptr chtype, n: cint): ErrCode {.ncurses_default, importc: "addchnstr".}
proc waddchstr*(win: PWindow, chstr: ptr chtype): ErrCode {.ncurses_default, importc: "waddchstr".}
proc waddchnstr*(win: PWindow, chstr: ptr chtype, n: cint): ErrCode {.ncurses_default, importc: "waddchnstr".}
proc mvaddchstr*(y, x: cint, chstr: ptr chtype): ErrCode {.ncurses_default, importc: "mvaddchstr".}
proc mvaddchnstr*(y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses_default, importc: "mvaddchnstr".}
proc mvwaddchstr*(win: PWindow, y, x: cint, chstr: ptr chtype): ErrCode {.ncurses_default, importc: "mvwaddchstr".}
proc mvwaddchnstr*(win: PWindow, y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses_default, importc: "mvwaddchnstr".}

#addstr: Adding a string of characters to a window (cstring)
proc addstr*(str: cstring): ErrCode {.ncurses_default, importc: "addstr".}
  ## Adds a string of characters the the stdscr and advances the cursor.
  ## @Param: The string to add the stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc addnstr*(str: cstring, n: cint): ErrCode {.ncurses_default, importc: "addnstr".}
proc waddstr*(win: PWindow; str: cstring): ErrCode {.ncurses_default, importc: "waddstr".}
  ## Writes a string to the specified window.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'stringToWrite'
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "waddnstr".}
proc mvaddstr*(y, x: cint; str: cstring): ErrCode {.ncurses_default, importc: "mvaddstr".}
  ## Moves the cursor to the specified position and outputs the provided string.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'stringToOutput' the string to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvaddnstr*(y, x: cint, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "mvaddnstr".}
proc mvwaddstr*(win: PWindow, y, x: int, str: cstring): ErrCode {.ncurses_default, importc: "mvwaddstr".}
proc mvwaddnstr*(win: PWindow, y, x: int, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "mvwaddnstr".}

#addwstr: Adding a string of wide characters to a window (WideCString)
proc addwstr(wstr: WideCString): ErrCode {.ncurses_default, importc: "addwstr".}
proc addnwstr(wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "addnwstr".}
proc waddwstr(win: PWindow, wstr: WideCString): ErrCode {.ncurses_default, importc: "waddwstr".}
proc waddnwstr(win: PWindow, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "waddnwstr".}
proc mvaddwstr(y, x: cint, win: PWindow, wstr: WideCString): ErrCode {.ncurses_default, importc: "mvaddwstr".}
proc mvaddnwstr(y, x: cint, win: PWindow, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "mvaddnwstr".}
proc mvwaddwstr(win: PWindow, y, x: cint, wstr: WideCString): ErrCode {.ncurses_default, importc: "mvwaddwstr".}
proc mvwaddnwstr(win: PWindow, y, x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "mvwaddnwstr".}

#new_pair: Color-pair functions
proc alloc_pair*(fg, bg: cint): ErrCode {.ncurses_default, importc: "".}
proc find_pair*(fg, bg: cint): ErrCode {.ncurses_default, importc: "".}
proc free_pair*(pair: cint): ErrCode {.ncurses_default, importc: "".}

#default_colors: Use terminal's default colors
proc use_default_colors*(): ErrCode {.ncurses_default, importc: "use_default_colors".}
proc assume_default_colors*(fg, bg: cint): ErrCode {.ncurses_default, importc: "assume_default_colors".}

#attr: Character and attribute control routines
const NCURSES_ATTR_SHIFT = 8'i64
template NCURSES_BITS(mask, shift: untyped): untyped =
 (NCURSES_CAST(int64, (mask)) shl ((shift) + NCURSES_ATTR_SHIFT))
const
  u1: uint = 1
  A_NORMAL*      = (u1 - u1)            #0
  A_BOLD*        = NCURSES_BITS(not (u1 - u1), 0)   #2097152
  A_UNDERLINE*   = NCURSES_BITS((u1 shl 8) - u1, 0) #131072
  A_ATTRIBUTES*  = NCURSES_BITS(u1,  8) #4294967040'i64
  A_CHAR_TEXT*   = NCURSES_BITS(u1,  9) #255
  A_REVERSE*     = NCURSES_BITS(u1, 10) #262144
  A_BLINK*       = NCURSES_BITS(u1, 11) #524288
  A_DIM*         = NCURSES_BITS(u1, 12) #1048576
  A_ALT_CHARSET* = NCURSES_BITS(u1, 13) #4194304
  A_INVIS*       = NCURSES_BITS(u1, 14) #8388608
  A_PROTECT*     = NCURSES_BITS(u1, 15) #16777216
  A_HORIZONTAL*  = NCURSES_BITS(u1, 16) #33554432
  A_LEFT*        = NCURSES_BITS(u1, 17) #67108864
  A_LOW*         = NCURSES_BITS(u1, 18) #34217728
  A_RIGHT*       = NCURSES_BITS(u1, 19) #268435456
  A_TOP*         = NCURSES_BITS(u1, 20) #536870912
  A_VERTICAL*    = NCURSES_BITS(u1, 21) #1073741824
  A_ITALIC*      = NCURSES_BITS(u1, 22) #2147483648

proc attr_get*(attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.ncurses_default, importc: "attr_get".}
proc wattr_get*(win: PWindow, attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.ncurses_default, importc: "wattr_get".}
proc attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "attr_set".}
proc wattr_set*(win: PWindow, attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "wattr_set".}
proc attr_off*(attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "attr_off".}
proc wattr_off*(win: PWindow, attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "wattr_off".}
proc attr_on*(attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "attr_on".}
proc wattr_on*(win: PWindow, attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "wattr_on".}
proc attroff*(attrs: cint): ErrCode {.ncurses_default, importc: "attroff".}
  ## Turns off the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn off for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattroff*(win: PWindow, attrs: cint): ErrCode {.ncurses_default, importc: "wattroff".}
proc attron*(attrs: cint): ErrCode {.ncurses_default, importc: "attron".}
  ## Turns on the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn on for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattron*(win: PWindow, attrs: cint): ErrCode {.ncurses_default, importc: "wattron".}
proc attrset*(attrs: cint): ErrCode {.ncurses_default, importc: "attrset".}
  ## Sets the current attributes of the given window to the provided attributes.
  ## @Param: 'attributes', the attributes to apply to the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattrset*(win: PWindow, attrs: cint): ErrCode {.ncurses_default, importc: "wattrset".}
proc chgat*(n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "chgat".}
proc wchgat*(win: PWindow, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "wchgat".}
proc mvchgat*(y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "mvchgat".}
proc mvwchgat*(win: PWindow, y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "mvwchgat".}
proc color_set*(pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "color_set".}
proc wcolor_set*(win: PWindow, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "wcolor_set".}
proc standend(): ErrCode {.ncurses_default, importc: "standend".}
proc wstandend*(win: PWindow): ErrCode {.ncurses_default, importc: "wstandend".}
proc standout*(): ErrCode {.ncurses_default, importc: "standout".}
proc wstandout*(win: PWindow): ErrCode {.ncurses_default, importc: "wstandout".}

#termattrs: Enviroment query routines
proc baudrate*(): cint {.ncurses_default, importc: "baudrate".}
proc erasechar*() {.ncurses_default, importc: "erasechar".}
proc erasewchar*(ch: WideCString) {.ncurses_default, importc: "erasewchar".}
proc has_ic*(): bool {.ncurses_default, importc: "has_ic".}
proc has_il*(): bool {.ncurses_default, importc: "has_il".}
proc killchar*(): cchar {.ncurses_default, importc: "killchar".}
proc killwchar*(ch: WideCString): char {.ncurses_default, importc: "killwchar".}
proc longname*(): cstring {.ncurses_default, importc: "longname".}
proc term_attrs*(): attr_t {.ncurses_default, importc: "term_attrs".}
proc term_attrs_ch*(): chtype {.ncurses_default, importc: "termattrs".}
  ## in C this function appears as termattr, although because of
  ## Nim's style insensitivity this had to be changed.
proc termname*(): cstring {.ncurses_default, importc: "termname".}

#beep: Bell and screen flash routines
proc beep*(): ErrCode {.ncurses_default, importc: "beep".}
proc flash*(): ErrCode {.ncurses_default, importc: "flash".}
  ## Flashes the screen and if that is not possible it sounds the alert. If this is not possible
  ## nothing happens.
  ## @Returns: ERR on failure and OK upon successfully flashing.

#bkgd: Window background manipulation routines
proc bkgdset*(ch: chtype): void {.ncurses_default, importc: "bkgdset".}
proc wbkgdset*(win: PWindow, ch: chtype): void {.ncurses_default, importc: "wbkgdset".}
proc bkgd*(ch: chtype): ErrCode {.ncurses_default, importc: "bkgd".}
  ## Sets the background property of the current window and apply this setting to every
  ## character position in the window.
  ## @Param: 'background' the background property to apply.
proc wbkgd*(win: PWindow, ch: chtype): ErrCode {.ncurses_default, importc: "wbkgd".}
proc getbkgd*(win: PWindow): chtype {.ncurses_default, importc: "getbkgd".}

#bkgrnd: Window complex background manipulation routines
proc bkgrnd*(wch: cchar_t): ErrCode {.ncurses_default, importc: "bkgrnd".}
proc wbkgrnd*(win: PWindow, wch: cchar_t): ErrCode {.ncurses_default, importc: "wbkgrnd".}
proc bkgrndset*(wch: cchar_t): void {.ncurses_default, importc: "bkgrndset".}
proc wbkgrndset*(win: PWindow, wch: cchar_t): void {.ncurses_default, importc: "getbkgrnd".}
proc getbkgrnd*(wch: cchar_t): ErrCode {.ncurses_default, importc: "getbkgrnd".}
proc wgetbkgrnd*(win: PWindow, wch: cchar_t): ErrCode {.ncurses_default, importc: "wgetbkgrnd".}

#border: Create borders, horizontal and vertical lines
proc border*(ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses_default, importc: "border".}
proc wborder*(win: PWindow, ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses_default, importc: "wborder".}
proc box*(win: PWindow, verch, horch: chtype): ErrCode {.ncurses_default, importc: "box".}
proc hline*(ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "hline".}
proc whline*(win: PWindow, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "whline".}
proc vline*(ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "vline".}
proc wvline*(win: PWindow, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "wvline".}
proc mvhline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "mvhline".}
proc mvwhline*(win: PWindow, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "mvwhline".}
proc mvvline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "mvvline".}
proc mvwvline*(win: PWindow, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses_default, importc: "mvwvline".}

#borderset: Create borders or lines using complex characters and renditions
proc border_set*(ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses_default, importc: "border_set".}
proc wborder_set*(win: PWindow, ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses_default, importc: "wborder_set".}
proc box_set*(win: PWindow, verch, horch: cchar_t): ErrCode {.ncurses_default, importc: "box_set".}
proc hline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "hline_set".}
proc whline_set*(win: PWindow, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "whline_set".}
proc mvhline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvhline_set".}
proc mvwhline_set*(win: PWindow, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvwhline_set".}
proc vline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "vline_set".}
proc wvline_set*(win: PWindow, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "wvline_set".}
proc mvvline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvvline_set".}
proc mvwvline_set*(win: PWindow, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvwvline_set".}

#inopts: Input options
proc cbreak*(): ErrCode {.ncurses_default, importc: "cbreak".}
  ## The cbreak routine disables line buffering and erase/kill character-processing
  ## (interrupt and flow control characters are unaffected), making characters typed by
  ## the user immediately available to the program.
  ## @Returns: ERR on failure and OK upon successful completion.
proc nocbreak*(): ErrCode {.ncurses_default, importc: "nocbreak".}
  ## Returns the terminal to normal (cooked mode).
  ## @Returns: ERR on failure and OK upon successful completion.
proc noecho*(): ErrCode {.ncurses_default, importc: "noecho".}
proc onecho*(): ErrCode {.ncurses_default, importc: "echo".}
  ## Previously `echo`, but this being a Nim's print function, is changed to `onecho`
proc halfdelay*(tenths: cint): ErrCode {.ncurses_default, importc: "halfdelay".}
proc keypad*(win: PWindow, bf: bool): cint {.ncurses_default, importc: "keypad".}
proc meta*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "meta".}
proc nodelay*(win: PWindow, bf: bool): cint {.ncurses_default, importc: "nodelay".}
proc raw*(): ErrCode {.ncurses_default, importc: "raw".}
proc noraw*(): ErrCode {.ncurses_default, importc: "noraw".}
proc noqiflush*(): void {.ncurses_default, importc: "noqiflush".}
proc qiflush*(): void {.ncurses_default, importc: "qiflush".}
proc notimeout*(): ErrCode {.ncurses_default, importc: "notimeout".}
proc timeout*(delay: cint): void {.ncurses_default, importc: "timeout".}
proc wtimeout*(win: PWindow, delay: cint): void {.ncurses_default, importc: "wtimeout".}
proc typeahead*(fd: cint): ErrCode {.ncurses_default, importc: "typeahead".}

#clear: Clear all or part of a window
proc erase*(): ErrCode {.ncurses_default, importc: "erase".}
proc werase*(win: PWindow): ErrCode {.ncurses_default, importc: "werase".}
proc clear*(): ErrCode {.ncurses_default, importc: "clear".}
proc wclear*(win: PWindow): ErrCode {.ncurses_default, importc: "wclear".}
proc clrtobot*(): ErrCode {.ncurses_default, importc: "clrtobot".}
proc wclrtobot*(win: PWindow): ErrCode {.ncurses_default, importc: "wclrtobot".}
proc clrtoeol*(): ErrCode {.ncurses_default, importc: "clrtoeol".}
proc wclrtoeol*(win: PWindow): ErrCode {.ncurses_default, importc: "wclrtoeol".}

#outopts: Output options
proc clearok*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "clearok".}
proc idlok*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "idlok".}
proc idcok*(win: PWindow, bf: bool): void {.ncurses_default, importc: "idcok".}
proc immedok*(win: PWindow, bf: bool): void {.ncurses_default, importc: "immedok".}
proc leaveok*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "leaveok".}
proc setscrreg*(top, bot: cint): ErrCode {.ncurses_default, importc: "setscrreg".}
proc wsetscrreg*(win: PWindow, top, bot: cint): ErrCode {.ncurses_default, importc: "wsetscrreg".}
proc scrollok*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "scrollok".}
proc nl*(): ErrCode {.ncurses_default, importc: "nl".}
proc nonl*(): ErrCode {.ncurses_default, importc: "nonl".}

#overlay: overlay and manipulate overlapped windows
proc overlay*(srcwin, dstwin: PWindow): ErrCode {.ncurses_default, importc: "overlay".}
proc overwrite*(srcwin, dstwin: PWindow): ErrCode {.ncurses_default, importc: "overwrite".}
proc copywin*(srcwin, dstwin: PWindow,
  sminrow, smincol,
  dminrow, dmincol,
  dmaxrow, dmaxcol: cint
): ErrCode {.ncurses_default, importc: "copywin".}

#kernel: low-level routines (all except cur_set will always return OK)
proc def_prog_mode*(): ErrCode {.ncurses_default, importc: "def_prog_mode".}
proc def_shell_mode*(): ErrCode {.ncurses_default, importc: "def_shell_mode".}
proc reset_prog_mode*(): ErrCode {.ncurses_default, importc: "reset_prog_mode".}
proc reset_shell_mode*(): ErrCode {.ncurses_default, importc: "reset_shell_mode".}
proc resetty*(): ErrCode {.ncurses_default, importc: "resetty".}
proc savetty*(): ErrCode {.ncurses_default, importc: "savetty".}
proc getsyx*(y,x: cint): void {.ncurses_default, importc: "getsyx".}
proc setsyx*(y,x: cint): void {.ncurses_default, importc: "setsyx".}
proc ripoffline*(line: cint, init: proc(win: PWindow, cols: cint): cint): ErrCode {.ncurses_default, importc: "ripoffline".}
proc curs_set*(visibility: cint): cint {.ncurses_default, importc: "curs_set".}
proc napms*(ms: cint): cint {.ncurses_default, importc: "napms".}
    ## Used to sleep for the specified milliseconds.
    ## @Params: 'milliseconds' the number of milliseconds to sleep for.
    ## @Returns: ERR on failure and OK upon successful completion.

#extend: misc extensions
proc curses_version*(): cstring {.ncurses_default, importc: "curses_version".}
proc use_extended_names*(enable: bool): cint {.ncurses_default, importc: "use_extended_names".}

#define_key: define a keycode
proc define_key*(definition: cstring, keycode: cint): ErrCode {.ncurses_default, importc: "define_key".}

#terminfo: interfaces to terminfo database
#[
type
  TermType {..} = object
    term_names, str_table: cstring
    booleans: ptr bool
    numbers: ptr cint
    strings: cstringArray
    term_names_table: cstring
    ext_Names: cstringArray
    num_Booleans, num_Numbers, num_Strings: cushort
    ext_Booleans, ext_Numbers, ext_Strings: cushort
  TermType2 = TermType
  Terminal {.ncurses_default, importc: "struct TERMINAL".} = object
    `type`: TERMTYPE
    filedes: cshort #yeaaaaah don't feel like adding terminfo
  #if interested:
  #https://invisible-island.net/ncurses/man/curs_terminfo.3x.html
  #look in /usr/include/term.h
]#

#util: misc utility routines
proc unctrl*(c: chtype): cstring {.ncurses_default, importc: "unctrl".}
proc wunctrl*(c: ptr cchar_t): WideCString {.ncurses_default, importc: "wunctrl".}
proc keyname*(c: cint): cstring {.ncurses_default, importc: "keyname".}
proc keyname_wch*(w: WideCString): cstring {.ncurses_default, importc: "key_name".} ## previously key_name, had to be renamed.
proc filter*(): void {.ncurses_default, importc: "filter".}
proc nofilter*(): void {.ncurses_default, importc: "nofilter".}
proc use_env*(f: bool): void {.ncurses_default, importc: "use_env".}
proc use_tioctl*(f: bool): void {.ncurses_default, importc: "use_tioctl".}
proc putwin*(win: PWindow, filep: File): ErrCode {.ncurses_default, importc: "putwin".}
proc getwin*(filep: File): PWindow {.ncurses_default, importc: "getwin".}
proc delay_output*(ms: cint): ErrCode {.ncurses_default, importc: "delay_output".}
proc flushinp*(): cint {.ncurses_default, importc: "flushinp".}

#delch: delete character under the cursor in a window
proc delch*(): cint {.ncurses_default, importc: "delch".}
  ## Delete the character under the cursor in the stdscr.
  ## @Returns: ERR on failure and OK upon successfully flashing.
proc wdelch*(win: PWindow): ErrCode {.ncurses_default, importc: "wdelch".}
proc mvdelch*(y,x: cint): ErrCode {.ncurses_default, importc: "mvdelch".}
proc mvwdelch*(win: PWindow, y,x: cint): ErrCode {.ncurses_default, importc: "mvwdelch".}

#deleteln: delete and insert lines in a window
proc deleteln*(): cint {.ncurses_default, importc: "deleteln".}
  ## Deletes the line under the cursor in the stdscr. All lines below the current line are moved up one line.
  ## The bottom line of the window is cleared and the cursor position does not change.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wdeleteln*(win: PWindow): ErrCode {.ncurses_default, importc: "wdeleteln".}
proc insdeln*(): ErrCode {.ncurses_default, importc: "insdeln".}
proc winsdeln*(win: PWindow, n: int): ErrCode {.ncurses_default, importc: "winsdeln".}
proc insertln*(): cint {.ncurses_default, importc: "insertln".}
  ## Inserts a blank line above the current line in stdscr and the bottom line is lost.
  ## @Returns: ERR on failure and OK upon successful completion.
proc winsertln*(win: PWindow): ErrCode {.ncurses_default, importc: "winsertln".}

#iniscr: screen initialization and manipulation routines
proc initscr*(): PWindow {.ncurses_default, importc: "initscr".}
  ## Usually the first curses routine to be called when initialising a program
  ## The initscr code determines the terminal type and initialises  all curses data structures.  initscr also causes the
  ## first call to refresh to clear the screen.
  ## @Returns: A pointer to stdscr is returned if the operation is successful.
  ## @Note: If errors occur, initscr writes an appropriate error message to
  ## standard error and exits.
proc endwin*(): ErrCode {.ncurses_default, importc: "endwin".}
  ## A program should always call endwin before exiting or escaping from curses mode temporarily. This routine
  ## restores tty modes, moves the cursor to the lower left-hand corner of the screen and resets the terminal into the
  ## proper non-visual mode. Calling refresh or doupdate after a temporary escape causes the program to resume visual mode.
  ## @Returns: ERR on failure and OK upon successful completion.
proc isendwin*(): bool {.ncurses_default, importc: "isendwin".}
proc newterm*(`type`: cstring, outfd, infd: File): ptr Screen {.ncurses_default, importc: "newterm".}
proc set_term*(`new`: ptr Screen): ptr Screen {.ncurses_default, importc: "set_term".}
proc delscreen*(sp: ptr Screen): void {.ncurses_default, importc: "delscreen".}

#window: create a window
proc newwin*(nlines, ncols, begin_y, begin_x: cint): PWindow {.ncurses_default, importc: "newwin".}
proc delwin*(win: PWindow): ErrCode {.ncurses_default, importc: "delwin".}
proc mvwin*(win: PWindow, y,x: cint): ErrCode {.ncurses_default, importc: "mvwin".}
proc subwin*(orig: PWindow, nlines, ncols, begin_y, begin_x: cint): PWindow {.ncurses_default, importc: "subwin".}
proc derwin*(orig: PWindow, nlines, ncols, begin_y, begin_x: cint): PWindow {.ncurses_default, importc: "derwin".}
proc mvderwin*(win: PWindow, par_y, par_x: cint): ErrCode {.ncurses_default, importc: "mvderwin".}
proc dupwin*(win: PWindow): PWindow {.ncurses_default, importc: "dupwin".}
proc wsyncup*(win: PWindow): void {.ncurses_default, importc: "wsyncup".}
proc syncok*(win: PWindow, bf: bool): ErrCode {.ncurses_default, importc: "syncok".}
proc wcursyncup*(win: PWindow): void {.ncurses_default, importc: "wcursynup".}
proc wsyncdown*(win: PWindow): void {.ncurses_default, importc: "wsyncdown".}

#refresh: refresh windows and lines
proc refresh*(): cint {.ncurses_default, importc: "refresh".}
  ## Must be called to get actual output to the terminal. refresh uses stdscr has the default window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wrefresh*(win: PWindow): cint {.ncurses_default, importc: "wrefresh".}
proc wnoutrefresh*(win: PWindow): ErrCode {.ncurses_default, importc: "wnoutrefresh".}
proc doupdate*(): ErrCode {.ncurses_default, importc: "doupdate".}
proc redrawwin*(win: PWindow): ErrCode {.ncurses_default, importc: "redrawwin".}
proc wredrawln*(win: PWindow, beg_lines, num_lines: cint): ErrCode {.ncurses_default, importc: "wredrawln".}

#slk: soft label routines
proc slk_init*(fmt: cint): ErrCode {.ncurses_default, importc: "slk_init".}
proc slk_set*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.ncurses_default, importc: "slk_set".}
proc slk_wset*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.ncurses_default, importc: "slk_wset".}
proc slk_label*(labnum: cint): cstring {.ncurses_default, importc: "slk_label".}
proc slk_refresh*(): ErrCode {.ncurses_default, importc: "slk_refresh".}
proc slk_noutrefresh*(): ErrCode {.ncurses_default, importc: "slk_noutrefresh".}
proc slk_clear*(): ErrCode {.ncurses_default, importc: "slk_clear".}
proc slk_restore*(): ErrCode {.ncurses_default, importc: "slk_restore".}
proc slk_touch*(): ErrCode {.ncurses_default, importc: "slk_touch".}
proc slk_attron_ch*(attrs: chtype): ErrCode {.ncurses_default, importc: "slk_attron".}
proc slk_attroff_ch*(attrs: chtype): ErrCode {.ncurses_default, importc: "slk_attroff".}
proc slk_attrset_ch*(attrs: chtype): ErrCode {.ncurses_default, importc: "slk_attrset".}
proc slk_attr_on*(attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "slk_attr_on".}
proc slk_attr_off*(attrs: attr_t, opts: pointer): ErrCode {.ncurses_default, importc: "slk_attr_off".}
proc slk_attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "slk_attr_set".}
proc slk_attr*(): attr_t {.ncurses_default, importc: "slk_attr".}
proc slk_color*(pair: cshort): ErrCode {.ncurses_default, importc: "slk_color".}
proc extended_slk_color*(pair: cint): ErrCode {.ncurses_default, importc: "extended_slk_color".}

#get_wch: get (or push back) a wide character from a terminal keyboard
proc get_wch*(wch: WideCString): ErrCode {.ncurses_default, importc: "get_wch".}
proc wget_wch*(win: PWindow, wch: WideCString): ErrCode {.ncurses_default, importc: "wget_wsch".}
proc mvget_wch*(y,x: cint, wch: WideCString): ErrCode {.ncurses_default, importc: "mvget_wch".}
proc mvwget_wch*(win: PWindow, y,x: cint, wch: WideCString): ErrCode {.ncurses_default, importc: "mvwget_wch".}
proc unget_wch*(wch: WideCString): ErrCode {.ncurses_default, importc: "unget_wch".}

#get_wstr: get an array of wide characters from a terminal keyboard
proc get_wstr*(wstr: WideCString): ErrCode {.ncurses_default, importc: "get_wstr".}
proc getn_wstr*(wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "getn_wstr".}
proc wget_wstr*(win: PWindow, wstr: WideCString): ErrCode {.ncurses_default, importc: "wget_wsch".}
proc wgetn_wstr*(win: PWindow, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "wgetn_wsch".}
proc mvget_wstr*(y,x: cint, wstr: WideCString): ErrCode {.ncurses_default, importc: "mvget_wstr".}
proc mvgetn_wstr*(y,x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "mvgetn_wstr".}
proc mvwget_wstr*(win: PWindow, y,x: cint, wstr: WideCString): ErrCode {.ncurses_default, importc: "mvwget_wstr".}
proc mvwgetn_wstr*(win: PWindow, y,x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses_default, importc: "mvwgetn_wstr".}

#legacy: get cursor and window coordinates, attributes
proc getattrs*(win: PWindow): cint {.ncurses_default, importc: "getattrs".}
proc getbegx*(win: PWindow): cint {.ncurses_default, importc: "getbegx".}
proc getbegy*(win: PWindow): cint {.ncurses_default, importc: "getbegy".}
proc getcurx*(win: PWindow): cint {.ncurses_default, importc: "getcurx".}
proc getcury*(win: PWindow): cint {.ncurses_default, importc: "getcury".}
proc getmaxx*(win: PWindow): cint {.ncurses_default, importc: "getmaxx".}
proc getmaxy*(win: PWindow): cint {.ncurses_default, importc: "getmaxy".}
proc getparx*(win: PWindow): cint {.ncurses_default, importc: "getparx".}
proc getpary*(win: PWindow): cint {.ncurses_default, importc: "getpary".}

#getyx: get curses cursor and window coordinates (these are implemented as macros in ncurses.h)
template getyx*(win: PWindow, y, x: cint): untyped=
  ## Reads the logical cursor location from the specified window.
  ## @Param: 'win' the window to get the cursor location from.
  ## @Param: 'y' stores the height of the window.
  ## @Param: 'x' stores the width of the window.
  (y = getcury(win); x = getcurx(win)) ## testing
template getbegyx*(win: PWindow, y, x: cint): untyped=
  (y = getbegy(win); x = getbegx(win))
template getmaxyx*(win: PWindow, y, x: cint): untyped=
  ## retrieves the size of the specified window in the provided y and x parameters.
  ## @Param: 'win' the window to measure.
  ## @Param: 'y' stores the height of the window.
  ## @Param: 'x' stores the width of the window.
  (y = getmaxy(win); x = getmaxx(win))
template getparyx*(win: PWindow, y, x: cint): untyped=
  (y = getpary(win); x = getparx(win))

#getcchar: Get a wide character string and rendition from cchar_t or set a cchar_t from a wide-character string
proc getcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: ptr attr_t, color_pair: ptr cshort, opts: pointer): ErrCode {.ncurses_default, importc: "getcchar".}
proc setcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: attr_t, color_pair: cshort, opts: pointer): ErrCode {.ncurses_default, importc: "setcchar".}

#getch: get (or push back) characters from the terminal keyboard
proc getch*(): ErrCode {.ncurses_default, importc: "getch".}
  ## Read a character from the stdscr window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetch*(win: PWindow): ErrCode {.ncurses_default, importc: "wgetch".}
  ## Read a character from the specified window.
  ## @Param: 'sourceWindow' the window to read a character from.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvgetch*(y,x: cint): ErrCode {.ncurses_default, importc: "mvgetch".}
proc mvwgetch*(win: PWindow, y,x: cint): ErrCode {.ncurses_default, importc: "mvwgetch".}
proc ungetch*(ch: cint): ErrCode {.ncurses_default, importc: "ungetch".}
proc has_key*(ch: cint): ErrCode {.ncurses_default, importc: "has_key".}

#mouse: mouse interface
proc has_mouse*(): bool {.ncurses_default, importc: "has_mouse".}
proc getmouse*(event: ptr Mevent): ErrCode {.ncurses_default, importc: "getmouse".}
proc ungetmouse*(event: ptr Mevent): ErrCode {.ncurses_default, importc: "ungetmouse".}
proc mousemask*(newmask: mmask_t, oldmask: ptr mmask_t): mmask_t {.ncurses_default, importc: "mousemask".}
proc wenclose*(win: PWindow, y, x: cint): bool {.ncurses_default, importc: "wenclose".}
proc mouse_trafo*(y,x: ptr cint, to_screen: bool): bool {.ncurses_default, importc: "mouse_trafo".}
proc wmouse_trafo*(win: PWindow, y,x: ptr cint, to_screen: bool): bool {.ncurses_default, importc: "wmouse_trafo".}
proc mouseinterval*(erval: cint): ErrCode {.ncurses_default, importc: "mouseinterval".}

#getstr: accept character strings from terminal keyboard
proc getstr*(str: cstring): ErrCode {.ncurses_default, importc: "getstr".}
  ## Reads the inputted characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Returns: ERR on failure and OK upon successful completion.
proc getnstr*(str: cstring; n: cint): ErrCode {.ncurses_default, importc: "getnstr".}
  ## Reads at most the specified number of characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Param: 'numberOfCharacters' the maximum number of characters to read.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetstr*(win: PWindow, str: cstring): ErrCode {.ncurses_default, importc: "wgetstr".}
proc wgetnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "wgetnstr".}
proc mvgetstr*(y,x: cint, str: cstring): ErrCode {.ncurses_default, importc: "mvgetstr".}
proc mvgetnstr*(y,x: cint, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "mvgetnstr".}
proc mvwgetstr*(win: PWindow, y,x: cint, str: cstring): ErrCode {.ncurses_default, importc: "mvwgetstr".}
proc mvwgetnstr*(win: PWindow, y,x: cint, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "mvwgetnstr".}

#in_wch: extract a complex character and rendition from a window
proc in_wch*(wcval: ptr cchar_t): ErrCode {.ncurses_default, importc: "in_wch".}
proc mvinwch*(y,x: cint, wcval: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvin_wch".}
proc mvwin_wch*(win: PWindow, y,x: cint, wcval: ptr cchar_t): ErrCode {.ncurses_default, importc: "mcwin_wch".}
proc win_wch*(win: PWindow, wcval: ptr cchar_t): ErrCode {.ncurses_default, importc: "win_wch".}

#in_wchstr: get an array of complex characters and renditions from a window
proc in_wchstr*(wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "in_wchstr".}
proc in_wchnstr*(wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "in_wchnstr".}
proc win_wchstr*(win: PWindow, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "win_wchstr".}
proc win_wchnstr*(win: PWindow, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "win_wchnstr".}
proc mvin_wchstr*(y,x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvin_wchstr".}
proc mvin_wchnstr*(y,x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvin_wchnstr".}
proc mvwin_wchstr*(win: PWindow, y,x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvwin_wchstr".}
proc mvwin_wchnstr*(win: PWindow; y,x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses_default, importc: "mvwin_wchnstr".}

#inch: get a character and attributes from a window
proc inch*(): chtype {.ncurses_default, importc: "inch".}
proc winch*(win: PWindow): chtype {.ncurses_default, importc: "winch".}
proc mvinch*(y,x: cint): chtype {.ncurses_default, importc: "mvinch".}
proc mvwinch*(win: PWindow; y,x: cint): chtype {.ncurses_default, importc: "mvwinch".}

#inchstr: get a string of characters (and attributes) from a window
proc inchstr*(chstr: ptr chtype): ErrCode {.ncurses_default, importc: "inchstr".}
proc inchnstr*(chstr: ptr chtype; n: cint): ErrCode {.ncurses_default, importc: "inchnstr".}
proc winchstr*(win: PWindow; chstr: ptr chtype): ErrCode {.ncurses_default, importc: "winchstr".}
proc winchnstr*(win: PWindow; chstr: ptr chtype; n: cint): ErrCode {.ncurses_default, importc: "winchnstr".}
proc mvinchstr*(y,x: cint; chstr: ptr chtype): ErrCode {.ncurses_default, importc: "mvinchstr".}
proc mvinchnstr*(y,x: cint; chstr: ptr chtype; n: cint): ErrCode {.ncurses_default, importc: "mvinchnstr".}
proc mvwinchstr*(win: PWindow, y,x: cint; chstr: ptr chtype): ErrCode {.ncurses_default, importc: "mvwinchstr".}
proc mvwinchnstr*(win: PWindow, y,x: cint; chstr: ptr chtype; n: cint): ErrCode {.ncurses_default, importc: "mvwinchnstr".}

#instr: get a string of characters from a window
proc instr*(str: cstring): ErrCode {.ncurses_default, importc: "instr".}
proc innstr*(str: cstring, n: cint): ErrCode {.ncurses_default, importc: "innstr".}
proc winstr*(win: PWindow, str: cstring): ErrCode {.ncurses_default, importc: "winstr".}
proc winnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.ncurses_default, importc: "winnstr".}
proc mvinstr*(): ErrCode {.ncurses_default, importc: "mvinstr".}
proc mvinnstr*(): ErrCode {.ncurses_default, importc: "mvinnstr".}
proc mvwinstr*(): ErrCode {.ncurses_default, importc: "mvwinstr".}
proc mvwinnstr*(): ErrCode {.ncurses_default, importc: "mvwinnstr".}

#inwstr: get a string of wchar_t characters from a window
proc inwstr*(wstr: WideCString): ErrCode {.ncurses_default, importc: "inwstr".}
proc innwstr*(wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "innwstr".}
proc winwstr*(win: PWindow; wstr: WideCString): ErrCode {.ncurses_default, importc: "winwstr".}
proc winnwstr*(win: PWindow; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "winnwstr".}
proc mvinwstr*(y,x: cint; wstr: WideCString): ErrCode {.ncurses_default, importc: "mvinwstr".}
proc mvinnwstr*(y,x: cint; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "mvinnwstr".}
proc mvwinwstr*(win: PWindow; y,x: cint; wstr: WideCString): ErrCode {.ncurses_default, importc: "mvwinwstr".}
proc mvwinnwstr*(win: PWindow; y,x: cint; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "mvwinnwstr".}

#ins_wstr: insert a wide-character string into a window
proc ins_wstr*(wstr: WideCString): ErrCode {.ncurses_default, importc: "ins_wstr".}
proc ins_nwstr*(wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "ins_nwstr".}
proc wins_wstr*(win: PWindow; wstr: WideCString): ErrCode {.ncurses_default, importc: "wins_wstr".}
proc wins_nwstr*(win: PWindow; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "wins_nwstr".}
proc mvins_wstr*(y,x: cint; wstr: WideCString): ErrCode {.ncurses_default, importc: "mvins_wstr".}
proc mvins_nwstr*(y,x: cint; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "mvins_nwstr".}
proc mvwins_wstr*(win: PWindow; y,x: cint; wstr: WideCString): ErrCode {.ncurses_default, importc: "mvwins_wstr".}
proc mvwins_nwstr*(win: PWindow; y,x: cint; wstr: WideCString; n: cint): ErrCode {.ncurses_default, importc: "mvwins_nwstr".}

#ins_wch: insert a complex character and rendition into a window
proc ins_wch*(wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "ins_wch".}
proc wins_wch*(win: PWindow; wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "wins_wch".}
proc mvins_wch*(y,x: cint; wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvins_wch".}
proc mvwins_wch*(win: PWindow; y,x: cint; wch: ptr cchar_t): ErrCode {.ncurses_default, importc: "mvwins_wch".}

#insch: insert a character before cursor in a window
proc insch*(ch: chtype): ErrCode {.ncurses_default, importc: "insch".}
    ## Inserts a character before the cursor in the stdscr.
    ## @Param: 'character' the character to insert.
    ## @Returns: ERR on failure and OK upon successful completion.
proc winsch*(win: PWindow; ch: chtype): ErrCode {.ncurses_default, importc: "winsch".}
proc mvinsch*(y,x: cint; ch: chtype): ErrCode {.ncurses_default, importc: "mvinsch".}
proc mvwinsch*(win: PWindow; y,x: cint; ch: chtype): ErrCode {.ncurses_default, importc: "mvwinsch".}

#insstr: insert string before cursor in a window
proc insstr*(str: cstring): ErrCode {.ncurses_default, importc: "insstr".}
proc insnstr*(str: cstring; n: cint): ErrCode {.ncurses_default, importc: "insnstr".}
proc winsstr*(win: PWindow; str: cstring): ErrCode {.ncurses_default, importc: "winsstr".}
proc winsnstr*(win: PWindow; str: cstring; n: cint): ErrCode {.ncurses_default, importc: "winsnstr".}
proc mvinsstr*(y,x: cint; str: cstring): ErrCode {.ncurses_default, importc: "minsstr".}
proc mvinsnstr*(y,x: cint; str: cstring; n: cint): ErrCode {.ncurses_default, importc: "mvinsnstr".}
proc mvwinsstr*(win: Pwindow; y,x: cint; str: cstring): ErrCode {.ncurses_default, importc: "mvwinsstr".}
proc mvwinsnstr*(win: Pwindow; y,x: cint; str: cstring; n: cint): ErrCode {.ncurses_default, importc: "mvwinsnstr".}

#opaque: window properties
#https://invisible-island.net/ncurses/man/curs_opaque.3x.html
proc is_cleared*(win: PWindow): bool {.ncurses_default, importc: "is_cleared".}
  ## returns the value set in clearok
proc is_idcok*(win: PWindow): bool {.ncurses_default, importc: "is_idcok".}
  ## returns the value set in is_idcok
proc is_idlok*(win: PWindow): bool {.ncurses_default, importc: "is_idlok".}
  ## returns the value set in is_idlok
proc is_immedok*(win: PWindow): bool {.ncurses_default, importc: "is_immedok".}
  ## returns the value set in is_immedok
proc is_keypad*(win: PWindow): bool {.ncurses_default, importc: "is_keypad".}
  ## returns the value set in is_keypad
proc is_leaveok*(win: PWindow): bool {.ncurses_default, importc: "is_leaveok".}
  ## returns the value set in is_leaveok
proc is_nodelay*(win: PWindow): bool {.ncurses_default, importc: "is_nodelay".}
  ## returns the value set in is_nodelay
proc is_notimeout*(win: PWindow): bool {.ncurses_default, importc: "is_notimeout".}
  ## returns the value set in is_notimeout
proc is_pad*(win: PWindow): bool {.ncurses_default, importc: "is_pad".}
  ## returns TRUE if the window is a pad i.e., created by newpad
proc is_scrollok*(win: PWindow): bool {.ncurses_default, importc: "is_scrollok".}
  ## returns the value set in is_scrollok
proc is_subwin*(win: PWindow): bool {.ncurses_default, importc: "is_subwin".}
  ## returns TRUE if the window is a subwindow, i.e., created by subwin
  ## or derwin
proc is_syncok*(win: PWindow): bool {.ncurses_default, importc: "is_syncok".}
  ## returns the value set in is_syncok
proc wgetparent*(win: PWindow): PWindow {.ncurses_default, importc: "wgetparent".}
  ## returns the parent WINDOW pointer for subwindows, or NULL for
  ## windows with no parent
proc wgetdelay*(win: PWindow): cint {.ncurses_default, importc: "wgetdelay".}
  ## returns the delay timeout as set in wtimeout
proc wgetscrreg*(win: PWindow; top, bottom: cint): cint {.ncurses_default, importc: "wgetscrreg".}
  ## returns the top and bottom rows for the scrolling margin as set in
  ## wsetscrreg

#touch: refresh control routines
#https://invisible-island.net/ncurses/man/curs_touch.3x.html
proc touchwin*(win: PWindow): ErrCode {.ncurses_default, importc: "touchwin".}
  ## Throws away all optimization information about which parts of the window
  ## have been touched, by pretending that the entire window has been drawn on.
  ## This is sometimes necessary when using overlapping windows, since a change
  ## to one window affects the other window, but the records of which lines
  ## have been changed in the other window do not reflect the change.
proc touchline*(win: PWindow; start, count: cint): ErrCode {.ncurses_default, importc: "touchline".}
  ## The same as touchwin, except it only pretends that count lines have been
  ## changed, beginning with line start.
proc untouchwin*(win: PWindow): ErrCode {.ncurses_default, importc: "untouchwin".}
  ## Marks all lines in the window as unchanged since the last call to wrefresh.
proc wtouchln*(win: PWindow; y, n, changed: cint): ErrCode {.ncurses_default, importc: "wtouchln".}
  ## Makes n lines in the window, starting at line y, look as if they have
  ## (changed=1) or have not (changed=0) been changed since the last call to
  ## wrefresh.
proc is_wintouched*(win: PWindow): bool {.ncurses_default, importc: "is_wintouched".}
  ## Returns TRUE if the specified window was modified since the last call to
  ## wrefresh
proc is_linetouched*(win: PWindow; line: cint): bool {.ncurses_default, importc: "is_linetouched".}
  ## The same as is_wintouched, In addition, returns ERR if line is not valid
  ## for the given window.

#resizeterm: change the curses terminal size
#https://invisible-island.net/ncurses/man/resizeterm.3x.html
proc is_term_resized*(lines, columns: cint): bool {.ncurses_default, importc: "is_term_resized".}
  ## Checks if the resize_term function would modify the window structures.
  ## returns TRUE if the windows would be modified, and FALSE otherwise.
proc resize_term*(lines, columns: cint): ErrCode {.ncurses_default, importc: "resizeterm".}
  ## Resizes the standard and current windows to the specified dimensions,
  ## and adjusts other bookkeeping data used by the ncurses library that
  ## record the window dimensions such as the LINES and COLS variables.
proc resize_term_ext*(lines, columns: cint): ErrCode {.ncurses_default, importc: "resize_term".}
  ## Blank-fills the areas that are extended. The calling application should
  ## fill in these areas with appropriate data. The resize_term function
  ## attempts to resize all windows. However, due to the calling convention of
  ## pads, it is not possible to resize these without additional interaction
  ## with the application.

#key_defined: check if a keycode is defined
#https://invisible-island.net/ncurses/man/key_defined.3x.html
proc key_defined*(definition: cstring): cint {.ncurses_default, importc: "key_defined".}
  ## If the string is bound to a keycode, its value (greater than zero) is
  ## returned. If no keycode is bound, zero is returned. If the string
  ## conflicts with longer strings which are bound to keys, -1 is returned.

#keybound: return definition of keycode
#https://invisible-island.net/ncurses/man/keybound.3x.html
proc keybound*(keycode, count: cint): cstring {.ncurses_default, importc: "keybound".}
  ## The keycode parameter must be greater than zero, else NULL is returned.
  ## If it does not correspond to a defined key, then NULL is returned. The
  ## count parameter is used to allow the application to iterate through
  ## multiple definitions, counting from zero. When successful, the function
  ## returns a string which must be freed by the caller.

#keyok: enable or disable a keycode
#https://invisible-island.net/ncurses/man/keyok.3x.html
proc keyok(keycode: cint; enable: bool): ErrCode {.ncurses_default, importc: "keyok".}
  ## The keycode must be greater than zero, else ERR is returned. If it
  ## does not correspond to a defined key, then ERR is returned. If the
  ## enable parameter is true, then the key must have been disabled, and
  ## vice versa. Otherwise, the function returns OK.

#mcprint: ship binary data to printer
#https://invisible-island.net/ncurses/man/curs_print.3x.html
proc mcprint*(data: cstring; len: cint): ErrCode {.ncurses_default, importc: "mcprint".}

#move: move window cursor
#https://invisible-island.net/ncurses/man/curs_move.3x.html
proc move*(y, x: cint): ErrCode {.ncurses_default, importc: "move".}
  ## Moves the cursor of stdscr to the specified coordinates.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wmove*(win: PWindow; y,x: cint): ErrCode {.ncurses_default, importc: "wmove".}

#printw: print formatted output in windows
#https://invisible-island.net/ncurses/man/curs_printw.3x.html
proc printw*(fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "printw".}
  ## Prints out a formatted string to the stdscr.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wprintw*(win: PWindow, fmt: cstring): ErrCode {.ncurses_default, importc: "wprintw".}
proc mvprintw*(y, x: cint; fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "mvprintw".}
  ## Prints out a formatted string to the stdscr at the specified row and column.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvwprintw*(win: PWindow; y,x: cint; fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "mvwprintw".}
  ## Prints out a formatted string to the specified window at the specified row and column.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc vw_printw*(win: PWindow; fmt: cstring; varglist: varargs[cstring]): ErrCode {.ncurses_default, importc: "vw_printw"}

#scanw: convert formatted input from a window
#https://invisible-island.net/ncurses/man/curs_scanw.3x.html
proc scanw*(fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "scanw".}
  ## Converts formatted input from the stdscr.
  ## @Param: 'formattedInput' Contains the fields for the input to be mapped to.
  ## @Returns: The number of fields that were mapped in the call.
proc wscanw*(win: PWindow; fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "wscanw".}
proc mvscanw*(y,x: cint; fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "mvscanw".}
proc mvwscanw*(win: PWindow; y,x: cint; fmt: cstring): ErrCode {.ncurses_default, varargs, importc: "wscanw".}
proc vw_scanw*(win: PWindow; fmt: cstring; varglist: varargs[cstring]): ErrCode {.ncurses_default, varargs, importc: "vw_scanw".}

#pad: create and display pads
#https://invisible-island.net/ncurses/man/curs_pad.3x.html
proc newpad*(nlines, ncols: cint): PWindow {.ncurses_default, importc: "newpad".}
proc subpad*(orig: PWindow; lines, columns, begin_y, begin_x: cint): PWindow {.ncurses_default, importc: "subpad".}
proc prefresh*(pad: PWindow;
  pminrow, pmincol,
  sminrow, smincol,
  smaxrow, smaxcol: cint
): ErrCode {.ncurses_default, importc: "prefresh".}
proc pnoutrefersh*(pad: PWindow;
  pminrow, pmincol,
  sminrow, smincol,
  smaxrow, smaxcol: cint
): ErrCode {.ncurses_default, importc: "pnoutrefersh".}
proc pechochar*(pad: PWindow; ch: chtype): ErrCode {.ncurses_default, importc: "pechochar".}
proc pecho_wchar*(pad: PWindow; wch: WideCString): ErrCode {.ncurses_default, importc: "pecho_wchar".}

#scr_dump: read (write) a screen from (to) a file
#https://invisible-island.net/ncurses/man/curs_scr_dump.3x.html
proc scr_dump*(filename: cstring): ErrCode {.ncurses_default, importc: "scr_dump".}
proc scr_restore*(filename: cstring): ErrCode {.ncurses_default, importc: "scr_restore".}
proc scr_init*(filename: cstring): ErrCode {.ncurses_default, importc: "scr_init".}
proc scr_set*(filename: cstring): ErrCode {.ncurses_default, importc: "scr_set".}

#scroll: scroll a window
#https://invisible-island.net/ncurses/man/curs_scroll.3x.html
proc scroll*(win: PWindow): ErrCode {.ncurses_default, importc: "scroll".}
proc scrl*(n: cint): ErrCode {.ncurses_default, importc: "scrl".}
proc wscrl*(win: PWindow; n: cint): ErrCode {.ncurses_default, importc: "".}

#termcap: direct interface to the terminfo capability database
#https://invisible-island.net/ncurses/man/curs_termcap.3x.html
var
  PC {.ncurses_default, importc: "char PC".}: cchar
  UP {.ncurses_default, importc: "char * UP".}: cstring
  BC {.ncurses_default, importc: "char * BC".}: cstring
  ospeed {.ncurses_default, importc: "short ospeed".}: cshort
proc tgetent*(np, name: cstring): cint {.ncurses_default, importc: "tgetent".}
proc tgetflag*(id: cstring): ErrCode {.ncurses_default, importc: "tgetflag".}
proc tgetnum*(id: cstring): ErrCode {.ncurses_default, importc: "tgetnum".}
proc tgetstr*(id: cstring; area: cstringArray ): cstring {.ncurses_default, importc: "tgetstr".}
proc tgoto*(cap: cstring; col, row: cint): cstring {.ncurses_default, importc: "tgoto".}
proc tputs*(str: cstring; affcnt: cint; putc: ptr proc(ch: cint): cint): ErrCode {.ncurses_default, importc: "tputs".}

#legacy_coding: override locale-encoding checks
#https://invisible-island.net/ncurses/man/legacy_coding.3x.html
proc use_legacy_coding*(level: cint): cint {.ncurses_default, importc: "use_legacy_coding".}
  ## If  the  screen has not been initialized, or the level parameter is out
  ## of range, the function returns ERR. Otherwise, it returns the previous
  ## level: 0, 1 or 2.

#wresize: resize a curses window
#https://invisible-island.net/ncurses/man/wresize.3x.html
proc wresize*(win: PWindow; line, column: int): ErrCode {.ncurses_default, importc: "wresize".}

# mouse interface
template NCURSES_MOUSE_MASK(b, m: untyped): untyped = ((m) shl (((b) - 1) * 5))
template BUTTON_RELEASE*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_BUTTON_RELEASED))
template BUTTON_PRESS*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_BUTTON_PRESSED))
template BUTTON_CLICK*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_BUTTON_CLICKED))
template BUTTON_DOUBLE_CLICK*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_DOUBLE_CLICKED))
template BUTTON_TRIPLE_CLICK*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_TRIPLE_CLICKED))
template BUTTON_RESERVED_EVENT*(e, x: untyped): untyped =
 ((e) and NCURSES_MOUSE_MASK(x, NCURSES_RESERVED_EVENT))

const
  NCURSES_BUTTON_RELEASED* = 0o01'i32
  NCURSES_BUTTON_PRESSED*  = 0o02'i32
  NCURSES_BUTTON_CLICKED*  = 0o04'i32
  NCURSES_DOUBLE_CLICKED*  = 0o10'i32
  NCURSES_TRIPLE_CLICKED*  = 0o20'i32
  NCURSES_RESERVED_EVENT*  = 0o40'i32

  # event masks
  BUTTON1_RELEASED* = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_RELEASED)
  BUTTON1_PRESSED*  = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_PRESSED)
  BUTTON1_CLICKED*  = NCURSES_MOUSE_MASK(1, NCURSES_BUTTON_CLICKED)
  BUTTON1_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(1, NCURSES_DOUBLE_CLICKED)
  BUTTON1_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(1, NCURSES_TRIPLE_CLICKED)
  BUTTON2_RELEASED* = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_RELEASED)
  BUTTON2_PRESSED*  = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_PRESSED)
  BUTTON2_CLICKED*  = NCURSES_MOUSE_MASK(2, NCURSES_BUTTON_CLICKED)
  BUTTON2_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(2, NCURSES_DOUBLE_CLICKED)
  BUTTON2_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(2, NCURSES_TRIPLE_CLICKED)
  BUTTON3_RELEASED* = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_RELEASED)
  BUTTON3_PRESSED*  = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_PRESSED)
  BUTTON3_CLICKED*  = NCURSES_MOUSE_MASK(3, NCURSES_BUTTON_CLICKED)
  BUTTON3_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(3, NCURSES_DOUBLE_CLICKED)
  BUTTON3_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(3, NCURSES_TRIPLE_CLICKED)
  BUTTON4_RELEASED* = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_RELEASED)
  BUTTON4_PRESSED*  = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_PRESSED)
  BUTTON4_CLICKED*  = NCURSES_MOUSE_MASK(4, NCURSES_BUTTON_CLICKED)
  BUTTON4_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(4, NCURSES_DOUBLE_CLICKED)
  BUTTON4_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(4, NCURSES_TRIPLE_CLICKED)
  BUTTON5_RELEASED* = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_RELEASED)
  BUTTON5_PRESSED*  = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_PRESSED)
  BUTTON5_CLICKED*  = NCURSES_MOUSE_MASK(5, NCURSES_BUTTON_CLICKED)
  BUTTON5_DOUBLE_CLICKED* = NCURSES_MOUSE_MASK(5, NCURSES_DOUBLE_CLICKED)
  BUTTON5_TRIPLE_CLICKED* = NCURSES_MOUSE_MASK(5, NCURSES_TRIPLE_CLICKED)
  BUTTON_CTRL*  = NCURSES_MOUSE_MASK(6, 1)
  BUTTON_SHIFT* = NCURSES_MOUSE_MASK(6, 2)
  BUTTON_ALT*   = NCURSES_MOUSE_MASK(6, 4)
  
  # keys
  KEY_CODE_YES*  = 0o400           # A wchar_t contains a key code
  KEY_MIN*       = 0o401           # Minimum curses key
  KEY_BREAK*     = 0o401           # Break key (unreliable)
  KEY_SRESET*    = 0o530           # Soft (partial) reset (unreliable)
  KEY_RESET*     = 0o531           # Reset or hard reset (unreliable)

  KEY_DOWN*      = 0o402           # down-arrow key
  KEY_UP*        = 0o403           # up-arrow key
  KEY_LEFT*      = 0o404           # left-arrow key
  KEY_RIGHT*     = 0o405           # right-arrow key
  KEY_HOME*      = 0o406           # home key
  KEY_BACKSPACE* = 0o407           # backspace key
  KEY_F0*        = 0o410           # Function keys.  Space for 64
  KEY_DL*        = 0o510           # delete-line key
  KEY_IL*        = 0o511           # insert-line key
  KEY_DC*        = 0o512           # delete-character key
  KEY_IC*        = 0o513           # insert-character key
  KEY_EIC*       = 0o514           # sent by rmir or smir in insert mode
  KEY_CLEAR*     = 0o515           # clear-screen or erase key
  KEY_EOS*       = 0o516           # clear-to-end-of-screen key
  KEY_EOL*       = 0o517           # clear-to-end-of-line key
  KEY_SF*        = 0o520           # scroll-forward key
  KEY_SR*        = 0o521           # scroll-backward key
  KEY_NPAGE*     = 0o522           # next-page key
  KEY_PPAGE*     = 0o523           # previous-page key
  KEY_STAB*      = 0o524           # set-tab key
  KEY_CTAB*      = 0o525           # clear-tab key
  KEY_CATAB*     = 0o526           # clear-all-tabs key
  KEY_ENTER*     = 0o527           # enter/send key
  KEY_PRINT*     = 0o532           # print key
  KEY_LL*        = 0o533           # lower-left key (home down)
  KEY_A1*        = 0o534           # upper left of keypad
  KEY_A3*        = 0o535           # upper right of keypad
  KEY_B2*        = 0o536           # center of keypad
  KEY_C1*        = 0o537           # lower left of keypad
  KEY_C3*        = 0o540           # lower right of keypad
  KEY_BTAB*      = 0o541           # back-tab key
  KEY_BEG*       = 0o542           # begin key
  KEY_CANCEL*    = 0o543           # cancel key
  KEY_CLOSE*     = 0o544           # close key
  KEY_COMMAND*   = 0o545           # command key
  KEY_COPY*      = 0o546           # copy key
  KEY_CREATE*    = 0o547           # create key
  KEY_END*       = 0o550           # end key
  KEY_EXIT*      = 0o551           # exit key
  KEY_FIND*      = 0o552           # find key
  KEY_HELP*      = 0o553           # help key
  KEY_MARK*      = 0o554           # mark key
  KEY_MESSAGE*   = 0o555           # message key
  KEY_MOVE*      = 0o556           # move key
  KEY_NEXT*      = 0o557           # next key
  KEY_OPEN*      = 0o560           # open key
  KEY_OPTIONS*   = 0o561           # options key
  KEY_PREVIOUS*  = 0o562           # previous key
  KEY_REDO*      = 0o563           # redo key
  KEY_REFERENCE* = 0o564           # reference key
  KEY_REFRESH*   = 0o565           # refresh key
  KEY_REPLACE*   = 0o566           # replace key
  KEY_RESTART*   = 0o567           # restart key
  KEY_RESUME*    = 0o570           # resume key
  KEY_SAVE*      = 0o571           # save key
  KEY_SBEG*      = 0o572           # shifted begin key
  KEY_SCANCEL*   = 0o573           # shifted cancel key
  KEY_SCOMMAND*  = 0o574           # shifted command key
  KEY_SCOPY*     = 0o575           # shifted copy key
  KEY_SCREATE*   = 0o576           # shifted create key
  KEY_SDC*       = 0o577           # shifted delete-character key
  KEY_SDL*       = 0o600           # shifted delete-line key
  KEY_SELECT*    = 0o601           # select key
  KEY_SEND*      = 0o602           # shifted end key
  KEY_SEOL*      = 0o603           # shifted clear-to-end-of-line key
  KEY_SEXIT*     = 0o604           # shifted exit key
  KEY_SFIND*     = 0o605           # shifted find key
  KEY_SHELP*     = 0o606           # shifted help key
  KEY_SHOME*     = 0o607           # shifted home key
  KEY_SIC*       = 0o610           # shifted insert-character key
  KEY_SLEFT*     = 0o611           # shifted left-arrow key
  KEY_SMESSAGE*  = 0o612           # shifted message key
  KEY_SMOVE*     = 0o613           # shifted move key
  KEY_SNEXT*     = 0o614           # shifted next key
  KEY_SOPTIONS*  = 0o615           # shifted options key
  KEY_SPREVIOUS* = 0o616           # shifted previous key
  KEY_SPRINT*    = 0o617           # shifted print key
  KEY_SREDO*     = 0o620           # shifted redo key
  KEY_SREPLACE*  = 0o621           # shifted replace key
  KEY_SRIGHT*    = 0o622           # shifted right-arrow key
  KEY_SRSUME*    = 0o623           # shifted resume key
  KEY_SSAVE*     = 0o624           # shifted save key
  KEY_SSUSPEND*  = 0o625           # shifted suspend key
  KEY_SUNDO*     = 0o626           # shifted undo key
  KEY_SUSPEND*   = 0o627           # suspend key
  KEY_UNDO*      = 0o630           # undo key
  KEY_MOUSE*     = 0o631           # Mouse event has occurred
  KEY_RESIZE*    = 0o632           # Terminal resize event
  KEY_EVENT*     = 0o633           # We were interrupted by an event

template KEY_F*(n: untyped): untyped= (KEY_F0+(n)) ## Value of function key n
