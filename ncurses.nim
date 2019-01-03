{.deadCodeElim: on.}
when defined(windows):
 const libncurses* = "libncurses.dll"
elif defined(macosx):
 const libncurses* = "libncurses.dylib"
else:
 const libncurses* = "libncursesw.so"
{.pragma: ncurses, discardable, cdecl, dynlib: libncurses.}

type
  chtype*  = cuint #32 or 64
  mmask_t* = uint32
  attr_t*  = chtype # ...must be at least as wide as chtype

  cchar_t* = object # (complex char)
    attr: attr_t
    chars: WideCString #5
    ext_color: cint

  ldat = object # (line data)
  
  window* = win_st
  win_st = object # (window struct)
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
    parent*: ptr window       # pointer to parent if a sub-window
    
    # these are used only if this is a pad
    pad*: pdat
    yoffset*: cshort          # real begy is _begy + _yoffset
    bkgrnd*: cchar_t          # current background char/attribute pair
    color*: cint              # current color-pair for non-space character
  
  pdat = object # (pad data)
    pad_y*,      pad_x*:     cshort
    pad_top*,    pad_left*:  cshort
    pad_bottom*, pad_right*: cshort

  MEVENT* = object # (mouse event)
    id*: cshort               # ID to distinguish multiple devices
    x*, y*, z*: cint          # event coordinates (character-cell)
    bstate*: mmask_t          # button state bits

var COLORS* {.importc: "COLORS", dynlib: libncurses.}: int
var COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: int

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
proc wadd_wch*(win: ptr window, wch: ptr cchar_t): ErrCode {.ncurses, importc: "wadd_wch".}
proc mvadd_wch*(y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses, importc: "mvadd_wch".}
proc mvwadd_wch*(win: ptr window, y, x: cint, wch: ptr cchar_t): ErrCode {.ncurses, importc: "mvwadd_wch".}
proc echo_wchar*(wch: ptr cchar_t): ErrCode {.ncurses, importc: "echo_wchar".}
proc wech_wchar*(win: ptr window, wch: ptr cchar_t): ErrCode {.ncurses, importc: "wech_wchar".}

#add_wchstr: Adding an array of complex characters to a window
proc add_wchstr*(wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "add_wchstr".}
proc add_wchnstr*(wchstr: ptr cchar_t, numberOfCharacters: cint): ErrCode {.ncurses, importc: "add_wchnstr".}
proc wadd_wchstr*(win: ptr window, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "wadd_wchstr".}
proc wadd_wchnstr*(win: ptr window, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "wadd_wchnstr".}
proc mvadd_wchstr*(y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "mvadd_wchstr".}
proc mvadd_wchnstr*(y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "mvadd_wchnstr".}
proc mvwadd_wchstr*(win: ptr window, y, x: cint, wchstr: ptr cchar_t): ErrCode {.ncurses, importc: "mvwadd_wchstr".}
proc mvwadd_wchnstr*(win: ptr window, y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwadd_wchnstr".}

#addch: Adding a character (with attributes) to a window
proc addch*(character: chtype): ErrCode {.ncurses, importc: "addch".}
  ## Puts a character into the stdscr at its current window position and then advances
  ## the current window position to the next position.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddch*(win: ptr window, ch: chtype): ErrCode {.ncurses, importc: "waddch".}
proc mvaddch*(y, x: cint, ch: chtype): ErrCode {.ncurses, importc: "mvaddch".}
proc mvwaddch*(win: ptr window, y, x: int, ch: chtype): ErrCode {.ncurses, importc: "mvwaddch".}
proc echochar*(ch: chtype): ErrCode {.ncurses, importc: "echochar".}
proc wechochar*(win: ptr window, ch: chtype): ErrCode {.ncurses, importc: "wechochar".}

#addchstr: Adding a string of characters (and attributes) to a window
proc addchstr*(chstr: ptr chtype): ErrCode {.ncurses, importc: "addchstr".}
proc addchnstr*(chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "addchnstr".}
proc waddchstr*(win: ptr window, chstr: ptr chtype): ErrCode {.ncurses, importc: "waddchstr".}
proc waddchnstr*(win: ptr window, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "waddchnstr".}
proc mvaddchstr*(y, x: cint, chstr: ptr chtype): ErrCode {.ncurses, importc: "mvaddchstr".}
proc mvaddchnstr*(y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "mvaddchnstr".}
proc mvwaddchstr*(win: ptr window, y, x: cint, chstr: ptr chtype): ErrCode {.ncurses, importc: "mvwaddchstr".}
proc mvwaddchnstr*(win: ptr window, y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.ncurses, importc: "mvwaddchnstr".}

#addstr: Adding a string of characters to a window (cstring)
proc addstr*(str: cstring): ErrCode {.ncurses, importc: "addstr".}
  ## Adds a string of characters the the stdscr and advances the cursor.
  ## @Param: The string to add the stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc addnstr*(str: cstring, n: cint): ErrCode {.ncurses, importc: "addnstr".}
proc waddstr*(win: ptr window; str: cstring): ErrCode {.ncurses, importc: "waddstr".}
  ## Writes a string to the specified window.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'stringToWrite'
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddnstr*(win: ptr window, str: cstring, n: cint): ErrCode {.ncurses, importc: "waddnstr".}
proc mvaddstr*(y, x: cint; str: cstring): ErrCode {.ncurses, importc: "mvaddstr".}
  ## Moves the cursor to the specified position and outputs the provided string.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'stringToOutput' the string to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvaddnstr*(y, x: cint, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvaddnstr".}
proc mvwaddstr*(win: ptr window, y, x: int, str: cstring): ErrCode {.ncurses, importc: "mvwaddstr".}
proc mvwaddnstr*(win: ptr window, y, x: int, str: cstring, n: cint): ErrCode {.ncurses, importc: "mvwaddnstr".}

#addwstr: Adding a string of wide characters to a window (WideCString)
proc addwstr(wstr: WideCString): ErrCode {.ncurses, importc: "addwstr".}
proc addnwstr(wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "addnwstr".}
proc waddwstr(win: ptr window, wstr: WideCString): ErrCode {.ncurses, importc: "waddwstr".}
proc waddnwstr(win: ptr window, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "waddnwstr".}
proc mvaddwstr(y, x: cint, win: ptr window, wstr: WideCString): ErrCode {.ncurses, importc: "mvaddwstr".}
proc mvaddnwstr(y, x: cint, win: ptr window, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvaddnwstr".}
proc mvwaddwstr(win: ptr window, y, x: cint, wstr: WideCString): ErrCode {.ncurses, importc: "mvwaddwstr".}
proc mvwaddnwstr(win: ptr window, y, x: cint, wstr: WideCString, n: cint): ErrCode {.ncurses, importc: "mvwaddnwstr".}

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
proc wattr_get*(win: ptr window, attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.ncurses, importc: "wattr_get".}
proc attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "attr_set".}
proc wattr_set*(win: ptr window, attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wattr_set".}
proc attr_off*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "attr_off".}
proc wattr_off*(win: ptr window, attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "wattr_off".}
proc attr_on*(attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "attr_on".}
proc wattr_on*(win: ptr window, attrs: attr_t, opts: pointer): ErrCode {.ncurses, importc: "wattr_on".}
proc attroff*(attrs: cint): ErrCode {.ncurses, importc: "attroff".}
  ## Turns off the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn off for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattroff*(win: ptr window, attrs: cint): ErrCode {.ncurses, importc: "wattroff".}
proc attron*(attrs: cint): ErrCode {.ncurses, importc: "attron".}
  ## Turns on the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn on for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattron*(win: ptr window, attrs: cint): ErrCode {.ncurses, importc: "wattron".}
proc attrset*(attrs: cint): ErrCode {.ncurses, importc: "attrset".}
  ## Sets the current attributes of the given window to the provided attributes.
  ## @Param: 'attributes', the attributes to apply to the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattrset*(win: ptr window, attrs: cint): ErrCode {.ncurses, importc: "wattrset".}
proc chgat*(n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "chgat".}
proc wchgat*(win: ptr window, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wchgat".}
proc mvchgat*(y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "mvchgat".}
proc mvwchgat*(win: ptr window, y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "mvwchgat".}
proc color_set*(pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "color_set".}
proc wcolor_set*(win: ptr window, pair: cshort, opts: pointer): ErrCode {.ncurses, importc: "wcolor_set".}
proc standend(): ErrCode {.ncurses, importc: "standend".}
proc wstandend*(win: ptr window): ErrCode {.ncurses, importc: "wstandend".}
proc standout*(): ErrCode {.ncurses, importc: "standout".}
proc wstandout*(win: ptr window): ErrCode {.ncurses, importc: "wstandout".}

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
proc wbkgdset*(win: ptr window, ch: chtype): void {.ncurses, importc: "wbkgdset".}
proc bkgd*(ch: chtype): ErrCode {.ncurses, importc: "bkgd".}
  ## Sets the background property of the current window and apply this setting to every
  ## character position in the window.
  ## @Param: 'background' the background property to apply.
proc wbkgd*(win: ptr window, ch: chtype): ErrCode {.ncurses, importc: "wbkgd".}
proc getbkgd*(win: ptr window): chtype {.ncurses, importc: "getbkgd".}

#bkgrnd: Window complex background manipulation routines
proc bkgrnd*(wch: cchar_t): ErrCode {.ncurses, importc: "bkgrnd".}
proc wbkgrnd*(win: ptr window, wch: cchar_t): ErrCode {.ncurses, importc: "wbkgrnd".}
proc bkgrndset*(wch: cchar_t): void {.ncurses, importc: "bkgrndset".}
proc wbkgrndset*(win: ptr window, wch: cchar_t): void {.ncurses, importc: "getbkgrnd".}
proc getbkgrnd*(wch: cchar_t): ErrCode {.ncurses, importc: "getbkgrnd".}
proc wgetbkgrnd*(win: ptr window, wch: cchar_t): ErrCode {.ncurses, importc: "wgetbkgrnd".}

#border: Create borders, horizontal and vertical lines
proc border*(ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses, importc: "border".}
proc wborder*(win: ptr window, ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.ncurses, importc: "wborder".}
proc box*(win: ptr window, verch, horch: chtype): ErrCode {.ncurses, importc: "box".}
proc hline*(ch: chtype, n: cint): ErrCode {.ncurses, importc: "hline".}
proc whline*(win: ptr window, ch: chtype, n: cint): ErrCode {.ncurses, importc: "whline".}
proc vline*(ch: chtype, n: cint): ErrCode {.ncurses, importc: "vline".}
proc wvline*(win: ptr window, ch: chtype, n: cint): ErrCode {.ncurses, importc: "wvline".}
proc mvhline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvhline".}
proc mvwhline*(win: ptr window, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvwhline".}
proc mvvline*(y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvvline".}
proc mvwvline*(win: ptr window, y, x: cint, ch: chtype, n: cint): ErrCode {.ncurses, importc: "mvwvline".}

#borderset: Create borders or lines using complex characters and renditions
proc border_set*(ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses, importc: "border_set".}
proc wborder_set*(win: ptr window, ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.ncurses, importc: "wborder_set".}
proc box_set*(win: ptr window, verch, horch: cchar_t): ErrCode {.ncurses, importc: "box_set".}
proc hline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "hline_set".}
proc whline_set*(win: ptr window, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "whline_set".}
proc mvhline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvhline_set".}
proc mvwhline_set*(win: ptr window, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwhline_set".}
proc vline_set*(wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "vline_set".}
proc wvline_set*(win: ptr window, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "wvline_set".}
proc mvvline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvvline_set".}
proc mvwvline_set*(win: ptr window, y,x: cint, wch: cchar_t, n: cint): ErrCode {.ncurses, importc: "mvwvline_set".}

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
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}
proc *(): ErrCode {.ncurses, importc: "".}




































#proc *(): ErrCode {.ncurses, importc: "".}
#proc *(): {.ncurses, importc: "".}


proc can_change_color*(): bool {.ncurses, importc: "can_change_color".}
    ## Used to determine if the terminal supports colours and can change their definitions.
    ## @Returns: true if the terminal supports colours and can change their definitions or
    ## false otherwise.


proc clear*(): cint {.ncurses, importc: "clear".}
proc clearok*() {.ncurses, importc: "".}
proc clrtobot*() {.ncurses, importc: "".}
proc clrtoeol*() {.ncurses, importc: "".}
proc color_content*() {.ncurses, importc: "".}

proc copywin*() {.ncurses, importc: "".}
proc copy*() {.ncurses, importc: "".}
proc curs_set*(visibility: int): cint {.ncurses, importc: "curs_set".}
proc curses_version*() {.ncurses, importc: "".}
proc def_prog_mode*(): cint {.ncurses, importc: "def_prog_mode".}
proc def_shell_mode*() {.ncurses, importc: "".}
proc define_key*() {.ncurses, importc: "".}
proc del_curterm*() {.ncurses, importc: "".}
proc delay_output*() {.ncurses, importc: "".}
proc delch*(): cint {.ncurses, importc: "delch".}
    ## Delete the character under the cursor in the stdscr.
    ## @Returns: ERR on failure and OK upon successfully flashing.
proc deleteln*(): cint {.ncurses, importc: "deleteln".}
    ## Deletes the line under the cursor in the stdscr. All lines below the current line are moved up one line.
    ## The bottom line of the window is cleared and the cursor position does not change.
    ## @Returns: ERR on failure and OK upon successful completion.
proc delscreen*() {.ncurses, importc: "".}
proc delwin*(win: ptr window): cint {.ncurses, importc: "delwin".}
proc derwin*() {.ncurses, importc: "".}
proc doupdate*() {.ncurses, importc: "".}
proc dupwin*() {.ncurses, importc: "".}
proc echo*() {.ncurses, importc: "".}
proc echo_whchar*() {.ncurses, importc: "".}
proc echochar*() {.ncurses, importc: "".}
proc endwin*(): cint {.ncurses, importc: "endwin".}
    ## A program should always call endwin before exiting or escaping from curses mode temporarily. This routine
    ## restores tty modes, moves the cursor to the lower left-hand corner of the screen and resets the terminal into the
    ## proper non-visual mode. Calling refresh or doupdate after a temporary escape causes the program to resume visual mode.
    ## @Returns: ERR on failure and OK upon successful completion.
proc erase*(): cint {.ncurses, importc: "erase".}

proc extended_color_content*() {.ncurses, importc: "".}
proc extended_pair_content*() {.ncurses, importc: "".}
proc extended_slk_color*() {.ncurses, importc: "".}
proc filter*() {.ncurses, importc: "".}

proc flushinp*() {.ncurses, importc: "".}

proc get_wch*() {.ncurses, importc: "".}
proc get_wstr*() {.ncurses, importc: "".}
proc getattrs*(a2: ptr window): cint {.ncurses, importc: "getattrs".}
proc getbegx*(a2: ptr window): cint {.ncurses, importc: "getbegx".}
proc getbegy*(a2: ptr window): cint {.ncurses, importc: "getbegy".}
proc getbegyx*() {.ncurses, importc: "".}
proc getcurx*(a2: ptr window): cint {.ncurses, importc: "getcurx".}
proc getcury*(a2: ptr window): cint {.ncurses, importc: "getcury".}
proc getmaxx*(a2: ptr window): cint {.ncurses, importc: "getmaxx".}
proc getmaxy*(a2: ptr window): cint {.ncurses, importc: "getmaxy".}
proc getmaxyx*(win: ptr window, y, x: var int) =
    ## retrieves the size of the specified window in the provided y and x parameters.
    ## @Param: 'win' the window to measure.
    ## @Param: 'y' stores the height of the window.
    ## @Param: 'x' stores the width of the window.
    y = getmaxy(win)
    x = getmaxx(win)
proc getparx*(a2: ptr window): cint {.ncurses, importc: "getparx".}
proc getpary*(a2: ptr window): cint {.ncurses, importc: "getpary".}
#proc *() {.ncurses, importc: "".}

proc has_mouse*(): bool {.ncurses, importc: "has_mouse".}
proc getmouse*(a2: ptr MEVENT): cint {.ncurses, importc: "getmouse".}
proc ungetmouse*(a2: ptr MEVENT): cint {.ncurses, importc: "ungetmouse".}
proc mousemask*(a2: mmask_t; a3: ptr mmask_t): mmask_t {.ncurses, importc: "mousemask".}
proc wenclose*(a2: ptr window; a3: cint; a4: cint): bool {.ncurses, importc: "wenclose".}
proc mouseinterval*(a2: cint): cint {.ncurses, importc: "mouseinterval".}
proc wmouse_trafo*(a2: ptr window; a3: ptr cint; a4: ptr cint; a5: bool): bool {.ncurses, importc: "wmouse_trafo".}
proc mouse_trafo*(a2: ptr cint; a3: ptr cint; a4: bool): bool {.ncurses, importc: "mouse_trafo".}

# These functions are not in X/Open, but we use them in macro definitions:



proc newwin*(lines, columns, begin_y, begin_x: int): ptr window {.ncurses, importc: "newwin".}

proc mvwin*(win: ptr window, y, x: int): cint {.ncurses, importc: "mvwin".}

proc subpad*(orig: ptr window, lines, columns, begin_y, begin_x: int): ptr window {.ncurses, importc: "subpad".}

proc subwin*(orig: ptr window, lines, columns, begin_y, begin_x: int): ptr window {.ncurses, importc: "subwin".}

proc keypad*(win: ptr window, bf: bool): cint {.ncurses, importc: "keypad".}

proc scrollok*(win: ptr window, bf: bool): cint {.ncurses, importc: "scrollok".}

proc scroll*(win: ptr window): cint {.ncurses, importc: "scroll".}

proc werase*(win: ptr window): cint {.ncurses, importc: "werase".}

proc wclear*(win: ptr window): cint {.ncurses, importc: "wclear".}

proc wrefresh*(win: ptr window): cint {.ncurses, importc: "wrefresh".}

proc wattron*(win: ptr window, attributes: int64): cint {.ncurses, importc: "wattron".}

proc wattroff*(win: ptr window, attributes: int64): cint {.ncurses, importc: "wattroff".}

proc wresize*(win: ptr window, line, column: int): cint {.ncurses, importc: "wresize".}

proc wmove*(win: ptr window, y, x: int): cint {.ncurses, importc: "wmove".}

proc wprintw*(win: ptr window, formattedString: cstring): cint {.ncurses, importc: "wprintw".}

proc set_escdelay*(size: int): cint {.ncurses, importc: "set_escdelay".}

proc reset_prog_mode*(): cint {.ncurses, importc: "reset_prog_mode".}

proc raw*(): cint {.ncurses, importc: "raw".}

proc timeout*(delay: cint) {.ncurses, importc: "timeout".}

proc nodelay*(win: ptr window, bf: bool): cint {.ncurses, importc: "nodelay".}

proc getch*(): cint {.ncurses, importc: "getch".}
    ## Read a character from the stdscr window.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getnstr*(inputString: cstring; numberOfCharacters: int): cint {.ncurses, importc: "getnstr".}
    ## Reads at most the specified number of characters into the provided string.
    ## @Param: 'inputString' the variable to read the input into.
    ## @Param: 'numberOfCharacters' the maximum number of characters to read.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getstr*(inputString: cstring): cint {.ncurses, importc: "getstr".}
    ## Reads the inputted characters into the provided string.
    ## @Param: 'inputString' the variable to read the input into.
    ## @Returns: ERR on failure and OK upon successful completion.

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

proc initscr*(): ptr window {.ncurses, importc: "initscr".}
    ## Usually the first curses routine to be called when initialising a program
    ## The initscr code determines the terminal type and initialises  all curses data structures.  initscr also causes the
    ## first call to refresh to clear the screen.
    ## @Returns: A pointer to stdscr is returned if the operation is successful.
    ## @Note: If errors occur, initscr writes an appropriate error message to
    ## standard error and exits.

proc insch*(character: chtype): cint {.ncurses, importc: "insch".}
    ## Inserts a character before the cursor in the stdscr.
    ## @Param: 'character' the character to insert.
    ## @Returns: ERR on failure and OK upon successful completion.

proc insertln*(): cint {.ncurses, importc: "insertln".}
    ## Inserts a blank line above the current line in stdscr and the bottom line is lost.
    ## @Returns: ERR on failure and OK upon successful completion.

proc move*(y: int; x: int): cint {.ncurses, importc: "move".}
    ## Moves the cursor of stdscr to the specified coordinates.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
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

proc mvwprintw*(destinationWindow: ptr window; y: int; x: int; formattedString: cstring): cint {.varargs, ncurses, importc: "mvwprintw".}
    ## Prints out a formatted string to the specified window at the specified row and column.
    ## @Param: 'destinationWindow' the window to write the string to.
    ## @Param: 'y' the line to move the cursor to.
    ## @Param: 'x' the column to move the cursor to.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc napms*(milliseconds: int): cint {.ncurses, importc: "napms".}
    ## Used to sleep for the specified milliseconds.
    ## @Params: 'milliseconds' the number of milliseconds to sleep for.
    ## @Returns: ERR on failure and OK upon successful completion.

proc printw*(formattedString: cstring): cint {.varargs, ncurses, importc: "printw".}
    ## Prints out a formatted string to the stdscr.
    ## @Param: 'formattedString' the string with formatting to be output to stdscr.
    ## @Returns: ERR on failure and OK upon successful completion.

proc refresh*(): cint {.ncurses, importc: "refresh".}
    ## Must be called to get actual output to the terminal. refresh uses stdscr has the default window.
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

proc wgetch*(sourceWindow: ptr window): cint {.ncurses, importc: "wgetch".}
    ## Read a character from the specified window.
    ## @Param: 'sourceWindow' the window to read a character from.
    ## @Returns: ERR on failure and OK upon successful completion.

proc getyx*(win: ptr window, y, x: var int) =
    ## Reads the logical cursor location from the specified window.
    ## @Param: 'win' the window to get the cursor location from.
    ## @Param: 'y' stores the height of the window.
    ## @Param: 'x' stores the width of the window.
    y = getcury(win)
    x = getcurx(win)

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

  # colors
  COLOR_BLACK*   = 0
  COLOR_RED*     = 1
  COLOR_GREEN*   = 2
  COLOR_YELLOW*  = 3
  COLOR_BLUE*    = 4
  COLOR_MAGENTA* = 5
  COLOR_CYAN*    = 6
  COLOR_WHITE*   = 7

template KEY_F*(n: untyped): untyped= (KEY_F0+(n))    # Value of function key n