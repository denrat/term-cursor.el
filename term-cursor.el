;;; term-cursor.el --- Change cursor shape in terminal -*- lexical-binding: t; coding: utf-8; -*-

;; Version: 0.4
;; Author: h0d
;; URL: https://github.com/h0d
;; Keywords: terminals
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; Change cursor shape in TTY Emacs according to what it would be in the GUI.
;; Send specific escape sequences to terminal emulator to trigger this cursor shape change.

;; Using VT520 DECSCUSR (cf https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).
;; Does not rely on `evil-mode' or any other dependency.
;; Does not interfere with GUI Emacs behavior.

;;; Code:

(defgroup term-cursor nil
  "Group for term-cursor."
  :group 'terminals
  :prefix 'term-cursor-)


;;; Escape codes sets
;;; -----------------
;; VT520
(defconst term-cursor-esc-vt520
  '((block-steady       . "\e[1 q")
    (block-blinking     . "\e[2 q")
    (underline-steady   . "\e[3 q")
    (underline-blinking . "\e[4 q")
    (bar-steady         . "\e[5 q")
    (bar-blinking       . "\e[6 q"))
  "Escape sequences for VT520 terminal emulators."
  :group 'term-cursor)

;; Customize
(defcustom term-cursor-esc-set
  term-cursor-esc-vt520
  "Default escape sequences set to use."
  :type '(alist :key-type symbol :value-type string)
  :group 'term-cursor)


;;; Individual escape codes
;;; -----------------------
;; Define escape codes for different cursors
(defcustom term-cursor-block-blinking
  (alist-get 'block-blinking term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a blinking box."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-block-steady
  (alist-get 'block-steady term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a steady box."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-underline-blinking
  (alist-get 'underline-blinking term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a blinking underscore."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-underline-steady
  (alist-get 'underline-steady term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a steady underscore."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-bar-blinking
  (alist-get 'bar-blinking term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a blinking bar."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-bar-steady
  (alist-get 'bar-steady term-cursor-esc-set)
  "The escape code sent to terminal to set the cursor as a steady bar."
  :type 'string
  :group 'term-cursor)

(defcustom term-cursor-default 'block-steady
  "Cursor type to use by default when `cursor-type' isn't properly set."
  :type 'symbol
  :options '(block-blinking
	     block-steady
	     underline-blinking
	     underline-steady
	     bar-blinking
	     bar-steady)
  :group 'term-cursor)


;;; `term-cursor--immediate' triggers
;;; ---------------------------------
;; Hook-based cursor evaluation
(defcustom term-cursor-triggers
  '('blink-cursor-mode-hook
    'focus-in-hook
    'focus-out-hook
    'lsp-ui-doc-frame-hook)
  "Hooks to add when the variable watcher might not be enough.
That is, hooks calling `term-cursor--immediate'."
  :type '(list :type symbol)
  :group 'term-cursor)

(defcustom term-cursor-watchables
  '(cursor-type)
  ;; TODO: merge `term-cursor--immediate' and `term-cursor--eval'
  "Variables to watch for change, calling `term-cursor--eval'."
  :type '(list :type symbol)
  :group 'term-cursor)


;;; Modes
;;; -----
;;;###autoload
(define-minor-mode term-cursor-mode
  "Minor mode for term-cursor."
  :group 'term-cursor
  (if term-cursor-mode
      (term-cursor--watch)
    ;; else
    (term-cursor--unwatch)))

;;;###autoload
(define-globalized-minor-mode global-term-cursor-mode term-cursor-mode
  (lambda ()
    (term-cursor-mode t))
  :group 'term-cursor)


;;; Data manipulation and conversion
;;; --------------------------------
(defun term-cursor--normalize (cursor)
  "Return the actual value of CURSOR.
It can sometimes be a `cons' from which we only want the first element (cf `cursor-type')."
  (if (consp cursor)
      (car cursor)
    ;; else
    cursor))

(defun term-cursor--determine-esc (cursor blink)
  "Return an escape code depending on the CURSOR and whether it should BLINK."
  (cond
   (;; Vertical bar
    (eq cursor 'bar)
    (if blink term-cursor-bar-blinking
      term-cursor-bar-steady))
   (;; Underscore
    (eq cursor 'hbar)
    (if blink term-cursor-underline-blinking
      term-cursor-underline-steady))
   (;; Box
    (eq cursor 'box)
    (if blink term-cursor-block-blinking
      term-cursor-block-steady))
   (;; Default value
    t
    term-cursor-default)))

(defun term-cursor--eval (cursor blink)
  "Send escape code to terminal according to CURSOR and whether it should BLINK.
Determine an escape sequence according to "
  ;; Must be in TTY
  (unless (display-graphic-p)
    (let*
	(;; CURSOR can be a `cons' (cf `cursor-type')
	 (cursor (term-cursor--normalize cursor))

	 ;; Determine the escape code according to the cursor
	 (escape-code
	  (cond (;; Vertical bar
		 (eq cursor 'bar)
		 (if blink term-cursor-bar-blinking
		   term-cursor-bar-steady))
		(;; Underscore
		 (eq cursor 'hbar)
		 (if blink term-cursor-underline-blinking
		   term-cursor-underline-steady))
		(;; Box
		 (eq cursor 'box)
		 (if blink term-cursor-block-blinking
		   term-cursor-block-steady))
		(;; Default value
		 t
		 term-cursor-default))))

      ;; Ask terminal to display new cursor
      (send-string-to-terminal escape-code))))

(defun term-cursor--immediate ()
  "Send an escape code without waiting for `term-cursor--watcher'."
  (term-cursor--eval cursor-type blink-cursor-mode))


;;; Watcher logic
;;; -------------
(defun term-cursor--watcher (_symbol cursor operation _watch)
  "Call `term-cursor--eval' as a result of a variable change.
Change cursor shape through escape sequences depending on CURSOR.
Waits for OPERATION to be 'set."
  (when (eq operation 'set)  ; A new value must be set to the variable
    (term-cursor--eval cursor blink-cursor-mode)))

(defun term-cursor--watch ()
  "Start reacting to `cursor-type' change."
  ;; Add watchers
  (dolist (var term-cursor-watchables)
    (add-variable-watcher var #'term-cursor--watcher))
  ;; Add hooks
  (dolist (hook term-cursor-triggers)
    (add-hook hook #'term-cursor--immediate)))

(defun term-cursor--unwatch ()
  "Stop reacting to `cursor-type' change."
  ;; Remove watchers
  (dolist (var term-cursor-watchables)
    (remove-variable-watcher var #'term-cursor--watcher))
  ;; Remove hooks
  (dolist (hook term-cursor-triggers)
    (remove-hook hook #'term-cursor--immediate)))


(provide 'term-cursor)

;;; term-cursor.el ends here
