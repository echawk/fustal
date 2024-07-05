#!/usr/bin/env emacs --script

;; Emacs lisp version of gendocs.

(setq source-file (nth 0 argv))

(message "\\documentclass{article}\n
\\usepackage{amsmath}\n
\\newcommand{\\divider}{\\par\\noindent\\rule{\\textwidth}{1pt}}\n
\\begin{document}\n")

(message
 (with-temp-buffer
   (insert-file-contents source-file)
   (keep-lines (rx bol (or (: "-- " (or "desc" "equation"))
                           "entry")))
   (replace-regexp-in-region (rx "-- desc: " (group-n 1 (0+ any) eol))
                             "\n\\\\noindent\nDescription:\n\n \\1 \n\n")
   (replace-regexp-in-region
    (rx "-- equation: " (group-n 1 (+ any) eol))
    "\\\\begin{center}\n \\1 \n\\\\end{center}")

   (replace-regexp-in-region
    (rx bol "entry" (1+ " ") (group-n 1 (1+ (not " "))) (1+ " ") (group-n 2 (1+ any)) "=")
"\\\\noindent\nFunction Name: \\\\begin{verbatim} \\1 \\\\end{verbatim}\n
\\\\noindent\nFunction Type Signature: \\\\begin{verbatim} \\2 \\\\end{verbatim}\n
\\\\divider\n")

   (delete-matching-lines (rx bol "--"))
   (buffer-substring-no-properties (point-min) (point-max))))
(message"\n\\end{document}")
