(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(better-jumper evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; update melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'evil)
  (package-install 'evil))
(require 'evil)
(evil-mode 1)

(require 'view)

(defun my/view-scroll-half-page-down-and-center ()
  "Scroll half a page down and center the cursor."
  (interactive)
  (View-scroll-half-page-forward)
  (recenter))

(defun my/view-scroll-half-page-up-and-center ()
  "Scroll half a page up and center the cursor."
  (interactive)
  (View-scroll-half-page-backward)
  (recenter))

(global-set-key (kbd "C-d") 'my/view-scroll-half-page-down-and-center)
(global-set-key (kbd "C-u") 'my/view-scroll-half-page-up-and-center)

(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)

(require 'saveplace)
(setq-default save-place t)
(save-place-mode 1)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

(setq scroll-margin 99)
(setq scroll-preserve-screen-position 1)
(setq scroll-conservatively 101)

; (unless (package-installed-p 'better-jumper)
;   (package-install 'better-jumper))
; (require 'better-jumper)
; (better-jumper-mode 1)
