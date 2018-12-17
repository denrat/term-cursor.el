;;; term-cursor.el --- Change cursor shape in terminal -*- coding: utf-8; -*-

;; Version: 0.2
;; Author: h0d
;; URL: https://github.com/h0d
;; Keywords: terminals
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; Send escape codes to change cursor in terminal.
;; Using VT520 DECSCUSR
;; from https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

;;; Code:

(defgroup 'term-cursor nil
  "Group for term-cursor."
  :group 'terminals
  :prefix 'term-cursor-)

;;;###autoload
(define-minor-mode term-cursor-mode
  "Minor mode for term-cursor."
  :group 'term-cursor
  (if term-cursor-mode (term-cursor-watch)
    (term-cursor-unwatch)))

(defun term-cursor-watcher (_symbol val op _watch)
  "Change cursor through escape sequences depending on VAL.
Waits for OP to be 'set."
  (unless (display-graphic-p)
    (when (eq op 'set)
      (cond
       ;; Symbol ('box, 'hollow, 'bar, 'hbar)
       ((eq (type-of val) 'symbol)
	(cond ((eq val 'bar)
	       (send-string-to-terminal "\e[5 q"))
	      ((eq val 'hbar)
	       (send-string-to-terminal "\e[3 q"))
	      (t
	       (send-string-to-terminal "\e[1 q"))))
       ;; Cons ((bar . WIDTH), (hbar . HEIGHT))
       ((eq (type-of val) 'cons)
	(cond ((eq (car val) 'bar)
	       (send-string-to-terminal "\e[5 q"))
	      ((eq (car val) 'hbar)
	       (send-string-to-terminal "\e[3 q"))
	      (t
	       (send-string-to-terminal "\e[1 q"))))
       ;; Anything else
       (t
	(send-string-to-terminal "\e[1 q"))))))

(defun term-cursor-watch ()
  "Start watching cursor change."
  (interactive)
  (add-variable-watcher 'cursor-type #'term-cursor-watcher))

(defun term-cursor-unwatch ()
  "Start watching cursor change."
  (interactive)
  (remove-variable-watcher 'cursor-type #'term-cursor-watcher))

(provide 'term-cursor)

;;; term-cursor.el ends here
