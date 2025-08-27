;;misc
(setq inhibit-startup-screen t)
(global-visual-line-mode 1)
(global-display-line-numbers-mode 1)
(delete-selection-mode 1)
(setq select-enable-clipboard t)

;; Top Bar Cleanup
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; spelling
(setq ispell-program-name "aspell")
(setq ispell-extra-args '("--sug-mode=ultra" "--lang=en"))

(add-hook 'text-mode-hook #'flyspell-mode)

;; inherit shell PATH
(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK")) 

;; eval-buffer on save of init.el
(defun reload-init-file-on-save ()
  "Reload init.el automatically after saving."
  (when (string-equal (file-truename user-init-file)
                      (file-truename buffer-file-name))
    (eval-buffer)
    (message "✅ init.el reloaded successfully.")))
;;
(add-hook 'after-save-hook #'reload-init-file-on-save)

;; Enable package manager
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Use 'use-package' for better package management
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; theme
(use-package modus-themes
  :ensure nil                    
  :init

  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs   t
        modus-themes-region 'bg-only    
        modus-themes-org-blocks 'gray-background)
  ;; Load the light theme.  For dark, use 'modus-vivendi.
  (load-theme 'modus-operandi t))

;; fontaine
(use-package fontaine
  :ensure t)

(setq fontaine-presets
      '((regular
	 :default-family "Aporetic Sans Mono"
	 :default-height 120
	 :line spacing 1)
	(large
	 :default-family "Aporetic Sans Mono"
	 :default-height 170
	 :line spacing 1)))

;; eyebrowse
(use-package eyebrowse
  :ensure t
  :config
  (eyebrowse-mode t))

;; pdf-tools
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install) 
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-continuous nil)
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
  (define-key pdf-view-mode-map (kbd "C-s") 'pdf-occur)) ;; Enable search

;; orderless
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; vertico
(use-package vertico
  :init
  (vertico-mode))

;; marginalia
(use-package marginalia
  :ensure t
  :init (marginalia-mode))

;; consult
(use-package consult
  :ensure t
  :bind
  ("C-s" . consult-line))

;; yasnippet
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode 1))

;; which-key
(use-package which-key
  :config (which-key-mode))

;; magit
(use-package magit)
;; refresh verison control state after git checkout to update buffer information
(add-hook 'magit-post-checkout-hook #'vc-refresh-state)

;; Refresh any unmodified file as soon as it changes on disk (incl. Git checkouts)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t) ; refresh *Magit* & *grep* buffers too

;; Disable auto-save files (#file#)
(setq auto-save-default nil)

;; Disable backup files (file~)
(setq make-backup-files nil)

;; Disable lockfiles (.#file)
(setq create-lockfiles nil)

;; eglot
(setq eglot-report-progress nil)

(with-eval-after-load 'eglot
(add-to-list 'eglot-server-programs
             `((java-mode java-ts-mode)
               .
               ("jdtls"
                :initializationOptions
                (
		 :extendedClientCapabilities (:classFileContentsSupport t))))))

;; eat
(use-package eat
  :ensure t
  :custom (eat-term-name "xterm-256color"))


;; groovy mode
(use-package groovy-mode
  :ensure t
  :mode (("\\.gradle\\'"                 . groovy-mode)
         ("\\(settings\\|init\\)\\.gradle\\'" . groovy-mode)))

;; kotlin mode
(use-package kotlin-mode
  :ensure t
  :mode "\\.gradle\\.kts\\'")

;; tree-sitter
(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python")
        (java   "https://github.com/tree-sitter/tree-sitter-java")
	(yaml "https://github.com/ikatyang/tree-sitter-yaml")
	(groovy "https://github.com/Decodetalkers/tree-sitter-groovy" "gh-pages")
        (kotlin "https://github.com/tree-sitter-grammars/tree-sitter-kotlin")
	(bash   "https://github.com/tree-sitter/tree-sitter-bash")))

(setq major-mode-remap-alist
      '((java-mode   . java-ts-mode)
        (python-mode . python-ts-mode)
	(sh-mode     . bash-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.bash\\'"  . bash-ts-mode))
(add-to-list 'auto-mode-alist '("\\.bashrc\\'" . bash-ts-mode))
(add-to-list 'auto-mode-alist '("\\.bash_profile\\'" . bash-ts-mode))
(add-to-list 'auto-mode-alist '("\\.sh\\'"    . bash-ts-mode))

(setq treesit-font-lock-level 4)

;; grammar auto-installer
(dolist (lang '(python java yaml bash kotlin groovy))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; org
(use-package org
  :ensure nil
  :config
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-insert-heading-respect-content t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (with-eval-after-load 'org
  (require 'org-clock))

  (setq org-directory "~/notes")
  (setq org-agenda-files (list (expand-file-name "journal" org-directory)))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAIT(w!)" "BLOCK(b)" "ACTIVE(a)" "|" "CANCEL(c!)" "DONE(d!)")))
  (setq org-todo-keyword-faces
      '(("TODO"    . (:foreground "red" :weight bold))
        ("WAIT"    . (:foreground "orange" :weight bold))
        ("BLOCK"   . (:foreground "blue" :weight bold))
        ("ACTIVE"  . (:foreground "green" :weight bold))
        ("CANCEL"  . (:foreground "grey" :weight bold))
        ("DONE"    . (:foreground "forest green" :weight bold))))
  
  (setq org-agenda-prefix-format
      '((agenda . "%t ")
        (todo   . " ")
        (tags   . " ")
        (search . " ")))

  (setq org-agenda-show-inherited-tags t)
  (setq org-agenda-hide-tags-regexp "\\`journal\\'")

  (setq org-agenda-custom-commands
	'(

	  ("D" "Daily agenda"
	   ((todo "TODO"
		  ((org-agenda-overriding-header "Tasks")))
	    (agenda ""
		    ((org-agenda-block-separator nil)
		     (org-agenda-span 1)
		     (org-agenda-overriding-header "\nDaily Agenda")))))

	  ))
  )

;; clock in function
(defvar my/org-auto-clock-in-states '("ACTIVE"))
(defvar my/org-auto-clock-out-on-leave-states '("ACTIVE"))

(defun my/org-auto-clock-by-state ()
  "Clock in when entering certain states; clock out when leaving them."
  (when (derived-mode-p 'org-mode)
    (let ((new org-state)
          (old org-last-state))
      ;; Entering an 'on' state → clock in (this also clocks out previous task)
      (when (and new (member new my/org-auto-clock-in-states))
        (org-clock-in))
      ;; Leaving an 'on' state → clock out (unless immediately entering another 'on' state)
      (when (and old (member old my/org-auto-clock-out-on-leave-states)
                 (not (and new (member new my/org-auto-clock-in-states))))
        (when (org-clock-is-active) (org-clock-out))))))

(add-hook 'org-after-todo-state-change-hook #'my/org-auto-clock-by-state)

;; modeline
(setq-default mode-line-format
	      '("%e"
		"  "
		modeline-buffer-name
		"    "
		modeline-major-mode
		"    "
		modeline-vc-branch
		"    "
		modeline-org-clock
		))

(defvar modeline-clock-symbol (if (char-displayable-p ?⏱) "⏱" "clk"))
(defvar modeline-org-clock-task-width 40
  "Max display width for the clocked task in the mode line.")

;; Click: jump to the clocked task
(defvar modeline-org-clock-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] #'org-clock-goto)
    map))

(defun modeline--org-clock-time-string ()
  "Return H:MM for current Org clock, or nil if not clocking."
  (when (org-clocking-p)
    (let* ((mins (org-clock-get-clocked-time))
           (h (/ mins 60)) (m (% mins 60)))
      (format "%d:%02d" h m))))

(defun modeline--truncate-end (s width)
  (if (and (numberp width) (> (string-width s) width))
      (truncate-string-to-width s width nil nil "…")
    s))

(defvar-local modeline-org-clock
  '(:eval
    (when-let* ((selected (mode-line-window-selected-p))
                (tstr (modeline--org-clock-time-string))
                (task (or org-clock-current-task "")))
      (setq task (modeline--truncate-end task modeline-org-clock-task-width))
      (concat
       " "
       (propertize modeline-clock-symbol 'face 'mode-line-emphasis)
       " "
       (propertize tstr 'face 'mode-line-emphasis)
       "  "
       (propertize task
                   'face 'mode-line
                   'mouse-face 'mode-line-highlight
                   'help-echo "mouse-1: org-clock-goto"
                   'local-map modeline-org-clock-map))))
  "Modeline segment showing Org clock time and current task.")
(put 'modeline-org-clock 'risky-local-variable t)




(defvar modeline-symbol-modified (if (char-displayable-p ?●) "●" "*")
  "Symbol when buffer has unsaved changes.")
(defvar modeline-symbol-clean    (if (char-displayable-p ?○) "○" "-")
  "Symbol when buffer is unmodified.")
(defvar modeline-symbol-readonly (if (char-displayable-p ?) "" "RO")
  "Symbol when buffer is read-only.")

(defvar-local modeline-buffer-name
  '(:eval
    (let* ((ro  buffer-read-only)
           (mod (buffer-modified-p))
           (sym (cond (ro  modeline-symbol-readonly)
                      (mod modeline-symbol-modified)
                      (t   modeline-symbol-clean)))
           (face (cond (ro  'shadow)
                       (mod 'error)
                       (t   'success))))
      (concat
       (propertize sym 'face face)
       " "
       (propertize (buffer-name) 'face 'bold))))
  "Modeline construct to display a status symbol and the buffer name.")
(put 'modeline-buffer-name 'risky-local-variable t)


(defvar-local modeline-major-mode
    '(:eval
      (format "%s"
	      (propertize (symbol-name major-mode) 'face 'italic)))
      "Modeline construct to display the major mode.")
(put 'modeline-major-mode 'risky-local-variable t)

(declare-function vc-git--symbolic-ref "vc-git" (file))

(defvar modeline-vc-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] #'vc-diff)
    (define-key map [mode-line down-mouse-3] #'vc-root-diff)
    map)
  "Keymap used on VC indicator in the mode line.")

(defun modeline-vc--help-echo (file)
  "Help text for FILE tracked by VC."
  (format "Revision: %s\nmouse-1: vc-diff\nmouse-3: vc-root-diff"
          (vc-working-revision file)))

(defun modeline-vc--branch-name (file backend)
  "Return capitalized branch (or short rev) for FILE under BACKEND."
  (when-let* ((rev (vc-working-revision file backend))
              (branch (or (and (eq backend 'Git)
                               (ignore-errors (vc-git--symbolic-ref file)))
                          (substring rev 0 (min 7 (length rev))))))
    (capitalize branch)))

(defconst modeline-vc--state-faces
  '((added      . vc-locally-added-state)
    (edited     . vc-edited-state)
    (removed    . vc-removed-state)
    (missing    . vc-missing-state)
    (conflict   . vc-conflict-state)
    (locked     . vc-locked-state)
    (up-to-date . vc-up-to-date-state))
  "Mapping from VC state keywords to faces.")

(defun modeline-vc--face (file backend)
  "Face for FILE/Backend based on VC state."
  (when-let ((state (vc-state file backend)))
    (alist-get state modeline-vc--state-faces 'vc-up-to-date-state)))

(defcustom modeline-vc-max-width 32
  "Max width for the VC chunk. Use nil for no truncation."
  :type '(choice (const :tag "No limit" nil) integer))

(defun modeline--truncate-end (s width)
  (if (and (numberp width) (> (string-width s) width))
      (truncate-string-to-width s width nil nil "…")
    s))

(defvar modeline-branch-symbol
  (if (char-displayable-p ?\uE0A0) "  " " vcs: ")
  "Prefix shown before branch name in the mode line.")

(defun modeline-vc--text (file branch face)
  "Build propertized VC text for FILE with BRANCH and FACE."
  (concat
   (propertize modeline-branch-symbol 'face 'shadow)
   (propertize branch
               'face face
               'mouse-face 'mode-line-highlight
               'help-echo (modeline-vc--help-echo file)
               'local-map modeline-vc-map)))

(defvar-local modeline-vc-branch
  '(:eval
    (let ((sel (if (fboundp 'mode-line-window-selected-p)
                   (mode-line-window-selected-p) t)))
      (when (and vc-mode sel)
        (let* ((file    (or buffer-file-name default-directory))
               (backend (or (vc-backend file) 'Git))
               (branch  (modeline-vc--branch-name file backend)))
          (when branch
            (modeline--truncate-end
             (modeline-vc--text file branch (modeline-vc--face file backend))
             modeline-vc-max-width))))))
  "Mode line construct that shows the current VC branch.")
(put 'modeline-vc-branch 'risky-local-variable t)

;; denote
(use-package denote
  :ensure t
  :hook
  (
  (text-mode . denote-fontify-links-mode-maybe)
  (dired-mode . denote-dired-mode))
  :bind
  ;; Denote DOES NOT define any key bindings.  This is for the user to
  ;; decide.  For example:
  ( :map global-map
    ("C-c n n" . denote-open-or-create)    ;; If you intend to use Denote with a variety of file types, it is
    ("C-c n d" . denote-sort-dired)
    ;; easier to bind the link-related commands to the `global-map', as
    ;; shown here.  Otherwise follow the same pattern for `org-mode-map',
    ;; `markdown-mode-map', and/or `text-mode-map'.
    ("C-c n l" . denote-link)
    ("C-c n L" . denote-add-links)
    ("C-c n b" . denote-backlinks)
    ("C-c n q c" . denote-query-contents-link) ; create link that triggers a grep
    ("C-c n q f" . denote-query-filenames-link) ; create link that triggers a dired
    ;; Note that `denote-rename-file' can work from any context, not just
    ;; Dired bufffers.  That is why we bind it here to the `global-map'.
    ("C-c n r" . denote-rename-file)
    ("C-c n R" . denote-rename-file-using-front-matter)

    ;; Key bindings specifically for Dired.
    :map dired-mode-map
    ("C-c C-d C-i" . denote-dired-link-marked-notes)
    ("C-c C-d C-r" . denote-dired-rename-files)
    ("C-c C-d C-k" . denote-dired-rename-marked-files-with-keywords)
    ("C-c C-d C-R" . denote-dired-rename-marked-files-using-front-matter))

  :config
  ;; Remember to check the doc string of each of those variables.
  (setq denote-directory (expand-file-name "~/notes/"))
  (setq denote-save-buffers nil)
  (setq denote-known-keywords '("emacs" "philosophy" "research" "type system" "recipe" "writing" "paper"))
  (setq denote-infer-keywords t)
  (setq denote-sort-keywords t)
  (setq denote-prompts '(title keywords))
  (setq denote-excluded-directories-regexp nil)
  (setq denote-excluded-keywords-regexp nil)
  (setq denote-rename-confirmations '(rewrite-front-matter modify-file-name))
  ;; Pick dates, where relevant, with Org's advanced interface:
  (setq denote-date-prompt-use-org-read-date t)
  ;; Automatically rename Denote buffers using the `denote-rename-buffer-format'.
  (denote-rename-buffer-mode 1))

;; denote journal
(use-package denote-journal
  :ensure t
  :bind
  ( :map global-map
    ("C-c n j j" .  denote-journal-new-or-existing-entry)
    ("C-c n j l" .  denote-journal-link-or-create-entry ))
  :hook (calendar-mode . denote-journal-calendar-mode)
  :config
  ;; Use the "journal" subdirectory of the `denote-directory'.  Set this
  ;; to nil to use the `denote-directory' instead.
  (setq denote-journal-directory
        (expand-file-name "journal" denote-directory))
  ;; Default keyword for new journal entries. It can also be a list of
  ;; strings.
  (setq denote-journal-keyword "journal")
  ;; Read the doc string of `denote-journal-title-format'.
  (setq denote-journal-title-format 'day-date-month-year))

;; denote journal function override for custom layout

(with-eval-after-load 'denote-journal

  (defun denote-journal-path-to-new-or-existing-entry (&optional date)
  "Return path to existing or new journal file.
With optional DATE, do it for that date, else do it for today.  DATE is
a string and has the same format as that covered in the documentation of
the `denote' function.  It is internally processed by `denote-valid-date-p'.

If there are multiple journal entries for the date, prompt for one among
them using minibuffer completion.  If there is only one, return it.  If
there is no journal entry, create it."
  (let* ((internal-date (or (denote-valid-date-p date) (current-time)))
         (files (denote-journal--entry-today internal-date)))
    (if files
        (denote-journal-select-file-prompt files)
        (denote-journal-new-entry date)
        (save-buffer)
        (buffer-file-name)))))


;; agda
(load-file (let ((coding-system-for-read 'utf-8))
             (shell-command-to-string "agda --emacs-mode locate")))

(setq auto-mode-alist
   (append
     '(("\\.agda\\'" . agda2-mode)
       ("\\.lagda.md\\'" . agda2-mode))
     auto-mode-alist))

;; beframe
(use-package beframe
  :ensure t
  :config
  (beframe-mode 1))

;; winner mode 
(use-package winner
  :ensure nil
  :config
  (winner-mode 1))

;; custom layouts
(setq org-agenda-window-setup 'current-window
      org-agenda-restore-windows-after-quit t)

(defun my/layout--journal+agendaD+calendar ()
  "Journal with agenda and calendar layout."
  (split-window-right)
  (org-agenda nil "D")
  (split-window-below)
  (other-window 2)
  (calendar) 
)

(add-hook 'after-make-frame-functions
          (lambda (fr)
            (with-selected-frame fr
              (set-frame-parameter nil 'my-fresh-frame t))))


(defun my/denote-journal--layout-after (&rest _) 
       (when (frame-parameter nil 'my-fresh-frame)
	 (set-frame-parameter nil 'my-fresh-frame nil)
	 (message "Im here")
	 (my/layout--journal+agendaD+calendar)))


(advice-add 'denote-journal-new-or-existing-entry :after #'my/denote-journal--layout-after)

(defun my/layout--standard-project ()
  "Project layout with magit status and eat buffer"
  (split-window-right)
  (magit-status)
  (split-window-below)
  (other-window 1)
  (eat-project)
  )

(defun my/project-switch--layout-after (&rest _)
  (when (frame-parameter nil 'my-fresh-frame)
    (set-frame-parameter nil 'my-fresh-frame nil)
    (my/layout--standard-project)))

(advice-add 'project-switch-project :after #'my/project-switch--layout-after)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil)
 '(safe-local-variable-values '((eval turn-off-auto-fill))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
