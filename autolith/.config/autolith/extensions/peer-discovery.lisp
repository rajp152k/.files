(in-package #:autolith)

(defparameter *peer-discovery-pathname* *load-truename*
  "The installed discovery extension, used for a config-only reload.")

(define-condition peer-lookup-error (error)
  ((query :initarg :query :reader peer-lookup-query)
   (candidates :initarg :candidates :reader peer-lookup-candidates))
  (:documentation "A live identity lookup did not select exactly one session."))

(define-condition peer-not-found (peer-lookup-error) ()
  (:report (lambda (condition stream)
             (format stream "No live peer matches ~S. Refresh discovery or use an exact ID."
                     (peer-lookup-query condition)))))

(define-condition peer-ambiguous (peer-lookup-error) ()
  (:report (lambda (condition stream)
             (format stream "Peer ~S is ambiguous. Use an exact ID from ~S."
                     (peer-lookup-query condition)
                     (mapcar (lambda (row) (getf (rest row) :session-id))
                             (peer-lookup-candidates condition))))))

(defun peer--configuration ()
  "Use the live application's configuration, or a bound worker configuration."
  (or (and *active-application*
           (application-configuration *active-application*))
      *configuration*
      (error "Peer discovery needs an application or a bound configuration.")))

(defun peer--public-status (status)
  "Copy public identity and state fields only. Never return endpoint credentials."
  (list* :localgroup-status
         (loop for key in '(:version :session-id :alias :pid :autolith-version
                           :conversation-id :conversation-display-id
                           :conversation-title :conversation-persisted-p
                           :cwd :state :idle-p :waiting-for-input-p :paused-p
                           :handoff-p :model :reasoning-effort :permission-mode
                           :active-turn-p :queued-input-count :steering-input-count
                           :recalled-input-p :turn-cancelling-p :reader-paused-p
                           :task-live-count :task-active-count
                           :terminal-attached-p :terminal-attachment :observer-count
                           :created-at)
               append (list key (copy-tree (getf (rest status) key))))))

(defun peers (&optional (configuration (peer--configuration)))
  "Query live native statuses. Return tagged public records, not authority grants.
Fields follow the tag: use (getf (rest row) :alias). Missing aliases stay NIL.
Native discovery can prune unreachable endpoint registry records."
  (mapcar #'peer--public-status (localgroup-statuses configuration)))

(defun peer--words (name)
  "Normalize alias separators and case, without normalizing case-sensitive IDs."
  (loop with start = nil
        for index from 0 to (length name)
        for separator = (or (= index (length name))
                            (find (char name index)
                                  '(#\Space #\Tab #\Newline #\Return #\_ #\-)))
        when (and separator start)
          collect (string-downcase (subseq name start index))
          and do (setf start nil)
        when (and (not separator) (null start)) do (setf start index)))

(defun peer--friendly-words (alias)
  "Omit only a six-hex-digit suffix on a three-part generated alias."
  (let ((words (peer--words alias)))
    (if (and (= 3 (length words))
             (= 6 (length (third words)))
             (every (lambda (character) (digit-char-p character 16)) (third words)))
        (butlast words)
        words)))

(defun peer--select (query matches)
  (cond ((null matches)
         (error 'peer-not-found :query query :candidates nil))
        ((rest matches)
         (error 'peer-ambiguous :query query :candidates matches))
        (t (first matches))))

(defun peer--resolve (name snapshot)
  "Prefer exact aliases and canonical/display IDs, then normalized alias names."
  (check-type name string)
  (let ((words (peer--words name)))
    (peer--select
     name
     (or (remove-if-not
          (lambda (row)
            (some (lambda (key)
                    (let ((value (getf (rest row) key)))
                      (and (stringp value) (string= name value))))
                  '(:alias :session-id :conversation-id :conversation-display-id)))
          snapshot)
         (and words
              (remove-if-not
               (lambda (row)
                 (let ((alias (getf (rest row) :alias)))
                   (and (stringp alias)
                        (or (equal words (peer--words alias))
                            (equal words (peer--friendly-words alias))))))
               snapshot))))))

(defun peer (name &optional (snapshot (peers)))
  "Resolve NAME without choosing an ambiguous match. SNAPSHOT can be from PEERS.
RETRY refreshes live discovery. USE-VALUE resolves another name against SNAPSHOT."
  (restart-case (peer--resolve name snapshot)
    (retry () :report "Refresh live discovery and retry the same name."
      (peer name))
    (use-value (new-name) :report "Resolve another exact ID or alias."
      (peer new-name snapshot))))

(defun peer--self (snapshot identifier pid)
  "Match the actual application conversation and process, not its workspace/name."
  (peer--select
   (list :conversation-id identifier :pid pid)
   (remove-if-not
    (lambda (row)
      (and (stringp identifier)
           (eql pid (getf (rest row) :pid))
           (or (equal identifier (getf (rest row) :conversation-id))
               (equal identifier (getf (rest row) :session-id)))))
    snapshot)))

(defun self-peer (&optional (snapshot (peers)))
  "Return this live application's peer record, including an honest NIL alias.
This is the application's session identity, not a child job's actor identity."
  (restart-case
      (peer--self snapshot
                  (and *active-application*
                       (conversation-identifier
                        (application-conversation *active-application*)))
                  (current-process-id))
    (retry () :report "Refresh discovery and retry the actual self identity."
      (self-peer))))

(defun peer-discovery-reload ()
  "Reload discovery and its shared advice without running init or changing settings."
  (let ((*extension-registration-source* :user))
    (load *peer-discovery-pathname* :verbose nil :print nil))
  :loaded)

;; Use the existing contributor. One registration supplies dispatch and discovery advice.
(let ((*extension-registration-source* :user))
  (load (merge-pathnames "dispatch-policy.lisp" *load-truename*)
        :verbose nil :print nil))
