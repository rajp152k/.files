;;; Run after the NixOS rebuild and the first Neovim plugin installation:
;;;   sbcl --script ~/.files/nix-habits/setup-common-lisp.lisp
(require :asdf)

(defpackage #:nvim-runtime-setup (:use #:cl))
(in-package #:nvim-runtime-setup)

(defparameter *backends*
  '(("swank-lsp" "20b04439b2ecd82c33d1b65f3a43c3a27b906c62")
    ("cl-scope-resolver" "b8a137c420d37ad4b2eecf529a29864b07328cde")
    ("jsonrpc" "53caf42cb3d4afabb84a3869505d16d25c423895")))

(defun run (&rest arguments)
  (uiop:run-program arguments :output *standard-output* :error-output *error-output*))

(defun xdg-directory (variable fallback)
  (let ((value (uiop:getenv variable)))
    (uiop:ensure-directory-pathname
     (if (and value (plusp (length value)))
         value
         (merge-pathnames fallback (user-homedir-pathname))))))

(defun ensure-backend (base name commit)
  (let ((directory (merge-pathnames (format nil "~A/" name) base)))
    (if (probe-file directory)
        (let ((head (string-trim '(#\Newline #\Return)
                                (uiop:run-program
                                 (list "git" "-C" (namestring directory) "rev-parse" "HEAD")
                                 :output :string))))
          (unless (and (string= head commit)
                       (zerop (length
                               (uiop:run-program
                                (list "git" "-C" (namestring directory) "status" "--porcelain")
                                :output :string))))
            (error "Backend ~A is modified or at another revision; inspect it before provisioning."
                   directory)))
        (progn
          (run "git" "clone" "--quiet" "--no-checkout"
               (format nil "https://github.com/ramfjord/~A.git" name) (namestring directory))
          (run "git" "-C" (namestring directory) "checkout" "--quiet" "--detach" commit)))
    (pushnew directory asdf:*central-registry* :test #'equal)))

(defun provision ()
  (let* ((data (xdg-directory "XDG_DATA_HOME" ".local/share/"))
         (backend (merge-pathnames "common-lisp/" data))
         (quicklisp (merge-pathnames "quicklisp/" (user-homedir-pathname)))
         (setup (merge-pathnames "setup.lisp" quicklisp))
         (bootstrap (merge-pathnames "nvim/quicklisp-bootstrap.lisp"
                                    (xdg-directory "XDG_CACHE_HOME" ".cache/")))
         (vlime (merge-pathnames "nvim/site/pack/core/opt/vlime/lisp/load-vlime.lisp" data)))
    (unless (probe-file vlime)
      (error "Install Neovim's declared plugins before provisioning the Lisp runtime."))
    (ensure-directories-exist backend)
    (dolist (entry *backends*)
      (apply #'ensure-backend backend entry))
    (unless (probe-file setup)
      (ensure-directories-exist bootstrap)
      (run "curl" "--fail" "--location" "--retry" "3" "--output" (namestring bootstrap)
           "https://beta.quicklisp.org/quicklisp.lisp")
      (let ((digest (uiop:run-program (list "sha256sum" (namestring bootstrap)) :output :string)))
        (unless (string= digest "4a7a5c2aebe0716417047854267397e24a44d0cce096127411e9ce9ccfeb2c17"
                         :end1 64)
          (error "Quicklisp bootstrap checksum mismatch.")))
      (load bootstrap)
      (uiop:symbol-call :quicklisp-quickstart :install :path quicklisp
                       :dist-url "http://beta.quicklisp.org/dist/quicklisp/2026-01-01/distinfo.txt"))
    (load setup)
    (uiop:symbol-call :ql :quickload :swank-lsp :silent t)
    (load vlime)
    (format t "~&Neovim Common Lisp runtime ready.~%")))

(provision)
