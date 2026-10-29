(in-package #:autolith)

(define-application-command user-config-reload-command
    (:name "/reval"
     :argument nil
     :description "Reload user initialization and extension definitions"
     :tip "reloads executable user configuration in the running session."
     :busy-behavior :hold
     :terminal-behavior :shared
     :callable t)
    (application)
  (let ((loaded-path
          (user-init-load (application-configuration application))))
    (application-present
     application
     (format nil "Reloaded user definitions~@[ from ~A~]." loaded-path)))
  :continue)
