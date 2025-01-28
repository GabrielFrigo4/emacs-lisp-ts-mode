# emacs-lisp-ts-mode
Major mode in Treesit for editing Emacs Lisp programs

# Get Treesit Grammar
To use this tressit mode you need to download [Elisp Grammar](https://github.com/Wilfred/tree-sitter-elisp) from Emacs

# Installing with Quelpa
If you prefer to use a package manager, you can use [quelpa-use-package](https://github.com/quelpa/quelpa-use-package).

```elisp
;; Install Emacs Lisp for Treesit
(use-package emacs-lisp-ts-mode
  :quelpa (emacs-lisp-ts-mode :fetcher github :repo "GabrielFrigo4/emacs-lisp-ts-mode"))
```