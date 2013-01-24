;; The raelly important keys are M-x ccur and M-x imenu and C-s foo then C-x C-x
(add-to-list 'load-path "C:/Users/Office/.emacs.d/matlab-emacs")
(add-to-list 'load-path "c:/Users/Office/.emacs.d/elpa/smex-2.0/")
(load-library "matlab-load")
(require 'smex)
(smex-initialize)
(global-set-key (kbd "<apps>") 'smex)
(require 'python)
(require 'igrep)
(winner-mode 1)
(kill-buffer "*scratch*")
;;;;;;;;;;;;;;;;;;;;;;;;; GENERAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [?\C-x ?\C-k] 'ido-kill-buffer)
(global-set-key [?\C-=] 'text-scale-increase)
(defadvice quit-window (before quit-window-always-kill)
  "When running `quit-window', always kill the buffer."
  (ad-set-arg 0 t))
(ad-activate 'quit-window)

(global-set-key [?\C-c ?l] 'org-store-link)
(global-set-key [?\C-c ?c] 'org-capture)
(global-set-key [?\C-c ?a] 'org-agenda)
(global-set-key [?\C-c ?b] 'org-iswitchb)

(electric-pair-mode 1)
(global-set-key "" 'newline-and-indent)
(global-set-key "
" (quote newline-and-indent))
(transient-mark-mode 1)
(global-set-key [?\C-a] 'back-to-indentation)
(global-set-key [f1] (quote call-last-kbd-macro))
(global-set-key [home] 'back-to-indentation)
(global-set-key [?\C-x ?9] 'close-and-kill-next-pane)
(defun has-revisit-file-with-coding-windows-1252 ()
    "Re-opens currently visited file with the windows-1252 coding. (By: hassansrc at gmail dot com)
    Example: 
    the currently opened file has french accents showing as codes such as:
        french: t\342ches et activit\340s   (\340 is shown as a unique char) 
    then execute this function: has-revisit-file-with-coding-windows-1252
      consequence: the file is reopened with the windows-1252 coding with no other action on the part of the user. 
                   Hopefully, the accents are now shown properly.
                   Otherwise, find another coding...
    
    "
        (interactive)
        (let ((coding-system-for-read 'windows-1252)
    	  (coding-system-for-write 'windows-1252)
    	  (coding-system-require-warning t)
    	  (current-prefix-arg nil))
          (message "has: Reopened file with coding set to windows-1252")
          (find-alternate-file buffer-file-name)
          )
    )
(defun close-and-kill-next-pane ()
  "Switch to next pane, close buffer, kill window"
  (interactive)
  (other-window 1)
  (kill-buffer-and-window))

(defun select-next-window ()
  "Switch to the next window"
  (interactive)
  (select-window (next-window)))

(defun select-previous-window ()
  "Switch to the previous window"
  (interactive)
  (select-window (previous-window)))

(defun key (desc)
  (or (and window-system (read-kbd-macro desc))
      (or (cdr (assoc desc real-keyboard-keys))
          (read-kbd-macro desc))))

(defconst real-keyboard-keys
  '(("M-<up>"        . [27 up])
    ("M-<down>"      . [27 down])
    ("M-p"           . "p")
    ("M-n"           . "n"))
  "An assoc list of pretty key strings                                                                                                                 
and their terminal equivalents.")

(global-set-key [f12] 'select-next-window)
(global-set-key (key "M-p") 'backward-paragraph)
(global-set-key (key "M-n") 'forward-paragraph)
(defun show-file-name ()
  "Shows the full path file name in the minibuffer an dcopies it to kill-ring"
  (interactive)
  (message (concat "Copied path " (buffer-file-name) " to clipboard"))
  (kill-new (file-truename buffer-file-name))
)
(global-set-key [?\C-c ?\C-s ?\C-f] 'show-file-name)

(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(eval-after-load "flyspell"  '(defun flyspell-mode (&optional arg))) ;;disable flyspell
(setq truncate-lines nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TAGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defadvice find-tag (around refresh-etags activate)
"Rerun etags and reload tags if tag not found and redo find-tag.
If buffer is modified, ask about save before running etags."
(let ((extension (file-name-extension (buffer-file-name))))
(condition-case err
    ad-do-it
  (error (and (buffer-modified-p)
              (not (ding))
              (y-or-n-p "Buffer is modified, save it? ")
              (save-buffer))
         (make-tags extension)
         ad-do-it))))

(defun make-tags (&optional extension)
"Run etags on all peer files in current dir and reload them silently."
(interactive)
(shell-command (format "etags *.%s" (or extension "el")))
(let ((tags-revert-without-query t))  ; don't query, revert silently          
(visit-tags-table default-directory nil)))
(global-set-key [?\M-8] 'pop-tag-mark)
;;;;;;;;;;;;;;;;;;;;;;; MATLAB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
(add-to-list 'auto-mode-alist  '("\\.m$" . matlab-mode))
(setq matlab-indent-function t)
(setq matlab-shell-command "matlab")

;;;;;;;;;;;;;;;;;;;;;; PYTHON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun py-execute-current-line ()
  "Execute the current line assuming it's python"
  (interactive)
  (progn
    (python-send-region (line-beginning-position) (line-end-position))
    (message "Ran line in python")))

(defun pychecker ()
  "Run pychecker against the file behind the current buffer after                                                                                      
  checking if unsaved buffers should be saved."
  (interactive)
  (let* ((file (buffer-file-name (current-buffer)))
                 (command (concat "pychecker " file)))
                 (save-some-buffers (not compilation-ask-about-save) nil) ; save  files.                                                               
                 (compile-internal command "No more errors or warnings" "pychecker"
                                                   nil pychecker-regexp-alist)))
(defun python-ka-hook ()
  ""
  (progn
  (setq pychecker-regexp-alist '(("\\([a-zA-Z]?:?[^:(\t\n]+\\)[:( \t]+\\([0-9]+\\)[:) \t]" 1 2)))
  (global-set-key [?\C-r] 'py-execute-current-line)))
(add-hook 'python-mode-hook 'python-ka-hook)

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ORG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-alphabetical-lists t
      org-startup-indented t
      org-enforce-todo-checkbox-dependencies t
      org-enforce-todo-dependencies t
      org-clock-persist 'history
      org-log-done t
      org-use-tag-inheritance nil
      org-startup-truncated nil
      org-todo-keywords '((sequence "TODO" "IN-PROGRESS" "WAITING" "DONE"))
      org-confirm-babel-evaluate nil
      org-tag-alist '((:startgroup . nil)
                      ("@reading" . ?r)
                      ("@coding" . ?c)
                      ("@errand" . ?e)
                      (:endgroup . nil)
                      (:startgroup . nil)
                      ("@work" . ?w)
                      ("@personal" . ?p)
                      (:endgroup . nil)
                      ))
(define-key mode-specific-map [?a] 'org-agenda)

;; org-clock-persistance-insinutae has a side effect dont shift it behind that eval-after function
(org-clock-persistence-insinuate)
(eval-after-load "org"
  '(progn
     '(defun org-return (&optional indent) "" (interactive) (newline-and-indent))
     (define-prefix-command 'org-todo-state-map)
     (define-key org-mode-map "\C-cx" 'org-todo-state-map)
     (define-key org-mode-map [home] 'org-beginning-of-line)
     (define-key org-todo-state-map "x"
       #'(lambda nil (interactive) (org-todo "CANCELLED")))
     (define-key org-todo-state-map "d"
       #'(lambda nil (interactive) (org-todo "DONE")))
     (define-key org-todo-state-map "f"
       #'(lambda nil (interactive) (org-todo "DEFERRED")))
     (define-key org-todo-state-map "l"
       #'(lambda nil (interactive) (org-todo "DELEGATED")))
     (define-key org-todo-state-map "s"
       #'(lambda nil (interactive) (org-todo "STARTED")))
     (define-key org-todo-state-map "w"
       #'(lambda nil (interactive) (org-todo "WAITING")))
     
     (define-key org-agenda-mode-map "\C-n" 'next-line)
     (define-key org-agenda-keymap "\C-n" 'next-line)
     (define-key org-agenda-mode-map "\C-p" 'previous-line)
     (define-key org-agenda-keymap "\C-p" 'previous-line)))

(defun org-screenshot ()
  "Take a screenshot into a time stamped unique-named file in the same 
directory as the org-buffer and insert a link to this file. This function wont work if the buffer is not saved to a file
"
  (interactive)
  (setq tilde-buffer-filename (replace-regexp-in-string "/" "\\" (buffer-file-name) t t))
  (setq filename (concat (make-temp-name (concat tilde-buffer-filename "_" (format-time-string "%Y%m%d_%H%M%S_")) ) ".jpg"))
  ;; Linux: ImageMagick: (call-process "import" nil nil nil filename)
  ;; Windows: Irfanview
  (call-process "c:\\IrfanView\\i_view32.exe" nil nil nil (concat "/clippaste /convert=" filename))
  (insert (concat "[[file:" filename "]]"))
  (insert (concat "\n" filename))
  ;;(insert-image (create-image filename))
  (funcall 'org-mode)
  (org-display-inline-images))
(global-set-key [f5] 'org-screenshot)

(defun insert-org-line ()
  "Insert org-mode line to file"
  (interactive)
  (insert "-*- mode: org; -*-\n"))
;;(setq org-agenda-files (list "~/org/work.org" "~/org/school.org" "~/org/home.org"))
;; The basic way to turn on a minor mode or run a function when turning on a mode is to use (add-hook 'XXXX-mode-hook 'MY-FUNCTION-NAME)

(org-babel-do-load-languages
    'org-babel-load-languages '((python . t) (R . t)))

(require 'org-inlinetask)

; rememember that to update its C-u C-c # or C-u C-c C-x C-u
(defun org-refresh-everything()
  "An example of how to have emacs 'interact' with the minibuffer use a kbd macro"
  (interactive)
  (progn
  (execute-kbd-macro [?\C-  ?\C- ])
  (beginning-of-buffer)
  (execute-kbd-macro [?\C-c ?\C-c])
  (execute-kbd-macro [?\C-u ?\C-c ?#])
  (execute-kbd-macro [?\C-u ?\C-c ?\C-x ?\C-u])
  (execute-kbd-macro [?\C-u ?\C- ])))

(defun org-ka-hook ()
  "Orgmode hook"
  (progn
    (global-set-key [?\C-r] 'org-refresh-everything)    
    (global-set-key [?\C-c ?q] 'org-set-tags-command)))
(add-hook 'org-mode-hook 'org-ka-hook)
