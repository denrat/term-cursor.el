;;; term-cursor.el --- Change cursor shape in terminal -*- lexical-binding: t; coding: utf-8; -*-

;; Version: 0.4
;; Author: h0d
;; URL: https://github.com/h0d
;; Keywords: terminals
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; Send terminal escape codes to change cursor shape in TTY Emacs.
;; Using VT520 DECSCUSR (cf https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).
;; Does not interfere with GUI Emacs behavior.

;;; Code:

(defgroup term-cursor nil
  "Group for term-cursor."
  :group 'terminals
  :prefix 'term-cursor-)

;; Define escape codes for different cursors
(defcustom term-cursor-block-blinking "\e[1 q"
  "The escape code sent to terminal to set the cursor as a blinking box."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-block-steady "\e[2 q"
  "The escape code sent to terminal to set the cursor as a steady box."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-underline-blinking "\e[3 q"
  "The escape code sent to terminal to set the cursor as a blinking underscore."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-underline-steady "\e[4 q"
  "The escape code sent to terminal to set the cursor as a steady underscore."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-bar-blinking "\e[5 q"
  "The escape code sent to terminal to set the cursor as a blinking bar."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-bar-steady "\e[6 q"
  "The escape code sent to terminal to set the cursor as a steady bar."
  :type 'string
  :group 'term-cursor)

;; Current cursor evaluation
(defcustom term-cursor-triggers (list 'blink-cursor-mode-hook 'lsp-ui-doc-frame-hook)
  "Hooks to add when the variable watcher might not be enough.
That is, hooks to trigger `term-cursor--immediate'."
  :type 'list
  :group 'term-cursor)

;;;###autoload
(define-minor-mode term-cursor-mode
  "Minor mode for term-cursor."
  :group 'term-cursor
  (if term-cursor-mode
      (term-cursor-watch)
    ;; else
    (term-cursor-unwatch)))

;;;###autoload
(define-globalized-minor-mode global-term-cursor-mode term-cursor-mode
  (lambda ()
    (term-cursor-mode t))
  :group 'term-cursor)

(defun term-cursor--normalize (cursor)
  "Return the actual value of CURSOR.
It can sometimes be a `cons' from which we only want the first element (cf `cursor-type')."
  (if (consp cursor)
      (car cursor)
    ;; else
    cursor))

(defun term-cursor--determine-esc (cursor blink)
  "Return an escape code depending on the CURSOR and whether it should BLINK."
  (cond (;; Vertical bar
	 (eq cursor 'bar)
	 (if blink term-cursor-bar-blinking
	   term-cursor-bar-steady))
	(;; Underscore
	 (eq cursor 'hbar)
	 (if blink term-cursor-underline-blinking
	   term-cursor-underline-steady))
	(;; Box — default value
	 t
	 (if blink term-cursor-block-blinking
	   term-cursor-block-steady))))

(defun term-cursor--eval (cursor blink)
  "Send escape code to terminal according to CURSOR and whether it should BLINK."
  (unless (display-graphic-p) ; Must be in TTY
    ;; CURSOR can be a `cons' (cf. `cursor-type')
    (setq cursor
	  (term-cursor--normalize cursor))

    ;; Ask terminal to display new cursor
    (send-string-to-terminal
     (term-cursor--determine-esc cursor blink))))

(defun term-cursor--immediate ()
  "Send an escape code without waiting for `term-cursor-watcher'."
  (term-cursor--eval cursor-type blink-cursor-mode))

(defun term-cursor-watcher (_symbol cursor operation _watch)
  "Change cursor shape through escape sequences depending on CURSOR.
Waits for OPERATION to be 'set."
  (when (eq operation 'set)  ; A new value must be set to the variable
    (term-cursor--eval cursor blink-cursor-mode)))

(defun term-cursor-watch ()
  "Start reacting to cursor change."
  (add-variable-watcher 'cursor-type #'term-cursor-watcher)
  (dolist (hook term-cursor-triggers)
    (add-hook hook #'term-cursor--immediate)))

(defun term-cursor-unwatch ()
  "Stop reacting to cursor change."
  (remove-variable-watcher 'cursor-type #'term-cursor-watcher)
  (dolist (hook term-cursor-triggers)
    (remove-hook hook #'term-cursor--immediate)))

(provide 'term-cursor)

;;; term-cursor.el ends here
