(in-package #:autolith)

;; Portable defaults. Keep these settings in sync with intended /settings changes.
(setf (config :model) "gpt-6-luna"
      (config :reasoning-effort) "high"
      (config :reasoning-traces-p) t
      (config :simple-technical-english-p) t)

;; Optional machine-specific overrides beside the deployed init file.
(let ((local-init (merge-pathnames "local.lisp" *load-pathname*)))
  (when (probe-file local-init)
    (load local-init)))

(let* ((extension-directory (merge-pathnames "extensions/" *load-pathname*))
       (notification-extension
         (merge-pathnames "notifications/tmux-ready-notification.lisp"
                          extension-directory))
       (reload-command-extension
         (merge-pathnames "commands/config-reload.lisp" extension-directory)))
  (load (if (probe-file notification-extension)
            notification-extension
            (merge-pathnames "tmux-ready-notification.lisp" extension-directory)))
  (load reload-command-extension))
