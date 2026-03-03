;;;; tcp-eval.lisp — minimal local TCP eval server (SBCL)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-bsd-sockets))

(defpackage :tcp-eval
  (:use :cl)
  (:export :start-server :stop-server))

(in-package :tcp-eval)

(defun %trim (s)
  (string-trim '(#\Space #\Tab #\Newline #\Return) s))

(defun start-server (&key (port 5555) (host "127.0.0.1"))
  (let* ((sock (make-instance 'sb-bsd-sockets:inet-socket
                              :type :stream
                              :protocol :tcp))
         (addr (sb-bsd-sockets:host-ent-address
                (sb-bsd-sockets:get-host-by-name host))))
    (sb-bsd-sockets:socket-bind sock addr port)
    (sb-bsd-sockets:socket-listen sock 5)
    (format t "~&[tcp-eval] Listening on ~a:~d~%" host port)

    (sb-thread:make-thread
     (lambda ()
       (loop
         (let ((client (sb-bsd-sockets:socket-accept sock)))
           (sb-thread:make-thread
            (lambda ()
              (unwind-protect
                   (let ((stream (sb-bsd-sockets:socket-make-stream
                                  client :input t :output t
                                  :element-type 'character
                                  :buffering :line)))
                     (format stream "OK READY~%")
                     (finish-output stream)
                     (loop for line = (read-line stream nil nil)
                           while line do
                             (let ((line (%trim line)))
                               (when (plusp (length line))
                                 (handler-case
                                     (let* ((*package* (find-package :cl-user))
                                            (form (read-from-string line))
                                            (vals (multiple-value-list (eval form))))
                                       (format stream "OK ~s~%" (car vals)))
                                   (error (e)
                                     (format stream "ERR ~a~%" e))))
                               (finish-output stream))))
                (ignore-errors (sb-bsd-sockets:socket-close client))))))))
     :name "tcp-eval-accept-loop")
    sock))

(defun stop-server (listener-socket)
  (ignore-errors (sb-bsd-sockets:socket-close listener-socket))
  (format t "~&[tcp-eval] Stopped.~%"))
