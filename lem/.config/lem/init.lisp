(in-package :lem-user)

;; Use Vim-style bindings globally.
(lem-vi-mode:vi-mode)

;; Load machine-specific settings after the shared settings.
(let ((local-file (merge-pathnames "local.lisp" (lem:lem-home))))
  (when (probe-file local-file)
    (load local-file)))
