# emacs-lisp-ts-mode
Treesit major mode for editing Emacs Lisp (Elisp) programs

# Get Treesit Grammar
To use this tressit mode you need to download [Treesit Grammar for Elisp][treesit-gramar-elisp] from Emacs using this command `treesit-install-language-grammar`

# Installing with Quelpa
If you prefer to use a package manager, you can use [quelpa-use-package].

```elisp
;; Install Treesit for Emacs Lisp (Elisp) 
(use-package emacs-lisp-ts-mode
  :quelpa (emacs-lisp-ts-mode :fetcher github :repo "GabrielFrigo4/emacs-lisp-ts-mode"))
```

[treesit-gramar-elisp]: https://github.com/Wilfred/tree-sitter-elisp
[quelpa-use-package]: https://github.com/quelpa/quelpa-use-package