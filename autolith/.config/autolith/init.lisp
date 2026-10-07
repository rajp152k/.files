(in-package #:autolith)

;; Portable defaults. Keep these settings in sync with intended /settings changes.
(setf (config :model) "gpt-6.1-sol"
      (config :reasoning-effort) "low"
      (config :reasoning-traces-p) t
      (config :simple-technical-english-p) t)

;; Optional machine-specific overrides beside the deployed init file.
(let ((local-init (merge-pathnames "local.lisp" *load-pathname*)))
  (when (probe-file local-init)
    (load local-init)))
