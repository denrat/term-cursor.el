# term-cursor.el
Display Emacs cursor in terminal as it would be in GUI, with or without `evil-mode`.

Requires Emacs 26.

## Compliance
For now, only VT520-compliant terminals are supported. Contribution is welcome.

Tested in kitty, iTerm2, Alacritty and Terminal.app on macOS Mojave.

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
;; In a buffer
(term-cursor-mode)

;; For all buffers
(global-term-cursor-mode)
```
