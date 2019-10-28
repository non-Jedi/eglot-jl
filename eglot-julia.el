;;; eglot-julia.el --- Julia support for eglot -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Adam Beckmeyer

;; Version: 0.1.0
;; Author: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; Maintainer: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;; URL: https://github.com/non-Jedi/eglot-julia
;; Keywords: convenience, languages
;; Package-Requires: ((emacs "25.1") (eglot "1.4") (julia-mode "0.3"))

;; This file is not part of GNU Emacs.

;;; License:

;; To the extent possible under law, Adam Beckmeyer has waived all
;; copyright and related or neighboring rights to eglot-julia. This
;; work is published from: United States.

;;; Code:

(require 'cl-generic)
(require 'eglot)

(degroup eglot-julia nil
         "Interaction with LanguageServer.jl LSP server via eglot"
         :prefix "eglot-julia-"
         :group 'applications)

(defcustom eglot-julia-default-depot ""
  "The default depot path, used if `JULIA_DEPOT_PATH' is unset"
  :type 'string)

(defcustom eglot-julia-default-environment "~/.julia/environment/v1.1"
  "The default julia environment"
  :type 'string)

(defconst eglot-julia-base (file-name-directory load-file-name))

(defun eglot-julia/depot-path ()
  (if-let (env-depot (getenv "JULIA_DEPOT_PATH"))
      (expand-file-name env-depot)
    (if (equal eglot-julia-default-depot "")
        eglot-julia-default-depot
      (expand-file-name eglot-julia-default-depot))))

(defun eglot-julia/get-env (dir)
  (expand-file-name (if dir (or (locate-dominating-file dir "JuliaProject.toml")
                                (locate-dominating-file dir "Project.toml")
                                eglot-julia-default-environment)
                      eglot-julia-default-environment)))

;; Make project.el aware of Julia projects
(defun eglot-julia/project-try (dir)
  (let ((root (or (locate-dominating-file dir "JuliaProject.toml")
                 (locate-dominating-file dir "Project.toml"))))
    (and root (cons 'julia root))))

(add-hook 'project-find-functions 'eglot-julia/project-try)

(cl-defmethod project-roots ((project (head julia)))
  (list (cdr project)))

(defun eglot-julia/ls-invocation ()
  `("julia"
    ,(expand-file-name "eglot.jl" eglot-julia-base)
    ,(eglot-julia/get-env (buffer-file-name))
    ,(eglot-julia/depot-path)))

;;;###autoload
(add-to-list 'eglot-server-programs
             ;; function instead of strings to find project dir at runtime
             '(julia-mode . eglot-julia/ls-invocation))

(provide 'eglot-julia)
;;; eglot-julia.el ends here
