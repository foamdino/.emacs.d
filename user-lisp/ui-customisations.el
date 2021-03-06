; colour scheme
(add-to-list 'load-path "~/.emacs.d/user-lisp/color-theme")

(require 'color-theme)
;(require 'color-theme-tango)
(require 'color-theme-zenburn)
;(color-theme-tango)
(color-theme-zenburn)

(set-default-font "-*-terminus-medium-*-*-*-*-*-*-*-*-*-cp1251")
                                        ;
; hide toolbar and scrollbar
(tool-bar-mode 0)
(scroll-bar-mode 0)

; show x-position (ie column number) for point in buffer
(column-number-mode 1)

; always highlight matching parentheses
(show-paren-mode 1)

; always highlight line that cursor is on
(global-hl-line-mode 1)

; always truncate lines (i.e. don't wrap lines)
(setq-default truncate-lines t)

; show file name in window title
(setq frame-title-format "%b - emacs")

(provide 'ui-customisations)
