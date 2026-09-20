;;; dots-mode.el --- DotS/Vit major mode -*- lexical-binding: t; -*-

(defvar dots-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?\" "\"" st)
    st))

(defconst dots-font-lock-keywords
  '(("\\_<\\(space\\|pull\\|form\\|proc\\|give\\|begin\\|end\\)\\_>" . font-lock-preprocessor-face)
    ("\\_<\\(module\\|use\\|import\\)\\_>" . font-lock-keyword-face)
    ("\\_<\\(fn\\|set\\|let\\|const\\|call\\|ret\\)\\_>" . font-lock-function-name-face)
    ("\\_<\\(if\\|elif\\|else\\|loop\\|while\\|for\\|break\\|continue\\|try\\|catch\\|throw\\)\\_>" . font-lock-constant-face)
    ("\\_<\\(as\\|and\\|or\\|not\\|in\\|case\\)\\_>" . font-lock-builtin-face)
    ("\\_<\\(true\\|false\\|null\\)\\_>" . font-lock-constant-face)
    ("\\_<\\(int\\|i32\\|i64\\|f64\\|bool\\|string\\|bytes\\|ptr\\|result\\|void\\|any\\)\\_>" . font-lock-type-face)
    ("\\$[A-Za-z_][A-Za-z0-9_]*" . font-lock-variable-name-face)
    ("\\_<[A-Za-z_][A-Za-z0-9_]*\\(?:\\.[A-Za-z0-9_]+\\)+\\_>" . font-lock-function-name-face)
    ("\\_<\\([0-9]+\\)\\_>" . font-lock-constant-face)))

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
