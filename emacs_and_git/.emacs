;--> a killall emacs is needed after any change to this file

; C/C++ environemnt
; from: https://github.com/tuhdo/emacs-c-ide-demo
;(load-file "~/.emacs.d/init.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(cua-mode t nil (cua-base))
 '(global-whitespace-mode t)
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(cmake-mode company dap-mode flycheck helm-lsp helm-xref js2-mode
                json-mode lsp-mode lsp-treemacs projectile py-autopep8
                scss-mode typescript-mode yasnippet)))
;(vue-mode yaml-mode dart-mode kotlin-mode swift-mode csharp-mode typescript-mode py-autopep8 js2-mode scss-mode json-mode))))
(blink-cursor-mode 0)

(require 'whitespace)
(setq whitespace-style
(quote (face trailing whitespace-line)))

; install color-theme from emacs-goodies-el
; to avoid but still possible to do:
; download manually color theme from:
; http://www.nongnu.org/color-theme/#sec5
; http://download.savannah.nongnu.org/releases/color-theme/
(add-to-list 'load-path "~/.emacs.d/color-theme-6.6.0/")
(require 'color-theme)
(color-theme-initialize)
(eval-after-load "color-theme" '(color-theme-clarity))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :foreground nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 158 :width normal :foundry "PfEd" :family "DejaVu Sans Mono")))))

(set-face-attribute 'default nil :height 158)

(defun my-frame-toggle ()
  "Maximize/Restore Emacs frame using 'wmctrl'."
  (interactive)
  ;;  (shell-command "wmctrl -r :ACTIVE: -btoggle,maximized_vert,maximized_horz"))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0)))
(global-set-key [(control f4)] 'my-frame-toggle)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;; Prevent Extraneous Tabs
(setq-default indent-tabs-mode nil)

;;; tab size
(setq default-tab-width 4)

(put 'scroll-left 'disabled nil)

;; create a backup file in the backups directory
(defun make-backup-file-name (file)
(concat "~/.emacs_backups/" (file-name-nondirectory file) "~"))

;(require 'package)
;(add-to-list 'package-archives
;    '("marmalade" .
;      "http://marmalade-repo.org/packages/"))
;(package-initialize)

(global-set-key [S-dead-grave] "`")

(define-key key-translation-map [dead-tilde] "~")

; for the backtick with ALT-1
(define-key key-translation-map (kbd "M-1") (kbd "`"))

;; -----------------------------------------------------------------------

; --> for JavaScript
; https://elpa.gnu.org/packages/js2-mode.html

; In the Google Javascript guide, Javascript has 2 letters of indentation
(setq js-indent-level 4)

; To install it as your major mode for JavaScript editing:
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

; You may also want to hook it in for shell scripts running via node.js:

(add-to-list 'interpreter-mode-alist '("node" . js2-mode))

; Support for JSX is available via the derived mode `js2-jsx-mode'.  If you
; also want JSX support, use that mode instead:

(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))
(add-to-list 'interpreter-mode-alist '("node" . js2-jsx-mode))

(setq-default js2-strict-missing-semi-warning nil)
(setq-default js2-strict-trailing-comma-warning nil)

; for indentations in CSS and Javascript
(setq js-indent-level 2)
(setq typescript-indent-level 2)
(setq css-indent-offset 2)
(setq js-switch-indent-offset 2)
(setq js2-indent-switch-body t)

; remove the bell sound when scrolling in the Gnome desktop
(setq ring-bell-function 'ignore)

; html
;(setq sgml-basic-offset 4)
(put 'upcase-region 'disabled nil)

;(prefer-coding-system 'utf-8)

; mode for cshtml
; download file here http://web-mode.org/
;(load-file "~/.emacs.d/web-mode.el")
;(require 'web-mode)
;(add-to-list 'auto-mode-alist '("\\.cshtml\\'" . web-mode))

;; ----> to install less-css-mode from the ELPA repository
; --> uncomment the code below:
;
 (require 'package) ;; You might already have this line
 (add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
; (when (< emacs-major-version 24)
;  ;; For important compatibility libraries like cl-lib
;  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line

; ALT + x list-packages
; CTRL + s less-css-mode
; click with the mouse on install

;https://emacs-lsp.github.io/lsp-mode/tutorials/CPP-guide/
(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))

(global-set-key (kbd "<S-f12>") 'lsp-clangd-find-other-file)
(global-set-key (kbd "<f12>") 'xref-find-definitions)
(global-set-key (kbd "<f9>") 'xref-go-back)
