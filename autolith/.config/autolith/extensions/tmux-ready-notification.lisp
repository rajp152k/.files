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
  "Display the popup on a background thread without blocking turn completion."
  (bordeaux-threads:make-thread
   (lambda ()
     (handler-case
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
             (eql exit-code 0)))
       (serious-condition () nil)))
   :name "Autolith tmux ready notification"))

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

(defun ntfy-ready-notification--character-bytes (character)
  (let ((code (char-code character)))
    (cond ((<= code #x7f) 1)
          ((<= code #x7ff) 2)
          ((<= code #xffff) 3)
          (t 4))))

(defun ntfy-ready-notification--chunks (text &optional (maximum-bytes 3800))
  (let ((chunks nil)
        (start 0)
        (byte-count 0))
    (loop for index from 0 below (length text)
          for character = (char text index)
          for bytes = (ntfy-ready-notification--character-bytes character)
          do (when (and (plusp byte-count)
                        (> (+ byte-count bytes) maximum-bytes))
               (push (subseq text start index) chunks)
               (setf start index
                     byte-count 0))
             (incf byte-count bytes))
    (when (< start (length text))
      (push (subseq text start) chunks))
    (nreverse chunks)))

(defun ntfy-ready-notification--last-assistant-text (application)
  (loop for item in (reverse
                     (conversation-input-items
                      (application-conversation application)))
        for text = (cl-llm-provider-api:response-item-assistant-text item)
        when (and (stringp text)
                  (plusp (length (string-trim
                                  '(#\Space #\Tab #\Newline #\Return)
                                  text))))
          return text))

(defun ntfy-ready-notification--send (application)
  (let* ((identifier
           (image-daemon:session-identifier-display
            (conversation-identifier (application-conversation application))))
         (text (ntfy-ready-notification--last-assistant-text application))
         (chunks (and text (ntfy-ready-notification--chunks text)))
         (part-count (length chunks))
         (title (tmux-ready-notification--sanitize
                 (format nil "Autolith ~A" identifier))))
    (when chunks
      (loop for chunk in chunks
            for part from 1
            for part-title = (if (> part-count 1)
                                 (format nil "~A (~D/~D)"
                                         title part part-count)
                                 title)
            do (multiple-value-bind (output error-output exit-code)
                   (uiop:run-program
                    (list "curl" "--fail" "--silent" "--show-error"
                          "--max-time" "5"
                          "--header" (concatenate 'string "Title: " part-title)
                          "--data-binary" chunk
                          "http://100.73.230.125:2586/driver")
                    :output nil :error-output nil :ignore-error-status t)
                 (declare (ignore output error-output))
                 (unless (eql exit-code 0)
                   (return-from ntfy-ready-notification--send nil)))
            finally (return t)))))

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
                      (serious-condition () nil))
                    (handler-case
                        (ntfy-ready-notification--send application)
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
