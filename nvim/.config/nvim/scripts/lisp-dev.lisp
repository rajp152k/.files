(require :asdf)
(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))

(defpackage #:nvim-lisp-dev (:use #:cl))
(in-package #:nvim-lisp-dev)

(defun env-directory (name)
  (uiop:ensure-directory-pathname
   (or (uiop:getenv name) (error "Missing environment variable ~A" name))))

(defun start-image ()
  (let* ((root (env-directory "LISP_DEV_ROOT"))
         (state (env-directory "LISP_DEV_STATE"))
         (backend (env-directory "LISP_DEV_BACKEND"))
         (data (env-directory "LISP_DEV_DATA"))
         (*default-pathname-defaults* root)
         (system (uiop:getenv "LISP_DEV_SYSTEM")))
    (dolist (directory '("swank-lsp/" "jsonrpc/" "cl-scope-resolver/"))
      (pushnew (merge-pathnames directory backend) asdf:*central-registry* :test #'equal))
    (ql:quickload :swank-lsp :silent t)
    (load (merge-pathnames "site/pack/core/opt/vlime/lisp/load-vlime.lisp" data))
    (pushnew (merge-pathnames "site/pack/core/opt/vlime/lisp/" data)
             asdf:*central-registry* :test #'equal)
    (asdf:initialize-source-registry
     `(:source-registry (:tree ,root) :inherit-configuration))
    (proclaim '(optimize (debug 3) (safety 3) (speed 1)))
    (when (and system (plusp (length system)))
      (ql:quickload system))
    ;; Resolve names after loading the packages, so this file reads on a fresh SBCL.
    (uiop:symbol-call :vlime :main :interface #(127 0 0 1) :port 0
                      :port-file (merge-pathnames "vlime.port" state))
    (uiop:symbol-call :swank-lsp :start-and-publish :host "127.0.0.1" :port 0
                      :port-file (merge-pathnames "lsp.port" state))
    (setf cl:*default-pathname-defaults* root)
    (format t "~&Project image ready: ~A~%" root)))

;; Server threads inherit these streams. Keep the log open until the image exits.
(defparameter *startup-log*
  (open (merge-pathnames "startup.log" (env-directory "LISP_DEV_STATE"))
        :direction :output :if-exists :supersede :if-does-not-exist :create))
(let ((*standard-output* (make-broadcast-stream *standard-output* *startup-log*))
      (*error-output* (make-broadcast-stream *error-output* *startup-log*)))
  (handler-case (start-image)
    (error (condition)
      (format *error-output* "~&SBCL startup failed: ~A~%" condition)
      (finish-output *error-output*)
      (uiop:quit 1))))
(in-package #:cl-user)
