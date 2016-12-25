; --> a killall emacs is needed after any change

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-mode t nil (cua-base))
;; '(custom-enabled-themes nil)
 '(inhibit-startup-screen t)
 '(global-whitespace-mode t)
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)

(blink-cursor-mode 0)

(require 'whitespace)
(setq whitespace-style
(quote (face trailing whitespace-line)))

; download manually color theme from:
; http://www.nongnu.org/color-theme/#sec5
; http://download.savannah.nongnu.org/releases/color-theme/
(add-to-list 'load-path "/home/thierry/.emacs.d/color-theme-6.6.0/")
(require 'color-theme)
(color-theme-initialize)
(eval-after-load "color-theme" '(color-theme-clarity))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
'(default ((t (:inherit nil :stipple nil :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 143 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

(defun my-frame-toggle ()
  "Maximize/Restore Emacs frame using 'wmctrl'."
  (interactive)
  ;;  (shell-command "wmctrl -r :ACTIVE: -btoggle,maximized_vert,maximized_horz"))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0)))
(global-set-key [(control f4)] 'my-frame-toggle)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

     ;;; Prevent Extraneous Tabs
(setq-default indent-tabs-mode nil)

;(add-to-list 'load-path "~/ErlangRigEmacsConfig")
;(require 'my-config)

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

;(add-to-list 'load-path "~/.emacs.d/")

; gtags and speedbar
; install gtas with apt-get install global
; http://www.wolinlabs.com/blog/emacs.global.speedbar.html
; emacs commands to get next tags when they are repeated
; http://www.gnu.org/software/emacs/manual/html_node/emacs/Find-Tag.html
(setq load-path (cons "/usr/share/emacs/site-lisp/global" load-path))

(autoload 'gtags-mode "gtags" "" t)

(setq c-mode-hook
      '(lambda ()
         (gtags-mode 1)
         ))

(setq c++-mode-hook
      '(lambda ()
         (gtags-mode 1)
         ))


; http://stackoverflow.com/questions/663588/emacs-c-mode-incorrect-indentation
(setq c-default-style "bsd" c-basic-offset 4)

; python must use tags and not gtags. produce tags with ctags
; find . -type f -name '*.py' | xargs etags

; use M-x speedbar
; Start speedbar automatically if we're using a window system like X, etc
;(when window-system
;   (speedbar t))
; open speedbar with M-x speedbar

; to switch between windows
(global-set-key [C-tab] 'ace-window)

(global-set-key (kbd "C-n") 'speedbar)
(global-set-key (kbd "M-,") 'gtags-pop-stack)
; M-. for gtags-find-tag
(global-set-key (kbd "M-l") 'gtags-find-symbol)

(define-key key-translation-map [dead-tilde] "~")


; -----------------------------------------------------------
; for GDB
; http://dschrempf.github.io/posts/Emacs/2015-06-24-Debugging-with-Emacs-and-GDB.html


(setq gdb-many-windows t)



; to help starting gdb
(defvar gdb-my-history nil "History list for dom-gdb-MYPROG.")
(defun dom-gdb-MYPROG ()
  "Debug MYPROG with `gdb'."
  (interactive)
  (let* ((wd "/path/to/working/directory")
         (pr "/path/to/executable")
         (dt "/path/to/datafile")
         (guess (concat "gdb -i=mi -cd=" wd " --args " pr " -s " dt))
         (arg (read-from-minibuffer "Run gdb (like this): "
                                    guess nil nil 'gdb-my-history)))
    (gdb arg)))



; function dom-gdb-restore-windows, that resets the display and fixes the window layout:
(defun dom-gdb-restore-windows ()
  "Restore GDB session."
  (interactive)
  (if (eq gdb-many-windows t)
      (gdb-restore-windows)
    (dom-gdb-restore-windows-gud-io-and-source)))

(defun dom-gdb-restore-windows-gud-io-and-source ()
  "Restore GUD buffer, IO buffer and source buffer next to each other."
  (interactive)
  ;; Select dedicated GUD buffer.
  (switch-to-buffer gud-comint-buffer)
  (delete-other-windows)
  (set-window-dedicated-p (get-buffer-window) t)
  (when (or gud-last-last-frame gdb-show-main)
    (let ((side-win (split-window nil nil t))
          (bottom-win (split-window)))
      ;; Put source to the right.
      (set-window-buffer
       side-win
       (if gud-last-last-frame
           (gud-find-file (car gud-last-last-frame))
         (gud-find-file gdb-main-file)))
      (setq gdb-source-window side-win)
      ;; Show dedicated IO buffer below.
      (set-window-buffer
       bottom-win
       (gdb-get-buffer-create 'gdb-inferior-io))
      (set-window-dedicated-p bottom-win t))))

(defun dom-gdb-display-source-buffer ()
  "Display gdb source buffer if it is set."
  (interactive)
  (when (or gud-last-last-frame gdb-show-main)
    (switch-to-buffer
     (if gud-last-last-frame
         (gud-find-file (car gud-last-last-frame))
       (gud-find-file gdb-main-file))))
  (delete-other-windows))
