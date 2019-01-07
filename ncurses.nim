{.deadCodeElim: on.}
when defined(windows):
  const libncurses* = "libncurses.dll"
elif defined(macosx):
  const libncurses* = "libncurses.dylib"
else:
  const libncurses* = "libncursesw.so"

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
  Screen* {.importc.} = object
  Terminal* {.importc.} = object
  Window* = object ## window struct
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
  NCURSES_ATTR_SHIFT = 8'i64
template NCURSES_BITS(mask, shift: untyped): untyped =
   (NCURSES_CAST(int64, (mask)) shl ((shift) + NCURSES_ATTR_SHIFT))
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
  COLORS* {.importc: "COLORS", dynlib: libncurses.}: cint
    ## is initialized by start_color to the maximum number of colors thfe
    ## terminal can support.
  COLOR_PAIRS* {.importc: "COLOR_PAIRS", dynlib: libncurses.}: cint
    ## is initialized by start_color to the maximum number of color pairs the
    ## terminal can support.
template COLOR_PAIR*(n: untyped): untyped = NCURSES_BITS((n), 0'i64)
template PAIR_NUMBER*(a: untyped): untyped =
  (NCURSES_CAST(int, ((NCURSES_CAST(uint64, (a)) and A_COLOR) shr
    NCURSES_ATTR_SHIFT)))

proc start_color*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Initialises the the eight basic colours and the two global varables COLORS and COLOR_PAIRS.
  ## It also restores the colours on the terminal to the values that they had when the
  ## terminal was just turned on.
  ## @Note: It is good practice to call this routine right after initscr. It must be
  ## called before any other colour manipulating routines.
proc has_colors*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Used to determine if the terminal can manipulate colours.
  ## @Returns: true if the terminal can manipulate colours or false if it cannot.
proc can_change_color*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Used to determine if the terminal supports colours and can change their definitions.
  ## @Returns: true if the terminal supports colours and can change their definitions or
  ## false otherwise.
proc init_pair*(pair, f,b: cshort): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Changes the definition of a colour pair.
  ## @Param: 'pair' the number of the colour pair to change.
  ## @Param: 'foreground': the foreground colour number.
  ## @Param: 'background': the background colour number.
  ## @Returns: ERR on failure and OK upon successful completion.
proc init_color*(color: cshort, r, g, b: cshort): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc init_extended_pair*(pair, f,b: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc init_extended_color*(color: cint, r, g, b: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc color_content*(color: cshort, r, g, b: ptr cshort): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc pair_content*(pair: cshort, f,b: ptr cshort): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc extended_color_content*(color: cint, r, g, b: ptr cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc pair_content*(pair: cint, f,b: ptr cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc reset_color_pairs*(): void {.cdecl, importc, discardable, dynlib: libncurses.}

#threads: thread support
proc get_escdelay*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc set_escdelay*(size: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc set_tabsize*(size: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
#proc use_screen*(scr: PScreen, scr_cb: proc(scr: PScreen, pt: pointer): cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc use_window*(win: PWindow, win_cb: proc(win: PWindow, pt: pointer): cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#add_wchs: Adding complex characters to a window
proc add_wch*(wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wadd_wch*(win: PWindow, wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvadd_wch*(y, x: cint, wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwadd_wch*(win: PWindow, y, x: cint, wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc echo_wchar*(wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wech_wchar*(win: PWindow, wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#add_wchstr: Adding an array of complex characters to a window
proc add_wchstr*(wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc add_wchnstr*(wchstr: ptr cchar_t, numberOfCharacters: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wadd_wchstr*(win: PWindow, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wadd_wchnstr*(win: PWindow, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvadd_wchstr*(y, x: cint, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvadd_wchnstr*(y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwadd_wchstr*(win: PWindow, y, x: cint, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwadd_wchnstr*(win: PWindow, y, x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#addch: Adding a character (with attributes) to a window
proc addch*(character: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Puts a character into the stdscr at its current window position and then advances
  ## the current window position to the next position.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddch*(win: PWindow, ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddch*(y,x: cint; character: chtype): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Moves the cursor to the specified position and outputs the provided character.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'character' the character to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvwaddch*(win: PWindow, y, x: cint, ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc echochar*(ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wechochar*(win: PWindow, ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#addchstr: Adding a string of characters (and attributes) to a window
proc addchstr*(chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc addchnstr*(chstr: ptr chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc waddchstr*(win: PWindow, chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc waddchnstr*(win: PWindow, chstr: ptr chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddchstr*(y, x: cint, chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddchnstr*(y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddchstr*(win: PWindow, y, x: cint, chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddchnstr*(win: PWindow, y, x: cint, chstr: ptr chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#addstr: Adding a string of characters to a window (cstring)
proc addstr*(str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Adds a string of characters the the stdscr and advances the cursor.
  ## @Param: The string to add the stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc addnstr*(str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc waddstr*(win: PWindow; str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Writes a string to the specified window.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'stringToWrite'
  ## @Returns: ERR on failure and OK upon successful completion.
proc waddnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddstr*(y, x: cint; str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Moves the cursor to the specified position and outputs the provided string.
  ## The cursor is then advanced to the next position.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'stringToOutput' the string to put into the current window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvaddnstr*(y, x: cint, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddstr*(win: PWindow, y, x: cint, str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddnstr*(win: PWindow, y, x: cint, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#addwstr: Adding a string of wide characters to a window (WideCString)
proc addwstr(wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc addnwstr(wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc waddwstr(win: PWindow, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc waddnwstr(win: PWindow, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddwstr(y, x: cint, win: PWindow, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvaddnwstr(y, x: cint, win: PWindow, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddwstr(win: PWindow, y, x: cint, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwaddnwstr(win: PWindow, y, x: cint, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#new_pair: Color-pair functions
proc alloc_pair*(fg, bg: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc find_pair*(fg, bg: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc free_pair*(pair: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#default_colors: Use terminal's default colors
proc use_default_colors*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc assume_default_colors*(fg, bg: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#attr: Character and attribute control routines
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

proc attr_get*(attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wattr_get*(win: PWindow, attrs: ptr attr_t, pair: ptr cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wattr_set*(win: PWindow, attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attr_off*(attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wattr_off*(win: PWindow, attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attr_on*(attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wattr_on*(win: PWindow, attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attroff*(attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Turns off the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn off for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattroff*(win: PWindow, attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attron*(attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Turns on the named attributes without affecting any other attributes.
  ## @Param: 'attributes' the attributes to turn on for the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattron*(win: PWindow, attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc attrset*(attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Sets the current attributes of the given window to the provided attributes.
  ## @Param: 'attributes', the attributes to apply to the current window.
  ## @Returns: An integer value, but the returned value does not have any meaning and can
  ## thus be ignored.
proc wattrset*(win: PWindow, attrs: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc chgat*(n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wchgat*(win: PWindow, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvchgat*(y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwchgat*(win: PWindow, y, x: cint, n: cint, attr: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc color_set*(pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wcolor_set*(win: PWindow, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc standend(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wstandend*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc standout*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wstandout*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#termattrs: Enviroment query routines
proc baudrate*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc erasechar*() {.cdecl, importc, discardable, dynlib: libncurses.}
proc erasewchar*(ch: WideCString) {.cdecl, importc, discardable, dynlib: libncurses.}
proc has_ic*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc has_il*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc killchar*(): cchar {.cdecl, importc, discardable, dynlib: libncurses.}
proc killwchar*(ch: WideCString): char {.cdecl, importc, discardable, dynlib: libncurses.}
proc longname*(): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc term_attrs*(): attr_t {.cdecl, importc, discardable, dynlib: libncurses.}
proc term_attrs_ch*(): chtype {.cdecl, importc: "termattrs", discardable, dynlib: libncurses.} ## Previously termattrs
proc termname*(): cstring {.cdecl, importc, discardable, dynlib: libncurses.}

#beep: Bell and screen flash routines
proc beep*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc flash*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Flashes the screen and if that is not possible it sounds the alert. If this is not possible
  ## nothing happens.
  ## @Returns: ERR on failure and OK upon successfully flashing.

#bkgd: Window background manipulation routines
proc bkgdset*(ch: chtype): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc wbkgdset*(win: PWindow, ch: chtype): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc bkgd*(ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Sets the background property of the current window and apply this setting to every
  ## character position in the window.
  ## @Param: 'background' the background property to apply.
proc wbkgd*(win: PWindow, ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc getbkgd*(win: PWindow): chtype {.cdecl, importc, discardable, dynlib: libncurses.}

#bkgrnd: Window complex background manipulation routines
proc bkgrnd*(wch: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wbkgrnd*(win: PWindow, wch: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc bkgrndset*(wch: cchar_t): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc wbkgrndset*(win: PWindow, wch: cchar_t): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc getbkgrnd*(wch: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wgetbkgrnd*(win: PWindow, wch: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#border: Create borders, horizontal and vertical lines
proc border*(ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wborder*(win: PWindow, ls, rs, ts, bs, tl, tr, bl, br: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc box*(win: PWindow, verch, horch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc hline*(ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc whline*(win: PWindow, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc vline*(ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wvline*(win: PWindow, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvhline*(y, x: cint, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwhline*(win: PWindow, y, x: cint, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvvline*(y, x: cint, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwvline*(win: PWindow, y, x: cint, ch: chtype, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#borderset: Create borders or lines using complex characters and renditions
proc border_set*(ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wborder_set*(win: PWindow, ls, rs, ts, bs, tl, tr, bl, br: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc box_set*(win: PWindow, verch, horch: cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc hline_set*(wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc whline_set*(win: PWindow, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvhline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwhline_set*(win: PWindow, y,x: cint, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc vline_set*(wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wvline_set*(win: PWindow, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvvline_set*(y,x: cint, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwvline_set*(win: PWindow, y,x: cint, wch: cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#inopts: Input options
proc cbreak*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## The cbreak routine disables line buffering and erase/kill character-processing
  ## (interrupt and flow control characters are unaffected), making characters typed by
  ## the user immediately available to the program.
  ## @Returns: ERR on failure and OK upon successful completion.
proc nocbreak*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Returns the terminal to normal (cooked mode).
  ## @Returns: ERR on failure and OK upon successful completion.
proc noecho*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc onecho*(): ErrCode {.cdecl, discardable, dynlib: libncurses, importc: "echo".} ## Previously echo
proc halfdelay*(tenths: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc keypad*(win: PWindow, bf: bool): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc meta*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc nodelay*(win: PWindow, bf: bool): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc raw*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc noraw*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc noqiflush*(): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc qiflush*(): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc notimeout*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc timeout*(delay: cint): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc wtimeout*(win: PWindow, delay: cint): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc typeahead*(fd: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#clear: Clear all or part of a window
proc erase*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc werase*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc clear*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wclear*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc clrtobot*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wclrtobot*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc clrtoeol*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wclrtoeol*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#outopts: Output options
proc clearok*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc idlok*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc idcok*(win: PWindow, bf: bool): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc immedok*(win: PWindow, bf: bool): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc leaveok*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc setscrreg*(top, bot: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wsetscrreg*(win: PWindow, top, bot: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc scrollok*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc nl*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc nonl*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#overlay: overlay and manipulate overlapped windows
proc overlay*(srcwin, dstwin: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc overwrite*(srcwin, dstwin: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc copywin*(srcwin, dstwin: PWindow,
  sminrow, smincol,
  dminrow, dmincol,
  dmaxrow, dmaxcol: cint
): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#kernel: low-level routines (all except cur_set will always return OK)
proc def_prog_mode*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc def_shell_mode*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc reset_prog_mode*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc reset_shell_mode*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc resetty*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc savetty*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc getsyx*(y,x: cint): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc setsyx*(y,x: cint): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc ripoffline*(line: cint, init: proc(win: PWindow, cols: cint): cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc curs_set*(visibility: cint): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc napms*(ms: cint): cint {.cdecl, importc, discardable, dynlib: libncurses.}
    ## Used to sleep for the specified milliseconds.
    ## @Params: 'milliseconds' the number of milliseconds to sleep for.
    ## @Returns: ERR on failure and OK upon successful completion.

#extend: misc extensions
proc curses_version*(): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc use_extended_names*(enable: bool): cint {.cdecl, importc, discardable, dynlib: libncurses.}

#define_key: define a keycode
proc define_key*(definition: cstring, keycode: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#terminfo: interfaces to terminfo database
var
  cur_term*: ptr Terminal
  boolnames*, boolcodes*, boolfnames*: cstringArray
  numnames*, numcodes*, numfnames*: cstringArray
  strnames*, strcodes*, strfnames*: cstringArray
proc setupterm*(term: cstring; filedes: cint; errret: ptr cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc setterm*(term: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc set_curterm*(nterm: ptr Terminal): ptr Terminal {.cdecl, importc, discardable, dynlib: libncurses.}
proc del_curterm*(oterm: ptr Terminal): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc restartterm*(term: cstring; filedes: cint; errret: ptr cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tparm*(str: cstring): cstring {.varargs, cdecl, importc, discardable, dynlib: libncurses.}
proc putp*(str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc vid_puts_ch*(attrs: chtype; putc: proc(ch: cint): cint): ErrCode {.cdecl, importc: "vidputs", discardable, dynlib: libncurses.}
proc vid_attr_ch*(attrs: chtype): ErrCode {.cdecl, importc: "vidattr", discardable, dynlib: libncurses.}
proc vid_puts*(attrs: attr_t; pair: cshort; opts: pointer; putc: proc(ch: cint): cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc vid_attr*(attrs: attr_t; pair: cshort; opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvcur*(oldrow, oldcol, newrow, newcol: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tigetflag*(capname: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tigetnum*(capname: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tigetstr*(capname: cstring): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc tiparm*(str: cstring): cstring {.varargs, cdecl, importc, discardable, dynlib: libncurses.}

#util: misc utility routines
proc unctrl*(c: chtype): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc wunctrl*(c: ptr cchar_t): WideCString {.cdecl, importc, discardable, dynlib: libncurses.}
proc keyname*(c: cint): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc keyname_wch*(w: WideCString): cstring {.cdecl, discardable, dynlib: libncurses, importc: "key_name".} ## previously key_name, had to be renamed.
proc filter*(): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc nofilter*(): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc use_env*(f: bool): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc use_tioctl*(f: bool): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc putwin*(win: PWindow, filep: File): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc getwin*(filep: File): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc delay_output*(ms: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc flushinp*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}

#delch: delete character under the cursor in a window
proc delch*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Delete the character under the cursor in the stdscr.
  ## @Returns: ERR on failure and OK upon successfully flashing.
proc wdelch*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvdelch*(y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwdelch*(win: PWindow, y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#deleteln: delete and insert lines in a window
proc deleteln*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Deletes the line under the cursor in the stdscr. All lines below the current line are moved up one line.
  ## The bottom line of the window is cleared and the cursor position does not change.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wdeleteln*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc insdeln*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winsdeln*(win: PWindow, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc insertln*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Inserts a blank line above the current line in stdscr and the bottom line is lost.
  ## @Returns: ERR on failure and OK upon successful completion.
proc winsertln*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#iniscr: screen initialization and manipulation routines
proc initscr*(): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Usually the first curses routine to be called when initialising a program
  ## The initscr code determines the terminal type and initialises  all curses data structures.  initscr also causes the
  ## first call to refresh to clear the screen.
  ## @Returns: A pointer to stdscr is returned if the operation is successful.
  ## @Note: If errors occur, initscr writes an appropriate error message to
  ## standard error and exits.
proc endwin*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## A program should always call endwin before exiting or escaping from curses mode temporarily. This routine
  ## restores tty modes, moves the cursor to the lower left-hand corner of the screen and resets the terminal into the
  ## proper non-visual mode. Calling refresh or doupdate after a temporary escape causes the program to resume visual mode.
  ## @Returns: ERR on failure and OK upon successful completion.
proc isendwin*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc newterm*(`type`: cstring, outfd, infd: File): PScreen {.cdecl, importc, discardable, dynlib: libncurses.}
proc set_term*(`new`: PScreen): ptr Screen {.cdecl, importc, discardable, dynlib: libncurses.}
proc delscreen*(sp: PScreen): void {.cdecl, importc, discardable, dynlib: libncurses.}

#window: create a window
proc newwin*(nlines, ncols, begin_y, begin_x: cint): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc delwin*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwin*(win: PWindow, y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc subwin*(orig: PWindow, nlines, ncols, begin_y, begin_x: cint): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc derwin*(orig: PWindow, nlines, ncols, begin_y, begin_x: cint): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvderwin*(win: PWindow, par_y, par_x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc dupwin*(win: PWindow): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc wsyncup*(win: PWindow): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc syncok*(win: PWindow, bf: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wcursyncup*(win: PWindow): void {.cdecl, importc, discardable, dynlib: libncurses.}
proc wsyncdown*(win: PWindow): void {.cdecl, importc, discardable, dynlib: libncurses.}

#refresh: refresh windows and lines
proc refresh*(): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Must be called to get actual output to the terminal. refresh uses stdscr has the default window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wrefresh*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc wnoutrefresh*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc doupdate*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc redrawwin*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wredrawln*(win: PWindow, beg_lines, num_lines: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#slk: soft label routines
proc slk_init*(fmt: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_set*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_wset*(labnum: cint, label: WideCString, fmt: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_label*(labnum: cint): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_refresh*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_noutrefresh*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_clear*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_restore*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_touch*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_attron_ch*(attrs: chtype): ErrCode {.cdecl, importc: "slk_attron", discardable, dynlib: libncurses.} ## Previously slk_attron
proc slk_attroff_ch*(attrs: chtype): ErrCode {.cdecl, importc: "slk_attroff", discardable, dynlib: libncurses.} ## Previously slk_attroff
proc slk_attrset_ch*(attrs: chtype): ErrCode {.cdecl, importc: "slk_attrset", discardable, dynlib: libncurses.} ## Previously slk_attrset
proc slk_attr_on*(attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_attr_off*(attrs: attr_t, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_attr_set*(attrs: attr_t, pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_attr*(): attr_t {.cdecl, importc, discardable, dynlib: libncurses.}
proc slk_color*(pair: cshort): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc extended_slk_color*(pair: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#get_wch: get (or push back) a wide character from a terminal keyboard
proc get_wch*(wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wget_wch*(win: PWindow, wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvget_wch*(y,x: cint, wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwget_wch*(win: PWindow, y,x: cint, wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc unget_wch*(wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#get_wstr: get an array of wide characters from a terminal keyboard
proc get_wstr*(wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc getn_wstr*(wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wget_wstr*(win: PWindow, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wgetn_wstr*(win: PWindow, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvget_wstr*(y,x: cint, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvgetn_wstr*(y,x: cint, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwget_wstr*(win: PWindow, y,x: cint, wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwgetn_wstr*(win: PWindow, y,x: cint, wstr: WideCString, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#legacy: get cursor and window coordinates, attributes
proc getattrs*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getbegx*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getbegy*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getcurx*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getcury*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getmaxx*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getmaxy*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getparx*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc getpary*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}

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
proc getcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: ptr attr_t, color_pair: ptr cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc setcchar*(wcval: ptr cchar_t, wch: WideCString, attrs: attr_t, color_pair: cshort, opts: pointer): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#getch: get (or push back) characters from the terminal keyboard
proc getch*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Read a character from the stdscr window.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetch*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Read a character from the specified window.
  ## @Param: 'sourceWindow' the window to read a character from.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvgetch*(y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwgetch*(win: PWindow, y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc ungetch*(ch: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc has_key*(ch: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#mouse: mouse interface
proc has_mouse*(): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc getmouse*(event: ptr Mevent): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc ungetmouse*(event: ptr Mevent): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mousemask*(newmask: mmask_t, oldmask: ptr mmask_t): mmask_t {.cdecl, importc, discardable, dynlib: libncurses.}
proc wenclose*(win: PWindow, y, x: cint): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc mouse_trafo*(y,x: ptr cint, to_screen: bool): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc wmouse_trafo*(win: PWindow, y,x: ptr cint, to_screen: bool): bool {.cdecl, importc, discardable, dynlib: libncurses.}
proc mouseinterval*(erval: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#getstr: accept character strings from terminal keyboard
proc getstr*(str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Reads the inputted characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Returns: ERR on failure and OK upon successful completion.
proc getnstr*(str: cstring; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Reads at most the specified number of characters into the provided string.
  ## @Param: 'inputString' the variable to read the input into.
  ## @Param: 'numberOfCharacters' the maximum number of characters to read.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wgetstr*(win: PWindow, str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wgetnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvgetstr*(y,x: cint, str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvgetnstr*(y,x: cint, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwgetstr*(win: PWindow, y,x: cint, str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwgetnstr*(win: PWindow, y,x: cint, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#in_wch: extract a complex character and rendition from a window
proc in_wch*(wcval: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinwch*(y,x: cint, wcval: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwin_wch*(win: PWindow, y,x: cint, wcval: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc win_wch*(win: PWindow, wcval: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#in_wchstr: get an array of complex characters and renditions from a window
proc in_wchstr*(wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc in_wchnstr*(wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc win_wchstr*(win: PWindow, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc win_wchnstr*(win: PWindow, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvin_wchstr*(y,x: cint, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvin_wchnstr*(y,x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwin_wchstr*(win: PWindow, y,x: cint, wchstr: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwin_wchnstr*(win: PWindow; y,x: cint, wchstr: ptr cchar_t, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#inch: get a character and attributes from a window
proc inch*(): chtype {.cdecl, importc, discardable, dynlib: libncurses.}
proc winch*(win: PWindow): chtype {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinch*(y,x: cint): chtype {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinch*(win: PWindow; y,x: cint): chtype {.cdecl, importc, discardable, dynlib: libncurses.}

#inchstr: get a string of characters (and attributes) from a window
proc inchstr*(chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc inchnstr*(chstr: ptr chtype; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winchstr*(win: PWindow; chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winchnstr*(win: PWindow; chstr: ptr chtype; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinchstr*(y,x: cint; chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinchnstr*(y,x: cint; chstr: ptr chtype; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinchstr*(win: PWindow, y,x: cint; chstr: ptr chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinchnstr*(win: PWindow, y,x: cint; chstr: ptr chtype; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#instr: get a string of characters from a window
proc instr*(str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc innstr*(str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winstr*(win: PWindow, str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winnstr*(win: PWindow, str: cstring, n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinstr*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinnstr*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinstr*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinnstr*(): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#inwstr: get a string of wchar_t characters from a window
proc inwstr*(wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc innwstr*(wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winwstr*(win: PWindow; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winnwstr*(win: PWindow; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinwstr*(y,x: cint; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinnwstr*(y,x: cint; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinwstr*(win: PWindow; y,x: cint; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinnwstr*(win: PWindow; y,x: cint; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#ins_wstr: insert a wide-character string into a window
proc ins_wstr*(wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc ins_nwstr*(wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wins_wstr*(win: PWindow; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wins_nwstr*(win: PWindow; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvins_wstr*(y,x: cint; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvins_nwstr*(y,x: cint; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwins_wstr*(win: PWindow; y,x: cint; wstr: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwins_nwstr*(win: PWindow; y,x: cint; wstr: WideCString; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#ins_wch: insert a complex character and rendition into a window
proc ins_wch*(wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wins_wch*(win: PWindow; wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvins_wch*(y,x: cint; wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwins_wch*(win: PWindow; y,x: cint; wch: ptr cchar_t): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#insch: insert a character before cursor in a window
proc insch*(ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
    ## Inserts a character before the cursor in the stdscr.
    ## @Param: 'character' the character to insert.
    ## @Returns: ERR on failure and OK upon successful completion.
proc winsch*(win: PWindow; ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinsch*(y,x: cint; ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinsch*(win: PWindow; y,x: cint; ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#insstr: insert string before cursor in a window
proc insstr*(str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc insnstr*(str: cstring; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winsstr*(win: PWindow; str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc winsnstr*(win: PWindow; str: cstring; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinsstr*(y,x: cint; str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvinsnstr*(y,x: cint; str: cstring; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinsstr*(win: Pwindow; y,x: cint; str: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvwinsnstr*(win: Pwindow; y,x: cint; str: cstring; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#opaque: window properties
#https://invisible-island.net/ncurses/man/curs_opaque.3x.html
proc is_cleared*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in clearok
proc is_idcok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_idcok
proc is_idlok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_idlok
proc is_immedok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_immedok
proc is_keypad*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_keypad
proc is_leaveok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_leaveok
proc is_nodelay*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_nodelay
proc is_notimeout*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_notimeout
proc is_pad*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns TRUE if the window is a pad i.e., created by newpad
proc is_scrollok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_scrollok
proc is_subwin*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns TRUE if the window is a subwindow, i.e., created by subwin
  ## or derwin
proc is_syncok*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the value set in is_syncok
proc wgetparent*(win: PWindow): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the parent WINDOW pointer for subwindows, or NULL for
  ## windows with no parent
proc wgetdelay*(win: PWindow): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the delay timeout as set in wtimeout
proc wgetscrreg*(win: PWindow; top, bottom: cint): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## returns the top and bottom rows for the scrolling margin as set in
  ## wsetscrreg

#touch: refresh control routines
#https://invisible-island.net/ncurses/man/curs_touch.3x.html
proc touchwin*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Throws away all optimization information about which parts of the window
  ## have been touched, by pretending that the entire window has been drawn on.
  ## This is sometimes necessary when using overlapping windows, since a change
  ## to one window affects the other window, but the records of which lines
  ## have been changed in the other window do not reflect the change.
proc touchline*(win: PWindow; start, count: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## The same as touchwin, except it only pretends that count lines have been
  ## changed, beginning with line start.
proc untouchwin*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Marks all lines in the window as unchanged since the last call to wrefresh.
proc wtouchln*(win: PWindow; y, n, changed: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Makes n lines in the window, starting at line y, look as if they have
  ## (changed=1) or have not (changed=0) been changed since the last call to
  ## wrefresh.
proc is_wintouched*(win: PWindow): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Returns TRUE if the specified window was modified since the last call to
  ## wrefresh
proc is_linetouched*(win: PWindow; line: cint): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## The same as is_wintouched, In addition, returns ERR if line is not valid
  ## for the given window.

#resizeterm: change the curses terminal size
#https://invisible-island.net/ncurses/man/resizeterm.3x.html
proc is_term_resized*(lines, columns: cint): bool {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Checks if the resize_term function would modify the window structures.
  ## returns TRUE if the windows would be modified, and FALSE otherwise.
proc resize_term*(lines, columns: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Resizes the standard and current windows to the specified dimensions,
  ## and adjusts other bookkeeping data used by the ncurses library that
  ## record the window dimensions such as the LINES and COLS variables.
proc resize_term_ext*(lines, columns: cint): ErrCode {.cdecl, discardable, dynlib: libncurses, importc: "resize_term".}
  ## Blank-fills the areas that are extended. The calling application should
  ## fill in these areas with appropriate data. The resize_term function
  ## attempts to resize all windows. However, due to the calling convention of
  ## pads, it is not possible to resize these without additional interaction
  ## with the application.

#key_defined: check if a keycode is defined
#https://invisible-island.net/ncurses/man/key_defined.3x.html
proc key_defined*(definition: cstring): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## If the string is bound to a keycode, its value (greater than zero) is
  ## returned. If no keycode is bound, zero is returned. If the string
  ## conflicts with longer strings which are bound to keys, -1 is returned.

#keybound: return definition of keycode
#https://invisible-island.net/ncurses/man/keybound.3x.html
proc keybound*(keycode, count: cint): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
  ## The keycode parameter must be greater than zero, else NULL is returned.
  ## If it does not correspond to a defined key, then NULL is returned. The
  ## count parameter is used to allow the application to iterate through
  ## multiple definitions, counting from zero. When successful, the function
  ## returns a string which must be freed by the caller.

#keyok: enable or disable a keycode
#https://invisible-island.net/ncurses/man/keyok.3x.html
proc keyok(keycode: cint; enable: bool): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## The keycode must be greater than zero, else ERR is returned. If it
  ## does not correspond to a defined key, then ERR is returned. If the
  ## enable parameter is true, then the key must have been disabled, and
  ## vice versa. Otherwise, the function returns OK.

#mcprint: ship binary data to printer
#https://invisible-island.net/ncurses/man/curs_print.3x.html
proc mcprint*(data: cstring; len: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#move: move window cursor
#https://invisible-island.net/ncurses/man/curs_move.3x.html
proc move*(y, x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
  ## Moves the cursor of stdscr to the specified coordinates.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wmove*(win: PWindow; y,x: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#printw: print formatted output in windows
#https://invisible-island.net/ncurses/man/curs_printw.3x.html
proc printw*(fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
  ## Prints out a formatted string to the stdscr.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc wprintw*(win: PWindow, fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc mvprintw*(y, x: cint; fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
  ## Prints out a formatted string to the stdscr at the specified row and column.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc mvwprintw*(win: PWindow; y,x: cint; fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
  ## Prints out a formatted string to the specified window at the specified row and column.
  ## @Param: 'destinationWindow' the window to write the string to.
  ## @Param: 'y' the line to move the cursor to.
  ## @Param: 'x' the column to move the cursor to.
  ## @Param: 'formattedString' the string with formatting to be output to stdscr.
  ## @Returns: ERR on failure and OK upon successful completion.
proc vw_printw*(win: PWindow; fmt: cstring; varglist: varargs[cstring]): ErrCode {.cdecl, importc, discardable, dynlib: libncurses}

#scanw: convert formatted input from a window
#https://invisible-island.net/ncurses/man/curs_scanw.3x.html
proc scanw*(fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
  ## Converts formatted input from the stdscr.
  ## @Param: 'formattedInput' Contains the fields for the input to be mapped to.
  ## @Returns: The number of fields that were mapped in the call.
proc wscanw*(win: PWindow; fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
proc mvscanw*(y,x: cint; fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
proc mvwscanw*(win: PWindow; y,x: cint; fmt: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs.}
proc vw_scanw*(win: PWindow; fmt: cstring; varglist: varargs[cstring]): ErrCode {.cdecl, importc, discardable, dynlib: libncurses, varargs,.}

#pad: create and display pads
#https://invisible-island.net/ncurses/man/curs_pad.3x.html
proc newpad*(nlines, ncols: cint): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc subpad*(orig: PWindow; lines, columns, begin_y, begin_x: cint): PWindow {.cdecl, importc, discardable, dynlib: libncurses.}
proc prefresh*(pad: PWindow;
  pminrow, pmincol,
  sminrow, smincol,
  smaxrow, smaxcol: cint
): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc pnoutrefersh*(pad: PWindow;
  pminrow, pmincol,
  sminrow, smincol,
  smaxrow, smaxcol: cint
): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc pechochar*(pad: PWindow; ch: chtype): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc pecho_wchar*(pad: PWindow; wch: WideCString): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#scr_dump: read (write) a screen from (to) a file
#https://invisible-island.net/ncurses/man/curs_scr_dump.3x.html
proc scr_dump*(filename: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc scr_restore*(filename: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc scr_init*(filename: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc scr_set*(filename: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#scroll: scroll a window
#https://invisible-island.net/ncurses/man/curs_scroll.3x.html
proc scroll*(win: PWindow): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc scrl*(n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc wscrl*(win: PWindow; n: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#termcap: direct interface to the terminfo capability database
#https://invisible-island.net/ncurses/man/curs_termcap.3x.html
var
  PC* {.importc, dynlib: libncurses.}: cchar
  UP* {.importc, dynlib: libncurses.}: ptr cchar
  BC* {.importc, dynlib: libncurses.}: ptr cchar
  ospeed* {.importc, dynlib: libncurses.}: cshort
proc tgetent*(np, name: cstring): cint {.cdecl, importc, discardable, dynlib: libncurses.}
proc tgetflag*(id: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tgetnum*(id: cstring): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}
proc tgetstr*(id: cstring; area: cstringArray ): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc tgoto*(cap: cstring; col, row: cint): cstring {.cdecl, importc, discardable, dynlib: libncurses.}
proc tputs*(str: cstring; affcnt: cint; putc: ptr proc(ch: cint): cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

#legacy_coding: override locale-encoding checks
#https://invisible-island.net/ncurses/man/legacy_coding.3x.html
proc use_legacy_coding*(level: cint): cint {.cdecl, importc, discardable, dynlib: libncurses.}
  ## If  the  screen has not been initialized, or the level parameter is out
  ## of range, the function returns ERR. Otherwise, it returns the previous
  ## level: 0, 1 or 2.

#wresize: resize a curses window
#https://invisible-island.net/ncurses/man/wresize.3x.html
proc wresize*(win: PWindow; line, column: cint): ErrCode {.cdecl, importc, discardable, dynlib: libncurses.}

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
