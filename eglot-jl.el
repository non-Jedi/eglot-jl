;;; eglot-jl.el --- Julia support for eglot -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Adam Beckmeyer

;; Version: 2.1.0
;; Author: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; Maintainer: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; URL: https://github.com/non-Jedi/eglot-jl
;; Keywords: convenience, languages
;; Package-Requires: ((emacs "25.1") (eglot "1.4") (julia-mode "0.3"))
;; License: CC0

;; This file is not part of GNU Emacs.

;;; License:

;; To the extent possible under law, Adam Beckmeyer has waived all
;; copyright and related or neighboring rights to eglot-jl. This
;; work is published from: United States.

;;; Commentary:

;; This package loads support for the Julia language server into eglot
;; and package.el.  This provides IDE-like features for editing
;; julia-mode buffers.  After installing this package, to load support
;; for the Julia language server, run eglot-jl-init.  After that,
;; running the eglot function in a julia-mode buffer should work
;; properly.

;;; Code:

(require 'cl-generic)
(require 'eglot)
(require 'project)

(defconst eglot-jl-base (file-name-directory load-file-name))

(defgroup eglot-jl nil
  "Interaction with LanguageServer.jl LSP server via eglot"
  :prefix "eglot-jl-"
  :group 'applications)

(defcustom eglot-jl-julia-command "julia"
  "Command to run the Julia executable."
  :type 'string)

(defcustom eglot-jl-julia-flags nil
  "Extra flags to pass to the Julia executable."
  :type '(repeat string))

(defcustom eglot-jl-depot ""
  "Path or paths (space-separated) to Julia depots.
An empty string uses the default depot for ‘eglot-jl-julia-command’
when the JULIA_DEPOT_PATH environment variable is not set."
  :type 'string)

(defcustom eglot-jl-language-server-project eglot-jl-base
  "Julia project to run language server from.
The project should have LanguageServer and SymbolServer packages
available."
  :type 'string)

;; Make project.el aware of Julia projects
(defun eglot-jl--project-try (dir)
  "Return project instance if DIR is part of a julia project.
Otherwise returns nil"
  (let ((root (or (locate-dominating-file dir "JuliaProject.toml")
                  (locate-dominating-file dir "Project.toml"))))
    (and root (cons 'julia root))))

(cl-defmethod project-roots ((project (head julia)))
  (list (cdr project)))

(defun eglot-jl--ls-invocation (_interactive)
  "Return list of strings to be called to start the Julia language server."
  `(,eglot-jl-julia-command
    "--startup-file=no"
    ,(concat "--project=" eglot-jl-language-server-project)
    ,@eglot-jl-julia-flags
    ,(expand-file-name "eglot-jl.jl" eglot-jl-base)
    ,(file-name-directory (buffer-file-name))
    ,eglot-jl-depot))

;;;###autoload
(defun eglot-jl-init ()
  "Load `eglot-jl' to use eglot with the Julia language server."
  (interactive)
  (add-hook 'project-find-functions #'eglot-jl--project-try)
  (add-to-list 'eglot-server-programs
               ;; function instead of strings to find project dir at runtime
               '(julia-mode . eglot-jl--ls-invocation)))

(provide 'eglot-jl)
;;; eglot-jl.el ends here
