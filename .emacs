; Per Karlsson - emacs bindings

; If on a mac keyboard, remember to se env EMACS_COMMAND_AS_META to 1
; i.e. export EMACS_COMMAND_AS_META=1 in bash

;################################################################
;#                PERSONAL CUSTOMIZATION
;################################################################

; treat .h files as c++
(setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))

; skip startup screen, 
; show where in buffer you are
; selection highlighting
(custom-set-variables
 '(inhibit-startup-screen t)
 '(size-indication-mode t)
 '(transient-mark-mode (quote (only . t))))

; Colorize matching paranthesis
(show-paren-mode 1)

; show current column
(setq column-number-mode t)

; Always show line-numbers
(global-linum-mode 1)

;; no overwrite mode (insert key)
(put 'overwrite-mode 'disabled t)

; Disable the toolbar
(tool-bar-mode -1)
(menu-bar-mode -1)

;; F3/F4 toggles toolbar
(global-set-key [f4] 'tool-bar-mode)
(global-set-key [f3] 'menu-bar-mode)

;; do not make backup files
(setq make-backup-files nil)

;;bind F5 to compile
(global-set-key [(C-f5)] 'compile)
(global-set-key [(f5)] 'recompile)

; line spacing
(setq-default line-spacing 3)

; enforce scroll bar to the right
(set-scroll-bar-mode 'right)

; tab width always 4 spaces
(setq-default tab-width 4)

;; Keep position when scrolling
(setq scroll-preserve-screen-position t)

; Show absolute path in window title
(setq frame-title-format
  '( (:eval (if (buffer-file-name)
                (abbreviate-file-name (buffer-file-name))
                "%b")) " [%*]"))

;;Will create a compiling.. window below the two active windows
(defun my-compilation-hook ()
  (interactive) 
  (when (not (get-buffer-window "*compilation*"))
    (save-selected-window
      (save-excursion
        (setq old-buffer (window-buffer (windmove-right)))
        (windmove-left)
        (delete-other-windows)
        (let* (     
               (w (split-window-vertically))
               (h (window-height w))
               (c (split-window-horizontally)))

          (select-window c)
          (switch-to-buffer old-buffer)
          (select-window w)
          (switch-to-buffer "*compilation*")
          (shrink-window (- h 30))
          )))))
(add-hook 'compilation-mode-hook 'my-compilation-hook)

; compile command
(setq compile-command "make")

;; startup size
(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 70))

;; if two files are open, split
(defun 2-windows-vertical-to-horizontal ()
  (let ((buffers (mapcar 'window-buffer (window-list))))
    (when (= 2 (length buffers))
      (delete-other-windows)
      (set-frame-width (selected-frame) 172)
      (add-to-list 'default-frame-alist '(width . 172))
      (set-window-buffer (split-window-horizontally) (cadr buffers)))))
(add-hook 'emacs-startup-hook '2-windows-vertical-to-horizontal)

;################################################################
;;#                 GOOGLE  C/C++ style for  c-mode;
;################################################################

;; google-c-style.el is Copyright (C) 2008 Google Inc. All Rights Reserved.
;;
;; It is free software; you can redistribute it and/or modify it under the
;; terms of either:
;;
;; a) the GNU General Public License as published by the Free Software
;; Foundation; either version 1, or (at your option) any later version, or
;;
;; b) the "Artistic License".

;;; Code:

;; For some reason 1) c-backward-syntactic-ws is a macro and 2)  under Emacs 22
;; bytecode cannot call (unexpanded) macros at run time:
(eval-when-compile (require 'cc-defs))

;; Wrapper function needed for Emacs 21 and XEmacs (Emacs 22 offers the more
;; elegant solution of composing a list of lineup functions or quantities with
;; operators such as "add")
(defun google-c-lineup-expression-plus-4 (langelem)
  "Indents to the beginning of the current C expression plus 4 spaces.

This implements title \"Function Declarations and Definitions\" of the Google
C++ Style Guide for the case where the previous line ends with an open
parenthese.

\"Current C expression\", as per the Google Style Guide and as clarified by
subsequent discussions,
means the whole expression regardless of the number of nested parentheses, but
excluding non-expression material such as \"if(\" and \"for(\" control
structures.

Suitable for inclusion in `c-offsets-alist'."
  (save-excursion
    (back-to-indentation)
    ;; Go to beginning of *previous* line:
    (c-backward-syntactic-ws)
    (back-to-indentation)
    ;; We are making a reasonable assumption that if there is a control
    ;; structure to indent past, it has to be at the beginning of the line.
    (if (looking-at "\\(\\(if\\|for\\|while\\)\\s *(\\)")
        (goto-char (match-end 1)))
    (vector (+ 4 (current-column)))))
        
(defconst google-c-style
  `((c-recognize-knr-p . nil)
    (c-enable-xemacs-performance-kludge-p . t) ; speed up indentation in XEmacs
    (c-basic-offset . 4)
    (indent-tabs-mode . nil)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist . ((defun-open after)
                               (defun-close before after)
                               (class-open after)
                               (class-close before after)
                               (namespace-open after)
                               (inline-open after)
                               (inline-close before after)
                               (block-open after)
                               (block-close . c-snug-do-while)
                               (extern-lang-open after)
                               (extern-lang-close after)
                               (statement-case-open after)
                               (substatement-open after)))
    (c-hanging-colons-alist . ((case-label)
                               (label after)
                               (access-label after)
                               (member-init-intro before)
                               (inher-intro)))
    (c-hanging-semi&comma-criteria
     . (c-semi&comma-no-newlines-for-oneline-inliners
        c-semi&comma-inside-parenlist
        c-semi&comma-no-newlines-before-nonblanks))
    (c-indent-comments-syntactically-p . nil)
    (comment-column . 40)
    (c-cleanup-list . (brace-else-brace
                       brace-elseif-brace
                       brace-catch-brace
                       empty-defun-braces
                       defun-close-semi
                       list-close-comma
                       scope-operator))
    (c-offsets-alist . ((arglist-intro google-c-lineup-expression-plus-4)
                        (func-decl-cont . ++)
                        (member-init-intro . ++)
                        (inher-intro . ++)
                        (comment-intro . 0)
                        (arglist-close . c-lineup-arglist)
                        (topmost-intro . 0)
                        (block-open . 0)
                        (inline-open . 0)
                        (substatement-open . 0)
                        (statement-cont
                         .
                         (,(when (fboundp 'c-no-indent-after-java-annotations)
                             'c-no-indent-after-java-annotations)
                          ,(when (fboundp 'c-lineup-assignments)
                             'c-lineup-assignments)
                          ++))
                        (label . /)
                        (case-label . +)
                        (statement-case-open . +)
                        (statement-case-intro . +) ; case w/o {
                        (access-label . /)
                        (innamespace . 0))))
  "Google C/C++ Programming Style")

(defun google-set-c-style ()
  "Set the current buffer's c-style to Google C/C++ Programming
  Style. Meant to be added to `c-mode-common-hook'."
  (interactive)
  (make-local-variable 'c-tab-always-indent)
  (setq c-tab-always-indent t)
  (c-add-style "Google" google-c-style t))

(defun google-make-newline-indent ()
  "Sets up preferred newline behavior. Not set by default. Meant
  to be added to `c-mode-common-hook'."
  (interactive)
  (define-key c-mode-base-map "\C-m" 'newline-and-indent)
  (define-key c-mode-base-map [ret] 'newline-and-indent))

(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;################################################################
;#                 ERGO EMACS (key bindings)
;###############################################################

;-*- coding: utf-8 -*-

(require 'redo "redo.elc" t) ; for redo shortcut

(delete-selection-mode 1) ; turn on text selection highlighting and make typing override selected text (Note: when delete-selection-mode is on, then transient-mark-mode is automatically on too.)

(defun print-buffer-confirm ()
  "Print current buffer, but ask for confirmation first."
  (interactive)
  (when
      (y-or-n-p "Print current buffer?")
    (print-buffer)
    )
  )

(defun call-keyword-completion ()
  "Call the command that has keyboard shortcut M-TAB."
  (interactive)
  (call-interactively (key-binding (kbd "M-TAB")))
)

(defun describe-major-mode ()
  "Show inline doc for current major-mode."
  ;; code by Kevin Rodgers. 2009-02-25
  (interactive)
  (describe-function major-mode))

(defun copy-all ()
  "Put the whole buffer content into the kill-ring.
If narrow-to-region is in effect, then copy that region only."
  (interactive)
  (kill-new (buffer-string))
  (message "Buffer content copied copy-region-as-kill")
  )

(defun cut-all ()
  "Cut the whole buffer content into the kill-ring.
If narrow-to-region is in effect, then cut that region only."
  (interactive)
  (kill-region (point-min) (point-max))
  (message "Buffer content cut")
  )

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (message "Current line is copied.")
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))

(defadvice kill-region (before slick-copy activate compile)
  "When called interactively with no active region, cut the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))

;;; TEXT SELECTION RELATED

(defun select-text-in-quote ()
  "Select text between the nearest left and right delimiters.
Delimiters are paired characters:
 () [] {} «» ‹› “” 〖〗 【】 「」 『』 （） 〈〉 《》 〔〕 ⦗⦘ 〘〙

For practical purposes, it also includes double straight quote
\", but not curly single quote matching pairs ‘’, because that is
often used as apostrophy. It also consider both left and right
angle brackets <> as either beginning or ending pair, so that it
is easy to get content inside html tags."
 (interactive)
 (let (b1 b2)
   (skip-chars-backward "^<>([{“「『‹«（〈《〔【〖⦗〘\"")
   (setq b1 (point))
   (skip-chars-forward "^<>)]}”」』›»）〉》〕】〗⦘〙\"")
   (setq b2 (point))
   (set-mark b1)
   )
 )

;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun semnav-up (arg)
  (interactive "p")
  (when (nth 3 (syntax-ppss))
    (if (> arg 0)
        (progn
          (skip-syntax-forward "^\"")
          (goto-char (1+ (point)))
          (decf arg))
      (skip-syntax-backward "^\"")
      (goto-char (1- (point)))
      (incf arg)))
  (up-list arg))

;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun extend-selection (arg &optional incremental)
  "Select the current word.
Subsequent calls expands the selection to larger semantic unit."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (or (and transient-mark-mode mark-active)
                         (eq last-command this-command))))
  (if incremental
      (progn
        (semnav-up (- arg))
        (forward-sexp)
        (mark-sexp -1))
    (if (> arg 1)
        (extend-selection (1- arg) t)
      (if (looking-at "\\=\\(\\s_\\|\\sw\\)*\\_>")
          (goto-char (match-end 0))
        (unless (memq (char-before) '(?\) ?\"))
          (forward-sexp)))
      (mark-sexp -1))))

;;; TEXT TRANSFORMATION RELATED

(defun kill-line-backward ()
  "Kill text between the beginning of the line to the cursor position.
If there's no text, delete the previous line ending."
  (interactive)
  (if (looking-back "\n")
      (delete-char -1)
    (kill-line 0)
    )
  )

(defun move-cursor-next-pane ()
  "Move cursor to the next pane."
  (interactive)
  (other-window 1)
  )

(defun move-cursor-previous-pane ()
  "Move cursor to the previous pane."
  (interactive)
  (other-window -1)
  )

(defun compact-uncompact-block ()
  "Remove or add line endings on the current block of text.
This is similar to a toggle for fill-paragraph and unfill-paragraph
When there is a text selection, act on the region.

When in text mode, a paragraph is considerd a block. When in programing
language mode, the block is defined by between empty lines.

Todo: The programing language behavior is currently not done.
Right now, the code uses fill* functions, so does not work or work well
in programing lang modes. A proper implementation to compact is replacing
EOL chars by space when the EOL char is not inside string."
  (interactive)

  ;; This command symbol has a property “'stateIsCompact-p”, the
  ;; possible values are t and nil. This property is used to easily
  ;; determine whether to compact or uncompact, when this command is
  ;; called again

  (let (bds currentLineCharCount currentStateIsCompact
            (bigFillColumnVal 4333999) (deactivate-mark nil))

    (save-excursion
      ;; currentLineCharCount is used to determine whether current state
      ;; is compact or not, when the command is run for the first time
      (setq currentLineCharCount
            (progn
              (setq bds (bounds-of-thing-at-point 'line))
              (length (buffer-substring-no-properties (car bds) (cdr bds)))    
              ;; Note: 'line includes eol if it is not buffer's last line
              )
            )

      ;; Determine whether the text is currently compact.  when the last
      ;; command is this, then symbol property easily tells, but when
      ;; this command is used fresh, right now we use num of chars of
      ;; the cursor line as a way to define current compatness state
      (setq currentStateIsCompact
            (if (eq last-command this-command)
                (get this-command 'stateIsCompact-p)
              (if (> currentLineCharCount fill-column) t nil)
              )
            )

      (if (and transient-mark-mode mark-active)
          (if currentStateIsCompact
              (fill-region (region-beginning) (region-end))
            (let ((fill-column bigFillColumnVal))
              (fill-region (region-beginning) (region-end)))
            )
        (if currentStateIsCompact
            (fill-paragraph nil)
          (let ((fill-column bigFillColumnVal))
            (fill-paragraph nil))
          )
        )

      (put this-command 'stateIsCompact-p (if currentStateIsCompact
                                              nil t)) ) ) )

(defun shrink-whitespaces ()
  "Remove white spaces around cursor to just one or none.
If current line does not contain non-white space chars, then remove blank lines to just one.
If current line contains non-white space chars, then shrink any whitespace char surrounding cursor to just one space.
If current line is a single space, remove that space.

Calling this command 3 times will always result in no whitespaces around cursor."
  (interactive)
  (let (
        cursor-point
        line-has-meat-p  ; current line contains non-white space chars
        spaceTabNeighbor-p
        whitespace-begin whitespace-end
        space-or-tab-begin space-or-tab-end
        line-begin-pos line-end-pos
        )
    (save-excursion
      ;; todo: might consider whitespace as defined by syntax table, and also consider whitespace chars in unicode if syntax table doesn't already considered it.
      (setq cursor-point (point))

      (setq spaceTabNeighbor-p (if (or (looking-at " \\|\t") (looking-back " \\|\t")) t nil) )
      (move-beginning-of-line 1) (setq line-begin-pos (point) )
      (move-end-of-line 1) (setq line-end-pos (point) )
      ;;       (re-search-backward "\n$") (setq line-begin-pos (point) )
      ;;       (re-search-forward "\n$") (setq line-end-pos (point) )
      (setq line-has-meat-p (if (< 0 (count-matches "[[:graph:]]" line-begin-pos line-end-pos)) t nil) )
      (goto-char cursor-point)

      (skip-chars-backward "\t ")
      (setq space-or-tab-begin (point))

      (skip-chars-backward "\t \n")
      (setq whitespace-begin (point))

      (goto-char cursor-point)      (skip-chars-forward "\t ")
      (setq space-or-tab-end (point))
      (skip-chars-forward "\t \n")
      (setq whitespace-end (point))
      )

    (if line-has-meat-p
        (let (deleted-text)
          (when spaceTabNeighbor-p
            ;; remove all whitespaces in the range
            (setq deleted-text (delete-and-extract-region space-or-tab-begin space-or-tab-end))
            ;; insert a whitespace only if we have removed something
            ;; different that a simple whitespace
            (if (not (string= deleted-text " "))
                (insert " ") ) ) )

      (progn
        ;; (delete-region whitespace-begin whitespace-end)
        ;; (insert "\n")
        (delete-blank-lines)
        )
      ;; todo: possibly code my own delete-blank-lines here for better efficiency, because delete-blank-lines seems complex.
      )
    )
  )

(defun toggle-letter-case ()
  "Toggle the letter case of current word or text selection.
Toggles from 3 cases: UPPER CASE, lower case, Title Case,
in that cyclic order."
(interactive)
(let (pos1 pos2 (deactivate-mark nil) (case-fold-search nil))
  (if (and transient-mark-mode mark-active)
      (setq pos1 (region-beginning)
            pos2 (region-end))
    (setq pos1 (car (bounds-of-thing-at-point 'word))
          pos2 (cdr (bounds-of-thing-at-point 'word))))

  (when (not (eq last-command this-command))
    (save-excursion
      (goto-char pos1)
      (cond
       ((looking-at "[[:lower:]][[:lower:]]") (put this-command 'state "all lower"))
       ((looking-at "[[:upper:]][[:upper:]]") (put this-command 'state "all caps") )
       ((looking-at "[[:upper:]][[:lower:]]") (put this-command 'state "init caps") )
       (t (put this-command 'state "all lower") )
       )
      )
    )

  (cond
   ((string= "all lower" (get this-command 'state))
    (upcase-initials-region pos1 pos2) (put this-command 'state "init caps"))
   ((string= "init caps" (get this-command 'state))
    (upcase-region pos1 pos2) (put this-command 'state "all caps"))
   ((string= "all caps" (get this-command 'state))
    (downcase-region pos1 pos2) (put this-command 'state "all lower"))
   )
)
)

;;; FRAME

(defun switch-to-next-frame ()
  "Select the next frame on current display, and raise it."
  (interactive)
  (other-frame 1)
  )

(defun switch-to-previous-frame ()
  "Select the previous frame on current display, and raise it."
  (interactive)
  (other-frame -1)
  )

;;; BUFFER RELATED

(defun next-user-buffer ()
  "Switch to the next user buffer.
User buffers are those whose name does not start with *."
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (and (string-match "^*" (buffer-name)) (< i 50))
      (setq i (1+ i)) (next-buffer) )))

(defun previous-user-buffer ()
  "Switch to the previous user buffer.
User buffers are those whose name does not start with *."
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (and (string-match "^*" (buffer-name)) (< i 50))
      (setq i (1+ i)) (previous-buffer) )))

(defun next-emacs-buffer ()
  "Switch to the next emacs buffer.
Emacs buffers are those whose name starts with *."
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (and (not (string-match "^*" (buffer-name))) (< i 50))
      (setq i (1+ i)) (next-buffer) )))

(defun previous-emacs-buffer ()
  "Switch to the previous emacs buffer.
Emacs buffers are those whose name starts with *."
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (and (not (string-match "^*" (buffer-name))) (< i 50))
      (setq i (1+ i)) (previous-buffer) )))

(defun new-empty-buffer ()
  "Opens a new empty buffer."
  (interactive)
  (let ((buf (generate-new-buffer "untitled")))
    (switch-to-buffer buf)
    (funcall (and initial-major-mode))
    (setq buffer-offer-save t)))
;; note: emacs won't offer to save a buffer that's
;; not associated with a file,
;; even if buffer-modified-p is true.
;; One work around is to define your own my-kill-buffer function
;; that wraps around kill-buffer, and check on the buffer modification
;; status to offer save
;; This custome kill buffer is close-current-buffer.

(defun open-in-desktop ()
  "Open the current file in desktop.
Works in Microsoft Windows and Mac OS X."
  (interactive)
  (cond
   ((string-equal system-type "windows-nt")
    (w32-shell-execute "explore"
                       (replace-regexp-in-string "/" "\\" default-directory t t)))
   ((string-equal system-type "darwin") (shell-command "open ."))
   ((string-equal system-type "gnu/linux") (shell-command "xdg-open ."))
   ) )

(defvar recently-closed-buffers (cons nil nil) "A list of recently closed buffers. The max number to track is controlled by the variable recently-closed-buffers-max.")
(defvar recently-closed-buffers-max 10 "The maximum length for recently-closed-buffers.")

(defun close-current-buffer ()
"Close the current buffer.

Similar to (kill-buffer (current-buffer)) with the following addition:

• prompt user to save if the buffer has been modified even if the buffer is not associated with a file.
• make sure the buffer shown after closing is a user buffer.
• if the buffer is a file, add the path to the list recently-closed-buffers.

A emacs buffer is one who's name starts with *.
Else it is a user buffer."
 (interactive)
 (let (emacsBuff-p isEmacsBufferAfter)
   (if (string-match "^*" (buffer-name))
       (setq emacsBuff-p t)
     (setq emacsBuff-p nil))

   ;; offer to save buffers that are non-empty and modified, even for non-file visiting buffer. (because kill-buffer does not offer to save buffers that are not associated with files)
   (when (and (buffer-modified-p)
              (not emacsBuff-p)
              (not (string-equal major-mode "dired-mode"))
              (if (equal (buffer-file-name) nil) 
                  (if (string-equal "" (save-restriction (widen) (buffer-string))) nil t)
                t
                )
              )
     (if (y-or-n-p
            (concat "Buffer " (buffer-name) " modified; Do you want to save?"))
       (save-buffer)
       (set-buffer-modified-p nil)))

   ;; save to a list of closed buffer
   (when (not (equal buffer-file-name nil))
     (setq recently-closed-buffers
           (cons (cons (buffer-name) (buffer-file-name)) recently-closed-buffers))
     (when (> (length recently-closed-buffers) recently-closed-buffers-max)
           (setq recently-closed-buffers (butlast recently-closed-buffers 1))
           )
     )

   ;; close
   (kill-buffer (current-buffer))

   ;; if emacs buffer, switch to a user buffer
   (if (string-match "^*" (buffer-name))
       (setq isEmacsBufferAfter t)
     (setq isEmacsBufferAfter nil))
   (when isEmacsBufferAfter
     (next-user-buffer)
     )
   )
 )

(defun open-last-closed ()
  "Open the last closed file."
  (interactive)
  (find-file (cdr (pop recently-closed-buffers)) ) )

;-*- coding: utf-8 -*-

;; this file define keys that we want to set/unset because they are already defined by ergoemacs minor mode

(require 'edmacro)

(defconst ergoemacs-redundant-keys
  '( "C-/"
     "C-0"
     "C-1"
     "C-2"
     "C-3"
     "C-4"
     "C-5"
     "C-6"
     "C-7"
     "C-8"
     "C-9"
     "C-<next>"
     "C-<prior>"
     "C-@"
     "C-M-%"
     "C-_"
     "C-a"
     "C-b"
     "C-d"
     "C-e"
     "C-f"
     "C-j"
     "C-k"
     "C-l"
     "C-n"
     "C-o"
     "C-p"
     "C-r"
     "C-s"
     "C-t"
     "C-v"
     "C-w"
     "C-x 0"
     "C-x 1"
     "C-x 2"
     "C-x 3"
     "C-x 5 0"
     "C-x 5 2"
     "C-x C-d"
     "C-x C-f"
     "C-x C-s"
     "C-x C-w"
     "C-x d"
     "C-x h"
     "C-x o"
     "C-y"
     "C-z"
     "M--"
     "M-0"
     "M-1"
     "M-2"
     "M-3"
     "M-4"
     "M-5"
     "M-6"
     "M-7"
     "M-8"
     "M-9"
     "M-<"
     "M->"
     "M-@"
     "M-\\"
     "M-a"
     "M-b"
     "M-c"
     "M-d"
     "M-e"
     "M-f"
     "M-h"
     "M-i"
     "M-j"
     "M-k"
     "M-l"
     "M-m"
     "M-n"
     "M-o"
     "M-p"
     "M-q"
     "M-r"
     "M-s"
     "M-t"
     "M-u"
     "M-v"
     "M-w"
     "M-x"
     "M-y"
     "M-z"
     "M-{"
     "M-}"
     )
  )

;; Some exceptions we don't want to unset.
;; "C-g" 'keyboard-quit
;; "C-i" 'indent-for-tab-command
;; "C-m" 'newline-and-indent
;; "C-q" 'quote-insert
;; "C-u" 'universal-argument
;; "C-h" ; (help-map)
;; "C-x" ; (ctl-x-map)
;; "C-c" ; (prefix)
;; "M-g" ; (prefix)

(defvar ergoemacs-overridden-global-keys '()
  "Alist to store overridden keyboard shortcuts in
  `current-global-map' and other maps. Each item looks like '(MAP KEY OLD-COMMAND).")

(defun ergoemacs-unset-global-key (map key-s)
  "Sets to nil the associated command for the specified key in specified map.
It is like:

  \(define-key map (kbd key-s) nil))

But it saves the old command associated with the
specified key, so we can restore it when ergoemacs minor mode is
disabled at `ergoemacs-restore-global-keys'."
  (let (key oldcmd)
    (setq key (edmacro-parse-keys key-s))
    ;; get the old command associated with this key
    (setq oldcmd (lookup-key map key))
    ;; save that shortcut in ergoemacs-overridden-global-keys
    (if oldcmd
	(add-to-list 'ergoemacs-overridden-global-keys (cons map (cons key-s (cons oldcmd nil)))))
    ;; redefine the key in the ergoemacs-keymap
    (define-key map key nil)
    )
  )

(defun ergoemacs-unset-redundant-global-keys ()
  "Unsets redundant keyboard shortcuts that should not be used in ErgoEmacs."
  (mapc (lambda (x)
	  (ergoemacs-unset-global-key (current-global-map) x))
	ergoemacs-redundant-keys)
  )

(defun ergoemacs-restore-global-keys ()
  "Restores all keyboard shortcuts that were overwritten by `ergoemacs-unbind-global-key'."
  (mapc (lambda (x)
	  (define-key
	    (car x)
	    (edmacro-parse-keys (car (cdr x)))
	    (car (cdr (cdr x))))
	  )
	ergoemacs-overridden-global-keys)
  (setq ergoemacs-overridden-global-keys '()) ; clear the list
  )

;; Based on describe-key-briefly
(defun where-is-old-binding (&optional key)
  "Print the name of the function KEY invoked before to start ErgoEmacs minor mode."
  (interactive
   (let ((enable-disabled-menus-and-buttons t)
	 (cursor-in-echo-area t)
	 saved-yank-menu)
     (unwind-protect
	 (let (key)
	   ;; If yank-menu is empty, populate it temporarily, so that
	   ;; "Select and Paste" menu can generate a complete event.
	   (when (null (cdr yank-menu))
	     (setq saved-yank-menu (copy-sequence yank-menu))
	     (menu-bar-update-yank-menu "(any string)" nil))
	   (setq key (read-key-sequence "Describe old key (or click or menu item): "))
	   ;; If KEY is a down-event, read and discard the
	   ;; corresponding up-event.  Note that there are also
	   ;; down-events on scroll bars and mode lines: the actual
	   ;; event then is in the second element of the vector.
	   (and (vectorp key)
		(let ((last-idx (1- (length key))))
		  (and (eventp (aref key last-idx))
		       (memq 'down (event-modifiers (aref key last-idx)))))
		(read-event))
	   (list key))
       ;; Put yank-menu back as it was, if we changed it.
       (when saved-yank-menu
	 (setq yank-menu (copy-sequence saved-yank-menu))
	 (fset 'yank-menu (cons 'keymap yank-menu))))))

  (let (key-desc item-key item-cmd old-cmd)
    (setq key-desc (key-description key))
    (setq item ergoemacs-overridden-global-keys)
    (while (and item (not old-cmd))
      (setq item-key (car (cdr (car item))))
      (setq item-cmd (car (cdr (cdr (car item)))))
      (if (string= item-key key-desc)
	  (setq old-cmd item-cmd))
      (setq item (cdr item))
      )
    (if old-cmd
	(with-temp-buffer
	  (where-is old-cmd t)
	  (message "Key %s was bound to %s which is now invoked by %s"
		   key-desc old-cmd (buffer-string))
	  )
      (message "Key %s was not bound to any command" key-desc)
      )
    )
  )

;-*- coding: utf-8 -*-
;; Shortcuts for ERGOEMACS_KEYBOARD_LAYOUT=us
;; Keyboard Layout: United States
;; Contributor: David Capello, Xah Lee
;; Creation date: 2009

;;; --------------------------------------------------
;;; CURSOR MOVEMENTS

;; Single char cursor movement
(defconst ergoemacs-backward-char-key			(kbd "M-j"))
(defconst ergoemacs-forward-char-key			(kbd "M-l"))
(defconst ergoemacs-previous-line-key			(kbd "M-i"))
(defconst ergoemacs-next-line-key			(kbd "M-k"))

;; Move by word
(defconst ergoemacs-backward-word-key			(kbd "M-J"))
(defconst ergoemacs-forward-word-key			(kbd "M-L"))

;; Move by paragraph
(defconst ergoemacs-backward-paragraph-key		(kbd "M-U"))
(defconst ergoemacs-forward-paragraph-key		(kbd "M-O"))

;; Move to beginning/ending of line
(defconst ergoemacs-move-beginning-of-line-key		(kbd "M-u"))
(defconst ergoemacs-move-end-of-line-key		(kbd "M-o"))

;; Move by screen (page up/down)
(defconst ergoemacs-scroll-down-key			(kbd "M-I"))
(defconst ergoemacs-scroll-up-key			(kbd "M-K"))

;; Move to beginning/ending of file
(defconst ergoemacs-beginning-of-buffer-key		(kbd "M-U"))
(defconst ergoemacs-end-of-buffer-key			(kbd "M-O"))

;; isearch
(defconst ergoemacs-isearch-forward-key			(kbd "M-s"))
(defconst ergoemacs-isearch-backward-key		(kbd "M-S"))

(defconst ergoemacs-recenter-key			(kbd "M-p"))

;;; MAJOR EDITING COMMANDS

;; Delete previous/next char.
(defconst ergoemacs-delete-backward-char-key		(kbd "M-d"))
(defconst ergoemacs-delete-char-key			(kbd "M-f"))

; Delete previous/next word.
(defconst ergoemacs-backward-kill-word-key		(kbd "M-D"))
(defconst ergoemacs-kill-word-key			(kbd "M-F"))

; Copy Cut Paste, Paste previous
(defconst ergoemacs-kill-region-key			(kbd "M-x"))
(defconst ergoemacs-kill-ring-save-key			(kbd "M-c"))
(defconst ergoemacs-yank-key				(kbd "M-v"))
(defconst ergoemacs-yank-pop-key			(kbd "M-V"))
(defconst ergoemacs-copy-all-key			(kbd "M-C"))
(defconst ergoemacs-cut-all-key				(kbd "M-X"))

;; undo and redo
(defconst ergoemacs-redo-key				(kbd "M-Z"))
(defconst ergoemacs-undo-key				(kbd "M-z"))

; Kill line
(defconst ergoemacs-kill-line-key			(kbd "M-e"))
(defconst ergoemacs-kill-line-backward-key (kbd "M-E"))

;;; Textual Transformation

(defconst ergoemacs-mark-paragraph-key			(kbd "M-S-SPC"))
(defconst ergoemacs-shrink-whitespaces-key		(kbd "M-w"))
(defconst ergoemacs-comment-dwim-key			(kbd "M-'"))
(defconst ergoemacs-toggle-letter-case-key		(kbd "M-/"))

; keyword completion, because Alt+Tab is used by OS
(defconst ergoemacs-call-keyword-completion-key		(kbd "M-t"))

; Hard-wrap/un-hard-wrap paragraph
(defconst ergoemacs-compact-uncompact-block-key		(kbd "M-q"))

;;; EMACS'S SPECIAL COMMANDS

; Cancel
(defconst ergoemacs-keyboard-quit-key			(kbd "M-g"))

; Mark point.
(defconst ergoemacs-set-mark-command-key		(kbd "M-SPC"))

(defconst ergoemacs-execute-extended-command-key        (kbd "M-a"))
(defconst ergoemacs-shell-command-key			(kbd "M-A"))

;;; WINDOW SPLITING
(defconst ergoemacs-move-cursor-next-pane-key		(kbd "M-;"))
(defconst ergoemacs-move-cursor-previous-pane-key	(kbd "M-:"))

;;; --------------------------------------------------
;;; OTHER SHORTCUTS

(defconst ergoemacs-switch-to-previous-frame-key        (kbd "M-~"))
(defconst ergoemacs-switch-to-next-frame-key            (kbd "M-`"))

(defconst ergoemacs-query-replace-key                   (kbd "M-5"))
(defconst ergoemacs-query-replace-regexp-key            (kbd "M-%"))

(defconst ergoemacs-delete-other-windows-key            (kbd "M-1"))
(defconst ergoemacs-delete-window-key                   (kbd "M-0"))

(defconst ergoemacs-split-window-vertically-key         (kbd "M-4"))
(defconst ergoemacs-split-window-horizontally-key       (kbd "M-2"))

(defconst ergoemacs-extend-selection-key                (kbd "M-8"))
(defconst ergoemacs-select-text-in-quote-key            (kbd "M-*"))

;;; --------------------------------------------------
;;; ergoemacs-keymap

(defvar ergoemacs-keymap (make-sparse-keymap)
  "ErgoEmacs minor mode keymap.")

;; Single char cursor movement
(define-key ergoemacs-keymap ergoemacs-backward-char-key 'backward-char)
(define-key ergoemacs-keymap ergoemacs-forward-char-key 'forward-char)
(define-key ergoemacs-keymap ergoemacs-previous-line-key 'previous-line)
(define-key ergoemacs-keymap ergoemacs-next-line-key 'next-line)

;; Move by word
(define-key ergoemacs-keymap ergoemacs-backward-word-key 'backward-word)
(define-key ergoemacs-keymap ergoemacs-forward-word-key 'forward-word)

;; Move by paragraph
(define-key ergoemacs-keymap ergoemacs-backward-paragraph-key 'backward-paragraph)
(define-key ergoemacs-keymap ergoemacs-forward-paragraph-key 'forward-paragraph)

;; Move to beginning/ending of line
(define-key ergoemacs-keymap ergoemacs-move-beginning-of-line-key 'move-beginning-of-line)
(define-key ergoemacs-keymap ergoemacs-move-end-of-line-key 'move-end-of-line)

;; Move by screen (page up/down)
(define-key ergoemacs-keymap ergoemacs-scroll-down-key 'scroll-down)
(define-key ergoemacs-keymap ergoemacs-scroll-up-key 'scroll-up)

;; Move to beginning/ending of file
(define-key ergoemacs-keymap ergoemacs-beginning-of-buffer-key 'beginning-of-buffer)
(define-key ergoemacs-keymap ergoemacs-end-of-buffer-key 'end-of-buffer)

;; isearch
(define-key ergoemacs-keymap ergoemacs-isearch-forward-key 'isearch-forward)
(define-key ergoemacs-keymap ergoemacs-isearch-backward-key 'isearch-backward)

(define-key ergoemacs-keymap ergoemacs-recenter-key 'recenter-top-bottom)

;;; MAJOR EDITING COMMANDS

;; Delete previous/next char.
(define-key ergoemacs-keymap ergoemacs-delete-backward-char-key 'delete-backward-char)
(define-key ergoemacs-keymap ergoemacs-delete-char-key 'delete-char)

; Delete previous/next word.
(define-key ergoemacs-keymap ergoemacs-backward-kill-word-key 'backward-kill-word)
(define-key ergoemacs-keymap ergoemacs-kill-word-key 'kill-word)

; Copy Cut Paste, Paste previous
(define-key ergoemacs-keymap ergoemacs-kill-region-key 'kill-region)
(define-key ergoemacs-keymap ergoemacs-kill-ring-save-key 'kill-ring-save)
(define-key ergoemacs-keymap ergoemacs-yank-key 'yank)
(define-key ergoemacs-keymap ergoemacs-yank-pop-key 'yank-pop)
(define-key ergoemacs-keymap ergoemacs-copy-all-key 'copy-all)
(define-key ergoemacs-keymap ergoemacs-cut-all-key 'cut-all)

;; undo and redo
(define-key ergoemacs-keymap ergoemacs-redo-key 'redo)
(define-key ergoemacs-keymap ergoemacs-undo-key 'undo)

; Kill line
(define-key ergoemacs-keymap ergoemacs-kill-line-key 'kill-line)
(define-key ergoemacs-keymap ergoemacs-kill-line-backward-key 'kill-line-backward)

;;; Textual Transformation

(define-key ergoemacs-keymap ergoemacs-mark-paragraph-key 'mark-paragraph)
(define-key ergoemacs-keymap ergoemacs-shrink-whitespaces-key 'shrink-whitespaces)
(define-key ergoemacs-keymap ergoemacs-comment-dwim-key 'comment-dwim)
(define-key ergoemacs-keymap ergoemacs-toggle-letter-case-key 'toggle-letter-case)

; keyword completion, because Alt+Tab is used by OS
(define-key ergoemacs-keymap ergoemacs-call-keyword-completion-key 'call-keyword-completion)

; Hard-wrap/un-hard-wrap paragraph
(define-key ergoemacs-keymap ergoemacs-compact-uncompact-block-key 'compact-uncompact-block)

;;; EMACS'S SPECIAL COMMANDS

; Cancel
(define-key ergoemacs-keymap ergoemacs-keyboard-quit-key 'keyboard-quit)

; Mark point.
(define-key ergoemacs-keymap ergoemacs-set-mark-command-key 'set-mark-command)

(define-key ergoemacs-keymap ergoemacs-execute-extended-command-key 'execute-extended-command)
(define-key ergoemacs-keymap ergoemacs-shell-command-key 'shell-command)

;;; WINDOW SPLITING
(define-key ergoemacs-keymap ergoemacs-move-cursor-next-pane-key 'move-cursor-next-pane)
(define-key ergoemacs-keymap ergoemacs-move-cursor-previous-pane-key 'move-cursor-previous-pane)

;;; --------------------------------------------------
;;; STANDARD SHORTCUTS

(define-key ergoemacs-keymap (kbd "C-n") 'new-empty-buffer)
(define-key ergoemacs-keymap (kbd "C-S-n") 'make-frame-command)
(define-key ergoemacs-keymap (kbd "C-o") 'find-file)
(define-key ergoemacs-keymap (kbd "C-S-o") 'open-in-desktop)
(define-key ergoemacs-keymap (kbd "C-S-t") 'open-last-closed)
(define-key ergoemacs-keymap (kbd "C-w") 'close-current-buffer)
(define-key ergoemacs-keymap (kbd "C-s") 'save-buffer)
(define-key ergoemacs-keymap (kbd "C-S-s") 'write-file)
(define-key ergoemacs-keymap (kbd "C-a") 'mark-whole-buffer)
(define-key ergoemacs-keymap (kbd "C-S-w") 'delete-frame)

(define-key ergoemacs-keymap (kbd "C-f") 'search-forward)

(define-key ergoemacs-keymap (kbd "<delete>") 'delete-char) ; the Del key for forward delete. Needed if C-d is set to nil.

(define-key ergoemacs-keymap (kbd "C-<prior>") 'previous-user-buffer)
(define-key ergoemacs-keymap (kbd "C-<next>") 'next-user-buffer)

(define-key ergoemacs-keymap (kbd "C-S-<prior>") 'previous-emacs-buffer)
(define-key ergoemacs-keymap (kbd "C-S-<next>") 'next-emacs-buffer)

(define-key ergoemacs-keymap (kbd "M-S-<prior>") 'backward-page)
(define-key ergoemacs-keymap (kbd "M-S-<next>") 'forward-page)

(define-key ergoemacs-keymap (kbd "C-x C-b") 'ibuffer)
(define-key ergoemacs-keymap (kbd "C-h m") 'describe-major-mode)
(define-key ergoemacs-keymap (kbd "C-h o") 'where-is-old-binding)

;; Ctrl+Break is a common IDE shortcut to stop compilation/find/grep
(define-key ergoemacs-keymap (kbd "C-<pause>") 'kill-compilation)

;;; --------------------------------------------------
;;; OTHER SHORTCUTS

(define-key ergoemacs-keymap ergoemacs-switch-to-previous-frame-key 'switch-to-previous-frame)
(define-key ergoemacs-keymap ergoemacs-switch-to-next-frame-key 'switch-to-next-frame)

(define-key ergoemacs-keymap ergoemacs-query-replace-key 'query-replace)
(define-key ergoemacs-keymap ergoemacs-query-replace-regexp-key 'query-replace-regexp)

(define-key ergoemacs-keymap ergoemacs-delete-other-windows-key 'delete-other-windows)
(define-key ergoemacs-keymap ergoemacs-delete-window-key 'delete-window)

(define-key ergoemacs-keymap ergoemacs-split-window-vertically-key 'split-window-vertically)
(define-key ergoemacs-keymap ergoemacs-split-window-horizontally-key 'split-window-horizontally)

(define-key ergoemacs-keymap ergoemacs-extend-selection-key 'extend-selection)
(define-key ergoemacs-keymap ergoemacs-select-text-in-quote-key 'select-text-in-quote)

;;----------------------------------------------------------------------
;; CUA fix

(let (cuaModeState cua-mode)
(cua-mode 1) ; turn on cua-mode first so the command ergoemacs-fix-cua--pre-command-handler-1 will be able to set some symbols from cua-mode

(defun ergoemacs-fix-cua--pre-command-handler-1 ()
  "Fixes CUA minor mode so selection is highlighted only when
Shift+<special key> is used (arrows keys, home, end, pgdn, pgup, etc.)."
 (defun cua--pre-command-handler-1 ()
  ;; Cancel prefix key timeout if user enters another key.
  (when cua--prefix-override-timer
    (if (timerp cua--prefix-override-timer)
        (cancel-timer cua--prefix-override-timer))
    (setq cua--prefix-override-timer nil))

  (cond
   ;; Only symbol commands can have necessary properties
   ((not (symbolp this-command))
    nil)

   ;; Handle delete-selection property on non-movement commands
   ((not (eq (get this-command 'CUA) 'move))
    (when (and mark-active (not deactivate-mark))
      (let* ((ds (or (get this-command 'delete-selection)
                     (get this-command 'pending-delete)))
             (nc (cond
                  ((not ds) nil)
                  ((eq ds 'yank)
                   'cua-paste)
                  ((eq ds 'kill)
                   (if cua--rectangle
                       'cua-copy-rectangle
                     'cua-copy-region))
                  ((eq ds 'supersede)
                   (if cua--rectangle
                       'cua-delete-rectangle
                     'cua-delete-region))
                  (t
                   (if cua--rectangle
                       'cua-delete-rectangle ;; replace?
                     'cua-replace-region)))))
        (if nc
            (setq this-original-command this-command
                  this-command nc)))))

   ;; Handle shifted cursor keys and other movement commands.
   ;; If region is not active, region is activated if key is shifted.
   ;; If region is active, region is cancelled if key is unshifted
   ;;   (and region not started with C-SPC).
   ;; If rectangle is active, expand rectangle in specified direction and
   ;;   ignore the movement.
   ((if window-system
        ;; Shortcut for window-system, assuming that input-decode-map is empty.

        ;; ErgoEmacs patch begin ------------------
        ;;;; (memq 'shift (event-modifiers
        ;;;;               (aref (this-single-command-raw-keys) 0)))
        (and (memq 'shift (event-modifiers
                           (aref (this-single-command-raw-keys) 0)))
             ;; In this way, we expect to use CUA only with keys that
             ;; are symbols (like <left>, <next>, etc.)
             (symbolp (event-basic-type (aref (this-single-command-raw-keys) 0))))
        ;; ErgoEmacs patch end --------------------

      (or
       ;; Check if the final key-sequence was shifted.
       (memq 'shift (event-modifiers
                     (aref (this-single-command-keys) 0)))
       ;; If not, maybe the raw key-sequence was mapped by input-decode-map
       ;; to a shifted key (and then mapped down to its unshifted form).
       (let* ((keys (this-single-command-raw-keys))
              (ev (lookup-key input-decode-map keys)))
         (or (and (vector ev) (memq 'shift (event-modifiers (aref ev 0))))
             ;; Or maybe, the raw key-sequence was not an escape sequence
             ;; and was shifted (and then mapped down to its unshifted form).
             (memq 'shift (event-modifiers (aref keys 0)))))))
    (unless mark-active
      (push-mark-command nil t))
    (setq cua--last-region-shifted t)
    (setq cua--explicit-region-start nil))

   ;; Set mark if user explicitly said to do so
   ((or cua--explicit-region-start cua--rectangle)
    (unless mark-active
      (push-mark-command nil nil)))

   ;; Else clear mark after this command.
   (t
    ;; If we set mark-active to nil here, the region highlight will not be
    ;; removed by the direct_output_ commands.
    (setq deactivate-mark t)))

  ;; Detect extension of rectangles by mouse or other movement
  (setq cua--buffer-and-point-before-command
        (if cua--rectangle (cons (current-buffer) (point)))))
 )
(if cuaModeState (cua-mode 1) (cua-mode 0))
  )

;;----------------------------------------------------------------------
;; ErgoEmacs hooks

(defun ergoemacs-minibuffer-setup-hook ()
  "Hook for minibuffer to move through history with previous-line and next-line keys."

  (defvar ergoemacs-minibuffer-keymap (copy-keymap ergoemacs-keymap))

  (define-key ergoemacs-minibuffer-keymap ergoemacs-keyboard-quit-key 'minibuffer-keyboard-quit)
  (define-key ergoemacs-minibuffer-keymap ergoemacs-previous-line-key 'previous-history-element)
  (define-key ergoemacs-minibuffer-keymap ergoemacs-next-line-key 'next-history-element)

  (define-key ergoemacs-minibuffer-keymap (kbd "<f11>") 'previous-history-element)
  (define-key ergoemacs-minibuffer-keymap (kbd "<f12>") 'next-history-element)
  (define-key ergoemacs-minibuffer-keymap (kbd "S-<f11>") 'previous-matching-history-element)
  (define-key ergoemacs-minibuffer-keymap (kbd "S-<f12>") 'next-matching-history-element)

  ;; The ergoemacs-mode keymap could already be in the minor-mode-overriding map
  ;; (e.g. iswitchb or ido hooks were executed)
  (add-to-list 'minor-mode-overriding-map-alist (cons 'ergoemacs-mode ergoemacs-minibuffer-keymap)
	       nil (lambda (x y)
		     (equal (car y) (car x))))
  )

(defun ergoemacs-isearch-hook ()
  "Hook for `isearch-mode-hook' so ergoemacs keybindings are not lost."

  ;; TODO restore these keys! (it is not necessary, when the
  ;; ergoemacs-isearch-hook is removed from isearch-mode-hook)

  (define-key isearch-mode-map (kbd "M-p") 'nil) ; was isearch-ring-retreat
  (define-key isearch-mode-map (kbd "M-n") 'nil) ; was isearch-ring-advance
  (define-key isearch-mode-map (kbd "M-y") 'nil) ; was isearch-yank-kill
  (define-key isearch-mode-map (kbd "M-c") 'nil) ; was isearch-toggle-case-fold
  (define-key isearch-mode-map (kbd "M-r") 'nil) ; was isearch-toggle-regexp
  (define-key isearch-mode-map (kbd "M-e") 'nil) ; was isearch-edit-string

  (define-key isearch-mode-map ergoemacs-keyboard-quit-key 'isearch-abort)
  (define-key isearch-mode-map ergoemacs-isearch-forward-key 'isearch-repeat-forward)
  (define-key isearch-mode-map ergoemacs-isearch-backward-key 'isearch-repeat-backward)
  (define-key isearch-mode-map ergoemacs-recenter-key 'recenter)
  (define-key isearch-mode-map ergoemacs-yank-key 'isearch-yank-kill)

  ;; CUA paste key is isearch-yank-kill in isearch mode
  (define-key isearch-mode-map (kbd "C-v") 'isearch-yank-kill)

  ;; isearch-other-control-char sends the key to the original buffer and cancels isearch
  (define-key isearch-mode-map ergoemacs-kill-ring-save-key 'isearch-other-control-char)
  (define-key isearch-mode-map ergoemacs-kill-word-key 'isearch-other-control-char)
  (define-key isearch-mode-map ergoemacs-backward-kill-word-key 'isearch-other-control-char)

  (define-key isearch-mode-map (kbd "<f11>") 'isearch-ring-retreat)
  (define-key isearch-mode-map (kbd "<f12>") 'isearch-ring-advance)
  )

;; Hook for interpreters
(defun ergoemacs-comint-hook ()
  "Hook for `comint-mode-hook'."

  (define-key comint-mode-map (kbd "<f11>") 'comint-previous-input)
  (define-key comint-mode-map (kbd "<f12>") 'comint-next-input)
  (define-key comint-mode-map (kbd "S-<f11>") 'comint-previous-matching-input)
  (define-key comint-mode-map (kbd "S-<f12>") 'comint-next-matching-input)
  )

;; Log edit mode
(defun ergoemacs-log-edit-hook ()
  "Hook for `log-edit-mode-hook'."

  (define-key log-edit-mode-map (kbd "<f11>") 'log-edit-previous-comment)
  (define-key log-edit-mode-map (kbd "<f12>") 'log-edit-next-comment)
  (define-key log-edit-mode-map (kbd "S-<f11>") 'log-edit-previous-comment)
  (define-key log-edit-mode-map (kbd "S-<f12>") 'log-edit-next-comment)
  )

(defun ergoemacs-eshell-hook ()
  "Hook for `eshell-mode-hook', to redefine some ErgoEmacs keys so they are more useful."

  ;; Redefining ergoemacs-move-beginning-of-line-key to eshell-bol in eshell-mode-map
  ;; does not work, we have to use minor-mode-overriding-map-alist in this case
  (defvar ergoemacs-eshell-keymap (copy-keymap ergoemacs-keymap))

  (define-key ergoemacs-eshell-keymap ergoemacs-move-beginning-of-line-key 'eshell-bol)
  (define-key ergoemacs-eshell-keymap (kbd "<home>") 'eshell-bol)
  (define-key ergoemacs-eshell-keymap (kbd "<f11>") 'eshell-previous-matching-input-from-input)
  (define-key ergoemacs-eshell-keymap (kbd "<f12>") 'eshell-next-matching-input-from-input)
  (define-key ergoemacs-eshell-keymap (kbd "S-<f11>") 'eshell-previous-matching-input-from-input)
  (define-key ergoemacs-eshell-keymap (kbd "S-<f12>") 'eshell-next-matching-input-from-input)

  (add-to-list 'minor-mode-overriding-map-alist (cons 'ergoemacs-mode ergoemacs-eshell-keymap))
  )

(defun ergoemacs-iswitchb-hook ()
  "Hooks for `iswitchb-minibuffer-setup-hook'."

  (defvar ergoemacs-iswitchb-keymap (copy-keymap ergoemacs-keymap))

  (define-key ergoemacs-iswitchb-keymap ergoemacs-keyboard-quit-key 'minibuffer-keyboard-quit)
  (define-key ergoemacs-iswitchb-keymap ergoemacs-isearch-backward-key 'iswitchb-prev-match)
  (define-key ergoemacs-iswitchb-keymap ergoemacs-isearch-forward-key 'iswitchb-next-match)

  (define-key ergoemacs-iswitchb-keymap (kbd "<f11>") 'iswitchb-prev-match)
  (define-key ergoemacs-iswitchb-keymap (kbd "<f12>") 'iswitchb-next-match)
  (define-key ergoemacs-iswitchb-keymap (kbd "S-<f11>") 'iswitchb-prev-match)
  (define-key ergoemacs-iswitchb-keymap (kbd "S-<f12>") 'iswitchb-next-match)

  (add-to-list 'minor-mode-overriding-map-alist (cons 'ergoemacs-mode ergoemacs-iswitchb-keymap))
  )

(defun ergoemacs-ido-minibuffer-setup-hook ()
  "Hook for `ido-minibuffer-setup-hook'."

  (defvar ergoemacs-ido-keymap (copy-keymap ergoemacs-keymap))

  (define-key ergoemacs-ido-keymap ergoemacs-keyboard-quit-key 'minibuffer-keyboard-quit)
  (define-key ergoemacs-ido-keymap ergoemacs-forward-char-key 'ido-next-match)
  (define-key ergoemacs-ido-keymap ergoemacs-backward-char-key 'ido-prev-match)
  (define-key ergoemacs-ido-keymap ergoemacs-previous-line-key 'ido-next-match-dir)
  (define-key ergoemacs-ido-keymap ergoemacs-next-line-key 'ido-prev-match-dir)

  (define-key ergoemacs-ido-keymap (kbd "<f11>") 'previous-history-element)
  (define-key ergoemacs-ido-keymap (kbd "<f12>") 'next-history-element)
  (define-key ergoemacs-ido-keymap (kbd "S-<f11>") 'previous-matching-history-element)
  (define-key ergoemacs-ido-keymap (kbd "S-<f12>") 'next-matching-history-element)

  (add-to-list 'minor-mode-overriding-map-alist (cons 'ergoemacs-mode ergoemacs-ido-keymap))
  )

(defun ergoemacs-auto-complete-mode-hook ()
  "Hook for `auto-complete-mode-hook'.

When the `auto-complete-mode' is on, and when a word completion
is in process, Ctrl+s does `ac-isearch'.
This fixes it."

(define-key ac-completing-map ergoemacs-isearch-forward-key 'ac-isearch)
(define-key ac-completing-map (kbd "C-s") nil)
  )

(defvar ergoemacs-hook-list (list)
  "List of hook and hook-function pairs.")

(defun ergoemacs-add-hook (hook hook-function)
  "Adds a pair of hook and hook-function to the list
ergoemacs hooks."
  (add-to-list 'ergoemacs-hook-list (cons hook hook-function)))

(ergoemacs-add-hook 'isearch-mode-hook 'ergoemacs-isearch-hook)
(ergoemacs-add-hook 'comint-mode-hook 'ergoemacs-comint-hook)
(ergoemacs-add-hook 'log-edit-mode-hook 'ergoemacs-log-edit-hook)
(ergoemacs-add-hook 'eshell-mode-hook 'ergoemacs-eshell-hook)
(ergoemacs-add-hook 'minibuffer-setup-hook 'ergoemacs-minibuffer-setup-hook)
(ergoemacs-add-hook 'iswitchb-minibuffer-setup-hook 'ergoemacs-iswitchb-hook)
(ergoemacs-add-hook 'ido-minibuffer-setup-hook 'ergoemacs-ido-minibuffer-setup-hook)
(ergoemacs-add-hook 'auto-complete-mode-hook 'ergoemacs-auto-complete-mode-hook)

(defun ergoemacs-hook-modes ()
  "Installs/Removes ErgoEmacs minor mode hooks from major modes
depending the state of `ergoemacs-mode' variable.  If the mode
is being initialized, some global keybindings in current-global-map
will change."

  (let ((modify-hook (if ergoemacs-mode 'add-hook 'remove-hook))
	(modify-advice (if ergoemacs-mode 'ad-enable-advice 'ad-disable-advice)))

    ;; Fix CUA
    (if ergoemacs-mode
        (ergoemacs-fix-cua--pre-command-handler-1))

    ;; when ergoemacs-mode is on, activate hooks and unset global keys, else do inverse
    (if (and ergoemacs-mode (not (equal ergoemacs-mode 0)))
	(progn
	  (ergoemacs-unset-redundant-global-keys)

	  ;; alt+n is the new "Quit" in query-replace-map
	  (ergoemacs-unset-global-key query-replace-map "\e")
	  (define-key query-replace-map ergoemacs-keyboard-quit-key 'exit-prefix))
      ;; if ergoemacs was disabled: restore original keys
      (ergoemacs-restore-global-keys))

    ;; install the mode-hooks
    (dolist (hook ergoemacs-hook-list)
      (funcall modify-hook (car hook) (cdr hook)))

    ;; enable advices
    (funcall modify-advice 'global-set-key 'around 'ergoemacs-global-set-key-advice)
    (funcall modify-advice 'global-unset-key 'around 'ergoemacs-global-unset-key-advice)
    (funcall modify-advice 'local-set-key 'around 'ergoemacs-local-set-key-advice)
    (funcall modify-advice 'local-unset-key 'around 'ergoemacs-local-unset-key-advice)

    ;; update advices
    (ad-activate 'global-set-key)
    (ad-activate 'global-unset-key)
    (ad-activate 'local-set-key)
    (ad-activate 'local-unset-key)
    )
  )

;;----------------------------------------------------------------------
;; ErgoEmacs replacements for local- and global-set-key

(defun ergoemacs-global-set-key (key command)
  "Set a key in the ergoemacs-keymap, thus
making it globally active. This allow to redefine
any key unbound or claimed by ergoemacs."
  (interactive)
  (define-key ergoemacs-keymap key command))

(defun ergoemacs-global-unset-key (key)
  "Removes a key from the ergoemacs-keymap."
  (interactive)
  (ergoemacs-global-set-key key nil))

(defvar ergoemacs-local-keymap nil
  "Local ergoemacs keymap")
(make-variable-buffer-local 'ergoemacs-local-keymap)

(defun ergoemacs-local-set-key (key command)
  "Set a key in the ergoemacs local map."
  ;; install keymap if not already installed
  (interactive)
  (progn
    (unless ergoemacs-local-keymap
      (setq ergoemacs-local-keymap (copy-keymap ergoemacs-keymap))
      (add-to-list 'minor-mode-overriding-map-alist (cons 'ergoemacs-mode ergoemacs-local-keymap)))
    ;; add key
    (define-key ergoemacs-local-keymap key command)))

(defun ergoemacs-local-unset-key (key)
  "Unset a key in the ergoemacs local map."
  (ergoemacs-local-set-key key nil))

;;----------------------------------------------------------------------
;; ErgoEmacs advices for local- and global-set-key

(defadvice global-set-key (around ergoemacs-global-set-key-advice (key command))
  "This let you use global-set-key as usual when ergoemacs-mode is enabled."
  (if (fboundp 'ergoemacs-mode)
      (ergoemacs-global-set-key key command)
    ad-do-it))

(defadvice global-unset-key (around ergoemacs-global-unset-key-advice (key))
  "This let you use global-unset-key as usual when ergoemacs-mode is enabled."
  (if (fboundp 'ergoemacs-mode)
      (ergoemacs-global-unset-key key)
    ad-do-it))

(defadvice local-set-key (around ergoemacs-local-set-key-advice (key command))
  "This let you use local-set-key as usual when ergoemacs-mode is enabled."
  (if (fboundp 'ergoemacs-mode)
      (ergoemacs-local-set-key key command)
    ad-do-it))

(defadvice local-unset-key (around ergoemacs-local-unset-key-advice (key))
  "This let you use local-unset-key as usual when ergoemacs-mode is enabled."
  (if (fboundp 'ergoemacs-mode)
      (ergoemacs-local-unset-key key)
    ad-do-it))

;;----------------------------------------------------------------------
;; ErgoEmacs minor mode

(define-minor-mode ergoemacs-mode
  "Toggle ergoemacs keybinding mode.
This minor mode changes your emacs keybindings.
Without argument, toggles the minor mode.
If optional argument is 1, turn it on.
If optional argument is 0, turn it off.
Argument of t or nil should not be used.
For full documentation, see:
URL `http://xahlee.org/emacs/ergonomic_emacs_keybinding.html'

If you turned on by mistake, the shortcut to call execute-extended-command is M-a."
  nil
  :lighter " ErgoEmacs"	;; TODO this should be nil (it is for testing purposes)
  :global t
  :keymap ergoemacs-keymap

  (ergoemacs-hook-modes)
  )

(ergoemacs-mode 1)

;; replace-string on M-r
(global-set-key "\M-r" 'replace-string)

;; use mac command key as meta
(defvar mac_command (getenv "EMACS_COMMAND_AS_META"))
(cond
 ((string= mac_command "1")
  (setq mac-command-modifier 'meta))
 )

;################################################################
;#                    COLOR THEME
;################################################################


;;; color-theme.el --- install color themes

;; Copyright (C) 1999, 2000  Jonadab the Unsightly One <jonadab@bright.net>
;; Copyright (C) 2000, 2001, 2002, 2003  Alex Schroeder <alex@gnu.org>
;; Copyright (C) 2003, 2004, 2005, 2006  Xavier Maillard <zedek@gnu.org>

;; Version: 6.6.0
;; Keywords: faces
;; Author: Jonadab the Unsightly One <jonadab@bright.net>
;; Maintainer: Xavier Maillard <zedek@gnu.org>
;; URL: http://www.emacswiki.org/cgi-bin/wiki.pl?ColorTheme

;; This file is not (YET) part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:

;; Please read README and BUGS files for any relevant help.
;; Contributors (not themers) should also read HACKING file.

;;; Thanks

;; Deepak Goel  <deego@glue.umd.edu>
;; S. Pokrovsky <pok@nbsp.nsk.su> for ideas and discussion.
;; Gordon Messmer <gordon@dragonsdawn.net> for ideas and discussion.
;; Sriram Karra <karra@cs.utah.edu> for the color-theme-submit stuff.
;; Olgierd `Kingsajz' Ziolko <kingsajz@rpg.pl> for the spec-filter idea.
;; Brian Palmer for color-theme-library ideas and code
;; All the users that contributed their color themes.



;;; Code:
(eval-when-compile
  (require 'easymenu)
  (require 'reporter)
  (require 'sendmail))

(require 'cl); set-difference is a function...

;; for custom-face-attributes-get or face-custom-attributes-get
(require 'cus-face)
(require 'wid-edit); for widget-apply stuff in cus-face.el

(defconst color-theme-maintainer-address "zedek@gnu.org"
  "Address used by `submit-color-theme'.")

;; Emacs / XEmacs compatibility and workaround layer

(cond ((and (facep 'tool-bar)
	    (not (facep 'toolbar)))
       (put 'toolbar 'face-alias 'tool-bar))
      ((and (facep 'toolbar)
	    (not (facep 'tool-bar)))
       (put 'tool-bar 'face-alias 'toolbar)))

(defvar color-theme-xemacs-p (and (featurep 'xemacs) 
                                  (string-match "XEmacs" emacs-version))
  "Non-nil if running XEmacs.")

;; Add this since it appears to miss in emacs-2x
(or (fboundp 'replace-in-string)
    (defun replace-in-string (target old new)
      (replace-regexp-in-string old new  target)))

;; face-attr-construct has a problem in Emacs 20.7 and older when
;; dealing with inverse-video faces.  Here is a short test to check
;; wether you are affected.

;; (set-background-color "wheat")
;; (set-foreground-color "black")
;; (setq a (make-face 'a-face))
;; (face-spec-set a '((t (:background "white" :foreground "black" :inverse-video t))))
;; (face-attr-construct a)
;;     => (:background "black" :inverse-video t)

;; The expected response is the original specification:
;;     => (:background "white" :foreground "black" :inverse-video t)

;; That's why we depend on cus-face.el functionality.

(cond ((fboundp 'custom-face-attributes-get)
       (defun color-theme-face-attr-construct (face frame)
         (if (atom face)
             (custom-face-attributes-get face frame)
             (if (and (consp face) (eq (car face) 'quote))
                 (custom-face-attributes-get (cadr face) frame)
                 (custom-face-attributes-get (car face) frame)))))
      ((fboundp 'face-custom-attributes-get)
       (defalias 'color-theme-face-attr-construct
	 'face-custom-attributes-get))
      (t
       (defun color-theme-face-attr-construct (&rest ignore)
	 (error "Unable to construct face attributes"))))

(defun color-theme-alist (plist)
  "Transform PLIST into an alist if it is a plist and return it.
If the first element of PLIST is a cons cell, we just return PLIST,
assuming PLIST to be an alist.  If the first element of plist is not a
symbol, this is an error: We cannot distinguish a plist from an ordinary
list, but a list that doesn't start with a symbol is certainly no plist
and no alist.

This is used to make sure `default-frame-alist' really is an alist and not
a plist.  In XEmacs, the alist is deprecated; a plist is used instead."
  (cond ((consp (car plist))
	 plist)
	((not (symbolp (car plist)))
	 (error "Wrong type argument: plist, %S" plist))
	((featurep 'xemacs)
	 (plist-to-alist plist)))); XEmacs only

;; Customization

(defgroup color-theme nil
  "Color Themes for Emacs.
A color theme consists of frame parameter settings, variable settings,
and face definitions."
  :version "20.6"
  :group 'faces)

(defcustom color-theme-legal-frame-parameters "\\(color\\|mode\\)$"
  "Regexp that matches frame parameter names.
Only frame parameter names that match this regexp can be changed as part
of a color theme."
  :type '(choice (const :tag "Colors only" "\\(color\\|mode\\)$")
		 (const :tag "Colors, fonts, and size"
			"\\(color\\|mode\\|font\\|height\\|width\\)$")
		 (regexp :tag "Custom regexp"))
  :group 'color-theme
  :link '(info-link "(elisp)Window Frame Parameters"))

(defcustom color-theme-legal-variables "\\(color\\|face\\)$"
  "Regexp that matches variable names.
Only variables that match this regexp can be changed as part of a color
theme.  In addition to matching this name, the variables have to be user
variables (see function `user-variable-p')."
  :type 'regexp
  :group 'color-theme)

(defcustom color-theme-illegal-faces "^w3-"
  "Regexp that matches face names forbidden in themes.
The default setting \"^w3-\" excludes w3 faces since these
are created dynamically."
  :type 'regexp
  :group 'color-theme
  :link '(info-link "(elisp)Faces for Font Lock")
  :link '(info-link "(elisp)Standard Faces"))

(defcustom color-theme-illegal-default-attributes '(:family :height :width)
  "A list of face properties to be ignored when installing faces.
This prevents Emacs from doing terrible things to your display just because
a theme author likes weird fonts."
  :type '(repeat symbol)
  :group 'color-theme)

(defcustom color-theme-is-global t
  "*Determines wether a color theme is installed on all frames or not.
If non-nil, color themes will be installed for all frames.
If nil, color themes will be installed for the selected frame only.

A possible use for this variable is dynamic binding. Here is a larger
example to put in your ~/.emacs; it will make the Blue Sea color theme
the default used for the first frame, and it will create two additional
frames with different color themes.

setup:
    \(require 'color-theme)
    ;; set default color theme
    \(color-theme-blue-sea)
    ;; create some frames with different color themes
    \(let ((color-theme-is-global nil))
      \(select-frame (make-frame))
      \(color-theme-gnome2)
      \(select-frame (make-frame))
      \(color-theme-standard))

Please note that using XEmacs and and a nil value for
color-theme-is-global will ignore any variable settings for the color
theme, since XEmacs doesn't have frame-local variable bindings.

Also note that using Emacs and a non-nil value for color-theme-is-global
will install a new color theme for all frames.  Using XEmacs and a
non-nil value for color-theme-is-global will install a new color theme
only on those frames that are not using a local color theme."
  :type 'boolean
  :group 'color-theme)

(defcustom color-theme-is-cumulative t
  "*Determines wether new color themes are installed on top of each other.
If non-nil, installing a color theme will undo all settings made by
previous color themes."
  :type 'boolean
  :group 'color-theme)


(defcustom color-theme-load-all-themes t
  "When t, load all color-theme theme files
as presented by `color-theme-libraries'. Else
do not load any of this themes."
  :type 'boolean
  :group 'color-theme)

(defcustom color-theme-mode-hook nil
  "Hook for color-theme-mode."
  :type 'hook
  :group 'color-theme)

(defvar color-theme-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'color-theme-install-at-point)
    (define-key map (kbd "c") 'list-colors-display)
    (define-key map (kbd "d") 'color-theme-describe)
    (define-key map (kbd "f") 'list-faces-display)
    (define-key map (kbd "i") 'color-theme-install-at-point)
    (define-key map (kbd "l") 'color-theme-install-at-point-for-current-frame)
    (define-key map (kbd "p") 'color-theme-print)
    (define-key map (kbd "q") 'bury-buffer)
    (define-key map (kbd "?") 'color-theme-describe)
    (if color-theme-xemacs-p
	(define-key map (kbd "<button2>") 'color-theme-install-at-mouse)
      (define-key map (kbd "<mouse-2>") 'color-theme-install-at-mouse))
    map)
  "Mode map used for the buffer created by `color-theme-select'.")

(defvar color-theme-initialized nil
  "Internal variable determining whether color-theme-initialize has been invoked yet")

(defvar color-theme-buffer-name "*Color Theme Selection*"
  "Name of the color theme selection buffer.")

(defvar color-theme-original-frame-alist nil
  "nil until one of the color themes has been installed.")

(defvar color-theme-history nil
  "List of color-themes called, in reverse order")

(defcustom color-theme-history-max-length nil
  "Max length of history to maintain.
Two other values are acceptable: t means no limit, and
nil means that no history is maintained."
  :type '(choice (const :tag "No history" nil)
		 (const :tag "Unlimited length" t)
		 integer)
  :group 'color-theme)

(defvar color-theme-counter 0
  "Counter for every addition to `color-theme-history'.
This counts how many themes were installed, regardless
of `color-theme-history-max-length'.")

(defvar color-theme-entry-path (cond
                                ;; Emacs 22.x and later
                                ((lookup-key global-map [menu-bar tools])
                                 '("tools"))
                                ;; XEmacs
                                ((featurep 'xemacs)
                                 (setq tool-entry '("Tools")))
                                ;; Emacs < 22
                                (t
                                 '("Tools")))
  "Menu tool entry path.")

(defun color-theme-add-to-history (name)
  "Add color-theme NAME to `color-theme-history'."
  (setq color-theme-history
	(cons (list name color-theme-is-cumulative)
	      color-theme-history)
	color-theme-counter (+ 1 color-theme-counter))
  ;; Truncate the list if necessary.
  (when (and (integerp color-theme-history-max-length)
	     (>= (length color-theme-history)
		 color-theme-history-max-length))
    (setcdr (nthcdr (1- color-theme-history-max-length)
		    color-theme-history)
	    nil)))

;; (let ((l '(1 2 3 4 5)))
;;   (setcdr (nthcdr 2 l) nil)
;;   l)



;; List of color themes used to create the *Color Theme Selection*
;; buffer.

(defvar color-themes
  '((color-theme-aalto-dark "Aalto Dark" "Jari Aalto <jari.aalto@poboxes.com>")
    (color-theme-xp "XP" "Girish Bharadwaj <girishb@gbvsoft.com>"))
  "List of color themes.

Each THEME is itself a three element list (FUNC NAME MAINTAINER &optional LIBRARY).

FUNC is a color theme function which does the setup.  The function
FUNC may call `color-theme-install'.  The color theme function may be
interactive.

NAME is the name of the theme and MAINTAINER is the name and/or email of
the maintainer of the theme.

If LIBRARY is non-nil, the color theme will be considered a library and
may not be shown in the default menu.

If you defined your own color theme and want to add it to this list,
use something like this:

  (add-to-list 'color-themes '(color-theme-gnome2 \"Gnome2\" \"Alex\"))")

;;; Functions

(defun color-theme-backup-original-values ()
  "Back up the original `default-frame-alist'.
The values are stored in `color-theme-original-frame-alist' on
startup."
  (if (null color-theme-original-frame-alist)
      (setq color-theme-original-frame-alist
	    (color-theme-filter (frame-parameters (selected-frame))
				color-theme-legal-frame-parameters))))
(add-hook 'after-init-hook 'color-theme-backup-original-values)

;;;###autoload
(defun color-theme-select (&optional arg)
  "Displays a special buffer for selecting and installing a color theme.
With optional prefix ARG, this buffer will include color theme libraries
as well.  A color theme library is in itself not complete, it must be
used as part of another color theme to be useful.  Thus, color theme
libraries are mainly useful for color theme authors."
  (interactive "P")
  (unless color-theme-initialized (color-theme-initialize))
  (switch-to-buffer (get-buffer-create color-theme-buffer-name))
  (setq buffer-read-only nil)
  (erase-buffer)
  ;; recreate the snapshot if necessary
  (when (or (not (assq 'color-theme-snapshot color-themes))
	    (not (commandp 'color-theme-snapshot)))
    (fset 'color-theme-snapshot (color-theme-make-snapshot))
    (setq color-themes (delq (assq 'color-theme-snapshot color-themes)
			     color-themes)
	  color-themes (delq (assq 'bury-buffer color-themes)
			     color-themes)
	  color-themes (append '((color-theme-snapshot
				  "[Reset]" "Undo changes, if possible.")
				 (bury-buffer
				  "[Quit]" "Bury this buffer."))
			     color-themes)))
  (dolist (theme color-themes)
    (let ((func (nth 0 theme))
	  (name (nth 1 theme))
	  (author (nth 2 theme))
	  (library (nth 3 theme))
	  (desc))
      (when (or (not library) arg)
	(setq desc (format "%-23s %s" 
			   (if library (concat name " [lib]") name)
			   author))
	(put-text-property 0 (length desc) 'color-theme func desc)
	(put-text-property 0 (length name) 'face 'bold desc)
	(put-text-property 0 (length name) 'mouse-face 'highlight desc)
	(insert desc)
	(newline))))
  (goto-char (point-min))
  (setq buffer-read-only t)
  (set-buffer-modified-p nil)
  (color-theme-mode))

(when (require 'easymenu)
  (easy-menu-add-item nil color-theme-entry-path "--")
  (easy-menu-add-item  nil color-theme-entry-path
                       ["Color Themes" color-theme-select t]))

(defun color-theme-mode ()
  "Major mode to select and install color themes.

Use \\[color-theme-install-at-point] to install a color theme on all frames.
Use \\[color-theme-install-at-point-for-current-frame] to install a color theme for the current frame only.

The changes are applied on top of your current setup.  This is a
feature.

Some of the themes should be considered extensions to the standard color
theme: they modify only a limited number of faces and variables.  To
verify the final look of a color theme, install the standard color
theme, then install the other color theme.  This is a feature. It allows
you to mix several color themes.

Use \\[color-theme-describe] to read more about the color theme function at point.
If you want to install the color theme permanently, put the call to the
color theme function into your ~/.emacs:

    \(require 'color-theme)
    \(color-theme-gnome2)

If you worry about the size of color-theme.el: You are right.  Use
\\[color-theme-print] to print the current color theme and save the resulting buffer
as ~/.emacs-color-theme.  Now you can install only this specific color
theme in your .emacs:

    \(load-file \"~/.emacs-color-theme\")
    \(my-color-theme)

The Emacs menu is not affected by color themes within Emacs.  Depending
on the toolkit you used to compile Emacs, you might have to set specific
X ressources.  See the info manual for more information.  Here is an
example ~/.Xdefaults fragment:

    emacs*Background: DarkSlateGray
    emacs*Foreground: wheat

\\{color-theme-mode-map}

The color themes are listed in `color-themes', which see."
  (kill-all-local-variables)
  (setq major-mode 'color-theme-mode)
  (setq mode-name "Color Themes")
  (use-local-map color-theme-mode-map)
  (when (functionp 'goto-address); Emacs
    (goto-address))
  (run-hooks 'color-theme-mode-hook))

;;; Commands in Color Theme Selection mode

;;;###autoload
(defun color-theme-describe ()
  "Describe color theme listed at point.
This shows the documentation of the value of text-property color-theme
at point.  The text-property color-theme should be a color theme
function.  See `color-themes'."
  (interactive)
  (describe-function (get-text-property (point) 'color-theme)))

;;;###autoload
(defun color-theme-install-at-mouse (event)
  "Install color theme clicked upon using the mouse.
First argument EVENT is used to set point.  Then
`color-theme-install-at-point' is called."
  (interactive "e")
  (save-excursion
    (mouse-set-point event)
    (color-theme-install-at-point)))

;;;autoload
(defun color-theme-install-at-point ()
  "Install color theme at point.
This calls the value of the text-property `color-theme' at point.
The text-property `color-theme' should be a color theme function.
See `color-themes'."
  (interactive)
  (let ((func (get-text-property (point) 'color-theme)))
    ;; install theme
    (if func
	(funcall func))
    ;; If goto-address is being used, remove all overlays in the current
    ;; buffer and run it again.  The face used for the mail addresses in
    ;; the the color theme selection buffer is based on the variable
    ;; goto-address-mail-face.  Changes in that variable will not affect
    ;; existing overlays, however, thereby confusing users.
    (when (functionp 'goto-address); Emacs
      (dolist (o (overlays-in (point-min) (point-max)))
	(delete-overlay o))
      (goto-address))))

;;;###autoload
(defun color-theme-install-at-point-for-current-frame ()
  "Install color theme at point for current frame only.
Binds `color-theme-is-global' to nil and calls
`color-theme-install-at-point'."
  (interactive)
  (let ((color-theme-is-global nil))
    (color-theme-install-at-point)))



;; Taking a snapshot of the current color theme and pretty printing it.

(defun color-theme-filter (old-list regexp &optional exclude)
  "Filter OLD-LIST.
The resulting list will be newly allocated and contains only elements
with names matching REGEXP.  OLD-LIST may be a list or an alist.  If you
want to filter a plist, use `color-theme-alist' to convert your plist to
an alist, first.

If the optional argument EXCLUDE is non-nil, then the sense is
reversed: only non-matching elements will be retained."
  (let (elem new-list)
    (dolist (elem old-list)
      (setq name (symbol-name (if (listp elem) (car elem) elem)))
      (when (or (and (not exclude)
		     (string-match regexp name))
		(and exclude
		     (not (string-match regexp name))))
	;; Now make sure that if elem is a cons cell, and the cdr of
	;; that cons cell is a string, then we need a *new* string in
	;; the new list.  Having a new cons cell is of no use because
	;; modify-frame-parameters will modify this string, thus
	;; modifying our color theme functions!
	(when (and (consp elem)
		   (stringp (cdr elem)))
	  (setq elem (cons (car elem)
			   (copy-sequence (cdr elem)))))
	;; Now store elem
	(setq new-list (cons elem new-list))))
    new-list))

(defun color-theme-spec-filter (spec)
  "Filter the attributes in SPEC.
This makes sure that SPEC has the form ((t (PLIST ...))).
Only properties not in `color-theme-illegal-default-attributes'
are included in the SPEC returned."
  (let ((props (cadar spec))
	result prop val)
    (while props
      (setq prop (nth 0 props)
	    val (nth 1 props)
	    props (nthcdr 2 props))
      (unless (memq prop color-theme-illegal-default-attributes)
	(setq result (cons val (cons prop result)))))
    `((t ,(nreverse result)))))

;; (color-theme-spec-filter '((t (:background "blue3"))))
;; (color-theme-spec-filter '((t (:stipple nil :background "Black" :foreground "SteelBlue" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :width semi-condensed :family "misc-fixed"))))

(defun color-theme-plist-delete (plist prop)
  "Delete property PROP from property list PLIST by side effect.
This modifies PLIST."
  ;; deal with prop at the start
  (while (eq (car plist) prop)
    (setq plist (cddr plist)))
  ;; deal with empty plist
  (when plist
    (let ((lastcell (cdr plist))
	  (l (cddr plist)))
      (while l
	(if (eq (car l) prop)
	    (progn
	      (setq l (cddr l))
	      (setcdr lastcell l))
	  (setq lastcell (cdr l)
		l (cddr l))))))
  plist)

;; (color-theme-plist-delete '(a b c d e f g h) 'a)
;; (color-theme-plist-delete '(a b c d e f g h) 'b)
;; (color-theme-plist-delete '(a b c d e f g h) 'c)
;; (color-theme-plist-delete '(a b c d e f g h) 'g)
;; (color-theme-plist-delete '(a b c d c d e f g h) 'c)
;; (color-theme-plist-delete '(a b c d e f c d g h) 'c)

(if (or (featurep 'xemacs)
	(< emacs-major-version 21))
    (defalias 'color-theme-spec-compat 'identity)
  (defun color-theme-spec-compat (spec)
    "Filter the attributes in SPEC such that is is never invalid.
Example: Eventhough :bold works in Emacs, it is not recognized by
`customize-face' -- and then the face is uncustomizable.  This
function replaces a :bold attribute with the corresponding :weight
attribute, if there is no :weight, or deletes it.  This undoes the
doings of `color-theme-spec-canonical-font', more or less."
    (let ((props (cadar spec)))
      (when (plist-member props :bold)
	(setq props (color-theme-plist-delete props :bold))
	(unless (plist-member props :weight)
	  (setq props (plist-put props :weight 'bold))))
      (when (plist-member props :italic)
	(setq props (color-theme-plist-delete props :italic))
	(unless (plist-member props :slant)
	  (setq props (plist-put props :slant 'italic))))
      `((t ,props)))))

;; (color-theme-spec-compat '((t (:foreground "blue" :bold t))))
;; (color-theme-spec-compat '((t (:bold t :foreground "blue" :weight extra-bold))))
;; (color-theme-spec-compat '((t (:italic t :foreground "blue"))))
;; (color-theme-spec-compat '((t (:slant oblique :italic t :foreground "blue"))))

(defun color-theme-spec-canonical-font (atts)
  "Add :bold and :italic attributes if necessary."
  ;; add these to the front of atts -- this will keept the old value for
  ;; customize-face in Emacs 21.
  (when (and (memq (plist-get atts :weight)
		   '(ultra-bold extra-bold bold semi-bold))
	     (not (plist-get atts :bold)))
    (setq atts (cons :bold (cons t atts))))
  (when (and (not (memq (plist-get atts :slant)
			'(normal nil)))
	     (not (plist-get atts :italic)))
    (setq atts (cons :italic (cons t atts))))
  atts)
;; (color-theme-spec-canonical-font (color-theme-face-attr-construct 'bold (selected-frame)))
;; (defface foo '((t (:weight extra-bold))) "foo")
;; (color-theme-spec-canonical-font (color-theme-face-attr-construct 'foo (selected-frame)))
;; (face-spec-set 'foo '((t (:weight extra-bold))) nil)
;; (face-spec-set 'foo '((t (:bold t))) nil)
;; (face-spec-set 'foo '((t (:bold t :weight extra-bold))) nil)

;; Handle :height according to NEWS file for Emacs 21
(defun color-theme-spec-resolve-height (old new)
  "Return the new height given OLD and NEW height.
OLD is the current setting, NEW is the setting inherited from."
  (cond ((not old)
	 new)
	((integerp old)
	 old)
	((and (floatp old)
	      (integerp new))
	 (round (* old new)))
	((and (floatp old)
	      (floatp new))
	 (* old new))
	((and (functionp old)
	      (integerp new))
	 (round (funcall old new)))
	((and (functionp old)
	      (float new))
	 `(lambda (f) (* (funcall ,old f) ,new)))
	((and (functionp old)
	      (functionp new))
	 `(lambda (f) (* (funcall ,old (funcall ,new f)))))
	(t
	 (error "Illegal :height attributes: %S or %S" old new))))
;; (color-theme-spec-resolve-height 12 1.2)
;; (color-theme-spec-resolve-height 1.2 1.2)
;; (color-theme-spec-resolve-height 1.2 12)
;; (color-theme-spec-resolve-height 1.2 'foo)
;; (color-theme-spec-resolve-height (lambda (f) (* 2 f)) 5)
;; (color-theme-spec-resolve-height (lambda (f) (* 2 f)) 2.0)
;; the following lambda is the result from the above calculation
;; (color-theme-spec-resolve-height (lambda (f) (* (funcall (lambda (f) (* 2 f)) f) 2.0)) 5)

(defun color-theme-spec-resolve-inheritance (atts)
  "Resolve all occurences of the :inherit attribute."
  (let ((face (plist-get atts :inherit)))
    ;; From the Emacs 21 NEWS file: "Attributes from inherited faces are
    ;; merged into the face like an underlying face would be." --
    ;; therefore properties of the inherited face only add missing
    ;; attributes.
    (when face
      ;; remove :inherit face from atts -- this assumes only one
      ;; :inherit attribute.
      (setq atts (delq ':inherit (delq face atts)))
      (let ((more-atts (color-theme-spec-resolve-inheritance
			(color-theme-face-attr-construct
			 face (selected-frame))))
	    att val)
	(while more-atts
	  (setq att (car more-atts)
		val (cadr more-atts)
		more-atts (cddr more-atts))
	  ;; Color-theme assumes that no value is ever 'unspecified.
	  (cond ((eq att ':height); cumulative effect!
		 (setq atts (plist-put atts 
				       ':height 
				       (color-theme-spec-resolve-height
					(plist-get atts att) 
					val))))
		;; Default: Only put if it has not been specified before.
		((not (plist-get atts att))
		 (setq atts (cons att (cons val atts))))
		  
))))
    atts))
;; (color-theme-spec-resolve-inheritance '(:bold t))
;; (color-theme-spec-resolve-inheritance '(:bold t :foreground "blue"))
;; (color-theme-face-attr-construct 'font-lock-comment-face (selected-frame))
;; (color-theme-spec-resolve-inheritance '(:bold t :inherit font-lock-comment-face))
;; (color-theme-spec-resolve-inheritance '(:bold t :foreground "red" :inherit font-lock-comment-face))
;; (color-theme-face-attr-construct 'Info-title-2-face (selected-frame))
;; (color-theme-face-attr-construct 'Info-title-3-face (selected-frame))
;; (color-theme-face-attr-construct 'Info-title-4-face (selected-frame))
;; (color-theme-spec-resolve-inheritance '(:inherit Info-title-2-face))

;; The :inverse-video attribute causes Emacs to swap foreground and
;; background colors, XEmacs does not.  Therefore, if anybody chooses
;; the inverse-video attribute, we 1. swap the colors ourselves in Emacs
;; and 2. we remove the inverse-video attribute in Emacs and XEmacs.
;; Inverse-video is only useful on a monochrome tty.
(defun color-theme-spec-maybe-invert (atts)
  "Remove the :inverse-video attribute from ATTS.
If ATTS contains :inverse-video t, remove it and swap foreground and
background color.  Return ATTS."
  (let ((inv (plist-get atts ':inverse-video)))
    (if inv
	(let (result att)
	  (while atts
	    (setq att (car atts)
		  atts (cdr atts))
	    (cond ((and (eq att :foreground) (not color-theme-xemacs-p))
		   (setq result (cons :background result)))
		  ((and (eq att :background) (not color-theme-xemacs-p))
		   (setq result (cons :foreground result)))
		  ((eq att :inverse-video)
		   (setq atts (cdr atts))); this prevents using dolist
		  (t
		   (setq result (cons att result)))))
	  (nreverse result))
      ;; else
      atts)))
;; (color-theme-spec-maybe-invert '(:bold t))
;; (color-theme-spec-maybe-invert '(:foreground "blue"))
;; (color-theme-spec-maybe-invert '(:background "red"))
;; (color-theme-spec-maybe-invert '(:inverse-video t))
;; (color-theme-spec-maybe-invert '(:inverse-video t :foreground "red"))
;; (color-theme-spec-maybe-invert '(:inverse-video t :background "red"))
;; (color-theme-spec-maybe-invert '(:inverse-video t :background "red" :foreground "blue" :bold t))
;; (color-theme-spec-maybe-invert '(:inverse-video nil :background "red" :foreground "blue" :bold t))

(defun color-theme-spec (face)
  "Return a list for FACE which has the form (FACE SPEC).
See `defface' for the format of SPEC.  In this case we use only one
DISPLAY, t, and determine ATTS using `color-theme-face-attr-construct'.
If ATTS is nil, (nil) is used  instead.

If ATTS contains :inverse-video t, we remove it and swap foreground and
background color using `color-theme-spec-maybe-invert'.  We do this
because :inverse-video is handled differently in Emacs and XEmacs.  We
will loose on a tty without colors, because in that situation,
:inverse-video means something."
  (let ((atts
	 (color-theme-spec-canonical-font
	  (color-theme-spec-maybe-invert
	   (color-theme-spec-resolve-inheritance
	    (color-theme-face-attr-construct face (selected-frame)))))))
    (if atts
	`(,face ((t ,atts)))
      `(,face ((t (nil)))))))

(defun color-theme-get-params ()
  "Return a list of frame parameter settings usable in a color theme.
Such an alist may be installed by `color-theme-install-frame-params'.  The
frame parameters returned must match `color-theme-legal-frame-parameters'."
  (let ((params (color-theme-filter (frame-parameters (selected-frame))
				    color-theme-legal-frame-parameters)))
    (sort params (lambda (a b) (string< (symbol-name (car a))
					(symbol-name (car b)))))))

(defun color-theme-get-vars ()
  "Return a list of variable settings usable in a color theme.
Such an alist may be installed by `color-theme-install-variables'.
The variable names must match `color-theme-legal-variables', and the
variable must be a user variable according to `user-variable-p'."
  (let ((vars)
	(val))
    (mapatoms (lambda (v)
		(and (boundp v)
		     (user-variable-p v)
		     (string-match color-theme-legal-variables
				   (symbol-name v))
		     (setq val (eval v))
		     (add-to-list 'vars (cons v val)))))
    (sort vars (lambda (a b) (string< (car a) (car b))))))

(defun color-theme-print-alist (alist)
  "Print ALIST."
  (insert "\n     " (if alist "(" "nil"))
  (dolist (elem alist)
    (when (= (preceding-char) ?\))
      (insert "\n      "))
    (prin1 elem (current-buffer)))
  (when (= (preceding-char) ?\)) (insert ")")))

(defun color-theme-get-faces ()
  "Return a list of faces usable in a color theme.
Such an alist may be installed by `color-theme-install-faces'.  The
faces returned must not match `color-theme-illegal-faces'."
  (let ((faces (color-theme-filter (face-list) color-theme-illegal-faces t)))
    ;; default face must come first according to comments in
    ;; custom-save-faces, the rest is to be sorted by name
    (cons 'default (sort (delq 'default faces) 'string-lessp))))

(defun color-theme-get-face-definitions ()
  "Return face settings usable in a color-theme."
  (let ((faces (color-theme-get-faces)))
    (mapcar 'color-theme-spec faces)))

(defun color-theme-print-faces (faces)
  "Print face settings for all faces returned by `color-theme-get-faces'."
  (when faces
    (insert "\n     "))
  (dolist (face faces)
    (when (= (preceding-char) ?\))
      (insert "\n     "))
    (prin1 face (current-buffer))))

(defun color-theme-reset-faces ()
  "Reset face settings for all faces returned by `color-theme-get-faces'."
  (let ((faces (color-theme-get-faces))
	(face) (spec) (entry)
	(frame (if color-theme-is-global nil (selected-frame))))
    (while faces
      (setq entry (color-theme-spec (car faces)))
      (setq face (nth 0 entry))
      (setq spec '((t (nil))))
      (setq faces (cdr faces))
      (if (functionp 'face-spec-reset-face)
	  (face-spec-reset-face face frame)
	(face-spec-set face spec frame)
	(if color-theme-is-global
	    (put face 'face-defface-spec spec))))))

(defun color-theme-print-theme (func doc params vars faces)
  "Print a theme into the current buffer.
FUNC is the function name, DOC the doc string, PARAMS the
frame parameters, VARS the variable bindings, and FACES
the list of faces and their specs."
  (insert "(defun " (symbol-name func) " ()\n"
	  "  \"" doc "\"\n"
	  "  (interactive)\n"
	  "  (color-theme-install\n"
	  "   '(" (symbol-name func))
  ;; alist of frame parameters
  (color-theme-print-alist params)
  ;; alist of variables
  (color-theme-print-alist vars)
  ;; remaining elements of snapshot: face specs
  (color-theme-print-faces faces)
  (insert ")))\n")
  (insert "(add-to-list 'color-themes '(" (symbol-name func) " "
          " \"THEME NAME\" \"YOUR NAME\"))")
  (goto-char (point-min)))

;;;###autoload
(defun color-theme-print (&optional buf)
  "Print the current color theme function.

You can contribute this function to <URL:news:gnu.emacs.sources> or
paste it into your .emacs file and call it.  That should recreate all
the settings necessary for your color theme.

Example:

    \(require 'color-theme)
    \(defun my-color-theme ()
      \"Color theme by Alex Schroeder, created 2000-05-17.\"
      \(interactive)
      \(color-theme-install
       '(...
	 ...
	 ...)))
    \(my-color-theme)

If you want to use a specific color theme function, you can call the
color theme function in your .emacs directly.

Example:

    \(require 'color-theme)
    \(color-theme-gnome2)"
  (interactive)
  (message "Pretty printing current color theme function...")
  (switch-to-buffer (if buf
			buf
		      (get-buffer-create "*Color Theme*")))
  (unless buf
    (setq buffer-read-only nil)
    (erase-buffer))
  ;; insert defun
  (insert "(eval-when-compile"
          "    (require 'color-theme))\n")
  (color-theme-print-theme 'my-color-theme
			   (concat "Color theme by "
				   (if (string= "" user-full-name)
				       (user-login-name)
				     user-full-name)
				   ", created " (format-time-string "%Y-%m-%d") ".")
			   (color-theme-get-params)
			   (color-theme-get-vars)
			   (mapcar 'color-theme-spec (color-theme-get-faces)))
  (unless buf
    (emacs-lisp-mode))
  (goto-char (point-min))
  (message "Pretty printing current color theme function... done"))

(defun color-theme-analyze-find-theme (code)
  "Find the sexpr that calls `color-theme-install'."
  (let (theme)
    (while (and (not theme) code)
      (when (eq (car code) 'color-theme-install)
	(setq theme code))
      (when (listp (car code))
	(setq theme (color-theme-analyze-find-theme (car code))))
      (setq code (cdr code)))
    theme))

;; (equal (color-theme-analyze-find-theme
;; 	'(defun color-theme-blue-eshell ()
;; 	   "Color theme for eshell faces only."
;; 	   (color-theme-install
;; 	    '(color-theme-blue-eshell
;; 	      nil
;; 	      (eshell-ls-archive-face ((t (:bold t :foreground "IndianRed"))))
;; 	      (eshell-ls-backup-face ((t (:foreground "Grey"))))))))
;;        '(color-theme-install
;; 	 (quote
;; 	  (color-theme-blue-eshell
;; 	   nil
;; 	   (eshell-ls-archive-face ((t (:bold t :foreground "IndianRed"))))
;; 	   (eshell-ls-backup-face ((t (:foreground "Grey")))))))))

(defun color-theme-analyze-add-face (a b regexp faces)
  "If only one of A or B are in FACES, the other is added, and FACES is returned.
If REGEXP is given, this is only done if faces contains a match for regexps."
  (when (or (not regexp)
	    (catch 'found
	      (dolist (face faces)
		(when (string-match regexp (symbol-name (car face)))
		  (throw 'found t)))))
    (let ((face-a (assoc a faces))
	  (face-b (assoc b faces)))
      (if (and face-a (not face-b))
	  (setq faces (cons (list b (nth 1 face-a))
			    faces))
	(if (and (not face-a) face-b)
	    (setq faces (cons (list a (nth 1 face-b))
			      faces))))))
  faces)

;; (equal (color-theme-analyze-add-face
;; 	'blue 'violet nil
;; 	'((blue ((t (:foreground "blue"))))
;; 	  (bold ((t (:bold t))))))
;;        '((violet ((t (:foreground "blue"))))
;; 	 (blue ((t (:foreground "blue"))))
;; 	 (bold ((t (:bold t))))))
;; (equal (color-theme-analyze-add-face
;; 	'violet 'blue nil
;; 	'((blue ((t (:foreground "blue"))))
;; 	  (bold ((t (:bold t))))))
;;        '((violet ((t (:foreground "blue"))))
;; 	 (blue ((t (:foreground "blue"))))
;; 	 (bold ((t (:bold t))))))
;; (equal (color-theme-analyze-add-face
;; 	'violet 'blue "foo"
;; 	'((blue ((t (:foreground "blue"))))
;; 	  (bold ((t (:bold t))))))
;;        '((blue ((t (:foreground "blue"))))
;; 	 (bold ((t (:bold t))))))
;; (equal (color-theme-analyze-add-face
;; 	'violet 'blue "blue"
;; 	'((blue ((t (:foreground "blue"))))
;; 	  (bold ((t (:bold t))))))
;;        '((violet ((t (:foreground "blue"))))
;; 	 (blue ((t (:foreground "blue"))))
;; 	 (bold ((t (:bold t))))))

(defun color-theme-analyze-add-faces (faces)
  "Add missing faces to FACES and return it."
  ;; The most important thing is to add missing faces for the other
  ;; editor.  These are the most important faces to check.  The
  ;; following rules list two faces, A and B.  If either of the two is
  ;; part of the theme, the other must be, too.  The optional third
  ;; argument specifies a regexp.  Only if an existing face name
  ;; matches this regexp, is the rule applied.
  (let ((rules '((font-lock-builtin-face font-lock-reference-face)
		 (font-lock-doc-face font-lock-doc-string-face)
		 (font-lock-constant-face font-lock-preprocessor-face)
		 ;; In Emacs 21 `modeline' is just an alias for
		 ;; `mode-line'.  I recommend the use of
		 ;; `modeline' until further notice.
		 (modeline mode-line)
		 (modeline modeline-buffer-id)
		 (modeline modeline-mousable)
		 (modeline modeline-mousable-minor-mode)
		 (region primary-selection)
		 (region zmacs-region)
		 (font-lock-string-face dired-face-boring "^dired")
		 (font-lock-function-name-face dired-face-directory "^dired")
		 (default dired-face-executable "^dired")
		 (font-lock-warning-face dired-face-flagged "^dired")
		 (font-lock-warning-face dired-face-marked "^dired")
		 (default dired-face-permissions "^dired")
		 (default dired-face-setuid "^dired")
		 (default dired-face-socket "^dired")
		 (font-lock-keyword-face dired-face-symlink "^dired")
		 (tool-bar menu))))
    (dolist (rule rules)
      (setq faces (color-theme-analyze-add-face
		   (nth 0 rule) (nth 1 rule) (nth 2 rule) faces))))
  ;; The `fringe' face defines what the left and right borders of the
  ;; frame look like in Emacs 21.  To give them default fore- and
  ;; background colors, use (fringe ((t (nil)))) in your color theme.
  ;; Usually it makes more sense to choose a color slightly lighter or
  ;; darker from the default background.
  (unless (assoc 'fringe faces)
    (setq faces (cons '(fringe ((t (nil)))) faces)))
  ;; The tool-bar should not be part of the frame-parameters, since it
  ;; should not appear or disappear depending on the color theme.  The
  ;; apppearance of the toolbar, however, can be changed by the color
  ;; theme.  For Emacs 21, use the `tool-bar' face.  The easiest way
  ;; to do this is to give it the default fore- and background colors.
  ;; This can be achieved using (tool-bar ((t (nil)))) in the theme.
  ;; Usually it makes more sense, however, to provide the same colors
  ;; as used in the `menu' face, and to specify a :box attribute.  In
  ;; order to alleviate potential Emacs/XEmacs incompatibilities,
  ;; `toolbar' will be defined as an alias for `tool-bar' if it does
  ;; not exist, and vice-versa.  This is done eventhough the face
  ;; `toolbar' seems to have no effect on XEmacs.  If you look at
  ;; XEmacs lisp/faces.el, however, you will find that it is in fact
  ;; referenced for XPM stuff.
  (unless (assoc 'tool-bar faces)
    (setq faces (cons '(tool-bar ((t (nil)))) faces)))
  ;; Move the default face back to the front, and sort the rest.
  (unless (eq (caar faces) 'default)
    (let ((face (assoc 'default faces)))
      (setq faces (cons face
			(sort (delete face faces)
			      (lambda (a b)
				(string-lessp (car a) (car b))))))))
  faces)

(defun color-theme-analyze-remove-heights (faces)
  "Remove :height property where it is an integer and return FACES."
  ;; I don't recommend making font sizes part of a color theme.  Most
  ;; users would be surprised to see their font sizes change when they
  ;; install a color-theme.  Therefore, remove all :height attributes
  ;; if the value is an integer.  If the value is a float, this is ok
  ;; -- the value is relative to the default height.  One notable
  ;; exceptions is for a color-theme created for visually impaired
  ;; people.  These *must* use a larger font in order to be usable.
  (let (result)
    (dolist (face faces)
      (let ((props (cadar (nth 1 face))))
	(if (and (plist-member props :height)
		 (integerp (plist-get props :height)))
	    (setq props (color-theme-plist-delete props :height)
		  result (cons (list (car face) `((t ,props)))
			       result))
	  (setq result (cons face result)))))
    (nreverse result)))

;; (equal (color-theme-analyze-remove-heights
;; 	'((blue ((t (:foreground "blue" :height 2))))
;; 	  (bold ((t (:bold t :height 1.0))))))
;;        '((blue ((t (:foreground "blue"))))
;; 	 (bold ((t (:bold t :height 1.0))))))

;;;###autoload
(defun color-theme-analyze-defun ()
  "Once you have a color-theme printed, check for missing faces.
This is used by maintainers who receive a color-theme submission
and want to make sure it follows the guidelines by the color-theme
author."
  ;; The support for :foreground and :background attributes works for
  ;; Emacs 20 and 21 as well as for XEmacs.  :inverse-video is taken
  ;; care of while printing color themes.
  (interactive)
  ;; Parse the stuff and find the call to color-theme-install
  (save-excursion
    (save-restriction
      (narrow-to-defun)
      ;; define the function
      (eval-defun nil)
      (goto-char (point-min))
      (let* ((code (read (current-buffer)))
	     (theme (color-theme-canonic
		     (eval
		      (cadr
		       (color-theme-analyze-find-theme
			code)))))
	     (func (color-theme-function theme))
	     (doc (documentation func t))
	     (variables (color-theme-variables theme))
	     (faces (color-theme-faces theme))
	     (params (color-theme-frame-params theme)))
	(setq faces (color-theme-analyze-remove-heights
		     (color-theme-analyze-add-faces faces)))
	;; Remove any variable bindings of faces that point to their
	;; symbol?  Perhaps not, because another theme might want to
	;; change this, so it is important to be able to reset them.
	;; 	(let (result)
	;; 	  (dolist (var variables)
	;; 	    (unless (eq (car var) (cdr var))
	;; 	      (setq result (cons var result))))
	;; 	  (setq variables (nreverse result)))
	;; Now modify the theme directly.
	(setq theme (color-theme-analyze-find-theme code))
	(setcdr (cadadr theme) (list params variables faces))
	(message "Pretty printing analysed color theme function...")
	(with-current-buffer (get-buffer-create "*Color Theme*")
	  (setq buffer-read-only nil)
	  (erase-buffer)
	  ;; insert defun
	  (color-theme-print-theme func doc params variables faces)
	  (emacs-lisp-mode))
	(message "Pretty printing analysed color theme function... done")
	(ediff-buffers (current-buffer)
		       (get-buffer "*Color Theme*"))))))

;;; Creating a snapshot of the current color theme

(defun color-theme-snapshot nil)

;;;###autoload
(defun color-theme-make-snapshot ()
  "Return the definition of the current color-theme.
The function returned will recreate the color-theme in use at the moment."
  (eval `(lambda ()
	   "The color theme in use when the selection buffer was created.
\\[color-theme-select] creates the color theme selection buffer.  At the
same time, this snapshot is created as a very simple undo mechanism.
The snapshot is created via `color-theme-snapshot'."
	   (interactive)
	   (color-theme-install
	    '(color-theme-snapshot
	      ;; alist of frame parameters
	      ,(color-theme-get-params)
	      ;; alist of variables
	      ,(color-theme-get-vars)
	      ;; remaining elements of snapshot: face specs
	      ,@(color-theme-get-face-definitions))))))



;;; Handling the various parts of a color theme install

(defvar color-theme-frame-param-frobbing-rules
  '((foreground-color default foreground)
    (background-color default background))
  "List of rules to use when frobbing faces based on frame parameters.
This is only necessary for XEmacs, because in Emacs 21 changing the
frame paramters automatically affects the relevant faces.")

;; fixme: silent the bytecompiler with set-face-property
(defun color-theme-frob-faces (params)
  "Change certain faces according to PARAMS.
This uses `color-theme-frame-param-frobbing-rules'."
  (dolist (rule color-theme-frame-param-frobbing-rules)
    (let* ((param (nth 0 rule))
	   (face (nth 1 rule))
	   (prop (nth 2 rule))
	   (val (cdr (assq param params)))
	   (frame (if color-theme-is-global nil (selected-frame))))
      (when val
	(set-face-property face prop val frame)))))

(defun color-theme-alist-reduce (old-list)
  "Reduce OLD-LIST.
The resulting list will be newly allocated and will not contain any elements
with duplicate cars.  This will speed the installation of new themes by
only installing unique attributes."
  (let (new-list)
    (dolist (elem old-list)
      (when (not (assq (car elem) new-list))
	(setq new-list (cons elem new-list))))
    new-list))

(defun color-theme-install-frame-params (params)
  "Change frame parameters using alist PARAMETERS.

If `color-theme-is-global' is non-nil, all frames are modified using
`modify-frame-parameters' and the PARAMETERS are prepended to
`default-frame-alist'.  The value of `initial-frame-alist' is not
modified.  If `color-theme-is-global' is nil, only the selected frame is
modified.  If `color-theme-is-cumulative' is nil, the frame parameters
are restored from `color-theme-original-frame-alist'.

If the current frame parameters have a parameter `minibuffer' with
value `only', then the frame parameters are not installed, since this
indicates a dedicated minibuffer frame.

Called from `color-theme-install'."
  (setq params (color-theme-filter
		params color-theme-legal-frame-parameters))
  ;; We have a new list in params now, therefore we may use
  ;; destructive nconc.
  (if color-theme-is-global
      (let ((frames (frame-list)))
	(if (or color-theme-is-cumulative
		(null color-theme-original-frame-alist))
	    (setq default-frame-alist
		  (append params (color-theme-alist default-frame-alist))
		  minibuffer-frame-alist
		  (append params (color-theme-alist minibuffer-frame-alist)))
	  (setq default-frame-alist
		(append params color-theme-original-frame-alist)
		minibuffer-frame-alist
		(append params (color-theme-alist minibuffer-frame-alist))))
	(setq default-frame-alist
	      (color-theme-alist-reduce default-frame-alist)
	      minibuffer-frame-alist
	      (color-theme-alist-reduce minibuffer-frame-alist))
	(dolist (frame frames)
	  (let ((params (if (eq 'only (cdr (assq 'minibuffer (frame-parameters frame))))
			    minibuffer-frame-alist
			  default-frame-alist)))
	    (condition-case var
		(modify-frame-parameters frame params)
	      (error (message "Error using params %S: %S" params var))))))
    (condition-case var
	(modify-frame-parameters (selected-frame) params)
      (error (message "Error using params %S: %S" params var))))
  (when color-theme-xemacs-p
    (color-theme-frob-faces params)))

;; (setq default-frame-alist (cons '(height . 30) default-frame-alist))

(defun color-theme-install-variables (vars)
  "Change variables using alist VARS.
All variables matching `color-theme-legal-variables' are set.

If `color-theme-is-global' and `color-theme-xemacs-p' are nil, variables
are made frame-local before setting them.  Variables are set using `set'
in either case.  This may lead to problems if changing the variable
requires the usage of the function specified with the :set tag in
defcustom declarations.

Called from `color-theme-install'."
  (let ((vars (color-theme-filter vars color-theme-legal-variables)))
    (dolist (var vars)
      (if (or color-theme-is-global color-theme-xemacs-p)
	  (set (car var) (cdr var))
	(make-variable-frame-local (car var))
	(modify-frame-parameters (selected-frame) (list var))))))

(defun color-theme-install-faces (faces)
  "Change faces using FACES.

Change faces for all frames and create any faces listed in FACES which
don't exist.  The modified faces will be marked as \"unchanged from
its standard setting\".  This is OK, since the changes made by
installing a color theme should never by saved in .emacs by
customization code.

FACES should be a list where each entry has the form:

  (FACE SPEC)

See `defface' for the format of SPEC.

If `color-theme-is-global' is non-nil, faces are modified on all frames
using `face-spec-set'.  If `color-theme-is-global' is nil, faces are
only modified on the selected frame.  Non-existing faces are created
using `make-empty-face' in either case.  If `color-theme-is-cumulative'
is nil, all faces are reset before installing the new faces.

Called from `color-theme-install'."
  ;; clear all previous faces
  (when (not color-theme-is-cumulative)
    (color-theme-reset-faces))
  ;; install new faces
  (let ((faces (color-theme-filter faces color-theme-illegal-faces t))
	(frame (if color-theme-is-global nil (selected-frame))))
    (dolist (entry faces)
      (let ((face (nth 0 entry))
	    (spec (nth 1 entry)))
	(or (facep face)
	    (make-empty-face face))
	;; remove weird properties from the default face only
	(when (eq face 'default)
	  (setq spec (color-theme-spec-filter spec)))
	;; Emacs/XEmacs customization issues: filter out :bold when
	;; the spec contains :weight, etc, such that the spec remains
	;; "valid" for custom.
	(setq spec (color-theme-spec-compat spec))
	;; using a spec of ((t (nil))) to reset a face doesn't work
	;; in Emacs 21, we use the new function face-spec-reset-face
	;; instead
	(if (and (functionp 'face-spec-reset-face)
		 (equal spec '((t (nil)))))
	    (face-spec-reset-face face frame)
	  (condition-case var
	      (progn
		(face-spec-set face spec frame)
		(if color-theme-is-global
		    (put face 'face-defface-spec spec)))
	    (error (message "Error using spec %S: %S" spec var))))))))

;; `custom-set-faces' is unusable here because it doesn't allow to set
;; the faces for one frame only.

;; Emacs `face-spec-set': If FRAME is nil, the face is created and
;; marked as a customized face.  This is achieved by setting the
;; `face-defface-spec' property.  If we don't, new frames will not be
;; created using the face we installed because `face-spec-set' is
;; broken: If given a FRAME of nil, it will not set the default faces;
;; instead it will walk through all the frames and set modify the faces.
;; If we do set a property (`saved-face' or `face-defface-spec'),
;; `make-frame' will correctly use the faces we defined with our color
;; theme.  If we used the property `saved-face',
;; `customize-save-customized' will save all the faces installed as part
;; of a color-theme in .emacs.  That's why we use the
;; `face-defface-spec' property.



;;; Theme accessor functions, canonicalization, merging, comparing

(defun color-theme-canonic (theme)
  "Return the canonic form of THEME.
This deals with all the backwards compatibility stuff."
  (let (function frame-params variables faces)
    (when (functionp (car theme))
      (setq function (car theme)
	    theme (cdr theme)))
    (setq frame-params (car theme)
	  theme (cdr theme))
    ;; optional variable defintions (for backwards compatibility)
    (when (listp (caar theme))
      (setq variables (car theme)
	    theme (cdr theme)))
    ;; face definitions
    (setq faces theme)
    (list function frame-params variables faces)))

(defun color-theme-function (theme)
  "Return function used to create THEME."
  (nth 0 theme))

(defun color-theme-frame-params (theme)
  "Return frame-parameters defined by THEME."
  (nth 1 theme))

(defun color-theme-variables (theme)
  "Return variables set by THEME."
  (nth 2 theme))

(defun color-theme-faces (theme)
  "Return faces defined by THEME."
  (nth 3 theme))

(defun color-theme-merge-alists (&rest alists)
  "Merges all the alist arguments into one alist.
Only the first instance of every key will be part of the resulting
alist.  Membership will be tested using `assq'."
  (let (result)
    (dolist (l alists)
      (dolist (entry l)
	(unless (assq (car entry) result)
	  (setq result (cons entry result)))))
    (nreverse result)))
;; (color-theme-merge-alists '((a . 1) (b . 2)))
;; (color-theme-merge-alists '((a . 1) (b . 2) (a . 3)))
;; (color-theme-merge-alists '((a . 1) (b . 2)) '((a . 3)))
;; (color-theme-merge-alists '((a . 1) (b . 2)) '((c . 3)))
;; (color-theme-merge-alists '((a . 1) (b . 2)) '((c . 3) (d . 4)))
;; (color-theme-merge-alists '((a . 1) (b . 2)) '((c . 3) (d . 4) (b . 5)))

;;;###autoload
(defun color-theme-compare (theme-a theme-b)
  "Compare two color themes.
This will print the differences between installing THEME-A and
installing THEME-B.  Note that the order is important: If a face is
defined in THEME-A and not in THEME-B, then this will not show up as a
difference, because there is no reset before installing THEME-B.  If a
face is defined in THEME-B and not in THEME-A, then this will show up as
a difference."
  (interactive
   (list
    (intern
     (completing-read "Theme A: "
		      (mapcar (lambda (i) (list (symbol-name (car i))))
			      color-themes)
		      (lambda (i) (string-match "color-theme" (car i)))))
    (intern
     (completing-read "Theme B: "
		      (mapcar (lambda (i) (list (symbol-name (car i))))
			      color-themes)
		      (lambda (i) (string-match "color-theme" (car i)))))))
  ;; install the themes in a new frame and get the definitions
  (let ((color-theme-is-global nil))
    (select-frame (make-frame))
    (funcall theme-a)
    (setq theme-a (list theme-a
			(color-theme-get-params)
			(color-theme-get-vars)
			(color-theme-get-face-definitions)))
    (funcall theme-b)
    (setq theme-b (list theme-b
			(color-theme-get-params)
			(color-theme-get-vars)
			(color-theme-get-face-definitions)))
    (delete-frame))
  (let ((params (set-difference
		 (color-theme-frame-params theme-b)
		 (color-theme-frame-params theme-a)
		 :test 'equal))
	(vars (set-difference
	       (color-theme-variables theme-b)
	       (color-theme-variables theme-a)
	       :test 'equal))
	(faces (set-difference
		(color-theme-faces theme-b)
		(color-theme-faces theme-a)
		:test 'equal)))
    (list 'diff
	  params
	  vars
	  faces)))



;;; Installing a color theme
;;;###autoload
(defun color-theme-install (theme)
  "Install a color theme defined by frame parameters, variables and faces.

The theme is installed for all present and future frames; any missing
faces are created.  See `color-theme-install-faces'.

THEME is a color theme definition.  See below for more information.

If you want to install a color theme from your .emacs, use the output
generated by `color-theme-print'.  This produces color theme function
which you can copy to your .emacs.

A color theme definition is a list:
\([FUNCTION] FRAME-PARAMETERS VARIABLE-SETTINGS FACE-DEFINITIONS)

FUNCTION is the color theme function which called `color-theme-install'.
This is no longer used.  There was a time when this package supported
automatic factoring of color themes.  This has been abandoned.

FRAME-PARAMETERS is an alist of frame parameters.  These are installed
with `color-theme-install-frame-params'.  These are installed last such
that any changes to the default face can be changed by the frame
parameters.

VARIABLE-DEFINITIONS is an alist of variable settings.  These are
installed with `color-theme-install-variables'.

FACE-DEFINITIONS is an alist of face definitions.  These are installed
with `color-theme-install-faces'.

If `color-theme-is-cumulative' is nil, a color theme will undo face and
frame-parameter settings of previous color themes."
  (setq theme (color-theme-canonic theme))
  (color-theme-install-variables (color-theme-variables theme))
  (color-theme-install-faces (color-theme-faces theme))
  ;; frame parameters override faces
  (color-theme-install-frame-params (color-theme-frame-params theme))
  (when color-theme-history-max-length
    (color-theme-add-to-history
     (car theme))))



;; Sharing your stuff
;;;###autoload
(defun color-theme-submit ()
  "Submit your color-theme to the maintainer."
  (interactive)
  (require 'reporter)
  (let ((reporter-eval-buffer (current-buffer))
	final-resting-place
	after-sep-pos
	(reporter-status-message "Formatting buffer...")
	(reporter-status-count 0)
	(problem "Yet another color-theme")
	(agent (reporter-compose-outgoing))
	(mailbuf (current-buffer))
	hookvar)
    ;; do the work
    (require 'sendmail)
    ;; If mailbuf did not get made visible before, make it visible now.
    (let (same-window-buffer-names same-window-regexps)
      (pop-to-buffer mailbuf)
      ;; Just in case the original buffer is not visible now, bring it
      ;; back somewhere
      (and pop-up-windows (display-buffer reporter-eval-buffer)))
    (goto-char (point-min))
    (mail-position-on-field "to")
    (insert color-theme-maintainer-address)
    (mail-position-on-field "subject")
    (insert problem)
    ;; move point to the body of the message
    (mail-text)
    (setq after-sep-pos (point))
    (unwind-protect
	(progn
	  (setq final-resting-place (point-marker))
	  (goto-char final-resting-place))
      (color-theme-print (current-buffer))
      (goto-char final-resting-place)
      (insert "\n\n")
      (goto-char final-resting-place)
      (insert "Hello there!\n\nHere's my color theme named: ")
      (set-marker final-resting-place nil))
    ;; compose the minibuf message and display this.
    (let* ((sendkey-whereis (where-is-internal
			     (get agent 'sendfunc) nil t))
	   (abortkey-whereis (where-is-internal
			      (get agent 'abortfunc) nil t))
	   (sendkey (if sendkey-whereis
			(key-description sendkey-whereis)
		      "C-c C-c")); TBD: BOGUS hardcode
	   (abortkey (if abortkey-whereis
			 (key-description abortkey-whereis)
		       "M-x kill-buffer"))); TBD: BOGUS hardcode
      (message "Enter a message and type %s to send or %s to abort."
	       sendkey abortkey))))



;; Use this to define themes
(defmacro define-color-theme (name author description &rest forms)
  (let ((n name))
    `(progn 
       (add-to-list 'color-themes
                    (list ',n
                          (upcase-initials
                           (replace-in-string
                            (replace-in-string 
                             (symbol-name ',n) "^color-theme-" "") "-" " "))
                          ,author))
       (defun ,n ()
	 ,description
	 (interactive)
         ,@forms))))


;;; FIXME: is this useful ??
;;;###autoload
(defun color-theme-initialize ()
  "Initialize the color theme package by loading color-theme-libraries."
  (interactive)

  (color-theme-initialize)
)

(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-hober)))


(defun color-theme-monokai ()
  "Monokai color theme for Emacs by Operator.
Based on the TextMate theme Monokai"
  (interactive)
  (color-theme-install
   '(color-theme-monokai
     ((foreground-color . "#F8F8F2")
      (background-color . "#272822")
      (background-mode . dark)
      (cursor-color . "#73d216") ; medium chameleon
      (mouse-color . "#73d216"))

     ;;; Standard font lock faces
     (default ((t (nil))))
     (font-lock-comment-face ((t (:foreground "#75715E")))) ; dark aluminum
     (font-lock-comment-delimiter-face ((t (:foreground "#75715E")))) ; dark aluminum
     (font-lock-doc-face ((t (:foreground "#75715E")))) ; plum
     (font-lock-doc-string-face ((t (:foreground "#75715E")))) ; plum
     (font-lock-string-face ((t (:foreground "#E6DB74")))) ; plum
     (font-lock-keyword-face ((t (:foreground "#F92672")))) ; light sky blue
     (font-lock-builtin-face ((t (:foreground "#855c1b")))) ; med-dark chocolate
     (font-lock-function-name-face ((t (:foreground "#A6E22E")))) ; dark butter
     (font-lock-variable-name-face ((t (:foreground "#FD971F"))))
     (font-lock-preprocessor-face ((t (:foreground "#66D9EF")))) ; aluminum
     (font-lock-constant-face ((t (:foreground "#4e9a06")))) ; dark chameleon
     (font-lock-type-face ((t (:foreground "#66D9EF")))) ; light plum
     (font-lock-warning-face ((t (:bold t :foreground "#cc0000")))) ; scarlet red

     ;; Search
     (isearch ((t (:foreground "#080808" :background "#edd400"))))
     (isearch-lazy-highlight-face ((t (:foreground "#080808" :background "#75715E"))))

     ;; Emacs Interface
     (fringe ((t (:background "#0f0f0f"))))
     (border ((t (:background "#0f0f0f"))))
     (mode-line ((t (:background "#1f1f1f" :foreground "#eeeeec"))))
     (mode-line-buffer-id ((t (:background "#1f1f1f" :foreground "#eeeeec"))))
     (mode-line-inactive ((t (:background "#1f1f1f" :foreground "#888a85"))))
     (minibuffer-prompt ((t (:foreground "#729fcf")))) ; light sky blue
     (region ((t (:background "#49483E"))))

     ;; Parenthesis matching
     (show-paren-match-face ((t (:foreground "#2e3436" :background "#cc0000"))))
     (show-paren-mismatch-face ((t (:foreground "#2e3436" :background "#cc0000"))))

     ;; Calendar
     (holiday-face ((t (:foreground "#cc0000")))) ; dark scarlet red

     ;; Info
     (info-xref ((t (:foreground "#729fcf")))) ; light sky blue
     (info-xref-visited ((t (:foreground "#ad7fa8")))) ; light plum

     ;;; AUCTeX
     (font-latex-sectioning-5-face ((t (:foreground "#c4a000" :bold t)))) ; dark butter
     (font-latex-bold-face ((t (:foreground "#4e9a06" :bold t)))) ; dark chameleon
     (font-latex-italic-face ((t (:foreground "#4e9a06" :italic t)))) ; dark chameleon
     (font-latex-math-face ((t (:foreground "#855c1b")))) ; med-dark chocolate
     (font-latex-string-face ((t (:foreground "#77507b")))) ; plum
     (font-latex-warning-face ((t (:foreground "#cc0000")))) ; dark scarlet red
     (font-latex-slide-title-face ((t (:foreground "#c4a000")))) ; dark butter
     )))

(color-theme-monokai)
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#272822" :foreground "#F8F8F2" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

;;; Code:
;;
;; cmake executable variable used to run cmake --help-command
;; on commands in cmake-mode
;;
;; cmake-command-help Written by James Bigler
;;

(defcustom cmake-mode-cmake-executable "cmake"
  "*The name of the cmake executable.

This can be either absolute or looked up in $PATH.  You can also
set the path with these commands:
 (setenv \"PATH\" (concat (getenv \"PATH\") \";C:\\\\Program Files\\\\CMake 2.8\\\\bin\"))
 (setenv \"PATH\" (concat (getenv \"PATH\") \":/usr/local/cmake/bin\"))"
  :type 'file
  :group 'cmake)
;;
;; Regular expressions used by line indentation function.
;;
(defconst cmake-regex-blank "^[ \t]*$")
(defconst cmake-regex-comment "#.*")
(defconst cmake-regex-paren-left "(")
(defconst cmake-regex-paren-right ")")
(defconst cmake-regex-argument-quoted
  "\"\\([^\"\\\\]\\|\\\\\\(.\\|\n\\)\\)*\"")
(defconst cmake-regex-argument-unquoted
  "\\([^ \t\r\n()#\"\\\\]\\|\\\\.\\)\\([^ \t\r\n()#\\\\]\\|\\\\.\\)*")
(defconst cmake-regex-token (concat "\\(" cmake-regex-comment
                                    "\\|" cmake-regex-paren-left
                                    "\\|" cmake-regex-paren-right
                                    "\\|" cmake-regex-argument-unquoted
                                    "\\|" cmake-regex-argument-quoted
                                    "\\)"))
(defconst cmake-regex-indented (concat "^\\("
                                       cmake-regex-token
                                       "\\|" "[ \t\r\n]"
                                       "\\)*"))
(defconst cmake-regex-block-open
  "^\\(if\\|macro\\|foreach\\|else\\|elseif\\|while\\|function\\)$")
(defconst cmake-regex-block-close
  "^[ \t]*\\(endif\\|endforeach\\|endmacro\\|else\\|elseif\\|endwhile\\|endfunction\\)[ \t]*(")

;------------------------------------------------------------------------------

;;
;; Helper functions for line indentation function.
;;
(defun cmake-line-starts-inside-string ()
  "Determine whether the beginning of the current line is in a string."
  (if (save-excursion
        (beginning-of-line)
        (let ((parse-end (point)))
          (goto-char (point-min))
          (nth 3 (parse-partial-sexp (point) parse-end))
          )
        )
      t
    nil
    )
  )

(defun cmake-find-last-indented-line ()
  "Move to the beginning of the last line that has meaningful indentation."
  (let ((point-start (point))
        region)
    (forward-line -1)
    (setq region (buffer-substring-no-properties (point) point-start))
    (while (and (not (bobp))
                (or (looking-at cmake-regex-blank)
                    (cmake-line-starts-inside-string)
                    (not (and (string-match cmake-regex-indented region)
                              (= (length region) (match-end 0))))))
      (forward-line -1)
      (setq region (buffer-substring-no-properties (point) point-start))
      )
    )
  )

;------------------------------------------------------------------------------

;;
;; Line indentation function.
;;
(defun cmake-indent ()
  "Indent current line as CMAKE code."
  (interactive)
  (if (cmake-line-starts-inside-string)
      ()
    (if (bobp)
        (cmake-indent-line-to 0)
      (let (cur-indent)

        (save-excursion
          (beginning-of-line)

          (let ((point-start (point))
                (case-fold-search t)  ;; case-insensitive
                token)

            ; Search back for the last indented line.
            (cmake-find-last-indented-line)

            ; Start with the indentation on this line.
            (setq cur-indent (current-indentation))

            ; Search forward counting tokens that adjust indentation.
            (while (re-search-forward cmake-regex-token point-start t)
              (setq token (match-string 0))
              (if (string-match (concat "^" cmake-regex-paren-left "$") token)
                  (setq cur-indent (+ cur-indent cmake-tab-width))
                )
              (if (string-match (concat "^" cmake-regex-paren-right "$") token)
                  (setq cur-indent (- cur-indent cmake-tab-width))
                )
              (if (and
                   (string-match cmake-regex-block-open token)
                   (looking-at (concat "[ \t]*" cmake-regex-paren-left))
                   )
                  (setq cur-indent (+ cur-indent cmake-tab-width))
                )
              )
            (goto-char point-start)

            ; If this is the end of a block, decrease indentation.
            (if (looking-at cmake-regex-block-close)
                (setq cur-indent (- cur-indent cmake-tab-width))
              )
            )
          )

        ; Indent this line by the amount selected.
        (if (< cur-indent 0)
            (cmake-indent-line-to 0)
          (cmake-indent-line-to cur-indent)
          )
        )
      )
    )
  )

(defun cmake-point-in-indendation ()
  (string-match "^[ \\t]*$" (buffer-substring (point-at-bol) (point))))

(defun cmake-indent-line-to (column)
  "Indent the current line to COLUMN.
If point is within the existing indentation it is moved to the end of
the indentation.  Otherwise it retains the same position on the line"
  (if (cmake-point-in-indendation)
      (indent-line-to column)
    (save-excursion (indent-line-to column))))

;------------------------------------------------------------------------------

;;
;; Helper functions for buffer
;;
(defun unscreamify-cmake-buffer ()
  "Convert all CMake commands to lowercase in buffer."
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "^\\([ \t]*\\)\\(\\w+\\)\\([ \t]*(\\)" nil t)
    (replace-match
     (concat
      (match-string 1)
      (downcase (match-string 2))
      (match-string 3))
     t))
  )

;------------------------------------------------------------------------------

;;
;; Keyword highlighting regex-to-face map.
;;
(defconst cmake-font-lock-keywords
  (list '("^[ \t]*\\(\\w+\\)[ \t]*(" 1 font-lock-function-name-face))
  "Highlighting expressions for CMAKE mode."
  )

;------------------------------------------------------------------------------

;;
;; Syntax table for this mode.  Initialize to nil so that it is
;; regenerated when the cmake-mode function is called.
;;
(defvar cmake-mode-syntax-table nil "Syntax table for cmake-mode.")
(setq cmake-mode-syntax-table nil)

;;
;; User hook entry point.
;;
(defvar cmake-mode-hook nil)

;;
;; Indentation increment.
;;
(defvar cmake-tab-width 2)

;------------------------------------------------------------------------------

;;
;; CMake mode startup function.
;;
;;;###autoload
(defun cmake-mode ()
  "Major mode for editing CMake listfiles."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'cmake-mode)
  (setq mode-name "CMAKE")

  ; Create the syntax table
  (setq cmake-mode-syntax-table (make-syntax-table))
  (set-syntax-table cmake-mode-syntax-table)
  (modify-syntax-entry ?_  "w" cmake-mode-syntax-table)
  (modify-syntax-entry ?\(  "()" cmake-mode-syntax-table)
  (modify-syntax-entry ?\)  ")(" cmake-mode-syntax-table)
  (modify-syntax-entry ?# "<" cmake-mode-syntax-table)
  (modify-syntax-entry ?\n ">" cmake-mode-syntax-table)

  ; Setup font-lock mode.
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(cmake-font-lock-keywords))

  ; Setup indentation function.
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'cmake-indent)

  ; Setup comment syntax.
  (make-local-variable 'comment-start)
  (setq comment-start "#")

  ; Run user hooks.
  (run-hooks 'cmake-mode-hook))

; Help mode starts here


;;;###autoload
(defun cmake-command-run (type &optional topic buffer)
  "Runs the command cmake with the arguments specified.  The
optional argument topic will be appended to the argument list."
  (interactive "s")
  (let* ((bufname (if buffer buffer (concat "*CMake" type (if topic "-") topic "*")))
         (buffer  (if (get-buffer bufname) (get-buffer bufname) (generate-new-buffer bufname)))
         (command (concat cmake-mode-cmake-executable " " type " " topic))
         ;; Turn of resizing of mini-windows for shell-command.
         (resize-mini-windows nil)
         )
    (shell-command command buffer)
    (save-selected-window
      (select-window (display-buffer buffer 'not-this-window))
      (cmake-mode)
      (toggle-read-only t))
    )
  )

;;;###autoload
(defun cmake-help-list-commands ()
  "Prints out a list of the cmake commands."
  (interactive)
  (cmake-command-run "--help-command-list")
  )

(defvar cmake-commands '() "List of available topics for --help-command.")
(defvar cmake-help-command-history nil "Command read history.")
(defvar cmake-modules '() "List of available topics for --help-module.")
(defvar cmake-help-module-history nil "Module read history.")
(defvar cmake-variables '() "List of available topics for --help-variable.")
(defvar cmake-help-variable-history nil "Variable read history.")
(defvar cmake-properties '() "List of available topics for --help-property.")
(defvar cmake-help-property-history nil "Property read history.")
(defvar cmake-help-complete-history nil "Complete help read history.")
(defvar cmake-string-to-list-symbol
  '(("command" cmake-commands cmake-help-command-history)
    ("module" cmake-modules cmake-help-module-history)
    ("variable"  cmake-variables cmake-help-variable-history)
    ("property" cmake-properties cmake-help-property-history)
    ))

(defun cmake-get-list (listname)
  "If the value of LISTVAR is nil, run cmake --help-LISTNAME-list
and store the result as a list in LISTVAR."
  (let ((listvar (car (cdr (assoc listname cmake-string-to-list-symbol)))))
    (if (not (symbol-value listvar))
        (let ((temp-buffer-name "*CMake Temporary*"))
          (save-window-excursion
            (cmake-command-run (concat "--help-" listname "-list") nil temp-buffer-name)
            (with-current-buffer temp-buffer-name
              (set listvar (cdr (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t))))))
      (symbol-value listvar)
      ))
  )

(require 'thingatpt)
(defun cmake-help-type (type)
  (let* ((default-entry (word-at-point))
         (history (car (cdr (cdr (assoc type cmake-string-to-list-symbol)))))
         (input (completing-read
                 (format "CMake %s: " type) ; prompt
                 (cmake-get-list type) ; completions
                 nil ; predicate
                 t   ; require-match
                 default-entry ; initial-input
                 history
                 )))
    (if (string= input "")
        (error "No argument given")
      input))
  )

;;;###autoload
(defun cmake-help-command ()
  "Prints out the help message for the command the cursor is on."
  (interactive)
  (cmake-command-run "--help-command" (cmake-help-type "command") "*CMake Help*"))

;;;###autoload
(defun cmake-help-module ()
  "Prints out the help message for the module the cursor is on."
  (interactive)
  (cmake-command-run "--help-module" (cmake-help-type "module") "*CMake Help*"))

;;;###autoload
(defun cmake-help-variable ()
  "Prints out the help message for the variable the cursor is on."
  (interactive)
  (cmake-command-run "--help-variable" (cmake-help-type "variable") "*CMake Help*"))

;;;###autoload
(defun cmake-help-property ()
  "Prints out the help message for the property the cursor is on."
  (interactive)
  (cmake-command-run "--help-property" (cmake-help-type "property") "*CMake Help*"))

;;;###autoload
(defun cmake-help ()
  "Queries for any of the four available help topics and prints out the approriate page."
  (interactive)
  (let* ((default-entry (word-at-point))
         (command-list (cmake-get-list "command"))
         (variable-list (cmake-get-list "variable"))
         (module-list (cmake-get-list "module"))
         (property-list (cmake-get-list "property"))
         (all-words (append command-list variable-list module-list property-list))
         (input (completing-read
                 "CMake command/module/variable/property: " ; prompt
                 all-words ; completions
                 nil ; predicate
                 t   ; require-match
                 default-entry ; initial-input
                 'cmake-help-complete-history
                 )))
    (if (string= input "")
        (error "No argument given")
      (if (member input command-list)
          (cmake-command-run "--help-command" input "*CMake Help*")
        (if (member input variable-list)
            (cmake-command-run "--help-variable" input "*CMake Help*")
          (if (member input module-list)
              (cmake-command-run "--help-module" input "*CMake Help*")
            (if (member input property-list)
                (cmake-command-run "--help-property" input "*CMake Help*")
              (error "Not a know help topic.") ; this really should not happen
              ))))))
  )

;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
  (add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode)))
