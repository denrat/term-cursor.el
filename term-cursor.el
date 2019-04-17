;;; term-cursor.el --- Change cursor shape in terminal -*- lexical-binding: t; coding: utf-8; -*-

;; Version: 0.3
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

;;;###autoload
(define-minor-mode term-cursor-mode
  "Minor mode for term-cursor."
  :group 'term-cursor
  (if term-cursor-mode
      (term-cursor-watch)
    (term-cursor-unwatch)))

;;;###autoload
(define-globalized-minor-mode global-term-cursor-mode term-cursor-mode
  (lambda ()
    (term-cursor-mode t))
  :group 'term-cursor)

;; (add-hook 'lsp-ui-doc-frame-hook #'term-cursor--eval)

(defun term-cursor--eval (&optional cursor)
  "Send escape code to terminal according to the value of `cursor-type'.
If not supplied, CURSOR will be automatically set to `cursor-type'."
  (unless (display-graphic-p)		; Must be in TTY
    ;; Get the cursor when not supplied by the watcher
    (unless cursor
      (setq cursor cursor-type))
    ;; CURSOR can be a `cons' (cf. `C-h v cursor-type')
    ;; In that case, extract actual cursor type
    (when (consp cursor)
      (setq cursor (car cursor)))

    ;; Compare values and send corresponding escape code
    (cond (;; Vertical bar
	   (eq cursor 'bar)
	   (send-string-to-terminal term-cursor-bar-steady))
	  (;; Underscore
	   (eq cursor 'hbar)
	   (send-string-to-terminal term-cursor-underline-steady))
	  (;; Box — default value
	   t
	   (send-string-to-terminal term-cursor-block-steady)))))

(defun term-cursor-watcher (_symbol cursor operation _watch)
  "Change cursor shape through escape sequences depending on CURSOR.
Waits for OPERATION to be 'set."
  ;; FIXME: investigate cursor being changed unexpectedly (e.g. with lsp-ui & js)
  (unless (not (eq operation 'set))  ; A new value must be set to the variable
    (term-cursor--eval cursor)))

(defun term-cursor-watch ()
  "Start watching cursor change."
  (add-variable-watcher 'cursor-type #'term-cursor-watcher))

(defun term-cursor-unwatch ()
  "Stop watching cursor change."
  (remove-variable-watcher 'cursor-type #'term-cursor-watcher))

(provide 'term-cursor)

;;; term-cursor.el ends here
