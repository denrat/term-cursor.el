# term-cursor.el
Change Emacs cursor in terminal, with or without `evil-mode`.
Requires Emacs > 26.

## Compliance
For now, only VT520-compliant terminals are supported. Contribution is welcome.

Tested in kitty, iTerm2, Alacritty and Terminal.app (macOS Mojave).

## Installation
- Using `quelpa`
```elisp
(quelpa '(term-cursor :repo "h0d/term-cursor.el" :fetcher github))
```
- Manual
```elisp
;; Once `term-cursor.el' has been added to load path
(require 'term-cursor)
```

## Usage
```elisp
(term-cursor-mode)
```

## Disclaimer
As the project goes further, probably supporting more terminals, breaking changes may occur.
