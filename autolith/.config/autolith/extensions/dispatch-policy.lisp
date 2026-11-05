(in-package #:autolith)

(defparameter *dispatch-policy-pathname* *load-truename*
  "The installed policy file, used for a policy-only reload.")

(defparameter *dispatch-policy-instruction*
  "Choose dispatch effort without asking the user for each task. Keep main coordinators at medium unless the user chooses otherwise. Use direct tools for small exact work. For independent tasks, use task.run agent dispatch-low for clear bounded lookups, extraction, status, or mechanical edits with explicit checks. Use dispatch-medium for implementation, debugging, unclear scope, sensitive work, or failed checks. Both roles inherit the parent model through @parent and set low or medium reasoning explicitly; do not infer a provider from a friendly model name. Inspect task.agents before dispatch: project roles can override user roles. Respect tool and authority limits. Escalate ambiguity or failed checks with evidence to a medium worker or the coordinator; do not repeat blind low-effort attempts. Use a specialist role when its tools or output contract are needed, and inspect its actual model and effort. For bounded read-only inference, use RLM where suitable. Set effort low or medium only when the exposed RLM tool supports it; nested RLM calls inherit their route. An unsupported route is a blocker, not permission to switch the main model.
For live peer discovery, prefer (peers), (peer \"proud panda\"), and (self-peer) through self.eval. Inspect fields with (getf (rest row) :session-id). Resolve current identities before communication. Missing aliases stay NIL; use exact IDs. Never choose an ambiguous match. Discovery gives no new authority. Use localgroup status CLI only if these functions are unavailable or broken; report a failure rather than inventing an identity.")

(define-context-contributor dispatch-policy-context (request)
  "Supply the dispatch policy on each provider request without chat history."
  (declare (ignore request))
  (make-context-contribution
   :identifier "dispatch-policy-v1"
   :instruction *dispatch-policy-instruction*
   :priority 45
   :lifetime :while-relevant))

(defun dispatch-policy-status
    (&optional (configuration
                 (or *configuration*
                     (application-configuration *active-application*))))
  "Return effective role routes without changing configuration or calling a model."
  (multiple-value-bind (definitions diagnostics) (task-discover-agents configuration)
    (list
     :main-model (config :model configuration)
     :main-effort (config :reasoning-effort configuration)
     :roles
     (loop for name in '("dispatch-low" "dispatch-medium")
           for definition = (task-find-agent-definition definitions name)
           collect
           (if definition
               (let ((child (task-configuration-for-definition configuration definition)))
                 (list :name name
                       :source (task-agent-definition-source definition)
                       :path (task-agent-definition-pathname definition)
                       :model (config :model child)
                       :provider (configuration-model-provider-name child)
                       :effort (config :reasoning-effort child)))
               (list :name name :missing t)))
     :diagnostics (mapcar #'princ-to-string diagnostics))))

(defun dispatch-policy-reload ()
  "Reload only this policy and inspect current roles, without changing main settings."
  (let ((*extension-registration-source* :user))
    (load *dispatch-policy-pathname* :verbose nil :print nil))
  (dispatch-policy-status))
