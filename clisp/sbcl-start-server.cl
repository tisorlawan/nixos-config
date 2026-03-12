(defun load-relative (file)
  (load (merge-pathnames
         file
         (make-pathname :name nil :type nil
                        :defaults *load-truename*))))

(load-relative #P"sbcl-server.cl")
; (load #P"/home/agung-b-sorlawan/.rice/clisp/sbcl-server.cl")
(ignore-errors
  (defparameter *listener*
    (tcp-eval:start-server :port 5677)))
