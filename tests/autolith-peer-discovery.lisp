(in-package #:autolith)

(defun check-peer-discovery ()
  "Check lookup rules and recovery without network or model requests."
  (let* ((panda '(:localgroup-status :session-id "AbC1234" :alias "proud_panda_abcdef"
                 :conversation-id "AbC1234" :conversation-display-id "A-bC1234" :pid 12
                 :cwd "/panda/" :state :idle))
         (other '(:localgroup-status :session-id "XyZ5678" :alias "proud_panda_123abc"
                 :conversation-id "XyZ5678" :pid 13))
         (unnamed '(:localgroup-status :session-id "NoAlias" :alias nil
                   :conversation-id "NoAlias" :pid 14)))
    (flet ((fails-as (type thunk)
             (assert (handler-case (progn (funcall thunk) nil)
                       (peer-lookup-error (condition) (typep condition type))))))
      (dolist (name '("proud panda" " PROUD__PANDA " "proud-panda"
                      "proud panda abcdef" "proud_panda_abcdef"
                      "AbC1234" "A-bC1234"))
        (assert (eq panda (peer name (list panda unnamed)))))
      (assert (eq panda (peer "AbC1234" (list panda other))))
      (assert (eq panda (peer "proud_panda_abcdef" (list panda other))))
      (assert (eq unnamed (peer "NoAlias" (list panda unnamed))))
      (assert (null (getf (rest (peer "NoAlias" (list unnamed))) :alias)))
      (fails-as 'peer-ambiguous (lambda () (peer "proud panda" (list panda other))))
      (fails-as 'peer-ambiguous (lambda () (peer "AbC1234" (list panda panda))))
      (dolist (name '("abc1234" "AbC" "" " " "No Alias" "not a peer"))
        (fails-as 'peer-not-found (lambda () (peer name (list panda unnamed)))))
      (handler-bind ((peer-ambiguous
                      (lambda (condition)
                        (assert (= 2 (length (peer-lookup-candidates condition))))
                        (assert (find-restart 'retry condition))
                        (invoke-restart 'use-value "XyZ5678"))))
        (assert (eq other (peer "proud panda" (list panda other)))))
      (assert (eq unnamed (peer--self (list panda unnamed) "NoAlias" 14)))
      (fails-as 'peer-not-found
                (lambda () (peer--self (list panda unnamed) "NoAlias" 12)))
      (fails-as 'peer-not-found
                (lambda () (peer--self (list panda) "absent" 12)))
      (fails-as 'peer-not-found
                (lambda () (peer--self (list '(:localgroup-status :pid 12)) nil 12)))
      (fails-as 'peer-ambiguous
                (lambda () (peer--self (list panda panda) "AbC1234" 12)))
      (let ((public (peer--public-status
                     (append panda '(:token "test-only" :port 123 :endpoint "hidden")))))
        (dolist (key '(:session-id :alias :conversation-id :pid :cwd :state))
          (assert (equal (getf (rest panda) key) (getf (rest public) key))))
        (dolist (key '(:token :port :endpoint))
          (assert (eq :absent (getf (rest public) key :absent)))))))
  :passed)

(defun check-peer-discovery-reload (configuration)
  "Check reload and shared contributor registration without model requests."
  (let ((*configuration* configuration)
        (before (list (config :model configuration)
                      (config :reasoning-effort configuration))))
    (peer-discovery-reload)
    (peer-discovery-reload)
    (assert (equal before (list (config :model configuration)
                               (config :reasoning-effort configuration))))
    (assert (= 1 (count "dispatch-policy-context"
                        (context-contributor-registrations)
                        :key (lambda (entry) (getf entry :identifier))
                        :test #'string=))))
  :passed)
