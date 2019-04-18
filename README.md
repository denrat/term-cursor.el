# term-cursor.el
Display Emacs cursor in terminal as it would be in GUI, with or without `evil-mode`.

Requires Emacs 26.

## Compliance
For now, only VT520-compliant terminals are supported out of the box. You can still use [your own escape codes](#my-terminal-is-not-supported).

Tested in kitty, iTerm2, Alacritty and Terminal.app on macOS Mojave.
Contribution is welcome.

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

MELPA pending.

## Usage
```elisp
;; In a buffer
(term-cursor-mode)

;; For all buffers
(global-term-cursor-mode)
```

## My terminal is not supported
If you know the escape codes for your terminal, you can specify them in your configuration or through `M-x customize`.

```elisp
(setq term-cursor-bar-escape-code        "<your escape code>")
(setq term-cursor-underline-escape-code  "<your escape code>")
(setq term-cursor-block-escape-code      "<your escape code>")
```
