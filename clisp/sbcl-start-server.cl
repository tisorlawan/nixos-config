(defun load-relative (file)
  (load (merge-pathnames
         file
         (make-pathname :name nil :type nil
                        :defaults *load-truename*))))

(load-relative #P"sbcl-server.cl")
(ignore-errors
  (defparameter *listener*
    (tcp-eval:start-server :port 5555)))
