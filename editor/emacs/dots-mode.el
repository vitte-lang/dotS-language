;;; dots-mode.el --- DotS/Vit major mode -*- lexical-binding: t; -*-

(defvar dots-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?\" "\"" st)
    st))

(defconst dots-font-lock-keywords
  '(("\\<\\(space\\|pull\\|form\\|proc\\|const\\|let\\|give\\|loop\\|if\\|else\\|entry\\|at\\)\\>" . font-lock-keyword-face)
    ("\\<\\([0-9]+\\)\\>" . font-lock-constant-face)))

(defun dots-indent-line ()
  (interactive)
  (let ((indent 0)
        (not-indented t))
    (save-excursion
      (beginning-of-line)
      (if (bobp)
          (setq indent 0)
        (while not-indented
          (forward-line -1)
          (cond
           ((looking-at "^[ \t]*}")
            (setq indent (current-indentation))
            (setq not-indented nil))
           ((looking-at ".*{[ \t]*$")
            (setq indent (+ (current-indentation) tab-width))
            (setq not-indented nil))
           ((bobp)
            (setq not-indented nil))))))
    (if (looking-at "^[ \t]*}")
        (setq indent (max 0 (- indent tab-width))))
    (indent-line-to indent)))

(define-derived-mode dots-mode prog-mode "DotS"
  "Major mode for DotS and Vit."
  :syntax-table dots-mode-syntax-table
  (setq-local font-lock-defaults '(dots-font-lock-keywords))
  (setq-local indent-line-function #'dots-indent-line)
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local imenu-generic-expression
              '(("Proc" "^\\s-*proc\\s-+\\([A-Za-z0-9_]+\\)" 1)
                ("Form" "^\\s-*form\\s-+\\([A-Za-z0-9_]+\\)" 1)
                ("Entry" "^\\s-*entry\\s-+at\\s-+\\([A-Za-z0-9_/]+\\)" 1))))

(add-to-list 'auto-mode-alist '("\\.dotS\\'" . dots-mode))
(add-to-list 'auto-mode-alist '("\\.vit\\'" . dots-mode))

(provide 'dots-mode)

