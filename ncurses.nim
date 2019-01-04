{.deadCodeElim: on.}
from sugar import `->`
when defined(windows):
 const libncurses* = "libncurses.dll"
elif defined(macosx):
 const libncurses* = "libncurses.dylib"
else:
 const libncurses* = "libncursesw.so"
{.pragma: ncurses, discardable, cdecl, dynlib: libncurses.}

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
  Screen* = object
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
    parent*: ptr Window       # pointer to parent if a sub-window
    
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

var COLORS* {.importc: "COLORS", dynlib: libncurses.}: int
var COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: int
const  # colors
  COLOR_BLACK*   = 0
  COLOR_RED*     = 1
  COLOR_GREEN*   = 2
  COLOR_YELLOW*  = 3
  COLOR_BLUE*    = 4
  COLOR_MAGENTA* = 5
  COLOR_CYAN*    = 6
  COLOR_WHITE*   = 7
const
  ERR* = (-1)
  OK*  = (0)

type ErrCode = cint ## Returns ERR upon failure or OK on success.

template NCURSES_CAST(`type`, value: untyped): untyped = (`type`)(value)
template COLOR_PAIR*(n: untyped): untyped =
 NCURSES_BITS((n), 0'i64)
template PAIR_NUMBER*(a: untyped): untyped =
 (NCURSES_CAST(int, ((NCURSES_CAST(uint64, (a)) and A_COLOR) shr
     NCURSES_ATTR_SHIFT)))

#add_wchs: Adding complex characters to a window
proc add_wch*(wch: ptr cchar_t): ErrCode {.ncurses, importc: "add_wch".}
proc wadd_wch*(win: ptr Window, wch: ptr cchar_t): ErrCode {.ncurses, importc: "wadd_wch".}
proc mvadd_wch*(y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses, importc: "mvadd_wch".}
proc mvwadd_wch*(win: ptr Window, y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses, importc: "mvwadd_wch".}
proc echo_wchar*(wch: ptr cchar_t): ErrCode {.ncurses, importc: "echo_wchar".}
proc wech_wchar*(win: ptr Window, wch: ptr cchar_t): ErrCode {.ncurses, importc: "wech_wchar".}

#add_wchstr: Adding an array of complex characters to a window
proc add_wchstr*(wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "add_wchstr".}
proc add_wchnstr*(wchstr: ptr cchar_t, numberOfCharacters: cint): ErrCode {.ncurses, importc: "add_wchnstr".}
proc wadd_wchstr*(win: ptr Window, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "wadd_wchstr".}
proc wadd_wchnstr*(win: ptr Window, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "wadd_wchnstr".}
proc mvadd_wchstr*(y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "mvadd_wchstr".}
proc mvadd_wchnstr*(y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "mvadd_wchnstr".}
proc mvwadd_wchstr*(win: ptr Window, y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "mvwadd_wchstr".}
proc mvwadd_wchnstr*(win: ptr Window, y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwadd_wchnstr".}

#addch: Adding a character (with attributes) to a window
proc addch*(character: chtype): ErrCode {.ncurses, importc: "addch".}
  ## Puts a character into the stdscr at its current window position and then advances
  ## the current window position to the next position.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddch*(win: ptr Window, ch: chtype): ErrCode {.ncurses, importc: "waddch".}
proc mvaddch*(y, x: cint, ch: chtype): ErrCode {.ncurses, importc: "mvaddch".}
proc mvwaddch*(win: ptr Window, y, x: int, ch: chtype): ErrCode {.ncurses, importc: "mvwaddch".}
proc echochar*(ch: chtype): ErrCode {.ncurses, importc: "echochar".}
proc wechochar*(win: ptr Window, ch: chtype): ErrCode {.ncurses, importc: "wechochar".}

#addchstr: Adding a string of characters (and attributes) to a window
proc addchstr*(chstr: ptr chtype): ErrCode {.ncurses, importc: "addchstr".}
proc addchnstr*(chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "addchnstr".}
proc waddchstr*(win: ptr Window, chstr: ptr chtype): ErrCode {.ncurses, importc: "waddchstr".}
proc waddchnstr*(win: ptr Window, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "waddchnstr".}
proc mvaddchstr*(y, x: cint, chstr: ptr chtype): ErrCode {.ncurses, importc: "mvaddchstr".}
proc mvaddchnstr*(y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "mvaddchnstr".}
proc mvwaddchstr*(win: ptr Window, y, x: cint, chstr: ptr chtype): ErrCode {.ncurses, importc: "mvwaddchstr".}
proc mvwaddchnstr*(win: ptr Window, y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "mvwaddchnstr".}

#addstr: Adding a string of characters to a window (cstring)
proc addstr*(str: cstring): ErrCode {.ncurses, importc: "addstr".}
  ## Adds a string of characters the the stdscr and advances the cursor.
  ## @Param: The string to add the stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc addnstr*(str: cstring, n: cint): ErrCode {.ncurses, importc: "addnstr".}
proc waddstr*(win: ptr Window; str: cstring): ErrCode {.ncurses, importc: "waddstr".}
  ## Writes a string to the specified window.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'stringToWrite'
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddnstr*(win: ptr Window, str: cstring, n: cint): ErrCode {.ncurses, importc: "waddnstr".}
proc mvaddstr*(y, x: cint; str: cstring): ErrCode {.ncurses, importc: "mvaddstr".}
  ## Moves the cursor to the specified position and outputs the provided string.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'stringToOutput' the string to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvaddnstr*(y, x: cint, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvaddnstr".}
proc mvwaddstr*(win: ptr Window, y, x: int, str: cstring): ErrCode {.ncurses, importc: "mvwaddstr".}
proc mvwaddnstr*(win: ptr Window, y, x: int, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvwaddnstr".}

#addwstr: Adding a string of wide characters to a window (WideCString)
proc addwstr(wstr: WideCString): ErrCode {.ncurses, importc: "addwstr".}
proc addnwstr(wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "addnwstr".}
proc waddwstr(win: ptr Window, wstr: WideCString): ErrCode {.ncurses, importc: "waddwstr".}
proc waddnwstr(win: ptr Window, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "waddnwstr".}
proc mvaddwstr(y, x: cint, win: ptr Window, wstr: WideCString): ErrCode {.ncurses, importc: "mvaddwstr".}
proc mvaddnwstr(y, x: cint, win: ptr Window, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvaddnwstr".}
proc mvwaddwstr(win: ptr Window, y, x: cint, wstr: WideCString): ErrCode {.ncurses, importc: "mvwaddwstr".}
proc mvwaddnwstr(win: ptr Window, y, x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvwaddnwstr".}

#new_pair: Color-pair functions
proc alloc_pair*(fg, bg: cint): ErrCode {.ncurses, importc: "".}
proc find_pair*(fg, bg: cint): ErrCode {.ncurses, importc: "".}
proc free_pair*(pair: cint): ErrCode {.ncurses, importc: "".}

#default_colors: Use terminal's default colors
proc use_default_colors*(): ErrCode {.ncurses, importc: "use_default_colors".}
proc assume_default_colors*(fg, bg: cint): ErrCode {.ncurses, importc: "assume_default_colors".}

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

proc attr_get*(attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.ncurses, importc: "attr_get".}
proc wattr_get*(win: ptr Window, attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.ncurses, importc: "wattr_get".}
proc attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "attr_set".}
proc wattr_set*(win: ptr Window, attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wattr_set".}
proc attr_off*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "attr_off".}
proc wattr_off*(win: ptr Window, attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "wattr_off".}
proc attr_on*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "attr_on".}
proc wattr_on*(win: ptr Window, attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "wattr_on".}
proc attroff*(attrs: cint): ErrCode {.ncurses, importc: "attroff".}
  ## Turns off the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn off for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattroff*(win: ptr Window, attrs: cint): ErrCode {.ncurses, importc: "wattroff".}
proc attron*(attrs: cint): ErrCode {.ncurses, importc: "attron".}
  ## Turns on the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn on for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattron*(win: ptr Window, attrs: cint): ErrCode {.ncurses, importc: "wattron".}
proc attrset*(attrs: cint): ErrCode {.ncurses, importc: "attrset".}
  ## Sets the current attributes of the given window to the provided attributes.
  ## @Param: 'attributes', the attributes to apply to the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattrset*(win: ptr Window, attrs: cint): ErrCode {.ncurses, importc: "wattrset".}
proc chgat*(n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "chgat".}
proc wchgat*(win: ptr Window, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wchgat".}
proc mvchgat*(y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "mvchgat".}
proc mvwchgat*(win: ptr Window, y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "mvwchgat".}
proc color_set*(pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "color_set".}
proc wcolor_set*(win: ptr Window, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wcolor_set".}
proc standend(): ErrCode {.ncurses, importc: "standend".}
proc wstandend*(win: ptr Window): ErrCode {.ncurses, importc: "wstandend".}
proc standout*(): ErrCode {.ncurses, importc: "standout".}
proc wstandout*(win: ptr Window): ErrCode {.ncurses, importc: "wstandout".}

#termattrs: Enviroment query routines
proc baudrate*(): cint {.ncurses, importc: "baudrate".}
proc erasechar*() {.ncurses, importc: "erasechar".}
proc erasewchar*(ch: WideCString) {.ncurses, importc: "erasewchar".}
proc has_ic*(): bool {.ncurses, importc: "has_ic".}
proc has_il*(): bool {.ncurses, importc: "has_il".}
proc killchar*(): cchar {.ncurses, importc: "killchar".}
proc killwchar*(ch: WideCString): char {.ncurses, importc: "killwchar".}
proc longname*(): cstring {.ncurses, importc: "longname".}
proc term_attrs*(): attr_t {.ncurses, importc: "term_attrs".}
proc term_attrs_ch*(): chtype {.ncurses, importc: "termattrs".}
  ## in C this function appears as termattr, although because of
  ## Nim's style insensitivity this had to be changed.
proc termname*(): cstring {.ncurses, importc: "termname".}

#beep: Bell and screen flash routines
proc beep*(): ErrCode {.ncurses, importc: "beep".}
proc flash*(): ErrCode {.ncurses, importc: "flash".}
  ## Flashes the screen and if that is not possible it sounds the alert. If this is not possible
  ## nothing happens.
  ## @Returns: ERR on failure and OK upon successfully flashing.

#bkgd: Window background manipulation routines
proc bkgdset*(ch: chtype): void {.ncurses, importc: "bkgdset".}
proc wbkgdset*(win: ptr Window, ch: chtype): void {.ncurses, importc: "wbkgdset".}
proc bkgd*(ch: chtype): ErrCode {.ncurses, importc: "bkgd".}
  ## Sets the background property of the current window and apply this setting to every
  ## character position in the window.
  ## @Param: 'background' the background property to apply.
proc wbkgd*(win: ptr Window, ch: chtype): ErrCode {.ncurses, importc: "wbkgd".}
proc getbkgd*(win: ptr Window): chtype {.ncurses, importc: "getbkgd".}

#bkgrnd: Window complex background manipulation routines
proc bkgrnd*(wch: cchar_t): ErrCode {.ncurses, importc: "bkgrnd".}
proc wbkgrnd*(win: ptr Window, wch: cchar_t): ErrCode {.ncurses, importc: "wbkgrnd".}
proc bkgrndset*(wch: cchar_t): void {.ncurses, importc: "bkgrndset".}
proc wbkgrndset*(win: ptr Window, wch: cchar_t): void {.ncurses, importc: "getbkgrnd".}
proc getbkgrnd*(wch: cchar_t): ErrCode {.ncurses, importc: "getbkgrnd".}
proc wgetbkgrnd*(win: ptr Window, wch: cchar_t): ErrCode {.ncurses, importc: "wgetbkgrnd".}

#border: Create borders, horizontal and vertical lines
proc border*(ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses, importc: "border".}
proc wborder*(win: ptr Window, ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses, importc: "wborder".}
proc box*(win: ptr Window, verch, horch: chtype): ErrCode {.ncurses, importc: "box".}
proc hline*(ch: chtype, n: cint): ErrCode {.ncurses, importc: "hline".}
proc whline*(win: ptr Window, ch: chtype, n: cint): ErrCode {.ncurses, importc: "whline".}
proc vline*(ch: chtype, n: cint): ErrCode {.ncurses, importc: "vline".}
proc wvline*(win: ptr Window, ch: chtype, n: cint): ErrCode {.ncurses, importc: "wvline".}
proc mvhline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvhline".}
proc mvwhline*(win: ptr Window, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvwhline".}
proc mvvline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvvline".}
proc mvwvline*(win: ptr Window, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvwvline".}

#borderset: Create borders or lines using complex characters and renditions
proc border_set*(ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses, importc: "border_set".}
proc wborder_set*(win: ptr Window, ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses, importc: "wborder_set".}
proc box_set*(win: ptr Window, verch, horch: cchar_t): ErrCode {.ncurses, importc: "box_set".}
proc hline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "hline_set".}
proc whline_set*(win: ptr Window, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "whline_set".}
proc mvhline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvhline_set".}
proc mvwhline_set*(win: ptr Window, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwhline_set".}
proc vline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "vline_set".}
proc wvline_set*(win: ptr Window, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "wvline_set".}
proc mvvline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvvline_set".}
proc mvwvline_set*(win: ptr Window, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwvline_set".}

#inopts: Input options
proc cbreak*(): ErrCode {.ncurses, importc: "cbreak".}
  ## The cbreak routine disables line buffering and erase/kill character-processing
  ## (interrupt and flow control characters are unaffected), making characters typed by
  ## the user immediately available to the program.
  ## @Returns: ERR on failure and OK upon successful completion.
proc nocbreak*(): ErrCode {.ncurses, importc: "nocbreak".}
  ## Returns the terminal to normal (cooked mode).
  ## @Returns: ERR on failure and OK upon successful completion.
proc noecho*(): ErrCode {.ncurses, importc: "noecho".}
proc onecho*(): ErrCode {.ncurses, importc: "echo".}
  ## Previously `echo`, but this being a Nim's print function, is changed to `onecho`
proc halfdelay*(tenths: cint): ErrCode {.ncurses, importc: "halfdelay".}
proc keypad*(win: ptr Window, bf: bool): cint {.ncurses, importc: "keypad".}
proc meta*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "meta".}
proc nodelay*(win: ptr Window, bf: bool): cint {.ncurses, importc: "nodelay".}
proc raw*(): ErrCode {.ncurses, importc: "raw".}
proc noraw*(): ErrCode {.ncurses, importc: "noraw".}
proc noqiflush*(): void {.ncurses, importc: "noqiflush".}
proc qiflush*(): void {.ncurses, importc: "qiflush".}
proc notimeout*(): ErrCode {.ncurses, importc: "notimeout".}
proc timeout*(delay: cint): void {.ncurses, importc: "timeout".}
proc wtimeout*(win: ptr Window, delay: cint): void {.ncurses, importc: "wtimeout".}
proc typeahead*(fd: cint): ErrCode {.ncurses, importc: "typeahead".}

#clear: Clear all or part of a window
proc erase*(): ErrCode {.ncurses, importc: "erase".}
proc werase*(win: ptr Window): ErrCode {.ncurses, importc: "werase".}
proc clear*(): ErrCode {.ncurses, importc: "clear".}
proc wclear*(win: ptr Window): ErrCode {.ncurses, importc: "wclear".}
proc clrtobot*(): ErrCode {.ncurses, importc: "clrtobot".}
proc wclrtobot*(win: ptr Window): ErrCode {.ncurses, importc: "wclrtobot".}
proc clrtoeol*(): ErrCode {.ncurses, importc: "clrtoeol".}
proc wclrtoeol*(win: ptr Window): ErrCode {.ncurses, importc: "wclrtoeol".}

#outopts: Output options
proc clearok*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "clearok".}
proc idlok*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "idlok".}
proc idcok*(win: ptr Window, bf: bool): void {.ncurses, importc: "idcok".}
proc immedok*(win: ptr Window, bf: bool): void {.ncurses, importc: "immedok".}
proc leaveok*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "leaveok".}
proc setscrreg*(top, bot: cint): ErrCode {.ncurses, importc: "setscrreg".}
proc wsetscrreg*(win: ptr Window, top, bot: cint): ErrCode {.ncurses, importc: "wsetscrreg".}
proc scrollok*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "scrollok".}
proc nl*(): ErrCode {.ncurses, importc: "nl".}
proc nonl*(): ErrCode {.ncurses, importc: "nonl".}

#overlay: overlay and manipulate overlapped windows
proc overlay*(srcwin, dstwin: ptr Window): ErrCode {.ncurses, importc: "overlay".}
proc overwrite*(srcwin, dstwin: ptr Window): ErrCode {.ncurses, importc: "overwrite".}
proc copywin*(srcwin, dstwin: ptr Window,
  sminrow, smincol,
  dminrow, dmincol,
  dmaxrow, dmaxcol: cint
): ErrCode {.ncurses, importc: "copywin".}

#kernel: low-level routines (all except cur_set will always return OK)
proc def_prog_mode*(): ErrCode {.ncurses, importc: "def_prog_mode".}
proc def_shell_mode*(): ErrCode {.ncurses, importc: "def_shell_mode".}
proc reset_prog_mode*(): ErrCode {.ncurses, importc: "reset_prog_mode".}
proc reset_shell_mode*(): ErrCode {.ncurses, importc: "reset_shell_mode".}
proc resetty*(): ErrCode {.ncurses, importc: "resetty".}
proc savetty*(): ErrCode {.ncurses, importc: "savetty".}
proc getsyx*(y,x: cint): void {.ncurses, importc: "getsyx".}
proc setsyx*(y,x: cint): void {.ncurses, importc: "setsyx".}
proc ripoffline*(line: cint, init: proc(win: ptr Window, cols: cint): cint): ErrCode {.ncurses, importc: "ripoffline".}
proc curs_set*(visibility: cint): cint {.ncurses, importc: "curs_set".}
proc napms*(ms: cint): cint {.ncurses, importc: "napms".}
    ## Used to sleep for the specified milliseconds.
    ## @Params: 'milliseconds' the number of milliseconds to sleep for.
    ## @Returns: ERR on failure and OK upon successful completion.

#extend: misc extensions
proc curses_version*(): cstring {.ncurses, importc: "curses_version".}
proc use_extended_names*(enable: bool): cint {.ncurses, importc: "use_extended_names".}

#define_key: define a keycode
proc define_key*(definition: cstring, keycode: cint): ErrCode {.ncurses, importc: "define_key".}

#terminfo: interfaces to terminfo database
#[
type
  TERMTYPE = object
    term_names, str_table: cstring
    booleans: ptr bool
    numbers: ptr cint
    strings: cstringArray
    term_names_table: cstring
    ext_Names: cstringArray
    num_Booleans, num_Numbers, num_Strings: cushort
    ext_Booleans, ext_Numbers, ext_Strings: cushort
  TERMTYPE2 = TERMTYPE
  TERMINAL = object
    `type`: TERMTYPE
    filedes: cshort #yeaaaaah don't feel like adding terminfo ()
  #if interested:
  #https://invisible-island.net/ncurses/man/curs_terminfo.3x.html
  #look in /usr/include/term.h
]#

#util: misc utility routines
proc unctrl*(c: chtype): cstring {.ncurses, importc: "unctrl".}
proc wunctrl*(c: ptr cchar_t): WideCString {.ncurses, importc: "wunctrl".}
proc keyname*(c: cint): cstring {.ncurses, importc: "keyname".}
proc keyname_wch*(w: WideCString): cstring {.ncurses, importc: "key_name".} ## previously key_name, had to be renamed.
proc filter*(): void {.ncurses, importc: "filter".}
proc nofilter*(): void {.ncurses, importc: "nofilter".}
proc use_env*(f: bool): void {.ncurses, importc: "use_env".}
proc use_tioctl*(f: bool): void {.ncurses, importc: "use_tioctl".}
proc putwin*(win: ptr Window, filep: File): ErrCode {.ncurses, importc: "putwin".}
proc getwin*(filep: File): ptr Window {.ncurses, importc: "getwin".}
proc delay_output*(ms: cint): ErrCode {.ncurses, importc: "delay_output".}
proc flushinp*(): cint {.ncurses, importc: "flushinp".}

#delch: delete character under the cursor in a window
proc delch*(): cint {.ncurses, importc: "delch".}
  ## Delete the character under the cursor in the stdscr.
  ## @Returns: ERR on failure and OK upon successfully flashing.
proc wdelch*(win: ptr Window): ErrCode {.ncurses, importc: "wdelch".}
proc mvdelch*(y,x: cint): ErrCode {.ncurses, importc: "mvdelch".}
proc mvwdelch*(win: ptr Window, y,x: cint): ErrCode {.ncurses, importc: "mvwdelch".}

#deleteln: delete and insert lines in a window
proc deleteln*(): cint {.ncurses, importc: "deleteln".}
  ## Deletes the line under the cursor in the stdscr. All lines below the current line are moved up one line.
  ## The bottom line of the window is cleared and the cursor position does not change.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wdeleteln*(win: ptr Window): ErrCode {.ncurses, importc: "wdeleteln".}
proc insdeln*(): ErrCode {.ncurses, importc: "insdeln".}
proc winsdeln*(win: ptr Window, n: int): ErrCode {.ncurses, importc: "winsdeln".}
proc insertln*(): cint {.ncurses, importc: "insertln".}
  ## Inserts a blank line above the current line in stdscr and the bottom line is lost.
  ## @Returns: ERR on failure and OK upon successful completion.
proc winsertln*(win: ptr Window): ErrCode {.ncurses, importc: "winsertln".}

#iniscr: screen initialization and manipulation routines
proc initscr*(): ptr Window {.ncurses, importc: "initscr".}
  ## Usually the first curses routine to be called when initialising a program
  ## The initscr code determines the terminal type and initialises  all curses data structures.  initscr also causes the
  ## first call to refresh to clear the screen.
  ## @Returns: A pointer to stdscr is returned if the operation is successful.
  ## @Note: If errors occur, initscr writes an appropriate error message to
  ## standard error and exits.
proc endwin*(): ErrCode {.ncurses, importc: "endwin".}
  ## A program should always call endwin before exiting or escaping from curses mode temporarily. This routine
  ## restores tty modes, moves the cursor to the lower left-hand corner of the screen and resets the terminal into the
  ## proper non-visual mode. Calling refresh or doupdate after a temporary escape causes the program to resume visual mode.
  ## @Returns: ERR on failure and OK upon successful completion.
proc isendwin*(): bool {.ncurses, importc: "isendwin".}
proc newterm*(`type`: cstring, outfd, infd: File): ptr Screen {.ncurses, importc: "newterm".}
proc set_term*(`new`: ptr Screen): ptr Screen {.ncurses, importc: "set_term".}
proc delscreen*(sp: ptr Screen): void {.ncurses, importc: "delscreen".}

#window: create a window
proc newwin*(nlines, ncols, begin_y, begin_x: cint): ptr Window {.ncurses, importc: "newwin".}
proc delwin*(win: ptr Window): ErrCode {.ncurses, importc: "delwin".}
proc mvwin*(win: ptr Window, y,x: cint): ErrCode {.ncurses, importc: "mvwin".}
proc subwin*(orig: ptr Window, nlines, ncols, begin_y, begin_x: cint): ptr Window {.ncurses, importc: "subwin".}
proc derwin*(orig: ptr Window, nlines, ncols, begin_y, begin_x: cint): ptr Window {.ncurses, importc: "derwin".}
proc mvderwin*(win: ptr Window, par_y, par_x: cint): ErrCode {.ncurses, importc: "mvderwin".}
proc dupwin*(win: ptr Window): ptr Window {.ncurses, importc: "dupwin".}
proc wsyncup*(win: ptr Window): void {.ncurses, importc: "wsyncup".}
proc syncok*(win: ptr Window, bf: bool): ErrCode {.ncurses, importc: "syncok".}
proc wcursyncup*(win: ptr Window): void {.ncurses, importc: "wcursynup".}
proc wsyncdown*(win: ptr Window): void {.ncurses, importc: "wsyncdown".}

#refresh: refresh windows and lines
proc refresh*(): cint {.ncurses, importc: "refresh".}
  ## Must be called to get actual output to the terminal. refresh uses stdscr has the default window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wrefresh*(win: ptr Window): cint {.ncurses, importc: "wrefresh".}
proc wnoutrefresh*(win: ptr Window): ErrCode {.ncurses, importc: "wnoutrefresh".}
proc doupdate*(): ErrCode {.ncurses, importc: "doupdate".}
proc redrawwin*(win: ptr Window): ErrCode {.ncurses, importc: "redrawwin".}
proc wredrawln*(win: ptr Window, beg_lines, num_lines: cint): ErrCode {.ncurses, importc: "wredrawln".}

#slk: soft label routines
proc slk_init*(fmt: cint): ErrCode {.ncurses, importc: "slk_init".}
proc slk_set*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.ncurses, importc: "slk_set".}
proc slk_wset*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.ncurses, importc: "slk_wset".}
proc slk_label*(labnum: cint): cstring {.ncurses, importc: "slk_label".}
proc slk_refresh*(): ErrCode {.ncurses, importc: "slk_refresh".}
proc slk_noutrefresh*(): ErrCode {.ncurses, importc: "slk_noutrefresh".}
proc slk_clear*(): ErrCode {.ncurses, importc: "slk_clear".}
proc slk_restore*(): ErrCode {.ncurses, importc: "slk_restore".}
proc slk_touch*(): ErrCode {.ncurses, importc: "slk_touch".}
proc slk_attron_ch*(attrs: chtype): ErrCode {.ncurses, importc: "slk_attron".}
proc slk_attroff_ch*(attrs: chtype): ErrCode {.ncurses, importc: "slk_attroff".}
proc slk_attrset_ch*(attrs: chtype): ErrCode {.ncurses, importc: "slk_attrset".}
proc slk_attr_on*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "slk_attr_on".}
proc slk_attr_off*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "slk_attr_off".}
proc slk_attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "slk_attr_set".}
proc slk_attr*(): attr_t {.ncurses, importc: "slk_attr".}
proc slk_color*(pair: cshort): ErrCode {.ncurses, importc: "slk_color".}
proc extended_slk_color*(pair: cint): ErrCode {.ncurses, importc: "extended_slk_color".}

#get_wch: get (or push back) a wide character from a terminal keyboard
proc get_wch*(wch: WideCString): ErrCode {.ncurses, importc: "get_wch".}
proc wget_wch*(win: ptr Window, wch: WideCString): ErrCode {.ncurses, importc: "wget_wsch".}
proc mvget_wch*(y,x: cint, wch: WideCString): ErrCode {.ncurses, importc: "mvget_wch".}
proc mvwget_wch*(win: ptr Window, y,x: cint, wch: WideCString): ErrCode {.ncurses, importc: "mvwget_wch".}
proc unget_wch*(wch: WideCString): ErrCode {.ncurses, importc: "unget_wch".}

#get_wstr: get an array of wide characters from a terminal keyboard
proc get_wstr*(wstr: WideCString): ErrCode {.ncurses, importc: "get_wstr".}
proc getn_wstr*(wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "getn_wstr".}
proc wget_wstr*(win: ptr Window, wstr: WideCString): ErrCode {.ncurses, importc: "wget_wsch".}
proc wgetn_wstr*(win: ptr Window, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "wgetn_wsch".}
proc mvget_wstr*(y,x: cint, wstr: WideCString): ErrCode {.ncurses, importc: "mvget_wstr".}
proc mvgetn_wstr*(y,x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvgetn_wstr".}
proc mvwget_wstr*(win: ptr Window, y,x: cint, wstr: WideCString): ErrCode {.ncurses, importc: "mvwget_wstr".}
proc mvwgetn_wstr*(win: ptr Window, y,x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvwgetn_wstr".}

#legacy: get cursor and window coordinates, attributes
proc getattrs*(win: ptr Window): cint {.ncurses, importc: "getattrs".}
proc getbegx*(win: ptr Window): cint {.ncurses, importc: "getbegx".}
proc getbegy*(win: ptr Window): cint {.ncurses, importc: "getbegy".}
proc getcurx*(win: ptr Window): cint {.ncurses, importc: "getcurx".}
proc getcury*(win: ptr Window): cint {.ncurses, importc: "getcury".}
proc getmaxx*(win: ptr Window): cint {.ncurses, importc: "getmaxx".}
proc getmaxy*(win: ptr Window): cint {.ncurses, importc: "getmaxy".}
proc getparx*(win: ptr Window): cint {.ncurses, importc: "getparx".}
proc getpary*(win: ptr Window): cint {.ncurses, importc: "getpary".}

#getyx: get curses cursor and window coordinates (these are implemented as macros in ncurses.h)
template getyx*(win: ptr Window, y, x: cint): untyped=
  ## Reads the logical cursor location from the specified window.
  ## @Param: 'win' the window to get the cursor location from.
  ## @Param: 'y' stores the height of the window.
  ## @Param: 'x' stores the width of the window.
  (y = getcury(win); x = getcurx(win)) ## testing
template getbegyx*(win: ptr Window, y, x: cint): untyped=
  (y = getbegy(win); x = getbegx(win))
template getmaxyx*(win: ptr Window, y, x: cint): untyped=
  ## retrieves the size of the specified window in the provided y and x parameters.
  ## @Param: 'win' the window to measure.
  ## @Param: 'y' stores the height of the window.
  ## @Param: 'x' stores the width of the window.
  (y = getmaxy(win); x = getmaxx(win))
template getparyx*(win: ptr Window, y, x: cint): untyped=
  (y = getpary(win); x = getparx(win))

#getcchar: Get a wide character string and rendition from cchar_t or set a cchar_t from a wide-character string
proc getcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: ptr attr_t, color_pair: ptr cshort, opts: pointer): ErrCode {.ncurses, importc: "getcchar".}
proc setcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: attr_t, color_pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "setcchar".}

#getch: get (or push back) characters from the terminal keyboard
proc getch*(): ErrCode {.ncurses, importc: "getch".}
  ## Read a character from the stdscr window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetch*(win: ptr Window): ErrCode {.ncurses, importc: "wgetch".}
  ## Read a character from the specified window.
  ## @Param: 'sourceWindow' the window to read a character from.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvgetch*(y,x: cint): ErrCode {.ncurses, importc: "mvgetch".}
proc mvwgetch*(win: ptr Window, y,x: cint): ErrCode {.ncurses, importc: "mvwgetch".}
proc ungetch*(ch: cint): ErrCode {.ncurses, importc: "ungetch".}
proc has_key*(ch: cint): ErrCode {.ncurses, importc: "has_key".}

#mouse: mouse interface
proc has_mouse*(): bool {.ncurses, importc: "has_mouse".}
proc getmouse*(event: ptr Mevent): ErrCode {.ncurses, importc: "getmouse".}
proc ungetmouse*(event: ptr Mevent): ErrCode {.ncurses, importc: "ungetmouse".}
proc mousemask*(newmask: mmask_t, oldmask: ptr mmask_t): mmask_t {.ncurses, importc: "mousemask".}
proc wenclose*(win: ptr Window, y, x: cint): bool {.ncurses, importc: "wenclose".}
proc mouse_trafo*(y,x: ptr cint, to_screen: bool): bool {.ncurses, importc: "mouse_trafo".}
proc wmouse_trafo*(win: ptr Window, y,x: ptr cint, to_screen: bool): bool {.ncurses, importc: "wmouse_trafo".}
proc mouseinterval*(erval: cint): ErrCode {.ncurses, importc: "mouseinterval".}

#getstr: accept character strings from terminal keyboard
proc getstr*(str: cstring): ErrCode {.ncurses, importc: "getstr".}
  ## Reads the inputted characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Returns: ERR on failure and OK upon successful completion.
proc getnstr*(str: cstring; n: cint): ErrCode {.ncurses, importc: "getnstr".}
  ## Reads at most the specified number of characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Param: 'numberOfCharacters' the maximum number of characters to read.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetstr*(win: ptr Window, str: cstring): ErrCode {.ncurses, importc: "wgetstr".}
proc wgetnstr*(win: ptr Window, str: cstring, n: cint): ErrCode {.ncurses, importc: "wgetnstr".}
proc mvgetstr*(y,x: cint, str: cstring): ErrCode {.ncurses, importc: "mvgetstr".}
proc mvgetnstr*(y,x: cint, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvgetnstr".}
proc mvwgetstr*(win: ptr Window, y,x: cint, str: cstring): ErrCode {.ncurses, importc: "mvwgetstr".}
proc mvwgetnstr*(win: ptr Window, y,x: cint, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvwgetnstr".}

#in_wch: extract a complex character and rendition from a window
#https://invisible-island.net/ncurses/man/curs_in_wch.3x.html

#in_wchstr: get an array of complex characters and renditions from a window
#https://invisible-island.net/ncurses/man/curs_in_wchstr.3x.html

#inch: get a character and attributes from a window
#https://invisible-island.net/ncurses/man/curs_inch.3x.html

#inchstr: get a string of characters (and attributes) from a window
#https://invisible-island.net/ncurses/man/curs_inchstr.3x.html

#instr: get a string of characters from a window
#https://invisible-island.net/ncurses/man/curs_instr.3x.html

#inwstr: get a string of wchar_t characters from a window
#https://invisible-island.net/ncurses/man/curs_inwstr.3x.html

#ins_wstr: insert a wide-character string into a window
#https://invisible-island.net/ncurses/man/curs_ins_wstr.3x.html

#ins_wch: insert a complex character and rendition into a window
#https://invisible-island.net/ncurses/man/curs_ins_wch.3x.html

#insch: insert a character before cursor in a window
#https://invisible-island.net/ncurses/man/curs_insch.3x.html

#insstr: insert string before cursor in a window
#https://invisible-island.net/ncurses/man/curs_insstr.3x.html

#opaque: window properties
#https://invisible-island.net/ncurses/man/curs_opaque.3x.html

#touch: refresh control routines
#https://invisible-island.net/ncurses/man/curs_touch.3x.html

#resizeterm: change the curses terminal size
#https://invisible-island.net/ncurses/man/resizeterm.3x.html

#key_defined: check if a keycode is defined
#https://invisible-island.net/ncurses/man/key_defined.3x.html

#keybound: return definition of keycode
#https://invisible-island.net/ncurses/man/keybound.3x.html

#keyok: enable or disable a keycode
#https://invisible-island.net/ncurses/man/keyok.3x.html

#print: ship binary data to printer
#https://invisible-island.net/ncurses/man/curs_print.3x.html

#move: move window cursor
proc move*(y, x: cint): cint {.ncurses, importc: "move".}
  ## Moves the cursor of stdscr to the specified coordinates.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Returns: ERR on failure and OK upon successful completion.
#MISSING: wmove
#https://invisible-island.net/ncurses/man/curs_move.3x.html

#printw: print formatted output in windows
#https://invisible-island.net/ncurses/man/curs_printw.3x.html

#scanw: convert formatted input from a window
#https://invisible-island.net/ncurses/man/curs_scanw.3x.html

#pad: create and display pads
#https://invisible-island.net/ncurses/man/curs_pad.3x.html

#scr_dump: read (write) a screen from (to) a file
#https://invisible-island.net/ncurses/man/curs_scr_dump.3x.html

#scroll: scroll a window
#https://invisible-island.net/ncurses/man/curs_scroll.3x.html

#termcap: direct interface to the terminfo capability database
#https://invisible-island.net/ncurses/man/curs_termcap.3x.html

#legacy_coding: override locale-encoding checks
#https://invisible-island.net/ncurses/man/legacy_coding.3x.html

#wresize: resize a curses window
#https://invisible-island.net/ncurses/man/wresize.3x.html

#proc *(): ErrCode {.ncurses, importc: "".}
#proc *(): {.ncurses, importc: "".}
# https://invisible-island.net/ncurses/man/ncurses.3x.html
# https://invisible-island.net/ncurses/man/curs_outopts.3x.html #[ Ended Here ]#

proc can_change_color*(): bool {.ncurses, importc: "can_change_color".}
    ## Used to determine if the terminal supports colours and can change their definitions.
    ## @Returns: true if the terminal supports colours and can change their definitions or
    ## false otherwise.

#proc *() {.ncurses, importc: "".}

# These functions are not in X/Open, but we use them in macro definitions:



proc newwin*(lines, columns, begin_y, begin_x: int): ptr Window {.ncurses, importc: "newwin".}

proc mvwin*(win: ptr Window, y, x: int): cint {.ncurses, importc: "mvwin".}

proc subpad*(orig: ptr Window, lines, columns, begin_y, begin_x: int): ptr Window {.ncurses, importc: "subpad".}

proc subwin*(orig: ptr Window, lines, columns, begin_y, begin_x: int): ptr Window {.ncurses, importc: "subwin".}

proc scroll*(win: ptr Window): cint {.ncurses, importc: "scroll".}

proc wattron*(win: ptr Window, attributes: int64): cint {.ncurses, importc: "wattron".}

proc wattroff*(win: ptr Window, attributes: int64): cint {.ncurses, importc: "wattroff".}

proc wresize*(win: ptr Window, line, column: int): cint {.ncurses, importc: "wresize".}

proc wprintw*(win: ptr Window, formattedString: cstring): cint {.ncurses, importc: "wprintw".}

proc set_escdelay*(size: int): cint {.ncurses, importc: "set_escdelay".}

proc has_colors*(): bool {.ncurses, importc: "has_colors".}
    ## Used to determine if the terminal can manipulate colours.
    ## @Returns: true if the terminal can manipulate colours or false if it cannot.

proc init_color*(color: cshort, r: cshort, g: cshort, b: cshort): cint {.ncurses, importc: "init_color".}

proc init_pair*(pair: cshort; foreground: cshort; background: cshort): cint {.ncurses, importc: "init_pair".}
    ## Changes the definition of a colour pair.
    ## @Param: 'pair' the number of the colour pair to change.
    ## @Param: 'foreground': the foreground colour number.
    ## @Param: 'background': the background colour number.
    ## @Returns: ERR on failure and OK upon successful completion.

proc insch*(character: chtype): cint {.ncurses, importc: "insch".}
    ## Inserts a character before the cursor in the stdscr.
    ## @Param: 'character' the character to insert.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvaddch*(y: int; x: int; character: chtype): cint {.ncurses, importc: "mvaddch".}
    ## Moves the cursor to the specified position and outputs the provided character.
    ## The cursor is then advanced to the next position.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'character' the character to put into the current window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvprintw*(y: int; x: int; formattedString: cstring): cint {.varargs, ncurses, importc: "mvprintw".}
    ## Prints out a formatted string to the stdscr at the specified row and column.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc mvwprintw*(destinationWindow: ptr Window; y: int; x: int; formattedString: cstring): cint {.varargs, ncurses, importc: "mvwprintw".}
    ## Prints out a formatted string to the specified window at the specified row and column.
    ## @Param: 'destinationWindow' the window to write the string to.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc printw*(formattedString: cstring): cint {.varargs, ncurses, importc: "printw".}
    ## Prints out a formatted string to the stdscr.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc scanw*(formattedInput: cstring): int {.varargs, ncurses, importc: "scanw".}
    ## Converts formatted input from the stdscr.
    ## @Param: 'formattedInput' Contains the fields for the input to be mapped to.
    ## @Returns: The number of fields that were mapped in the call.

proc start_color*(): cint {.ncurses, importc: "start_color".}
    ## Initialises the the eight basic colours and the two global varables COLORS and COLOR_PAIRS.
    ## It also restores the colours on the terminal to the values that they had when the
    ## terminal was just turned on.
    ## @Note: It is good practice to call this routine right after initscr. It must be
    ## called before any other colour manipulating routines.

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
