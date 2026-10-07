(in-package :lem-user)

;; Add shared Lem settings here.

;; Load machine-specific settings after the shared settings.
(let ((local-file (merge-pathnames "local.lisp" (lem:lem-home))))
  (when (probe-file local-file)
    (load local-file)))
