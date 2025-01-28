;;; emacs-lisp-ts-mode.el --- Elisp treesit major mode

;; Author: Gabriel Frigo <gabriel.frigo4@gmail.com>
;; URL: https://github.com/GabrielFrigo4/.emacs.d
;; Version: 0.0.1

;; This file is NOT part of GNU Emacs.

;; Copyright (c) 2025-2025, Gabriel Frigo
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;   * Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;   * Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;; IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
;; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;; PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
;; OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Code:

;; Import *treesit*
(require 'treesit)

;; Set *macro-names*
(setq-local macro-names '())
(mapatoms (lambda (symbol)
            (when (macrop symbol)
              (push (symbol-name symbol) macro-names))))
(setq-local macro-names (cl-sort macro-names 'string-lessp :key 'downcase))
(push "require" macro-names)

;; Def *emacs-lisp-ts-mode--builtins*
(defvar emacs-lisp-ts-mode--builtins
  macro-names)

;; Def *emacs-lisp-ts-mode--keywords*
(defvar emacs-lisp-ts-mode--keywords
  '("defun" "defsubst" "defmacro" "defconst" "defvar"
    ;; Special forms
    "if" "while" "catch" "cond" "condition-case" "function"
    "interactive" "lambda" "let" "let*" "prog1" "prog2" "progn"
    "save-restriction" "save-current-buffer" "save-excursion"
    "quote" "setq" "setq-default" "unwind-protect"))

;; Def *emacs-lisp-ts-mode--operators*
(defvar emacs-lisp-ts-mode--operators
  '("*" "/" "%" "+" "-" "mod" "incf" "decf"
    "=" "/=" "<" ">" ">=" "<=" "max" "min"
    "and" "or" "not"))

;; Def *emacs-lisp-ts-mode--fontify-parameters*
(defun emacs-lisp-ts-mode--fontify-parameters (node override start end &rest _)
  (treesit-fontify-with-override
   (treesit-node-start node)
   (treesit-node-end node)
   (if (string-prefix-p "&" (treesit-node-text node))
       'font-lock-type-face
     'font-lock-variable-name-face)
   override start end))

;; Def *emacs-lisp-ts-mode--font-lock-settings*
(defvar emacs-lisp-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'elisp
   :feature 'comment
   `((comment) @font-lock-comment-face)

   :language 'elisp
   :feature 'string
   `((string) @font-lock-string-face)

   :language 'elisp
   :feature 'number
   `([(integer) (float)] @font-lock-number-face)

   :language 'elisp
   :feature 'operator
   `(((symbol) @font-lock-operator-face
      (:match ,(rx-to-string
                `(seq bol
                      (or ,@emacs-lisp-ts-mode--operators)
                      eol))
              @font-lock-operator-face)))

   :language 'elisp
   :feature 'keyword
   `([,@emacs-lisp-ts-mode--keywords] @font-lock-keyword-face
     (quote ["`" "'" "#'"] @font-lock-keyword-face)
     (unquote_splice ",@" @font-lock-keyword-face)
     (unquote "," @font-lock-keyword-face))

   :language 'elisp
   :feature 'constant
   `(["t" "nil"] @font-lock-constant-face
     (char) @font-lock-constant-face)

   :language 'elisp
   :feature 'definition
   `((special_form
      _ ["defvar" "setq" "setq-default" "let"] (symbol) @font-lock-variable-name-face)

     (function_definition
      name: (symbol) @font-lock-function-name-face
      parameters: (list _ (symbol) @emacs-lisp-ts-mode--fontify-parameters :*))

     (macro_definition
      name: (symbol) @font-lock-keyword-face
      parameters: (list _ (symbol) @emacs-lisp-ts-mode--fontify-parameters :*)))

   :language 'elisp
   :feature 'builtin
   `((list _ ((symbol) @font-lock-keyword-face
              (:match ,(rx-to-string
                        `(seq bol
                              (or ,@emacs-lisp-ts-mode--builtins)
                              eol))
                      @font-lock-keyword-face))))

   :language 'elisp
   :feature 'property
   `(((symbol) @font-lock-builtin-face
      (:match ,(rx bol ":") @font-lock-builtin-face)))

   :language 'elisp
   :feature 'preprocessor
   `(((symbol) @font-lock-preprocessor-face
      (:match ,(rx bol "@") @font-lock-preprocessor-face))
     (unquote_splice (symbol) @font-lock-preprocessor-face)
     (unquote (symbol) @font-lock-preprocessor-face))

   :language 'elisp
   :feature 'quoted
   `((quote (symbol) @font-lock-constant-face))

   :language 'elisp
   :feature 'bracket
   `(["(" ")" "[" "]" "#[" "#("] @font-lock-bracket-face)

   :language 'elisp
   :feature 'variable
   `((vector _ ((symbol) @font-lock-variable-name-face)))

   :language 'elisp
   :feature 'callable
   `((list _ ((symbol) @font-lock-function-call-face)))

   :language 'elisp
   :feature 'argument
   `(((symbol) @font-lock-variable-name-face))))

;; Def *emacs-lisp-ts-mode-feature-list*
(defvar emacs-lisp-ts-mode-feature-list
  `((comment)
    (string keyword definition)
    (builtin constant property preprocessor)
    (bracket number operator quoted variable callable argument)))

;; Define Derived Mode *emacs-lisp-ts-mode*
(define-derived-mode emacs-lisp-ts-mode emacs-lisp-mode "ELisp"
  "Major mode for editing Emacs Lisp code using tree-sitter.

Commands:
\\<emacs-lisp-ts-mode-map>"
  (when (treesit-ready-p 'elisp)
    (treesit-parser-create 'elisp)

    (setq-local treesit-font-lock-settings
                emacs-lisp-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                emacs-lisp-ts-mode-feature-list)

    (treesit-major-mode-setup)))

;; Provide *emacs-lisp-ts-mode*
(provide 'emacs-lisp-ts-mode)

;;; emacs-lisp-ts-mode.el