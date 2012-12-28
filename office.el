(add-to-list 'load-path "C:/Users/Office/.emacs.d/matlab-emacs")
(load-library "matlab-load")
(setq org-alphabetical-lists t)
(autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
(add-to-list 'auto-mode-alist  '("\\.m$" . matlab-mode))
(setq matlab-indent-function t)
(setq matlab-shell-command "matlab")
(electric-pair-mode 1)
(require 'python)
(global-set-key "" 'newline-and-indent)
(global-set-key "" (quote delete-forward-char))
(transient-mark-mode 1)
(defun py-execute-current-line ()
  "Execute the current line assuming it's python"
  (interactive)
  (python-send-region (line-beginning-position) (line-end-position)))

(setq pychecker-regexp-alist '(("\\([a-zA-Z]?:?[^:(\t\n]+\\)[:( \t]+\\([0-9]+\\)[:) \t]" 1 2)))
(global-set-key "\C-r" 'py-execute-current-line)

(add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m")
(global-set-key (kbd "C-a") 'back-to-indentation)
(global-set-key [f1] (quote call-last-kbd-macro))
(global-set-key [home] 'back-to-indentation)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                                                     
(defun pychecker ()
  "Run pychecker against the file behind the current buffer after                                                                                      
  checking if unsaved buffers should be saved."
  (interactive)
  (let* ((file (buffer-file-name (current-buffer)))
                 (command (concat "pychecker " file)))
                 (save-some-buffers (not compilation-ask-about-save) nil) ; save  files.                                                               
                 (compile-internal command "No more errors or warnings" "pychecker"
                                                   nil pychecker-regexp-alist)))

(defun kill-current-line (&optional n)
  "Emulate dd of vim by C-d"
  (interactive "p")
  (save-excursion
    (beginning-of-line)
    (let ((kill-whole-line t))
      (kill-line n))))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; KEY BINDINGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                                                     
(defconst real-keyboard-keys
  '(("M-<up>"        . [27 up])
    ("M-<down>"      . [27 down])
    ("M-p"           . "p")
    ("M-n"           . "n"))
  "An assoc list of pretty key strings                                                                                                                 
and their terminal equivalents.")

;(global-set-key (kbd "C-d") 'kill-current-line)
(global-set-key [f12] 'select-next-window)
(global-set-key (key "M-p") 'backward-paragraph)
(global-set-key (key "M-n") 'forward-paragraph)
(global-set-key "
" (quote newline-and-indent))

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
         (er-refresh-etags extension)
         ad-do-it))))

(defun er-refresh-etags (&optional extension)
"Run etags on all peer files in current dir and reload them silently."
(interactive)
(shell-command (format "etags *.%s" (or extension "el")))
(let ((tags-revert-without-query t))  ; don't query, revert silently          
(visit-tags-table default-directory nil)))
 
(defun show-file-name ()
  "Shows the full path file name in the minibuffer an dcopies it to kill-ring"
  (interactive)
  (message (concat "Copied path " (buffer-file-name) " to clipboard"))
  (kill-new (file-truename buffer-file-name))
)
(global-set-key "\C-cz" 'show-file-name)

(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))


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
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(defun insert-org-line ()
"Insert org-mode line to file"
(interactive)
(insert "-*- mode: org; -*-\n"))
(setq ispell-program-name "aspell")
(setq ispell-extra-args '("--sug-mode=ultra"))
(eval-after-load "flyspell"  '(defun flyspell-mode (&optional arg)))

(setq truncate-lines nil)

;; The basic way to turn on a minor mode or run a function when turning on a mode is to use (add-hook 'XXXX-mode-hook 'MY-FUNCTION-NAME)
;;(setq org-agenda-files (list "~/org/work.org" "~/org/school.org" "~/org/home.org"))
(setq org-startup-indented t
      org-enforce-todo-checkbox-dependencies t
      org-enforce-todo-dependencies t
      org-clock-persist 'history
      org-log-done t
      org-use-tag-inheritance nil
      org-startup-truncated nil
      org-todo-keywords '((sequence "TODO" "IN-PROGRESS" "WAITING" "DONE"))
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

(org-clock-persistence-insinuate)
(define-key mode-specific-map [?a] 'org-agenda)
(eval-after-load "org"
  '(progn
     
     (define-prefix-command 'org-todo-state-map)
     (define-key org-mode-map "\C-cx" 'org-todo-state-map)
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
     (global-set-key "\C-cq" 'org-set-tags-command)
     (define-key org-agenda-mode-map "\C-n" 'next-line)
     (define-key org-agenda-keymap "\C-n" 'next-line)
     (define-key org-agenda-mode-map "\C-p" 'previous-line)
     (define-key org-agenda-keymap "\C-p" 'previous-line)))

(org-babel-do-load-languages
    'org-babel-load-languages '((python . t) (R . t)))

(setq org-confirm-babel-evaluate nil)
