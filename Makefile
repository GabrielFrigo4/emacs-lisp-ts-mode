.POSIX:
.SUFFIXES: .el .elc
EMACS = emacs

compile: emacs-lisp-ts-mode.elc

clean:
	rm -f emacs-lisp-ts-mode.elc

.el.elc:
	$(EMACS) -Q -batch -f batch-byte-compile $<