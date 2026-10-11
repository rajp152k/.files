(in-package #:autolith)

;; Portable defaults. Keep these settings in sync with intended /settings changes.
(setf (config :model) "gpt-6-luna"
      (config :reasoning-effort) "high"
      (config :reasoning-traces-p) t
      (config :simple-technical-english-p) t)

;; Load the shared Mermaid code-block renderer from this config checkout.
(let ((renderer-extension
        (merge-pathnames "extensions/mermaid-hook.lisp" *load-pathname*)))
  (when (probe-file renderer-extension)
    (load renderer-extension)))

;; Optional machine-specific overrides beside the deployed init file.
(let ((local-init (merge-pathnames "local.lisp" *load-pathname*)))
  (when (probe-file local-init)
    (load local-init)))
