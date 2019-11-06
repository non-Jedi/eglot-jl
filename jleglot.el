;;; jleglot.el --- Julia support for eglot -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Adam Beckmeyer

;; Version: 0.1.0
;; Author: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; Maintainer: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; URL: https://github.com/non-Jedi/jleglot
;; Keywords: convenience, languages
;; Package-Requires: ((emacs "25.1") (eglot "1.4") (julia-mode "0.3"))

;; This file is not part of GNU Emacs.

;;; License:

;; To the extent possible under law, Adam Beckmeyer has waived all
;; copyright and related or neighboring rights to jleglot. This
;; work is published from: United States.


;;; Commentary:

;; This package loads support for the Julia language server into eglot
;; and package.el.  This provides IDE-like features for editing
;; julia-mode buffers.  After installing this package, to load support
;; for the Julia language server, run jleglot-init.  After that,
;; running the eglot function in a julia-mode buffer should work
;; properly.

;;; Code:

(require 'cl-generic)
(require 'eglot)
(require 'project)

(defgroup jleglot nil
         "Interaction with LanguageServer.jl LSP server via eglot"
         :prefix "jleglot-"
         :group 'applications)

(defcustom jleglot-julia-command "julia"
  "Command to run the Julia executable."
  :type 'string)

(defcustom jleglot-depot ""
  "Path or paths (space-separated) to Julia depots.
An empty string uses the default depot for ‘jleglot-julia-command’
when the JULIA_DEPOT_PATH environment variable is not set."
  :type 'string)

(defcustom jleglot-default-environment "~/.julia/environment/v1.2"
  "Path to the Julia environment used if file not in a Julia Project."
  :type 'string)

(defconst jleglot-base (file-name-directory load-file-name))

(defun jleglot--env (dir)
  "Find the most relevant Julia Project for a given directory.
If a parent directory to DIR contains a file JuliaProject.toml or
Project.toml, that parent directory is used.  If not,
`jleglot-default-environment' is used."
  (expand-file-name (if dir (or (locate-dominating-file dir "JuliaProject.toml")
                                (locate-dominating-file dir "Project.toml")
                                jleglot-default-environment)
                      jleglot-default-environment)))

;; Make project.el aware of Julia projects
(defun jleglot--project-try (dir)
  "Return project instance if DIR is part of a julia project.
Otherwise returns nil"
  (let ((root (or (locate-dominating-file dir "JuliaProject.toml")
                 (locate-dominating-file dir "Project.toml"))))
    (and root (cons 'julia root))))

(cl-defmethod project-roots ((project (head julia)))
  (list (cdr project)))

(defun jleglot--ls-invocation (_interactive)
  "Return list of strings to be called to start the Julia language server."
  `(,jleglot-julia-command
    ,(expand-file-name "jleglot.jl" jleglot-base)
    ,(jleglot--env (buffer-file-name))
    ,jleglot-depot))

;;;###autoload
(defun jleglot-init ()
  "Load `jleglot' to use eglot with the Julia language server."
  (interactive)
  (add-hook 'project-find-functions #'jleglot--project-try)
  (add-to-list 'eglot-server-programs
               ;; function instead of strings to find project dir at runtime
               '(julia-mode . jleglot--ls-invocation)))

(provide 'jleglot)
;;; jleglot.el ends here
