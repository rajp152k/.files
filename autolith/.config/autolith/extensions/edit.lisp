(in-package #:autolith)

(defvar *external-editor-read-event-installed-p* nil)
(defvar *external-editor-ui-handler-installed-p* nil)

(defun external-editor--temporary-file (text)
  (loop repeat 20
        for pathname =
          (merge-pathnames
           (format nil "autolith-edit-~36R.tmp" (random (expt 36 10)))
           (uiop:temporary-directory))
        for stream = (open pathname :direction :output
                                   :if-exists nil
                                   :if-does-not-exist :create)
        when stream
          do (write-string text stream)
             (close stream)
             (return pathname)
        finally (error "Could not create a temporary editor file.")))

(defun external-editor--edit (text)
  (let ((pathname (external-editor--temporary-file text)))
    (unwind-protect
         (progn
           (uiop:run-program
            (list "/bin/sh" "-c"
                  "exec ${VISUAL:-${EDITOR:-vi}} \"$1\""
                  "autolith-edit"
                  (namestring pathname))
            :input :interactive
            :output :interactive
            :error-output :interactive)
           (uiop:read-file-string pathname))
      (when (probe-file pathname)
        (delete-file pathname)))))

(defun external-editor-install ()
  "Bind Ctrl-E in the Autolith prompt to edit its draft with VISUAL or EDITOR."
  (unless *external-editor-read-event-installed-p*
    (let ((original (symbol-function 'clinedi:read-event)))
      (setf (symbol-function 'clinedi:read-event)
            (lambda (&key (stream *standard-input*) (escape-delay 0.002))
              (let ((character (read-char stream nil nil)))
                (if (and character (= (char-code character) 5))
                    :edit-external
                    (progn
                      (when character (unread-char character stream))
                      (funcall original :stream stream
                                        :escape-delay escape-delay))))))
      (setf *external-editor-read-event-installed-p* t)))
  (unless *external-editor-ui-handler-installed-p*
    (let ((original (symbol-function 'terminal-ui--apply-editor-event)))
      (setf (symbol-function 'terminal-ui--apply-editor-event)
            (lambda (ui event)
              (if (eq event :edit-external)
                  (let* ((editor (terminal-ui-editor ui))
                         (edited (external-editor--edit
                                  (line-editor-text editor))))
                    (line-editor-set-text editor edited)
                    (values :changed nil))
                  (funcall original ui event))))
      (setf *external-editor-ui-handler-installed-p* t)))
  nil)

(external-editor-install)
