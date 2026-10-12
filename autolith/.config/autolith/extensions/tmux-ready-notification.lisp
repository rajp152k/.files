(in-package #:autolith)

(defvar *tmux-ready-notification-installed-p* nil)

(defun tmux-ready-notification--sanitize (text)
  (let* ((cleaned
           (map 'string
                (lambda (character)
                  (cond
                    ((or (char< character #\Space)
                         (char= character #\Rubout)) #\Space)
                    ((char= character #\;) #\,)
                    (t character)))
                text))
         (trimmed (string-trim '(#\Space #\Tab #\Newline #\Return) cleaned)))
    (subseq trimmed 0 (min 200 (length trimmed)))))

(defun tmux-ready-notification--location (pane)
  (multiple-value-bind (output error-output exit-code)
      (uiop:run-program
       (list "tmux" "display-message" "-p" "-t" pane "#S:#I.#W")
       :output :string :error-output :string :ignore-error-status t)
    (declare (ignore error-output))
    (when (eql exit-code 0)
      (let ((location (tmux-ready-notification--sanitize output)))
        (unless (zerop (length location)) location)))))

(defun tmux-ready-notification--show (pane title message)
  (let ((command
          "printf '%s\\n\\nPress any key to dismiss.' \"$AUTOLITH_TMUX_READY_MESSAGE\"; old_stty=$(stty -g); trap 'stty \"$old_stty\"' EXIT HUP INT TERM; stty -icanon -echo min 1 time 0; dd bs=1 count=1 >/dev/null 2>&1;"))
    (multiple-value-bind (output error-output exit-code)
        (uiop:run-program
         (list "tmux" "display-popup" "-t" pane "-E" "-w" "50" "-h" "5"
               "-x" "R" "-y" "0" "-T" title
               "-e" (concatenate 'string "AUTOLITH_TMUX_READY_MESSAGE=" message)
               command)
         :output nil :error-output nil :ignore-error-status t)
      (declare (ignore output error-output))
      (eql exit-code 0))))

(defun tmux-ready-notification--send (application)
  (let ((pane (sb-ext:posix-getenv "TMUX_PANE")))
    (when (and (sb-ext:posix-getenv "TMUX") pane)
      (let* ((identifier
               (image-daemon:session-identifier-display
                (conversation-identifier (application-conversation application))))
             (location (tmux-ready-notification--location pane))
             (title (tmux-ready-notification--sanitize
                     (format nil "Autolith ~A" identifier)))
             (message (tmux-ready-notification--sanitize
                       (format nil "Ready for input - Localgroup ID: ~A~@[ - ~A~]"
                               identifier location))))
        (tmux-ready-notification--show pane title message)))))

(defun tmux-ready-notification-install ()
  "Show the OMP-style tmux popup after each completed top-level user turn."
  (unless *tmux-ready-notification-installed-p*
    (let ((original (symbol-function 'application--run-turn)))
      (setf (symbol-function 'application--run-turn)
            (lambda (application content &rest arguments)
              (prog1 (apply original application content arguments)
                (unless (or (getf arguments :continuation-p)
                            (getf arguments :operation-request))
                  (handler-case
                      (tmux-ready-notification--send application)
                    (serious-condition () nil))))))
      (setf *tmux-ready-notification-installed-p* t)))
  nil)

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
(tmux-ready-notification-install)
