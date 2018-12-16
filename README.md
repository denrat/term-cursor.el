# term-cursor.el
Change Emacs cursor in terminal, with or without `evil-mode`.
Requires Emacs > 26.

## Compliance
For now, only VT520-compliant terminals are supported. Contribution is welcome.

## Usage
```elisp
;; Turn on watcher
(term-cursor-watch)

;; Turn off watcher
(term-cursor-unwatch)
```

## Disclaimer
As the project goes further, probably supporting more terminals, breaking changes may occur.
