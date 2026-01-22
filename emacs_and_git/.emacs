;--> a killall emacs is needed after any change to this file

; C/C++ environemnt
; from: https://github.com/tuhdo/emacs-c-ide-demo
;(load-file "~/.emacs.d/init.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
 '(global-whitespace-mode t)
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(dockerfile-mode go-mode js2-mode json-mode markdown-mode neotree
                     py-autopep8 rust-mode scss-mode swagg treemacs
                     typescript-mode yaml-mode)))
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
 '(default ((t (:inherit nil :stipple nil :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 158 :width normal :foundry "PfEd" :family "DejaVu Sans Mono")))))

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
(require 'swagg)

(defun my/swagger-browser-preview ()
  "Open the local swagger-ui-watcher page."
  (interactive)
  ;; This assumes you have started 'swagger-ui-watcher' in a terminal
  (browse-url "http://127.0.0.1:8000"))

(global-set-key (kbd "C-c C-p") 'my/swagger-browser-preview)

;; Add this to your init.el
(require 'treemacs)
(global-set-key (kbd "C-x t") 'treemacs)


(use-package treemacs
  :ensure t
  :bind
  (:map global-map
;        ("C-x d" . treemacs-select-window)
        ("M-0"   . treemacs-select-window))
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-project-follow-mode t)
  (add-hook 'window-setup-hook 'treemacs))

;go install golang.org/x/tools/gopls@latest
;install in package-list-packages: yasnippert, company, go-mode

;; --- 1. PATH SETUP ---
;; This ensures Emacs can find 'gopls' installed in your ~/go/bin
(setenv "PATH" (concat (expand-file-name "~/go/bin") path-separator (getenv "PATH")))
(add-to-list 'exec-path (expand-file-name "~/go/bin"))

;; --- 2. COMPLETION ENGINE (Company Mode) ---
(use-package company
  :ensure t
  :init
  (global-company-mode)
  :config
  (setq company-idle-delay 0.05            ; Show menu almost instantly
        company-minimum-prefix-length 1   ; Show menu after 1 character
        company-tooltip-align-annotations t)
  ;; This connects Company to Eglot's LSP data
  (setq company-backends '((company-capf :with company-yasnippet))))

;; --- 3. GO MODE & LSP (Eglot) ---
(setq gofmt-args '("-s"))

(defun my-go-mode-before-save-hook ()
  "Function to run before saving Go files."
  ;; Check if we are in go-mode OR go-ts-mode (for Emacs 29+)
  (when (or (derived-mode-p 'go-mode) 
            (derived-mode-p 'go-ts-mode))
    (message "SAVE HOOK TRIGGERED!")
    (gofmt-before-save) ; This handles the -s simplify flag
    (ignore-errors (eglot-format-buffer))
    (ignore-errors (eglot-code-action-organize-imports 1))))

;; ADD THIS OUTSIDE OF USE-PACKAGE
;; This ensures the hook exists the moment Emacs starts
(add-hook 'before-save-hook #'my-go-mode-before-save-hook)

(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :hook (go-mode . eglot-ensure))

;; --- 4. EGLOT SETTINGS ---
(with-eval-after-load 'eglot
  (setq eglot-report-progress nil)
  (add-to-list 'eglot-server-programs '(go-mode . ("gopls"))))

;; --- 5. YASNIPPET ---
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(setq create-lockfiles nil)
(setq auto-save-file-name-transforms
      `((".*" ,(temporary-file-directory) t)))

(add-hook 'before-save-hook (lambda () (message "SAVE HOOK TRIGGERED!")) nil t)
