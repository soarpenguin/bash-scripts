; Use the package manager
(require 'package)

; Sets package management sources
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives 
               '("gnu" . "http://elpa.gnu.org/packages/")))

(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))

; Initialize the package manager
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;color
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Tab
;; set default tab char's display width to 4 spaces
(setq-default tab-width 4)
;; set current buffer's tab char's display width to 4 spaces
(setq tab-width 4)

;;;;;;;;;;;;;;;;;;;;;;;;;evil-mode;;;;;;;;;;;;;;;;
;;;;;;;;;;package-install evil
;;;
;;;;;Use evil mode
;;(require 'evil)
;;(evil-mode t)
;;;;Give us back Ctrl+U for vim emulation
;;(setq evil-want-C-u-scroll t)

;;;;;;;;;;;;;;;;;;;;;;;;;go-mode;;;;;;;;;;;;;;;;
;;;;;;;;;;package-install go-mode
;;;;;;;;;;package-install go-autocomplete
;;;;;;;;;;package-install auto-complete-config
;;;;;GOPATH
;;(setenv "GOPATH" "~/golib/")
;;
;;;;;godoc
;;(defun set-exec-path-from-shell-PATH ()
;;  (let ((path-from-shell (replace-regexp-in-string
;;                          "[ \t\n]*$"
;;                          ""
;;                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
;;    (setenv "PATH" path-from-shell)
;;    (setq eshell-path-env path-from-shell) ; for eshell users
;;    (setq exec-path (split-string path-from-shell path-separator))))
;;
;;(when window-system (set-exec-path-from-shell-PATH))
;;
;;
;;;;;Automatically call gofmt on save
;;(setq exec-path (cons "~/go/bin" exec-path))
;;(add-to-list 'exec-path "~/golib/bin")
;;(add-hook 'before-save-hook 'gofmt-before-save)
;;
;;(require 'auto-complete-config)
;;(require 'go-autocomplete)
;;
;;;;;Autocomplete
;;(defun auto-complete-for-go ()
;;  (auto-complete-mode 1))
;;(add-hook 'go-mode-hook 'auto-complete-for-go)

;;;;;gofmt
;;(defun go-mode-setup ()
;; (go-eldoc-setup)
;; (add-hook 'before-save-hook 'gofmt-before-save))
;;(add-hook 'go-mode-hook 'go-mode-setup)


;;(with-eval-after-load 'go-mode
;;(require 'go-autocomplete))

