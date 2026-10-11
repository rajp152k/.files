(in-package #:autolith)

(defparameter *mermaid-ascii-program*
  (namestring (merge-pathnames ".local/bin/mermaid-ascii" (user-homedir-pathname)))
  "Verified mermaid-ascii executable used by the Mermaid code-block adapter.")

(define-condition code-block-render-error (error)
  ((reason :initarg :reason :reader code-block-render-error-reason))
  (:report (lambda (condition stream)
             (princ (code-block-render-error-reason condition) stream))))

(defclass code-block-markdown-renderer (termdown:markdown-renderer)
  ((block-function :initform nil :accessor code-block-renderer-function))
  (:documentation "A Markdown renderer that buffers blocks handled by an extension."))

(defparameter *mermaid-code-block-cache* (make-hash-table :test #'equal)
  "At most 64 successful Mermaid renders, keyed by executable, source, and width.")

(defun mermaid-code-block-render (source width)
  "Return Unicode diagram text for SOURCE within WIDTH cells.
Use stdin, bounded output, and a three-second subprocess deadline. Signal
CODE-BLOCK-RENDER-ERROR when rendering fails; callers can display the source."
  (when (or (> (length source) 16384)
            (> (count #\Newline source) 255))
    (error 'code-block-render-error :reason "Diagram source exceeds the render limit."))
  (let* ((key (list *mermaid-ascii-program* source width))
         (cached (gethash key *mermaid-code-block-cache*)))
    (or cached
        (let ((output (bounded-output-stream-create 262144))
              (diagnostic (bounded-output-stream-create 4096)))
          (unless (probe-file *mermaid-ascii-program*)
            (error 'code-block-render-error :reason "mermaid-ascii is not installed."))
          (multiple-value-bind (ignored ignored-error status)
              (uiop:run-program
               (list "/usr/bin/timeout" "--kill-after=1" "3"
                     *mermaid-ascii-program* "--file" "-"
                     "--max-width" (write-to-string width))
               :input (make-string-input-stream source)
               :output output :error-output diagnostic
               :ignore-error-status t :force-shell nil :external-format :utf-8)
            (declare (ignore ignored ignored-error))
            (unless (eql status 0)
              (error 'code-block-render-error
                     :reason (format nil "mermaid-ascii failed (exit ~A)." status))))
          (when (bounded-output-stream-truncated-p output)
            (error 'code-block-render-error :reason "Diagram output exceeds the render limit."))
          (let ((text (string-right-trim '(#\Newline #\Return)
                                         (sanitize-text (bounded-output-stream-text output)))))
            (when (zerop (length text))
              (error 'code-block-render-error :reason "mermaid-ascii returned no diagram."))
            (when (some (lambda (line) (> (clinedi:text-cell-width line) width))
                        (uiop:split-string text :separator '(#\Newline)))
              (error 'code-block-render-error :reason "Diagram exceeds the terminal width."))
            (when (>= (hash-table-count *mermaid-code-block-cache*) 64)
              (clrhash *mermaid-code-block-cache*))
            (setf (gethash key *mermaid-code-block-cache*) text))))))

(defparameter *code-block-renderers*
  (let ((table (make-hash-table :test #'equal)))
    (setf (gethash "mermaid" table) #'mermaid-code-block-render)
    table)
  "Language tags mapped to functions accepting (source width) and returning text.")

(defun register-code-block-renderer (language function)
  "Register FUNCTION for LANGUAGE, or remove the hook when FUNCTION is NIL.
A hook receives the complete source and available terminal-cell width. Return
plain text with explicit newlines. Do not include terminal control sequences."
  (check-type language string)
  (check-type function (or null function))
  (let ((tag (string-downcase language)))
    (if function
        (setf (gethash tag *code-block-renderers*) function)
        (remhash tag *code-block-renderers*))))

(defun code-block--source-rows (renderer lines)
  "Return buffered raw LINES using the normal numbered-code presentation."
  (let ((copy (termdown::markdown--copy-renderer renderer)))
    (setf (termdown::markdown-renderer-code-line-number copy) 1)
    (loop for line in lines append (termdown::markdown--code-rows copy line))))

(defun code-block--render-rows (renderer source function)
  "Call FUNCTION for a complete block; return source rows if the hook fails."
  (handler-case
      (restart-case
          (let* ((width (max 8 (- (termdown:markdown-renderer-width renderer) 2)))
                 (text (funcall function source width)))
            (check-type text string)
            (loop for line in (uiop:split-string (sanitize-text text) :separator '(#\Newline))
                  when (> (clinedi:text-cell-width line) width)
                    do (error 'code-block-render-error :reason "Rendered block exceeds the terminal width.")
                  collect (list (terminal-span ':plain (concatenate 'string "  " line)))))
        (use-source ()
          :report "Display the original code-block source."
          (code-block--source-rows renderer (uiop:split-string source :separator '(#\Newline)))))
    (error ()
      (code-block--source-rows renderer (uiop:split-string source :separator '(#\Newline))))))

(defun code-block--finish (renderer)
  "Commit buffered source when a stream ends before the closing fence."
  (when (and (typep renderer 'code-block-markdown-renderer)
             (code-block-renderer-function renderer)
             (termdown::markdown-renderer-code-open-p renderer))
    (setf (code-block-renderer-function renderer) nil)
    (code-block--source-rows renderer
                            (reverse (termdown::markdown-renderer-code-source renderer)))))

(defun application--markdown-renderer (application)
  "Return an extensible Markdown renderer sized to APPLICATION's terminal."
  (make-instance 'code-block-markdown-renderer
                 :width (max 24
                             (1- (terminal-columns
                                  (terminal-ui-terminal (application-ui application)))))))

(defun application--markdown-rows (renderer line)
  "Render LINE, replace complete handled blocks, and retain copyable raw source."
  (multiple-value-bind (fence-p information) (termdown::markdown--fence-line-p line)
    (let* ((open-p (termdown::markdown-renderer-code-open-p renderer))
           (extended-p (typep renderer 'code-block-markdown-renderer))
           (function (and extended-p (code-block-renderer-function renderer)))
           (rows (termdown:markdown-render-line renderer line))
           (source (termdown:markdown-renderer-closed-code-source renderer)))
      (when (and extended-p fence-p (not open-p))
        (let* ((tag (string-trim '(#\Space #\Tab) information))
               (end (or (position-if (lambda (c) (find c '(#\Space #\Tab))) tag)
                        (length tag))))
          (setf (code-block-renderer-function renderer)
                (gethash (string-downcase (subseq tag 0 end)) *code-block-renderers*))))
      (cond
        ((and function open-p (not fence-p)) (setf rows nil))
        ((and function open-p fence-p)
         (setf (code-block-renderer-function renderer) nil
               rows (append (code-block--render-rows renderer source function) rows))))
      (if (null source)
          rows
          (loop for row in rows
                collect (loop for span in row
                              collect (if (eq (terminal-span-style span) ':code-copy)
                                          (termdown:make-widget ':code-copy
                                                               (terminal-span-text span)
                                                               (list ':copy source))
                                          span)))))))

(defun application--markdown-partial (renderer partial)
  "Preview buffered block source without invoking a code-block renderer."
  (if (and (typep renderer 'code-block-markdown-renderer)
           (code-block-renderer-function renderer)
           (termdown::markdown-renderer-code-open-p renderer))
      (values nil
              (code-block--source-rows
               renderer
               (append (reverse (termdown::markdown-renderer-code-source renderer))
                       (when (plusp (length partial)) (list partial))))
              partial)
      (termdown:markdown-render-partial renderer partial)))

(defun application--markdown-body (application text)
  "Return sanitized TEXT as Markdown spans, flushing incomplete handled blocks."
  (let* ((renderer (application--markdown-renderer application))
         (trimmed (string-right-trim '(#\Space #\Tab #\Newline #\Return) (sanitize-text text)))
         (rows (loop for line in (or (uiop:split-string trimmed :separator '(#\Newline)) (list ""))
                     append (application--markdown-rows renderer line))))
    (loop for row in (append rows (code-block--finish renderer))
          append (append row (list (terminal-span ':plain (string #\Newline)))))))

(DEFUN APPLICATION-AGENT-OBSERVER
       (APPLICATION
        &KEY STEERING-FUNCTION STEERING-PERSISTED-FUNCTION
        USER-MESSAGE-PERSISTED-FUNCTION PENDING-OPERATIONS-FUNCTION
        USER-MESSAGE-INPUT (CONTINUATION-P NIL))
  "Return a terminal observer streaming one APPLICATION turn as stable lines."
  (LET ((UI (APPLICATION-UI APPLICATION))
        (ACTIVITY-LABEL (APPLICATION-THINKING-LABEL))
        (REASONING-TEXT (TEXT-BUFFER-CREATE))
        (PRESENTED-REASONING-TEXT NIL)
        (STREAM-TEXT (TEXT-BUFFER-CREATE))
        (STREAM-PENDING "")
        (STREAM-OPEN-P NIL)
        (STREAM-STARTED-AT NIL)
        (STREAM-RENDERER NIL))
    (LABELS ((REASONING-FLUSH ()
               "Finalize the visible reasoning summary before assistant output."
               (TERMINAL-UI-SET-PREVIEW-ROWS UI NIL)
               (WHEN
                   (AND (APPLICATION-REASONING-TRACES-P APPLICATION)
                        (PLUSP (LENGTH REASONING-TEXT))
                        (NULL PRESENTED-REASONING-TEXT))
                 (LET ((SUMMARY (TEXT-BUFFER-STRING REASONING-TEXT)))
                   (APPLICATION-PRESENT APPLICATION
                                        (APPLICATION--REASONING-SUMMARY-ENTRY
                                         APPLICATION SUMMARY))
                   (SETF PRESENTED-REASONING-TEXT SUMMARY))))
             (STREAM-TEXT-DELTA (DELTA)
               "Commit DELTA's completed markdown rows and repaint the fluid tail."
               (WHEN (PLUSP (LENGTH DELTA))
                 (TERMINAL-UI-NOTE-STATUS-PROGRESS UI)
                 (TEXT-BUFFER-APPEND STREAM-TEXT DELTA)
                 (SETF STREAM-PENDING
                         (SANITIZE-TEXT
                          (CONCATENATE 'STRING STREAM-PENDING DELTA)))
                 (LET ((ROWS NIL))
                   (UNLESS STREAM-OPEN-P
                     (REASONING-FLUSH)
                     (SETF STREAM-OPEN-P T
                           STREAM-STARTED-AT (GET-UNIVERSAL-TIME)
                           STREAM-RENDERER
                             (APPLICATION--MARKDOWN-RENDERER APPLICATION))
                     (APPLICATION-SET-ACTIVITY APPLICATION
                                               "receiving response")
                     (PUSH
                      (APPLICATION--TRANSCRIPT-ENTRY APPLICATION :STYLE ':BRAND
                                                     :HEADER "● autolith"
                                                     :TIMESTAMP
                                                     STREAM-STARTED-AT)
                      ROWS))
                   (LOOP FOR NEWLINE = (POSITION #\Newline STREAM-PENDING)
                         WHILE NEWLINE
                         DO (SETF ROWS
                                    (APPEND ROWS
                                            (APPLICATION--MARKDOWN-ROWS
                                             STREAM-RENDERER
                                             (SUBSEQ STREAM-PENDING 0
                                                     NEWLINE)))
                                  STREAM-PENDING
                                    (SUBSEQ STREAM-PENDING (1+ NEWLINE))))
                   (MULTIPLE-VALUE-BIND (OVERFLOW-ROWS TAIL-ROWS RETAINED)
                       (APPLICATION--MARKDOWN-PARTIAL STREAM-RENDERER
                                                      STREAM-PENDING)
                     (SETF STREAM-PENDING RETAINED)
                     (TERMINAL-UI-STREAM-UPDATE UI :ROWS
                                                (APPEND ROWS OVERFLOW-ROWS)
                                                :TAIL TAIL-ROWS)))))
             (STREAM-FLUSH ()
               "Finish the streamed block with its remaining text and separator."
               (WHEN STREAM-OPEN-P
                 (TERMINAL-UI-STREAM-UPDATE UI :ROWS
                                            (APPEND
                                             (WHEN
                                                 (PLUSP
                                                  (LENGTH STREAM-PENDING))
                                               (APPLICATION--MARKDOWN-ROWS
                                                STREAM-RENDERER
                                                STREAM-PENDING))
                                             (CODE-BLOCK--FINISH
                                              STREAM-RENDERER)
                                             (LIST NIL))
                                            :TAIL NIL)
                 (SETF STREAM-PENDING ""
                       STREAM-OPEN-P NIL
                       STREAM-RENDERER NIL))))
      (CALLBACK-AGENT-OBSERVER-CREATE :TEXT-CALLBACK #'STREAM-TEXT-DELTA
                                      :REASONING-CALLBACK
                                      (LAMBDA (DELTA)
                                        (WHEN (PLUSP (LENGTH DELTA))
                                          (TERMINAL-UI-NOTE-STATUS-PROGRESS
                                           UI))
                                        (WHEN
                                            (AND
                                             (APPLICATION-REASONING-TRACES-P
                                              APPLICATION)
                                             (NULL PRESENTED-REASONING-TEXT)
                                             (PLUSP (LENGTH DELTA)))
                                          (TEXT-BUFFER-APPEND REASONING-TEXT
                                                              DELTA)
                                          (TERMINAL-UI-SET-PREVIEW-ROWS UI
                                                                        (APPLICATION--REASONING-PREVIEW-ROWS
                                                                         APPLICATION
                                                                         REASONING-TEXT))))
                                      :STATUS-CALLBACK
                                      (LAMBDA (STATUS DETAILS)
                                        (CASE STATUS
                                          (:USER-MESSAGE-PERSISTED
                                           (LET ((PENDING-INPUT-IDENTIFIER
                                                  (GETF DETAILS
                                                        :PENDING-INPUT-IDENTIFIER)))
                                             (WHEN
                                                 (AND PENDING-INPUT-IDENTIFIER
                                                      USER-MESSAGE-PERSISTED-FUNCTION)
                                               (FUNCALL
                                                USER-MESSAGE-PERSISTED-FUNCTION
                                                PENDING-INPUT-IDENTIFIER)))
                                           (LET ((SEQUENCE
                                                  (GETF DETAILS :SEQUENCE))
                                                 (TIMESTAMP
                                                  (GETF DETAILS :TIME)))
                                             (UNLESS
                                                 (TYPEP SEQUENCE '(INTEGER 0))
                                               (ERROR
                                                'CONVERSATION-INVARIANT-ERROR
                                                :MESSAGE
                                                "The persisted user message has no valid sequence."
                                                :PATHNAME
                                                (CONVERSATION-PATHNAME
                                                 (APPLICATION-CONVERSATION
                                                  APPLICATION))
                                                :SEQUENCE SEQUENCE))
                                             (WITH-RECURSIVE-LOCK-HELD ((APPLICATION-RENDER-LOCK
                                                                         APPLICATION))
                                               (TERMINAL-UI-APPEND-FINALIZED UI
                                                                             (LIST
                                                                              :CONVERSATION
                                                                              (CONVERSATION-IDENTIFIER
                                                                               (APPLICATION-CONVERSATION
                                                                                APPLICATION))
                                                                              SEQUENCE)
                                                                             (IF CONTINUATION-P
                                                                                 (LIST
                                                                                  (TERMINAL-SPAN
                                                                                   ':HINT
                                                                                   "∙ goal continues"))
                                                                                 (APPLICATION--TRANSCRIPT-ENTRY
                                                                                  APPLICATION
                                                                                  :STYLE
                                                                                  ':USER
                                                                                  :HEADER
                                                                                  "❯ you"
                                                                                  :TIMESTAMP
                                                                                  TIMESTAMP
                                                                                  :BODY
                                                                                  (USER-MESSAGE-INPUT-TEXT
                                                                                   USER-MESSAGE-INPUT))))
                                               (SETF (APPLICATION-RENDERED-SEQUENCE
                                                      APPLICATION)
                                                       SEQUENCE)))
                                           (APPLICATION-PUBLISH-RECOVERY-SESSION
                                            APPLICATION))
                                          (:PROVIDER-PROGRESS
                                           (TERMINAL-UI-NOTE-STATUS-PROGRESS
                                            UI))
                                          (:PROVIDER-REQUEST-STARTED
                                           (TERMINAL-UI-SET-PREVIEW-ROWS UI
                                                                         NIL)
                                           (TEXT-BUFFER-CLEAR REASONING-TEXT)
                                           (TEXT-BUFFER-CLEAR STREAM-TEXT)
                                           (SETF PRESENTED-REASONING-TEXT NIL
                                                 ACTIVITY-LABEL
                                                   (APPLICATION-THINKING-LABEL))
                                           (APPLICATION-NOTE-PROMPT-CACHE-REQUEST-STARTED
                                            APPLICATION)
                                           (APPLICATION-PUBLISH-RECOVERY-SESSION
                                            APPLICATION)
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION ACTIVITY-LABEL))
                                          (:PROVIDER-RETRYING
                                           (LET ((PARTIAL-OUTPUT-P
                                                  (OR STREAM-OPEN-P
                                                      (PLUSP
                                                       (LENGTH
                                                        REASONING-TEXT)))))
                                             (STREAM-FLUSH)
                                             (TERMINAL-UI-SET-PREVIEW-ROWS UI
                                                                           NIL)
                                             (WHEN PARTIAL-OUTPUT-P
                                               (APPLICATION-PRESENT APPLICATION
                                                                    (LIST
                                                                     (TERMINAL-SPAN
                                                                      ':HINT
                                                                      (FORMAT
                                                                       NIL
                                                                       "∙ provider stream interrupted; retrying ~D/~D"
                                                                       (GETF
                                                                        DETAILS
                                                                        :ATTEMPT)
                                                                       (GETF
                                                                        DETAILS
                                                                        :MAXIMUM-ATTEMPTS))))))
                                             (TEXT-BUFFER-CLEAR REASONING-TEXT)
                                             (TEXT-BUFFER-CLEAR STREAM-TEXT)
                                             (SETF PRESENTED-REASONING-TEXT NIL
                                                   STREAM-PENDING ""
                                                   STREAM-OPEN-P NIL
                                                   STREAM-RENDERER NIL)
                                             (APPLICATION-SET-ACTIVITY
                                              APPLICATION
                                              (LET ((DELAY
                                                     (GETF DETAILS :DELAY)))
                                                (IF (AND (INTEGERP DELAY)
                                                         (PLUSP DELAY))
                                                    (FORMAT NIL
                                                            "reconnecting ~D/~D in ~Ds"
                                                            (GETF DETAILS
                                                                  :ATTEMPT)
                                                            (GETF DETAILS
                                                                  :MAXIMUM-ATTEMPTS)
                                                            DELAY)
                                                    (FORMAT NIL
                                                            "reconnecting ~D/~D"
                                                            (GETF DETAILS
                                                                  :ATTEMPT)
                                                            (GETF DETAILS
                                                                  :MAXIMUM-ATTEMPTS)))))))
                                          (:PROVIDER-REQUEST-COMPLETED
                                           (APPLICATION-REFRESH-CONTEXT-METER
                                            APPLICATION)
                                           (REASONING-FLUSH)
                                           (LET ((COMPLETED-STREAM-TEXT
                                                  (AND STREAM-OPEN-P
                                                       (TEXT-BUFFER-STRING
                                                        STREAM-TEXT)))
                                                 (COMPLETED-REASONING-TEXT
                                                  PRESENTED-REASONING-TEXT))
                                             (STREAM-FLUSH)
                                             (APPLICATION-RENDER-RECORDS
                                              APPLICATION
                                              :STREAMED-ASSISTANT-TEXT
                                              COMPLETED-STREAM-TEXT
                                              :STREAMED-REASONING-TEXT
                                              COMPLETED-REASONING-TEXT))
                                           (APPLICATION-NOTE-PROMPT-CACHE-REQUEST-COMPLETED
                                            APPLICATION DETAILS))
                                          (:TOOL-CALL-STARTED
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION
                                            (FORMAT NIL "running ~A"
                                                    (GETF DETAILS :TOOL))))
                                          (:TOOL-CALL-PROGRESS
                                           (LET ((ACTIVITY
                                                  (GETF DETAILS :ACTIVITY)))
                                             (WHEN
                                                 (NON-EMPTY-STRING-P ACTIVITY)
                                               (APPLICATION-SET-ACTIVITY
                                                APPLICATION ACTIVITY))))
                                          (:TOOL-CALL-COMPLETED
                                           (APPLICATION-RENDER-RECORDS
                                            APPLICATION)
                                           (LET ((TOOL-NAME
                                                  (OR (GETF DETAILS :TOOL) "")))
                                             (COND
                                              ((STRING= TOOL-NAME "skill.load")
                                               (IF (AND
                                                    (GETF DETAILS :SUCCESS-P)
                                                    (APPLICATION-COMPACT-VIEW-P
                                                     APPLICATION)
                                                    (NTH-VALUE 2
                                                               (APPLICATION--SKILL-LOAD-RESULT-DETAILS
                                                                (GETF DETAILS
                                                                      :DETAILS))))
                                                   (APPLICATION--PRESENT-SKILL-LOAD-RESULT
                                                    APPLICATION DETAILS)
                                                   (APPLICATION--PRESENT-TRANSIENT-TOOL-RESULT
                                                    APPLICATION DETAILS)))))
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION ACTIVITY-LABEL))
                                          (:STEERING-APPLIED
                                           (APPLICATION-RENDER-RECORDS
                                            APPLICATION)
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION ACTIVITY-LABEL))
                                          (:COMPACTION-STARTED
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION
                                            "compacting the conversation")
                                           (TERMINAL-UI-SET-COMPACTING UI T))
                                          (:COMPACTION-COMPLETED
                                           (TERMINAL-UI-SET-COMPACTING UI NIL)
                                           (SETF (APPLICATION-PROMPT-CACHE-BASELINE
                                                  APPLICATION)
                                                   NIL)
                                           (APPLICATION-RENDER-RECORDS
                                            APPLICATION)
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION ACTIVITY-LABEL))
                                          (:TURN-COMPLETED
                                           (TERMINAL-UI-SET-COMPACTING UI NIL)
                                           (TERMINAL-UI-SET-PREVIEW-ROWS UI
                                                                         NIL)
                                           (APPLICATION-SET-ACTIVITY
                                            APPLICATION NIL))))
                                      :STEERING-CALLBACK STEERING-FUNCTION
                                      :STEERING-PERSISTED-CALLBACK
                                      STEERING-PERSISTED-FUNCTION
                                      :PENDING-OPERATIONS-CALLBACK
                                      PENDING-OPERATIONS-FUNCTION
                                      :COMMAND-AUTHORIZATION-CALLBACK
                                      (LAMBDA (COMMAND DIRECTORY)
                                        (APPLICATION-AUTHORIZE-COMMAND
                                         APPLICATION COMMAND DIRECTORY))
                                      :TOOL-AUTHORIZATION-CALLBACK
                                      (LAMBDA (TOOL ARGUMENTS)
                                        (APPLICATION-AUTHORIZE-TOOL APPLICATION
                                                                    TOOL
                                                                    ARGUMENTS))))))
